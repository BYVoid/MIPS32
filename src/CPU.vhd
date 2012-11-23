library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use std.env.all;
use work.Common.all;

entity CPU is
  generic (
    debug      : boolean;
    fetch_wait : WaitCycles;
    load_wait  : WaitCycles;
    store_wait : WaitCycles
    );
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- RAM
    ram_en       : out std_logic                      := '1';
    ram_rw       : out RwType;
    ram_length   : out LenType;
    ram_addr     : out std_logic_vector (31 downto 0) := Int32_Zero;
    ram_data_in  : out std_logic_vector (31 downto 0);
    ram_data_out : in  std_logic_vector (31 downto 0)
    );
end CPU;

architecture Behavioral of CPU is
  component RegisterFile
    port (
      clk     : in  std_logic;
      rst     : in  std_logic;
      rw      : in  RwType;
      rdReg1  : in  std_logic_vector (4 downto 0);
      rdReg2  : in  std_logic_vector (4 downto 0);
      wrReg   : in  std_logic_vector (4 downto 0);
      wrData  : in  std_logic_vector (31 downto 0);
      rdData1 : out std_logic_vector (31 downto 0);
      rdData2 : out std_logic_vector (31 downto 0));
  end component;
  component AluOpEncoder
    port (
      op    : in  std_logic_vector(5 downto 0);
      func  : in  std_logic_vector(5 downto 0);
      rt    : in  std_logic_vector(4 downto 0);
      aluop : out AluOpType);
  end component;
  component ALU
    port (
      aluop    : in  AluOpType;
      operand1 : in  std_logic_vector(31 downto 0);
      operand2 : in  std_logic_vector(31 downto 0);
      result   : out std_logic_vector(31 downto 0));
  end component;

  signal reg_rw      : RwType;
  signal reg_rdReg1  : std_logic_vector (4 downto 0)  := "00000";
  signal reg_rdReg2  : std_logic_vector (4 downto 0)  := "00000";
  signal reg_wrReg   : std_logic_vector (4 downto 0)  := "00000";
  signal reg_wrData  : std_logic_vector (31 downto 0) := Int32_Zero;
  signal reg_rdData1 : std_logic_vector (31 downto 0);
  signal reg_rdData2 : std_logic_vector (31 downto 0);

  signal aluop    : AluOpType;
  signal alu_op   : std_logic_vector(5 downto 0)  := "000000";
  signal alu_func : std_logic_vector(5 downto 0)  := "000000";
  signal alu_rt   : std_logic_vector(4 downto 0)  := "00000";
  signal alu_a    : std_logic_vector(31 downto 0) := Int32_Zero;
  signal alu_b    : std_logic_vector(31 downto 0) := Int32_Zero;
  signal alu_r    : std_logic_vector(31 downto 0);


begin

  RegisterFile_1 : RegisterFile
    port map (
      clk     => clk,
      rst     => rst,
      rw      => reg_rw,
      rdReg1  => reg_rdReg1,
      rdReg2  => reg_rdReg2,
      wrReg   => reg_wrReg,
      wrData  => reg_wrData,
      rdData1 => reg_rdData1,
      rdData2 => reg_rdData2);
  AluOpEncoder_1 : AluOpEncoder
    port map (
      op    => alu_op,
      func  => alu_func,
      rt    => alu_rt,
      aluop => aluop);
  ALU_1 : ALU
    port map (
      aluop    => aluop,
      operand1 => alu_a,
      operand2 => alu_b,
      result   => alu_r);

  process (clk, rst)
    type StateType is (
      IF_0,                             -- Instruction Fetch
      IF_1,                             -- wait for fetching
      ID_0,                             -- Instruction Decode
      EX_0,                             -- Execute
      MEM_0,                            -- Memory Access
      MEM_1,                            -- wait for memory operation
      WB_0                              -- Write Back
      );

    variable state       : StateType;
    variable L           : line;
    variable pc, npc     : Int32;
    variable instr       : Int32;
    variable fetch_count : WaitCycles := 0;
    variable load_count  : WaitCycles := 0;
    variable store_count : WaitCycles := 0;

    alias op          : Int6 is instr(31 downto 26);
    alias rs          : Int5 is instr(25 downto 21);
    alias rt          : Int5 is instr(20 downto 16);
    alias rd          : Int5 is instr(15 downto 11);
    alias sa          : Int5 is instr(10 downto 6);
    alias func        : Int6 is instr(5 downto 0);
    alias instr_index : Int26 is instr(25 downto 0);
    alias imm         : Int16 is instr(15 downto 0);

    procedure instr_invalid is
    begin
      if debug then
        write(L, string'("instruction invalid"));
        writeline(output, L);
      end if;
      finish(0);
    end procedure;

    procedure halt is
    begin
      if debug then
        write(L, string'("halt"));
        writeline(output, L);
      end if;
      finish(0);
    end procedure;

    procedure fetch_debug(
      pc : Int32) is    
    begin
      if debug then
        write(L, string'("fetch instr @ "));
        write(L, to_hex_string(pc));
        writeline(output, L);
      end if;
    end procedure;
    
    procedure alu_debug(
      alu_a, alu_b, alu_r : std_logic_vector(31 downto 0)) is
    begin
      if debug then
        write(L, string'("alu_a <= "));
        write(L, to_hex_string(alu_a));
        write(L, string'(" ("));
        write(L, to_bitvector(alu_a));
        write(L, string'(")"));
        writeline(output, L);
        write(L, string'("alu_b <= "));
        write(L, to_hex_string(alu_b));
        write(L, string'(" ("));
        write(L, to_bitvector(alu_b));
        write(L, string'(")"));
        writeline(output, L);
        write(L, string'("alu_r :  "));
        write(L, to_hex_string(alu_r));
        write(L, string'(" ("));
        write(L, to_bitvector(alu_r));
        write(L, string'(")"));
        writeline(output, L);
      end if;
    end procedure;
    
    procedure reg_debug(
      rw   : RwType;
      reg  : std_logic_vector(4 downto 0);
      data : std_logic_vector(31 downto 0)) is
    begin
      if debug then
        write(L, string'("R["));
        write(L, to_integer(unsigned(reg)), right, 2);
        if rw = R then
          write(L, string'("] :  "));
        else
          write(L, string'("] <= "));
        end if;
        write(L, to_hex_string(data));
        write(L, string'(" ("));
        write(L, to_bitvector(data));
        write(L, string'(")"));
        writeline(output, L);
      end if;
    end procedure;

    function sign_extend(data_in : std_logic_vector) return Int32 is
    begin
      return (std_logic_vector(resize(signed(data_in), 32)));
    end function;

    procedure newline is
    begin
      if debug then
        writeline(output, L);
      end if;
    end procedure;
    
  begin
    if rst = '0' then
      --reset
      if debug then
        write(L, string'("booting"));
        writeline(output, L);
      end if;
      npc   := Int32_Zero;
      state := IF_0;
      
    elsif rising_edge(clk) then
      case state is
        when IF_0 =>
          newline;
          -- finish writing to register
          reg_rw     <= R;
          -- renew pc
          pc         := npc;
          npc        := std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
          -- prepare to fetch an instruction
          fetch_debug(pc);
          ram_en     <= '0';
          ram_rw     <= R;
          ram_length <= Lword;
          ram_addr   <= pc;
          state      := IF_1;
        when IF_1 =>
          -- wait until fetching complete
          if fetch_count = fetch_wait then
            fetch_count := 0;
            state       := ID_0;
          else
            fetch_count := fetch_count + 1;
          end if;
        when others =>
          if state = ID_0 then
            -- instruction fetched
            ram_en   <= '1';
            instr    := ram_data_out;
            alu_op   <= op;
            alu_func <= func;
            alu_rt   <= rt;
          end if;
          -- ID_0, EX_0, MEM_0, MEM_1, WB_0 for each instruction
          case op is
            when op_special =>
              case func is
                when func_syscall =>
                  halt;
                when func_jr | func_jalr =>
                when func_sll | func_srl | func_sra |
                  func_sllv | func_srlv | func_srav |
                  func_addu | func_subu |
                  func_and | func_or | func_xor | func_nor |
                  func_slt | func_sltu =>
                  case state is
                    when ID_0 =>
                      reg_rdReg1 <= rs;
                      reg_rdReg2 <= rt;
                      state      := EX_0;
                    when EX_0 =>
                      if func /= func_sll and
                        func /= func_srl and
                        func /= func_sra then
                        reg_debug(R, reg_rdReg1, reg_rdData1);
                      end if;
                      reg_debug(R, reg_rdReg2, reg_rdData2);
                      if func = func_sll or func = func_srl or func = func_sra then
                        alu_a <= Int16_Zero & Int8_Zero & "000" & sa;
                      else
                        alu_a <= reg_rdData1;
                      end if;
                      alu_b <= reg_rdData2;
                      state := WB_0;
                    when WB_0 =>
                      alu_debug(alu_a, alu_b, alu_r);
                      reg_rw     <= W;
                      reg_wrReg  <= rd;
                      reg_wrData <= alu_r;
                      reg_debug(W, rd, alu_r);
                      state      := IF_0;
                    when others =>
                      -- impossible;
                  end case;
                when others =>
                  instr_invalid;
              end case;
            when op_regimm | op_beq | op_bne | op_blez | op_bgtz =>
              if op = op_regimm and rt /= rt_bltz and rt /= rt_bgez then
                instr_invalid;
              end if;
            when op_j | op_jal                                              =>
            when op_addiu | op_slti | op_sltiu | op_andi | op_ori | op_xori =>
              case state is
                when ID_0 =>
                  reg_rdReg1 <= rs;
                  state      := EX_0;
                when EX_0 =>
                  reg_debug(R, reg_rdReg1, reg_rdData1);
                  alu_a <= reg_rdData1;
                  if op = op_andi or op = op_ori or op = op_xori then
                    alu_b <= Int16_Zero & imm;
                  else
                    alu_b <= sign_extend(imm);
                  end if;
                  state := WB_0;
                when WB_0 =>
                  alu_debug(alu_a, alu_b, alu_r);
                  reg_rw     <= W;
                  reg_wrReg  <= rt;
                  reg_wrData <= alu_r;
                  reg_debug(W, rt, alu_r);
                  state      := IF_0;
                when others =>
                  -- impossible
              end case;
            when op_lui =>
              reg_rw     <= W;
              reg_wrReg  <= rt;
              reg_wrData <= imm & Int16_Zero;
              reg_debug(W, rt, imm & Int16_Zero);
              state      := IF_0;
            when op_lb | op_lh | op_lw | op_lbu | op_lhu =>
              case state is
                when ID_0 =>
                  reg_rdReg1 <= rs;
                  state      := EX_0;
                when EX_0 =>
                  reg_debug(R, reg_rdReg1, reg_rdData1);
                  alu_a <= reg_rdData1;
                  alu_b <= sign_extend(imm);
                  state := MEM_0;
                when MEM_0 =>
                  alu_debug(alu_a, alu_b, alu_r);
                  ram_en   <= '0';
                  ram_rw   <= R;
                  ram_addr <= alu_r;
                  if op = op_lw then
                    ram_length <= Lword;
                  elsif op = op_lh or op = op_lhu then
                    ram_length <= Lhalf;
                  else
                    ram_length <= Lbyte;
                  end if;
                  state := MEM_1;
                when MEM_1 =>
                  -- wait until loading complete
                  if load_count = load_wait then
                    load_count := 0;
                    state      := WB_0;
                  else
                    load_count := load_count + 1;
                  end if;
                when WB_0 =>
                  ram_en    <= '1';
                  reg_rw    <= W;
                  reg_wrReg <= rt;
                  if op = op_lb then
                    reg_wrData <= sign_extend(ram_data_out(7 downto 0));
                    reg_debug(W, rt, sign_extend(ram_data_out(7 downto 0)));
                  elsif op = op_lh then
                    reg_wrData <= sign_extend(ram_data_out(15 downto 0));
                    reg_debug(W, rt, sign_extend(ram_data_out(15 downto 0)));
                  else
                    reg_wrData <= ram_data_out;
                    reg_debug(W, rt, ram_data_out);
                  end if;
                  state := IF_0;
                when others =>
                  -- impossible
              end case;
            when op_sb | op_sh | op_sw =>
              case state is
                when ID_0 =>
                  reg_rdReg1 <= rs;
                  reg_rdReg2 <= rt;
                  state      := EX_0;
                when EX_0 =>
                  reg_debug(R, reg_rdReg1, reg_rdData1);
                  reg_debug(R, reg_rdReg2, reg_rdData2);
                  alu_a <= reg_rdData1;
                  alu_b <= sign_extend(imm);
                  state := MEM_0;
                when MEM_0 =>
                  alu_debug(alu_a, alu_b, alu_r);
                  ram_en      <= '0';
                  ram_rw      <= W;
                  ram_addr    <= alu_r;
                  ram_data_in <= reg_rdData2;
                  if op = op_sw then
                    ram_length <= Lword;
                  elsif op = op_sh then
                    ram_length <= Lhalf;
                  else
                    ram_length <= Lbyte;
                  end if;
                  state := MEM_1;
                when MEM_1 =>
                  -- wait until storing complete
                  if store_count = store_wait then
                    store_count := 0;
                    state       := IF_0;
                  else
                    store_count := store_count + 1;
                  end if;
                when others =>
                  -- impossible
              end case;
            when others =>
              instr_invalid;
          end case;
      end case;
    end if;
  end process;
  
end Behavioral;

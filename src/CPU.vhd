library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
--sim: use std.env.all;
use work.Common.all;

entity CPU is
  generic (
    debug      : boolean;
    start_addr : std_logic_vector (31 downto 0)
    );
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- RAM
    mem_en        : out std_logic                      := '1';
    mem_rw        : out RwType;
    mem_length    : out LenType;
    mem_addr      : out std_logic_vector (31 downto 0) := Int32_Zero;
    mem_data_in   : out std_logic_vector (31 downto 0);
    mem_data_out  : in  std_logic_vector (31 downto 0);
    mem_completed : in  std_logic;
    
    led    : out std_logic_vector (15 downto 0);
    seg7_l_num: out Int4
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
      aluop: in AluOpType;
      operand1: in Int32;
      operand2: in Int32;
      result: out Int32;
      result_ext: out Int32
    );
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
  signal alu_rext : std_logic_vector(31 downto 0);

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
      result   => alu_r,
      result_ext => alu_rext
    );

  process (clk, rst)
    type StateType is (
      HALT,
      IF_0,                             -- Instruction Fetch
      IF_1,                             -- wait for fetching
      ID_0,                             -- Instruction Decode
      EX_0,                             -- Execute
      MEM_0,                            -- Memory Access
      MEM_1,                            -- wait for memory operation
      WB_0                              -- Write Back
      );

    variable state   : StateType;
    variable L       : line;
    variable pc, npc : Int32;
    variable instr   : Int32;

    alias op          : Int6 is instr(31 downto 26);
    alias rs          : Int5 is instr(25 downto 21);
    alias rt          : Int5 is instr(20 downto 16);
    alias rd          : Int5 is instr(15 downto 11);
    alias sa          : Int5 is instr(10 downto 6);
    alias func        : Int6 is instr(5 downto 0);
    alias instr_index : Int26 is instr(25 downto 0);
    alias imm         : Int16 is instr(15 downto 0);

    procedure print_state(
      state: in StateType;
      signal seg7_l_num: out Int4) is
    begin
      case state is
        when HALT =>
          seg7_l_num <= std_logic_vector(to_signed(0, 4));
        when IF_0 =>
          seg7_l_num <= std_logic_vector(to_signed(1, 4));
        when IF_1 =>
          seg7_l_num <= std_logic_vector(to_signed(2, 4));
        when ID_0 =>
          seg7_l_num <= std_logic_vector(to_signed(3, 4));
        when EX_0 =>
          seg7_l_num <= std_logic_vector(to_signed(4, 4));
        when MEM_0 =>
          seg7_l_num <= std_logic_vector(to_signed(5, 4));
        when MEM_1 =>
          seg7_l_num <= std_logic_vector(to_signed(6, 4));
        when WB_0 =>
          seg7_l_num <= std_logic_vector(to_signed(7, 4));
        when others =>
          seg7_l_num <= std_logic_vector(to_signed(15, 4));
      end case;
    end;

    procedure instr_invalid is
    begin
      if debug then
        write(L, string'("instruction invalid"));
        writeline(output, L);
      end if;
      --sim: finish(0);
      state := IF_0;
    end procedure;
    
    procedure bad_addr is
    begin
      if debug then
        write(L, string'("bad address"));
        writeline(output, L);
      end if;
      --sim: finish(0);
    end procedure;
    

    procedure halt is
    begin
      if debug then
        write(L, string'("halt"));
        writeline(output, L);
      end if;
      --sim: finish(0);
    end procedure;

    procedure fetch_debug(
      pc : Int32) is    
    begin
      if debug then
        write(L, string'("fetch instr @ "));
        write(L, to_hex_string(pc));
        write(L, string'(" ("));
        write(L, to_bitvector(pc));
        write(L, string'(")"));
        writeline(output, L);
      end if;
    end procedure;

    procedure decode_debug is
    begin
      if debug then
        case op is
          when op_special =>
            write(L, to_bitvector(op));
            write(L, string'(" | "));
            write(L, to_bitvector(rs));
            write(L, string'(" | "));
            write(L, to_bitvector(rt));
            write(L, string'(" | "));
            write(L, to_bitvector(rd));
            write(L, string'(" | "));
            write(L, to_bitvector(sa));
            write(L, string'(" | "));
            write(L, to_bitvector(func));
            writeline(output, L);
            write(L, opcode_names(to_integer(unsigned(op))));
            write(L, string'("  "));
            write(L, string'("rs:"));
            write(L, to_integer(unsigned(rs)), right, 2);
            write(L, string'("   "));
            write(L, string'("rt:"));
            write(L, to_integer(unsigned(rt)), right, 2);
            write(L, string'("   "));
            write(L, string'("rd:"));
            write(L, to_integer(unsigned(rd)), right, 2);
            write(L, string'("   "));
            write(L, string'("sa:"));
            write(L, to_integer(unsigned(sa)), right, 2);
            write(L, string'("   "));
            write(L, sp_func_names(to_integer(unsigned(func))));
            writeline(output, L);
          when op_regimm =>
            write(L, to_bitvector(op));
            write(L, string'(" | "));
            write(L, to_bitvector(rs));
            write(L, string'(" | "));
            write(L, to_bitvector(rt));
            write(L, string'(" | "));
            write(L, to_bitvector(imm));
            writeline(output, L);
            write(L, opcode_names(to_integer(unsigned(op))));
            write(L, string'("  "));
            write(L, string'("rs:"));
            write(L, to_integer(unsigned(rs)), right, 2);
            write(L, string'("   "));
            write(L, ri_rt_names(to_integer(unsigned(rt))));
            write(L, string'("    "));
            write(L, string'("imm:"));
            write(L, to_hex_string(imm));
            writeline(output, L);
          when op_j | op_jal =>
            write(L, to_bitvector(op));
            write(L, string'(" | "));
            write(L, to_bitvector(instr_index));
            writeline(output, L);
            write(L, opcode_names(to_integer(unsigned(op))));
            write(L, string'("  "));
            write(L, string'("instr_index:"));
            write(L, to_hex_string(instr_index));
            writeline(output, L);
          when others =>
            write(L, to_bitvector(op));
            write(L, string'(" | "));
            write(L, to_bitvector(rs));
            write(L, string'(" | "));
            write(L, to_bitvector(rt));
            write(L, string'(" | "));
            write(L, to_bitvector(imm));
            writeline(output, L);
            write(L, opcode_names(to_integer(unsigned(op))));
            write(L, string'("  "));
            write(L, string'("rs:"));
            write(L, to_integer(unsigned(rs)), right, 2);
            write(L, string'("   "));
            write(L, string'("rt:"));
            write(L, to_integer(unsigned(rt)), right, 2);
            write(L, string'("   "));
            write(L, string'("imm:"));
            write(L, to_hex_string(imm));
            writeline(output, L);
        end case;
        
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
    
    procedure mmu_debug(
      addr_virt : std_logic_vector(31 downto 0);
      addr_phys : std_logic_vector(31 downto 0)) is
    begin
      if debug then
        write(L, string'("MMU["));
        write(L, to_hex_string(addr_virt));
        write(L, string'("] :  "));
        write(L, to_hex_string(addr_phys));
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
    
    procedure write_reg(
      reg  : std_logic_vector(4 downto 0);
      data : std_logic_vector(31 downto 0)) is
    begin
      reg_rw     <= W;
      reg_wrReg  <= reg;
      reg_wrData <= data;
      reg_debug(W, reg, data);
    end procedure;
    
    procedure conv_mem_addr(
      addr : std_logic_vector (31 downto 0)) is
    begin
      case addr(31 downto 28) is
        when x"8" | x"9" | x"A" | x"B" =>
          --if mode = Kernel then
            mmu_debug(addr, "000" & addr(28 downto 0));
            mem_addr <= "000" & addr(28 downto 0);
          --else
            -- exception 
          --end if;
        when others =>
          bad_addr;        
      end case;
    end procedure;
    
  begin
    if rst = '0' then
      --reset
      if debug then
        write(L, string'("booting"));
        writeline(output, L);
      end if;

      mem_en <= '1';
      mem_rw <= R;
      reg_rw <= R;

      npc   := start_addr;
      state := IF_0;
      
    elsif rising_edge(clk) then
      print_state(state, seg7_l_num); -- Debug --
      case state is
        when HALT =>
          -- do nothing
        when IF_0 =>
          newline;
          -- finish writing to register
          reg_rw     <= R;
          -- renew pc
          pc         := npc;
          npc        := std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
          -- prepare to fetch an instruction
          fetch_debug(pc);
          mem_en     <= '0';
          mem_rw     <= R;
          mem_length <= Lword;
          conv_mem_addr(pc);
          state := IF_1;
        when IF_1 =>
          -- wait until fetching complete
          if mem_completed = '1' then
            -- instruction fetched
            mem_en <= '1';
            instr  := mem_data_out;
            state  := ID_0;
          end if;
        when others =>
          if state = ID_0 then
            decode_debug;
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
                  state := HALT;
                when func_jr | func_jalr =>
                  case state is
                    when ID_0 =>
                      reg_rdReg1 <= rs;
                      state      := WB_0;
                    when WB_0 =>
                      reg_debug(R, reg_rdReg1, reg_rdData1);
                      npc := reg_rdData1;
                      if func = func_jalr then
                        write_reg(rd, std_logic_vector(unsigned(pc) + to_unsigned(8, 32)));
                      end if;
                      state := IF_0;
                    when others =>
                      -- impossible
                  end case;
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
                        alu_a <= Int24_Zero & "000" & sa;
                      else
                        alu_a <= reg_rdData1;
                      end if;
                      alu_b <= reg_rdData2;
                      state := WB_0;
                    when WB_0 =>
                      alu_debug(alu_a, alu_b, alu_r);
                      write_reg(rd, alu_r);
                      state := IF_0;
                    when others =>
                      -- impossible;
                  end case;
                when others =>
                  instr_invalid;
              end case;
            when op_regimm | op_beq | op_bne | op_blez | op_bgtz =>
              case state is
                when ID_0 =>
                  if op = op_regimm and rt /= rt_bltz and rt /= rt_bgez then
                    instr_invalid;
                  end if;
                  reg_rdReg1 <= rs;
                  reg_rdReg2 <= rt;
                  state      := EX_0;
                when EX_0 =>
                  reg_debug(R, reg_rdReg1, reg_rdData1);
                  if op = op_beq or op = op_bne then
                    reg_debug(R, reg_rdReg2, reg_rdData2);
                  end if;
                  alu_a <= reg_rdData1;
                  alu_b <= reg_rdData2;
                  state := WB_0;
                when WB_0 =>
                  if alu_r(0) = '1' then
                    npc := std_logic_vector(unsigned(pc) + to_unsigned(4, 32) + unsigned(resize(signed(imm & "00"), 32)));
                  end if;
                  state := IF_0;
                when others =>
                  -- impossible
              end case;
            when op_j | op_jal =>
              case state is
                when ID_0 =>
                  npc := npc(31 downto 28) & instr_index & "00";
                  if op = op_j then
                    state := IF_0;
                  else
                    state := WB_0;
                  end if;
                when WB_0 =>
                  write_reg("11111", std_logic_vector(unsigned(pc) + to_unsigned(8, 32)));
                  state := IF_0;
                when others =>
                  -- impossible
              end case;
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
                  write_reg(rt, alu_r);
                  state := IF_0;
                when others =>
                  -- impossible
              end case;
            when op_lui =>
              write_reg(rt, imm & Int16_Zero);
              state := IF_0;
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
                  mem_en   <= '0';
                  mem_rw   <= R;
                  conv_mem_addr(alu_r);
                  if op = op_lw then
                    mem_length <= Lword;
                  elsif op = op_lh or op = op_lhu then
                    mem_length <= Lhalf;
                  else
                    mem_length <= Lbyte;
                  end if;
                  state := MEM_1;
                when MEM_1 =>
                  -- wait until loading complete
                  if mem_completed = '1' then
                    mem_en <= '1';
                    state  := WB_0;
                  end if;
                when WB_0 =>
                  if op = op_lb then
                    write_reg(rt, sign_extend(mem_data_out(7 downto 0)));
                  elsif op = op_lh then
                    write_reg(rt, sign_extend(mem_data_out(15 downto 0)));
                  else
                    write_reg(rt, mem_data_out);
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
                  mem_en      <= '0';
                  mem_rw      <= W;
                  mem_data_in <= reg_rdData2;
                  conv_mem_addr(alu_r);
                  
                  if op = op_sw then
                    mem_length <= Lword;
                  elsif op = op_sh then
                    mem_length <= Lhalf;
                  else
                    mem_length <= Lbyte;
                  end if;
                  state := MEM_1;
                when MEM_1 =>
                  -- wait until storing complete
                  if mem_completed = '1' then
                    mem_en <= '1';
                    mem_rw <= R;
                    state  := IF_0;
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

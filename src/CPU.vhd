library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.Common.all;

entity CPU is
  port (
    clk : in std_logic;
    rst : in std_logic;

    -- RAM
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
  
  type StateType is (
    IF_0,                               -- Instruction Fetch
    ID_0,                               -- Instruction Decode
    EX_0,                               -- Execute
    MEM_0,                              -- Memory Access
    WB_0                                -- Write Back
    );

  signal reg_rw      : RwType;
  signal reg_rdReg1  : std_logic_vector (4 downto 0) := "00000";
  signal reg_rdReg2  : std_logic_vector (4 downto 0) := "00000";
  signal reg_wrReg   : std_logic_vector (4 downto 0) := "00000";
  signal reg_wrData  : std_logic_vector (31 downto 0) := Int32_Zero;
  signal reg_rdData1 : std_logic_vector (31 downto 0);
  signal reg_rdData2 : std_logic_vector (31 downto 0);

  signal aluop    : AluOpType;
  signal alu_op   : std_logic_vector(5 downto 0) := "000000";
  signal alu_func : std_logic_vector(5 downto 0) := "000000";
  signal alu_rt   : std_logic_vector(4 downto 0) := "00000";
  signal alu_a    : std_logic_vector(31 downto 0) := Int32_Zero;
  signal alu_b    : std_logic_vector(31 downto 0) := Int32_Zero;
  signal alu_r    : std_logic_vector(31 downto 0);

  signal state : StateType;
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
    variable L              : line;
    variable pc, npc        : Int32;
    variable instr          : Int32;
    variable op, func       : std_logic_vector (5 downto 0);
    variable rs, rt, rd, sa : std_logic_vector (4 downto 0);
    variable imm            : std_logic_vector (15 downto 0);
    variable instr_index    : std_logic_vector (25 downto 0);
  begin
    if rst = '0' then
      --reset
      write(L, string'("booting"));
      writeline(output, L);

      npc   := Int32_Zero;
      state <= IF_0;
    elsif rising_edge(clk) then
      case state is
        when IF_0 =>
          -- finish writing to register
          reg_rw <= R;

          -- renew pc
          pc         := npc;
          npc        := std_logic_vector(unsigned(pc) + to_unsigned(4, 32));
          -- prepare to fetch an instruction
          ram_rw     <= R;
          ram_length <= Lword;
          ram_addr   <= pc;

          write(L, string'("fetch instr @ "));
          write(L, to_bitvector(pc));
          writeline(output, L);

          -- change state
          state <= ID_0;
          
        when ID_0 =>
          -- instruction fetched
          instr       := ram_data_out;
          write(L, string'("instr: "));
          write(L, to_bitvector(instr));
          writeline(output, L);

          
          -- decode
          op          := instr(31 downto 26);
          instr_index := instr(25 downto 0);
          rs          := instr(25 downto 21);
          rt          := instr(20 downto 16);
          imm         := instr(15 downto 0);
          rd          := instr(15 downto 11);
          sa          := instr(10 downto 6);
          func        := instr(5 downto 0);

          -- prepare to read registers, then change state
          if op = op_lui then
            write(L, string'("lui"));
            writeline(output, L);
            state <= EX_0;
          elsif op = op_j or op = op_jal then
            npc := npc(31 downto 28) & instr_index & "00";
            write(L, string'("jump to"));
            write(L, to_bitvector(npc));
            writeline(output, L);
            if op = op_j then
              state <= IF_0;
            else
              state <= WB_0;
            end if;
          else
            write(L, string'("read rs, rt: "));
            write(L, to_bitvector(rs));
            write(L, string'(", "));
            write(L, to_bitvector(rt));
            writeline(output, L);
            reg_rw     <= R;
            reg_rdReg1 <= rs;
            reg_rdReg2 <= rt;
            state      <= EX_0;
          end if;
          
        when EX_0 =>
          -- registers read out
          write(L, string'("R[rs]: "));
          write(L, to_bitvector(reg_rdData1));
          writeline(output, L);
          write(L, string'("R[rt]: "));
          write(L, to_bitvector(reg_rdData2));
          writeline(output, L);

          -- prepare alu inputs, and then change state
          alu_op   <= op;
          alu_func <= func;
          alu_rt   <= rt;

          case op is
            when op_special =>
              if func = func_jr or func = func_jalr then
                npc := reg_rdData1;
                write(L, string'("jump to"));
                write(L, to_bitvector(npc));
                writeline(output, L);
                if func = func_jr then
                  state <= IF_0;
                else
                  state <= WB_0;
                end if;
              elsif func = func_sll or func = func_srl or func = func_sra then
                alu_a <= Int16_Zero & Int8_Zero & "000" & sa;
                alu_b <= reg_rdData2;
                state <= WB_0;
              else
                alu_a <= reg_rdData1;
                alu_b <= reg_rdData2;
                state <= WB_0;
              end if;
            when op_lui =>
              alu_a <= Int16_Zero & Int8_Zero & "00010000";
              alu_b <= Int16_Zero & imm;
              state <= WB_0;
            when op_andi | op_ori | op_xori =>
              alu_a <= reg_rdData1;
              alu_b <= Int16_Zero & imm;
              state <= WB_0;
            when op_addiu | op_slti | op_sltiu =>
              alu_a <= reg_rdData1;
              -- sign-extend
              alu_b <= std_logic_vector(resize(signed(imm), 32));
              state <= WB_0;
            when op_sw | op_lw | op_sb | op_lb | op_lbu =>
              alu_a <= reg_rdData1;
              alu_b <= std_logic_vector(resize(signed(imm), 32));
              state <= MEM_0;
            when others =>
              alu_a <= reg_rdData1;
              alu_b <= reg_rdData2;
              state <= WB_0;
          end case;

          write(L, string'("alu_a: "));
          write(L, to_bitvector(alu_a));
          writeline(output, L);
          write(L, string'("alu_b: "));
          write(L, to_bitvector(alu_b));
          writeline(output, L);

        when MEM_0 =>
          -- alu result
          ram_addr <= alu_r;

          write(L, string'("ram_addr: "));
          write(L, to_bitvector(alu_r));
          writeline(output, L);

          case op is
            when op_lw =>
              ram_rw     <= R;
              ram_length <= Lword;
              state      <= WB_0;
            when op_lbu | op_lb =>
              ram_rw     <= R;
              ram_length <= Lbyte;
              state      <= WB_0;
            when op_sw =>
              ram_rw      <= W;
              ram_length  <= Lword;
              ram_data_in <= reg_rdData2;
              state       <= IF_0;
            when op_sb =>
              ram_rw      <= W;
              ram_length  <= Lbyte;
              ram_data_in <= reg_rdData2;
              state       <= IF_0;
            when others =>
          end case;



        when WB_0 =>

          case op is
            when op_lw | op_lbu =>
              reg_wrReg  <= rt;
              reg_wrData <= ram_data_out;
              reg_rw     <= W;
            when op_lb =>
              reg_wrReg  <= rt;
              reg_wrData <= std_logic_vector(resize(signed(ram_data_out(15 downto 0)), 32));
              reg_rw     <= W;
            when op_special =>
              if func = func_jalr then
                reg_wrData <= std_logic_vector(unsigned(pc) + to_unsigned(8, 32));
              else
                reg_wrData <= alu_r;
              end if;
              reg_wrReg <= rd;
              reg_rw    <= W;
            when op_jal =>
              reg_wrReg  <= "11111";
              reg_wrData <= std_logic_vector(unsigned(pc) + to_unsigned(8, 32));
              reg_rw     <= W;
            when op_addiu | op_sltiu | op_slti | op_andi | op_ori | op_xori =>
              reg_wrReg  <= rt;
              reg_wrData <= alu_r;
              reg_rw     <= W;
            when op_beq | op_bne | op_bgtz | op_blez | op_regimm =>
              if alu_r(0) = '1' then
                npc := std_logic_vector(unsigned(pc) + to_unsigned(4, 32) + unsigned(resize(signed(imm & "00"), 32)));
              end if;
            when others =>
          end case;

          write(L, string'("write "));
          write(L, to_bitvector(reg_wrData));
          write(L, string'(" to Reg "));
          write(L, to_bitvector(reg_wrReg));
          writeline(output, L);

          state <= IF_0;
      end case;
    end if;
  end process;
  
end Behavioral;

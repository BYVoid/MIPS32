library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Common is
  type RwType is (R, W);
  type LenType is (Lword, Lhalf, Lbyte);
  type AluOpType is (
    ALU_NOP,
    ALU_AND, ALU_OR, ALU_XOR, ALU_NOR,
    ALU_ADD, ALU_SUB,
    ALU_SRL, ALU_SRA, ALU_SLL,
    ALU_EQ, ALU_NE,
    ALU_LT, ALU_LTU,
    ALU_GTZ, ALU_LEZ, ALU_GEZ);
    
  subtype WaitCycles is integer range 0 to 15;

  subtype Int32 is std_logic_vector(31 downto 0);
  subtype Int31 is std_logic_vector(30 downto 0);
  subtype Int30 is std_logic_vector(29 downto 0);
  subtype Int26 is std_logic_vector(25 downto 0);
  subtype Int24 is std_logic_vector(23 downto 0);
  subtype Int23 is std_logic_vector(22 downto 0);
  subtype Int18 is std_logic_vector(17 downto 0);
  subtype Int16 is std_logic_vector(15 downto 0);
  subtype Int10 is std_logic_vector(9  downto 0);
  subtype Int8  is std_logic_vector(7  downto 0);
  subtype Int6  is std_logic_vector(5  downto 0);
  subtype Int5  is std_logic_vector(4  downto 0);
  subtype Int4  is std_logic_vector(3  downto 0);
  
  subtype Signed32 is signed(31 downto 0);
  subtype Unsigned32 is unsigned(31 downto 0);

  constant Int8_Zero:     Int8  := "00000000";
  constant Int8_Z:        Int8  := "ZZZZZZZZ";
  constant Int16_Zero:    Int16 := "0000000000000000";
  constant Int16_Z:       Int16 := "ZZZZZZZZZZZZZZZZ";
  constant Int24_Zero:    Int24 := "000000000000000000000000";
  constant Int30_Zero:    Int30 := "000000000000000000000000000000";
  constant Int31_Zero:    Int31 := "0000000000000000000000000000000";
  constant Int32_Zero:    Int32 := "00000000000000000000000000000000";
  constant Int32_Z:       Int32 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
  constant COM_Data_Addr: Int32 := x"1FD003F8";
  constant COM_Stat_Addr: Int32 := x"1FD003FC";

  -- opcode
  constant op_special : Int6 := "000000";
  constant op_regimm  : Int6 := "000001";
  constant op_j       : Int6 := "000010";
  constant op_jal     : Int6 := "000011";
  constant op_beq     : Int6 := "000100";
  constant op_bne     : Int6 := "000101";
  constant op_blez    : Int6 := "000110";
  constant op_bgtz    : Int6 := "000111";
  constant op_addiu   : Int6 := "001001";
  constant op_slti    : Int6 := "001010";
  constant op_sltiu   : Int6 := "001011";
  constant op_andi    : Int6 := "001100";
  constant op_ori     : Int6 := "001101";
  constant op_xori    : Int6 := "001110";
  constant op_lui     : Int6 := "001111";
  constant op_lb      : Int6 := "100000";
  constant op_lh      : Int6 := "100001";
  constant op_lw      : Int6 := "100011";
  constant op_lbu     : Int6 := "100100";
  constant op_sb      : Int6 := "101000";
  constant op_sh      : Int6 := "101001";
  constant op_sw      : Int6 := "101011";

  -- func
  constant func_sll     : Int6 := "000000";
  constant func_srl     : Int6 := "000010";
  constant func_sra     : Int6 := "000011";
  constant func_sllv    : Int6 := "000100";
  constant func_srlv    : Int6 := "000110";
  constant func_srav    : Int6 := "000111";
  constant func_jr      : Int6 := "001000";
  constant func_jalr    : Int6 := "001001";
  constant func_syscall : Int6 := "001100";
  constant func_mfhi    : Int6 := "010000";
  constant func_mthi    : Int6 := "010001";
  constant func_mflo    : Int6 := "010010";
  constant func_mtlo    : Int6 := "010100";
  constant func_mult    : Int6 := "011000";
  constant func_multu   : Int6 := "011001";
  constant func_addu    : Int6 := "100001";
  constant func_subu    : Int6 := "100011";
  constant func_and     : Int6 := "100100";
  constant func_or      : Int6 := "100101";
  constant func_xor     : Int6 := "100110";
  constant func_nor     : Int6 := "100111";
  constant func_slt     : Int6 := "101010";
  constant func_sltu    : Int6 := "101011";

  -- rt
  constant rt_bltz : Int5 := "00000";
  constant rt_bgez : Int5 := "00001";
  
  function boolean_to_std_logic(cond: boolean) return std_logic;

end Common;

package body Common is
  function boolean_to_std_logic(cond: boolean) return std_logic is 
  begin 
    if cond then 
      return('1'); 
    else 
      return('0'); 
    end if; 
  end function boolean_to_std_logic; 
end Common;

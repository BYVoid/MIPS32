library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Common is
  type RwType is (R, W);
  type LenType is (Lword, Lhalf, Lbyte);
  type AluOpType is (
    ALU_AND, ALU_OR, ALU_XOR, ALU_NOR,
    ALU_ADD, ALU_SUB,
    ALU_SRL, ALU_SRA, ALU_SLL,
    ALU_EQ, ALU_NE,
    ALU_LT, ALU_LTU,
    ALU_GTZ, ALU_LEZ, ALU_GEZ);
  
  subtype Int32 is std_logic_vector(31 downto 0);
  subtype Int31 is std_logic_vector(30 downto 0);
  subtype Int16 is std_logic_vector(15 downto 0);
  subtype Int8  is std_logic_vector(7  downto 0);
  subtype Int5  is std_logic_vector(4  downto 0);
  subtype Int4  is std_logic_vector(3  downto 0);
  
  subtype Signed32 is signed(31 downto 0);
  subtype Unsigned32 is unsigned(31 downto 0);

  constant Int8_Zero:     Int8  := "00000000";
  constant Int8_Z:        Int8  := "ZZZZZZZZ";
  constant Int16_Zero:    Int16 := "0000000000000000";
  constant Int16_Z:       Int16 := "ZZZZZZZZZZZZZZZZ";
  constant Int31_Zero:    Int31 := "0000000000000000000000000000000";
  constant Int32_Zero:    Int32 := "00000000000000000000000000000000";
  constant Int32_Z:       Int32 := "ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ";
  constant COM_Address:   Int32 := x"1FD003F8";
  
  constant OP_AND:        Int5  := "00000";
  constant OP_OR:         Int5  := "00001";
  constant OP_XOR:        Int5  := "00010";
  constant OP_NOR:        Int5  := "00011";
  constant OP_NOT:        Int5  := "00100";
  constant OP_PLUS:       Int5  := "00101";
  constant OP_MINUS:      Int5  := "00110";
  constant OP_SRL:        Int5  := "00111";
  constant OP_SRA:        Int5  := "01000";
  constant OP_SLL:        Int5  := "01001";
  constant OP_EQ:         Int5  := "01010";
  constant OP_NE:         Int5  := "01011";
  constant OP_LTU:        Int5  := "01100";
  constant OP_LT:         Int5  := "01101";
  constant OP_GTU:        Int5  := "01110";
  constant OP_GT:         Int5  := "01111";
  constant OP_LTEU:       Int5  := "10000";
  constant OP_LTE:        Int5  := "10001";
  constant OP_GTEU:       Int5  := "10010";
  constant OP_GTE:        Int5  := "10011";
  constant OP_INVALID:    Int5  := "11111";
  
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package Common is
  type RwType is (R, W);
  type LenType is (Lword, Lhalf, Lbyte);

  subtype Int32 is std_logic_vector(31 downto 0);
  subtype Int31 is std_logic_vector(30 downto 0);
  subtype Int16 is std_logic_vector(15 downto 0);
  subtype Int8  is std_logic_vector(7  downto 0);
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
  
  constant BF00          : Int16 := "1011111100000000";
  constant BF01          : Int16 := "1011111100000001";
  
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

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RegisterFile is
  port (
    -- Interface --
    clk:          in      std_logic;
    rst:          in      std_logic;
    rdReg1:       in      std_logic_vector (4 downto 0);
    rdReg2:       in      std_logic_vector (4 downto 0);
    wrReg:        in      std_logic_vector (4 downto 0);
    wrData:       in      std_logic_vector (31 downto 0);
    rdData1:      out     std_logic_vector (31 downto 0);
    rdData2:      out     std_logic_vector (31 downto 0)
  );
end RegisterFile; 

architecture Behavioral of RegisterFile is
  
begin

end Behavioral;

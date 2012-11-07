library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
  port (
    -- Interface --
    clk:          in      std_logic;
    rst:          in      std_logic;
    rw:           in      std_logic;
    addr:         in      std_logic_vector (31 downto 0);
    data:         inout   std_logic_vector (31 downto 0);
    
    -- Hardware --
    data1:        inout   std_logic_vector (15 downto 0);
    addr1:        out     std_logic_vector (17 downto 0);
    oe1:          out     std_logic;
    we1:          out     std_logic;
    en1:          out     std_logic;
    data2:        inout   std_logic_vector (15 downto 0);
    addr2:        out     std_logic_vector (17 downto 0);
    oe2:          out     std_logic;
    we2:          out     std_logic;
    en2:          out     std_logic
  );
end Memory; 

architecture Behavioral of Memory is
  
begin

end Behavioral;

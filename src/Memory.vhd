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
    data_1:       inout   std_logic_vector (15 downto 0);
    addr_1:       out     std_logic_vector (17 downto 0);
    oe_1:         out     std_logic;
    we_1:         out     std_logic;
    en_1:         out     std_logic;
    data_2:       inout   std_logic_vector (15 downto 0);
    addr_2:       out     std_logic_vector (17 downto 0);
    oe_2:         out     std_logic;
    we_2:         out     std_logic;
    en_2:         out     std_logic
  );
end Memory; 

architecture Behavioral of Memory is
  
begin

end Behavioral;

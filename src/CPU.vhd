library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.Common.all;

entity CPU is
  port (
    clk:              in      std_logic;
    rst:              in      std_logic;
    debug:            out     line;
    
    -- RAM
    ram_rw:           in      RwType;
    ram_length:       in      LenType;
    ram_addr:         in      std_logic_vector (31 downto 0);
    ram_data_in:      in      std_logic_vector (31 downto 0);
    ram_data_out:     out     std_logic_vector (31 downto 0)   
  );
end CPU;

architecture Behavioral of CPU is

begin
  
end Behavioral;

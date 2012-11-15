library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;
use work.Common.all;

entity CPU is
  port (
    clk   : in std_logic;
    rst   : in std_logic;

    -- RAM
    ram_rw       : out RwType;
    ram_length   : out LenType;
    ram_addr     : out std_logic_vector (31 downto 0) := Int32_Zero;
    ram_data_in  : out std_logic_vector (31 downto 0);
    ram_data_out : in  std_logic_vector (31 downto 0)
    );
end CPU;

architecture Behavioral of CPU is

begin


  process (clk, rst)
    variable L : line;
  begin
    if rst = '0' then
      --reset
      write(L, string'("booting"));
      writeline(output, L);
    elsif rising_edge(clk) then
      write(L, string'("tick"));
      writeline(output, L);
    end if;
  end process;
  
end Behavioral;

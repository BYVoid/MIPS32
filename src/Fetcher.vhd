library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Fetcher is
  port (
    -- Interface --
    clk:          in      std_logic;
    rst:          in      std_logic;
    instAddr:     in      std_logic_vector (31 downto 0);
    op:           out     std_logic_vector (5 downto 0);
    rs:           out     std_logic_vector (4 downto 0);
    rt:           out     std_logic_vector (4 downto 0);
    rd:           out     std_logic_vector (4 downto 0);
    shamt:        out     std_logic_vector (4 downto 0);
    func:         out     std_logic_vector (5 downto 0);
    imm:          out     std_logic_vector (15 downto 0);
    instIndex:    out     std_logic_vector (25 downto 0)
  );
end Fetcher; 

architecture Behavioral of Fetcher is
  
begin

end Behavioral;

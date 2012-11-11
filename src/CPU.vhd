library ieee;
use ieee.std_logic_1164.all;

entity CPU is
  port (
    rst:          in      std_logic;
    clk:          in      std_logic;
    switch:       in      std_logic_vector (15 downto 0);
    led:          out     std_logic_vector (15 downto 0);
    seg7_l:       out     std_logic_vector (7 downto 0);
    seg7_r:       out     std_logic_vector (7 downto 0);
  
    -- Bus --
    data1:        inout   std_logic_vector (15 downto 0);
    addr1:        out     std_logic_vector (17 downto 0);
    data2:        inout   std_logic_vector (15 downto 0);
    addr2:        out     std_logic_vector (17 downto 0);
    
    -- RAM Control --
    ram1_oe:      out     std_logic;
    ram1_we:      out     std_logic;
    ram1_en:      out     std_logic;
    ram2_oe:      out     std_logic;
    ram2_we:      out     std_logic;
    ram2_en:      out     std_logic;
    
    -- COM Control --
    com_ready:    in      std_logic;
    com_rdn:      out     std_logic;
    com_wrn:      out     std_logic;
    com_tbre:     in      std_logic;
    com_tsre:     in      std_logic
  );
end CPU;

architecture Behavioral of CPU is

begin

end Behavioral;

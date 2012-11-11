library ieee;
use ieee.std_logic_1164.all;

entity CPU is
  port (
    -- Input --
    clk0:         in      std_logic;
    clk1:         in      std_logic;
    clk_key:      in      std_logic;
    rst:          in      std_logic;
    switch:       in      std_logic_vector (15 downto 0);
    key:          in      std_logic_vector (3 downto 0);
    
    -- Output --
    led:          out     std_logic_vector (15 downto 0);
    seg7_l:       out     std_logic_vector (7 downto 0);
    seg7_r:       out     std_logic_vector (7 downto 0);
    
    -- RAM --
    ram1_oe:      out     std_logic;
    ram1_we:      out     std_logic;
    ram1_en:      out     std_logic;
    ram1_data:    inout   std_logic_vector (15 downto 0);
    ram1_addr:    out     std_logic_vector (17 downto 0);
    ram2_oe:      out     std_logic;
    ram2_we:      out     std_logic;
    ram2_en:      out     std_logic;
    ram2_data:    inout   std_logic_vector (15 downto 0);
    ram2_addr:    out     std_logic_vector (17 downto 0);
    
    -- COM --
    com_ready:    in      std_logic;
    com_rdn:      out     std_logic;
    com_wrn:      out     std_logic;
    com_tbre:     in      std_logic;
    com_tsre:     in      std_logic;
    
    -- Flash --
    flash_data:   inout   std_logic_vector (15 downto 0);
    flash_addr:   out     std_logic_vector (22 downto 0)
  );
end CPU;

architecture Behavioral of CPU is

begin

end Behavioral;

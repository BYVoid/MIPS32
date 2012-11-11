library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

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
    seg7_l:       out     std_logic_vector (6 downto 0);
    seg7_r:       out     std_logic_vector (6 downto 0);
    
    -- RAM --
    ram1_en:      out     std_logic;
    ram1_oe:      out     std_logic;
    ram1_rw:      out     std_logic;
    ram1_data:    inout   std_logic_vector (15 downto 0);
    ram1_addr:    out     std_logic_vector (17 downto 0);
    ram2_en:      out     std_logic;
    ram2_oe:      out     std_logic;
    ram2_rw:      out     std_logic;
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
  component Seg7 is
    port (
      digit:      in    std_logic_vector (3 downto 0);
      led_out:    out   std_logic_vector (6 downto 0)
    );
  end component;
  component Memory is
    port (
      -- Interface --
      clk:          in      std_logic;
      rst:          in      std_logic;
      rw:           in      std_logic;
      length:       in      std_logic_vector (1 downto 0);
      addr:         in      std_logic_vector (31 downto 0);
      data_in:      in      std_logic_vector (31 downto 0);
      data_out:     out     std_logic_vector (31 downto 0);
    
      -- Import --
      ram1_en:      out     std_logic;
      ram1_oe:      out     std_logic;
      ram1_rw:      out     std_logic;
      ram1_data:    inout   std_logic_vector (15 downto 0);
      ram1_addr:    out     std_logic_vector (17 downto 0);
      ram2_en:      out     std_logic;
      ram2_oe:      out     std_logic;
      ram2_rw:      out     std_logic;
      ram2_data:    inout   std_logic_vector (15 downto 0);
      ram2_addr:    out     std_logic_vector (17 downto 0);
      com_ready:    in      std_logic;
      com_rdn:      out     std_logic;
      com_wrn:      out     std_logic;
      com_tbre:     in      std_logic;
      com_tsre:     in      std_logic;
      flash_data:   inout   std_logic_vector (15 downto 0);
      flash_addr:   out     std_logic_vector (22 downto 0);
      
      -- Debug --
      seg7_r_num:   out     std_logic_vector (3 downto 0)
    );
  end component;
  signal rw: std_logic;
  signal data_in: std_logic_vector (31 downto 0);
  signal data_out: std_logic_vector (31 downto 0);
  signal seg7_l_num: std_logic_vector (3 downto 0);
  signal seg7_r_num: std_logic_vector (3 downto 0);
begin
  rw <= '0';
  seg7_l_num <= data_out(3 downto 0);
  data_in <= Int16_Zero & switch;
  led <= Int8_Zero & data_in(7 downto 0);
  
  seg7_left: Seg7 port map(
    digit => seg7_l_num,
    led_out => seg7_l
  );
  seg7_right: Seg7 port map(
    digit => seg7_r_num,
    led_out => seg7_r
  );
  mem: Memory port map(
    clk_key,
    rst,
    rw,
    "00",
    COM_Address,
    data_in,
    data_out,
    ram1_en,
    ram1_oe,
    ram1_rw,
    ram1_data,
    ram1_addr,
    ram2_en,
    ram2_oe,
    ram2_rw,
    ram2_data,
    ram2_addr,
    com_ready,
    com_rdn,
    com_wrn,
    com_tbre,
    com_tsre,
    flash_data,
    flash_addr,
    seg7_r_num
  );
  
  process (key(0))
  begin
    if rising_edge(key(0)) then
    end if;
  end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

entity System_sim is
end System_sim;

architecture Behavioral of System_sim is
  component CPU
    generic (
      debug      : boolean;
      fetch_wait : WaitCycles;
      load_wait  : WaitCycles;
      store_wait : WaitCycles);
    port (
      clk : in std_logic;
      rst : in std_logic;

      -- RAM
      ram_en       : out std_logic;
      ram_rw       : out RwType;
      ram_length   : out LenType;
      ram_addr     : out std_logic_vector (31 downto 0);
      ram_data_in  : out std_logic_vector (31 downto 0);
      ram_data_out : in  std_logic_vector (31 downto 0));
  end component;
  component MemoryVirtual
    generic (
      debug : boolean);
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      en       : in  std_logic;
      rw       : in  RwType;
      length   : in  LenType;
      addr     : in  std_logic_vector (31 downto 0);
      data_in  : in  std_logic_vector (31 downto 0);
      data_out : out std_logic_vector (31 downto 0));
  end component;

  signal clk : std_logic;
  signal rst : std_logic;

  --RAM
  signal ram_en       : std_logic;
  signal ram_rw       : RwType;
  signal ram_length   : LenType;
  signal ram_addr     : std_logic_vector (31 downto 0);
  signal ram_data_in  : std_logic_vector (31 downto 0);
  signal ram_data_out : std_logic_vector (31 downto 0);

  constant clk_period : time := 100 ns;
  
begin

  CPU_1 : CPU
    generic map (
      debug      => true,
      fetch_wait => 1,
      load_wait  => 1,
      store_wait => 1)
    port map (
      clk          => clk,
      rst          => rst,
      ram_en       => ram_en,
      ram_rw       => ram_rw,
      ram_length   => ram_length,
      ram_addr     => ram_addr,
      ram_data_in  => ram_data_in,
      ram_data_out => ram_data_out);

  MemoryVirtual_1 : MemoryVirtual
    generic map (
      debug => true)
    port map (
      clk      => clk,
      rst      => rst,
      en       => ram_en,
      rw       => ram_rw,
      length   => ram_length,
      addr     => ram_addr,
      data_in  => ram_data_in,
      data_out => ram_data_out);

  -- clock generation, print debug messages
  process
  begin
    -- boot up
    rst <= '0', '1' after clk_period;
    clk <= '0';
    wait for 2*clk_period;

    -- tick
    loop
      clk <= '1', '0' after 0.5*clk_period;
      wait for clk_period;
    end loop;
  end process;
  

end Behavioral;

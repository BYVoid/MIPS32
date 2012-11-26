library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

entity System is
  port (
    -- Input --
    clk0    : in std_logic;
    clk1    : in std_logic;
    clk_key : in std_logic;
    rst     : in std_logic;
    switch  : in std_logic_vector (15 downto 0);
    key     : in std_logic_vector (3 downto 0);

    -- Output --
    led    : out std_logic_vector (15 downto 0);
    seg7_l : out std_logic_vector (6 downto 0);
    seg7_r : out std_logic_vector (6 downto 0);

    -- RAM --
    ram1_en   : out   std_logic;
    ram1_oe   : out   std_logic;
    ram1_rw   : out   std_logic;
    ram1_data : inout std_logic_vector (15 downto 0);
    ram1_addr : out   std_logic_vector (17 downto 0);
    ram2_en   : out   std_logic;
    ram2_oe   : out   std_logic;
    ram2_rw   : out   std_logic;
    ram2_data : inout std_logic_vector (15 downto 0);
    ram2_addr : out   std_logic_vector (17 downto 0);

    -- COM --
    com_ready : in  std_logic;
    com_rdn   : out std_logic;
    com_wrn   : out std_logic;
    com_tbre  : in  std_logic;
    com_tsre  : in  std_logic;

    -- Flash --
    flash_byte : out   std_logic;
    flash_vpen : out   std_logic;
    flash_ce   : out   std_logic;
    flash_oe   : out   std_logic;
    flash_we   : out   std_logic;
    flash_rp   : out   std_logic;
    flash_data : inout std_logic_vector (15 downto 0);
    flash_addr : out   std_logic_vector (22 downto 0)
    );
end System;

architecture Behavioral of System is
  component CPU
    generic (
      debug      : boolean;
      start_addr : std_logic_vector (31 downto 0);
      fetch_wait : WaitCycles;
      load_wait  : WaitCycles;
      store_wait : WaitCycles);
    port (
      clk : in std_logic;
      rst : in std_logic;

      -- RAM
      mem_en       : out std_logic;
      mem_rw       : out RwType;
      mem_length   : out LenType;
      mem_addr     : out std_logic_vector (31 downto 0);
      mem_data_in  : out std_logic_vector (31 downto 0);
      mem_data_out : in  std_logic_vector (31 downto 0)
    );
  end component;
  component Memory is
    port (
      -- Interface --
      clk      : in  std_logic;
      rst      : in  std_logic;
      en       : in  std_logic;
      rw       : in  RwType;
      length   : in  LenType;
      addr     : in  std_logic_vector (31 downto 0);
      data_in  : in  std_logic_vector (31 downto 0);
      data_out : out std_logic_vector (31 downto 0);

      -- Import --
      ram1_en    : out   std_logic;
      ram1_oe    : out   std_logic;
      ram1_rw    : out   std_logic;
      ram1_data  : inout std_logic_vector (15 downto 0);
      ram1_addr  : out   std_logic_vector (17 downto 0);
      ram2_en    : out   std_logic;
      ram2_oe    : out   std_logic;
      ram2_rw    : out   std_logic;
      ram2_data  : inout std_logic_vector (15 downto 0);
      ram2_addr  : out   std_logic_vector (17 downto 0);
      com_ready  : in    std_logic;
      com_rdn    : out   std_logic;
      com_wrn    : out   std_logic;
      com_tbre   : in    std_logic;
      com_tsre   : in    std_logic;
      flash_byte : out   std_logic;
      flash_vpen : out   std_logic;
      flash_ce   : out   std_logic;
      flash_oe   : out   std_logic;
      flash_we   : out   std_logic;
      flash_rp   : out   std_logic;
      flash_data : inout std_logic_vector (15 downto 0);
      flash_addr : out   std_logic_vector (22 downto 0);

      -- Debug --
      seg7_r_num : out std_logic_vector (3 downto 0)
    );
  end component;
  component Seg7 is
    port (
      digit   : in  std_logic_vector (3 downto 0);
      led_out : out std_logic_vector (6 downto 0)
    );
  end component;

  signal mem_en       : std_logic;
  signal mem_rw       : RwType;
  signal mem_length   : LenType;
  signal mem_addr     : Int32;
  signal mem_data_in  : Int32;
  signal mem_data_out : Int32;

  signal seg7_l_num : Int4;
  signal seg7_r_num : Int4;

begin
  led <= mem_data_out(15 downto 0);
  seg7_l_num <= mem_data_in(3 downto 0);

  Seg7_1 : Seg7
    port map (
      digit   => seg7_l_num,
      led_out => seg7_l
    );

  Seg7_2 : Seg7
    port map (
      digit   => seg7_r_num,
      led_out => seg7_r
    );

  CPU_1 : CPU
    generic map (
      debug      => false,
      start_addr => x"00000000",
      fetch_wait => 4,
      load_wait  => 4,
      store_wait => 4)
    port map (
      clk          => clk0,
      rst          => rst,
      mem_en       => mem_en,
      mem_rw       => mem_rw,
      mem_length   => mem_length,
      mem_addr     => mem_addr,
      mem_data_in  => mem_data_in,
      mem_data_out => mem_data_out
    );

  Memory_1 : Memory
    port map (
      clk        => clk_key,
      rst        => rst,
      en         => mem_en,
      rw         => mem_rw,
      length     => mem_length,
      addr       => mem_addr,
      data_in    => mem_data_in,
      data_out   => mem_data_out,
      ram1_en    => ram1_en,
      ram1_oe    => ram1_oe,
      ram1_rw    => ram1_rw,
      ram1_data  => ram1_data,
      ram1_addr  => ram1_addr,
      ram2_en    => ram2_en,
      ram2_oe    => ram2_oe,
      ram2_rw    => ram2_rw,
      ram2_data  => ram2_data,
      ram2_addr  => ram2_addr,
      com_ready  => com_ready,
      com_rdn    => com_rdn,
      com_wrn    => com_wrn,
      com_tbre   => com_tbre,
      com_tsre   => com_tsre,
      flash_byte => flash_byte,
      flash_vpen => flash_vpen,
      flash_ce   => flash_ce,
      flash_oe   => flash_oe,
      flash_we   => flash_we,
      flash_rp   => flash_rp,
      flash_data => flash_data,
      flash_addr => flash_addr,
      seg7_r_num => seg7_r_num
    );

end Behavioral;

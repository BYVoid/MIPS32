library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

entity System is
end System;

architecture Behavioral of System is
  component CPU
    port (
      clk   : in  std_logic;
      rst   : in  std_logic;
      debug : out line;

      -- RAM
      ram_rw       : in  RwType;
      ram_length   : in  LenType;
      ram_addr     : in  std_logic_vector (31 downto 0);
      ram_data_in  : in  std_logic_vector (31 downto 0);
      ram_data_out : out std_logic_vector (31 downto 0));
  end component;
  component MemoryVirtual
    port (
      clk      : in  std_logic;
      rst      : in  std_logic;
      rw       : in  RwType;
      length   : in  LenType;
      addr     : in  std_logic_vector (31 downto 0);
      data_in  : in  std_logic_vector (31 downto 0);
      data_out : out std_logic_vector (31 downto 0));
  end component;

  signal clk, rst : std_logic;
  signal debug    : line;
  --RAM
  signal ram_rw           : RwType;
  signal ram_length       : LenType;
  signal ram_addr         : std_logic_vector (31 downto 0);
  signal ram_data_in      : std_logic_vector (31 downto 0);
  signal ram_data_out     : std_logic_vector (31 downto 0);
  
begin

  

end Behavioral;

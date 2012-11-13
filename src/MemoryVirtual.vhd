library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity MemoryVirtual is
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
    flash_addr:   out     std_logic_vector (22 downto 0)
  );
end MemoryVirtual;

architecture Behavioral of MemoryVirtual is
  constant NUM_CELLS: integer := 256;
  type VirtualMemoryType is array(0 to NUM_CELLS - 1) of Int32;
  signal memories: VirtualMemoryType;
begin
  process(clk, rst)
  begin
    if rst = '0' then
      -- Reset
    elsif rising_edge(clk) then
      if rw = '0' then
        -- Read ram
        data_out <= memories(to_integer(unsigned(addr)));
      else
        -- Write ram
        memories(to_integer(unsigned(addr))) <= data_in;
      end if;
    end if;
  end process;
end Behavioral;

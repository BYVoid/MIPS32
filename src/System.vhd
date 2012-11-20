library ieee;
use ieee.std_logic_1164.all;
use work.Common.all;

entity System is
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
    flash_byte:   out     std_logic;
    flash_vpen:   out     std_logic;
    flash_ce:     out     std_logic;
    flash_oe:     out     std_logic;
    flash_we:     out     std_logic;
    flash_rp:     out     std_logic;
    flash_data:   inout   std_logic_vector (15 downto 0);
    flash_addr:   out     std_logic_vector (22 downto 0)
    );
end System;

architecture Behavioral of System is
  component CPU
    port (
      clk          : in  std_logic;
      rst          : in  std_logic;

      -- RAM
      ram_rw       : out RwType;
      ram_length   : out LenType;
      ram_addr     : out std_logic_vector (31 downto 0);
      ram_data_in  : out std_logic_vector (31 downto 0);
      ram_data_out : in  std_logic_vector (31 downto 0));
  end component;
  component Memory is
    port (
      -- Interface --
      clk:          in      std_logic;
      rst:          in      std_logic;
      rw:           in      RwType;
      length:       in      LenType;
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
      flash_byte:   out     std_logic;
      flash_vpen:   out     std_logic;
      flash_ce:     out     std_logic;
      flash_oe:     out     std_logic;
      flash_we:     out     std_logic;
      flash_rp:     out     std_logic;
      flash_data:   inout   std_logic_vector (15 downto 0);
      flash_addr:   out     std_logic_vector (22 downto 0);
      
      -- Debug --
      seg7_r_num:   out     std_logic_vector (3 downto 0)
      );
  end component;
  component Seg7 is
    port (
      digit:      in    std_logic_vector (3 downto 0);
      led_out:    out   std_logic_vector (6 downto 0)
      );
  end component;
begin
  
  
end Behavioral;

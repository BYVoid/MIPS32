library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity Memory is
  port (
    -- Interface --
    clk:          in      std_logic;
    rst:          in      std_logic;
    rw:           in      RwType;
    length:       in      LenType;
    addr:         in      Int32;
    data_in:      in      Int32;
    data_out:     out     Int32;
    
    -- Import --
    ram1_en:      out     std_logic;
    ram1_oe:      out     std_logic;
    ram1_rw:      out     std_logic;
    ram1_data:    inout   Int16;
    ram1_addr:    out     Int18;
    ram2_en:      out     std_logic;
    ram2_oe:      out     std_logic;
    ram2_rw:      out     std_logic;
    ram2_data:    inout   Int16;
    ram2_addr:    out     Int18;
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
    flash_data:   inout   Int16;
    flash_addr:   out     Int23;
    
    -- Debug --
    seg7_r_num:   out     Int4
    );
end Memory;

architecture Behavioral of Memory is
  component Rom
    port (
      clka: in std_logic;
      addra: in Int10;
      douta: out Int32
    );
  end component;

  type StateType is (
    INITIAL,
    ROM_READ,
    RAM_READ_1,
    RAM_WRITE_1,
    RAM_WRITE_BYTE_1,
    RAM_WRITE_BYTE_2,
    COM_READ_1,
    COM_READ_2,
    COM_WRITE_1,
    COM_WRITE_2,
    FLASH_READ_1,
    FLASH_WRITE_1
  );

procedure rom_read(
  signal addr: in Int32;
  signal data_out: out Int32;
  signal rom_addr: out Int10;
  signal rom_data: in Int32;
  signal state: inout StateType) is
begin
  case state is
    when INITIAL =>
      rom_addr <= addr(11 downto 2);
      state <= ROM_READ;
    when ROM_READ =>
      data_out <= rom_data;
      state <= INITIAL;
    when others =>
  end case;
end;

procedure ram_read(
  signal length: in LenType;
  signal addr: in Int32;
  signal data_out: out Int32;
  signal ram1_en: out std_logic;
  signal ram1_oe: out std_logic;
  signal ram1_rw: out std_logic;
  signal ram1_data: inout Int16;
  signal ram1_addr: out Int18;
  signal ram2_en: out std_logic;
  signal ram2_oe: out std_logic;
  signal ram2_rw: out std_logic;
  signal ram2_data: inout Int16;
  signal ram2_addr: out Int18;
  signal state: inout StateType) is
begin
  case state is
    when INITIAL =>
      ram1_en <= '0';
      ram2_en <= '0';
      ram1_oe <= '0';
      ram2_oe <= '0';
      ram1_rw <= '1';
      ram2_rw <= '1';
      ram1_addr <= addr(19 downto 2);
      ram2_addr <= addr(19 downto 2);
      ram1_data <= Int16_Z;
      ram2_data <= Int16_Z;
      state <= RAM_READ_1;
    when RAM_READ_1 =>
      if length = Lword then
        data_out(15 downto 0) <= ram1_data;
        data_out(31 downto 16) <= ram2_data;
      elsif length = Lhalf then
        data_out(31 downto 16) <= Int16_Zero;
        if addr(1) = '0' then
          data_out(15 downto 0) <= ram1_data;
        else
          data_out(15 downto 0) <= ram2_data;
        end if;
      elsif length = Lbyte then
        data_out(31 downto 8) <= Int16_Zero & Int8_Zero;
        if addr(1) = '0' then
          if addr(0) = '0' then
            data_out(7 downto 0) <= ram1_data(7 downto 0);
          else
            data_out(7 downto 0) <= ram1_data(15 downto 8);
          end if;
        else
          if addr(0) = '0' then
            data_out(7 downto 0) <= ram2_data(7 downto 0);
          else
            data_out(7 downto 0) <= ram2_data(15 downto 8);
          end if;
        end if;
      end if;
      state <= INITIAL;
    when others =>
  end case;
end;
  
procedure ram_write(
  signal length: in LenType;
  signal addr: in Int32;
  signal data_in: in Int32;
  signal ram1_en: out std_logic;
  signal ram1_oe: out std_logic;
  signal ram1_rw: out std_logic;
  signal ram1_data: inout Int16;
  signal ram1_addr: out Int18;
  signal ram2_en: out std_logic;
  signal ram2_oe: out std_logic;
  signal ram2_rw: out std_logic;
  signal ram2_data: inout Int16;
  signal ram2_addr: out Int18;
  signal data_byte_temp: inout Int16;
  signal state: inout StateType) is
begin
  case state is
    when INITIAL =>
      ram1_en <= '0';
      ram2_en <= '0';
      ram1_addr <= addr(19 downto 2);
      ram2_addr <= addr(19 downto 2);
      -- Write ram
      if length = Lword then
        ram1_oe <= '1';
        ram2_oe <= '1';
        ram1_rw <= '0';
        ram2_rw <= '0';
        ram1_data <= data_in(15 downto 0);
        ram2_data <= data_in(31 downto 16);
        state <= RAM_WRITE_1;
      elsif length = Lhalf then
        if addr(1) = '0' then
          ram1_oe <= '1';
          ram1_rw <= '0';
          ram1_data <= data_in(15 downto 0);
        else
          ram2_oe <= '1';
          ram2_rw <= '0';
          ram2_data <= data_in(15 downto 0);
        end if;
        state <= RAM_WRITE_1;
      elsif length = Lbyte then
        ram1_oe <= '0';
        ram2_oe <= '0';
        ram1_rw <= '1';
        ram2_rw <= '1';
        ram1_data <= Int16_Z;
        ram2_data <= Int16_Z;
        state <= RAM_WRITE_BYTE_1;
      end if;
    when RAM_WRITE_1 =>
      ram1_rw <= '1';
      ram2_rw <= '1';
      state <= INITIAL;
    when RAM_WRITE_BYTE_1 =>
      if addr(1) = '0' then
        data_byte_temp <= ram1_data;
      else
        data_byte_temp <= ram2_data;
      end if;
      state <= RAM_WRITE_BYTE_2;
    when RAM_WRITE_BYTE_2 =>
      if addr(1) = '0' then
        ram1_oe <= '1';
        ram1_rw <= '0';
        if addr(0) = '0' then
          ram1_data(7 downto 0) <= data_in(7 downto 0);
          ram1_data(15 downto 8) <= data_byte_temp(15 downto 8);
        else
          ram1_data(7 downto 0) <= data_byte_temp(7 downto 0);
          ram1_data(15 downto 8) <= data_in(7 downto 0);
        end if;
      else
        ram2_oe <= '1';
        ram2_rw <= '0';
        if addr(0) = '0' then
          ram2_data(7 downto 0) <= data_in(7 downto 0);
          ram2_data(15 downto 8) <= data_byte_temp(15 downto 8);
        else
          ram2_data(7 downto 0) <= data_byte_temp(7 downto 0);
          ram2_data(15 downto 8) <= data_in(7 downto 0);
        end if;
      end if;
      state <= RAM_WRITE_1;
    when others =>
  end case;
end;

procedure com_status(
  signal com_ready: in std_logic;
  signal com_tbre: in std_logic;
  signal com_tsre: in std_logic;
  signal data_out: out Int32;
  signal state: inout StateType) is
begin
  case state is
    when INITIAL =>
      data_out(0) <= com_ready;
      data_out(1) <= com_tbre and com_tsre;
      data_out(31 downto 2) <= Int30_Zero;
      state <= INITIAL;
    when others =>
  end case;
end;

procedure com_read(
  signal com_ready: in std_logic;
  signal com_rdn: out std_logic;
  signal ram1_en: out std_logic;
  signal ram2_en: out std_logic;
  signal com_data: inout Int8;
  signal data_out: out Int32;
  signal state: inout StateType) is
begin
  case state is
    when INITIAL =>
      ram1_en <= '1';
      ram2_en <= '1';
      if com_ready = '1' then
        com_rdn <= '0';
        state <= COM_READ_1;
      end if;
    when COM_READ_1 =>
      com_data <= Int8_Z;
      state <= COM_READ_2;
    when COM_READ_2 =>
      com_rdn <= '1';
      data_out(7 downto 0) <= com_data;
      data_out(31 downto 8) <= Int16_Zero & Int8_Zero;
      state <= INITIAL;
    when others =>
  end case;
end;

procedure com_write(
  signal com_tbre: in std_logic;
  signal com_tsre: in std_logic;
  signal data_in: in Int32;
  signal com_wrn: out std_logic;
  signal ram1_en: out std_logic;
  signal ram2_en: out std_logic;
  signal com_data: inout Int8;
  signal state: inout StateType) is
begin
  case state is
    when INITIAL =>
      ram1_en <= '1';
      ram2_en <= '1';
      com_data <= data_in(7 downto 0);
      state <= COM_WRITE_1;
    when COM_WRITE_1 =>
      com_wrn <= '0';
      if com_tbre = '1' and com_tsre = '1' then
        state <= COM_WRITE_2;
      end if;
    when COM_WRITE_2 =>
      com_wrn <= '1';
      state <= INITIAL;
    when others =>
  end case;
end;

procedure flash_read(
  signal addr: in Int32;
  signal data_out: out Int32;
  signal flash_oe: out std_logic;
  signal flash_we: out std_logic;
  signal flash_data: inout Int16;
  signal flash_addr: out Int23;
  signal state: inout StateType) is
begin
  case state is
    when INITIAL =>
      flash_oe <= '0';
      flash_we <= '1';
      flash_addr <= addr(24 downto 2);
      flash_data <= Int16_Z;
      state <= FLASH_READ_1;
    when FLASH_READ_1 =>
      data_out(15 downto 0) <= flash_data;
      data_out(31 downto 16) <= Int16_Zero;
      state <= INITIAL;
    when others =>
  end case;
end;

procedure flash_write(
  signal addr: in Int32;
  signal data_in: in Int32;
  signal flash_oe: out std_logic;
  signal flash_we: out std_logic;
  signal flash_data: inout Int16;
  signal flash_addr: out Int23;
  signal state: inout StateType) is
begin
  case state is
    when INITIAL =>
      flash_oe <= '1';
      flash_we <= '0';
      flash_addr <= addr(24 downto 2);
      flash_data <= data_in(15 downto 0);
      state <= FLASH_WRITE_1;
    when FLASH_WRITE_1 =>
      flash_we <= '1';
      state <= INITIAL;
    when others =>
  end case;
end;
  
signal state: StateType;
signal data_byte_temp: Int16;
signal rom_addr: Int10;
signal rom_data: Int32;
  
begin
  flash_byte <= '1';
  flash_vpen <= '1';
  flash_ce <= '0';
  flash_rp <= '1';
  
  rom_instance: Rom port map (
    clka => clk,
    addra => rom_addr,
    douta => rom_data
  );
  
  process(clk, rst)
  begin
    if rst = '0' then
      -- Reset
      ram1_en <= '1';
      ram2_en <= '1';
      ram1_oe <= '1';
      ram2_oe <= '1';
      ram1_rw <= '1';
      ram2_rw <= '1';
      com_rdn <= '1';
      com_wrn <= '1';
      state <= INITIAL;
    elsif rising_edge(clk) then
      if state = INITIAL then
        seg7_r_num <= std_logic_vector(to_signed(0, 4)); -- Debug --
        if addr(31 downto 20) = x"000" then
          --- SRAM ---
          if rw = R then
            ram_read(length, addr, data_out, ram1_en, ram1_oe, ram1_rw, ram1_data, ram1_addr,
              ram2_en, ram2_oe, ram2_rw, ram2_data, ram2_addr, state);
          else
            ram_write(length, addr, data_in, ram1_en, ram1_oe, ram1_rw, ram1_data, ram1_addr,
              ram2_en, ram2_oe, ram2_rw, ram2_data, ram2_addr, data_byte_temp, state);
          end if;
        elsif addr(31 downto 12) = x"1FC00" then
          if rw = R then
            rom_read(addr, data_out, rom_addr, rom_data, state);
          end if;
        elsif addr = COM_Data_Addr then
          -- COM --
          if rw = R then
            com_read(com_ready, com_rdn, ram1_en, ram2_en, ram1_data(7 downto 0), data_out, state);
          else
            com_write(com_tbre, com_tsre, data_in, com_wrn, ram1_en, ram2_en, ram1_data(7 downto 0), state);
          end if;
        elsif addr = COM_Stat_Addr then
          -- COM Status --
          if rw = R then
            com_status(com_ready, com_tbre, com_tsre, data_out, state);
          end if;
        elsif addr(31 downto 24) = x"1E" then
          --- Flash ---
          if rw = R then
            flash_read(addr, data_out, flash_oe, flash_we, flash_data, flash_addr, state);
          else
            flash_write(addr, data_in, flash_oe, flash_we, flash_data, flash_addr, state);
          end if;
        end if;
      else
        ram_read(length, addr, data_out, ram1_en, ram1_oe, ram1_rw, ram1_data, ram1_addr,
          ram2_en, ram2_oe, ram2_rw, ram2_data, ram2_addr, state);
        ram_write(length, addr, data_in, ram1_en, ram1_oe, ram1_rw, ram1_data, ram1_addr,
          ram2_en, ram2_oe, ram2_rw, ram2_data, ram2_addr, data_byte_temp, state);
        rom_read(addr, data_out, rom_addr, rom_data, state);
        com_read(com_ready, com_rdn, ram1_en, ram2_en, ram1_data(7 downto 0), data_out, state);
        com_write(com_tbre, com_tsre, data_in, com_wrn, ram1_en, ram2_en, ram1_data(7 downto 0), state);
        flash_read(addr, data_out, flash_oe, flash_we, flash_data, flash_addr, state);
        flash_write(addr, data_in, flash_oe, flash_we, flash_data, flash_addr, state);
      end if;
    end if;
  end process;
end Behavioral;

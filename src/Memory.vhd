library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Memory is
  port (
    -- Interface --
    clk:          in      std_logic;
    rst:          in      std_logic;
    rw:           in      std_logic;
    addr:         in      std_logic_vector (31 downto 0);
    data:         inout   std_logic_vector (31 downto 0);
    
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
end Memory;

architecture Behavioral of Memory is
  component Com is
    port (
      -- Interface --
      clk:          in      std_logic;
      rst:          in      std_logic;
      rw:           in      std_logic;
      data:         inout   std_logic_vector (7 downto 0);
      ready:        inout   std_logic;
      -- Import --
      com_data:     inout   std_logic_vector (7 downto 0);
      com_ready:    in      std_logic;
      com_rdn:      out     std_logic;
      com_wrn:      out     std_logic;
      com_tbre:     in      std_logic;
      com_tsre:     in      std_logic
    );
  end component;

  type StateType is (
    INITIAL,
    RAM_READ_COMPLETE,
    RAM_WRITTING,
    RAM_WRITE_COMPLETE,
    COM_READING_BYTE1,
    COM_READING_BYTE2,
    COM_READING_BYTE3,
    COM_READING_BYTE4,
    COM_WRITING_BYTE1,
    COM_WRITING_BYTE2,
    COM_WRITING_BYTE3,
    COM_WRITING_BYTE4
  );
  
  signal state, next_state: StateType;
  signal com_data: std_logic_vector (7 downto 0);
  signal ready: std_logic;
begin
  com_instance: com port map(
    clk => clk,
    rst => rst,
    rw => rw,
    data => com_data,
    ready => ready,
    com_data => ram1_data(7 downto 0),
    com_ready => com_ready,
    com_rdn => com_rdn,
    com_wrn => com_wrn,
    com_tbre => com_tbre,
    com_tsre => com_tsre
  );
  
  process(clk, rst)
  begin
    if rst = '0' then
      -- Reset
      state <= INITIAL;
    elsif rising_edge(clk) then
      state <= next_state;
    end if;
  end process;
  
  process(state)
	  variable actual_addr: std_logic_vector (31 downto 0);
  begin
    case state is
      when INITIAL =>
        if addr(31 downto 20) = x"000" then
          -- RAM
          ram1_addr <= addr(17 downto 0);
          ram1_en <= '0';
          ram2_addr <= addr(17 downto 0);
          ram2_en <= '0';
          if rw = '0' then
            -- Read ram
            ram1_oe <= '0';
            ram1_rw <= '1';
            ram1_data <= "ZZZZZZZZZZZZZZZZ";
            ram2_oe <= '0';
            ram2_rw <= '1';
            ram2_data <= "ZZZZZZZZZZZZZZZZ";
            next_state <= RAM_READ_COMPLETE;
          else
            -- Write ram
            ram1_oe <= '1';
            ram1_rw <= '0';
            ram1_data <= data(31 downto 16);
            ram2_oe <= '1';
            ram2_rw <= '0';
            ram2_data <= data(15 downto 0);
            next_state <= RAM_WRITTING;
          end if;
        elsif addr = x"1FD003F8" then
          -- COM
          ready <= '0';
          if rw = '0' then
            next_state <= COM_READING_BYTE1;
          else
            com_data <= data(31 downto 24);
            next_state <= COM_WRITING_BYTE1;
          end if;
        else
          next_state <= INITIAL;
        end if;
      when RAM_READ_COMPLETE =>
        data(31 downto 16) <= ram1_data;
        data(15 downto 0) <= ram2_data;
        ram1_en <= '1';
        ram2_en <= '1';
        next_state <= INITIAL;
      when RAM_WRITTING =>
        ram1_rw <= '1';
        ram2_rw <= '1';
        next_state <= RAM_WRITE_COMPLETE;
      when RAM_WRITE_COMPLETE =>
        ram1_en <= '1';
        ram2_en <= '1';
        next_state <= INITIAL;
      when COM_READING_BYTE1 =>
        if ready = '1' then
          data(31 downto 24) <= com_data;
          ready <= '0';
          next_state <= COM_READING_BYTE2;
        end if;
      when COM_READING_BYTE2 =>
        if ready = '1' then
          data(23 downto 16) <= com_data;
          ready <= '0';
          next_state <= COM_READING_BYTE3;
        end if;
      when COM_READING_BYTE3 =>
        if ready = '1' then
          data(15 downto 8) <= com_data;
          ready <= '0';
          next_state <= COM_READING_BYTE4;
        end if;
      when COM_READING_BYTE4 =>
        if ready = '1' then
          data(7 downto 0) <= com_data;
          next_state <= INITIAL;
        end if;
      when COM_WRITING_BYTE1 =>
        if ready = '1' then
          ready <= '0';
          com_data <= data(23 downto 16);
          next_state <= COM_WRITING_BYTE2;
        end if;
      when COM_WRITING_BYTE2 =>
        if ready = '1' then
          ready <= '0';
          com_data <= data(15 downto 8);
          next_state <= COM_WRITING_BYTE3;
        end if;
      when COM_WRITING_BYTE3 =>
        if ready = '1' then
          ready <= '0';
          com_data <= data(7 downto 0);
          next_state <= COM_WRITING_BYTE4;
        end if;
      when COM_WRITING_BYTE4 =>
        if ready = '1' then
          next_state <= INITIAL;
        end if;
    end case;
  end process;

end Behavioral;

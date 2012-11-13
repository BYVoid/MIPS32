library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity Memory is
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
end Memory;

architecture VirtualBehav of Memory is
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
end VirtualBehav;

architecture Behavioral of Memory is
  type StateType is (
    INITIAL,
    RAM_READ_1,
    RAM_READ_2,
    RAM_WRITE_1,
    RAM_WRITE_2,
    RAM_WRITE_3,
    COM_READING,
    COM_READ_COMPLETED,
    COM_WRITING,
    COM_WRITE_COMPLETED
    );
  
  signal state: StateType;
  signal ready: std_logic;
begin
  process(clk, rst)
    variable actual_addr: std_logic_vector (31 downto 0);
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
      case state is
        when INITIAL =>
          seg7_r_num <= "0000"; -- Debug --
          if addr(31 downto 20) = x"000" then
            -- RAM
            ram1_en <= '0';
            ram2_en <= '0';
            if rw = '0' then
              -- Read ram
              ram1_oe <= '0';
              ram2_oe <= '0';
              ram1_rw <= '1';
              ram2_rw <= '1';
              ram1_data <= Int16_Z;
              ram2_data <= Int16_Z;
              state <= RAM_READ_1;
            else
              -- Write ram
              ram1_addr <= addr(19 downto 2);
              ram2_addr <= addr(19 downto 2);
              ram1_data <= data_in(15 downto 0);
              ram2_data <= data_in(31 downto 16);
              state <= RAM_WRITE_1;
            end if;
          elsif addr = COM_Address then
            -- COM --
            -- Disable Ram to avoid bus confilict --
            ram1_en <= '1';
            ram2_en <= '1';
            if rw = '0' then
              if com_ready = '1' then
                com_rdn <= '0';
                state <= COM_READING;
              end if;
            else
              ram1_data(7 downto 0) <= data_in(7 downto 0);
              state <= COM_WRITING;
            end if;
          else
            state <= INITIAL;
          end if;
        when RAM_READ_1 =>
          seg7_r_num <= "0001"; -- Debug --
          ram1_addr <= addr(19 downto 2);
          ram2_addr <= addr(19 downto 2);
          state <= RAM_READ_2;
        when RAM_READ_2 =>
          data_out(31 downto 16) <= ram1_data;
          data_out(15 downto 0) <= ram2_data;
          ram1_en <= '1';
          ram2_en <= '1';
          state <= INITIAL;
        when RAM_WRITE_1 =>
          seg7_r_num <= "0010"; -- Debug --
          ram1_oe <= '1';
          ram2_oe <= '1';
          ram1_rw <= '0';
          ram2_rw <= '0';
          state <= RAM_WRITE_2;
        when RAM_WRITE_2 =>
          ram1_rw <= '1';
          ram2_rw <= '1';
          state <= RAM_WRITE_3;
        when RAM_WRITE_3 =>
          seg7_r_num <= "0011"; -- Debug --
          ram1_en <= '1';
          ram2_en <= '1';
          state <= INITIAL;
        when COM_READING =>
          seg7_r_num <= "0100"; -- Debug --
          ram1_data(7 downto 0) <= Int8_Z;
          state <= COM_READ_COMPLETED;
        when COM_READ_COMPLETED =>
          seg7_r_num <= "0101"; -- Debug --
          com_rdn <= '1';
          data_out(7 downto 0) <= ram1_data(7 downto 0);
          ready <= '1';
          state <= INITIAL;
        when COM_WRITING =>
          seg7_r_num <= "0110"; -- Debug --
          com_wrn <= '0';
          if com_tbre = '1' and com_tsre = '1' then
            state <= COM_WRITE_COMPLETED;
          end if;
        when COM_WRITE_COMPLETED =>
          seg7_r_num <= "0111"; -- Debug --
          com_wrn <= '1';
          ready <= '1';
          state <= INITIAL;
      end case;
    end if;
  end process;
end Behavioral;

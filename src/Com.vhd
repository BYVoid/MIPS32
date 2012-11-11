library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity Com is
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
end Com;

architecture Behavioral of Com is
  type StateType is (
    INITIAL,
    READING,
    READ_COMPLETED,
    WRITTING,
    WRITE_COMPLETED
  );
  
  signal state: StateType;
begin
  process(clk, rst)
  begin
    if rst = '0' then
      -- Reset
      state <= INITIAL;
    elsif rising_edge(clk) then
      case state is
        when INITIAL =>
          if ready = '0' then
            if rw = '0' then
              -- Read from COM
              com_wrn <= '1';
              state <= READING;
            else
              -- Write to COM
              com_wrn <= '0';
              com_data <= data;
              state <= WRITTING;
            end if;
          end if;
        when READING =>
          if com_ready = '1' then
            com_rdn <= '0';
            state <= READ_COMPLETED;
          else
            com_rdn <= '1';
          end if;
        when READ_COMPLETED =>
          com_rdn <= '1';
          com_data <= "ZZZZZZZZ";
          data <= com_data;
          ready <= '1';
          state <= INITIAL;
        when WRITTING =>
	      com_wrn <= '1';
          com_data <= "ZZZZZZZZ";
          if com_tbre = '1' and com_tsre = '1' then
            state <= WRITE_COMPLETED;
          end if;
        when WRITE_COMPLETED =>
          ready <= '1';
          state <= INITIAL;
      end case;
    end if;
  end process;
end Behavioral;

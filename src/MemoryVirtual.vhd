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
    length:       in      unsigned (1 downto 0); -- define a custom type
    addr:         in      unsigned (31 downto 0);
    data_in:      in      unsigned (31 downto 0);
    data_out:     out     unsigned (31 downto 0);
    );
end MemoryVirtual;

architecture Behavioral of MemoryVirtual is
begin

  process(clk, rst)

    constant NUM_CELLS: integer := 1024;
    type VirtualMemoryType is array(0 to NUM_CELLS - 1) of unsigned (7 downto 0);

    variable mem: VirtualMemoryType;
    variable addr_int: integer;

    procedure load(mem: out VirtualMemoryType) is
      file mem_file: text open read_mode is "memory.dat";
      variable buf: line;
      variable addr_var, data_var, i: integer;
      variable word: unsigned (31 downto 0);
    begin
      while not endfile(mem_file) loop
        readline(mem_file, buf);
        addr_var := 0;
        for i in 1 to 8 loop
          if ('0' <= buf(i) and buf(i) <= '9') then
            addr_var := addr_var*16
                        + character'pos(buf(i)) - character'pos('0');
          else
            addr_var := addr_var*16
                        + character'pos(buf(i)) - character'pos('a') + 10;
          end if;
        end loop;
        data_var := 0;
        for i in 10 to 17 loop
          if ('0' <= buf(i) and buf(i) <= '9') then
            data_var := data_var*16
                        + character'pos(buf(i)) - character'pos('0');
          else
            data_var := data_var*16
                        + character'pos(buf(i)) - character'pos('a') + 10;
          end if;
        end loop;

        write(buf, addr_var);
        write(buf, ' ');
        write(buf, data_var);
        writeline(output, buf);

        word := to_unsigned(data_var, 32);
        mem(addr_var)   := word(7 downto 0); 
        mem(addr_var+1) := word(15 downto 8);
        mem(addr_var+2) := word(23 downto 16);
        mem(addr_var+3) := word(31 downto 24);  
        
      end loop;
    end load;
    
  begin
    if rst = '0' then
      -- Reset
      load(mem);
    elsif rising_edge(clk) then
      addr_int := to_integer(addr);
      if rw = '0' then
        -- Read ram
        case length is
          when "11" =>                  -- word
            data_out(7 downto 0)   <= mem(addr_int);
            data_out(15 downto 8)  <= mem(addr_int+1);
            data_out(23 downto 16) <= mem(addr_int+2);
            data_out(31 downto 24) <= mem(addr_int+3);
          when "01" =>                  -- halfword
            data_out(7 downto 0)   <= mem(addr_int);
            data_out(15 downto 8)  <= mem(addr_int+1);
            data_out(23 downto 16) <= x"00";
            data_out(31 downto 24) <= x"00";
          when "00" =>                  -- byte
            data_out(7 downto 0)   <= mem(addr_int);
            data_out(15 downto 8)  <= x"00";
            data_out(23 downto 16) <= x"00";
            data_out(31 downto 24) <= x"00";
          when others =>
            data_out <= x"00000000";
        end case;
      else
        -- Write ram
        case length is
          when "11" =>                  -- word
            mem(addr_int)   := data_in(7 downto 0);
            mem(addr_int+1) := data_in(15 downto 8);
            mem(addr_int+2) := data_in(23 downto 16);
            mem(addr_int+3) := data_in(31 downto 24);
          when "01" =>                  -- halfword
            mem(addr_int)   := data_in(7 downto 0);
            mem(addr_int+1) := data_in(15 downto 8);
          when "00" =>                  -- byte
            mem(addr_int)   := data_in(7 downto 0);
          when others =>
        end case;        
      end if;
    end if;
  end process;
end Behavioral;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.Common.all;

entity MemoryVirtual is
  generic (
    debug : boolean
    );
  port (
    -- Interface --
    clk      : in  std_logic;
    rst      : in  std_logic;
    en       : in  std_logic;
    rw       : in  RwType;
    length   : in  LenType;
    addr     : in  std_logic_vector (31 downto 0);
    data_in  : in  std_logic_vector (31 downto 0);
    data_out : out std_logic_vector (31 downto 0)
    );
end MemoryVirtual;

architecture Behavioral of MemoryVirtual is
begin

  process(clk, rst)
    
    type StateType is (
      INITIAL,
      RAM_READ,
      RAM_WRITE,
      COM_WRITE
      );

    constant NUM_CELLS : integer := 1024*1024;
    type     VirtualMemoryType is array(0 to NUM_CELLS - 1) of Int8;

    variable state        : StateType;
    variable mem          : VirtualMemoryType;
    variable addr_int     : integer;
    variable L            : line;
    variable com          : line;
    variable data_out_tmp : std_logic_vector (31 downto 0);


    procedure load is
      file mem_file     : text open read_mode is "memory.dat";
      variable addr_var : integer;
      variable data_var : integer;
      variable i        : integer;
      variable word     : Int32;
      variable addr     : Int32;
    begin
      if debug then
        write(L, string'("loading memory from file"));
        writeline(output, L);
      end if;

      while not endfile(mem_file) loop
        readline(mem_file, L);
        addr_var := 0;
        for i in 1 to 8 loop
          if ('0' <= L(i) and L(i) <= '9') then
            addr_var := addr_var*16
                        + character'pos(L(i)) - character'pos('0');
          else
            addr_var := addr_var*16
                        + character'pos(L(i)) - character'pos('a') + 10;
          end if;
        end loop;
        data_var := 0;
        for i in 10 to 17 loop
          if ('0' <= L(i) and L(i) <= '9') then
            data_var := data_var*16
                        + character'pos(L(i)) - character'pos('0');
          else
            data_var := data_var*16
                        + character'pos(L(i)) - character'pos('a') + 10;
          end if;
        end loop;

        if debug then
          writeline(output, L);
        end if;
        
        word     := std_logic_vector(to_signed(data_var, 32));
        addr     := std_logic_vector(to_signed(addr_var, 32));
        addr     := "000" & addr(28 downto 0);
        addr_var := to_integer(unsigned(addr));
        
        mem(addr_var)   := word(7 downto 0);
        mem(addr_var+1) := word(15 downto 8);
        mem(addr_var+2) := word(23 downto 16);
        mem(addr_var+3) := word(31 downto 24);
        
      end loop;
    end load;
    
    procedure mem_debug(
      rw         : RwType;
      addr, data : std_logic_vector;
      length     : LenType) is
    begin
      if debug then
        write(L, string'("Mem["));
        write(L, to_hex_string(addr));
        if rw = R then
          write(L, string'("] :  "));
        else
          write(L, string'("] <= "));
        end if;
        case length is
          when Lword =>
            write(L, to_hex_string(data(31 downto 0)));
            write(L, string'(" ("));
            write(L, to_bitvector(data(31 downto 0)));
            write(L, string'(")"));
          when Lhalf =>
            write(L, to_hex_string(data(15 downto 0)));
            write(L, string'(" ("));
            write(L, to_bitvector(data(15 downto 0)));
            write(L, string'(")"));
          when Lbyte =>
            write(L, to_hex_string(data(7 downto 0)));
            write(L, string'(" ("));
            write(L, to_bitvector(data(7 downto 0)));
            write(L, string'(")"));
        end case;
        writeline(output, L);
      end if;
    end procedure;
    
  begin
    if rst = '0' then
      -- Reset
      load;
      state := INITIAL;
    elsif rising_edge(clk) then 
      if en = '1' then
        state := INITIAL;
      end if;
      case state is
        when INITIAL =>
          if en = '0' then
            if addr(31 downto 20) = x"000" then
              -- RAM
              addr_int := to_integer(unsigned(addr));
              if rw = R then
                state := RAM_READ;
              else
                state := RAM_WRITE;
              end if;
            elsif addr = COM_Data_Addr then
              if rw = W then
                state := COM_WRITE;
              end if;
            end if;
          end if;
        when RAM_READ =>
          -- Read ram
          case length is
            when Lword =>
              data_out_tmp(7 downto 0)   := mem(addr_int);
              data_out_tmp(15 downto 8)  := mem(addr_int+1);
              data_out_tmp(23 downto 16) := mem(addr_int+2);
              data_out_tmp(31 downto 24) := mem(addr_int+3);
            when Lhalf =>
              data_out_tmp(7 downto 0)   := mem(addr_int);
              data_out_tmp(15 downto 8)  := mem(addr_int+1);
              data_out_tmp(23 downto 16) := Int8_Zero;
              data_out_tmp(31 downto 24) := Int8_Zero;
            when Lbyte =>
              data_out_tmp(7 downto 0)   := mem(addr_int);
              data_out_tmp(15 downto 8)  := Int8_Zero;
              data_out_tmp(23 downto 16) := Int8_Zero;
              data_out_tmp(31 downto 24) := Int8_Zero;
          end case;
          data_out <= data_out_tmp;
          mem_debug(rw, addr, data_out_tmp, length);
          state    := INITIAL;
        when RAM_WRITE =>
          case length is
            when Lword =>
              mem(addr_int)   := data_in(7 downto 0);
              mem(addr_int+1) := data_in(15 downto 8);
              mem(addr_int+2) := data_in(23 downto 16);
              mem(addr_int+3) := data_in(31 downto 24);
            when Lhalf =>
              mem(addr_int)   := data_in(7 downto 0);
              mem(addr_int+1) := data_in(15 downto 8);
            when Lbyte =>
              mem(addr_int) := data_in(7 downto 0);
          end case;
          mem_debug(rw, addr, data_in, length);
          state := INITIAL;
        when COM_WRITE =>
          if not debug then
            write(com, to_hex_string(data_in(7 downto 0)));
            writeline(output, com);
          else
            mem_debug(rw, addr, data_in(7 downto 0), Lbyte);
          end if;
          state := INITIAL;
      end case;
    end if;
  end process;
end Behavioral;

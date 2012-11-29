f = open('bootloader.coe', 'r')
i = 0
vhdl = """library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity Rom is
  port (
    addr: in Int10;
    data: out Int32
  );
end Rom;

architecture Behavioral of Rom is
  constant NUM_ROM_CELLS: integer := 128;
  type RomType is array(0 to NUM_ROM_CELLS - 1) of Int32;
  signal rom: RomType;
begin
  data <= rom(to_integer(unsigned(addr)));
"""
for line in f:
  if i >= 2:
    value = line[0:8]
    vhdl += '  rom(' + str(i - 2) + ') <= x"' + value + '";\n'
  i += 1
vhdl += 'end architecture;\n'
f.close()
f = open('Rom.vhd', 'w')
f.write(vhdl)
f.close()

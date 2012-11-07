library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ALU is
  port (
    -- Interface --
    operator:     in      std_logic_vector (3 downto 0);
    operand1:     in      std_logic_vector (31 downto 0);
    operand2:     in      std_logic_vector (31 downto 0);
    result:       out     std_logic_vector (31 downto 0)
  );
end ALU;

architecture Behavioral of ALU is
  signal add_r, sub_r, sll_r, sla_r, rol_r : std_logic_vector (31 downto 0);  
begin

  process(operand1, operand2)
    variable sll_tmp: std_logic_vector (31 downto 0);
  begin
    sll_tmp := std_logic_vector(unsigned(operand1) sll to_integer(unsigned(operand2)));
    sll_r <= sll_tmp;	 
    sla_r <= operand1(31) & sll_tmp(30 downto 0);
    rol_r <= std_logic_vector(unsigned(operand1) rol to_integer(unsigned(operand2)));
    add_r <= std_logic_vector(unsigned(operand1) + unsigned(operand2));
    sub_r <= std_logic_vector(unsigned(operand1) - unsigned(operand2));
  end process;

  with operator select
    r <= add_r when "0000",
    sub_r when "0001",
    a and b when "0010",
    a or b when "0011",
    a xor b when "0100",
    not a when "0101",
    sll_r when "0110",
    sla_r when "0111",
    rol_r when "1000",
    "----------------" when others;

end Behavioral;

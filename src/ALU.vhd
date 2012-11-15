library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity ALU is
  port (
    -- Interface --
    operator:     in      std_logic_vector(4 downto 0);
    operand1:     in      std_logic_vector(31 downto 0);
    operand2:     in      std_logic_vector(31 downto 0);
    result:       out     std_logic_vector(31 downto 0)
  );
end ALU;

architecture Behavioral of ALU is
begin
  process(operand1, operand2)
    variable op1_s, op2_s: Signed32;
    variable op1_us, op2_us: Unsigned32;
  begin
    op1_s := signed(operand1);
    op2_s := signed(operand2);
    op1_us := unsigned(operand1);
    op2_us := unsigned(operand2);
    case operator is
      when OP_AND =>
        result <= operand1 and operand2;
      when OP_OR =>
        result <= operand1 or operand2;
      when OP_XOR =>
        result <= operand1 xor operand2;
      when OP_NOR =>
        result <= operand1 nor operand2;
      when OP_NOT =>
        result <= not operand1;
      when OP_PLUS => -- plus
        result <= std_logic_vector(op1_us + op2_us);
      when OP_MINUS => -- minus
        result <= std_logic_vector(op1_us - op2_us);
      when OP_SRL => -- shift right logic
        result <= std_logic_vector(shift_right(op1_us, to_integer(op2_us)));
      when OP_SRA => -- shift right arithmetic
        result <= std_logic_vector(shift_right(op1_s, to_integer(op2_us)));
      when OP_SLL => -- shift left logic
        result <= std_logic_vector(shift_left(op1_us, to_integer(op2_us)));
      when OP_EQ => -- equal
        result <= Int31_Zero & boolean_to_std_logic(operand1 = operand2);
      when OP_NE => -- not equal
        result <= Int31_Zero & boolean_to_std_logic(operand1 /= operand2);
      when OP_LTU => -- less than (unsigned)
        result <= Int31_Zero & boolean_to_std_logic(op1_us < op2_us);
      when OP_LT => -- less than (signed)
        result <= Int31_Zero & boolean_to_std_logic(op1_s < op2_s);
      when OP_GTU => -- greater than (unsigned)
        result <= Int31_Zero & boolean_to_std_logic(op1_us > op2_us);
      when OP_GT => -- greater than (signed)
        result <= Int31_Zero & boolean_to_std_logic(op1_s > op2_s);
      when OP_LTEU => -- less than or equal (unsigned)
        result <= Int31_Zero & boolean_to_std_logic(op1_us <= op2_us);
      when OP_LTE => -- less than or equal (signed)
        result <= Int31_Zero & boolean_to_std_logic(op1_s <= op2_s);
      when OP_GTEU => -- greater than or equal (unsigned)
        result <= Int31_Zero & boolean_to_std_logic(op1_us >= op2_us);
      when OP_GTE => -- greater than or equal (signed)
        result <= Int31_Zero & boolean_to_std_logic(op1_s >= op2_s);
      when others =>
        result <= Int32_Zero;
    end case;
  end process;
end Behavioral;

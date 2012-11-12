library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity OperatorEncoder is
  port (
    -- Interface --
    op:           in      std_logic_vector(5 downto 0);
    func:         in      std_logic_vector(5 downto 0);
    rt:           in      std_logic_vector(4 downto 0);
    operator:     out     std_logic_vector(4 downto 0)
  );
end OperatorEncoder;

architecture Behavioral of OperatorEncoder is
begin
  process (op, func, rt)
  begin
    case op is
      when "000000" =>
        case func is
          when "000000" => -- sll
            operator <= OP_SLL;
          when "000010" => -- srl
            operator <= OP_SRL;
          when "000011" => -- sra
            operator <= OP_SRA;
          when "000100" => -- sllv
            operator <= OP_SLL;
          when "000110" => -- srlv
            operator <= OP_SRL;
          when "000111" => -- srav
            operator <= OP_SRA;
          when "100001" => -- addu
            operator <= OP_PLUS;
          when "100011" => -- subu
            operator <= OP_MINUS;
          when "100100" => -- and
            operator <= OP_AND;
          when "100101" => -- or
            operator <= OP_OR;
          when "100110" => -- xor
            operator <= OP_XOR;
          when "100111" => -- nor
            operator <= OP_NOR;
          when "101010" => -- slt
            operator <= OP_LT;
          when "101011" => -- sltu
            operator <= OP_LTU;
          when others =>
            operator <= OP_INVALID;
        end case;
      when "000001" =>
        case rt is
          when "00000" => -- bltz
            operator <= OP_LT;
          when "00001" => -- bgez
            operator <= OP_GTE;
          when others =>
            operator <= OP_INVALID;
        end case;
      when "000100" => -- beq
        operator <= OP_EQ;
      when "000101" => -- bne
        operator <= OP_NE;
      when "000110" => -- blez
        operator <= OP_LTE;
      when "000111" => -- bgtz
        operator <= OP_GT;
      when "001001" => -- addiu
        operator <= OP_PLUS;
      when "001010" => -- slti
        operator <= OP_LT;
      when "001011" => -- sltiu
        operator <= OP_LTU;
      when "001100" => -- andi
        operator <= OP_AND;
      when "001101" => -- ori
        operator <= OP_OR;
      when "001110" => -- xori
        operator <= OP_XOR;
      when others =>
        operator <= OP_INVALID;
    end case;
  end process;
end Behavioral;

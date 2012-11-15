library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity AluOpEncoder is
  port (
    -- Interface --
    opcode : in  std_logic_vector(5 downto 0);
    func   : in  std_logic_vector(5 downto 0);
    rt     : in  std_logic_vector(4 downto 0);
    aluop  : out AluOpType
    );
end AluOpEncoder;

architecture Behavioral of AluOpEncoder is
begin
  process
  begin
    case opcode is
      -- R-Type
      when "000000" =>
        case func is
          when "000000" =>              -- sll
            aluop <= ALU_SLL;
          when "000010" =>              -- srl
            aluop <= ALU_SRL;
          when "000011" =>              -- sra
            aluop <= ALU_SRA;
          when "000100" =>              -- sllv
            aluop <= ALU_SLL;
          when "000110" =>              -- srlv
            aluop <= ALU_SRL;
          when "000111" =>              -- srav
            aluop <= ALU_SRA;
          when "100001" =>              -- addu
            aluop <= ALU_ADD;
          when "100011" =>              -- subu
            aluop <= ALU_SUB;
          when "100100" =>              -- and
            aluop <= ALU_AND;
          when "100101" =>              -- or
            aluop <= ALU_OR;
          when "100110" =>              -- xor
            aluop <= ALU_XOR;
          when "100111" =>              -- nor
            aluop <= ALU_NOR;
          when "101010" =>              -- slt
            aluop <= ALU_LT;
          when "101011" =>              -- sltu
            aluop <= ALU_LTU;
          when others =>
            -- alu not needed
        end case;
      when "000001" =>
        case rt is
          when "00000" =>               -- bltz
            aluop <= ALU_LT;
          when "00001" =>               -- bgez
            aluop <= ALU_GEZ;
          when others =>
            -- alu not needed
        end case;
      when "000100" =>                  -- beq
        aluop <= ALU_EQ;
      when "000101" =>                  -- bne
        aluop <= ALU_NE;
      when "000110" =>                  -- blez
        aluop <= ALU_LEZ;
      when "000111" =>                  -- bgtz
        aluop <= ALU_GTZ;
      when "001001" =>                  -- addiu
        aluop <= ALU_ADD;
      when "001010" =>                  -- slti
        aluop <= ALU_LT;
      when "001011" =>                  -- sltiu
        aluop <= ALU_LTU;
      when "001100" =>                  -- andi
        aluop <= ALU_AND;
      when "001101" =>                  -- ori
        aluop <= ALU_OR;
      when "001110" =>                  -- xori
        aluop <= ALU_XOR;
      when "001111" =>                  -- lui
        aluop <= ALU_SLL;
      when "100000"                     -- lb
                 | "100011"             -- lw
                 | "100100"             -- lbu
                 | "101000"             -- sb
                 | "101011" =>          -- sw
        aluop <= ALU_ADD;
      when others =>
        --alu not needed
    end case;
  end process;
end Behavioral;

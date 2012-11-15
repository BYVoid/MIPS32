library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.Common.all;

entity AluOpEncoder is
  port (
    -- Interface --
    op    : in  std_logic_vector(5 downto 0);
    func  : in  std_logic_vector(5 downto 0);
    rt    : in  std_logic_vector(4 downto 0);
    aluop : out AluOpType
    );
end AluOpEncoder;

architecture Behavioral of AluOpEncoder is
begin
  process
  begin
    case op is
      -- R-Type
      when op_special =>
        case func is
          when func_sll =>
            aluop <= ALU_SLL;
          when func_srl =>
            aluop <= ALU_SRL;
          when func_sra =>
            aluop <= ALU_SRA;
          when func_sllv =>
            aluop <= ALU_SLL;
          when func_srlv =>
            aluop <= ALU_SRL;
          when func_srav =>
            aluop <= ALU_SRA;
          when func_addu =>
            aluop <= ALU_ADD;
          when func_subu =>
            aluop <= ALU_SUB;
          when func_and =>
            aluop <= ALU_AND;
          when func_or =>
            aluop <= ALU_OR;
          when func_xor =>
            aluop <= ALU_XOR;
          when func_nor =>
            aluop <= ALU_NOR;
          when func_slt =>
            aluop <= ALU_LT;
          when func_sltu =>
            aluop <= ALU_LTU;
          when others =>
            -- alu not needed
        end case;
      when op_regimm =>
        case rt is
          when rt_bltz =>
            aluop <= ALU_LT;
          when rt_bgez =>
            aluop <= ALU_GEZ;
          when others =>
            -- alu not needed
        end case;
      when op_beq =>
        aluop <= ALU_EQ;
      when op_bne =>
        aluop <= ALU_NE;
      when op_blez =>
        aluop <= ALU_LEZ;
      when op_bgtz =>
        aluop <= ALU_GTZ;
      when op_addiu =>
        aluop <= ALU_ADD;
      when op_slti =>
        aluop <= ALU_LT;
      when op_sltiu =>
        aluop <= ALU_LTU;
      when op_andi =>
        aluop <= ALU_AND;
      when op_ori =>
        aluop <= ALU_OR;
      when op_xori =>
        aluop <= ALU_XOR;
      when op_lui =>
        aluop <= ALU_SLL;
      when op_lb | op_lw | op_lbu | op_sb | op_sw =>
        aluop <= ALU_ADD;
      when others =>
        --alu not needed
    end case;
  end process;
end Behavioral;

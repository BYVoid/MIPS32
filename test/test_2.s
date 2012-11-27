#sra_sllv_srlv_lbu_sb
start:
  .text 0
  lw $2, operand($0)  # r2 := operand
  sra $3, $2, 3       # r3 := r2 >> 3 (arithmetic)
  sllv $2, $3, $2     # r2 := r3 << r2(4 downto 0, = 5)
  sw $2, operand($0)  # operand := r2
  lbu $2, shamt($0)   # r2 := shamt(7 downto 0, = 0x8E)
  lw $3, operand($0)  # r3 := operand
  srlv $3, $3, $2     # r3 := r3 >> r2(4 downto 0, = 14)
  addiu $2, $0, 1     # r2 := 1  
  sb $3, shamt($2)    # shamt(15 downto 8) := r3
  lw $2, shamt($0)    # r2 := shamt
  syscall
operand:
  .word 0xAA001005
shamt:
  .word 0xFFFFFF8E
  
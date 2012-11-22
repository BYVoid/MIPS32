text:
  .text 0
  lw $2, addend_a($0) # r2 := addend_a
  addiu $3, $2, 456   # r3 := r2 + 456
  sw $3, result($0)   # result := r3
  lw $4, result($0)   # r4 := result
  syscall
addend_a:
  .word 123
result:
  .word 0

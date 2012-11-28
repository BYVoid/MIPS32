.set noreorder
#jump_branch_com
start:
  .text 0
  j calc
  nop
calc:
  la $s0, 0xbfd003f8
  la $s1, 0xbfd003fc

  addiu $2, $0, 0x30   # r2 := 0x30
  addiu $3, $0, 8      # r3 := 8
loop:
  addu  $3, $2, $3     # r3 := r2 + r3
  
  move $a0, $3
  jal write_com
  nop
  
  addiu $3, $3, 0xffff # r3 := r3 - 1
  subu  $3, $3, $2     # r3 := r3 - r2 
  bgez  $3, loop       # if r3 >= 0 then goto loop

  break

write_com:
  li $t1, 1
  write_com_loop:
  lw $t0, 0($s1)
  andi $t0, $t0, 1
  bne $t0, $t1, write_com_loop
  sw $a0, 0($s0)
  jr $ra

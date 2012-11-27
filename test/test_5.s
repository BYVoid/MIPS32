.set noreorder
#Multiply and write to com
start:
  .text 0
  la $s0, 0xbfd003f8
  la $s1, 0xbfd003fc
  
  li $t0, 12345678
  li $t1, 34567890
  mult $t0, $t1
  
  mfhi $a0
  jal wrtie_word_com
  nop
  
  mflo $a0
  jal wrtie_word_com
  nop
  
  syscall

wrtie_word_com:
  move $t7, $ra
  move $t8, $a0
  
  li $t9, 0xFF000000
  and $t9, $t8, $t9
  srl $a0, $t9, 24
  jal write_com
  nop
  
  li $t9, 0xFF0000
  and $t9, $t8, $t9
  srl $a0, $t9, 16
  jal write_com
  nop
  
  li $t9, 0xFF00
  and $t9, $t8, $t9
  srl $a0, $t9, 8
  jal write_com
  nop
  
  move $a0, $t8
  jal write_com
  nop
  
  jr $t7
  nop

write_com:
  li $t1, 1
  loop:
  lw $t0, 0($s1)
  andi $t0, $t0, 1
  bne $t0, $t1, loop
  sw $a0, 0($s0)
  jr $ra
  nop

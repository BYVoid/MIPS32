.set noreorder
.set noat
__start:
  li $a0, 0
  jal load_flash
  nop
  move $a0, $v0
  jal wrtie_word_com
  nop
  li $a0, 4
  jal load_flash
  nop
  move $a0, $v0
  jal wrtie_word_com
  nop
  break

/* off = offset from s0 */
/* load a 32bit word from Flash, 
 * off is byte-addressed */
load_flash:
  move $t7, $a0
  sll $t7, $t7, 1
  la $s0, 0xBE000000
  addu $t7, $s0, $t7
  lw $v0, 0($t7)
  lw $t7, 4($t7)
  sll $t7, $t7, 16
  or $v0, $v0, $t7
  jr $ra
  nop

wrtie_word_com:
  la $s0, 0xbfd003f8
  la $s1, 0xbfd003fc
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

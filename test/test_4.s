.set noreorder
#Write com function test
start:
  .text 0
  la $s0, 0xbfd003f8
  la $s1, 0xbfd003fc
  li $a0, 0x23
  jal write_com
  nop
  li $a0, 0x24
  jal write_com
  nop
  li $a0, 0x25
  jal write_com
  nop
  break

write_com:
  li $t1, 1
  loop:
  lw $t0, 0($s1)
  andi $t0, $t0, 1
  bne $t0, $t1, loop
  sw $a0, 0($s0)
  jr $ra

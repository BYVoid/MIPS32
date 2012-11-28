# exceptions
.set noreorder
start:
  .text 0
  jal init
  nop
  
  la $s0, 0xbfd003f8
  la $s1, 0xbfd003fc
  
  li $a0, 0x12
joop:
  jal write_com
  nop
  j loop
  nop
  # never reach here


init:

  # set exception return base (EBase)
  la $t1, 0x800b0000  
  mfc0 $t0, $15
  or   $t0, $t1
  mtc0 $t0, $15
  
  # set Compare to Count + 400
  mfc0 $t0, $9
  addu $t0, $t0, 400
  mtc0 $t0, $11
  
  # enable exception
  mfc0 $t0, $12
  or   $t0,  0b00000000000000001111111100000001
  and  $t0,~(0b00000000000000000000000000000010)
  mtc0 $t0, $12
  
  jr $ra
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

  
# ex_handler @ 0x800b0180
.set noreorder
start:
  .text 0
  
  la $s0, 0xbfd003f8
  la $s1, 0xbfd003fc
  
  ori  $k0, $a0, 0   # protect $a0
  ori  $k1, $ra, 0   # protect $ra
  li   $a0, 0x34
  jal  write_com
  nop
  ori  $a0, $k0, 0   # restore $a0
  ori  $ra, $k1, 0   # restore $ra
  
  # set Compare to Count + 300
  mfc0 $t0, $9
  addu $t0, $t0, 300
  mtc0 $t0, $11
  
  eret
  
write_com:
  li $t1, 1
  loop:
  lw $t0, 0($s1)
  andi $t0, $t0, 1
  bne $t0, $t1, loop
  sw $a0, 0($s0)
  jr $ra
  nop




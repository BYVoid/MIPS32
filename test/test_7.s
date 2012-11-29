# exceptions
.set noreorder
start:
  .text 0
  jal init
  nop
  div $s0, $s1
  break


init:
  
  # set exception return base (EBase)
  la $t1, 0x80000000 
  mfc0 $t0, $15
  or   $t0, $t1
  mtc0 $t0, $15
  
  # enable exception
  mfc0 $t0, $12
  or   $t0,  0b00000000000000000000000000000001
  and  $t0,~(0b00000000000000000000000000000010)
  mtc0 $t0, $12
  
  jr $ra
  nop
  
# ex_handler @ 0x80000180
.set noreorder
start:
  .text 0
  
  la $s0, 0xbfd003f8
  la $s1, 0xbfd003fc
  
  mfc0 $a0, $13
  and  $a0, 0xff
  srl  $a0, 2
  jal  write_com
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
  nop




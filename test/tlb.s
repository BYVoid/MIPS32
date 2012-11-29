# tlb
.set noreorder
start:
  .text 0
  jal init
  nop
  
  la $s0, 0xbfd003f8
  la $s1, 0xbfd003fc
  
  lw $a0, 0x40000070($0)
  jal write_com
  nop
  
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

write_com:
  li $t1, 1
  loop:
  lw $t0, 0($s1)
  andi $t0, $t0, 1
  bne $t0, $t1, loop
  sw $a0, 0($s0)
  jr $ra
  nop
  
data:
  .word 0x00000012
  
# ex_handler @ 0x80000180
.set noreorder
start:
  .text 0
  
  la $k0, 0x00000000
  mtc0 $k0, $0
  
  la $k0, 0x00000002
  mtc0 $k0, $2
  
  la $k0, 0x40000000
  mtc0 $k0, $10
  
  tlbwi
  
  eret
 
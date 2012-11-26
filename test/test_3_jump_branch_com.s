start:
  .text 0
  j calc
  j start
calc:
  la    $4, 0x1fd003f8
  addiu $2, $0, 0x30   # r2 := 0x30
  addiu $3, $0, 8      # r3 := 8
loop:
  addu  $3, $2, $3     # r3 := r2 + r3
  sb    $3, 0($4)
  addiu $3, $3, 0xffff # r3 := r3 - 1
  subu  $3, $3, $2     # r3 := r3 - r2 
  bgez  $3, loop       # if r3 >= 0 then goto loop
  addiu $5, $0, 0x0a   # r5 := 0x0a ('\n')
  sb    $5, 0($4)
  syscall

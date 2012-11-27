#Load a number and send it to COM
start:
  .text 0
  la $4, 0x1234
  la $5, 0xBFD003F8 # r5 := COM_ADDR
  sw $4, 0($5) # mem[r5] := r4
  syscall

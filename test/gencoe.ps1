# compile assembly code to binary, disassemble it to .code.txt
# then convert to memory image(.dat) for simulation

if ($args.count -eq 1) {  
  $startaddr = "0x00000000"
} elseif ($args.count -eq 2) {
  if ($args[1].gettype().name -eq "Int32") {
    $startaddr = "{0:x}" -f $args[1]   
  } else {
    echo "startaddr must be a number"
    exit
  }
} else {
  echo "USAGE: ./gencoe {filename} [{startaddr}=0x00000000]"
  exit
}

$filein = $args[0]
if (!(test-path $filein)) {
  echo "File Not Found: $filein"
  exit
}

# extract out the file extension
$fileout = $filein -replace('\.\w+$', '')

# compile, -EL for little endien, -g for not strip the NOP after branch
mips-sde-elf-as -EL -g -mips32 $filein -o "$fileout.o"
# link, -Ttext to set start address for text segment 
mips-sde-elf-ld -EL -e $startaddr -Ttext $startaddr "$fileout.o" -o "$fileout.out"
mips-sde-elf-objcopy -O binary "$fileout.out" "$fileout.bin"
# disassemble
mips-sde-elf-objdump -EL -S --prefix-addresses --show-raw-insn "$fileout.out" | out-file -encoding ascii "$fileout.code"
# generate coe file
./bintocoe "$fileout.bin" "$fileout.coe"

rm "$fileout.o"
rm "$fileout.out"
rm "$fileout.bin"

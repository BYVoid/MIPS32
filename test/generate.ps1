# generate coe for rom, or data for ram

if ($args.count -eq 2) {  
  $target = $args[0]
  if ($target -eq "-rom") {
    $startaddr = "0xBFC00000"
  } elseif ($target -eq "-ram") {
    $startaddr = "0x80000000"
  } else {
    echo "USAGE: ./generate [-rom|-ram] {filename}"
    exit
  }  
} else {
  echo "USAGE: ./generate [-rom|-ram] {filename}"
  exit
}

$ext = $target.substring(1,3)

$filein = $args[1]
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
mips-sde-elf-objdump -EL -S --prefix-addresses --show-raw-insn "$fileout.out" | out-file -encoding ascii "$fileout.$ext.code"

if ($target -eq "-rom") {
  # generate coe file
  ./bintocoe "$fileout.bin" "$fileout.coe"
} elseif ($target -eq "-ram") {
  # generate data file
  ./bintodata "$fileout.bin" "$fileout.ram1.data" "$fileout.ram2.data"
} 

rm "$fileout.o"
rm "$fileout.out"
rm "$fileout.bin"

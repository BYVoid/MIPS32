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

$ex = $null
select-string '^# ?ex_handler ?@ ?(\w+) ?$' -Path $filein | 
%{$ex = $_.matches.count
  $exline = $_.linenumber
  $exstartaddr = $_.matches[0].groups[1].value
}

if ($ex -eq $null) {
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
} elseif (($ex -eq 1) -and ($target -eq "-ram")) {
  $line = (cat $filein).count
  (cat $filein)[0..($exline-2)] | out-file -encoding ascii "$fileout.1.s"
  (cat $filein)[$exline..($line-1)] | out-file -encoding ascii "$fileout.2.s"
  mips-sde-elf-as -EL -g -mips32 "$fileout.1.s" -o "$fileout.1.o"
  mips-sde-elf-as -EL -g -mips32 "$fileout.2.s" -o "$fileout.2.o"
  mips-sde-elf-ld -EL -e $startaddr -Ttext $startaddr "$fileout.1.o" -o "$fileout.1.out"
  mips-sde-elf-ld -EL -e $startaddr -Ttext $exstartaddr "$fileout.2.o" -o "$fileout.2.out"
  mips-sde-elf-objcopy -O binary "$fileout.1.out" "$fileout.1.bin"
  mips-sde-elf-objcopy -O binary "$fileout.2.out" "$fileout.2.bin"
  mips-sde-elf-objdump -EL -S --prefix-addresses --show-raw-insn "$fileout.1.out" | out-file -encoding ascii "$fileout.ram.code"
  mips-sde-elf-objdump -EL -S --prefix-addresses --show-raw-insn "$fileout.2.out" | out-file -encoding ascii "$fileout.ram.code" -append
  ./bintodata "$fileout.1.bin" "$fileout.1.ram1.data" "$fileout.1.ram2.data"
  ./bintodata "$fileout.2.bin" "$fileout.2.ram1.data" "$fileout.2.ram2.data"
  rm "$fileout.1.s"
  rm "$fileout.1.o"
  rm "$fileout.1.out"
  rm "$fileout.1.bin"
  rm "$fileout.2.s"
  rm "$fileout.2.o"
  rm "$fileout.2.out"
  rm "$fileout.2.bin"
} else {
  echo "Can't handle neither more than one of ex_handler, nor ex_handler for rom"
  exit
}

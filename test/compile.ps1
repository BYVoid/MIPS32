# compile assembly code to binary, disassemble it to .code.txt
# then convert to memory image(.dat) for simulation

if ($args.count -ne 1) {
  echo "USAGE: ./compile {filename}"
  exit
}

$filein = $args[0]

# extract out the file extension
$fileout = $filein -replace('\.\w+$', '')

# compile, -EL for little endien, -g for not strip the NOP after branch
mips-sde-elf-as -EL -g -mips32 $filein -o "$fileout.out"

# disassemble
mips-sde-elf-objdump -EL -d --prefix-addresses --show-raw-insn "$fileout.out" | out-file -encoding ascii "$fileout.code.txt"

# convert to .dat format
cat "$fileout.code.txt" | where{$_ -match '^\w+ <.+> \w+ +.+$'} | %{$_ -replace '^(\w+) <.+> (\w+) +.+$','$1 $2'} | out-file -encoding ascii "$fileout.dat"

rm "$fileout.out"

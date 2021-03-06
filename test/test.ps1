# compile assembly code to binary, disassemble it to .code.txt
# then convert to memory image(.dat) for simulation
# compare the simulation result to expected result

$startaddr = "0x80000000"

if ($args.count -ne 1) {
  echo "USAGE: ./test {filename} or ./test -all"
  exit
}

if ($args[0] -eq "-all")
{
  $total = $passed = $failed = $untested = 0
  ls *.s | % {./test $_.name
    $total++
    switch ($lastexitcode) {
      0 {$untested++}
      1 {$failed++}
      2 {$passed++}
    }
  }
  echo "Total=$total, Passed=$passed, Failed=$failed, Untested=$untested"
  exit
}

$filein = $args[0]
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
  # disassemble
  mips-sde-elf-objdump -EL -S --prefix-addresses --show-raw-insn "$fileout.out" | out-file -encoding ascii "$fileout.sim.code"
  
  rm "$fileout.o"
  rm "$fileout.out"
} elseif ($ex -eq 1) {
  $line = (cat $filein).count
  (cat $filein)[0..($exline-2)] | out-file -encoding ascii "$fileout.1.s"
  (cat $filein)[$exline..($line-1)] | out-file -encoding ascii "$fileout.2.s"
  mips-sde-elf-as -EL -g -mips32 "$fileout.1.s" -o "$fileout.1.o"
  mips-sde-elf-as -EL -g -mips32 "$fileout.2.s" -o "$fileout.2.o"
  mips-sde-elf-ld -EL -e $startaddr -Ttext $startaddr "$fileout.1.o" -o "$fileout.1.out"
  mips-sde-elf-ld -EL -e $startaddr -Ttext $exstartaddr "$fileout.2.o" -o "$fileout.2.out"
  mips-sde-elf-objdump -EL -S --prefix-addresses --show-raw-insn "$fileout.1.out" | out-file -encoding ascii "$fileout.sim.code"
  mips-sde-elf-objdump -EL -S --prefix-addresses --show-raw-insn "$fileout.2.out" | out-file -encoding ascii "$fileout.sim.code" -append
  
  rm "$fileout.1.s"
  rm "$fileout.1.o"
  rm "$fileout.1.out"
  rm "$fileout.2.s"
  rm "$fileout.2.o"
  rm "$fileout.2.out" 
} else {
  echo "Can't handle more than one of ex_handler"
  exit
}

# convert to .dat format
cat "$fileout.sim.code" | where{$_ -match '^\w+ <.+> \w+ +.+$'} | %{$_ -replace '^(\w+) <.+> (\w+) +.+$','$1 $2'} | out-file -encoding ascii "$fileout.dat"

# simulation use memory.dat under /src directory
cp "$fileout.dat" ../src/memory.dat
cp bootloader.hex ../src/rom.hex
cp ucore.hex ../src/flash.hex

cd ../src

# clean simulation files if exist
if (test-path transcript) {rm -force transcript}
if (test-path *wlf*) {rm -force *wlf*}
if (test-path work) {rm -force -recurse work}

# create the work library 
vlib work

# generate CPU_sim.vhd
cat CPU.vhd | %{$_ -replace ('--sim: ', '')} | out-file -encoding ascii CPU_sim.vhd
# compile VHDL quietly
vcom -quiet Common.vhd MemoryVirtual.vhd AluOpEncoder.vhd ALU.vhd RegisterFile.vhd CPU_sim.vhd System_sim.vhd

# estimate the simulation time
$line = (cat ./memory.dat).count
$time = $line * 8000;

# generate script, perform simulation, then delete the script
echo "run $time ns" "exit -f" | out-file -encoding ascii "$fileout.in"
vsim -c -quiet -Gdebug=true -do "$fileout.in" system_sim | out-file -encoding ascii "$fileout.debug"
vsim -c -quiet -Gdebug=false -do "$fileout.in" system_sim | out-file -encoding ascii "$fileout.output"
rm "$fileout.in"

# clean the simulation files
if (test-path transcript) {rm -force transcript}
if (test-path *wlf*) {rm -force *wlf*}
if (test-path work) {rm -force -recurse work}
if (test-path memory.dat) {rm -force memory.dat}
if (test-path rom.hex) {rm -force rom.hex}
if (test-path flash.hex) {rm -force flash.hex}

cd ../test

# parse the result files, then delete them
$line = (cat ../src/"$fileout.debug").count
if ($line -gt 6) {
  (cat ../src/"$fileout.debug")[6..($line-1)] | %{$_ -replace ('^# ', '')} | out-file -encoding ascii "$fileout.d.result"
} else {
  echo "" | out-file -encoding ascii "$fileout.d.result"
}
rm ../src/"$fileout.debug"

$line = (cat ../src/"$fileout.output").count
if ($line -gt 6) {
  (cat ../src/"$fileout.output")[6..($line-1)] | %{$_ -replace ('^# ', '')} | out-file -encoding ascii "$fileout.o.result"
} else {
  echo "" | out-file -encoding ascii "$fileout.o.result"
}
rm ../src/"$fileout.output"

# test the result files against expected files
if ((test-path "$fileout.d.expected") -and (test-path "$fileout.d.expected")) {
  if ((diff (cat "$fileout.d.result") (cat "$fileout.d.expected")) -or (diff (cat "$fileout.o.result") (cat "$fileout.o.expected"))) {
    echo "FAILED: $filein"
    exit 1
  } else {
    echo "PASSED: $filein"
    exit 2
  }
} else {
  echo "UNTESTED: $filein"
  exit 0
}

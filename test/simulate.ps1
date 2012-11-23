# perform the simulation

if ($args.count -ne 1) {
  echo "USAGE: ./simulate {filename}"
  exit
}

$filein = $args[0]

# extract out the file extension
$fileout = $filein -replace('\.dat$', '')

# simulation use memory.dat under /src directory
cp $filein ../src/memory.dat

cd ../src

# clean simulation files if exist
if (test-path transcript) {rm -force transcript}
if (test-path *wlf*) {rm -force *wlf*}
if (test-path work) {rm -force -recurse work}

# create the work library 
vlib work

# compile VHDL quietly
vcom -quiet Common.vhd MemoryVirtual.vhd AluOpEncoder.vhd ALU.vhd RegisterFile.vhd CPU.vhd System_sim.vhd

# estimate the simulation time
$line = (cat ./memory.dat).count
$time = $line * 8 * 100 + 200;

# generate script, perform simulation, then delete the script
echo "run $time ns" "exit -f" | out-file -encoding ascii "$fileout.in"
vsim -c -quiet -do "$fileout.in" system_sim | out-file -encoding ascii "$fileout.result"
rm "$fileout.in"

# clean the simulation files
if (test-path transcript) {rm -force transcript}
if (test-path *wlf*) {rm -force *wlf*}
if (test-path work) {rm -force -recurse work}
if (test-path memory.dat) {rm -force memory.dat}

cd ../test

# parse the result file, then delete it
# $line = (cat ../src/"$fileout.result").count
cat ../src/"$fileout.result" | %{$_ -replace ('^# ', '')} |out-file -encoding ascii "$fileout.result.txt"
rm ../src/"$fileout.result"

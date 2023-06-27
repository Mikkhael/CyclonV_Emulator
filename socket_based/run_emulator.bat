vlog ./*.v
@ IF ERRORLEVEL 1 exit 1
vopt +acc EMULATOR -o emulator_opt
@ IF ERRORLEVEL 1 exit 1

vsim -c emulator_opt -do "emulator.do"
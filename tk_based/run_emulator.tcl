
set DO_SIMPLE  [expr [lsearch -glob $argv "-s*"] != -1]
set DO_SIMPLEF [expr [lsearch -glob $argv "-S*"] != -1]
set DO_QUARTUS [expr [lsearch -glob $argv "-q*"] != -1]

if {!$DO_SIMPLE && !$DO_SIMPLEF && !$DO_QUARTUS} {
    puts "###############################"
    puts "No emulation type specified (use -s, -S or -q)"
    set DO_QUARTUS [llength [glob -nocomplain "*.qpf"]]
    set DO_SIMPLE [expr !$DO_QUARTUS]
}

if {$DO_SIMPLE} {
    puts "###############################"
    puts "  Preparing Simple Emulation"
    puts "###############################"
    puts "######### Compiling all *.v files in current directory ([pwd])... ############"
    if { [catch {exec "vlog" "./*.v" >@stdout 2>@stderr <@stdin}] } {
        puts "######### Compilation Error - Aborting... ############"
        exit
    }
    puts "######### Optimizing... ############"
    if { [catch {exec vopt +acc EMULATOR -o emulator_opt >@stdout 2>@stderr <@stdin}] } {
        puts "######### Optimization Error - Aborting... ############"
        exit
    }
}
if {$DO_SIMPLE || $DO_SIMPLEF} {
    puts "###############################"
    puts "      Starting Emulation"
    puts "###############################"
    catch {exec vsim -c emulator_opt -do emulator.do >@stdout 2>@stderr <@stdin}
}


if {$DO_QUARTUS} {
    puts "###############################"
    puts "   Preparing Quartus Script"
    puts "###############################"
    set do_files [glob -nocomplain "simulation/modelsim/*_gate_*.do"]
    if {[llength $do_files] == 0} {
        puts "Not found gate-level simulation script inside ([pwd]/simulation) directory"
        puts "Be sure to correctly set up quartus simulation, by running Gate-Level Simulation for (corectly configured) testbench \"EMULATOR\""
        puts "######### Preparing Script Failed - Aborting... ############"
        exit
    }
    if { [catch {
        puts "Reading simulation script..."
        set do_file [lindex $do_files 0]
        set do_file_fd [open $do_file "r"]
        set do_file_data [read $do_file_fd]
        close $do_file_fd
        puts "Modifying simulation script..."
        set do_file_data [string map {"run -all" "do ../../emulator.do ../.."} $do_file_data]
        puts "Overriding simulation script..."
        set do_file_fd [open $do_file "w"]
        puts -nonewline $do_file_fd $do_file_data
        close $do_file_fd
    }] } {
        puts "######### Filesystem Error - Aborting... ############"
        exit
    }
    puts "###############################"
    puts "      Starting Emulation"
    puts "###############################"
    cd "simulation/modelsim"
    catch {exec vsim -c -do [file tail $do_files] >@stdout 2>@stderr <@stdin}
}
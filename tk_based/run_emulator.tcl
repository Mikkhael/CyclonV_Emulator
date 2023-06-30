
set DO_SIMPLE   [expr [lsearch -glob $argv "-s*"] != -1]
set DO_SIMPLEF  [expr [lsearch -glob $argv "-S*"] != -1]
set DO_QUARTUS  [expr [lsearch -glob $argv "-q*"] != -1]
set FORCE_REP   [expr [lsearch -glob $argv "-a*"] != -1]
set NOFORCE_REP [expr [lsearch -glob $argv "-na*"] != -1]

proc puts2 {data} {
    puts "\[EMU\] $data"
}

proc prepare_dut_instance {force_override} {
    set vo_files [glob -nocomplain "simulation/modelsim/*.vo"]
    if {[llength $vo_files] == 0} {
        puts2 "######################################################"
        puts2 "Precompiled top-level module ([pwd]/simulation/modelsim/*.vo) not found."
        puts2 "If you had run Netlist Writer, than create the instantiation inside emulator/emulator.v manualy"
        puts2 "######################################################"
        puts2 "Press enter to continue..."
        gets stdin
        return 0
    }

    puts2 "Reading top-level module verilog template..."
    set vo_file [lindex $vo_files 0]
    set vo_file_fd [open $vo_file "r"]
    set vo_data [read $vo_file_fd]
    close $vo_file_fd

    set vo_data_module_res [regexp -lineanchor -inline "^module (\\S+?) \\((.*?)\\);$" $vo_data]

    if {[llength $vo_data_module_res] != 3} {
        puts2 "######################################################"
        puts2 "Unexpected format of ([pwd]/simulation/modelsim/*.vo)"
        puts2 "Please create the instantiation inside emulator/emulator.v manualy"
        puts2 "######################################################"
        puts2 "Press enter to continue..."
        gets stdin
        return 0;
    }
    
    puts2 "Extracting top-level name and ports..."
    set vo_module_name       [lindex $vo_data_module_res 1]
    set vo_module_ports_str  [lindex $vo_data_module_res 2]
    set vo_module_ports_list [split $vo_module_ports_str "\n"]
    set vo_module_ports_list [lmap elem $vo_module_ports_list {string trim [string trim $elem] ","}]
    set vo_module_ports_list [lsearch -all -inline -not $vo_module_ports_list ""]



    set found_module 0
    while {$found_module == 0} {
        puts2 "Reading emulator.v..."
        set ev_file_fd [open "emulator/emulator.v" "r"]
        set ev_data [read $ev_file_fd]
        close $ev_file_fd

        puts2 "Extracting emulated module name..."
        set found_module [regexp -lineanchor -indices "^(\\w+?)\\s+dut\\s*\\(.*?\\);" $ev_data ev_dut_rng ev_dut_name_rng]
        if {$found_module == 0} {
            puts2 "######################################################"
            puts2 "Unexpected format of ([pwd]/emulator/emulator.v)"
            puts2 "Not found any module instance named \"dut\"!"
            puts2 "Insert any instance named \"dut\" (e.g. \"DUT dut();\") inside EMULATOR module in emulator/emulator.v"
            puts2 "######################################################"
            puts2 "Press enter to retry..."
            gets stdin
        }
    }

    set ev_dut_name [string range $ev_data [lindex $ev_dut_name_rng 0] [lindex $ev_dut_name_rng 1]]

    if {$ev_dut_name!=$vo_module_name && !$force_override} {
        puts2 "######################################################"
        puts2 "Found instance of type \"$ev_dut_name\", but top-level is \"$vo_module_name\""
        puts2 "Replace in manually or type \"a\" to do it automatically: "
        gets stdin char
        if { $char == "a" || $char == "A" } {
            set force_override 1
        }
    }

    if {$force_override} {
        puts2 "######################################################"
        puts2 "Overriding emulated module inside [pwd]/emulator/emulator.v"
        puts2 "######################################################"
        
        puts2 "Generating new module instance..."
        set ports [lmap port_name $vo_module_ports_list {get_port_line_from_name $port_name}]
        set ports_str [join $ports ",\n"]
        set new_module_inst "$vo_module_name dut(\n$ports_str\n);"
        set new_ev_data [string replace $ev_data [lindex $ev_dut_rng 0] [lindex $ev_dut_rng 1] $new_module_inst]

        puts2 "Overwriting emulator.v..."
        set ev_file_fd [open "emulator/emulator.v" "w"]
        puts -nonewline $ev_file_fd $new_ev_data
        close $ev_file_fd
        
        puts2 "######################################################"
        puts2 "Overwriting [pwd]/emulator/emulator.v completed:"
        puts2 $new_module_inst
        puts2 "Check if all ports are connected correctly (my program has to guess it based on ports' names)"
        puts2 "######################################################"
        puts2 "Press enter to continue..."
        gets stdin
    }


    # puts2 $vo_module_name
    # puts2 $vo_module_ports_list
    # puts2 [llength $vo_module_ports_list]
    # puts2 $ev_dut_rng
    # puts2 $ev_dut_name_rng
    # puts2 $ev_dut_name
    # puts2 $ports_str
    # puts2 $new_module_inst

}

proc guess_wire_from_port_name {port_name} {
    switch -nocase -regexp -matchvar D $port_name {
        "^SW.*(\\d)"   {return "SW\[[lindex $D 1]\]"}
        "^KEY.*(\\d)"  {return "KEY\[[lindex $D 1]\]"}
        "^BTN.*(\\d)"  {return "KEY\[[lindex $D 1]\]"}
        "^LED.*(\\d)"  {return "LED\[[lindex $D 1]\]"}
        "^SW.*"        {return "SW"}
        "^KEY.*"       {return "KEY"}
        "^BTN.*"       {return "KEY"}
        "^LED.*"       {return "LED"}
        "^HEX.*(\\d)"  {return "HEX[lindex $D 1]"}
        "^SEG.*(\\d)"  {return "HEX[lindex $D 1]"}
        default        {return ""}
    }
}

proc get_port_line_from_name {port_name} {
    return "\t.$port_name\([guess_wire_from_port_name $port_name]\)"
}

if {!$DO_SIMPLE && !$DO_SIMPLEF && !$DO_QUARTUS} {
    puts2 "###############################"
    puts2 "No emulation type specified (use -s, -S or -q)"
    set DO_QUARTUS [llength [glob -nocomplain "*.qpf"]]
    set DO_SIMPLE [expr !$DO_QUARTUS]
}

if {$DO_SIMPLE} {
    puts2 "###############################"
    puts2 "  Preparing Simple Emulation"
    puts2 "###############################"
    puts2 "######### Compiling all *.v files in current directory ([pwd])... ############"
    if { [catch {exec "vlog" "*.v" "emulator/emulator.v" >@stdout 2>@stderr <@stdin}] } {
        puts2 "######### Compilation Error - Aborting... ############"
        exit
    }
    puts2 "######### Optimizing... ############"
    if { [catch {exec vopt +acc EMULATOR -o emulator_opt >@stdout 2>@stderr <@stdin}] } {
        puts2 "######### Optimization Error - Aborting... ############"
        exit
    }
}
if {$DO_SIMPLE || $DO_SIMPLEF} {
    puts2 "###############################"
    puts2 "      Starting Emulation"
    puts2 "###############################"
    catch {exec vsim -c emulator_opt -do emulator/emulator.do >@stdout 2>@stderr <@stdin}
}


if {$DO_QUARTUS} {
    puts2 "###############################"
    puts2 "   Preparing Quartus Script"
    puts2 "###############################"
    set do_files [glob -nocomplain "simulation/modelsim/*_gate_*.do"]
    if {[llength $do_files] == 0} {
        puts2 "Not found gate-level simulation script inside ([pwd]/simulation) directory"
        puts2 "Be sure to correctly set up quartus simulation, by running Gate-Level Simulation for (corectly configured) testbench \"EMULATOR\""
        puts2 "######### Preparing Script Failed - Aborting... ############"
        exit
    }
    puts2 "######### Preparing .do simulation file ############"
    if { [catch {
        puts2 "Reading simulation script..."
        set do_file [lindex $do_files 0]
        set do_file_fd [open $do_file "r"]
        set do_file_data [read $do_file_fd]
        close $do_file_fd
        puts2 "Modifying simulation script..."
        set do_file_data [string map {"run -all" "do ../../emulator/emulator.do ../../emulator "} $do_file_data]
        puts2 "Overriding simulation script..."
        set do_file_fd [open $do_file "w"]
        puts -nonewline $do_file_fd $do_file_data
        close $do_file_fd
    }] } {
        puts2 "######### Filesystem Error - Aborting... ############"
        exit
    }

    if {!$NOFORCE_REP} {
        puts2 "######### Preparing top_level module inside emulator.v file ############"
        if { [catch {
            prepare_dut_instance $FORCE_REP
        }] } {
            puts2 "######### Unexpected Error - Aborting... ############"
            exit
        }
    }

    puts2 "###############################"
    puts2 "      Starting Emulation"
    puts2 "###############################"
    cd "simulation/modelsim"
    catch {exec vsim -c -do [file tail $do_files] >@stdout 2>@stderr <@stdin}
}
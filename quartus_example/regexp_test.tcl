

proc prepare_dut_instance {force_override} {
    set vo_files [glob -nocomplain "simulation/modelsim/*.vo"]
    if {[llength $vo_files] == 0} {
        puts "######################################################"
        puts "Precompiled top-level module ([pwd]/simulation/modelsim/*.vo) not found."
        puts "If you had run Netlist Writer, than create the instantiation inside emulator/emulator.v manualy"
        puts "######################################################"
        puts "Press enter to continue..."
        gets stdin
        return 0
    }

    puts "Reading top-level module verilog template..."
    set vo_file [lindex $vo_files 0]
    set vo_file_fd [open $vo_file "r"]
    set vo_data [read $vo_file_fd]
    close $vo_file_fd

    set vo_data_module_res [regexp -lineanchor -inline "^module (\\S+?) \\((.*?)\\);$" $vo_data]

    if {[llength $vo_data_module_res] != 3} {
        puts "######################################################"
        puts "Unexpected format of ([pwd]/simulation/modelsim/*.vo)"
        puts "Please create the instantiation inside emulator/emulator.v manualy"
        puts "######################################################"
        puts "Press enter to continue..."
        gets stdin
        return 0;
    }
    
    puts "Extracting top-level name and ports..."
    set vo_module_name       [lindex $vo_data_module_res 1]
    set vo_module_ports_str  [lindex $vo_data_module_res 2]
    set vo_module_ports_list [split $vo_module_ports_str "\n"]
    set vo_module_ports_list [lmap elem $vo_module_ports_list {string trim [string trim $elem] ","}]
    set vo_module_ports_list [lsearch -all -inline -not $vo_module_ports_list ""]



    set found_module 0
    while {$found_module == 0} {
        puts "Reading emulator.v..."
        set ev_file_fd [open "emulator/emulator.v" "r"]
        set ev_data [read $ev_file_fd]
        close $ev_file_fd

        puts "Extracting emulated module name..."
        set found_module [regexp -lineanchor -indices "^(\\w+?)\\s+dut\\s*\\(.*?\\);" $ev_data ev_dut_rng ev_dut_name_rng]
        if {$found_module == 0} {
            puts "######################################################"
            puts "Unexpected format of ([pwd]/emulator/emulator.v)"
            puts "Not found any module instance named \"dut\"!"
            puts "Insert any instance named \"dut\" (e.g. \"DUT dut();\") inside EMULATOR module in emulator/emulator.v"
            puts "######################################################"
            puts "Press enter to retry..."
            gets stdin
        }
    }

    set ev_dut_name [string range $ev_data [lindex $ev_dut_name_rng 0] [lindex $ev_dut_name_rng 1]]

    if {$ev_dut_name!=$vo_module_name && !$force_override} {
        puts "######################################################"
        puts "Found instance of type \"$ev_dut_name\", but top-level is \"$vo_module_name\""
        puts "Replace in manually or input \"y\" to do it automatically: "
        gets stdin char
        if { $char == "y" || $char == "Y" } {
            set force_override 1
        }
    }

    if {$force_override} {
        puts "######################################################"
        puts "Overriding emulated module inside [pwd]/emulator/emulator.v"
        puts "######################################################"
        
        puts "Generating new module instance..."
        set ports [lmap port_name $vo_module_ports_list {get_port_line_from_name $port_name}]
        set ports_str [join $ports ",\n"]
        set new_module_inst "$vo_module_name dut(\n$ports_str\n);"
        set new_ev_data [string replace $ev_data [lindex $ev_dut_rng 0] [lindex $ev_dut_rng 1] $new_module_inst]

        puts "Overwriting emulator.v..."
        set ev_file_fd [open "emulator/emulator.v" "w"]
        puts -nonewline $ev_file_fd $new_ev_data
        close $ev_file_fd
        
        puts "######################################################"
        puts "Overwriting [pwd]/emulator/emulator.v completed:"
        puts $new_module_inst
        puts "Check if all ports are connected correctly (my program has to guess it based on ports' names)"
        puts "######################################################"
        puts "Press enter to continue..."
        gets stdin
    }


    # puts $vo_module_name
    # puts $vo_module_ports_list
    # puts [llength $vo_module_ports_list]
    # puts $ev_dut_rng
    # puts $ev_dut_name_rng
    # puts $ev_dut_name
    # puts $ports_str
    # puts $new_module_inst

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

prepare_dut_instance 0


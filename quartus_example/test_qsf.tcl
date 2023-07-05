

# "set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation"
# "set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH EMULATOR -section_id eda_simulation"

# "set_global_assignment -name EDA_LAUNCH_CMD_LINE_TOOL ON -section_id eda_simulation"
# "set_global_assignment -name EDA_NATIVELINK_GENERATE_SCRIPT_ONLY ON -section_id eda_simulation"

# "set_global_assignment -name EDA_TEST_BENCH_NAME EMULATOR -section_id eda_simulation"
# "set_global_assignment -name EDA_DESIGN_INSTANCE_NAME NA -section_id EMULATOR"
# "set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME EMULATOR -section_id EMULATOR"

# "set_global_assignment -name EDA_TEST_BENCH_FILE emulator/emulator.v -section_id EMULATOR"

proc puts2 {data} {
    puts "\[EMU\] $data"
}


###############

proc find_in_qsf_and_replace {qsf name value} {
    set found_ops [regexp -lineanchor -indices -linestop "^set_global_assignment\\s+-name\\s+$name.*?$" $qsf ops]
    set replacement "set_global_assignment -name $name $value"
    if {$found_ops} {
        # puts $ops
        set res [string replace $qsf [lindex $ops 0] [lindex $ops 1] "$replacement"]
    } else {
        # puts "No Ops"
        set res [string cat $qsf "\n$replacement"]
    }
    return $res
}
proc find_in_qsf_or_add {qsf value} {
    set replacement "set_global_assignment -name $value"
    set value [string map {" " "\\s+"} $value]
    set found_ops [regexp -lineanchor -indices -linestop "^set_global_assignment\\s+-name\\s+$value\\s*?$" $qsf ops]
    if {$found_ops} {
        # puts "Found"
        # puts $ops
        return $qsf
    } else {
        # puts "No Ops"
        set res [string cat $qsf "\n$replacement"]
        return $res
    }
}

proc prepare_qsf {} {
    
    set qsf_files [glob -nocomplain "*.qsf"]
    if {[llength $qsf_files] != 1} {
        puts2 "######################################################"
        puts2 "Found [expr {([llength $qsf_files] == 0) ? "none" : "multiple"}] qsf files inside ([pwd]) directory"
        puts2 "Unable to check/prepare qsf file"
        puts2 "Prepare the quartus project manually."
        puts2 "######################################################"
        puts2 "Press enter to continue..."
        gets stdin
        return 0
    }
    puts2 "######### Preparing project settings file ############"
    if { [catch {
        puts2 "Reading settings file..."
        set qsf_file [lindex $qsf_files 0]
        set qsf_file_fd [open $qsf_file "r"]
        set qsf_file_data [read $qsf_file_fd]
        close $qsf_file_fd


        set new_qsf [find_in_qsf_and_replace $qsf_file_data "EDA_TEST_BENCH_ENABLE_STATUS" "TEST_BENCH_MODE -section_id eda_simulation"]
        set new_qsf [find_in_qsf_and_replace $new_qsf "EDA_NATIVELINK_SIMULATION_TEST_BENCH" "EMULATOR -section_id eda_simulation"]
        
        set new_qsf [find_in_qsf_and_replace $new_qsf "EDA_LAUNCH_CMD_LINE_TOOL" "ON -section_id eda_simulation"]
        set new_qsf [find_in_qsf_and_replace $new_qsf "EDA_NATIVELINK_GENERATE_SCRIPT_ONLY" "ON -section_id eda_simulation"]

        set new_qsf [find_in_qsf_or_add $new_qsf "EDA_TEST_BENCH_NAME EMULATOR -section_id eda_simulation"]
        set new_qsf [find_in_qsf_or_add $new_qsf "EDA_DESIGN_INSTANCE_NAME NA -section_id EMULATOR"]
        set new_qsf [find_in_qsf_or_add $new_qsf "EDA_TEST_BENCH_MODULE_NAME EMULATOR -section_id EMULATOR"]
        set new_qsf [find_in_qsf_or_add $new_qsf "EDA_TEST_BENCH_FILE emulator/emulator.v -section_id EMULATOR"]

        set changed [expr {$new_qsf != $qsf_file_data}]

        if {$changed} {
            puts2 "Creating backup file..."
            set qsf_file_bak_fd [open "$qsf_file.emulator.bak" "w"]
            puts -nonewline $qsf_file_bak_fd $qsf_file_data
            close $qsf_file_bak_fd
            puts2 "Overwriting settings file..."
            set qsf_file_fd [open $qsf_file "w"]
            puts -nonewline $qsf_file_fd $new_qsf
            close $qsf_file_fd
            puts2 "Success."
            return 2
        } else {
            puts2 "Settings file is already prepared."
            return 1
        }

    }] } {
        puts2 "######################################################"
        puts2 "Filesystem Error during qsf file preparing..."
        puts2 "Prepare the quartus project manually."
        puts2 "######################################################"
        puts2 "Press enter to continue..."
        gets stdin
        return 0
    }
}

prepare_qsf


# puts2 "---------------------"
# puts  [find_in_qsf_and_replace "sdfgsg\nafsdf" "EDA_TEST_BENCH_NAME" "aha"]
# puts2 "---------------------"
# puts  [find_in_qsf_and_replace "" "EDA_TEST_BENCH_NAME" "aha"]
# puts2 "---------------------"
# puts  [find_in_qsf_and_replace "set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation" "EDA_TEST_BENCH_NAME" "aha"]
# puts2 "---------------------"
# puts  [find_in_qsf_and_replace "set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation\nset_global_assignment -name EDA_TEST_BENCH_NAME EMULATOR -section_id eda_simulation\nsgdfgdfg" "EDA_TEST_BENCH_NAME" "aha"]
# puts2 "---------------------"
# puts  [find_in_qsf_and_replace "" "EDA_NATIVELINK_SIMULATION_TEST_BENCH" "aha"]
# puts2 "---------------------"



# puts2 "---------------------"
# puts  [find_in_qsf_or_add "sdfgsg\nafsdf" "EDA_TEST_BENCH_NAME EMULATOR -section_id eda_simulation"]
# puts2 "---------------------"
# puts  [find_in_qsf_or_add "" "EDA_TEST_BENCH_NAME EMULATOR -section_id eda_simulation"]
# puts2 "---------------------"
# puts  [find_in_qsf_or_add "set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation" "EDA_TEST_BENCH_NAME EMULATOR -section_id eda_simulation"]
# puts2 "---------------------"
# puts  [find_in_qsf_or_add "set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation\nset_global_assignment -name EDA_TEST_BENCH_NAME EMULATOR -section_id eda_simulation\nsgdfgdfg" "EDA_TEST_BENCH_NAME EMULATOR -section_id eda_simulation"]
# puts2 "---------------------"
# puts  [find_in_qsf_or_add "" "EDA_NATIVELINK_SIMULATION_TEST_BENCH EMULATOR"]
# puts2 "---------------------"
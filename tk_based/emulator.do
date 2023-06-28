
####### CONFIG ############

set RUN_FOR      10
set IO_INTERVAL  1000

###########################

set stdin_len -1

set gui [open "| tclsh emulator_gui.tcl 2>@stdout" "r+"]
chan configure stdin -blocking 0
chan configure $gui  -blocking 0

while {$stdin_len == -1} {

    # run $RUN_FOR ns
    # set new_output [call EMULATOR.update_state $new_input]

    # puts $gui "o $new_output"
    puts $gui "test"
    flush $gui
    
    after $IO_INTERVAL
    
    while {[gets $gui gui_cmd] >= 0} {
        switch [string index $gui_cmd 0] {
            q {
                close $gui
                exit
            }
            i {
                puts stdout "New input: $gui_cmd"
            }
        }
    }

    set stdin_len [gets stdin stdin_line]
}


close $gui
exit
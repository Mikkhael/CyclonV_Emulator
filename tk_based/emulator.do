
####### CONFIG ############

set RUN_FOR      30
set IO_INTERVAL  10

set RUN          1

###########################

set stdin_len -1
set new_input 11110000000000
set t0 0
set t1 0
set td 0

set gui [open "| tclsh emulator_gui.tcl 2>@stdout" "r+"]
chan configure stdin -blocking 0
chan configure $gui  -blocking 0

puts $gui "c $RUN $RUN_FOR $IO_INTERVAL"
flush $gui

while {$stdin_len == -1} {

    if {$RUN} {
        set t0 [clock milliseconds]
        run $RUN_FOR ns
        set t1 [clock milliseconds]
        set td [expr $t1-$t0]
        set new_output [call EMULATOR.update_state $new_input]
        puts $gui "o$new_output"
        puts $gui "t$td"
        flush $gui
    }
    
    after $IO_INTERVAL
    
    while {[gets $gui gui_cmd] >= 0} {
        switch [string index $gui_cmd 0] {
            q {
                catch { puts $gui "q"; flush $gui }
                close $gui
                exit
            }
            i {
                set new_input [string range $gui_cmd 1 end]
                # puts stdout "New input: $new_input"
            }
            c {
                set args [split $gui_cmd " "]
                puts stdout "New Configuration: $args"
                flush stdout
                lassign $args _ RUN RUN_FOR IO_INTERVAL
            }
        }
    }

    set stdin_len [gets stdin stdin_line]
}


catch { puts $gui "q"; flush $gui }
close $gui
exit
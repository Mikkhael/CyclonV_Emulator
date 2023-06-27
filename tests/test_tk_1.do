# == CONFIG =======================

set IO_INTERVAL 100

# =================================


set gui [open "| tclsh test_tk_2.do 2>@stdout" "r+"]

chan configure stdin -blocking 0
chan configure $gui  -blocking 0

while {1} {
    set len [gets stdin cmd]

    if {$len > 0} {
        if {$cmd == "q" || $cmd == "quit" || $cmd == "exit"} {
            puts $gui "q"
            flush $gui
            break
        } else {
            puts "GOT: $cmd"
            puts $gui $cmd
            flush $gui
        }
    }
    
    set gui_len [gets $gui gui_cmd]
    if {$gui_len > 0} {
        puts stdout "RECEIVED($gui_len): $gui_cmd"
    }

    after $IO_INTERVAL
}

close $gui
exit
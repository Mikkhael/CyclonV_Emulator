package require Tk
set END 0
wm protocol . WM_DELETE_WINDOW {
    set END 1
}

pack [frame .frm1]
pack [frame .frm2]
pack [frame .leds]
pack [frame .btns]

label .leds.led1 -width 1 -height 1 -bg "red"
label .leds.led2 -width 1 -height 1 -bg "grey"

set BTNS_STATE [list 0 0 0 0]

proc create_btn {id text} {
    label .btns.btn$id -width 3 -height 1 -bg "grey" -text $text
    bind  .btns.btn$id <ButtonPress> [subst {
        .btns.btn$id configure -bg "green"
        puts stdout "BTN$id on"
        flush stdout
    }]
    bind  .btns.btn$id <ButtonRelease> [subst {
        .btns.btn$id configure -bg "grey"
        puts stdout "BTN$id off"
        flush stdout
    }]
    bind . <KeyPress-$text> [subst -nocommands {
        if {[lindex \$BTNS_STATE $id] == 0} {
            lset BTNS_STATE $id 1
            .btns.btn$id configure -bg "green"
            puts stdout "K BTN$id on"
            flush stdout
        }
    }]
    bind . <KeyRelease-$text> [subst {
        lset BTNS_STATE $id 0
        .btns.btn$id configure -bg "grey"
        puts stdout "K BTN$id off"
        flush stdout
    }]
    pack .btns.btn$id -side left -padx 3
}

label .frm2.txt1 -text jsdoifgs
label .frm2.txt2 -text sjdiug

set ent_val "krzeslo"
entry  .frm1.ent -textvariable ent_val -width 100
button .frm1.btn -text "Send" -command {
    puts  stdout $ent_val
    flush stdout
}


# grid .ent -column 1 -row 1
# grid .btn -column 2 -row 1
# grid [label .txt1 -text jsdoifgs] -column 1 -row 2
# grid [label .txt2 -text sjdiug] -column 2 -row 2
pack .frm1.ent  -side left
pack .frm1.btn  -side left
pack .frm2.txt1 -side left
pack .frm2.txt2 -side left
pack .leds.led1 -side left -padx 3
pack .leds.led2 -side left -padx 3
create_btn 0 "a"
create_btn 1 "s"
create_btn 2 "d"


set stdin_handler {
    set len [gets stdin data]
    # puts stdout "GOT($len): $data"
    # flush stdout
    set ent_val $data
    if {$data == "q"} {
        set END 1
    } elseif {$data == "terr"} {
        puts stdout "TEST ERROR"
        flush stdout
        puts stderr "TEST ERROR"
        flush stderr
    } elseif {$data == "err"} {
        puts stdout "REAL ERROR"
        flush stdout
        jdsuiogjhf
    }
}

chan event stdin readable {
    set err_code [catch $stdin_handler err_msg]
    if {$err_code} {
        puts stderr $err_msg
        flush stderr
        set END 1
    }
}

vwait END

puts stdout "q"
flush stdout
exit

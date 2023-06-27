package require Tk
set END 0

set ent_val "krzeslo"


entry  .ent -textvariable ent_val -width 100
button .btn -text "Send" -command {
    puts  stdout $ent_val
    flush stdout
}

pack .ent
pack .btn


chan event stdin readable {
    set len [gets stdin data]
    # puts stdout "GOT($len): $data"
    # flush stdout
    set ent_val $data
    if {$data == "q"} {
        set END 1
    }
}

# TODO wait for window close event
vwait END
exit

### CONFIG ############
set KEY_bindings {a s d f}
set SW_bindings  {q w e r t y u i o p}

set COLOR_KEY_OFF "grey30"
set COLOR_KEY_ON  "green"
set COLOR_SW_OFF  "grey65"
set COLOR_SW_ON   "grey45"

set COLOR_LED_OFF "black"
set COLOR_LED_ON  "red"

set SEG_L 40
set SEG_W 7

set SEG_COORDS [subst {
    {[expr 0]             [expr 0]                 [expr $SEG_L] [expr $SEG_W]            }
    {[expr $SEG_L-$SEG_W] [expr $SEG_W]            [expr $SEG_L] [expr $SEG_W+$SEG_L]     }
    {[expr $SEG_L-$SEG_W] [expr $SEG_L+$SEG_W*2]   [expr $SEG_L] [expr $SEG_L*2+$SEG_W*2] }
    {[expr 0]             [expr $SEG_L*2+$SEG_W*2] [expr $SEG_L] [expr $SEG_L*2+$SEG_W*3] }
    {[expr 0]             [expr $SEG_L+$SEG_W*2]   [expr $SEG_W] [expr $SEG_L*2+$SEG_W*2] }
    {[expr 0]             [expr $SEG_W]            [expr $SEG_W] [expr $SEG_W+$SEG_L]     }
    {[expr 0]             [expr $SEG_L+$SEG_W]     [expr $SEG_L] [expr $SEG_L+$SEG_W*2]   }
}]
set SEG_H [expr $SEG_L*2+$SEG_W*3]
set SEG_W [expr $SEG_L]
#######################

package require Tk
set END 0
wm protocol . WM_DELETE_WINDOW {
    set END 1
}

proc putf {channel value} {
    puts $channel $value
    flush $channel
}

### GUI State #################

set INPUT_STATE [list 1 1 1 1 0 0 0 0 0 0 0 0 0 0]

proc get_key_handler {name id state bg} {
    return [subst -nocommands {
        if {[lindex \$INPUT_STATE 3-$id] != $state} {
            lset INPUT_STATE 3-$id $state
            # putf stdout "$name -> $state"
            $name configure -bg $bg
            send_input_state_cmd
        }
    }]
}

proc get_sw_handler {name id} {
    return [subst -nocommands {
        if [lindex \$INPUT_STATE end-$id] {
            lset INPUT_STATE end-$id 0
            # putf stdout "$name -> 0"
            $name.u configure -bg \$COLOR_SW_OFF
            $name.d configure -bg \$COLOR_SW_ON
        } else {
            lset INPUT_STATE end-$id 1
            # putf stdout "$name -> 1"
            $name.u configure -bg \$COLOR_SW_ON
            $name.d configure -bg \$COLOR_SW_OFF
        }
        send_input_state_cmd
    }]
}

proc set_led {id state} {
    global COLOR_LED_OFF COLOR_LED_ON
    if {$state == 1} {
        .frame_led.led$id configure -bg $COLOR_LED_ON
    } else {
        .frame_led.led$id configure -bg $COLOR_LED_OFF
    }
}

proc set_hex_seg {id sub_id state} {
    global COLOR_LED_OFF COLOR_LED_ON
    if {$state == 0} {
        .frame_hex.hex$id itemconfigure $sub_id -fill $COLOR_LED_ON
    } else {
        .frame_hex.hex$id itemconfigure $sub_id -fill $COLOR_LED_OFF
    }
}

proc set_hexs_from_str {str} {
    for {set i 0} {$i < 6} {incr i} {
        set off [expr 9+$i*7]
        for {set j 1} {$j <= 7} {incr j} {
            set_hex_seg $i $j [string index $str end-[expr $j+$off]]
        }
    }
}

proc handle_output_state_cmd {cmd} {
    for {set i 0} {$i < 10} {incr i} {
        set_led $i [string index $cmd end-$i]
    }
    set_hexs_from_str $cmd
}


proc send_input_state_cmd {} {
    global INPUT_STATE
    putf stdout "i[join $INPUT_STATE ""]"
}

### GUI Setup ###############

grid [frame .frame_hex -background "grey90"] -column 1 -row 1 -columnspan 2
grid [frame .frame_led -background "grey90"] -column 1 -row 2
grid [frame .frame_sw  -background "grey90"] -column 1 -row 3
grid [frame .frame_key -background "grey90"] -column 2 -row 2 -rowspan 2
grid [frame .frame_cnf] -column 1 -row 4 -columnspan 2

set CNF_RUN 0
set CNF_RUN_FOR 0
set CNF_IO_INTERVAL 0
set LAST_ITERATION_TIME 0

grid [label .frame_cnf.txt0 -text "ON/OFF:"]                   -column 1 -row 1
grid [checkbutton .frame_cnf.ent0 -variable CNF_RUN ]          -column 2 -row 1
grid [label .frame_cnf.txt1 -text "Steps per iteration:"]      -column 1 -row 2
grid [entry .frame_cnf.ent1 -textvariable CNF_RUN_FOR ]        -column 2 -row 2
grid [label .frame_cnf.txt2 -text "Iteration interval (ms):"]  -column 1 -row 3
grid [entry .frame_cnf.ent2 -textvariable CNF_IO_INTERVAL ]    -column 2 -row 3
grid [label .frame_cnf.txt3 -text "Last iteration time (ms):"] -column 1 -row 4
grid [label .frame_cnf.ent3 -textvariable LAST_ITERATION_TIME] -column 2 -row 4

grid [button .frame_cnf.btn -text "Update Configuration" -command {update_conf}] -column 3 -row 1 -rowspan 3 -padx 30

proc update_conf {} {
    global CNF_RUN CNF_RUN_FOR CNF_IO_INTERVAL
    putf stdout "c $CNF_RUN $CNF_RUN_FOR $CNF_IO_INTERVAL"
}

proc create_hex {id} {
    global SEG_H SEG_W SEG_COORDS COLOR_LED_OFF
    set name ".frame_hex.hex$id"
    canvas $name  -width $SEG_W -height $SEG_H -bg "black"
    set i 0
    foreach coord $SEG_COORDS {
        $name create rectangle [lmap x $coord {expr $x+2}] -fill $COLOR_LED_OFF -outline ""
        incr i
    }
    pack $name -side right
}

proc create_led {id} {
    global COLOR_LED_OFF
    set name ".frame_led.led$id"
    label $name -text $id -width 2 -bg $COLOR_LED_OFF
    pack  $name -side right -padx 2 -pady 2
}

proc create_sw {id keycode} {
    global COLOR_SW_OFF COLOR_SW_ON
    set name ".frame_sw.sw$id"
    pack [frame $name -width 2] -side right -padx 2 -pady 2
    pack [label $name.u -width 2 -height 1 -bg $COLOR_SW_OFF -cursor hand2]
    pack [label $name.d -width 2 -height 1 -bg $COLOR_SW_ON  -cursor hand2 -text $keycode]
    bind .       <KeyRelease-$keycode> [get_sw_handler $name $id]
    bind $name.u <ButtonPress>         [get_sw_handler $name $id]
    bind $name.d <ButtonPress>         [get_sw_handler $name $id]
}

proc create_key {id keycode} {
    global COLOR_KEY_OFF COLOR_KEY_ON
    set name ".frame_key.key$id"
    label $name -text $keycode -width 4 -height 2 -bg $COLOR_KEY_OFF -cursor hand2
    pack  $name -side right -padx 2 -pady 2
    bind .     <KeyPress-$keycode>   [get_key_handler $name $id 0 $COLOR_KEY_ON]
    bind .     <KeyRelease-$keycode> [get_key_handler $name $id 1 $COLOR_KEY_OFF]
    bind $name <ButtonPress>         [get_key_handler $name $id 0 $COLOR_KEY_ON]
    bind $name <ButtonRelease>       [get_key_handler $name $id 1 $COLOR_KEY_OFF]
}

for {set i 0} {$i < 10} {incr i} {
    create_led $i
    create_sw  $i [lindex $SW_bindings end-$i]
}
for {set i 0} {$i < 6} {incr i} {
    create_hex $i
}
for {set i 0} {$i < 4} {incr i} {
    create_key $i [lindex $KEY_bindings end-$i]
}


### STDIN Handlers #############

proc stdin_handler {} {
    global INPUT_STATE END CNF_RUN CNF_RUN_FOR CNF_IO_INTERVAL LAST_ITERATION_TIME
    set cmd_len [gets stdin cmd]
    switch [string index $cmd 0] {
        q { set END 1 }
        s { putf stdout "i$INPUT_STATE"}
        o { handle_output_state_cmd $cmd }
        h {
            set args [split $cmd " "]
            putf stdout "sARGS: $args"
            set_hex_seg [lindex $args 1] [lindex $args 2] [lindex $args 3]
        }
        c {
            set args [split $cmd " "]
            putf stdout "sARGS: $args"
            lassign $args _ CNF_RUN CNF_RUN_FOR CNF_IO_INTERVAL
        }
        t {
            set LAST_ITERATION_TIME [string range $cmd 1 end]
        }
    }
}

chan event stdin readable {
    set err_code [catch stdin_handler err_msg]
    if {$err_code} {
        putf stderr $err_msg
        set END 1
    }
}

### EXITING ####################

vwait END
catch {
    putf stdout "q"
}
exit

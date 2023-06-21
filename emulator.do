
####### CONFIG ############

set TCP_PORT         5001
set RUN_FOR          10
set UPDATE_INTERVAL  30

###########################

set stdin_len -1
set new_input_candidate "0"
set new_input "0"

set interface_socket [socket "localhost" $TCP_PORT]
chan configure $interface_socket -blocking 0
chan configure stdin -blocking 0

while {$stdin_len == -1} {

    run $RUN_FOR ns
    set new_output [call EMULATOR.update_state $new_input]

    puts $interface_socket $new_output
    flush $interface_socket
    
    after $UPDATE_INTERVAL
    
    set interface_socket_gets_len [gets $interface_socket new_input_candidate]
    if {$interface_socket_gets_len > 0} {
        set new_input $new_input_candidate
    }
    set stdin_len [gets stdin stdin_line]
}
exit
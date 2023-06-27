

chan configure stdin -blocking 0
set n 0
while {1} {
    set len [chan gets stdin value]
    if {$len > 0} {
        puts "R($n): $value"
        set n 0
        flush stdout
    } else {
        incr n
    }
    after 1000
    # puts "Tick\a"
}


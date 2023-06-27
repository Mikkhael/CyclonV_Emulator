
# transcript quietly

proc test id {
    return "[chan blocked $id] [chan eof $id] "
}
proc aha {child val} {
    puts $child $val
    puts "($val) TEST PUTS: [test $child]"
    flush $child
    puts "($val) TEST FLUSH: [test $child]"
    gets $child data
    puts "($val) TEST GATS: [test $child]"
    puts "$val -> $data"
}

# puts "\a"
after 1000

set child [open "| tclsh test2.do 2>@stderr 1>@stdout" "r+"]
gets stdin data
puts "Sending: $data"
aha $child $data
aha $child "aha"
after 100
aha $child "dnfuigfdg"

close $child
exit
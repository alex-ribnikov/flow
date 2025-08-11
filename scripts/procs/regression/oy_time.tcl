namespace eval ::ory_time {
    variable START
    variable CHECK         
}

proc ::ory_time::start {} {

    set ::ory_time::START [clock seconds]

}

proc ::ory_time::check {} {

    set ::ory_time::CHECK [clock seconds]
    
}

proc ::ory_time::from_start {} {

    return [expr {[clock seconds]-$::ory_time::START}]

}

proc ::ory_time::from_check {} {

    return [expr {[clock seconds]-$::ory_time::CHECK}]

}

proc ::ory_time::print { time_in_seconds } {

    return "[::ory_time::convert_seconds $time_in_seconds]"

}

proc ::ory_time::now { } {
    clock format [clock seconds] -format "%d/%m/%Y %T"
}

proc ::ory_time::convert_seconds { time_in_seconds } {
    set h [expr { $time_in_seconds/3600 }]
    incr time_in_seconds [expr {$h*-3600}]
    set m [expr {$time_in_seconds/60}]
    set s [expr {$time_in_seconds%60}]
    format "%02.2d:%02.2d:%02.2d" $h $m $s
}

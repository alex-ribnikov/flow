proc start_time {} {
  global set_start_time
  set set_start_time [clock seconds]
}
proc elapsed_time {} {
  global set_start_time
  set total_time [expr [clock seconds] - $set_start_time]
  set secs [expr $total_time % 60]
  set mins [expr ( ($total_time - $secs) / 60) % 60 ]
  set hours [expr ($total_time - ($mins + $secs)) / 3600]
  return "${hours}h:${mins}mn:${secs}s"
}

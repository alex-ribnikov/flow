proc userGetNetLengthByName {netName} {
        set wireLength 0
        dbForEachNetWire [dbGetNetByName $netName] segmentPtr {
                set segLength [dbWireLen $segmentPtr]
                set wireLength [expr $wireLength+$segLength]
         }
        set wireLengthInMicron [expr $wireLength*[dbHeadMicronPerDBU]]
        return $wireLengthInMicron
}

proc findViolatingPath {maxLength reportName} {
         set maxlength_control $maxLength
         set x [ get_nets -hier * ]
         set f1 [ open $reportName ??w?? ]
         foreach_in_collection x1 $x {
                    set name [ get_object_name $x1 ]
                    set flag1 [ dbIsNetClock $name ]
                    set flag2 [ dbIsNetPwrOrGnd $name ]
                     if { $flag1 == 0 && $flag2 == 0 } {
                                  set length [ userGetNetLengthByName $name ]
                                  if { $length > $maxlength_control } {
                                            puts $f1 $name
                                   }
                     }
         }
        close $f1
}

proc fixLongNets {minLength bufName} {
  set of [open long_nets.rpt w]
  setEcoMode -updateTiming false -refinePlace false
  set count 0
  foreach net [dbGet top.nets] {
    if {[dbGet $net.numTerms] != 2} { continue }
    if {[dbGet $net.rule] != 0x0} { continue }
    if {[dbGet $net.isPwrOrGnd]} { continue }
    if {[dbGet $net.isCTSClock]} { continue }
    if {[dbGet $net.isClock]} { continue }
    if {[dbGet $net.isPhysOnly]} { continue }
    if {[dbGet $net.skipRouting]} { continue }
    set totalLength 0
    foreach wire [dbGet $net.wires] {
      if {$wire == 0x0} {continue}
      set length [dbWireLen $wire]
      set totalLength [expr $totalLength + $length]
    }
    set totalLength [dbu2uu $totalLength]
    if {$totalLength > $minLength} {
      puts $of "$totalLength [dbGet $net.name]"
      set netName [dbGet $net.name]
      regsub {\{} $netName "" netName
      regsub {\}} $netName "" netName
      ecoAddRepeater -net $netName -cell $bufName -relativeDistToSink 0.5
      incr count
    }
  }
  close $of
  Puts "dumped a total of $count nets to file long_nets.rpt"
}

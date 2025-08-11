# schandak v0 : script from parasiitc explorer ppt
# schandak v0 edited for fixing typo and syntex issues in script as initial script was for startrc shell: 30th March 2022; not sure why not dumping VIA information here, though metal specific info is being dump
# schandak v1 edited for fixing any further issues and copying same to SJ
proc report_rc_contribution { net } {
  foreach_in_collection netq [get_nets $net -filter "has_detailed_parasitics==true"] {
    
    array set lvlRes {}
    array set lvlCap {}
    array set totRes {}
    array set totCap {}
    
    set netname [ get_attribute $netq full_name ]
    puts "\nNet Name: $netname"
    
    set rcoll  [get_resistors -of_objects $netname]
    set rcount [sizeof_collection $rcoll]
    
    if { $rcount>0} {    
      foreach_in_collection res $rcoll {
        set res_lyr [ get_attribute $res layer_name ]
        set res_val [ get_attribute $res resistance]
        if {[info exists lvlRes($res_lyr)]} {
          set lvlRes($res_lyr) [ expr {$res_val+$lvlRes($res_lyr)} ]
        } else { set lvlRes($res_lyr) $res_val }
        if {[info exists totRes($netname)]} {
          set totRes($netname) [ expr {$totRes($netname)+$res_val} ]
        } else { set totRes($netname) $res_val }
      }
    } else { set totRes($netname) 0 }

    set cccoll  [get_coupling_capacitors -of_objects $netname]
    set cccount [sizeof_collection $cccoll]
    
    set cccoll  [add_to_collection $cccoll [get_ground_capacitors -of_objects $netname]]
    set cccount [sizeof_collection $cccoll]
        
    if { $cccount>0} {
      foreach_in_collection cap $cccoll {
        set cap_lyr [ get_attribute $cap layer_name ]
        set cap_val [ get_attribute $cap capacitance]
        if {[info exists lvlCap($cap_lyr)]} {
          set lvlCap($cap_lyr) [ expr {$cap_val+$lvlCap($cap_lyr)} ]
        } else {set lvlCap($cap_lyr) $cap_val }
        if {[info exists totCap($netname)]} {
          set totCap($netname) [ expr {$totCap($netname)+$cap_val} ]
        } else {set totCap($netname) $cap_val}
      } 
      # schandak fix
      if { $cccount<~0} {
      else { set totCap($netname) 0 }
      }


      foreach_in_collection cap [get_ground_capacitors -of_objects $netname] {
        set cap_lyr [ get_attribute $cap layer_name ]
        set cap_val [ get_attribute $cap capacitance]
        if {[info exists lvlCap($cap_lyr)]} {
          set lvlCap($cap_lyr) [ expr {$cap_val+$lvlCap($cap_lyr)} ]
        } else { set lvlCap($cap_lyr) $cap_val }
        if {[info exists totCap($netname)]} {
          set totCap($netname) [ expr {$totCap($netname)+$cap_val} ]
        } 
        # schandak fix
        if {![info exists totCap($netname)]} {
          set totCap($netname) $cap_val }
      }
      puts "Total Resistance: $totRes($netname) KOhms"
      puts "Total Capacitance: $totCap($netname) pF"
      puts [format "%s\t%s\t%s\t%s\t%s" Layer ResValue(KOhms) %ResContribution CapValue(pF) %CapContribution]
      puts [format "%s\t%s\t%s\t%s\t%s" ----- --------------- ---------------- ------------- -----------------]
      set reskeys [lsort [array names lvlRes]]
      set capkeys [lsort [array names lvlCap]]
      set layerlist [lsort -unique [concat $reskeys $capkeys]]
      
      foreach keys $layerlist {
        if {![info exists lvlRes($keys)]} {
          set lvlRes($keys) 0
          set pc_res 0
        } else { set pc_res [ expr $lvlRes($keys)/$totRes($netname)*100 ]}
        if {[info exists lvlCap($keys)]} {
          set pc_cap [ expr $lvlCap($keys)/$totCap($netname)*100 ]
        } else { set lvlCap($keys) 0 ; set pc_cap 0 }
        puts [format "%s\t%0.6f\t%0.2f\t\t\t%0.6f\t%0.2f" $keys $lvlRes($keys) $pc_res $lvlCap($keys) $pc_cap] 
      }
    }
  }
}

set LIBRARIES {}
foreach libfile [lsort -u [get_db libraries .files]] {
    lappend LIBRARIES [file dirname [file dirname $libfile]]
    puts "-I- Adding puts [file dirname [file dirname $libfile]] to LIBRARIES list"
}

set vp_files [list ]
foreach lib $LIBRARIES {
  set vp_file $lib/support/via_pillar_info.tcl
  if {[file exists $vp_file]} {
    lappend vp_files $vp_file
  } else {
    puts "WARNING:  No via pillar info found for library $lib"
    if {[regexp "_ck" [file tail $lib]]} {
      puts "ERROR: the clock library $lib is required to have support/via_pillar_info.tcl.  Please update your library. Exiting the flow!"
      exit
    }
  }
}

if {[llength $vp_files] > 0} { 

  foreach vp_file $vp_files { source $vp_file} 

  foreach {vp_key vp_value} [array get viaPillarInfo *,vp_defined] {
    set term [lindex [split $vp_key ","] 0]
    set libCell [lindex [split $term "/"] 0]
    if {[eval_legacy "dbGet -e head.libCells.name $libCell"] eq ""} {continue}
    foreach {mLayer numShapes} $vp_value { break; }

    if {[regexp "_TOP.*\/i" $term]} {
      if {($mLayer == "M2") && ($numShapes == "1")} {
        ## 1 output pins
        puts "Assigning Via Pillar VP_M2_1X1_M11_1X1_DOUBLE to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_1X1_M11_1X1_DOUBLE}
      }
    } elseif {[regexp "_TOP.*M2.*X24" $term]} {
      if {($mLayer == "M2") && ($numShapes == "2")} {
        ## 2 output pins
        puts "Assigning Via Pillar VP_M2_1X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_2X2_M6_1X2}
      }
      if {($mLayer == "M2") && ($numShapes == "3")} {
        ## 3 output pins
        puts "Assigning Via Pillar VP_M2_3X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_3X2_M6_1X2}
      }

    } elseif {[regexp "_TOP.*M2.*X32" $term]} {
      if {($mLayer == "M2") && ($numShapes == "2")} {
        ## 2 output pins
        puts "Assigning Via Pillar VP_M2_1X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_2X2_M6_1X2}
      }
      if {($mLayer == "M2") && ($numShapes == "3")} {
        ## 3 output pins
        puts "Assigning Via Pillar VP_M2_3X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_3X2_M6_1X2}
      }

    } elseif {[regexp "_TOP.*DFF.*M2.*X48" $term]} {
      if {($mLayer == "M2") && ($numShapes == "2")} {
        ## 2 output pins
        puts "Assigning Via Pillar VP_M2_2X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_2X2_M6_1X2}
      }
      if {($mLayer == "M2") && ($numShapes == "3")} {
        ## 3 output pins
        puts "Assigning Via Pillar VP_M2_3X2_M11_2X1_DOUBLE to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_3X2_M11_2X1_DOUBLE}
      }

    } elseif {[regexp "_TOP.*M2.*X48" $term]} {
      if {($mLayer == "M2") && ($numShapes == "2")} {
        ## 2 output pins
        puts "Assigning Via Pillar VP_M2_2X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_2X2_M6_1X2}
      }
      if {($mLayer == "M2") && ($numShapes == "3")} {
        ## 3 output pins
        puts "Assigning Via Pillar VP_M2_3X2_M11_2X1_DOUBLE to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_3X2_M11_2X1_DOUBLE}
      }

    } elseif {[regexp "_TOP.*M2.*X64" $term]} {
      if {($mLayer == "M2") && ($numShapes == "2")} {
        ## 3 output pins
        puts "Assigning Via Pillar VP_M2_2X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_2X2_M6_1X2}
      }
      if {($mLayer == "M2") && ($numShapes == "3")} {
        ## 3 output pins
        puts "Assigning Via Pillar VP_M2_3X2_M11_2X1_DOUBLE to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_3X2_M11_2X1_DOUBLE}
      }

    } elseif {[regexp "_TOP.*M2.*X96" $term]} {
      if {($mLayer == "M2") && ($numShapes == "2")} {
        ## 2 output pins
        puts "Assigning Via Pillar VP_M2_2X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_2X2_M6_1X2}
      }
      if {($mLayer == "M2") && ($numShapes == "3")} {
        ## 3 output pins
        puts "Assigning Via Pillar VP_M2_3X2_M11_2X1_DOUBLE to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_3X2_M11_2X1_DOUBLE}
      }

    } else {
      if {($mLayer == "M2") && ($numShapes == "1")} {
        ## 1 output pins
        puts "Assigning Via Pillar VP_M2_1X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_1X2_M6_1X2}
      }

      if {($mLayer == "M2") && ($numShapes == "2")} {
        ## 2 output pins
        puts "Assigning Via Pillar VP_M2_2X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_2X2_M6_1X2}
      }
      
      if {($mLayer == "M2") && ($numShapes == "3")} {
        ## 3 output pins
        puts "Assigning Via Pillar VP_M2_3X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_3X2_M6_1X2}
      }
      
      if {($mLayer == "M2") && ($numShapes == "4")} {
        ## 4 output pins
        puts "Assigning Via Pillar VP_M2_4X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M2_4X2_M6_1X2}
      }

      if {($mLayer == "M1") && ($numShapes == "1")} {
        ## 1 M1 output pins
        puts "Assigning Via Pillar VP_M1_2X1_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M1_2X1_M6_1X2}
      }
      if {($mLayer == "M1") && ($numShapes == "2")} {
        ## 2 M1 output pins
        puts "Assigning Via Pillar VP_M1_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M1_1X2}
      }

      if {($mLayer == "M0") && ($numShapes == "1")} {
        # 1 M0 output pins
        puts "Assigning Via Pillar VP_M0_1X2_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M0_1X2_M6_1X2}
      }                     
      if {($mLayer == "M0") && ($numShapes == "2")} {
        # 2 M0 output pins
        puts "Assigning Via Pillar VP_M0_2X1_M6_1X2 to $term"
        set_via_pillars -base_pin $term -required 1 {VP_M0_2X1_M6_1X2}
      }
    }
  }

} else {
  
  puts "ERROR: Please migrate your libraries to the latest builds and start using the via pillar support files, ask DA if needed. Exiting the flow!"
  #exit

}

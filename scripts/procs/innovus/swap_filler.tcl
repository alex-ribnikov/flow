proc fix_implt_filler_viol {} {
   foreach MMM [get_db markers -if ".subtype == SPImpltAreaViolation && .objects == *FILL*"] {
      set X [expr [get_db $MMM .objects.bbox.ll.x] -0.01]
      set Y [expr ([get_db $MMM .objects.bbox.ur.y ] + [get_db $MMM .objects.bbox.ll.y]) /2]
      deselect_obj  -all
      set near_inst [gui_select -point "$X $Y"]
      if {[regexp FILL [get_db selected .name]] } {continue}
      
      regexp {F6(\S\S)} [get_db selected .base_cell.name ] match VT
      regsub {F6\S\S} [get_db $MMM .objects.base_cell.name ] "F6$VT" new_base_cell
             
   }
}



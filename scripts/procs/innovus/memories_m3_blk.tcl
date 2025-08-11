proc memories_m3_blk {} {
   set counter 0
   foreach MEMORY [get_db insts -if ".is_memory==true"] {
      set ORI [get_db $MEMORY .orient]
      set BBOX [get_db $MEMORY .bbox]
      if {$ORI == "r0" || $ORI == "mx"} {
         set NEW_BBOX [get_computed_shapes [get_computed_shapes $BBOX MOVE {0.1 0}] OR $BBOX]
      } else {
         set NEW_BBOX [get_computed_shapes [get_computed_shapes $BBOX MOVE {-0.1 0}] OR $BBOX]
      }
      create_route_blockage -layer M3 -name RB_memories_${counter} -rects $NEW_BBOX
      incr counter
   }

}



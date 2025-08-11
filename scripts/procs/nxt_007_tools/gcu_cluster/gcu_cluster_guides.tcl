# Create LEB guides
proc create_LEB_guides {} {
  set bb     [get_db [get_db designs] .bbox]
  set xleft [lindex $bb 0 0]
  set xright [lindex $bb 0 2]
  set ybottom [lindex $bb 0 1]
  set ytop   [lindex $bb 0 3]

  set left_offset 8.768
  set right_offset 8.768
  set left [expr $xleft + $left_offset]
  set right [expr $xright - $right_offset]
  set group_width  [expr [expr $right - $left] / 8]

  set group_height 13.92
  set top [expr 928.32 + [expr 1.5 * $group_height]]
  for {set i 0} {$i<8} {incr i} {
    for {set j 0} {$j<15} {incr j} {
      set _box [list [list [expr [expr $group_width * $i] + $left_offset] [expr $top - [expr $group_height * $j] ] [expr [expr $group_width * [expr $i + 1]] + $left_offset] [expr $top - [expr $group_height * [expr $j + 1]] ] ] ]
      if {[get_db program_short_name] == "genus"} {
        create_group -name LEB_${i}_${j} -type guide -rects [join $_box]
      } else {
        create_group -name LEB_${i}_${j} -type guide -rects $_box
      }
      update_group -name LEB_${i}_${j} -add -objs *GCU_COL_${i}_gcu_col*leb_inst_${j}_genblk1_leb
    }
  }

  set top [expr 716.88 + [expr 0.5 * $group_height]]
  for {set i 0} {$i<8} {incr i} {
    for {set j 15} {$j<33} {incr j} {
      set _box [list [list [expr [expr $group_width * $i] + $left_offset] [expr $top - [expr $group_height * [expr $j - 15]] ] [expr [expr $group_width * [expr $i + 1]] + $left_offset] [expr $top - [expr $group_height * [expr [expr $j - 15] + 1]] ] ] ]
      if {[get_db program_short_name] == "genus"} {
        create_group -name LEB_${i}_${j} -type guide -rects [join $_box]
      } else {
        create_group -name LEB_${i}_${j} -type guide -rects $_box
      }
      update_group -name LEB_${i}_${j} -add -objs *GCU_COL_${i}_gcu_col*leb_inst_${j}_genblk1_leb
    }
  }

  set group_height 15.12
  set top [expr 438 + [expr 0.5 * $group_height]]
  for {set i 0} {$i<8} {incr i} {
    for {set j 33} {$j<55} {incr j} {
      set _box [list [list [expr [expr $group_width * $i] + $left_offset] [expr $top - [expr $group_height * [expr $j - 33]] ] [expr [expr $group_width * [expr $i + 1]] + $left_offset] [expr $top - [expr $group_height * [expr [expr $j - 33] + 1]] ] ] ]
      if {[get_db program_short_name] == "genus"} {
        create_group -name LEB_${i}_${j} -type guide -rects [join $_box]
      } else {
        create_group -name LEB_${i}_${j} -type guide -rects $_box
      }
      update_group -name LEB_${i}_${j} -add -objs *GCU_COL_${i}_gcu_col*leb_inst_${j}_genblk1_leb
    }
  }

  set group_height 13.92
  set top [expr 86.88 + [expr 0.5 * $group_height]]
  for {set i 0} {$i<8} {incr i} {
    for {set j 55} {$j<60} {incr j} {
      set _box [list [list [expr [expr $group_width * $i] + $left_offset] [expr $top - [expr $group_height * [expr $j - 55]] ] [expr [expr $group_width * [expr $i + 1]] + $left_offset] [expr $top - [expr $group_height * [expr [expr $j - 55] + 1]] ] ] ]
      if {[get_db program_short_name] == "genus"} {
        create_group -name LEB_${i}_${j} -type guide -rects [join $_box]
      } else {
        create_group -name LEB_${i}_${j} -type guide -rects $_box
      }
      update_group -name LEB_${i}_${j} -add -objs *GCU_COL_${i}_gcu_col*leb_inst_${j}_genblk1_leb
    }
  }

}

proc update_LEB_guides {} {
  set bb     [get_db [get_db designs] .bbox]
  set xleft [lindex $bb 0 0]
  set xright [lindex $bb 0 2]
  set ybottom [lindex $bb 0 1]
  set ytop   [lindex $bb 0 3]

  set left_offset 8.768
  set right_offset 8.768
  set left [expr $xleft + $left_offset]
  set right [expr $xright - $right_offset]
  set group_width  [expr [expr $right - $left] / 8]

  set group_height 13.92
  set top [expr 928.32 + [expr 1.5 * $group_height]]
  for {set i 0} {$i<8} {incr i} {
    for {set j 0} {$j<15} {incr j} {
      set _box [list [list [expr [expr $group_width * $i] + $left_offset] [expr $top - [expr $group_height * $j] ] [expr [expr $group_width * [expr $i + 1]] + $left_offset] [expr $top - [expr $group_height * [expr $j + 1]] ] ] ]
      if {[get_db program_short_name] == "genus"} {
        puts "update_floorplan_obj group:grid_cluster/LEB_${i}_${j} -rects [join $_box]"
        update_floorplan_obj group:grid_cluster/LEB_${i}_${j} -rects [join $_box]
      } else {
        update_floorplan_obj -obj group:grid_cluster/LEB_${i}_${j} -rects $_box
      }
    }
  }

  set top [expr 716.88 + [expr 0.5 * $group_height]]
  for {set i 0} {$i<8} {incr i} {
    for {set j 15} {$j<33} {incr j} {
      set _box [list [list [expr [expr $group_width * $i] + $left_offset] [expr $top - [expr $group_height * [expr $j - 15]] ] [expr [expr $group_width * [expr $i + 1]] + $left_offset] [expr $top - [expr $group_height * [expr [expr $j - 15] + 1]] ] ] ]
      if {[get_db program_short_name] == "genus"} {
        update_floorplan_obj group:grid_cluster/LEB_${i}_${j} -rects [join $_box]
      } else {
        update_floorplan_obj -obj group:grid_cluster/LEB_${i}_${j} -rects $_box
      }
    }
  }

  set group_height 15.12
  set top [expr 438 + [expr 0.5 * $group_height]]
  for {set i 0} {$i<8} {incr i} {
    for {set j 33} {$j<55} {incr j} {
      set _box [list [list [expr [expr $group_width * $i] + $left_offset] [expr $top - [expr $group_height * [expr $j - 33]] ] [expr [expr $group_width * [expr $i + 1]] + $left_offset] [expr $top - [expr $group_height * [expr [expr $j - 33] + 1]] ] ] ]
      if {[get_db program_short_name] == "genus"} {
        update_floorplan_obj group:grid_cluster/LEB_${i}_${j} -rects [join $_box]
      } else {
        update_floorplan_obj -obj group:grid_cluster/LEB_${i}_${j} -rects $_box
      }
    }
  }

  set group_height 13.92
  set top [expr 86.88 + [expr 0.5 * $group_height]]
  for {set i 0} {$i<8} {incr i} {
    for {set j 55} {$j<60} {incr j} {
      set _box [list [list [expr [expr $group_width * $i] + $left_offset] [expr $top - [expr $group_height * [expr $j - 55]] ] [expr [expr $group_width * [expr $i + 1]] + $left_offset] [expr $top - [expr $group_height * [expr [expr $j - 55] + 1]] ] ] ]
      if {[get_db program_short_name] == "genus"} {
        update_floorplan_obj group:grid_cluster/LEB_${i}_${j} -rects [join $_box]
      } else {
        update_floorplan_obj -obj group:grid_cluster/LEB_${i}_${j} -rects $_box
      }
    }
  }

}

# Delete LEB guides
proc delete_LEB_guides  {} {
  if {[get_db groups *LEB*] != ""} {
    delete_obj [get_db groups *LEB*]
  }
}

# Create GCU FT AON guides
proc create_gcu_feedthrough_aon_guides {} {
  set bb     [get_db [get_db designs] .bbox]
  set xleft [lindex $bb 0 0]
  set xright [lindex $bb 0 2]

  set left_offset 8.768
  set right_offset 8.768
  set left [expr $xleft + $left_offset]
  set right [expr $xright - $right_offset]

  set _box [list [list 8.778 723.84 472.758 740.4 ] ]
  if {[get_db program_short_name] == "genus"} {
    create_group -name gcu_feedthrough_aon_0 -type guide -rects [join $_box]
  } else {
    create_group -name gcu_feedthrough_aon_0 -type guide -rects $_box
  }
  update_group -name gcu_feedthrough_aon_0 -add -objs *gcu_sw_feedthrough_aon*_south_*_gen_0_*vr_*_repeater_*
  update_group -name gcu_feedthrough_aon_0 -add -objs *gcu_mem_feedthrough_aon*_south_*_gen_0_*vr_*_repeater_*
  update_group -name gcu_feedthrough_aon_0 -add -objs *gcu_sw_feedthrough_aon*_north_*_gen_2_*vr_*_repeater_*
  update_group -name gcu_feedthrough_aon_0 -add -objs *gcu_mem_feedthrough_aon*_north_*_gen_2_*vr_*_repeater_*

  set _box [list [list 8.778 445.44 472.758 473.28 ] ]
  if {[get_db program_short_name] == "genus"} {
    create_group -name gcu_feedthrough_aon_1 -type guide -rects [join $_box]
  } else {
    create_group -name gcu_feedthrough_aon_1 -type guide -rects $_box
  }
  update_group -name gcu_feedthrough_aon_1 -add -objs *gcu_sw_feedthrough_aon*_south_*_gen_1_*vr_*_repeater_*
  update_group -name gcu_feedthrough_aon_1 -add -objs *gcu_mem_feedthrough_aon*_south_*_gen_1_*vr_*_repeater_*
  update_group -name gcu_feedthrough_aon_1 -add -objs *gcu_sw_feedthrough_aon*_north_*_gen_1_*vr_*_repeater_*
  update_group -name gcu_feedthrough_aon_1 -add -objs *gcu_mem_feedthrough_aon*_north_*_gen_1_*vr_*_repeater_*

  set _box [list [list 8.778 93.84 472.758 112.8 ] ]
  if {[get_db program_short_name] == "genus"} {
    create_group -name gcu_feedthrough_aon_2 -type guide -rects [join $_box]
  } else {
    create_group -name gcu_feedthrough_aon_2 -type guide -rects $_box
  }
  update_group -name gcu_feedthrough_aon_2 -add -objs *gcu_sw_feedthrough_aon*_south_*_gen_2_*vr_*_repeater_*
  update_group -name gcu_feedthrough_aon_2 -add -objs *gcu_mem_feedthrough_aon*_south_*_gen_2_*vr_*_repeater_*
  update_group -name gcu_feedthrough_aon_2 -add -objs *gcu_sw_feedthrough_aon*_north_*_gen_0_*vr_*_repeater_*
  update_group -name gcu_feedthrough_aon_2 -add -objs *gcu_mem_feedthrough_aon*_north_*_gen_0_*vr_*_repeater_*
}

# Create GCU FT AON guides
proc update_gcu_feedthrough_aon_guides {} {
  set bb     [get_db [get_db designs] .bbox]
  set xleft [lindex $bb 0 0]
  set xright [lindex $bb 0 2]

  set left_offset 8.768
  set right_offset 8.768
  set left [expr $xleft + $left_offset]
  set right [expr $xright - $right_offset]

  set _box [list [list 8.778 723.84 472.758 740.4 ] ]
  if {[get_db program_short_name] == "genus"} {
    update_floorplan_obj group:gcu_feedthrough_aon_0 -rects [join $_box]
  } else {
    update_floorplan_obj -obj group:gcu_feedthrough_aon_0 -rects $_box
  }

  set _box [list [list 8.778 445.44 472.758 473.28 ] ]
  if {[get_db program_short_name] == "genus"} {
    update_floorplan_obj group:gcu_feedthrough_aon_1 -rects [join $_box]
  } else {
    update_floorplan_obj -obj group:gcu_feedthrough_aon_1 -rects $_box
  }

  set _box [list [list 8.778 93.84 472.758 112.8 ] ]
  if {[get_db program_short_name] == "genus"} {
    update_floorplan_obj group:gcu_feedthrough_aon_2 -rects [join $_box]
  } else {
    update_floorplan_obj -obj group:gcu_feedthrough_aon_2 -rects $_box
  }
}

# Create GMU FT AON guides
proc create_gmu_feedthrough_aon_guides {} {
  set bb     [get_db [get_db designs] .bbox]
  set xleft [lindex $bb 0 0]
  set xright [lindex $bb 0 2]

  set left_offset 8.768
  set right_offset 8.768
  set left [expr $xleft + $left_offset]
  set right [expr $xright - $right_offset]

  set _box [list [list 8.778 550 472.758 570 ] ]
  if {[get_db program_short_name] == "genus"} {
     create_group -name gmu_feedthrough_aon_0 -type guide -rects [join $_box]
  } else {
     create_group -name gmu_feedthrough_aon_0 -type guide -rects $_box
  }
  update_group -name gmu_feedthrough_aon_0 -add -objs *gmu_sw_feedthrough_aon*_south_*_gen_0_*vr_*_repeater_*
  update_group -name gmu_feedthrough_aon_0 -add -objs *gmu_sw_feedthrough_aon*_north_*_gen_1_*vr_*_repeater_*

  set _box [list [list 8.778 275 472.758 295 ] ]
  if {[get_db program_short_name] == "genus"} {
     create_group -name gmu_feedthrough_aon_1 -type guide -rects [join $_box]
  } else {
     create_group -name gmu_feedthrough_aon_1 -type guide -rects $_box
  }
  update_group -name gmu_feedthrough_aon_1 -add -objs *gmu_sw_feedthrough_aon*_south_*_gen_1_*vr_*_repeater_*
  update_group -name gmu_feedthrough_aon_1 -add -objs *gmu_sw_feedthrough_aon*_north_*_gen_0_*vr_*_repeater_*
}

# Create GMU FT AON guides
proc update_gmu_feedthrough_aon_guides {} {
  set bb     [get_db [get_db designs] .bbox]
  set xleft [lindex $bb 0 0]
  set xright [lindex $bb 0 2]

  set left_offset 8.768
  set right_offset 8.768
  set left [expr $xleft + $left_offset]
  set right [expr $xright - $right_offset]

  set _box [list [list 8.778 550 472.758 570 ] ]
  if {[get_db program_short_name] == "genus"} {
    update_floorplan_obj group:gmu_feedthrough_aon_0 -rects [join $_box]
  } else {
    update_floorplan_obj -obj group:gmu_feedthrough_aon_0 -rects $_box
  }

  set _box [list [list 8.778 275 472.758 295 ] ]
  if {[get_db program_short_name] == "genus"} {
    update_floorplan_obj group:gmu_feedthrough_aon_1 -rects [join $_box]
  } else {
    update_floorplan_obj -obj group:gmu_feedthrough_aon_1 -rects $_box
  }
}

# Create GSU FT AON guides
proc create_gsu_feedthrough_aon_guides {} {
  set bb     [get_db [get_db designs] .bbox]
  set xleft [lindex $bb 0 0]
  set xright [lindex $bb 0 2]

  set left_offset 8.768
  set right_offset 8.768
  set left [expr $xleft + $left_offset]
  set right [expr $xright - $right_offset]

  set _box [list [list 100 60 380 80 ] ]
  if {[get_db program_short_name] == "genus"} {
     create_group -name gsu_feedthrough_aon_0 -type guide -rects [join $_box]
  } else {
     create_group -name gsu_feedthrough_aon_0 -type guide -rects $_box
  }
  update_group -name gsu_feedthrough_aon_0 -add -objs *gsu_mem_feedthrough_aon*_south_*_gen_0_*vr_*_repeater_*
  update_group -name gsu_feedthrough_aon_0 -add -objs *gsu_mem_feedthrough_aon*_north_*_gen_0_*vr_*_repeater_*
}

# Create GSU FT AON guides
proc update_gsu_feedthrough_aon_guides {} {
  set bb     [get_db [get_db designs] .bbox]
  set xleft [lindex $bb 0 0]
  set xright [lindex $bb 0 2]

  set left_offset 8.768
  set right_offset 8.768
  set left [expr $xleft + $left_offset]
  set right [expr $xright - $right_offset]

  set _box [list [list 100 60 380 80 ] ]
  if {[get_db program_short_name] == "genus"} {
    update_floorplan_obj group:gsu_feedthrough_aon_0 -rects [join $_box]
  } else {
    update_floorplan_obj -obj group:gsu_feedthrough_aon_0 -rects $_box
  }
}


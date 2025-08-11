
  # Left Channel
  set bbox_list {{2414.748 310.0 2441.88 1050.0}}

  set left_col_bbox_list {}
  set dy 1108.8
  set gap 20.16
  for { set i 0 } { $i < 8 } { incr i } {
      foreach bbox $bbox_list {
          lassign $bbox xl yl xh yh
          set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
          lappend left_col_bbox_list $new_bbox
      }
  }

  create_place_blockage -name "carpet_cts_blockage" -type hard -rects $left_col_bbox_list

  # Right Channel
  set bbox_list {{7298.508 310.0 7325.64 1050.0}}

  set left_col_bbox_list {}
  set dy 1108.8
  set gap 20.16
  for { set i 0 } { $i < 8 } { incr i } {
      foreach bbox $bbox_list {
          lassign $bbox xl yl xh yh
          set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
          lappend left_col_bbox_list $new_bbox
      }
  }

  create_place_blockage -name "carpet_cts_blockage" -type hard -rects $left_col_bbox_list


  # Middle Channel
  set bbox_list {{4829.496 310.0 4910.892 1050.0}}

  set left_col_bbox_list {}
  set dy 1108.8
  set gap 20.16
  for { set i 0 } { $i < 8 } { incr i } {
      foreach bbox $bbox_list {
          lassign $bbox xl yl xh yh
          set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
          lappend left_col_bbox_list $new_bbox
      }
  }

  create_place_blockage -name "carpet_cts_blockage" -type hard -rects $left_col_bbox_list


  # Bottom channel (8 starting from 0 at the top)
  set bbox_list {{694 141.12 1200 161.28} {297 141.12 352 161.28}}

  set row_bbox_list {}
  set dx 1193.808
  set dy 1108.8
  set xmul 27.132
  set gap 20.16
  for { set j 0 } { $j < 9 } { incr j } {
    for { set i 0 } { $i < 8 } { incr i } {
        foreach bbox $bbox_list {
            lassign $bbox xl yl xh yh
#            if { $j == 0 } { set yl 40.32 ; set yh 50.4 } elseif { $j == 8 } { set yl 30.24 ; set yh 40.32 } else { set yl 30.24 ; set yh 50.4 }
            if { $i == 2 || $i == 3 } { 
              set new_bbox [list [expr $xl + $i*$dx + 1*$xmul] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx + 1*$xmul] [expr $yh + $j*($dy+$gap)]] 
            } elseif { $i == 4 || $i == 5 } { 
              set new_bbox [list [expr $xl + $i*$dx + 4*$xmul] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx + 4*$xmul] [expr $yh + $j*($dy+$gap)]] 
            } elseif { $i == 6 || $i == 7 } { 
              set new_bbox [list [expr $xl + $i*$dx + 5*$xmul] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx + 5*$xmul] [expr $yh + $j*($dy+$gap)]] 
            } else {
              set new_bbox [list [expr $xl + $i*$dx] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx] [expr $yh + $j*($dy+$gap)]] 
            }
            lappend row_bbox_list $new_bbox
        }
    }
  }
  set row_bbox_list [concat $row_bbox_list { {9714.983 8043.84 9820.5715 8064.00} \
                                             {9714.983 6914.88 9820.5715 6935.04} \
                                             {9714.983 5785.92 9820.5715 5806.08} \
                                             {9714.983 4656.96 9820.5715 4677.12} \
                                             {9714.983 3528.00 9820.5715 3548.16} \
                                             {9714.983 2399.04 9820.5715 2419.20} \
                                             {9714.983 1270.08 9820.5715 1290.24} \
                                             {9714.983 151.200 9820.5715 161.280}}]
  create_place_blockage -name "carpet_cts_blockage" -type hard -rects $row_bbox_list


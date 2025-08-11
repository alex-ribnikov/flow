##
##set xbot 2398.0
##set xtop 2424.0
##set ybot 50.4
##set ytop 1139.04
##
##set num_of_boxes 30
##
##set dy [expr ($ytop - $ybot)/$num_of_boxes]
##
##set table {}
##array unset box_arr
##
##for { set i 0 } { $i < $num_of_boxes } { incr i } { 
##    
##    set xl $xbot
##    set xh $xtop
##    set yl [expr $ybot +       $i*$dy]
##    set yh [expr $ybot + ($i + 1)*$dy]
##    set bbox [list $xl $yl $xh $yh]
##    
##    array unset dens_res
##    array set dens_res [get_pins_dens  h $bbox]
##    
##    set box_arr($i:box)  $bbox
##    set box_arr($i:dens) {}
##    
##    foreach key [array names dens_res *util] { lappend box_arr($i:dens) [list [lindex [split $key ":"] 0] $dens_res($key)] }
##    set line [list $i $bbox]
##    foreach layer [list   M6 M8 M10 M12 M14 ] {
##        set dens $dens_res($layer:util)
##        lappend line $dens
##    }
##    
##    lappend table $line    
##}
##
##set header [list index bbox   M6 M8 M10 M12 M14 ]
##rls_table -table [lsort -index 0 -dec -real $table] -header $header -spac -breaks
#
##index | bbox                            | M6     | M8     | M10    | M12    | M14    
##------+---------------------------------+--------+--------+--------+--------+--------
##19    | 2398.0 1084.608 2424.0 1139.04  | 0.00%  | 0.00%  | 0.00%  | 0.00%  | 0.00%  
##18    | 2398.0 1030.176 2424.0 1084.608 | 0.00%  | 0.00%  | 0.00%  | 0.00%  | 0.00%  
##17    | 2398.0 975.744 2424.0 1030.176  | 0.00%  | 0.00%  | 0.00%  | 0.00%  | 0.00%  
##16    | 2398.0 921.312 2424.0 975.744   | 0.00%  | 0.00%  | 0.00%  | 0.00%  | 0.00%  
##15    | 2398.0 866.88 2424.0 921.312    | 0.00%  | 0.00%  | 0.00%  | 0.00%  | 0.00%  
##14    | 2398.0 812.448 2424.0 866.88    | 9.97%  | 10.14% | 10.31% | 0.00%  | 0.00%  
##13    | 2398.0 758.016 2424.0 812.448   | 50.09% | 50.09% | 50.09% | 7.20%  | 7.22%  
##12    | 2398.0 703.584 2424.0 758.016   | 50.09% | 50.09% | 50.09% | 29.56% | 29.74% 
##11    | 2398.0 649.152 2424.0 703.584   | 33.79% | 33.79% | 33.79% | 29.82% | 29.38% 
##10    | 2398.0 594.72 2424.0 649.152    | 34.19% | 34.13% | 34.13% | 23.97% | 24.23% 
##9     | 2398.0 540.288 2424.0 594.72    | 34.02% | 33.85% | 33.85% | 9.28%  | 9.28%  
##8     | 2398.0 485.856 2424.0 540.288   | 38.08% | 38.25% | 38.25% | 22.37% | 22.16% 
##7     | 2398.0 431.424 2424.0 485.856   | 50.09% | 50.09% | 50.09% | 22.11% | 22.56% 
##6     | 2398.0 376.992 2424.0 431.424   | 50.09% | 49.91% | 49.91% | 22.37% | 22.16% 
##5     | 2398.0 322.56 2424.0 376.992    | 50.00% | 50.09% | 50.09% | 22.16% | 22.16% 
##4     | 2398.0 268.128 2424.0 322.56    | 33.16% | 33.16% | 33.16% | 22.16% | 22.16% 
##3     | 2398.0 213.696 2424.0 268.128   | 0.00%  | 0.00%  | 0.00%  | 15.42% | 15.46% 
##2     | 2398.0 159.264 2424.0 213.696   | 0.00%  | 0.00%  | 0.00%  | 0.00%  | 0.00%  
##1     | 2398.0 104.832 2424.0 159.264   | 0.00%  | 0.00%  | 0.00%  | 0.00%  | 0.00%  
##0     | 2398.0 50.4 2424.0 104.832      | 0.00%  | 0.00%  | 0.00%  | 0.00%  | 0.00%  
##
##
##set xbot 2010
##set xtop 1220.94
##set ybot 48
##set ytop 52
##
##set num_of_boxes 30
##
##set dx [expr ($xtop - $xbot)/$num_of_boxes]
##
##set table {}
##array unset box_arr
##
##for { set i 0 } { $i < $num_of_boxes } { incr i } { 
##    
##    set yl $ybot
##    set yh $ytop
##    set xl [expr $xbot +       $i*$dx]
##    set xh [expr $xbot + ($i + 1)*$dx]
##    set bbox [list $xl $yl $xh $yh]
##
##    array unset dens_res
##    array set dens_res [get_pins_dens v $bbox]
##    
##    set box_arr($i:box)  $bbox
##    set box_arr($i:dens) {}
##    
##    foreach key [array names dens_res *util] { lappend box_arr($i:dens) [list [lindex [split $key ":"] 0] $dens_res($key)] }
##    set line [list $i $bbox]
##    foreach layer [list   M5 M7 M9 M11 M13 ] {
##        set dens $dens_res($layer:util)
##        lappend line $dens
##    }
##    
##    lappend table $line    
##}
##
##set header [list index bbox   M5 M7 M9 M11 M13 ]
##rls_table -table [lsort -index 0 -dec -real $table] -header $header -spac -breaks
##
#
#if { $STAGE!="cts" } {
## Left Channel
##set bbox_list {{2414.748 300.0 2441.88 525.0} \
##               {2414.748 545.0 2441.88 575.0} \
##               {2414.748 600.0 2441.88 630.0} \
##               {2414.748 660.0 2441.88 820.0}}
#set bbox_list {{2414.748 311.0 2441.88 1050.0}}
#
#
#set left_col_bbox_list {}
#set num_of_blocks 20
#set dy  1108.8
#set d2y [expr $dy/$num_of_blocks]
#
#for { set i 0 } { $i < 8 } { incr i } {
#    foreach bbox $bbox_list {
#        for { set j 0 } { $j < $num_of_blocks } { incr j } {
#            lassign $bbox xl yl xh yh
#            set new_bbox [list $xl [expr $yl + $i*$dy + $i*20.16] $xh [expr $yh + $i*$dy + $i*20.16]]
#            lappend left_col_bbox_list $new_bbox
#        }
#    }
#}
#
#create_place_blockage -name "carpet_blockage" -exclude_flops -density 5 -type partial -rects $left_col_bbox_list
#
## Right Channel
#set bbox_list {{7298.508 300.0 7325.64 525.0} \
#               {7298.508 545.0 7325.64 575.0} \
#               {7298.508 600.0 7325.64 630.0} \
#               {7298.508 660.0 7325.64 820.0}}
#        
#set left_col_bbox_list {}
#set dy 1108.8
#for { set i 0 } { $i < 8 } { incr i } {
#    foreach bbox $bbox_list {
#        lassign $bbox xl yl xh yh
#        set new_bbox [list $xl [expr $yl + $i*$dy] $xh [expr $yh + $i*$dy]]
#        lappend left_col_bbox_list $new_bbox
#    }
#}
#
#create_place_blockage -name "carpet_blockage" -exclude_flops -density 5 -type partial -rects $left_col_bbox_list
#
#
## Middle Channel
#set bbox_list {{4829.496 300.0 4910.892 525.0} \
#               {4829.496 545.0 4910.892 575.0} \
#               {4829.496 600.0 4910.892 630.0} \
#               {4829.496 660.0 4910.892 820.0}}
#        
#set left_col_bbox_list {}
#set dy 1108.8
#for { set i 0 } { $i < 8 } { incr i } {
#    foreach bbox $bbox_list {
#        lassign $bbox xl yl xh yh
#        set new_bbox [list $xl [expr $yl + $i*$dy] $xh [expr $yh + $i*$dy]]
#        lappend left_col_bbox_list $new_bbox
#    }
#}
#
#create_place_blockage -name "carpet_blockage" -exclude_flops -density 5 -type partial -rects $left_col_bbox_list
#
#
## Bottom channel (8 starting from 0 at the top)
#set bbox_list {{854.658 40.32 1193.808 50.4}}
#
#set row_bbox_list {}
#set dx 1193.808
#set dy 1108.8
#set xmul 27.132
#for { set j 0 } { $j < 9 } { incr j } {
#  for { set i 0 } { $i < 8 } { incr i } {
#      foreach bbox $bbox_list {
#          lassign $bbox xl yl xh yh
#          if { $j == 0 } { set yl 40.32 ; set yh 50.4 } elseif { $j == 8 } { set yl 30.24 ; set yh 40.32 } else { set yl 30.24 ; set yh 50.4 }
#                if { $i == 2 || $i == 3 } { 
#            set new_bbox [list [expr $xl + $i*$dx + 1*$xmul] [expr $yl + $j*$dy] [expr $xh + $i*$dx + 1*$xmul] [expr $yh + $j*$dy]] 
#          } elseif { $i == 4 || $i == 5 } { 
#            set new_bbox [list [expr $xl + $i*$dx + 4*$xmul] [expr $yl + $j*$dy] [expr $xh + $i*$dx + 4*$xmul] [expr $yh + $j*$dy]] 
#          } elseif { $i == 6 || $i == 7 } { 
#            set new_bbox [list [expr $xl + $i*$dx + 5*$xmul] [expr $yl + $j*$dy] [expr $xh + $i*$dx + 5*$xmul] [expr $yh + $j*$dy]] 
#          } else {
#            set new_bbox [list [expr $xl + $i*$dx] [expr $yl + $j*$dy] [expr $xh + $i*$dx] [expr $yh + $j*$dy]] 
#          }
#          lappend row_bbox_list $new_bbox
#      }
#  }
#}
#create_place_blockage -name "carpet_blockage" -exclude_flops -density 5 -type partial -rects $row_bbox_list
#
#} else {
#
#
#  # Left Channel
#  set bbox_list {{2414.748 310.0 2441.88 1050.0}}
#
#  set left_col_bbox_list {}
#  set dy 1108.8
#  set gap 20.16
#  for { set i 0 } { $i < 8 } { incr i } {
#      foreach bbox $bbox_list {
#          lassign $bbox xl yl xh yh
#          set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
#          lappend left_col_bbox_list $new_bbox
#      }
#  }
#
#  create_place_blockage -name "carpet_cts_blockage" -type hard -rects $left_col_bbox_list
#
#  # Right Channel
#  set bbox_list {{7298.508 310.0 7325.64 1050.0}}
#
#  set left_col_bbox_list {}
#  set dy 1108.8
#  set gap 20.16
#  for { set i 0 } { $i < 8 } { incr i } {
#      foreach bbox $bbox_list {
#          lassign $bbox xl yl xh yh
#          set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
#          lappend left_col_bbox_list $new_bbox
#      }
#  }
#
#  create_place_blockage -name "carpet_cts_blockage" -type hard -rects $left_col_bbox_list
#
#
#  # Middle Channel
#  set bbox_list {{4829.496 310.0 4910.892 1050.0}}
#
#  set left_col_bbox_list {}
#  set dy 1108.8
#  set gap 20.16
#  for { set i 0 } { $i < 8 } { incr i } {
#      foreach bbox $bbox_list {
#          lassign $bbox xl yl xh yh
#          set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
#          lappend left_col_bbox_list $new_bbox
#      }
#  }
#
#  create_place_blockage -name "carpet_cts_blockage" -type hard -rects $left_col_bbox_list
#
#
#  # Bottom channel (8 starting from 0 at the top)
#  set bbox_list {{694 141.12 1200 161.28} {297 141.12 352 161.28}}
#
#  set row_bbox_list {}
#  set dx 1193.808
#  set dy 1108.8
#  set xmul 27.132
#  set gap 20.16
#  for { set j 0 } { $j < 9 } { incr j } {
#    for { set i 0 } { $i < 8 } { incr i } {
#        foreach bbox $bbox_list {
#            lassign $bbox xl yl xh yh
##            if { $j == 0 } { set yl 40.32 ; set yh 50.4 } elseif { $j == 8 } { set yl 30.24 ; set yh 40.32 } else { set yl 30.24 ; set yh 50.4 }
#            if { $i == 2 || $i == 3 } { 
#              set new_bbox [list [expr $xl + $i*$dx + 1*$xmul] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx + 1*$xmul] [expr $yh + $j*($dy+$gap)]] 
#            } elseif { $i == 4 || $i == 5 } { 
#              set new_bbox [list [expr $xl + $i*$dx + 4*$xmul] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx + 4*$xmul] [expr $yh + $j*($dy+$gap)]] 
#            } elseif { $i == 6 || $i == 7 } { 
#              set new_bbox [list [expr $xl + $i*$dx + 5*$xmul] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx + 5*$xmul] [expr $yh + $j*($dy+$gap)]] 
#            } else {
#              set new_bbox [list [expr $xl + $i*$dx] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx] [expr $yh + $j*($dy+$gap)]] 
#            }
#            lappend row_bbox_list $new_bbox
#        }
#    }
#  }
#  set row_bbox_list [concat $row_bbox_list { {9714.983 8043.84 9820.5715 8064.00} \
#                                             {9714.983 6914.88 9820.5715 6935.04} \
#                                             {9714.983 5785.92 9820.5715 5806.08} \
#                                             {9714.983 4656.96 9820.5715 4677.12} \
#                                             {9714.983 3528.00 9820.5715 3548.16} \
#                                             {9714.983 2399.04 9820.5715 2419.20} \
#                                             {9714.983 1270.08 9820.5715 1290.24} \
#                                             {9714.983 151.200 9820.5715 161.280}}]
#  create_place_blockage -name "carpet_cts_blockage" -type hard -rects $row_bbox_list
#
#
#}
#  
#  set xslice 5.0
#  set yslice 100.0
#  
#  # Left Channel
#  set bbox_list {{2414.748 310.0 2441.88 1050.0}}
#
#  set left_col_bbox_list {}
#  set dy 1108.8
#  set gap 20.16
#  for { set i 0 } { $i < 8 } { incr i } {
#      foreach bbox $bbox_list {
#          set bbox_sub_list [split_bbox $bbox $xslice $yslice 0.01]
#          foreach sub_bbox $bbox_sub_list {
#              lassign $sub_bbox xl yl xh yh
#              set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
#              lappend left_col_bbox_list $new_bbox
#              create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $new_bbox
#          }
#      }
#  }
#
##  create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $left_col_bbox_list
#
#  # Right Channel
#  set bbox_list {{7298.508 310.0 7325.64 1050.0}}
#
#  set left_col_bbox_list {}
#  set dy 1108.8
#  set gap 20.16
#  for { set i 0 } { $i < 8 } { incr i } {
#      foreach bbox $bbox_list {
#          set bbox_sub_list [split_bbox $bbox $xslice $yslice 0.01]
#          foreach sub_bbox $bbox_sub_list {
#              lassign $sub_bbox xl yl xh yh
#              set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
#              lappend left_col_bbox_list $new_bbox
#              create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $new_bbox
#          }
#      }
#  }
#
#  #create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $left_col_bbox_list
#
#
#  # Middle Channel
#  set bbox_list {{4829.496 310.0 4910.892 1050.0}}
#
#  set left_col_bbox_list {}
#  set dy 1108.8
#  set gap 20.16
#  for { set i 0 } { $i < 8 } { incr i } {
#      foreach bbox $bbox_list {
#          set bbox_sub_list [split_bbox $bbox $xslice $yslice 0.01]
#          foreach sub_bbox $bbox_sub_list {
#              lassign $sub_bbox xl yl xh yh
#              set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
#              lappend left_col_bbox_list $new_bbox
#              create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $new_bbox
#          }
#      }
#  }
#
##  create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $left_col_bbox_list
#
#
#  # Bottom channel (8 starting from 0 at the top)
#  set bbox_list {{694 141.12 1200 161.28} {297 141.12 352 161.28}}
#
#  set row_bbox_list {}
#  set dx 1193.808
#  set dy 1108.8
#  set xmul 27.132
#  set gap 20.16
#  for { set j 0 } { $j < 9 } { incr j } {
#    for { set i 0 } { $i < 8 } { incr i } {
#        foreach bbox $bbox_list {
#            lassign $bbox xl yl xh yh
##            if { $j == 0 } { set yl 40.32 ; set yh 50.4 } elseif { $j == 8 } { set yl 30.24 ; set yh 40.32 } else { set yl 30.24 ; set yh 50.4 }
#            if { $i == 2 || $i == 3 } { 
#              set new_bbox [list [expr $xl + $i*$dx + 1*$xmul] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx + 1*$xmul] [expr $yh + $j*($dy+$gap)]] 
#            } elseif { $i == 4 || $i == 5 } { 
#              set new_bbox [list [expr $xl + $i*$dx + 4*$xmul] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx + 4*$xmul] [expr $yh + $j*($dy+$gap)]] 
#            } elseif { $i == 6 || $i == 7 } { 
#              set new_bbox [list [expr $xl + $i*$dx + 5*$xmul] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx + 5*$xmul] [expr $yh + $j*($dy+$gap)]] 
#            } else {
#              set new_bbox [list [expr $xl + $i*$dx] [expr $yl + $j*($dy+$gap)] [expr $xh + $i*$dx] [expr $yh + $j*($dy+$gap)]] 
#            }
#            lappend row_bbox_list $new_bbox
#        }
#    }
#  }
#  set row_bbox_list [concat $row_bbox_list { {9714.983 8043.84 9820.5715 8064.00} \
#                                             {9714.983 6914.88 9820.5715 6935.04} \
#                                             {9714.983 5785.92 9820.5715 5806.08} \
#                                             {9714.983 4656.96 9820.5715 4677.12} \
#                                             {9714.983 3528.00 9820.5715 3548.16} \
#                                             {9714.983 2399.04 9820.5715 2419.20} \
#                                             {9714.983 1270.08 9820.5715 1290.24} \
#                                             {9714.983 151.200 9820.5715 161.280}}]
#  
#  set xslice 50
#  set yslice 4
#  foreach bbox $row_bbox_list {
#      set sub_bbox_list [split_bbox $bbox $xslice $yslice 0.01]
#      foreach sub_bbox $sub_bbox_list {
#          create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $sub_bbox
#      }
#  }
#  
##  create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $row_bbox_list
#

############################################################
############################################################
############################################################
############################################################
  
  set xslice 2.05
  set yslice 0.63
  
  # Left Channel
  set bbox_list {{2414.748 310.0 2441.88 1050.0}}

  set left_col_bbox_list {}
  set dy 1108.8
  set gap 20.16
  for { set i 0 } { $i < 8 } { incr i } {
      foreach bbox $bbox_list {
          set bbox_sub_list [split_bbox_by $bbox $xslice $yslice 0.01]
          foreach sub_bbox $bbox_sub_list {
              lassign $sub_bbox xl yl xh yh
              set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
              lappend left_col_bbox_list $new_bbox
              create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $new_bbox
          }
      }
  }

#  create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $left_col_bbox_list

  # Right Channel
  set bbox_list {{7298.508 310.0 7325.64 1050.0}}

  set left_col_bbox_list {}
  set dy 1108.8
  set gap 20.16
  for { set i 0 } { $i < 8 } { incr i } {
      foreach bbox $bbox_list {
          set bbox_sub_list [split_bbox_by $bbox $xslice $yslice 0.01]
          foreach sub_bbox $bbox_sub_list {
              lassign $sub_bbox xl yl xh yh
              set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
              lappend left_col_bbox_list $new_bbox
              create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $new_bbox
          }
      }
  }

  #create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $left_col_bbox_list


  # Middle Channel
  set bbox_list {{4829.496 310.0 4910.892 1050.0}}

  set left_col_bbox_list {}
  set dy 1108.8
  set gap 20.16
  for { set i 0 } { $i < 8 } { incr i } {
      foreach bbox $bbox_list {
          set bbox_sub_list [split_bbox_by $bbox $xslice $yslice 0.01]
          foreach sub_bbox $bbox_sub_list {
              lassign $sub_bbox xl yl xh yh
              set new_bbox [list $xl [expr $yl + $i*($dy+$gap)] $xh [expr $yh + $i*($dy+$gap)]]
              lappend left_col_bbox_list $new_bbox
              create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $new_bbox
          }
      }
  }

#  create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $left_col_bbox_list


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
  
  set xslice 2.05
  set yslice 0.63
  foreach bbox $row_bbox_list {
      set sub_bbox_list [split_bbox_by $bbox $xslice $yslice 0.01]
      foreach sub_bbox $sub_bbox_list {
          create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $sub_bbox
      }
  }
  
#  create_place_blockage -name "carpet_cts_blockage" -type partial -density 5 -exclude_flops -rects $row_bbox_list











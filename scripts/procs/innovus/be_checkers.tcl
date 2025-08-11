
#====================================================================================================================
# All of these PROCs, generate reports for the be_checklist.tcl
#====================================================================================================================
proc generate_clock_cells_list {  } {
    puts "-I- Generate clock cells list ..."
    global STAGE
    
    set clock_list_tmp ""
    foreach clk [get_db clocks .base_name] {
       if {(![regexp {virtual_|__cdc} $clk])} {
          lappend clock_list_tmp $clk
       }
    }
    set clock_list [lsort -u $clock_list_tmp]
    set fo [open reports/$STAGE/clock_cells_list.rpt w]
    foreach clk $clock_list {
       set overall_clock_cells [all_fanout -from $clk -trace_through clocks -only_cells]
        if {[get_db insts -if {.is_macro == true || .is_memory == true}] != "" } {   
           set all_macro_in_design [lsort -u [get_property [get_db insts -if {.is_macro == true || .is_memory == true}] ref_lib_cell_name]]
        } else {
           set all_macro_in_design ""
        }
       set mb_ff_in_clock_path [lsort -u [get_db  [get_cells [filter_collection [all_registers -edge_triggered] "is_integrated_clock_gating_cell==false"] ] .base_cell.name ]]
       set list_to_filter [concat $all_macro_in_design $mb_ff_in_clock_path]
       set list_of_clock_cells ""
       set i 0
       foreach cell [get_object_name $overall_clock_cells] {
           if {[lsearch  -exact $list_to_filter [get_property [get_cells -quiet $cell] ref_lib_cell_name]] == -1} {
              lappend list_of_clock_cells $cell
           }
       }

    };# foreach clock ..
    foreach cell [lsort -u $list_of_clock_cells] {
      puts $fo "[get_property [get_cells -quiet $cell] ref_lib_cell_name] $cell "
    }

  close $fo
};# generate_clock_cells_list 

#====================================================================================================================
proc check_clock_to_each_clk_pin { } {
    global STAGE
    puts "-I- Check the clock to each clock pin..."
    set OFILE [open reports/${STAGE}/reports_clock_to_each_clk_pin_${STAGE}.rpt w]
    set clock_pins [get_object_name [all_registers -clock_pins]] 
    set clock_list_tmp ""
    foreach clk [get_db clocks .base_name] {
       if {(![regexp {virtual_|__cdc} $clk])} {
          lappend clock_list_tmp $clk
       }
    }
    set clock_list [lsort -u $clock_list_tmp]
    set clock_pin_violations 0
    puts $OFILE "#==========================================" 
    puts $OFILE "#clock_pin                connected_to"
    puts $OFILE "#==========================================" 
    foreach clk_pin [get_object_name [all_registers -clock_pins ]] {
       set connect_to_clk 0
       #set clk_pin_connected [all_fanin -to $clk_pin -startpoints_only]
       set clk_pin_connected [all_fanin -to $clk_pin -trace_through all -startpoints_only]
       foreach clk $clock_list {
         if {[lsearch -exact $clk_pin_connected $clk]} {
            incr connect_to_clk
         }
       }
       if {$connect_to_clk == 0} {
          puts $OFILE "$clk_pin    $clk_pin_connected"
          incr clock_pin_violations
       }
    };# foreach clk_pin ...
   puts $OFILE ""
   puts $OFILE "clock_pins_not_connect_to_clock $clock_pin_violations"
 close $OFILE
};# check_clock_to_each_clk_pin 
#====================================================================================================================
proc dont_use_cells_check { } {
    #=========================================================================================  
    # NOTE:
    #   1. Check if we want in latest stage, change the VT for clock cells that are NOT "UN" ?
    #   2. Need to add option for filtering the waiver instance.
    #=========================================================================================  
    global CTS_CELLS_HALO
    global STAGE
    global DONT_USE_CELLS
    global DO_USE_CELLS
    global HOLD_FIX_CELLS_LIST
    global IOBUFFER_CELL
    global USEABLE_IOBUFFER_CELL
    ###################################################################
    #                 results Dir.
    ###################################################################
    set dirname "reports"
    if {![file exist $dirname] == 1} {
    	exec 	mkdir reports
    } 
    ###################################################################
    puts "-I- Don't use cells Check..."
    set OFILE [open  ${dirname}/${STAGE}/report_dont_use_cells.rpt w]
    # generate clock list
     generate_clock_cells_list
     set clock_cells_list ""
     set fi_clk [open  reports/${STAGE}/clock_cells_list.rpt r]
     while {[gets $fi_clk line]>=0} {
         set clock_cells_list [concat $clock_cells_list [lindex $line 1]] 
     } 
    #if {[string match $STAGE "route"]} {
    #  # Check if we want in latest stage, change the VT for clock cells that are NOT "UN" ?
    #}
    puts $OFILE "#=========================================================================" 
    puts $OFILE "# Info :                                                                  " 
    puts $OFILE "# 1. List dont_used_cells : $DONT_USE_CELLS                               " 
    puts $OFILE "# 2. List used_cells      : $DO_USE_CELLS                                 " 
    puts $OFILE "# 3. List used_clk_cells  : $CTS_CELLS_HALO                               " 
    puts $OFILE "# 4. List hold fix        : $HOLD_FIX_CELLS_LIST                          " 
    puts $OFILE "# 4. List IO BUFFERS      : $IOBUFFER_CELL $USEABLE_IOBUFFER_CELL         " 
    puts $OFILE "#=========================================================================" 
    
    foreach du_cell $DONT_USE_CELLS {
        set num_of_lib_cells_in [sizeof_collection [get_lib_cells -quiet $du_cell]]
        if {$num_of_lib_cells_in == 0} {
            puts $OFILE "-E-  can't find any lib cells for : $du_cell"
        }
     }

     foreach u_cell $DO_USE_CELLS {
        set num_of_lib_cells_in [sizeof_collection [get_lib_cells -quiet $u_cell]]
        if {$num_of_lib_cells_in == 0} {
            puts $OFILE "-E- can't find any lib cells for : $u_cell"
        }
     }

     foreach hf_cell $HOLD_FIX_CELLS_LIST {
        set num_of_lib_cells_in [sizeof_collection [get_lib_cells -quiet $hf_cell]]
        if {$num_of_lib_cells_in == 0} {
            puts $OFILE "-E- can't find any lib cells for : $hf_cell"
        }
     }

     set IO_BUFFER_LIST [concat $IOBUFFER_CELL $USEABLE_IOBUFFER_CELL]
     foreach io_cell $HOLD_FIX_CELLS_LIST {
        set num_of_lib_cells_in [sizeof_collection [get_lib_cells -quiet $io_cell]]
        if {$num_of_lib_cells_in == 0} {
            puts $OFILE "-E- can't find any lib cells for : $io_cell"
        }
     }

    puts $OFILE "#=========================================================================" 
    puts $OFILE "" 
    puts $OFILE "# List of instances , that failed dont use cell check:" 
    puts $OFILE "#=========================================================================" 
    puts $OFILE "# lib_ref_name (cell_type)                  Inst                        "
    puts $OFILE "#=========================================================================" 
    set sort_dont_use_list [lsort -u [ get_property [get_lib_cells -quiet $DONT_USE_CELLS] name]]
    set sort_clock_list [lsort -u [ get_property [get_lib_cells -quiet $CTS_CELLS_HALO] name]]
    if {![string match $STAGE "place"]} {
         set sort_use_list [concat [lsort -u [ get_property [get_lib_cells -quiet $DO_USE_CELLS] name]] [lsort -u [ get_property [get_lib_cells -quiet $IO_BUFFER_LIST] name]] [lsort -u [ get_property [get_lib_cells -quiet $HOLD_FIX_CELLS_LIST] name]]]   
    } else {
         set sort_use_list [concat [lsort -u [ get_property [get_lib_cells -quiet $DO_USE_CELLS] name]] [lsort -u [ get_property [get_lib_cells -quiet $IO_BUFFER_LIST] name]]]
    }
    set sort_fix_hold_list [lsort -u [ get_property [get_lib_cells -quiet $HOLD_FIX_CELLS_LIST] name]]
    set all_cells [ get_cells  -quiet -hierarchical -filter "is_hierarchical==false && is_macro_cell==false && is_pad_cell==false && is_black_box==false"]
     ## Check that we reduce also PNR blocks !!!!!!
    set num_all_cells [sizeof_collection $all_cells]
    set failed_counter 0

    foreach cell [get_object_name  $all_cells] {
         set ref_lib_cell_name [get_property [get_cells -quiet $cell] ref_lib_cell_name]
       #  set if_clock_cell [check_if_clock_cell $cell ]
          if { [lsearch -exact $clock_cells_list $cell] > -1} {
               set if_clock_cell 1
          } else {
               set if_clock_cell 0
          }
         set clk_cell "data"
         if {$if_clock_cell} {
            set clk_cell "clock"
            set if_in_clk_list [lsearch $sort_clock_list $ref_lib_cell_name]
            if {$if_in_clk_list==-1} {
               puts $OFILE "$ref_lib_cell_name  $cell ($clk_cell)"
               incr failed_counter
            }
         } else {
             set if_cell_dont_use_list [lsearch $sort_dont_use_list $ref_lib_cell_name]
             if {$sort_use_list==""} {
               set if_cell_use_list  -1
             } else {
               set if_cell_use_list [lsearch $sort_use_list $ref_lib_cell_name] 
             }
  
             if {($if_cell_dont_use_list >= 0) && ($if_cell_use_list == -1) && ($clk_cell=="data")} {
               puts $OFILE "$ref_lib_cell_name  $cell ($clk_cell)"
               incr failed_counter
             }
         }
     };# foreach cell..

  if {$failed_counter} {
      puts $OFILE "#===============================================================" 
      puts $OFILE "# -E- Found $failed_counter don't use cells violations"
      puts $OFILE "#===============================================================" 
  } else {
      puts $OFILE "#===============================================================" 
      puts $OFILE "# -I- Found $failed_counter don't use cells violations"
      puts $OFILE "#===============================================================" 
  }

  close $OFILE
};#dont_use_cells_check
#====================================================================================================================
proc clock_tree_cells_check { } {
    global CTS_CELLS_HALO
    global STAGE
    global HOLD_FIX_CELLS_LIST
    puts "-I- Report clock tree cells..."
    # generate clock tree list
    generate_clock_cells_list
    set OFILE [open reports/${STAGE}/reports_clock_tree_cells.rpt w]
    puts $OFILE "#=============================================="
    puts $OFILE "#      Allowed clock tree list:"
    puts $OFILE "#=============================================="
    puts $OFILE "# $CTS_CELLS_HALO"
    puts $OFILE "#=============================================="
    puts $OFILE "# list of clock tree violation:"
    puts $OFILE "#=============================================="
    puts $OFILE "# base_name      cell_name"
     set clock_cells_list ""
     set fi_clk [open  reports/${STAGE}/clock_cells_list.rpt r]
     set count_clk_tree_vio 0
     set sort_clock_list [lsort -u [ get_property [get_lib_cells -quiet $CTS_CELLS_HALO] name]]
     while {[gets $fi_clk line]>=0} {
         set base_name [lindex $line 0]
         set cell_name [lindex $line 1]
         if {[lsearch -exact $sort_clock_list $base_name] == -1} {
            puts $OFILE "$base_name   $cell_name"
            incr count_clk_tree_vio
         }
     };# while .. 
   
    puts $OFILE "#=============================================="
    puts $OFILE ""
    puts $OFILE "#-------------------------------------------"
    puts $OFILE "clock tree violations $count_clk_tree_vio "
    set count_hold_fix_cell [llength [get_db insts -if {.name=="*i_${STAGE}_hold*"}]]
    puts $OFILE "number of min delay cells 'i_${STAGE}_hold' $count_hold_fix_cell "
    puts $OFILE "#-------------------------------------------"
 close $OFILE
};# clock_tree_cells_check
#====================================================================================================================
proc constraints_check {} {
      global STAGE
      # clock_period: Reports only the paths that end at the clock_period timing check
       report_constraints -check_type {clock_period pulse_width}  -all_violators > reports/${STAGE}/report_constraints_${STAGE}.rpt

      
};# constraints_check
#====================================================================================================================
proc preplace_count {} {
    global STAGE
    global VT_GROUPS
    puts "-I- Preplace count ..."
    set all_edge   [all_registers -edge_triggered]
   # Leaf Instance count
    set leaf_cell_count [sizeof [get_cells -quiet -hier -filter "is_hierarchical == false && is_macro_cell == false"]]
    # Sequential Instance Count    
    if { [sizeof $all_edge] > 0 } { set seq_cell_count  [sizeof  [filter_collection $all_edge  "is_integrated_clock_gating_cell==false"]] } { set seq_cell_count 0 }
    # report VT
    set SVT    [sizeof_collection [get_cells -quiet -hierarchical -filter "ref_lib_cell_name=~${VT_GROUPS(SVT)}"]]
    set LVT    [sizeof_collection [get_cells -quiet -hierarchical -filter "ref_lib_cell_name=~${VT_GROUPS(LVT)}"]]
    set LVTLL  [sizeof_collection [get_cells -quiet -hierarchical -filter "ref_lib_cell_name=~${VT_GROUPS(LVTLL)}"]]
    set ULVTLL [sizeof_collection [get_cells -quiet -hierarchical -filter "ref_lib_cell_name=~${VT_GROUPS(ULVTLL)}"]]
    set ULVT   [sizeof_collection [get_cells -quiet -hierarchical -filter "ref_lib_cell_name=~${VT_GROUPS(ULVT)}"]]
    set EVT    [sizeof_collection [get_cells -quiet -hierarchical -filter "ref_lib_cell_name=~${VT_GROUPS(EVT)}"]]
    set count_all_vt [expr $SVT+$LVT+$LVTLL+$ULVTLL+$ULVT+$EVT]
    set SVT_perc [expr ($SVT*100.0)/($count_all_vt*1.0)]
    set LVT_perc [expr ($LVT*100.0)/($count_all_vt*1.0)]
    set LVTLL_perc [expr ($LVTLL*100.0)/($count_all_vt*1.0)]
    set ULVTLL_perc [expr ($ULVTLL*100.0)/($count_all_vt*1.0)]
    set ULVT_perc [expr ($ULVT*100.0)/($count_all_vt*1.0)]
    set EVT_perc [expr ($EVT*100.0)/($count_all_vt*1.0)]
    set fo [open reports/${STAGE}/preplace_count.rpt w]

    puts $fo [format "Leaf Instance count          : %7d "  $leaf_cell_count]
    puts $fo [format "Sequential Cells Count       : %7d "  $seq_cell_count]
    puts $fo [format "SVT                          : %3.2f%s" ${SVT_perc} %]
    puts $fo [format "LVT                          : %3.2f%s" ${LVT_perc} %]
    puts $fo [format "LVTLL                        : %3.2f%s" ${LVTLL_perc} %]
    puts $fo [format "ULVTLL                       : %3.2f%s" ${ULVTLL_perc} %]
    puts $fo [format "ULVT                         : %3.2f%s" ${ULVT_perc} %]
    puts $fo [format "EVT                          : %3.2f%s" ${EVT_perc} %]
    
    # for count Memory BITs
    foreach mem_module [lsort -u [get_db [get_db insts -if {.is_macro == true || .is_memory == true}] .base_cell.name ]] {
       puts $fo "MEMORYs                      : $mem_module [llength [get_db insts -if {.base_cell.name == ${mem_module}}]]"
    }
    
    # for transistors count :
    puts $fo "Leaf_Cells_Count             : [sizeof [get_cells -hier -filter "is_hierarchical == false && is_macro_cell == false"]] "

    close $fo
};#preplace_count 
#====================================================================================================================
proc check_unplace_ports { } {
  global STAGE 
  set if_exit_port_check 0
  if {[get_db place_global_place_io_pins]=="false"} {
      ###################################################################
      #                 results Dir.
      ###################################################################
      set dirname "reports"
      if {![file exist $dirname] == 1} {
      	exec 	mkdir reports
      } 
      ###################################################################
      puts "-I- checking for un-place Ports..."
      set OFILE [open  ${dirname}/${STAGE}/report_unplaced_ports.rpt w]
      set unplace_ports_list ""
      set count_vio 0
      foreach port [get_object_name [get_ports]] {
        if {[get_db [get_ports -quiet $port] .place_status] == "unplaced"} {
         lappend  unplace_ports_list $port 
         incr count_vio
        }
      };# foreach port ...

      if {$count_vio} {
         puts $OFILE "set unplaced_ports \{ \\"
         foreach port $unplace_ports_list {
           puts $OFILE "$port \\"
         }
         puts $OFILE "\}"
         set if_exit_port_check 1
      } else {
         puts $OFILE   "#==================================================================================="
         puts $OFILE   " PASS: All ports are placed.                                                      "
         puts $OFILE   "#==================================================================================="
      }

 }; # if get_db place_global_place_io_pins
 close $OFILE
 return $if_exit_port_check
};# check_unplace_ports

#====================================================================================================================
proc check_macro_placement { } {
  global STAGE 
  set if_exit_macro_check 0
      ###################################################################
      #                 results Dir.
      ###################################################################
      set dirname "reports"
      if {![file exist $dirname] == 1} {
      	exec 	mkdir reports
      } 
      ###################################################################
      puts "-I- checking for un-place Macros..."
      set OFILE [open  ${dirname}/${STAGE}/report_macro_placement.rpt w]
      set unplace_macros_list ""
      set count_vio 0
      if {[llength [get_db insts -if {.is_macro == true || .is_memory == true}]]} {
        foreach macro [get_db [get_db insts -if {.is_macro == true || .is_memory == true}] .name] {
          if {[get_db [get_cells -quiet $macro] .place_status] != "fixed"} {
           lappend  unplace_macros_list $macro 
           incr count_vio
          }
        };# foreach macro ...
        if {$count_vio} {
           puts $OFILE "set unfixed_macros \{ \\"
           foreach macro $unplace_macros_list {
             puts $OFILE "$macro \\"
           }
           puts $OFILE "\}"
           set if_exit_macro_check 1
        } else {
           puts $OFILE   "#==================================================================================="
           puts $OFILE   " PASS : All macros are placed and fixed.                                                      "
           puts $OFILE   "#==================================================================================="
        }
       } else {
           puts $OFILE   " No macros where found.                                                      "

       }
   close $OFILE
   return $if_exit_macro_check
};# check_macro_placement
#====================================================================================================================
proc cts_cell_name_info {} {
   puts "-I-  report_cts_cell_name_info ..."
   global STAGE
   set fo [open reports/${STAGE}/report_cts_cell_name_info.rpt w]
   set fot [open reports/${STAGE}/report_cts_cell_name_info_transposed.rpt w]
   set r [open tmp_cts_cell_name_info w]
   puts $r "[report_cts_cell_name_info ]"; close $r
   set fi [open tmp_cts_cell_name_info r]
   while {[gets $fi line]>=0} {
      if {(![regexp {Creators:} $line]) && ($line!="")} {
         set prefix [lindex $line 0]
         puts $fot "CTS_${prefix},[llength [get_db insts -if {.name == *CTS_${prefix}_*}]]"
         if {[llength [get_db insts -if {.name == *CTS_${prefix}_*}]] > 0} {
            puts $fo "CTS_$prefix    [llength [get_db insts -if {.name == *CTS_${prefix}_*}]]"
         }
      }
   }
  close $fo
  close $fot
 # exec rm tmp_cts_cell_name_info
};# cts_cell_name_info 

#=================================================================
# net length :
proc net_length {net} {
 set net [get_db [get_nets $net]]  
 set net_length [lsum [get_db $net .wires.length ]]
 return $net_length
}; #net_length 
#=================================================================
#=================================================================
# manhattan_length :
proc manhattan_length {pin1 pin2} {
  set manhattan_length 0
  if {($pin1!="") && ($pin2!="")} {
  if {[sizeof_collection [get_ports -quiet $pin1]]} {
     set pin1_type "port"
  } else {
     set pin1_type "pin"
  }
  if {[sizeof_collection [get_ports -quiet $pin2]]} {
     set pin2_type "port"
  } else {
     set pin2_type "pin"
  }
  if {($pin1_type=="pin") && ($pin2_type=="pin") } {
      set x_pin1 [get_property [get_pins $pin1] x_coordinate]
      set y_pin1 [get_property [get_pins $pin1] y_coordinate]
      set x_pin2 [get_property [get_pins $pin2] x_coordinate]
      set y_pin2 [get_property [get_pins $pin2] y_coordinate]
   }
  if {($pin1_type=="port") && ($pin2_type=="pin") } {
      set x_pin1 [get_property [get_ports $pin1] x_coordinate]
      set y_pin1 [get_property [get_ports $pin1] y_coordinate]
      set x_pin2 [get_property [get_pins $pin2] x_coordinate]
      set y_pin2 [get_property [get_pins $pin2] y_coordinate]
   }
  if {($pin1_type=="pin") && ($pin2_type=="port") } {
      set x_pin1 [get_property [get_pins $pin1] x_coordinate]
      set y_pin1 [get_property [get_pins $pin1] y_coordinate]
      set x_pin2 [get_property [get_ports $pin2] x_coordinate]
      set y_pin2 [get_property [get_ports $pin2] y_coordinate]
   }
  if {($pin1_type=="port") && ($pin2_type=="port") } {
      set x_pin1 [get_property [get_ports $pin1] x_coordinate]
      set y_pin1 [get_property [get_ports $pin1] y_coordinate]
      set x_pin2 [get_property [get_ports $pin2] x_coordinate]
      set y_pin2 [get_property [get_ports $pin2] y_coordinate]
   }

   set manhattan_length [expr abs($x_pin2-$x_pin1) + abs($y_pin2-$y_pin1)]
  };# if pin1 & pin2, NOT empty
  return $manhattan_length
};#manhattan_length

#=================================================================
proc route_quality_check { {min_route_length 100} } {
 # check route quality ONLT for fo=1
  global MIN_ROUTE_LENGTH
  global STAGE
  ###################################################################
  #                 results Dir.
  ###################################################################
  set dirname "reports"
  if {![file exist $dirname] == 1} {
  	exec 	mkdir reports
  } 
  ###################################################################
  set OFILE [open  $dirname/${STAGE}/report_route_quality_ratio.rpt w]
  puts "-I- Checking route quality ..."
  if {[info exists MIN_ROUTE_LENGTH]} {
     set min_distance ${MIN_ROUTE_LENGTH}
  } else {
     set min_distance $min_route_length
  }
  # Nets with FO==1
  set nets_to_check [get_db nets -if {(.is_power == false) && (.is_ground  == false) && (.is_physical_only == false) && (.num_loads == 1)}]
  set TFILE [open reports/tmp_report_file.rpt w]
  set EFILE [open reports/err_report_file.rpt w]
  foreach net $nets_to_check {
     set driver [get_db [get_db [get_nets $net]] .drivers.name]
     set lo [get_db [get_db [get_nets $net]] .loads.name]
     set sum_length [net_length $net]
     set manhattan_length [manhattan_length $driver $lo]
     if {$manhattan_length > 0} {
       set route_quality [expr $sum_length/$manhattan_length]
       if {$sum_length > $min_distance} {
          puts $TFILE [format "%5.2f \t\t %5.2f \t %5.2f \t %s " $route_quality $manhattan_length $sum_length [get_db $net .name]  ]
       }
    } else {
          puts $EFILE [format "%s \t\t %5.2f \t %5.2f \t %s " ERROR $manhattan_length $sum_length [get_db $net .name]  ]
    }
  }
  close $TFILE
  close $EFILE

  #exec cat reports/tmp_report_file.rpt | sort -nk2 -r > l.rpt
  exec cat reports/tmp_report_file.rpt | sort -nk1 -r > l.rpt
  set EIFILE [open reports/err_report_file.rpt]
  puts $OFILE "#================================================================================"
  puts $OFILE "#Route_Quality_Ration   Manhattan_Distance   Real_Distance   Net                  "
  puts $OFILE "#================================================================================"

  while {[gets $EIFILE line]>=0} {
   puts $OFILE "$line"
  }

  set IFILE [open l.rpt r]
  while {[gets $IFILE line]>=0} {
   puts $OFILE "$line"
  }
  if {[catch {exec cat reports/err_report_file.rpt | egrep ERROR}] == 0} {
   puts $OFILE "#================================================================================"
   puts $OFILE "# -I- Worst route quality ratio [lindex [exec head -n 1 l.rpt] 0] include ERRORS "
   puts $OFILE "#================================================================================"
  } else {
   puts $OFILE "#================================================================================"
   puts $OFILE "# -I- Worst route quality ratio [lindex [exec head -n 1 l.rpt] 0]  "
   puts $OFILE "#================================================================================"
  }
 close $OFILE
 exec rm l.rpt
 exec rm reports/tmp_report_file.rpt

};#route_quality_check
#====================================================================================================================
proc check_clock_ndr {   } {
   global STAGE
 ###################################################################
 #                 results Dir.
 ###################################################################
  set dirname "reports"
  if {![file exist $dirname] == 1} {
  	exec 	mkdir reports
  } 
 set OFILE [open  ${dirname}/${STAGE}/report_clock_nets_ndr_$STAGE.rpt w]
 set fo_tmp [open ${dirname}/${STAGE}/tmp_report_clk_ndr w]
 puts "-I-  Checking Clock Nets NDR ..."
 
 set ndr_name [get_db nets .wires.route_rule.name -unique]
 set all_clk_nets ""
 set number_of_clk_ndr_violations 0
 foreach net1 [get_db clock_trees .nets.name] {
   set net [get_db [get_nets $net1]]
   set fo  [get_db $net .num_loads] 
   set ndr [get_db $net .wires.route_rule.name -unique]
   set num_of_metals [llength [get_db $net .wires.layer.name]]
   set num_of_route_rule [llength [get_db $net .wires.route_rule.name]]
   set sum_length [net_length $net] 
     if {([lsearch  $ndr_name $ndr] == -1) || ($num_of_metals != $num_of_route_rule)} {   
       puts $fo_tmp "$sum_length        $fo        $net1     $num_of_route_rule\/$num_of_metals   $ndr     "
       incr number_of_clk_ndr_violations
     }
 } ; # foreach net ...
 close $fo_tmp
 if {$number_of_clk_ndr_violations} {
   exec cat  ${dirname}/${STAGE}/tmp_report_clk_ndr | sort -nk1 -r > l.rpt
   set IFILE [open l.rpt r]
   puts $OFILE "#========================================================================================"
   puts $OFILE "# Net_Length      FO         NET              num_of_route_roule/num_of_metals    NDR              "
   puts $OFILE "#========================================================================================"
   while {[gets $IFILE line]>=0} {
      puts $OFILE "$line"
   }
      puts $OFILE "#========================================="
      exec rm l.rpt
 }
 puts $OFILE "Clock tree nets NDR  $ndr_name"
 puts $OFILE "Clock tree nets NDR violations $number_of_clk_ndr_violations"
 close $OFILE
 exec rm ${dirname}/${STAGE}/tmp_report_clk_ndr
}; #check_clock_ndr
#====================================================================================================================
proc check_dcaps_around_clock_cells {{min_dcap_area 0.03213} {clk_cells_prefix "LPD"}} {
   # Criteria for PASS :
   #   1. At least one dcap beside clock cell
   #   2. dcap area >= MIN_DCAP_AREA/min_dcap_area

   # dcap cell list
    global DCAP_CELLS_LIST
    global MIN_DCAP_AREA
    global STAGE
    global CLK_CELLS_PREFIX
    ###################################################################
    #                 results Dir.
    ###################################################################
    set dirname "reports"
    if {![file exist $dirname] == 1} {
    	exec 	mkdir reports
    } 
    ###################################################################
    puts "-I- Checking DCAPs around clock cells ..."
    if {[info exists MIN_DCAP_AREA]} {
       set min_area ${MIN_DCAP_AREA}
    } else {
       # by default set to area of DCAP == F6LLAA_CCCAP3
       set min_area $min_dcap_area
    }
    if {[info exists CLK_CELLS_PREFIX]} {
       set cell_prefix ${CLK_CELLS_PREFIX}
    } else {
       set cell_prefix $clk_cells_prefix
    }
    set OFILE [open  ${dirname}/${STAGE}/report_missing_dcaps.rpt w]
 
    # generate clock list
     generate_clock_cells_list
     set clock_cells_list ""
     set fi_clk [open  reports/${STAGE}/clock_cells_list.rpt r]
     while {[gets $fi_clk line]>=0} {
         set clock_cells_list [concat $clock_cells_list [lindex $line 1]] 
     } 
    puts $OFILE "#=========================================================================" 
    puts $OFILE "# Info :                                                                  " 
    puts $OFILE "# List DCAP_CELLS_LIST : $DCAP_CELLS_LIST                               " 
    puts $OFILE "#=========================================================================" 
    
    foreach dcap_cell $DCAP_CELLS_LIST {
        set num_of_lib_cells_in [sizeof_collection [get_lib_cells -quiet $dcap_cell]]
        if {$num_of_lib_cells_in == 0} {
            puts $OFILE "-E-  can't find any lib cells for : $dcap_cell"
        }
     }
    puts $OFILE "#=========================================================================" 
    puts $OFILE "" 
    puts $OFILE "# List of clock elements , that failed dcap check:" 
    puts $OFILE "#=========================================================================" 
    puts $OFILE "# ref_name         Clock Inst                            Number of dcap  " 
    puts $OFILE "#=========================================================================" 
    set sort_dcap_cells_list [lsort -u [ get_property [get_lib_cells -quiet $DCAP_CELLS_LIST] name]]
    #set all_cells [get_object_name [ get_cells  -quiet -hierarchical -filter "is_hierarchical==false && is_macro_cell==false && is_pad_cell==false && is_black_box==false"]]
    set failed_dcap_counter 0
    foreach cell  $clock_cells_list {
    set count_dcap 0
    set side_left "NA"
    set side_right "NA"
         ## use for clk buffer/invter $cell_prefix cells, include cap no need to check for DCAP.
         set ref_clk_cell [get_property [get_cells -quiet $cell] ref_lib_cell_name]
         if {[regexp -inline $cell_prefix $ref_clk_cell]  == ""} { 
             set clk_cell_llx [get_db [get_cells -quiet $cell] .bbox.ll.x]
             set clk_cell_lly [get_db [get_cells -quiet $cell] .bbox.ll.y]
             set clk_cell_urx [get_db [get_cells -quiet $cell] .bbox.ur.x]
             set clk_cell_ury [get_db [get_cells -quiet $cell] .bbox.ur.y]
             set cells_beside_clk_cell [get_obj_in_area -polygon [get_db [get_cells -quiet $cell] .bbox]  -abut_only]
             foreach c $cells_beside_clk_cell {
               # check if the Cs linked to cell, on right / left
                set c_cell_llx [get_db $c .bbox.ll.x]
                set c_cell_lly [get_db $c .bbox.ll.y]
                set c_cell_urx [get_db $c .bbox.ur.x]
                set c_cell_ury [get_db $c .bbox.ur.y]
                # check if linked on left:
                if {($clk_cell_llx==$c_cell_urx) && ($clk_cell_lly==$c_cell_lly) && ($clk_cell_ury==$c_cell_ury)} {
                   if {[lsearch $sort_dcap_cells_list [get_db $c .base_cell.name]] > -1} {
                       incr count_dcap
                       set side_left "left"
                       set dcap_area_left [get_db $c .bbox.area]
                   }
                }
                # check if linked on right:
                if {($clk_cell_urx==$c_cell_llx) && ($clk_cell_lly==$c_cell_lly) && ($clk_cell_ury==$c_cell_ury)} {
                   if {[lsearch $sort_dcap_cells_list [get_db $c .base_cell.name]] > -1} {
                       incr count_dcap
                       set side_left "right"
                       set dcap_area_right [get_db $c .bbox.area]
                   }
                }

             };# foreach cells beside ...
        # print results:
         # 1. we got 2 DCAPs
         if {($side_left=="left") && ($side_right=="right")} {
           if {($dcap_area_left >= $min_area) || ($dcap_area_right >= $min_area)} {
             puts $OFILE "$ref_clk_cell  $cell $count_dcap PASS"
           } else {
             puts $OFILE "$ref_clk_cell  $cell $count_dcap FAILED(DCAPs AREA)"
           }
         }  
         # 2. we got 1 DCAP, on left
         if {($side_left=="left") && ($side_right=="NA")} {
           if {($dcap_area_left >= $min_area) } {
             puts $OFILE "$ref_clk_cell  $cell $count_dcap PASS(left)"
           } else {
             puts $OFILE "$ref_clk_cell  $cell $count_dcap FAILED(left DCAP AREA)"
           }
         }  
         # 3. we got 1 DCAP, on right
         if {($side_left=="NA") && ($side_right=="right")} {
           if {($dcap_area_right >= $min_area) } {
             puts $OFILE "$ref_clk_cell  $cell $count_dcap PASS(right)"
           } else {
             puts $OFILE "$ref_clk_cell  $cell $count_dcap FAILED(right DCAP AREA)"
           }
         }  
         # 4. we got 0 DCAP, on right
         if {($side_left=="NA") && ($side_right=="NA")} {
             puts $OFILE "$ref_clk_cell  $cell $count_dcap FAILED"
             incr failed_dcap_counter
         }  
       };# clk cells...
    };# foreach cell...

         puts $OFILE "#========================================================================"
         puts $OFILE "# -I- Found $failed_dcap_counter clock cells with DCAPs violations       "
         puts $OFILE "#========================================================================"
     
    close $OFILE
};# check_dcaps_around_clock_cells  
#===========================================================================================
proc check_dcaps_around_ff_cells {{min_dcap_area 0.03213} {filter_ff_cells "Not Available"}  } {
    global STAGE
   # dcap cell list
    global DCAP_CELLS_LIST
    global MIN_DCAP_AREA
    ###################################################################
    #                 results Dir.
    ###################################################################
    set dirname "reports"
    if {![file exist $dirname] == 1} {
    	exec 	mkdir reports
    } 
    ###################################################################
    puts "-I- Checking DCAPs around FFs cells ..."
    if {[info exists MIN_DCAP_AREA]} {
       set min_area ${MIN_DCAP_AREA}
    } else {
       # by default set to area of DCAP == F6LLAA_CCCAP3
       set min_area $min_dcap_area
    }

    if {[info exists FILTER_FF_LIST]} {
       # check if need to prepare the filter list!!!!!!
       set filter_ff  ${FILTER_FF_LIST}
    } else {
       set filter_ff $filter_ff_cells
    }
    set OFILE [open  ${dirname}/${STAGE}/report_missing_dcaps_around_ff_cells.rpt w]

    puts $OFILE "#=========================================================================" 
    puts $OFILE "# Info :                                                                  " 
    puts $OFILE "# List DCAP_CELLS_LIST : $DCAP_CELLS_LIST                               " 
    puts $OFILE "#=========================================================================" 
    # FFs
    set all_ff [get_object_name [filter_collection [all_registers -edge_triggered] "is_integrated_clock_gating_cell==false && is_memory_cell == false && is_macro_cell == false"]]
    

    foreach dcap_cell $DCAP_CELLS_LIST {
        set num_of_lib_cells_in [sizeof_collection [get_lib_cells -quiet $dcap_cell]]
        if {$num_of_lib_cells_in == 0} {
            puts $OFILE "-E-  can't find any lib cells for : $dcap_cell"
        }
    }
    puts $OFILE "#=========================================================================" 
    puts $OFILE "" 
    puts $OFILE "# List of clock elements , that failed dcap check:" 
    puts $OFILE "#=========================================================================" 
    puts $OFILE "# ref_name         Clock Inst                            Number of dcap  " 
    puts $OFILE "#=========================================================================" 
    set sort_dcap_cells_list [lsort -u [ get_property [get_lib_cells -quiet $DCAP_CELLS_LIST] name]]
    set failed_dcap_counter 0
    foreach cell  $all_ff {
    set count_dcap 0
    set side_left "NA"
    set side_right "NA"
         set ref_ff_cell [get_property [get_cells -quiet $cell] ref_lib_cell_name]
         if {[regexp -inline $filter_ff $ref_ff_cell]  == ""} { 
             set ff_cell_llx [get_db [get_cells -quiet $cell] .bbox.ll.x]
             set ff_cell_lly [get_db [get_cells -quiet $cell] .bbox.ll.y]
             set ff_cell_urx [get_db [get_cells -quiet $cell] .bbox.ur.x]
             set ff_cell_ury [get_db [get_cells -quiet $cell] .bbox.ur.y]
             set cells_beside_ff_cell [get_obj_in_area -polygon [get_db [get_cells -quiet $cell] .bbox]  -abut_only]
             foreach c $cells_beside_ff_cell {
               # check if the Cs linked to cell, on right / left
                set c_cell_llx [get_db $c .bbox.ll.x]
                set c_cell_lly [get_db $c .bbox.ll.y]
                set c_cell_urx [get_db $c .bbox.ur.x]
                set c_cell_ury [get_db $c .bbox.ur.y]
                # check if linked on left:
                if {($ff_cell_llx==$c_cell_urx) && ($ff_cell_lly==$c_cell_lly) && ($ff_cell_ury==$c_cell_ury)} {
                   if {[lsearch $sort_dcap_cells_list [get_db $c .base_cell.name]] > -1} {
                       incr count_dcap
                       set side_left "left"
                       set dcap_area_left [get_db $c .bbox.area]
                   }
                }
                # check if linked on right:
                if {($ff_cell_urx==$c_cell_llx) && ($ff_cell_lly==$c_cell_lly) && ($ff_cell_ury==$c_cell_ury)} {
                   if {[lsearch $sort_dcap_cells_list [get_db $c .base_cell.name]] > -1} {
                       incr count_dcap
                       set side_left "right"
                       set dcap_area_right [get_db $c .bbox.area]
                   }
                }

             };# foreach cells beside ...
        # print results:
         # 1. we got 2 DCAPs
         if {($side_left=="left") && ($side_right=="right")} {
           if {($dcap_area_left >= $min_area) || ($dcap_area_right >= $min_area)} {
             puts $OFILE "$ref_ff_cell  $cell $count_dcap PASS"
           } else {
             puts $OFILE "$ref_ff_cell  $cell $count_dcap FAILED(DCAPs AREA)"
           }
         }  
         # 2. we got 1 DCAP, on left
         if {($side_left=="left") && ($side_right=="NA")} {
           if {($dcap_area_left >= $min_area) } {
             puts $OFILE "$ref_ff_cell  $cell $count_dcap PASS(left)"
           } else {
             puts $OFILE "$ref_ff_cell  $cell $count_dcap FAILED(left DCAP AREA)"
           }
         }  
         # 3. we got 1 DCAP, on right
         if {($side_left=="NA") && ($side_right=="right")} {
           if {($dcap_area_right >= $min_area) } {
             puts $OFILE "$ref_ff_cell  $cell $count_dcap PASS(right)"
           } else {
             puts $OFILE "$ref_ff_cell  $cell $count_dcap FAILED(right DCAP AREA)"
           }
         }  
         # 4. we got 0 DCAP, on right
         if {($side_left=="NA") && ($side_right=="NA")} {
             puts $OFILE "$ref_ff_cell  $cell $count_dcap FAILED"
             incr failed_dcap_counter
         }  
       };# ff cells...
    };# foreach cell...

         puts $OFILE "#========================================================================"
         puts $OFILE "# -I- Found $failed_dcap_counter FFs with DCAPs violations.            "
         puts $OFILE "#========================================================================"
     
    close $OFILE
 

 };#check_dcaps_around_ff_cells
#===========================================================================================
proc check_nets_length { {min_route_length 100}   } {
  #=========================================================================================  
  # NOTE:
  #   we can add filter to reduce some of the nets. 
  #=========================================================================================  
    global STAGE
    global MIN_ROUTE_LENGTH
    ###################################################################
    #                 results Dir.
    ###################################################################
    set dirname "reports"
    if {![file exist $dirname] == 1} {
    	exec 	mkdir reports
    } 
    ###################################################################
     set OFILE [open  ${dirname}/${STAGE}/report_nets_length_${STAGE}.rpt w]
     set TFILE [open ${dirname}/${STAGE}/tmp_report_file.rpt w]
     puts "-I- Long Nets Check ..."
     if {[info exists MIN_ROUTE_LENGTH]} {
        set min_distance ${MIN_ROUTE_LENGTH}
     } else {
        set min_distance $min_route_length
     }
     set all_nets_to_check [get_db nets .name ]
     ## option to filter spesific nets ...
     # if {[info exists vars(filter_long_nets_check)]} {
     #  foreach n $vars(filter_long_nets_check) {
     #    set all_nets_to_check [lsearch -inline -all -not $all_nets_to_check $n]
     #  }
     # }
     set number_of_violated_nets 0
     foreach net $all_nets_to_check {
        set fo [get_db [get_db [get_nets -quiet $net]] .num_loads]
        if {[sizeof_collection [get_nets -quiet $net]]} {
           set net_l [net_length $net]
        } else {
           set net_l 0 ; # didn't find this net in the design
        }
        if {$net_l >= $min_distance} { 
           puts $TFILE "$net_l \t $fo \t $net"
           incr number_of_violated_nets
        } 
     };# foreach net ...
     close $TFILE
    exec cat $dirname/${STAGE}/tmp_report_file.rpt | sort -nk1 -r > l.rpt
    set IFILE [open l.rpt r]
    puts $OFILE "#============================================================"
    puts $OFILE "#Net_distance    FO         Net_name                           "
    puts $OFILE "#============================================================"

   while {[gets $IFILE line]>=0} {
       puts $OFILE "$line"
   }

    puts $OFILE "#===============================================================" 
    puts $OFILE "#==  Found $number_of_violated_nets Long Nets > $min_distance\[um\]"
    puts $OFILE "#===============================================================" 

   exec rm l.rpt
   exec rm $dirname/${STAGE}/tmp_report_file.rpt
   close $OFILE  
};# check_nets_length 

#====================================================================================================================
proc io_buffers_statistics {} {
    puts "-I- Check IO buffers statistics ..."
    global STAGE
    global USEABLE_IOBUFFER_CELL
    set OFILE [open reports/${STAGE}/io_buffers_driving_ports.rpt w]
    set MFILE [open reports/${STAGE}/measure_distance_between_io_buffers_to_ports.rpt w]
    set CFILE [open reports/${STAGE}/io_buffers_statistics.csv w]
    puts $OFILE "#================================================================= "
    puts $OFILE "# PORT              direction   number_of_connection    connected_to "
    puts $OFILE "#================================================================="
    set sort_io_buf_list [lsort -u [ get_property [get_lib_cells -quiet $USEABLE_IOBUFFER_CELL] name]]

    set buf_in_count 0
    set buf_out_count 0
    set status_report 1
    set ref_name_list "" 
    set count_io_buf_violations 0
    set TFILE [open reports/${STAGE}/tmp_report_file.rpt w]
    foreach port [ get_db [get_db ports -if {.is_clock_used_as_clock== false}] .name] {
         set port_direction [get_db [get_ports -quiet $port] .direction]
        # set connect_to [get_db [get_ports $port] .net.loads.name]
         set connect_to [lsearch -all -inline -not -exact [get_object_name [all_connected $port -leaf]] $port]
         set ref_name [get_db [get_cells -quiet -of_objects [get_pins -quiet $connect_to]] .base_cell.name]
         if {[llength $connect_to] > 1} {
             puts $OFILE "$port   $port_direction           [llength $connect_to]   $connect_to"
             set status_report 0
             incr count_io_buf_violations

         } elseif {[llength $connect_to] == 1} {
             if {[lsearch -exact $sort_io_buf_list $ref_name] == -1} {
               puts $OFILE "$port   $port_direction           [llength $connect_to]   ${connect_to}($ref_name)"
               #puts $OFILE "$port   $port_direction           [llength $connect_to]   "
               set status_report 0
               incr count_io_buf_violations
             }
         }
  ## count IO buffers
         if {([llength $connect_to] == 1) && ([lsearch -exact $sort_io_buf_list $ref_name] > -1)} {
            if {$port_direction=="in"} {
              incr buf_in_count
            } elseif {$port_direction=="out"} {
              incr buf_out_count
            }
            lappend ref_name_list $ref_name
         }

       set fo [llength  $connect_to] 
       set net_port_length [net_length $port]
          if {[lsearch -exact $sort_io_buf_list $ref_name] > -1} {
             puts $TFILE "$port  [get_db [get_ports $port] .direction]   $fo       $net_port_length "
          } else {
             puts $TFILE "$port  [get_db [get_ports $port] .direction]   $fo       $net_port_length (NOT in IOBUF list)"
          }
  
     };# foreach port ...
     close $TFILE
    exec cat  reports/${STAGE}/tmp_report_file.rpt | sort -nk4 -r  > l.rpt
    set IFILE [open l.rpt r]
    puts $MFILE "#======================================================"
    puts $MFILE "# PORT      direction       FO            actual_langth"
    puts $MFILE "#======================================================"
    while {[gets $IFILE line]>=0} {
       puts $MFILE "$line"
    }

     
# check if there was a problem
    puts $CFILE "Total IO buffers  [expr $buf_in_count+$buf_out_count] "
    puts $CFILE "Input buffers  $buf_in_count"
    puts $CFILE "Output buffers  $buf_out_count"
    ## base cell - statistics
   set ref_name_list_u [lsort -u $ref_name_list]
   foreach ref $ref_name_list_u {
      puts $CFILE "$ref   [llength [lsearch -exact -all $ref_name_list $ref]]"
   }
    puts $OFILE "#================================================================="

 if {$status_report == 0} {
    puts $OFILE "-E- found $count_io_buf_violations, IO buffer connection violation , please check above "

 } elseif {$status_report} {
    puts $OFILE "-I- found $count_io_buf_violations, IO buffer connection violation."
    
 }

    puts $OFILE "#================================================================="

    puts $MFILE "#================================================================="
    puts $MFILE "MAX length between port & io buf [lindex [exec head -n 1 l.rpt] 3] "
    puts $MFILE "#================================================================="

  exec rm l.rpt
  exec rm reports/${STAGE}/tmp_report_file.rpt
  close $OFILE
  close $CFILE
  close $MFILE
};# io_buffers_statistics
#====================================================================================================================
proc io_sampled {} {
    puts "-I- Check IO Sampled ..."
    global STAGE
    global USEABLE_IOBUFFER_CELL
    set OFILE [open reports/${STAGE}/io_sampled.rpt w]
    puts $OFILE "#================================================================= "
    puts $OFILE "# PORT              direction          connected to "
    puts $OFILE "#================================================================="
    set status_report 1
    set count_io_buf_violations 0

    foreach port [ get_db [get_db ports -if {.is_clock_used_as_clock== false}] .name] {
         set port_direction [get_db [get_ports -quiet $port] .direction]
         if {$port_direction == "in"} {
            set port_connections [get_object_name [all_fanout -from $port -endpoints_only]]
         } elseif {$port_direction == "out"} {
            set port_connections [get_object_name [all_fanin -to $port -startpoints_only]]
         }
         foreach cell $port_connections {
            set ref_name [get_db [get_cells -quiet -of_objects [get_pins -quiet $cell]] .base_cell.name]
            if {([regexp {_MBIT_} $cell]) && ([regexp {BSDFF} $ref_name])} {
               puts $OFILE "$port  $port_direction  $cell"
               incr count_io_buf_violations
            }
         }
     };# foreach port ...

  
    puts $OFILE "#================================================================="

 if {$status_report} {
    puts $OFILE "-E- found $count_io_buf_violations MBITs , Sampled PORTs . "

 } elseif {$status_report == 0} {
    puts $OFILE "-I- found $count_io_buf_violations MBITs, Sampled PORTs."
    
 }

    puts $OFILE "#================================================================="

  close $OFILE
};# io_sampled
#====================================================================================================================
proc physical_cells {} {
   global PROJECT
   global STAGE
   global TAPCELL
   global ENDCAPS
   global ECO_DCAP_LIST
   global PRE_PLACE_ECO_DCAP
   global PRE_PLACE_DECAP

    set endcap_list ""
    set tap_list ""
    set fpgfill_list ""
    set fpdcap_list ""
    set endcap_list_tmp ""
    foreach ecap [array names ENDCAPS] {
       lappend endcap_list_tmp $ENDCAPS($ecap)
    }
   regsub  -all "\{|\}" $endcap_list_tmp  " " endcap_list
     # search  list for TAPs:
     # set TAPCELL "{F6LLAA_TIESMALL rule 15.8 boundary_layer LUP_SRM boundary_rule 15.8} {F6LLAA_TIE rule 22.5}"
     set tap_list [concat [lindex [lindex $TAPCELL 1] 0] [lindex [lindex $TAPCELL 0] 0]]
     # search  list for FPGFILL:
     set fpgfill_list [concat $PRE_PLACE_ECO_DCAP $ECO_DCAP_LIST]
     # search  list for FPDCAP:
     set fpdcap_list $PRE_PLACE_DECAP

      puts "-I- physical cells statistics..."
   set OFILE [open  reports/${STAGE}/reports_physical_cells.rpt w]
   puts $OFILE "cell_type  count"
   puts $OFILE "================"
   # ENDCAP cells
   set endcap_count 0
   foreach cell [get_db insts *ENDCAP*] {
     if {[lsearch -exact $endcap_list [get_db $cell .base_cell.name]] > -1 } {
        incr endcap_count 
     }
   }
    puts $OFILE "ENDCAP  $endcap_count"

   set tap_count 0
   foreach cell [get_db insts *TAP*] {
     if {[lsearch -exact $tap_list [get_db $cell .base_cell.name]] > -1 } {
        incr tap_count 
     }
   }
    puts  $OFILE "TAP  $tap_count"

   # FPGFILL cells
   set fpgfill_count 0
   foreach cell [get_db insts *FPGFILL*] {
     if {[lsearch -exact $fpgfill_list [get_db $cell .base_cell.name]] > -1 } {
        incr fpgfill_count 
     }
   }
    puts  $OFILE "FPGFILL  $fpgfill_count"

   # FPDCAP cells
   set fpdcap_count 0
   foreach cell [get_db insts *FPDCAP*] {
     if {[lsearch -exact $fpdcap_list [get_db $cell .base_cell.name]] > -1 } {
        incr fpdcap_count 
     }
   }
    puts  $OFILE "FPDCAP  $fpdcap_count"
   

    close $OFILE
};# physical_cells
#====================================================================================================================
proc dcap_cells {} {
   global ECO_DCAP_LIST
   global DCAP_CELLS_LIST
   global STAGE
   puts "-I- DCAP cells statistics..."
   set fo [open reports/${STAGE}/report_dcap_cells.rpt w]
   puts $fo "#==============================================="
   puts $fo "#DACP_LIST         cell_name           count   "
   puts $fo "#==============================================="
   set total_dcap_cells 0
   set total_eco_dcap 0
   set dcap_cells_list ""
   set eco_dcap_list ""
   foreach  dcap_cell $DCAP_CELLS_LIST {
     set tmp_dcap_cells [get_db insts -if {.base_cell.name == ${dcap_cell}}]
     lappend dcap_cells_list $tmp_dcap_cells
     if {[llength $tmp_dcap_cells]} {
       set total_dcap_cells [expr $total_dcap_cells+[llength $tmp_dcap_cells]]  
       puts $fo "DCAP_CELLS_LIST     $dcap_cell     [llength $tmp_dcap_cells]"
     }      
   }
  
   foreach  eco_dcap $ECO_DCAP_LIST {
     set tmp_eco_dcap [get_db insts -if {.base_cell.name == ${eco_dcap}}] 
     lappend eco_dcap_list $tmp_eco_dcap
     if {[llength $tmp_eco_dcap]} {
       set total_eco_dcap [expr $total_eco_dcap+[llength $tmp_eco_dcap]]  
       puts $fo "ECO_DCAP_LIST     $eco_dcap     [llength $tmp_eco_dcap]"    
     }  
   }
   

   puts $fo "#=========================================="
   puts $fo "Total_number_from_dcap_cells_list    $total_dcap_cells"
   puts $fo "Total_number_from_eco_dcap_list      $total_eco_dcap"
   close $fo
   
   deselect_obj -all
   regsub -all "{|}" $dcap_cells_list "" dcap_cells_list_final
   gui_highlight  $dcap_cells_list_final -auto_color
   be_snapshot -file_name reports/chip_finish/snapshot/dcap_cells_list.gif
 
  
   deselect_obj -all
   regsub -all "{|}" $eco_dcap_list "" eco_dcap_list_final
   gui_highlight  $eco_dcap_list_final -auto_color
   be_snapshot -file_name reports/chip_finish/snapshot/eco_dcap_list.gif

};#dcap_cells
#====================================================================================================================

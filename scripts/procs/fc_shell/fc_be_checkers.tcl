
#====================================================================================================================
# All of these PROCs, generate reports for the be_checklist.tcl
#====================================================================================================================
#====================================================================================================================
proc list2row {list} {
   if {[llength $list] > 0} {
     set list_2_row ""
     foreach ele $list {
        lappend list_2_row $ele 
     }
     return $list_2_row
   } else {
     return $list
   }
};#list2row
#====================================================================================================================

proc preplace_count {} {
    global STAGE
    puts "-I- Preplace count ..."
    set fo [open reports/${STAGE}/preplace_count.rpt w]
    # for count Memory BITs
    foreach mem_module [lsort -u  [get_attribute [get_cells -quiet -hier -filter "is_hierarchical == false && is_hard_macro == true"] ref_name ]]  {
       puts $fo  "MEMORYs                      : $mem_module [sizeof_collection [get_cells -hierarchical -filter "ref_name==${mem_module}" ]]"
    }
    
    # for transistors count :
    puts $fo "Leaf_Cells_Count             : [sizeof_collection [get_flat_cells]] "

    close $fo
};# preplace_count
#====================================================================================================================
proc physical_cells {} {
   global PROJECT
   global STAGE
   global RUNNING_DIR
   puts "-I- physical cells statistics..."
   set OFILE [open  reports/${STAGE}/reports_physical_cells.rpt w]
   puts $OFILE "cell_type  count"
   puts $OFILE "================"
   puts  $OFILE "TAP     [sizeof_collection [get_cells -hierarchical -filter "ref_name=~*_TIE* || ref_name=~*_BORDER*TIE* || ref_name=~*FILLERWALL* "]]"
   puts  $OFILE "ENDCAP  [sizeof_collection [get_cells -hierarchical -filter "ref_name=~*_BORDER* && ref_name!~*_BORDER*TIE*"]]"
   puts  $OFILE "FPGFILL [sizeof_collection [get_cells -hierarchical -filter "name=~*FPGFILL*"]]"
   puts  $OFILE "FPDCAP  [sizeof_collection [get_cells -hierarchical -filter "name=~*FPDCAP*"]]"

    close $OFILE
};# physical_cells
#====================================================================================================================
#====================================================================================================================
proc check_macro_placement { } {
  global STAGE 
  global RUNNING_DIR  
  set if_exit_macro_check 0
      puts "-I- checking for un-place Macros..."
      set OFILE [open  reports/${STAGE}/report_macro_placement.rpt w]
      set unplace_macros_list ""
      set count_vio 0
      if {[sizeof_collection [get_cells -hierarchical -filter "is_hard_macro==true || is_memory_cell==true"]]} {
        foreach macro [get_object_name [get_cells -hierarchical -filter "is_hard_macro==true || is_memory_cell==true"]] {
          if {[get_attribute -quiet $macro physical_status] != "fixed"} {
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
           puts $OFILE   "#==================================================================================="
           puts $OFILE   " FAILED : macro placement !!!                                                      "
           puts $OFILE   "#==================================================================================="
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
proc check_unplace_ports { } {
  global STAGE 
  set if_exit_port_check 0
      puts "-I- checking for un-place Ports..."
      set OFILE [open  reports/${STAGE}/report_unplaced_ports.rpt w]
      set unplace_ports_list ""
      set count_vio 0
      foreach port [get_object_name  [get_ports]] {
       if {(([lindex [get_attribute -quiet $port bbox] 0 0] < 1) && (([lindex [get_attribute -quiet $port bbox] 0 1] < 1))) || (![regexp {M} [get_object_name [get_attribute -quiet $port layer]]])} {
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
         puts $OFILE   "#==================================================================================="
         puts $OFILE   " FAILED: ports placement !!!                                                      "
         puts $OFILE   "#==================================================================================="
         set if_exit_port_check 1
      } else {
         puts $OFILE   "#==================================================================================="
         puts $OFILE   " PASS: All ports are placed.                                                      "
         puts $OFILE   "#==================================================================================="
      }

 close $OFILE
 return $if_exit_port_check
};# check_unplace_ports
#====================================================================================================================
proc clock_tree_cells_check { } {
    global STAGE
    global CTS_INVERTER_CELLS_TOP
    global CTS_INVERTER_CELLS_TRUNK
    global CTS_INVERTER_CELLS_LEAF 
    global CTS_LOGIC_CELLS
    global CTS_CLOCK_GATING_CELLS
    puts "-I- Report clock tree cells Violation ..."

      set OFILE [open reports/${STAGE}/reports_clock_tree_cells_violations.rpt w]
      set cts_clk_cell_ref_name [concat $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]
      
      puts $OFILE "#=============================================="
      puts $OFILE "#      Allowed clock tree Cells list:"
      puts $OFILE "#=============================================="
      puts $OFILE "# $cts_clk_cell_ref_name"
      puts $OFILE "#=============================================="
      puts $OFILE "# list of clock tree violation:"
      puts $OFILE "#=============================================="
      puts $OFILE "# base_name      cell_name"
      set count_clk_tree_vio 0
      set clock_cells_list [lsort -u [get_object_name [get_attribute [get_clock_tree_pins -filter !is_clock_pin] cell]]]
      set clock_cells_refname_list [get_attribute [get_cells $clock_cells_list] ref_name]
      set reduce_clock_cells_refname_list $clock_cells_refname_list
      foreach rname $cts_clk_cell_ref_name {
         set reduce_clock_cells_refname_list [lsearch -all -exact -inline -not $reduce_clock_cells_refname_list $rname]
      }

      foreach  clk_tree_refn [lsort -u $reduce_clock_cells_refname_list] {
         foreach loc [lsearch -all -exact $clock_cells_refname_list $clk_tree_refn] { 
           puts $OFILE " [lindex $clock_cells_refname_list $loc] [lindex $clock_cells_list $loc]"
           incr count_clk_tree_vio
         };# foreach loc ...
      };# foreach

      puts $OFILE "#=============================================="
      puts $OFILE ""
      puts $OFILE "#-------------------------------------------"
      puts $OFILE "clock_tree_Cells_violations $count_clk_tree_vio "
      puts $OFILE "#-------------------------------------------"

      close $OFILE
 };#clock_tree_cells_check 
#====================================================================================================================
 proc check_clock_to_each_clk_pin { } {
    global STAGE
    puts "-I- Check the clock to each clock pin..."
    set fo [open reports/${STAGE}/reports_clock_to_each_clk_pin.rpt w]
    set clock_list [lsort -u [get_object_name [get_clocks [get_clocks -filter "name!~*virtual_*"] -filter "name!~*cdc"]]]
    set clock_pin_violations 0
    ##
    puts $fo "#==========================================" 
    puts $fo "#clock                    clock_pin        "
    puts $fo "#=========================================="
     set pins_clk [get_clock_tree_pins -filter is_clock_pin]
     set count_clk_pins [sizeof_collection $pins_clk]
     foreach clk_pin [get_object_name $pins_clk] {
       set connect_to_clk 0
       set all_fanin_to [all_fanin -quiet -flat -to $clk_pin -trace_arcs all -startpoints_only]
       if {[sizeof_collection $all_fanin_to]} {
          set clk_pin_connected [get_object_name $all_fanin_to]
          foreach clk $clk_pin_connected {
            if {[lsearch -exact $clock_list $clk] != -1} {
               incr connect_to_clk
            }
          }
       }
       if {$connect_to_clk == 0} {
          puts $fo "[get_object_name $all_fanin_to]  $clk_pin "
          incr clock_pin_violations
       }

     };# end foreach clk_pin... 
     puts $fo ""
     puts $fo "#=========================================="
     puts $fo "clock_pins_not_connect_to_clock $clock_pin_violations"
     puts $fo "#=========================================="
   close $fo
 };# check_clock_to_each_clk_pin
#====================================================================================================================
proc check_clock_ndr { }  { 
    global STAGE
    puts "-I- Check clock NDR, routing_rule..."
    set fo [open reports/${STAGE}/report_clock_ndr_violations.rpt w]
    set clk_nets [get_nets -of_objects [get_clock_tree_pins]] 
    puts $fo "#==========================================" 
    puts $fo "#route_rule                      clk_net   "
    puts $fo "#=========================================="
    set count_ndr_violation 0
    foreach net [get_object_name $clk_nets] {
      if {![regexp {NDR} [get_attribute -quiet [get_nets -quiet $net] routing_rule]]} {
         puts $fo "[get_attribute $net routing_rule]    $net"
         incr count_ndr_violation
      }
    }
    puts $fo ""
    puts $fo "#==========================================" 
    puts $fo "clock_ndr_violations $count_ndr_violation"
    puts $fo "#==========================================" 

    close $fo
 };# check_clock_ndr
#====================================================================================================================
proc buf_inv_info { } {
   global STAGE
   puts "-I- count buf & inv ..."
   if {[file exist reports/${STAGE}/count_buf_inv.rpt]} {
      set fo [open reports/${STAGE}/reports_buf_inv_count.rpt w]
      set fot [open reports/${STAGE}/reports_buf_inv_count_trans.rpt w]
      exec cat reports/${STAGE}/count_buf_inv.rpt | egrep {\):} > tmp_count
      set fi [open tmp_count r]
      while {[gets $fi line]>=0} {
         if {[regexp {[0-9]} [lindex [split $line ":"] 1 0]]} {
            puts $fo "[lindex [split $line ":"] 0]:   [regsub {,} [lindex [split $line ":"] 1 0] {}]"
            puts $fot "[regsub -all {\(|\)} [lindex [lindex [split $line ":"] 0] end] {}],[regsub {,} [lindex [split $line ":"] 1 0] {}]"
         } else {
            puts $fot "[regsub -all {\(|\)} [lindex [lindex [split $line ":"] 0] end] {}],0"
         }
      }
    exec rm tmp_count
    close $fo
    close $fot
   }
 }; #buf_inv_info
#====================================================================================================================
proc io_sampled {} {
    puts "-I- Check IO Sampled ..."
    global STAGE
    set OFILE [open reports/${STAGE}/io_sampled.rpt w]
    if {[file exist reports/${STAGE}/report_multibit.rpt]} {
       set fim [open reports/${STAGE}/report_multibit.rpt r]
       set count_io_buf_violations 0
       set mbit_list ""
       while {[gets $fim line]>=0} {
          if {[regexp {E*_BSDFF*} $line]} {
            lappend mbit_list [lindex $line 0]
          }
       }

       puts $OFILE "#================================================================= "
       puts $OFILE "# list MBIT used : [list2row $mbit_list] "
       puts $OFILE "#================================================================="
       puts $OFILE "#================================================================= "
       puts $OFILE "# PORT              direction          connected to "
       puts $OFILE "#================================================================="

      foreach port [get_attribute -quiet [get_ports -quiet -filter "is_clock_used_as_clock==false&&name!=VSS&&name!=VDD"] name] {
         set port_direction [get_attribute -quiet [get_ports -quiet $port] direction]
         if {$port_direction == "in"} {
            set port_connections [get_object_name [all_fanout -from $port -endpoints_only]]
         } elseif {$port_direction == "out"} {
            set port_connections [get_object_name [all_fanin -to $port -startpoints_only]]
         }
         set pin_count 0
         foreach rm [get_attribute -quiet  [get_cells -quiet -of_objects [get_pins -quiet  $port_connections]] ref_name] {
            if {[lsearch $mbit_list $rm]!=-1} {
               puts $OFILE "$port  $port_direction  [lindex $port_connections $pin_count] (${rm})"
               incr count_io_buf_violations
            }
            incr pin_count
         }

      };# foreach port...
       puts $OFILE "#================================================================= "
       puts $OFILE " found_ports_sampled_by_mbit $count_io_buf_violations"
       puts $OFILE "#================================================================="
      
    } else {
       puts $OFILE "#================================================================= "
       puts $OFILE " found_ports_sampled_by_mbit NA"
       puts $OFILE "#================================================================="
    }
    close $OFILE
 };#io_sampled
#====================================================================================================================
proc io_buffers_statistics {} {
    puts "-I- Check IO buffers statistics ..."
    global STAGE
    global USEABLE_IOBUFFER_CELL
    set OFILE [open reports/${STAGE}/io_buffers_driving_ports.rpt w]
    set MFILE [open reports/${STAGE}/measure_distance_between_io_buffers_to_ports.rpt w]
    set CFILE [open reports/${STAGE}/io_buffers_statistics.csv w]
    puts $OFILE "#=========================================================================" 
    puts $OFILE "# Info :                                                                  " 
    puts $OFILE "# List USEABLE_IOBUFFER_CELL : [list2row $USEABLE_IOBUFFER_CELL]          " 
    puts $OFILE "#=========================================================================" 
    puts $OFILE "#================================================================= "
    puts $OFILE "# PORT              direction   number_of_connection    connected_to "
    puts $OFILE "#================================================================="
    set sort_io_buf_list [lsort -u [ get_attribute -quiet [get_lib_cells -quiet $USEABLE_IOBUFFER_CELL] name]]
     # exclude list for IO Buf
      set exclude_list_tmp ""
      if {[file exist excNetFileName.txt]} {
         set fi [open excNetFileName.txt r]
         while {[gets $fi line]>=0} {
            lappend exclude_list_tmp $line
         }
         set exclude_list [regsub -all "\{|\}" $exclude_list_tmp ""]
      } else {
        set exclude_list $exclude_list_tmp
      }
    set buf_in_count 0
    set buf_out_count 0
    set status_report 1
    set ref_name_list "" 
    set count_io_buf_violations 0
    set TFILE [open reports/${STAGE}/tmp_report_file.rpt w]
    foreach port [get_attribute -quiet [get_ports -quiet -filter "is_clock_used_as_clock==false&&name!=VSS&&name!=VDD"] name] {
    # puts $port
     set port_direction [get_attribute -quiet [get_ports -quiet $port] direction]
     set connect_to [lsearch -all -inline -not -exact [get_object_name [all_connected $port ]] $port]
     set ref_name [get_attribute -quiet [get_cells -quiet -of_objects [get_pins -quiet $connect_to]] ref_name]
     if  {([llength $connect_to]) && ($ref_name!="")} {
       if {[llength $connect_to] > 1} {
             puts $OFILE "$port   $port_direction           [llength $connect_to]   $connect_to"
             set status_report 0
             incr count_io_buf_violations

         } elseif {[llength $connect_to] == 1} {
             if {([lsearch -exact $sort_io_buf_list $ref_name] == -1) && ([lsearch -exact $exclude_list $port]==-1)} {
               puts $OFILE "$port   $port_direction           [llength $connect_to]   ${connect_to}($ref_name)"
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
         set net_port_length [get_attribute -quiet [get_nets -quiet $port] vr_length]
         if {([lsearch -exact $sort_io_buf_list $ref_name] > -1) && ([lsearch -exact $exclude_list $port]==-1)} {
              puts $TFILE [format " %s   %s  %d  %5.2f" $port $port_direction $fo $net_port_length ]
         } else {
          #   puts $TFILE "$port  $port_direction   $fo       $net_port_length (NOT in IOBUF list)"
              set err_msg {(NOT in IOBUF list)}
              puts $TFILE [format " %s   %s  %d  %5.2f %s" $port $port_direction $fo $net_port_length $err_msg]
         }
      }
    };# foreach port...
    close $TFILE
    exec cat  reports/${STAGE}/tmp_report_file.rpt | sort -nk4 -r  > l.rpt
    set IFILE [open l.rpt r]
    puts $MFILE "#======================================================"
    puts $MFILE "# PORT      direction       FO            vr_length    "
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
    puts $OFILE " Found_io_buffer_violations $count_io_buf_violations"
    puts $OFILE "#================================================================="
    
    puts $MFILE "#================================================================="
    puts $MFILE "MAX_length_between_port_2_iobuf [lindex [exec head -n 1 l.rpt] 3] "
    puts $MFILE "#================================================================="

  exec rm l.rpt
  exec rm reports/${STAGE}/tmp_report_file.rpt
  close $OFILE
  close $CFILE
  close $MFILE
};#io_buffers_statistics
#====================================================================================================================
proc dont_use_cells_check { } {
    global STAGE
    global CTS_INVERTER_CELLS_TOP
    global CTS_INVERTER_CELLS_TRUNK
    global CTS_INVERTER_CELLS_LEAF 
    global CTS_LOGIC_CELLS
    global CTS_CLOCK_GATING_CELLS
    global HOLD_FIX_CELLS_LIST
    global DO_USE_CELLS
    global DONT_USE_CELLS
    global USEABLE_IOBUFFER_CELL

    puts "-I- Don't use cells Check ..."
    set OFILE [open  reports/${STAGE}/report_dont_use_cells.rpt w]
    set cts_clk_cell_ref_name [concat $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]

    puts $OFILE "#=========================================================================" 
    puts $OFILE "# Info :                                                                  " 
    puts $OFILE "# 1. List dont_used_cells : [list2row $DONT_USE_CELLS]                    " 
    puts $OFILE "# 2. List used_cells      : [list2row $DO_USE_CELLS]                      " 
    puts $OFILE "# 3. List used_clk_cells  : [list2row $cts_clk_cell_ref_name]             " 
    puts $OFILE "# 4. List hold fix        : [list2row $HOLD_FIX_CELLS_LIST]               " 
    puts $OFILE "# 4. List IO BUFFERS      : [list2row $USEABLE_IOBUFFER_CELL]             " 
    puts $OFILE "#========================================================================="

     set clock_cells_list  [lsort -u [get_object_name [get_attribute [get_clock_tree_pins -filter !is_clock_pin] cell]]]

     foreach du_cell $DONT_USE_CELLS {
        set num_of_lib_cells_in [sizeof_collection [get_lib_cells -quiet $du_cell]]
        if {$num_of_lib_cells_in == 0} {
            puts $OFILE "-E- can't find any lib cells for : $du_cell"
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
     
     foreach io_cell $USEABLE_IOBUFFER_CELL {
        set num_of_lib_cells_in [sizeof_collection [get_lib_cells -quiet $io_cell]]
        if {$num_of_lib_cells_in == 0} {
            puts $OFILE "-E- can't find any lib cells for : $io_cell"
        }
     }

    puts $OFILE "#=========================================================================" 
    puts $OFILE "" 
    puts $OFILE "# List of instances , that failed dont use cell check:" 
    puts $OFILE "#=========================================================================" 
    puts $OFILE "# ref_name (cell_type)                  Inst                              "
    puts $OFILE "#========================================================================="
    set sort_dont_use_list [lsort -u [get_attribute [get_lib_cells -quiet $DONT_USE_CELLS] name]]
    set sort_clock_list [lsort -u [get_attribute [get_lib_cells -quiet $cts_clk_cell_ref_name] name]]
    set sort_use_list  [concat [lsort -u [get_attribute [get_lib_cells -quiet $DO_USE_CELLS] name]] [lsort -u [get_attribute [get_lib_cells -quiet $HOLD_FIX_CELLS_LIST] name]] [lsort -u [get_attribute [get_lib_cells -quiet $USEABLE_IOBUFFER_CELL] name]]]
    # all cells to check :
    set all_cells [get_flat_cells -quiet -filter "is_hard_macro==false&&pad_cell==false&& is_memory_cell==false&&design_type!=black_box"]
     set failed_counter 0
     ## Check that we reduce also PNR blocks !!!!!!
     foreach cell [get_object_name  $all_cells] {
       set ref_name [get_attribute [get_cells -quiet $cell] ref_name]
       if { [lsearch -exact $clock_cells_list $cell] > -1} {
             set if_clock_cell 1
        } else {
             set if_clock_cell 0
        }
        set cell_type "data"
         if {$if_clock_cell} {
            set cell_type "clock"
            set if_in_clk_list [lsearch $sort_clock_list $ref_name]
            if {$if_in_clk_list==-1} {
               puts $OFILE "$ref_name  $cell ($cell_type)"
               incr failed_counter
            }
         } else {
             set if_cell_dont_use_list [lsearch $sort_dont_use_list $ref_name]
             if {$sort_use_list==""} {
               set if_cell_use_list  -1
             } else {
               set if_cell_use_list [lsearch $sort_use_list $ref_name] 
             }
  
             if {($if_cell_dont_use_list >= 0) && ($if_cell_use_list == -1) && ($cell_type=="data")} {
               puts $OFILE "$ref_name  $cell ($cell_type)"
               incr failed_counter
             }
         }

         

     };# foreach cell...

         puts $OFILE "#===============================================================" 
         puts $OFILE " Found_dont_use_cells_violations $failed_counter           "
         puts $OFILE "#===============================================================" 

  close $OFILE
 };# dont_use_cells_check
#====================================================================================================================
proc check_nets_length { {min_route_length 100}  } {
  #=========================================================================================  
  # NOTE:
  #   we can add filter to reduce some of the nets. 
  #=========================================================================================  
    global STAGE
    global MIN_ROUTE_LENGTH
    set OFILE [open reports/${STAGE}/report_nets_length.rpt w]
    set TFILE [open reports/${STAGE}/tmp_report_file.rpt w]
    puts "-I- Long Nets Check ..."
     if {[info exists MIN_ROUTE_LENGTH]} {
        set min_distance ${MIN_ROUTE_LENGTH}
     } else {
        set min_distance $min_route_length
     }

    set all_nets_to_check [get_flat_nets]
    ## option to filter spesific nets ...
     # if {[info exists vars(filter_long_nets_check)]} {
     #  foreach n $vars(filter_long_nets_check) {
     #    set all_nets_to_check [lsearch -inline -all -not $all_nets_to_check $n]
     #  }
     # }
    set number_of_violated_nets 0
    foreach net [get_object_name $all_nets_to_check] {
      if {[sizeof_collection [get_nets -quiet $net]]} {
          set net_l [get_attribute -quiet [get_nets $net] dr_length]
       } else {
          set net_l 0 ; # didn't find this net in the design
       }
       if {$net_l >= $min_distance} { 
           set fo [ get_attribute -quiet [get_nets $net] number_of_flat_loads]
           puts $TFILE "$net_l \t $fo \t $net"
           incr number_of_violated_nets
        } 
     };# foreach net ...
     close $TFILE
     exec cat reports/${STAGE}/tmp_report_file.rpt | sort -nk1 -r > l.rpt
     set IFILE [open l.rpt r]
     puts $OFILE "#============================================================"
     puts $OFILE "#Net_distance    FO         Net_name                           "
     puts $OFILE "#============================================================"

   while {[gets $IFILE line]>=0} {
       puts $OFILE "$line"
   }


    puts $OFILE "#===============================================================" 
    puts $OFILE " Found_long_nets $number_of_violated_nets  > $min_distance\[um\]"
    puts $OFILE "#===============================================================" 

   exec rm l.rpt
   exec rm reports/${STAGE}/tmp_report_file.rpt

  close $OFILE  
};#check_nets_length 
#====================================================================================================================
proc route_quality_check { {min_route_length 100} } {
 # check route quality ONLT for fo=1
  global MIN_ROUTE_LENGTH
  global STAGE
  set OFILE [open  reports/${STAGE}/report_route_quality_ratio.rpt w]
  set TFILE [open reports/${STAGE}/tmp_report_file_q.rpt w]
  puts "-I- Checking route quality ..."

    if {[info exists MIN_ROUTE_LENGTH]} {
       set min_distance ${MIN_ROUTE_LENGTH}
    } else {
       set min_distance $min_route_length
    }

     # Nets with FO==1
    set all_nets_to_check [get_flat_nets -filter "number_of_flat_loads==1&&dr_length>=$min_distance"]
    set number_of_violated_nets 0
    foreach net [get_object_name $all_nets_to_check] {
      if {[sizeof_collection [get_nets -quiet $net]]} {
            set net_dr [get_attribute -quiet [get_nets $net] dr_length]
            set net_vr [get_attribute -quiet [get_nets $net] vr_length]
       } else {
            set net_dr 0 ; # didn't find this net in the design
            set net_vr 1 ; # didn't find this net in the design
       }
       set route_quality [expr $net_dr/$net_vr]
       puts $TFILE [format "   %5.2f \t      %5.2f \t %5.2f \t %s " $route_quality  $net_vr  $net_dr   $net]
    };# foreach net ..
    close $TFILE
     exec cat reports/${STAGE}/tmp_report_file_q.rpt | sort -nk1 -r > l.rpt
     set IFILE [open l.rpt r]
     puts $OFILE "#============================================================"
     puts $OFILE "#route_quality_ratio    net_vr       net_dr        net_name"
     puts $OFILE "#============================================================"
     
      while {[gets $IFILE line]>=0} {
          puts $OFILE "$line"
      }
     puts $OFILE ""
     puts $OFILE "#================================================================================"
     puts $OFILE " Worst_route_quality_ratio [lindex [exec head -n 1 l.rpt] 0]  "
     puts $OFILE "#================================================================================"

    exec rm l.rpt
    exec rm reports/${STAGE}/tmp_report_file_q.rpt
    close $OFILE
 };#route_quality_check 
#====================================================================================================================
#====================================================================================================================
#  From Synopsys
#====================================================================================================================
# (c) 2023 Synopsys, Inc.  All rights reserved.
#
# This script is proprietary and confidential information of
# Synopsys, Inc. and may be used and disclosed only as authorized per
# your agreement with Synopsys, Inc. controlling such use and disclosure.

#A# Author         Anders Lind <alind>
#C# Category       supported
#D# Description    This script will count and categorize buffers and inverters
#D#                inserted during the various design phases. This is done based on
#D#                the instance naming. Please see the following SolvNet article for
#D#                additional information:
#D#                https://solvnetplus.synopsys.com/s/article/Script-to-Report-the-Number-of-Cells-Added-During-the-Different-Optimization-Stages-1577133845122
#D#
#D#                Version: 15
#U# Usage          > source count_buf_inv.tcl
#U#                > count_buf_inv
#U#
#U#                Procedure options:
#U#                -dont_suppress_empty : Print cells with count == 0
#U#                -no_commas : Don't add commas as thousands separators
#U#                -extra_stats : Split each type in buffers/inverters/others
#K# Keywords       buffer inverter prefix count optimization
#L# Language       tcl
#T# Tools          ICC2 FC

###################################################################################
# © 2016-2023 Synopsys, Inc.  All rights reserved.
#
# This script is proprietary and confidential information of
# Synopsys, Inc. and may be used and disclosed only as authorized
# per your agreement with Synopsys, Inc. controlling such use and
# disclosure.
#
###################################################################################
# Script to count buffers/inverters inserted during various phases.
#
# Version 1: Tested with IC Compiler II version L-2016.03-SP4 (updated November 17, 2016)
# Version 2: Tested with IC Compiler II version M-2016.12-SP4 (updated August 28, 2017)
#            - Added "Advanced HFN Buffering" prefixes HFSBUF/HFSINV
# Version 3: Updated for IC Compiler II version N-2017.09 (updated January 4, 2018)
#            - Added "General buffering" prefix BINV_P
#            - Updated some descriptions
# Version 4: Updated for IC Compiler II version O-2018.06-SP2 (updated September 1, 2018)
#            - Added "Logic restructuring for timing" prefix ctmTdsLR_
#            - Added "hBuf post-CTS hold fixing" prefix copt_h
#            - Removed manual categorization in buffers and inverters, instead only
#              uses the function ID.
#            - Reports count of cells being neither buffers nor inverters.
#            - Added prefix cbi_ to all variables
#            - If not suppressing types with no instances, print a "-" instead of "0"
# Version 5: (updated September 4, 2018)
#            - Added "Inserted by CTS for target latency" prefix cts_trgdly
# Version 6: (updated January 30, 2019)
#            - Added "hBuf post-CTS setup fixing" prefix copt_d_inst
# Version 7: (updated April 23, 2019)
#            - Added popt_d, ZBUF and ZINV prefixes
# Version 8: Updated for IC Compiler II version P-2019.03-SP4 (updated October 4, 2019)
#            - Added grfo, ccd, ctmi and Z_gre prefixes
#            - Put CCD cells in a separate section
#            - Removed usage of function_id, replaced it with is_buffer and is_inverter
#            - Minor corrections
# Version 9: Updated for IC Compiler II and Fusion Compiler version Q-2019.12-SP4 (updated June 29, 2020)
#            - Converted to a procedure "count_buf_inv" with options -dont_suppress_empty, -no_commas and -extra_stats
#            - Added additional output for each prefix by buffer, inverter and other gates (option -extra_stats)
#            - Updated copt_h prefix
#            - Added APSBUF, phfnr_buf, ropt_inst, Z_gre_BUF_f, Z_gre_INV_f, ABO and Buf prefixes
#            - Removed Z_gre prefix
#            - Prefixes sorted alphabetically
# Version 10: (updated July 28, 2020)
#            - Revised based on feedback. Several descriptions changed.
#            - Classification of cells changed to 6 categories: Setup/DRC, Hold, Utility, Clock, Clock utility and Pre-existing
#            - Formatting in -extra_stats mode modified
# Version 11: (updated August 25, 2020)
#            - Corrected patterns for Buf and U/u prefixes
#            - Added pattern for congi prefix
#            - Added additional filtering to no longer count any cells not being a buffer or an inverter. This will
#              lead to lower counts for those prefixes that could also match a gate (examples: U/u, RLB, ctmi, ABO_CELL).
#            - Prints out the total number of buffers and inverters in the design as part of the summary
# Version 12: (updated April 21, 2021)
#            - Modified to work with older tool versions, that do not support the is_buffer/is_inverter attributes
#            - Updated description for phfnr_buf
#            - Added pmd_ and MV_RESTRICTION categories
#            - Added gre_a, gre_d, gre_h and gre_mt categories
# Version 13: (updated January 3, 2022)
#            - Added prefixes for the Next Gen CTS/CTO engines
# Version 14: (updated June 22, 2023)
#            - Added new CTS/CTO prefixes for version U-2022.12
#            - Updated some CTS/CTO descriptions
# Version 15: (updated August 30, 2023)
#            - Fixed typo for prefix ctosc_drc_inst
#            - ctsctobgt* and sbcto* cells now count as setup/hold instead of clock cells

proc count_buf_inv {args} {

  # Process the procedure options and assign default values
  parse_proc_arguments -args $args input_args
  if {[string length [array names input_args "-dont_suppress_empty"]] > 0} {set cbi_suppress_empty 0} else {set cbi_suppress_empty 1}
  if {[string length [array names input_args "-no_commas"]]           > 0} {set cbi_commas 0}         else {set cbi_commas 1}
  if {[string length [array names input_args "-extra_stats"]]         > 0} {set cbi_extra_stats 1}    else {set cbi_extra_stats 0}

  # List fields:
  # 0) "Prefix" - used for the reporting
  # 1) [S] Setup/DRC - cell inserted to fix setup or max_trans/cap/length, etc.
  # 2) [H] Hold - cell inserted to fix hold
  # 3) [U] Utility - miscellaneous utility cell
  # 4) [C] Clock - clock tree cell
  # 5) [V] Clock Utility cell
  # 6) [P] Pre-existing netlist buffer/inverter
  # 7) "Description" - Short description of the cell usage for the reporting
  # 8) "RegExp" - Regular expression used to identify the cell instances

  set cbi_prefix_list { \
    {"---"          ---S H U C V P "########################   Pre-Route Optimization Cells   ########################" ""            }
    {"ABO_CELL"        1 0 0 0 0 0 "Temporary remapping cell"                                 ".*ABO_CELL_\[0-9\]+.*"                 }
    {"AINV_P"          1 0 0 0 0 0 "Inverters for preconditioning / DRC fixing"               ".*AINV_P_\[0-9\]+.*"                   }
    {"APSBUF"          1 0 0 0 0 0 "Rebuffering of net during layer demotion"                 ".*APSBUF.*"                            }
    {"APSHOLD"         0 1 0 0 0 0 "Post-CTS hold fixing"                                     ".*APSHOLD_\[0-9\]+.*"                  }
    {"APSLS"           1 0 0 0 0 0 "Effort sizing for augmenting weak drivers"                ".*APSLS_\[0-9\]+.*"                    }
    {"BINV_P"          1 0 0 0 0 0 "Inverters, regular optimization"                          ".*BINV_P_\[0-9\]+.*"                   }
    {"BINV_R"          1 0 0 0 0 0 "Inverters, regular optimization"                          ".*BINV_R_\[0-9\]+.*"                   }
    {"BINV_RR"         1 0 0 0 0 0 "Repeater inverters"                                       ".*BINV_RR_\[0-9\]+.*"                  }
    {"Buf"             1 0 0 0 0 0 "Inserted by compile_fusion for delay fixing, Gbuf engine" ".*Buf\[0-9\]+$"                        }
    {"BUFT_GROPTO"     1 0 0 0 0 0 "Global Route Optimization"                                ".*BUFT_GROPTO.*"                       }
    {"BUFT_L"          1 0 0 0 0 0 "Load buffering"                                           ".*BUFT_L_\[0-9\]+.*"                   }
    {"BUFT_P"          1 0 0 0 0 0 "HFS/DRC buffering"                                        ".*BUFT_P_\[0-9\]+.*"                   }
    {"BUFT_RR"         1 0 0 0 0 0 "Repeater buffers"                                         ".*BUFT_RR_\[0-9\]+.*"                  }
    {"copt_d_inst"     1 0 0 0 0 0 "Post-CTS setup fixing"                                    ".*copt_d_inst_\[0-9\]+.*"              }
    {"copt_h_inst"     0 1 0 0 0 0 "Post-CTS hold fixing"                                     ".*copt_h_inst_\[0-9\]+.*"              }
    {"ctmi"            1 0 0 0 0 0 "Inserted by logic restructuring"                          ".*ctmi.*"                              }
    {"ctmTdsLR"        1 0 0 0 0 0 "Logic and arithmetic restructuring for timing"            ".*ctmTdsLR_.*"                         }
    {"congi"           1 0 0 0 0 0 "Structural congestion optimization"                       ".*congi_.*"                            }
    {"gre_a"           1 0 0 0 0 0 "GRE (Global Route Everywhere) area recovery rebuffering"  ".*gre_a.*"                             }
    {"gre_d"           1 0 0 0 0 0 "GRE (Global Route Everywhere) setup fixing"               ".*gre_d.*"                             }
    {"gre_h"           0 1 0 0 0 0 "GRE (Global Route Everywhere) hold fixing"                ".*gre_h.*"                             }
    {"gre_mt"          1 0 0 0 0 0 "GRE (Global Route Everywhere) trans fixing"               ".*gre_mt.*"                            }
    {"grfo_d"          1 0 0 0 0 0 "GR based final optimization setup fixing"                 ".*grfo_d.*"                            }
    {"grfo_h"          0 1 0 0 0 0 "GR based final optimization hold fixing"                  ".*grfo_h.*"                            }
    {"grfo_inst"       1 0 0 0 0 0 "GR based final optimization"                              ".*grfo_inst.*"                         }
    {"grfo_mt"         1 0 0 0 0 0 "GR based final optimization trans/cap fixing"             ".*grfo_mt.*"                           }
    {"HFSBUF"          1 0 0 0 0 0 "Buffers inserted by the HFN synthesis engine"             ".*HFSBUF.*"                            }
    {"HFSINV"          1 0 0 0 0 0 "Inverters inserted by the HFN synthesis engine"           ".*HFSINV.*"                            }
    {"phfnr_buf"       1 0 0 0 0 0 "Pre-placement buffer tree cleanup"                        ".*phfnr_buf_\[0-9\]+.*"                }
    {"popt_d_inst"     1 0 0 0 0 0 "place_opt setup fixing"                                   ".*popt_d_inst_\[0-9\]+.*"              }
    {"SGI"             1 0 0 0 0 0 "Logic and Arithmetic Restructuring for area"              ".*SGI\[0-9\]+_\[0-9\]+.*"              }
    {"ZBUF"            1 0 0 0 0 0 "Pre-route incremental setup/trans/cap fixing"             ".*ZBUF_\[0-9\]+_inst_\[0-9\]+.*"       }
    {"Z_gre_BUF"       1 0 0 0 0 0 "GRE incremental setup/DRC fixing"                         ".*Z_gre_BUF_\[0-9\]+_inst_\[0-9\]+.*"  }
    {"Z_gre_INV"       1 0 0 0 0 0 "GRE incremental setup/DRC fixing"                         ".*Z_gre_INV_\[0-9\]+_inst_\[0-9\]+.*"  }
    {"Z_gre_BUF_f"     1 0 0 0 0 0 "GRE incr. setup/DRC fixing, forced BUF"                   ".*Z_gre_BUF_\[0-9\]+_f_inst_\[0-9\]+.*"}
    {"Z_gre_INV_f"     1 0 0 0 0 0 "GRE incr. setup/DRC fixing, forced preserve polarity INV" ".*Z_gre_INV_\[0-9\]+_f_inst_\[0-9\]+.*"}
    {"ZINV"            1 0 0 0 0 0 "Pre-route incremental setup/trans/cap fixing"             ".*ZINV_\[0-9\]+_inst_\[0-9\]+.*"       }

    {"---"          ---S H U C V P "##########################   Pre-Route Utility Cells  ############################" ""            }
    {"ABUF_PR"         0 0 1 0 0 0 "Preconditioning buffers"                                  ".*ABUF_PR.*"                           }
    {"AINV_PR"         0 0 1 0 0 0 "Preconditioning inverters"                                ".*AINV_PR.*"                           }
    {"APS_CLK_ISO"     0 0 1 0 0 0 "Clock-data isolation"                                     ".*APS_CLK_ISO.*"                       }
    {"APS_FTB"         0 0 1 0 0 0 "Feedthrough buffering"                                    ".*APS_FTB.*"                           }
    {"APS_PI"          0 0 1 0 0 0 "Port isolation"                                           ".*APS_PI.*"                            }
    {"APS_TDBUF"       0 0 1 0 0 0 "Tristate isolation"                                       ".*APS_TDBUF.*"                         }
    {"BINV_S"          0 0 1 0 0 0 "Inverters for side load isolation"                        ".*BINV_S_\[0-9\]+.*"                   }
    {"BUFT_S"          0 0 1 0 0 0 "Buffers for side load isolation"                          ".*BUFT_S_\[0-9\]+.*"                   }
    {"FTB"             0 0 1 0 0 0 "Feedthrough buffering and assign statement avoidance"     ".*FTB_\[0-9\]+__\[0-9\]+.*"            }
    {"MPN_BUF"         0 0 1 0 0 0 "Multi-port net buffers added before initial_opto"         ".*MPN_BUF_\[0-9\]+.*"                  }
    {"MVISOL"          0 0 1 0 0 0 "Multi-voltage isolation"                                  ".*MVISOL.*"                            }
    {"MV_RESTRICTION"  0 0 1 0 0 0 "Multi-voltage protection buffer"                          ".*MV_RESTRICTION_.*"                   }
    {"PI"              0 0 1 0 0 0 "Port Isolation buffers"                                   ".*PI_.*"                               }
    {"PIOLD"           0 0 1 0 0 0 "Port Isolation buffers used as regular buffer"            ".*PIOLD_.*"                            }
    {"pmd"             0 0 1 0 0 0 "Multi-voltage protection buffer"                          ".*pmd.*"                               }
    {"RBBUF"           0 0 1 0 0 0 "Buffer removal - port isolation"                          ".*RBBUF.*"                             }
    {"RBINV"           0 0 1 0 0 0 "Buffer removal - inverters for polarity maintenance"      ".*RBINV_\[0-9\]+.*"                    }
    {"RLB"             0 0 1 0 0 0 "Created during optimization roll-back"                    ".*RLB_\[0-9\]+.*"                      }

    {"---"          ---S H U C V P "##############################   Clock Tree Cells   ##############################" ""            }
    {"buf_drc_cln"     0 0 0 1 0 0 "Cloned buffers during DRC fixing"                         ".*buf_drc_cln_?\[0-9\]+.*"             }
    {"clk_drv_r"       0 0 0 1 0 0 "Created by create_clock_drivers"                          ".*clk_drv_r.*"                         }
    {"cto_buf"         0 0 0 1 0 0 "Buffers inserted by CTO for optimization"                 ".*cto_buf_\[0-9\]+.*"                  }
    {"cto_buf_cln"     0 0 0 1 0 0 "Cloned buffers during CTO"                                ".*cto_buf_cln_\[0-9\]+.*"              }
    {"cto_buf_drc"     0 0 0 1 0 0 "Buffers inserted by old CTO to fix DRC"                   ".*cto_buf_drc_\[0-9\]+.*"              }
    {"cto_dtrdly"      0 0 0 1 0 0 "Cells inserted by CTO for de-touring"                     ".*cto_dtrdly_\[0-9\]+.*"               }
    {"cto_inv"         0 0 0 1 0 0 "Inverters inserted by CTO for optimization"               ".*cto_inv_\[0-9\]+.*"                  }
    {"cto_inv_cln"     0 0 0 1 0 0 "Cloned inverters during CTO"                              ".*cto_inv_cln_\[0-9\]+.*"              }
    {"cto_inv_drc"     0 0 0 1 0 0 "Inverters inserted by old CTO to fix DRC"                 ".*cto_inv_drc_\[0-9\]+.*"              }
    {"cto_st"          0 0 0 1 0 0 "Repeaters added by CTO for clock balancing"               ".*cto_st_\[0-9\]+.*"                   }
    {"ctosc*asb"       0 0 0 1 0 0 "MTCTO, relax latency for priority clock skew opt."        ".*ctosc.*asb.*"                        }
    {"ctosc_drc_inst"  0 0 0 1 0 0 "Inserted by post route CTO for DRC fixing"                ".*ctosc_drc_inst.*"                    }
    {"ctosc_gls_inst"  0 0 0 1 0 0 "MTCTO, skew fixing"                                       ".*ctosc_gls_inst.*"                    }
    {"ctosc_inst"      0 0 0 1 0 0 "Inserted by post route CTO for optimization"              ".*ctosc_inst_\[0-9\]+.*"               }
    {"cts_buf"         0 0 0 1 0 0 "Buffers inserted by CTS clustering"                       ".*cts_buf_\[0-9\]+.*"                  }
    {"ctsctobgt_ht"    0 1 0 0 0 0 "Multi-vector final CTO f. hold TNS improvement"           ".*ctsctobgt_ht.*"                      }
    {"ctsctobgt_st"    1 0 0 0 0 0 "Multi-vector final CTO f. setup TNS improvement"          ".*ctsctobgt_st.*"                      }
    {"ctsctobgt_sw"    1 0 0 0 0 0 "Multi-vector final CTO f. setup WNS improvement"          ".*ctsctobgt_sw.*"                      }
    {"cts_dlydt"       0 0 0 1 0 0 "Cells inserted by CTS for delay detouring"                ".*cts_dlydt_\[0-9\]+.*"                }
    {"cts_inv"         0 0 0 1 0 0 "Inverters inserted by CTS clustering"                     ".*cts_inv_\[0-9\]+.*"                  }
    {"CTS_MCSB"        0 0 0 1 0 0 "Added by CTS for multi-fanout skew balancing"             ".*CTS_MCSB.*"                          }
    {"cts_trgdly"      0 0 0 1 0 0 "Inserted by CTS for target latency"                       ".*cts_trgdly_\[0-9\]+.*"               }
    {"dly_icdb_inst"   0 0 0 1 0 0 "Inter clock delay balancing in clock_opt build_clock"     ".*dly_icdb_inst.*"                     }
    {"dly_inst"        0 0 0 1 0 0 "MTCTO, delay detour insertion"                            ".*dly_inst.*"                          }
    {"dly_mcsb_inst"   0 0 0 1 0 0 "MTCTO, multi clock source skew balancing"                 ".*dly_mcsb_inst.*"                     }
    {"dly_trglat_inst" 0 0 0 1 0 0 "MTCTO, delay insertion for target latency"                ".*dly_trglat_inst.*"                   }
    {"ICDB"            0 0 0 1 0 0 "Added during clock group balancing"                       ".*ICDB_\[0-9\]+.*"                     }
    {"inv_drc_cln"     0 0 0 1 0 0 "Cloned inverters during DRC fixing"                       ".*inv_drc_cln_?\[0-9\]+.*"             }
    {"msgts_l"         0 0 0 1 0 0 "Created by synthesize_multisource_global_clock_trees"     ".*msgts_l.*"                           }
    {"sbcto_ht"        0 1 0 0 0 0 "Solver-based CTO for hold TNS improvement"                ".*sbcto_ht.*"                          }
    {"sbcto_st"        1 0 0 0 0 0 "Solver-based CTO for setup TNS improvement"               ".*sbcto_st.*"                          }
    {"sbcto_sw"        1 0 0 0 0 0 "Solver-based CTO for setup WNS improvement"               ".*sbcto_sw.*"                          }
    {"ugs"             0 0 0 1 0 0 "Inserted by CTS to drive ungated sinks"                   ".*_ugs\[0-9\]+.*"                      }
    {"ZCTSBUF"         0 0 0 1 0 0 "Buffers added during Next-Gen Clock Tree Synthesis"       ".*ZCTSBUF.*"                           }
    {"ZCTSINV"         0 0 0 1 0 0 "Inverters added during Next-Gen Clock Tree Synthesis"     ".*ZCTSINV.*"                           }
    {"ctsiso_split"    0 0 0 1 0 0 "Isolates clock sinks for fast tree to certain endpoints"  ".*ctsiso_split.*"                      }

    {"---"          ---S H U C V P "############################   Clock Utility Cells   #############################" ""            }
    {"bdp"             0 0 0 0 1 0 "Buffers inserted by CTS to separate clock to data path"   ".*_bdp\[0-9\]+.*"                      }
    {"BDP"             0 0 0 0 1 0 "CTS data isolation"                                       ".*BDP.*"                               }
    {"bcg"             0 0 0 0 1 0 "Guide buffers inserted by CTS to separate skew groups"    ".*_bcg\[0-9\]+.*"                      }
    {"bip"             0 0 0 0 1 0 "Buffers inserted by CTS to separate ignore pin"           ".*_bip\[0-9\]+.*"                      }
    {"biso"            0 0 0 0 1 0 "Buffers added to isolate clock ports"                     ".*_biso\[0-9\]+.*"                     }
    {"btd"             0 0 0 0 1 0 "Buffers inserted by CTS to separate disabled path"        ".*_btd\[0-9\]+.*"                      }
    {"vcg"             0 0 0 0 1 0 "Guide inverters inserted by CTS to separate skew groups"  ".*_vcg\[0-9\]+.*"                      }
    {"vdp"             0 0 0 0 1 0 "Inverters inserted by CTS to separate clock to data path" ".*_vdp\[0-9\]+.*"                      }
    {"vip"             0 0 0 0 1 0 "Inverters inserted by CTS to separate ignore pin"         ".*_vip\[0-9\]+.*"                      }
    {"viso"            0 0 0 0 1 0 "Inverters added to isolate clock ports"                   ".*_viso\[0-9\]+.*"                     }
    {"vtd"             0 0 0 0 1 0 "Inverters inserted by CTS to separate disabled path"      ".*_vtd\[0-9\]+.*"                      }

    {"---"          ---S H U C V P "########################   Post-Route Optimization Cells   #######################" ""            }
    {"ropt_d_inst"     1 0 0 0 0 0 "Post-route setup fixing"                                  ".*ropt_d_inst_\[0-9\]+.*"              }
    {"ropt_h_inst"     0 1 0 0 0 0 "Post-route hold fixing"                                   ".*ropt_h_inst_\[0-9\]+.*"              }
    {"ropt_mt_inst"    1 0 0 0 0 0 "Post-route trans/cap fixing"                              ".*ropt_mt_inst_\[0-9\]+.*"             }
    {"ropt_inst"       1 0 0 0 0 0 "Post-route miscellaneous optimization"                    ".*ropt_inst_\[0-9\]+.*.*"              }

    {"---"          ---S H U C V P "###################   Cells inserted during CCD optimization   ###################" ""            }
    {"ccd_drc"         1 0 0 0 0 0 "CCD in clock_opt final_opto & route_opt for DRC fixing"   ".*ccd_drc.*"                           }
    {"ccd_hold"        0 1 0 0 0 0 "CCD in clock_opt final_opto & route_opt for hold"         ".*ccd_hold.*"                          }
    {"ccd_setup"       1 0 0 0 0 0 "CCD in clock_opt final_opto & route_opt for setup"        ".*ccd_setup.*"                         }
    {"ctobgt_inst"     1 0 0 0 0 0 "Inserted by CCD during build_clock for postponing"        ".*ctobgt_inst_.*"                      }

    {"---"          ---S H U C V P "#############################   Miscellaneous Cells   ############################" ""            }
    {"optlc"           0 0 1 0 0 0 "Tie cells"                                                ".*optlc_\[0-9\]+.*"                    }
    {"u/U"             0 0 0 0 0 1 "Preexisting netlist buffers and inverters"                ".*\[uU\]\[0-9\]+$"                     }
  }

  set cbi_buffers 0
  set cbi_inverters 0
  set cbi_S_cells 0
  set cbi_H_cells 0
  set cbi_U_cells 0
  set cbi_C_cells 0
  set cbi_V_cells 0
  set cbi_P_cells 0

  set cbi_all_cells [get_cells -physical_context -quiet]

  # Check if is_buffer and is_inverter attributes are defined in the current tool version and use the appropriate
  # method to find all buffers and inverters
  if {[llength [get_defined_attributes -class lib_cell is_buffer]] == 0} {
    set cbi_all_buffers   [filter_collection -regexp $cbi_all_cells lib_cell.function_id=="a1.0"]
    set cbi_all_inverters [filter_collection -regexp $cbi_all_cells lib_cell.function_id=="Ia1.0"]
  } else {
    set cbi_all_buffers   [filter_collection -regexp $cbi_all_cells lib_cell.is_buffer==true]
    set cbi_all_inverters [filter_collection -regexp $cbi_all_cells lib_cell.is_inverter==true]
  }

  foreach cbi_type $cbi_prefix_list {
    if {[lindex $cbi_type 0] == "---"} {

      # Print the section header
      puts ""
      if {$cbi_extra_stats} {
        puts [format "%82.82s    Buffers  Inverters" [lindex $cbi_type 7]]
      } else {
        puts [format "%82.82s" [lindex $cbi_type 7]]
      }

    } else {

      # Count the cells and update the individual counters
      if {[llength [get_defined_attributes -class lib_cell is_buffer]] == 0} {
        set cbi_instances [filter_collection -regexp $cbi_all_cells "name =~[lindex $cbi_type 8] && (lib_cell.function_id==a1.0 || lib_cell.function_id==Ia1.0)"]
        set cbi_all_cells [remove_from_collection $cbi_all_cells $cbi_instances]
        set cbi_inst_buffers [sizeof_collection [filter_collection $cbi_instances lib_cell.function_id=="a1.0"]]
        set cbi_inst_inverters [sizeof_collection [filter_collection $cbi_instances lib_cell.function_id=="Ia1.0"]]
      } else {
        set cbi_instances [filter_collection -regexp $cbi_all_cells "name =~[lindex $cbi_type 8] && (lib_cell.is_buffer==true || lib_cell.is_inverter==true)"]
        set cbi_all_cells [remove_from_collection $cbi_all_cells $cbi_instances]
        set cbi_inst_buffers [sizeof_collection [filter_collection $cbi_instances lib_cell.is_buffer==true]]
        set cbi_inst_inverters [sizeof_collection [filter_collection $cbi_instances lib_cell.is_inverter==true]]
      }

      set cbi_count [sizeof_collection $cbi_instances]

      if {$cbi_count || !$cbi_suppress_empty} {
        if {$cbi_count} {
          if {$cbi_extra_stats} {
            puts [format "%70.70s: %10.10s %10.10s %10.10s" "[lindex $cbi_type 7] ([lindex $cbi_type 0])" [::cbi_add_commas $cbi_count] [::cbi_add_commas $cbi_inst_buffers] [::cbi_add_commas $cbi_inst_inverters]]
          } else {
            puts [format "%70.70s: %10.10s" "[lindex $cbi_type 7] ([lindex $cbi_type 0])" [::cbi_add_commas $cbi_count]]
          }
        } else {
          puts [format "%70.70s: %10.10s" "[lindex $cbi_type 7] ([lindex $cbi_type 0])" "-"]
        }

        # Count the inverters and buffers
        if {[llength [get_defined_attributes -class lib_cell is_buffer]] == 0} {
          foreach_in_collection cbi_cell $cbi_instances {
            if {[get_attribute $cbi_cell lib_cell.function_id] == "a1.0"} {
              incr cbi_buffers
            } elseif {[get_attribute $cbi_cell lib_cell.function_id] == "Ia1.0"} {
              incr cbi_inverters
            }
          }
        } else {
          foreach_in_collection cbi_cell $cbi_instances {
            if [get_attribute $cbi_cell ref_block.is_buffer] {
              incr cbi_buffers
            } elseif [get_attribute $cbi_cell ref_block.is_inverter] {
              incr cbi_inverters
            }
          }
        }

        if {[lindex $cbi_type 1]} {set cbi_S_cells [expr $cbi_S_cells + $cbi_count]}
        if {[lindex $cbi_type 2]} {set cbi_H_cells [expr $cbi_H_cells + $cbi_count]}
        if {[lindex $cbi_type 3]} {set cbi_U_cells [expr $cbi_U_cells + $cbi_count]}
        if {[lindex $cbi_type 4]} {set cbi_C_cells [expr $cbi_C_cells + $cbi_count]}
        if {[lindex $cbi_type 5]} {set cbi_V_cells [expr $cbi_V_cells + $cbi_count]}
        if {[lindex $cbi_type 6]} {set cbi_P_cells [expr $cbi_P_cells + $cbi_count]}
      }
    }
  }

  puts "\nCell type and purpose counts:"
  puts "#############################"
  puts [format "%15.15s: %10.10s   (total in design: %10.10s)" "Buffers" [::cbi_add_commas $cbi_buffers] [::cbi_add_commas [sizeof_collection $cbi_all_buffers]]]
  puts [format "%15.15s: %10.10s   (total in design: %10.10s)" "Inverters" [::cbi_add_commas $cbi_inverters] [::cbi_add_commas [sizeof_collection $cbi_all_inverters]]]
  puts ""
  puts [format "%15.15s: %10.10s" "Setup and DRC" [::cbi_add_commas $cbi_S_cells]]
  puts [format "%15.15s: %10.10s" "Hold" [::cbi_add_commas $cbi_H_cells]]
  puts [format "%15.15s: %10.10s" "Utility" [::cbi_add_commas $cbi_U_cells]]
  puts [format "%15.15s: %10.10s" "Clock" [::cbi_add_commas $cbi_C_cells]]
  puts [format "%15.15s: %10.10s" "Clock utility" [::cbi_add_commas $cbi_V_cells]]
  puts [format "%15.15s: %10.10s" "Pre-existing" [::cbi_add_commas $cbi_P_cells]]
}

define_proc_attributes count_buf_inv -info "Count buffers/inverters inserted during various phases." \
  -define_args {
    {"-dont_suppress_empty" "Print cells with count == 0."  "" boolean optional}
    {"-no_commas"           "Don't add commas as thousands separators." "" boolean optional}
    {"-extra_stats"         "Split each type in buffers/inverters/others." "" boolean optional}
}


proc cbi_add_commas {num} {
  upvar cbi_commas cbi_commas
  set result ""
  set offset [expr [string length $num] % 3]
  for {set i 0} {$i < [string length $num]} {incr i} {
    if {[expr $i>0] && [expr ($i%3)] == $offset} {
      append result ","
    }
    append result [string index $num $i]
  }
  if {$cbi_commas} {return $result} else {return $num}
}


# END

#====================================================================================================================

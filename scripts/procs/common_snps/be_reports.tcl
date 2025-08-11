if { [info exists sh_launch_dir] } {
  source $sh_launch_dir/scripts/procs/common/parseOpt.tcl 
  source $sh_launch_dir/scripts/procs/common/rls_table.tcl
} elseif { [info exists RUNNING_DIR] } {
  source ${RUNNING_DIR}/scripts/procs/common/parseOpt.tcl 
  source ${RUNNING_DIR}/scripts/procs/common/rls_table.tcl
} elseif { [file exists scripts/procs/common] } {
  source scripts/procs/common/parseOpt.tcl 
  source scripts/procs/common/rls_table.tcl
} else {
  puts "-W- No scripts/procs/common/ found" 
  return
}

################################################################################################################
## be_report_hier
################################################################################################################

::parseOpt::cmdSpec be_report_hier {
    -help "hier report - CURRENTLY NOT SUPPORTING ROOT,CELLS,SORT_BY,POWER"
    -opt {
        {-optname root        -type string  -default ""      -required 0 -help "Hierarchy to start from. Exclusive with -cells. Default is TOP. i.e. my_block_top/my_cpu_wrap/cpu"}
        {-optname cells       -type string  -default ""      -required 0 -help "Default is all cells in the design. Exclusive with -root"}
        {-optname level       -type integer -default 1       -required 0 -help "Default is 1 level"}        
        {-optname sort_by     -type integer -default 0       -required 0 -help "0 will sort by name"}
        {-optname power       -type boolean -default false   -required 0 -help "Add power data"}        
        {-optname area        -type boolean -default false   -required 0 -help "Add area data"} 
        {-optname file_name   -type string  -default ""      -required 0 -help "If not empty, saves to file_name and file_name.csv"}         
        {-optname details     -type boolean -default false   -required 0 -help "generate a second more detailed report"}
    }
} 

proc be_report_hier { args } {

    set PROC "[lindex [info level 0] 0]"

  # ~ ~ INIT ~ ~
  # taking user args
    if { ! [::parseOpt::parseOpt be_report_hier $args] } { return 0 }    
  # args to variables
    foreach _opt [array names opt] {
        set [string range $_opt 1 end] $opt($_opt)
    }

    set start_t [clock seconds]
    puts "-I- Start running $PROC at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

  # // Using snps support version - will require some tweeks..
	global DESIGN_NAME
    global STAGE

    set snps_rpt "reports/report_area_hierarchy.$STAGE.rpt"
    redirect $snps_rpt { area_report -levels $level }

    puts "-I- Report is under $snps_rpt"
  # DETAILED REPORT  
    if {$details} {

    # // last edited 11.06.2023 by Hillel

    # set output file name based on level and detailed data (power or area)
      if { $file_name == "" } {
          set file_name "reports/hier_cell_count_L${level}.rpt"
          foreach _opt "area power" {
              if { [set $_opt] } { set file_name [regsub -all "_L" $file_name "_${_opt}_L"] }
          }
      }
    # output table
      set out_h "hier_name hier_cells macro_cells buf_cells inv_cells comb_cells seq_cells bits icg_cells"
      foreach _opt "area power" {
          if { [set $_opt] } { set out_h [concat $out_h [regsub -all {_cells} [lsearch -all -inline $out_h "*_cells"] "_$_opt"] ] }
      }

    # ~ ~ DISCLAIMERS ~ ~
    # //
    # // simplifying for now.. 
    # //      no root
    # //      no cell
    # //      no sort_by
    # //      no power
    # //   

    # ~ ~ COLLECTING CELL DATA ~~
    # Filtering all 'leaf' cells
      puts "-I- $PROC  starting extracting cell data  [clock format [expr [clock seconds] - $start_t] -timezone UTC -format %T]"
      set my_cells [get_cells $root* -hier -filter is_hierarchical==false]      ; list

      array unset cell_arr
      array set cell_arr "name {} buf {} inv {} macro {} icg {} seq {} comb {}"
    # Building cell data base, split by type
      foreach_in_col c $my_cells {
          set ref [get_attribute $c ref_name]   
          set _c  [get_object_name $c]
          set _data "$_c [expr {$area? [get_attribute [get_lib_cells -of $c] area] : {0}}] [expr {$power ? {0} : {0}}]"      
        # keeping cell name list not by-type, to parse hierarchy names in a simpler, faster way        
          lappend cell_arr(name) "$_c"

          if { [regexp "BUF" $ref] } { 
              lappend cell_arr(buf) $_data
          } elseif { [regexp "INV" $ref]  } {
              lappend cell_arr(inv) $_data
          } elseif { [regexp "^M5" $ref] } {
              lappend cell_arr(macro) $_data
          } elseif { [regexp "CKEN" $ref] } {
              lappend cell_arr(icg) $_data
          } elseif { [regexp "DFF|SRESYNC" $ref]  } {
              lappend cell_arr(seq) $_data
          } else {
              lappend cell_arr(comb) $_data
          }        
      }
      puts "-I- $PROC  done     extracting cell data  [clock format [expr [clock seconds] - $start_t] -timezone UTC -format %T]"

    # ~ ~ PARSING HIERS ~ ~  
      set pat0 "\[\\w\]+/"
      set pat "${root}${pat0}"
      set my_hiers ""

      for { set _lvl [expr [llength [regexp -all -inline "/" $root]] + 1] } { $_lvl <= $level } { incr _lvl } {
          lappend my_hiers [lsort -unique [regsub -all {/ |/$} [lsort -unique [join [regexp -all -inline "^${pat}| ${pat}" $cell_arr(name)]]] " "]]
          set pat "${pat}${pat0}"
      }
      set my_hiers [join [join $my_hiers]]   ;   list
      set all_types [regsub -all "name" [array names cell_arr] ""]

    # ~ ~ COLLECTING HIER DATA AND PRINTING TO FILE ~ ~

      array unset hier_res
      array set hier_res ""

  #    set out_h "hier_name hier_cells macro_cells buf_cells inv_cells comb_cells seq_cells bits icg_cells"
    # printing header  
      set f [open _be_report_hier.tmp.1 w]
      puts $f $out_h
      puts $f [regsub -all {[^ ]} $out_h "-"]

      array set idx "cells 0 area 1 power 2"

      if { $root == "" } {
          set hier_list [concat "top" [lsort -unique $my_hiers]]
      } else {    
          set hier_list [concat "$root" [lsort -unique $my_hiers]]
      }

      foreach _hier $hier_list {
        # adding top hierarchy
          if { $_hier == "top" } {
              set hier $root
          } else {
              set hier [regsub -all "//" "$_hier/" "/"]
          }

        # collecting per type
          array unset total
          array set total "cells 0 area 0 power 0"  
          foreach type $all_types {
              set _hier_cells [lsearch -all -inline -index 0 $cell_arr($type) "$hier*"]
              set res(cells)  [llength $_hier_cells]
              set res(area)  [expr { $area ? [expr round([lsum [lsearch -inline -all -subindices -index 1 $_hier_cells *]])] : "0"}]
              set res(power) [expr { $power ? "0" : "0"}]
              set _data "$res(cells) $res(area) $res(power)"      

              set hier_res($type) "$_data"

              foreach domain "cells area power" {
                  set total($domain) [expr $total($domain) + $res($domain)] 
              }
          }
        #  adding bits count
          set _hier_cells [lsearch -all -inline -index 0 $cell_arr(seq) "$hier*"]
          set res_bits [expr [lindex $hier_res(seq) 0] + [llength [regexp -inline -all "_MB_" [join $_hier_cells]]]]
        # printing to file
          set line_out "[regsub {/$} $_hier {}]"
          foreach domain "cells [expr {$area ? {area} : {}}] [expr {$power ? {power} : {}}]" {
              lappend line_out $total($domain)
              foreach type "macro buf inv comb seq icg" {
                  lappend line_out [lindex $hier_res($type) $idx($domain)]
                # add bits count for cells type only  
                  if { [regexp "cells" $domain] && [regexp "seq" $type] } {
                      lappend line_out $res_bits
                  }
              }
          }
          puts $f "$line_out"
      }
      close $f

      exec sh -c {cat _be_report_hier.tmp.1 | /bin/sed 's/[ ]/@\|@/g;s/$/@\|/g' | column -o " " -t -s '@' | /bin/sed '/\-\-\-/ {s/[ ]/\-/g}' | /bin/sed 's/ \([0-9\.]\+\)\([ ]\+\) / \2\1 /g' > _be_report_hier.tmp.2 }
      exec cat _be_report_hier.tmp.2 > $file_name
      set csv_file "[regsub -all {\.rpt$} $file_name {}].csv"
      exec sed "2d;s/\\\s//g;s/|/,/g;s/,\$//g" $file_name > $csv_file      

      file delete _be_report_hier.tmp.1
      file delete _be_report_hier.tmp.2

      puts "-I- $PROC detailed report file is under:    $file_name"
    } ;# // end of detailed script
    set end_t [clock seconds]
    puts "-I- End running $PROC at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
    puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
}

################################################################################################################
## be_report_area
################################################################################################################

proc be_report_area { {all 0} } {


    set rpt_out         reports/$STAGE/report_area.$STAGE.rpt
    set rpt_hier_out    reports/$STAGE/report_area_hierarchy.$STAGE.rpt
    
    report_area -nosplit > $rpt_out
    report_area -nosplit -hierarchy > $rpt_hier_out  
    
    if { $all } {
        return
    } else {
        if { [info exists ::synopsys_program_name] } {  ;# snps
            set my_cells [get_cells -hier -filter is_hierarchical==false&&within_block_abstraction==false]    
        } else {                                        ;# cdnc
            #set my_cells [get_cells -hier -filter is_hierarchical==false] ;# ADD CADENCE SUPPORT
            return
        }
    }

  # get abstract data
    set abst_list [get_object_name [get_cells -hier -filter is_block_abstraction]]
    set abst_area [lsum [get_attribute [get_cells -hier -filter is_hierarchical==false&&within_block_abstraction] area]]
    set abst_as_bbox 0  ;# to count all cells within block abstractions as black box area
    
  # Get data
    set _nets  [get_nets -hier -filter within_block_abstraction==false]
    set _comb  [filter_collection $my_cells is_combinational]
    set _seq   [filter_collection $my_cells is_sequential]
    set _hips  [filter_collection $my_cells is_hard_macro]
    set _bfin  [filter_collection $my_cells ref_name=~*BUF*||ref_name=~*INV*]
    set _refs  "????" ;# not sure what those are.. can't reach a count similar to the report

    set num_list "x [sizeof $_nets] [sizeof $my_cells] [sizeof $_comb] [sizeof $_seq] [expr ([sizeof $_hips]) + ($abst_as_bbox*$abst_area)] [sizeof $_bfin] x"
    set num_len [llength $num_list]

    set area_list "[lsum [get_att $_comb area]] [lsum [get_att $_bfin area]] [lsum [get_att $_seq area]] [lsum [get_att $_hips area]] x [lsum [get_att $my_cells area]] x"

  # Writing output to files
    set f_out     [open $rpt_out.tmp w] 
    set f_out_h   [open $rpt_hier_out.tmp w]

    set f_data_ [open $rpt_hier_out r]    ;   set f_data [split [read $f_data_] \n]  ;   close $f_data_
    
    set idx 0
    set hier_only 0    
    foreach line $f_data {
      # if inside 'hier' data table
        set is_abst_data 0
        if { $hier_only } {
            if { [regexp {[0-9]+\.[0-9]+[ \t]+[0-9]} $line] } { ;# if is a hier data line
                set hier [lindex $line 0]
                if { $hier == $DESIGN_NAME } {
                    set glob_area [lsum [get_att $my_cells area]]
                    set top_comb  [lsum [get_att [get_cells -filter is_combinational] area]]
                    set top_nonc  [lsum [get_att [get_cells -filter is_combinational==false] area]]
                    set line [lreplace $line 1 4 $glob_area 100.0 $top_comb $top_nonc]
                } elseif { [regexp $hier $abst_list] } {
                    if { $abst_as_bbox } {
                        set hier_cells [get_cells -hier -filter full_name=~$hier*]
                        set glob_area  [lsum [get_att $hier_cells area]]
                        set top_comb   [lsum [get_att [get_cells $hier/* -filter is_combinational] area]]
                        set top_nonc   [lsum [get_att [get_cells $hier/* -filter is_combinational==false] area]]
                        set line [lreplace $line 1 4 $glob_area $top_comb $top_nonc]
                    }
                } else {
                    foreach abst $abst_list { 
                        if { [regexp "$abst/" $hier] } { set is_abst_data 1 ; break }
                    }
                }
            }
      # if in general section      
        } else {
            if { [regexp "Number of " $line] } {
                set v [lindex $num_list $idx]
                if { $v != "x" } { set line [lreplace $line end end $v] }
                incr idx ; if { $idx == $num_len } { set idx 0 } 
            } elseif { [regexp "area: " $line] } {
                set v [lindex $area_list $idx]
                if { $v != "x" } { set line [lreplace $line end end $v] }
                incr idx
            }
        }
      # print if not abstract data 
        if { !$is_abst_data } {
            puts $f_out_h $line        
            if { !$hier_only } {
                set hier_only [regexp "Hierarchical" $line]
                if { !$hier_only } { puts $f_out $line }
            }
        }
    }
    
    close $f_out
    close $f_out_h
    file delete $rpt_out
    file delete $rpt_hier_out
    file copy $rpt_out.tmp $rpt_out
    file copy $rpt_hier_out.tmp $rpt_hier_out
    
    puts "-I- output area report is under:  $rpt_out"
}


##################################################################################
##################################################################################
##                                                                              ##
##  Version   : 1.0                                                             ##
##  Date, Day : 19-June-2008, Thursday                                          ##
##  Developer : Sumit Garg (sumitg@synopsys.com)                                ##
##  Support   : Drop me an e-mail at sumitg@synopsys.com about your feedback,   ##
##              suggestions or any related issues.                              ##
##                                                                              ##
##################################################################################
##################################################################################

## Main proc starts
proc area_report { args } {
   
    set ::char  { }
    set ::level 1
    set   crlvl 0
    set maxlen  [string length "Reference Name"]
    array unset ::har
    array   set ::har ""
    parse_proc_arguments -arg ${args} options
    if {[info exists options(-levels)]} {
        set ::level $options(-levels)
    }
    
    echo ""
    echo "*************************************"
    echo " Report  : Area                      "
    echo " Design  : [get_attribute [current_design] name]    "  
    echo " Version : $::sh_product_version     "
    echo " Date    : [date]                    "
    echo "*************************************"
    echo ""

    set current_design_name [get_attribute [current_design] name] 
    set leaf_cell [sizeof_collection [get_cells -hierarchical -filter "is_hierarchical==false"]]
    set comb_cell [sizeof_collection [get_cells -hierarchical -filter "is_hierarchical==false && is_combinational==true" ]]
    set  seq_cell [sizeof_collection [get_cells -hierarchical -filter "is_hierarchical==false && is_combinational==false"]]
    #set  seq_cell [sizeof_collection [get_cells -hierarchical -filter "is_hierarchical==false && is_sequential==true"]]
    redirect -var arearpt { report_area -nosplit }
    regexp {Total cell area: +(.*?)\n.*} $arearpt match area
    regexp {Combinational area: +(.*?)\n.*} $arearpt match comb_area
    regexp {Noncombinational area: +(.*?)\n.*} $arearpt match seq_area
    set ::har([string repeat ${::char} [expr ${crlvl}*4]]$current_design_name) "${leaf_cell} ${comb_cell} ${seq_cell} ${area} ${comb_area} ${seq_area}"
    lappend ::har() "[string repeat ${::char} [expr ${crlvl}*4]]$current_design_name"

    if {${::level} > 0 } {
	incr crlvl
        set hier_cell [get_cells * -filter "is_hierarchical==true"]
	foreach_in_collection cell ${hier_cell} {
	    instance_stat ${cell} ${crlvl}
	}
    }
    foreach name $::har() {
        set len [string length ${name}]
	if {$len > $maxlen} {
	    set maxlen $len
	}
    }

    echo "[format " %-*s %*s %*s %*s %*s %*s %*s " [expr ${maxlen}+4] "Reference Name" 10 "Cell Count" 10 "Comb." 10 "Seq." 15 "Area" 12 "Comb." 12 "Seq."]"
    echo "[format " %-*s   %*s %*s %*s %*s %*s %*s " ${maxlen} [string repeat {-} ${maxlen}] 0 "" 0 "" 32 [string repeat {-} 32] 0 "" 0 "" 39 [string repeat {-} 39] ]"
    
    foreach name $::har() {
        set  tot_count [format %.0f [lindex $::har($name) 0]]
        set comb_count [format %.0f [lindex $::har($name) 1]]
        set  seq_count [format %.0f [lindex $::har($name) 2]]
	set  tot_area  [format %.2f [lindex $::har($name) 3]]
	set comb_area  [format %.2f [lindex $::har($name) 4]]
	set  seq_area  [format %.2f [lindex $::har($name) 5]]
	echo "[format " %-*s %*.0f %*.0f %*.0f %*.2f %*.2f %*.2f " [expr ${maxlen}+4] ${name} 10 ${tot_count} 10 ${comb_count} 10 ${seq_count} 15 ${tot_area} 12 ${comb_area} 12 ${seq_area} ]"
    }
    echo ""
    return 1
}
    	 
proc instance_stat { inst crlvl } {
	
	set mstr_name [get_attribute -quiet [get_cells -hier $inst] ref_name]
	redirect /dev/null {set orig [current_instance .]}	
	redirect /dev/null {current_instance $inst}
	set leaf_cell [sizeof_collection [get_cells -hierarchical -filter "is_hierarchical==false"]]
    	set comb_cell [sizeof_collection [get_cells -hierarchical -filter "is_hierarchical==false && is_combinational==true" ]]
    	set  seq_cell [sizeof_collection [get_cells -hierarchical -filter "is_hierarchical==false && is_combinational==false"]]
    	redirect -var arearpt { report_area -nosplit }
    	regexp {Total cell area: +(.*?)\n.*} $arearpt match area
    	regexp {Combinational area: +(.*?)\n.*} $arearpt match comb_area
    	regexp {Noncombinational area: +(.*?)\n.*} $arearpt match seq_area
    	set ::har([string repeat ${::char} [expr ${crlvl}*4]]${mstr_name}) "${leaf_cell} ${comb_cell} ${seq_cell} ${area} ${comb_area} ${seq_area}"
    	lappend ::har() "[string repeat ${::char} [expr ${crlvl}*4]]${mstr_name}"
    	incr crlvl
    	if { ${crlvl} <= ${::level} } {
        	set hier_cell [get_cells * -filter "is_hierarchical==true"]
        	foreach_in_collection cell ${hier_cell} {
	    		instance_stat ${cell} ${crlvl}
        	}
    	}

	redirect /dev/null {current_instance}
	redirect /dev/null {current_instance $orig}

}
    
define_proc_attributes area_report  \
      -info "Generate an hierarchical area report" \
      -hide_body \
      -define_args { \
      { -levels   "Levels of hierarchy to be parsed when generating area report (default: 1)" "Integer" int optional }
                  }
###############################################################################################

# Procedure:  report_logic_levels
# Purpose:  This procedure will print a tabular report of the number of logic levels, real levels of logic, and worst
#           slack of the most critical paths in a given group.
# Usage:  report_logic_levels -group 
#         report_logic_levels -group  -max_paths 20 -nworst 3 

###############################################################################################

proc be_report_logic_levels { args } {

    ### Taken from SolvNet (and edited by HN)
    set rpt "reports/report_logic_levels.rpt"

    ### Violation Params
        set CLK_DERATE 0.92
        set CLK_JTR    0.075
        set MEAN_DLY   0.025

  # // Parsing Args
    parse_proc_arguments -args $args results

    set group       [expr { [info exists results(-group)]     ? $results(-group)     : ""   }]
    set max_paths   [expr { [info exists results(-max_paths)] ? $results(-max_paths) : 1000  }]
    set nworst      [expr { [info exists results(-nworst)]    ? $results(-max_paths) : 1    }]
    set type        [expr { [info exists results(-type)]      ? $results(-type)      : "rpt_and_viol"   }]
    set overrides   [expr { [info exists results(-overrides)] ? $results(-overrides) : ""   }]

    set _hdr "Startpoint Endpoint StartClk EndClk LogicLevels Period Path_Group"

    if { [regexp "rpt" $type] } {

        set f [open $rpt w]

        if { $group != "" } {
            set paths [get_timing_paths -nworst $nworst -max_paths $max_paths -group $group]
        } else {
            set paths [get_timing_paths -nworst $nworst -max_paths $max_paths]
        } 

        foreach_in_collection path $paths {
            set timing_points       [get_attribute $path points]
            set num_timing_points   [sizeof_collection $timing_points]
            set num_logic_levels    [expr ($num_timing_points - 2) / 2]
            set endpoint            [get_object_name [get_attribute $path endpoint]]
            set startpoint          [get_object_name [get_attribute $path startpoint]]
            set group               [get_object_name [get_attribute $path path_group]]
            set end_prd             [get_attribute $path endpoint_clock_close_edge_value]
            set end_clk             [get_object_name [get_attribute $path endpoint_clock]]
            set start_clk           [get_object_name [get_attribute $path startpoint_clock]]

            puts $f "$startpoint $endpoint $start_clk $end_clk $num_logic_levels $end_prd $group"
        }
        close $f
        exec echo "$_hdr" > $rpt.tmp
        exec cat $rpt | sort -k5,5nr -k3,3 >> $rpt.tmp
        exec cat $rpt.tmp | column -t > $rpt
        exec echo "--------------------------------------" >> $rpt
        exec echo "* You can get a full timing report by \'report_timing -to <endpoint>\'"
        file delete $rpt.tmp
    #    puts "-I- report is under:    $rpt"
    }
    if {[regexp "viol" $type]} {
        set _v_name "reports/report_logic_levels_violations.rpt"
        set _v [open $_v_name.tmp w]
        puts $_v "[concat $_hdr Threshold]"
        array set path_periods ""
        foreach "st end per" $overrides {
            set path_periods($st,$end,user) "$per"
        }
        set f [open $rpt r] ; set rpt_data [split [read $f] "\n"] ; close $f
        foreach line [lrange $rpt_data 1 end] {
            lassign $line st end st_clk end_clk logic clk_prd grp
            if { $clk_prd == "" } { continue }
            set found_ovrd 0
            foreach "_st _end _src" [regsub -all "," [array names path_periods] " "] {
                if { ([string match $_st $st_clk])&&([string match $_end $end_clk]) } {
                    set thr $path_periods($_st,$_end,$_src)
                    set found_ovrd 1
                    break
                }
            }
            if { !$found_ovrd } {
                set thr [expr int(ceil((($clk_prd*$CLK_DERATE)-$CLK_JTR)/$MEAN_DLY) - 2)]   ;# 8% + 75ps clk_derate + jitter, assuming mean delay 0.025, 2 additionals stages for FF delay
                set path_periods($st_clk,$end_clk,formula) $thr
                set _src "formula"
            }
            if { $logic >= $thr } {
                puts $_v "$st $end $st_clk $end_clk $logic $clk_prd $grp ${thr}(${_src})"
            } 
        }
        close $_v
        exec cat $_v_name.tmp | column -t > $_v_name
        exec rm $_v_name.tmp
    }
}

define_proc_attributes be_report_logic_levels \
    -define_args {
        {-group "Group name" "" string optional}
        {-max_paths "Maximum number of paths" "1000" string optional}
        {-nworst "Number of worst paths per endpoint" "1" string optional}
        {-type "rpt_only , viol_only , rpt_and_viol" "rpt_and_viol" string optional}
        {-overrides "violation overrides in form of <fromClkA> <toClkA> <Levels_Threshold_A> <fromClkB> <toClkB> <Levels_Threshold_B> .." "" string optional}
}

################################################################################################################
## report_fanin/fanout.
################################################################################################################

proc be_report_io_fo { } {

  global STAGE
  set PROC "be_report_io_fo"

  # START TIME
  set start_t [clock seconds]
  puts "-I- Start running $PROC at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

  # init variables
  set alrgs [add_to_collection [all_registers -edge] [all_registers -level]]
  set alcgs [get_cells -hier -filter is_icg||is_clock_gate]

  array set ports_by_clock ""
  array set clock_periods ""
  foreach _p [get_object_name [get_ports]] {
    set _clk [get_related_clocks -quiet $_p]
    set _clk_name [get_object_name $_clk]
    if { $_clk != "" } {
        lappend ports_by_clock($_clk_name) $_p 
        if { ![info exists clock_periods($_clk_name)] } { 
            set clock_periods($_clk_name) [get_attribute $_clk period]
        }
    }
  }

  foreach {dir _d} "in o out i" {

    set _D [string toupper $_d]

    # report headers
    set rpt  "reports/${STAGE}_${dir}puts_f${_d}_size.rpt"
    set rptd "$rpt.detailed"
    
    set f  [open $rpt.tmp w]
    set fd [open $rptd.tmp w]

  # Gathering all_fanin/out data  

    set my_list ""
    
    foreach _clk [array names ports_by_clock] {

        set related_ports [common_collection [get_ports -quiet $ports_by_clock($_clk)] [get_ports -quiet -filter direction==$dir&&is_clock_used_as_clock!=true] ]
        set _period $clock_periods($_clk)

        foreach_in_col p $related_ports {
            if { $dir == "out" } {
                set regs [all_fanin -only -flat -start -to $p]
            } elseif { $dir == "in" } {
                set regs [all_fanout -only -flat -end -from $p]
              # go through clock gates        
                set cgs  [common_collection $alcgs $regs]

                while { [sizeof $cgs] } {
                    set _regs [all_fanout -only -flat -end -from [get_pins -of $cgs -filter direction==out]]
                    set cgs   [remove_from_collection [common_collection $_regs $alcgs] $cgs]
                    if { [sizeof $_regs] } { append_to_collection regs $_regs }
                }
                set regs [remove_from_collection $regs $alcgs]
            }

            set sz [sizeof_collection $regs]
            if { $sz } {        
                set n [get_object_name $p]
                # limiting FO list to 100, because tcl gets stuck sorting larger lists
                lappend my_list "$n $sz $_clk $_period \{[lrange [get_object_name $regs] 0 99]\}"
            }
        }
    }   ;# end - foreach _clk 
    
    set sorted_list [lsort -index 1 -decreasing -integer $my_list]

    foreach line $sorted_list {
        lassign $line n sz c prd r
        puts $f  "$n \| $sz \| $c \| $prd \|"
        puts $fd "$r"
    }

    close $f    ;   close $fd
  # a lot of parsing to make reports similar to genus  
    set title [expr {$dir == "in" ? "Endpoints" : "Startpoints" }]
    
    exec echo "Port_Name | F${_D} | Clock | Period |" > tmp_h1
    exec echo "--------- + --- + ----- + ------ +" >> tmp_h1
    exec echo " $title" > tmp_h2
    exec echo " -----------" >> tmp_h2

    exec cat tmp_h1 $rpt.tmp | column -t > $rpt
    exec cat tmp_h2 $rptd.tmp > tmp_f
    exec paste $rpt tmp_f > $rptd.tmp

    file delete tmp_h1 tmp_h2 tmp_f $rpt.tmp $rptd.tmp 
  } ;# end of main loop

  # End Time
  set end_t [clock seconds]
  puts "-I- End running $PROC at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
  puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
}

#####################################################################
#####################################################################

proc get_related_clocks {args} {
    parse_proc_arguments -args $args results

    set rpt {}
    set range {}
    array set rtn_clk "" 
    set var {}


    if {![info exist results(-quiet)]} {
        set port [get_ports $results(object)]
    } else {
        set port [get_ports -quiet $results(object)]
    }

    foreach_in_collection po $port {
        set obj [get_object_name $po]
        redirect -var rpt_port {report_port -verbose [get_object_name $po]}
        set rpt [split $rpt_port \n]
        if {[get_attribute [get_ports [get_object_name $po]] direction] eq "out"} {
            set range [lrange $rpt [lsearch -regexp $rpt {\s+Output\s+Delay}] end]
        } else {
            set range [lrange $rpt [lsearch -regexp $rpt {\s+Input\s+Delay}] [expr [lsearch -regexp $rpt {\s+Resistance}] - 1]]
        }
        set er_clk [lindex [regexp -all -inline -- {\S+} [lindex $range [expr [lsearch -regexp $range {\-+}] + 1]]] 5]
        if { $er_clk eq "--" } {
            if {![info exist results(-quiet)]} {
                puts "Port [get_object_name $po] is unconstrained ..."
            }
            continue
        } else {
            set rtn_clk($er_clk) er_clk
        }
    }
    set var [lrange $range [expr [lsearch -regexp $range {\-+}] + 2] end-2]
    foreach vr $var {
        if {[lindex $vr 4] ne ""} {
            set clk [lindex [regexp -all -inline -- {\S+} $vr] 4]
            if { $clk eq "--" } {
                if {![info exist results(-quiet)]} {
                    puts "Port [get_object_name $po] is unconstrained ..."
                }
                continue
            } else {
                set rtn_clk($clk) clk
            }
        }
    } 
    set rtn [array names rtn_clk]
    if {![info exist results(-quiet)]} {
        return [get_clocks $rtn]
    } else {
        return [get_clocks -quiet $rtn]
    }
}


define_proc_attributes get_related_clocks -info "Get a Collection of related clock for the port" \
    -define_args  { \
        {-quiet "Supress all messages" "" boolean optional} \
        {object  "Ports" "object_list" string optional} \
    }


#####################################################################

proc be_report_feedthroughs { {f_out ""} } {

    set PROC [lindex [info level 0] 0]
    global STAGE

    if { $f_out == "" } {
        set f_out "reports/$STAGE/report_feedthrough.rpt"
    }
    set f [open $f_out.tmp w]
    set dc [expr [info exist ::synopsys_program_name] && [regexp $::synopsys_program_name "dc_shell"]]
    if {!$dc} {set ports [get_ports -quiet -filter {direction==in && net.number_of_pins>=2}]} {set ports [get_ports -quiet -filter {direction==in}]}
    foreach_in_collection p $ports {
 	if {!$dc} {
        	set afo [all_transitive_fanout -end -flat -from $p]
		set po [get_ports -quiet $afo -filter {direction==out}]
		set timing_POV 1
	} else {
        set afo [all_fanout -end -flat -from $p]
		set po [get_ports -quiet $afo -filter {direction==out}]
		set timing_POV 0
	}
	if {$timing_POV && [sizeof $po]} {
			set afo [all_fanout -quiet -end -flat -from $p]
			set po [get_ports -quiet $afo -filter {direction==out}]
	}
        if { [sizeof $po] } {
            puts $f "[get_object_name $p]\t-->\t[join [get_object_name $po]]"
        }
    }
    close $f
    exec cat $f_out.tmp | column -t | sed "s/\-\-\>/    \-\-\>    /g" > $f_out
    file delete $f_out.tmp
    puts "-I- Output of $PROC is under    $f_out"

}


## script ends ##




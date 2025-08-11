proc be_report_io_fo { } {

  global STAGE
  global RUNNING_DIR
  set PROC "be_report_io_fo"

  # START TIME
  set start_t [clock seconds]
  puts "-I- Start running $PROC at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

  # init variables
  set alrgs [add_to_collection [all_registers -edge] [all_registers -level]]
  set alcgs [get_clock_gates]

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
    set rpt  "${RUNNING_DIR}/reports/${STAGE}/report_${dir}puts_f${_d}_size.rpt"
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

proc be_report_logic_levels { args } {
    
    global STAGE
    global RUNNING_DIR
    ### Taken from SolvNet (and edited by HN)
#    set rpt "reports/${STAGE}/report_logic_levels.rpt"

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
    set rpt         [expr { [info exists results(-rpt)]       ? $results(-rpt)       : "report_logic_levels.rpt"   }]

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
        set _v_name "${RUNNING_DIR}/reports/report_logic_levels_violations.rpt"
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
        {-rpt "report file" "" string required}
}

proc ory_genus_reports {} {

	# Report lebs util
	source /space/users/ory/user/be_scripts/nxt_007_tools/grid_cluster/highlight_guides.tcl
	report_lebs_util 1 1

	

}


proc ory_calc_util { {bbox 0} } {

	if { $bbox != 0 } {
    	return
    }

}

proc report_ports_levels { {ports ""} } {
	
    puts "Start: [::ory_time::now]"
    if { $ports != "" } {
    	set all_inputs  [get_ports [get_db $ports -if {.direction=="in"}]]
    	set all_outputs [get_ports [get_db $ports -if {.direction=="out"}]]        
    } else {
		set all_inputs  [all_inputs ]
	    set all_outputs [all_outputs]    
    }
    array unset ports_arr 

	puts "Analyzing [sizeof $all_inputs] inputs [::ory_time::now]"        
    foreach_in_collection port $all_inputs {
	    set end_points [get_pins -quiet [get_db [all_fanout -from $port -flat -endpoints_only ] -if {!.obj_type == "port"}]]
    	if { [sizeof $end_points] == 0  } { continue }

      	set all_paths_from_port [all_fanout -from $port -flat ]
        set max_path_length 0

     	foreach_in_collection pin $end_points {
            set path_to_pin [all_fanin -to $pin -flat ]
            set common_path [remove_from_collection $path_to_pin [remove_from_collection $path_to_pin $all_paths_from_port]] ; # common collection
            set common_path_length [sizeof [get_cells -of $common_path -quiet]]
            if { $max_path_length < $common_path_length } { 
            	set max_path_length $common_path_length
                set ports_arr([get_db $port .name]) [list $common_path_length [get_db $port .direction] [get_object_name $pin]]
            }
            
        }
        
    }

	puts "Analyzing [sizeof $all_outputs] outputs [::ory_time::now]"        	
    foreach_in_collection port $all_outputs {

	    set start_points [get_pins -quiet [get_db [all_fanin -to $port -flat -startpoints_only ] -if {!.obj_type == "port"}]]
    	if { [sizeof $start_points] == 0  } { continue }

      	set all_paths_to_port [all_fanin -to $port -flat ]
        set max_path_length 0

     	foreach_in_collection pin $start_points {
            set path_from_pin [all_fanout -from $pin -flat ]
            set common_path [remove_from_collection $path_from_pin [remove_from_collection $path_from_pin $all_paths_to_port]] ; # common collection
            set common_path_length [sizeof [get_cells -of $common_path -quiet]]
            if { $max_path_length <  $common_path_length } { 
              	set max_path_length $common_path_length
               	set ports_arr([get_db $port .name]) [list $common_path_length [get_db $port .direction] [get_object_name $pin]]
            }
        }

    }

	puts "End: [::ory_time::now]"    
            
    redirect ports_table.tbl { parray ports_arr }

}

proc report_unsampled_ports { {output ""} } {

    puts "Start: [::ory_time::now]"
    set ports ""
    if { $ports != "" } {
    	set all_inputs  [get_ports [get_db $ports -if {.direction=="in"}]]
    	set all_outputs [get_ports [get_db $ports -if {.direction=="out"}]]        
    } else {
		set all_inputs  [all_inputs ]
	    set all_outputs [all_outputs]    
    }
    array unset ports_arr 

	puts "Analyzing [sizeof $all_inputs] inputs [::ory_time::now]"        
    foreach_in_collection port $all_inputs {
		set afo [get_db [all_fanout -from $port  -flat -only_cells] -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]
        if { [sizeof $afo] != 0 } { set ports_arr([get_object_name $port]) "[get_db $port .direction]\tUnsampled" } else { set ports_arr([get_object_name $port]) "[get_db $port .direction]\tSampled" }
    }

	puts "Analyzing [sizeof $all_outputs] outputs [::ory_time::now]"        	
    foreach_in_collection port $all_outputs {
		set afi [get_db [all_fanin -to $port  -flat -only_cells] -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]
        if { [sizeof $afi] != 0 } { set ports_arr([get_object_name $port]) "[get_db $port .direction]\tUnsampled" } else { set ports_arr([get_object_name $port]) "[get_db $port .direction]\tSampled" }
    }
    
    if { $output == "" } {set output "unsampled_ports_table.tbl"}
#    redirect $output { parray ports_arr }
	

    redirect $output {
    puts "[format %-50s Port_Name] [format %-10s Direction] Status"
    foreach port [lsort [array names ports_arr]] {
    	lassign $ports_arr($port) dir status
        if { $status == "Sampled" } { continue } ; # comment out to print sampled
        set port [string map {"{" "" "}" ""} $port]
        set line "[format %-50s $port] [format %-10s $dir] $status"
        puts $line
    }
    }
    

 	puts "End: [::ory_time::now]"       
}

proc compare_unsampled_reports { rpt1 rpt2 } {

	set fp1 [open $rpt1 r]
    set fp1_data [read $fp1]
    close $fp1
    
	set fp2 [open $rpt2 r]
    set fp2_data [read $fp2]
    close $fp2
    
    array unset comp_arr
    array unset noneq_arr    
    foreach line [split $fp1_data "\n"] {
    	if { $line == "" } { continue }
    	lassign [split [regsub -all " +|\t+" [regsub "=" $line " "] " "] " "] a dir sam
        regexp "\\((.+)\\)" $a res port_name
        set comp_arr($port_name:rpt1) [list $dir $sam]
    } 

    foreach line [split $fp2_data "\n"] {
    	if { $line == "" } { continue }
    	lassign [split [regsub -all " +|\t+" [regsub "=" $line " "] " "] " "] a dir sam
        regexp "\\((.+)\\)" $a res port_name
        set comp_arr($port_name:rpt2) [list $dir $sam]
        
        if { [lindex $comp_arr($port_name:rpt1) 1] != $sam } {
        	set noneq_arr($port_name:rpt1/rpt2) [list $comp_arr($port_name:rpt1) [list $dir $sam]]
            lappend noneq_arr(ports) $port_name
        }
    } 
    
    redirect noneq_ports.rpt {parray noneq_arr }
    
    return [array get noneq_arr]
}



::parseOpt::cmdSpec ory_map_logic_levels {
    -help "Report longest-logic-levels paths"
    -opt    {
            {-optname max_paths   -type integer   -default 50000     -required 0 -help "Max number of paths for report timing"}
            {-optname nworst      -type integer   -default 50        -required 0 -help "Max number of paths per endpoint"}            
            {-optname internal    -type boolean   -default false     -required 0 -help "If false, searching IO only"}
            {-optname no_derate   -type boolean   -default false     -required 0 -help "Use set_timing_derate for more accurate results (Runtime). This may corrupt your timing status!!!!"}
            {-optname mapped      -type boolean   -default false     -required 0 -help "If the design is mapped, use collection to count levels (Runtime)"}                                    
            {-optname output      -type string    -default ""        -required 0 -help "File name"}                                                
    }
}

proc ory_map_logic_levels { args } {
	# TODO
    # CHange flags to syngen + derate -DONE
    # Check for invs in gen - Not yet
    # check internal levels - Not yet
    # Add clock + cycle - DONE
    # Report timing per port VS nworst=100 - DONE. Report by bus
    # Sanity check for outputs - with Moriya and Yigal later
    # Insert to regression flow
    # Cheatsheet to FE
    
	if { ! [::parseOpt::parseOpt ory_map_logic_levels $args] } { return 0 }

    set internal  $opt(-internal)
    set max_paths $opt(-max_paths)
    set nworst    $opt(-nworst)
	set no_derate $opt(-no_derate)
	set mapped    $opt(-mapped)    
    
    parray opt
    
    if { !$internal } {  
    
    	set all_inputs  [all_inputs]
    	set all_outputs [all_outputs]            
        
        set pins [all_fanout -from $all_inputs -flat]
        set pins [add_to_collection $pins [all_fanin -to $all_outputs -flat]]

        set cells [get_db [get_cells -quiet -of $pins] -if {!.is_latch==true && !.is_flop==true && !.is_sequential}]
		
        if { !$no_derate } {
            puts "-I- Derating cells delay. [::ory_time::now]"    
            foreach view [get_db analysis_views] {
	            set corner [get_db $view .delay_corner]
	            set_timing_derate -delay_corner $corner -cell_delay -late 1000  $cells
	        }    
        }
		
        # Compress bus: [3] -> * ; "1" means that 5_[3] -> *_* ; less busses. Reasonable runtime on big partitions    
		set compressed_list [ory_bus_compress [get_db [all_inputs] .name] 1]

        if { $mapped } {    
            puts "-I- Getting outputs timing paths. [::ory_time::now]: nworst=$nworst ; max_paths=$max_paths"
		    set timing_paths {}            
 		    set timing_paths [report_timing -unconstrained -collection -max_paths $max_paths -nworst $nworst -to $all_outputs]

            set nworst    [lindex [lsort -real -inc [list 10   $nworst]] 0]
            set max_paths [lindex [lsort -real -inc [list 5000 $max_paths]] 0]            
            puts "-I- Getting inputs timing paths. [::ory_time::now]: nworst=$nworst ; max_paths=$max_paths"                        
            foreach bus $compressed_list {
	            redirect /dev/null {
                	set new_timing_paths [report_timing -unconstrained -collection -max_paths $max_paths -nworst $nworst -from [get_ports $bus -filter direction==in]] 
#                    puts "$bus   [sizeof $new_timing_paths]   "
                    append_to_collection -uniq timing_paths $new_timing_paths 
                }
            }
                        puts "-I- DONE - Getting timing paths. [::ory_time::now]"
        } else {
        	set string_list [list "report_timing -max_paths $max_paths -nworst $nworst -unconstrained -from \[ all_inputs \]"]
#            set rpt_str2 "report_timing -max_paths $max_paths -nworst $nworst -unconstrained -to   \[ all_outputs \]"
            set nworst    [lindex [lsort -real -inc [list 10   $nworst]] 0]
            set max_paths [lindex [lsort -real -inc [list 5000 $max_paths]] 0]            
            foreach bus $compressed_list {
            	lappend string_list "report_timing -unconstrained -max_paths $max_paths -nworst $nworst -from \[get_ports $bus -filter direction==in\]"
            }
            
    	    puts "-I- Using get_logic_levels to retrieve logic levels. [::ory_time::now]"            
	        redirect /dev/null { applet load get_logic_levels }
            redirect /tmp/count_logic_levels.rpt {echo "# This is not empty"}
            foreach string $string_list {
            	if { $string == "" } {continue}
    	    	redirect -app /tmp/count_logic_levels.rpt { get_logic_levels -skip_buf -skip_inv $string ; puts ""}
            }
        }

    } else {

        if { !$no_derate } {
            puts "-I- Derating cells delay. [::ory_time::now]"
            set cells [get_db insts -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]
            foreach view [get_db analysis_views] {
	            set corner [get_db $view .delay_corner]
	            set_timing_derate -delay_corner $corner -cell_delay -late 1000 $cells 
	        }
        }
        
        if { $mapped } {    
            puts "-I- Getting timing paths. [::ory_time::now]"
		    set timing_paths [report_timing -collection -max_paths $max_paths -nworst $nworst]
        } else {
      	    puts "-I- Using get_logic_levels to retrieve logic levels. [::ory_time::now]"            
            redirect /dev/null { applet load get_logic_levels }
        	redirect /tmp/count_logic_levels.rpt {  get_logic_levels -skip_buf -skip_inv  "report_timing -max_paths $max_paths -nworst $nworst" }
        }

    }
	if { $mapped } {
        puts "-I- Counting cells. [::ory_time::now]"        
	    set table {}
        foreach_in_collection tp $timing_paths {
       	    set points   [get_db $tp .timing_points] 
            set start    [get_db $tp .launching_point.name]
            set end      [get_db $tp .capturing_point.name]
            set pins     [get_db [get_db $tp .timing_points] .pin]
            set cells    [get_db [get_cells -quiet -of $pins] -if {!.is_latch==true && !.is_flop==true && !.is_sequential}]
            
            set from_clock [get_db $tp .launching_clock.name]
            set to_clock   [get_db $tp .capturing_clock.name]
			
            set ct     [list [get_db [get_clocks -quiet $from_clock] .period] [get_db [get_clocks -quiet $to_clock] .period]]
            if { [lindex $ct 0] == [lindex $ct 1] } {set ct [join [lsort -u $ct]]}
            set ct [lminus $ct {{}}]
            
            set logic   [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]]
            set buffers [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && !.is_combinational==true || .is_buffer==true || .is_inverter==true}]]
            lappend table [list [llength $cells] $logic $buffers $from_clock $to_clock $ct $start $end]                        
        }
        
#        foreach_in_collection tp [common_collection $timing_paths $timing_paths] {
#			
#            set points  [get_db $tp .timing_points]
#            set start   [get_db $tp .launching_point.name]
#            set end     [get_db $tp .capturing_point.name]
#            set pins    [get_db [get_db $tp .timing_points] .pin]
#            set cells   [get_db [get_cells -quiet -of $pins] -if {!.is_latch==true && !.is_flop==true && !.is_sequential}]
#
#            if { [llength $cells] == 0 } { 
#                set logic 0 ; set buffers 0
#            } else {
#                set logic   [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]]
#                set buffers [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && !.is_combinational==true || .is_buffer==true || .is_inverter==true}]]
#            }
#            if {$cells == "" || $logic == "" || $buffers == "" } { return "$start $end"}
#            lappend table [list [llength $cells] $logic $buffers $start $end]
#            puts "[list [llength $cells] $logic $buffers $start $end]"
#        }
        set header        [list Cells Logic Buf_Inv FromCLK ToCLK CT From To] 
    	set sorted_table  [lsort -index 1 -real -dec $table]
        
    } else {
#    	puts "-I- Using get_logic_levels to retrieve logic levels. [::ory_time::now]"
#	    redirect /dev/null { applet load get_logic_levels }
#    	redirect /tmp/count_logic_levels.rpt { get_logic_levels -skip_buf -skip_inv $rpt_str1 ; puts ""}
#    	if { [info exists rpt_str2] } { redirect -app /tmp/count_logic_levels.rpt { get_logic_levels -skip_buf -skip_inv $rpt_str2 } }
        
        puts "-I- Parsing logic levels report. [::ory_time::now]"
        set grep_res [regsub -all "\\-\\-" [exec cat /tmp/count_logic_levels.rpt | grep -B2 "Logic Level" ] "@"]
        
        foreach phrase [split $grep_res "@"] {
        	regexp "Start Point   \\-\\> (\[a-zA-Z0-9_\\\[\\\]/\]+).+End Point     \\-\\> (\[a-zA-Z0-9_\\\[\\\]/\]+).+Logic Levels  \\-\\> (\[0-9\]+)" $phrase main start end levels
            if { !$levels } { continue }
            if { [set dec [sizeof [get_ports -quiet "$start $end"]]] } { set levels [expr $levels - (2-$dec)] }
            if { [sizeof [get_ports -quiet $start]] == 0 } { set from_clock [get_db [get_db pins $start] .clocks.base_name] } else { set from_clock ""}
            if { [sizeof [get_ports -quiet $end  ]] == 0 } { set to_clock   [get_db [get_db pins $end] .clocks.base_name]   } else { set to_clock ""}
            lappend table [list $levels $from_clock $to_clock $start $end]            
        }
        set header        [list Logic "Start_clock(s)" "End_clock(s)" From To]    	
    	set sorted_table  [lsort -index 0 -real -dec $table]       
    }

    if { $opt(-output) == "" } { set output "logic_levels_report.rpt" } else { set output $opt(-output)}    
    puts "-I- Print table to $output"
    redirect $output { rls_table -table $sorted_table -header $header -breaks }
	
    if { ![catch {glob /tmp/count_logic_levels.rpt} res] } { file delete -force /tmp/count_logic_levels.rpt }
}

#
#::parseOpt::cmdSpec ory_report_timing_summary {
#    -help "Report longest-logic-levels paths"
#    -opt    {
#            {-optname from        -type string   -default ""       -required 0 -help "Report timing from"}
#            {-optname to          -type string   -default ""       -required 0 -help "Report timing to"}
#            {-optname max_paths   -type integer  -default 1000     -required 0 -help "Max number of paths for report timing"}
#            {-optname nworst      -type integer  -default 1        -required 0 -help "Max number of paths per endpoint"}            
#            {-optname group       -type string   -default ""       -required 0 -help "Max number of paths per endpoint"}                        
#            {-optname output      -type string   -default ""       -required 0 -help "File name"}                                                
#    }
#}
#
#proc ory_report_timing_summary { args } {
#
#	if { ! [::parseOpt::parseOpt ory_report_timing_summary $args] } { return 0 }
#    
#    set cmd "ory_report_timing -max_slack 999 -max_path $opt(-max_paths) -nworst $opt(-nworst)"
#    if { $opt(-group) != "" } {   append cmd " -group $opt(-group)"   }
#    if { $opt(-from)  != "" } {   append cmd " -from $opt(-from)"   }
#    if { $opt(-to)    != "" } {   append cmd " -to $opt(-to)"   }        
#
#    puts "-I- Eval: $cmd"
##    redirect _ory_tmp_report_timing.rpt { eval $cmd }
#    echo [redirect_and_catch  $cmd] > _ory_tmp_report_timing.rpt
#    
#
#    set fp [open _ory_tmp_report_timing.rpt r]
#    set fd [read $fp]
#    close $fp
#    
#    set fd_clean [regsub -all "#+" $fd "#"]
#    set fds      [split $fd_clean "#"]
#    
#    if { [llength $fds] < 2 } { 
#        puts "-W- No timing path found"
#        return
#    }
#
#    puts "-I- Parsing"      
#    set table {}
#    set id 1
#    set final_detail_report ""
#    foreach timing_path $fds {
#        
#        if { $timing_path == "" || ![regexp "Start Clock" $timing_path] } { continue }
#        
#        append final_detail_report "path id: $id"
#        append final_detail_report $timing_path
#
#        set group $id
#        regexp  "Startpoint: (\[\\\{\\\}a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res sp
#        regexp  "Endpoint: (\[\\\{\\\}a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res ep        
#        regexp  "Start Clock: (\[a-zA-Z0-9_/\\\<\\\>\\\[\\\]\]+)" $timing_path res sp_clk        
#        regexp  "End Clock: (\[a-zA-Z0-9_/\\\<\\\>\\\[\\\]\]+)" $timing_path res ep_clk                        
#        regexp  "Group: (\[a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res group                                
#
#        regexp  "Slack +:= +(\[\-.a-zA-Z0-9_/\\\<\\\>\\\{\\\}\\\[\\\]\]+)" $timing_path res slack                                        
#        regexp  "Required Time +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res req_time                                        
#        regexp  "Data Path +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res path_delay                                        
#        regexp  "Logic +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res logic                                        
#        regexp  "Buf/Inv +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res bufs                                        
#        regexp  "Total Dist +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res dist   
#        
#        set line  [list $id $group $slack [expr $logic + $bufs] $logic $bufs $dist $sp_clk $sp $ep_clk $ep]
#        lappend table $line
#
#        incr id        
#    
#    }
#    
#    set header [list id group slack cells logic "buf/inv" Dist start_clk startpoint end_clk endpoint]
#    redirect -var summary_table { rls_table -table $table -header $header -breaks -spac }
#    
#    set output $opt(-output)
#    if { $output == "" } { set output "ory_timing_summary.rpt" }
#    
#    redirect      $output { puts $summary_table }
#    redirect -app $output { puts $final_detail_report }
#    
#    file delete _ory_tmp_report_timing.rpt
#    
#    puts "-I- Report: $output"
#
#}


#proc ory_report_timing { args } {
#	
#    if { [regexp {\-help} $args] } {
#        report_timing -help
#        return
#    }
#
#    set debug_log log/.ory_report_timing_debug.log
#    
#    ######################################
#    # DEBUG
#    echo "-I- Running report_timing" > $debug_log
#    echo "set cmd \"redirect -app $debug_log \{ set tps \[ report_timing -collection $args \]\}\"" >> $debug_log
#    echo "eval \$cmd" >> $debug_log
#    ######################################
#
#    set cmd  "redirect -app $debug_log { set tps \[ report_timing -collection $args \]}"
#    eval $cmd
#
#    set parsed_reports ""
#    set index 0
#
#	foreach_in_collection tp $tps {
#        ######################################
#        # DEBUG
#        echo "-I- Parsing timing path number $index" >> $debug_log
#        ######################################
#    
#        append parsed_reports "####################################################################################################\n"
#    	redirect -app -var parsed_reports { ory_parse_timing_path $tp }
#        append parsed_reports "\n"        
#        incr index
#    }
#    
#    puts $parsed_reports    
#}
#
#proc ory_parse_timing_path { tp } {
#
##              View: func_ss_0p675v_125c_cworst_s
##              Group: reg2out
##         Startpoint: (R) i_gsu_top/gsu_mem_feedthrough_aon/mem_north_node_1_mem_north_track_1_u_ft_mem_rsp_north/slice_gen_0_u_vr_slice/fifo_mode_u_repeater_node/rd_ptr_reg_4/CP
##              Clock: (R) grid_tor_clk
##           Endpoint: (R) gsu_gmu_ft_mem_rsp_north_header_1_1[5]
##              Clock: (R) virtual_grid_tor_clk
##            N-Sigma: 3.000
##
##                       Capture       Launch
##         Clock Edge:+    0.410        0.000
##        Src Latency:+    0.000        0.000
##        Net Latency:+    0.188 (I)    0.210 (P)
##            Arrival:=    0.598        0.210
#    set debug_log log/.ory_parse_timing_path_debug.log
#    
#    ######################################
#    # DEBUG
#    echo "-I- Analyzing $tp" > $debug_log
#    echo "-I- Getting start point attributes " >> $debug_log
#    ######################################
#    
#	set view  [get_db $tp .view_name]
#    if { [get_db program_short_name] != "genus" } { set group [get_db $tp .path_group_name] } else { set group "NA" }
#
#    set start(point)       [get_db $tp .launching_point.name]
#    set start(latency)     [get_db $tp .launching_clock_latency] 
#    set start(clock)       [get_db $tp .launching_clock.base_name] 
#    set start(r/f)         [get_db $tp .launching_point.slack_max_edge]
#
#    set start(input_delay) "0.0"
#    if { [get_db $tp .launching_point.obj_type] == "port" && [regexp -all "input_delay \\\{\[0-9. \]+\\\}" [get_db $tp .launching_point.timing_info] res ] } {
#    array set array_res [join [regexp -inline -all "input_delay \\\{\[0-9. \]+\\\}" [get_db $tp .launching_point.timing_info] ] " "]
#    set start(input_delay) [lsort -u $array_res(input_delay)]
#    }
#
#    set start(prp_clk) "(I)" 
#
#    ######################################
#    # DEBUG
#    echo "-I- Getting end point attributes " >> $debug_log
#    ######################################
#
#    set end(point)     [list [get_db $tp .capturing_point.name] ]
#    set end(latency)   [get_db $tp .capturing_clock_latency] 
#    set end(clock)     [get_db $tp .capturing_clock.base_name]
#    set end(r/f)       [get_db $tp .capturing_point.slack_max_edge]
#
#    set end(output_delay) "0.0"
#    if { [get_db $tp .capturing_point.obj_type] == "port"  } {
#    array set array_res [join [regexp -inline -all "output_delay \\\{\[0-9. \]+\\\}" [get_db $tp .capturing_point.timing_info] ] " "]
#    set end(output_delay) [lsort -u $array_res(output_delay)]
#    }
#
#    set end(prp_clk) "(I)" 
#    
#    ######################################
#    # DEBUG
#    echo "-I- Getting timing path attributes" >> $debug_log
#    ######################################
#
#    set path(out_delay)   [get_db $tp .external_delay]            
#    set path(required)    [get_db $tp .required_time]                    
#    set path(delay)       [get_db $tp .path_delay]                    
#    set path(slack)       [get_db $tp .slack]
#    set path(period)      [get_db $tp .period]
#    if { [is_attribute -obj timing_path uncertainty] } {
#        set path(uncert)  [get_db $tp .uncertainty] 
#    } else { 
#        set path(uncert)  [get_db [get_clocks $start(clock)] .setup_uncertainty]
#    }
#    set path(setup)       [get_db $tp .setup]
#    if { $path(slack) > 0 } { set meet "MET" } else { set meet "VIOLATED" }
#        
#    # Skew
##    set path(skew) [expr $end(latency) + $end(src_l) - $start(latency) - $start(src_l) ]
#
#    ######################################
#    # DEBUG
#    echo "-I- Count cells" >> $debug_log
#    ######################################
#
#    # Count cells    
#    set pins     [get_db [get_db $tp .timing_points] .pin]
#    set cells    [get_db [get_cells -quiet -of $pins] -if {!.is_latch==true && !.is_flop==true && !.is_sequential}]
#
#    set path(logic_cells) [get_db [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}] .name]
#    set path(buffs_cells) [get_db [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && !.is_combinational==true || .is_buffer==true || .is_inverter==true}] .name]
#    set path(logic)   [llength $path(logic_cells)]
#    set path(buffers) [llength $path(buffs_cells)]
#    
#    if { [llength $cells] == 0 } {
#        set path(power)	    0
#        set path(avg_power) 0
#        set path(area)	    0
#        set path(avg_area) 0        
#    } else {
#        set path(power)	  [lsum [get_db $cells .power_total]]
#        set path(avg_power)     [format "%.6f" [expr $path(power)/[llength $cells]]]
#
#        if { ![regexp no_value [set areas [get_db $cells .area]]] } { 
#            set path(area)      [lsum [get_db $cells .area]] 
#            set path(avg_area)  [format "%.4f" [expr $path(area)/[llength $cells]]  ]
#        } else { 
#            set path(area) no_value 
#            set path(avg_area) no_value
#        }        
#    }
#
#
#
##
##       Output Delay:-    0.226
##        Uncertainty:-    0.013
##        Cppr Adjust:+    0.000
##      Required Time:=    0.360
##       Launch Clock:=    0.210
##          Data Path:+    0.252
##              Slack:=   -0.097
#
#    ######################################
#    # DEBUG
#    echo "-I- Analyze timing points" >> $debug_log
#    ######################################
#    
#	set total_dist 0
#    set total_cell_delay 0  
#    set total_logic_delay 0
#    set total_buff_delay 0
#    set total_rc_delay   0
#    set index 0
#    set table {}
#    array unset point_att_arr
#    set timing_points [get_db $tp .timing_points]
#    foreach point $timing_points {
#        array set point_att_arr [ory_get_obj_dbs $point $index]
#
#        set current_pin $point_att_arr($index:pin)        
#        set base_cell   "-"
#        set delay "-"
#        set slew "-"        
#        set net_load "-"        
#        set net ""
#        set fanout "-"
#        set inc "-"        
#        set dist "-"
#
#        ######################################
#        # DEBUG
#        echo "-I- Analyzing pins $current_pin, index: $index" >> $debug_log
#        ######################################
#        
#        # Determine r/f
#        if { $point_att_arr($index:arrival) == [get_db $current_pin .arrival_max_rise] } {
#            set point_att_arr($index:r/f) "rise"
#        } else {
#            set point_att_arr($index:r/f) "fall"
#        }
#        set edge $point_att_arr($index:r/f)
#        
#        if { $index == 0 && [get_db $current_pin .obj_type] == "port" } {
#                set net       [get_db $current_pin .net]
#                set net_load  [expr [get_db $current_pin .wire_capacitance] + [get_db $current_pin .capacitance_max_$edge] ]
#                set fanout    [get_db $net .num_loads]
#        }
#
#        if { $index > 0 } {
#            # Get max delay
#            set prev_pin    $point_att_arr([expr $index - 1]:pin)
#            
#            # Get load
#            set dir [get_db $current_pin .direction]
#            if { $dir == "out" && [get_db $current_pin .obj_type] != "port" } {
#                set cell      [get_db $current_pin .inst.name]
#                set net       [get_db $current_pin .net]
#                set net_load  [expr [get_db $current_pin .wire_capacitance] + [get_db $current_pin .capacitance_max_$edge] ]
#                set fanout    [get_db $net .num_loads]
#                
#                if { $point_att_arr($index:arrival) == "inf" } { 
#                    set inc "inf"
#                } else {
#                    set inc [expr $point_att_arr($index:arrival) - $point_att_arr([expr $index -1]:arrival)]  
#                }
#                
#                if { $total_cell_delay == "inf" || $inc == "inf" } {
#                    set total_cell_delay "inf"
#                } else {
#                    set total_cell_delay [expr $total_cell_delay + $inc]                    
#                }
#
#
#                
#                if {       [lsearch $path(buffs_cells) $cell] > -1 } {
#                    set total_buff_delay [expr $total_buff_delay + $inc]
#                } elseif { [lsearch $path(logic_cells) $cell] > -1 } {
#                    set total_logic_delay [expr $total_logic_delay + $inc]                
#                }
#
#            } else {
#                # Calc dist
#                set loc1 [split [string map {"\{" "" "\}" ""} [get_db $current_pin .location] ] " "]
#                set loc2 [split [string map {"\{" "" "\}" ""} [get_db $prev_pin .location]    ] " "]
#                set dist -0
#                if { $loc1 != "no_value" && $loc2 != "no_value" } {
#                    set dist [expr abs([lindex $loc1 0] - [lindex $loc2 0]) + abs([lindex $loc1 1] - [lindex $loc2 1])]
#                    set total_dist [expr $total_dist + $dist]
#                } 
#                
#                set slew [get_db $point .pin.slew_max_$edge]
#                
#                if { $point_att_arr($index:arrival) == "inf" } { 
#                    set delay "inf"
#                } else {
#                    set delay [expr $point_att_arr($index:arrival) - $point_att_arr([expr $index -1]:arrival)]
#                }
#                
#                if { $total_rc_delay == "inf" || $delay == "inf" } {
#                    set total_rc_delay "inf"
#                } else {
#                    set total_rc_delay [expr $total_rc_delay + $delay]
#                }
#
#                if { [get_db $point_att_arr($index:pin) .obj_type] != "port" } {
#                    set base_cell   [get_db $point_att_arr($index:pin) .inst.base_cell.name]                                                
#                    set vt_group    [ory_return_vt_group $base_cell]
#                    lappend vt_groups_arr($vt_group) $base_cell           
#                }     
#            }
#        }
#        set point_att_arr($index:net)       [get_db $net .name]
#        set point_att_arr($index:net_load)  $net_load
#        set point_att_arr($index:max_delay) $delay                        
#        
#        lappend table [list [string range [get_db $current_pin .name] end-180 end] [string range $edge 0 0] $base_cell $dist $slew $net_load $fanout $delay $inc $point_att_arr($index:arrival)]
#
#        incr index
#    }
#
#    ######################################
#    # DEBUG
#    echo "-I- Calc post analysis data " >> $debug_log
#    ######################################
#
#    if { $path(logic) || $path(buffers) } { set avg_cell_delay [format "%.4f" [expr $total_cell_delay/($path(logic) + $path(buffers))]] } else { set avg_cell_delay NA}
#    if { $path(logic)                   } { set avg_lgc_delay  [format "%.4f" [expr $total_logic_delay/$path(logic)]] } else { set avg_lgc_delay NA }
#    if { $path(buffers)                 } { set avg_buf_delay  [format "%.4f" [expr $total_buff_delay/$path(buffers)]]} else { set avg_buf_delay NA }
#
#    # Build path table
#    set pre_table "
#       View: $view
#      Group: $group
# Startpoint: $start(point)
#Start Clock: $start(clock)
#   Endpoint: $end(point)
#  End Clock: $end(clock)
#
#    "
##
##    if { $path(in_delay) != "no_value" } {
##    set post_table "
##  Input Delay:-    $path(in_delay)"
##    } elseif { $path(out_delay) != "no_value" } {
##    append post_table "
## Output Delay:-    $path(out_delay)"    
##    } 
#
#    append post_table "
#       Period       :=    $path(period)
#  Uncertainty       :-    $path(uncert)       
#        Setup       :-    $path(setup)         
# Output Delay       :-    $end(output_delay)  
#Required Time       :=    $path(required)   
#
#  Input Delay       :=    -$start(input_delay)
#    Data Path       :=    -$path(delay)      
#        Slack       :=    $path(slack)                     
#
#        Logic       :=    $path(logic)                             
#      Buf/Inv       :=    $path(buffers)  
#      
#Total Dist          :=    [format "%.2f" $total_dist]
#
#Total RC   Delay    :=    [format "%.4f" $total_rc_delay]
#Total Cell Delay    :=    [format "%.4f" $total_cell_delay]
#Total Logic Delay   :=    [format "%.4f" $total_logic_delay]
#Total Buf/Inv Delay :=    [format "%.4f" $total_buff_delay]
#Avg Cell Delay      :=    $avg_cell_delay
#Avg Logic Delay     :=    $avg_lgc_delay
#Avg Buf/Inv Delay   :=    $avg_buf_delay 
#
#Avg Cell Power      :=    $path(avg_power)
#Avg Cell Area       :=    $path(avg_area)
#
#"
#
#    foreach vt_group [lsort [array names vt_groups_arr]] {
#        append post_table "[format %-14s $vt_group]:=    [llength $vt_groups_arr($vt_group)] \n"
#    }
#    
#    puts $pre_table
#    
#    set header [list Inst Edge Base_cell Dist Slew Load FO Delay Incr Arrival]
#    set format "%s %s %s %-.2f %.3f %.3f %s %.3f %.3f %.3f %.3f"
#    
#    rls_table -table $table -format $format -header $header -spac -breaks
# 
#    puts $post_table 
#
#}



proc ory_parse_report_timing_file { file } {

#    set file bla_1000.rpt
    set fp [open $file r]
    set timing_paths [read $fp]
    close $fp
    
    set res [ory_parse_timing_paths $timing_paths]
    
    return $res
    

}



proc ory_report_timing { args } {
	
    if { [regexp {\-help} $args] } {
        report_timing -help
        return
    }

    set prev_trf [get_db timing_report_fields]
    set_db -quiet timing_report_fields {timing_point cell edge fanout load transition total_derate delay arrival pin_location flags}
    set cmd  "report_timing -split_delay $args"
    redirect -var timing_paths { eval $cmd }
    set_db -quiet timing_report_fields $prev_trf

    
    set res [ory_parse_timing_paths $timing_paths]
    
    puts [lindex $res 1]

}



::parseOpt::cmdSpec ory_report_timing_summary {
    -help "Report longest-logic-levels paths"
    -opt    {
            {-optname from        -type string   -default ""       -required 0 -help "Report timing from"}
            {-optname to          -type string   -default ""       -required 0 -help "Report timing to"}
            {-optname max_paths   -type integer  -default 1000     -required 0 -help "Max number of paths for report timing"}
            {-optname nworst      -type integer  -default 1        -required 0 -help "Max number of paths per endpoint"}            
            {-optname group       -type string   -default ""       -required 0 -help "Max number of paths per endpoint"}                        
            {-optname output      -type string   -default ""       -required 0 -help "File name"}                                                
    }
}

proc ory_report_timing_summary { args } {

	if { ! [::parseOpt::parseOpt ory_report_timing_summary $args] } { return 0 }
    
    set cmd "report_timing -hpin -split_delay -max_slack 999 -max_path $opt(-max_paths) -nworst $opt(-nworst)"
    if { $opt(-group) != "" } {   append cmd " -group $opt(-group)"   }
    if { $opt(-from)  != "" } {   append cmd " -from $opt(-from)"   }
    if { $opt(-to)    != "" } {   append cmd " -to $opt(-to)"   }        

    puts "-I- Eval: $cmd"
    
    set prev_trf [get_db timing_report_fields]
    set_db -quiet timing_report_fields {timing_point cell edge fanout load transition total_derate delay arrival pin_location flags}
    
    redirect -var return_var { eval $cmd }
    redirect _ory_tmp_report_timing.rpt { puts $return_var }
    
    set_db -quiet timing_report_fields $prev_trf
    
    # If not paths found
    if { [regexp "No paths found" $return_var] } {
        puts "-I- No paths found"
        return 
    }
        
    set output $opt(-output)
    if { $output == "" } { set output "ory_timing_summary.rpt" }
        
    set res [ory_parse_timing_paths $return_var]
    set table   [lindex $res 0]
    set new_rpt [lindex $res 1]
    
    set header [list "Path_id" "Group" "Slack" "Cells" "Logic" "Buf/Inv" "Dist" "From_Clk" "From" "To_Clk" "To"]
    redirect -var print_table { rls_table -table $table -header $header -spac -breaks }

    redirect ${output}          { puts $print_table }
    redirect ${output}.detailed { puts $new_rpt }

    file delete _ory_tmp_report_timing.rpt
    
    puts "-I- Report: $output"

}

proc ory_parse_timing_paths { timing_paths } {

    global PROJECT
#    if { [info exists ::env(PROJECT)] } { set proj $::env(PROJECT) } else { set proj [lindex [split [pwd] "/"] end-3] }
    
    if { [regexp "snpsn" $PROJECT] } {
	    puts "-I- process is snps 5nm"
        set bc_pattern "(HDB\[A-Z\]+06_\[A-Z0-9_\]+) |(sacrls\[a-z0-9\]+) "
    } elseif { [regexp "brcm|nxt080|inext" $PROJECT] } {
	    puts "-I- process is brcm 5nm"
        set bc_pattern "(F6\[A-Z\]+AA_\[A-Z0-9_\]+) |(M5SRF\[A-Z0-9\]) "
    } else {       
        set bc_pattern "DOOMED_TO_FAIL"
    }

    if { [get_db program_short_name] == "genus" } {
        set program "genus"
        set dp_pattern " +Data Path:\- +(\[\\\-0-9\\\.\]+)"
    } else {
        set program "not_genus"
        set dp_pattern " +Data Path:\\\+ +(\[\\\-0-9\\\.\]+)"
    }


    array unset paths_arr 
    set start 0
    set end   0
    set string_len [string length $timing_paths]
    for {set i 1} { $end != $string_len } { incr i } {

        set path      "Path $i"    
        set next_path "Path [expr $i + 1]"
        set start [string first $path $timing_paths $end]
        set end   [expr [string first $next_path $timing_paths $start+1] - 1]

        if { $end < 0 } { set end $string_len }
        
        set paths_arr($i) [string range $timing_paths $start $end]

    }
    
    
    set table {}
    set new_rpt ""
    foreach id [lsort -real -inc [array names paths_arr]] {
        
        set path $paths_arr($id)
#        if { [catch { set base_cells [regexp -all -inline $bc_pattern $path] } res] } { set base_cells {} }

        if { [catch { regexp " +Slack:= +(\[\\\-0-9\\\.\]+)" $path regres slack } res] } { set slack "NA" }        
        if { [catch { regexp $dp_pattern $path regres dp } res] } { set dp "NA" }                

        if { [catch { regexp " +Group: +(\[A-Za-z0-9_/\\\[\\\]\]+)"              $path regres group } res]      } { set group "NA" }                
        if { [catch { regexp " +Startpoint: \\(\[R|F|L\]\\) +(\[A-Za-z0-9_/\\\[\\\]\]+)" $path regres startpoint } res] } { set startpoint "NA" }                
        if { [catch { regexp " +Endpoint: \\(\[R|F|L\]\\) +(\[A-Za-z0-9_/\\\[\\\]\]+)"   $path regres endpoint } res]   } { set endpoint "NA" }                        
        
        set startpoint_pattern [string map {"[" "." "]" "."} $startpoint]
        set endpoint_pattern   [string map {"[" "." "]" "."} $endpoint]        
        
        if { [catch { set clocks [regexp -all -inline " +Clock: \\(\[R|F|L\]\\) +(\[A-Za-z0-9_/\\\[\\\]\]+)"   $path  ] } res]   } { set clocks "NA" }                                
        lassign $clocks a start_clock b end_clock
        
#        set number_of_cells [llength $base_cells]
        set flops 0
        set logic 0
        set rpts  0
        set rc_delay 0
        set logic_delay 0
        set rpts_delay  0
        set flop_delay  0
        set avg_logic_delay 0
        set avg_rpts_delay  0  
        set dist 0    
        set prevx -1
        set prevy -1 
        set is_path false
#        if { $number_of_cells > 0 } { 

            foreach line [split $path "\n"] { 
                
                if { ![regexp $bc_pattern $line] && ![regexp "\(arrival\|port\)" $line] && ![regexp $endpoint_pattern $line] } { continue }
                if { [regexp "hpin" $line] } { continue }

                set spline [split [regsub -all " +" $line " "] " "]

                lassign $spline space1 pin bc edge fo cap trans derate delay arrival loc flags 
                
                if { $pin == "$startpoint" } { set is_path true ; set prev_arrival $arrival }
                if { !$is_path } { continue }
                
                lassign [split [string map {"(" "" ")" ""} $loc] ","] x y
                
                if { $prevx > 0 } {
                    set dist [expr $dist + abs($x - $prevx) + abs($y - $prevy)]
                }

                if { $delay == "-" } { set delay 0 }
                
                if { ($program == "genus" && $cap != "-" && $trans != "-" && $bc != "(arrival)") || ($program == "not_genus" && $cap != "-" && $trans != "-" && $bc != "(arrival)" && $fo == "-" ) } {
                    
                    if { $program != "genus" } { set lc [get_db base_cells $bc] } else { set lc [index_collection [get_lib_cells $bc] 0] }
                    if { [regexp "unmapped" $bc] } { incr logic ; set logic_delay [expr $logic_delay + $arrival - $prev_arrival] }        
                    if { [get_db $lc .is_flop] || [get_db $lc .is_memory] || [get_db $lc .is_macro] } { 
                    
                        incr flops 
                        set flop_delay [expr $flop_delay + $arrival - $prev_arrival]                        
                    } elseif { [get_db $lc .is_buffer] || [get_db $lc .is_inverter] } { 
                        incr rpts 
                        set rpts_delay [expr $rpts_delay + $arrival - $prev_arrival]
                    } else { 
                        incr logic 
                        set logic_delay [expr $logic_delay + $arrival - $prev_arrival]
                    }


                } else {
                    set rc_delay [expr $rc_delay + $arrival - $prev_arrival]
                }
                
                set prevx $x
                set prevy $y
                set prev_arrival $arrival 
                
#                puts "$line $rpts_delay $logic_delay $rc_delay $flop_delay"
                                            
            }
            
            if { $logic > 0 } { set avg_logic_delay [expr $logic_delay/$logic] } 
            if { $rpts > 0  } { set avg_rpts_delay  [expr $rpts_delay/$rpts]   } 
            set cells_delay [expr $logic_delay + $rpts_delay + $flop_delay]
            set d_err       [expr {$dp > 0 ?  (1.0*$dp-$cells_delay - $rc_delay)/$dp : 0.0 }]
            
#        }
        
        set line [list $id $group $slack [expr $logic + $rpts] $logic $rpts "[format "%.2f" $dist]" $start_clock $startpoint $end_clock $endpoint ]    
        lappend table $line
        
        append new_rpt "$path"
        append new_rpt "Path Summary:
        Logic       :=    $logic                             
      Buf/Inv       :=    $rpts  
      
Total Dist          :=    [format "%.2f" $dist]

Total RC   Delay    :=    [format "%.3f" $rc_delay]
Total Cell Delay    :=    [format "%.3f" $cells_delay]
Total Logic Delay   :=    [format "%.3f" [expr $logic*$avg_logic_delay]]
Total Buf/Inv Delay :=    [format "%.3f" [expr $rpts*$avg_rpts_delay]]

Avg Logic Delay     :=    [format "%.3f" $avg_logic_delay]
Avg Buf/Inv Delay   :=    [format "%.3f" $avg_rpts_delay ]

Cell+RC delay Error (%):  [format "%.2f" [expr 100*$d_err]]%

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n\n"        
    }
    
    return [list $table $new_rpt]

}


proc report_mcp_hfn { {th 1000} } {

    set cells [get_cells -hier -filter full_name=~*mcp_buf_SIZE_ONLY*]
    if { [sizeof $cells] == 0 } { puts "-W- No mcp bufs found" ; return }
    set table {}
    set hfn {}
    foreach_in_collection cell $cells {
        set pin [get_pins -of $cell -filter direction==out]
        set afo [all_fanout -flat -end -from $pin]
        lappend table [list [get_db $pin .name] [sizeof $afo]]
        
        if { [sizeof $afo] > $th } { lappend hfn [get_db $pin] }
    }
    
    set table [lsort -index 1 -real -dec $table]
    
    redirect reports/report_mcp_hfn.rpt { rls_table -table $table -header {"Pin" "AFO"} -spac -breaks }
    
    return $hfn

}

proc swap_mcp_bufs { cells {base_cell F6LLAA_OA21X4} {pin_map {i i0_0}} {tieoffs {i0_1 0 i1_0 1}}} {
    
    array set to_arr $tieoffs
    
    set new_cells {}
    
    foreach cell [get_db [get_cells $cells] .name] {
        change_link -instances $cell -base_cell $base_cell  -pin_map $pin_map
        foreach pin [array names to_arr] {
            set real_pin "$cell/$pin"
            connect -constant $to_arr($pin) $real_pin
        }
        lappend new_cells $cell
    }
    
    set_dont_touch [get_cells $new_cells] true
    
    set fp [open out/complex_mcp_buf_list.rpt w]
    puts $fp [join $new_cells "\n"]
    close $fp
}












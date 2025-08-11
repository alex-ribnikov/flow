proc ory_find_overalpping_port { {ports ""} } {

    set ports [get_ports]
    if { $ports != "" } { set ports [get_ports $ports] }
    
    array unset layer_loc_arr
#    dict unset layer_loc_dict
    foreach_in_collection port $ports {
    	set layer [get_db $port .layer]
        set loc	  [get_db $port .location]
        lappend layer_loc_arr("${layer}:${loc}") [get_object_name $port]
        #dict incr layer_loc_dict "${layer}_${loc}"
    }
    
    redirect report_ports_overlap.rpt {
    foreach key [array names layer_loc_arr] {
    	set num_of_ports [llength $layer_loc_arr($key)]
    	if { $num_of_ports > 1 } {
        	puts "[format %-30s $key] $layer_loc_arr($key)"
        }
    }
    }

}

proc ory_check_ports { {quick_fix false} {ports ""} } {

    if { $ports == "" } { set ports [get_db ports] }
    
    array unset status_arr
    set bad_ports {}
    
    foreach port [get_db $ports] {
    
        set ps  [get_db $port .place_status]
        set loc [get_db $port .location]
        
        set status_arr([get_db $port .name]:$ps) $loc

        if { $ps == "fixed" && $loc == "\{0.0 0.0\}" } {
            lappend bad_ports $port
        }
    }
    
    puts "-W- Ports with fixed status and 0,0 location"
    t $bad_ports place_status location
    
    if { $quick_fix } {
        ory_quick_place_bad_ports $bad_ports
    }
    
}

proc ory_quick_place_bad_ports { ports } {
    set_db assign_pins_edit_in_batch true
    
    set_db $ports .place_status unplaced
    
    foreach port $ports {
    edit_pin  -fix_overlap -pin [get_db $ports .name] -assign {0 10} -snap track -layer M4
    }
    
    set_db $ports .place_status fixed
    
    set_db assign_pins_edit_in_batch false
}

proc report_stage_timing { stage } {


 time_design -report_only -expanded_views -report_dir out/${stage} -num_paths 5000 -report_prefix postC
 time_design -report_only -expanded_views -report_dir out/${stage} -num_paths 5000 -report_prefix postC -hold
 report_clock_tree_structure -expand_below_generators -expand_below_logic -show_sinks -out_file out/${stage}/all_clocks.show_sinks.trace
 report_clock_tree_structure -expand_below_generators -expand_below_logic         -out_file out/${stage}/all_clocks.trace
 report_ccopt_worst_chain -out_file out/${stage}/ccopt_worstChain.rpt
 report_clock_trees -out_file out/${stage}/ccopt_clock_trees.rpt
 report_skew_groups -out_file out/${stage}/ccopt_skew_groups.rpt


}


proc ory_report_timing { args } {
	
    if { [regexp {\-help} $args] } {
        report_timing -help
        return
    }
    
    set cmd "redirect /dev/null { set tps \[ report_timing -collection $args \]}"
    eval $cmd
    
    set parsed_reports ""
	foreach_in_collection tp $tps {
        append parsed_reports "####################################################################################################\n"
    	redirect -app -var parsed_reports { ory_parse_timing_path $tp }
        append parsed_reports "####################################################################################################\n"        
    }
    
    puts $parsed_reports    
}

proc ory_parse_timing_path { tp } {

#              View: func_ss_0p675v_125c_cworst_s
#              Group: reg2out
#         Startpoint: (R) i_gsu_top/gsu_mem_feedthrough_aon/mem_north_node_1_mem_north_track_1_u_ft_mem_rsp_north/slice_gen_0_u_vr_slice/fifo_mode_u_repeater_node/rd_ptr_reg_4/CP
#              Clock: (R) grid_tor_clk
#           Endpoint: (R) gsu_gmu_ft_mem_rsp_north_header_1_1[5]
#              Clock: (R) virtual_grid_tor_clk
#            N-Sigma: 3.000
#
#                       Capture       Launch
#         Clock Edge:+    0.410        0.000
#        Src Latency:+    0.000        0.000
#        Net Latency:+    0.188 (I)    0.210 (P)
#            Arrival:=    0.598        0.210

	set view  [get_db $tp .view_name]
    set group [get_db $tp .path_group_name]    

    set start(point)   [get_db $tp .launching_point.name]
    set start(edge)    [get_db $tp .launching_clock_open_edge_time] 
    set start(r_f)     [get_db $tp .launching_clock_open_edge_type] 
    set start(latency) [get_db $tp .launching_clock_latency] 
    set start(clock)   [get_db $tp .launching_clock.base_name] 
    set start(src_l)   [get_db $tp .launching_clock.source_latency_late_${start(r_f)}_max]  ; # source latency
    if { $start(src_l) == "no_value" } { set start(src_l) 0 }
    set start(arrival) [expr $start(edge) + $start(latency) + $start(src_l)]
    if { [get_db $tp .launching_clock_is_propagated] } { set start(prp_clk) "(P)" } else { set start(prp_clk) "(I)" }

    set end(point)     [list [get_db $tp .capturing_point.name] ]
    set end(edge)      [get_db $tp .capturing_clock_close_edge_time] 
    set end(r_f)       [get_db $tp .capturing_clock_close_edge_type] 
    set end(latency)   [get_db $tp .capturing_clock_latency] 
    set end(clock)     [get_db $tp .capturing_clock.base_name]        
    set end(src_l)   [get_db $tp .launching_clock.source_latency_late_${end(r_f)}_max] ; # source latency
    if { $end(src_l) == "no_value" } { set end(src_l) 0 }
    set end(arrival)   [expr $end(edge) + $end(latency) + $end(src_l)]
    if { [get_db $tp .capturing_clock_is_propagated] } { set end(prp_clk) "(P)" } else { set end(prp_clk) "(I)" }    
    

    set path(in_delay)    [get_db $tp .launching_input_delay]        
    set path(out_delay)   [get_db $tp .external_delay]            
    set path(uncertainty) [get_db $tp .clock_uncertainty]            
    set path(cppr)        [get_db $tp .cppr_adjustment]                
    set path(required)    [get_db $tp .required_time]                    
    set path(delay)       [get_db $tp .path_delay]                    
    set path(slack)       [get_db $tp .slack]
    if { $path(slack) > 0 } { set meet "MET" } else { set meet "VIOLATED" }
    if { [get_db $tp .check_type] == "hold" }  { set path(type) "min" } else { set path(type) max }
        
    # Skew
    set path(skew) [expr $end(latency) + $end(src_l) - $start(latency) - $start(src_l) ]

    # Count cells    
    set pins     [get_db [get_db $tp .timing_points] .pin]
    set cells    [get_db [get_cells -quiet -of $pins] -if {!.is_latch==true && !.is_flop==true && !.is_sequential}]

    set path(logic_cells) [get_db [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}] .name]
    set path(buffs_cells) [get_db [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && !.is_combinational==true || .is_buffer==true || .is_inverter==true}] .name]
    set path(logic)   [llength $path(logic_cells)]
    set path(buffers) [llength $path(buffs_cells)]
    set path(power)	  [lsum [get_db $cells .power_total]]
    set path(area)    [lsum [get_db $cells .area]]
    if { [llength $cells] > 0 } { 
    set path(avg_power) [expr $path(power)/[llength $cells]] 
    set path(avg_area)  [expr $path(area)/[llength $cells]]
    } else { 
    set path(avg_power) 0 
    set path(avg_area)  0
    }
    
#
#       Output Delay:-    0.226
#        Uncertainty:-    0.013
#        Cppr Adjust:+    0.000
#      Required Time:=    0.360
#       Launch Clock:=    0.210
#          Data Path:+    0.252
#              Slack:=   -0.097
	set total_dist 0
    set total_cell_delay 0  
    set total_logic_delay 0
    set total_buff_delay 0
    set total_rc_delay   0
    set index 0
    set table {}
    array unset point_att_arr
    set timing_points [get_db $tp .timing_points]
    foreach point $timing_points {
        array set point_att_arr [ory_get_obj_dbs $point $index]
        set transition_type $point_att_arr($index:transition_type)        

        set current_pin $point_att_arr($index:pin)        
        set base_cell   "-"
        set delay "-"
        set slew "-"        
        set net_load "-"        
        set net ""
        set fanout "-"
        set inc "-"        
        set dist "-"
        
        if { $index > 0 } {
            # Get max delay
            set prev_pin    $point_att_arr([expr $index - 1]:pin)
#            set arc [get_arc -from $prev_pin -to $current_pin] 
#            set delay [lindex [get_db $arc .delay_${path(type)}_$transition_type] 0]

            
            # Get load
            set dir [get_db $current_pin .direction]
            if { $dir == "out" && [get_db $current_pin .obj_type] != "port" } {
                set cell      [get_db $current_pin .inst.name]
                set net       [get_nets -of $current_pin]
                set net_load  [get_db $net .capacitance_max]
                set fanout    [get_db $net .num_loads]
                set inc       [expr $point_att_arr($index:arrival) - $point_att_arr([expr $index -1]:arrival)]  
                
                set total_cell_delay [expr $total_cell_delay + $inc] 
                
                if {       [lsearch $path(buffs_cells) $cell] > -1 } {
                    set total_buff_delay [expr $total_buff_delay + $inc]
                } elseif { [lsearch $path(logic_cells) $cell] > -1 } {
                    set total_logic_delay [expr $total_logic_delay + $inc]                
                }
                                                             
            } else {
                # Calc dist
                set loc1 [split [string map {"\{" "" "\}" ""} [get_db $current_pin .location] ] " "]
                set loc2 [split [string map {"\{" "" "\}" ""} [get_db $prev_pin .location]    ] " "]
                set dist [expr abs([lindex $loc1 0] - [lindex $loc2 0]) + abs([lindex $loc1 1] - [lindex $loc2 1])]
                set total_dist [expr $total_dist + $dist]
                
                set slew $point_att_arr($index:slew)
                set delay       [expr $point_att_arr($index:arrival) - $point_att_arr([expr $index -1]:arrival)]
                set total_rc_delay [expr $total_rc_delay + $delay]
                                
                if { [get_db $point_att_arr($index:pin) .obj_type] != "port" } {
                    set base_cell   [get_db $point_att_arr($index:pin) .inst.base_cell.name]                                                
                    set vt_group    [ory_return_vt_group $base_cell]
                    lappend vt_groups_arr($vt_group) $base_cell           
                }     
            }
            #array set arcs_att_arr [ory_get_obj_dbs $arc [expr $index -1 ]]                        
        }
        set point_att_arr($index:net)       [get_db $net .name]
        set point_att_arr($index:net_load)  $net_load
        set point_att_arr($index:max_delay) $delay                        
        
        lappend table [list [string range [get_db $current_pin .name] end-180 end] $base_cell $transition_type $dist $slew $net_load $fanout $delay $inc $point_att_arr($index:arrival)]
        
        incr index
    }

    if { $path(logic) || $path(buffers) } { set avg_cell_delay [format "%.4f" [expr $total_cell_delay/($path(logic) + $path(buffers))]] } else { set avg_cell_delay NA}
    if { $path(logic)                   } { set avg_lgc_delay  [format "%.4f" [expr $total_logic_delay/$path(logic)]] } else { set avg_lgc_delay NA }
    if { $path(buffers)                 } { set avg_buf_delay  [format "%.4f" [expr $total_buff_delay/$path(buffers)]]} else { set avg_buf_delay NA }

    # Build path table
    set pre_table "
       View: $view
      Group: $group
 Startpoint: $start(point)
Start Clock: $start(clock)
   Endpoint: $end(point)
  End Clock: $end(clock)

                Capture       Launch
 Clock Edge:+    [format %.3f $end(edge)]        [format %.3f $start(edge)]
Src Latency:+    [format %.3f $end(src_l)]        [format %.3f $start(src_l)]
Net Latency:+    [format %.3f $end(latency)] $end(prp_clk)    [format %.3f $start(latency)] $start(prp_clk)
    Arrival:=    [format %.3f $end(arrival)]        [format %.3f $start(arrival)]

    "

    if { $path(in_delay) != "no_value" } {
    set post_table "
  Input Delay:-    $path(in_delay)"
    } elseif { $path(out_delay) != "no_value" } {
    append post_table "
 Output Delay:-    $path(out_delay)"    
    } 

    append post_table "
  Uncertainty       :-    $path(uncertainty)
  Cppr Adjust       :+    $path(cppr)       
Required Time       :=    $path(required)   
 Launch Clock       :=    $start(edge)
    Data Path       :+    $path(delay)      
        Slack       :=   $path(slack)                       

   Clock Skew       :=    $path(skew)        
         
        Logic       :=    $path(logic)                            
      Buf/Inv       :=    $path(buffers)  
      
Total Dist          :=    [format "%.2f" $total_dist]

Total RC   Delay    :=    [format "%.4f" $total_rc_delay]
Total Cell Delay    :=    [format "%.4f" $total_cell_delay]
Total Logic Delay   :=    [format "%.4f" $total_logic_delay]
Total Buf/Inv Delay :=    [format "%.4f" $total_buff_delay]
Avg Cell Delay      :=    $avg_cell_delay
Avg Logic Delay     :=    $avg_lgc_delay
Avg Buf/Inv Delay   :=    $avg_buf_delay 

Avg Cell Power      :=    [format "%.6f" $path(avg_power)]
Avg Cell Area       :=    [format "%.4f" $path(avg_area)]


"

    foreach vt_group [lsort [array names vt_groups_arr]] {
        append post_table "[format %-14s $vt_group]:=    [llength $vt_groups_arr($vt_group)] \n"
    }
    
    puts $pre_table
    
    set header [list Inst Base_cell "r/f" Dist Slew Load FO Delay Incr Arrival]
    set format "%s %s %s %-.2f %.3f %.3f %s %.3f %.3f %.3f %.3f"
    
    rls_table -table $table -format $format -header $header -spac -breaks
 
    puts $post_table    

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
    
    set cmd "ory_report_timing -max_path $opt(-max_paths) -nworst $opt(-nworst)"
    if { $opt(-group) != "" } {   append cmd " -group $opt(-group)"   }
    if { $opt(-from)  != "" } {   append cmd " -from $opt(-from)"   }
    if { $opt(-to)    != "" } {   append cmd " -to $opt(-to)"   }        

    puts "-I- Eval: $cmd"
    redirect _ory_tmp_report_timing.rpt { eval $cmd }
     
    puts "-I- Parsing"  
    set fp [open _ory_tmp_report_timing.rpt r]
    set fd [read $fp]
    close $fp
    
    set fd_clean [regsub -all "#+" $fd "#"]
    set fds      [split $fd_clean "#"]
    
    if { [llength $fds] < 2 } { 
        puts "-W- No timing path found"
        return
    }
    
    set table {}
    set id 1
    set final_detail_report ""
    foreach timing_path $fds {

        if { $timing_path == "" || ![regexp "Start Clock" $timing_path] } { continue }
        
        append final_detail_report "path id: $id"
        append final_detail_report $timing_path

        set group $id
        regexp  "Startpoint: (\[\\\{\\\}a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res sp
        regexp  "Endpoint: (\[\\\{\\\}a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res ep        
        regexp  "Start Clock: (\[a-zA-Z0-9_/\\\<\\\>\\\[\\\]\]+)" $timing_path res sp_clk        
        regexp  "End Clock: (\[a-zA-Z0-9_/\\\<\\\>\\\[\\\]\]+)" $timing_path res ep_clk                        
        regexp  "Group: (\[a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res group                                

        regexp  "Slack +:= +(\[\-.a-zA-Z0-9_/\\\<\\\>\\\{\\\}\\\[\\\]\]+)" $timing_path res slack                                        
        regexp  "Required Time +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res req_time                                        
        regexp  "Data Path +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res path_delay                                        
        regexp  "Logic +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res logic                                        
        regexp  "Buf/Inv +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res bufs                                        
        regexp  "Total Dist +:= +(\[.a-zA-Z0-9_/\\\[\\\]\]+)" $timing_path res dist   
        
        set line  [list $id $group $slack [expr $logic + $bufs] $logic $bufs $dist $sp_clk $sp $ep_clk $ep]
        lappend table $line

        incr id        
    
    }
    
    set header [list id group slack cells logic "buf/inv" dist start_clk startpoint end_clk endpoint]
    redirect -var summary_table { rls_table -table $table -header $header -breaks -spac }
    
    set output $opt(-output)
    if { $output == "" } { set output "ory_timing_summary.rpt" }
    
    redirect      $output { puts $summary_table }
    redirect -app $output { puts $final_detail_report }
    
    file delete _ory_tmp_report_timing.rpt
    
    puts "-I- Report: $output"

}



proc find_bad_skews { clock {max_paths 50000} {nworst 100}} {

    set tps [report_timing -from [get_clocks $clock] -to [get_clocks $clock] -max_p $max_paths -nworst $nworst -collection]
    set talbe {}
    
    foreach_in_collection tp $tps {
        
	    set view  [get_db $tp .view_name]
        set group [get_db $tp .path_group_name]    

        set start(point)   [get_db $tp .launching_point.name]
        set start(edge)    [get_db $tp .launching_clock_open_edge_time] 
        set start(r_f)     [get_db $tp .launching_clock_open_edge_type] 
        set start(latency) [get_db $tp .launching_clock_latency] 
        set start(clock)   [get_db $tp .launching_clock.base_name] 
        set start(src_l)   [get_db $tp .launching_clock.source_latency_late_${start(r_f)}_max]  ; # source latency
        if { $start(src_l) == "no_value" } { set start(src_l) 0 }
        set start(arrival) [expr $start(edge) + $start(latency) + $start(src_l)]
        if { [get_db $tp .launching_clock_is_propagated] } { set start(prp_clk) "(P)" } else { set start(prp_clk) "(I)" }

        set end(point)     [list [get_db $tp .capturing_point.name] ]
        set end(edge)      [get_db $tp .capturing_clock_close_edge_time] 
        set end(r_f)       [get_db $tp .capturing_clock_close_edge_type] 
        set end(latency)   [get_db $tp .capturing_clock_latency] 
        set end(clock)     [get_db $tp .capturing_clock.base_name]        
        set end(src_l)   [get_db $tp .launching_clock.source_latency_late_${end(r_f)}_max] ; # source latency
        if { $end(src_l) == "no_value" } { set end(src_l) 0 }
        set end(arrival)   [expr $end(edge) + $end(latency) + $end(src_l)]
        if { [get_db $tp .capturing_clock_is_propagated] } { set end(prp_clk) "(P)" } else { set end(prp_clk) "(I)" }    


        set path(in_delay)    [get_db $tp .launching_input_delay]        
        set path(out_delay)   [get_db $tp .external_delay]            
        set path(uncertainty) [get_db $tp .clock_uncertainty]            
        set path(cppr)        [get_db $tp .cppr_adjustment]                
        set path(required)    [get_db $tp .required_time]                    
        set path(delay)       [get_db $tp .path_delay]                    
        set path(slack)       [get_db $tp .slack]
        if { $path(slack) > 0 } { set meet "MET" } else { set meet "VIOLATED" }
        if { [get_db $tp .check_type] == "hold" }  { set path(type) "min" } else { set path(type) max }

        # Skew
        set start(ID)  [expr $start(latency) + $start(src_l)]
        set end(ID)    [expr $end(latency) + $end(src_l)]
        set path(skew) [expr abs($end(ID) - $start(ID))]

        # Count cells    
        set pins     [get_db [get_db $tp .timing_points] .pin]
        set cells    [get_db [get_cells -quiet -of $pins] -if {!.is_latch==true && !.is_flop==true && !.is_sequential}]

        set path(logic)   [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]]
        set path(buffers) [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && !.is_combinational==true || .is_buffer==true || .is_inverter==true}]]
        
        lappend table [list $path(skew) $path(slack) $start(clock) $start(ID) $end(clock) $end(ID) $start(point) $end(point) ]
    }   
    
    set sorted_table [lsort -index 0 -real -dec $table]
    
    set header [list Skew Slack Start_clock ID End_Clock ID Start End]
    rls_table -table $sorted_table -header $header -spac -breaks

}


proc ory_calc_net_length { {nets {}} } {
    
    if { $nets == {} } { 
        set routed_nets [get_db nets -if { ! .wires=="" } ] 
    } else { 
        set routed_nets [get_nets -quiet [get_db $nets -if { ! .wires=="" }]]
        set not_routed  [remove_from_collection [get_nets -quiet $nets] $routed_nets]        
    }
    
    redirect /dev/null {
    define_attribute be_net_length -category be_user_attributes -data_type double  -obj_type net -default -1
    define_attribute be_detailed_net_length -category be_user_attributes -data_type string  -obj_type net    
    define_attribute be_sorted_detailed_net_length -category be_user_attributes -data_type string  -obj_type net    
    }
    
    set_db $nets .be_net_length 0
    set_db $nets .be_detailed_net_length ""
    set_db $nets .be_sorted_detailed_net_length ""
      
    
    set total [llength $routed_nets]
    set current 0
    
    foreach net [get_db $routed_nets] {
        array unset net_length_arr

        ory_progres $current $total
        incr current 
        
        if { [llength [set wires [get_db $net .wires]]] == 0 } { set_db $net .be_net_length 0 ; continue }
        
        set total_length 0
        set detailed_length ""
        foreach layer [lsort -u [get_db $net .wires.layer.name]] { set net_length_arr($layer) 0 }
        
        foreach wire $wires {
            set layer  [get_db $wire .layer.name]
            set length [get_db $wire .length]
            set net_length_arr($layer) [expr $net_length_arr($layer) + $length]
            set total_length           [expr $total_length + $length]
        }
        
        foreach layer [array names net_length_arr] { append detailed_length "{ $layer $net_length_arr($layer) } " }
        
        set_db $net .be_net_length          $total_length
        set_db $net .be_detailed_net_length [lsort -index 1 -real -dec $detailed_length]
        set sorted {}
        foreach m {M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 M17} {        
            if { [set index [lsearch $detailed_length " $m *"] ] < 0 } { lappend sorted [list $m 0.00 ] } { lappend sorted [lindex $detailed_length $index]}
        }
        set_db $net .be_sorted_detailed_net_length $sorted
        
    }
    puts ""
    
}

proc ory_get_long_nets { {th 400} {nets ""} } {

    if { [llength [get_db attributes *be_net_length]] == 0 } {
        puts "-I- Calculating net length"
        ory_calc_net_length
    }

    if { $th == -1 } {
        if { $nets != "" } { 
            set long_nets [get_db $nets -if {.be_net_length==$th}]
        } else {    
            set long_nets [get_db nets -if {.be_net_length==$th}]
        }    
    } else {
        if { $nets != "" } { 
            set long_nets [get_db $nets -if {.be_net_length>$th}]
        } else {    
            set long_nets [get_db nets -if {.be_net_length>$th}]
        }
    }
    
#     t $long_nets dr_length dont_touch physical_status
    set data {}
    foreach net $long_nets {
        
        set line [list [get_db $net .name] [get_db $net .be_net_length] [get_db $net .dont_touch] [get_db $net .use]  ]        
        lappend data $line
    
    }
    set sorted_data [lsort -index 1 -real -decre $data]
    rls_table -breaks -table $sorted_data -spacious -header [list Net be_net_length dont_touch use ]
    
#     return $long_nets

}


proc ory_nets_area { {nets ""} } {

    if { $nets == "" } {
        set nets   [get_db nets]
    } else { 
        set nets   [get_db $nets]
    }
	#    set wires  [concat [get_db $nets .wires] [get_db $nets .special_wires]]
    set wires  [get_db $nets .wires] 
    set layers [lsort -u [get_db $wires .layer.name]]

    array unset area_arr

    foreach layer $layers {

        puts "-I- Layer: $layer"

        set area 0    
        set lwires    [get_db $wires -if .layer.name==$layer]
        set begin_ext [get_db $lwires .begin_extension]
        set end_ext   [get_db $lwires .end_extension]        
        set length    [get_db $lwires .length]   
        set width     [get_db $lwires .width]                        

        set curr  0
        set total [llength $width]
        
        foreach be $begin_ext ee $end_ext l $length w $width {
            incr curr  
            ory_progress $curr $total
            set area [expr $area + $w * ($be + $l + $ee)]
         
        }

        set total_length [lsum [concat $begin_ext $end_ext $length]]
        set area_arr([string trim $layer "M"]) [list $layer [llength [lsort -u [get_db $lwires .net]]] $area $total_length $total]

        puts ""        
    }
    
    set table {}
    foreach l [lsort -real -inc [array names area_arr]] {
        lappend table $area_arr($l)
    }
    
    rls_table -table $table -header [list Layer "#ofNets" Area Length "#ofShapes"] -spac -breaks

}

proc ory_supply_nets_area { } {

    set nets   [get_db nets -if .use==power||.use==ground]

    set wires  [get_db $nets .special_wires]
    set layers [lsort -u [get_db $wires .layer.route_index]]

    array unset area_arr
    foreach layer $layers {
        set areas [get_db [get_db $wires -if .layer.route_index==$layer] .area]
        set area_arr($layer) [lsum $areas]
    }
    
    return [array get area_arr]

}

proc ory_track_info { } {

    set tracks       [get_db [get_db track_patterns ]  -if .layers.name==M*]

    array unset track_arr
    array unset step_arr 
    array unset start_arr
    
    foreach track $tracks {

        set layer     [get_db $track .layers.name]
        set layer_num [get_db $track .layers.route_index]
        set dir       [get_db $track .direction]
        
        if { ( [expr $layer_num % 2] == 0 && $dir == "x" ) || ( [expr $layer_num % 2] == 1 && $dir == "y" ) } {
            
            lappend track_arr($layer_num) [get_db $track .num_tracks]
            lappend step_arr($layer_num)  [get_db $track .step]
            lappend start_arr($layer_num) [get_db $track .start]            

        }
    }
    
    array set net_area_arr [ory_supply_nets_area]
    set core_bbox [split [string range [get_db designs .io_bbox] 1 end-1] " "]
    set core_x    [expr [lindex $core_bbox 2] - [lindex $core_bbox 0]]
    set core_y    [expr [lindex $core_bbox 3] - [lindex $core_bbox 1]]    
    
    set table_h {}
    set table_v {}
    foreach layer [lsort -inc -real [array names track_arr]] {

        set number [lsum $track_arr($layer)]
        if { [info exists net_area_arr($layer)] } { set net_area $net_area_arr($layer) } else { set net_area 0 }

        if { [expr $layer % 2] == 0 } { 
            set track_per_um [format "%.2f" [expr $number / $core_x]]
            set supp_per_um  [format "%.2f" [expr $net_area / $core_x]]
            lappend table_v  [list "M[expr $layer-1]" $number $track_per_um [lindex [lsort -inc $start_arr($layer)] 0] [lsort -u $step_arr($layer)] [format "%.2f" $net_area] $supp_per_um]            
        } else {
            set track_per_um [format "%.2f" [expr $number / $core_y]]
            set supp_per_um  [format "%.2f" [expr $net_area / $core_y]]
            lappend table_h  [list "M[expr $layer-1]" $number $track_per_um [lindex [lsort -inc $start_arr($layer)] 0] [lsort -u $step_arr($layer)] [format "%.2f" $net_area] $supp_per_um]            
        } 
    }
    
    puts "-I- Block BBox: $core_bbox\n"
    
    set header [list "Layer" "Total_Track_num" "Tracks/um" "Start" "Step" "Supp_Net_Area" "Supp_area/um"]
    rls_table -table $table_h -header $header -spac -breaks
    puts ""
    rls_table -table $table_v -header $header -spac -breaks    

}



proc ory_get_pins_latency { pin_name } {

    set tp       [report_timing -through $pin_name -collection -uncon]
    set points   [get_db $tp .timing_points]
    
    set start_point [lindex $points 0]
    set my_point    [get_db $points -if .pin.name==$pin_name]
    
    return [expr [get_db $my_point .arrival] - [get_db $start_point .arrival]]
}

proc ory_calc_pins_skew_and_latency { pins } {
    
    set table {}  

    array unset pins_late_arr
    set max_late 0
    set min_late 9999
    set total_late 0
    foreach pin [lsort $pins] {
    
        set pin_name [get_db $pin .name]
        set pin_late [ory_get_pins_latency $pin_name]
        set pin_late_arr($pin_name) $pin_late   
        
        if { $min_late > $pin_late } { set min_late $pin_late }
        if { $max_late < $pin_late } { set max_late $pin_late }                
        set total_late [expr $total_late + $pin_late]
        lappend table [list $pin_name $pin_late]
    }
    
    set avg_late [format "%.3f" [expr $total_late / [llength $pins]]]
        
    rls_table -table $table -break -spac -header [list pin_name latency]
    
    puts "Max_skew       : [format "%.3f" [expr $max_late - $min_late]]"
    puts "Average latency: $avg_late"
}

proc ory_calc_dist_to_rcvs { drv } {
# Calc Manhaten distnace from drv pin to each rcv pin    
    set drv [get_pins $drv]
    
    set drv_loc  [split [lindex [get_db $drv .location] 0] " "]
    set drv_name [get_db $drv .name]
    
    set rcvs       [get_db [all_connected -leaf [get_nets -of $drv]] -if !.name==$drv_name]
    
    set table {}    
    foreach rcv $rcvs {
        set rcv_loc  [split [lindex [get_db $rcv .location] 0] " "]
        set dist     [expr abs([lindex $drv_loc 0] - [lindex $rcv_loc 0]) + abs([lindex $drv_loc 1] - [lindex $rcv_loc 1]) ]
        lappend table [list [get_db $rcv .name] $dist $rcv_loc]
    }
    
    puts "Driver: $drv_name, $drv_loc"
    set header [list "Receiver" "Distance_from_drv" "Location"]
    rls_table -table $table -header $header -breaks -spac 
}


proc ory_copy_inst { inst_name {new_inst_name ""} } {
# Duplicate inst + all input connections
# Place at the original cell's place

    set inst [get_db insts $inst_name]

    if { $new_inst_name == "" } { set new_inst_name "${inst_name}_ory_copy" }
        
    set base_cell     [get_db $inst .base_cell.name]
    set pins          [get_db [get_db $inst .pins] -if .direction==in]
    
    create_inst -cell $base_cell -inst $new_inst_name  
    move_obj -point [lindex [get_db [get_db $inst] .location] 0] [get_db insts $new_inst_name ]
    
    foreach pin $pins {
        set net           [get_db [get_nets -of $pin] .name]
        set pin_base_name [get_db $pin .base_name]
        
        connect_pin -inst $new_inst_name -pin $pin_base_name -net $net
    }

    return [get_db insts $new_inst_name]    

}

proc ory_insert_guide_buffers { drv_name } {
# Insert and places buffers for preroute

    set erp_prev_state   [get_db eco_refine_place]
    set eut_prev_state   [get_db eco_update_timing]
    set ehdt_prev_state  [get_db eco_honor_dont_touch]

    set_db eco_refine_place false
    set_db eco_update_timing false
    set_db eco_honor_dont_touch false
    
    set drv  [get_db pins $drv_name]
    set rcvs [get_db [all_connected -leaf [get_nets -of $drv]] -if !.name==$drv_name]
    
    set drv_location [split [lindex [get_db $drv .location] 0] " "]
    lassign $drv_location drv_x drv_y
    
    set index 0
    foreach rcv $rcvs {
        set rcv_location [split [lindex [get_db $rcv .location] 0] " "]
        lassign $rcv_location rcv_x rcv_y  
        set x_dist [expr $drv_x - $rcv_x]
        set y_dist [expr $drv_y - $rcv_y]
        
        # Determine direction of rcv relative to drv
        if { $x_dist < 0 && $y_dist < 0 } { set direction top_right ; set axis "x" ; set y_dist 0 }
        if { $x_dist < 0 && $y_dist > 0 } { set direction bot_right ; set axis "y" ; set x_dist 0 }
        if { $x_dist > 0 && $y_dist < 0 } { set direction top_left  ; set axis "y" ; set x_dist 0 }
        if { $x_dist > 0 && $y_dist > 0 } { set direction bot_left  ; set axis "x" ; set y_dist 0 }       
        
        set new_buf_location [list [expr $drv_x - $x_dist] [expr $drv_y - $y_dist]]
        set new_buf_name     "[get_db [get_db $drv .inst] .base_name]_guide_buffer_$index"
        
        eco_add_repeater -cells    DCCKBD4BWP240H11P57PDULVT -name $new_buf_name -new_net_name ${new_buf_name}_net \
                         -location $new_buf_location         -pins [get_db $rcv .name]
        
        incr index        
    }

    set_db eco_refine_place     $erp_prev_state
    set_db eco_update_timing    $eut_prev_state
    set_db eco_honor_dont_touch $ehdt_prev_state
    
    return [get_db insts [get_db [get_db $drv .inst] .base_name]_guide_buffer* ]
 
}

proc ory_remove_guide_buffers { {drv_name ""} } {

    set erp_prev_state   [get_db eco_refine_place]
    set eut_prev_state   [get_db eco_update_timing]
    set ehdt_prev_state  [get_db eco_honor_dont_touch]

    set_db eco_refine_place false
    set_db eco_update_timing false
    set_db eco_honor_dont_touch false

    
    set pattern "*_guide_buffer*"
    if { $drv_name != "" } { set pattern "[get_db [get_db $drv .inst] .base_name]_guide_buffer*" }
    
    set buffers [get_db [get_db insts $pattern] .name]
    
    eco_delete_repeater -insts $buffers
    
    set_db eco_refine_place     $erp_prev_state
    set_db eco_update_timing    $eut_prev_state
    set_db eco_honor_dont_touch $ehdt_prev_state
    
}




proc ory_measure_cell_delay {} {

    if { [llength [get_db attributes */be_cell_delay]] == 0 } {        define_attribute -category be_user_attributes -obj_type inst      -data_type double  -default 999    be_cell_delay   }
    if { [llength [get_db attributes */avg_worst_cell_delay]] == 0 } { define_attribute -category be_user_attributes -obj_type base_cell -data_type double  -default 999    avg_worst_cell_delay  }
    if { [llength [get_db attributes */avg_best_cell_delay]] == 0  } { define_attribute -category be_user_attributes -obj_type base_cell -data_type double  -default 999    avg_best_cell_delay  }    


    set cells  [get_db insts -if .is_black_box==false]
    array unset worst_cell_delay_arr
    array unset best_cell_delay_arr    
    set prog 1
    set total [llength $cells]

    foreach cell $cells {

    	
        ory_progress $prog $total
        incr prog
        
        set out_pins [get_db $cell .pins -if .direction==out]
        set arcs     [get_db $cell .arcs]
        set delays {}        
        foreach out $out_pins {
            
            set delays [concat $delays [concat [get_db [get_db $arcs -if .to_pin==$out] .delay_max_fall] [get_db [get_db $arcs -if .to_pin==$out] .delay_max_rise]]]
                        

        }
        set delays [lminus $delays "no_value"]

        if { $delays != {} } {
            set sorted_list [lsort -dec $delays]
            set worst_cell_delay_arr([get_db $cell .name]) [lindex $sorted_list 0]
            set best_cell_delay_arr([get_db $cell .name])  [lindex $sorted_list end]            
            set_db -quiet [get_db insts $cell] .be_cell_delay [expr [lsum $sorted_list]/[llength $sorted_list]]
        }

    }
    
    array unset worst_base_cells_arr
    array unset best_base_cells_arr    
    foreach cell [array names worst_cell_delay_arr] {
    
        set bc [get_db [get_db insts $cell] .base_cell.name]
        lappend worst_base_cells_arr($bc) $worst_cell_delay_arr($cell)
        lappend best_base_cells_arr($bc)  $best_cell_delay_arr($cell)        
    
    }
    
    foreach bc [array names worst_base_cells_arr] {
        set total_delay [lsum $worst_base_cells_arr($bc)]
        set count       [llength $worst_base_cells_arr($bc)]
        set avg_delay   [expr $total_delay/$count]
        
        set_db -quiet [get_db base_cells $bc] .avg_worst_cell_delay $avg_delay
        
        set total_delay [lsum $best_base_cells_arr($bc)]
        set avg_delay   [expr $total_delay/$count]
        
        set_db -quiet [get_db base_cells $bc] .avg_best_cell_delay $avg_delay        
    }   
        
    puts ""

}

proc copy_pins { b1 b2 direction b1_offset map_list {write_tcl "false"} } {
    # HELP - place b1 pins IN b2 in the same order
    puts "-I- Start pin alignment for $b1 - $b2. [::ory_time::now]"
    
    set b1_bc [get_db [get_cells $b1] .base_cell.name]
    set b2_bc [get_db [get_cells $b2] .base_cell.name]
    
    set b1_index [join [regexp -inline -all "\[0-9\]" $b1] "_"]
    set b2_index [join [regexp -inline -all "\[0-9\]" $b2] "_"]    
    
    set b1_loc  [lindex [get_db [get_cells $b1  ] .location] 0]
    set b2_loc  [lindex [get_db [get_cells $b2  ] .location] 0]

    set b1_bbox [lindex [get_db [get_cells $b1] .bbox] 0]
    set b2_bbox [lindex [get_db [get_cells $b2] .bbox] 0]


    array set map_arr $map_list
parray map_arr
    set_db assign_pins_edit_in_batch true        
    
    foreach b1_pattern [array names map_arr] {

        set b2_pattern $map_arr($b1_pattern)
        puts "-I- Aligning $b1_pattern in BLOCK:$b1 and $b2_pattern in BLOCK:$b2"        
        
        set b1_pins [get_db pins $b1/$b1_pattern*]
        
        foreach b1_pin $b1_pins {

            set b2_pin [get_db [regsub $b1 [regsub $b1_pattern $b1_pin $b2_pattern] $b2]]

            set x1 [expr [get_db $b1_pin .location.x] -  [get_db $b1_pin .inst.bbox.ll.x]]
            set y1 [expr [get_db $b1_pin .location.y] -  [get_db $b1_pin .inst.bbox.ll.y]]
            set layer [get_db $b1_pin .layer.name]    


            if { $direction == "V" || $direction == "v" } {
                set b2_location [list [expr $x1 + $offset] $y1]
            } elseif { $direction == "H" || $direction == "h" } {
                set b2_location [list $x1 [expr $y1 + $b1_offset]]
            }        



            if { [get_db $b1_pin .obj_type] == "port" } {
                set edit_pin_cmd "edit_pin -snap  track  -fix_overlap  1  -pin  [get_db $b2_pin .base_name] -layer $layer -assign  \" [join $b2_location " "] \""
            } else {
                set edit_pin_cmd "edit_pin -hinst $b2 -snap  track  -fix_overlap  1  -pin  [get_db $b2_pin .base_name] -layer $layer -assign  \" [join $b2_location " "] \""        
            }
            set line "if { \[catch { $edit_pin_cmd } res \] } { puts \"-E- Unable to place $b2_pin AND $b1_pin\" }\n"
            puts $line
            echo "[get_db $b1_pin .base_name] --- [get_db $b2_pin .base_name] ---  $x1 $y1 -- [lindex [get_db $b2_pin .location]]" >> debug_mirror_b2b.rpt
            eval $line    

            if { $write_tcl != "false" } {
                set edit_pin_cmd "if \{ \[sizeof \[get_pins -quiet [get_db $b2_pin .base_name]\]\] != 0 \} \{ edit_pin -fixed -pin  [get_db $b2_pin .base_name] -layer $layer   -assign  \" [join $b2_location " "] \" \}"
                puts $fp  $edit_pin_cmd
                if { [get_db $b1_pin .obj_type] == "pin" } { continue }
                set b2_cell [get_db [get_cell -of $b1_pin] .name]
                set edit_pin_cmd "if \{ \[sizeof \[get_pins -quiet $b2/[get_db $b2_pin .base_name]\]\] != 0 \} \{ edit_pin -fixed -hinst $b2_cell -pin  [get_db $b2_pin .base_name] -layer $layer   -assign  \" [join $b2_location " "] \" \}"
                puts $fp2 $edit_pin_cmd                
            }

            ### Compare actual vs assigned placement ###
            set b2_pin_actual_loc [lindex [get_db $b2_pin .location]  0]
            set key "[get_db $b1_pin .base_name]:[get_db $b2_pin .base_name]"

            if { $direction == "V" || $direction == "v" } {
                set pin_pairs_arr($key) [format "%.4f" [expr $x1 +  [get_db $b1_pin .inst.bbox.ll.x] - [lindex $b2_pin_actual_loc 0]]]
            } else {
                set pin_pairs_arr($key) [format "%.4f" [expr $y1 +  [get_db $b1_pin .inst.bbox.ll.y] - [lindex $b2_pin_actual_loc 1]]]
            }

        }    
        
    }
    set_db assign_pins_edit_in_batch false        


    
    if { $write_tcl != "false" } { 
        puts $fp "set_db assign_pins_edit_in_batch false"    
        close $fp
        puts $fp2 "set_db assign_pins_edit_in_batch false"    
        close $fp2        
    }
    
 
#    append cmds "set_db assign_pins_edit_in_batch false\n"       
    set_db assign_pins_edit_in_batch false
    echo "-I- Missaligned ports:" > reports/${b1}_${b2}_missaligned_ports.rpt
    set index0 0
    set index1 0
    foreach name [array names pin_pairs_arr] {
        incr index0
        if { $pin_pairs_arr($name) != 0 } {
            incr index1
            lassign [split $name ":"] p1 p2
            puts "-W- $p1 and $p2 are not aligned"
            echo "$p1 $p2" >> reports/${b1}_${b2}_missaligned_ports.rpt                     
        }        
    }
    puts "-I- Out of $index0 tested, $index1 not aligned"
    puts "-I- End pin alignment for $b1 - $b2. [::ory_time::now]"        
    
}

proc quick_spread_pins { b1 b2 direction {pattern ""} } {
    # HELP - "reset" b2 pins which are common with b1
    puts "-I- Start spreading $b1 - $b2. [::ory_time::now]"
    
    set b1_bc [get_db [get_cells $b1] .base_cell.name]
    set b2_bc [get_db [get_cells $b2] .base_cell.name]
    
    set b1_index [join [regexp -inline -all "\[0-9\]" $b1] "_"]
    set b2_index [join [regexp -inline -all "\[0-9\]" $b2] "_"]    
    
    set b1_loc  [lindex [get_db [get_cells $b1  ] .location] 0]
    set b2_loc  [lindex [get_db [get_cells $b2  ] .location] 0]

    set b1_bbox [lindex [get_db [get_cells $b1] .bbox] 0]
    set b2_bbox [lindex [get_db [get_cells $b2] .bbox] 0]

    if { $direction == "V" || $direction == "v" } {

        set offset [lindex $b2_loc 0]
        set low    [lindex $b2_bbox 1]
        set high   [lindex $b2_bbox 3] 
        set min    [lindex $b2_bbox 0]
        set max    [lindex $b2_bbox 2]               
        if { [lindex $b1_loc 1] < $low } { set side 0 } else { set side [expr $high - $low] }
        set line [list 0 $side [expr $max - $min] $side]
        set layers {M1 M3}

    } elseif { $direction == "H" || $direction == "h" } {
        set offset [lindex $b2_loc 1]
        set min    [lindex $b2_bbox 1]
        set max    [lindex $b2_bbox 3]         
        set low    [lindex $b2_bbox 0]
        set high   [lindex $b2_bbox 2]                
        if { [lindex $b1_loc 0] < $low } { set side 0 } else { set side [expr $high - $low] }
        set line [list $side 0 $side [expr $max - $min]]
        set layers {M2 M4}

    } else {
        puts "-E- direction must be h/H or v/V!" ; return -1 
    }


    set b1_pins [get_db [get_db insts $b1] .pins]
    set b2_pins [get_db [get_db insts $b2] .pins]    

    set b1_nets [get_nets [get_db $b1_pins .net]]
    set b2_nets [get_nets [get_db $b2_pins .net]]
    set common_nets [get_db [common_collection $b1_nets $b2_nets] -if .num_connections==2]
    
    if { $pattern == "" } {
        set common_b2_pins [get_db [common_collection [get_pins $b2_pins] [get_pins -of $common_nets]]]    
    } else {
        set common_b2_pins [get_db [filter_collection [common_collection [get_pins $b2_pins] [get_pins -of $common_nets]] full_name=~$pattern ] ]
    }
    puts "-I- Moving [llength  $common_b2_pins] b2_pins to new temp location"        
    quick_place_pins $b2 $common_b2_pins $line $direction $layers

}

proc get_p2p_pins { b1 b2 } {
    set b1_pins [get_db [get_db insts $b1] .pins]
    set b2_pins [get_db [get_db insts $b2] .pins]    

    set b1_nets [get_nets [get_db $b1_pins .net]]
    set b2_nets [get_nets [get_db $b2_pins .net]]
    set common_nets [get_db [common_collection $b1_nets $b2_nets] -if .num_connections==2]

    set p2p_nets {}
    foreach_in_collection net [get_nets $common_nets] {

        if { ![llength [set drv [get_db $net .driver_pins]]] } { set drv [get_db $net .driver_ports] }
        if { ![llength [set rcv [get_db $net .load_pins  ]]] } { set rcv [get_db $net .load_ports] }

        if { [llength [concat $drv $rcv]] > 2 } { puts "-W- Net [get_db $net .name] has multiple receivers or noe drv/rcv" ; continue }

        append_to_collection p2p_nets $net            
    }
    
    return [common_collection [get_pins $b1_pins] [get_pins -of $p2p_nets]]
}

proc align_pins_b2b { b1 b2 direction {write_tcl false} {dir ""} } {
    
    puts "-I- Start pin alignment for $b1 - $b2. [::ory_time::now]"
    
    if { $dir == "" } { set dir "out/tcl_files" }
    
    set b1_bc [get_db [get_cells $b1] .base_cell.name]
    set b2_bc [get_db [get_cells $b2] .base_cell.name]
    
    set b1_index [join [regexp -inline -all "\[0-9\]" $b1] "_"]
    set b2_index [join [regexp -inline -all "\[0-9\]" $b2] "_"]    
    
    set b1_loc  [lindex [get_db [get_cells $b1  ] .location] 0]
    set b2_loc  [lindex [get_db [get_cells $b2  ] .location] 0]

    set b1_bbox [lindex [get_db [get_cells $b1] .bbox] 0]
    set b2_bbox [lindex [get_db [get_cells $b2] .bbox] 0]

    if { $direction == "V" || $direction == "v" } {

        set offset [lindex $b2_loc 0]
        set low    [lindex $b2_bbox 1]
        set high   [lindex $b2_bbox 3] 
        set min    [lindex $b2_bbox 0]
        set max    [lindex $b2_bbox 2]               
        if { [lindex $b1_loc 1] < $low } { set side 0 } else { set side [expr $high - $low] }
        set line [list 0 $side [expr $max - $min] $side]
        set layers {M1 M3}

    } elseif { $direction == "H" || $direction == "h" } {
        set offset [lindex $b2_loc 1]
        set min    [lindex $b2_bbox 1]
        set max    [lindex $b2_bbox 3]         
        set low    [lindex $b2_bbox 0]
        set high   [lindex $b2_bbox 2]                
        if { [lindex $b1_loc 0] < $low } { set side 0 } else { set side [expr $high - $low] }
        set line [list $side 0 $side [expr $max - $min]]
        set layers {M2 M4}

    } else {
        puts "-E- direction must be h/H or v/V!" ; return -1 
    }


    set b1_pins [get_db [get_db [get_db insts $b1] .pins] -if .base_name!=*TEST*]
    set b2_pins [get_db [get_db [get_db insts $b2] .pins] -if .base_name!=*TEST*]    

    set b1_nets [get_nets [get_db $b1_pins .net]]
    set b2_nets [get_nets [get_db $b2_pins .net]]
    set common_nets [get_db [common_collection $b1_nets $b2_nets] -if .num_connections==2]
    
    set common_b2_pins [get_db [common_collection [get_pins $b2_pins] [get_pins -of $common_nets]]]
#    puts "-I- Moving [llength  $common_b2_pins] b2_pins to new temp location"        
#    quick_place_pins $b2 $common_b2_pins $line $direction $layers

    array unset unplaced_arr 
    set unplaced_arr(na) "NA"
    array unset pin_pairs_arr 
    array unset pin_loc_arr
#    set cmds "set_db assign_pins_edit_in_batch true\n"   

    if { $write_tcl != "false" } {         
        exec mkdir -pv $dir
        set fp  [open $dir/${b1_bc}_${b1_index}_to_${b2_bc}_${b2_index}_${direction}_port_placement.tcl w]
        set fp2 [open $dir/${b1_bc}_${b1_index}_to_${b2_bc}_${b2_index}_${direction}_quad_port_placement.tcl w]        
        puts $fp  "set_db assign_pins_edit_in_batch true"
        puts $fp2 "set_db assign_pins_edit_in_batch true"        
    }    
    set_db assign_pins_edit_in_batch true
    set eval_res ""
    foreach net $common_nets {

        set dont_place false
        
	    set pins   [all_connected -leaf $net]
        set b1_pin [get_db $pins -if .name==*$b1/*]
        set b2_pin [get_db $pins -if .name==*$b2/*]      
        
        set b1_pin_loc [lindex [get_db $b1_pin .location]  0]
        lassign $b1_pin_loc x1 y1
        
        if { $direction == "V" || $direction == "v" } {
            if { $x1 < $min || $x1 > $max } { set unplaced_arr($b1_pin) "matching_pin_out_of_block_boundary" ; set dont_place true}
            set b2_pin_loc [list [expr $x1 - $offset] $side]            
        } elseif { $direction == "H" || $direction == "h" } {
            if { $y1 < $min || $y1 > $max } { set unplaced_arr($b1_pin) "matching_pin_out_of_block_boundary" ; set dont_place true}        
            set b2_pin_loc [list $side [expr $y1 - $offset]]
        }    
        
        set b2_pin_layer [get_db $b1_pin .layer.name]
        
        if { !$dont_place } {
            set edit_pin_cmd "edit_pin -hinst $b2 -pin  [get_db $b2_pin .base_name] -layer $b2_pin_layer   -assign  \" [join $b2_pin_loc " "] \""
            set line "if { \[catch { $edit_pin_cmd } res \] } { puts \"-E- Unable to place $b1_pin AND $b2_pin\" }\n"
    #        puts $line
            redirect -app -stderr -var eval_res { eval $line }
            
            if { $write_tcl != "false" } {
                set edit_pin_cmd "if \{ \[sizeof \[get_ports -quiet [get_db $b2_pin .base_name]\]\] != 0 \} \{ edit_pin -fixed -pin  [get_db $b2_pin .base_name] -layer $b2_pin_layer   -assign  \" [join $b2_pin_loc " "] \" \}"
                puts $fp  $edit_pin_cmd
                set edit_pin_cmd "if \{ \[sizeof \[get_pins -quiet $b2/[get_db $b2_pin .base_name]\]\] != 0 \} \{ edit_pin -fixed -hinst $b2 -pin  [get_db $b2_pin .base_name] -layer $b2_pin_layer   -assign  \" [join $b2_pin_loc " "] \" \}"
                puts $fp2 $edit_pin_cmd                
            }
            set pin_loc_arr([get_db $b2_pin .base_name]) $b2_pin_loc
        }
        
        ### Compare actual vs assigned placement ###
        set b2_pin_actual_loc [lindex [get_db $b2_pin .location]  0]
        set key "[get_db $b1_pin .base_name]:[get_db $b2_pin .base_name]"
        
        if { $direction == "V" || $direction == "v" } {
            set pin_pairs_arr($key) [expr [lindex $b1_pin_loc 0] - [lindex $b2_pin_actual_loc 0]]
        } else {
            set pin_pairs_arr($key) [expr [lindex $b1_pin_loc 1] - [lindex $b2_pin_actual_loc 1]]        
        }
       
    }

    if { [regexp "ERROR" $eval_res] } { 
        puts "-E- Errors founs dureing command eval\n-E- See reports/eval_errors.rpt for more details" 
        set fpe [open reports/eval_errors.rpt w]
        puts $eval_res $fpe
        close $fpe
    }        
    
    if { $write_tcl != "false" } { 
        puts $fp "set_db assign_pins_edit_in_batch false"    
        puts $fp2 "set_db assign_pins_edit_in_batch false"    
    }
    
    redirect reports/${b1}_${b2}_unplaced.rpt {parray unplaced_arr}
    
#    append cmds "set_db assign_pins_edit_in_batch false\n"       
    set_db assign_pins_edit_in_batch false
    echo "-I- Missaligned ports:" > reports/${b1}_${b2}_missaligned_ports.rpt
    set index0 0
    set index1 0
    foreach name [array names pin_pairs_arr] {
        incr index0
        if { $pin_pairs_arr($name) != 0 } {
            incr index1
            lassign [split $name ":"] p1 p2
#            puts "-W- $p1 and $p2 are not aligned"
            echo "$p1 $p2" >> reports/${b1}_${b2}_missaligned_ports.rpt 
        }        
    }
    puts "-I- Out of $index0 tested, $index1 not aligned"
    puts "-I- End pin alignment for $b1 - $b2. [::ory_time::now]"  
    puts "-I- Check : reports/${b1}_${b2}_missaligned_ports.rpt"
    puts "-I- Tcl in: $dir/${b1_bc}_${b1_index}_to_${b2_bc}_${b2_index}_${direction}_port_placement.tcl"
    
    if { $write_tcl != "false" } {
        
        if { [array exists pin_loc_arr] } {
            puts $fp "array unset pin_loc_arr"
            foreach pin [array names pin_loc_arr] {
            
                puts $fp "set pin_loc_arr($pin) \{$pin_loc_arr($pin)\}"
            
            }
            puts $fp "set count 0 ; set plist {} ; set fp \[open not_in_place_ports.rpt w\]"
            puts $fp "foreach pin \[array names pin_loc_arr\] \{"
            puts $fp "    set td_loc  \$pin_loc_arr(\$pin)"
            puts $fp "    lassign \$td_loc tdx tdy"
            puts $fp "    set act_loc \[lindex \[get_db \[get_ports -quiet \$pin\] .location\] 0\]"
            puts $fp "    lassign \$act_loc actx acty"
            puts $fp "    if \{ \$actx != \$tdx || \$acty != \$tdy \} \{ incr count ; lappend plist \$pin ; puts \$fp \"\$pin \$act_loc --> \$td_loc\"\}"
            puts $fp "\}"
            puts $fp "if \{ \$count > 0 \} \{"
            puts $fp "    puts \"-W- \$count ports are not in place.\" "
            puts $fp "    puts \"-W- Report in not_in_place_ports.rpt\""
            puts $fp "\} else \{"
            puts $fp "    puts \"-I- All ports are in place\""
            puts $fp "\}"
            puts $fp "close \$fp"
        }
     
        close $fp
        close $fp2
    }  

}


proc align_pins_b2i { b1 {abutted false} {ndr ""} {placement_report ""} } {

    puts "-I- Alignning ports for $b1"

    set bbox      [lindex [get_db designs         .bbox] 0]
    set b1_bbox   [lindex [get_db [get_cells $b1] .bbox] 0]
    lassign $bbox xl yl xh yh
    set b1_center [list [expr ($xh+$xl)/2.0] [expr ($yh+$yl)/2.0]]
    
    set ports   [get_ports *]
#    set b1_pins [get_pins [get_db pins -if .name==*$b1*/*]]
    
    
    if { $placement_report == "" } {
        puts "-I- Running pin placement check"
        check_all_quad_cells [get_cells $b1] "" true
        set placement_report "reports/pin_alignment/alignment_report_[get_db [get_cells $b1] .name].rpt"
    }

    puts "-I- Extracting pins from placement_report"
    set b1_pins {}
    if { ![file exists $placement_report] } { puts "-E- Placement report file: $placement_report not exists" ; return }
    set fp [open $placement_report r]
    set fd [read $fp]
    close $fp

    foreach line [split $fd "\n"] {
        if { $line == "" || ![regexp " port" $line] } { continue }
        set spline [split [regsub -all " +" $line " "] " "]
        lassign $spline res type1 p1 type2 p2

        if { $type1 == "pin" } { set index 2 } elseif { $type2 == "pin" } { set index 4 } { puts "-E- Something is wrong in \"align_pins_b2i $b1\"" ; return }
        lappend b1_pins [lindex $spline $index]
    } 
    puts "-I- Found [llength $b1_pins] pins"
    if { [llength $b1_pins] == 0 } { return }
    set b1_pins [get_pins $b1_pins]
    
    set ports_nets   [get_nets [get_db $ports   .net]]
    set b1_nets      [get_nets [get_db $b1_pins .net]]
    set common_nets  [get_db [common_collection $b1_nets $ports_nets] -if .num_connections==2]
    set common_ports [get_ports -of $common_nets]
        
    set_db [get_db messages *IMPPTN-867*]  .max_print 0
    set_db assign_pins_edit_in_batch true

    puts "-I- Clearing [sizeof $common_ports] misaligned ports"    
    set_db $common_ports .location {0 0}
    set_db $common_ports .place_status unplaced
    set pss {}
    foreach_in_collection cp $common_ports {
        set name    [get_db $cp .name]
        lappend pss [get_db port_shapes -if .name==*$name]
    }
    delete_obj $pss

    
    if { $ndr != "" && $ndr != "reset" } {
        puts "-I- Set NDR: $ndr on common nets"
        foreach net $common_nets {
            if { [catch {set_route_attributes -route_rule $ndr -nets [get_db $net .name]} res] } {
                puts $res
                puts "-E- set_route_attributes_failed"
                return
            }
        }
    } elseif { $ndr == "reset" } {
        puts "-I- Set NDR: $ndr on common nets"
        foreach net $common_nets {
            if { [catch {set_route_attributes -reset -nets [get_db $net .name]} res] } {
                puts $res
                puts "-E- set_route_attributes_failed"
                return
            }
        }
    }

    foreach net $common_nets {
    
	    set pins   [all_connected -leaf $net]
        set b1_pin [get_db $pins -if .name==*$b1/*]
        set b2_pin [get_db $pins -if .obj_type=="*port*"]
        
        set b1_pin_loc [lindex [get_db $b1_pin .location]  0]
        lassign $b1_pin_loc x1 y1
        
        set route_index [get_db $b1_pin .layer.route_index]        
        set b2_pin_layer       [get_db $b1_pin .layer.name]        
        
        if { [expr $route_index%2] } {        
            set min_dist [expr abs($x1 - $xl)]
            if { $min_dist < [expr abs($x1 - $xh)] } { set side $xl } else { set side $xh }
            set b2_pin_loc [list $side $y1]
        } else {
            set min_dist [expr abs($y1 - $yl)]
            if { $min_dist < [expr abs($y1 - $yh)] } { set side $yl } else { set side $yh } 
            set b2_pin_loc [list $x1 $side]            
        }
        if { $abutted } { set b2_pin_loc $b1_pin_loc }

        set edit_pin_cmd "edit_pin -snap  track  -fix_overlap  1  -pin  [get_db $b2_pin .base_name] -layer $b2_pin_layer   -assign  \" [join $b2_pin_loc " "] \""
        set line "if { \[catch { $edit_pin_cmd } res \] } { puts \"-E- Unable to place $b1_pin AND $b2_pin\" }\n"

        redirect -var eval_res { eval $line }
       
    }

    set_db assign_pins_edit_in_batch false

    set_db  [get_db messages *IMPPTN-867*]  .max_print 20
    
    check_all_quad_cells [get_cells $b1] "" true    
}

proc align_pins_i2b { b1 } {
    
    set b1 [get_db [get_cells $b1] .name]
    
    set bbox    [lindex [get_db designs         .bbox] 0]
    set b1_bbox   [lindex [get_db [get_cells $b1] .bbox] 0]
    lassign $b1_bbox xl yl xh yh
    
    set b1_center [list [expr ($xh+$xl)/2.0] [expr ($yh+$yl)/2.0]]
    
    set ports   [get_ports [get_db ports -if !.place_status==unplaced]]
    set b1_pins [get_pins [get_db pins -if .name==*$b1*/*]]
    
    set ports_nets  [get_nets [get_db $ports   .net]]
    set b1_nets     [get_nets [get_db $b1_pins .net]]
    set common_nets [get_db [common_collection $b1_nets $ports_nets] -if .num_connections==2]
    
        
#    set cmds "set_db assign_pins_edit_in_batch true\n"   
    set_db assign_pins_edit_in_batch true
    foreach net $common_nets {
    
	    set pins   [all_connected -leaf $net]
        set b1_pin [get_db $pins -if .name==*$b1/*]
        set b2_pin [get_db $pins -if .obj_type=="*port*"]
        
        set b2_pin_loc [lindex [get_db $b2_pin .location]  0]
        lassign $b2_pin_loc x2 y2
        
        set route_index [get_db $b2_pin .layer.route_index]        
        set b1_pin_layer       [get_db $b2_pin .layer.name]        
        
        if { [expr $route_index%2] } {        
            set min_dist [expr abs($x2 - $xl)]
            if { $min_dist < [expr abs($x2 - $xh)] } { set side 0 } else { set side [expr $xh - $xl] }
            set b1_pin_loc [list $side [expr $y2 - $yl]]
        } else {
            set min_dist [expr abs($y2 - $yl)]
            if { $min_dist < [expr abs($y2 - $yh)] } { set side 0 } else { set side [expr $yh - $yl] } 
            set b1_pin_loc [list [expr $x2 - $xl] $side]            
        }

        set edit_pin_cmd "edit_pin -hinst $b1 -snap  track  -fix_overlap  1  -pin  [get_db $b1_pin .base_name] -layer $b1_pin_layer   -assign  \" [join $b1_pin_loc " "] \""
        set line "if { \[catch { $edit_pin_cmd } res \] } { puts \"-E- Unable to place $b2_pin AND $b1_pin\" }\n"
#        puts $line >> xxx.tcl
        eval $line       
       
    }
#    append cmds "set_db assign_pins_edit_in_batch false\n"       
    set_db assign_pins_edit_in_batch false
    

}

# set b1_pattern nbus_to_west_nbus_
# set b2_pattern east_nbus_to_nbus_
proc mirror_bus2bus { b1_pattern b2_pattern direction {edge ""} {write_tcl false} } {
    # HELP - places b2_pattern pins/ports on the "edge" side according to b1_pattern's location
    
    if { [sizeof [set b1 [get_ports -quiet $b1_pattern*]]] == 0 } { set b1 [get_pins -quiet $b1_pattern*] }
    if { [sizeof [set b2 [get_ports -quiet $b2_pattern*]]] == 0 } { set b2 [get_pins -quiet $b2_pattern*] }
    
    set b1 [get_db $b1]
    set b2 [get_db $b2]
    
    if { [llength $b1] != [llength $b2] } { puts "-W- Busses have different width!" }
    
    if { [get_db -uniq $b1 .obj_type] == "port" } {
        set bbox [lindex [get_db designs .bbox] 0]
        lassign $bbox xl yl xh yh

        if { $direction == "V" || $direction == "v" } {

            set y1 [get_db [lindex $b1 0] .location.y]
            if { $y1 < [expr ($yh + $yl)/2] } { set side $yh } else { set side $yl }

        } elseif { $direction == "H" || $direction == "h" } {

            set x1 [get_db [lindex $b1 0] .location.x]
            if { $x1 < [expr ($xh + $xl)/2] } { set side $xh } else { set side $xl }

        } else {
            puts "-E- direction must be h/H or v/V!" ; return -1 
        }
        set b1_cell ""
    } else {
        set b1_cell [get_db -uniq $b1 .inst.name]
        set b1_loc  [lindex [get_db [get_cells $b1_cell ] .location] 0]
        set b1_bbox [lindex [get_db [get_cells $b1_cell ] .bbox] 0]

        if { $direction == "V" || $direction == "v" } {

            set offset [lindex $b1_loc 0]
            set yl     [lindex $b1_bbox 1]
            set yh     [lindex $b1_bbox 3] 
            set xl     [lindex $b1_bbox 0]
            set xh     [lindex $b1_bbox 2]               
            if { $edge == "down" } { set side 0 } else { set side [expr $yh - $yl] }
            set line [list 0 $side [expr $xh - $xl] $side]
            set layers {M1 M3}

        } elseif { $direction == "H" || $direction == "h" } {
            set offset [lindex $b1_loc 1]
            set yl     [lindex $b1_bbox 1]
            set yh     [lindex $b1_bbox 3]         
            set xl     [lindex $b1_bbox 0]
            set xh     [lindex $b1_bbox 2]                
            if { $edge == "left" } { set side 0 } else { set side [expr $xh - $xl] }
            set line [list $side 0 $side [expr $yh - $yl]]
            set layers {M2 M4}
        }             
        quick_place_pins $b1_cell $b2 $line $direction $layers        
    }


    if { $write_tcl != "false" } {         
        exec mkdir -pv $dir
        set fp  [open $dir/${b1_bc}_${b1_index}_to_${b2_bc}_${b2_index}_${direction}_port_placement.tcl w]
        set fp2 [open $dir/${b1_bc}_${b1_index}_to_${b2_bc}_${b2_index}_${direction}_quad_port_placement.tcl w]        
        puts $fp  "set_db assign_pins_edit_in_batch true"
        puts $fp2 "set_db assign_pins_edit_in_batch true"        
    }    

    echo "" > debug_mirror_b2b.rpt
    set_db assign_pins_edit_in_batch true
    foreach b1_port $b1 {
        
        set b2_port [regsub $b1_pattern $b1_port $b2_pattern]
        
        set x1 [get_db $b1_port .location.x]
        set y1 [get_db $b1_port .location.y]    
        set layer [get_db $b1_port .layer.name]    
        
        if { [get_db $b1_port .obj_type] == "port" } {
            if { $direction == "V" || $direction == "v" } {
                set b2_location [list $x1 $side]
            } elseif { $direction == "H" || $direction == "h" } {
                set b2_location [list $side $y1]
            }
        } else {
            if { $direction == "V" || $direction == "v" } {
                set b2_location [list [expr $x1 - $xl] $side]
            } elseif { $direction == "H" || $direction == "h" } {
                set b2_location [list $side [expr $y1 - $yl]]
            }        
        }
        
        
        if { [get_db $b1_port .obj_type] == "port" } {
            set edit_pin_cmd "edit_pin -snap  track  -fix_overlap  1  -pin  [get_db $b2_port .base_name] -layer $layer -assign  \" [join $b2_location " "] \""
        } else {
            set edit_pin_cmd "edit_pin -hinst $b1_cell -snap  track  -fix_overlap  1  -pin  [get_db $b2_port .base_name] -layer $layer -assign  \" [join $b2_location " "] \""        
        }
        set line "if { \[catch { $edit_pin_cmd } res \] } { puts \"-E- Unable to place $b2_port AND $b1_port\" }\n"
#        puts $line
        echo "[get_db $b1_port .base_name] --- [get_db $b2_port .base_name] ---  $x1 $y1 -- [lindex [get_db $b2_port .location]]" >> debug_mirror_b2b.rpt
        eval $line    
        
        if { $write_tcl != "false" } {
            set edit_pin_cmd "if \{ \[sizeof \[get_ports -quiet [get_db $b2_port .base_name]\]\] != 0 \} \{ edit_port -fixed -pin  [get_db $b2_port .base_name] -layer $layer   -assign  \" [join $b2_location " "] \" \}"
            puts $fp  $edit_pin_cmd
            if { [get_db $b1_port .obj_type] == "port" } { continue }
            set b2_cell [get_db [get_cell -of $b1_port] .name]
            set edit_pin_cmd "if \{ \[sizeof \[get_pins -quiet $b2/[get_db $b2_port .base_name]\]\] != 0 \} \{ edit_port -fixed -hinst $b2_cell -pin  [get_db $b2_port .base_name] -layer $layer   -assign  \" [join $b2_location " "] \" \}"
            puts $fp2 $edit_pin_cmd                
        }
        
        ### Compare actual vs assigned placement ###
        set b2_pin_actual_loc [lindex [get_db $b2_port .location]  0]
        set key "[get_db $b1_port .base_name]:[get_db $b2_port .base_name]"
        
        if { $direction == "V" || $direction == "v" } {
            set pin_pairs_arr($key) [expr $x1 - [lindex $b2_pin_actual_loc 0]]
        } else {
            set pin_pairs_arr($key) [expr $y1 - [lindex $b2_pin_actual_loc 1]]        
        }

    }    
    set_db assign_pins_edit_in_batch false
    
    if { $write_tcl != "false" } { 
        puts $fp "set_db assign_pins_edit_in_batch false"    
        close $fp
        puts $fp2 "set_db assign_pins_edit_in_batch false"    
        close $fp2        
    }
    
#    append cmds "set_db assign_pins_edit_in_batch false\n"       
    set_db assign_pins_edit_in_batch false
    echo "-I- Missaligned ports:" > reports/${b1_cell}_missaligned_ports.rpt                     
    set index0 0
    set index1 0
    foreach name [array names pin_pairs_arr] {
        incr index0
        if { $pin_pairs_arr($name) != 0 } {
            incr index1
            lassign [split $name ":"] p1 p2
            puts "-W- $p1 and $p2 are not aligned"
            echo "$p1 $p2" >> reports/${b1_cell}_missaligned_ports.rpt                     
        }        
    }
    puts "-I- Out of $index0 tested, $index1 not aligned"
    puts "-I- End pin alignment for $b1_pattern - $b2_pattern. [::ory_time::now]"        
    
    

}

# set p1_pin i_cbu/i_cbue_top/cbus_to_west_data_ft_out__0
# set map [list [list out in] [list ft blaaaaa]]
proc mirror_p2p { cell p1_bus map direction } {

    set p1 [get_db $p1_bus]
    
    set bbox [lindex [get_db [get_cells $cell] .bbox] 0]
    lassign $bbox xl yl xh yh
    
    if { $direction == "V" || $direction == "v" } {

        set y1 [get_db [lindex $p1 0] .location.y]
        if { $y1 < [expr ($yh + $yl)/2] } { set side [expr $yh - $yl] } else { set side 0 }
        set offset $xl
        
    } elseif { $direction == "H" || $direction == "h" } {

        set x1 [get_db [lindex $p1 0] .location.x]
        if { $x1 < [expr ($xh + $xl)/2] } { set side [expr $xh - $xl] } else { set side 0 }
        set offset $yl

    } else {
        puts "-E- direction must be h/H or v/V!" ; return -1 
    }

    set_db assign_pins_edit_in_batch true
    foreach p1_pin $p1 {

        set p2_pin $p1_pin
        foreach m $map {
            set p2_pin     [regsub [lindex $m 0] $p2_pin [lindex $m 1]]
        }
        
        set x1 [get_db $p1_pin    .location.x]
        set y1 [get_db $p1_pin    .location.y]    
        set layer [get_db $p1_pin .layer.name]    
        
        if { $direction == "V" || $direction == "v" } {
            set p2_location [list [expr $x1 - $offset] $side]
        } elseif { $direction == "H" || $direction == "h" } {
            set p2_location [list $side [expr $y1 - $offset]]
        }
        
        set edit_pin_cmd "edit_pin -hinst $cell -snap  track  -fix_overlap  1  -pin  [get_db $p2_pin .base_name] -layer $layer -assign  \" [join $p2_location " "] \""
        set line "if { \[catch { $edit_pin_cmd } res \] } { puts \"-E- Unable to place $p2_pin AND $p1_pin\" }\n"
#        puts $line >> xxx.tcl
        eval $line       

    }    
    set_db assign_pins_edit_in_batch false
    

}


proc create_io_placement_file { file } {

    set ports  [get_db ports -if .place_status==fixed||.place_status==placed]
    set names  [get_db $ports .name]
    set locs   [get_db $ports .location]
    set layers [get_db $ports .layer.name]
    
    echo "set_db assign_pins_edit_in_batch true\n" > $file
        
    foreach name $names loc $locs layer $layers {
    
        set line "edit_pin -snap  track  -fix_overlap  1  -pin  $name -layer $layer   -assign  \" $loc \""
        echo $line >> $file
    
    }
    
    echo "set_db assign_pins_edit_in_batch false\n" >> $file

}


proc dump_io_placement_data { file } {

    set ports  [get_db ports -if .place_status==fixed||.place_status==placed]
    set names  [get_db $ports .name]
    set locs   [get_db $ports .location]
    set layers [get_db $ports .layer.name]
    set widths [get_db $ports .width]
    set depths [get_db $ports .depth]    
    
    set fp [open $file w]
    
    puts $fp "puts \"-I- IO placement data for block [get_db designs .name] ::oy_time::now\""  
    puts $fp "array unset [get_db designs .name]_io_placement_arr"   
    puts $fp "array set [get_db designs .name]_io_placement_arr {"  
    foreach name $names loc $locs layer $layers width $widths depth $depths {
        puts $fp "$name { \{$loc\} $layer $width $depth }"  
    }
    puts $fp "}\n"
    puts $fp "set latest_io_placement_arr_name [get_db designs .name]_io_placement_arr"
    puts $fp "puts \"-I- Data is an array of the structure: [get_db designs .name]_io_placement_arr(port_name) { location layer width depth }\"\n"      

    close $fp
}

proc io_placement_convert_array_to_commands { arr_list {hinst ""} } {

    array set arr $arr_list
    
    set cmd_list "set_db assign_pins_edit_in_batch true\n" 
        
    foreach name [array names arr] {
        lassign $arr($name) loc layer 
        if { $hinst == "" } {
            set line "edit_pin               -layer [format %4s $layer] -assign [format %20s \{$loc\}] -pin  $name "
        } else {
            set line "edit_pin -hinst $hinst -layer [format %4s $layer] -assign [format %20s \{$loc\}] -pin  $name "        
        }
        append cmd_list "$line\n"
    }
    
    append cmd_list "set_db assign_pins_edit_in_batch false\n"
    
    return $cmd_list    
    
}

proc impl_io_placement_from_data { file {hinst ""} {debug false} } {
    
    if { ![file exists $file] } { puts "-E- No file $file found!" ; return }

    puts "-I- Sourcing $file"    
    if { [catch {source $file} res] } { puts "-E- Error while sourcing io placement data" ; puts $res ; return }
    
    set cmd_list [io_placement_convert_array_to_commands [array get $latest_io_placement_arr_name] $hinst]
    
    if { $debug } {
        puts "-I- Run in debug mode. Port placement will not be executed"
        puts "-I- Debug IO placement file is in ${file}.debug"     

        set fp [open ${file}.debug w]
        puts $fp $cmd_list
        close $fp
        
        return
    }
    
    eval $cmd_list

}


proc create_td_io_placement_file { cell file {pins ""} } {
    
    set inst [get_cells $cell]
    set loc  [lindex [get_db $inst .location] 0]
    lassign $loc xoff yoff
    
    if { $pins == "" } {
        set pins [get_db pins $cell/*]    
    } else {
        set pins [get_db $pins]
    }
    set pins [get_db $pins -if !.base_name==*grid_clk*]
    set names  [get_db $pins .base_name]
    set locs   [get_db $pins .location]
    set layers [get_db $pins .layer.name]
    
    set for_quad_file [regsub ".tcl\$" ${file} ".for_quad.tcl"]
    
    echo "set_db assign_pins_edit_in_batch true\n" > $file
    echo "set_db assign_pins_edit_in_batch true\n" > $for_quad_file
    
    echo "set_db \[get_db ports *\] .location {0 0}\n" >> $file
    echo "set_db \[get_db ports *\] .place_status unplaced\n" >> $file
    echo "delete_obj \[get_db port_shapes -if {.name != V*}\]\n" >> $file            
    
    set mod 1000    
    set index 0
    foreach name $names loc $locs layer $layers {
        lassign $loc x y
        set new_loc [list [format "%.4f" [expr $x - $xoff]] [format "%.4f" [expr $y - $yoff]] ]
        set line "edit_pin -fixed_pin -snap  track  -fix_overlap  1  -pin  $name -layer $layer   -assign  \" $new_loc \""
        echo $line >> $file
        set line "edit_pin -hinst [get_db $inst .name] -fixed_pin -snap  track  -fix_overlap  1  -pin  $name -layer $layer   -assign  \" $new_loc \""
        echo $line >> $for_quad_file
#        if { [expr $index%$mod] == 0 || [regexp nbus_to_north_nbus_valid_ $name]} {
#            puts "[format "%-60s" $name]: [format "%-20s" $loc] -> $new_loc"
#        }
        incr index
    }
    
    echo "set_db assign_pins_edit_in_batch false\n" >> $file
    echo "set_db assign_pins_edit_in_batch false\n" >> $for_quad_file    

}



proc create_pin_placement_file { cell file } {

    set pins   [get_db pins $cell/*]
    set names  [get_db $pins .base_name]
    set locs   [get_db $pins .location]
    set layers [get_db $pins .layer.name]
    
    echo "set_db assign_pins_edit_in_batch true\n" > $file
        
    foreach name $names loc $locs layer $layers {
    
        set line "edit_pin -hinst $cell  -snap  track  -fix_overlap  1  -pin  $name -layer $layer   -assign  \" $loc \""
        echo $line >> $file
    
    }
    
    echo "set_db assign_pins_edit_in_batch false\n" >> $file

}


proc list2hist { vector bin } {

    set vector [lsort -real -increasing $vector]
    set max_val [lindex $vector end]
    set min_val [lindex $vector 0]
    set buck_l [expr $min_val - 0.5*$bin]
    set buck_h $buck_l
    array unset l
    set max_word 0
    set min 9999
    set max -9999
    set table {} 
    set indx 0
    set count 0
    while { $buck_h < $max_val } {
        set buck_h [expr $buck_l + $bin]
        set count 0
#        puts "range: $buck_l $buck_h"
        foreach val $vector { 
            if { ($val > $buck_l) && ($val <= $buck_h) } { incr count }
        }
        if {$buck_h >= $max_val} {
            set n "\($buck_l\)-\($max_val\)"
#             puts "$n: $count"
            set l($indx:$n) $count
            incr indx
            if { [string length $n] > $max_word } { set max_word [string length $n] }         
        } else {
            set n "\($buck_l\)-\($buck_h\)"
#             puts "$n: $count"
            set l($indx:$n) $count
            incr indx
            if { [string length $n] > $max_word } { set max_word [string length $n] } 
        }
        if { $min > $count } { set min $count}
        if { $max < $count } { set max $count}        
        set buck_l [expr $buck_h]
#puts "$buck_h $max_val $count"        
    }

    set ratio [expr (1.0*($max-$min)/[llength $vector])/($max/200.0)]
    if { $min == $max } { set ratio 1 }

#    puts "-D- ratio=$ratio, max=$max, min=$min mw=$max_word" ; parray l

#    foreach n [lsort [array names l]] { puts "[format "%-${max_word}s" [lindex [split $n ":"] 1]] - [format "%-8s" $l($n)] - [string repeat "\#" [expr int($l($n)*$ratio) + 1]]" }
    
    for { set i 0 } { $i < $indx } { incr i } {
        
        set n [array names l $i:*]
        puts "[format "%-${max_word}s" [lindex [split $n ":"] 1]] - [format "%-8s" $l($n)] - [format "%-8s" [format "%.2f" [expr 100.0*$l($n)/[llength $vector]]]%] - [string repeat "\#" [expr int($l($n)*$ratio) + 1]]"
        
    }
 

}

proc be_skew_hist { {max_path 5000000} {view ""} {exclude_pattern ""} } { 
    
    if { $view == "" } {
        set view [get_db analysis_views -if ".is_setup_default==true"]
    }
    
    set tps [get_db [report_timing -path_type full_clock -max_paths $max_path -view $view -collection -from [all_registers] -to [all_registers]]]
    
    if { $exclude_pattern != "" } {
        set tps [get_db $tps -if ".launching_point.name!=$exclude_pattern&&.capturing_point.name!=$exclude_pattern"]
    }
    
    
    set skews [get_db $tps .skew]
    puts "-I- prints skew hist for [llength $tps] timing paths"
    list2hist $skews 0.02

    set sorted_skews [lsort -incr -real  $skews] 
    set max_skew [lindex $sorted_skews end]
    set min_skew [lindex $sorted_skews 0]   
    
    set max_skew_index [lsearch $skews $max_skew] 
    set max_skew_path  [lindex $tps $max_skew_index]
    set start_point    [get_db $max_skew_path .launching_point]
    set end_point      [get_db $max_skew_path .capturing_point]    
    
    puts "-I- Max skew worst path path"
    report_timing -view $view -from $start_point -to $end_point -path_type full_clock
}

proc check_cell_overlap { cell } {

    set bbox     [get_db $cell .bbox]
    set ol_cells [get_db [get_cells_within $bbox] ]
    
    if { [llength $ol_cells] > 1 } {
        return $ol_cells
    } else {
        return {}
    }

}

proc get_cells_within { bbox {enclosed_only false} } {
    
    if { $enclosed_only } {
    return [get_cells -quiet [get_db [eval_legacy "dbQuery -objType inst  -area $bbox -enclosed_only"]]]
    } else {
    return [get_cells -quiet [get_db [eval_legacy "dbQuery -objType inst  -area $bbox"]]]
    }
    
}

proc get_pins_within { bbox } {
    
    set cells [get_cells_within $bbox]
    set pins  [get_pins -of $cells]
    
    lassign $bbox xl yl xh yh
    
    set pins_within [get_db $pins -if .location.x>=$xl&&.location.x<$xh&&.location.y>=$yl&&.location.y<$yh]
    
    return [get_pins -quiet $pins_within ]
    
}

proc _legalize_F6UNAA_LPDSINVGT5X96 { inst {horizdist 3} {vertdist 3} } {
    
    puts "-I- Legalizing $inst"
    
    set xmul 8.5935
#    set xmul 4.488
    set ymul 5.25
    
    set gridx 27.132
    set gridy 10.08
    
    set current_loc  [lindex [get_db $inst .location] 0]
    set current_bbox [lindex [get_db $inst .bbox] 0]
    
    lassign $current_loc   x y
    lassign $current_bbox  xl yl xh yh
    
    set width  [expr $xh - $xl]
    set height [expr $yh - $yl]
    
    set xunits [expr round($x/$gridx)]
    set yunits [expr round($y/$gridy)]    
    
    set xorig [expr $xunits*$gridx + $xmul]
    set yorig [expr $yunits*$gridy + $ymul]
    
    set horizvec {}
    for { set i 0 } { $i < $horizdist } { incr i } { set horizvec [concat $horizvec [lsort -u [list $i [expr -$i]]]] }
    set vertvec {}
    for { set i 0 } { $i < $vertdist } { incr i } { set vertvec [concat $vertvec [lsort -u [list $i [expr -$i]]]] }    

    array unset box_dist_arr 
    foreach i $horizvec {
        
        set xl [expr $xorig + $i*$width]
        set xh [expr $xorig + ($i+1)*$width]
        
        foreach j $vertvec {
            
            set yl [expr $yorig + $j*$height]
            set yh [expr $yorig + ($j+1)*$height]
           
            set new_box [list $xl $yl $xh $yh]
#            puts "-D- Box $i,$j\t: $new_box"
            set box_dist_arr($new_box) [expr abs($i)+abs($j)]
            
        }
        
    }
    
    set best_box {}
    set min_dist 999
    foreach box [array names box_dist_arr] {

        set ol_cells [remove_from_collection [get_cells -quiet [get_db [get_cells_within $box]]] [get_cells $inst]]        
        
        if { [llength $ol_cells] > 0 } { continue }  
        
        set dist $box_dist_arr($box)
        if { $dist < $min_dist } { set best_box $box ; set min_dist $dist }
        
    }
    
    if { $best_box == {} } { puts "-E- Found no legal location for $inst with dist of $horizdist in X and $vertdist in Y" ; return -1 }    
        
    lassign $best_box new_x new_y other_x other_y
    
    puts "-I- Original location of [get_db $inst .name]: $current_loc"
    puts "-I- New      location of [get_db $inst .name]: $new_x $new_y"
      
    place_inst [get_db $inst .name] [list $new_x $new_y] mx
}




::parseOpt::cmdSpec add_clean_shape {
    -help "Add a (drc) clean shape for a given net at a give line"
    -opt    {
            {-optname net         -type string   -default ""       -required 1 -help "Net to add shape to"}
            {-optname layer       -type string   -default ""       -required 1 -help "Layer of added shape"}
            {-optname line        -type string   -default ""       -required 1 -help "Line of added shape"}
            {-optname route_rule  -type string  -default "DEFAULT" -required 0 -help "Route rule to follow"} 
            {-optname max_dist    -type float    -default 0.5      -required 0 -help "Max distance to move shape for clean drc"} 
            {-optname reverse     -type boolean  -default false    -required 0 -help "IF true - Search down/left first. Default - search up/right first"}             
            {-optname drc_th      -type integer  -default 0        -required 0 -help "Max number of allowrd drc violations"} 
            {-optname force       -type boolean  -default false    -required 0 -help "Ignor all drcs and add shape"} 
            {-optname avoid_cross_vias -type boolean -default false -required 0 -help "If true, avoid creating crossover vias "} 
            {-optname via_map     -type string   -default ""       -required 0 -help "Replace via types of added wire"}
            
    }
}

proc add_clean_shape   { args } {

	if { ! [::parseOpt::parseOpt add_clean_shape $args] } { return 0 }
    
    if { [set net [get_db $opt(-net) .name]] == "" } { 
        puts "-E- You must enter a valid net!"
        return -1
    }
    set reverse       $opt(-reverse)
    set force         $opt(-force)
    set drc_th        $opt(-drc_th)
    set layer         $opt(-layer)
    set line          $opt(-line)
    set max_dist      $opt(-max_dist)
            
    lassign $line orig_x0 orig_y0 orig_x1 orig_y1
    
    set x0 $orig_x0
    set x1 $orig_x1
    set y0 $orig_y0
    set y1 $orig_y1
        
    # Settings 
    set settings "
    set_db edit_wire_nets $net
    set_db edit_wire_rule {$opt(-route_rule)}\n"
    
    if { $opt(-avoid_cross_vias) } { append settings "    set_db edit_wire_create_crossover_vias {0}\n" } else { append settings "    set_db edit_wire_create_crossover_vias {1}\n" }
    
    puts "-I- Eval settings: $settings"
    eval $settings
        
    set layer_number [string trim $layer "M"]
    if { [expr $layer_number%2] == 0 } { 
        set dir "h"
        set pitch  [get_db [get_db layers  $layer] .pitch_y]
        set assumed_bbox [list [expr min($x0, $x1)] [expr min($y0,$y1) - $max_dist] [expr max($x0, $x1)] [expr max($y0,$y1) + $max_dist]]
        
        puts "-D- Setting horizontal layer: $layer"
        set_db edit_wire_layer_horizontal $layer   
        
        set point_sort_index 0
        set line_mark $y0
        
    } else { 
        set dir "v" 
        set pitch  [get_db [get_db layers  $layer] .pitch_x]
        set assumed_bbox [list [expr min($x0, $x1) - $max_dist] [expr min($y0,$y1)] [expr max($x0, $x1) + $max_dist] [expr max($y0,$y1)]]
        
        puts "-D- Setting vertical layer: $layer"    
        set_db edit_wire_layer_vertical   $layer    

        set point_sort_index 1
        set line_mark $x0
        
    }
    set orig_wires [get_wires_within $assumed_bbox $layer]            
    
    if { $pitch > $max_dist } {
        puts "-E- Layer $layer pitch is greater then max_distance $max_dist"
        return -2 
    }
    
    delete_drc_markers
    
    puts "-D- Adding route in: $x0 $y0 -> $x1 $y1"
    edit_add_route_point $x0  $y0
    edit_end_route_point $x1  $y1
    
    # Verify actual wire location + get its new line
    set current_wires [get_wires_within $assumed_bbox $layer]
    set new_wire      [remove_from_list $current_wires $orig_wires]
    set sorted_points [lsort -index $point_sort_index [get_db $new_wire .points]]
    set current_line  [concat [lindex $sorted_points 0] [lindex $sorted_points end]]
#    lassign $current_line x0 y0 x1 y1
#    
#    if { $dir == "h" } { set new_line_mark $y0 } else { set new_line_mark $x0 }
#    
#    puts "-D- Line mark: $line_mark ; New line mark: $new_line_mark"
    
    set markers [get_db markers]

    if { $reverse } { set sign -1 } else { set sign 1 }
    
    set shift 0
    set i 0
    set safety 1000
    while { $i < $safety && ( !$force && [llength $markers] > $drc_th && $shift < $max_dist ) } {
        
        gui_undo 
        
        if { $dir == "h" } {
            set y0 [expr $y0 + $sign*$pitch]
            set y1 $y0
            set new_line_mark $y0
            set shift [expr $shift + $pitch]
        } else {
            set x0 [expr $x0 + $sign*$pitch]
            set x1 $x0
            set new_line_mark $x0            
            set shift [expr $shift + $pitch]        
        }
        puts "going up: $x0 $y0 $x1 $y1"
        edit_add_route_point $x0  $y0
        edit_end_route_point $x1  $y1

        set current_wires [get_wires_within $assumed_bbox $layer]
        set new_wire      [remove_from_list $current_wires $orig_wires]
        set sorted_points [lsort -index $point_sort_index [get_db $new_wire .points]]
        set current_line  [concat [lindex $sorted_points 0] [lindex $sorted_points end]]
#        lassign $current_line x0 y0 x1 y1
#        if { $dir == "h" } { set new_line_mark $y0 } else { set new_line_mark $x0 }
#
#        puts "-D- Line mark: $line_mark ; New line mark: $new_line_mark"

        
        set markers [get_db markers]
    
        incr i
    }
    
    if { $i > $safety } {
        puts "-E- Something went wrong! Talk to OrY"
        return -3
    }
        
    set shift 0
    set i 0
    set safety 1000

    set x0 $orig_x0
    set x1 $orig_x1
    set y0 $orig_y0
    set y1 $orig_y1
    
    while { $i < $safety && ( !$force && [llength $markers] > $drc_th && $shift < $max_dist ) } {
        
        gui_undo 
        
        if { $dir == "h" } {
            set y0 [expr $y0 - $sign*$pitch]
            set y1 $y0
            set new_line_mark $y0
            set shift [expr $shift + $pitch]
        } else {
            set x0 [expr $x0 - $sign*$pitch]
            set x1 $x0
            set new_line_mark $x0            
            set shift [expr $shift + $pitch]        
        }
        puts "going down: $x0 $y0 $x1 $y1"        
        edit_add_route_point $x0  $y0
        edit_add_route_point $x1  $y1
        edit_end_route_point $x1  $y1

        set current_wires [get_wires_within $assumed_bbox $layer]
        set new_wire      [remove_from_list $current_wires $orig_wires]
        set sorted_points [lsort -index $point_sort_index [get_db $new_wire .points]]
        set current_line  [concat [lindex $sorted_points 0] [lindex $sorted_points end]]
#        lassign $current_line x0 y0 x1 y1
        
        set markers [get_db markers]
    
        incr i
    }
    
    if { $i > $safety } {
        puts "-E- Something went wrong. Talk to OrY"
        return -3
    }
    
    if { $shift > $max_dist } {
        puts "-E- Could not find a clean location within max distance of $max_dist from line $line"
        gui_undo
        return -4
    }
    puts "-I- New wire desired location: $line"
    puts "-I- New wire actual  location: $current_line"
    
    # Edit vias
    if { $opt(-via_map) != "" } {
        array set via_map $opt(-via_map)
        set vias [get_vias_within [list $x0 $y0 $x1 $y1]]
        
        foreach via_type [array names via_map] {
            if { [set myVias [get_db $vias -if .via_def.name==$via_type]] != "" } {
                foreach via $myVias {
                    set loc [lindex [get_db $via .location] 0]
                    lassign $loc x y
                    puts "-R- edit_update_via -from $via_type -to $via_map($via_type) -at [list $x $y]"
                    edit_update_via -from $via_type -to $via_map($via_type) -at [list $x $y]                
                }
            }
        }

    }
    
    
    return [list $current_line $new_wire]
}



proc get_ports_within { bbox {layer ""} } {
    
    set res  [get_db [eval_legacy "dbQuery -objType pinshape  -area $bbox"] ]
    if { $res   == {} } { return {} }
    if { $layer == "" } { return $res }
    
    return [get_db $res -if .layer.name==$layer]
}

proc get_wires_within { bbox {layer ""} {overlap false} } {

    set all_wires {}
    
    if { !$overlap } {
        if { $layer == "" } {
            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType swire  -area $bbox"] ]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType pwire  -area $bbox"] ]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType wire  -area $bbox"]  ]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }
        } else {
            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType swire  -area $bbox"] -if .layer.name==$layer]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType pwire  -area $bbox"] -if .layer.name==$layer]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType wire  -area $bbox"] -if .layer.name==$layer ]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

        }
    } else {
        if { $layer == "" } {
            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType swire -overlap_only -area $bbox"] ]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType pwire -overlap_only -area $bbox"] ]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType wire  -overlap_only -area $bbox"]  ]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }
        } else {
            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType swire -overlap_only -area $bbox"] -if .layer.name==$layer]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType pwire -overlap_only -area $bbox"] -if .layer.name==$layer]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

            if { [llength [set wires [get_db [eval_legacy "dbQuery -objType wire  -overlap_only -area $bbox"] -if .layer.name==$layer ]] ] > 0 } {
                set all_wires [concat $all_wires $wires]
            }

        }

    }
    
    return $all_wires

}


proc get_vias_within { bbox } {

    set all_vias {}
    if { [llength [set vias [get_db [eval_legacy "dbQuery -objType sviainst  -area $bbox"] ]] ] > 0 } {
        set all_vias [concat $all_vias $vias]
    }
    
    if { [llength [set vias [get_db [eval_legacy "dbQuery -objType viainst  -area $bbox"] ]] ] > 0 } {
        set all_vias [concat $all_vias $vias]
    }
        
    return $all_vias

}

proc get_pg_tracks_within { bbox layer } {
    set ri        [get_db [get_db layers $layer] .route_index]
    set via_layer [regsub "M" $layer "VIA"]
    
    lassign $bbox xl yl xh yh
    
    set wires [get_db [get_wires_within $bbox $layer true] -if .net.name==VDD||.net.name==VSS]
    
    set pgs {}
    if { [expr $ri%2] == 0 } { 
        if { [llength $wires] > 0 } { set pgs  [lsort -u [get_db $wires .path.x]] }
#        if { [llength $vias]  > 0 } { set pgs  [lsort -u [concat $pgs [get_db [get_db $vias -if .point.x<=$xh&&.point.x>$xl] .point.x]]] }
    } else {
        set vias  [get_db [get_vias_within $bbox] -if (.net.name==VDD||.net.name==VSS)&&.via_def.cut_layer.name==$via_layer]
        if { [llength $wires] > 0 } { set pgs  [lsort -u [get_db $wires .path.y]] }
        if { [llength $vias]  > 0 } { set pgs  [lsort -u [concat $pgs [get_db [get_db $vias -if .point.y<=$yh&&.point.y>$yl] .point.y]]] }
    }
    
    return [llength $pgs]
}

proc ory_draw_bbox {box {color 'yellow'}} {
    create_gui_shape -rect $box -layer User_box_layer_$color
    set_layer_preference User_box_layer_$color -is_visible 1
    set_layer_preference User_box_layer_$color -color $color -stipple_data 8 4 "0x00 0x11 0x00 0x00"
}

proc ory_clear_gui {} {
    gui_delete_objs -all
    gui_clear_highlight -all
}


proc ory_sort_pins_by_edge { cell neighbors_map } {
    # Neighbors_map = {block_name0 edge_num0 block_name1 edge_num1 ...}
    
    array unset result_arr
    array unset neighbors_arr
    array set neighbors_arr $neighbors_map
    set myPins [get_pins [get_db $cell .pins]]
    
    foreach block_name [array names neighbors_arr] {
        
        set edge $neighbors_arr($block_name)
        set inst [get_db insts $block_name]
        if { [ llength $inst ] == 0 } { puts "-W- Block $block_name not found" ; continue }
        
        set yourPins   [get_db $inst .pins]
        set yourNets   [get_nets -hier -of $yourPins]
        set allPins    [get_pins -hier -of $yourNets]
        set commonPins [common_collection $myPins $allPins]    
        
        set result_arr("$edge:$block_name") $commonPins
        
    }
    
    set output_file "[get_db $cell .name]_ports_edges.tcl"  
    set fp [open $output_file w]
    set summary ""
    foreach name [lsort [array names result_arr]] {
        set pins $result_arr($name)
        set name "edge_[string trim [regsub ":" $name "_"] "\""]"
        puts $fp "puts \"-I- Setting ports list for $name\""  
        puts $fp "set $name \[get_ports \""
        foreach_in_collection pin $pins {
            puts $fp "[get_db $pin .base_name]"
        }
        puts $fp "\"\]"
        
        append summary "puts \"-I- TOP  : Set [sizeof $pins] ports in $name\"\n"
        append summary "puts \"-I- BLOCK: Set \[sizeof \$$name\] ports in $name\"\n"        
    }
    puts $fp $summary
    
    close $fp    
        
}

proc quick_place_pins { hinst pins line dir layers } {

    lassign $line xl yl xh yh
    set distx [expr $xh - $xl]
    set disty [expr $yh - $yl]
    if { $dir == "v" || $dir == "V" } { 
        set dist  $distx 
        set const $yl
        set start $xl
    } elseif { $dir == "h" || $dir == "H" } {
        set dist  $disty
        set const $xl
        set start $yl
    } else {
        puts "-E- dir must be v OR h"
        exit
    }
    
    
    set pins       [get_db $pins .base_name]
    set size       [llength $pins]
    set delta      [expr 1.0*$dist/$size]
    set layersNum  [llength $layers] 
    
    set cmd ""
    for { set i 0 } { $i < $size } {incr i} {
        set p      [lindex $pins $i]
        set layer  [lindex $layers [expr $i%$layersNum]]
        set newP   [expr $start + $i*$delta]
        if { $dir == "v" || $dir == "V" } { set new_loc [list $newP $const] } { set new_loc [list $const $newP] }
        if { $hinst != "" } {
            set new_line "edit_pin -hinst $hinst -snap track -fix_overlap  1  -pin $p -layer $layer -assign  \"$new_loc\""
        } else {
            set new_line "edit_pin -snap track -fix_overlap  1  -pin $p -layer $layer -assign  \"$new_loc\""
        }
        append cmd "$new_line\n"
    }
    
    set_db assign_pins_edit_in_batch true
    puts "-I_ eval edit_pin commands"
    redirect -stderr -var eval_res { eval $cmd }
    set_db assign_pins_edit_in_batch false
    
    if { [regexp "ERROR" $eval_res] } { 
        puts "-E- Errors founs dureing command eval\n-E- See reports/eval_errors.rpt for more details" 
        set fp [open reports/eval_errors.rpt w]
        puts $eval_res $fp
        close $fp
    }
    
}


proc get_pin_lef_const { pin } {
    
    if { [set lef_file [get_db $pin .inst.base_cell.lef_file_name]] == "" } { return 1 }
    if { ![file exists $lef_file] } { return 2 }
    
    set bn [regsub "\\\]" [regsub "\\\[" [get_db $pin .base_name] "\\\["] "\\\]"]
    
    puts [grep -A5 "PIN $bn" $lef_file]
    
}



proc report_route_rules { {pattern ""} {max_layer ""} {min_layer ""}} {
    
    if { $max_layer == "" } { set max_layer design_top_routing_layer }
    if { $min_layer == "" } { set max_layer design_bottom_routing_layer }    
    
    if { $pattern == "" } {    
    set rrs [get_db route_rules]
    } else {
    set rrs [get_db route_rules $pattern]
    }
    
    set all_layers [get_db -uniq $rrs .layer_rules.layer]
    set header [list "Rule_Name"]
    foreach layer $all_layers {
        set index [get_db $layer .route_index]
        set name  [get_db $layer .name]        
        if { $index > $max_layer || $index < $min_layer} { continue } 
        lappend header "${name}_w" ; lappend header "${name}_s"
    }
    
    set table {}
    array unset rr_arr 
    foreach rr $rrs {
        
        set rr_arr([get_db $rr .name]) [get_db $rr .layer_rules]
        
        set line [list [get_db $rr .name]]
        
        foreach layer $all_layers {
            set index [get_db $layer .route_index]
            set name  [get_db $layer .name] 
            if { $index > $max_layer || $index < $min_layer} { continue } 
            if { [set lr [get_db [get_db $rr .layer_rules] -if .layer.name==$name]] == "" } { 
                lappend line "0" 
                lappend line "0"
            } else {
                lappend line [get_db $lr .width]
                lappend line [get_db $lr .spacing]
            }
        }
        lappend table $line
        
    }
    
    rls_table -table $table -header $header -spac -breaks
    
}



proc write_ports_only { file_name } {

    write_def -floorplan -no_std_cells $file_name
    
    if { [set row_index [lsearch  [split [exec head -250 $file_name] "\n"]  "*ROW*"]] > 0 } {
        set head      [exec head -$row_index $file_name]
    } elseif { [set row_index [lsearch  [split [exec head -250 $file_name] "\n"]  "*TRACKS*"]] > 0 } {        
        set head      [exec head -$row_index $file_name]
    } else {
#        set row_index [lsearch  [split [exec head -150 $file_name] "\n"]  "*END PROPERTYDEFINITIONS*"
#        set head      [exec head -$row_index $file_name]
#        set head -9
    }
    
    set pin_start [lindex [split [exec grep -n "^PINS " $file_name] ":"] 0]
    set pin_end   [lindex [split [exec grep -n "^END PINS" $file_name] ":"] 0]
    
    set pins      [exec head -$pin_end $file_name | tail -[expr $pin_end - $pin_start + 1]]
    
    set def "$head\n$pins\nEND DESIGN\n"
    
    set fp [open $file_name w]
    puts $fp $def
    close $fp
    
}


proc convert_early_global_to_route { nets {is_write_def false} } {
    
    set nets [get_nets $nets]
    if { [sizeof $nets] == 0 } { puts "-E- Not nets found" ; return -1 }
    
    set straight_nets [filter_routed_p2p_nets $nets]
    
    puts "-I- Total number of routed straight nets is [llength $straight_nets] / [sizeof $nets]"
    
    set wires  [get_db $straight_nets .wires]
    set vias   [get_db $straight_nets .vias]
    
    set_db $wires .status fixed
    
    deselect_obj -all
    select_obj $straight_nets
    
    if { $is_write_def!="false" } { 
        if { $is_write_def=="true" } { write_def -selected -routing out/def/routed_straight_nets.def } { write_def  -selected -routing $is_write_def }
    }
}


proc ory_calc_net_area { {nets ""}} {
    
    if { $nets == "" } { set nets [get_nets -hier] } 
    
#    redirect /dev/null {
#    define_attribute be_net_area -category be_user_attributes -data_type string  -obj_type net -default -1
#    define_attribute area -category be_user_attributes -data_type double  -obj_type wire -default -1    
#    }
    
    set total [llength $nets]
    set current 0
    
    array unset total_area_arr

    if { [llength [set swires [get_db $nets .special_wires]]] == 0 && [llength [set wires [get_db $nets .wires]]] == 0 } { set_db $nets .be_net_length 0 ; continue }        
    set layers [lsort -u [get_db [concat $wires $swires] .layer.name]]
        
    array unset area_arr

    foreach layer $layers {

        puts "-I- Layer: $layer"
        set area 0
        
        if { [llength [set lswires [get_db $swires -if .layer.name==$layer]]] > 0 } {
            set area [lsum [get_db $laswires .area]]
        } 
        
        if { [llength [set lwires  [get_db $wires -if .layer.name==$layer]]] > 0 } {
            set begin_ext [get_db $lwires .begin_extension]
            set end_ext   [get_db $lwires .end_extension]        
            set length    [get_db $lwires .length]   
            set width     [get_db $lwires .width]                        

            set curr  0
            set total [llength $width]

            foreach be $begin_ext ee $end_ext l $length w $width {
                incr curr  
                ory_progress $curr $total
                set area [expr $area + $w * ($be + $l + $ee)]         
            }

            set total_length [lsum [concat $begin_ext $end_ext $length]]
            set area_arr([string trim $layer "M"]) [list $layer [llength [lsort -u [get_db $lwires .net]]] $area $total_length $total]
        }

        puts "" 
        
    }

    set table {}
    foreach l [lsort -real -inc [array names area_arr]] {
        lappend table $area_arr($l)
    }
    
    rls_table -table $table -header [list Layer "#ofNets" Area Length "#ofShapes"] -spac -breaks

}




proc ory_calc_net_area_2 { {nets ""}} {
    
    if { $nets == "" } { set nets [get_nets -hier] } 
    set nets [get_db $nets]
    
    if { ![is_attribute -obj net  be_net_area] } { define_attribute be_net_area -category be_user_attributes -data_type string  -obj_type net -default "" }
    set_db $nets .be_net_area ""
    
    set total [llength $nets]
    set current 0
    
    array unset total_area_arr

    if { [llength [set swires [get_db $nets .special_wires]]] == 0 && [llength [set wires [get_db $nets .wires]]] == 0 } { set_db $nets .be_net_area 0 ; continue }        
    set layers [lsort -u [get_db [concat $wires $swires] .layer.name]]
        
    array unset area_arr


    foreach net $nets {
        array unset net_area_arr

        ory_progres $current $total
        incr current 
        
        if { [llength [set swires [get_db $net .special_wires]]] == 0 && [llength [set wires [get_db $net .wires]]] == 0 } { set_db $net .be_net_area 0 ; continue }        
        foreach layer [set layers [lsort -u [get_db [concat $wires $swires] .layer.name]]] { set net_area_arr($layer) 0 }
        
        set detailed_area ""
        
        foreach layer $layers {

            if { [llength [set lswires [get_db [get_db $net .special_wires] -if .layer.name==$layer]]] > 0 } {
                set net_area_arr($layer) [lsum [get_db $lswires .area]]
            } 
            
            if { [llength [set lwires  [get_db [get_db $net .wires]         -if .layer.name==$layer]]] > 0 } {
                set begin_ext [get_db $lwires .begin_extension]
                set end_ext   [get_db $lwires .end_extension]        
                set length    [get_db $lwires .length]   
                set width     [get_db $lwires .width]                        

                foreach be $begin_ext ee $end_ext l $length w $width {
                    set net_area_arr($layer) [expr $net_area_arr($layer) + $w * ($be + $l + $ee)]         
                }
            }            
        }
        
        foreach layer [array names net_area_arr] { append detailed_area "{ $layer $net_area_arr($layer) } " }
        
        set_db $net .be_net_area [lsort -index 1 -real -dec $detailed_area]
    }

    puts ""
#
#    set table {}
#    foreach l [lsort -real -inc [array names area_arr]] {
#        lappend table $area_arr($l)
#    }
#    
#    rls_table -table $table -header [list Layer "#ofNets" Area Length "#ofShapes"] -spac -breaks

}



proc align_pins_b2i_wdef { b1 {abutted false} {force false} {placement_report ""} } {

    puts "-I- Alignning ports for $b1"
 
    ####################################
    # NDR_A width-depth table
    # TODO: Support more "width-depth" tables for different NDRs
    set pinWidth(M5)  0.038
    set pinWidth(M6)  0.08
    set pinWidth(M7)  0.076
    set pinWidth(M8)  0.08
    set pinWidth(M9)  0.076
    set pinWidth(M10)  0.08
    set pinWidth(M11)  0.076
    set pinWidth(M12)  0.062
    set pinWidth(M13)  0.062
    set pinWidth(M14)  0.126
    set pinWidth(M15)  0.126
    set pinWidth(M16)  0.45
    set pinWidth(M17)  0.45

    set pinDepth(M5)  0.395
    set pinDepth(M6)  0.188
    set pinDepth(M7)  0.198
    set pinDepth(M8)  0.188
    set pinDepth(M9)  0.198
    set pinDepth(M10)  0.188
    set pinDepth(M11)  0.198
    set pinDepth(M12)  0.354
    set pinDepth(M13)  0.354
    set pinDepth(M14)  0.453
    set pinDepth(M15)  0.453
    set pinDepth(M16)  1.8
    set pinDepth(M17)  1.8
    ####################################
    
    set b1 [get_db [get_cells $b1] .name]
    
    set boundary  [lindex [get_db designs .boundary] 0]
    set bbox      [lindex [get_db designs         .bbox] 0]
    lassign $bbox xl yl xh yh
    set center    [list [expr ($xh+$xl)/2.0] [expr ($yh+$yl)/2.0]]
    
    set ports   [get_ports *]
    
    if { $force } { 
        puts "-I- Ignoring placement_report and aligning all b1 pins"
        set b1_pins [get_db [get_pins -of $b1] -if !.base_name=="*TEST*" ]

    } else {

        if { $placement_report == "" } {
            puts "-I- Running pin placement check"
            check_all_quad_cells [get_cells $b1] "" true
            set placement_report "reports/pin_alignment/alignment_report_[get_db [get_cells $b1] .name].rpt"
        }
        
        puts "-I- Extracting pins from placement_report"
        set b1_pins {}
        if { ![file exists $placement_report] } { puts "-E- Placement report file: $placement_report not exists" ; return }
        set fp [open $placement_report r]
        set fd [read $fp]
        close $fp

        foreach line [split $fd "\n"] {
            if { $line == "" || ![regexp " port" $line] } { continue }
            set spline [split [regsub -all " +" $line " "] " "]
            lassign $spline res type1 p1 type2 p2

            if { $type1 == "pin" } { set index 2 } elseif { $type2 == "pin" } { set index 4 } { puts "-E- Something is wrong in \"align_pins_b2i $b1\"" ; return }
            lappend b1_pins [lindex $spline $index]
        } 
        puts "-I- Found [llength $b1_pins] pins"
        if { [llength $b1_pins] == 0 } { return }
        set b1_pins [get_pins $b1_pins]
        
    }
    
    set ports_nets   [get_nets [get_db $ports   .net]]
    set b1_nets      [get_nets [get_db $b1_pins .net]]
    set common_nets  [get_db [common_collection $b1_nets $ports_nets] -if .num_connections==2]
    set common_ports [get_ports -of $common_nets]

#    echo " " > tmp_def_file.def
    set counter 0
    set def_body ""
    foreach net $common_nets {
        
	    set pins   [all_connected -leaf $net]
        set b1_pin [get_db $pins -if .name==*$b1/*]
        set b2_pin [get_db $pins -if .obj_type=="*port*"]
        
        set b1_pin_loc [lindex [get_db $b1_pin .location]  0]
        set b1_rect    [lindex [get_db $b1_pin .base_pin.physical_pins.layer_shapes.shapes.rect] 0]
        set b1_ll      [list [lindex $b1_rect 0] [lindex $b1_rect 1]]
        set b1_dx      [expr [lindex $b1_rect 2] - [lindex $b1_rect 0]]
        set b1_dy      [expr [lindex $b1_rect 3] - [lindex $b1_rect 1]]
        set b2_dir     [get_db $b2_pin .direction]
        set b2_clk     [get_db $b2_pin .is_clock_used_as_clock]
        
        if { $b2_dir == "in" } {
            set direction "INPUT"
        } elseif { $b2_dir == "out" } {
            set direction "OUTPUT"
        } else {
            set direction "INOUT"
        }
        
        if { $b2_clk } { set use "CLOCK" } { set use "SIGNAL" }
        
        set route_index [get_db $b1_pin .layer.route_index]        
        set b2_pin_layer       [get_db $b1_pin .layer.name]        
        
        if { [expr $route_index%2] } { set coor_index 0 } { set coor_index 1 }
        
        # Find closest boundary
        set min_dist 999
        foreach coor $boundary { 
            set cur_side [lindex $coor $coor_index]
            set dist [expr abs($cur_side - [lindex $b1_pin_loc $coor_index])]
            if { $dist < $min_dist } { set min_dist $dist ; set side $cur_side }
        }
        
        if { $side < [lindex $center $coor_index] } {
            if { [expr $route_index%2] } { set orient "E" } { set orient "N" }
        } else {
            if { [expr $route_index%2] } { set orient "W" } { set orient "S" }
        }

        if { $orient == "S" || $orient == "N" } {
            set width $pinWidth($b2_pin_layer)
            set depth $pinDepth($b2_pin_layer)
            
            if { [expr $b1_dx - $width] == 0 } { set b1_dy $depth }
        
set new_line "- [get_db $b2_pin .name] + NET [get_db $b2_pin .net.name] + DIRECTION $direction + USE $use
  + LAYER $b2_pin_layer ( [expr int(-round($b1_dx*1000))] 0 ) ( [expr int(round($b1_dx*1000))] [expr int($b1_dy*2000)] )
  + PLACED ( [expr int(round(2000*[lindex $b1_pin_loc 0]))] [expr int(round(2000*$side))] ) $orient ;\n"
        } else {
            set width $pinWidth($b2_pin_layer)
            set depth $pinDepth($b2_pin_layer)
            
            if { [expr $b1_dy - $width] == 0 } { set b1_dx $depth }
        
set new_line "- [get_db $b2_pin .name] + NET [get_db $b2_pin .net.name] + DIRECTION $direction + USE $use
  + LAYER $b2_pin_layer ( [expr int(-round($b1_dy*1000))] 0 ) ( [expr int(round($b1_dy*1000))] [expr int($b1_dx*2000)] )
  + PLACED ( [expr int(2000*$side)] [expr int(round(2000*[lindex $b1_pin_loc 1]))] ) $orient ;\n"
        }

#        echo $new_line >> tmp_def_file.def
        append def_body $new_line
        incr counter
    }
    
    set one_port [index_collection [get_ports -of $common_nets ] 0]
    so $one_port
    write_def -selected def_for_header.def
    
    set line [lindex [split [exec grep -n "PINS " def_for_header.def] ":"] 0]
    set header [exec cat def_for_header.def | head -[expr $line-1]]
    
    mkdir -pv out/io_def_files
    set fp [open out/io_def_files/${b1}_align_to_io.def w]
    puts $fp $header
    puts $fp "PINS $counter ;"
    puts $fp $def_body
    puts $fp "END PINS\nEND DESIGN\n"
    close $fp
    
    read_def   out/io_def_files/${b1}_align_to_io.def 

    check_all_quad_cells [get_cells $b1] "" true    
}

proc get_design_route_status { {nets ""} } {
    
    if { $nets == "" } { set all_nets [get_nets -hier] } { set all_nets [get_nets -hier $nets] }
    set total    [llength [get_db -uniq $all_nets]]
    set routed   [get_db -uniq $all_nets -if .wires.status=="routed"||.special_wires.status=="routed"]
    set fixed    [get_db -uniq $all_nets -if .wires.status=="fixed"||.special_wires.status=="fixed"]
    set unkno    [get_db -uniq $all_nets -if .wires.status=="unknown"||.special_wires.status=="unknown"]
    
    puts "-I- Design Route Status:"
    puts "    ------------------- "
    puts "-I- Total number of nets    : [format "%10d" $total]"
    if { $total == 0 } { return }
    puts "-I- Total number of routed  : [format "%10d" [llength $routed]]  ; [format "%.2f" [expr 100.0*[llength $routed]/$total]]%"
    puts "-I- Total number of fixed   : [format "%10d" [llength $fixed]]  ; [format "%.2f" [expr 100.0*[llength $fixed]/$total]]%"
    puts "-I- Total number of unknown : [format "%10d" [llength $unkno]]  ; [format "%.2f" [expr 100.0*[llength $unkno]/$total]]%"        
    
    if { $nets != "" } { return [list $routed $fixed $unkno] }
    
}


proc get_pins_dens {direction {bbox ""} {is_print false}} {
    
    if { $bbox == "" } {
        puts "-?- Selecte bbox in gui"
        set bbox [gui_get_box]
        lassign $bbox x0 y0 x1 y1
        set bbox [list [expr min($x0,$x1)] [expr min($y0,$y1)] [expr max($x0,$x1)] [expr max($y0,$y1)]]
        puts "-I- Running on bbox: $bbox"
        set is_print true
    }
    
    lassign $bbox xl yl xh yh
    
    set pins_within [get_pins_within $bbox]
    
    if { $direction == "h" } { 
        set layers [list M2 M4 M6 M8 M10 M12 M14 M16] 
        set total_dist [expr $yh - $yl]
    } else { 
        set layers [list M1 M3 M5 M7 M9 M11 M13 M15] 
        set total_dist [expr $xh - $xl]
    }
     
    array set tracks_per_um_arr {M1 29.41 M3 23.81 M5 13.16 M7 13.16 M9  13.16 M11 13.16 M13 7.52 M15 3.76 \
                                 M2 28.57 M4 23.81 M6 12.50 M8 12.50 M10 12.50 M12 7.94  M14 3.97 M16 0.99}
    array unset res_arr
    foreach layer $layers {
        set layer_pins [get_db $pins_within -if .layer.name==$layer]
        set res_arr($layer:count)     [llength $layer_pins]
        set res_arr($layer:tracks)    [expr floor($tracks_per_um_arr($layer)*$total_dist)]
        set res_arr($layer:pg_tracks) [get_pg_tracks_within $bbox $layer]
        set res_arr($layer:util)      "[format "%.2f" [expr 100.0*$res_arr($layer:count)/($res_arr($layer:tracks) - $res_arr($layer:pg_tracks))]]%"
    }
    
    if { $is_print } { parray res_arr }
    
    return [array get res_arr]
    
}

proc ory_update_macros { base_cells dir } {
    
    foreach macro [get_db $base_cells .name] { 
        if { [glob -nocomp $dir/${macro}*lef] == {} } { puts "-W- File $dir/${macro}*lef not found" ;  continue }
        set cmd "update_lef_macro [glob $dir/${macro}*lef] -macros $macro" ; puts "-I- Running: $cmd"; eval $cmd 
    }
    
}

proc show_star_short { star_line } {
    
    set spline [split $star_line " "]
    set net1    [lindex $spline 3]
    set net2    [lindex $spline 6]
    set layer   [lindex $spline 9]
    set raw_box [lindex $spline 10]
    
}


proc ory_show_gui {} {
    gui_show
    set_layer_preference node_layer -is_visible 0
}

proc get_p2p_nets { nets } {
    
    set nets [get_nets $nets]
    set curr 1
    set total [sizeof $nets]
    
    if { $total == 0 } { puts "-E- No nets accepted for p2p check (get_p2p_nets)" ; return 1 }
    set p2p_nets {}
    array unset p2p_arr 
    foreach_in_collection net $nets {

        ory_progress $curr $total
        incr curr

        if { ![llength [set drv [get_db $net .driver_pins]]] } { set drv [get_db $net .driver_ports] }
        if { ![llength [set rcv [get_db $net .load_pins  ]]] } { set rcv [get_db $net .load_ports] }

        if { [llength [concat $drv $rcv]] != 2 } { continue }
        
        if { [compare_pins $drv $rcv] != "true" } { continue }
        
        set drv_layer [get_db $drv .layer.name]
        
        append_to_collection p2p_nets $net
        set p2p_arr([get_db $net .name]) $drv_layer
        
    }
    puts ""
    puts "-I- Out of [sizeof $nets] / [sizeof $p2p_nets] ([format "%.2f" [expr 100.0 * [sizeof $nets] / [sizeof $p2p_nets]]]%) nets are p2p. (get_p2p_nets)"
    return [array get p2p_arr]
}

proc set_net_man_dist { {nets {}} } {

    if { ![is_attribute -obj_type net be_man_dist] } {
        define_attribute be_man_dist -category be_user_attributes -data_type double  -obj_type net -default -1
    }
    
    foreach net [get_db [get_nets $nets ]] {
        set man_dist [expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $net] .location.y]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $net] .location.y]] 0] \
              + [lindex [lsort -real -incr [get_db [all_connected -leaf $net] .location.x]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $net] .location.x]] 0]]
        set_db $net .be_man_dist $man_dist
    }

}

proc _be_route_p2p { nets } {
    
    array unset p2p_arr
    array set   p2p_arr [get_p2p_nets $nets]
    
    delete_routes -net [array names p2p_arr]

    puts "-I- Calc nets man dist"    
    set_net_man_dist [get_db nets [array names p2p_arr]]
    set nets2route [get_db [get_db nets [array names p2p_arr]] -if .be_man_dist>0]
    set curr 1
    set total [llength $nets2route]
    set cmd ""    
    puts "-I- Out of [llength [array names p2p_arr]] / [llength $nets2route] are longer the 0um"
    
    foreach net $nets2route {

        ory_progress $curr $total
        incr curr

        if { [set route_rule [get_db $net .route_rule.name]] == "" } { set route_rule "DEFAULT" }
        set layer $p2p_arr([get_db $net .name])

        set drv [get_db $net .drivers]
        set rcv [get_db $net .loads]
        
        if { [get_db $drv .obj_type] == "port" || [get_db $rcv .obj_type] == "port" } { continue }
        
        set drv_loc [lindex [get_db $drv .location] 0]
        set rcv_loc [lindex [get_db $rcv .location] 0]
        
        set drv_pp  [lindex [get_db $drv .base_pin.physical_pins.layer_shapes.shapes.rect] 0]
        set rcv_pp  [lindex [get_db $rcv .base_pin.physical_pins.layer_shapes.shapes.rect] 0]
        
        set drv_dx  [expr abs([lindex $drv_pp 0] - [lindex $drv_pp 2]) / 2]
        set drv_dy  [expr abs([lindex $drv_pp 1] - [lindex $drv_pp 3]) / 2]
        set rcv_dx  [expr abs([lindex $rcv_pp 0] - [lindex $rcv_pp 2]) / 2]
        set rcv_dy  [expr abs([lindex $rcv_pp 1] - [lindex $rcv_pp 3]) / 2]
        
        lassign $drv_loc drvx drvy
        lassign $rcv_loc rcvx rcvy
        
        # Determine start and end points
        if       { $drvx == $rcvx && $drvy > $rcvy } {
            set start [list $drvx [expr $drvy + $drv_dy]]
            set end   [list $rcvx [expr $rcvy - $rcv_dy]]
        } elseif { $drvx == $rcvx && $drvy < $rcvy } {
            set start [list $drvx [expr $drvy - $drv_dy]]
            set end   [list $rcvx [expr $rcvy + $rcv_dy]]
        } elseif { $drvx > $rcvx && $drvy == $rcvy } {
            set start [list [expr $drvx + $drv_dx] $drvy]
            set end   [list [expr $rcvx - $rcv_dx] $rcvy]
        } elseif { $drvx < $rcvx && $drvy == $rcvy } {
            set start [list [expr $drvx - $drv_dx] $drvy]
            set end   [list [expr $rcvx + $rcv_dx] $rcvy]
        } else {
            puts "-E- Something is wrong... (_be_route_p2p)" ; return
        }
        
        set cmd "set_db edit_wire_type regular
        set_db edit_wire_nets [get_db $net .name]
        set_db edit_wire_create_crossover_vias {0}
        set_db edit_wire_layer_vertical   $layer
        set_db edit_wire_layer_horizontal   $layer
        set_db edit_wire_rule $route_rule
        set_db edit_wire_drc_on {0}
        edit_add_route_point $start
        edit_end_route_point $end
        "
        eval $cmd
        append cmds $cmd
#        eval $settings
#        edit_add_route_point $drv_loc
#        edit_end_route_point $rcv_loc
    }
    #eval $cmds
    puts "[get_design_route_status]"

}

proc set_ndr_pin_const {} {
    
    array unset pinWidth
    array unset pinDepth
    
    ####################################
    # NDR_A width-depth table
    # TODO: Support more "width-depth" tables for different NDRs
    set pinWidth(NDR_A:M5)  0.038
    set pinWidth(NDR_A:M6)  0.08
    set pinWidth(NDR_A:M7)  0.076
    set pinWidth(NDR_A:M8)  0.08
    set pinWidth(NDR_A:M9)  0.076
    set pinWidth(NDR_A:M10)  0.08
    set pinWidth(NDR_A:M11)  0.076
    set pinWidth(NDR_A:M12)  0.062
    set pinWidth(NDR_A:M13)  0.062
    set pinWidth(NDR_A:M14)  0.126
    set pinWidth(NDR_A:M15)  0.126
    set pinWidth(NDR_A:M16)  0.45
    set pinWidth(NDR_A:M17)  0.45

    set pinDepth(NDR_A:M5)  0.395
    set pinDepth(NDR_A:M6)  0.188
    set pinDepth(NDR_A:M7)  0.198
    set pinDepth(NDR_A:M8)  0.188
    set pinDepth(NDR_A:M9)  0.198
    set pinDepth(NDR_A:M10)  0.188
    set pinDepth(NDR_A:M11)  0.198
    set pinDepth(NDR_A:M12)  0.354
    set pinDepth(NDR_A:M13)  0.354
    set pinDepth(NDR_A:M14)  0.453
    set pinDepth(NDR_A:M15)  0.453
    set pinDepth(NDR_A:M16)  1.8
    set pinDepth(NDR_A:M17)  1.8
    ####################################
    
    foreach rule_layer [array names pinWidth] {
        
        set width $pinWidth($rule_layer)
        set depth $pinDepth($rule_layer)
        set layer [lindex [split $rule_layer ":"] 1]
        set rule  [lindex [split $rule_layer ":"] 0]
        
        set ports [get_db ports -if .width==$width&&.layer.name==$layer]
        
        set cmd "set_pin_constraint -cell [get_db designs .name] -pins \{[get_db $ports .name]\} -width $width -depth $depth"
        puts "-I- Setting pin constraints for: [llength $ports] in layer $layer with rule $rule"
        eval $cmd
        
    }

}

proc be_slacks_awk { file } {
    
    if { [file exists $file] } {
        exec gawk -f ./scripts/bin/slacks.awk $file > ${file}.summary
    } elseif { [file exists ${file}.gz] } {
        exec zcat ${file}.gz | gawk -f ./scripts/bin/slacks.awk > ${file}.summary
    } else {
        puts "-E- File $file OR ${file}.gz not found"
        return -1
    }
    
}

proc report_timing_paths_vt { tps {bin 0.030}} {
    
    set min_slack [lindex [lsort -incr -real [get_db $tps .slack]] 0]
    set max_slack [lindex [lsort -incr -real [get_db $tps .slack]] end]
    set num_path  [sizeof $tps]
    
    puts "-D- Min: $min_slack ; Max: $max_slack ; Num: $num_path"
    
    set table  {}
    set form   {%s %9s %9s %6s %6s %6s %6s %6s %6s %10s %10s %10s %10s %10s %10s}
    set header {Slack_Bin NumPaths NumCells SN LL LN UL UN EN SNA LLA LNA ULA UNA ENA}
    set current_min_slack $min_slack
    set current_max_slack $min_slack
    while {$current_max_slack <= [expr $max_slack + $bin/2.0] } {
        set current_prev_slack [format "%.3f" $current_max_slack  ]
        set current_min_slack  [format "%.3f" $current_prev_slack ]
        set current_max_slack  [format "%.3f" [expr $current_min_slack + $bin] ]
        
        if { $current_min_slack < 0 && $current_max_slack > 0 } { set current_max_slack 0.000 }
        if { $current_max_slack > 0.5 } { set bin [expr $bin*2] }
        
        set paths  [get_db $tps -if .slack>=$current_min_slack&&.slack<$current_max_slack]
        puts "-D- Found [llength $paths] paths between $current_min_slack to $current_max_slack"
        
        if { [llength $paths] == 0 } { continue }
        
        set cells [get_cells [get_db [get_db -uniq [get_db [get_db -uniq $paths  .timing_points.pin] -if .obj_type==pin] .inst] -if .is_flop==false]]
        redirect garbage { set vt_res [be_report_cells_vt -cells $cells -return] }
        
        set sn  [lindex [lindex $vt_res 0] 4]
        set sna [lindex [lindex $vt_res 0] 3]
        set ll  [lindex [lindex $vt_res 1] 4]
        set lla [lindex [lindex $vt_res 1] 3]
        set ln  [lindex [lindex $vt_res 2] 4]
        set lna [lindex [lindex $vt_res 2] 3]
        set ul  [lindex [lindex $vt_res 3] 4]
        set ula [lindex [lindex $vt_res 3] 3]
        set un  [lindex [lindex $vt_res 4] 4]
        set una [lindex [lindex $vt_res 4] 3]
        set en  [lindex [lindex $vt_res 5] 4]
        set ena [lindex [lindex $vt_res 5] 3]
        
        set new_line [list "$current_min_slack - $current_max_slack" [llength $paths] [sizeof $cells] \
                      $sn $ll $ln $ul $un $en $sna $lla $lna $ula $una $ena]
                      
        lappend table $new_line
        
    }
    
    rls_table -table [ory_sum_table $table] -header $header -breaks -spac -format $form
    
}


proc ory_get_points_dist { points_list } {
    
#    if { [llength $points_list] < 2  } { return 0 }    
    set total_dist 0
    for { set i 0 } { $i < [expr [llength $points_list] - 1] } { incr i } {
        set p1 [lindex $points_list $i]
        set p2 [lindex $points_list $i+1]
        set dist [expr abs([lindex $p1 0] - [lindex $p2 0]) + abs([lindex $p1 1] - [lindex $p2 1])]
        set total_dist [expr $total_dist + $dist]
    }
    
    return $total_dist
    
}

# Take PNR (awk) timing summary file, and compress it by replacing digits with *
# calculate_timing == run report_timing on eack compressed SP and EP which will result in more significant results, but with higher runtime
proc ory_compress_timing_sum { timing_sum_file {calculate_timing false} {max_paths 1000} {nworst 10} } {
    
    if { ![file exists $timing_sum_file] } { puts "-E- File $timing_sum_file not exists" ; return -1 }
    set fp [open $timing_sum_file r]
    set fd [split [read $fp] "\n"]
    close $fp
    
#    set sps [exec cat $timing_sum_file | awk {{print $3}} | sed -e {s/\([0-9]\+\)/*/g} | sort -u]
#    set eps [exec cat $timing_sum_file | awk {{print $3}} | sed -e {s/\([0-9]\+\)/*/g} | sort -u]
    array unset comp_arr
    foreach line $fd {
        
        if { $line == "" } { continue }
        
        set spline [split [regsub -all " +" [regsub -all "\\|" $line " "] " "] " "]
        lassign $spline slack sp spc ep epc
        
        set comp_sp [regsub -all "\[0-9\]+" $sp "*"]
        set comp_ep [regsub -all "\[0-9\]+" $ep "*"]
        set key     "$comp_sp:$comp_ep"
        
        lappend comp_arr($key) $slack
        
    }
    
    set table {}
    foreach key [array names comp_arr] {
        
        if { $key == ":" } { continue }
        lassign [split $key ":"] sp ep
        set slacks $comp_arr($key)
        if { $calculate_timing } {
            
            set tps [report_timing -from $sp -to $sp -max_paths $max_paths -nworst $nworst -collection -max_slack 0]
            set slacks [get_db $tps .slack]
                    
        }
        
        if { $slacks != {} } {
            set fep [llength $slacks]
            set tns [lsum $slacks]
            set wns [lindex [lsort -real -incr $slacks] 0]
        } else {
            set fep -1
            set tns 0
            set wns 0
        }

        set new_line [list $wns $tns $fep $sp $ep]
        lappend table $new_line
        
    }    
    
    set header {WNS TNS FEP STARPOINT ENDPOINT}
    set sorted_table [lsort -index 1 -real -incr $table]
    
    rls_table -spac -breaks -header $header -table $sorted_table
    
}


proc ory_report_bottleneck {args} {
    
    set th 5
    
    set cmd "report_timing -collection [join $args " "]"
    puts "-I- Runnin: $cmd"
    set tps [eval $cmd]
    
    if { [llength $tps ] == 0 } { return -1 }
    
    set nets [get_db [get_db [get_db -uniq $tps .timing_points.pin.net] -if .is_clock==false] .name]
    
    puts "-I- Calculating bottlenecks"
    set table {}
    set total   [llength $nets]
    set current 0
    foreach net $nets {
        ory_progress $current $total
        incr current
        
        if { [catch {set net_tps [get_db $tps -if .timing_points.pin.net.name==$net]} res] } { puts "-W- No tps found for net $net" ; continue }
        set slacks  [get_db $net_tps .slack]
        set fep [llength $slacks]
        set tns [lsum $slacks]
        set wns [lindex [lsort -real -incr $slacks] 0]
        
        if { $fep < 0   } { puts "-D- Found 0 paths for net: $net" ; continue }
        if { $fep < $th } { continue }
        
        set new_line [list $wns $tns $fep $net]        
        lappend table $new_line
    }
    puts ""
    set header {WNS TNS FEP NET}
    set sorted_table [lsort -index 1 -real -incr $table]
    
    rls_table -spac -breaks -header $header -table $sorted_table
    
}

###### HN ADDITION, BELIEVING ONE DAY I WILL CLEAN UP AND SORT ALL OF THESE PROCS ANY WAY..
proc be_cts_name { {suffix ""} } {

    if { $suffix == "" } { puts "[report_cts_cell_name_info]"  ;  return }

    redirect __cts_name_f {puts "[report_cts_cell_name_info]"}
    set f [open __cts_name_f r]   ;   set cts_data [split [read $f] \n]   ;   close $f   ;   file delete __cts_name_f
    
    foreach res [lsearch -all -inline -regexp $cts_data "^\[ \]\*${suffix} "] {
        puts $res
    }
}


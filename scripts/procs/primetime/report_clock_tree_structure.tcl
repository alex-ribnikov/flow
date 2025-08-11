#################################################################################################################################################################################
#	 																					#
#	report_clock_tree_structure	 																	#
#	 																					#
#	 																					#
#################################################################################################################################################################################
proc rcts_print_level {IN_PIN OUT_PIN LEVEL {DELAY false} {ARRIVAL false} {SINK_ONLY false} {PHYSICAL false} {VERBOSE false} {END_AT 1000000000}} {
	if {$VERBOSE} {echo "OUT_PIN [get_object_name $OUT_PIN] ; LEVEL $LEVEL "}
	if {$VERBOSE} {echo "all_fanout size: [sizeof_collection [all_fanout -from [get_object_name $OUT_PIN] -levels 1]] "}
	if {$LEVEL == $END_AT} {echo "end" ; return}

	if {[sizeof_collection [all_fanout -from [get_object_name $OUT_PIN] -levels 1]] > 1} {
		if {$VERBOSE} {echo "fanout larger than 1"}
		if {$PHYSICAL}  {
			if {[get_attribute $OUT_PIN object_class] == "clock"} {
			    set physical "([expr [get_attribute [get_attribute $OUT_PIN sources] x_coordinate]/1000] [expr [get_attribute [get_attribute $OUT_PIN sources] y_coordinate]/1000])"
			} else {
			    set physical "([expr [get_attribute $OUT_PIN x_coordinate]/1000] [expr [get_attribute $OUT_PIN y_coordinate]/1000])"
			}
		} else {
			set physical ""
		}
		if {[get_attribute $OUT_PIN object_class] == "pin"} {
			if {$VERBOSE} {echo "OUT_PIN is pin "}
			set CELL_NAME [get_attribute  [get_attribute   [get_pins $OUT_PIN] cell] original_ref_name] 
			if {$ARRIVAL} {set arrival_time "([get_attribute   [get_pins $OUT_PIN] max_arrival])" } else {set arrival_time ""}
			if {$DELAY && $IN_PIN != "none"}   {
				set delay_time   " ([expr [get_attribute   [get_pins $OUT_PIN] max_arrival] - [get_attribute   [get_pins $IN_PIN] max_arrival]])"
			} else {set delay_time ""}
			
		} elseif {[get_attribute $OUT_PIN object_class] == "port"} {
			if {$VERBOSE} {echo "OUT_PIN is port "}
			set CELL_NAME [get_object_name $OUT_PIN] 
			if {$ARRIVAL} {set arrival_time "([lindex [get_attribute   [get_ports $OUT_PIN] arrival_window] end end end end])" } else {set arrival_time ""}
			if {$DELAY && $IN_PIN != "none"}   {
				set delay_time   " ([expr [lindex [get_attribute   [get_ports $OUT_PIN] arrival_window] end end end end] - [lindex [get_attribute   [get_ports $IN_PIN] arrival_window] end end end end]]("
			} else {set delay_time ""}
		} else {
			set delay_time ""
			set arrival_time ""
			set CELL_NAME ""
		}
		if {$SINK_ONLY == "false"} {puts "[string repeat " " [expr $LEVEL * 4]]$LEVEL${delay_time} $arrival_time [get_object_name $OUT_PIN] ($CELL_NAME) $physical"}
		
#		foreach_in_collection VALUE [all_fanout -from [get_object_name $OUT_PIN] -levels 1] {}
		if {[get_attribute $OUT_PIN object_class] == "clock"} {
			set OUT_PIN [get_attribute  [get_clocks grid_clk] sources]
		}
		foreach_in_collection VALUE [all_connected -leaf [get_nets -of $OUT_PIN]] {
			if {$VERBOSE} {echo "VALUE [get_object_name $VALUE] ,OUT_PIN [get_object_name $OUT_PIN]"}
#			if {[get_attribute $VALUE direction] == "out" && [get_object_name $VALUE] != [get_object_name $OUT_PIN]} {}
			if {[get_attribute $VALUE direction] == "in" && [get_object_name $VALUE] != [get_object_name $OUT_PIN]} {
				if {$VERBOSE} {echo "rerun proc on in pin: rcts_print_level [get_object_name $VALUE] [expr $LEVEL+1] $ARRIVAL"}
				set OOO [get_pins -of_objects [get_cells -of $VALUE] -filter "direction == out"]
				if {[sizeof_collection $OOO] > 1} {
					set CELL_NAME [get_attribute  [get_attribute   [get_pins $VALUE] cell] original_ref_name] 
					if {$ARRIVAL} {set arrival_time "([get_attribute   [get_pins $VALUE] max_arrival])" } else {set arrival_time ""}
					if {$SINK_ONLY} {
						puts "[string repeat " " [expr ($LEVEL+1) * 1]][expr $LEVEL + 1] $arrival_time [get_object_name $VALUE] ($CELL_NAME) (sink) $physical"
					} else {
						puts "[string repeat " " [expr ($LEVEL+1) * 4]][expr $LEVEL + 1] $arrival_time [get_object_name $VALUE] ($CELL_NAME) (sink) $physical"
					}
				} else {
					rcts_print_level $VALUE $OOO [expr $LEVEL+1] $DELAY $ARRIVAL $SINK_ONLY $PHYSICAL $VERBOSE $END_AT
				}
			} elseif {[get_attribute $VALUE direction] == "out" && [get_object_name $VALUE] != [get_object_name $OUT_PIN]} {
				# this is an output port
				if {$VERBOSE} {echo "rerun proc on output port: rcts_print_level [get_object_name $VALUE] [expr $LEVEL+1] $ARRIVAL"}
				rcts_print_level none $VALUE [expr $LEVEL+1] $DELAY $ARRIVAL $SINK_ONLY $PHYSICAL $VERBOSE $END_AT
			}
		}
		return
	} else {
#		puts "$LEVEL [string repeat " " [expr $LEVEL * 3]] $OUT_PIN (sink)"
		if {$PHYSICAL}  {set physical "([expr [get_attribute $OUT_PIN x_coordinate]/1000] [expr [get_attribute $OUT_PIN y_coordinate]/1000])"} else {set physical ""}
		if {[get_attribute $OUT_PIN object_class] == "pin"} {
			set CELL_NAME [get_attribute  [get_attribute   [get_pins $OUT_PIN] cell] original_ref_name] 
			if {$ARRIVAL} {set arrival_time "([get_attribute   [get_pins $OUT_PIN] max_arrival])" } else {set arrival_time ""}
		} elseif {[get_attribute $OUT_PIN object_class] == "port"} {
			set CELL_NAME [get_object_name $OUT_PIN] 
			if {$ARRIVAL} {set arrival_time "([lindex [get_attribute   [get_ports $OUT_PIN] arrival_window] end end end end])" } else {set arrival_time ""}
		} else {
			set CELL_NAME ""
			set arrival_time ""
		}
		if {$SINK_ONLY} {
			puts "[string repeat " " [expr $LEVEL * 1]]$LEVEL $arrival_time [get_object_name $OUT_PIN] ($CELL_NAME) (sink) $physical"
		} else {
			puts "[string repeat " " [expr $LEVEL * 4]]$LEVEL $arrival_time [get_object_name $OUT_PIN] ($CELL_NAME) (sink) $physical"
		}
		return
	}
}

proc report_clock_tree_structure {args} {
	parse_proc_arguments -args $args options
	if {[info exists options(-from_clock) ]}    {set CLOCKS $options(-from_clock)} else {set CLOCKS [get_clocks]}
	if {[info exists options(-arrival) ]}       {set ARRIVAL true} else {set ARRIVAL false}
	if {[info exists options(-delay) ]}         {set DELAY true} else {set DELAY false}
	if {[info exists options(-sink_only) ]}     {set SINK_ONLY true} else {set SINK_ONLY false}
	if {[info exists options(-physical) ]}      {set PHYSICAL true} else {set PHYSICAL false}
	if {[info exists options(-verbose) ]}       {set VERBOSE true} else {set VERBOSE false}
	echo $DELAY
	# print header 
	puts "****************************************"
	puts "Report : report_clock_tree_structure"
	puts "   $args"
	puts "Design : [get_object_name [get_design]]"
	puts "[get_app_var sh_product_version]"
	puts "[date]"
	puts "****************************************"
	puts ""
	puts "---------------------------------------------------------------------------------------------------------------"
	foreach_in_collection CLK_col [get_clocks $CLOCKS] {
		puts ""
		puts "clock [get_object_name $CLK_col]"
		puts ""
		set ppp "level"
		if {$DELAY} {set ppp "$ppp (cell delay)"}
		if {$ARRIVAL} {set ppp "$ppp (arrival)"}
		set ppp "$ppp port/pin (ref_name)"
		puts $ppp
		puts "--------------------------------------------------"
		
		if {[sizeof_collection [get_attribute  [get_clocks $CLK_col] clock_network_pins -quiet]] > 0} {
			echo "rcts_print_level none $CLK_col 0 $DELAY $ARRIVAL $SINK_ONLY $PHYSICAL $VERBOSE"
			rcts_print_level none $CLK_col 0 $DELAY $ARRIVAL $SINK_ONLY $PHYSICAL $VERBOSE
		}
	}
	puts ""
}

define_proc_attributes report_clock_tree_structure \
	-info "report clock tree struction." \
  	-define_args {
    		{-from_clock "show report on those clocks" "" list {optional}}
    		{-arrival "add max arrival time to each level" "" boolean {optional}}
    		{-delay   "add cell delay time to each level" "" boolean {optional}}
    		{-sink_only "print sink only." "" boolean {optional}}
     		{-physical "print physical location." "" boolean {optional}}
    		{-verbose "debug flow." "" boolean {optional}}
    	}


proc report_row {} {
    puts "-I- PinName | max_rise_arrival | sizeof_afi | Driver'sLoad"
    for {set i 0 } { $i < 8 } { incr i } { 
        t  [get_pins *r$i*/grid_clk]  max_rise_arrival \
                                      {sizeof [all_fanin -to $o -flat -only]} \
                                      {get_att [get_pins -of [get_nets -of $o] -filter direction==out] effective_capacitance_max }
    }
    
    set prev -1        
    set diff 0
    for {set i 7 } { $i >= 0 } { incr i -1 } {        
        set max_arrs    [get_attribute [get_pins *cluster*r$i*/grid_clk] max_rise_arrival]
        set avg_max_arr [expr [lsum $max_arrs]/[llength $max_arrs]]
        set min_max_arr [lindex [lsort -incr -real $max_arrs] 0]
        set max_max_arr [lindex [lsort -incr -real $max_arrs] end]
        
        set left_half {} ; set right_half {}
        for { set j 0 } { $j < 4 } { incr j } { append_to_collection left_half  [get_pins -quiet *cluster*r$i*c$j*/grid_clk ] }
        for { set j 4 } { $j < 8 } { incr j } { append_to_collection right_half [get_pins -quiet *cluster*r$i*c$j*/grid_clk ] }
        
        set left_avg  [format "%.3f" [expr [lsum [get_attribute $left_half max_rise_arrival]]/[sizeof $left_half]]]
        set right_avg [format "%.3f" [expr [lsum [get_attribute $right_half max_rise_arrival]]/[sizeof $right_half]]]
        
        if { $prev > 0 } { set diff [expr abs ($avg_max_arr - $prev)] }
        set prev $avg_max_arr
        
        puts "-I- Row $i avg max arrival \[ns\]: [format "%.3f" $avg_max_arr] (Left: $left_avg) (Right: $right_avg)\
 (min [format "%.3f" $min_max_arr]) (max [format "%.3f" $max_max_arr]) (Internal Skew [format "%.3f" [expr $max_max_arr - $min_max_arr]]) (R2R Skew [format "%.3f" $diff])"
    }
}

proc report_col {} {
    puts "-I- PinName | max_arrival | sizeof_afi | Driver'sLoad"
    for {set i 0 } { $i < 8 } { incr i } { 
        t  [get_pins *c$i*/grid_clk]  max_arrival \
                                      {sizeof [all_fanin -to $o -flat -only]} \
                                      {get_att [get_pins -of [get_nets -of $o] -filter direction==out] effective_capacitance_max }
    }
    
    set prev -1        
    set diff 0
    for {set i 7 } { $i >= 0 } { incr i -1 } {        
        set max_arrs    [get_attribute [get_pins *cluster*c$i*/grid_clk] max_rise_arrival]
        set avg_max_arr [expr [lsum $max_arrs]/[llength $max_arrs]]
        set min_max_arr [lindex [lsort -incr -real $max_arrs] 0]
        set max_max_arr [lindex [lsort -incr -real $max_arrs] end]
        
        set left_half {} ; set right_half {}
        for { set j 0 } { $j < 4 } { incr j } { append_to_collection left_half  [get_pins -quiet *cluster*r$i*c$j*/grid_clk ] }
        for { set j 4 } { $j < 8 } { incr j } { append_to_collection right_half [get_pins -quiet *cluster*r$i*c$j*/grid_clk ] }
        
        set left_avg  [format "%.3f" [expr [lsum [get_attribute $left_half max_rise_arrival]]/[sizeof $left_half]]]
        set right_avg [format "%.3f" [expr [lsum [get_attribute $right_half max_rise_arrival]]/[sizeof $right_half]]]
        
        if { $prev > 0 } { set diff [expr abs ($avg_max_arr - $prev)] }
        set prev $avg_max_arr
        
        puts "-I- Col $i avg max arrival \[ns\]: [format "%.3f" $avg_max_arr] (Left: $left_avg) (Right: $right_avg)\
 (min [format "%.3f" $min_max_arr]) (max [format "%.3f" $max_max_arr]) (Internal Skew [format "%.3f" [expr $max_max_arr - $min_max_arr]]) (R2R Skew [format "%.3f" $diff])"
    }
}

proc get_skew_hist { args } {
    

    
}

proc get_skews { args } {
    
    set cmd "get_timing_paths [join $args " "]"
    
    puts "-I- Running: $cmd"
    set tps [eval $cmd]
    
    set skews {}
    foreach_in_collection tp $tps {
        lappend skews [get_tp_skew $tp]
    }
    
    return $skews
    
}

proc get_tp_skew { tp } {
    
    set sp_latency [get_att $tp startpoint_clock_latency]
    set ep_latency [get_att $tp endpoint_clock_latency]
    set crpr       [get_att $tp common_path_pessimism]
    
    return [expr $sp_latency - $ep_latency - $crpr]
        
}












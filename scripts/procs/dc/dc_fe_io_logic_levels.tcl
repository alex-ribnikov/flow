proc dc_fe_io_logic_levels { stage } {
    set start_t [clock seconds]

    puts "-I- Grouping Paths"
    set reset true

    set in2reg_file [get_logic_levels -stage $stage  -group in2reg]
    exec cat $in2reg_file | tail -n +13 | sed {s/\[[0-9+]*\]/[*]/g} | sed {s/_[0-9+]*_/_*_/g} | sed {s/_[0-9+]*\//_*\//g} | tr -s { } | sort | uniq -c | sort -k4rn | sed {1i group_size Startpoints Endpoints Logic_levels} | column -t > ${in2reg_file}.vectorized        

    set reg2out_file [get_logic_levels -stage $stage -group reg2out]
    exec cat $reg2out_file | tail -n +13 | sed {s/\[[0-9+]*\]/[*]/g} | sed {s/_[0-9+]*_/_*_/g} | sed {s/_[0-9+]*\//_*\//g} | tr -s { } | sort | uniq -c | sort -k4rn | sed {1i group_size Startpoints Endpoints Logic_levels} | column -t > ${reg2out_file}.vectorized        
    set end_t [clock seconds]
    puts "-I- dc_fe_io_logic_levels rung for [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
    
    
    
}


proc get_logic_levels {args} {

    set PARAMS(-max_path) 20000
    set PARAMS(-nworst) 20
    #set PARAMS(-file_name) "report_input_logic_levels.rpt"
    set PARAMS(-group) "in2reg"
    #set PARAMS(-stage) "MUST"
    
    array set PARAMS $args

    set max_path $PARAMS(-max_path)
    set nworst $PARAMS(-nworst)

    set group $PARAMS(-group)
    if {[string match $group "in2reg"]} {
	set dir "input"
    } elseif {[string match $group "reg2out"]} {
	set dir "output"
    } else {
	return "Group define with -group is of wrong type. Can be in2reg or reg2out only"
    }

    
    if {![info exists PARAMS(-stage)]} {
	return "Stage must be defined. Please run with -stage"
    } else {
	set stage $PARAMS(-stage)
    }
    
    if {[info exists PARAMS(-file_name)]} {
	set fname $PARAMS(-file_name)
    } else {
	set fname "reports/${stage}_report_${dir}_logic_levels.rpt"
    }
    
    set fout [open $fname w]
    set w1 40
    set w2 180
    set w3 20
    
    # Make a nice header (with separator) for the table first
    set sep --[string repeat - $w1]---[string repeat - $w2]---[string repeat - $w3]
    
    puts $fout [format "%-*s %-*s %*s " $w1 "Startpoint" $w2 "Endpoint" $w3 "Levels of Logic"]
    puts $fout $sep

    if {[string match $group "in2reg"]} {
	set path_col [get_timing_paths -from [all_inputs] -max_paths $max_path -nworst $nworst]
    } elseif {[string match $group "reg2out"]} {
	set path_col [get_timing_paths -to [all_outputs] -max_paths $max_path -nworst $nworst]
    } else {
	return
    }
    foreach_in_collection pc $path_col  {
	set startpoint [get_object_name [get_attribute $pc startpoint]]
	set endpoint [get_object_name [get_attribute $pc endpoint]]
	set logic_depth [get_attribute $pc logic_depth]
	puts $fout [format "%-*s %-*s %*s" $w1 $startpoint $w2 $endpoint $w3 $logic_depth]
    }
    close $fout
    return $fname
}


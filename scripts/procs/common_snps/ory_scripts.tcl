if { [info exists sh_launch_dir] } {
source $sh_launch_dir/scripts/procs/common/parseOpt.tcl 
source $sh_launch_dir/scripts/procs/common/rls_table.tcl
} elseif { [file exists scripts/procs/common] } {
source scripts/procs/common/parseOpt.tcl 
source scripts/procs/common/rls_table.tcl
} else {
puts "-W- No scripts/procs/common/ found" 
return
}

proc be_report_attributes {obj {ptrn ".*"}} {
    global suppress_errors
    # Dont report the following error 
    suppress_message UID-95
    set uid_list "UID-125 UID-119 UID-445 UID-101"
    foreach uid $uid_list { lappend suppress_errors $uid }

    # Get all avaliable attribute in the current design
    set obj_class [lsort -u [get_attribute $obj object_class]]

    redirect -var att_list_txt  {list_attributes -class $obj_class -app -nos}
    set start [lsearch -all [split $att_list_txt "\n"] "Attribute ?ame*"]
    set att_list_split [lrange [split $att_list_txt "\n"] $start end]
    set att_list {}
    foreach line $att_list_split {lappend att_list [lindex $line 0]}
    set all_attr $att_list

    # Report attribute for each object
    echo "---------------------------------------------------"
    echo "Report attribute of: [get_object_name $obj]"

    # Getting attribute value - and if exist print it
    set record true
    foreach attr $all_attr {
        if { !$record } { continue }
        if { $attr == {} } { set record false ; continue } 
        if { ! [regexp $ptrn $attr] } { continue }
        redirect -var garbage {set attr_value [get_attribute -quiet $obj $attr]}
        if { $attr_value != "" } {
            echo "\t$attr \t $attr_value"
        } else { 
            #echo "-N- $attr $attr_value"
        }
    }
        
    
    # Report error again
    unsuppress_message UID-95
    foreach uid $uid_list { set suppress_errors [lminus $suppress_errors $uid] }
#    set suppress_errors [lreplace $suppress_errors [lsearch $suppress_errors UID-125] [lsearch $suppress_errors UID-125]]
    return
}




proc be_get_all_attributes { } {

    set res_attr {}

    redirect -variable all_attr {list_attributes -application }
    
    set in 0
    foreach attr_line [split $all_attr "\n"] {
        if { $in } {
            if { [regexp {^\-\-\-\-\-\-\-} $attr_line] } {
                set in 0
                continue
            }
            
            regexp {^[^ ]+} $attr_line attr
            if { [lsearch -exact $res_attr $attr] < 0 } {
                lappend res_attr $attr 
            }
            
        } elseif { [regexp {^\-\-\-\-\-\-\-} $attr_line] } {
            set in 1
        }
    }
    
    foreach ta [list capture_clock_paths \
                    clock_uncertainty \
                    clock_path \
                    crpr_common_point \
                    crpr_value \
                    endpoint \
                    endpoint_clock \
                    endpoint_clock_close_edge_type \
                    endpoint_clock_close_edge_value \
                    endpoint_clock_is_inverted \
                    endpoint_clock_is_propagated \
                    endpoint_clock_latency \
                    endpoint_clock_open_edge_type \
                    endpoint_clock_open_edge_value \
                    endpoint_clock_pin \
                    endpoint_hold_time_value \
                    endpoint_is_level_sensitive \
                    endpoint_output_delay_value \
                    endpoint_recovery_time_value \
                    endpoint_removal_time_value \
                    endpoint_setup_time_value \
                    hierarchical \
                    launch_clock_paths \
                    object_class \
                    path_group \
                    path_type \
                    points \
                    scenario \
                    slack \
                    startpoint \
                    startpoint_clock \
                    startpoint_clock_is_inverted \
                    startpoint_clock_is_propagated \
                    startpoint_clock_latency \
                    startpoint_clock_open_edge_type \
                    startpoint_clock_open_edge_value \
                    startpoint_input_delay_value \
                    startpoint_is_level_sensitive \
                    time_borrowed_from_endpoint \
                    time_lent_to_startpoint ] {
        lappend res_attr $ta
    }


    return [lsort $res_attr]
}

### TODO: writes a reports to parse not annotated and summarize by hierarchy/bus
proc be_reports_not_annotated_by_hier { pattern {file_name ""} } {

    set nets [get_nets -hier -filter full_name=~$pattern]
    set lim  [sizeof $nets] 
    
    report_annotated_parasitics -list_not_annotated -max $lim > reports/be_reports_not_annotated_by_hier.rpt.detailed
    
    set fp [open reports/be_reports_not_annotated_by_hier.rpt.detailed r]
    set fd [read $fp]
    
    foreach line [split $fd "\n"] {
        set spline [split $line " "]
        if {$line == "" || ![regexp "\[\]+." [lindex $spline 0] res]} { continue }
    }    
    
    
}


proc ory_pt_setup {} {

    alias fit "all_fanin -flat -trace_arcs timing -startpoints_only -to"
    alias fot "all_fanout -flat -trace_arcs timing -endpoints_only -from"
    alias timing_const "set timing_report_unconstrained_paths true"
    alias rpthr   "report_timing -nosplit -trans -pba ex -include_hierarchical_pins -input -nets -through"
    alias rptf    "report_timing -nosplit -trans -pba ex -include_hierarchical_pins -input -nets -from"
    alias rptt    "report_timing -nosplit -trans -pba ex -include_hierarchical_pins -input -nets -to"
    alias rpthrs  "report_timing -nosplit -trans -pba ex -include_hierarchical_pins -slack_lesser_than 10000 -input -nets -through"
    alias rptm    "report_timing -nosplit -include_hierarchical_pins -delay min"
    alias rpt     "report_timing -nosplit -include_hierarchical_pins"
    alias soc     "sizeof_collection"

}


proc t {args} {
    if {[llength $args]==0} {
        echo "Usage: t <collection> \[flags\] \[attribute name\] \[attribute name\] \[\{proc\}\] \[./file\] ..."
        echo "optional additional flags: return, nosort, noname, full_name, uniq\[c\]\[n\]\n\n";
        echo "procedure usage: must include a space! example: {return \[get_pins -of \$o\]}"
        echo "to write directly to a file, it must start with ./ or /, if the file ends with .csv it will be written as csv"
	return
    }
    
    set is_list false
    
    redirect -var garbage { if { [llength [get_attribute -quiet [lindex $args 0] object_class] ] == 0 } { set is_list true } }
    
    if { $is_list } { puts [join [lsort -dictionary [lindex $args 0]] "\n"] ; return }
    
    if {[llength $args]==1} {
        # quick print collection
        set table [list]
        foreach_in_collection o [lindex $args 0] {
            lappend table [get_object_name $o]
        }
        echo [join [lsort -dictionary $table] "\n"]
	return
    }
    # parse "command line"
    set table [list]
    set attrs [list]
    set doReturn 0  
    set doSort 1
    set noName 0
    set doUniq 0
    set doUniqCount 0
    set toFile ""
    array set UNIQ {}
    set header [list {Object Name}]
    set attrsData [list]
    foreach a [lrange $args 1 end] {
	if {$a=="return"} {
	    set doReturn 1
	} elseif {$a=="nosort"} {
	    set doSort 0
	} elseif {$a=="noname"} {
	    set noName 1
	} elseif {[regexp {^uniq(c)?(\d+)?$} $a -> count field]} {
	    set doUniq 1
	    if {$count=="c"} {set doUniqCount 1}
	    if {$field==""} {set field 0}
	    set uniqField $field
	} elseif {[regexp {^[\/\~\.]} $a]} {
	    set toFile $a
	} else {
	    if {$a=="full_name"} {set noName 1}
	    lappend attrs $a
	    if {[regexp {\s} $a]} {
		lappend header "proc[llength $attrs]"
	    } else {
		lappend header $a
	    }
	}
    }
    set col [lindex $args 0]
    if {$noName} {set header [lrange $header 1 end]}
    set soCol [sizeof_collection $col]
    # get attributes data
    foreach a $attrs {
	if {[regexp {\s} $a]} {
	    eval "proc temp_t_procedure {o} {$a}"
	    set data [list]
	    foreach_in_collection o $col {
		set v [eval {temp_t_procedure $o}]
		if {[regexp {^_sel\d+$} $v]} {
		    set v [get_object_name $v]
		}
		lappend data $v
	    }
	    lappend attrsData $data
	} else {
	    set data [get_attribute -quiet $col $a]
	    set need [expr {-[llength $data]}]
	    if {[llength $data]!=$soCol} {
		set data [list]
		foreach_in_collection o $col {
		    if {[expr {$need==0}]} {break}
		    set v [get_attribute -quiet $o $a]
		    if {$v!=""} {incr need}
		    lappend data $v
		}
	    }
	    lappend attrsData $data
	}
    }
    # transpose to table
    set oi 0
    foreach_in_collection o $col {
	set line [list]
	if {!$noName} {lappend line [get_object_name $o]}
	set ai 0
	foreach a $attrs {
	    lappend line [lindex [lindex $attrsData $ai] $oi]
	    incr ai
	}
	if {$doUniq} {
	    set val [lindex $line $uniqField]
	    if {[info exists UNIQ($val)]} {
		incr UNIQ($val)
		incr oi
		continue
	    }
	    set UNIQ($val) 1
	}
	incr oi
	lappend table $line
    }
    if {$doUniq && $doUniqCount} {
	# add uniq count
	for {set oi 0} {$oi<[llength $table]} {incr oi} {
	    set line [lindex $table $oi]
	    set val [lindex $line $uniqField]
	    lset table $oi [lreplace $line $uniqField $uniqField "$val ($UNIQ($val))"]
	}
    }
    # finish
    if {$doReturn} {return $table}
    if {$doSort} {set table [lsort -dictionary $table]}
    if {$toFile==""} {
	rls_table -header $header -table $table -spacious -breaks -no_sep
    } elseif {[regexp {\.csv$} $toFile]} {
	rls_table -header $header -table $table -file $toFile -csv_mode
    } else {
	rls_table -header $header -table $table -spacious -breaks -no_sep -file $toFile
    }
}


proc ory_pt_net_length { net } { 
    set x_max [lindex [get_att $net x_coordinate_max] 0]
    set x_min [lindex [get_att $net x_coordinate_min] 0]
    set y_max [lindex [get_att $net y_coordinate_max] 0]
    set y_min [lindex [get_att $net y_coordinate_min] 0]
    
    return [expr (abs( $x_max - $x_min ) + abs( $y_max - $y_min ))/1000] 
}



proc find_bad_skews { {paths {5000}} {from_clock {}} {to_clock {}} {pba_mode {path}} } {
    set table [list]
    if { [regexp setup $::check] } { set max_or_min max } else { set max_or_min min }
    redirect /dev/null {set tps [get_timing_paths -pba_mode $pba_mode -delay_type $max_or_min -max_paths $paths]}
    foreach_in_collection tp $tps {
        set slack         [format %.3f [get_attribute $tp slack]]
        set startpoint    [get_object_name [get_attribute $tp startpoint]]
        set endpoint      [get_object_name [get_attribute $tp endpoint]]
        set sp_type [get_attribute [get_attribute $tp startpoint] object_class]
        set ep_type [get_attribute [get_attribute $tp endpoint] object_class]
        if { [string equal $sp_type port] || [string equal $ep_type port] } { continue }

        set start_clock   [get_object_name [get_attribute $tp startpoint_clock]]
        set end_clock     [get_object_name [get_attribute $tp endpoint_clock]]

        if { $from_clock!="" } {
            if { $start_clock!=$from_clock } { continue }
        }
        if { $to_clock!="" } {
            if { $end_clock!=$to_clock } { continue }
        }
        set start_latency [format %.3f [get_attribute $tp startpoint_clock_latency]]
        set end_latency   [format %.3f [get_attribute $tp endpoint_clock_latency]]
        set diff [format %.3f [expr {$start_latency-$end_latency}]]

        if { [string equal $max_or_min min] } {
            set common_path_pessimisim [get_attribute $tp common_path_pessimism]
            set diff [format %.3f [expr {$diff-$common_path_pessimisim}]]
        }

        if { [string equal $max_or_min max] } {
            if { $start_latency>$end_latency } {
                lappend table "$slack $diff $start_latency $end_latency $start_clock $end_clock $startpoint $endpoint"
            }
        } else {
            if { $end_latency>$start_latency } {
                lappend table "$slack $diff $start_latency $end_latency $start_clock $end_clock $startpoint $endpoint"
            }
        }
    }
    rls_table -header {slack latency_diff start_latency end_latency start_clock end_clock startpoint endpoint} -table $table -breaks -spacious -file find_bad_skews.${::pvt}_${::rc}_${::check}.rpt
}


proc be_reprot_var { pattern } {
    set info_res [info var ::$pattern]
    
    set max_length 0
    array unset res_arr
    
    foreach var $info_res {
        if { [array exists $var] } {
            foreach name [array names $var] {
                redirect -var val {eval "echo -n \$$var\($name\)"}
                set res_arr(${var}\($name\)) $val
                
                if { [set new_length [string length "${var}\($name\)"]] > $max_length } { set max_length $new_length }
            }
        } else {
            redirect -var val {eval "echo -n \$$var"}
            set res_arr($var) $val
            
            if { [set new_length [string length ${var}]] > $max_length } { set max_length $new_length }            
        }
    }
    
    foreach name [array names res_arr] {
        puts "[format "%-${max_length}s" $name][format "%5s" " "]$res_arr($name)"
    }
}

proc avg_list { l } {
    
    if { [llength $l] == 0 } { return 0 }
    
    set s 0
    foreach v $l { set s [expr $s + $v] }
    
    return [expr 1.0*$s/[llength $l]]
    
}

proc list_stats {num_list} {
    # Verify that the list contains only numbers
    foreach num $num_list {
        if {! [string is double -strict $num]} {
            error "Input list contains non-numeric values"
        }
    }
    
    # Calculate average
    set sum 0
    foreach num $num_list {
        set sum [expr $sum + $num]
    }
    set avg [format "%.4f" [expr {$sum / [llength $num_list]}]]
    
    # Calculate min and max
    set min [format "%.4f" [lindex [lsort -real $num_list] 0]]
    set max [format "%.4f" [lindex [lsort -decreasing -real $num_list] 0]]
    
    # Calculate standard deviation and variance
    set sum_squares 0
    foreach num $num_list {
        set deviation [expr {$num - $avg}]
        set sum_squares [expr $sum_squares + {$deviation * $deviation}]
    }
    set variance [format "%.6f" [expr {$sum_squares / [llength $num_list]}]]
    set std_dev  [format "%.6f" [expr {sqrt($variance)}]]
    
    # Return results as a list
    return [list $avg $min $max $std_dev $variance]
}


proc get_net_max_delay { net } {
    
    set pins [all_connected -leaf $net]
    if { [sizeof $pins] < 2 } { return -1 }
    
    set drv [filter_collection $pins direction==out]
    set rcv [filter_collection $pins direction==in]
    
    set drv_arrs [get_attribute $drv max_arrival]
    set rcv_arrs [get_attribute $rcv max_arrival]
    
    if { [llength $drv_arrs] == 0 } { return -2 }
    if { [llength $rcv_arrs] == 0 } { return -3 }
    
    set drv_arr [avg_list $drv_arrs]
    set rcv_arr [avg_list $rcv_arrs]
    
    return [expr abs($rcv_arr - $drv_arr)]
}

proc pt_report_out_buffers {{ports ""}} {
    
    set outs [get_ports -filter direction==out]
    array unset out_bufs 
    array unset hier_cells_arr    
    set all_rns {}
        
    foreach p [get_object_name $outs] {
        set n [get_nets -of $p]
        set alc [get_pins -quiet [all_connected -leaf $n]]
        if { [sizeof $alc] == 0 } { continue }
        set cells [get_cells -of $alc] 
        set pc    [get_attribute -quiet $cells parent_cell]
        if { $pc == "" } { continue }
        set pc    [lsort -u [get_object_name $pc]]
        if { [llength $pc] > 1 } { continue }
        set out_bufs($p) [get_object_name $cells]
        lappend hier_cells_arr($pc) [get_attribute $cells ref_name]
        lappend all_rns [get_attribute $cells ref_name]
    }  
    
    set all_rns [lsort -u [join $all_rns " "]]
    set header [concat {Cell} $all_rns]
    set table {}

    foreach cell [lsort [array names hier_cells_arr]] {
        set buffers $hier_cells_arr($cell)
        set line [list $cell]
        foreach rn $all_rns {
            set search_res [lsearch -all $buffers $rn]
            if { $search_res == "-1" } { set res_num 0 } { set res_num [llength $search_res] }
            lappend line $res_num
        }
        lappend table $line
    }
    
    redirect reports/output_buffers_ref_name.rpt { rls_table -table $table -header $header -spac -breaks }
    
    set ins [get_ports -filter direction==in]
    array unset in_bufs 
    array unset hier_cells_arr    
    set all_rns {}
        
    foreach p [get_object_name $ins] {
        set n [get_nets -of $p]
        set alc [get_pins -quiet [all_connected -leaf $n]]
        if { [sizeof $alc] == 0 } { continue }
        set cells [get_cells -of $alc] 
        set pc    [get_attribute -quiet $cells parent_cell]
        if { $pc == "" } { continue }
        set pc    [lsort -u [get_object_name $pc]]
        if { [llength $pc] > 1 } { continue }
        set in_bufs($p) [get_object_name $cells]
        lappend hier_cells_arr($pc) [get_attribute $cells ref_name]
        lappend all_rns [get_attribute $cells ref_name]
    }  
    
    set all_rns [lsort -u [join $all_rns " "]]
    set header [concat {Cell} $all_rns]
    set table {}

    foreach cell [lsort [array names hier_cells_arr]] {
        set buffers $hier_cells_arr($cell)
        set line [list $cell]
        foreach rn $all_rns {
            set search_res [lsearch -all $buffers $rn]
            if { $search_res == "-1" } { set res_num 0 } { set res_num [llength $search_res] }
            lappend line $res_num
        }
        lappend table $line
    }
    
    
    redirect reports/input_buffers_ref_name.rpt { rls_table -table $table -header $header -spac -breaks }
}

proc _quad_get_tp_ports { tp } { 

}

proc _get_tp_skew { tp } {
    set skew [expr [get_attribute $tp endpoint_clock_latency] - [get_attribute $tp startpoint_clock_latency]]
    return $skew
}

proc get_skews { args } {

#    set cmd "set tps \[get_timing_paths $args\]"
    set filter  "full_name !~ $cell/TEST_* && full_name !~ $cell/*strap* && full_name !~ $cell/*dft_rst_n_override && full_name !~ $cell/*grid_rst_n"
    set exclude "$cell/nbus_to_west_nbus_valid__* $cell/east_dlink_to_dlink_ready* $cell/nbus_to_east_nbus_valid__* $cell/dlink_to_west_dlink_data__2* \
    $cell/cbus_to_east_valid* $cell/nbus_to_east_nbus_data_* $cell/west_to_cbus_ready* $cell/cbus_to_west_valid* $cell/cbus_to_east_data__* $cell/west_nbus_to_nbus_ready__* $cell/east_to_cbus_ready*"
    
    # TODO - divide the report to pairs of cells - nfi2cbue, nfi2cbui etc. Max 5000 tps per b2b. 
    
    if { [catch {eval $cmd} res] } { puts $res ; return -1 } 
    
    set skews {}
    foreach_in_collection tp $tps {        
        set skew [_get_tp_skew $tp]
        lappend skews $skew
    }
    
    return [list $tps $skews]    
}



proc report_net_bottleneck { {number_of_nets_to_return {5000}} {num_of_paths {25000}}  {nworst {25}} {scenario {}} } {
#    if { $scenario=="" } { set scenario ${::mode}_${::pvt}_${::rc}_$::check }
    set tps [get_timing_paths -max_paths $num_of_paths -nworst $nworst -delay_type max ]
    array unset violators_arr
    foreach_in_collection tp $tps {
        set slack [get_attribute -quiet $tp slack]
        if { $slack=="" } { continue }
        set slack  [format %.0f $slack]
        if { $slack>=0 } { continue }
        set points [get_attribute -quiet $tp points]
        if { [sizeof_collection $points]==0 } { continue }
        foreach_in_collection point $points {
            set object [get_attribute -quiet $point object]
            if { [sizeof_collection $object]==0 } { continue }
            set object_name [get_object_name $object]
            if { ! [info exists violators_arr($object_name)] } {
                #                                 TNS    WNS
                set violators_arr($object_name) "$slack $slack"
            } else {
                lassign $violators_arr($object_name) tns worst_slack
                set tns [expr {$tns+$slack}]
                set violators_arr($object_name) "$tns $worst_slack"
            }
        }
    }

    array unset nets_arr
    foreach violator [array names violators_arr] {
        set net [get_object_name [get_nets -of_objects $violator]]
        if { ! [info exists nets_arr($net)] } {
            set nets_arr($net) $violators_arr($violator)
        } else {
            lassign $violators_arr($violator) tns worst_slack
            lassign $nets_arr($net) ntns nwns
            set ntns [expr {$tns+$ntns}]
            if { $nwns>$worst_slack } { set nwns $worst_slack }
            set nets_arr($net) "$ntns $nwns"
        }
    }

    set table [list]
    foreach net [array names nets_arr] {
        lappend table [join "$nets_arr($net) $net"]
    }

    set sorted_table [lsort -real -increasing -index 0 $table]
    set report reports/report_net_bottleneck.rpt
    rls_table -header {TNS WNS NET} -table $sorted_table -breaks -spacious -file $report
    puts "-I- Report: $report"

    set i 1
    set nets2return [list]
    foreach line $sorted_table {
        set net [lindex $line 2]
        lappend nets2return $net
        if { $i>=$number_of_nets_to_return } {
            break
        } else {
            incr i
        }
    }
    return $nets2return
}

proc ory_report_hfn { {th 200} {nets ""} } {

    if { [info exists ::synopsys_program_name] && $::synopsys_program_name=="pt_shell"} {
        if { $nets == "" } {
            set nets [get_nets -hier -quiet -filter "number_of_leaf_loads>$th"]
        } else {
            set nets [get_nets -hier -quiet $nets -filter "number_of_leaf_loads>$th"]
        }
        t $nets number_of_leaf_loads is_clock_network
        puts "-I- Found total of [sizeof $nets] HFN"
        puts "-I- Out of which [sizeof [filter_collection $nets is_clock_network==true]] are clock nets"
    } else {
        if { $nets == "" } {
            set nets [get_nets -quiet -physical_context -filter "net_type!=power && net_type!=ground && number_of_flat_loads>$th"]
        } else {
            set nets [get_nets  -quiet $nets -filter "net_type!=power && net_type!=ground && number_of_flat_loads>$th"]
        }
        t $nets net_type dont_touch number_of_flat_loads {get_att [filter_collection [all_connected -leaf $o] direction==out] clocks}
    }

}





::parseOpt::cmdSpec be_report_cells_vt {
    -help "Base cells VT split"
    -opt {
        {-optname base_cells_pattern  -type string   -default ""    -required 0 -help "Base/lib cell pattern.  If both patterns are being used, inst prevail!"}
        {-optname insts_name_pattern  -type string   -default ""    -required 0 -help "Instances name pattern. If both patterns are being used, inst prevail!"}
        {-optname cells               -type string   -default ""    -required 0 -help "Cells to check. If both patterns and cells are being used, cells prevail!"}
        {-optname return_res          -type boolean  -default false -required 0 -help "Return table instead of print"}        
    }
}
proc be_report_cells_vt { args } {

    if { ! [::parseOpt::parseOpt be_report_cells_vt $args] } { return 0 }    

    set base_cells_pattern $opt(-base_cells_pattern)
    set insts_name_pattern $opt(-insts_name_pattern)    
    set cells $opt(-cells)

    if { $cells == "" && $insts_name_pattern != "" } {
        set cells      [get_cells -quiet -hier -filter "full_name=~$insts_name_pattern && is_hierarchical==false && is_memory_cell == false && number_of_pins >= 2"]
    } elseif { $cells == "" && $base_cells_pattern != "" } {
        set cells      [get_cells -quiet -hier -filter "is_hierarchical==false && ref_name=~$base_cells_pattern && number_of_pins >= 2"]
    } elseif { $cells == "" } {
      	set cells [get_cells -quiet -hier -filter "is_hierarchical==false && is_memory_cell == false && number_of_pins >= 2"]
    }

    array unset vt_rule_arr
    
    # Array name structure: arr(process:group_name) = pattern
    # SNPS
    set vt_rule_arr(snpsn5:0:svt)    "*SVT06*"
    set vt_rule_arr(snpsn5:1:lvt)    "*LVT06*"
    set vt_rule_arr(snpsn5:2:lvtll)  "*LVTLL06*"
    set vt_rule_arr(snpsn5:3:ulvt)   "*ULT06*"
    set vt_rule_arr(snpsn5:4:ulvtll) "*ULTLL06*"
    
    set vt_rule_arr(snpsn7:0:svt)    "*SVT*"
    set vt_rule_arr(snpsn7:1:lvt)    "*LVT*"
    set vt_rule_arr(snpsn7:2:ulvt)  "*ULT*"
    
    # TSMC
    set vt_rule_arr(tsmcn5:0:svt)    "*DSVT"
    set vt_rule_arr(tsmcn5:1:lvt)    "*DLVT"
    set vt_rule_arr(tsmcn5:2:lvtll)  "*DLVTLL"
    set vt_rule_arr(tsmcn5:3:ulvt)   "*DULVT"
    set vt_rule_arr(tsmcn5:4:ulvtll) "*DULVTLL"
    
    set vt_rule_arr(tsmcn7:0:svt)    "*DSVT"
    set vt_rule_arr(tsmcn7:1:lvt)    "*DLVT"
    set vt_rule_arr(tsmcn7:2:ulvt)   "*DULVT"    
    
    # BRCM
   set vt_rule_arr(brcmn7:0:svt)    "P6S*"
   set vt_rule_arr(brcmn7:1:lvt)    "P6L*"
   set vt_rule_arr(brcmn7:2:ulvt)   "P6U*"    
   
   set vt_rule_arr(brcmn5:0:SN)     "F6SN*"
   set vt_rule_arr(brcmn5:1:LL)     "F6LL*"
   set vt_rule_arr(brcmn5:2:LN)     "F6LN*"
   set vt_rule_arr(brcmn5:3:UL)     "F6UL*"	  
   set vt_rule_arr(brcmn5:4:UN)     "F6UN*"	  
   set vt_rule_arr(brcmn5:5:EN)     "F6EN*"  
	
    set vt_groups_list [list brcmn5 tsmcn5 snpsn5 brcmn7 tsmcn7 snpsn7]    
  
    ############################################################################
#	set node "n[get_db design_process_node]"
#    set process ""
#    foreach group [regexp -inline -all "\[a-zA-Z\]+$node" $vt_groups_list] {    
#        foreach sub_group [array names vt_rule_arr $group*] {            
#            if { [llength [get_lib_cells */$vt_rule_arr($sub_group)]] > 0 } { set process "[lindex [split $sub_group ":"] 0]" ; break }
#        }
#        if { $process != "" } { break }   
#    }

    set process "brcmn5"
    
#	set lib  [lindex [get_db [get_db [get_db lib_cells] .library] .files] 0]
#    if { [string match "*SNPS*" $lib] } {
#    	set vendor "snps"
#    } elseif { [string match "*BRCM*" $lib] } {
#    	set vendor "brcm"
#    } else {
#    	set vendor "tsmc"
#    }        
    
    if { $process == "" } { 
        puts "-E- Could not determine process"
        return -1
    }

    ############################################################################    

#    set total  [llength $base_cells]
#    set total_a [format "%.4f" [lsum [get_db $base_cells .area]]]         
    set total 0
    set total_a 0
    set remaining_cells $cells    
    array unset vt_cells_arr
    set table {}

    foreach key [lsort [array names vt_rule_arr *$process*]] {
    	
        set group [lindex [split $key ":"] end]

        set relevant_cells  [filter_collection $cells ref_name=~$vt_rule_arr($key)]
        set remaining_cells [remove_from_collection $remaining_cells $relevant_cells]
        
        set vt_cells_arr($group:cells)     $relevant_cells
        set vt_cells_arr($group:count)     [sizeof $vt_cells_arr($group:cells)]        
        set vt_cells_arr($group:count_pct) 0
        set areas [get_attribute -quiet $vt_cells_arr($group:cells) area]
        set vt_cells_arr($group:area)      [format "%.4f" [lsum $areas]] 
        set vt_cells_arr($group:area_pct)  0
        
        set total   [expr $total   + $vt_cells_arr($group:count)]
        set total_a [expr $total_a + $vt_cells_arr($group:area)]

    }

    if { [sizeof $remaining_cells] > 0 } {
        puts "-W- Found [sizeof $remaining_cells] cells with no VT afiiliation"
    }
    
    # Calc pct
    foreach key [lsort [array names vt_rule_arr *$process*]] {

        set group [lindex [split $key ":"] end]
        set vt_cells_arr($group:count_pct) "[format "%.2f" [expr  100.0 * $vt_cells_arr($group:count) / $total]]%"
        set vt_cells_arr($group:area_pct)  "[format "%.2f" [expr  100.0 * $vt_cells_arr($group:area) / $total_a]]%"

        lappend table [list $group $vt_cells_arr($group:count) $vt_cells_arr($group:count_pct) \
                                   $vt_cells_arr($group:area)  $vt_cells_arr($group:area_pct)]
    }
        
    lappend table [list "" "" "" "" ""]
    lappend table [list "Total" $total "" $total_a ""]
    
    if { $opt(-return_res) } { return $table }
    
    set header [list Type count pct area pct]
    rls_table -table $table -header $header -spac -breaks        
}


proc report_timing_paths_vt { tps {bin 0.030}} {
    
    set min_slack [lindex [lsort -incr -real [get_att $tps slack]] 0]
    set max_slack [lindex [lsort -incr -real [get_att $tps slack]] end]
    set num_path  [sizeof $tps]
    
    puts "-D- Min: $min_slack ; Max: $max_slack ; Num: $num_path"
    
    set table  {}
    set form   {%s %9s %9s %6s %6s %6s %6s %6s %6s %10s %10s %10s %10s %10s %10s}
    set header {Slack_Bin NumPaths NumCells SN LL LN UL UN EN SNA LLA LNA ULA UNA ENA}
    set current_min_slack $min_slack
    set current_max_slack $min_slack    
    while { $current_max_slack <= [expr $max_slack + $bin/2.0] } {
        set current_prev_slack [format "%.3f" $current_max_slack  ]
        set current_min_slack  [format "%.3f" $current_prev_slack ]
        set current_max_slack  [format "%.3f" [expr $current_min_slack + $bin] ]
        
        if { $current_min_slack < 0 && $current_max_slack > 0 } { set current_max_slack 0.000 }
        if { $current_max_slack > 0.5 } { set bin [expr $bin*2] }
        
        set paths  [filter_collection $tps  slack>=$current_min_slack&&slack<$current_max_slack]
        puts "-D- Found [sizeof $paths] paths between $current_min_slack to $current_max_slack"
        
        if { [llength $paths] == 0 } { continue }
        
        set cells [get_cells -quiet [lsort -uniq [get_att [get_att -quiet $paths  points.object.cell] full_name] ] -filter is_sequential==false]
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
        
        set new_line [list "$current_min_slack - $current_max_slack" [sizeof $paths] [sizeof $cells] \
                      $sn $ll $ln $ul $un $en $sna $lla $lna $ula $una $ena]
                      
        lappend table $new_line
        
    }
    
    rls_table -table [ory_sum_table $table] -header $header -breaks -spac -format $form
    
}



proc ory_sum_table { table {sort_by -1} } {

    set num_of_col [llength [lindex $table 0]]
    set col_types  {}
    
    # Transpose
    set table_t [_transposeMatrix $table]
    
    # 1st passage - mark columns
    set new_table_t {}
    foreach line $table_t {
        set is_float false
        set dec_digits -1 
        set but_did_i_check_format false 
        set format_str ""          
        set col_type "number"
        set col_tot  0
        foreach v $line {
            if { ![ _isnumeric $v ] } {
                set col_type "notAnumber"
                break
            } else {
                set col_tot [expr $col_tot + $v]
                if { !$but_did_i_check_format } {
                    if { [regexp "\\.(\[0-9\]+)" $v res dec_digits] } {            
                        set format_str "%.[string length $dec_digits]f"
                    }
                }
            }
        }
        if { $format_str != "" } { set col_tot [format $format_str $col_tot] }
        lappend col_types $col_type
        
        if { $col_type == "number" } { 
            set new_line [concat $line $col_tot]
        } else {
            set new_line [concat $line [list "-"]]
        }
        lappend new_table_t $new_line
    }     
    
    # Transpose
    set table [_transposeMatrix $new_table_t]
    
    return $table
}

proc _isnumeric { string } {
    if { $string == "" } { return 0 }
    if { [string is digit $string] || [string is double $string] || [string is integer $string] || [string is wideinteger $string] } {
        return 1
    }
    return 0
}

proc _iota n {
   # index vector generator, e.g. iota 5 => 0 1 2 3 4
   set res {}
   for {set i 0} {$i<$n} {incr i} {
       lappend res $i
   }
   set res
}

proc _transposeMatrix m {
   set cols [_iota [llength [lindex $m 0]]]
   foreach row $m {
       foreach element $row   *col $cols {
           lappend ${*col} $element
       }
   }
   eval list $[join $cols " $"]
}











proc highlight_path {args} {
	set args_count [llength $args]
    if { !($args_count) } {
    set tp [report_timing -collection]
    return [highlighter $tp ""]
    }
    if { [lsearch $args -clear_gui*] > -1} {
    	gui_pv_clear
        return 
    } elseif { [lsearch $args -clear_path*] > -1} {
    	set pn [lindex $args 1]
    	gui_pv_airline_delete $pn
        return 
    
    } elseif { [lsearch $args -help*] > -1} {
    	puts "Highlight selected path on gui with airlines.\n\n "
    	
    	puts "
        		Flags Manual\n\n"
            
        puts "-clear_gui 
        	  Clear all paths from gui.	\n\n"
        puts "-clear_path <integer> 
        	  Clear specific path (starts from 0) " 
        puts  "-color Specifies the paths color.

              The color can have following values:

              blue, brown, cyan, green, magenta, orange, pink, purple, red, yellow, white."
    	puts "-from {<inst>|<hinst>|<external_delay>|<clock>|<port>|<pin>|<hpin>}
              Specifies a Tcl list of start points for the paths. The start points can be input ports of your design, clock pins of flip-flops, clock objects, or a combination of these, instances, or input ports to which the specified external delay timing applies."
              
     	puts "-to {<inst>|<hinst>|<external_delay>|<clock>|<port>|<pin>|<hpin>}
              Specifies a Tcl list of end points for the paths. The end points can be output ports of your design, input pins of flip-flops, clock objects, or a combination of these, instances, or output ports to which the specified external delay timing exception applies."
        
        puts "-through {inst|hinst|port| pin|hpin}                                                                                                                                                                                                                                                       
                            Specifies a Tcl list of a sequence of points that a path must traverse. Points to traverse can be ports, hierarchical pins, pins on a sequential/mapped combinational cells, or sequential/mapped combinational instances."
        puts "-max_paths <integer>
              Specifies the maximum number of paths to report.

              Default: the value of -nworst"
		puts "-nworst <integer>
              Specifies the maximum number of paths to report to each endpoint.

              Default: 1"
       	puts "-max_slack <integer>
              Reports only paths with a slack smaller than the specified number. The slack is reported in picoseconds.

              This option cannot be combined with the -unconstrained option."

       	puts "-min_slack <integer>
              Reports only paths with a slack greater than the specified number. The slack is reported in picoseconds.

              This option cannot be combined with the -unconstrained option."
		puts "-group <group_list>
              Reports paths for the specified path group or cost group."
        puts  "-unconstrained
              Reports only the unconstrained paths (paths with no slack). Each signal arriving at the path end node which does not have a matching required time, results in an unconstrained path."
 		return 
        
	} elseif { !([llength $args] % 2)} {
    	set flags ""
        set color ""
        set color_case 0
        foreach flag $args {
        	if {$flag == "-color" } { 
            	set color_case 1
                continue
            }
            if {$color_case} {
            	set color $flag
            	continue
            }
        	append flags " " 
        	append flags $flag
        }
        append flags " -collection"
        #puts "$flags"
        set tp [eval report_timing $flags]
        return [highlighter $tp $color]
    	
    } else {
    	puts "Wrong input"
        return 
    }
    
}                          



proc highlighter {path color_flag} {
    set color_list [list "blue" "brown" "cyan" "green" "magenta" "orange" "pink" "purple" "red" "yellow" "white"]
    set j 0
    set start_point_list [list]
    set end_point_list [list]
    set slack_list [list]
    set max_string_start 0
    set max_string_end 0
    set max_string_slack 0
    foreach_in_collection p $path {
    	
        set color [lindex $color_list [expr $j % 11] ]
        if {$color_flag != ""} {
        	set color $color_flag
        }
    	set time_list [list]
    	foreach t_p [get_db $p .timing_points] {
    		lappend time_list [get_db $t_p .pin]
    	}
    	set len [llength $time_list]
    	set i 0
        
    	
    	while {$i < [expr $len - 1]} {
    		
    		gui_pv_airline_add -from [get_db [lindex $time_list $i] .name] -to [get_db [lindex $time_list [expr $i +1]] .name] -color $color -name $j -width 2 -glyph arrow
            if {[get_db [lindex $time_list $i] .obj_type] == "port"} {
            	
            	gui_pv_highlight -append  [lindex $time_list $i] -color $color -pattern cross
             
            } else {
            	gui_pv_highlight -append [get_db [get_db [lindex $time_list $i] .inst] .name] -color $color -pattern cross }
            set i [expr $i +1 ] 
    	}
        if {[get_db [lindex $time_list $i] .obj_type] == "port"} {
            	
            	gui_pv_highlight -append  [lindex $time_list $i] -color $color -pattern cross
             
        } else {
            	gui_pv_highlight -append [get_db [get_db [lindex $time_list $i] .inst] .name] -color $color -pattern cross }
        set starting_point [get_db [lindex $time_list 0] .name]
        if {[string length $starting_point] >= $max_string_start} {
        	set max_string_start [string length $starting_point]
        }
        
        lappend start_point_list $starting_point
        
        set ending_point [get_db [lindex $time_list [expr $len-1]] .name]
        lappend ending_point_list $ending_point
        if {[string length $ending_point] >= $max_string_end} {
        	set max_string_end [string length $ending_point]
        }
        
        set slack [get_db [get_db $p] .slack]
        if {[string length $slack] >= $max_string_slack} {
        	set max_string_slack [string length $slack]
        }
        lappend slack_list $slack
        
        set j [expr $j +1 ]
        
	}
    set a "slack"
    set b "Starting point"
    set c "Ending point"
    set rep1 [string repeat "-" $max_string_start]
    set rep2 [string repeat "-" $max_string_end]
    puts "\n"
    puts [format "%-10s%-${max_string_start}s   %-${max_string_end}s" $a $b $c]
    puts [format "%-10s%-${max_string_start}s   %-${max_string_end}s" "-----" $rep1 $rep2]
    foreach sl $slack_list sp $start_point_list ep $ending_point_list {
    	puts [format "%-10s%-${max_string_start}s   %-${max_string_end}s" $sl  $sp $ep]
    }
    puts "\n"
}






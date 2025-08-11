proc clock_route_histogram {{bin_edges {5 10 20 30 50 75 100}}} {

	array set hist {}
	array set metals_seen {}
	array set rule_count {}
	array set routing_seen {}
	array set sample_net {}
	
	# Build bin labels automatically from bin edges
	set bin_labels {}
	foreach edge $bin_edges {
		lappend bin_labels "<=${edge}um"
	}
	lappend bin_labels ">[lindex $bin_edges end]um"
	
	foreach_in_collection nnn [get_nets -filter "net_type == clock "] {
		set length [get_att $nnn dr_length]
		set max_layer [lindex [lsort -dictionary [get_att $nnn route_length]] end 0]
		set routing_rule [get_att $nnn routing_rule]
	
		set metals_seen($max_layer) 1
		
        	# Find which bin this length falls into
        	set label ">[lindex $bin_edges end]um"
        	foreach edge $bin_edges lbl $bin_labels {
            		if {$length <= $edge} {
                		set label $lbl
                		break
            		}
        	}		
		
		
#    		if {$length <= 5} {
#        		set label "<=5um"
#    		} elseif {$length <= 10} {
#        		set label "<=10um"
#    		} elseif {$length <= 20} {
#       		 	set label "<=20um"
#    		} elseif {$length <= 30} {
#        		set label "<=30um"
#    		} elseif {$length <= 50} {
#        		set label "<=50um"
#    		} elseif {$length <= 75} {
#        		set label "<=75um"
#    		} elseif {$length <= 100} {
#        		set label "<=100um"
#    		} else {
#        		set label ">100um"
#    		}
    		incr hist($max_layer,$label)
		incr rule_count($max_layer,$routing_rule)
		set routing_seen($routing_rule) 1
		
		if {![info exists sample_net($max_layer,$label)]} {
    			set sample_net($max_layer,$label) [get_object_name $nnn ]
		}
	}

	# Define bin labels in order for printing
#	set bin_labels {"<=5um" "<=10um" "<=20um" "<=30um" "<=50um" "<=75um" "<=100um" ">100um"}
	# Define routing rule values
	set rule_values [lsort -dictionary [array names routing_seen]]

	# Print header
	puts -nonewline [format "%-6s" "Metal"]
	foreach label $bin_labels {
    		puts -nonewline [format " %7s" $label]
	}
	puts -nonewline " |"
	foreach rule $rule_values {
    		# Print only the short name after last underscore
    		if {[regexp {.*_(SHLD)?$} $rule -> short]} {
        		puts -nonewline [format " %10s" $short]
    		} else {
        		puts -nonewline [format " %10s" $rule]
    		}
	}
	puts ""

	# Print data per metal
	foreach metal [lsort -dictionary [array names metals_seen]] {
    		puts -nonewline [format "%-6s" $metal]
    		foreach label $bin_labels {
        		set count 0
        		if {[info exists hist($metal,$label)]} {
            			set count $hist($metal,$label)
        		}
        		puts -nonewline [format " %7d" $count]
    		}

    		puts -nonewline " |"
    		foreach rule $rule_values {
        		set count 0
        		if {[info exists rule_count($metal,$rule)]} {
            			set count $rule_count($metal,$rule)
        		}
        		puts -nonewline [format " %20d" $count]
		}
    		puts ""
	}
	
	puts "\nSample nets per metal and bin:"
	foreach key [lsort -dictionary [array names sample_net]] {
    		array set tmp [list metal [lindex $key 0] bin [lindex $key 1]]
    		set net_name $sample_net($key)
    		set dr_length [get_att [get_nets $net_name] dr_length]
    		puts [format "Metal: %-4s  Bin: %-8s  Length: %-7.2f  Net: %s" \
          	$tmp(metal) $tmp(bin) $dr_length $net_name]
	}


}

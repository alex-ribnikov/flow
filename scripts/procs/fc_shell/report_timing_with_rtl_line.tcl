proc report_timing_with_rtl_line {args} {
	set insert_rtl_column 0
	set infile tmpin.rpt
	set outfile tmpout.rpt
	set index [lsearch $args "-nosplit" ]
	if {$index!=-1} {set args [lreplace $args $index $index]}
	set cmd "get_timing_paths  $args"
	set tp [eval $cmd]
	if {[sizeof $tp]} {
		report_timing $tp -nosplit  > $infile 	
		foreach_in_collection c [get_attribute $tp points] {
			set fname [get_attribute $c name]
			set cp(${fname}) [get_attribute $c rtl_line]
		}
		
		set fin [open $infile r]
		set fout [open $outfile w]
		set path_count 0
		
		while {[gets $fin line] >= 0} {
		   if {[string match "*Point*" $line]} {
			puts $fout "$line     RTL Info"
			set insert_rtl_column 1
		    } elseif {[regexp {^-+} [string trim $line]] && $insert_rtl_column} {
			puts $fout "$line[string repeat "-" 100]"
			set insert_rtl_column 0
		    } else {
			set fields [split [string trim $line] " "]
			set cell_pin [lindex $fields 0]

			if {[info exists cp($cell_pin)]} {
			    set rtl_info $cp($cell_pin)
			    puts $fout "$line    $rtl_info"
			} else {
			    puts $fout $line
			}
		    }
		}

			close $fin
			close $fout
			set fout [open $outfile r]
			set content [read $fout]
			close $fout
			exec rm $infile
			exec rm $outfile
			puts $content
	} else {
		puts "No paths."
	}
	 
}

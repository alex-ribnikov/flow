
proc be_report_macro_count_check {} {
	global DESIGN_NAME
        set my_macro_cells [get_cells -quiet -hier -filter design_type==macro]
	foreach_in_collection macro_ $my_macro_cells {
		set ref_name [get_attribute $macro_ ref_name]
		incr macro_count($ref_name)
	}
	puts "\n"
	puts [string repeat * 50]
	puts "Report : macro count"
	puts "Design : $DESIGN_NAME"
	if {[info exists ::synopsys_program_name] } {
		puts "Version: [get_app_var sh_product_version]"
	}
	puts "Date   : [date]"
	puts [string repeat * 50]
	puts "\n"
	puts [format "%-70s %-20s %-70s" "Type" "Count" "Wrapper name" ]
	puts [string repeat - 160]

	foreach macro_ [lsort [array names macro_count]] { 
		set cmd "get_cells -hier -filter {ref_name=~$macro_}"
		set m [index [eval $cmd] 0]
		set p [get_Attribute $m hdl_file]
		set wrap_name [lindex [split $p "/"] end]
		set wrap_name [string range $wrap_name 0 [expr [string first "." $wrap_name ] - 1] ]
		puts [format "%-70s %-20s %-70s" $macro_ $macro_count($macro_) $wrap_name]		
	}
	puts "\n"

}



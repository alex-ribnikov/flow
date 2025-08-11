
proc memory_grouping_BSI {{file_name "macros_groups"}} {

	global DESIGN_NAME
	set RUNTIME_START [clock seconds]
	puts "-I- Start running at: [clock format $RUNTIME_START -format "%d/%m/%y %H:%M:%S"]"
	set num_mem_in_group 10
	set x_step 400
	set y_step 400

	set png_name $file_name.png
	set csv_name $file_name.csv
	set file_name $file_name.rpt
	set csv [open $csv_name w]
	set fi [open $file_name w]

	set is_first 1
	gui_change_highlight -remove -all_colors
	gui_set_highlight_options -auto_cycle_color 1
	gui_set_highlight_options -current_color yellow
	
	puts $csv "Block name,memory configuration name,compiler type,number of memory instancesper block,Frequency(G)"
	
	set compiler_type {M3SRF211HC M3PD211HC M3SP111HC M3PSP111HD M3SP111HD M3DP222HC M3CAM111HC M3DP222HC}

	foreach ct $compiler_type {
		
		set cmd "get_cells -hier -filter {is_hard_macro&&ref_name=~${ct}*BSI*}"
		set all_mems [eval $cmd]
		
		set mem_config_lst [lsort -u [get_attribute $all_mems ref_name]]
		foreach mem_config $mem_config_lst {
			set period "get_attribute \[get_clocks \[get_attribute \[all_fanin -to \[get_pins -of_objects \[index \[get_cells -hierarchical -filter \{is_hard_macro&&ref_name=~*$mem_config*\}\] 0\] -filter \{is_clock_pin\}\] -startpoints_only\] name\]\] period"
			set period [eval $period]
			set freq [format %.1f [expr 1.0/$period]]
			set count "sizeof \[get_flat_cells -filter \{is_hard_macro&&ref_name=~$mem_config\}\]"
			set count [eval $count]
			if {$is_first} {puts $csv "$DESIGN_NAME,$mem_config,$ct,$count,$freq"; set is_first 0} {puts $csv ",$mem_config,$ct,$count,$freq"}
		}

		lassign [get_attribute [current_block ] boundary_bounding_box.ur] x_end y_end
		
		set ll_y [expr [get_attribute [index [sort_collection $all_mems boundary_bounding_box.ll_y] 0] boundary_bounding_box.ll_y] - 1]
		set ll_x [expr [get_attribute [index [sort_collection $all_mems boundary_bounding_box.ll_x] 0] boundary_bounding_box.ll_x] - 1]


		while {[sizeof $all_mems] > 0} {

			set ur_y [expr $ll_y + $y_step]
			set ur_x [expr $ll_x + $x_step]
	
			set mems [sort_collection [get_cells -hier -filter {is_hard_macro} -q -within [list "$ll_x $ll_y" "$x_end $ur_y"]] boundary_bounding_box.ll] 
			set cmd "filter_collection \$mems \{ref_name=~*${ct}*BSI*\}"
			set mems [eval $cmd]

			set all_mems [remove_from_collection $all_mems $mems]
			set col ""

			for {set i 0} {$i < [sizeof $mems]} {incr i} {

				set mem [index $mems $i]
				set ur_x_mem [get_attribute $mem boundary_bounding_box.ur_x]
				set ll_x_mem [get_attribute $mem boundary_bounding_box.ll_x]
			
				if {$ur_x_mem > $ur_x||[sizeof $col] >= $num_mem_in_group} {
					gui_change_highlight -collection $col
					puts $fi [join [get_attribute $col full_name] "\n"]
					puts $fi "\n"
					set col ""
					set ur_x [expr $ll_x_mem + $x_step]
				}

				append_to_collection -unique col $mem
				
			} 
			
			puts $fi [join [get_attribute $col full_name] "\n"]
			puts $fi "\n"
			gui_change_highlight -collection $col
			set ll_y [expr [get_attribute [index [sort_collection $all_mems boundary_bounding_box.ll_y] 0] boundary_bounding_box.ll_y] - 1]
		}


	}

	close $csv
	close $fi

	gui_start
	gui_set_layout_layer_visibility [get_attribute [get_layers] name] -toggle
	gui_write_window_image -format png -file $png_name
	gui_change_highlight -remove -all_colors
	gui_stop

	set end_t [clock seconds]
	puts "-I- End running at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
	puts "#     Elapse time is [expr ($end_t - $RUNTIME_START)/60/60/24] days , [clock format [expr $end_t - $RUNTIME_START] -timezone UTC -format %T]"


	puts "-I- a file showsing the macros groups saved as : \n $file_name"
}

#################################################################################################################################################################################
#	 																					#
#	report_clock_tree_structure	 																	#
#	 																					#
#	 																					#
#################################################################################################################################################################################
proc supper_buf_size_cell {cell_list lib_cell} {
	 
	set input_net [get_net -of [get_pins -of_objects $cell_list -filter "direction == in"]]
	set output_net [get_net -of [get_pins -of_objects $cell_list -filter "direction == out"]]
	if {[sizeof_collection  [get_cells $cell_list]] != 1} {
		puts "Error: too many instaces. need to be one. (NextSi-610)"
		return 2
	}
	if {[sizeof_collection  [get_pins -of_objects $cell_list -filter "direction == in"]] != 1} {
		puts "Error: too many input pins. need to be one. (NextSi-610)"
		return 2
	}
	if {[sizeof_collection  [get_pins -of_objects $cell_list -filter "direction == out"]] != 1} {
		puts "Error: too many output pins. need to be one. (NextSi-611)"
		return 2
	}
	if {[sizeof_collection  [get_lib_pins -of_objects [get_lib_cells */$lib_cell] -filter "direction == in"]] != 1} {
		puts "Error: too many input pins to lib_cell. need to be one. (NextSi-612)"
		return 2
	}
	if {[sizeof_collection  [get_lib_pins -of_objects [get_lib_cells */$lib_cell] -filter "direction == out"]] != 1} {
		puts "Error: too many output pins to lib_cell. need to be one. (NextSi-613)"
		return 2
	}
	if {[get_attribute [get_lib_cells  */[get_attribute [get_cells $cell_list] ref_name]] function_id] != [get_attribute  [get_lib_cells */$lib_cell] function_id]} {
		puts "Error: lib_cell $lib_cell function differ from $cell_list. (NextSi-614)"
		return 2
	}
	if {[get_attribute [get_cells $cell_list] ref_name] == $lib_cell} {
		puts "Warning: lib_cell $lib_cell match to $cell_list. (NextSi-615)"
		return 0
	}

	# remove old inst
	puts "Disconnecting nets from cell $cell_list"
	disconnect_net $input_net  $cell_list
	disconnect_net $output_net $cell_list
	puts "Remove cell $cell_list , [get_attribute [get_cells $cell_list] ref_name]"
	remove_cell $cell_list
	# create new inst	
	puts "create new cell $cell_list , $lib_cell"
	create_cell $cell_list $lib_cell
	set input_pin_new [get_pins -of_objects $cell_list -filter "direction == in"]
	set output_pin_new [get_pins -of_objects $cell_list -filter "direction == out"]
	puts "connecting nets to cell $cell_list"
	connect_net $input_net $input_pin_new
	connect_net $output_net $output_pin_new
	
}
define_proc_attributes  supper_buf_size_cell \
	-info "Relinks  one  or  more leaf cell instances to a new library cell\nthat has the same logical function but different properties such\n	as size and drive strength." \
  	-define_args {
    		{cell_list "show report on those clocks" cell_list list {required}}
    		{lib_cell "add max arrival time to each level" lib_cell string {required}}
    	}

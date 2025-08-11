proc gen_port_list {REPORTS_DIR} {
	regexp {::(\S+)} [lindex [info level 0] 0] match script

	puts "Info ($script): Begin"
	foreach_in_collection des [get_designs -q] {
		set fileId [open "temp_port_list_" "w"]
		set all_ports [get_ports -quiet * -filter "port_type != power && port_type != ground"]
		foreach_in_collection port [sort_collection -dictionary $all_ports {full_name}] { puts $fileId [get_object_name $port] }
		close $fileId
		exec cat temp_port_list_ | tr "\[" " " | awk "{print \$1}" | sort | uniq -c | sort -k1 -nr > $REPORTS_DIR/[get_object_name $des].port_list
		exec rm -f temp_port_list_
	}
	
	set hard_macros_refs [lsort -unique [get_attribute [get_cells -physical_context -filter "(is_hard_macro == true) || (is_soft_macro == true) || (design_type == black_box) && ref_name!~M3*"] ref_name]]
	foreach ref $hard_macros_refs {
		set cell [index_collection [get_cells -physical_context -filter "ref_name == $ref"] 0]
		set cell_name [get_object_name $cell]
		set fileId [open "temp_port_list_" "w"]
		set pins [get_pins -physical_context -of $cell -filter "port_type != power && port_type != ground"]
		foreach_in_collection pin [sort_collection -dictionary $pins {full_name}] { puts $fileId [get_attribute $pin name] }
		close $fileId
		exec cat temp_port_list_ | tr "\[" " " | awk "{print \$1}" | sort | uniq -c | sort -k1 -nr > $REPORTS_DIR/$ref.port_list
		exec rm -f temp_port_list_
	}

	puts "Info ($script): End"
}

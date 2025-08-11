################################################################################################################
##   addiobuffer_proc	- add io buffer to interface								
################################################################################################################
proc addiobuffer_proc {args} {
	#parse_proc_arguments -args $args options

# // PARSE ARGS 
  # INFO
    set proc_info "
add buffer to io
"
  # ARG DATA
         # opt_name         must  type      default            info
    set my_args {
	{mode               0   integer   0                    "buffer cell to use. mode 0 using one cell height which is E3 and mode 1 using two cell heights: E1,E2" }
	{direction 	     0   string    "both" 		"place buffer on input , output or both"}
    	{padding 	     0   string    "0 0 0 0" 		"add padding to created cells.  can give 1 number for all sides, or left top right bottom"}
    	{antenna 	     0   boolean    1 			"add antenna to input"}
 	{buffer  	     0   string     "E1LLRA_BUFX8 E2LLRA_BUFX8" 			"ref cell names for mode 1.useful together with -mode flag."}
    	{i_buffer 	     0   string     "E3LLRA_BUFAX6" 	"ref cell name for input ports IO buffers - mode 0.useful together with -antenna flag for ocerriding the default behaving of adding an antenna buffer on input ports."}
    	{o_buffer 	     0   string     "E3LLRA_BUFX6" 	"ref cell name for output ports IO buffers - mode 0"}


    }
    if { [be_parse_args $proc_info $my_args l$args] != "0" } { return }
	if {$mode==1} {
		set BUFFER_117 [lindex $buffer 0]; #E1LLRA_BUFX8 
		set BUFFER_169 [lindex $buffer 1]; #E2LLRA_BUFX8
	}
# //

  # init settings

	if {[llength $padding] > 1 } {
		set left_side    [lindex $padding 0]
		set top_side     [lindex $padding 1]
		set right_side   [lindex $padding 2]
		set bottom_side  [lindex $padding 3]
	} else {
		set left_side    $padding
		set top_side     $padding
		set right_side   $padding
		set bottom_side  $padding
	}
	#set_cell_padding -cell $BUFFER  -bottom_side $bottom_side -top_side $top_side -right_side $right_side -left_side $left_side
	#maybe horizontal spacing should be the width of the most wide usable buffer
	#the vertical spacing should be the height of one row
	
	remove_placement_spacing_rules -label X
	remove_placement_spacing_rules -rule {X X}

       	if {$mode==1} {
		 set_placement_spacing_label -name X -side both -lib_cells [get_lib_cells "$BUFFER_117 $BUFFER_169" ]
	} else {
		set_placement_spacing_label -name X -side both -lib_cells [get_lib_cells "$i_buffer $o_buffer"]
	}

	set_placement_spacing_rule -labels {X X} {0 1}

	set rows_height [list 169 117]

	#set boundary_offset_x 0.024
	#set boundary_offset_y 0.0845
	set boundary_offset [list 0.0845 0.024]


   	if {[info exists buffer]} {
		set fid [open excNetFileName.txt w]
		set excNetFileName_flag 0

   		if {$direction == "both" || $direction == "both_ant" || $direction == "in" || $direction == "in_ant" } {
			set in_ports [get_port -filter "direction==in && port_type==signal && defined(net) && net.net_type==signal"]
			set clock_ports [get_ports [get_attribute [get_clocks -f defined(sources)] sources]]
			set floating_in_ports [get_ports -quiet -of [get_nets -quiet -of [get_ports -filter "direction==in"] -filter "number_of_pins<2"]]
			set test_ports [get_ports * -filter "(direction==in) && (name =~ test*|| name =~ scan*)"]			
			set in_ports [remove_from_collection $in_ports $clock_ports]
			set in_ports [remove_from_collection $in_ports $floating_in_ports]
			set in_ports [remove_from_collection $in_ports $test_ports]

			foreach_in_collection ppp [add_to_collection [add_to_collection $clock_ports $test_ports ] $floating_in_ports] {
					puts $fid [get_attribute $ppp name]
					set excNetFileName_flag 1
			}
			if {$mode==0} {
			foreach_in_collection ppp $in_ports {
					add_buffer $ppp  $i_buffer -new_cell_names IOBuf -snap	
			}
			} else {
			foreach_in_collection ppp $in_ports {
						set first_port $ppp
						set point [get_attribute $first_port bounding_box.center]
						set rows [get_site_rows -quiet -at $point]
						if {$rows==""} {
							define_pin_edge_attribute	
							set edge [get_attribute $ppp pin_edge]
							set shifting [lindex $boundary_offset [expr $edge%2]]
							set y_shift [add_to_collection [get_site_rows -quiet -at [list [lindex $point 0] [expr [lindex $point 1] + [lindex $boundary_offset  0]]]] \
							[get_site_rows -quiet -at [list [lindex $point 0] [expr [lindex $point 1] - [lindex $boundary_offset  0]]]]]
							set x_shift [add_to_collection [get_site_rows -quiet -at [list [expr [lindex $point 0] + [lindex $boundary_offset  1]] [lindex $point 1]]] \
							[get_site_rows -quiet -at [list [expr [lindex $point 0] - [lindex $boundary_offset  1]] [lindex $point 1]]]]
							set rows [add_to_collection $y_shift $x_shift]
							echo "[sizeof $rows] [get_object_name $ppp] $point" >> IOBuf_short_terminal_ports.rpt
						}
						if {$rows!=""} {
							set first_row [index [sort_collection $rows site_height] 0]
							set first_height [get_attribute $first_row site_height]
							set first_row_ll_y [get_attribute $first_row bounding_box.ll_y]
							set is_lower [lsearch $rows_height [expr int($first_height*1000)]]
							if {$is_lower} {add_buffer $ppp  $BUFFER_117 -new_cell_names IOBuf -snap} {add_buffer $ppp  $BUFFER_169 -new_cell_names IOBuf -snap}
						}
							

			}
			}

		}
   		if {$direction == "both" || $direction == "both_ant" || $direction == "out" } {
			set out_ports [get_ports -filter "direction==out && port_type==signal && defined(net) && net.net_type==signal"] 
			foreach_in_collection ppp [get_ports -filter {direction==out&&(port_type!=signal||!defined(net)||net.net_type!=signal)} -quiet] {
					puts $fid [get_attribute $ppp name]
					set excNetFileName_flag 1
			}
			if {$mode==0} {
			foreach_in_collection ppp $out_ports {
					add_buffer $ppp  $o_buffer -new_cell_names IOBuf -snap	
			}
			} else {
			foreach_in_collection ppp $out_ports {
						set first_port $ppp
						set point [get_attribute $first_port bounding_box.center]
						set rows [get_site_rows -at $point -quiet]
						if {$rows==""} {
							define_pin_edge_attribute	
							set edge [get_attribute $ppp pin_edge]
							set shifting [lindex $boundary_offset [expr $edge%2]]
							set y_shift [add_to_collection [get_site_rows -quiet -at [list [lindex $point 0] [expr [lindex $point 1] + [lindex $boundary_offset  0]]]] \
							[get_site_rows -quiet -at [list [lindex $point 0] [expr [lindex $point 1] - [lindex $boundary_offset  0]]]]]
							set x_shift [add_to_collection [get_site_rows -quiet -at [list [expr [lindex $point 0] + [lindex $boundary_offset  1]] [lindex $point 1]]] \
							[get_site_rows -quiet -at [list [expr [lindex $point 0] - [lindex $boundary_offset  1]] [lindex $point 1]]]]
							set rows [add_to_collection $y_shift $x_shift]
							echo "[sizeof $rows] [get_object_name $ppp] $point" >> IOBuf_short_terminal_ports.rpt
						}
						if {$rows!=""} {
							set first_row [index [sort_collection $rows site_height] 0]
							set first_height [get_attribute $first_row site_height]
							set first_row_ll_y [get_attribute $first_row bounding_box.ll_y]
							set is_lower [lsearch $rows_height [expr int($first_height*1000)]]
							if {$is_lower} {add_buffer $ppp  $BUFFER_117 -new_cell_names IOBuf -snap} {add_buffer $ppp  $BUFFER_169 -new_cell_names IOBuf -snap}
						}	
			}
			}
	
					
		}
		close $fid
		if {$excNetFileName_flag} {puts "exclude_nets_file saved: excNetFileName.txt"}
 
		puts "-I- setting size_only on IOBuf"
		set_size_only [get_flat_cells *IOBuf*]

   		#dont touch on net
		#puts "-I- setting dont touch on IO nets"
		#set_dont_touch [all_connected $in_ports] true
		#set_dont_touch [all_connected $out_ports] true

		
  		#delete cell padding - outside script, after legalization
		
   	}
}


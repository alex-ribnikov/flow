
proc addiobuffer_by_layer {args} {
	  

 set proc_info "
add buffer to io
"
	set my_args {
		{direction 	     0   string    "both" 		"place buffer on input , output or both"}
	 	{buffer  	     0   string     "E1LLRA_BUFX8 E2LLRA_BUFX8" 			"ref cell names for mode 1.useful together with -mode flag."}
    		{i_buffer 	     0   string     "" 	"ref cell name for input ports IO buffers - mode 0.useful together with -antenna flag for ocerriding the default behaving of adding an antenna buffer on input ports."}
    		{o_buffer 	     0   string     "" 	"ref cell name for output ports IO buffers - mode 0"}
 	}

    	if { [be_parse_args $proc_info $my_args $args] != "0" } { return }

	define_pin_edge_attribute

	set iobuf_name "IOBuf"

	if { [info exists IOBUFFER_CELL] } {
	    set iobuf_cell $buffer
	} else {
	    set iobuf_cell "E3LLRA_BUFX9"
	}

	set IN_BUFFER_117 [lindex $i_buffer 0]; 
	set IN_BUFFER_169 [lindex $i_buffer 1];
	set OUT_BUFFER_117 [lindex $o_buffer 0]; 
	set OUT_BUFFER_169 [lindex $o_buffer 1];

	set rows_height [list 169 117]

	if { [info exists IO_BUFFERS_DIR] } {
	    set dir_list ""
	    if { [regexp "in|both" $direction] }     { lappend dir_list "in" }
	    if { [regexp "out|both" $direction] }    { lappend dir_list "out" }    
	} else {
	    set dir_list "in"
	}

	lassign [join  [get_attribute [get_designs ] boundary_bounding_box.ur]] X Y


	# all ports on north edge
	array unset buf_edge_arr ;#  format is 'edge {idx {x0/y0 rand lay_step} idx1 {x1/y1 r l} ...}'
	array set buf_edge_arr "
	    north_2 {0 {[expr $Y - 0.2] -0.5 -0.8}}
	    south_4 {0 {[expr 0  + 0.2]  0.5  0.8}}
	    west_1 {0 {[expr 0  + 1.3]  0.5  1.0}}
	    east_3  {0 {[expr $X - 1.3] -0.5 -1.0}}
	"  


	foreach dir $dir_list {

	set_placement_spacing_label  -name IO_BUF -side both -lib_cells $iobuf_cell
	set_placement_spacing_rule -labels {IO_BUF IO_BUF} {0 2}
	set_placement_spacing_label  -name IO_BUF -vertical_side bottom -lib_cells $iobuf_cell
	set_placement_spacing_rule -labels {IO_BUF IO_BUF} {0 2}


	  foreach _edge_entry [array names buf_edge_arr] {

	    lassign [split $_edge_entry "_"] _edge _edge_num 

	    set cmd "get_ports -filter \{pin_edge==$_edge_num&&direction==$dir&&port_type==signal&&defined(net)&&net.net_type==signal\}"

	    set port_names [get_attribute [eval $cmd] name]



	    array unset buf_arr ; array set buf_arr $buf_edge_arr($_edge_entry)

	    set buf_arr_len [llength [array names buf_arr]]

	    for { set i 0 } { $i < $buf_arr_len } { incr i} {
		lassign $buf_arr($i) _v _rand _step

		 
		foreach ppp $port_names {
			puts "$ppp"
			set first_port $ppp
			set first_row [index [sort_collection [get_site_rows -at [get_attribute $first_port bounding_box.center]] site_height] 0]
			set first_height [get_attribute $first_row site_height]
			set first_row_ll_y [get_attribute $first_row bounding_box.ll_y]
			set is_lower [lsearch $rows_height [expr int($first_height*1000)]]
			
			if {$dir == "in"} {
				if {$is_lower} {
					add_buffer $ppp  $IN_BUFFER_117 -new_cell_names "${ppp}_I_${iobuf_name}_${i}_${dir}_${_edge}"  -snap	
				} else {
					add_buffer $ppp  $IN_BUFFER_169 -new_cell_names "${ppp}_I_${iobuf_name}_${i}_${dir}_${_edge}"  -snap	
				}
			} else {
				if {$is_lower} {
					add_buffer $ppp  $OUT_BUFFER_117 -new_cell_names "${ppp}_I_${iobuf_name}_${i}_${dir}_${_edge}"  -snap	
				} else {
					add_buffer $ppp  $OUT_BUFFER_169 -new_cell_names "${ppp}_I_${iobuf_name}_${i}_${dir}_${_edge}"  -snap	
				
				}
			 }


	    	} 

	    foreach i [array names buf_arr] {
	      lassign [join $buf_arr($i)] _y _rand _step
	      set cmd "get_cells -hier *${iobuf_name}_${i}_${dir}_${_edge}* -quiet"
	      set cells [eval $cmd]

	      foreach_in_collection c $cells {
		set _c [get_object_name $c]
		set _p [regsub -lineanchor {_([0-9]+)$} [regsub "_I_$iobuf_name.*" $_c ""] {[\1]}]
		set _lay [get_attribute [get_ports $_p] layer_name]
		if { [regexp "M" $_lay] } {
		    set _lay_d [expr ${_step}*(0.5*([regsub "M" $_lay {}] - 3))]
		    set v [expr $_v + ((0.5 - rand())*2*${_rand}) + $_lay_d] 
		    lassign [join [get_attribute [get_ports $_p] bounding_box.ll]] x0 y0
		    if { [regexp "...th" $_edge] } {
			set cmd "set_cell_location $_c -coordinates {$x0 $v} -orientation r0 -ignore_fixed"
			eval $cmd
		    } else {
			set cmd "set_cell_location $_c -coordinates {$v $y0} -orientation r0 -ignore_fixed"
			eval $cmd
		    }
		}
	      }
	    }

	}
	}

	set_app_option -name place.legalize.legalize_only_selected_cells -value true
	legalize_placement -cells [get_cells *IOBuf*]
	
	remove_placement_spacing_rules -label IO_BUF
	remove_placement_spacing_rules -rule {IO_BUF IO_BUF}

}
}

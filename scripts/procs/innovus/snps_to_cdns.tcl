#################################################################################################################################################################################
#	alias and procedure for snps eco command under cadence tools 														#
#																						#
#																						#
#		procedures:																			#
#			set_cell_location	- Specifies the physical location, orientation, and is_fixed status for leaf cells  						#
#			add_buffer_on_route	- Adds buffers along the route of the specified nets										#
#			insert_buffer	        - Inserts a buffer at one or more pins												#
#			remove_buffer	 	- Removes specified buffers from the current design										#
#			size_cell	 	- Relinks one or more leaf cell instances to a new library cell that has the same logical function 				#
#						  but different properties such as size and drive strength.									#
#			disconnect_net	 	- Disconnects a net from pins or ports												#
#			connect_net	 	-Connects the specified net to the specified pins or ports									#
#																						#
#																						#
#																						#
#################################################################################################################################################################################


################################################################################################################
## set_cell_location.
################################################################################################################
proc set_cell_location {args} {
    parse_proc_arguments -args $args options
    if {[info exists options(-coordinates) ]}    {set COORDINATES $options(-coordinates)}
    if {[info exists options(-orientation) ]}    {set ORIENTATION $options(-orientation)}
    if {[info exists options(inst) ]}            {set INST $options(inst)}
    set INST_NAME [get_object_name $INST]

    if { [string compare $ORIENTATION "N"] ==0 } {
        set orientation "R0"
    } elseif     { [string compare $ORIENTATION "FN"] ==0 } {
        set orientation "MY"
    } elseif     { [string compare $ORIENTATION "FS"] ==0 } {
        set orientation "MX"
    } elseif     { [string compare $ORIENTATION "S"] ==0 } {
        set orientation "R180"
    } elseif     { [string compare $ORIENTATION "FW"] ==0 } {
        set orientation "MX90"
    } elseif     { [string compare $ORIENTATION "W"] ==0 } {
        set orientation "R90"
    } elseif     { [string compare $ORIENTATION "E"] ==0 } {
        set orientation "R270"
    } elseif     { [string compare $ORIENTATION "FE"] ==0 } {
        set orientation "MY90"
    } else { puts "-E- orientation error. Terminating."
        return -1
    }

#    echo "CMD: place_inst $INST_NAME $COORDINATES $orientation"
#    place_inst $INST_NAME $COORDINATES $orientation
    set cell [get_db [get_db insts $INST_NAME] .base_cell.name]
    if {[llength [get_db insts $INST_NAME]] == 1} {
        echo "CMD: eco_update_cell  -insts $INST_NAME -location $COORDINATES -orient $orientation -cells $cell"
        echo "eco_update_cell  -insts $INST_NAME -location $COORDINATES -orient $orientation -cells $cell" >> eco_file.tcl
        eco_update_cell  -insts $INST_NAME -location $COORDINATES -orient $orientation -cells $cell
    } else {
        echo "ERROR: missing instance"
    }

}

define_proc_arguments set_cell_location \
    -info "Places a leaf instance in the core " \
      -define_args {
        {-coordinates  "Specifies x and y coordinates of new origin." "" list  {required}}
        {-orientation  "Specifies the orient of the instance." "" string  {required}}
        {inst  "Specifies the leaf instance name." "inst" string  {required}}
        }


################################################################################################################
## add_buffer_on_route.
################################################################################################################
proc add_buffer_on_route {args} {
    parse_proc_arguments -args $args options
    if {[info exists options(-no_legalize) ]}    {set NO_LEGALIZE true} else {set NO_LEGALIZE false }
    if {[info exists options(-user_specified_buffers) ]}    {set USER_SPECIFIED_BUFFERS $options(-user_specified_buffers)}
    if {[info exists options(-max_distance_to_route) ]}     {set MAX_DISTANCE_TO_ROUTE $options(-max_distance_to_route)}
    if {[info exists options(net) ]}    {set NET $options(net)}
    set NET_NAME [get_object_name $NET]

    set cmd "eco_add_repeater"
    set NAME [list]
    set REF_NAME [list]
    set XL [list]
    set YL [list]
    set METAL [list]
    for {set i 0} {$i < [llength $USER_SPECIFIED_BUFFERS]} {incr i} {
        if {[expr $i%5] == 0} { lappend NAME [lindex $USER_SPECIFIED_BUFFERS $i] }
        if {[expr $i%5] == 1} { lappend REF_NAME  [lindex $USER_SPECIFIED_BUFFERS $i] }
        if {[expr $i%5] == 2} { lappend XL  [lindex $USER_SPECIFIED_BUFFERS $i] }
        if {[expr $i%5] == 3} { lappend YL  [lindex $USER_SPECIFIED_BUFFERS $i] }
        if {[expr $i%5] == 4} { lappend METAL  [lindex $USER_SPECIFIED_BUFFERS $i] }
    }
    
    set INVERTER_PAIR false
    if {[lindex [get_db [get_db base_cells $REF_NAME] .is_inverter] 0]} {
        set INVERTER_PAIR true
	set RRR $REF_NAME
        set REF_NAME [list]
	for {set i 0} {$i < [llength $RRR]} {incr i 2} {lappend REF_NAME [lindex $RRR $i]}
    }
    
    set cmd "$cmd -cells \"$REF_NAME\""
    set cmd "$cmd -name \"$NAME\""
    set cmd "$cmd -net $NET_NAME"
    set cmd "$cmd -off_load_at_location \""
    for {set i 0} {$i < [llength $XL]} {incr i} {
        set cmd "${cmd} [lindex $XL $i] [lindex $YL $i]"
    }
    set cmd "$cmd\""
    
#    if {[llength $XL] > 1} {
#        set cmd "$cmd -off_load_at_location \"[lindex $XL 0] [lindex $YL 0]  [lindex $XL 1] [lindex $YL 1]\""
#        set cmd "$cmd -location \"[lindex $XL 0] [lindex $YL 0]  [lindex $XL 1] [lindex $YL 1]\""
#    } else {
#        set cmd "$cmd -off_load_at_location \"$XL $YL\""
#        set cmd "$cmd -location \"$XL $YL\""
#    }
    
    
#    if {$NO_LEGALIZE} {set cmd "$cmd -no_place"}
    echo "CMD: $cmd"
    echo $cmd >> eco_file.tcl
    set OBJ [eval $cmd]

    if {[info exists INVERTER_PAIR] && $INVERTER_PAIR == "true"} {
        echo "INFORMATION: INVERTER_PAIR is true. need to change inverter name to match SNPS expected name."
#       rename_obj [get_db [get_db [get_db insts [lindex $OBJ 0]] .pins -if ".direction == out"] .net] [lindex $NEW_NET_NAMES 0]     ;# rename first  inverter out net
#       rename_obj [get_db [get_db [get_db insts [lindex $OBJ 3]] .pins -if ".direction == out"] .net] [lindex $NEW_NET_NAMES 0]     ;# rename second inverter out net
        for {set i 0} {$i < [llength $NAME]} {incr i} {	    
            echo "CMD: rename_obj [get_db insts [lindex $OBJ [expr $i*3]]] [lindex $NAME $i]"
            echo "rename_obj [get_db insts [lindex $OBJ [expr $i*3]]] [lindex $NAME $i]" >> eco_file.tcl
            rename_obj [get_db insts [lindex $OBJ [expr $i*3]]] [lindex $NAME $i]    ;# rename first inverter
        }
#       rename_obj [get_db insts [lindex $OBJ 0]] [lindex $NAME 0]    ;# rename first inverter
#       rename_obj [get_db nets  [lindex $OBJ 2]] [lindex $NEW_NET_NAMES 0]     ;# rename first inverter out net
#       rename_obj [get_db insts [lindex $OBJ 3]] [lindex $NAME 1]    ;# rename second inverter
#       rename_obj [get_db nets  [lindex $OBJ 4]] [lindex $NEW_NET_NAMES 1]     ;# rename second inverter out net
    }
    
}

define_proc_arguments add_buffer_on_route \
    -info "Adds either a single buffer or two inverters on a net " \
      -define_args {
        {net  "Specifies the name of the net where the buffer will be inserted" "net" string  {required}}
        {-user_specified_buffers  "" "" list  {required}}
        {-no_legalize  "Specifies that the inserted cells should not be placed." "" boolean  {required}}
        {-max_distance_to_route  "Specifies the maximum horizontal or vertical distance in microns between the location found by route tracing and the legalized cell bounding box." "" float  {optional}}
        }

################################################################################################################
## insert_buffer.
################################################################################################################
proc insert_buffer {args} {
    parse_proc_arguments -args $args options
    if {[info exists options(-orientation) ]}    {set ORIENTATION $options(-orientation)}
    if {[info exists options(-location) ]}       {set LOCATION $options(-location)}
    if {[info exists options(-new_cell_names) ]} {set NEW_CELL_NAMES $options(-new_cell_names)}
    if {[info exists options(-new_net_names) ]}  {set NEW_NET_NAMES $options(-new_net_names)}
    if {[info exists options(-inverter_pair) ]}  {set INVERTER_PAIR true} else {set INVERTER_PAIR false }
    if {[info exists options(buffer_lib_cell) ]} {set BUFFER_LIB_CELL $options(buffer_lib_cell)}
    if {[info exists options(object_list) ]}     {set OBJECT_LIST $options(object_list)}
    
    set cmd "eco_add_repeater -cells $BUFFER_LIB_CELL"
    if {[info exists ORIENTATION]} {
        if { [string compare $ORIENTATION "N"] ==0 } {
            set cmd "$cmd -buffer_orient R0"
        } elseif 	{ [string compare $ORIENTATION "FN"] ==0 } {
            set cmd "$cmd -buffer_orient MY"
        } elseif 	{ [string compare $ORIENTATION "FS"] ==0 } {
            set cmd "$cmd -buffer_orient MX"
        } elseif 	{ [string compare $ORIENTATION "S"] ==0 } {
            set cmd "$cmd -buffer_orient R180"
        } elseif 	{ [string compare $ORIENTATION "FW"] ==0 } {
            set cmd "$cmd -buffer_orient MX90"
        } elseif 	{ [string compare $ORIENTATION "W"] ==0 } {
            set cmd "$cmd -buffer_orient R90"
        } elseif 	{ [string compare $ORIENTATION "E"] ==0 } {
            set cmd "$cmd -buffer_orient R270"
        } elseif 	{ [string compare $ORIENTATION "FE"] ==0 } {
            set cmd "$cmd -buffer_orient MY90"
        } else { puts "-E- orientation error. Terminating."
            return -1
	}
    }
    if {[info exists LOCATION]} {
    	set cmd "$cmd -location {$LOCATION}"
    } else {
    	set cmd "$cmd -no_place"
    }
    if {[info exists NEW_NET_NAMES] && $INVERTER_PAIR == "false"} {
    	set cmd "$cmd -new_net_name {$NEW_NET_NAMES}"
    }
    if {[info exists NEW_CELL_NAMES] && $INVERTER_PAIR == "false"} {
    	set cmd "$cmd -name {$NEW_CELL_NAMES}"
    }
    
    if {[get_db $OBJECT_LIST .obj_type] == "pin"} {
    	set cmd "$cmd -pins {[get_db $OBJECT_LIST .name]}"
	echo "CMD: $cmd"
	echo "$cmd" >> eco_file.tcl
	set OBJ [eval $cmd]
    } elseif {[get_db $OBJECT_LIST .obj_type] == "net"} {
    	set cmd "$cmd -net $OBJECT_LIST"
	echo "CMD: $cmd"
	echo "$cmd" >> eco_file.tcl
	set OBJ [eval $cmd]
    }
    if {[info exists INVERTER_PAIR] && $INVERTER_PAIR == "true"} {
        echo "INFORMATION: INVERTER_PAIR is true. need to change inverter name to match SNPS expected name."
#       rename_obj [get_db [get_db [get_db insts [lindex $OBJ 0]] .pins -if ".direction == out"] .net] [lindex $NEW_NET_NAMES 0]     ;# rename first  inverter out net
#       rename_obj [get_db [get_db [get_db insts [lindex $OBJ 3]] .pins -if ".direction == out"] .net] [lindex $NEW_NET_NAMES 0]     ;# rename second inverter out net
       
        echo "CMD: rename_obj [get_db insts [lindex $OBJ 0]] [lindex $NEW_CELL_NAMES 0]"
        echo "rename_obj [get_db insts [lindex $OBJ 0]] [lindex $NEW_CELL_NAMES 0]" >> eco_file.tcl
        rename_obj [get_db insts [lindex $OBJ 0]] [lindex $NEW_CELL_NAMES 0]    ;# rename first inverter
#       rename_obj [get_db nets  [lindex $OBJ 2]] [lindex $NEW_NET_NAMES 0]     ;# rename first inverter out net
        echo "CMD: rename_obj [get_db insts [lindex $OBJ 3]] [lindex $NEW_CELL_NAMES 1]"
        echo "rename_obj [get_db insts [lindex $OBJ 3]] [lindex $NEW_CELL_NAMES 1]" >> eco_file.tcl
        rename_obj [get_db insts [lindex $OBJ 3]] [lindex $NEW_CELL_NAMES 1]    ;# rename second inverter
#       rename_obj [get_db nets  [lindex $OBJ 4]] [lindex $NEW_NET_NAMES 1]     ;# rename second inverter out net
    }

    return    



    set inv1_net_name [lindex $new_net_name 0]
    set inv2_net_name [lindex $new_net_name 1]
    set inv1_cell_name [lindex $new_cell_name 0]
    set inv2_cell_name [lindex $new_cell_name 1]
    set inv1_loc [list [lindex $locations 0] [lindex $locations 1]]
    set inv2_loc [list [lindex $locations 2] [lindex $locations 3]]
    set invs_loc [list [lindex $locations 0] [lindex $locations 1] [lindex $locations 2] [lindex $locations 3]]
    set names [list $inv1_cell_name $inv2_cell_name]
    set new_nets [list $inv1_net_name $inv2_net_name]
    set pins [get_db $pins .name]
    
    if {[string compare $invs_flag "-inverter_pair"] == 0 } {
    	if {$orientation == "" } {
	    eco_add_repeater -pins $pins -name $inv1_cell_name -cells $cell -new_net_name $inv1_net_name -location $inv1_loc   -hinst_guide $::BE_CURRENT_INST	
	    echo "eco_add_repeater -pins $pins -name $inv1_cell_name -cells $cell -new_net_name $inv1_net_name -location $inv1_loc   -hinst_guide $::BE_CURRENT_INST" >> eco_file.tcl
            set buf [get_db [get_db pins *$inv1_cell_name/o*] .name]        
            eco_add_repeater -pins $buf -name $inv2_cell_name -cells $cell -new_net_name $inv2_net_name -location $inv2_loc  -hinst_guide $::BE_CURRENT_INST     
	    echo "eco_add_repeater -pins $buf -name $inv2_cell_name -cells $cell -new_net_name $inv2_net_name -location $inv2_loc  -hinst_guide $::BE_CURRENT_INST" >> eco_file.tcl
        } else {
	    eco_add_repeater -pins $pins -name $inv1_cell_name -cells $cell -new_net_name $new_nets -location $inv1_loc -buffer_orient $orientation  -hinst_guide $::BE_CURRENT_INST	
	    echo "eco_add_repeater -pins $pins -name $inv1_cell_name -cells $cell -new_net_name $new_nets -location $inv1_loc -buffer_orient $orientation  -hinst_guide $::BE_CURRENT_INST" >> eco_file.tcl
            set buf [get_db [get_db pins *$inv1_cell_name/o*] .name]
            eco_add_repeater -pins $buf -name $inv2_cell_name -cells $cell -new_net_name $inv2_net_name -location $inv2_loc -buffer_orient $orientation  -hinst_guide $::BE_CURRENT_INST
	    echo "eco_add_repeater -pins $buf -name $inv2_cell_name -cells $cell -new_net_name $inv2_net_name -location $inv2_loc -buffer_orient $orientation  -hinst_guide $::BE_CURRENT_INST" >> eco_file.tcl	
	}
    }
    
}

define_proc_arguments insert_buffer \
    -info "Adds either a single buffer or two inverters on a net " \
      -define_args {
        {object_list  "Specifies a list of nets, pins, or ports to be buffered" "object_list" list  {required}}
        {buffer_lib_cell "Specifies the library cell object to be used as a buffer or inverter. Specify the object as either a named library cell or a library cell collection" "buffer_lib_cell" list  {required}}
        {-inverter_pair  "Inserts inverter pairs instead of buffer cells" "" boolean  {optional}}
        {-new_net_names  "Specifies the names of the new nets created by buffer insertion" "new_net_names"   list  {optional}}
        {-new_cell_names "Specifies the names of the new cells created by buffer insertion" "new_cell_names" list  {optional}}
        {-location       "Specifies the lower-left coordinates in microns for the locations of the buffer cells or inverter pairs, in the format {x1 y1 x2 y2 ...}. " "coordinate_list" list  {optional}}
        {-orientation    "Specifies the orientation of the buffer cells or inverter pairs. You must specify one orientation per buffer when inserting buffers, or two orientations per inverter pair when inserting inverter pairs" "orientation_list" list  {optional}}
        }

################################################################################################################
## remove_buffer.
################################################################################################################

proc remove_buffer { buffer_inst } {
    set inst_name [get_db $buffer_inst .name]
    set inst_ref_name [get_db $buffer_inst .base_cell]
    
    if {[lindex [get_db $inst_ref_name .is_inverter] 0]} {
       set cmd "-inverter_pair {$inst_name}"
    } else {
       set cmd "-insts {$inst_name}"
    }
    set cmd "eco_delete_repeater $cmd"
    echo "CMD: $cmd"
    echo "$cmd" >> eco_file.tcl
    eval $cmd


}



################################################################################################################
## size_cell.
################################################################################################################


proc size_cell {cell_name new_cell} {
    regsub {{}} $cell_name {} cell_name
    regsub {{}} $new_cell {} new_cell
    set cell_name_fix [get_db [get_cells $cell_name] .name]
    echo "CMD: eco_update_cell  -insts $cell_name_fix -cells $new_cell"
    echo "eco_update_cell  -insts $cell_name_fix -cells $new_cell" >> eco_file.tcl
    eco_update_cell  -insts $cell_name_fix -cells $new_cell
}


#add_buffer_on_route [get_net -of {i_place_FE_OFC627054_grid_rst_n_N_IOBuf/o}] -user_specified_buffers { max_tran_inst_1_1__PTECO_DRC_BUF38394 F6UNAA_BUFX4 306.892 495.880 M6 max_tran_inst_1_1__PTECO_DRC_BUF38401 F6LLAA_BUFAX16 304.240 495.880 M6} -no_legalize
# insert buffers from the "end" to the start- mean take the first net to buff:
proc hk_get_common_hier_of_pins {pins} {

    set sorted_names [lsort -u [get_db $pins .inst.parent.name ] ]
    
    set common_hiers {}
    set is_break false
    for {set i 0} { $i < [llength $sorted_names ] } { incr i } {
        set curr_name ""
        set prev_name ""
        foreach name $sorted_names {             
            set spline [split $name "/"]
            set hier_name [lindex $spline $i]
            
            if { $prev_name == "" } { set prev_name $hier_name ; continue } { set curr_name $hier_name }   
            if { $prev_name != $curr_name } { set is_break true ; break }
            set prev_name $curr_name
        }
        if { $is_break } { break }
        lappend common_hiers $hier_name
    }
    
    return [join $common_hiers "/"]  
}

proc get_common_pins_hier {pins } {

    set top_hier [hk_get_hiers_of_pins [get_pins -leaf -hierarchical ]]
    set sorted_names [lsort -u [get_db $pins .inst.parent.name ]  ]
    #puts "$sorted_names"
    #set high_name [lindex [split $top_hier "/"] end]
    set common_hiers {}
    set is_break false
    for {set i 0} { $i < [llength $sorted_names ] } { incr i } {
        set curr_name ""
        set prev_name ""
        foreach name $sorted_names {
        	            
            set spline [split $name "/"]
            set hier_name [lindex $spline $i]
            
            if { $prev_name == "" } { set prev_name $hier_name ; continue } { set curr_name $hier_name }   
            if { $prev_name != $curr_name  } { set is_break true ; break }
            set prev_name $curr_name
        }
        if { $is_break } { break }
        lappend common_hiers $hier_name
    }
    
    if { [string compare [join $common_hiers "/"]  $top_hier] == 0 } {
        return 1
    } elseif {[join $common_hiers "/"] != ""} {
        return [join $common_hiers "/"]
    } else {
        return $top_hier 
    } 

}

proc find_hier {pins} {
    set top_hier [hk_get_hiers_of_pins [get_pins -leaf -hierarchical ]]
    set all_parent_names [get_db $pins .inst.parent.name ]
    set all_parents_names_no_top  [regsub -all "$top_hier/" [get_db $pins .inst.parent.name ] ""  ]
    array unset res_arr
    foreach name $all_parent_names {
            if { [info exists res_arr($name)] } {
                lappend res_arr($name) $name        
            } else {
                set res_arr($name) [list $name]
            }

    }
    set table {}
    
    foreach name [array names res_arr] {
        
        lappend table [list [llength $res_arr($name)] $name]
       
    }
    set sort_by 0
    if { $sort_by } {
        set s_table [lsort -decr -index $sort_by $table]
    } else {
        set s_table [lsort -decr -real -index $sort_by $table]
    }
    
    rls_table -table $s_table -header "#ofCells Hier_cell" -format "%-5d %s" -spacious -breaks
    


}




proc disconnect_net {net pin} {
	echo "CMD: disconnect_pin   -inst [get_db $pin .cell_name] -pin [lindex [split [get_db $pin .name] "/"] end ] -net [get_db [get_nets $net] .name]"
	echo "disconnect_pin   -inst [get_db $pin .cell_name] -pin [lindex [split [get_db $pin .name] "/"] end ] -net [get_db [get_nets $net] .name]" >> eco_file.tcl
	disconnect_pin   -inst [get_db $pin .cell_name] -pin [lindex [split [get_db $pin .name] "/"] end ] -net [get_db [get_nets $net] .name]
}

proc connect_net {net pin} {
	echo "CMD: connect_pin   -inst [get_db $pin .cell_name] -pin [lindex [split [get_db $pin .name] "/"] end ] -net [get_db [get_nets $net] .name]"
	echo "connect_pin   -inst [get_db $pin .cell_name] -pin [lindex [split [get_db $pin .name] "/"] end ] -net [get_db [get_nets $net] .name]" >> eco_file.tcl
	connect_pin   -inst [get_db $pin .cell_name] -pin [lindex [split [get_db $pin .name] "/"] end ] -net [get_db [get_nets $net] .name]
}

proc cut_pg_over_macro {args} {

    set results(-min_layer) ""
    set results(-max_layer) ""
    set results(-macros) ""
    set results(-left_ext) "0"
    set results(-right_ext) "0"
    set results(-top_ext) "0"
    set results(-bottom_ext) "0"
    set results(-ext_all_side) "0"
    set results(-selected) ""


   parse_proc_arguments -args $args results
    set min_layer $results(-min_layer)
    set max_layer $results(-max_layer)
    set macros $results(-macros)
    set left_ext $results(-left_ext)
    set right_ext $results(-right_ext)
    set top_ext $results(-top_ext)
    set bottom_ext $results(-bottom_ext)
    set ext_all_side $results(-ext_all_side)
    set selected $results(-selected)

	cut_view_setting $min_layer $max_layer 0

	if {$selected == 1} {
		set macros [get_db selected .name]   
	}

	#set macros [get_db selected .name]
	foreach macro $macros {
		gui_deselect -all
		set i [get_db insts -if {.name==$macro}]
		set box_temp [lindex [get_db $i .bbox] 0]
		if {$ext_all_side != "0"} {
			set box "[expr [lindex $box_temp 0] -${ext_all_side}] [expr [lindex $box_temp 1] -${ext_all_side}] [expr [lindex $box_temp 2] +${ext_all_side}] [expr [lindex $box_temp 3] +${ext_all_side}]"
		} else {
			set box "[expr [lindex $box_temp 0] -${left_ext}] [expr [lindex $box_temp 1] -${bottom_ext}] [expr [lindex $box_temp 2] +${right_ext}] [expr [lindex $box_temp 3] +${top_ext}]"
		}


		#puts "Special Route - COVER"
		foreach R [get_db [get_db [get_obj_in_area -areas $box -obj_type special] -if {.net.name !=VSS && .net.name !=VDD} ] .net.name] {
			if {$R != "0x0"} {
				set_db [get_db nets $R ] .special_wires.status cover
			}
		}

		set lx [expr [lindex $box 0] + 0.02]
		set ly [expr [lindex $box 1] + 0.02]
		set ux [expr [lindex $box 2] - 0.02]
		set uy [expr [lindex $box 3] - 0.02]

		edit_cut_route -only_visible_wires  -box $box
		gui_select -append -rect $box
		delete_selected_from_floorplan
 		
		gui_select -append -line "$lx $ly $ux $ly"
		gui_select -append -line "$lx $ly $lx $uy"
		gui_select -append -line "$lx $uy $ux $uy"
		gui_select -append -line "$ux $ly $ux $uy"
		delete_selected_from_floorplan
	}
		#puts "Special Route - Routed"
		foreach R [get_db [get_db [get_obj_in_area -areas $box -obj_type special] -if {.net.name !=VSS && .net.name !=VDD} ] .net.name] {
			if {$R != "0x0"} {
				set_db [get_db nets $R ] .special_wires.status ROUTED
			}
		}

	cut_view_setting $min_layer $max_layer 1
	deselect_obj -all

}


define_proc_arguments cut_pg_over_macro \
    -info "Cut P/G over macros" \
    -define_args {
	{-min_layer            "Minimum layer to delete" "" string required}
	{-max_layer            "Maximum layer to delete" "" string required}
	{-macros               "Macros list" "" string  optional}
	{-left_ext             "Extension cutting from left" "" string optional}
	{-right_ext            "Extension cutting from right" "" string optional}
	{-top_ext              "Extension cutting from top" "" string optional}
	{-bottom_ext           "Extension cutting from bottom" "" string optional}
	{-ext_all_side         "Extension cutting from all sides" "" string optional}
	{-selected              "selected macro only" "" boolean optional}

    }

proc cut_view_setting {min_layer max_layer onoff} {

set_layer_preference node_inst -is_selectable $onoff
set_layer_preference instanceCell -is_selectable $onoff
set_layer_preference block -is_selectable $onoff
set_layer_preference stdCell -is_selectable $onoff
set_layer_preference coverCell -is_selectable $onoff
set_layer_preference phyCell -is_selectable $onoff
set_layer_preference io -is_selectable $onoff
set_layer_preference areaIo -is_selectable $onoff
set_layer_preference blackBox -is_selectable $onoff
set_layer_preference instanceFunction -is_selectable $onoff
set_layer_preference flop -is_selectable $onoff
set_layer_preference pwrswt -is_selectable $onoff
set_layer_preference isolation -is_selectable $onoff
set_layer_preference shift -is_selectable $onoff
set_layer_preference funcother -is_selectable $onoff
set_layer_preference instanceStatus -is_selectable $onoff
set_layer_preference place -is_selectable $onoff
set_layer_preference fixed -is_selectable $onoff
set_layer_preference cover -is_selectable $onoff
set_layer_preference softfix -is_selectable $onoff
set_layer_preference unplace -is_selectable $onoff
set_layer_preference node_blockage -is_selectable $onoff

set_layer_preference net -is_visible $onoff
set_layer_preference clock -is_visible $onoff


set_layer_preference P0 -is_visible 0
set_layer_preference M0 -is_visible 0
set_layer_preference VIA0 -is_visible 0
set_layer_preference M1 -is_visible 0
set_layer_preference VIA1 -is_visible 0
set_layer_preference M2 -is_visible 0
set_layer_preference VIA2 -is_visible 0
set_layer_preference M3 -is_visible 0
set_layer_preference VIA3 -is_visible 0
set_layer_preference M4 -is_visible 0
set_layer_preference VIA4 -is_visible 0
set_layer_preference M5 -is_visible 0
set_layer_preference VIA5 -is_visible 0
set_layer_preference M6 -is_visible 0
set_layer_preference VIA6 -is_visible 0
set_layer_preference M7 -is_visible 0
set_layer_preference VIA7 -is_visible 0
set_layer_preference M8 -is_visible 0
set_layer_preference VIA8 -is_visible 0
set_layer_preference M9 -is_visible 0
set_layer_preference VIA9 -is_visible 0
set_layer_preference M10 -is_visible 0
set_layer_preference VIA10 -is_visible 0
set_layer_preference M11 -is_visible 0
set_layer_preference VIA11 -is_visible 0
set_layer_preference M12 -is_visible 0
set_layer_preference VIA12 -is_visible 0
set_layer_preference M13 -is_visible 0
set_layer_preference VIA13 -is_visible 0
set_layer_preference M14 -is_visible 0
set_layer_preference VIA14 -is_visible 0
set_layer_preference M15 -is_visible 0
set_layer_preference VIA15 -is_visible 0
set_layer_preference M16 -is_visible 0
set_layer_preference VIA16 -is_visible 0
set_layer_preference M17 -is_visible 0
set_layer_preference RV -is_visible 0
set_layer_preference AP -is_visible 0


for {set i $min_layer} {$i <= $max_layer} {incr i} {

set_layer_preference M${i} -is_visible 1
set_layer_preference VIA${i} -is_visible 1

}
set_layer_preference VIA${max_layer} -is_visible 1

}



set_layer_preference node_row -is_selectable 0
source ./scripts/layout/cut_layer.tcl

	set llist [get_db [get_db insts -if {.base_cell.base_class == block && .base_cell == *M3*}] .name ]
	foreach memory $llist {
		set memory_name [get_db [get_cells $memory] .name]
		set memory_base_name [get_db [get_cells $memory] .base_cell.name]
		set box [lindex [get_db [get_cells $memory] .bbox] 0]
		
		deselect_obj -all	
		cut_view_setting 2 4 0
               	set lx [expr [lindex $box 0] - 0.15]
                set ly [expr [lindex $box 1] - 0.1]
                set ux [expr [lindex $box 2] + 0.15]
                set uy [expr [lindex $box 3] + 0.1]

            	gui_select -line "$lx $ly $lx $uy"
            	gui_select -append -line "$lx $ly $ux $ly"
                delete_selected_from_floorplan
		deselect_obj -all
            	gui_select -line "$ux $ly $ux $uy"
            	gui_select -append -line "$lx $uy $ux $uy"
                delete_selected_from_floorplan
		deselect_obj -all

		if {[string match *M3SRF*BSI* $memory_base_name]} {
			cut_pg_over_macro -macros $memory_name -min_layer 5 -max_layer 6 \
			-left_ext 0.45 -right_ext 0.45 -bottom_ext 0.6 -top_ext 0.6
			set_db add_stripes_stacked_via_top_layer M0
			set_db add_stripes_stacked_via_bottom_layer M0
			set cmd "add_stripes -layer M6  \
			-width 0.076 \
  			-direction horizontal \
  			-set_to_set_distance 0.988 \
			-start_offset  0.076\
  			-spacing 0.418\
  			-nets {VSS VDD} \
  			-insts $memory_name \
   			"
   			eval $cmd
			update_power_vias  -bottom_layer M5 -via_using_exact_crossover_size true  -add_vias 1 \
			 -orthogonal_only 0 -top_layer M7  -create_via_on_signal_pins 1 -area $box	
		}		
		if {[string match *M3SP111* $memory_base_name] || [string match *M3DP222* $memory_base_name]} {
			update_power_vias  -bottom_layer M7 -via_using_exact_crossover_size true  -add_vias 1 \
			 -orthogonal_only 0 -top_layer M8  -create_via_on_signal_pins 1 -area $box	
		}		
		if {[string match *M3SRF*_wrapper $memory_base_name] || [string match *M3PSP* $memory_base_name]} {
			cut_pg_over_macro -macros $memory_name -min_layer 6 -max_layer 6 -ext_all_side 1
			update_power_vias  -bottom_layer M6 -via_using_exact_crossover_size true  -add_vias 1 \
			 -orthogonal_only 0 -top_layer M7  -create_via_on_signal_pins 1 -area $box	
		}		



	}

deselect_obj -all











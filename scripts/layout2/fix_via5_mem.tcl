






reset_db -category generate_special_via
set_db generate_special_via_ignore_drc 1
set_db  generate_special_via_rule_preference VIA56_LONG_H_BW114_UW80
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true


cut_view_setting 5 5 0
set llist [get_db [get_db insts -if {.base_cell.base_class == block && .base_cell == *M5*}] ]

foreach mem $llist {
	set box [lindex [get_db $mem .bbox] 0]

               	set lx [expr [lindex $box 0] - 0.2]
                set ly [expr [lindex $box 1] - 0.2]
                set ux [expr [lindex $box 2] + 0.2]
                set uy [expr [lindex $box 1] + 0.2]

                gui_select -append -rect "$lx $ly $ux $uy"
                delete_selected_from_floorplan
		update_power_vias  -bottom_layer M5 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M6  -create_via_on_signal_pins 1 -area "$lx $ly $ux $uy"

               	set lx [expr [lindex $box 0] - 0.2]
                set ly [expr [lindex $box 3] - 0.2]
                set ux [expr [lindex $box 2] + 0.2]
                set uy [expr [lindex $box 3] + 0.2]

                gui_select -append -rect "$lx $ly $ux $uy"
                delete_selected_from_floorplan
		update_power_vias  -bottom_layer M5 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M6  -create_via_on_signal_pins 1 -area "$lx $ly $ux $uy"


}










foreach mem [get_db insts -if {.base_cell.base_class == block}] {
	set inst [get_db $mem .name]
	set ori [get_db $mem .orient]
	set lx [get_db $mem .bbox.ll.x]
	set ly [expr [get_db $mem .bbox.ll.y] + 0.001]
	set lrowo [get_db [get_obj_in_area -obj_type {row} -polygons "$lx $ly"] .orient]
	set ux [get_db $mem .bbox.ur.x]
	set uy [expr [get_db $mem .bbox.ur.y] - 0.001]
	set urowo [get_db [get_obj_in_area -obj_type {row} -polygons "$ux $uy"] .orient]

	if {$lrowo=="r0"} {set lly 0.84} else {set lly 1.05}
	if {$urowo=="r0"} {set uuy 1.05} else {set uuy 0.84}
	if {$ori=="r0" || $ori=="mx"} {set llx 1.02 ; set uux 0.51} else {set llx 0.51 ;set uux 1.02}

	create_place_halo -halo_deltas "0.02 0 0.02 0" -insts $inst -snap_to_site


}




source scripts/layout/halo4endcap.tcl



#get_db add_endcaps*

set_db add_endcaps_avoid_two_sites_cell_abut  false
set_db add_endcaps_bottom_edge  {}
set_db add_endcaps_boundary_tap  false
set_db add_endcaps_boundary_tap_swap_flow  true
set_db add_endcaps_cells     {}
set_db add_endcaps_create_rows  false
set_db add_endcaps_flip_y    false
set_db add_endcaps_incremental_left_edge  {}
set_db add_endcaps_incremental_right_edge  {}
set_db add_endcaps_left_bottom_corner  {}
set_db add_endcaps_left_bottom_corner_even  {}
set_db add_endcaps_left_bottom_corner_neighbor  {}
set_db add_endcaps_left_bottom_corner_odd  {}
set_db add_endcaps_left_bottom_edge  {}
set_db add_endcaps_left_bottom_edge_even  {}
set_db add_endcaps_left_bottom_edge_neighbor  {}
set_db add_endcaps_left_bottom_edge_odd  {}
set_db add_endcaps_left_edge  F6LLAA_BORDERTIESMRIGHT
set_db add_endcaps_left_edge_bottom_border  {}
set_db add_endcaps_left_edge_even  {}
set_db add_endcaps_left_edge_odd  {}
set_db add_endcaps_left_edge_top_border  {}
set_db add_endcaps_left_top_corner  F6LLAA_BORDERCORNERPTIERIGHT
set_db add_endcaps_left_top_corner_even  {}
set_db add_endcaps_left_top_corner_neighbor  {}
set_db add_endcaps_left_top_corner_odd  {}
set_db add_endcaps_left_top_edge  F6LLAA_BORDERCORNERINTPTIERIGHT
set_db add_endcaps_left_top_edge_even  {}
set_db add_endcaps_left_top_edge_neighbor  {}
set_db add_endcaps_left_top_edge_odd  {}
set_db add_endcaps_min_horizontal_channel_width  4
set_db add_endcaps_min_jog_height  2
set_db add_endcaps_min_jog_width  20
set_db add_endcaps_min_vertical_channel_width  71
set_db add_endcaps_prefix    ENDCAP_
set_db add_endcaps_right_bottom_corner  {}
set_db add_endcaps_right_bottom_corner_even  {}
set_db add_endcaps_right_bottom_corner_neighbor  {}
set_db add_endcaps_right_bottom_corner_odd  {}
set_db add_endcaps_right_bottom_edge  {}
set_db add_endcaps_right_bottom_edge_even  {}
set_db add_endcaps_right_bottom_edge_neighbor  {}
set_db add_endcaps_right_bottom_edge_odd  {}
set_db add_endcaps_right_edge  {}
set_db add_endcaps_right_edge_bottom_border  {}
set_db add_endcaps_right_edge_even  {}
set_db add_endcaps_right_edge_odd  {}
set_db add_endcaps_right_edge_top_border  {}
set_db add_endcaps_right_top_corner  {}
set_db add_endcaps_right_top_corner_even  {}
set_db add_endcaps_right_top_corner_neighbor  {}
set_db add_endcaps_right_top_corner_odd  {}
set_db add_endcaps_right_top_edge  {}
set_db add_endcaps_right_top_edge_even  {}
set_db add_endcaps_right_top_edge_neighbor  {}
set_db add_endcaps_right_top_edge_odd  {}
set_db add_endcaps_top_bottom_edge  {}
set_db add_endcaps_top_edge  {F6LLAA_BORDERROWP16 F6LLAA_BORDERROWP8 F6LLAA_BORDERROWP4 F6LLAA_BORDERROWP2 F6LLAA_BORDERROWP1}
set_db add_endcaps_use_even_odd_sites  none
set_db add_endcaps_wall_keepout_from_vertical_boundary  0.0
set_db add_endcaps_wall_offset  0.0
set_db add_endcaps_wall_pitch  0.0
set_db add_endcaps_wall_to_convex_corner_spacing  0.0




set_db add_endcaps_left_bottom_edge_neighbor  F6LLAA_BORDERROWPGAP
set_db add_endcaps_left_top_edge_neighbor  F6LLAA_BORDERROWPGAP
set_db add_endcaps_right_bottom_edge_neighbor  F6LLAA_BORDERROWPGAP
set_db add_endcaps_right_top_edge_neighbor  F6LLAA_BORDERROWPGAP



eval_legacy { \
	setEndCapMode \
		-min_jog_height 2 \
		-min_jog_width 20 \
		-min_vertical_channel_width 71 \
		-min_horizontal_channel_width 4 \
	}

add_endcaps -prefix ENDCAP





foreach mem [get_db insts -if {.base_cell.base_class == block && .base_cell == *BSI*}] {
	set inst [get_db $mem .name]
	set ori [get_db $mem .orient]
	set lx [get_db $mem .bbox.ll.x]
	set ly [expr [get_db $mem .bbox.ll.y] + 0.001]
	set lrowo [get_db [get_obj_in_area -obj_type {row} -polygons "$lx $ly"] .orient]
	set ux [expr [get_db $mem .bbox.ur.x] -0.8 ]
	set uy [expr [get_db $mem .bbox.ur.y] - 0.001]
	set urowo [get_db [get_obj_in_area -obj_type {row} -polygons "$ux $uy"] .orient]

	if {$lrowo=="r0"} {set lly 0.84} else {set lly 1.05}
	if {$urowo=="r0"} {set uuy 1.05} else {set uuy 0.84}
	if {$ori=="r0" || $ori=="mx"} {set llx 1.02 ; set uux 0.51} else {set llx 0.51 ;set uux 1.02}

	create_place_halo -halo_deltas "5 $lly 5 $uuy" -insts $inst -snap_to_site


}




add_well_taps \
	-checker_board \
	-cell_interval 77.644 \
	-in_row_offset 40.596 \
	-prefix WELLTAP \
	-cell F6LLAA_TIE \
	-fixed_gap

set PRE_PLACE_DECAP "F6LLAA_CCCAP16"

add_well_taps \
	-checker_board \
	-cell_interval 77.644 \
	-in_row_offset 20.043 \
	-prefix FPDCAP \
	-cell $PRE_PLACE_DECAP \
	-fixed_gap



set PRE_PLACE_ECO_DCAP "F6LLAAG_CCCAP16"
set DEFAULT_SITE CORE_6
set ECO_DCAP_Y_STEP 20


foreach mem [get_db insts -if {.base_cell.base_class == block && .base_cell == *BSI*}] {
	set inst [get_db $mem .name]
	set ori [get_db $mem .orient]
	set lx [get_db $mem .bbox.ll.x]
	set ly [expr [get_db $mem .bbox.ll.y] + 0.001]
	set lrowo [get_db [get_obj_in_area -obj_type {row} -polygons "$lx $ly"] .orient]
	set ux [get_db $mem .bbox.ur.x]
	set uy [expr [get_db $mem .bbox.ur.y] - 0.001]
	set urowo [get_db [get_obj_in_area -obj_type {row} -polygons "$ux $uy"] .orient]

	if {$lrowo=="r0"} {set lly 0.84} else {set lly 1.05}
	if {$urowo=="r0"} {set uuy 1.05} else {set uuy 0.84}
	if {$ori=="r0" || $ori=="mx"} {set llx 1.02 ; set uux 0.51} else {set llx 0.51 ;set uux 1.02}

	create_place_halo -halo_deltas "5 5 5 5" -insts $inst -snap_to_site
}


add_gate_array_filler \
	-step_x 38.822 \
	-offset_x 7.956 \
	-step_y [expr $ECO_DCAP_Y_STEP*[lindex [get_db site:$DEFAULT_SITE .size] 0 1]] \
	-offset_y 2.52 \
	-prefix FPGFILL \
	-cell $PRE_PLACE_ECO_DCAP



add_gate_array_filler \
	-step_x 38.822 \
	-offset_x 27.367 \
	-step_y [expr $ECO_DCAP_Y_STEP*[lindex [get_db site:$DEFAULT_SITE .size] 0 1]] \
	-offset_y 4.62 \
	-prefix FPGFILL \
	-cell $PRE_PLACE_ECO_DCAP


source scripts/layout/halo4endcap.tcl

source scripts/layout/flip_gap.tcl


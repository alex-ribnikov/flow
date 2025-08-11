#------------------------------------------------------------------------------
# floorplan size 
#------------------------------------------------------------------------------
#read_def /space/users/royl/nxt007/nextflow/be_work/NXT007/gmu_cluster/gmu_cluster_betterpg/inter/gmu_cluster_empty.def
set core_x_size [expr 0.0005 * 963072]
set core_y_size [expr 0.028 * 9657]    ; # y multiplier must be odd number
set core_x_offset [expr 0.714+0.201*2]
set core_y_offset [expr 0.560+0.028*16]

set_db floorplan_default_tech_site $DEFAULT_SITE

create_floorplan \
	-core_margins_by die \
	-flip s \
	-no_snap_to_grid \
	-site $DEFAULT_SITE \
	-die_size $core_x_size $core_y_size  $core_x_offset $core_y_offset $core_x_offset $core_y_offset


set_db floorplan_check_types odd_even_site_row
check_floorplan
check_floorplan -report_density 

#------------------------------------------------------------------------------
# macro placement 
#------------------------------------------------------------------------------
# placement sites must be odd after Macro placement

#------------------------------------------------------------------------------
# fix routing tracks
#------------------------------------------------------------------------------
delete_tracks
add_tracks \
	-pitch_pattern {m0 offset 0.0 pitch 0.049 {pitch 0.028 repeat 4} pitch 0.049 } \
	-mask_pattern {m0 1 2 1 2 1 2  m1 2 1 m2 1 2 m3 1 2 m4 1 2} \
	-offsets {m1 vert 0.0085 m2 horiz 0.0175 m3 vert 0.0085 m4 horiz 0   m5 vert die_box 0.0505 m6 horiz die_box 0 m7 vert die_box 0.0505 m8 horiz die_box 0 m9 vert die_box 0.0505 m10 horiz die_box 0 m11 vert 0 m12 horiz 0 }

add_dummy_boundary_wires -layers {M1 M2} -space {0.025 0.03}

#------------------------------------------------------------------------------
# create rows
#------------------------------------------------------------------------------
init_core_rows

set_db floorplan_snap_block_grid layer_track
snap_floorplan -block
check_floorplan
set_db floorplan_snap_block_grid finfet_placement
snap_floorplan -block
check_floorplan

#------------------------------------------------------------------------------
# placement blockage
#------------------------------------------------------------------------------
# Fix macro placement
set_db [get_db insts -if {.base_cell.base_class == block}] .place_status fixed


# Cut Rows around memories
foreach mem_dpo [get_db insts -if {.base_cell.base_class == block}] {
#  split_row -honor_row_site_height -area [get_computed_shapes [get_db $mem_dpo .bbox] SIZE 0.5]
  create_place_halo -halo_deltas {0.459 0.392 0.459 0.392} -snap_to_site -insts [get_db $mem_dpo .name]
}


check_floorplan


create_boundary_placement_halo -halo_width 1





set_db finish_floorplan_active_objs {core macro macro_halo hard_blockage}
finish_floorplan -fill_place_blockage hard 5
set_db finish_floorplan_active_objs {core macro macro_halo soft_blockage}
finish_floorplan -fill_place_blockage soft 20

set_db finish_floorplan_drc_region_objs {macro hard_blockage macro_halo min_gap core_spacing non_row_area}
finish_floorplan -drc_region_layer {FB1} -edge_extend {0 0.105} -edge_shrink {0.0255 0 }
#set_db finish_floorplan_drc_region_objs {hard_blockage}
#finish_floorplan -drc_region_layer {FB1} -edge_extend {0.2 0.36}

#------------------------------------------------------------------------------
# place endcap
#------------------------------------------------------------------------------
# this is for N5 H210 lib
eval_legacy { \
	setEndCapMode \
		-min_jog_height 2 \
		-min_jog_width 20 \
		-min_vertical_channel_width 71 \
		-min_horizontal_channel_width 4 \
	}

add_endcaps -prefix ENDCAP
check_endcaps -error 10000 -out_file reports/fp/verifyEndcap.rpt

#------------------------------------------------------------------------------
# place pins
#------------------------------------------------------------------------------
source scripts_local/${DESIGN_NAME}_place_pins.tcl

#------------------------------------------------------------------------------
# power
#------------------------------------------------------------------------------
create_boundary_routing_halo -halo_width 1 -layers {M0 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13}
#source scripts/create_power_grid.tcl
source scripts/create_power_grid.snpsn5.tcl

if {[info exists ILM_FILES] && $ILM_FILES != ""} {
   flatten_ilm
}

delete_obj [get_db route_blockages {-if .name == boundary_route_halo } ]


eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}
check_drc -limit 100000

fix_via -min_step 
eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}
check_drc -limit 100000

create_route_halo -bottom_layer M1 -top_layer $MAX_ROUTING_LAYER -space 1.0 -design_halo 



#------------------------------------------------------------------------------
# place taps , eco dcap and dcaps
#------------------------------------------------------------------------------
set_db add_well_taps_insert_cells $TAPCELL

add_well_taps -checker_board
check_well_taps	-max_distance 45 -report reports/fp/verifyWelltap.rpt

#add_well_taps \
#	-cell $TAPCELL \
#	-cell_interval 90 \
#	-in_row_offset 25 \
#	-checker_board \
#	-avoid_abutment \
#	-site_offset 3

#check_well_taps -cells $TAPCELL -max_distance 45 -avoid_abutment -site_offset 3 -report reports/fp/verifyWelltap.rpt

#add_well_taps -incremental $TAPCELL -cell $TAPCELL -cell_interval 90 -checker_board -avoid_abutment -site_offset 3
#check_well_taps -cells $TAPCELL -max_distance 45 -avoid_abutment -site_offset 3 -report out/verifyWelltap.rpt

add_well_taps \
	-checker_board \
	-cell_interval 90 \
	-in_row_offset 24.182 \
	-prefix FPDCAP \
	-cell $PRE_PLACE_DECAP 
	
set ECO_DCAP_Y_STEP	 10
	
add_gate_array_filler \
	-step_x 74.988 \
	-offset_x 11.282 \
	-step_y [expr $ECO_DCAP_Y_STEP*[lindex [get_db site:$DEFAULT_SITE .size] 0 1]] \
	-offset_y 2.53 \
	-prefix FPGFILL \
	-cell $PRE_PLACE_ECO_DCAP


###   ###  ####   #   # ###
###  #     #   #  #   #  #
### #      ####   #   #  #
###  #     #   #  #   #  #
###   ###  ####    ###  ###
#------------------------------------------------------------------------------
# floorplan size 
#------------------------------------------------------------------------------
set BRCM_DEF 0

if {$BRCM_DEF} {

read_def /bespace/users/royl/deliveries/from_brcm/cbui_top_PG_11Aug2021.def.gz

set_db finish_floorplan_active_objs {core macro macro_halo soft_blockage}
finish_floorplan -fill_place_blockage soft 17

} else {
#read_def /space/users/royl/nxt007/nextflow/be_work/NXT007/gmu_cluster/gmu_cluster_betterpg/inter/gmu_cluster_empty.def
#set core_x_size [expr 0.0005 * 963072]  ;# 480
# SIZE 0.051 BY 0.21
#set core_x_size [expr 0.0005 * 1122000]  ;# 561

## Size calculation:
## Area: 370419.853
## Utilization: 57% 
## FP AREA: 649,859.39
set yMul 10.080
set xMul 27.132

set core_x_size [expr $xMul * 23]   ;# 624.036
set core_y_size [expr $yMul * 86]     ;# 665.28

set core_x_offset 0.0255
#set core_x_offset 0
set core_y_offset 0

set_db floorplan_default_tech_site $DEFAULT_SITE
set_db floorplan_check_types odd_even_site_row

set FILE [open ex.def w]
puts $FILE "VERSION 5.8 ;"
puts $FILE "DESIGN $DESIGN_NAME ;"
puts $FILE "UNITS DISTANCE MICRONS 2000 ;"
puts $FILE "PROPERTYDEFINITIONS"
puts $FILE "COMPONENTPIN designRuleWidth REAL ;"
puts $FILE "    DESIGN FE_CORE_BOX_LL_X REAL 0 ;"
puts $FILE "    DESIGN FE_CORE_BOX_UR_X REAL $core_x_size ;"
puts $FILE "    DESIGN FE_CORE_BOX_LL_Y REAL 0.0000 ;"
puts $FILE "    DESIGN FE_CORE_BOX_UR_Y REAL $core_y_size ;"
puts $FILE "END PROPERTYDEFINITIONS"
puts $FILE ""
puts $FILE "DIEAREA ( 0 0 ) ( [expr 2000*$core_x_size]  [expr 2000*$core_y_size] ) ;"
puts $FILE "END DESIGN"
close $FILE


read_def ex.def
delete_row -all
create_row -site $DEFAULT_SITE

write_def ex1.def -no_core_cells -no_std_cells -no_special_net -no_tracks
exec perl -p -i -e "s#CORE_6 0#CORE_6 51#" ex1.def
exec sed -i "/NONDEFAULTRULES/Q" ex1.def
cat ex1.def | awk "{if (NF > 10 && \$1 == \"ROW\") {n=\$8-1; \$8=n}; print}" > ex2.def

echo "END DESIGN" >> ex2.def
read_def ex2.def
file delete ex.def
file delete ex1.def
file delete ex2.def

if {0} {
create_floorplan \
	-core_margins_by die \
	-flip s \
	-no_snap_to_grid \
	-site $DEFAULT_SITE \
	-die_size $core_x_size $core_y_size  $core_x_offset $core_y_offset $core_x_offset $core_y_offset
}

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
	-mask_pattern {m0 2 2 1 2 1 2  m1 2 1 m2 1 2 m3 1 2 m4 1 2} \
	-offsets {m1 vert 0.0510 m2 horiz 0.0 m3 vert die_box 0.0 m4 horiz 0.0   m5 vert die_box 0.038 m6 horiz die_box 0.04 m7 vert die_box 0.038 m8 horiz die_box 0 m9 vert die_box 0.038 m10 horiz die_box 0 m11 vert die_box 0.038 m12 horiz 0 m13 vert die_box 0.0 m14 horiz 0 m15 vert die_box 0.133 m16 horiz 0.504 }





#------------------------------------------------------------------------------
# create rows
#------------------------------------------------------------------------------

#init_core_rows


#------------------------------------------------------------------------------
# placement blockage
#------------------------------------------------------------------------------
#resize_floorplan -x_size 5.712
## Place Macros
## gcl output
source scripts_local/cbui_top.srams_location.syn_v11p0a.tcl

#set_db floorplan_snap_block_grid layer_track
#snap_floorplan -block
#check_floorplan
#set_db floorplan_snap_block_grid finfet_placement
#snap_floorplan -block
check_floorplan

# check if memories are placed on placement grid. print to screen suggested near location
memory_placement_checker

# Fix macro placement
set_db [get_db insts -if {.base_cell.base_class == block}] .place_status fixed


# Cut Rows around memories
foreach mem_dpo [get_db insts -if {.base_cell.base_class == block}] {
#  split_row -honor_row_site_height -area [get_computed_shapes [get_db $mem_dpo .bbox] SIZE 0.5]
  if {[regexp wrapper [get_db $mem_dpo .base_cell] ]} {
     create_place_halo -orient R0 -halo_deltas {0.0255 0.8 0.1275 1.04} -insts [get_db $mem_dpo .name]
  } elseif {[regexp BSI [get_db $mem_dpo .base_cell] ]} {
      create_place_halo -orient R0 -halo_deltas {0.102 0.8 0.051 0.84} -insts [get_db $mem_dpo .name]
  } else {
     create_place_halo -snap_to_site -orient R0 -halo_deltas {0.153 0.336 0.255 0.536} -insts [get_db $mem_dpo .name]
  }
}


check_floorplan


#create_boundary_placement_halo -halo_width 1






#------------------------------------------------------------------------------
# placement blockage 
#------------------------------------------------------------------------------

set_db finish_floorplan_active_objs {core macro macro_halo hard_blockage}
finish_floorplan -fill_place_blockage hard 5
set_db finish_floorplan_active_objs {core macro macro_halo soft_blockage}
finish_floorplan -fill_place_blockage soft 17

set_db finish_floorplan_drc_region_objs {macro hard_blockage macro_halo min_gap core_spacing non_row_area}
#finish_floorplan -drc_region_layer {FB1} -edge_extend {0 0.105} -edge_shrink {0.0255 0 }
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
delete_markers
check_endcaps -error 10000 -out_file reports/floorplan/verifyEndcap.rpt

if {[llength [get_db markers ]] > 0} {
	set ORIG [get_db floorplan_default_blockage_name_prefix]
	set_db floorplan_default_blockage_name_prefix ENDCAP_marker
	foreach mmm [get_db markers] {
		create_place_blockage -rects [get_db $mmm .bbox] -type hard -use_prefix -no_cut_by_core
	}
	set_db floorplan_default_blockage_name_prefix $ORIG
	
}


#------------------------------------------------------------------------------
# power
#------------------------------------------------------------------------------
add_dummy_boundary_wires -layers {M1 M2 M3 M4} 

#create_boundary_routing_halo -halo_width 0.2 -layers { M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12}
source scripts/flow/create_power_grid.${PROJECT}.tcl


write_db  -verilog      out/db/${DESIGN_NAME}.PG.enc.dat

#------------------------------------------------------------------------------
# place pins
#------------------------------------------------------------------------------
source scripts_local/cbui_top_place_pins.fp19p1c.tcl


#delete_obj [get_db route_blockages {-if .name == boundary_route_halo } ]


eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}

# Fix port color issue
if {[llength [get_db port_shapes -if ".layer.name == M4"]] > 0} {
	deselect_obj -all
	select_obj [get_db port_shapes -if ".layer.name == M4"]
	edit_update_route_mask -to 0
	add_power_mesh_colors
}
if {[llength [get_db port_shapes -if ".layer.name == M3"]] > 0} {
# not working for M3. wrong color for ports
#	deselect_obj -all
#	select_obj [get_db port_shapes -if ".layer.name == M3"]
#	edit_update_route_mask -to 0
#	add_power_mesh_colors
	
	foreach ppp [get_db port_shapes -if ".layer.name == M3"] {
		deselect_obj -all
		select_obj $ppp
		set x [expr ([get_db selected .rect.ll.x] + [get_db selected .rect.ur.x])/2]
		if {![expr int(fmod($x*1000,84)) ]} {
			edit_update_route_mask -to 1
		} else {
			edit_update_route_mask -to 2
		}
	}
	deselect_obj -all
}


write_def -no_tracks -no_std_cells   out/def/${DESIGN_NAME}.for_BRCM.def.gz

check_drc -limit 100000

fix_via -min_step 
check_drc -limit 100000

create_route_halo -bottom_layer M1 -top_layer $MAX_ROUTING_LAYER -space 0.2 -design_halo 

#put M3 blockage on memories and exted it by 0.1 on pins side
memories_m3_blk


finish_floorplan -fill_place_blockage hard 45 -name_prefix TIE_BLK

#------------------------------------------------------------------------------
# place taps , eco dcap and dcaps
#------------------------------------------------------------------------------
set_db add_well_taps_insert_cells $TAPCELL

add_well_taps -checker_board
check_well_taps	-max_distance 45 -report reports/floorplan/verifyWelltap.rpt

delete_obj [get_db place_blockages -if ".name == TIE_BLK*"]

} ;  # if {$BRCM_DEF} {

finish_floorplan -fill_place_blockage hard 45 -name_prefix TIE_BLK

#add_well_taps \
#	-cell $TAPCELL \
#	-cell_interval 90 \
#	-in_row_offset 25 \
#	-checker_board \
#	-avoid_abutment \
#	-site_offset 3

#check_well_taps -cells $TAPCELL -max_distance 45 -avoid_abutment -site_offset 3 -report reports/floorplan/verifyWelltap.rpt

#add_well_taps -incremental $TAPCELL -cell $TAPCELL -cell_interval 90 -checker_board -avoid_abutment -site_offset 3
#check_well_taps -cells $TAPCELL -max_distance 45 -avoid_abutment -site_offset 3 -report out/verifyWelltap.rpt

add_well_taps \
	-checker_board \
	-cell_interval 89.862 \
	-in_row_offset 12.639 \
	-prefix FPDCAP \
	-cell $PRE_PLACE_DECAP 
	
set ECO_DCAP_Y_STEP	 10
	
add_gate_array_filler \
	-step_x 44.931 \
	-offset_x 27.6455 \
	-step_y [expr $ECO_DCAP_Y_STEP*[lindex [get_db site:$DEFAULT_SITE .size] 0 1]] \
	-offset_y 2.52 \
	-prefix FPGFILL \
	-cell $PRE_PLACE_ECO_DCAP

delete_obj [get_db place_blockages -if ".name == TIE_BLK*"]


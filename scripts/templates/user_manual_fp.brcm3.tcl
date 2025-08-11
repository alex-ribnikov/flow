set CONTINUE_ON_ERROR [get_db source_continue_on_error]
set_db source_continue_on_error true

set env(ICPROCESS) cln03
set env(INQA_ROOT) /project/foundry/TSMC/N3/BRCM/20241007/inqa/
eval_legacy {
source /project/foundry/TSMC/N3/BRCM/20241007/inqa/scripts/inqa/floorplanning/setup.tcl
source ./scripts/flow/create_power_grid.brcm3.tcl
}



set xMul 31.92
set yMul 10.868
set die_x [expr $xMul *7]
set die_y [expr $yMul *19]
set boundary_offset_x 0.024
set boundary_offset_y 0.0845


create_floorplan \
       -core_margins_by die \
       -floorplan_origin llcorner \
       -flip s \
       -die_size ${die_x} ${die_y} ${boundary_offset_x} ${boundary_offset_y} ${boundary_offset_x} ${boundary_offset_y} \
       -no_snap_to_grid 



init_core_rows
#split_row

delete_tracks
add_tracks -honor_pitch

add_tracks \
    -offsets {M0 horiz die_box 0.0839 M1 vert die_box -0.006 M2 horiz die_box 0.104 M3 vert die_box 0.0 M4 horiz die_box 0 M5 vert die_box 0.0 M6 horiz die_box 0.038 M7 vert die_box 0.038 M8 horiz die_box 0.038 M9 vert die_box 0.038 M10 horiz die_box 0.038 M11 vert die_box 0.038 M12 horiz die_box 0.038 M13 vert die_box 0.038 M14 horiz die_box 0 M15 vert die_box 0 M16 horiz die_box 0 M17 vert die_box 0 M18 horiz die_box 0 M19 vert die_box 0} \
    -mask_pattern {M0 2 1 2 1 2 1 2 1 2 1 2   1 2 1 2 1 2 1 2 1 2 1  M2 1 2 M5 2 1} \
    -width_pitch_pattern {M0 offset 0.0785  width 0.027 pitch 0.030  width 0.013 pitch 0.023  width 0.013 pitch 0.023  width 0.013 pitch 0.023  width 0.013 pitch 0.030  width 0.027 pitch 0.0305  width 0.014 pitch 0.024  {width 0.014 pitch 0.024 repeat 3}  width 0.014 pitch 0.0305  width 0.027 pitch 0.030  width 0.013 pitch 0.023  width 0.013 pitch 0.023  width 0.013 pitch 0.023  width 0.013 pitch 0.030  width 0.027 pitch 0.0305  width 0.014 pitch 0.024  {width 0.014 pitch 0.024 repeat 3}  width 0.014 pitch 0.0305 } \
    -pitches {M14 horiz 0.143 M15 vert 0.133 M16 horiz 0.286 M17 vert 0.266 M18 horiz 0.988 M19 vert 0.912}

#------------------------------------------------------------------------------
# hard macro placement
#------------------------------------------------------------------------------

#source scripts_local/cbui_top.srams_location.syn_v11p0a.tcl
place_inst i_lcb_unit_i_rs_i_rs_mem_g_channels_0__g_mem_wrap_128_i_mini_rs_1r1w_128x141_ebb_mini_rs_1r1w_128x141_0 {197.904 0.0} my 
place_inst i_lcb_unit_i_rs_i_rs_mem_g_channels_1__g_mem_wrap_128_i_mini_rs_1r1w_128x141_ebb_mini_rs_1r1w_128x141_0 {170.24 0.0} r0 
place_inst i_lcb_unit_i_rs_i_rs_mem_g_channels_2__g_mem_wrap_128_i_mini_rs_1r1w_128x141_ebb_mini_rs_1r1w_128x141_0 {149.264 0.0} my 
place_inst i_lcb_unit_i_rs_i_rs_mem_g_channels_3__g_mem_wrap_128_i_mini_rs_1r1w_128x141_ebb_mini_rs_1r1w_128x141_0 {121.6 0.0} r0 

  ### Check that all macros are on grid.
#eval_legacy {  check_macro_snap_grid }
3memory_placement_checker

# Add Halo arround memories
foreach mem [get_db insts -if {.base_cell.base_class == block && .base_cell == *M3*}] {
#set inst [get_db selected . ]
        set yy 0.8
        set xx 0.65
        set ddy $yy
        set inst [get_db $mem .name]
        set lx [expr [get_db $mem .bbox.ll.x] - $xx]
        set ly [expr [get_db $mem .bbox.ll.y] - $yy]
        set lrowo [get_db [get_obj_in_area -obj_type {row} -polygons "$lx $ly"] .site.name]
        set ux [expr [get_db $mem .bbox.ur.x] + $xx]
        set uy [expr [get_db $mem .bbox.ur.y] + $yy]
        set urowo [get_db [get_obj_in_area -obj_type {row} -polygons "$ux $uy"] .site.name]
        if {[string match *coreW48M143H117* $lrowo]} {set ddy [expr $ddy+0.117]}
        if {[string match *coreW48M143H117* $urowo]} {set uuy [expr $ddy+0.117]}

        create_place_halo -halo_deltas "$xx $ddy $xx $uuy" -insts $inst 

}




#------------------------------------------------------------------------------
# placement blockage 
#------------------------------------------------------------------------------
set_db finish_floorplan_active_objs {core macro macro_halo hard_blockage}
finish_floorplan -fill_place_blockage hard 5
set_db finish_floorplan_active_objs {core macro macro_halo soft_blockage}
finish_floorplan -fill_place_blockage soft 17



#set_db finish_floorplan_drc_region_objs {macro hard_blockage macro_halo min_gap core_spacing non_row_area}

#------------------------------------------------------------------------------
# place endcap
#------------------------------------------------------------------------------

add_endcaps -prefix ENDCAP
delete_markers
check_endcaps -error 10000 -out_file reports/floorplan/verifyEndcap.rpt


###==============================================================
### Add boundary and TAP cell
###==============================================================

add_well_taps -checker_board


#------------------------------------------------------------------------------
# power
#------------------------------------------------------------------------------
  ### Add the Avago power grid.
#read_def scripts_local/AvagoPG908.def.gz 
eval_legacy {    add_avago_power_grid }

# fix power over memories
source ./scripts/layout/fix3_memory_pg.tcl


check_power_vias -check_wire_pin_overlap -error 1000000 -report missing_via.rpt

#------------------------------------------------------------------------------
# place pins
#------------------------------------------------------------------------------
#source scripts_local/cbui_top_place_pins.fp19p1c.tcl
set_db [get_db ports *] .place_status unplaced
delete_obj [get_db port_shapes]
set_db [get_db ports *] .location {0 0}

set_db assign_pins_edit_in_batch true

edit_pin \
   -pin [get_db [get_db ports *tlm*] .name] \
   -layer {M5 M7 M9} \
   -edge 1 \
   -spread_direction clockwise \
   -offset_start 5 \
   -offset_end 10 \
   -pattern fill_checkerboard  \
   -snap track -fixed_pin -fix_overlap 1

edit_pin \
   -pin [get_db [get_db ports *xbar*] .name] \
   -layer { M5 M7 M9  } \
   -edge 1 \
   -spread_direction counterclockwise \
   -offset_start 5 \
   -offset_end 10 \
   -pattern fill_checkerboard  \
   -snap track -fixed_pin -fix_overlap 1
   
edit_pin \
   -pin [get_db [get_db ports *s_data*] .name] \
   -layer { M5 M7 M9  } \
   -edge 1 \
   -spread_direction counterclockwise \
   -offset_start 84 \
   -offset_end 10 \
   -pattern fill_checkerboard  \
   -snap track -fixed_pin -fix_overlap 1




edit_pin \
   -pin [get_db [get_db ports *apb_master_i_*] .name] \
   -layer { M5 M7 M9  } \
   -edge 1 \
   -spread_direction counterclockwise \
   -offset_start 120 \
   -offset_end 10 \
   -pattern fill_checkerboard  \
   -snap track -fixed_pin -fix_overlap 1

edit_pin \
   -pin [get_db [get_db ports -if ".name != *tlm* && .name != *s_data* && .name != *apb_master_i_* && .name != *xbar*"] .name] \
   -layer { M5 M7 M9  } \
   -edge 1 \
   -spread_direction counterclockwise \
   -offset_start 130 \
   -offset_end 10 \
   -pattern fill_checkerboard  \
   -snap track -fixed_pin -fix_overlap 1


set_db assign_pins_edit_in_batch false


eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}

#------------------------------------------------------------------------------
# place taps , eco dcap and dcaps
#------------------------------------------------------------------------------
set_db finish_floorplan_active_objs {core macro macro_halo hard_blockage}
finish_floorplan -fill_place_blockage hard 45 -name_prefix TIE_BLK

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





set_db source_continue_on_error $CONTINUE_ON_ERROR



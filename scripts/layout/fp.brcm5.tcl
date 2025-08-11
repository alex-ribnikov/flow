source ./scripts/procs/source_be_scripts.tcl

set DESIGN_NAME [get_db current_design .name]

set DEFAULT_SITE CORE_6
set MAX_ROUTING_LAYER 16
set MIN_ROUTING_LAYER 2



set yMul 10.080
set xMul 27.132

set core_x_size [expr $xMul * 22]   ;
set core_y_size [expr $yMul * 90]     ;

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


delete_tracks
add_tracks \
	-pitch_pattern {m0 offset 0.0 pitch 0.049 {pitch 0.028 repeat 4} pitch 0.049 } \
	-mask_pattern {m0 2 2 1 2 1 2  m1 2 1 m2 1 2 m3 1 2 m4 1 2} \
	-offsets {m1 vert 0.0510 m2 horiz 0.0 m3 vert die_box 0.0 m4 horiz 0.0   m5 vert die_box 0.038 m6 horiz die_box 0.04 m7 vert die_box 0.038 m8 horiz die_box 0 m9 vert die_box 0.038 m10 horiz die_box 0 m11 vert die_box 0.038 m12 horiz 0 m13 vert die_box 0.0 m14 horiz 0 m15 vert die_box 0.133 m16 horiz 0.504 }


   if [file exists ./placeBbox.tcl] {
      source ./placeBbox.tcl
   } else {
      puts "<FP> Warning: no bbox placement was supplied" 
   }



set_db [get_db insts -if {.base_cell.name == *M5*}] .place_status fixed

source ./scripts/layout/add_well_taps.tcl

set_db finish_floorplan_active_objs {core macro macro_halo hard_blockage}
finish_floorplan -fill_place_blockage hard 5
set_db finish_floorplan_active_objs {core macro macro_halo soft_blockage}
finish_floorplan -fill_place_blockage soft 18

source ./scripts/layout/pre_pg_source.tcl
source ./scripts/layout/pg.brcm5.tcl


   if [file exists ./$DESIGN_NAME\_PINS.def] {
     	read_def ./$DESIGN_NAME\_PINS.def
   } else {
      puts "<FP> Warning: no pin placement was supplied" 
   }




if 0 {
set_db assign_pins_edit_in_batch true


edit_pin \
     -pin   "[get_object_name [get_ports *]]" \
				-fix_overlap 1 \
                               -pattern fill_track \
                              -unit track \
                              -spacing 2 \
                              -snap track \
                              -side top \
                              -start 100 604.8  \
                              -end 940 604.8 \
                              -layer {12 10 8 6} \
				-layer_priority \
                              -fixed_pin 1

}

eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}

# Fix port color issue
if {[llength [get_db port_shapes -if ".layer.name == M4"]] > 0} {
        deselect_obj -all
        select_obj [get_db port_shapes -if ".layer.name == M4"]
        edit_update_route_mask -to 0
        add_power_mesh_colors
}
if {[llength [get_db port_shapes -if ".layer.name == M3"]] > 0} {
        add_power_mesh_colors
        
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


check_floorplan
check_floorplan -report_density


write_def -floorplan -no_std_cells   out/def/${DESIGN_NAME}.for_BRCM.def.gz


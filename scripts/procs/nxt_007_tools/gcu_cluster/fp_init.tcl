# Testing on grid_cluster
#create_floorplan -site core -core_size 481.536 1696.632 0.0 0.0 0.0 0.0
#read_def /space/users/ory/user/myScripts/innovus/grid_cluster_empty_core_def.def

#puts "-I- OY - Load design"
source scr/do_innovusFP.tcl
#
puts "-I- OY - Load empty def"
read_def /space/users/ory/wb_flow/gcu_standalone_ww42/inter/gcu_cluster_empty.def

#set str "( 65664 0 ) ( 65664 36480 )
#        ( 0 36480 ) ( 0 1668960 )
#        ( 32832 1668960 ) ( 32832 1723680 )
#        ( 0 1723680 ) ( 0 2371200 )
#        ( 65664 2371200 ) ( 65664 2444160 )
#        ( 0 2444160 ) ( 0 3356160 )
#        ( 65664 3356160 ) ( 65664 3392640 )
#        ( 897408 3392640 ) ( 897408 3356160 )
#        ( 963072 3356160 ) ( 963072 2444160 )
#        ( 897408 2444160 ) ( 897408 2371200 )
#        ( 963072 2371200 ) ( 963072 1723680 )
#        ( 930240 1723680 ) ( 930240 1668960 )
#        ( 963072 1668960 ) ( 963072 36480 )
#        ( 897408 36480 ) ( 897408 0 )"
#set clean_str [regsub -all " +" [string map {( "" ) ""} $str] " "]
#set list [split $clean_str "\n"]
#foreach line $list {
#
#	if { $line == "" } { continue }
#	set line [split [string trim $line " "] " "]
#	set a [lindex $line 0]
#	set b [lindex $line 1]
#	set c [lindex $line 2]
#	set d [lindex $line 3]
#	puts "([expr $a/2] [expr $b/2]) ([expr $c/2] [expr $d/2])"
#
#}


# From wb fp flow (manully added by Jerome)
connect_global_net VDD  -type pg_pin -pin_base_name VDD 
connect_global_net VDD  -type pg_pin -pin_base_name VPP 
connect_global_net VDD  -type tiehi -all 
connect_global_net VSS  -type pg_pin -pin_base_name VSS  
connect_global_net VSS  -type pg_pin -pin_base_name VBB 
connect_global_net VSS  -type tielo -all 
delete_tracks 
add_tracks -pitch_pattern {m0 offset 0.0 pitch 0.06 {pitch 0.04 repeat 3} pitch 0.06 pitch 0.06 {pitch 0.04 repeat 3} pitch 0.06} -mask_pattern {m0 2 1 2 1 2 1 2 1 2 1 m1 2 1 m2 2 1 m3 1 2} -offsets {m1 vert 0.0 m2 horiz 0.02 m3 vert 0.0 m4 horiz 0.056 m5 vert 0 m6 horiz 0.056 m7 vert 0 m8 horiz 0.056 m9 vert 0 m10 horiz 0 m11 vert 0 m12 horiz 0 m13 vert 0 m14 horiz 0} 
init_core_rows 

######################################################################################################
check_floorplan -odd_even_site_row
######################################################################################################

######################################################################################################
# Macro placement
# Macro placement - Taken from /space/users/ory/grid_cluster/inter/grid_cluster_block_placement.paste
#unplace_obj -blocks
#delete_place_halo -all_blocks
#
#source -e -v /space/users/ory/user/myScripts/innovus/grid_cluster/macro_placement.tcl

####################################################################################

create_boundary_placement_halo -halo_width 1 

set_db finish_floorplan_active_objs {core macro soft_blockage} 
finish_floorplan -fill_place_blockage soft 20 
set_db finish_floorplan_active_objs {core macro hard_blockage} 
finish_floorplan -fill_place_blockage hard 5 

add_endcaps -prefix ENDCAP

check_endcaps -error 10000 -out_file out/verifyEndcap.rpt

add_well_taps -cell TAPCELLBWP240H8P57PDSVT -cell_interval 200 -checker_board -avoid_abutment -site_offset 3

check_well_taps -cells TAPCELLBWP240H8P57PDSVT -max_distance 50 -avoid_abutment -site_offset 3 -report out/verifyWelltap.rpt

add_well_taps -cell TAPCELLBWP240H8P57PDSVT -cell_interval 200 -checker_board -avoid_abutment -site_offset 3

check_well_taps -cells TAPCELLBWP240H8P57PDSVT -max_distance 50 -avoid_abutment -site_offset 3 -report out/verifyWelltap.rpt

create_boundary_routing_halo -halo_width 1 -layers {M0 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12}


####################################################################################

add_well_taps -cell TAPCELLBWP240H8P57PDSVT -cell_interval 200 -checker_board -avoid_abutment -site_offset 3 
check_well_taps -cells TAPCELLBWP240H8P57PDSVT -max_distance 50 -avoid_abutment -site_offset 3 -report out/verifyWelltap.rpt 
add_well_taps -cell TAPCELLBWP240H8P57PDSVT -cell_interval 200 -checker_board -avoid_abutment -site_offset 3 
check_well_taps -cells TAPCELLBWP240H8P57PDSVT -max_distance 50 -avoid_abutment -site_offset 3 -report out/verifyWelltap.rpt 

create_boundary_routing_halo -halo_width 1 -layers {M0 M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12} 

source /space/users/moriya/nextflow/project_flow/NXT007/controls/create_power_grid_v6.0_up_to_M12.tcl

delete_obj [get_db route_blockages {-if .name == boundary_route_halo } ]

eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}

check_drc -limit 100000

fix_via -min_step 

eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}

check_drc -limit 100000

####################################################################################
# 2020 09/10 - I stopped here

source /space/users/ory/user/be_scripts/nxt_007_tools/gcu_cluster/gcu_cluster_guides.tcl
#
create_LEB_guides
#
create_gcu_feedthrough_aon_guides
#
#create_gmu_feedthrough_aon_guides
#
#create_gsu_feedthrough_aon_guides
#
check_drc -limit 100000

# Place pins
source $g_project/inter/gcu_place_pins_ww42.tcl
#
#write_def -floorplan -no_std_cells out/${g_design}_floorplan.def.gz
#
#write_floorplan out/${g_design}_floorplan.fp.gz
#
#write_db -verilog      out/${g_design}.FP.enc.dat
#write_def -routing     out/${g_design}.FP.def.gz
#
#return 
#exit

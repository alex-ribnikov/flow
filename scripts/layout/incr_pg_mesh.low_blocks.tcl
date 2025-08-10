

#set sub_block [get_cells -hierarchical -filter design_type==module&&is_physical&&is_hierarchical -quiet]
#set sub_block [get_cells -quiet {test_top test_top1 test_top2}]; 

#set top_design [get_attribute [current_design] name]
set top_design [get_attribute [current_block] full_name]
set design_name [get_attribute [current_block] design_name]

##########################################################   block-specific overides  ########################################################## 

if {[get_attribute $top_design name] == "cfg_car_top"} {
    set run_overide_pg_mesh_locally 1
	# Einav: modified basic definition in AVGO script (Gilad) - 
    set local_pg_generation_script /bespace/users/ex-gilads/nextflow/be_work/brcm3/nfi_cbu/pnr/RTFM/fc_create_power_grid.brcm3.tcl
    set ips_with_M7M8_pg_pins "ds03_tessent_occ_01 cpll03_pllsys01_top_ns_02"
    set maxInstBlkLyr_subblocks 6
    set run_resize_mem_kom_for_pg_cut 0 ;# default is 0. in case user want to have narrow channels without boundary cells , it go to run_resize_mem_kom_for_pg_cut and edit the script with a list of mems to extent thier KOM.
    set run_clean_pg_around_mems_auto 0
    set run_connect_mems_to_pg_mesh 0
    set run_clean_pg_around_rectangular_block 1  ;# default is 0 , NOTE! for hier-blocks : user need to set to 1 only after the correct cut values per each subblock, see note #5 below
    set run_shift_via9_via10_above_mems 0 ;# to avoid stackRangeMaxStackLevel DRC violations in TF
    set run_revert_resize_mem_kom_for_pg_cut 0 ;# default is to keep KOM extended , if set to 1 then it will revert to original KOM , before extension BUT user will have to put additional blockage to avoid any cells in channels
    set block_ips_with_M7M8_pg_pins ""

    define_user_attribute -classes cell -type boolean -name block_brcm_pg
    set_attribute [get_cells -hier] block_brcm_pg false
    foreach x $ips_with_M7M8_pg_pins {set_attribute [get_cells -hier -filter ref_name==${x}] block_brcm_pg true}

}

##########################################################   USER settings  ########################################################## 

# settings
set fix_m7_missalignment 0 ;# set to 1 if mem is not placed correctly and want to trim M7 staps touching mems, set to 0 if mem was placed correctly and m7 are aliignmened (defalt is 0, meme are aliigned already)
set fix_m7_missalignment_trim 3 ;# relevant only if fix_m7_missalignment is 1. this var specify now many tracks of M7 to trim from memory edges

set VIA5_master   VIA56_LONG_V_BW36_UW76 ;#VIA56_1cut_BW20_UW38 ;#VIA56_LONG_V_BW60_UW76_1 ;
set VIA6_master   VIA67_1cut_BW38_UW76 ;#VIA67_1cut_BW76_UW40
set VIA7_master   VIA78_big_BW76_UW76

set vdd_net VDD
set vss_net VSS

#set top_design [get_attribute [current_design] name]
set top_design [get_attribute [current_block] full_name]
set design_name [get_attribute [current_block] design_name]

set M6_pitch [get_attribute [get_layers M6] pitch]
set M7_pitch [get_attribute [get_layers M7] pitch]
set M6_width [get_attribute [get_layers M6] default_width]
set M6_step   0.988
set M6_area [get_attribute [get_layers M6] min_area]
set M0_bbox_cut_offset_X_mem 0.238 ;#0.214 ;# horizonal distance from mem bbox to cut point in boundary cell pins M0
set M0_bbox_cut_offset_X_core 0.192 ;# horizonal distance from core boundary to cut point in boundary cell pins M0

set row_h1 0.169 ;# row heights
set row_h2 0.117

define_user_attribute -classes cell -type string -name max_layer_pg_pin
define_user_attribute -classes shape -type boolean -name was_cut
define_user_attribute -classes via -type boolean -name valid_for_cut
define_user_attribute -classes shape -type boolean -name valid_for_cut
define_user_attribute -classes cell -type boolean -name was_via_shifted
define_user_attribute -classes cell -type string -name extended_kom

############################################################# create VDD/VSS terminals  ############################################################

if {![sizeof_collection [get_terminals -of [get_ports $vdd_net] -quiet]]} {
    set tvdd [get_shapes -filter layer_name==M19&&shape_use==stripe&&net.name==${vdd_net}]
    create_terminal -of_objects $tvdd
}

if {![sizeof_collection [get_terminals -of [get_ports $vss_net] -quiet]]} {
    set tvss [get_shapes -filter layer_name==M19&&shape_use==stripe&&net.name==${vss_net}]
    create_terminal -of_objects $tvss
}

#connect_pg_net -automatic
connect_pg_net -net $vdd_net [get_pins -hier -filter name==${vdd_net}]
connect_pg_net -net $vss_net [get_pins -hier -filter name==${vss_net}]

############################################################# DRC sanity check  ############################################################

proc sanity_check_drc {} {

    open_drc_error_data DRC_report_by_check_pg_drc_hybrid
    set error_data [get_drc_error_data ]

    echo "INFO-This proc is checking channels or regions which are defined as non-standard cell region because not enclosed by boundary cells"
    set min_metal_width [get_drc_errors -quiet -error_data $error_data -filter type_name=~*Min*Metal*Width*]
    if {[sizeof_collection $min_metal_width]} {
	if {[regexp "no standard cell" [get_attribute [index_collection $min_metal_width 0] error_info]]} {
	    echo "Info-Error!!: user should open check_pg_drc error browser and review all Min Metal Width violations in M0"
	    echo "Info-Error!!: pls review and avoid such regions in your floorplan"
	}
    }
    #regexp "no standard cell" [get_attribute [index_collection $min_metal_width 0] error_info]
    close_drc_error_data [get_drc_error_data ] -force
}

# check pg drc before operations
if {$run_check_pg_drc_pre} {
    check_pg_drc  > check_pg_drc.${design_name}.global.pre
    if {$run_sanity_check_drc} { sanity_check_drc }
    check_pg_missing_vias -nets "$vdd_net $vss_net" > check_pg_missing_vias.${design_name}.pre
}


##########################################################   vias and shape classification   ########################################################## 
proc pg_via_shape_marking {} {
    global vdd_net
    global vss_net
    set all_pg_vias [get_vias -filter (net_type==power||net_type==ground)&&(net.name==${vdd_net}||net.name==${vss_net})]
    set_attribute [get_vias ] valid_for_cut false
    set_attribute  $all_pg_vias valid_for_cut true

    set all_pg_shapes [get_shapes -filter (net_type==power||net_type==ground)&&(net.name==${vdd_net}||net.name==${vss_net})]
    set_attribute [get_shapes ] valid_for_cut false
    set_attribute $all_pg_shapes valid_for_cut true
}

pg_via_shape_marking


############################################################# brcm pg settings  ############################################################
set env(ICPROCESS) cln03
#set env(INQA_ROOT) /project/foundry/TSMC/N3/BRCM/20241007/inqa/
set env(INQA_ROOT) /project/foundry/TSMC/N3/BRCM/PDK/20250416/inqa/  ;# updated by BRCM
source ./scripts/bin/inqa/setup.tcl

set ROUTING_LAYER_DIRECTION_OFFSET_LIST {{M0 horizontal 0.0839} {M1 vertical -0.006} {M2 horizontal 0.104} {M3 vertical 0.0}
    {M4 horizontal 0} {M5 vertical 0.0} {M6 horizontal 0.038} {M7 vertical 0.038}
    {M8 horizontal 0.038} {M9 vertical 0.038} {M10 horizontal 0.038} {M11 vertical 0.038}
    {M12 horizontal 0.038} {M13 vertical 0.038} {M14 horizontal 0} {M15 vertical 0}
    {M16 horizontal 0} {M17 vertical 0} {M18 horizontal 0} {M19 vertical 0}}

if {$ROUTING_LAYER_DIRECTION_OFFSET_LIST != ""} {
    foreach direction_offset_pair $ROUTING_LAYER_DIRECTION_OFFSET_LIST {
	set layer [lindex $direction_offset_pair 0]
	set direction [lindex $direction_offset_pair 1]
	set offset [lindex $direction_offset_pair 2]
	set_attribute [get_layers $layer] routing_direction $direction
	if {$offset != ""} {
	    set_attribute [get_layers $layer] track_offset $offset
	}
    }
}

##########################################################   mems clasification  ########################################################## 
#set mems [get_cells -hierarchical -filter is_hard_macro&&is_memory_cell -quiet ]
set mems [get_cells -hierarchical -filter is_hard_macro&&ref_name=~M3* -quiet ]
set softip [get_cells * -filter "((is_soft_macro==true) && is_physical_only == false && ref_name!~M3*)" -hier]
foreach ip [get_object_name $softip] {
	set ip_mems [get_cells -hierarchical -filter "is_hard_macro && ref_name=~M3* && full_name!~${ip}*" -quiet]
	set mems [remove_from_collection $mems $ip_mems]
}

if {[sizeof_collection $mems ] } {
    set_attribute $mems was_via_shifted false
    set_attribute $mems extended_kom ""

    foreach x [get_object_name $mems] {
	set layer [agMaxBlockedLayer $x]
	set layer_value M${layer};
	case $layer {
	    "5" {
		set M4_exist [get_shapes -quiet -of_objects [get_pins -of_objects [get_cells $x ] -filter port_type==power||port_type==ground] -filter layer.name==M4]
		if {[sizeof_collection $M4_exist]} { set layer_value M${layer}_M4 }
	    }
	    "6" {
		set M5_exist [get_shapes -quiet -of_objects [get_pins -of_objects [get_cells $x ] -filter port_type==power||port_type==ground] -filter layer.name==M5]
		if {[sizeof_collection $M5_exist]} { set layer_value M${layer}_M5 }
	    }
	    "7" {
		set M6_exist [get_shapes -quiet -of_objects [get_pins -of_objects [get_cells $x ] -filter port_type==power||port_type==ground] -filter layer.name==M6]
		if {[sizeof_collection $M6_exist]} { set layer_value M${layer}_M6 }
	    }
	}
	set_attribute -objects [get_cells $x] -name max_layer_pg_pin -value $layer_value
    }
}

##################################################################   procs   ########################################################## 
# Einav: TODO flow good practice should not allow users to overwrite the MEM KOM or add hard blockages before PG/ BWT flow,
# Flow basic:
# BWT
# PG generation
# (this script) PG post processing
# blockages and everything else . . .
proc search_boundary_cells_around_mem {inst at_x at_y side} {
    set marker_cell "" ;# default is no boundary cells
    set x_width [get_attribute [get_cells $inst] width]
    set row_site_on_mem_bbox [get_site_rows -quiet -at "$at_x $at_y" -filter name=~*M143H169*||name=~*M143H117*]
    if {[sizeof_collection $row_site_on_mem_bbox]} {
	set row_site_height [get_attribute $row_site_on_mem_bbox site_height]
	case $side {
	    "south" {
		set y_row [lindex [get_attribute $row_site_on_mem_bbox bbox] 0 1]
		if {$row_site_height == 0.169} {
		    set y_search [expr $y_row - 0.0585]
		} else {
		    set y_search [expr $y_row - 0.2275]
		}
	    }
	    "north" {
		set y_row [lindex [get_attribute $row_site_on_mem_bbox bbox] 1 1]
		if {$row_site_height == 0.169} {
		    set y_search [expr $y_row + 0.0585]
		} else {
		    set y_search [expr $y_row + 0.2275]
		}
	    }
	} ;# y_search
	
	for {set xx $at_x} {$xx < [expr $x_width+$at_x]} {set xx [expr 0.5+$xx]} {
	    set marker_cell_temp [index_collection [get_cells -quiet -filter ref_name=~*BORDER* -at "$xx $y_search"] 0]
	    if {[sizeof_collection $marker_cell_temp]} {set marker_cell $marker_cell_temp}
	}
    }
    return $marker_cell
}

# check all mems has same X dir halso width - OK
# check why some mems dobt have is_memory_cell attrubute
# dangling via , check pg drc
# floating instances , missing vias

##############################################################   clean mems     ##############################################################    
proc clean_pg_around_mems_auto {mems cut_intersect_vias} {
    foreach x [get_object_name $mems] {
	echo "INFO - cleaning pg around mem:$x"
	global fix_m7_missalignment_trim;
	global fix_m7_missalignment;
	global M7_pitch;
	global M0_bbox_cut_offset_X_mem;

	# south side
	set marker_cell ""
	set LLX [lindex [get_attribute [get_cells $x] boundary_bbox]  0 0]
	set LLX_ext [lindex [get_attribute [get_cells $x] bbox]  0 0];
	set LLY [lindex [get_attribute [get_cells $x] bbox]  0 1]
	set LLY_cut $LLY
	set marker_cell [search_boundary_cells_around_mem $x $LLX $LLY south] ;# call search function
	if {[sizeof_collection $marker_cell]} {
	    set lly [lindex [get_attribute $marker_cell boundary_bbox] 0 1]
	    set LLY_cut [expr ([get_attribute $marker_cell height]/2.0 + $lly)]
	}

	# north side
	set marker_cell ""
	set URX [lindex [get_attribute [get_cells $x] boundary_bbox]  1 0]
	set URX_ext [lindex [get_attribute [get_cells $x] bbox]  1 0];
	set URY [lindex [get_attribute [get_cells $x] bbox]  1 1]
	set URY_cut $URY
	set marker_cell [search_boundary_cells_around_mem $x $LLX $URY north] ;# call search function
	if {[sizeof_collection $marker_cell]} {
	    set lly [lindex [get_attribute $marker_cell boundary_bbox] 0 1]
	    set URY_cut [expr ([get_attribute $marker_cell height]/2.0 + $lly)]
	}
	
	set LLX_cut [expr [lindex [get_attribute [get_cells $x] bbox] 0 0] -$M0_bbox_cut_offset_X_mem];
	set URX_cut [expr [lindex [get_attribute [get_cells $x] bbox] 1 0] +$M0_bbox_cut_offset_X_mem]
	set resize_llx [expr -1*($LLX_cut-$LLX_ext)] ; set resize_lly [expr $LLY-$LLY_cut]
	set resize_urx [expr $URX_cut-$URX_ext] ; set resize_ury [expr -1*($URY-$URY_cut)]
	
	set split_area [get_attribute [resize_polygons -size "$resize_llx $resize_lly $resize_urx $resize_ury" [get_attribute [get_cells $x] bounding_box]] bbox]
	
	# shapes cleanup
	set split_objects [get_shapes -quiet -intersect $split_area -filter layer.name==M0&&shape_use==stripe&&valid_for_cut] ;# M0 objects to split
	if {[sizeof_collection $split_objects]} {split_objects $split_objects -rect $split_area}
	set shape2remove [get_shapes -touching  $split_area -filter layer_name==M0&&valid_for_cut -quiet] 
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
	set shape2remove [get_shapes -within  $split_area -filter layer_name==M0&&valid_for_cut -quiet] ;# possible leftovers from previous cuts
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
    
	set split_objects [get_shapes -quiet -intersect $split_area -filter layer.name==M1&&shape_use==stripe&&valid_for_cut] ;# M1 objects to split
	if {[sizeof_collection $split_objects]} {split_objects $split_objects -rect $split_area}
	set shape2remove [get_shapes -touching  $split_area -filter layer_name==M1&&valid_for_cut -quiet] 
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
 	set shape2remove [get_shapes -within  $split_area -filter layer_name==M1&&valid_for_cut -quiet] ;# possible leftovers from previous cuts
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
   
	set split_objects [get_shapes -quiet -intersect $split_area -filter layer.name==M5&&shape_use==stripe&&valid_for_cut] ;# M5 objects to split
	if {[sizeof_collection $split_objects]} {split_objects $split_objects -rect $split_area}
	set shape2remove [get_shapes -touching  $split_area -filter layer_name==M5&&valid_for_cut -quiet] 
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
	set shape2remove [get_shapes -within  $split_area -filter layer_name==M5&&valid_for_cut -quiet] ;# possible leftovers from previous cuts
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
	
	if {([get_attribute [get_cells $x ] max_layer_pg_pin] == "M7") && $fix_m7_missalignment} {
	    #split by mem area with min spacing
	    set resize_llx [expr  $fix_m7_missalignment_trim*$M7_pitch] ;set resize_lly [expr  $fix_m7_missalignment_trim*$M7_pitch]; set resize_urx [expr  $fix_m7_missalignment_trim*$M7_pitch];set resize_ury [expr  $fix_m7_missalignment_trim*$M7_pitch] ;# USER can set this to other values, default is 3 tracks
	    set split_area_m7 [get_attribute [resize_polygons -size "$resize_llx $resize_lly $resize_urx $resize_ury" [get_attribute [get_cells $x] boundary_bbox]] bbox]
	    set split_objects [get_shapes -quiet -intersect $split_area_m7 -filter layer.name==M7&&shape_use==stripe&&valid_for_cut] ;# M7 objects to split
	    if {[sizeof_collection $split_objects]} {split_objects $split_objects -rect $split_area_m7}
	    set shape2remove [get_shapes -touching  $split_area_m7 -filter layer_name==M7&&valid_for_cut -quiet]; if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
	    set via2remove [ get_vias -within $split_area_m7 -filter lower_layer_name==M7&&valid_for_cut -quiet ];	if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	    set shape2remove [get_shapes -within  $split_area_m7 -filter layer_name==M7&&valid_for_cut -quiet]; if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove} ;# possible leftovers from previous cuts
	    
	}
	
	# vias cleanup , touching
	set via2remove [get_vias -within $split_area -filter lower_layer_name==M0&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	set via2remove [get_vias -within $split_area -filter lower_layer_name==M1&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	set via2remove [get_vias -within $split_area -filter lower_layer_name==M2&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	
	set via2remove [get_vias -within $split_area -filter lower_layer_name==M3&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	set via2remove [get_vias -within $split_area -filter lower_layer_name==M4&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	
	set via2remove [get_vias -within $split_area -filter lower_layer_name==M5&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	set via2remove [get_vias -within $split_area -filter lower_layer_name==M6&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	
	# vias cleanup , intersect vias
	if {$cut_intersect_vias} {
	    set via2remove [get_vias -intersect $split_area -filter lower_layer_name==M0&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	    set via2remove [get_vias -intersect $split_area -filter lower_layer_name==M1&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	    set via2remove [get_vias -intersect $split_area -filter lower_layer_name==M2&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	    
	    set via2remove [get_vias -intersect $split_area -filter lower_layer_name==M3&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	    set via2remove [get_vias -intersect $split_area -filter lower_layer_name==M4&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	    
	    set via2remove [get_vias -intersect $split_area -filter lower_layer_name==M5&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	    set via2remove [get_vias -intersect $split_area -filter lower_layer_name==M6&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	}
    }
} ;# end proc

##############################################################   clean pg by bbox manuall     ##############################################################    

proc clean_pg_inside_bbox_manual {llx lly urx ury layer} {
    echo "set clean_area \[create_poly_rect -boundary \{ \{$llx $lly\} \{$urx $ury\} \}]" > _a ; source _a
    if {![regexp VIA $layer]} {
	set shape2remove [get_shapes -quiet -within $clean_area -filter layer.name==$layer&&shape_use==stripe&&valid_for_cut]
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
    } else {
	set via2remove [get_vias -quiet -within $clean_area -filter cut_layer_names==$layer&&shape_use==stripe&&valid_for_cut]
	if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
    }
}

    
##############################################################   clean block boundary     ##############################################################    
proc clean_pg_around_die_auto {} {
    global M0_bbox_cut_offset_X_core
    global row_h2
    global top_design
    global run_clean_m5_VIA5_m6_VIA6_from_block_boundary
    set resize_llx [expr -1*$M0_bbox_cut_offset_X_core]
    set resize_lly [expr  -1*$row_h2/2.0]
    set resize_urx [expr -1*$M0_bbox_cut_offset_X_core]
    set resize_ury [expr  -1*$row_h2/2.0]
    
	set top_module_name [get_att [current_block] top_module_name]
    set split_area_core [get_attribute [resize_polygons -size "$resize_llx $resize_lly $resize_urx $resize_ury" [get_attribute [current_block] core_area_boundary]] poly_rects]
    set split_area_die [get_attribute [current_block] boundary_bounding_box]
    set split_area_m5 [get_attribute [resize_polygons -size "0 0 0 0" [get_attribute [current_block] core_area_boundary]] poly_rects]
    
    #shapes cleanup M0
	reshape_objects -force -simple -keep_inside -cut [get_att $split_area_core point_list ] [get_shapes -intersect $split_area_core -filter layer.name==M0&&shape_use==stripe&&physical_status!=locked]
    #shapes cleanup M1
	reshape_objects -force -simple -keep_inside -cut [get_att $split_area_core point_list ] [get_shapes -intersect $split_area_core -filter layer.name==M1&&shape_use==stripe&&physical_status!=locked]
	set via1to4in [get_vias -within $split_area_core -filter "(lower_layer.name==M0 || lower_layer.name==M1 || lower_layer.name==M2 || lower_layer.name==M3 || lower_layer.name==M4) && shape_use==stripe && physical_status!=locked"]
	set via1to4all [get_vias -filter "(lower_layer.name==M0 || lower_layer.name==M1 || lower_layer.name==M2 || lower_layer.name==M3 || lower_layer.name==M4) && shape_use==stripe&&physical_status!=locked"]
	remove_vias -force -verbose [remove_from_collection $via1to4all $via1to4in]

    # shapes cleanup M5
    if {$run_clean_m5_VIA5_m6_VIA6_from_block_boundary} {
		reshape_objects -force -simple -keep_inside -cut [get_att $split_area_m5 point_list ] [get_shapes -intersect $split_area_m5 -filter layer.name==M5&&width==0.02&&shape_use==stripe&&physical_status!=locked]
		set via5in [get_vias -within $split_area_core -filter "(lower_layer.name==M6 || upper_layer.name==M6) && shape_use==stripe && physical_status!=locked"]
		set via5all [get_vias -filter "(lower_layer.name==M6 || upper_layer.name==M6) && shape_use==stripe && physical_status!=locked"]
		remove_vias -force -verbose [remove_from_collection $via5all $via5in]
	}

} ;# end clean_pg_around_die_auto


##############################################################   connect mems to pg mesh     ##############################################################    

proc connect_mems_to_pg_mesh {mems} {

    global M6_step
    global M6_width
    global M6_pitch
    global VIA5_master
    global VIA6_master
    global VIA7_master
    global vss_net
    global vdd_net
    global run_shift_via9_via10_above_mems
    
    foreach x [get_object_name [get_cells -quiet $mems -filter max_layer_pg_pin==M5]] {
	echo "INFO-connecting pg pins for mem:$x]"
	#VDD
	#    set M6_loc_y_1st [expr 0 - 1.5*$M6_pitch ]
	set M6_loc_y_1st [expr $M6_step/2.0]
	
	create_pg_wire_pattern M6_mesh_1st \
	    -direction horizontal -layer M6 -width [expr 2*$M6_width] -pitch "$M6_step" \
	    -center $M6_loc_y_1st \
	    -spacing $M6_pitch -track_alignment track
        
	set_pg_strategy M6_strategy_1st -pattern "{name: M6_mesh_1st} {nets: $vdd_net}" -macros $x
	
	set_pg_via_master_rule VIA56_rule_1st -contact_code "$VIA5_master $VIA6_master" -via_array_dimension {1 1} -cut_spacing {1 1} ;
	
	#set_pg_via_master_rule VIA56_rule_1st  -via_array_dimension {1 1} -cut_spacing {1 1} ;# use default via defs
	
	set_pg_strategy_via_rule VIA56_strategy_1st -via_rule "{{intersection : adjacent}{via_master: VIA56_rule_1st}}"
	
#	check_pg_drc  -coordinates [get_attribute [get_cells $x] bbox] > check_pg_drc.mems_with_M5_pins.pre
	
	compile_pg -strategies {M6_strategy_1st} -via_rule {VIA56_strategy_1st} -tag M6_strategy_1st ;# compile VDD
	
	#VSS
	set M6_loc_y_2nd 0
	
	create_pg_wire_pattern M6_mesh_2nd \
	    -direction horizontal -layer M6 -width [expr 2*$M6_width] -pitch "$M6_step" \
	    -center $M6_loc_y_2nd \
	    -spacing $M6_pitch -track_alignment track
	
	
	set_pg_strategy M6_strategy_2nd -pattern "{name: M6_mesh_2nd} {nets: $vss_net}" -macros $x
	
	set_pg_via_master_rule VIA56_rule_2nd -contact_code "$VIA5_master $VIA6_master" -via_array_dimension {1 1} -cut_spacing {1 1} ;
	
	#set_pg_via_master_rule VIA56_rule_2nd  -via_array_dimension {1 1} -cut_spacing {1 1} ;# use default via defs
	
	set_pg_strategy_via_rule VIA56_strategy_2nd -via_rule "{{intersection : adjacent}{via_master: VIA56_rule_2nd}}"
	
	compile_pg -strategies {M6_strategy_2nd} -via_rule {VIA56_strategy_2nd} -tag M6_strategy_2nd ;# compile VS
	
#	check_pg_drc  -coordinates [get_attribute [get_cells $x] bbox] > check_pg_drc.mems_with_M5_pins.post
	
    }
    
    foreach x [get_object_name [get_cells -quiet $mems -filter max_layer_pg_pin==M6]] {
	# Note , the current VSS intersection in M6 to M7 inresction has more than 4 stack via, so the rule :"Stack via range rule" fails
	#  VDD intersection is ok
	# in TF stackRangeMaxStackLevel	= 4 , for those layers
	
	#7. Violation of the rule "Stack via range rule":
	#Status:          Error
	#Layer:           VIA6
	#Violation bbox:  {303.981 18.753} {304.019 18.791}
	#Maximal number:  4
	#Actual number:   5
	#Object itself:   is new ndm-simple-via(0x334469a28)
	#                box : {{303.981 18.753} {304.019 18.791}}

	echo "INFO-connecting pg pins for mem:$x]"

	if {$run_shift_via9_via10_above_mems} {

	    create_pg_vias -within_bbox [get_attribute [get_cells $x] boundary_bbox] \
		-nets "$vss_net" \
		-tag ${vss_net}_VIA6_mem \
		-from_layers M6 -from_types {macro_pin_connect macro_pin} \
		-to_layer M7 -to_types {stripe} \
		-via_master $VIA6_master
	} else {
	    create_pg_vias -within_bbox [get_attribute [get_cells $x] boundary_bbox] \
		-nets "$vss_net" \
		-tag ${vss_net}_VIA6_mem \
		-from_layers M6 -from_types {macro_pin_connect macro_pin} \
		-to_layer M7 -to_types {stripe} \
		-show_phantom \
		-drc check_but_no_fix \
		-via_master $VIA6_master
	}
	
	create_pg_vias -within_bbox [get_attribute [get_cells $x] boundary_bbox] \
	    -nets "$vdd_net" \
	    -tag ${vdd_net}_VIA6_mem \
	    -from_layers M6 -from_types {macro_pin_connect macro_pin} \
	    -to_layer M7 -to_types {stripe} \
	    -via_master $VIA6_master
	
    }
    
    foreach x [get_object_name [get_cells -quiet $mems -filter max_layer_pg_pin==M7]] {
	echo "INFO-connecting pg pins for mem:$x]"
	if {$run_shift_via9_via10_above_mems} {
	    # in case via was shiftet to solve stackRangeMaxStackLevel
	    
	    create_pg_vias -within_bbox [get_attribute [get_cells $x] boundary_bbox] \
		-nets "$vss_net" \
		-tag ${vss_net}_VIA7_mem \
		-from_layers M7 -from_types {macro_pin_connect macro_pin} \
		-to_layer M8 -to_types {stripe} \
		-via_master $VIA7_master
	} else {
	    create_pg_vias -within_bbox [get_attribute [get_cells $x] boundary_bbox] \
		-nets "$vss_net" \
		-tag ${vss_net}_VIA7_mem \
		-from_layers M7 -from_types {macro_pin_connect macro_pin} \
		-to_layer M8 -to_types {stripe} \
		-show_phantom \
		-drc check_but_no_fix \
		-via_master $VIA7_master
	}
	
	create_pg_vias -within_bbox [get_attribute [get_cells $x] boundary_bbox] \
	    -nets "$vdd_net" \
	    -tag ${vdd_net}_VIA7_mem \
	    -from_layers M7 -from_types {macro_pin_connect macro_pin} \
	    -to_layer M8 -to_types {stripe} \
	    -via_master $VIA7_master

    }

    # support for mix-layer mems M6_M5
    foreach x [get_object_name [get_cells -quiet $mems -filter max_layer_pg_pin==M6_M5]] {
	echo "INFO-connecting pg pins for mem:$x]"
	echo "INFO-connecting mem with mixed pins in M6 and M5 is CURRENTLY NOT SUPPORTED -NDM need to be updated to remove M6 blockage"

	#VDD
	#    set M6_loc_y_1st [expr 0 - 1.5*$M6_pitch ]

	set M6_loc_y_1st [expr $M6_step/2.0]
	
	create_pg_wire_pattern M6_mesh_1st \
	    -direction horizontal -layer M6 -width [expr 2*$M6_width] -pitch "$M6_step" \
	    -center $M6_loc_y_1st \
	    -spacing $M6_pitch -track_alignment track
    
    
	set_pg_strategy M6_strategy_1st -pattern "{name: M6_mesh_1st} {nets: $vdd_net}" -macros $x
	
	set_pg_via_master_rule VIA56_rule_1st -contact_code "$VIA5_master $VIA6_master" -via_array_dimension {1 1} -cut_spacing {1 1} ;
	
	#set_pg_via_master_rule VIA56_rule_1st  -via_array_dimension {1 1} -cut_spacing {1 1} ;# use default via defs
	
	set_pg_strategy_via_rule VIA56_strategy_1st -via_rule "{{intersection : adjacent}{via_master: VIA56_rule_1st}}"
##	set_pg_strategy_via_rule no_via -via_rule { {{strategies: M6_strategy_1st }} {{intersection: all} {via_master: NIL}}} ;# OK
	
#	check_pg_drc  -coordinates [get_attribute [get_cells $x] bbox] > check_pg_drc.mems_with_M5_M6_pins.pre
	
	compile_pg -strategies {M6_strategy_1st} -via_rule {VIA56_strategy_1st} -tag M6_strategy_1st ;# compile VDD
##	compile_pg -strategies {M6_strategy_1st} -via_rule no_via -tag M6_strategy_1st ;# compile VDD ;# OK
	
	#VSS
	set M6_loc_y_2nd 0
	
	create_pg_wire_pattern M6_mesh_2nd \
	    -direction horizontal -layer M6 -width [expr 2*$M6_width] -pitch "$M6_step" \
	    -center $M6_loc_y_2nd \
	    -spacing $M6_pitch -track_alignment track
	
	
	set_pg_strategy M6_strategy_2nd -pattern "{name: M6_mesh_2nd} {nets: $vss_net}" -macros $x
	
	set_pg_via_master_rule VIA56_rule_2nd -contact_code "$VIA5_master $VIA6_master" -via_array_dimension {1 1} -cut_spacing {1 1} ;
	
	#set_pg_via_master_rule VIA56_rule_2nd  -via_array_dimension {1 1} -cut_spacing {1 1} ;# use default via defs
	
	set_pg_strategy_via_rule VIA56_strategy_2nd -via_rule "{{intersection : adjacent}{via_master: VIA56_rule_2nd}}"
	
	compile_pg -strategies {M6_strategy_2nd} -via_rule {VIA56_strategy_2nd} -tag M6_strategy_2nd ;# compile VS
	
#	check_pg_drc  -coordinates [get_attribute [get_cells $x] bbox] > check_pg_drc.mems_with_M5_M6_pins.post
	
	######## connecting the exiting M6 pins of the mixed mem to M7

	if {$run_shift_via9_via10_above_mems} {

	    create_pg_vias -within_bbox [get_attribute [get_cells $x] boundary_bbox] \
		-nets "$vss_net" \
		-tag ${vss_net}_VIA6_mem \
		-from_layers M6 -from_types {macro_pin_connect macro_pin} \
		-to_layer M7 -to_types {stripe} \
		-via_master $VIA6_master
	} else {
	    create_pg_vias -within_bbox [get_attribute [get_cells $x] boundary_bbox] \
		-nets "$vss_net" \
		-tag ${vss_net}_VIA6_mem \
		-from_layers M6 -from_types {macro_pin_connect macro_pin} \
		-to_layer M7 -to_types {stripe} \
		-show_phantom \
		-drc check_but_no_fix \
		-via_master $VIA6_master
	}
	
	create_pg_vias -within_bbox [get_attribute [get_cells $x] boundary_bbox] \
	    -nets "$vdd_net" \
	    -tag ${vdd_net}_VIA6_mem \
	    -from_layers M6 -from_types {macro_pin_connect macro_pin} \
	    -to_layer M7 -to_types {stripe} \
	    -via_master $VIA6_master
	
    }

} ;# end proc connect_mems_to_pg_mesh



##############################################################   clean rectangular sub-blocks    ##############################################################    

proc clean_pg_around_rectangular_block {cell llx lly urx ury cut_intersect_vias layer} {
    set x $cell
    echo "INFO - cleaning pg around cell:$x"

	set split_area [get_attribute [resize_polygons -size "$llx $lly $urx $ury" [get_attribute [get_cells $x] boundary_bounding_box]] bbox]

    if {![regexp VIA $layer]} {

	# shapes cleanup
	set split_objects [get_shapes  -quiet -intersect $split_area -filter layer.name==${layer}&&shape_use==stripe&&physical_status!=locked&&valid_for_cut] ;# M1 objects to split
	if {[sizeof_collection $split_objects]} {split_objects $split_objects -rect $split_area}
	set shape2remove [get_shapes -touching  $split_area -filter layer_name==${layer}&&shape_use==stripe&&physical_status!=locked&&valid_for_cut -quiet] 
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
    
    } else {
	
	# vias cleanup , touching cut_layers.name
	set via2remove [get_vias -within $split_area -filter cut_layers.name==${layer}&&physical_status!=locked&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	
	# vias cleanup , intersect vias
	if {$cut_intersect_vias} {
	    set via2remove [get_vias -intersect $split_area -filter cut_layers.name==${layer}&&valid_for_cut -quiet ];if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	}
    }
} ;# end proc clean_pg_around_rectangular_block

##############################################################   fix stackRangeMaxStackLevel   ##############################################################    

proc shift_via9_via10_above_mems {mems} {
    if {[sizeof_collection $mems]} {
	set_snap_setting -enabled 0
	foreach x [get_object_name [get_cells $mems]] {
	    if {![get_attribute [get_cells $x] was_via_shifted]} {
		echo "INFO-shifting vias for mem:$x"
		set via2shift_via9 [get_vias -quiet -within [get_attribute [get_cells $x] bbox] -filter via_def_name==P3VIA910A_MH143&&net.name==VSS]
		if {[sizeof_collection $via2shift_via9]} {move_objects -delta {0.0 0.494} $via2shift_via9}
		set via2shift_via10 [get_vias -quiet -within [get_attribute [get_cells $x] bbox] -filter via_def_name==P3VIA1011A_MH143&&net.name==VSS]
		if {[sizeof_collection $via2shift_via10]} {move_objects -delta {0.0 0.494} $via2shift_via10}
		set_attribute [get_cells $x] was_via_shifted true
	    } else {
		echo "INFO- vias are already shifter for mem:$x"
	    }
	}
	set_snap_setting -enabled 1
    }
}

##############################################################   connect BORDERWALL cells   ##############################################################    

proc mark_and_connect_borderrownwall_objects {cells} {
    foreach x [get_object_name $cells] {
	set shape2extent  [get_shapes -quiet -intersect [get_attribute [get_cells -quiet $x] bbox] -filter layer.name==M1&&net.name==VSS&&valid_for_cut]
	if {[sizeof_collection $shape2extent]} {set_attribute $shape2extent physical_status locked}
	# search existing via and mark as locked, if not exist then create the via and mark locked.
	set via2keep [get_vias -quiet -within [get_attribute [get_cells $x] bbox] -filter lower_layer_name==M0&&net.name==VSS&&valid_for_cut] ;# search within
	if {![sizeof_collection $via2keep]} {
	    set via2keep [get_vias -quiet -intersect [get_attribute [get_cells $x] bbox] -filter lower_layer_name==M0&&net.name==VSS&&valid_for_cut] ;# search intersect
	}
	if {![sizeof_collection $via2keep]} {
	    # create the via and connect
	    set vss_m0_pin_shape [get_shapes -of_objects [get_pins -of_objects [get_cells -quiet $x] -filter name==VSS] -filter layer.name==M0&&valid_for_cut]
	    set origin_x [expr [lindex [get_attribute $shape2extent bbox] 0 0]+[get_attribute $shape2extent width]/2.0]
	    set origin_y [expr [lindex [get_attribute $vss_m0_pin_shape bbox] 0 1]+0.027/2.0]
	    set via2keep [create_via -via_def P3VIA01Z_MH143 -origin "$origin_x $origin_y" -net VSS]
	}
	set_attribute $via2keep physical_status locked
    }
}

proc mark_and_connect_borderrowpwall_objects {cells} {
    foreach x [get_object_name $cells] {
	echo "work on cell $x]"
	set shape2extent  [get_shapes -quiet -intersect [get_attribute [get_cells -quiet $x] bbox] -filter layer.name==M1&&net.name==VDD]
	if {[sizeof_collection $shape2extent]} {set_attribute $shape2extent physical_status locked}
	# search existing via and mark as locked, if not exist then create the via and mark locked.
	set via2keep [get_vias -quiet -within [get_attribute [get_cells $x] bbox] -filter lower_layer_name==M0&&net.name==VDD&&valid_for_cut] ;# search within
	if {![sizeof_collection $via2keep]} {
	    set via2keep [get_vias -quiet -intersect [get_attribute [get_cells $x] bbox] -filter lower_layer_name==M0&&net.name==VDD&&valid_for_cut] ;# search intersect
	}
	if {![sizeof_collection $via2keep]} {
	    # create the via and connect
	    set vdd_m0_pin_shape [get_shapes -of_objects [get_pins -of_objects [get_cells -quiet $x] -filter name==VDD] -filter layer.name==M0&&valid_for_cut]
	    set origin_x [expr [lindex [get_attribute $shape2extent bbox] 0 0]+[get_attribute $shape2extent width]/2.0]
	    set origin_y [expr [lindex [get_attribute $vdd_m0_pin_shape bbox] 0 1]+0.027/2.0]
	    set via2keep [create_via -via_def P3VIA01Z_MH143 -origin "$origin_x $origin_y" -net VDD]
	}
	set_attribute $via2keep physical_status locked
    }
}

set BORDERROWNWALL_cells [get_flat_cells  -quiet -filter ref_name=~*_BORDERROWNWALL -all -hierarchical]
set BORDERROWPWALL_cells [get_flat_cells  -quiet -filter ref_name=~*_BORDERROWPWALL -all -hierarchical]

if {$run_mark_and_connect_borderrownwall_objects && [sizeof_collection $BORDERROWNWALL_cells]} {mark_and_connect_borderrownwall_objects $BORDERROWNWALL_cells}
if {$run_mark_and_connect_borderrowpwall_objects && [sizeof_collection $BORDERROWPWALL_cells]} {mark_and_connect_borderrowpwall_objects $BORDERROWPWALL_cells}

############################################################# DRC fixing ############################################################
proc bbox_center {bbox} {
    set llx [lindex $bbox  0 0];set lly [lindex $bbox  0 1];set urx [lindex $bbox   1 0];set ury [lindex $bbox   1 1];
    return "[expr $llx +($urx-$llx)/2.0] [expr $lly + ($ury-$lly)/2.0]"
}

proc auto_fix_drc {} {
    #
    open_drc_error_data DRC_report_by_check_pg_drc_hybrid
    set error_data [get_drc_error_data ]
    # min spacing cause by cutting out via around mems

    #fixing DRC type : ".Layer min spacing" on M3 and M5
    set layer_min_spacing [get_drc_errors -quiet -error_data $error_data -filter type_name=~*.Layer*min*spac*]
    if {[sizeof_collection $layer_min_spacing]} {
	foreach_in_collection x $layer_min_spacing {
	    set drc_bbox [get_attribute $x bbox]
	    set drc_net_name [get_object_name [get_attribute $x objects]]
	    set drc_layer [get_object_name [get_attribute $x layers]]
	    if {$drc_layer== "M3" || $drc_layer == "M5"} {
		create_shape -boundary $drc_bbox -layer $drc_layer -net $drc_net_name -shape_type rect -shape_use stripe
	    }
	}
    }
    #fixing DRC type : ""One Neighbor End-of-Line Spacing" on M3 and M5
    set One_Neighbor_EndofLine_spacing [get_drc_errors -quiet -error_data $error_data -filter type_name=~*.One*Neighbor*End-of-Line*Spacing*]
        if {[sizeof_collection $One_Neighbor_EndofLine_spacing]} {
	foreach_in_collection x $One_Neighbor_EndofLine_spacing {
	    set drc_bbox [get_attribute $x bbox]
	    set drc_net_name [get_object_name [get_attribute $x objects]]
	    set drc_layer [get_object_name [get_attribute $x layers]]
	    if {$drc_layer== "M3" || $drc_layer == "M5"} {
		create_shape -boundary $drc_bbox -layer $drc_layer -net $drc_net_name -shape_type rect -shape_use stripe
	    }
	}
    }
    #fixing DRC type : "No illegal overlaps of routing objects on VIA0"
    set illegal_overlaps_via0 [get_drc_errors -quiet -error_data $error_data -filter type_name=~*No*illegal*overlaps*of*routing*objects*]
    if {[sizeof_collection $illegal_overlaps_via0]} {
	foreach_in_collection x $illegal_overlaps_via0 {
	    set drc_bbox [get_attribute $x bbox]
	    set drc_bbox_center [bbox_center $drc_bbox]
	    set drc_net_name [get_object_name [get_attribute $x objects]]
	    set drc_layer [get_object_name [get_attribute $x layers]]
	    if {$drc_layer== "VIA0"} {
		set via2remove [get_vias -at $drc_bbox_center -filter cut_layers.name==$drc_layer&&net.name==$drc_net_name -quiet ]
		if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
		# USER should ignore those missing vias from report since it's was removed due to drc violations
	    }
	}
    }

    #set Double_pattern_sidetoside_minspacing_m0 [get_drc_errors -quiet -error_data $error_data -filter type_name=~*Double*pattern*side-to-side*min*spacing*]
    set Double_pattern_sidetoside_minspacing_m0 "" ;# fix is disabled for now
    if {[sizeof_collection $Double_pattern_sidetoside_minspacing_m0]} {
	foreach_in_collection x $Double_pattern_sidetoside_minspacing_m0 {
	    set drc_bbox [get_attribute $x bbox]
	    set drc_bbox_center [bbox_center $drc_bbox]
	    set drc_net_name [get_object_name [get_attribute $x objects]]
	    set drc_layer [get_object_name [get_attribute $x layers]]
	    if {$drc_layer== "M0"} {
		set drc_via [get_vias -intersect $drc_bbox -filter lower_layer.name==$drc_layer&&net.name==$drc_net_name -quiet ]
		if {[sizeof_collection $drc_via]} {
		    echo "INFO- drc_bbox:$drc_bbox, num of intesected vias:[sizeof_collection $drc_via]"
		    set drc_via_mask [get_attribute $drc_via lower_mask_constraint]
		    if {$drc_via_mask == "no_mask" } {derive_pg_mask_constraint}
		    if {$drc_via_mask == "mask_one" } {set_attribute $drc_via lower_mask_constraint mask_two} else {set_attribute $drc_via lower_mask_constraint mask_one}
		}
	    }
	}
    }
    
    close_drc_error_data [get_drc_error_data ] -force
}

############################################################# missing via fixing  ############################################################

proc auto_fix_missing_via {vdd_net vss_net} {

    check_pg_missing_vias -nets "$vdd_net $vss_net" 
    open_drc_error_data [get_attr [current_block] name]*missingVia.err
    set error_data [get_drc_error_data [get_attr [current_block] name]*missingVia.err]

#    check_pg_missing_vias -nets "$vdd_net $vss_net" 
#    open_drc_error_data *missingVia.err
#    set error_data [get_drc_error_data ]

    #close_drc_error_data [get_drc_error_data ] -force
    #remove_drc_error_data $error_data
    
    if {[sizeof_collection $error_data]>1} {
	#close_drc_error_data [get_drc_error_data ] -force
    }

    # objects to fix
    set missing_vias_m0 [get_drc_errors -quiet -error_data $error_data -filter error_info=~*Missing*via*of*net*on*layer*VIA0*from*via*rule:default]
    
    if {[sizeof_collection $missing_vias_m0]} {
	foreach_in_collection x $missing_vias_m0 {
	    set drc_bbox [get_attribute $x bbox]
	    set drc_net_name [get_object_name [get_attribute $x objects]]
	    set drc_layer [get_object_name [get_attribute $x layers]]
	    set via_origin [bbox_center $drc_bbox]
	    if {$drc_layer== "VIA0"} {
		create_via -via_def P3VIA01Z_MH143 -origin $via_origin -net $drc_net_name -shape_use stripe
	    }
	}
    }
    close_drc_error_data [get_drc_error_data ] -force
    
}

############################################################# resize KOM for narrow channels  ############################################################

proc resize_mem_kom_for_pg_cut {x resize_llx resize_lly resize_urx resize_ury} {
    set kom [get_keepout_margins -of_objects [get_cells $x]]
    set old_kom_boundary [get_attribute $kom boundary]
    set old_mem_bbox  [get_attribute [get_cells $x] bbox]
    set old_margin [get_attribute $kom margin]
    set llx [expr [lindex $old_margin 0] + $resize_llx];
    set lly [expr [lindex $old_margin 1] + $resize_lly];
    set urx [expr [lindex $old_margin 2] + $resize_urx];
    set ury [expr [lindex $old_margin 1] + $resize_ury];

    set_attribute [get_cells $x] extended_kom [get_attribute $kom margin]
    set_attribute $kom margin "$llx $lly $urx $ury"
    
    set new_mem_bbox  [get_attribute [get_cells $x] bbox]
    set kom [get_keepout_margins -of_objects [get_cells $x]]
    set new_kom_boundary [get_attribute $kom boundary]

    echo "INFO - Warning! KOM of mem: [get_object_name $x] is being changed from $old_mem_bbox TO $new_mem_bbox"
}

############################################################# add PG local script ############################################################

proc overide_pg_mesh_locally {} {

    global local_pg_generation_script
    global maxInstBlkLyr_subblocks

    set_app_option -name file.def.check_mask_constraints -value none
    set_app_option -name shell.undo.enabled -value false
    
    read_def ./scripts/layout/brcm3_pg_via.def
    #source -echo -verbose /project/foundry/TSMC/N3/BRCM/PDK/20241007/Synopsys/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R_enterprise_MH143.extra_vias_for_iccii.tcl
    source -echo -verbose $local_pg_generation_script
    
    set_app_option -name shell.undo.enabled -value false

    add_avago_power_grid

}


##############################################################   EXECUTION tasks    ##############################################################    

if {$run_overide_pg_mesh_locally} {
    if {[get_attribute $top_design name] == "cfg_car_top"} {
	overide_pg_mesh_locally ;# re-create pg with correct blockages on IPs
	pg_via_shape_marking ;# re-mark pg
    }
}

if {$run_resize_mem_kom_for_pg_cut} {
    # put here the mems that has small channels witout boundary cells, and extent their existing KOM by llx lly urx ury

    # for example for mcu_top block, spefic FP used for test cases :
    if {$design_name == "mcu_top"} {
	resize_mem_kom_for_pg_cut i_mcu_i_mcu_squad_i_bin_complex_g_bin_2__i_bin_i_lookup_i_sdt_i_sdt_mem_i_mcu_sdt_mem_ebb_memory_split_a1_d0 2 0 2 0
	resize_mem_kom_for_pg_cut i_mcu_i_mcu_squad_i_bin_complex_g_bin_2__i_bin_i_lookup_i_sdt_i_sdt_mem_i_mcu_sdt_mem_ebb_memory_split_a2_d0 2 0 2 0
	resize_mem_kom_for_pg_cut i_mcu_i_mcu_squad_i_bin_complex_g_bin_0__i_bin_i_lookup_i_sdt_i_sdt_mem_i_mcu_sdt_mem_ebb_memory_split_a2_d0 2 0 2 0
	resize_mem_kom_for_pg_cut i_mcu_i_mcu_squad_i_bin_complex_g_bin_0__i_bin_i_lookup_i_sdt_i_sdt_mem_i_mcu_sdt_mem_ebb_memory_split_a1_d0 2 0 2 0
	resize_mem_kom_for_pg_cut i_mcu_i_mcu_squad_i_bin_complex_g_bin_1__i_bin_i_lookup_i_sdt_i_sdt_mem_i_mcu_sdt_mem_ebb_memory_split_a2_d0 2 0 2 0
	resize_mem_kom_for_pg_cut i_mcu_i_mcu_squad_i_bin_complex_g_bin_1__i_bin_i_lookup_i_sdt_i_sdt_mem_i_mcu_sdt_mem_ebb_memory_split_a1_d0 2 0 2 0
	resize_mem_kom_for_pg_cut i_mcu_i_mcu_squad_i_bin_complex_g_bin_3__i_bin_i_lookup_i_sdt_i_sdt_mem_i_mcu_sdt_mem_ebb_memory_split_a2_d0 2 0 2 0
	resize_mem_kom_for_pg_cut i_mcu_i_mcu_squad_i_bin_complex_g_bin_3__i_bin_i_lookup_i_sdt_i_sdt_mem_i_mcu_sdt_mem_ebb_memory_split_a1_d0 2 0 2 0
    }
}


if {$run_clean_pg_around_mems_auto} {clean_pg_around_mems_auto $mems 1}
if {$run_clean_pg_around_die_auto} {clean_pg_around_die_auto}
if {$run_shift_via9_via10_above_mems} {
    shift_via9_via10_above_mems [get_cells -quiet $mems -filter max_layer_pg_pin==M6]
    shift_via9_via10_above_mems [get_cells -quiet $mems -filter max_layer_pg_pin==M7]
    shift_via9_via10_above_mems [get_cells -quiet $mems -filter max_layer_pg_pin==M6_M5]
}

if {$run_connect_mems_to_pg_mesh} {connect_mems_to_pg_mesh $mems}

if {$run_clean_pg_around_rectangular_block} {

    # for blocks with other IPs except memories, USER need to add specific cutting around them , see below :
    if {[get_attribute $top_design name] == "cfg_car_top"} {

	###############################  cutting PG from IP halo  #####################################################
	#PLL - for example , user can set different cutting for different layers
	set pll_inst_name [get_object_name [get_cells -filter ref_name==cpll03_pllsys01_top_ns_02 -hierarchical ]]
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 M0
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 M1
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 M2
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 M3
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 M4
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 M5
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 M6
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 VIA0
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 VIA1
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 VIA2
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 VIA3
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 VIA4
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 VIA5
	clean_pg_around_rectangular_block $pll_inst_name 15.192 15.301 15.192 15.301 1 VIA6
	
	#OCC1 - for example for all the 7 instances same cutting
	foreach x [get_object_name [get_cells -hier -filter ref_name==ds03_tessent_occ_01]] {
	    foreach xx [list M0 M1 M2 M3 M4 M5 M6 VIA0 VIA1 VIA2 VIA3 VIA4 VIA5 VIA6] {
		clean_pg_around_rectangular_block $x 0.216 0.14 0.216 2.8795 1 $xx
	    }
	}
	
	################################  cutting PG from IP physical edge ################################################
	#PLL - 
	foreach x [get_object_name [get_cells -hier -filter ref_name==cpll03_pllsys01_top_ns_02]] {
	    foreach xx [list M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 M17 M18 M19 VIA7 VIA8 VIA9 VIA10 VIA11 VIA12 VIA13 VIA14 VIA15 VIA16 VIA17 VIA18] {
		clean_pg_around_rectangular_block $x 0 0 0 0 1 $xx
	    }
	}
	#OCC- 
	foreach x [get_object_name [get_cells -hier -filter ref_name==ds03_tessent_occ_01]] {
	    foreach xx [list M7 M8 VIA7] {
		clean_pg_around_rectangular_block $x 0 0 0 0 1 $xx
	    }
	}
	

    } ;# END block  cfg_car_top
}


##############################################################   junk yard    ##############################################################    

#set_attribute -objects [get_vias VIA_S_2] -name via_def -value [get_via_defs -library [get_libs test_4pg_lib] -quiet VIA67_1cut_BW76_UW40] ;# WA

#remove_vias [get_vias -within [get_attribute [get_cells $x] boundary_bbox] -filter net_type==power]
#remove_vias [get_vias -within [get_attribute [get_cells $x] boundary_bbox] -filter net_type==ground]
#remove_vias [get_vias -intersect [get_attribute [get_cells $x] boundary_bbox] -filter net_type==power]
#remove_vias [get_vias -intersect [get_attribute [get_cells $x] boundary_bbox] -filter net_type==ground]

#connect_pg_net -automatic
#check_lvs -checks {short open} -nets "VDD VSS" -max_errors 100000000
#check_lvs -checks {short open} -nets "VDD VSS" -max_errors 100000000 -check_child_cells 0
#check_pg_missing_vias -nets "VDD VSS" -within_bbox [get_attribute [get_cells $mems ] bbox]

#  1 Layer min spacing on M3
#  1 One Neighbor End-of-Line Spacing on M3
#  1 preferred and non-preferred end-of-line spacing rule on M3

# for debug cfg_car_top_lib
legalize_placement
add_tie_cells -objects [get_pins -leaf -of_objects [get_cells -hierarchical ] -filter constant_value==0]
add_tie_cells -objects [get_pins -leaf -of_objects [get_cells -hierarchical ] -filter constant_value==1]
legalize_placement -cells [get_cells -filter ref_name=~*_TIE*]
connect_pg_net -net $vdd_net [get_pins -hier -filter name==${vdd_net}]
connect_pg_net -net $vss_net [get_pins -hier -filter name==${vss_net}]
check_lvs -checks {short open} -nets "$vdd_net $vss_net" -exclude_child_cell_types lib_cell -max_errors 10000 -check_child_cells 0 -open_reporting detailed

#set_attribute [get_vias -filter cut_layer_names==VIA4&&valid_for_cut] is_cut_mask_fixed true
#[get_vias -filter cut_layer_names==VIA4&&valid_for_cut]
#cfg_car_top     VIA_C_1446142   boolean     is_cut_mask_fixed     false
#cfg_car_top     VIA_C_1446142   boolean     is_lower_mask_fixed   false
#cfg_car_top     VIA_C_1446142   boolean     is_upper_mask_fixed   true
#cfg_car_top     VIA_C_1446142   string      lower_mask_constraint no_mask


#set via4_mask_one [get_vias -filter cut_layer_names==VIA4&&valid_for_cut&&upper_mask_constraint==mask_one]
#set via4_mask_two [get_vias -filter cut_layer_names==VIA4&&valid_for_cut&&upper_mask_constraint==mask_two]

#set_attribute $via4_mask_one upper_mask_constraint mask_two
#set_attribute $via4_mask_two upper_mask_constraint mask_one


#to do
# 1. clean PG from block boundaries
################################################################################ control settings  ###################################################3

set add_pg_mesh_to_top 1 ;# set to 1 if top block has no pg inside , then flow will it.
set add_pg_mesh_to_mcn 1 ;# default is 0;only set to 1 if mcn is bbox and has no pg shapes inside.
set clean_pg_around_subblocks 1;
set bbox2module_frame 1 ;# default is 0, no need for now
set maxInstBlkLyr_subblocks 5 ;#
set run_clean_pg_around_die_auto 1
set local_pg_generation_script /bespace/users/ex-gilads/nextflow/be_work/brcm3/nfi_cbu/pnr/RTFM/fc_create_power_grid.brcm3.tcl
set boundary_root_dir /bespace/users/ex-gilads/nextflow/be_work/brcm3/nfi_cbu/pnr/bwt_flow/
set run_clean_m5_VIA5_m6_VIA6_from_block_boundary 1 ;# set 1 if want to keep only M7 continous, this is the default.

open_block  out/grid_quadrant_lib:grid_quadrant; # bbox + without boundary cells
#open_block  out/2nd/grid_quadrant_lib:grid_quadrant  ;# with boundary cells from liorz
#open_block  out/2nd/grid_quadrant_lib:grid_quadrant/compile
#open_block  out/2nd/grid_quadrant_lib:w_bnd_cells
#open_block  out/2nd/grid_quadrant_lib:clean_pg_around_die

#set_editability -blocks [get_blocks ] -value true
#report_editability -blocks [get_blocks ]

#set top_design [get_attribute [current_design] name]
set top_design [current_block]

#set all_subblocks_ref_name [get_attribute [get_blocks -filter name!=$top_design] name] ;# for bbox design
set all_subblocks_ref_name "grid_quad_east_filler_row_top grid_quad_north_filler_col_top grid_quad_west_filler_row_top fcb_ensemble_top mcn"



set M0_bbox_cut_offset_X_core 0.192 ;# horizonal distance from core boundary to cut point in boundary cell pins M0
set row_h1 0.169 ;# row heights
set row_h2 0.117

define_user_attribute -classes cell -type boolean -name block_brcm_pg

set_attribute [get_cells -hier] block_brcm_pg false
foreach x $all_subblocks_ref_name {set_attribute [get_cells -filter ref_name==${x}] block_brcm_pg true}

###################################################################################### brcm PG settings  ###################################################3

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


###################################################################################### add PG for MCN block ###################################################3
if {$add_pg_mesh_to_mcn} {
    current_block mcn

    set_app_option -name file.def.check_mask_constraints -value none
    set_app_option -name shell.undo.enabled -value false
    set_app_option -name file.def.support_via_matrix -value true
    
    read_def ./scripts/layout/brcm3_pg_via.def
    source ./scripts/layout/fc_create_power_grid.brcm3.tcl
    
    set_app_option -name shell.undo.enabled -value false
    set_app_option -name file.def.support_via_matrix -value true
    
    report_app_options file.def.support_via_matrix
    
    add_avago_power_grid
    save_block
    close_block
    current_block $top_design
}


##################################################################################################################################
if {$bbox2module_frame} {
    foreach x $all_subblocks_ref_name {
	current_block $x
	#    create_abstract -read
	create_frame
	save_block
	close_block
    }

    current_block $top_design

    #set_attribute [get_designs $all_subblocks_ref_name] -name design_type -value macro
    set_attribute [get_designs * -hier ] -name design_type -value macro
    
    set_attribute [get_blocks] -name design_type -value macro
    #    set_editability -blocks [get_blocks ] -value false
}


###################################################################################### add boundary cells      ###################################################

if {![sizeof_collection [get_placement_blockages FR_PB*]]} {
    # FR_PB are generated during boundary flow to mark bloced area between boundary cells and subblocks.
    set run_check_legality false ;# to save runtime, will be run seperatly
    set ROOT [file normalize $boundary_root_dir]
    source -echo -verbose $ROOT/insert_bwt_cells.tcl
    save_block -as w_bnd_cells
}

#close_lib;

#exit

###################################################################################### add PG for grid quadrant ##################################################
if {$add_pg_mesh_to_top} {
    #set top_design [get_attribute [current_design] name]
    #set all_subblocks_ref_name [get_attribute [get_blocks -filter name!=$top_design] name]
    
    set_app_option -name file.def.check_mask_constraints -value none
    set_app_option -name shell.undo.enabled -value false
    set_app_option -name file.def.support_via_matrix -value true

    read_def ./scripts/layout/brcm3_pg_via.def
    #source ./scripts/layout/fc_create_power_grid.brcm3.tcl
    source $local_pg_generation_script ;# local copy to support current grid quadrant

    set_app_option -name shell.undo.enabled -value false
    set_app_option -name file.def.support_via_matrix -value true
    
    report_app_options file.def.support_via_matrix
    
    add_avago_power_grid
    save_block -as w_pg
}

########################################################################## settings for clean PG for grid quadrant ###################################################3

define_user_attribute -classes via -type boolean -name valid_for_cut
define_user_attribute -classes via_matrix -type boolean -name valid_for_cut1 ;# for via matrix
define_user_attribute -classes shape -type boolean -name valid_for_cut ;# for signle via

set all_pg_via_matrix [get_via_matrix -quiet -filter net_type==power||net_type==ground]  ;# for via matrix, if exist
set all_via_matrix  [get_via_matrix -quiet]
if {[sizeof_collection $all_via_matrix]} {set_attribute $all_via_matrix valid_for_cut1 false}
if {[sizeof_collection $all_pg_via_matrix]} {set_attribute $all_pg_via_matrix valid_for_cut1 true}

set all_pg_vias [get_vias -quiet -filter net_type==power||net_type==ground] ;# for vias
set all_vias [get_vias -quiet]
if {[sizeof_collection $all_vias]} {set_attribute $all_vias valid_for_cut false}
if {[sizeof_collection $all_pg_vias]} {set_attribute $all_pg_vias valid_for_cut true}

set all_pg_shapes [get_shapes -filter net_type==power||net_type==ground] ;# for shapes
set_attribute [get_shapes ] valid_for_cut false
set_attribute $all_pg_shapes valid_for_cut true

################################################################# convert via_matrix to single vias   ###################################################3
# need to convert some via matrix in regions near the blocks , so that some signle vias can be removed from those areas


set matrix2vias [get_via_matrixes -filter lower_layer_name==M0&&shape_use==stripe&&valid_for_cut1 -quiet] ;# VIA0
if {[sizeof_collection $matrix2vias]} {
    convert_via_matrixes_to_vias $matrix2vias
    set all_pg_vias [get_vias -filter net_type==power||net_type==ground]
    set_attribute [get_vias ] valid_for_cut false
    set_attribute  $all_pg_vias valid_for_cut true
}

set matrix2vias [get_via_matrixes -filter lower_layer_name==M1&&shape_use==stripe&&valid_for_cut1 -quiet] ;# VIA1
if {[sizeof_collection $matrix2vias]} {
    convert_via_matrixes_to_vias $matrix2vias
    set all_pg_vias [get_vias -filter net_type==power||net_type==ground]
    set_attribute [get_vias ] valid_for_cut false
    set_attribute  $all_pg_vias valid_for_cut true
}

set matrix2vias [get_via_matrixes -filter lower_layer_name==M2&&shape_use==stripe&&valid_for_cut1 -quiet] ;# VIA2
if {[sizeof_collection $matrix2vias]} {
    convert_via_matrixes_to_vias $matrix2vias
    set all_pg_vias [get_vias -filter net_type==power||net_type==ground]
    set_attribute [get_vias ] valid_for_cut false
    set_attribute  $all_pg_vias valid_for_cut true
}

set matrix2vias [get_via_matrixes -filter lower_layer_name==M3&&shape_use==stripe&&valid_for_cut1 -quiet] ;# VIA3
if {[sizeof_collection $matrix2vias]} {
    convert_via_matrixes_to_vias $matrix2vias
    set all_pg_vias [get_vias -filter net_type==power||net_type==ground]
    set_attribute [get_vias ] valid_for_cut false
    set_attribute  $all_pg_vias valid_for_cut true
}

set matrix2vias [get_via_matrixes -filter lower_layer_name==M4&&shape_use==stripe&&valid_for_cut1 -quiet] ;# VIA4
if {[sizeof_collection $matrix2vias]} {
    convert_via_matrixes_to_vias $matrix2vias
    set all_pg_vias [get_vias -filter net_type==power||net_type==ground]
    set_attribute [get_vias ] valid_for_cut false
    set_attribute  $all_pg_vias valid_for_cut true
}

if {$run_clean_m5_VIA5_m6_VIA6_from_block_boundary} {
    set matrix2vias [get_via_matrixes -filter lower_layer_name==M5&&shape_use==stripe&&valid_for_cut1 -quiet] ;# VIA5
    if {[sizeof_collection $matrix2vias]} {
	convert_via_matrixes_to_vias $matrix2vias
	set all_pg_vias [get_vias -filter net_type==power||net_type==ground]
	set_attribute [get_vias ] valid_for_cut false
	set_attribute  $all_pg_vias valid_for_cut true
    }
    set matrix2vias [get_via_matrixes -filter lower_layer_name==M6&&shape_use==stripe&&valid_for_cut1 -quiet] ;# VIA6
    if {[sizeof_collection $matrix2vias]} {
	convert_via_matrixes_to_vias $matrix2vias
	set all_pg_vias [get_vias -filter net_type==power||net_type==ground]
	set_attribute [get_vias ] valid_for_cut false
	set_attribute  $all_pg_vias valid_for_cut true
    }
}

###################################################################################### clean PG for grid quadrant ###################################################3

if {$clean_pg_around_subblocks} {
    set shapes2remove_all_M0 ""
    set shapes2remove_all_M1 ""
    set vias2remove_all_VIA0 ""
    set vias2remove_all_VIA1 ""
    set vias2remove_all_VIA2 ""
    set vias2remove_all_VIA3 ""
    set vias2remove_all_VIA4 ""
    set vias2remove_all_VIA5 ""
    set vias2remove_all_VIA6 ""

   
    set cnt 0
    foreach_in_collection x [get_placement_blockages FR_PB_*] {
	#    set x [get_placement_blockages FR_PB_12]
	echo "working on PB $cnt : [get_object_name $x]"
	set split_area [get_attribute [resize_polygons -size "0.216 0.0585 0.216 0.0585" [get_attribute $x boundary]] poly_rects]
	#set split_objects [get_shapes -intersect $split_area -filter layer.name==M0&&shape_use==stripe&&valid_for_cut] ;# M0 objects to split
	
	#in case of complex block shape , like L-shape or other, need to split by line
	for {set i 0} {$i< [llength [get_attribute $split_area point_list]]} {incr i} {
	    set current_point [list [lindex [get_attribute $split_area point_list] $i]]
	    set next_point [list [lindex [get_attribute $split_area point_list] [expr 1+$i]]]
	    if {$i == [expr [llength [get_attribute $split_area point_list]]-1]} {
		set next_point [list [lindex [get_attribute $split_area point_list] 0]] ;
	    }
	    set split_objects_M0 [get_shapes -quiet -intersect $split_area -filter layer.name==M0&&shape_use==stripe&&valid_for_cut] ;# M0 objects to split
	    if {[sizeof_collection $split_objects_M0]} {split_objects $split_objects_M0 -line "$current_point $next_point"}
	    set split_objects_M1 [get_shapes -quiet -intersect $split_area -filter layer.name==M1&&shape_use==stripe&&valid_for_cut] ;# M1 objects to split
	    if {[sizeof_collection $split_objects_M1]} {split_objects $split_objects_M1 -line "$current_point $next_point"}
	    if {$run_clean_m5_VIA5_m6_VIA6_from_block_boundary} {
		set split_objects_M5 [get_shapes -quiet -intersect $split_area -filter layer.name==M5&&shape_use==stripe&&valid_for_cut] ;# M5 objects to split
		if {[sizeof_collection $split_objects_M5]} {split_objects $split_objects_M5 -line "$current_point $next_point"}
	    }
	}
	
	# shapes cleanup
	set shapes2remove [get_shapes -quiet -touching $split_area -filter layer.name==M0&&shape_use==stripe&&valid_for_cut] ;# M0 objects to split
	if {[sizeof_collection $shapes2remove]} {append_to_collection shapes2remove_all_M0 $shapes2remove}
	set shapes2remove [get_shapes -quiet -touching $split_area -filter layer.name==M1&&shape_use==stripe&&valid_for_cut] ;# M1 objects to split
	if {[sizeof_collection $shapes2remove]} {append_to_collection shapes2remove_all_M1 $shapes2remove}
	if {$run_clean_m5_VIA5_m6_VIA6_from_block_boundary} {
	    set shapes2remove [get_shapes -quiet -touching $split_area -filter layer.name==M5&&shape_use==stripe&&valid_for_cut] ;# M5 objects to split
	    if {[sizeof_collection $shapes2remove]} {append_to_collection shapes2remove_all_M5 $shapes2remove}
	    
	}
	# vias cleanup
	set vias2remove [get_vias -quiet -intersect  $split_area -filter lower_layer_name==M0&&shape_use==stripe&&valid_for_cut] ;# VIA0 intersect
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA0 $vias2remove}
	set vias2remove [get_vias -quiet -within $split_area -filter lower_layer_name==M0&&shape_use==stripe&&valid_for_cut] ;# VIA0 within
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA0 $vias2remove}
	
	set vias2remove [get_vias -quiet -intersect  $split_area -filter lower_layer_name==M1&&shape_use==stripe&&valid_for_cut] ;# VIA1 intersect
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA1 $vias2remove}
	set vias2remove [get_vias -quiet -within $split_area -filter lower_layer_name==M1&&shape_use==stripe&&valid_for_cut] ;# VIA1 within
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA1 $vias2remove}
	
	set vias2remove [get_vias -quiet -intersect  $split_area -filter lower_layer_name==M2&&shape_use==stripe&&valid_for_cut] ;# VIA2 intersect
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA2 $vias2remove}
	set vias2remove [get_vias -quiet -within $split_area -filter lower_layer_name==M2&&shape_use==stripe&&valid_for_cut] ;# VIA2 within
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA2 $vias2remove}
	
	set vias2remove [get_vias -quiet -intersect  $split_area -filter lower_layer_name==M3&&shape_use==stripe&&valid_for_cut] ;# VIA3 intersect
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA3 $vias2remove}
	set vias2remove [get_vias -quiet -within $split_area -filter lower_layer_name==M3&&shape_use==stripe&&valid_for_cut] ;# VIA3 within
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA3 $vias2remove}
	
	set vias2remove [get_vias -quiet -intersect  $split_area -filter lower_layer_name==M4&&shape_use==stripe&&valid_for_cut] ;# VIA4 intersect
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA4 $vias2remove}
	set vias2remove [get_vias -quiet -within $split_area -filter lower_layer_name==M4&&shape_use==stripe&&valid_for_cut] ;# VIA4 within
	if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA4 $vias2remove}

	if {$run_clean_m5_VIA5_m6_VIA6_from_block_boundary} {
	    set vias2remove [get_vias -quiet -intersect  $split_area -filter lower_layer_name==M5&&shape_use==stripe&&valid_for_cut] ;# VIA5 intersect
	    if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA5 $vias2remove}
	    set vias2remove [get_vias -quiet -within $split_area -filter lower_layer_name==M5&&shape_use==stripe&&valid_for_cut] ;# VIA5 within
	    if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA5 $vias2remove}

	    set vias2remove [get_vias -quiet -intersect  $split_area -filter lower_layer_name==M6&&shape_use==stripe&&valid_for_cut] ;# VIA6 intersect
	    if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA6 $vias2remove}
	    set vias2remove [get_vias -quiet -within $split_area -filter lower_layer_name==M6&&shape_use==stripe&&valid_for_cut] ;# VIA6 within
	    if {[sizeof_collection $vias2remove]} {append_to_collection vias2remove_all_VIA6 $vias2remove}

	}
	incr cnt
    }
    
    # user need to review before remove
    if {[sizeof_collection $shapes2remove_all_M0]} {remove_shapes $shapes2remove_all_M0} ;# clean M0 shapes
    if {[sizeof_collection $shapes2remove_all_M1]} {remove_shapes $shapes2remove_all_M1} ;# clean M1 shapes
    if {[sizeof_collection $shapes2remove_all_M5]} {remove_shapes $shapes2remove_all_M5} ;# clean M5 shapes
    if {[sizeof_collection $vias2remove_all_VIA0]} {remove_vias $vias2remove_all_VIA0} ;# clean VIA0
    if {[sizeof_collection $vias2remove_all_VIA1]} {remove_vias $vias2remove_all_VIA1} ;# clean VIA1
    if {[sizeof_collection $vias2remove_all_VIA2]} {remove_vias $vias2remove_all_VIA2} ;# clean VIA2
    if {[sizeof_collection $vias2remove_all_VIA3]} {remove_vias $vias2remove_all_VIA3} ;# clean VIA3 
    if {[sizeof_collection $vias2remove_all_VIA4]} {remove_vias $vias2remove_all_VIA4} ;# clean VIA4
    if {[sizeof_collection $vias2remove_all_VIA5]} {remove_vias $vias2remove_all_VIA5} ;# clean VIA5
    if {[sizeof_collection $vias2remove_all_VIA6]} {remove_vias $vias2remove_all_VIA6} ;# clean VIA6

    #check_pg_drc
    save_block -as clean_pg_around_subblocks
}



#set via2remove [ get_vias -intersect [get_attribute [get_blocks $top_design] boundary] -filter lower_layer_name==M3&&valid_for_cut -quiet ];
#if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
 
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
    
    set split_area_core [get_attribute [resize_polygons -size "$resize_llx $resize_lly $resize_urx $resize_ury" [get_attribute [get_blocks $top_design] core_area_boundary]] poly_rects]
    set split_area_die [get_attribute [get_blocks $top_design] boundary_bounding_box]
    set split_area_m5 [get_attribute [resize_polygons -size "0 0 0 0" [get_attribute [get_blocks $top_design] core_area_boundary]] poly_rects]
     
    #shapes cleanup M0
    set split_objects [get_shapes -intersect $split_area_core -filter layer.name==M0&&shape_use==stripe&&valid_for_cut] ;# M0 objects to split
    
    #in case of complex block shape , like L-shape or other, need to split by line
    for {set i 0} {$i< [llength [get_attribute $split_area_core point_list]]} {incr i} {
	set current_point [list [lindex [get_attribute $split_area_core point_list] $i]]
	set next_point [list [lindex [get_attribute $split_area_core point_list] [expr 1+$i]]]
	if {$i == [expr [llength [get_attribute $split_area_core point_list]]-1]} {
	    set next_point [list [lindex [get_attribute $split_area_core point_list] 0]] ;
	}
	set split_objects [get_shapes -intersect $split_area_core -filter layer.name==M0&&shape_use==stripe&&valid_for_cut] ;# M0 objects to split
	split_objects $split_objects -line "$current_point $next_point"
    }
    
    
    set shape2remove [get_shapes -intersect  $split_area_core -filter layer_name==M0&&length==0.216&&valid_for_cut -quiet] ;# remove M0 shapes from vertical block sides
    if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
    set shape2remove [get_shapes -intersect  [get_attribute [get_blocks $top_design] boundary] -filter layer_name==M0&&width==0.027&&valid_for_cut -quiet] ;#remove M0 shapes from horizontal block sides
    if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
    
    #removing M0 shapes between split core to block die area
    set peripherial_polygon [compute_polygons -objects1 [get_attribute [get_blocks $top_design] boundary] -objects2 $split_area_core -operation NOT ]
    set shape2remove [ get_shapes -within $peripherial_polygon -filter layer_name==M0&&physical_status!=locked&&valid_for_cut -quiet ]; if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
    
    #shapes cleanup M1
    set split_objects [get_shapes -intersect $split_area_core -filter layer.name==M1&&shape_use==stripe&&physical_status!=locked&&valid_for_cut] ;# M1 objects to split
    
    #in case of complex block shape , like L-shape or other, need to split by line
    for {set i 0} {$i< [llength [get_attribute $split_area_core point_list]]} {incr i} {
	set current_point [list [lindex [get_attribute $split_area_core point_list] $i]]
	set next_point [list [lindex [get_attribute $split_area_core point_list] [expr 1+$i]]]
	if {$i == [expr [llength [get_attribute $split_area_core point_list]]-1]} {
	    set next_point [list [lindex [get_attribute $split_area_core point_list] 0]] ;
	}
	split_objects $split_objects -line "$current_point $next_point"
    }
    
    set shape2remove [get_shapes -intersect  $split_area_core -filter layer_name==M1&&length==0.1430&&physical_status!=locked&&valid_for_cut -quiet] ;# remove M1 shapes from vertical block sides
    if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
    set shape2remove [get_shapes -intersect  [get_attribute [get_blocks $top_design] boundary] -filter layer_name==M1&&width==0.028&&physical_status!=locked&&valid_for_cut -quiet] ;#remove M1 shapes from horizontal block sides
    if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}

    # shapes cleanup M5
    if {$run_clean_m5_VIA5_m6_VIA6_from_block_boundary} {

	set split_objects [get_shapes -intersect $split_area_m5 -filter layer.name==M5&&width==0.02&&shape_use==stripe&&physical_status!=locked&&valid_for_cut] ;# M5 objects to split
    
	#in case of complex block shape , like L-shape or other, need to split by line
	for {set i 0} {$i< [llength [get_attribute $split_area_m5 point_list]]} {incr i} {
	    set current_point [list [lindex [get_attribute $split_area_m5 point_list] $i]]
	    set next_point [list [lindex [get_attribute $split_area_m5 point_list] [expr 1+$i]]]
	    if {$i == [expr [llength [get_attribute $split_area_m5 point_list]]-1]} {
		set next_point [list [lindex [get_attribute $split_area_m5 point_list] 0]] ;
	    }
	    split_objects $split_objects -line "$current_point $next_point"
	}
	
	set shape2remove [get_shapes -intersect  $split_area_m5 -filter layer_name==M5&&length==0.0845&&physical_status!=locked&&valid_for_cut -quiet] ;# remove M5 shapes from vertical block sides
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
	set shape2remove [get_shapes -intersect  $split_area_die -filter layer_name==M5&&width==0.02&&physical_status!=locked&&valid_for_cut -quiet] ;# remove M5 shapes intersection die boundary
	if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove} 
	
	#removing M5 shapes between split core to block die area
	set peripherial_polygon [compute_polygons -objects1 [get_attribute [get_blocks $top_design] boundary] -objects2 $split_area_core -operation NOT ]
	set shape2remove [ get_shapes -within $peripherial_polygon -filter layer_name==M5&&width==0.02&&physical_status!=locked&&valid_for_cut -quiet ]; if {[sizeof_collection $shape2remove]} {remove_shapes $shape2remove}
    }

    # removing VIA0,VIA1vias between split core to block die area
    set peripherial_polygon [compute_polygons -objects1 [get_attribute [get_blocks $top_design] boundary] -objects2 $split_area_core -operation NOT ]
    set via2remove [ get_vias -within $peripherial_polygon -filter lower_layer_name==M0&&physical_status!=locked&&valid_for_cut -quiet ]; if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
    set via2remove [ get_vias -within $peripherial_polygon -filter lower_layer_name==M1&&valid_for_cut -quiet ]; if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
    set via2remove [ get_vias -intersect $peripherial_polygon -filter lower_layer_name==M1&&valid_for_cut -quiet ]; if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
    
    # removing VIA2,VIA3,VIA4 vias that expands beyond block die area 
    set via2remove [ get_vias -intersect [get_attribute [get_blocks $top_design] boundary] -filter lower_layer_name==M2&&valid_for_cut -quiet ];
    if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
    set via2remove [ get_vias -intersect [get_attribute [get_blocks $top_design] boundary] -filter lower_layer_name==M3&&valid_for_cut -quiet ];
    if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
    set via2remove [ get_vias -intersect [get_attribute [get_blocks $top_design] boundary] -filter lower_layer_name==M4&&valid_for_cut -quiet ];
    if {[sizeof_collection $via2remove]} {remove_vias $via2remove}

    if {$run_clean_m5_VIA5_m6_VIA6_from_block_boundary} {
	set via2remove [ get_vias -intersect [get_attribute [get_blocks $top_design] boundary] -filter lower_layer_name==M5&&valid_for_cut -quiet ];
	if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
	set via2remove [ get_vias -intersect [get_attribute [get_blocks $top_design] boundary] -filter lower_layer_name==M6&&valid_for_cut -quiet ];
	if {[sizeof_collection $via2remove]} {remove_vias $via2remove}
    }

    save_block -as clean_pg_around_die

} ;# end clean_pg_around_die_auto

if {$run_clean_pg_around_die_auto} {clean_pg_around_die_auto}

#derive_pg_mask_constraint -derive_cut_mask
derive_pg_mask_constraint -check_fix_shape_drc -overwrite

check_pg_drc -do_not_check_shapes_in_hier_blocks 

save_block

close_lib
#return


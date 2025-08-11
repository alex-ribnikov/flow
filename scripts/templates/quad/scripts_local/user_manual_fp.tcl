#------------------------------------------------------------------------------
# floorplan size 
#------------------------------------------------------------------------------
set BRCM_DEF 0

if {$BRCM_DEF} {

source scripts/templates/quad/create_phsy_hard_ips.tcl -e -v 

# FROM /services/bespace/users/ory/nextflow_pre_pn85/be_work/brcm5/grid_quadrant/v6_inext_grid_pn85.2_20220303_1830/brcm_to_ns/Quad_predft_blocks_defs_15March2022/Quad_predft_blocks_defs/grid_quadrant/grid_quadrant.def.gz
read_def ../inter/grid_quadrant.def.gz
#source ../inter/grid_quadrant_io_placement.tcl
read_def ../inter/grid_quadrant_floorplan_post_io_placement_040722.def

check_all_quad_cells

set_db finish_floorplan_active_objs {core macro macro_halo soft_blockage}
finish_floorplan -fill_place_blockage soft 7

source scripts_local/create_blackboxes.tcl 
source scripts_local/create_blackboxes_flavors.tcl

} else {

set yMul 10.080
set xMul 27.132

set core_x_size [expr $xMul * 145]   ;# 624.036
set core_y_size [expr $yMul * 335]     ;# 665.28

set core_x_offset 0.0255
#set core_x_offset 0
set core_y_offset 0
#
#### CONVERT RECTS TO POLY ###
#proc convert_rects_to_poly { rects_list } {
#    set rects_list_string ""
#    
#    foreach rect $rects_list {
#        append rects_list_string "\{$rect\} OR "
#    }
#    set rects_list_string [regsub "OR \$" $rects_list_string ""]
#    
#    set cmd "get_computed_shapes -output polygon $rects_list_string"
#    puts "-I- Eval: $cmd"
#    return [eval $cmd]
#}
#
##set poly {{107.712 0.0} {107.712 98.7} {0.0 98.7} {0.0 3376.8} {3934.14 3376.8} {3934.14 0.0}}
#set box_list { {0 5050.08 9876.048 8850.24} \
#{0 4616.64 9767.52 5050.08} \
#{0 987.84 9876.048 4616.64} \
#{1031.016 231.84 9876.048 987.84} \
#{1031.016 0 9794.652 231.84}}

#set poly [lindex [convert_rects_to_poly $box_list ] 0]
# middle-notch is currently 383.04
# Update middle-notch to 221.76

set box_list {{0.00000 8678.88000 9821.78400 8940.96000} {0.00000 4465.44000 9876.04800 8678.88000} \
              {0.00000 4243.68000 9821.78400 4465.44000} {0.00000 1038.24000 9876.04800 4243.68000} \
             {705.43200 231.84000 9876.04800 1038.24000} {705.43200 0.00000 9821.78400 231.84000}}

#set poly {{9876.048 8678.88} {9713.256 8678.88} {9713.256 8940.96} {0 8940.96} {0 1038.24} {705.432 1038.24} \
#          {705.432 0} {9821.784 0} {9821.784 231.84} {9876.048 231.84} {9876.048 4243.68} {9821.784 4243.68} \
#          {9821.784 4465.44} {9876.048 4465.44}}
#          
#set poly {{9876.048 8860.32} {9713.256 8860.32} {9713.256 9122.4} {0 9122.4} {0 1068.48} {678.3 1068.48} \
#          {678.3 0} {9821.784 0} {9821.784 231.84} {9876.048 231.84} {9876.048 4243.68} {9821.784 4243.68} \
#          {9821.784 4465.44} {9876.048 4465.44}}

set poly {{9876.048 9001.44} {9713.256 9001.44} {9713.256 9233.28} {0 9233.28} {0 1169.28} {678.3 1169.28} \
          {678.3 0} {9821.784 0} {9821.784 231.84} {9876.048 231.84} {9876.048 4455.36} {9821.784 4455.36} \
          {9821.784 4677.12} {9876.048 4677.12}}          


set trx [lindex [lindex [lsort -index 0 -incr -real $poly ] end] 0]
set try [lindex [lindex [lsort -index 1 -incr -real $poly ] end] 1]

set new_coors ""
foreach coor $poly { 
    lassign $coor x y
    # round to lego
    set x [expr $xMul*round($x/$xMul)]
    set y [expr $yMul*round($y/$yMul)]
    set new_coor "( [expr $x*2000] [expr $y*2000] )"
    puts "$coor -> $x $y"
    append new_coors " $new_coor "
}

set_db floorplan_default_tech_site $DEFAULT_SITE
set_db floorplan_check_types odd_even_site_row

set FILE [open ex.def w]
puts $FILE "VERSION 5.8 ;"
puts $FILE "DESIGN $DESIGN_NAME ;"
puts $FILE "UNITS DISTANCE MICRONS 2000 ;"
puts $FILE "PROPERTYDEFINITIONS"
puts $FILE "COMPONENTPIN designRuleWidth REAL ;"
puts $FILE "    DESIGN FE_CORE_BOX_LL_X REAL 0 ;"
puts $FILE "    DESIGN FE_CORE_BOX_UR_X REAL $trx ;"
puts $FILE "    DESIGN FE_CORE_BOX_LL_Y REAL 0.0000 ;"
puts $FILE "    DESIGN FE_CORE_BOX_UR_Y REAL $try ;"
puts $FILE "END PROPERTYDEFINITIONS"
puts $FILE ""
puts $FILE "DIEAREA $new_coors ;"
puts $FILE "END DESIGN"
close $FILE


read_def ex.def
delete_row -all
create_row -site $DEFAULT_SITE
write_def ex1.def -no_core_cells -no_std_cells -no_special_net -no_tracks
#exec perl -p -i -e "s#CORE_6 0#CORE_6 51#" ex1.def
#edit for ecore block lower polygon
#exec perl -p -i -e "s#CORE_6 1410864#CORE_6 1410915#" ex1.def
exec sed -i "/NONDEFAULTRULES/Q" ex1.def
cat ex1.def | awk "{if (NF > 10 && \$1 == \"ROW\") {n=\$8-1; \$8=n; m=\$4+51; \$4=m}; print}" > ex2.def
#cat ex1.def | awk "{if (NF > 10 && \$1 == \"ROW\")  {n=\$8-1; \$8=n}; print}" > ex2.def

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
# macro placement / Create and place blackboxes - Placement is always from top to bottom, from left to right
#------------------------------------------------------------------------------
# placement sites must be odd after Macro placement
source scripts/templates/quad/create_phsy_hard_ips.tcl -e -v 
source scripts_local/create_blackboxes.tcl 
source scripts_local/create_blackboxes_flavors.tcl
#
######################
## Update fillers size
##set middle_notch_h  [expr 38*10.08] ; # 383.04
#set middle_notch_h [expr 22*10.08] ; #221.76
#set middle_notch_w  [expr 4*$xMul]
#set filler_w        [expr 6*$xMul]
#set middle_notch_ur {9876.048 4425.12}
#set die_ur          $tr
#
#set box_list [list [list 0 $middle_notch_h $filler_w [expr [lindex $tr 1] - [lindex $middle_notch_ur 1] + $middle_notch_h]] \
#              [list 0 0 $middle_notch_w $middle_notch_h]]
#set_floorplan_rects -type instance -name i_pseudo_quad_r0_c0_i_ne_filler $box_list
#
#set bottom_notch_h 231.84
#set s_filler_h     [expr 2*$yMul]
#set se_filler_h    [expr [lindex $middle_notch_ur 1] - $middle_notch_h]
#
#set box_list [list [list 0 $bottom_notch_h $filler_w $se_filler_h] \
#                   [list 0 $s_filler_h     $middle_notch_w $bottom_notch_h]]
#set_floorplan_rects -type instance -name i_pseudo_quad_r0_c0_i_se_filler $box_list
######################


set quad_bbox [lindex [get_db designs .bbox] 0]
#set cbue_bbox [lindex [get_db -uniq [get_cells -hier *i_cbue_top*] .bbox] 0]
#set cbui_bbox [lindex [get_db -uniq [get_cells -hier *i_cbui_top*] .bbox] 0]
#set nfi_bbox  [lindex [get_db -uniq [get_cells -hier *i_nfi_mcu_top*] .bbox] 0]
#set tcu_bbox  [lindex [get_db -uniq [get_cells -hier *i_tcu_top*] .bbox] 0]
set grid_cluster_bbox [lindex [get_db -uniq [get_cells -hier *i_grid_cluster*] .bbox] 0]

set xstart [expr 1*27.132]
set ystart [expr [lindex $quad_bbox 3] - [expr 5*10.08]]
#
#set cbue_w [expr [lindex $cbue_bbox 2] - [lindex $cbue_bbox 0]]
#set cbue_h [expr [lindex $cbue_bbox 3] - [lindex $cbue_bbox 1]]
#set cbui_w [expr [lindex $cbui_bbox 2] - [lindex $cbui_bbox 0]]
#set cbui_h [expr [lindex $cbui_bbox 3] - [lindex $cbui_bbox 1]]
#set nfi_w  [expr [lindex $nfi_bbox 2]  - [lindex $nfi_bbox 0]]
#set nfi_h  [expr [lindex $nfi_bbox 3]  - [lindex $nfi_bbox 1]]
#set tcu_w  [expr [lindex $tcu_bbox 2]  - [lindex $tcu_bbox 0]]
#set tcu_h  [expr [lindex $tcu_bbox 3]  - [lindex $tcu_bbox 1]]

set gc_w [lindex $grid_cluster_bbox 2]
set gc_h [lindex $grid_cluster_bbox 3]

set x_channel [expr 2*27.132]
set y_channel [expr 10.08]

##########################
### SET CHANNEL MATRIX ###
##########################
# In multiplications of xMul/yMul
# The index is always the channel to the left/top of the matching block
set v_channel(0) 0
set v_channel(1) 0
set v_channel(2) 1
set v_channel(3) 0
set v_channel(4) 3
set v_channel(5) 0
set v_channel(6) 1
set v_channel(7) 0
set h_channel(0) 1
set h_channel(1) 2
set h_channel(2) 2
set h_channel(3) 2
set h_channel(4) 2
set h_channel(5) 2
set h_channel(6) 2
set h_channel(7) 2


set rows 8
set cols 8

#set cbue_ul_index [list 0 0]
#set cbui_ul_index [list 0 0]
#set nfi_ul_index  [list 0 0]
#set tcu_ul_index  [list 0 0]

set ul_index {0 0}

# GRID
set acc_y $ystart
for { set j 0 } { $j < $rows } { incr j } {
  set acc_x $xstart
  for { set i 0 } { $i < $cols } { incr i } {
  
#    set nfi_cell  [get_db [get_cells -quiet -hier *_r[expr ${j} +  [lindex $nfi_ul_index 0]]_c[expr ${i} + [lindex $nfi_ul_index 1]]_i_nfi_mcu_top] .name]
#    set cbui_cell [get_db [get_cells -quiet -hier *_r[expr ${j} + [lindex $cbui_ul_index 0]]_c[expr ${i} + [lindex $cbui_ul_index 1]]_*i_cbui_top] .name]
#    set cbue_cell [get_db [get_cells -quiet -hier *_r[expr ${j} + [lindex $cbue_ul_index 0]]_c[expr ${i} + [lindex $cbue_ul_index 1]]_*i_cbue_top] .name]
#    set tcu_cell  [get_db [get_cells -quiet -hier *_r[expr ${j} +  [lindex $tcu_ul_index 0]]_c[expr ${i} + [lindex $tcu_ul_index 1]]_*i_tcu_top] .name]
    set gc_cell    [get_db [get_cells -quiet -hier *i_cluster_r[expr       ${j} +  [lindex $ul_index 0]]_c[expr ${i} + [lindex $ul_index 1]]] .name]
    set gtc_cell   [get_db [get_cells -quiet -hier *i_grid_tcu_cluster_r[expr   ${j} +  [lindex $ul_index 0]]_c[expr ${i} + [lindex $ul_index 1]]] .name]
    set gec_cell   [get_db [get_cells -quiet -hier *i_grid_ecore_cluster_r[expr ${j} +  [lindex $ul_index 0]]_c[expr ${i} + [lindex $ul_index 1]]] .name]
    
#    set cbue_loc  [list [expr $acc_x + $v_channel($i)*$xMul]           [expr $acc_y - $h_channel($j)*$yMul - $gc_h]]
#    set cbui_loc  [list [expr $acc_x + $v_channel($i)*$xMul]           [expr $acc_y - $h_channel($j)*$yMul - $cbui_h]]
#    set nfi_loc   [list [expr $acc_x + $v_channel($i)*$xMul + $cbue_w] [expr $acc_y - $h_channel($j)*$yMul - $gc_h]]
#    set tcu_loc   [list [expr $acc_x + $v_channel($i)*$xMul]            [expr $acc_y - $h_channel($j)*$yMul - $gc_h]]
    set gc_loc     [list [expr $acc_x + $v_channel($i)*$xMul]            [expr $acc_y - $h_channel($j)*$yMul - $gc_h]]
        
    set acc_x [expr $acc_x + $v_channel($i)*$xMul + $gc_w]
    
#    if { $nfi_cell != ""  } { place_inst $nfi_cell  $nfi_loc r0  }
#    if { $cbui_cell != "" } { place_inst $cbui_cell $cbui_loc r0 }
#    if { $cbue_cell != "" } { place_inst $cbue_cell $cbue_loc r0 }       
#    if { $tcu_cell != ""  } { place_inst $tcu_cell $tcu_loc r0 }           

    if { $gc_cell  != "" } { place_inst $gc_cell  $gc_loc r0 }
    if { $gtc_cell != "" } { place_inst $gtc_cell $gc_loc r0 }       
    if { $gec_cell != "" } { place_inst $gec_cell $gc_loc r0 }           

  }
  set acc_y [expr $acc_y - $h_channel($j)*$yMul - $gc_h]
}

### HACK FOR r7 c0 nfi ###
#set r7c0nfi_loc [list  [get_db [get_cells -hier *cluster_r6_c0] .bbox.ll.x] [get_db [get_cells -hier *i_cluster_r7_c1] .bbox.ll.y]]
#place_inst  i_grid_tcu_col_i_nfi_mcu_top_r7_c0 $r7c0nfi_loc r0
##########################

# WEST
set acc_y $ystart
for { set i 0 } { $i < 8 } { incr i } {
    set cell      [get_cells -quiet -hier *i_grid_quad_west_filler_i_grid_quad_west_filler_r$i]
    if { $cell != "" } { set cell_name [get_db $cell .name] } { set cell_name "" }   
   
    set cell_loc  [list 0 [expr $acc_y - $h_channel($i)*$yMul - $gc_h]]
    set acc_y [expr $acc_y - $h_channel($i)*$yMul - $gc_h]        
    
    if { [get_db $cell .bbox] == "{0.0 0.0 0.0 0.0}" } { continue }
    if { $cell_name != ""  } { place_inst $cell_name $cell_loc r0 }   

}

# EAST
set acc_y $ystart
for { set i 0 } { $i < 8 } { incr i } {
    set cell      [get_cells -quiet -hier *i_grid_quad_east_filler_i_grid_quad_east_filler_r$i]
    if { $cell != "" } { set cell_name [get_db $cell .name] }    

    set cell_loc  [list [get_db [get_cells -hier *i_cluster_r0_c7] .bbox.ur.x] [expr $acc_y - $h_channel($i)*$yMul - $gc_h]]
    set acc_y [expr $acc_y - $h_channel($i)*$yMul - $gc_h]        
puts "[get_db $cell] $cell_loc"
    if { [get_db $cell .bbox] == "{0.0 0.0 0.0 0.0}" } { continue }    
    if { $cell_name != ""  } { place_inst $cell_name $cell_loc r0 }   
}

# North
set acc_x $xstart
for { set i 0 } { $i < 8 } { incr i } {
    set cell [get_cells -quiet -hier *i_grid_quad_north_filler_i_grid_quad_north_filler_c$i]
    set cell_name [get_db $cell .name]

    set cell_loc  [list [expr $acc_x + $v_channel($i)*$xMul] [expr 2*$yMul + [get_db [get_cells -hier *i_cluster_r0_c7] .bbox.ur.y]]]
    set acc_x [expr $acc_x + $v_channel($i)*$xMul + $gc_w]
    
#    if { $i == 0 } { set acc_x [expr $acc_x + $xMul]}
    
    if { [get_db $cell .bbox] == "{0.0 0.0 0.0 0.0}" } { continue }        
    if { $cell_name != ""  } { place_inst $cell_name $cell_loc r0 }   
}

# SOUTH
set acc_x $xstart
for { set i 0 } { $i < 8 } { incr i } {
    set cell [get_cells -quiet -hier *i_grid_quad_south_filler_i_grid_quad_south_filler_c$i]
    set cell_name [get_db $cell .name]
    
    set cell_loc  [list [expr $acc_x + $v_channel($i)*$xMul] 0]
    set acc_x [expr $acc_x + $v_channel($i)*$xMul + $gc_w]
    
    if { [get_db $cell .bbox] == "{0.0 0.0 0.0 0.0}" } { continue }        
    if { $cell_name != ""  } { place_inst $cell_name $cell_loc r0 }   
}
place_inst i_grid_quad_south_filler_i_grid_quad_south_filler_c0   { 678.3 0 }
place_inst i_grid_quad_south_filler_i_grid_quad_south_filler_east [list [get_db [get_cells -hier i_grid_quad_south_filler_i_grid_quad_south_filler_c7] .bbox.ur.x] 0]


# FLAVORS:
######################
# Update fillers size
set_floorplan_rects -type instance -name i_grid_tcu_col_i_grid_ecore_cluster_r7_c0 [list [list 678.3 141.12 1220.94 1280.16] [list 0 1169.2800 678.3 1280.16]]

# WEST L SHAPE
#set_floorplan_rects -type instance -name i_grid_quad_west_filler_i_grid_quad_west_filler_r7 [list [list 678.3 40.32 786.828 1179.36] [list 0 1068.48000 678.3 1179.36]]
# EAST BOTTOM RIGHT
#set_floorplan_rects -type instance -name i_grid_quad_east_filler_i_grid_quad_east_filler_r7 {{0.0 80.64 162.792 1118.88} {0.0 0.0 108.528 80.64}}

# EAST MIDDLE RIGHT
#set_floorplan_rects -type instance -name i_grid_quad_east_filler_i_grid_quad_east_filler_r4 [list [list 9713.256 3447.36 9821.784 4556.16] [list 9821.784 3447.36 9876.048 4334.4] ]


place_inst i_grid_quad_east_filler_i_grid_quad_east_filler_r4 {9713.256 3548.16} r0 
#place_inst i_grid_quad_west_filler_i_grid_quad_west_filler_r7 {0.0 141.12} r0 
place_inst i_grid_quad_east_filler_i_grid_quad_east_filler_r7 {9713.256 151.2} r0 

## ICOVL B - -15um from the top of r4 c3 nfi - not to block the channel with blockages
#place_inst icovl_type_b [list [get_db [get_cells i_grid_clusters_wrap_i_cluster_r4_c3] .bbox.ur.x] \
#                              [expr -1*[get_db [get_db insts  icovl_type_b] .base_cell.bbox.ur.y] -8 + [get_db [get_cells i_grid_clusters_wrap_i_cluster_r4_c3] .bbox.ur.y]]] r0
#
## ICOVL C - +15um from the top of r3 c3 nfi - not to block the channel with blockages
#place_inst icovl_type_c [list [get_db [get_cells i_grid_clusters_wrap_i_cluster_r4_c3] .bbox.ur.x] \
#                              [expr +8 + [get_db [get_cells i_grid_clusters_wrap_i_cluster_r3_c3] .bbox.ll.y]]] r0
#
#
# ICOVL H - -15um from the top of r5 c5 nfi - not to block the channel with blockages
#place_inst icovl_type_h_0 [list [get_db [get_cells i_grid_clusters_wrap_i_cluster_r5_c5_i_nfi_mcu_top] .bbox.ur.x] \
#                              [expr -1*[get_db [get_db insts  icovl_type_h] .base_cell.bbox.ur.y] -8 + [get_db [get_cells i_grid_clusters_wrap_i_cluster_r5_c5_i_nfi_mcu_top] .bbox.ur.y]]] r0
#place_inst icovl_type_h_1 [list [get_db [get_cells i_grid_clusters_wrap_i_cluster_r5_c5_i_nfi_mcu_top] .bbox.ur.x] \
#                              [expr [get_db inst:grid_quadrant/icovl_type_h_0 .location.y] + 3508]] r0                              
place_inst icovl_type_h_1 {7298.508 6825.378} r0 
place_inst icovl_type_h_0 {7298.508 3438.498} r0 
place_inst icovl_type_c {4853.772 4685.12} r0 
place_inst icovl_type_b {4853.772 4460.128} r0 

# VTMON
#place_inst i_vtmon_remote_sensor {4829.496 3548.16} r0 
place_inst i_vtmon_remote_sensor {4862.136 3595.41} r0 


### Create routing and placement blockages on ICOVL
foreach inst [get_db insts "*icovl*b* *icovl*c*"] {
    
    set bbox [lindex [get_db $inst .bbox] 0]
    lassign $bbox xl yl xh yh
    
    set place_blk_big_box [list [expr $xl - 15] [expr $yl - 15] [expr $xh + 15] [expr $yh + 15]]
    set place_blk_list    [get_computed_shapes $place_blk_big_box XOR $bbox -output rect]
    
    set route_blk_big_box [list [expr $xl - 8] [expr $yl - 8] [expr $xh + 8] [expr $yh + 8]]
    set route_blk_list    [get_computed_shapes $route_blk_big_box XOR $bbox -output rect]  
    
    create_place_blockage -name icovl_place_blockage -rects $place_blk_list
    create_route_blockage -name icovl_route_blockage -rects $route_blk_list  -layers {M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 \
                                                                   VIA0 VIA1 VIA2 VIA3 VIA4 VIA5 VIA6 VIA7 VIA8 VIA9 VIA10 VIA11}  
    
}

foreach inst [get_db insts *icovl*h*] {
    
    set bbox [lindex [get_db $inst .bbox] 0]
    lassign $bbox xl yl xh yh
    
    set place_blk_big_box [list [expr $xl - 8] [expr $yl - 8] [expr $xh + 8] [expr $yh + 8]]
    set place_blk_list    [get_computed_shapes $place_blk_big_box XOR $bbox -output rect]
    
    set route_blk_big_box [list [expr $xl - 8] [expr $yl - 8] [expr $xh + 8] [expr $yh + 8]]
    set route_blk_list    [get_computed_shapes $route_blk_big_box XOR $bbox -output rect]  
    
    create_place_blockage -name icovl_place_blockage -rects $place_blk_list
    create_route_blockage -name icovl_route_blockage -rects $route_blk_list  -layers {M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 \
                                                                   VIA0 VIA1 VIA2 VIA3 VIA4 VIA5 VIA6 VIA7 VIA8 VIA9 VIA10 VIA11}  
    
}

return
                          
#------------------------------------------------------------------------------
# fix routing tracks
#------------------------------------------------------------------------------
delete_tracks
add_tracks \
	-pitch_pattern {m0 offset 0.0 pitch 0.049 {pitch 0.028 repeat 4} pitch 0.049 } \
	-mask_pattern {m0 2 2 1 2 1 2  m1 2 1 m2 1 2 m3 1 2 m4 1 2} \
	-offsets {m1 vert 0.0510 m2 horiz 0.0 m3 vert die_box 0.0 m4 horiz 0.0   m5 vert die_box 0.038 m6 horiz die_box 0.04 m7 vert die_box 0.038 m8 horiz die_box 0 m9 vert die_box 0.038 m10 horiz die_box 0 m11 vert die_box 0.038 m12 horiz 0 m13 vert die_box 0.0 m14 horiz 0 m15 vert die_box 0.133 m16 horiz 0.504 }

return
##------------------------------------------------------------------------------
## pin alignment
##------------------------------------------------------------------------------
############################
##### CHECK CONNECTIVITY ###
############################
#source -e -v scripts/templates/quad/check_connectivity.tcl
#
######################
#### PIN ALIGNMENT ###
######################
#source -e -v scripts/templates/quad/pin_alignment.tcl
#
#write_db  -verilog      out/db/${DESIGN_NAME}.post_pin_alignment.enc.dat 
#
#return 
##################################
### ALIGN TO BLOCK'S INTERFACE ###
##################################
set ext_blocks [get_cells "i_grid_quad*_filler_*"]
foreach cell [get_db $ext_blocks] {
    puts "align_pins_b2i [get_db $cell .name]"
    align_pins_b2i_wdef [get_db $cell .name] true
}

set ext_blocks [get_cells -hier "*south_filler_c*"]
foreach cell [get_db $ext_blocks] {
    puts "align_pins_b2i [get_db $cell .name]"
    align_pins_b2i [get_db $cell .name] true NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076
}
set ext_blocks [get_cells -hier "*north_filler_c*"]
foreach cell [get_db $ext_blocks] {
    puts "align_pins_b2i [get_db $cell .name]"
    align_pins_b2i [get_db $cell .name] true 
}

write_db  -verilog      out/db/${DESIGN_NAME}.post_ports_alignment.enc.dat 

### PLACE CLOCK PORTS
set_db assign_pins_edit_in_batch true

edit_pin -pin grid_clk       -layer M17 -assign {4879 0} -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_div_2 -layer M15 -assign {4870 0} -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track

edit_pin -pin grid_clk_from_east[0] -layer M16 \
   -assign [list 9876.048 [expr -2.5+([get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r1] .bbox.ur.y]+[get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r0] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_from_east[1] -layer M16 \
   -assign [list 9876.048 [expr -2.5+([get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r3] .bbox.ur.y]+[get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r2] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_from_east[2] -layer M16 \
   -assign [list 9876.048 [expr -2.5+([get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r5] .bbox.ur.y]+[get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r4] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_from_east[3] -layer M16 \
   -assign [list 9876.048 [expr -2.5+([get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r7] .bbox.ur.y]+[get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r6] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track         


edit_pin -pin grid_clk_to_east[0] -layer M16 \
   -assign [list 9876.048 [expr 2.5+([get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r1] .bbox.ur.y]+[get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r0] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_to_east[1] -layer M16 \
   -assign [list 9876.048 [expr 2.5+([get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r3] .bbox.ur.y]+[get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r2] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_to_east[2] -layer M16 \
   -assign [list 9876.048 [expr 2.5+([get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r5] .bbox.ur.y]+[get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r4] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_to_east[3] -layer M16 \
   -assign [list 9876.048 [expr 2.5+([get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r7] .bbox.ur.y]+[get_db [get_cells i_grid_quad_east_filler_i_grid_quad_east_filler_r6] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track         


edit_pin -pin grid_clk_to_west[0] -layer M16 \
   -assign [list 0 [expr 2.5+([get_db [get_cells i_grid_quad_west_filler_i_grid_quad_west_filler_r1] .bbox.ur.y]+[get_db [get_cells i_grid_quad_west_filler_i_grid_quad_west_filler_r0] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_to_west[1] -layer M16 \
   -assign [list 0 [expr 2.5+([get_db [get_cells i_grid_quad_west_filler_i_grid_quad_west_filler_r3] .bbox.ur.y]+[get_db [get_cells i_grid_quad_west_filler_i_grid_quad_west_filler_r2] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_to_west[2] -layer M16 \
   -assign [list 0 [expr 2.5+([get_db [get_cells i_grid_quad_west_filler_i_grid_quad_west_filler_r5] .bbox.ur.y]+[get_db [get_cells i_grid_quad_west_filler_i_grid_quad_west_filler_r4] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_to_west[3] -layer M16 \
   -assign [list 0 [expr 2.5+([get_db [get_cells i_grid_quad_west_filler_i_grid_quad_west_filler_r7] .bbox.ur.y]+[get_db [get_cells i_grid_quad_west_filler_i_grid_quad_west_filler_r6] .bbox.ll.y])/2]] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track         


edit_pin -pin grid_clk_to_north[0] -layer M17 \
   -assign [list [expr 4+([get_db [get_cells i_grid_quad_north_filler_i_grid_quad_north_filler_c1] .bbox.ur.x]+[get_db [get_cells i_grid_quad_north_filler_i_grid_quad_north_filler_c0] .bbox.ll.x])/2] 8850.24] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_to_north[1] -layer M17 \
   -assign [list [expr 4+([get_db [get_cells i_grid_quad_north_filler_i_grid_quad_north_filler_c3] .bbox.ur.x]+[get_db [get_cells i_grid_quad_north_filler_i_grid_quad_north_filler_c2] .bbox.ll.x])/2] 8850.24] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_to_north[2] -layer M17 \
   -assign [list [expr 4+([get_db [get_cells i_grid_quad_north_filler_i_grid_quad_north_filler_c5] .bbox.ur.x]+[get_db [get_cells i_grid_quad_north_filler_i_grid_quad_north_filler_c4] .bbox.ll.x])/2] 8850.24] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin grid_clk_to_north[3] -layer M17 \
   -assign [list [expr 4+([get_db [get_cells i_grid_quad_north_filler_i_grid_quad_north_filler_c7] .bbox.ur.x]+[get_db [get_cells i_grid_quad_north_filler_i_grid_quad_north_filler_c6] .bbox.ll.x])/2] 8850.24] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track         


edit_pin -pin v_remote_sensor -layer M16 \
   -assign [list 9876.048 4431.67] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin remote_sensor_return -layer M16 \
   -assign [list 9876.048 4432.68] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -pin i_remote_sensor -layer M16 \
   -assign [list 9876.048 4428] \
   -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track      



set test_ports     [get_ports "*TEST*" -filter full_name!~*CLK&&full_name!~*CLOCK]
set test_clk_ports [get_ports "*TEST*" -filter full_name=~*CLK||full_name=~*CLOCK]

edit_pin -layer {M5 M7 M9 M11 M13} -edge 3 -spread_direction clockwise -offset_start 4830.44 -offset_end 4802.5 -pin [lsort [get_db $test_ports .name]] -pattern fill_optimised

edit_pin -layer M13 -edge 3 -spread_type edge -spread_direction clockwise -offset_start 4850.44 -offset_end 4850.5 -pin [lsort [get_db $test_clk_ports .name]] 


set_db assign_pins_edit_in_batch false

write_db  -verilog      out/db/${DESIGN_NAME}.post_io_placement.enc.dat 

return


read_def -special_nets /services/bespace/users/ory/nextflow_pre_pn85/be_work/brcm5/grid_quadrant/v3_quadrant_pn85/pnr_w_lefs/out/def/PG.def

write_db  -verilog      out/db/${DESIGN_NAME}.post_io_placement_w_pg.enc.dat 
#------------------------------------------------------------------------------
# placement blockage
#------------------------------------------------------------------------------
#resize_floorplan -x_size 5.712
## Place Macros
## gcl output
#source scripts_local/cbui_top.srams_location.syn_v11p0a.tcl

#set_db floorplan_snap_block_grid layer_track
#snap_floorplan -block
#check_floorplan
#set_db floorplan_snap_block_grid finfet_placement
#snap_floorplan -block
check_floorplan


# Fix macro placement
set_db [get_db insts -if {.base_cell.base_class == block}] .place_status fixed


# Cut Rows around memories
foreach mem_dpo [get_db insts -if {.base_cell.base_class == block&&.base_cell.is_macro==true}] {
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
finish_floorplan -fill_place_blockage soft 7

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
check_endcaps -error 10000 -out_file reports/fp/verifyEndcap.rpt
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
foreach inst_dpo [get_db [get_db insts -if {.base_cell.base_class == block}]] {
  create_route_blockage -rects [join [get_computed_shapes [get_db $inst_dpo .bbox] SIZE 0.48]] -layers {M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12 M13 M14 M15 VIA0 VIA1 VIA2 VIA3 VIA4 VIA5 VIA6 VIA7 VIA8 VIA9 VIA10 VIA11 VIA12 VIA13 VIA14}  -name temp_mem_blockages
}

add_dummy_boundary_wires -layers {M1 M2 M3 M4} 

write_db  -verilog      out/db/${DESIGN_NAME}.pre_PG.enc.dat

#create_boundary_routing_halo -halo_width 0.2 -layers { M1 M2 M3 M4 M5 M6 M7 M8 M9 M10 M11 M12}
source -e -v scripts/flow/create_power_grid.${::env(PROJECT)}.tcl

write_db  -verilog      out/db/${DESIGN_NAME}.PG.enc.dat

#------------------------------------------------------------------------------
# place pins
#------------------------------------------------------------------------------

delete_obj [get_db route_blockages {-if .name == boundary_route_halo } ]

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

create_route_halo -bottom_layer M1 -top_layer $MAX_ROUTING_LAYER -space 2.0 -design_halo 


#------------------------------------------------------------------------------
# place taps , eco dcap and dcaps
#------------------------------------------------------------------------------
set_db add_well_taps_insert_cells $TAPCELL

add_well_taps -checker_board
check_well_taps	-max_distance 45 -report reports/fp/verifyWelltap.rpt
} 
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

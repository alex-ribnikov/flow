source -e -v  scripts/templates/quad/pn99_clock_recipe/record_connectivity_change_220123_2230.tcl
read_def scripts/templates/quad/pn99_clock_recipe/grid_quadrant.clock_cells_placement.def.gz



#source scripts/templates/quad/scripts_local/cts_hard_blockages.tcl
#source scripts/templates/quad/pn99_clock_recipe/insert_column_clock_skew.tcl
#source scripts/templates/quad/pn99_clock_recipe/isolate_output_clocks.tcl
#
#read_def scripts/templates/quad/pn99_clock_recipe/grid_quadrant.skew_clock_cells_placement.def.gz
#
#delete_obj [get_db place_blockages carpet_cts_blockage]
#
#read_def -preserve_shape scripts/templates/quad/pn99_clock_recipe/grid_quadrant.skew_clock_routing.def.gz 

read_def -components ../pnr_new_edt_w_clock_new_lefs/out/def/grid_quadrant.place.def.gz
enter_eco_mode
place_inst ts_1_mux_and_stm2s3_sea1__atsource434511__intno434511_i {4500 4500} r0
place_inst ts_1_mux_and_stm2s3_sea1__atsource434510__intno434510_i {4500 4500} r0
place_inst AVAGOTECH_REV_TAG_PN99_4_6Dec22_09_01_40 {4500 4500} r0
place_inst assignBuf_275 {4500 4500} r0
place_inst assignBuf_274 {4500 4500} r0
place_inst assignBuf_273 {4500 4500} r0
place_inst mgc_hdle_prim_buf {4500 4500} r0
place_inst mgc_hdle_inst_45 {4500 4500} r0
place_inst mgc_hdle_inst_44 {4500 4500} r0
place_inst mgc_hdle_inst_38 {4500 4500} r0
place_inst mgc_hdle_inst_34 {4500 4500} r0
place_inst mgc_hdle_inst_26 {4500 4500} r0
place_inst mgc_hdle_inst_14 {4500 4500} r0
place_inst mgc_hdle_inst_12 {4500 4500} r0
place_inst mgc_hdle_inst_11 {4500 4500} r0
place_inst mgc_hdle_inst_7 {4500 4500} r0
place_inst mgc_hdle_inst_4 {4500 4500} r0
place_inst mgc_hdle_inst_3 {4500 4500} r0
place_inst mgc_hdle_inst_1 {4500 4500} r0
place_inst mgc_hdle_inst {4500 4500} r0

set clock_cells [add_to_collection [get_cells -hier {*level*tap* *skew* *split*}] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]
set_db $clock_nets .dont_touch false

source -e -v scripts_local/insert_column_clock_skew.tcl
read_def  /services/bespace/users/johnd/nextflow/be_work/brcm5/grid_quadrant/v1_grid_pn99_20221124_1905_for_cubby/pnr_new_edt/out/def/grid_quadrant.clock_cells_only.def.gz
read_def  -preserve_shape /services/bespace/users/johnd/nextflow/be_work/brcm5/grid_quadrant/v1_grid_pn99_20221124_1905_for_cubby/pnr_new_edt/out/def/grid_quadrant.clock_nets_only.def.gz


########################################
# ADD REPEATERS ON FROM EAST CLOCK
########################################
#enter_eco_mode
#set tap_groups_list [list ck00 {i_grid_quad_east_filler_i_grid_quad_east_filler_r1/east_grid_clk i_grid_quad_east_filler_i_grid_quad_east_filler_r0/east_grid_clk} \
#                          ck01 {i_grid_quad_east_filler_i_grid_quad_east_filler_r3/east_grid_clk i_grid_quad_east_filler_i_grid_quad_east_filler_r2/east_grid_clk} \
#                          ck02 {i_grid_quad_east_filler_i_grid_quad_east_filler_r5/east_grid_clk i_grid_quad_east_filler_i_grid_quad_east_filler_r4/east_grid_clk} \
#                          ck03 {i_grid_quad_east_filler_i_grid_quad_east_filler_r7/east_grid_clk i_grid_quad_east_filler_i_grid_quad_east_filler_r6/east_grid_clk} ]
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#set_db [get_nets -of $tap_pins_list ] .dont_touch false
#insert_taps $tap_pins_list level_from_east_clock_tap 100 false {40 0}
#enter_eco_mode true



set clock_cells [add_to_collection [get_cells -hier {*level*tap* *skew* *split*}] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]

set_db route_early_global_top_routing_layer 16
set_db design_top_routing_layer 16

if { [get_db route_rules grid_clk_vp_rule_3] == "" } {
create_route_rule -name grid_clk_vp_rule_3 -width   {M1 0.02  M2 0.02  M3 0.02  M4 0.02  M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076_SHLD \
                                         -spacing {M1 0.014 M2 0.015 M3 0.022 M4 0.022 M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}
}
                                         
set_db $clock_nets .route_rule {}
foreach net [get_db $clock_nets .name] {
  set_route_attributes -reset -nets $net
  set_route_attributes -nets $net -top_preferred_routing_layer 18 -bottom_preferred_routing_layer 17 \
                       -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort high \
                       -route_rule grid_clk_vp_rule_3
}


foreach base_cell [get_db -uniq [get_super_invs_cells] .base_cell] {
    set width    [get_db $base_cell .bbox.ur.x]
    set height   [get_db $base_cell .bbox.ur.y]
    set hratio   1
    set vratio   1.5
    set hsite    0.051
    set vsite    0.21
    set hpadding [expr int( $width*$hratio/$hsite )]
    set vpadding [expr int( $height*$vratio/$vsite )]

    set_db $base_cell .bottom_padding $vpadding
    set_db $base_cell .top_padding    $vpadding
    set_db $base_cell .right_padding  $hpadding
    set_db $base_cell .left_padding   $hpadding
}


proc blocks_over_clocks { } {
    
    set clock_cells [add_to_collection [get_cells -hier *level*tap*] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
    set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
    set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
    set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]
    
    set wires [get_db [get_db $clock_nets .wires] -if .layer.name==M17||.layer.name==M16]
    
    set m16_rects {}
    set m17_rects {}
    
    set m16w 5.04
    set m17w 13.566
    
    set margin 0.01
    
    foreach wire [get_db $wires -if .layer.name==M16] { 
        
        set rect [lindex [get_db $wire .rect]  0]
        lassign $rect x1 y1 x2 y2
        
        set xl [expr min($x1,$x2) - $margin*abs($x1-$x2)]
        set xh [expr max($x1,$x2) + $margin*abs($x1-$x2)]
        set yl [expr min($y1,$y2) - $m16w/2]
        set yh [expr max($y1,$y2) + $m16w/2]        
        
        lappend m16_rects [list $xl $yl $xh $yh]
        
    }
    foreach wire [get_db $wires -if .layer.name==M17] { 
    
        set rect [lindex [get_db $wire .rect]  0]
        lassign $rect x1 y1 x2 y2
        
        set yl [expr min($y1,$y2) - $margin*abs($y1-$y2)]
        set yh [expr max($y1,$y2) + $margin*abs($y1-$y2)]
        set xl [expr min($x1,$x2) - $m17w/2]
        set xh [expr max($x1,$x2) + $m17w/2]        
        
        lappend m17_rects [list $xl $yl $xh $yh]
    
    }
    
    create_route_blockage  -layers {M16} -rects $m16_rects -name do_not_route_m1716_please
    create_route_blockage  -layers {M17} -rects $m17_rects -name do_not_route_m1716_please
    
}

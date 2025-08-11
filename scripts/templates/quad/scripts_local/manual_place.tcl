#source /services/bespace/users/ory/nextflow_pre_pn85/be_work/brcm5/grid_quadrant/v12_pn85.3_cts_tests/pnr_ref/out/clock_tree/clock_tree_connectivity.tcl -e -v
#read_def /services/bespace/users/ory/nextflow_pre_pn85/be_work/brcm5/grid_quadrant/v12_pn85.3_cts_tests/pnr_ref/out/clock_tree/clock_cells_placement.def
#source /services/bespace/users/ory/nextflow_pre_pn85/be_work/brcm5/grid_quadrant/v11_grid_pn85.3_auto_flow/pnr_man_ref_w_blockages_for_route/record_connectivity_change_240722_1140.tcl

set cells {} ; foreach box  [get_db  [get_super_invs_cells ] .bbox] {lappend cells [get_db [get_cells_within $box]]}
delete_obj  [get_db [get_cells $cells ] -if .is_physical ]

source -e -v  scripts/templates/quad/block_carpets.tcl
#
#read_def /services/bespace/users/ory/nextflow_pre_pn85/be_work/brcm5/grid_quadrant/v12_pn85.3_cts_tests/pnr_manual_route_w_route_blockages/out/def/routed_straight_nets_100pct.def
#
set_interactive_constraint_modes func

set_multicycle_path 5 -from grid_clk* -to grid_clk*
set_multicycle_path 5 -from virtual_grid_clk* -to grid_clk*
set_multicycle_path 5 -from grid_clk* -to virtual_grid_clk*

### Limit trans on 0 max trans pins
#if { [llength [set pins [get_db pins -if .max_transition==0]]] > 0 } {
#    
#    puts "-I- Set max_trans on [llength $pins]"
#    set_max_transition 1 $pins
#    
#}

set all_other_nets   [get_nets -hier -filter full_name!~*clk&&full_name!~*rst_n&&full_name!~dft_scan_en&&full_name!~*TEST*&&full_name!~*tessent*]
set n1 [get_nets -of [get_pins       -filter full_name!~*clk&&full_name!~*rst_n&&full_name!~dft_scan_en&&full_name!~*TEST*&&full_name!~*tessent*]]
set n2 [get_nets -of [get_ports      -filter full_name!~*clk&&full_name!~*rst_n&&full_name!~dft_scan_en&&full_name!~*TEST*&&full_name!~*tessent*]]
set n12 [add_to_collection -uniq $n1 $n2]
set all_other_nets [common_collection $n12 $all_other_nets]

# Convert global to actuall route
set p2p_nets {}
array unset net_const_arr
puts "-I- Setting route rule on p2p nets [ory_time::now]"
set curr 0
set total [sizeof $all_other_nets]
foreach_in_collection net $all_other_nets {

    ory_progress $curr $total
    incr curr
    
    if { ![llength [set drv [get_db $net .driver_pins]]] } { set drv [get_db $net .driver_ports] }
    if { ![llength [set rcv [get_db $net .load_pins  ]]] } { set rcv [get_db $net .load_ports] }
    
    if { [llength [concat $drv $rcv]] != 2 } { continue }
    
    set drv_layer [get_db $drv .layer.route_index]
    set rcv_layer [get_db $rcv .layer.route_index]

    if { [compare_pins $drv $rcv] != "true" } { continue }
  
#    set_route_attributes -nets [get_db $net .name] -top_preferred_routing_layer $drv_layer -bottom_preferred_routing_layer $drv_layer \
#    -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort hard
    
    set_db $net .bottom_preferred_layer $drv_layer
    set_db $net .top_preferred_layer $drv_layer
    
    lappend net_const_arr($drv_layer) [get_db $net .name]
    
    append_to_collection p2p_nets $net
}
puts ""

set_db [get_db $p2p_nets ] .dont_touch true


#### IGNORE SPARE NETS FOR PN99 ####

set spare_nets [get_nets -of [get_ports "*spare* hif_quad_strap[0]"]]
#remove_inverters  [get_cells -of $spare_nets] true
set_db $spare_nets .dont_touch true
set_db $spare_nets .is_early_global_routed false
set_false_path -through $spare_nets


### AVOID FALSE PATHS ON STRAPS - WILL BE REMOVED IN FN ###
set_false_path -from strap_quad_sf_from_east[0] -to hif_quad_strap[0]


### SET ROUTE BLOCKAGES OVER BLOCKS FOR M15-M17
set_db route_early_global_top_routing_layer 16
set_db design_top_routing_layer 16

create_route_blockage  -layers {M16 M17} -rects [get_db designs .bbox] -name do_not_route_m1716_please
#blocks_over_clocks

foreach inst_dpo [get_db [get_db insts -if .base_cell==*top*]] {
  set rect [lindex [get_db $inst_dpo .bbox] 0]
  lassign $rect xl yl xh yh
  set rect [list [expr $xl + 2] [expr $yl + 2] [expr $xh - 2] [expr $yh - 2]]
  create_route_blockage -rects $rect  -layers {M15}  -name temp_block_blockages
}

set_interactive_constraint_modes {}
#
#### INSERT GRID CLK CLOCK TREE ###
#source scripts/templates/quad/scripts_local/build_clock_tree_pn99.tcl -e -v 
#
#set PRE_PLACE_DEF out/def/grid_quadrant.init_cell_placement.def.gz
#if { [info exists PRE_PLACE_DEF] && $PRE_PLACE_DEF!="" } { 
#    read_def $PRE_PLACE_DEF 
#
#    write_db -verilog out/db/${DESIGN_NAME}.place_post_clock_cells_pre_route.enc.dat
#    
#    ### ROUTE GRID CLK CLOCK TREE ###    
#    set clock_cells [add_to_collection [get_cells -hier *level*tap*] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
#    set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
#    set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
#    set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]
#    
#    be_build_super_inv_vp
#
#    set_db route_early_global_top_routing_layer 18
#    set_db design_top_routing_layer 18
#
#    if { [get_db route_rules grid_clk_vp_rule_2] == "" } {
#    create_route_rule -name grid_clk_vp_rule_2 -width   {M1 0.02  M2 0.02  M3 0.02  M4 0.02  M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 \
#                                             -spacing {M1 0.014 M2 0.015 M3 0.022 M4 0.022 M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}
#    }
#
#    set_db $clock_nets .route_rule {}
#    foreach net [get_db $clock_nets .name] {
#      set_route_attributes -reset -nets $net
#      set_route_attributes -nets $net -top_preferred_routing_layer 18 -bottom_preferred_routing_layer 17 \
#                           -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort high \
#                           -route_rule grid_clk_vp_rule_2
#    }
#    #read_def snapshot.def
#
#    set_db $clock_nets .dont_touch true
#    set_db $clock_nets .wires.status fixed
#    set_db $clock_nets .vias.status fixed
#    write_db -verilog out/db/${DESIGN_NAME}.place_post_vp.enc.dat
#
#    delete_obj [get_db [get_db [get_nets ] .wires ] -if .status==unknown]
#    delete_obj [get_db [get_db [get_nets ] .vias ] -if .status==unknown]
#
#    set route_blockages [get_db route_blockages *temp*]
#    delete_obj $route_blockages
#    set route_blockages [get_db route_blockages *do_not_route_m1716_please*]
#    delete_obj $route_blockages
#
#    be_route_p2p [get_nets $clock_nets]
#
#    set_db route_design_with_timing_driven false
#    set_db route_design_antenna_diode_insertion false
#    set_db route_design_with_si_driven false
#    set_db route_design_detail_fix_antenna false
#    set_db route_design_detail_end_iteration 1
#
#    deselect_obj -all
#    select_obj  $clock_nets
#    route_global_detail -selected
#    deselect_obj -all
#
#    set_db route_design_with_timing_driven true
#    set_db route_design_antenna_diode_insertion true
#    set_db route_design_with_si_driven true
#    set_db route_design_detail_fix_antenna true
#    set_db route_design_detail_end_iteration 0
#
#    ory_calc_net_length $clock_nets
#    puts "-I- Quad clock nets length:"
#    t $clock_nets be_net_length
#
#    set_db $clock_nets .dont_touch true
#    set_db $clock_nets .wires.status fixed
#    set_db $clock_nets .vias.status fixed
#    write_db -verilog out/db/${DESIGN_NAME}.place_post_clk_route.enc.dat
#    
#}

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


set MAX_ROUTING_LAYER 16
set_db route_early_global_top_routing_layer 16
set_db design_top_routing_layer 16

create_route_blockage  -layers {M16 M17} -rects [get_db designs .bbox] -name do_not_route_m1716_please
#blocks_over_clocks

foreach inst_dpo [get_db [get_db insts -if .base_cell==*top*]] {
  set rect [lindex [get_db $inst_dpo .bbox] 0]
  lassign $rect xl yl xh yh
  set rect [list [expr $xl + 2] [expr $yl + 2] [expr $xh - 2] [expr $yh - 2]]
  create_route_blockage -rects $rect  -layers {M15}  -name temp_block_blockages
}

#########################
# GROUPING COMPRESSORS
#########################
#set cells_arr(g11) [get_cells *group_1_1*]
#set cells_arr(g12) [get_cells *group_1_2*]
#set cells_arr(g21) [get_cells *group_2_1*]
#set cells_arr(g22) [get_cells *group_2_2*]
#set cells_arr(g3)  [get_cells *group_3*]
#set cells_arr(g4)  [get_cells *group_4*]


create_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_1 -rects {4829.496 6935.04 4910.892 9172.8} -type guide
update_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_1 -add  -obj [get_db [get_cells *grid_quadrant_grid_cluster_extest_edt_compression_group_1*] .name]

create_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_2 -rects {4829.496 4677.12 4910.892 6914.88} -type guide
update_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_2 -add  -obj [get_db [get_cells *grid_quadrant_grid_cluster_extest_edt_compression_group_2*] .name]

create_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_3 -rects {4829.496 2419.20 4910.892 4656.96} -type guide
update_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_3 -add  -obj [get_db [get_cells *grid_quadrant_grid_cluster_extest_edt_compression_group_3*] .name]

create_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_4 -rects {4829.496 161.28  4910.892 2399.04} -type guide
update_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_4 -add  -obj [get_db [get_cells *grid_quadrant_grid_cluster_extest_edt_compression_group_4*] .name]


#eval_legacy "setPlaceMode -timingDriven false"
eval_legacy "setOptMode -powerEffort none"
eval_legacy "setOptMode -maxLength 200"


set STAGE "place"
set_db opt_new_inst_prefix "i_${STAGE}_"
set_db opt_new_net_prefix  "n_${STAGE}_"

eee "place_design  "
write_db out/db/${DESIGN_NAME}.place_design.enc.dat

convert_early_global_to_route $p2p_nets

set straight_nets  [filter_routed_p2p_nets $p2p_nets]
set p2p_not_routed [remove_from_collection  $p2p_nets  [get_nets $straight_nets ]]

set wires [get_db $p2p_not_routed .wires]
set vias  [get_db $p2p_not_routed .vias]
delete_obj [concat $wires $vias]

_be_route_p2p $p2p_not_routed
convert_early_global_to_route $p2p_not_routed

#set straight_nets  [filter_routed_p2p_nets $p2p_nets]
#so $straight_nets
#write_def -selected -routing out/def/grid_quadrant.p2p_route.def.gz

#set curr 0
#set total [sizeof $p2p_not_routed]
#
#foreach_in_collection net $p2p_not_routed {
#
#    ory_progress $curr $total
#    incr curr
#    
#    if { ![llength [set drv [get_db $net .driver_pins]]] } { set drv [get_db $net .driver_ports] }
#    if { ![llength [set rcv [get_db $net .load_pins  ]]] } { set rcv [get_db $net .load_ports] }
#    
#    if { [llength [concat $drv $rcv]] != 2 } { continue }
#    
#    set drv_layer [get_db $drv .layer.route_index]
#    set rcv_layer [get_db $rcv .layer.route_index]
#
#    if { [compare_pins $drv $rcv] != "true" } { continue }
#  
##    set_route_attributes -nets [get_db $net .name] -top_preferred_routing_layer $drv_layer -bottom_preferred_routing_layer $drv_layer \
##    -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort hard
#    
#    set_db $net .bottom_preferred_layer $drv_layer
#    set_db $net .top_preferred_layer $drv_layer
#    
#    lappend net_const_arr($drv_layer) [get_db $net .name]
#    
##    append_to_collection p2p_nets $net
#}
#
#
#set non_abuted_pins_nets [get_non_abuted_pins_nets $p2p_nets]
#convert_early_global_to_route $p2p_nets


eee "opt_design -pre_cts"
write_db out/db/${DESIGN_NAME}.place_opt.enc.dat

delete_obj [get_db route_blockages do_not_route_m1716_please]

write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.${STAGE}.def.gz
write_lef_abstract -5.8 \
	-top_layer $MAX_ROUTING_LAYER \
	-pg_pin_layers $MAX_ROUTING_LAYER \
	-stripe_pins \
	-property \
	out/lef/${DESIGN_NAME}.${STAGE}.lef



# Set route blockage between east r3 and east r4 from M11 to 15
create_route_blockage -rects {9713.256 4656.96 9820.00 5785.92}  -layers {M11 M12 M13 M14 M15}  -name eastr34_blockage


create_route_type -name new_clockRouteTop -top_preferred_layer $MAX_ROUTING_LAYER -bottom_preferred_layer [expr $MAX_ROUTING_LAYER -1] -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076
create_route_type -name new_clockRouteTrunk -top_preferred_layer $MAX_ROUTING_LAYER -bottom_preferred_layer 7 -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076
create_route_type -name new_clockRouteLeaf -top_preferred_layer [expr min($MAX_ROUTING_LAYER,10)] -bottom_preferred_layer 2 -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076
set_db cts_route_type_top   new_clockRouteTop
set_db cts_route_type_trunk new_clockRouteTrunk
set_db cts_route_type_leaf  new_clockRouteLeaf

commit_clock_tree_route_attributes -verbose

if { [get_db clock_trees] == "" } { create_clock_tree_spec }

set_db [get_db clock_trees *grid_*clk*] .cts_opt_ignore true
t [get_db clock_trees] cts_opt_ignore
eee "clock_design"



#return
##set routed_p2p [filter_routed_p2p_nets $p2p_nets ]
#convert_early_global_to_route $p2p_nets
#
#set straight_nets  [filter_routed_p2p_nets $p2p_nets]
#set p2p_not_routed [remove_from_collection  $p2p_nets  [get_nets $straight_nets ]]
#
#set wires [get_db $p2p_not_routed .wires]
#set vias  [get_db $p2p_not_routed .vias]
#delete_obj [concat $wires $vias]
#
#set curr 0
#set total [sizeof $p2p_not_routed]
#
#foreach_in_collection net $p2p_not_routed {
#
#    ory_progress $curr $total
#    incr curr
#    
#    if { ![llength [set drv [get_db $net .driver_pins]]] } { set drv [get_db $net .driver_ports] }
#    if { ![llength [set rcv [get_db $net .load_pins  ]]] } { set rcv [get_db $net .load_ports] }
#    
#    if { [llength [concat $drv $rcv]] != 2 } { continue }
#    
#    set drv_layer [get_db $drv .layer.route_index]
#    set rcv_layer [get_db $rcv .layer.route_index]
#
#    if { [compare_pins $drv $rcv] != "true" } { continue }
#  
##    set_route_attributes -nets [get_db $net .name] -top_preferred_routing_layer $drv_layer -bottom_preferred_routing_layer $drv_layer \
##    -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort hard
#    
#    set_db $net .bottom_preferred_layer $drv_layer
#    set_db $net .top_preferred_layer $drv_layer
#    
#    lappend net_const_arr($drv_layer) [get_db $net .name]
#    
##    append_to_collection p2p_nets $net
#}
#
#set non_abuted_pins_nets [get_non_abuted_pins_nets $p2p_nets]
#
#eee "opt_design -pre_cts -incremental"
#write_db out/db/${DESIGN_NAME}.place_opt_incr.enc.dat






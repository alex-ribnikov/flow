puts "-I- Start p2p preroutes [ory_time::now]"
set_interactive_constraint_modes func

set_multicycle_path 5 -from grid_clk -to grid_clk
set_multicycle_path 5 -from virtual_grid_clk -to grid_clk
set_multicycle_path 5 -from grid_clk -to virtual_grid_clk

read_def /services/bespace/users/ory/nextflow_pre_pn85/be_work/brcm5/grid_quadrant/v12_pn85.3_cts_tests/pnr_manual_route_w_route_blockages/out/def/routed_straight_nets_100pct.def

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
    
    lappend net_const_arr($drv_layer) [get_db $net .name]
    
    append_to_collection p2p_nets $net
}


set_db [get_db $p2p_nets ] .dont_touch true
#
#report_timing_summary > rts_pre_opt.rpt
#check_drc -limit 100000 > check_drc_pre_opt.rpt
#
#opt_design -setup -incremental -post_cts
#write_db -verilog out/db/${DESIGN_NAME}.post_2nd_opt_design.enc.dat
#
#report_timing_summary > rts_post_opt.rpt
#check_drc -limit 100000 > check_drc_post_opt.rpt


#set_db route_design_with_timing_driven false
#set_db route_design_antenna_diode_insertion false
#set_db opt_via_pillar_effort low
#set_db route_design_with_si_driven false
#set_db route_design_detail_fix_antenna false
#set_db route_design_detail_end_iteration 5
#set_db route_early_global_top_routing_layer 16
#set_db design_top_routing_layer 16

set_db opt_max_length 200
set_db route_design_with_timing_driven true
set_db route_design_antenna_diode_insertion true
set_db opt_via_pillar_effort low
set_db route_design_with_si_driven true
set_db route_design_detail_fix_antenna true
set_db route_design_detail_end_iteration 10
set_db route_early_global_top_routing_layer 16
set_db design_top_routing_layer 16


create_route_blockage  -layers {M16 M17} -rects [get_db designs .bbox] -name do_not_route_m1716_please

foreach inst_dpo [get_db [get_db insts -if .base_cell==*top*]] {
  set rect [lindex [get_db $inst_dpo .bbox] 0]
  lassign $rect xl yl xh yh
  set rect [list [expr $xl + 2] [expr $yl + 2] [expr $xh - 2] [expr $yh - 2]]
  create_route_blockage -rects $rect  -layers {M15}  -name temp_block_blockages
}

#
#so $all_other_nets
#route_global_detail -selected 
#
#puts "-I- End p2p preroutes [ory_time::now]"
#
#write_db -verilog out/db/${DESIGN_NAME}.post_pre_route.enc.dat
#

eee "add_fillers"

##### standard wbRouteDesign

set_db opt_new_inst_prefix "i_${STAGE}_topt_"
set_db opt_new_net_prefix  "n_${STAGE}_topt_"

set be_stage ${STAGE}_track_opt
eee_stage $be_stage {route_design -track_opt}

write_db -verilog      out/db/${DESIGN_NAME}.route_track_opt.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.route_track_opt.def.gz


set_db opt_new_inst_prefix "i_${STAGE}_multi_cut_"
set_db opt_new_net_prefix  "n_${STAGE}_multi_cut_"

report_route -multi_cut > reports/route/route_track_opt.multicut.init.rpt	
if {[info exists DFM_REDUNDANT_VIA] && [file exists $DFM_REDUNDANT_VIA]} {
	eval_legacy "source $DFM_REDUNDANT_VIA"
} else {
	set_db route_design_via_weight {VIA*_DFM_P1_VIA* 11,  VIA*_DFM_P2_VIA* 10,  VIA*_DFM_P3_VIA* 9,  VIA*_DFM_P4_VIA* 8,  VIA*_DFM_P5_VIA* 7,  VIA*_DFM_P6_VIA* 6,  VIA*_DFM_P7_VIA* 5,  VIA*_DFM_P8_VIA* 4,  VIA*_DFM_P9_VIA* 3}
	set_db route_design_detail_post_route_swap_via true
	eee "route_design -via_opt"
}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.route_multi_cut.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.route_multi_cut.def.gz

#------------------------------------------------------------------------------
# DRC check and fix
#------------------------------------------------------------------------------
eee_stage route_eco {route_eco -fix_drc}
check_drc -limit 500000

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.route_drc.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.route_drc.def.gz




write_db -verilog out/db/${DESIGN_NAME}.route.enc.dat





puts "-I- Start p2p preroutes [ory_time::now]"
set_interactive_constraint_modes func
#
#set all_gc_blocks [get_db insts *i_cluster_r*_c*]
#set all_reg_pins  [get_db [get_db $all_gc_blocks .pins] -if !.base_name==grid_clk&&!.base_name==grid_rst_n&&!.base_name==dft_scan_en]
#
#set_db $all_reg_pins .dont_touch true

## Ignore r3-r4 dlink pins since they are missaligned
#set pins [get_pins -hier "i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_ready_ft_out[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_valid_ft_out[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__0[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__1[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__2[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__3[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__4[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__5[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__6[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__7[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__8[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_data_ft_out__9[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_ready_ft_out[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_rsp_in_valid_ft_out[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__1[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__2[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__3[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__4[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__5[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__6[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__7[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__8[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__9[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_ready_ft_out[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_valid_ft_out[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__0[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__1[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__2[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__3[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__4[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__5[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__6[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__7[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__8[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_data_ft_out__9[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_ready_ft_out[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_rsp_in_valid_ft_out[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_ready[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_valid[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__0[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__1[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__2[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__3[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__4[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__5[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__6[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__7[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__8[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_data__9[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_ready[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_rsp_out_valid[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__1[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__2[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__3[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__4[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__5[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__6[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__7[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__8[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__9[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_ready[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_valid[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__0[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__1[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__2[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__3[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__4[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__5[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__6[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__7[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__8[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_data__9[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_ready[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_rsp_out_valid[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__0[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__1[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__2[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__3[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__4[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__5[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__6[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__7[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__8[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_node_req_out_data_ft_out__9[*]
#i_cluster_r3_c*_i_cbu_i_cbue_top/dlink_pt_req_out_data_ft_out__0[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__0[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__1[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__2[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__3[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__4[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__5[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__6[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__7[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__8[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_node_req_in_data__9[*]
#i_cluster_r4_c*_i_nfi_mcu_top/dlink_pt_req_in_data__0[*]"]
#set nets34 [get_nets -of $pins]
#set_db $nets34 .dont_touch true
#set_false_path -through $nets34

## Disconnect nets
#set_db eco_honor_dont_use false
#set_db eco_update_timing false
#set_db eco_refine_place false
#set_db eco_check_logical_equivalence false
#set curr 0
#set total [sizeof $nets34]
#foreach_in_collection net $nets34 {
#
#    ory_progress $curr $total
#    incr curr
#    
#    set pins [all_connected -leaf $net]
#    foreach_in_collection pin $pins { 
#        disconnect_pin -pin [get_db $pin .base_name] -inst [get_db $pin .inst.name]
#    }
#    
#}
#set_db eco_honor_dont_use true
#set_db eco_update_timing true
#set_db eco_refine_place true
#set_db eco_check_logical_equivalence true



#set all_other_nets [remove_from_collection [get_nets -hier -filter full_name!~*clk&&full_name!~*rst_n&&full_name!~dft_scan_en] $nets34]
set all_other_nets [get_nets -hier -filter full_name!~*clk&&full_name!~*rst_n&&full_name!~dft_scan_en]
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
    
    if { [llength [concat $drv $rcv]] > 2 } { continue }
    
    set drv_layer [get_db $drv .layer.route_index]
    set rcv_layer [get_db $rcv .layer.route_index]
    
    if { $drv_layer != $rcv_layer } { continue }
  
    set_route_attributes -nets [get_db $net .name] -top_preferred_routing_layer $drv_layer -bottom_preferred_routing_layer $drv_layer \
    -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort hard
    
    lappend net_const_arr($drv_layer) [get_db $net .name]
    
    append_to_collection p2p_nets $net
}

#puts "-I- Applying route rule"
#foreach layer [array names net_const_arr] {
#    puts "-I- Layer M[expr $layer - 1]"
#    set bus_comp [ory_bus_compress $net_const_arr($layer)]
#    puts "-I- Applying rule on [llength $bus_comp] busses"
#    foreach bus $bus_comp {
#        set_route_attributes -nets $bus -top_preferred_routing_layer $layer -bottom_preferred_routing_layer $layer
#    }
#}

set_db [get_db nets] .dont_touch true
#set_false_path -through $p2p_nets


set_interactive_constraint_modes {}

set_db route_design_with_timing_driven false
set_db route_design_with_si_driven false
set_db route_design_detail_end_iteration 5

so $all_other_nets
route_global_detail -selected 

puts "-I- End p2p preroutes [ory_time::now]"

write_db -verilog out/db/${DESIGN_NAME}.post_pre_route.enc.dat
stop here

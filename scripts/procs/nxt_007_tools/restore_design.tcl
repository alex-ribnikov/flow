##### pasted: -rwxrwxrwx 1 jeromem ns 226 Sep  8 19:56 /space/users/moriya/nextflow/project_flow/NXT007/controls/INN.preproc.paste
# Variables to set before loading libraries
set_db add_route_vias_auto true ;                                       # (default : false
set_db add_route_vias_advanced_rule true ;                              # (default : false

set utilsDir /space/users/moriya/nextflow/be_flow/cadence/wb/generic/scripts/../utils
source $utilsDir/innovus_utils.tcl

set_db design_process_node 7
set_dont_use [get_lib_cells *D0BWP*]
set_dont_use [get_lib_cells *D32*]
set_dont_use [get_lib_cells *D24*]
set_dont_use [get_lib_cells *D20*]
set_dont_use [get_lib_cells *D18*]
set_dont_use [get_lib_cells SDFQOPTBB*]
set_dont_use [get_lib_cells XNR2D1BWP*]
set_dont_use [get_lib_cells NR2SKPD1BWP*]
set_dont_use [get_lib_cells NR2D1BWP*]
set_dont_use [get_lib_cells ND2SKND1BWP*]
set_dont_use [get_lib_cells ND2D1BWP*]
set_dont_use [get_lib_cells INVSKPD2BWP*]
set_dont_use [get_lib_cells INVSKPD1BWP*]
set_dont_use [get_lib_cells INVSKND2BWP*]
set_dont_use [get_lib_cells INVSKND1BWP*]
set_dont_use [get_lib_cells INR2D1BWP*]
set_dont_use [get_lib_cells IND2D1BWP*]
set_dont_use [get_lib_cells CKNR2D1BWP*]
set_dont_use [get_lib_cells CKND2D1BWP*]
set_dont_use [get_lib_cells CKND2BWP*]
set_dont_use [get_lib_cells CKND1BWP*]
set_dont_use [get_lib_cells CKBD1BWP*]
set_dont_use [get_lib_cells BUFFSKPD1BWP*]
set_dont_use [get_lib_cells BUFFSKND1BWP*]
set_dont_use [get_lib_cells BUFTD*]
set_dont_use [get_lib_cells MB*SRLSDFRPQ*]
set_dont_use [get_lib_cells MB*SRLSDFSNQ*]
set_dont_use [get_lib_cells MB*SRLSDFKRPQ*]

##### pasted: -rwxrwxrwx 1 jeromem ns 24403 Oct 28 17:56 /space/users/moriya/nextflow/project_flow/NXT007/controls/INN.setup.paste
# Process
###############################################
set_db design_process_node 7
set_db route_design_process_node N7

# Flow
###############################################
set_db design_flow_effort standard ;					# (default : standard)
set_db design_early_clock_flow true ;					# (default : false)
set_db design_power_effort low ;					# (default : none)
#set_db opt_via_pillar_effort low ;					# (default : low) - Not supported yet in CUI for Innovus 18.1
eval_legacy "setOptMode -viaPillarEffort low"

# Floorplan
###############################################
set_db floorplan_default_tech_site core ;                               # (default : "")
set_db floorplan_row_site_width even ;					# (default : any)
set_db floorplan_row_site_height even ;					# (default : any)
set_db floorplan_check_types odd_even_site_row ;			# (default : basic)
set_db floorplan_snap_block_grid inst ;					# (default : manufacturing)
set_floorplan_mode -floorplan_global_odd_even_sites_height 2
set_floorplan_mode -floorplan_global_odd_even_sites_row 2

# Verify DRC
###############################################
set_db check_drc_limit 10000 ;						# (default : 1000)
set_db check_drc_inside_via_def true ;					# (default : false)

# DRV
###############################################
set_db opt_fix_fanout_load true ;					# (default : false)
set_db opt_drv_margin 0.05 ;						# (default : 0.0)

# Placement
###############################################
set_db place_global_clock_gate_aware true ;				# (default : true)
#set_db place_global_clock_power_driven_effort standard ;		# (default : standard)
#set_db place_global_activity_power_driven true ;			# (default : false)
#set_db place_hard_fence true ;						# (default : false)
set_db place_detail_use_no_diffusion_one_site_filler true ;		# (default : false)

# Endcap cells
eval_legacy {  setEndCapMode \
    -min_vertical_channel_width 48 \
    -min_jog_width 10 \
    -min_horizontal_channel_width 10 \
    -min_jog_height 3 \
}
set_db add_endcaps_avoid_two_sites_cell_abut true 
set_db add_endcaps_boundary_tap 	   false 
set_db add_endcaps_left_edge_even	   BOUNDARYRIGHTBWP240H8P57PDSVT  
set_db add_endcaps_left_edge_odd	   BOUNDARYRIGHTBWP240H8P57PDSVT  
set_db add_endcaps_left_top_corner_even    BOUNDARYPCORNERBWP240H8P57PDSVT  
set_db add_endcaps_left_top_corner_odd     BOUNDARYPCORNERBWP240H8P57PDSVT 
set_db add_endcaps_left_bottom_corner_even BOUNDARYNCORNERBWP240H8P57PDSVT 
set_db add_endcaps_left_bottom_corner_odd  BOUNDARYNCORNERBWP240H8P57PDSVT 
set_db add_endcaps_top_edge		  {BOUNDARYPROW2BWP240H8P57PDSVT BOUNDARYPROW4BWP240H8P57PDSVT BOUNDARYPROW8BWP240H8P57PDSVT} 
set_db add_endcaps_bottom_edge  	  {BOUNDARYNROW2BWP240H8P57PDSVT BOUNDARYNROW4BWP240H8P57PDSVT BOUNDARYNROW8BWP240H8P57PDSVT}
set_db add_endcaps_right_edge_even	   BOUNDARYLEFTBWP240H8P57PDSVT 
set_db add_endcaps_right_edge_odd	   BOUNDARYLEFTBWP240H8P57PDSVT
set_db add_endcaps_right_top_edge_even     BOUNDARYPINCORNERBWP240H8P57PDSVT
set_db add_endcaps_right_top_edge_odd	   BOUNDARYPINCORNERBWP240H8P57PDSVT
set_db add_endcaps_right_bottom_edge_even  BOUNDARYNINCORNERBWP240H8P57PDSVT
set_db add_endcaps_right_bottom_edge_odd   BOUNDARYNINCORNERBWP240H8P57PDSVT
set_db add_endcaps_use_even_odd_sites	   even

# Tie-cells
###############################################
set_db add_tieoffs_cells {TIEHXPBWP240H11P57PDSVT TIELXNBWP240H11P57PDSVT} ;		# ""
set_db add_tieoffs_max_fanout 5 ;                                       # (default : 0)
set_db add_tieoffs_max_distance 20 ;                                    # (default : 0.0)

# Optimization
###############################################
set_db opt_max_length 150 ;						# (default : -1)
set_db opt_all_end_points true ;					# (default : false)
set_db opt_power_effort low ;						# (default : none)
set_db opt_enable_data_to_data_checks true ;				# (default : false)
set_limited_access_feature FlipFlopMergeAndSplit 1
set_db opt_multi_bit_flop_opt true ;					# (default : false)
eval_legacy "setOptMode -flopMergeDebug 1" ;				# (default : 0)
set_db opt_post_route_fix_glitch true ;					# (default : true)
set_db opt_post_route_fix_si_transitions true ;				# (default : false)
set_db opt_time_design_compress_reports false ;				# (default : true)
set_db opt_time_design_num_paths 100 ;					# (default : 50)
set_db opt_time_design_expanded_view true ;				# (default : false)
set_db opt_time_design_report_net true ;				# (default : true)
#set_db opt_useful_skew_cells {} ;					# (default : {})
#set_db opt_useful_skew_max_allowed_delay 0.25 ;			# (default : 1.0)
set_db opt_multi_bit_flop_opt  true ;				        # (default : false)
set_db opt_preserve_user_route_type_constraints true ;			# (default : false)
set_db opt_spatial_power_driven true ;				        # (default : false)
#set_db opt_setup_target_slack  0.0 ;				        # (default : 0.0
#set_db opt_hold_target_slack  0.0 ;				        # (default : 0.0)

# CCOpt
###############################################
set_db opt_useful_skew_no_boundary true
set_db ccopt_worst_chain_report_timing true ;				# (default : false)
set_db cts_adjacent_rows_legal false ;					# (default : false)
set_db cts_cell_density 0.2 ;						# (default : 0.75)
set_db cts_buffer_cells {DCCKBD6BWP240H11P57PDULVT DCCKBD8BWP240H11P57PDULVT DCCKBD10BWP240H11P57PDULVT DCCKBD12BWP240H11P57PDULVT DCCKBD14BWP240H11P57PDULVT DCCKBD16BWP240H11P57PDULVT}
set_db cts_inverter_cells {DCCKND6BWP240H11P57PDULVT DCCKND8BWP240H11P57PDULVT DCCKND10BWP240H11P57PDULVT DCCKND12BWP240H11P57PDULVT DCCKND14BWP240H11P57PDULVT DCCKND16BWP240H11P57PDULVT}
set_db cts_logic_cells {CKXOR2D4BWP240H11P57PDULVT CKXOR2D8BWP240H11P57PDULVT CKOR2D4BWP240H11P57PDULVT CKOR2D8BWP240H11P57PDULVT CKNR2D4BWP240H11P57PDULVT CKNR2D8BWP240H11P57PDULVT CKAN2D4BWP240H11P57PDULVT CKAN2D8BWP240H11P57PDULVT CKND2D4BWP240H11P57PDULVT CKND2D8BWP240H11P57PDULVT CKMUX2D4BWP240H11P57PDULVT CKMUX2D8BWP240H11P57PDULVT}
set_db cts_clock_gating_cells {CKLHQD4BWP240H11P57PDULVT CKLHQD5BWP240H11P57PDULVT CKLHQD6BWP240H11P57PDULVT CKLHQD8BWP240H11P57PDULVT CKLHQD10BWP240H11P57PDULVT CKLHQD12BWP240H11P57PDULVT CKLHQD14BWP240H11P57PDULVT CKLHQD16BWP240H11P57PDULVT CKLNQD4BWP240H11P57PDULVT CKLNQD5BWP240H11P57PDULVT CKLNQD6BWP240H11P57PDULVT CKLNQD8BWP240H11P57PDULVT CKLNQD10BWP240H11P57PDULVT CKLNQD12BWP240H11P57PDULVT CKLNQD14BWP240H11P57PDULVT CKLNQD16BWP240H11P57PDULVT}
set_db cts_use_inverters true ;						# (default : auto)
set_db cts_max_fanout 50 ;					       # (default : 100)
set_db cts_top_fanout_threshold 1000 ;  			       # (default : unset)
set_db cts_target_max_transition_time 0.05 ;			       # (default : default)
set_db cts_target_max_transition_time_leaf 0.05 ;		       # (default : default)
if {[get_db route_rules  2w_2s] == ""} {
  create_route_rule -name 2w_2s -spacing_multiplier {M4:M13 2} -width_multiplier {M4:M13 2} -min_cut {VIA4:VIA12 2}
}
if {[get_db route_types .name clockRouteTop] == ""} {
  create_route_type -name clockRouteTop -top_preferred_layer 13 -bottom_preferred_layer 12 -preferred_routing_layer_effort high -route_rule 2w_2s -shield_net VSS
}
if {[get_db route_types .name clockRouteTrunk] == ""} {
  create_route_type -name clockRouteTrunk -top_preferred_layer 13 -bottom_preferred_layer 12 -preferred_routing_layer_effort high -route_rule 2w_2s -shield_net VSS
}
if {[get_db route_types .name clockRouteLeaf] == ""} {
  create_route_type -name clockRouteLeaf -top_preferred_layer 11 -bottom_preferred_layer 6 -preferred_routing_layer_effort high -route_rule 2w_2s
}
set_db cts_route_type_top   clockRouteTop
set_db cts_route_type_trunk clockRouteTrunk
set_db cts_route_type_leaf  clockRouteLeaf


set_db [get_db base_cells DCCKBD6BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells DCCKBD8BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells DCCKBD10BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells DCCKBD12BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells DCCKBD14BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells DCCKBD16BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells DCCKND6BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells DCCKND8BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells DCCKND10BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells DCCKND12BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells DCCKND14BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells DCCKND16BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLHQD4BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKLHQD5BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKLHQD6BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKLHQD8BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLHQD10BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLHQD12BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLHQD14BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLHQD16BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLNQD4BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKLNQD5BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKLNQD6BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKLNQD8BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLNQD10BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLNQD12BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLNQD14BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKLNQD16BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKXOR2D4BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKXOR2D8BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKOR2D4BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKOR2D8BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKNR2D4BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKNR2D8BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKAN2D4BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKAN2D8BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKND2D4BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKND2D8BWP240H11P57PDULVT] .cts_cell_halo_x 3.42
set_db [get_db base_cells CKMUX2D4BWP240H11P57PDULVT] .cts_cell_halo_x 1.71
set_db [get_db base_cells CKMUX2D8BWP240H11P57PDULVT] .cts_cell_halo_x 3.42

set_db [get_db base_cells DCCKBD6BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells DCCKBD8BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells DCCKBD10BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells DCCKBD12BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells DCCKBD14BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells DCCKBD16BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells DCCKND6BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells DCCKND8BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells DCCKND10BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells DCCKND12BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells DCCKND14BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells DCCKND16BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLHQD4BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKLHQD5BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKLHQD6BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKLHQD8BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLHQD10BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLHQD12BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLHQD14BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLHQD16BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLNQD4BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKLNQD5BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKLNQD6BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKLNQD8BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLNQD10BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLNQD12BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLNQD14BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKLNQD16BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKXOR2D4BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKXOR2D8BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKOR2D4BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKOR2D8BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKNR2D4BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKNR2D8BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKAN2D4BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKAN2D8BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKND2D4BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKND2D8BWP240H11P57PDULVT] .cts_cell_halo_x 1.96
set_db [get_db base_cells CKMUX2D4BWP240H11P57PDULVT] .cts_cell_halo_x 0.98
set_db [get_db base_cells CKMUX2D8BWP240H11P57PDULVT] .cts_cell_halo_x 1.96

# Hold fixing
###############################################
set_db opt_fix_hold_verbose true ;					# (default : false)
#set_db opt_fix_hold_ignore_path_groups {in2reg reg2out in2out} ;	# (default : "")
#set_db opt_fix_hold_allow_setup_tns_degradation false ;	                # (default : true)

# Delay calculation and STA
###############################################
set_db timing_report_fields {instance cell arc delay arrival transition load fanout incr_delay user_derate instance_location}
set_db timing_analysis_type ocv ;					# (default : ocv)
set_db timing_analysis_cppr both ;					# (default : none)
set_db timing_analysis_async_checks async ;				# (default : async)
set_db timing_analysis_clock_propagation_mode sdc_control ;		# (default : sdc_control)
set_db timing_report_launch_clock_path true ;				# (default : false)
set_db timing_case_analysis_for_icg_propagation always ;		# (default : false)
set_db timing_analysis_self_loops_paths_no_skew false ;			# (default : false)
set_db timing_enable_generated_clock_edge_based_source_latency true ;	# (default : true)
set_db timing_apply_default_primary_input_assertion true ;		# (default : true)
set_db timing_dynamic_loop_breaking true ;				# (default : true)
set_db timing_disable_internal_inout_net_arcs true ;			# (default : true)
set_db timing_enable_data_through_clock_gating true ;			# (default : true)
set_db timing_enable_uncertainty_for_clock_checks true ;		# (default : false)
set_db timing_recompute_sdf_in_setuphold_mode true ;			# (default : false)
set_db timing_generated_clocks_inherit_ideal_latency true ;		# (default : false)
set_db timing_enable_preset_clear_arcs true ;				# (default : false)
set_db timing_disable_retime_clock_path_slew_propagation true ;		# (default : true)
set_db timing_generated_clocks_inherit_ideal_latency true ;		# (default : false)
#set_db timing_cppr_threshold_ps 3 ;					# (default : 20)
#set_db timing_analysis_aocv true ;					# (default : false)
#set_db timing_aocv_analysis_mode launch_capture ;			# (default : launch_capture)
#set_db timing_enable_aocv_slack_based true ;				# (default : false)
set_db timing_analysis_socv true ;					# (default : false)
#set_db timing_disable_inout_output_side_timing_checks true ;		# (default : true)
#set_db timing_disable_library_data_to_data_checks true ;		# (default : false)
# Delay Mode
###############################################
set_db delaycal_default_net_load 0.1pf ;				# (default : 0.5pf)
set_db delaycal_equivalent_waveform_model propagation ;			# (default : none)
set_db delaycal_ewm_type simulation ;					# (default : moments)
set_db delaycal_socv_accuracy_mode low ;				# (default : low)
set_db delaycal_socv_lvf_mode moments ;				        # (default : moments)
set_db delaycal_socv_use_lvf_tables all ;				# (default : all)
set_db delaycal_enable_quiet_receivers_for_hold true ;		        # (default : false)
set_db delaycal_advanced_node_pin_cap_settings true ;		        # (default : false)
set_socv_reporting_nsigma_multiplier -setup 3.0 -hold 4.5 

# SOCV RC variation
set_db timing_socv_rc_variation_mode true
foreach _av [all_analysis_views] {
  set _rc [get_delay_corner [get_analysis_view $_av -delay_corner] -rc_corner]
  if {[regexp "typ|\w+T" $_rc]} {
    puts "INFO: set_socv_rc_variation_factor 0.1 -view $_av -late -early"
    set_socv_rc_variation_factor 0.1 -view $_av -late -early
  } elseif {[regexp "cbCCb$|rcbCCb$" $_rc]} {
    puts "INFO: set_socv_rc_variation_factor -late 0.1 -view $_av"
    set_socv_rc_variation_factor -late 0.1 -view $_av
  } elseif {[regexp "cwCCw$|rcwCCw$" $_rc]} {
    puts "INFO: set_socv_rc_variation_factor -early 0.1 -view $_av"
    set_socv_rc_variation_factor -early 0.1 -view $_av
  }
}

## SI Mode
set_db delaycal_enable_si true ;				        # (default : false)
set_db si_delay_separate_on_data true ;					# (default : false)
set_db si_delay_delta_annotation_mode lumpedOnNet ;			# (default : arc)
set_db si_delay_enable_double_clocking_check true ;			# (default : false)
set_db si_glitch_enable_report true ;					# (default : false)
set_db si_accumulated_small_aggressor_mode current ;			# (default : current)
# delta_slew report is huge
#set_db si_enable_delta_slew_report true ;				# (default : false)
set_db si_delay_enable_report true ;					# (default : false)
set_db si_enable_drv_with_delta_slew true ;				# (default : false)
set_db timing_enable_si_cppr true ;					# (default : true)
set_db timing_cppr_transition_sense same_transition_expanded ;		# (default : normal)
#set_db si_glitch_receiver_peak_limit 0.15 ;				# (default : 0.15)
#set_db si_accumulated_small_aggressor_threshold 0.03 ;			# (default : 10.01, ie disabled)
#set_db si_individual_aggressor_threshold 0.01 ;			# (default : 0.015)
#set_db si_delay_delta_threshold 1e-12; 				# (default : -1)
#set_db si_accumulated_small_aggressor_factor 0.0 ;			# (default : 1)
set_db si_use_infinite_timing_window false ;				# (default : false)
set_db si_aggressor_alignment timing_aware_edge ;			# (default : path)

# Extraction
###############################################
#set_db extract_rc_relative_cap_threshold  ;				# (default : 0.03)
#set_db extract_rc_coupling_cap_threshold  ;				# (default : 3.0)
#set_db extract_rc_total_cap_threshold  ;				# (default : 5.0)
#set_db extract_rc_cap_filter_mode relative_and_coupling ;		# (default : relative_and_coupling)   
set_db extract_rc_effort_level high ;					# (default : medium)    

# Power
###############################################
set_db power_clock_source_as_clock true ;				# (default : false)
set_db power_disable_static false ;					# (default : true)
set_db power_honor_negative_energy true ;				# (default : true)
set_db power_ignore_control_signals false ;				# (default : true)
set_db power_read_rcdb true ;						# (default : false)
set_db power_constant_override false ;					# (default : false)
set_db power_domain_based_clipping true ;				# (default : false)

#set_db power_transition_time_method avg ;				# (default : max)
#set_db power_average_rise_fall_cap true ;				# (default : false)
#set_db power_compatible_internal_power false ;				# (default : true)

set_default_switching_activity -clip_activity_to_domain_freq true ;	# (default : false)

# Fillercells
###############################################
set decap1  "DCAP64XPBWP240H11P57PDSVT DCAP64XPXNBWP240H11P57PDSVT"
set decap2  "DCAP32XPBWP240H11P57PDSVT DCAP32XPXNBWP240H11P57PDSVT"
set decap3  "DCAP16XPBWP240H11P57PDSVT DCAP16XPXNBWP240H11P57PDSVT"
set decap4  "DCAP8XPBWP240H11P57PDSVT DCAP8XPXNBWP240H11P57PDSVT"
set decap5  "DCAP4XPBWP240H11P57PDSVT"
set filler1 "FILL64BWP240H11P57PDSVT FILL64BWP240H11P57PDLVT FILL64BWP240H11P57PDULVT FILL64BWP240H8P57PDSVT FILL64BWP240H8P57PDLVT FILL64BWP240H8P57PDULVT"
set filler2 "FILL32BWP240H11P57PDSVT FILL32BWP240H11P57PDLVT FILL32BWP240H11P57PDULVT FILL32BWP240H8P57PDSVT FILL32BWP240H8P57PDLVT FILL32BWP240H8P57PDULVT"
set filler3 "FILL16BWP240H11P57PDSVT FILL16BWP240H11P57PDLVT FILL16BWP240H11P57PDULVT FILL16BWP240H8P57PDSVT FILL16BWP240H8P57PDLVT FILL16BWP240H8P57PDULVT"
set filler4 "FILL12BWP240H11P57PDSVT FILL12BWP240H11P57PDLVT FILL12BWP240H11P57PDULVT FILL12BWP240H8P57PDSVT FILL12BWP240H8P57PDLVT FILL12BWP240H8P57PDULVT"
set filler5 "FILL8BWP240H11P57PDSVT FILL8BWP240H11P57PDLVT FILL8BWP240H11P57PDULVT FILL8BWP240H8P57PDSVT FILL8BWP240H8P57PDLVT FILL8BWP240H8P57PDULVT"
set filler6 "FILL4BWP240H11P57PDSVT FILL4BWP240H11P57PDLVT FILL4BWP240H11P57PDULVT FILL4BWP240H8P57PDSVT FILL4BWP240H8P57PDLVT FILL4BWP240H8P57PDULVT"
set filler7 "FILL3BWP240H11P57PDSVT FILL3BWP240H11P57PDLVT FILL3BWP240H11P57PDULVT FILL3BWP240H8P57PDSVT FILL3BWP240H8P57PDLVT FILL3BWP240H8P57PDULVT"
set filler8 "FILL2BWP240H11P57PDSVT FILL2BWP240H11P57PDLVT FILL2BWP240H11P57PDULVT FILL2BWP240H8P57PDSVT FILL2BWP240H8P57PDLVT FILL2BWP240H8P57PDULVT"
set filler9 "FILL1BWP240H11P57PDSVT FILL1BWP240H11P57PDLVT FILL1BWP240H11P57PDULVT FILL1BWP240H8P57PDSVT FILL1BWP240H8P57PDLVT FILL1BWP240H8P57PDULVT"
set _fillers "$decap1 $decap2 $decap3 $decap4 $decap5 $filler1 $filler2 $filler3 $filler4 $filler5 $filler6 $filler7 $filler8 $filler9"
set designname [get_db designs .name]
set_db add_fillers_cells $_fillers
#set_db add_fillers_no_single_site_gap true
set_db add_fillers_prefix FILL_${designname} 
set_db add_fillers_preserve_user_order true
set_db add_fillers_eco_mode true
set_db add_fillers_avoid_abutment_patterns "1:1 2:1" ;		        # (default : "1:1 2:1") 
set_db add_fillers_swap_cell {\
{FILL1BWP240H11P57PDSVT FILL1NOBCMBWP240H11P57PDSVT} \
{FILL1BWP240H11P57PDLVT FILL1NOBCMBWP240H11P57PDLVT} \
{FILL1BWP240H11P57PDULVT FILL1NOBCMBWP240H11P57PDULVT} \
{FILL1BWP240H8P57PDSVT FILL1NOBCMBWP240H8P57PDSVT} \
{FILL1BWP240H8P57PDLVT FILL1NOBCMBWP240H8P57PDLVT} \
{FILL1BWP240H8P57PDULVT FILL1NOBCMBWP240H8P57PDULVT}}
	      
# Routing
###############################################
set_max_route_layer 13
set_db route_early_global_bottom_routing_layer 2 ;			# (default : 2)
set_db route_early_global_top_routing_layer 13 ;			# (default : 2147483647)
set_db route_design_detail_fix_antenna true ;				# (default : true)
set_db route_design_antenna_diode_insertion true ;			# (default : false)
set_db route_design_diode_insertion_for_clock_nets true ;		# (default : false)
set_db route_design_with_timing_driven true ;				# (default : false)
set_db route_design_with_si_driven true ;				# (default : false)
set_db route_design_with_litho_driven true ;				# (default : false)
set_db route_design_with_trim_metal {-layer 2  \
  -mask2 {-pitch 0.24 -core_offset 0.225 -width 0.03 }  \
  -mask2 {-pitch 0.24 -core_offset 0.095 -width 0.03 }  \
  -mask1 {-pitch 0.24 -core_offset 0.015 -width 0.03 }  \
  -mask1 {-pitch 0.24 -core_offset 0.145 -width 0.03 }}
set_db route_design_concurrent_minimize_via_count_effort high ;		# (default : medium)
set_db route_design_detail_use_multi_cut_via_effort low ;		# (default : low)
set_db route_design_concurrent_minimize_via_count_effort  high
set_db route_design_reserve_space_for_multi_cut true ;			# (default : false)
set_db route_design_strict_honor_route_rule true ;			# (default : false)
set_db route_design_detail_auto_stop false ;				# (default : true)
set_db route_design_with_via_in_pin false ;				# (default : false)
set_db route_design_detail_post_route_spread_wire false ;		# (default : auto)
# Connect to M2 pins using only vias. No planar connections.
eval_legacy {setNanoRouteMode -routeWithViaOnlyForMacroCellPin "2:2"}
set_db route_design_antenna_cell_name ANTENNABWP240H11P57PDSVT ;	# (default : "")

# Stream
###############################################
set_db write_stream_pin_text_orientation automatic ;			# (default : false)
set_db write_stream_virtual_connection false ;				# (default : true)

##### source: -rwxrwxrwx 1 jeromem ns 0 Aug 31 17:58 /space/users/moriya/nextflow/project_flow/NXT007/controls/INN.procs.tcl
source /space/users/moriya/nextflow/project_flow/NXT007/controls/INN.procs.tcl

##### timing derate
source scr/do_innovusPostC.set_timing_derate.tcl

create_basic_path_groups -expanded

##### pasted: -rwxrwxrwx 1 jeromem ns 36076 Oct 21 10:52 /space/users/moriya/nextflow/project_flow/NXT007/controls/signoff_model_mbist_derating.paste
global delta_voltage_derate_tt delta_voltage_derate_ff delta_temperature_derate
global extra_setup_clock_derate_early extra_setup_clock_derate_late extra_setup_data_derate_late extra_hold_clock_derate_early extra_hold_data_derate_early extra_hold_clock_derate_late
global extra_memory_min_derate extra_memory_max_derate extra_ip_min_derate extra_ip_max_derate
global extra_memory_setup_margin extra_memory_hold_margin extra_ip_setup_margin extra_ip_hold_margin

# Delta voltage for timing derate (mV)
# Possible values for slow corners 3.4, 6.8, 10.1, 13.5, 16.9, 33.8, 50.6, 67.5
# Possible values for typical corners 3.8, 7.5, 11.3, 15.0, 18.8, 37.5, 56.3, 75.0
# Possible values for fast corners 3.7, 7.5, 11.2, 15.0, 18.7, 37.5, 56.2, 75.0
set delta_voltage_derate_ss 10.1
set delta_voltage_derate_tt 18.8
set delta_voltage_derate_ff 18.7

# Delta temperature for timing derate (degre)
# It must be a multiple of 10.
set delta_temperature_derate 20

# Add extra derating on clock paths
set extra_setup_clock_derate_early -0.02
set extra_setup_clock_derate_late 0.02
set extra_setup_data_derate_late 0.00
set extra_hold_clock_derate_early -0.03
set extra_hold_data_derate_early -0.03
set extra_hold_clock_derate_late 0.03

# Add extra derating on memory cell delay (signoff model)
set extra_memory_min_derate -0.03
set extra_memory_max_derate 0.05

# Add extra derating on IP cell delay (signoff model)
set extra_ip_min_derate 0.00
set extra_ip_max_derate 0.00

# Add extra margin (ns) for memories (signoff model + MBIST)
set extra_memory_setup_margin [expr 0.020 + 0.030]
set extra_memory_hold_margin [expr 0.010 + 0.015]

# Add extra margin (ns) for IPs (signoff model)
set extra_ip_setup_margin 0.00
set extra_ip_hold_margin 0.00

##############################################################################

# Add VT derates
proc add_vt_derates {delayCorner} {
  global delta_voltage_derate_ss delta_voltage_derate_tt delta_voltage_derate_ff delta_temperature_derate
  
  # 
  # set_timing_derate -cell_delay -add <V & T flat OCV>
  #
  # lookup table for VT derating values
  # (taken from TSMC signoff document)
  # -----------------------------------
  array set user_voltage_derate {
    ssgnp_0p675v_m40c,8,svt,3.4   0.017     ssgnp_0p675v_m40c,8,svt,6.8   0.033     ssgnp_0p675v_m40c,8,svt,10.1   0.048     ssgnp_0p675v_m40c,8,svt,13.5   0.064     ssgnp_0p675v_m40c,8,svt,16.9   0.079     ssgnp_0p675v_m40c,8,svt,33.8   0.145     ssgnp_0p675v_m40c,8,svt,50.6   0.202     ssgnp_0p675v_m40c,8,svt,67.5   0.252 
    ssgnp_0p675v_m40c,8,lvt,3.4   0.012     ssgnp_0p675v_m40c,8,lvt,6.8   0.023     ssgnp_0p675v_m40c,8,lvt,10.1   0.034     ssgnp_0p675v_m40c,8,lvt,13.5   0.044     ssgnp_0p675v_m40c,8,lvt,16.9   0.054     ssgnp_0p675v_m40c,8,lvt,33.8   0.103     ssgnp_0p675v_m40c,8,lvt,50.6   0.145     ssgnp_0p675v_m40c,8,lvt,67.5   0.183 
    ssgnp_0p675v_m40c,8,ulvt,3.4  0.009     ssgnp_0p675v_m40c,8,ulvt,6.8  0.017     ssgnp_0p675v_m40c,8,ulvt,10.1  0.026     ssgnp_0p675v_m40c,8,ulvt,13.5  0.034     ssgnp_0p675v_m40c,8,ulvt,16.9  0.042     ssgnp_0p675v_m40c,8,ulvt,33.8  0.079     ssgnp_0p675v_m40c,8,ulvt,50.6  0.113     ssgnp_0p675v_m40c,8,ulvt,67.5  0.143

    ssgnp_0p675v_0c,8,svt,3.4     0.016     ssgnp_0p675v_0c,8,svt,6.8     0.031     ssgnp_0p675v_0c,8,svt,10.1     0.045     ssgnp_0p675v_0c,8,svt,13.5     0.059     ssgnp_0p675v_0c,8,svt,16.9     0.073     ssgnp_0p675v_0c,8,svt,33.8     0.136     ssgnp_0p675v_0c,8,svt,50.6     0.190     ssgnp_0p675v_0c,8,svt,67.5     0.237 
    ssgnp_0p675v_0c,8,lvt,3.4     0.011     ssgnp_0p675v_0c,8,lvt,6.8     0.021     ssgnp_0p675v_0c,8,lvt,10.1     0.032     ssgnp_0p675v_0c,8,lvt,13.5     0.042     ssgnp_0p675v_0c,8,lvt,16.9     0.051     ssgnp_0p675v_0c,8,lvt,33.8     0.097     ssgnp_0p675v_0c,8,lvt,50.6     0.137     ssgnp_0p675v_0c,8,lvt,67.5     0.174 
    ssgnp_0p675v_0c,8,ulvt,3.4    0.008     ssgnp_0p675v_0c,8,ulvt,6.8    0.016     ssgnp_0p675v_0c,8,ulvt,10.1    0.024     ssgnp_0p675v_0c,8,ulvt,13.5    0.032     ssgnp_0p675v_0c,8,ulvt,16.9    0.039     ssgnp_0p675v_0c,8,ulvt,33.8    0.075     ssgnp_0p675v_0c,8,ulvt,50.6    0.107     ssgnp_0p675v_0c,8,ulvt,67.5    0.136 

    ssgnp_0p675v_125c,8,svt,3.4   0.012     ssgnp_0p675v_125c,8,svt,6.8   0.024     ssgnp_0p675v_125c,8,svt,10.1   0.036     ssgnp_0p675v_125c,8,svt,13.5   0.047     ssgnp_0p675v_125c,8,svt,16.9   0.058     ssgnp_0p675v_125c,8,svt,33.8   0.109     ssgnp_0p675v_125c,8,svt,50.6   0.155     ssgnp_0p675v_125c,8,svt,67.5   0.196 
    ssgnp_0p675v_125c,8,lvt,3.4   0.009     ssgnp_0p675v_125c,8,lvt,6.8   0.018     ssgnp_0p675v_125c,8,lvt,10.1   0.026     ssgnp_0p675v_125c,8,lvt,13.5   0.034     ssgnp_0p675v_125c,8,lvt,16.9   0.042     ssgnp_0p675v_125c,8,lvt,33.8   0.080     ssgnp_0p675v_125c,8,lvt,50.6   0.115     ssgnp_0p675v_125c,8,lvt,67.5   0.146 
    ssgnp_0p675v_125c,8,ulvt,3.4  0.007     ssgnp_0p675v_125c,8,ulvt,6.8  0.013     ssgnp_0p675v_125c,8,ulvt,10.1  0.020     ssgnp_0p675v_125c,8,ulvt,13.5  0.026     ssgnp_0p675v_125c,8,ulvt,16.9  0.032     ssgnp_0p675v_125c,8,ulvt,33.8  0.062     ssgnp_0p675v_125c,8,ulvt,50.6  0.089     ssgnp_0p675v_125c,8,ulvt,67.5  0.113 

    tt_0p75_85c,8,svt,3.8         0.010     tt_0p75_85c,8,svt,7.5         0.019     tt_0p75_85c,8,svt,11.3         0.029     tt_0p75_85c,8,svt,15.0         0.039     tt_0p75_85c,8,svt,18.8         0.048     tt_0p75_85c,8,svt,37.5         0.097     tt_0p75_85c,8,svt,56.3         0.146     tt_0p75_85c,8,svt,75.0         0.195 
    tt_0p75_85c,8,lvt,3.8         0.007     tt_0p75_85c,8,lvt,7.5         0.014     tt_0p75_85c,8,lvt,11.3         0.021     tt_0p75_85c,8,lvt,15.0         0.028     tt_0p75_85c,8,lvt,18.8         0.036     tt_0p75_85c,8,lvt,37.5         0.071     tt_0p75_85c,8,lvt,56.3         0.107     tt_0p75_85c,8,lvt,75.0         0.144 
    tt_0p75_85c,8,ulvt,3.8        0.006     tt_0p75_85c,8,ulvt,7.5        0.011     tt_0p75_85c,8,ulvt,11.3        0.017     tt_0p75_85c,8,ulvt,15.0        0.022     tt_0p75_85c,8,ulvt,18.8        0.028     tt_0p75_85c,8,ulvt,37.5        0.055     tt_0p75_85c,8,ulvt,56.3        0.083     tt_0p75_85c,8,ulvt,75.0        0.110 

    tt_0p75_25c,8,svt,3.8         0.011     tt_0p75_25c,8,svt,7.5         0.021     tt_0p75_25c,8,svt,11.3         0.032     tt_0p75_25c,8,svt,15.0         0.042     tt_0p75_25c,8,svt,18.8         0.053     tt_0p75_25c,8,svt,37.5         0.105     tt_0p75_25c,8,svt,56.3         0.159     tt_0p75_25c,8,svt,75.0         0.213 
    tt_0p75_25c,8,lvt,3.8         0.008     tt_0p75_25c,8,lvt,7.5         0.015     tt_0p75_25c,8,lvt,11.3         0.023     tt_0p75_25c,8,lvt,15.0         0.031     tt_0p75_25c,8,lvt,18.8         0.039     tt_0p75_25c,8,lvt,37.5         0.077     tt_0p75_25c,8,lvt,56.3         0.116     tt_0p75_25c,8,lvt,75.0         0.155 
    tt_0p75_25c,8,ulvt,3.8        0.006     tt_0p75_25c,8,ulvt,7.5        0.012     tt_0p75_25c,8,ulvt,11.3        0.018     tt_0p75_25c,8,ulvt,15.0        0.024     tt_0p75_25c,8,ulvt,18.8        0.030     tt_0p75_25c,8,ulvt,37.5        0.060     tt_0p75_25c,8,ulvt,56.3        0.090     tt_0p75_25c,8,ulvt,75.0        0.120 

    ffgnp_0p825v_m40c,8,svt,3.7   0.007     ffgnp_0p825v_m40c,8,svt,7.5   0.015     ffgnp_0p825v_m40c,8,svt,11.2   0.023     ffgnp_0p825v_m40c,8,svt,15.0   0.030     ffgnp_0p825v_m40c,8,svt,18.7   0.038     ffgnp_0p825v_m40c,8,svt,37.5   0.081     ffgnp_0p825v_m40c,8,svt,56.2   0.129     ffgnp_0p825v_m40c,8,svt,75.0   0.183 
    ffgnp_0p825v_m40c,8,lvt,3.7   0.005     ffgnp_0p825v_m40c,8,lvt,7.5   0.011     ffgnp_0p825v_m40c,8,lvt,11.2   0.017     ffgnp_0p825v_m40c,8,lvt,15.0   0.023     ffgnp_0p825v_m40c,8,lvt,18.7   0.029     ffgnp_0p825v_m40c,8,lvt,37.5   0.060     ffgnp_0p825v_m40c,8,lvt,56.2   0.095     ffgnp_0p825v_m40c,8,lvt,75.0   0.134 
    ffgnp_0p825v_m40c,8,ulvt,3.7  0.004     ffgnp_0p825v_m40c,8,ulvt,7.5  0.009     ffgnp_0p825v_m40c,8,ulvt,11.2  0.013     ffgnp_0p825v_m40c,8,ulvt,15.0  0.018     ffgnp_0p825v_m40c,8,ulvt,18.7  0.023     ffgnp_0p825v_m40c,8,ulvt,37.5  0.048     ffgnp_0p825v_m40c,8,ulvt,56.2  0.075     ffgnp_0p825v_m40c,8,ulvt,75.0  0.106 

    ffgnp_0p825v_0c,8,svt,3.7     0.007     ffgnp_0p825v_0c,8,svt,7.5     0.014     ffgnp_0p825v_0c,8,svt,11.2     0.022     ffgnp_0p825v_0c,8,svt,15.0     0.029     ffgnp_0p825v_0c,8,svt,18.7     0.037     ffgnp_0p825v_0c,8,svt,37.5     0.078     ffgnp_0p825v_0c,8,svt,56.2     0.124     ffgnp_0p825v_0c,8,svt,75.0     0.175 
    ffgnp_0p825v_0c,8,lvt,3.7     0.005     ffgnp_0p825v_0c,8,lvt,7.5     0.011     ffgnp_0p825v_0c,8,lvt,11.2     0.016     ffgnp_0p825v_0c,8,lvt,15.0     0.022     ffgnp_0p825v_0c,8,lvt,18.7     0.027     ffgnp_0p825v_0c,8,lvt,37.5     0.058     ffgnp_0p825v_0c,8,lvt,56.2     0.091     ffgnp_0p825v_0c,8,lvt,75.0     0.129 
    ffgnp_0p825v_0c,8,ulvt,3.7    0.004     ffgnp_0p825v_0c,8,ulvt,7.5    0.009     ffgnp_0p825v_0c,8,ulvt,11.2    0.013     ffgnp_0p825v_0c,8,ulvt,15.0    0.017     ffgnp_0p825v_0c,8,ulvt,18.7    0.022     ffgnp_0p825v_0c,8,ulvt,37.5    0.046     ffgnp_0p825v_0c,8,ulvt,56.2    0.072     ffgnp_0p825v_0c,8,ulvt,75.0    0.100 

    ffgnp_0p825v_125c,8,svt,3.7   0.006     ffgnp_0p825v_125c,8,svt,7.5   0.013     ffgnp_0p825v_125c,8,svt,11.2   0.019     ffgnp_0p825v_125c,8,svt,15.0   0.026     ffgnp_0p825v_125c,8,svt,18.7   0.032     ffgnp_0p825v_125c,8,svt,37.5   0.068     ffgnp_0p825v_125c,8,svt,56.2   0.106     ffgnp_0p825v_125c,8,svt,75.0   0.150 
    ffgnp_0p825v_125c,8,lvt,3.7   0.005     ffgnp_0p825v_125c,8,lvt,7.5   0.009     ffgnp_0p825v_125c,8,lvt,11.2   0.014     ffgnp_0p825v_125c,8,lvt,15.0   0.019     ffgnp_0p825v_125c,8,lvt,18.7   0.024     ffgnp_0p825v_125c,8,lvt,37.5   0.050     ffgnp_0p825v_125c,8,lvt,56.2   0.079     ffgnp_0p825v_125c,8,lvt,75.0   0.111 
    ffgnp_0p825v_125c,8,ulvt,3.7  0.004     ffgnp_0p825v_125c,8,ulvt,7.5  0.007     ffgnp_0p825v_125c,8,ulvt,11.2  0.011     ffgnp_0p825v_125c,8,ulvt,15.0  0.015     ffgnp_0p825v_125c,8,ulvt,18.7  0.019     ffgnp_0p825v_125c,8,ulvt,37.5  0.039     ffgnp_0p825v_125c,8,ulvt,56.2  0.062     ffgnp_0p825v_125c,8,ulvt,75.0  0.086 

    ssgnp_0p675v_m40c,11,svt,3.4  0.018     ssgnp_0p675v_m40c,11,svt,6.8  0.035     ssgnp_0p675v_m40c,11,svt,10.1  0.052     ssgnp_0p675v_m40c,11,svt,13.5  0.068     ssgnp_0p675v_m40c,11,svt,16.9  0.084     ssgnp_0p675v_m40c,11,svt,33.8  0.154     ssgnp_0p675v_m40c,11,svt,50.6  0.214     ssgnp_0p675v_m40c,11,svt,67.5  0.266 
    ssgnp_0p675v_m40c,11,lvt,3.4  0.013     ssgnp_0p675v_m40c,11,lvt,6.8  0.025     ssgnp_0p675v_m40c,11,lvt,10.1  0.036     ssgnp_0p675v_m40c,11,lvt,13.5  0.048     ssgnp_0p675v_m40c,11,lvt,16.9  0.059     ssgnp_0p675v_m40c,11,lvt,33.8  0.110     ssgnp_0p675v_m40c,11,lvt,50.6  0.155     ssgnp_0p675v_m40c,11,lvt,67.5  0.196 
    ssgnp_0p675v_m40c,11,ulvt,3.4 0.010     ssgnp_0p675v_m40c,11,ulvt,6.8 0.019     ssgnp_0p675v_m40c,11,ulvt,10.1 0.028     ssgnp_0p675v_m40c,11,ulvt,13.5 0.036     ssgnp_0p675v_m40c,11,ulvt,16.9 0.045     ssgnp_0p675v_m40c,11,ulvt,33.8 0.085     ssgnp_0p675v_m40c,11,ulvt,50.6 0.121     ssgnp_0p675v_m40c,11,ulvt,67.5 0.154

    ssgnp_0p675v_0c,11,svt,3.4    0.017     ssgnp_0p675v_0c,11,svt,6.8    0.033     ssgnp_0p675v_0c,11,svt,10.1    0.048     ssgnp_0p675v_0c,11,svt,13.5    0.063     ssgnp_0p675v_0c,11,svt,16.9    0.077     ssgnp_0p675v_0c,11,svt,33.8    0.144     ssgnp_0p675v_0c,11,svt,50.6    0.200     ssgnp_0p675v_0c,11,svt,67.5    0.250 
    ssgnp_0p675v_0c,11,lvt,3.4    0.012     ssgnp_0p675v_0c,11,lvt,6.8    0.023     ssgnp_0p675v_0c,11,lvt,10.1    0.034     ssgnp_0p675v_0c,11,lvt,13.5    0.045     ssgnp_0p675v_0c,11,lvt,16.9    0.055     ssgnp_0p675v_0c,11,lvt,33.8    0.104     ssgnp_0p675v_0c,11,lvt,50.6    0.147     ssgnp_0p675v_0c,11,lvt,67.5    0.185 
    ssgnp_0p675v_0c,11,ulvt,3.4   0.009     ssgnp_0p675v_0c,11,ulvt,6.8   0.018     ssgnp_0p675v_0c,11,ulvt,10.1   0.026     ssgnp_0p675v_0c,11,ulvt,13.5   0.034     ssgnp_0p675v_0c,11,ulvt,16.9   0.043     ssgnp_0p675v_0c,11,ulvt,33.8   0.081     ssgnp_0p675v_0c,11,ulvt,50.6   0.115     ssgnp_0p675v_0c,11,ulvt,67.5   0.146 

    ssgnp_0p675v_125c,11,svt,3.4  0.013     ssgnp_0p675v_125c,11,svt,6.8  0.026     ssgnp_0p675v_125c,11,svt,10.1  0.037     ssgnp_0p675v_125c,11,svt,13.5  0.049     ssgnp_0p675v_125c,11,svt,16.9  0.061     ssgnp_0p675v_125c,11,svt,33.8  0.115     ssgnp_0p675v_125c,11,svt,50.6  0.162     ssgnp_0p675v_125c,11,svt,67.5  0.205 
    ssgnp_0p675v_125c,11,lvt,3.4  0.009     ssgnp_0p675v_125c,11,lvt,6.8  0.019     ssgnp_0p675v_125c,11,lvt,10.1  0.028     ssgnp_0p675v_125c,11,lvt,13.5  0.036     ssgnp_0p675v_125c,11,lvt,16.9  0.045     ssgnp_0p675v_125c,11,lvt,33.8  0.086     ssgnp_0p675v_125c,11,lvt,50.6  0.122     ssgnp_0p675v_125c,11,lvt,67.5  0.155 
    ssgnp_0p675v_125c,11,ulvt,3.4 0.007     ssgnp_0p675v_125c,11,ulvt,6.8 0.014     ssgnp_0p675v_125c,11,ulvt,10.1 0.021     ssgnp_0p675v_125c,11,ulvt,13.5 0.028     ssgnp_0p675v_125c,11,ulvt,16.9 0.035     ssgnp_0p675v_125c,11,ulvt,33.8 0.067     ssgnp_0p675v_125c,11,ulvt,50.6 0.096     ssgnp_0p675v_125c,11,ulvt,67.5 0.123 

    tt_0p75_85c,11,svt,3.8        0.010     tt_0p75_85c,11,svt,7.5        0.020     tt_0p75_85c,11,svt,11.3        0.031     tt_0p75_85c,11,svt,15.0        0.041     tt_0p75_85c,11,svt,18.8        0.051     tt_0p75_85c,11,svt,37.5        0.102     tt_0p75_85c,11,svt,56.3        0.154     tt_0p75_85c,11,svt,75.0        0.206 
    tt_0p75_85c,11,lvt,3.8        0.008     tt_0p75_85c,11,lvt,7.5        0.015     tt_0p75_85c,11,lvt,11.3        0.023     tt_0p75_85c,11,lvt,15.0        0.030     tt_0p75_85c,11,lvt,18.8        0.038     tt_0p75_85c,11,lvt,37.5        0.076     tt_0p75_85c,11,lvt,56.3        0.115     tt_0p75_85c,11,lvt,75.0        0.154 
    tt_0p75_85c,11,ulvt,3.8       0.006     tt_0p75_85c,11,ulvt,7.5       0.012     tt_0p75_85c,11,ulvt,11.3       0.018     tt_0p75_85c,11,ulvt,15.0       0.024     tt_0p75_85c,11,ulvt,18.8       0.030     tt_0p75_85c,11,ulvt,37.5       0.060     tt_0p75_85c,11,ulvt,56.3       0.091     tt_0p75_85c,11,ulvt,75.0       0.121 

    tt_0p75_25c,11,svt,3.8        0.011     tt_0p75_25c,11,svt,7.5        0.022     tt_0p75_25c,11,svt,11.3        0.033     tt_0p75_25c,11,svt,15.0        0.044     tt_0p75_25c,11,svt,18.8        0.056     tt_0p75_25c,11,svt,37.5        0.111     tt_0p75_25c,11,svt,56.3        0.168     tt_0p75_25c,11,svt,75.0        0.225 
    tt_0p75_25c,11,lvt,3.8        0.008     tt_0p75_25c,11,lvt,7.5        0.016     tt_0p75_25c,11,lvt,11.3        0.025     tt_0p75_25c,11,lvt,15.0        0.033     tt_0p75_25c,11,lvt,18.8        0.041     tt_0p75_25c,11,lvt,37.5        0.083     tt_0p75_25c,11,lvt,56.3        0.125     tt_0p75_25c,11,lvt,75.0        0.167 
    tt_0p75_25c,11,ulvt,3.8       0.007     tt_0p75_25c,11,ulvt,7.5       0.013     tt_0p75_25c,11,ulvt,11.3       0.020     tt_0p75_25c,11,ulvt,15.0       0.026     tt_0p75_25c,11,ulvt,18.8       0.033     tt_0p75_25c,11,ulvt,37.5       0.065     tt_0p75_25c,11,ulvt,56.3       0.098     tt_0p75_25c,11,ulvt,75.0       0.131 

    ffgnp_0p825v_m40c,11,svt,3.7  0.008     ffgnp_0p825v_m40c,11,svt,7.5  0.016     ffgnp_0p825v_m40c,11,svt,11.2  0.024     ffgnp_0p825v_m40c,11,svt,15.0  0.032     ffgnp_0p825v_m40c,11,svt,18.7  0.041     ffgnp_0p825v_m40c,11,svt,37.5  0.086     ffgnp_0p825v_m40c,11,svt,56.2  0.137     ffgnp_0p825v_m40c,11,svt,75.0  0.196 
    ffgnp_0p825v_m40c,11,lvt,3.7  0.006     ffgnp_0p825v_m40c,11,lvt,7.5  0.012     ffgnp_0p825v_m40c,11,lvt,11.2  0.018     ffgnp_0p825v_m40c,11,lvt,15.0  0.025     ffgnp_0p825v_m40c,11,lvt,18.7  0.031     ffgnp_0p825v_m40c,11,lvt,37.5  0.066     ffgnp_0p825v_m40c,11,lvt,56.2  0.104     ffgnp_0p825v_m40c,11,lvt,75.0  0.146 
    ffgnp_0p825v_m40c,11,ulvt,3.7 0.005     ffgnp_0p825v_m40c,11,ulvt,7.5 0.010     ffgnp_0p825v_m40c,11,ulvt,11.2 0.015     ffgnp_0p825v_m40c,11,ulvt,15.0 0.020     ffgnp_0p825v_m40c,11,ulvt,18.7 0.025     ffgnp_0p825v_m40c,11,ulvt,37.5 0.053     ffgnp_0p825v_m40c,11,ulvt,56.2 0.083     ffgnp_0p825v_m40c,11,ulvt,75.0 0.116 

    ffgnp_0p825v_0c,11,svt,3.7    0.007     ffgnp_0p825v_0c,11,svt,7.5    0.015     ffgnp_0p825v_0c,11,svt,11.2    0.023     ffgnp_0p825v_0c,11,svt,15.0    0.031     ffgnp_0p825v_0c,11,svt,18.7    0.039     ffgnp_0p825v_0c,11,svt,37.5    0.083     ffgnp_0p825v_0c,11,svt,56.2    0.132     ffgnp_0p825v_0c,11,svt,75.0    0.187 
    ffgnp_0p825v_0c,11,lvt,3.7    0.006     ffgnp_0p825v_0c,11,lvt,7.5    0.012     ffgnp_0p825v_0c,11,lvt,11.2    0.018     ffgnp_0p825v_0c,11,lvt,15.0    0.024     ffgnp_0p825v_0c,11,lvt,18.7    0.030     ffgnp_0p825v_0c,11,lvt,37.5    0.063     ffgnp_0p825v_0c,11,lvt,56.2    0.099     ffgnp_0p825v_0c,11,lvt,75.0    0.140 
    ffgnp_0p825v_0c,11,ulvt,3.7   0.005     ffgnp_0p825v_0c,11,ulvt,7.5   0.009     ffgnp_0p825v_0c,11,ulvt,11.2   0.014     ffgnp_0p825v_0c,11,ulvt,15.0   0.019     ffgnp_0p825v_0c,11,ulvt,18.7   0.024     ffgnp_0p825v_0c,11,ulvt,37.5   0.050     ffgnp_0p825v_0c,11,ulvt,56.2   0.079     ffgnp_0p825v_0c,11,ulvt,75.0   0.111 

    ffgnp_0p825v_125c,11,svt,3.7  0.006     ffgnp_0p825v_125c,11,svt,7.5  0.013     ffgnp_0p825v_125c,11,svt,11.2  0.020     ffgnp_0p825v_125c,11,svt,15.0  0.027     ffgnp_0p825v_125c,11,svt,18.7  0.034     ffgnp_0p825v_125c,11,svt,37.5  0.071     ffgnp_0p825v_125c,11,svt,56.2  0.113     ffgnp_0p825v_125c,11,svt,75.0  0.159 
    ffgnp_0p825v_125c,11,lvt,3.7  0.005     ffgnp_0p825v_125c,11,lvt,7.5  0.010     ffgnp_0p825v_125c,11,lvt,11.2  0.015     ffgnp_0p825v_125c,11,lvt,15.0  0.021     ffgnp_0p825v_125c,11,lvt,18.7  0.026     ffgnp_0p825v_125c,11,lvt,37.5  0.055     ffgnp_0p825v_125c,11,lvt,56.2  0.086     ffgnp_0p825v_125c,11,lvt,75.0  0.120 
    ffgnp_0p825v_125c,11,ulvt,3.7 0.004     ffgnp_0p825v_125c,11,ulvt,7.5 0.008     ffgnp_0p825v_125c,11,ulvt,11.2 0.012     ffgnp_0p825v_125c,11,ulvt,15.0 0.017     ffgnp_0p825v_125c,11,ulvt,18.7 0.021     ffgnp_0p825v_125c,11,ulvt,37.5 0.044     ffgnp_0p825v_125c,11,ulvt,56.2 0.068     ffgnp_0p825v_125c,11,ulvt,75.0 0.095 
  }

  array set user_temperature_derate {
    ssgnp_0p675v_m40c,8,svt,10   0.006
    ssgnp_0p675v_m40c,8,lvt,10   0.002
    ssgnp_0p675v_m40c,8,ulvt,10  0.000

    ssgnp_0p675v_0c,8,svt,10     0.006
    ssgnp_0p675v_0c,8,lvt,10     0.002
    ssgnp_0p675v_0c,8,ulvt,10    0.000

    ssgnp_0p675v_125c,8,svt,10   0.004
    ssgnp_0p675v_125c,8,lvt,10   0.000
    ssgnp_0p675v_125c,8,ulvt,10  0.004

    tt_0p75_85c,8,svt,10         0.001
    tt_0p75_85c,8,lvt,10         0.003
    tt_0p75_85c,8,ulvt,10        0.005

    tt_0p75_25c,8,svt,10         0.000
    tt_0p75_25c,8,lvt,10         0.002
    tt_0p75_25c,8,ulvt,10        0.004

    ffgnp_0p825v_m40c,8,svt,10   0.003
    ffgnp_0p825v_m40c,8,lvt,10   0.004
    ffgnp_0p825v_m40c,8,ulvt,10  0.005

    ffgnp_0p825v_0c,8,svt,10     0.003
    ffgnp_0p825v_0c,8,lvt,10     0.004
    ffgnp_0p825v_0c,8,ulvt,10    0.006

    ffgnp_0p825v_125c,8,svt,10   0.005
    ffgnp_0p825v_125c,8,lvt,10   0.006
    ffgnp_0p825v_125c,8,ulvt,10  0.009

    ssgnp_0p675v_m40c,11,svt,10  0.006
    ssgnp_0p675v_m40c,11,lvt,10  0.002
    ssgnp_0p675v_m40c,11,ulvt,10 0.001

    ssgnp_0p675v_0c,11,svt,10    0.006
    ssgnp_0p675v_0c,11,lvt,10    0.002
    ssgnp_0p675v_0c,11,ulvt,10   0.001

    ssgnp_0p675v_125c,11,svt,10  0.004
    ssgnp_0p675v_125c,11,lvt,10  0.000
    ssgnp_0p675v_125c,11,ulvt,10 0.003

    tt_0p75_85c,11,svt,10        0.001
    tt_0p75_85c,11,lvt,10        0.003
    tt_0p75_85c,11,ulvt,10       0.005

    tt_0p75_25c,11,svt,10        0.000
    tt_0p75_25c,11,lvt,10        0.002
    tt_0p75_25c,11,ulvt,10       0.004

    ffgnp_0p825v_m40c,11,svt,10  0.004
    ffgnp_0p825v_m40c,11,lvt,10  0.005
    ffgnp_0p825v_m40c,11,ulvt,10 0.006

    ffgnp_0p825v_0c,11,svt,10    0.004
    ffgnp_0p825v_0c,11,lvt,10    0.005
    ffgnp_0p825v_0c,11,ulvt,10   0.006

    ffgnp_0p825v_125c,11,svt,10  0.005
    ffgnp_0p825v_125c,11,lvt,10  0.007
    ffgnp_0p825v_125c,11,ulvt,10 0.008
  }

  # Set delta volatge
  set delta_v_derate_ss $delta_voltage_derate_ss
  set delta_v_derate_tt $delta_voltage_derate_tt
  set delta_v_derate_ff $delta_voltage_derate_ff

  # Set delta temparature (specify x times 10 degres). For example, 2 means 2*10 degres = 20 degres
  set delta_t_derate    [expr $delta_temperature_derate / 10 ]

  ##################################################
  #
  # WARNING : Use only SS delay corners for setup
  #           For hold, specific hold delay corner should be defined for all SS delay corners (derating applied differently).
  #
  ##################################################

  ##################################################
  # 1. all ss delay corners @ 125 degrees
  ##################################################
  # ssgnp_0p675v_125c

  if {[regexp ss_0p675v_125c $delayCorner]} {
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,8,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,8,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,8,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,11,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,11,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_125c,11,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_125c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

  ##################################################
  # 2. all ss delay corners @ 0 degrees
  ##################################################
  # ssgnp_0p675v_0c

  if {[regexp ss_0p675v_0c $delayCorner]} {
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,8,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,8,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,8,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,11,svt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,11,lvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(ssgnp_0p675v_0c,11,ulvt,$delta_v_derate_ss) + [expr $delta_t_derate * $user_temperature_derate(ssgnp_0p675v_0c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

  ##################################################
  # 3. all tt delay corners @ 25 degrees
  ##################################################
  # tt_0p75_25c

  if {[regexp tt_0p75v_25c $delayCorner]} {
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,8,svt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,8,lvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,8,ulvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,11,svt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,11,lvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_25c,11,ulvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_25c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

  ##################################################
  # 4. all tt delay corners @ 85 degrees
  ##################################################
  # tt_0p75_85c

  if {[regexp tt_0p75v_85c $delayCorner]} {
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,8,svt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,8,lvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,8,ulvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,11,svt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,11,lvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -early [expr 1 - [expr $user_voltage_derate(tt_0p75_85c,11,ulvt,$delta_v_derate_tt) + [expr $delta_t_derate * $user_temperature_derate(tt_0p75_85c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

  ##################################################
  # 5. all ff delay corners @ 125 degrees
  ##################################################
  # ffgnp_0p825v_125c

  if {[regexp ff_0p825v_125c $delayCorner]} {
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,8,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,8,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,8,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,11,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,11,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_125c,11,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_125c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

  ##################################################
  # 6. all ff delay corners @ 0 degrees
  ##################################################
  # ffgnp_0p825v_0c

  if {[regexp ff_0p825v_0c $delayCorner]} {
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,8,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,8,svt,10)]]]   [get_lib_cells *H8P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,8,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,8,lvt,10)]]]   [get_lib_cells *H8P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,8,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,8,ulvt,10)]]] [get_lib_cells *H8P57PDULVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,11,svt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,11,svt,10)]]]   [get_lib_cells *H11P57PDSVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,11,lvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,11,lvt,10)]]]   [get_lib_cells *H11P57PDLVT*] -delay_corner $delayCorner
    set_timing_derate -cell_delay -late [expr 1 + [expr $user_voltage_derate(ffgnp_0p825v_0c,11,ulvt,$delta_v_derate_ff) + [expr $delta_t_derate * $user_temperature_derate(ffgnp_0p825v_0c,11,ulvt,10)]]] [get_lib_cells *H11P57PDULVT*] -delay_corner $delayCorner
  }

}

# Add extra derates
proc add_extra_derates {delayCorner} {
  global extra_setup_clock_derate_early extra_setup_clock_derate_late extra_setup_data_derate_late extra_hold_clock_derate_early extra_hold_data_derate_early extra_hold_clock_derate_late
  if {[ regexp {ss[_a-z0-9]+_s} $delayCorner]} {
     set_timing_derate -add -cell_delay -clock -early -delay_corner $delayCorner $extra_setup_clock_derate_early
     set_timing_derate -add -cell_delay -clock -late -delay_corner $delayCorner $extra_setup_clock_derate_late
     set_timing_derate -add -cell_delay -data -late -delay_corner $delayCorner $extra_setup_data_derate_late
  }
  if {[regexp {^ff} $delayCorner] || [regexp {^tt} $delayCorner] || [ regexp {ss[_a-z0-9]+_h} $delayCorner]} {
     set_timing_derate -add -cell_delay -clock -early -delay_corner $delayCorner $extra_hold_clock_derate_early
     set_timing_derate -add -cell_delay -data -early -delay_corner $delayCorner $extra_hold_data_derate_early
     set_timing_derate -add -cell_delay -clock -late -delay_corner $delayCorner $extra_hold_clock_derate_late
  }
}

# Define memories extra derating
proc add_memories_extra_derate {delayCorner} {
  global extra_memory_max_derate extra_memory_min_derate
  foreach _mem [concat [get_db base_cells .base_name sa*] [get_db base_cells .base_name as*]] {
     if {[ regexp {ss[_a-z0-9]+_s} $delayCorner]} {
        set_timing_derate -add -cell_delay -late -delay_corner $delayCorner $extra_memory_max_derate $_mem
     }
     if {[regexp {^ff} $delayCorner] || [regexp {^tt} $delayCorner] || [ regexp {ss[_a-z0-9]+_h} $delayCorner]} {
        set_timing_derate -add -cell_delay -early -delay_corner $delayCorner $extra_memory_min_derate $_mem
     }
  }
} 

# Define IPs extra derating
proc add_ips_extra_derate {delayCorner} {
  global extra_ip_max_derate extra_ip_min_derate
  foreach _ip [get_db base_cells -if {.class == block}] {
     if {![regexp "^sa" [get_db $_ip .base_name]] && ![regexp "^as" [get_db $_ip .base_name]]} {
        if {[ regexp {ss[_a-z0-9]+_s} $delayCorner]} {
          set_timing_derate -add -cell_delay -late -delay_corner $delayCorner $extra_ip_max_derate $_ip
        }
        if {[regexp {^ff} $delayCorner] || [regexp {^tt} $delayCorner] || [ regexp {ss[_a-z0-9]+_h} $delayCorner]} {
           set_timing_derate -add -cell_delay -early -delay_corner $delayCorner $extra_ip_min_derate $_ip
        }
     }
  }
} 

# Define memories extra margins
proc add_memories_extra_margin {} {
  global extra_memory_setup_margin extra_memory_hold_margin
  set memId 0
  foreach _mem [concat [get_db base_cells .base_name sa*] [get_db base_cells .base_name as*]] {
     foreach _inst_mem [get_db insts -if {.base_cell.name == $_mem}] {
        if {[get_db program_short_name] == "genus"} {
	   foreach _setup_view [get_db analysis_views -if {.is_setup == true}] {
	      set_path_adjust -delay [expr 1000 * -$extra_memory_setup_margin] -to $_inst_mem -view [get_db $_setup_view .name]
           }
        } else {
           set_path_adjust_group -name toMem${memId} -to $_inst_mem
	   foreach _setup_view [get_db analysis_views -if {.is_setup == true}] {
	      set_path_adjust -$extra_memory_setup_margin -path_adjust_group toMem${memId} -view [get_db $_setup_view .name]
           }
	   foreach _hold_view [get_db analysis_views -if {.is_hold == true}] {
	      set_path_adjust -$extra_memory_hold_margin -path_adjust_group toMem${memId} -view [get_db $_hold_view .name]
           }
	}
	incr memId
     }
  }
}

# Define IPs extra margins
proc add_ips_extra_margin {} {
  global extra_ip_setup_margin extra_ip_hold_margin
  set IPId 0
  foreach _ip [get_db base_cells -if {.class == block}] {
     if {![regexp "^sa" [get_db $_ip .base_name]] && ![regexp "^as" [get_db $_ip .base_name]]} {
        foreach _inst_ip [get_db insts -if {.base_cell.name == $_ip}] {
           if {[get_db program_short_name] == "genus"} {
	      foreach _setup_view [get_db analysis_views -if {.is_setup == true}] {
	         set_path_adjust -delay [expr 1000 * -$extra_ip_setup_margin] -to $_inst_ip -view [get_db $_setup_view .name]
              }
           } else {
              set_path_adjust_group -name toIP${IPId} -to $_inst_ip
	      foreach _setup_view [get_db analysis_views -if {.is_setup == true}] {
	         set_path_adjust -$extra_ip_setup_margin -path_adjust_group toIP${IPId} -view [get_db $_setup_view .name]
              }
	      foreach _hold_view [get_db analysis_views -if {.is_hold == true}] {
	         set_path_adjust -$extra_ip_hold_margin -path_adjust_group toIP${IPId} -view [get_db $_hold_view .name]
              }
	   }
	incr IPId
        }
     }
  }
}

# Apply all deratings and extra margins
if {[get_db program_short_name] != "genus"} {
  reset_timing_derate
}
foreach delayCorner [get_db delay_corners .name] {
  add_vt_derates $delayCorner
  add_extra_derates $delayCorner
  add_memories_extra_derate $delayCorner
  add_ips_extra_derate $delayCorner
}
add_memories_extra_margin
add_ips_extra_margin


##### pasted: -rwxrwxrwx 1 jeromem ns 873 Aug 28 18:30 /space/users/moriya/nextflow/project_flow/NXT007/controls/vt_groups.paste
# Define VT groups
proc vt_groups_config {} {
  # clear previous vt group naming
  set_db [get_db base_cells] .voltage_threshold_group ""
  # define custom vt group naming for metrics
  set_db [get_db base_cells -if {.name == *BWP240H8P57PDSVT && !.is_black_box}] .voltage_threshold_group SVT8
  set_db [get_db base_cells -if {.name == *BWP240H11P57PDSVT && !.is_black_box}] .voltage_threshold_group SVT11
  set_db [get_db base_cells -if {.name == *BWP240H8P57PDLVT && !.is_black_box}] .voltage_threshold_group LVT8
  set_db [get_db base_cells -if {.name == *BWP240H11P57PDLVT && !.is_black_box}] .voltage_threshold_group LVT11
  set_db [get_db base_cells -if {.name == *BWP240H8P57PDULVT && !.is_black_box}] .voltage_threshold_group ULVT8
  set_db [get_db base_cells -if {.name == *BWP240H11P57PDULVT && !.is_black_box}] .voltage_threshold_group ULVT11
}
vt_groups_config


# update_io_latency -verbose

set_interactive_constraint_modes [all_constraint_modes -active]

set_dont_use [get_lib_cells DEL*] false


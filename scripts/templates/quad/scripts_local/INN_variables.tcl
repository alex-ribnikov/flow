set_db extract_rc_lef_tech_file_map ./scripts/flow/QRC.layermap.ccl
history keep 10000

if {[info exists STAGE]} {set_db auto_file_dir work/${STAGE}}


# Process
###############################################
if { [info exists ::env(PROJECT)] } {
	set proj $::env(PROJECT)
} else {
    set proj [lindex [split [pwd] "/"] end-3]
}

if { ![is_attribute -obj root be_project] } {
    define_attribute be_project -obj_type root -category be_user_attributes -data_type string -default $proj
} else {
    set_db be_project $proj
}

if { [regexp "snpsn5|tsmcn5|inext|brcm5" $proj] } {
	puts "-I- process is 5nm"
	set_db design_process_node 5
	set_db route_design_process_node N5
	
	set_db timing_report_enable_verbose_ssta_mode true 

} elseif { [regexp "snpsn7|tsmcn7|nxt007|nxt008" $proj] } {
	puts "-I- process is 7nm"
	set_db design_process_node 7
	set_db route_design_process_node N7
} else {
    puts "-E- INN_variables: No valid project found!"
    exit -1
}

# Flow
###############################################
set_db design_flow_effort standard ;					# (default : standard)
if {[info exists ECF] && $ECF == "true"} {
	set_db design_early_clock_flow true ;					# (default : false)
} else {
	set_db design_early_clock_flow false ;					# (default : false)
}
set_db design_power_effort low ;					# (default : none)
set_db opt_via_pillar_effort low ;					# (default : low) - Not supported yet in CUI for Innovus 18.1

set_db design_pessimistic_mode true

# Floorplan
###############################################
set_db floorplan_default_tech_site $DEFAULT_SITE ;                               # (default : "")
set_db floorplan_row_site_width odd ;					# (default : any)
set_db floorplan_row_site_height even ;					# (default : any)
set_db floorplan_check_types odd_even_site_row ;					# (default : basic)
set_db floorplan_snap_block_grid  finfet_placement;			# (default : manufacturing)

if {[regexp {20.1} [get_db program_version]]} {
	set_floorplan_mode -floorplan_global_odd_even_sites_height 2
	set_floorplan_mode -floorplan_global_odd_even_sites_row 2
}

set_db floorplan_snap_die_grid   user_define
set_db floorplan_snap_core_grid  user_define
set_db floorplan_snap_io_grid    user_define
set_db floorplan_snap_block_grid user_define



#foreach MACRO [lsort -u [get_property  [all_macros ] ref_name]] {
#   foreach LLL [lsort -u [get_db [get_db base_cells $MACRO] .obs_layer_shapes.layer.name ]] {
#	create_cell_obs -cell $MACRO -spacing 0 -rects [get_db [get_db base_cells $MACRO ] .bbox] -layer $LLL
#   }
#}
# Verify DRC
###############################################
set_db check_drc_limit 10000 ;						# (default : 1000)
#set_db check_drc_inside_via_def false ;					# (default : false)

# DRV
###############################################
set_db opt_fix_fanout_load true ;					# (default : false)
#set_db opt_drv_margin 0.05 ;						# (default : 0.0)
set_db check_drc_disable_rules {out_of_die}

# Placement
###############################################
if {[info exists SCAN] && $SCAN == "false"} {
	puts "-I- running without scan"
	set_db place_global_ignore_scan true
	set_db message:IMPSP-9099 .severity  Warning
	if { [regexp "brcm" $proj] } {
	   foreach pin [get_db insts .pins.name */ti] {
		set inst_name [get_db pin:$pin .inst.name]
		set net_name  [get_db pin:$pin .net.name]
		if {$net_name != ""} {
			disconnect_pin -inst $inst_name -pin ti -net $net_name    
		}
	   }
	} else {
	   foreach pin [get_db insts .pins.name */SI] {
		set inst_name [get_db pin:$pin .inst.name]
		set net_name  [get_db pin:$pin .net.name]
		if {$net_name != ""} {
			disconnect_pin -inst $inst_name -pin SI -net $net_name    
		}
	   }
	}
}

set_db place_global_reorder_scan true ; 				# (default : true)
set_db place_global_clock_gate_aware true ;				# (default : true)
#set_db place_global_clock_power_driven_effort standard ;		# (default : standard)
#set_db place_global_activity_power_driven true ;			# (default : false)
#set_db place_hard_fence true ;						# (default : false)
set_db place_detail_use_no_diffusion_one_site_filler true ;		# (default : false)
set_db place_detail_swap_eeq_cells true			;
set_db place_global_module_aware_spare true ;		                # (default : false)
set_db place_global_ignore_spare true ;		                        # (default : false)
set_db place_detail_no_filler_without_implant true 
eval_legacy {setPlaceMode -place_detail_check_implant_across_rows_strict six}
set_db place_global_max_density 0.8		;			# (default : -1)

# Endcap cells
#eval_legacy {  setEndCapMode \
#    -min_vertical_channel_width 48 \
#    -min_jog_width 10 \
#    -min_horizontal_channel_width 10 \
#    -min_jog_height 3 \
#}

set_db add_endcaps_avoid_two_sites_cell_abut true 
set_db add_endcaps_boundary_tap 	   false 
set_db add_endcaps_prefix ENDCAP_
foreach ENDCAP_ [array name ENDCAPS] {
	set cmd "set_db add_endcaps_[string tolower $ENDCAP_] {$ENDCAPS($ENDCAP_)}"
	echo $cmd
	eval $cmd
}

set_db add_endcaps_use_even_odd_sites	   none

# cell_edge_type
###############################################
if {[file exists scripts/flow/cell_edge_type.${::env(PROJECT)}.tcl]} {
	puts "-I- sourcing cell_edge_type.${::env(PROJECT)}.tcl"
	source -e -v scripts/flow/cell_edge_type.${::env(PROJECT)}.tcl
}

# Tie-cells
###############################################
set_db add_tieoffs_cells "$TIEHCELL $TIELCELL" ;		# ""
set_db add_tieoffs_max_fanout 5 ;                                       # (default : 0)
set_db add_tieoffs_max_distance 20 ;                                    # (default : 0.0)

# Optimization
###############################################
#set_db opt_max_length 150 ;						# (default : -1)
set_db opt_all_end_points true ;					# (default : false)
set_db opt_power_effort low ;						# (default : none)
set_db opt_enable_data_to_data_checks true ;				# (default : false)
set_limited_access_feature FlipFlopMergeAndSplit 1
set_db opt_multi_bit_flop_opt true ;					# (default : false)
#set_db opt_multi_bit_flop_ignore_sdc false ; 				# (default : true)

eval_legacy "setOptMode -flopMergeDebug 1" ;				# (default : 0)
set_db opt_post_route_fix_glitch false ;					# (default : true)
set_db opt_post_route_fix_si_transitions true ;				# (default : false)
set_db opt_time_design_compress_reports false ;				# (default : true)
set_db opt_time_design_num_paths 10000 ;				# (default : 50)
set_db opt_time_design_expanded_view true ;				# (default : false)
set_db opt_time_design_report_net true ;				# (default : true)
set_db opt_preserve_user_route_type_constraints true ;			# (default : false)
set_db opt_spatial_power_driven true ;				        # (default : false)
#set_db opt_setup_target_slack  0.0 ;				        # (default : 0.0
#set_db opt_hold_target_slack  0.0 ;				        # (default : 0.0)
set_db opt_useful_skew_no_boundary true ;				# (default : false)
set_db opt_post_route_report_si_transitions true ;			# (default : false)

# CCOpt
###############################################
if {[info exists USEFUL_SKEW] && $USEFUL_SKEW == "true"} {
	set_db opt_useful_skew true
} else {
	set_db opt_useful_skew false
	
}
set_db ccopt_worst_chain_report_timing true ;				# (default : false)
set_db opt_useful_skew_max_allowed_delay 0.150 ;
#set_db opt_useful_skew_cells {} ;					# (default : {})
#set_db cts_adjacent_rows_legal false ;					# (default : false)

if {[info exists STAGE ] && ($STAGE == "cts" || $STAGE == "route" || ([info exists USEFUL_SKEW] && $USEFUL_SKEW == "true"))} {
	set_db reorder_scan_clock_aware true
}
set_db reorder_scan_skip_mode skip_buffer

if {![info exists STAGE ] || $STAGE != "floorplan"} {
    set_db cts_cell_density 0.2 ;						# (default : 0.75)
    set_db cts_buffer_cells $CTS_BUFFER_CELLS
    set_db cts_inverter_cells      $CTS_INVERTER_CELLS_TRUNK
    set_db cts_inverter_cells_top  $CTS_INVERTER_CELLS_TOP
    set_db cts_inverter_cells_leaf $CTS_INVERTER_CELLS_LEAF
    set_db cts_logic_cells $CTS_LOGIC_CELLS
    set_db cts_clock_gating_cells $CTS_CLOCK_GATING_CELLS
    set_db cts_use_inverters true ;					       # (default : auto)
    set_db ccopt_merge_clock_gates true ;				       # (default : true)
    set_db ccopt_merge_clock_logic true ;				       # (default : true)
    set_db cts_merge_clock_gates true ;				       # (default : true)
    set_db cts_merge_clock_logic true ;				       # (default : true)
    set_db cts_clone_clock_gates true ;				       # (default : false)
    set_db cts_clone_clock_logic true ;				       # (default : false)
    set_db cts_max_fanout 30 ;					       # (default : 100)
    set_db cts_top_fanout_threshold 100 ;  			       # (default : unset)
    set_db cts_target_max_transition_time 0.050 ;			       # (default : default)
    set_db cts_target_max_transition_time_leaf 0.040 ;		       # (default : default)
    set_db cts_route_type_auto_trim false
    set_db cts_max_source_to_sink_net_length_leaf 30 ;             # (default : default)

    # A global insertion delay target
    set_db skew_groups .cts_skew_group_target_insertion_delay 0.250

    ## Layer Adherence
    # eval_legacy "set_ccopt_property routing_preferred_layer_effort high"

    eval_legacy "set_ccopt_property write_routing_correlation_report_to_log true"
    eval_legacy "set_ccopt_property enable_routing_correlation_report true"
}



if {[get_db route_rules  2w_2s] == ""} {
  if {$MAX_ROUTING_LAYER > 7} {
	set cmd "create_route_rule -name 2w_2s -spacing_multiplier {M5:M[expr $MAX_ROUTING_LAYER -1] 2} -width_multiplier {M5:M[expr $MAX_ROUTING_LAYER-1]  2} -min_cut {VIA5:VIA[expr $MAX_ROUTING_LAYER -2] 2}"
	eval $cmd
  }
}

if {[get_db route_types .name clockRouteTop] == ""} {
  if { [regexp "brcm" $proj] || [regexp "inext" $proj] } {
     create_route_type -name clockRouteTop -top_preferred_layer $MAX_ROUTING_LAYER -bottom_preferred_layer [expr $MAX_ROUTING_LAYER -1] -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076_SHLD -shield_net VSS
  } else {
     create_route_type -name clockRouteTop -top_preferred_layer $MAX_ROUTING_LAYER -bottom_preferred_layer [expr $MAX_ROUTING_LAYER -1] -preferred_routing_layer_effort high -route_rule 2w_2s -shield_net VSS
  }
}

if {[get_db route_types .name clockRouteTrunk] == ""} {
  if { [regexp "brcm" $proj] || [regexp "inext" $proj] } {
     create_route_type -name clockRouteTrunk -top_preferred_layer $MAX_ROUTING_LAYER -bottom_preferred_layer 7 -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076_SHLD -shield_net VSS
  } else {
     create_route_type -name clockRouteTrunk -top_preferred_layer $MAX_ROUTING_LAYER -bottom_preferred_layer 7 -preferred_routing_layer_effort high -route_rule 2w_2s -shield_net VSS
  }
}

if {[get_db route_types .name clockRouteLeaf] == ""} {
   if { [regexp "brcm" $proj] || [regexp "inext" $proj] } {
     create_route_type -name clockRouteLeaf -top_preferred_layer [expr min($MAX_ROUTING_LAYER,10)] -bottom_preferred_layer 2 -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076
   } else {
     create_route_type -name clockRouteLeaf -top_preferred_layer [expr min($MAX_ROUTING_LAYER,10)] -bottom_preferred_layer 2 -preferred_routing_layer_effort high
   }
}

 
     
if {![info exists STAGE ] || $STAGE != "floorplan"} {
    set_db cts_route_type_top   clockRouteTop
    set_db cts_route_type_trunk clockRouteTrunk
    set_db cts_route_type_leaf  clockRouteLeaf
    #############################################################################################################################################
    #   need to define those fix values in setup.tcl file
    #############################################################################################################################################
    if {[info exists CTS_CELLS_HALO] && $CTS_CELLS_HALO != ""} {
	    echo > cts_cell_halo_x
	    echo > cts_cell_halo_y
	    foreach _CTS_CELL $CTS_CELLS_HALO {
		    set _WIDTH [lindex [get_db [get_db base_cells $_CTS_CELL] .bbox] 0 2]
		    set _HEIGHT [lindex [get_db [get_db base_cells $_CTS_CELL] .bbox] 0 3]
		    echo "_WIDTH $_WIDTH" >> cts_cell_halo_x
		    echo "_HEIGHT $_HEIGHT" >> cts_cell_halo_y
		    if {$_WIDTH < 1.15} {
			    set _WIDTH_MARGIN 1.71
		    } else {
			    set _WIDTH_MARGIN 3.42
		    }
		    if {$_HEIGHT < 0.48} {
			    set _HEIGHT_MARGIN 0.98
		    } else {
			    set _HEIGHT_MARGIN 1.96
		    }
		    set_db [get_db base_cells $_CTS_CELL] .cts_cell_halo_x $_WIDTH_MARGIN
		    set_db [get_db base_cells $_CTS_CELL] .cts_cell_halo_y $_HEIGHT_MARGIN
		    echo "set_db [get_db base_cells $_CTS_CELL] .cts_cell_halo_x $_WIDTH_MARGIN" >> cts_cell_halo_x
		    echo "set_db [get_db base_cells $_CTS_CELL] .cts_cell_halo_y $_HEIGHT_MARGIN" >> cts_cell_halo_y

	    }
    }

} ; # if {![info exists STAGE ] || $STAGE != "floorplan"} {

# Hold fixing
###############################################
set_db opt_fix_hold_verbose true ;					# (default : false)
set_db opt_fix_hold_slack_threshold -1.0 ;				# (default : -1000)
set_db opt_fix_hold_ignore_path_groups {in2reg reg2out in2out} ;	# (default : "")
#set_db opt_signoff_hold_target_slack -0.010 ;				# (default : 0)

#set_db opt_fix_hold_allow_setup_tns_degradation false ;	                # (default : true)

# Delay calculation and STA
###############################################
#set_db timing_report_fields {instance cell arc delay arrival transition load fanout incr_delay user_derate socv_derate instance_location}
set_db timing_report_fields {timing_point cell edge annotation fanout load transition total_derate delay arrival pin_location}
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
set_db timing_enable_preset_clear_arcs false ;				# (default : false)
set_db timing_disable_retime_clock_path_slew_propagation false ;	# (default : true)
set_db timing_generated_clocks_inherit_ideal_latency true ;		# (default : false)
#set_db timing_cppr_threshold_ps 3 ;					# (default : 20)
#set_db timing_analysis_aocv true ;					# (default : false)
#set_db timing_aocv_analysis_mode launch_capture ;			# (default : launch_capture)
#set_db timing_enable_aocv_slack_based true ;				# (default : false)
set_db timing_analysis_socv true ;					# (default : false)
#set_db timing_disable_inout_output_side_timing_checks true ;		# (default : true)
#set_db timing_disable_library_data_to_data_checks true ;		# (default : false)
set_db timing_case_analysis_for_sequential_propagation false ;		# (default : false)
set_db timing_use_incremental_si_transition true

# Default Analysis Views
###############################################
if { [info exists DEFAULT_SETUP_VIEW] && [llength [get_db analysis_views $DEFAULT_SETUP_VIEW]] > 0 } {
    puts "-I- Set default setup view: $DEFAULT_SETUP_VIEW"
    set_default_view -setup $DEFAULT_SETUP_VIEW    
}
if { [info exists DEFAULT_HOLD_VIEW] && [llength [get_db analysis_views $DEFAULT_HOLD_VIEW]] > 0 } {
    puts "-I- Set default hold view: $DEFAULT_HOLD_VIEW"
    set_default_view -hold $DEFAULT_HOLD_VIEW
}

# Delay Mode
###############################################
set_db delaycal_default_net_load 0.025pf ;				# (default : 0.5pf)
#set_db delaycal_equivalent_waveform_model propagation ;			# (default : none)
set_db delaycal_ewm_type simulation ;					# (default : moments)
set_db delaycal_socv_accuracy_mode low ;				# (default : low)
set_db delaycal_socv_lvf_mode moments ;				        # (default : moments)
set_db delaycal_socv_use_lvf_tables all ;				# (default : all)
set_db delaycal_enable_quiet_receivers_for_hold true ;		        # (default : false)
#set_db delaycal_advanced_node_pin_cap_settings true ;		        # (default : false)
set_db delaycal_advanced_pin_cap_mode true ;		                # (default : 0)
set_db delaycal_signoff_alignment_settings true ;		        # (default : false)
set_db timing_socv_statistical_min_max_mode mean_and_three_sigma_bounded ; # (default : mean_and_three_sigma_bounded)
set_socv_reporting_nsigma_multiplier -setup 3.0 -hold 4.5 

# SOCV RC variation
if {![info exists STAGE] || ($STAGE != "chip_finish" && $STAGE != "floorplan" )} {
  set_db timing_socv_rc_variation_mode true
  foreach _av [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]] {
	set _rc [lindex [split [regsub "_setup|_hold" $_av ""] "_"] end]
	puts "INFO: set_socv_rc_variation_factor 0.1 -view $_av -late -early"
	set_socv_rc_variation_factor $rc_corner($_rc,rc_variation) -view $_av -late -early
  }
}
set_db timing_enable_spatial_derate_mode true
# Set in INN.preproc.paste before loading libaries
#set timing_derate_spatial_distance_unit 1nm

# bounding_box only used for implementation in GBA mode
set_db timing_spatial_derate_distance_mode bounding_box

## SI Mode
set_db delaycal_enable_si true ;				        # (default : false)
set_db si_delay_separate_on_data true ;					# (default : false)
set_db si_delay_delta_annotation_mode lumpedOnNet ;			# (default : arc)
#set_db si_delay_enable_double_clocking_check false ;			# (default : false)
set_db si_glitch_enable_report true ;					# (default : false)
#set_db si_accumulated_small_aggressor_mode current ;			# (default : current)
# delta_slew report is huge
#set_db si_enable_delta_slew_report true ;				# (default : false)
set_db si_delay_enable_report true ;					# (default : false)
#set_db si_enable_drv_with_delta_slew true ;				# (default : false)
set_db timing_enable_si_cppr true ;					# (default : true)
set_db timing_cppr_transition_sense normal ;		# (default : normal)
#set_db si_glitch_receiver_peak_limit 0.15 ;				# (default : 0.15)
#set_db si_accumulated_small_aggressor_threshold 0.03 ;			# (default : 10.01, ie disabled)
#set_db si_individual_aggressor_threshold 0.01 ;			# (default : 0.015)
#set_db si_delay_delta_threshold 1e-12; 				# (default : -1)
#set_db si_accumulated_small_aggressor_factor 0.0 ;			# (default : 1)
set_db si_use_infinite_timing_window false ;				# (default : false)
set_db si_aggressor_alignment path_overlap ;			# (default : path)
set_db si_glitch_input_voltage_high_threshold 0.2
set_db si_glitch_input_voltage_low_threshold 0.2


# Signoff optimisation
###############################################
set_db opt_signoff_fix_si_slew true ;			         	# (default : false)
set_db opt_signoff_fix_hold_allow_setup_optimization true ;		# (default : false)
set_db opt_signoff_along_route_buffering true ;				# (default : false)

# Analyze clock DRV violations before setting this variable
# May degrade setup timing significantly
#set_db opt_signoff_fix_clock_drv true ;                                # (default : false)

# If design is congested and if we observe divergence during ECO route
#set_db opt_signoff_routing_congestion_aware true ;			# (default : false)

# To fix latest setup violations. Maybe not in the first iterations
#set_db opt_signoff_optimize_sequential_cells true ;			# (default : false)
#set_db opt_signoff_allow_skewing true;				        # (default : false)
#set_db opt_signoff_clock_cell_list {DCCKBD6BWP240H11P57PDULVT DCCKBD8BWP240H11P57PDULVT DCCKBD10BWP240H11P57PDULVT DCCKBD12BWP240H11P57PDULVT DCCKBD14BWP240H11P57PDULVT DCCKBD16BWP240H11P57PDULVT DCCKND6BWP240H11P57PDULVT DCCKND8BWP240H11P57PDULVT DCCKND10BWP240H11P57PDULVT DCCKND12BWP240H11P57PDULVT DCCKND14BWP240H11P57PDULVT DCCKND16BWP240H11P57PDULVT}

# Extraction
###############################################
#set_db extract_rc_relative_cap_threshold  ;				# (default : 0.03)
#set_db extract_rc_coupling_cap_threshold  ;				# (default : 3.0)
#set_db extract_rc_total_cap_threshold  ;				# (default : 5.0)
#set_db extract_rc_cap_filter_mode relative_and_coupling ;		# (default : relative_and_coupling)   
# if high, will run QRC for extraction
# New advanced modeling for iQuantus
if {[info exists EXTRACT_RC_EFFORT]} {
   set_db extract_rc_effort_level $EXTRACT_RC_EFFORT
} else {
#   set_db extract_rc_effort_level high ;					# (default : medium)    
   set_db extract_rc_effort_level medium ;					# !!! To save runtime during exploration stages !!! MUST CHANGE TO HIGH FOR "REAL" RUNS
}

# check what is peg
eval_legacy "setVar pegAddNewCCEAPIChanges 1"
eval_legacy "setVar pegEnableOptionalMode5 1"
eval_legacy "setVar pegEnableOptionalMode7 1"

if {![info exists INNOVUS_FROM_GENUS]  || $INNOVUS_FROM_GENUS == "false"} {
	if {[regexp {20.1} [get_db program_version]]} {
	  set_db extract_rc_local_cpu 4
	} else {
	  eval_legacy {setExtractRCMode -localCpu 4}
	}
}

set_db timing_extract_model_write_lvf true
set_db timing_extract_model_enable_mt true
set_db timing_extract_model_slew_propagation_mode path_based_slew
set_db timing_extract_model_consider_design_level_drv false

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
set designname [get_db designs .name]
set_db add_fillers_cells $FILLERS_CELLS_LIST
set_db add_fillers_no_single_site_gap false
set_db add_fillers_prefix FILL_${designname} 
set_db add_fillers_preserve_user_order true
set_db add_fillers_eco_mode true
#set_db add_fillers_avoid_abutment_patterns "1:1 2:1" ;		        # (default : "") 
set_db add_fillers_swap_cell $ADD_FILLERS_SWAP_CELL
	      
# Routing
###############################################
set_max_route_layer $MAX_ROUTING_LAYER
set_db route_early_global_bottom_routing_layer $MIN_ROUTING_LAYER ;			# (default : 2)
set_db route_early_global_top_routing_layer    $MAX_ROUTING_LAYER ;			# (default : 2147483647)
if {[regexp {20.1} [get_db program_version]]} {
  set_db design_bottom_routing_layer $MIN_ROUTING_LAYER ;			        # (default : "")
  set_db design_top_routing_layer $MAX_ROUTING_LAYER ;			                # (default : "")
}

set_db route_design_detail_fix_antenna true ;				# (default : true)
set_db route_design_antenna_diode_insertion true ;			# (default : false)
#set_db route_design_diode_insertion_for_clock_nets true ;		# (default : false)
set_db route_design_with_timing_driven true ;				# (default : false)
set_db route_design_with_si_driven true ;				# (default : false)
set_db route_design_with_litho_driven false ;				# (default : false)
#set_db route_design_with_trim_metal {-layer 2  \
#  -mask2 {-pitch 0.24 -core_offset 0.225 -width 0.03 }  \
#  -mask2 {-pitch 0.24 -core_offset 0.095 -width 0.03 }  \
#  -mask1 {-pitch 0.24 -core_offset 0.015 -width 0.03 }  \
#  -mask1 {-pitch 0.24 -core_offset 0.145 -width 0.03 }}
set_db route_design_concurrent_minimize_via_count_effort high ;		# (default : medium)
set_db route_design_detail_use_multi_cut_via_effort low ;		# (default : low)
set_db route_design_reserve_space_for_multi_cut true ;			# (default : false)
set_db route_design_strict_honor_route_rule true ;			# (default : false)
#set_db route_design_detail_auto_stop true ;				# (default : true)
set_db route_design_with_via_in_pin "1:1" ;				# (default : false)
set_db route_design_detail_post_route_spread_wire false ;		# (default : auto)
# Connect to M2 pins using only vias. No planar connections.
eval_legacy {setNanoRouteMode -routeWithViaOnlyForMacroCellPin "2:2"}
set_db route_design_with_via_only_for_block_cell_pin "2:2"

set_db route_design_antenna_cell_name $ANTENNA_CELL_NAME ;	# (default : "")

if {[info exists ROUTE_END_ITERATION] && $ROUTE_END_ITERATION > 0 } {
	puts "-I- stop script after route iteration $ROUTE_END_ITERATION"
	set_db route_design_detail_end_iteration $ROUTE_END_ITERATION
}
if {[info exists STAGE] && $STAGE == "route"} {
   set_db route_design_fix_clock_nets 1
}

# AC limit
###############################################
set_db check_ac_limit_method { rms avg peak }                          ; # (default : "")
set_db check_ac_limit_use_qrc_tech true                                ; # (default : true)
set_db check_ac_limit_use_db_freq true                                 ; # (default : false)
set_db check_ac_limit_force_hold_view true                             ; # (default : false)

set_db check_ac_limit_view $AC_LIMIT_SCENARIOS                ; # (default : "") 
set_db check_ac_limit_em_temperature 110                               ; # (default : -1) 
set_db check_ac_limit_delta_temperature 5.0                            ; # (default : 5.0)

# Recommended rules enhancer
###############################################
if {[info command opt_pattern]!=""} {set_opt_pattern_fixing_option -option lpaViaNamePrefix -value [get_db designs .name]_lpaVia}

# Stream
###############################################
set_db write_stream_pin_text_orientation automatic ;			# (default : false)
set_db write_stream_virtual_connection false ;				# (default : true)


#------------------------------------------------------------------------------
# via pillers
#------------------------------------------------------------------------------
if {[info exists VIA_PILLARS] && $VIA_PILLARS == "true" } {
    puts "-I- adding via pillers definition"
	source scripts/flow/via_pillars.${::env(PROJECT)}.tcl
}

#------------------------------------------------------------------------------
# set timing derate
#------------------------------------------------------------------------------
if {![info exists INNOVUS_FROM_GENUS]  || $INNOVUS_FROM_GENUS == "false"} {
    if {[info exists OCV] && $OCV && $STAGE != "floorplan" && $STAGE != "chip_finish"} {
	    puts "-I- setting OCV"
	    source -v -e ./scripts/flow/derating.${::env(PROJECT)}.tcl

        # Source additional user derates
        if { [file exists ./scripts_local/user_derates.tcl] } { 
            puts "-I- Source user_derates.tcl"
            source ./scripts_local/user_derates.tcl
        }
    } else {
        puts "-I- OCV = false. No derates applied."
    }

#------------------------------------------------------------------------------
# define voltage_threshold_group
#------------------------------------------------------------------------------
	# clear previous vt group naming
	set_db [get_db base_cells] .voltage_threshold_group ""
	foreach name [lsort [array names VT_GROUPS]] {
		puts "-I- voltage_threshold_group for $name"
		set_db [get_db base_cells -if ".name == $VT_GROUPS($name) && !.is_black_box"] .voltage_threshold_group $name
	}

#------------------------------------------------------------------------------
# timing groups 
#------------------------------------------------------------------------------
   if {![info exists STAGE ] || $STAGE != "floorplan"} {
	create_basic_path_groups -expanded
	
	set_path_group_options in2reg -effort_level high
	set_path_group_options reg2out -effort_level high
	set_path_group_options in2out -effort_level high
	set_path_group_options default -effort_level high
   }

	#------------------------------------------------------------------------------
	# set dont use for cells
	#------------------------------------------------------------------------------
	source -e -v scripts/flow/dont_use_n_ideal_network.tcl


} else {
	if {[get_db insts -if {.base_cell.class == block}] != ""} {convert_lib_clock_tree_latencies} 
	create_clock_tree_spec -out_file scripts_local/${DESIGN_NAME}_Syn_ccopt_clock_tree_spec.tcl
	source out/${DESIGN_NAME}_Syn_ccopt_clock_tree_spec.tcl

}   ; # $INNOVUS_FROM_GENUS == "false"}





if {![info exists STAGE] || ( $STAGE != "floorplan" && $STAGE != "route" && $STAGE != "chip_finish" )} {
   if {[get_db is_ilm_flattened]} {unflatten_ilm}
   commit_clock_tree_route_attributes
}



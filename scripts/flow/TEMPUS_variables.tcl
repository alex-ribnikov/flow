##### pasted: -rw-rw---- 1 jeromem ns 16528 Jan 26 13:30 /space/users/moriya/nextflow/project_flow/NXT007/controls/TEMPUS.setup.paste
# Process
###############################################
# Process
###############################################

if { [regexp "snpsn5|tsmcn5|inext|nextcore|nxt080" $PROJECT] } {
	puts "-I- process is 5nm"
	set_db design_process_node 5
	set_db route_design_process_node N5
} elseif { [regexp "snpsn7|tsmcn7|nxt007|nxt008" $PROJECT] } {
	puts "-I- process is 7nm"
	set_db design_process_node 7
	set_db route_design_process_node N7
} else {
    puts "-E- INN_variables: No valid project found!"
    return -1
}


# Delay calculation and STA
###############################################
#set_db timing_report_fields {instance cell arc delay arrival transition load fanout incr_delay user_derate socv_derate instance_location}
set_db timing_report_fields {timing_point cell edge annotation fanout load transition total_derate delay arrival instance_location}

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
set_db timing_cppr_threshold_ps 1 ;					# (default : 20)
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
set_db delaycal_socv_accuracy_mode ultra ;				# (default : low)
set_db delaycal_socv_lvf_mode moments ;				        # (default : moments)
set_db delaycal_socv_use_lvf_tables all ;				# (default : all)
set_db delaycal_enable_quiet_receivers_for_hold true ;		        # (default : false)
set_db delaycal_advanced_node_pin_cap_settings true ;		        # (default : false)
set_db delaycal_advanced_pin_cap_mode 2 ;		                # (default : 0)
set_db delaycal_socv_machine_learning_level 1 ;		                # (default : 0)
set_socv_reporting_nsigma_multiplier -setup 3.0 -hold 3.0 
set_db timing_socv_statistical_min_max_mode mean_and_three_sigma_bounded ; # (default : mean_and_three_sigma_bounded)
set_db timing_socv_view_based_nsigma_multiplier_mode true  ;		# (default : true)
# SOCV RC variation
if {![info exists STAGE] || $STAGE != "chip_finish" } {
  set_db timing_socv_rc_variation_mode true
  foreach _av [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]] {
	set _rc [lindex [split [regsub "_setup|_hold" $_av ""] "_"] end]
	puts "INFO: set_socv_rc_variation_factor 0.1 -view $_av -late -early"
	set_socv_rc_variation_factor $rc_corner($_rc,rc_variation) -view $_av -late -early
  }
}
set_db timing_enable_spatial_derate_mode true
# Set in TEMPUS.preproc.paste before loading libaries
#set timing_derate_spatial_distance_unit 1nm

# chip_size should be used and not bouding_box
# The spatial_derate_distance_mode is used only for GBA analysis.
# For PBA, we are anyways always in bounding_box mode.
# But to calculate the violated paths in GBA (which will then be analyzed in PBA),
# R&D recommends to perform spatial analysis in chip_size mode to be a bit more pessimitic
# and to avoid to get positive paths in GBA (not analyzed then in PBA whereas they will negative in PBA).
# Since you need a chip_size then, I use the square root of the area.
# To reduce a bit the pessimistic in Tempus, the value is reduced by the fact
# that the area is calculated only by the area specified in Liberty files (no DEF available), which means
# that the area is the real stdcells/macros/pads area. It reduces the area by density value.
set_db timing_spatial_derate_distance_mode chip_size
if {[info command distribute_partition] == ""} {
	set_db timing_spatial_derate_chip_size [expr int(sqrt([get_db designs .area]))]
}
## SI Mode

if {[info exists XTALK_SI] && $XTALK_SI == "false"} {
 set_db delaycal_enable_si false ;				        # (default : false)
} else {
 set_db delaycal_enable_si true ;				        # (default : false)
}

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

# Power
##############################################
set_db power_clock_source_as_clock true ;				# (default : false)
set_db power_disable_static false ;					# (default : true)
set_db power_honor_negative_energy true ;				# (default : true)
set_db power_ignore_control_signals false ;				# (default : true)
set_db power_read_rcdb true ;						# (default : false)
set_db power_constant_override false ;					# (default : false)
set_db power_domain_based_clipping true ;				# (default : false)

set_db power_use_lef_for_missing_cells true

#set_db power_transition_time_method avg ;				# (default : max)
#set_db power_average_rise_fall_cap true ;				# (default : false)
#set_db power_compatible_internal_power false ;				# (default : true)

# Not supported in DSTA
if {[info command distribute_partition] == ""} {
   set_default_switching_activity -clip_activity_to_domain_freq true ;	# (default : false)
}

# CCOpt
###############################################

#############################################################################################################################################
#   need to define those fix values in setup.tcl file
#############################################################################################################################################
if {[info command distribute_partition] == ""} {
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
}
# Fillercells
###############################################
set designname [get_db designs .name]
set_db add_fillers_cells $FILLERS_CELLS_LIST
set_db add_fillers_no_single_site_gap false
set_db add_fillers_prefix FILL_${designname} 
set_db add_fillers_preserve_user_order true
set_db add_fillers_eco_mode true
set_db add_fillers_avoid_abutment_patterns "1:1 2:1" ;		        # (default : "1:1 2:1") 
set_db add_fillers_swap_cell $ADD_FILLERS_SWAP_CELL
	      



#------------------------------------------------------------------------------
# define voltage_threshold_group
#------------------------------------------------------------------------------
if {[info command distribute_partition] == ""} {
	# clear previous vt group naming
	set_db [get_db base_cells] .voltage_threshold_group ""
	foreach name [lsort [array names VT_GROUPS]] {
		puts "-I- voltage_threshold_group for $name"
		set_db [get_db base_cells -if ".name == $VT_GROUPS($name) && !.is_black_box"] .voltage_threshold_group $name
	}

}

#------------------------------------------------------------------------------
# set dont use for cells
#------------------------------------------------------------------------------
source -e -v scripts/flow/dont_use_n_ideal_network.tcl

#------------------------------------------------------------------------------
# extraction
#------------------------------------------------------------------------------
set_db timing_extract_model_enable_mt true


###############################################
# Process
###############################################
set sh_continue_on_error true
if {[info exists env(TMPDIR)] && $env(TMPDIR) != ""} {set_app_var pt_tmp_dir $env(TMPDIR)}

set sh_new_variable_message false
if {[regexp 2020 $sh_product_version]} { set eco_enable_more_scenarios_than_hosts true }

set eco_report_unfixed_reason_max_endpoints 500
if {$pt_shell_mode == "primetime_master"} {
	if {[info exists RESTORE] && $RESTORE == "true" } {
		file delete -force ./work_restored
		set multi_scenario_working_directory ./work_restored
		set multi_scenario_merged_error_log ./work_restored/error_log.txt
	} else {
		file delete -force ./work
		set multi_scenario_working_directory ./work
		set multi_scenario_merged_error_log ./work/error_log.txt
	}
	set multi_scenario_license_mode core
}
set search_path ". $search_path $sh_launch_dir"


if {[info exists XTALK_SI] && $XTALK_SI == "true"} {
	set si_enable_analysis true 
	set si_xtalk_double_switching_mode clock_network 
      set_app_var si_enable_multi_input_switching_analysis true
      set_app_var si_enable_multi_input_switching_timing_window_filter true
      
#	can be read only after design  exists.
#      if {$pt_shell_mode != "primetime_master"} {
#      	set_noise_parameters -analysis_mode report_at_endpoint
#      }
}


##### OCV setting.
if {[info exists OCV] && $OCV == "pocv"} {
	if {[info exists pvt] && [regexp "SS" $pvt]} {
     	 	set_app_var timing_pocvm_corner_sigma 3.0
      		set_app_var timing_pocvm_report_sigma 3.0
	} elseif {[info exists pvt] && [regexp "FF" $pvt]} {
    		set_app_var timing_pocvm_corner_sigma 4.5
      		set_app_var timing_pocvm_report_sigma 4.5
	}

	#Enabling POCV analysis is required for via variation
	# Enabling POCV analysis
	set timing_pocvm_enable_analysis true

	#  By default, POCV side file will take precedence over LVF data
	#  If both POCV side file and LVF are applied on the same library cell, to make POCV side takes precendece
	# set timing_pocvm_precedence lib_cell_in_file
	#  If both POCV side file and LVF are applied on the same library cell, to make LVF takes precendece

 	set timing_pocvm_precedence library

	#############################################################
	# changed app vars base on noam comparison with BRCM
	#############################################################

	set timing_pocvm_enable_extended_moments false

}
if {$PROJECT == "nxt013" || $PROJECT == "brcm3"} {
	# from file /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/cyclone_primetime-lvf_init.tcl
	set_app_var delay_calc_enhanced_ccsn_waveform_analysis false
	set_app_var si_multi_input_switching_late_margin_factor 1.0
	set_app_var case_analysis_sequential_propagation              never  
	set_app_var timing_clock_gating_propagate_enable              true  
	set_app_var timing_crpr_different_transition_variation_derate 0.0
	set_app_var si_ccs_recalculate_quiet_delay                    true
	set_app_var timing_report_use_worst_parallel_cell_arc         true

	set_app_var timing_aocvm_analysis_mode                        ""



}



# Enabling CCS-based waveform propagation. This variable needs to be set before link_design.
# CCS waveform analysis requires libraries that contain CCS timing and CCS noise data. 
# Please make sure the libraries have passed check_library checks in Library Compiler.  
set delay_calc_waveform_analysis_mode  full_design
set timing_enable_slew_variation true
set timing_enable_constraint_variation true
set read_parasitics_load_locations true
set timing_enable_slew_variation true
#Must enable this variable before read_parasitics to extract via infomation
#set parasitics_enable_tail_annotation true
#set sh_source_uses_search_path true ;

set timing_remove_clock_reconvergence_pessimism true 
#set timing_clock_reconvergence_pessimism same_transition 
set pba_exhaustive_endpoint_path_limit infinity

set_app_var timing_use_constraint_derates_for_pulse_checks true
set_app_var variation_report_timing_increment_format delay_variation
set_app_var timing_save_pin_arrival_and_required true


#set_app_var extract_model_with_ccs_timing true
#set_app_var extract_model_with_clock_latency_arcs true


if {[info exists POWER_REPORTS] && $POWER_REPORTS == "true"} {
	set_app_var power_enable_analysis true
	set_app_var power_enable_multi_rail_analysis true
	set_app_var power_enable_advanced_sv_name_mapping true
	
	if {[info exists VCD_FILE] && [file exists $VCD_FILE]} {
		set_app_var power_analysis_mode time_based
	}
	
}
#############################################################
# changed app vars base on noam comparison with BRCM
#############################################################

set timing_save_pin_arrival_and_slack true
set timing_prelayout_scaling false
set timing_enable_max_transition_set_case_analysis true
set timing_enable_max_capacitance_set_case_analysis true
set timing_early_launch_at_borrowing_latches false
set timing_crpr_threshold_ps 1
set timing_clock_reconvergence_pessimism normal
set si_xtalk_delay_analysis_mode all_path_edges
set si_xtalk_composite_aggr_mode statistical
set si_noise_skip_update_for_report_attribute true
set si_noise_immunity_default_height_ratio 0.20
set si_noise_endpoint_height_threshold_ratio 1.0
set si_noise_composite_aggr_mode statistical
set sh_source_uses_search_path false
#set sh_new_variable_message true
set scaling_calculation_compatibility true
set rc_degrade_min_slew_when_rd_less_than_rnet true
set rc_cache_min_max_rise_fall_ceff true
set pba_enable_xtalk_delay_ocv_pessimism_reduction true
set parasitics_enable_tail_annotation false
#set multi_scenario_enable_analysis false
if { ![info exists ::CREATE_BLACKBOX] || !$::CREATE_BLACKBOX } {
    set link_create_black_boxes false
} else {
    set link_create_black_boxes true
}

# ????????
set extract_model_with_clock_latency_arcs false
set extract_model_with_ccs_timing false
#set eco_report_unfixed_reason_max_endpoints 0
#set eco_enable_more_scenarios_than_hosts false
set case_analysis_propagate_through_icg true
set report_default_significant_digits 3 ;
#############################################################
# eco setting
#############################################################
#set eco_strict_pin_name_equivalence true

#############################################################
# write HS model
#############################################################
if { [info exists ::CREATE_HS] && $::CREATE_HS } {
    puts "-I- Setting hier_enable_analysis to true"
    #set_app_var hier_enable_analysis true
#    set hier_enable_distributed_analysis true
    set hier_enable_analysis true
}

if {[info exists pvt] && [regexp "SS" $pvt]} {
  set timing_crpr_different_transition_derate 0.97
  set si_xtalk_composite_aggr_quantile_high_pct 99.85
} elseif {[info exists pvt] && [regexp "FF" $pvt]} {
  set timing_crpr_different_transition_derate  0.93
  set si_xtalk_composite_aggr_quantile_high_pct 99.72
}

###############################################
# Process
###############################################
if { [info exists ::env(PROJECT)] } {
	set proj $::env(PROJECT)
} else {
    set proj [lindex [split [pwd] "/"] end-3]
}
set sh_continue_on_error true

set sh_new_variable_message false
if {[regexp 2020 $sh_product_version]} { set eco_enable_more_scenarios_than_hosts true }

set eco_report_unfixed_reason_max_endpoints 500
if {$pt_shell_mode == "primetime_master"} {
	file delete -force ./work
	set multi_scenario_working_directory ./work
	set multi_scenario_merged_error_log ./work/error_log.txt
	set multi_scenario_license_mode core
}
set search_path ". $search_path $sh_launch_dir"


if {[info exists XTALK_SI] && $XTALK_SI == "true"} {
	set si_enable_analysis true 
	set si_xtalk_double_switching_mode clock_network 
      set_app_var si_enable_multi_input_switching_analysis true
      set_app_var si_enable_multi_input_switching_timing_window_filter true
}
if {[info exists pvt] && [regexp "SS" $pvt]} {
      set_app_var timing_pocvm_corner_sigma 3.0
      set_app_var timing_pocvm_report_sigma 3.0
} elseif {[info exists pvt] && [regexp "SS" $pvt]} {
      set_app_var timing_pocvm_corner_sigma 4.5
      set_app_var timing_pocvm_report_sigma 4.5
}

# Enabling CCS-based waveform propagation. This variable needs to be set before link_design.
# CCS waveform analysis requires libraries that contain CCS timing and CCS noise data. 
# Please make sure the libraries have passed check_library checks in Library Compiler.  
#set delay_calc_waveform_analysis_mode  full_design
set delay_calc_waveform_analysis_mode  disabled ; # set to disabled since nfi do not extract ccs
# Enabling POCV analysis
set timing_pocvm_enable_analysis true
set timing_enable_slew_variation true
set timing_enable_constraint_variation true
set timing_pocvm_enable_extended_moments true
set read_parasitics_load_locations true
#  By default, POCV side file will take precedence over LVF data
#  If both POCV side file and LVF are applied on the same library cell, to make POCV side takes precendece
# set timing_pocvm_precedence lib_cell_in_file
#  If both POCV side file and LVF are applied on the same library cell, to make LVF takes precendece

set timing_pocvm_precedence library

#Enabling POCV analysis is required for via variation
set timing_pocvm_enable_analysis true
set timing_enable_slew_variation true
#Must enable this variable before read_parasitics to extract via infomation
set parasitics_enable_tail_annotation true
set report_default_significant_digits 3 ;
set sh_source_uses_search_path true ;

set timing_remove_clock_reconvergence_pessimism true 
set timing_clock_reconvergence_pessimism same_transition 
set pba_exhaustive_endpoint_path_limit infinity

set_app_var timing_use_constraint_derates_for_pulse_checks true
set_app_var variation_report_timing_increment_format delay_variation
set_app_var timing_save_pin_arrival_and_required true


#set_app_var extract_model_with_ccs_timing true
set_app_var extract_model_with_clock_latency_arcs true




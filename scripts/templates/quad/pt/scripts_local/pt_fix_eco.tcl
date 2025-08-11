#################################################################################################################################################
#																		#
#	this script will run PrimeTime ECO  													#
#	variable received from session of setting:												#
#																		#
#																		#
#	 Var	date of change	owner		 comment											#
#	----	--------------	-------	 ---------------------------------------------------------------					#
#	0.1	05/10/2021	Royl	initial script												#
#																		#
#																		#
#################################################################################################################################################
if {[file exists eco_setting.tcl]} {source -e -v eco_setting.tcl}

if {![info exists eco_number]}  	{set eco_number 1}
if {![info exists round]}  		{set round 1}
if {![info exists RESULTS_DIR]}  	{set RESULTS_DIR [pwd]/eco_results_${eco_number}_${round}}


if {![info exists DEF_FILE]}   		{set DEF_FILE $INNOVUS_DIR/out/def/${DESIGN_NAME}.${STAGE}.def.gz}
if {![info exists PHYSICAL_MODE]}  	{set PHYSICAL_MODE occupied_site } ; #options are open_site , occupied_site ,
if {![info exists FIX_CLOCK]}  		{set FIX_CLOCK false}
if {![info exists SETUP_MARGIN]}   	{set SETUP_MARGIN 0.05}

if {![info exists FIX_TRANSITION]}  	{set FIX_TRANSITION false}
if {![info exists FIX_CAPACITANCE]}  	{set FIX_CAPACITANCE false}
if {![info exists FIX_NOISE]}  		{set FIX_NOISE false}

if {![info exists FIX_LEAKAGE]}  	{set FIX_LEAKAGE false}
if {![info exists FIX_AREA_RECOVERY]}   {set FIX_AREA_RECOVERY false}

if {![info exists FIX_SETUP]}  		{set FIX_SETUP false}
if {![info exists FIX_SETUP_GROUPS]}  	{set FIX_SETUP_GROUPS {"**async_default**" "**clock_gating_default**" "in2out" "in2reg" "reg2out" "reg2reg"} }

if {![info exists FIX_HOLD]}  		{set FIX_HOLD false}
if {![info exists FIX_HOLD_GROUPS]}  	{set FIX_HOLD_GROUPS {"**async_default**" "**clock_gating_default**" "reg2reg"} }


if {![file exists $RESULTS_DIR]} {sh mkdir $RESULTS_DIR}

if {$FIX_CLOCK} {
	set INV_LIST [list]
	if {[info exists CTS_INVERTER_CELLS_TOP] && $CTS_INVERTER_CELLS_TOP ne ""}     {foreach dd $CTS_INVERTER_CELLS_TOP { lappend INV_LIST "*/$dd"}}
	if {[info exists CTS_INVERTER_CELLS_TRUNK] && $CTS_INVERTER_CELLS_TRUNK ne ""} {foreach dd $CTS_INVERTER_CELLS_TRUNK { lappend INV_LIST "*/$dd"}}
	if {[info exists CTS_INVERTER_CELLS_LEAF] && $CTS_INVERTER_CELLS_LEAF ne ""}   {foreach dd $CTS_INVERTER_CELLS_LEAF { lappend INV_LIST "*/$dd"}}
	if {[llength $INV_LIST] == 0} {
		puts "ERROR: missing INV LIST"
		return
	}
	
	if {$pt_shell_mode == "primetime_master"} {
		if {![info exists ECO_DRC_BUF_LIST]}   	{get_distributed_variables ECO_DRC_BUF_LIST    -merge_type unique_list -pre_commands {set ECO_DRC_BUF_LIST   [get_attribute [get_lib_cells $INV_LIST] base_name] }}
		if {![info exists ECO_SETUP_BUF_LIST]}  {get_distributed_variables ECO_SETUP_BUF_LIST  -merge_type unique_list -pre_commands {set ECO_SETUP_BUF_LIST [get_attribute [get_lib_cells $INV_LIST] base_name] }}
		if {![info exists ECO_HOLD_BUF_LIST]}  	{get_distributed_variables ECO_HOLD_BUF_LIST   -merge_type unique_list -pre_commands {set ECO_HOLD_BUF_LIST  [get_attribute [get_lib_cells $INV_LIST] base_name] }}
	} else {
	# use inverters for clock
		if {![info exists ECO_DRC_BUF_LIST]}   	{set ECO_DRC_BUF_LIST   [get_attribute [get_lib_cells $INV_LIST] base_name] }
		if {![info exists ECO_SETUP_BUF_LIST]}  {set ECO_SETUP_BUF_LIST [get_attribute [get_lib_cells $INV_LIST] base_name] }
		if {![info exists ECO_HOLD_BUF_LIST]}  	{set ECO_HOLD_BUF_LIST  [get_attribute [get_lib_cells $INV_LIST] base_name] }
	}
} else {
	if {$pt_shell_mode == "primetime_master"} {
		# use buffers for data path
		if {![info exists ECO_DRC_BUF_LIST]}   	{get_distributed_variables ECO_DRC_BUF_LIST    -merge_type unique_list -pre_commands {set ECO_DRC_BUF_LIST   [get_attribute [get_lib_cells {*/*_BUF*X4 */*_BUF*X8 */*_BUF*X6 */*_BUF*X10 */*_BUF*X12 */*_BUF*X14 */*_BUF*X16    }] base_name] }}
		if {![info exists ECO_SETUP_BUF_LIST]}  {get_distributed_variables ECO_SETUP_BUF_LIST  -merge_type unique_list -pre_commands {set ECO_SETUP_BUF_LIST [get_attribute [get_lib_cells {*/*_BUF*X4 */*_BUF*X8 */*_BUF*X6 */*_BUF*X10 */*_BUF*X12 */*_BUF*X14 */*_BUF*X16    }] base_name] }}
		if {![info exists ECO_HOLD_BUF_LIST]}  	{get_distributed_variables ECO_HOLD_BUF_LIST   -merge_type unique_list -pre_commands {set ECO_HOLD_BUF_LIST  [get_attribute [get_lib_cells {*/*_BUF*X4 */*_BUF*X8 */*_BUF*X6 */*_BUF*X10 */*_BUF*X12 */*_BUF*X14 */*_BUF*X16    }] base_name] }}
	} else {
		if {![info exists ECO_DRC_BUF_LIST]}   	{set ECO_DRC_BUF_LIST   [get_attribute [get_lib_cells {*/*_BUF*X4 */*_BUF*X8 */*_BUF*X6 */*_BUF*X10 */*_BUF*X12 */*_BUF*X14 */*_BUF*X16    }] base_name] }
		if {![info exists ECO_SETUP_BUF_LIST]}  {set ECO_SETUP_BUF_LIST [get_attribute [get_lib_cells {*/*_BUF*X4 */*_BUF*X8 */*_BUF*X6 */*_BUF*X10 */*_BUF*X12 */*_BUF*X14 */*_BUF*X16    }] base_name] }
		if {![info exists ECO_HOLD_BUF_LIST]}  	{set ECO_HOLD_BUF_LIST  [get_attribute [get_lib_cells {*/*_BUF*X4 */*_BUF*X8 */*_BUF*X6 */*_BUF*X10 */*_BUF*X12 */*_BUF*X14 */*_BUF*X16    }] base_name] }
	}
}

if {$PHYSICAL == "true"} {
	set cmd "set_eco_options "
	set cmd "$cmd -physical_tech_lib_path {$TECH_LEF} -filler_cell_names {$FILLERS_CELLS_LIST} -physical_lib_path {$LEF_FILE_LIST} -physical_design_path {$DEF_FILE} -log_file physical_information.log -enable_pin_color_alignment_check "
	if {$FIX_CLOCK == "true"} {
		set cmd "$cmd -physical_enable_clock_data"
	}
	if {[info exists PHYSICAL_CONSTRAINT_FILE] && [file exists $PHYSICAL_CONSTRAINT_FILE]} {
		set cmd "$cmd -physical_constraint_file $PHYSICAL_CONSTRAINT_FILE"
	}

   	if {$pt_shell_mode == "primetime_master"} {
		set cmd "remote_execute { $cmd }"
   	}
	echo $cmd
	eval $cmd
}

if {$pt_shell_mode == "primetime_master"} {
   set_distributed_variables {RESULTS_DIR    }
}

##################################################################
#    Physically Aware check_eco Section                          #
##################################################################
if {$pt_shell_mode == "primetime_master"} {
	remote_execute {   check_eco }
} else {
	check_eco
}

##################################################################
#    DONT USE and DONT_TOUCH                                     #
##################################################################
if {$pt_shell_mode == "primetime_master"} {
	remote_execute { source $sh_launch_dir/scripts/flow/dont_use_n_ideal_network.tcl   }
} else {
	source scripts/flow/dont_use_n_ideal_network.tcl
}


if {$pt_shell_mode == "primetime_master"} {
	remote_execute {write_changes -reset	}
} else {
	write_changes -reset
}

##################################################################
#    Fix ECO Leakage Section                                     #
##################################################################
if {$FIX_LEAKAGE} {

	if {$pt_shell_mode == "primetime_master"} {
	   remote_execute {
 	   	define_user_attribute vt_swap_priority -type string -class lib_cell
		foreach_in_collection lib_cell [get_lib_cells */F6*] {
			set_user_attr -class lib_cell [get_lib_cells $lib_cell ] vt_swap_priority [get_attr $lib_cell base_name]
		}
		
		set power_enable_analysis true
		report_cell_usage -pattern_priority $leakage_pattern_priority_list > $RESULTS_DIR/pre_leakage_eco_report_cell_usage.report
	   	report_power -threshold -pattern_priority $leakage_pattern_priority_list -group "combinational register sequential clock_network " > $RESULTS_DIR/pre_leakage_eco_report_power.rpt
   	   }
	   
	   
	} else {
 	   define_user_attribute vt_swap_priority -type string -class lib_cell
	   foreach_in_collection lib_cell [get_lib_cells */F6*] {
		set_user_attr -class lib_cell [get_lib_cells $lib_cell ] vt_swap_priority [get_attribute $lib_cell base_name]
	   }
	   
	   set power_enable_analysis true
	   report_cell_usage -pattern_priority $leakage_pattern_priority_list > $RESULTS_DIR/pre_leakage_eco_report_cell_usage.report
	   report_power -threshold -pattern_priority $leakage_pattern_priority_list -group "combinational register sequential clock_network " > $RESULTS_DIR/pre_leakage_eco_report_power.rpt
	}
	
	fix_eco_leakage -verbose -setup_margin $SETUP_MARGIN -pattern $leakage_pattern_priority_list -attribute vt_swap_priority
	
	if {$pt_shell_mode == "primetime_master"} {
	   remote_execute {
		report_cell_usage -pattern_priority $leakage_pattern_priority_list > $RESULTS_DIR/post_leakage_eco_report_cell_usage.report
		report_power -threshold -pattern_priority $leakage_pattern_priority_list -group "combinational register sequential clock_network " > $RESULTS_DIR/post_leakage_eco_report_power.rpt
	   }
	} else {
		report_cell_usage -pattern_priority $leakage_pattern_priority_list > $RESULTS_DIR/post_leakage_eco_report_cell_usage.report
		report_power -threshold -pattern_priority $leakage_pattern_priority_list -group "combinational register sequential clock_network " > $RESULTS_DIR/post_leakage_eco_report_power.rpt
	}


}


##################################################################
#    Fix ECO Power Cell Downsize Section                         #
##################################################################
if {$FIX_AREA_RECOVERY} {
	if {$pt_shell_mode == "primetime_master"} {
	   remote_execute {
		set power_enable_analysis true
		report_constraint -all -max_capacitance -max_transition > $RESULTS_DIR/pre_area_recovary_report_constraint.rpt          
		report_cell_usage > $RESULTS_DIR/pre_area_recovary_report_cell_usage.report
	   }
	} else {
		set power_enable_analysis true
		report_constraint -all -max_capacitance -max_transition > $RESULTS_DIR/pre_area_recovary_report_constraint.rpt          
		report_cell_usage > $RESULTS_DIR/pre_area_recovary_report_cell_usage.report
	}

	fix_eco_power -pba_mode ex -setup_margin $SETUP_MARGIN -verbose -methods remove_buffer
	if {$pt_shell_mode == "primetime_master"} {
	   remote_execute {
		set power_enable_analysis true
		report_constraint -all -max_capacitance -max_transition > $RESULTS_DIR/post_area_recovary_report_constraint.rpt          
		report_cell_usage > $RESULTS_DIR/post_area_recovary_report_cell_usage.report
		
	# write netlist changes
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_AREA_RECOVERY_${mode}_${pvt}_${rc}_${check}.tcl
		write_changes -reset
	   }
	   
	} else {
		set power_enable_analysis true
		report_constraint -all -max_capacitance -max_transition > $RESULTS_DIR/post_area_recovary_report_constraint.rpt          
		report_cell_usage > $RESULTS_DIR/post_area_recovary_report_cell_usage.report
		
	# write netlist changes
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_AREA_RECOVERY.tcl
		write_changes -reset
	}
}

##################################################################
#    Fix ECO DRC Section                                         #
##################################################################
if {$FIX_TRANSITION} {
	set_app_var eco_instance_name_prefix max_tran_inst_${eco_number}_${round}_
	set_app_var eco_net_name_prefix max_tran_net_${eco_number}_${round}_
	report_constraint -nosplit -all -max_transition > $RESULTS_DIR/pre_eco_max_transition.rpt          
	fix_eco_drc \
		-type max_transition \
		-method { size_cell insert_buffer } \
		-verbose \
		-buffer_list $ECO_DRC_BUF_LIST \
		-physical_mode $PHYSICAL_MODE 
	report_constraint -nosplit -all -max_transition > $RESULTS_DIR/post_eco_max_transition.rpt          
	if {$pt_shell_mode == "primetime_master"} {
	  remote_execute {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_TRANSITION_${mode}_${pvt}_${rc}_${check}.tcl
		write_changes -reset
	   }
	} else {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_TRANSITION.tcl
		write_changes -reset
	}
	
}
if {$FIX_CAPACITANCE} {
	set_app_var eco_instance_name_prefix max_cap_inst_${eco_number}_${round}_
	set_app_var eco_net_name_prefix max_cap_net_${eco_number}_${round}_
	report_constraint -nosplit -all -max_capacitance > $RESULTS_DIR/pre_eco_cap_transition.rpt          
	fix_eco_drc \
		-type max_capacitance \
		-method { size_cell insert_buffer } \
		-verbose \
		-buffer_list $ECO_DRC_BUF_LIST \
		-physical_mode $PHYSICAL_MODE 
	report_constraint -nosplit -all -max_capacitance > $RESULTS_DIR/post_eco_max_capacitance.rpt 
	
	if {$pt_shell_mode == "primetime_master"} {
	  remote_execute {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_CAPACITANCE_${mode}_${pvt}_${rc}_${check}.tcl
		write_changes -reset
	   }
	} else {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_CAPACITANCE.tcl
		write_changes -reset
	}
	         
}
if {$FIX_NOISE} {
	set_app_var eco_instance_name_prefix noise_inst_${eco_number}_${round}_
	set_app_var eco_net_name_prefix noise_net_${eco_number}_${round}_
	
	report_noise -nosplit -all_violators -above -low  > $RESULTS_DIR/pre_eco_report_noise_all_viol_abv_low.report
	report_noise -nosplit -all_violators -below -high > $RESULTS_DIR/pre_eco_report_noise_all_viol_below_high.report
	
	fix_eco_drc \
		-type noise \
		-method { size_cell insert_buffer } \
		-verbose \
		-buffer_list $ECO_DRC_BUF_LIST \
		-physical_mode $PHYSICAL_MODE 
		
	report_noise -nosplit -all_violators -above -low  > $RESULTS_DIR/post_eco_report_noise_all_viol_abv_low.report
	report_noise -nosplit -all_violators -below -high > $RESULTS_DIR/post_eco_report_noise_all_viol_below_high.report
	if {$pt_shell_mode == "primetime_master"} {
	  remote_execute {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_NOISE_${mode}_${pvt}_${rc}_${check}.tcl
		write_changes -reset
	   }
	} else {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_NOISE.tcl
		write_changes -reset
	}
		
}

##################################################################
#    Fix ECO Timing Section                                      #
##################################################################
if {$FIX_SETUP} {
# fix setup 
	set_app_var eco_instance_name_prefix setup_inst_${eco_number}_${round}_
	set_app_var eco_net_name_prefix setup_net_${eco_number}_${round}_
	report_timing \
		-delay_type max \
		-physical \
		-slack_lesser_than 0 \
		-max_paths 10000 \
		-derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode exhaustive > $RESULTS_DIR/pre_eco_setup.rpt
		
	if {$FIX_CLOCK} {
		set CELL_TYPE "clock_network"
		set METHODS "insert_inverter_pair"
	} else {
		set CELL_TYPE "combinational sequential"
		set METHODS "size_cell insert_buffer"
	}

	set cmd "fix_eco_timing \
		-type setup \
		-methods  {$METHODS } \
		-pba_mode $PBA_MODE \
		-buffer_list {$ECO_SETUP_BUF_LIST} \
		-group {$FIX_SETUP_GROUPS} \
		-verbose \
		-cell_type {$CELL_TYPE } \
		-slack_lesser_than 0 \
		-physical_mode $PHYSICAL_MODE \
		-estimate_unfixable_reasons "
		
	if {[info exists ECO_SETUP_TIMEOUT] && $ECO_SETUP_TIMEOUT != ""} {set cmd "$cmd -timeout $ECO_SETUP_TIMEOUT"}
	if {$pt_shell_mode == "primetime_master"} {
		if {[info exists scenarios(leakage)] && $scenarios(leakage) != ""  } { #set cmd "$cmd -leakage_scenario $scenarios(leakage)"}
		if {[info exists scenarios(dynamic)] && $scenarios(dynamic) != ""  } { #set cmd "$cmd -dynamic_scenario $scenarios(dynamic)"}
	}
	echo $cmd
	eval $cmd
	
	report_timing \
		-delay_type max \
		-physical \
		-slack_lesser_than 0 \
		-max_paths 10000 \
		-derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode exhaustive > $RESULTS_DIR/post_eco_setup.rpt
	
	if {$pt_shell_mode == "primetime_master"} {
	  remote_execute {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_SETUP_${mode}_${pvt}_${rc}_${check}.tcl
		write_changes -reset
	   }
	} else {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_SETUP.tcl
		write_changes -reset
	}

}

##################################################################
#    Fix ECO hold Section                                      #
##################################################################
if {$FIX_HOLD} {
# fix hold 
	set_app_var eco_instance_name_prefix hold_inst_${eco_number}_${round}_
	set_app_var eco_net_name_prefix hold_net_${eco_number}_${round}_
	report_timing \
		-delay_type min \
		-physical \
		-slack_lesser_than 0 \
		-max_paths 10000 \
		-derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode exhaustive > $RESULTS_DIR/pre_eco_hold_${eco_number}_${round}.rpt

	if {$FIX_CLOCK} {
		set CELL_TYPE "clock_network"
		set METHODS "insert_inverter_pair"
	} else {
		set CELL_TYPE "combinational"
		set METHODS "size_cell insert_buffer insert_buffer_at_load_pins"
	}

	set cmd "fix_eco_timing \
		-type hold \
		-methods  {$METHODS } \
		-pba_mode $PBA_MODE \
		-buffer_list {$ECO_HOLD_BUF_LIST} \
		-group {$FIX_HOLD_GROUPS} \
		-verbose \
		-cell_type {$CELL_TYPE } \
		-slack_lesser_than 0 \
		-physical_mode $PHYSICAL_MODE \
		-estimate_unfixable_reasons "
	if {[info exists ECO_HOLD_TIMEOUT] && $ECO_HOLD_TIMEOUT != ""} {set cmd "$cmd -timeout $ECO_HOLD_TIMEOUT"}
	if {[info exists FIX_HOLD_LOAD_CELL_LIST] && $FIX_HOLD_LOAD_CELL_LIST != ""} {set cmd "$cmd -load_cell_list $FIX_HOLD_LOAD_CELL_LIST"}
	
	if {$pt_shell_mode == "primetime_master"} {
		if {[info exists scenarios(leakage)] && $scenarios(leakage) != ""  } { #set cmd "$cmd -leakage_scenario $scenarios(leakage)"}
		if {[info exists scenarios(dynamic)] && $scenarios(dynamic) != ""  } { #set cmd "$cmd -dynamic_scenario $scenarios(dynamic)"}
	}
	echo $cmd
	eval $cmd

	report_timing \
		-delay_type min \
		-physical \
		-slack_lesser_than 0 \
		-max_paths 10000 \
		-derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode exhaustive > $RESULTS_DIR/post_eco_hold_${eco_number}_${round}.rpt
	
	if {$pt_shell_mode == "primetime_master"} {
	  remote_execute {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_HOLD_${mode}_${pvt}_${rc}_${check}.tcl
		write_changes -reset
	   }
	} else {
		write_changes -format icctcl -output $RESULTS_DIR/eco_changes_FIX_HOLD.tcl
		write_changes -reset
	}
}



return
##################################################################
#    Fix ECO Output Section                                      #
##################################################################
# write netlist changes
remote_execute {
write_changes -format icctcl -output $RESULTS_DIR/eco_changes.tcl
}


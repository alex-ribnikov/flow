#################################################################################################################################################################################
#																						#
#	this script will run Fusion_compiler  																		#
#	variable received from shell are:																	#
#		CPU		- number of CPU to run.8 per license														#
#		DESIGN_NAME	- name of top model																#
#		IS_PHYSICAL	- runing physical synthesis															#
#		SCAN 		- insert scan to the design															#
#		OCV 		- run with ocv 																	#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	27/11/2024	Royl	initial script																#
#																						#
#																						#
#################################################################################################################################################################################
if {[info exists LABEL]}         {puts "LABEL $LABEL"} else {set LABEL "None" }

set STAGE cts

source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
if {![file exists ./reports/qor_data]} {exec mkdir -pv ./reports/qor_data}
if {![file exists ./reports/cts]} {exec mkdir -pv ./reports/cts}
if {![file exists ./reports/cts_only]} {exec mkdir -pv ./reports/cts_only}
if {![file exists ./reports/cts/snapshots]} {exec mkdir -pv ./reports/cts/snapshots}
if {![file exists ./reports/cts_only/snapshots]} {exec mkdir -pv ./reports/cts_only/snapshots}
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}

exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.

set_host_options -max_cores $CPU

script_runtime_proc -start


#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	set setup_file scripts/setup/setup.${PROJECT}.tcl
}
source -v -e $setup_file
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v -e ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v -e scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------

set_svf out/svf/${DESIGN_NAME}_${STAGE}.svf
open_lib out/${DESIGN_NAME}_lib
copy_block -from ${DESIGN_NAME}/place -to ${DESIGN_NAME}/cts -force
current_block ${DESIGN_NAME}/cts
link_block

#------------------------------------------------------------------------------
# hierarchical flow
#------------------------------------------------------------------------------
if {[info exists USE_ABSTRACTS_FOR_BLOCKS] && $USE_ABSTRACTS_FOR_BLOCKS != ""} {
		puts "-I- Swapping { $USE_ABSTRACTS_FOR_BLOCKS } blocks for abstracts to design view for all blocks"
		change_abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label $STAGE -view abstract
		report_abstracts
}


#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
set QOR_STRATEGY_STAGE cts
if {[file exists scripts_local/fc_variables.tcl]} {
	puts "-I- reading fc_variables file from scripts_local"
	source -v -e scripts_local/fc_variables.tcl
} else {
	puts "-I- reading fc_variables file from scripts"
	source -v -e scripts/flow/fc_variables.tcl
}


#------------------------------------------------------------------------------
# connect_pg_net
#------------------------------------------------------------------------------
if {[file exists scripts_local/connect_pg_net.tcl]} {
        puts "-I- reading connect_pg_net file from scripts_local"
        source -e -v scripts_local/connect_pg_net.tcl
} else {
        puts "-I- reading connect_pg_net file from scripts"
        source -e -v scripts/flow/connect_pg_net.tcl
}


#------------------------------------------------------------------------------
# pre cts_only extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_cts_only_setting.tcl]} {
	puts "-I- reading pre_cts_only_setting file from scripts_local"
	source -v -e ./scripts_local/pre_cts_only_setting.tcl
} 

#------------------------------------------------------------------------------
# clocks extra margin
#------------------------------------------------------------------------------
if {[info exists CLOCK_MARGIN] && $CLOCK_MARGIN == "true"} {
	if {![info exists UNCERTAINTY_MARGIN] || $UNCERTAINTY_MARGIN == ""} {
		puts "Error: clock extra margin was set, but no margin numbers exists. please set UNCERTAINTY_MARGIN list (NextSi-301)"
	} else {
		set EXTRA_MARGIN [expr  [lindex $UNCERTAINTY_MARGIN 1] + [lindex $UNCERTAINTY_MARGIN 2]]
		puts "Information: setting extra margin of $EXTRA_MARGIN on all clock "
		file mkdir scripts_local/UNC_SDC
		set CS [current_scenario]
		foreach_in_collection sss [all_scenarios] {
			current_scenario $sss
	
			write_sdc -include clock_uncertainty -output scripts_local/UNC_SDC/UNC_${STAGE}_[get_object_name $sss].sdc -nosplit
			if {[file exists ./scripts_local/UNC_SDC/UNC_${STAGE}_[get_object_name $sss].sdc]} {
				set fid_in [open ./scripts_local/UNC_SDC/UNC_compile_[get_object_name $sss].sdc r]
			} else {
				set fid_in [open ./scripts_local/UNC_SDC/UNC_${STAGE}_[get_object_name $sss].sdc r]
			}
			set fid_out [open ./scripts_local/UNC_SDC/UNC_${STAGE}_[get_object_name $sss]_modify.sdc w ]
			set processed_lines_count 0
			while {[gets $fid_in line] != -1} {
    				# Check if the line starts with "set_clock_uncertainty" and contains "-setup"
    				# and capture the number next to -setup
				if {[regexp {^(.*)-setup\s+([0-9.]+)(.*)$} $line full_match prefix uncertainty_value suffix]} {
					set original_uncertainty $uncertainty_value
        				set new_uncertainty [expr {$original_uncertainty + $EXTRA_MARGIN}]

        				# Reconstruct the line with the new uncertainty value
        				# We use the captured 'prefix' and 'suffix' to maintain the rest of the line
        				set modified_line "${prefix}-setup ${new_uncertainty}${suffix}"

        				puts $fid_out "$modified_line"
        				incr processed_lines_count
		    		}
			}

			close $fid_in
			close $fid_out

			puts "-I- source set_clock_uncertainty update with $EXTRA_MARGIN for scenario [get_object_name $sss]"
			source ./scripts_local/UNC_SDC/UNC_${STAGE}_[get_object_name $sss]_modify.sdc
		}
	}
}


## Prefix
set_app_options -name cts.common.user_instance_name_prefix -value clock_opt_cts_
set_app_options -name opt.common.user_instance_name_prefix -value clock_opt_cts_opt_

## For set_qor_strategy -metric timing, disabling the leakage and dynamic power analysis in active scenarios for optimization
set rm_leakage_scenarios [get_object_name [get_scenarios -filter active==true&&leakage_power==true]]
set rm_dynamic_scenarios [get_object_name [get_scenarios -filter active==true&&dynamic_power==true]]
if {[llength $rm_leakage_scenarios] > 0 || [llength $rm_dynamic_scenarios] > 0} {
    	puts "RM-info: Disabling leakage analysis for $rm_leakage_scenarios"
    	puts "RM-info: Disabling dynamic analysis for $rm_dynamic_scenarios"
	set_scenario_status -leakage_power false -dynamic_power false [get_scenarios "$rm_leakage_scenarios $rm_dynamic_scenarios"]
}


#------------------------------------------------------------------------------
# clock tree setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/${DESIGN_NAME}_cts.tcl]} {
	puts "-I- reading ${DESIGN_NAME}_cts file from scripts_local"
	source -v -e ./scripts_local/${DESIGN_NAME}_cts.tcl
} 

#------------------------------------------------------------------------------
#  Pre-CTS customizations
#------------------------------------------------------------------------------
redirect -file reports/cts_only/report_lib_cell_purpose {report_lib_cell -objects [get_lib_cells] -column {full_name:20 valid_purposes}}
redirect -file reports/cts_only/pre_cts.report_clock_settings {report_clock_settings} ;# CTS constraints and settings
redirect -file reports/cts_only/pre_cts.check_clock_tree {check_clock_tree} ;# checks issues that could hurt CTS results
redirect -file reports/cts_only/report_qor.start {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
redirect -append -file reports/cts_only/report_qor.start {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
redirect -tee -file reports/cts_only/report_global_timing.start {report_global_timing -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
redirect -file reports/cts_only/check_stage_settings {check_stage_settings -stage pnr -metric timing -step cts}



redirect -file reports/cts_only/report_app_options.non_default_pre_cts_only.rpt {report_app_options -non_default}

#------------------------------------------------------------------------------
# clock_opt CTS flow
#------------------------------------------------------------------------------
set_app_options -list {design.enable_rule_based_query false}


puts "RM-info: Running check for relaxed clock transition constraint" 	
### TBD need to check this proc
#check_clock_transition -threshold 0.15 -apply_max_transition


if {[info exists BREAK_CTS] && $BREAK_CTS == "true" } {
	puts "RM-info: Running synthesize_clock_trees command"
	current_scenario $DEFAULT_CCOPT_VIEW
	
	
	redirect -file reports/cts_only/check_clock_trees.rpt {check_clock_trees}
	eee {synthesize_clock_trees}
	save_block -as ${DESIGN_NAME}/synthesize_clock_trees

	puts "RM-info: Running balance_clock_groups command"
	eee {balance_clock_groups}
	save_block -as ${DESIGN_NAME}/balance_clock_groups

	puts "RM-info: Running clock_opt command"
	eee {clock_opt}
	save_block -as ${DESIGN_NAME}/clock_opt
} else {

	puts "RM-info: Running clock_opt -from build_clock -to build_clock command"
	eee {clock_opt -from build_clock -to build_clock}
	#If relaxed clock transition applied, original constraint will be restored
	save_block -as ${DESIGN_NAME}/cts_build_clock


}



### TBD need to check this proc
#restore_clock_transition	
	
puts "RM-info: Running clock_opt -from route_clock -to route_clock command"
eee {clock_opt -from route_clock -to route_clock}

if {[info exists CTS_CREATE_SHIELDS] && $CTS_CREATE_SHIELDS} {
	create_shields -with_ground VSS
}

#------------------------------------------------------------------------------
## Post-CTS customizations
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
#  Propagate all clocks 
#------------------------------------------------------------------------------
## This should be used only when additional modes/scenarios are activated after CTS is done.
## Get inactive scenarios, activate them, mark them as propagated, and then deactivate them.
#	if {[sizeof_collection [get_scenarios -filter active==false -quiet]] > 0} {
#	        set active_scenarios [get_scenarios -filter active]
#	        set inactive_scenarios [get_scenarios -filter active==false]
#
#	        set_scenario_status -active false [get_scenarios $active_scenarios]
#	        set_scenario_status -active true [get_scenarios $inactive_scenarios]
#
#	        synthesize_clock_trees -propagate_only ;# only works on active scenarios
#	        set_scenario_status -active true [get_scenarios $active_scenarios]
#	        set_scenario_status -active false [get_scenarios $inactive_scenarios]
#	}


## Re-enable power analysis if disabled for set_qor_strategy -metric timing
if {[info exists rm_leakage_scenarios] && [llength $rm_leakage_scenarios] > 0} {
   puts "RM-info: Reenabling leakage power analysis for $rm_leakage_scenarios"
   set_scenario_status -leakage_power true [get_scenarios $rm_leakage_scenarios]
}
if {[info exists rm_dynamic_scenarios] && [llength $rm_dynamic_scenarios] > 0} {
   puts "RM-info: Reenabling dynamic power analysis for $rm_dynamic_scenarios"
   set_scenario_status -dynamic_power true [get_scenarios $rm_dynamic_scenarios]
}

## Run check_routes to save updated routing DRC to the block
redirect -tee -file reports/cts_only/check_routes {check_routes -open_net false}

## Save block
save_block -as ${DESIGN_NAME}/cts_only
save_lib 

#------------------------------------------------------------------------------
#  cts_only Reports  
#------------------------------------------------------------------------------
set stage_temp $STAGE
set STAGE cts_only

eee "redirect -file ./reports/${STAGE}/report_threshold_voltage_group.rpt {report_threshold_voltage_group -nosplit \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group
eee "redirect -file ./reports/${STAGE}/report_vt_summary.rpt {report_threshold_voltage_group -nosplit -summary \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group_summary
redirect -file ./reports/$STAGE/report_congestion_summary.rpt {report_congestion -mode summary}	
redirect -tee -file ./reports/$STAGE/report_congestion {report_congestion -layers [get_layers -filter "layer_type==interconnect"] -nosplit}
write_app_options -output reports/${STAGE}/write_app_options.bin
printvar -user_defined > reports/$STAGE/printvar_user_defined.tcl
sh perl -p -i -e {s/(.*)=/set \1/} reports/$STAGE/printvar_user_defined.tcl

if {[regexp  "k8s" $env(HOST)] } {

	set DESCRIPTION "[string tolower [lindex [split [pwd] "/"] end]]_reports"
	echo "set STAGE $STAGE" > ${STAGE}_report_parallel.tcl
	echo "set FE_MODE $FE_MODE" >> ${STAGE}_report_parallel.tcl
	echo "set DESIGN_NAME $DESIGN_NAME" >> ${STAGE}_report_parallel.tcl
	echo "set PROJECT $PROJECT" >> ${STAGE}_report_parallel.tcl
	echo "set RUNNING_DIR [pwd]" >> ${STAGE}_report_parallel.tcl
	echo "read_app_options [pwd]/reports/${STAGE}/write_app_options.bin" >> ${STAGE}_report_parallel.tcl
#	echo "source [pwd]/reports/${STAGE}/printvar_user_defined.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/procs.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/ory_general_utils.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/oy_time.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/be_mails.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common_snps/be_reports.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/qor.generator.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/proc_qor.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/proc_histogram.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/be_report_io_fo.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/fc_be_checkers.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/fc_be_utils.tcl" >> ${STAGE}_report_parallel.tcl
	if {[file exists ./scripts_local/post_cts_setting.tcl]} {
		echo "source [pwd]/scripts_local/post_cts_setting.tcl" >> ${STAGE}_report_parallel.tcl
	} 
		
 	set REPORTS_MEMORY [expr 1.4 * $MEMORY]
	
#	exec cp -pv ./scripts/flow/fc_reports_cts.tcl ./sourced_scripts/${STAGE}/.
 	report_parallel \
 		-work_directory reports/${STAGE}/parallel_run \
		-submit_command "./scripts/bin/pt_nextk8s.csh -cpu 16 -mem $REPORTS_MEMORY -pwd [pwd] -description ${DESCRIPTION} -label $LABEL"  \
		-max_cores 16 \
		-user_scripts [list "${STAGE}_report_parallel.tcl" "[which ./scripts/flow/fc_reports_cts.tcl]"]
		
		
} else {
	source -e -v ./scripts/flow/fc_reports_cts.tcl
}

set STAGE $stage_temp
write_qor_data -report_list "performance host_machine report_app_options" -label cts_only -output ./reports/qor_data
report_msg -summary
print_message_info -ids * -summary





#------------------------------------------------------------------------------
# set_qor_strategy cts opto
#------------------------------------------------------------------------------
set QOR_STRATEGY_STAGE post_cts_opto
if {[file exists scripts_local/fc_variables.tcl]} {
	puts "-I- reading fc_variables file from scripts_local"
	source -v -e scripts_local/fc_variables.tcl
} else {
	puts "-I- reading fc_variables file from scripts"
	source -v -e scripts/flow/fc_variables.tcl
}


#------------------------------------------------------------------------------
# pre cts extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_cts_setting.tcl]} {
	puts "-I- reading pre_cts_setting file from scripts_local"
	source -v -e ./scripts_local/pre_cts_setting.tcl
} 



#------------------------------------------------------------------------------
#  cts optimization 
#------------------------------------------------------------------------------

## Prefix
set_app_options -name opt.common.user_instance_name_prefix -value clock_opt_opto_
set_app_options -name cts.common.user_instance_name_prefix -value clock_opt_opto_cts_

redirect -file reports/cts/report_qor.start {report_qor -scenarios [all_scenarios] -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
redirect -append -file reports/cts/report_qor.start {report_qor -summary -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
redirect -tee -file reports/cts/report_global_timing.start {report_global_timing -pba_mode [get_app_option_value -name time.pba_optimization_mode] -nosplit}
redirect -file reports/cts/check_stage_settings {check_stage_settings -stage pnr -metric timing -step post_cts_opto}
redirect -file reports/cts/report_app_options.non_default_pre_cts_opto.rpt {report_app_options -non_default}


set_app_options -list {design.enable_rule_based_query false}

puts "RM-info: Running clock_opt -from final_opto -to final_opto command"
eee {clock_opt -from final_opto -to final_opto}

#------------------------------------------------------------------------------
#  connect_pg_net
#------------------------------------------------------------------------------
if {[file exists scripts_local/connect_pg_net.tcl]} {
        puts "-I- reading connect_pg_net file from scripts_local"
        source -e -v scripts_local/connect_pg_net.tcl
} else {
        puts "-I- reading connect_pg_net file from scripts"
        source -e -v scripts/flow/connect_pg_net.tcl
}

#------------------------------------------------------------------------------
#  save block
#------------------------------------------------------------------------------
save_block
create_frame \
	-merge_metal_blockage true \
	-block_all true \
	-remove_non_pin_shapes { {PO all} {M0 all} {VIA0 all} {M1 all} {VIA1 all} {M2 all} {VIA2 all} {M3 all} {VIA3 all} {M4 all} {VIA4 all} {M5 all} {VIA5 all} {M6 all} {VIA6 all} {M7 all} {VIA7 all} {M8 all} {VIA8 all} {M9 all} {VIA9 all} {M10 all} {VIA10 all} {M11 all} {VIA11 all} {M12 all} {VIA12 all} {M13 all} {VIA13 all} {M14 all} {VIA14 all} {M15 all} {VIA15 all} {M16 all} {VIA16 all} {M17 all} {VIA17 all} {M18 all} {VIA18 all}}

save_lib 

if {[info exists CREATE_ABSTRACT] && $CREATE_ABSTRACT == "true" } {
	#set_scenario_status [get_scenarios $ALL_SCENARIOS] -active true
	set_app_options -name abstract.annotate_power -value true
	create_abstract -read_only
#	create_frame -block_all true
}



write_verilog -compress gzip out/netlist/${DESIGN_NAME}.cts.v.gz
write_def -compress gzip -include_tech_via_definitions -include { cells ports pg_metal_fills blockages specialnets } -net_types { clock } out/def/${DESIGN_NAME}.cts.def

#    30/07/2025 Royl:  why removing ALL Metals from lef ??????????
#	set exclude_layers "\[get_layers -filter {name !~ 'M\d+$' || name > 'M${MAX_ROUTING_LAYER}'}\]"
#	set cmd "write_lef -include cell -exclude_layers $exclude_layers  out/lef/${DESIGN_NAME}.compile.lef"


	set cmd "write_lef -include cell  out/lef/${DESIGN_NAME}.compile.lef"

eval $cmd

if {[file exists ./scripts_local/post_cts_setting.tcl]} {
	puts "-I- reading post_cts_setting file from scripts_local"
	source -v -e ./scripts_local/post_cts_setting.tcl
} 

#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
eee "redirect -file ./reports/${STAGE}/report_threshold_voltage_group.rpt {report_threshold_voltage_group -nosplit \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group
eee "redirect -file ./reports/${STAGE}/report_vt_summary.rpt {report_threshold_voltage_group -nosplit -summary \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group_summary

redirect -file ./reports/$STAGE/report_congestion_summary.rpt {report_congestion -mode summary}	
redirect -tee -file ./reports/$STAGE/report_congestion {report_congestion -layers [get_layers -filter "layer_type==interconnect"] -nosplit}
write_app_options -output reports/${STAGE}/write_app_options.bin
printvar -user_defined > reports/$STAGE/printvar_user_defined.tcl
sh perl -p -i -e {s/(.*)=/set \1/} reports/$STAGE/printvar_user_defined.tcl

if {[regexp  "k8s" $env(HOST)] } {

	set DESCRIPTION "[string tolower [lindex [split [pwd] "/"] end]]_reports"
	echo "set STAGE $STAGE" > ${STAGE}_report_parallel.tcl
	echo "set FE_MODE $FE_MODE" >> ${STAGE}_report_parallel.tcl
	echo "set DESIGN_NAME $DESIGN_NAME" >> ${STAGE}_report_parallel.tcl
	echo "set PROJECT $PROJECT" >> ${STAGE}_report_parallel.tcl
	echo "set RUNNING_DIR [pwd]" >> ${STAGE}_report_parallel.tcl
	echo "read_app_options [pwd]/reports/${STAGE}/write_app_options.bin" >> ${STAGE}_report_parallel.tcl
#	echo "source [pwd]/reports/${STAGE}/printvar_user_defined.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/procs.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/ory_general_utils.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/oy_time.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/be_mails.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common_snps/be_reports.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/qor.generator.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/proc_qor.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/proc_histogram.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/be_report_io_fo.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/fc_be_checkers.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/fc_be_utils.tcl" >> ${STAGE}_report_parallel.tcl
	if {[file exists ./scripts_local/post_cts_setting.tcl]} {
		echo "source [pwd]/scripts_local/post_cts_setting.tcl" >> ${STAGE}_report_parallel.tcl
	} 
		
 	set REPORTS_MEMORY [expr 1.4 * $MEMORY]
	
	exec cp -pv ./scripts/flow/fc_reports_cts.tcl ./sourced_scripts/${STAGE}/.
 	report_parallel \
 		-work_directory reports/${STAGE}/parallel_run \
		-submit_command "./scripts/bin/pt_nextk8s.csh -cpu 16 -mem $REPORTS_MEMORY -pwd [pwd] -description ${DESCRIPTION} -label $LABEL"  \
		-max_cores 16 \
		-user_scripts [list "${STAGE}_report_parallel.tcl" "[which ./scripts/flow/fc_reports_cts.tcl]"]
		
		
} else {
	source -e -v ./scripts/flow/fc_reports_cts.tcl
}

#------------------------------------------------------------------------------
# create_lib
#------------------------------------------------------------------------------
if {[info exists CREATE_LIB] && $CREATE_LIB == "true"} {
        set_host_options -target PrimeTime -max_cores [expr round(double($CPU) / [sizeof_collection [all_scenarios ]])]
	echo "set STAGE $STAGE" > ./scripts_local/fc_pre_link_pt.tcl
	echo "set DESIGN_NAME $DESIGN_NAME" >> ./scripts_local/fc_pre_link_pt.tcl
	echo "set PROJECT $PROJECT" >> ./scripts_local/fc_pre_link_pt.tcl
	echo "set RUNNING_DIR [pwd]" >> ./scripts_local/fc_pre_link_pt.tcl
	echo "set OCV ${OCV}" >> ./scripts_local/fc_pre_link_pt.tcl
	echo "source [pwd]/scripts/setup/setup.${PROJECT}.tcl" >> ./scripts_local/fc_pre_link_pt.tcl
	
	set_pt_options \
		-pt_exec [sh which pt_shell] \
		-work_dir ETM_work_dir/${STAGE} \
		-post_link_script ./scripts/flow/fc_post_link_pt.tcl \
		-pre_link_script ./scripts_local/fc_pre_link_pt.tcl

	report_extract_model_options
	sh rm -rf ETM_work_dir/${STAGE}
        eee {extract_model -etm_lib_work_dir out/ETM_lib}
	file mkdir out/db/${STAGE}
	foreach_in_collection sss [all_scenarios] {
		set sss_name [get_object_name $sss]
		file copy -force ETM_work_dir/${STAGE}/DMSA/${sss_name}/${DESIGN_NAME}.lib out/db/${STAGE}/${DESIGN_NAME}_${sss_name}.lib
		file copy -force ETM_work_dir/${STAGE}/DMSA/${sss_name}/${DESIGN_NAME}_lib.db out/db/${STAGE}/${DESIGN_NAME}_${sss_name}_lib.db
	}

}



#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end

#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
} else {

   exit
  
}

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

set STAGE route

source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
if {![file exists ./reports/qor_data]} {exec mkdir -pv ./reports/qor_data}
if {![file exists ./reports/route]} {exec mkdir -pv ./reports/route}
if {![file exists ./reports/route/snapshots]} {exec mkdir -pv ./reports/route/snapshots}
if {![file exists ./reports/route_auto]} {exec mkdir -pv ./reports/route_auto}
if {![file exists ./reports/route_auto/snapshots]} {exec mkdir -pv ./reports/route_auto/snapshots}

exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.

set_host_options -max_cores $CPU
set_host_options -max_cores 8 -target StarRC

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
copy_block -from ${DESIGN_NAME}/cts -to ${DESIGN_NAME}/route -force
current_block ${DESIGN_NAME}/route
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
set QOR_STRATEGY_STAGE route
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
# pre route extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_route_setting.tcl]} {
	puts "-I- reading pre_route_setting file from scripts_local"
	source -v -e ./scripts_local/pre_route_setting.tcl
} 

#------------------------------------------------------------------------------
# clocks extra margin
#------------------------------------------------------------------------------
if {[info exists CLOCK_MARGIN] && $CLOCK_MARGIN == "true"} {
	if {![info exists UNCERTAINTY_MARGIN] || $UNCERTAINTY_MARGIN == ""} {
		puts "Error: clock extra margin was set, but no margin numbers exists. please set UNCERTAINTY_MARGIN list (NextSi-501)"
	} else {
		set EXTRA_MARGIN [lindex $UNCERTAINTY_MARGIN 2]
		puts "Information: setting extra margin of $EXTRA_MARGIN on all clock "
		file mkdir scripts_local/UNC_SDC
		set CS [current_scenario]
		foreach_in_collection sss [all_scenarios] {
			current_scenario $sss
	
			write_sdc -include clock_uncertainty -output scripts_local/UNC_SDC/UNC_${STAGE}_[get_object_name $sss].sdc -nosplit
			if {[file exists ./scripts_local/UNC_SDC/UNC_compile_[get_object_name $sss].sdc]} {
				set fid_in [open ./scripts_local/UNC_SDC/UNC_compile_[get_object_name $sss].sdc r]
			} elseif {[file exists ./scripts_local/UNC_SDC/UNC_cts_[get_object_name $sss].sdc]} {
				set fid_in [open ./scripts_local/UNC_SDC/UNC_cts_[get_object_name $sss].sdc r]
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


#------------------------------------------------------------------------------
## Pre-route_auto customizations
#------------------------------------------------------------------------------
set_app_options -name opt.common.user_instance_name_prefix -value route_auto_
#redirect -file reports/route_auto/set_stage.route {set_stage -step route -report}
#set_stage -step route
#check_stage_settings -stage pnr -metric timing -step route
redirect -file reports/route_auto/check_stage_settings {check_stage_settings -stage pnr -metric timing -step route}
redirect -file reports/route_auto/report_app_options.non_default_pre_route_auto.rpt {report_app_options -non_default}

#------------------------------------------------------------------------------
## route_auto 
#------------------------------------------------------------------------------
eee {route_auto}

if {[info exists DFM_REDUNDANT_VIA] && $DFM_REDUNDANT_VIA != "" && $ROUTE_DFM } {
	## Redundant via insertion
	puts "-I- Redundant via insertion"
	eee {add_redundant_vias}
}


## Run check_routes to save updated routing DRC to the block
redirect -tee -file reports/route_auto/check_routes {check_routes}

#------------------------------------------------------------------------------
#  Outputs 
#------------------------------------------------------------------------------

save_block -as ${DESIGN_NAME}/route_auto

#------------------------------------------------------------------------------
#  Report 
#------------------------------------------------------------------------------
write_qor_data -report_list "performance host_machine report_app_options" -label route_auto -output ./reports/qor_data

#------------------------------------------------------------------------------
# set_qor_strategy route auto
#------------------------------------------------------------------------------
set QOR_STRATEGY_STAGE post_route
if {[file exists scripts_local/fc_variables.tcl]} {
	puts "-I- reading fc_variables file from scripts_local"
	source -v -e scripts_local/fc_variables.tcl
} else {
	puts "-I- reading fc_variables file from scripts"
	source -v -e scripts/flow/fc_variables.tcl
}

#------------------------------------------------------------------------------
# pre route opt extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_route_opt_setting.tcl]} {
	puts "-I- reading pre_route_opt_setting file from scripts_local"
	source -v -e ./scripts_local/pre_route_opt_setting.tcl
} 


#------------------------------------------------------------------------------
#  Pre-route_opt customizations
#------------------------------------------------------------------------------
#redirect -file reports/route/set_stage.route {set_stage -step post_route -report}
#set_stage -step post_route
set_app_options -name opt.common.user_instance_name_prefix -value route_opt_
set_app_options -name cts.common.user_instance_name_prefix -value route_opt_cts_


## StarRC in-design extraction (optional) : a config file is required to set up a proper StarRC run
if {[info exists STARRC_INDESIGN] && $STARRC_INDESIGN == "true"} {
	file copy -force ./scripts/do_starrc.cmd ./scripts_local/
	sh perl -p -i -e 's/NUM_CORES/* NUM_CORES/' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/STARRC_DP_STRING/* STARRC_DP_STRING/' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/CORNERS_FILE/* CORNERS_FILE/' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/SELECTED_CORNERS/* SELECTED_CORNERS/' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/GPD/* GPD/' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/.*DESIGN_NAME/* /' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/.*NO_EXTRA_LOOPS/* /' scripts_local/do_starrc.cmd
	set cmd "sh perl -p -i -e 's#TECHNOLOGY_LAYER_MAP#$TECHNOLOGY_LAYER_MAP#' scripts_local/do_starrc.cmd"
	eval $cmd
	set cmd "sh perl -p -i -e 's#STREAM_LAYER_MAP_FILE#$STREAM_LAYER_MAP_FILE#' scripts_local/do_starrc.cmd"
	eval $cmd
	foreach sss $STREAM_FILE_LIST {
		echo "OASIS_FILE: $sss" >> scripts_local/do_starrc.cmd
	}
	

        echo "SIGNOFF_IMAGE:  [sh which StarXtract]" > ./scripts_local/starrc_indesign.cfg
        echo "COMMAND_FILE:      [pwd]/scripts_local/do_starrc.cmd" >> ./scripts_local/starrc_indesign.cfg
        echo "CORNER_GRD_FILE: [pwd]/scripts_local/starrc_indesign.smc" >> ./scripts_local/starrc_indesign.cfg

        file delete scripts_local/starrc_indesign.smc
        foreach_in_collection ccc [all_corners] {
               	regexp {.*_FF_(.*)_(\d*)_\d$} [get_object_name $ccc] match rc temp
               	echo "[get_object_name $ccc] $rc_corner($rc,nxtgrd)" >> ./scripts_local/starrc_indesign.smc
        }



#	set_host_options -target StarRC -work_dir WORK_STARRC -name STARRC_HOST\
#		-num_processes 4 \
#            	-max_cores 8 \
#            	-submit_protocol custom \
#            	-submit_command  "[pwd]/scripts/bin/k8s_fmdpx.sh -CPU 8 -MEMORY 50 -LABEL $LABEL"
	
	set_app_options -name extract.starrc_mode -value in_design
	
	set_starrc_in_design -config ./scripts_local/starrc_indesign.cfg -mode starrc_centric -reduction no_extra_loops
	report_starrc_in_design
	
}


#redirect -file reports/route/check_stage_settings {check_stage_settings -stage pnr -metric timing -step post_route}

#------------------------------------------------------------------------------
#  route_opt flow
#------------------------------------------------------------------------------
if {[get_drc_error_data -quiet zroute.err] == ""} {open_drc_error_data zroute.err}
set rm_drc_before_corecmd [sizeof_collection [get_drc_errors -quiet -error_data zroute.err]]

compute_clock_latency

if {!$ENABLE_ROUTE_OPT_PBA} {
	set_app_options -name time.pba_optimization_mode -value none
}

redirect -file reports/route/report_app_options.non_default_pre_route_opt.rpt {report_app_options -non_default}

#------------------------------------------------------------------------------
#   hyper_route_opt
#------------------------------------------------------------------------------

eee {hyper_route_opt}


#------------------------------------------------------------------------------
#  Incremental route_detail for fixing routing DRCs
#------------------------------------------------------------------------------
if {[get_drc_error_data -quiet zroute.err] == ""} {open_drc_error_data zroute.err}
set rm_drc_after_corecmd [sizeof_collection [get_drc_errors -quiet -error_data zroute.err]]

if { [info exists rm_drc_before_corecmd] && [info exists rm_drc_after_corecmd] } {
	set incr_route_detail_cmd "route_detail -incremental true -initial_drc_from_input true"
	if { ($rm_drc_after_corecmd > $rm_drc_before_corecmd) && \
	     ($rm_drc_before_corecmd < 10000 ) && \
	     ($rm_drc_after_corecmd > 50 ) && \
	     ([expr (${rm_drc_after_corecmd}-${rm_drc_before_corecmd})] > [expr (0.1*${rm_drc_before_corecmd})]) } {
		puts "RM-info : INCR_ROUTE_DETAIL_MODE = auto and conditions are met. Running $incr_route_detail_cmd"	
		eval $incr_route_detail_cmd
	}
}

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

## Run check_routes to save updated routing DRC to the block
redirect -tee -file reports/route/check_routes {check_routes}
#------------------------------------------------------------------------------
#  Outputs 
#------------------------------------------------------------------------------

save_block 
create_frame \
	-merge_metal_blockage true \
	-block_all true \
	-remove_non_pin_shapes { {PO all} {M0 all} {VIA0 all} {M1 all} {VIA1 all} {M2 all} {VIA2 all} {M3 all} {VIA3 all} {M4 all} {VIA4 all} {M5 all} {VIA5 all} {M6 all} {VIA6 all} {M7 all} {VIA7 all} {M8 all} {VIA8 all} {M9 all} {VIA9 all} {M10 all} {VIA10 all} {M11 all} {VIA11 all} {M12 all} {VIA12 all} {M13 all} {VIA13 all} {M14 all} {VIA14 all} {M15 all} {VIA15 all} {M16 all} {VIA16 all} {M17 all} {VIA17 all} {M18 all} {VIA18 all}}

if {[info exists CREATE_ABSTRACT] && $CREATE_ABSTRACT == "true" } {
	#set_scenario_status [get_scenarios $ALL_SCENARIOS] -active true
	set_app_options -name abstract.annotate_power -value true
	create_abstract -read_only
#	create_frame -block_all true
}
save_lib 

write_verilog -compress gzip out/netlist/${DESIGN_NAME}.route.v.gz
write_def -compress gzip -include_tech_via_definitions -include { cells ports pg_metal_fills blockages specialnets nets routing_rules} out/def/${DESIGN_NAME}.route.def

#    30/07/2025 Royl:  why removing ALL Metals from lef ??????????
#	set exclude_layers "\[get_layers -filter {name !~ 'M\d+$' || name > 'M${MAX_ROUTING_LAYER}'}\]"
#	set cmd "write_lef -include cell -exclude_layers $exclude_layers  out/lef/${DESIGN_NAME}.compile.lef"


	set cmd "write_lef -include cell  out/lef/${DESIGN_NAME}.compile.lef"
eval $cmd

if {[file exists ./scripts_local/post_route_setting.tcl]} {
	puts "-I- reading post_route_setting file from scripts_local"
	source -v -e ./scripts_local/post_route_setting.tcl
} 


#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
eee "redirect -file ./reports/${STAGE}/report_threshold_voltage_group.rpt {report_threshold_voltage_group -nosplit \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group
eee "redirect -file ./reports/${STAGE}/report_vt_summary.rpt {report_threshold_voltage_group -nosplit -summary \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group_summary

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
	echo "source [pwd]/scripts/procs/fc_shell/user_report_inst_vt.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/multiport_checker.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/fc_be_checkers.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/fc_be_utils.tcl" >> ${STAGE}_report_parallel.tcl
	if {[file exists ./scripts_local/post_route_setting.tcl]} {
		echo "source [pwd]/scripts_local/post_route_setting.tcl" >> ${STAGE}_report_parallel.tcl
	} 

 	set REPORTS_MEMORY [expr 1.4 * $MEMORY]
	
	exec cp -pv ./scripts/flow/fc_reports_route.tcl ./sourced_scripts/${STAGE}/.
 	report_parallel \
 		-work_directory reports/${STAGE}/parallel_run \
		-submit_command "./scripts/bin/pt_nextk8s.csh -cpu 16 -mem $REPORTS_MEMORY -pwd [pwd] -description ${DESCRIPTION} -label $LABEL"  \
		-max_cores 16 \
		-user_scripts [list "${STAGE}_report_parallel.tcl" "[which ./sourced_scripts/${STAGE}/fc_reports_route.tcl]"]


} else {
	source -e -v ./scripts/flow/fc_reports_route.tcl
}

#------------------------------------------------------------------------------
# create_lib
#------------------------------------------------------------------------------
if {[info exists CREATE_LIB] && $CREATE_LIB == "true"} {
        set_host_options -target PrimeTime -max_cores [expr round(double($CPU) / [sizeof_collection [all_scenarios ]])]


	file copy -force ./scripts/do_starrc.cmd ./scripts_local/
	sh perl -p -i -e 's/NUM_CORES/* NUM_CORES/' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/STARRC_DP_STRING/* STARRC_DP_STRING/' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/CORNERS_FILE/* CORNERS_FILE/' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/SELECTED_CORNERS/* SELECTED_CORNERS/' scripts_local/do_starrc.cmd
	sh perl -p -i -e 's/GPD/* GPD/' scripts_local/do_starrc.cmd
	set cmd "sh perl -p -i -e 's#TECHNOLOGY_LAYER_MAP#$TECHNOLOGY_LAYER_MAP#' scripts_local/do_starrc.cmd"
	eval $cmd
	set cmd "sh perl -p -i -e 's#STREAM_LAYER_MAP_FILE#$STREAM_LAYER_MAP_FILE#' scripts_local/do_starrc.cmd"
	eval $cmd
	foreach sss $STREAM_FILE_LIST {
		echo "OASIS_FILE: $sss" >> scripts_local/do_starrc.cmd
	}
	

        echo "SIGNOFF_IMAGE:  [sh which StarXtract]" > ./scripts_local/starrc_indesign.cfg
        echo "COMMAND_FILE:      [pwd]/scripts_local/do_starrc.cmd" >> ./scripts_local/starrc_indesign.cfg
        echo "CORNER_GRD_FILE: [pwd]/scripts_local/starrc_indesign.smc" >> ./scripts_local/starrc_indesign.cfg


	file delete scripts_local/starrc_indesign.smc
	foreach_in_collection ccc [all_corners] {
		regexp {.*_FF_(.*)_(\d*)_\d$} [get_object_name $ccc] match rc temp
		echo "[get_object_name $ccc] $rc_corner($rc,nxtgrd)" >> ./scripts_local/starrc_indesign.smc
	}
	
	set_app_options -name extract.starrc_mode -value in_design
	set_starrc_options -config ./scripts_local/starrc_indesign.cfg
	set_extract_model_options \
		-extract_model_with_clock_latency_arcs true \
		-extract_model_clock_latency_arcs_include_all_registers true

	
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
#write_qor_data -report_list "performance host_machine report_app_options" -label route -output ./reports/qor_data

report_msg -summary
print_message_info -ids * -summary


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


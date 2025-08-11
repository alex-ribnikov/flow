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

set STAGE place

source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
if {![file exists ./reports/${STAGE}]} {exec mkdir -pv ./reports/${STAGE}}
if {![file exists ./reports/qor_data]} {exec mkdir -pv ./reports/qor_data}
if {![file exists ./reports/${STAGE}/snapshots]} {exec mkdir -pv ./reports/${STAGE}/snapshots}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}

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

if {[info exists INC_INIT] && $INC_INIT} {
	copy_block -from ${DESIGN_NAME}/inc_init -to ${DESIGN_NAME}/place -force
} else {
	copy_block -from ${DESIGN_NAME}/compile -to ${DESIGN_NAME}/place -force
}
current_block ${DESIGN_NAME}/place
link_block

#------------------------------------------------------------------------------
# unplaced macros/ports checking 
#------------------------------------------------------------------------------
set size_unplaced_port [sizeof_collection [get_ports -filter {port_type==signal&&physical_status==unplaced}]]
if {$size_unplaced_port} {
	puts "ERROR: unplaced ports ...\nreport file saved: unplaced_ports.rpt"	
	redirect -file check_unplaced_ports.rpt {get_attribute [get_ports -filter {port_type==signal&&physical_status==unplaced}] name }
	exit 1
}
set size_unplaced_macro [sizeof_collection [get_cells -hierarchical -filter {is_hard_macro && physical_status == unplaced}]]
if {$size_unplaced_macro} {
	puts "ERROR: unplaced macros found ...\nreport file saved: unplaced_macro.rpt"
	redirect -file unplaced_macros.rpt {get_attribute [get_cells -hierarchical -filter {is_hard_macro && physical_status == unplaced}] full_name}
	exit 1	
}
#------------------------------------------------------------------------------
# starting from netlist
#------------------------------------------------------------------------------

if {[info exists INC_INIT] && $INC_INIT} {

	#------------------------------------------------------------------------------
	# run multi corner multi mode definition
	#------------------------------------------------------------------------------
	source scripts/flow/snps_mmmc_create.tcl
	mmmc_create

	source -e -v $mmmc_results

	foreach scenario $scenarios(setup) {
		set_scenario_status $scenario -active true -setup true -max_transition true -max_capacitance true
	}
	foreach scenario $scenarios(hold) {
		set_scenario_status $scenario -active true -hold true -max_transition true -max_capacitance true
	}
	foreach scenario $scenarios(dynamic) {
		set_scenario_status $scenario -active true -dynamic_power true 
	}
	foreach scenario $scenarios(leakage) {
		set_scenario_status $scenario -active true -leakage_power true 
	}
	redirect -file ./reports/${STAGE}/report_scenarios.rpt {report_scenarios}

	set_app_options -name  cts.compile.primary_corner 	-value [get_attribute [get_scenarios ${DEFAULT_CCOPT_VIEW}*] corner.name]
	set_app_options -name  ccd.reference_corner          	-value [get_attribute [get_scenarios ${DEFAULT_CCOPT_VIEW}*] corner.name]

	#------------------------------------------------------------------------------
	# clocks related to io
	#------------------------------------------------------------------------------
	set CCC [get_attribute [get_clocks -filter "name !~ virtual*"] name]
	set VCCC [get_attribute [get_clocks -filter "name =~ virtual*"] name]
	if {[llength $CCC] == 1} {
		puts "-I- only one internal clock for IO latency_adjustment"
		set_latency_adjustment_options -reference_clock $CCC -clocks_to_update $VCCC
	} else {
		foreach CLOCK $CCC {
			set VCLOCK [get_attribute [ get_clocks -quiet virtual_${CLOCK}] name]
			if {$VCLOCK != ""} {
				set_latency_adjustment_options -reference_clock $CLOCK -clocks_to_update $VCLOCK
				set VCCC [lreplace  $VCCC [lsearch $VCCC $VCLOCK] [lsearch $VCCC $VCLOCK]]
			}
		}
		if {[llength $VCCC] > 0} {
			puts "Warning: the following virtual clocks not defined for IO latency_adjustment"
		}
	}

	#------------------------------------------------------------------------------
	# group_path
	#------------------------------------------------------------------------------
	set mems [get_flat_cells -quiet -filter "design_type==macro"]

	set current_scenario_saved [current_scenario]

	foreach_in_collection  scenario [get_scenarios -filter active] {
		current_scenario ${scenario}
		if {[file exists scripts_local/group_path.tcl]} {
			puts "-I- reading extra group path from file scripts_local/group_path.tcl for scenario [get_object_name $scenario]"
			source  -e -v scripts_local/group_path.tcl
		}
	}
	current_scenario ${current_scenario_saved}

	#------------------------------------------------------------------------------
	# OCV
	#------------------------------------------------------------------------------

	if {[info exists OCV] && $OCV == "pocv"} {
		#  refernce
		#/bespace/users/royl/deliveries/from_snps/CBU_power_run_TC_2024099_334138/inputs/TCL_POCV_SETUP_FILE.tcl
		puts "-I- setting POCV"
		set CC [current_corner]
		set_pocvm_corner_sigma -corners [get_corners *FF*] 4.5
		set_pocvm_corner_sigma -corners [get_corners *SS*] 3.0
		unset -nocomplain TEV_OP_MODE
		define_user_attribute -type boolean -classes lib_cell -name brcm_has_lvf

        	foreach_in_collection CCC [all_corners] { 
			current_corner $CCC
			set corner_name [get_object_name $CCC]
			regsub {SS\S+} [regsub {FF\S+} [get_object_name $CCC] "FF"] "SS"  pvt
			set TEV_OP_MODE [lindex [split $pvt "_"] end]
		
			if { [info exists pvt_corner($pvt,pt_pocv)]} {
    				foreach pocvm_file $pvt_corner($pvt,pt_pocv) {
    					puts "-I- reading OCVM file: $pocvm_file"
        				read_ocvm $pocvm_file
    				}
			}
			if { [info exists pvt_corner($pvt,pt_ocv)]} {
    				foreach pocvm_file $pvt_corner($pvt,pt_ocv) {
					puts "-I- reading derate file: $pocvm_file"
					set file_to_read $pocvm_file
    					if {![catch {sh  grep set_app_var $pocvm_file}]} {
						set new_name [lindex [split  $pocvm_file "/"] end]
						if { ! [file exists derate]} {sh mkdir derate}
						sh grep -v set_app_var $pocvm_file | grep -v set_noise_parameters > derate/$new_name
						set file_to_read ./derate/$new_name
					}
    					if {![catch {sh  grep report_ocvm $pocvm_file}]} {
						set new_name [lindex [split  $pocvm_file "/"] end]
						if { ! [file exists derate]} {sh mkdir derate}
						sh cat $pocvm_file | perl -pe 's/report_ocvm -type pocv -coefficient/report_ocvm -type pocv -corner $corner_name/' | perl -pe 's/set_user_attribute/set_attribute/' > derate/${corner_name}_${new_name}
						set file_to_read ./derate/${corner_name}_$new_name
					}
				
        				source -e -v $file_to_read
    				}
			}
			unset -nocomplain TEV_OP_MODE
			report_ocvm -type pocvm > reports/${STAGE}/report_ocvm.${pvt}.rpt

	
		   	# Source additional user derates
		   	if { [file exists ./scripts_local/user_derates.tcl] } { 
				puts "-I- Source user_derates.tcl"
				source -v -e ./scripts_local/user_derates.tcl
		   	}

		}
		current_corner $CC
	} elseif {[info exists OCV] && $OCV == "flat" } {
		puts "-I- setting OCV to flat ocv"
		set CS [current_corner]
        	foreach_in_collection AC [all_corners] {
		    current_corner [get_object_name $AC]
#		    set mode  [lindex [split [get_object_name $AC] "_"] 0]
#		    set check [lindex [split [get_object_name $AC] "_"] end]
#		    regsub "${mode}_(.*)_${check}" [get_object_name $AC] {\1} sub_pvt
		    regexp {(.*[SF])_(.*)} [get_object_name $AC] match PVT rc
	    
		    if {[info exists pvt_corner($PVT,flat_mem_ocv)] && [llength $pvt_corner($PVT,flat_mem_ocv)] == 2} {
		        if {[sizeof_collection [get_cells -quiet -hier -filter "is_hierarchical == false && is_hard_macro == true"]] > 0} {
		     	   puts "-I- setting flat OCV check and data for corner [get_object_name $AC] on memories"
		     	   set_timing_derate -late  [lindex $pvt_corner($PVT,flat_mem_ocv) 0 0] -cell_check  [get_lib_cells -of_objects [get_flat_cells -filter "is_hard_macro" ]]
		     	   set_timing_derate -early [lindex $pvt_corner($PVT,flat_mem_ocv) 0 1] -cell_check  [get_lib_cells -of_objects [get_flat_cells -filter "is_hard_macro" ]]
		     	   set_timing_derate -late  [lindex $pvt_corner($PVT,flat_mem_ocv) 1 0] -data 		[get_lib_cells -of_objects [get_flat_cells -filter "is_hard_macro" ]]
		     	   set_timing_derate -early [lindex $pvt_corner($PVT,flat_mem_ocv) 1 1] -data 		[get_lib_cells -of_objects [get_flat_cells -filter "is_hard_macro" ]]
		        }
		    }
		    if {[info exists pvt_corner($PVT,flat_ocv)] && [llength $pvt_corner($PVT,flat_ocv)] == 2} {
		        puts "-I- setting flat OCV clock and data for corner [get_object_name $AC]"
		        set_timing_derate -late  [lindex $pvt_corner($PVT,flat_ocv) 0 0] -clock 
		        set_timing_derate -early [lindex $pvt_corner($PVT,flat_ocv) 0 1] -clock 
		        set_timing_derate -late  [lindex $pvt_corner($PVT,flat_ocv) 1 0] -data  
		        set_timing_derate -early [lindex $pvt_corner($PVT,flat_ocv) 1 1] -data  
		    } elseif {[info exists pvt_corner($PVT,flat_ocv)] && [llength $pvt_corner($PVT,flat_ocv)] == 1} {
		        puts "-I- setting flat OCV clock only for corner [get_object_name $AC]"
		        set_timing_derate -late  [lindex $pvt_corner($PVT,flat_ocv) 0] -clock 
		        set_timing_derate -early [lindex $pvt_corner($PVT,flat_ocv) 1] -clock 
		    } else {
		        puts "-W- missing derate values for corner $PVT"
		    }
		}
		current_corner $CS
	}

	#------------------------------------------------------------------------------
	# max transition and IO RC
	#------------------------------------------------------------------------------
	set CM [current_mode]

	foreach_in_collection mmm [all_modes] {
		current_mode $mmm
		set_max_transition 0.2 [current_design]
		foreach_in_collection ccc [all_clocks] {
			if {[get_attribute $ccc is_virtual] } {
				puts "-I- clock [get_object_name $ccc] is virtual"
				set out_ports [get_ports -filter "related_clock == [get_object_name $ccc] && direction == out"]
				if {[sizeof_collection $out_ports ] > 0 } {
#					set_max_transition [expr [get_attribute $ccc period] * 0.22] $ccc -data_path -corners [all_corners] [get_ports $out_ports]
				}
			} else {
				if {[llength [get_attribute -quiet $ccc period]] > 0} {
					set_max_transition [expr [get_attribute $ccc period] * 0.11] $ccc -clock_path -corners [all_corners]
					set_max_transition [expr [get_attribute $ccc period] * 0.22] $ccc -data_path  -corners [all_corners]
				} else {
					puts "Warning: clock [get_object_name $ccc] does not have period defined !!!!!! "
				}
			}
		}
	}
	
	current_mode $CM
	set input_ports  [remove_from_collection [all_inputs ] [get_attribute [all_clocks] sources -quiet]]
	set_driving_cell -scenarios [all_scenarios] \
		-lib_cell  [lindex $OUT_BUFFER_CELL 0] -pin o $input_ports


}

if {[info exists USE_ABSTRACTS_FOR_BLOCKS] && $USE_ABSTRACTS_FOR_BLOCKS != ""} {
		puts "-I- Swapping { $USE_ABSTRACTS_FOR_BLOCKS } blocks for abstracts to design view for all blocks"
		change_abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label $STAGE -view abstract
		report_abstracts
}



#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
set QOR_STRATEGY_STAGE compile_initial
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
# star from initial_place for DFT netlist
#------------------------------------------------------------------------------

if {[info exists INC_INIT] && $INC_INIT} {
	#------------------------------------------------------------------------------
	# pre place extra setting script
	#------------------------------------------------------------------------------
	if {[file exists ./scripts_local/pre_initial_place_setting.tcl]} {
		puts "-I- reading pre_initial_place_setting file from scripts_local"
		source -v -e ./scripts_local/pre_initial_place_setting.tcl
	}

	set_app_options -list {design.enable_rule_based_query false}
	redirect -file reports/${STAGE}/report_app_options.non_default_pre_initial_place.rpt {report_app_options -non_default}

	eee {compile_fusion -from initial_place -to initial_place}
	eee {compile_fusion -from initial_opto  -to initial_opto -incremental}

	report_qor -summary
}

#------------------------------------------------------------------------------
# star from initial_place for DFT netlist
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
set QOR_STRATEGY_STAGE compile_final_place
if {[file exists scripts_local/fc_variables.tcl]} {
	puts "-I- reading fc_variables file from scripts_local"
	source -v -e scripts_local/fc_variables.tcl
} else {
	puts "-I- reading fc_variables file from scripts"
	source -v -e scripts/flow/fc_variables.tcl
}

#------------------------------------------------------------------------------
# pre place extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_place_setting.tcl]} {
	puts "-I- reading pre_place_setting file from scripts_local"
	source -v -e ./scripts_local/pre_place_setting.tcl
} 

set_app_options -list {design.enable_rule_based_query false}

redirect -file reports/${STAGE}/report_app_options.non_default_pre_final_place.rpt {report_app_options -non_default}
eee {compile_fusion -from final_place -to final_place}
save_block -as ${DESIGN_NAME}/final_place
eee {compile_fusion -from final_opto -to final_opto}
#save_block -as ${DESIGN_NAME}/final_opto

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
# save stage
#------------------------------------------------------------------------------
set_svf -off

save_block
create_frame \
	-merge_metal_blockage true \
	-block_all true \
	-remove_non_pin_shapes { {PO all} {M0 all} {VIA0 all} {M1 all} {VIA1 all} {M2 all} {VIA2 all} {M3 all} {VIA3 all} {M4 all} {VIA4 all} {M5 all} {VIA5 all} {M6 all} {VIA6 all} {M7 all} {VIA7 all} {M8 all} {VIA8 all} {M9 all} {VIA9 all} {M10 all} {VIA10 all} {M11 all} {VIA11 all} {M12 all} {VIA12 all} {M13 all} {VIA13 all} {M14 all} {VIA14 all} {M15 all} {VIA15 all} {M16 all} {VIA16 all} {M17 all} {VIA17 all} {M18 all} {VIA18 all}}


save_lib

write_verilog -compress gzip out/netlist/${DESIGN_NAME}.place.v.gz
write_def -compress gzip -include_tech_via_definitions -include { cells ports pg_metal_fills blockages } out/def/${DESIGN_NAME}.place.def

#    30/07/2025 Royl:  why removing ALL Metals from lef ??????????
#	set exclude_layers "\[get_layers -filter {name !~ 'M\d+$' || name > 'M${MAX_ROUTING_LAYER}'}\]"
#	set cmd "write_lef -include cell -exclude_layers $exclude_layers  out/lef/${DESIGN_NAME}.compile.lef"


	set cmd "write_lef -include cell  out/lef/${DESIGN_NAME}.compile.lef"

eval $cmd


report_qor -summary


set parallel_execute_cmd "parallel_execute -commands_only \[list\n"
set parallel_execute_cmd "${parallel_execute_cmd}write_verilog  -hierarchy all -compress gzip  -exclude {scalar_wire_declarations leaf_module_declarations pg_objects end_cap_cells well_tap_cells filler_cells pad_spacer_cells physical_only_cells cover_cells flip_chip_pad_cells}   ./out/netlist/${DESIGN_NAME}_${STAGE}.v.gz\n"
set parallel_execute_cmd "${parallel_execute_cmd}\]"
eval ${parallel_execute_cmd}


#------------------------------------------------------------------------------
# Create abstract and frame
#------------------------------------------------------------------------------
if {[info exists CREATE_ABSTRACT] && $CREATE_ABSTRACT == "true" } {
	#set_scenario_status [get_scenarios $ALL_SCENARIOS] -active true
	set_app_options -name abstract.annotate_power -value true
	create_abstract -read_only
#	create_frame -block_all true
}

if {[file exists ./scripts_local/post_place_setting.tcl]} {
	puts "-I- reading post_place_setting file from scripts_local"
	source -v -e ./scripts_local/post_place_setting.tcl
} 


#------------------------------------------------------------------------------
# reports 
#------------------------------------------------------------------------------
eee "redirect -file ./reports/${STAGE}/report_threshold_voltage_group.rpt {report_threshold_voltage_group -nosplit \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group
eee "redirect -file ./reports/${STAGE}/report_vt_summary.rpt {report_threshold_voltage_group -nosplit -summary \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group_summary
redirect -file ./reports/${STAGE}/report_congestion_summary.rpt {report_congestion -mode summary}
eee "redirect -tee -file ./reports/${STAGE}/report_congestion.rpt {report_congestion -layers [get_layers -filter "layer_type==interconnect"] -rerun_global_router -nosplit}" ./reports/${STAGE}/runtime.txt report_congestion
write_app_options -output reports/${STAGE}/write_app_options.bin
printvar -user_defined > reports/$STAGE/printvar_user_defined.tcl
sh perl -p -i -e {s/(.*)=/set \1/} reports/$STAGE/printvar_user_defined.tcl


if {[regexp  "k8s" $env(HOST)]} {
		

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
	if {[file exists scripts_local/post_place_setting.tcl]} {
		echo "source [pwd]/scripts_local/post_place_setting.tcl" >> ${STAGE}_report_parallel.tcl
	}	
 	set REPORTS_MEMORY [expr 1.4 * $MEMORY]
	
	exec cp -pv ./scripts/flow/fc_reports_place.tcl ./sourced_scripts/${STAGE}/.
 	report_parallel \
 		-work_directory reports/${STAGE}/parallel_run \
		-submit_command "./scripts/bin/pt_nextk8s.csh -cpu 8 -mem $REPORTS_MEMORY -pwd [pwd] -description ${DESCRIPTION} -label $LABEL"  \
		-max_cores 8 \
		-user_scripts [list "${STAGE}_report_parallel.tcl" "[which ./scripts/flow/fc_reports_place.tcl]"]

} else {
	source -e -v ./scripts/flow/fc_reports_place.tcl
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

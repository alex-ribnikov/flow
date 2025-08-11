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

set STAGE compile

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
copy_block -from ${DESIGN_NAME}/init -to ${DESIGN_NAME}/compile -force
current_block ${DESIGN_NAME}/compile
link_block

#remove error data from db
remove_drc_error_data [get_drc_error_data -all] -force

#------------------------------------------------------------------------------
# hierarchical flow
#------------------------------------------------------------------------------
if {[info exists USE_ABSTRACTS_FOR_BLOCKS] && $USE_ABSTRACTS_FOR_BLOCKS != ""} {
		puts "-I- Swapping { $USE_ABSTRACTS_FOR_BLOCKS } blocks for abstracts to design view for all blocks"
		change_abstract -references $USE_ABSTRACTS_FOR_BLOCKS -label $STAGE -view abstract
		report_abstracts
}
if {[info exists USE_ETM_FOR_BLOCKS] && $USE_ETM_FOR_BLOCKS != ""} {
	foreach bbb $USE_ETM_FOR_BLOCKS {
		puts "-I- getting   mode for  { $bbb } etm "
		unset -nocomplain mmm
		redirect -variable rrr {report_cell_mode $bbb -nosplit}
		foreach line [split $rrr "\n"] {
			if {[string match "*$bbb*" $line]} {
				regexp  {\y(func\w*)\y} $line  match mmm
			}
		}
		if {[info exists mmm]} {
			puts "-I- setting $mmm  mode for  { $bbb } etm "
			set_cell_mode $mmm $bbb
			report_cell_mode $bbb -nosplit
		}		
	}
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
# clocks extra margin
#------------------------------------------------------------------------------
if {[info exists CLOCK_MARGIN] && $CLOCK_MARGIN == "true"} {
	if {![info exists UNCERTAINTY_MARGIN] || $UNCERTAINTY_MARGIN == ""} {
		puts "Error: clock extra margin was set, but no margin numbers exists. please set UNCERTAINTY_MARGIN list (NextSi-101)"
	} else {
		set EXTRA_MARGIN [expr [lindex $UNCERTAINTY_MARGIN 0] + [lindex $UNCERTAINTY_MARGIN 1] +[lindex $UNCERTAINTY_MARGIN 2]]
		puts "Information: setting extra margin of $EXTRA_MARGIN on all clock "
		file mkdir scripts_local/UNC_SDC
		set CS [current_scenario]
		foreach_in_collection sss [all_scenarios] {
			current_scenario $sss
	
			write_sdc -include clock_uncertainty -output scripts_local/UNC_SDC/UNC_${STAGE}_[get_object_name $sss].sdc -nosplit
			set fid_in [open ./scripts_local/UNC_SDC/UNC_${STAGE}_[get_object_name $sss].sdc r]
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
#	set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
#	remove_path_groups -all
#	group_path -name in2reg  -to    [all_registers -data_pins]    -from [remove_from_collection [all_inputs] ${ports_clock_root}] 
#	group_path -name in2out  -from  [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
#	group_path -name reg2reg -from  [all_registers -clock_pins ]  -to [all_registers -data_pins ] -weight 100 -critical_range 100
#	group_path -name reg2out -from  [all_registers -clock_pins ]  -to [all_outputs ]
#	if {[sizeof_collection $mems] > 0 } {
#
#		puts "-I- mem2reg"
#		group_path -name mem2reg -from [get_pins -of_objects $mems -filter "is_clock_pin == true"] -to [all_registers]
#		
#		puts "-I- mem2out"
#		group_path -name mem2out -from [get_pins -of_objects $mems -filter "is_clock_pin == true"] -to [all_outputs]
#		
#		puts "-I- reg2mem"
#		group_path -name reg2mem   -from [all_registers] -to [get_pins -of_objects $mems -filter {direction=~ in}]
#		
#		puts "-I- in2mem"	  
#		group_path -name in2mem   -from [all_inputs] -to [get_pins -of_objects $mems -filter {direction=~ in}]
#	}
	if {[file exists scripts_local/group_path.tcl]} {
		puts "-I- reading extra group path from file scripts_local/group_path.tcl for scenario [get_object_name $scenario]"
		source  -e -v scripts_local/group_path.tcl
	}
}
current_scenario ${current_scenario_saved}



# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -outputs
set_fix_multiple_port_nets -all -buffer_constants

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
#	    set mode  [lindex [split [get_object_name $AC] "_"] 0]
#	    set check [lindex [split [get_object_name $AC] "_"] end]
#	    regsub "${mode}_(.*)_${check}" [get_object_name $AC] {\1} sub_pvt
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
#				set_max_transition [expr [get_attribute $ccc period] * 0.22] $ccc -data_path -corners [all_corners] [get_ports $out_ports]
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

set input_ports  [remove_from_collection [all_inputs ] [get_attribute [all_clocks] sources -quiet]]
set_driving_cell -scenarios [all_scenarios] \
	-lib_cell  [lindex $OUT_BUFFER_CELL 0] -pin o $input_ports



current_mode $CM

########################################################################
## clock NDR
########################################################################
#rm_source -file $TCL_CTS_NDR_RULE_FILE -optional -print "TCL_CTS_NDR_RULE_FILE"
#redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_routing_rules {report_routing_rules -verbose}
#redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_routing_rules {report_clock_routing_rules}
#redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_settings {report_clock_settings}


#------------------------------------------------------------------------------
#  setting
#------------------------------------------------------------------------------

set rm_lib_type [get_attribute -quiet [current_design] rm_lib_type]

## set_stage : a command to apply stage-based application options; intended to be used after set_qor_strategy within RM scripts.
# 04/02/2025 Royl: legacy 
#redirect -file reports/compile/set_stage.synthesis {set_stage -step synthesis -report}
#set_stage -step synthesis

## Prefix
set_app_options -name opt.common.user_instance_name_prefix -value compile_
set_app_options -name cts.common.user_instance_name_prefix -value compile_cts_

#redirect -file reports/compile/check_stage_settings {check_stage_settings -stage synthesis -metric timing -step synthesis}

#TBD roy 01122024
#/bespace/users/royl/deliveries/from_snps/CBU_power_run_TC_2024099_334138/baseline20_SCO_power/rm_user_plugin_scripts/compile_pre_script.tcl


#------------------------------------------------------------------------------
# pre compile extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_compile_setting.tcl]} {
	puts "-I- reading pre_compile_setting file from scripts_local"
	source -v -e ./scripts_local/pre_compile_setting.tcl
} 

#------------------------------------------------------------------------------
# clock gating latency
#------------------------------------------------------------------------------
set CS [current_scenario ]
foreach_in_collection AC [get_scenarios *SS*] {
	current_scenario $AC
	set cmd "set_clock_gate_latency -stage 1 -fanout_latency {{ 1-inf ${CLOCK_GATING_SETUP} }}"
#	eval $cmd
	set cmd "set_clock_gate_latency -stage 2 -fanout_latency {{ 1-inf ${CLOCK_GATING_SETUP} }}"
#	eval $cmd
	set cmd "set_clock_gate_latency -stage 0 -fanout_latency {{ 1-inf 0 }}"
#	eval $cmd
}
current_scenario $CS

# 12/03/2025 Roy: found duplicate shapes not exists in init
check_duplicates -remove 

if {[info exists FE_MODE] && $FE_MODE} {
	set bcg_cg_pins [get_pins -of [get_flat_cells -filter {is_integrated_clock_gating_cell&&full_name=~*bcg*&&is_mapped}] -filter {name=~*/phi}]
	set_attribute $bcg_cg_pins dont_estimate_clock_latency true
}


#------------------------------------------------------------------------------
## Initial Compile
#------------------------------------------------------------------------------
save_block -as ${DESIGN_NAME}/init_design 

puts "RM-info: Running compile_fusion -check_only"
redirect -file reports/${STAGE}/compile_fusion.check_only {compile_fusion -check_only}


set_app_options -list {design.enable_rule_based_query false}

redirect -file reports/${STAGE}/report_app_options.non_default_pre_initial_map.rpt {report_app_options -non_default}

eee {compile_fusion -to initial_map}

save_block -as ${DESIGN_NAME}/initial_map


if {[info exists STOP_AFTER] && [regexp "compile:initial_map" $STOP_AFTER]} {
	puts "-I- stoping compile stage after initial_map"
	puts "    goto save design and reports"
} else {
	
	if {[info exists USE_ETM_FOR_BLOCKS] && $USE_ETM_FOR_BLOCKS != ""} {
		foreach bbb $USE_ETM_FOR_BLOCKS {
			puts "-I- getting   mode for  { $bbb } etm "
			unset -nocomplain mmm
			redirect -variable rrr {report_cell_mode $bbb -nosplit}
			foreach line [split $rrr "\n"] {
				if {[string match "*$bbb*" $line]} {
					regexp  {\y(func\w*)\y} $line  match mmm
				}
			}
			if {[info exists mmm]} {
				puts "-I- setting $mmm  mode for  { $bbb } etm "
				set_cell_mode $mmm $bbb
				report_cell_mode $bbb -nosplit
			}		
		}
	}
	
	
	#======Add IO BUFFER======
	if {[info exists IO_BUFFERS_DIR] && ($IO_BUFFERS_DIR == "in" ||$IO_BUFFERS_DIR == "out"|| $IO_BUFFERS_DIR == "both" || $IO_BUFFERS_DIR == "in_ant" || $IO_BUFFERS_DIR == "both_ant")} {
	
		if {[info exists IO_BUFFER_DISTRIBUTION] && [regexp "checkerboard" $IO_BUFFER_DISTRIBUTION]} {
	
			puts "-I- Create carpet checkerboard blockages"
	    		create_blockage_boxes
	
			puts "-I- adding IO buffers to interface on $IO_BUFFERS_DIR direction"
			addiobuffer_proc \
				-buffer $IOBUFFER_CELL \
				-i_buffer $IN_BUFFER_CELL \
				-o_buffer $OUT_BUFFER_CELL \
				-direction $IO_BUFFERS_DIR \
				-padding "2 0 2 0" \
				-mode 1
				
	
			set_app_option -name place.legalize.legalize_only_selected_cells -value true
		
			if {$IO_BUFFER_DISTRIBUTION == "checkerboard"} {
				
				set c [get_cells -filter {name=~*IOBuf*}]
				puts "[sizeof $c] IO buffers found"
				if {[sizeof $c]} {
					append_to_collection leg $c
					legalize_placement -cells  [get_cells -filter {name=~*IOBuf*}]
					set_fixed_objects $c
				}	
	
			} else {
				
				set layers [lsort -u -dict [get_attribute [get_ports -of_objects [get_nets -of_objects [get_cells *IOBuf*]]] layer_name]]
				set leg [add_to_collection "" ""]
				foreach l $layers {
					puts $l
					set cmd "filter_collection \[get_cells -of_objects \[get_nets -of_objects \[get_ports -filter {layer_name==$l}\]\]\] name=~*IOBuf*"
					set c [eval $cmd]
					puts "[sizeof $c] IO buffers found"
					if {[sizeof $c]} {
						append_to_collection leg $c
						legalize_placement -cells $leg
						set_fixed_objects $c
					}
				}
	
			}
	
			set_app_option -name place.legalize.legalize_only_selected_cells -value false
			remove_placement_spacing_rules -label X
			remove_placement_spacing_rules -rule {X X}
			remove_placement_blockages [get_placement_blockages *IOBUFS_BLOCKAGE*]   
	
		} elseif {[info exists IO_BUFFER_DISTRIBUTION] && $IO_BUFFER_DISTRIBUTION == "layer"} {
			puts "-I- adding IO buffers to interface on $IO_BUFFERS_DIR direction"
			addiobuffer_by_layer \
				-direction $IO_BUFFERS_DIR \
				-buffer $IOBUFFER_CELL \
				-i_buffer $IN_BUFFER_CELL \
				-o_buffer $OUT_BUFFER_CELL
	
		}
	
	
	}
	
	if {[file exists ./scripts_local/pre_logic_opto_setting.tcl]} {
		puts "-I- reading pre_logic_opto_setting file from scripts_local"
		source -v -e ./scripts_local/pre_logic_opto_setting.tcl
	} 
	eee {compile_fusion -from logic_opto -to logic_opto}
	save_block -as ${DESIGN_NAME}/logic_opto
	
	
	#------------------------------------------------------------------------------
	# initial place
	#------------------------------------------------------------------------------
	
	if {[file exists ./scripts_local/pre_initial_place_setting.tcl]} {
		puts "-I- reading pre_initial_place_setting file from scripts_local"
		source -v -e ./scripts_local/pre_initial_place_setting.tcl
	} 
	mark_clock_trees -routing_rules
	eee {compile_fusion -from initial_place -to initial_place}
	save_block -as ${DESIGN_NAME}/initial_place
	
	
	eee {compile_fusion -from initial_drc -to initial_drc}
	save_block -as ${DESIGN_NAME}/initial_drc
	
	
	report_qor -summary
	if {[file exists ./scripts_local/pre_initial_opto_setting.tcl]} {
		puts "-I- reading pre_initial_opto_setting file from scripts_local"
		source -v -e ./scripts_local/pre_initial_opto_setting.tcl
	} 
	eee {compile_fusion -from initial_opto -to initial_opto}
	
	
	

} ; # if {[info exists STOP_AFTER] && [regexp "compile:initial_map" $STOP_AFTER]}

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
# change name and flatten design
#------------------------------------------------------------------------------

define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port
	
define_name_rules scip -first_restricted {0-9 _}
#define_name_rules scip -last_restricted  {_}

redirect -file reports/compile/report_name_rules.log {report_name_rules}
redirect -file reports/compile/report_names.log {report_names -rules verilog}
#change_names -rules verilog -hierarchy -skip_physical_only_cells


change_names -hierarchy -rules scip
change_names -hierarchy -rules verilog

#
if {[info exists FE_MODE] && $FE_MODE} {
	redirect -file reports/${STAGE}/report_area.rpt {area_report -level 4}
}
redirect -file reports/${STAGE}/report_area_summary.rpt  {report_area}

if {[info exists FLAT_DESIGN] && $FLAT_DESIGN == "true"} {
	save_block -as ${DESIGN_NAME}/compile_hier
	write_verilog -exclude { physical_only_cells well_tap_cells filler_cells end_cap_cells pg_netlist } -compress gzip out/netlist/${DESIGN_NAME}.compile_hier.v.gz
	

	ungroup_cells -all -flatten -force
	if {[sizeof_collection [get_cells -hierarchical -filter "is_hierarchical"]] > 0} {
		puts  "Warning: design is not flatten. run ungroup again"
		set_attribute [get_cells -hierarchical -filter "is_hierarchical"] ungroup true
		ungroup_cells -all -flatten -force
	}



	change_names -hierarchy -rules scip
	change_names -hierarchy -rules verilog
}


#save_block -as ${DESIGN_NAME}/logic_opto

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------

if {$FE_MODE == "false"} { 
	EaExtractBumpCenters -add_term_to_connected_port -rm_dupes 
	EaCreateAPTerms
}

save_block

if {![info exists STOP_AFTER] || ![regexp "compile:initial_map" $STOP_AFTER]} {
	create_frame \
		-merge_metal_blockage true \
		-block_all true \
		-remove_non_pin_shapes { {PO all} {M0 all} {VIA0 all} {M1 all} {VIA1 all} {M2 all} {VIA2 all} {M3 all} {VIA3 all} {M4 all} {VIA4 all} {M5 all} {VIA5 all} {M6 all} {VIA6 all} {M7 all} {VIA7 all} {M8 all} {VIA8 all} {M9 all} {VIA9 all} {M10 all} {VIA10 all} {M11 all} {VIA11 all} {M12 all} {VIA12 all} {M13 all} {VIA13 all} {M14 all} {VIA14 all} {M15 all} {VIA15 all} {M16 all} {VIA16 all} {M17 all} {VIA17 all} {M18 all} {VIA18 all}}

}

save_lib

write_sdc -exclude {annotation clock_latency ideal_network } -output out/sdc/${DESIGN_NAME}_compile.sdc

write_verilog -exclude { physical_only_cells well_tap_cells filler_cells end_cap_cells pg_netlist } -compress gzip out/netlist/${DESIGN_NAME}.compile.v.gz

if {![info exists STOP_AFTER] || ![regexp "compile:initial_map" $STOP_AFTER]} {

	set_app_option -name file.def.ignore_uncolored_shapes -value 0
	set_app_options -name file.def.check_mask_constraints -value none
	write_def -compress gzip -include_tech_via_definitions -include {cells blockages rows ports specialnets} -include_physical_status fixed out/def/${DESIGN_NAME}.${STAGE}.be.def
	

#    30/07/2025 Royl:  why removing ALL Metals from lef ??????????
#	set exclude_layers "\[get_layers -filter {name !~ 'M\d+$' || name > 'M${MAX_ROUTING_LAYER}'}\]"
#	set cmd "write_lef -include cell -exclude_layers $exclude_layers  out/lef/${DESIGN_NAME}.compile.lef"


	set cmd "write_lef -include cell  out/lef/${DESIGN_NAME}.compile.lef"

	eval $cmd
	write_floorplan \
		-output out/floorplan/${STAGE}_manual \
		-include {cells blockages bounds die_area module_boundaries nets pg_regions pins route_guides rows tracks user_shapes vias} \
		-force \
		-include_physical_status all \
		-include_tech_via_definitions \
		-net_types  {ground power} \
		-read_def_options "-add_def_only_objects all -no_incremental" \
		-def_units 10000
	
	if {[info exists CREATE_ABSTRACT] && $CREATE_ABSTRACT == "true" } {
		#set_scenario_status [get_scenarios $ALL_SCENARIOS] -active true
	#	set_app_options -name abstract.annotate_power -value true
	#	create_frame
	#	create_abstract -read_only
		
		puts "Info: creating frame and abstract for block . . ."
		set cmd "create_abstract -read_only"
		set cells2include [get_cells -q -hier -filter "ref_name==PROBEPAD_59X59||ref_name==UBUMP"]
		if {$cells2include  != ""} {
		    append cmd " -include_objects [get_pins -of_objects $cells2include ]"
		}
		eval $cmd
		
	}
}

if {[file exists ./scripts_local/post_compile_setting.tcl]} {
	puts "-I- reading post_compile_setting file from scripts_local"
	source -v -e ./scripts_local/post_compile_setting.tcl
} 


#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
eee "redirect -file ./reports/${STAGE}/report_threshold_voltage_group.rpt {report_threshold_voltage_group -nosplit \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group
eee "redirect -file ./reports/${STAGE}/report_vt_summary.rpt {report_threshold_voltage_group -nosplit -summary \[get_cells -filter {!is_hard_macro&&!is_physical_only}\]}"  ./reports/${STAGE}/runtime.txt report_threshold_voltage_group_summary
if {![info exists STOP_AFTER] || ![regexp "compile:initial_map" $STOP_AFTER]} {
	redirect -file ./reports/${STAGE}/report_congestion_summary.rpt {report_congestion -mode summary}
	redirect -tee -file ./reports/${STAGE}/report_congestion.rpt {report_congestion -layers [get_layers -filter "layer_type==interconnect"] -rerun_global_router -nosplit}
}

write_app_options -output ./reports/${STAGE}/write_app_options.bin
printvar -user_defined > reports/$STAGE/printvar_user_defined.tcl
sh perl -p -i -e {s/(.*)=/set \1/} reports/$STAGE/printvar_user_defined.tcl

if {[regexp  "k8s|argo" $env(HOST)] } {

	set DESCRIPTION "[string tolower [lindex [split [pwd] "/"] end]]_reports"
	echo "set STAGE $STAGE" > ${STAGE}_report_parallel.tcl
	echo "set FE_MODE $FE_MODE" >> ${STAGE}_report_parallel.tcl
	echo "set DESIGN_NAME $DESIGN_NAME" >> ${STAGE}_report_parallel.tcl
	echo "set PROJECT $PROJECT" >> ${STAGE}_report_parallel.tcl
	echo "set RUNNING_DIR [pwd]" >> ${STAGE}_report_parallel.tcl
	echo "set STOP_AFTER $STOP_AFTER" >> ${STAGE}_report_parallel.tcl
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
	echo "source [pwd]/scripts/procs/fc_shell/report_timing_with_rtl_line.tcl" >> ${STAGE}_report_parallel.tcl
	
	if {[file exists ./scripts_local/post_compile_setting.tcl]} {
		echo "source [pwd]/scripts_local/post_compile_setting.tcl" >> ${STAGE}_report_parallel.tcl
	} 

	set REPORTS_MEMORY [expr 1.4 * $MEMORY]
	
	exec cp -pv ./scripts/flow/fc_reports_compile.tcl ./sourced_scripts/${STAGE}/.
 	report_parallel \
 		-work_directory reports/${STAGE}/parallel_run \
		-submit_command "./scripts/bin/pt_nextk8s.csh -cpu $CPU -mem $REPORTS_MEMORY -pwd [pwd] -description ${DESCRIPTION} -label $LABEL"  \
		-max_cores $CPU \
		-user_scripts [list "${STAGE}_report_parallel.tcl" "[which ./scripts/flow/fc_reports_compile.tcl]"]
		
		
} else {
	source -e -v ./scripts/flow/fc_reports_compile.tcl
}


#------------------------------------------------------------------------------
# collect DFT collaterals 
#------------------------------------------------------------------------------

catch {dft_files_generator} results

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

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

set STAGE init

set start_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - Start running $STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
# create proc just for synopsys
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
if {![file exists ./reports/${STAGE}]} {exec mkdir -pv ./reports/${STAGE}}
if {![file exists ./reports/qor_data]} {exec mkdir -pv ./reports/qor_data}
if {![file exists ./reports/${STAGE}/snapshots]} {exec mkdir -pv ./reports/${STAGE}/snapshots}

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
source -v $setup_file
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/rtla_pre_design_variables.tcl]} {
	puts "-I- reading rtla_pre_design_variables file from scripts_local"
	source -v -e scripts_local/rtla_pre_design_variables.tcl
} else {
	puts "-I- reading rtla_pre_design_variables file from scripts"
	source -v -e scripts/flow/rtla_pre_design_variables.tcl
}


########################################################################
## Library creation
########################################################################
source ./scripts/flow/create_snps_lib.tcl

if {[info exists AUTOFIX] && $AUTOFIX == "true" } {
	puts "-I- allow autofix for incompleate design "
  	set_current_mismatch_config auto_fix -enable {netlist library}
#	redirect -file reports/report_design_mismatch.rpt  { report_design_mismatch -verbose }
}



if {$ENABLE_RTL_RESTRUCTURING} {
	puts "-I runnin with ENABLE_RTL_RESTRUCTURING true"
        set_app_options -name rtl_restructuring.enable_restructured_rtl_generation -value true
        set_app_options -name time.reparent_enable_inherit_constraints -value true
}

#################################################################################
## Read in the RTL design
#################################################################################
if { ![info exists FILELIST] || $FILELIST == "None" } {
	if       { [file exists ./filelist] } {
           set filelist ./filelist    
   
	} elseif { [file exists ../inter/filelist] } {
           set filelist ../inter/filelist
   
	} else {
		puts "Error: missing filelist"
		exit 1
	}
       
} else {
	set filelist $FILELIST
}


puts "-I- path_to_filelist_location [file normalize [glob $filelist]]"
redirect -tee -file reports/init/analyze.rpt {analyze -format sverilog -vcs "+define+NXT_PRIMITIVES+BRCM_NO_MEM_SPECIFY -f $filelist"}

redirect -tee -file reports/elaborate.rpt  { [catch {elaborate ${DESIGN_NAME}} link_status] }
redirect -tee -file reports/link.rpt  { [catch {set_top_module ${DESIGN_NAME}} link_status] }
if { [info exists AUTOFIX] && $AUTOFIX == "false" } {
  	if {![catch {exec grep DMM-116 reports/link.rpt}]} {
    		puts "Error: Design has  unresolved references. check reports/link.rpt for more information " 
     		report_design_mismatch -verbose
   #    	puts $link_status 
    		exit 1 
  	}
}


if {[info exists AUTOFIX] && $AUTOFIX == "true" } {
  #set_current_mismatch_config auto_fix -enable {netlist library}
  report_design_mismatch -verbose
}


####################################
## Save elaborated design
####################################

save_block -hier -as ${DESIGN_NAME}/elaborate

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/rtla_variables.tcl]} {
	puts "-I- reading rtla_variables file from scripts_local"
	source -e -v scripts_local/rtla_variables.tcl
} else {
	puts "-I- reading rtla_variables file from scripts"
	source -e -v scripts/flow/rtla_variables.tcl
}

if {$ENABLE_PRE_RTL_OPT_NETLIST_CHECKS == "true"} {
	check_design -checks netlist 
	puts "RM-Info : Perform prelude netlist checks to foreseen bad RTL coding error.\n"
} 



## Design mismatch reports
redirect -file reports/init/report_design_mismatch {report_design_mismatch -verbose}
redirect -file reports/init/report_unbound {report_unbound}

## start SAIF mapping database
saif_map -start

	
#uniquify -force
#------------------------------------------------------------------------------
# elaborat reports
#------------------------------------------------------------------------------



################################################################
## connect_pg_net
################################################################
if {[file exists scripts_local/connect_pg_net.tcl]} {
        puts "-I- reading connect_pg_net file from scripts_local"
        source -e -v scripts_local/connect_pg_net.tcl
} else {
        puts "-I- reading connect_pg_net file from scripts"
        source -e -v scripts/flow/connect_pg_net.tcl
}

################################################################
## floorplan
################################################################
## Set site default
if {$DEFAULT_SITE != ""} {
	set_attribute [get_site_defs] is_default false
	set_attribute [get_site_defs $DEFAULT_SITE] is_default true
}

foreach LLL $ROUTING_DIRECTION_HORIZONTAL {set_attribute [get_layer $LLL]  routing_direction horizontal }
foreach LLL $ROUTING_DIRECTION_VERTICAL   {set_attribute [get_layer $LLL]  routing_direction vertical }
#set_attribute [get_layers $layer] track_offset $offset

if {[info exists MANUAL_FP] && $MANUAL_FP  } {
	puts "-I- manual FP.\ndo source scripts_local/user_manual_fp.tcl"
	return
} elseif {$DEF_FILE != "None" } {
       read_def -no_incremental -add_def_only_objects all $DEF_FILE
} elseif {[file exists scripts_local/user_manual_fp.tcl]} {
	source -e -v ./scripts_local/user_manual_fp.tcl
} else {
	puts "-I- using default RTLA floorplanning"
}




########################################################################
## run multi corner multi mode definition
########################################################################
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

#------------------------------------------------------------------------------
# clock gating latency
#------------------------------------------------------------------------------
set CS [current_scenario ]
foreach_in_collection AC [get_scenarios *SS*] {
	current_scenario $AC
	set cmd "set_clock_gate_latency -stage 1 -fanout_latency {{ 1-inf ${CLOCK_GATING_SETUP} }}"
	eval $cmd
	set cmd "set_clock_gate_latency -stage 0 -fanout_latency {{ 1-inf 0 }}"
	eval $cmd
}
current_scenario $CS



##############################################################
### group_path
##############################################################
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

########################################################################
## OCV
########################################################################

if {[info exists OCV] && $OCV == "pocv"} {
#  refernce
#/bespace/users/royl/deliveries/from_snps/CBU_power_run_TC_2024099_334138/inputs/TCL_POCV_SETUP_FILE.tcl
	puts "-I- setting OCV"
	set CS [current_scenario]
        foreach dc [all_scenarios] { 
	   source -v -e ./scripts/flow/derating.${PROJECT}.tcl

	   # Source additional user derates
	   if { [file exists ./scripts_local/user_derates.tcl] } { 
		puts "-I- Source user_derates.tcl"
		source ./scripts_local/user_derates.tcl
	   }
	}
	current_scenario $CS
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

########################################################################
## clock NDR
########################################################################
#rm_source -file $TCL_CTS_NDR_RULE_FILE -optional -print "TCL_CTS_NDR_RULE_FILE"
#redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_routing_rules {report_routing_rules -verbose}
#redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_routing_rules {report_clock_routing_rules}
#redirect -file ${REPORTS_DIR}/${REPORT_PREFIX}/report_clock_settings {report_clock_settings}


########################################################################
## Check to remove any duplicate shapes in the design
########################################################################
set duplicate_shapes [check_duplicates -return_as_collection]
if {[sizeof_collection $duplicate_shapes] > 0} {
	puts "-W- duplicate_shapes exists. removing them"
	if {[sizeof_collection [filter_collection $duplicate_shapes object_class==via]]>0} {
		remove_vias -force  [filter_collection $duplicate_shapes object_class==via]
	}
	if {[sizeof_collection [filter_collection $duplicate_shapes object_class==shape]]>0} {
   		remove_shapes -force [filter_collection $duplicate_shapes object_class==shape]
	}
}

##########################################################################################
## Perform RTL Restructuring
##########################################################################################
if {$ENABLE_RTL_RESTRUCTURING} {
	puts "-I- running with ENABLE_RTL_RESTRUCTURING"
        set_app_options -name time.reparent_enable_inherit_constraints -value true
        set_app_options -name mv.hierarchical.restructure_upf_for_group -value true
        set_app_options -name mv.hierarchical.restructure_upf_for_ungroup -value true
        if {$UPF_MODE == "golden"} {
                 puts "RM-info: Turning off upf golden mode for RTL restructuring flow to be able to write out modified UPF"
                 set_app_options -name mv.upf.enable_golden_upf -value false
        }
        rm_source -file $TCL_RTL_RESTRUCTURING_SCRIPT -print "TCL_RTL_RESTRUCTURING_SCRIPT"

        file mkdir out/RESTRUCTURING out/RESTRUCTURING
        write_restructured_rtl -output out/RESTRUCTURING
        file mkdir out/RESTRUCTURING/CONSTRAINTS
	write_script -output out/RESTRUCTURING/CONSTRAINTS -force
        file mkdir out/RESTRUCTURING/UPF/
        save_upf out/RESTRUCTURING/UPF/${DESIGN_NAME}.upf
}


save_block -hier -as ${DESIGN_NAME}/init

####################################
## Sanity checks and QoR Report	
####################################
check_floorplan_rules 
write_qor_data -report_list "performance host_machine report_app_options" -label init -output ./reports/qor_data 

#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------

close_lib -all


report_msg -summary
print_message_info -ids * -summary

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end

#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}_done

   exit

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
} else {

   exit
  
}

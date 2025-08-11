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
#	0.1	29/08/2021	Royl	initial script																#
#																						#
#																						#
#################################################################################################################################################################################

set STAGE eco

set start_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - Start running $STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
# create proc just for synopsys
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.

#script_runtime_proc -start
if {![file exists reports/eco$ECO_NUM]} {exec mkdir -pv reports/eco$ECO_NUM}

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file scripts_local/setup.tcl
} elseif {[info exists PROJECT] && [file exists scripts/setup/setup.${PROJECT}.tcl]} {
	puts "-I- reading setup file for project $PROJECT from scripts"
	set setup_file scripts/setup/setup.${PROJECT}.tcl
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
if {[file exists scripts_local/fc_variables.tcl]} {
	puts "-I- reading fc_variables file from scripts_local"
	source -v scripts_local/fc_variables.tcl
} else {
	puts "-I- reading fc_variables file from scripts"
	source -v scripts/flow/fc_variables.tcl
}


########################################################################
## Library creation
########################################################################
source -e -v ./scripts/flow/create_snps_lib.tcl


#################################################################################
## Read in the RTL design
#################################################################################
if {[file exists ./scripts_local/chiplet_vstub.tcl] } {
    puts "-I- reading ./scripts_local/chiplet_vstub.tcl"
    source ./scripts_local/chiplet_vstub.tcl
} elseif {[file exists ./scripts/flow/chiplet_vstub.${PROJECT}.tcl] } {
    puts "-I- reading ./scripts/flow/chiplet_vstub.${PROJECT}.tcl"
    source ./scripts/flow/chiplet_vstub.${PROJECT}.tcl
}




if {[file exists $NETLIST] } {
	if {[info exists vstub_filelist]} { 
		puts "-I- adding vstub files to NETLIST"
		lappend NETLIST $vstub_filelist 
		set_attribute -objects [get_mismatch_types empty_logic_module]  -name action(default) -value repair

	}
	read_verilog $NETLIST -top ${DESIGN_NAME}
} else {
	read_verilog out/db/${DESIGN_NAME}.route.enc.dat/${DESIGN_NAME}.v.gz  -top ${DESIGN_NAME}
	read_def -add_def_only_objects all  -traverse_physical_hierarchy  out/def/${DESIGN_NAME}.route.def.gz  
}



if {$ECO_DO == "LOGIC" } {
	puts "-I- doing netlist compare"
	eco_netlist \
		-write_changes out/eco${ECO_NUM}.tcl \
		-by_verilog_file $ECO_NETLIST \
		-write_summary out/eco${ECO_NUM}.sum \
		-top_module $DESIGN_NAME
		
} elseif {$ECO_DO == "LOGIC_TCL" } {
	puts "-I- doing Logic TCL ECO"
    	if {[info exists ECO_SCRIPT] && [file exists $ECO_SCRIPT]} {
        	set SCRIPT__ $ECO_SCRIPT 
    	} elseif {[file exists out/eco${ECO_NUM}.tcl]} {
        	set SCRIPT__  out/eco${ECO_NUM}.tcl
    	} else {
        	puts "-E- missing script file for logic ECO"
		return
    	}
    	puts "-I- doing logic eco on netlist $NETLIST using script $SCRIPT__"
    	catch  {exec  grep attachTerm $SCRIPT__ } ddd
    
    	if {![regexp "child process" $ddd]} {
        	puts "Error: this TCL script is for Innovus"
    	} else {
        	source -e -v $SCRIPT__
    	}
} else {
     puts  "ERROR: No ECO was define"
		
}

write_verilog out/netlist/${DESIGN_NAME}.${STAGE}${ECO_NUM}.v.gz -compress gzip

if {![info exists INTERACTIVE] && $INTERACTIVE == "false"} {
	exit
}

return

################################################################
## MCMM setup  
################################################################
source scripts/flow/snps_mmmc_create.tcl
mmmc_create
source scripts_local/mmmc_results.tcl 

foreach view [lsort -unique [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]] {
	set cmd "scenario_proc_${view}"
	eval $cmd
}
foreach _view $scenarios(setup) {
	set_scenario_status  $_view -setup true -max_transition true -max_capacitance true  -active true
}
foreach _view $scenarios(hold) {
	set_scenario_status  $_view -hold true -max_transition true -max_capacitance true  -active true
}
foreach _view $scenarios(dynamic) {
	set_scenario_status  $_view -dynamic_power true  -active true
}
foreach _view $scenarios(leakage) {
	set_scenario_status  $_view -leakage_power true  -active true
}
remove_duplicate_timing_contexts

redirect -file reports/eco$ECO_NUM/report_scenarios.rpt { report_scenarios }
redirect -file reports/eco$ECO_NUM/report_corners.rpt   { report_corners }

####################################
## Save elaborated design
####################################

save_block -as ${DESIGN_NAME}/${DESIGN_NAME}_elaborated

####################################
## Design mismatch reports
####################################		       

redirect -file reports/elab.check_design.design_mismatch { check_design -ems_database check_design.design_mismatch.ems -checks design_mismatch }
redirect -file reports/elab.report_design_mismatch { report_design_mismatch -verbose }
redirect -file reports/elab.report_unbound { report_unbound }

###################################
## start SAIF mapping database
###################################

saif_map -start
###################################
## DFT Ports
###################################

# Create DFT ports if necessary
################################################################
## Read and commit the UPF file(s)  
################################################################
if {[info exists UPF_MODE] && $UPF_MODE == "golden"} {
      set_app_options -name mv.upf.enable_golden_upf -value true ;# tool default false
}
if {[info exists UPF_MODE] && $UPF_MODE != "none"} {
      if {[file exists [which $UPF_FILE]]} {
              load_upf $UPF_FILE

	      ## Read the supply set file
	      if {[file exists [which $UPF_UPDATE_SUPPLY_SET_FILE]]} {
		    load_upf $UPF_UPDATE_SUPPLY_SET_FILE
	      } elseif {$UPF_UPDATE_SUPPLY_SET_FILE != ""} {
		    puts "RM-error: UPF_UPDATE_SUPPLY_SET_FILE($UPF_UPDATE_SUPPLY_SET_FILE) is invalid. Please correct it."
	      }
              commit_upf
      } elseif {$UPF_FILE != ""} {
              puts "RM-error : UPF file($UPF_FILE) is invalid. Please correct it."
      }
}

set_technology

################################################################
## Floorplanning  
################################################################
set_attribute [get_site_defs] is_default false
set_attribute [get_site_defs $DEFAULT_SITE] is_default true
if {[file exists $DEF_FILE]} { 	
	puts "-I- reading def file $DEF_FILE" 
	read_def -add_def_only_objects all $DEF_FILE 
}


################################################################
## dont use  
################################################################
source  -v -e scripts/flow/dont_use_n_ideal_network.tcl
return
################################################################
## Timing constraints  
################################################################
  ## Specify a Tcl script to read in your TLU+ files by using the read_parasitic_tech command;
read_parasitic_tech

################################################################
## MCMM setup  
################################################################
source scripts/flow/snps_mmmc_create.tcl
mmmc_create


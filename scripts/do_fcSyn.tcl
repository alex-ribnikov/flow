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

set STAGE syn
if { [info exists ::env(SYN4RTL)] } { set fe_mode $::env(SYN4RTL) } else { set fe_mode false }
if {![file exists reports/dft]} {exec mkdir reports/dft}

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
source ./scripts/flow/create_snps_lib.tcl

#################################################################################
## Read in the RTL design
#################################################################################

set_svf out/${INIT_DESIGN_BLOCK_NAME}.svf
analyze -format sverilog ${RTL_SOURCE_FILES}
elaborate ${DESIGN_NAME}

set_top_module ${DESIGN_NAME}

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


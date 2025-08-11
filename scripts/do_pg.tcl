#########################################################################################################################################################
#																			#
#	this script will add top layers PG for innovus db  												#
#	variable received from shell are:														#
#		CPU		 	- number of CPU to run.8 per license										#
#		DESIGN_NAME	 	- name of top model												#
#		DEF_FILES 	  	- if variable is exists and point to a file, will read DEF/NETLIST instead of innovus DB.			#
#		NETLIST_FILE_LIST 		- if variable is exists and point to a file, will read DEF/NETLIST instead of innovus DB.		#
#		INNOVUS_DB 		- design with scan insertion											#
#																			#
#																			#
#																			#
#	 Var	date of change	owner		 comment												#
#	----	--------------	-------	 ---------------------------------------------------------------						#
#	0.1	05/04/2021	Royl	initial script													#
#																			#
#																			#
#########################################################################################################################################################
set_db source_verbose false
set RUNNING_LOCAL_SCRIPTS [list]
#set STAGE PG

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}

script_runtime_proc -start
check_script_location

if {![file exists reports/pg]} {exec mkdir -pv reports/pg}
#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v scripts_local/setup.tcl
} elseif {[file exists ${INNOVUS_DIR}/scripts_local/setup.tcl]} {
	puts "-I- reading setup file from ${INNOVUS_DIR}/scripts_local"
	source -v ${INNOVUS_DIR}/scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	source -v ./scripts/setup/setup.${::env(PROJECT)}.tcl
}


if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from inter"
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v scripts_local/supplement_setup.tcl
} elseif {[file exists ${INNOVUS_DIR}/scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ${INNOVUS_DIR}/scripts_local"
	source -v ${INNOVUS_DIR}/scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
set_multi_cpu_usage -local_cpu $CPU -remote_host 1 -cpu_per_remote_host 1

set_db init_delete_assigns 1
set_db init_power_nets        $PWR_NET
set_db init_ground_nets       $GND_NET
set_db init_keep_empty_modules true

#------------------------------------------------------------------------------
# define and read mmmc 
#------------------------------------------------------------------------------
source scripts/flow/mmmc_create.tcl
mmmc_create

set_db read_db_file_check false
#------------------------------------------------------------------------------
# read  design
#------------------------------------------------------------------------------
if {[info exists NETLIST_FILE_LIST] && [info exists DEF_FILES ] && [file exists $NETLIST_FILE_LIST] && [file exists $DEF_FILES]} {
	puts "-I- read design from DEF && Netlist: \n\t${NETLIST_FILE_LIST}\n\t${DEF_FILES}"
	read_mmmc $mmmc_results
	read_physical -lef $LEF_FILE_LIST
	read_netlist -top ${DESIGN_NAME} $NETLIST_FILE_LIST
	init_design
	read_def $DEF_FILES
} else {
	puts "-I- read design from innovus db: ${INNOVUS_DIR}/out/db/${DESIGN_NAME}.${STAGE}.enc.dat"
	read_db   ${INNOVUS_DIR}/out/db/${DESIGN_NAME}.${STAGE}.enc.dat
}

#------------------------------------------------------------------------------
# connect P/G pins to nets
#------------------------------------------------------------------------------
if {[file exists scripts_local/connect_global_net.tcl]} {
	puts "-I- reading connect_global_net file from scripts_local"
	source -e -v scripts_local/connect_global_net.tcl
} else {
	puts "-I- reading connect_global_net file from scripts"
	source -e -v scripts/flow/connect_global_net.tcl
}

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/INN_variables.tcl]} {
	puts "-I- reading INN_variables file from scripts_local"
	source -v scripts_local/INN_variables.tcl
} else {
	puts "-I- reading INN_variables file from scripts"
	source -v scripts/flow/INN_variables.tcl
}

#------------------------------------------------------------------------------
# add top layers PG
#------------------------------------------------------------------------------
set ADD_TOP_POWER true

source -e -v scripts/flow/create_power_grid.${PROJECT}.tcl

#------------------------------------------------------------------------------
# generate power source file for IR drop analysis
#------------------------------------------------------------------------------
source -e -v ./scripts/flow/generate_voltus_AP_power_sources.tcl

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.${STAGE}.def.gz

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end

exit


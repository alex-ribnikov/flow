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

set STAGE $STAGE_TO_REPORT

source ./scripts/procs/source_be_scripts.tcl

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
# read design setting
#------------------------------------------------------------------------------

open_lib out/${DESIGN_NAME}_lib
open_block ${DESIGN_NAME}/$STAGE
if {[file exists reports/${STAGE}/write_app_options.bin]} {
	puts "-I- reading app_option from file reports/${STAGE}/write_app_options.bin"
	read_app_options reports/${STAGE}/write_app_options.bin
}


#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------

source -e -v ./scripts/flow/fc_reports_${STAGE}.tcl

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end

#------------------------------------------------------------------------------
# Mark reports stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}_reports_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
} else {

   exit
  
}


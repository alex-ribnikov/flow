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

set STAGE eco
if {![info exists NUM_OF_FIXS] } {set NUM_OF_FIXS 1}

source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
if {![file exists ./reports/${STAGE}]} {exec mkdir -pv ./reports/${STAGE}}
if {![file exists ./reports/qor_data]} {exec mkdir -pv ./reports/qor_data}
if {![file exists ./reports/${STAGE}/snapshots]} {exec mkdir -pv ./reports/${STAGE}/snapshots}
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
set PREV_ECO_NUM [expr $ECO_NUM -1]
if {$ECO_DO == "LOGIC_TCL"} {

set_svf out/svf/${DESIGN_NAME}_${STAGE}.svf
open_lib out/${DESIGN_NAME}_lib


if {$ECO_NUM == 1} {
	puts "-I- read design from route db"
	set READ_DB ${DESIGN_NAME}/route
} else {
	puts "-I- read design from eco$PREV_ECO_NUM db"
	set READ_DB ${DESIGN_NAME}/eco${PREV_ECO_NUM}
}

	copy_block -from $READ_DB -to ${DESIGN_NAME}/eco${ECO_NUM} -force


current_block ${DESIGN_NAME}/eco${ECO_NUM}
link_block

#------------------------------------------------------------------------------
# extra setting and operations 
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_eco_setting.tcl]} {
        puts "-I- running Extra setting from ./scripts_local/pre_eco_setting.tcl]}"
        check_script_location ./scripts_local/pre_eco_setting.tcl
        source -v -e ./scripts_local/pre_eco_setting.tcl
}

#------------------------------------------------------------------------------
# do eco 
#------------------------------------------------------------------------------
if {$ECO_DO == "DRC" } {

} elseif {$ECO_DO == "STA" } {
    if {[file exists scripts_local/sta_eco${ECO_NUM}.tcl]} {
        puts "-I- source scripts_local/sta_eco${ECO_NUM}.tcl"
        set cmd "eee {source -e -v scripts_local/sta_eco${ECO_NUM}.tcl}"
        eval $cmd
    } else {
    	puts "Error: missing eco scripts scripts_local/sta_eco${ECO_NUM}.tcl"
    }
} elseif {$ECO_DO == "LOGIC_TCL" } {
} else {
     puts  "ERROR: No ECO was define"
}

#------------------------------------------------------------------------------
# post setting and operations 
#------------------------------------------------------------------------------
set hook_script "./scripts_local/post_eco_setting.tcl"
if {[file exists ./scripts_local/post_eco_setting.tcl]} {
        puts "-I- running Extra setting from ./scripts_local/post_eco_setting.tcl"
        check_script_location ./scripts_local/post_eco_setting.tcl
        source -v -e ./scripts_local/post_eco_setting.tcl
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

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------





#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
report_resource

#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}${ECO_NUM}_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
}

if {![info exists BATCH] || $BATCH == "true"} {
     exit
}



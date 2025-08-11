#################################################################################################################################################
#																		#
#	this script will run Voltuse IR/EM analysis  												#
#	variable received from shell are:													#
#		CPU		  		- number of CPU to run.8 per license								#
#		HOSTS 		  		- if distributed run, will run those hosts							#
#		DESIGN_NAME	  		- name of top model										#
#		STAGE 		  		- stage of the design running on								#
#		OCV 		  		- run with OCV											#
#		RAIL_ANALYSIS_TEMPERATURE  	- define temperature for rail check								#
#		POWER_METHOD 	  		- static or dynamic IR										#
#		ACTIVITY_FILE 	  		- run power analysis with activity file instead of activity factor				#
#		SWITCHING_ACTIVITY_FILE 	- run power analysis with switching activity file 						#
#		DEFAULT_SWITCHING_ACTIVITY	- run power analysis with those default_switching_activity					#
#		VIEW 		  		- the view to run on										#
#		INNOVUS_DB 	  		- location of INNOVUS database 									#
#		INTERACTIVE 	  		- dont exit at end of script									#
#		SPEF_DIR 	  		- location of SPEF dir 										#
#		SPEF_FILE_LIST 	  		- if variable is exists and point to a file, spef will be read from that file.			#
#						  else spef location is read from setup.tcl							#
#		DEF_FILES 	  		- if variable is exists and point to a file, will read DEF/NETLIST instead of innovus DB.	#
#		NETLIST_FILE_LIST 	  	- if variable is exists and point to a file, will read DEF/NETLIST instead of innovus DB.	#
#																		#
#																		#
#	 Var	date of change	owner		 comment											#
#	----	--------------	-------	 ---------------------------------------------------------------					#
#	0.1	04/04/2021	Royl	initial script												#
#																		#
#																		#
#################################################################################################################################################
set_multi_cpu_usage -local_cpu $CPU -remote_host 2   
if {![info exists STAGE]} {set STAGE chip_finish}
#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.


script_runtime_proc -start
if {![file exists ./reports]} {exec mkdir -pv ./reports}

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	source -v ./scripts/setup/setup.${PROJECT}.tcl
}
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from inter"
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
set_multi_cpu_usage -local_cpu $CPU 

#------------------------------------------------------------------------------
# define and read mmmc 
#------------------------------------------------------------------------------
if {[llength $VIEWS] == 1} {
	set scenarios(setup) $VIEWS ;  set scenarios(hold) $VIEWS ; set scenarios(dynamic) "" ; set scenarios(leakage) ""
} else {
	set scenarios(setup) [list] ;  
	set scenarios(hold) [list] ; 
	set scenarios(dynamic) "" ; 
	set scenarios(leakage) ""
	foreach _VIEW $VIEWS {
		set VIEW_SPLIT [split $_VIEW "_"]
		set check [lindex $VIEW_SPLIT end]
		if {$check == "setup" } {lappend scenarios(setup) $_VIEW}
		if {$check == "hold" } {lappend scenarios(hold) $_VIEW}
	}
}

source scripts/flow/mmmc_create.tcl
mmmc_create
 
#------------------------------------------------------------------------------
# read  design
#------------------------------------------------------------------------------
if {[file exists $NETLIST_FILE_LIST] && [file exists $DEF_FILES]} {
	puts "-I- read design from DEF && Netlist: \n\t${NETLIST_FILE_LIST}\n\t${DEF_FILES}"
	read_mmmc $mmmc_results
	read_physical -lef $LEF_FILE_LIST
	read_netlist -top ${DESIGN_NAME} $NETLIST_FILE_LIST
	init_design
	read_def $DEF_FILES -preserve_shape
} else {
	puts "-I- read design from innovus db: $INNOVUS_DB"
	read_db -mmmc_file $mmmc_results  $INNOVUS_DB
}
#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/TEMPUS_variables.tcl]} {
	puts "-I- reading TEMPUS_variables file from scripts_local"
	source -v scripts_local/TEMPUS_variables.tcl
} else {
	puts "-I- reading TEMPUS_variables file from scripts"
	source -v scripts/TEMPUS_variables.tcl
}


set_db power_dynamic_power_view ${VIEWS}
set_db power_leakage_power_view ${VIEWS}
#------------------------------------------------------------------------------
# read spef
#------------------------------------------------------------------------------
puts "-I- reading SPEF"
if {[info exists SPEF_FILE_LIST] && $SPEF_FILE_LIST != ""} {
	puts "-I- spef from list $SPEF_FILE_LIST"
	read_spef -extended -keep_star_node_locations -rc_corner [all_rc_corners -active] $SPEF_FILE_LIST
} else {
	foreach RC_CORNER [all_rc_corners -active] {
		regexp {(\d+)} $RC_CORNER match TEMP
		regsub {\d+} $RC_CORNER "" RC
		puts "-I- spef files [list $rc_corner($RC,spef_$TEMP)] for rc corner $RC_CORNER "
		read_spef -extended -keep_star_node_locations -rc_corner $RC_CORNER [list $rc_corner($RC,spef_$TEMP)]
	}
}
report_annotated_parasitics > reports/annotations_summary.rpt
report_annotated_parasitics \
	-not_annotated_nets \
	-unloaded_nets \
	-no_driver_nets \
	-floating_nets \
	-broken_nets \
	-real_nets \
	-max_missing 100000 > reports/annotations.rpt


#------------------------------------------------------------------------------
# Power setting 
#------------------------------------------------------------------------------
if {[info exists DEFAULT_SWITCHING_ACTIVITY] && $DEFAULT_SWITCHING_ACTIVITY != "" } {
	puts "-I- setting set_default_switching_activity from  $DEFAULT_SWITCHING_ACTIVITY"
	set DEFAULT_SWITCHING_ACTIVITY_list [ split $DEFAULT_SWITCHING_ACTIVITY ,]
	if {[lindex $DEFAULT_SWITCHING_ACTIVITY_list 0] != ""} {set_default_switching_activity -input_activity [lindex $DEFAULT_SWITCHING_ACTIVITY_list 0]}
	if {[lindex $DEFAULT_SWITCHING_ACTIVITY_list 1] != ""} {set_default_switching_activity -sequential_activity [lindex $DEFAULT_SWITCHING_ACTIVITY_list 1]}
	if {[lindex $DEFAULT_SWITCHING_ACTIVITY_list 2] != ""} {set_default_switching_activity -clock_gates_output [lindex $DEFAULT_SWITCHING_ACTIVITY_list 2]}
} else {
	puts "-I- setting set_default_switching_activity to 0.3 , 0.3 , 1.8"
	set_default_switching_activity -input_activity 0.3
	set_default_switching_activity -sequential_activity 0.3
	set_default_switching_activity -clock_gates_output 1.8
}
if {[info exists SWITCHING_ACTIVITY_FILE] && [file exists $SWITCHING_ACTIVITY_FILE]} {
	puts "-I- reading switching activity from file $SWITCHING_ACTIVITY_FILE"
	source -e -v $SWITCHING_ACTIVITY_FILE
}
if {[info exists ACTIVITY_FILE] && $ACTIVITY_FILE != "" } {
	puts "-I- reading activity file $ACTIVITY_FILE "
	read_activity_file $ACTIVITY_FILE -format fsdb
} 

set_db power_write_db true
set_db power_write_static_currents true
set_db power_method $POWER_METHOD
set_power_output_dir out/${POWER_METHOD}Pwr

if {[regexp dynamic $POWER_METHOD]} { 
	puts "-I- set_dynamic_power_simulation period to 10ns and resolution to 5ps "
	set_dynamic_power_simulation -period 10ns -resolution 5ps	
}

#------------------------------------------------------------------------------
#  power reports 
#------------------------------------------------------------------------------
report_power -out_file reports/${POWER_METHOD}Pwr/${POWER_METHOD}_power.rpt
report_power -insts {*} -no_wrap -out_file reports/${POWER_METHOD}Pwr/${POWER_METHOD}_instances.rpt

#------------------------------------------------------------------------------
# IR setting 
#------------------------------------------------------------------------------
if {[regexp dynamic $POWER_METHOD]} {
	set rail_analysis_config "-method dynamic -write_movies true -save_voltage_waveforms false -limit_number_of_steps false -write_decap_eco true  "
} else {
	set rail_analysis_config "-method static -enable_rlrp_analysis true"
}

set cmd "set_rail_analysis_config \
	$rail_analysis_config \
	-gif_resolution 0 \
	-tmp_directory_name /local/tmp \
	-work_directory_name work_[pid] \
	-enable_manufacturing_effects true \
	-ignore_shorts true \
	-temperature $RAIL_ANALYSIS_TEMPERATURE \
	-accuracy hd \
	-power_grid_libraries {$POWER_GRID_LIBRARIES} \
	-ict_em_models $ICT_EM_MODELS \
	-process_techgen_em_rules true "

echo $cmd
eval $cmd

set_pg_nets -net VDD -voltage 0.75 -threshold 0.71
set_pg_nets -net VSS -voltage 0.0 -threshold 0.04

if {[file exists ./out/VDD.pp]} {set_power_pads -net VDD -format xy -file ./out/VDD.pp } else {set_power_pads -net VDD -format defpin}
if {[file exists ./out/VSS.pp]} {set_power_pads -net VSS -format xy -file ./out/VSS.pp } else {set_power_pads -net VSS -format defpin}

set DYN static
regexp "(dynamic)" $POWER_METHOD match DYN
set cmd "set_power_data -format current {./reports/${POWER_METHOD}Pwr/${DYN}_VDD.ptiavg ./reports/${POWER_METHOD}Pwr/${DYN}_VSS.ptiavg}"
eval $cmd

set_rail_analysis_domain -domain_name coreDomain -power_nets $PWR_NET -ground_nets $GND_NET
eval_legacy  " analyze_resistance -method rlrp  -domain coreDomain -output_dir ./reports/domain_rlrp "

#------------------------------------------------------------------------------
#  IR reports 
#------------------------------------------------------------------------------
report_rail -type domain -output_dir reports/${POWER_METHOD}IRdrop coreDomain

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end

#------------------------------------------------------------------------------
# interactive 
#------------------------------------------------------------------------------
if {![info exists INTERACTIVE] || $INTERACTIVE == "false"} {
	exit
}




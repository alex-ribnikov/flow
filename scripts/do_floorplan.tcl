#################################################################################################################################################################################
#																						#
#	this script will run innovus floorplaning  																#
#	variable received from shell are:																	#
#		CPU		- number of CPU to run.8 per license														#
#		BATCH 		- run in batch mode																#
#		DESIGN_NAME	- name of top model																#
#		NETLIST_FILE 	- netlist to read into stage															#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	28/12/2020	Royl	initial script																#
#	0.2	08/03/2021	OrY	 	Merge with env
#																						#
#																						#
#################################################################################################################################################################################
set_db source_verbose false

set STAGE floorplan
set RUNNING_LOCAL_SCRIPTS [list]

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

if {![file exists reports/floorplan]} {exec mkdir -pv reports/floorplan}
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
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	check_script_location scripts_local/supplement_setup.tcl
	source -v scripts_local/supplement_setup.tcl
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
source ./scripts/flow/mmmc_create.tcl
mmmc_create
set cmd "read_mmmc { $mmmc_results }"
eval $cmd

#------------------------------------------------------------------------------
# read lef and enable PLE-MODE
#------------------------------------------------------------------------------
read_physical -lef $LEF_FILE_LIST

#------------------------------------------------------------------------------
# read  design
#------------------------------------------------------------------------------
read_netlist -top $DESIGN_NAME $NETLIST_FILE

init_design

be_set_design_source
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
# save netlist design
#------------------------------------------------------------------------------
write_db  -verilog      out/db/${DESIGN_NAME}.netlist.enc.dat

#------------------------------------------------------------------------------
# user manual floorplan
#------------------------------------------------------------------------------
if {[info exists MANUAL_FP] && $MANUAL_FP  } {
	puts "-I- manual FP.\ndo source scripts_local/user_manual_fp.tcl"
	return
} else {
	source -e -v scripts_local/user_manual_fp.tcl
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

check_drc -limit 100000
check_pin_assignment 
#------------------------------------------------------------------------------
# Check ports placement
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------

write_db  -verilog      out/db/${DESIGN_NAME}.floorplan.enc.dat
write_floorplan 	out/fp/${DESIGN_NAME}.floorplan.fp.gz

write_def -routing      out/def/${DESIGN_NAME}.floorplan.def.gz
write_def -floorplan -no_std_cells out/def/${DESIGN_NAME}.floorplan_for_syn.def.gz

write_lef_abstract -5.8 \
	-top_layer $MAX_ROUTING_LAYER \
	-pg_pin_layers $MAX_ROUTING_LAYER \
	-stripe_pins \
	-property \
	out/lef/${DESIGN_NAME}.${STAGE}.lef


#------------------------------------------------------------------------------
# Reports
#------------------------------------------------------------------------------

#report_summary -no_html -out_file reports/floorplan_report_summary.rpt
be_reports -timing -stage floorplan 

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
report_resource

#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
}

if {![info exists BATCH] || $BATCH == "true"} {
	delete_routes -type special -layer {M0 VIA0 M1 VIA1 M2 VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
	delete_obj [get_db insts FPGFILL*]
	delete_obj [get_db insts FPDCAP*]
	delete_obj [get_db insts ENDCAP*]
	delete_obj [get_db insts TAP*]
	write_def -floorplan -no_std_cells out/def/${DESIGN_NAME}.def.gz

	exit
}

#################################################################################################################################################################################
#																						#
#	this script will run Genus  																		#
#	variable received from shell are:																	#
#		CPU		- number of CPU to run.8 per license														#
#		DESIGN_NAME	- name of top model																#
#		PYISICAL_SYN	- runing physical synthesis															#
#		SCAN 		- insert scan to the design															#
#		OCV 		- run with ocv 																	#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	28/02/2021	Ory	initial script																#
#																						#
#																						#
#################################################################################################################################################################################
set STAGE joules
set start_joules [clock seconds]
puts "-I- Start running joules at: [clock format $start_joules -format "%d/%m/%y %H:%M:%S"]"


#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	source -v $::env(BEROOT)/be_flow/ns_flow/scripts/setup/setup.${::env(PROJECT)}.tcl
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
set_db library_setup_ispatial true ;                                    # (default : false
set_db max_cpus_per_server $CPU


#------------------------------------------------------------------------------
# define and read mmmc 
#------------------------------------------------------------------------------
source $::env(BEROOT)/be_flow/ns_flow/scripts/flow/mmmc_create.tcl
mmmc_create
set cmd "read_mmmc { $mmmc_results }"
eval $cmd

#------------------------------------------------------------------------------
# read lef and enable PLE-MODE
#------------------------------------------------------------------------------
set cmd "read_physical -lef \[list $LEF_FILE_LIST\]"
eval $cmd

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/syn_variables.tcl]} {
	puts "-I- reading syn_variables file from scripts_local"
	source -v scripts_local/joules_variables.tcl
} else {
	puts "-I- reading syn_variables file from scripts"
	source -v $::env(BEROOT)/be_flow/ns_flow/scripts/joules_variables.tcl
}

#------------------------------------------------------------------------------
# set dont use for cells
#------------------------------------------------------------------------------
source -v -e $::env(BEROOT)/be_flow/ns_flow/scripts/dont_use.tcl

#------------------------------------------------------------------------------
# Tag memory cells
#------------------------------------------------------------------------------
infer_memory_cells -tag_as_mem


#------------------------------------------------------------------------------
# read HDL design
#------------------------------------------------------------------------------
if {[file exists scripts_local/read_design.tcl]} {
	puts "-I- read design from scripts_local"
    source -v scripts_local/read_design.tcl
} else {
	puts "-I- read design from scripts"
	source -v $::env(BEROOT)/be_flow/ns_flow/scripts/read_design.tcl
}

elaborate $DESIGN_NAME

puts "Runtime & Memory after: read_hdl"
timestat Elaboration

init_design

write_db -all_root_attributes -to_file out/elab.jdb

rtlstim2gate -init out/elab.jdb -keep_libraries ; # Add -map_file fv/


#------------------------------------------------------------------------------
# read NETLIST
#------------------------------------------------------------------------------
# /bespace/users/ory/syn4rtl/new_nextinside/gendir/out/grid_cluster.Syn.v.gz
read_netlist $NETLIST

#------------------------------------------------------------------------------
# read SDC
#------------------------------------------------------------------------------
read_sdc $sdc_files(func)

#------------------------------------------------------------------------------
# read stimulus file (VCD/FSDB etc.)
#------------------------------------------------------------------------------
set_db stim_auto_mapping 1
#read_stimulus -file /bespace/users/ory/syn4rtl/new_nextinside/gendir/wb_env/inter/dump.fsdb -dut_instance /cluster_tb/grid_cluster -resim_cg_enables -scrub_prep -x_value 0 -frame_count 10
read_stimulus -file $STIM_FILE -dut_instance $DUT_INST -resim_cg_enables -scrub_prep -x_value $X_VALUE -frame_count $FRAME_COUNT

#------------------------------------------------------------------------------
# report sdb annotation
#------------------------------------------------------------------------------
report_sdb_annotation > out/annotation.rpt


#------------------------------------------------------------------------------
# Compute power
#------------------------------------------------------------------------------
#compute_power -mode time_based -scale_to_sdc_frequency -post_cts_clock -clock_network_slew propagate
compute_power -mode time_based -scale_to_sdc_frequency


#------------------------------------------------------------------------------
# Report power
#------------------------------------------------------------------------------
report_power -frame "/stim#1/frame#\[$FROM_FRAME:$TO_FRAME\]" -format "%.3f" -unit mW > out/power.rpt




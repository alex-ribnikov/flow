#################################################################################################################################################
#																		#
#	this script will generate PG Views for STD/memories 											#
#	variable received from shell are:													#
#		CPU		  		- number of CPU to run.8 per license								#
#		DESIGN_NAME	  		- name of top model										#
#																		#
#																		#
#	 Var	date of change	owner		 comment											#
#	----	--------------	-------	 ---------------------------------------------------------------					#
#	0.1	04/04/2021	Royl	initial script												#
#																		#
#																		#
#################################################################################################################################################
set STAGE PGV

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
source ./scripts/procs/source_be_scripts.tcl

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v scripts_local/setup.tcl
} else {
	puts "-I- reading ${::env(PROJECT)} setup file from scripts"
	source -v ./scripts/setup/setup.${::env(PROJECT)}.tcl
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

if {[regexp 5 ${::env(PROJECT)}]} {
	set PROCESS n5
} else {
	set PROCESS n7
}

#------------------------------------------------------------------------------
# read  design
#------------------------------------------------------------------------------
read_physical -lef $LEF_FILE_LIST

#------------------------------------------------------------------------------
# set pg library mode
#------------------------------------------------------------------------------
set cmd "set_pg_library_mode \
	-cell_type $CELL_TYPE \
	-power_pins {VDD 0.75 VDDF 0.75} \
	-ground_pins {VSS 0} \
	-bulk_power_pins {VPP 0.75 VBP 0.75 VDDB 0.75} \
	-bulk_ground_pins {VBB VBN VSSB} \
	-extraction_tech_file $rc_corner(cworst) \
	-lef_layer_map ./scripts/VTS.${PROCESS}.lefdef.layermap \
	-temperature 25 "
	
#enable_distributed_processing true \

echo $cmd
eval $cmd	

#------------------------------------------------------------------------------
# outputs
#------------------------------------------------------------------------------
write_pg_library -out_dir out/



#########################################################################################################################################################
#																			#
#	this script will run formal verification Place stage  												#
#	variable received from shell are:														#
#		SYN_DIR		 - synthesis dir to start from												#
#		CPU		 - number of CPU to run.8 per license											#
#		BATCH 		 - run in batch mode													#
#		DESIGN_NAME	 - name of top model													#
#		NETLIST_FILE 	 - netlist to read into stage												#
#		SCAN_DEF_FILE 	 - scan def file location												#
#		SCAN 		 - design with scan insertion												#
#		OCV 		 - run place with OCV													#
#		PLACE_OPT 	 - run place opt #N times												#
#		PLACE_START_FROM - starting stage from:													#
#					db : floorplan stage												#
#					def : def and netlist												#
#					syn : from synthesis db												#
#																			#
#																			#
#																			#
#	 Var	date of change	owner		 comment												#
#	----	--------------	-------	 ---------------------------------------------------------------						#
#	0.1	02/05/2021	Royl	initial script													#
#																			#
#########################################################################################################################################################
set STAGE ${::env(STAGE)}

#------------------------------------------------------------------------------
# read HDL design
#------------------------------------------------------------------------------
# TODO: Give FILELIST instead of NEXTINSIDE
set nextinside_path ${::env(NEXTINSIDE)}
set filelist        $nextinside_path/auto_gen/gendir/${::env(DESIGN_NAME)}/${::env(DESIGN_NAME)}_gen_filelist/filelist

##################################
# Check for a private filelist
##################################
if       { [file exists ./filelist] } {
    puts "-I- Reading filelist from: [exec realpath ./filelist]"
} elseif { [file exists ${::env(SYN_DIR)}/filelist] } {
    puts "-I- Reading filelist from: [exec realpath ${::env(SYN_DIR)}/filelist]"
} elseif { [file exists ../inter/filelist] } {
    puts "-I- Reading filelist from: [exec realpath ../inter/filelist]"

} else {
    puts "-I- Reading filelist from: $filelist"
    if {[file exists auto_gen]} {file delete auto_gen}
    if {[file exists design]} {file delete design}
    file link -symbolic auto_gen $nextinside_path/auto_gen
    file link -symbolic design $nextinside_path/design
}

# Link the Synthesis fv directory
if {[file exists fv]} {file delete fv}
exec ln -s ${::env(SYN_DIR)}/fv .

dofile ./fv/${::env(DESIGN_NAME)}/lec.${::env(STAGE)}.Syn.do

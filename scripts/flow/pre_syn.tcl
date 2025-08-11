set PROJECT inext
set STAGE eco
if {[file exists ../scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file ../scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
#	set setup_file ../scripts/setup/setup.${::env(PROJECT)}.tcl
	set setup_file ../scripts/setup/setup.${PROJECT}.tcl
}
source -v $setup_file

if {[file exists ../scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v ../scripts_local/supplement_setup.tcl
} elseif {[file exists ../../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../../inter/supplement_setup.tcl
}


#------------------------------------------------------------------------------
# set dont use for cells, dont touch inst and nets
#------------------------------------------------------------------------------
source  -v -e ../scripts/flow/dont_use_n_ideal_network.tcl


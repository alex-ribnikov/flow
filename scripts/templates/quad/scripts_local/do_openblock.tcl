#################################################################################################################################################################################
#																						#
#	this script will run open innovus db stage  																#
#	variable received from shell are:																	#
#		CPU		 - number of CPU to run.8 per license														#
#		DESIGN_NAME	 - name of top model																#
#		STAGE_TO_OPEN 	 - read db of this stage
#																						#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	12/01/2021	Royl	initial script																#
#																						#
#																						#
#################################################################################################################################################################################
set_db source_verbose false
history keep 10000

set STAGE open_block
#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------

# Central procs
source ./scripts/procs/source_be_scripts.tcl

script_runtime_proc -start

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v scripts_local/setup.tcl
} else {
	puts "-I- reading ${::env(PROJECT)}  setup file from scripts"
	source -v scripts/setup/setup.${::env(PROJECT)}.tcl
}

if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v scripts_local/supplement_setup.tcl
}
#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------


if {[info exists STAGE_TO_OPEN] && $STAGE_TO_OPEN != "" } {

    if { [get_db program_short_name] == "innovus" } {
      # allow to check setup and hold in the same session
      
      # set_db timing_enable_simultaneous_setup_hold_mode true
      
#      set_multi_cpu_usage -local_cpu $CPU -remote_host 1 -cpu_per_remote_host 1
      set_multi_cpu_usage -local_cpu $CPU 
      
	  puts "-I- opening innovus db $STAGE_TO_OPEN"
	  set STAGE $STAGE_TO_OPEN
      set db out/db/${DESIGN_NAME}.$STAGE_TO_OPEN.enc.dat

      if { $STAGE_TO_OPEN == "syn" } {
        set db $SYN_DIR/out/${DESIGN_NAME}.Syn.invs_db/${DESIGN_NAME}.stylus.enc
      }
      
    } else {
      
      set_multi_cpu_usage -local_cpu $CPU 
    
      puts "-I- opening Genus db $STAGE_TO_OPEN"
      set STAGE $STAGE_TO_OPEN
      set db out/${DESIGN_NAME}.${STAGE_TO_OPEN}.db
      
    }
    
    set cmd "read_db "
    
    if { [info exists REFRESH] && ( $REFRESH == "lef" || $REFRESH == "both" )} {
      set_db read_db_file_check 0
      append cmd " -lef_files \$LEF_FILE_LIST"
    }
    
    if { [info exists REFRESH] && ( $REFRESH == "lib" || $REFRESH == "both" )} {
      source ./scripts/flow/mmmc_create.tcl
      mmmc_create      
      append cmd " -mmmc_file $mmmc_results"
    }    

    if { [file exists $db] } {
      puts "Running: read_db $db"
      append cmd " $db"
    } elseif { [file exists $STAGE_TO_OPEN] && [regexp "enc\\.dat" $STAGE_TO_OPEN] || [regexp "\\.db" $STAGE_TO_OPEN] } {
      if { ![info exists ::STAGE] } { set ::STAGE "NOSTGE" }
      append cmd " $STAGE_TO_OPEN"
    } else {
      puts "-E- $db not found"
    }
    puts "-I- Running: $cmd"
    eval $cmd
    
}

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end

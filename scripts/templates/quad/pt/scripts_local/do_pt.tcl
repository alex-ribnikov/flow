#################################################################################################################################################
#																		#
#	this script will run Tempuse STA  													#
#	variable received from shell are:													#
#		CPU		  - number of CPU to run.8 per license										#
#		HOSTS 		  - if distributed run, will run those hosts									#
#		DESIGN_NAME	  - name of top model												#
#		PHYSICAL	  - run in physical mode											#
#		OCV 		  - run with OCV												#
#		UPDATE_IO_CLOCK_LATENCY 		  - update virtual clock latency to common clock id					#
#		VIEW 		  - the view to run on												#
#		INNOVUS_DIR 	  - location of INNOVUS directory for netlist/def database 							#
#		INTERACTIVE 	  - dont exit at end of script											#
#		XTALK_SI 	  - run with si setting 											#
#		STAGE 		  - stage of the design												#
#		RESTORE		  - restore previous run											#
#		NETLIST_FILE_LIST - netlist file list of the design										#
#		SPEF_DIR 	  - location of SPEF dir 											#
#		READ_SPEF 	  - read spef													#
#		CREATE_LIB 	  - create timing lib for block											#
#		SPEF_FILE_LIST 	  - if variable is exists and point to a file, spef will be read from that file.				#
#				    else spef location is read from setup.tcl									#
#																		#
#																		#
#	 Var	date of change	owner		 comment											#
#	----	--------------	-------	 ---------------------------------------------------------------					#
#	0.1	24/02/2021	Royl	initial script												#
#	0.2	08/06/2021	Royl	add option to create lib files										#
#	0.3	30/11/2021	Royl	add option restore previous run										#
#																		#
#																		#
#################################################################################################################################################

if {![info exists STAGE]} {set STAGE chip_finish}
#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
#source ./scripts/procs/source_be_scripts.tcl
source scripts/procs/common/procs.tcl

script_runtime_proc -start
set SPEF_DIR [sh realpath $SPEF_DIR]
set REPORTS_DIR reports

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v ./scripts_local/setup.tcl
} elseif {[file exists $INNOVUS_DIR/scripts_local/setup.tcl]} {
	puts "-I- reading setup file from $INNOVUS_DIR/scripts_local"
	source -v $INNOVUS_DIR/scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	source -v ./scripts/setup/setup.${::env(PROJECT)}.tcl
}

if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v scripts_local/supplement_setup.tcl
} elseif {[file exists $INNOVUS_DIR/scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from $INNOVUS_DIR/scripts_local"
	source -v $INNOVUS_DIR/scripts_local/supplement_setup.tcl
}



#if {[llength $VIEWS] == 1} {set mmmc_results ./scripts_local/mmmc_results_${VIEWS}.tcl}

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pt_variables.tcl]} {
	puts "-I- reading pt_variables file from scripts_local"
	source -v ./scripts_local/pt_variables.tcl
} else {
	puts "-I- reading pt_variables file from scripts"
	source -v ./scripts/flow/pt_variables.tcl
}

if {$pt_shell_mode == "primetime_master"} {
	puts "-I- prime time in master mode"
	set NUMNER_OF_VIEWS [llength $VIEWS]
	set NUMNER_OF_VIEWS_PER_SERVER [expr max(1,$NUMNER_OF_VIEWS / [llength $HOSTS])]
	if {[llength $HOSTS] > 0 && $HOSTS == "localhost"} {
		set_host_options -num_processes $NUMNER_OF_VIEWS -max_cores $CPU
	} elseif {[llength $HOSTS] > 0 && $HOSTS != "localhost"} {
		foreach host $HOSTS {
			set_host_options \
				-name "HOST_${host}" \
				-num_processes $NUMNER_OF_VIEWS_PER_SERVER \
				-max_cores $CPU \
   				-submit_command "/usr/bin/ssh" $host
			
		}
	}
} else {
	puts "-I- prime time in single mode"
	set_host_options -max_cores $CPU
}

if {$pt_shell_mode == "primetime_master"} {
	foreach view $VIEWS {
        	echo "creating scenario $view "
		set mode [lindex [split $view "_"] 0]
		set check [lindex [split $view "_"] end]
		set rc [lindex [split $view "_"] end-1]
		set temp  [lindex [split $view "_"] end-4]        
        
        puts "-D- $view - $mode $check $rc $temp"
        
		regexp "${mode}_(.*)_${rc}_${check}" $view match pvt
		if {[info exists RESTORE] && $RESTORE == "true" } {
        		create_scenario -name $view -image session/${DESIGN_NAME}/$view
		} else {
			foreach file $NETLIST_FILE_LIST {lappend files [sh realpath $file]}
			set NETLIST_FILE_LIST $files
			create_scenario -name $view \
				-specific_variables "PROJECT mode check rc pvt temp DESIGN_NAME SPEF_DIR HIER_SPEF_DIR HIER_NETLISTS_DIR GPD_DIR OCV STAGE PHYSICAL UPDATE_IO_CLOCK_LATENCY INNOVUS_DIR  NETLIST_FILE_LIST SPEF_FILE_LIST GPD_FILE_LIST READ_SPEF READ_GPD XTALK_SI  " \
        	  		-specific_data " scripts_local/pt_read_design.tcl"
		}
	}
	start_hosts
	report_host_usage 
	current_session -all

} else {
    if { [llength $VIEWS] > 1 } {
        puts "-E- You are running in SINGLE mode with multiple VIEWS"
        puts "-E- Please only select ONE VIEW or run in DMSA"
        exit
    }
	if {[info exists RESTORE] && $RESTORE == "true" } {
		restore_session session/${DESIGN_NAME}/$VIEWS
	} else { 
		set mode  [lindex [split $VIEWS "_"] 0]
		set check [lindex [split $VIEWS "_"] end]
		set rc    [lindex [split $VIEWS "_"] end-1]
		set temp  [lindex [split $VIEWS "_"] end-4]        
		regexp "${mode}_(.*)_${rc}_${check}" $VIEWS match pvt
		source -e -v scripts_local/pt_read_design.tcl
	}
}

if {![info exists RESTORE] || $RESTORE == "false" } {

#------------------------------------------------------------------------------
# merge reports
#------------------------------------------------------------------------------
	if {$pt_shell_mode == "primetime_master"} {
		source -e -v scripts/flow/pt_report_design.tcl
	}

return
#------------------------------------------------------------------------------
#    Save_Session Section                                        
#------------------------------------------------------------------------------
	if {$pt_shell_mode == "primetime_master"} {
		save_session session/${DESIGN_NAME}
	} else {
		save_session session/${DESIGN_NAME}/$VIEWS
	}
}	; # if $RESTORE == "false"

#------------------------------------------------------------------------------
#    save lib                                         
#------------------------------------------------------------------------------
if {[info exists CREATE_LIB] && $CREATE_LIB == "true"} {
	set cmddb  "extract_model -output \${DESIGN_NAME}_\${mode}_\${pvt}_\${rc}_\${check} -library_cell -format {lib db}"    
	
	if {$pt_shell_mode == "primetime_master"} {
        set cmddb  "remote_execute { $cmddb }"        
	} 
	echo $cmddb
	eval $cmddb
}

#------------------------------------------------------------------------------
#    Save_Session Section                                        
#------------------------------------------------------------------------------
if {[info exists ECO] && $ECO == "true"} {
	source -e -v scripts/flow/pt_fix_eco.tcl
}

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






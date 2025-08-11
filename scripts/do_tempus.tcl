#################################################################################################################################################
#																		#
#	this script will run Tempuse STA  													#
#	variable received from shell are:													#
#		CPU		  - number of CPU to run.8 per license										#
#		HOSTS 		  - if distributed run, will run those hosts									#
#		DESIGN_NAME	  - name of top model												#
#		PHYSICAL	  - run in physical mode											#
#		OCV 		  - run with OCV												#
#		VIEW 		  - the view to run on												#
#		INNOVUS_DIR 	  - location of INNOVUS directory for netlist/def database 							#
#		SAVE_ECO_DB 	  - create eco DB for Tempus ECO										#
#		INTERACTIVE 	  - dont exit at end of script											#
#		XTALK_SI 	  - run with si setting 											#
#		STAGE 		  - stage of the design												#
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
#	0.1	08/06/2021	Royl	add option to create lib files												#
#																		#
#																		#
#################################################################################################################################################
set_db source_verbose false

if {[file exists ./tempus_user_input.tcl]} {source -e -v ./tempus_user_input.tcl}
if {![info exists STAGE]} {set STAGE chip_finish}
#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.

script_runtime_proc -start

foreach VIEW $VIEWS {
	if {![file exists ./reports/sta_$VIEW]} {exec mkdir -pv ./reports/sta_$VIEW}
}
#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v ./scripts_local/setup.tcl
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
	source -v scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#if {[llength $VIEWS] == 1} {set mmmc_results ./scripts_local/mmmc_results_${VIEWS}.tcl}

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
set_multi_cpu_usage -local_cpu $CPU 

if {[llength $HOSTS] > 0 && $HOSTS != "localhost"} {
	set_multi_cpu_usage -local_cpu $CPU -cpu_per_remote_host $CPU -remote_host [llength $HOSTS]
	if {[info command distribute_partition] != ""} {
		set_distributed_hosts -time_out 300 -ssh -add $HOSTS
		distribute_start_clients
	} else {
		set NUMBER_OF_VIEWS_PER_HOST [expr [llength $VIEWS]/[llength $HOSTS]]
		if {$NUMBER_OF_VIEWS_PER_HOST > 8} {puts "**WARNING number of VIEWS per host is grater than 8. it require more licenses." }
		set j -1
		for {set i 0} {$i < [llength $VIEWS]} { incr i} {
			if {[expr $i%$NUMBER_OF_VIEWS_PER_HOST] == 0} {	incr j 	}
			if {[llength $HOSTS] == $j} {incr j -1}
			lappend VIEWS_IN_HOST([lindex $HOSTS $j]) [lindex $VIEWS $i]
		}
		foreach host $HOSTS {
			lappend DISTRIBUTE_VIEWS_LIST $VIEWS_IN_HOST($host)
		}
		set_distributed_mmmc_mode -use_one_host_per_batch_job true -client_init_execute_script ./run_setting.tcl
		set_distributed_hosts -time_out 300 -ssh -add $HOSTS
	}
}

#------------------------------------------------------------------------------
# define and read mmmc 
#------------------------------------------------------------------------------
if {[info exists CREATE_LIB] && $CREATE_LIB == "true" && $STAGE == "syn" } {
	puts "-I- take scenarios from mmmc_setup file for stage $STAGE."
} elseif {[llength $VIEWS] == 1} {
	set scenarios(setup) $VIEWS ;  set scenarios(hold) $VIEWS ; set scenarios(dynamic) "" ; set scenarios(leakage) ""
} else {
	set all_scenarios $VIEWS
	set scenarios(setup) [list] ;  
	set scenarios(hold) [list] ; 
	set scenarios(dynamic) "" ; 
	set scenarios(leakage) ""
	foreach _VIEW $VIEWS {
		set VIEW_SPLIT [split $_VIEW "_"]
		set check [lindex $VIEW_SPLIT end]
		if {$check == "setup" } {
			lappend scenarios(setup) $_VIEW
		} elseif {$check == "hold" } {
			lappend scenarios(hold) $_VIEW
		} else {
			lappend scenarios(setup) $_VIEW
			lappend scenarios(hold) $_VIEW
		}
	}
}


source scripts/flow/mmmc_create.tcl
mmmc_create
 
#------------------------------------------------------------------------------
# read  design
#------------------------------------------------------------------------------
if {[info command distribute_partition] == "" && [llength $HOSTS] > 1} {
	distribute_read_design -design_script ./scripts/flow/read_design.tcl -out_dir dmmmc_rundir
} else {
	source ./scripts/flow/read_design.tcl
}



if {[info exists DISTRIBUTE_VIEWS_LIST]} {
	puts "" > scripts_local/blank.tcl
	puts "set_db distributed_mmmc_disable_reports_auto_redirection true" > scripts_local/distribute_views_variables.tcl
	distribute_views -views $DISTRIBUTE_VIEWS_LIST -script scripts_local/blank.tcl
	distribute_views -views $DISTRIBUTE_VIEWS_LIST -script scripts_local/distribute_views_variables.tcl
	distribute_views -views $DISTRIBUTE_VIEWS_LIST -script scripts/report_design.tcl -write_db all
} else {
	source -e -v scripts/flow/report_design.tcl
}





#------------------------------------------------------------------------------
# merge timing reports 
#------------------------------------------------------------------------------
if {[info exists CREATE_LIB] && $CREATE_LIB == "true" && ($STAGE == "syn" || $STAGE == "place" )} {
} else {
   foreach CHECK {late early} {
	report_timing -${CHECK}                -net -max_paths 10000 -path_type full_clock > reports/${CHECK}.all.viol.tarpt
	report_timing -${CHECK} -group in2reg  -net -max_paths 10000 -path_type full_clock > reports/${CHECK}.in2reg.viol.tarpt
	report_timing -${CHECK} -group reg2reg -net -max_paths 10000 -path_type full_clock > reports/${CHECK}.reg2reg.viol.tarpt
	report_timing -${CHECK} -group reg2out -net -max_paths 10000 -path_type full_clock > reports/${CHECK}.reg2out.viol.tarpt
	report_timing -${CHECK} -group in2out  -net -max_paths 10000 -path_type full_clock > reports/${CHECK}.in2reg.viol.tarpt
	report_timing -${CHECK} -group reg2reg -net -max_paths 500000 -nworst 1000 -max_slack 0 -retime path_slew_propagation -path_type full_clock > reports/${CHECK}.reg2reg.retime.viol.tarpt
	
	exec gawk -f scripts/bin/slacks.awk reports/${CHECK}.all.viol.tarpt     > reports/${CHECK}.all.summary
	exec gawk -f scripts/bin/slacks.awk reports/${CHECK}.in2reg.viol.tarpt  > reports/${CHECK}.in2reg.summary
	exec gawk -f scripts/bin/slacks.awk reports/${CHECK}.reg2reg.viol.tarpt > reports/${CHECK}.reg2reg.summary
	exec gawk -f scripts/bin/slacks.awk reports/${CHECK}.reg2out.viol.tarpt > reports/${CHECK}.reg2out.summary
	exec gawk -f scripts/bin/slacks.awk reports/${CHECK}.in2reg.viol.tarpt  > reports/${CHECK}.in2reg.summary
	exec gawk -f scripts/bin/slacks.awk reports/${CHECK}.reg2reg.retime.viol.tarpt > reports/${CHECK}.reg2reg.retime.summary
   }

   report_constraint -all_violators -drv_violation_type max_capacitance 		> reports/cap_vios.rpt
   report_constraint -all_violators -drv_violation_type max_transition  		> reports/tran_vios.rpt
   report_constraint -all_violators -by_driver -drv_violation_type max_transition  > reports/tran_vios_driver.rpt
   report_timing     -check_type pulse_width  -max_slack 0 -max_paths 10000 -path_type full_clock > reports/min_pulse_width.rpt
   report_timing     -check_type clock_period -max_slack 0 -max_paths 10000 -path_type full_clock > reports/clock_period.rpt
   if {[info exists XTALK_SI]  && $XTALK_SI == "true" } {
   	report_noise -failure -sort_by noise -out_file reports/SI_failure.txt
   	report_noise -noisy_waveform         -out_file reports/SI_noise.txt
   }
   report_double_clocking -nworst 10000 		> reports/SI_double_clocking.txt
} ; #if {[info exists CREATE_LIB] && $CREATE_LIB == "true" && $STAGE == "syn"} 

#------------------------------------------------------------------------------
# save lib 
#------------------------------------------------------------------------------
if {[info exists CREATE_LIB] && $CREATE_LIB == "true" } {
   set ANALYSIS_VIEWS [get_db analysis_views .name]
   if {[regexp {setup|hold} $ANALYSIS_VIEWS]} {
   	set_analysis_view -setup $ANALYSIS_VIEWS -hold $ANALYSIS_VIEWS
   }
   
   foreach view_dpo [get_db analysis_views .name] {
	write_timing_model -view $view_dpo out/lib/${DESIGN_NAME}.${STAGE}.${view_dpo}.lib.gz -lib_name ${DESIGN_NAME}_${view_dpo}
   }
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




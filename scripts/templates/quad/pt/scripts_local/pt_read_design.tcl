#################################################################################################################################################
#																		#
#	this script will run read design to prime time slave or single  									#
#																		#
#																		#
#	 Var	date of change	owner		 comment											#
#	----	--------------	-------	 ---------------------------------------------------------------					#
#	0.1	24/02/2021	Royl	initial script												#
#																		#
#																		#
#################################################################################################################################################
source $sh_launch_dir/scripts/procs/common/procs.tcl

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists $sh_launch_dir/scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -e -v $sh_launch_dir/scripts_local/setup.tcl
	
} elseif {[file exists $INNOVUS_DIR/scripts_local/setup.tcl]} {
	puts "-I- reading setup file from $INNOVUS_DIR/scripts_local"
	source -e -v $INNOVUS_DIR/scripts_local/setup.tcl
	
} else {
	puts "-I- reading setup file from scripts"
	source -e -v $sh_launch_dir/scripts/setup/setup.${PROJECT}.tcl
}

if {[file exists $sh_launch_dir/../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -e -v $sh_launch_dir/../inter/supplement_setup.tcl
}

if {[file exists $sh_launch_dir/scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -e -v $sh_launch_dir/scripts_local/supplement_setup.tcl
} elseif {[file exists $INNOVUS_DIR/scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from $INNOVUS_DIR/scripts_local"
	source -e -v $INNOVUS_DIR/scripts_local/supplement_setup.tcl
}

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
if {[file exists $sh_launch_dir/scripts_local/pt_variables.tcl]} {
	puts "-I- reading pt_variables file from scripts_local"
	source -e -v $sh_launch_dir/scripts_local/pt_variables.tcl
} else {
	puts "-I- reading pt_variables file from scripts"
	source -e -v $sh_launch_dir/scripts/flow/pt_variables.tcl
}

regsub -all "\.lib " [regsub -all "\.lib\.gz " $pvt_corner($pvt,timing) "\.db "] "\.db " TARGET_LIBRARY_FILES
regsub -all {prod(\S+BSI)} $TARGET_LIBRARY_FILES {int\1} TARGET_LIBRARY_FILES            

set TEV_OP_MODE [lindex [split $pvt "_"] end]

set search_path "."
set target_library $TARGET_LIBRARY_FILES
set link_path "* $target_library "

if {![info exists REPORTS_DIR]} {set REPORTS_DIR "."}

##################################################################
#    Netlist Reading Section                                     #
##################################################################
set link_path "* $link_path"
if { [info exists HIER_NETLISTS_DIR] && $HIER_NETLISTS_DIR != "" } {
    set netlist_files [glob $HIER_NETLISTS_DIR/*]
    set NETLIST_FILE_LIST [concat $NETLIST_FILE_LIST $netlist_files]
}
read_verilog $NETLIST_FILE_LIST

current_design $DESIGN_NAME 
link -verbose


##################################################################
#    Back Annotation Section                                     #
##################################################################
if {[info exists XTALK_SI] && $XTALK_SI == "true"} {
	set KEEP_CAPACITIVE_COUPLING "-keep_capacitive_coupling"
} else {
	set KEEP_CAPACITIVE_COUPLING ""
}

if {[info exists READ_SPEF] && $READ_SPEF == "true"} {
	
    if {[info exists SPEF_FILE_LIST] && $SPEF_FILE_LIST != ""} {
		puts "-I- reading parasitic from $SPEF_FILE_LIST"
	} else {
		set SPEF_FILE_LIST $rc_corner($rc,spef_$pvt_corner($pvt,temperature))    
    }

    if { [info exists HIER_SPEF_DIR] && $HIER_SPEF_DIR != "" } {
        puts "-I- Getting hierarchical spef files from: $HIER_SPEF_DIR"
        set spef_files [regexp -all -inline " (\[a-zA-Z0-9/_\\\.\]+\\\.${rc}_$temp)" [glob $HIER_SPEF_DIR/*]]
        set SPEF_FILE_LIST [concat $SPEF_FILE_LIST $spef_files]    
    } 
	
    puts "-I- Parasitic files list:"
    puts [join $SPEF_FILE_LIST "\n"]
    
	foreach para_file $SPEF_FILE_LIST {
        puts "-I- Reading para_file $para_file"
        set para_file [regsub " " $para_file ""]
        if { ![file exists $para_file] } { puts "-E- File $para_file not exists" ; continue }
		if {[regexp $DESIGN_NAME [lindex [split $para_file "/"] end]]} {
			puts "-I- reading TOP parasitic $para_file"
     		read_parasitics -keep_capacitive_coupling $para_file 
		} else {
			set HLB_NAME [lindex [split [lindex [split $para_file /] end] .] 0]
			puts "-I- reading $HLB_NAME parasitic $para_file"
			if {[sizeof_collection [get_cells -hierarchical -filter "ref_name == $HLB_NAME" -quiet]] == 0} {
				puts "Warning: $HLB_NAME does not instatuated in the design. (NS-001)"
			} else {
				foreach_in_collection  HLB_INST [get_cells -hierarchical -filter "ref_name == $HLB_NAME" -quiet] {
     				read_parasitics -path [get_object_name $HLB_INST] -keep_capacitive_coupling $para_file 
				}
			}
		}
	}
	report_annotated_parasitics -list_not_annotated > $REPORTS_DIR/report_annotated_parasitics_list_not_annotated.rpt
} elseif {[info exists READ_GPD] && $READ_GPD == "true"} {
	set parasitic_corner_name  "${rc}_$pvt_corner($pvt,temperature)"
	
	if {[info exists GPD_FILE_LIST] && $GPD_FILE_LIST != ""} {
		puts "-I- reading parasitic from $GPD_FILE_LIST"
	} else {
		set GPD_FILE_LIST $rc_corner(gpd_file)
	}
	
	foreach para_file $GPD_FILE_LIST {
		if {[regexp $DESIGN_NAME $para_file]} {
			puts "-I- reading TOP GPD parasitic $para_file"
	      		read_parasitics -format GPD $KEEP_CAPACITIVE_COUPLING $para_file 
		} else {
			set HLB_NAME [lindex [split [lindex [split $para_file /] end] .] 0]
			puts "-I- reading $HLB_NAME parasitic $para_file"
			if {[sizeof_collection [get_cells -hierarchical -filter "ref_name == $HLB_NAME" -quiet]] == 0} {
				puts "Warning: $HLB_NAME does not instatuated in the design. (NS-001)"
			} else {
				foreach_in_collection  HLB_INST [get_cells -hierarchical -filter "ref_name == $HLB_NAME" -quiet] {
      					read_parasitics -path [get_object_name $HLB_INST] -format GPD -keep_capacitive_coupling $para_file 
				}
			}
		}
	}
	report_annotated_parasitics -list_not_annotated > $REPORTS_DIR/report_annotated_parasitics_list_not_annotated.rpt
}

##################################################################
#    Reading Constraints Section                                 #
##################################################################
foreach constraint_file $sdc_files($mode) {
 	set sss [lindex [split $constraint_file /] end]
	redirect -file $REPORTS_DIR/read_${sss}   {source -e -v $constraint_file}
#	source -e -v $constraint_file
}


##################################################################
#    Setting Derate and CRPR Section                             #
##################################################################

if { [info exists pvt_corner($pvt,pt_pocv)]} {
    foreach pocvm_file $pvt_corner($pvt,pt_pocv) {
    	puts "-I- reading OCVM file: $pocvm_file"
        read_ocvm $pocvm_file
    }
}

# TODO - check this file in PT - /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_ck06t0750v.coefficient

if { [info exists pvt_corner($pvt,pt_ocv)]} {
    foreach pocvm_file $pvt_corner($pvt,pt_ocv) {
    	puts "-I- reading derate file: $pocvm_file"
        source -e -v $pocvm_file
    }
}



##################################################################
#    Update_timing and check_timing Section                      #
##################################################################
if {$STAGE == "cts" || $STAGE == "route" || $STAGE == "chip_finish"} {
	set_propagated_clock [get_clocks ]
}

##################################################################
#    automatic clock latency for virtual clock                   #
##################################################################
if {[info exists UPDATE_IO_CLOCK_LATENCY] && $UPDATE_IO_CLOCK_LATENCY == "true"} {
	set IO_CLOCK_LATENCY 0
	set NUM_OF_PATH 0
	foreach LATENCY [get_attribute  [get_timing_paths -from [get_clocks -filter "full_name !~ virtual*"] -max_paths 5000 -slack_lesser_than 100] startpoint_clock_latency] {
		set IO_CLOCK_LATENCY [expr $IO_CLOCK_LATENCY + $LATENCY]
		incr NUM_OF_PATH
	}
	foreach LATENCY [get_attribute  [get_timing_paths -to [get_clocks -filter "full_name !~ virtual*"] -max_paths 5000 -slack_lesser_than 100] endpoint_clock_latency] {
		set IO_CLOCK_LATENCY [expr $IO_CLOCK_LATENCY + $LATENCY]
		incr NUM_OF_PATH
	}
	set IO_CLOCK_LATENCY [expr $IO_CLOCK_LATENCY /$NUM_OF_PATH]
	set_clock_latency $IO_CLOCK_LATENCY [get_clocks virtual*] 

}

##################################################################
#    set group path 			                         #
##################################################################
group_path -name reg2reg -from [filter_collection [all_registers -clock_pins ] "is_clock_gating_pin==false"] -to [all_registers -data_pins ]
group_path -name reg2out -from [filter_collection [all_registers -clock_pins ] "is_clock_gating_pin==false"] -to [all_outputs ]
group_path -name in2reg  -from [all_inputs ] -to [all_registers -data_pins ]
group_path -name in2out  -from [all_inputs ] -to [all_outputs ]

##################################################################
#    set false path to setup/hold 	                         #
##################################################################
if {$check == "setup"} {
	#set_false_path -hold -to [all_clocks]
} else {
	#set_false_path -setup -to [all_clocks]
}





update_timing -full
check_timing -verbose > $REPORTS_DIR/check_timing.report

##################################################################
#    local reports 			                         #
##################################################################
if {$check == "setup"} {
	set delay_type  "max"
} else {
	set delay_type  "min"
}

report_timing 		     -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode exhaustive > $REPORTS_DIR/${check}_all.rpt
report_timing -group reg2reg -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode exhaustive > $REPORTS_DIR/${check}_reg2reg.rpt
report_timing -group in2reg  -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode exhaustive > $REPORTS_DIR/${check}_in2reg.rpt
report_timing -group reg2out -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode exhaustive > $REPORTS_DIR/${check}_reg2out.rpt
report_timing -group in2out  -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode exhaustive > $REPORTS_DIR/${check}_in2out.rpt
exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check}_all.rpt     | sort -n > $REPORTS_DIR/${check}_all.summary
exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check}_reg2reg.rpt | sort -n > $REPORTS_DIR/${check}_reg2reg.summary
exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check}_in2reg.rpt  | sort -n > $REPORTS_DIR/${check}_in2reg.summary
exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check}_reg2out.rpt | sort -n > $REPORTS_DIR/${check}_reg2out.summary
exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check}_in2out.rpt  | sort -n > $REPORTS_DIR/${check}_in2out.summary

report_clock -skew -attribute > $REPORTS_DIR/report_clock.report 
report_si_double_switching -nosplit -rise -fall > $REPORTS_DIR/report_si_double_switching.report
report_ocvm -type pocvm > $REPORTS_DIR/report_pocvm.report

# Noise Settings
set_noise_parameters -enable_propagation -analysis_mode report_at_endpoint
check_noise > $REPORTS_DIR/check_noise.report
update_noise
# Noise Reporting
report_noise -nosplit -all_violators -above -low > $REPORTS_DIR/report_noise_all_viol_abv_low.report
report_noise -nosplit -nworst 10 -above -low > $REPORTS_DIR/report_noise_alow.report

report_noise -nosplit -all_violators -below -high > $REPORTS_DIR/report_noise_all_viol_below_high.report
report_noise -nosplit -nworst 10 -below -high > $REPORTS_DIR/report_noise_below_high.report


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
# case 01284397  hotfix to save primetime session. version must be 2012 ot later
# does not work for version U-2022.12-SP5-2
if {[regexp "S-2021" [get_app_var sh_product_version]]} {
	source $sh_launch_dir/scripts/bin/physical_variant_cells_link_to_master_cell_v2_2009_2106_210820.tbc
}

#source $sh_launch_dir/scripts/procs/common/procs.tcl
source $sh_launch_dir/scripts/procs/source_be_scripts.tcl

if {$pt_shell_mode != "primetime_master"} {
	script_runtime_proc -start
}
#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists $sh_launch_dir/scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -e -v $sh_launch_dir/scripts_local/setup.tcl
	
} elseif {[file exists $PNR_DIR/scripts_local/setup.tcl]} {
	puts "-I- reading setup file from $PNR_DIR/scripts_local"
	source -e -v $PNR_DIR/scripts_local/setup.tcl
	
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
} elseif {[file exists $PNR_DIR/scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from $PNR_DIR/scripts_local"
	source -e -v $PNR_DIR/scripts_local/supplement_setup.tcl
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

set new_list {}
foreach file $pvt_corner($pvt,timing) {
    	if       { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue
    	} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue    
    	} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue
    	} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue
    	} else {
		regsub {/prod/} $file {/int/} file_            
    		if       { [regsub "\.lib\.gz\$" $file_ "\.db"     new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue
    		} elseif { [regsub "\.lib\.gz\$" $file_ "_lib\.db" new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue    
    		} elseif { [regsub "\.lib\$"     $file_ "\.db"     new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue
    		} elseif { [regsub "\.lib\$"     $file_ "_lib\.db" new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue
    		} else {
        		puts "Error: File $file have no .db version in folder. (NS_LIB01)"
		}
    	}        
}
set TARGET_LIBRARY_FILES $new_list
#regsub -all "\.lib " [regsub -all "\.lib\.gz " $pvt_corner($pvt,timing) "\.db "] "\.db " TARGET_LIBRARY_FILES
#regsub -all {prod(\S+BSI)} $TARGET_LIBRARY_FILES {int\1} TARGET_LIBRARY_FILES            

set TEV_OP_MODE [lindex [split $pvt "_"] end]

set search_path "."
set target_library $TARGET_LIBRARY_FILES
set link_path "* $target_library "

if {![info exists REPORTS_DIR]} {set REPORTS_DIR "."}

##################################################################
#    Netlist Reading Section                                     #
##################################################################
set link_path "* $link_path"
foreach file $NETLIST_FILE_LIST {
	read_verilog $file
}
#read_verilog $NETLIST_FILE_LIST
current_design $DESIGN_NAME 
link


##################################################################
#    Back Annotation Section                                     #
##################################################################
if {[info exists XTALK_SI] && $XTALK_SI == "true"} {
	set KEEP_CAPACITIVE_COUPLING "-keep_capacitive_coupling"
} else {
	set KEEP_CAPACITIVE_COUPLING ""
}

if {[info exists READ_SPEF] && $READ_SPEF == "true"} {
	
	if {[info exists SPEF_FILE_LIST] && $SPEF_FILE_LIST != "None"} {
		puts "-I- reading parasitic from $SPEF_FILE_LIST"
	} else {
		puts "-I- reading parasitic from setup file: rc_corner($rc,spef_$pvt_corner($pvt,temperature))"
		set SPEF_FILE_LIST $rc_corner($rc,spef_$pvt_corner($pvt,temperature))    
	}

	if { [info exists HIER_SPEF_DIR] && $HIER_SPEF_DIR != "" } {
        	puts "-I- Getting hierarchical spef files from: $HIER_SPEF_DIR"
        	set spef_files [glob $HIER_SPEF_DIR/*]
        	set SPEF_FILE_LIST [concat $SPEF_FILE_LIST $spef_files]    
    	} 

    	puts "-I- Parasitic files list:"
    	puts [join $SPEF_FILE_LIST "\n"]

	foreach para_file $SPEF_FILE_LIST {
        	puts "-I- Reading para_file $para_file"
        	set para_file [regsub " " $para_file ""]
        	if { ![file exists $para_file] } { puts "Error: File $para_file not exists. (NS_SPEF01)" ; continue }
		if {[regexp $DESIGN_NAME [lindex [split $para_file "/"] end]]} {
			puts "-I- reading TOP parasitic $para_file"
     			read_parasitics -keep_capacitive_coupling $para_file 
		} else {
			set HLB_NAME [lindex [split [lindex [split $para_file /] end] .] 0]
			if {[sizeof_collection [get_cells -hierarchical -filter "ref_name == ${HLB_NAME}_for_spef" -quiet]] == 0} {
				puts "Warning: ${HLB_NAME}_for_spef does not instatuated in the design. (NextSi-601)"
                		puts "-I- Looking for $HLB_NAME instead"
                		if {[sizeof_collection [get_cells -hierarchical -filter "ref_name == ${HLB_NAME}" -quiet]] != 0} {
                    			set HLB_STR $HLB_NAME
                		} else {
    					puts "Warning: ${HLB_NAME} does not instatuated in the design. (NextSi-602)"
                		}
			} else {
                		set HLB_STR "${HLB_NAME}_for_spef"
			}
   			puts "-I- Reading $HLB_STR parasitic $para_file"
			foreach_in_collection  HLB_INST [get_cells -hierarchical -filter "ref_name == $HLB_STR" -quiet] {
     				read_parasitics -path [get_object_name $HLB_INST] -keep_capacitive_coupling $para_file 
			}
		}
	}
	report_annotated_parasitics -list_not_annotated > $REPORTS_DIR/report_annotated_parasitics_list_not_annotated.rpt
} elseif {[info exists READ_GPD] && $READ_GPD == "true"} {
	set parasitic_corner_name  "${rc}_$pvt_corner($pvt,temperature)"
	
	if {[info exists GPD_FILE_LIST] && $GPD_FILE_LIST != "None" && $GPD_FILE_LIST != ""} {
		puts "-I- reading parasitic from $GPD_FILE_LIST"
	} elseif {[info exists GPD_FILES ] && $GPD_FILES != "None" && $GPD_FILES != ""} {
		puts "-I- reading user input parasitic file ${GPD_FILES}"
		set GPD_FILE_LIST ${GPD_FILES}
	} else {
		set GPD_FILE_LIST $rc_corner(gpd_file)
	}
    
    	if { [info exists HIER_GPD_DIR] && $HIER_GPD_DIR != "" } {
        	puts "-I- Getting hierarchical spef files from: $HIER_GPD_DIR"
        	set gpd_files [glob $HIER_GPD_DIR/*]
        	set GPD_FILE_LIST [concat $GPD_FILE_LIST $gpd_files]    
    	} 

    	puts "-I- Parasitic files list:"
   	puts [join $GPD_FILE_LIST "\n"]
	
	foreach para_file $GPD_FILE_LIST {
        	puts "-I- Reading para_file $para_file"
        	set para_file [regsub " " $para_file ""]
        	if { ![file exists $para_file] } { puts "Error: File $para_file not exists. (NS_SPEF01)" ; continue }
		if {[regexp $DESIGN_NAME [lindex [split $para_file "/"] end]]} {
			puts "-I- reading TOP parasitic $para_file"
			if {$KEEP_CAPACITIVE_COUPLING == ""} {
	      			read_parasitics -format GPD $para_file
			} else {
	      			read_parasitics -format GPD -keep_capacitive_coupling $para_file
			}
		} else {
			set HLB_NAME [lindex [split [lindex [split $para_file /] end] .] 0]
			if {[sizeof_collection [get_cells -hierarchical -filter "ref_name == ${HLB_NAME}_for_spef" -quiet]] == 0} {
				puts "Warning: ${HLB_NAME}_for_spef does not instatuated in the design. (NextSi-601)"
				puts "-I- Looking for $HLB_NAME instead"
                		if {[sizeof_collection [get_cells -hierarchical -filter "ref_name == ${HLB_NAME}" -quiet]] != 0} {
                    			set HLB_STR $HLB_NAME
                		} else {
    					puts "Warning: ${HLB_NAME} does not instatuated in the design. (NextSi-602)"
                		}
			} else {
                		set HLB_STR "${HLB_NAME}_for_spef"
			}
   			puts "-I- Reading $HLB_STR parasitic $para_file"
			foreach_in_collection  HLB_INST [get_cells -hierarchical -filter "ref_name == $HLB_STR" -quiet] {
                		read_parasitics -path [get_object_name $HLB_INST] -format GPD -keep_capacitive_coupling $para_file 
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

foreach_in_collection clock_cell [remove_from_collection [all_fanout -clock_tree -only_cells] [filter_collection [all_registers ] "!is_integrated_clock_gating_cell"]] {
	set ref_name [get_att $clock_cell ref_name]
	set inst_name [get_object_name $clock_cell]
	if {![regexp "F6UN" $ref_name]} { 
		puts "Warning: $inst_name inst on clock netwoek with different VT allowed ($ref_name). adding extra derate on inst."
		set cmd "set CLOCK_EXCEPTIONS($inst_name) \"\""
		puts "\t$cmd"
		eval $cmd
	}
}

##################################################################
#    Setting Derate and CRPR Section                             #
##################################################################
if {[info exists OCV] &&$OCV == "pocv"} {
	if { [info exists pvt_corner($pvt,pt_pocv)]} {
    		foreach pocvm_file $pvt_corner($pvt,pt_pocv) {
    			puts "-I- reading OCVM file: $pocvm_file"
        		read_ocvm $pocvm_file
    		}
	}
	if { [info exists pvt_corner($pvt,pt_ocv)]} {
    		foreach pocvm_file $pvt_corner($pvt,pt_ocv) {
    			puts "-I- reading derate file: $pocvm_file"
        		source -e -v $pocvm_file
    		}
	}
} elseif {[info exists OCV] &&$OCV == "flat"} {
	 if {[info exists pvt_corner($pvt,flat_mem_ocv)] && [llength $pvt_corner($pvt,flat_mem_ocv)] == 2} {
	     set all_macro_cells [get_cells -quiet -hier -filter is_memory_cell]
             if {[sizeof_collection $all_macro_cells] > 0} {
	     	puts "-I- setting flat OCV check and data for corner $pvt on memories"
	     	set_timing_derate [lindex $pvt_corner($pvt,flat_mem_ocv) 0 0] -late  -cell_check  [get_lib_cells -of_objects $all_macro_cells ]
	     	set_timing_derate [lindex $pvt_corner($pvt,flat_mem_ocv) 0 1] -early -cell_check  [get_lib_cells -of_objects $all_macro_cells ]
	     	set_timing_derate [lindex $pvt_corner($pvt,flat_mem_ocv) 1 0] -late  -data   [get_lib_cells -of_objects $all_macro_cells ]
	     	set_timing_derate [lindex $pvt_corner($pvt,flat_mem_ocv) 1 1] -early -data   [get_lib_cells -of_objects $all_macro_cells ]
	     }
	 }
	    
	 if {[info exists pvt_corner($pvt,flat_ocv)] && [llength $pvt_corner($pvt,flat_ocv)] == 2} {
	     puts "-I- setting flat OCV clock and data for corner $pvt"
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 0 0] -late  -clock -cell_delay 
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 0 1] -early -clock -cell_delay 
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 1 0] -late  -data  -cell_delay 
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 1 1] -early -data  -cell_delay 
	 } elseif {[info exists pvt_corner($pvt,flat_ocv)] && [llength $pvt_corner($pvt,flat_ocv)] == 1} {
	     puts "-I- setting flat OCV clock only for corner $pvt"
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 0] -late  -clock -cell_delay 
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 1] -early -clock -cell_delay 
	 } else {
	     puts "-W- missing derate values for corner $pvt"
	 }
	
} else {
	puts "Warning: running withou OCV"
}




##################################################################
#    Update_timing and check_timing Section                      #
##################################################################
set realclock [all_clocks]
if {$STAGE == "cts" || $STAGE == "route" || $STAGE == "chip_finish"} {
	foreach_in_collection ccc [get_clocks] {
		if {![llength [get_attribute [get_clocks $ccc] sources -quiet]]} {
			puts [get_object_name $ccc]
			set realclock [remove_from_collection $realclock  $ccc]
		}
	}
	if {[sizeof_collection $realclock] > 0} {
		set_propagated_clock [get_clocks $realclock]
	} else {
		puts "Warning: No real clocks in the design"
	}
}

##################################################################
#    automatic clock latency for virtual clock                   #
##################################################################
if {[info exists IO_CLOCK_LATENCY] && $IO_CLOCK_LATENCY == "true"} {
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

##################################################################
#    SI inf window on interface
##################################################################
set ports_fanout [get_nets -top_net_of_hierarchical_group -segments -of_objects [all_fanout -flat -from [get_ports * -filter "direction==in"]]]
set_si_delay_analysis -ignore_arrival $ports_fanout
set_si_noise_analysis -ignore_arrival $ports_fanout
set ports_fanin [get_nets -top_net_of_hierarchical_group -segments -of_objects [all_fanin -flat -to [get_ports * -filter "direction==out"]]]
set_si_delay_analysis -ignore_arrival $ports_fanin
set_si_noise_analysis -ignore_arrival $ports_fanin

if {[file exists ${sh_launch_dir}/scripts_local/pre_pt_setting.tcl]} {
	puts "-I- reading pt setting file ${sh_launch_dir}/scripts_local/pre_pt_setting.tcl"
	source -e -v ${sh_launch_dir}/scripts_local/pre_pt_setting.tcl
}

update_timing -full
check_timing -verbose > $REPORTS_DIR/check_timing.report

#if {![info exists CREATE_LIB_ONLY] || $CREATE_LIB_ONLY == "false"} {
if {![info exists TIMING_REPORTS] || $TIMING_REPORTS == "true"} {
   
   ##################################################################
   #    local reports 			                         #
   ##################################################################
   foreach delay_type  {max min} {
   if {$delay_type == "min"} {
   	set check__ "hold"
   } else {
   	set check__ "setup"
   }
   #if {$check == "setup"} {
   #	set delay_type  "max"
   #} else {
   #	set delay_type  "min"
   #}
   
   	report_timing 		     -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_all.rpt
   	report_timing -group reg2reg -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_reg2reg.rpt
   	report_timing -group in2reg  -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_in2reg.rpt
   	report_timing -group reg2out -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_reg2out.rpt
   	report_timing -group in2out  -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_in2out.rpt
   	exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check__}_all.rpt     | sort -n > $REPORTS_DIR/${check__}_all.summary
   	exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check__}_reg2reg.rpt | sort -n > $REPORTS_DIR/${check__}_reg2reg.summary
   	exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check__}_in2reg.rpt  | sort -n > $REPORTS_DIR/${check__}_in2reg.summary
   	exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check__}_reg2out.rpt | sort -n > $REPORTS_DIR/${check__}_reg2out.summary
   	exec gawk -f $sh_launch_dir/scripts/bin/slacks.awk $REPORTS_DIR/${check__}_in2out.rpt  | sort -n > $REPORTS_DIR/${check__}_in2out.summary

	exec $sh_launch_dir/scripts/bin/timing_filter.pl $REPORTS_DIR/${check__}_reg2reg.rpt
	exec $sh_launch_dir/scripts/bin/timing_filter.pl $REPORTS_DIR/${check__}_in2reg.rpt
	exec $sh_launch_dir/scripts/bin/timing_filter.pl $REPORTS_DIR/${check__}_reg2out.rpt
	exec $sh_launch_dir/scripts/bin/timing_filter.pl $REPORTS_DIR/${check__}_in2out.rpt


   }
   
   report_constraints -nosplit -all_violators -max_capacitance  > $REPORTS_DIR/max_capacitance.rpt
   report_constraints -nosplit -all_violators -max_transition   > $REPORTS_DIR/max_transition.rpt
   report_constraints -nosplit -all_violators -min_pulse_width  > $REPORTS_DIR/min_pulse_width.rpt
   report_constraints -nosplit -all_violators -min_period       > $REPORTS_DIR/min_period.rpt
   
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
   
   if { [file exists $sh_launch_dir/scripts_local/additional_reports.tcl ] } {
       puts "-I- Running additional reports from $sh_launch_dir/scripts_local/additional_reports.tcl"
       source $sh_launch_dir/scripts_local/additional_reports.tcl
   }
   
   puts "-I- memory usage for read_design: [mem] KB"
   if {$pt_shell_mode != "primetime_master"} {
   	script_runtime_proc -end
   }
} ; #if {![info exists TIMING_REPORTS] || $TIMING_REPORTS == "true"}
#############################################################
# write HS model
#############################################################
if { [info exists CREATE_HS] && $CREATE_HS } {
    if { [file exists out/hs] } { if { [file exists out/prev_hs] } { rm -rf out/prev_hs } ; sh mv out/hs out/prev_hs }
    sh mkdir -pv out/hs
    set tag "${pvt}_$rc"
    puts "-I- Generating HS model in out/hs/${DESIGN_NAME}.${tag}.hs"
    write_hier_data -parasitics gpd_format out/hs/${DESIGN_NAME}.${tag}.hs
}

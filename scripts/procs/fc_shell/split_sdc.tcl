proc split_sdc { mode corner scenario } {


	global sdc_files
	
	if {![file exists ./sdc]} {exec mkdir sdc}
#	set mode_fi [open sdc/mode.sdc w]
#	set corner_fi [open sdc/corner.sdc w]
#	set scenario_fi [open sdc/scenario.sdc w]
#	set general_fi [open sdc/general.sdc w]	

#	set modes [get_modes ]
#	set corners [get_corners]
#	set scenarios [get_scenarios -filter active]
	
	set mode_commands {create_clock create_generated_clock  set_clock_groups set_case_analysis set_disable_timing set_multicycle_path set_min_delay set_max_delay set_propagated_clock set_clock_sense set_clock_exclusivity set_false_path set_clock_gating_check group_path}
	set corner_commands {set_load set_timing_derate set_operating_conditions set_voltage }
	set scenario_commands {set_clock_uncertainty set_input_delay set_output_delay set_input_transition set_max_transition set_clock_transition set_ideal_transition set_annotated_transition set_annotated_delay set_clock_balance_points set_clock_latency set_clock_jitter set_clock_gate_latency set_data_check set_ideal_latency set_max_time_borrow set_min_pulse_width set_max_fanout set_max_capacitance set_min_capacitance set_drive set_driving_cell}

#	set files [list $mode_fi $corner_fi $scenario_fi $general_fi]
	set in_file 0
	set in_command 0
	set in_block 0
	set block_file 4
	set cnt_c 0
	set cnt_o 0
	set cmd_lst [list "" "" "" ""]
	
	
	set mode_fi     [open sdc/mode_${mode}.sdc w]
	set corner_fi   [open sdc/corner_${corner}.sdc w]
	set scenario_fi [open sdc/scenario_${scenario}.sdc w]
	set general_fi  [open sdc/general_${scenario}.sdc w]	
	set files [list $mode_fi $corner_fi $scenario_fi $general_fi]

	set lst [list $mode_commands $corner_commands $scenario_commands]
	set lst_sdc $sdc_files($mode)
		
	foreach constraint_file $lst_sdc {
		set sdc_fi [open $constraint_file r]
		while {[gets $sdc_fi line] >= 0} {
			set trimmed_line [string trim $line]
			set cmd [lindex [split $trimmed_line] 0]
			if {![regexp ^# $trimmed_line]} {
				incr cnt_o [regexp -all {\{} $trimmed_line]
     				incr cnt_c [regexp -all {\}} $trimmed_line]
			}

			if {!$in_block && ([string match "for*\{" $trimmed_line] || [string match "while*\{" $trimmed_line] || [string match "if*\{" $trimmed_line])} {
        			set in_block 1
        			set block_content "$line\n"
        			continue
    			}


			if {$in_command} {
				if {$in_block} {
					if {$in_file == 4} {
						for {set i 0} {$i < 4} {incr i} {
             						if {[lindex $cmd_lst $i]!="" || [expr $i == $in_file -1]} {
								set value [lindex $cmd_lst $i]
								append value "$line\n"
								set cmd_lst [lreplace $cmd_lst $i $i $value]
							}   
        					} 
						append block_content "\n$trimmed_line"
							
					} else {
						set value [lindex $cmd_lst $in_file-1]
						append value "$line\n"
						set cmd_lst [lreplace $cmd_lst $in_file-1 $in_file-1 $value]
					}	
				} else {
					puts [lindex $files $in_file-1] $line
				}
				set in_command 0
				
			} else {

  				set found 0

    				for {set j 0} {$j < [llength $lst]} {incr j} {
					set l [lindex $lst $j]
        				foreach pattern $l {
            					if {[regexp $pattern $line]} {
                					set found 1
							set in_file [expr $j + 1]
                					break
            					}
        				}
        				if {$found} {
            					break
        				}

    				}
				if {!$found} {
            				set in_file [expr $j + 1]	
				}

					

				if {$in_block} {
												
					if {$cnt_o==$cnt_c} {
						set block_content [split [string trim $block_content] "\n"]
						foreach bc $block_content {
							for {set i 0} {$i < 4} {incr i} {
								set tmp_str [lindex $cmd_lst $i]
             							if {$tmp_str!="" && [string first $bc $tmp_str] == -1} {
									puts [lindex $files $i] "$bc"
								}   
        						}			
						}
						for {set i 0} {$i < 4} {incr i} {
             						if {[lindex $cmd_lst $i]!=""} {
								puts [lindex $files $i] "[lindex $cmd_lst $i]$line"
							}   
        					}
							
						set in_block 0
            					set block_content ""
						set cmd_lst [list "" "" "" ""]
					} elseif {[string match "\} else*" $trimmed_line] || [string match "for*" $trimmed_line] || [string match "if*" $trimmed_line] || [string match "*while*" $trimmed_line] || [string match "\}*" $trimmed_line] } {
						append block_content "\n$trimmed_line"
						for {set i 0} {$i < 4} {incr i} {
             						if {[lindex $cmd_lst $i]!=""} {
								set value [lindex $cmd_lst $i]
								append value "$line\n"
								set cmd_lst [lreplace $cmd_lst $i $i $value]
							}   
        					}


					} else {
						if {$in_file == 4} {
							for {set i 0} {$i < 4} {incr i} {
             							if {[lindex $cmd_lst $i]!="" || [expr $i == $in_file -1]} {
									set value [lindex $cmd_lst $i]
									append value "$line\n"
									set cmd_lst [lreplace $cmd_lst $i $i $value]
								}   
        						} 
							append block_content "\n$trimmed_line"
						} else {					
							set value [lindex $cmd_lst $in_file-1]
							append value "$line\n"
							set cmd_lst [lreplace $cmd_lst $in_file-1 $in_file-1 $value]
						}
					}
				} else {	
					puts [lindex $files $in_file-1] $line
				}
					
			}
				
			if {[regexp {\\$} $trimmed_line]} {
				set in_command 1
			}
		}

		close $sdc_fi
	}
	close $mode_fi
	close $corner_fi
	close $scenario_fi
	close $general_fi
}


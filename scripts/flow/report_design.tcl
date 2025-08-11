#------------------------------------------------------------------------------
# read spef
#------------------------------------------------------------------------------
if {[info exists READ_SPEF] && $READ_SPEF == "true" } {
	puts "-I- reading SPEF"
	eval_legacy {set nspefOverrideTopSpefTermLocFromDB false}
	if {[info exists SPEF_FILE_LIST] && $SPEF_FILE_LIST != ""} {
		read_spef -extended -keep_star_node_locations -rc_corner [all_rc_corners -active] $SPEF_FILE_LIST
	} else {
		foreach RC_CORNER [all_rc_corners -active] {
			regexp {(\d+)} $RC_CORNER match TEMP
			regsub {_\d+} $RC_CORNER "" RC
		  	read_spef -extended -keep_star_node_locations -rc_corner $RC_CORNER [list $rc_corner($RC,spef_$TEMP)]
		}
	}
}
if {[info command distribute_partition] != ""} {
	distribute_partition
}
if {[info exists READ_SPEF] && $READ_SPEF == "true" } {
	foreach VIEW [get_db analysis_views  .name] {
	   report_annotated_parasitics > reports/sta_$VIEW/annotations_summary.rpt
	   report_annotated_parasitics \
		-not_annotated_nets \
		-unloaded_nets \
		-no_driver_nets \
		-floating_nets \
		-broken_nets \
		-real_nets \
		-view $VIEW \
		-max_missing 100000 > reports/sta_$VIEW/annotations.rpt
	}
}

#------------------------------------------------------------------------------
# read ocv
#------------------------------------------------------------------------------
if {[info exists OCV] && $OCV} {
	reset_timing_derate
	source ./scripts/flow/derating.tcl
}

#------------------------------------------------------------------------------
# create path groups 
#------------------------------------------------------------------------------
create_basic_path_groups -expanded


#------------------------------------------------------------------------------
# update timing 
#------------------------------------------------------------------------------
if {[info command distribute_partition] == ""} {
	if {![info exists STAGE] || ($STAGE != "syn" && $STAGE != "place")} {
		update_io_latency -adjust_source_latency -verbose
	}
}
update_timing -full


#------------------------------------------------------------------------------
# timing reports per view
#------------------------------------------------------------------------------
if {[info exists CREATE_LIB] && $CREATE_LIB == "true" && ($STAGE == "syn" || $STAGE == "place" )} {
} else {
   foreach view_dpo [get_db analysis_views -if ".is_active"] {
	set VIEW [get_db $view_dpo .name]
	if {[regexp setup $VIEW]} {set CHECK late} else {set CHECK early}
	report_clock_timing -view $VIEW -type summary > reports/sta_$VIEW/${CHECK}.clockreport
	report_timing -view $VIEW -${CHECK} -max_slack 100 -net -max_paths 10000 -path_type full_clock > reports/sta_$VIEW/${CHECK}.all.tarpt
	report_timing -view $VIEW -${CHECK}                -net -max_paths 10000 -path_type full_clock > reports/sta_$VIEW/${CHECK}.all.viol.tarpt
	report_timing -view $VIEW -${CHECK} -group in2reg  -net -max_paths 10000 -path_type full_clock > reports/sta_$VIEW/${CHECK}.in2reg.viol.tarpt
	report_timing -view $VIEW -${CHECK} -group reg2reg -net -max_paths 10000 -path_type full_clock > reports/sta_$VIEW/${CHECK}.reg2reg.viol.tarpt
	report_timing -view $VIEW -${CHECK} -group reg2out -net -max_paths 10000 -path_type full_clock > reports/sta_$VIEW/${CHECK}.reg2out.viol.tarpt
	report_timing -view $VIEW -${CHECK} -group in2out  -net -max_paths 10000 -path_type full_clock > reports/sta_$VIEW/${CHECK}.in2reg.viol.tarpt
	report_timing -view $VIEW -${CHECK} -group reg2reg -net -max_paths 500000 -nworst 1000 -max_slack 0 -retime path_slew_propagation -path_type full_clock > reports/sta_$VIEW/${CHECK}.reg2reg.retime.viol.tarpt
	
	exec gawk -f scripts/bin/slacks.awk reports/sta_$VIEW/${CHECK}.all.viol.tarpt     > reports/sta_$VIEW/${CHECK}.all.summary
	exec gawk -f scripts/bin/slacks.awk reports/sta_$VIEW/${CHECK}.in2reg.viol.tarpt  > reports/sta_$VIEW/${CHECK}.in2reg.summary
	exec gawk -f scripts/bin/slacks.awk reports/sta_$VIEW/${CHECK}.reg2reg.viol.tarpt > reports/sta_$VIEW/${CHECK}.reg2reg.summary
	exec gawk -f scripts/bin/slacks.awk reports/sta_$VIEW/${CHECK}.reg2out.viol.tarpt > reports/sta_$VIEW/${CHECK}.reg2out.summary
	exec gawk -f scripts/bin/slacks.awk reports/sta_$VIEW/${CHECK}.in2reg.viol.tarpt  > reports/sta_$VIEW/${CHECK}.in2reg.summary
	exec gawk -f scripts/bin/slacks.awk reports/sta_$VIEW/${CHECK}.reg2reg.retime.viol.tarpt > reports/sta_$VIEW/${CHECK}.reg2reg.retime.summary
	
	report_constraint -view $VIEW -all_violators -drv_violation_type max_capacitance            > reports/sta_$VIEW/cap_vios.rpt
	report_constraint -view $VIEW -all_violators -drv_violation_type max_transition             > reports/sta_$VIEW/tran_vios.rpt
	report_constraint -view $VIEW -all_violators -by_driver -drv_violation_type max_transition  > reports/sta_$VIEW/tran_vios_driver.rpt
	report_timing     -view $VIEW -check_type pulse_width  -max_slack 0 -max_paths 10000 -path_type full_clock > reports/sta_$VIEW/min_pulse_width.rpt
	report_timing     -view $VIEW -check_type clock_period -max_slack 0 -max_paths 10000 -path_type full_clock > reports/sta_$VIEW/clock_period.rpt
	if {[info exists XTALK_SI]  && $XTALK_SI == "true" } {
		report_noise      -view $VIEW -failure -sort_by noise -out_file reports/sta_$VIEW/SI_failure.txt
		report_noise      -view $VIEW -noisy_waveform         -out_file reports/sta_$VIEW/SI_noise.txt
	}
	report_double_clocking -view $VIEW -nworst 10000 		> reports/sta_$VIEW/SI_double_clocking.txt
   } 


#------------------------------------------------------------------------------
# save DB 
#------------------------------------------------------------------------------
write_db out/${DESIGN_NAME} -overwrite

} ; #if {[info exists CREATE_LIB] && $CREATE_LIB == "true" && $STAGE == "syn"} 

#------------------------------------------------------------------------------
# save eco DB 
#------------------------------------------------------------------------------
if {[info exists SAVE_ECO_DB] && $SAVE_ECO_DB == "true"} {
	set_db opt_signoff_retime path_slew_propagation
	set_db opt_signoff_max_paths 500000
	set_db opt_signoff_nworst 10000
	set_db opt_signoff_write_eco_opt_db out/${DESIGN_NAME}.eco
	#set_db opt_signoff_fix_glitch true
	write_eco_opt_db
}

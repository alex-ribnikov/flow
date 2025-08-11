foreach check__ {setup hold} {
	puts "-I- generating reports for $check__"
	if {$check__ == "setup"} {
		set delay_type  "max"
	} else {
		set delay_type  "min"
	}
	report_timing 		     -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than 100      -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode none > $REPORTS_DIR/${check__}_all_GBA.rpt
	report_timing 		     -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than -0.00001 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_all.rpt
	report_timing -group reg2reg -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than -0.00001 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_reg2reg.rpt
	report_timing -group in2reg  -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than -0.00001 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_in2reg.rpt
	report_timing -group reg2out -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than -0.00001 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_reg2out.rpt
	report_timing -group in2out  -delay_type $delay_type -physical -include_hierarchical_pins -slack_lesser_than -0.00001 -max_paths 10000 -derate -crosstalk_delta  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded  -pba_mode $PBA_MODE > $REPORTS_DIR/${check__}_in2out.rpt
	exec gawk -f scripts/bin/slacks.awk $REPORTS_DIR/${check__}_all_GBA.rpt | sort -n > $REPORTS_DIR/${check__}_all_GBA.summary
	exec gawk -f scripts/bin/slacks.awk $REPORTS_DIR/${check__}_all.rpt     | sort -n > $REPORTS_DIR/${check__}_all.summary
	exec gawk -f scripts/bin/slacks.awk $REPORTS_DIR/${check__}_reg2reg.rpt | sort -n > $REPORTS_DIR/${check__}_reg2reg.summary
	exec gawk -f scripts/bin/slacks.awk $REPORTS_DIR/${check__}_in2reg.rpt  | sort -n > $REPORTS_DIR/${check__}_in2reg.summary
	exec gawk -f scripts/bin/slacks.awk $REPORTS_DIR/${check__}_reg2out.rpt | sort -n > $REPORTS_DIR/${check__}_reg2out.summary
	exec gawk -f scripts/bin/slacks.awk $REPORTS_DIR/${check__}_in2out.rpt  | sort -n > $REPORTS_DIR/${check__}_in2out.summary
        
	exec ./scripts/bin/timing_filter.pl $REPORTS_DIR/${check__}_reg2reg.rpt
	exec ./scripts/bin/timing_filter.pl $REPORTS_DIR/${check__}_in2reg.rpt
	exec ./scripts/bin/timing_filter.pl $REPORTS_DIR/${check__}_reg2out.rpt
	exec ./scripts/bin/timing_filter.pl $REPORTS_DIR/${check__}_in2out.rpt

}

report_constraints -nosplit -all_violators -max_capacitance  > $REPORTS_DIR/max_capacitance.rpt
report_constraints -nosplit -all_violators -max_transition   > $REPORTS_DIR/max_transition.rpt
report_constraints -nosplit -all_violators -min_pulse_width  > $REPORTS_DIR/min_pulse_width.rpt
report_constraints -nosplit -all_violators -min_period       > $REPORTS_DIR/min_period.rpt
report_constraints -nosplit -all_violators   > $REPORTS_DIR/report_constraints.rpt
#report_qor -summary > $REPORTS_DIR/report_qor.rpt

report_noise -nosplit -all_violators -above -low > $REPORTS_DIR/report_noise_all_viol_abv_low.report   
report_noise -nosplit -all_violators -above -high > $REPORTS_DIR/report_noise_all_viol_abv_high.report   
report_noise -nosplit -all_violators -below -high > $REPORTS_DIR/report_noise_all_viol_below_high.report
report_noise -nosplit -all_violators -below -low > $REPORTS_DIR/report_noise_all_viol_below_low.report

if {$pt_shell_mode == "primetime_master"} {


}
##################################################################
#    Report_timing Section                                       #
##################################################################
#==============================================================================
#Cover through reporting from 2018.06* version
#get_timing_paths and report_timing commands are enhanced with a new option, -cover_through through_list, which collects the single worst violating path through each of the objects specified in a list. 
#For example,
#pt_shell> get_timing_paths -cover_through {n1 n2 n3}
#This command creates a collection containing the worst path through n1, the worst path
#through n2, and the worst path through n3, resulting in a collection of up to three paths.
#=======================================================================
report_global_timing > $REPORTS_DIR/${DESIGN_NAME}_report_global_timing.report


#report_analysis_coverage -status_details untested -nosplit > reports/report_analysis_coverage.rpt

# To report HyperTrace, please use the PBA exhaustive as above or use the report_timing command as below
# Below command is also used for general Machine Learning Exhaustive reporting
# report_timing -crosstalk_delta -slack_lesser_than 0.0 -pba_mode ml_exhaustive -delay min_max -nosplit -input -net  > $REPORTS_DIR/${DESIGN_NAME}_report_timing_ml_pba.report

#report_design > $REPORTS_DIR/${DESIGN_NAME}_report_design.report
#report_net > $REPORTS_DIR/${DESIGN_NAME}_report_net.report


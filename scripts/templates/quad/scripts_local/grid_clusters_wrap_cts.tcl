set_db opt_new_inst_prefix "i_${STAGE}_only_"
set_db opt_new_net_prefix  "n_${STAGE}_only_"

set_db route_design_detail_use_multi_cut_via_effort high

source ./scripts_local/build_clock_tree.tcl -e -v

set_db route_design_detail_use_multi_cut_via_effort default


#------------------------------------------------------------------------------
# connect P/G pins to nets
#------------------------------------------------------------------------------
if {[file exists scripts_local/connect_global_net.tcl]} {
	puts "-I- reading connect_global_net file from scripts_local"
	source -e -v scripts_local/connect_global_net.tcl
} else {
	puts "-I- reading connect_global_net file from scripts"
	source -e -v scripts/flow/connect_global_net.tcl
}
#add_tieoffs -matching_power_domains true


#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.${STAGE}.def.gz
write_lef_abstract -5.8 \
	-top_layer $MAX_ROUTING_LAYER \
	-pg_pin_layers $MAX_ROUTING_LAYER \
	-stripe_pins \
	-property \
	out/lef/${DESIGN_NAME}.${STAGE}.lef


#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
#if {[get_db [get_db designs] .is_routed] != true} { puts "-I- Running route_early_global";  route_early_global }
#if {[get_db [get_db designs] .is_rc_extracted] != true} {  puts "-I- Running extract_rc";   extract_rc }
time_design -report_only -timing_debug_report -expanded_views -report_dir reports/cts -num_paths 10000 -report_prefix cts
time_design -report_only -timing_debug_report -expanded_views -report_dir reports/cts -num_paths 10000 -report_prefix cts -hold
#
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_all.tarpt       > reports/cts/cts_all.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2reg.tarpt   > reports/cts/cts_reg2reg.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2cgate.tarpt > reports/cts/cts_reg2cgate.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_in2reg.tarpt    > reports/cts/cts_in2reg.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2out.tarpt   > reports/cts/cts_reg2out.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_in2out.tarpt    > reports/cts/cts_in2out.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_default.tarpt   > reports/cts/cts_default.summary
#
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_all_hold.tarpt       > reports/cts/cts_all_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2reg_hold.tarpt   > reports/cts/cts_reg2reg_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2cgate_hold.tarpt > reports/cts/cts_reg2cgate_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_in2reg_hold.tarpt    > reports/cts/cts_in2reg_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2out_hold.tarpt   > reports/cts/cts_reg2out_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_in2out_hold.tarpt    > reports/cts/cts_in2out_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_default_hold.tarpt   > reports/cts/cts_default_hold.summary


report_clock_tree_structure -expand_below_generators -expand_below_logic -show_sinks -out_file reports/cts/all_clocks.show_sinks.trace
report_clock_tree_structure -expand_below_generators -expand_below_logic		     -out_file reports/cts/all_clocks.trace
report_ccopt_worst_chain                                                             -out_file reports/cts/cts_worstChain.rpt
report_clock_trees -histograms -num_transition_time_violating_pins 50                -out_file reports/cts/cts_clock_trees.rpt
report_skew_groups                                                                   -out_file reports/cts/cts_skew_groups.rpt
check_place                                                                                    reports/cts/cts_check_place.rpt

# report_power -out_file reports/cts/power.rpt
user_report_inst_vt reports/cts/threshold_instance_count.rpt

set_db check_drc_disable_rules out_of_die
check_drc -limit 100000 -ignore_trial_route true -out_file reports/cts/cts_drc.rpt  
report_congestion -hotspot > reports/cts/cts_hotspot.rpt


report_metric -format html -file reports/cts/${DESIGN_NAME}.html
write_metric  -format csv  -file reports/cts/${DESIGN_NAME}.csv

gui_create_floorplan_snapshot -dir reports/cts/snapshot -name ${DESIGN_NAME} -overwrite
gui_write_flow_gifs -dir reports/cts/snapshot -prefix [get_db designs .name] -full_window
gui_hide

set end_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - End running $STAGE at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
puts "-I- BE_STAGE: $STAGE - Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

be_reports    -stage $STAGE -block $DESIGN_NAME -all
#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
be_sum_to_csv -stage $STAGE -mail -final
report_resource

#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}_done


if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
}

if {![info exists BATCH] || $BATCH == "true"} {
	exit
}

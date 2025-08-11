#################################################################################################################################################################################
#																						#
#	this script will run innovus CTS stage  																#
#	variable received from shell are:																	#
#		CPU		 - number of CPU to run.8 per license														#
#		BATCH 		 - run in batch mode																#
#		DESIGN_NAME	 - name of top model																#
#		SCAN 		 - design with scan insertion															#
#		OCV 		 - run CTS with OCV																#
#																						#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	20/01/2021	Royl	initial script																#
#	0.2	08/03/2021	OrY	 	Merge with env
#																						#
#																						#
#################################################################################################################################################################################
set_db source_verbose false

set STAGE cts
set RUNNING_LOCAL_SCRIPTS [list]

set start_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - Start running $STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
source ./scripts/procs/source_be_scripts.tcl

script_runtime_proc -start
check_script_location

if {![file exists reports/$STAGE]} {mkdir -pv reports/$STAGE}
set_db user_stage_reports_dir reports/$STAGE
#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v scripts_local/setup.tcl
} else {
	puts "-I- reading ${::env(PROJECT)}  setup file from scripts"
	source -v ./scripts/setup/setup.${::env(PROJECT)}.tcl
}
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}
if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	check_script_location scripts_local/supplement_setup.tcl
	source -v scripts_local/supplement_setup.tcl
}
#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
set_multi_cpu_usage -local_cpu $CPU -remote_host 1 -cpu_per_remote_host 1

set_db init_delete_assigns 1
set_db init_power_nets        $PWR_NET
set_db init_ground_nets       $GND_NET
set_db init_keep_empty_modules true

#------------------------------------------------------------------------------
# define and read mmmc 
#------------------------------------------------------------------------------
source ./scripts/flow/mmmc_create.tcl
mmmc_create

#------------------------------------------------------------------------------
# load db base
#------------------------------------------------------------------------------
if {[info exists FLOW_START_FROM] && $FLOW_START_FROM == "def"} {
	#------------------------------------------------------------------------------
	# define and read mmmc 
	#------------------------------------------------------------------------------
	set cmd "read_mmmc { $mmmc_results }"
	eval $cmd
	
	puts "-I- read design from place def"
	read_physical -lef $LEF_FILE_LIST
	read_netlist -top $DESIGN_NAME ./out/db/${DESIGN_NAME}.place.enc.dat/${DESIGN_NAME}.v.gz
	init_design
	read_def ./out/def/${DESIGN_NAME}.place.def.gz
} else {
	puts "-I- read design from place db"
	read_db -lef_files $LEF_FILE_LIST -mmmc_file $mmmc_results  out/db/${DESIGN_NAME}.place.enc.dat
}

#------------------------------------------------------------------------------
# read  ilm design
#------------------------------------------------------------------------------
if {[info exists ILM_FILES] && $ILM_FILES != ""} {
   if {[get_db is_ilm_flattened]} {unflatten_ilm}
   foreach ilm_block_file $ILM_FILES {
   	set ilm_block_name [lindex [split $ilm_block_file '/'] end-5]
	#reset_ilm -cell $ilm_block_name
	read_ilm -cell $ilm_block_name -dir $ilm_block_file
   }
   flatten_ilm
   report_ilm_status > reports/${STAGE}/report_ilm_status.rpt
   foreach mmm [get_db / .constraint_modes.name] {
   	update_constraint_mode  -name $mmm -ilm_sdc_files  $sdc_files($mmm)
   }
}

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


#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/INN_variables.tcl]} {
	puts "-I- reading INN_variables file from scripts_local"
	source -v scripts_local/INN_variables.tcl
} else {
	puts "-I- reading INN_variables file from scripts"
	source -v scripts/flow/INN_variables.tcl
}

#------------------------------------------------------------------------------
# extra setting and operations 
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_cts_setting.tcl]} {
	puts "-I- running Extra setting from scripts_local/pre_cts_setting.tcl [ory_time::now]"
	check_script_location scripts_local/pre_cts_setting.tcl
	source -v ./scripts_local/pre_cts_setting.tcl
}

#------------------------------------------------------------------------------
# clock setting and  operations
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/${DESIGN_NAME}_cts.tcl]} {
	puts "-I- running clock setting scripts_local/${DESIGN_NAME}_cts.tcl [ory_time::now]"
	source -v ./scripts_local/${DESIGN_NAME}_cts.tcl
}
return
#------------------------------------------------------------------------------
#  CTS 
#------------------------------------------------------------------------------
set_db opt_new_inst_prefix "i_${STAGE}_only_"
set_db opt_new_net_prefix  "n_${STAGE}_only_"

set_db route_design_detail_use_multi_cut_via_effort high

if { [info exists CTS_DEBUG] && $CTS_DEBUG } {
    puts "-I- Running CTS_DEBUG mode"
    eee {clock_design }
} else {
    ##### standard CCOpt
    eee {ccopt_design -expanded_views -report_dir reports/cts/ }
}

set_db route_design_detail_use_multi_cut_via_effort default

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}_only.enc.dat

#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------

if {[get_db [get_db designs] .is_routed] != true} { puts "-I- Running route_early_global";  route_early_global }
if {[get_db [get_db designs] .is_rc_extracted] != true} {  puts "-I- Running extract_rc";   extract_rc }

time_design       -report_only -timing_debug_report -expanded_views -report_dir reports/cts/cts_only -num_paths 10000 -report_prefix cts_only
time_design -hold -report_only -timing_debug_report -expanded_views -report_dir reports/cts/cts_only -num_paths 10000 -report_prefix cts_only

exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_all.tarpt            > reports/cts/cts_only/cts_only_all.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_reg2reg.tarpt        > reports/cts/cts_only/cts_only_reg2reg.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_reg2cgate.tarpt      > reports/cts/cts_only/cts_only_reg2cgate.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_in2reg.tarpt         > reports/cts/cts_only/cts_only_in2reg.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_reg2out.tarpt        > reports/cts/cts_only/cts_only_reg2out.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_in2out.tarpt         > reports/cts/cts_only/cts_only_in2out.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_default.tarpt        > reports/cts/cts_only/cts_only_default.summary

exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_all_hold.tarpt       > reports/cts/cts_only/cts_only_all_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_reg2reg_hold.tarpt   > reports/cts/cts_only/cts_only_reg2reg_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_reg2cgate_hold.tarpt > reports/cts/cts_only/cts_only_reg2cgate_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_in2reg_hold.tarpt    > reports/cts/cts_only/cts_only_in2reg_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_reg2out_hold.tarpt   > reports/cts/cts_only/cts_only_reg2out_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_in2out_hold.tarpt    > reports/cts/cts_only/cts_only_in2out_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_only/cts_only_default_hold.tarpt   > reports/cts/cts_only/cts_only_default_hold.summary

report_clock_tree_structure -expand_below_generators -expand_below_logic -show_sinks -out_file reports/cts/cts_only_all_clocks.show_sinks.trace
report_clock_tree_structure -expand_below_generators -expand_below_logic		 -out_file reports/cts/cts_only_all_clocks.trace
report_clock_timing -type summary            > reports/cts/cts_only_report_clock_timing.summary
report_clock_timing -type latency            > reports/cts/cts_only_report_clock_timing.latency 
report_clock_timing -type skew               > reports/cts/cts_only_report_clock_timing.skew      
report_clock_timing -type interclock_skew    > reports/cts/cts_only_report_clock_timing.interclock_skew

report_ccopt_worst_chain                                              -out_file reports/cts/cts_only_worstChain.rpt
report_clock_trees -histograms -num_transition_time_violating_pins 50 -out_file reports/cts/cts_only_clock_trees.rpt
report_skew_groups                                                    -out_file reports/cts/cts_only_skew_groups.rpt
check_place                                                                     reports/cts/cts_only_check_place.rpt

report_power -out_file reports/cts/cts_only_power.rpt
check_drc -limit 100000 -ignore_trial_route true -out_file reports/cts/cts_only_drc.rpt  

gui_create_floorplan_snapshot -dir reports/cts/cts_only/snapshot -name ${DESIGN_NAME} -overwrite
gui_write_flow_gifs -dir reports/cts/cts_only/snapshot -prefix [get_db designs .name] -full_window
gui_hide

if { [info exists SCAN] && $SCAN } {
    report_scan_chain -verbose -out_file reports/$STAGE/cts_only_report_scan_chain.rpt
}

be_reports    -stage cts_only -clocks -multibit -power -routing 
be_sum_to_csv -stage cts_only

if { [info exists CTS_DEBUG] && $CTS_DEBUG } {
    return
}

#------------------------------------------------------------------------------
#   opt design
#------------------------------------------------------------------------------
#set_db opt_new_inst_prefix "i_${STAGE}_"
#set_db opt_new_net_prefix  "n_${STAGE}_"

#  08/11/2021 ROYL : does add extra value after ccopt_design
#eee {opt_design       -expanded_views  -post_cts  -report_dir reports/cts/cts_setup}
#if {[get_db [get_db designs] .is_routed] != true} { puts "-I- Running route_early_global";   route_early_global }
#if {[get_db [get_db designs] .is_rc_extracted] != true} {  puts "-I- Running extract_rc";    extract_rc }

set_interactive_constraint_modes [all_constraint_modes -active]
set_dont_use [get_lib_cells $HOLD_FIX_CELLS_LIST] false
set_db opt_fix_hold_ignore_path_groups {in2reg reg2out in2out}

set_db opt_new_inst_prefix "i_${STAGE}_hold_"
set_db opt_new_net_prefix  "n_${STAGE}_hold_"

eee {opt_design -hold -expanded_views  -post_cts  -report_dir reports/cts/cts_hold}

set_dont_use [get_lib_cells $HOLD_FIX_CELLS_LIST] true
set_db opt_fix_hold_ignore_path_groups ""

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}.opt_hold.enc.dat

#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------

if {[get_db [get_db designs] .is_routed] != true} { puts "-I- Running route_early_global";  route_early_global }
if {[get_db [get_db designs] .is_rc_extracted] != true} {  puts "-I- Running extract_rc";   extract_rc }

time_design       -report_only -timing_debug_report -expanded_views -report_dir reports/cts/cts_opt_hold -num_paths 10000 -report_prefix cts_opt_hold
time_design -hold -report_only -timing_debug_report -expanded_views -report_dir reports/cts/cts_opt_hold -num_paths 10000 -report_prefix cts_opt_hold

exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_all.tarpt            > reports/cts/cts_opt_hold/cts_opt_hold_all.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2reg.tarpt        > reports/cts/cts_opt_hold/cts_opt_hold_reg2reg.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2cgate.tarpt      > reports/cts/cts_opt_hold/cts_opt_hold_reg2cgate.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_in2reg.tarpt         > reports/cts/cts_opt_hold/cts_opt_hold_in2reg.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2out.tarpt        > reports/cts/cts_opt_hold/cts_opt_hold_reg2out.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_in2out.tarpt         > reports/cts/cts_opt_hold/cts_opt_hold_in2out.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_default.tarpt        > reports/cts/cts_opt_hold/cts_opt_hold_default.summary

exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_all_hold.tarpt       > reports/cts/cts_opt_hold/cts_opt_hold_all_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2reg_hold.tarpt   > reports/cts/cts_opt_hold/cts_opt_hold_reg2reg_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2cgate_hold.tarpt > reports/cts/cts_opt_hold/cts_opt_hold_reg2cgate_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_in2reg_hold.tarpt    > reports/cts/cts_opt_hold/cts_opt_hold_in2reg_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2out_hold.tarpt   > reports/cts/cts_opt_hold/cts_opt_hold_reg2out_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_in2out_hold.tarpt    > reports/cts/cts_opt_hold/cts_opt_hold_in2out_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_default_hold.tarpt   > reports/cts/cts_opt_hold/cts_opt_hold_default_hold.summary

#------------------------------------------------------------------------------
# fix clock routing 
#------------------------------------------------------------------------------

eee {route_design -clock_eco}


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
if {[get_db [get_db designs] .is_routed] != true} { puts "-I- Running route_early_global";  route_early_global }
if {[get_db [get_db designs] .is_rc_extracted] != true} {  puts "-I- Running extract_rc";   extract_rc }
time_design -report_only -timing_debug_report -expanded_views -report_dir reports/cts -num_paths 10000 -report_prefix cts
time_design -report_only -timing_debug_report -expanded_views -report_dir reports/cts -num_paths 10000 -report_prefix cts -hold

exec gawk -f scripts/bin/slacks.awk reports/cts/cts_all.tarpt       > reports/cts/cts_all.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2reg.tarpt   > reports/cts/cts_reg2reg.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2cgate.tarpt > reports/cts/cts_reg2cgate.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_in2reg.tarpt    > reports/cts/cts_in2reg.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2out.tarpt   > reports/cts/cts_reg2out.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_in2out.tarpt    > reports/cts/cts_in2out.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_default.tarpt   > reports/cts/cts_default.summary

exec gawk -f scripts/bin/slacks.awk reports/cts/cts_all_hold.tarpt       > reports/cts/cts_all_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2reg_hold.tarpt   > reports/cts/cts_reg2reg_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2cgate_hold.tarpt > reports/cts/cts_reg2cgate_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_in2reg_hold.tarpt    > reports/cts/cts_in2reg_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_reg2out_hold.tarpt   > reports/cts/cts_reg2out_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_in2out_hold.tarpt    > reports/cts/cts_in2out_hold.summary
exec gawk -f scripts/bin/slacks.awk reports/cts/cts_default_hold.tarpt   > reports/cts/cts_default_hold.summary


report_clock_tree_structure -expand_below_generators -expand_below_logic -show_sinks -out_file reports/cts/all_clocks.show_sinks.trace
report_clock_tree_structure -expand_below_generators -expand_below_logic		     -out_file reports/cts/all_clocks.trace
report_ccopt_worst_chain                                                             -out_file reports/cts/cts_worstChain.rpt
report_clock_trees -histograms -num_transition_time_violating_pins 50                -out_file reports/cts/cts_clock_trees.rpt
report_skew_groups                                                                   -out_file reports/cts/cts_skew_groups.rpt
check_place                                                                                    reports/cts/cts_check_place.rpt

report_power -out_file reports/cts/power.rpt
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
# Hierarchical flow
#------------------------------------------------------------------------------
extract_rc
foreach rc_corner_ [get_db [get_db rc_corners -if ".is_active"] .name] {
	write_parasitics -rc_corner $rc_corner_ -spef_file out/spef/${DESIGN_NAME}.${STAGE}_${rc_corner_}.spef.gz
}
write_ilm -to_dir out/ilm/${STAGE} -overwrite  -model_type timing

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

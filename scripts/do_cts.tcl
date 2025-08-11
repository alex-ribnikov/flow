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


if { ![file exists out/sdc] } { exec mkdir -pv out/sdc }

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}

script_runtime_proc -start
check_script_location

if {![file exists reports/$STAGE]} {exec mkdir -pv reports/$STAGE}
set_db user_stage_reports_dir reports/$STAGE
#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v scripts_local/setup.tcl
} else {
	puts "-I- reading ${PROJECT}  setup file from scripts"
	source -v ./scripts/setup/setup.${PROJECT}.tcl
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
# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
set_multi_cpu_usage -local_cpu $CPU

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
    # !!! INFO: Var NEW_SDC does not exist by default. Use it only for private overrides !!!
	if {[info exists NEW_SDC] && $NEW_SDC == "true"} {
		puts "-I- read design from place db"
		read_db -lef_files $LEF_FILE_LIST -mmmc_file $mmmc_results  out/db/${DESIGN_NAME}.place.enc.dat
	} else {
		read_db out/db/${DESIGN_NAME}.place.enc.dat
		set_analysis_view -setup $scenarios(setup) -hold $scenarios(hold) -dynamic $scenarios(dynamic) -leakage $scenarios(leakage)
   		foreach mmm [get_db / .constraint_modes.name] {
		    if {[info exists sdc_update_files($mmm)]} {
			set_interactive_constraint_modes $mmm
			foreach sdcfile_  $sdc_update_files($mmm) {
				if {[file exists $sdcfile_]} {
					puts "-I- updateing sdc for mode $mmm , sourcing file $sdcfile_"
					source $sdcfile_
				}
			}
		    }
   		}
	}
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
        puts "-I- running Extra setting from ./scripts_local/pre_cts_setting.tcl"
        check_script_location ./scripts_local/pre_cts_setting.tcl
        source -v ./scripts_local/pre_cts_setting.tcl
}


#------------------------------------------------------------------------------
# clock setting and  operations
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/${DESIGN_NAME}_cts.tcl]} {
	puts "-I- running clock setting scripts_local/${DESIGN_NAME}_cts.tcl"
	source -v ./scripts_local/${DESIGN_NAME}_cts.tcl
}

#------------------------------------------------------------------------------
#  CTS 
#------------------------------------------------------------------------------
set_db opt_new_inst_prefix "i_${STAGE}_only_"
set_db opt_new_net_prefix  "n_${STAGE}_only_"

set_db route_design_detail_use_multi_cut_via_effort high

if { [info exists STOP_AFTER] && $STOP_AFTER=="cts_cluster" } {
    puts "-I- Running CTS_DEBUG mode - Stop after CTS clustering stage"
    set_db cts_balance_mode cluster
    create_clock_tree_spec -out_file spec.tcl
    source spec.tcl
    eee { clock_design }
} elseif { [info exists BREAK_CTS] && $BREAK_CTS } {
    puts "-I- Run CTS in deconstructed mode - ccopt_design -cts + opt_design -setup"
#    eee {eval_legacy "ccopt_design -cts -expandedViews -outDir reports/cts/"}
    if {[regexp {22} [get_db program_version]]} {
        eee {eval_legacy "ccopt_design -cts"}
    } else {
        clock_opt_design -cts
    }
    rm -rf out/db/${DESIGN_NAME}.clock_only.enc.dat
    write_db -verilog      out/db/${DESIGN_NAME}.clock_only.enc.dat

    #check_drc -limit 100000 -ignore_trial_route  -out_file reports/cts/clock_only_drc.rpt  

    eee {clock_post_route_repair}
    rm -rf out/db/${DESIGN_NAME}.clock_fix_route.enc.dat
    write_db -verilog      out/db/${DESIGN_NAME}.clock_fix_route.enc.dat

    #check_drc -limit 100000 -ignore_trial_route  -out_file reports/cts/clock_fix_route_drc.rpt  
    
#    write_db -verilog      out/db/${DESIGN_NAME}.ccopt_pre_opt_design.enc.dat
    if { [file exists scripts_local/pre_setup_opt_settings.tcl] } { 
        puts "-I- Sourcing: scripts_local/pre_setup_opt_settings.tcl"
        source -e -v scripts_local/pre_setup_opt_settings.tcl 
    }
    eee {opt_design -setup -post_cts  -report_dir reports/cts/cts_setup}
} else {
    ##### standard CCOpt
    if {[regexp {22} [get_db program_version]]} {
        eee {ccopt_design -expanded_views -report_dir reports/cts/ }
    } else {
        clock_opt_design  -expanded_views -report_dir reports/cts/
    }
}

set_db route_design_detail_use_multi_cut_via_effort default

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
rm -rf out/db/${DESIGN_NAME}.${STAGE}_only.enc.dat
write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}_only.enc.dat

#------------------------------------------------------------------------------
# post cts extra setting 
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/post_cts_setting.tcl]} {
        puts "-I- running Extra setting from ./scripts_local/post_cts_setting.tcl"
        check_script_location ./scripts_local/post_cts_setting.tcl
        source -v ./scripts_local/post_cts_setting.tcl
}

#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
set_db user_stage_reports_dir reports/${STAGE}/cts_only

if {[get_db [get_db designs] .is_routed] != true} { puts "-I- Running route_early_global";  route_early_global }
if {[get_db [get_db designs] .is_rc_extracted] != true} {  puts "-I- Running extract_rc";   extract_rc }

time_design       -report_only -timing_debug_report -expanded_views -report_dir reports/cts/cts_only -num_paths 10000 -report_prefix cts_only
time_design -hold -report_only -timing_debug_report -expanded_views -report_dir reports/cts/cts_only -num_paths 10000 -report_prefix cts_only

exec zcat reports/cts/cts_only/cts_only_all.tarpt.gz            | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_all.summary
exec zcat reports/cts/cts_only/cts_only_reg2reg.tarpt.gz        | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_reg2reg.summary
exec zcat reports/cts/cts_only/cts_only_reg2cgate.tarpt.gz      | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_reg2cgate.summary
exec zcat reports/cts/cts_only/cts_only_in2reg.tarpt.gz         | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_in2reg.summary
exec zcat reports/cts/cts_only/cts_only_reg2out.tarpt.gz        | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_reg2out.summary
exec zcat reports/cts/cts_only/cts_only_in2out.tarpt.gz         | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_in2out.summary
exec zcat reports/cts/cts_only/cts_only_default.tarpt.gz        | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_default.summary

exec zcat reports/cts/cts_only/cts_only_all_hold.tarpt.gz       | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_all_hold.summary
exec zcat reports/cts/cts_only/cts_only_reg2reg_hold.tarpt.gz   | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_reg2reg_hold.summary
exec zcat reports/cts/cts_only/cts_only_reg2cgate_hold.tarpt.gz | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_reg2cgate_hold.summary
exec zcat reports/cts/cts_only/cts_only_in2reg_hold.tarpt.gz    | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_in2reg_hold.summary
exec zcat reports/cts/cts_only/cts_only_reg2out_hold.tarpt.gz   | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_reg2out_hold.summary
exec zcat reports/cts/cts_only/cts_only_in2out_hold.tarpt.gz    | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_in2out_hold.summary
exec zcat reports/cts/cts_only/cts_only_default_hold.tarpt.gz   | gawk -f scripts/bin/slacks.awk > reports/cts/cts_only/cts_only_default_hold.summary


exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_all.tarpt.gz            
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_reg2reg.tarpt.gz        
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_reg2cgate.tarpt.gz      
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_in2reg.tarpt.gz         
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_reg2out.tarpt.gz        
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_in2out.tarpt.gz         
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_default.tarpt.gz        

exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_all_hold.tarpt.gz       
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_reg2reg_hold.tarpt.gz   
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_reg2cgate_hold.tarpt.gz 
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_in2reg_hold.tarpt.gz    
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_reg2out_hold.tarpt.gz   
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_in2out_hold.tarpt.gz    
exec ./scripts/bin/timing_filter.pl reports/cts/cts_only/cts_only_default_hold.tarpt.gz   


report_clock_tree_structure -expand_below_generators -expand_below_logic -show_sinks -out_file reports/cts/cts_only/all_clocks.show_sinks.trace
report_clock_tree_structure -expand_below_generators -expand_below_logic		 -out_file reports/cts/cts_only/all_clocks.trace
report_clock_timing -type summary            > reports/cts/cts_only/report_clock_timing.summary
report_clock_timing -type latency            > reports/cts/cts_only/report_clock_timing.latency 
report_clock_timing -type skew               > reports/cts/cts_only/report_clock_timing.skew      
report_clock_timing -type interclock_skew    > reports/cts/cts_only/report_clock_timing.interclock_skew

report_ccopt_worst_chain                                                -out_file reports/cts/cts_only/worstChain.rpt
report_clock_trees -histograms -num_transition_time_violating_pins 5000 -out_file reports/cts/cts_only/clock_trees.rpt
report_skew_groups                                                      -out_file reports/cts/cts_only/skew_groups.rpt
check_place                                                                     reports/cts/cts_only/check_place.rpt

report_power -out_file reports/cts/cts_only/power.rpt
#check_drc -limit 100000 -ignore_trial_route  -out_file reports/cts/cts_only/drc.rpt  

set cmd "gui_create_floorplan_snapshot -dir reports/${STAGE}/snapshot/cts_only -name ${DESIGN_NAME} -overwrite"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res }
set cmd "gui_write_flow_gifs -dir reports/${STAGE}/snapshot/cts_only -prefix [get_db designs .name] -full_window"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res } { gui_hide }



if { [info exists SCAN] && $SCAN } {
    report_scan_chain -verbose -out_file reports/$STAGE/cts_only/report_scan_chain.rpt
}

be_reports    -stage cts_only -clocks -multibit -power -routing 
be_sum_to_csv -stage cts_only

if { [info exists STOP_AFTER] && $STOP_AFTER=="cts_cluster" } {
    if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
        return
    }
    exit
}

set_db user_stage_reports_dir reports/${STAGE}

#------------------------------------------------------------------------------
# pre cts opt extra setting 
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_cts_opt_setting.tcl]} {
        puts "-I- running Extra setting from ./scripts_local/pre_cts_opt_setting.tcl"
        check_script_location ./scripts_local/pre_cts_opt_setting.tcl
        source -v ./scripts_local/pre_cts_opt_setting.tcl
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
#
##------------------------------------------------------------------------------
## save design
##------------------------------------------------------------------------------
#write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}.opt_hold.enc.dat
#
##------------------------------------------------------------------------------
## reports
##------------------------------------------------------------------------------
#
#if {[get_db [get_db designs] .is_routed] != true} { puts "-I- Running route_early_global";  route_early_global }
#if {[get_db [get_db designs] .is_rc_extracted] != true} {  puts "-I- Running extract_rc";   extract_rc }
#
#time_design       -report_only -timing_debug_report -expanded_views -report_dir reports/cts/cts_opt_hold -num_paths 10000 -report_prefix cts_opt_hold
#time_design -hold -report_only -timing_debug_report -expanded_views -report_dir reports/cts/cts_opt_hold -num_paths 10000 -report_prefix cts_opt_hold
#
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_all.tarpt            > reports/cts/cts_opt_hold/cts_opt_hold_all.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2reg.tarpt        > reports/cts/cts_opt_hold/cts_opt_hold_reg2reg.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2cgate.tarpt      > reports/cts/cts_opt_hold/cts_opt_hold_reg2cgate.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_in2reg.tarpt         > reports/cts/cts_opt_hold/cts_opt_hold_in2reg.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2out.tarpt        > reports/cts/cts_opt_hold/cts_opt_hold_reg2out.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_in2out.tarpt         > reports/cts/cts_opt_hold/cts_opt_hold_in2out.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_default.tarpt        > reports/cts/cts_opt_hold/cts_opt_hold_default.summary
#
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_all_hold.tarpt       > reports/cts/cts_opt_hold/cts_opt_hold_all_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2reg_hold.tarpt   > reports/cts/cts_opt_hold/cts_opt_hold_reg2reg_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2cgate_hold.tarpt > reports/cts/cts_opt_hold/cts_opt_hold_reg2cgate_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_in2reg_hold.tarpt    > reports/cts/cts_opt_hold/cts_opt_hold_in2reg_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_reg2out_hold.tarpt   > reports/cts/cts_opt_hold/cts_opt_hold_reg2out_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_in2out_hold.tarpt    > reports/cts/cts_opt_hold/cts_opt_hold_in2out_hold.summary
#exec gawk -f scripts/bin/slacks.awk reports/cts/cts_opt_hold/cts_opt_hold_default_hold.tarpt   > reports/cts/cts_opt_hold/cts_opt_hold_default_hold.summary

#------------------------------------------------------------------------------
# fix clock routing 
#------------------------------------------------------------------------------

# eee {route_design -clock_eco}


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
# post cts opt extra setting 
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/post_cts_opt_setting.tcl]} {
        puts "-I- running Extra setting from ./scripts_local/post_cts_opt_setting.tcl"
        check_script_location ./scripts_local/post_cts_opt_setting.tcl
        source -v ./scripts_local/post_cts_opt_setting.tcl
}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
rm -rf out/db/${DESIGN_NAME}.${STAGE}.enc.dat
write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.${STAGE}.def.gz
write_lef_abstract -5.8 \
	-top_layer $MAX_ROUTING_LAYER \
	-pg_pin_layers $MAX_ROUTING_LAYER \
	-stripe_pins \
	-property \
	out/lef/${DESIGN_NAME}.${STAGE}.lef

foreach MODE [get_db constraint_modes .name] {
	set default_setup_view [get_db [get_db analysis_views -if ".is_active==true&&.is_setup_default && .constraint_mode == *${MODE}"] .name] 
	set cmd "write_sdc -view $default_setup_view  out/sdc/${DESIGN_NAME}.${STAGE}.${MODE}.sdc"
	puts "-I- Running: $cmd"
	eval $cmd
}

#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
if {[get_db [get_db designs] .is_routed] != true} { puts "-I- Running route_early_global";  route_early_global }
if {[get_db [get_db designs] .is_rc_extracted] != true} {  puts "-I- Running extract_rc";   extract_rc }
time_design -report_only -timing_debug_report -expanded_views -report_dir reports/cts -num_paths 10000 -report_prefix cts
time_design -report_only -timing_debug_report -expanded_views -report_dir reports/cts -num_paths 10000 -report_prefix cts -hold

exec zcat reports/cts/cts_all.tarpt.gz             | gawk -f scripts/bin/slacks.awk > reports/cts/cts_all.summary
exec zcat reports/cts/cts_reg2reg.tarpt.gz         | gawk -f scripts/bin/slacks.awk > reports/cts/cts_reg2reg.summary
exec zcat reports/cts/cts_reg2cgate.tarpt.gz       | gawk -f scripts/bin/slacks.awk > reports/cts/cts_reg2cgate.summary
exec zcat reports/cts/cts_in2reg.tarpt.gz          | gawk -f scripts/bin/slacks.awk > reports/cts/cts_in2reg.summary
exec zcat reports/cts/cts_reg2out.tarpt.gz         | gawk -f scripts/bin/slacks.awk > reports/cts/cts_reg2out.summary
exec zcat reports/cts/cts_in2out.tarpt.gz          | gawk -f scripts/bin/slacks.awk > reports/cts/cts_in2out.summary
exec zcat reports/cts/cts_default.tarpt.gz         | gawk -f scripts/bin/slacks.awk > reports/cts/cts_default.summary

exec zcat reports/cts/cts_all_hold.tarpt.gz        | gawk -f scripts/bin/slacks.awk > reports/cts/cts_all_hold.summary
exec zcat reports/cts/cts_reg2reg_hold.tarpt.gz    | gawk -f scripts/bin/slacks.awk > reports/cts/cts_reg2reg_hold.summary
exec zcat reports/cts/cts_reg2cgate_hold.tarpt.gz  | gawk -f scripts/bin/slacks.awk > reports/cts/cts_reg2cgate_hold.summary
exec zcat reports/cts/cts_in2reg_hold.tarpt.gz     | gawk -f scripts/bin/slacks.awk > reports/cts/cts_in2reg_hold.summary
exec zcat reports/cts/cts_reg2out_hold.tarpt.gz    | gawk -f scripts/bin/slacks.awk > reports/cts/cts_reg2out_hold.summary
exec zcat reports/cts/cts_in2out_hold.tarpt.gz     | gawk -f scripts/bin/slacks.awk > reports/cts/cts_in2out_hold.summary
exec zcat reports/cts/cts_default_hold.tarpt.gz    | gawk -f scripts/bin/slacks.awk > reports/cts/cts_default_hold.summary

exec ./scripts/bin/timing_filter.pl reports/cts/cts_all.tarpt.gz            
exec ./scripts/bin/timing_filter.pl reports/cts/cts_reg2reg.tarpt.gz        
exec ./scripts/bin/timing_filter.pl reports/cts/cts_reg2cgate.tarpt.gz      
exec ./scripts/bin/timing_filter.pl reports/cts/cts_in2reg.tarpt.gz         
exec ./scripts/bin/timing_filter.pl reports/cts/cts_reg2out.tarpt.gz        
exec ./scripts/bin/timing_filter.pl reports/cts/cts_in2out.tarpt.gz         
exec ./scripts/bin/timing_filter.pl reports/cts/cts_default.tarpt.gz        

exec ./scripts/bin/timing_filter.pl reports/cts/cts_all_hold.tarpt.gz       
exec ./scripts/bin/timing_filter.pl reports/cts/cts_reg2reg_hold.tarpt.gz   
exec ./scripts/bin/timing_filter.pl reports/cts/cts_reg2cgate_hold.tarpt.gz 
exec ./scripts/bin/timing_filter.pl reports/cts/cts_in2reg_hold.tarpt.gz    
exec ./scripts/bin/timing_filter.pl reports/cts/cts_reg2out_hold.tarpt.gz   
exec ./scripts/bin/timing_filter.pl reports/cts/cts_in2out_hold.tarpt.gz    
exec ./scripts/bin/timing_filter.pl reports/cts/cts_default_hold.tarpt.gz   

report_clock_tree_structure -expand_below_generators -expand_below_logic -show_sinks -out_file reports/cts/all_clocks.show_sinks.trace
report_clock_tree_structure -expand_below_generators -expand_below_logic		     -out_file reports/cts/all_clocks.trace
report_ccopt_worst_chain                                                             -out_file reports/cts/cts_worstChain.rpt
#report_clock_trees -histograms -num_transition_time_violating_pins 50                -out_file reports/cts/cts_clock_trees.rpt
report_clock_trees  -num_transition_time_violating_pins 5000                -out_file reports/cts/cts_clock_trees.rpt
report_skew_groups                                                                   -out_file reports/cts/cts_skew_groups.rpt
check_place                                                                                    reports/cts/cts_check_place.rpt

report_power -out_file reports/cts/power.rpt
user_report_inst_vt reports/cts/threshold_instance_count.rpt

set_db check_drc_disable_rules out_of_die
#check_drc -limit 100000 -ignore_trial_route  -out_file reports/cts/cts_drc.rpt  
report_congestion -hotspot > reports/cts/cts_hotspot.rpt

be_check_multiport $STAGE
be_check_clock_cells_vt reports/cts/${DESIGN_NAME}.${STAGE}.clock_cells_vt.rpt

report_metric -format html -file reports/cts/${DESIGN_NAME}.html
write_metric  -format csv  -file reports/cts/${DESIGN_NAME}.csv

set cmd "gui_create_floorplan_snapshot -dir reports/cts/snapshot -name ${DESIGN_NAME} -overwrite"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res }
set cmd "gui_write_flow_gifs -dir reports/cts/snapshot -prefix [get_db designs .name] -full_window"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res } { gui_hide }

set end_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - End running $STAGE at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
puts "-I- BE_STAGE: $STAGE - Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

be_reports    -stage $STAGE -block $DESIGN_NAME -all
#===================================================================
#    Post-cts checkers, for be_checklist 
#===================================================================
 set pnr [lindex [ split  [exec pwd] "/" ] end]
 regsub "pnr" $pnr  "" prefix
 set WA [join [regsub "pnr.*" [split [exec pwd] "/"] ""] "/"]

# 1. clock tree cells, statistics & violations, and number of min buffers
eee  clock_tree_cells_check ${STAGE}.time

# 2. clock tree ndr : route rule & violations:
eee check_clock_ndr ${STAGE}.time

# 3. check  constraints :
eee constraints_check  ${STAGE}.time

# 4. check that each clock pin, start with clock (clock tree)
eee check_clock_to_each_clk_pin ${STAGE}.time

# 5. check report_cts_cell_name_info
eee  cts_cell_name_info ${STAGE}.time

#===================================================================

#------------------------------------------------------------------------------
# Hierarchical flow
#------------------------------------------------------------------------------
if {[info exists CREATE_SPEF] && ($CREATE_SPEF == "true" || [regexp "cts" $CREATE_SPEF] )} {
   set start_t [clock seconds]
   extract_rc
   foreach rc_corner_ [get_db [get_db rc_corners -if ".is_active"] .name] {
	set cmd  "write_parasitics -rc_corner $rc_corner_ -spef_file out/spef/${DESIGN_NAME}.${STAGE}.spef.${rc_corner_}.gz"
	eee $cmd
   }
   set end_t [clock seconds]
   puts "-I- Elapse time for running write_parasitics is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
}


if {[info exists CREATE_LIB] && $CREATE_LIB == "true" } {
   set ANALYSIS_VIEWS [get_db [get_db analysis_views -if .is_active] .name]
   if {[regexp {setup|hold} $ANALYSIS_VIEWS]} {
   	set_analysis_view -setup $ANALYSIS_VIEWS -hold $ANALYSIS_VIEWS
   }
   foreach view_dpo [get_db [get_db analysis_views -if .is_active] .name] {
   	date
	write_timing_model -include_power_ground -view $view_dpo out/lib/${DESIGN_NAME}.${STAGE}.${view_dpo}.lib.gz -lib_name ${DESIGN_NAME}_${view_dpo}
   }
} 

if {[info exists CREATE_ILM] && $CREATE_ILM == "true" } {
	write_ilm -to_dir out/ilm/${STAGE} -overwrite  -model_type timing
}

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

# activated the be_checklist after stage is done.
redirect_and_catch "./scripts/bin/be_checklist.tcl $STAGE"

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
}

if {![info exists BATCH] || $BATCH == "true"} {
	exit
}

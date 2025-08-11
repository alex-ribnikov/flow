#################################################################################################################################################################################
#																						#
#	this script will run innovus ROUTE stage  																#
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
#	0.1	27/01/2021	Royl	initial script																#
#																						#
#																						#
#################################################################################################################################################################################
set_db source_verbose false

set STAGE route
set RUNNING_LOCAL_SCRIPTS [list]

set start_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - Start running $STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
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
	source -v scripts/setup/setup.${::env(PROJECT)}.tcl
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
set_multi_cpu_usage -local_cpu $CPU 

set_db init_delete_assigns 1
set_db init_power_nets        $PWR_NET
set_db init_ground_nets       $GND_NET
set_db init_keep_empty_modules true

#------------------------------------------------------------------------------
# define and read mmmc 
#------------------------------------------------------------------------------
source scripts/flow/mmmc_create.tcl
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
	read_netlist -top $DESIGN_NAME ./out/db/${DESIGN_NAME}.cts.enc.dat/${DESIGN_NAME}.v.gz
	init_design
	read_def ./out/def/${DESIGN_NAME}.cts.def.gz
} else {
	puts "-I- read design from cts db"
	read_db -lef_files $LEF_FILE_LIST -mmmc_file $mmmc_results  out/db/${DESIGN_NAME}.cts.enc.dat
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
return
#------------------------------------------------------------------------------
# extra setting and operations 
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_route_setting.tcl]} {
	puts "-I- running Extra setting from scripts_local/pre_route_setting.tcl"
	check_script_location scripts_local/pre_route_setting.tcl
	source -v ./scripts_local/pre_route_setting.tcl
}

#------------------------------------------------------------------------------
#  Route route_early_global
#------------------------------------------------------------------------------
#update_io_latency -verbose

add_fillers

##### standard wbRouteDesign
set be_stage ${STAGE}_track_opt
eee_stage $be_stage {route_design -track_opt}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.route_track_opt.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.route_track_opt.def.gz
if {[info exists ROUTE_END_ITERATION] && $ROUTE_END_ITERATION > 0 } {
	puts "-I- stop script after route iteration $ROUTE_END_ITERATION"
	return
}


#------------------------------------------------------------------------------
# reports after route eraly opt
#------------------------------------------------------------------------------
time_design -hold -report_only -timing_debug_report -expanded_views -report_dir reports/route/track_opt -num_paths 10000 
time_design       -report_only -timing_debug_report -expanded_views -report_dir reports/route/track_opt -num_paths 10000 

set_db check_drc_disable_rules out_of_die
check_drc -limit 300000 -out_file reports/route/track_opt/track_opt_drc.rpt  

report_power -out_file reports/route/track_opt/power.rpt
user_report_inst_vt reports/route/track_opt/threshold_instance_count.rpt
# report_scan_chain -verbose > reports/$STAGE/${be_stage}_only_power.rpt

gui_create_floorplan_snapshot -dir reports/route/track_opt/snapshot -name ${DESIGN_NAME} -overwrite
gui_write_flow_gifs -dir reports/route/track_opt/snapshot -prefix [get_db designs .name] -full_window
gui_hide

be_reports     -stage $be_stage -all
be_sum_to_csv  -stage $be_stage 



#------------------------------------------------------------------------------
# DFM opt design
#------------------------------------------------------------------------------
if {[info exists DFM_REDUNDANT_VIA] && [file exists $DFM_REDUNDANT_VIA]} {
	set_db opt_new_inst_prefix "i_${STAGE}_multi_cut_"
	set_db opt_new_net_prefix  "n_${STAGE}_multi_cut_"
	
	report_route -multi_cut > reports/route/multi_cut/route_track_opt.multicut.init.rpt
	eval_legacy "source $DFM_REDUNDANT_VIA"
	report_route -multi_cut > reports/route/multi_cut/route_track_opt.multicut.final.rpt

	##### standard wbOptDesignPostRoute
	set_db extract_rc_engine post_route
	if {[get_db [get_db designs] .is_rc_extracted] != true} {
	  if {[get_db extract_rc_effort_level] == "high"} {
	   if {[get_db design_process_node] < 7} {
	  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_5nm_modeling"
	   } else {
	  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_10nm_modeling"
	   }
	  }
	  extract_rc 
	}
	
	time_design       -report_only -timing_debug_report -expanded_views -report_dir reports/route/route_multi_cut -num_paths 10000 
	time_design -hold -report_only -timing_debug_report -expanded_views -report_dir reports/route/route_multi_cut -num_paths 10000 
}

#------------------------------------------------------------------------------
# route track opt design
#------------------------------------------------------------------------------
set be_stage ${STAGE}_route_opt

set_db opt_new_inst_prefix "i_${STAGE}_route_opt_"
set_db opt_new_net_prefix  "n_${STAGE}_route_opt_"
set_dont_use [get_lib_cells $HOLD_FIX_CELLS_LIST] false
set_db opt_fix_hold_ignore_path_groups {in2reg reg2out in2out}

if {[get_db extract_rc_effort_level] == "high"} {
   if {[get_db design_process_node] < 7} {
  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_5nm_modeling"
   } else {
  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_10nm_modeling"
   }
}
eee_stage $be_stage {opt_design  -setup -hold     -expanded_views  -post_route  -report_dir reports/route/route_opt_design}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.route_opt.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.route_opt.def.gz

#------------------------------------------------------------------------------
# reports after route track opt
#------------------------------------------------------------------------------
if {[get_db [get_db designs] .is_rc_extracted] != true} {
  if {[get_db extract_rc_effort_level] == "high"} {
   if {[get_db design_process_node] < 7} {
  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_5nm_modeling"
   } else {
  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_10nm_modeling"
   }
  }
  extract_rc 
}

time_design       -report_only -timing_debug_report -expanded_views -report_dir reports/route/route_opt -num_paths 10000 
time_design -hold -report_only -timing_debug_report -expanded_views -report_dir reports/route/route_opt -num_paths 10000 
report_metric -format html -file reports/route/route_opt/${DESIGN_NAME}.route_opt.html
write_metric  -format csv  -file reports/route/route_opt/${DESIGN_NAME}.route_opt.csv
check_drc -limit 300000 -out_file reports/route/route_opt/route_opt.rpt  

gui_create_floorplan_snapshot -dir reports/route/route_opt/snapshot -name "${DESIGN_NAME}.route_opt" -overwrite
gui_write_flow_gifs -dir reports/route/route_opt/snapshot -prefix "[get_db designs .name].route_opt" -full_window
gui_hide

be_reports     -stage $be_stage -all
be_sum_to_csv  -stage $be_stage 

#------------------------------------------------------------------------------
# DRC check and fix
#------------------------------------------------------------------------------
eee_stage route_eco {route_eco -fix_drc}
check_drc -limit 500000

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.route_drc.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.route_drc.def.gz




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
# delete Dangling Nets
#------------------------------------------------------------------------------
delete_floating_nets
report_floating_nets -out_file reports/route/report_floating_nets.rpt


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

set default_setup_view [get_db [get_db analysis_views -if .is_active==true&&.is_setup_default] .name] 
set cmd "write_sdc -view $default_setup_view  ../inter/${DESIGN_NAME}.${STAGE}.sdc"
puts "-I- Running: $cmd"
eval $cmd

#------------------------------------------------------------------------------
# final LEC
#------------------------------------------------------------------------------
write_do_lec -flat \
	-golden_design [pwd]/out/db/${DESIGN_NAME}.place.enc.dat/${DESIGN_NAME}.v.gz \
	-revised_design [pwd]/out/db/${DESIGN_NAME}.${STAGE}.enc.dat/${DESIGN_NAME}.v.gz \
	-checkpoint [file join [get_db write_lec_directory_naming_style] lec.route.ckpt]   lec.route.do


#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
if {[get_db [get_db designs] .is_rc_extracted] != true} {
  if {[get_db extract_rc_effort_level] == "high"} {
   if {[get_db design_process_node] < 7} {
  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_5nm_modeling"
   } else {
  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_10nm_modeling"
   }
  }
  extract_rc 
}

time_design -report_only -timing_debug_report -expanded_views -report_dir reports/route -num_paths 10000 
time_design -report_only -timing_debug_report -expanded_views -report_dir reports/route -num_paths 10000 -hold

exec gawk -f scripts/bin/slacks.awk reports/route/${DESIGN_NAME}_all.tarpt       > reports/route/${DESIGN_NAME}_all.summary
exec gawk -f scripts/bin/slacks.awk reports/route/${DESIGN_NAME}_reg2reg.tarpt   > reports/route/${DESIGN_NAME}_reg2reg.summary
exec gawk -f scripts/bin/slacks.awk reports/route/${DESIGN_NAME}_reg2cgate.tarpt > reports/route/${DESIGN_NAME}_reg2cgate.summary
exec gawk -f scripts/bin/slacks.awk reports/route/${DESIGN_NAME}_in2reg.tarpt    > reports/route/${DESIGN_NAME}_in2reg.summary
exec gawk -f scripts/bin/slacks.awk reports/route/${DESIGN_NAME}_reg2out.tarpt   > reports/route/${DESIGN_NAME}_reg2out.summary
exec gawk -f scripts/bin/slacks.awk reports/route/${DESIGN_NAME}_in2out.tarpt    > reports/route/${DESIGN_NAME}_in2out.summary
exec gawk -f scripts/bin/slacks.awk reports/route/${DESIGN_NAME}_default.tarpt   > reports/route/${DESIGN_NAME}_default.summary


report_power -out_file reports/route/power.rpt
user_report_inst_vt reports/route/threshold_instance_count.rpt

report_metric -format html -file reports/route/${DESIGN_NAME}.html
write_metric  -format csv  -file reports/route/${DESIGN_NAME}.csv

gui_create_floorplan_snapshot -dir reports/route/snapshot -name ${DESIGN_NAME} -overwrite
gui_write_flow_gifs -dir reports/route/snapshot -prefix [get_db designs .name] -full_window
gui_hide

check_connectivity -ignore_dangling_wires -error 100000 -out_file reports/route/check_connectivity.rpt 

set end_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - End running $STAGE at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
puts "-I- BE_STAGE: $STAGE - Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

be_reports    -stage $STAGE -block $DESIGN_NAME -all

#------------------------------------------------------------------------------
# Hierarchical flow
#------------------------------------------------------------------------------
if {[get_db [get_db designs] .is_rc_extracted] != true} {
  if {[get_db extract_rc_effort_level] == "high"} {
   if {[get_db design_process_node] < 7} {
  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_5nm_modeling"
   } else {
  	user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_10nm_modeling"
   }
  }
  extract_rc 
}

#------------------------------------------------------------------------------
# Hierarchical flow
#------------------------------------------------------------------------------
if {[info exists CREATE_LIB] && $CREATE_LIB == "true" } {
   foreach rc_corner_ [get_db [get_db rc_corners -if ".is_active"] .name] {
	write_parasitics -rc_corner $rc_corner_ -spef_file out/spef/${DESIGN_NAME}.${STAGE}_${rc_corner_}.spef.gz
   }
   set ANALYSIS_VIEWS [get_db [get_db analysis_views -if .is_active] .name]
   if {[regexp {setup|hold} $ANALYSIS_VIEWS]} {
   	set_analysis_view -setup $ANALYSIS_VIEWS -hold $ANALYSIS_VIEWS
   }
   
   foreach view_dpo [get_db [get_db analysis_views -if .is_active] .name] {
   	date
	write_timing_model -include_power_ground -view $view_dpo out/lib/${DESIGN_NAME}.${STAGE}.${view_dpo}.lib.gz -lib_name ${DESIGN_NAME}_${view_dpo}
   }
} else {
	write_ilm -to_dir out/ilm/${STAGE} -overwrite  -model_type timing
}

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
report_resource

be_sum_to_csv -stage $STAGE -mail -final
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


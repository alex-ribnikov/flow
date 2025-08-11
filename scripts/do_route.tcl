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

if { ![file exists out/sdc] } { exec mkdir -pv out/sdc }

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
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
	source -v scripts/setup/setup.${PROJECT}.tcl
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
	if {[info exists NEW_SDC] && $NEW_SDC == "true"} {
		puts "-I- read design from cts db"
		read_db -lef_files $LEF_FILE_LIST -mmmc_file $mmmc_results  out/db/${DESIGN_NAME}.cts.enc.dat
	} else {
		read_db out/db/${DESIGN_NAME}.cts.enc.dat
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
set hook_script "./scripts_local/pre_route_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

#------------------------------------------------------------------------------
#  Route route_early_global
#------------------------------------------------------------------------------
#update_io_latency -verbose

add_fillers

set_db opt_new_inst_prefix "i_${STAGE}_topt_"
set_db opt_new_net_prefix  "n_${STAGE}_topt_"

if {[info exists BREAK_ROUTE] && $BREAK_ROUTE} {
##### standard wbRouteDesign
   set be_stage ${STAGE}_track_opt
   eee_stage $be_stage {route_design -track_opt}
} else {
   set be_stage ${STAGE}_opt_design
   eee_stage $be_stage {route_opt_design -report_dir reports/route/route_opt_design}
}

#------------------------------------------------------------------------------
# post route track extra setting 
#------------------------------------------------------------------------------
set hook_script "./scripts_local/post_route_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
if {[info exists BREAK_ROUTE] && $BREAK_ROUTE} {
   write_db -verilog      out/db/${DESIGN_NAME}.route_track_opt.enc.dat
   write_def -routing     out/def/${DESIGN_NAME}.route_track_opt.def.gz
   if {[info exists ROUTE_END_ITERATION] && $ROUTE_END_ITERATION > 0 } {
	puts "-I- stop script after route iteration $ROUTE_END_ITERATION"
	return
   }
} 

#------------------------------------------------------------------------------
# reports after route eraly opt
#------------------------------------------------------------------------------
if {[info exists BREAK_ROUTE] && $BREAK_ROUTE} {
   time_design -hold -report_only -timing_debug_report -expanded_views -report_dir reports/route/track_opt -num_paths 10000 
   time_design       -report_only -timing_debug_report -expanded_views -report_dir reports/route/track_opt -num_paths 10000 

   set_db check_drc_disable_rules out_of_die
   check_drc -limit 300000 -out_file reports/route/track_opt/track_opt_drc.rpt  

   report_power -out_file reports/route/track_opt/power.rpt
   user_report_inst_vt reports/route/track_opt/threshold_instance_count.rpt
   # report_scan_chain -verbose > reports/$STAGE/${be_stage}_only_power.rpt


   set cmd "gui_create_floorplan_snapshot -dir reports/route/track_opt/snapshot -name ${DESIGN_NAME} -overwrite"
   if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res }
   set cmd "gui_write_flow_gifs -dir reports/route/track_opt/snapshot -prefix [get_db designs .name] -full_window"
   if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res } { gui_hide }

   be_reports     -stage $be_stage -all
   be_sum_to_csv  -stage $be_stage 
}



#------------------------------------------------------------------------------
# DFM opt design
#------------------------------------------------------------------------------
if {[info exists ROUTE_DFM] && $ROUTE_DFM == "true"} {
    set_db opt_new_inst_prefix "i_${STAGE}_multi_cut_"
    set_db opt_new_net_prefix  "n_${STAGE}_multi_cut_"

    report_route -multi_cut > reports/route/route_track_opt.multicut.init.rpt	
    if {[info exists DFM_REDUNDANT_VIA] && [file exists $DFM_REDUNDANT_VIA]} {
	eval_legacy "source $DFM_REDUNDANT_VIA"
    } else {
	set_db route_design_via_weight {VIA*_DFM_P1_VIA* 11,  VIA*_DFM_P2_VIA* 10,  VIA*_DFM_P3_VIA* 9,  VIA*_DFM_P4_VIA* 8,  VIA*_DFM_P5_VIA* 7,  VIA*_DFM_P6_VIA* 6,  VIA*_DFM_P7_VIA* 5,  VIA*_DFM_P8_VIA* 4,  VIA*_DFM_P9_VIA* 3}
	set_db route_design_detail_post_route_swap_via true
	eee {route_design -via_opt}
    }

    report_route -multi_cut > reports/route/route_track_opt.multicut.final.rpt
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

    #------------------------------------------------------------------------------
    # save design
    #------------------------------------------------------------------------------
    write_db -verilog      out/db/${DESIGN_NAME}.route_multi_cut.enc.dat
    write_def -routing     out/def/${DESIGN_NAME}.route_multi_cut.def.gz


    time_design       -report_only -timing_debug_report -expanded_views -report_dir reports/route/route_multi_cut -num_paths 10000 
    time_design -hold -report_only -timing_debug_report -expanded_views -report_dir reports/route/route_multi_cut -num_paths 10000 
}

#------------------------------------------------------------------------------
# pre route opt extra setting 
#------------------------------------------------------------------------------
set hook_script "./scripts_local/pre_route_opt_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

#------------------------------------------------------------------------------
# route track opt design
#------------------------------------------------------------------------------
set be_stage ${STAGE}_route_opt
if {([info exists BREAK_ROUTE] && $BREAK_ROUTE) || ([info exists ROUTE_DFM] && $ROUTE_DFM)} {

   set_db opt_new_inst_prefix "i_${STAGE}_ropt_"
   set_db opt_new_net_prefix  "n_${STAGE}_ropt_"
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
}


#------------------------------------------------------------------------------
# post route opt extra setting 
#------------------------------------------------------------------------------
set hook_script "./scripts_local/post_route_opt_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

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

set cmd "gui_create_floorplan_snapshot -dir reports/route/route_opt/snapshot -name ${DESIGN_NAME}.route_opt -overwrite"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res }
set cmd "gui_write_flow_gifs -dir reports/route/route_opt/snapshot -prefix [get_db designs .name].route_opt -full_window"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res } { gui_hide }

set_db user_stage_reports_dir reports/${STAGE}/route_opt

be_reports     -stage $be_stage -all
be_sum_to_csv  -stage $be_stage 

set_db user_stage_reports_dir reports/${STAGE}

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

foreach MODE [get_db constraint_modes .name] {
	set default_setup_view [get_db [get_db analysis_views -if ".is_active==true&&.is_setup_default && .constraint_mode == *${MODE}"] .name] 
	set cmd "write_sdc -view $default_setup_view  out/sdc/${DESIGN_NAME}.${STAGE}.${MODE}.sdc"
	puts "-I- Running: $cmd"
	eval $cmd
}

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

exec zcat reports/route/${DESIGN_NAME}_all.tarpt.gz       | gawk -f scripts/bin/slacks.awk > reports/route/${DESIGN_NAME}_all.summary
exec zcat reports/route/${DESIGN_NAME}_reg2reg.tarpt.gz   | gawk -f scripts/bin/slacks.awk > reports/route/${DESIGN_NAME}_reg2reg.summary
exec zcat reports/route/${DESIGN_NAME}_reg2cgate.tarpt.gz | gawk -f scripts/bin/slacks.awk > reports/route/${DESIGN_NAME}_reg2cgate.summary
exec zcat reports/route/${DESIGN_NAME}_in2reg.tarpt.gz    | gawk -f scripts/bin/slacks.awk > reports/route/${DESIGN_NAME}_in2reg.summary
exec zcat reports/route/${DESIGN_NAME}_reg2out.tarpt.gz   | gawk -f scripts/bin/slacks.awk > reports/route/${DESIGN_NAME}_reg2out.summary
exec zcat reports/route/${DESIGN_NAME}_in2out.tarpt.gz    | gawk -f scripts/bin/slacks.awk > reports/route/${DESIGN_NAME}_in2out.summary
exec zcat reports/route/${DESIGN_NAME}_default.tarpt.gz   | gawk -f scripts/bin/slacks.awk > reports/route/${DESIGN_NAME}_default.summary

exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_all.tarpt.gz      
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_reg2reg.tarpt.gz  
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_reg2cgate.tarpt.gz
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_in2reg.tarpt.gz   
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_reg2out.tarpt.gz  
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_in2out.tarpt.gz   
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_default.tarpt.gz  


exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_all_hold.tarpt.gz      
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_reg2reg_hold.tarpt.gz  
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_reg2cgate_hold.tarpt.gz
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_in2reg_hold.tarpt.gz   
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_reg2out_hold.tarpt.gz  
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_in2out_hold.tarpt.gz   
exec ./scripts/bin/timing_filter.pl reports/route/${DESIGN_NAME}_default_hold.tarpt.gz  

report_skew_groups -out_file reports/route/route_skew_groups.rpt
#report_clock_trees -histograms -num_transition_time_violating_pins 5000 -out_file reports/route/route_clock_trees.rpt
report_clock_trees  -num_transition_time_violating_pins 5000 -out_file reports/route/route_clock_trees.rpt

report_power -out_file reports/route/power.rpt
user_report_inst_vt reports/route/threshold_instance_count.rpt

report_metric -format html -file reports/route/${DESIGN_NAME}.html
write_metric  -format csv  -file reports/route/${DESIGN_NAME}.csv

set cmd "gui_create_floorplan_snapshot -dir reports/route/snapshot -name ${DESIGN_NAME} -overwrite"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res }
set cmd "gui_write_flow_gifs -dir reports/route/snapshot -prefix [get_db designs .name] -full_window"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res } { gui_hide }

check_connectivity -ignore_dangling_wires -error 100000 -out_file reports/route/check_connectivity.rpt 

be_check_multiport $STAGE

set end_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - End running $STAGE at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
puts "-I- BE_STAGE: $STAGE - Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

be_reports    -stage $STAGE -block $DESIGN_NAME -all
#===================================================================
#    Post-route checkers, for be_checklist 
#===================================================================
 set pnr [lindex [ split  [exec pwd] "/" ] end]
 regsub "pnr" $pnr  "" prefix
 set WA [join [regsub "pnr.*" [split [exec pwd] "/"] ""] "/"]

# 1. check constraints, 
 eee  constraints_check ${STAGE}.time

# 2. clock tree ndr : route rule & violations:
eee  check_clock_ndr ${STAGE}.time

# 3. check that each clock pin, start with clock (clock tree)
eee  check_clock_to_each_clk_pin ${STAGE}.time

# 4. route quality
eee  route_quality_check ${STAGE}.time

# 5. check long nets
eee  check_nets_length ${STAGE}.time

# 6. dont use cell check
eee  dont_use_cells_check ${STAGE}.time

# 7. check DCAPs, around clock tree cells
eee  check_dcaps_around_clock_cells  ${STAGE}.time

# 7. check DCAPs, around FFs cells
eee  check_dcaps_around_ff_cells  ${STAGE}.time

#===================================================================
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
if {[info exists CREATE_SPEF] && ($CREATE_SPEF == "true" || [regexp "route" $CREATE_SPEF] )} {

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
report_resource

be_sum_to_csv -stage $STAGE -mail -final
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


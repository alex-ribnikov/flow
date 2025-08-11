#################################################################################################################################################################################
#																						#
#	this script will run Fusion_compiler  																		#
#	variable received from shell are:																	#
#		CPU		- number of CPU to run.8 per license														#
#		DESIGN_NAME	- name of top model																#
#		IS_PHYSICAL	- runing physical synthesis															#
#		SCAN 		- insert scan to the design															#
#		OCV 		- run with ocv 																	#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	27/11/2024	Royl	initial script																#
#																						#
#																						#
#################################################################################################################################################################################
if {[info exists LABEL]}         {puts "LABEL $LABEL"} else {set LABEL "None" }
if {[info exists SORT_BY_TIMING_METRICS] && $SORT_BY_TIMING_METRICS == "None"}         {set SORT_BY_TIMING_METRICS "" }

set STAGE syn

set start_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - Start running $STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
# create proc just for synopsys
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
if {![file exists ./reports/init]} {exec mkdir -pv ./reports/init}
if {![file exists ./reports/syn]} {exec mkdir -pv ./reports/syn}
if {![file exists ./reports/qor_data]} {exec mkdir -pv ./reports/qor_data}
if {![file exists ./reports/${STAGE}/snapshots]} {exec mkdir -pv ./reports/${STAGE}/snapshots}

set_host_options -max_cores $CPU

script_runtime_proc -start
#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	set setup_file scripts/setup/setup.${PROJECT}.tcl
}
source -v $setup_file
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------

open_lib out/${DESIGN_NAME}_lib
copy_block -from ${DESIGN_NAME}/init -to ${DESIGN_NAME}/syn -force
open_block ${DESIGN_NAME}/syn
link_block

report_scenarios

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/rtla_variables.tcl]} {
	puts "-I- reading rtla_variables file from scripts_local"
	source -e -v scripts_local/rtla_variables.tcl
} else {
	puts "-I- reading rtla_variables file from scripts"
	source -e -v scripts/flow/rtla_variables.tcl
}

#------------------------------------------------------------------------------
# floorplan
#------------------------------------------------------------------------------

if {[info exists MANUAL_FP] && $MANUAL_FP  } {
        puts "-I- manual FP.\ndo source scripts_local/user_manual_fp.tcl"
        return
} elseif {$DEF_FILE != "None" } {
        #def read into original design
	#read_def -no_incremental -add_def_only_objects all $DEF_FILE
} elseif {[file exists scripts_local/user_manual_fp.tcl]} {
        source -e -v ./scripts_local/user_manual_fp.tcl
} else {
        puts "-I- using default RTLA floorplanning"
}
	
if {${DYNAMIC_POWER_ANALYSIS}} {
  # this needs aligned with pp_setup.tcl
  if {${POWER_ANNOTATION} != "fsdb" && ${POWER_ANNOTATION} != "saif"} {
    set_app_option -list "power.default_toggle_rate $TOGGLE_RATE"
    #redirect ./reports/infer_switching_activity.log  "infer_switching_activity -apply -sci_based all -scenario ${scenarios(dynamic)}"
    set_switching_activity -scenarios ${scenarios(dynamic)} -toggle_rate 1 -clock_derate $CLOCK_DERATE \
      [get_pins -of [get_flat_cells -filter is_integrated_clock_gating_cell] \
      -filter "direction == out"] -static_probability 0.5
  }
}

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/rtla_pre_design_variables.tcl]} {
	puts "-I- reading rtla_pre_design_variables file from scripts_local"
	source -v -e scripts_local/rtla_pre_design_variables.tcl
} else {
	puts "-I- reading rtla_pre_design_variables file from scripts"
	source -v -e scripts/flow/rtla_pre_design_variables.tcl
}
#------------------------------------------------------------------------------
#  setting
#------------------------------------------------------------------------------

##############################################################
### effort setting
##############################################################
if {[info exists EFFORT] && $EFFORT == "low" } {
  set_rtl_opt_strategy -congestion relaxed -timing  relaxed -power relaxed
} elseif {[info exists EFFORT] && $EFFORT == "medium" }  {
  set_rtl_opt_strategy -congestion default -timing  default -power default
} elseif {[info exists EFFORT] && $EFFORT == "high" }  {
  set_rtl_opt_strategy -congestion high -timing  high -power high
} elseif {[info exists EFFORT] && $EFFORT == "extreme" }  {
  set_rtl_opt_strategy -congestion high -timing  high -power high
} else {
  set_rtl_opt_strategy -reset
}
set rm_lib_type [get_attribute -quiet [current_design] rm_lib_type]


## set_stage : a command to apply stage-based application options; intended to be used after set_qor_strategy within RM scripts.
redirect -file reports/syn/set_stage.synthesis {set_stage -step synthesis -report}
set_stage -step synthesis


set_app_options -name time.si_enable_analysis  			 -value false
set_app_options -name time.remove_clock_reconvergence_pessimism	 -value false

# Enable FAST CTS engine if required for better clock power estimation
if {$ENABLE_CTS} {
       set_app_options -name time.remove_clock_reconvergence_pessimism	 -value true
       set_app_option -name rtl_opt.flow.enable_cts -value true
	## Prefix
	set_app_options -name opt.common.user_instance_name_prefix -value compile_
	set_app_options -name cts.common.user_instance_name_prefix -value compile_cts_
}

# Enable multibit inference, banking and debanking 
if {$ENABLE_MULTIBIT} {
        set_app_options -name compile.flow.enable_multibit -value true
} else {
        set_app_options -name compile.flow.enable_multibit -value false
}



redirect -file reports/syn/check_stage_settings {check_stage_settings -stage synthesis -metric timing -step synthesis}

#TBD roy 01122024
#/bespace/users/royl/deliveries/from_snps/CBU_power_run_TC_2024099_334138/baseline20_SCO_power/rm_user_plugin_scripts/compile_pre_script.tcl

#------------------------------------------------------------------------------
# Run RTL Conditioning
#------------------------------------------------------------------------------
set rtl_opt_cmd "rtl_opt -from conditioning -to conditioning"

suppress_message CMD-007
echo $rtl_opt_cmd
eval $rtl_opt_cmd
unsuppress_message CMD-007
 
##########################################################################################
# Post RTL Conditioning Customizations
##########################################################################################
if {[file exists scripts_local/post_conditioning_script.tcl]} {
	puts "-I- reading /post_conditioning_script.tcl file from scripts_local"
	source -v scripts_local/post_conditioning_script.tcl.tcl
}
  
##########################################################################################
# Run RTL Estimation
##########################################################################################

set rtl_opt_cmd "rtl_opt -from estimation -to estimation "

echo $rtl_opt_cmd
eval $rtl_opt_cmd


if {$CREATE_ABSTRACT} {
# Create a frame view in case this will be used in a bottom-up hierarchical flow
create_frame

create_abstract -read_only
}

save_block -hier -as ${DESIGN_NAME}/syn

##########################################################################################
# Metrics (Congestion, Timing and Power) - Reports & Queries
##########################################################################################
set_app_options -name metrics.timing.max_paths -value 1000 						 ; # Specifies  the  maximum  number of violating paths. Default is 50, increasing it may impact runtime.
set_app_options -name metrics.timing.auto_adjust_max_logic_levels -value true				 ; # Report logic level violations even on paths with positive slack

set metrics_cmd "compute_metrics -congestion -timing"

# Congestion and Timing Metrics Computation 
echo $metrics_cmd
eval $metrics_cmd

if {${DYNAMIC_POWER_ANALYSIS}} {
  #############################################
  # Power
  #############################################
  if {[file exists RTLA_glitch_workspace]} {
    file delete -force RTLA_glitch_workspace
  }

  echo "MPR 0"
  source -echo scripts_local/rtl_power_setup.tcl
   
  if {! $ENABLE_CTS } {
   set_ideal_network [get_nets -of_objects [get_clock_tree_pins]]
  }
  
  set metrics_power_cmd "compute_metrics -power"
  
  #Power Metrics Computation
  echo $metrics_power_cmd
  eval $metrics_power_cmd
}

#-------------------------------------------------------------------------------------------#
# Congestion Metrics
#-------------------------------------------------------------------------------------------#

# Congestion summary for Top-level hierarchy and all it's descendants (child logical hierarchies) 
report_metrics -congestion  > reports/${DESIGN_NAME}.metrics.congestion.summary.rpt



# Nworst Congested Hierarchies
get_metrics -nworst 10 -metric metrics_cong_number_cells -local > reports/${DESIGN_NAME}.metrics.congestion.nworst_congested_hierarchies.rpt
# Nworst Logic Congested Hierarchies (Logic-Structure Induced Congestion) 
get_metrics -nworst 10 -metric metrics_cong_number_cells_in_cong_area -local > reports/${DESIGN_NAME}.metrics.congestion.nworst_logic_congested_hierarchies.rpt
# Nworst Channel Congested Hierarchies (Narrow Channel or Floorplan Congestion) 
get_metrics -nworst 10 -metric metrics_cong_number_cells_in_cong_channel -local > reports/${DESIGN_NAME}.metrics.congestion.nworst_channel_congested_hierarchies.rpt

# Nworst RTL lines which generates most congested cells
get_metrics -metric metrics_cong_number_cells_in_cong_area -rtl_worst_lines 10  > reports/${DESIGN_NAME}.metrics.congestion.rtl_worst_lines.rpt 



# To report number of congested cells generated by rtl.v, line 10.
# get_metrics -rtl_line {rtl.v 10} -metrics metrics_cong_number_cells_in_cong_area 

# To list all congested cells generated by rtl.v, line 10.
# get_metrics -rtl_line {rtl.v 10} -metrics metrics_cong_number_cells_in_cong_area  -detail

#-------------------------------------------------------------------------------------------#
# Timing Metrics
#-------------------------------------------------------------------------------------------#

# Timing summary for Top-level hierarchy and all it's descendants (child logical hierarchies) 
report_metrics  -timing      > reports/${DESIGN_NAME}.metrics.timing.summary.rpt

if {[sizeof_collection [get_cells -hierarchical -filter "is_hierarchical && hierarchy_type == normal" -quiet ]] } {
	set timing_cells_metrics [list ]
	foreach_in_collection LH [get_cells -hierarchical -filter "is_hierarchical && hierarchy_type == normal"] {
		if {[get_attribute [get_cells $LH] $SORT_BY_TIMING_METRICS] !=""} {
			lappend timing_cells_metrics "[get_object_name $LH] [get_attribute [get_cells $LH] $SORT_BY_TIMING_METRICS]"
		}
	}
	set timing_cells_metrics [lsort -integer -index 1 -decreasing $timing_cells_metrics]
	set LH_instances [list ]
	foreach LH $timing_cells_metrics { lappend LH_instances [lindex $LH 0] }
	if {[llength $LH_instances] > 0} {
		report_metrics -timing -cells $LH_instances -table -local > reports/${DESIGN_NAME}.metrics.timing.detailed.rpt
	}
}


# Nworst R2R wns
get_metrics -nworst 10 -metric metrics_tim_wns_r2r -local > reports/${DESIGN_NAME}.metrics.timing.nworst_tim_wns_r2r.rpt
# Nworst R2R tns
get_metrics -nworst 10 -metric metrics_tim_tns_r2r -local > reports/${DESIGN_NAME}.metrics.timing.nworst_tim_tns_r2r.rpt
# Nworst R2R nvp
get_metrics -nworst 10 -metric metrics_tim_nvp_r2r -local > reports/${DESIGN_NAME}.metrics.timing.nworst_tim_nvp_r2r.rpt
# Nworst R2R zero wire load violations
get_metrics -nworst 10 -metric metrics_tim_zwl_viol_count -local > reports/${DESIGN_NAME}.metrics.timing.nworst_tim_zwl_viol_count.rpt

# R2R path details
get_metrics -details -path_table -metric metrics_tim_tns_r2r > reports/${DESIGN_NAME}.metrics.timing.path_table_tim_tns_r2r.rpt
# Logic levels path deatils, even on paths with postive slack
get_metrics -details -path_table -metric metrics_tim_logic_levels_viol > reports/${DESIGN_NAME}.metrics.timing.path_table_tim_logic_levels_viol.rpt

#-------------------------------------------------------------------------------------------#
# Power Metrics
#-------------------------------------------------------------------------------------------#
# Nworst contribute to leakage power

if {[sizeof_collection [get_scenarios -filter "leakage_power"]] > 0} {
#	compute_metrics -power -scenario [get_scenarios -filter "leakage_power"]
#	get_metrics -nworst 10 -metric leakage_power   -scenario [get_scenarios -filter "leakage_power"] > reports/${DESIGN_NAME}.metrics.power.nworst_leakage_power.rpt
}
if {${DYNAMIC_POWER_ANALYSIS}} {
 
  # do not generate power reports centrally if we are using the multiple-FSDB flow
  # Power summary for Top-level hierarchy and all it's descendants (child logical hierarchies)
  set power_metrics_report_cmd "report_metrics -power -scenario ${scenarios(dynamic)}"

  echo $power_metrics_report_cmd
  eval $power_metrics_report_cmd > reports/${DESIGN_NAME}.metrics.power.summary.rpt

  # Nworst contribute to total power
  get_metrics -nworst 10 -metric total_power  -scenario ${scenarios(dynamic)} > reports/${DESIGN_NAME}.metrics.power.nworst_total_power.rpt
  # Nworst contribute to internal power
  get_metrics -nworst 10 -metric internal_power  -scenario ${scenarios(dynamic)} > reports/${DESIGN_NAME}.metrics.power.nworst_internal_power.rpt
  # Nworst contribute to switching power
  get_metrics -nworst 10 -metric switching_power  -scenario ${scenarios(dynamic)} > reports/${DESIGN_NAME}.metrics.power.nworst_switching_power.rpt

}

########################################################################################
# Advanced Reports
###########################################################################################
set DATE [sh date +%F:%H:%M]

# ----------------------------------------
# Basic Reports
# ---------------------------------------
redirect reports/${DESIGN_NAME}.design.${DATE}.rpt	      { report_design -all}
redirect reports/${DESIGN_NAME}.check_timing.${DATE}.rpt       { check_timing -all }
redirect reports/${DESIGN_NAME}.clock.${DATE}.rpt              { report_clock }

redirect reports/${DESIGN_NAME}.scenarios.${DATE}.rpt          { report_scenarios }


# ----------------------------------------
# Area
# ----------------------------------------
redirect reports/${DESIGN_NAME}.area.${DATE}.rpt               { report_area }
redirect -append reports/${DESIGN_NAME}.area.${DATE}.rpt       { report_reference }
redirect reports/${DESIGN_NAME}.area_hier.${DATE}.rpt          { report_reference -hierarchical }
redirect reports/${DESIGN_NAME}.area.hier.${DATE}.rpt          { report_area -hierarchy -nosplit }
redirect reports/${DESIGN_NAME}.qor_summary.${DATE}.rpt        { report_qor -summary }
redirect reports/${DESIGN_NAME}.utilization.${DATE}.rpt        { report_utilization }
redirect reports/${DESIGN_NAME}.congestion.${DATE}.rpt         { report_congestion } 


# ----------------------------------------
# TIMING REPORTS
# ----------------------------------------
redirect reports/${DESIGN_NAME}.global_timing.${DATE}.rpt       { report_global_timing }
redirect reports/${DESIGN_NAME}.timing_per_scenario.${DATE}.rpt { report_metrics -timing -scenario [get_scenarios * -filter "active==true"] -table }
foreach_in_col sc [get_scenarios -f "active==true && setup==true"] {
	redirect reports/${DESIGN_NAME}.top50_timingpaths.[get_attr $sc name].${DATE}.rpt         { report_timing  -max_paths 50 -nworst 1 -nets -derate -scenario $sc }
}


if {$RUN_TIMING_REPORTS} {
	report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 > reports/syn/syn.rpt.detailed

   foreach path_group [get_object_name [get_path_groups]] {
	report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 -slack_lesser_than 0 -group $path_group > reports/syn/syn.rpt.$path_group.detailed
   }

   exec gawk -f ./scripts/bin/slacks.awk reports/syn/syn.rpt.detailed     | sort -n > reports/syn/syn.rpt
   foreach path_group [get_object_name [get_path_groups]] {
	exec gawk -f ./scripts/bin/slacks.awk reports/syn/syn.rpt.$path_group.detailed | sort -n > reports/syn/syn.rpt.$path_group
   }

   report_qor > reports/syn/report_qor.syn.rpt
   report_area -nosplit > reports/syn/report_area.syn.rpt
   report_area -nosplit -hierarchy > reports/syn/report_area_hierarchy.syn.rpt
   report_clock_gating -nosplit > reports/syn/report_clock_gating.syn.rpt

}

# ----------------------------------------
# POWER REPORTS
# ----------------------------------------
#  redirect reports/${DESIGN_NAME}.power_metrics.${DATE}.rpt 	{ report_metrics -power -scenario ${scenarios(dynamic)}  }
#  redirect reports/${DESIGN_NAME}.power.${DATE}.rpt		{ report_power  -scenario ${scenarios(dynamic)} }
  redirect reports/${DESIGN_NAME}.clock_gating.${DATE}.rpt 	{ report_clock_gating }
  redirect reports/${DESIGN_NAME}.multibit.${DATE}.rpt  	{ report_multibit -hierarchical }
  redirect reports/${DESIGN_NAME}.threshold_voltage_groups.${DATE}.rpt       { report_threshold_voltage_groups }


if {$WRITE_QOR_DATA} {
	write_qor_data -label "RTL-A" -output reports/qor
	compare_qor_data -run_locations reports/qor -force
}

save_lib -all

report_msg -summary
print_message_info -ids * -summary

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end

#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}_done


if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
} else {

   exit
  
}

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
#set search_path [list ./rm_setup ./rm_fc_scripts ./rm_tech_scripts ./rm_user_plugin_scripts]
lappend search_path .

set_host_options -max_cores $CPU
set_app_options -name route.common.verbose_level  -value 1


   ## Enable on-disk operation for copy_block to save block to disk right away
   #  set_app_options -name design.on_disk_operation -value true ;# default false and global-scoped


set sh_continue_on_error false

# Controls HDLC naming style settings to make it easier to apply
# the same UPF file across multiple tools at the RTL level
set_app_options -name hdlin.naming.upf_compatible -value true

# set_app_options -name hdlin.elaborate.ff_infer_async_set_reset -value true
# set_app_options -name hdlin.elaborate.ff_infer_sync_set_reset  -value false
set_app_options -name hdlin.naming.shorten_long_module_name  -value true



################################################################
## Technology & settings  
################################################################
if { [regexp "tsmcn3|brcm3|nxt013" $PROJECT] } {
    set TECHNOLOGY_NODE 3e
} elseif { [regexp "brcm5|nxt009|inext" $PROJECT] } {
    set TECHNOLOGY_NODE 5
}
if {[info exists TECHNOLOGY_NODE] && $TECHNOLOGY_NODE != ""} {
	redirect -file reports/${STAGE}/set_technology {set_technology -node $TECHNOLOGY_NODE -report_only}
	set_technology -node $TECHNOLOGY_NODE
}


unset -nocomplain cmd
if {![info exists QOR_STRATEGY_METRIC]} {set QOR_STRATEGY_METRIC timing}

if {[info exists QOR_STRATEGY_STAGE] } {
	set cmd "set_qor_strategy -stage ${QOR_STRATEGY_STAGE} -mode balanced"
	if {[info exists QOR_STRATEGY_METRIC]}    { set cmd "$cmd -metric ${QOR_STRATEGY_METRIC}" }
	
	if {[info exists EFFORT_CONG] && $EFFORT_CONG == "high"}    { set cmd "$cmd -congestion_effort high" }
	if {[info exists EFFORT_CONG] && $EFFORT_CONG == "ultra"} { set cmd "$cmd -congestion_effort ultra" }
	if {[info exists EFFORT_TIMING] && $EFFORT_TIMING == "extreme"} { set cmd "$cmd -high_effort_timing" }

	redirect -file reports/${STAGE}/set_qor_strategy.${QOR_STRATEGY_STAGE} {eval ${cmd} -report_only }
	echo $cmd
	eval $cmd


}

################################################################
## reset app option   
################################################################
# LeonR reset_app_options place.coarse.max_density
# LeonR reset_app_options place.coarse.congestion_driven_max_util
enable_placer_recommended_settings

set_app_options -list {flow.runtime.version "ERI-20241001"}

# Early GR
set_app_options -list { flow.common.early_gr true }

enable_runtime_improvements

# Memory blockages zero_spacing setting
set macros [get_flat_cells -filter "design_type==macro"]
if [sizeof_collection $macros] {
       set_attribute [get_routing_blockages -of $macros] is_zero_spacing true
}
# need to run it every time.

# LeonR: WRONG. set_attribute [ get_routing_blockages -of_objects [get_flat_cells ]] is_zero_spacing true

if {$STAGE == "init"} { 
	set_app_options -list {design.enable_rule_based_query true}
} else {
	set_app_options -list {design.enable_rule_based_query false}
}

# LeonR: Disabpling before each optimization stage
	set_app_options -list {design.enable_rule_based_query true}

set_app_options -name shell.common.report_default_significant_digits -value 3

## Assure unique module names including hierarchical integration. Must run before physical constraints applied for MV designs
set_app_option -name design.uniquify_naming_style -value ${DESIGN_NAME}_%s_%d



################################################################
## block  
################################################################
set_app_options -block [current_block] -list {route.detail.save_after_iterations {4 9}}



##########################################################################################
# floorplan
##########################################################################################
	set_app_option -name plan.mtcmos.honor_pin_color_alignment -value 1
	set_app_option -name plan.mtcmos.honor_placement_spacing_rule -value 1
	# From R&D
	set_app_options -name chipfinishing.enable_advanced_legalizer_boundary_insertion -value true
	set_app_options -name chipfinishing.enable_column_based_tap_insertion -value true
	set_app_options -name chipfinishing.enable_column_based_early_fixing -value true
	
	## For foundry required to drop VDD only (ICC2/FC default behavior to drop both VDD and VSS edge)
	## No need to specify any power net name, use only VDD, only impact tap coverage checking
	set_app_options -name place.legalize.tap_cover_drop_edges -value {VDD}

##########################################################################################
# Script: init_design.tcl.3nm_t.set_technology
##########################################################################################


## Set max routing layer
if {$MAX_ROUTING_LAYER != ""} {set_ignored_layers -max_routing_layer M$MAX_ROUTING_LAYER}
if {$MIN_ROUTING_LAYER != ""} {set_ignored_layers -min_routing_layer M$MIN_ROUTING_LAYER}

## Legalization
set_app_options -name place.legalize.pin_color_alignment_width_threshold_on_layers -value {{10.0 M0}} ;# foundry library specific
set_app_options -name place.legalize.avoid_backside_pins_under_preroute_layers 	-value true
set_app_options -name place.legalize.enable_variant_aware               	-value true
set_app_options -name place.legalize.enable_pin_access_vins_check 		-value true
#WA to avoid false One Neighbor End to End Spacing Violations 20221003
set_app_option -name place.legalize.ignore_base_layer_metal 			-value false

#To avoid Placement Failure Issue 20221121
set_app_option -name place.legalize.disable_drc_rules -value {{color_based_end_of_line_alignment M2}}
#To avoid false pin access violations of routed M1 pin, false pin access violations of cell internal M1 routing blockage 20240313
#set_app_options -name place.legalize.enable_native_mam_check_for_pin_access -value true

#23/02/2025 : from Leon (AE) to solve LGL-164 caused by erroneous PRF constraint for vertical abutment.
set_app_options -name place.legalize.disable_advanced_legalizer_rules -value "vert_abut"

## For PP.R.10 and CELL.NP.S.10.1.T 2021/01/29
## 03/03/2025 Roy: check if needed.
set_app_options -name place.legalize.enable_absolute_distance_spacing_rule -value true

## For antenna diode insertion
set_app_options -name route.detail.insert_diodes_during_routing -value true
set_app_options -name route.detail.diode_libcell_names -value ${ANTENNA_CELL_NAME}

##############################################################
### ICC2 setting
##############################################################
set_app_options -name shell.common.report_default_significant_digits    -value 3

##############################################################
### VT setting
##############################################################
#if {[info exists THRESHOLD_VOLTAGE_GROUP_TYPE_high_vt] && $THRESHOLD_VOLTAGE_GROUP_TYPE_high_vt != ""}     {set_threshold_voltage_group_type -type high_vt   $THRESHOLD_VOLTAGE_GROUP_TYPE_high_vt  }
#if {[info exists THRESHOLD_VOLTAGE_GROUP_TYPE_normal_vt] && $THRESHOLD_VOLTAGE_GROUP_TYPE_normal_vt != ""} {set_threshold_voltage_group_type -type normal_vt $THRESHOLD_VOLTAGE_GROUP_TYPE_normal_vt  }
#if {[info exists THRESHOLD_VOLTAGE_GROUP_TYPE_low_vt] && $THRESHOLD_VOLTAGE_GROUP_TYPE_low_vt != ""}       {set_threshold_voltage_group_type -type low_vt    $THRESHOLD_VOLTAGE_GROUP_TYPE_low_vt  }
foreach VT_GROUP [array name VT_GROUPS] {
	echo "VT_GROUP $VT_GROUP"
	set_attribute [get_lib_cells -quiet  $VT_GROUPS($VT_GROUP) ] threshold_voltage_group $VT_GROUP -quiet
	if {[lsearch $THRESHOLD_VOLTAGE_GROUP_TYPE_high_vt $VT_GROUP] >= 0}   { set_threshold_voltage_group_type -type high_vt $VT_GROUP ; echo "high_vt"}
	if {[lsearch $THRESHOLD_VOLTAGE_GROUP_TYPE_normal_vt $VT_GROUP] >= 0} { set_threshold_voltage_group_type -type normal_vt $VT_GROUP ; echo "normal_vt"}
	if {[lsearch $THRESHOLD_VOLTAGE_GROUP_TYPE_low_vt $VT_GROUP] >= 0}    { set_threshold_voltage_group_type -type low_vt $VT_GROUP ; echo "low_vt" }

}

set_multi_vth_constraint -low_vt_percentage $LVT_PERCENTAGE -cost area

if {$ENABLE_AUTO_MULTI_VT_CONSTRAINT} {
	auto_multi_vth_constraint -apply -percentage ${LVT_PERCENTAGE}
}
##############################################################
### compile setting
##############################################################
## 03/03/2025 Roy: check if needed. this is runtime in blocks without memories.
set_app_options -name compile.initial_drc.global_route_based -value true


set mbit_stages {true compile place cts route false}
if {[info exists MBIT] && [expr [lsearch $mbit_stages $MBIT] != -1] && [lsearch $mbit_stages $STAGE] >= [lsearch $mbit_stages $MBIT]} {
	set_app_options -name compile.flow.enable_multibit -value true
	set_app_options -name compile.flow.enable_second_pass_multibit_banking -value true
} 
##############################################################
### qor
##############################################################
set_app_options -name  cts.compile.primary_corner -value [get_attribute [get_scenarios $DEFAULT_CCOPT_VIEW] corner.name]

if {[info exists NO_AUTOUNGROUP] && $NO_AUTOUNGROUP == "true"} {
	set_app_options -name compile.flow.autoungroup  -value false
	## The following app option is required if auto ungroup is disabled during compile
	set_app_options -name opt.common.consider_port_direction -value true 
}

##############################################################
### OCV
##############################################################
if {[info exists OCV]} {
	if {$OCV == "pocv"} {
		set_app_options -name time.pocvm_enable_analysis 		-value true ;# tool default false; enables POCV
		reset_app_options time.aocvm_enable_analysis ;# reset it to prevent POCV being overriden by AOCV
		set_app_options -name time.ocvm_enable_distance_analysis 	-value true
		set_app_options -name time.enable_constraint_variation 		-value true
		set_app_options -name time.enable_slew_variation 		-value true
		set_app_options -name time.pocvm_precedence 			-value library
		set_app_options -name time.pocvm_corner_sigma 			-value 3
		set_app_options -name time.pocvm_enable_extended_moments 	-value false
		set_app_options -name time.pocvm_max_transition_sigma 		-value 3.0

	} elseif {$OCV == "flat"} {
		set_app_options -name time.pocvm_enable_analysis 		-value false ;# tool default false; enables POCV
	} else {
	}
}
##############################################################
### timing
##############################################################
set_app_options -name time.remove_clock_reconvergence_pessimism         -value true
set_app_options -name time.enable_clock_to_data_analysis                -value true
# this is part of SQS 
#set_app_options -name time.delay_calc_waveform_analysis_mode    	-value full_design

if {$STAGE == "route"} {
# this is part of SQS 
#	set_app_options -name time.si_enable_analysis 		 -value true 
	set_app_options -name time.enable_propagation_for_noise  -value true 
#	set_app_options -name route.global.crosstalk_driven 			-value true

}

set_app_options -name opt.port.eliminate_verilog_assign                 -value true
if {[info exists SCAN_DEF] && $SCAN_DEF == "true"} {
	set_app_options -name place.coarse.continue_on_missing_scandef  -value false
} else {
	set_app_options -name place.coarse.continue_on_missing_scandef 	-value true
}


set_app_options -name route.common.ignore_var_spacing_to_pg             -value true
# this is part of SQS 
#set_app_options -name route.global.timing_driven                        -value true
# this is part of SQS 
#set_app_options -name route.track.crosstalk_driven                      -value true
# this is part of SQS 
#set_app_options -name route.track.timing_driven                         -value true
# this is part of SQS 
#set_app_options -name route.detail.timing_driven                        -value true
## Crosstalk driven settings

set_app_options -name route.common.assert_mode                          -value warn
set_app_options -name route.common.derive_connect_within_pin_via_region -value true ;# tool default false, configure ICC2 to create appropriate via region based on pin width
set_app_options -name route.common.global_min_layer_mode 		-value allow_pin_connection
set_app_options -name route.common.net_min_layer_mode 			-value allow_pin_connection
set_app_options -name route.common.clock_net_min_layer_mode 		-value allow_pin_connection
set_app_options -name route.common.global_max_layer_mode 		-value hard

## Recommendation by Synopsys AE Merwin Antao in 2015 hidden option - to be reviewed
#30/01/2025 show worst congestion  result .
#        set_app_options -name route.global.pin_access_factor -value 9

#To check mask_constraints compatibility with respect to TF 20211224
#none option will not check, loose option will just give warning and strict option will give error
set_app_options -list {lib.setting.check_mask_constraints loose}
#Updated color prevention options to error out if collaterals dont match color 20220922
set_app_options -name file.def.check_mask_constraints -value loose
set_app_options -name file.gds.check_mask_constraints -value strict
set_app_options -name file.oasis.check_mask_constraints -value strict


#For Missing M2.CS.1.T Violations near M1 Must Joint pin access 20221123
set_app_options -list {route.auto_via_ladder.check_drcs_on_existing_via_ladders true}

#For Missing A.R.6/A.R.6.1/A.R.8:M18, A.R.7:VIA15/A.R.7:VIA16 DRC violation 20230503
#set_app_options -list {route.detail.propagate_antenna_property_for_intermediate_layers true}

#WA for floating must joint pins to be connected 20231017
set_app_options -name route.common.create_nets_for_floating_pins_pattern_must_join_via_ladder -value true

#set_app_options -name opt.common.user_instance_name_prefix -value $DST_BLOCK_NAME

# 23/02/2025 : from Leon (AE) to solve congestion 
set_app_options -name place.coarse.auto_density_control 		-value enhanced
set_app_options -name place.coarse.apply_eadc_to_initial_placement 	-value true
set_app_options -name place.coarse.target_routing_density 		-value 0.85
set_app_options -name place.coarse.enable_direct_congestion_mode 	-value true
set_app_options -name place.coarse.direct_congestion_version 	-value  2


#set_app_options -name place.coarse.max_density                    	-value 0.8
set_app_options -name place.coarse.pin_density_aware                    -value true
set_app_options -name place.coarse.enhanced_auto_density_control        -value true
set_app_options -name opt.common.max_fanout                             -value 32
# 03/03/2025 Leon do not agree to this.
#set_app_options -name opt.common.max_net_length 			-value 180


##############################################################
### effort setting
##############################################################
if {[info exists EFFORT_TIMING] && $EFFORT_TIMING == "low" } {
#	set_app_options -name  place_opt.place.congestion_effort       -value none
#	set_app_options -name  refine_opt.place.congestion_effort      -value none
#	set_app_options -name  compile.early_place.effort              -value low
#	set_app_options -name  compile.final_place.effort              -value low
#	set_app_options -name  opt.timing.effort                       -value low
	set ENABLE_ROUTE_OPT_PBA false
} elseif {[info exists EFFORT_TIMING] && $EFFORT_TIMING == "medium" }  {
#	set_app_options -name  place_opt.place.congestion_effort       -value medium
#	set_app_options -name  refine_opt.place.congestion_effort      -value medium
#	set_app_options -name  compile.early_place.effort              -value medium
#	set_app_options -name  compile.final_place.effort              -value medium
#	set_app_options -name  opt.timing.effort                       -value medium
	set ENABLE_ROUTE_OPT_PBA false
} elseif {[info exists EFFORT_TIMING] && $EFFORT_TIMING == "high" }  {
#	set_app_options -name  place_opt.place.congestion_effort       -value high
#	set_app_options -name  refine_opt.place.congestion_effort      -value high
#	set_app_options -name  compile.early_place.effort              -value high
#	set_app_options -name  compile.final_place.effort              -value high
#	set_app_options -name  opt.timing.effort                       -value high
#	set_app_options -name  cts.compile.cg_timing_aware             -value true
#	set_app_options -name  cts.icg.timing_aware                    -value true
	set_app_options -name place_opt.final_place.effort 	-value high
	set_app_options -name opt.timing.effort 		-value high
	set ENABLE_ROUTE_OPT_PBA true
	if {$STAGE == "route"} {set_app_options -list {time.pba_optimization_mode path} }	
	
} elseif {[info exists EFFORT_TIMING] && $EFFORT_TIMING == "extreme" }  {
#	set_app_options -name  place_opt.place.congestion_effort       -value high
#	set_app_options -name  refine_opt.place.congestion_effort      -value high
#	set_app_options -name  compile.early_place.effort              -value high
#	set_app_options -name  compile.final_place.effort              -value high
#	set_app_options -name  opt.timing.effort                       -value high
#	set_app_options -name  compile.flow.high_effort_timing         -value 1
#	set_app_options -name  cts.compile.cg_timing_aware             -value true
#	set_app_options -name  cts.icg.timing_aware                    -value true
#	set_app_option -list {place_opt.place.congestion_effort ultra}
#	set_app_option -list {compile.place.congestion_effort ultra}
	set_app_options -name place_opt.final_place.effort 	-value high
	set_app_options -name opt.timing.effort 		-value high
	set_app_options -name opt.area.effort 			-value high
	if {$STAGE == "route"} {set_app_options -list {time.pba_optimization_mode path} }	

	set ENABLE_ROUTE_OPT_PBA true
} else {
	set ENABLE_ROUTE_OPT_PBA false
}



#set_app_options -name place.coarse.wide_cell_use_model 	-value true
#set_app_options -name place.common.use_placement_model 	-value true
set_app_options -name place.common.enable_cellmap_advanced_rules 	-value true

set_app_options -name place.coarse.pin_density_control_effort  -value medium

########################################################################
## dont use
########################################################################
source -e -v scripts/flow/dont_use_n_ideal_network.tcl


if {[info exists CTS_CREATE_SHIELDS] && $CTS_CREATE_SHIELDS} {
	set_app_options -list {route.common.reshield_modified_nets reshield}
}

##############################################################
### useful skew setting
##############################################################

# LeonR set_app_option -list {route_opt.flow.enable_ccd false}
set_app_options -name ccd.adjust_io_clock_latency 	-value false
set_app_options -name  ccd.optimize_boundary_timing  	-value false

set_app_options -name  ccd.max_postpone              	-value 0.05
set_app_options -name  ccd.max_prepone               	-value 0.05
#set_app_options -name place_opt.flow.estimate_clock_gate_latency 	-value false
#set_app_options -name refine_opt.flow.estimate_clock_gate_latency 	-value false
#set_app_options -name opt.common.estimate_clock_gate_latency 		-value false
set_app_options -name route_opt.flow.enable_ccd  -value false

#if {$STAGE != "init"} {set_app_options -name  ccd.reference_corner          	-value func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup     }

if {![info exists USEFUL_SKEW] || $USEFUL_SKEW == "false"}  {
	set_app_options -name compile.flow.enable_ccd    -value false
	set_app_options -name place_opt.flow.enable_ccd  -value false
	set_app_options -name clock_opt.flow.enable_ccd  -value false
#	set_app_option -list {route_opt.flow.enable_ccd false}
} else {
	if {$USEFUL_SKEW == "cts"} {
		set_app_options -name compile.flow.enable_ccd   -value false
		set_app_options -name place_opt.flow.enable_ccd -value false
	} else {
		set_app_options -name compile.flow.enable_ccd   -value true
		set_app_options -name place_opt.flow.enable_ccd -value true
	}
	set_app_options -name  clock_opt.flow.enable_ccd  	-value true

	set_app_options -name  ccd.hold_control_effort 		-value medium ; # options are none / low / medium / high / ultra
	set_app_options -name  ccd.ignore_scan_reset_for_boundary_identification  -value true
	
	if {$STAGE != "init"} { 
		set_app_options -name  ccd.reference_corner          -value [get_attribute [get_scenarios ${DEFAULT_CCOPT_VIEW}*] corner.name]  
	}
	
}

# allow to split ICG.
set_app_options -list {place_opt.flow.enable_timing_driven_clock_gate_split true}

# 03/07/2025 royl:  this causing a lot of timing issues to ICG + duplicate too many ICG
#set_app_options -list {compile.clockgate.physically_aware true}

##############################################################
### set_lib_cell_purpose
##############################################################
# tie  cells usage
set_lib_cell_purpose -include optimization [get_lib_cells [concat $TIEHCELL $TIELCELL]]

## Hold time fixing cells 
set_lib_cell_purpose -exclude hold [get_lib_cells */*]
set_lib_cell_purpose -include hold [get_lib_cells $HOLD_FIX_CELLS_LIST]

## CTS cells (non-exclusive) 

set_lib_cell_purpose -exclude cts [get_lib_cells */*]
set_lib_cell_purpose -include none [get_lib_cells [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]]
set_lib_cell_purpose -include cts [get_lib_cells [concat $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]]
set_lib_cell_purpose -include cts [get_lib_cells -filter "is_sequential&&valid_purposes=~*optimization*"]


set_clock_gating_options -minimum_bitwidth 3 -max_fanout 32
set_clock_gate_style -test_point before 



##############################################################
### change name rules
##############################################################
  define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
  define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
  define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port

  define_name_rules scip -first_restricted {0-9 _}

##############################################################
### clock routing rule
##############################################################
set_clock_routing_rules -net_type root     -max_routing_layer M$MAX_ROUTING_LAYER -min_routing_layer M[expr $MAX_ROUTING_LAYER -1] -rules NDR_A__m78910111213_p076_SHLD
set_clock_routing_rules -net_type internal -max_routing_layer M[expr $MAX_ROUTING_LAYER -2] -min_routing_layer M12 -rules NDR_A__m78910111213_p076_SHLD
set_clock_routing_rules -net_type sink     -max_routing_layer M12 -min_routing_layer M7 -rules NDR_A__m78910111213_p076

##############################################################
# clock additional setting
##############################################################
#set_app_options -name time.enable_ccs_rcv_cap                   -value true
set_app_options -name cts.common.max_fanout                     -value 32
set_clock_tree_options -root_ndr_fanout_limit 4096

##############################################################
# route additional setting
##############################################################
# 03/03/2025 Roy: need to check this
#set_app_options -name route.global.effort_level                         -value high
# 03/03/2025 Roy: need to check this
#set_app_options -name route.global.advance_node_timing_driven_effort    -value high
set_extraction_options  \
			-corners [all_corners] \
			-include_pin_resistance true 
			
	
foreach_in_collection ccc [all_corners] {
	set ccc_name [get_object_name $ccc]
	if {$ccc_name == "default"} {continue }
	regexp {(.*[SF])_(.*)_(\d+)_\d} $ccc_name match pvt rc temp
	set_extraction_options -corners $ccc_name -late_ccap_threshold [lindex $rc_corner($rc,ccap_threshold) 0 1] -early_ccap_threshold [lindex $rc_corner($rc,ccap_threshold) 0 0]
}
			
if {$STAGE == "route" } {
	set_app_options -name extract.enable_coupling_cap 			-value true
	
	if { [regexp "tsmcn3|brcm3|nxt013" $PROJECT] } {
		set_extraction_options \
			-corners [all_corners] \
			-virtual_shield_extraction false \
			-real_metalfill_extraction floating 
		
	}
}

########################################################################################## 
## chip finish
##########################################################################################
set_app_options -name chf.create_stdcell_fillers.follow_orders -value 1
set_app_option -name signoff.physical.rename_cell_files -value $CELLNAME_MAP_FILES

##############################################################
# add spacing near each FF / ICG
##############################################################
#################################################################################################
# LeonR
remove_placement_spacing_rules -all
set_app_options -name place.legalize.one_access_point_on_via23_track -val true
set_app_options -list {route.common.connect_within_pins_by_layer_name {{M0 off}}}
set_app_options -list {route.common.min_max_layer_distance_threshold 2.5}



# These 2 specific options are provided by R&D for BRCM library. They require the 23.12-SP5-5 version
# TBD: when version is installed
set_app_options -name route.common.enable_zroute_improvements -value 2

set_app_options -name route_opt.flow.timing_closure_enhancements -value true

########################################################################################## 
## Message handling
##########################################################################################
suppress_message ATTR-11 ;# suppress the information about that design specific attribute values override over library values
## set_message_info -id ATTR-11 -limit 1 ;# limit the message normally printed during report_lib_cells to just 1 occurence
set_message_info -id PVT-012 -limit 1
set_message_info -id PVT-013 -limit 1
puts "RM-info: Hostname: [sh hostname]"; puts "RM-info: Date: [date]"; puts "RM-info: PID: [pid]"; puts "RM-info: PWD: [pwd]"

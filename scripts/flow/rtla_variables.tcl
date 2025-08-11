#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
#set search_path [list ./rm_setup ./rm_fc_scripts ./rm_tech_scripts ./rm_user_plugin_scripts]
lappend search_path .

set_host_options -max_cores $CPU


   ## Enable on-disk operation for copy_block to save block to disk right away
   #  set_app_options -name design.on_disk_operation -value true ;# default false and global-scoped


set sh_continue_on_error false

# Controls HDLC naming style settings to make it easier to apply
# the same UPF file across multiple tools at the RTL level
if {$ENABLE_UPF} {
	puts "-I- running in UPF mode"
	# Controls HDLC naming style settings to make it easier to apply; the same UPF file across multiple tools at the RTL level
	set_app_options -name hdlin.naming.upf_compatible 	  -value true
	set_app_options -name hdlin.naming.sverilog_union_member  -value true
}	

# set_app_options -name hdlin.elaborate.ff_infer_async_set_reset -value true
# set_app_options -name hdlin.elaborate.ff_infer_sync_set_reset  -value false



set_app_options -list {flow.runtime.version "ERI-20230820"}
enable_runtime_improvements

# Memory blockages zero_spacing setting
set macros [get_flat_cells -filter "design_type==macro"]
if {[sizeof_collection $macros]} {
       set_attribute [get_routing_blockages -of $macros] is_zero_spacing true
}

set_app_options -list {design.enable_rule_based_query true}

################################################################
## Technology & settings  
################################################################
if { [regexp "tsmcn3|brcm3|nxt013" $PROJECT] } {
    set TECHNOLOGY_NODE 3e
} elseif { [regexp "brcm5|nxt009|inext" $PROJECT] } {
    set TECHNOLOGY_NODE 5
}
if {[info exists TECHNOLOGY_NODE] && $TECHNOLOGY_NODE != ""} {
	redirect -file reports/init/set_technology {set_technology -node $TECHNOLOGY_NODE -report_only}
	set_technology -node $TECHNOLOGY_NODE
}

report_app_options -non_default

## Assure unique module names including hierarchical integration. Must run before physical constraints applied for MV designs
set_app_option -name design.uniquify_naming_style -value ${DESIGN_NAME}_%s_%d


## Routing
set_app_options -name route.common.derive_connect_within_pin_via_region -value true ;# tool default false, configure ICC2 to create appropriate via region based on pin width

##########################################################################################
# Script: init_design.tcl.3nm_t.set_technology
##########################################################################################

## Set max routing layer
if {$MAX_ROUTING_LAYER != ""} {set_ignored_layers -max_routing_layer M$MAX_ROUTING_LAYER}
if {$MIN_ROUTING_LAYER != ""} {set_ignored_layers -min_routing_layer M$MIN_ROUTING_LAYER}

## Legalization
set_app_options -name place.legalize.pin_color_alignment_width_threshold_on_layers -value {{10.0 M0}} ;# foundry library specific

## For PP.R.10 and CELL.NP.S.10.1.T 2021/01/29
set_app_options -name place.legalize.enable_absolute_distance_spacing_rule -value true

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


if {$ENABLE_AUTO_MULTI_VT_CONSTRAINT} {
	puts "-I- auto multi VT constraint"
	auto_multi_vth_constraint -apply -percentage ${LVT_PERCENTAGE}
}

##############################################################
### qor
##############################################################
#set_app_options -name cts.compile.primary_corner -value $DEFAULT_CCOPT_VIEW

if {[info exists NO_AUTOUNGROUP] && $NO_AUTOUNGROUP == "true"} {
	set_app_options -name rtl_opt.conditioning.disable_boundary_optimization_and_auto_ungrouping -value true 
##MPR dont know this
	## The following app option is required if auto ungroup is disabled during compile
	set_app_options -name opt.common.consider_port_direction -value true 
}

##############################################################
### OCV
##############################################################
if {[info exists OCV]} {
	if {$OCV == "pocv"} {
		set_app_options -name time.pocvm_enable_analysis -value true ;# tool default false; enables POCV
		reset_app_options time.aocvm_enable_analysis ;# reset it to prevent POCV being overriden by AOCV
		set_app_options -name time.ocvm_enable_distance_analysis -value true
		set_app_options -name time.enable_constraint_variation -value true
		set_app_options -name time.enable_slew_variation -value true
		set_app_options -name time.pocvm_precedence -value library
		set_app_options -name time.pocvm_corner_sigma -value 3
		set_app_options -name time.pocvm_enable_extended_moments -value false
		set_app_options -name time.pocvm_max_transition_sigma -value 3.0

	} elseif {$OCV == "flat"} {
	} else {
	}
}
##############################################################
### timing
##############################################################
set_app_options -name time.enable_clock_to_data_analysis                -value true

set_app_options -name opt.port.eliminate_verilog_assign                 -value true
set_app_options -name place.coarse.continue_on_missing_scandef          -value true

#MPRset_app_options -name place.legalize.enable_variant_aware               -value true

set_app_options -name route.common.ignore_var_spacing_to_pg             -value true
set_app_options -name route.global.timing_driven                        -value true

set_app_options -name route.common.assert_mode                          -value warn

#To check mask_constraints compatibility with respect to TF 20211224
#none option will not check, loose option will just give warning and strict option will give error
set_app_options -list {lib.setting.check_mask_constraints loose}
#Updated color prevention options to error out if collaterals dont match color 20220922
set_app_options -name file.def.check_mask_constraints -value loose
set_app_options -name file.gds.check_mask_constraints -value strict
set_app_options -name file.oasis.check_mask_constraints -value strict
#set_app_options -name place.legalize.enable_pin_access_vins_check -value true
	set_app_options -name place.legalize.enable_pin_access_vins_check -value true

#WA to avoid false One Neighbor End to End Spacing Violations 20221003
set_app_option -name place.legalize.ignore_base_layer_metal -value false

#To avoid Placement Failure Issue 20221121
set_app_option -name place.legalize.disable_drc_rules -value {{color_based_end_of_line_alignment M2}}

#For Missing M2.CS.1.T Violations near M1 Must Joint pin access 20221123
set_app_options -list {route.auto_via_ladder.check_drcs_on_existing_via_ladders true}

#For Missing A.R.6/A.R.6.1/A.R.8:M18, A.R.7:VIA15/A.R.7:VIA16 DRC violation 20230503
#set_app_options -list {route.detail.propagate_antenna_property_for_intermediate_layers true}

#WA for floating must joint pins to be connected 20231017
set_app_options -name route.common.create_nets_for_floating_pins_pattern_must_join_via_ladder -value true

#To avoid false pin access violations of routed M1 pin, false pin access violations of cell internal M1 routing blockage 20240313
#set_app_options -name place.legalize.enable_native_mam_check_for_pin_access -value true

#set_app_options -name opt.common.user_instance_name_prefix -value $DST_BLOCK_NAME

	set_app_options -name place.coarse.pin_density_aware                    -value true
	set_app_options -name place.coarse.enhanced_auto_density_control        -value true
	set_app_options -name opt.common.max_fanout                             -value 30


set_app_option -name opt.common.estimate_clock_gate_latency -value false

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


set_app_options -name place.coarse.pin_density_control_effort  -value medium
set_app_options -name opt.common.max_net_length -value 180




########################################################################
## dont use
########################################################################
#MPR see file
source -e -v scripts/flow/dont_use_n_ideal_network.tcl




##############################################################
### useful skew setting
##############################################################

if {![info exists USEFUL_SKEW] || ${USEFUL_SKEW} == "false"}  {
	set_app_options -name compile.flow.enable_ccd    -value false
}
if {[info exists USEFUL_SKEW_MAX_PREPONE]}  {
	set_app_options -name ccd.max_prepone    -value ${USEFUL_SKEW_MAX_PREPONE}
}
if {[info exists USEFUL_SKEW_MAX_POSTPONE]}  {
	set_app_options -name ccd.max_postpone    -value ${USEFUL_SKEW_MAX_POSTPONE}
}

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


set_clock_gating_options -minimum_bitwidth 8 -max_fanout 32
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
set_clock_routing_rules -net_type internal -max_routing_layer M$MAX_ROUTING_LAYER -min_routing_layer M[expr $MAX_ROUTING_LAYER -1] -rules NDR_A__m78910111213_p076_SHLD
set_clock_routing_rules -net_type sink     -max_routing_layer M$MAX_ROUTING_LAYER -min_routing_layer M7 -rules NDR_A__m78910111213_p076



########################################################################################## 
## Message handling
##########################################################################################
suppress_message ATTR-11 ;# suppress the information about that design specific attribute values override over library values
## set_message_info -id ATTR-11 -limit 1 ;# limit the message normally printed during report_lib_cells to just 1 occurence
set_message_info -id PVT-012 -limit 1
set_message_info -id PVT-013 -limit 1
puts "RM-info: Hostname: [sh hostname]"; puts "RM-info: Date: [date]"; puts "RM-info: PID: [pid]"; puts "RM-info: PWD: [pwd]"

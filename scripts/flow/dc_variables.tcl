#
#   <HN> 27.08.2023 -    added 3 significant bits as default
#

   set_host_options -max_cores $CPU

   define_design_lib WORK -path ./WORK
###The following variable helps verification when there are differences between DC and FM while inferring logical hierarchies 
set_app_var hdlin_enable_hier_map true
set_app_var timing_enable_multiple_clocks_per_reg true
set timing_use_enhanced_capacitance_modeling true

  # Change alib_library_analysis_path to point to a central cache of analyzed libraries
  # to save runtime and disk space.  The following setting only reflects the
  # default value and should be changed to a central location for best results.

  set_app_var alib_library_analysis_path .

  # In cases where RTL has VHDL generate loops or SystemVerilog structs, switching 
  # activity annotation from SAIF may be rejected, the following variable setting 
  # improves SAIF annotation, by making sure that synthesis object names follow same 
  # naming convention as used by RTL simulation. 

  set_app_var hdlin_enable_upf_compatible_naming true

  # By default, the tool uses  simple  names  for  elements  inferred  from
  # unions in SystemVerilog. Setting this variable to true enables the tool
  # to use the name of the first union member as a reference for the  port,
  # net, and cell names associated with the union data type.

  set_app_var hdlin_sv_union_member_naming true
  if {[info exists DW_POWER] && $DW_POWER == "true"} {
     set_app_var synthetic_library {standard.sldb dw_foundation.sldb dw_minpower.sldb};
     set power_enable_minpower true ;  
  } else {
     set_app_var synthetic_library "standard.sldb  dw_foundation.sldb"
  }
  
  if {$MBIT == "true" } {
  	set_app_var hdlin_infer_multibit default_all
  } else {
  	set_app_var hdlin_infer_multibit never
  }
  
# Enable the support of via resistance for RC estimation to improve the timing 
# correlation with IC Compiler
set_app_var spg_enable_via_resistance_support true

set_app_var link_allow_physical_variant_cells true
set_app_var hdlin_enable_upf_compatible_naming true ;



  set enable_recovery_removal_arcs false
  set compile_seqmap_identify_shift_registers false
  set write_name_nets_same_as_ports true
  set synlib_enable_analyze_dw_power 1
  set hdlin_reporting_level comprehensive
  set compile_fix_multiple_port_nets true
  set compile_timing_high_effort_tns true

  set_app_var compile_ultra_ungroup_dw true ;
  set compile_ultra_ungroup_small_hierarchies true


###################################################################
###             change names setting
###################################################################

set hdlin_shorten_long_module_name true
set hdlin_module_name_limit 192
set change_names_dont_change_bus_members true
define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port

define_name_rules scip -first_restricted {0-9 _}
#define_name_rules scip -last_restricted  {_}
###################################################################
###             power setting
###################################################################
set power_cg_derive_related_clock true
set power_do_not_size_icg_cells true
set case_analysis_propagate_through_icg true



if {[shell_is_dcnxt_shell] && [shell_is_in_topographical_mode]} {
	set_app_var power_cg_physically_aware_cg true
	
	set_app_var compile_enhanced_tns_optimization true
	set_app_var placer_max_cell_density_threshold 0.75        
	set_app_var compile_register_replication_across_hierarchy true 
	
	set_app_var placer_enable_enhanced_router true
	set_app_var placer_congestion_effort medium
	set_app_var compile_timing_high_effort true 
	set spg_congestion_placement_in_incremental_compile true

	set placer_soft_keepout_channel_width 10

       # With the following variables set, Zroute-based congestion-driven placement is enabled
       # instead of virtual route based estimation. 
       # Enabling this feature may have runtime impact. Enable this for highly congested designs
       # set_app_var placer_congestion_effort medium
       # set_app_var placer_enable_enhanced_router true
}


if {[info exists REMOVE_FLOPS ] && $REMOVE_FLOPS == "false" } {
	set compile_delete_unloaded_sequential_cells false
	set compile_seqmap_propagate_high_effort false
	set compile_seqmap_propagate_constants false
	set compile_enable_constant_propagation_with_no_boundary_opt false
#	set_app_var compile_delete_unloaded_sequential_cells false
#	set_app_var compile_seqmap_propagate_constants false
#	set_app_var compile_seqmap_propagate_constant_clocks false
} else {
	set compile_delete_unloaded_sequential_cells true
	set compile_seqmap_propagate_high_effort true
	set compile_seqmap_propagate_constants true
	set compile_enable_constant_propagation_with_no_boundary_opt true
}

# Set default significant digits
set report_default_significant_digits 3


if {$DESIGN_NAME == "grid_node_top"}  { 
	##power optimization		
	set_compile_power_high_effort -total TRUE		
		
	##next option		
	set_dynamic_optimization true		
	set_app_var power_low_power_placement true	
}


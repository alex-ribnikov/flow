
if { [info exists $PROJECT] } {
	set proj $PROJECT
} else {
    set proj [lindex [split [pwd] "/"] end-3]
}

if { ![is_attribute -obj root be_project] } {
    define_attribute be_project -obj_type root -category be_user_attributes -data_type string -default $PROJECT
} else {
    set_db be_project $PROJECT
}

if { [regexp "snpsn5|tsmcn5|inext|brcm5|nextcore|nxt080|nxt013" $PROJECT] } {
	set_db design_process_node 5
	set_db route_design_process_node N5
} elseif { [regexp "tsmcn4" $PROJECT] } {
	set_db design_process_node 4
	set_db route_design_process_node N4
} elseif { [regexp "smsng4" $PROJECT] } {
	set_db design_process_node 4
	set_db route_design_process_node S4
} elseif { [regexp "brcm3" $PROJECT] } {
	set_db design_process_node 3
	set_db route_design_process_node N3
} elseif { [regexp "tsmcn3" $PROJECT] } {
	set_db design_process_node 3
	set_db route_design_process_node N3
} elseif { [regexp "snpsn7|tsmcn7|nxt007|brcm7|nxt008" $PROJECT] } {
	set_db design_process_node 7
	set_db route_design_process_node N7
} else {
    puts "-E- syn_variables: No valid project found!"
    exit
}


if {![info exists WLM] || $WLM == "false"} {
    if { [info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER != "" } {
   	set_db number_of_routing_layers $MAX_ROUTING_LAYER
    }

}

##### elaborate attributes
#set_db hdl_preserve_unused_registers false ;					# Default : false

##### synthesis attributes
if { [info exists REMOVE_FLOPS] && $REMOVE_FLOPS == "false" } {
   puts "-I- Syn will not remove flops"
   set_db delete_unloaded_insts       false ;					# Default : true
   set_db delete_unloaded_seqs        false ;					# Default : true
   set_db optimize_constant_0_flops   false ;					# Default : true
   set_db optimize_constant_1_flops   false ;					# Default : true
} else {
   set_db delete_unloaded_insts       true ;					# Default : true
   set_db delete_unloaded_seqs        true ;					# Default : true
   set_db optimize_constant_0_flops   true ;					# Default : true
   set_db optimize_constant_1_flops   true ;					# Default : true
}
set_db optimize_constant_latches   false ;					# Default : true
set_db optimize_merge_flops        false ;					# Default : true
set_db optimize_merge_latches      false ;					# Default : true
set_db tns_opto                    true  ;					# Default : true
#set_db drc_first                   false ;					# Default : false


##### pasted: -rwxrwxrwx 1 jeromem ns 3007 Sep 28 14:56 /space/users/moriya/nextflow/project_flow/NXT007/controls/GENUS.setup.paste
include load_etc.tcl

set_db source_verbose true ;					# Default : true
set_db information_level 5 ;					# Default : 1
set_db gen_module_prefix RC_DP_ ;				# Default : RC_DP_
set_db inst_prefix RC_i_ ;					# Default : g

set_db auto_ungroup none ;					# Default : both
set_db optimize_seq_x_to 0 ;					# Default : 0
# set_db iopt_sequential_duplication false ; 			# Default : false
# set_db use_tiehilo_for_const unique ;				# Default : none

# refine mapper targets in a 2nd iteration
set_db ultra_global_mapping true ;	 			# Default : false

set_db gen_module_prefix xx ;			 		# Default : ""
set_db time_recovery_arcs true ;	 			# Default : false

set_db case_analysis_sequential_propagation true ; 		# Default : false


#------------------------------------------------------------------------------
# HDL attributes
#------------------------------------------------------------------------------
#set_db hdl_max_loop_limit 1024 ;				# Default : 1024
if { ![info exists ERROR_ON_BLACKBOX] || $ERROR_ON_BLACKBOX == true } { 
  set_db hdl_error_on_blackbox true  ;				# Default : false
} else {
  set_db hdl_error_on_blackbox false ;				# Default : false
}
#set_db hdl_error_on_latch true ;				# Default : false
set_db hdl_unconnected_value none ;				# Default : 0
#set_db hdl_infer_unresolved_from_logic_abstract false ;		# Default : true - will be obsolete
set_db hdl_array_naming_style %s_%d_ ;				# Default : %s[%d]
set_db hdl_reg_naming_style %s_reg%s ;				# Default : %s_reg%s
set_db hdl_generate_index_style %s_%d_  ;			# Default : %s[%d]
set_db hdl_generate_separator _ ;				# Default : .
set_db hdl_parameter_naming_style _%d_ ; 			# Default : _%s%d
#set_db hdl_bus_wire_naming_style %s_\[%d\]
#set_db bus_naming_style %s_\[%d\] 
#set_db hdl_record_naming_style %s_%s

set_db hdl_use_cw_first true ;					# Default : false 
set_db hdl_flatten_complex_port false ; 			# Default : false
set_db hdl_resolve_instance_with_libcell true ;	 		# Default : false
#set_db hdl_sv_module_wrapper true
set_db / .hdl_track_filename_row_col true ;	 		# Default : false

if { [regexp "brcm3" $PROJECT] } {
   ::legacy::set_attr short_cell_height $SHORT_CELL_HEIGHT
   ::legacy::set_attr tall_cell_height $TALL_CELL_HEIGHT
   set SHORT_TALL_HEIGHT_AVG [format %.3f [expr [expr $SHORT_CELL_HEIGHT + $TALL_CELL_HEIGHT] / 2]]
   ::legacy::set_attr hum_n3_row_height                  $SHORT_TALL_HEIGHT_AVG /
   
   set FIRST_VERT_PITCH [::legacy::get_attr pitch [lindex [::legacy::filter direction vertical [::legacy::find / -layer *]] 0]]
   set SITE_SIZE [format %.3f [expr $SHORT_TALL_HEIGHT_AVG + $FIRST_VERT_PITCH]]
   ::legacy::set_attribute force_site_size           $SITE_SIZE ;# (average of short/tall cell height + the first vertical pitch value) = 0.143 + 0.030
   
   if {[info exists IS_PHYSICAL] && $IS_PHYSICAL == "true" || [info exists IS_HYBRID] && $IS_HYBRID == "true" } {
        ::legacy::set_attr enable_strict_percent_control   1 /
        apply_short_tall_control
   }

   
} else {
}

#------------------------------------------------------------------------------
# Write attributes
#------------------------------------------------------------------------------
#set_db write_sdc_exclude {set_timing_derate group_path} ;       # Default : {}
set_db write_vlog_empty_module_for_logic_abstract false  ;	# Default : true
set_db remove_assigns true

# Controls the preciseness of the line numbers reported in the messages for failing SDC commands when reading in an SDC file.
set_db detailed_sdc_messages true

#------------------------------------------------------------------------------
# DFT attributes
#------------------------------------------------------------------------------
set_db dft_auto_identify_shift_register false ;			# Default : false

set_db dft_include_test_signal_outputs_in_abstract_model false ;# Default : true
# Waiting to get clear DFT strategy. WA for mixed edges in scan segments.
#set_db [current_design] .dft_mix_clock_edges_in_scan_chain true ; # Default : false

##### Avoid using internal scan mux 
set_db use_scan_seqs_for_non_dft degenerated_only

#------------------------------------------------------------------------------
# Power attributes
#------------------------------------------------------------------------------
set_db lp_power_unit mW ;					# Default : nW
#set_db [current_design] .max_dynamic_power 100 ;               # Default : no_value
#set_db designs lp_power_optimization_weight 0.5 ;	        # Default : no_value
#set_db lp_insert_clock_gating               true  ; 	# moved to setup.tcl file
#set_db [get_db designs] .lp_clock_gating_max_flops 48
#set_db designs .lp_clock_gating_max_flops 48 ;			# Default : inf
#set_db designs .lp_clock_gating_auto_path_adjust variable ;	# Default : none
set_db leakage_power_effort none ;				# Default : none

#------------------------------------------------------------------------------
# LEC attributes
#------------------------------------------------------------------------------
set_db wlec_set_cdn_synth_root true ;	 			# Default : false
set_db wlec_parallel_threads 4  ;	 			# Default : 4
#set_db current_design .verification_directory out/fv    	; # Default : fv/<design_name>
set_db verification_directory out/fv    	; # Default : fv/<design_name>


#------------------------------------------------------------------------------
# Physical options
#------------------------------------------------------------------------------
if {[regexp {20.1} [get_db program_version]]} {
	set_db limited_access_feature {{ syn_opt_ispatial_restricted_features 775213404 }}
} elseif {[regexp {19.} [get_db program_version]]} {
	set_db limited_access_feature               [list {syn_opt_ispatial 329570052} \
                                                      {syn_opt_ispatial_unqualified 566479620} \
                                                      {syn_opt_ispatial_sc 380398200} \
                                                ]
} else {

}


#------------------------------------------------------------------------------
# OPT attributes
#------------------------------------------------------------------------------
#set opt_spaitiom_restructeting  true
#set_db iopt_sequential_duplication false ; 			# Default : false

# Controls whether to use useful-skew optimization within Innovus for opt_spatial_effort extreme.
if {[info exists USEFUL_SKEW] && $USEFUL_SKEW=="true" } {
   set_db opt_spatial_useful_skew true	;			# Default : true 
   set_db opt_spatial_early_clock true ;                        # Default : false 
} else {
   set_db opt_spatial_useful_skew false	;			# Default : true 
}
#set_db lib_lef_consistency_check_enable true ;	 		# Default : true 
set_db find_fuzzy_match true ;                                  # Default : false
set_db read_def_libcell_mismatch_error false ;                  # Default : true
set_db congestion_effort high ;	 			# Default : off 

if {[info exists PYISICAL_SYN] && $PYISICAL_SYN == "true"} {

   set_db phys_checkout_innovus_license        true
   if {[file exists scripts_local/setup.tcl]} {
	puts "-I- passing to innovus setup file from scripts_local"
	set_db invs_preload_script ./scripts_local/setup.tcl
   } else {
	puts "-I- passing to innovus setup file from scripts"
	set_db invs_preload_script ./scripts/setup.${::env(PROJECT)}.tcl 
   }

   if {[file exists scripts_local/INN_variables.tcl]} {
	puts "-I- passing to innovus post setup file from scripts_local"
   	set_db invs_postload_script ./scripts_local/INN_variables.tcl
   } else {
	puts "-I- passing to innovus post setup file from scripts"
    	set_db invs_postload_script ./scripts/flow/INN_variables.tcl
   }
	

   #Via pillar
   #set_db phys_enable_stack_via true
}
###########################################################
# Options accepted by Genus but not fully transmitted to Innovus
# Reloaded through Innovus postload
###########################################################

#------------------------------------------------------------------------------
# Flow
#------------------------------------------------------------------------------
set_db design_flow_effort extreme ;				# Default : standard
#set_db design_early_clock_flow true ;				# Default : false
if {$POWER_EFFORT != "none"} {
    set_db design_power_effort $POWER_EFFORT
    set_db opt_leakage_to_dynamic_ratio 0.0 ;		# Default : 1 , full leakage opt.
}


#------------------------------------------------------------------------------
# Timing
#------------------------------------------------------------------------------
set_db timing_report_fields {timing_point cell edge fanout load transition total_derate delay arrival pin_location flags}
set_db timing_analysis_cppr both ;				# Default : none
if {![regexp {22.1} [get_db program_version]]} {
#	set_db timing_case_analysis_for_icg_propagation always ;	# Default : false
}
set_db time_recovery_arcs true ;	 			# Default : false
set_db case_analysis_sequential_propagation true ; 		# Default : true

#------------------------------------------------------------------------------
# multi bit
#------------------------------------------------------------------------------
if {![info exists MBIT] || $MBIT == "true"} {
	set_db use_multibit_cells true ;                                # Default : false
	set_db multibit_prefix_string  ""    ; # Avoid SDC errors (with CDN_MB prefix)
	#set_db physical_aware_multibit_mapping auto 
    set_db multibit_allow_unused_bits false ; # Default true - hurts lec
}
#------------------------------------------------------------------------------
# Physical optimisation
#------------------------------------------------------------------------------
set_db opt_fix_fanout_load true ;				# Default : false
set_db opt_drv_margin 0.05 ;					# Default : 0.0
set_db opt_max_length 150 ;					# Default : -1
set_db opt_all_end_points true ;				# Default : false
set_db opt_enable_data_to_data_checks true ;			# Default : false
set_db opt_multi_bit_flop_opt true ;				# Default : false
set_db opt_useful_skew_no_boundary true ;			# Default : false
set_db read_def_fuzzy_name_match true

#------------------------------------------------------------------------------
# Placement
#------------------------------------------------------------------------------
set_db place_global_clock_gate_aware true ;			
set_db place_detail_use_no_diffusion_one_site_filler true ;	# Default : false
set_db place_global_module_aware_spare true ;		        # Default : false
set_db place_global_ignore_spare true ;		                # Default : false



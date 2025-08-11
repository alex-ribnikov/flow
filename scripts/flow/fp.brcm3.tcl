if {$FE_MODE && ![file exists ./scripts_local/user_manual_fp.tcl]} {
	set_auto_floorplan_constraints \
		-core_utilization 0.5 \
		-row_pattern H117_H169 \
		-track_script ./scripts/layout/N3E-track-icc2.tcl
	set_block_pin_constraints -self -allowed_layers {M6 M7 M8 M9 M10 M11 M12 M13 M14} -pin_spacing 1
} else {
	set env(ICPROCESS) cln03
	set env(INQA_ROOT) /project/foundry/TSMC/N3/BRCM/PDK//20250416/inqa/
	source ./scripts/bin/inqa/setup.tcl

	if {$MANUAL_FP == "true" || $INTERACTIVE == "true" || $WIN == "true" || $OPEN != "None"} {
		set cmd_out "return 1" 
	} else {
		set cmd_out "exit 0" 
	}
	#set cmd_out [expr { $MANUAL_FP||$INTERACTIVE||$WIN||([string compare $OPEN None]) ? "return" : "exit 0"}]	 

	set xMul 31.92
	set yMul 10.868
	set boundary_offset_x 0.024
	set boundary_offset_y 0.0845



	set ROUTING_LAYER_DIRECTION_OFFSET_LIST {{M0 horizontal 0.0839} {M1 vertical -0.006} {M2 horizontal 0.104} {M3 vertical 0.0}
										 {M4 horizontal 0} {M5 vertical 0.0} {M6 horizontal 0.038} {M7 vertical 0.038}
										 {M8 horizontal 0.038} {M9 vertical 0.038} {M10 horizontal 0.038} {M11 vertical 0.038}
										 {M12 horizontal 0.038} {M13 vertical 0.038} {M14 horizontal 0} {M15 vertical 0}
										 {M16 horizontal 0} {M17 vertical 0} {M18 horizontal 0} {M19 vertical 0}}


	if {$ROUTING_LAYER_DIRECTION_OFFSET_LIST != ""} {
			foreach direction_offset_pair $ROUTING_LAYER_DIRECTION_OFFSET_LIST {
				set layer [lindex $direction_offset_pair 0]
				set direction [lindex $direction_offset_pair 1]
				set offset [lindex $direction_offset_pair 2]
				set_attribute [get_layers $layer] routing_direction $direction
				if {$offset != ""} {
					set_attribute [get_layers $layer] track_offset $offset
				}
		}
	}

	### user_manual ### 
	if {[file exists ./scripts_local/user_manual_fp.tcl]} {
		source ./scripts_local/user_manual_fp.tcl
	} else {
		puts "-E- ./scripts_local/user_manual_fp.tcl file not found!"
		echo $cmd_out ; eval $cmd_out
		#echo $cmd_out ; return 1
	}
	
	#------------------------------------------------------------------------------
	# Block boundary definition
	#------------------------------------------------------------------------------
	# EA checking
	if {[info exists block_boundary]} {	
		if {[expr {[lsearch -exact [lmap x [join $block_boundary] {string is integer -strict $x}] 0] == -1}]} {
			set block_boundary [lmap {x y} [join $block_boundary] {list [format %.3f [expr {$x * 31.92}]] [format %.3f [expr {$y * 10.868}]]}]
			puts $block_boundary
		}	
		foreach p $block_boundary {
			set p_x [lindex $p 0]
			set p_y [lindex $p 1]
			set p_x_mul [expr ${p_x}/${xMul} ]
			set p_x_mul_int [expr int(${p_x_mul})]
			set p_y_mul [expr ${p_y}/${yMul} ]
			set p_y_mul_int [expr int(${p_y_mul})]
			if {[expr abs($p_y_mul_int - $p_y_mul)] > 0.0000 || [expr abs($p_x_mul_int - $p_x_mul)] > 0.0000} {
				puts "Error: found ILLEGAL X multiple $p_x_mul OR Y multiple $p_y_mul"
				echo $cmd_out ; eval $cmd_out
	#			echo $cmd_out ; return 1
			} else {
				puts "Found legal X multiple $p_x_mul and Y multiple $p_y_mul"
			}
		}
	} else {
		save_block -compress -as ${DESIGN_NAME}/init_ERROR_boundary 
	
		puts "-W- block_boundary variable not defined!"
		echo $cmd_out ; eval $cmd_out
	#	echo $cmd_out ; return 1 
	}
	
	# EA: using control type die and not core - to give the internal shape and have the IO core created around -
	initialize_floorplan \
		-control_type die \
		-core_offset [list $boundary_offset_x $boundary_offset_y] \
		-boundary "$block_boundary" \
		-row_pattern H117_H169
	
	
	remove_tracks -all
	source -e -v scripts/layout/N3E-track-icc2.tcl
	
	#------------------------------------------------------------------------------
	# hard macro placement
	#------------------------------------------------------------------------------
	if {[sizeof [get_cells -hier -filter {is_hard_macro}]]} {
		if {[info exists macros_file]&&[file exists $macros_file]} {
			if {![string compare [file extension $macros_file] ".tcl"]} {
				source $macros_file
			} elseif {[regexp {\.def(\.gz)?$} $macros_file]} {
				read_def $macros_file
			}
			set size_unplaced_macro [sizeof_collection [get_cells -hierarchical -filter {is_hard_macro && physical_status == unplaced}]]
			if {$size_unplaced_macro} {
				puts "ERROR: unplaced macros found ...\nreport file saved: unplaced_macro.rpt"
				redirect -file unplaced_macros.rpt {get_attribute [get_cells -hierarchical -filter {is_hard_macro && physical_status == unplaced}] full_name}
				if {!$FE_MODE} {
					echo $cmd_out ; eval $cmd_out
					# echo $cmd_out ; return 1
				}	
			}
		} else {
			puts "-W- macros placement file not found!"
			if {!$FE_MODE} {
				echo $cmd_out ; eval $cmd_out
				#echo $cmd_out ; return 1
			}
			
		}
		
		# creating macros grid(s) and snap macros to it (them)
		write_collection [sort_collection [get_cells -hier -filter "is_hard_macro&&ref_name=~$MEM_PREFIX_PATTERN*"] full_name] -columns "full_name origin" -file before.rpt
		remove_macros_grid
		create_macros_grid
		report_grids > macro_grids.rpt
		write_collection [sort_collection [get_cells -hier -filter "is_hard_macro&&ref_name=~$MEM_PREFIX_PATTERN*"] full_name] -columns "full_name origin" -file after.rpt
		set moved [compare_cell_positions before.rpt after.rpt]
		if {$moved} {be_print_big_warning "$moved macros were moved during snapping to grids. please check!"}
		# defining, checking & fixing fp spacing rules
		define_fp_spacing_rules
		report_floorplan_rules > fp_spacing_rules.rpt
		set err_cnt [sizeof [check_floorplan_rules -objects [get_cells -hier -filter "is_hard_macro&&ref_name=~$MEM_PREFIX_PATTERN*"]]]
		if {$err_cnt} {
			write_collection [sort_collection [get_cells -hier -filter "is_hard_macro&&ref_name=~$MEM_PREFIX_PATTERN*"] full_name] -columns "full_name origin" -file before.rpt
			set_fixed_objects -unfix [get_cells -hier -filter "is_hard_macro&&ref_name=~$MEM_PREFIX_PATTERN*"]
			fix_floorplan_rules -objects [get_cells -hier -filter "is_hard_macro&&ref_name=~$MEM_PREFIX_PATTERN*"]
			write_collection [sort_collection [get_cells -hier -filter "is_hard_macro&&ref_name=~$MEM_PREFIX_PATTERN*"] full_name] -columns "full_name origin" -file after.rpt
			set moved [compare_cell_positions before.rpt after.rpt]
			if {$moved} {be_print_big_warning "$moved macros were moved during spacing rules violation fixing. please check!"}
		}
		
		# removing gui annotaions created by fix command:
		gui_start
		if {[sizeof [gui_get_annotations -group displacement_report]]} {
			gui_remove_annotations -group displacement_report
		}
		gui_stop
		
		# check that all macros are on grid
		memory_placement_checker_brcm3
		cs
		set err_cnt [sizeof [check_floorplan_rules -objects [get_cells -hier -filter "is_hard_macro&&ref_name=~$MEM_PREFIX_PATTERN*"]]]
		if {$err_cnt} {
			save_block -compress -as ${DESIGN_NAME}/init_ERROR_macro 
			echo $cmd_out ; eval $cmd_out
			# echo $cmd_out ; return 1
		} else {
		
			remove_placement_blockages [get_placement_blockages -filter {for_floorplan_rules}]
		}
		check_pin_placement -cell_type HARD_MACRO -wire_track true -pin_type SIGNAL_PINS -filename reports/macro_signal_pin_placement.rpt
		set vio_pins [check_pin_placement -cell_type HARD_MACRO -wire_track true -pin_type SIGNAL_PINS]
		if {[sizeof $vio_pins]} {
			echo $cmd_out ; eval $cmd_out
			#echo $cmd_out ; return 1
		}
		
		#----------------------------
		# Add Halo arround memories
		#----------------------------
		foreach_in_collection mem [get_cells -hierarchical -filter "is_hard_macro==true && ref_name =~ $MEM_PREFIX_PATTERN*"] {
		        set yy 0.8
		        set xx 0.65
		        set ddy $yy
		        set uuy $yy
		        set inst [get_object_name [get_cells $mem]]
		        set lx [lindex [get_attribute [get_cells $mem]  bbox] 0 0]
		        set ly [expr [lindex [get_attribute [get_cells $mem]  bbox] 0 1] - $yy]
		        set lrowo [get_attribute [get_objects_by_location -classes site_row -at "$lx $ly"] site_name]
		        set ux [lindex [get_attribute [get_cells $mem]  bbox] 1 0]
		        set uy [expr [lindex [get_attribute [get_cells $mem]  bbox] 1 1] + $yy]
		        set urowo [get_attribute [get_objects_by_location -classes site_row -at "$ux $uy"] site_name]
		        if {[string match *coreW48M143H117* $lrowo]} {set ddy [expr $ddy+0.117]}
		        if {[string match *coreW48M143H117* $urowo]} {set uuy [expr $uuy+0.117]}
		
		        set_attribute $inst outer_keepout_margin_hard "$xx $ddy $xx $uuy"
		}
	
	} ; # if {[sizeof [get_cells -hier -filter {is_hard_macro}]]} 
	
	#------------------------------------------------------------------------------
	# placement blockage 
	#------------------------------------------------------------------------------
	if {[info exists blockage_file]&&[file exists $blockage_file]} {
		source $blockage_file
	}
	
	set_app_options -name plan.place.auto_create_blockage_channel_widths -value "5um 17um"
	set_app_options -name plan.place.auto_create_blockage_channel_heights -value "5um 17um"
	derive_placement_blockages
	
	
	foreach_in_collection PB [get_placement_blockages auto_g* -filter "blockage_type == soft"] {
	 	set_attr $PB blockage_type allow_buffer_only
	        set_attr $PB blocked_percentage 50
	}  
	remove_floorplan_rules -all
	# core area dimension rule
	 set_floorplan_width_rules -name core_simple -direction vertical -type simple -offset 2.119 -step 0.286 -object_types core_area
	 set_floorplan_width_rules -name core_jog -direction vertical -type jog -offset 0.572 -step 0.286 -object_types core_area
	 set_floorplan_width_rules -name core_incorner -direction vertical -type incorner -offset 1.313 -step 0.286 -object_types core_area
	 set_floorplan_width_rules -name core_concave -direction vertical -type concave -offset 2.119 -step 0.286 -object_types core_area
	 set_floorplan_width_rules -name core_simple_h -direction horizontal -type simple -offset 2.016 -step 0.048 -object_types core_area
	 set_floorplan_width_rules -name core_jog_h -direction horizontal -type jog -offset 1.056 -step 0.048 -object_types core_area
	 set_floorplan_width_rules -name core_incorner_h -direction horizontal -type incorner -offset 0.96 -step 0.048 -object_types core_area
	 set_floorplan_width_rules -name core_concave_h -direction horizontal -type concave -offset 2.016 -step 0.048 -object_types core_area
	#VA legal dimension
	 set_floorplan_width_rules -name va_simple -direction vertical -type simple -offset 2.119 -step 0.286 -object_types boundary_cell_region
	 set_floorplan_width_rules -name va_jog -direction vertical -type jog -offset 0.572 -step 0.286 -object_types boundary_cell_region
	 set_floorplan_width_rules -name va_incorner -direction vertical -type incorner -offset 1.313 -step 0.286 -object_types boundary_cell_region
	 set_floorplan_width_rules -name va_concave -direction vertical -type concave -offset 2.119 -step 0.286 -object_types boundary_cell_region
	 set_floorplan_width_rules -name va_simple_h -direction horizontal -type simple -offset 2.016 -step 0.048 -object_types boundary_cell_region
	 set_floorplan_width_rules -name va_jog_h -direction horizontal -type jog -offset 1.056 -step 0.048 -object_types boundary_cell_region
	 set_floorplan_width_rules -name va_incorner_h -direction horizontal -type incorner -offset 0.96 -step 0.048 -object_types boundary_cell_region
	 set_floorplan_width_rules -name va_concave_h -direction horizontal -type concave -offset 2.016 -step 0.048 -object_types boundary_cell_region
	# VA legal location
	 set_floorplan_enclosure_rules -name va_location -sides vertical -offset 0.572 -step 0.286 -from_object_types core_area -to_object_types va_boundary -valid_list {0}
	 set_floorplan_enclosure_rules -name va_location_h -sides horizontal -offset 0 -step 0.048 -from_object_types core_area -to_object_types va_boundary
	
	set_app_options -name chipfinishing.enable_placeable_region_query_al -value true
	set_app_options -name chipfinishing.enable_column_based_simplified_internal_check -value true
	
	check_floorplan_rules
	set_floorplan_tech_constraint
	fix_floorplan_rules -auto 
	check_floorplan_rules -auto
	



	
	#--------------------
	# place endcap
	#--------------------
	if {!$FE_MODE} {
		
		
		# read_def out/def/nsc_l3u_wrapper_v3.before_tap.def.gz
		
		#add_well_taps -checker_board
		set_tap_boundary_wall_cell_rules \
		   -wall_distance                 {3.024 95.76} \
		   -p_tap                         */E3LLRA_TIEP \
		   -n_tap                         */E3LLRA_TIEN \
		   -p_tb_wall                     */E1LLRA_BORDERROWPWALL \
		   -n_tb_wall                     */E1LLRA_BORDERROWNWALL \
		   -p_fill_wall                  {*/E1LLRA_FILLERWALL */E2LLRA_FILLERWALL} \
		   -n_fill_wall                  {*/E1LLRA_FILLERWALL */E2LLRA_FILLERWALL} \
		   -p_fill_wall_replacement      {*/E1LLRA_FILLERWALLB */E2LLRA_FILLERWALLB} \
		   -n_fill_wall_replacement      {*/E1LLRA_FILLERWALLB */E2LLRA_FILLERWALLB} \
		   -fill_wall                    {*/E1LLRA_FILLERWALL */E2LLRA_FILLERWALL} \
		   -fill_wall_replacement        {*/E1LLRA_FILLERWALLB */E2LLRA_FILLERWALLB} \
		   -p_tap_wall                    *E3LLRA_TIEPWALL \
		   -n_tap_wall                    *E3LLRA_TIENWALL \
		   -p_tb_tap_wall                 */E3LLRA_BORDERROWTIEPWALL \
		   -n_tb_tap_wall                 */E3LLRA_BORDERROWTIENWALL \
		   -left_boundary                {*/E1LLRA_BORDERSIDELEFT  */E2LLRA_BORDERSIDELEFT} \
		   -right_boundary               {*/E1LLRA_BORDERSIDERIGHT */E2LLRA_BORDERSIDERIGHT} \
		   -p_tb_boundary                {*/E1LLRA_BORDERROWP8 */E1LLRA_BORDERROWP4 */E1LLRA_BORDERROWP2 */E1LLRA_BORDERROWP1} \
		   -n_tb_boundary                {*/E1LLRA_BORDERROWN8 */E1LLRA_BORDERROWN4 */E1LLRA_BORDERROWN2 */E1LLRA_BORDERROWN1} \
		   -p_tb_corner_boundary          */E1LLRA_BORDERCORNERPRIGHT \
		   -n_tb_corner_boundary          */E1LLRA_BORDERCORNERNRIGHT  \
		   -p_inner_corner_boundary       */E3LLRA_BORDERINTCORNERPRIGHT \
		   -n_inner_corner_boundary       */E3LLRA_BORDERINTCORNERNRIGHT \
		   -p_left_tap                    */E3LLRA_BORDERSIDELEFTTIEP \
		   -n_left_tap                    */E3LLRA_BORDERSIDELEFTTIEN \
		   -p_right_tap                   */E3LLRA_BORDERSIDERIGHTTIEP \
		   -n_right_tap                   */E3LLRA_BORDERSIDERIGHTTIEN \
		   -p_tb_tap                      */E3LLRA_BORDERROWTIEP \
		   -n_tb_tap                      */E3LLRA_BORDERROWTIEN \
		   -p_tb_corner_tap               */E3LLRA_BORDERCORNERPRIGHTTIEP \
		   -n_tb_corner_tap               */E3LLRA_BORDERCORNERNRIGHTTIEN \
		   -incorner_keepout              0.768 \
		   -at_va_boundary 
		
		report_tap_boundary_wall_cell_rules
		
		
		compile_tap_boundary_wall_cells -initial_insertion
		
		reset_app_option chipfinishing.standard_cell_region_vertical_shrink_factor
		reset_app_option chipfinishing.standard_cell_region_horizontal_shrink_factor
		set_app_options -name chipfinishing.standard_cell_region_vertical_shrink_value -value -0.0845
		set_app_options -name chipfinishing.standard_cell_region_horizontal_shrink_value -value -0.024
		
		derive_standard_cell_region_routing_guides
		
		
		derive_core_boundary_objects \
			-core_objects {CBLEFRG} \
			-y_offset 0.0005 \
			-height 0.0855 \
			-layers M1 \
			-x_extension 0.024
		
		## For CM1A.R.19.4.tm 2021/09/03
		#Since no CM1 in N3E
		#derive_core_boundary_objects \
		#	-core_objects {CBLEFRG} \
		#	-x_offset 0.0900 \
		#	-width 0.1800 \
		#	-layers M1 \
		#	-core_edge routing_preferred_direction
		
		
		## For M[1234].EN.19.[1234] 2021/06/02
		## M1 spacing 0.044 -> M1.CS.1.T
		derive_perimeter_constraint_objects \
			-perimeter_objects {metal_preferred mpndrg_nonpreferred} \
			-layers {M1} \
			-spacing_nonpreferred 0.124 \
			-spacing_preferred 0.044 \
			-width_nonpreferred 0.106 \
			-spacing_from_boundary {{M1 0.0845}} \
			-add_routing_blockage \
			-snap_to_track inward
		
		## M2 spacing 0.040 -> M2.CS.1.T
		derive_perimeter_constraint_objects \
			-perimeter_objects {metal_preferred mpndrg_nonpreferred} \
			-layers {M2} \
			-spacing_nonpreferred 0.124 \
			-spacing_preferred 0.040 \
			-width_nonpreferred 0.106 \
			-spacing_from_boundary {{M2 0.0845}} \
			-add_routing_blockage \
			-snap_to_track inward
		
		derive_perimeter_constraint_objects \
			-perimeter_objects {metal_preferred mpndrg_nonpreferred} \
			-layers {M3 M4} \
			-spacing_preferred 0.044 \
			-spacing_nonpreferred 0.124 \
			-width_nonpreferred 0.216 \
			-spacing_from_boundary {{M3 0.070} {M4 0.070}} \
			-no_overlap \
			-add_routing_blockage
		
		## To avoid LUP Violations around HDR by adding TAP cells
		set_app_options -name chipfinishing.enable_advanced_legalizer_postfixing -value true
		set_app_options -name chipfinishing.enable_al_tap_insertion -value true
		
		report_tap_boundary_wall_cell_rules
		
		## tap / boundary tap / tap wall cell insertion
		set compile_tap_boundary_wall_cells_cmd "compile_tap_boundary_wall_cells"
		
		#if {[sizeof_collection [ get_cells -hier -filter "ref_name=~HDR*" ]] > 0} {
		#	## Note: Please make sure to include tap function HDR only
		#	lappend compile_tap_boundary_wall_cells_cmd -hdr_n_tap_cells */HDR* -use_double_height_fill
		#}
		
		puts "RM-info: running $compile_tap_boundary_wall_cells_cmd"
		eval $compile_tap_boundary_wall_cells_cmd
		
		#remove_placement_spacing_rules -label BNDRY
		#remove_placement_spacing_rules -label HDR
		
		## For foundry required to drop VDD only (ICC2/FC default behavior to drop both VDD and VSS edge)
		## No need to specify any power net name, use only VDD, only impact tap coverage checking
		set_app_options -name place.legalize.tap_cover_drop_edges -value {VDD}
		
		## Check continuity & tap coverage
		check_legality -chipfinishing all
		
	
	} ; # if {!$FE_MODE}
							
	
	#------------------------------------------------------------------------------
	# power
	#------------------------------------------------------------------------------
	if {!$FE_MODE} {
		set_app_option -name file.def.check_mask_constraints -value none
		read_def ./scripts/layout/brcm3_pg_via.def
		source ./scripts/layout/fc_create_power_grid.brcm3.tcl
	
		### Add the Avago power grid.
		add_avago_power_grid
	
		#add_dummy_boundary_wires -layers {M1 M2 M3 M4} 
	
		# Add verifyPowerVia for PG intersection VIA existence check.
		#check_power_vias-check_wire_pin_overlap -error 1000000 -report missing_via.rpt
		check_pg_missing_vias -output_file reports/init/missing_via.rpt
	
	
		source -e -v ./scripts/layout/incr_pg_mesh.low_blocks.tcl
	
		#derive_pg_mask_constraint -derive_cut_mask -check_fix_shape_drc -overwrite
	
		check_pg_drc > reports/init/check_pg_drc.rpt
	}
	
	#------------------------------------------------------------------------------
	# place pins
	#------------------------------------------------------------------------------
	if {[info exists ports_file]&&[file exists $ports_file]} {
			if {![string compare [file extension $ports_file] ".tcl"]} {
				source $ports_file
			} elseif {[regexp {\.def(\.gz)?$} $ports_file]} {
				read_def $ports_file
			}
			set_app_options -name plan.pins.ignore_pin_spacing_constraint_to_pg -value true	
			set size_violated_port [check_pin_placement   \
	    		-location true    \
	    		-wire_track true  \
	    		-pin_spacing true \
	    		-alignment true   \
	    		-layers true      \
	    		-self             \
	    		-filename  reports/pin_placement.rpt ] 
			if {[sizeof $size_violated_port]} {
				puts "ERROR: violated ports ...\nreport file saved: reports/pin_placement.rpt"
				if {!$FE_MODE} {
					save_block -compress -as ${DESIGN_NAME}/init_ERROR_ports 
					echo $cmd_out ; eval $cmd_out
	#				echo $cmd_out ; return 1
	
				}	
			}
			
			set size_unplaced_port [sizeof_collection [get_ports -filter {port_type==signal&&physical_status==unplaced}]]
			if {$size_unplaced_port} {
				puts "ERROR: unplaced ports ...\nreport file saved: unplaced_ports.rpt"	
				redirect -file check_unplaced_ports.rpt {get_attribute [get_ports -filter {port_type==signal&&physical_status==unplaced}] name }
				if {!$FE_MODE} {
					echo $cmd_out ; eval $cmd_out
	#				echo $cmd_out ; return 1
				}
			}
	
	} else {
		puts "-W- port placement file not found!"
		if {!$FE_MODE} {
			echo $cmd_out ; eval $cmd_out
	#		echo $cmd_out ; return 1
		}
	}
	
	#------------------------------------------------------------------------------
	# DCAP, GFILL insertion
	#------------------------------------------------------------------------------
	if {!$FE_MODE} {
	
		lassign [get_attribute [current_block] boundary_bounding_box.ur] die_x die_y
		set num_of_walls [expr ceil(($die_x - 88.824) / 89.088)]
		set ll_x 0.0
		set ll_y 0.0
		set ur_x 88.824
		set ur_y [expr $die_y - 0.117]
	
		for {set i 0} {$i <= $num_of_walls&&$ll_x<$die_x} {incr i} {
	
			puts "i: $i"
			puts "boundary {$ll_x $ll_y $ur_x $ur_y}"
			set cmd "create_cell_array \
					-lib_cell $PRE_PLACE_DECAP \
					-x_pitch 29.856 \
					-y_pitch  0.286 \
					-x_offset 7.344  \
					-checkerboard even \
					-snap_to_site_row true \
					-prefix FPDCAP \
					-boundary \{\{$ll_x $ll_y\} \{$ur_x $ur_y\}\}
			"
	
			eval $cmd
			set ll_x $ur_x
			set ur_x [expr $ur_x + [expr $ur_x==88.824] * 87.168 + [expr $ur_x!=88.824] * 89.088]
			if {$ur_x > $die_x} {set ur_x $die_x}
		}
	
	
	
		set ECO_DCAP_Y_STEP	 8
		
		set ll_x 0.0
		set ll_y 0.0
		set ur_x 88.824
		set ur_y [expr $die_y - 0.117]
	
	
		for {set i 0} {$i <= $num_of_walls&&$ll_x<$die_x} {incr i} {
		
			puts "i: $i"
			puts "boundary {$ll_x $ll_y $ur_x $ur_y}"
	
			set cmd "create_cell_array \
				-lib_cell $PRE_PLACE_ECO_DCAP \
				-x_pitch  29.856 \
				-y_pitch  \[expr 0.455 * $ECO_DCAP_Y_STEP\] \
				-x_offset \[expr 14.928 + 7.344] \
				-checkerboard even \
				-snap_to_site_row true \
				-prefix FPGFILL \
				-boundary \{\{$ll_x $ll_y\} \{$ur_x $ur_y\}\}
			"
			eval $cmd
		
			set ll_x $ur_x
			set ur_x [expr $ur_x + [expr $ur_x==88.824] * 87.168 + [expr $ur_x!=88.824] * 89.088]
			if {$ur_x > $die_x} {set ur_x $die_x}
	
		}

			
		#Remove all the physical cells outside boundary
		set all_physical_only_cells [get_cells -filter {is_physical_only}]
		set all_physical_only_cells_overlap_core [get_cells -within [get_attribute [current_block] boundary] -filter {is_physical_only}]
		set physical_only_cells_outside_boundary [remove_from_collection $all_physical_only_cells $all_physical_only_cells_overlap_core]

		remove_cells $physical_only_cells_outside_boundary
	}
	
	#------------------------------------------------------------------------------
	# post fp file 
	#------------------------------------------------------------------------------
	if {[info exists post_fp_file]&&[file exists $post_fp_file]} {
		source $post_fp_file
	}
} ; #if {$FE_MODE && ![file exists ./scripts_local/user_manual_fp.tcl]}


return 0

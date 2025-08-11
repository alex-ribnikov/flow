proc ea_write_terminals {} {
        # global top_module_name
        if {![file isdirectory scripts_local]} {
                puts "Einav: creating scripts_local directory . . ."
                file mkdir scripts_local
        }
        set tmn [get_att [current_design ] top_module_name] ; # [get_attribute [current_block] name]
        set term [get_terminals * -filter "name != VDD && name != VSS"]
        set oldRulebased [get_app_option_value -name design.enable_rule_based_query]
        write_floorplan -objects $term -force -output floorplan_pins 
        exec mv floorplan_pins/fp.tcl ${tmn}.pins_tmp
        exec rm -rf floorplan_pins
        set target_port_file "./scripts_local/${tmn}.port_locations.tcl"
        redirect $target_port_file {echo "set oldSnapState \[get_snap_setting -enabled\]"}
        redirect -append $target_port_file {echo "if \{\[get_terminals * -quiet\] != \"\"\} \{remove_objects \[get_shapes -of_objects \[get_terminals *\]\]\}"}
        redirect -append $target_port_file {echo "set_app_options -name design.enable_rule_based_query -value false"}
        exec cat ${tmn}.pins_tmp | perl -pe {s/\\\n/ /g} | perl -pe {s/\{\n//g} | perl -pe {s/^\}//g} | grep -v remove_shape > ${tmn}.pins_tmp2
        exec cat ${tmn}.pins_tmp2 | perl -00pe0 >> $target_port_file ; # ../inter/${tmn}.port_locations.tcl
        redirect -append $target_port_file {echo "\nset_fixed_objects \[get_terminals\] "}
        redirect -append $target_port_file {echo "set_snap_setting -enabled \$oldSnapState"}
        file delete -force ${tmn}.pins_tmp
        file delete -force ${tmn}.pins_tmp2
        puts "-I- Written Terminals: [sizeof_collection $term] , $target_port_file"
}

# ${DESIGN_NAME}.bump_centers.txt
proc EaExtractBumpCenters {args} {

	parse_proc_arguments -args $args results
	
	global STREAM_FILE_LIST STREAM_LAYER_MAP_FILE LEF_FILE_LIST
	global DESIGN_NAME

	puts "TODO - to be done before the script execution, for users ! ! ! set_early_data_check_policy -policy tolerate -checks hier.block.leaf_cell_outside_boundary"

	set outf "./reports/[get_att [current_block] top_module_name].bump_centers.txt" ; # ${DESIGN_NAME}
	# if {[info exists results(-p_list)]} {
	# 	set p_col [get_ports $results(-p_list)]
	# } else {
	# 	puts "Generating current block bump centers file . . ."
	# 	# return
	# }

	# # Einav: modifications to run from fullchip level -
	# global unit_stubs unit_ips
	set all_hard_ips [get_cells -q -physical_context -filter "is_hard_macro==true && is_physical_only == false && ref_name!~M3*"] ; # TODO pads as well? || (pad_cell == true)
	# set all_hard_ips [get_cells -hierarchical -filter "ref_name==[regsub -all { } $unit_ips { || ref_name==}]"] ; #  && ref_name!~ *UBMP* && ref_name!=[regsub -all { } $unit_stubs { \&\& ref_name!=}]
	# set all_hard_ips [get_cells -filter "is_hard_macro==true && is_physical_only == false && ref_name!~M3* && view_name!=frame"] ;#avoiding catching the sons' frame

	if {$all_hard_ips == ""} {
		puts "Found no hard IPs to extract bumps for, returning . . ."
		return
	}

	# Einav: adding probepad and ubump references globally in project 
	if {[info exists results(-no_rm_all_bump)] && $results(-no_rm_all_bump)} {
		puts "Warning: skipping [sizeof [get_cells -q -filter "ref_name==PROBEPAD_59X59||ref_name==UBUMP"]] pre-existing bumps removal . . ."
	} elseif {[get_cells -q -filter "ref_name==PROBEPAD_59X59||ref_name==UBUMP"] != ""} {
		puts "Warning: PROBEPAD/ BUMP already exist in design, removing . . ."
		remove_cells -f [get_cells -filter "ref_name==PROBEPAD_59X59||ref_name==UBUMP"]
	}

	if {[info exists results(-add_term_to_connected_port)] && $results(-add_term_to_connected_port) && [get_terminals -q -filter "layer.name==AP"] != ""} {
		remove_terminals -f [get_terminals -filter "layer.name==AP"]
	}

	set outp [open ${outf} w]
	puts $outp "ATT NAME\t\t\tX VALUE\tY VALUE\tPORT NAME\tIP REF\tIP ORIENTATION"
	set curr_p ""
	set p_list [list ]
	set bump_cnt 0
	set no_bump_col ""
	set ports_placed ""

	# Einav: adding multipliers to avoid miscalculations of TCL -
	set tenk_int 10000
	set tenk_float 10000.0

	foreach_in_collection m $all_hard_ips {
		set m_name [get_object_name $m]
		set m_ref [get_att $m ref_name]
		set m_boundary [get_att [get_cells $m] boundary]

		puts "Info: generating BUMP cells for instance $m_name of type $m_ref"
		set m_lef [lsearch -all -inline $LEF_FILE_LIST *${m_ref}*]
		global CTERM_FILE_LIST
		set m_cterm ""
		if {[info exists CTERM_FILE_LIST]} {
			set m_cterm [lsearch -all -inline $CTERM_FILE_LIST *${m_ref}*]
		}
		if {$m_lef == ""} {
			
			if {$m_cterm == ""} {
				puts "Error: no hard IP LEF OR CTERM found for \"${m_ref}\", continuing . . ."
				continue
				# return
			} else {
				puts "Warning: no hard IP LEF found for \"${m_ref}\", found CTERM instead . . ."
			}
		}
		if {[lsearch -all -inline $STREAM_FILE_LIST *${m_ref}*] == ""} {
			puts "Error: no GDS found in the \$STREAM_FILE_LIST for ${m_ref}! Returning . . ."
			return
		}
		if {![file exists $m_lef]} {
			set valid_flag 0
			foreach m_cterm_i $m_cterm {
				if {[file exists $m_cterm_i} {
					set valid_flag 1
					break
				}
			}
			if {!$valid_flag} {
				puts "Error: the file $m_lef NOR CTERM files exist! Returning . . ."
				# return
			}
		}
		if {[llength $m_lef] > 1} {
			puts "Error: found multiple LEF matching for \"${m_ref}\", returning . . ."
			return
		}

		set m_bump_cnt 0
		# Einav: handling none rectlinear IPs -
		set m_min_x -1.0
		set m_max_x -1.0
		set m_max_y -1.0
		set m_min_y -1.0
		foreach point $m_boundary {
			set point_x [lindex $point 0]
			set point_y [lindex $point 1]
			if {$m_max_x < 0 || $m_max_y < 0} {
				set m_max_x $point_x
				set m_min_x $point_x
				set m_max_y $point_y
				set m_min_y $point_y
				continue
			}
			if {$m_max_x < $point_x} {
				set m_max_x $point_x
			}
			if {$m_min_x > $point_x} {
				set m_min_x $point_x
			}
			if {$m_max_y < $point_y} {
				set m_max_y $point_y
			}
			if {$m_min_y > $point_y} {
				set m_min_y $point_y
			}
		}
		set m_width [expr $m_max_x - $m_min_x]
		set m_height [expr $m_max_y - $m_min_y]

		# Einav: setting possible rotation respective offset addition -
		set m_orient [get_att $m orientation]
		set m_orient_sign_x 1
		set m_orient_sign_y 1
		switch $m_orient {
			"R0" {
				set m_orient_offset_x [expr $m_min_x ] ; # + $p_x
				set m_orient_offset_y [expr $m_min_y ] ; # + $p_y
			}
			"MX" {
				set m_orient_offset_x [expr $m_min_x ] ; # + $p_x
				set m_orient_offset_y [expr $m_min_y + $m_height ] ; # - $p_y
				set m_orient_sign_y -1
			}
			"MY" {
				set m_orient_offset_x [expr $m_min_x + $m_width ] ; # - $p_x
				set m_orient_sign_x -1
				set m_orient_offset_y [expr $m_min_y ] ; # + $p_y
			}
			"R180" {
				set m_orient_offset_x [expr $m_min_x + $m_width ] ; # - $p_x
				set m_orient_sign_x -1
				set m_orient_offset_y [expr $m_min_y + $m_height ] ; # - $p_y
				set m_orient_sign_y -1
			}
			default {
				puts "Error: $m_name hard IP possibly placed with invalid orientation (anything other than R0,Mx,My,R180), returning . . ."
				return
			}
		}
		
		# Einav: CTERM should only exist for PM HIP - 
		if {$m_cterm == ""} {
			set target_file_path "temp_lef_grep.txt"
			exec egrep "PIN\|BUMP" $m_lef > $target_file_path
			set target_pattern "\\s+PROPERTY\\s+(\\S+)\\s+\\\"(\\S+),(\\S+)\\\""
			# Einav: Performing the file parsing on the potentially necessary lines only -
			# set f [open "$target_file_path" r] ; # "$m_lef"
			#    PIN VSS
		} else {
			set target_file_path $m_cterm
			set target_pattern "\.\*LAYOUT\\s+TEXT\\s+\\\"(\\S+)\\\"\\s+(\\S+)\\s+(\\S+)"
		}
		
		foreach target_f $target_file_path {
			set f [open "$target_f" r]
			while {[gets $f line] != -1} {
				if {[regexp {\s+PIN\s+(\S+)} $line -> p_match]} {
					set curr_p $p_match
					set p_list [lappend p_list $curr_p]
					# puts "$curr_p"
				} else {
					# NO *PIN* regexp should be matched in CTERM files -
					if {$m_cterm != ""} {
						# {.*LAYOUT\s+TEXT\s+\"(\S+)\"\s+(\S+)\s+(\S+)}
						if {[regexp $target_pattern $line -> p_match]} {
							set curr_p $p_match
							set p_list [lappend p_list $curr_p]
						}
					}
				}

				#     PROPERTY UBUMP_CENTER_COORDS93 "37.240000,1233.026000" ;
				#     PROPERTY PBUMP_CENTER_COORDS1 "223.440000,1258.712000" ; 
				# TODO for CTERM files -
				# LAYOUT TEXT "VSS" 3800.024 1639.8 202 74 "pm8x200_top_g2_h"
				# regexp {.*LAYOUT\s+TEXT\s+\"(\S+)\"\s+(\S+)\s+(\S+)} $line -> p_property p_x p_y
				# PROPERTY UBUMP_CENTER_COORDS107 "220.2200,190.6440" ;
				# \s+PROPERTY\s+(\S+)\s+\"(\S+),(\S+)\"
				if {[regexp $target_pattern $line -> p_property p_x p_y]} {
					set offset_x_int [expr int(${m_orient_offset_x}*${tenk_int})]
					set offset_y_int [expr int(${m_orient_offset_y}*${tenk_int})]
					set p_x_int [expr int(${p_x}*${tenk_int})]
					set p_y_int [expr int(${p_y}*${tenk_int})]
					set p_global_loc_x [expr ($offset_x_int + (${m_orient_sign_x}*${p_x_int}))/$tenk_float]
					set p_global_loc_y [expr ($offset_y_int + (${m_orient_sign_y}*${p_y_int}))/$tenk_float]

					# Einav: adding references dependant on bump type -
					set bump_ref "UBUMP"
    				if {[regexp PBUMP $p_property] || [regexp prbpad_only $target_f]} { set bump_ref "PROBEPAD_59X59" }
					puts $outp "${p_property}\t\t${p_global_loc_x}\t${p_global_loc_y}\t${curr_p}\t${m_ref}\t${m_orient}" ; #
					# TODO Einav: Small ones are ubumps and bigger ones are probepad - PORT MACRO to create bumps by terminal size
					
					# puts "Einav: Line executed is: $line"
					set mycell [create_cell "[regsub -all {\[|\]} [string toupper ${curr_p}] {_}]_${bump_ref}_${bump_cnt}" $bump_ref]
    				set_attribute [get_cells $mycell] origin "$p_global_loc_x $p_global_loc_y" ; # "$bump_center_x $bump_center_y"
					set_attribute [get_cells $mycell] orientation $m_orient
    				set_attribute [get_cells $mycell] physical_status locked ; # Einav: avoiding any issues due to unplaced status
					if {[info exists results(-add_term_to_connected_port)] && $results(-add_term_to_connected_port)} {
						# # TODO - Einav: work around ONLY for HBM missing ports in old version!!! TEMPORARY!!!
						# if {$curr_p == "VDDQ" || $curr_p == "VDDQL"} {
						# 	# Einav: internal to save the get_ports iterations for no reason -
						# 	if {[get_ports -q $curr_p] == ""} {
						# 		puts "Warning: cannot find port name $curr_p placing VDD terminals instead ! ! !"
						# 		set curr_p VDD
						# 	}
						# }
						set mypin [get_pins ${m_name}/${curr_p}]
						set mypin_net [get_nets -q -physical_context -of $mypin] ; # ${curr_p} TODO a patch for old HBM (NO BUMPS!) with new LEF
						
						if {$mypin_net == ""} {
							puts "Error: found a disconnected pin with name - [get_object_name $mypin]"
						} else {
							# Einav: adding bump pin connectivity to the net for LVS purposes -
							connect_net -net [get_nets $mypin_net] [get_pins -of $mycell -filter "layer.name==AP"] ; # [get_pins ${mycell}/Z]
							set curr_p_net_port [get_ports -q [all_connected -leaf $mypin_net]] ; # -of $mypin_net
							# puts "Einav: adding on [get_object_name $mypin] pin a terminal for port - [get_object_name $curr_p_net_port]"
							if {$curr_p_net_port == ""} {
								puts "Error: no port connectivity to create terminal on for pin - [get_object_name $mypin]"
							} else {
								set mycell_z_shape_boundary [get_att [get_shapes -of [get_pins -of $mycell -filter "layer.name==AP"]] boundary]
								create_terminal -port $curr_p_net_port -boundary $mycell_z_shape_boundary -name "[get_object_name ${curr_p_net_port}]_term${bump_cnt}" -direction all -layer AP
								append_to_collection ports_placed $curr_p_net_port
							}
						}
						
					}
    				incr bump_cnt
					incr m_bump_cnt
				}
			}
			puts "Info: added $m_bump_cnt bumps for instance $m_name of type $m_ref . . ."
			puts "Info: added total of $bump_cnt bump cover cells, ongoing . . ."
			if {!$m_bump_cnt} {
				append_to_collection no_bump_col $m
			}
			# puts "Info: BUMP generation count: $bump_cnt"
			close $f
		}
		
	}
	close $outp
	if {$ports_placed != ""} {
		set_attribute [get_nets -of $ports_placed] physical_status locked
		set_dont_touch [get_nets -of $ports_placed] true
	}
	
	# Einav: post processing iterating over all BUMP/ PAD and remove those within another one -
	set bump_pad_overlap ""
	foreach_in_collection c [get_cells -q -filter "ref_name=~*PAD*"] {
		set pad_box [get_att $c bbox]
		set c_inter [remove_from_collection [get_cells -q -inter $pad_box -filter "ref_name=~*PAD*"] $c]
		set c_within [remove_from_collection [get_cells -q -within $pad_box -filter "ref_name=~*UBUMP*"] $c]
		if {$c_inter != ""} {
			puts "Warning: found PAD name [get_object_name $c] overlap with PAD cells - [get_object_name $c_inter]"
			append_to_collection bump_pad_overlap $c_inter
		}
		if {$c_within != ""} {
			puts "Warning: found PAD name [get_object_name $c] covering a BUMP cell - [get_object_name $c_within]"
			append_to_collection bump_pad_overlap $c_within
		}
	}

	if {$bump_pad_overlap != ""} {
		if {[info exists results(-rm_dupes)] && $results(-rm_dupes)} {
			puts "Info: removing [sizeof $bump_pad_overlap] bumps/ probes with overlap . . ."
			remove_cells -f $bump_pad_overlap
		} else {
			puts "Warning: found [sizeof $bump_pad_overlap] bumps/ probes with overlap, consider running with flag -rm_dupes . . ."
		}
	}

	# TODO Einav: must make sure the count match the total number of PBUMP+UBUMP - Number of leaf cells kept due to include_objects: 45
	# Einav: TODO to be added to the flow !!!
	global STREAM_FILE_LIST
	global cell_rename_files
	global STREAM_LAYER_MAP_FILE
	
	# Einav: TODO all app options below must be indluded in the flow!!! -
	set_app_options -name file.oasis.check_mask_constraints -value none
	
	# Einav: TODO clarification with Gilad throws an error - TL-129 can be ignored.
	suppress_message TL-129 ; # Einav: avoiding this error from throwing uss out of the script
	suppress_message NDMUI-925
	# TODO - to be done before the script execution, for users ! ! ! set_early_data_check_policy -policy tolerate -checks hier.block.leaf_cell_outside_boundary
	# TODO also possible: catch {set_early_data_check_policy -policy tolerate -checks hier.block.leaf_cell_outside_boundary} ; # To avoid the error - Error: Configuration not set. (NDMUI-925)
	foreach_in_collection c $no_bump_col {
		puts "Warning: [get_object_name $c] of type [get_att $c ref_name] received no bumps ! ! !"
	}

	if {!$bump_cnt} {
		puts "Warning: no bumps added in current design level, no abstract or frame was generated, script done . . ."
		return
	}
	
	set p_list [lsort -u $p_list]
	puts "Total bumps added: $bump_cnt" ; # [llength $p_list]

	if {[info exists results(-no_frame)] && $results(-no_frame)} {
		puts "Warning: skipping frame and abstract creation for the block . . ."
		return
	}
	
	if {![info exists results(-write_oas)] || ([info exists results(-write_oas)] && !$results(-write_oas))} {
		puts "Warning: skipping oasis generation . . ."
		return
	}
	
	suppress_message OASIS-059
	puts "Info: generating OAS file to ./out/${DESIGN_NAME}_merge.oas"
	set cmd "write_oasis -verbose -rename_cell $cell_rename_files -connect_below_cut_metal -write_default_layers [list [get_object_name [get_layers VIA* -filter "number_of_masks==2"]]] -merge_files \"${STREAM_FILE_LIST}\" -lib_cell_view frame -hierarchy all -output_pin {all} -keep_data_type -unit 2000 -text_for_pin -layer_map $STREAM_LAYER_MAP_FILE -layer_map_format icc2 ./out/${DESIGN_NAME}_merge.oas"
	
	eval $cmd
	unsuppress_message OASIS-059
	# Example from Gilad - # HOW TO EXTRACT port name from upper level, for exmaple take one of proce bumps ROBEPAD_59X59_10
	# Example from Gilad - # and run the follwing
	# Example from Gilad - 
	# Example from Gilad - fc_shell> bbox_center [get_attribute [get_cells PROBEPAD_59X59_10 ] bbox]
	# Example from Gilad - 31.92 161.28
	# Example from Gilad - fc_shell> get_terminals -at [bbox_center [get_attribute [get_cells PROBEPAD_59X59_10 ] bbox]]
	# Example from Gilad - {VDDA15_term0}
	# Example from Gilad - fc_shell> get_ports -of_objects [get_terminals -at [bbox_center [get_attribute [get_cells PROBEPAD_59X59_10 ] bbox]]]
	# Example from Gilad - {VDDA15}
}
define_proc_attributes EaExtractBumpCenters -info "Extracting all the bumps from the LEF of the current design hard IPs to a file in the format: ATT NAME X VALUE Y VALUE PORT NAME HARD IP ORIENTATION" -define_args {
	{-no_rm_all_bump				"Avoiding currently existing bumps from removal" {} boolean optional}
	{-no_frame						"Exit without creating the frame and abstract" {} boolean optional}
	{-add_term_to_connected_port	"Adding temrinals by finding connected ports to the LEF pins" {} boolean optional}
	{-write_oas						"Writing oasis at the end of the function" {} boolean optional}
	{-rm_dupes 						"Removing overlapping bump/ probes from the design" {} boolean optional}
}

proc EaCreateAPTerms {args} {
	parse_proc_arguments -args $args results
	set all_sub_blocks [get_cells -q -physical_context -filter "(is_soft_macro==true || is_hard_macro==true) && is_physical_only == false && ref_name!~M3*"]
	set all_ap_pins [get_pins -q -of $all_sub_blocks -filter "layer.name==AP && (cell.ref_name!~*PROBE* && cell.ref_name!~*BUMP* && cell.ref_name!~*UBMP*)"]
	# Einav: skipping for the empty collection case -
	if {$all_ap_pins == ""} {
		puts "Info: skipping non-AP pins block . . ."
		return
	}
    suppress_message SEL-010
	set naked_shapes ""
	set cnt_init [sizeof [get_terminals -q -filter "layer.name==AP"]]
    set cnt [expr 1+${cnt_init}]
    foreach_in_collection p $all_ap_pins {
    	set p_port [get_ports -q [all_connected -leaf [get_nets -q -of $p]]]
    	if {$p_port == ""} {
    		puts "Error: found non-port-connected pin, skipping - [get_object_name $p]"
    		continue
    	}
		set p_net [get_nets -q -of $p_port]
    	
    	puts "Info: generating terminals for port [get_object_name $p_port] "
    	set p_ap_shapes [get_shapes -q -of $p -filter "layer.name==AP"]
    	foreach_in_collection s $p_ap_shapes {
    		set s_boundary [get_att $s boundary]
    		create_terminal -port $p_port -boundary $s_boundary -name "[get_object_name ${p_port}]_term${cnt}" -direction all -layer AP
    		incr cnt
			# Einav: adding bump pins ocnnectivity - all hierarchical bumps upgraded to top-level in the loop above, PG-MESH bumps will only be added later! -
			set s_center [get_att $s bounding_box.center]
			set s_bumps_pads [get_cells -q -at $s_center -filter "ref_name=~*UBUMP* || ref_name=~*UBMP* || ref_name=~*PROBEPAD*"]
			if {$s_bumps_pads != ""} {
				# Einav: connnected pins cannot be re-connected, checking for correct connectivity -
				foreach_in_collection ub_pin [get_pins -q -of $s_bumps_pads -filter "layer.name==AP"] {
					set ub_net [get_nets -q -of $ub_pin]
					if {$ub_net != "" && ([get_object_name $ub_net] != [get_object_name $p_net])} {
						# Einav: for pin net other than the port net error.
						puts "Error: top-level bump [get_object_name $ub_pin] is conencted to net [get_object_name $ub_net] instead of [get_object_name $p_net] !"
					} 
					if {$ub_net == ""} {
						connect_net -net $p_net $ub_pin ; # if no net, connect to the port net.
					}
					# Einav: no action required if the nets are the same already!
				}
			} else {
				puts "Warning: no bump found for shape at - $s_center"
				append_to_collection naked_shapes $s
			}
    	}
    }
    puts "Info: added [expr $cnt - $cnt_init] AP shapes on design sub blocks . . ."
	puts "Info: found [sizeof $naked_shapes] AP shapes without a matching bump/ probe"
    unsuppress_message SEL-010
	set all_bumps_nets [get_nets -q -of [get_pins -q -of [get_cells -q -filter "ref_name=~*UBMP* || ref_name=~*UBUMP* || ref_name=~*PROBEPAD*"] -filter "layer.name==AP"]]
	set all_nets_bumps [get_cells -q -of [get_pins -q -of $all_bumps_nets -filter "cell.ref_name=~*UBMP* || cell.ref_name=~*UBUMP* || cell.ref_name=~*PROBEPAD*"]]
	set no_net_bumps [remove_from_collection [get_cells -q -filter "ref_name=~*UBMP* || ref_name=~*UBUMP* || ref_name=~*PROBEPAD*"] $all_nets_bumps]
	if {$no_net_bumps != ""} {
		puts "Error: found [sizeof $no_net_bumps] bumps/ pads without a net connected to it !"
	}
}
define_proc_attributes EaCreateAPTerms -info "globally connects all AP pins in current level to their respective ports, TODO might require buffer/inverter removal earlier" -define_args {
}


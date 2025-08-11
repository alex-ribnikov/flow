proc bedb_lib_prep {stages args} {
	if {$stages == ""} {
		puts "Error: No stage name given as an input"
		return
	}
	# Default for optional flag
    	set change_lib true
    	# Parse optional args
    	set i 0
   	while {$i < [llength $args]} {
        	set arg [lindex $args $i]
        	switch -- $arg {
            		-change_lib {
                		incr i
                		if {$i >= [llength $args]} {
                    			error "Missing value for -change_lib"
                		}
                		set change_lib [lindex $args $i]
            		}
            		default {
                		error "Unknown flag: $arg"
            		}
        	}
        	incr i
    	}
	# To ensure that everything has been closed and no lib was left open
	# Make sure that everything has been saved before running this proc
	close_lib -all
	global DESIGN_NAME 
	set design_name $DESIGN_NAME
	set continuous_layers [list "M7" "M8" "M11" "M13" "M14" "M15" "M16" "M17" "M18" "M19"]
	foreach stage $stages {
		if {![file exists [pwd]/out/${design_name}_lib/${design_name}/design_label.${stage}/design.ndm]} {
			puts "Error: stage $stage NDM cannot be found for block $design_name, skipping"
			continue
		}
		set source_dir [pwd]/out/${design_name}_lib:$design_name/$stage.design
		if {[file exists [pwd]/out/${design_name}_${stage}_frame_abstract_lib:$design_name/$stage]} {
			exec rm -rf [pwd]/out/${design_name}_${stage}_frame_abstract_lib:$design_name/$stage
		}
		set dest_dir [pwd]/out/${design_name}_${stage}_frame_abstract_lib:$design_name/$stage
		copy_block -from_block $source_dir -to_block $dest_dir
		open_block $dest_dir
		report_ref_libs > ref_libs.rpt
		set bedb_cmd "/bespace/users/be_repository/scripts/bedb/latest/nextbe-cli.py"
		# Open the report file
		set reportFile [open "ref_libs.rpt" r]
		set lineNumber 0
		set subsystemOrTopFound 0
		set startParsing 0
		# Reading the file line by line
		while {[gets $reportFile line] >= 0} {
    			incr lineNumber
			# Starting at the first line that begins with "*+"
			if {[regexp {^\*\+} $line]} {
				set startParsing 1
			}
    			if {$startParsing} {
        			set trimmedLine [string trim $line] 			
        			if {[regexp {^\s+(\S+)\s+(\S+)\s+(\S+)} $trimmedLine match name path location]} {
					# Execute the command and capture the output
            				set sons_output [exec $bedb_cmd get_sons -block $DESIGN_NAME]
            				set sons_list {}
            				if {[string equal $sons_output ""]} {
						# Blank output means we are running at block level
                				continue
            				} else {
						# Subsystem or Top level
						set subsystemOrTopFound 1  ;# Set the flag if a valid /bespace/* path is found
                				# Split the output by commas and append "_lib" to each block name
                				set block_names [split $sons_output ","]
                				foreach block_name $block_names {
                    					lappend sons_list "${block_name}_lib"
               		 			}
            				}	
            				# Use the sons_list to check for matches with $name column
            				foreach son_name $sons_list {
						# Remove the "_lib" suffix to get the block_name
                				set block_name [string trimright $son_name "_lib"]
                				if {$son_name eq $name} {
                    					#puts "Marked pnr for $name: $path"
                    					set bedb_cmd_result [catch {
                        					set current_pnr [exec $bedb_cmd get -block $block_name -by pnr]
                   					} errorMessage]
							 if {$bedb_cmd_result != 0} {
                        					puts "Error: Couldn't find marked lib for $block_name"
                        					puts "Details: $errorMessage\n"
                    					} else {
								set full_path "${current_pnr}/${son_name}"
                        					if {$full_path eq $path || $full_path eq $location} {
                            						puts "Test passed! Ref_libs for $name (excluding STD cells, memories, and HIPs) are pointing to the current 'pnr' marked dir of the relevant block\n"
                        					} else {
                            						puts "Warning: Test failed! Ref_libs for $name (excluding STD cells, memories, and HIPs) are NOT pointing to the current 'pnr' marked dir of the relevant block"
                            						puts "Marked lib: $current_pnr"
                            						puts "Lib set in design: $path\n"
									#Add in so that if flag is marked, these two lines of code are not run
                            						if {[string equal -nocase $change_lib "true"]} {
										set_ref_libs -remove $path
                            							set_ref_libs -add $full_path
									}
                        					}
							}
                				}
            				}
    				}
		    	}
        	}
		close $reportFile
		foreach layer $continuous_layers {
               		if {[sizeof [get_terminals -q -filter "port.name==VDD || port.name==VSS && layer.name==${layer}"]] } {
                               remove_terminals [get_terminals -filter "port.name==VDD || port.name==VSS && layer.name==${layer}"]
               		}
              		create_terminal -of_objects [get_shapes -of [get_nets {VSS VDD} ] -filter layer_name==${layer}]
		}
		save_block
		save_lib
		puts "Info: creating frame and abstract for block . . ."
        	set cmd "create_abstract -read_only"
        	set cells2include [get_cells -q -hier -filter "ref_name=~*PROBEPAD*||ref_name=~UBUMP*||ref_name=~*UBMP*"]
        	if {$cells2include  != ""} {
        	    append cmd { -include_objects [get_pins -of_objects $cells2include ]}
        	}
        	eval $cmd
        	create_frame -merge_metal_blockage true -block_all true -remove_non_pin_shapes { {PO all} {M0 all} {VIA0 all} {M1 all} {VIA1 all} {M2 all} {VIA2 all} {M3 all} {VIA3 all} {M4 all} {VIA4 all} {M5 all} {VIA5 all} {M6 all} {VIA6 all} {M7 all} {VIA7 all} {M8 all} {VIA8 all} {M9 all} {VIA9 all} {M10 all} {VIA10 all} {M11 all} {VIA11 all} {M12 all} {VIA12 all} {M13 all} {VIA13 all} {M14 all} {VIA14 all} {M15 all} {VIA15 all} {M16 all} {VIA16 all} {M17 all} {VIA17 all} {M18 all} {VIA18 all}}
		close_lib -all
	}
	# If running from block level as opposed to top or subsystem
	if {[info exists subsystemOrTopFound] && $subsystemOrTopFound == 0} {
    		puts "Run from block level completed."
	}
}




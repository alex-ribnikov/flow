#############################################################################
#	dont use lib cells
#############################################################################
if {[info exists DONT_USE_CELLS] && $DONT_USE_CELLS != ""} {
	if { [regexp "inext|brcm5|nextcore|nxt080" $PROJECT] } {
	    if {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "genus"} {
                set_db [get_db lib_cells -if {.base_name == F6*} ] .avoid false
    	    } elseif {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "innovus"} {
                set_dont_use [get_lib_cells F6*] false
	    } elseif {[info exists ::synopsys_program_name]} {
		remove_attribute [get_lib_cells -regexp .*/F6.*] dont_use
  	    }
	} elseif { [regexp "brcm3|nxt013" $PROJECT] } {
	    if {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "genus"} {
	        puts "-I- setting all lib cells to be usaable"
                set_db [get_db lib_cells -if {.base_name == E*} ] .avoid false
    	    } elseif {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "innovus"} {
 	        puts "-I- setting all lib cells to be usaable"
               set_dont_use [get_lib_cells E*] false
	    } elseif {[info exists ::synopsys_program_name]} {
#		remove_attribute [get_lib_cells -regexp .*/E.*] dont_use
  	    }
	}	
	
	
	puts "-I- setting avoid on lib cells $DONT_USE_CELLS"
	foreach _cell $DONT_USE_CELLS {
         	if {[sizeof_collection [get_lib_cells */$_cell -quiet]] > 0} {
			if {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "genus"} {
				set_db [get_db lib_cells -if {.base_name == $_cell} ] .avoid true
			} elseif {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "innovus"} {
				set_dont_use [get_lib_cells $_cell]
			} elseif {[info exists ::synopsys_program_name] && $::synopsys_program_name == "rtl_shell"} {
                                 set_lib_cell_purpose -include none "[get_lib_cells $_cell]"
			} elseif {[info exists ::synopsys_program_name]} {
				set_dont_use [get_lib_cells */$_cell]
        	 	} 
		} else {
            		puts "-W- DONT_USE_CELLS lib cells $_cell does not exists"
        	}
	}
}

if {[info exists DO_USE_CELLS] && $DO_USE_CELLS != ""} {
	puts "-I- removing avoid on lib cells $DO_USE_CELLS"
	foreach _cell $DO_USE_CELLS {
		if {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "genus"} {
			set_db [get_db lib_cells -if {.base_name == $_cell} ] .avoid false
		} elseif {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "innovus"} {
			set_dont_use [get_lib_cells $_cell] false
		} elseif {[info exists ::synopsys_program_name] && $::synopsys_program_name == "dc_shell"} {
			set_attribute [get_lib_cells */$_cell] dont_use false
		} elseif {[info exists ::synopsys_program_name] && $::synopsys_program_name == "fc_shell"} {
			set_attribute [get_lib_cells */$_cell] dont_use false
		} elseif {[info exists ::synopsys_program_name] && $::synopsys_program_name == "rtl_shell"} {
			set_lib_cell_purpose -include all "[get_lib_cells */$_cell]"
		} elseif {[info exists ::synopsys_program_name]} {
			set_dont_use [get_lib_cells */$_cell]  false
		} 
	}
}

#############################################################################
#	size only
#############################################################################
if {[info exists SIZE_ONLY_INST] && $SIZE_ONLY_INST != ""} {
	foreach _inst $SIZE_ONLY_INST {
		if {[info exists ::synopsys_program_name] && $synopsys_program_name != "pt_shell"} {
			if {[sizeof_collection [get_cells -hierarchical -filter "full_name =~ $_inst && size_only == false"]] > 0} {
				puts "-I- setting size only on inst  $_inst"
		   		set_size_only -all_instances [get_cells -hierarchical -filter "full_name =~ $_inst && size_only == false"]
            			#----------------------------------------------------------------------------
            			#   remove dont touch from unloaded object
            			#----------------------------------------------------------------------------
            			foreach_in_collection III [get_cells -hierarchical -filter "full_name =~ $_inst && !abstract_dont_touch "] {
               				set output_pins [get_pins -of $III -filter "direction == out"]
               				if { [get_nets -of_object $output_pins -q] == ""} {
                     				puts "-W- Found unloaded [get_object_name $III],remove size only attribute from it"
                     				set_size_only $III false
               				}
            			}
			} else {
				puts  "-W- $_inst from SIZE_ONLY_INST list, does not exists in design"
			}
		} else {
	   		if {[sizeof_collection [get_cells -quiet -hier $_inst]] > 0} {
	   			if {![info exists ::synopsys_program_name]} {
		   			puts "-I- setting dont touch on inst  $_inst"
					set_db [get_db insts $_inst] .dont_touch size_ok
                  #----------------------------------------------------------------------------
                  #   remove dont touch from unloaded object
                  #----------------------------------------------------------------------------
                  foreach_in_collection III [get_cells -hierarchical -filter "full_name =~ $_inst"] {
                     set output_pins [get_pins -of $III -filter "direction == out"]
                     if { [get_nets -of_object $output_pins] == ""} {
                        puts "-W- Found unloaded [get_object_name $III],remove size only attribute from it"
                        set_db [get_db insts $_inst] .dont_touch false
                     }
                  }
				}
	   		} else {
				puts  "-W- $_inst from SIZE_ONLY_INST list, does not exists in design"
	   		}
		}
	}
	if {[info exists ::synopsys_program_name] && $synopsys_program_name != "pt_shell"} {
		report_size_only > reports/report_size_only.rpt
	}
}

if {![info exists ::synopsys_program_name] && [is_attribute user_size_only_cell  -obj_type inst]} {
	puts "-I- setting size only on user define attributre user_size_only_cell"
	foreach _inst [get_db insts -if ".user_size_only_cell==true"] {
			puts "-I- setting sizeonly on inst $_inst"
			set_db [get_db $_inst] .dont_touch size_ok
	}
}

#############################################################################
#	dont touch inst
#############################################################################
if {[info exists DONT_TOUCH_INST] && $DONT_TOUCH_INST != ""} {
    foreach _inst $DONT_TOUCH_INST {
        if {[info exists ::synopsys_program_name] && $synopsys_program_name != "pt_shell"} {
            if {[sizeof_collection [get_cells -hierarchical -filter "full_name =~ $_inst "]] > 0} {
                puts "-I- setting dont touch on inst  $_inst"
                set_dont_touch [get_cells -hierarchical -filter "full_name =~ $_inst "]
                #----------------------------------------------------------------------------
                #   remove dont touch from unloaded object
                #----------------------------------------------------------------------------
                foreach_in_collection III [get_cells -hierarchical -filter "full_name =~ $_inst"] {
                    set output_pins [get_pins -of $III -filter "direction == out"]
                    if { [get_nets -of_object $output_pins] == ""} {
                        puts "-W- Found unloaded [get_object_name $III],remove dont touch attribute from it"
                        set_dont_touch $III false
                    }
                }
            } else {
                puts  "-W- $_inst from DONT_TOUCH_INST list, does not exists in design"
            }
        } else {
            if {[sizeof_collection [get_cells -quiet -hier $_inst]] > 0} {
                if {![info exists ::synopsys_program_name]} {
                    puts "-I- setting dont touch on inst  $_inst"
                    if {[get_db / .program_short_name] == "genus"} {
                        set_db [get_db insts $_inst] .dont_touch true
                    } elseif {[get_db / .program_short_name] == "innovus"} {
                        set_db [get_db insts  -if {.name == $_inst}] .is_dont_touch true
                    }
                    #----------------------------------------------------------------------------
                    #   remove dont touch from unloaded object
                    #----------------------------------------------------------------------------
                    foreach_in_collection III [get_cells -hierarchical -filter "full_name =~ $_inst"] {
                        set output_pins [get_pins -of $III -filter "direction == out"]
                        if { [get_nets -of_object $output_pins] == ""} {
                            puts "-W- Found unloaded [get_object_name $III],remove dont touch attribute from it"
                            if {[get_db / .program_short_name] == "genus"} {
                                set_db [get_db insts [get_object_name $III]  ] .dont_touch false
                            } elseif {[get_db / .program_short_name] == "innovus"} {
                                set_db [get_db insts [get_object_name $III]  ] .is_dont_touch false
                            }
                        }
                    }
                }
            } else {
                puts  "-W- $_inst from DONT_TOUCH_INST list, does not exists in design"
            }
        }
    }
    if {[info exists ::synopsys_program_name] && $synopsys_program_name != "pt_shell"} {
        report_dont_touch > reports/report_dont_touch.rpt
    }
}

#############################################################################
#	dont touch net
#############################################################################
if {[info exists DONT_TOUCH_NET] && $DONT_TOUCH_NET != ""} {
	puts "-I- setting dont touch on nets  $DONT_TOUCH_NET"
	if {![info exists ::synopsys_program_name]} {
	   if {[get_db / .program_short_name] == "genus"} {
		foreach _net $DONT_TOUCH_NET {
			set_db net:$_net .dont_touch true
		}
	   }
	} else {
	   foreach _net $DONT_TOUCH_NET {
	   	set_dont_touch $_net
	   }
	}
}

#############################################################################
#	no ungroups module
#############################################################################
if {[info exists NO_UNGROUP_MODULE] && $NO_UNGROUP_MODULE != ""} {
	puts "-I- setting ungroup false on modules  $NO_UNGROUP_MODULE"
	if {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "genus"} {
		foreach _module $NO_UNGROUP_MODULE {
			set_db hinst:$_module .ungroup_ok false
		}
	} elseif {[info exists ::synopsys_program_name] && $synopsys_program_name != "pt_shell"} {
		puts "-I- setting ungroup false on modules  $NO_UNGROUP_MODULE"
		foreach _module $NO_UNGROUP_MODULE {
#			set_dont_touch $_module
			set_ungroup $_module false
		}
	}
}


#############################################################################
#	dft dont scan
#############################################################################
if {[info exists DONT_SCAN_FF] && $DONT_SCAN_FF != ""} {
	puts "-I- setting non scan element ff:  $DONT_SCAN_FF"
	if {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "genus"} {
		foreach _inst $DONT_SCAN_FF {
			set_db [get_db insts $_inst] .dft_dont_scan true
		}
	}
}

#############################################################################
#	Exclude ICG 
#############################################################################
if {[info exists EXCLUDE_ICG] && $EXCLUDE_ICG != ""} {
    foreach inst $EXCLUDE_ICG {
	puts "-I- setting exclude ICG for instance $inst"
        if {![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "genus"} {
            if {$inst == "IO" || $inst == "INPUT" || $inst == "io" || $inst == "input"  } {
	       set clk_port ""
	       foreach_in_collection clk_ [get_clocks] {
	          set clk_port "$clk_port [get_db [get_clocks $clk_] .sources.name]"
	       }
	       set ckg_exclude [get_db [all_fanout -from [remove_from_collection [get_ports -filter "direction == in"] [get_ports $clk_port]] -endpoints_only -flat -only_cells ] -if ".obj_type==inst"]
               set_db [get_db insts $ckg_exclude] .lp_clock_gating_exclude true
	    } elseif { [regex {^port:(\S+)} $inst match port]} {
	       set clk_port ""
	       foreach_in_collection clk_ [get_clocks] {
	          set clk_port "$clk_port [get_db [get_clocks $clk_] .sources.name]"
	       }
	       set ckg_exclude [get_db [all_fanout -from [remove_from_collection [get_ports $port -filter "direction == in"] [get_ports $clk_port]] -endpoints_only -flat -only_cells ] -if ".obj_type==inst"]
               set_db [get_db insts $ckg_exclude] .lp_clock_gating_exclude true
	    } else {
               set_db [get_db insts $EXCLUDE_ICG] .lp_clock_gating_exclude true
            }
        } elseif {[info exists ::synopsys_program_name]} {
            if {$inst == "IO" || $inst == "INPUT" || $inst == "io" || $inst == "input"  } {
	        set clk_port [get_attribute [get_clocks grid_clk] sources]
	        set_clock_gating_enable -exclude [remove_from_collection [get_ports       -filter "direction == in"] $clk_port]
            } elseif {[regex {^port:(\S+)} $inst match port]} {
	        set clk_port [get_attribute [get_clocks grid_clk] sources]
	        set_clock_gating_enable -exclude [remove_from_collection [get_ports $port -filter "direction == in"] $clk_port]
            } else {
	        if {[regexp {\*} $inst]} {
	            set_clock_gating_enable -exclude [get_cells -hierarchical $inst]
		} else {
	            set_clock_gating_enable -exclude [get_cells  $inst]
		}
	    } 
	} 
    }
}






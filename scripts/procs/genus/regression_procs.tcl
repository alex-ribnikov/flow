#---------------------------------------------------
# METRIC PROCS
#---------------------------------------------------

# Check_timing
proc get_unconnected_or_logic_driven_clocks { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Unconnected/logic driven clocks[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_sequential_data_pins_driven_by_a_clock_signal { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Sequential data pins driven by a clock signal[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_sequential_clock_pins_without_clock_waveform { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Sequential clock pins without clock waveform[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_sequential_clock_pins_with_multiple_clock_waveforms { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Sequential clock pins with multiple clock waveforms[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_generated_clocks_without_clock_waveform { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Generated clocks without clock waveform[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_generated_clocks_with_incompatible_options { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Generated clocks with incompatible options[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_generated_clocks_with_multi_master_clock { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Generated clocks with multi-master clock[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_paths_constrained_with_different_clocks { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Paths constrained with different clocks[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_loop_breaking_cells_for_combinational_feedback { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Loop-breaking cells for combinational feedback[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_nets_with_multiple_drivers { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Nets with multiple drivers[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_timing_exceptions_with_no_effect { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Timing exceptions with no effect[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_suspicious_multi_cycle_exceptions { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Suspicious multi_cycle exceptions[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_pins_ports_with_conflicting_case_constants { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Pins/ports with conflicting case constants[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_inputs_without_clocked_external_delays { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Inputs without clocked external delays[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_outputs_without_clocked_external_delays { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Outputs without clocked external delays[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_inputs_without_external_driver_transition { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Inputs without external driver/transition[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_outputs_without_external_load { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Outputs without external load[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_exceptions_with_invalid_timing_start_endpoints { } {
set file_r [open [file join [get_db flow_report_directory]/check_timing.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Exceptions with invalid timing start-/endpoints[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}


# Check_design
proc get_unresolved_references { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Unresolved References[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_empty_modules { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Empty Modules[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_unloaded_port { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Unloaded Port\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_unloaded_sequential_pin { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Unloaded Sequential Pin\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_unloaded_combinational_pin { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Unloaded Combinational Pin\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_assigns { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Assigns[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_undriven_port { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Undriven Port\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_undriven_leaf_pin { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Undriven Leaf Pin\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_undriven_hierarchical_pin { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Undriven hierarchical pin\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_multidriven_port { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Multidriven Port\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_multidriven_leaf_pin { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Multidriven Leaf Pin\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_multidriven_hierarchical_pin { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Multidriven hierarchical Pin\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_multidriven_unloaded_net { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Multidriven unloaded net\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_constant_port { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Constant Port\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}
proc get_constant_leaf_pin { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Constant Leaf Pin\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}
proc get_constant_hierarchical_pin { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Constant hierarchical Pin\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}
proc get_preserved_leaf_instance { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Preserved leaf instance\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_preserved_hierarchical_instance { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Preserved hierarchical instance\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_libcells_with_no_lef_cell { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Libcells with no LEF cell[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_physical_cells_with_no_libcell { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Physical (LEF) cells with no libcell[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_subdesigns_with_long_module_name { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Subdesigns with long module name[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_physical_only_instance { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Physical only instance\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

proc get_logical_only_instance { } {
set file_r [open [file join [get_db flow_report_directory]/check_design.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {Logical only instance\(s\)[ \t]+([0-9]+)} $line match number]} {return $number}
  }
}

# Timing constraints
proc get_all_inputs { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"all_inputs\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_all_outputs { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"all_outputs\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_create_clock { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"create_clock\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_current_design { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"current_design\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_get_clocks { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"get_clocks\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_get_pins { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"get_pins\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_get_cells { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"get_cells\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_get_ports { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"get_ports\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_set_clock_latency { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"set_clock_latency\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_set_clock_uncertainty { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"set_clock_uncertainty\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_set_false_path { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"set_false_path\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_set_input_delay { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"set_input_delay\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_set_disable_timing { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"set_disable_timing\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_set_max_capacitance { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"set_max_capacitance\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_set_max_transition { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"set_max_transition\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_set_multicycle_path { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"set_multicycle_path\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_set_output_delay { } {
set file_r [open [file join [get_db flow_report_directory]/timing_constraints.rpt] r]
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {\"set_output_delay\"[ \t]+- successful[ \t]+([0-9]+) , failed[ \t]+([0-9]+) \(runtime} $line match successful failed]} {return "$successful $failed"}
  }
}

proc get_sequential_deleted_unloaded { } {
if {[file exists [file join [get_db flow_report_directory]/sequential_deleted.rpt]]} {
  set file_r [open [file join [get_db flow_report_directory]/sequential_deleted.rpt] r]
    while {![eof $file_r]} {
      set line [gets $file_r]
      if {[regexp {for \"unloaded\" reason\:[ \t]+([0-9]+)} $line match number]} {return $number}
    }
  } else {
    return "not_ran"
  }
}

proc get_sequential_deleted_merged { } {
if {[file exists [file join [get_db flow_report_directory]/sequential_deleted.rpt]]} {
  set file_r [open [file join [get_db flow_report_directory]/sequential_deleted.rpt] r]
    while {![eof $file_r]} {
      set line [gets $file_r]
      if {[regexp {for \"merged\" reason\:[ \t]+([0-9]+)} $line match number]} {return $number}
    }
  } else {
    return "not_ran"
  }
}

proc get_sequential_deleted_constant_0 { } {
if {[file exists [file join [get_db flow_report_directory]/sequential_deleted.rpt]]} {
  set file_r [open [file join [get_db flow_report_directory]/sequential_deleted.rpt] r]
    while {![eof $file_r]} {
      set line [gets $file_r]
      if {[regexp {for \"constant 0\" reason\:[ \t]+([0-9]+)} $line match number]} {return $number}
    }
  } else {
    return "not_ran"
  }
}

proc get_sequential_deleted_constant_1 { } {
if {[file exists [file join [get_db flow_report_directory]/sequential_deleted.rpt]]} {
  set file_r [open [file join [get_db flow_report_directory]/sequential_deleted.rpt] r]
    while {![eof $file_r]} {
      set line [gets $file_r]
      if {[regexp {for \"constant 1\" reason\:[ \t]+([0-9]+)} $line match number]} {return $number}
    }
  } else {
    return "not_ran"
  }
}


proc custom_metrics { } {
  define_metric -name design.timing_constraints.all_inputs_successful -tcl "join [lindex [get_all_inputs] 0]"
  define_metric -name design.timing_constraints.all_inputs_failed -tcl "join [lindex [get_all_inputs] 1]"
  define_metric -name design.timing_constraints.all_outputs_successful -tcl "join [lindex [get_all_outputs] 0]"
  define_metric -name design.timing_constraints.all_outputs_failed -tcl "join [lindex [get_all_outputs] 1]"
  define_metric -name design.timing_constraints.create_clock_successful -tcl "join [lindex [get_create_clock] 0]"
  define_metric -name design.timing_constraints.create_clock_failed -tcl "join [lindex [get_create_clock] 1]"
  define_metric -name design.timing_constraints.current_design_successful -tcl "join [lindex [get_current_design] 0]"
  define_metric -name design.timing_constraints.current_design_failed -tcl "join [lindex [get_current_design] 1]"
  define_metric -name design.timing_constraints.get_clocks_successful -tcl "join [lindex [get_get_clocks] 0]"
  define_metric -name design.timing_constraints.get_clocks_failed -tcl "join [lindex [get_get_clocks] 1]"
  define_metric -name design.timing_constraints.get_pins_successful -tcl "join [lindex [get_get_pins] 0]"
  define_metric -name design.timing_constraints.get_pins_failed -tcl "join [lindex [get_get_pins] 1]"
  define_metric -name design.timing_constraints.get_cells_successful -tcl "join [lindex [get_get_cells] 0]"
  define_metric -name design.timing_constraints.get_cells_failed -tcl "join [lindex [get_get_cells] 1]"
  define_metric -name design.timing_constraints.get_ports_successful -tcl "join [lindex [get_get_ports] 0]"
  define_metric -name design.timing_constraints.get_ports_failed -tcl "join [lindex [get_get_ports] 1]"
  define_metric -name design.timing_constraints.set_clock_latency_successful -tcl "join [lindex [get_set_clock_latency] 0]"
  define_metric -name design.timing_constraints.set_clock_latency_failed -tcl "join [lindex [get_set_clock_latency] 1]"
  define_metric -name design.timing_constraints.set_clock_uncertainty_successful -tcl "join [lindex [get_set_clock_uncertainty] 0]"
  define_metric -name design.timing_constraints.set_clock_uncertainty_failed -tcl "join [lindex [get_set_clock_uncertainty] 1]"
  define_metric -name design.timing_constraints.set_false_path_successful -tcl "join [lindex [get_set_false_path] 0]"
  define_metric -name design.timing_constraints.set_false_path_failed -tcl "join [lindex [get_set_false_path] 1]"
  define_metric -name design.timing_constraints.set_input_delay_successful -tcl "join [lindex [get_set_input_delay] 0]"
  define_metric -name design.timing_constraints.set_input_delay_failed -tcl "join [lindex [get_set_input_delay] 1]"
  define_metric -name design.timing_constraints.set_disable_timing_successful -tcl "join [lindex [get_set_disable_timing] 0]"
  define_metric -name design.timing_constraints.set_disable_timing_failed -tcl "join [lindex [get_set_disable_timing] 1]"
  define_metric -name design.timing_constraints.set_max_capacitance_successful -tcl "join [lindex [get_set_max_capacitance] 0]"
  define_metric -name design.timing_constraints.set_max_capacitance_failed -tcl "join [lindex [get_set_max_capacitance] 1]"
  define_metric -name design.timing_constraints.set_max_transition_successful -tcl "join [lindex [get_set_max_transition] 0]"
  define_metric -name design.timing_constraints.set_max_transition_failed -tcl "join [lindex [get_set_max_transition] 1]"
  define_metric -name design.timing_constraints.set_multicycle_path_successful -tcl "join [lindex [get_set_multicycle_path] 0]"
  define_metric -name design.timing_constraints.set_multicycle_path_failed -tcl "join [lindex [get_set_multicycle_path] 1]"
  define_metric -name design.timing_constraints.set_output_delay_successful -tcl "join [lindex [get_set_output_delay] 0]"
  define_metric -name design.timing_constraints.set_output_delay_failed -tcl "join [lindex [get_set_output_delay] 1]"

  define_metric -name design.check_timing.unconnected_or_logic_driven_clocks -tcl get_unconnected_or_logic_driven_clocks
  define_metric -name design.check_timing.sequential_data_pins_driven_by_a_clock_signal -tcl get_sequential_data_pins_driven_by_a_clock_signal
  define_metric -name design.check_timing.sequential_clock_pins_without_clock_waveform -tcl get_sequential_clock_pins_without_clock_waveform
  define_metric -name design.check_timing.sequential_clock_pins_with_multiple_clock_waveforms -tcl get_sequential_clock_pins_with_multiple_clock_waveforms
  define_metric -name design.check_timing.generated_clocks_without_clock_waveform -tcl get_generated_clocks_without_clock_waveform
  define_metric -name design.check_timing.generated_clocks_with_incompatible_options -tcl get_generated_clocks_with_incompatible_options
  define_metric -name design.check_timing.generated_clocks_with_multi_master_clock -tcl get_generated_clocks_with_multi_master_clock
  define_metric -name design.check_timing.paths_constrained_with_different_clocks -tcl get_paths_constrained_with_different_clocks
  define_metric -name design.check_timing.loop_breaking_cells_for_combinational_feedback -tcl get_loop_breaking_cells_for_combinational_feedback
  define_metric -name design.check_timing.nets_with_multiple_drivers -tcl get_nets_with_multiple_drivers
  define_metric -name design.check_timing.timing_exceptions_with_no_effect -tcl get_timing_exceptions_with_no_effect
  define_metric -name design.check_timing.suspicious_multi_cycle_exceptions -tcl get_suspicious_multi_cycle_exceptions
  define_metric -name design.check_timing.pins_ports_with_conflicting_case_constants -tcl get_pins_ports_with_conflicting_case_constants
#   define_metric -name design.check_timing.inputs_without_clocked_external_delays -tcl get_inputs_without_clocked_external_delays
#   define_metric -name design.check_timing.outputs_without_clocked_external_delays -tcl get_outputs_without_clocked_external_delays
#   define_metric -name design.check_timing.inputs_without_external_driver_transition -tcl get_inputs_without_external_driver_transition
#   define_metric -name design.check_timing.outputs_without_external_load -tcl get_outputs_without_external_load
  define_metric -name design.check_timing.exceptions_with_invalid_timing_start_endpoints -tcl get_exceptions_with_invalid_timing_start_endpoints

  define_metric -name design.check_design.unresolved_references -tcl get_unresolved_references
  define_metric -name design.check_design.empty_modules -tcl get_empty_modules
  define_metric -name design.check_design.unloaded_port -tcl get_unloaded_port
#   define_metric -name design.check_design.unloaded_sequential_pin -tcl get_unloaded_sequential_pin
#   define_metric -name design.check_design.unloaded_combinational_pin -tcl get_unloaded_combinational_pin
#   define_metric -name design.check_design.assigns -tcl get_assigns
  define_metric -name design.check_design.undriven_port -tcl get_undriven_port
  define_metric -name design.check_design.undriven_leaf_pin -tcl get_undriven_leaf_pin
  define_metric -name design.check_design.undriven_hierarchical_pin -tcl get_undriven_hierarchical_pin
  define_metric -name design.check_design.multidriven_port -tcl get_multidriven_port
  define_metric -name design.check_design.multidriven_leaf_pin -tcl get_multidriven_leaf_pin
  define_metric -name design.check_design.multidriven_hierarchical_pin -tcl get_multidriven_hierarchical_pin
  define_metric -name design.check_design.multidriven_unloaded_net -tcl get_multidriven_unloaded_net
#   define_metric -name design.check_design.constant_port -tcl get_constant_port
#   define_metric -name design.check_design.constant_leaf_pin -tcl get_constant_leaf_pin
#   define_metric -name design.check_design.constant_hierarchical_pin -tcl get_constant_hierarchical_pin
  define_metric -name design.check_design.preserved_leaf_instance -tcl get_preserved_leaf_instance
  define_metric -name design.check_design.preserved_hierarchical_instance -tcl get_preserved_hierarchical_instance
#   define_metric -name design.check_design.libcells_with_no_lef_cell -tcl get_libcells_with_no_lef_cell
#   define_metric -name design.check_design.physical_cells_with_no_libcell -tcl get_physical_cells_with_no_libcell
#   define_metric -name design.check_design.subdesigns_with_long_module_name -tcl get_subdesigns_with_long_module_name
#   define_metric -name design.check_design.physical_only_instance -tcl get_physical_only_instance
#   define_metric -name design.check_design.logical_only_instance -tcl get_logical_only_instance

  define_metric -name design.report_sequential.sequential_deleted_unloaded   -tcl get_sequential_deleted_unloaded
  define_metric -name design.report_sequential.sequential_deleted_merged     -tcl get_sequential_deleted_merged
  define_metric -name design.report_sequential.sequential_deleted_constant_0 -tcl get_sequential_deleted_constant_0
  define_metric -name design.report_sequential.sequential_deleted_constant_1 -tcl get_sequential_deleted_constant_1


  define_metric -name design.timing_constraints.report_path
  if {[get_db flow_run_tag] != ""} {
    set_metric -name design.timing_constraints.report_path -value [get_db user_reports_dir]/timing_constraints.rpt
  } else {
    set_metric -name design.timing_constraints.report_path -value [get_db user_reports_dir]/timing_constraints.rpt
  } 

  define_metric -name design.check_timing.report_path
  if {[get_db flow_run_tag] != ""} {
    set_metric -name design.check_timing.report_path -value [get_db user_reports_dir]/check_timing_verbose.rpt
  } else {
    set_metric -name design.check_timing.report_path -value [get_db user_reports_dir]/check_timing_verbose.rpt
  } 

  define_metric -name design.check_design.report_path
  if {[get_db flow_run_tag] != ""} {
    set_metric -name design.check_design.report_path -value [get_db user_reports_dir]/check_design_verbose.rpt
  } else {
    set_metric -name design.check_design.report_path -value [get_db user_reports_dir]/check_design_verbose.rpt
  } 

  define_metric -name design.report_sequential.report_path
  if {[get_db flow_run_tag] != ""} {
    set_metric -name design.report_sequential.report_path -value [get_db user_reports_dir]/sequential_deleted_verbose.rpt
  } else {
    set_metric -name design.report_sequential.report_path -value [get_db user_reports_dir]/sequential_deleted_verbose.rpt
  } 

  if {![regexp {User} [dict key [get_metric_config]]]} {
    create_metric_page -name User
    
    create_metric_table_heading \
     -id heading_timing_constraints_failed -page User \
     -title "timing_constraints_failed statistics"
    create_metric_table \
     -id table_timing_constraints_failed -heading heading_timing_constraints_failed \
     -per_snapshot -type vertical

    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.all_inputs_failed \
     -group "timing_constraints_failed statistics" -title all_inputs_failed
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.all_outputs_failed \
     -group "timing_constraints_failed statistics" -title all_outputs_failed
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.create_clock_failed \
     -group "timing_constraints_failed statistics" -title create_clock_failed
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.current_design_failed \
     -group "timing_constraints_failed statistics" -title current_design_failed
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.get_clocks_failed \
     -group "timing_constraints_failed statistics" -title get_clocks_failed
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.get_cells_failed \
     -group "timing_constraints_failed statistics" -title get_cells_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.get_pins_failed \
     -group "timing_constraints_failed statistics" -title get_pins_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.get_ports_failed \
     -group "timing_constraints_failed statistics" -title get_ports_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.set_clock_latency_failed \
     -group "timing_constraints_failed statistics" -title set_clock_latency_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.set_clock_uncertainty_failed \
     -group "timing_constraints_failed statistics" -title set_clock_uncertainty_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.set_false_path_failed \
     -group "timing_constraints_failed statistics" -title set_false_path_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.set_input_delay_failed \
     -group "timing_constraints_failed statistics" -title set_input_delay_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.set_disable_timing_failed \
     -group "timing_constraints_failed statistics" -title set_disable_timing_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.set_max_capacitance_failed \
     -group "timing_constraints_failed statistics" -title set_max_capacitance_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.set_max_transition_failed \
     -group "timing_constraints_failed statistics" -title set_max_transition_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.set_multicycle_path_failed \
     -group "timing_constraints_failed statistics" -title set_multicycle_path_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.set_output_delay_failed \
     -group "timing_constraints_failed statistics" -title set_output_delay_failed 
    update_metric -table table_timing_constraints_failed -metric design.timing_constraints.report_path \
     -group "timing_constraints_failed statistics" -title "Timing constraints report" 

    create_metric_table_heading \
     -id heading_timing_constraints_sucessful -page User \
     -title "timing_constraints_sucessful statistics"
    create_metric_table \
     -id table_timing_constraints_sucessful -heading heading_timing_constraints_sucessful \
     -per_snapshot -type vertical

    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.all_inputs_successful \
     -group "timing_constraints_siccessful statistics" -title all_inputs_successful
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.all_outputs_successful \
     -group "timing_constraints_successful statistics" -title all_outputs_successful
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.create_clock_successful \
     -group "timing_constraints_successful statistics" -title create_clock_successful
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.current_design_successful \
     -group "timing_constraints_successful statistics" -title current_design_successful
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.get_clocks_successful \
     -group "timing_constraints_successful statistics" -title get_clocks_successful
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.get_cells_successful \
     -group "timing_constraints_successful statistics" -title get_cells_successful
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.get_pins_successful \
     -group "timing_constraints_successful statistics" -title get_pins_successful
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.get_ports_successful \
     -group "timing_constraints_successful statistics" -title get_ports_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.set_clock_latency_successful \
     -group "timing_constraints_successful statistics" -title set_clock_latency_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.set_clock_uncertainty_successful \
     -group "timing_constraints_successful statistics" -title set_clock_uncertainty_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.set_false_path_successful \
     -group "timing_constraints_successful statistics" -title set_false_path_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.set_input_delay_successful \
     -group "timing_constraints_successful statistics" -title set_input_delay_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.set_disable_timing_successful \
     -group "timing_constraints_successful statistics" -title set_disable_timing_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.set_max_capacitance_successful \
     -group "timing_constraints_successful statistics" -title set_max_capacitance_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.set_max_transition_successful \
     -group "timing_constraints_successful statistics" -title set_max_transition_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.set_multicycle_path_successful \
     -group "timing_constraints_successful statistics" -title set_multicycle_path_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.set_output_delay_successful \
     -group "timing_constraints_successful statistics" -title set_output_delay_successful 
    update_metric -table table_timing_constraints_sucessful -metric design.timing_constraints.report_path \
     -group "timing_constraints_successful statistics" -title "Timing constraints report" 

    create_metric_table_heading \
     -id heading_check_timing -page User \
     -title "check_timing statistics"
    create_metric_table \
     -id table_check_timing -heading heading_check_timing \
     -per_snapshot -type vertical

    update_metric -table table_check_timing -metric design.check_timing.unconnected_or_logic_driven_clocks \
     -group "check_timing statistics" -title unconnected_or_logic_driven_clocks
    update_metric -table table_check_timing -metric design.check_timing.sequential_data_pins_driven_by_a_clock_signal \
     -group "check_timing statistics" -title sequential_data_pins_driven_by_a_clock_signal
    update_metric -table table_check_timing -metric design.check_timing.sequential_clock_pins_without_clock_waveform \
     -group "check_timing statistics" -title sequential_clock_pins_without_clock_waveform
    update_metric -table table_check_timing -metric design.check_timing.sequential_clock_pins_with_multiple_clock_waveforms \
     -group "check_timing statistics" -title sequential_clock_pins_with_multiple_clock_waveforms 
    update_metric -table table_check_timing -metric design.check_timing.generated_clocks_without_clock_waveform \
     -group "check_timing statistics" -title generated_clocks_without_clock_waveform 
    update_metric -table table_check_timing -metric design.check_timing.generated_clocks_with_incompatible_options \
     -group "check_timing statistics" -title generated_clocks_with_incompatible_options 
    update_metric -table table_check_timing -metric design.check_timing.generated_clocks_with_multi_master_clock \
     -group "check_timing statistics" -title generated_clocks_with_multi_master_clock 
    update_metric -table table_check_timing -metric design.check_timing.paths_constrained_with_different_clocks \
     -group "check_timing statistics" -title paths_constrained_with_different_clocks 
    update_metric -table table_check_timing -metric design.check_timing.loop_breaking_cells_for_combinational_feedback \
     -group "check_timing statistics" -title loop_breaking_cells_for_combinational_feedback 
    update_metric -table table_check_timing -metric design.check_timing.nets_with_multiple_drivers \
     -group "check_timing statistics" -title nets_with_multiple_drivers 
    update_metric -table table_check_timing -metric design.check_timing.timing_exceptions_with_no_effect \
     -group "check_timing statistics" -title timing_exceptions_with_no_effect 
    update_metric -table table_check_timing -metric design.check_timing.suspicious_multi_cycle_exceptions \
     -group "check_timing statistics" -title suspicious_multi_cycle_exceptions 
    update_metric -table table_check_timing -metric design.check_timing.pins_ports_with_conflicting_case_constants \
     -group "check_timing statistics" -title pins_ports_with_conflicting_case_constants 
#     update_metric -table table_check_timing -metric design.check_timing.inputs_without_clocked_external_delays \
#      -group "check_timing statistics" -title inputs_without_clocked_external_delays 
#     update_metric -table table_check_timing -metric design.check_timing.outputs_without_clocked_external_delays \
#      -group "check_timing statistics" -title outputs_without_clocked_external_delays 
#     update_metric -table table_check_timing -metric design.check_timing.inputs_without_external_driver_transition \
#      -group "check_timing statistics" -title inputs_without_external_driver_transition 
#     update_metric -table table_check_timing -metric design.check_timing.outputs_without_external_load \
#      -group "check_timing statistics" -title outputs_without_external_load 
    update_metric -table table_check_timing -metric design.check_timing.exceptions_with_invalid_timing_start_endpoints \
     -group "check_timing statistics" -title exceptions_with_invalid_timing_start_endpoints 
    update_metric -table table_check_timing -metric design.check_timing.report_path \
     -group "check_timing statistics" -title "Check timing report" 

    create_metric_table_heading \
     -id heading_check_design -page User \
     -title "check_design statistics"
    create_metric_table \
     -id table_check_design -heading heading_check_design \
     -per_snapshot -type vertical

    update_metric -table table_check_design -metric design.check_design.unresolved_references \
     -group "check_design statistics" -title unresolved_references
    update_metric -table table_check_design -metric design.check_design.empty_modules \
     -group "check_design statistics" -title empty_modules
    update_metric -table table_check_design -metric design.check_design.unloaded_port \
     -group "check_design statistics" -title unloaded_port
#     update_metric -table table_check_design -metric design.check_design.unloaded_sequential_pin \
#      -group "check_design statistics" -title unloaded_sequential_pin 
#     update_metric -table table_check_design -metric design.check_design.unloaded_combinational_pin \
#      -group "check_design statistics" -title unloaded_combinational_pin 
#     update_metric -table table_check_design -metric design.check_design.assigns \
#      -group "check_design statistics" -title assigns 
    update_metric -table table_check_design -metric design.check_design.undriven_port \
     -group "check_design statistics" -title undriven_port 
    update_metric -table table_check_design -metric design.check_design.undriven_leaf_pin \
     -group "check_design statistics" -title undriven_leaf_pin 
    update_metric -table table_check_design -metric design.check_design.undriven_hierarchical_pin \
     -group "check_design statistics" -title undriven_hierarchical_pin 
    update_metric -table table_check_design -metric design.check_design.multidriven_port \
     -group "check_design statistics" -title multidriven_port 
    update_metric -table table_check_design -metric design.check_design.multidriven_leaf_pin \
     -group "check_design statistics" -title multidriven_leaf_pin 
    update_metric -table table_check_design -metric design.check_design.multidriven_hierarchical_pin \
     -group "check_design statistics" -title multidriven_hierarchical_pin 
    update_metric -table table_check_design -metric design.check_design.multidriven_unloaded_net \
     -group "check_design statistics" -title multidriven_unloaded_net 
#     update_metric -table table_check_design -metric design.check_design.constant_port \
#      -group "check_design statistics" -title constant_port 
#     update_metric -table table_check_design -metric design.check_design.constant_leaf_pin \
#      -group "check_design statistics" -title constant_leaf_pin 
#     update_metric -table table_check_design -metric design.check_design.constant_hierarchical_pin \
#      -group "check_design statistics" -title constant_hierarchical_pin 
    update_metric -table table_check_design -metric design.check_design.preserved_leaf_instance \
     -group "check_design statistics" -title preserved_leaf_instance 
    update_metric -table table_check_design -metric design.check_design.preserved_hierarchical_instance \
     -group "check_design statistics" -title preserved_hierarchical_instance 
#     update_metric -table table_check_design -metric design.check_design.libcells_with_no_lef_cell \
#      -group "check_design statistics" -title libcells_with_no_lef_cell 
#     update_metric -table table_check_design -metric design.check_design.physical_cells_with_no_libcell \
#      -group "check_design statistics" -title physical_cells_with_no_libcell 
#     update_metric -table table_check_design -metric design.check_design.subdesigns_with_long_module_name \
#      -group "check_design statistics" -title subdesigns_with_long_module_name 
#     update_metric -table table_check_design -metric design.check_design.physical_only_instance \
#      -group "check_design statistics" -title physical_only_instance 
#     update_metric -table table_check_design -metric design.check_design.logical_only_instance \
#      -group "check_design statistics" -title logical_only_instance 
    update_metric -table table_check_design -metric design.check_design.report_path \
     -group "check_design statistics" -title "Check design report" 

    create_metric_table_heading \
     -id heading_report_sequential -page User \
     -title "report_sequential -deleted statistics"
    create_metric_table \
     -id table_report_sequential -heading heading_report_sequential \
     -per_snapshot -type vertical

    update_metric -table table_report_sequential -metric design.report_sequential.sequential_deleted_unloaded \
     -group "report_sequential -deleted statistics" -title "Sequential element deleted for \"unloaded\" reason" 
    update_metric -table table_report_sequential -metric design.report_sequential.sequential_deleted_merged \
     -group "report_sequential -deleted statistics" -title "Sequential element deleted for \"merged\" reason" 
    update_metric -table table_report_sequential -metric design.report_sequential.sequential_deleted_constant_0 \
     -group "report_sequential -deleted statistics" -title "Sequential element deleted for \"constant 0\" reason" 
    update_metric -table table_report_sequential -metric design.report_sequential.sequential_deleted_constant_1 \
     -group "report_sequential -deleted statistics" -title "Sequential element deleted for \"constant 1\" reason" 
    update_metric -table table_report_sequential -metric design.report_sequential.report_path \
     -group "report_sequential -deleted statistics" -title "report_sequential -deleted report" 
  }
}

#---------------------------------------------------
# REPORTS AND OTHERS
#---------------------------------------------------

proc report_mbff {} {
  report_multibit_inferencing  > [get_db user_stage_reports_dir]/mbff.rpt

  set sbff_cnt [lindex [get_metric design.instances.register] 1]
  set mbff_cell_list [get_db -unique  [get_db base_cells -if {.is_flop && .name==MB*} ] .name]
  set bit_list [lsort -u -integer -increasing [lsearch -all -inline -index 1 -subindices [lmap x $mbff_cell_list {regexp -all -inline -- {MB(\d+)} $x}] *]]
  
  set dict_bit_stat {}
  dict set dict_bit_stat mbff_count 0
  dict set dict_bit_stat total_bit_count 0
  foreach x $bit_list {
    dict set dict_bit_stat $x [llength [get_db -regexp [get_db insts -if {.is_flop}] .base_cell.name "^MB$x\\D"]]
    dict set dict_bit_stat mbff_count [expr [dict get $dict_bit_stat mbff_count] + [dict get $dict_bit_stat $x]]
    dict set dict_bit_stat total_bit_count [expr [dict get $dict_bit_stat total_bit_count] + $x * [dict get $dict_bit_stat $x]]
  }
  
  set total_ff_cnt [expr $sbff_cnt + [dict get $dict_bit_stat mbff_count]]
    
    
  set port [open [get_db user_stage_reports_dir]/mbff.rpt a]
  
  get_metric -names design.instances.register
  puts $port ""
  puts $port "------------------------------------------------------------"
  puts $port "        Current design flip-flop statistics"
  puts $port ""
  puts $port [format "Single-Bit FF Count  :%13s" $sbff_cnt]
  puts $port [format "Multi-Bit FF Count   :%13s" [dict get $dict_bit_stat mbff_count]]
  
  foreach x $bit_list {
     puts $port [format "-%2s-Bit FF Count     :%13s" $x [dict get $dict_bit_stat $x]]
  }
  
  puts $port [format "Total Bit Count      :%13s" [dict get $dict_bit_stat total_bit_count]]
  puts $port [format "Total FF Count       :%13s" $total_ff_cnt]
  
  if $total_ff_cnt {
    puts $port [format "Bits Per Flop        :%13.3f" [expr 1.0 * [dict get $dict_bit_stat total_bit_count] / $total_ff_cnt]]
  } else {
    puts $port [format "Bits Per Flop        :%13s" "NA"]
  }
  
  puts $port "------------------------------------------------------------"
  close $port

}


proc gen_dummy_liberty {netlist_file liberty_file module_name} {
  set file_r [open $netlist_file r]
  set file_w [open $liberty_file w]
  set record "false"
  set port_count "0"
  set verilog_line ""
  array unset port_table
  while {![eof $file_r]} {
    set line [gets $file_r]
    set line [regsub -all " +\\\\" $line " "]
    set line [regsub -all "," $line " "]    
    
    if {([regexp "^ +input " $line]) || ([regexp "^ +output " $line]) || ([regexp "^ +inout " $line])} {
      set record "true"
    }
    if { $record == "true" } {
      if {$verilog_line == ""} {
        set verilog_line $line
      } else {
        set verilog_line "$verilog_line $line"
      }
      if {[regexp {;} $line]} {
        
#puts "LINE: $verilog_line"        
        
        # Collect info in verilog file
        # puts $file_w $verilog_line
        set direction [lindex $verilog_line 0]
        if {[regexp {\[([0-9]+)\:([0-9]+)\]} [lindex $verilog_line 1] match upper_bit lower_bit]} {
          for {set i 2} {$i<[llength $verilog_line]} {incr i} {
            
            if { [lindex $verilog_line $i] == ";" } { continue }
            set port_table($port_count) "[regsub {,|;} [lindex $verilog_line $i] {}] $direction $upper_bit $lower_bit"
            
#            puts "1: [lindex $verilog_line $i] :: $port_table($port_count)"            
            
            incr port_count
          }
        } else {
          for {set i 1} {$i<[llength $verilog_line]} {incr i} {

            if { [lindex $verilog_line $i] == ";" } { continue }          
            set port_table($port_count) "[regsub {,|;} [lindex $verilog_line $i] {}] $direction single_bit single_bit"
            
#            puts "2: [lindex $verilog_line $i] :: $port_table($port_count)"            
            
            incr port_count
          }
        }


        # End collect info in verilog file
       
        set record "false"
        set verilog_line ""
      }
    }
  }
  
  puts $file_w "library \($module_name \)\{"
  puts $file_w "  delay_model : table_lookup;"
  puts $file_w "  date : \"No Date\" ;"
  puts $file_w "  revision : \"1.0\" ;"
  puts $file_w "  library_features(report_delay_calculation); "
  puts $file_w "  bus_naming_style : \"%s\[%d\]\" ;"
  puts $file_w "  comment : \"Generated By manual script\" ;"
  puts $file_w "  "
  puts $file_w "  /* unit attributes */"
  puts $file_w "  capacitive_load_unit ( 1.0000,pf);"
  puts $file_w "  current_unit : \"1mA\" ;"
  puts $file_w "  pulling_resistance_unit : \"1kohm\" ;"
  puts $file_w "  time_unit : \"1ns\" ;"
  puts $file_w "  voltage_unit : \"1V\" ;"
  puts $file_w "  leakage_power_unit : \"1nW\" ;"
  puts $file_w "  "
  puts $file_w "  /* threshold definitions */"
  puts $file_w "  input_threshold_pct_fall : 50.0000;"
  puts $file_w "  input_threshold_pct_rise : 50.0000;"
  puts $file_w "  output_threshold_pct_fall : 50.0000;"
  puts $file_w "  output_threshold_pct_rise : 50.0000;"
  puts $file_w "  slew_lower_threshold_pct_fall : 30.0000;"
  puts $file_w "  slew_lower_threshold_pct_rise : 30.0000;"
  puts $file_w "  slew_upper_threshold_pct_fall : 70.0000;"
  puts $file_w "  slew_upper_threshold_pct_rise : 70.0000;"
  puts $file_w "  slew_derate_from_library : 0.5000;"
  puts $file_w "  "
  puts $file_w "  /* operating conditions */"
  puts $file_w "  operating_conditions (ssgnp_0p675v_0c_cworst_CCworst_T ){"
  puts $file_w "    process :  1.0000;"
  puts $file_w "    temperature :  0.0000;"
  puts $file_w "    voltage :  0.6750;"
  puts $file_w "    tree_type :  \"balanced_tree\" ;"
  puts $file_w "  }"
  puts $file_w "  default_operating_conditions : \"ssgnp_0p675v_0c_cworst_CCworst_T\" ;"
  puts $file_w "  nom_process : 1.0000;"
  puts $file_w "  nom_temperature : 0.0000;"
  puts $file_w "  nom_voltage : 0.6750;"
  puts $file_w "  "
  puts $file_w "  /* default attributes */"
  puts $file_w "  default_fanout_load : 1.0000;"
  puts $file_w "  default_inout_pin_cap : 1.0000;"
  puts $file_w "  default_input_pin_cap : 1.0000;"
  puts $file_w "  default_output_pin_cap : 0.0000;"
  puts $file_w "  default_wire_load_area : 0.0000;"
  puts $file_w "  default_wire_load_capacitance : 0.0000;"
  puts $file_w "  default_wire_load_resistance : 3.7000;"
  puts $file_w "  k_process_cell_rise :  0.0000;"
  puts $file_w "  k_process_cell_fall :  0.0000;"
  puts $file_w "  k_volt_cell_rise :  0.0000;"
  puts $file_w "  k_volt_cell_fall :  0.0000;"
  puts $file_w "  k_temp_cell_rise :  0.0000;"
  puts $file_w "  k_temp_cell_fall :  0.0000;"
  puts $file_w "  k_process_rise_transition :  0.0000;"
  puts $file_w "  k_process_fall_transition :  0.0000;"
  puts $file_w "  k_volt_rise_transition :  0.0000;"
  puts $file_w "  k_volt_fall_transition :  0.0000;"
  puts $file_w "  k_temp_rise_transition :  0.0000;"
  puts $file_w "  k_temp_fall_transition :  0.0000;"
  puts $file_w "  "
  puts $file_w "  /* templates */"
  puts $file_w "  define( min_delay_arc , timing , boolean ) ;"
  puts $file_w "  "
  puts $file_w "  /* end of header section */"
  puts $file_w "  "
  puts $file_w "  cell ($module_name ) \{ "
  puts $file_w "    area :  0.0000;"
  puts $file_w "    dont_touch : true ;"
  puts $file_w "    dont_use : true ;"
  puts $file_w "    timing_model_type : extracted ;"
  puts $file_w "    is_macro_cell : true ;"
  puts $file_w "  "

  for {set i 0} {$i<$port_count} {incr i} {
    if {[lindex $port_table($i) 2] == "single_bit"} {
      puts $file_w "    pin ([lindex $port_table($i) 0]) \{"
      puts $file_w "      direction : [lindex $port_table($i) 1] ;"
      puts $file_w "      capacitance :  0.0000;"
      puts $file_w "    \}"
      puts $file_w ""
    } else {
      set bus_type bus_[lindex $port_table($i) 2]_[lindex $port_table($i) 3]
      if {![info exists bus_declared($bus_type)]} {
        set bus_declared($bus_type) 1
        puts $file_w "    type ($bus_type) \{"
        puts $file_w "      base_type : array ;"
        puts $file_w "      data_type : bit ;"
        puts $file_w "      bit_width :  [expr [lindex $port_table($i) 2] + 1];"
        puts $file_w "      bit_from :  [lindex $port_table($i) 2];"
        puts $file_w "      bit_to :  [lindex $port_table($i) 3];"
        puts $file_w "      downto : true ;"
        puts $file_w "    \}"
        puts $file_w ""
      }
      puts $file_w "    bus ([lindex $port_table($i) 0]) \{"
      puts $file_w "      bus_type :  $bus_type ;"
      puts $file_w ""
      for {set j [lindex $port_table($i) 3]} {$j<=[lindex $port_table($i) 2]} {incr j 1} {
        puts $file_w "      pin ([lindex $port_table($i) 0]\[$j\] ) \{"
        puts $file_w "        direction : [lindex $port_table($i) 1] ;"
        puts $file_w "        capacitance :  0.0000;"
        puts $file_w "      \}"
        puts $file_w ""      
      }
      puts $file_w "    \}"
      puts $file_w ""
    }
  }

  puts $file_w "  \} /* End of Design */"
  puts $file_w "  "
  puts $file_w "\} /* End of Library */"

  close $file_r
  close $file_w
  
}

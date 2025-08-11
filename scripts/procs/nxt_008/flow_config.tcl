# Flowkit v19.10-s009_1
################################################################################
# This file contains content which is used to customize the refererence flow
# process.  Commands such as 'create_flow', 'create_flow_step' and 'edit_flow'
# would be most prevalent.  For example:
#
# create_flow_step -name write_sdf -owner user -write_db {
#   write_sdf [get_db flow_report_directory]/[get_db flow_report_name].sdf
# }
#
# edit_flow -after flow_step:innovus_report_late_timing -append flow_step:write_sdf
#
################################################################################

################################################################################
# FLOW CPU AND HOST SETTINGS
################################################################################
create_flow_step -name init_mcpu -owner flow {
  # Multi host/cpu attributes
  #-----------------------------------------------------------------------------
  # The FLOWTOOL_NUM_CPUS is an environment variable which should be exported by
  # the specified dist script.  This connects the number of CPUs being reserved
  # for batch jobs with the current flow scripts.  The LSB_MAX_NUM_PROCESSORS is
  # a typical environment variable exported by distribution platforms and is
  # useful for ensuring all interactive jobs are using the reserved amount of CPUs.
  set max_cpus 8
  set_db max_cpus_per_server  $max_cpus
}
edit_flow -after Cadence.plugin.flowkit.read_db.pre -append flow_step:init_mcpu
edit_flow -after Cadence.plugin.flowkit.read_db.post -append flow_step:init_mcpu

##############################################################################
# STEP report_late_paths
##############################################################################
create_flow_step -name report_late_paths -owner flow -exclude_time_metric {
  #- Reports that show detailed timing with Graph Based Analysis (GBA)
  report_timing -max_paths 5   -nworst 1 -path_type endpoint        > [get_db flow_report_directory]/[get_db flow_report_name]/setup.endpoint.rpt
  report_timing -max_paths 1   -nworst 1 -path_type full_clock -net > [get_db flow_report_directory]/[get_db flow_report_name]/setup.worst.rpt
  report_timing -max_paths 500 -nworst 1 -path_type full_clock      > [get_db flow_report_directory]/[get_db flow_report_name]/setup.gba.rpt
  report_timing -max_paths 500 -nworst 1 -path_type full_clock -output_format gtd > [get_db flow_report_directory]/[get_db flow_report_name]/setup.gba.mtarpt
}

##############################################################################
# STEP report_area
##############################################################################
create_flow_step -name report_area -owner flow -exclude_time_metric {
  report_area  > [get_db flow_report_directory]/[get_db flow_report_name]/area.rpt
  
  set port [open [get_db flow_report_directory]/[get_db flow_report_name]/area.rpt a]
  puts $port ""
  puts $port "  ------------------------------------------------------------"
  puts $port "        Current design statistics"
  
  dict for {k v} [concat [get_metric design.area*] [get_metric design.instances*]] {
    puts $port "$k = $v"
  }
  close $port
}


##############################################################################
# STEP report_feedthrough
##############################################################################

create_flow_step -name report_feedthrough -owner flow -exclude_time_metric {
  proc inport { outport } {get_ports [all_fanin -to $outport -flat -startpoints_only] -quiet -filter "direction==in"}
  set port [open [get_db flow_report_directory]/[get_db flow_report_name]/feedthrough.rpt a]
  foreach outport [get_object_name [get_ports * -filter "direction==out"]] {if {[inport $outport] ne ""} {puts $port [format "%-20s %-20s" "[get_object_name [inport $outport]]" " --> $outport"]}}
  close $port

}

##############################################################################
# STEP report_unsampled_ports
##############################################################################

create_flow_step -name report_unsampled_ports -owner flow -exclude_time_metric {
  proc report_unsampled_ports { output } {

    set all_inputs  [all_inputs ]
    set all_outputs [all_outputs]    

    array unset ports_arr 
    foreach_in_collection port $all_inputs {
        set afo [get_db [all_fanout -from $port  -flat -only_cells] -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]
        if { [sizeof $afo] != 0 } { set ports_arr([get_object_name $port]) "[get_db $port .direction]\tUnsampled" } else { set ports_arr([get_object_name $port]) "[get_db $port .direction]\tSampled" }
    }

    foreach_in_collection port $all_outputs {
        set afi [get_db [all_fanin -to $port  -flat -only_cells] -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]
        if { [sizeof $afi] != 0 } { set ports_arr([get_object_name $port]) "[get_db $port .direction]\tUnsampled" } else { set ports_arr([get_object_name $port]) "[get_db $port .direction]\tSampled" }
    }
    
    if { $output == "" } {set output "unsampled_ports.rpt"}

    redirect $output {
    puts "[format %-50s Port_Name] [format %-10s Direction] Status"
    foreach port [lsort [array names ports_arr]] {
        lassign $ports_arr($port) dir status
        if { $status == "Sampled" } { continue }
        set port [string map {"{" "" "}" ""} $port]
        set line "[format %-50s $port] [format %-10s $dir] $status"
        puts $line
    }
    }
  }
  
  set output "[get_db flow_report_directory]/[get_db flow_report_name]/unsampled_ports.rpt"
  report_unsampled_ports $output	
}


##############################################################################
# STEP report_flops
##############################################################################
create_flow_step -name report_flops -owner flow -exclude_time_metric {
  report_sequential -hier > [get_db flow_report_directory]/[get_db flow_report_name]/flops.rpt.gz

#  set port [open [get_db flow_report_directory]/[get_db flow_report_name]/flops.rpt w]
#  get_db insts -if {.is_flop && !.is_integrated_clock_gating } -foreach {puts $port $obj(.name)}
#  close $port
}

##############################################################################
# STEP report_mbff
##############################################################################
create_flow_step -name report_mbff -owner flow -exclude_time_metric {
  report_multibit_inferencing  > [get_db flow_report_directory]/[get_db flow_report_name]/mbff.rpt

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
    
    
  set port [open [get_db flow_report_directory]/[get_db flow_report_name]/mbff.rpt a]
  
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

##############################################################################
# STEP write_elaborated_netlist
##############################################################################
create_flow_step -name write_elaborated_netlist -owner user {
  write_hdl $design_name > [get_db flow_db_directory]/${block_name}_elaborated.v
}
create_flow_step -name generate_mapped_netlist -owner user {
  write_hdl $design_name > [get_db flow_db_directory]/${block_name}_mapped.v
}
create_flow_step -name update_submodule_names -owner user {
  update_names -module -prefix ${design_name}_ [current_design]
}

create_flow_step -name reload_timing_constraints -owner user {
  if {[regexp {no_sdc} $sdc_relative_path]} {
    catch {exec touch empty.sdc}
    set constraint_mode_sdc empty.sdc
  } else {
    set constraint_mode_sdc $nextinside_path/$sdc_relative_path
  }
  redirect [file join [get_db flow_report_directory]/timing_constraints.rpt] "update_constraint_mode -name [get_db constraint_modes .name] -sdc_files $constraint_mode_sdc"
}

create_flow_step -name check_design -owner user {
  check_design -undriven -unloaded -multiple_driver -unresolved > [file join [get_db flow_report_directory] check_design_verbose.rpt]
  check_design > [file join [get_db flow_report_directory] check_design.rpt]
  
  puts "executing [get_db flow_source_directory]/run_rtl2be_waivers.tcl -inplace -report_dir [get_db flow_report_directory] -check_design_waiver_file [file normalize $check_design_waivers]"
  exec [get_db flow_source_directory]/run_rtl2be_waivers.tcl -inplace -report_dir [get_db flow_report_directory] -check_design_waiver_file [file normalize $check_design_waivers]
}

create_flow_step -name check_timing -owner user {
  check_timing_intent -verbose > [file join [get_db flow_report_directory] check_timing_verbose.rpt]
  
  puts "executing [get_db flow_source_directory]/run_rtl2be_waivers.tcl -inplace -report_dir [get_db flow_report_directory] -check_timing_waiver_file [file normalize $check_timing_waivers]"
  exec [get_db flow_source_directory]/run_rtl2be_waivers.tcl -inplace -report_dir [get_db flow_report_directory] -check_timing_waiver_file [file normalize $check_timing_waivers]
}

create_flow_step -name check_sequential_deleted -owner user {
  redirect [file join [get_db flow_report_directory]/sequential_deleted_verbose.rpt] "report_sequential -deleted"

  set file_r [open [file join [get_db flow_report_directory] sequential_deleted_verbose.rpt] r]
  set file_w [open [file join [get_db flow_report_directory] sequential_deleted.rpt] w]
  set write_in_file_w "false"
  set nb_unloaded 0
  set nb_constant_0 0
  set nb_constant_1 0
  set nb_merged 0
  while {![eof $file_r]} {
    set line [gets $file_r]
    if {[regexp {^   Reason} $line]} {
      set write_in_file_w "true"
    }
    if {$write_in_file_w} {
      if {[regexp {^unloaded} $line]} {
        incr nb_unloaded
      }
      if {[regexp {^constant 0} $line]} {
        incr nb_constant_0
      }
      if {[regexp {^constant 1} $line]} {
        incr nb_constant_1
      }
      if {[regexp {^merged} $line]} {
        incr nb_merged
      }
    }
  }
  close $file_r
  puts $file_w "report_sequential -deleted summary:"
  puts $file_w "  Sequential element deleted for \"unloaded\" reason:   $nb_unloaded"
  puts $file_w "  Sequential element deleted for \"merged\" reason:     $nb_merged"
  puts $file_w "  Sequential element deleted for \"constant 0\" reason: $nb_constant_0"
  puts $file_w "  Sequential element deleted for \"constant 1\" reason: $nb_constant_1"
  close $file_w

}

create_flow_step -name custom_metrics -owner user {

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
    set_metric -name design.timing_constraints.report_path -value [file dirname [get_db flow_source_directory]]/[get_db flow_run_tag]/[get_db flow_report_directory]/timing_constraints.rpt
  } else {
    set_metric -name design.timing_constraints.report_path -value [file dirname [get_db flow_source_directory]]/[get_db flow_report_directory]/timing_constraints.rpt
  } 

  define_metric -name design.check_timing.report_path
  if {[get_db flow_run_tag] != ""} {
    set_metric -name design.check_timing.report_path -value [file dirname [get_db flow_source_directory]]/[get_db flow_run_tag]/[get_db flow_report_directory]/check_timing_verbose.rpt
  } else {
    set_metric -name design.check_timing.report_path -value [file dirname [get_db flow_source_directory]]/[get_db flow_report_directory]/check_timing_verbose.rpt
  } 

  define_metric -name design.check_design.report_path
  if {[get_db flow_run_tag] != ""} {
    set_metric -name design.check_design.report_path -value [file dirname [get_db flow_source_directory]]/[get_db flow_run_tag]/[get_db flow_report_directory]/check_design_verbose.rpt
  } else {
    set_metric -name design.check_design.report_path -value [file dirname [get_db flow_source_directory]]/[get_db flow_report_directory]/check_design_verbose.rpt
  } 

  define_metric -name design.report_sequential.report_path
  if {[get_db flow_run_tag] != ""} {
    set_metric -name design.report_sequential.report_path -value [file dirname [get_db flow_source_directory]]/[get_db flow_run_tag]/[get_db flow_report_directory]/sequential_deleted_verbose.rpt
  } else {
    set_metric -name design.report_sequential.report_path -value [file dirname [get_db flow_source_directory]]/[get_db flow_report_directory]/sequential_deleted_verbose.rpt
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

create_flow_step -name write_metric_json -owner user {
  write_metric -format json -file [file join [get_db flow_report_directory]/qor.json]
  write_metric -format csv  -file [file join [get_db flow_report_directory]/qor.csv]
}

create_flow_step -name gen_dummy_liberty -owner user {
  write_hdl $design_name -abstract > [get_db flow_db_directory]/${block_name}_stub.v
  gen_dummy_liberty [get_db flow_db_directory]/${block_name}_stub.v [get_db flow_db_directory]/${block_name}_from_stub.lib $design_name
}

create_flow_step -name gen_read_hdl_netlist_report -owner user {
  set file_r [open [get_db log_file] r]
  if {[info exists be_archive_netlist]} { set mode netlist} else { set mode rtl }
  if {$mode == "netlist"} {
    set file_w [open [file join [get_db flow_report_directory]/read_netlist.rpt] w]
    set print_line "false"
    while {![eof $file_r]} {
      set line [gets $file_r]
      if {[regexp {^Starting read_netlist command} $line]} {set print_line "true"}
      if {$print_line} {puts $file_w $line}
      if {[regexp {^End of read_netlist command} $line]} {set print_line "false"}
    }
    close $file_w
  } else {
    set file_w [open [file join [get_db flow_report_directory]/read_hdl.rpt] w]
    set print_line "false"
    while {![eof $file_r]} {
      set line [gets $file_r]
      if {[regexp {^Starting read_hdl command} $line]} {set print_line "true"}
      if {$print_line} {puts $file_w $line}
      if {[regexp {^End of elaborate command} $line]} {set print_line "false"}
    }
    close $file_r
    close $file_w
  } 
}

create_flow_step -name report_messages -owner user {
  report_messages -all > [get_db flow_report_directory]/report_messages_all_[get_db flow_report_name].rpt
  report_messages -message_list "[get_db messages .name SDC* CDFG* ELAB*]" > [get_db flow_report_directory]/report_messages_[get_db flow_report_name].rpt
}

create_flow_step -name report_net_loads -owner user {
  set file_w [open [get_db flow_report_directory]/report_net_loads.rpt w]
  foreach el [get_db nets -expr {$obj(.num_loads) > 25}] {
    puts $file_w "[get_db $el .name] [get_db $el .num_loads]"
  }
  close $file_w
}
create_flow_step -name report_logic_levels_histogram -owner user {
  report_logic_levels_histogram -threshold 25 -details > [get_db flow_report_directory]/report_logic_levels_histogram.rpt
}

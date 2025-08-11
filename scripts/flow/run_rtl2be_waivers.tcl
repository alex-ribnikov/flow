#! /usr/bin/tclsh

if {[regexp {\-help} $argv] || ([llength $argv] == 0)} {
  # Print help
  puts "Script usage: run_rtl2be_waivers.tcl -report_dir <report_dir> -check_timing_waiver_file <check_timing_waiver_file>"
  puts "              -check_design_waiver_file <check_design_waiver_file> \[-inplace\]"
  puts "  Options:"
  puts "    -report_dir <report_dir>"
  puts "    -check_timing_waiver_file <check_timing_waiver_file>"
  puts "    -check_design_waiver_file <check_design_waiver_file>"
  puts "    -inplace"
  exit 0
} else {
  set inplace 0
  set use_pattern 0
  set report_dir {}
  set check_design_waiver_file {}
  set check_timing_waiver_file {}
  puts "Inputs:"
  for {set i 0} {$i < [llength $argv]} {incr i} {
    if {[lindex $argv $i] == "-report_dir"} {
      incr i
      set report_dir [lindex $argv $i]
      puts "  report_dir: $report_dir"
    } elseif {[lindex $argv $i] == "-check_timing_waiver_file"} {
      incr i
      set check_timing_waiver_file [lindex $argv $i]
      puts "  check_timing_waiver_file: $check_timing_waiver_file"
    } elseif {[lindex $argv $i] == "-check_design_waiver_file"} {
      incr i
      set check_design_waiver_file [lindex $argv $i]
      puts "  check_design_waiver_file: $check_design_waiver_file"
    } elseif {[lindex $argv $i] == "-inplace"} {  
      set inplace 1
    } else {
      puts "ERROR: Bad argument [lindex $argv $i]"
      puts "ERROR: Please run \"run_rtl2be_waivers.tcl -help\" to get the script help"
      exit 1
    } 
  }
}

if {$report_dir eq ""} {
  puts "ERROR: report_dir should be specified using option -report_dir"
  puts "ERROR: Please run \"run_rtl2be_waivers.tcl -h\" to get the script help"
  exit 1
} elseif {![file isdirectory $report_dir]} {
  puts "ERROR: report_dir $report_dir seems to be invalid"
  puts "ERROR: Please specify a valid directory"
  exit 1
}

if {$check_design_waiver_file eq "" && $check_timing_waiver_file eq ""} {
  puts "ERROR: At least check_timing_waiver_file or check_design_waiver_file need to be specified"
  puts "ERROR: Please run \"run_rtl2be_waivers.tcl -h\" to get the script help"
  exit 1

}

if {$inplace} {
  set report_dir_new ${report_dir}
} else {
  set report_dir_new "${report_dir}_new"
  if {![file exists $report_dir_new]} { file mkdir $report_dir_new }
}

set check_design_verbose_before_parsing_before_waivers $report_dir_new/check_design_verbose_before_parsing_before_waivers.rpt 
set check_design_verbose_before_waivers                $report_dir_new/check_design_verbose_before_waivers.rpt
set check_design_verbose                               $report_dir_new/check_design_verbose.rpt
set check_design_summary                               $report_dir_new/check_design_summary.rpt
set check_design                                       $report_dir_new/check_design.rpt

set check_timing_verbose_before_waivers                $report_dir_new/check_timing_verbose_before_waivers.rpt
set check_timing_verbose                               $report_dir_new/check_timing_verbose.rpt
set check_timing                                       $report_dir_new/check_timing.rpt

if {$check_design_waiver_file ne ""} {

  file copy   -force $report_dir/check_design_verbose.rpt $check_design_verbose_before_parsing_before_waivers
  if $inplace {
    file rename -force $report_dir/check_design_verbose.rpt $report_dir/check_design_verbose.rpt.original
  }
  
  file copy   -force $report_dir/check_design.rpt $check_design_summary
  if $inplace {
    file rename -force $report_dir/check_design.rpt $report_dir/check_design.rpt.original
  }
  
  set file_r [open $check_design_verbose_before_parsing_before_waivers r]
  set file_w [open $check_design_verbose_before_waivers w]
    
  set print "true"
  while {[gets $file_r line]>=0} {
    if {[regexp {design \'(.*)\' has the following unloaded sequential elements} $line match design]} {
      set print "false"
      # puts $file_w "No unloaded sequential element in \'$design\'\n"
    }
    if {[regexp {unloaded port} $line]} {
      set print "true"
    }
    if {$print} {
      puts $file_w $line
    }
  }
  close $file_r
  close $file_w
  file delete -force $check_design_verbose_before_parsing_before_waivers

  catch {unset table_waiver}
  set waiver_number_table(unresolved_references) 0
  set waiver_number_table(empty_modules) 0
  set waiver_number_table(unloaded_ports) 0
  set waiver_number_table(undriven_ports) 0
  set waiver_number_table(undriven_combinational_pins) 0
  set waiver_number_table(undriven_sequential_pins) 0
  set waiver_number_table(undriven_hierarchical_pins) 0
  set waiver_number_table(multidriven_ports) 0
  set waiver_number_table(multidriven_combinational_pins) 0
  set waiver_number_table(multidriven_sequential_pins) 0
  set waiver_number_table(multidriven_hierarchical_pins) 0
  set waiver_number_table(multidriven_unloaded_nets) 0


  if [file exists $check_design_waiver_file] {

    set file_r [open $check_design_waiver_file r]
    set rule_name "NA"
    while {![eof $file_r]} {
      set line [gets $file_r]
      if {[regexp {RULE: (.*)} $line match rule_string]} {
        set rule_name [regsub -all { } $rule_string {_}]
      } else {
        if {$rule_name != "NA"} {
          if {($line != "") && (![regexp "^#" $line])} {
            set recorded_line [regsub -all {[ \t]+} $line {}]
            set table_waiver($rule_name,$recorded_line) 1
          }
        }
      }
    }
    close $file_r
  
    set file_r [open $check_design_verbose_before_waivers r]
    set file_w [open $check_design_verbose w]
    set rule "NA"
    set summary "false"
    set total_number 0
    while {[gets $file_r line] >= 0} {
  
      if {[regexp {unresolved references} $line]} {
        set rule "unresolved_references"
        puts $file_w $line
      } elseif {[regexp {empty modules} $line]} {
        set rule "empty_modules"
        puts $file_w $line
      } elseif {[regexp {following unloaded port} $line]} {
        set rule "unloaded_ports"
        puts $file_w $line
      } elseif {[regexp {following port.*are undriven} $line]} {
        set rule "undriven_ports"
        puts $file_w $line
      } elseif {[regexp {following combinational pin.*are undriven} $line]} {
        set rule "undriven_combinational_pins"
        puts $file_w $line
      } elseif {[regexp {following sequential pin.*are undriven} $line]} {
        set rule "undriven_sequential_pins"
        puts $file_w $line
      } elseif {[regexp {following hierarchical pin.*are undriven} $line]} {
        set rule "undriven_hierarchical_pins"
        puts $file_w $line
      } elseif {[regexp {following port.*are multidriven} $line]} {
        set rule "multidriven_ports"
        puts $file_w $line
      } elseif {[regexp {following combinational pin.*are multidriven} $line]} {
        set rule "multidriven_combinational_pins"
        puts $file_w $line
      } elseif {[regexp {following sequential pin.*are multidriven} $line]} {
        set rule "multidriven_sequential_pins"
        puts $file_w $line
      } elseif {[regexp {following hierarchical pin.*are multidriven} $line]} {
        set rule "multidriven_hierarchical_pins"
        puts $file_w $line
      } elseif {[regexp {multidriven unloaded} $line]} {
        set rule "multidriven_unloaded_nets"
        puts $file_w $line
      } else {
  
        # the following conditional switch
        # if case: does not support * patterns in the waiver file yet, works fast
        # else case: supports usage of "*" in the waiver file, yet works much slower
        #            because iterates through all the paterns for each line of the report
        if {!$use_pattern} {
          set recorded_line [regsub -all {[ \t]+} $line {}]
          if {[info exist table_waiver($rule,$recorded_line)]} {
            incr waiver_number_table($rule)
            puts $file_w "# Waived by rtl2be mechanism by rule $rule: $line"
          } else {
            if {[regexp {(^Total number.*) ([0-9]+)} $line match text number]} {
              set line "$text [expr $number - $waiver_number_table($rule)]"
            }
            puts $file_w $line
          }
        } else {
          
          # parse the line with Total number of violation after each section
          # if matched, reduces the number of violaition by number of waived,
          # then prints the result fo reduction
          if [regexp {(^Total number.*) ([0-9]+)} $line match text number] {
            set line "$text [expr $number - $waiver_number_table($rule)]"
            puts $file_w $line
            continue
          }
          
          # compares the line of the original report against all the patterns 
          # in the waiver file (saved in array $table_waiver)
          # if matched, re-prints the line but commented with "# Waived by rtl2be mechanism:"
          ## set recorded_line [regsub -all {[ \t]+} $line {}]
          set recorded_line [lindex $line 0]
          set is_waived 0
          foreach waive_pattern [array names table_waiver "$rule,*"] {
            if [string match [string map {\\ {\\} [ {\[} ] {\]}} $waive_pattern] "$rule,$recorded_line"] {
              set is_waived 1
              break
            }
          }
          if $is_waived {
            incr waiver_number_table($rule)
            puts $file_w "# Waived by rtl2be mechanism: $line"
            continue
          }
          
          # if nothig above happened, simply re-print the line from the original report
          puts $file_w $line
        }
      }
    }
    close $file_r
    close $file_w
    file delete -force $check_design_verbose_before_waivers
  } else {
    file rename -force $check_design_verbose_before_waivers $check_design_verbose
  } ; # end if [file exists $check_design_waiver_file]
  
  set file_r [open $check_design_summary r]
  set file_w [open $check_design w]
  set write_in_file_w "false"

  while {[gets $file_r line]>=0} {

    if {([regexp {Unloaded Sequential Pin} $line] || 
         [regexp {Unloaded Combinational Pin} $line] || 
         [regexp {Assigns} $line] || 
         [regexp {^Constant} $line] || 
         [regexp {Feedthrough} $line] || 
         [regexp {Libcells with no LEF cell} $line] || 
         [regexp {^Physical} $line] || 
         [regexp {Subdesigns with long module name} $line] || 
         [regexp {Logical only instance} $line] || 
         [regexp {Preserved } $line])} {
      # dropping these checks from the report
      continue
    } elseif {[regexp {Unresolved References.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(unresolved_references)]
    } elseif {[regexp {Empty Modules.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(empty_modules)]
    } elseif {[regexp {Unloaded Port.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(unloaded_ports)]
    } elseif {[regexp {Undriven Port.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(undriven_ports)]
    } elseif {[regexp {Undriven Leaf Pin.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(undriven_combinational_pins) - $waiver_number_table(undriven_sequential_pins)]
    } elseif {[regexp {Undriven hierarchical pin.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(undriven_hierarchical_pins)]
    } elseif {[regexp {Multidriven Port.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(multidriven_ports)]
    } elseif {[regexp {Multidriven Leaf Pin.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(multidriven_combinational_pins) - $waiver_number_table(multidriven_sequential_pins)]
    } elseif {[regexp {Multidriven hierarchical Pin.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(multidriven_hierarchical_pins)]
    } elseif {[regexp {Multidriven unloaded net.*\s+(\d+)} $line match orig_number]} {
      set new_number [expr $orig_number - $waiver_number_table(multidriven_unloaded_nets)]
    }
    if {[regexp {.*\s+[0-9]+} $line]} {
      if {$new_number != $orig_number} {
        set line [regsub {[0-9]+} $line "$new_number (modified by rtl2be waiver mechanism)"]
      }
    }
    puts $file_w $line
  }
  close $file_r
  close $file_w
  file delete -force $check_design_summary
}

if {$check_timing_waiver_file ne ""} {
  
  file copy -force $report_dir/check_timing_verbose.rpt $check_timing_verbose_before_waivers
  if $inplace {
    file rename -force $report_dir/check_timing_verbose.rpt $report_dir/check_timing_verbose.rpt.original
  }

  if [file exists $check_timing_waiver_file] {
    
    catch {unset table_waiver}
    set waiver_number_table(Unconnected/logic_driven_clocks) 0
    set waiver_number_table(Sequential_data_pins_driven_by_a_clock_signal) 0
    set waiver_number_table(Sequential_clock_pins_without_clock_waveform) 0
    set waiver_number_table(Sequential_clock_pins_with_multiple_clock_waveforms) 0
    set waiver_number_table(Generated_clocks_without_clock_waveform) 0
    set waiver_number_table(Generated_clocks_with_incompatible_options) 0
    set waiver_number_table(Generated_clocks_with_multi-master_clock) 0
    set waiver_number_table(Paths_constrained_with_different_clocks) 0
    set waiver_number_table(Loop-breaking_cells_for_combinational_feedback) 0
    set waiver_number_table(Nets_with_multiple_drivers) 0
    set waiver_number_table(Timing_exceptions_with_no_effect) 0
    set waiver_number_table(Suspicious_multi_cycle_exceptions) 0
    set waiver_number_table(Pins/ports_with_conflicting_case_constants) 0
    set waiver_number_table(Inputs_without_clocked_external_delays) 0
    set waiver_number_table(Outputs_without_clocked_external_delays) 0
    set waiver_number_table(Inputs_without_external_driver/transition) 0
    set waiver_number_table(Outputs_without_external_load) 0
    set waiver_number_table(Exceptions_with_invalid_timing_start-/endpoints) 0
  
    set file_r [open $check_timing_waiver_file r]
    set rule_name "NA"
    while {![eof $file_r]} {
      set line [gets $file_r]
      if {[regexp {RULE: (.*)} $line match rule_string]} {
        set rule_name [regsub -all { } $rule_string {_}]
      } else {
        if {$rule_name != "NA"} {
          if {($line != "") && (![regexp "^#" $line])} {
            set table_waiver($rule_name,$line) 1
          }
        }
      }
    }
    close $file_r
  
    set file_r [open $check_timing_verbose_before_waivers r]
    set file_w [open $check_timing_verbose w]
  
    set rule "NA"
    set summary "false"
    set total_number 0
    while {[gets $file_r line] >= 0} {
  
      if {[regexp {Lint summary} $line]} {
        set summary "true"
      }
      if {$summary} {
          set orig_number 0
          set new_number 0
        if {[regexp {Unconnected/logic driven clocks\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Unconnected/logic_driven_clocks)]
          incr total_number $waiver_number_table(Unconnected/logic_driven_clocks)
        } elseif {[regexp {Sequential data pins driven by a clock signal\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Sequential_data_pins_driven_by_a_clock_signal)]
          incr total_number $waiver_number_table(Sequential_data_pins_driven_by_a_clock_signal)
        } elseif {[regexp {Sequential clock pins without clock waveform\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Sequential_clock_pins_without_clock_waveform)]
          incr total_number $waiver_number_table(Sequential_clock_pins_without_clock_waveform)
        } elseif {[regexp {Sequential clock pins with multiple clock waveforms\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Sequential_clock_pins_with_multiple_clock_waveforms)]
          incr total_number $waiver_number_table(Sequential_clock_pins_with_multiple_clock_waveforms)
        } elseif {[regexp {Generated clocks without clock waveform\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Generated_clocks_without_clock_waveform)]
          incr total_number $waiver_number_table(Generated_clocks_without_clock_waveform)
        } elseif {[regexp {Generated clocks with incompatible options\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Generated_clocks_with_incompatible_options)]
          incr total_number $waiver_number_table(Generated_clocks_with_incompatible_options)
        } elseif {[regexp {Generated clocks with multi-master clock\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Generated_clocks_with_multi-master_clock)]
          incr total_number $waiver_number_table(Generated_clocks_with_multi-master_clock)
        } elseif {[regexp {Paths constrained with different clocks\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Paths_constrained_with_different_clocks)]
          incr total_number $waiver_number_table(Paths_constrained_with_different_clocks)
        } elseif {[regexp {Loop-breaking cells for combinational feedback\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Loop-breaking_cells_for_combinational_feedback)]
          incr total_number $waiver_number_table(Loop-breaking_cells_for_combinational_feedback)
        } elseif {[regexp {Nets with multiple drivers\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Nets_with_multiple_drivers)]
          incr total_number $waiver_number_table(Nets_with_multiple_drivers)
        } elseif {[regexp {Timing exceptions with no effect\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Timing_exceptions_with_no_effect)]
          incr total_number $waiver_number_table(Timing_exceptions_with_no_effect)
        } elseif {[regexp {Suspicious multi_cycle exceptions\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Suspicious_multi_cycle_exceptions)]
          incr total_number $waiver_number_table(Suspicious_multi_cycle_exceptions)
        } elseif {[regexp {Pins/ports with conflicting case constants\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Pins/ports_with_conflicting_case_constants)]
          incr total_number $waiver_number_table(Pins/ports_with_conflicting_case_constants)
        } elseif {[regexp {Inputs without clocked external delays\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Inputs_without_clocked_external_delays)]
          incr total_number $waiver_number_table(Inputs_without_clocked_external_delays)
        } elseif {[regexp {Outputs without clocked external delays\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Outputs_without_clocked_external_delays)]
          incr total_number $waiver_number_table(Outputs_without_clocked_external_delays)
        } elseif {[regexp {Inputs without external driver/transition\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Inputs_without_external_driver/transition)]
          incr total_number $waiver_number_table(Inputs_without_external_driver/transition)
        } elseif {[regexp {Outputs without external load\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Outputs_without_external_load)]
          incr total_number $waiver_number_table(Outputs_without_external_load)
        } elseif {[regexp {Exceptions with invalid timing start-/endpoints\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $waiver_number_table(Exceptions_with_invalid_timing_start-/endpoints)]
          incr total_number $waiver_number_table(Exceptions_with_invalid_timing_start-/endpoints)
        } elseif {[regexp {Total:\s+([0-9]+)} $line match orig_number]} {
          set new_number [expr $orig_number - $total_number]
        }
        set number_length_difference [expr [string length $orig_number] - [string length $new_number]]
        if {$number_length_difference == "1"} {
          regsub $orig_number $line " $new_number" line
        } elseif {$number_length_difference == "2"} {
          regsub $orig_number $line "  $new_number" line
        } elseif {$number_length_difference == "3"} {
          regsub $orig_number $line "   $new_number" line
        } elseif {$number_length_difference == "4"} {
          regsub $orig_number $line "    $new_number" line
        } elseif {$number_length_difference == "5"} {
          regsub $orig_number $line "     $new_number" line
        } elseif {$number_length_difference == "6"} {
          regsub $orig_number $line "      $new_number" line
        } else {
          regsub $orig_number $line $new_number line
        }
        if {$orig_number != $new_number} {
          if {[regexp {[0-9]+} $line] && ![regexp {Total} $line]} {
            puts $file_w "$line (modified by rtl2be waiver mechanism)"
          } else {
            puts $file_w $line
          }
        } else {
          puts $file_w $line
        }
      } else {
        if {[regexp {Unconnected/logic driven clocks} $line]} {
          set rule "Unconnected/logic_driven_clocks"
          puts $file_w $line
        } elseif {[regexp {Sequential data pins driven by a clock signal} $line]} {
          set rule "Sequential_data_pins_driven_by_a_clock_signal"
          puts $file_w $line
        } elseif {[regexp {Sequential clock pins without clock waveform} $line]} {
          set rule "Sequential_clock_pins_without_clock_waveform"
          puts $file_w $line
        } elseif {[regexp {Sequential clock pins with multiple clock waveforms} $line]} {
          set rule "Sequential_clock_pins_with_multiple_clock_waveforms"
          puts $file_w $line
        } elseif {[regexp {Generated clocks without clock waveform} $line]} {
          set rule "Generated_clocks_without_clock_waveform"
          puts $file_w $line
        } elseif {[regexp {Generated clocks with incompatible options} $line]} {
          set rule "Generated_clocks_with_incompatible_options"
          puts $file_w $line
        } elseif {[regexp {Generated clocks with multi-master clock} $line]} {
          set rule "Generated_clocks_with_multi-master_clock"
          puts $file_w $line
        } elseif {[regexp {Paths constrained with different clocks} $line]} {
          set rule "Paths_constrained_with_different_clocks"
          puts $file_w $line
        } elseif {[regexp {Loop-breaking cells for combinational feedback} $line]} {
          set rule "Loop-breaking_cells_for_combinational_feedback"
          puts $file_w $line
        } elseif {[regexp {Nets with multiple drivers} $line]} {
          set rule "Nets_with_multiple_drivers"
          puts $file_w $line
        } elseif {[regexp {Excluded: Timing exceptions with no effect} $line]} {
          set rule "Timing_exceptions_with_no_effect"
          puts $file_w $line
        } elseif {[regexp {Suspicious multi_cycle exceptions} $line]} {
          set rule "Suspicious_multi_cycle_exceptions"
          puts $file_w $line
        } elseif {[regexp {Pins/ports with conflicting case constants} $line]} {
          set rule "Pins/ports_with_conflicting_case_constants"
          puts $file_w $line
        } elseif {[regexp {Inputs without clocked external delays} $line]} {
          set rule "Inputs_without_clocked_external_delays"
          puts $file_w $line
        } elseif {[regexp {Outputs without clocked external delays} $line]} {
          set rule "Outputs_without_clocked_external_delays"
          puts $file_w $line
        } elseif {[regexp {Inputs without external driver/transition} $line]} {
          set rule "Inputs_without_external_driver/transition"
          puts $file_w $line
        } elseif {[regexp {Outputs without external load} $line]} {
          set rule "Outputs_without_external_load"
          puts $file_w $line
        } elseif {[regexp {Exceptions with invalid timing start-/endpoints} $line]} {
          set rule "Exceptions_with_invalid_timing_start-/endpoints"
          puts $file_w $line
        } else {
          
          # the following conditional switch
          # if case: does not support * patterns in the waiver file yet, works fast
          # else case: supports usage of "*" in the waiver file, yet works much slower
          #            because iterates through all the paterns for each line of the report
          if {!$use_pattern} {
          
            if {[info exist table_waiver($rule,$line)]} {
              incr waiver_number_table($rule)
              puts $file_w "# Waived by rtl2be mechanism: $line"
            } else {
              puts $file_w $line
            }
          } else {
            
            # compares the line of the original report against all the patterns 
            # in the waiver file (saved in array $table_waiver)
            # if matched, re-prints the line but commented with "# Waived by rtl2be mechanism:"
            set recorded_line [regsub -all {[ \t]+} $line {}]
            set is_waived 0
            foreach waive_pattern [array names table_waiver "$rule,*"] {
              if [string match [string map {\\ {\\} [ {\[} ] {\]}} $waive_pattern] "$rule,$recorded_line"] {
                set is_waived 1
                break
              }
            }
            if $is_waived {
              incr waiver_number_table($rule)
              puts $file_w "# Waived by rtl2be mechanism: $line"
              continue
            }
            
            # if nothig above happened, simply re-print the line from the original report
            puts $file_w $line
          }
        }
      }
    }
    close $file_r
    close $file_w
    file delete -force $check_timing_verbose_before_waivers
  } else {
    file rename -force $check_timing_verbose_before_waivers $check_timing_verbose
  }

  set file_r [open $check_timing_verbose r]
  set file_w [open $check_timing w]
  set write_in_file_w "false"
  set total_waived 0
  while {[gets $file_r line]>=0} {

    if {[regexp {^Lint summary} $line]} {
      set write_in_file_w "true"
    }
    if {$write_in_file_w} {
      if {([regexp {Inputs without} $line] || [regexp {Outputs without} $line])} {
        regexp {([0-9]+)} $line match number
        incr total_waived $number
      } elseif {[regexp {Total:\s+([0-9]+)} $line match orig_number]} {
        set new_number [expr $orig_number - $total_waived]
        set orig_number_length [string length $orig_number]
        regsub $orig_number $line [format "%${orig_number_length}s" $new_number] line
        puts $file_w $line
      } else {
        puts $file_w $line
      }
    }
  }
  close $file_r
  close $file_w
}

puts "\nFinished waivers implementation in directory $report_dir_new"

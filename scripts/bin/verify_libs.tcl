#!/bin/tclsh

global g_design g_controls 

set setupfile $::env(CONTROLS)/setup.tcl
set g_design  $::env(BLOCK)

source $setupfile

set libs [info var ::innovus::*LIB*]

set report_name "verify_libs.rpt"
set fp [open $report_name w]

foreach lib $libs {
    set cmd "set lib_file_list \$$lib"
    eval $cmd
    foreach file $lib_file_list {
        if { ![file exists $file ] } {
             if { [llength $file] > 1 } {
                 foreach sub_file $file {
                     if { ![file exists $sub_file ] } {             
                         puts $fp "$lib: $sub_file"                     
                     }
                 }
             } else {
                 puts $fp "$lib: $file"
             }
        }
    }
}

close $fp

#!/bin/tclsh

set default_env_vars_list { REPO_SOURCE \
FLOW \
CONTROLS \
TSMC_PDK \
PROCESS \
LEF_SOURCE \
LIB_SOURCE \
DEF_TOOLS_innovus_ \
DEF_TOOLS_genus_ \
DEF_TOOLS_tempus_ \
DEF_TOOLS_fv_ \
DEF_TOOLS_clp_ \
DEF_TOOLS_litmus_ \
DEF_TOOLS_qrc_ \
DEF_TOOLS_voltus_ \
DEF_TOOLS_pegasus_ \
BLOCKINFO \
BLOCKSDC \
BLOCK \
FILELIST \
PROJECT \
BEROOT \
WORK \
PROJFLOW \
CONTROLS \
WB_ROOT \
WB_PATH \
WB_FONT }

if { [info exists ::env(WORK)] } {
set     csh_files [glob -nocomplain $::env(WORK)/setenv_*csh]
}
lappend csh_files [glob -nocomplain ./setenv_*csh]
set     csh_files [lsort -u $csh_files]

set more_vars {}
foreach file $csh_files {
    if { ![file exists $file] } { continue }
    set fp [open $file r]
    set fd [read $fp]
    close $fp
    
    foreach line [split $fd "\n"] {
        if { $line == "" } { continue }        
        if { [lindex [split $line " "] 0] != "setenv" } { continue }
        lappend default_env_vars_list [lindex [split $line " "] 1]            
    }    
}


set default_env_vars_list [lsort -u $default_env_vars_list]

foreach var $default_env_vars_list {
    if { [info exists ::env($var)] } {
        puts "[format %-30s $var] | $::env($var)"
    }
}


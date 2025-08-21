###############################################################################
#
# File:         setup.tcl
# Description:  Sources needed procedures and configuration settings.
# Authors:      Jason Gentry
# Created:      Tue Sep 11 09:21:36 MDT 2012
# Modified:     $Date:$ (Jason Gentry) jason.gentry@avagotech.com
# Language:     Tcl
# Package:      route_utilities
# Status:       Experimental (Do Not Distribute)
#
# (C) Copyright 2012-2015, Avago Technologies, Inc., all rights reserved.
#
###############################################################################


puts "DBG: Soursing setup.tcl : Begin"

### Env check.
### Environment variable check.
if {! [info exists env(ICPROCESS)]} {
  error "Environment variable 'ICPROCESS' must be set."
}
if {! [info exists env(INQA_ROOT)]} {
  error "Environment variable 'INQA_ROOT' must be set."
}
#set script_dir [file join $env(INQA_ROOT) scripts inqa]
set script_dir [file dirname [info script]]


set config [file join $env(INQA_ROOT) $env(ICPROCESS) inqa floorplanning config.tcl]
if {! [file readable $config]} {
  error "Configuration file '$config' not found."
}
if {[catch {source $config} msg]} {
  error "Failed to source configuration file '$config': $msg"
}

### Source the needed procedures.
if {[info commands parse_proc_arguments] == ""} {
  source [file join $script_dir argument_parser.tcl]
}
### Handle built-in argument parser (new to EDI11.1)
if {[info commands define_proc_arguments] != "" &&
  [info commands define_proc_attributes] == ""} {
  eval interp alias [list {} define_proc_attributes {}] define_proc_arguments
}
### Depending on the EDA tool, enable "dbu" conversion.
if {[info commands dbDBUToMicrons] == ""} {
  source [file join $script_dir  dbu_utilities.tcl]
  eval interp alias [list {} dbDBUToMicrons {}] ::DBUUtil::DBUToMicrons
  eval interp alias [list {} dbMicronsToDBU {}] ::DBUUtil::MicronsToDBU
  eval interp alias [list {} dbgMicronPerDBU {}] ::DBUUtil::agMicronPerDBU
}

#echo 1
#if {[info exists synopsys_program_name] && ($synopsys_program_name == "icc2_shell" || $synopsys_program_name == "fc_shell")} {
  ### Create the needed p/g vias if they exist.
  set pgvias [file join $env(INQA_ROOT) $env(ICPROCESS) inqa floorplanning pgvias_for_iccii.tcl]
  set pgvias [glob [file join ./scripts/bin/inqa pgvias_for_iccii_$env(ICPROCESS).tcl]]
  echo "-I- $pgvias"
  if {[file readable $pgvias]} { source $pgvias }
#} else {
  ### Turn off logging of command-line arguments.
#  unlogCommand parse_proc_arguments
#  unlogCommand define_proc_arguments
#  unlogCommand define_proc_attributes
#}

echo "-I- utilities.tcl"
source [file join $script_dir utilities.tcl]

echo "-I- custom_def.tcl "
source [file join $script_dir custom_def.tcl]

echo "-I- add_power.tcl"
source [file join $script_dir add_power.tcl]

echo "-I- add_context_obs.tcl"
source [file join $script_dir add_context_obs.tcl]



puts "DBG: Soursing setup.tcl : End"



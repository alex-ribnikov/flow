#################################################################################################################################################################################
#																						#
#	This scripts will run syn_regression flow
#	It is a "thinner" version of do_synGenus using the previous regression flow settings and "skips"
#	
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	    12/09/2021	    Ory  	 initial script																#
#																						#
#																						#
#################################################################################################################################################################################

set STAGE syn_reg
set block_name $DESIGN_NAME

set start_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - Start running $STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.

script_runtime_proc -start

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	set setup_file scripts/setup/setup.${::env(PROJECT)}.tcl
}
source -v $setup_file

if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
set_db library_setup_ispatial true ;                                    # (default : false
set_db max_cpus_per_server $CPU

puts "-I- Done setup [::ory_time::now]"


#------------------------------------------------------------------------------
# Verify Filelist
#------------------------------------------------------------------------------
set nextinside_path $NEXTINSIDE
if { ![info exists FILELIST] || $FILELIST == "None" } {

    set filelist        $nextinside_path/auto_gen/gendir/$DESIGN_NAME/${DESIGN_NAME}_gen_filelist/filelist

    if       { [file exists ./filelist] } {
        set filelist ./filelist    

    } elseif { [file exists ../inter/filelist] } {
        set filelist ../inter/filelist

    } else {
        if {[file exists auto_gen]} {file delete auto_gen}
        if {[file exists design]} {file delete design}
        file link -symbolic auto_gen $nextinside_path/auto_gen
        file link -symbolic design $nextinside_path/design
    }
    
} else {
    set filelist $FILELIST
}

#------------------------------------------------------------------------------
# Add libs for stubs
#------------------------------------------------------------------------------
set srcfile [regsub "filelist" $filelist "srcfile.flist"]
if { [file exists $srcfile] } {
    
    set fp [open $srcfile r]
    set fd [read $fp]
    close $fp
    
    set file_list {}
    set stubs_list {}
    
    foreach file [split $fd "\n"] { if { [regexp "\\\.vstub" $file] && ![regexp "behavioral_verilog" $file] } {lappend stubs_list $file } {lappend file_list $file} }
    puts "-I- stub file list : $stubs_list" 
} else {
	puts "-W- No srcfile found!"
}


if {[info exists stubs_list] && $stubs_list != ""} {
    
    set_db hdl_resolve_instance_with_libcell true
    set_db hdl_exclude_params_in_cell_search {pcore_l3_cluster_bank_noc_wrapper}
    
    exec cp $srcfile ${srcfile}.old
#	redirect temp.flist {puts [exec grep -v .vstub $srcfile]}
#	exec mv temp.flist $srcfile
    
    set fp [open $srcfile w]
    puts $fp [join $file_list "\n"]
    close $fp
 
	set fp [open reports/stub_list.rpt w]
	puts $fp [join $stubs_list "\n"]   
	close $fp
    
	set stub_lib_list ""
	foreach file $stubs_list { 
		puts "-I- Get module from stub: $file"
		set module [lindex [exec grep "module " $file] 1] 
		puts "-I- Get lib file for module: $module"
		set lib_path "$env(REPO_ROOT)/target/syn_regressions/$module/out/${module}_from_stub.lib"
		if { [file exists $lib_path] } { append stub_lib_list " $lib_path " } { puts "-W- No lib found in: $lib_path for $module" }
	}
    
	foreach pvt_cor [array names pvt_corner *timing] {
		set pvt_corner($pvt_cor) "$pvt_corner($pvt_cor) \
		$stub_lib_list"
	}
}

#------------------------------------------------------------------------------
# define and read mmmc 
#------------------------------------------------------------------------------
source scripts/flow/mmmc_create.tcl
mmmc_create
set cmd "read_mmmc { $mmmc_results }"
eval $cmd

puts "-I- Done mmmc_create [::ory_time::now]"


#------------------------------------------------------------------------------
# read lef and enable PLE-MODE
#------------------------------------------------------------------------------
set cmd "read_physical -lef \[list $LEF_FILE_LIST\]"
eval $cmd

puts "-I- Done read_physical [::ory_time::now]"


#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/syn_variables.tcl]} {
	puts "-I- reading syn_variables file from scripts_local"
	source -v scripts_local/syn_variables.tcl
} else {
	puts "-I- reading syn_variables file from scripts"
	source -v scripts/flow/syn_variables.tcl
}


puts "-I- Done syn_variables [::ory_time::now]"


#------------------------------------------------------------------------------
# syn_reg settings
#------------------------------------------------------------------------------
set_db hdl_preserve_unused_registers                false
set_db hdl_array_naming_style                       %s_%d ;                           # Default : %s[%d]
set_db hdl_instance_array_naming_style              %s_%d_ ;      # Default : %s[%d]
set_db hdl_reg_naming_style                         %s_reg%s ;    # Default : %s_reg%s
set_db hdl_max_loop_limit                           4096 ;                            # Default : 1024
# set_db hdl_error_on_latch                           true ;                          # Default : false
set_db hdl_unconnected_value                        none ;                            # Default : 0
set_db hdl_infer_unresolved_from_logic_abstract     false ;       # Default : true - will be obsolete
set_db hdl_generate_index_style                     %s_%d  ;                  # Default : %s[%d]
set_db hdl_generate_separator                       _ ;                                   # Default : .
set_db hdl_use_cw_first                             true ;                            # Default : false 
set_db hdl_flatten_complex_port                     false ;                   # Default : false
set_db hdl_resolve_instance_with_libcell            true ;                      # Default : false
set_db hdl_parameter_naming_style                   _%d ;                       # Default : _%s%d
set_db hdl_keep_first_module_definition             false


if { $ALLOW_BLACK_BOX } {
    set_db hdl_error_on_blackbox false
}

#------------------------------------------------------------------------------
# read HDL design
#------------------------------------------------------------------------------
puts "-I- Reading filelist from: $filelist"

if { [catch {read_hdl -language sv -f $filelist} res] } { fe_report_hdl ; puts "-E- read_hdl failed!"; puts $res ; exit } { puts $res }
if {[info exists srcfile] && [file exists $srcfile.old]} {exec cp $srcfile.old ${srcfile}}

puts "-I- Done read hdl [::ory_time::now]"
if { [catch {elaborate $DESIGN_NAME            } res] } { fe_report_hdl ; puts "-E- Elaborate failed!"; puts $res ; exit } { puts $res }
puts "-I- Done elaborate [::ory_time::now]"

puts "Runtime & Memory after: read_hdl & elaborate"
timestat Elaboration

#------------------------------------------------------------------------------
# read HDL Report
#------------------------------------------------------------------------------
fe_report_hdl

if { [info exists STOP_AFTER] && $STOP_AFTER == "elaborate" } {
    puts "-I- Stopping after elaborate"
    puts "-I- Printing some reports before exit"
    
    puts "-I- Counting cells [::ory_time::now]"
    
    set stage elaborate
    
    set cell_count [redirect_and_catch be_count_cells]
    set io_count   [redirect_and_catch be_count_interface]
    
    set cell_count_status "
    [nice_header "Cell Count"] \n$cell_count \n$io_count "
    
    redirect  reports/elab/report_macro_count.rpt {be_report_macro_count}
    
    set fp [open reports/${stage}_cell_count.rpt w]    
    puts $fp $cell_count_status
    close $fp

    
    exec touch .syn_done
    exit
}

redirect  reports/elab/report_macro_count.rpt {be_report_macro_count}

init_design

puts "-I- Done init_design [::ory_time::now]"

# init_genus (from orig flow) - timing
set_db ocv_mode                                     true

source  -v -e scripts/flow/dont_use_n_ideal_network.tcl

source ./scripts/flow/apply_rtl2be_directives.tcl
apply_rtl2be_directives

update_names -module -prefix ${DESIGN_NAME}_ [current_design]

# Write elaborated netlist and DB
puts "-I- Saving post elaborate design"
write_db -all_root out/${DESIGN_NAME}.elaborate.db
write_hdl >        out/${DESIGN_NAME}.elaborate.v 

if { !$GENERATE_MAPPED_NETLIST } {

#------------------------------------------------------------------------------
# reload_timing_constraints
#------------------------------------------------------------------------------
    set constraint_mode_sdc $sdc_files(func)
    redirect [file join [get_db user_stage_reports_dir]/timing_constraints.rpt] "update_constraint_mode -name [get_db constraint_modes .name] -sdc_files $constraint_mode_sdc"
    
    #------------------------------------------------------------------------------
    # Checks and Reports
    #------------------------------------------------------------------------------
    fe_check_design $CHECK_DESIGN_WAIVERS
    fe_check_timing $CHECK_TIMING_WAIVERS

    report_logic_levels_histogram -threshold 25 -details > [get_db user_stage_reports_dir]/report_logic_levels_histogram.rpt

    set file_w [open [get_db user_stage_reports_dir]/report_net_loads.rpt w]
    foreach el [get_db nets -expr {$obj(.num_loads) > 25}] {
      puts $file_w "[get_db $el .name] [get_db $el .num_loads]"
    }
    close $file_w

    #------------------------------------------------------------------------------
    # Set syn effort
    #------------------------------------------------------------------------------    
    set_db syn_global_effort high
    
} else {
#------------------------------------------------------------------------------
# Set syn effort
#------------------------------------------------------------------------------
    set_db syn_global_effort express
}

#------------------------------------------------------------------------------
# Run syn generic
#------------------------------------------------------------------------------
if { !$DONT_CHECK_CONSTANT_0_1 || $RUN_TIMING_REPORTS || $GENERATE_MAPPED_NETLIST } {
    set stage "syn_generic"
    mkdir -pv reports/$stage
    set_db user_stage_reports_dir reports/$stage
    be_set_design_source    
    puts "-I- BE: Running $stage"
    eee_stage $stage "$stage"
    
    
    puts "-I- Counting cells [::ory_time::now]"
    
    set cell_count [redirect_and_catch be_count_cells]
    set io_count   [redirect_and_catch be_count_interface]
    
    set cell_count_status "
    [nice_header "Cell Count"] \n$cell_count \n$io_count "
    
    redirect  reports/report_macro_count.rpt {be_report_macro_count}
    
    set fp [open [get_db user_stage_reports_dir]/${stage}_cell_count.rpt w]    
    puts $fp $cell_count_status
    close $fp
}

if { !$DONT_CHECK_CONSTANT_0_1 && !$GENERATE_MAPPED_NETLIST } {
# check_sequential_deleted
    redirect -var rpt { report_removed_sequentials syn_generic }
    
    set fp [open [get_db user_stage_reports_dir]/${stage}_sequential_deleted.rpt w]
    puts $fp $rpt
    close $fp
}

# Save DB
write_db -all_root out/${DESIGN_NAME}_${stage}.db

if { $RUN_TIMING_REPORTS && !$GENERATE_MAPPED_NETLIST } {
# report_late_paths
    #- Reports that show detailed timing with Graph Based Analysis (GBA)
    report_timing -max_paths 5   -nworst 1 -path_type endpoint        > [get_db user_stage_reports_dir]/setup.endpoint.rpt
    report_timing -max_paths 1   -nworst 1 -path_type full_clock -net > [get_db user_stage_reports_dir]/setup.worst.rpt
    report_timing -max_paths 500 -nworst 1 -path_type full_clock      > [get_db user_stage_reports_dir]/setup.gba.rpt
    report_timing -max_paths 500 -nworst 1 -path_type full_clock -output_format gtd > [get_db user_stage_reports_dir]/setup.gba.mtarpt

}

if { !$GENERATE_MAPPED_NETLIST } {
# custom_metrics
#    source /bespace/users/ory/nextinside_for_reg_010921/scripts/be_scripts/syn_regressions/scripts/metric_procs.tcl
#    source my_procs.tcl
    source ./scripts/procs/genus/regression_procs.tcl
    custom_metrics
}


# Report fanin fanout
if { [info exists REPORT_FI_FO_SIZE] && $REPORT_FI_FO_SIZE } {
    fe_report_io_fo $stage
}

# Report logic levels
if { [info exists REPORT_LOGIC_LEVELS] && $REPORT_LOGIC_LEVELS } {
    fe_io_logic_levels $stage
}

report_ports_status    [get_db user_stage_reports_dir]/syn_gen_io_status.rpt
fi_depth               [get_db user_stage_reports_dir]/syn_gen_fi_depth.rpt
fo_depth               [get_db user_stage_reports_dir]/syn_gen_fo_depth.rpt
fe_report_tap_clock_fo [get_db user_stage_reports_dir]/syn_gen_report_tap_clock_fo.rpt
fe_check_clock_gate    [get_db user_stage_reports_dir]/syn_gen_not_allowed_clock_gates.rpt


#            - report_area:
report_area  > [get_db user_stage_reports_dir]/area.rpt

set port [open [get_db user_stage_reports_dir]/area.rpt a]
puts $port ""
puts $port "  ------------------------------------------------------------"
puts $port "        Current design statistics"

dict for {k v} [concat [get_metric design.area*] [get_metric design.instances*]] {
    puts $port "$k = $v"
}
close $port


#            - report_feedthrough:   
fe_report_ft

#            - report_flops:
report_sequential -hier > [get_db user_stage_reports_dir]/flops.rpt.gz

#            - report_messages:
redirect [get_db user_reports_dir]/report_messages_${stage}.rpt     { report_messages -warning -error -all -message_list "[get_db messages .name SDC* CDFG* ELAB*]" } 
redirect [get_db user_reports_dir]/report_messages_all_${stage}.rpt { report_messages -all }
  
#            - gen_dummy_liberty:
write_hdl $DESIGN_NAME -abstract > [get_db user_outputs_dir]/${DESIGN_NAME}_stub.v
gen_dummy_liberty [get_db user_outputs_dir]/${DESIGN_NAME}_stub.v [get_db user_outputs_dir]/${DESIGN_NAME}_from_stub.lib $DESIGN_NAME

##            - block_finish:
#  #- Make sure flow_report_name is reset from any reports executed during the flow
#  set_db flow_report_name [get_db [lindex [get_db flow_hier_path] end] .name]
  
  #- Store non-default root attributes to metrics
  catch {report_obj -tcl} flow_root_config
  if {[dict exists $flow_root_config root:/]} {
    set flow_root_config [dict get $flow_root_config root:/]
  } elseif {[dict exists $flow_root_config root:]} {
    set flow_root_config [dict get $flow_root_config root:]
  } else {
  }
  foreach key [dict keys $flow_root_config] {
    if {[string length [dict get $flow_root_config $key]] > 200} {
      dict set flow_root_config $key "\[long value truncated\]"
    }
  }
  set_metric -name flow.root_config -value $flow_root_config

#            - write_metric_json:
#                enabled: "!generate_mapped_netlist"
if { !$GENERATE_MAPPED_NETLIST } {
  write_metric -format json -file [file join [get_db user_stage_reports_dir]/qor.json]
  write_metric -format csv  -file [file join [get_db user_stage_reports_dir]/qor.csv]
}


if { ! ($GENERATE_MAPPED_NETLIST || $RUN_TIMING_REPORTS) } {
    touch .syn_done
    puts "-I- syn regression flow is done."
    exit 
}


#------------------------------------------------------------------------------
# Proceed to syn map flow
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# running map
#------------------------------------------------------------------------------
##### standard wbSynMap
set stage "syn_map"
mkdir -pv reports/$stage
set_db user_stage_reports_dir reports/$stage
puts "-I- BE: Running $stage"
eee_stage $stage "$stage"

set fp [open [get_db user_stage_reports_dir]/${stage}_cell_count.rpt w]    
puts $cell_count_status
close $fp

if { !$GENERATE_MAPPED_NETLIST } {
# report_late_paths
    #- Reports that show detailed timing with Graph Based Analysis (GBA)
    report_timing -max_paths 5   -nworst 1 -path_type endpoint        > [get_db user_stage_reports_dir]/setup.endpoint.rpt
    report_timing -max_paths 1   -nworst 1 -path_type full_clock -net > [get_db user_stage_reports_dir]/setup.worst.rpt
    report_timing -max_paths 500 -nworst 1 -path_type full_clock      > [get_db user_stage_reports_dir]/setup.gba.rpt
    report_timing -max_paths 500 -nworst 1 -path_type full_clock -output_format gtd > [get_db user_stage_reports_dir]/setup.gba.mtarpt

}

#            - generate_mapped_netlist:
write_db -all_root out/${DESIGN_NAME}_${stage}.db
write_hdl $DESIGN_NAME > [get_db user_outputs_dir]/${DESIGN_NAME}_mapped.v

#            - report_area:
  report_area  > [get_db user_stage_reports_dir]/area.rpt
  
  set port [open [get_db user_stage_reports_dir]/area.rpt a]
  puts $port ""
  puts $port "  ------------------------------------------------------------"
  puts $port "        Current design statistics"
  
  dict for {k v} [concat [get_metric design.area*] [get_metric design.instances*]] {
    puts $port "$k = $v"
  }
  close $port
  
#            - report_flops:
  report_sequential -hier > [get_db user_stage_reports_dir]/${stage}/flops.rpt.gz

#            - report_mbff:
  report_mbff
  
#            - report_messages:
redirect [get_db user_reports_dir]/report_messages_${stage}.rpt     { report_messages -warning -error -all -message_list "[get_db messages .name SDC* CDFG* ELAB*]" } 
redirect [get_db user_reports_dir]/report_messages_all_${stage}.rpt { report_messages -all }


#            - block_finish:
#  #- Make sure flow_report_name is reset from any reports executed during the flow
#  set_db flow_report_name [get_db [lindex [get_db flow_hier_path] end] .name]
  
  #- Store non-default root attributes to metrics
  catch {report_obj -tcl} flow_root_config
  if {[dict exists $flow_root_config root:/]} {
    set flow_root_config [dict get $flow_root_config root:/]
  } elseif {[dict exists $flow_root_config root:]} {
    set flow_root_config [dict get $flow_root_config root:]
  } else {
  }
  foreach key [dict keys $flow_root_config] {
    if {[string length [dict get $flow_root_config $key]] > 200} {
      dict set flow_root_config $key "\[long value truncated\]"
    }
  }
  set_metric -name flow.root_config -value $flow_root_config


if { ! $RUN_TIMING_REPORTS } {
    touch .syn_done
    puts "-I- syn regression flow is done."
    exit 
}


#------------------------------------------------------------------------------
# Proceed to syn opt flow
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# running opt
#------------------------------------------------------------------------------
##### standard wbSynMap
set stage "syn_opt"
mkdir -pv reports/$stage
set_db user_stage_reports_dir reports/$stage
puts "-I- BE: Running $stage"
eee_stage $stage "$stage"

set fp [open [get_db user_stage_reports_dir]/${stage}_cell_count.rpt w]    
puts $cell_count_status
close $fp

# report_late_paths
  #- Reports that show detailed timing with Graph Based Analysis (GBA)
  report_timing -max_paths 5   -nworst 1 -path_type endpoint        > [get_db user_stage_reports_dir]/setup.endpoint.rpt
  report_timing -max_paths 1   -nworst 1 -path_type full_clock -net > [get_db user_stage_reports_dir]/setup.worst.rpt
  report_timing -max_paths 500 -nworst 1 -path_type full_clock      > [get_db user_stage_reports_dir]/setup.gba.rpt
  report_timing -max_paths 500 -nworst 1 -path_type full_clock -output_format gtd > [get_db user_stage_reports_dir]/setup.gba.mtarpt



#            - generate_mapped_netlist:
write_db -all_root out/${DESIGN_NAME}_${stage}.db
write_hdl $DESIGN_NAME > [get_db user_outputs_dir]/${DESIGN_NAME}_opt.v

#            - report_area:
  report_area  > [get_db user_stage_reports_dir]/area.rpt
  
  set port [open [get_db user_stage_reports_dir]/area.rpt a]
  puts $port ""
  puts $port "  ------------------------------------------------------------"
  puts $port "        Current design statistics"
  
  dict for {k v} [concat [get_metric design.area*] [get_metric design.instances*]] {
    puts $port "$k = $v"
  }
  close $port
  
#            - report_flops:
  report_sequential -hier > [get_db user_stage_reports_dir]/${stage}/flops.rpt.gz

#            - report_mbff:
  report_mbff
  
#            - report_messages:
redirect [get_db user_reports_dir]/report_messages_${stage}.rpt     { report_messages -warning -error -all -message_list "[get_db messages .name SDC* CDFG* ELAB*]" } 
redirect [get_db user_reports_dir]/report_messages_all_${stage}.rpt { report_messages -all }


#            - block_finish:
#  #- Make sure flow_report_name is reset from any reports executed during the flow
#  set_db flow_report_name [get_db [lindex [get_db flow_hier_path] end] .name]
  
  #- Store non-default root attributes to metrics
  catch {report_obj -tcl} flow_root_config
  if {[dict exists $flow_root_config root:/]} {
    set flow_root_config [dict get $flow_root_config root:/]
  } elseif {[dict exists $flow_root_config root:]} {
    set flow_root_config [dict get $flow_root_config root:]
  } else {
  }
  foreach key [dict keys $flow_root_config] {
    if {[string length [dict get $flow_root_config $key]] > 200} {
      dict set flow_root_config $key "\[long value truncated\]"
    }
  }
  set_metric -name flow.root_config -value $flow_root_config

touch .syn_done









if {![info exists RUNNING_DIR] } {set RUNNING_DIR [pwd] }
if {![file exists ${RUNNING_DIR}/reports/${STAGE}]} {exec mkdir -pv ${RUNNING_DIR}/reports/${STAGE}}
if {![file exists ${RUNNING_DIR}/reports/${STAGE}/snapshots] } {exec mkdir -pv ${RUNNING_DIR}/reports/${STAGE}/snapshots }

if {[file exists ${RUNNING_DIR}/reports/${STAGE}/runtime.txt ]} {exec rm ${RUNNING_DIR}/reports/${STAGE}/runtime.txt }

script_runtime_proc -start

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists ${RUNNING_DIR}/scripts_local/setup.tcl]} {
	puts "-I- reading setup file from ${RUNNING_DIR}/scripts_local"
	set setup_file ${RUNNING_DIR}/scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from ${RUNNING_DIR}/scripts"
	set setup_file ${RUNNING_DIR}/scripts/setup/setup.${PROJECT}.tcl
}
source -v -e $setup_file



update_timing

set t [get_user_units -type power -output]
set_user_units -type power -output -value 1.00mW



set parallel_execute_list [list]
lappend parallel_execute_list "{report_app_options } ${RUNNING_DIR}/reports/${STAGE}/report_app_options.all.rpt"
lappend parallel_execute_list "{report_app_options  -non_default} ${RUNNING_DIR}/reports/${STAGE}/report_app_options.non_default.rpt"
lappend parallel_execute_list "{report_global_timing -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_timing_summary.rpt"
lappend parallel_execute_list "{report_global_timing -format csv } ${RUNNING_DIR}/reports/${STAGE}/timing_summary.csv"
lappend parallel_execute_list "{report_timing -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins } ${RUNNING_DIR}/reports/${STAGE}/setup_all.rpt"
lappend parallel_execute_list "{report_timing -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins -from \[all_registers\] -to \[all_registers\] } ${RUNNING_DIR}/reports/${STAGE}/setup_reg2reg.rpt"
lappend parallel_execute_list "{report_constraint -all_violators -max_transition -max_capacitance -scenarios \[get_scenarios -filter active\] -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_constraint.rpt"
lappend parallel_execute_list "{report_clocks -mode \[all_modes\] -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_clocks.rpt"
lappend parallel_execute_list "{report_design -library -netlist -floorplan -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_design.rpt"
lappend parallel_execute_list "{report_tracks -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_tracks.rpt"
lappend parallel_execute_list "{report_references -hierarchical -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_reference.rpt"
lappend parallel_execute_list "{report_ignored_layers } ${RUNNING_DIR}/reports/${STAGE}/report_ignored_layers.rpt"
lappend parallel_execute_list "{report_extraction_options -corners \[all_corners\] } ${RUNNING_DIR}/reports/${STAGE}/report_extraction_options.rpt"
lappend parallel_execute_list "{report_power -verbose -scenarios \[get_scenarios -filter active\] -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_power.rpt"
lappend parallel_execute_list "{report_modes -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_modes.rpt"
lappend parallel_execute_list "{report_pvt -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_pvt.rpt"
lappend parallel_execute_list "{report_corners \[all_corners\] } ${RUNNING_DIR}/reports/${STAGE}/report_corners.rpt"
#lappend parallel_execute_list "{ } "
# need to add:
lappend parallel_execute_list "{count_buf_inv -dont_suppress_empty -extra_stats}  ${RUNNING_DIR}/reports/$STAGE/count_buf_inv.rpt"


foreach_in_collection pg [get_path_groups] {
	set gname [get_object_name $pg]
	lappend parallel_execute_list "{report_timing -group $gname  -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate  -capacitance -transition_time -nosplit -nets -input_pins } ${RUNNING_DIR}/reports/${STAGE}/setup_[string map  {* "" / "_"} [get_object_name $pg]].rpt"
}

set cmd "parallel_execute {\n"
foreach line $parallel_execute_list {
	set cmd "$cmd $line\n"
}
set cmd "$cmd }"
echo $cmd
eval $cmd

set_user_units -type power -output -value $t

set path_groups [get_attribute [get_path_groups] name]
lappend path_groups reg2reg
lappend path_groups all

foreach pg $path_groups {
	set gname  [string map  {* "" / "_"} $pg]
	exec gawk -f ${RUNNING_DIR}/scripts/bin/slacks.awk ${RUNNING_DIR}/reports/${STAGE}/setup_${gname}.rpt | sort -n > ${RUNNING_DIR}/reports/${STAGE}/setup_${gname}.summary
	exec ${RUNNING_DIR}/scripts/bin/timing_filter.pl ${RUNNING_DIR}/reports/${STAGE}/setup_${gname}.rpt
}



### app options ###
# ROY parallel_execute : report_app_options -as_list > ${RUNNING_DIR}/reports/${STAGE}/report_app_options.all.rpt
# ROY parallel_execute : report_app_options -as_list -non_default > ${RUNNING_DIR}/reports/${STAGE}/report_app_options.non_default.rpt

### checking legality ###
puts "Info: 	check legality ...\n"
eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_check_legality.rpt {check_legality -verbose}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt check_lagality

### QoR ###
set pba_mode [get_app_option_value -name time.pba_optimization_mode] 
puts "Info: Reporting timing and QoR ...\n"
redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_qor.rpt {report_qor -scenarios [get_scenarios -filter active] -pba_mode $pba_mode -nosplit}
redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_qor_summary.qor {report_qor -summary -pba_mode $pba_mode -nosplit}
# using 2 specific procs from RM which were can be found under this paths:
#source /bespace/users/rinate/nextflow/be_work/brcm3/grid_quad_west_filler_row_top/work_051224/fusion/tcl/proc_qor.tcl
#source /bespace/users/rinate/nextflow/be_work/brcm3/grid_quad_west_filler_row_top/work_051224/fusion/tcl/proc_histogram.tcl
eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/proc_qor.rpt {proc_qor -pba_mode $pba_mode}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt proc_qor

write_qor_data -output $RUNNING_DIR/reports/qor_data -report_group placed -report_list "gui_congestion gui_cell_density gui_cellmap_utilization gui_pin_density gui_hold_buffers" -label "${STAGE}"
if {[file exists  $RUNNING_DIR/reports/compare_qor_data ]} {exec rm -r  $RUNNING_DIR/reports/compare_qor_data } 
compare_qor_data -output $RUNNING_DIR/reports/compare_qor_data -run_locations $RUNNING_DIR/reports/qor_data -force

### timing ###
# ROY parallel_execute : eee "redirect -tee -file ${RUNNING_DIR}/reports/${STAGE}/report_timing_summary.rpt {report_global_timing -pba_mode $pba_mode -nosplit}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_timing_summary

### all ###
# ROY parallel_execute : eee "report_timing -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins  -pba_mode $pba_mode > ${RUNNING_DIR}/reports/${STAGE}/${STAGE}_all.rpt" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_timing_all
#exec gawk -f ./scripts/bin/slacks.awk ${RUNNING_DIR}/reports/${STAGE}/${STAGE}_all.rpt     | sort -n > ${RUNNING_DIR}/reports/${STAGE}/${STAGE}_all.summary

### per group path ###
# ROY parallel_execute : foreach_in_collection pg [get_path_groups] {
# ROY parallel_execute : 	set gname [get_object_name $pg]
# ROY parallel_execute : 	eee "report_timing -group $gname  -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins  -pba_mode $pba_mode > ${RUNNING_DIR}/reports/${STAGE}/${STAGE}_${gname}.rpt" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_timing_${gname}
# ROY parallel_execute : 	exec gawk -f ./scripts/bin/slacks.awk ${RUNNING_DIR}/reports/${STAGE}/${STAGE}_${gname}.rpt | sort -n > ${RUNNING_DIR}/reports/${STAGE}/${STAGE}_${gname}.summary
# ROY parallel_execute : 	exec ./scripts/bin/timing_filter.pl ${RUNNING_DIR}/reports/${STAGE}/${STAGE}_${gname}.rpt
# ROY parallel_execute : }

### transition violators ###
# ROY parallel_execute : redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_constraint.rpt {report_constraint -all_violators -max_transition -max_capacitance -scenarios [get_scenarios -filter active] -nosplit}

### Debugging -  is it interesting? ###
puts "Info: Analyzing design violations ...\n"
analyze_design_violations -type setup -stage preroute -output ${RUNNING_DIR}/reports/${STAGE}/analyze_design_violations.rpt

### timing constraints  ###
puts "Info: Reporting timing constraints ...\n"
# ROY parallel_execute : parallel_execute {
# ROY parallel_execute : 	{report_modes -nosplit} ${RUNNING_DIR}/reports/${STAGE}/report_modes.rpt
# ROY parallel_execute : 	{report_pvt -nosplit} ${RUNNING_DIR}/reports/${STAGE}/report_pvt.rpt
# ROY parallel_execute : 	{report_corners [all_corners]} ${RUNNING_DIR}/reports/${STAGE}/report_corners.rpt
# ROY parallel_execute : }
redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_scenarios.rpt {report_scenarios -nosplit}
# ROY parallel_execute : redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_clocks.rpt {report_clocks -mode [all_modes] -nosplit}

###  design information  ###
puts "Info: Reporting design information ...\n"
# ROY parallel_execute : redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_design.rpt {report_design -library -netlist -floorplan -nosplit}
# ROY parallel_execute : redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_tracks.rpt {report_tracks -nosplit}

### util ###
set rm_lib_type [get_attribute -quiet [current_design] rm_lib_type]
if {$rm_lib_type != ""} {puts "RM-info: rm_lib_type = $rm_lib_type"}

if {[sizeof_collection [get_utilization_configurations no_physical -quiet]] > 0} {
	remove_utilization_configurations no_physical
}
create_utilization_configuration no_physical -capacity site_row -exclude {hard_macros macro_keepouts soft_macros io_cells hard_blockages physical_only_cells}
redirect -tee -file ${RUNNING_DIR}/reports/${STAGE}/report_utilization.rpt {report_utilization  -config no_physical}



# ROY parallel_execute : redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_reference.rpt {report_references -hierarchical -nosplit}
# ROY parallel_execute : redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_ignored_layers.rpt {report_ignored_layers}
# ROY parallel_execute : redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_extraction_options.rpt {report_extraction_options -corners [all_corners]}

### mbit ###
redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_multibit.rpt {report_multibit}


### cong ###
#redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_congestion_summary.rpt {report_congestion -mode summary}


### power ###
# VT groups
# ROY parallel_execute : eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_threshold_voltage_group.rpt {report_threshold_voltage_group -nosplit}"  ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_threshold_voltage_group
# ROY parallel_execute : eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_vt_summary.rpt {report_threshold_voltage_group -nosplit -summary}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt  
# ROY parallel_execute : eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_power.rpt {report_power -verbose -scenarios [get_scenarios -filter active] -nosplit}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_power
#
set_app_options -name route.global.timing_driven -value true	
	
#eee "redirect -tee -file ${RUNNING_DIR}/reports/${STAGE}/report_congestion.rpt {report_congestion -layers [get_layers -filter "layer_type==interconnect"] -rerun_global_router -nosplit}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_congestion

redirect -file ${RUNNING_DIR}/reports/place/report_area_summary.rpt {report_area}


#Placement snapshots

if {![file exists ${RUNNING_DIR}/reports/${STAGE}/snapshots] } {exec mkdir -pv ${RUNNING_DIR}/reports/${STAGE}/snapshots }

gui_start
gui_set_layout_layer_visibility [get_attribute [get_layers] name] -toggle
gui_change_highlight -remove -all_colors
gui_execute_menu_item -menu "View->Map->Global Route Congestion"
gui_write_window_image -format png -file ${RUNNING_DIR}/reports/${STAGE}/snapshots/${DESIGN_NAME}.congestion.png

gui_execute_menu_item -menu "View->Map->Cell Density"
gui_write_window_image -format png -file ${RUNNING_DIR}/reports/${STAGE}/snapshots/${DESIGN_NAME}.density.png

gui_stop

gui_start
gui_set_layout_layer_visibility [get_attribute [get_layers] name] -toggle
gui_set_setting -setting showPort -value false -window [gui_get_current_window -type Layout]
gui_select_by_name -object_type Cells -highlight	
gui_write_window_image -format png -file ${RUNNING_DIR}/reports/${STAGE}/snapshots/${DESIGN_NAME}.placement.png


# taking snapshot of hiers and ports (as set in the post_place_opt_setting.tcl file)
if { [info exists COLOR_HIERS] || [info exists COLOR_PORTS] } {
  #gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value false
  if { [llength [array get COLOR_HIERS]] } {
    foreach i [array names COLOR_HIERS] {
        puts "-I- Creating HIER image for entry $i"
        be_color_hiers $COLOR_HIERS($i)
        change_selection
	set f "${RUNNING_DIR}/reports/${STAGE}/snapshots/${DESIGN_NAME}.user_hiers_${i}.png"
	gui_write_window_image -format png -file $f
  	gui_change_highlight -remove -all_colors
	remove_annotation_shapes -all

    }
  } else {
    if { [info exists COLOR_HIERS] } {
        be_color_hiers $COLOR_HIERS
	set f "${RUNNING_DIR}/reports/${STAGE}/snapshots/${DESIGN_NAME}.user_hiers.png"
    	gui_write_window_image -format png -file  $f   
    	gui_change_highlight -remove -all_colors
    	remove_annotation_shapes -all
	change_selection
    }
   
    if { [info exists COLOR_PORTS] } {
       # gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value true
        be_color_ports $COLOR_PORTS
	set f "${RUNNING_DIR}/reports/${STAGE}/snapshots/${DESIGN_NAME}.user_ports.png"
    	gui_write_window_image -format png -file  $f   
    	gui_change_highlight -remove -all_colors
    	remove_annotation_shapes -all
	change_selection
    }

  }
    #gui_set_setting -window [gui_get_current_window -types Layout -mru] -setting showPort -value true
}
    gui_stop



### be.qor ###
#source /bespace/users/noac/tcl/flow/fusion_reports/qor.generator.tcl
be_reports -all
#===========================================
# be checklist
#===========================================
# cd to pnr..
set current_location [pwd]
cd ${RUNNING_DIR}
puts "-I- current location --> [pwd]"

# IO buffer Statistics & driving ports violations:
io_buffers_statistics 

#  check io buffer sampled By MB:
io_sampled 
 
# buf/inv count & info
buf_inv_info 

redirect_and_catch "exec ./scripts/bin/fc_be_checklist.tcl $STAGE"

#===========================================
# Zip the reports files
#===========================================

set files [exec find ${RUNNING_DIR}/reports/${STAGE}/ -maxdepth 1 -type f ! -name *.gz ! -name ${STAGE}.be.qor]
foreach f $files {exec gzip -f $f}


#===========================================
exec touch .${STAGE}_reports_done
### upload tables to grafana
if {![info exists FE_MODE] || $FE_MODE == "false"} {
	set status [catch {exec scripts/bin/run_db.csh $STAGE} msg]
}
# back to parallel_run dir
cd $current_location
puts "-I- current location --> [pwd]"
	
#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end


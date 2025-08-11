if {![info exists RUNNING_DIR] } {set RUNNING_DIR [pwd] }
if {![file exists ${RUNNING_DIR}/reports/$STAGE]} {exec mkdir -pv ${RUNNING_DIR}/reports/$STAGE}
if {![file exists ${RUNNING_DIR}/reports/$STAGE/snapshots] } {exec mkdir -pv ${RUNNING_DIR}/reports/$STAGE/snapshots }

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
lappend parallel_execute_list "{report_app_options } ${RUNNING_DIR}/reports/$STAGE/report_app_options.all.rpt"
lappend parallel_execute_list "{report_app_options -non_default} ${RUNNING_DIR}/reports/$STAGE/report_app_options.non_default.rpt"
lappend parallel_execute_list "{report_global_timing -nosplit } ${RUNNING_DIR}/reports/$STAGE/report_timing_summary.rpt"
lappend parallel_execute_list "{report_global_timing -format csv } ${RUNNING_DIR}/reports/${STAGE}/timing_summary.csv"
lappend parallel_execute_list "{report_timing -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins } ${RUNNING_DIR}/reports/$STAGE/setup_all.rpt"
lappend parallel_execute_list "{report_timing -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins -delay_type min} ${RUNNING_DIR}/reports/$STAGE/hold_all.rpt"
lappend parallel_execute_list "{report_timing -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins  -path_type full_clock_expanded -from \[all_registers\] -to \[all_registers\] } ${RUNNING_DIR}/reports/${STAGE}/setup_reg2reg.rpt"
lappend parallel_execute_list "{report_timing -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins -delay_type min  -path_type full_clock_expanded -from \[all_registers\] -to \[all_registers\] } ${RUNNING_DIR}/reports/$STAGE/hold_reg2reg.rpt"

# shai update
lappend parallel_execute_list "{report_constraint -all_violators -max_transition -max_capacitance -min_pulse_width -min_period -scenarios \[get_scenarios -filter active\] -nosplit } ${RUNNING_DIR}/reports/$STAGE/report_constraint.rpt"
lappend parallel_execute_list "{report_qor -scenarios \[get_scenarios -filter active\] -nosplit}  ${RUNNING_DIR}/reports/$STAGE/report_qor.rpt"
lappend parallel_execute_list "{report_qor -summary}  ${RUNNING_DIR}/reports/$STAGE/report_qor_summary.rpt"
lappend parallel_execute_list "{report_clocks -mode \[all_modes\] -nosplit } ${RUNNING_DIR}/reports/$STAGE/report_clocks.rpt"
lappend parallel_execute_list "{report_design -library -netlist -floorplan -nosplit } ${RUNNING_DIR}/reports/$STAGE/report_design.rpt"
lappend parallel_execute_list "{report_tracks -nosplit } ${RUNNING_DIR}/reports/$STAGE/report_tracks.rpt"
lappend parallel_execute_list "{report_references -hierarchical -nosplit } ${RUNNING_DIR}/reports/$STAGE/report_reference.rpt"
lappend parallel_execute_list "{report_ignored_layers } ${RUNNING_DIR}/reports/$STAGE/report_ignored_layers.rpt"
lappend parallel_execute_list "{report_extraction_options -corners \[all_corners\] } ${RUNNING_DIR}/reports/$STAGE/report_extraction_options.rpt"
lappend parallel_execute_list "{report_power -verbose -scenarios \[get_scenarios -filter active\] -nosplit } ${RUNNING_DIR}/reports/$STAGE/report_power.rpt"
lappend parallel_execute_list "{report_modes -nosplit } ${RUNNING_DIR}/reports/$STAGE/report_modes.rpt"
lappend parallel_execute_list "{report_pvt -nosplit } ${RUNNING_DIR}/reports/$STAGE/report_pvt.rpt"
lappend parallel_execute_list "{report_corners \[all_corners\] } ${RUNNING_DIR}/reports/$STAGE/report_corners.rpt"
lappend parallel_execute_list "{check_design -ems_database check_design.pre_route_stage.ems -checks pre_route_stage} ${RUNNING_DIR}/reports/$STAGE/check_design.pre_route_stage"
lappend parallel_execute_list "{report_clock_timing -type summary -clock_synthesis_view -scenarios \[get_scenarios -filter active\] -nosplit} ${RUNNING_DIR}/reports/$STAGE/report_clock_timing.summary"
lappend parallel_execute_list "{report_clock_timing -type latency -clock_synthesis_view -scenarios \[get_scenarios -filter active\] -nosplit} ${RUNNING_DIR}/reports/$STAGE/report_clock_timing.latency"
lappend parallel_execute_list "{report_clock_timing -type skew -clock_synthesis_view -scenarios \[get_scenarios -filter active\] -nosplit} ${RUNNING_DIR}/reports/$STAGE/report_clock_timing.skew"
lappend parallel_execute_list "{report_clock_timing -type interclock_skew -nosplit}  ${RUNNING_DIR}/reports/$STAGE/report_clock_timing.interclock_skew"
lappend parallel_execute_list "{report_clock_qor -type structure -nosplit} ${RUNNING_DIR}/reports/$STAGE/report_clock_qor.structure"
lappend parallel_execute_list "{report_clock_qor -type area -nosplit} ${RUNNING_DIR}/reports/$STAGE/report_clock_qor.area"
lappend parallel_execute_list "{report_clock_qor -type latency -show_paths -nosplit} ${RUNNING_DIR}/reports/$STAGE/report_clock_qor.latency"
lappend parallel_execute_list "{report_clock_qor -type power -nosplit} ${RUNNING_DIR}/reports/$STAGE/report_clock_qor.power"
lappend parallel_execute_list "{report_clock_qor -type summary -nosplit} ${RUNNING_DIR}/reports/$STAGE/report_clock_qor.summary"
lappend parallel_execute_list "{report_clock_qor -type level -nosplit} ${RUNNING_DIR}/reports/$STAGE/report_clock_qor.level"
# shai update
lappend parallel_execute_list "{count_buf_inv -dont_suppress_empty -extra_stats}  ${RUNNING_DIR}/reports/$STAGE/count_buf_inv.rpt"

foreach_in_collection pg [get_path_groups] {
	set gname [get_object_name $pg]
	lappend parallel_execute_list "{report_timing -group $gname  -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate  -capacitance -transition_time -nosplit -nets -input_pins } ${RUNNING_DIR}/reports/$STAGE/setup_[string map  {* "" / "_"} [get_object_name $pg]].rpt"
	lappend parallel_execute_list "{report_timing -group $gname  -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate  -capacitance -transition_time -nosplit -nets -input_pins -delay_type min } ${RUNNING_DIR}/reports/$STAGE/hold_[string map  {* "" / "_"} [get_object_name $pg]].rpt"

	
}

set cmd "parallel_execute {\n"
foreach line $parallel_execute_list {
	set cmd "$cmd $line\n"
}
set cmd "$cmd }"
echo $cmd
eval $cmd

set_user_units -type power -output -value $t


### Timing ###
set path_groups [get_attribute [get_path_groups] name]
lappend path_groups reg2reg
lappend path_groups all

foreach pg $path_groups {
	set gname [string map  {* "" / "_"} $pg]
	exec gawk -f ${RUNNING_DIR}/scripts/bin/slacks.awk ${RUNNING_DIR}/reports/${STAGE}/setup_${gname}.rpt | sort -n > ${RUNNING_DIR}/reports/${STAGE}/setup_${gname}.summary
	exec ${RUNNING_DIR}/scripts/bin/timing_filter.pl ${RUNNING_DIR}/reports/${STAGE}/setup_${gname}.rpt
	
	exec gawk -f ${RUNNING_DIR}/scripts/bin/slacks.awk ${RUNNING_DIR}/reports/$STAGE/hold_${gname}.rpt | sort -n > ${RUNNING_DIR}/reports/$STAGE/hold_${gname}.summary
	exec ${RUNNING_DIR}/scripts/bin/timing_filter.pl ${RUNNING_DIR}/reports/$STAGE/hold_${gname}.rpt

}


### Timing Constraints  ###
redirect -file ${RUNNING_DIR}/reports/$STAGE/report_scenarios.rpt {report_scenarios -nosplit}

### QoR ###
set pba_mode [get_app_option_value -name time.pba_optimization_mode] 
redirect -file ${RUNNING_DIR}/reports/$STAGE/proc_qor.rpt {proc_qor -pba_mode $pba_mode}

write_qor_data -output $RUNNING_DIR/reports/qor_data -report_group cts -label "${STAGE}"
if {[file exists  $RUNNING_DIR/reports/compare_qor_data ]} {exec rm -r  $RUNNING_DIR/reports/compare_qor_data } 
compare_qor_data -output $RUNNING_DIR/reports/compare_qor_data -run_locations $RUNNING_DIR/reports/qor_data -force

### Debugging ###
analyze_design_violations -type setup -stage preroute -output ${RUNNING_DIR}/reports/$STAGE/analyze_design_violations.rpt

### Utilzation ###
set rm_lib_type [get_attribute -quiet [current_design] rm_lib_type]
if {$rm_lib_type != ""} {puts "RM-info: rm_lib_type = $rm_lib_type"}

if {[sizeof_collection [get_utilization_configurations no_physical -quiet]] > 0} {
	remove_utilization_configurations no_physical
}
create_utilization_configuration no_physical -capacity site_row -exclude {hard_macros macro_keepouts soft_macros io_cells hard_blockages physical_only_cells}

redirect -tee -file ${RUNNING_DIR}/reports/$STAGE/report_utilization.rpt {report_utilization  -config no_physical}


### Mbit ###
redirect -file ${RUNNING_DIR}/reports/$STAGE/report_multibit.rpt {report_multibit}


### Congestion ###
set_app_options -name route.global.timing_driven -value true		


### Snapshots ###

gui_start
gui_set_layout_layer_visibility [get_attribute [get_layers] name] -toggle
gui_change_highlight -remove -all_colors
gui_set_setting -setting showPort -value false -window [gui_get_current_window -type Layout]
gui_select_by_name -object_type Cells -highlight	
gui_write_window_image -format png -file ${RUNNING_DIR}/reports/$STAGE/snapshots/${DESIGN_NAME}.placement.png

gui_change_highlight -remove -all_colors
gui_set_setting -setting showPort -value true -window [gui_get_current_window -type Layout]
gui_execute_menu_item -menu "View->Map->Global Route Congestion"
gui_write_window_image -format png -file ${RUNNING_DIR}/reports/$STAGE/snapshots/${DESIGN_NAME}.congestion.png
gui_execute_menu_item -menu "View->Map->Cell Density"
gui_load_cell_density_mm
gui_write_window_image -format png -file ${RUNNING_DIR}/reports/$STAGE/snapshots/${DESIGN_NAME}.density.png
gui_change_highlight -remove -all_color

gui_load_cell_slack_vm -scenario func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup -upper_bound 0.0 -upper_bound_strict
gui_execute_menu_item -menu "Highlight -> Color By -> Clock Tree"
gui_write_window_image -window [gui_get_current_window] -format png -file ${RUNNING_DIR}/reports/$STAGE/snapshots/${DESIGN_NAME}.highlighed_by_cts_level.png
gui_execute_menu_item -menu "Window->Clock Tree Analysis Window"
gui_select_by_name  -object_type Clocks
gui_execute_menu_item -menu "View->Levelized Clock Tree Graph->Beyond Exception"
gui_select_by_name  -object_type Clocks -remove
gui_write_window_image -window [gui_get_current_window -type Acg] -format png -file ${RUNNING_DIR}/reports/$STAGE/snapshots/${DESIGN_NAME}.clock_tree.png


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
if {![string compare $STAGE "cts_only"]} {
	be_reports -all -mail false
	#===========================================
	# be checklist
	#===========================================
	set current_location [pwd]
	cd ${RUNNING_DIR}
	puts "-I- current location --> [pwd]"
	
	# check clock tree cells  violation:
	clock_tree_cells_check
	# buf/inv count & info
	buf_inv_info 
	# check that each clock pin, start with clock (clock tree)
	check_clock_to_each_clk_pin 
	# check clock NETs, routing rule
	check_clock_ndr
	
	redirect_and_catch "exec ./scripts/bin/fc_be_checklist.tcl $STAGE"
	cd $current_location
	puts "-I- current location --> [pwd]"
	#------------------------------------------------------------

} else {
	be_reports -all
	#===========================================
	# be checklist
	#===========================================
	# cd to pnr..
	set current_location [pwd]
	cd ${RUNNING_DIR}
	puts "-I- current location --> [pwd]"
	
	# check clock tree cells  violation:
	clock_tree_cells_check
	# buf/inv count & info
	buf_inv_info 
	# check that each clock pin, start with clock (clock tree)
	check_clock_to_each_clk_pin 
	# check clock NETs, routing rule
	check_clock_ndr

	redirect_and_catch "exec  ./scripts/bin/fc_be_checklist.tcl $STAGE"

	#===========================================
	exec touch .${STAGE}_reports_done
	### upload tables to grafana
	
	set status [catch {exec scripts/bin/run_db.csh $STAGE} msg]

	# back to parallel_run dir
	cd $current_location
	puts "-I- current location --> [pwd]"

}

#===========================================
# Zip the reports files
#===========================================

set files [exec find ${RUNNING_DIR}/reports/${STAGE}/ -maxdepth 1 -type f ! -name *.gz ! -name ${STAGE}.be.qor]
foreach f $files {exec gzip -f $f}

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end


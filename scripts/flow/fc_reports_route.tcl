if {![info exists RUNNING_DIR] } {set RUNNING_DIR [pwd] }
if {![file exists ${RUNNING_DIR}/reports/${STAGE}]} {exec mkdir -pv ${RUNNING_DIR}/reports/${STAGE}}
if {![file exists ${RUNNING_DIR}/reports/${STAGE}/snapshots] } {exec mkdir -pv ${RUNNING_DIR}/reports/${STAGE}/snapshots }

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
lappend parallel_execute_list "{report_app_options -non_default} ${RUNNING_DIR}/reports/${STAGE}/report_app_options.non_default.rpt"
lappend parallel_execute_list "{report_global_timing -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_timing_summary.rpt"
lappend parallel_execute_list "{report_global_timing -format csv } ${RUNNING_DIR}/reports/${STAGE}/timing_summary.csv"
lappend parallel_execute_list "{report_timing -physical -crosstalk_delta -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins } ${RUNNING_DIR}/reports/${STAGE}/setup_all.rpt"
lappend parallel_execute_list "{report_timing -physical -crosstalk_delta  -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins -delay_type min} ${RUNNING_DIR}/reports/${STAGE}/hold_all.rpt"
lappend parallel_execute_list "{report_timing -physical -crosstalk_delta -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins -path_type full_clock_expanded -from \[all_registers\] -to \[all_registers\]} ${RUNNING_DIR}/reports/${STAGE}/setup_reg2reg.rpt"
lappend parallel_execute_list "{report_timing -physical -crosstalk_delta  -include_hierarchical_pins -slack_lesser_than 0 -max_paths 10000 -derate  -capacitance -transition_time -nosplit -nets -input_pins -delay_type min -path_type full_clock_expanded -from \[all_registers\] -to \[all_registers\]} ${RUNNING_DIR}/reports/${STAGE}/hold_reg2reg.rpt"
lappend parallel_execute_list "{report_constraint -all_violators -max_transition -max_capacitance -min_pulse_width -min_period -scenarios \[get_scenarios -filter active\] -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_constraint.rpt"
lappend parallel_execute_list "{report_qor -scenarios \[get_scenarios -filter active\] -nosplit}  ${RUNNING_DIR}/reports/${STAGE}/report_qor.rpt"
lappend parallel_execute_list "{report_qor -summary}  ${RUNNING_DIR}/reports/${STAGE}/report_qor_summary.rpt"
lappend parallel_execute_list "{report_clocks -mode \[all_modes\] -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_clocks.rpt"
lappend parallel_execute_list "{report_design -library -netlist -floorplan -routing -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_design.rpt"
lappend parallel_execute_list "{report_tracks -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_tracks.rpt"
lappend parallel_execute_list "{report_references -hierarchical -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_reference.rpt"
lappend parallel_execute_list "{report_ignored_layers } ${RUNNING_DIR}/reports/${STAGE}/report_ignored_layers.rpt"
lappend parallel_execute_list "{report_extraction_options -corners \[all_corners\] } ${RUNNING_DIR}/reports/${STAGE}/report_extraction_options.rpt"
lappend parallel_execute_list "{report_power -verbose -scenarios \[get_scenarios -filter active\] -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_power.rpt"
lappend parallel_execute_list "{report_modes -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_modes.rpt"
lappend parallel_execute_list "{report_pvt -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_pvt.rpt"
lappend parallel_execute_list "{report_corners \[all_corners\] } ${RUNNING_DIR}/reports/${STAGE}/report_corners.rpt"
lappend parallel_execute_list "{count_buf_inv -dont_suppress_empty -extra_stats}  ${RUNNING_DIR}/reports/$STAGE/count_buf_inv.rpt"


foreach_in_collection pg [get_path_groups] {
	set gname [get_object_name $pg]
	lappend parallel_execute_list "{report_timing -group $gname -crosstalk_delta  -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate  -capacitance -transition_time -nosplit -nets -input_pins } ${RUNNING_DIR}/reports/${STAGE}/setup_[string map  {* "" / "_"} [get_object_name $pg]].rpt"
	lappend parallel_execute_list "{report_timing -group $gname -crosstalk_delta -physical -include_hierarchical_pins -slack_lesser_than 0 -max_paths 1000 -derate  -capacitance -transition_time -nosplit -nets -input_pins -delay_type min} ${RUNNING_DIR}/reports/${STAGE}/hold_[string map  {* "" / "_"} [get_object_name $pg]].rpt"

	
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



### DRC reports ###

	if {[get_drc_error_data -quiet zroute.err] == ""} {open_drc_error_data zroute.err}
	redirect -tee -file ${RUNNING_DIR}/reports/${STAGE}/report_drc.rpt {report_drc_error -error_data zroute.err}
	redirect -tee -file ${RUNNING_DIR}/reports/${STAGE}/report_drc_matrix.rpt {report_drc_error -error_data zroute.err  -report_type matrix}

	if {[lsearch [get_attribute [get_drc_error_types -error_data zroute.err] name] "Short"] != -1} {
		redirect -tee -file ${RUNNING_DIR}/reports/${STAGE}/report_shorts_per_layer.rpt {report_drc_errors -error_data zroute.err -error_type Short}
		redirect -tee -file ${RUNNING_DIR}/reports/${STAGE}/report_shorts_per_layer_matrix.rpt {report_drc_errors -error_data zroute.err -error_type Short -report_type matrix}
	}

# need another LICENSE FOR THAT
#    redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_safety_status {report_safety_status}

  if {[get_app_option_value -name time.si_enable_analysis]} {
                set RM_current_value_enable_si true
        }
        puts "RM-info: time.si_enable_analysis is set to false ...\n"
        set_app_options -name time.si_enable_analysis -value false

        puts "RM-info: Reporting timing and QoR in non-SI mode ...\n"
        ## QoR
        redirect -file ${RUNNING_DIR}/reports/${STAGE}/no_si.report_qor {report_qor -scenarios [get_scenarios -filter active] -nosplit}
        redirect -tee -append -file ${RUNNING_DIR}/reports/${STAGE}/no_si.report_qor {report_qor -summary -nosplit}


write_qor_data -output $RUNNING_DIR/reports/qor_data -report_group routed -report_list "gui_routing_drcs" -label "${STAGE}"
if {[file exists  $RUNNING_DIR/reports/compare_qor_data ]} {exec rm -r  $RUNNING_DIR/reports/compare_qor_data } 
compare_qor_data -output $RUNNING_DIR/reports/compare_qor_data -run_locations $RUNNING_DIR/reports/qor_data -force


        ## Timing (-variation enabled for POCV)
        if {[get_app_option_value -name time.pocvm_enable_analysis]} {
                redirect -file ${RUNNING_DIR}/reports/${STAGE}/no_si.report_timing.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
                -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -variation -nosplit}
                redirect -file ${RUNNING_DIR}/reports/${STAGE}//no_si.report_timing.no_variation.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
                -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -nosplit}
        } else {
                redirect -file ${RUNNING_DIR}/reports/${STAGE}/no_si.report_timing.max {report_timing -delay max -scenarios [get_scenarios -filter active] \
                -input_pins -nets -transition_time -capacitance -attributes -physical -derate -report_by group -nosplit}
        }

        ## Restore user default of time.si_enable_analysis
        if {[info exists RM_current_value_enable_si] && ${RM_current_value_enable_si}} {
                set_app_options -name time.si_enable_analysis -value true
        }


	analyze_design_violations -type setup -stage postroute -output ${RUNNING_DIR}/reports/${STAGE}/analyze_design_violations
	analyze_design_violations -type hold -stage postroute -output ${RUNNING_DIR}/reports/${STAGE}/analyze_design_violations



### innovus ###
# TODO report_skew_groups -out_file reports/route/route_skew_groups.rpt
# TODO report_clock_trees -histograms -num_transition_time_violating_pins 5000 -out_file reports/route/route_clock_trees.rpt
# TODO report_clock_trees  -num_transition_time_violating_pins 5000 -out_file reports/route/route_clock_trees.rpt

#source /bespace/users/rinate/nextflow/be_work/brcm3/grid_quad_west_filler_row_top/work_051224/fusion/20250120_reports/user_report_inst_vt.tcl
user_report_inst_vt ${RUNNING_DIR}/reports/route/threshold_instance_count.rpt

redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_multibit.rpt {report_multibit}

#source /bespace/users/rinate/nextflow/be_work/brcm3/grid_quad_west_filler_row_top/work_051224/fusion/20250120_reports/multiport_checker.tcl 
be_check_multiport



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

#gui_load_power_density_mm -scenario func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold

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

be_reports -all
#===========================================
# be checklist
#===========================================
# cd to pnr..
set current_location [pwd]
cd ${RUNNING_DIR}
puts "-I- current location --> [pwd]"

# buf/inv count & info
buf_inv_info 

# clock tree ndr : route rule & violations:
 check_clock_ndr 

#  route quality
 route_quality_check 

#  check long nets
 check_nets_length 

# 6. dont use cell check
 dont_use_cells_check 


redirect_and_catch "exec ./scripts/bin/fc_be_checklist.tcl $STAGE"

#===========================================
# Zip the reports files
#===========================================

set files [exec find ${RUNNING_DIR}/reports/${STAGE}/ -maxdepth 1 -type f ! -name *.gz ! -name ${STAGE}.be.qor]
foreach f $files {exec gzip -f $f}

#===========================================
exec touch .${STAGE}_reports_done
### upload tables to grafana
set status [catch {exec scripts/bin/run_db.csh $STAGE} msg]
# back to parallel_run dir
cd $current_location
puts "-I- current location --> [pwd]"

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end



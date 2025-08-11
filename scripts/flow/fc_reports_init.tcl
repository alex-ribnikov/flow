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


set parallel_execute_list [list]
lappend parallel_execute_list "{report_app_options } ${RUNNING_DIR}/reports/${STAGE}/report_app_options.all.rpt"
lappend parallel_execute_list "{report_app_options  -non_default} ${RUNNING_DIR}/reports/${STAGE}/report_app_options.non_default.rpt"
lappend parallel_execute_list "{check_design -ems_database ${RUNNING_DIR}/reports/${STAGE}/check_design.pre_compile.ems -checks {pre_placement_stage} } ${RUNNING_DIR}/reports/${STAGE}/check_design.rpt"
lappend parallel_execute_list "{check_physical_constraints } ${RUNNING_DIR}/reports/${STAGE}/check_physical_constraints.rpt"
lappend parallel_execute_list "{report_net_fanout -threshold 100 } ${RUNNING_DIR}/reports/${STAGE}/report_net_fanout.rpt"
lappend parallel_execute_list "{report_clock_gating -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_clock_gating.rpt"
lappend parallel_execute_list "{report_clock_gating -ungated } ${RUNNING_DIR}/reports/${STAGE}/report_ungated_registers.rpt"
lappend parallel_execute_list "{check_netlist -hierarchical -summary } ${RUNNING_DIR}/reports/${STAGE}/check_netlist_summary.rpt"
lappend parallel_execute_list "{check_netlist -hierarchical } ${RUNNING_DIR}/reports/${STAGE}/check_netlist.rpt"
lappend parallel_execute_list "{report_dont_touch -all } ${RUNNING_DIR}/reports/${STAGE}/dont_touch_cells.rpt"
lappend parallel_execute_list "{report_timing -max_paths 1000 -derate    -nosplit -nets -input_pins  -pba_mode none } ${RUNNING_DIR}/reports/${STAGE}/${STAGE}_all.rpt"
lappend parallel_execute_list "{report_clocks -mode \[all_modes\] -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_clocks.rpt"
lappend parallel_execute_list "{report_design -library -netlist -floorplan -nosplit } ${RUNNING_DIR}/reports/${STAGE}/report_design.rpt"
#lappend parallel_execute_list "{ } "

set cmd "parallel_execute {\n"
foreach line $parallel_execute_list {
	set cmd "$cmd $line\n"
}
set cmd "$cmd }"
echo $cmd
eval $cmd




#be_report_feedthroughs ./reports/init/feedthrough.rpt


### app options ###
#report_app_options -as_list > ${RUNNING_DIR}/reports/${STAGE}/report_app_options.all.rpt
#report_app_options -as_list -non_default > ${RUNNING_DIR}/reports/${STAGE}/report_app_options.non_default.rpt

### Check design ###
#puts "Info: check design ...\n"
#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/check_design.rpt {check_design -ems_database ${RUNNING_DIR}/reports/${STAGE}/check_design.pre_compile.ems -checks {pre_placement_stage}}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt check_design
	
### Check physical constraints ###
#puts "Info: check physical constraints ...\n"
#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/check_physical_constraints.rpt {check_physical_constraints}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt check_physical_constraints

set size_unplaced_macro [sizeof_collection [get_cells -hierarchical -filter {is_hard_macro && physical_status == unplaced}]]
if {$size_unplaced_macro} {
	puts "ERROR: unplaced macro ...\n"
	eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/unplaced_macro.rpt {get_attribute [get_cells -hierarchical -filter {is_hard_macro && physical_status == unplaced}] full_name} " ${RUNNING_DIR}/reports/${STAGE}/runtime.txt unplaced_macro		
}

puts "Info: check unplaced ports ...\n"
set size_unplaced_port [sizeof_collection [get_ports -filter {physical_status == unplaced}]]
if {$size_unplaced_port} {
	puts "ERROR: unplaced ports ...\n"	
	eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/check_unplaced_ports.rpt {get_attribute [get_ports -filter {physical_status == unplaced}] name }" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt check_unplaced_ports
}

### Check high FO nets ###
#puts "Info: check high FO nets ...\n"
#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_net_fanout.rpt {report_net_fanout -threshold 100 }" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_net_fanout
	
	
### CG - summary ###
#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_clock_gating.rpt {report_clock_gating -nosplit}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_clock_gating	

### CG - why ungated registers ###
#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_ungated_registers.rpt {report_clock_gating -ungated}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_ungated_registers	

### Check netlist summary - include floating inputs & input driven by 0/1 & multi_driven inputs ###
#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/check_netlist_summary.rpt {check_netlist -hierarchical -summary}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt check_netlist_summary
#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/check_netlist.rpt {check_netlist -hierarchical}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt check_netlist
	
### Macro count ###
set macro_count [sizeof_collection [get_cells -hierarchical -filter is_hard_macro]]	
be_report_macro_count > ${RUNNING_DIR}/reports/${STAGE}/report_macro_count.rpt 

### DONT_USE list ###
eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/dont_use_cells.rpt {get_lib_cells -filter {valid_purposes == '' || dont_use}}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt dont_use_cells	

	
### DONT_TOUCH list ###
#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/dont_touch_cells.rpt {report_dont_touch -all}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_dont_touch
	
### Check timing ###
#puts "Info: check timing ...\n"
eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/check_timing.rpt {check_timing -exclude {missing_dslg}}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt check_timing


### Report timing - all ###
#set pba_mode [get_app_option_value -name time.pba_optimization_mode] 
#eee "report_timing -max_paths 1000 -derate    -nosplit -nets -input_pins  -pba_mode none > ${RUNNING_DIR}/reports/${STAGE}/${STAGE}_all.rpt" runtime.txt report_timing_all


### Reports for QOR ###

#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_clocks.rpt {report_clocks -mode [all_modes] -nosplit}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_clocks
#eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_design.rpt {report_design -library -netlist -floorplan -nosplit}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_design

eee "redirect -file ${RUNNING_DIR}/reports/${STAGE}/report_qor.rpt {report_qor -scenarios [get_scenarios -filter active] -nosplit}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_qor
eee "redirect -tee -append -file ${RUNNING_DIR}/reports/${STAGE}/report_qor.rpt {report_qor -summary -nosplit}" ${RUNNING_DIR}/reports/${STAGE}/runtime.txt report_qor

write_qor_data -output $RUNNING_DIR/reports/qor_data -report_group unmapped -label "[file tail ${RUNNING_DIR}]_${STAGE}"
if {[file exists  $RUNNING_DIR/reports/compare_qor_data ]} {exec rm -r  $RUNNING_DIR/reports/compare_qor_data } 
compare_qor_data -output $RUNNING_DIR/reports/compare_qor_data -run_locations $RUNNING_DIR/reports/qor_data -force

### Fp & preplace snapshots ###

gui_start
gui_set_layout_layer_visibility [get_attribute [get_layers] name] -toggle
gui_change_highlight -remove -all_colors
gui_write_window_image -format png -file ${RUNNING_DIR}/reports/${STAGE}/snapshots/${DESIGN_NAME}.fp.png
gui_select_by_name -object_type Cells -highlight
gui_write_window_image -format png -file ${RUNNING_DIR}/reports/${STAGE}/snapshots/${DESIGN_NAME}.pre_place.png
gui_change_highlight -remove -all_colors
gui_stop	



### QOR ###
be_reports    
#===========================================
# be checklist
#===========================================
# cd to pnr..
set current_location [pwd]
cd ${RUNNING_DIR}
puts "-I- current location --> ${RUNNING_DIR}"
exec touch .${STAGE}_reports_done

#------------------------------------------------------
# TMP source:
#source -v -e scripts_local/fc_be_checkers.tcl
#------------------------------------------------------
# check unplaced Macros
check_macro_placement
# check unplaced Ports 
check_unplace_ports
# calculate physical cells
physical_cells
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
puts "-I- current location --> $current_location"

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end



	

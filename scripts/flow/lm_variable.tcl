set scale_factor 2000
set DELIVERY_ [lindex [split [pwd] "/"] end-3]
set SETUP_FILE "[pwd]/scripts/setup/setup.brcm5.tcl"
set TECH_FILE [lindex [exec grep "set TECH_FILE" $SETUP_FILE] end]



#set LEF_FILE [lindex $LEF_FILE_LIST [lsearch -regexp $LEF_FILE_LIST $BLOCK_NAME]]
if {[regexp tsmc5ff_ $BLOCK_NAME]} {
	set DELIVERY "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/${}"
	set LEF_FILE [glob ${DELIVERY}/${BLOCK_NAME}/lef/${BLOCK_NAME}.lef]
	set logic_db [glob ${DELIVERY}/${BLOCK_NAME}/db/${BLOCK_NAME}*.db]
	
	
	
} elseif {[regexp M5 $BLOCK_NAME]}  {
	set DELIVERY "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/${DELIVERY_}/memory/prod/"
	set LEF_FILE [glob ${DELIVERY}/lay/lef/${BLOCK_NAME}.lef]
	set logic_db [glob ${DELIVERY}/tim/etm/${BLOCK_NAME}*.db ]
	set pattern "\\S+${BLOCK_NAME}_ESTIMATED\\S+"
	set logic_db [regsub -all $pattern $logic_db ""]
#	set pattern "\\S+${BLOCK_NAME}_wrapper\\S+"
#	set logic_db [regsub -all $pattern $logic_db ""]
}

#set logic_db_ [list]
#foreach PVT_CORNER_index [lsearch -all -regexp [array get pvt_corner]  $BLOCK_NAME] {
#	lappend logic_db_ [lindex [lindex [array get pvt_corner] $PVT_CORNER_index] [lsearch -regexp  [lindex [array get pvt_corner] $PVT_CORNER_index] $BLOCK_NAME]]
#}
#regsub -all "lib.gz" $logic_db_ db logic_db



set sel_ndm_flow normal
set sh_continue_on_error true
set_app_options -as_user_default -name lib.workspace.group_libs_naming_strategies -value "common_prefix common_suffix common_prefix_and_common_suffix first_logical_lib_name"
set_app_options -as_user_default -name lib.workspace.allow_commit_workspace_overwrite -value true
set_app_options -as_user_default -name lib.workspace.group_libs_create_slg -value false
set_app_options -as_user_default -name lib.workspace.allow_missing_related_pg_pins -value true
set_app_options -as_user_default -name lib.workspace.remove_frame_bus_properties -value true
set_app_options -as_user_default -name lib.workspace.save_design_views -value true 
set_app_options -as_user_default -name lib.workspace.save_layout_views -value true 
#set_app_options -as_user_default -name lib.workspace.group_libs_macro_grouping_strategy -value single_cell_per_lib
set_app_options -as_user_default -name link.require_physical -value true
set_app_options -as_user_default -name design.bus_delimiters -value {[]}
set_app_options -as_user_default -name lib.workspace.keep_all_physical_cells -value true

set_app_options -as_user_default -name lib.physical_model.block_all -value auto
set_app_options -as_user_default -name lib.physical_model.connect_within_pin -value true
set_app_options -as_user_default -name lib.physical_model.hierarchical -value true
set_app_options -as_user_default -name lib.physical_model.merge_metal_blockage -value false
set_app_options -as_user_default -name lib.physical_model.preserve_metal_blockage -value auto

set_app_options -as_user_default -name lib.logic_model.use_db_rail_names -value true

set diode_cells "*DIODE*"
set diode_pin "i"

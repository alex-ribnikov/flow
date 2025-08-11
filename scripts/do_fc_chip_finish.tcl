#################################################################################################################################################################################
#																						#
#	this script will run Fusion_compiler  																		#
#	variable received from shell are:																	#
#		CPU		- number of CPU to run.8 per license														#
#		DESIGN_NAME	- name of top model																#
#		IS_PHYSICAL	- runing physical synthesis															#
#		SCAN 		- insert scan to the design															#
#		OCV 		- run with ocv 																	#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	27/11/2024	Royl	initial script																#
#																						#
#																						#
#################################################################################################################################################################################
if {[info exists LABEL]}         {puts "LABEL $LABEL"} else {set LABEL "None" }

if {[info exists CHIP_FINISH_OPEN_BLOCK] && $CHIP_FINISH_OPEN_BLOCK != "None"} {
	set STAGE chip_finish_from_$CHIP_FINISH_OPEN_BLOCK
} else {
	set STAGE chip_finish
}

source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
if {![file exists ./reports/${STAGE}]} {exec mkdir -pv ./reports/${STAGE}}
if {![file exists ./reports/qor_data]} {exec mkdir -pv ./reports/qor_data}
if {![file exists ./reports/${STAGE}/snapshots]} {exec mkdir -pv ./reports/${STAGE}/snapshots}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.

set_host_options -max_cores $CPU

script_runtime_proc -start


#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	set setup_file scripts/setup/setup.${PROJECT}.tcl
}
source -v -e $setup_file
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v -e ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v -e scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------

set_svf out/svf/${DESIGN_NAME}_${STAGE}.svf
open_lib out/${DESIGN_NAME}_lib
if {[info exists CHIP_FINISH_OPEN_BLOCK] && $CHIP_FINISH_OPEN_BLOCK != "None"} {
	copy_block -from ${DESIGN_NAME}/${CHIP_FINISH_OPEN_BLOCK} -to ${DESIGN_NAME}/${STAGE} -force
} else {
	if {[info exists ECO_NUM] && $ECO_NUM != "" && $ECO_NUM != "None"} {
		puts "-I- read design from eco$ECO_NUM label"
		copy_block -from ${DESIGN_NAME}/eco${ECO_NUM} -to ${DESIGN_NAME}/chip_finish -force
	} elseif {[info exists READ_DB] && $READ_DB != "" && $READ_DB != "None"} {
		puts "-I- read design from $READ_DB label"
		copy_block -from ${DESIGN_NAME}/${READ_DB} -to ${DESIGN_NAME}/chip_finish -force
	} else {
		puts "-I- read design from route db"
		copy_block -from ${DESIGN_NAME}/route -to ${DESIGN_NAME}/chip_finish -force
	}
}

current_block ${DESIGN_NAME}/${STAGE}
link_block


#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/fc_variables.tcl]} {
	puts "-I- reading fc_variables file from scripts_local"
	source -v -e scripts_local/fc_variables.tcl
} else {
	puts "-I- reading fc_variables file from scripts"
	source -v -e scripts/flow/fc_variables.tcl
}
#------------------------------------------------------------------------------
# chip finish extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/chip_finish_setting.tcl]} {
	puts "-I- reading chip_finish_setting file from scripts_local"
	source -v -e ./scripts_local/chip_finish_setting.tcl
}
#------------------------------------------------------------------------------
# connect_pg_net
#------------------------------------------------------------------------------
if {[file exists scripts_local/connect_pg_net.tcl]} {
        puts "-I- reading connect_pg_net file from scripts_local"
        source -e -v scripts_local/connect_pg_net.tcl
} else {
        puts "-I- reading connect_pg_net file from scripts"
        source -e -v scripts/flow/connect_pg_net.tcl
}



#------------------------------------------------------------------------------
# add fillers
#------------------------------------------------------------------------------
remove_placement_blockages [get_placement_blockages -filter blockage_type!=hard]
remove_placement_spacing_rules -all
#derive_pg_mask_constraint -derive_cut_mask -check_fix_shape_drc -overwrite
set_app_options -name chf.create_stdcell_fillers.follow_orders -value 1

# Insert metal filler cells 
create_stdcell_fillers -rules {check_pnet color_safe} -lib_cells $ALL_DCAP_CELLS -prefix FILL_DCAP -leakage_vt_order {VTEL_N VTEL_P VTUL_N VTUL_P VTULN_LL VTULP_LL VTLN_LL VTLP_LL VTL_N VTL_P VTS_N VTS_P }
if {[file exists scripts_local/connect_pg_net.tcl]} {
        puts "-I- reading connect_pg_net file from scripts_local"
        source -e -v scripts_local/connect_pg_net.tcl
} else {
        puts "-I- reading connect_pg_net file from scripts"
        source -e -v scripts/flow/connect_pg_net.tcl
}

remove_stdcell_fillers_with_violation; # Remove DCAPs with shorts on M1

# Run non-timing driven route cleanup after DCAPs
#if {[get_app_option_value -name route.detail.timing_driven]} {
#	set_app_option -name route.detail.timing_driven -value false
#	set saved_rte_dtl_tmg_drvn_value true
#}

######################################################
# Incremental route after M1 CCAP cells
######################################################


#set_app_options -name route.detail.insert_diodes_during_routing -value false
#route_detail -incremental true

# Insert non-metal filler cells after route cleanup
create_stdcell_fillers -rules {check_pnet color_safe} -lib_cell $ALL_FILLER_CELLS -prefix FILL -leakage_vt_order {VTEL_N VTEL_P VTUL_N VTUL_P VTULN_LL VTULP_LL VTLN_LL VTLP_LL VTL_N VTL_P VTS_N VTS_P }
if {[file exists scripts_local/connect_pg_net.tcl]} {
        puts "-I- reading connect_pg_net file from scripts_local"
        source -e -v scripts_local/connect_pg_net.tcl
} else {
        puts "-I- reading connect_pg_net file from scripts"
        source -e -v scripts/flow/connect_pg_net.tcl
}

check_legality

## M0 Routing flow require cut metal addition for CM0
create_cut_metals

# Add BCM0V
#reset_app_options fignoff.create_metal_fill.*

#set_app_option -name signoff.create_metal_fill.runset -value /project/foundry/TSMC/N3/TSMC/PDK/BEOL_dummy/snps/LOGIC_TopMr_DUMMY/Dummy_BEOL_ICV_3nm_E_19M_1Xa1Xb1Xc1Xd1Ya1Yb6Y2Yy2Yx2R_014.11_1a
#set_app_option -name signoff.physical.merge_stream_files -value $STREAM_FILE_LIST
#set_app_option -name signoff.physical.layer_map_file -value $STREAM_LAYER_MAP_FILE

#if {[info exists CELLNAME_MAP_FILES]  && $CELLNAME_MAP_FILES != ""} { set_app_option -name signoff.physical.rename_cell_files -value $CELLNAME_MAP_FILES }

#set_app_options -name signoff.create_metal_fill.m0_min_rail_width -value 0.027
#signoff_create_metal_fill -track_fill tsmc3 -output_colored_fill true -fill_all_tracks true -select_layer {M0} -active_fill drc -add_cut_metal true



#------------------------------------------------------------------------------
# write out files
#------------------------------------------------------------------------------
save_block 
create_frame \
	-merge_metal_blockage true \
	-block_all true \
	-remove_non_pin_shapes { {PO all} {M0 all} {VIA0 all} {M1 all} {VIA1 all} {M2 all} {VIA2 all} {M3 all} {VIA3 all} {M4 all} {VIA4 all} {M5 all} {VIA5 all} {M6 all} {VIA6 all} {M7 all} {VIA7 all} {M8 all} {VIA8 all} {M9 all} {VIA9 all} {M10 all} {VIA10 all} {M11 all} {VIA11 all} {M12 all} {VIA12 all} {M13 all} {VIA13 all} {M14 all} {VIA14 all} {M15 all} {VIA15 all} {M16 all} {VIA16 all} {M17 all} {VIA17 all} {M18 all} {VIA18 all}}

if {[info exists CREATE_ABSTRACT] && $CREATE_ABSTRACT == "true" } {
	#set_scenario_status [get_scenarios $ALL_SCENARIOS] -active true
	set_app_options -name abstract.annotate_power -value true
	create_abstract -read_only
#	create_frame -block_all true
}
save_lib 

write_verilog -compress gzip out/netlist/${DESIGN_NAME}.${STAGE}.v.gz
write_def -compress gzip -include_tech_via_definitions -include { cells ports pg_metal_fills blockages specialnets nets routing_rules} out/def/${DESIGN_NAME}.${STAGE}.def
set exclude_layers "\[get_layers -filter {name !~ 'M\d+$' || name > 'M${MAX_ROUTING_LAYER}'}\]"
set cmd "write_lef -include cell -exclude_layers $exclude_layers  out/lef/${DESIGN_NAME}.${STAGE}.lef"
eval $cmd


check_shapes -uncolored

# X -allow_design_mismatch
# removed -long_names
# ? -connect_below_cut_metal
set cmd "write_oasis \
	./out/oas/${DESIGN_NAME}_empty.oas \
        -verbose \
	-write_default_layers [list [get_object_name [get_layers VIA* -filter "number_of_masks==2"]]] \
	-lib_cell_view frame \
	-hierarchy all \
	-output_pin {all} \
	-keep_data_type \
	-units 2000 \
	-text_for_pin \
	-layer_map $GDS_MAP_FILE \
        -layer_map_format icc2 "
	
if {[info exists CELLNAME_MAP_FILES]  && $CELLNAME_MAP_FILES != ""} { set cmd "$cmd -rename_cell { $CELLNAME_MAP_FILES }" }
echo $cmd
eval $cmd

set cmd "write_oasis \
./out/oas/${DESIGN_NAME}_merge.oas \
-verbose \
-write_default_layers [list [get_object_name [get_layers VIA* -filter "number_of_masks==2"]]] \
-merge_files \"${STREAM_FILE_LIST}\" \
-lib_cell_view frame \
-hierarchy all \
-output_pin {all} \
-keep_data_type \
-unit 2000 \
-text_for_pin \
-layer_map $GDS_MAP_FILE \
-layer_map_format icc2"	


if {[info exists CELLNAME_MAP_FILES]  && $CELLNAME_MAP_FILES != ""} { set cmd "$cmd -rename_cell { $CELLNAME_MAP_FILES }" }
echo $cmd
eval $cmd





#------------------------------------------------------------------------------
#  Report s
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------

report_msg -summary
print_message_info -ids * -summary


script_runtime_proc -end

#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
} else {

   exit
  
}


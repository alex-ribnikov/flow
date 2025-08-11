#################################################################################################################################################################################
#																						#
#	this script will run innovus CHIP FINISH stage  															#
#	variable received from shell are:																	#
#		CPU		 - number of CPU to run.8 per license														#
#		BATCH 		 - run in batch mode																#
#		DESIGN_NAME	 - name of top model																#
#		ADD_METAL_FILL	 - add metal fill to design															#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	27/01/2021	Royl	initial script																#
#	0.2	22/02/2021	Royl	add metal fill using Pegasus														#
#																						#
#																						#
#################################################################################################################################################################################
set_db source_verbose false

set STAGE chip_finish
set RUNNING_LOCAL_SCRIPTS [list]

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}

script_runtime_proc -start
check_script_location

if {![file exists reports/chip_finish]} {exec mkdir -pv reports/chip_finish}
#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v scripts_local/setup.tcl
} else {
	puts "-I- reading ${PROJECT} setup file from scripts"
	source -v ./scripts/setup/setup.${PROJECT}.tcl
}
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}
if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	check_script_location scripts_local/supplement_setup.tcl
	source -v scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
set_multi_cpu_usage -local_cpu $CPU 

set_db init_delete_assigns 1
set_db init_power_nets        $PWR_NET
set_db init_ground_nets       $GND_NET
set_db init_keep_empty_modules true


#------------------------------------------------------------------------------
# load db base
#------------------------------------------------------------------------------
if {[info exists ECO_NUM] && $ECO_NUM != "" && $ECO_NUM != "None"} {
	puts "-I- read design from eco$ECO_NUM db"
	read_db out/db/${DESIGN_NAME}.eco${ECO_NUM}.enc.dat
} elseif {[info exists READ_DB] && $READ_DB != "" && $READ_DB != "None"} {
	puts "-I- read design from $READ_DB db"
	read_db out/db/${DESIGN_NAME}.$READ_DB.enc.dat
} else {
	puts "-I- read design from route db"
	read_db out/db/${DESIGN_NAME}.route.enc.dat
}


#------------------------------------------------------------------------------
# read  ilm design
#------------------------------------------------------------------------------
if {[info exists ILM_FILES] && $ILM_FILES != ""} {
   if {[get_db is_ilm_flattened]} {unflatten_ilm}
   foreach ilm_block_file $ILM_FILES {
   	set ilm_block_name [lindex [split $ilm_block_file '/'] end-5]
	#reset_ilm -cell $ilm_block_name
	read_ilm -cell $ilm_block_name -dir $ilm_block_file
   }
   flatten_ilm
   report_ilm_status > reports/${STAGE}/report_ilm_status.rpt
   foreach mmm [get_db / .constraint_modes.name] {
   	update_constraint_mode  -name $mmm -ilm_sdc_files  $sdc_files($mmm)
   }
}

#------------------------------------------------------------------------------
# connect P/G pins to nets
#------------------------------------------------------------------------------
if {[file exists scripts_local/connect_global_net.tcl]} {
	puts "-I- reading connect_global_net file from scripts_local"
	source -e -v scripts_local/connect_global_net.tcl
} else {
	puts "-I- reading connect_global_net file from scripts"
	source -e -v scripts/flow/connect_global_net.tcl
}

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/INN_variables.tcl]} {
	puts "-I- reading INN_variables file from scripts_local"
	source -v scripts_local/INN_variables.tcl
} else {
	puts "-I- reading INN_variables file from scripts"
	source -v scripts/flow/INN_variables.tcl
}

#------------------------------------------------------------------------------
# extra setting and operations 
#------------------------------------------------------------------------------
set hook_script "./scripts_local/chip_finish_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

#delete_filler 

set_db add_fillers_with_drc false
set_db add_fillers_check_drc true


set DCAP_LIST "$ECO_DCAP_LIST $DCAP_CELLS_LIST"
set_db add_fillers_cells $DCAP_LIST
set_db add_fillers_prefix DCAP_${DESIGN_NAME}
set_db add_fillers_check_drc true
add_fillers 


reset_db add_fillers_prefix
set_db add_fillers_prefix FILL_${DESIGN_NAME}
set_db add_fillers_swap_cell $ADD_FILLERS_SWAP_CELL
set_db add_fillers_cells   $FILLERS_CELLS_LIST
add_fillers -check_drc true



if {[get_db design_process_node] > 5} {
	swap_well_taps -cells $SWAP_WELL_TAPS -default_cell $TAPCELL -diffusion_forbidden_spacing $DIFFUSION_FORBIDDEN_SPACING -violation_report tap_violations_doSwap.rpt -swap_report reports/chip_finish/tap_swap.rpt -check_only
}
#------------------------------------------------------------------------------
# add metal fill
#------------------------------------------------------------------------------
#####
# TODO: Missing $METAL_FILL_RUNSET AND $GDS_FILE_LIST
#####
if {[info exists ADD_METAL_FILL] && $ADD_METAL_FILL == "true" && [regexp "pegasus" $::env(PATH)]} {
	set_metal_fill_signoff_config \
		-die_area_as_boundary \
		-rule_file $METAL_FILL_RUNSET \
		-layer_map_file $GDS_MAP_FILE \
		-units 2000 \
		-uniquify_cell_names \
		-die_area_as_boundary \
		-merge $GDS_FILE_LIST

	delete_metal_fill
	add_metal_fill_signoff -fill
	add_metal_fill_signoff -view_fills

}


#------------------------------------------------------------------------------
# connect P/G pins to nets
#------------------------------------------------------------------------------
if {[file exists scripts_local/connect_global_net.tcl]} {
	puts "-I- reading connect_global_net file from scripts_local"
	source -e -v scripts_local/connect_global_net.tcl
} else {
	puts "-I- reading connect_global_net file from scripts"
	source -e -v scripts/flow/connect_global_net.tcl
}


#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.${STAGE}.def.gz
write_lef_abstract -5.8 -stripe_pins -property out/lef/${DESIGN_NAME}.${STAGE}.lef

create_gui_shape -layer adjusted_boundary -polygon [join [ get_computed_shapes [get_db design:${DESIGN_NAME} .boundary] SIZEX -0.0255 -output polygon ]  ]



##### standard wbWriteLEC
write_do_lec  lec.innovusPostC.do \
	-flat \
	-golden_design ../syn/out/${DESIGN_NAME}.Syn.v.lec.gz \
	-revised_design out/db/${DESIGN_NAME}.${STAGE}.enc.dat/${DESIGN_NAME}.v.gz \
	-log_file log/lec.innovusPostC.log \
	-checkpoint innovusPostC

write_stream \
	out/gds/${DESIGN_NAME}_empty.oas.gz \
	-format oasis \
	-unit 2000 \
	-die_area_as_boundary \
	-map_file $GDS_MAP_FILE 

write_stream \
	out/gds/${DESIGN_NAME}_merge.oas.gz \
	-unit 2000 \
	-die_area_as_boundary \
        -map_file $GDS_MAP_FILE \
	-merge $STREAM_FILE_LIST \
        -format oasis


write_netlist \
	-phys \
	-exclude_insts_of_cells [get_db [get_db base_cells -if ".name == *FILLER* || .name == *BORDER* || .name == *_TIE || .name == *_TIESMALL"] .name] \
	-exclude_leaf_cells \
	out/netlist/${DESIGN_NAME}.lvs.v


#------------------------------------------------------------------------------
# check place 
#------------------------------------------------------------------------------
redirect {check_place} > reports/${STAGE}/check_place_summary.rpt
check_place reports/${STAGE}/check_place_detail.rpt
#------------------------------------------------------------------------------
# design check 
#------------------------------------------------------------------------------
check_drc -out_file reports/${STAGE}/chip_finish_check_drc.rpt
check_process_antenna
check_connectivity

#===================================================================
#    Post-chip_finish  checkers, for be_checklist 
#===================================================================
 set pnr [lindex [ split  [exec pwd] "/" ] end]
 regsub "pnr" $pnr  "" prefix
 set WA [join [regsub "pnr.*" [split [exec pwd] "/"] ""] "/"]

# 1. check constraints, 
 eee  dcap_cells ${STAGE}.time
#===================================================================


#------------------------------------------------------------------------------
# create SPEF
#------------------------------------------------------------------------------
if {[info exists CREATE_SPEF] && ($CREATE_SPEF == "true" || [regexp "chip_finish" $CREATE_SPEF] )} {
   set_analysis_view -setup $scenarios(setup) -hold $scenarios(hold) -dynamic $scenarios(dynamic) -leakage $scenarios(leakage)

   set start_t [clock seconds]
   extract_rc
   foreach rc_corner_ [get_db [get_db rc_corners -if ".is_active"] .name] {
	set cmd  "write_parasitics -rc_corner $rc_corner_ -spef_file out/spef/${DESIGN_NAME}.${STAGE}.spef.${rc_corner_}.gz"
	eee $cmd
   }
   set end_t [clock seconds]
   puts "-I- Elapse time for running write_parasitics is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
}


#------------------------------------------------------------------------------
# Hierarchical flow
#------------------------------------------------------------------------------
#write_ilm -to_dir out/ilm/${STAGE} -overwrite  -model_type all
#foreach rc_corner_ [get_db [get_db rc_corners -if ".is_active"] .name] {
#   write_parasitics -rc_corner $rc_corner_ -spef_file out/spef/${DESIGN_NAME}.${STAGE}_${rc_corner_}.spef.gz
#}

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
report_resource

#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}_done

# activated the be_checklist after stage is done.
redirect_and_catch "./scripts/bin/be_checklist.tcl $STAGE"


if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
}

if {![info exists BATCH] || $BATCH == "true"} {
	exit
}



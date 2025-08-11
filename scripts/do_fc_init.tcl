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

if {[info exists INC_INIT] && !$INC_INIT} { set STAGE init } { set STAGE inc_init}

set start_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - Start running $STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
# create proc just for synopsys
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
# read tool variables
#------------------------------------------------------------------------------

	if {[file exists scripts_local/fc_pre_design_variables.tcl]} {
		puts "-I- reading fc_pre_design_variables file from scripts_local"
		source -v -e scripts_local/fc_pre_design_variables.tcl
	} else {
		puts "-I- reading fc_pre_design_variables file from scripts"
		source -v -e scripts/flow/fc_pre_design_variables.tcl
	}

#------------------------------------------------------------------------------
# Library creation
#------------------------------------------------------------------------------
set eco [expr !([info exists START_FROM_NETLIST] && $START_FROM_NETLIST)]
set lib_exists [file exists out/${DESIGN_NAME}_lib]

if {$INC_INIT&&$eco&&!$lib_exists} {
	puts "Error: -inc_init is enabled in ECO mode, but no previous lib exists.\n Cannot proceed without a base lib containing the compile block."
	exit 1 
}

if {!$INC_INIT  ||  ($INC_INIT && !$eco && !$lib_exists)} {
	source -v ./scripts/flow/create_snps_lib.tcl
} else {
	open_lib out/${DESIGN_NAME}_lib
}


#------------------------------------------------------------------------------
# Read in the RTL design
#------------------------------------------------------------------------------
if {[info exists INC_INIT] && !$INC_INIT} {
	if { ![info exists FILELIST] || $FILELIST == "None" } {
		if       { [file exists ./filelist] } {
           		set filelist ./filelist    
   
		} elseif { [file exists ../inter/filelist] } {
           		set filelist ../inter/filelist
   
		} else {
			puts "Error: missing filelist"
			exit 1
		}
       
	} else {
		set filelist $FILELIST
	}


	puts "-I- path_to_filelist_location [file normalize [glob $filelist]]"
	set_svf out/svf/${DESIGN_NAME}_${STAGE}.svf
	redirect -tee -file reports/init/analyze.rpt {analyze -format sverilog -vcs "+define+NXT_PRIMITIVES+BRCM_NO_MEM_SPECIFY -f $filelist"}


	redirect -tee -file reports/elaborate.rpt  { [catch {elaborate ${DESIGN_NAME}} link_status] }

	if {[info exists USE_ABSTRACTS_FOR_BLOCKS] && $USE_ABSTRACTS_FOR_BLOCKS != ""} {
		set_label_switch_list -reference $USE_ABSTRACTS_FOR_BLOCKS compile
	}

	redirect -tee -file reports/link.rpt  { [catch {set_top_module ${DESIGN_NAME}} link_status] }


	if {[info exists CREATE_LIB] && ($CREATE_LIB == "true" || $CREATE_LIB == "only")} {
		# allow to the design to have unresolved references for stub lib.

		write_verilog -shell_only out/netlist/${DESIGN_NAME}.vstub -module_list $DESIGN_NAME
		gen_dummy_liberty out/netlist/${DESIGN_NAME}.vstub out/lib/${DESIGN_NAME}.lib $DESIGN_NAME 
		set cmd "exec /tools/snps/lc/S-2021.06-SP5/bin/lc_shell -x \"read_lib out/lib/${DESIGN_NAME}.lib; write_lib -output out/lib/${DESIGN_NAME}.db ${DESIGN_NAME} ;exit\""
		eval $cmd
	
		if {[info exists CREATE_LIB] && $CREATE_LIB == "only"} {
			puts "-I- finished to create stub lib ."
			script_runtime_proc -end
	
			exec touch .${STAGE}_done
			exit
		}
	}



	if {![catch {exec grep LNK-005 reports/link.rpt}]} {
	    puts "Error: Design has  unresolved references. check reports/link.rpt for more information " 
	#    puts $link_status 
	    exit 1 
	}

	if { $link_status == 0} { 
	}
	#------------------------------------------------------------------------------
	# Save elaborated design
	#------------------------------------------------------------------------------

	save_block -as ${DESIGN_NAME}/elaborate

	set file_name  "./reports/${STAGE}/report_macro_count_check.rpt"
	be_report_macro_count_check > $file_name
	#set path [exec realpath $file_name]
	#set subject "Memory mismatch check"
	#set cmd  "exec echo \"-I- Memory mismatch check summary: \n $path \" | mail -r BE_MMC@nextsilicon.com -a $file_name -s \$subject  eliana.feifel@nextsilicon.com "
	#eval $cmd
} else {
	# inc_init mode
	if {[info exists DFT_COLLATERALS]&&[file exists $DFT_COLLATERALS]} {
		if {[set v_gz [file exists $DFT_COLLATERALS/${DESIGN_NAME}.v.gz]]||[file exists $DFT_COLLATERALS/${DESIGN_NAME}.NO_IP.vg]} {
  			if {$v_gz} {set DFT_NETLIST $DFT_COLLATERALS/${DESIGN_NAME}.v.gz} {set DFT_NETLIST $DFT_COLLATERALS/${DESIGN_NAME}.NO_IP.vg}
		} else {
			puts "Error: incremental init is on but no netlist exists!"
			exit 1
		}
	
		if {[file exists $DFT_COLLATERALS/${DESIGN_NAME}_scan.def.gz]} {
  			set SCAN_DEF $DFT_COLLATERALS/${DESIGN_NAME}_scan.def.gz
 		} else {
  			puts "Error: -inc_init is enabled but no scan_def found!"
 			exit 1
 		}
	
	} else {
	  	puts "Error: incremental init is on but dft_collaterals not exists!"
		exit 1
	} 


	if {[info exists START_FROM_NETLIST] && $START_FROM_NETLIST} {
		read_verilog $DFT_NETLIST -design  ${DESIGN_NAME}/inc_init -as_block -top ${DESIGN_NAME}
		current_block ${DESIGN_NAME}/inc_init
	} else {
		copy_block -from ${DESIGN_NAME}/compile -to ${DESIGN_NAME}/inc_init -force
		current_block ${DESIGN_NAME}/inc_init
	}
	if {[info exists USE_ABSTRACTS_FOR_BLOCKS] && $USE_ABSTRACTS_FOR_BLOCKS != ""} {
		set_label_switch_list -reference $USE_ABSTRACTS_FOR_BLOCKS place
	}
	link_block
	if {[info exists DFT_NETLIST] && $DFT_NETLIST != "None" && $START_FROM_NETLIST == "false"} {
		puts "-I- reading DFT netlist during netlist ECO."
		eco_netlist -by_verilog_file $DFT_NETLIST -write_changes scripts_local/dft_eco_netlist.tcl -write_summary scripts_local/dft_eco_netlist.summary.rpt
		source -e -v scripts_local/dft_eco_netlist.tcl
		write_verilog -exclude { physical_only_cells well_tap_cells filler_cells end_cap_cells pg_netlist } -compress gzip out/netlist/${DESIGN_NAME}.dft_post_eco_netlist.inc_init.v.gz
		#save_block -as ${DESIGN_NAME}/dft_pre_place
		#save_lib 
	}
	read_def $SCAN_DEF
} ; #if {[info exists INC_INIT] && !$INC_INIT}


#------------------------------------------------------------------------------
# source extra process settings
#------------------------------------------------------------------------------
if {[info exists FC_EXTRA_TECH_FILES] && $FC_EXTRA_TECH_FILES != ""} {
	foreach file $FC_EXTRA_TECH_FILES {
		puts "-I- source FC_EXTRA_TECH_FILES $file"
		if {[file exists $file]} { source $file } else {puts "Warning: $file does not exists" }
	}
}


#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/fc_variables.tcl]} {
	puts "-I- reading fc_variables file from scripts_local"
	source -e -v scripts_local/fc_variables.tcl
} else {
	puts "-I- reading fc_variables file from scripts"
	source -e -v scripts/flow/fc_variables.tcl
}


if {[info exists INC_INIT] && !$INC_INIT} {
	saif_map -start

	
	uniquify -force
	#------------------------------------------------------------------------------
	# elaborat reports
	#------------------------------------------------------------------------------


	## Design mismatch reports
	redirect -file reports/init/check_design.design_mismatch {check_design -ems_database check_design.design_mismatch.ems -checks design_mismatch}
	redirect -file reports/init/report_design_mismatch {report_design_mismatch -verbose}
	redirect -file reports/init/report_unbound {report_unbound}

	## start SAIF mapping database

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
# floorplan
#------------------------------------------------------------------------------
## Set site default
if {$DEFAULT_SITE != ""} {
	set_attribute [get_site_defs] is_default false
	set_attribute [get_site_defs $DEFAULT_SITE] is_default true
}

foreach LLL $ROUTING_DIRECTION_HORIZONTAL {set_attribute [get_layer $LLL]  routing_direction horizontal }
foreach LLL $ROUTING_DIRECTION_VERTICAL   {set_attribute [get_layer $LLL]  routing_direction vertical }
#set_attribute [get_layers $layer] track_offset $offset

if {[info exists INC_INIT] && !$INC_INIT} {
	save_block -as ${DESIGN_NAME}/pre_fp
}

if {[info exists MANUAL_FP] && $MANUAL_FP  } {
        puts "-I- manual FP.\ndo source scripts/flow/fp.${PROJECT}.tcl"
        return
} elseif {$DEF_FILE != "None" } {
        puts "-I- reading def file $DEF_FILE"
	set_app_options -name file.def.check_mask_constraints -value none
	if {!$FE_MODE} {read_def -no_incremental -add_def_only_objects all $DEF_FILE} {read_def -no_incremental $DEF_FILE}
	source -e -v scripts/layout/N3E-track-icc2.tcl
} elseif {[info exists INC_INIT] && $INC_INIT } {
        puts "-I- inc init mode"
	if {[info exists START_FROM_NETLIST] && $START_FROM_NETLIST} {
	        puts "-I- reading FP tcl $FP_TCL for start from  dft netlist"
		if {[file exists $FP_TCL]} { 
			set_app_options -name file.def.check_mask_constraints -value none
			source -e -v $FP_TCL
		} else {
			puts "Error : starting from dft netlist but $FP_TCL floorplan is missing"
		}
	}
	if {[file exists scripts_local/dft_port_placement.tcl]} {
		puts "-I- reading dft_port_placement.tcl file from scripts_local"
		source -e -v scripts_local/dft_port_placement.tcl
	}
	
} else {
	if {[source -e -v scripts/flow/fp.${PROJECT}.tcl]} {
		puts "Error: failed to generate valid floorplan (NextSi-001) "
		return
	}
}

	
#------------------------------------------------------------------------------
# fixed all macros and ports
#------------------------------------------------------------------------------
if {[sizeof_collection [get_flat_cells -filter "is_hard_macro&&physical_status!=unplaced"]] > 0 } { set_fixed_objects [get_flat_cells -filter "is_hard_macro&&physical_status!=unplaced"] }
if {[sizeof_collection [get_terminals]] > 0 } {
	set_fixed_objects [get_terminals ]
	set_fixed_objects [get_ports -of_objects [get_terminals ]]
}


#------------------------------------------------------------------------------
# Check to remove any duplicate shapes in the design
#------------------------------------------------------------------------------
set duplicate_shapes [check_duplicates -return_as_collection]
if {[sizeof_collection $duplicate_shapes] > 0} {
	puts "-W- duplicate_shapes exists. removing them"
	if {[sizeof_collection [filter_collection $duplicate_shapes object_class==via]]>0} {
		remove_vias -force  [filter_collection $duplicate_shapes object_class==via]
	}
	if {[sizeof_collection [filter_collection $duplicate_shapes object_class==shape]]>0} {
   		remove_shapes -force [filter_collection $duplicate_shapes object_class==shape]
	}
}

if { ! $FE_MODE } {
	if { !$INC_INIT || ($INC_INIT  && $START_FROM_NETLIST)} {
		set_floorplan_tech_constraint
		derive_floorplan_tech_objects
		derive_metal_cut_routing_guides -add_metal_cut_allowed
	}
}
#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
save_block -as ${DESIGN_NAME}/${STAGE}

#EaExtractBumpCenters -add_term_to_connected_port -rm_dupes

create_frame \
	-merge_metal_blockage true \
	-block_all true \
	-remove_non_pin_shapes { {PO all} {M0 all} {VIA0 all} {M1 all} {VIA1 all} {M2 all} {VIA2 all} {M3 all} {VIA3 all} {M4 all} {VIA4 all} {M5 all} {VIA5 all} {M6 all} {VIA6 all} {M7 all} {VIA7 all} {M8 all} {VIA8 all} {M9 all} {VIA9 all} {M10 all} {VIA10 all} {M11 all} {VIA11 all} {M12 all} {VIA12 all} {M13 all} {VIA13 all} {M14 all} {VIA14 all} {M15 all} {VIA15 all} {M16 all} {VIA16 all} {M17 all} {VIA17 all} {M18 all} {VIA18 all}}

save_lib
if {[info exists INC_INIT] && !$INC_INIT} {
	set_svf -off
}

if { ! $FE_MODE} {
	write_verilog -compress gzip out/netlist/${DESIGN_NAME}.${STAGE}.v.gz
	write_def -compress gzip  -include {cells blockages rows ports } -cell_types {macro} out/def/${DESIGN_NAME}.${STAGE}.fe.def
	set_app_option -name file.def.ignore_uncolored_shapes -value 0
	set_app_options -name file.def.check_mask_constraints -value none
	write_def -compress gzip -include_tech_via_definitions -include {cells blockages rows ports specialnets} -include_physical_status fixed out/def/${DESIGN_NAME}.${STAGE}.be.def
	set exclude_layers "\[get_layers -filter {name !~ 'M\d+$' || name > 'M${MAX_ROUTING_LAYER}'}\]"
	set cmd "write_lef -include cell -exclude_layers $exclude_layers  out/lef/${DESIGN_NAME}.${STAGE}.lef"
	eval $cmd
	# to reduce fp.tcl size
	undefine_user_attribute -classes shape -name was_cut -force
	undefine_user_attribute -classes via -name valid_for_cut -force
	undefine_user_attribute -classes shape -name valid_for_cut -force

	write_floorplan \
		-output out/floorplan/${STAGE}_manual \
		-include {cells blockages bounds die_area  module_boundaries nets pg_regions pins route_guides rows tracks user_shapes vias} \
		-force \
		-include_physical_status all \
		-include_tech_via_definitions \
		-net_types  {ground power} \
		-read_def_options "-add_def_only_objects all -no_incremental" \
		-def_units 10000

	#------------------------------------------------------------------------------
	## Sanity checks and QoR Report	
	#------------------------------------------------------------------------------

	check_floorplan_rules 
}
write_qor_data -report_list "performance host_machine report_app_options" -label $STAGE -output ./reports/qor_data
#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
write_app_options -output reports/${STAGE}/write_app_options.bin
printvar -user_defined > reports/$STAGE/printvar_user_defined.tcl
sh perl -p -i -e {s/(.*)=/set \1/} reports/$STAGE/printvar_user_defined.tcl

file mkdir reports/port_list
gen_port_list reports/port_list

if {[regexp  "k8s|argo" $env(HOST)] } {


	set DESCRIPTION "[string tolower [lindex [split [pwd] "/"] end]]_reports"
	echo "set STAGE $STAGE" > ${STAGE}_report_parallel.tcl
	echo "set FE_MODE $FE_MODE" >> ${STAGE}_report_parallel.tcl
	echo "set DESIGN_NAME $DESIGN_NAME" >> ${STAGE}_report_parallel.tcl
	echo "set PROJECT $PROJECT" >> ${STAGE}_report_parallel.tcl
	echo "set RUNNING_DIR [pwd]" >> ${STAGE}_report_parallel.tcl
	echo "read_app_options [pwd]/reports/${STAGE}/write_app_options.bin" >> ${STAGE}_report_parallel.tcl
#	echo "source [pwd]/reports/${STAGE}/printvar_user_defined.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/procs.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/ory_general_utils.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/oy_time.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common/be_mails.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/common_snps/be_reports.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/qor.generator.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/proc_qor.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/proc_histogram.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/be_report_io_fo.tcl" >> ${STAGE}_report_parallel.tcl
	echo "source [pwd]/scripts/procs/fc_shell/fc_be_checkers.tcl" >> ${STAGE}_report_parallel.tcl
		
 	set REPORTS_MEMORY [expr 1.5 * $MEMORY]
	
	exec cp -pv ./scripts/flow/fc_reports_init.tcl ./sourced_scripts/${STAGE}/.
 	report_parallel \
 		-work_directory reports/${STAGE}/parallel_run \
		-submit_command "./scripts/bin/pt_nextk8s.csh -cpu 8 -mem $REPORTS_MEMORY -pwd [pwd] -description ${DESCRIPTION} -label $LABEL"  \
		-max_cores 8 \
		-user_scripts [list "${STAGE}_report_parallel.tcl" "[which ./scripts/flow/fc_reports_init.tcl]"]

} else {
	source -e -v ./scripts/flow/fc_reports_init.tcl
}

report_msg -summary
print_message_info -ids * -summary

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end

#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
if {[info exists INC_INIT] && $INC_INIT} {set STAGE init}
exec touch .${STAGE}_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
} else {

   exit
  
}

#################################################################################################################################################################################
#																						#
#	this script will run Design  																		#
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
#	0.1	29/08/2021	Royl	initial script																#
#																						#
#																						#
#################################################################################################################################################################################

set STAGE syn
#if { [info exists ::env(SYN4RTL)] } { set FE_MODE $::env(SYN4RTL) } else { set FE_MODE false }
if {![file exists reports/dft]}  {exec mkdir reports/dft}
if {![file exists reports/syn]}  {exec mkdir reports/syn}
if {![file exists reports/elab]} {exec mkdir reports/elab}
if {![file exists reports/compile]} {sh mkdir reports/compile}


if {![info exists RUN_TIMING_REPORTS]} {set RUN_TIMING_REPORTS true}

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
# create proc just for synopsys
source ./scripts/procs/source_be_scripts.tcl
#source ./scripts/procs/common/procs.tcl
#source ./scripts/procs/genus/regression_procs.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}


script_runtime_proc -start


#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file ./scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	set setup_file scripts/setup/setup.${PROJECT}.tcl
}
source -v -e $setup_file
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v -e ../inter/supplement_setup.tcl
}

if {[file exists ./scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v -e ./scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/dc_variables.tcl]} {
	puts "-I- reading dc_variables file from scripts_local"
	source -v -e scripts_local/dc_variables.tcl
} else {
	puts "-I- reading dc_variables file from scripts"
	source -v -e scripts/flow/dc_variables.tcl
}


########################################################################
## Library creation
########################################################################
source -e -v ./scripts/flow/create_snps_lib.tcl

#################################################################################
## open ddc file
#################################################################################
if {$OPEN != "None"} {
   if {$OPEN != "true"} {
   	if { [file exists out/${DESIGN_NAME}.${OPEN}.ddc] } {
		read_ddc out/${DESIGN_NAME}.${OPEN}.ddc
                if {[file exists scripts_local/abstract_module.tcl]} {source -e -v scripts_local/abstract_module.tcl}
	} elseif { [file exists $OPEN] &&  [regexp "\\.ddc" $STAGE_TO_OPEN] } {
		read_ddc ${OPEN}
                if {[file exists scripts_local/abstract_module.tcl]} {source -e -v scripts_local/abstract_module.tcl}
   	} elseif { [file exists $OPEN] &&  [regexp "\\.v" $STAGE_TO_OPEN] } {
		read_verilog -netlist ${OPEN}
                if {[file exists scripts_local/abstract_module.tcl]} {source -e -v scripts_local/abstract_module.tcl}
		current_design ${DESIGN_NAME}

    	} else {
      		puts "-E- $OPEN not found"
    	}
	if {$IS_PHYSICAL == "false"} {    set_zero_interconnect_delay_mode true }

   }

   return
} 

#################################################################################
## Read in the RTL design
#################################################################################
set_svf out/${DESIGN_NAME}.svf
saif_map -start
   
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
   
set fid [open $filelist r]
set read_filelist [read $fid]
close $fid
regexp {(\S+srcfile\.flist)} $read_filelist srcfile
regexp {(\S+rtl_files\.flist)} $read_filelist rtl_files

#set srcfile [regsub "filelist" $filelist "srcfile.flist"]

if { [info exists srcfile] && [file exists $srcfile] } {
 
	set fp [open $srcfile r]
	set fd [read $fp]
	close $fp

	set stubs_list {}
	foreach file [split $fd "\n"] { if { [regexp "\\\.vstub" $file] } {lappend stubs_list $file }}
} elseif {[info exists rtl_files] && [file exists $rtl_files]} {
	set fp [open $rtl_files r]
	set fd [read $fp]
	close $fp

	set stubs_list {}
	foreach file [split $fd "\n"] { if { [regexp "\\\.vstub" $file] } {lappend stubs_list $file }}
} else {
	puts "-W- No srcfile found!"
}


if {[info exists stubs_list] && $stubs_list != "" && $STOP_AFTER != "elaborate"} {

	if {  [info exists srcfile] && [file exists $srcfile] } {
		exec cp $srcfile ${srcfile}.old
		redirect -file temp.flist  {exec grep -v .vstub $srcfile}
		exec mv temp.flist $srcfile
	} elseif {[info exists rtl_files] && [file exists $rtl_files]} {
		exec cp $rtl_files ${rtl_files}.old
		redirect -file temp.flist  {exec grep -v .vstub $rtl_files}
		exec mv temp.flist $rtl_files
	}
	
	set fp [open reports/stub_list.rpt w]
	puts $fp [join $stubs_list "\n"]	
	close $fp
		
	set_app_var timing_ignore_paths_within_block_abstraction true
	echo > scripts_local/abstract_module.tcl
	foreach file $stubs_list { 
		puts "-I- Get module from stub: $file"
		regsub {\.vstub} [lindex [split $file "/"] end] "" module
		puts "-I- Get ddc file for module: $module"
		if {[file exists $env(REPO_ROOT)/target/syn_regressions_dc/$module/scripts_local/supplement_setup.tcl]} {
			puts "-I- read block supplement_setup from: $env(REPO_ROOT)/target/syn_regressions_dc/$module/scripts_local/supplement_setup.tcl"
			source -e $env(REPO_ROOT)/target/syn_regressions_dc/$module/scripts_local/supplement_setup.tcl
			set db_filelist {}
			set pvt_corner($pvt,timing) [lsort -unique $pvt_corner($pvt,timing)]
			foreach file $pvt_corner($pvt,timing) {
				lappend db_filelist [replace_lib_with_db $file]
			}
			set TARGET_LIBRARY_FILES [regsub "{}" $db_filelist ""]
			
			set_app_var target_library ${TARGET_LIBRARY_FILES}
			set_app_var link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES $synthetic_library"
		}
 		if {$STOP_AFTER != "elaborate"} {
		    set cmd "set_top_implementation_options -load_logic compact_interfac -block_references ${module}"
		    echo $cmd >> scripts_local/abstract_module.tcl
		    echo $cmd 
		    eval $cmd
        	}
	}
} elseif {[info exists stubs_list] && $stubs_list != ""} {
	puts "-I- reading stub files in elaboration :\n\t $stubs_list"
}
   
#if {[info exists debug] && $debug == "true"} { return}
   
redirect -tee -file reports/analyze.rpt {analyze -format sverilog -vcs "+define+NXT_PRIMITIVES+BRCM_NO_MEM_SPECIFY -f $filelist"}
if {[info exists srcfile] && [file exists $srcfile.old]} {exec cp ${srcfile}.old ${srcfile}}
if {[info exists rtl_files] && [file exists $rtl_files.old]} {exec cp ${rtl_files}.old ${rtl_files}}
if {![catch {exec grep Error reports/analyze.rpt}]} {
	puts "Error: Design has  Errors during analyze the design. check reports/analyze.rpt for more information "	
	exit 1
}
   
redirect -tee -file reports/elaborate.rpt {elaborate ${DESIGN_NAME}}

if {[info exists stubs_list] && $stubs_list != "" && $STOP_AFTER != "elaborate"} {
	foreach file $stubs_list { 
		regsub {\.vstub} [lindex [split $file "/"] end] "" module
		puts "-I- Get ddc file for module: $module"

		if {$STOP_AFTER == "elaborate"} {
			if { [file exists $env(REPO_ROOT)/target/syn_regressions_dc/$module/out/${module}.elab.ddc] } {
				puts "-I- reading elaboration ddc from: $env(REPO_ROOT)/target/syn_regressions_dc/$module/out/${module}.elab.ddc"
				read_ddc $env(REPO_ROOT)/target/syn_regressions_dc/$module/out/${module}.elab.ddc
			} else {
				puts "Error: no elaboration ddc found for $module"
			}
			
		} else {
			if { [file exists $env(REPO_ROOT)/target/syn_regressions_dc/$module/out/${module}.abstract.ddc] } {
				puts "-I- reading abstract ddc from: $env(REPO_ROOT)/target/syn_regressions_dc/$module/out/${module}.abstract.ddc"
				set cmd "read_ddc $env(REPO_ROOT)/target/syn_regressions_dc/$module/out/${module}.abstract.ddc"
				echo $cmd >> scripts_local/abstract_module.tcl
		    		echo $cmd 
		    		eval $cmd

			} else {
				puts "Error: no Abstract ddc found for $module"
			}
		}

	}
}
   
current_design ${DESIGN_NAME}


#return
redirect -tee -file reports/link.rpt  { [catch {link} link_status] }
if { $link_status == 0} { 
    puts "Error: Design has  unresolved references. check reports/link.rpt for more information " 
#    puts $link_status 
    exit 1 
}

##catch {redirect -tee -file reports/link.rpt {link}} link_status
#if { $link_status == 0} {
#	puts "Error: Design has  unresolved references. check reports/link.rpt for more information "
#	exit 1
#}
   
#if {![catch {exec grep unresolved reports/elaborate.rpt}]} {
#}

set_verification_top

if {[info exists stubs_list]} {
	report_top_implementation_options > reports/report_top_implementation_options.rpt
	report_block_abstraction  > reports/report_block_abstraction.rpt
	
}
####################################
## Save elaborated design
####################################
write -hierarchy -format ddc     -output out/${DESIGN_NAME}.elab.ddc
write -hierarchy -format verilog -output out/${DESIGN_NAME}.elab.v
#exec gzip out/${DESIGN_NAME}.elab.v

   
####################################
## change name
####################################
change_names -hierarchy -rules scip

#define_name_rules scip_last -equal_ports_nets
#define_name_rules scip_last -special verilog
#change_names -hierarchy -rules scip_last
change_names -hierarchy -rules verilog
   
####################################
## Elaboration reports
####################################		    

#be_check_design
check_design -nosplit > ./reports/check_design_elab_verbose.rpt
check_design -summary > ./reports/check_design_elab.rpt

be_report_feedthroughs ./reports/elab/feedthrough.rpt

#Analyze the RTL constructs which may lead to congestion
redirect -file reports/analyze_rtl_congetion.rpt {analyze_rtl_congestion}
parallel_execute [list \
	"report_clock_gating -nosplit > reports/elab/report_clock_gating.elab.rpt" \
	"report_clock_gating -nosplit -verbose > reports/elab/report_clock_gating_verbose.elab.rpt" \
]

redirect -file reports/elab/report_macro_count.rpt {be_report_macro_count}

#################################################################################
# setting after read design 
#################################################################################
if {[shell_is_dcnxt_shell]} {
	set_technology -node 5 
	set_congestion_options -max_util 0.80
#    set_route_zrt_common_options -global_min_layer_mode allow_pin_connection
#    set_route_zrt_global_options -timing_driven true
#    set_route_zrt_global_options -macro_boundary_track_utilization 80
#    set_route_zrt_global_options -macro_corner_track_utilization 70
}
#################################################################################
# Apply Logical Design Constraints
#################################################################################
   
if {[shell_is_dcnxt_shell]} {
	source scripts/flow/snps_mmmc_create.tcl
	mmmc_create
	source $mmmc_results
	remove_scenario -all
   
	foreach _view [lsort -unique [concat $scenarios(setup) $scenarios(dynamic) $scenarios(leakage)]] {
		set cmd "scenario_proc_${_view}"
		echo $cmd
		eval $cmd
	}
	foreach _view $scenarios(setup) {
		set_scenario_options -scenarios $_view -setup true 
	}
	foreach _view $scenarios(dynamic) {
		set_scenario_options -scenarios $_view -dynamic_power true 
	}
	foreach _view $scenarios(leakage) {
		set_scenario_options -scenarios $_view -leakage_power true 
	}
	redirect -file reports/report_scenarios.rpt { report_scenarios }
} else {
	foreach constraint_file $sdc_files(func) {
		set sss [lindex [split $constraint_file /] end]
		redirect -tee -file reports/read_${sss}   {source -e -v $constraint_file}
	}
	#library variable is defined in scripts/flow/create_snps_lib.tcl script.
	set_operating_conditions -library $library $pvt_corner($pvt,op_code)
	if {![shell_is_in_topographical_mode] } {
		puts "-I- set_wire_load_model W3600" 
		set_wire_load_model -name W3600 -library $library
	}
	if {[info exists ZWLM] && $ZWLM=="true"} {
    		set_zero_interconnect_delay_mode true
	}
}

set RUNTIME_START [clock seconds]
# TODO: Add waiver mechanism
be_check_timing
set RUNTIME_END [clock seconds]
puts "-I- check_timing run time is [expr ($RUNTIME_END - $RUNTIME_START)/60/60/24] days , [clock format [expr $RUNTIME_END - $RUNTIME_START] -timezone UTC -format %T]"

if { [info exists STOP_AFTER] && $STOP_AFTER == "elaborate" } {
	puts "-I- Stopping after elaborate"
	if { [info exists INTERACTIVE] && $INTERACTIVE } {
           return
	}
	

	puts "-I- memory usage for read_design: [mem] KB"
	script_runtime_proc -end
	exec touch .syn_done
	exit 0
}
   
#------------------------------------------------------------------------------
# set timing derate
#------------------------------------------------------------------------------
if {[shell_is_dcnxt_shell]} {
   if {[info exists OCV] && $OCV == "socv"} {
	puts "-I- setting OCV"
	set CS [current_scenario]
        foreach dc [all_scenarios] { 
	   source -v -e ./scripts/flow/derating.${PROJECT}.tcl

	   # Source additional user derates
	   if { [file exists ./scripts_local/user_derates.tcl] } { 
		puts "-I- Source user_derates.tcl"
		source ./scripts_local/user_derates.tcl
	   }
	}
	current_scenario $CS
   } elseif {[info exists OCV] && $OCV == "flat" } {
	puts "-I- setting OCV to flat ocv"
	set CS [current_scenario]
        foreach dc [all_scenarios] { 
	    current_scenario $dc
	    set mode  [lindex [split $dc "_"] 0]
	    set check [lindex [split $dc "_"] end]
	    regsub "${mode}_(.*)_${check}" $dc {\1} sub_pvt
	    regexp {(.*[SF])_(.*)} $sub_pvt match PVT rc
	    
	    if {[info exists pvt_corner($PVT,flat_mem_ocv)] && [llength $pvt_corner($PVT,flat_mem_ocv)] == 2} {
	        if {[sizeof_collection [all_macro_cells]] > 0} {
	     	   puts "-I- setting flat OCV check and data for corner $pvt on memories"
	     	   set_timing_derate [lindex $pvt_corner($PVT,flat_mem_ocv) 0 0] -late  -cell_check  [get_lib_cells -of_objects [all_macro_cells ]]
	     	   set_timing_derate [lindex $pvt_corner($PVT,flat_mem_ocv) 0 1] -early -cell_check  [get_lib_cells -of_objects [all_macro_cells ]]
	     	   set_timing_derate [lindex $pvt_corner($PVT,flat_mem_ocv) 1 0] -late  -data   [get_lib_cells -of_objects [all_macro_cells ]]
	     	   set_timing_derate [lindex $pvt_corner($PVT,flat_mem_ocv) 1 1] -early -data   [get_lib_cells -of_objects [all_macro_cells ]]
	        }
	    }
	    if {[info exists pvt_corner($PVT,flat_ocv)] && [llength $pvt_corner($PVT,flat_ocv)] == 2} {
	        puts "-I- setting flat OCV clock and data for corner $PVT"
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 0 0] -late  -clock -cell_delay 
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 0 1] -early -clock -cell_delay 
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 1 0] -late  -data  -cell_delay 
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 1 1] -early -data  -cell_delay 
	    } elseif {[info exists pvt_corner($PVT,flat_ocv)] && [llength $pvt_corner($PVT,flat_ocv)] == 1} {
	        puts "-I- setting flat OCV clock only for corner $PVT"
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 0] -late  -clock -cell_delay 
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 1] -early -clock -cell_delay 
	    } else {
	        puts "-W- missing derate values for corner $PVT"
	    }
	}
	current_scenario $CS
   }
} else {
   if {[info exists OCV] && $OCV == "socv"} {
	puts "-I- setting OCV"
	source -v -e ./scripts/flow/derating.${PROJECT}.tcl

	# Source additional user derates
	if { [file exists ./scripts_local/user_derates.tcl] } { 
		puts "-I- Source user_derates.tcl"
		source ./scripts_local/user_derates.tcl
	}
   } elseif {[info exists OCV] && $OCV == "flat" } {
	 if {[info exists pvt_corner($pvt,flat_mem_ocv)] && [llength $pvt_corner($pvt,flat_mem_ocv)] == 2} {
	     if {[sizeof_collection [all_macro_cells]] > 0} {
	     	puts "-I- setting flat OCV check and data for corner $pvt on memories"
	     	set_timing_derate [lindex $pvt_corner($pvt,flat_mem_ocv) 0 0] -late  -cell_check  [get_lib_cells -of_objects [all_macro_cells ]]
	     	set_timing_derate [lindex $pvt_corner($pvt,flat_mem_ocv) 0 1] -early -cell_check  [get_lib_cells -of_objects [all_macro_cells ]]
	     	set_timing_derate [lindex $pvt_corner($pvt,flat_mem_ocv) 1 0] -late  -data   [get_lib_cells -of_objects [all_macro_cells ]]
	     	set_timing_derate [lindex $pvt_corner($pvt,flat_mem_ocv) 1 1] -early -data   [get_lib_cells -of_objects [all_macro_cells ]]
	     }
	 }
	    
	 if {[info exists pvt_corner($pvt,flat_ocv)] && [llength $pvt_corner($pvt,flat_ocv)] == 2} {
	     puts "-I- setting flat OCV clock and data for corner $pvt"
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 0 0] -late  -clock -cell_delay 
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 0 1] -early -clock -cell_delay 
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 1 0] -late  -data  -cell_delay 
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 1 1] -early -data  -cell_delay 
	 } elseif {[info exists pvt_corner($pvt,flat_ocv)] && [llength $pvt_corner($pvt,flat_ocv)] == 1} {
	     puts "-I- setting flat OCV clock only for corner $pvt"
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 0] -late  -clock -cell_delay 
	     set_timing_derate [lindex $pvt_corner($pvt,flat_ocv) 1] -early -clock -cell_delay 
	 } else {
	     puts "-W- missing derate values for corner $pvt"
	 }
   }
}


#################################################################################
# Create Default Path Groups
#
# Separating these paths can help improve optimization.
# Remove these path group settings if user path groups have already been defined.
#################################################################################
set mems     [all_macro_cells]
if {[shell_is_dcnxt_shell]} {
	set current_scenario_saved [current_scenario]

	foreach scenario [all_active_scenarios] {
		current_scenario ${scenario}
		set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
		group_path -name in2reg  -to  [all_registers -data_pins] -from [remove_from_collection [all_inputs] ${ports_clock_root}] 
		group_path -name in2out  -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
		group_path -name reg2reg -from  [all_registers -clock_pins ]  -to [all_registers -data_pins ] -weight 100 -critical_range 100
		group_path -name reg2out -from  [all_registers -clock_pins ]  -to [all_outputs ]
		if {[sizeof_collection $mems] > 0 } {
			puts "-I- mem2reg"
			group_path -name mem2reg -from [get_pins -of_objects $mems -filter "is_clock_pin == true"] -to [all_registers]
		
			puts "-I- mem2out"
			group_path -name mem2out -from [get_pins -of_objects $mems -filter "is_clock_pin == true"] -to [all_outputs]
		
			puts "-I- reg2mem"
			group_path -name reg2mem   -from [all_registers] -to [get_pins -of_objects $mems -filter {direction=~ in}]
		
			puts "-I- in2mem"	  
			group_path -name in2mem   -from [all_inputs] -to [get_pins -of_objects $mems -filter {direction=~ in}]
		}
		if {[file exists scripts_local/group_path.tcl]} {
			puts "-I- reading extra group path from file scripts_local/group_path.tcl for scenario $scenario"
			source  -e -v scripts_local/group_path.tcl
		}
	}
	current_scenario ${current_scenario_saved}
} else {
	set_critical_range 0.5 [current_design]
	
	set ports_clock_root [filter_collection [get_attribute [get_clocks] sources] object_class==port]
	group_path -name in2reg  -to  [all_registers -data_pins] -from [remove_from_collection [all_inputs] ${ports_clock_root}] 
	group_path -name in2out  -from [remove_from_collection [all_inputs] ${ports_clock_root}] -to [all_outputs]
	group_path -name reg2reg -from  [all_registers -clock_pins ]  -to [all_registers -data_pins ] -weight 100 -critical_range 100
	group_path -name reg2out -from  [all_registers -clock_pins ]  -to [all_outputs ]
	if {[sizeof_collection $mems] > 0 } {
		puts "-I- mem2reg"
		group_path -name mem2reg -from [get_pins -of_objects $mems -filter "is_clock_pin == true"] -to [all_registers]
		
		puts "-I- mem2out"
		group_path -name mem2out -from [get_pins -of_objects $mems -filter "is_clock_pin == true"] -to [all_outputs]
		
		puts "-I- reg2mem"
		group_path -name reg2mem   -from [all_registers] -to [get_pins -of_objects $mems -filter {direction=~ in}]
		
		puts "-I- in2mem"	  
		group_path -name in2mem   -from [all_inputs] -to [get_pins -of_objects $mems -filter {direction=~ in}]
	}
	if {[file exists scripts_local/group_path.tcl]} {
		puts "-I- reading extra group path from file scripts_local/group_path.tcl"
		source  -e -v scripts_local/group_path.tcl
	}
}

################################################################
## dont use  
################################################################
source  -v -e scripts/flow/dont_use_n_ideal_network.tcl

################################################################
## clock gating setting  
################################################################
set cmd "set_clock_gating_style \
		-minimum_bitwidth 3 \
		-control_point before \
		-setup $CLOCK_GATING_SETUP -num_stages 1 -observation_logic_depth 2 \
		-control_signal scan_enable"

if {[info exists LP_CLOCK_GATING_CELL] && $LP_CLOCK_GATING_CELL != ""} {
	set cmd "$cmd -positive_edge_logic  integrated:[get_object_name [index_collection [get_lib_cells */$LP_CLOCK_GATING_CELL] 0]]"
}
echo $cmd
eval $cmd

# Prevent assignment statements in the Verilog netlist.
set_fix_multiple_port_nets -all -outputs
set_fix_multiple_port_nets -all -buffer_constants

################################################################
##  exclude ICG  
################################################################
if {[info exists EXCLUDE_ICG] && $EXCLUDE_ICG != ""} {
	redirect {reports/exclude_icg.rpt} {foreach_in_collection a $EXCLUDE_ICG {echo [get_object_name $a]}}
	set_clock_gating_enable -exclude $EXCLUDE_ICG
	
}


################################################################
## VT threshold  
################################################################
foreach VT_T [array name VT_GROUPS] {
	set_attribute [get_lib_cells */$VT_GROUPS($VT_T)] threshold_voltage_group $VT_T -type string
}

################################################################
##   Apply Physical Design Constraints
################################################################
if {[shell_is_in_topographical_mode] && $IS_PHYSICAL} {
	if { ${MIN_ROUTING_LAYER} != ""} {
		set_ignored_layers -min_routing_layer "M[expr ${MIN_ROUTING_LAYER} - 1]"
	}
	if { ${MAX_ROUTING_LAYER} != ""} {
		set_ignored_layers -max_routing_layer "M[expr ${MAX_ROUTING_LAYER} -1 ]"
	}
	set_preferred_routing_direction -layers {M0 M2 M4 M6 M8 M10 M12 M14 M16 AP} -direction horizontal
	set_preferred_routing_direction -layers {M1 M3 M5 M7 M9 M11 M13 M15 M17} -direction vertical   

	report_ignored_layers
   
	set_app_var enable_rule_based_query true
	set_query_rules  -hierarchical_separators {/ _ __ .} \
		 -bus_name_notations {[] __ ()}   \
		 -class {cell pin port net}	  \
		 -wildcard			  \
		 -regsub_cumulative		  \
		 -show
   
	if {[file exists $DEF_FILE]} {
		extract_physical_constraints -allow_physical_cells $DEF_FILE -verbose
	}
	if {[file exists $FP_FILE]} {
     		read_floorplan $FP_FILE
	}
   
	if {[file exists ./scripts_local/${DESIGN_NAME}.physical_constraints.tcl]} {
		puts "-I- Sourcing script file ./scripts_local/${DESIGN_NAME}.physical_constraints.tcl"
		source -echo -verbose ./scripts_local/${DESIGN_NAME}.physical_constraints.tcl
#		set_app_var enable_rule_based_query false 
   	}
	if {![file exists $DEF_FILE] && ![file exists $FP_FILE]  && ![file exists ./scripts_local/${DESIGN_NAME}.physical_constraints.tcl]} {
		set_max_area 0.0
		
	}
	report_physical_constraints > reports/report_physical_constraints.rpt
   	report_preferred_routing_direction > reports/report_routing_directions.rpt

}
   
if {[shell_is_in_topographical_mode] && $IS_PHYSICAL} {
	# Use the "-check_only" option of "compile_ultra" to verify that your
	# libraries and design are complete and that optimization will not fail
	# in topographical mode.  Use the same options as will be used in compile_ultra.

	compile_ultra -check_only -spg > reports/compile_ultra.check
} else {
	#compile_ultra -check_only > reports/compile_ultra.check
}

redirect -file reports/report_app_var.rpt {report_app_var}
redirect -file reports/report_app_var_only_changed_vars.rpt {report_app_var -only_changed_vars}

#------------------------------------------------------------------------------
# pre generic extra setting script
#------------------------------------------------------------------------------
set hook_script "./scripts_local/pre_compile_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

#if { $FE_MODE } {
#	set cmd "compile -map_effort medium -area_effort none -power_effort none"
#} else {
#
#	set cmd " compile_ultra -scan -retime"
#	if {![info exists LPG] || $LPG == "true"} {
#		set cmd "$cmd -gate_clock"
#	}
#}

set cmd " compile_ultra -no_seq_output_inversion"
if {![info exists SCAN_FF] || $SCAN_FF == "true"} {
	set cmd "$cmd -scan"
}
if {![info exists RETIME] || $RETIME == "true"} {
	set cmd "$cmd -retime"
}
if {![info exists LPG] || $LPG == "true"} {
	set cmd "$cmd -gate_clock"
}
if {![info exists NO_AUTOUNGROUP] || $NO_AUTOUNGROUP == "true"} {
	set cmd "$cmd -no_autoungroup"
}
if {![info exists NO_BOUNDARY_OPT] || $NO_BOUNDARY_OPT == "true"} {
	set cmd "$cmd -no_boundary_optimization"
}

if {[shell_is_in_topographical_mode]  && $IS_PHYSICAL } {set cmd "$cmd -spg"}

echo $cmd
eee $cmd

#------------------------------------------------------------------------------
# post setting and operations
#------------------------------------------------------------------------------
set hook_script "./scripts_local/post_compile_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write -hierarchy -format ddc -output out/${DESIGN_NAME}.compile.ddc
write -hierarchy -format verilog -output out/${DESIGN_NAME}.compile.v
#exec gzip out/${DESIGN_NAME}.compile.v

#------------------------------------------------------------------------------
# compile reports
#------------------------------------------------------------------------------
# ports checker
source scripts/procs/dc/reports.tcl
eee {report_ports_conn}

if {$RUN_TIMING_REPORTS} {
   set timing_reports [list \
	"report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 > reports/compile/compile.rpt.detailed"
	]

   foreach path_group [get_object_name [get_path_groups]] {
	lappend timing_reports "report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 -slack_lesser_than 0 -group $path_group > reports/compile/compile.rpt.$path_group.detailed"
   }

   parallel_execute $timing_reports

   exec gawk -f ./scripts/bin/slacks.awk reports/compile/compile.rpt.detailed     | sort -n > reports/compile/compile.rpt
   foreach path_group [get_object_name [get_path_groups]] {
	exec gawk -f ./scripts/bin/slacks.awk reports/compile/compile.rpt.$path_group.detailed	| sort -n > reports/compile/compile.rpt.$path_group
   }
}

parallel_execute [list \
	"report_qor > reports/compile/report_qor.compile.rpt" \
	"report_area -nosplit > reports/compile/report_area.compile.rpt" \
	"report_area -nosplit -hierarchy > reports/compile/report_area_hierarchy.compile.rpt" \
	"report_clock_gating -nosplit > reports/compile/report_clock_gating.compile.rpt" \
	"report_clock_gating -nosplit -verbose > reports/compile/report_clock_gating_verbose.compile.rpt" \
]

catch { be_report_io_fo } err
if { $err != "" } { puts "-E- be_report_io_fo failed" ; puts "$err" }
catch { be_report_logic_levels } err
if { $err != "" } { puts "-E- be_report_logic_levels failed" ; puts "$err" }

eee {redirect -file reports/compile/report_power.compile.rpt        		{ report_power -nosplit}                    }
#eee {redirect -file reports/compile/report_power_cell.compile.rpt	       	{ report_power -nosplit -verbose -cell}     }
eee {redirect -file reports/compile/report_power_hierarchy.compile.rpt 	{ report_power -nosplit -hierarchy -verbose}    }

# <HN> 23ww52b power_cell report is huge ( >50GB ) and we don't view it currently
# if it will be required again, we'll add a flag to control it 

set _details [expr {[info exists DETAILED_HIER_REPORT] && $DETAILED_HIER_REPORT ? "-details" : ""}]    ;# To be given as 'other_args'
be_report_hier -area -level 4 $_details

#------------------------------------------------------------------------------
# insert DFT
#------------------------------------------------------------------------------
if {[info exists SCAN] && $SCAN == "true" && !$FE_MODE } {
	puts "-I- doing scan insertion" 
	source -v ../inter/insert_dft.tcl
     
	if {![info exists COMPILE_INCR] || $COMPILE_INCR == 0} {
		set COMPILE_INCR 1
	}
}

#------------------------------------------------------------------------------
# running flat design
#------------------------------------------------------------------------------
if {[info exists FLAT_DESIGN] && ($FLAT_DESIGN == "syn_opt" || $FLAT_DESIGN == "compile")} {
	puts "-I- flatting the design."
	set_app_var power_cg_flatten true
	set dont_touch_cells [get_object_name [get_cells -hierarchical -filter "dont_touch"]]
	set_dont_touch $dont_touch_cells false

	ungroup -all -flatten
	set_dont_touch $dont_touch_cells
	if {![info exists COMPILE_INCR] || $COMPILE_INCR == 0} {
		set COMPILE_INCR 1
	}
}

if {[info exists COMPILE_INCR] && $COMPILE_INCR > 0} {
#------------------------------------------------------------------------------
# increment compile
#------------------------------------------------------------------------------
	if {[info exists AUTO_PG] && $AUTO_PG == "true"} {
		create_auto_path_groups -mode mapped \
			-prefix AUTO_PG_ \
			-file scripts_local/auto_path_groups.tcl
	}
	#------------------------------------------------------------------------------
	# pre compile increment setting script
	#------------------------------------------------------------------------------
	if {[file exists ./scripts_local/pre_compile_incr_setting.tcl]} {
		puts "-I- reading pre_compile_incr_setting file from scripts_local"
		source -v ./scripts_local/pre_compile_incr_setting.tcl
	}

	set cmd "$cmd -incremental"
	if {![file exists reports/compile_incr]} {sh mkdir reports/compile_incr}
	while {$COMPILE_INCR} {
		puts "-I- doing compile ultra incremental. run $COMPILE_INCR"
		eee $cmd 
		#------------------------------------------------------------------------------
		# save design
		#------------------------------------------------------------------------------
		write -hierarchy -format ddc -output out/${DESIGN_NAME}.compile_incr_${COMPILE_INCR}.ddc

		#------------------------------------------------------------------------------
		# compile reports
		#------------------------------------------------------------------------------
		report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 > reports/compile_incr/compile_incr_${COMPILE_INCR}.rpt.detailed
		exec gawk -f ./scripts/bin/slacks.awk reports/compile_incr/compile_incr_${COMPILE_INCR}.rpt.detailed     | sort -n > reports/compile_incr/compile_incr_${COMPILE_INCR}.rpt
	     
		incr COMPILE_INCR -1
	}
	if {[info exists AUTO_PG] && $AUTO_PG == "true"} {
		puts "-I- remove_auto_path_groups"
		remove_auto_path_groups
	}
}

#------------------------------------------------------------------------------
# optimize area
#------------------------------------------------------------------------------
puts "-I- Performs monotonic gate-to-gate  optimization  to  improve  area without  degrading timing or leakage."
eee {optimize_netlist -area}

#------------------------------------------------------------------------------
# optimize area
#------------------------------------------------------------------------------
if {[info exists FLAT_DESIGN] && $FLAT_DESIGN == "save_design"} {
	puts "-I- flatting the design."
	set_app_var power_cg_flatten true
	set dont_touch_cells [get_object_name [get_cells -hierarchical -filter "dont_touch"]]
	set_dont_touch $dont_touch_cells false

	ungroup -all -flatten
	set_dont_touch $dont_touch_cells
}

#------------------------------------------------------------------------------
# change name before writin netlist 
#------------------------------------------------------------------------------
change_names -rules verilog -hierarchy

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write -hierarchy -format ddc -output out/${DESIGN_NAME}.Syn.ddc
write -hierarchy -format verilog -output out/${DESIGN_NAME}.Syn.v
#exec gzip out/${DESIGN_NAME}.Syn.v

set_svf -off
if {[shell_is_dcnxt_shell]} {
	write_icc2_files -force  -output out/${DESIGN_NAME}_icc2_files
}
if {[shell_is_in_topographical_mode]} {
	# Do not write out net RC info into SDC
	set_app_var write_sdc_output_lumped_net_capacitance false
	set_app_var write_sdc_output_net_resistance false
}
write_sdc -nosplit out/${DESIGN_NAME}.sdc


# If SAIF is used, write out SAIF name mapping file for PrimeTime-PX
saif_map -type ptpx -write_map out/${DESIGN_NAME}.mapped.SAIF.namemap

#------------------------------------------------------------------------------
# compile reports
#------------------------------------------------------------------------------
set timing_reports [list \
	"report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 > reports/syn/syn.rpt.detailed"
	]

foreach path_group [get_object_name [get_path_groups]] {
	lappend timing_reports "report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 -slack_lesser_than 0 -group $path_group > reports/syn/syn.rpt.$path_group.detailed"
}
parallel_execute $timing_reports

exec gawk -f ./scripts/bin/slacks.awk reports/syn/syn.rpt.detailed     | sort -n > reports/syn/syn.rpt
foreach path_group [get_object_name [get_path_groups]] {
	exec gawk -f ./scripts/bin/slacks.awk reports/syn/syn.rpt.$path_group.detailed	| sort -n > reports/syn/syn.rpt.$path_group
}

if {$MBIT == "true" } {
	redirect -file reports/syn/report_multibit.syn.rpt        { report_multibit -nosplit}
}
parallel_execute [list \
	"report_qor > reports/syn/report_qor.syn.rpt" \
	"report_area -nosplit > reports/syn/report_area.syn.rpt" \
	"report_area -nosplit -hierarchy > reports/syn/report_area_hierarchy.syn.rpt" \
	"report_clock_gating -nosplit > reports/syn/report_clock_gating.syn.rpt" \
	"report_clock_gating -nosplit -verbose > reports/syn/report_clock_gating_verbose.syn.rpt" \
	"report_threshold_voltage_group -nosplit > reports/report_threshold_voltage_group.rpt" \
	"report_synlib dw_foundation.sldb > reports/synlib_dw_foundation.rpt" \
	"report_timing -loops > reports/timing_loops.rpt" \
]

catch { be_report_io_fo        } err
if { $err != "" } { puts "-E- be_report_io_fo failed" ; puts "$err" }
catch { be_report_logic_levels } err
if { $err != "" } { puts "-E- be_report_logic_levels failed" ; puts "$err" }

redirect -file reports/syn/report_power.syn.rpt        { report_power -nosplit}
#redirect -file reports/syn/report_power_cell.syn.rpt	       { report_power -nosplit -verbose -cell}
redirect -file reports/syn/report_power_hierarchy.syn.rpt { report_power -nosplit -hierarchy -verbose}
redirect -file reports/all_violators.rpt {report_constraints -all_violators -significant_digits 3 -verbose}

# <HN> 23ww52b power_cell report is huge ( >50GB ) and we don't view it currently
# if it will be required again, we'll add a flag to control it 

#redirect -file reports/syn/check_design.rpt { check_design -nosplit }
#redirect -file reports/syn/check_design.summary.rpt { check_design -summary }
#redirect -file reports/syn/check_timing.rpt { check_timing }
be_check_design
be_check_timing
redirect -file reports/syn/report_macro_count.rpt {be_report_macro_count}

dc_fe_io_logic_levels $STAGE

redirect -file reports/report_app_var.rpt {report_app_var}
redirect -file reports/report_app_var_only_changed_vars.rpt {report_app_var -only_changed_vars}

if {[shell_is_dcnxt_shell]} {
	report_congestion > reports/report_congestion.rpt
	if {[info exists env(DISPLAY)]} {
		set RUNTIME_START [clock seconds]
		gui_start
		set MyLayout [gui_create_window -type LayoutWindow]
		report_congestion -build_map
		gui_show_map -map "Global Route Congestion" -show true
		gui_zoom -window [gui_get_current_window -view] -full
		gui_write_window_image -format png -file reports/congestion_map.png
		gui_write_window_image -window ${MyLayout} -format png -file reports/congestion_map_window.png
		gui_stop
		set RUNTIME_END [clock seconds]
		puts "-I-     Elapse time is [expr ($RUNTIME_END - $RUNTIME_START)/60/60/24] days , [clock format [expr $RUNTIME_END - $RUNTIME_START] -timezone UTC -format %T]"
	} else {
		puts "Information: The DISPLAY environment variable is not set. Congestion map generation has been skipped."
	}
	if {[info exists CREATE_SPEF] && $CREATE_SPEF == "true" } {
		puts "-I- generate spef files "
   		set start_t [clock seconds]
		write_parasitics -output out/spef/${DESIGN_NAME}.${STAGE}
   		set end_t [clock seconds]
   		puts "-I- Elapse time for running write_parasitics is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
	}
}

puts "-I- generate block abstraction"
create_block_abstraction
write_file -hierarchy -format ddc -output out/${DESIGN_NAME}.abstract.ddc

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
puts "-I- memory usage for read_design: [mem] KB"
script_runtime_proc -end


exec touch .syn_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {
	return
}

exit


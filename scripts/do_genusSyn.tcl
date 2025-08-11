#################################################################################################################################################################################
#																						#
#	this script will run Genus  																		#
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
#	0.1	05/01/2021	Royl	initial script																#
#	0.2	13/01/2021	Royl	add option to read extra files pre each stage												#
#	0.3	21/01/2021	Ory	    1. Add "fe_mode" some ifs for RTLrs runs (no scan, private def file, maybe other overrides in the future)				#
#                           2. Add some BE env vars dependancy - For FE and BE runs (Known file location etc.)									#
#                           3. Change some files (scripts) location to match current folder structure - The flow is under $BEROOT/be_flow/ns_flow				#
#	0.4	28/01/2021	Ory	    Add new flags: sdc_list, def_file, stop_after											#
#	0.5	30/12/2021	Royl	    add flat option. 															#	
#																						#
#																						#
#################################################################################################################################################################################

set STAGE syn
#if { [info exists ::env(SYN4RTL)] } { set FE_MODE $::env(SYN4RTL) } else { set FE_MODE false }
if {![file exists reports/dft ]   } {exec mkdir reports/dft}
if {![file exists reports/elab]   } {exec mkdir reports/elab}
if {![file exists reports/syn_gen]} {exec mkdir reports/syn_gen}
if {![file exists reports/syn_map]} {exec mkdir reports/syn_map}
if {![file exists reports/syn_opt]} {exec mkdir reports/syn_opt}

set start_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - Start running $STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}

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

#------------------------------------------------------------------------------
# Verify Filelist
#------------------------------------------------------------------------------

if { ![info exists FILELIST] || $FILELIST == "None" } {

    if { [file exists ./filelist] } {
        set filelist ./filelist  
        be_print_big_warning "Reading filelist from local WA" 10
    } elseif { [file exists ../inter/filelist] } {
        set filelist ../inter/filelist
        be_print_big_warning "Reading filelist from inter" 10
    } else {
	puts "Error: missing filelist"
	exit 1
    }     
} else {
    set filelist $FILELIST
    be_print_big_warning "Reading filelist from [file dirname $filelist]" 10
}

#------------------------------------------------------------------------------
# Add libs/ilms for stubs
#------------------------------------------------------------------------------
set st_t [exec date +%s]

set fid [open $filelist r]
set read_filelist [read $fid]
close $fid
regexp {(\S+srcfile\.flist)} $read_filelist srcfile
regexp {(\S+rtl_files\.flist)} $read_filelist rtl_files

if { [info exists srcfile] && [file exists $srcfile] } {
    
    set fp [open $srcfile r]
    set fd [read $fp]
    close $fp
    
    set file_list {}
    set stubs_list {}
    
    foreach file [split $fd "\n"] { 
        if { $file == "" } { continue }
        if { [catch {set module [lindex [exec grep "module" $file] 1] } res] } { set module "NOMODULE" }
        if { [info exists BE_PARTITIONS] && $BE_PARTITIONS!="None" && [lsearch [split $BE_PARTITIONS " "] $module] >=0 } {lappend stubs_list $file ;  continue }
        if { [regexp "\\\.vstub" $file] && ![regexp "behavioral_verilog" $file] }                            {lappend stubs_list $file ;  continue } 
        lappend file_list $file
    }
    puts "-I- Running in chiplet mode"
    puts "-I- stub file list : $stubs_list" 
    
    if {[llength $stubs_list] > 0} {
        if { [info exists SEARCH_PATH] && $SEARCH_PATH!="None" } {
            set repo_root $SEARCH_PATH
        } elseif { [info exists env(REPO_ROOT)] } {
            set repo_root $env(REPO_ROOT)
        } else {
            set design_path [lindex [exec grep "/design/" $srcfile] 0]
            regexp "(.+/)design/" $design_path res repo_root
        }    
        puts "-I- REPO_ROOT: $repo_root"
    }
    
} elseif { [info exists rtl_files] && [file exists $rtl_files] } {
    set fp [open $rtl_files r]
    set fd [read $fp]
    close $fp
    
    set file_list {}
    set stubs_list {}
    
    foreach file [split $fd "\n"] { 
        if { $file == "" } { continue }
        if { [catch {set module [lindex [exec grep "module" $file] 1] } res] } { set module "NOMODULE" }
        if { [info exists BE_PARTITIONS] && $BE_PARTITIONS!="None" && [lsearch [split $BE_PARTITIONS " "] $module] >=0 } {lappend stubs_list $file ;  continue }
        if { [regexp "\\\.vstub" $file] && ![regexp "behavioral_verilog" $file] }                            {lappend stubs_list $file ;  continue } 
        lappend file_list $file
    }
    puts "-I- Running in chiplet mode"
    puts "-I- stub file list : $stubs_list" 
    
    if {[llength $stubs_list] > 0} {
        if { [info exists SEARCH_PATH] && $SEARCH_PATH!="None" } {
            set repo_root $SEARCH_PATH
        } elseif { [info exists env(REPO_ROOT)] } {
            set repo_root $env(REPO_ROOT)
        } else {
            set design_path [lindex [exec grep "/design/" $rtl_files] 0]
            regexp "(.+/)design/" $design_path res repo_root
        }    
        puts "-I- REPO_ROOT: $repo_root"
    }
} else {
	puts "-W- No srcfile found!"
}


set is_chiplet false
set supplement_setup_files {}
if {[info exists stubs_list] && $stubs_list != ""} {

    set is_chiplet true
    set ILM_FILES ""
    
    # TODO: CP and use private srcfile if stublist
    set_db hdl_resolve_instance_with_libcell true
    set_db hdl_exclude_params_in_cell_search {pcore_l3_cluster_bank_noc_wrapper}
    
    if {[info exists srcfile] &&  [file exists $srcfile] } {
        exec cp $srcfile ${srcfile}.old
        set fp [open $srcfile w]
    } elseif {[info exists rtl_files] &&  [file exists $rtl_files] } {
       exec cp $rtl_files ${rtl_files}.old
        set fp [open $rtl_files w]
    }
#	redirect temp.flist {puts [exec grep -v .vstub $srcfile]}
#	exec mv temp.flist $srcfile
    
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
        set lib_path       "$repo_root/target/syn_regressions/$module/out/${module}_from_stub.lib"
        set ilm_path       "$repo_root/target/syn_regressions/$module/out/ilm"
        set sup_setup_path "$repo_root/target/syn_regressions/$module/scripts_local/supplement_setup.tcl"
        if { [file exists $ilm_path] } { 
            puts "-I- Adding ilm file for $module"
            append ILM_FILES " $ilm_path " 
            lappend supplement_setup_files $sup_setup_path
        } else { 
            puts "-W- No ilm found in: $ilm_path for $module. Searching for lib file instead." 
            if { [file exists $lib_path] } { append stub_lib_list " $lib_path " } { puts "-W- No lib found in: $lib_path for $module" }
        }
    }
    if { $stub_lib_list != "" } {
	    foreach pvt_cor [array names pvt_corner *timing] {
		    set pvt_corner($pvt_cor) "$pvt_corner($pvt_cor) \
		    $stub_lib_list"
	    }
    }
}

set en_t [exec date +%s]
set run_time [calc_run_time $st_t $en_t]
set OFILE [open syn.time w]
puts $OFILE "Run time of     Add LIBS/ILM stage: $run_time"
close $OFILE

### SOURCE ILM BLOCKS SUPPLEMENT SETUP FILES
foreach file $supplement_setup_files { 
    if { [file exists $file] } { 
        puts "-I- Sourcing $file for ILM module"
        source $file
    } else {
        puts "-W- File $file not found for ILM module"
    }    
}

#------------------------------------------------------------------------------
# define and read mmmc 
#------------------------------------------------------------------------------
set st_t [exec date +%s]
source scripts/flow/mmmc_create.tcl
mmmc_create
set cmd "read_mmmc { $mmmc_results }"
eval $cmd
foreach file $sdc_files(func) {
   exec cp -pv $file ./sourced_scripts/${STAGE}/.
}
set en_t [exec date +%s]
set run_time [calc_run_time $st_t $en_t]
set OFILE [open syn.time a]
puts $OFILE "Run time of     MMMC gen stage: $run_time"
close $OFILE

#------------------------------------------------------------------------------
# read lef and enable PLE-MODE
#------------------------------------------------------------------------------
set cmd "read_physical -lef \[list $LEF_FILE_LIST\]"
eee $cmd syn.time "READ_PHYSICAL"

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
set st_t [exec date +%s]
if {[file exists scripts_local/syn_variables.tcl]} {
	puts "-I- reading syn_variables file from scripts_local"
	source -v scripts_local/syn_variables.tcl
} else {
	puts "-I- reading syn_variables file from scripts"
	source -v scripts/flow/syn_variables.tcl
}
set en_t [exec date +%s]
set run_time [calc_run_time $st_t $en_t]
set OFILE [open syn.time a]
puts $OFILE "Run time of     SYN VARS stage: $run_time"
close $OFILE


set stt [clock seconds]
puts "-I-  Reading filelist from: $filelist at: [clock format $stt -format "%d/%m/%y %H:%M:%S"]"
if { [catch {read_hdl -language sv -f $filelist} res] } { 
   eee {fe_report_hdl }
   puts "-E- read_hdl failed!"
   puts $res 
   exit 
} else { 
     puts $res 
}

set ett [clock seconds]
puts "-I- End running read_hdl $filelist at: [clock format $ett -format "%d/%m/%y %H:%M:%S"]"
puts "-I- Elapse time is [expr ($ett - $stt)/60/60/24] days , [clock format [expr $ett - $stt] -timezone UTC -format %T]"


#------------------------------------------------------------------------------
# Recover filelist if stubs
#------------------------------------------------------------------------------
if { [info exists stubs_list] && $stubs_list != "" && [info exists srcfile] && [file exists ${srcfile}.old] } {
    puts "-I- Recovering srcfile"
    exec mv ${srcfile}.old ${srcfile}
}
if { [info exists stubs_list] && $stubs_list != "" && [info exists rtl_files] && [file exists ${rtl_files}.old] } {
    puts "-I- Recovering rtl_files"
    exec mv ${rtl_files}.old ${rtl_files}
}

#------------------------------------------------------------------------------
# read hierarchical flow 
#------------------------------------------------------------------------------
if {[info exists ILM_FILES] && $ILM_FILES != ""} {
   set st_t [exec date +%s]
   foreach ILM_FILE $ILM_FILES {
    if { [set ilm_netlist [glob -nocomp $ILM_FILE/*.ilm.v]] == "" } { puts "-W- No ilm file found for $ILM_FILE" ; continue }
   	set block_name [lindex [split [lindex [split $ilm_netlist '/'] end] "."] 0]
   	puts "-I- reading ILM file $ILM_FILE for block $block_name"
	if {([info exists IS_PHYSICAL] && $IS_PHYSICAL == "true" ) || ([info exists IS_HYBRID] && $IS_HYBRID == "true")} {
		read_ilm -basename ${ILM_FILE}/${block_name}.${STAGE} -module_name ${block_name} 
	} else {
	 	if {[file exists ${ILM_FILE}/${block_name}.lef]} {
			read_ilm -basename ${ILM_FILE}/${block_name}.${STAGE} -module_name ${block_name} -lef_file ${ILM_FILE}/${block_name}.lef
		} else {
			read_ilm -basename ${ILM_FILE}/${block_name}.${STAGE} -logical -module_name ${block_name}
		}
	}
   }
   set en_t [exec date +%s]
   set run_time [calc_run_time $st_t $en_t]
   set OFILE [open syn.time a]
   puts $OFILE "Run time of    READ ILM stage: $run_time"
   close $OFILE
}

set st_t [exec date +%s]
set stt [clock seconds]
puts "-I-  elaborate $DESIGN_NAME at: [clock format $stt -format "%d/%m/%y %H:%M:%S"]"
if { [catch {elaborate $DESIGN_NAME } res] } { 
   eee {fe_report_hdl }
   puts "-E- Elaborate failed!"
   puts $res 
   exit
} else { 
   puts $res 
}
set ett [clock seconds]
puts "-I- End running elaborate $DESIGN_NAME at: [clock format $ett -format "%d/%m/%y %H:%M:%S"]"
puts "-I- Elapse time is [expr ($ett - $stt)/60/60/24] days , [clock format [expr $ett - $stt] -timezone UTC -format %T]"
set en_t [exec date +%s]
set run_time [calc_run_time $st_t $en_t]
set OFILE [open syn.time a]
puts $OFILE "Run time of     ELABORATE stage: $run_time"
close $OFILE

eee {redirect reports/elab/report_macro_count.rpt {be_report_macro_count}} syn.time "MACRO COUNT"
puts "-I- Runtime & Memory after: read_hdl & elaborate"
timestat Elaboration

eee {init_design} syn.time "INIT DESIGN"

puts "-I- Saving post elaborate design"
set cmd "write_db -all_root out/${DESIGN_NAME}.elaborate.db"
eee $cmd syn.time "WRITE DB ELAB"
set cmd "write_hdl >        out/${DESIGN_NAME}.elaborate.v"
eee $cmd syn.time "WRITE HDL ELAB"

set st_t [exec date +%s]
# fe_mode == false
    puts "-I- change \[ name \] or '\.' usage in instances, hierarchies, hierarchy pins, and net names"
    # // <HN>24ww02b - attempt to run all 3 restricted chars together failed - but works separately
    eee {update_names  -restricted {[} -replace_str "_" -inst -module -hnet -hport_bus -log log/update_names.log}
    eee {update_names  -restricted {]} -replace_str "_" -inst -module -hnet -hport_bus -log log/update_names.log -append_log}
    eee {update_names  -restricted "." -replace_str "_" -inst -module -hnet -hport_bus -log log/update_names.log -append_log}
    foreach net [get_db nets -if ".name == *\[*"] {
    	foreach map_point [regsub -all {[\[\]]} [regexp -inline -all {\[\w+\]} [regsub {\[\d+\]} $net ""]] ""] {
	   set cmd "set map($map_point) 1"
	   eval $cmd
	}
    }
    foreach map_name [array name map] {
	lappend update_names_map "\"\[$map_name\]\" \"_${map_name}_\""
    }
    if {[info exists update_names_map]} {
    	update_names  -map $update_names_map -log log/update_names.log -append_log
    }
set en_t [exec date +%s]
set run_time [calc_run_time $st_t $en_t]
set OFILE [open syn.time a]
puts $OFILE "Run time of     UPDATE NAMES stage: $run_time"
close $OFILE
    
    
eee {remove_cdn_loop_breaker} syn.time "REMOVE LOOP"
    puts "-I- Running check_timing_intent"        
puts "-I- Running check_design"    
eee {check_design -all > reports/check_design_elab.rpt} syn.time "CHECK DESIGN ELAB"
eee {check_timing_intent -verbose > reports/check_timing_intent_elaborate.rpt} syn.time "CHECK TIMING ELAB"

# SDC errors

redirect ./reports/read_sdc.rpt "update_constraint_mode -name [get_db constraint_modes .name] -sdc_files \{$sdc_files(func)\}"

if {[info exists ::dc::sdc_failed_commands]} {
	echo $::dc::sdc_failed_commands >> reports/read_sdc.rpt
}

if { [info exists STOP_AFTER] && $STOP_AFTER == "elaborate" } {
    puts "-I- Printing some reports before exit"
    puts "-I- Counting cells [::ory_time::now]"
    
    set sub_stage elaborate
    
    set cell_count [redirect_and_catch be_count_cells]
    set io_count   [redirect_and_catch be_count_interface]
    
    set cell_count_status "
    [nice_header "Cell Count"] \n$cell_count \n$io_count "
        
    set fp [open reports/${sub_stage}_cell_count.rpt w]    
    puts $fp $cell_count_status
    close $fp

    puts "-I- Stopping after elaborate"
    exec touch .syn_done
    exit
}

if {[info exists IS_PHYSICAL] && $IS_PHYSICAL == "true" || [info exists IS_HYBRID] && $IS_HYBRID == "true" } {
    if {[file exists $DEF_FILE]} { 	
        puts "-I- reading def file $DEF_FILE" 
        read_def $DEF_FILE 
    } else {
        puts "ERROR def file for physical run $DEF_FILE does not exists"
    }
}



if {[info exists ILM_FILES] && $ILM_FILES != ""} {
   	puts "-I- running in ILM flow assemble_design"
	eee {assemble_design}
}

#------------------------------------------------------------------------------
# set dont use for cells, dont touch inst and nets
#------------------------------------------------------------------------------
source  -v -e scripts/flow/dont_use_n_ideal_network.tcl

#source ./scripts/flow/apply_rtl2be_directives.tcl

# TODO - Add "source if exists" to save time?
#eee {apply_rtl2be_directives}

#------------------------------------------------------------------------------
# wireload module
#------------------------------------------------------------------------------
if {[info exists WLM] && $WLM != "false"} {
   set_db interconnect_mode wireload
   set_db wireload_mode top
   set_db [get_db designs]  .force_wireload [get_db wireloads *tsmc5ff_ck06t0750v_pssg*/$WLM]
}

#------------------------------------------------------------------------------
# group path
#------------------------------------------------------------------------------
set st_t [exec date +%s]
puts "-I- Grouping Paths"
set reset false
foreach mode_ [get_db constraint_modes  .name] {      
   set_interactive_constraint_modes "$mode_"
   
   if { $reset } { reset_path_group -all ; if { [catch {delete_obj [get_db cost_groups]} res] } {puts "-W- Failed to delete cost group"} ; set reset false }
   
   set mems     [get_db insts -if ".base_cell.is_memory==true || (.base_cell.is_macro==true && .base_cell.is_sequential==true)"]
   set all_regs [remove_from_collection [filter_collection [all_registers ] is_integrated_clock_gating_cell!=true] $mems]
   # Higher number means higher priority
   set default_priority 5
   set special_priority 10
   set very_special_priority 15
   
   if { [sizeof $all_regs] > 0 } {
       puts "-I- reg2reg"
       set excp [group_path -name reg2reg -from [remove_from_collection $all_regs $mems] -to [remove_from_collection $all_regs $mems]]
       set_db $excp .user_priority $default_priority
   
       puts "-I- reg2out"
       set excp [group_path -name reg2out -from [remove_from_collection $all_regs $mems] -to [all_outputs]]
       set_db $excp .user_priority $default_priority   
   
       puts "-I- in2reg"
       set excp [group_path -name in2reg  -from [all_inputs]    -to [remove_from_collection $all_regs $mems]]
       set_db $excp .user_priority $default_priority
   }
     
   if {[sizeof_collection $mems] > 0 } {
        puts "-I- mem2reg"
	    set excp [group_path -name mem2reg -from [get_pins -of_objects $mems -filter {is_clock}] -to [all_registers]]
        set_db $excp .user_priority $special_priority        

        puts "-I- mem2out"
	    set excp [group_path -name mem2out -from [get_pins -of_objects $mems -filter {is_clock}] -to [all_outputs]]
        set_db $excp .user_priority $special_priority        

        puts "-I- reg2mem"
	    set excp [group_path -name reg2mem   -from [all_registers] -to [get_pins -of_objects $mems -filter {direction=~ in}]]
        set_db $excp .user_priority $special_priority

        puts "-I- in2mem"        
	    set excp [group_path -name in2mem   -from [all_inputs] -to [get_pins -of_objects $mems -filter {direction=~ in}]]
        set_db $excp .user_priority $special_priority        
   }
   
   if { $is_chiplet && [info exists stubs_list] && $stubs_list != "" && $ILM_FILES != "" } {
       
       foreach stub $stubs_list {
           set module [lindex [exec grep "module " $stub] 1] 
           set hcells [get_db hinsts -if .module.name==$module]

           foreach hcell $hcells { 
               
               set name [get_db $hcell .name]
               set base_name [get_db $hcell .base_name]
                         
               puts "-I- Defining path groups for module: $module, cell: $name"
               set pins  [common_collection [get_pins -hier -filter full_name=~$name/*] [get_pins -of $all_regs]]
               
               if { [sizeof $pins] == 0 } { puts "-W- No internal pins found for $name. Check if $name has ILM module" ; continue }
               
               set excp [group_path -name chiplet2$base_name -to [filter_collection $pins direction==in]]
               set_db $excp .user_priority $very_special_priority

               set excp [group_path -name ${base_name}2chiplet -from [filter_collection $pins direction==out]]
               set_db $excp .user_priority $very_special_priority
           }
           
       }
   
   }
   
   set_interactive_constraint_modes {}   
}
set en_t [exec date +%s]
set run_time [calc_run_time $st_t $en_t]
set OFILE [open syn.time a]
puts $OFILE "Run time of     GROUP PATHS stage: $run_time"
close $OFILE


#------------------------------------------------------------------------------
# set timing derate
#------------------------------------------------------------------------------
set st_t [exec date +%s]
if {[info exists OCV] && $OCV == "socv"} {

	puts "-I- setting OCV to socv"
	set_db ocv_mode true; # If the user requires OCV
	set_db / .socv_analysis 1  
        ::legacy::set_attribute timing_nsigma_multiplier 3 
	::legacy::set_attribute socv_use_lvf_tables {all} /

        phys_enable_ocv -native_socv  -design [get_db designs]
	
	source -v -e ./scripts/flow/derating.${PROJECT}.tcl
    
    # Source additional user derates
    if { [file exists ./scripts_local/user_derates.tcl] } { 
        puts "-I- Source user_derates.tcl"
        source ./scripts_local/user_derates.tcl
    }
} elseif {[info exists OCV] && $OCV == "flat" } {
	puts "-I- setting OCV to flat ocv"
	set_db ocv_mode true; # If the user requires OCV
        foreach dc [get_db [get_db analysis_views -if .is_active==true] .delay_corner] { 
	    set dc_name [get_db $dc .name]
	    regexp {^(\S+_[SF][SF])_} $dc_name match PVT
	    if {[info exists pvt_corner($PVT,flat_ocv)] && [llength $pvt_corner($PVT,flat_ocv)] == 2} {
	        puts "-I- setting flat OCV clock and data for corner $PVT"
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 0 0] -late  -clock -cell_delay -delay_corner $dc_name
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 0 1] -early -clock -cell_delay -delay_corner $dc_name
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 1 0] -late  -data  -cell_delay -delay_corner $dc_name
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 1 1] -early -data  -cell_delay -delay_corner $dc_name
	    } elseif {[info exists pvt_corner($PVT,flat_ocv)] && [llength $pvt_corner($PVT,flat_ocv)] == 1} {
	        puts "-I- setting flat OCV clock only for corner $PVT"
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 0] -late  -clock -cell_delay -delay_corner $dc_name
	        set_timing_derate [lindex $pvt_corner($PVT,flat_ocv) 1] -early -clock -cell_delay -delay_corner $dc_name
	    } else {
	        puts "-W- missing derate values for corner $PVT"
	    }
	}	
}
set en_t [exec date +%s]
set run_time [calc_run_time $st_t $en_t]
set OFILE [open syn.time a]
puts $OFILE "Run time of     DERATES stage: $run_time"
close $OFILE


#------------------------------------------------------------------------------
# define voltage_threshold_group
#------------------------------------------------------------------------------
# clear previous vt group naming
set_db [get_db base_cells] .voltage_threshold_group ""
# define custom vt group naming for metrics
foreach name [lsort [array names VT_GROUPS]] {
    puts "-I- Setting VT group $name"
    set_db [get_db base_cells -if .name==$VT_GROUPS($name)&&!.is_black_box==true] .voltage_threshold_group $name
}

#------------------------------------------------------------------------------
# insert ICG
#------------------------------------------------------------------------------
set st_t [exec date +%s]
if {[info exists LP_CLOCK_GATING_CELL ] && $LP_CLOCK_GATING_CELL != ""} {
    if {[info exists LPG] && $LPG == "true"} {
        puts "-I- define clock gating cells"
	
#	set_db designs .lp_clock_gating_max_flops 48 ;			# Default : inf
	set_db designs .lp_clock_gating_auto_path_adjust variable ;	# Default : none

        set_db designs .lp_clock_gating_cell base_cell:$LP_CLOCK_GATING_CELL
        set_db designs .lp_clock_gating_min_flops 3
        set_db designs .lp_clock_gating_auto_path_adjust  fixed 
        set_db designs .lp_clock_gating_auto_path_adjust_fixed_delay    [expr 1000* $CLOCK_GATING_SETUP ]
    }
}
set en_t [exec date +%s]
set run_time [calc_run_time $st_t $en_t]
set OFILE [open syn.time a]
puts $OFILE "Run time of     INSERT ICG stage: $run_time"
close $OFILE


#------------------------------------------------------------------------------
# insert DFT
#------------------------------------------------------------------------------
if {[info exists SCAN] && $SCAN == "true" && !$FE_MODE } {
	puts "-I- doing scan insertion" 
	source -v ../inter/insert_dft.tcl
}

#------------------------------------------------------------------------------
# run phisycal with floorplan
#------------------------------------------------------------------------------
if { ([info exists IS_PHYSICAL] && $IS_PHYSICAL == "true") || ([info exists IS_HYBRID] && $IS_HYBRID )} {
	if {[file exists $FP_FILE]} {
		puts "-I reading FP constraint file"
		source $FP_FILE
	}
	
	set_db opt_spatial_effort extreme
	set IS_PHYSICAL_CMD "-physical"
    if { [info exists IS_PHYSICAL] && $IS_PHYSICAL == "true"  } {
	    set SPATIAL_CMD "-spatial"
    } else {
	    set SPATIAL_CMD ""
    }
    ### // Checker to make sure all ports are placed and all macros are fixed
    set exit_flag 0
    set _unplaced_ports [get_db ports -if .place_status!=fixed]
    if { [llength $_unplaced_ports] > 0} {
        puts "ERROR below ports are uplaced. "
        foreach _p $_unplaced_ports {
            puts "[get_db $_p .name]"
        } 
        puts "\n"
        set exit_flag 1
    }

    set _unfixed_macros [get_db insts -if {.base_cell.class==block&&.place_status!=fixed}]
    if { [llength $_unfixed_macros] } {
        puts "ERROR below macros are not fixed."
        foreach _c $_unfixed_macros {
            puts "[get_db $_c .name]" 
        }
        puts "\n"
        set exit_flag 1
    }
    if {$exit_flag} {
        puts "Fatal Error. exit."
        exit 1
    }
} else {
	set IS_PHYSICAL_CMD ""
	set SPATIAL_CMD ""
}

#------------------------------------------------------------------------------
# FE PRE GENERIC REPORTS
#------------------------------------------------------------------------------
if { [info exists FE_MODE] && $FE_MODE } {
   set st_t [exec date +%s]
    set stt [clock seconds]
    puts "-I-  FE PRE GENERIC REPORTS at: [clock format $stt -format "%d/%m/%y %H:%M:%S"]"

    #------------------------------------------------------------------------------
    # read HDL Report
    #------------------------------------------------------------------------------
   eee {fe_report_hdl} syn.time "FE READ HDL"
    
    #------------------------------------------------------------------------------
    # reload_timing_constraints
    #------------------------------------------------------------------------------
    set constraint_mode_sdc $sdc_files(func)
    redirect [file join [get_db user_stage_reports_dir]/timing_constraints.rpt] "update_constraint_mode -name [get_db constraint_modes .name] -sdc_files [list $constraint_mode_sdc]"
    
    #------------------------------------------------------------------------------
    # Checks and Reports
    #------------------------------------------------------------------------------
   set cmd "fe_check_design $CHECK_DESIGN_WAIVERS"
   eee $cmd syn.time "FE CHECK DESIGN"
   set cmd "fe_check_timing $CHECK_TIMING_WAIVERS"
   eee $cmd syn.time "FE CHECK TIMING"

   eee {report_logic_levels_histogram -threshold 25 -details > [get_db user_stage_reports_dir]/report_logic_levels_histogram.rpt} syn.time "FE REPORT LOGIC LEVELS"

    set file_w [open [get_db user_stage_reports_dir]/report_net_loads.rpt w]
    foreach el [get_db nets -expr {$obj(.num_loads) > 25}] {
      puts $file_w "[get_db $el .name] [get_db $el .num_loads]"
    }
    close $file_w

    set ett [clock seconds]
    puts "-I- End running FE PRE GENERIC REPORTS at: [clock format $ett -format "%d/%m/%y %H:%M:%S"]"
    puts "-I- Elapse time is [expr ($ett - $stt)/60/60/24] days , [clock format [expr $ett - $stt] -timezone UTC -format %T]"
   set en_t [exec date +%s]
   set run_time [calc_run_time $st_t $en_t]
   set OFILE [open syn.time a]
   puts $OFILE "Run time of    FE reports stage: $run_time"
   close $OFILE
}

#------------------------------------------------------------------------------
# pre generic extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_generic_setting.tcl]} {
	puts "-I- reading pre_generic_setting file from scripts_local"
	source -v ./scripts_local/pre_generic_setting.tcl
} 
#------------------------------------------------------------------------------
# running generic
#------------------------------------------------------------------------------
##### standard wbSynGen
set_db be_stage syn_gen
be_set_design_source
puts "-I- BE: Running syn_gen $IS_PHYSICAL_CMD"

be_report_all_root_attributes pre_syn_gen

if { [file exists reports/[get_db be_stage]/FAIL] } { exec rm reports/[get_db be_stage]/FAIL }
if { [file exists reports/[get_db be_stage]/PASS] } { exec rm reports/[get_db be_stage]/PASS }
if { [catch {eee_stage syn_gen "syn_generic $IS_PHYSICAL_CMD" syn.time "SYN GEN" } res] } { 
    exec touch reports/[get_db be_stage]/FAIL
    puts "-E- Failed [get_db be_stage]"
    if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {  return  }
    exit 1
}


#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
puts "-I- Saving design after syn_gen"    
write_db -all_root out/${DESIGN_NAME}.syn_gen.db
write_hdl       > out/${DESIGN_NAME}.syn_gen.v.gz
write_hdl  -lec > out/${DESIGN_NAME}.syn_gen.v.lec.gz
write_hdl $DESIGN_NAME -abstract > out/${DESIGN_NAME}_stub.v
gen_dummy_liberty                  out/${DESIGN_NAME}_stub.v out/${DESIGN_NAME}_from_stub.lib $DESIGN_NAME

exec touch reports/[get_db be_stage]/PASS

#------------------------------------------------------------------------------
# gen reports
#------------------------------------------------------------------------------

set sub_stage "syn_gen"
if {![file exists reports/$sub_stage]} {exec mkdir -pv reports/$sub_stage}
set_db user_stage_reports_dir reports/$sub_stage

set cmd "report_clock_gating        > reports/$sub_stage/report_clock_gating.rpt"
eee $cmd syn.time "CG GENERAL SYN_GEN REPORT"
set cmd "report_clock_gating -fanout_histogram -step {{1 32} {33 48} {49 64}} >> reports/$sub_stage/report_clock_gating_fanout_histogram.rpt"
eee $cmd syn.time "CG FANOUT SYN_GEN REPORT"
set cmd "report_clock_gating -gated_ff    > reports/$sub_stage/report_clock_gating_gated_ff.rpt"
eee $cmd syn.time "CG GATED FF SYN_GEN REPORT"
set cmd "report_clock_gating -ungated_ff     > reports/$sub_stage/report_clock_gating_ungated_ff.rpt"
eee $cmd syn.time "CG UNGATED FF SYN_GEN REPORT"
set cmd "report_clock_gates -get_sinks gated_only_by_user > reports/$sub_stage/report_clock_gates_user_only.rpt"
eee $cmd syn.time "CG USER GATED SYN_GEN REPORT"
set cmd "report_dp -all -ungroup > reports/$sub_stage/report_dp_ungroup.datapath"
eee $cmd syn.time "REPORT DP SYN_GEN"
set cmd "be_report_timing_summary -out reports/$sub_stage/syn_gen_timing.rpt"
eee $cmd syn.time "BE REPORT TIMING SYN_GEN"
puts "-I- Report messages"    
set cmd "be_report_messages    ./reports/$sub_stage/syn_gen_report_messages.rpt"
eee $cmd syn.time "BE REPORT MSG SYN_GEN"
puts "-I- Report macros"
eee {redirect  reports/report_macro_count.rpt {be_report_macro_count}} syn.time "MACRO COUNT SYN_GEN"
puts "-I- Report IO status"
set cmd "report_ports_status reports/$sub_stage/syn_gen_io_status.rpt"
eee $cmd syn.time "PORTS STATUS SYN_GEN"
if { [info exists REPORT_FI_FO_SIZE] && $REPORT_FI_FO_SIZE } {
puts "-I- Report FI depth"
   set cmd "fi_depth      reports/$sub_stage/syn_gen_fi_depth.rpt"
   eee $cmd syn.time "FI DEPTH SYN_GEN"
puts "-I- Report FO depth"
   set cmd "fo_depth      reports/$sub_stage/syn_gen_fo_depth.rpt"
   eee $cmd syn.time "FO DEPTH SYN_GEN"
} else {
	puts "-I- skipping report ${sub_stage} fi_fo size, by user flag"
}
puts "-I- Report not allowed clock gates"
set cmd "fe_check_clock_gate reports/$sub_stage/syn_gen_not_allowed_clock_gates.rpt"
eee $cmd syn.time "CG CHECK SYN_GEN"
#    report_timing -logic_levels 1000 -views [lindex [get_db [get_db analysis_views *setup*] .name] 0] > reports/$sub_stage/syn_gen_logic_levels.rpt
if { [info exists REPORT_LOGIC_LEVELS] && $REPORT_LOGIC_LEVELS } {
	puts "-I- Report ${sub_stage} logic_levels"
   set cmd "fe_report_timing_logic_levels reports/$sub_stage/syn_gen_logic_levels.rpt"
   eee $cmd syn.time "LOGIC LEVELS SYN_GEN"
} else {
	puts "-I- skipping report ${sub_stage} logic_levels, by user flag"
}
puts "-I- check_design"
set cmd "check_design -undriven -unloaded -multiple_driver -unresolved > ./reports/$sub_stage/syn_gen_check_design_verbose.rpt"
eee $cmd syn.time "CHECK DESIGN FEW OPTIONS SYN_GEN"
set cmd "check_design > ./reports/$sub_stage/syn_gen_check_design.rpt"
eee $cmd syn.time "CHECK DESIGN GENERAL SYN_GEN"
puts "-I- check_timing_intent"
set cmd "check_timing_intent  > ./reports/$sub_stage/syn_gen_check_timing.rpt"
eee $cmd syn.time "CHECK TIMING SYN_GEN"
set cmd "check_timing_intent -verbose > ./reports/$sub_stage/syn_gen_check_timing.verbose.rpt"
eee $cmd syn.time "CHECK TIMING VERBOSE SYN_GEN"

if { $FE_MODE != "true" } {
    puts "-I- FE_MODE is false"    
   set cmd "user_report_ff reports/$sub_stage/syn_gen.FF.list"
   eee $cmd syn.time "REPORT FF SYN_GEN"
#    report_timing -logic_levels 1000 -views [lindex [get_db [get_db analysis_views *setup*] .name] 0] > reports/$sub_stage/syn_gen_logic_levels.rpt
   set cmd "redirect reports/$sub_stage/syn_gen_hier_cell_count.rpt { ory_report_hier }"
   eee $cmd syn.time "ORY REPORT HIER SYN_GEN"
    puts "-I- be_reports"
    if { [catch {be_reports    -stage syn_gen -sequentials -power -multibit} res] } { 
        puts "-E- An error occurred while running be_reports"
        puts $res 
    } else { 
  	    puts "-I- be_sum_to_csv"
      eee {be_sum_to_csv -stage syn_gen} syn.time "SUM2CSV SYN_GEN"
    }
} else {
  # <HN> reverting back to sub-stage, synced with Oren and Raz
    set_db user_stage_reports_dir reports/${sub_stage}
    puts "-I- FE_MODE is true"
   eee {fe_report_hdl} syn.time "FE REPORT HDL SYN_GEN"
   eee {fe_report_messages syn_generic} syn.time "FE REPORT MESSAGE SYN_GEN"

    puts "-I- Running fe_report_ft"
   eee {fe_report_ft} syn.time "FE REPORT FT SYN_GEN"
     
    puts "-I- Report tap clock FO"
   eee {fe_report_tap_clock_fo [get_db user_stage_reports_dir]/syn_gen_report_tap_clock_fo.rpt} syn.time "FE REPORT TAP CLK FO SYN_GEN"

    #            - report_flops:
    puts "-I- Running report_sequential -hier"
   eee {report_sequential -hier > [get_db user_stage_reports_dir]/flops.rpt.gz} syn.time "FE REPORT SEQ SYN_GEN"

#    set_db user_stage_reports_dir reports/$sub_stage   ;# <HN> initial change reverted, no need for update
    #            - report_messages:
    puts "-I- Running FE report messages"
    redirect [get_db user_reports_dir]/report_messages_${sub_stage}.rpt     { report_messages -warning -error -all -message_list "[get_db messages .name SDC* CDFG* ELAB*]" } 
    redirect [get_db user_reports_dir]/report_messages_all_${sub_stage}.rpt { report_messages -all }

    
  	puts "-I- Running be_reports"
    if { [catch {be_reports -stage syn_gen -timing -power -sequentials} res] } { 
        puts "-E- An error occurred while running be_reports"
        puts $res 
    }
    
    puts "-I- Done syn_gen reporting"
}

#------------------------------------------------------------------------------
# Stop after syn_gen
#------------------------------------------------------------------------------
if { [info exists STOP_AFTER] && $STOP_AFTER == "syn_gen" } {
    if { !$FE_MODE } {
        # Mail results
        be_sum_to_csv -stage syn_gen -final -mail
    }
    puts "-I- Stopping after syn_gen"
    exec touch .syn_done
    
    if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {
        return
    }
    exit        
}

#------------------------------------------------------------------------------
# group path
#------------------------------------------------------------------------------
puts "-I- Grouping Paths"
set reset true
foreach mode_ [get_db constraint_modes  .name] {
   set_interactive_constraint_modes "$mode_"
   
   if { $reset } { reset_path_group -all ; if { [catch {delete_obj [get_db cost_groups]} res] } {puts "-W- Failed to delete cost group"} ; set reset false }
   
   set mems     [get_db insts -if .base_cell.is_memory==true]
   set all_regs [remove_from_collection [filter_collection [all_registers ] is_integrated_clock_gating_cell!=true] $mems]
   # Higher number means higher priority
   set default_priority 5
   set special_priority 10
   set very_special_priority 15
   
   if { [sizeof $all_regs] > 0 } {
       puts "-I- reg2reg"
       set excp [group_path -name reg2reg -from [remove_from_collection $all_regs $mems] -to [remove_from_collection $all_regs $mems]]
       set_db $excp .user_priority $default_priority
   
       puts "-I- reg2out"
       set excp [group_path -name reg2out -from [remove_from_collection $all_regs $mems] -to [all_outputs]]
       set_db $excp .user_priority $default_priority   
   
       puts "-I- in2reg"
       set excp [group_path -name in2reg  -from [all_inputs]    -to [remove_from_collection $all_regs $mems]]
       set_db $excp .user_priority $default_priority
   }

   if {[sizeof_collection $mems] > 0 } {
        puts "-I- mem2reg"
	    set excp [group_path -name mem2reg -from [get_pins -of_objects $mems -filter {is_clock}] -to [all_registers]]
        set_db $excp .user_priority $special_priority        

        puts "-I- mem2out"
	    set excp [group_path -name mem2out -from [get_pins -of_objects $mems -filter {is_clock}] -to [all_outputs]]
        set_db $excp .user_priority $special_priority        

        puts "-I- reg2mem"
	    set excp [group_path -name reg2mem   -from [all_registers] -to [get_pins -of_objects $mems -filter {direction=~ in}]]
        set_db $excp .user_priority $special_priority

        puts "-I- in2mem"        
	    set excp [group_path -name in2mem   -from [all_inputs] -to [get_pins -of_objects $mems -filter {direction=~ in}]]
        set_db $excp .user_priority $special_priority        
   }
   
   if { $is_chiplet && [info exists stubs_list] && $stubs_list != "" && $ILM_FILES != "" } {
       
       foreach stub $stubs_list {
           set module [lindex [exec grep "module " $stub] 1] 
           set hcells [get_db hinsts -if .module.name==$module]

           foreach hcell $hcells { 
               
               set name [get_db $hcell .name]
               set base_name [get_db $hcell .base_name]
                         
               puts "-I- Defining path groups for module: $module, cell: $name"
               set pins  [common_collection [get_pins -hier -filter full_name=~$name/*] [get_pins -of $all_regs]]
               
               if { [sizeof $pins] == 0 } { puts "-W- No internal pins found for $name. Check if $name has ILM module" ; continue }
               
               set excp [group_path -name chiplet2$base_name -to [filter_collection $pins direction==in]]
               set_db $excp .user_priority $very_special_priority

               set excp [group_path -name ${base_name}2chiplet -from [filter_collection $pins direction==out]]
               set_db $excp .user_priority $very_special_priority
           }
           
       }
   
   }
   
   set_interactive_constraint_modes {}   
}


#------------------------------------------------------------------------------
# pre map extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_map_setting.tcl]} {
	puts "-I- reading pre_map_setting file from scripts_local"
	source -v ./scripts_local/pre_map_setting.tcl
} 

#------------------------------------------------------------------------------
# Check if design is mapped
#------------------------------------------------------------------------------
set is_design_pre_mapped false
if { [llength [get_db insts -if .base_cell=={}]] == 0 } {
    set is_design_pre_mapped true
    puts "-E- Error: Design is mapped before syn_map"  
}

#------------------------------------------------------------------------------
# running map
#------------------------------------------------------------------------------
set_db be_stage syn_map
puts "-I- BE: Running syn_map $IS_PHYSICAL_CMD"
set_db syn_map_effort medium

# !!! Cadence fix to memory block overflow !!!
::legacy::set_attr min_remap_st_block_size 100000
::legacy::set_attr min_st_block_size       100000

if { [file exists reports/[get_db be_stage]/FAIL] } { exec rm reports/[get_db be_stage]/FAIL }
if { [file exists reports/[get_db be_stage]/PASS] } { exec rm reports/[get_db be_stage]/PASS }

if { [catch {eee_stage syn_map "syn_map $IS_PHYSICAL_CMD" syn.time "SYN MAP stage"} res] } {
    if { $is_design_pre_mapped } {
        puts "-W- Genus failed running syn_map on a fully mapped design"    
    } else {
        exec touch reports/[get_db be_stage]/FAIL
        puts "-E- Failed [get_db be_stage]"
        if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {  return  }
        exit 1
    }
}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
set sub_stage "syn_map"
set cmd "write_db -all_root out/${DESIGN_NAME}.syn_map.db"
eee $cmd syn.time "WRITE DB SYN_MAP"
set cmd "write_hdl -mapped      > out/${DESIGN_NAME}.syn_map.v.gz"
eee $cmd syn.time "WRITE HDL MAP SYN_MAP"
set cmd "write_hdl -lec > out/${DESIGN_NAME}.syn_map.lec.gz"
eee $cmd syn.time "WRITE HDL LEC SYN_MAP"

if { !$is_design_pre_mapped } {
  write_do_lec \
	  -top ${DESIGN_NAME} \
	  -golden_design rtl \
	  -revised_design fv_map \
	  -logfile log/lec.rtl2map.log \
	  -checkpoint out/verified.ckpt  > [file join [get_db current_design .verification_directory] lec.rtl2map.do] 
}

exec touch reports/[get_db be_stage]/PASS

#------------------------------------------------------------------------------
# map reports
#------------------------------------------------------------------------------
if {![file exists reports/$sub_stage]} {exec mkdir -pv reports/$sub_stage}
set_db user_stage_reports_dir reports/$sub_stage

#puts "-I- Check Design [::ory_time::now]"
#check_design -undriven -unloaded -multiple_driver -unresolved > ./reports/$sub_stage/syn_map_check_design_verbose.rpt
#check_design > ./reports/$sub_stage/syn_map_check_design.rpt
#check_timing_intent  > ./reports/$sub_stage/syn_map_check_timing.rpt 
#check_timing_intent -verbose > ./reports/$sub_stage/syn_map_check_timing.verbose.rpt 



if { $FE_MODE != "true" } {
    puts "-I- Report timing [::ory_time::now]"
    set cmd "be_report_timing_summary -debug_rpt -max_paths 5000  -nworst 1  -out reports/$sub_stage/syn_map.rpt"
    eee $cmd syn.time "BE REPORT TIMING SUM DEBUG SYN_MAP"
    exec ./scripts/bin/timing_filter.pl ./reports/${sub_stage}/syn_map.rpt.detailed
    foreach group [lsort -uniq [concat [get_db designs .cost_groups.name] [get_db designs .path_groups.cost_group.name]]] {
        puts "-I- Report timing for group $group"    
        set cmd "be_report_timing_summary -max_paths 2000  -nworst 1  -group $group -out reports/$sub_stage/syn_map.rpt.$group"
        eee $cmd syn.time "BE REPORT TIMING SUM SYN_MAP"
        exec ./scripts/bin/timing_filter.pl ./reports/${sub_stage}/syn_map.rpt.${group}.detailed
    }
    
    set cmd "redirect reports/$sub_stage/syn_map_hier_cell_count.rpt { ory_report_hier -area -power}"
    eee $cmd syn.time "ORY REPORT HIER SYN_MAP"
    set cmd "report_gates                      > reports/$sub_stage/syn_map.gates.rpt"
    eee $cmd syn.time "REPORT GATES SYN_MAP"
    set cmd "report_area                       > reports/$sub_stage/syn_map.area.rpt"
    eee $cmd syn.time "REPORT AREA SYN_MAP"
    set cmd "report_design_rules               > reports/$sub_stage/syn_map.drc"
    eee $cmd syn.time "REPORT DESIGN RULES SYN_MAP"
    set cmd "report_dp -all -ungroup           > reports/$sub_stage/syn_map.datapath"
    eee $cmd syn.time "REPORT DP SYN_MAP"
    ###### Report Clock Gates ######
    puts "-I- Report Clock Gates [::ory_time::now]"
    set cmd "report_clock_gating               > reports/$sub_stage/syn_map.cg"
    eee $cmd syn.time "CG GENERAL SYN_MAP"
    set cmd "report_clock_gating -fanout_histogram -step {{1 32} {33 48} {49 64}} >> reports/$sub_stage/syn_map.cg"
    eee $cmd syn.time "CG FANOUT SYN_MAP"
    set cmd "report_clock_gating -gated_ff     > reports/$sub_stage/syn_map_detail.cg"
    eee $cmd syn.time "CG GATED FF SYN_MAP"
    set cmd "report_clock_gating -ungated_ff     > reports/$sub_stage/syn_map_ungated_ff.cg"
    eee $cmd syn.time "CG UNGATED FF SYN_MAP"
    set cmd "report_clock_gates -get_sinks gated_only_by_user > reports/$sub_stage/syn_map_report_clock_gates_user_only.rpt"
    eee $cmd syn.time "CG USER GATED SYN_MAP"
    puts "-I- Report messages"    
    set cmd "be_report_messages    ./reports/$sub_stage/syn_map_report_messages.rpt"
    eee $cmd syn.time "BE REPORT MSG SYN_MAP"
    puts "-I- BE Reports [::ory_time::now]"    
    if { [catch {be_reports -all -stage syn_map} res] } { 
        puts "-E- An error occurred while running be_reports"
        puts $res 
    } else { 
        puts "-I- be_sum_to_csv"
        be_sum_to_csv   -stage syn_map
    }
    if {([info exists IS_PHYSICAL] && $IS_PHYSICAL == "true") || ([info exists IS_HYBRID] && $IS_HYBRID == "true")} {
        set cmd "user_report_inst_vt               reports/$sub_stage/syn_map.vt"
        eee $cmd syn.time "INST VT SYN_MAP"
    }
} else {
   eee {fe_report_hdl} syn.time "FE REPORT HDL SYN_MAP"
   eee {fe_report_messages syn_map} syn.time "FE REPORT MESSAGE SYN_MAP"
   set cmd "report_dp -all -ungroup           > reports/$sub_stage/syn_map.datapath"
   eee $cmd syn.time "FE REPORT DP SYN_MAP"
   	puts "-I- Report messages"    
   set cmd "be_report_messages    ./reports/$sub_stage/${sub_stage}_report_messages.rpt"
   eee $cmd syn.time "FE REPORT MSG SYN_MAP"
  	puts "-I- be_reports"
    if { [catch {be_reports -stage syn_map -timing -power -sequentials} res] } { 
        puts "-E- An error occurred while running be_reports"
        puts $res 
    }
}

#------------------------------------------------------------------------------
# Stop after syn_map
#------------------------------------------------------------------------------
if { [info exists STOP_AFTER] && $STOP_AFTER == "syn_map" } {
    if { !$FE_MODE } {
        # Mail results
        be_sum_to_csv -stage syn_map -final -mail
    }
    puts "-I- Stopping after syn_map"
    exec touch .syn_done    

    if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {
        return
    }
    exit        
}

#------------------------------------------------------------------------------
# pre opt extra setting script
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_opt_setting.tcl]} {
	puts "-I- reading pre_opt_setting file from scripts_local"
	source -v ./scripts_local/pre_opt_setting.tcl
} 

#------------------------------------------------------------------------------
# scan insertion
#------------------------------------------------------------------------------
if {[info exists SCAN] && $SCAN == "true" && !$FE_MODE} {
	set_interactive_constraint_modes func

	if {[sizeof_collection [get_db ports dft_scan_en]] > 0} { set_case_analysis 0 [get_db ports  dft_scan_en]}
	if {[sizeof_collection [get_db ports scan_en]] > 0} { set_case_analysis 0 [get_db ports  scan_en]}
	if {[sizeof_collection [get_db ports shift_en]] > 0} { set_case_analysis 0 [get_db ports shift_en]}
	if {[sizeof_collection [get_pins -quiet -hierarchical */ti]] > 0} {
   		puts "-I- apply multicycle on ti pins"
   		set_multicycle_path 7 -hold  -to [get_pins -hierarchical */ti]
   		set_multicycle_path 8 -setup -to [get_pins -hierarchical */ti]
	}

         set_interactive_constraint_modes {}

	#identify_shift_register_scan_segments
   eee {connect_scan_chains} syn.time "SCAN INSERTION"
	
}

#------------------------------------------------------------------------------
# running Opt
#------------------------------------------------------------------------------
if {[info exists FLAT_DESIGN] && $FLAT_DESIGN == "syn_opt"} {
    set_db ui_respects_preserve false 
    set num_sp [llength [get_db hinsts *_state_point*] ]
    
    if { $num_sp != 0 } {
       foreach sp [get_db hinsts *_state_point*] {
       set_db $sp .preserve false
       }
    }
    ungroup -all -flatten -force
    set_db ui_respects_preserve true 
}

# If -spatial - create a preload script
if { $SPATIAL_CMD == "-spatial" } {
    puts "-I- Writing invs_preload_script"
    set invs_preload scripts_local/invs_preload.tcl
    set fp [open $invs_preload w]
    
    puts $fp "# -I- Passing user and flow variables from Genus
	set CPU                  $CPU                 
	set DESIGN_NAME          $DESIGN_NAME         
	set IS_PHYSICAL          $IS_PHYSICAL        
	set DEF_FILE             $DEF_FILE            
	set SDC_LIST             {$SDC_LIST}            
	set STOP_AFTER           $STOP_AFTER          
    set SCAN                 $SCAN                
    set OCV                  $OCV                 
    set STAGE                $STAGE        

    ############################################################
    # Actual setup file
    ############################################################
    source -v $setup_file
	" 
    
    close $fp
    set_db invs_preload_script $invs_preload
}

##### standard wbSynOpt
set_db be_stage syn_opt
puts "-I- BE: Running syn_opt $SPATIAL_CMD"
set_db syn_opt_effort high

if { [file exists reports/[get_db be_stage]/FAIL] } { exec rm reports/[get_db be_stage]/FAIL }
if { [file exists reports/[get_db be_stage]/PASS] } { exec rm reports/[get_db be_stage]/PASS }

if { [catch {eee_stage syn_opt "syn_opt $SPATIAL_CMD" syn.time "SYN OPT stage"} res] } {
    exec touch reports/[get_db be_stage]/FAIL
    puts "-E- Failed [get_db be_stage]"
    if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {  return  }
    exit 1
}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
set sub_stage "syn_opt"
set cmd "write_db -all_root out/${DESIGN_NAME}.syn_opt.db"
eee $cmd syn.time "WRITE DB SYN_OPT"
set cmd "write_hdl -mapped  > out/${DESIGN_NAME}.syn_opt.v.gz"
eee $cmd syn.time "WRITE HDL SYN_OPT"

exec touch reports/[get_db be_stage]/PASS

#------------------------------------------------------------------------------
# opt reports
#------------------------------------------------------------------------------

if {![file exists reports/$sub_stage]} {exec mkdir -pv reports/$sub_stage}
set_db user_stage_reports_dir reports/$sub_stage

# IO size reports
if { [info exists REPORT_FI_FO_SIZE] && $REPORT_FI_FO_SIZE } {
    puts "-I- Running fe_report_io_fo $sub_stage"
    eee "fe_report_io_fo ${sub_stage}" syn.time "FE REPORT IO FO SYN_GEN"
    # reports will be under reports/${sub_stage}/${sub_stage}_outputs_fi_size.rpt
    #                       reports/${sub_stage}/${sub_stage}_inputs_fo_size.rpt
} else {
    puts "-I- skipping report ${sub_stage} fi fo size, by user flag"
}

# Logic Levels reports
if { [info exists REPORT_LOGIC_LEVELS] && $REPORT_LOGIC_LEVELS } {
    puts "-I- Running fe_io_logic_levels syn_gen"
    eee "fe_io_logic_levels ${sub_stage}" syn.time "FE IO LOGIC LEVELS SYN_GEN"
    # reports will be under reports/${sub_stage}/${sub_stage}_report_*_logic_levels.rpt
} else {
    puts "-I- skipping report ${sub_stage} logic leves, by user flag"
}

# Timing Summary
puts "-I- Report timing [::ory_time::now]"
set cmd "be_report_timing_summary -debug_rpt -max_paths 5000 -out reports/$sub_stage/syn_opt.rpt"
eee $cmd syn.time "BE TIMING SUM DEBUG SYN_OPT"
exec ./scripts/bin/timing_filter.pl ./reports/${sub_stage}/syn_opt.rpt.detailed
foreach group [lsort -uniq [concat [get_db designs .cost_groups.name] [get_db designs .path_groups.cost_group.name]]] {
    puts "-I- Report timing for group $group"
   set cmd "be_report_timing_summary -max_paths 2000  -nworst 1  -group $group -out reports/$sub_stage/syn_opt.rpt.$group"
   eee $cmd syn.time "BE TIMING SUM SYN_OPT"
    exec ./scripts/bin/timing_filter.pl ./reports/${sub_stage}/syn_opt.rpt.${group}.detailed
}

# We decided with FE to remove. if needed define JOJO=1
if {[info exists JOJO] && $JOJO} {
   set st_t [exec date +%s]
if { ![info exists FLAT_DESIGN] || $FLAT_DESIGN != "syn_opt" } {
   eee "ory_report_hier -level 2 -area -power  -file_name  reports/hier_cell_count_area_power.rpt "
   eee "ory_report_hier -level 3 -area         -file_name  reports/hier_cell_count_area_L3.rpt    "
   eee "ory_report_hier -level 4 -area         -file_name  reports/hier_cell_count_area_L4.rpt    "
}
   set en_t [exec date +%s]
   set run_time [calc_run_time $st_t $en_t]
   set OFILE [open syn.time a]
   puts $OFILE "Run time of    REPORT HIER stage: $run_time"
   close $OFILE
}

puts "-I- Check Design [::ory_time::now]"
set cmd "check_design -undriven -unloaded -multiple_driver -unresolved > ./reports/$sub_stage/syn_opt_check_design_verbose.rpt"
eee $cmd syn.time "CHECK DESIGN FEW OPTIONS SYN_OPT"
set cmd "check_design > ./reports/$sub_stage/syn_opt_check_design.rpt"
eee $cmd syn.time "CHECK DESIGN GENERAL SYN_OPT"
set cmd "check_timing_intent  > ./reports/$sub_stage/syn_opt_check_timing.rpt"
eee $cmd syn.time "CHECK TIMING SYN_OPT"
set cmd "check_timing_intent -verbose > ./reports/$sub_stage/syn_opt_check_timing.verbose.rpt"
eee $cmd syn.time "CHECK TIMING VERBOSE SYN_OPT"
set cmd "report_gates                      > reports/$sub_stage/syn_opt.gates.rpt"
eee $cmd syn.time "REPORT GATES SYN_OPT"
set cmd "report_area                       > reports/$sub_stage/syn_opt.area.rpt"
eee $cmd syn.time "REPORT AREA SYN_OPT"
set cmd "report_design_rules                     > reports/$sub_stage/syn_opt.drc"
eee $cmd syn.time "REPORT DESIGN RULES SYN_OPT"
set cmd "report_dp -all -ungroup           > reports/$sub_stage/syn_opt.datapath"
eee $cmd syn.time "REPORT DP SYN_OPT"

###### Report Clock Gates ######
puts "-I- Report Clock Gates [::ory_time::now]"
set cmd "report_clock_gating               > reports/$sub_stage/syn_opt.cg"
eee $cmd syn.time "CG GENERAL SYN_OPT"
set cmd "report_clock_gating -fanout_histogram -step {{1 32} {33 48} {49 64}} >> reports/$sub_stage/syn_opt.cg"
eee $cmd syn.time "CG FANOUT SYN_OPT"
set cmd "report_clock_gating -detail     > reports/$sub_stage/syn_opt_detail.cg"
eee $cmd syn.time "CG DETAILED SYN_OPT"
set cmd "report_clock_gating -ungated_ff   > reports/$sub_stage/syn_opt_ungated_ff.cg"
eee $cmd syn.time "CG UNGATED FF SYN_OPT"
set cmd "report_clock_gates -get_sinks gated_only_by_user > reports//$sub_stage/syn_opt_report_clock_gates_user_only.rpt"
eee $cmd syn.time "CG USER GATED SYN_OPT"

if {([info exists IS_PHYSICAL] && $IS_PHYSICAL == "true" ) || ([info exists IS_HYBRID] && $IS_HYBRID == "true")} {
   set cmd "user_report_inst_vt               reports/$sub_stage/syn_opt.vt"
   eee $cmd syn.time "INST VT SYN_OPT"
}

if { [file exists ./scripts_local/additional_reports.tcl ] } {
    puts "-I- Running additional reports from ./scripts_local/additional_reports.tcl"
    source ./scripts_local/additional_reports.tcl
}

set cmd "be_report_messages    ./reports/$sub_stage/syn_opt_report_messages.rpt"
eee $cmd syn.time "BE REPORT MSG SYN_OPT"
puts "-I- BE Reports [::ory_time::now]"
if { [catch {be_reports  -all -stage syn_opt} res] } { 
    puts "-E- An error occurred while running be_reports"
    puts $res 
} else { 
    puts "-I- be_sum_to_csv"
    be_sum_to_csv    -stage syn_opt
}

# TM - Report detail area before ungroup and flattening
#eee {redirect reports/report_area.rpt {report_area -detail}} syn.time "REPORT AREA DETAILED FINAL"
eee {report_area -detail                      > reports/report_area.detailed.rpt} syn.time "REPORT AREA DETAILED FINAL"

set_db user_stage_reports_dir "reports"

#------------------------------------------------------------------------------
# rename and save design
#------------------------------------------------------------------------------
set st_t [exec date +%s]
if {[info exists FLAT_DESIGN] && $FLAT_DESIGN == "save_design"} {

    set_db ui_respects_preserve false 
    
    set num_sp [llength [get_db hinsts *_state_point*] ]
    
    if { $num_sp != 0 } {
       foreach sp [get_db hinsts *_state_point*] {
       set_db $sp .preserve false
       }
    }
    
    ungroup -all -flatten -force
    
    set_db ui_respects_preserve true 
    
}

##### standard wbRename
set_db ui_respects_preserve false
update_names -prefix ${DESIGN_NAME}_ -force -verilog -module design:${DESIGN_NAME}
set_db ui_respects_preserve true
set en_t [exec date +%s]
set run_time [calc_run_time $st_t $en_t]
set OFILE [open syn.time a]
puts $OFILE "Run time of     RENAME stage: $run_time"
close $OFILE

if {([info exists IS_PHYSICAL] && $IS_PHYSICAL == "true")  || ([info exists IS_HYBRID] && $IS_HYBRID == "true")} {
	write_def ${DESIGN_NAME} > out/${DESIGN_NAME}.Syn.def.gz
#	write_design -innovus -db -base_name out/${DESIGN_NAME}.Syn.invs_db/${DESIGN_NAME} -gzip_files ${DESIGN_NAME}
#	write_db -common -base_name out/${DESIGN_NAME}.Syn.invs_db/${DESIGN_NAME} -gzip_files
	write_db -common out/${DESIGN_NAME}.Syn.invs_db
	 
}

set cmd "write_db -all_root_attributes -to_file out/${DESIGN_NAME}.Syn.db"
eee $cmd syn.time "WRITE DB FINAL"
set cmd "write_hdl -mapped      > out/${DESIGN_NAME}.Syn.v.gz"
eee $cmd syn.time "WRITE HDL MAP FINAL"
set cmd "write_hdl -mapped -lec > out/${DESIGN_NAME}.Syn.v.lec.gz"
eee $cmd syn.time "WRITE HDL LEC FINAL"

#------------------------------------------------------------------------------
# final LEC
#------------------------------------------------------------------------------
if { !$is_design_pre_mapped } {
  write_do_lec \
	  -top $DESIGN_NAME \
	  -golden_design fv_map \
	  -revised_design out/${DESIGN_NAME}.Syn.v.gz \
	  -logfile log/lec.map2Syn.log \
	  -checkpoint out/verified.ckpt  > [file join [get_db current_design .verification_directory] lec.map2Syn.do]
}

write_do_lec \
	-top $DESIGN_NAME \
	-golden_design rtl \
	-revised_design out/${DESIGN_NAME}.Syn.v.gz \
	-write_session  session \
	-logfile log/lec.rtl2Syn.log \
	-checkpoint out/verified.ckpt  > [file join [get_db current_design .verification_directory] lec.rtl2Syn.do]

set cmd "write_name_mapping -to_file reports/${DESIGN_NAME}_genus_syn_mapping.rpt"
eee $cmd syn.time "WRITE NAME MAPPING FINAL"

exec touch .syn_outputs_done

#------------------------------------------------------------------------------
# SCAN outputs and reports
#------------------------------------------------------------------------------

if {[info exists SCAN] && $SCAN == "true" && !$FE_MODE} {
	puts  "-I- doing: write_scandef"
	write_scandef ${DESIGN_NAME} > out/${DESIGN_NAME}.Syn.scandef.gz
	puts  "-I- doing: write_dft_abstract_model - If it stuck - tell Roy!!"
	write_dft_abstract_model > out/${DESIGN_NAME}.Syn.scan.abstract
	puts  "-I- doing: write_dft_abstract_model -ctl"
	write_dft_abstract_model -ctl > out/${DESIGN_NAME}.ctl
	
	puts  "-I- doing: report_scan_registers -dont_scan"
	report_scan_registers -dont_scan > reports/dft/report_scan_registers_dont_scan.rpt
	puts  "-I- doing: report_scan_registers -multi_bit"
	report_scan_registers -multi_bit > reports/dft/report_scan_registers_multi_bit.rpt
	puts  "-I- doing: report_scan_registers -fail_tdrc"
	report_scan_registers -fail_tdrc > reports/dft/report_scan_registers_fail_tdrc.rpt
	puts  "-I- doing: report_scan_registers -other"
	report_scan_registers -other     > reports/dft/report_scan_registers_none_scan.rpt
	puts  "-I- doing: report_scan_chains -summary"
	report_scan_chains -summary > reports/dft/report_scan_chains_summary.rpt
	puts  "-I- doing: report_scan_chains"
	report_scan_chains > reports/dft/report_scan_chains.rpt
	
}
exec touch .syn_netlist_done


#------------------------------------------------------------------------------
# final reports
#------------------------------------------------------------------------------

puts "-I- Report timing [::ory_time::now]"
eee {be_report_timing_summary -max_paths 10000  -nworst 1  -out reports/syn.rpt} syn.time "BE REPORT TIMING SUM DEBUG FINAL"
eee {report_gates                      > reports/syn.gates.rpt} syn.time "REPORT GATES FINAL"
eee {report_area                       > reports/syn.area.rpt} syn.time "REPORT AREA FINAL"
eee {report_design_rules                     > reports/syn.drc} syn.time "REPORT DESIGN RULES FINAL"
eee {report_dp  -all -ungroup          > reports/syn.datapath} syn.time "REPORT DP FINAL"
puts "-I- Report Clock Gates [::ory_time::now]"
eee {report_clock_gating               > reports/syn.cg} syn.time "CG GENERAL FINAL"
eee {report_clock_gating -fanout_histogram -step {{1 32} {33 48} {49 64}} >> reports/syn.cg} syn.time "CG FANOUT FINAL"
eee {report_clock_gating -detail     > reports/syn_detail.cg} syn.time "CG DETAILED FINAL"
eee {report_clock_gating -ungated_ff   > reports/syn_ungated_ff.cg} syn.time "CG UNGATED FF FINAL"
eee {report_clock_gates -get_sinks gated_only_by_user > reports/syn_report_clock_gates_user_only.rpt} syn.time "CG USER GATED FINAL"

if {[info exists IS_PHYSICAL] && $IS_PHYSICAL == "true"} {
   eee {user_report_inst_vt               reports/syn.vt} syn.time "INST VT FINAL"
}

set end_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - End running $STAGE at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
puts "-I- BE_STAGE: $STAGE - Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

puts "-I- BE Reports [::ory_time::now]"
if { [catch {be_reports    -stage $STAGE -block $DESIGN_NAME -all} res] } { 
    puts "-E- An error occurred while running be_reports"
    puts $res 
}
eee {redirect  reports/report_macro_count.rpt {be_report_macro_count}} syn.time "MACRO COUNT FINAL"
set cmd "report_metric -format html -file reports/${DESIGN_NAME}.Syn.html"
eee $cmd syn.time "REPORT METRIC FINAL"
set cmd "write_metric -format csv -file reports/${DESIGN_NAME}.Syn.csv"
eee $cmd syn.time "WRITE METRIC FINAL"

#if {[info exists CREATE_LIB] && $CREATE_LIB == "true" } {
#    puts "-I- creating lib file"
#    write_lib_lef  -lib out/${DESIGN_NAME}.lib
#}

write_sdc \
    -exclude {set_units current_design set_timing_derate group_path set_dont_use } \
    -view [lindex [get_db [get_db analysis_views] .name] 0] \
    -no_split ${DESIGN_NAME} > out/${DESIGN_NAME}.sdc

if {[info exists CREATE_SPEF] && $CREATE_SPEF == "true" } {
   	set start_t [clock seconds]
   set st_t [exec date +%s]
 	foreach view [get_db analysis_views .name] {
		set rc_ccc [get_db analysis_view:$view .delay_corner.early_rc_corner.name]
		write_parasitics -view $view > out/spef/${DESIGN_NAME}.${STAGE}.spef.${rc_ccc}.gz
	}
   	set end_t [clock seconds]
   set en_t [exec date +%s]
   set run_time [calc_run_time $st_t $en_t]
   set OFILE [open syn.time a]
   puts $OFILE "Run time of    REPORT PARASITICS: $run_time"
   close $OFILE
   	puts "-I- Elapse time for running write_parasitics is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
}


if { !$is_chiplet || [info exists CREATE_ILM] && $CREATE_ILM == "true" } {
    puts "-I- Generating ILM"
   set cmd "generate_ilm -basename out/ilm/${DESIGN_NAME}.syn"
   eee $cmd syn.time "GENERATE ILM"
} else {
#    puts "-I- Write parasitics for chiplet"
}

#write_lib_lef  -lib out/${DESIGN_NAME}.lib

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
report_resource
if { !$FE_MODE } {
    puts "-I- Sum to CSV AND Mail [::ory_time::now]"
    set cmd "be_sum_to_csv -stage $STAGE -mail -final"
    eee $cmd syn.time "SUM2CSV FINAL"
}
exec touch .syn_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {
    return
}

exit

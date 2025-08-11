#########################################################################################################################################################################
#																					#
#	this script will run innovus Place stage  															#
#	variable received from shell are:																#
#		SYN_DIR		 - synthesis dir to start from														#
#		CPU		 - number of CPU to run.8 per license													#
#		BATCH 		 - run in batch mode															#
#		DESIGN_NAME	 - name of top model															#
#		NETLIST_FILE 	 - netlist to read into stage														#
#		SCAN_DEF_FILE 	 - scan def file location														#
#		SCAN 		 - design with scan insertion														#
#		OCV 		 - run place with OCV															#
#		PLACE_OPT 	 - run place opt #N times														#
#		FLOW_START_FROM  - starting stage from previous db / def												#															#
#		PLACE_START_FROM - starting stage from:															#
#					db 	 : floorplan stage													#
#					def 	 : def and netlist													#
#					syn 	 : from synthesis db													#
#					syn_incr : from synthesis db do place increment											#
#																					#
#																					#
#																					#
#	 Var	date of change	owner		 comment														#
#	----	--------------	-------	 ---------------------------------------------------------------								#
#	0.1	12/01/2021	Royl	initial script															#
#	0.2	08/03/2021	OrY	 	Merge with env														#
#	0.3	14/06/2021	Royl	can start stage from def file													#
#																					#
#																					#
#########################################################################################################################################################################
set_db source_verbose false

set STAGE place
set RUNNING_LOCAL_SCRIPTS [list]

set start_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - Start running $STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
source ./scripts/procs/source_be_scripts.tcl

if {![file exists reports/$STAGE]} {mkdir -pv reports/$STAGE}
set_db user_stage_reports_dir reports/$STAGE

script_runtime_proc -start
check_script_location

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v scripts_local/setup.tcl
} else {
	puts "-I- reading ${::env(PROJECT)} setup file from scripts"
	source -v scripts/setup/setup.${::env(PROJECT)}.tcl
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
#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
#set_multi_cpu_usage -local_cpu $CPU -remote_host 1 -cpu_per_remote_host 1
set_multi_cpu_usage -local_cpu $CPU

set_db init_delete_assigns 1
set_db init_power_nets        $PWR_NET
set_db init_ground_nets       $GND_NET
set_db init_keep_empty_modules true

#------------------------------------------------------------------------------
# define and read mmmc 
#------------------------------------------------------------------------------
source scripts/flow/mmmc_create.tcl
mmmc_create

#------------------------------------------------------------------------------
# load db base
#------------------------------------------------------------------------------
if {$PLACE_START_FROM == "db"} {
	if {[info exists FLOW_START_FROM] && $FLOW_START_FROM == "def"} {
		#------------------------------------------------------------------------------
		# define and read mmmc 
		#------------------------------------------------------------------------------
		set cmd "read_mmmc { $mmmc_results }"
		redirect -tee -stderr -var mmmc_res { eval $cmd }
		
		puts "-I- read design from floorplan def"
		read_physical -lef $LEF_FILE_LIST
		read_netlist -top $DESIGN_NAME ./out/db/${DESIGN_NAME}.floorplan.enc.dat/${DESIGN_NAME}.v.gz
		init_design
		read_def ./out/def/${DESIGN_NAME}.floorplan.def.gz
	} else {
		puts "-I- read design from floorplan db"
		redirect -tee -stderr -var mmmc_res { read_db -lef_files $LEF_FILE_LIST -mmmc_file $mmmc_results  out/db/${DESIGN_NAME}.floorplan.enc.dat }
	}
} elseif {$PLACE_START_FROM == "syn" || $PLACE_START_FROM == "syn_incr"} {
	if {[info exists FLOW_START_FROM] && $FLOW_START_FROM == "def"} {
		
		#------------------------------------------------------------------------------
		# define and read mmmc 
		#------------------------------------------------------------------------------
		set cmd "read_mmmc { $mmmc_results }"
		redirect -tee -stderr -var mmmc_res { eval $cmd }
		
		puts "-I- read design from synthesis $SYN_DIR/out def"
		read_physical -lef $LEF_FILE_LIST
		read_netlist -top $DESIGN_NAME $SYN_DIR/out/${DESIGN_NAME}.Syn.invs_db/${DESIGN_NAME}.v.gz
		init_design
		read_def $SYN_DIR/out/${DESIGN_NAME}.Syn.invs_db/${DESIGN_NAME}.def.gz
	} else {
		puts "-I- read design from synthesis $SYN_DIR/out db"
		redirect -tee -stderr -var mmmc_res { read_db -lef_files $LEF_FILE_LIST -mmmc_file $mmmc_results $SYN_DIR/out/${DESIGN_NAME}.Syn.invs_db/${DESIGN_NAME}.stylus.enc }
	}
} elseif {$PLACE_START_FROM == "def"} {
	puts "-I- read design from netlist/def"
	#------------------------------------------------------------------------------
	# define and read mmmc 
	#------------------------------------------------------------------------------
	set cmd "read_mmmc { $mmmc_results }"
	redirect -tee -stderr -var mmmc_res { eval $cmd }

	#------------------------------------------------------------------------------
	# read lef and enable PLE-MODE
	#------------------------------------------------------------------------------
	read_physical -lef $LEF_FILE_LIST
	
	#------------------------------------------------------------------------------
	# read  design
	#------------------------------------------------------------------------------
	read_netlist -top $DESIGN_NAME $NETLIST_FILE

	init_design
	
	read_def $DEF_FILE
} else {
	puts "ERROR: PLACE_START_FROM is not define correctly."
	if {[info exists PLACE_START_FROM]} {puts "ERROR: PLACE_START_FROM is $PLACE_START_FROM"}
}

set fp [open reports/${STAGE}_read_sdc.rpt w]
foreach line [split $mmmc_res "\n"] { if { [regexp "sdc" $line] } { puts $fp $line } }
close $fp

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

be_set_design_source
    
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
# read scan def
#------------------------------------------------------------------------------
if { [info exists SCAN] && $SCAN =="true"} {
	##### read scan def file(s)
	puts "-I- reading scan def"
	read_def $SCAN_DEF_FILE
}
return
#------------------------------------------------------------------------------
# extra setting and operations 
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_place_setting.tcl]} {
	puts "-I- running Extra setting from scripts_local/pre_place_setting.tcl"
	check_script_location scripts_local/pre_place_setting.tcl
	source -v ./scripts_local/pre_place_setting.tcl
}

if {[info exists PLACE_OPT_POST_PLACE_TCL] && $PLACE_OPT_POST_PLACE_TCL != ""} {
    if { ![file exists $PLACE_OPT_POST_PLACE_TCL] } {
        puts "-E- The variable PLACE_OPT_POST_PLACE_TCL was defined, but the file $PLACE_OPT_POST_PLACE_TCL was not found!"
        return -1
    } else {
	    puts "-I- setting place_opt_post_place_tcl to $PLACE_OPT_POST_PLACE_TCL"
    #	set_db place_opt_post_place_tcl /space/users/moriya/grid_cluster/inter/delete_grid_cluster_guides.tcl
	    set_db place_opt_post_place_tcl $PLACE_OPT_POST_PLACE_TCL
    }
}

if {[info exists IO_BUFFERS_DIR] && ($IO_BUFFERS_DIR == "in" ||$IO_BUFFERS_DIR == "out"|| $IO_BUFFERS_DIR == "both" || $IO_BUFFERS_DIR == "in_ant" || $IO_BUFFERS_DIR == "both_ant")} {
	puts "-I- adding IO beffers to interface on $IO_BUFFERS_DIR direction"
	addiobuffer_proc \
		-buffer $IOBUFFER_CELL \
		-useable_buffer $USEABLE_IOBUFFER_CELL \
		-direction $IO_BUFFERS_DIR \
		-padding "2 0 2 0" \
		-antenna $ANTENNA_CELL_NAME \

}

if {[info exists ADDSPARECELL] && $ADDSPARECELL == "true"} {
#	need to redefine this section

	define_attribute save_place_status -obj_type inst -data_type string -skip_in_db -category user 
	set_db [get_db insts -if .place_status==placed ] .save_place_status placed 
	set_db [get_db insts -if .place_status==placed ] .place_status unplaced 
	place_spare_module_custom $SPARE_MODULE 0.005  0.050  grid_clk  grid_rst_n_ft_d:SDN
	set_db [get_db insts -if .save_place_status==placed ] .place_status placed 
	place_eco 
	#attach_spare_clocks {grid_tor_clk {{365.3965 59.9945} {155.0135 59.9945} {155.0135 120.635} {93.2085 120.635} {93.2085 59.9945} {93.112 59.9945} {93.112 15.6535} {365.3965 15.6535}}}
	report_spare_usage 
	set_db [get_db insts -if { .is_spare && .place_status==placed }] .place_status soft_fixed 
	set_db [get_db insts -if .is_spare ] .dont_touch true 
	# Uncomment to display small regions
	# set_preference MinFPModuleSize 1
	
}

#------------------------------------------------------------------------------
#  place_opt_design
#------------------------------------------------------------------------------
set_db opt_new_inst_prefix "i_${STAGE}_"
set_db opt_new_net_prefix  "n_${STAGE}_"

##### standard wbPlaceOptDesign
set_db [get_db insts -if {.base_cell.class == block}] .place_status fixed
set_db [get_db insts -if {.base_cell.class == pad}] .place_status fixed
if {$PLACE_START_FROM == "syn_incr" } {
	eee_stage pre_opt_place "
	puts \"-I- Running: place_opt_design -incremental -expanded_views -report_dir reports/place/place_design\"
	place_opt_design -incremental -expanded_views -report_dir reports/place/place_design
	puts \"-I- Running: report_resources\"
	report_resource
	puts \"-I- Running: place_detail\"
	place_detail
	"
} else {
	eee_stage pre_opt_place "
	puts \"-I- Running: place_opt_design -expanded_views -report_dir reports/place/place_design\"
	place_opt_design -expanded_views -report_dir reports/place/place_design
	puts \"-I- Running: report_resources\"
	report_resource
	puts \"-I- Running: place_detail\"
	place_detail
	"
}

set_all_ios_to_fixed


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

add_tieoffs -matching_power_domains true

#------------------------------------------------------------------------------
# WA for Pre-Route DRC
#------------------------------------------------------------------------------
#delete_drc_markers
#check_place reports/place/pre_opt_place_check_place_pre_fix.rpt
#if {[get_db markers .type place] != ""} {
#  place_detail -eco true
#  delete_drc_markers  
#  check_place reports/place/pre_opt_place_check_place_post_fix.rpt
#  if {[get_db markers .type place] != ""} {
#     set_db place_detail_eco_max_distance 50
#     place_detail -eco true
#     delete_drc_markers     
#     check_place reports/place/pre_opt_place_check_place_post_p50_fix.rpt
#  }
#}


#------------------------------------------------------------------------------
# If place_opt == 0 - do not save pre_place_opt and jump streight to save place 
#------------------------------------------------------------------------------
if { $PLACE_OPT > 0 } {

    #------------------------------------------------------------------------------
    # save design
    #------------------------------------------------------------------------------
    write_db -verilog      out/db/${DESIGN_NAME}.pre_opt_${STAGE}.enc.dat
    write_def -routing     out/def/${DESIGN_NAME}.pre_opt_${STAGE}.def.gz
    write_lef_abstract -5.8 -stripe_pins -property out/lef/${DESIGN_NAME}.pre_opt_${STAGE}.lef

    #------------------------------------------------------------------------------
    # reports
    #------------------------------------------------------------------------------
    time_design -report_only -timing_debug_report -expanded_views -report_dir reports/place -num_paths 1000 -report_prefix pre_opt_place
    exec gawk -f ./scripts/bin/slacks.awk reports/place/pre_opt_place_all.tarpt > reports/place/pre_opt_place_all.summary
    exec gawk -f ./scripts/bin/slacks.awk reports/place/pre_opt_place_reg2reg.tarpt > reports/place/pre_opt_place_reg2reg.summary
    exec gawk -f ./scripts/bin/slacks.awk reports/place/pre_opt_place_reg2cgate.tarpt > reports/place/pre_opt_place_reg2cgate.summary
    exec gawk -f ./scripts/bin/slacks.awk reports/place/pre_opt_place_in2reg.tarpt > reports/place/pre_opt_place_in2reg.summary
    exec gawk -f ./scripts/bin/slacks.awk reports/place/pre_opt_place_reg2out.tarpt > reports/place/pre_opt_place_reg2out.summary
    exec gawk -f ./scripts/bin/slacks.awk reports/place/pre_opt_place_in2out.tarpt > reports/place/pre_opt_place_in2out.summary
    exec gawk -f ./scripts/bin/slacks.awk reports/place/pre_opt_place_default.tarpt > reports/place/pre_opt_place_default.summary

#
#    be_report_timing_summary -max_paths 5000  -nworst 1  -out [get_db user_stage_reports_dir]/pre_opt_place.rpt    
#    foreach pg [get_db [get_path_groups] .name] { 
#        puts "-I- Report timing for group $pg"
#        be_report_timing_summary -max_paths 2000  -nworst 1  -group $pg -out [get_db user_stage_reports_dir]/pre_opt_place.rpt.$pg
#    }


    if {[get_db design_process_node] < 7 && $LEAKAGE_LEF_SIDE_FILES != "" && $LEAKAGE_CONFIG_FILE != "" && $LEAKAGE_CONFIG_FILE != "" && [llength [glob -nocomplain $LEAKAGE_LEF_SIDE_FILES $LEAKAGE_CONFIG_FILE $LEAKAGE_CONFIG_FILE]] > 0 } {
	    set cmd "cat [glob -nocomplain $LEAKAGE_LEF_SIDE_FILES $LEAKAGE_CONFIG_FILE ] > ./scripts_local/all_lib_side_file.txt"
	    eval exec $cmd
	    load_side_file -files [list $LEAKAGE_LEF_SIDE_FILES $LEAKAGE_LIB_SIDE_FILES $LEAKAGE_CONFIG_FILE] -dump_tcl_file ./scripts_local/lef_side_file.tcl
	    source ./scripts_local/lef_side_file.tcl
	    eval_legacy {set_power_analysis_mode -boundary_gate_leakage_file ./scripts_local/all_lib_side_file.txt -write_static_currents true -boundary_gate_leakage_report true  }
    }

    be_reports    -stage pre_opt_place -block $DESIGN_NAME -all
    be_sum_to_csv -stage pre_opt_place

    report_power -out_file reports/place/pre_opt_power.rpt
    user_report_inst_vt reports/place/pre_opt_threshold_instance_count.rpt
    
#    report_scan_chain -verbose > reports/$STAGE/${STAGE}_only_power.rpt
    
    report_metric -format html -file reports/place/pre_opt_${DESIGN_NAME}.html
    write_metric  -format csv  -file reports/place/pre_opt_${DESIGN_NAME}.csv
    check_place reports/place/pre_opt_check_place.rpt

}

#------------------------------------------------------------------------------
# pre opt extra setting 
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pre_place_opt_setting.tcl]} {
	puts "-I- running Extra setting from scripts_local/pre_place_opt_setting.tcl"
	check_script_location scripts_local/pre_place_opt_setting.tcl
	source -v ./scripts_local/pre_place_opt_setting.tcl
}

#------------------------------------------------------------------------------
#  opt design
#------------------------------------------------------------------------------
for {set i 0} {$i < $PLACE_OPT} {incr i} {
	set_db opt_new_inst_prefix "i_${STAGE}_opt_${i}_"
	set_db opt_new_net_prefix  "n_${STAGE}_opt_${i}_"
    eee_stage place_opt_$i "
	opt_design -incremental -expanded_views -report_dir reports/place/place_opt_${i}_design
	place_detail
	time_design -report_only -timing_debug_report -expanded_views -report_dir reports/place -num_paths 1000 -report_prefix place_opt_${i}_design
	write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}_opt_${i}.enc.dat
    "	
    be_reports    -stage place_opt_$i -block $DESIGN_NAME -all
    be_sum_to_csv -stage place_opt_$i     
}
#------------------------------------------------------------------------------
# pre opt extra setting 
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/post_place_opt_setting.tcl]} {
	puts "-I- running Extra setting from scripts_local/post_place_opt_setting.tcl"
	check_script_location scripts_local/post_place_opt_setting.tcl
	source -v ./scripts_local/post_place_opt_setting.tcl
}
#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.${STAGE}.def.gz
write_lef_abstract -5.8 \
	-top_layer $MAX_ROUTING_LAYER \
	-pg_pin_layers $MAX_ROUTING_LAYER \
	-stripe_pins \
	-property \
	out/lef/${DESIGN_NAME}.${STAGE}.lef

set default_setup_view [get_db [get_db analysis_views -if .is_active==true&&.is_setup_default] .name] 
set cmd "write_sdc -view $default_setup_view  ../inter/${DESIGN_NAME}.${STAGE}.sdc"
puts "-I- Running: $cmd"
eval $cmd

#------------------------------------------------------------------------------
# final LEC
#------------------------------------------------------------------------------
set cmd "-log_file log/lec.log -flat -revised_design [pwd]/out/db/${DESIGN_NAME}.${STAGE}.enc.dat/${DESIGN_NAME}.v.gz -checkpoint  out/verified.ckpt lec.place.do"
if {[get_db init_read_netlist_files] != "" && [llength [glob -nocomplain [get_db init_read_netlist_files]]] > 0 } {
	set cmd "-golden_design [get_db init_read_netlist_files] $cmd"
} else {
	set cmd "-golden_design $SYN_DIR/out/${DESIGN_NAME}.Syn.v.gz $cmd"
}
set cmd "write_do_lec $cmd"
echo $cmd
eval $cmd

#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
time_design -report_only -timing_debug_report -expanded_views -report_dir reports/place -num_paths 10000 -report_prefix place
if { [file exists reports/place/place_all.tarpt      ] } { exec gawk -f scripts/bin/slacks.awk reports/place/place_all.tarpt       > reports/place/place_all.summary }
if { [file exists reports/place/place_reg2reg.tarpt  ] } { exec gawk -f scripts/bin/slacks.awk reports/place/place_reg2reg.tarpt   > reports/place/place_reg2reg.summary}
if { [file exists reports/place/place_reg2cgate.tarpt] } { exec gawk -f scripts/bin/slacks.awk reports/place/place_reg2cgate.tarpt > reports/place/place_reg2cgate.summary}
if { [file exists reports/place/place_in2reg.tarpt   ] } { exec gawk -f scripts/bin/slacks.awk reports/place/place_in2reg.tarpt    > reports/place/place_in2reg.summary}
if { [file exists reports/place/place_reg2out.tarpt  ] } { exec gawk -f scripts/bin/slacks.awk reports/place/place_reg2out.tarpt   > reports/place/place_reg2out.summary}
if { [file exists reports/place/place_in2out.tarpt   ] } { exec gawk -f scripts/bin/slacks.awk reports/place/place_in2out.tarpt    > reports/place/place_in2out.summary}
if { [file exists reports/place/place_default.tarpt  ] } { exec gawk -f scripts/bin/slacks.awk reports/place/place_default.tarpt   > reports/place/place_default.summary}

#be_report_timing_summary -max_paths 5000  -nworst 1  -out [get_db user_stage_reports_dir]/place.rpt    
#foreach pg [get_db [get_path_groups] .name] { 
#    be_report_timing_summary -max_paths 2000  -nworst 1  -group $pg -out [get_db user_stage_reports_dir]/place.rpt.$pg
#}


check_place reports/place/check_place.rpt

report_area > reports/place/report_area.rpt

report_power -out_file reports/place/power.rpt
user_report_inst_vt reports/place/threshold_instance_count.rpt
# report_scan_chain -verbose > reports/$STAGE/${STAGE}_only_power.rpt

report_metric -format html -file reports/place/${DESIGN_NAME}.${STAGE}.html
write_metric  -format csv  -file reports/place/${DESIGN_NAME}.csv

set cmd "gui_create_floorplan_snapshot -dir reports/${STAGE}/snapshot -name ${DESIGN_NAME} -overwrite"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res }
set cmd "gui_write_flow_gifs -dir reports/${STAGE}/snapshot -prefix [get_db designs .name] -full_window"
if { [catch {eval $cmd} res] } { puts "-E- Error while running $cmd" ; puts $res } { gui_hide }

set end_t [clock seconds]
puts "-I- BE_STAGE: $STAGE - End running $STAGE at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
puts "-I- BE_STAGE: $STAGE - Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

be_reports    -stage $STAGE -block $DESIGN_NAME -all

#------------------------------------------------------------------------------
# Hierarchical flow
#------------------------------------------------------------------------------
if { ( [info exists CREATE_LIB] && $CREATE_LIB == "true" ) || ( [info exists CREATE_SPEF] && $CREATE_SPEF == "true" ) } {
   set start_t [clock seconds]
   extract_rc
   foreach rc_corner_ [get_db [get_db rc_corners -if ".is_active"] .name] {
	set cmd  "write_parasitics -rc_corner $rc_corner_ -spef_file out/spef/${DESIGN_NAME}.${STAGE}.${rc_corner_}.spef.gz"
	eee $cmd
   }
   set end_t [clock seconds]
   puts "-I- Elapse time for running write_parasitics is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
}


if {[info exists CREATE_LIB] && $CREATE_LIB == "true" } {
   set ANALYSIS_VIEWS [get_db [get_db analysis_views -if .is_active] .name]
   if {[regexp {setup|hold} $ANALYSIS_VIEWS]} {
   	set_analysis_view -setup $ANALYSIS_VIEWS -hold $ANALYSIS_VIEWS
   }
   foreach view_dpo [get_db [get_db analysis_views -if .is_active] .name] {
   	date
	write_timing_model -include_power_ground -view $view_dpo out/lib/${DESIGN_NAME}.${STAGE}.${view_dpo}.lib.gz -lib_name ${DESIGN_NAME}_${view_dpo}
   }
} 

if {[info exists CREATE_ILM] && $CREATE_ILM == "true" } {
	write_ilm -to_dir out/ilm/${STAGE} -overwrite  -model_type timing
}
#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
report_resource

be_sum_to_csv -stage $STAGE -mail -final
#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
}


if {![info exists BATCH] || $BATCH == "true"} {
	exit
}

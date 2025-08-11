#########################################################################################################################################################
#                                                                                               #
#     this script will run innovus ECO stage                                                                   #
#     variable received from shell are:                                                                      #
#          CPU           - number of CPU to run.8 per license                                                       #
#          BATCH            - run in batch mode                                                                 #
#          DESIGN_NAME      - name of top model                                                                 #
#          SCAN            - design with scan insertion                                                            #
#          OCV            - run CTS with OCV                                                                 #
#          ECO_NUM       - corrent ECo number                                                                 #
#          ECO_DO           - do eco option are : SEM,STA                                                            #
#          NUM_OF_FIXS      - loop SEM for NUM_OF_FIXS times                                                       #
#                                                                                               #
#                                                                                               #
#      Var     date of change     owner           comment                                                            #
#     ----     --------------     -------      ---------------------------------------------------------------                              #
#     0.1     27/01/2021     Royl     initial script                                                                 #
#     0.2     27/01/2021     Royl     option for Signal Em fix's                                                       #
#                                                                                               #
#                                                                                               #
#########################################################################################################################################################
set_db source_verbose false

if {![info exists NUM_OF_FIXS] } {set NUM_OF_FIXS 1}
set STAGE eco
set RUNNING_LOCAL_SCRIPTS [list]

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}

script_runtime_proc -start
check_script_location

if {![file exists reports/eco$ECO_NUM]} {exec mkdir -pv reports/eco$ECO_NUM}
#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
     puts "-I- reading setup file from scripts_local"
     source -v scripts_local/setup.tcl
} else {
     puts "-I- reading ${PROJECT}  setup file from scripts"
     source -v scripts/setup/setup.${PROJECT}.tcl
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
# define and read mmmc 
#------------------------------------------------------------------------------
source scripts/flow/mmmc_create.tcl
mmmc_create

#------------------------------------------------------------------------------
# load db base
#------------------------------------------------------------------------------
set PREV_ECO_NUM [expr $ECO_NUM -1]
if {$ECO_DO == "LOGIC_TCL"} {
    set cmd "read_mmmc { $mmmc_results }"
    eval $cmd

    #------------------------------------------------------------------------------
    # read lef and enable PLE-MODE
    #------------------------------------------------------------------------------
    read_physical -lef $LEF_FILE_LIST

    #------------------------------------------------------------------------------
    # read  design
    #------------------------------------------------------------------------------
    read_netlist -top $DESIGN_NAME $NETLIST_FILE

    init_design
} else {
    if {$ECO_NUM == 1} {
         puts "-I- read design from route db"
         set READ_DB out/db/${DESIGN_NAME}.route.enc.dat
#         read_db -lef_files $LEF_FILE_LIST -mmmc_file $mmmc_results  out/db/${DESIGN_NAME}.route.enc.dat
    } else {
         puts "-I- read design from eco$PREV_ECO_NUM db"
         set READ_DB out/db/${DESIGN_NAME}.eco${PREV_ECO_NUM}.enc.dat
#         read_db -lef_files $LEF_FILE_LIST -mmmc_file $mmmc_results  out/db/${DESIGN_NAME}.eco${PREV_ECO_NUM}.enc.dat
    }

    if {[info exists NEW_SDC] && $NEW_SDC == "true"} {
         puts "-I- read design from cts db"
         read_db -lef_files $LEF_FILE_LIST -mmmc_file $mmmc_results  $READ_DB
    } else {
         read_db $READ_DB
         set_analysis_view -setup $scenarios(setup) -hold $scenarios(hold) -dynamic $scenarios(dynamic) -leakage $scenarios(leakage)
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
set hook_script "./scripts_local/pre_eco_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

if {$ECO_DO == "SEM" } {
   while {$NUM_OF_FIXS > 0} {
        puts "-I- left $NUM_OF_FIXS iteration to fix Signal EM"
     #-----------------------------------------
     # Check AC Limits - 0
     #-----------------------------------------
     if {[get_db extract_rc_effort_level] == "high"} {
           if {[get_db design_process_node] < 7} {
            user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_5nm_modeling"
           } else {
            user_wait_license -required_features "Virtuoso_QRC_Extraction_XL QRC_Advanced_Analysis Advanced_sub_10nm_modeling"
           }
       }
     # need to run this so the Design Stage will be: PostRoute
     set_db extract_rc_engine post_route
#     time_design -post_route
     propagate_activity -set_net_freq true
     write_tcf scripts_local/activity.tcf
     read_activity_file -format TCF -write_net_freq true scripts_local/activity.tcf

     set_db check_ac_limit_ict_em_models $ICT_EM_MODELS
     set_db check_ac_limit_out_file reports/eco${ECO_NUM}/signal_em_${NUM_OF_FIXS}.rep
     check_ac_limits
     #-----------------------------------------
     # Fix AC Limits - 0
     #-----------------------------------------
     fix_ac_limit_violations \
          -use_report_file reports/eco${ECO_NUM}/signal_em_${NUM_OF_FIXS}.rep \
          -fix_nets_category clock_and_data \
          -fixing_method route_rule
          
     incr NUM_OF_FIXS -1

   }
} elseif {$ECO_DO == "STA" } {
     #before batch mode
    #cdns flag to use current instance: maybe need to set false after? check with Roy
    

    set_db timing_enable_get_ports_for_current_instance true 
    set_db eco_update_timing false 
    set_db eco_refine_place false
   #set_db eco_check_logical_equivalence true on default- set to false to insert inverters.
    set_db eco_check_logical_equivalence true

    set_db eco_honor_dont_use false
    #get_db add_fillers_eco_mode true,
    set_db eco_honor_dont_touch false ;#? make sure nets are not on dont touch.
    set_db eco_honor_fixed_status true ;#? for desired replacement of fixed insts.
    set_db place_detail_preserve_routing true 
    set_db place_detail_remove_affected_routing false 
    set_db place_detail_check_route false

    set_db [get_db insts -if ".place_status == fixed && .is_macro == false && .is_physical== false "] .place_status soft_fixed
    set_db [get_db insts -if ".place_status_cts == fixed && .is_macro == false && .is_physical== false "] .place_status_cts soft_fixed
    delete_obj [get_db groups ]

    #proc for get_net in PT output
#    proc get_net {of_flag net_pin} {
#         set t_hier [hk_get_common_hier_of_pins [get_pins -leaf -hierarchical ]]
#         get_nets -hier -of "pin:$t_hier/$net_pin"
#    }
    
    
#    proc be_get_current_instance {args} {
#         set ::BE_CURRENT_INST [lindex [lindex $args 0] 1]
#    }
#    trace add execution current_instance leave be_get_current_instance


    #needed on shell:
    set_interactive_constraint_modes func
    
    delete_filler
    delete_filler  -prefix DCAP

    set_db source_continue_on_error true
    set_db eco_batch_mode true
    if {[file exists scripts_local/sta_eco${ECO_NUM}.tcl]} {
        puts "-I- source scripts_local/sta_eco${ECO_NUM}.tcl"
        set cmd "eee {source -e -v scripts_local/sta_eco${ECO_NUM}.tcl}"
        eval $cmd
    } else {
    	puts "Error: missing eco scripts scripts_local/sta_eco${ECO_NUM}.tcl"
    }
    set_db source_continue_on_error false
    set_db eco_batch_mode false
    
    #delete proc and set batch mode false 
#    rename get_net ""
    #rename be_get_current_instance ""   ###delete proc

   
   
    set_db place_detail_eco_priority_insts eco
    set_db place_detail_eco_max_distance 15
    place_detail -eco true ;# delete fillers anyway!!!!!!!#########
    #place_eco
    

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
     set_db add_fillers_cells	$FILLERS_CELLS_LIST
     add_fillers -check_drc true



    
    set_db route_design_with_timing_driven false
    set_db route_design_with_eco true
    
#    route_design -clock_eco

    route_eco  -target ; 
    check_drc
    route_eco -fix_drc

} elseif {$ECO_DO == "LOGIC_TCL" } {
    if {[info exists ECO_SCRIPT] && [file exists $ECO_SCRIPT]} {
        set SCRIPT__ $ECO_SCRIPT 
    } elseif {[file exists out/eco${ECO_NUM}.tcl} {
        set SCRIPT__  out/eco${ECO_NUM}.tcl
    } else {
        puts "-E- missing script file for logic ECO"
	return
    }
    puts "-I- doing logic eco on netlist $NETLIST_FILE using script $SCRIPT__"
    
    catch  {exec  grep attachTerm $SCRIPT__ } ddd
    
    if {![regexp "child process" $ddd]} {
        set cmd "eval_legacy {source -e -v $SCRIPT__}" 
        eval $cmd
    } else {
        source -e -v $SCRIPT__
    }
} else {
     puts  "ERROR: No ECO was define"
}

#------------------------------------------------------------------------------
# post setting and operations 
#------------------------------------------------------------------------------
set hook_script "./scripts_local/post_eco_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
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
#add_tieoffs -matching_power_domains true

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}${ECO_NUM}.enc.dat
#write_netlist out/netlist/${DESIGN_NAME}.${STAGE}${ECO_NUM}.eeq.v.gz -use_eeq_cell_with_liberty_info
write_netlist out/netlist/${DESIGN_NAME}.${STAGE}${ECO_NUM}.v.gz

if {$ECO_DO != "LOGIC_TCL" } {
    write_def -routing     out/def/${DESIGN_NAME}.${STAGE}${ECO_NUM}.def.gz
    write_lef_abstract -5.8 \
     -top_layer $MAX_ROUTING_LAYER \
     -pg_pin_layers $MAX_ROUTING_LAYER \
     -stripe_pins \
     -property \
     out/lef/${DESIGN_NAME}.${STAGE}${ECO_NUM}.lef

#------------------------------------------------------------------------------
# reports
#------------------------------------------------------------------------------
    check_drc -limit 500000 -out_file reports/eco${ECO_NUM}/check_drc.rpt
    check_place reports/eco${ECO_NUM}/check_place.rpt

} ; #if {$ECO_DO != "LOGIC_TCL" }
#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
report_resource

be_sum_to_csv -stage $STAGE -mail -final
#------------------------------------------------------------------------------
# Mark stage is done
#------------------------------------------------------------------------------
exec touch .${STAGE}${ECO_NUM}_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true"} {
    return
}

if {![info exists BATCH] || $BATCH == "true"} {
     exit
}


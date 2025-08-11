#################################################################################################################################################
#                                                                                                                                               #
#    this script will run PrimeTime STA                                                                                                         #
#    variable received from shell are:                                                                                                          #
#        CPU          - number of CPU to run.8 per license                                                                                      #
#        HOSTS           - if distributed run, will run those hosts                                                                             #
#        DESIGN_NAME      - name of top model                                                                                                   #
#        PHYSICAL      - run in physical mode                                                                                                   #
#        OCV           - run with OCV                                                                                                           #
#        IO_CLOCK_LATENCY           - update virtual clock latency to common clock id                                                    #
#        VIEW           - the view to run on                                                                                                    #
#        PNR_DIR       - location of PNR directory for netlist/def database                                                             #
#        INTERACTIVE       - dont exit at end of script                                                                                         #
#        XTALK_SI       - run with si setting                                                                                                   #
#        STAGE           - stage of the design                                                                                                  #
#        RESTORE          - restore previous run                                                                                                #
#        NETLIST_FILE_LIST - netlist file list of the design                                                                                    #
#        SPEF_DIR       - location of SPEF dir                                                                                                  #
#        READ_SPEF       - read spef                                                                                                            #
#        CREATE_LIB       - create timing lib for block                                                                                         #
#        SPEF_FILE_LIST       - if variable is exists and point to a file, spef will be read from that file.                                    #
#                    else spef location is read from setup.tcl                                                                                  #
#                                                                                                                                               #
#                                                                                                                                               #
#     Var    date of change    owner         comment                                                                                            #
#    ----    --------------    -------     ---------------------------------------------------------------                                      #
#    0.1    24/02/2021    Royl    initial script                                                                                                #
#    0.2    08/06/2021    Royl    add option to create lib files                                                                                #
#    0.3    30/11/2021    Royl    add option restore previous run                                                                               #
#                                                                                                                                               #
#                                                                                                                                               #
#################################################################################################################################################

if {1} {
if {[info exists LABEL]}         {puts "LABEL $LABEL"} else {set LABEL "None" }
if {[info exists XTALK_SI]}         {puts "XTALK_SI $XTALK_SI"}
if {[info exists VCD_TYPE]}          {puts "VCD_TYPE $VCD_TYPE"}
if {[info exists POWER_REPORTS]}     {puts "POWER_REPORTS $POWER_REPORTS"}
if {[info exists CREATE_LIB_ONLY]}     {puts "CREATE_LIB_ONLY $CREATE_LIB_ONLY"}


if {[info exists TIMING_REPORTS]}     {
	puts "TIMING_REPORTS $TIMING_REPORTS"
} else {
	if {[info exists CREATE_LIB_ONLY] && $CREATE_LIB_ONLY == "true"} {
		set TIMING_REPORTS false
	} else {
		set TIMING_REPORTS true 
	}
	puts "TIMING_REPORTS $TIMING_REPORTS"
	
}
if {[info exists RH_OUT]}             {puts "RH_OUT $RH_OUT"}
if {[info exists READ_SPEF]}          {puts "READ_SPEF $READ_SPEF"}
if {[info exists IO_CLOCK_LATENCY]} {puts "IO_CLOCK_LATENCY $IO_CLOCK_LATENCY"}
if {[info exists VCD_FILE]}           {puts "VCD_FILE $VCD_FILE"}
if {[info exists HOSTS]}              {puts "HOSTS $HOSTS"}
if {[info exists ECO_NUMBER]}         {puts "ECO_NUMBER $ECO_NUMBER"}
if {[info exists PBA_MODE]}           {puts "PBA_MODE $PBA_MODE"}
if {[info exists VCD_BLOCK_PATH]}     {puts "VCD_BLOCK_PATH $VCD_BLOCK_PATH"}
if {[info exists VIEWS]}              {puts "VIEWS $VIEWS"}
if {[info exists STAGE]}              {puts "STAGE $STAGE"}
if {[info exists NETLIST_FILE_LIST]}  {puts "NETLIST_FILE_LIST $NETLIST_FILE_LIST"}
if {[info exists SPEF_DIR]}           {puts "SPEF_DIR $SPEF_DIR"}
if {[info exists CPU]}                {puts "CPU $CPU"}
if {[info exists ECO]}                {puts "ECO $ECO"}
if {[info exists GPD_FILE_LIST]}      {puts "GPD_FILE_LIST $GPD_FILE_LIST"} else {set GPD_FILE_LIST ""}
if {[info exists PHYSICAL]}           {puts "PHYSICAL $PHYSICAL"}
if {[info exists RESTORE]}            {puts "RESTORE $RESTORE"}
if {[info exists CREATE_LIB]}         {puts "CREATE_LIB $CREATE_LIB"}
if {[info exists POWER_REPORTS]}      {puts "POWER_REPORTS $POWER_REPORTS"}
if {[info exists TIMING_REPORTS]}     {puts "TIMING_REPORTS $TIMING_REPORTS"}
if {[info exists GPD_DIR]}            {puts "GPD_DIR $GPD_DIR"}
if {[info exists DESIGN_NAME]}        {puts "DESIGN_NAME $DESIGN_NAME"}
if {[info exists OCV]}                {puts "OCV $OCV"}
if {[info exists INTERACTIVE]}        {puts "INTERACTIVE $INTERACTIVE"}
if {[info exists READ_GPD]}           {puts "READ_GPD $READ_GPD"}
if {[info exists SPEF_FILE_LIST]}     {puts "SPEF_FILE_LIST $SPEF_FILE_LIST"} else {set SPEF_FILE_LIST "None"}
if {[info exists PNR_DIR]}        {puts "PNR_DIR $PNR_DIR"}
if {[info exists SDC_LIST]}           {puts "SDC_LIST $SDC_LIST"}
}

if {[file exists .pt_done]} {file delete  .pt_done}
if {![info exists STAGE]} {set STAGE chip_finish}
#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
#source scripts/procs/common/procs.tcl
source scripts/procs/source_be_scripts.tcl
script_runtime_proc -start
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}



set SPEF_DIR [sh realpath $SPEF_DIR]
set GPD_DIR [sh realpath $GPD_DIR]

if {$SPEF_FILE_LIST != "None" && $SPEF_FILE_LIST != "" }    {set SPEF_FILE_LIST [sh realpath $SPEF_FILE_LIST]}
if {$GPD_FILE_LIST  != "None" && $GPD_FILE_LIST  != "" }    {set GPD_FILE_LIST [sh realpath $GPD_FILE_LIST]}

if {![info exists REPORTS_DIR] || $REPORTS_DIR == "" } {set REPORTS_DIR reports}
if {![file exists $REPORTS_DIR    ]} {sh mkdir $REPORTS_DIR}
if {![file exists out/sdf    ]} {sh mkdir out/sdf}

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/setup.tcl]} {
    puts "-I- reading setup file from scripts_local"
    source -v ./scripts_local/setup.tcl
} elseif {[file exists $PNR_DIR/scripts_local/setup.tcl]} {
    puts "-I- reading setup file from $PNR_DIR/scripts_local"
    source -v $PNR_DIR/scripts_local/setup.tcl
} else {
    puts "-I- reading setup file from scripts"
    source -v ./scripts/setup/setup.${PROJECT}.tcl
}

if {[file exists ../inter/supplement_setup.tcl]} {
    puts "-I- reading supplement_setup file from ../inter "
    source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
    puts "-I- reading supplement_setup file from scripts_local"
    source -v scripts_local/supplement_setup.tcl
} elseif {[file exists $PNR_DIR/scripts_local/supplement_setup.tcl]} {
    puts "-I- reading supplement_setup file from $PNR_DIR/scripts_local"
    source -v $PNR_DIR/scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#if {[llength $VIEWS] == 1} {set mmmc_results ./scripts_local/mmmc_results_${VIEWS}.tcl}

#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/pt_variables.tcl]} {
    puts "-I- reading pt_variables file from scripts_local"
    source -v -e ./scripts_local/pt_variables.tcl
} else {
    puts "-I- reading pt_variables file from scripts"
    source -v -e ./scripts/flow/pt_variables.tcl
}

if {$pt_shell_mode == "primetime_master"} {
    puts "-I- prime time in master mode.\n-I- Hosts are $HOSTS"
    set NUMNER_OF_VIEWS [llength $VIEWS]
    set NUMNER_OF_VIEWS_PER_SERVER [expr max(1,$NUMNER_OF_VIEWS / [llength $HOSTS])]
    if {[llength $HOSTS] > 0 && $HOSTS == "localhost"} {
        set_host_options -num_processes $NUMNER_OF_VIEWS -max_cores $CPU
    } elseif {[llength $HOSTS] > 0 && $HOSTS == "nextk8s"} {
        set DESCRIPTION "[string tolower [lindex [split [pwd] "/"] end]]_slave"
        for {set i 0 } { $i <   $NUMNER_OF_VIEWS } { incr i} {
           set_host_options \
            -num_processes 1 \
            -max_cores $CPU \
            -protocol custom \
            -terminate_command "exit 0" \
            -submit_command  "$sh_launch_dir/scripts/bin/pt_nextk8s.csh -cpu $CPU -mem $MEMORY -pwd $sh_launch_dir -description ${DESCRIPTION}_$i -label $LABEL"
        }
    } elseif {[llength $HOSTS] > 0 && $HOSTS != "localhost"} {
        foreach host $HOSTS {
            set_host_options \
                -name "HOST_${host}" \
                -num_processes $NUMNER_OF_VIEWS_PER_SERVER \
                -max_cores $CPU \
                   -submit_command "/usr/bin/ssh" $host
                        
        }
    }
} else {
    puts "-I- prime time in single mode"
    set_host_options -max_cores $CPU
}


if {$pt_shell_mode == "primetime_master"} {
    foreach view $VIEWS {
        echo "creating scenario $view "
        set mode [lindex [split $view "_"] 0]
        set check [lindex [split $view "_"] end]
        regsub "${mode}_(.*)_${check}" $view {\1} sub_pvt
        regexp {(.*[SF])_(.*)} $sub_pvt match pvt rc
        if {[info exists RESTORE] && $RESTORE == "true" } {
        	if { [info exists SESSION] && $SESSION != "None" } {
                	create_scenario -name $view -image ${SESSION}/${DESIGN_NAME}/$view
		} else {
                	create_scenario -name $view -image session/${DESIGN_NAME}/$view
		}
        } else {
            set files {}
            foreach file $NETLIST_FILE_LIST {lappend files [sh realpath $file]}
            set NETLIST_FILE_LIST $files
            create_scenario -name $view \
                -specific_variables "PROJECT mode check rc pvt DESIGN_NAME SPEF_DIR GPD_DIR OCV STAGE PHYSICAL IO_CLOCK_LATENCY PNR_DIR SDC_LIST  NETLIST_FILE_LIST SPEF_FILE_LIST GPD_FILE_LIST READ_SPEF READ_GPD XTALK_SI PBA_MODE TIMING_REPORTS POWER_REPORTS CREATE_HS" \
                      -specific_data " scripts/flow/pt_read_design.tcl"
        }
    }
    start_hosts
    report_host_usage 
    current_session -all

} else {
    if { [llength $VIEWS] > 1 } {
        puts "-E- You are running in SINGLE mode with multiple VIEWS"
        puts "-E- Please only select ONE VIEW or run in DMSA"
        exit
    }
    if {[info exists RESTORE] && $RESTORE == "true" } {
        set PRE_RESTORE_ECO $ECO
        set PRE_INTERACTIVE $INTERACTIVE
        if { [info exists SESSION] && $SESSION != "None" } {
            restore_session $SESSION
        } else {
            restore_session session/${DESIGN_NAME}/$VIEWS
        }
        set RESTORE true
        set ECO $PRE_RESTORE_ECO
        set INTERACTIVE $PRE_INTERACTIVE
	source -e -v ./user_inputs.tcl 
	
    } else {
        echo "-I- NETLIST_FILE_LIST $NETLIST_FILE_LIST"
        
        set files {}
        foreach file $NETLIST_FILE_LIST {lappend files [sh realpath $file]}
        set NETLIST_FILE_LIST $files
        
        set mode [lindex [split $VIEWS "_"] 0]
        set check [lindex [split $VIEWS "_"] end]
        regsub "${mode}_(.*)_${check}" $VIEWS {\1} sub_pvt
        regexp {(.*[SF])_(.*)} $sub_pvt match pvt rc
        source -e -v scripts/flow/pt_read_design.tcl
    }
}

if {(![info exists RESTORE] || $RESTORE == "false") && $CREATE_LIB_ONLY == "false"} {

#------------------------------------------------------------------------------
#    Save_Session Section                                        
#------------------------------------------------------------------------------
    puts "-I- save session"
    if {$pt_shell_mode == "primetime_master"} {
        save_session session/${DESIGN_NAME}
    } else {
        if {![file exists session/${DESIGN_NAME}]} {sh mkdir session/${DESIGN_NAME}}
        save_session session/${DESIGN_NAME}/$VIEWS
    }
    
#------------------------------------------------------------------------------
# merge reports
#------------------------------------------------------------------------------
    if {$pt_shell_mode == "primetime_master" && (![info exists TIMING_REPORTS] || $TIMING_REPORTS == "true")} {
        puts "-I- creating merge reports"
        source -e -v scripts/flow/pt_report_design.tcl
    }


}    ; # if $RESTORE == "false"


#------------------------------------------------------------------------------
#    Additional reports
#------------------------------------------------------------------------------
if { [file exists $sh_launch_dir/scripts_local/additional_reports.tcl ] } {
    puts "-I- Running additional reports from $sh_launch_dir/scripts_local/additional_reports.tcl"
    source $sh_launch_dir/scripts_local/additional_reports.tcl
}

#------------------------------------------------------------------------------
# Power reports
#------------------------------------------------------------------------------
if {[info exists POWER_REPORTS] && $POWER_REPORTS == "true"} {

    if {[file exists scripts_local/activity_file.tcl]} { 
        puts "-I- sourcing activity file scripts_local/activity_file.tcl"
        source -e -v scripts_local/activity_file.tcl
    }
    if {[file exists scripts_local/pre_power_report.tcl]} { 
        puts "-I- sourcing activity file scripts_local/pre_power_report.tcl"
        source -e -v scripts_local/pre_power_report.tcl
    }
    if {[info exists VCD_FILE] && [file exists $VCD_FILE]} {
        if {[file exists $sh_launch_dir/scripts_local/set_rtl_to_gate_name.tcl]} {
            source -e -v $sh_launch_dir/scripts_local/set_rtl_to_gate_name.tcl
        }
	if {[info exists MAP_FILE] && [file exists $MAP_FILE]} {
		source -e -v $MAP_FILE
	}
        set cmd ""
        
        if {[info exists VCD_TYPE] && $VCD_TYPE == "rtl" } { set cmd  "$cmd -$VCD_TYPE" }
        if {[info exists VCD_BLOCK_PATH] && $VCD_BLOCK_PATH != "" } { set cmd "$cmd -strip_path $VCD_BLOCK_PATH" }
        
        set report_cmd "report_activity_file_check $cmd $VCD_FILE > $REPORTS_DIR/report_activity_file_check.rpt"
        echo $report_cmd
        eval $report_cmd
        
        set cmd ""
        if {[info exists VCD_TYPE] && $VCD_TYPE != "" && $VCD_TYPE != "None"} { set cmd  "$cmd -$VCD_TYPE" }
        if {[info exists VCD_BLOCK_PATH] && $VCD_BLOCK_PATH != "" && $VCD_BLOCK_PATH != "None"} { set cmd "$cmd -strip_path $VCD_BLOCK_PATH" }
        if {[info exists BLOCK_PATH] && $BLOCK_PATH != "" && $BLOCK_PATH != "None" } { set cmd "$cmd -path $BLOCK_PATH" }
	if {[info exists VCD_START] && [info exists VCD_END]  && ($VCD_START != "None" || $VCD_END != "None")} { set cmd "$cmd -time {$VCD_START $VCD_END}" }
        if {[regexp {\.fsdb$} $VCD_FILE]} {
            set read_cmd "read_fsdb $cmd $VCD_FILE"
    	} else {
            set read_cmd "read_vcd $cmd $VCD_FILE"
    	}
        echo $read_cmd
        eval $read_cmd
        
#        report_activity_file_check \
#            -rtl \
#            -strip_path mult_2_stage_tb/i_mult_2_stage_top \
#            /services/bespace/users/moriya/nxt012/nextflow_feb22_pn85/be_work/brcm5/nxt080/vcd/mult_2_stage/mult_2_stage_500MHz.vcd > $REPORTS_DIR/report_activity_file_check.rpt
#        read_vcd \
#            -strip_path  mult_2_stage_tb/i_mult_2_stage_top  \
#            -rtl \
#            /services/bespace/users/moriya/nxt012/nextflow_feb22_pn85/be_work/brcm5/nxt080/vcd/mult_2_stage/mult_2_stage_500MHz.vcd

        
        ## set power analysis options                                   
        set_power_analysis_options -waveform_format fsdb -waveform_output out/wave

    }
    
    if {$STAGE == "syn"} {
	foreach_in_collection ccc [get_clocks -filter "full_name !~ virtual* && !is_generated"] {
		set period [get_attribute $ccc period]
		set sources  [get_attribute $ccc sources]
		set input_pins [filter_collection [all_fanout -flat -from $sources ] "direction == in"]
		puts "-I- set_annotated_transition on clock [get_object_name $ccc] , period $period , source [get_object_name $sources]"
		set_annotated_transition [expr 0.12*$period] $input_pins
	}
	
	set_ideal_network [ all_fanout -clock_tree -flat ]

	update_timing
    }


    check_power   > $REPORTS_DIR/check_power.rpt
    update_power  

    ## report_power
    report_switching_activity -list_not_annotated  > $REPORTS_DIR/report_switching_activity_not_annotated.rpt
    report_switching_activity -list_annotated  > $REPORTS_DIR/report_switching_activity_annotated.rpt
    report_power -significant_digits 9  > $REPORTS_DIR/report_power.rpt
    report_power -significant_digits 9  -relative_toggle_rate  -net_power > $REPORTS_DIR/report_power_relative_toggle_rate.rpt
    report_power -significant_digits 9  -hierarchy -nosplit > $REPORTS_DIR/report_power_hierarchy.rpt
    report_clock_gate_savings > $REPORTS_DIR/report_clock_gate_savings.rpt
    report_clock_gate_savings -nosplit -sequential > $REPORTS_DIR/report_clock_gate_savings_sequential.rpt
    report_clock_gate_savings -nosplit -by_clock_gate  > $REPORTS_DIR/report_clock_gate_savings_by_clock_gate.rpt


    #------------------------------------------------------------------------------
    #    Save_Session Section                                        
    #------------------------------------------------------------------------------
    if {[file exists scripts_local/post_power_report.tcl]} { 
        puts "-I- sourcing activity file scripts_local/post_power_report.tcl"
        source -e -v scripts_local/post_power_report.tcl
    }
    
    if {[info exists SAVE_POWER] && $SAVE_POWER == "true" } {
        puts "-I- save session"
        if {$pt_shell_mode == "primetime_master"} {
            save_session session/${DESIGN_NAME}_POWER
        } else {
            if {![file exists session/${DESIGN_NAME}_POWER]} {sh mkdir session/${DESIGN_NAME}_POWER}
            save_session session/${DESIGN_NAME}_POWER/$VIEWS
        }
    }
}

#------------------------------------------------------------------------------
#    write RedHawk timing windows file                                         
#------------------------------------------------------------------------------
if {[info exists RH_OUT] && $RH_OUT == "true"} {
    puts "-I- creating redhawk timing windows file"
    set cmddb  "write_rh_file -filetype irdrop -output $sh_launch_dir/out/rhtf/\${DESIGN_NAME}_\${mode}_\${pvt}_\${rc}_\${check}.rh.timing.gz "    
    
    if {$pt_shell_mode == "primetime_master"} {
        set cmddb  "remote_execute { if {\[regexp \"125\" \$pvt\] && \[regexp \"rc_wc_cc_wc\" \$rc\] } {$cmddb} }"        
    } 
    echo $cmddb
    eval $cmddb
}

#------------------------------------------------------------------------------
#    fix eco timing                                        
#------------------------------------------------------------------------------
if {[info exists ECO] && $ECO == "true"} {
    puts "-I- do timing eco"
    source -e -v scripts/flow/pt_fix_eco.tcl
}

#------------------------------------------------------------------------------
#    save lib                                         
#------------------------------------------------------------------------------
if {([info exists CREATE_LIB] && $CREATE_LIB == "true") || $CREATE_LIB_ONLY == "true"} {
    puts "-I- creating libs and db"
    
    
    set cmddb  "extract_model -output $sh_launch_dir/out/lib/\${DESIGN_NAME}_\${mode}_\${pvt}_\${rc}_\${check} -library_cell -format {lib db}"    
    if {[info exists XTALK_SI] && $XTALK_SI == "true"} {
    	set cmddb "$cmddb -noise"
    }
    if {$pt_shell_mode == "primetime_master"} {
        set cmddb  "remote_execute { remove_case_analysis -all ; update_timing ; $cmddb }"        
    } else {
    	remove_case_analysis -all
	update_timing
    }
    echo $cmddb
    eval $cmddb
    
    sh gzip -f $sh_launch_dir/out/lib/*.lib

    
}

#------------------------------------------------------------------------------
#    write SDF                                         
#------------------------------------------------------------------------------
if {[info exists CREATE_SDF] && $CREATE_SDF == "true"} {
    puts "-I- creating SDF file"
    set cmdsdf  "write_sdf -no_internal_pins -include {SETUPHOLD RECREM} -no_derates $sh_launch_dir/out/sdf/\${DESIGN_NAME}_\${mode}_\${pvt}_\${rc}_\${check}.sdf "    
    
    if {$pt_shell_mode == "primetime_master"} {
        set cmdsdf  "remote_execute { ${cmdsdf} }"        
    } 
    echo $cmdsdf
    eval $cmdsdf
}

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
sh touch .pt_done

#------------------------------------------------------------------------------
# interactive 
#------------------------------------------------------------------------------
if {![info exists INTERACTIVE] || $INTERACTIVE == "false"} {
    exit
}






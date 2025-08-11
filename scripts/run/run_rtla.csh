#!/bin/tcsh -fe

source /tools/common/pkgs/modules/current/init/tcsh

#Flag                   Default         Description                                                                                                                               
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-k8s	                 false         'Run through k8s';\
#-desc	                 <>            'k8s pod name. 20 char limit . default is running dir name';\
#-memory	                 60            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
#-tail	                 false         'tail after create k8s pod';\
#-design_name             <>            'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
#-project                 <>            'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
#-nextinside              <>            'For \-BSS\-FE: REPO_ROOT\-BSE\-. For \-BSS\-BE: $BE_DEFAULT_NEXTINSIDE\-BSE\-.';\
#-cpu                     8            'Number of cpus per run. (default 16)';\
#-is_physical             false         'If true, run physical synthesis - \-BSS\-expects .def file\-BSE\- in ./  OR ../inter/ OR using -def';\
#-scan                    false         'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Run insert_dft and scan-related processes';\
#-scan_ff                 true          'insert scan FF or none scan FF';\
#-ocv                     flat          'Run in ocv mode options: none / flat / socv ';\
#-mbit                    false         'Run with multibit';\
#-lpg                     true          'insert low power clock gating cells';\
#-retime                  true          'Uses  the  adaptive  retiming  algorithm  during optimization to improve delay.';\
#-zwlm                    true          'run with zero interconnect delay mode.';\
#-no_autoungroup          false         'Specifies that automatic ungrouping is completely disabled.';\
#-no_boundary_opt         false         'Specifies that no hierarchical boundary optimization is to be performed.';\
#-vt_effort               low           'high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL';\
#-power_effort            none          'none - Disables power optimization.  low - Performs a low-effort power optimization with minimum trade-off. high - Performs the best power optimization with a higher trade-off';\
#-flat_design             <>            'Flat design before specific stage. Options are false , syn_opt , save_design . \-BSS\-BE Default is syn_opt. FE Default is false\-BSE\-';\
#-compile_incr            0             'extra compile increment . 0 means None.';\
#-interactive             false         'Do not exit when done';\
#-fe_mode                 false         'Do not run BE related stuff. Faster syn for FE';\
#-create_lib              true         'Create lib for hierarchical flow - Adds runtime';\
#-create_spef             false         'Create spef for hierarchical flow - Adds runtime';\
#-remove_flops            true          'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Remove constant and unloaded flops';\
#-error_on_blackbox       true          'If false, ignores error on blackbox on elaborate. Default: \-BSS\-true \-BSE\-';\
#-sdc_list                <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
#-def_file                <>            '.def file or .def.gz file. \-BSS\-Default is ./DESIGN_NAME.def  OR ../inter/DESIGN_NAME.def\-BSE\-';\
#-filelist                <>            'Private filelist file';\
#-be_partitions           <>            'List of modules to be synthesized as libs/ILM models/blackbox';\
#-search_path             <>            'Path to a REPO_ROOT area that contains lib/ILM files under its target/syn_regressions dir';\
#-stop_after              final         'Defaults: finish run. Stop after this stage - elaborate/syn_gen/syn_map';\
#-detailed_timing         true/false    'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Print detailed timing reports';\
#-check_design_waivers    <>            'FE use - waivers file for check_design';\
#-check_timing_waivers    <>            'FE use - waivers file for check_design';\
#-report_fi_fo_size       true          'syn_reg only - Report size of FI FO from/to interface';\
#-report_logic_levels     true          'syn_reg only - Report logic levels number on interface and internal';\
#-open                    <>            'Stage to open syn_gen, syn_map, syn_opt OR Syn';\
#-saif_file               <>            'load SAIF file ';\
#-saif_inst_name          <>            'When loading SAIF activity file - specify the instance path of the design top';\
#-other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool. \-BSS\- Must be within /appost/ YOUR STRING /appost/ \-BSE\-';\
#-brcm                    true          'run BRCM script';\
#-user_inputs             false         'read same user inputs as last run. need to define k8s flags again.';\
#-local                   false         'If true run do_ file from scripts_local folder';\
#-scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
#-help                    false         'Prints help for the relevant tool' ;\

#setenv SNPS_ENABLE_TESTCASE
setenv SNPSLMD_QUEUE true
setenv SNPS_MAX_QUEUETIME  18000
#-----------------------------------
# Parsing flags
#-----------------------------------
source ./scripts/bin/parse_args.csh rtla $argv 

if ( $is_exit  == "true" ) then
    exit
endif


#-----------------------------------
# nextk8s run 
#-----------------------------------
echo "k8s: $k8s"
if ($k8s == "true" ) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh rtla $argv 
   exit 0
endif


#-----------------------------------
# shell command 
#-----------------------------------


#-----------------------------------
# Load modules 
#-----------------------------------
module unload snps/rtla
echo "tool_version $tool_version"
if ($tool_version != "None") then
    if (`(module avail snps/rtla/$tool_version) | &grep $tool_version | wc -l` > 0 ) then
        echo "Info: RTLA version $tool_version"
	module load snps/rtla/$tool_version
    else 
        echo "Info: RTLA version V-2023.12-SP5-2"
        module load snps/rtla/V-2023.12-SP5-2
    endif
else
    module load snps/rtla/V-2023.12-SP5-2
endif



#-----------------------------------
# mkdir
#-----------------------------------

mkdir -pv log out reports/init reports scripts_local reports/dft log/prev  log/prev_tmp reports/prev_tmp WORK
mkdir -pv sourced_scripts

set STAGES = "$stages"


####################################################################################################################################
##   stages scripts
####################################################################################################################################
if ($?local && `echo $local | egrep "true|init" | wc -l`) then
    set INIT_SCRIPT = "./scripts_local/do_rtla_init.tcl"
else
    set INIT_SCRIPT = "./scripts/do_rtla_init.tcl"
endif
if ($?local && `echo $local | egrep "true|syn" | wc -l`) then
    set SYN_SCRIPT = "./scripts_local/do_rtla_syn.tcl"
else
    set SYN_SCRIPT = "./scripts/do_rtla_syn.tcl"
endif

####################################################################################################################################
##   shell arguments
####################################################################################################################################
set STAGE_TO_OPEN = $open
if ( $STAGE_TO_OPEN != "None" ) then
    set STAGES = "open"
    set force  = "true"
    echo "set STAGE_TO_OPEN $open" >> .tmp_user_inputs.tcl
    echo "set STAGE $open      \n" >> .tmp_user_inputs.tcl  
 \cp -p .tmp_user_inputs.tcl open_user_inputs.tcl
else 
   if ($user_inputs == "false") then
 \cp -p .tmp_user_inputs.tcl user_inputs.tcl
   else
      echo "using existing user input file"
   endif
endif

\rm .tmp_user_inputs.tcl


####################################################################################################################################
##   execute stages 
####################################################################################################################################
foreach STAGE (`echo $STAGES`)
    echo "-I- Running $STAGE"
    set log_file = log/${STAGE}.log
    # Remove old done stage
    if ( -e .${STAGE}_done ) then
        \rm .${STAGE}_done
    endif
#    if ( $force == "false" ) then 
#        if ($STAGE != "init") then
#        # Check of previous stage is done
#    	    if ( ! -e .${previous_stage}_done ) then
#    		echo "-E- No .${previous_stage}_done found. Make sure $previous_stage is done, or use -force to overide this check"
#    		echo "-E- No .${previous_stage}_done found. Make sure $previous_stage is done, or use -force to overide this check" > $log_file
#    		exit 1
#    	    endif
#    	endif
#    endif
#    set previous_stage = $STAGE
    
    if ($STAGE == "open") then
       set log_file = `whoami`_`date +%F.%T`
      rtl_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./open_user_inputs.tcl ; \
                " \
	    -f $OPEN_SCRIPT | tee -i log/open_${log_file}.log
    
    else if ($STAGE == "init") then
       cp -pf $INIT_SCRIPT sourced_scripts/.
    
        rtl_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./user_inputs.tcl ; \
                " \
	    -f ./sourced_scripts/do_rtla_init.tcl | tee -i log/do_rtla_${STAGE}.log.full
    
    else if ($STAGE == "syn") then
        cp -pf $SYN_SCRIPT sourced_scripts/.
        rtl_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./user_inputs.tcl ; \
                " \
	    -f ./sourced_scripts/do_rtla_syn.tcl | tee -i log/do_rtla_${STAGE}.log.full
    endif
    if ( -e .${STAGE}_done ) then
        echo "-I- $STAGE done with normal exit"
    else
        echo "-E- $STAGE done with abnormal exit"
        exit 1
    endif


    if ( `echo $HOST| egrep "nextk8s|argo" | wc -l` > 0) then
        echo "k8s: $k8s"
        source ./scripts/bin/k8s_launcher.csh profiler_update $STAGE
    endif
    echo "INFO: end stage $STAGE from stages $STAGES"
end
echo "INFO: normal exit"
exit 0
    
    
    
    
    

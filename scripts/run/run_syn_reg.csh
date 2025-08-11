#!/bin/csh

#Flag                   Default         Description                                                                                                                                            
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-k8s                   false           Run through k8s                                                                                                                                        
#-desc                  <>              k8s pod name. 20 char limit . default is running dir name                                                                                              
#-memory                60              nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB                                    
#-version               genus/201       Tool version. Default is 20.11.  Recommended 21.X version is: genus/211/21.15-e056_1                                                   
#-user_input            false           read same user inputs as last run. need to define k8s flags again.                                                                                     
#-design_name           <>              Default - nextflow/be_work/project_name/ block_name                                                                                    
#-project               <>              Default - nextflow/be_work/ project_name /block_name                                                                                   
#-nextinside            <>              For  FE: REPO_ROOT . For  BE: /project/inext/inext_hw_fe_model_releases/inext_hw_fe_grid_cloning_prio1_20220909_0813 . 
#-cpu                   16              Number of cpus per run. (default 16)                                                                                                                   
#-is_physical           false           If true, run physical synthesis -  expects .def file  in ./ OR ../inter/ OR using -def                                                 
#-is_hybrid             false           If true, run physical syn_gen and syn_map, but NOT physical syn_opt.  expects .def file  in ./ OR ../inter/ OR using -def              
#-useful_skew           false           if true will do useful skew for physical run                                                                                                           
#-scan                  false           Defaults:  BE - true. FE - false . Run insert_dft and scan-related processes                                                           
#-ocv                   false           Run in ocv mode                                                                                                                                        
#-mbit                  false           Run with multibit                                                                                                                                      
#-lpg                   true            insert low power clock gating cells                                                                                                                    
#-vt_effort             low             high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL                                                                       
#-flat_design           <>              Flat design before specific stage. Options are false, syn_opt, save_design.  BE Default is syn_opt. FE Default is false                
#-interactive           false           Do not exit when done                                                                                                                                  
#-fe_mode               false           Do not run BE related stuff. Faster syn for FE                                                                                                         
#-create_lib            false           Create lib for hierarchical flow - Adds runtime                                                                                                        
#-remove_flops          true            Defaults:  BE - true. FE - false . Remove constant and unloaded flops                                                                  
#-error_on_blackbox     true            If false, ignores error on blackbox on elaborate. Default:  true                                                                       
#-sdc_list              <>              Comma seperated list of .sdc files. Will be sourced in order.  Default is ./DESIGN_NAME.sdc OR ../inter/.sdc                           
#-def_file              <>              .def file or .def.gz file.  Default is ./DESIGN_NAME.def OR ../inter/DESIGN_NAME.def                                                   
#-filelist              <>              Private filelist file                                                                                                                                  
#-stop_after            final/syn_gen   Defaults:  BE - finish run. FE - syn_gen . Stop after this stage - syn_gen/syn_map                                                     
#-detailed_timing       true/false      Defaults:  BE - true. FE - false . Print detailed timing reports                                                                       
#-check_design_waivers  <>              FE use - waivers file for check_design                                                                                                                 
#-check_timing_waivers  <>              FE use - waivers file for check_design                                                                                                                 
#-report_fi_fo_size     true            syn_reg only - Report size of FI FO from/to interface                                                                                                  
#-report_logic_levels   true            syn_reg only - Report logic levels number on interface and internal                                                                                    
#-open                  <>              Stage to open syn_gen, syn_map, syn_opt OR Syn                                                                                                         
#-other_args            <>              Other arguments as a string. This string will be sourced as is in the tool.   Must be within ' YOUR STRING '                           





#-----------------------------------
# FE Root / BE Root
#-----------------------------------
if ( "$?REPO_ROOT" == 0 ) then
    setenv BEROOT   `git rev-parse --show-toplevel` ; # <This is where your "nextflow" folder is>
#    set nextinside = /project/nxt008/nextinside_model_releases/nextinside_bravo_20210119_bravo_fn1    
else
    setenv BEROOT   $REPO_ROOT/submodules/nextflow ; # <This is where your "nextflow" folder is>
endif 


#-----------------------------------
# Parsing flags
#-----------------------------------
source $BEROOT/ns_flow/scripts/bin/parse_args.csh genus $argv 

if ( $is_exit  == "true" ) then
    exit 2
endif

mv .tmp_user_inputs.tcl user_inputs.tcl

#-----------------------------------
# Load modules 
#-----------------------------------
echo "-I- Loading module $version"
set inn_version = `echo $version | tr "/" " " | awk '{print $2}'`
module clear -f
module unload genus innovus
module load $version innovus/$inn_version


#-----------------------------------
# mkdir
#-----------------------------------
echo "-I- Creating directories"
mkdir -pv log out reports scripts_local out/spef reports/dft log/prev reports/prev log/prev_tmp reports/prev_tmp

echo "-I- Removing previous log"
\rm -rf log/*

if ( -e .syn_done || -e .syn_outputs_done || -e .syn_netlist_done) then
	\rm .syn*_done
endif

#-----------------------------------
# Run
#-----------------------------------

setenv PROJECT  $project
setenv SYN4RTL  $fe_mode

if ( "$stop_after" == "syn_opt" ) then
  set do_file  = `realpath ./scripts/do_genusSyn.tcl`
else
  set do_file  = `realpath ./scripts/do_synReg.tcl`
endif
set log_file = `realpath ./log/do_synReg.log`

echo "-I- Run Genus"
genus \
	-execute " \
    source -e -v ./user_inputs.tcl ; \
    set GENERATE_MAPPED_NETLIST false \
    set ALLOW_BLACK_BOX false \
    set RUN_TIMING_REPORTS false \
    set DONT_CHECK_CONSTANT_0_1 false \
	" \
	-f $do_file \
	-log $log_file | tee -a ${log_file}.full

if ( -e .syn_done ) then
	echo "-I- Syn done with normal exit"
    ./scripts/bin/logscan.tcl $log_file
	echo "-I- logscan done. Exit with exit code 0"    
	exit 0
else
	echo "-E- Syn done with abnormal exit"
    ./scripts/bin/logscan.tcl $log_file
	echo "-I- logscan done. Exit with exit code 1"    
	exit 1
endif


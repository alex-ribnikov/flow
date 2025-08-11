#!/bin/tcsh -fe

source /tools/common/pkgs/modules/current/init/tcsh


#Flag                   Default         Description                                                                                                                                            
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# -k8s	                 false         'Run through k8s';\
# -desc	                 <>            'k8s pod name. 20 char limit . default is running dir name';\
# -memory	                 60            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
# -tail	                 false         'tail after create k8s pod';\
# -design_name             <>            'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
# -project                 <>            'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
# -nextinside              <>            'For \-BSS\-FE: REPO_ROOT\-BSE\-. For \-BSS\-BE: $BE_DEFAULT_NEXTINSIDE\-BSE\-.';\
# -cpu                     16            'Number of cpus per run. (default 16)';\
# -is_physical             false         'If true, run physical synthesis - \-BSS\-expects .def file\-BSE\- in ./  OR ../inter/ OR using -def';\
# -is_hybrid               false         'If true, run physical syn_gen and syn_map, but NOT physical syn_opt. \-BSS\-expects .def file\-BSE\- in ./  OR ../inter/ OR using -def';\
# -useful_skew             false         'if true will do useful skew for physical run';\
# -scan                    false         'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Run insert_dft and scan-related processes';\
# -ocv                     flat          'Run in ocv mode options: none / flat / socv ';\
# -mbit                    false         'Run with multibit';\
# -wlm                     false         'run with wireload model.option are false , W1600 , W3600';\
# -lpg                     true          'insert low power clock gating cells';\
# -no_autoungroup          false         'Specifies that automatic ungrouping is completely disabled.';\
# -vt_effort               low           'high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL';\
# -power_effort            none          'none - Disables power optimization.  low - Performs a low-effort power optimization with minimum trade-off. high - Performs the best power optimization with a higher trade-off';\
# -flat_design             <>            'Flat design before specific stage. Options are false, syn_opt, save_design. \-BSS\-BE Default is syn_opt. FE Default is false\-BSE\-';\
# -interactive             false         'Do not exit when done';\
# -fe_mode                 false         'Do not run BE related stuff. Faster syn for FE';\
# -create_lib              false/true    'Create lib for hierarchical flow - Adds runtime';\
# -remove_flops            true          'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Remove constant and unloaded flops';\
# -error_on_blackbox       true          'If false, ignores error on blackbox on elaborate. Default: \-BSS\-true \-BSE\-';\
# -sdc_list                <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
# -def_file                <>            '.def file or .def.gz file. \-BSS\-Default is ./DESIGN_NAME.def  OR ../inter/DESIGN_NAME.def\-BSE\-';\
# -filelist                <>            'Private filelist file';\
# -be_partitions           <>            'List of modules to be synthesized as libs/ILM models/blackbox';\
# -search_path             <>            'Path to a REPO_ROOT area that contains lib/ILM files under its target/syn_regressions dir';\
# -stop_after              final         'Defaults: finish run. Stop after this stage - elaborate/syn_gen/syn_map/final';\
# -detailed_timing         true/false    'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Print detailed timing reports';\
# -check_design_waivers    <>            'FE use - waivers file for check_design';\
# -check_timing_waivers    <>            'FE use - waivers file for check_design';\
# -report_fi_fo_size       true          'syn_reg only - Report size of FI FO from/to interface';\
# -report_logic_levels     true          'syn_reg only - Report logic levels number on interface and internal';\
# -open                    <>            'Stage to open syn_gen, syn_map, syn_opt OR Syn';\
# -other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool. \-BSS\- Must be within /appost/ YOUR STRING /appost/ \-BSE\-';\
# -user_inputs              false         'read same user inputs as last run. need to define k8s flags again.';\
# -local                   false         'If true run do_ file from scripts_local folder';\
# -scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
# -help                    false         'Prints help for the relevant tool' ;\




#-----------------------------------
# FE Root / BE Root
#-----------------------------------
if ( "$?REPO_ROOT" == 0 ) then
#     echo "REPO_ROOT is : $REPO_ROOT"
#    setenv BEROOT   `git rev-parse --show-toplevel` ; # <This is where your "nextflow" folder is>
#    set nextinside = /project/nxt008/nextinside_model_releases/nextinside_bravo_20210119_bravo_fn1    
else
     echo "No REPO_ROOT"
#    setenv BEROOT   $REPO_ROOT/submodules/nextflow ; # <This is where your "nextflow" folder is>
endif 


#-----------------------------------
# Parsing flags
#-----------------------------------
source ./scripts/bin/parse_args.csh genus $argv 

if ( $is_exit  == "true" ) then
    exit
endif

####################################################################################################################################
##   stages scripts
####################################################################################################################################


if ( $?local && $local == "true" ) then
    # Run from local do file
    set do_scripts = ./scripts_local/do_genusSyn.tcl
else
    # Run from central do file
    set do_scripts = ./scripts/do_genusSyn.tcl
endif

#-----------------------------------
# nextk8s run 
#-----------------------------------
echo "k8s: $k8s"
if ($k8s == "true" ) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh genus $argv 
   exit 0
endif




###
###if ($k8s == "true" ) then
###   set PROFILER = "NONE"
###   set stage = "syn"
###   if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###   if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###   if ($PROFILER != "NONE") then
###      if (`grep syn $PROFILER | wc -l` == 0) then
###          echo "Warning: missing syn stage for k8s_profiler. adding default values cpu $cpu , memory $memory"
###          echo "syn $cpu $memory" >> $PROFILER
###      endif
###      echo "k8s profiler: $PROFILER"
###      set memory = `cat $PROFILER | perl -pe 's/#.*//' | grep $stage | awk '{print $NF}'`
###      set cpu = `cat $PROFILER | perl -pe 's/#.*//' | grep $stage | awk '{print $(NF-1)}'`
###      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###   else
###      if ( -d ../inter ) then
###          echo "Warning: missing syn stage for k8s_profiler. adding default values cpu $cpu , memory $memory"
###          echo "syn $cpu $memory" >> ../inter/k8s_profiler
###      endif
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###   endif
###   set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`
###   echo "K8S_CPU $K8S_CPU limit $cpu"
###   echo "K8S_MEM $K8S_MEM limit $K8S_MEM_LIMIT"
###
###
###   set AAA = `echo $argv | perl -pe 's/-k8s//;s/-desc \S+//;s/-tail//;s/-vnc_server \S+//;s/-vnc_display \S+//;s/-win//;'`
###   set AAA = "$AAA -k8s false"
###   if ($desc == "None") then
###      set desc = `echo $PWD | awk -F'/' '{print $NF}' | cut -c1-20 | tr "[:upper:]" "[:lower:]"`
###   else
###      set desc = `echo $desc | tr "[:upper:]" "[:lower:]"`
###   endif
###   echo "k8s:  $k8s"
###   echo "desc: $desc"
###   echo "argv: $argv"
###   echo "AAA:  $AAA"
###      
###   set COMMAND = "./scripts/run/run_genus.csh $AAA"
###   echo $COMMAND
###   if ($open != "None" || $interactive == "true" || $win == "true") then
###       if ($vnc_display == "None" || $vnc_server == "None") then
###           echo "ERROR: missing vnc_display or vnc_server"
###	   exit 1
###       endif
###       if ( $?NXT080) then
###           if ( $NXT080 == "true") then
###               set terminal = "setenv NXT080 true && $terminal"
###           endif
###       endif
###       set cmd = "nextk8s run -command '$terminal -e "\""$COMMAND"\""' -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc $desc -memory $K8S_MEM -memory-limit $K8S_MEM_LIMIT -x-display-num $vnc_display -vnc-server $vnc_server"
###   else
###       set cmd = "nextk8s run -command '$COMMAND' -x-server -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc $desc -memory $K8S_MEM -memory-limit $K8S_MEM_LIMIT"
###       if ($tail == "true") then
###          set cmd = "$cmd -tail"
###       endif
###   endif
###   
###   
###   echo $cmd
###   eval $cmd
###   exit
###endif

#-----------------------------------
# Load modules 
#-----------------------------------
module unload cdnc/innovus cdnc/genus
if ($tool_version != "None") then
    if (`(module avail cdnc/innovus/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: innovus version $tool_version"
	module load cdnc/innovus/$tool_version
    else 
        echo "Info: innovus version 23.32.000"
        module load cdnc/innovus/23.32.000
    endif
    if (`(module avail cdnc/genus/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: genus version $tool_version"
	module load cdnc/genus/$tool_version
    else 
        echo "Info: genus version 23.32.000"
        module load cdnc/genus/23.32.000
    endif
else
    module load cdnc/innovus/23.32.000 cdnc/genus/23.32.000 
endif


#-----------------------------------
# mkdir
#-----------------------------------

if ( $open != "None" ) then

    set force  = "true"
    echo "set STAGE_TO_OPEN $open" >> .tmp_user_inputs.tcl

    set log_file = `date +%F.%T`
    
    setenv PROJECT  $project
    setenv SYN4RTL  $fe_mode
    
    mv .tmp_user_inputs.tcl open_user_inputs.tcl
    
    genus \
	    -execute " \
    #	WA: $WA_PATH \
        source -e -v ./open_user_inputs.tcl ; \
	    " \
	    -f ./scripts/do_openblock.tcl \
	    -log log/open_${log_file}.log | tee -a log/open_${log_file}.log.full
    
    exit [0]
    
endif

#-----------------------------------
# mkdir
#-----------------------------------

mkdir -pv log out reports scripts_local out/spef reports/dft log/prev reports/prev log/prev_tmp reports/prev_tmp
\rm -rf log/*

if ( -e .syn_done || -e .syn_outputs_done || -e .syn_netlist_done) then
	\rm .syn*_done
endif

#-----------------------------------
# Run
#-----------------------------------

setenv PROJECT  $project
setenv SYN4RTL  $fe_mode

if ($user_inputs == "false") then
   mv .tmp_user_inputs.tcl user_inputs.tcl
endif


genus \
       -wait 18000 \
       -execute " \
#      WA: $WA_PATH \
    source -e -v ./user_inputs.tcl ; \
       " \
       -f $do_scripts \
       -log log/do_syn.log | tee -a log/do_syn.log.full

####################################################################################################################################
##   calculate memory usage and update k8s_profiler + 20%
####################################################################################################################################
if ( `echo $HOST| grep nextk8s | wc -l` > 0) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh profiler_update syn
endif


###if ( `echo $HOST| grep nextk8s | wc -l` > 0) then
###   set MEM_USAGE = `curl -s -g https://prometheus.k8s.nextsilicon.com/api/v1/query --data-urlencode 'query=max_over_time(container_memory_working_set_bytes{pod="'$HOST'",container="hw-ldap"}[14d])' | jq '.data.result[].value[1]' | perl -pe 's/"//g' | awk '{print $1/1024.0/1024.0/1024.0}'`
###   if ( $MEM_USAGE == "") then
###   	echo "MEM USAGE unavailable for pod $HOST from containeer hw-ldap"
###   else
###       set MEM_USAGE_20 = `echo $MEM_USAGE | awk '{print $1*1.2}'`
###       set PROFILER = "NONE"
###       if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###       if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###       if ($PROFILER != "NONE") then
###           \cp $PROFILER ${PROFILER}.syn_old
###           echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in k8s profiler $PROFILER to $MEM_USAGE_20   (usage + 20%)"
###           set cmd = 'perl -p -i -e '\''s/(syn \d+) \d+/$1 '$MEM_USAGE_20'/'\'' '$PROFILER
###
###           echo $cmd
###           eval $cmd
###       else
###           if ( -d ../inter) then
###               echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in ../inter/k8s_profiler to $MEM_USAGE_20   (usage + 20%)"
###               echo "syn $cpu $MEM_USAGE_20" >> ../inter/k8s_profiler
###           else
###               echo "WARNING: memory usage for run is $MEM_USAGE .  update memory usage in ./scripts_local/k8s_profiler to $MEM_USAGE_20   (usage + 20%)"
###               echo "syn $cpu $MEM_USAGE_20" >> ./scripts_local/k8s_profiler
###           endif
###       endif
###   endif
###endif


if ($create_lib == "true" && -e .syn_done) then
    module unload genus innovus
    module load genus/211 innovus/211
    
#    perl -p -i -e 's/set PROJECT \S+/set PROJECT nxt080/' ./user_inputs.tcl

    # remove SDC LIST from user inputs and use genus output.
    perl -p -i -e 's/set SDC_LIST \S+//' ./user_inputs.tcl
    
    genus \
        -wait 18000 \
        -execute "source -e -v ./user_inputs.tcl" \
	-f ./scripts/do_genus_create_lib.tcl \
	-log log/do_genus_create_lib.log | tee -a log/do_genus_create_lib.log.full

#    perl -p -i -e 's/set PROJECT \S+/set PROJECT nextcore/' ./user_inputs.tcl
#    genus \
#        -wait 18000 \
#        -execute "source -e -v ./user_inputs.tcl" \
#	-f ./scripts/do_genus_create_lib.tcl \
#	-log log/do_genus_create_lib.log | tee -a log/do_genus_create_lib_nextcore.log.full

    
    setenv SNPSLMD_QUEUE true
    setenv SNPS_MAX_QUEUETIME  18000
    module load snps/fusioncompiler/S-2021.06-SP1
    /tools/snps/lc/S-2021.06-SP5/bin/lc_shell -x '\
    	source -e -v ./user_inputs.tcl ; \
	set lib_files [glob out/${DESIGN_NAME}*.lib] ; \
	foreach lib $lib_files { \
	  regexp {out/(.*)\.lib} $lib match lib_file_name ; \
	  read_lib $lib ;\
	  set lib_name [get_object_name [get_libs]] ; \
	  write_lib -output out/${lib_file_name}.db $lib_name  ; \
	} ; \
	exit '   | tee -a log/do_lc.log.full


endif

set log_file = log/do_syn.log

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


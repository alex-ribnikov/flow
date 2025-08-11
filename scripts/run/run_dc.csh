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
source ./scripts/bin/parse_args.csh dc $argv 

if ( $is_exit  == "true" ) then
    exit
endif


#-----------------------------------
# nextk8s run 
#-----------------------------------
echo "k8s: $k8s"
if ($k8s == "true" ) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh dc $argv 
   exit 0
endif



###set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`
###
###if ($k8s == "true" ) then
###   set stage = "syn"
###   set PROFILER = "NONE"
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
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`
###   else
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`
###   endif
###   echo "K8S_CPU $K8S_CPU limit $cpu"
###   echo "K8S_MEM $K8S_MEM limit $K8S_MEM_LIMIT"
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
###   set COMMAND = "./scripts/run/run_dc.csh $AAA"
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
###   echo $cmd
###   eval $cmd
###   exit
###endif

#-----------------------------------
# shell command 
#-----------------------------------


if ( $is_physical  == "true" ) then
	set DC_SHELL = "dcnxt_shell"
	set DC_TOPO = "-topographical_mode"
else
#	set DC_SHELL = "dc_shell"
	set DC_SHELL = "dcnxt_shell"
	set DC_TOPO = ""

endif

if ( $local == "false") then
    if ( $brcm  == "true" ) then
        set DC_SCRIPT = "./scripts/do_BRCM_dcSyn.tcl"
    else
        set DC_SCRIPT = "./scripts/do_dcSyn.tcl"
    endif
else
    if ( $brcm  == "true" ) then
        set DC_SCRIPT = "./scripts_local/do_BRCM_dcSyn.tcl"
    else
        set DC_SCRIPT = "./scripts_local/do_dcSyn.tcl"
    endif
endif
  
echo "DC_SCRIPT $DC_SCRIPT"



#-----------------------------------
# Load modules 
#-----------------------------------
module unload snps/syn
#module load snps/syn/T-2022.03-SP5-1
echo "tool_version $tool_version"
if ($tool_version != "None") then
    if (`(module avail snps/syn/$tool_version) | &grep $tool_version | wc -l` > 0 ) then
        echo "Info: DC version $tool_version"
	module load snps/syn/$tool_version
    else 
        echo "Info: DC version U-2022.12-SP7-1"
        module load snps/syn/U-2022.12-SP7-1
    endif
else
    module load snps/syn/U-2022.12-SP7-1
endif



#-----------------------------------
# mkdir
#-----------------------------------

mkdir -pv log out reports scripts_local out/spef reports/dft log/prev reports/prev log/prev_tmp reports/prev_tmp WORK
mkdir -pv sourced_scripts

\rm -rf ${design_name}_lib
\rm -rf ${design_name}_ndm.lib

#-----------------------------------
# open ddc
#-----------------------------------
if ( $open != "None" ) then
    set log_file = `date +%F.%T`

    set force  = "true"
    echo "set STAGE_TO_OPEN $open" >> .tmp_user_inputs.tcl
    
    setenv PROJECT  $project
    setenv SYN4RTL  $fe_mode
    if (`echo $open | grep ".v" | wc -l` > 0) then
         set open = "${design_name}_netlist"
    endif
    mv .tmp_user_inputs.tcl open_user_inputs.tcl

$DC_SHELL $DC_TOPO \
	-x " \
#	WA: $WA_PATH ; \
    source -e -v ./open_user_inputs.tcl ; \
	" \
	-f ./scripts/do_dcSyn.tcl \
	-output_log_file log/open_${log_file}.log | tee -a log/open_${log_file}.log.full
    
    exit [0]
    
endif

#-----------------------------------
# Run
#-----------------------------------
\rm -rf log/*

if ( -e .syn_done || -e .syn_outputs_done || -e .syn_netlist_done) then
	\rm .syn*_done
endif

setenv PROJECT  $project
setenv SYN4RTL  $fe_mode
echo "-I- Running $DC_SHELL $DC_TOPO"

if ($user_inputs == "false") then
endif
mv .tmp_user_inputs.tcl user_inputs.tcl

cp $DC_SCRIPT sourced_scripts/
set DCS = `echo $DC_SCRIPT | perl -pe 's/scripts/sourced_scripts/;s/_local//'`
echo "Information: copy running script to sourced_scripts and running it from there"
echo "             source file $DC_SCRIPT , running $DCS"

$DC_SHELL $DC_TOPO \
	-x " \
#	WA: $WA_PATH ; \
    source -e -v ./user_inputs.tcl ; \
	" \
	-f $DCS \
	-output_log_file log/do_syn.log | tee -a log/do_syn.log.full

set log_file = log/do_syn.log.full

# ~ ~ // removed seq report // ~ ~ 
set rpt = "reports/removed_sequentials.rpt"
# header
echo "#=============================================="  > $rpt
echo "# Creating removed sequentials report from log:" >> $rpt
echo "#     `realpath $log_file`" >> $rpt
echo "# On `date`" >> $rpt
echo "#==============================================" >> $rpt
echo "" >> $rpt
echo "Reason      Instace Name" >> $rpt
echo "------------------------" >> $rpt

# greping removed sequentials from log
#grep -E "OPT-1206|OPT-1207" $log_file | sed "s/'//g" | awk '{ if ($0~/OPT-1207/) {$NF="unloaded"} else {$NF="constant"} ; printf("%-12s%s\n",$NF,$4) }' >> $rpt
echo "-I- removed sequentials report is under $rpt"
# ~ ~ // // ~ ~

####################################################################################################################################
##   calculate memory usage and update k8s_profiler + 20%
####################################################################################################################################
if ( `echo $HOST| egrep "nextk8s|argo" | wc -l` > 0) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh profiler_update syn
endif
###
#### calculate memory usage and update k8s_profiler + 20%
###if (`echo $HOST| grep nextk8s | wc -l` > 0) then
###   set MEM_USAGE = `curl -s -g https://prometheus.k8s.nextsilicon.com/api/v1/query --data-urlencode 'query=max_over_time(container_memory_working_set_bytes{pod="'$HOST'",container="hw-ldap"}[14d])' | jq '.data.result[].value[1]' | perl -pe 's/"//g' | awk '{print $1/1024.0/1024.0/1024.0}'`
###   if ( $MEM_USAGE == "") then
###       echo "MEM USAGE unavailable for pod $HOST from containeer hw-ldap"
###   else
###       set MEM_USAGE_20 = `echo $MEM_USAGE | awk '{print $1*1.2}'`
###       set PROFILER = "NONE"
###       if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###       if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###       if ($PROFILER != "NONE") then
###           \cp $PROFILER ${PROFILER}.syn_old
###           echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in k8s profiler $PROFILER to $MEM_USAGE_20   (usage + 20%)"
###           set cmd = 'perl -p -i -e '\''s/(syn \d+) \d+/$1 '$MEM_USAGE_20'/'\'' '$PROFILER
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
    mv out/${design_name}.sdc out/${design_name}.sdc.orig
    cat out/${design_name}.sdc.orig | egrep -v "set_wire_load_model|set_units|set_timing_derate|set_operating_conditions|set_max_area" > out/${design_name}.sdc 



   ./scripts/run/run_pt.csh \
   	-fe_mode ${fe_mode} \
   	-create_lib_only \
   	-views func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup \
   	-stage syn \
   	-sdc_list out/${design_name}.sdc \
   	-project ${project} \
   	-design_name ${design_name} \
   	-io_clock_latency false \
	-read_spef false \
	-read_gpd false \
	-ocv flat \
	-netlist out/${design_name}.Syn.v.gz 

    if (! -e out/lib/${design_name}_func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup_lib.db) then
	echo "missing db"
	module load snps/fusioncompiler/S-2021.06-SP1
    	/tools/snps/lc/S-2021.06-SP5/bin/lc_shell -x '\
    	    source -e -v ./user_inputs.tcl ; \
	    set lib_files [glob out/lib/${DESIGN_NAME}*.lib.gz] ; \
	    foreach lib $lib_files { \
	  	regexp {out/lib/(.*)\.lib.gz} $lib match lib_file_name ; \
	  	read_lib $lib ;\
	  	set lib_name [get_object_name [get_libs]] ; \
	  	write_lib -output out/${lib_file_name}_lib.db $lib_name  ; \
	    } ; \
	    exit '   | tee -a log/do_lc.log.full

	
endif

###################################################
#	generate lib using Genus
#
###################################################
#    module unload genus innovus
#    module load genus/211 innovus/211
#    
#    # remove SDC LIST from user inputs and use genus output.
#    perl -p -i -e 's/set SDC_LIST \S+//' ./user_inputs.tcl
#    
#    perl -p -i -e 's/set PROJECT \S+/set PROJECT nxt080/' ./user_inputs.tcl
#    genus \
#        -wait 18000 \
#        -execute "source -e -v ./user_inputs.tcl" \
#	-f ./scripts/do_genus_create_lib.tcl \
#	-log log/do_genus_create_lib.log | tee -a log/do_genus_create_lib_nxt080.log.full
#
#    perl -p -i -e 's/set PROJECT \S+/set PROJECT nextcore/' ./user_inputs.tcl
#    genus \
#        -wait 18000 \
#        -execute "source -e -v ./user_inputs.tcl" \
#	-f ./scripts/do_genus_create_lib.tcl \
#	-log log/do_genus_create_lib.log | tee -a log/do_genus_create_lib_nextcore.log.full
#
#    
#    setenv SNPSLMD_QUEUE true
#    setenv SNPS_MAX_QUEUETIME  18000
#    module load snps/fusioncompiler/S-2021.06-SP1
#    /tools/snps/lc/S-2021.06-SP5/bin/lc_shell -x '\
#    	source -e -v ./user_inputs.tcl ; \
#	set lib_files [glob out/${DESIGN_NAME}*.lib] ; \
#	foreach lib $lib_files { \
#	  regexp {out/(.*)\.lib} $lib match lib_file_name ; \
#	  read_lib $lib ;\
#	  set lib_name [get_object_name [get_libs]] ; \
#	  write_lib -output out/${lib_file_name}.db $lib_name  ; \
#	} ; \
#	exit '   | tee -a log/do_lc.log.full


endif

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


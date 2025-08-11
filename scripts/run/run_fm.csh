#!/bin/tcsh -fe

source /tools/common/pkgs/modules/current/init/tcsh


#   Flag             Default   Description                                                                                
#   --------------------------------------------------------------------------------------------------------------------
# -k8s	                 true/false    'Run through k8s. Defaults: \-BSS\-BE - true. FE - false\-BSE\-.';\
# -win	                 false         'open k8s terminal and run in it.';\
# -term_options            <>            'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
# -vnc_server              <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
# -vnc_display             <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
# -label	           hw-be             'set k8s label';\
# -desc	                 <>            'k8s pod name. 20 char limit . default is running dir name';\
# -memory	                 50            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
# -tail	                 false         'tail after create k8s pod';\
# -cpu                     4             'Number of cpus per run. (default 4)';\
# -fe_mode                 false         'Do not run BE related stuff. Faster syn for FE';\
# -design_name             <>            'MUST - partition/block name';\
# -project                 <>            'MUST - nxt008 / nxt007 etc.';\
# -fm_mode                 <>            'Options:  $fm_modes';\
# -interactive             false         'Do not exit when done';\
# -syn_dir      		 <>            'Default - syn folder to start from. \-BSS\-Default is syn_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
# -innovus_dir             <>            'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
# -fusion_dir              <>            'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
# -golden_netlist          <>            'Defaults: filelist , syn_map   , syn_opt   , place';\
# -revised_netlist         <>            'Defaults: syn_map  , syn_opt   , place     , pnr_final';\
# -svf_file                <>            'svf file';\
# -disable_scan            <>            'will disable dft signals from golden and revised';\
# -use_tool_dofile         false         'work for rtl2map,map2syn,dft2place only, will take dofile script from genus/innovus output';\
# -restore                 false         'restore previous session';\
# -other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool';\
# -local                   false         'If true run  do_fm  from scripts_local folder.';\
# -scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
# -tool_version            <>            'formality version. default will be define in run_.csh' ;\
# -help                    false         'Prints help for the relevant tool' ;\
#   

#
#-----------------------------------
# Run
#-----------------------------------
#set SYN_DIR = `echo $PWD | perl -pe 's/fm/syn/'`
#set INNOVUS_DIR = `echo $PWD | perl -pe 's/fm/pnr/'`

#-----------------------------------
# Parsing flags
#-----------------------------------
source ./scripts/bin/parse_args.csh fm $argv 

if ( $is_exit  == "true" ) then
    exit 2
endif

#-----------------------------------
# nextk8s run 
#-----------------------------------
echo "k8s: $k8s"
if ($k8s == "true" ) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh fm $argv 
   exit 0
endif

###
###echo "k8s: $k8s"
###if ($k8s == "true" ) then
###   set PROFILER = "NONE"
###   if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###   if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###   if ($PROFILER != "NONE") then
###      echo "k8s profiler: $PROFILER"
###      if (`grep fm ../inter/k8s_profiler | wc -l` == 0) then
###          echo "Warning: missing fm stage for k8s_profiler. adding default values cpu $cpu , memory $memory"
###          echo "fm $cpu $memory" >> ../inter/k8s_profiler
###      endif
###      set memory = `cat $PROFILER | perl -pe 's/#.*//' | grep fm | awk '{print $NF}'`
###      set cpu = `cat $PROFILER | perl -pe 's/#.*//' | grep fm | awk '{print $(NF-1)}'`
###      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.3; $1*1.3==int($1*1.3) ? x=$1*1.3 : x=int($1*1.3)+1 ; printf x"\n" }'`
###   else
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.3; $1*1.3==int($1*1.3) ? x=$1*1.3 : x=int($1*1.3)+1 ; printf x"\n" }'`
###   endif
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
###   set COMMAND = "./scripts/run/run_fm.csh $AAA"
###   echo $COMMAND
###   if ($win == "true" || $interactive == "true" || $restore == "true") then
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
#module clear -f
#module unload cdnc/confrml/19.20.100
module unload snps/fm snps/fusioncompiler
module load snps/fusioncompiler/V-2023.12-SP5-5

#module load snps/fm/T-2022.03-SP4
if ($tool_version != "None") then
    if (`(module avail snps/fm/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: Formality version $tool_version"
	module load snps/fm/$tool_version
    else 
        echo "Info: Formality version V-2023.12-SP5
        module load snps/fm/V-2023.12-SP5
    endif
else
    module load snps/fm/V-2023.12-SP5
endif


#-----------------------------------
# running scripts 
#-----------------------------------
if ( $local == "false") then
   set SCRIPT_FILE = ../scripts/do_fm.tcl
else
   set SCRIPT_FILE = ../scripts_local/do_fm.tcl
endif


#-----------------------------------
# mkdir
#-----------------------------------
echo "-I- mode : $fm_mode"

mkdir -pv $fm_mode
mv .tmp_user_inputs.tcl ${fm_mode}/user_inputs.tcl
cd $fm_mode
if (! -d scripts) then
	ln -s ../scripts
endif


set OUTPUT_DIR  = "./session"       
set REPORTS_DIR = "./reports"   
set LOG_DIR     = "./log"       

\rm -rf WORK
mkdir -pv $OUTPUT_DIR ${OUTPUT_DIR}_prev $REPORTS_DIR ${REPORTS_DIR}_prev $LOG_DIR ${LOG_DIR}_prev log


####################################################################################################################################
##   running command
####################################################################################################################################
echo "-I- running formality"
setenv FM_WAIT_LICENSE 1

fm_shell -overwrite -file $SCRIPT_FILE | tee -i log/fm.log

cd ..

####################################################################################################################################
##   calculate memory usage and update k8s_profiler + 20%
####################################################################################################################################
if ( `echo $HOST| grep nextk8s | wc -l` > 0) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh profiler_update fm
endif

###if (`echo $HOST| grep nextk8s | wc -l` > 0) then
###   set MEM_USAGE = `curl -s -g https://prometheus.k8s.nextsilicon.com/api/v1/query --data-urlencode 'query=max_over_time(container_memory_working_set_bytes{pod="'$HOST'",container="hw-ldap"}[14d])' | jq '.data.result[].value[1]' | perl -pe 's/"//g' | awk '{print $1/1024.0/1024.0/1024.0}'`
###   if ( $MEM_USAGE == "") then
###       echo "MEM USAGE unavailable for pod $HOST from containeer hw-ldap"
###   else
###       set MEM_USAGE_20 = `echo $MEM_USAGE | awk '{print $1*1.5}'`
###       set PROFILER = "NONE"
###       if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###       if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###       if ($PROFILER != "NONE") then
###           \cp $PROFILER ${PROFILER}.fm_old
###           echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in k8s profiler $PROFILER to $MEM_USAGE_20   (usage + 50%)"
###           set cmd = 'perl -p -i -e '\''s/(fm \d+) \d+/$1 '$MEM_USAGE_20'/'\'' '$PROFILER
###           echo $cmd
###           eval $cmd
###       else
###           if ( -d ../inter) then
###               echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in ../inter/k8s_profiler to $MEM_USAGE_20   (usage + 50%)"
###               echo "fm $cpu $MEM_USAGE_20" >> ../inter/k8s_profiler
###           else
###               echo "WARNING: memory usage for run is $MEM_USAGE .  update memory usage in ./scripts_local/k8s_profiler to $MEM_USAGE_20   (usage + 20%)"
###               echo "fm $cpu $MEM_USAGE_20" >> ./scripts_local/k8s_profiler
###           endif
###       endif
###   endif
###endif

####################################################################################################################################
##   end of run
####################################################################################################################################
echo "Finished running Formality flow on $STAGE mode"

exit 0


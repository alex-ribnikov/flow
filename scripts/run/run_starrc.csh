#!/bin/tcsh -fe

source /tools/common/pkgs/modules/current/init/tcsh


mkdir -pv out/spef log
mkdir -pv out/gpd

####################################################################################################################################
##   Setting env vars 
##   TODO - add flag parsser!!!
####################################################################################################################################
setenv PROJECT  `echo $PWD | awk -F '/' '{print $(NF-3)}'`


#-----------------------------------
# Parsing flags
#-----------------------------------
source ./scripts/bin/parse_args.csh starrc $argv 

if ( $is_exit  == "true" ) then
    exit
endif


#-----------------------------------
# nextk8s run 
#-----------------------------------
echo "k8s: $k8s"
if ($k8s == "true" ) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh starrc $argv 
   exit 0
endif


###echo "k8s: $k8s"
###if ($k8s == "true" ) then
###   set PROFILER = "NONE"
###   if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###   if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###   if ($PROFILER != "NONE") then
###      echo "k8s profiler: $PROFILER"
###      set memory = `cat $PROFILER | perl -pe 's/#.*//' | grep starrc | awk '{print $NF}'`
###      set cpu = `cat $PROFILER | perl -pe 's/#.*//' | grep starrc | awk '{print $(NF-1)}'`
####      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_CPU = $cpu
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`
###   else
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
####      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_CPU = $cpu
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`
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
###   set COMMAND = "./scripts/run/run_starrc.csh $AAA"
###   echo $COMMAND
###   if ($win == "true") then
###       if ($vnc_display == "None" || $vnc_server == "None") then
###           echo "ERROR: missing vnc_display or vnc_server"
###	   exit 1
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
###



#-----------------------------------
# Load modules 
#-----------------------------------
module unload snps/starrc
if ($tool_version != "None") then
    if (`(module avail snps/starrc/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: STAR-RCXC version $tool_version"
	module load snps/starrc/$tool_version
    else 
        echo "Info: STAR-RCXC version V-2023.12-SP5-2"
        module load snps/starrc/V-2023.12-SP5-2
    endif
else
    module load snps/starrc/V-2023.12-SP5-2
endif


####################################################################################################################################
##   user setting
####################################################################################################################################
#-----------------------------------------------------------------------------------------------------------------------------------
# design setting
#-----------------------------------------------------------------------------------------------------------------------------------

#-----------------------------------
# Flow
#-----------------------------------
if ( -f scripts_local/setup.tcl ) then
   echo "-I- setup file is scripts_local/setup.tcl"
   set SETUP_FILE = scripts_local/setup.tcl
else if ( -f $PNR_DIR/scripts_local/setup.tcl ) then
   echo "-I- setup file is $PNR_DIR/scripts_local/setup.tcl"
   set SETUP_FILE = $PNR_DIR/scripts_local/setup.tcl
else if ( -f $PNR_DIR/scripts/setup/setup.${project}.tcl) then
   echo "-I- setup file is $PNR_DIR/scripts/setup/setup.${project}.tcl"
   set SETUP_FILE = $PNR_DIR/scripts/setup/setup.${project}.tcl
else
   echo "-I- setup file is ./scripts/setup/setup.${project}.tcl"
   set SETUP_FILE = ./scripts/setup/setup.${project}.tcl
     
endif

#-----------------------------------------------------------------------------------------------------------------------------------
# merge setup files with supplement reading lef file
#-----------------------------------------------------------------------------------------------------------------------------------
echo "proc get_db {args} {} ;" > starrc.tcl
echo "proc check_script_location {} {} ;" >> starrc.tcl

echo "set STAGE $STAGE ;" >> starrc.tcl
echo "set DEF_FILE None ;" >> starrc.tcl
echo "source $SETUP_FILE ;" >> starrc.tcl



if ( -f ../inter/supplement_setup.tcl ) then
   echo "-I- supplement_setup file is ../inter/supplement_setup.tcl"
   echo "source ../inter/supplement_setup.tcl ;" >> starrc.tcl
endif

if ( -f $PNR_DIR/scripts_local/supplement_setup.tcl ) then
   echo "-I- supplement_setup file is $PNR_DIR/scripts_local/supplement_setup.tcl"
   echo "source $PNR_DIR/scripts_local/supplement_setup.tcl ;" >> starrc.tcl
else if ( -f scripts_local/supplement_setup.tcl ) then
   echo "-I- supplement_setup file is scripts_local/supplement_setup.tcl"
   echo "source scripts_local/supplement_setup.tcl ;" >> starrc.tcl
endif

echo "set fid [open do_starrc.cmd a] ;" >> starrc.tcl

if ($input_db != "NDM") then
	echo 'foreach lef_file $LEF_FILE_LIST {puts $fid "LEF_FILE: $lef_file" } ;' >> starrc.tcl
endif

echo 'foreach oas_file $STREAM_FILE_LIST {puts $fid "OASIS_FILE: $oas_file" } ;' >> starrc.tcl
echo 'if {[info exists MACRO_DEF_FILE] && $MACRO_DEF_FILE != ""} { foreach def_file $MACRO_DEF_FILE {puts $fid "MACRO_DEF_FILE $def_file"}} ;' >> starrc.tcl

echo 'close $fid' >> starrc.tcl



#-----------------------------------------------------------------------------------------------------------------------------------
# all corners
#-----------------------------------------------------------------------------------------------------------------------------------
set ALL_EXTRACT_CORNERS = "\
rc_wc_cc_wc_0 \
c_wc_cc_wc_0 \
rc_bc_cc_bc_0 \
c_bc_cc_bc_0 \
rc_wc_cc_wc_T_125 \
c_wc_cc_wc_T_125 \
rc_bc_cc_bc_125 \
c_bc_cc_bc_125 \
rc_wc_cc_wc_T_0 \
c_wc_cc_wc_T_0 \
rc_wc_cc_wc_125 \
c_wc_cc_wc_125 \
"

set EXTRACT_CORNERS = "\
rc_wc_cc_wc_0 \
c_wc_cc_wc_0 \
rc_bc_cc_bc_0 \
c_bc_cc_bc_0 \
rc_wc_cc_wc_T_125 \
c_wc_cc_wc_T_125 \
rc_bc_cc_bc_125 \
c_bc_cc_bc_125 \
rc_wc_cc_wc_T_0 \
c_wc_cc_wc_T_0 \
rc_wc_cc_wc_125 \
c_wc_cc_wc_125 \
"





####################################################################################################################################
##   make command script
####################################################################################################################################
if ( $?local && $local == "true" ) then
    # Run from local do file
	\cp -p scripts_local/do_starrc.cmd .
else
    # Run from central do file
	\cp -p scripts/do_starrc.cmd .
endif


echo "setting CPU"
set cmd = "perl -p -i -e 's/CPU/$CPU/' do_starrc.cmd"
eval $cmd

echo "setting HOST"
set cmd = "perl -p -i -e 's/HOSTS/$HOSTS/' do_starrc.cmd"
eval $cmd

echo "setting DESIGN_NAME"
set cmd = "perl -p -i -e 's/DESIGN_NAME/$DESIGN_NAME/' do_starrc.cmd"
eval $cmd
echo "setting STAGE"
set cmd = "perl -p -i -e 's/STAGE/$STAGE/' do_starrc.cmd"
eval $cmd

echo "setting BLOCK_DEF_FILE"
if ($input_db == "DEF") then
   perl -p -i -e 's/\* TOP_DEF_FILE/TOP_DEF_FILE/' do_starrc.cmd
   set cmd = "perl -p -i -e 's#BLOCK_DEF_FILE#$PNR_DEF#' do_starrc.cmd"
   eval $cmd
else
   perl -p -i -e 's/\* NDM_DATABASE/NDM_DATABASE/' do_starrc.cmd
   set cmd = "perl -p -i -e 's#BLOCK_NDM_LIB#$PNR_NDM#' do_starrc.cmd"
   eval $cmd

   echo "perl -p -i -e 's#^(BLOCK:.*)#\1/${STAGE}#' do_starrc.cmd"
   set cmd = "perl -p -i -e 's#^(BLOCK:\s+\S+)#\1/${STAGE}#' do_starrc.cmd"
   echo $cmd
   eval $cmd
   
endif

echo "setting EXTRACT_CORNERS"
\rm -f ccc
foreach CCC (`echo $EXTRACT_CORNERS | perl -pe 's/\s+/ /;s/\n//g'`)
echo $CCC >> ccc
end
set CC = `cat ccc | perl -pe 's/\n/ /'`
set cmd = "perl -p -i -e 's/EXTRACT_CORNERS/$CC/' do_starrc.cmd"
echo $cmd
eval $cmd
\rm -f ccc



if ($WITH_DM == "true") then
   set cmd = "perl -p -i -e 's#.*METAL_FILL_OASIS_FILE.*#METAL_FILL_OASIS_FILE: $DM_OASIS_FILE#' do_starrc.cmd"
   eval "$cmd"
endif

if ($output_file == "GPD") then
   perl -p -i -e 's#^\* GPD#GPD#' do_starrc.cmd
   perl -p -i -e 's#^NETLIST_FILE#\* NETLIST_FILE#' do_starrc.cmd
   perl -p -i -e 's#^NETLIST_FORMAT#\* NETLIST_FORMAT#' do_starrc.cmd
else if ($output_file == "SPEF" || $output_file == "SPF") then
   perl -p -i -e 's#^GPD#\* GPD#' do_starrc.cmd
   perl -p -i -e 's#^\* NETLIST_FILE#NETLIST_FILE#' do_starrc.cmd
   perl -p -i -e 's#^\* NETLIST_FORMAT#NETLIST_FORMAT#' do_starrc.cmd
else
   echo "Error: output_file $output_file not supported"
   exit 1
endif

perl scripts/bin/starrc.pl \
	-setup $SETUP_FILE \
	-command do_starrc.cmd \
	-design_name ${DESIGN_NAME} -verbose


##   adding LEF / OAS files to command
tclsh starrc.tcl
\rm -f starrc.tcl

#if ($input_db == "NDM") then
#    cat do_starrc.cmd |grep -v LEF_FILE > do_starrc.cmd.tmp
#    mv do_starrc.cmd.tmp do_starrc.cmd
#endif

####################################################################################################################################
##   running command
####################################################################################################################################

StarXtract -clean ./do_starrc.cmd | tee log/do_starrc.log


####################################################################################################################################
##   calculate memory usage and update k8s_profiler + 20%
####################################################################################################################################
#-----------------------------------
# memory usage k8s profiler update
#-----------------------------------
if ( `echo $HOST| grep nextk8s | wc -l` > 0) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh profiler_update starrc
endif



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
###           \cp $PROFILER ${PROFILER}.starrc_old
###           echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in k8s profiler $PROFILER to $MEM_USAGE_20   (usage + 20%)"
###           set cmd = 'perl -p -i -e '\''s/(starrc \d+) \d+/$1 '$MEM_USAGE_20'/'\'' '$PROFILER
###           echo $cmd
###           eval $cmd
###       else
###           if ( -d ../inter) then
###               echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in ../inter/k8s_profiler to $MEM_USAGE_20   (usage + 20%)"
###               echo "starrc $cpu $MEM_USAGE_20" >> ../inter/k8s_profiler
###           else
###               echo "WARNING: memory usage for run is $MEM_USAGE .  update memory usage in ./scripts_local/k8s_profiler to $MEM_USAGE_20   (usage + 20%)"
###               echo "starrc $cpu $MEM_USAGE_20" >> ./scripts_local/k8s_profiler
###           endif
###       endif
###   endif
###endif

####################################################################################################################################
##   end of run
####################################################################################################################################
exit 0

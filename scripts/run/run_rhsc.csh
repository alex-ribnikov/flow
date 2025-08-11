#!/bin/tcsh -fe

source /tools/common/pkgs/modules/current/init/tcsh

# -grid                       local         'run using local resources or k8s. options: local , k8s ';\
# -k8s	                    false         'Run through k8s';\
# -desc	                    <>            'k8s pod name. 20 char limit . default is running dir name';\
# -memory	                    60            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
# -cpu                        16            'Number of cpus per run. (default 16)';\
# -design_name                <>            'MUST - partition/block name';\
# -project                    <>            'MUST - nxt008 / nxt007 etc.';\
# -innovus_dir                <>            'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
# -starrc_dir                 <>            'starrc running dir. \-BSS\-Default is starrc_SUFFIX-TO-MATCH-YOUR-PT-NAME\-BSE\-';\
# -gpd_dir                    <>            'GPD folder containing all GPD corners. \-BSS\-Default is starrc_SUFFIX-TO-MATCH-YOUR-RHSC-NAME\-BSE\-';\
# -pt_dir                     <>            'pt running dir. \-BSS\-Default is pt_SUFFIX-TO-MATCH-YOUR-RHSC-NAME\-BSE\-';\
# -stage                      chip_finish   '';\
# -create_db                  true          'running innovuse to create top PG layers DEF and ploc file.';\
# -analyse_type               static        'running IR analysis mode. options are static or dynamic.';\
# -twf                        <>            'Timing Windows file created by PrimeTime. \-BSS\-Default is pt_SUFFIX-TO-MATCH-YOUR-RHSC-NAME/out/rhtf/DESIGN_NAME_PVT.rh.timing.gz\-BSE\-';\
# -ploc_file                  <>            'power source location file. created by innovus run.';\
# -def_file                   <>            'created by innovus';\



mkdir -pv log out/db out/def out/tf scripts_local


####################################################################################################################################
##   Setting env vars 
##   TODO - add flag parsser!!!
####################################################################################################################################
#setenv BEROOT   `git rev-parse --show-toplevel` ; # <This is where your "nextflow" folder is>

####################################################################################################################################
##   Parse args
####################################################################################################################################
source ./scripts/bin/parse_args.csh rhsc $argv 

if ( $is_exit  == "true" ) then
    exit 2
endif

####################################################################################################################################
##   nextk8s run
####################################################################################################################################
echo "k8s: $k8s"
if ($k8s == "true" ) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh rhsc $argv 
   exit 0
endif

####################################################################################################################################
##  Load modules
####################################################################################################################################
module unload ansys/redhawk-sc  snps/fusioncompiler
module load snps/fusioncompiler/V-2023.12-SP5-5 

if ($tool_version != "None") then
    
    if (`(module avail ansys/redhawk/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: RedHawk SC version $tool_version"
	module load ansys/redhawk-sc/ $tool_version
    else 
        echo "Info: Redhawk SC version 2025_R1.3"
	module load ansys/redhawk-sc/2025_R1.3
    endif
    
else
	module load ansys/redhawk-sc/2025_R1.3
endif




setenv QT_X11_NO_MITSHM 1

####################################################################################################################################
##   setup files
####################################################################################################################################
if ( -f scripts_local/setup.tcl ) then
   echo "-I- setup file is scripts_local/setup.tcl"
   set SETUP_FILE = scripts_local/setup.tcl
else if ( -f $INNOVUS_DIR/scripts_local/setup.tcl ) then
   echo "-I- setup file is $INNOVUS_DIR/scripts_local/setup.tcl"
   set SETUP_FILE = $INNOVUS_DIR/scripts_local/setup.tcl
else if ( -f $INNOVUS_DIR/scripts/setup.tcl ) then
   echo "-I- setup file is $INNOVUS_DIR/scriptssetup.tcl"
   set SETUP_FILE = $INNOVUS_DIR/scripts/setup.${project}.tcl
else
   echo "-I- setup file is ./scripts/setup/setup.${project}.tcl"
   set SETUP_FILE = ./scripts/setup/setup.${project}.tcl
endif



####################################################################################################################################
##   setting
####################################################################################################################################
set Run_Static = "1"

#set CREATE_DB = "false"
#set STAGE = "chip_finish"
set NOMINAL_VOLTAGE = 0.75
set DEFAULT_PERIOD = 6.250e-10
if ( $analyse_type == "static" ) then
    set VIEW = `grep RHSC_STATIC $SETUP_FILE | awk '{print $NF}'`
#    set PVT = "no_od_125_LIBRARY_FF"
#    set SELECTED_CORNERS = "rc_wc_cc_wc_125"
#    set VIEW = "func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold"
    set COMBINATIONAL_TOGGLE_RATE = 1.0
    set IO_TOGGLE_RATE = 1.0
    set SEQUENTIAL_TOGGLE_RATE = 1.0
    set MACRO_TOGGLE_RATE = 1.0
else if ( $analyse_type == "sigem" ) then
    set VIEW = `grep RHSC_SIGEM $SETUP_FILE | awk '{print $NF}'`
#    set PVT = "no_od_125_LIBRARY_SS"
#    set SELECTED_CORNERS = "rc_wc_cc_wc_T_125"
#    set VIEW = "func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup"


    set COMBINATIONAL_TOGGLE_RATE = 1.0
    set IO_TOGGLE_RATE = 1.0
    set SEQUENTIAL_TOGGLE_RATE = 1.0
    set MACRO_TOGGLE_RATE = 1.0

else
    set VIEW = `grep RHSC_DYNAMIC $SETUP_FILE | awk '{print $NF}'`
#    set PVT = "no_od_125_LIBRARY_SS"
#    set SELECTED_CORNERS = "rc_wc_cc_wc_T_125"
#    set VIEW = "func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup"

    
    set COMBINATIONAL_TOGGLE_RATE = 0.3
    set IO_TOGGLE_RATE = 0.3
    set SEQUENTIAL_TOGGLE_RATE = 0.3
    set MACRO_TOGGLE_RATE = 1.0
endif

set SELECTED_CORNERS = `echo $VIEW | awk -F'_' '{$1=""; $NF="" ; print $0}' | perl -pe '$TTT =($_ =~ m/125/) ? "125" : "0" ;   ;s/.*[FS][FS] (.*)/\1/;s/ /_/g;s/_$/_$TTT/'`
set PVT = `echo $VIEW | awk -F'_' '{$1=""; $NF="" ; print $0}' | perl -pe 's/([FS][FS]).*/\1/;s/^ //;s/ /_/g'`

if ( "$twf" == "None" ) then
   set TIMING_WINDOW_FILES = `ls $PWD/PT/out/rhtf/*${PVT}*rh.timing.gz`
else
   set TIMING_WINDOW_FILES = `realpath $twf`
endif

#set DESIGN_NAME  = `echo $PWD | awk -F '/' '{print $(NF-2)}'`
#set INNOVUS_DIR  = `echo $PWD  | perl -pe 's/rhsc/pnr/'`
#set STARRC_DIR   = `echo $PWD  | perl -pe 's/rhsc/starrc/'`
#set PT_DIR   = `echo $PWD  | perl -pe 's/rhsc/pt/'`


####################################################################################################################################
##   check if input files exists.
####################################################################################################################################
if (! -d ${gpd_dir}/out/gpd/${DESIGN_NAME}.${STAGE}.HIER.gpd) then
	echo "ERROR missing GPD_DIR $gpd_dir"
#	exit
endif


if (! -f  $def_file) then
	echo "ERROR missing DEF_FILE $def_file"
	echo "INFO  running innovus"
	set CREATE_DB = "true"
endif

if (! -f  $PLOC_FILE) then
	echo "ERROR missing PLOC_FILE $PLOC_FILE"
	echo "INFO  running innovus"
	set CREATE_DB = "true"
endif

if (! -f  "$TIMING_WINDOW_FILES") then
	echo "ERROR missing TIMING_WINDOW_FILES $TIMING_WINDOW_FILES"
	echo "INFO  running primetime to generate it"
	set CREATE_TWF = "true"
else 
	set CREATE_TWF = "false"
endif

####################################################################################################################################
##   create DB
####################################################################################################################################

if ($CREATE_DB == "true") then
#   innovus -common_ui \
	-wait 3600 \
	-execute " \
	set CPU 16 ; \
	set DESIGN_NAME $DESIGN_NAME; \
	set INNOVUS_DIR $INNOVUS_DIR ; \
	set STAGE $STAGE ; \
	" \
	-files scripts/do_pg.tcl -log  log/do_pg.log
	
endif



####################################################################################################################################
##   make command script
####################################################################################################################################
if ( $analyse_type == "static" ) then
	\cp -p scripts/rhsc/static_run.py .
	\cp -p scripts/rhsc/static_inputs.py .
	\cp -p scripts/rhsc/custom_scripts.py .
	\cp -p scripts/rhsc/object_settings.py .
	
	set INPUT_SETTING = "static_inputs.py"
	set RUN_SCRIPT = "static_run.py"
	
else if ( $analyse_type == "sigem" ) then
	\cp -p scripts/rhsc/signal_em.run.py .
	\cp -p scripts/rhsc/signal_em_inputs.py .
	\cp -p scripts/rhsc/object_settings.py .
	\cp -p scripts/rhsc/custom_scripts.py .
	set INPUT_SETTING = "signal_em_inputs.py"
	set RUN_SCRIPT = "signal_em.run.py"
else
	\cp -p scripts/rhsc/dynamic_nopackage_run.py .
	\cp -p scripts/rhsc/dynamic_inputs.py .
	\cp -p scripts/rhsc/object_settings.py .
	\cp -p scripts/rhsc/custom_scripts.py .
	set INPUT_SETTING = "dynamic_inputs.py"
	set RUN_SCRIPT = "dynamic_nopackage_run.py"
	
endif



set TECH_APACHE = `grep TECH_APACHE $SETUP_FILE | awk '{print $NF}' | perl -pe 's/"//g'`
echo "setting TECH_APACHE"
set cmd = "perl -p -i -e 's#TECH_APACHE#$TECH_APACHE#' $INPUT_SETTING"
eval $cmd


echo "setting DESIGN_NAME"
set cmd = "perl -p -i -e 's/DESIGN_NAME/$DESIGN_NAME/' $INPUT_SETTING"
eval $cmd

echo "setting DEF_FILE"
set cmd = "perl -p -i -e 's#DEF_FILE#$DEF_FILE#' $INPUT_SETTING"
eval $cmd
echo "setting GPD_DIR"
set cmd = "perl -p -i -e 's#GPD_DIR#${GPD_DIR}/out/gpd/${DESIGN_NAME}.${STAGE}.HIER.gpd#' $INPUT_SETTING"
eval $cmd
echo "setting SELECTED_CORNERS"
set cmd = "perl -p -i -e 's#SELECTED_CORNERS#$SELECTED_CORNERS#' $INPUT_SETTING"
eval $cmd
#echo "setting TIMING_WINDOW_FILES"
#set cmd = "perl -p -i -e 's#TIMING_WINDOW_FILES#$TIMING_WINDOW_FILES#' $INPUT_SETTING"
#eval $cmd
echo "setting PLOC_FILE"
set cmd = "perl -p -i -e 's#PLOC_FILE#$PLOC_FILE#' $INPUT_SETTING"
eval $cmd




if ( `echo $PVT | grep SS | wc -l` ) then
	set VV = `echo $NOMINAL_VOLTAGE | awk '{SUM= $1 * 0.95 ; print SUM}'`
else
	set VV = `echo $NOMINAL_VOLTAGE | awk '{SUM= $1 * 1.05 ; print SUM}'`
endif
set cmd = "perl -p -i -e 's/(^\s+.VDD.):0\.\d+/\1:$VV/' $INPUT_SETTING"
eval $cmd

set cmd = "perl -p -i -e 's/MACRO_TOGGLE/$MACRO_TOGGLE_RATE/' $INPUT_SETTING"
eval $cmd
set cmd = "perl -p -i -e 's/SEQUENTIAL_TOGGLE/$SEQUENTIAL_TOGGLE_RATE/' $INPUT_SETTING"
eval $cmd
set cmd = "perl -p -i -e 's/IO_TOGGLE/$IO_TOGGLE_RATE/' $INPUT_SETTING"
eval $cmd
set cmd = "perl -p -i -e 's/COMBINATIONAL_TOGGLE/$COMBINATIONAL_TOGGLE_RATE/' $INPUT_SETTING"
eval $cmd



#-----------------------------------------------------------------------------------------------------------------------------------
# merge setup files with supplement reading lef file
#-----------------------------------------------------------------------------------------------------------------------------------
echo "proc get_db {args} {} ;" > rhsc_input.tcl
echo "proc check_script_location {} {} ;" >> rhsc_input.tcl

echo "set STAGE $STAGE ;" >> rhsc_input.tcl
echo "set DEF_FILE None ;" >> rhsc_input.tcl
echo "source $SETUP_FILE ;" >> rhsc_input.tcl
echo "set PVT $PVT ;" >> rhsc_input.tcl


if ( -f ../inter/supplement_setup.tcl ) then
   echo "-I- supplement_setup file is ../inter/supplement_setup.tcl"
   echo "source ../inter/supplement_setup.tcl ;" >> rhsc_input.tcl
endif

if ( -f $INNOVUS_DIR/scripts_local/supplement_setup.tcl ) then
   echo "-I- supplement_setup file is $INNOVUS_DIR/scripts_local/supplement_setup.tcl"
   echo "source $INNOVUS_DIR/scripts_local/supplement_setup.tcl ;" >> rhsc_input.tcl
else if ( -f scripts_local/supplement_setup.tcl ) then
   echo "-I- supplement_setup file is scripts_local/supplement_setup.tcl"
   echo "source scripts_local/supplement_setup.tcl ;" >> rhsc_input.tcl
endif
echo "set fid [open $INPUT_SETTING a] ;" >> rhsc_input.tcl
echo 'puts $fid [string repeat # 180]' >> rhsc_input.tcl
echo 'puts $fid [format "%s %*s" "###" 176 "###"]' >> rhsc_input.tcl
echo 'puts $fid [format "%s                     LEF FILE LIST %*s" "###" 142 "###"]' >> rhsc_input.tcl
echo 'puts $fid [format "%s %*s" "###" 176 "###"]' >> rhsc_input.tcl
echo 'puts $fid [string repeat # 180]' >> rhsc_input.tcl
echo 'puts $fid "lef_files = \["' >> rhsc_input.tcl
echo 'foreach lef_file $LEF_FILE_LIST {puts $fid "  '\''$lef_file'\''," } ;' >> rhsc_input.tcl
echo 'puts $fid "\]"' >> rhsc_input.tcl

#echo 'foreach lef_file $LEF_FILE_LIST {puts $fid "lef_files.append\('\''$lef_file'\''\)" } ;' >> rhsc_input.tcl

echo 'puts $fid ""' >> rhsc_input.tcl
echo 'puts $fid [string repeat # 180]' >> rhsc_input.tcl
echo 'puts $fid [format "%s %*s" "###" 176 "###"]' >> rhsc_input.tcl
echo 'puts $fid [format "%s                     LIBERTY FILE NAMES %*s" "###" 137 "###"]' >> rhsc_input.tcl
echo 'puts $fid [format "%s %*s" "###" 176 "###"]' >> rhsc_input.tcl
echo 'puts $fid [string repeat # 180]' >> rhsc_input.tcl
echo 'puts $fid "lib_files = \["' >> rhsc_input.tcl
echo 'foreach lib_file $pvt_corner($PVT,timing) {puts $fid "  '\''$lib_file'\''," } ;' >> rhsc_input.tcl
echo 'puts $fid "\]"' >> rhsc_input.tcl

#echo 'foreach lib_file $pvt_corner($PVT,timing) {puts $fid "liberty_file_names.append\('\''$lib_file'\''\)" } ;' >> rhsc_input.tcl

echo 'puts $fid ""' >> rhsc_input.tcl
echo 'puts $fid [string repeat # 180]' >> rhsc_input.tcl
echo 'puts $fid [format "%s %*s" "###" 176 "###"]' >> rhsc_input.tcl
echo 'puts $fid [format "%s                     APL FILE NAMES %*s" "###" 141 "###"]' >> rhsc_input.tcl
echo 'puts $fid [format "%s %*s" "###" 176 "###"]' >> rhsc_input.tcl
echo 'puts $fid [string repeat # 180]' >> rhsc_input.tcl
echo 'puts $fid "apl_files = \["' >> rhsc_input.tcl
echo 'foreach apl_file $pvt_corner($PVT,apl_file_list) {foreach lib_file [glob $apl_file] {puts $fid "  '\''$lib_file'\''," }} ;' >> rhsc_input.tcl
echo 'puts $fid "\]"' >> rhsc_input.tcl
echo 'puts $fid ""' >> rhsc_input.tcl

echo -n > output_loads.sdc

echo 'foreach sdc_file $sdc_files(func) {catch {exec grep set_load $sdc_file >> output_loads.sdc}}'>> rhsc_input.tcl
echo 'exec echo >  sdc_12.sdc' >> rhsc_input.tcl
echo 'foreach sdc_file $sdc_files(func) {exec cat $sdc_file >> sdc_12.sdc}'>> rhsc_input.tcl


#echo 'foreach apl_file $pvt_corner($PVT,apl_file_list) {foreach lib_file [glob $apl_file] {puts $fid "apl_file_names.append\(\{'\''file_name'\'':'\''$lib_file'\''\}\)" }} ;' >> rhsc_input.tcl
echo 'close $fid' >> rhsc_input.tcl

##   adding LEF files to command
tclsh rhsc_input.tcl


####################################################################################################################################
##   create TWF
####################################################################################################################################

if ($CREATE_TWF == "true") then
   if ( $analyse_type == "static" || $analyse_type == "sigem" ) then
      perl -p -i -e 's/(create_clock.*-period) (\d*\.*\d*)/\1 kjhgf/g;$sum =$2/1.2; s/kjhgf/$sum/' sdc_12.sdc
   endif
   if (! -f  run_pt.csh) ln -s scripts/run/run_pt.csh
   
   ./scripts/run/run_pt.csh \
       -stage $stage \
       -design_name $design_name \
       -project $project \
       -rh_out -create_lib_only \
       -cpu $cpu \
       -views $VIEW \
       -innovus_dir $innovus_dir \
       -gpd_dir $gpd_dir \
       -sdc_list sdc_12.sdc \
       -other_args "set REPORTS_DIR reports/pt"

   set TIMING_WINDOW_FILES = `ls $PWD/out/rhtf/*${PVT}*rh.timing.gz`
    
    
    
endif
echo "setting TIMING_WINDOW_FILES"
set cmd = "perl -p -i -e 's#TIMING_WINDOW_FILES#$TIMING_WINDOW_FILES#' $INPUT_SETTING"
eval $cmd

set DEFAULT_PERIOD = `grep create_clock sdc_12.sdc | perl -pe 's/.* -period (\d*\.*\d*) .*/\1/' | awk 'BEGIN{LL=1000}{if (LL > $1) {LL = $1}}END{print LL/1000000000}'`
set cmd = "perl -p -i -e 's/(default_period =) \d+\.\d+e-\d+/\1 $DEFAULT_PERIOD/' $INPUT_SETTING"
eval $cmd

#-----------------------------------------------------------------------------------------------------------------------------------
# set run.py
#-----------------------------------------------------------------------------------------------------------------------------------
#foreach sss (STATIC DYNAMIC_PROP DYNAMIC_PCVS DYNAMIC_NVP RUN_PGEM RUN_DYN_PGEM RUN_SIGEM BQM RUN_VECTOR_PROFILER RUN_VECTOR_STRESS CHECK_VIA DVD_DIAGNOSTIC R_EFF CPM )
#   set sssl = `echo $sss | tr "[A-Z]" "[a-z]"`
#   if ($sss == "CPM") then 
#	set sssl = "CPM"
#   endif
#   set sss_value = `eval echo \$$sss | tr "[A-Z]" "[a-z]" | sed 's/./\u&/'`
#   echo "setting $sssl $sss_value "
#   set cmd = "perl -p -i -e 's/^$sssl = \S+/$sssl = $sss_value/' run.py"
#   eval $cmd
#end

if ($grid == "local") then
   echo "running on local resources"
   perl -p -i -e 's/.*(ll = create_local_launcher)/\1/;s/.*(ll = create_grid_launcher)/#\1/' $RUN_SCRIPT
else
   echo "running on K8S resources"
   perl -p -i -e 's/.*(ll = create_local_launcher)/#\1/;s/.*(ll = create_grid_launcher)/\1/' $RUN_SCRIPT
   set cmd = "perl -p -i -e 's/(rhsc_nextk8s.csh)/\1 -label $label -image $image/'"
   eval $cmd

   
endif

#-----------------------------------------------------------------------------------------------------------------------------------
# make running dir
#-----------------------------------------------------------------------------------------------------------------------------------
if ( -e ${analyse_type}_old ) then
   mv ${analyse_type}_old delete
   \rm -rf delete &
endif
if ( -e ${analyse_type} ) then
   mv ${analyse_type} ${analyse_type}_old
endif

mkdir -pv $analyse_type
mv $RUN_SCRIPT $INPUT_SETTING custom_scripts.py object_settings.py $analyse_type/
if (-f output_loads.sdc) mv output_loads.sdc $analyse_type
cd $analyse_type

#-----------------------------------------------------------------------------------------------------------------------------------
# running redhawk
#-----------------------------------------------------------------------------------------------------------------------------------

redhawk_sc $RUN_SCRIPT

cd ..

####################################################################################################################################
##   calculate memory usage and update k8s_profiler + 20%
####################################################################################################################################
if ( `echo $HOST| grep nextk8s | wc -l` > 0) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh profiler_update $analyse_type
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
###           \cp $PROFILER ${PROFILER}.${analyse_type}_old
###           echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in k8s profiler $PROFILER to $MEM_USAGE_20   (usage + 50%)"
###           set cmd = 'perl -p -i -e '\''s/('$analyse_type' \d+) \d+/$1 '$MEM_USAGE_20'/'\'' '$PROFILER
###           echo $cmd
###           eval $cmd
###       else
###           if ( -d ../inter) then
###               echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in ../inter/k8s_profiler to $MEM_USAGE_20   (usage + 50%)"
###               echo "$analyse_type $cpu $MEM_USAGE_20" >> ../inter/k8s_profiler
###           else
###               echo "WARNING: memory usage for run is $MEM_USAGE .  update memory usage in ./scripts_local/k8s_profiler to $MEM_USAGE_20   (usage + 20%)"
###               echo "$analyse_type $cpu $MEM_USAGE_20" >> ./scripts_local/k8s_profiler
###           endif
###       endif
###   endif
endif

####################################################################################################################################
##   end of run
####################################################################################################################################

exit 0





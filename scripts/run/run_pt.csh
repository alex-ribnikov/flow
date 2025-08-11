#!/bin/tcsh -f

source /tools/common/pkgs/modules/current/init/tcsh

#########################################################################################################################################################################
#																					#
#	this script will run Prime Time STA  																#
#	to run need to define 																		#
# -k8s	                   false         'Run through k8s';\														#
# -label	           <>            'set k8s label';\														#
# -desc	                   <>            'k8s pod name. 20 char limit . default is running dir name';\									#
# -memory	           50            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\	#
# -design_name             <>            'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\								#
# -project                 <>            'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\								#
# -cpu                     2             'Number of cpus per run. (default 16)';\											#
# -stage                   chip_finish   '';\																#
# -interactive             false         'Do not exit when done';\													#
# -innovus_dir             <>            'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PT-NAME\-BSE\-'';\				#
# -sdc_list                <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\	#
# -pba_mode 	           exhaustive    'options for pba mode are: none , path , exhaustive';\										#
# -ocv 		           pocv	         'ocv setting: None , common , POCV(default)';\											#
# -io_clock_latency        true          'run with automatic calculated clock latency for io';\										#
# -xtalk 		   true/false    'run with si information. true when reading parasitic file. false else';\							#
# -read_spef	           true          'read parasitic spef file. default is reading gpd';\										#
# -read_gpd	           false         'read this gpd files';\													#
# -spef_files              <>            'read this spef files. when running single view. wrap list of files is "" ';\							#
# -gpd_files               <>            'read this spef files. wrap list of files is "" ';\										#
# -spef_dir                <>            'Spef folder containing all spef corners. \-BSS\-Default is starrc_SUFFIX-TO-MATCH-YOUR-PT-NAME\-BSE\-';\			#
# -gpd_dir                 <>            'GPD folder containing all GPD corners. \-BSS\-Default is starrc_SUFFIX-TO-MATCH-YOUR-PT-NAME\-BSE\-';\			#
# -netlist                 <>            'read this netlists file list. default is taking netlist from pnr/out/db/stage/design_name.v.gz';\				#
# -create_blackbox         false         'If true, the tool will automatically convert unresolved references to blackboxes';\						#
# -hosts	           localhost     'servers to run dmsa. should be localhost , nextk8s, list of servers between quatation marks';\				#
# -single		   false         'run PT in single mode';\													#
# -views		   <>	         'run list of views in list separated with spaces. default in the run_pt.csh';\							#
# -views_list              <>	         'print list of views';\													#
# -eco		           false         'run fix eco timing';\														#
# -eco_num 	           <> 	         'run fix eco timing number';\													#
# -physical 	           false         'eco stage is done with physical information default false';\									#
# -create_lib 	           false         'create .lib file. default false';\												#
# -create_lib_only         false         'create only lib files without any reports';\											#
# -create_hs               false         'create hyperscale model';\													#
# -rh_out 	           false    	 'output redhawk timing windows file';\												#
# -restore 	           false         'restore sessions';\														#
# -session                 <>            'Provide single session to restore - override the usage of VIEWS';\								#
# -power_reports           false         'generate power reports using Prime Power';\											#
# -vcd_file                false         'read this activity file for power reports using Prime Power';\								#
# -vcd_type                rtl           'can be  empty (for timing simulation) , rtl , zero_delay';\									#
# -vcd_block_path          <>            'the block hierarchy path inside the VCD';\											#
# -other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool. \-BSS\- Must be within /appost/ YOUR STRING /appost/ \-BSE\-';\
# -local                   false         'If true run  do_fm  from scripts_local folder.';\										#
# -scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\								#
# -help                    false         'Prints help for the relevant tool' ;\												#
# 																					#
# 																					#
#																					#
#																					#
#	 Var	date of change	owner		 comment														#
#	----	--------------	-------	 ---------------------------------------------------------------								#
#	0.1	09/09/2021	Royl	initial script															#
#	0.2	14/10/2021	Royl	add support for gdp parasitic file												#
#	0.3	31/01/2022	Royl	single view will run single mode												#
#																					#
#																					#
#########################################################################################################################################################################


mkdir -pv log reports out out/lib out/rhtf session work

####################################################################################################################################
##   Setting env vars 
##   TODO - add flag parsser!!!
####################################################################################################################################
if ( "$?REPO_ROOT" == 0 ) then
#    setenv BEROOT   `git rev-parse --show-toplevel` ; # <This is where your "nextflow" folder is>
else
#    setenv BEROOT   $REPO_ROOT/submodules/nextflow ; # <This is where your "nextflow" folder is>
endif 



#-----------------------------------
# Parsing flags
#-----------------------------------
source ./scripts/bin/parse_args.csh pt $argv 
if ($help == "true") then
	exit 0
endif

if ( "$project" == "None" ) then
    setenv PROJECT  `echo $PWD | awk -F '/' '{print $(NF-3)}'`
else
    setenv PROJECT $project
endif



####################################################################################################################################
##   user setting
####################################################################################################################################

####################################################################################################################################
##   nextk8s run
####################################################################################################################################
echo "k8s: $k8s"
echo $views_list
if ($k8s == "true" && $views_list == "None") then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh pt $argv 
   exit 0
endif



###set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`
###
###if ($k8s == "true" ) then
###   set PROFILER = "NONE"
###   if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###   if ( -f scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###   if ($PROFILER != "NONE") then
###      echo "k8s profiler: $PROFILER"
###      set memory = `cat $PROFILER | perl -pe 's/#.*//' | grep pt | awk '{print $NF}'`
###      set cpu = `cat $PROFILER | perl -pe 's/#.*//' | grep pt | awk '{print $(NF-1)}'`
###      echo "cpu $cpu"
###      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`
###   else
###      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`
###   endif
### 
###   set AAA = `echo $argv | perl -pe 's/-k8s//;s/-desc \S+//;s/-tail//;s/-vnc_server \S+//;s/-vnc_display \S+//;s/-win//;'`
###   if ($desc == "None") then
###      set desc = `echo $PWD | awk -F'/' '{print $NF}' | cut -c1-20 | tr "[:upper:]" "[:lower:]"`
###   endif
###   
###   echo "k8s:  $k8s"
###   echo "desc: $desc"
###   echo "argv: $argv"
###   echo "AAA:  $AAA"
###      
###   echo "K8S_MEM $K8S_MEM"
###   echo "K8S_CPU $K8S_CPU"
###   
###   set AAAA = `echo $AAA | perl -pe 's/-cpu \S+//'`
###   if ($hosts == "None") then
###      set COMMAND = "./scripts/run/run_pt.csh -cpu $cpu -hosts nextk8s $AAAA"
###   else
###      set COMMAND = "./scripts/run/run_pt.csh -cpu $cpu -hosts nextk8s $AAAA"
###   endif
###  
###   if ($win == "true" || $interactive == "true" ) then
###       if ($vnc_display == "None" || $vnc_server == "None") then
###           echo "ERROR: missing vnc_display or vnc_server"
###	   exit 1
###       endif
###       set cmd = "/tools/common/bin/nextk8s run -command '$terminal -e "\""$COMMAND"\""' -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc $desc -memory $K8S_MEM -memory-limit $K8S_MEM_LIMIT -x-display-num $vnc_display -vnc-server $vnc_server"
###   else
###       set cmd = "/tools/common/bin/nextk8s run -command '$COMMAND' -x-server -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc $desc -memory $K8S_MEM -memory-limit $K8S_MEM_LIMIT"
###   endif
###   
###   if ($label != "None") then
###       set cmd = "$cmd -label $label"
###   endif
###   echo $cmd
###   eval $cmd
###   exit 0
###endif

#-----------------------------------------------------------------------------------------------------------------------------------
# run setting
#-----------------------------------------------------------------------------------------------------------------------------------
module unload snps/prime
#module load  snps/prime/S-2021.06-SP5-2
if ($tool_version != "None") then
    if (`(module avail snps/prime/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: DC version $tool_version"
	module load snps/prime/$tool_version
    else 
        echo "Info: PrimeTime version V-2023.12-SP5-1"
        module load snps/prime/V-2023.12-SP5-1
    endif
else
    module load  snps/prime/V-2023.12-SP5-1
endif


if (! $?VERDI_HOME  ) then
   echo "define  verdi U-2023.03-SP1"
   module load snps/verdi/U-2023.03-SP1
endif


#setenv SYNOPSYS_LC_ROOT /tools/snps/lc/R-2020.09-SP5
setenv NOVAS_HOME  $VERDI_HOME
setenv NOVAS_VERSION `echo $VERDI_HOME | perl -pe 's#/# #g' | awk '{print $NF}'`
setenv LD_LIBRARY_PATH $VERDI_HOME/share/vcst/linux64/



#set HOSTS = "terminalfault crosstalk" ; # (server, # sessions , # CPU).
#set HOSTS = (localhost) ; # can be localhost , nextk8s , or servers list.

#-----------------------------------------------------------------------------------------------------------------------------------
# design setting
#-----------------------------------------------------------------------------------------------------------------------------------


#set SPEF_FILE_LIST = {}
#set GPD_FILE_LIST = {}
#-----------------------------------------------------------------------------------------------------------------------------------
# power setting
#-----------------------------------------------------------------------------------------------------------------------------------

#set POWER_REPORTS = "false"
#set VCD_FILE = /services/bespace/users/moriya/nxt012/nextflow_feb22_pn85/be_work/brcm5/nxt080/vcd/mult_2_stage/mult_2_stage_500MHz.vcd
#set VCD_TYPE = "rtl"   ; # can be  empty , rtl , zero_delay 
#set VCD_BLOCK_PATH = "mult_2_stage_tb/i_mult_2_stage_top" 	; # the block hierarchy path inside the VCD

####################################################################################################################################
##   define views to run
####################################################################################################################################
set VIEWS = ($views)

if ( "$VIEWS" == "None" ) then

    set VIEWS = ( \
    func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup \
    func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup \
    func_no_od_125_LIBRARY_SS_rc_bc_cc_bc_setup \
    func_no_od_125_LIBRARY_SS_c_bc_cc_bc_setup \
    func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup \
    func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup \
    func_no_od_minT_LIBRARY_SS_rc_bc_cc_bc_setup \
    func_no_od_minT_LIBRARY_SS_c_bc_cc_bc_setup \
    func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold \
    func_no_od_125_LIBRARY_FF_c_wc_cc_wc_hold \
    func_no_od_125_LIBRARY_FF_rc_bc_cc_bc_hold \
    func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold \
    func_no_od_minT_LIBRARY_FF_rc_wc_cc_wc_hold \
    func_no_od_minT_LIBRARY_FF_c_wc_cc_wc_hold \
    func_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold \
    func_no_od_minT_LIBRARY_FF_c_bc_cc_bc_hold \
    )

    if ($views_list == "true") then
        foreach vvv ($VIEWS)
	   echo $vvv
	end
	exit
    endif


    # 6 ciritcal views from BRTCM
    set VIEWS = (\
    func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup \
    func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup \
    func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup \
    func_no_od_125_LIBRARY_FF_rc_bc_cc_bc_hold \
    func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold \
    func_no_od_minT_LIBRARY_FF_c_bc_cc_bc_hold \
    )

    set VIEWS = ( \
    func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup \
    func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup \
    func_no_od_125_LIBRARY_SS_rc_bc_cc_bc_setup \
    func_no_od_125_LIBRARY_SS_c_bc_cc_bc_setup \
    func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup \
    func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup \
    func_no_od_minT_LIBRARY_SS_rc_bc_cc_bc_setup \
    func_no_od_minT_LIBRARY_SS_c_bc_cc_bc_setup \
    func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold \
    func_no_od_125_LIBRARY_FF_c_wc_cc_wc_hold \
    func_no_od_125_LIBRARY_FF_rc_bc_cc_bc_hold \
    func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold \
    func_no_od_minT_LIBRARY_FF_rc_wc_cc_wc_hold \
    func_no_od_minT_LIBRARY_FF_c_wc_cc_wc_hold \
    func_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold \
    func_no_od_minT_LIBRARY_FF_c_bc_cc_bc_hold \
    )
endif

#if ($RH_OUT == "true" &&  `echo $VIEWS | grep func_qod_125_LIBRARY_FF_rc_wc_cc_wc_hold | wc -l` == 0 ) then
#    echo "Adding view: func_qod_125_LIBRARY_FF_rc_wc_cc_wc_hold"
##    set VIEWS = (\
#    $VIEWS \
#    func_qod_125_LIBRARY_FF_rc_wc_cc_wc_hold \
#)
#
#endif

####################################################################################################################################
##   stages scripts
####################################################################################################################################
if ( $local == "false") then
   set PT_SCRIPT = "scripts/do_pt.tcl"
else
   set PT_SCRIPT = "scripts_local/do_pt.tcl"
endif



####################################################################################################################################
##   shell arguments
####################################################################################################################################



####################################################################################################################################
##   stages scripts
####################################################################################################################################
if ( `echo $hosts | grep nextk8s | wc -l` ) then
#   setenv TMPDIR /local-tmp
else
#   setenv TMPDIR /local/tmp
endif

if ( `echo $VIEWS | wc -w` == 1) then
	echo "single view ($VIEWS) will run in single mode"
	set single = "true"
endif

####################################################################################################################################
##   execute run
####################################################################################################################################
if ($single == "false") then
   set DISTRIBUTED = "-multi_scenario"
else
   set DISTRIBUTED = ""
endif

if ($restore == "false" && $create_lib_only == "false") then
    if (-f .pt_done) then
	\rm -f log/do_pt*
	mv reports_old reports_delete
	mv reports reports_old
	\rm -rf reports_delete &
	
	mv work_old work_delete
	mv work work_old
	\rm -rf work_delete &
	
	mv session_old session_delete
	mv session session_old
	\rm -rf session_delete &
	
    else
	\rm -f log/do_pt*
	mv reports reports_delete
	\rm -rf reports_delete &
	
	mv work work_delete
	\rm -rf work_delete &
	
	mv session session_delete
	\rm -rf session_delete &
	
       
    endif
    \mkdir -pv log reports out out/lib out/rhtf session work
endif
if ($create_lib_only == "true") then
	\rm -f log/do_pt*
	mv work_old work_delete
	mv work work_old
	\rm -rf work_delete &
endif

# 10/01/2024 Roy : work with user inputs
\cp -p .tmp_user_inputs.tcl user_inputs.tcl

if ($restore == "true") then
    set log_file_ = `whoami`_`date +%F.%T`
    set log_file = "log/open_${log_file_}.log"
else
    set log_file = "log/do_pt.log"
endif

setenv SNPSLMD_QUEUE true
setenv SNPS_MAX_QUEUETIME 259200 


pt_shell $DISTRIBUTED \
	-file ${PT_SCRIPT} \
	-x "  \
	set WA $WA_PATH ; \
 	source -e -v ./user_inputs.tcl ; \
        set VIEWS {$VIEWS} ; \
        set NETLIST_FILE_LIST {$netlist} ; \
        set SPEF_FILE_LIST {$spef_files} ; \
        set XTALK_SI {$xtalk} ; \
	" \
	-output_log_file $log_file | tee ${log_file}.full

#-----------------------------------
# memory usage k8s profiler update
#-----------------------------------
if ( `echo $HOST| grep nextk8s | wc -l` > 0) then
   echo "k8s: $k8s"
#   source ./scripts/bin/k8s_launcher.csh profiler_update pt
endif

exit 0

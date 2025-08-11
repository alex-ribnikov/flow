#!/bin/tcsh -fe

source /tools/common/pkgs/modules/current/init/tcsh

mkdir -pv log


source ./scripts/bin/parse_args.csh drc $argv 

if ( $is_exit  == "true" ) then
    exit 2
endif

#-----------------------------------
# nextk8s run 
#-----------------------------------
echo "k8s: $k8s"
if ($k8s == "true" ) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh icv_drc $argv 
   exit 0
endif



module unload snps/icvalidator
if ($tool_version != "None") then
    
    if (`(module avail snps/icvalidator/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: ICV version $tool_version"
	module load snps/icvalidator/$tool_version
    else 
        echo "Info: ICV version V-2023.12-SP5-11"
        module load snps/icvalidator/V-2023.12-SP5-11
    endif
    
else
   module load snps/icvalidator/V-2023.12-SP5-11
endif

####################################################################################################################################
##   Parse args
####################################################################################################################################
if (`echo $layout_file | grep oas | wc -l ` == 1) then
    set FORMAT = OASIS
else if (`echo $layout_file | grep gds | wc -l ` == 1) then
    set FORMAT = GDSII
endif

if ($type == "drc") then
	set RUNSET = "RUNSET_ICV_DRC"
else if ($type == "drc_fp") then
	set RUNSET = "RUNSET_ICV_DRC_FP"
else if ($type == "package") then
	set RUNSET = "RUNSET_ICV_BUMP"

else if ($type == "dodpo") then
	set RUNSET = "RUNSET_ICV_DODPO"
else if ($type == "dm") then
	set RUNSET = "RUNSET_ICV_DM"

else
	echo "ERROR: type is not allowed. "
	exit 1
endif

if ( $?local && $local == "true" ) then
    # Run from local do file
    if ( -e ./scripts_local/${RUNSET} ) then
        \cp -p scripts_local/${RUNSET} $RUNSET
    else if ( -e ./scripts_local/${RUNSET}.${project} ) then
    	echo "-I- copy scripts_local/${RUNSET}.${project} to $RUNSET"
        \cp -p scripts_local/${RUNSET}.${project} $RUNSET
    else
        echo "ERROR: missing RUNSET file ${RUNSET} in scripts_local folder"
	exit 1
    endif
else
    # Run from central do file
    echo "-I- copy scripts/flow/${RUNSET}.${project} to $RUNSET"
    \cp -p scripts/flow/${RUNSET}.${project} $RUNSET
endif

set cmd = "perl -p -i -e 's#TOPCELLNAME#$design_name#' $RUNSET"
eval $cmd


echo "running command:"
echo "icv -host_init localhost:$cpu -vue -c ${design_name} -f ${FORMAT} -i ${layout_file} ${RUNSET}"
icv -host_init localhost:$cpu -vue -c ${design_name} -f ${FORMAT} -i ${layout_file} ${RUNSET} | tee log/run_drc.log

touch .${type}_done

if ( `echo $HOST| egrep "nextk8s|argo" | wc -l` > 0) then
    echo "k8s: $k8s"
    source ./scripts/bin/k8s_launcher.csh profiler_update $type
endif

exit 0


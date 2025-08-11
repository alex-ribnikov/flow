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
   source ./scripts/bin/k8s_launcher.csh drc $argv 
   exit 0
endif



module unload mentor/calibre
if ($tool_version != "None") then
    
    if (`(module avail snps/icvalidator/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: ICV version $tool_version"
	module load mentor/calibre/$tool_version
    else 
        echo "Info: Valibre version 2021.4_17.8"
        module load mentor/calibre/2021.4_17.8
    endif
    
else
   module load mentor/calibre/2021.4_17.8
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
	set RUNSET = "RUNSET_DRC"
else if ($type == "drc_fp") then
	set RUNSET = "RUNSET_DRC_FP"

else if ($type == "package") then
	set RUNSET = "RUNSET_BUMP"

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

set cmd = "perl -p -i -e 's#GDSFILENAME#$layout_file#' $RUNSET"
eval $cmd
set cmd = "perl -p -i -e 's#TOPCELLNAME#$design_name#' $RUNSET"
eval $cmd


calibre -hyper  -hier -turbo $cpu -drc $RUNSET | tee -i log/drc.log

exit 0

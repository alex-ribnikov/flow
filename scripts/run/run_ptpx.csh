#!/bin/tcsh -fe


#-----------------------------------
# Parsing flags
#-----------------------------------
source ./scripts/bin/parse_args.csh ptpx $argv 

if ( $is_exit  == "true" ) then
    exit
endif

\cp -p .tmp_user_inputs.tcl user_inputs.tcl

./scripts/run/run_pt.csh -k8s $k8s -power_reports true -user_inputs $argv 

exit 0

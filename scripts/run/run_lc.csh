#!/bin/csh

#-----------------------------------
# FE Root / BE Root
#-----------------------------------
setenv BEROOT   `git rev-parse --show-toplevel` ; # <This is where your "nextflow" folder is>

#-----------------------------------
# Parsing flags
#-----------------------------------
source $BEROOT/ns_flow/scripts/bin/parse_args.csh lc $argv 

echo $libs_dir
echo $db_dir

if ( $is_exit  == "true" ) then
    exit 2
endif

#-----------------------------------
# Load modules 
#-----------------------------------
module clear -f
module unload snps/syn/R-2020.09-SP1
module load   snps/fusioncompiler/S-2021.06-SP1

#-----------------------------------
# mkdir
#-----------------------------------

mkdir -pv log $db_dir
#rm -rf log/*

#-----------------------------------
# Run
#-----------------------------------

setenv PROJECT  $project
setenv SYN4RTL  $fe_mode

mv .tmp_user_inputs.tcl user_inputs.tcl

/tools/snps/lc/R-2020.09-SP5/bin/lc_shell \
	-x " \
#	WA: $WA_PATH \
    source -e -v ./user_inputs.tcl ; \
	" \
	-f ./scripts/do_lc.tcl \
	-output_log_file log/do_lc.log | tee -a log/lc.log.full

set log_file = log/do_lc.log

if ( -e .syn_done ) then
	echo "-I- Syn done with normal exit"
    ./scripts/bin/logscan.tcl $log_file
	exit 0
else
	echo "-E- Syn done with abnormal exit"
    ./scripts/bin/logscan.tcl $log_file
	exit 1
endif


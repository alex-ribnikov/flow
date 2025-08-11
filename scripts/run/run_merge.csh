#!/bin/csh


module unload snps/icv_workbench
module load snps/icv_workbench/S-2021.06-SP1


####################################################################################################################################
##   Parse args
####################################################################################################################################
set DESIGN_NAME  = `echo $PWD | awk -F '/' '{print $(NF-2)}'`

icvwb -nodisplay -log log/do_merge_dummy.log -run scripts/do_merge_dummy.tcl


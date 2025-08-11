#!/bin/csh

mkdir -pv log

####################################################################################################################################
##  Load modules
####################################################################################################################################
module unload mentor/calibre
module load mentor/calibre

#set path=(/tools/mentor/calibre/2021.4_17.8/aoi_cal_2021.4_17.8/bin $path)
#setenv LM_LICENSE_FILE 1717@nxt-svc04


####################################################################################################################################
##   Parse args
####################################################################################################################################
set DESIGN_NAME  = `echo $PWD | awk -F '/' '{print $(NF-2)}'`
set INNOVUS_DIR = `echo $PWD  | perl -pe 's/\/ant/\/pnr/'`
set LAYOUT_FILE  = "${INNOVUS_DIR}/out/gds/${DESIGN_NAME}.oas.gz"

\cp -p scripts/flow/RUNSET_ANT .
set cmd = "perl -p -i -e 's#GDSFILENAME#$LAYOUT_FILE#' RUNSET_ANT"
eval $cmd
set cmd = "perl -p -i -e 's#TOPCELLNAME#$DESIGN_NAME#' RUNSET_ANT"
eval $cmd


calibre -hyper -hier -turbo 8 -drc RUNSET_ANT | tee -i log/ant.log

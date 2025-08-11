#!/bin/csh

unlimit
mkdir -pv log

####################################################################################################################################
##  Load modules
####################################################################################################################################
module unload mentor/calibre
module load mentor/calibre


####################################################################################################################################
##   Parse args
####################################################################################################################################
set DESIGN_NAME  = `echo $PWD | awk -F '/' '{print $(NF-2)}'`
set INNOVUS_DIR = `echo $PWD  | perl -pe 's/dodpo/pnr/'`
set LAYOUT_FILE  = "${INNOVUS_DIR}/out/gds/${DESIGN_NAME}_merge.oas.gz"

\cp -p scripts/flow/RUNSET_DODPO .
set cmd = "perl -p -i -e 's#GDSFILENAME#$LAYOUT_FILE#' RUNSET_DODPO"
eval $cmd
set cmd = "perl -p -i -e 's#TOPCELLNAME#$DESIGN_NAME#' RUNSET_DODPO"
eval $cmd


calibre -hier -turbo 8 -drc RUNSET_DODPO | tee -i log/drc.log

touch ${INNOVUS_DIR}/.dummy_odpo_done

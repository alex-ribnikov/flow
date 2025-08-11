#!/bin/csh

mkdir -pv log

####################################################################################################################################
##  Load modules
####################################################################################################################################
module unload mentor/calibre
module load mentor/calibre

#set path=(/tools/mentor/calibre/2021.4_17.8/aoi_cal_2021.4_17.8/bin $path)
#setenv LM_LICENSE_FILE 1717@nxt-svc04

setenv PROJECT  `echo $PWD | awk -F '/' '{print $(NF-3)}'`
set COMPARE_ONLY = "false"

####################################################################################################################################
##   Parse args
####################################################################################################################################
set DESIGN_NAME  = `echo $PWD | awk -F '/' '{print $(NF-2)}'`
set INNOVUS_DIR  = `echo $PWD  | perl -pe 's/lvs/pnr/'`

set LAYOUT_FILE     = "${INNOVUS_DIR}/out/gds/${DESIGN_NAME}.oas.gz"
set SCHEMATIC_FILE  = "${INNOVUS_DIR}/out/netlist/${DESIGN_NAME}.lvs.v"



set i = 0
while ($i < $#argv) 
  @ i++
  if ("$argv[$i]" == "-help") then
  	echo "-I- goto help"
   	goto HELP
  endif
  if ("$argv[$i]" == "-c" || "$argv[$i]" == "-compare") then
  	set COMPARE_ONLY = "true"
  endif
end





####################################################################################################################################
##   run verilog to lvs spice module
####################################################################################################################################


if (! -f ${DESIGN_NAME}.cdl || `stat -c "%Y" ${DESIGN_NAME}.cdl` < `stat -c "%Y" $SCHEMATIC_FILE` ) then 
   v2lvs -v  $SCHEMATIC_FILE -log log/v2lvs_${DESIGN_NAME}.log -o ${DESIGN_NAME}.cdl
else
   echo "${DESIGN_NAME}.cdl exists and newer than $SCHEMATIC_FILE"
endif

#-----------------------------------------------------------------------------------------------------------------------------------
# setup file
#-----------------------------------------------------------------------------------------------------------------------------------

if ( -f scripts_local/setup.tcl ) then
   echo "-I- setup file is scripts_local/setup.tcl"
   set SETUP_FILE = scripts_local/setup.tcl
else if ( -f $INNOVUS_DIR/scripts_local/setup.tcl ) then
   echo "-I- setup file is $INNOVUS_DIR/scripts_local/setup.tcl"
   set SETUP_FILE = $INNOVUS_DIR/scripts_local/setup.tcl
else
   echo "-I- setup file is $INNOVUS_DIR/scripts/setup/setup.${PROJECT}.tcl"
   set SETUP_FILE = $INNOVUS_DIR/scripts/setup/setup.${PROJECT}.tcl
endif

#-----------------------------------------------------------------------------------------------------------------------------------
# merge setup files with supplement reading cdl file
#-----------------------------------------------------------------------------------------------------------------------------------



echo "proc get_db {args} {} ;" > lvs.tcl
echo "proc check_script_location {} {} ;" >> lvs.tcl

echo "set STAGE chip_finish ;" >> lvs.tcl
echo "set DESIGN_NAME $DESIGN_NAME  ;" >> lvs.tcl
echo "set DEF_FILE None ;" >> lvs.tcl
echo "source $SETUP_FILE ;" >> lvs.tcl



if ( -f ../inter/supplement_setup.tcl ) then
   echo "-I- supplement_setup file is ../inter/supplement_setup.tcl"
   echo "source ../inter/supplement_setup.tcl ;" >> lvs.tcl
endif

if ( -f $INNOVUS_DIR/scripts_local/supplement_setup.tcl ) then
   echo "-I- supplement_setup file is $INNOVUS_DIR/scripts_local/supplement_setup.tcl"
   echo "source $INNOVUS_DIR/scripts_local/supplement_setup.tcl ;" >> lvs.tcl
else if ( -f scripts_local/supplement_setup.tcl ) then
   echo "-I- supplement_setup file is scripts_local/supplement_setup.tcl"
   echo "source scripts_local/supplement_setup.tcl ;" >> lvs.tcl
endif
echo "set fid [open all_include.txt w] ;" >> lvs.tcl
echo 'foreach cdl_file $SCHEMATIC_FILE_LIST {puts $fid ".INCLUDE  \"$cdl_file\"" } ;' >> lvs.tcl
echo 'puts $fid ".INCLUDE ${DESIGN_NAME}.cdl"' >> lvs.tcl

echo 'close $fid' >> lvs.tcl

echo "set fid [open hcell_prep.csh w] ;" >> lvs.tcl
echo 'puts $fid "echo // Layout_cell                                      Schematic_cell            > hcell.txt"' >> lvs.tcl

echo 'foreach lef_file $LEF_FILE_LIST {puts $fid "grep \"^MACRO\" $lef_file | grep -v FILLER | awk '\''{print \$2\" \"\$2}'\'' >> hcell.txt" } ;' >> lvs.tcl
echo 'close $fid' >> lvs.tcl


##   adding LEF files to command
tclsh lvs.tcl
\rm -f lvs.tcl

source hcell_prep.csh

\cp -p scripts/flow/RUNSET_LVS .
set cmd = "perl -p -i -e 's#GDSFILENAME#$LAYOUT_FILE#' RUNSET_LVS"
eval $cmd
set cmd = "perl -p -i -e 's#TOPCELLNAME#$DESIGN_NAME#' RUNSET_LVS"
eval $cmd
echo "COMPARE_ONLY: $COMPARE_ONLY"
if ($COMPARE_ONLY == "true") then
   set cmd = "perl -p -i -e 's#LAYOUT PATH\s+\S+#LAYOUT PATH ${DESIGN_NAME}\.extract\.cdl#' RUNSET_LVS"
   eval $cmd
   perl -p -i -e 's/LAYOUT SYSTEM OASIS/LAYOUT SYSTEM SPICE/' RUNSET_LVS
   calibre -lvs -hcell hcell.txt -hier -turbo 4 RUNSET_LVS | tee -i log/compare.log
else
   calibre -lvs -hcell hcell.txt -spice ${DESIGN_NAME}.extract.cdl -hier -turbo 4 RUNSET_LVS | tee -i log/lvs.log
endif


goto END

HELP:
echo "variable this script can get are:"
echo "  -help 		: print this help"
echo "  -compare ; -c  	: run compare on corrent extraction "
echo ""

END:

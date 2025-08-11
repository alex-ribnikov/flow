#!/bin/csh
module unload ext
module load ext/201/20.12-p025

mkdir -pv out/spef log

####################################################################################################################################
##   Setting env vars 
##   TODO - add flag parsser!!!
####################################################################################################################################
setenv PROJECT  `echo $PWD | awk -F '/' '{print $(NF-3)}'`

####################################################################################################################################
##   link to scripts
####################################################################################################################################
if ( ! -e scripts ) then
endif


####################################################################################################################################
##   user setting
####################################################################################################################################
#-----------------------------------------------------------------------------------------------------------------------------------
# design setting
#-----------------------------------------------------------------------------------------------------------------------------------
set CPU = 4
set DESIGN_NAME  = `echo $PWD | awk -F '/' '{print $(NF-2)}'`
set STAGE  = "route"
# qrc dir name should match pnr (pnr_dd --> qrc_dd)
set INNOVUS_DIR = `echo $PWD | awk -F'/' '{print $NF}' | perl -pe 's/qrc/pnr/'`

set INNOVUS_DB  = "../${INNOVUS_DIR}/out/def/${DESIGN_NAME}.${STAGE}.def.gz"
set TECHNOLOGY_NAME = "cln5"


set STREAM_LAYER_MAP_FILE = $PWD/scripts/flow/qrc_stream.${TECHNOLOGY_NAME}.layermap
set TECHNOLOGY_LAYER_MAP = $PWD/scripts/flow/QRC.layermap.ccl 
#-----------------------------------------------------------------------------------------------------------------------------------
# all corners
#-----------------------------------------------------------------------------------------------------------------------------------
set ALL_EXTRACT_CORNERS = "\
    cworst_0 \
    cworst_125 \
    rcworst_0 \
    rcworst_125 \
    cbest_0 \
    cbest_125 \
    rcbest_0 \
    rcbest_125 \
    typical_25 \
    typical_85 \
"

set EXTRACT_CORNERS = "\
    cworst_0 \
    cworst_125 \
    rcworst_0 \
    rcworst_125 \
    cbest_0 \
    cbest_125 \
    rcbest_0 \
    rcbest_125 \
"

set ALL_EXTRACT_CORNERS = "\
c_wc_cc_wc_0 \
c_wc_cc_wc_125 \
c_wc_cc_wc_T_0 \
c_wc_cc_wc_T_125 \
rc_wc_cc_wc_T_0 \
rc_wc_cc_wc_T_125 \
rc_wc_cc_wc_0 \
rc_wc_cc_wc_125 \
c_bc_cc_bc_0 \
c_bc_cc_bc_125 \
rc_bc_cc_bc_0 \
rc_bc_cc_bc_125 \
"

set EXTRACT_CORNERS = "\
c_wc_cc_wc_T_0 \
c_wc_cc_wc_T_125 \
rc_wc_cc_wc_T_0 \
rc_wc_cc_wc_T_125 \
"

####################################################################################################################################
##   make command script
####################################################################################################################################
\cp -p scripts/do_qrc.tcl .

echo "DEFINE $TECHNOLOGY_NAME $PWD" > qrc.def
set TECHNOLOGY_LIBRARY_FILE = $PWD/qrc.def 


set _CORNER = ""
set _TEMP = ""
foreach ccc (`echo $EXTRACT_CORNERS`)
  set __CORNER = `echo $ccc | perl -pe 's/_\d+//'`
  set __TEMP = `echo $ccc | perl -pe 's/\S+_//'`
  set _CORNER = "$_CORNER \\\n $__CORNER "
  set _TEMP = "$_TEMP \\\n $__TEMP "
end
set cmd = "perl -p -i -e 's/TECHNOLOGY_CORNER/$_CORNER/;s/TEMPERATURE/$_TEMP/' do_qrc.tcl"
eval $cmd
set cmd = "perl -p -i -e 's#STREAM_LAYER_MAP_FILE#$STREAM_LAYER_MAP_FILE#' do_qrc.tcl"
eval $cmd
set cmd = "perl -p -i -e 's#TECHNOLOGY_LIBRARY_FILE#$TECHNOLOGY_LIBRARY_FILE#' do_qrc.tcl"
eval $cmd
set cmd = "perl -p -i -e 's#TECHNOLOGY_NAME#$TECHNOLOGY_NAME#' do_qrc.tcl"
eval $cmd
set cmd = "perl -p -i -e 's#TECHNOLOGY_LAYER_MAP#$TECHNOLOGY_LAYER_MAP#' do_qrc.tcl"
eval $cmd
set cmd = "perl -p -i -e 's#STAGE#$STAGE#' do_qrc.tcl"
eval $cmd

perl scripts/bin/qrc.pl -design_name $DESIGN_NAME -setup scripts/setup/setup.${PROJECT}.tcl -command do_qrc.tcl


perl -p -i -e 's/"//g' corner.defs


####################################################################################################################################
##   running command
####################################################################################################################################


qrc \
	-mp $CPU \
	-cmd do_qrc.tcl \
	${INNOVUS_DB} ; 
	
	
exit 0

mv out/qrcExtract_gmu_cluster_cworst_0.spef.gz out/qrcExtract_gmu_cluster_cworstLT.spef.gz ; 
mv out/qrcExtract_gmu_cluster_cworst_125.spef.gz out/qrcExtract_gmu_cluster_cworstHT.spef.gz ; 
mv out/qrcExtract_gmu_cluster_rcworst_0.spef.gz out/qrcExtract_gmu_cluster_rcworstLT.spef.gz ; 
mv out/qrcExtract_gmu_cluster_rcworst_125.spef.gz out/qrcExtract_gmu_cluster_rcworstHT.spef.gz ; 
mv out/qrcExtract_gmu_cluster_cbest_0.spef.gz out/qrcExtract_gmu_cluster_cbestLT.spef.gz ; 
mv out/qrcExtract_gmu_cluster_cbest_125.spef.gz out/qrcExtract_gmu_cluster_cbestHT.spef.gz ; 
mv out/qrcExtract_gmu_cluster_rcbest_0.spef.gz out/qrcExtract_gmu_cluster_rcbestLT.spef.gz ; 
mv out/qrcExtract_gmu_cluster_rcbest_125.spef.gz out/qrcExtract_gmu_cluster_rcbestHT.spef.gz ; 
mv out/qrcExtract_gmu_cluster_typical_25.spef.gz out/qrcExtract_gmu_cluster_typicalLT.spef.gz ; 
mv out/qrcExtract_gmu_cluster_typical_85.spef.gz out/qrcExtract_gmu_cluster_typicalHT.spef.gz ' ; 

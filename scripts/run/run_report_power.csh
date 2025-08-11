#!/bin/csh
module unload ssv innovus
module load  ssv/201/20.13-s082_1 innovus

mkdir -pv log reports out
\rm -rf log/*

####################################################################################################################################
##   user setting
####################################################################################################################################
set INTERACTIVE = "true"
set CREATE_DB_FOR_VOLTUS = "true"

#-----------------------------------------------------------------------------------------------------------------------------------
# run setting
#-----------------------------------------------------------------------------------------------------------------------------------
set CPU = 8
set POWER_METHOD = static       ; #options are static , dynamic_vectorless , dynamic_vectorbased , dynamic_mixed_mode , vector_profile
set ACTIVITY_FILE = {}
set DEFAULT_SWITCHING_ACTIVITY = "0.3,0.3,1.8"   # should be {input_activity,sequential_activity,clock_gates_output}
set SWITCHING_ACTIVITY_FILE = {}
set RAIL_ANALYSIS_TEMPERATURE = 110

setenv TMPDIR /local/tmp

#-----------------------------------------------------------------------------------------------------------------------------------
# design setting
#-----------------------------------------------------------------------------------------------------------------------------------
setenv PROJECT  `echo $PWD | awk -F '/' '{print $(NF-3)}'`
set DESIGN_NAME  = `echo $PWD | awk -F '/' '{print $(NF-2)}'`
set OCV = "false"               

set STAGE = "route"
set INNOVUS_DIR = "../pnr"
set SPEF_DIR = "../qrc"

set INNOVUS_DB = "$INNOVUS_DIR/out/db/${DESIGN_NAME}.${STAGE}.enc.dat"
set INNOVUS_DB_FOR_VOLTUS = "./out/db/${DESIGN_NAME}.pg_addon.enc.dat"

set SPEF_FILE_LIST = {}
set NETLIST_FILE_LIST = "out/db/${DESIGN_NAME}.pg_addon.enc.dat/${DESIGN_NAME}.v.gz"
set DEF_FILES = "out/def/${DESIGN_NAME}.pg_addon.def.gz"


####################################################################################################################################
##   define views to run
####################################################################################################################################
set VIEWS = func_pffg_v0830_t125_cworst_hold

####################################################################################################################################
##   stages scripts
####################################################################################################################################
set VOLTUS_SCRIPT = "./do_voltus.tcl"

####################################################################################################################################
##   execute voltus run
####################################################################################################################################
voltus -stylus \
        -execute " \
        set DESIGN_NAME $DESIGN_NAME; \
        set VIEWS {$VIEWS} ; \
        set STAGE $STAGE ; \
        set OCV $OCV ; \
        set NETLIST_FILE_LIST $NETLIST_FILE_LIST ; \
        set DEF_FILES $DEF_FILES ; \
        set POWER_METHOD $POWER_METHOD ; \
        set ACTIVITY_FILE $ACTIVITY_FILE ; \
        set SWITCHING_ACTIVITY_FILE $SWITCHING_ACTIVITY_FILE ; \
        set DEFAULT_SWITCHING_ACTIVITY $DEFAULT_SWITCHING_ACTIVITY ; \
        set RAIL_ANALYSIS_TEMPERATURE $RAIL_ANALYSIS_TEMPERATURE ; \
        set CPU $CPU ; \
        set INNOVUS_DB $INNOVUS_DB_FOR_VOLTUS ; \
        set SPEF_DIR $SPEF_DIR ; \
        set SPEF_FILE_LIST $SPEF_FILE_LIST ; \
        set INTERACTIVE $INTERACTIVE ; \
        " \
        -files ${VOLTUS_SCRIPT} -log log/do_voltus_${POWER_METHOD}.log


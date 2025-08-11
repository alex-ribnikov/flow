set MAX_ROUTING_LAYER 18

#### USE JUST 1 VIEW AS INN AND GEN DEFAULT FOR RUNTIME ####
if { [info var synopsys_program_name] == "" && [get_db program_short_name] == "innovus" } { 
    
    set scenarios(setup)   "func_no_od_125_LIBRARY_SS_cworst_setup"
    set scenarios(hold)    "func_no_od_minT_LIBRARY_FF_rcbest_hold"
    set scenarios(dynamic) "func_no_od_125_LIBRARY_FF_cbest_hold"
    set scenarios(leakage) "func_no_od_125_LIBRARY_FF_cbest_hold"

}


#### ADD BLOCK LEFS AND LIBS ####
set wa /services/bespace/users/ory/nextflow_quad_1121/be_work/brcm5/grid_clusters_wrap/v0/

set LEF_FILE_LIST [lreplace  $LEF_FILE_LIST [lsearch $LEF_FILE_LIST "*/tsmc5ff_ck06t0750v.lef"] [lsearch $LEF_FILE_LIST "*/tsmc5ff_ck06t0750v.lef"] ]

if { [set driname [exec pwd | tr "/" " " | awk {{print $NF}}]] == "pnr_from_brcm" } { 
set LEF_FILE_LIST "$LEF_FILE_LIST \
$wa/inter/inputs/lefs/nfi_mcu_top.chip_finish_from_brcm.lef \
$wa/inter/inputs/lefs/cbue_top.chip_finish_from_brcm.lef    \
$wa/inter/inputs/lefs/cbui_top.cts_from_brcm.lef    \
$wa/inter/inputs/lefs/tsmc5ff_ck06t0750v.lef \
$wa/inter/inputs/lefs/my_vp.lef \
"
} else {
set LEF_FILE_LIST "$LEF_FILE_LIST \
$wa/inter/inputs/lefs/nfi_mcu_top.chip_finish.lef \
$wa/inter/inputs/lefs/cbue_top.route.lef \
$wa/inter/inputs/lefs/cbui_top.cts.lef \
$wa/inter/inputs/lefs/tsmc5ff_ck06t0750v.lef \
$wa/inter/inputs/lefs/my_vp.lef \
"
}

set PVT_CORNER no_od_125_LIBRARY_SS
set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
$wa/inter/inputs/libs/cbui_top_func_no_od_125_LIBRARY_SS_cworst_setup.lib  \
$wa/inter/inputs/libs/cbue_top_func_no_od_125_LIBRARY_SS_cworst_setup.lib \
$wa/inter/inputs/libs/nfi_mcu_top_func_no_od_125_LIBRARY_SS_cworst_setup.lib \
"

set PVT_CORNER no_od_125_LIBRARY_FF
set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing)  \
$wa/inter/inputs/libs/cbui_top_func_no_od_125_LIBRARY_FF_cbest_hold.lib \
$wa/inter/inputs/libs/cbue_top_func_no_od_125_LIBRARY_FF_cbest_hold.lib  \
$wa/inter/inputs/libs/nfi_mcu_top_func_no_od_125_LIBRARY_FF_cbest_hold.lib \
"

set PVT_CORNER no_od_minT_LIBRARY_SS
set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
$wa/inter/inputs/libs/cbui_top_func_no_od_minT_LIBRARY_SS_cworst_setup.lib \
$wa/inter/inputs/libs/cbue_top_func_no_od_minT_LIBRARY_SS_cworst_setup.lib  \
$wa/inter/inputs/libs/nfi_mcu_top_func_no_od_minT_LIBRARY_SS_cworst_setup.lib \
"

set PVT_CORNER no_od_minT_LIBRARY_FF
set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
$wa/inter/inputs/libs/cbui_top_func_no_od_minT_LIBRARY_FF_cbest_hold.lib \
$wa/inter/inputs/libs/cbue_top_func_no_od_minT_LIBRARY_FF_cbest_hold.lib \
$wa/inter/inputs/libs/nfi_mcu_top_func_no_od_minT_LIBRARY_FF_cbest_hold.lib \
"

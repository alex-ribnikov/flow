#################################################################################################################################################################################################
#																								#
#	this script will define all variable need to run all tools.																#
#	the order of setting is:																				#
#		running scenarios																				# 
#		timing constraint 																				#
#		physical view																					#
#		RC view																						#
#		timing view																					#
#		design setting																					# 
#		floorplan setting																				# 
#		tools dependent	; * can define tool setting																	#
#																								#
#																								#
#																								#
#	 Var	date of change	owner	comment																			#
#	----	--------------	-------	---------------------------------------------------------------												#
#	0.1	    01/03/2021		Ory		New setup for snps n5 libs														#
#	0.2	    03/03/2021		Ory		Merge with Roy																#
#																								#
#																								#
#################################################################################################################################################################################################
if {[info command check_script_location] == "check_script_location"} { check_script_location }

if {![info exists FE_MODE] } {set FE_MODE false}
#if { [info exists ::env(SYN4RTL)] } { set FE_MODE $::env(SYN4RTL) } else { set FE_MODE false }
#if { [info exists ::env(PROJECT)] } { set PROJECT ${PROJECT} } 

set mmmc_results ./scripts_local/mmmc_results.tcl

if {![info exists DESIGN_NAME]} {set DESIGN_NAME [lindex [split [pwd] "/"] end-2]}
if {![info exists SPEF_DIR]}    {set SPEF_DIR ""}
if {![info exists GPD_DIR]}     {set GPD_DIR ""}

#################################################################################################################################################################################################
###    BRCM TVAR setting 
#################################################################################################################################################################################################
set TVAR(sta,max_vnom) 0.75
set TVAR(sta,max_vnom,v0550) 0.75
set TVAR(sta,max_vnom,v0600) 0.75
set TVAR(sta,max_vnom,v0620) 0.75
set TVAR(sta,max_vnom,v0670) 0.75
set TVAR(sta,max_vnom,v0830) 0.75
set TVAR(sta,use_85C_aging_derates) false
set TVAR(sta,enable_struct_clk_net_derate) false


#################################################################################################################################################################################################
###    running scenarios 
#################################################################################################################################################################################################

set scenarios(setup) "func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_rc_bc_cc_bc_setup"
set scenarios(hold) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold func_qod_125_LIBRARY_FF_rc_bc_cc_bc_hold func_qod_125_LIBRARY_FF_rc_wc_cc_wc_T_hold func_qod_minT_LIBRARY_FF_c_bc_cc_bc_hold func_qod_minT_LIBRARY_FF_rc_bc_cc_bc_hold func_qod_minT_LIBRARY_FF_rc_wc_cc_wc_T_hold func_qod_125_LIBRARY_FF_rc_wc_cc_wc_hold"
set scenarios(dynamic) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
set scenarios(leakage) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"

set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]

set AC_LIMIT_SCENARIOS "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
set DEFAULT_SETUP_VIEW func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup
set DEFAULT_CCOPT_VIEW func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup
set DEFAULT_HOLD_VIEW  func_qod_minT_LIBRARY_FF_rc_bc_cc_bc_hold

set RHSC_STATIC  func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold
set RHSC_DYNAMIC func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup
set RHSC_SIGEM   func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup


if {![info exists STAGE] || $STAGE == "syn" || $STAGE == "syn_reg" || $STAGE == "FM" } {
        set scenarios(setup) "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
    if { $FE_MODE } {
        set scenarios(hold) ""
        set scenarios(dynamic) ""
        set scenarios(leakage) ""
        	set DEFAULT_SETUP_VIEW func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup
    } else {
        set scenarios(hold)    "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
        set scenarios(dynamic) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
        set scenarios(leakage) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
    }
    set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
    
} elseif { [info exists STAGE] && $STAGE == "eco"} {
    set DEFAULT_SETUP_VIEW func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup
    set DEFAULT_CCOPT_VIEW func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup
    set scenarios(setup) "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
    set scenarios(hold)  "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
    set scenarios(dynamic) "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
    set scenarios(leakage) "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
}

#################################################################################################################################################################################################
###	setting per project 
#################################################################################################################################################################################################
if {[info exists PROJECT] && $PROJECT == "nextcore"} {
	regsub -all "no_od" $scenarios(setup) "hod" scenarios(setup)
	regsub -all "no_od" $scenarios(hold) "hod" scenarios(hold)
	regsub -all "qod" $scenarios(hold) "hod" scenarios(hold)
	regsub -all "no_od" $scenarios(dynamic) "hod" scenarios(dynamic)
	regsub -all "qod" $scenarios(dynamic) "hod" scenarios(dynamic)
	regsub -all "no_od" $scenarios(leakage) "hod" scenarios(leakage)
	regsub -all "qod" $scenarios(leakage) "hod" scenarios(leakage)
	regsub -all "qod" $all_scenarios "hod" all_scenarios
	regsub -all "no_od" $all_scenarios "hod" all_scenarios
	
	if {![info exists CLOCK_GATING_SETUP]} {set CLOCK_GATING_SETUP 0.085 }
	
	
} elseif {[info exists PROJECT] && $PROJECT == "nxt080"} {
	regsub -all "qod" $scenarios(hold) "no_od" scenarios(hold)
	regsub -all "qod" $scenarios(dynamic) "no_od" scenarios(dynamic)
	regsub -all "qod" $scenarios(leakage) "no_od" scenarios(leakage)
	regsub -all "qod" $all_scenarios "no_od" all_scenarios
	
} elseif {[info exists PROJECT] && $PROJECT == "inext"} {
        set scenarios(setup) "func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup"
        set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
	set OCV "none"
   
} elseif {[info exists PROJECT] && $PROJECT == "nxt013"} {
        set scenarios(setup) "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
        set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
	set OCV "flat"
}


echo "scenarios(setup) $scenarios(setup)"
echo "scenarios(hold) $scenarios(hold)"
echo "scenarios(dynamic) $scenarios(dynamic)"
echo "scenarios(leakage) $scenarios(leakage)"


#################################################################################################################################################################################################
###    timing constraint 
#################################################################################################################################################################################################

if { ! [info exists SDC_LIST] || $SDC_LIST == "None" } {
        set sdc_files(func) ""
        if {[info exists sh_launch_dir]} {
            if { [file exists ${sh_launch_dir}/../inter/${DESIGN_NAME}.pre.sdc]  }     { append sdc_files(func) " ${sh_launch_dir}/../inter/${DESIGN_NAME}.pre.sdc "  }
            if { [file exists ${sh_launch_dir}/../inter/${DESIGN_NAME}.sdc]}           { append sdc_files(func) " ${sh_launch_dir}/../inter/${DESIGN_NAME}.sdc "      }
            if { [file exists ${sh_launch_dir}/../inter/${DESIGN_NAME}.post.sdc] }     { append sdc_files(func) " ${sh_launch_dir}/../inter/${DESIGN_NAME}.post.sdc " }                
        } else {
            if { [file exists ../inter/${DESIGN_NAME}.pre.sdc]  }         { append sdc_files(func) " ../inter/${DESIGN_NAME}.pre.sdc "  }
            if { [file exists ../inter/${DESIGN_NAME}.sdc]}     { append sdc_files(func) " ../inter/${DESIGN_NAME}.sdc "      }
            if { [file exists ../inter/${DESIGN_NAME}.post.sdc] } {
                append sdc_files(func) " ../inter/${DESIGN_NAME}.post.sdc " 
                set sdc_update_files(func) " ../inter/${DESIGN_NAME}.post.sdc " 
            } else { 
                set sdc_update_files(func) "" 
            }               
        }
    
        if { $sdc_files(func) == "" } { puts "-E- No SDC file" ;  }
        set sdc_files(scan_shift) ""
        set sdc_files(scan_capture) ""
        set sdc_files(bist) ""
} elseif { [info exists SDC_LIST] } {
    if { [regexp "," $SDC_LIST] } { set sdc_list [split $SDC_LIST ","] } { set sdc_list [split $SDC_LIST " "] }
    foreach file $sdc_list {  
        if {![file exists $file] } { puts "-E- File $file is on sdc_list but not exists" ; exit } 
    }
    
    set sdc_files(func) [join $sdc_list " "]
    if { [file exists ../inter/${DESIGN_NAME}.post.sdc] } {
        set sdc_update_files(func) " ../inter/${DESIGN_NAME}.post.sdc " 
    #    set sdc_update_files(func) "" 
    }
}

puts "-I- sdc files are: "
parray sdc_files

#################################################################################################################################################################################################
###    physical view
#################################################################################################################################################################################################
# set GDS_MAP_FILE      "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/APR/cdns/1.1.2A/PRTF_Innovus_5nm_014_Cad_V11_2a/PR_tech/Cadence/GdsOutMap/PRTF_Innovus_N5_gdsout_17M_1X_h_1Xb_v_1Xe_h_1Ya_v_1Yb_h_5Y_vhvhv_2Yy2Yx2R_SHDMIM.11_2a.map"
# add prboundary layer
set GDS_MAP_FILE      "./scripts/bin/PRTF_Innovus_N5_gdsout_17M_1X_h_1Xb_v_1Xe_h_1Ya_v_1Yb_h_5Y_vhvhv_2Yy2Yx2R_SHDMIM.11_2a.map"
set STREAM_LAYER_MAP_FILE /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_gds_lefdef_map
set TECHNOLOGY_LAYER_MAP /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_lefdef_rcxt_map

if {![info exists ROUTE_DFM]} {set ROUTE_DFM true}
set DFM_REDUNDANT_VIA ""
set METAL_FILL_RUNSET ""
set TECH_APACHE "/bespace/users/royl/deliveries/from_brcm/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_typical_apache.tech"

set ICT_EM_MODELS "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/EM/cdns/1.1.3A/cln5_1p17m+ut-alrdl_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim.ictem"
set TECH_FILE "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.tf"
set TECH_LEF " \
/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.lef \
/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/cadence/var_active_17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.lef \
"

set LEF_FILE_LIST "$TECH_LEF \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/lef/tsmc5ff_ck06t0750v.lef \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/lef/tsmc5ff_ga06t0750v.lef \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/lef/tsmc5ff_lscore.lef \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/lef/tsmc5ff_mb06t0750v.lef \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/lef/tsmc5ff_sc06t0750v.lef \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/lef/tsmc5ff_tgate_mb06t0750v.lef \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/lef/tsmc5ff_tgate_sc06t0750v.lef \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/lef/tsmc5ff_top06t0750v.lef \
 \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/Docs/DRM/1.2/LEF/N5_ICOVL_TYPE_C_M11/N5_ICOVL_v0d9.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/Docs/DRM/1.2/LEF/N5_ICOVL_TYPE_B_M11/N5_ICOVL_v0d9.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/Docs/DRM/N5_ICOVL_library_kit_general_v1d1_200526/LEF/N5_ICOVL_TYPE_H_M11/N5_ICOVL_v0d5.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20221206/lef/N5_DTCD_v0d9.lef \
"
set NDM_REFERENCE_LIBRARY " \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/iccii.frame/tsmc5ff_ck06t0750v.ndm \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/iccii.frame/tsmc5ff_ga06t0750v.ndm \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/iccii.frame/tsmc5ff_lscore.ndm \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/iccii.frame/tsmc5ff_mb06t0750v.ndm \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/iccii.frame/tsmc5ff_sc06t0750v.ndm \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/iccii.frame/tsmc5ff_tgate_mb06t0750v.ndm \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/iccii.frame/tsmc5ff_tgate_sc06t0750v.ndm \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/iccii.frame/tsmc5ff_top06t0750v.ndm \
 \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/Docs/DRM/1.2/NDM/N5_ICOVL_TYPE_B_M11/N5_ICOVL_v0d9.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/Docs/DRM/N5_ICOVL_library_kit_general_v1d1_200526/NDM/N5_ICOVL_TYPE_H_M11/N5_ICOVL_v0d5.ndm \
"
#/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/Docs/DRM/1.2/NDM/N5_ICOVL_TYPE_C_M11/N5_ICOVL_v0d9.ndm \


set LEAKAGE_CONFIG_FILE ""

set LEAKAGE_LEF_SIDE_FILES ""

set LEAKAGE_LIB_SIDE_FILES ""

set POWER_GRID_LIBRARIES " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/PGV/techonly.cl \
"

set STREAM_FILE_LIST " \
"

set SCHEMATIC_FILE_LIST " \
    ./scripts/flow/empty_subckt.cdl \
"
set CTL_FILE_LIST ""

#################################################################################################################################################################################################
###    RC view
#################################################################################################################################################################################################
set rc_corner(gpd_file) "$GPD_DIR/out/gpd/${DESIGN_NAME}.${STAGE}.HIER.gpd"

set rc_corner(c_wc_cc_wc_T)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cworst_CCworst_T.tch"
set rc_corner(c_wc_cc_wc_T,nxtgrd)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cworst_CCworst_T.nxtgrd"
set rc_corner(c_wc_cc_wc_T,rc_variation) 0.1
set rc_corner(c_wc_cc_wc_T,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.c_wc_cc_wc_T_0.gz"
set rc_corner(c_wc_cc_wc_T,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.c_wc_cc_wc_T_125.gz"
set rc_corner(c_wc_cc_wc_T,preRoute_res) 1.029
set rc_corner(c_wc_cc_wc_T,postRoute_res) "{1.023 1.023 1}"
set rc_corner(c_wc_cc_wc_T,preRoute_cap) 1.223
set rc_corner(c_wc_cc_wc_T,postRoute_cap) "{1.026 1.026 1}"
set rc_corner(c_wc_cc_wc_T,postRoute_xcap) "{1.064 1.064 1}"
set rc_corner(c_wc_cc_wc_T,preRoute_clkres) 1
set rc_corner(c_wc_cc_wc_T,preRoute_clkcap) 1
set rc_corner(c_wc_cc_wc_T,postRoute_clkcap) "{1 1 1}"
set rc_corner(c_wc_cc_wc_T,postRoute_clkres) "{1 1 1}"

set rc_corner(c_wc_cc_wc)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cworst_CCworst.tch"
set rc_corner(c_wc_cc_wc,nxtgrd)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cworst_CCworst.nxtgrd"
set rc_corner(c_wc_cc_wc,rc_variation) 0.1
set rc_corner(c_wc_cc_wc,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.c_wc_cc_wc_0.gz"
set rc_corner(c_wc_cc_wc,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.c_wc_cc_wc_125.gz"
set rc_corner(c_wc_cc_wc,preRoute_res) 1.029
set rc_corner(c_wc_cc_wc,postRoute_res) "{1.023 1.023 1}"
set rc_corner(c_wc_cc_wc,preRoute_cap) 1.223
set rc_corner(c_wc_cc_wc,postRoute_cap) "{1.026 1.026 1}"
set rc_corner(c_wc_cc_wc,postRoute_xcap) "{1.064 1.064 1}"
set rc_corner(c_wc_cc_wc,preRoute_clkres) 1
set rc_corner(c_wc_cc_wc,preRoute_clkcap) 1
set rc_corner(c_wc_cc_wc,postRoute_clkcap) "{1 1 1}"
set rc_corner(c_wc_cc_wc,postRoute_clkres) "{1 1 1}"

set rc_corner(rc_wc_cc_wc)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcworst_CCworst.tch"
set rc_corner(rc_wc_cc_wc,nxtgrd)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcworst_CCworst.nxtgrd"
set rc_corner(rc_wc_cc_wc,rc_variation) 0.1
set rc_corner(rc_wc_cc_wc,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.rc_wc_cc_wc_0.gz"
set rc_corner(rc_wc_cc_wc,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.rc_wc_cc_wc_125.gz"
set rc_corner(rc_wc_cc_wc,preRoute_res) 1.003
set rc_corner(rc_wc_cc_wc,postRoute_res) "{1.017 1.017 1}"
set rc_corner(rc_wc_cc_wc,preRoute_cap) 1.223
set rc_corner(rc_wc_cc_wc,postRoute_cap) "{1.024 1.024 1}"
set rc_corner(rc_wc_cc_wc,postRoute_xcap) "{1.007 1.007 1}"
set rc_corner(rc_wc_cc_wc,preRoute_clkres) 1
set rc_corner(rc_wc_cc_wc,preRoute_clkcap) 1
set rc_corner(rc_wc_cc_wc,postRoute_clkcap) "{1 1 1}"
set rc_corner(rc_wc_cc_wc,postRoute_clkres) "{1 1 1}"

set rc_corner(rc_wc_cc_wc_T)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcworst_CCworst_T.tch"
set rc_corner(rc_wc_cc_wc_T,nxtgrd)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcworst_CCworst_T.nxtgrd"
set rc_corner(rc_wc_cc_wc_T,rc_variation) 0.1
set rc_corner(rc_wc_cc_wc_T,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.rc_wc_cc_wc_T_0.gz"
set rc_corner(rc_wc_cc_wc_T,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.rc_wc_cc_wc_T_125.gz"
set rc_corner(rc_wc_cc_wc_T,preRoute_res) 1.003
set rc_corner(rc_wc_cc_wc_T,postRoute_res) "{1.017 1.017 1}"
set rc_corner(rc_wc_cc_wc_T,preRoute_cap) 1.223
set rc_corner(rc_wc_cc_wc_T,postRoute_cap) "{1.024 1.024 1}"
set rc_corner(rc_wc_cc_wc_T,postRoute_xcap) "{1.007 1.007 1}"
set rc_corner(rc_wc_cc_wc_T,preRoute_clkres) 1
set rc_corner(rc_wc_cc_wc_T,preRoute_clkcap) 1
set rc_corner(rc_wc_cc_wc_T,postRoute_clkcap) "{1 1 1}"
set rc_corner(rc_wc_cc_wc_T,postRoute_clkres) "{1 1 1}"

set rc_corner(c_bc_cc_bc)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cbest_CCbest.tch"
set rc_corner(c_bc_cc_bc,nxtgrd)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cbest_CCbest.nxtgrd"
set rc_corner(c_bc_cc_bc,rc_variation) 0.1
set rc_corner(c_bc_cc_bc,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.c_bc_cc_bc_0.gz"
set rc_corner(c_bc_cc_bc,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.c_bc_cc_bc_125.gz"
set rc_corner(c_bc_cc_bc,preRoute_res) 0.935
set rc_corner(c_bc_cc_bc,postRoute_res) "{1.009 1.009 1}"
set rc_corner(c_bc_cc_bc,preRoute_cap) 1.167
set rc_corner(c_bc_cc_bc,postRoute_cap) "{1.032 1.032 1}"
set rc_corner(c_bc_cc_bc,postRoute_xcap) "{1.028 1.028 1}"
set rc_corner(c_bc_cc_bc,preRoute_clkres) 1
set rc_corner(c_bc_cc_bc,preRoute_clkcap) 1
set rc_corner(c_bc_cc_bc,postRoute_clkcap) "{1 1 1}"
set rc_corner(c_bc_cc_bc,postRoute_clkres) "{1 1 1}"

set rc_corner(rc_bc_cc_bc)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcbest_CCbest.tch"
set rc_corner(rc_bc_cc_bc,nxtgrd)  "/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/FN_04122024/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcbest_CCbest.nxtgrd"
set rc_corner(rc_bc_cc_bc,rc_variation) 0.1
set rc_corner(rc_bc_cc_bc,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.rc_bc_cc_bc_0.gz"
set rc_corner(rc_bc_cc_bc,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.rc_bc_cc_bc_125.gz"
set rc_corner(rc_bc_cc_bc,preRoute_res) 0.945
set rc_corner(rc_bc_cc_bc,postRoute_res) "{1.026 1.026 1}"
set rc_corner(rc_bc_cc_bc,preRoute_cap) 1.21
set rc_corner(rc_bc_cc_bc,postRoute_cap) "{1.044 1.044 1}"
set rc_corner(rc_bc_cc_bc,postRoute_xcap) "{1.073 1.073 1}"
set rc_corner(rc_bc_cc_bc,preRoute_clkres) 1
set rc_corner(rc_bc_cc_bc,preRoute_clkcap) 1
set rc_corner(rc_bc_cc_bc,postRoute_clkcap) "{1 1 1}"
set rc_corner(rc_bc_cc_bc,postRoute_clkres) "{1 1 1}"

set rc_corner(typical)  /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/typical/Tech/typical/qrcTechFile
set rc_corner(typical,nxtgrd) ""
set rc_corner(typical,rc_variation) 0.1
set rc_corner(typical,spef_25) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.typical_25.gz"
set rc_corner(typical,spef_85) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.typical_85.gz"


#################################################################################################################################################################################################
###    timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "WCIND_WCT"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc5ff_sc06t0750v_pssg_s300_v0670_t125_xcwccwt" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
       /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff*/apache/SS0670125/* \
    /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20230310/memory/int/power/apache/apl/*/*ss* \
    "
   set pvt_corner($PVT_CORNER,timing) "\
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/db/tsmc5ff_tgate_mb06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/db/tsmc5ff_tgate_sc06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
        /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/db/tsmc5ff_lscore_pssg_s300_v0670_t125_o0760_xcwccwt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "WCIND_WCT"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc5ff_sc06t0750v_pssg_s300_v0670_t000_xcwccwt" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/db/tsmc5ff_tgate_mb06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/db/tsmc5ff_tgate_sc06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
        /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/db/tsmc5ff_lscore_pssg_s300_v0670_t000_o0760_xcwccwt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc5ff_sc06t0750v_pffg_s300_v0830_t125_xcbccbt" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
       /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20230310/tsmc5ff*/apache/FF0960125/* \
    /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20230310/memory/int/power/apache/apl/*/*ff* \
    "
   set pvt_corner($PVT_CORNER,timing) " \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/db/tsmc5ff_tgate_mb06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/db/tsmc5ff_tgate_sc06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
        /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/db/tsmc5ff_lscore_pffg_s300_v0830_t125_o0960_xcbccbt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc5ff_sc06t0750v_pffg_s300_v0830_t000_xcbccbt" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/db/tsmc5ff_tgate_mb06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/db/tsmc5ff_tgate_sc06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
        /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/db/tsmc5ff_lscore_pffg_s300_v0830_t000_o0960_xcbccbt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER qod_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
       /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20230310/tsmc5ff*/apache/FF0960125/* \
    /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20230310/memory/int/power/apache/apl/*/*ff* \
    "
   set pvt_corner($PVT_CORNER,timing) " \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER qod_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_125_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "WCIND_WCT"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc5ff_sc06t0750v_pssg_s300_v0760_t125_xcwccwt" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
       /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20221206/tsmc5ff*/apache/SS0670125/* \
    /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20221206/memory/int/power/apache/apl/*/*ss* \
    "
   set pvt_corner($PVT_CORNER,timing) "\
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pssg_s300_v0760_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pssg_s300_v0760_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pssg_s300_v0760_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pssg_s300_v0760_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/db/tsmc5ff_tgate_mb06t0750v_pssg_s300_v0760_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/db/tsmc5ff_tgate_sc06t0750v_pssg_s300_v0760_t125_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pssg_s300_v0760_t125_xcwccwt.lib.gz \
        /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/db/tsmc5ff_lscore_pssg_s300_v0760_t125_o0670_xcwccwt.lib.gz \
      "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_minT_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "WCIND_WCT"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc5ff_sc06t0750v_pssg_s300_v0760_t000_xcwccwt" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pssg_s300_v0760_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pssg_s300_v0760_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pssg_s300_v0760_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pssg_s300_v0760_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/db/tsmc5ff_tgate_mb06t0750v_pssg_s300_v0760_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/db/tsmc5ff_tgate_sc06t0750v_pssg_s300_v0760_t000_xcwccwt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pssg_s300_v0760_t000_xcwccwt.lib.gz \
        /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/db/tsmc5ff_lscore_pssg_s300_v0760_t000_o0670_xcwccwt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc5ff_sc06t0750v_pffg_s300_v0960_t125_xcbccbt" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
       /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20221206/tsmc5ff*/apache/FF0960125/* \
    /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20221206/memory/int/power/apache/apl/*/*ff* \
    "
   set pvt_corner($PVT_CORNER,timing) " \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pffg_s300_v0960_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pffg_s300_v0960_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pffg_s300_v0960_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pffg_s300_v0960_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/db/tsmc5ff_tgate_mb06t0750v_pffg_s300_v0960_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/db/tsmc5ff_tgate_sc06t0750v_pffg_s300_v0960_t125_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pffg_s300_v0960_t125_xcbccbt.lib.gz \
        /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/db/tsmc5ff_lscore_pffg_s300_v0960_t125_o0830_xcbccbt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc5ff_sc06t0750v_pffg_s300_v0960_t000_xcbccbt" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pffg_s300_v0960_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pffg_s300_v0960_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pffg_s300_v0960_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pffg_s300_v0960_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_mb06t0750v/db/tsmc5ff_tgate_mb06t0750v_pffg_s300_v0960_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_tgate_sc06t0750v/db/tsmc5ff_tgate_sc06t0750v_pffg_s300_v0960_t000_xcbccbt.lib.gz \
	/ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pffg_s300_v0960_t000_xcbccbt.lib.gz \
        /ex-project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/FN_04122024/tsmc5ff_lscore/db/tsmc5ff_lscore_pffg_s300_v0960_t000_o0830_xcbccbt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#################################################################################################################################################################################################
###    design setting 
#################################################################################################################################################################################################
set DEFAULT_SITE CORE_6
if {![info exists MAX_ROUTING_LAYER]} {set MAX_ROUTING_LAYER 16}
if {![info exists MIN_ROUTING_LAYER]} {set MIN_ROUTING_LAYER 2}

# TODO: Add supply voltage per net
set PWR_NET     [list VDD]
set GND_NET     [list VSS]
set PWR_PINS    [list VDD VDDB VDDF]
set GND_PINS    [list VSS VSSB]

if { ![info exists env(LEC_VERSION)] && (![info exists DEF_FILE] || $DEF_FILE == "None") && (  ([info exists PYISICAL_SYN] && $PYISICAL_SYN == "true")  || ( ![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "innovus") ) } {
    
    if { [info exists FE_MODE] && $FE_MODE } {
        set DEF_FILE "./${DESIGN_NAME}_floorplan.def.gz"    
    } elseif { ![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "innovus" && [file exists ./out/def/${DESIGN_NAME}.floorplan.def.gz] } { 
        set DEF_FILE ./out/def/${DESIGN_NAME}.floorplan.def.gz
    } elseif { [file exists ../inter/${DESIGN_NAME}.floorplan_for_syn.def.gz] } {
        set DEF_FILE "../inter/${DESIGN_NAME}.floorplan_for_syn.def.gz"  
    } elseif { [file exists ../inter/${DESIGN_NAME}_floorplan.def.gz] } {
        set DEF_FILE "../inter/${DESIGN_NAME}_floorplan.def.gz"  
    } else {
        puts "-W- No DEF file found"
    }

}
set FP_FILE  "../inter/floorplan_constraints.tcl"   
     
set VT_GROUPS(SVT)    *F6SN*
set VT_GROUPS(LVTLL)  *F6LL*
set VT_GROUPS(LVT)    *F6LN*
set VT_GROUPS(ULVT)   *F6UN*
set VT_GROUPS(ULVTLL) *F6UL*
set VT_GROUPS(EVT)    *F6EN*
#set VT_GROUPS(LVTLL)  *LVTLL06*
#set VT_GROUPS(ULVTLL) *ULTLL06*
set leakage_pattern_priority_list "F6SN F6LL F6LN F6UL F6UN F6EN"



set DONT_SCAN_FF ""
set DONT_TOUCH_INST "*DONT_TOUCH* *i_spare* "

set SIZE_ONLY_INST "*SIZE_ONLY* \
*CKGT_par_sin_mux* \
*DAX_CKGT_PIPE_par_sin_mux* \
*DAX_CKGT_PIPE_par_sout_mux* \
*DAX_TAP_PIPE_par_sin_mux* \
*DAX_TAP_PIPE_par_sout_mux* \
*DAX_DAX_par_sin_mux* \
*JTAGMUXD_par_sin_mux* \
*MUXD_par_sin_mux* \
*MUXD_domscan_mux* \
*EDTMUX* \
*TEST__EDT_COMPRESSOR* \
*DAXMUX* \
*TEST__DAX_COMPRESSOR* \
*CKGTST_PROTOTYPE* \
*TEST__CKGT_*_FLOP \
*i*_AND*_SIG 
*TEST__KILL_CLOCKS_inv_and* \
*tessent* \
*REV_TAG* \
"

set DONT_USE_CELLS " \
  F6*_LCAP* \
  F6*BSDFFM* \
  F6*SDFFM* \
  F6*BDLATR* \
  F6*_DLAT* \
  F6*SYNC* \
  F6*_BDFF* \
  F6*_TRI* \
  F6*_BSDFFRAND2X* \
  F6*INVX2 \
  F6*X48 \
  F6*X40 \
  F6*_BDLATX* \
  F6*_BDLATN* \
  F6*_CK* \
  F6*DLY* \
  F6*CDM* \
  F6*RESYNC* \
  F6*_CKENNOOX* \
  F6*_DFF* \
  F6*_SDFF* \
  F6*_BDFF* \
  F6*LPD* \
  F6*_TOP* \
  F6*_AO2222VAX2 \
  F6*_AO2222X6 \
  F6*_FANCR2X2 \
  F6*_FANCRSX2 \
  F6S* \
  F6*G_* \
  *BSDFFAO22* \
"

#  F6*_BSDFF*W* \

if {[info exists STAGE] && $STAGE=="syn"} {
  puts "-I- DONT_USE_CELLS: physical variants"
  set DONT_USE_CELLS " $DONT_USE_CELLS \
    F6*BA_* \
    F6*CA_* \
    F6*DA_* \
  "

}

if {[info exists MBIT] && $MBIT == "false"} {
  puts "-I- DONT_USE_CELLS: Run without MBIT cells"
  set DONT_USE_CELLS " $DONT_USE_CELLS \
    F6*BSDFFRW2* \
    F6*BSDFFRW2* \
    F6*BSDFFRW4* \
    F6*BSDFFRW8* \
    F6*BSDFFW2* \
    F6*BSDFFW4* \
    *BSDFFCW4* \
    F6*BSDFFCW2* \
  "
} 

if { ![info exists VT_EFFORT] || $VT_EFFORT == "low" } {
  puts "-I- DONT_USE_CELLS: Run without ULVT and ULVTLL cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
  F6*UN* \
  F6*UL* \
  F6EN* \
  "
} elseif { $VT_EFFORT == "medium" } {
  puts "-I- DONT_USE_CELLS: Run without ULVT  cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
  F6*UN* \
  F6EN* \
  "
} elseif { $VT_EFFORT == "high" } {
  puts "-I- DONT_USE_CELLS: Run with ULVT and ULVTLL cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
  F6EN* \
  "
} elseif { $VT_EFFORT == "extreme" } {
  puts "-I- DO_USE_CELLS: Run with EVT "

} else {
  puts "-E- DONT_USE_CELLS: VT_EFFORT must be low, medium or high!"
  exit 
}

puts "-I- DONT_USE_CELLS: Full list - "
puts [join [split [regsub -all " +" $DONT_USE_CELLS " "] " "] "\n"]

set DO_USE_CELLS " \
F6UNAA_CKENOAX4 \
F6UNAA_CKENOAX8 \
F6UNAA_LPDCKENAOAX12 \
F6UNAA_LPDCKENAOAX8 \
F6UNAA_LPDCKENOAX8 \
F6UNAA_LPDCKENOAX10 \
F6UNAA_LPDCKENOAX12 \
F6UNAA_LPDCKENOAX14 \
F6UNAA_LPDCKENOAX16 \
"

if {[info exists TGATE] && $TGATE == "true"} {
puts "-I remove TGATE flops from DONT_USE_CELLS" 
#regsub {F6\*_DFF\*} $DONT_USE_CELLS "" DONT_USE_CELLS
regsub {F6\*_SDFF\*} $DONT_USE_CELLS "" DONT_USE_CELLS

}
if {[info exists LATCH] && $LATCH == "true"} {
puts "-I remove TGATE flops from DONT_USE_CELLS" 
regsub {F\6*_BDLATX\*} $DONT_USE_CELLS "" DONT_USE_CELLS
regsub {F\6*_BDLATN\*} $DONT_USE_CELLS "" DONT_USE_CELLS
}

#################################################################################################################################################################################################
###    place setting 
#################################################################################################################################################################################################
set IOBUFFER_CELL "F6LLAA_BUFX12"
set USEABLE_IOBUFFER_CELL {F6LLAA_BUFX10 F6LLAA_BUFX12 F6LLAA_BUFX16 F6LLAA_BUFX18 F6LLAA_BUFX8 F6LNAA_BUFX10 F6LNAA_BUFX12 F6LNAA_BUFX16 F6LNAA_BUFX18 F6LNAA_BUFX8 F6SNAA_BUFX10 F6SNAA_BUFX12 F6SNAA_BUFX16 F6SNAA_BUFX18 F6SNAA_BUFX8 F6ULAA_BUFX10 F6ULAA_BUFX12 F6ULAA_BUFX16 F6ULAA_BUFX18 F6ULAA_BUFX8 F6UNAA_BUFX10 F6UNAA_BUFX12 F6UNAA_BUFX16 F6UNAA_BUFX18 F6UNAA_BUFX8  }
set SPARE_MODULE { \
CKLHQD4BWP240H11P57PDULVT {  1 0 } \
SDFSNQD4BWP240H11P57PDULVT {  5 0 } \
AO22D4BWP240H11P57PDULVT {  5 1 } \
BUFFD8BWP240H11P57PDULVT { 10 0 } \
MAOI22D4BWP240H11P57PDULVT {  5 1 } \
IND2D4BWP240H11P57PDULVT {  4 0 } \
INR2D4BWP240H11P57PDULVT {  4 1 } \
INVD8BWP240H11P57PDULVT { 10 0 } \
INR2D4BWP240H11P57PDULVT {  1 1 } \
MUX2D4BWP240H11P57PDULVT {  5 0 } \
IND2D4BWP240H11P57PDULVT { 10 1 } \
AN2D4BWP240H11P57PDULVT {  5 0 } \
OR2D4BWP240H11P57PDULVT {  5 1 } \
IND3D4BWP240H11P57PDULVT {  5 0 } \
INR3D4BWP240H11P57PDULVT {  5 1 } \
OA21D4BWP240H11P57PDULVT { 10 0 } \
OA22D4BWP240H11P57PDULVT {  1 1 } \
OAI21D4BWP240H11P57PDULVT {  5 0 } \
XNR2D4BWP240H11P57PDULVT {  5 1 }} 

#################################################################################################################################################################################################
###    floorplan setting 
#################################################################################################################################################################################################
set DIFFUSION_FORBIDDEN_SPACING 0.277 

#set ENDCAPS(TOP_EDGE)             {F6LLAA_BORDERROWPGAP F6LLAA_BORDERROWP8 F6LLAA_BORDERROWP4 F6LLAA_BORDERROWP2 F6LLAA_BORDERROWP16 F6LLAA_BORDERROWP1}

#set ENDCAPS(BOTTOM_EDGE)         {F6LLAA_BORDERROWPGAP F6LLAA_BORDERROWP8 F6LLAA_BORDERROWP4 F6LLAA_BORDERROWP2 F6LLAA_BORDERROWP16 F6LLAA_BORDERROWP1}
set ENDCAPS(TOP_EDGE)         {F6LLAA_BORDERROWP16 F6LLAA_BORDERROWP8 F6LLAA_BORDERROWP4 F6LLAA_BORDERROWP2 F6LLAA_BORDERROWP1 BORDERROWPGAP}
#set ENDCAPS(LEFT_EDGE)             F6LLAA_BORDERTIESMRIGHT
set ENDCAPS(LEFT_EDGE)         F6LLAA_BORDERTIESMRIGHT
#set ENDCAPS(RIGHT_TOP_CORNER)         F6LLAA_BORDERCORNERPTIERIGHT

#set ENDCAPS(LEFT_BOTTOM_CORNER)     F6LLAA_BORDERCORNERPTIERIGHT
set ENDCAPS(LEFT_TOP_CORNER)     F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_TOP_CORNER)         F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_BOTTOM_CORNER)     F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_TOP_EDGE)         F6LLAA_BORDERCORNERINTPRIGHT
#set ENDCAPS(RIGHT_TOP_EDGE)         F6LLAA_BORDERCORNERINTPRIGHT
#set ENDCAPS(LEFT_BOTTOM_EDGE)         F6LLAA_BORDERCORNERINTPRIGHT


#set ENDCAPS(LEFT_BOTTOM_EDGE)         F6LLAA_BORDERCORNERINTPTIERIGHT
set ENDCAPS(LEFT_TOP_EDGE)         F6LLAA_BORDERCORNERINTPTIERIGHT



#set ENDCAPS(LEFT_TOP_EDGE_NEIGHBOR)     HDBSVT06_CAPBRINCGAP3    
#set ENDCAPS(RIGHT_TOP_EDGE_NEIGHBOR)     HDBSVT06_CAPBLINCGAP3    
#set ENDCAPS(LEFT_BOTTOM_EDGE_NEIGHBOR)  HDBSVT06_CAPBRINCGAP3        
#set ENDCAPS(RIGHT_BOTTOM_EDGE_NEIGHBOR) HDBSVT06_CAPBLINCGAP3        


set TAPCELL "{F6LLAA_TIESMALL rule 15.8 boundary_layer LUP_SRM boundary_rule 15.8} {F6LLAA_TIE rule 22.5}"
set SWAP_WELL_TAPS { F6LLAA_TIE }
set TIEHCELL "F6LLAA_TIEHI"
set TIELCELL "F6LLAA_TIELO"
set ANTENNA_CELL_NAME "F6LLAA_DIODEX2 F6LLAA_DIODEX3 F6LLAA_DIODEX4"

set PRE_PLACE_DECAP "F6LLAA_CCCAP16"
set PRE_PLACE_ECO_DCAP "F6LLAAG_CCCAP16"

set ECO_DCAP_LIST   "F6LNAAG_CCCAP16BY2 F6LLAAG_CCCAP16BY2 F6LNAAG_CCCAP8BY2 F6LLAAG_CCCAP8BY2 F6LNAAG_CCCAP4BY2 F6LLAAG_CCCAP4BY2 F6LNAAG_CCCAP2BY2 F6LLAAG_CCCAP2BY2 F6LNAAG_CCCAP2 F6LNAAG_CCCAP1"
set DCAP_CELLS_LIST "F6LLAA_CCCAPD64BY16 F6LLAA_CCCAPD32BY8 F6LLAA_CCCAPD16BY4 F6LLAA_CCCAPD16BY2 F6LLAA_CCCAP8BY2 F6LLAAG_CCCAP2 F6LLAA_CCCAP3"

set FILLER64_CELLS_LIST "F6UNAA_FILLER64 F6ULAA_FILLER64 F6SNAA_FILLER64 F6LNAA_FILLER64 F6LLAA_FILLER64 F6ENAA_FILLER64"
set FILLER32_CELLS_LIST "F6UNAA_FILLER32 F6ULAA_FILLER32 F6SNAA_FILLER32 F6LNAA_FILLER32 F6LLAA_FILLER32 F6ENAA_FILLER32"
set FILLER16_CELLS_LIST "F6UNAA_FILLER16 F6ULAA_FILLER16 F6SNAA_FILLER16 F6LNAA_FILLER16 F6LLAA_FILLER16 F6ENAA_FILLER16"
set FILLER12_CELLS_LIST ""
set FILLER8_CELLS_LIST  "F6UNAA_FILLER8 F6ULAA_FILLER8 F6SNAA_FILLER8 F6LNAA_FILLER8 F6LLAA_FILLER8 F6ENAA_FILLER8"
set FILLER4_CELLS_LIST  "F6UNAA_FILLER4 F6ULAA_FILLER4 F6SNAA_FILLER4 F6LNAA_FILLER4 F6LLAA_FILLER4 F6ENAA_FILLER4"
set FILLER3_CELLS_LIST  "F6UNAA_FILLER3 F6ULAA_FILLER3 F6SNAA_FILLER3 F6LNAA_FILLER3 F6LLAA_FILLER3 F6ENAA_FILLER3"
set FILLER2_CELLS_LIST  "F6UNAA_FILLER2 F6ULAA_FILLER2 F6SNAA_FILLER2 F6LNAA_FILLER2 F6LLAA_FILLER2 F6ENAA_FILLER2"
set FILLER1_CELLS_LIST  "F6UNAA_FILLER1 F6ULAA_FILLER1 F6SNAA_FILLER1 F6LNAA_FILLER1 F6LLAA_FILLER1 F6ENAA_FILLER1"

set FILLERS_CELLS_LIST "$ECO_DCAP_LIST $DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"
#set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"

set ADD_FILLERS_SWAP_CELL {{F6LLAA_FILLER1 F6LLAA_FILLER1B} {F6LNAA_FILLER1 F6LNAA_FILLER1B} {F6UNAA_FILLER1 F6UNAA_FILLER1B} {F6ENAA_FILLER1 F6ENAA_FILLER1B} {F6ULAA_FILLER1 F6ULAA_FILLER1B} {F6SNAA_FILLER1 F6SNAA_FILLER1B}}

###################################################################################################################################################################################################
###    CTS setting 
###################################################################################################################################################################################################


set CTS_BUFFER_CELLS          {F6UNAA_LPDBUFX8 F6UNAA_LPDBUFX12 F6UNAA_LPDBUFX16 }

set CTS_INVERTER_CELLS_TOP    { \
F6UNAA_LPDINVX28 \
F6UNAA_LPDINVX32 \
F6UNAA_LPDINVX36 \
}

set CTS_INVERTER_CELLS_TRUNK  { \
F6UNAA_LPDINVX16 \
F6UNAA_LPDINVX20 \
F6UNAA_LPDINVX24 \
F6UNAA_LPDINVX28 \
}

set CTS_INVERTER_CELLS_LEAF   { \
F6UNAA_LPDINVX8  \
F6UNAA_LPDINVX12 \
F6UNAA_LPDINVX16 \
F6UNAA_LPDINVX20 \
F6UNAA_LPDINVX24 \
}

set CTS_LOGIC_CELLS           {F6UNAA_CKENOAX8 F6UNAA_CKENOAX6 F6UNAA_CKENOAX4 F6UNAA_CKENOAX32 F6UNAA_CKENOAX20 F6UNAA_CKENOAX2 F6UNAA_CKENOAX16 F6UNAA_CKENOAX12 F6UNAA_CKENNOOX8 F6UNAA_CKENNOOX4 F6UNAA_CKENNOOX16 F6UNAA_CKENNOOX12 F6UNAA_CKENAOAX4 F6UNAA_BALAND2X8 F6UNAA_BALAND2X4 F6UNAA_BALAND2X2 F6UNAA_CKAND2X8 F6UNAA_CKMUX2X12 F6UNAA_CKMUX2X16 F6UNAA_CKMUX2X8 F6UNAA_CKNAND2X8 F6UNAA_CKNOR2X8 F6UNAA_CKOR2X8 F6UNAA_CKXOR2X8 }
set CTS_CLOCK_GATING_CELLS    {F6UNAA_LPDCKENOAX8 F6UNAA_LPDCKENOAX12 F6UNAA_LPDCKENOAX16 F6UNAA_LPDCKENOAX20 }
set CTS_CELLS_HALO [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]

if {![info exists CLOCK_GATING_SETUP]} {set CLOCK_GATING_SETUP 0.100 }
if {![info exists LP_CLOCK_GATING_CELL]} {set LP_CLOCK_GATING_CELL F6UNAA_LPDCKENOAX16}
if {![info exists EXCLUDE_ICG] } {set EXCLUDE_ICG ""}   ;# a list of inst name or IO/io/INPUT/input


set HOLD_FIX_CELLS_LIST [list \
*LL*A_DLY* \
*LN*A_DLY* \
*UL*A_DLY* \
] 
#################################################################################################################################################################################################
###	tools dependent
#################################################################################################################################################################################################

if {[info command set_verification_information] == "" && ![info exists ::synopsys_program_name] } {
 if {[info command distribute_partition] == "" } {
  
  if { [get_db / .program_short_name] == "genus" } {
	puts "-I- extra definition for [get_db / .program_short_name]"

	# Variables to set before loading libraries
	if {[info exists LPG] && $LPG == "false"} {
		set_db lp_insert_clock_gating               false
	} else {
		set_db lp_insert_clock_gating               true
	}
  }
  
  if { [get_db / .program_short_name] == "innovus" } {
	puts "-I- extra definition for [get_db / .program_short_name]"

	# Variables to set before loading libraries
	set_db add_route_vias_auto true ;                                       # (default : false
	set_db add_route_vias_advanced_rule true ;                              # (default : false
	set_db timing_derate_spatial_distance_unit 1nm
  }

  if { [get_db / .program_short_name] == "tempus" } {
	puts "-I- extra definition for [get_db / .program_short_name]"

	# Variables to set before loading libraries
	set_db timing_derate_spatial_distance_unit 1nm
  }
 } else {
	set_db timing_derate_spatial_distance_unit 1nm
	# Required for DSTA CUI - CCR2415003
   	set_db distributed_disable_clock_collection_client_sync 0
 }
}
#################################################################################################################################################################################################
###	done
#################################################################################################################################################################################################
puts "-I done setup file"




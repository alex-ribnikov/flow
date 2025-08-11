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
        if { [file exists ../inter/${DESIGN_NAME}.pre.sdc]  }  { append sdc_files(func) " ../inter/${DESIGN_NAME}.pre.sdc "  }
        if { [file exists ../inter/${DESIGN_NAME}.sdc]}        { append sdc_files(func) " ../inter/${DESIGN_NAME}.sdc "      }
        if { [file exists ../inter/${DESIGN_NAME}.post.sdc] }  {
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
set GDS_MAP_FILE      "/project/foundry/TSMC/N4/TBD/PDK/APR/cdns/1.0.1a/PRTF_Innovus_4nm_014_Cad_V10_1a/PR_tech/Cadence/GdsOutMap/PRTF_Innovus_N4P_gdsout_17M_1X_h_1Xb_v_1Xe_h_1Ya_v_1Yb_h_5Y_vhvhv_2Yy2Yx2R_SHDMIM.10_1a.map"
# add prboundary layer

set STREAM_LAYER_MAP_FILE /project/foundry/TSMC/N4/TBD/PDK/APR/cdns/1.0.1a/PRTF_Innovus_4nm_014_Cad_V10_1a/PR_tech/Cadence/StarDummyMap/PRTF_Innovus_N4P_dummy_17M_1X_h_1Xb_v_1Xe_h_1Ya_v_1Yb_h_5Y_vhvhv_2Yy2Yx2R_SHDMIM.10_1a.map
set TECHNOLOGY_LAYER_MAP /project/foundry/TSMC/N4/TBD/PDK/APR/cdns/1.0.1a/PRTF_Innovus_4nm_014_Cad_V10_1a/PR_tech/Cadence/StarRCMap/PRTF_Innovus_N4P_starrc_17M_1X1Xb1Xe1Ya1Yb5Y2Yy2Yx2R_SHDMIM.10_1a.map

if {![info exists ROUTE_DFM]} {set ROUTE_DFM true}
set DFM_REDUNDANT_VIA "/project/foundry/TSMC/N4/TBD/PDK/APR/cdns/1.0.1a/PRTF_Innovus_4nm_014_Cad_V10_1a/PR_tech/Cadence/script//PRTF_Innovus_N4P_DFM_via_swap_reference_command.10_1a.tcl"
set METAL_FILL_RUNSET ""
# 07022024 Royl: missing
#set TECH_APACHE "/bespace/users/royl/deliveries/from_brcm/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_typical_apache.tech"

set ICT_EM_MODELS "/project/foundry/TSMC/N4/TBD/PDK/EM/cdns/1.0.1a/cln4p_1p17m+ut-alrdl_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim.ictem"
set TECH_FILE "/project/foundry/TSMC/N4/TBD/PDK/APR/snps/1.0.1a/PRTF_ICC2_4nm_014_Syn_V10_1a/PR_tech/Synopsys/TechFile/Standard/VHV/PRTF_ICC2_N4P_17M_1X1Xb1Xe1Ya1Yb5Y2Yy2Yx2R_UTRDL_M1P38_M2P40_M3P48_M4P48_M5P76_M6P80_M7P76_M8P80_M9P76_M10P80_M11P76_H280_SHDMIM.10_1a.tf"

set TECH_LEF " \
/project/foundry/TSMC/N4/TBD/PDK/APR/cdns/1.0.1a/PRTF_Innovus_4nm_014_Cad_V10_1a/PR_tech/Cadence/LefHeader/Standard/VHV/PRTF_Innovus_N4P_17M_1X1Xb1Xe1Ya1Yb5Y2Yy2Yx2R_UTRDL_M1P38_M2P40_M3P48_M4P48_M5P76_M6P80_M7P76_M8P80_M9P76_M10P80_M11P76_H280_SHDMIM.10_1a.tlef \
"

set LEF_FILE_LIST "$TECH_LEF \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_base_elvt_100a/lef/tcbn04p_bwph280l6p57cnod_base_elvt.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_base_lvt_100a/lef/tcbn04p_bwph280l6p57cnod_base_lvt.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_mb_lvt_100a/lef/tcbn04p_bwph280l6p57cnod_mb_lvt.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_base_lvtll_100a/lef/tcbn04p_bwph280l6p57cnod_base_lvtll.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_mb_lvtll_100a/lef/tcbn04p_bwph280l6p57cnod_mb_lvtll.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_base_svt_100a/lef/tcbn04p_bwph280l6p57cnod_base_svt.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_mb_svt_100a/lef/tcbn04p_bwph280l6p57cnod_mb_svt.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_base_ulvt_100a/lef/tcbn04p_bwph280l6p57cnod_base_ulvt.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_mb_ulvt_100a/lef/tcbn04p_bwph280l6p57cnod_mb_ulvt.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_base_ulvtll_100a/lef/tcbn04p_bwph280l6p57cnod_base_ulvtll.lef \
    /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Back_End/lef/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100a/lef/tcbn04p_bwph280l6p57cnod_mb_ulvtll.lef \
"
set NDM_REFERENCE_LIBRARY ""


set LEAKAGE_CONFIG_FILE ""

set LEAKAGE_LEF_SIDE_FILES ""

set LEAKAGE_LIB_SIDE_FILES ""

set POWER_GRID_LIBRARIES ""

set STREAM_FILE_LIST ""

set SCHEMATIC_FILE_LIST ""
set CTL_FILE_LIST ""

#################################################################################################################################################################################################
###    RC view
#################################################################################################################################################################################################
set rc_corner(gpd_file) "$GPD_DIR/out/gpd/${DESIGN_NAME}.${STAGE}.HIER.gpd"

set rc_corner(c_wc_cc_wc_T)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/cdns/1.0.1a/QRC/cworst/Tech/cworst_CCworst_T/qrcTechFile"
set rc_corner(c_wc_cc_wc_T,nxtgrd)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/snps/1.0.1a/StarRC/cworst/Tech/cworst_CCworst_T/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_cworst_CCworst_T.nxtgrd"
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

set rc_corner(c_wc_cc_wc)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/cdns/1.0.1a/QRC/cworst/Tech/cworst_CCworst/qrcTechFile"
set rc_corner(c_wc_cc_wc,nxtgrd)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/snps/1.0.1a/StarRC/cworst/Tech/cworst_CCworst/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_cworst_CCworst.nxtgrd"
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

set rc_corner(rc_wc_cc_wc)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/cdns/1.0.1a/QRC/rcworst/Tech/rcworst_CCworst/qrcTechFile"
set rc_corner(rc_wc_cc_wc,nxtgrd)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/snps/1.0.1a/StarRC/rcworst/Tech/rcworst_CCworst/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_rcworst_CCworst.nxtgrd"
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

set rc_corner(rc_wc_cc_wc_T)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/cdns/1.0.1a/QRC/rcworst/Tech/rcworst_CCworst_T/qrcTechFile"
set rc_corner(rc_wc_cc_wc_T,nxtgrd)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/snps/1.0.1a/StarRC/rcworst/Tech/rcworst_CCworst_T/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_rcworst_CCworst_T.nxtgrd"
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

set rc_corner(c_bc_cc_bc)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/cdns/1.0.1a/QRC/cbest/Tech/cbest_CCbest/qrcTechFile"
set rc_corner(c_bc_cc_bc,nxtgrd)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/snps/1.0.1a/StarRC/cbest/Tech/cbest_CCbest/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_cbest_CCbest.nxtgrd"
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

set rc_corner(rc_bc_cc_bc)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/cdns/1.0.1a/QRC/rcbest/Tech/rcbest_CCbest/qrcTechFile"
set rc_corner(rc_bc_cc_bc,nxtgrd)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/snps/1.0.1a/StarRC/rcbest/Tech/rcbest_CCbest/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_rcbest_CCbest.nxtgrd"
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

set rc_corner(typical)  "/project/foundry/TSMC/N4/TBD/PDK/Extraction/cdns/1.0.1a/QRC/typical/Tech/typical/qrcTechFile"
set rc_corner(typical,nxtgrd) "/project/foundry/TSMC/N4/TBD/PDK/Extraction/snps/1.0.1a/StarRC/typical/Tech/typical/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_typical.nxtgrd"
set rc_corner(typical,rc_variation) 0.1
set rc_corner(typical,spef_25) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.typical_25.gz"
set rc_corner(typical,spef_85) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.typical_85.gz"


#################################################################################################################################################################################################
###    timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ssgnp_0p675v_125c_cworst_CCworst_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ssgnp_0p675v_0c_cworst_CCworst_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p825v_125c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) " \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
   "
   
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p825v_0c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER qod_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p88v_125c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) " \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER qod_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p88v_0c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_125_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ssgnp_0p765v_125c_cworst_CCworst_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_minT_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ssgnp_0p765v_0c_cworst_CCworst_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p935v_125c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) " \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p935v_0c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_elvt_100b/tcbn04p_bwph280l6p57cnod_base_elvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvt_100b/tcbn04p_bwph280l6p57cnod_base_lvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_lvtll_100b/tcbn04p_bwph280l6p57cnod_base_lvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_svt_100b/tcbn04p_bwph280l6p57cnod_base_svtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvt_100b/tcbn04p_bwph280l6p57cnod_base_ulvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_base_ulvtll_100b/tcbn04p_bwph280l6p57cnod_base_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvt_100b/tcbn04p_bwph280l6p57cnod_mb_lvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/lvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_lvtll_100b/tcbn04p_bwph280l6p57cnod_mb_lvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/svt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_svt_100b/tcbn04p_bwph280l6p57cnod_mb_svtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvt_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/mb/ulvtll/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn04p_bwph280l6p57cnod_mb_ulvtll_100b/tcbn04p_bwph280l6p57cnod_mb_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N4/TBD/IP/STD/TSMC/tcbn04p_bwph280l6p57cnod/H280/base/elvt/100b/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n04_wire.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#################################################################################################################################################################################################
###    design setting 
#################################################################################################################################################################################################
set DEFAULT_SITE coreW57H280
if {![info exists MAX_ROUTING_LAYER]} {set MAX_ROUTING_LAYER 16}
if {![info exists MIN_ROUTING_LAYER]} {set MIN_ROUTING_LAYER 2}

# TODO: Add supply voltage per net
set PWR_NET     [list VDD]
set GND_NET     [list VSS]
set PWR_PINS    [list VDD VPP VDDF]
set GND_PINS    [list VSS VBB]

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
     
set VT_GROUPS(SVT)    *CNODSVT
set VT_GROUPS(LVTLL)  *CNODLVTLL
set VT_GROUPS(LVT)    *CNODLVT
set VT_GROUPS(ULVT)   *CNODULVT
set VT_GROUPS(ULVTLL) *CNODULVTLL
set VT_GROUPS(EVT)    *CNODELVT
set leakage_pattern_priority_list "SVT LVTLL LVT ULVTLL ULVT EVT"



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
  G* \
  DF* \
  MB8* \
  MB6* \
  LN* \
  BUFT* \
  *CNODSVT \
  *D20* \
  *D24* \
  *D28* \
  *D32* \
  *D36* \
"

#  F6*_BSDFF*W* \

if {[info exists STAGE] && $STAGE=="syn"} {
  puts "-I- DONT_USE_CELLS: physical variants"
  set DONT_USE_CELLS " $DONT_USE_CELLS"

}

if {[info exists MBIT] && $MBIT == "false"} {
  puts "-I- DONT_USE_CELLS: Run without MBIT cells"
  set DONT_USE_CELLS " $DONT_USE_CELLS \
     MB* \
  "
} 

if { ![info exists VT_EFFORT] || $VT_EFFORT == "low" } {
   puts "-I- DONT_USE_CELLS: Run without ULVT and ULVTLL cells"
   set DONT_USE_CELLS "$DONT_USE_CELLS \
      *CNODULVT
      *CNODULVTLL
      *CNODELVT
   "
} elseif { $VT_EFFORT == "medium" } {
  puts "-I- DONT_USE_CELLS: Run without ULVT  cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
      *CNODULVT
      *CNODELVT
  "
} elseif { $VT_EFFORT == "high" } {
  puts "-I- DONT_USE_CELLS: Run with ULVT and ULVTLL cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
      *CNODELVT
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
   CKLNQKBD8BWP280H6P57CNODULVT \
   CKLNQKBD6BWP280H6P57CNODULVT \
   CKLNQOPTBBKBD10BWP280H6P57CNODULVT \
   CKLNQOPTBBKBD12BWP280H6P57CNODULVT \
   CKLNQOPTBBKBD14BWP280H6P57CNODULVT \
   CKLNQOPTBBKBD16BWP280H6P57CNODULVT \
   CKLNQOPTBBKBD8BWP280H6P57CNODULVT \
   
"

if {[info exists TGATE] && $TGATE == "true"} {
puts "-I remove TGATE flops from DONT_USE_CELLS" 
#regsub {F6\*_DFF\*} $DONT_USE_CELLS "" DONT_USE_CELLS
#regsub {F6\*_SDFF\*} $DONT_USE_CELLS "" DONT_USE_CELLS

}
if {[info exists LATCH] && $LATCH == "true"} {
   puts "-I remove LATCH flops from DONT_USE_CELLS" 
   regsub {LN*} $DONT_USE_CELLS "" DONT_USE_CELLS
}

#################################################################################################################################################################################################
###    place setting 
#################################################################################################################################################################################################
set IOBUFFER_CELL "BUFFKBD8BWP280H6P57CNODLVT"
set USEABLE_IOBUFFER_CELL {BUFFKBD10BWP280H6P57CNODULVT BUFFKBD10BWP280H6P57CNODLVT BUFFKBD12BWP280H6P57CNODULVT BUFFKBD12BWP280H6P57CNODLVT BUFFKBD6BWP280H6P57CNODULVT BUFFKBD6BWP280H6P57CNODLVT BUFFKBD8BWP280H6P57CNODULVT BUFFKBD8BWP280H6P57CNODLVT}
set SPARE_MODULE { \
CKLHQKBD4BWP280H6P57CNODULVT {  1 0 } \
SDFSNQKBD4BWP280H6P57CNODULVT {  5 0 } \
AO22KBD4BWP280H6P57CNODULVT {  5 1 } \
BUFFKBD8BWP280H6P57CNODLVT { 10 0 } \
MAOI22KBD4BWP280H6P57CNODULVT {  5 1 } \
IND2KBD4BWP280H6P57CNODULVT {  4 0 } \
INR2KBD4BWP280H6P57CNODULVT {  4 1 } \
INVKBD8BWP280H6P57CNODULVT { 10 0 } \
MUX2KBD4BWP280H6P57CNODULVT {  5 0 } \
AN2KBD4BWP280H6P57CNODULVT {  5 0 } \
OR2KBD4BWP280H6P57CNODULVT {  5 1 } \
IND3KBD4BWP280H6P57CNODULVT {  5 0 } \
INR3KBD4BWP280H6P57CNODULVT {  5 1 } \
OA21KBD4BWP280H6P57CNODULVT { 10 0 } \
OA22KBD4BWP280H6P57CNODULVT {  1 1 } \
OAI21KBD4BWP280H6P57CNODULVT {  5 0 } \
XNR2KBD4BWP280H6P57CNODULVT {  5 1 } \
} 

#################################################################################################################################################################################################
###    floorplan setting 
#################################################################################################################################################################################################
set DIFFUSION_FORBIDDEN_SPACING 0.277 

set ENDCAPS(RIGHT_EDGE)                 {BOUNDARYLEFTKBBWP280H6P57CNODLVT BOUNDARYLEFTCWKBBWP280H6P57CNODLVT}
set ENDCAPS(LEFT_EDGE)                  {BOUNDARYRIGHTKBBWP280H6P57CNODLVT BOUNDARYRIGHTCWKBBWP280H6P57CNODLVT}
set ENDCAPS(LEFT_TOP_CORNER)            {BOUNDARYPCORNERKBBWP280H6P57CNODLVT BOUNDARYPCORNERCWKBBWP280H6P57CNODLVT}
set ENDCAPS(LEFT_BOTTOM_CORNER)         {BOUNDARYPCORNERKBBWP280H6P57CNODLVT BOUNDARYPCORNERCWKBBWP280H6P57CNODLVT}
set ENDCAPS(TOP_EDGE)                   {BOUNDARYPROW8KBBWP280H6P57CNODLVT BOUNDARYPROW4KBBWP280H6P57CNODLVT BOUNDARYPROW2KBBWP280H6P57CNODLVT BOUNDARYPROW1KBBWP280H6P57CNODLVT}
set ENDCAPS(BOTTOM_EDGE)                {BOUNDARYPROW8KBBWP280H6P57CNODLVT BOUNDARYPROW4KBBWP280H6P57CNODLVT BOUNDARYPROW2KBBWP280H6P57CNODLVT BOUNDARYPROW1KBBWP280H6P57CNODLVT}
set ENDCAPS(RIGHT_TOP_EDGE)             {BOUNDARYPINCORNERKBBWP280H6P57CNODLVT BOUNDARYPINCORNERCWKBBWP280H6P57CNODLVT}
set ENDCAPS(RIGHT_BOTTOM_EDGE)          {BOUNDARYPINCORNERKBBWP280H6P57CNODLVT BOUNDARYPINCORNERCWKBBWP280H6P57CNODLVT}
set ENDCAPS(RIGHT_TOP_EDGE_NEIGHBOR)    {BOUNDARYPROWRGAPKBBWP280H6P57CNODLVT}
set ENDCAPS(RIGHT_BOTTOM_EDGE_NEIGHBOR) {BOUNDARYPROWRGAPKBBWP280H6P57CNODLVT}


set TAPCELL "{TAPCELLFIN9KBBWP280H6P57CNODLVT rule 15.8 boundary_layer LUP_SRM boundary_rule 15.8} {TAPCELLKBBWP280H6P57CNODLVT rule 22.5}"
set SWAP_WELL_TAPS {}
set TIEHCELL "TIEHXPKBBWP280H6P57CNODLVT"
set TIELCELL "TIELXNKBBWP280H6P57CNODLVT"
set ANTENNA_CELL_NAME "ANTENNAKBBWP280H6P57CNODLVT "

set PRE_PLACE_DECAP "DCAP16XPKBBWP280H6P57CNODLVTLL"
set PRE_PLACE_ECO_DCAP "GDCAP9SHXPKBBWP280H6P57CNODLVT"

set ECO_DCAP_LIST   "GDCAP11SHXPKBBWP280H6P57CNODLVT GDCAP12SHXPKBBWP280H6P57CNODLVT GDCAP1SHXPKBBWP280H6P57CNODLVT GDCAP2DHXPKBBWP280H6P57CNODLVT GDCAP2SHXPKBBWP280H6P57CNODLVT GDCAP3SHXPKBBWP280H6P57CNODLVT GDCAP4SHXPKBBWP280H6P57CNODLVT GDCAP5DHXPKBBWP280H6P57CNODLVT GDCAP5SHXPKBBWP280H6P57CNODLVT GDCAP6DHXPKBBWP280H6P57CNODLVT GDCAP6SHXPKBBWP280H6P57CNODLVT GDCAP7DHXPKBBWP280H6P57CNODLVT GDCAP8SHXPKBBWP280H6P57CNODLVT GDCAP9SHXPKBBWP280H6P57CNODLVT"
set DCAP_CELLS_LIST "DCAP64XPKBBWP280H6P57CNODLVTLL DCAP32XPKBBWP280H6P57CNODLVTLL DCAP16XPKBBWP280H6P57CNODLVTLL DCAP8XPKBBWP280H6P57CNODLVTLL DCAP4XPKBBWP280H6P57CNODLVTLL"

set FILLER64_CELLS_LIST "FILL64KBBWP280H6P57CNODULVT FILL64KBBWP280H6P57CNODULVTLL FILL64KBBWP280H6P57CNODLVT FILL64KBBWP280H6P57CNODLVTLL "
set FILLER32_CELLS_LIST "FILL32KBBWP280H6P57CNODULVT FILL32KBBWP280H6P57CNODULVTLL FILL32KBBWP280H6P57CNODLVT FILL32KBBWP280H6P57CNODLVTLL "
set FILLER16_CELLS_LIST "FILL16KBBWP280H6P57CNODULVT FILL16KBBWP280H6P57CNODULVTLL FILL16KBBWP280H6P57CNODLVT FILL16KBBWP280H6P57CNODLVTLL "
set FILLER12_CELLS_LIST "FILL12KBBWP280H6P57CNODULVT FILL12KBBWP280H6P57CNODULVTLL FILL12KBBWP280H6P57CNODLVT FILL12KBBWP280H6P57CNODLVTLL "
set FILLER8_CELLS_LIST  "FILL8KBBWP280H6P57CNODULVT FILL8KBBWP280H6P57CNODULVTLL FILL8KBBWP280H6P57CNODLVT FILL8KBBWP280H6P57CNODLVTLL "
set FILLER4_CELLS_LIST  "FILL4KBBWP280H6P57CNODULVT FILL4KBBWP280H6P57CNODULVTLL FILL4KBBWP280H6P57CNODLVT FILL4KBBWP280H6P57CNODLVTLL"
set FILLER3_CELLS_LIST  "FILL3KBBWP280H6P57CNODULVT FILL3KBBWP280H6P57CNODULVTLL FILL3KBBWP280H6P57CNODLVT FILL3KBBWP280H6P57CNODLVTLL"
set FILLER2_CELLS_LIST  "FILL2KBBWP280H6P57CNODULVT FILL2KBBWP280H6P57CNODULVTLL FILL2KBBWP280H6P57CNODLVT FILL2KBBWP280H6P57CNODLVTLL"
set FILLER1_CELLS_LIST  "FILL1KBBWP280H6P57CNODULVT FILL1KBBWP280H6P57CNODULVTLL FILL1KBBWP280H6P57CNODLVT FILL1KBBWP280H6P57CNODLVTLL"

set FILLERS_CELLS_LIST "$ECO_DCAP_LIST $DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"
#set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"

set ADD_FILLERS_SWAP_CELL {{FILL1KBBWP280H6P57CNODULVT FILL1NOBCMKBBWP280H6P57CNODULVT} {FILL1KBBWP280H6P57CNODULVTLL FILL1NOBCMKBBWP280H6P57CNODULVTLL} {FILL1KBBWP280H6P57CNODLVT FILL1NOBCMKBBWP280H6P57CNODLVT} {FILL1KBBWP280H6P57CNODLVTLL FILL1NOBCMKBBWP280H6P57CNODLVTLL}}

###################################################################################################################################################################################################
###    CTS setting 
###################################################################################################################################################################################################


set CLK_CELLS_PREFIX 		DCCK
set CTS_BUFFER_CELLS          {DCCKB*D8*ULVT DCCKB*D12*ULVT DCCKB*D16*ULVT }

set CTS_INVERTER_CELLS_TOP    { \
DCCKN*D12*ULVT \
DCCKN*D16*ULVT \
DCCKN*D18*ULVT \
DCCKN*D20*ULVT \
}

set CTS_INVERTER_CELLS_TRUNK  { \
DCCKN*D8*ULVT \
DCCKN*D12*ULVT \
DCCKN*D16*ULVT \
}

set CTS_INVERTER_CELLS_LEAF   { \
DCCKN*D8*ULVT \
DCCKN*D12*ULVT \
DCCKN*D16*ULVT\
}

set CTS_LOGIC_CELLS           {}
set CTS_CLOCK_GATING_CELLS    {CKLNQ*D5*ULVT  CKLNQ*D6*ULVT CKLNQ*D8*ULVT}
set CTS_CELLS_HALO [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]

if {![info exists CLOCK_GATING_SETUP]} {set CLOCK_GATING_SETUP 0.100 }
if {![info exists LP_CLOCK_GATING_CELL]} {set LP_CLOCK_GATING_CELL CKLNQKBD8BWP280H6P57CNODULVT }
if {![info exists EXCLUDE_ICG] } {set EXCLUDE_ICG ""}   ;# a list of inst name or IO/io/INPUT/input


set HOLD_FIX_CELLS_LIST [list \
DEL* \
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




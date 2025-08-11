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

## 04/02/2024 Royl :no QOD corner
#set scenarios(setup) "func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_rc_bc_cc_bc_setup"
#set scenarios(hold) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold func_qod_125_LIBRARY_FF_rc_bc_cc_bc_hold func_qod_125_LIBRARY_FF_rc_wc_cc_wc_T_hold func_qod_minT_LIBRARY_FF_c_bc_cc_bc_hold func_qod_minT_LIBRARY_FF_rc_bc_cc_bc_hold func_qod_minT_LIBRARY_FF_rc_wc_cc_wc_T_hold func_qod_125_LIBRARY_FF_rc_wc_cc_wc_hold"
#set scenarios(dynamic) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
#set scenarios(leakage) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"

set scenarios(setup) "func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_rc_bc_cc_bc_setup"
set scenarios(hold) "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold func_no_od_125_LIBRARY_FF_rc_bc_cc_bc_hold func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_T_hold func_no_od_minT_LIBRARY_FF_c_bc_cc_bc_hold func_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold func_no_od_minT_LIBRARY_FF_rc_wc_cc_wc_T_hold func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold"
set scenarios(dynamic) "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
set scenarios(leakage) "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"

set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]

## 04/02/2024 Royl :no QOD corner
#set AC_LIMIT_SCENARIOS "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
#set DEFAULT_SETUP_VIEW func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup
#set DEFAULT_CCOPT_VIEW func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup
#set DEFAULT_HOLD_VIEW  func_qod_minT_LIBRARY_FF_rc_bc_cc_bc_hold

set AC_LIMIT_SCENARIOS "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
set DEFAULT_SETUP_VIEW func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup
set DEFAULT_CCOPT_VIEW func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup
set DEFAULT_HOLD_VIEW  func_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold

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
## 04/02/2024 Royl :no QOD corner
#        set scenarios(hold)    "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
#        set scenarios(dynamic) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
#        set scenarios(leakage) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
    
        set scenarios(hold)    "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
        set scenarios(dynamic) "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
        set scenarios(leakage) "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
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
set GDS_MAP_FILE      "/project/foundry/TSMC/N3/TBD/PDK/APR/cdns/1.1.1b/PRTF_Innovus_3nm_014_Cad_V11_1b/PR_tech/Cadence/GdsOutMap/PRTF_Innovus_N3E_gdsout_17M_1Xa_h_1Xb_v_1Xc_h_1Xd_v_1Ya_h_1Yb_v_6Y_hvhvhv_2Yy2R_SHDMIM.11_1b.map"
# add prboundary layer

set STREAM_LAYER_MAP_FILE "/project/foundry/TSMC/N3/TBD/PDK/APR/cdns/1.1.1b/PRTF_Innovus_3nm_014_Cad_V11_1b/PR_tech/Cadence/StarDummyMap/PRTF_Innovus_N3E_dummy_17M_1Xa_h_1Xb_v_1Xc_h_1Xd_v_1Ya_h_1Yb_v_6Y_hvhvhv_2Yy2R_SHDMIM.11_1b.map"
set TECHNOLOGY_LAYER_MAP ""

if {![info exists ROUTE_DFM]} {set ROUTE_DFM true}
set DFM_REDUNDANT_VIA "/project/foundry/TSMC/N3/TBD/PDK/APR/cdns/1.1.1b/PRTF_Innovus_3nm_014_Cad_V11_1b/PR_tech/Cadence/script/PRTF_Innovus_N3E_run_DFM_swap.11_1b.tcl"
set METAL_FILL_RUNSET "/project/foundry/TSMC/N3/TBD/PDK/APR/cdns/1.1.1b/PRTF_Innovus_3nm_014_Cad_V11_1b/PR_tech/Cadence/StarRCMap/PRTF_Innovus_N3E_starrc_17M_1Xa1Xb1Xc1Xd1Ya1Yb6Y2Yy2R_SHDMIM.11_1b.map"
# 07022024 Royl: missing
#set TECH_APACHE "/bespace/users/royl/deliveries/from_brcm/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_typical_apache.tech"

set ICT_EM_MODELS "/project/foundry/TSMC/N3/TBD/PDK/APR/snps/1.1.1a/PRTF_ICC2_3nm_014_Syn_V11_1a/PR_tech/Synopsys/TechFile/Standard/VHV/PRTF_ICC2_N3E_17M_1Xa1Xb1Xc1Xd1Ya1Yb6Y2Yy2R_UTRDL_M1P54_M2P34_M3P40_M4P42_M5P66_M6P76_M7P80_M8P76_M9P80_M10P76_M11P80_M12P76_M13P80_H169_SHDMIM.11_1a.tf"
set TECH_FILE ""

set TECH_LEF "/project/foundry/TSMC/N3/TBD/PDK/APR/cdns/1.1.1b/PRTF_Innovus_3nm_014_Cad_V11_1b/PR_tech/Cadence/LefHeader/Standard/VHV/PRTF_Innovus_N3E_17M_1Xa1Xb1Xc1Xd1Ya1Yb6Y2Yy2R_UTRDL_M1P54_M2P34_M3P40_M4P42_M5P66_M6P76_M7P80_M8P76_M9P80_M10P76_M11P80_M12P76_M13P80_H169_SHDMIM.11_1b.tlef"

set LEF_FILE_LIST "$TECH_LEF \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/lef/tcbn03e_bwph169l3p54cpd_mb_ulvtll.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base2_elvt_100a/lef/tcbn03e_bwph169l3p54cpd_base2_elvt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base_elvt_110b/lef/tcbn03e_bwph169l3p54cpd_base_elvt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base2_lvt_100a/lef/tcbn03e_bwph169l3p54cpd_base2_lvt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base_lvt_110b/lef/tcbn03e_bwph169l3p54cpd_base_lvt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base2_lvtll_100a/lef/tcbn03e_bwph169l3p54cpd_base2_lvtll.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/lef/tcbn03e_bwph169l3p54cpd_base_lvtll.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base2_svt_100a/lef/tcbn03e_bwph169l3p54cpd_base2_svt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base_svt_110b/lef/tcbn03e_bwph169l3p54cpd_base_svt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base2_ulvt_100a/lef/tcbn03e_bwph169l3p54cpd_base2_ulvt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/lef/tcbn03e_bwph169l3p54cpd_base_ulvt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base2_ulvtll_100a/lef/tcbn03e_bwph169l3p54cpd_base2_ulvtll.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/lef/tcbn03e_bwph169l3p54cpd_base_ulvtll.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/lef/tcbn03e_bwph169l3p54cpd_mb_elvt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/lef/tcbn03e_bwph169l3p54cpd_mb_lvt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/lef/tcbn03e_bwph169l3p54cpd_mb_lvtll.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_mb_svt_110b/lef/tcbn03e_bwph169l3p54cpd_mb_svt.lef \
    /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Back_End/lef/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/lef/tcbn03e_bwph169l3p54cpd_mb_ulvt.lef \
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

set rc_corner(c_wc_cc_wc_T)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/cdns/1_1p1/cworst/Tech/cworst_CCworst_T/qrcTechFile"
set rc_corner(c_wc_cc_wc_T,nxtgrd)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/snps/1_1p1/cworst/Tech/cworst_CCworst_T/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_cworst_CCworst_T.nxtgrd"
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

set rc_corner(c_wc_cc_wc)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/cdns/1_1p1/cworst/Tech/cworst_CCworst/qrcTechFile"
set rc_corner(c_wc_cc_wc,nxtgrd)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/snps/1_1p1/cworst/Tech/cworst_CCworst/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_cworst_CCworst.nxtgrd"
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

set rc_corner(rc_wc_cc_wc)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/cdns/1_1p1/rcworst/Tech/rcworst_CCworst/qrcTechFile"
set rc_corner(rc_wc_cc_wc,nxtgrd)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/snps/1_1p1/rcworst/Tech/rcworst_CCworst/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_rcworst_CCworst.nxtgrd"
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

set rc_corner(rc_wc_cc_wc_T)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/cdns/1_1p1/rcworst/Tech/rcworst_CCworst_T/qrcTechFile"
set rc_corner(rc_wc_cc_wc_T,nxtgrd)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/snps/1_1p1/rcworst/Tech/rcworst_CCworst_T/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_rcworst_CCworst_T.nxtgrd"
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

set rc_corner(c_bc_cc_bc)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/cdns/1_1p1/cbest/Tech/cbest_CCbest/qrcTechFile"
set rc_corner(c_bc_cc_bc,nxtgrd)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/snps/1_1p1/cbest/Tech/cbest_CCbest/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_cbest_CCbest.nxtgrd"
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

set rc_corner(rc_bc_cc_bc)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/cdns/1_1p1/rcbest/Tech/rcbest_CCbest/qrcTechFile"
set rc_corner(rc_bc_cc_bc,nxtgrd)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/snps/1_1p1/rcbest/Tech/rcbest_CCbest/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_rcbest_CCbest.nxtgrd"
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

set rc_corner(typical)  "/project/foundry/TSMC/N3/TBD/PDK/Extraction/cdns/1_1p1/typical/Tech/typical/qrcTechFile"
set rc_corner(typical,nxtgrd) "/project/foundry/TSMC/N3/TBD/PDK/Extraction/snps/1_1p1/typical/Tech/typical/cln4p_1p17m_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim_ut-alrdl_typical.nxtgrd"
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
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ssgnp_0p675v_0c_cworst_CCworst_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p825v_125c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) " \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
   "
   
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p825v_0c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER qod_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p88v_125c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p88v_125c_cbest_CCbest_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 set PVT_CORNER qod_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p88v_0c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) " \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) " \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p88v_0c_cbest_CCbest_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_125_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ssgnp_0p765v_125c_cworst_CCworst_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_hm_lvf.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p765v_125c_cworst_CCworst_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_minT_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ssgnp_0p765v_0c_cworst_CCworst_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_hm_lvf.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllssgnp_0p765v_0c_cworst_CCworst_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p935v_125c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) " \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_hm_lvf.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p935v_125c_cbest_CCbest_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER hod_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffgnp_0p935v_0c_cbest_CCbest_T"
   set pvt_corner($PVT_CORNER,op_code_lib) "tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/LVF/CCS/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_hm_lvf.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/n03_wire.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_elvt_110b/tcbn03e_bwph169l3p54cpd_base_elvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvt_110b/tcbn03e_bwph169l3p54cpd_base_lvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_lvtll_110b/tcbn03e_bwph169l3p54cpd_base_lvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_svt_110b/tcbn03e_bwph169l3p54cpd_base_svtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvt_110b/tcbn03e_bwph169l3p54cpd_base_ulvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/base/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_base_ulvtll_110b/tcbn03e_bwph169l3p54cpd_base_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/elvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_elvt_110b/tcbn03e_bwph169l3p54cpd_mb_elvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvt_110b/tcbn03e_bwph169l3p54cpd_mb_lvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/lvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_lvtll_110b/tcbn03e_bwph169l3p54cpd_mb_lvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/svt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_svt_110b/tcbn03e_bwph169l3p54cpd_mb_svtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvt/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvt_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
      /project/foundry/TSMC/N3/TBD/IP/STD/TSMC/tcbn03e_bwph169l3p54cpd/H169/mb/ulvtll/100c/TSMCHOME/digital/Front_End/timing_margin/SPM/pocvm/tcbn03e_bwph169l3p54cpd_mb_ulvtll_110b/tcbn03e_bwph169l3p54cpd_mb_ulvtllffgnp_0p935v_0c_cbest_CCbest_T_sp.pocvm \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) ""
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#################################################################################################################################################################################################
###    design setting 
#################################################################################################################################################################################################
set DEFAULT_SITE coreW54H169
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
     
set VT_GROUPS(SVT)    *CPDSVT
set VT_GROUPS(LVTLL)  *CPDLVTLL
set VT_GROUPS(LVT)    *CPDLVT
set VT_GROUPS(ULVT)   *CPDULVT
set VT_GROUPS(ULVTLL) *CPDULVTLL
set VT_GROUPS(EVT)    *CPDELVT
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
  *CPDSVT \
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
      *CPDULVT
      *CPDULVTLL
      *CPDELVT
  "
} elseif { $VT_EFFORT == "medium" } {
  puts "-I- DONT_USE_CELLS: Run without ULVT  cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
      *CPDULVT
      *CPDELVT
  "
} elseif { $VT_EFFORT == "high" } {
  puts "-I- DONT_USE_CELLS: Run with ULVT and ULVTLL cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
      *CPDELVT
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
   CKLNQD4BWP169H3P54CPDULVT \
   CKLNQD6BWP169H3P54CPDULVT \
   CKLNQD8BWP169H3P54CPDULVT \
   CKLNQD10BWP169H3P54CPDULVT \
   CKLNQD12BWP169H3P54CPDULVT \
   CKLNQOPTBBD8BWP169H3P54CPDULVT \
   CKLNQOPTBBD10BWP169H3P54CPDULVT \
   CKLNQOPTBBD12BWP169H3P54CPDULVT \
   CKLNQOPTBBD14BWP169H3P54CPDULVT \
   CKLNQOPTBBD16BWP169H3P54CPDULVT \
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
set IOBUFFER_CELL "BUFFD6BWP169H3P54CPDLVT"
set USEABLE_IOBUFFER_CELL {BUFFD4BWP169H3P54CPD*VT BUFFD6BWP169H3P54CPD*VT BUFFD8BWP169H3P54CPD*VT BUFFD10BWP169H3P54CPD*VT BUFFD12BWP169H3P54CPD*VT}


# TBD
#set SPARE_MODULE { \
#CKLNQMZD4BWP210H6P51CPDULVT {  1 0 } \
#SDFSNQMZD4BWP210H6P51CPDLVT {  5 0 } \
#AO22MZD4BWP210H6P51CPDLVT {  5 1 } \
#BUFFMVPMZD8BWP210H6P51CPDLVT { 10 0 } \
#MAOI22MZD4BWP210H6P51CPDLVT {  5 1 } \
#INVMVPMZD8BWP210H6P51CPDLVT { 10 0 } \
#INR2MZD4BWP210H6P51CPDLVT {  5 1 } \
#MUX2MZD4BWP210H6P51CPDLVT {  5 0 } \
#IND2MZD4BWP210H6P51CPDLVT { 10 1 } \
#AN2MZD4BWP210H6P51CPDLVT {  5 0 } \
#OR2MZD4BWP210H6P51CPDLVT {  5 1 } \
#IND3MZD4BWP210H6P51CPDLVT {  5 0 } \
#INR3MZD4BWP210H6P51CPDLVT {  5 1 } \
#OA21MZD4BWP210H6P51CPDLVT { 10 0 } \
#OA22MZD4BWP210H6P51CPDLVT {  1 1 } \
#OAI21MZD4BWP210H6P51CPDLVT {  5 0 } \
#XNR2MZD4BWP210H6P51CPDLVT {  5 1 } \
#} 

#################################################################################################################################################################################################
###    floorplan setting 
#################################################################################################################################################################################################
set DIFFUSION_FORBIDDEN_SPACING 0.277 

#TBD
set ENDCAPS(RIGHT_EDGE) 		BOUNDARYLEFTSHBWP169H3P54CPDLVT
set ENDCAPS(LEFT_EDGE) 			BOUNDARYRIGHTSHBWP169H3P54CPDLVT
set ENDCAPS(LEFT_TOP_CORNER) 		BOUNDARYNCORNERSHBWP169H3P54CPDLVT
set ENDCAPS(LEFT_BOTTOM_CORNER) 	BOUNDARYNCORNERSHBWP169H3P54CPDLVT
set ENDCAPS(TOP_EDGE) 			{BOUNDARYNROWNWTAPSHBWP169H3P54CPDLVT BOUNDARYNROW1SHBWP169H3P54CPDLVT BOUNDARYNROW2SHBWP169H3P54CPDLVT BOUNDARYNROW4SHBWP169H3P54CPDLVT BOUNDARYNROW8SHBWP169H3P54CPDLVT}
set ENDCAPS(BOTTOM_EDGE) 		{BOUNDARYNROWNWTAPSHBWP169H3P54CPDLVT BOUNDARYNROW1SHBWP169H3P54CPDLVT BOUNDARYNROW2SHBWP169H3P54CPDLVT BOUNDARYNROW4SHBWP169H3P54CPDLVT BOUNDARYNROW8SHBWP169H3P54CPDLVT}
set ENDCAPS(RIGHT_TOP_EDGE) 		BOUNDARYNCORNERSHBWP169H3P54CPDLVT
set ENDCAPS(RIGHT_BOTTOM_EDGE) 		BOUNDARYNCORNERSHBWP169H3P54CPDLVT
set ENDCAPS(RIGHT_BOTTOM_EDGE_NEIGHBOR) BOUNDARYNINCORNERSHBWP169H3P54CPDLVT	
set ENDCAPS(RIGHT_TOP_EDGE_NEIGHBOR) 	BOUNDARYNINCORNERSHBWP169H3P54CPDLVT	

#TBD
set TAPCELL "{TAPCELLNWBWP169H3P54CPDLVT rule 15.8 boundary_layer LUP_SRM boundary_rule 15.8} {TAPCELLNWBWP169H3P54CPDLVT rule 22.5}"
set SWAP_WELL_TAPS ""
set TIEHCELL "TIEHXPBWP169H3P54CPDLVT"
set TIELCELL "TIELXNBWP169H3P54CPDLVT"
set ANTENNA_CELL_NAME "ANTENNABWP169H3P54CPDLVT"

set PRE_PLACE_DECAP "DCAP16XPRBWP169H3P54CPDLVT"
set PRE_PLACE_ECO_DCAP "GDCAP8SHXPRBWP169H3P54CPDLVT"

set ECO_DCAP_LIST   ""
set DCAP_CELLS_LIST "DCAP16XPRMSBWP169H3P54CPDELVT DCAP16XPRMSBWP169H3P54CPDLVT DCAP16XPRMSBWP169H3P54CPDLVTLL DCAP16XPRMSBWP169H3P54CPDSVT DCAP16XPRMSBWP169H3P54CPDULVT DCAP16XPRMSBWP169H3P54CPDULVTLL DCAP32XPRMSBWP169H3P54CPDELVT DCAP32XPRMSBWP169H3P54CPDLVT DCAP32XPRMSBWP169H3P54CPDLVTLL DCAP32XPRMSBWP169H3P54CPDSVT DCAP32XPRMSBWP169H3P54CPDULVT DCAP32XPRMSBWP169H3P54CPDULVTLL DCAP4XPRMSBWP169H3P54CPDELVT DCAP4XPRMSBWP169H3P54CPDLVT DCAP4XPRMSBWP169H3P54CPDLVTLL DCAP4XPRMSBWP169H3P54CPDSVT DCAP4XPRMSBWP169H3P54CPDULVT DCAP4XPRMSBWP169H3P54CPDULVTLL DCAP64XPRMSBWP169H3P54CPDELVT DCAP64XPRMSBWP169H3P54CPDLVT DCAP64XPRMSBWP169H3P54CPDLVTLL DCAP64XPRMSBWP169H3P54CPDSVT DCAP64XPRMSBWP169H3P54CPDULVT DCAP64XPRMSBWP169H3P54CPDULVTLL DCAP8XPRMSBWP169H3P54CPDELVT DCAP8XPRMSBWP169H3P54CPDLVT DCAP8XPRMSBWP169H3P54CPDLVTLL DCAP8XPRMSBWP169H3P54CPDSVT DCAP8XPRMSBWP169H3P54CPDULVT DCAP8XPRMSBWP169H3P54CPDULVTLL"
set FILLER64_CELLS_LIST "FILL64BWP169H3P54CPDSVT FILL64BWP169H3P54CPDLVTLL FILL64BWP169H3P54CPDLVT FILL64BWP169H3P54CPDULVTLL FILL64BWP169H3P54CPDULVT FILL64BWP169H3P54CPDELVT"
set FILLER32_CELLS_LIST "FILL32BWP169H3P54CPDSVT FILL32BWP169H3P54CPDLVTLL FILL32BWP169H3P54CPDLVT FILL32BWP169H3P54CPDULVTLL FILL32BWP169H3P54CPDULVT FILL32BWP169H3P54CPDELVT"
set FILLER16_CELLS_LIST "FILL16BWP169H3P54CPDSVT FILL16BWP169H3P54CPDLVTLL FILL16BWP169H3P54CPDLVT FILL16BWP169H3P54CPDULVTLL FILL16BWP169H3P54CPDULVT FILL16BWP169H3P54CPDELVT"
set FILLER8_CELLS_LIST  "FILL8BWP169H3P54CPDSVT  FILL8BWP169H3P54CPDLVTLL  FILL8BWP169H3P54CPDLVT  FILL8BWP169H3P54CPDULVTLL  FILL8BWP169H3P54CPDULVT  FILL8BWP169H3P54CPDELVT"
set FILLER4_CELLS_LIST  "FILL4BWP169H3P54CPDSVT  FILL4BWP169H3P54CPDLVTLL  FILL4BWP169H3P54CPDLVT  FILL4BWP169H3P54CPDULVTLL  FILL4BWP169H3P54CPDULVT  FILL4BWP169H3P54CPDELVT"
set FILLER3_CELLS_LIST  "FILL3BWP169H3P54CPDSVT  FILL3BWP169H3P54CPDLVTLL  FILL3BWP169H3P54CPDLVT  FILL3BWP169H3P54CPDULVTLL  FILL3BWP169H3P54CPDULVT  FILL3BWP169H3P54CPDELVT"
set FILLER2_CELLS_LIST  "FILL2BWP169H3P54CPDSVT  FILL2BWP169H3P54CPDLVTLL  FILL2BWP169H3P54CPDLVT  FILL2BWP169H3P54CPDULVTLL  FILL2BWP169H3P54CPDULVT  FILL2BWP169H3P54CPDELVT"
set FILLER1_CELLS_LIST  "FILL1BWP169H3P54CPDSVT  FILL1BWP169H3P54CPDLVTLL  FILL1BWP169H3P54CPDLVT  FILL1BWP169H3P54CPDULVTLL  FILL1BWP169H3P54CPDULVT  FILL1BWP169H3P54CPDELVT"


set FILLERS_CELLS_LIST "$ECO_DCAP_LIST $DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"
#set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"

set ADD_FILLERS_SWAP_CELL "\
{FILL1BWP169H3P54CPDSVT FILL1BWP169H3P54CPDSVT } \
{FILL1BWP169H3P54CPDLVTLL FILL1BWP169H3P54CPDLVTLL} \
{FILL1BWP169H3P54CPDLVT FILL1BWP169H3P54CPDLVT} \
{FILL1BWP169H3P54CPDULVTLL FILL1BWP169H3P54CPDULVTLL} \
{FILL1BWP169H3P54CPDULVT FILL1BWP169H3P54CPDULVT} \
{FILL1BWP169H3P54CPDELVT FILL1BWP169H3P54CPDELVT} \
"

###################################################################################################################################################################################################
###    CTS setting 
###################################################################################################################################################################################################


set CLK_CELLS_PREFIX 		DCCK
set CTS_BUFFER_CELLS   {DCCKBD6BWP169H3P54CPDULVT DCCKBD8BWP169H3P54CPDULVT DCCKBD10BWP169H3P54CPDULVT DCCKBD12BWP169H3P54CPDULVT DCCKBD14BWP169H3P54CPDULVT DCCKBD16BWP169H3P54CPDULVT}

set CTS_INVERTER_CELLS_TOP    { \
DCCKNTHD24BWP169H3P54CPDULVT \
DCCKNTHD20BWP169H3P54CPDULVT \
DCCKNDHD18BWP169H3P54CPDULVT \
DCCKNDHD16BWP169H3P54CPDULVT \
}

set CTS_INVERTER_CELLS_TRUNK  { \
DCCKNDHD18BWP169H3P54CPDULVT \
DCCKNDHD16BWP169H3P54CPDULVT \
DCCKND14BWP169H3P54CPDULVT \
DCCKND12BWP169H3P54CPDULVT \
}

set CTS_INVERTER_CELLS_LEAF   { \
DCCKND14BWP169H3P54CPDULVT \
DCCKND12BWP169H3P54CPDULVT \
DCCKND10BWP169H3P54CPDULVT \
DCCKND8BWP169H3P54CPDULVT \
DCCKND6BWP169H3P54CPDULVT \
}

set CTS_LOGIC_CELLS    {CKAN2D*CPDULVT CKMUX2D*CPDULVT CKNR2D*CPDULVT CKOR2D*CPDULVT CKXOR2D*CPDULVT}
set CTS_CLOCK_GATING_CELLS { CKLHQD*CPDULVT CKLNQD*CPDULVT CKLNQOPTBBD*CPDULVT}
set CTS_CELLS_HALO [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]

if {![info exists CLOCK_GATING_SETUP]} {set CLOCK_GATING_SETUP 0.100 }
if {![info exists LP_CLOCK_GATING_CELL]} {set LP_CLOCK_GATING_CELL CKLNQD8BWP169H3P54CPDULVT }
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




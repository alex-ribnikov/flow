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
#if { [info exists ::env(SYN4RTL)] } { set fe_mode $::env(SYN4RTL) } else { set fe_mode false }
#if { [info exists ::env(PROJECT)] } { set PROJECT ${::env(PROJECT)} } 

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

set scenarios(setup) "func_no_od_125_LIBRARY_SS_c_wc_cc_wc_setup func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_setup func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_setup func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_setup func_no_od_minT_LIBRARY_SS_rc_bc_cc_bc_setup"
set scenarios(hold) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold func_qod_125_LIBRARY_FF_rc_bc_cc_bc_hold func_qod_125_LIBRARY_FF_rc_wc_cc_wc_T_hold func_qod_minT_LIBRARY_FF_c_bc_cc_bc_hold func_qod_minT_LIBRARY_FF_rc_bc_cc_bc_hold func_qod_minT_LIBRARY_FF_rc_wc_cc_wc_T_hold"
set scenarios(dynamic) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
set scenarios(leakage) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"

set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]

set AC_LIMIT_SCENARIOS "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
set DEFAULsetup_VIEW func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_setup
set DEFAULT_CCOPT_VIEW func_no_od_125_LIBRARY_SS_c_wc_cc_wc_setup
set DEFAULT_HOLD_VIEW  func_qod_minT_LIBRARY_FF_rc_bc_cc_bc_hold

set RHSC_STATIC  func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold
set RHSC_DYNAMIC func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_setup
set RHSC_SIGEM   func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_setup


if {![info exists STAGE] || $STAGE == "syn" || $STAGE == "syn_reg" } {
        set scenarios(setup) "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_setup"
    if { $fe_mode } {
        set scenarios(hold) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
        set scenarios(dynamic) ""
        set scenarios(leakage) ""
        	set DEFAULsetup_VIEW func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_setup
    } else {
        set scenarios(hold)    "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
        set scenarios(dynamic) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
        set scenarios(leakage) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
    }
    set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
    
} elseif { [info exists STAGE] && $STAGE == "eco"} {
    set DEFAULsetup_VIEW func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_setup
    set DEFAULT_CCOPT_VIEW func_no_od_125_LIBRARY_SS_c_wc_cc_wc_setup
    set scenarios(setup) "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_setup func_no_od_125_LIBRARY_SS_c_wc_cc_wc_setup"
    set scenarios(hold)  "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
    set scenarios(dynamic) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
    set scenarios(leakage) "func_qod_125_LIBRARY_FF_c_bc_cc_bc_hold"
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
	
	
	
} elseif {[info exists PROJECT] && $PROJECT == "nxt080"} {
	regsub -all "qod" $scenarios(hold) "no_od" scenarios(hold)
	regsub -all "qod" $scenarios(dynamic) "no_od" scenarios(dynamic)
	regsub -all "qod" $scenarios(leakage) "no_od" scenarios(leakage)
	regsub -all "qod" $all_scenarios "no_od" all_scenarios
	
} elseif {[info exists PROJECT] && $PROJECT == "inext"} {
        set scenarios(setup) "func_no_od_125_LIBRARY_SS_c_wc_cc_wc_setup"
        set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
	set OCV "none"
}


echo "scenarios(setup) $scenarios(setup)"
echo "scenarios(hold) $scenarios(hold)"
echo "scenarios(dynamic) $scenarios(dynamic)"
echo "scenarios(leakage) $scenarios(leakage)"


#################################################################################################################################################################################################
###    timing constraint 
#################################################################################################################################################################################################

if { ! [info exists SDC_LIST] || $SDC_LIST == "None" } {
    if { $fe_mode } {
        set sdc_files(func) "./${DESIGN_NAME}.sdc "
    } else {
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
    }
} elseif { [info exists SDC_LIST] } {

    if { [regexp "," $SDC_LIST] } { set sdc_list [split $SDC_LIST ","] } { set sdc_list [split $SDC_LIST " "] }
    foreach file $sdc_list {  if {![file exists $file] } { puts "-E- File $file is on sdc_list but not exists" ; exit } }
    
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
set GDS_MAP_FILE      ""
set STREAM_LAYER_MAP_FILE ""
set TECHNOLOGY_LAYER_MAP  /project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/StarRC/LN04LPP_Star-RCXT_Cell-Level_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/ln04lpp_16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB_Cell.map

if {![info exists ROUTE_DFM]} {set ROUTE_DFM true}
set DFM_REDUNDANT_VIA "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/APR/cdns/v1p0p6p0/LN04LPP_INNOVUS_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/4nm_DFM_via_priority.tcl"
set METAL_FILL_RUNSET ""
set TECH_APACHE ""

set ICT_EM_MODELS ""
set TECH_FILE "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/APR/snps/v1p0p6p0/LN04LPP_ICC_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/ln04lpp_200H_54cpp_16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB.tf"
set TECH_LEF "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/APR/cdns/v1p0p6p0/LN04LPP_INNOVUS_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/6p25TR/ln04lpp_tech_16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB.lef \
" ;# SMSNG

set LEF_FILE_LIST "$TECH_LEF \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230331_0300/LEF/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230331_0300/LEF/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230331_0307/LEF/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230331_0307/LEF/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230331_0322/LEF/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230331_0322/LEF/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0019/LEF/ln04lpp_sc_s6p25t_flkp_rvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0019/LEF/ln04lpp_sc_s6p25t_flkp_rvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0019/LEF/ln04lpp_sc_s6p25t_flk_rvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0019/LEF/ln04lpp_sc_s6p25t_flk_rvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0020/LEF/ln04lpp_sc_s6p25t_flk_lvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0020/LEF/ln04lpp_sc_s6p25t_flk_lvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0020/LEF/ln04lpp_sc_s6p25t_flkp_lvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0020/LEF/ln04lpp_sc_s6p25t_flkp_lvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0021/LEF/ln04lpp_sc_s6p25t_flkp_slvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0021/LEF/ln04lpp_sc_s6p25t_flkp_slvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0021/LEF/ln04lpp_sc_s6p25t_flk_slvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230401_0021/LEF/ln04lpp_sc_s6p25t_flk_slvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230414_0249/LEF/ln04lpp_sc_s6p25t_pbk_lvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230414_0249/LEF/ln04lpp_sc_s6p25t_pbk_lvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230414_0250/LEF/ln04lpp_sc_s6p25t_pbk_rvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230414_0250/LEF/ln04lpp_sc_s6p25t_pbk_rvt_c54l06.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230414_0251/LEF/ln04lpp_sc_s6p25t_pbk_slvt_c54l04.lef \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common_sec230414_0251/LEF/ln04lpp_sc_s6p25t_pbk_slvt_c54l06.lef \
" ;# SMSNG

set NDM_REFERENCE_LIBRARY " "


set LEAKAGE_CONFIG_FILE ""

set LEAKAGE_LEF_SIDE_FILES ""

set LEAKAGE_LIB_SIDE_FILES ""

set POWER_GRID_LIBRARIES " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/PGV/techonly.cl \
"

set STREAM_FILE_LIST " \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0166/GDS/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0166/GDS/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0168/GDS/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0168/GDS/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0170/GDS/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0170/GDS/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0172/GDS/ln04lpp_sc_s6p25t_flk_lvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0172/GDS/ln04lpp_sc_s6p25t_flk_lvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0172/GDS/ln04lpp_sc_s6p25t_flkp_lvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0172/GDS/ln04lpp_sc_s6p25t_flkp_lvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0174/GDS/ln04lpp_sc_s6p25t_flkp_rvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0174/GDS/ln04lpp_sc_s6p25t_flkp_rvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0174/GDS/ln04lpp_sc_s6p25t_flk_rvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0174/GDS/ln04lpp_sc_s6p25t_flk_rvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0177/GDS/ln04lpp_sc_s6p25t_flkp_slvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0177/GDS/ln04lpp_sc_s6p25t_flkp_slvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0177/GDS/ln04lpp_sc_s6p25t_flk_slvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0177/GDS/ln04lpp_sc_s6p25t_flk_slvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0267/GDS/ln04lpp_sc_s6p25t_pbk_lvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0267/GDS/ln04lpp_sc_s6p25t_pbk_lvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0269/GDS/ln04lpp_sc_s6p25t_pbk_rvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0269/GDS/ln04lpp_sc_s6p25t_pbk_rvt_c54l06.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0271/GDS/ln04lpp_sc_s6p25t_pbk_slvt_c54l04.gds \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0271/GDS/ln04lpp_sc_s6p25t_pbk_slvt_c54l06.gds \
";# SMSNG

set SCHEMATIC_FILE_LIST " \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0166/CIR/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0166/CIR/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0168/CIR/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0168/CIR/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0170/CIR/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0170/CIR/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0172/CIR/ln04lpp_sc_s6p25t_flk_lvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0172/CIR/ln04lpp_sc_s6p25t_flk_lvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0172/CIR/ln04lpp_sc_s6p25t_flkp_lvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0172/CIR/ln04lpp_sc_s6p25t_flkp_lvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0174/CIR/ln04lpp_sc_s6p25t_flkp_rvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0174/CIR/ln04lpp_sc_s6p25t_flkp_rvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0174/CIR/ln04lpp_sc_s6p25t_flk_rvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0174/CIR/ln04lpp_sc_s6p25t_flk_rvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0177/CIR/ln04lpp_sc_s6p25t_flkp_slvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0177/CIR/ln04lpp_sc_s6p25t_flkp_slvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0177/CIR/ln04lpp_sc_s6p25t_flk_slvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230330_0177/CIR/ln04lpp_sc_s6p25t_flk_slvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0267/CIR/ln04lpp_sc_s6p25t_pbk_lvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0267/CIR/ln04lpp_sc_s6p25t_pbk_lvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0269/CIR/ln04lpp_sc_s6p25t_pbk_rvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0269/CIR/ln04lpp_sc_s6p25t_pbk_rvt_c54l06.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0271/CIR/ln04lpp_sc_s6p25t_pbk_slvt_c54l04.cdl \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/BE-Common_sec230331_0271/CIR/ln04lpp_sc_s6p25t_pbk_slvt_c54l06.cdl \
    	./scripts/flow/empty_subckt.cdl \
"
set CTL_FILE_LIST ""

#################################################################################################################################################################################################
###    RC view
#################################################################################################################################################################################################
set rc_corner(gpd_file) "$GPD_DIR/out/gpd/${DESIGN_NAME}.${STAGE}.HIER.gpd"

set rc_corner(c_wc_cc_wc)  "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/qrc/LN04LPP_QRC_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/SigCmaxDP_ErPlus/qrcTechFile"
set rc_corner(c_wc_cc_wc,nxtgrd)  "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/StarRC/LN04LPP_Star-RCXT_Cell-Level_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/ln04lpp_16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB_SigCmaxDP_ErPlus_detailed.nxtgrd"
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

set rc_corner(rc_wc_cc_wc)  "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/qrc/LN04LPP_QRC_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/SigRCmaxDP_ErPlus/qrcTechFile"
set rc_corner(rc_wc_cc_wc,nxtgrd)  "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/StarRC/LN04LPP_Star-RCXT_Cell-Level_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/ln04lpp_16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB_SigRCmaxDP_ErPlus_detailed.nxtgrd"
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

set rc_corner(c_bc_cc_bc)  "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/qrc/LN04LPP_QRC_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/SigCminDP_ErMinus/qrcTechFile"
set rc_corner(c_bc_cc_bc,nxtgrd)  "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/StarRC/LN04LPP_Star-RCXT_Cell-Level_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/ln04lpp_16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB_SigCminDP_ErMinus_detailed.nxtgrd"
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

set rc_corner(rc_bc_cc_bc)  "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/qrc/LN04LPP_QRC_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/SigRCminDP_ErMinus/qrcTechFile"
set rc_corner(rc_bc_cc_bc,nxtgrd)  "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/StarRC/LN04LPP_Star-RCXT_Cell-Level_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/ln04lpp_16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB_SigRCminDP_ErMinus_detailed.nxtgrd"
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

set rc_corner(typical)  "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/qrc/LN04LPP_QRC_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/nominal/qrcTechFile"
set rc_corner(typical,nxtgrd) "/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/PDK/Extraction/StarRC/LN04LPP_Star-RCXT_Cell-Level_S00-V1.0.6.0/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/ln04lpp_16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB_nominal_detailed.nxtgrd"
set rc_corner(typical,rc_variation) 0.1
set rc_corner(typical,spef_25) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.typical_25.gz"
set rc_corner(typical,spef_85) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.typical_85.gz"


#################################################################################################################################################################################################
###    timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "sspg_0p6750v_125c" ;# SMSNG
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l06_sspg_nominal_max_0p6750v_125c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "125";# SMSNG
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
       /project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Common*/REDHAWK/*c54l04*0p75* \
    "
   set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_sspg_nominal_max_0p6750v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_sspg_nominal_max_0p6750v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_sspg_nominal_max_0p6750v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_sspg_nominal_max_0p6750v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_sspg_nominal_max_0p6750v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_sspg_nominal_max_0p6750v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_sspg_nominal_max_0p6750v_125c.lib.gz \
   ";# SMSNG
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
   set pvt_corner($PVT_CORNER,op_code) "sspg_0p6750v_m40c";# SMSNG
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l04_sspg_nominal_max_0p6750v_m40c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "-40";# SMSNG
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
   "
   set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_sspg_nominal_max_0p6750v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_sspg_nominal_max_0p6750v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_sspg_nominal_max_0p6750v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_sspg_nominal_max_0p6750v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_sspg_nominal_max_0p6750v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_sspg_nominal_max_0p6750v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_sspg_nominal_max_0p6750v_m40c.lib.gz \
    ";# SMSNG

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
   set pvt_corner($PVT_CORNER,op_code) "ffpg_0p8250v_125c";# SMSNG
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_0p8250v_125c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
    "
   set pvt_corner($PVT_CORNER,timing) " \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_ffpg_nominal_min_0p8250v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_ffpg_nominal_min_0p8250v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_ffpg_nominal_min_0p8250v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_ffpg_nominal_min_0p8250v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_ffpg_nominal_min_0p8250v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_0p8250v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_ffpg_nominal_min_0p8250v_125c.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   ";# SMSNG

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell"))} {
   set pvt_corner($PVT_CORNER,op_code) "ffpg_0p8250v_m40c";# SMSNG
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_0p8250v_m40c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "-40";# SMSNG
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_ffpg_nominal_min_0p8250v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_ffpg_nominal_min_0p8250v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_ffpg_nominal_min_0p8250v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_ffpg_nominal_min_0p8250v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_ffpg_nominal_min_0p8250v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_0p8250v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_ffpg_nominal_min_0p8250v_m40c.lib.gz \
";# SMSNG
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
   set pvt_corner($PVT_CORNER,op_code) "ffpg_0p9000v_125c";# SMSNG
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_0p9000v_125c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "125";# SMSNG
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) " \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_ffpg_nominal_min_0p9000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_ffpg_nominal_min_0p9000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_ffpg_nominal_min_0p9000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_ffpg_nominal_min_0p9000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_ffpg_nominal_min_0p9000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_0p9000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_ffpg_nominal_min_0p9000v_125c.lib.gz \
";# SMSNG
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
   set pvt_corner($PVT_CORNER,op_code) "ffpg_0p9000v_m40c";# SMSNG
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_0p9000v_m40c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "-40";# SMSNG
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_ffpg_nominal_min_0p9000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_ffpg_nominal_min_0p9000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_ffpg_nominal_min_0p9000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_ffpg_nominal_min_0p9000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_ffpg_nominal_min_0p9000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_0p9000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_ffpg_nominal_min_0p9000v_m40c.lib.gz \
";# SMSNG
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
   set pvt_corner($PVT_CORNER,op_code) "sspg_0p8550v_125c"
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l04_sspg_nominal_max_0p8550v_125c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
    "
   set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_sspg_nominal_max_0p8550v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_sspg_nominal_max_0p8550v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_sspg_nominal_max_0p8550v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_sspg_nominal_max_0p8550v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_sspg_nominal_max_0p8550v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_sspg_nominal_max_0p8550v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_sspg_nominal_max_0p8550v_125c.lib.gz \
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
   set pvt_corner($PVT_CORNER,op_code) "sspg_0p8550v_m40c"
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l04_sspg_nominal_max_0p8550v_m40c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "-40"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_sspg_nominal_max_0p8550v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_sspg_nominal_max_0p8550v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_sspg_nominal_max_0p8550v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_sspg_nominal_max_0p8550v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_sspg_nominal_max_0p8550v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_sspg_nominal_max_0p8550v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_sspg_nominal_max_0p8550v_m40c.lib.gz \
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
   set pvt_corner($PVT_CORNER,op_code) "ffpg_1p0000v_125c"
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_1p0000v_125c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
    "
   set pvt_corner($PVT_CORNER,timing) " \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_ffpg_nominal_min_1p0000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_ffpg_nominal_min_1p0000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_ffpg_nominal_min_1p0000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_ffpg_nominal_min_1p0000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_ffpg_nominal_min_1p0000v_125c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_1p0000v_125c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_ffpg_nominal_min_1p0000v_125c.lib.gz \
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
   set pvt_corner($PVT_CORNER,op_code) "ffpg_1p0000v_m40c"
   set pvt_corner($PVT_CORNER,op_code_lib) "ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_1p0000v_m40c" ;# SMSNG
   set pvt_corner($PVT_CORNER,temperature) "-40"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.06 0.95} {1.06 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l04_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0212/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_rvt_c54l06_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l04_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0216/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_lvt_c54l06_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l04_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230331_0219/LIBERTY/mbslk/ln04lpp_sc_s6p25t_mbslk_slvt_c54l06_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l04_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0088/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_slvt_c54l06_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l04_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0090/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_lvt_c54l06_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l04_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230411_0092/LIBERTY/pbk/ln04lpp_sc_s6p25t_pbk_rvt_c54l06_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l04_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_lvt_c54l06_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l04_ffpg_nominal_min_1p0000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0097/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_lvt_c54l06_ffpg_nominal_min_1p0000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l04_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_slvt_c54l06_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l04_ffpg_nominal_min_1p0000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0098/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_slvt_c54l06_ffpg_nominal_min_1p0000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l04_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flk/ln04lpp_sc_s6p25t_flk_rvt_c54l06_ffpg_nominal_min_1p0000v_m40c_lvf_dth.lib_ccs_tn.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l04_ffpg_nominal_min_1p0000v_m40c.lib.gz \
/project/foundry/SAMSUNG/N4/16M_3Mx_2Fx_7Dx_2Hx_2Iz_LB/IP/STDCELL/SMSNG/v1p01/FE-Liberty_sec230412_0099/LIBERTY/flkp/ln04lpp_sc_s6p25t_flkp_rvt_c54l06_ffpg_nominal_min_1p0000v_m40c.lib.gz \
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
set DEFAULT_SITE ln04lpp_sc_s6p25t_c54
if {![info exists MAX_ROUTING_LAYER]} {set MAX_ROUTING_LAYER 15}
if {![info exists MIN_ROUTING_LAYER]} {set MIN_ROUTING_LAYER 2}

# TODO: Add supply voltage per net
set PWR_NET     [list VDD]
set GND_NET     [list VSS]
set PWR_PINS    [list VDD VNW VDDG]
set GND_PINS    [list VSS VPW]

if { ![info exists env(LEC_VERSION)] && (![info exists DEF_FILE] || $DEF_FILE == "None") && (  ([info exists PYISICAL_SYN] && $PYISICAL_SYN == "true")  || ( ![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "innovus") ) } {
    
    if { [info exists fe_mode] && $fe_mode } {
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
     
set VT_GROUPS(RVT)    *S6P25TR*
set VT_GROUPS(LVT)    *S6P25TL*
set VT_GROUPS(SLVT)   *S6P25TSL*

set leakage_pattern_priority_list "RVT LVT SLVT"


if {[info exists ::synopsys_program_name] } {
	set EXCLUDE_ICG ""
}

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
  DFF* \
  GP* \
"

#  F6*_BSDFF*W* \

if {[info exists MBIT] && $MBIT == "false"} {
  puts "-I- DONT_USE_CELLS: Run without MBIT cells"
  set DONT_USE_CELLS " $DONT_USE_CELLS \
    SDFFQ2BSRLV* \
    SDFFQ3BSRLV* \
    SDFFQ4BSRLV* \
    SDFFQ8BSRLV* \
    SDFFRPQ2BSRLV* \
    SDFFRPQ3BSRLV* \
    SDFFRPQ4BSRLV* \
    SDFFRPQ8BSRLV* \
    SDFFRPQN2BSRLV* \
    SDFFRPQN3BSRLV* \
    SDFFRPQN4BSRLV* \
    SDFFRPQN8BSRLV* \
    SDFFSQ2BSRLV* \
    SDFFSQ3BSRLV* \
    SDFFSQ4BSRLV* \
    SDFFSQ8BSRLV* \
  "
} 

if { ![info exists VT_EFFORT] || $VT_EFFORT == "low" } {
  puts "-I- DONT_USE_CELLS: Run without SLVT "
  set DONT_USE_CELLS "$DONT_USE_CELLS \
     *S6P25TSL* \
  "
} elseif { $VT_EFFORT == "medium" } {
  puts "-I- DONT_USE_CELLS: Run without ULVT and with ULVTLL cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
  "
} elseif { $VT_EFFORT == "high" } {
  puts "-I- DONT_USE_CELLS: Run with ULVT and ULVTLL cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
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
  PREICG_D4_N_S6P25TL_C54L04 \
  PREICG_D5_N_S6P25TL_C54L04 \ 
  PREICG_D6_N_S6P25TL_C54L04 \
  PREICG_D7_N_S6P25TL_C54L04 \
  PREICG_D8_N_S6P25TL_C54L04 \
  PREICG_D10_N_S6P25TL_C54L04 \
"

if {[info exists TGATE] && $TGATE == "true"} {
puts "-I remove TGATE flops from DONT_USE_CELLS" 

}
if {[info exists LATCH] && $LATCH == "false"} {
  puts "-I- DONT_USE_CELLS: Run without Latch cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
  LAT*
  "

}

#################################################################################################################################################################################################
###    place setting 
#################################################################################################################################################################################################
set IOBUFFER_CELL "BUF_D12_N_S6P25TR_C54L04"
set USEABLE_IOBUFFER_CELL { BUF_D10_N_S6P25TR_C54L04 \
BUF_D12_N_S6P25TR_C54L04 \
BUF_D14_N_S6P25TR_C54L04 \
BUF_D16_N_S6P25TR_C54L04 \
BUF_D1_N_S6P25TR_C54L04 \
BUF_D20_N_S6P25TR_C54L04 \
BUF_D24_N_S6P25TR_C54L04 \
BUF_D28_N_S6P25TR_C54L04 \
BUF_D2_N_S6P25TR_C54L04 \
BUF_D32_N_S6P25TR_C54L04 \
BUF_D3_N_S6P25TR_C54L04 \
BUF_D4_N_S6P25TR_C54L04 \
BUF_D5_N_S6P25TR_C54L04 \
BUF_D6_N_S6P25TR_C54L04 \
BUF_D7_N_S6P25TR_C54L04 \
BUF_D8_N_S6P25TR_C54L04 \
 }
set SPARE_MODULE { \
} 

#################################################################################################################################################################################################
###    floorplan setting 
#################################################################################################################################################################################################
set DIFFUSION_FORBIDDEN_SPACING 0.277 

#set ENDCAPS(TOP_EDGE)             {F6LLAA_BORDERROWPGAP F6LLAA_BORDERROWP8 F6LLAA_BORDERROWP4 F6LLAA_BORDERROWP2 F6LLAA_BORDERROWP16 F6LLAA_BORDERROWP1}
#set ENDCAPS(BOTTOM_EDGE)         {F6LLAA_BORDERROWPGAP F6LLAA_BORDERROWP8 F6LLAA_BORDERROWP4 F6LLAA_BORDERROWP2 F6LLAA_BORDERROWP16 F6LLAA_BORDERROWP1}
#set ENDCAPS(LEFT_EDGE)             F6LLAA_BORDERTIESMRIGHT
#set ENDCAPS(RIGHT_TOP_CORNER)         F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_BOTTOM_CORNER)     F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_TOP_CORNER)         F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_BOTTOM_CORNER)     F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_TOP_EDGE)         F6LLAA_BORDERCORNERINTPRIGHT
#set ENDCAPS(RIGHT_TOP_EDGE)         F6LLAA_BORDERCORNERINTPRIGHT
#set ENDCAPS(LEFT_BOTTOM_EDGE)         F6LLAA_BORDERCORNERINTPRIGHT
#set ENDCAPS(LEFT_BOTTOM_EDGE)         F6LLAA_BORDERCORNERINTPTIERIGHT
#set ENDCAPS(LEFT_TOP_EDGE)         F6LLAA_BORDERCORNERINTPTIERIGHT
#set ENDCAPS(LEFT_TOP_EDGE_NEIGHBOR)     HDBSVT06_CAPBRINCGAP3    
#set ENDCAPS(RIGHT_TOP_EDGE_NEIGHBOR)     HDBSVT06_CAPBLINCGAP3    
#set ENDCAPS(LEFT_BOTTOM_EDGE_NEIGHBOR)  HDBSVT06_CAPBRINCGAP3        
#set ENDCAPS(RIGHT_BOTTOM_EDGE_NEIGHBOR) HDBSVT06_CAPBLINCGAP3        

set ENDCAPS(TOP_EDGE)              {TOPBOTTOM1N_DX_L_S6P25TR_C54L04 TOPBOTTOM2N_DX_L_S6P25TR_C54L04 TOPBOTTOM3N_DX_L_S6P25TR_C54L04 TOPBOTTOM4N_DX_L_S6P25TR_C54L04 TOPBOTTOM5N_DX_L_S6P25TR_C54L04 TOPBOTTOM8N_DX_L_S6P25TR_C54L04 }
set ENDCAPS(BOTTOM_EDGE)           {TOPBOTTOM1P_DX_L_S6P25TR_C54L04 TOPBOTTOM2P_DX_L_S6P25TR_C54L04 TOPBOTTOM3P_DX_L_S6P25TR_C54L04 TOPBOTTOM4P_DX_L_S6P25TR_C54L04 TOPBOTTOM5P_DX_L_S6P25TR_C54L04 TOPBOTTOM8P_DX_L_S6P25TR_C54L04}
set ENDCAPS(LEFT_EDGE)                 ENDCAPTIE_DX_L_S6P25TR_C54L04
set ENDCAPS(LEFT_TOP_CORNER)           ENDCAPTIETOPBOTTOMN_DX_L_S6P25TR_C54L04
set ENDCAPS(LEFT_BOTTOM_CORNER)        ENDCAPTIETOPBOTTOMP_DX_L_S6P25TR_C54L04
set ENDCAPS(LEFT_TOP_EDGE)             INCNRCAPTIEP_DX_L_S6P25TR_C54L04
set ENDCAPS(LEFT_BOTTOM_EDGE)          INCNRCAPTIEN_DX_L_S6P25TR_C54L04
set ENDCAPS(LEFT_TOP_EDGE_NEIGHBOR)    ENDCAPTIEINCNRN_DX_L_S6P25TR_C54L04     
set ENDCAPS(LEFT_BOTTOM_EDGE_NEIGHBOR) ENDCAPTIEINCNRP_DX_L_S6P25TR_C54L04     








#set TAPCELL "{F6LLAA_TIESMALL rule 15.8 boundary_layer LUP_SRM boundary_rule 15.8} {F6LLAA_TIE rule 22.5}"
set TAPCELL " {FILLTIE_DX_L_S6P25TR_C54L04 rule 25}"
set SWAP_WELL_TAPS ""
set TIEHCELL "TIEHI"
set TIELCELL "TIELO"
set ANTENNA_CELL_NAME "ANTENNA"

set PRE_PLACE_DECAP "FILLSGCAP32_DX_L_S6P25TL_C54L04"
set PRE_PLACE_ECO_DCAP "FILLSGCAP64_DX_L_S6P25TL_C54L04"

set ECO_DCAP_LIST   ""
set DCAP_CELLS_LIST "FILLSGCAP1024_DX_L_S6P25TR_C54L04 FILLSGCAP512_DX_L_S6P25TR_C54L04 FILLSGCAP256_DX_L_S6P25TR_C54L04 FILLSGCAP128_DX_L_S6P25TR_C54L04 FILLSGCAP64_DX_L_S6P25TR_C54L04 FILLSGCAP32_DX_L_S6P25TR_C54L04 FILLSGCAP16_DX_L_S6P25TR_C54L04 FILLSGCAP8_DX_L_S6P25TR_C54L04 FILLSGCAP5_DX_L_S6P25TR_C54L04 FILLSGCAP4_DX_L_S6P25TR_C54L04 "

set FILLER128_CELLS_LIST "FILL128_DX_L_S6P25TSL_C54L04 FILL128_DX_L_S6P25TL_C54L04 FILL128_DX_L_S6P25TR_C54L04"
set FILLER64_CELLS_LIST "FILL64_DX_L_S6P25TSL_C54L04 FILL64_DX_L_S6P25TL_C54L04 FILL64_DX_L_S6P25TR_C54L04"
set FILLER32_CELLS_LIST "FILL32_DX_L_S6P25TSL_C54L04 FILL32_DX_L_S6P25TL_C54L04 FILL32_DX_L_S6P25TR_C54L04"
set FILLER16_CELLS_LIST "FILL16_DX_L_S6P25TSL_C54L04 FILL16_DX_L_S6P25TL_C54L04 FILL16_DX_L_S6P25TR_C54L04"
set FILLER12_CELLS_LIST ""
set FILLER8_CELLS_LIST  "FILL8_DX_L_S6P25TSL_C54L04 FILL8_DX_L_S6P25TL_C54L04 FILL8_DX_L_S6P25TR_C54L04"
set FILLER5_CELLS_LIST  "FILL5_DX_L_S6P25TSL_C54L04 FILL5_DX_L_S6P25TL_C54L04 FILL5_DX_L_S6P25TR_C54L04"
set FILLER4_CELLS_LIST  "FILL4_DX_L_S6P25TSL_C54L04 FILL4_DX_L_S6P25TL_C54L04 FILL4_DX_L_S6P25TR_C54L04"
set FILLER3_CELLS_LIST  "FILL3_DX_L_S6P25TSL_C54L04 FILL3_DX_L_S6P25TL_C54L04 FILL3_DX_L_S6P25TR_C54L04"
set FILLER2_CELLS_LIST  "FILL2_DX_L_S6P25TSL_C54L04 FILL2_DX_L_S6P25TL_C54L04 FILL2_DX_L_S6P25TR_C54L04"
set FILLER1_CELLS_LIST  "FILL1_DX_L_S6P25TSL_C54L04 FILL1_DX_L_S6P25TL_C54L04 FILL1_DX_L_S6P25TR_C54L04"

set FILLERS_CELLS_LIST "$ECO_DCAP_LIST $DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER5_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"
#set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER128_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"

set ADD_FILLERS_SWAP_CELL {{FILL1_DX_L_S6P25TSL_C54L04 FILL1MR_DX_L_S6P25TSL_C54L04} {FILL1_DX_L_S6P25TL_C54L04 FILL1MR_DX_L_S6P25TL_C54L04} {FILL1_DX_L_S6P25TR_C54L04 FILL1MR_DX_L_S6P25TR_C54L04} }

###################################################################################################################################################################################################
###    CTS setting 
###################################################################################################################################################################################################


set CLK_CELLS_PREFIX 		""
set CTS_BUFFER_CELLS          { }

set CTS_INVERTER_CELLS_TOP    { \
CLKINV_D24_N_S6P25TSL_C54L04 \
CLKINV_D28_N_S6P25TSL_C54L04 \
CLKINV_D32_N_S6P25TSL_C54L04 \
}

set CTS_INVERTER_CELLS_TRUNK  { \
CLKINV_D14_N_S6P25TSL_C54L04 \
CLKINV_D16_N_S6P25TSL_C54L04 \
CLKINV_D20_N_S6P25TSL_C54L04 \
CLKINV_D24_N_S6P25TSL_C54L04 \
}

set CTS_INVERTER_CELLS_LEAF   { \
CLKINV_D6_N_S6P25TSL_C54L04 \
CLKINV_D7_N_S6P25TSL_C54L04 \
CLKINV_D8_N_S6P25TSL_C54L04 \
CLKINV_D10_N_S6P25TSL_C54L04 \
CLKINV_D12_N_S6P25TSL_C54L04 \
CLKINV_D14_N_S6P25TSL_C54L04 \
}

set CTS_LOGIC_CELLS           {}
set CTS_CLOCK_GATING_CELLS    {PREICG_D4_N_S6P25TL_C54L04 PREICG_D5_N_S6P25TL_C54L04 PREICG_D6_N_S6P25TL_C54L04 PREICG_D7_N_S6P25TL_C54L04 PREICG_D8_N_S6P25TL_C54L04 PREICG_D10_N_S6P25TL_C54L04}
set CTS_CELLS_HALO [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]

if {[info exists ::synopsys_program_name] } {
	set LP_CLOCK_GATING_CELL PREICG_D4_N_S6P25TL_C54L04
}
if {![info exists CLOCK_GATING_SETUP]} {set CLOCK_GATING_SETUP 0.100 }

set HOLD_FIX_CELLS_LIST [list \
DLY*TR_C54L04 \
DLY*TL_C54L04* \
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




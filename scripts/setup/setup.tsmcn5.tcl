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
#	 Var	date of change	owner		 comment																	#
#	----	--------------	-------	 ---------------------------------------------------------------											#
#	0.1	14/01/2021	Royl	initial script																		#
#	0.2	21/01/2021	OrY	    Update libs location (from srv to foundary)
#	0.3	26/01/2021	OrY	    Update BRCM libs location and corners
#	0.4	28/01/2021	Royl	add SOCV file 																		#
#	0.5	03/03/2021	OrY	    Merge between Roy and Or
#																								#
#																								#
#################################################################################################################################################################################################

#if { [info exists ::env(SYN4RTL)] } { set fe_mode $::env(SYN4RTL) } else { set fe_mode false }
if {![info exists FE_MODE] } {set FE_MODE false}


set mmmc_results ./scripts_local/mmmc_results.tcl

if {![info exists DESIGN_NAME]} {set DESIGN_NAME [lindex [split [pwd] "/"] end-2]}
if {![info exists SPEF_DIR]} {set SPEF_DIR ""}

#################################################################################################################################################################################################
###	running scenarios 
#################################################################################################################################################################################################
if {[info exists STAGE] && ($STAGE == "route" || $STAGE == "cts")} {
	set scenarios(setup) "func_ssgnp_0p675v_0c_cworst_setup func_ssgnp_0p675v_125c_cworst_setup func_ssgnp_0p675v_0c_rcworst_setup func_ssgnp_0p675v_125c_rcworst_setup"
	set scenarios(hold) "func_ssgnp_0p675v_0c_cworst_hold func_ssgnp_0p675v_125c_cworst_hold func_ffgnp_0p825v_125c_cbest_hold func_ffgnp_0p825v_0c_cbest_hold"
	set scenarios(dynamic) "func_ssgnp_0p675v_0c_cworst_setup"
	set scenarios(leakage) "func_ffgnp_0p825v_125c_cbest_hold"
} else {
	set scenarios(setup) "func_ssgnp_0p675v_0c_cworst_setup"
	if { !$fe_mode } {
		set scenarios(hold) "func_ffgnp_0p825v_125c_cworst_hold"
		set scenarios(dynamic) "func_ssgnp_0p675v_0c_cworst_setup"
		set scenarios(leakage) "func_ffgnp_0p825v_125c_cworst_hold"
	} else {
		set scenarios(hold) "func_ssgnp_0p675v_0c_cworst_setup"
	}
}

#################################################################################################################################################################################################
###	timing constraint 
#################################################################################################################################################################################################

if { ! [info exists SDC_LIST] || $SDC_LIST == "None" } {
    if { !$fe_mode } {
    
        set sdc_files(func) ""
        if { [file exists ../inter/${DESIGN_NAME}.pre.sdc]  } { append sdc_files(func) " ../inter/${DESIGN_NAME}.pre.sdc " }
        if { [file exists ../inter/${DESIGN_NAME}.sdc]      } { append sdc_files(func) " ../inter/${DESIGN_NAME}.sdc " }
        if { [file exists ../inter/${DESIGN_NAME}.post.sdc] } { append sdc_files(func) " ../inter/${DESIGN_NAME}.post.sdc " }                
        
        if { $sdc_files(func) == "" } { puts "-E- No SDC file" ; exit }
        
        set sdc_files(scan_shift) ""
        set sdc_files(scan_capture) ""
        set sdc_files(bist) ""

    } else {
        set sdc_files(func) "\
        ./${DESIGN_NAME}.sdc \
        "
    }
} else {

    set sdc_files(func) [join [split $SDC_LIST ","] " "]

}

puts "-I- sdc files are: "
parray sdc_files

#################################################################################################################################################################################################
###	physical view
#################################################################################################################################################################################################
set GDS_MAP_FILE      "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/APR/cdns/1.1.2A/PRTF_Innovus_5nm_014_Cad_V11_2a/PR_tech/Cadence/GdsOutMap/PRTF_Innovus_N5_gdsout_17M_1X_h_1Xb_v_1Xe_h_1Ya_v_1Yb_h_5Y_vhvhv_2Yy2Yx2R_SHDMIM.11_2a.map"
set DFM_REDUNDANT_VIA "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/APR/cdns/1.1.2A/PRTF_Innovus_5nm_014_Cad_V11_2a/PR_tech/Cadence/script/PRTF_Innovus_N5_DFM_via_swap_reference_command.11_2a.tcl"
set METAL_FILL_RUNSET ""
set ICT_EM_MODELS "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK//EM/cdns/1.1.3A/cln5_1p17m+ut-alrdl_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim.ictem"
set TECH_LEF "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/APR/cdns/1.1.2A/PRTF_Innovus_5nm_014_Cad_V11_2a/PR_tech/Cadence/LefHeader/Standard/VHV/PRTF_Innovus_N5_17M_1X1Xb1Xe1Ya1Yb5Y2Yy2Yx2R_UTRDL_M1P34_M2P35_M3P42_M4P42_M5P76_M6P76_M7P76_M8P76_M9P76_M10P76_M11P76_H210_SHDMIM.11_2a.tlef"

set LEF_FILE_LIST "$TECH_LEF \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_lvt_110a/lef/tcbn05_bwph210l6p51cnod_base_lvt.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_lvt_110a/lef/tcbn05_bwph210l6p51cnod_base_lvt_par.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_lvtll_110a/lef/tcbn05_bwph210l6p51cnod_base_lvtll.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_lvtll_110a/lef/tcbn05_bwph210l6p51cnod_base_lvtll_par.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_svt_110a/lef/tcbn05_bwph210l6p51cnod_base_svt.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_svt_110a/lef/tcbn05_bwph210l6p51cnod_base_svt_par.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_ulvt_110a/lef/tcbn05_bwph210l6p51cnod_base_ulvt.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_ulvt_110a/lef/tcbn05_bwph210l6p51cnod_base_ulvt_par.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_ulvtll_110a/lef/tcbn05_bwph210l6p51cnod_base_ulvtll.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_ulvtll_110a/lef/tcbn05_bwph210l6p51cnod_base_ulvtll_par.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_lvt_110a/lef/tcbn05_bwph210l6p51cnod_mb_lvt.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_lvt_110a/lef/tcbn05_bwph210l6p51cnod_mb_lvt_par.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_lvtll_110a/lef/tcbn05_bwph210l6p51cnod_mb_lvtll.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_lvtll_110a/lef/tcbn05_bwph210l6p51cnod_mb_lvtll_par.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_svt_110a/lef/tcbn05_bwph210l6p51cnod_mb_svt.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_svt_110a/lef/tcbn05_bwph210l6p51cnod_mb_svt_par.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_ulvt_110a/lef/tcbn05_bwph210l6p51cnod_mb_ulvt.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_ulvt_110a/lef/tcbn05_bwph210l6p51cnod_mb_ulvt_par.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_ulvtll_110a/lef/tcbn05_bwph210l6p51cnod_mb_ulvtll.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_ulvtll_110a/lef/tcbn05_bwph210l6p51cnod_mb_ulvtll_par.lef \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.plef \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.plef \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.plef \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0.plef \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1.plef \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.plef \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.plef \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.plef \
"


set LEAKAGE_CONFIG_FILE " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_leakage_config.txt \
"


set LEAKAGE_LEF_SIDE_FILES " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_lvt_110a/lef/tcbn05_bwph210l6p51cnod_base_lvt_edgeinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_lvtll_110a/lef/tcbn05_bwph210l6p51cnod_base_lvtll_edgeinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_svt_110a/lef/tcbn05_bwph210l6p51cnod_base_svt_edgeinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_ulvt_110a/lef/tcbn05_bwph210l6p51cnod_base_ulvt_edgeinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_base_ulvtll_110a/lef/tcbn05_bwph210l6p51cnod_base_ulvtll_edgeinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_lvt_110a/lef/tcbn05_bwph210l6p51cnod_mb_lvt_edgeinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_lvtll_110a/lef/tcbn05_bwph210l6p51cnod_mb_lvtll_edgeinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_svt_110a/lef/tcbn05_bwph210l6p51cnod_mb_svt_edgeinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_ulvt_110a/lef/tcbn05_bwph210l6p51cnod_mb_ulvt_edgeinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Back_End/lef/tcbn05_bwph210l6p51cnod_mb_ulvtll_110a/lef/tcbn05_bwph210l6p51cnod_mb_ulvtll_edgeinfo.txt \
"

set LEAKAGE_LIB_SIDE_FILES " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvt_ffgnp_0p825v_125c_typical_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtll_ffgnp_0p825v_125c_typical_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svt_ffgnp_0p825v_125c_typical_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvt_ffgnp_0p825v_125c_typical_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/leakage_table/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtll_ffgnp_0p825v_125c_typical_leakinfo.txt \
"

set POWER_GRID_LIBRARIES " \
/bespace/users/royl/libs_comp/be_work/tsmcn5/gmu_cluster/gmu_cluster_n5_test/pgv/out/techonly.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_base_lvt_110b/pgv/tcbn05_bwph210l6p51cnod_base_lvtffgnp_0p825v_125c_cbest_CCbest_T.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_base_lvtll_110b/pgv/tcbn05_bwph210l6p51cnod_base_lvtllffgnp_0p825v_125c_cbest_CCbest_T.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_base_svt_110b/pgv/tcbn05_bwph210l6p51cnod_base_svtffgnp_0p825v_125c_cbest_CCbest_T.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_base_ulvt_110b/pgv/tcbn05_bwph210l6p51cnod_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/pgv/tcbn05_bwph210l6p51cnod_base_ulvtllffgnp_0p825v_125c_cbest_CCbest_T.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_mb_lvt_110b/pgv/tcbn05_bwph210l6p51cnod_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/pgv/tcbn05_bwph210l6p51cnod_mb_lvtllffgnp_0p825v_125c_cbest_CCbest_T.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_mb_svt_110b/pgv/tcbn05_bwph210l6p51cnod_mb_svtffgnp_0p825v_125c_cbest_CCbest_T.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/pgv/tcbn05_bwph210l6p51cnod_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T.cl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Back_End/pgv/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/pgv/tcbn05_bwph210l6p51cnod_mb_ulvtllffgnp_0p825v_125c_cbest_CCbest_T.cl \
"

set GDS_FILE_LIST " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_base_lvt_110a/tcbn05_bwph210l6p51cnod_base_lvt.gds \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_base_lvtll_110a/tcbn05_bwph210l6p51cnod_base_lvtll.gds \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_base_svt_110a/tcbn05_bwph210l6p51cnod_base_svt.gds \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_base_ulvt_110a/tcbn05_bwph210l6p51cnod_base_ulvt.gds \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_base_ulvtll_110a/tcbn05_bwph210l6p51cnod_base_ulvtll.gds \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_mb_lvt_110a/tcbn05_bwph210l6p51cnod_mb_lvt.gds \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_mb_lvtll_110a/tcbn05_bwph210l6p51cnod_mb_lvtll.gds \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_mb_svt_110a/tcbn05_bwph210l6p51cnod_mb_svt.gds \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_mb_ulvt_110a/tcbn05_bwph210l6p51cnod_mb_ulvt.gds \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Back_End/gds/tcbn05_bwph210l6p51cnod_mb_ulvtll_110a/tcbn05_bwph210l6p51cnod_mb_ulvtll.gds \
"


#################################################################################################################################################################################################
###	RC view
#################################################################################################################################################################################################
set rc_corner(cworst) /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/cworst/Tech/cworst_CCworst_T/qrcTechFile
set rc_corner(cworst,rc_variation) 0.1
set rc_corner(cworst,spef_0) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_cworst_0.spef.gz"
set rc_corner(cworst,spef_125) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_cworst_125.spef.gz"
set rc_corner(rcworst) /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/rcworst/Tech/rcworst_CCworst_T/qrcTechFile
set rc_corner(rcworst,rc_variation) 0.1
set rc_corner(rcworst,spef_0) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_rcworst_0.spef.gz"
set rc_corner(rcworst,spef_125) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_rcworst_125.spef.gz"
set rc_corner(cbest) /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/cbest/Tech/cbest_CCbest_T/qrcTechFile
set rc_corner(cbest,rc_variation) 0.1
set rc_corner(cbest,spef_0) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_cbest_0.spef.gz"
set rc_corner(cbest,spef_125) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_cbest_125.spef.gz"
set rc_corner(rcbest) /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/rcbest/Tech/rcbest_CCbest_T/qrcTechFile
set rc_corner(rcbest,rc_variation) 0.1
set rc_corner(rcbest,spef_0) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_rcbest_0.spef.gz"
set rc_corner(rcbest,spef_125) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_rcbest_125.spef.gz"
set rc_corner(typical)  /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/typical/Tech/typical/qrcTechFile
set rc_corner(typical,rc_variation) 0.1
set rc_corner(typical,spef_25) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_typical_25.spef.gz"
set rc_corner(typical,spef_85) "$SPEF_DIR/out/${DESIGN_NAME}.${STAGE}_typical_85.spef.gz"


#################################################################################################################################################################################################
###	timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ssgnp_0p675v_125c
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
\
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/ssgnp_ccwt0p675v125c/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0/ssgnp_ccwt0p675v125c/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtllssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
"


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ssgnp_0p675v_0c
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
\
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/ssgnp_ccwt0p675v125c/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v0c/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v0c/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0/ssgnp_ccwt0p675v0c/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtllssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
"


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ffgnp_0p825v_125c
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
\
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/ssgnp_ccwt0p675v125c/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v125c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v125c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v125c/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v125c/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0/ffgnp_ccbt0p825v125c/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtllffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
"


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ffgnp_0p825v_0c
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
\
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/ssgnp_ccwt0p675v125c/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v0c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v0c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v0c/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v0c/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0/ffgnp_ccbt0p825v0c/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtllffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
"

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER tt_0p75v_85c
set pvt_corner($PVT_CORNER,temperature) "85"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtlltt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtlltt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtlltt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtlltt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
\
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/tt0p75v85c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/tt0p75v85c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/tt0p75v85c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0/tt0p75v25c/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvttt_0p75v_85c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtlltt_0p75v_85c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svttt_0p75v_85c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvttt_0p75v_85c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtlltt_0p75v_85c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvttt_0p75v_85c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtlltt_0p75v_85c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svttt_0p75v_85c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvttt_0p75v_85c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtlltt_0p75v_85c_typical_sp.socv \
"

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER tt_0p75v_25c
set pvt_corner($PVT_CORNER,temperature) "25"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtlltt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtlltt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtlltt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/LVF/CCS/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtlltt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
\
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/tt0p75v25c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/tt0p75v25c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/tt0p75v25c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p128x136m1b2w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p160x132m1b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BRCM_N5/compout/views/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0/tt0p75v25c/sassls0g4u1p3136x156m4b4w1c1p0d0r1rm4rw10e18zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvt_110b/tcbn05_bwph210l6p51cnod_base_lvttt_0p75v_25c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_lvtll_110b/tcbn05_bwph210l6p51cnod_base_lvtlltt_0p75v_25c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_svt_110b/tcbn05_bwph210l6p51cnod_base_svttt_0p75v_25c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvt_110b/tcbn05_bwph210l6p51cnod_base_ulvttt_0p75v_25c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/base/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_base_ulvtll_110b/tcbn05_bwph210l6p51cnod_base_ulvtlltt_0p75v_25c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvt_110b/tcbn05_bwph210l6p51cnod_mb_lvttt_0p75v_25c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/lvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_lvtll_110b/tcbn05_bwph210l6p51cnod_mb_lvtlltt_0p75v_25c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/svt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_svt_110b/tcbn05_bwph210l6p51cnod_mb_svttt_0p75v_25c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvt/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvt_110b/tcbn05_bwph210l6p51cnod_mb_ulvttt_0p75v_25c_typical_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/TSMC/tcbn05_bwph210l6p51cnod/H210/mb/ulvtll/110b/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn05_bwph210l6p51cnod_mb_ulvtll_110b/tcbn05_bwph210l6p51cnod_mb_ulvtlltt_0p75v_25c_typical_sp.socv \
"


#################################################################################################################################################################################################
###	design setting 
#################################################################################################################################################################################################
set DEFAULT_SITE core
set MAX_ROUTING_LAYER 14
set MIN_ROUTING_LAYER 2
set PWR_NET     [list VDD]
set GND_NET     [list VSS]
set PWR_PINS    [list VDD VPP VDDF]
set GND_PINS    [list VSS VBB]

if { (![info exists DEF_FILE] || $DEF_FILE == "None") && (  ([info exists PYISICAL_SYN] && $PYISICAL_SYN == "true")  || [get_db / .program_short_name] == "innovus" ) } {
    
    if { [info exists fe_mode] && $fe_mode } {
        set DEF_FILE "./${DESIGN_NAME}_floorplan.def.gz"    
    } elseif { [get_db / .program_short_name] == "innovus" && [file exists ./out/def/${DESIGN_NAME}.floorplan.def.gz] } { 
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

set VT_GROUPS(SVT)    *SVT*
set VT_GROUPS(LVT)    *LVT*
set VT_GROUPS(ULVT)   *ULVT*
set VT_GROUPS(LVTLL)  *LVTLL*
set VT_GROUPS(ULVTLL) *ULTLL*


set DONT_SCAN_FF ""
set DONT_TOUCH_INST "*DONT_TOUCH* *i_spare*" ; # REMOVED spare_i from dont touch
set SIZE_ONLY_INST "*SIZE_ONLY*"

set DONT_USE_CELLS " \
*D32* \
*D24* \
*D20* \
*D18* \
*G* \
"

set DO_USE_CELLS " \
CKLHQD?BWP210H6P51CNODULVT \
"

#################################################################################################################################################################################################
###	place setting 
#################################################################################################################################################################################################
set IOBUFFER_CELL "BUFFD4BWP210H6P51CNODSVT"
set USEABLE_IOBUFFER_CELL {BUFFD4BWPBWP210H6P51PD*VT BUFFD6BWPBWP210H6P51PD*VT BUFFD8BWPBWP210H6P51PD*VT BUFFD12BWPBWP210H6P51PD*VT}
set SPARE_MODULE { \
CKLHQD4BWP210H6P51CNODULVT {  1 0 } \
SDFSNQD4BWP210H6P51CNODULVT {  5 0 } \
AO22D4BWP210H6P51CNODULVT {  5 1 } \
BUFFD8BWP210H6P51CNODULVT { 10 0 } \
MAOI22D4BWP210H6P51CNODULVT {  5 1 } \
IND2D4BWP210H6P51CNODULVT {  4 0 } \
INR2D4BWP210H6P51CNODULVT {  4 1 } \
INVD8BWP210H6P51CNODULVT { 10 0 } \
INR2D4BWP210H6P51CNODULVT {  1 1 } \
MUX2D4BWP210H6P51CNODULVT {  5 0 } \
IND2D4BWP210H6P51CNODULVT { 10 1 } \
AN2D4BWP210H6P51CNODULVT {  5 0 } \
OR2D4BWP210H6P51CNODULVT {  5 1 } \
IND3D4BWP210H6P51CNODULVT {  5 0 } \
INR3D4BWP210H6P51CNODULVT {  5 1 } \
OA21D4BWP210H6P51CNODULVT { 10 0 } \
OA22D4BWP210H6P51CNODULVT {  1 1 } \
OAI21D4BWP210H6P51CNODULVT {  5 0 } \
XNR2D4BWP210H6P51CNODULVT {  5 1 }} 

#################################################################################################################################################################################################
###	floorplan setting 
#################################################################################################################################################################################################
set DIFFUSION_FORBIDDEN_SPACING 0.277 

set ENDCAPS(RIGHT_EDGE) 		BOUNDARYLEFTBWP210H6P51CNODSVT
set ENDCAPS(LEFT_EDGE) 			BOUNDARYRIGHTBWP210H6P51CNODSVT
set ENDCAPS(LEFT_TOP_CORNER) 		BOUNDARYPCORNERBWP210H6P51CNODSVT
set ENDCAPS(LEFT_BOTTOM_CORNER) 	BOUNDARYPCORNERBWP210H6P51CNODSVT
set ENDCAPS(TOP_EDGE) 			{BOUNDARYPROW8BWP210H6P51CNODSVT BOUNDARYPROW4BWP210H6P51CNODSVT BOUNDARYPROW2BWP210H6P51CNODSVT BOUNDARYPROW1BWP210H6P51CNODSVT}
set ENDCAPS(BOTTOM_EDGE) 		{BOUNDARYPROW8BWP210H6P51CNODSVT BOUNDARYPROW4BWP210H6P51CNODSVT BOUNDARYPROW2BWP210H6P51CNODSVT BOUNDARYPROW1BWP210H6P51CNODSVT}
set ENDCAPS(RIGHT_TOP_EDGE) 		BOUNDARYPINCORNERBWP210H6P51CNODSVT
set ENDCAPS(RIGHT_BOTTOM_EDGE) 		BOUNDARYPINCORNERBWP210H6P51CNODSVT
set ENDCAPS(RIGHT_BOTTOM_EDGE_NEIGHBOR) BOUNDARYPROWRGAPBWP210H6P51CNODSVT	
set ENDCAPS(RIGHT_TOP_EDGE_NEIGHBOR) 	BOUNDARYPROWRGAPBWP210H6P51CNODSVT	


set TAPCELL "{TAPCELLFIN6BWP210H6P51CNODSVT rule 15.8 boundary_layer LUP_SRM boundary_rule 15.8} {TAPCELLBWP210H6P51CNODSVT rule 22.5}"
set SWAP_WELL_TAPS ""
set TIEHCELL "TIEHXPBWP210H6P51CNODSVT"
set TIELCELL "TIELXNBWP210H6P51CNODSVT"
set ANTENNA_CELL_NAME "ANTENNABWP210H6P51CNODSVT"

set PRE_PLACE_DECAP "DCAP16XPBWP210H6P51CNODLVT"
set PRE_PLACE_ECO_DCAP "GDCAP7DHXPBWP210H6P51CNODLVT"

set DCAP_CELLS_LIST "DCAP64XPBWP210H6P51CNODSVT DCAP64XPBWP210H6P51CNODLVTLL DCAP64XPBWP210H6P51CNODLVT DCAP32XPBWP210H6P51CNODSVT DCAP32XPBWP210H6P51CNODLVTLL DCAP32XPBWP210H6P51CNODLVT DCAP16XPBWP210H6P51CNODSVT DCAP16XPBWP210H6P51CNODLVTLL DCAP16XPBWP210H6P51CNODLVT DCAP8XPBWP210H6P51CNODSVT DCAP8XPBWP210H6P51CNODLVTLL DCAP8XPBWP210H6P51CNODLVT DCAP4XPBWP210H6P51CNODSVT DCAP4XPBWP210H6P51CNODLVTLL DCAP4XPBWP210H6P51CNODLVT"
set FILLER64_CELLS_LIST "FILL64BWP210H6P51CNODSVT FILL64BWP210H6P51CNODLVTLL FILL64BWP210H6P51CNODLVT FILL64BWP210H6P51CNODULVTLL FILL64BWP210H6P51CNODULVT FILL64BWP210H6P51CNODELVT"
set FILLER32_CELLS_LIST "FILL32BWP210H6P51CNODSVT FILL32BWP210H6P51CNODLVTLL FILL32BWP210H6P51CNODLVT FILL32BWP210H6P51CNODULVTLL FILL32BWP210H6P51CNODULVT FILL32BWP210H6P51CNODELVT"
set FILLER16_CELLS_LIST "FILL16BWP210H6P51CNODSVT FILL16BWP210H6P51CNODLVTLL FILL16BWP210H6P51CNODLVT FILL16BWP210H6P51CNODULVTLL FILL16BWP210H6P51CNODULVT FILL16BWP210H6P51CNODELVT"
set FILLER8_CELLS_LIST  "FILL8BWP210H6P51CNODSVT FILL8BWP210H6P51CNODLVTLL FILL8BWP210H6P51CNODLVT FILL8BWP210H6P51CNODULVTLL FILL8BWP210H6P51CNODULVT FILL8BWP210H6P51CNODELVT"
set FILLER4_CELLS_LIST  "FILL4BWP210H6P51CNODSVT FILL4BWP210H6P51CNODLVTLL FILL4BWP210H6P51CNODLVT FILL4BWP210H6P51CNODULVTLL FILL4BWP210H6P51CNODULVT FILL4BWP210H6P51CNODELVT"
set FILLER3_CELLS_LIST  "FILL3BWP210H6P51CNODSVT FILL3BWP210H6P51CNODLVTLL FILL3BWP210H6P51CNODLVT FILL3BWP210H6P51CNODULVTLL FILL3BWP210H6P51CNODULVT FILL3BWP210H6P51CNODELVT"
set FILLER2_CELLS_LIST  "FILL2BWP210H6P51CNODSVT FILL2BWP210H6P51CNODLVTLL FILL2BWP210H6P51CNODLVT FILL2BWP210H6P51CNODULVTLL FILL2BWP210H6P51CNODULVT FILL2BWP210H6P51CNODELVT"
set FILLER1_CELLS_LIST  "FILL1BWP210H6P51CNODSVT FILL1BWP210H6P51CNODLVTLL FILL1BWP210H6P51CNODLVT FILL1BWP210H6P51CNODULVTLL FILL1BWP210H6P51CNODULVT FILL1BWP210H6P51CNODELVT"

set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"


set ADD_FILLERS_SWAP_CELL "\
{FILL1BWP210H6P51CNODSVT FILL1NOBCMBWP210H6P51CNODSVT} \
{FILL1BWP210H6P51CNODLVTLL FILL1NOBCMBWP210H6P51CNODLVTLL} \
{FILL1BWP210H6P51CNODLVT FILL1NOBCMBWP210H6P51CNODLVT} \
{FILL1BWP210H6P51CNODULVTLL FILL1NOBCMBWP210H6P51CNODULVTLL} \
{FILL1BWP210H6P51CNODULVT FILL1NOBCMBWP210H6P51CNODULVT} \
{FILL1BWP210H6P51CNODELVT FILL1NOBCMBWP210H6P51CNODELVT} \
"

###################################################################################################################################################################################################
###	CTS setting 
###################################################################################################################################################################################################

set CTS_BUFFER_CELLS   {DCCKBD6BWP210H6P51CNODULVT DCCKBD8BWP210H6P51CNODULVT DCCKBD10BWP210H6P51CNODULVT DCCKBD12BWP210H6P51CNODULVT DCCKBD14BWP210H6P51CNODULVT DCCKBD16BWP210H6P51CNODULVT}
set CTS_INVERTER_CELLS {CKND2BWP210H6P51CNODLVT CKND3BWP210H6P51CNODLVT CKND4BWP210H6P51CNODLVT CKND5BWP210H6P51CNODLVT DCCKND6BWP210H6P51CNODULVT DCCKND8BWP210H6P51CNODULVT DCCKND10BWP210H6P51CNODULVT DCCKND12BWP210H6P51CNODULVT DCCKND14BWP210H6P51CNODULVT DCCKND16BWP210H6P51CNODULVT}
set CTS_LOGIC_CELLS    {CKXOR2D4BWP210H6P51CNODULVT CKXOR2D8BWP210H6P51CNODULVT CKOR2D4BWP210H6P51CNODULVT CKOR2D8BWP210H6P51CNODULVT CKNR2D4BWP210H6P51CNODULVT CKNR2D8BWP210H6P51CNODULVT CKAN2D4BWP210H6P51CNODULVT CKAN2D8BWP210H6P51CNODULVT CKND2D4BWP210H6P51CNODULVT CKND2D8BWP210H6P51CNODULVT CKMUX2D4BWP210H6P51CNODULVT CKMUX2D8BWP210H6P51CNODULVT}
set CTS_CLOCK_GATING_CELLS {CKLHQD4BWP210H6P51CNODULVT CKLHQD5BWP210H6P51CNODULVT CKLHQD6BWP210H6P51CNODULVT CKLHQD8BWP210H6P51CNODULVT CKLHQD10BWP210H6P51CNODULVT CKLHQD12BWP210H6P51CNODULVT CKLHQD14BWP210H6P51CNODULVT CKLHQD16BWP210H6P51CNODULVT CKLNQD4BWP210H6P51CNODULVT CKLNQD5BWP210H6P51CNODULVT CKLNQD6BWP210H6P51CNODULVT CKLNQD8BWP210H6P51CNODULVT CKLNQD10BWP210H6P51CNODULVT CKLNQD12BWP210H6P51CNODULVT CKLNQD14BWP210H6P51CNODULVT CKLNQD16BWP210H6P51CNODULVT}
set CTS_CELLS_HALO [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]


set HOLD_FIX_CELLS_LIST [list \
DEL* \
] 
#################################################################################################################################################################################################
###	tools dependent
#################################################################################################################################################################################################
if {[info command distribute_partition] == ""} {
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






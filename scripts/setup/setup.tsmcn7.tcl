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

#################################################################################################################################################################################################
###	running scenarios 
#################################################################################################################################################################################################
if {[info exists STAGE] && $STAGE == "route"} {
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
        set sdc_files(func) "\
         ../inter/${DESIGN_NAME}.pre.sdc \
         ../inter/${DESIGN_NAME}.sdc \
         ../inter/${DESIGN_NAME}.post.sdc \
        "
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
set GDS_MAP_FILE      "/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/APR/cdns/1.3.1C/PRTF_Innovus_7nm_001_Cad_V13_1c/PR_tech/Cadence/GdsOutMap/PRTF_Innovus_N7_gdsout_15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R.13_1c.map.mod"
set DFM_REDUNDANT_VIA "/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/APR/cdns/1.3.1C/PRTF_Innovus_7nm_001_Cad_V13_1c/PR_tech/Cadence/script/PRTF_Innovus_N7_DFM_via_swap_reference_command.13_1c.tcl"
set METAL_FILL_RUNSET "/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/BEOL_dummy/cdns/1.3b/Dummy_BEOL_Pegasus_7nm_001.13b"

set LEF_FILE_LIST " \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/APR/cdns/1.3.1C/PRTF_Innovus_7nm_001_Cad_V13_1c/PR_tech/Cadence/LefHeader/Standard/VHV/PRTF_Innovus_N7_15M_1X1Xa1Ya5Y2Yy2Yx2R_UTRDL_M1P57_M2P40_M3P44_M4P76_M5P76_M6P76_M7P76_M8P76_M9P76_H240.13_1c.tlef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_base_svt_130a/lef/tcbn07_bwph240l8p57pd_base_svt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_base_svt_130a/lef/tcbn07_bwph240l8p57pd_base_svt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_mb_svt_130a/lef/tcbn07_bwph240l8p57pd_mb_svt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_mb_svt_130a/lef/tcbn07_bwph240l8p57pd_mb_svt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_base_lvt_130a/lef/tcbn07_bwph240l8p57pd_base_lvt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_base_lvt_130a/lef/tcbn07_bwph240l8p57pd_base_lvt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_mb_lvt_130a/lef/tcbn07_bwph240l8p57pd_mb_lvt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_mb_lvt_130a/lef/tcbn07_bwph240l8p57pd_mb_lvt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_base_ulvt_130a/lef/tcbn07_bwph240l8p57pd_base_ulvt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_base_ulvt_130a/lef/tcbn07_bwph240l8p57pd_base_ulvt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_mb_ulvt_130a/lef/tcbn07_bwph240l8p57pd_mb_ulvt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l8p57pd_mb_ulvt_130a/lef/tcbn07_bwph240l8p57pd_mb_ulvt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_base_svt_130a/lef/tcbn07_bwph240l11p57pd_base_svt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_base_svt_130a/lef/tcbn07_bwph240l11p57pd_base_svt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_mb_svt_130a/lef/tcbn07_bwph240l11p57pd_mb_svt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_mb_svt_130a/lef/tcbn07_bwph240l11p57pd_mb_svt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_base_lvt_130a/lef/tcbn07_bwph240l11p57pd_base_lvt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_base_lvt_130a/lef/tcbn07_bwph240l11p57pd_base_lvt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_mb_lvt_130a/lef/tcbn07_bwph240l11p57pd_mb_lvt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_mb_lvt_130a/lef/tcbn07_bwph240l11p57pd_mb_lvt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_base_ulvt_130a/lef/tcbn07_bwph240l11p57pd_base_ulvt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_base_ulvt_130a/lef/tcbn07_bwph240l11p57pd_base_ulvt_par.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_mb_ulvt_130a/lef/tcbn07_bwph240l11p57pd_mb_ulvt.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/lef/tcbn07_bwph240l11p57pd_mb_ulvt_130a/lef/tcbn07_bwph240l11p57pd_mb_ulvt_par.lef \
"

set GDS_FILE_LIST " \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvt.gds \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Back_End/gds/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvt.gds \
"

if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lef files to lef files list"
  set LEF_FILE_LIST "$LEF_FILE_LIST \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.plef \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.plef \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.plef \
  "
  
  puts "-I- add $DESIGN_NAME gds files to gds files list"
  set GDS_FILE_LIST "$GDS_FILE_LIST \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.gds \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.gds \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.gds \
  "

}

#################################################################################################################################################################################################
###	RC view
#################################################################################################################################################################################################
set rc_corner(cworst) /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/cworst/Tech/cworst_CCworst_T/qrcTechFile
set rc_corner(cworst,rc_variation) 0.1
set rc_corner(rcworst) /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/rcworst/Tech/rcworst_CCworst_T/qrcTechFile
set rc_corner(rcworst,rc_variation) 0.1
set rc_corner(cbest) /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/cbest/Tech/cbest_CCbest_T/qrcTechFile
set rc_corner(cbest,rc_variation) 0.1
set rc_corner(rcbest) /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/rcbest/Tech/rcbest_CCbest_T/qrcTechFile
set rc_corner(rcbest,rc_variation) 0.1
set rc_corner(typical)  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/typical/Tech/typical/qrcTechFile
set rc_corner(typical,rc_variation) 0.1


#################################################################################################################################################################################################
###	timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ssgnp_0p675v_125c
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
"
set pvt_corner($PVT_CORNER,ocv) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtssgnp_0p675v_125c_cworst_CCworst_T_sp.socv \
"

if {$DESIGN_NAME == "gmu_cluster" } {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v125c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v125c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v125c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
"
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ssgnp_0p675v_0c
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
"
set pvt_corner($PVT_CORNER,ocv) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_sp.socv \
"

if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v0c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
"
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ffgnp_0p825v_125c
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) " \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
"
set pvt_corner($PVT_CORNER,ocv) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_sp.socv \
"
if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v125c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v125c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ffgnp_ccbt0p825v125c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
  "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ffgnp_0p825v_0c
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
"
set pvt_corner($PVT_CORNER,ocv) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_sp.socv \
"
if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v0c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v0c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ffgnp_ccbt0p825v0c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
"
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER tt_0p75v_85c
set pvt_corner($PVT_CORNER,temperature) "85"
set pvt_corner($PVT_CORNER,timing) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
"
set pvt_corner($PVT_CORNER,ocv) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvttt_0p75v_85c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvttt_0p75v_85c_typical_sp.socv \
"
if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/tt0p75v85c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/tt0p75v85c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/tt0p75v85c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
"
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER tt_0p75v_25c
set pvt_corner($PVT_CORNER,temperature) "25"
set pvt_corner($PVT_CORNER,timing) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
"
set pvt_corner($PVT_CORNER,ocv) "\
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvttt_0p75v_25c_typical_sp.socv \
  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/timing_margin/SPM/socv/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvttt_0p75v_25c_typical_sp.socv \
"
if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/tt0p75v25c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/tt0p75v25c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/tt0p75v25c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
"
}


#################################################################################################################################################################################################
###	design setting 
#################################################################################################################################################################################################
set MAX_ROUTING_LAYER 12
set MIN_ROUTING_LAYER 2
set PWR_NET     [list VDD]
set GND_NET     [list VSS]
set PWR_PINS    [list VDD VBP]
set GND_PINS    [list VSS VBN]

if { ![info exists DEF_FILE] || $DEF_FILE == "None" } {
    
    if { $fe_mode } {
        set DEF_FILE "./${DESIGN_NAME}_floorplan.def.gz"    
    } else {
        set DEF_FILE "../inter/${DESIGN_NAME}_floorplan.def.gz"
    }

}
set FP_FILE  "../inter/floorplan_constraints.tcl"        

set VT_GROUPS(SVT8)    *BWP240H8P57PDSVT
set VT_GROUPS(SVT11)   *BWP240H11P57PDSVT
set VT_GROUPS(LVT8)    *BWP240H8P57PDLVT
set VT_GROUPS(LVT11)   *BWP240H11P57PDLVT
set VT_GROUPS(ULVT8)   *BWP240H8P57PDULVT
set VT_GROUPS(ULVT11)  *BWP240H11P57PDULVT


set DONT_SCAN_FF ""
set DONT_TOUCH_INST ""
set SIZE_ONLY_INST ""

set DONT_USE_CELLS " \
*D0BWP* \
*D32* \
*D24* \
*D20* \
*D18* \
SDFQOPTBB* \
XNR2D1BWP* \
NR2SKPD1BWP* \
NR2D1BWP* \
ND2SKND1BWP* \
ND2D1BWP* \
INVSKPD2BWP* \
INVSKPD1BWP* \
INVSKND2BWP* \
INVSKND1BWP* \
INR2D1BWP* \
IND2D1BWP* \
CKNR2D1BWP* \
CKND2D1BWP* \
CKND2BWP* \
CKND1BWP* \
CKBD1BWP* \
BUFFSKPD1BWP* \
BUFFSKND1BWP* \
BUFTD* \
MB*SRLSDFRPQ* \
MB*SRLSDFSNQ* \
MB*SRLSDFKRPQ* \
*ULVT \
"

#################################################################################################################################################################################################
###	place setting 
#################################################################################################################################################################################################
set IOBUFFER_CELL "BUFFD4BWP240H8P57PDSVT"
set USEABLE_IOBUFFER_CELL {BUFFD4BWP240H*P57PD*VT BUFFD6BWP240H*P57PD*VT BUFFD8BWP240H*P57PD*VT BUFFD12BWP240H*P57PD*VT}
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
###	floorplan setting 
#################################################################################################################################################################################################
set DIFFUSION_FORBIDDEN_SPACING 0.277 

set ENDCAPS_LEFT_EDGE_EVEN	    BOUNDARYRIGHTBWP240H8P57PDSVT  
set ENDCAPS_LEFT_EDGE_ODD	    BOUNDARYRIGHTBWP240H8P57PDSVT  
set ENDCAPS_LEFT_TOP_CORNER_EVEN    BOUNDARYPCORNERBWP240H8P57PDSVT  
set ENDCAPS_LEFT_TOP_CORNER_ODD     BOUNDARYPCORNERBWP240H8P57PDSVT 
set ENDCAPS_LEFT_BOTTOM_CORNER_EVEN BOUNDARYNCORNERBWP240H8P57PDSVT 
set ENDCAPS_LEFT_BOTTOM_CORNER_ODD  BOUNDARYNCORNERBWP240H8P57PDSVT 
set ENDCAPS_TOP_EDGE		   {BOUNDARYPROW2BWP240H8P57PDSVT BOUNDARYPROW4BWP240H8P57PDSVT BOUNDARYPROW8BWP240H8P57PDSVT} 
set ENDCAPS_BOTTOM_EDGE  	   {BOUNDARYNROW2BWP240H8P57PDSVT BOUNDARYNROW4BWP240H8P57PDSVT BOUNDARYNROW8BWP240H8P57PDSVT}
set ENDCAPS_RIGHT_EDGE_EVEN	    BOUNDARYLEFTBWP240H8P57PDSVT 
set ENDCAPS_RIGHT_EDGE_ODD	    BOUNDARYLEFTBWP240H8P57PDSVT
set ENDCAPS_RIGHT_TOP_EDGE_EVEN     BOUNDARYPINCORNERBWP240H8P57PDSVT
set ENDCAPS_RIGHT_TOP_EDGE_ODD	    BOUNDARYPINCORNERBWP240H8P57PDSVT
set ENDCAPS_RIGHT_BOTTOM_EDGE_EVEN  BOUNDARYNINCORNERBWP240H8P57PDSVT
set ENDCAPS_RIGHT_BOTTOM_EDGE_ODD   BOUNDARYNINCORNERBWP240H8P57PDSVT

set TAPCELL TAPCELLBWP240H8P57PDSVT
set SWAP_WELL_TAPS { TAPCELLBWP240H8P57PDSVT TAPCELLL1R2BWP240H8P57PDSVT TAPCELLL2R1BWP240H8P57PDSVT TAPCELLL1R1BWP240H8P57PDSVT }
set TIEHCELL TIEHXPBWP240H11P57PDSVT
set TIELCELL TIELXNBWP240H11P57PDSVT
set ANTENNA_CELL_NAME "ANTENNABWP240H8P57PDSVT"

set PRE_PLACE_DECAP "DCAP16XPXNDFMBWP240H11P57PDSVT"
set PRE_PLACE_ECO_DCAP "GDCAP5DHXPBWP240H11P57PDLVT"
#set PRE_PLACE_ECO_DCAP "GDCAP4SHXPBWP240H8P57PDLVT"

set DCAP_CELLS_LIST "DCAP64XPBWP240H11P57PDSVT DCAP64XPXNBWP240H11P57PDSVT DCAP32XPBWP240H11P57PDSVT DCAP32XPXNBWP240H11P57PDSVT DCAP16XPBWP240H11P57PDSVT DCAP16XPXNBWP240H11P57PDSVT DCAP8XPBWP240H11P57PDSVT DCAP8XPXNBWP240H11P57PDSVT DCAP4XPBWP240H11P57PDSVT"
set FILLER64_CELLS_LIST "FILL64BWP240H11P57PDSVT FILL64BWP240H11P57PDLVT FILL64BWP240H11P57PDULVT FILL64BWP240H8P57PDSVT FILL64BWP240H8P57PDLVT FILL64BWP240H8P57PDULVT"
set FILLER32_CELLS_LIST "FILL32BWP240H11P57PDSVT FILL32BWP240H11P57PDLVT FILL32BWP240H11P57PDULVT FILL32BWP240H8P57PDSVT FILL32BWP240H8P57PDLVT FILL32BWP240H8P57PDULVT"
set FILLER16_CELLS_LIST "FILL16BWP240H11P57PDSVT FILL16BWP240H11P57PDLVT FILL16BWP240H11P57PDULVT FILL16BWP240H8P57PDSVT FILL16BWP240H8P57PDLVT FILL16BWP240H8P57PDULVT"
set FILLER12_CELLS_LIST "FILL12BWP240H11P57PDSVT FILL12BWP240H11P57PDLVT FILL12BWP240H11P57PDULVT FILL12BWP240H8P57PDSVT FILL12BWP240H8P57PDLVT FILL12BWP240H8P57PDULVT"
set FILLER8_CELLS_LIST "FILL8BWP240H11P57PDSVT FILL8BWP240H11P57PDLVT FILL8BWP240H11P57PDULVT FILL8BWP240H8P57PDSVT FILL8BWP240H8P57PDLVT FILL8BWP240H8P57PDULVT"
set FILLER4_CELLS_LIST "FILL4BWP240H11P57PDSVT FILL4BWP240H11P57PDLVT FILL4BWP240H11P57PDULVT FILL4BWP240H8P57PDSVT FILL4BWP240H8P57PDLVT FILL4BWP240H8P57PDULVT"
set FILLER3_CELLS_LIST "FILL3BWP240H11P57PDSVT FILL3BWP240H11P57PDLVT FILL3BWP240H11P57PDULVT FILL3BWP240H8P57PDSVT FILL3BWP240H8P57PDLVT FILL3BWP240H8P57PDULVT"
set FILLER2_CELLS_LIST "FILL2BWP240H11P57PDSVT FILL2BWP240H11P57PDLVT FILL2BWP240H11P57PDULVT FILL2BWP240H8P57PDSVT FILL2BWP240H8P57PDLVT FILL2BWP240H8P57PDULVT"
set FILLER1_CELLS_LIST "FILL1BWP240H11P57PDSVT FILL1BWP240H11P57PDLVT FILL1BWP240H11P57PDULVT FILL1BWP240H8P57PDSVT FILL1BWP240H8P57PDLVT FILL1BWP240H8P57PDULVT"

set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"

set ADD_FILLERS_SWAP_CELL {\
{FILL1BWP240H11P57PDSVT FILL1NOBCMBWP240H11P57PDSVT} \
{FILL1BWP240H11P57PDLVT FILL1NOBCMBWP240H11P57PDLVT} \
{FILL1BWP240H11P57PDULVT FILL1NOBCMBWP240H11P57PDULVT} \
{FILL1BWP240H8P57PDSVT FILL1NOBCMBWP240H8P57PDSVT} \
{FILL1BWP240H8P57PDLVT FILL1NOBCMBWP240H8P57PDLVT} \
{FILL1BWP240H8P57PDULVT FILL1NOBCMBWP240H8P57PDULVT}}

###################################################################################################################################################################################################
###	CTS setting 
###################################################################################################################################################################################################

set CTS_BUFFER_CELLS   {DCCKBD6BWP240H11P57PDULVT DCCKBD8BWP240H11P57PDULVT DCCKBD10BWP240H11P57PDULVT DCCKBD12BWP240H11P57PDULVT DCCKBD14BWP240H11P57PDULVT DCCKBD16BWP240H11P57PDULVT}
set CTS_INVERTER_CELLS {DCCKND6BWP240H11P57PDULVT DCCKND8BWP240H11P57PDULVT DCCKND10BWP240H11P57PDULVT DCCKND12BWP240H11P57PDULVT DCCKND14BWP240H11P57PDULVT DCCKND16BWP240H11P57PDULVT}
set CTS_LOGIC_CELLS    {CKXOR2D4BWP240H11P57PDULVT CKXOR2D8BWP240H11P57PDULVT CKOR2D4BWP240H11P57PDULVT CKOR2D8BWP240H11P57PDULVT CKNR2D4BWP240H11P57PDULVT CKNR2D8BWP240H11P57PDULVT CKAN2D4BWP240H11P57PDULVT CKAN2D8BWP240H11P57PDULVT CKND2D4BWP240H11P57PDULVT CKND2D8BWP240H11P57PDULVT CKMUX2D4BWP240H11P57PDULVT CKMUX2D8BWP240H11P57PDULVT}
set CTS_CLOCK_GATING_CELLS {CKLHQD4BWP240H11P57PDULVT CKLHQD5BWP240H11P57PDULVT CKLHQD6BWP240H11P57PDULVT CKLHQD8BWP240H11P57PDULVT CKLHQD10BWP240H11P57PDULVT CKLHQD12BWP240H11P57PDULVT CKLHQD14BWP240H11P57PDULVT CKLHQD16BWP240H11P57PDULVT CKLNQD4BWP240H11P57PDULVT CKLNQD5BWP240H11P57PDULVT CKLNQD6BWP240H11P57PDULVT CKLNQD8BWP240H11P57PDULVT CKLNQD10BWP240H11P57PDULVT CKLNQD12BWP240H11P57PDULVT CKLNQD14BWP240H11P57PDULVT CKLNQD16BWP240H11P57PDULVT}

set CTS_CELLS_HALO [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]


set HOLD_FIX_CELLS_LIST [list \
DEL* \
] 
#################################################################################################################################################################################################
###	tools dependent
#################################################################################################################################################################################################
if { [get_db / .program_short_name] == "innovus" } {
	puts "-I- extra definition for [get_db / .program_short_name]"

	# Variables to set before loading libraries
	set_db add_route_vias_auto true ;                                       # (default : false
	set_db add_route_vias_advanced_rule true ;                              # (default : false
	set_db timing_derate_spatial_distance_unit 1nm
}
if { [get_db / .program_short_name] == "genus" } {
	set INNOVUS_FROM_GENUS "true"
}






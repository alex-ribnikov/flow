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
#	0.4	11/02/2021	OrY	    Update BRCM libs
#	0.5	21/02/2021	OrY	    Update BRCM libs + ff
#	0.6	TBD	OrY	    Add support to lib list (From FE)
#																								#
#																								#
#################################################################################################################################################################################################

if { [info exists ::env(SYN4RTL)] } { set fe_mode $::env(SYN4RTL) } else { set fe_mode false }


set mmmc_results ./scripts_local/mmmc_results.tcl

if {![info exists DESIGN_NAME]} {set DESIGN_NAME [lindex [split [pwd] "/"] end-2]}

#################################################################################################################################################################################################
###	running scenarios 
#################################################################################################################################################################################################
#set scenarios(setup) "func_ssgnp_0p675v_0c_cworst_setup "
#set scenarios(hold) "func_ffgnp_0p825v_125c_cworst_hold"
#set scenarios(dynamic) "func_ssgnp_0p675v_0c_cworst_setup"
#set scenarios(leakage) "func_ffgnp_0p825v_125c_cworst_hold"

set scenarios(setup)   "func_pssg_v0670_t000_cworst_setup "
set scenarios(hold)    "func_pffg_v0880_t125_cworst_hold"
set scenarios(dynamic) "func_pssg_v0670_t000_cworst_setup"
set scenarios(leakage) "func_pffg_v0880_t125_cworst_hold"

#################################################################################################################################################################################################
###	timing constraint 
#################################################################################################################################################################################################

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

puts "-I- sdc files are:\n [parray sdc_files]"

#################################################################################################################################################################################################
###	physical view
#################################################################################################################################################################################################

set LEF_FILE_LIST " \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK_Broadcom/SYNTH/cadence/15M_1x1xa1ya5y2yy2yx2r_R_enterprise.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK_Broadcom/SYNTH/cadence/var_15M_1x1xa1ya5y2yy2yx2r_R_enterprise.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/NXT_tsmc7ffp_sc06t0750v/lef/NXT_tsmc7ffp_sc06t0750v.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ck06t0750v/lef/tsmc7ffp_ck06t0750v.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ga06t0750v/lef/tsmc7ffp_ga06t0750v.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_hm06t0750v/lef/tsmc7ffp_hm06t0750v.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/lef/tsmc7ffp_lscore.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_sc06t0750v/lef/tsmc7ffp_sc06t0750v.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_top06t0750v/lef/tsmc7ffp_top06t0750v.lef \
"


if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
    puts "-I- add $DESIGN_NAME lef files to lef files list"
    set LEF_FILE_LIST "$LEF_FILE_LIST \
        /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper.lef \
        /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper.lef \
        /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper.lef \
    "
}

#if { ($DESIGN_NAME == "scr4_core_cluster") ||  ($DESIGN_NAME == "all")} {
#    puts "-I- add $DESIGN_NAME lef files to lef files list"
#    set LEF_FILE_LIST "$LEF_FILE_LIST \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sassls0g4l1p1024x15m8b2w0c1p0d0l1rm3sdrw00/sassls0g4l1p1024x15m8b2w0c1p0d0l1rm3sdrw00.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sassls0g4l1p1024x41m4b2w0c1p0d0l1rm3sdrw00/sassls0g4l1p1024x41m4b2w0c1p0d0l1rm3sdrw00.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sassls0g4l1p1024x144m4b2w0c1p0d0l1rm3sdrw00zh/sassls0g4l1p1024x144m4b2w0c1p0d0l1rm3sdrw00zh.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p4096x39m16b8w0c1p0d0l1rm3sdrw00/sadcls0g4l1p4096x39m16b8w0c1p0d0l1rm3sdrw00.plef \
#    "
#}
#
#if { ($DESIGN_NAME == "scr7_core_cluster") ||  ($DESIGN_NAME == "all")} {
#    puts "-I- add $DESIGN_NAME lef files to lef files list"
#    set LEF_FILE_LIST "$LEF_FILE_LIST \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p256x32m4b4w1c1p0d0l1rm3sdrw00zh/sadcls0g4l1p256x32m4b4w1c1p0d0l1rm3sdrw00zh.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p256x74m4b2w0c1p0d0l1rm3sdrw00zh/sadcls0g4l1p256x74m4b2w0c1p0d0l1rm3sdrw00zh.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadrls0g4l2p256x18m4b4w0c1p0d0l1rm3sdrw00/sadrls0g4l2p256x18m4b4w0c1p0d0l1rm3sdrw00.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p256x41m4b4w0c1p0d0l1rm3sdrw00/sadcls0g4l1p256x41m4b4w0c1p0d0l1rm3sdrw00.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p256x144m4b4w0c1p0d0l1rm3sdrw00/sadcls0g4l1p256x144m4b4w0c1p0d0l1rm3sdrw00.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadrls0g4u2p512x8m4b2w0c1p0d0l1rm3sdrw00/sadrls0g4u2p512x8m4b2w0c1p0d0l1rm3sdrw00.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p512x50m4b4w0c1p0d0l1rm3sdrw00/sadcls0g4l1p512x50m4b4w0c1p0d0l1rm3sdrw00.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p512x137m4b4w0c1p0d0l1rm3sdrw00/sadcls0g4l1p512x137m4b4w0c1p0d0l1rm3sdrw00.plef \
#    "
#}
#
#if { ($DESIGN_NAME == "cpu_wrap") ||  ($DESIGN_NAME == "all")} {
#    puts "-I- add $DESIGN_NAME lef files to lef files list"
#    set LEF_FILE_LIST "$LEF_FILE_LIST \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i0/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i0.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i1/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i1.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i2/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i2.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i3/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i3.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p8192x72m8b4w1c1p0d0l1rm3sdrw00zh/sadcls0g4l1p8192x72m8b4w1c1p0d0l1rm3sdrw00zh.plef \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/PLLTS7FFLAINTN/lef/PLLTS7FFLAINTN.lef \
#    "
#}



#################################################################################################################################################################################################
###	RC view
#################################################################################################################################################################################################
set rc_corner(cworst)   /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK_Broadcom/SYNTH/cadence/15M_1x1xa1ya5y2yy2yx2r_R07518FF_cworst_CCworst_1d25S.tch
set rc_corner(rcworst)  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK_Broadcom/SYNTH/cadence/15M_1x1xa1ya5y2yy2yx2r_R07518FF_rcworst_CCworst_1d25S.tch
#set rc_corner(cbest)    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/cbest/Tech/cbest_CCbest_T/qrcTechFile
#set rc_corner(rcbest)   /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/rcbest/Tech/rcbest_CCbest_T/qrcTechFile
#set rc_corner(typical)  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/typical/Tech/typical/qrcTechFile


#################################################################################################################################################################################################
###	timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#set PVT_CORNER ssgnp_0p675v_125c
set PVT_CORNER pssg_v0670_t125
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/NXT_tsmc7ffp_sc06t0750v/db/NXT_tsmc7ffp_sc06t0750v_pssg_s250_v0670_t125_xcwccwt.lib.gz \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ck06t0750v/db/tsmc7ffp_ck06t0750v_pssg_s250_v0670_t125_xcwccwt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ga06t0750v/db/tsmc7ffp_ga06t0750v_pssg_s250_v0670_t125_xcwccwt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_hm06t0750v/db/tsmc7ffp_hm06t0750v_pssg_s250_v0670_t125_xcwccwt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t125_o0760_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t125_o0670_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t125_o0830_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t125_o0550_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t125_o0720_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t125_o0880_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t125_o0960_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t125_o0600_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_sc06t0750v/db/tsmc7ffp_sc06t0750v_pssg_s250_v0670_t125_xcwccwt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_top06t0750v/db/tsmc7ffp_top06t0750v_pssg_s250_v0670_t125_xcwccwt.lib.gz       \
"

if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
 	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
  "
}


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#set PVT_CORNER ssgnp_0p675v_125c
set PVT_CORNER pssg_v0670_t000
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/NXT_tsmc7ffp_sc06t0750v/db/NXT_tsmc7ffp_sc06t0750v_pssg_s250_v0670_t000_xcwccwt.lib.gz \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ck06t0750v/db/tsmc7ffp_ck06t0750v_pssg_s250_v0670_t000_xcwccwt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ga06t0750v/db/tsmc7ffp_ga06t0750v_pssg_s250_v0670_t000_xcwccwt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_hm06t0750v/db/tsmc7ffp_hm06t0750v_pssg_s250_v0670_t000_xcwccwt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t000_o0760_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t000_o0670_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t000_o0600_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pssg_s250_v0670_t000_o0720_xcwccwt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_sc06t0750v/db/tsmc7ffp_sc06t0750v_pssg_s250_v0670_t000_xcwccwt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_top06t0750v/db/tsmc7ffp_top06t0750v_pssg_s250_v0670_t000_xcwccwt.lib.gz       \
"

if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
 	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
  "
}


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER pffg_v0880_t125
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ga06t0750v/db/tsmc7ffp_ga06t0750v_pffg_s250_v0880_t125_xcbccbt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ck06t0750v/db/tsmc7ffp_ck06t0750v_pffg_s250_v0880_t125_xcbccbt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_hm06t0750v/db/tsmc7ffp_hm06t0750v_pffg_s250_v0880_t125_xcbccbt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t125_o0500_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t125_o0720_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t125_o0670_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t125_o0600_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t125_o0550_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t125_o0830_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t125_o0960_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t125_o0880_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t125_o0760_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_top06t0750v/db/tsmc7ffp_top06t0750v_pffg_s250_v0880_t125_xcbccbt.lib.gz       \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_sc06t0750v/db/tsmc7ffp_sc06t0750v_pffg_s250_v0880_t125_xcbccbt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/NXT_tsmc7ffp_sc06t0750v/db/NXT_tsmc7ffp_sc06t0750v_pffg_s250_v0880_t125_xcbccbt.lib.gz \
"

if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
 	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
  "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER pffg_v0880_t-40
set pvt_corner($PVT_CORNER,temperature) "-40"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ck06t0750v/db/tsmc7ffp_ck06t0750v_pffg_s250_v0880_t-40_xcbccbt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_hm06t0750v/db/tsmc7ffp_hm06t0750v_pffg_s250_v0880_t-40_xcbccbt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ga06t0750v/db/tsmc7ffp_ga06t0750v_pffg_s250_v0880_t-40_xcbccbt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t-40_o0500_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t-40_o0550_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t-40_o0720_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t-40_o0670_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t-40_o0830_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t-40_o0600_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t-40_o0960_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t-40_o0880_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0880_t-40_o0760_xcbccbt.lib.gz           \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_top06t0750v/db/tsmc7ffp_top06t0750v_pffg_s250_v0880_t-40_xcbccbt.lib.gz       \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_sc06t0750v/db/tsmc7ffp_sc06t0750v_pffg_s250_v0880_t-40_xcbccbt.lib.gz         \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/NXT_tsmc7ffp_sc06t0750v/db/NXT_tsmc7ffp_sc06t0750v_pffg_s250_v0880_t-40_xcbccbt.lib.gz \
"

if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
 	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
  "
}



#
##################################################################################################################################################################################################
####	timing view
##################################################################################################################################################################################################
##--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
##set PVT_CORNER ssgnp_0p675v_125c
#set PVT_CORNER ffgnp_0p720v_125c
#set pvt_corner($PVT_CORNER,temperature) "125"
#set pvt_corner($PVT_CORNER,timing) "\
#   /project/nxt008/bravoSTD/tsmc7ffp_ck06t0750v/db/tsmc7ffp_ck06t0750v_pssg_s250_v0720_t125_xcwccwt.lib \
#   /project/nxt008/bravoSTD/tsmc7ffp_sc06t0750v/db/tsmc7ffp_sc06t0750v_pssg_s250_v0720_t125_xcwccwt.lib \
#   /project/nxt008/bravoSTD/tsmc7ffp_top06t0750v/db/tsmc7ffp_top06t0750v_pssg_s250_v0720_t125_xcwccwt.lib \
#"
#
###############################################
## No BRCM MEMS for now - taken from ff825 125c
###############################################
#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#   /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v125c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
#   /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v125c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
#   /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ffgnp_ccbt0p825v125c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
#  "
#}


#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v125c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
#	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v125c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v125c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
#"
#}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#set PVT_CORNER ssgnp_0p675v_0c
#set pvt_corner($PVT_CORNER,temperature) "0"
#set pvt_corner($PVT_CORNER,timing) "\
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtssgnp_0p675v_0c_cworst_CCworst_T_hm_lvf_p_ccs.lib.gz \
#"
#
#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
#	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v0c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
#"
#}
#
#if { ($DESIGN_NAME == "scr4_core_cluster") ||  ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sassls0g4l1p1024x15m8b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sassls0g4l1p1024x15m8b2w0c1p0d0l1rm3sdrw00.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sassls0g4l1p1024x41m4b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sassls0g4l1p1024x41m4b2w0c1p0d0l1rm3sdrw00.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sassls0g4l1p1024x144m4b2w0c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v0c/sassls0g4l1p1024x144m4b2w0c1p0d0l1rm3sdrw00zh.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p4096x39m16b8w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadcls0g4l1p4096x39m16b8w0c1p0d0l1rm3sdrw00.lib \
#"
#}
#
#if { ($DESIGN_NAME == "scr7_core_cluster") ||  ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p256x32m4b4w1c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v0c/sadcls0g4l1p256x32m4b4w1c1p0d0l1rm3sdrw00zh.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p256x74m4b2w0c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v0c/sadcls0g4l1p256x74m4b2w0c1p0d0l1rm3sdrw00zh.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadrls0g4l2p256x18m4b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadrls0g4l2p256x18m4b4w0c1p0d0l1rm3sdrw00.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p256x41m4b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadcls0g4l1p256x41m4b4w0c1p0d0l1rm3sdrw00.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p256x144m4b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadcls0g4l1p256x144m4b4w0c1p0d0l1rm3sdrw00.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadrls0g4u2p512x8m4b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadrls0g4u2p512x8m4b2w0c1p0d0l1rm3sdrw00.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p512x50m4b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadcls0g4l1p512x50m4b4w0c1p0d0l1rm3sdrw00.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p512x137m4b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadcls0g4l1p512x137m4b4w0c1p0d0l1rm3sdrw00.lib \
#     "
#}
#
#if { ($DESIGN_NAME == "cpu_wrap") ||  ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i0/ssgnp_ccwt0p675v0c/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i0.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i1/ssgnp_ccwt0p675v0c/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i1.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i2/ssgnp_ccwt0p675v0c/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i2.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i3/ssgnp_ccwt0p675v0c/asdvds0g4l1p4096x32m8b4c1p0l0rm3sd_i3.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/cpu/src/sadcls0g4l1p8192x72m8b4w1c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v0c/sadcls0g4l1p8192x72m8b4w1c1p0d0l1rm3sdrw00zh.lib \
#    /project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/PLLTS7FFLAINTN/lib/PLLTS7FFLAINTN_SSGNP_0P675V_0C.lib \
#    "
#}



#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#set PVT_CORNER ffgnp_0p825v_125c
#set pvt_corner($PVT_CORNER,temperature) "125"
#set pvt_corner($PVT_CORNER,timing) " \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtffgnp_0p825v_125c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#"
#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v125c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v125c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ffgnp_ccbt0p825v125c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
#  "
#}
#
##--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#set PVT_CORNER ffgnp_0p825v_0c
#set pvt_corner($PVT_CORNER,temperature) "0"
#set pvt_corner($PVT_CORNER,timing) "\
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvtffgnp_0p825v_0c_cbest_CCbest_T_hm_lvf_p_ccs.lib.gz \
#"
#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v0c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v0c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ffgnp_ccbt0p825v0c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
#"
#}
#
##--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#set PVT_CORNER tt_0p75v_85c
#set pvt_corner($PVT_CORNER,temperature) "85"
#set pvt_corner($PVT_CORNER,timing) "\
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvttt_0p75v_85c_typical_hm_lvf_p_ccs.lib.gz \
#"
#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/tt0p75v85c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/tt0p75v85c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/tt0p75v85c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
#"
#}
#
##--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#set PVT_CORNER tt_0p75v_25c
#set pvt_corner($PVT_CORNER,temperature) "25"
#set pvt_corner($PVT_CORNER,timing) "\
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_svt_130a/tcbn07_bwph240l8p57pd_base_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_svt_130a/tcbn07_bwph240l8p57pd_mb_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_lvt_130a/tcbn07_bwph240l8p57pd_base_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_lvt_130a/tcbn07_bwph240l8p57pd_mb_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_base_ulvt_130a/tcbn07_bwph240l8p57pd_base_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l8p57pd_mb_ulvt_130a/tcbn07_bwph240l8p57pd_mb_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_svt_130a/tcbn07_bwph240l11p57pd_base_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_svt_130a/tcbn07_bwph240l11p57pd_mb_svttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_lvt_130a/tcbn07_bwph240l11p57pd_base_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_lvt_130a/tcbn07_bwph240l11p57pd_mb_lvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_base_ulvt_130a/tcbn07_bwph240l11p57pd_base_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/TSMC/TSMCHOME/digital/Front_End/LVF/CCS/tcbn07_bwph240l11p57pd_mb_ulvt_130a/tcbn07_bwph240l11p57pd_mb_ulvttt_0p75v_25c_typical_hm_lvf_p_ccs.lib.gz \
#"
#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/tt0p75v25c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/tt0p75v25c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
#  	/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/tt0p75v25c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
#"
#}


#################################################################################################################################################################################################
###	design setting 
#################################################################################################################################################################################################
set MAX_ROUTING_LAYER 12
set PWR_NET [list VDD]
set GND_NET [list VSS]


set DEF_FILE "../inter/${DESIGN_NAME}_floorplan.def.gz"
set FP_FILE  "../inter/floorplan_constraints.tcl"

set VT_GROUP_SVT8   P6S8*
set VT_GROUP_SVT11  P6S11*
set VT_GROUP_LVT8   P6L8*
set VT_GROUP_LVT11  P6L11*
set VT_GROUP_ULVT8  P6U8*
set VT_GROUP_ULVT11 P6U11*


set DONT_SCAN_FF ""
set DONT_TOUCH_INST ""
set SIZE_ONLY_INST ""

set DONT_USE_CELLS " \
P6.*8B_LCAPX.* \
P6.*_CK.* \
P6.*8B_CKRCVRX.* \
P6.*BORDER.* \
P6.*DLY.* \
P6.*BSDFFR.* \
P6.*BSDFFS.* \
P6.*BSDFFRS.* \
P6.*BSDFFM.* \
P6.*BDFF.* \
P6.*CCCAP.* \
P6.*CDM1.* \
P6.*DIODE.* \
P6.*FILLER.* \
P6.*BDLATN.* \
P6.*BDLATR.* \
P6.*BDLATX.* \
P6.*_DLAT.* \
P6.*BSDFFRW2.* \
P6.*BSDFFRW2.* \
P6.*BSDFFRW4.* \
P6.*BSDFFW2.* \
P6.*BSDFFW4.* \
P6.*CKEN.* \
P6.*LCAP.* \
P6.*LPD.* \
P6.*CKRCVR.* \
P6.*SYNC.* \
"
set DO_USE_CELLS " \
P6L8B_LPDCKSMUX4X16 \
P6L8B_LPDBUFX16 \
P6L8B_LPDINVX16 \
P6L8B_LPDCKENOAX16 \
P6L8B_CKAND2X8 \
"
#################################################################################################################################################################################################
###	floorplan setting 
#################################################################################################################################################################################################
#set ENDCAPS_LEFT_EDGE_EVEN	    BOUNDARYRIGHTBWP240H8P57PDSVT  
#set ENDCAPS_LEFT_EDGE_ODD	    BOUNDARYRIGHTBWP240H8P57PDSVT  
#set ENDCAPS_LEFT_TOP_CORNER_EVEN    BOUNDARYPCORNERBWP240H8P57PDSVT  
#set ENDCAPS_LEFT_TOP_CORNER_ODD     BOUNDARYPCORNERBWP240H8P57PDSVT 
#set ENDCAPS_LEFT_BOTTOM_CORNER_EVEN BOUNDARYNCORNERBWP240H8P57PDSVT 
#set ENDCAPS_LEFT_BOTTOM_CORNER_ODD  BOUNDARYNCORNERBWP240H8P57PDSVT 
#set ENDCAPS_TOP_EDGE		   {BOUNDARYPROW2BWP240H8P57PDSVT BOUNDARYPROW4BWP240H8P57PDSVT BOUNDARYPROW8BWP240H8P57PDSVT} 
#set ENDCAPS_BOTTOM_EDGE  	   {BOUNDARYNROW2BWP240H8P57PDSVT BOUNDARYNROW4BWP240H8P57PDSVT BOUNDARYNROW8BWP240H8P57PDSVT}
#set ENDCAPS_RIGHT_EDGE_EVEN	    BOUNDARYLEFTBWP240H8P57PDSVT 
#set ENDCAPS_RIGHT_EDGE_ODD	    BOUNDARYLEFTBWP240H8P57PDSVT
#set ENDCAPS_RIGHT_TOP_EDGE_EVEN     BOUNDARYPINCORNERBWP240H8P57PDSVT
#set ENDCAPS_RIGHT_TOP_EDGE_ODD	    BOUNDARYPINCORNERBWP240H8P57PDSVT
#set ENDCAPS_RIGHT_BOTTOM_EDGE_EVEN  BOUNDARYNINCORNERBWP240H8P57PDSVT
#set ENDCAPS_RIGHT_BOTTOM_EDGE_ODD   BOUNDARYNINCORNERBWP240H8P57PDSVT
#
#set TAPCELL TAPCELLBWP240H8P57PDSVT
#set TIEHCELL TIEHXPBWP240H11P57PDSVT
#set TIELCELL TIELXNBWP240H11P57PDSVT

###################################################################################################################################################################################################
###	CTS setting 
###################################################################################################################################################################################################

#set CTS_BUFFER_CELLS       {DCCKBD6BWP240H11P57PDULVT DCCKBD8BWP240H11P57PDULVT DCCKBD10BWP240H11P57PDULVT DCCKBD12BWP240H11P57PDULVT DCCKBD14BWP240H11P57PDULVT DCCKBD16BWP240H11P57PDULVT}
#set CTS_INVERTER_CELLS     {DCCKND6BWP240H11P57PDULVT DCCKND8BWP240H11P57PDULVT DCCKND10BWP240H11P57PDULVT DCCKND12BWP240H11P57PDULVT DCCKND14BWP240H11P57PDULVT DCCKND16BWP240H11P57PDULVT}
#set CTS_LOGIC_CELLS        {CKXOR2D4BWP240H11P57PDULVT CKXOR2D8BWP240H11P57PDULVT CKOR2D4BWP240H11P57PDULVT CKOR2D8BWP240H11P57PDULVT CKNR2D4BWP240H11P57PDULVT CKNR2D8BWP240H11P57PDULVT CKAN2D4BWP240H11P57PDULVT CKAN2D8BWP240H11P57PDULVT CKND2D4BWP240H11P57PDULVT CKND2D8BWP240H11P57PDULVT CKMUX2D4BWP240H11P57PDULVT CKMUX2D8BWP240H11P57PDULVT}
#set CTS_CLOCK_GATING_CELLS {CKLHQD4BWP240H11P57PDULVT CKLHQD5BWP240H11P57PDULVT CKLHQD6BWP240H11P57PDULVT CKLHQD8BWP240H11P57PDULVT CKLHQD10BWP240H11P57PDULVT CKLHQD12BWP240H11P57PDULVT CKLHQD14BWP240H11P57PDULVT CKLHQD16BWP240H11P57PDULVT CKLNQD4BWP240H11P57PDULVT CKLNQD5BWP240H11P57PDULVT CKLNQD6BWP240H11P57PDULVT CKLNQD8BWP240H11P57PDULVT CKLNQD10BWP240H11P57PDULVT CKLNQD12BWP240H11P57PDULVT CKLNQD14BWP240H11P57PDULVT CKLNQD16BWP240H11P57PDULVT}

set CTS_BUFFER_CELLS       {P6L8B_LPDBUFX8 P6L8B_LPDBUFX12 P6L8B_LPDBUFX16 }
set CTS_INVERTER_CELLS     {P6L8B_LPDINVX8 P6L8B_LPDINVX12 P6L8B_LPDINVX16 }
set CTS_LOGIC_CELLS        {P6L8B_LPDCKSMUX4X16 P6L8B_LPDCKSMUX4X8 P6L8B_CKAND2X8 P6L8B_CKMUX2X12 P6L8B_CKMUX2X16 P6L8B_CKMUX2X8 P6L8B_CKNAND2X8 P6L8B_CKNOR2X8 P6L8B_CKOR2X8 P6L8B_CKXOR2X8 }
set CTS_CLOCK_GATING_CELLS {P6L8B_LPDCKENAOAX12 P6L8B_LPDCKENAOAX16 P6L8B_LPDCKENAOAX8 P6L8B_LPDCKENOAX12 P6L8B_LPDCKENOAX16 P6L8B_LPDCKENOAX8 P6L8B_CKENNOOX12 P6L8B_CKENNOOX16 P6L8B_CKENNOOX8 P6L8B_CKENOAX10 P6L8B_CKENOAX12 P6L8B_CKENOAX16    P6L8B_CKENOAX6 P6L8B_CKENOAX8}

#################################################################################################################################################################################################
###	tools dependent
#################################################################################################################################################################################################
if { [get_db / .program_short_name] == "innovus" } {
	puts "-I- extra definition for [get_db / .program_short_name]"

	# Variables to set before loading libraries
	set_db add_route_vias_auto true ;                                       # (default : false
	set_db add_route_vias_advanced_rule true ;                              # (default : false

}

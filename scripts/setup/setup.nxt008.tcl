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
#	0.6	28/02/2021	OrY	    Add new flags - sdc_list, def_file
#	0.7	03/03/2021	OrY	    Merge with Roy
#	0.*	TBD	OrY	    Add support to lib list (From FE)
#																								#
#																								#
#################################################################################################################################################################################################

if { [info exists ::env(SYN4RTL)] } { set fe_mode $::env(SYN4RTL) } else { set fe_mode false }


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
	set scenarios(setup)   "func_pssg_v0670_t000_cworst_setup"
	if { !$fe_mode } {
		set scenarios(hold)    "func_pffg_v0830_t125_cworst_hold"
		set scenarios(dynamic) "func_pssg_v0670_t000_cworst_setup"
		set scenarios(leakage) "func_pffg_v0830_t125_cworst_hold"
	} else {
		set scenarios(hold)    "func_pssg_v0670_t000_cworst_setup"
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
#set GDS_MAP_FILE      "/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/APR/cdns/1.3.1C/PRTF_Innovus_7nm_001_Cad_V13_1c/PR_tech/Cadence/GdsOutMap/PRTF_Innovus_N7_gdsout_15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R.13_1c.map.mod"
#set DFM_REDUNDANT_VIA "/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/APR/cdns/1.3.1C/PRTF_Innovus_7nm_001_Cad_V13_1c/PR_tech/Cadence/script/PRTF_Innovus_N7_DFM_via_swap_reference_command.13_1c.tcl"
#set METAL_FILL_RUNSET "/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/BEOL_dummy/cdns/1.3b/Dummy_BEOL_Pegasus_7nm_001.13b"

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
 \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SC111HC1024X15R20211VTLUS11LLEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SC111HC1024X41R20221VTLUS11LLEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SC111HC256X41R20121VTLUS11LLEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SC111HC512X50R20221VTLUS11LLEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SC111HC256X32R20121VTLUS11LLEBCW1H20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SC111HC256X74R20122VTLUS11LLEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC1024X16RR20421VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC64X72RR10121VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC64X48RR10121VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC256X18RR10211VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SP111HD256X144R20122VTLS11LEBRCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC80X132RR10121VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SP111HD1024X144R20222VTLS11LEBRCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC128X256RR10122VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC192X132RR10221VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SP111HD832X154R20222VTLS11LEBRCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SP111HD512X137R20122VTLS11LEBRCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC512X160RR10422VTLLUS11LEBCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7MRF211LC16X102AR00121VTLLUS11UEBH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7MRF211LC16X144AR00121VTLLUS11UEBH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF2_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF1_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF0_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF3_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SP111HD4096X39R20411VTLS8LEBRCH20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SP111HD8192X72R30422VTLS8LEBRCW1H20_wrapper.lef \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/lef/PM7SRF211HC512X8RR10411VTLLUS11LEBCH20_wrapper.lef \
"

set GDS_FILE_LIST " \
"



#################################################################################################################################################################################################
###	RC view
#################################################################################################################################################################################################
set rc_corner(cworst)   /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK_Broadcom/SYNTH/cadence/15M_1x1xa1ya5y2yy2yx2r_R07518FF_cworst_CCworst_1d25S.tch
set rc_corner(cworst,rc_variation) 0.1
set rc_corner(rcworst)  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK_Broadcom/SYNTH/cadence/15M_1x1xa1ya5y2yy2yx2r_R07518FF_rcworst_CCworst_1d25S.tch
set rc_corner(rcworst,rc_variation) 0.1
#set rc_corner(cbest)    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/cbest/Tech/cbest_CCbest_T/qrcTechFile
#set rc_corner(cbest,rc_variation) 0.1
#set rc_corner(rcbest)   /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/rcbest/Tech/rcbest_CCbest_T/qrcTechFile
#set rc_corner(rcbest,rc_variation) 0.1
#set rc_corner(typical)  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/typical/Tech/typical/qrcTechFile
#set rc_corner(typical,rc_variation) 0.1


#################################################################################################################################################################################################
###	timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
 \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X15R20211VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X41R20221VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X41R20121VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC512X50R20221VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X32R20121VTLUS11LLEBCW1H20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X74R20122VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC1024X16RR20421VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X72RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X48RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC256X18RR10211VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD256X144R20122VTLS11LEBRCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC80X132RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD1024X144R20222VTLS11LEBRCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X256RR10122VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC192X132RR10221VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD832X154R20222VTLS11LEBRCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD512X137R20122VTLS11LEBRCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X160RR10422VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X102AR00121VTLLUS11UEBH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X144AR00121VTLLUS11UEBH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF2_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF1_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF0_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF3_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD4096X39R20411VTLS8LEBRCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD8192X72R30422VTLS8LEBRCW1H20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
/project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X8RR10411VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
"



    #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
    \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X15R20211VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X41R20221VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X41R20121VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC512X50R20221VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X32R20121VTLUS11LLEBCW1H20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X74R20122VTLUS11LLEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC1024X16RR20421VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X72RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X48RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC256X18RR10211VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD256X144R20122VTLS11LEBRCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC80X132RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD1024X144R20222VTLS11LEBRCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X256RR10122VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC192X132RR10221VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD832X154R20222VTLS11LEBRCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD512X137R20122VTLS11LEBRCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X160RR10422VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X102AR00121VTLLUS11UEBH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X144AR00121VTLLUS11UEBH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF2_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF1_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF0_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF3_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD4096X39R20411VTLS8LEBRCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD8192X72R30422VTLS8LEBRCW1H20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X8RR10411VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \    
    "
    set pvt_corner($PVT_CORNER,ocv) "\
    "

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
    \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X15R20211VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X41R20221VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X41R20121VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC512X50R20221VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X32R20121VTLUS11LLEBCW1H20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X74R20122VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC1024X16RR20421VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X72RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X48RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC256X18RR10211VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD256X144R20122VTLS11LEBRCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC80X132RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD1024X144R20222VTLS11LEBRCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X256RR10122VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC192X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD832X154R20222VTLS11LEBRCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD512X137R20122VTLS11LEBRCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X160RR10422VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X102AR00121VTLLUS11UEBH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X144AR00121VTLLUS11UEBH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF2_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF1_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF0_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF3_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD4096X39R20411VTLS8LEBRCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD8192X72R30422VTLS8LEBRCW1H20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X8RR10411VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \ 
    "
    set pvt_corner($PVT_CORNER,ocv) "\
    "

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
    \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X15R20211VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X41R20221VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X41R20121VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC512X50R20221VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X32R20121VTLUS11LLEBCW1H20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X74R20122VTLUS11LLEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC1024X16RR20421VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X72RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X48RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC256X18RR10211VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD256X144R20122VTLS11LEBRCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC80X132RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD1024X144R20222VTLS11LEBRCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X256RR10122VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC192X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD832X154R20222VTLS11LEBRCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD512X137R20122VTLS11LEBRCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X160RR10422VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X102AR00121VTLLUS11UEBH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X144AR00121VTLLUS11UEBH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF2_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF1_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF0_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF3_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD4096X39R20411VTLS8LEBRCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD8192X72R30422VTLS8LEBRCW1H20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X8RR10411VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
    "
    set pvt_corner($PVT_CORNER,ocv) "\
    "

    #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    set PVT_CORNER pffg_v0830_t125
    set pvt_corner($PVT_CORNER,temperature) "125"
    set pvt_corner($PVT_CORNER,timing) "\
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ck06t0750v/db/tsmc7ffp_ck06t0750v_pffg_s250_v0830_t125_xcbccbt.lib.gz         \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ga06t0750v/db/tsmc7ffp_ga06t0750v_pffg_s250_v0830_t125_xcbccbt.lib.gz         \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_hm06t0750v/db/tsmc7ffp_hm06t0750v_pffg_s250_v0830_t125_xcbccbt.lib.gz         \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t125_o0670_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t125_o0600_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t125_o0720_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t125_o0550_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t125_o0760_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t125_o0500_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t125_o0880_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t125_o0830_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t125_o0960_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_top06t0750v/db/tsmc7ffp_top06t0750v_pffg_s250_v0830_t125_xcbccbt.lib.gz       \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_sc06t0750v/db/tsmc7ffp_sc06t0750v_pffg_s250_v0830_t125_xcbccbt.lib.gz         \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/NXT_tsmc7ffp_sc06t0750v/db/NXT_tsmc7ffp_sc06t0750v_pffg_s250_v0830_t125_xcbccbt.lib.gz \
    \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X15R20211VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X41R20221VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X41R20121VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                  \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC512X50R20221VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                  \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X32R20121VTLUS11LLEBCW1H20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X74R20122VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC1024X16RR20421VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X72RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X48RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC256X18RR10211VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD256X144R20122VTLS11LEBRCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC80X132RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD1024X144R20222VTLS11LEBRCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X256RR10122VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC192X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD832X154R20222VTLS11LEBRCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD512X137R20122VTLS11LEBRCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X160RR10422VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X102AR00121VTLLUS11UEBH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X144AR00121VTLLUS11UEBH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF2_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF1_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF0_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF3_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD4096X39R20411VTLS8LEBRCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD8192X72R30422VTLS8LEBRCW1H20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X8RR10411VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t125_xrcbccbt.lib                 \
    "
    set pvt_corner($PVT_CORNER,ocv) "\
    "

    #--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
    set PVT_CORNER pffg_v0830_tm40
    set pvt_corner($PVT_CORNER,temperature) "-40"
    set pvt_corner($PVT_CORNER,timing) "\
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ga06t0750v/db/tsmc7ffp_ga06t0750v_pffg_s250_v0830_t-40_xcbccbt.lib.gz         \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_ck06t0750v/db/tsmc7ffp_ck06t0750v_pffg_s250_v0830_t-40_xcbccbt.lib.gz         \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_hm06t0750v/db/tsmc7ffp_hm06t0750v_pffg_s250_v0830_t-40_xcbccbt.lib.gz         \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t-40_o0500_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t-40_o0600_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t-40_o0720_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t-40_o0550_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t-40_o0830_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t-40_o0880_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t-40_o0760_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t-40_o0960_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_lscore/db/tsmc7ffp_lscore_pffg_s250_v0830_t-40_o0670_xcbccbt.lib.gz           \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_top06t0750v/db/tsmc7ffp_top06t0750v_pffg_s250_v0830_t-40_xcbccbt.lib.gz       \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/tsmc7ffp_sc06t0750v/db/tsmc7ffp_sc06t0750v_pffg_s250_v0830_t-40_xcbccbt.lib.gz         \
    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/BRCM/2021_02_19/NXT_tsmc7ffp_sc06t0750v/db/NXT_tsmc7ffp_sc06t0750v_pffg_s250_v0830_t-40_xcbccbt.lib.gz \
    \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X15R20211VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC1024X41R20221VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X41R20121VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC512X50R20221VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                 \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X32R20121VTLUS11LLEBCW1H20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SC111HC256X74R20122VTLUS11LLEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC1024X16RR20421VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X72RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC64X48RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC256X18RR10211VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD256X144R20122VTLS11LEBRCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC80X132RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD1024X144R20222VTLS11LEBRCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X256RR10122VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC192X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD832X154R20222VTLS11LEBRCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD512X137R20122VTLS11LEBRCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X160RR10422VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X102AR00121VTLLUS11UEBH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7MRF211LC16X144AR00121VTLLUS11UEBH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF2_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF1_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF0_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7RM110HD4096X32R5012VTLLSU11LWHH20ZP_CF3_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD4096X39R20411VTLS8LEBRCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HD8192X72R30422VTLS8LEBRCW1H20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC512X8RR10411VTLLUS11LEBCH20_wrapper_pffg_s250_v0830_t-40_xrcbccbt.lib                \
    "
    set pvt_corner($PVT_CORNER,ocv) "\
    "
    
#################################################################################################################################################################################################
###	read lib and lef list (HIPs)
#################################################################################################################################################################################################
#source $::env(BEROOT)/be_flow/ns_flow/scripts/read_lib_and_lef_lists.tcl


#################################################################################################################################################################################################
###	design setting 
#################################################################################################################################################################################################
set MAX_ROUTING_LAYER 12
set MIN_ROUTING_LAYER 2
set PWR_NET     [list VDD]
set GND_NET     [list VSS]
set PWR_PINS    [list VDD VDDB]
set GND_PINS    [list VSS VSSB]

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


set VT_GROUPS(SVT8)   P6S8*
set VT_GROUPS(SVT11)  P6S11*
set VT_GROUPS(LVT8)   P6L8*
set VT_GROUPS(LVT11)  P6L11*
set VT_GROUPS(ULVT8)  P6U8*
set VT_GROUPS(ULVT11) P6U11*


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
###	place setting 
#################################################################################################################################################################################################
#set IOBUFFER_CELL "BUFFD4BWP240H8P57PDSVT"
#set USEABLE_IOBUFFER_CELL {BUFFD4BWP240H*P57PD*VT BUFFD6BWP240H*P57PD*VT BUFFD8BWP240H*P57PD*VT BUFFD12BWP240H*P57PD*VT}
#set SPARE_MODULE { \
#CKLHQD4BWP240H11P57PDULVT {  1 0 } \
#SDFSNQD4BWP240H11P57PDULVT {  5 0 } \
#AO22D4BWP240H11P57PDULVT {  5 1 } \
#BUFFD8BWP240H11P57PDULVT { 10 0 } \
#MAOI22D4BWP240H11P57PDULVT {  5 1 } \
#IND2D4BWP240H11P57PDULVT {  4 0 } \
#INR2D4BWP240H11P57PDULVT {  4 1 } \
#INVD8BWP240H11P57PDULVT { 10 0 } \
#INR2D4BWP240H11P57PDULVT {  1 1 } \
#MUX2D4BWP240H11P57PDULVT {  5 0 } \
#IND2D4BWP240H11P57PDULVT { 10 1 } \
#AN2D4BWP240H11P57PDULVT {  5 0 } \
#OR2D4BWP240H11P57PDULVT {  5 1 } \
#IND3D4BWP240H11P57PDULVT {  5 0 } \
#INR3D4BWP240H11P57PDULVT {  5 1 } \
#OA21D4BWP240H11P57PDULVT { 10 0 } \
#OA22D4BWP240H11P57PDULVT {  1 1 } \
#OAI21D4BWP240H11P57PDULVT {  5 0 } \
#XNR2D4BWP240H11P57PDULVT {  5 1 }} 

#################################################################################################################################################################################################
###	floorplan setting 
#################################################################################################################################################################################################
set DIFFUSION_FORBIDDEN_SPACING 0.277 

set ENDCAPS_LEFT_EDGE_EVEN          P6S8B_BORDERSIDERIGHT  
set ENDCAPS_LEFT_EDGE_ODD           P6S8B_BORDERSIDERIGHT  
set ENDCAPS_LEFT_TOP_CORNER_EVEN    P6S8B_BORDERSIDERIGHT  
set ENDCAPS_LEFT_TOP_CORNER_ODD     P6S8B_BORDERSIDERIGHT 
set ENDCAPS_LEFT_BOTTOM_CORNER_EVEN P6S8B_BORDERSIDERIGHT 
set ENDCAPS_LEFT_BOTTOM_CORNER_ODD  P6S8B_BORDERSIDERIGHT 
set ENDCAPS_TOP_EDGE                {P6S8B_BORDERROWP2 P6S8B_BORDERROWP4 P6S8B_BORDERROWP8} 
set ENDCAPS_BOTTOM_EDGE             {P6S8B_BORDERROWP2 P6S8B_BORDERROWP4 P6S8B_BORDERROWP8}
set ENDCAPS_RIGHT_EDGE_EVEN         P6S8B_BORDERSIDERIGHT 
set ENDCAPS_RIGHT_EDGE_ODD          P6S8B_BORDERSIDERIGHT
set ENDCAPS_RIGHT_TOP_EDGE_EVEN     P6S8B_BORDERSIDERIGHT
set ENDCAPS_RIGHT_TOP_EDGE_ODD      P6S8B_BORDERSIDERIGHT
set ENDCAPS_RIGHT_BOTTOM_EDGE_EVEN  P6S8B_BORDERSIDERIGHT
set ENDCAPS_RIGHT_BOTTOM_EDGE_ODD   P6S8B_BORDERSIDERIGHT


set TAPCELL  P6S8B_TIE
set SWAP_WELL_TAPS { P6S8B_TIE }
set TIEHCELL P6S8B_TIEHI
set TIELCELL P6S8B_TIELO
set ANTENNA_CELL_NAME ""

set PRE_PLACE_DECAP 	"P6S8B_CCCAPD16"
set PRE_PLACE_ECO_DCAP  "P6S8B_CCCAPD16"
set PRE_PLACE_ECO_DCAP  "P6S8B_CCCAPD16"

set DCAP_CELLS_LIST 	"P6S8B_CCCAPD64 P6S8B_CCCAPD32 P6S8B_CCCAPD16 P6S8B_CCCAP8 P6S8B_CCCAP4"
set FILLER64_CELLS_LIST "P6S8B_FILLER64 P6S11B_FILLER64"
set FILLER32_CELLS_LIST "P6S8B_FILLER32 P6S11B_FILLER32"
set FILLER16_CELLS_LIST "P6S8B_FILLER16 P6S11B_FILLER16"
set FILLER12_CELLS_LIST ""
set FILLER8_CELLS_LIST "P6S8B_FILLER8 P6S11B_FILLER8"
set FILLER4_CELLS_LIST "P6S8B_FILLER4 P6S11B_FILLER4"
set FILLER3_CELLS_LIST "P6S8B_FILLER3 P6S11B_FILLER3"
set FILLER2_CELLS_LIST "P6S8B_FILLER2 P6S11B_FILLER2"
set FILLER1_CELLS_LIST "P6S8B_FILLER1 P6S11B_FILLER1"

set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"

set ADD_FILLERS_SWAP_CELL {}

#set ADD_FILLERS_SWAP_CELL {\
#{FILL1BWP240H11P57PDSVT FILL1NOBCMBWP240H11P57PDSVT} \
#{FILL1BWP240H11P57PDLVT FILL1NOBCMBWP240H11P57PDLVT} \
#{FILL1BWP240H11P57PDULVT FILL1NOBCMBWP240H11P57PDULVT} \
#{FILL1BWP240H8P57PDSVT FILL1NOBCMBWP240H8P57PDSVT} \
#{FILL1BWP240H8P57PDLVT FILL1NOBCMBWP240H8P57PDLVT} \
#{FILL1BWP240H8P57PDULVT FILL1NOBCMBWP240H8P57PDULVT}}
###################################################################################################################################################################################################
###	CTS setting 
###################################################################################################################################################################################################


set CTS_BUFFER_CELLS       {P6L8B_LPDBUFX8 P6L8B_LPDBUFX12 P6L8B_LPDBUFX16 }
set CTS_INVERTER_CELLS     {P6L8B_LPDINVX8 P6L8B_LPDINVX12 P6L8B_LPDINVX16 }
set CTS_LOGIC_CELLS        {P6L8B_LPDCKSMUX4X16 P6L8B_LPDCKSMUX4X8 P6L8B_CKAND2X8 P6L8B_CKMUX2X12 P6L8B_CKMUX2X16 P6L8B_CKMUX2X8 P6L8B_CKNAND2X8 P6L8B_CKNOR2X8 P6L8B_CKOR2X8 P6L8B_CKXOR2X8 }
set CTS_CLOCK_GATING_CELLS {P6L8B_LPDCKENAOAX12 P6L8B_LPDCKENAOAX16 P6L8B_LPDCKENAOAX8 P6L8B_LPDCKENOAX12 P6L8B_LPDCKENOAX16 P6L8B_LPDCKENOAX8 P6L8B_CKENNOOX12 P6L8B_CKENNOOX16 P6L8B_CKENNOOX8 P6L8B_CKENOAX10 P6L8B_CKENOAX12 P6L8B_CKENOAX16    P6L8B_CKENOAX6 P6L8B_CKENOAX8}
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






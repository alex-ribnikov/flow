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

# See below - Read using - source $::env(BEROOT)/be_flow/ns_flow/scripts/read_lib_and_lef_lists.tcl
# Read from ./leflist OR ../inter/leflist OR $nextinside/<filelist location>/leflist OR $::env(BEROOT)/be_flow/ns_flow/scripts/leflist
set LEF_FILE_LIST " \
"

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
# See below - Read using - source $::env(BEROOT)/be_flow/ns_flow/scripts/read_lib_and_lef_lists.tcl
# Read from ./*.liblist OR ../inter/*.liblist OR $nextinside/<filelist location>/*.liblist OR $::env(BEROOT)/be_flow/ns_flow/scripts/*.liblist
set PVT_CORNER pssg_v0670_t125
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
"

#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
# 	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
#	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
#	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t125_xrcwccwt.lib \
#  "
#}


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# See below - Read using - source $::env(BEROOT)/be_flow/ns_flow/scripts/read_lib_and_lef_lists.tcl
# Read from ./*.liblist OR ../inter/*.liblist OR $nextinside/<filelist location>/*.liblist OR $::env(BEROOT)/be_flow/ns_flow/scripts/*.liblist
set PVT_CORNER pssg_v0670_t000
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
"

#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
# 	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
#	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
#	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pssg_s250_v0670_t000_xrcwccwt.lib \
#  "
#}


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# See below - Read using - source $::env(BEROOT)/be_flow/ns_flow/scripts/read_lib_and_lef_lists.tcl
# Read from ./*.liblist OR ../inter/*.liblist OR $nextinside/<filelist location>/*.liblist OR $::env(BEROOT)/be_flow/ns_flow/scripts/*.liblist
set PVT_CORNER pffg_v0880_t125
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
"

#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
# 	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
#	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
#	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t125_xrcbccbt.lib \
#  "
#}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
# See below - Read using - source $::env(BEROOT)/be_flow/ns_flow/scripts/read_lib_and_lef_lists.tcl
# Read from ./*.liblist OR ../inter/*.liblist OR $nextinside/<filelist location>/*.liblist OR $::env(BEROOT)/be_flow/ns_flow/scripts/*.liblist
set PVT_CORNER pffg_v0880_t-40
set pvt_corner($PVT_CORNER,temperature) "-40"
set pvt_corner($PVT_CORNER,timing) "\
"

#if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
#  puts "-I- add $DESIGN_NAME lib files to $PVT_CORNER lib list"
#  set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) \
# 	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SP111HC3136X156R20422VTULS8UEBRCW1H20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
#	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC128X136RR10121VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
#	   /project/nxt008/bravoIP/MEMORIES/MEMORIES_20210219/MEMORY/db/PM7SRF211HC160X132RR10221VTLLUS11LEBCH20_wrapper_pffg_s250_v0880_t-40_xrcbccbt.lib \
#  "
#}

#################################################################################################################################################################################################
###	read lib and lef list (HIPs)
#################################################################################################################################################################################################
source $::env(BEROOT)/be_flow/ns_flow/scripts/read_lib_and_lef_lists.tcl


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

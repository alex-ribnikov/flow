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
#	 Var	date of change	owner	comment																	#
#	----	--------------	-------	---------------------------------------------------------------											#
#	0.1	    01/03/2021		Ory		New setup for snps n7 libs
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
	set scenarios(setup) "func_ssgnp0p675v0c_cworst_setup func_ssgnp0p675v125c_cworst_setup func_ssgnp0p675v0c_rcworst_setup func_ssgnp0p675v125c_rcworst_setup"
	set scenarios(hold) "func_ssgnp0p675v0c_cworst_hold func_ssgnp0p675v125c_cworst_hold func_ffgnp0p825v125c_cbest_hold func_ffgnp0p825v0c_cbest_hold"
	set scenarios(dynamic) "func_ssgnp0p675v0c_cworst_setup"
	set scenarios(leakage) "func_ffgnp0p825v125c_cbest_hold"
} else {
	set scenarios(setup)   "func_ssgnp0p675v0c_cworst_setup"
	if { !$fe_mode } {
		set scenarios(hold)    "func_ffgnp0p825v125c_cworst_hold"
		set scenarios(dynamic) "func_ssgnp0p675v0c_cworst_setup"
		set scenarios(leakage) "func_ffgnp0p825v125c_cworst_hold"
	} else {
		set scenarios(hold)    "func_ssgnp0p675v0c_cworst_setup"
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
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/svt/latest/lef/5.8/ts07nxpslogl08hdh057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/svt/latest/lef/5.8/ts07nxpslogl11hdh057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/ulvt/latest/lef/5.8/ts07nxpvlogl11hdh057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/lvt/latest/lef/5.8/ts07nxpllogl08hdh057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/lvt/latest/lef/5.8/ts07nxpllogl11hdh057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/ulvt/latest/lef/5.8/ts07nxpvlogl08hdh057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/lvt/latest/lef/5.8/ts07nxpllogl08hdl057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/lvt/latest/lef/5.8/ts07nxpllogl11hdl057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/svt/latest/lef/5.8/ts07nxpslogl08hdl057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/svt/latest/lef/5.8/ts07nxpslogl11hdl057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/ulvt/latest/lef/5.8/ts07nxpvlogl08hdl057f.lef \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/ulvt/latest/lef/5.8/ts07nxpvlogl11hdl057f.lef \
\
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.plef \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.plef \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.plef \
"


set GDS_FILE_LIST " \
"

if { ($DESIGN_NAME == "grid_cluster") || ($DESIGN_NAME == "gmu_cluster") || ($DESIGN_NAME == "all")} {
    puts "-I- add $DESIGN_NAME lef files to lef files list"
    set LEF_FILE_LIST "$LEF_FILE_LIST \
    "

  puts "-I- add $DESIGN_NAME gds files to gds files list"
  set GDS_FILE_LIST "$GDS_FILE_LIST \
  "

}

#################################################################################################################################################################################################
###	RC view
#################################################################################################################################################################################################
set rc_corner(cworst)   /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/cworst/Tech/cworst_CCworst_T/qrcTechFile
set rc_corner(cworst,rc_variation) 0.1
set rc_corner(rcworst)  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/rcworst/Tech/rcworst_CCworst_T/qrcTechFile
set rc_corner(rcworst,rc_variation) 0.1
set rc_corner(cbest)    /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/cbest/Tech/cbest_CCbest_T/qrcTechFile
set rc_corner(cbest,rc_variation) 0.1
set rc_corner(rcbest)   /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/rcbest/Tech/rcbest_CCbest_T/qrcTechFile
set rc_corner(rcbest,rc_variation) 0.1
set rc_corner(typical)  /project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/PDK/Extract/cdns/1.2p1a/typical/Tech/typical/qrcTechFile
set rc_corner(typical,rc_variation) 0.1


#################################################################################################################################################################################################
###	timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

set PVT_CORNER ssgnp_0p675v125c
#set PVT_CORNER pssg_v0670_t125
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/lvt/latest/liberty/ccs/ts07nxpllogl08hdl057f_ssgnp0p675v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/svt/latest/liberty/ccs/ts07nxpslogl08hdl057f_ssgnp0p675v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/ulvt/latest/liberty/ccs/ts07nxpvlogl08hdl057f_ssgnp0p675v0c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/svt/latest/liberty/ccs/ts07nxpslogl08hdh057f_ssgnp0p675v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/lvt/latest/liberty/ccs/ts07nxpllogl08hdh057f_ssgnp0p675v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/ulvt/latest/liberty/ccs/ts07nxpvlogl08hdh057f_ssgnp0p675v0c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/lvt/latest/liberty/ccs/ts07nxpllogl11hdl057f_ssgnp0p675v125c.lib   \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/svt/latest/liberty/ccs/ts07nxpslogl11hdl057f_ssgnp0p675v125c.lib   \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/ulvt/latest/liberty/ccs/ts07nxpvlogl11hdl057f_ssgnp0p675v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/svt/latest/liberty/ccs/ts07nxpslogl11hdh057f_ssgnp0p675v125c.lib   \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/ulvt/latest/liberty/ccs/ts07nxpvlogl11hdh057f_ssgnp0p675v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/lvt/latest/liberty/ccs/ts07nxpllogl11hdh057f_ssgnp0p675v125c.lib   \
\    
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v125c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v125c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v125c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
"

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

set PVT_CORNER ssgnp0p675v0c
#set PVT_CORNER pssg_v0670_t000
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/lvt/latest/liberty/ccs/ts07nxpllogl08hdl057f_ssgnp0p675v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/svt/latest/liberty/ccs/ts07nxpslogl08hdl057f_ssgnp0p675v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/ulvt/latest/liberty/ccs/ts07nxpvlogl08hdl057f_ssgnp0p675v125c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/svt/latest/liberty/ccs/ts07nxpslogl08hdh057f_ssgnp0p675v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/lvt/latest/liberty/ccs/ts07nxpllogl08hdh057f_ssgnp0p675v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/ulvt/latest/liberty/ccs/ts07nxpvlogl08hdh057f_ssgnp0p675v125c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/lvt/latest/liberty/ccs/ts07nxpllogl11hdl057f_ssgnp0p675v0c.lib    \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/svt/latest/liberty/ccs/ts07nxpslogl11hdl057f_ssgnp0p675v0c.lib    \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/ulvt/latest/liberty/ccs/ts07nxpvlogl11hdl057f_ssgnp0p675v0c.lib   \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/svt/latest/liberty/ccs/ts07nxpslogl11hdh057f_ssgnp0p675v0c.lib    \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/ulvt/latest/liberty/ccs/ts07nxpvlogl11hdh057f_ssgnp0p675v0c.lib   \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/lvt/latest/liberty/ccs/ts07nxpllogl11hdh057f_ssgnp0p675v0c.lib    \
\
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ssgnp_ccwt0p675v0c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ssgnp_ccwt0p675v0c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \    
"
set pvt_corner($PVT_CORNER,ocv) "\
"

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ffgnp0p825v125c
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/lvt/latest/liberty/ccs/ts07nxpllogl08hdl057f_ffgnp0p825v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/svt/latest/liberty/ccs/ts07nxpslogl08hdl057f_ffgnp0p825v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/ulvt/latest/liberty/ccs/ts07nxpvlogl08hdl057f_ffgnp0p825v125c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/svt/latest/liberty/ccs/ts07nxpslogl08hdh057f_ffgnp0p825v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/lvt/latest/liberty/ccs/ts07nxpllogl08hdh057f_ffgnp0p825v125c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/ulvt/latest/liberty/ccs/ts07nxpvlogl08hdh057f_ffgnp0p825v125c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/lvt/latest/liberty/ccs/ts07nxpllogl11hdl057f_ffgnp0p825v125c.lib      \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/svt/latest/liberty/ccs/ts07nxpslogl11hdl057f_ffgnp0p825v125c.lib      \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/ulvt/latest/liberty/ccs/ts07nxpvlogl11hdl057f_ffgnp0p825v125c.lib     \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/svt/latest/liberty/ccs/ts07nxpslogl11hdh057f_ffgnp0p825v125c.lib      \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/ulvt/latest/liberty/ccs/ts07nxpvlogl11hdh057f_ffgnp0p825v125c.lib     \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/lvt/latest/liberty/ccs/ts07nxpllogl11hdh057f_ffgnp0p825v125c.lib      \
\
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v125c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v125c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ffgnp_ccbt0p825v125c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \    
"
set pvt_corner($PVT_CORNER,ocv) "\
"


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ffgnp0p825v0c
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/lvt/latest/liberty/ccs/ts07nxpllogl08hdl057f_ffgnp0p825v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/svt/latest/liberty/ccs/ts07nxpslogl08hdl057f_ffgnp0p825v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdl/ulvt/latest/liberty/ccs/ts07nxpvlogl08hdl057f_ffgnp0p825v0c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/svt/latest/liberty/ccs/ts07nxpslogl08hdh057f_ffgnp0p825v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/lvt/latest/liberty/ccs/ts07nxpllogl08hdh057f_ffgnp0p825v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/08hd/hdh/ulvt/latest/liberty/ccs/ts07nxpvlogl08hdh057f_ffgnp0p825v0c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/lvt/latest/liberty/ccs/ts07nxpllogl11hdl057f_ffgnp0p825v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/svt/latest/liberty/ccs/ts07nxpslogl11hdl057f_ffgnp0p825v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdl/ulvt/latest/liberty/ccs/ts07nxpvlogl11hdl057f_ffgnp0p825v0c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/svt/latest/liberty/ccs/ts07nxpslogl11hdh057f_ffgnp0p825v0c.lib  \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/ulvt/latest/liberty/ccs/ts07nxpvlogl11hdh057f_ffgnp0p825v0c.lib \
/project/foundry/TSMC/N7/15M_1X_h_1Xa_v_1Ya_h_5Y_vhvhv_2Yy2Yx2R/IP/STD/SNPS/DesignWare_logic_libs/tsmc07nglp/11hd/hdh/lvt/latest/liberty/ccs/ts07nxpllogl11hdh057f_ffgnp0p825v0c.lib  \
\
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v0c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/ffgnp_ccbt0p825v0c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/ffgnp_ccbt0p825v0c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \    
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


set VT_GROUPS(SVT)   *SVT*
set VT_GROUPS(LVT)   *LVT*
set VT_GROUPS(ULVT)  *ULT*


set DONT_SCAN_FF ""
set DONT_TOUCH_INST "" ; # REMOVED spare_i from dont touch
set SIZE_ONLY_INST ""

set DONT_USE_CELLS " \
*_AN2*_1 \
*_ND2*_1   \  
*_NR2*_1     \
*_OR2*_1    \
*_AN3*_1 \
*_ND3*_1   \  
*_NR3*_1     \
*_OR3*_1       \ 
*_AN4*_1 \
*_ND4*_1   \  
*_NR4*_1     \
*_OR4*_1     \
*FSD*M8* \
"

set DO_USE_CELLS " \
"

#################################################################################################################################################################################################
###	place setting 
#################################################################################################################################################################################################
set IOBUFFER_CELL "HDBSVT11_BUF_4"
set USEABLE_IOBUFFER_CELL {HDBSVT11_BUF*_4 HDBSVT11_BUF*_5 HDBSVT11_BUF*_6  HDBSVT11_BUF*_8 HDBSVT11_BUF*_10 HDBSVT11_BUF*_12    }
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

##################################################################################################################################################
###	floorplan setting 
#################################################################################################################################################################################################
set ENDCAPS_LEFT_EDGE_EVEN          HDBLVT08_CAPL5
set ENDCAPS_LEFT_EDGE_ODD           HDBLVT08_CAPL5  
set ENDCAPS_LEFT_TOP_CORNER_EVEN    HDBLVT08_CAPTLC5 
set ENDCAPS_LEFT_TOP_CORNER_ODD     HDBLVT08_CAPTLC5 
set ENDCAPS_LEFT_BOTTOM_CORNER_EVEN HDBLVT08_CAPBLC5 
set ENDCAPS_LEFT_BOTTOM_CORNER_ODD  HDBLVT08_CAPBLC5 
set ENDCAPS_TOP_EDGE                HDBLVT08_CAPT1 
set ENDCAPS_BOTTOM_EDGE             HDBLVT08_CAPB1
set ENDCAPS_RIGHT_EDGE_EVEN         HDBLVT08_CAPR5 
set ENDCAPS_RIGHT_EDGE_ODD          HDBLVT08_CAPR5
set ENDCAPS_RIGHT_TOP_EDGE_EVEN     HDBLVT08_CAPTRC5
set ENDCAPS_RIGHT_TOP_EDGE_ODD      HDBLVT08_CAPTRC5
set ENDCAPS_RIGHT_BOTTOM_EDGE_EVEN  HDBLVT08_CAPBRC5
set ENDCAPS_RIGHT_BOTTOM_EDGE_ODD   HDBLVT08_CAPBRC5

set ENDCAPS(RIGHT_EDGE) 		HDBLVT08_CAPR5
set ENDCAPS(LEFT_EDGE) 			HDBLVT08_CAPL5
set ENDCAPS(TOP_EDGE) 			{HDBLVT08_CAPB1}
set ENDCAPS(BOTTOM_EDGE) 		{HDBLVT08_CAPB1}
set ENDCAPS(RIGHT_TOP_CORNER) 		HDBLVT08_CAPBRC5
set ENDCAPS(RIGHT_BOTTOM_CORNER) 	HDBLVT08_CAPBRC5
set ENDCAPS(LEFT_TOP_CORNER) 		HDBLVT08_CAPBLC5
set ENDCAPS(LEFT_BOTTOM_CORNER) 	HDBLVT08_CAPBLC5
set ENDCAPS(RIGHT_TOP_EDGE) 		HDBSVT08_CAPBRINC5
set ENDCAPS(RIGHT_BOTTOM_EDGE) 		HDBSVT08_CAPBRINC5
set ENDCAPS(LEFT_TOP_EDGE) 		    HDBSVT08_CAPBLINC5
set ENDCAPS(LEFT_BOTTOM_EDGE) 		HDBSVT08_CAPBLINC5
set ENDCAPS(LEFT_BOTTOM_CORNER_NEIGHBOR)  HDBSVT06_CAPBLINC5     
set ENDCAPS(LEFT_BOTTOM_EDGE_NEIGHBOR) 	  HDBSVT06_CAPBLINC5  
set ENDCAPS(LEFT_TOP_CORNER_NEIGHBOR) 	  HDBSVT06_CAPBLINC5  
set ENDCAPS(LEFT_TOP_EDGE_NEIGHBOR) 	  HDBSVT06_CAPBLINC5  
set ENDCAPS(RIGHT_BOTTOM_CORNER_NEIGHBOR) HDBSVT06_CAPBRINC5     
set ENDCAPS(RIGHT_BOTTOM_EDGE_NEIGHBOR)   HDBSVT06_CAPBRINC5      
set ENDCAPS(RIGHT_TOP_CORNER_NEIGHBOR) 	  HDBSVT06_CAPBRINC5  
set ENDCAPS(RIGHT_TOP_EDGE_NEIGHBOR) 	  HDBSVT06_CAPBRINC5  

set TAPCELL  HDBSVT08_TAPDS
set SWAP_WELL_TAPS {}
set TIEHCELL HDBSVT11_TIE1_1 
set TIELCELL HDBSVT11_TIE0_1
set ANTENNA_CELL_NAME "HDBSVT08_TIEDIP_Y10_1 HDBSVT11_TIEDIP_Y10_1"

set PRE_PLACE_DECAP    "HDBSVT11_DCAP_V4_16"
set PRE_PLACE_ECO_DCAP "HDBSVT11_DCAP_V4_16"
set PRE_PLACE_ECO_DCAP "HDBSVT11_DCAP_V4_16"

set DCAP_CELLS_LIST "HDBSVT11_DCAP_V4_64 HDBSVT11_DCAP_V4_32 HDBSVT11_DCAP_V4_16 HDBSVT11_DCAP_V4_8 HDBSVT11_DCAP_V4_4"
set FILLER64_CELLS_LIST "HDBLVT08_FILL64 HDBLVT11_FILL64 HDBSVT08_FILL64 HDBSVT11_FILL64 HDBULT08_FILL64 HDBULT11_FILL64"
set FILLER32_CELLS_LIST "HDBLVT08_FILL32 HDBLVT11_FILL32 HDBSVT08_FILL32 HDBSVT11_FILL32 HDBULT08_FILL32 HDBULT11_FILL32"
set FILLER16_CELLS_LIST "HDBLVT08_FILL16 HDBLVT11_FILL16 HDBSVT08_FILL16 HDBSVT11_FILL16 HDBULT08_FILL16 HDBULT11_FILL16"
set FILLER12_CELLS_LIST "HDBLVT08_FILL12 HDBLVT11_FILL12 HDBSVT08_FILL12 HDBSVT11_FILL12 HDBULT08_FILL12 HDBULT11_FILL12"
set FILLER8_CELLS_LIST  "HDBLVT08_FILL8 HDBLVT11_FILL8 HDBSVT08_FILL8 HDBSVT11_FILL8 HDBULT08_FILL8 HDBULT11_FILL8"
set FILLER4_CELLS_LIST  "HDBLVT08_FILL4 HDBLVT11_FILL4 HDBSVT08_FILL4 HDBSVT11_FILL4 HDBULT08_FILL4 HDBULT11_FILL4"
set FILLER3_CELLS_LIST  "HDBLVT08_FILL3 HDBLVT11_FILL3 HDBSVT08_FILL3 HDBSVT11_FILL3 HDBULT08_FILL3 HDBULT11_FILL3"
set FILLER2_CELLS_LIST  "HDBLVT08_FILL2 HDBLVT11_FILL2 HDBSVT08_FILL2 HDBSVT11_FILL2 HDBULT08_FILL2 HDBULT11_FILL2"
set FILLER1_CELLS_LIST  "HDBLVT08_FILL1 HDBLVT11_FILL1 HDBSVT08_FILL1 HDBSVT11_FILL1 HDBULT08_FILL1 HDBULT11_FILL1"

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

set CTS_BUFFER_CELLS          {HDBULT11_BUF_S_6 HDBULT11_BUF_S_7 HDBULT11_BUF_S_8 HDBULT11_BUF_S_9 HDBULT11_BUF_S_10 HDBULT11_BUF_S_12 HDBULT11_BUF_S_14 HDBULT11_BUF_S_16}
set CTS_INVERTER_CELLS        {HDBULT11_INV_S_6 HDBULT11_INV_S_7 HDBULT11_INV_S_8 HDBULT11_INV_S_9 HDBULT11_INV_S_10 HDBULT11_INV_S_12 HDBULT11_INV_S_14 HDBULT11_INV_S_16}
set CTS_LOGIC_CELLS           {HDBULT11_OR2_2 HDBULT11_OR2_4 HDBULT11_AN2_2 HDBULT11_AN2_4 HDBULT11_NR2_2 HDBULT11_NR2_4 HDBULT11_ND2_2 HDBULT11_ND2_4 HDBULT11_MUX2_CK_1 HDBULT11_MUX2_CK_2 HDBULT11_MUX2_CKY2_4}
set CTS_CLOCK_GATING_CELLS    {HDBULT11_CKGTPLT_V5Y2_4 HDBULT11_CKGTPLT_V5Y2_6 HDBULT11_CKGTPLT_V5Y2_8 HDBULT11_CKGTPLT_V5Y2_12 HDBULT11_CKGTPLT_V5Y2_16 HDBULT11_CKGTPLT_V7Y2_3 HDBULT11_CKGTPLT_V7Y2_4 HDBULT11_CKGTPLT_V7Y2_5 HDBULT11_CKGTPLT_V7Y2_6 HDBULT11_CKGTPLT_V7Y2_7 HDBULT11_CKGTPLT_V7Y2_8 HDBULT11_CKGTPLT_V7Y2_10 HDBULT11_CKGTPLT_V7Y2_12 HDBULT11_CKGTPLT_V7Y2_16 HDBULT11_CKGTNLT_V3Y2_4 HDBULT11_CKGTNLT_V5Y2_4 HDBULT11_CKGTNLT_V5Y2_5 HDBULT11_CKGTNLT_V5Y2_6 HDBULT11_CKGTNLT_V5Y2_7 HDBULT11_CKGTNLT_V5Y2_8 HDBULT11_CKGTNLT_V5Y2_12 HDBULT11_CKGTNLT_V5Y2_16 }
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






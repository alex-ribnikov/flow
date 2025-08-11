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
#	0.1	    01/03/2021		Ory		New setup for snps n5 libs
#	0.2	    03/03/2021		Ory		Merge with Roy
#																								#
#																								#
#################################################################################################################################################################################################

if { [info exists ::env(SYN4RTL)] } { set fe_mode $::env(SYN4RTL) } else { set fe_mode false }
if { [info exists ::env(PROJECT)] } { set PROJECT ${::env(PROJECT)} } 

set mmmc_results ./scripts_local/mmmc_results.tcl

if {![info exists DESIGN_NAME]} {set DESIGN_NAME [lindex [split [pwd] "/"] end-2]}
if {![info exists SPEF_DIR]}    {set SPEF_DIR ""}
if {![info exists GPD_DIR]}     {set GPD_DIR ""}

#################################################################################################################################################################################################
###	running scenarios 
#################################################################################################################################################################################################

	set scenarios(setup) "func_no_od_125_LIBRARY_SS_cworst_setup func_no_od_125_LIBRARY_SS_rcworst_setup func_no_od_minT_LIBRARY_SS_cworst_setup func_no_od_minT_LIBRARY_SS_rcworst_setup func_no_od_minT_LIBRARY_SS_rcbest_setup"
	set scenarios(hold) "func_no_od_125_LIBRARY_FF_cbest_hold func_no_od_125_LIBRARY_FF_rcbest_hold func_no_od_125_LIBRARY_FF_rcworst_hold func_no_od_minT_LIBRARY_FF_cbest_hold func_no_od_minT_LIBRARY_FF_rcbest_hold func_no_od_minT_LIBRARY_FF_rcworst_hold"
	set scenarios(dynamic) "func_no_od_125_LIBRARY_FF_cbest_hold"
	set scenarios(leakage) "func_no_od_125_LIBRARY_FF_cbest_hold"

set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]

if {![info exists STAGE] || $STAGE == "syn" || $STAGE == "syn_reg" } {
	set scenarios(setup) "func_no_od_125_LIBRARY_SS_cworst_setup"
	if { !$fe_mode } {
		set scenarios(hold) "func_no_od_125_LIBRARY_FF_cbest_hold"
		set scenarios(dynamic) "func_no_od_125_LIBRARY_FF_cbest_hold"
		set scenarios(leakage) "func_no_od_125_LIBRARY_FF_cbest_hold"
	} else {
		set scenarios(hold) "func_no_od_125_LIBRARY_FF_cbest_hold"
		set scenarios(dynamic) ""
		set scenarios(leakage) ""
	}
	set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
	
} elseif { [info exists STAGE] && $STAGE == "place"} {
	set scenarios(setup) "func_no_od_125_LIBRARY_SS_cworst_setup"
	set scenarios(hold)  "func_no_od_125_LIBRARY_FF_cbest_hold"
	set scenarios(dynamic) "func_no_od_125_LIBRARY_FF_cbest_hold"
	set scenarios(leakage) "func_no_od_125_LIBRARY_FF_cbest_hold"
}
set scenarios(setup)   "func_no_od_125_LIBRARY_SS_cworst_setup"
set scenarios(hold)    "func_no_od_125_LIBRARY_FF_cbest_hold"
set scenarios(dynamic) "func_no_od_125_LIBRARY_FF_cbest_hold"
set scenarios(leakage) "func_no_od_125_LIBRARY_FF_cbest_hold"

set AC_LIMIT_SCENARIOS "func_no_od_125_LIBRARY_FF_cbest_hold"
#set DEFAULT_SETUP_VIEW func_no_od_125_LIBRARY_SS_cworst_setup
#set DEFAULT_HOLD_VIEW  func_no_od_minT_LIBRARY_FF_rcbest_hold

#################################################################################################################################################################################################
###	timing constraint 
#################################################################################################################################################################################################

if { ! [info exists SDC_LIST] || $SDC_LIST == "None" } {
    if { !$fe_mode } {
    
        set sdc_files(func) ""
        if {[info exists sh_launch_dir]} {
	   if { [file exists ${sh_launch_dir}/../inter/${DESIGN_NAME}.pre.sdc]  } { append sdc_files(func) " ${sh_launch_dir}/../inter/${DESIGN_NAME}.pre.sdc " }
           if { [file exists ${sh_launch_dir}/../inter/${DESIGN_NAME}.sdc]      } { append sdc_files(func) " ${sh_launch_dir}/../inter/${DESIGN_NAME}.sdc " }
           if { [file exists ${sh_launch_dir}/../inter/${DESIGN_NAME}.post.sdc] } { append sdc_files(func) " ${sh_launch_dir}/../inter/${DESIGN_NAME}.post.sdc " }                
	} else {
           if { [file exists ../inter/${DESIGN_NAME}.pre.sdc]  } { append sdc_files(func) " ../inter/${DESIGN_NAME}.pre.sdc " }
           if { [file exists ../inter/${DESIGN_NAME}.sdc]      } { append sdc_files(func) " ../inter/${DESIGN_NAME}.sdc " }
           if { [file exists ../inter/${DESIGN_NAME}.post.sdc] } { append sdc_files(func) " ../inter/${DESIGN_NAME}.post.sdc " }                
	}
	
        if { $sdc_files(func) == "" } { puts "-E- No SDC file" ;  }
        
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
set STREAM_LAYER_MAP_FILE  /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_gds_lefdef_map
set TECHNOLOGY_LAYER_MAP   /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_lefdef_rcxt_map

set DFM_REDUNDANT_VIA ""
set METAL_FILL_RUNSET ""
set ICT_EM_MODELS "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK//EM/cdns/1.1.3A/cln5_1p17m+ut-alrdl_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim.ictem"
set TECH_FILE "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.tf"
set TECH_LEF " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/cadence/var_active_17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.lef \
"

set LEF_FILE_LIST "$TECH_LEF \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_top06t0750v/lef/tsmc5ff_top06t0750v.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_sc06t0750v/lef/tsmc5ff_sc06t0750v.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_mb06t0750v/lef/tsmc5ff_mb06t0750v.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ga06t0750v/lef/tsmc5ff_ga06t0750v.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ck06t0750v/lef/tsmc5ff_ck06t0750v.lef \
./scripts_local/my_vp.lef \
\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5PD211HC2048X20R20221VT525G6BSIRCH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5PSP111HD1056X39R20221VT525G6EBRCW1H20LD_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5PSP111HD2112X39R20421VT525G6EBRCW1H20LD_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5PSP111HD4096X137R20822VT525G6BSIRCH20OD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SC111HC128X35R20121VT555G6BSIRCH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SC111HC128X59R20121VT535G6BSIRCH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SC111HC128X59R20122VT555G6BSIRCH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SC111HC256X32R20121VT555G6BSIRCW1H20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SC111HC256X35R20121VT555G6BSIRCH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SC111HC256X37R20121VT555G6BSIRCH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SC111HC256X39R20122VT555G6BSIRCH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SC111HC256X43R20122VT555G6BSIRCH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SC111HC256X43R20122VT555G6BSIRCW1H20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC1024X35R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC1024X46R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC1056X78R20221VT525G6EBRCW1H20QLA_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC128X43R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC128X46R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC128X46R20221VT525G6EBRCH20QLA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC128X59R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC2048X46R20221VT525G6EBRCH20QLA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC2112X156R20422VT525G6EBRCW1H20QLA_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC2112X78R20421VT525G6EBRCW1H20QLA_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC256X128R20222VT525G6EBRCW1H20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC256X18R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC256X32R20221VT525G6EBRCW1H20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC256X36R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC256X41R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC256X72R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC256X74R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC512X35R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC512X43R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC512X43R20221VT525G6EBRCH20QLA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HC512X69R20221VT525G6EBRCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD128X137R20122VT335G6EBRCH20LD_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD128X256R20122VT335G6BSIRCW1H20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD128X256R20122VT335G6EBRCW1H20LD_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD2048X156R20422VT335G6BSIRCW1H20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD2048X156R20422VT535G6BSIRCW1H20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD2048X156R30223VT535G6BSIRCW1H20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD2048X262R20223VT335G6EBRCH20LD_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD2048X262R20223VT535G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD2048X46R30121VT335G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD256X18R20111VT335G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD256X32R20111VT335G6BSIRCW1H20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD256X41R20111VT335G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD256X72R20122VT335G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD4096X137R20422VT335G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD4096X137R30423VT435G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD4224X138R20822VT335G6EBRCH20LD_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD512X137R20122VT335G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD512X137R20122VT335G6EBRCH20LD_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD512X137R20122VT535G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD512X44R20111VT335G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD512X7R20111VT335G6BSIRCH20OLD_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SP111HD512X80R20121VT335G6EBRCH20LD_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC128X139RR00121VT3255G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC128X187RR00122VT3255G60BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC128X35RR00111VT3255G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC128X59RR00111VT3255G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC128X73RR00121VT3255G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC128X7RR10111VT3525G6EBCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC160X128RR10121VT32355G6EBCH20QLA_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC160X128RR10121VT3525G6EBCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC160X128RR10121VT3525G6EBCH20QLA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC256X145RR00421VT3255G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC300X138RR10221VT3525G6EBCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC300X72RR10221VT3255G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC300X72RR10221VT3525G6EBCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X115RR10221VT3525G6BSICW1H20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X115RR10421VT3255G6BSICW1H20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X128RR10221VT3525G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X128RR10421VT3525G6BSICW1H20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X137RR10221VT3525G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X138RR10421VT3525G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X7RR20111VT3255G6BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC512X7RR20111VT3525G6EBCH20LA_wrapper.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC64X187RR00122VT3255G60BSICH20OLA_ESTIMATED.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/lef/M5SRF211HC64X257RR00122VT3255G60BSICW1H20OLA_ESTIMATED.lef \
"
set NDM_REFERENCE_LIBRARY " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ck06t0750v/ndm/tsmc5ff_ck06t0750v.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ga06t0750v/ndm/tsmc5ff_ga06t0750v.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_mb06t0750v/ndm/tsmc5ff_mb06t0750v.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_sc06t0750v/ndm/tsmc5ff_sc06t0750v.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_top06t0750v/ndm/tsmc5ff_top06t0750v.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5PD211HC2048X20R20221VT525G6BSIRCH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5PSP111HD1056X39R20221VT525G6EBRCW1H20LD_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5PSP111HD2112X39R20421VT525G6EBRCW1H20LD_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5PSP111HD4096X137R20822VT525G6BSIRCH20OD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SC111HC128X35R20121VT555G6BSIRCH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SC111HC128X59R20121VT535G6BSIRCH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SC111HC128X59R20122VT555G6BSIRCH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SC111HC256X32R20121VT555G6BSIRCW1H20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SC111HC256X35R20121VT555G6BSIRCH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SC111HC256X37R20121VT555G6BSIRCH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SC111HC256X39R20122VT555G6BSIRCH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SC111HC256X43R20122VT555G6BSIRCH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SC111HC256X43R20122VT555G6BSIRCW1H20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC1024X35R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC1024X46R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC1056X78R20221VT525G6EBRCW1H20QLA_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC128X43R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC128X46R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC128X46R20221VT525G6EBRCH20QLA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC128X59R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC2048X46R20221VT525G6EBRCH20QLA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC2112X156R20422VT525G6EBRCW1H20QLA_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC2112X78R20421VT525G6EBRCW1H20QLA_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC256X128R20222VT525G6EBRCW1H20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC256X18R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC256X32R20221VT525G6EBRCW1H20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC256X36R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC256X41R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC256X72R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC256X74R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC512X35R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC512X43R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC512X43R20221VT525G6EBRCH20QLA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HC512X69R20221VT525G6EBRCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD128X137R20122VT335G6EBRCH20LD_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD128X256R20122VT335G6BSIRCW1H20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD128X256R20122VT335G6EBRCW1H20LD_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD2048X156R20422VT335G6BSIRCW1H20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD2048X156R20422VT535G6BSIRCW1H20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD2048X156R30223VT535G6BSIRCW1H20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD2048X262R20223VT335G6EBRCH20LD_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD2048X262R20223VT535G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD2048X46R30121VT335G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD256X18R20111VT335G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD256X32R20111VT335G6BSIRCW1H20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD256X41R20111VT335G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD256X72R20122VT335G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD4096X137R20422VT335G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD4096X137R30423VT435G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD4224X138R20822VT335G6EBRCH20LD_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD512X137R20122VT335G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD512X137R20122VT335G6EBRCH20LD_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD512X137R20122VT535G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD512X44R20111VT335G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD512X7R20111VT335G6BSIRCH20OLD_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SP111HD512X80R20121VT335G6EBRCH20LD_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC128X139RR00121VT3255G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC128X187RR00122VT3255G60BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC128X35RR00111VT3255G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC128X59RR00111VT3255G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC128X73RR00121VT3255G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC128X7RR10111VT3525G6EBCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC160X128RR10121VT32355G6EBCH20QLA_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC160X128RR10121VT3525G6EBCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC160X128RR10121VT3525G6EBCH20QLA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC256X145RR00421VT3255G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC300X138RR10221VT3525G6EBCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC300X72RR10221VT3255G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC300X72RR10221VT3525G6EBCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X115RR10221VT3525G6BSICW1H20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X115RR10421VT3255G6BSICW1H20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X128RR10221VT3525G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X128RR10421VT3525G6BSICW1H20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X137RR10221VT3525G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X138RR10421VT3525G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X7RR20111VT3255G6BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC512X7RR20111VT3525G6EBCH20LA_wrapper.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC64X187RR00122VT3255G60BSICH20OLA_ESTIMATED.ndm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//lay/M5SRF211HC64X257RR00122VT3255G60BSICW1H20OLA_ESTIMATED.ndm \
"

set LEAKAGE_CONFIG_FILE ""

set LEAKAGE_LEF_SIDE_FILES ""

set LEAKAGE_LIB_SIDE_FILES ""

set POWER_GRID_LIBRARIES " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/PGV/techonly.cl \
"

set STREAM_FILE_LIST " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ck06t0750v/oasis/tsmc5ff_ck06t0750v.oas \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ga06t0750v/oasis/tsmc5ff_ga06t0750v.oas \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_mb06t0750v/oasis/tsmc5ff_mb06t0750v.oas \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_sc06t0750v/oasis/tsmc5ff_sc06t0750v.oas \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_top06t0750v/oasis/tsmc5ff_top06t0750v.oas \
"

set CTL_FILE_LIST ""

#################################################################################################################################################################################################
###	RC view
#################################################################################################################################################################################################
set rc_corner(gpd_file) "$GPD_DIR/out/gpd/${DESIGN_NAME}.${STAGE}.HIER.gpd"

set rc_corner(cworst)  "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cworst_CCworst_T.tch"
set rc_corner(cworst,nxtgrd)  "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cworst_CCworst_T.nxtgrd"
set rc_corner(cworst,rc_variation) 0.1
set rc_corner(cworst,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_cworst_0.spef.gz"
set rc_corner(cworst,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_cworst_125.spef.gz"
set rc_corner(cworst,preRoute_res) 1.029
set rc_corner(cworst,postRoute_res) "{1.023 1.023 1}"
set rc_corner(cworst,preRoute_cap) 1.223
set rc_corner(cworst,postRoute_cap) "{1.026 1.026 1}"
set rc_corner(cworst,postRoute_xcap) "{1.064 1.064 1}"
set rc_corner(cworst,preRoute_clkres) 1
set rc_corner(cworst,preRoute_clkcap) 1
set rc_corner(cworst,postRoute_clkcap) "{1 1 1}"
set rc_corner(cworst,postRoute_clkres) "{1 1 1}"

set rc_corner(rcworst)  "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcworst_CCworst_T.tch"
set rc_corner(rcworst,nxtgrd)  "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcworst_CCworst_T.nxtgrd"
set rc_corner(rcworst,rc_variation) 0.1
set rc_corner(rcworst,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_rcworst_0.spef.gz"
set rc_corner(rcworst,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_rcworst_125.spef.gz"
set rc_corner(rcworst,preRoute_res) 1.003
set rc_corner(rcworst,postRoute_res) "{1.017 1.017 1}"
set rc_corner(rcworst,preRoute_cap) 1.223
set rc_corner(rcworst,postRoute_cap) "{1.024 1.024 1}"
set rc_corner(rcworst,postRoute_xcap) "{1.007 1.007 1}"
set rc_corner(rcworst,preRoute_clkres) 1
set rc_corner(rcworst,preRoute_clkcap) 1
set rc_corner(rcworst,postRoute_clkcap) "{1 1 1}"
set rc_corner(rcworst,postRoute_clkres) "{1 1 1}"

set rc_corner(cbest)  "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cbest_CCbest.tch"
set rc_corner(cbest,nxtgrd)  "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cbest_CCbest.nxtgrd"
set rc_corner(cbest,rc_variation) 0.1
set rc_corner(cbest,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_cbest_0.spef.gz"
set rc_corner(cbest,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_cbest_125.spef.gz"
set rc_corner(cbest,preRoute_res) 0.935
set rc_corner(cbest,postRoute_res) "{1.009 1.009 1}"
set rc_corner(cbest,preRoute_cap) 1.167
set rc_corner(cbest,postRoute_cap) "{1.032 1.032 1}"
set rc_corner(cbest,postRoute_xcap) "{1.028 1.028 1}"
set rc_corner(cbest,preRoute_clkres) 1
set rc_corner(cbest,preRoute_clkcap) 1
set rc_corner(cbest,postRoute_clkcap) "{1 1 1}"
set rc_corner(cbest,postRoute_clkres) "{1 1 1}"

set rc_corner(rcbest)  "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcbest_CCbest.tch"
set rc_corner(rcbest,nxtgrd)  "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_rcbest_CCbest.nxtgrd"
set rc_corner(rcbest,rc_variation) 0.1
set rc_corner(rcbest,spef_0) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_rcbest_0.spef.gz"
set rc_corner(rcbest,spef_125) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_rcbest_125.spef.gz"
set rc_corner(rcbest,preRoute_res) 0.945
set rc_corner(rcbest,postRoute_res) "{1.026 1.026 1}"
set rc_corner(rcbest,preRoute_cap) 1.21
set rc_corner(rcbest,postRoute_cap) "{1.044 1.044 1}"
set rc_corner(rcbest,postRoute_xcap) "{1.073 1.073 1}"
set rc_corner(rcbest,preRoute_clkres) 1
set rc_corner(rcbest,preRoute_clkcap) 1
set rc_corner(rcbest,postRoute_clkcap) "{1 1 1}"
set rc_corner(rcbest,postRoute_clkres) "{1 1 1}"

set rc_corner(typical)  /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/typical/Tech/typical/qrcTechFile
set rc_corner(typical,nxtgrd) ""
set rc_corner(typical,rc_variation) 0.1
set rc_corner(typical,spef_25) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_typical_25.spef.gz"
set rc_corner(typical,spef_85) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}_typical_85.spef.gz"


#################################################################################################################################################################################################
###	timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_SS
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PD211HC2048X20R20221VT525G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD1056X39R20221VT525G6EBRCW1H20LD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD1056X39R20221VT525G6EBRCW1H20LD_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD2112X39R20421VT525G6EBRCW1H20LD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD2112X39R20421VT525G6EBRCW1H20LD_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD4096X137R20822VT525G6BSIRCH20OD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC128X35R20121VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC128X59R20121VT535G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC128X59R20122VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X32R20121VT555G6BSIRCW1H20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X35R20121VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X37R20121VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X39R20122VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X43R20122VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X43R20122VT555G6BSIRCW1H20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1024X35R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1024X46R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1056X78R20221VT525G6EBRCW1H20QLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1056X78R20221VT525G6EBRCW1H20QLA_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X43R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X46R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X46R20221VT525G6EBRCH20QLA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X59R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2048X46R20221VT525G6EBRCH20QLA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2112X156R20422VT525G6EBRCW1H20QLA_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2112X78R20421VT525G6EBRCW1H20QLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2112X78R20421VT525G6EBRCW1H20QLA_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X128R20222VT525G6EBRCW1H20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X18R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X32R20221VT525G6EBRCW1H20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X36R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X41R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X72R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X74R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X35R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X43R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X43R20221VT525G6EBRCH20QLA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X69R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD128X137R20122VT335G6EBRCH20LD_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD128X256R20122VT335G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD128X256R20122VT335G6EBRCW1H20LD_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X156R20422VT335G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X156R20422VT535G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X156R30223VT535G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X262R20223VT335G6EBRCH20LD_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X262R20223VT535G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X46R30121VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X18R20111VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X32R20111VT335G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X41R20111VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X72R20122VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X137R20422VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X137R30423VT435G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4224X138R20822VT335G6EBRCH20LD_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X137R20122VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X137R20122VT335G6EBRCH20LD_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X137R20122VT535G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X44R20111VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X7R20111VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X80R20121VT335G6EBRCH20LD_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X139RR00121VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X187RR00122VT3255G60BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X35RR00111VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X59RR00111VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X73RR00121VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X7RR10111VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT32355G6EBCH20QLA_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT3525G6EBCH20QLA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC256X145RR00421VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X72RR10221VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X72RR10221VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X115RR10221VT3525G6BSICW1H20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X115RR10421VT3255G6BSICW1H20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X128RR10221VT3525G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X128RR10421VT3525G6BSICW1H20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X137RR10221VT3525G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X138RR10421VT3525G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X7RR20111VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X7RR20111VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC64X187RR00122VT3255G60BSICH20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC64X257RR00122VT3255G60BSICW1H20OLA_ESTIMATED_pssg_s300_v0670_t125_xrcwccwt.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/INVS/5FF_pssg_s300_v0670_t125_spatial_innovus-socv.socv_table \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/INVS/cln05.wire.SS.socv \
"

set pvt_corner($PVT_CORNER,pt_pocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/cln05.wire.SS.pocvm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_ck06t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_ga06t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_mb06t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_sc06t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_top06t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
"

set pvt_corner($PVT_CORNER,pt_ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_ck06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_ga06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_mb06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_sc06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_top06t0750v.coefficient \
 \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/pt_si_settings_pssg_s300_v0670_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_pssg_s300_v0670_t125_primetime-lvf.global_signoff \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_ck06t0750v_pssg_s300_v0670_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_ga06t0750v_pssg_s300_v0670_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_mb06t0750v_pssg_s300_v0670_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_sc06t0750v_pssg_s300_v0670_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_top06t0750v_pssg_s300_v0670_t125.tcl \
"


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_SS
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PD211HC2048X20R20221VT525G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD4096X137R20822VT525G6BSIRCH20OD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC128X35R20121VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC128X59R20121VT535G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC128X59R20122VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X32R20121VT555G6BSIRCW1H20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X35R20121VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X37R20121VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X39R20122VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X43R20122VT555G6BSIRCH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X43R20122VT555G6BSIRCW1H20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1024X35R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1024X46R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X43R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X46R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X46R20221VT525G6EBRCH20QLA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X59R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2048X46R20221VT525G6EBRCH20QLA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X128R20222VT525G6EBRCW1H20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X18R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X32R20221VT525G6EBRCW1H20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X36R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X41R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X72R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X74R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X35R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X43R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X43R20221VT525G6EBRCH20QLA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X69R20221VT525G6EBRCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD128X256R20122VT335G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X156R20422VT335G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X156R20422VT535G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X156R30223VT535G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X262R20223VT535G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X46R30121VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X18R20111VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X32R20111VT335G6BSIRCW1H20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X41R20111VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X72R20122VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X137R20422VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X137R30423VT435G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X137R20122VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X137R20122VT535G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X44R20111VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X7R20111VT335G6BSIRCH20OLD_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X139RR00121VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X187RR00122VT3255G60BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X35RR00111VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X59RR00111VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X73RR00121VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X7RR10111VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT3525G6EBCH20QLA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC256X145RR00421VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X72RR10221VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X72RR10221VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X115RR10221VT3525G6BSICW1H20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X115RR10421VT3255G6BSICW1H20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X128RR10221VT3525G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X128RR10421VT3525G6BSICW1H20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X137RR10221VT3525G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X138RR10421VT3525G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X7RR20111VT3255G6BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X7RR20111VT3525G6EBCH20LA_wrapper_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC64X187RR00122VT3255G60BSICH20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC64X257RR00122VT3255G60BSICW1H20OLA_ESTIMATED_pssg_s300_v0670_t000_xrcwccwt.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/INVS/5FF_pssg_s300_v0670_t000_spatial_innovus-socv.socv_table \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/INVS/cln05.wire.SS.socv \
"

set pvt_corner($PVT_CORNER,pt_pocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/cln05.wire.SS.pocvm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_ck06t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_ga06t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_mb06t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_sc06t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_top06t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
"

set pvt_corner($PVT_CORNER,pt_ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_ck06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_ga06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_mb06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_sc06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_top06t0750v.coefficient \
 \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/pt_si_settings_pssg_s300_v0670_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_pssg_s300_v0670_t000_primetime-lvf.global_signoff \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_ck06t0750v_pssg_s300_v0670_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_ga06t0750v_pssg_s300_v0670_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_mb06t0750v_pssg_s300_v0670_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_sc06t0750v_pssg_s300_v0670_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_top06t0750v_pssg_s300_v0670_t000.tcl \
"


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_FF
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PD211HC2048X20R20221VT525G6BSIRCH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD1056X39R20221VT525G6EBRCW1H20LD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD1056X39R20221VT525G6EBRCW1H20LD_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD2112X39R20421VT525G6EBRCW1H20LD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD2112X39R20421VT525G6EBRCW1H20LD_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD4096X137R20822VT525G6BSIRCH20OD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC128X35R20121VT555G6BSIRCH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC128X59R20121VT535G6BSIRCH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC128X59R20122VT555G6BSIRCH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X32R20121VT555G6BSIRCW1H20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X35R20121VT555G6BSIRCH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X37R20121VT555G6BSIRCH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X39R20122VT555G6BSIRCH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X43R20122VT555G6BSIRCH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SC111HC256X43R20122VT555G6BSIRCW1H20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1024X35R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1024X46R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1056X78R20221VT525G6EBRCW1H20QLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1056X78R20221VT525G6EBRCW1H20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X43R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X46R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X46R20221VT525G6EBRCH20QLA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X59R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2048X46R20221VT525G6EBRCH20QLA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2112X156R20422VT525G6EBRCW1H20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2112X78R20421VT525G6EBRCW1H20QLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2112X78R20421VT525G6EBRCW1H20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X128R20222VT525G6EBRCW1H20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X18R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X32R20221VT525G6EBRCW1H20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X36R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X41R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X72R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X74R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X35R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X43R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X43R20221VT525G6EBRCH20QLA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X69R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD128X137R20122VT335G6EBRCH20LD_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD128X256R20122VT335G6BSIRCW1H20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD128X256R20122VT335G6EBRCW1H20LD_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X156R20422VT335G6BSIRCW1H20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X156R20422VT535G6BSIRCW1H20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X156R30223VT535G6BSIRCW1H20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X262R20223VT335G6EBRCH20LD_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X262R20223VT535G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X46R30121VT335G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X18R20111VT335G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X32R20111VT335G6BSIRCW1H20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X41R20111VT335G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD256X72R20122VT335G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X137R20422VT335G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X137R30423VT435G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4224X138R20822VT335G6EBRCH20LD_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X137R20122VT335G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X137R20122VT335G6EBRCH20LD_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X137R20122VT535G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X44R20111VT335G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X7R20111VT335G6BSIRCH20OLD_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X80R20121VT335G6EBRCH20LD_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X139RR00121VT3255G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X187RR00122VT3255G60BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X35RR00111VT3255G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X59RR00111VT3255G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X73RR00121VT3255G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X7RR10111VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT32355G6EBCH20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT3525G6EBCH20QLA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC256X145RR00421VT3255G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X72RR10221VT3255G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X72RR10221VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X115RR10221VT3525G6BSICW1H20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X115RR10421VT3255G6BSICW1H20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X128RR10221VT3525G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X128RR10421VT3525G6BSICW1H20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X137RR10221VT3525G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X138RR10421VT3525G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X7RR20111VT3255G6BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X7RR20111VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC64X187RR00122VT3255G60BSICH20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC64X257RR00122VT3255G60BSICW1H20OLA_ESTIMATED_pffg_s300_v0830_t125_xrcbccbt.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/INVS/5FF_pffg_s300_v0830_t125_spatial_innovus-socv.socv_table \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/INVS/cln05.wire.FF.socv \
"


set pvt_corner($PVT_CORNER,pt_pocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/cln05.wire.FF.pocvm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_ck06t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_ga06t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_mb06t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_sc06t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_top06t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
"

set pvt_corner($PVT_CORNER,pt_ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_ck06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_ga06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_mb06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_sc06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_top06t0750v.coefficient \
 \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/pt_si_settings_pffg_s300_v0830_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_pffg_s300_v0830_t125_primetime-lvf.global_signoff \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_ck06t0750v_pffg_s300_v0830_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_ga06t0750v_pffg_s300_v0830_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_mb06t0750v_pffg_s300_v0830_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_sc06t0750v_pffg_s300_v0830_t125.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_top06t0750v_pffg_s300_v0830_t125.tcl \

"


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_FF
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_top06t0750v/db/tsmc5ff_top06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_sc06t0750v/db/tsmc5ff_sc06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_mb06t0750v/db/tsmc5ff_mb06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ga06t0750v/db/tsmc5ff_ga06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_ck06t0750v/db/tsmc5ff_ck06t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD1056X39R20221VT525G6EBRCW1H20LD_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD1056X39R20221VT525G6EBRCW1H20LD_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD2112X39R20421VT525G6EBRCW1H20LD_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5PSP111HD2112X39R20421VT525G6EBRCW1H20LD_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X129AR00221VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC128X67AR00221VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X103AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X135AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC16X137AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X49AR00111VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC64X73AR00121VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5RF211HC80X133AR00221VT32355G6EBCH20_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1024X35R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1024X46R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1056X78R20221VT525G6EBRCW1H20QLA_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC1056X78R20221VT525G6EBRCW1H20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X43R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X46R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X46R20221VT525G6EBRCH20QLA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC128X59R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2048X46R20221VT525G6EBRCH20QLA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2112X156R20422VT525G6EBRCW1H20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2112X78R20421VT525G6EBRCW1H20QLA_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC2112X78R20421VT525G6EBRCW1H20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X128R20222VT525G6EBRCW1H20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X18R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X32R20221VT525G6EBRCW1H20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X36R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X41R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X72R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC256X74R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X35R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X43R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X43R20221VT525G6EBRCH20QLA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HC512X69R20221VT525G6EBRCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD128X137R20122VT335G6EBRCH20LD_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD128X256R20122VT335G6EBRCW1H20LD_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD2048X262R20223VT335G6EBRCH20LD_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4096X138R20422VT335G6EBRCH20LD_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD4224X138R20822VT335G6EBRCH20LD_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X137R20122VT335G6EBRCH20LD_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SP111HD512X80R20121VT335G6EBRCH20LD_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X7RR10111VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC128X80RR10121VT32355G6EBCH20LA_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT32355G6EBCH20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X128RR10121VT3525G6EBCH20QLA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC160X130RR10121VT3525G6EBCH20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC256X133RR10221VT32355G6EBCH20LA_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6BSICH20OLA_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X138RR10221VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X72RR10221VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC300X74RR10421VT32355G6EBCH20LA_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X128RR10221VT32355G6EBCH20QLA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC320X130RR10221VT3525G6EBCH20QLA_ESTIMATED_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X107RR10221VT3525G6EBCW1H20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211111/memory/prod//tim/etm/M5SRF211HC512X7RR20111VT3525G6EBCH20LA_wrapper_pffg_s300_v0830_t000_xrcbccbt.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/INVS/5FF_pffg_s300_v0830_t000_spatial_innovus-socv.socv_table \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/INVS/cln05.wire.FF.socv \
"

set pvt_corner($PVT_CORNER,pt_pocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/cln05.wire.FF.pocvm \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_ck06t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_ga06t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_mb06t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_sc06t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_top06t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
"

set pvt_corner($PVT_CORNER,pt_ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_ck06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_ga06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_mb06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_sc06t0750v.coefficient \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc5ff_top06t0750v.coefficient \
 \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/pt_si_settings_pffg_s300_v0830_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/5FF_pffg_s300_v0830_t000_primetime-lvf.global_signoff \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_ck06t0750v_pffg_s300_v0830_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_ga06t0750v_pffg_s300_v0830_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_mb06t0750v_pffg_s300_v0830_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_sc06t0750v_pffg_s300_v0830_t000.tcl \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc5ff_top06t0750v_pffg_s300_v0830_t000.tcl \
"


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER tt0p75v85c
set pvt_corner($PVT_CORNER,temperature) "85"
set pvt_corner($PVT_CORNER,timing) ""
set pvt_corner($PVT_CORNER,ocv) ""

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER tt0p75v25c
set pvt_corner($PVT_CORNER,temperature) "25"
set pvt_corner($PVT_CORNER,timing) ""
set pvt_corner($PVT_CORNER,ocv) ""


#################################################################################################################################################################################################
###	design setting 
#################################################################################################################################################################################################
set DEFAULT_SITE CORE_6
if {![info exists MAX_ROUTING_LAYER]} {set MAX_ROUTING_LAYER 16}
if {![info exists MIN_ROUTING_LAYER]} {set MIN_ROUTING_LAYER 2}

# TODO: Add supply voltage per net
set PWR_NET     [list VDD]
set GND_NET     [list VSS]
set PWR_PINS    [list VDD VDDB VDDF]
set GND_PINS    [list VSS VSSB]

if { (![info exists DEF_FILE] || $DEF_FILE == "None") && (  ([info exists PYISICAL_SYN] && $PYISICAL_SYN == "true")  || ( ![info exists ::synopsys_program_name] && [get_db / .program_short_name] == "innovus") ) } {
    
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

set VT_GROUPS(LVTLL)  *F6LL*
set VT_GROUPS(LVT)    *F6LN*
set VT_GROUPS(ULVT)   *F6UN*
set VT_GROUPS(ULVTLL) *F6UL*
set VT_GROUPS(EVT)    *F6EN*
#set VT_GROUPS(LVTLL)  *LVTLL06*
#set VT_GROUPS(ULVTLL) *ULTLL06*
set leakage_pattern_priority_list "F6LL F6LN F6UL F6UN F6EN"



set DONT_SCAN_FF ""
set DONT_TOUCH_INST "*DONT_TOUCH* *i_spare*" ; # REMOVED spare_i from dont touch
set SIZE_ONLY_INST "*SIZE_ONLY*"

if {[info exists MBIT] && $MBIT == "true"} {
  set DONT_USE_CELLS " \
    *_BDFF* \
    F6*_TRI* \
    F6*BSDFFRW2* \
    F6*BSDFFRW2* \
    F6*BSDFFRW4* \
    F6*BSDFFRW8* \
    F6*BSDFFRAND2* \
    F6*BSDFFLR* \
    F6*BSDFFM* \
    F6*BDLATN* \
    F6*_CK* \
    F6*BORDER* \
    F6*DLY* \
    F6*CCCAP* \
    F6*CDM* \
    F6*DIODE* \
    F6*FILLER* \
    F6*BDLATR* \
    F6*_DLAT* \
    F6*CKEN* \
    F6*LCAP* \
    F6*LPD* \
    F6*SYNC* \
    F6*TOP* \
    F6*TIEG* \
    F6*G_* \
    F6EN* \
    F6*BSDFFW2* \
    F6*BSDFFW4* \
    *BSDFFAO22* \
    *BSDFFCW4* \
  "

} else {
  set DONT_USE_CELLS " \
    *_BDFF* \
    F6*_TRI* \
    F6*BSDFFRAND2* \
    F6*BSDFFLR* \
    F6*BSDFFM* \
    F6*BDLATN* \
    F6*_CK* \
    F6*BORDER* \
    F6*DLY* \
    F6*CCCAP* \
    F6*CDM* \
    F6*DIODE* \
    F6*FILLER* \
    F6*BDLATR* \
    F6*_DLAT* \
    F6*CKEN* \
    F6*LCAP* \
    F6*LPD* \
    F6*SYNC* \
    F6*TOP* \
    F6*TIEG* \
    F6*G_* \
    F6EN* \
    *BSDFFAO22* \
  "
}

set DO_USE_CELLS " \
F6UNAA_CKENOAX4 \
F6UNAA_CKENOAX8 \
F6UNAA_LPDCKENAOAX12 \
F6UNAA_LPDCKENAOAX8 \
"

#################################################################################################################################################################################################
###	place setting 
#################################################################################################################################################################################################
set IOBUFFER_CELL "F6LLAA_BUFAX4"
set USEABLE_IOBUFFER_CELL {F6UNAA_BUFAX4 F6UNAA_BUFAX8 F6UNAA_BUFAX12 F6LLAA_BUFAX4 F6LLAA_BUFAX8 F6LLAA_BUFAX12 F6LNAA_BUFAX4 F6LNAA_BUFAX8 F6LNAA_BUFAX12  }
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

#set ENDCAPS(TOP_EDGE) 			{F6LLAA_BORDERROWPGAP F6LLAA_BORDERROWP8 F6LLAA_BORDERROWP4 F6LLAA_BORDERROWP2 F6LLAA_BORDERROWP16 F6LLAA_BORDERROWP1}

#set ENDCAPS(BOTTOM_EDGE) 		{F6LLAA_BORDERROWPGAP F6LLAA_BORDERROWP8 F6LLAA_BORDERROWP4 F6LLAA_BORDERROWP2 F6LLAA_BORDERROWP16 F6LLAA_BORDERROWP1}
set ENDCAPS(TOP_EDGE) 		{F6LLAA_BORDERROWP16 F6LLAA_BORDERROWP8 F6LLAA_BORDERROWP4 F6LLAA_BORDERROWP2 F6LLAA_BORDERROWP1 BORDERROWPGAP}
#set ENDCAPS(LEFT_EDGE) 			F6LLAA_BORDERTIESMRIGHT
set ENDCAPS(LEFT_EDGE) 		F6LLAA_BORDERTIESMRIGHT
#set ENDCAPS(RIGHT_TOP_CORNER) 		F6LLAA_BORDERCORNERPTIERIGHT

#set ENDCAPS(LEFT_BOTTOM_CORNER) 	F6LLAA_BORDERCORNERPTIERIGHT
set ENDCAPS(LEFT_TOP_CORNER) 	F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_TOP_CORNER) 		F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_BOTTOM_CORNER) 	F6LLAA_BORDERCORNERPTIERIGHT
#set ENDCAPS(LEFT_TOP_EDGE) 		F6LLAA_BORDERCORNERINTPRIGHT
#set ENDCAPS(RIGHT_TOP_EDGE) 		F6LLAA_BORDERCORNERINTPRIGHT
#set ENDCAPS(LEFT_BOTTOM_EDGE) 		F6LLAA_BORDERCORNERINTPRIGHT


#set ENDCAPS(LEFT_BOTTOM_EDGE) 		F6LLAA_BORDERCORNERINTPTIERIGHT
set ENDCAPS(LEFT_TOP_EDGE) 		F6LLAA_BORDERCORNERINTPTIERIGHT



#set ENDCAPS(LEFT_TOP_EDGE_NEIGHBOR) 	HDBSVT06_CAPBRINCGAP3	
#set ENDCAPS(RIGHT_TOP_EDGE_NEIGHBOR) 	HDBSVT06_CAPBLINCGAP3	
#set ENDCAPS(LEFT_BOTTOM_EDGE_NEIGHBOR)  HDBSVT06_CAPBRINCGAP3		
#set ENDCAPS(RIGHT_BOTTOM_EDGE_NEIGHBOR) HDBSVT06_CAPBLINCGAP3		


set TAPCELL "{F6LLAA_TIESMALL rule 15.8 boundary_layer LUP_SRM boundary_rule 15.8} {F6LLAA_TIE rule 22.5}"
set SWAP_WELL_TAPS { F6LLAA_TIE }
set TIEHCELL "F6LLAA_TIEHI"
set TIELCELL "F6LLAA_TIELO"
set ANTENNA_CELL_NAME "F6LLAA_DIODEX2 F6LLAA_DIODEX3 F6LLAA_DIODEX4"

set PRE_PLACE_DECAP "F6LLAA_CCCAP16"
set PRE_PLACE_ECO_DCAP "F6LLAAG_CCCAP16"

set DCAP_CELLS_LIST "F6LLAA_CCCAPD64BY16 F6LLAA_CCCAPD32BY8 F6LLAA_CCCAPD16BY4 F6LLAA_CCCAPD16BY2 F6LLAA_CCCAP8BY2 F6LLAA_CCCAP16 F6LLAA_CCCAP8 F6LLAA_CCCAP4 F6LLAA_CCCAP3 F6LLBA_CCCAP3 F6LLCA_CCCAP3 F6LLDA_CCCAP3"
set FILLER64_CELLS_LIST "F6LLAA_FILLER64 F6LNAA_FILLER64 F6ULAA_FILLER64 F6UNAA_FILLER64"
set FILLER32_CELLS_LIST "F6LLAA_FILLER32 F6LNAA_FILLER32 F6ULAA_FILLER32 F6UNAA_FILLER64"
set FILLER16_CELLS_LIST "F6LLAA_FILLER16 F6LNAA_FILLER16 F6ULAA_FILLER16 F6UNAA_FILLER16"
set FILLER12_CELLS_LIST ""
set FILLER8_CELLS_LIST  "F6LLAA_FILLER8 F6LNAA_FILLER8 F6ULAA_FILLER8 F6UNAA_FILLER8"
set FILLER4_CELLS_LIST  "F6LLAA_FILLER4 F6LNAA_FILLER4 F6ULAA_FILLER4 F6UNAA_FILLER4"
set FILLER3_CELLS_LIST  "F6LLAA_FILLER3 F6LNAA_FILLER3 F6ULAA_FILLER3 F6UNAA_FILLER3"
set FILLER2_CELLS_LIST  "F6LLAA_FILLER2 F6LNAA_FILLER2 F6ULAA_FILLER2 F6UNAA_FILLER2"
set FILLER1_CELLS_LIST  "F6LLAA_FILLER1 F6LLAA_FILLER1B F6LNAA_FILLER1 F6LNAA_FILLER1B F6ULAA_FILLER1 F6ULAA_FILLER1B F6UNAA_FILLER1 F6UNAA_FILLER1B"

set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"


set ADD_FILLERS_SWAP_CELL {}

###################################################################################################################################################################################################
###	CTS setting 
###################################################################################################################################################################################################


set CTS_BUFFER_CELLS          {F6UNAA_LPDBUFX8 F6UNAA_LPDBUFX12 F6UNAA_LPDBUFX16 }

set CTS_INVERTER_CELLS_TOP    { \
F6UNAA_LPDINVX28 \
F6UNAA_LPDINVX32 \
F6UNAA_LPDINVX36 \
F6UNAA_LPDINVX40 \
F6UNBA_LPDINVX28 \
F6UNBA_LPDINVX32 \
F6UNBA_LPDINVX36 \
F6UNBA_LPDINVX40 \
}

set CTS_INVERTER_CELLS_TRUNK  { \
F6UNAA_LPDINVX16 \
F6UNAA_LPDINVX20 \
F6UNAA_LPDINVX24 \
F6UNAA_LPDINVX28 \
F6UNBA_LPDINVX16 \
F6UNBA_LPDINVX20 \
F6UNBA_LPDINVX24 \
F6UNBA_LPDINVX28 \
}

set CTS_INVERTER_CELLS_LEAF   { \
F6UNAA_LPDINVX4  \
F6UNAA_LPDINVX8  \
F6UNAA_LPDINVX12 \
F6UNAA_LPDINVX16 \
F6UNAA_LPDINVX20 \
F6UNAA_LPDINVX24 \
F6UNBA_LPDINVX4  \
F6UNBA_LPDINVX8  \
F6UNBA_LPDINVX12 \
F6UNBA_LPDINVX16 \
F6UNBA_LPDINVX20 \
F6UNBA_LPDINVX24 \
}

set CTS_LOGIC_CELLS           {F6UNAA_CKENOAX8 F6UNAA_CKENOAX6 F6UNAA_CKENOAX4 F6UNAA_CKENOAX32 F6UNAA_CKENOAX20 F6UNAA_CKENOAX2 F6UNAA_CKENOAX16 F6UNAA_CKENOAX12 F6UNAA_CKENNOOX8 F6UNAA_CKENNOOX4 F6UNAA_CKENNOOX16 F6UNAA_CKENNOOX12 F6UNAA_CKENAOAX4 F6UNAA_BALAND2X8 F6UNAA_BALAND2X4 F6UNAA_BALAND2X2 F6UNAA_CKAND2X8 F6UNAA_CKMUX2X12 F6UNAA_CKMUX2X16 F6UNAA_CKMUX2X8 F6UNAA_CKNAND2X8 F6UNAA_CKNOR2X8 F6UNAA_CKOR2X8 F6UNAA_CKXOR2X8 }
set CTS_CLOCK_GATING_CELLS    {F6UNAA_CKENOAX8 F6UNAA_CKENOAX6 F6UNAA_CKENOAX4 F6UNAA_CKENOAX32 F6UNAA_CKENOAX20 F6UNAA_CKENOAX2 F6UNAA_CKENOAX16 F6UNAA_CKENOAX12 F6UNAA_LPDCKENOAX8 F6UNAA_LPDCKENOAX12 F6UNAA_LPDCKENOAX16 F6UNAA_LPDCKENOAX20 F6UNAA_LPDCKENOAX24 F6UNAA_LPDCKENOAX28}
set CTS_CELLS_HALO [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]


set HOLD_FIX_CELLS_LIST [list \
*_DLY* \
] 
#################################################################################################################################################################################################
###	tools dependent
#################################################################################################################################################################################################
if { ![info exists ::synopsys_program_name] } {
 if {[info command distribute_partition] == "" } {
  
  if { [get_db / .program_short_name] == "genus" } {
	puts "-I- extra definition for [get_db / .program_short_name]"

	# Variables to set before loading libraries
	set_db lp_insert_clock_gating               true
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




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

#if { [info exists ::env(SYN4RTL)] } { set fe_mode $::env(SYN4RTL) } else { set fe_mode false }
#if { [info exists ::env(PROJECT)] } { set PROJECT ${PROJECT} } 

set mmmc_results ./scripts_local/mmmc_results.tcl

if {![info exists DESIGN_NAME]} {set DESIGN_NAME [lindex [split [pwd] "/"] end-2]}
if {![info exists SPEF_DIR]}    {set SPEF_DIR ""}
if {![info exists GPD_DIR]}     {set GPD_DIR ""}

#################################################################################################################################################################################################
###	running scenarios 
#################################################################################################################################################################################################

set scenarios(setup) "func_ssgnp0p675v0c_cworst_setup func_ssgnp0p675v125c_cworst_setup func_ssgnp0p675v0c_rcworst_setup func_ssgnp0p675v125c_rcworst_setup"
set scenarios(hold) "func_ssgnp0p675v0c_cworst_hold func_ssgnp0p675v125c_cworst_hold func_ffgnp0p825v125c_cbest_hold func_ffgnp0p825v0c_cbest_hold"
set scenarios(dynamic) "func_ffgnp0p825v125c_cbest_hold"
set scenarios(leakage) "func_ffgnp0p825v125c_cbest_hold"

set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]

if {![info exists STAGE] || $STAGE == "syn" || $STAGE == "syn_reg" } {
    set scenarios(setup) "func_ssgnp0p675v0c_cworst_setup"
	if { !$fe_mode } {
		set scenarios(hold) "func_ffgnp0p825v125c_cbest_hold"
		set scenarios(dynamic) "func_ffgnp0p825v125c_cbest_hold"
		set scenarios(leakage) "func_ffgnp0p825v125c_cbest_hold"
	} else {
		set scenarios(hold) "func_ssgnp0p675v0c_cworst_setup"
		set scenarios(dynamic) ""
		set scenarios(leakage) ""
	}
	set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
	
} elseif { [info exists STAGE] && $STAGE == "place"} {
	set scenarios(setup) "func_ssgnp0p675v0c_cworst_setup"
	set scenarios(hold) "func_ffgnp0p825v125c_cbest_hold"
	set scenarios(dynamic) "func_ffgnp0p825v125c_cbest_hold"
	set scenarios(leakage) "func_ffgnp0p825v125c_cbest_hold"
}
set AC_LIMIT_SCENARIOS "func_ffgnp0p825v125c_cbest_hold"

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
set DFM_REDUNDANT_VIA "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/APR/cdns/1.1.2A/PRTF_Innovus_5nm_014_Cad_V11_2a/PR_tech/Cadence/script/PRTF_Innovus_N5_DFM_via_swap_reference_command.11_2a.tcl"
set METAL_FILL_RUNSET ""
set ICT_EM_MODELS "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK//EM/cdns/1.1.3A/cln5_1p17m+ut-alrdl_1x1xb1xe1ya1yb5y2yy2yx2r_shdmim.ictem"
set TECH_FILE ""
set TECH_LEF "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/APR/cdns/1.1.2A/PRTF_Innovus_5nm_014_Cad_V11_2a/PR_tech/Cadence/LefHeader/Standard/VHV/PRTF_Innovus_N5_17M_1X1Xb1Xe1Ya1Yb5Y2Yy2Yx2R_UTRDL_M1P34_M2P35_M3P42_M4P42_M5P76_M6P76_M7P76_M8P76_M9P76_M10P76_M11P76_H210_SHDMIM.11_2a.tlef"

set LEF_FILE_LIST "$TECH_LEF \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/lef/5.8/ts05nxqllogl06hdh051f.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/lef/5.8/ts05nxqmlogl06hdh051f.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/lef/5.8/ts05nxqslogl06hdh051f.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/lef/5.8/ts05nxqvlogl06hdh051f.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/lef/5.8/ts05nxqwlogl06hdh051f.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/lef/5.8/ts05nxqllogl06hdl051f.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/lef/5.8/ts05nxqmlogl06hdl051f.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/lef/5.8/ts05nxqslogl06hdl051f.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/lef/5.8/ts05nxqvlogl06hdl051f.lef \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/lef/5.8/ts05nxqwlogl06hdl051f.lef \
\
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.plef \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.plef \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.plef \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.plef \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.plef \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0.plef \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1_bottom_abut.plef \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1.plef \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1_side_abut.plef \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1_top_abut.plef \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0.plef \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1_bottom_abut.plef	\
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1.plef \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1_side_abut.plef \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1_top_abut.plef \
"


set LEAKAGE_CONFIG_FILE " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/leakage_data/ts05nxqllogl06hdh051f_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/leakage_data/ts05nxqmlogl06hdh051f_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/leakage_data/ts05nxqslogl06hdh051f_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/leakage_data/ts05nxqvlogl06hdh051f_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/leakage_data/ts05nxqwlogl06hdh051f_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/leakage_data/ts05nxqllogl06hdl051f_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/leakage_data/ts05nxqmlogl06hdl051f_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/leakage_data/ts05nxqslogl06hdl051f_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/leakage_data/ts05nxqvlogl06hdl051f_leakage_config.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/leakage_data/ts05nxqwlogl06hdl051f_leakage_config.txt \
"


set LEAKAGE_LEF_SIDE_FILES " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/leakage_data/ts05nxqllogl06hdh051f_celledge_sidefile \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/leakage_data/ts05nxqmlogl06hdh051f_celledge_sidefile \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/leakage_data/ts05nxqslogl06hdh051f_celledge_sidefile \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/leakage_data/ts05nxqvlogl06hdh051f_celledge_sidefile \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/leakage_data/ts05nxqwlogl06hdh051f_celledge_sidefile \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/leakage_data/ts05nxqllogl06hdl051f_celledge_sidefile \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/leakage_data/ts05nxqmlogl06hdl051f_celledge_sidefile \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/leakage_data/ts05nxqslogl06hdl051f_celledge_sidefile \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/leakage_data/ts05nxqvlogl06hdl051f_celledge_sidefile \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/leakage_data/ts05nxqwlogl06hdl051f_celledge_sidefile \
"

set LEAKAGE_LIB_SIDE_FILES " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/liberty/leakage_table/ts05nxqllogl06hdh051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/liberty/leakage_table/ts05nxqmlogl06hdh051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/liberty/leakage_table/ts05nxqslogl06hdh051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/liberty/leakage_table/ts05nxqvlogl06hdh051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/liberty/leakage_table/ts05nxqwlogl06hdh051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/liberty/leakage_table/ts05nxqllogl06hdl051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/liberty/leakage_table/ts05nxqmlogl06hdl051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/liberty/leakage_table/ts05nxqslogl06hdl051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/liberty/leakage_table/ts05nxqvlogl06hdl051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/liberty/leakage_table/ts05nxqwlogl06hdl051f_ffgnp0p825v125c_cbccbt_leakinfo.txt \
"

set POWER_GRID_LIBRARIES " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/pgv/techonly.cl \
"

set GDS_FILE_LIST ""
set OAS_FILE_LIST ""

set CTL_FILE_LIST " \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.ctl \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.ctl \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.ctl \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.ctl \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.ctl \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1.ctl \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1.ctl \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0.ctl \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0.ctl \
"

#################################################################################################################################################################################################
###	RC view
#################################################################################################################################################################################################
set rc_corner(gpd_file) "$GPD_DIR/out/gpd/${DESIGN_NAME}.${STAGE}.HIER.gpd"

set rc_corner(cworst) /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/cworst/Tech/cworst_CCworst_T/qrcTechFile
set rc_corner(cworst,nxtgrd) ""
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

set rc_corner(rcworst) /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/rcworst/Tech/rcworst_CCworst_T/qrcTechFile
set rc_corner(rcworst,nxtgrd) ""
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

set rc_corner(cbest) /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/cbest/Tech/cbest_CCbest_T/qrcTechFile
set rc_corner(cbest,nxtgrd) ""
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

set rc_corner(rcbest) /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK/Extraction/cdns/1.1.3a/rcbest/Tech/rcbest_CCbest_T/qrcTechFile
set rc_corner(rcbest,nxtgrd) ""
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
set PVT_CORNER ssgnp0p675v125c
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdh051f_ssgnp0p675v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdh051f_ssgnp0p675v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdh051f_ssgnp0p675v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdh051f_ssgnp0p675v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdh051f_ssgnp0p675v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdl051f_ssgnp0p675v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdl051f_ssgnp0p675v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdl051f_ssgnp0p675v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdl051f_ssgnp0p675v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdl051f_ssgnp0p675v125c.lib.gz \
\
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/ssgnp_ccwt0p675v125c/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0/ssgnp_ccwt0p675v125c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0/ssgnp_ccwt0p675v125c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/socv/ts05nxqllogl06hdh051f_ssgnp0p675v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/socv/ts05nxqmlogl06hdh051f_ssgnp0p675v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/socv/ts05nxqslogl06hdh051f_ssgnp0p675v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/socv/ts05nxqvlogl06hdh051f_ssgnp0p675v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/socv/ts05nxqwlogl06hdh051f_ssgnp0p675v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/socv/ts05nxqllogl06hdl051f_ssgnp0p675v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/socv/ts05nxqmlogl06hdl051f_ssgnp0p675v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/socv/ts05nxqslogl06hdl051f_ssgnp0p675v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/socv/ts05nxqvlogl06hdl051f_ssgnp0p675v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/socv/ts05nxqwlogl06hdl051f_ssgnp0p675v125c_sp.socv \
"
set pvt_corner($PVT_CORNER,pt_pocv) ""
set pvt_corner($PVT_CORNER,pt_ocv) ""

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ssgnp0p675v0c
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdh051f_ssgnp0p675v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdh051f_ssgnp0p675v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdh051f_ssgnp0p675v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdh051f_ssgnp0p675v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdh051f_ssgnp0p675v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdl051f_ssgnp0p675v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdl051f_ssgnp0p675v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdl051f_ssgnp0p675v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdl051f_ssgnp0p675v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdl051f_ssgnp0p675v0c.lib.gz \
\
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/ssgnp_ccwt0p675v125c/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/ssgnp_ccwt0p675v0c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/ssgnp_ccwt0p675v0c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0/ssgnp_ccwt0p675v0c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0/ssgnp_ccwt0p675v0c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/socv/ts05nxqllogl06hdh051f_ssgnp0p675v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/socv/ts05nxqmlogl06hdh051f_ssgnp0p675v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/socv/ts05nxqslogl06hdh051f_ssgnp0p675v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/socv/ts05nxqvlogl06hdh051f_ssgnp0p675v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/socv/ts05nxqwlogl06hdh051f_ssgnp0p675v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/socv/ts05nxqllogl06hdl051f_ssgnp0p675v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/socv/ts05nxqmlogl06hdl051f_ssgnp0p675v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/socv/ts05nxqslogl06hdl051f_ssgnp0p675v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/socv/ts05nxqvlogl06hdl051f_ssgnp0p675v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/socv/ts05nxqwlogl06hdl051f_ssgnp0p675v0c_sp.socv \
"
set pvt_corner($PVT_CORNER,pt_pocv) ""
set pvt_corner($PVT_CORNER,pt_ocv) ""


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ffgnp0p825v125c
set pvt_corner($PVT_CORNER,temperature) "125"
set pvt_corner($PVT_CORNER,timing) " \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdh051f_ffgnp0p825v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdh051f_ffgnp0p825v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdh051f_ffgnp0p825v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdh051f_ffgnp0p825v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdh051f_ffgnp0p825v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdl051f_ffgnp0p825v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdl051f_ffgnp0p825v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdl051f_ffgnp0p825v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdl051f_ffgnp0p825v125c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdl051f_ffgnp0p825v125c.lib.gz \
\
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/ssgnp_ccwt0p675v125c/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v125c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v125c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/ffgnp_ccbt0p825v125c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/ffgnp_ccbt0p825v125c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0/ffgnp_ccbt0p825v125c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0/ffgnp_ccbt0p825v125c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/socv/ts05nxqllogl06hdh051f_ffgnp0p825v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/socv/ts05nxqmlogl06hdh051f_ffgnp0p825v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/socv/ts05nxqslogl06hdh051f_ffgnp0p825v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/socv/ts05nxqvlogl06hdh051f_ffgnp0p825v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/socv/ts05nxqwlogl06hdh051f_ffgnp0p825v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/socv/ts05nxqllogl06hdl051f_ffgnp0p825v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/socv/ts05nxqmlogl06hdl051f_ffgnp0p825v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/socv/ts05nxqslogl06hdl051f_ffgnp0p825v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/socv/ts05nxqvlogl06hdl051f_ffgnp0p825v125c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/socv/ts05nxqwlogl06hdl051f_ffgnp0p825v125c_sp.socv \
"
set pvt_corner($PVT_CORNER,pt_pocv) ""
set pvt_corner($PVT_CORNER,pt_ocv) ""


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER ffgnp0p825v0c
set pvt_corner($PVT_CORNER,temperature) "0"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdh051f_ffgnp0p825v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdh051f_ffgnp0p825v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdh051f_ffgnp0p825v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdh051f_ffgnp0p825v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdh051f_ffgnp0p825v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdl051f_ffgnp0p825v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdl051f_ffgnp0p825v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdl051f_ffgnp0p825v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdl051f_ffgnp0p825v0c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdl051f_ffgnp0p825v0c.lib.gz \
\
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1/ssgnp_ccwt0p675v125c/sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/tmp_integrator/BDCM_Copy_to_N5/compout/views/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1/ssgnp_ccwt0p675v125c/saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v0c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/ffgnp_ccbt0p825v0c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/ffgnp_ccbt0p825v0c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/ffgnp_ccbt0p825v0c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0/ffgnp_ccbt0p825v0c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0/ffgnp_ccbt0p825v0c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/socv/ts05nxqllogl06hdh051f_ffgnp0p825v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/socv/ts05nxqmlogl06hdh051f_ffgnp0p825v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/socv/ts05nxqslogl06hdh051f_ffgnp0p825v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/socv/ts05nxqvlogl06hdh051f_ffgnp0p825v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/socv/ts05nxqwlogl06hdh051f_ffgnp0p825v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/socv/ts05nxqllogl06hdl051f_ffgnp0p825v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/socv/ts05nxqmlogl06hdl051f_ffgnp0p825v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/socv/ts05nxqslogl06hdl051f_ffgnp0p825v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/socv/ts05nxqvlogl06hdl051f_ffgnp0p825v0c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/socv/ts05nxqwlogl06hdl051f_ffgnp0p825v0c_sp.socv \
"
set pvt_corner($PVT_CORNER,pt_pocv) ""
set pvt_corner($PVT_CORNER,pt_ocv) ""

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER tt0p75v85c
set pvt_corner($PVT_CORNER,temperature) "85"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdh051f_tt0p75v85c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdh051f_tt0p75v85c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdh051f_tt0p75v85c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdh051f_tt0p75v85c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdh051f_tt0p75v85c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdl051f_tt0p75v85c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdl051f_tt0p75v85c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdl051f_tt0p75v85c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdl051f_tt0p75v85c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdl051f_tt0p75v85c.lib.gz \
\
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/tt0p75v85c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/tt0p75v85c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/tt0p75v85c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/tt0p75v25c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/tt0p75v25c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0/tt0p75v25c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0/tt0p75v25c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/socv/ts05nxqllogl06hdh051f_tt0p75v85c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/socv/ts05nxqmlogl06hdh051f_tt0p75v85c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/socv/ts05nxqslogl06hdh051f_tt0p75v85c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/socv/ts05nxqvlogl06hdh051f_tt0p75v85c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/socv/ts05nxqwlogl06hdh051f_tt0p75v85c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/socv/ts05nxqllogl06hdl051f_tt0p75v85c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/socv/ts05nxqmlogl06hdl051f_tt0p75v85c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/socv/ts05nxqslogl06hdl051f_tt0p75v85c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/socv/ts05nxqvlogl06hdl051f_tt0p75v85c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/socv/ts05nxqwlogl06hdl051f_tt0p75v85c_sp.socv \
"
set pvt_corner($PVT_CORNER,pt_pocv) ""
set pvt_corner($PVT_CORNER,pt_ocv) ""

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER tt0p75v25c
set pvt_corner($PVT_CORNER,temperature) "25"
set pvt_corner($PVT_CORNER,timing) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdh051f_tt0p75v25c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdh051f_tt0p75v25c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdh051f_tt0p75v25c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdh051f_tt0p75v25c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdh051f_tt0p75v25c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/liberty/ccs_lvf/ts05nxqllogl06hdl051f_tt0p75v25c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/liberty/ccs_lvf/ts05nxqmlogl06hdl051f_tt0p75v25c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/liberty/ccs_lvf/ts05nxqslogl06hdl051f_tt0p75v25c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/liberty/ccs_lvf/ts05nxqvlogl06hdl051f_tt0p75v25c.lib.gz \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/liberty/ccs_lvf/ts05nxqwlogl06hdl051f_tt0p75v25c.lib.gz \
\
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00/tt0p75v25c/sadrls0g4l2p128x136m1b4w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00/tt0p75v25c/sadrls0g4l2p160x132m2b2w0c1p0d0l1rm3sdrw00.lib \
/project/nxt007/nextBE_drops/nextinside_20201006_11/design/hard_ip/memories/gmu/src/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh/tt0p75v25c/sassls0g4l1p3136x156m4b4w1c1p0d0l1rm3sdrw00zh.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p320x64m2b4w1c0p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/CBU_Mems_21ww12e/V00/compout/views/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1/tt0p75v25c/sacrls0g4u2p320x128m2b4w1c1p0d0r1rm4rw10zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1/tt0p75v25c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/inext_cbu/V00_w_ecc_wo_bwen/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1/tt0p75v25c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg1.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0/tt0p75v25c/sacrls0g4l2p320x138m2b4w0c1p0d0r1rm4rw00zh1h0ms0mg0.lib \
/bespace/users/hilleln/memory_compiler/snps/side_runs/ME_gating/compout/views/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0/tt0p75v25c/sacrls0g4l2p320x72m2b4w0c0p0d0r1rm4rw00zh1h0ms0mg0.lib \
"
set pvt_corner($PVT_CORNER,ocv) "\
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvt/latest/socv/ts05nxqllogl06hdh051f_tt0p75v25c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/lvtll/latest/socv/ts05nxqmlogl06hdh051f_tt0p75v25c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/svt/latest/socv/ts05nxqslogl06hdh051f_tt0p75v25c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvt/latest/socv/ts05nxqvlogl06hdh051f_tt0p75v25c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdh/ulvtll/latest/socv/ts05nxqwlogl06hdh051f_tt0p75v25c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvt/latest/socv/ts05nxqllogl06hdl051f_tt0p75v25c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/lvtll/latest/socv/ts05nxqmlogl06hdl051f_tt0p75v25c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/svt/latest/socv/ts05nxqslogl06hdl051f_tt0p75v25c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvt/latest/socv/ts05nxqvlogl06hdl051f_tt0p75v25c_sp.socv \
/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/SNPS/DesignWare_logic_libs/tsmc05nglq/06hd/hdl/ulvtll/latest/socv/ts05nxqwlogl06hdl051f_tt0p75v25c_sp.socv \
"
set pvt_corner($PVT_CORNER,pt_pocv) ""
set pvt_corner($PVT_CORNER,pt_ocv) ""


#################################################################################################################################################################################################
###	design setting 
#################################################################################################################################################################################################
set DEFAULT_SITE TS05_DST
if {![info exists MAX_ROUTING_LAYER]} {set MAX_ROUTING_LAYER 16}
if {![info exists MIN_ROUTING_LAYER]} {set MIN_ROUTING_LAYER 2 }
# TODO: Add supply voltage per net
set PWR_NET     [list VDD]
set GND_NET     [list VSS]
set PWR_PINS    [list VDD VBP VDDF]
set GND_PINS    [list VSS VBN]

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


set VT_GROUPS(SVT)    *SVT06*
set VT_GROUPS(LVT)    *LVT06*
set VT_GROUPS(ULVT)   *ULT06*
set VT_GROUPS(LVTLL)  *LVTLL06*
set VT_GROUPS(ULVTLL) *ULTLL06*


set DONT_SCAN_FF " \
*i_sync* \
"
set DONT_TOUCH_INST "*DONT_TOUCH* *i_spare*" ; # REMOVED spare_i from dont touch
set SIZE_ONLY_INST "*SIZE_ONLY*"

set DONT_USE_CELLS " \
*AOI2222*1 \
*FSDP*M8* \
*ECO* \
*AOI2222_*_1 \
*_INV_S_1\
*AO2222*1 \
"

set DO_USE_CELLS " \
HDBLVT06_BUF_S* \
HDBLVT06_INV_S* \
HDBLVT06_MUX2_CK* \
HDBLVT06_CKGTPLT* \
"

#################################################################################################################################################################################################
###	place setting 
#################################################################################################################################################################################################
set IOBUFFER_CELL "HDBSVT06_BUF_4"
set USEABLE_IOBUFFER_CELL {HDBSVT06_BUF*_4 HDBSVT06_BUF*_5 HDBSVT06_BUF*_6  HDBSVT06_BUF*_8 HDBSVT06_BUF*_10 HDBSVT06_BUF*_12    }
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

set ENDCAPS(TOP_EDGE) 			{HDBSVT06_CAPB1}
set ENDCAPS(BOTTOM_EDGE) 		{HDBSVT06_CAPB1}
set ENDCAPS(LEFT_EDGE) 			HDBSVT06_CAPR14
set ENDCAPS(RIGHT_EDGE) 		HDBSVT06_CAPL14
set ENDCAPS(RIGHT_TOP_CORNER) 		HDBSVT06_CAPBLC14
set ENDCAPS(RIGHT_BOTTOM_CORNER) 	HDBSVT06_CAPBLC14
set ENDCAPS(LEFT_TOP_CORNER) 		HDBSVT06_CAPBRC14
set ENDCAPS(LEFT_BOTTOM_CORNER) 	HDBSVT06_CAPBRC14
set ENDCAPS(LEFT_TOP_EDGE) 		HDBSVT06_CAPBRINC14
set ENDCAPS(RIGHT_TOP_EDGE) 		HDBSVT06_CAPBLINC14
set ENDCAPS(LEFT_BOTTOM_EDGE) 		HDBSVT06_CAPBRINC14
set ENDCAPS(RIGHT_BOTTOM_EDGE) 		HDBSVT06_CAPBLINC14
set ENDCAPS(LEFT_TOP_EDGE_NEIGHBOR) 	HDBSVT06_CAPBRINCGAP3	
set ENDCAPS(RIGHT_TOP_EDGE_NEIGHBOR) 	HDBSVT06_CAPBLINCGAP3	
set ENDCAPS(LEFT_BOTTOM_EDGE_NEIGHBOR)  HDBSVT06_CAPBRINCGAP3		
set ENDCAPS(RIGHT_BOTTOM_EDGE_NEIGHBOR) HDBSVT06_CAPBLINCGAP3		


set TAPCELL "{HDBSVT06_TAPDS_30 rule 15.8 boundary_layer LUP_SRM boundary_rule 15.8} {HDBSVT06_TAPDS_39 rule 22.5}"
set SWAP_WELL_TAPS { TAPCELLBWP240H8P57PDSVT TAPCELLL1R2BWP240H8P57PDSVT TAPCELLL2R1BWP240H8P57PDSVT TAPCELLL1R1BWP240H8P57PDSVT }
set TIEHCELL "HDBSVT06_TIE1_V1_1"
set TIELCELL "HDBSVT06_TIE0_V1_1"
set ANTENNA_CELL_NAME "HDBSVT06_TIEDIN_CBQV1_4 HDBSVT06_TIEDIN_CB3QV1_4 HDBSVT06_TIEDIN_CAQV1_4 HDBSVT06_TIEDIN_CA3QV1_4 HDBSVT06_TIEDIN_CAQECO_6 HDBSVT06_TIEDIN_CB3QV1_4 HDBSVT06_TIEDIP_CAQY14_1"

set PRE_PLACE_DECAP "HDBLVT06_DCAP_16"
set PRE_PLACE_ECO_DCAP "HDBLVT06_DCAP_CAQY2ECO_16"

set DCAP_CELLS_LIST "HDBSVT06_DCAP_V4_64 HDBSVT06_DCAP_V4_32 HDBSVT06_DCAP_V4_16 HDBSVT06_DCAP_V4_8 HDBSVT06_DCAP_V4_4"
set FILLER64_CELLS_LIST "HDBLVT06_FILL64 HDBLVT06_FILL64 HDBSVT06_FILL64 HDBSVT06_FILL64 HDBULT06_FILL64 HDBULT06_FILL64"
set FILLER32_CELLS_LIST "HDBLVT06_FILL32 HDBLVT06_FILL32 HDBSVT06_FILL32 HDBSVT06_FILL32 HDBULT06_FILL32 HDBULT06_FILL32"
set FILLER16_CELLS_LIST "HDBLVT06_FILL16 HDBLVT06_FILL16 HDBSVT06_FILL16 HDBSVT06_FILL16 HDBULT06_FILL16 HDBULT06_FILL16"
set FILLER12_CELLS_LIST "HDBLVT06_FILL12 HDBLVT06_FILL12 HDBSVT06_FILL12 HDBSVT06_FILL12 HDBULT06_FILL12 HDBULT06_FILL12"
set FILLER8_CELLS_LIST  "HDBLVT06_FILL8 HDBLVT06_FILL8 HDBSVT06_FILL8 HDBSVT06_FILL8 HDBULT06_FILL8 HDBULT06_FILL8"
set FILLER4_CELLS_LIST  "HDBLVT06_FILL4 HDBLVT06_FILL4 HDBSVT06_FILL4 HDBSVT06_FILL4 HDBULT06_FILL4 HDBULT06_FILL4"
set FILLER3_CELLS_LIST  "HDBLVT06_FILL3 HDBLVT06_FILL3 HDBSVT06_FILL3 HDBSVT06_FILL3 HDBULT06_FILL3 HDBULT06_FILL3"
set FILLER2_CELLS_LIST  "HDBLVT06_FILL2 HDBLVT06_FILL2 HDBSVT06_FILL2 HDBSVT06_FILL2 HDBULT06_FILL2 HDBULT06_FILL2"
set FILLER1_CELLS_LIST  "HDBLVT06_FILL1 HDBLVT06_FILL1 HDBSVT06_FILL1 HDBSVT06_FILL1 HDBULT06_FILL1 HDBULT06_FILL1"

set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"


set ADD_FILLERS_SWAP_CELL {}

###################################################################################################################################################################################################
###	CTS setting 
###################################################################################################################################################################################################


set CTS_BUFFER_CELLS          {HDBLVT06_BUF_S_2 HDBLVT06_BUF_SM_3}
set CTS_INVERTER_CELLS_TOP    { \
        HDBLVT06_INV_CAQSDCY4_14 \
        HDBLVT06_INV_CAQSY4R_14 \
        HDBLVT06_INV_CAQSDCY4_16 \
        HDBLVT06_INV_CAQSY4R_16 \
        HDBLVT06_INV_CAQSY4_16 \
        HDBLVT06_INV_CAQSDCY4_20 \
        HDBLVT06_INV_CAQSY2R_20 \
        HDBLVT06_INV_CAQSY4_20 \
        }
set CTS_INVERTER_CELLS_TRUNK  {\
        HDBLVT06_INV_CA3QSDCY2_10 \
        HDBLVT06_INV_CA3QSDCY2_8 \
        HDBLVT06_INV_CAQSDCY2_10 \
        HDBLVT06_INV_CAQSDCY2_8 \
        HDBLVT06_INV_CAQSDCY4_12 \
        HDBLVT06_INV_CB3QSDCY2_10 \
        HDBLVT06_INV_CB3QSDCY2_8 \
        HDBLVT06_INV_CBQSDCY2_10 \
        HDBLVT06_INV_CBQSDCY2_8 \
        HDBLVT06_INV_CAQSDCY4_14 \
        HDBLVT06_INV_CAQSY4R_14 \
        }
set CTS_INVERTER_CELLS_LEAF   { \
        HDBLVT06_INV_S_2 \
        HDBLVT06_INV_S_4 \
        HDBLVT06_INV_CA3QSDCY2_10 \
        HDBLVT06_INV_CA3QSDCY2_8 \
        HDBLVT06_INV_CA3QSY2R_6 \
        HDBLVT06_INV_CAQSDCY2_10 \
        HDBLVT06_INV_CAQSDCY2_8 \
        HDBLVT06_INV_CAQSDCY2_6 \
        HDBLVT06_INV_CAQSDCY4_12 \
        HDBLVT06_INV_CAQSY2R_6 \
        HDBLVT06_INV_CB3QSDCY2_10 \
        HDBLVT06_INV_CB3QSDCY2_8 \
        HDBLVT06_INV_CB3QSCY2_6 \
        HDBLVT06_INV_CBQSDCY2_10 \
        HDBLVT06_INV_CBQSDCY2_8 \
        }

set CTS_LOGIC_CELLS           {HDBLVT06_OR2_2 HDBLVT06_OR2_4 HDBLVT06_AN2_2 HDBLVT06_AN2_4 HDBLVT06_NR2_2 HDBLVT06_NR2_4 HDBLVT06_ND2_2 HDBLVT06_ND2_4 HDBLVT06_MUX2_CK_1 HDBLVT06_MUX2_CK_2 }
set CTS_CLOCK_GATING_CELLS    {HDBLVT06_CKGTPLTN_V7_1 HDBLVT06_CKGTPLTN_V7_2 HDBLVT06_CKGTPLTN_V7_4 HDBLVT06_CKGTPLT_CA3QV7_1 HDBLVT06_CKGTPLT_CA3QV7_2 HDBLVT06_CKGTPLT_CA3QV7_4 HDBLVT06_CKGTPLT_CAQV7FC_1 HDBLVT06_CKGTPLT_CAQV7FC_2 HDBLVT06_CKGTPLT_CAQV7FC_3 HDBLVT06_CKGTPLT_CAQV7FC_4 HDBLVT06_CKGTPLT_CAQV7FC_5 HDBLVT06_CKGTPLT_CAQV7FC_6 HDBLVT06_CKGTPLT_CAQV7L_10 HDBLVT06_CKGTPLT_CAQV7L_12 HDBLVT06_CKGTPLT_CAQV7L_7 HDBLVT06_CKGTPLT_CAQV7L_8   HDBLVT06_CKGTPLT_CAQV7_1 HDBLVT06_CKGTPLT_CAQV7_10 HDBLVT06_CKGTPLT_CAQV7_11 HDBLVT06_CKGTPLT_CAQV7_12 HDBLVT06_CKGTPLT_CAQV7_2 HDBLVT06_CKGTPLT_CAQV7_3 HDBLVT06_CKGTPLT_CAQV7_4 HDBLVT06_CKGTPLT_CAQV7_5 HDBLVT06_CKGTPLT_CAQV7_6 HDBLVT06_CKGTPLT_CAQV7_7 HDBLVT06_CKGTPLT_CAQV7_8 HDBLVT06_CKGTPLT_CAQV7_9 HDBLVT06_CKGTPLT_CAQV8_1 HDBLVT06_CKGTPLT_CAQV8_2 HDBLVT06_CKGTPLT_CAQV8_3 HDBLVT06_CKGTPLT_CAQV8_4 HDBLVT06_CKGTPLT_CAQV8_6 HDBLVT06_CKGTPLT_CAQV8_8 HDBLVT06_CKGTPLT_CB3QV7_1 HDBLVT06_CKGTPLT_CB3QV7_2 HDBLVT06_CKGTPLT_CB3QV7_4 HDBLVT06_CKGTPLT_CBQV7_1 HDBLVT06_CKGTPLT_CBQV7_2 HDBLVT06_CKGTPLT_CBQV7_4 HDBLVT06_CKGTPLT_CAQV5_1 HDBLVT06_CKGTPLT_CAQV5_12 HDBLVT06_CKGTPLT_CAQV5_2 HDBLVT06_CKGTPLT_CAQV5_3 HDBLVT06_CKGTPLT_CAQV5_4 HDBLVT06_CKGTPLT_CAQV5_6 HDBLVT06_CKGTPLT_CAQV5_8}
set CTS_CELLS_HALO [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]


set HOLD_FIX_CELLS_LIST [list \
*DEL* \
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




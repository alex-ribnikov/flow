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

if {![info exists DESIGN_NAME]}  {set DESIGN_NAME [lindex [split [pwd] "/"] end-2]}
if {![info exists SPEF_DIR]}     {set SPEF_DIR ""}
if {![info exists GPD_DIR]}      {set GPD_DIR ""}
if {![info exists INC_INIT]}     {set INC_INIT "false"}

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
if {![info exists INC_INIT] || $INC_INIT == "true" } {
	#set scenarios(setup) "merge_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup merge_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup merge_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup merge_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup merge_no_od_minT_LIBRARY_SS_rc_bc_cc_bc_setup"
	#set scenarios(hold)  "merge_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold merge_no_od_125_LIBRARY_FF_rc_bc_cc_bc_hold merge_no_od_125_LIBRARY_FF_rc_wc_cc_wc_T_hold merge_no_od_minT_LIBRARY_FF_c_bc_cc_bc_hold merge_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold merge_no_od_minT_LIBRARY_FF_rc_wc_cc_wc_T_hold merge_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold"
	set scenarios(setup) "merge_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup merge_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup  "
	set scenarios(hold)  "merge_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold merge_no_od_minT_LIBRARY_FF_c_bc_cc_bc_hold merge_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold "
	set scenarios(dynamic) ""
	set scenarios(leakage) "merge_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"

	set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
	
	set AC_LIMIT_SCENARIOS "merge_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
	set DEFAULT_SETUP_VIEW merge_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup
	set DEFAULT_CCOPT_VIEW merge_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup
	set DEFAULT_HOLD_VIEW  merge_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold
	
	set RHSC_STATIC  merge_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold
	set RHSC_DYNAMIC merge_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup
	set RHSC_SIGEM   merge_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup


	if {![info exists STAGE] || $STAGE == "syn" || $STAGE == "syn_reg" || $STAGE == "FM" } {
	        set scenarios(setup) "merge_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
	    if { $FE_MODE } {
	        set scenarios(hold) ""
	        set scenarios(dynamic) ""
	        set scenarios(leakage) ""
	        set DEFAULT_SETUP_VIEW merge_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup
	    } else {
	        set scenarios(hold)    "merge_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
	        set scenarios(dynamic) ""
	        set scenarios(leakage) "merge_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
	    }
	    set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
    
	} elseif { [info exists STAGE] && $STAGE == "eco"} {
    		set DEFAULT_SETUP_VIEW merge_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup
    		set DEFAULT_CCOPT_VIEW merge_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup
    		set scenarios(setup) "merge_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
    		set scenarios(hold)  "merge_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
    		set scenarios(dynamic) ""
    		set scenarios(leakage) "merge_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
	}

} else {
	#set scenarios(setup) "func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_rc_bc_cc_bc_setup"
	#set scenarios(hold)  "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold func_no_od_125_LIBRARY_FF_rc_bc_cc_bc_hold func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_T_hold func_no_od_minT_LIBRARY_FF_c_bc_cc_bc_hold func_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold func_no_od_minT_LIBRARY_FF_rc_wc_cc_wc_T_hold func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_hold"
	set scenarios(setup) "func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup  "
	set scenarios(hold)  "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold func_no_od_minT_LIBRARY_FF_c_bc_cc_bc_hold func_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold "
	set scenarios(dynamic) ""
	set scenarios(leakage) "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"

	set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
	
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
	        set scenarios(hold)    "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
	        set scenarios(dynamic) ""
	        set scenarios(leakage) "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"
	    }
	    set all_scenarios [lsort -uniq [concat $scenarios(setup) $scenarios(hold) $scenarios(dynamic) $scenarios(leakage)]]
    
	} elseif { [info exists STAGE] && $STAGE == "eco"} {
    		set DEFAULT_SETUP_VIEW func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup
    		set DEFAULT_CCOPT_VIEW func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup
    		set scenarios(setup) "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
    		set scenarios(hold)  "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
    		set scenarios(dynamic) ""
    		set scenarios(leakage) "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup"
	}
}

#################################################################################################################################################################################################
###	setting per project 
#################################################################################################################################################################################################

puts "scenarios(setup) $scenarios(setup)"
puts "scenarios(hold) $scenarios(hold)"
puts "scenarios(dynamic) $scenarios(dynamic)"
puts "scenarios(leakage) $scenarios(leakage)"


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
    set sdc_files(merge) ""
    if {[info exists sh_launch_dir]} {
        if { [file exists ${sh_launch_dir}/../inter/${DESIGN_NAME}.pre.sdc]  }     { append sdc_files(merge) " ${sh_launch_dir}/../inter/${DESIGN_NAME}.pre.sdc "  }
        if { [file exists ${sh_launch_dir}/../inter/${DESIGN_NAME}.sdc]}           { append sdc_files(merge) " ${sh_launch_dir}/../inter/${DESIGN_NAME}.sdc "      }
        if { [file exists ${sh_launch_dir}/scripts/flow/DFT_merge.sdc]}            { append sdc_files(merge) " ${sh_launch_dir}/scripts/flow/DFT_merge.sdc "      }
        if { [file exists ${sh_launch_dir}/../inter/${DESIGN_NAME}.post.sdc] }     { append sdc_files(merge) " ${sh_launch_dir}/../inter/${DESIGN_NAME}.post.sdc " }                
    } else {
        if { [file exists ../inter/${DESIGN_NAME}.pre.sdc]  }  { append sdc_files(merge) " ../inter/${DESIGN_NAME}.pre.sdc "  }
        if { [file exists ../inter/${DESIGN_NAME}.sdc]}        { append sdc_files(merge) " ../inter/${DESIGN_NAME}.sdc "      }
        if { [file exists ./scripts/flow/DFT_merge.sdc]}       { append sdc_files(merge) " ./scripts/flow/DFT_merge.sdc "      }
        if { [file exists ../inter/${DESIGN_NAME}.post.sdc] }  {
            append sdc_files(merge) " ../inter/${DESIGN_NAME}.post.sdc " 
            set sdc_update_files(merge) " ../inter/${DESIGN_NAME}.post.sdc " 
        } else { 
            set sdc_update_files(merge) "" 
        }               
    }
    
    
    if { [regexp "func" $all_scenarios ] && $sdc_files(func) == "" }  { puts "-E- No func SDC file" ;  }
    if { [regexp "merge" $all_scenarios ] && $sdc_files(func) == "" } { puts "-E- No merge SDC file" ;  }
    
    
    set sdc_files(scan_shift) ""
    set sdc_files(scan_capture) ""
    set sdc_files(bist) ""
    
    
    
    
    
    
} elseif { [info exists SDC_LIST] } {
    if { [regexp "," $SDC_LIST] } { set sdc_list [split $SDC_LIST ","] } { set sdc_list [split $SDC_LIST " "] }
    foreach file $sdc_list {  
        if {![file exists $file] } { puts "-E- File $file is on sdc_list but not exists" ; exit } 
    }
    
    set sdc_files(func) [join $sdc_list " "]
    set sdc_files(merge) [join $sdc_list " "]
    if { [file exists ../inter/${DESIGN_NAME}.post.sdc] } {
        set sdc_update_files(func)  " ../inter/${DESIGN_NAME}.post.sdc " 
        set sdc_update_files(merge) " ../inter/${DESIGN_NAME}.post.sdc " 
    }
}

puts "-I- sdc files are: "
parray sdc_files

#################################################################################################################################################################################################
###    physical view
#################################################################################################################################################################################################
# add prboundary layer
set GDS_MAP_FILE      "/project/foundry/TSMC/N3/BRCM/PDK/20250715/Synopsys/gdsOutLayer.map"
set STREAM_LAYER_MAP_FILE /project/foundry/TSMC/N3/BRCM/PDK/20250715/StarRCXT/share/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_gds_lefdef_map
set TECHNOLOGY_LAYER_MAP  /project/foundry/TSMC/N3/BRCM/PDK/20250715/StarRCXT/share/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_lefdef_rcxt_map

if {![info exists ROUTE_DFM]} {set ROUTE_DFM true}
set DFM_REDUNDANT_VIA ""
set METAL_FILL_RUNSET ""

### 22/10/2024 Roy: TBD is this the right corner for IR/UVD/EM/ESD ?
set TECH_APACHE "/project/foundry/TSMC/N3/BRCM/PDK/20250715/Ansys_Apache/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R_rcworst_CCworst.tech"
set TECH_APACHE ""

set ICT_EM_MODELS ""
set TECH_FILE "/project/foundry/TSMC/N3/BRCM/PDK/20250715/Synopsys/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R_enterprise_MH143.tf"
set TECH_FILE "/project/foundry/TSMC/N3/BRCM/PDK/20241007/Synopsys/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R_enterprise_MH143.tf"
set FC_EXTRA_TECH_FILES " \
	./scripts/layout/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R_enterprise_MH143.extra_vias_for_iccii.tcl \
	./scripts/layout/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R_enterprise_MH143_ndr_active.tcl \
	/project/foundry/TSMC/N3/BRCM/PDK/20250715/Synopsys/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R_enterprise_MH143_ant.tcl \
"
set TECH_LEF " \
/project/foundry/TSMC/N3/BRCM/PDK/20250715/Cadence/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R_enterprise_MH143.lef \
/project/foundry/TSMC/N3/BRCM/PDK/20250715/Cadence/var_19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R_enterprise_MH143.lef \
"

set LEF_FILE_LIST "$TECH_LEF \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/lef/tsmc3ffe_sc05t0750v.lef \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/lef/tsmc3ffe_ck05t0750v.lef \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/lef/tsmc3ffe_ga05t0750v.lef \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/lef/tsmc3ffe_mb05t0750v.lef \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/lef/tsmc3ffe_top05t0750v.lef \
    \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/LEF/N3E_ICOVL_TYPE_A_M13/N3E_ICOVL_v0d9_1.lef \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/LEF/N3E_ICOVL_TYPE_F_M13/N3E_ICOVL_v0d9_1.lef \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/LEF/N3E_ICOVL_TYPE_B_M13/N3E_ICOVL_v0d9_1.lef \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/LEF/N3E_ICOVL_TYPE_G_M13/N3E_ICOVL_v0d9_1.lef \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/LEF/N3E_ICOVL_TYPE_C_M13/N3E_ICOVL_v0d9_1.lef \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/LEF/N3E_ICOVL_TYPE_H_M13/N3E_ICOVL_v0d9_1.lef \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/LEF/N3E_ICOVL_TYPE_D_M13/N3E_ICOVL_v0d9_1.lef \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/LEF/N3E_ICOVL_TYPE_I_M13/N3E_ICOVL_v0d9_1.lef \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/LEF/N3E_ICOVL_TYPE_E_M13/N3E_ICOVL_v0d9_1.lef \
    \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_DTCD_library_kit_general_v0d9_1_230327/LEF/N3E_DTCD_M13/N3E_DTCD_v0d9_1.lef \

"
set NDM_REFERENCE_LIBRARY " \
/project/foundry/TSMC/N3/BRCM/IP/STD/20250319/tsmc3ffe_ck05t0750v/ndm/tsmc3ffe_ck05t0750v.ndm  \
/project/foundry/TSMC/N3/BRCM/IP/STD/20250319/tsmc3ffe_lp05t0750v/ndm/tsmc3ffe_lp05t0750v.ndm  \
/project/foundry/TSMC/N3/BRCM/IP/STD/20250319/tsmc3ffe_misc/ndm/tsmc3ffe_misc.ndm              \
/project/foundry/TSMC/N3/BRCM/IP/STD/20250319/tsmc3ffe_ga05t0750v/ndm/tsmc3ffe_ga05t0750v.ndm  \
/project/foundry/TSMC/N3/BRCM/IP/STD/20250319/tsmc3ffe_lscore/ndm/tsmc3ffe_lscore.ndm          \
/project/foundry/TSMC/N3/BRCM/IP/STD/20250319/tsmc3ffe_sc05t0750v/ndm/tsmc3ffe_sc05t0750v.ndm  \
/project/foundry/TSMC/N3/BRCM/IP/STD/20250319/tsmc3ffe_hm05t0750v/ndm/tsmc3ffe_hm05t0750v.ndm  \
/project/foundry/TSMC/N3/BRCM/IP/STD/20250319/tsmc3ffe_mb05t0750v/ndm/tsmc3ffe_mb05t0750v.ndm  \
/project/foundry/TSMC/N3/BRCM/IP/STD/20250319/tsmc3ffe_top05t0750v/ndm/tsmc3ffe_top05t0750v.ndm \
/project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/ndm/UBUMP_2X2_PG.ndm \
/project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/ndm/UBUMP.ndm \
/project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/ndm/UBUMP_2X2_GPIO.ndm \
/project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/ndm/PROBEPAD_59X59.ndm \
/project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/ndm/tsmc3ffe_iopads.ndm \
"


set LEAKAGE_CONFIG_FILE ""

set LEAKAGE_LEF_SIDE_FILES ""

set LEAKAGE_LIB_SIDE_FILES ""

set POWER_GRID_LIBRARIES ""

set CELLNAME_MAP_FILES " \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/support/tsmc3ffe_ck05t0750v_cellname_map_file \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/support/tsmc3ffe_hm05t0750v_cellname_map_file \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/support/tsmc3ffe_ga05t0750v_cellname_map_file \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/support/tsmc3ffe_lp05t0750v_cellname_map_file \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/support/tsmc3ffe_mb05t0750v_cellname_map_file \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/support/tsmc3ffe_sc05t0750v_cellname_map_file \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/support/tsmc3ffe_lscore_cellname_map_file \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/support/tsmc3ffe_top05t0750v_cellname_map_file \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/support/tsmc3ffe_misc_cellname_map_file \
"

set STREAM_FILE_LIST " \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/oasis/tsmc3ffe_ck05t0750v.oas \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/oasis/tsmc3ffe_lp05t0750v.oas \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/oasis/tsmc3ffe_misc.oas \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/oasis/tsmc3ffe_ga05t0750v.oas \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/oasis/tsmc3ffe_lscore.oas \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/oasis/tsmc3ffe_sc05t0750v.oas \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/oasis/tsmc3ffe_hm05t0750v.oas \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/oasis/tsmc3ffe_mb05t0750v.oas \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/oasis/tsmc3ffe_top05t0750v.oas \
    \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_DTCD_library_kit_general_v0d9_1_230327/N3E_DTCD_ALL_phantom_general_20220327.oas \
    /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/N3E_ICOVL_ALL_phantom_general_20220327.oas \
    /project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/oasis/UBUMP_2X2_PG.oas \
    /project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/oasis/UBUMP.oas \
    /project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/oasis/UBUMP_2X2_GPIO.oas \
    /project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/oasis/PROBEPAD_59X59.oas \
    /project/foundry/TSMC/N3/BRCM/IP/BUMPS/20250212/oasis/tsmc3ffe_iopads.oas \
"

set APACHE_GDS_MODEL "\
/project/foundry/TSMC/N3/BRCM/IP/MEM/memories/20250203/memory/int/power/apache/physical/* \
"

set SCHEMATIC_FILE_LIST " \
    ./scripts/flow/empty_subckt.cdl \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/lvs_spice/tsmc3ffe_ck05t0750v.cdl \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/lvs_spice/tsmc3ffe_ga05t0750v.cdl \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/lvs_spice/tsmc3ffe_hm05t0750v.cdl \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/lvs_spice/tsmc3ffe_lp05t0750v.cdl \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/lvs_spice/tsmc3ffe_mb05t0750v.cdl \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/lvs_spice/tsmc3ffe_top05t0750v.cdl \
    /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/lvs_spice/tsmc3ffe_sc05t0750v.cdl \
"
set CTL_FILE_LIST ""

#################################################################################################################################################################################################
###    RC view
#################################################################################################################################################################################################
set rc_corner(gpd_file) "$GPD_DIR/out/gpd/${DESIGN_NAME}.${STAGE}.HIER.gpd"

## 22/10/2024 Roy TBD: missing currect metal stuck.
set rc_corner(c_wc_cc_wc_T)  "/project/foundry/TSMC/N3/TSMC/PDK/Extraction/cdns/1p19m_1xa1xb1xc1xd1ya1yb6y2yy2yx2r.1_1p1a/cworst/Tech/cworst_CCworst_T/qrcTechFile"
set rc_corner(c_wc_cc_wc_T,nxtgrd)  "/project/foundry/TSMC/N3/BRCM/PDK/20250715/StarRCXT/tech/V1.2p1a/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_cworst_CCworst_T.nxtgrd"
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
set rc_corner(c_wc_cc_wc_T,ccap_threshold) "{0.001 0.001}"     ; # { early late }
set rc_corner(c_wc_cc_wc_T,ccap_ratio)     "{0.01 0.01}"     ; # { early late }

set rc_corner(c_wc_cc_wc)  "/project/foundry/TSMC/N3/TSMC/PDK/Extraction/cdns/1p19m_1xa1xb1xc1xd1ya1yb6y2yy2yx2r.1_1p1a/cworst/Tech/cworst_CCworst/qrcTechFile"
set rc_corner(c_wc_cc_wc,nxtgrd)  "/project/foundry/TSMC/N3/BRCM/PDK/20250715/StarRCXT/tech/V1.2p1a/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_cworst_CCworst.nxtgrd"
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
set rc_corner(c_wc_cc_wc,ccap_threshold) "{0.001 0.001}"     ; # { early late }
set rc_corner(c_wc_cc_wc,ccap_ratio)     "{0.01 0.01}"     ; # { early late }

set rc_corner(rc_wc_cc_wc)  "/project/foundry/TSMC/N3/TSMC/PDK/Extraction/cdns/1p19m_1xa1xb1xc1xd1ya1yb6y2yy2yx2r.1_1p1a/rcworst/Tech/rcworst_CCworst/qrcTechFile"
set rc_corner(rc_wc_cc_wc,nxtgrd)  "/project/foundry/TSMC/N3/BRCM/PDK/20250715/StarRCXT/tech/V1.2p1a/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_rcworst_CCworst.nxtgrd"
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
set rc_corner(rc_wc_cc_wc,ccap_threshold) "{0.001 0.001}"     ; # { early late }
set rc_corner(rc_wc_cc_wc,ccap_ratio)     "{0.01 0.01}"     ; # { early late }

set rc_corner(rc_wc_cc_wc_T)  "/project/foundry/TSMC/N3/TSMC/PDK/Extraction/cdns/1p19m_1xa1xb1xc1xd1ya1yb6y2yy2yx2r.1_1p1a/rcworst/Tech/rcworst_CCworst_T/qrcTechFile"
set rc_corner(rc_wc_cc_wc_T,nxtgrd)  "/project/foundry/TSMC/N3/BRCM/PDK/20250715/StarRCXT/tech/V1.2p1a/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_rcworst_CCworst_T.nxtgrd"
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
set rc_corner(rc_wc_cc_wc_T,ccap_threshold) "{0.001 0.001}"     ; # { early late }
set rc_corner(rc_wc_cc_wc_T,ccap_ratio)     "{0.01 0.01}"     ; # { early late }

set rc_corner(c_bc_cc_bc)  "/project/foundry/TSMC/N3/TSMC/PDK/Extraction/cdns/1p19m_1xa1xb1xc1xd1ya1yb6y2yy2yx2r.1_1p1a/cbest/Tech/cbest_CCbest/qrcTechFile"
set rc_corner(c_bc_cc_bc,nxtgrd)  "/project/foundry/TSMC/N3/BRCM/PDK/20250715/StarRCXT/tech/V1.2p1a/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_cbest_CCbest.nxtgrd"
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
set rc_corner(c_bc_cc_bc,ccap_threshold) "{0.001 0.001}"     ; # { early late }
set rc_corner(c_bc_cc_bc,ccap_ratio)     "{0.01 0.01}"     ; # { early late }

set rc_corner(rc_bc_cc_bc)  "/project/foundry/TSMC/N3/TSMC/PDK/Extraction/cdns/1p19m_1xa1xb1xc1xd1ya1yb6y2yy2yx2r.1_1p1a/rcbest/Tech/rcbest_CCbest/qrcTechFile"
set rc_corner(rc_bc_cc_bc,nxtgrd)  "/project/foundry/TSMC/N3/BRCM/PDK/20250715/StarRCXT/tech/V1.2p1a/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_rcbest_CCbest.nxtgrd"
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
set rc_corner(rc_bc_cc_bc,ccap_threshold) "{0.001 0.001}"     ; # { early late }
set rc_corner(rc_bc_cc_bc,ccap_ratio)     "{0.01 0.01}"     ; # { early late }

set rc_corner(typical)  "/project/foundry/TSMC/N3/TSMC/PDK/Extraction/cdns/1p19m_1xa1xb1xc1xd1ya1yb6y2yy2yx2r.1_1p1a/typical/Tech/typical/qrcTechFile"
set rc_corner(typical,nxtgrd) "/project/foundry/TSMC/N3/BRCM/PDK/20250715/StarRCXT/tech/V1.2p1a/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_typical.nxtgrd"
set rc_corner(typical,rc_variation) 0.1
set rc_corner(typical,spef_25) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.typical_25.gz"
set rc_corner(typical,spef_85) "$SPEF_DIR/out/spef/${DESIGN_NAME}.${STAGE}.spef.typical_85.gz"


#################################################################################################################################################################################################
###    timing view
#################################################################################################################################################################################################
#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell" || $synopsys_program_name == "lc_shell"))} {
   set pvt_corner($PVT_CORNER,label) "pssg_s300_v0670_t125_xcwccwt"
   set pvt_corner($PVT_CORNER,op_code) "WCIND_WCT"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc3ffe_sc05t0750v_pssg_s300_v0670_t125_xcwccwt" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
       # 22/10/2024 Roy TBD: need to add memories files.
   set pvt_corner($PVT_CORNER,apl_file_list) "\
       /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_*/apache/SS0670125/* \
       /project/foundry/TSMC/N3/BRCM/IP/MEM/memories/20250203//memory/int/power/apache/apl/*/*ss* \
    "
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/db//tsmc3ffe_sc05t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/db//tsmc3ffe_ck05t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/db//tsmc3ffe_mb05t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/db//tsmc3ffe_ga05t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/db//tsmc3ffe_misc_pssg_s300_v0670_t125_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/db//tsmc3ffe_hm05t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/db//tsmc3ffe_lp05t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/db//tsmc3ffe_top05t0750v_pssg_s300_v0670_t125_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/db/tsmc3ffe_lscore_pssg_s300_v0670_t125_o0830_xcwccwt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/3FFE_pssg_s300_v0670_t125_spatial_tempus-socv.socv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/cln03.wire.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/cln03.wire.pocvm \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_ck05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_ga05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_hm05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_lp05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_lscore_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_mb05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_sc05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_top05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_misc_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_wildcards_primetime-lvf.locv_table \
      \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ck05t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ga05t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_hm05t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lp05t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_mb05t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_sc05t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_top05t0750v_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lscore_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_misc_pssg_s300_v0670_t125_primetime-lvf.pocv_coefficients \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/messages/messages.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/utils/utils.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ck05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ga05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_hm05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lp05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lscore.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_mb05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_misc.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_sc05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_top05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/pt_si_settings_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t125_primetime-lvf.global_signoff \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ck05t0750v_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ga05t0750v_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_hm05t0750v_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lp05t0750v_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lscore_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_mb05t0750v_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_misc_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_sc05t0750v_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_top05t0750v_pssg_s300_v0670_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/memory_derates.tcl \
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_SS
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell" || $synopsys_program_name == "lc_shell"))} {
   set pvt_corner($PVT_CORNER,label) "pssg_s300_v0670_t000_xcwccwt"
   set pvt_corner($PVT_CORNER,op_code) "WCIND_WCT"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc3ffe_sc05t0750v_pssg_s300_v0670_t000_xcwccwt" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/db/tsmc3ffe_sc05t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/db/tsmc3ffe_ck05t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/db/tsmc3ffe_ga05t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/db/tsmc3ffe_hm05t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/db/tsmc3ffe_lp05t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/db/tsmc3ffe_mb05t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/db/tsmc3ffe_misc_pssg_s300_v0670_t000_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/db/tsmc3ffe_top05t0750v_pssg_s300_v0670_t000_xcwccwt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/db/tsmc3ffe_lscore_pssg_s300_v0670_t000_o0830_xcwccwt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/3FFE_pssg_s300_v0670_t000_spatial_tempus-socv.socv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/cln03.wire.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
	/project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/cln03.wire.pocvm \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_ck05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_ga05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_hm05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_lp05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_lscore_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_mb05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_misc_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_sc05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_top05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_wildcards_primetime-lvf.locv_table \
      \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ck05t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ga05t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_hm05t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lp05t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lscore_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_mb05t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_misc_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_sc05t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_top05t0750v_pssg_s300_v0670_t000_primetime-lvf.pocv_coefficients \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/messages/messages.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/utils/utils.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ck05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ga05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_hm05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lp05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lscore.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_mb05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_misc.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_sc05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_top05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/pt_si_settings_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pssg_s300_v0670_t000_primetime-lvf.global_signoff \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ck05t0750v_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ga05t0750v_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_hm05t0750v_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lp05t0750v_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lscore_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_mb05t0750v_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_misc_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_sc05t0750v_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_top05t0750v_pssg_s300_v0670_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/memory_derates.tcl \
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell" || $synopsys_program_name == "lc_shell"))} {
   set pvt_corner($PVT_CORNER,label) "pffg_s300_v0830_t125_xcbccbt"
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc3ffe_sc05t0750v_pffg_s300_v0830_t125_xcbccbt" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
       /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_*/apache/FF0960125/* \
       /project/foundry/TSMC/N3/BRCM/IP/MEM/memories/20250203//memory/int/power/apache//apl/*/*ff* \
    "
   set pvt_corner($PVT_CORNER,timing) " \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/db/tsmc3ffe_sc05t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/db/tsmc3ffe_ck05t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/db/tsmc3ffe_ga05t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/db/tsmc3ffe_hm05t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/db/tsmc3ffe_lp05t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/db/tsmc3ffe_mb05t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/db/tsmc3ffe_misc_pffg_s300_v0830_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/db/tsmc3ffe_top05t0750v_pffg_s300_v0830_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/db/tsmc3ffe_lscore_pffg_s300_v0830_t125_o0935_xcbccbt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/3FFE_pffg_s300_v0830_t125_spatial_tempus-socv.socv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/cln03.wire.FF.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
	/project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/cln03.wire.pocvm \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_ck05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_ga05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_hm05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_lp05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_lscore_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_mb05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_misc_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_sc05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_top05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_wildcards_primetime-lvf.locv_table \
      \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ck05t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ga05t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_hm05t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lp05t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lscore_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_mb05t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_misc_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_sc05t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_top05t0750v_pffg_s300_v0830_t125_primetime-lvf.pocv_coefficients \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/messages/messages.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/utils/utils.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ck05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ga05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_hm05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lp05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lscore.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_mb05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_misc.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_sc05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_top05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/pt_si_settings_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t125_primetime-lvf.global_signoff \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ck05t0750v_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ga05t0750v_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_hm05t0750v_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lp05t0750v_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lscore_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_mb05t0750v_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_misc_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_sc05t0750v_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_top05t0750v_pffg_s300_v0830_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/memory_derates.tcl \
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell" || $synopsys_program_name == "lc_shell"))} {
   set pvt_corner($PVT_CORNER,label) "pffg_s300_v0830_t000_xcbccbt"
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc3ffe_sc05t0750v_pffg_s300_v0830_t000_xcbccbt" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/db/tsmc3ffe_sc05t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/db/tsmc3ffe_ck05t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/db/tsmc3ffe_ga05t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/db/tsmc3ffe_hm05t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/db/tsmc3ffe_lp05t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/db/tsmc3ffe_mb05t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/db/tsmc3ffe_misc_pffg_s300_v0830_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/db/tsmc3ffe_top05t0750v_pffg_s300_v0830_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/db/tsmc3ffe_lscore_pffg_s300_v0830_t000_o0935_xcbccbt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/3FFE_pffg_s300_v0830_t000_spatial_tempus-socv.socv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/cln03.wire.FF.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
	/project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/cln03.wire.pocvm \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_ck05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_ga05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_hm05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_lp05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_lscore_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_mb05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_misc_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_sc05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_top05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_wildcards_primetime-lvf.locv_table \
      \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ck05t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ga05t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_hm05t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lp05t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lscore_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_mb05t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_misc_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_sc05t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_top05t0750v_pffg_s300_v0830_t000_primetime-lvf.pocv_coefficients \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/messages/messages.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/utils/utils.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ck05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ga05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_hm05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lp05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lscore.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_mb05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_misc.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_sc05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_top05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/pt_si_settings_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0830_t000_primetime-lvf.global_signoff \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ck05t0750v_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ga05t0750v_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_hm05t0750v_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lp05t0750v_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lscore_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_mb05t0750v_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_misc_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_sc05t0750v_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_top05t0750v_pffg_s300_v0830_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/memory_derates.tcl \
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER qod_125_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell" || $synopsys_program_name == "lc_shell"))} {
   set pvt_corner($PVT_CORNER,label) "pffg_s300_v0880_t125_xcbccbt"
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc3ffe_sc05t0750v_pffg_s300_v0880_t125_xcbccbt" ;#
   set pvt_corner($PVT_CORNER,temperature) "125"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) "\
       /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_*/apache/FF0960125/* \
    /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20230310/memory/int/power/apache/apl/*/*ff* \
    "
   set pvt_corner($PVT_CORNER,timing) " \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/db/tsmc3ffe_sc05t0750v_pffg_s300_v0880_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/db/tsmc3ffe_ck05t0750v_pffg_s300_v0880_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/db/tsmc3ffe_ga05t0750v_pffg_s300_v0880_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/db/tsmc3ffe_hm05t0750v_pffg_s300_v0880_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/db/tsmc3ffe_lp05t0750v_pffg_s300_v0880_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/db/tsmc3ffe_mb05t0750v_pffg_s300_v0880_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/db/tsmc3ffe_misc_pffg_s300_v0880_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/db/tsmc3ffe_top05t0750v_pffg_s300_v0880_t125_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/db/tsmc3ffe_lscore_pffg_s300_v0880_t125_o0935_xcbccbt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/3FFE_pffg_s300_v0880_t125_spatial_tempus-socv.socv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/cln03.wire.FF.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
	/project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/cln03.wire.pocvm \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_ck05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_ga05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_hm05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_lp05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_lscore_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_mb05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_misc_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_sc05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_top05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_wildcards_primetime-lvf.locv_table \
      \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ck05t0750v_pffg_s300_v0880_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ga05t0750v_pffg_s300_v0880_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_hm05t0750v_pffg_s300_v0880_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lp05t0750v_pffg_s300_v0880_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lscore_pffg_s300_v0880_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_mb05t0750v_pffg_s300_v0880_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_misc_pffg_s300_v0880_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_sc05t0750v_pffg_s300_v0880_t125_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_top05t0750v_pffg_s300_v0880_t125_primetime-lvf.pocv_coefficients \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/messages/messages.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/utils/utils.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ck05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ga05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_hm05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lp05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lscore.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_mb05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_misc.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_sc05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_top05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/pt_si_settings_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t125_primetime-lvf.global_signoff \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ck05t0750v_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ga05t0750v_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_hm05t0750v_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lp05t0750v_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lscore_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_mb05t0750v_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_misc_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_sc05t0750v_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_top05t0750v_pffg_s300_v0880_t125.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/memory_derates.tcl \
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER qod_minT_LIBRARY_FF
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell" || $synopsys_program_name == "lc_shell"))} {
   set pvt_corner($PVT_CORNER,label) "pffg_s300_v0880_t000_xcbccbt"
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc3ffe_sc05t0750v_pffg_s300_v0880_t000_xcbccbt" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/db/tsmc3ffe_sc05t0750v_pffg_s300_v0880_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/db/tsmc3ffe_ck05t0750v_pffg_s300_v0880_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/db/tsmc3ffe_ga05t0750v_pffg_s300_v0880_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/db/tsmc3ffe_hm05t0750v_pffg_s300_v0880_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/db/tsmc3ffe_lp05t0750v_pffg_s300_v0880_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/db/tsmc3ffe_mb05t0750v_pffg_s300_v0880_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/db/tsmc3ffe_misc_pffg_s300_v0880_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/db/tsmc3ffe_top05t0750v_pffg_s300_v0880_t000_xcbccbt.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/db/tsmc3ffe_lscore_pffg_s300_v0880_t000_o0935_xcbccbt.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/3FFE_pffg_s300_v0880_t000_spatial_tempus-socv.socv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/TMPS/cln03.wire.FF.socv \
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_ck05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_ga05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_hm05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_lp05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_lscore_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_mb05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_misc_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_sc05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_top05t0750v_primetime-lvf.locv_table \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_wildcards_primetime-lvf.locv_table \
      \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ck05t0750v_pffg_s300_v0880_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_ga05t0750v_pffg_s300_v0880_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_hm05t0750v_pffg_s300_v0880_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lp05t0750v_pffg_s300_v0880_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_lscore_pffg_s300_v0880_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_mb05t0750v_pffg_s300_v0880_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_misc_pffg_s300_v0880_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_sc05t0750v_pffg_s300_v0880_t000_primetime-lvf.pocv_coefficients \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_top05t0750v_pffg_s300_v0880_t000_primetime-lvf.pocv_coefficients \
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/messages/messages.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/soft_tcllib/utils/utils.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ck05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ga05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_hm05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lp05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lscore.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_mb05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_misc.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_sc05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_top05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/pt_si_settings_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/3FFE_pffg_s300_v0880_t000_primetime-lvf.global_signoff \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ck05t0750v_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_ga05t0750v_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_hm05t0750v_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lp05t0750v_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_lscore_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_mb05t0750v_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_misc_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_sc05t0750v_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/sigma_derate_primetime-lvf_tsmc3ffe_top05t0750v_pffg_s300_v0880_t000.tcl \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/memory_derates.tcl \
   "
}

#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_25T_LIBRARY_TT
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell" || $synopsys_program_name == "lc_shell"))} {
   set pvt_corner($PVT_CORNER,label) "pttg_s300_v0750_t025_xctcct"
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc3ffe_sc05t0750v_pttg_s300_v0750_t025_xctcct" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/db/tsmc3ffe_sc05t0750v_pttg_s300_v0750_t025_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/db/tsmc3ffe_ck05t0750v_pttg_s300_v0750_t025_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/db/tsmc3ffe_ga05t0750v_pttg_s300_v0750_t025_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/db/tsmc3ffe_hm05t0750v_pttg_s300_v0750_t025_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/db/tsmc3ffe_lp05t0750v_pttg_s300_v0750_t025_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/db/tsmc3ffe_mb05t0750v_pttg_s300_v0750_t025_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/db/tsmc3ffe_misc_pttg_s300_v0750_t025_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/db/tsmc3ffe_top05t0750v_pttg_s300_v0750_t025_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/db/tsmc3ffe_lscore_pttg_s300_v0750_t000_o0750_xctcct_PowerEstOnly.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ck05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ga05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_hm05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lp05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lscore.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_mb05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_misc.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_sc05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_top05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/memory_derates.tcl \
   "
}


#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
set PVT_CORNER no_od_85T_LIBRARY_TT
if {[regexp $PVT_CORNER $all_scenarios] || ![info exists ::synopsys_program_name] || ([info exists ::synopsys_program_name] && ($synopsys_program_name == "pt_shell" || $synopsys_program_name == "fm_shell" || $synopsys_program_name == "lc_shell"))} {
   set pvt_corner($PVT_CORNER,label) "pttg_s300_v0750_t085_xctcct"
   set pvt_corner($PVT_CORNER,op_code) "BCIND"
   set pvt_corner($PVT_CORNER,op_code_lib) "tsmc3ffe_sc05t0750v_pttg_s300_v0750_t085_xctcct" ;#
   set pvt_corner($PVT_CORNER,temperature) "0"
   set pvt_corner($PVT_CORNER,flat_ocv) {{1.05 0.95} {1.05 1.0}} ; # {clock late early } { data late early }
   set pvt_corner($PVT_CORNER,flat_mem_ocv) {{1.08 1.0} {1.08 1.0}} ; # {check late early } { data late early }
   set pvt_corner($PVT_CORNER,apl_file_list) ""
   set pvt_corner($PVT_CORNER,timing) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/db/tsmc3ffe_sc05t0750v_pttg_s300_v0750_t085_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/db/tsmc3ffe_ck05t0750v_pttg_s300_v0750_t085_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/db/tsmc3ffe_ga05t0750v_pttg_s300_v0750_t085_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/db/tsmc3ffe_hm05t0750v_pttg_s300_v0750_t085_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/db/tsmc3ffe_lp05t0750v_pttg_s300_v0750_t085_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/db/tsmc3ffe_mb05t0750v_pttg_s300_v0750_t085_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/db/tsmc3ffe_misc_pttg_s300_v0750_t085_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/db/tsmc3ffe_top05t0750v_pttg_s300_v0750_t085_xctcct_PowerEstOnly.lib.gz \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/db/tsmc3ffe_lscore_pttg_s300_v0750_t000_o0750_xctcct_PowerEstOnly.lib.gz \
   "
   set pvt_corner($PVT_CORNER,ocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_pocv) "\
   "

   set pvt_corner($PVT_CORNER,pt_ocv) "\
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ck05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_ga05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_hm05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lp05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_lscore.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_mb05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_misc.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_sc05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/timing_derate_simulswitch_primetime-lvf_tsmc3ffe_top05t0750v.coefficient \
      /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/TIMING_SUPPORT/PTSI/memory_derates.tcl \
   "
}



#--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#################################################################################################################################################################################################
###    design setting 
#################################################################################################################################################################################################
if {![info exists UNCERTAINTY_MARGIN]} {set UNCERTAINTY_MARGIN [list 0.010 0.010 0.010] } ; # place , cts , route 

set DEFAULT_SITE coreW48M143H117
set DEFAULT_ROW_PATTERN coreW48M143H286

set SHORT_CELL_HEIGHT         0.117    ;# set it to "" if it's no need to used.
set TALL_CELL_HEIGHT          0.169    ;# set it to "" if it's no need to used.


if {![info exists MAX_ROUTING_LAYER]} {set MAX_ROUTING_LAYER 17}
if {![info exists MIN_ROUTING_LAYER]} {set MIN_ROUTING_LAYER 1}
set ROUTING_DIRECTION_HORIZONTAL "M0 M2 M4 M6 M8 M10 M12 M14 M16 M18 AP"
set ROUTING_DIRECTION_VERTICAL "M1 M3 M5 M7 M9 M11 M13 M15 M17"


set MIN_ROUTE_LENGTH 100
set MIN_DCAP_AREA 0.03213
set SPACE_TO_FF 9   ;  # 9 rows


# TODO: Add supply voltage per net
set PWR_NET     [list VDD]
set GND_NET     [list VSS]
set PWR_PINS    [list VDD VDDB VDDF]
set GND_PINS    [list VSS VSSB]

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
     
set VT_GROUPS(SVT)    *E?SN*
set VT_GROUPS(LVTLL)  *E?LL*
set VT_GROUPS(LVT)    *E?LN*
set VT_GROUPS(ULVT)   *E?UN*
set VT_GROUPS(ULVTLL) *E?UL*
set VT_GROUPS(EVT)    *E?EN*
#set VT_GROUPS(LVTLL)  *LVTLL06*
#set VT_GROUPS(ULVTLL) *ULTLL06*
set THRESHOLD_VOLTAGE_GROUP_TYPE_high_vt {SVT LVT LVTLL}
set THRESHOLD_VOLTAGE_GROUP_TYPE_normal_vt {}
set THRESHOLD_VOLTAGE_GROUP_TYPE_low_vt {ULVTLL ULVT EVT}
set leakage_pattern_priority_list "E?SN E?LL E?LN E?UL E?UN E?EN"
if {![info exists LVT_PERCENTAGE ]} {set LVT_PERCENTAGE                      "15" }  ; # User defined percentage of LVT to constrain. 

set ENABLE_AUTO_MULTI_VT_CONSTRAINT	false ; # Enable multi vth constraint on the design 

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
    E*SN* \
    E*DLY* \
    E*_LPD* \
    E*_*DLAT* \
    E*_CK* \
    E*_TOP*  \
    E*_BDFF*  \
    E*_TRI*  \
    E*_DFF*  \
    E*_SDFF* \
    E*CDM*  \
    E*RESYNC*  \
    E*G_*  \
    E1*DFF* \
    E2*A_ONAI22L4X8 \
    E2*A_ONAI22X8 \
    E*LCAP* \
    E*SYNC*  \
    E*BDFF*  \
    E*BORDER*  \
    E*CCAP*  \
    E*DIODE*  \
    E*FILLER* \
    E*_FANCRSX* \
    E*_FANCR2X* \
    E*_BSELX* \
    E*_ISOLAT* \
    \
    E*_AO2222X1 \
    E*_AO2222V1X1 \
    E*_AOI222X2 \
    E*X24 \
    E*X27 \
    E*X28 \
    E*X30 \
    E*X32 \
    E*X36 \
    E*X40 \
    E*X48 \
"

#    E*BSDFFR*  \
#    E*BSDFFS*  \
#    E*BSDFFRS*  \
#    E*BSDFFM*  \

# if {[info exists STAGE] && $STAGE=="syn"} {
#   puts "-I- DONT_USE_CELLS: physical variants"
#   set DONT_USE_CELLS " $DONT_USE_CELLS \
#     F6*BA_* \
#     F6*CA_* \
#     F6*DA_* \
#   "
# 
# }

set mbit_stages {true compile place cts route false}
if {[info exists MBIT] && ([expr [lsearch $mbit_stages $MBIT] == -1] || [lsearch $mbit_stages $STAGE] < [lsearch $mbit_stages $MBIT])} {
  puts "-I- DONT_USE_CELLS: Run without MBIT cells"
  set DONT_USE_CELLS " $DONT_USE_CELLS \
     E3*_BSDFFCW2*
     E3*_BSDFFCW4*
     E3*_BSDFFRW2*
     E3*_BSDFFRW4*
     E3*_BSDFFSW2*
     E3*_BSDFFSW4*
     E3*_BSDFFW2*
     E3*_BSDFFW4*
  "
} 

if { ![info exists VT_EFFORT] || $VT_EFFORT == "low" } {
  puts "-I- DONT_USE_CELLS: Run without ULVT and ULVTLL cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
  E*UN* \
  E*UL* \
  E*EN* \
  "
} elseif { $VT_EFFORT == "medium" } {
  puts "-I- DONT_USE_CELLS: Run without ULVT  cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
  E*UN* \
  E*EN* \
  "
} elseif { $VT_EFFORT == "high" } {
  puts "-I- DONT_USE_CELLS: Run with ULVT and ULVTLL cells"
  set DONT_USE_CELLS "$DONT_USE_CELLS \
  E*EN* \
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
E3UNRA_LPDCKENOAV1X28 \
E3UNRA_LPDCKENOAX20 \
E5UNRA_LPDCKENOAV1X12 \
E5UNRA_LPDCKENOAX12 \
E5UNRA_LPDCKENOAX16 \
E5UNRA_LPDCKENOAX8 \
"

#E2UNRA_CKENOAX6 \

# if {[info exists TGATE] && $TGATE == "true"} {
# puts "-I remove TGATE flops from DONT_USE_CELLS" 
# #regsub {F6\*_DFF\*} $DONT_USE_CELLS "" DONT_USE_CELLS
# regsub {F6\*_SDFF\*} $DONT_USE_CELLS "" DONT_USE_CELLS
# 
# }


if {[info exists LATCH] && $LATCH == "true"} {
puts "-I remove DLAT latch from DONT_USE_CELLS" 
regsub {E\*_\*DLAT\*} $DONT_USE_CELLS "" DONT_USE_CELLS
}

#################################################################################################################################################################################################
###    place setting 
#################################################################################################################################################################################################
set IOBUFFER_CELL {E1LLRA_BUFAVPX8 E2LLRA_BUFAVPX8 E1LLRA_BUFX8 E2LLRA_BUFX8}
set IN_BUFFER_CELL {E1LLRA_BUFAVPX8 E2LLRA_BUFAVPX8}
set OUT_BUFFER_CELL {E1LLRA_BUFX8 E2LLRA_BUFX8}
set USEABLE_IOBUFFER_CELL {E1LLRA_BUFX10 E1LLRA_BUFX12 E1LLRA_BUFX14 E1LLRA_BUFX8 E1LNRA_BUFX10 E1LNRA_BUFX12 E1LNRA_BUFX14 E1LNRA_BUFX8 E1SNRA_BUFX10 E1SNRA_BUFX12 E1SNRA_BUFX14 E1SNRA_BUFX8 E1ULRA_BUFX10 E1ULRA_BUFX12 E1ULRA_BUFX14 E1ULRA_BUFX8 E1UNRA_BUFX10 E1UNRA_BUFX12 E1UNRA_BUFX14 E1UNRA_BUFX8 E2LLRA_BUFX10 E2LLRA_BUFX12 E2LLRA_BUFX14 E2LLRA_BUFX8 E2LNRA_BUFX10 E2LNRA_BUFX12 E2LNRA_BUFX14 E2LNRA_BUFX8 E2SNRA_BUFX10 E2SNRA_BUFX12 E2SNRA_BUFX14 E2SNRA_BUFX8 E2ULRA_BUFX10 E2ULRA_BUFX12 E2ULRA_BUFX14 E2ULRA_BUFX8 E2UNRA_BUFX10 E2UNRA_BUFX12 E2UNRA_BUFX14 E2UNRA_BUFX8 E3LLRA_BUFX12 E3LNRA_BUFX12 E3SNRA_BUFX12 E3ULRA_BUFX12 E3UNRA_BUFX12}
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
###    floorplan setting 
#################################################################################################################################################################################################
# 24/10/2024 Roy TBD: need to check if this setting is correct. 
set DIFFUSION_FORBIDDEN_SPACING 0.277 

# variables for macros spacing rules
set H_MIN_SR 0.65
set H_SR 7.424
set V_MIN_SR 0.8
set V_SR 7.781
set MEM_PREFIX_PATTERN M3

set ENDCAPS(RIGHT_EDGE)         "E1LLRA_BORDERSIDELEFT E2LLRA_BORDERSIDELEFT E3LLRA_BORDERSIDELEFTTIEP E3LLRA_BORDERSIDELEFTTIEN"
set ENDCAPS(LEFT_EDGE)          "E1LLRA_BORDERSIDERIGHT E2LLRA_BORDERSIDERIGHT E3LLRA_BORDERSIDERIGHTTIEP E3LLRA_BORDERSIDERIGHTTIEN"
set ENDCAPS(LEFT_TOP_CORNER)    "E1LLRA_BORDERCORNERPRIGHT E3LLRA_BORDERCORNERPRIGHTTIEP"
set ENDCAPS(LEFT_BOTTOM_CORNER) "E1LLRA_BORDERCORNERNRIGHT E3LLRA_BORDERCORNERNRIGHTTIEN"
set ENDCAPS(TOP_EDGE)           "E1LLRA_BORDERROWPWALL E1LLRA_BORDERROWP8 E1LLRA_BORDERROWP4 E1LLRA_BORDERROWP2 E1LLRA_BORDERROWP1 E3LLRA_BORDERROWTIEPWALL E3LLRA_BORDERROWTIEP"
set ENDCAPS(BOTTOM_EDGE)        "E1LLRA_BORDERROWNWALL E1LLRA_BORDERROWN8 E1LLRA_BORDERROWN4 E1LLRA_BORDERROWN2 E1LLRA_BORDERROWN1 E3LLRA_BORDERROWTIENWALL E3LLRA_BORDERROWTIEN"
set ENDCAPS(LEFT_TOP_EDGE)      "E3LLRA_BORDERINTCORNERNRIGHT E3LLRA_BORDERINTCORNERNRIGHTTIEP"
set ENDCAPS(LEFT_BOTTOM_EDGE)   "E3LLRA_BORDERINTCORNERPRIGHT E3LLRA_BORDERINTCORNERPRIGHTTIEN"


#LUP6.6
#set TAPCELL "{F6LLAA_TIESMALL rule 16.13 boundary_layer LUP_SRM boundary_rule 16.13} {F6LLAA_TIE rule 21.33}"

set TAPCELL {E3LLRA_TIENWALL E3LLRA_TIEN E3LLRA_TIEPWALL E3LLRA_TIEP E1LLRA_FILLERWALL E2LLRA_FILLERWALL E1LLRA_FILLERWALLB E2LLRA_FILLERWALLB}
set TIEHCELL "E1LLRA_TIEHI"
set TIELCELL "E1LLRA_TIELO"
set ANTENNA_CELL_NAME "E1LLRA_DIODEX2 E1LLRA_DIODEX3 E1LLRA_DIODEX4 E2LLRA_DIODEX2 E2LLRA_DIODEX3 E2LLRA_DIODEX4"

set PRE_PLACE_DECAP "E3LLRA_CCCAPD16BY2"
set PRE_PLACE_ECO_DCAP "E5LNRG_CCCAP4"

set ECO_DCAP_LIST   "E5LNRAG_CCCAP1 E5LNRAG_CCCAP2 E5LNRAG_CCCAP4 E5LNRAG_CCCAP8 E5LNRAG_CCCAPM0FULL1 E5LNRAG_CCCAPM0FULL2 E5LNRAG_CCCAPM0FULL4 E5LNRAG_CCCAPM0FULL8 E5LNRG_CCCAP1 E5LNRG_CCCAP2 E5LNRG_CCCAP4 E5LNRG_CCCAP8 E5LNRG_CCCAPM0FULL1 E5LNRG_CCCAPM0FULL2 E5LNRG_CCCAPM0FULL4 E5LNRG_CCCAPM0FULL8"
set DCAP_CELLS_LIST "E1LLRA_CCCAP12 E1LLRA_CCCAP16 E1LLRA_CCCAP32 E1LLRA_CCCAP4 E1LLRA_CCCAP5 E1LLRA_CCCAP64 E1LLRA_CCCAP8 E2LLRA_CCCAP12 E2LLRA_CCCAP16 E2LLRA_CCCAP32 E2LLRA_CCCAP4 E2LLRA_CCCAP5 E2LLRA_CCCAP64 E2LLRA_CCCAP8 E3LLRA_CCCAP16BY4 E3LLRA_CCCAP32BY8 E3LLRA_CCCAP48BY16 E3LLRA_CCCAP48BY8 E3LLRA_CCCAP64BY16 E3LLRA_CCCAP8BY2 E3LLRA_CCCAPCPD16BY4 E3LLRA_CCCAPCPD32BY8 E3LLRA_CCCAPCPD48BY16 E3LLRA_CCCAPCPD48BY8 E3LLRA_CCCAPCPD64BY16 E3LLRA_CCCAPCPD8BY2"
set ALL_DCAP_CELLS  "$ECO_DCAP_LIST $DCAP_CELLS_LIST"

# from brcm
#  were in the list but not available:
#  E3UNRAG_CCCAPM0FULL8  \
   E3UNRAG_CCCAPM0FULL4  \
   E3UNRAG_CCCAPM0FULL2  \
   E3UNRAG_CCCAPM0FULL1  \

set fillbycap E3LLRA_CCCAPM0FULL64BY16 
set METAL_FILL_CELLS [ list \
     $fillbycap \
   E3LLRA_CCCAPM0FULL48BY16 \
   E3LLRA_CCCAPM0FULL48BY8 \
   E3LLRA_CCCAPM0FULL32BY8 \
   E3LLRA_CCCAPM0FULL16BY4 \
   E3LLRA_CCCAPM0FULL8BY2 \
   E5UNRAG_CCCAPM0FULL8 \
   E5UNRAG_CCCAPM0FULL4 \
   E5UNRAG_CCCAPM0FULL2 \
   E5UNRAG_CCCAPM0FULL1 \
   E5UNRAG_FILLERM0FULL1 \
   E2LLRA_CCCAPM0FULL16 \
   E2LLRA_CCCAPM0FULL8 \
   E2LLRA_CCCAPM0FULL4 \
   E2LLRA_CCCAPM0FULL3 \
   E1LLRA_CCCAPM0FULL16 \
   E1LLRA_CCCAPM0FULL8 \
   E1LLRA_CCCAPM0FULL4 \
   E1LLRA_CCCAPM0FULL3 \
]
set ALL_DCAP_CELLS $METAL_FILL_CELLS



set FILLER64_CELLS_LIST "E2UNRA_FILLER64 E1UNRA_FILLER64 E2LLRA_FILLER64 E1LLRA_FILLER64"
set FILLER32_CELLS_LIST "E2UNRA_FILLER32 E1UNRA_FILLER32 E2LLRA_FILLER32 E1LLRA_FILLER32"
set FILLER16_CELLS_LIST "E2UNRA_FILLER16 E1UNRA_FILLER16 E2LLRA_FILLER16 E1LLRA_FILLER16"
set FILLER12_CELLS_LIST "E2UNRA_FILLER12 E1UNRA_FILLER12 E2LLRA_FILLER12 E1LLRA_FILLER12"
set FILLER8_CELLS_LIST  "E2UNRA_FILLER8 E1UNRA_FILLER8 E2LLRA_FILLER8 E1LLRA_FILLER8"
set FILLER5_CELLS_LIST  "E2UNRA_FILLER5 E1UNRA_FILLER5 E2LLRA_FILLER5 E1LLRA_FILLER5"
set FILLER4_CELLS_LIST  "E2UNRA_FILLER4 E1UNRA_FILLER4 E2LLRA_FILLER4 E1LLRA_FILLER4"
set FILLER3_CELLS_LIST  "E2ENRA_FILLER3 E1ENRA_FILLER3 E2UNRA_FILLER3 E1UNRA_FILLER3 E2ULRA_FILLER3 E1ULRA_FILLER3 E2LNRA_FILLER3 E1LNRA_FILLER3 E2LLRA_FILLER3 E1LLRA_FILLER3 E2SNRA_FILLER3 E1SNRA_FILLER3"
set FILLER2_CELLS_LIST  "E2ENRA_FILLER2 E1ENRA_FILLER2 E2UNRA_FILLER2 E1UNRA_FILLER2 E2ULRA_FILLER2 E1ULRA_FILLER2 E2LNRA_FILLER2 E1LNRA_FILLER2 E2LLRA_FILLER2 E1LLRA_FILLER2 E2SNRA_FILLER2 E1SNRA_FILLER2"
set FILLER1_CELLS_LIST  "E2ENRA_FILLER1 E1ENRA_FILLER1 E2UNRA_FILLER1 E1UNRA_FILLER1 E2ULRA_FILLER1 E1ULRA_FILLER1 E2LNRA_FILLER1 E1LNRA_FILLER1 E2LLRA_FILLER1 E1LLRA_FILLER1 E2SNRA_FILLER1 E1SNRA_FILLER1"

set FILLERS_CELLS_LIST "$ECO_DCAP_LIST $DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER5_CELLS_LIST  $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"
set ALL_FILLER_CELLS "$FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER5_CELLS_LIST  $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"

#set FILLERS_CELLS_LIST "$DCAP_CELLS_LIST $FILLER64_CELLS_LIST $FILLER32_CELLS_LIST $FILLER16_CELLS_LIST $FILLER12_CELLS_LIST $FILLER8_CELLS_LIST $FILLER4_CELLS_LIST $FILLER3_CELLS_LIST $FILLER2_CELLS_LIST $FILLER1_CELLS_LIST"

#set ADD_FILLERS_SWAP_CELL {{F6LLAA_FILLER1 F6LLAA_FILLER1B} {F6LNAA_FILLER1 F6LNAA_FILLER1B} {F6UNAA_FILLER1 F6UNAA_FILLER1B} {F6ENAA_FILLER1 F6ENAA_FILLER1B} {F6ULAA_FILLER1 F6ULAA_FILLER1B} {F6SNAA_FILLER1 F6SNAA_FILLER1B}}

# from brcm
set NO_METAL_FILL_CELLS [ list \
     E2UNRA_FILLER64 \
   E1UNRA_FILLER64 \
   E2UNRA_FILLER32 \
   E1UNRA_FILLER32 \
   E2UNRA_FILLER16 \
   E1UNRA_FILLER16 \
   E2UNRA_FILLER12 \
   E1UNRA_FILLER12 \
   E2UNRA_FILLER8  \
   E1UNRA_FILLER8  \
   E2UNRA_FILLER5  \
   E1UNRA_FILLER5  \
   E2UNRA_FILLER4  \
   E1UNRA_FILLER4  \
   E2SNRA_FILLER3  \
   E2LLRA_FILLER3  \
   E2LNRA_FILLER3  \
   E2ULRA_FILLER3  \
   E2UNRA_FILLER3  \
   E2ENRA_FILLER3  \
   E1SNRA_FILLER3  \
   E1LLRA_FILLER3  \
   E1LNRA_FILLER3  \
   E1ULRA_FILLER3  \
   E1UNRA_FILLER3  \
   E1ENRA_FILLER3  \
   E2SNRA_FILLER2  \
   E2LLRA_FILLER2  \
   E2LNRA_FILLER2  \
   E2ULRA_FILLER2  \
   E2UNRA_FILLER2  \
   E2ENRA_FILLER2  \
   E1SNRA_FILLER2  \
   E1LLRA_FILLER2  \
   E1LNRA_FILLER2  \
   E1ULRA_FILLER2  \
   E1UNRA_FILLER2  \
   E1ENRA_FILLER2  \
   E2SNRA_FILLER1  \
   E2LLRA_FILLER1  \
   E2LNRA_FILLER1  \
   E2ULRA_FILLER1  \
   E2UNRA_FILLER1  \
   E2ENRA_FILLER1  \
   E1SNRA_FILLER1  \
   E1LLRA_FILLER1  \
   E1LNRA_FILLER1  \
   E1ULRA_FILLER1  \
   E1UNRA_FILLER1  \
   E1ENRA_FILLER1  \
]
set ALL_FILLER_CELLS $NO_METAL_FILL_CELLS

###################################################################################################################################################################################################
###    CTS setting 
###################################################################################################################################################################################################

set CLK_CELLS_PREFIX 		LPD
set CTS_BUFFER_CELLS          {E2UNRA_LPDBUFV1X12 E2UNRA_LPDBUFX12 E2UNRA_LPDBUFX16 E2UNRA_LPDBUFX8 E5UNRA_LPDBUFX20 }

set CTS_INVERTER_CELLS_TOP    {}

set CTS_INVERTER_CELLS_TRUNK  {}

set CTS_INVERTER_CELLS_LEAF   { \
E2UNRA_LPDINVX12 \
E2UNRA_LPDINVX16 \
E2UNRA_LPDINVX8 \
E5UNRA_LPDINVX20 \
E5UNRA_LPDINVX24 \
}

set CTS_LOGIC_CELLS           {E3UNRA_LPDCKSMUX2X2 E3UNRA_LPDCKSMUX4X16 E3UNRA_LPDCKSMUX4X8 E2UNRA_CKAND2X2 E2UNRA_CKAND2X4 E2UNRA_CKAND2X8 E2UNRA_CKMUX2IX2 E2UNRA_CKMUX2IX4 E2UNRA_CKMUX2IX6 E2UNRA_CKMUX2IX8 E2UNRA_CKMUX2X12 E2UNRA_CKMUX2X16 E2UNRA_CKMUX2X2 E2UNRA_CKMUX2X4 E2UNRA_CKMUX2X6 E2UNRA_CKMUX2X8 E2UNRA_CKNAND2X2 E2UNRA_CKNAND2X4 E2UNRA_CKNAND2X8 E2UNRA_CKNOR2X2 E2UNRA_CKNOR2X4 E2UNRA_CKNOR2X8 E2UNRA_CKOR2X2 E2UNRA_CKOR2X4 E2UNRA_CKOR2X8 E3UNRA_CKMUX2X6}
set CTS_CLOCK_GATING_CELLS    {E3UNRA_LPDCKENOAV1X28  E3UNRA_LPDCKENOAX20  E5UNRA_LPDCKENOAV1X12  E5UNRA_LPDCKENOAX12  E5UNRA_LPDCKENOAX16  E5UNRA_LPDCKENOAX8   }
set CTS_CELLS_HALO [concat $CTS_BUFFER_CELLS $CTS_INVERTER_CELLS_TOP $CTS_INVERTER_CELLS_TRUNK $CTS_INVERTER_CELLS_LEAF $CTS_LOGIC_CELLS $CTS_CLOCK_GATING_CELLS]

if {![info exists CLOCK_GATING_SETUP]} {set CLOCK_GATING_SETUP 0.060 }
if {![info exists LP_CLOCK_GATING_CELL]} {set LP_CLOCK_GATING_CELL E5UNRA_LPDCKENOAX16}
if {![info exists EXCLUDE_ICG] } {set EXCLUDE_ICG ""}   ;# a list of inst name or IO/io/INPUT/input


set HOLD_FIX_CELLS_LIST "E1LLRA_BUFX1 E1LNRA_BUFX1 E1SNRA_BUFX1 E1ULRA_BUFX1 E1UNRA_BUFX1 E1LLRA_BUFX2 E1LNRA_BUFX2 E1SNRA_BUFX2 E1ULRA_BUFX2 E1UNRA_BUFX2 E1LLRA_BUFX3 E1LNRA_BUFX3 E1SNRA_BUFX3 E1ULRA_BUFX3 E1UNRA_BUFX3 E1LLRA_BUFX4 E1LNRA_BUFX4 E1SNRA_BUFX4 E1ULRA_BUFX4 E1UNRA_BUFX4 E2LLRA_BUFX2 E2LNRA_BUFX2 E2SNRA_BUFX2 E2ULRA_BUFX2 E2UNRA_BUFX2 E2LLRA_BUFX4 E2LNRA_BUFX4 E2SNRA_BUFX4 E2ULRA_BUFX4 E2UNRA_BUFX4 E1LLRA_DLY025X1 E1LLRA_DLY025X2 E1LLRA_DLY025X4 E1LLRA_DLY050X1 E1LLRA_DLY050X4 E1LLRA_DLY075X1 E1LLRA_DLY100X1 E1LLRA_DLY150X1 E1LLRA_DLY200X1 E1LLRA_DLY250X1 E2LLRA_DLY025X2 E2LLRA_DLY025X4 E2LLRA_DLY025X8 E2LLRA_DLY050X2 E2LLRA_DLY050X8 E2LLRA_DLY100X2 E2LLRA_DLY150X2 E2LLRA_DLY200X2 E1LNRA_DLY025X1 E1LNRA_DLY025X2 E1LNRA_DLY025X4 E1LNRA_DLY050X1 E1LNRA_DLY050X4 E1LNRA_DLY075X1 E1LNRA_DLY100X1 E1LNRA_DLY150X1 E1LNRA_DLY200X1 E1LNRA_DLY250X1 E2LNRA_DLY025X2 E2LNRA_DLY025X4 E2LNRA_DLY025X8 E2LNRA_DLY050X2 E2LNRA_DLY050X8 E2LNRA_DLY100X2 E2LNRA_DLY150X2 E2LNRA_DLY200X2 E1ULRA_DLY025X1 E1ULRA_DLY025X2 E1ULRA_DLY025X4 E1ULRA_DLY050X1 E1ULRA_DLY050X4 E1ULRA_DLY075X1 E1ULRA_DLY100X1 E1ULRA_DLY150X1 E1ULRA_DLY200X1 E1ULRA_DLY250X1 E2ULRA_DLY025X2 E2ULRA_DLY025X4 E2ULRA_DLY025X8 E2ULRA_DLY050X2 E2ULRA_DLY050X8 E2ULRA_DLY100X2 E2ULRA_DLY150X2 E2ULRA_DLY200X2" 

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




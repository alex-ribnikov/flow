# // Design Source Paths

    if { ![info exists BRCM_IP_PATH] } {
        set BRCM_IP_PATH "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109"
    }
    if { ![info exists VERILOG_REPO_PATH] } {
        if { [regexp "/netlists/" [lindex $GOLDEN_NETLIST 0]] } {
            set VERILOG_REPO_PATH [regsub "/netlists/.*" [lindex $GOLDEN_NETLIST 0] ""]
        } elseif { [regexp "/netlists/" [lindex $REVISED_NETLIST 0]] } {
            set VERILOG_REPO_PATH [regsub "/netlists/.*" [lindex $REVISED_NETLIST 0] ""]
        }
    }
    if { ![info exists GEN_LIBS_PATH] } {
        set GEN_LIBS_PATH "$VERILOG_REPO_PATH/gen_libs"
    }
    if { ![info exists GEN_STUBS_PATH] } {
        set GEN_STUBS_PATH "$VERILOG_REPO_PATH/gen_stubs"  
    }


#######################################################################################################################################
##
##      d2d_pll_wrap
##
#######################################################################################################################################

if {$DESIGN_NAME == "d2d_pll_wrap"} {
   if {([info exists LEC_MODE] && $LEC_MODE == "syn2dft") || ([info exists FM_MODE] && $FM_MODE == "syn2dft")} {
       set REVISED_DESIGN_NAME "d2d_pll_wrap_ds05_max_mmi_pll_wrapper_island_lvl_01_0"
   } elseif {([info exists LEC_MODE] && $LEC_MODE == "net2net") || ([info exists FM_MODE] && $FM_MODE == "syn2dft")} {
       set REVISED_DESIGN_NAME "d2d_pll_wrap_ds05_max_mmi_pll_wrapper_island_lvl_01_0"
   }
   
   
#######################################################################################################################################
##
##      ecore_quad_complex_top
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "ecore_quad_complex_top"} {
    if { ![info exists ::synopsys_program_name] } {
        add_notranslate_modules -library -both \
            ecore_hif_wrap_top
    }
    if {[info exists FM_MODE] && $FM_MODE == "rtl2syn"} {
       set vstub_filelist [list \
          ${VERILOG_REPO_PATH}/netlists/netlists/ecore_hif_wrap_top.v.gz \
       ]
    
    } else {
       set vstub_lib [list \
          /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ecore_hif_wrap_top.lib   \
       ]
       set vstub_postDFT_lib [list \
          /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ecore_hif_wrap_top.lib   \
       ]
    }
#    set vstub_postDFT_filelist [list \
#       /bespace/users/royl/inext/inext_hw_fe/VSTUB_DFT_FN9/ecore_hif_wrap_top.vstub \
#    ]
    
     
#######################################################################################################################################
##
##      hbm3_chiplet
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "hbm3_chiplet" || $DESIGN_NAME == "hbm3_chiplet_v2"} {
    if { ![info exists ::synopsys_program_name] } {
#        add_notranslate_modules -library -both \
#            hbm3_mc4_syn_wrap
    }

    set vstub_lib [list \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/hbm3_mc4_syn_wrap_func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup.lib \
    ]
    set vstub_postDFT_lib [list \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN2_FN.18_20231101_2019/gen_libs/post_dft/hbm3_mc4_syn_wrap_func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup.lib \
    ]
        
    if {([info exists FM_MODE] && $FM_MODE == "syn2dft") || ([info exists LEC_MODE] && $LEC_MODE == "syn2dft")} {
        if {[regexp "hbm3_chiplet_v2" $revised_verilog_files ]} {
             set REVISED_DESIGN_NAME "hbm3_chiplet_v2"
        }
    }    
     
#######################################################################################################################################
##
##      ddr5_syn_wrap
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "ddr5_syn_wrap"} {
    if { ![info exists ::synopsys_program_name] } {
#        set ddr5_syn_wrap_notranslate_modules "
#            GCU_M5* M5S* M5P* cadence_phy_cdn_hs_phy_top
#        "
#        if {$LEC_MODE == "syn2dft"} {
#            add_notranslate_modules -design -golden ${ddr5_syn_wrap_notranslate_modules}
#            add_notranslate_modules -library -revised ${ddr5_syn_wrap_notranslate_modules}
#        } else {
#            add_notranslate_modules -library -both ${ddr5_syn_wrap_notranslate_modules}    
#        }

        add_notranslate_modules -library -both \
            cadence_phy_cdn_hs_phy_top
    }

    set vstub_lib [list \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/cadence_mc_1_controller_with_sram_wrap_func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup.lib \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/cadence_mc_controller_with_sram_wrap_func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup.lib \

    ]
    set vstub_postDFT_lib [list \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/cadence_mc_1_controller_with_sram_wrap_func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup.lib \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/cadence_mc_controller_with_sram_wrap_func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup.lib \
    ]

     
#######################################################################################################################################
##
##      pcore_axi_syn_top
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "pcore_axi_syn_top"} {

    if { ![info exists ::synopsys_program_name] } {
        add_notranslate_modules -library -both \
            pcore_bmt_syn_top pcore_config_wrapper pcore_l3_cluster_bank_noc_wrapper pcore_l3_cluster_cpu_top pcore_noc_east_wrapper pcore_noc_west_wrapper
    }
    if {[info exists FM_MODE] && $FM_MODE == "rtl2syn"} {
       # formality rtl2syn passed only when reading the child netlist
       set vstub_filelist [list \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/netlists/netlists/pcore_l3_cluster_bank_noc_wrapper.v.gz \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/netlists/netlists/pcore_bmt_syn_top.v.gz \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/netlists/netlists/pcore_l3_cluster_cpu_top.v.gz \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/netlists/netlists/pcore_config_wrapper.v.gz \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/netlists/netlists/pcore_noc_east_wrapper.v.gz \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/netlists/netlists/pcore_noc_west_wrapper.v.gz \
       ]
    } else {
       set vstub_lib [list \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcore_bmt_syn_top.lib \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcore_l3_cluster_bank_noc_wrapper.lib \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcore_noc_east_wrapper.lib \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcore_config_wrapper.lib \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcore_l3_cluster_cpu_top.lib \
         /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcore_noc_west_wrapper.lib \
       ]
       set vstub_postDFT_lib [list \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_bmt_syn_top.lib \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_l3_cluster_bank_noc_wrapper.lib \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_noc_east_wrapper.lib \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_config_wrapper.lib \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_l3_cluster_cpu_top.lib \
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_noc_west_wrapper.lib \
       ]
    }
     
#######################################################################################################################################
##
##      grid_quadrant
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "grid_quadrant"} {
    if { ![info exists ::synopsys_program_name] } {
        set grid_quadrant_notranslate_modules [list \
           F6LNAA_SRESYNCRX2 \
           F6LNAA_SRESYNCSX2 \
           F6ENAA_SRESYNC3RX2 \
           grid_cluster \
           grid_quad_south_filler_col_0_top \
           grid_quad_south_filler_col_top \
           grid_quad_south_filler_east_col_top \
           grid_quad_west_filler_ecore_row_top \
           grid_quad_west_filler_row_top \
           grid_tcu_cluster \
           grid_ecore_cluster \
           grid_quad_north_filler_col_top \
           grid_quad_east_filler_row_top \
           grid_quad_east_filler_row_0_top \
           grid_quad_east_filler_row_notch_top \
        ]
        if {$LEC_MODE == "syn2dft"} {
            # <HN> TODO test lib only
           add_notranslate_modules -design -golden ${grid_quadrant_notranslate_modules}
           add_notranslate_modules -library -revised ${grid_quadrant_notranslate_modules}
        } else {
           add_notranslate_modules -library -both ${grid_quadrant_notranslate_modules}
        }    
           add_notranslate_modules -library -both ${grid_quadrant_notranslate_modules}
    }
    set vstub_lib [list \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_cluster.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_ecore_cluster.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quad_east_filler_row_0_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quad_east_filler_row_notch_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quad_east_filler_row_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quad_north_filler_col_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quad_south_filler_col_0_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quad_south_filler_col_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quad_south_filler_east_col_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quad_west_filler_row_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_tcu_cluster.lib \
      ]
    set vstub_postDFT_lib [list \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_cluster.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_ecore_cluster.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quad_east_filler_row_0_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quad_east_filler_row_notch_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quad_east_filler_row_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quad_north_filler_col_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quad_south_filler_col_0_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quad_south_filler_col_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quad_south_filler_east_col_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quad_west_filler_row_top.lib \
       /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_tcu_cluster.lib \
      ]
     
#######################################################################################################################################
##
##      nxt009_top
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "nxt009_top"} {
    if { ![info exists ::synopsys_program_name] } {
        set_case_sensitivity on
                                   
	    if {$LEC_MODE == "syn2dft" } {

	        add_notranslate_modules -library -both \
            pciephyx16_wrapper_nxt009_NL16 \
		    ds05_max_efuse_wrapper_04 \
            grid_quadrant_tessent_mbisr_controller \
            pcore_axi_syn_top_tessent_mbisr_controller \
            ds05_tap_controller_02

	        # ds05_tap_controller_02
	        add_renaming_rule -module HBM1 {hbm3_chiplet_v2} {hbm3_chiplet} -both
	        add_renaming_rule -module HBM2 {_D84} {_D83} -both
	    }
    }

  # // <HN> rearrange variables by stage and not LEC_MODE
  
    set vstub_filelist "
        /tools/snps/syn/T-2022.03-SP5-5/packages/gtech/src_ver/GTECH_NOT.v
        /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_max_efuse_wrapper_04_behavioral_verilog.v
        /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_lib_ancil_ns_02_behavioral_verilog.v
    "

    set vstub_lib "
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/center_hif_tile_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/cfg_car_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_axi_chi_bridge_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_east_ctrl.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_io_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_west_ctrl.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ddr_ctrl_bridge.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ddr5_syn_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/eth_syn_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/general_pll.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quadrant.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/hbm3_chiplet.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/middle_io_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/nsc_nxt009_nextcore_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcie_car_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcie_top_syn_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/periphery_top_io_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/periphery_top_io_wrap_west.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/periphery_top_syn_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcore_axi_syn_top.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ecore_quad_complex_top.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/scu_top_syn_wrap.lib 
    "

    set vstub_postDFT_lib "
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/center_hif_tile_top.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/cfg_car_top.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_axi_chi_bridge_top.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_east_ctrl.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_io_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_west_ctrl.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ddr5_syn_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ddr_ctrl_bridge.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ecore_quad_complex_top.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/eth_syn_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/general_pll.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quadrant.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/hbm3_chiplet.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/hbm3_chiplet_v2.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/middle_io_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/nsc_nxt009_nextcore_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcie_car_top.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcie_top_syn_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_axi_syn_top.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_io_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_io_wrap_west.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_syn_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/scu_top_syn_wrap.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quadrant_tessent_mbisr_controller.lib
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_axi_syn_top_tessent_mbisr_controller.lib
    "
#        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_l3_cluster_bank_noc_wrapper.lib

    set vstub_postLayout_lib "
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/center_hif_tile_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/cfg_car_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/d2d_axi_chi_bridge_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/d2d_east_ctrl.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/d2d_io_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/d2d_west_ctrl.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/ddr5_syn_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/ddr_ctrl_bridge.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/ecore_quad_complex_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/eth_syn_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/general_pll.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/grid_quadrant.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/grid_quadrant_tessent_mbisr_controller.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/hbm3_chiplet.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/hbm3_chiplet_v2.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/middle_io_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/nsc_nxt009_nextcore_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcie_car_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcie_top_syn_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcore_axi_syn_top.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcore_axi_syn_top_tessent_mbisr_controller.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/periphery_top_io_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/periphery_top_io_wrap_west.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/periphery_top_syn_wrap.lib 
        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/scu_top_syn_wrap.lib             
    "
#      /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcore_l3_cluster_bank_noc_wrapper.lib 
  


###  ### // ~ ~ ~ RTL2ELAB ~ ~ ~ // ###
###    if {$LEC_MODE == "rtl2elab"} {
####                                /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_max_mmi_pll_wrapper_01_behavioral_verilog.vstub \
###
###        ### RTL2SYN OVERRIDES
###        
####        /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_max_efuse_wrapper_04_behavioral_verilog.v
####        /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_lib_ancil_ns_02_behavioral_verilog.v
###    
###    set vstub_filelist "
###        /tools/snps/syn/T-2022.03-SP5-5/packages/gtech/src_ver/GTECH_NOT.v
###    "
###    set vstub_lib "
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quadrant.lib
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/center_hif_tile_top.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_east_ctrl.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_west_ctrl.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_axi_chi_bridge_top.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/eth_syn_wrap.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcie_top_syn_wrap.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcie_car_top.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/hbm3_chiplet.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ddr5_syn_wrap.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ddr_ctrl_bridge.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/general_pll.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/periphery_top_syn_wrap.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/scu_top_syn_wrap.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/nsc_nxt009_nextcore_wrap.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/periphery_top_io_wrap.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/periphery_top_io_wrap_west.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/middle_io_wrap.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/cfg_car_top.lib 
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcore_axi_syn_top.lib
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ecore_quad_complex_top.lib
###        /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_io_wrap.lib
###    "
###
###        set vstub_postDFT_lib "
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/center_hif_tile_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/cfg_car_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_axi_chi_bridge_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_east_ctrl.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_io_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_west_ctrl.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ddr5_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ddr_ctrl_bridge.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ecore_quad_complex_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/eth_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/general_pll.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quadrant.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/hbm3_chiplet.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/hbm3_chiplet_v2.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/middle_io_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/nsc_nxt009_nextcore_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcie_car_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcie_top_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_axi_syn_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_l3_cluster_bank_noc_wrapper.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_io_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_io_wrap_west.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/scu_top_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quadrant_tessent_mbisr_controller.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_axi_syn_top_tessent_mbisr_controller.lib
###        "
###
###    
###  ### // ~ ~ ~ SYN2DFT ~ ~ ~ // ###
###	} elseif {([info exists LEC_MODE]) && ($LEC_MODE == "syn2dft")} {
###
###    ### Testing DC generated libs from FN15
###        set vstub_lib "
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/center_hif_tile_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/cfg_car_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_axi_chi_bridge_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_east_ctrl.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_io_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/d2d_west_ctrl.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ddr5_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ddr_ctrl_bridge.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/ecore_quad_complex_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/eth_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/general_pll.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/grid_quadrant.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/hbm3_chiplet.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/middle_io_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/nsc_nxt009_nextcore_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcie_car_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcie_top_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/pcore_axi_syn_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/periphery_top_io_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/periphery_top_io_wrap_west.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/periphery_top_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/syn/scu_top_syn_wrap.lib
###        "
###        set vstub_postDFT_lib "
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/center_hif_tile_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/cfg_car_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_axi_chi_bridge_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_east_ctrl.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_io_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_west_ctrl.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ddr5_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ddr_ctrl_bridge.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ecore_quad_complex_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/eth_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/general_pll.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quadrant.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/hbm3_chiplet.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/hbm3_chiplet_v2.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/middle_io_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/nsc_nxt009_nextcore_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcie_car_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcie_top_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_axi_syn_top.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_l3_cluster_bank_noc_wrapper.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_io_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_io_wrap_west.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/scu_top_syn_wrap.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quadrant_tessent_mbisr_controller.lib
###            /project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_axi_syn_top_tessent_mbisr_controller.lib
###        "
###    
###    set vstub_filelist "
###/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_max_mmi_pll_wrapper_01_behavioral_verilog.v
###/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_max_efuse_wrapper_04_behavioral_verilog.v
###/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_lib_ancil_ns_02_behavioral_verilog.v
###/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_max_mmi_pll_wrapper_core_lvl_01_behavioral_verilog.v
###/tools/snps/syn/T-2022.03-SP5-5/packages/gtech/src_ver/GTECH_NOT.v
###"
####/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_max_mmi_pll_wrapper_01_behavioral_verilog.v
####/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_max_efuse_wrapper_04_behavioral_verilog.v
####/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_lib_ancil_ns_02_behavioral_verilog.v
####/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20231109/verilog/ds05_max_mmi_pll_wrapper_core_lvl_01_behavioral_verilog.v
###
###  ### // ~ ~ ~ DFT2PLACE ~ ~ ~ // ##
###        } elseif { $LEC_MODE == "dft2place" } {
###
###            set vstub_postDFT_lib "
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/center_hif_tile_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/cfg_car_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_axi_chi_bridge_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_east_ctrl.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_io_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/d2d_west_ctrl.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ddr5_syn_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ddr_ctrl_bridge.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/ecore_quad_complex_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/eth_syn_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/general_pll.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quadrant.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/grid_quadrant_tessent_mbisr_controller.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/hbm3_chiplet.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/hbm3_chiplet_v2.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/middle_io_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/nsc_nxt009_nextcore_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcie_car_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcie_top_syn_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_axi_syn_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_axi_syn_top_tessent_mbisr_controller.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/pcore_l3_cluster_bank_noc_wrapper.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_io_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_io_wrap_west.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/periphery_top_syn_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_dft/scu_top_syn_wrap.lib             
###            "
###            set vstub_postLayout_lib "
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/center_hif_tile_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/cfg_car_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/d2d_axi_chi_bridge_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/d2d_east_ctrl.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/d2d_io_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/d2d_west_ctrl.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/ddr5_syn_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/ddr_ctrl_bridge.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/ecore_quad_complex_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/eth_syn_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/general_pll.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/grid_quadrant.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/grid_quadrant_tessent_mbisr_controller.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/hbm3_chiplet.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/hbm3_chiplet_v2.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/middle_io_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/nsc_nxt009_nextcore_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcie_car_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcie_top_syn_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcore_axi_syn_top.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcore_axi_syn_top_tessent_mbisr_controller.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/pcore_l3_cluster_bank_noc_wrapper.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/periphery_top_io_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/periphery_top_io_wrap_west.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/periphery_top_syn_wrap.lib 
###/project/inext/inext_hw_fe_model_releases/inext_hw_fe_GEN_FN.19_top_eco_20231115_1321/gen_libs/post_layout/scu_top_syn_wrap.lib             
###            "
###
###        }   ;# END OF DFT2PLACE
}    


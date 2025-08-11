switch $DESIGN_NAME {
   grid_quadrant {
#      set_black_box r:/WORK/grid_cluster
#      set_black_box r:/WORK/grid_tcu_cluster
#      set_black_box r:/WORK/grid_ecore_cluster
#      set_black_box r:/WORK/grid_quad_south_filler_col_top
#      set_black_box r:/WORK/grid_quad_south_filler_col_0_top
#      set_black_box r:/WORK/grid_quad_south_filler_east_col_top
#      set_black_box r:/WORK/grid_quad_west_filler_row_top
#      set_black_box r:/WORK/grid_quad_north_filler_col_top
#      set_black_box r:/WORK/grid_quad_east_filler_row_top
#      set_black_box r:/WORK/grid_quad_east_filler_row_0_top
#      set_black_box r:/WORK/grid_quad_east_filler_row_notch_top
      set_black_box r:/*/grid_cluster
      set_black_box r:/*/grid_tcu_cluster
      set_black_box r:/*/grid_ecore_cluster
      set_black_box r:/*/grid_quad_south_filler_col_top
      set_black_box r:/*/grid_quad_south_filler_col_0_top
      set_black_box r:/*/grid_quad_south_filler_east_col_top
      set_black_box r:/*/grid_quad_west_filler_row_top
      set_black_box r:/*/grid_quad_north_filler_col_top
      set_black_box r:/*/grid_quad_east_filler_row_top
      set_black_box r:/*/grid_quad_east_filler_row_0_top
      set_black_box r:/*/grid_quad_east_filler_row_notch_top
      set_black_box i:/WORK/grid_cluster
      set_black_box i:/WORK/grid_tcu_cluster
      set_black_box i:/WORK/grid_ecore_cluster
      set_black_box i:/WORK/grid_quad_south_filler_col_top
      set_black_box i:/WORK/grid_quad_south_filler_col_0_top
      set_black_box i:/WORK/grid_quad_south_filler_east_col_top
      set_black_box i:/WORK/grid_quad_west_filler_row_top
      set_black_box i:/WORK/grid_quad_north_filler_col_top
      set_black_box i:/WORK/grid_quad_east_filler_row_top
      set_black_box i:/WORK/grid_quad_east_filler_row_0_top
      set_black_box i:/WORK/grid_quad_east_filler_row_notch_top
   }
   middle_io_wrap {
      set_black_box r:/WORK/ecore_hif_wrap_top   
      set_black_box i:/WORK/ecore_hif_wrap_top   
   }
   ecore_quad_complex_top {
      set_black_box r:/WORK/ecore_hif_wrap_top   
      set_black_box i:/WORK/ecore_hif_wrap_top   
   }
   d2d_east_ctrl {
   }
   d2d_west_ctrl {
   }
   hbm3_chiplet {
      # instances of hbm3_mc4_syn_wrap
      #set_black_box r:/WORK/hbm3_chiplet/i_hbm_quad_0
      #set_black_box r:/WORK/hbm3_chiplet/i_hbm_quad_1
      #set_black_box r:/WORK/hbm3_chiplet/i_hbm_quad_2
      #set_black_box r:/WORK/hbm3_chiplet/i_hbm_quad_3
      #set_black_box i:/WORK/hbm3_chiplet/i_hbm_quad_0
      #set_black_box i:/WORK/hbm3_chiplet/i_hbm_quad_1
      #set_black_box i:/WORK/hbm3_chiplet/i_hbm_quad_2
      #set_black_box i:/WORK/hbm3_chiplet/i_hbm_quad_3
      #set_black_box r:/WORK/hbm3_mc4_syn_wrap
      #set_black_box i:/WORK/hbm3_mc4_syn_wrap
   }
   ddr5_syn_wrap {
      # cadence_mc_1_controller_with_sram_wrap and cadence_mc_controller_with_sram_wrap
      set_black_box i:/WORK/ddr5_syn_wrap/i_cadence_phy_ddr_subsystem_cadence_mc_controller_mci_wrapper_cadence_mc_1_controller_ch1/pwrBB
      set_black_box i:/WORK/ddr5_syn_wrap/i_cadence_phy_ddr_subsystem_cadence_mc_controller_mci_wrapper_cadence_mc_controller_ch0/pwrBB
      set_black_box r:/WORK/ddr5_syn_wrap/i_cadence_phy_ddr_subsystem/cadence_mc_controller_mci_wrapper/cadence_mc_1_controller_ch1/pwrBB
      set_black_box r:/WORK/ddr5_syn_wrap/i_cadence_phy_ddr_subsystem/cadence_mc_controller_mci_wrapper/cadence_mc_controller_ch0/pwrBB
   }
   pcore_axi_syn_top  {
      set_black_box r:/WORK/pcore_l3_cluster_cpu_top
      set_black_box r:/WORK/pcore_l3_cluster_bank_noc_wrapper
      set_black_box r:/WORK/pcore_bmt_syn_top
      set_black_box r:/WORK/pcore_noc_east_wrapper
      set_black_box r:/WORK/pcore_noc_west_wrapper
      set_black_box r:/WORK/pcore_config_wrapper
      set_black_box i:/WORK/pcore_l3_cluster_cpu_top
      set_black_box i:/WORK/pcore_l3_cluster_bank_noc_wrapper
      set_black_box i:/WORK/pcore_bmt_syn_top
      set_black_box i:/WORK/pcore_noc_east_wrapper
      set_black_box i:/WORK/pcore_noc_west_wrapper
      set_black_box i:/WORK/pcore_config_wrapper
   }
   nxt009_top {
      set_black_box r:/WORK/grid_quadrant
      set_black_box r:/WORK/ecore_quad_complex_top
      set_black_box r:/WORK/center_hif_tile_top
      set_black_box r:/WORK/d2d_east_ctrl
      set_black_box r:/WORK/d2d_west_ctrl
      set_black_box r:/WORK/d2d_axi_chi_bridge_top
      set_black_box r:/WORK/d2d_pll_wrap
      set_black_box r:/WORK/eth_syn_wrap
      set_black_box r:/WORK/pcie_top_syn_wrap
      set_black_box r:/WORK/pcie_car_top
      set_black_box r:/WORK/hbm3_chiplet
      set_black_box r:/WORK/ddr5_syn_wrap
      set_black_box r:/WORK/ddr_ctrl_bridge
      set_black_box r:/WORK/pcore_axi_syn_top
      set_black_box r:/WORK/general_pll
      set_black_box r:/WORK/scu_top_syn_wrap
      set_black_box r:/WORK/periphery_top_syn_wrap
      set_black_box r:/WORK/nsc_nxt009_nextcore_wrap
      set_black_box r:/WORK/periphery_top_io_wrap
      set_black_box r:/WORK/periphery_top_io_wrap_west
      set_black_box r:/WORK/middle_io_wrap
      set_black_box r:/WORK/d2d_io_wrap
      set_black_box r:/WORK/cfg_car_top
      set_black_box i:/WORK/grid_quadrant
      set_black_box i:/WORK/ecore_quad_complex_top
      set_black_box i:/WORK/center_hif_tile_top
      set_black_box i:/WORK/d2d_east_ctrl
      set_black_box i:/WORK/d2d_west_ctrl
      set_black_box i:/WORK/d2d_axi_chi_bridge_top
      set_black_box i:/WORK/d2d_pll_wrap
      set_black_box i:/WORK/eth_syn_wrap
      set_black_box i:/WORK/pcie_top_syn_wrap
      set_black_box i:/WORK/pcie_car_top
      set_black_box i:/WORK/hbm3_chiplet
      set_black_box i:/WORK/ddr5_syn_wrap
      set_black_box i:/WORK/ddr_ctrl_bridge
      set_black_box i:/WORK/pcore_axi_syn_top
      set_black_box i:/WORK/general_pll
      set_black_box i:/WORK/scu_top_syn_wrap
      set_black_box i:/WORK/periphery_top_syn_wrap
      set_black_box i:/WORK/nsc_nxt009_nextcore_wrap
      set_black_box i:/WORK/periphery_top_io_wrap
      set_black_box i:/WORK/periphery_top_io_wrap_west
      set_black_box i:/WORK/middle_io_wrap
      set_black_box i:/WORK/d2d_io_wrap
      set_black_box i:/WORK/cfg_car_top
   }
   default {
      puts "User_Warning : No user match commands found"
   }
}


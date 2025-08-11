enter_eco_mode
delete_inst -inst {assignBuf_258 assignBuf_259 assignBuf_260 assignBuf_261 assignBuf_262 assignBuf_263 assignBuf_264 assignBuf_265 assignBuf_266 assignBuf_267 assignBuf_268 assignBuf_269 assignBuf_270 assignBuf_271 assignBuf_272}
eco_update_cell -insts i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY -cells F6UNAA_LPDCKENOAX8
place_inst i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY {4865.349 2.0} r0
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_clock_port -new_net_name levelx_tap_clock_port_net -pins i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY/o -location {4865.349 5.0}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t66 -new_net_name level0_tap_a_t66_net -pins i_grid_clusters_wrap_i_cluster_r6_c6/grid_clk -location {7912.103 1282.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t66 -new_net_name level0_tap_b_t66_net -pins i_grid_clusters_wrap_i_cluster_r7_c6/grid_clk -location {7939.103 1293.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t67 -new_net_name level0_tap_a_t67_net -pins i_grid_clusters_wrap_i_cluster_r6_c7/grid_clk -location {9105.911 1282.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t67 -new_net_name level0_tap_b_t67_net -pins i_grid_clusters_wrap_i_cluster_r7_c7/grid_clk -location {9132.911 1293.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t00 -new_net_name level0_tap_a_t00_net -pins i_grid_tcu_col_i_grid_tcu_cluster_r0_c0/grid_clk -location {612.265 8045.9}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t00 -new_net_name level0_tap_b_t00_net -pins i_grid_tcu_col_i_grid_tcu_cluster_r1_c0/grid_clk -location {639.265 8056.9}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t01 -new_net_name level0_tap_a_t01_net -pins i_grid_clusters_wrap_i_cluster_r0_c1/grid_clk -location {1807.403 8055.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t01 -new_net_name level0_tap_b_t01_net -pins i_grid_clusters_wrap_i_cluster_r1_c1/grid_clk -location {1834.403 8066.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t02 -new_net_name level0_tap_a_t02_net -pins i_grid_clusters_wrap_i_cluster_r0_c2/grid_clk -location {3028.343 8055.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t02 -new_net_name level0_tap_b_t02_net -pins i_grid_clusters_wrap_i_cluster_r1_c2/grid_clk -location {3055.343 8066.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t20 -new_net_name level0_tap_a_t20_net -pins i_grid_tcu_col_i_grid_tcu_cluster_r2_c0/grid_clk -location {612.265 5787.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t20 -new_net_name level0_tap_b_t20_net -pins i_grid_tcu_col_i_grid_tcu_cluster_r3_c0/grid_clk -location {639.265 5798.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t03 -new_net_name level0_tap_a_t03_net -pins i_grid_clusters_wrap_i_cluster_r0_c3/grid_clk -location {4222.151 8055.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t03 -new_net_name level0_tap_b_t03_net -pins i_grid_clusters_wrap_i_cluster_r1_c3/grid_clk -location {4249.151 8066.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t21 -new_net_name level0_tap_a_t21_net -pins i_grid_clusters_wrap_i_cluster_r2_c1/grid_clk -location {1807.403 5798.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t21 -new_net_name level0_tap_b_t21_net -pins i_grid_clusters_wrap_i_cluster_r3_c1/grid_clk -location {1834.403 5809.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t40 -new_net_name level0_tap_a_t40_net -pins i_grid_tcu_col_i_grid_tcu_cluster_r4_c0/grid_clk -location {612.265 3530.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t40 -new_net_name level0_tap_b_t40_net -pins i_grid_tcu_col_i_grid_tcu_cluster_r5_c0/grid_clk -location {639.265 3541.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t04 -new_net_name level0_tap_a_t04_net -pins i_grid_clusters_wrap_i_cluster_r0_c4/grid_clk -location {5497.355 8055.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t04 -new_net_name level0_tap_b_t04_net -pins i_grid_clusters_wrap_i_cluster_r1_c4/grid_clk -location {5524.355 8066.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t22 -new_net_name level0_tap_a_t22_net -pins i_grid_clusters_wrap_i_cluster_r2_c2/grid_clk -location {3028.343 5798.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t22 -new_net_name level0_tap_b_t22_net -pins i_grid_clusters_wrap_i_cluster_r3_c2/grid_clk -location {3055.343 5809.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t41 -new_net_name level0_tap_a_t41_net -pins i_grid_clusters_wrap_i_cluster_r4_c1/grid_clk -location {1807.403 3540.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t41 -new_net_name level0_tap_b_t41_net -pins i_grid_clusters_wrap_i_cluster_r5_c1/grid_clk -location {1834.403 3551.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t05 -new_net_name level0_tap_a_t05_net -pins i_grid_clusters_wrap_i_cluster_r0_c5/grid_clk -location {6691.163 8055.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t05 -new_net_name level0_tap_b_t05_net -pins i_grid_clusters_wrap_i_cluster_r1_c5/grid_clk -location {6718.163 8066.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t23 -new_net_name level0_tap_a_t23_net -pins i_grid_clusters_wrap_i_cluster_r2_c3/grid_clk -location {4222.151 5798.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t23 -new_net_name level0_tap_b_t23_net -pins i_grid_clusters_wrap_i_cluster_r3_c3/grid_clk -location {4249.151 5809.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t60 -new_net_name level0_tap_a_t60_net -pins i_grid_tcu_col_i_grid_tcu_cluster_r6_c0/grid_clk -location {772.397 1285.6335}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t60 -new_net_name level0_tap_b_t60_net -pins i_grid_tcu_col_i_grid_ecore_cluster_r7_c0/grid_clk -location {799.397 1296.6335}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t42 -new_net_name level0_tap_a_t42_net -pins i_grid_clusters_wrap_i_cluster_r4_c2/grid_clk -location {3028.343 3540.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t42 -new_net_name level0_tap_b_t42_net -pins i_grid_clusters_wrap_i_cluster_r5_c2/grid_clk -location {3055.343 3551.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t24 -new_net_name level0_tap_a_t24_net -pins i_grid_clusters_wrap_i_cluster_r2_c4/grid_clk -location {5497.355 5798.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t24 -new_net_name level0_tap_b_t24_net -pins i_grid_clusters_wrap_i_cluster_r3_c4/grid_clk -location {5524.355 5809.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t06 -new_net_name level0_tap_a_t06_net -pins i_grid_clusters_wrap_i_cluster_r0_c6/grid_clk -location {7912.103 8055.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t06 -new_net_name level0_tap_b_t06_net -pins i_grid_clusters_wrap_i_cluster_r1_c6/grid_clk -location {7939.103 8066.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t61 -new_net_name level0_tap_a_t61_net -pins i_grid_clusters_wrap_i_cluster_r6_c1/grid_clk -location {1807.403 1282.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t61 -new_net_name level0_tap_b_t61_net -pins i_grid_clusters_wrap_i_cluster_r7_c1/grid_clk -location {1834.403 1293.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t43 -new_net_name level0_tap_a_t43_net -pins i_grid_clusters_wrap_i_cluster_r4_c3/grid_clk -location {4222.151 3540.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t43 -new_net_name level0_tap_b_t43_net -pins i_grid_clusters_wrap_i_cluster_r5_c3/grid_clk -location {4249.151 3551.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t25 -new_net_name level0_tap_a_t25_net -pins i_grid_clusters_wrap_i_cluster_r2_c5/grid_clk -location {6691.163 5798.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t25 -new_net_name level0_tap_b_t25_net -pins i_grid_clusters_wrap_i_cluster_r3_c5/grid_clk -location {6718.163 5809.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t07 -new_net_name level0_tap_a_t07_net -pins i_grid_clusters_wrap_i_cluster_r0_c7/grid_clk -location {9105.911 8055.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t07 -new_net_name level0_tap_b_t07_net -pins i_grid_clusters_wrap_i_cluster_r1_c7/grid_clk -location {9132.911 8066.98}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t62 -new_net_name level0_tap_a_t62_net -pins i_grid_clusters_wrap_i_cluster_r6_c2/grid_clk -location {3028.343 1282.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t62 -new_net_name level0_tap_b_t62_net -pins i_grid_clusters_wrap_i_cluster_r7_c2/grid_clk -location {3055.343 1293.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t44 -new_net_name level0_tap_a_t44_net -pins i_grid_clusters_wrap_i_cluster_r4_c4/grid_clk -location {5497.355 3540.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t44 -new_net_name level0_tap_b_t44_net -pins i_grid_clusters_wrap_i_cluster_r5_c4/grid_clk -location {5524.355 3551.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t26 -new_net_name level0_tap_a_t26_net -pins i_grid_clusters_wrap_i_cluster_r2_c6/grid_clk -location {7912.103 5798.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t26 -new_net_name level0_tap_b_t26_net -pins i_grid_clusters_wrap_i_cluster_r3_c6/grid_clk -location {7939.103 5809.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t63 -new_net_name level0_tap_a_t63_net -pins i_grid_clusters_wrap_i_cluster_r6_c3/grid_clk -location {4222.151 1282.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t63 -new_net_name level0_tap_b_t63_net -pins i_grid_clusters_wrap_i_cluster_r7_c3/grid_clk -location {4249.151 1293.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t45 -new_net_name level0_tap_a_t45_net -pins i_grid_clusters_wrap_i_cluster_r4_c5/grid_clk -location {6691.163 3540.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t45 -new_net_name level0_tap_b_t45_net -pins i_grid_clusters_wrap_i_cluster_r5_c5/grid_clk -location {6718.163 3551.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t27 -new_net_name level0_tap_a_t27_net -pins i_grid_clusters_wrap_i_cluster_r2_c7/grid_clk -location {9105.911 5798.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t27 -new_net_name level0_tap_b_t27_net -pins i_grid_clusters_wrap_i_cluster_r3_c7/grid_clk -location {9132.911 5809.06}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t64 -new_net_name level0_tap_a_t64_net -pins i_grid_clusters_wrap_i_cluster_r6_c4/grid_clk -location {5497.355 1282.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t64 -new_net_name level0_tap_b_t64_net -pins i_grid_clusters_wrap_i_cluster_r7_c4/grid_clk -location {5524.355 1293.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t46 -new_net_name level0_tap_a_t46_net -pins i_grid_clusters_wrap_i_cluster_r4_c6/grid_clk -location {7912.103 3540.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t46 -new_net_name level0_tap_b_t46_net -pins i_grid_clusters_wrap_i_cluster_r5_c6/grid_clk -location {7939.103 3551.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t65 -new_net_name level0_tap_a_t65_net -pins i_grid_clusters_wrap_i_cluster_r6_c5/grid_clk -location {6691.163 1282.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t65 -new_net_name level0_tap_b_t65_net -pins i_grid_clusters_wrap_i_cluster_r7_c5/grid_clk -location {6718.163 1293.22}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_a_t47 -new_net_name level0_tap_a_t47_net -pins i_grid_clusters_wrap_i_cluster_r4_c7/grid_clk -location {9105.911 3540.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level0_tap_b_t47 -new_net_name level0_tap_b_t47_net -pins i_grid_clusters_wrap_i_cluster_r5_c7/grid_clk -location {9132.911 3551.14}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t66 -new_net_name level1_tap_t66_net -pins {level0_tap_b_t66/i level0_tap_a_t66/i level0_tap_b_t67/i level0_tap_a_t67/i} -location {8513.957 1287.195}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t00 -new_net_name level1_tap_t00_net -pins {level0_tap_b_t00/i level0_tap_a_t00/i level0_tap_b_t01/i level0_tap_a_t01/i} -location {1215.449 8058.435}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t02 -new_net_name level1_tap_t02_net -pins {level0_tap_b_t02/i level0_tap_a_t02/i level0_tap_b_t03/i level0_tap_a_t03/i} -location {3643.763 8060.955}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t20 -new_net_name level1_tap_t20_net -pins {level0_tap_b_t20/i level0_tap_a_t20/i level0_tap_b_t21/i level0_tap_a_t21/i} -location {1215.449 5797.995}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t04 -new_net_name level1_tap_t04_net -pins {level0_tap_b_t04/i level0_tap_a_t04/i level0_tap_b_t05/i level0_tap_a_t05/i} -location {6105.992 8060.955}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t22 -new_net_name level1_tap_t22_net -pins {level0_tap_b_t22/i level0_tap_a_t22/i level0_tap_b_t23/i level0_tap_a_t23/i} -location {3643.763 5797.995}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t40 -new_net_name level1_tap_t40_net -pins {level0_tap_b_t40/i level0_tap_a_t40/i level0_tap_b_t41/i level0_tap_a_t41/i} -location {1229.015 3542.595}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t60 -new_net_name level1_tap_t60_net -pins {level0_tap_b_t60/i level0_tap_a_t60/i level0_tap_b_t61/i level0_tap_a_t61/i} -location {1296.845 1287.195}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t06 -new_net_name level1_tap_t06_net -pins {level0_tap_b_t06/i level0_tap_a_t06/i level0_tap_b_t07/i level0_tap_a_t07/i} -location {8513.957 8060.955}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t24 -new_net_name level1_tap_t24_net -pins {level0_tap_b_t24/i level0_tap_a_t24/i level0_tap_b_t25/i level0_tap_a_t25/i} -location {6105.992 5797.995}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t42 -new_net_name level1_tap_t42_net -pins {level0_tap_b_t42/i level0_tap_a_t42/i level0_tap_b_t43/i level0_tap_a_t43/i} -location {3664.112 3542.595}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t62 -new_net_name level1_tap_t62_net -pins {level0_tap_b_t62/i level0_tap_a_t62/i level0_tap_b_t63/i level0_tap_a_t63/i} -location {3643.763 1287.195}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t26 -new_net_name level1_tap_t26_net -pins {level0_tap_b_t26/i level0_tap_a_t26/i level0_tap_b_t27/i level0_tap_a_t27/i} -location {8513.957 5803.035}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t44 -new_net_name level1_tap_t44_net -pins {level0_tap_b_t44/i level0_tap_a_t44/i level0_tap_b_t45/i level0_tap_a_t45/i} -location {6112.775 3545.115}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t64 -new_net_name level1_tap_t64_net -pins {level0_tap_b_t64/i level0_tap_a_t64/i level0_tap_b_t65/i level0_tap_a_t65/i} -location {6105.992 1287.195}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level1_tap_t46 -new_net_name level1_tap_t46_net -pins {level0_tap_b_t46/i level0_tap_a_t46/i level0_tap_b_t47/i level0_tap_a_t47/i} -location {8513.957 3545.115}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_a_t44 -new_net_name level2_tap_a_t44_net -pins level1_tap_t44/i -location {7293.083 3539.615}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_b_t44 -new_net_name level2_tap_b_t44_net -pins level1_tap_t46/i -location {7320.083 3550.615}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_a_t40 -new_net_name level2_tap_a_t40_net -pins level1_tap_t40/i -location {2436.455 3539.615}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_b_t40 -new_net_name level2_tap_b_t40_net -pins level1_tap_t42/i -location {2463.455 3550.615}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_a_t04 -new_net_name level2_tap_a_t04_net -pins level1_tap_t04/i -location {7306.649 8055.455}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_b_t04 -new_net_name level2_tap_b_t04_net -pins level1_tap_t06/i -location {7333.649 8066.455}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_a_t00 -new_net_name level2_tap_a_t00_net -pins level1_tap_t00/i -location {2409.323 8055.455}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_b_t00 -new_net_name level2_tap_b_t00_net -pins level1_tap_t02/i -location {2436.323 8066.455}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_a_t64 -new_net_name level2_tap_a_t64_net -pins level1_tap_t64/i -location {7306.649 1281.695}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_b_t64 -new_net_name level2_tap_b_t64_net -pins level1_tap_t66/i -location {7333.649 1292.695}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_a_t60 -new_net_name level2_tap_a_t60_net -pins level1_tap_t60/i -location {2463.587 1281.695}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_b_t60 -new_net_name level2_tap_b_t60_net -pins level1_tap_t62/i -location {2490.587 1292.695}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_a_t24 -new_net_name level2_tap_a_t24_net -pins level1_tap_t24/i -location {7293.083 5797.535}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_b_t24 -new_net_name level2_tap_b_t24_net -pins level1_tap_t26/i -location {7320.083 5808.535}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_a_t20 -new_net_name level2_tap_a_t20_net -pins level1_tap_t20/i -location {2409.323 5792.495}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level2_tap_b_t20 -new_net_name level2_tap_b_t20_net -pins level1_tap_t22/i -location {2436.323 5803.495}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level3_tap_a_t44 -new_net_name level3_tap_a_t44_net -pins {level2_tap_b_t44/i level2_tap_a_t44/i} -location {7299.866 2410.655}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level3_tap_b_t44 -new_net_name level3_tap_b_t44_net -pins {level2_tap_b_t64/i level2_tap_a_t64/i} -location {7326.866 2421.655}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level3_tap_a_t40 -new_net_name level3_tap_a_t40_net -pins {level2_tap_b_t40/i level2_tap_a_t40/i} -location {2463.587 2405.615}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level3_tap_b_t40 -new_net_name level3_tap_b_t40_net -pins {level2_tap_b_t60/i level2_tap_a_t60/i} -location {2490.587 2416.615}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level3_tap_a_t04 -new_net_name level3_tap_a_t04_net -pins {level2_tap_b_t04/i level2_tap_a_t04/i} -location {7306.649 6926.495}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level3_tap_b_t04 -new_net_name level3_tap_b_t04_net -pins {level2_tap_b_t24/i level2_tap_a_t24/i} -location {7333.649 6937.495}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level3_tap_a_t00 -new_net_name level3_tap_a_t00_net -pins {level2_tap_b_t00/i level2_tap_a_t00/i} -location {2422.889 6921.455}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level3_tap_b_t00 -new_net_name level3_tap_b_t00_net -pins {level2_tap_b_t20/i level2_tap_a_t20/i} -location {2449.889 6932.455}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level4_tap_a_t40 -new_net_name level4_tap_a_t40_net -pins {level3_tap_b_t40/i level3_tap_a_t40/i} -location {4885.118 2405.615}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level4_tap_b_t40 -new_net_name level4_tap_b_t40_net -pins {level3_tap_b_t44/i level3_tap_a_t44/i} -location {4912.118 2416.615}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level4_tap_a_t00 -new_net_name level4_tap_a_t00_net -pins {level3_tap_b_t00/i level3_tap_a_t00/i} -location {4871.552 6923.975}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level4_tap_b_t00 -new_net_name level4_tap_b_t00_net -pins {level3_tap_b_t04/i level3_tap_a_t04/i} -location {4898.552 6934.975}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_west_clock_tap_ck20 -new_net_name level_west_clock_tap_ck20_net -pins {i_grid_quad_west_filler_i_grid_quad_west_filler_r4/grid_clk i_grid_quad_west_filler_i_grid_quad_west_filler_r5/grid_clk} -location {19.285 3525.123}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_west_clock_tap_ck30 -new_net_name level_west_clock_tap_ck30_net -pins i_grid_quad_west_filler_i_grid_quad_west_filler_r6/grid_clk -location {19.285 1831.683}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_west_clock_tap_ck00 -new_net_name level_west_clock_tap_ck00_net -pins {i_grid_quad_west_filler_i_grid_quad_west_filler_r0/grid_clk i_grid_quad_west_filler_i_grid_quad_west_filler_r1/grid_clk} -location {19.285 8040.963}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_west_clock_tap_ck10 -new_net_name level_west_clock_tap_ck10_net -pins {i_grid_quad_west_filler_i_grid_quad_west_filler_r2/grid_clk i_grid_quad_west_filler_i_grid_quad_west_filler_r3/grid_clk} -location {19.285 5783.043}
connect_hpin - -net level_west_clock_tap_ck00_net -pin_name {grid_clk_to_west[0]}
connect_pin -inst level_west_clock_tap_ck00 -pin i -net level0_tap_b_t00_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_west_clock_rpt_tap_0 -new_net_name level_west_clock_rpt_tap_0_net -pins level_west_clock_tap_ck00/i -location {622.111 8060.535}
connect_hpin - -net level_west_clock_tap_ck10_net -pin_name {grid_clk_to_west[1]}
connect_pin -inst level_west_clock_tap_ck10 -pin i -net level0_tap_b_t20_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_west_clock_rpt_tap_1 -new_net_name level_west_clock_rpt_tap_1_net -pins level_west_clock_tap_ck10/i -location {622.111 5802.615}
connect_hpin - -net level_west_clock_tap_ck20_net -pin_name {grid_clk_to_west[2]}
connect_pin -inst level_west_clock_tap_ck20 -pin i -net level0_tap_b_t40_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_west_clock_rpt_tap_2 -new_net_name level_west_clock_rpt_tap_2_net -pins level_west_clock_tap_ck20/i -location {622.111 3544.695}
place_inst level_west_clock_tap_ck30 {4.5135 1286.67} r0
connect_hpin - -net level_west_clock_tap_ck30_net -pin_name {grid_clk_to_west[3]}
connect_pin -inst level_west_clock_tap_ck30 -pin i -net level0_tap_b_t60_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_west_clock_rpt_tap_3 -new_net_name level_west_clock_rpt_tap_3_net -pins level_west_clock_tap_ck30/i -location {784.903 1286.775}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_east_clock_tap_ck20 -new_net_name level_east_clock_tap_ck20_net -pins {i_grid_quad_east_filler_i_grid_quad_east_filler_r4/grid_clk i_grid_quad_east_filler_i_grid_quad_east_filler_r5/grid_clk} -location {9790.13 3492.153}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_east_clock_tap_ck30 -new_net_name level_east_clock_tap_ck30_net -pins {i_grid_quad_east_filler_i_grid_quad_east_filler_r6/grid_clk i_grid_quad_east_filler_i_grid_quad_east_filler_r7/grid_clk} -location {9792.79 1200.8845}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_east_clock_tap_ck00 -new_net_name level_east_clock_tap_ck00_net -pins {i_grid_quad_east_filler_i_grid_quad_east_filler_r0/grid_clk i_grid_quad_east_filler_i_grid_quad_east_filler_r1/grid_clk} -location {9790.263 8010.9085}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_east_clock_tap_ck10 -new_net_name level_east_clock_tap_ck10_net -pins {i_grid_quad_east_filler_i_grid_quad_east_filler_r2/grid_clk i_grid_quad_east_filler_i_grid_quad_east_filler_r3/grid_clk} -location {9790.13 5750.073}
connect_hpin - -net level_east_clock_tap_ck00_net -pin_name {grid_clk_to_east[0]}
connect_pin -inst level_east_clock_tap_ck00 -pin i -net level0_tap_b_t07_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_east_clock_rpt_tap_0 -new_net_name level_east_clock_rpt_tap_0_net -pins level_east_clock_tap_ck00/i -location {9134.427 8060.535}
connect_hpin - -net level_east_clock_tap_ck10_net -pin_name {grid_clk_to_east[1]}
connect_pin -inst level_east_clock_tap_ck10 -pin i -net level0_tap_b_t27_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_east_clock_rpt_tap_1 -new_net_name level_east_clock_rpt_tap_1_net -pins level_east_clock_tap_ck10/i -location {9134.427 5802.615}
connect_hpin - -net level_east_clock_tap_ck20_net -pin_name {grid_clk_to_east[2]}
connect_pin -inst level_east_clock_tap_ck20 -pin i -net level0_tap_b_t47_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_east_clock_rpt_tap_2 -new_net_name level_east_clock_rpt_tap_2_net -pins level_east_clock_tap_ck20/i -location {9134.427 3544.695}
connect_hpin - -net level_east_clock_tap_ck30_net -pin_name {grid_clk_to_east[3]}
connect_pin -inst level_east_clock_tap_ck30 -pin i -net level0_tap_b_t67_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_east_clock_rpt_tap_3 -new_net_name level_east_clock_rpt_tap_3_net -pins level_east_clock_tap_ck30/i -location {9134.427 1286.775}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_north_clock_tap_ck02 -new_net_name level_north_clock_tap_ck02_net -pins {i_grid_quad_north_filler_i_grid_quad_north_filler_c4/grid_clk i_grid_quad_north_filler_i_grid_quad_north_filler_c5/grid_clk} -location {6414.989 9210.383}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_north_clock_tap_ck03 -new_net_name level_north_clock_tap_ck03_net -pins {i_grid_quad_north_filler_i_grid_quad_north_filler_c6/grid_clk i_grid_quad_north_filler_i_grid_quad_north_filler_c7/grid_clk} -location {8829.737 9210.383}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_north_clock_tap_ck00 -new_net_name level_north_clock_tap_ck00_net -pins {i_grid_quad_north_filler_i_grid_quad_north_filler_c0/grid_clk i_grid_quad_north_filler_i_grid_quad_north_filler_c1/grid_clk} -location {1531.229 9210.383}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_north_clock_tap_ck01 -new_net_name level_north_clock_tap_ck01_net -pins {i_grid_quad_north_filler_i_grid_quad_north_filler_c2/grid_clk i_grid_quad_north_filler_i_grid_quad_north_filler_c3/grid_clk} -location {3945.977 9210.383}
connect_hpin - -net level_north_clock_tap_ck00_net -pin_name {grid_clk_to_north[0]}
connect_pin -inst level_north_clock_tap_ck00 -pin i -net level1_tap_t00_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_north_clock_rpt_tap_0 -new_net_name level_north_clock_rpt_tap_0_net -pins level_north_clock_tap_ck00/i -location {1206.883 8063.535}
eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name level_north_clock_rpt_tap_0_0 -new_net_name level_north_clock_rpt_tap_0_0_net -pins level_north_clock_rpt_tap_0/i -location {1206.883 8063.535}
connect_hpin - -net level_north_clock_tap_ck01_net -pin_name {grid_clk_to_north[1]}
connect_pin -inst level_north_clock_tap_ck01 -pin i -net level1_tap_t02_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_north_clock_rpt_tap_1 -new_net_name level_north_clock_rpt_tap_1_net -pins level_north_clock_tap_ck01/i -location {3648.763 8063.535}
eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name level_north_clock_rpt_tap_1_1 -new_net_name level_north_clock_rpt_tap_1_1_net -pins level_north_clock_rpt_tap_1/i -location {3648.763 8063.535}
connect_hpin - -net level_north_clock_tap_ck02_net -pin_name {grid_clk_to_north[2]}
connect_pin -inst level_north_clock_tap_ck02 -pin i -net level1_tap_t04_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_north_clock_rpt_tap_2 -new_net_name level_north_clock_rpt_tap_2_net -pins level_north_clock_tap_ck02/i -location {6117.775 8063.535}
eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name level_north_clock_rpt_tap_2_2 -new_net_name level_north_clock_rpt_tap_2_2_net -pins level_north_clock_rpt_tap_2/i -location {6117.775 8063.535}
connect_hpin - -net level_north_clock_tap_ck03_net -pin_name {grid_clk_to_north[3]}
connect_pin -inst level_north_clock_tap_ck03 -pin i -net level1_tap_t06_net
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_north_clock_rpt_tap_3 -new_net_name level_north_clock_rpt_tap_3_net -pins level_north_clock_tap_ck03/i -location {8532.523 8063.535}
eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name level_north_clock_rpt_tap_3_3 -new_net_name level_north_clock_rpt_tap_3_3_net -pins level_north_clock_rpt_tap_3/i -location {8532.523 8063.535}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_south_clock_tap_ck02 -new_net_name level_south_clock_tap_ck02_net -pins {i_grid_quad_south_filler_i_grid_quad_south_filler_c4/grid_clk i_grid_quad_south_filler_i_grid_quad_south_filler_c5/grid_clk} -location {6423.501 63.1295}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_south_clock_tap_ck03 -new_net_name level_south_clock_tap_ck03_net -pins {i_grid_quad_south_filler_i_grid_quad_south_filler_c6/grid_clk i_grid_quad_south_filler_i_grid_quad_south_filler_c7/grid_clk} -location {8838.249 63.1295}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_south_clock_tap_ck00 -new_net_name level_south_clock_tap_ck00_net -pins {i_grid_quad_south_filler_i_grid_quad_south_filler_c0/grid_clk i_grid_quad_south_filler_i_grid_quad_south_filler_c1/grid_clk} -location {1541.869 63.28525}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_south_clock_tap_ck01 -new_net_name level_south_clock_tap_ck01_net -pins {i_grid_quad_south_filler_i_grid_quad_south_filler_c2/grid_clk i_grid_quad_south_filler_i_grid_quad_south_filler_c3/grid_clk} -location {3954.489 63.1295}
connect_pin -inst level_south_clock_tap_ck00 -pin i -net level1_tap_t60_net
connect_pin -inst level_south_clock_tap_ck01 -pin i -net level1_tap_t62_net
connect_pin -inst level_south_clock_tap_ck02 -pin i -net level1_tap_t64_net
connect_pin -inst level_south_clock_tap_ck03 -pin i -net level1_tap_t66_net
connect_hpin - -net level_south_clock_tap_ck00_net -pin_name {grid_clk_to_south[0]}
connect_hpin - -net level_south_clock_tap_ck01_net -pin_name {grid_clk_to_south[1]}
connect_hpin - -net level_south_clock_tap_ck02_net -pin_name {grid_clk_to_south[2]}
connect_hpin - -net level_south_clock_tap_ck03_net -pin_name {grid_clk_to_south[3]}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_south_clock_rpt_tap_0 -new_net_name level_south_clock_rpt_tap_0_net -pins level_south_clock_tap_ck00/i -location {1554.599 1286.775}
eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name level_south_clock_rpt_tap_0_0 -new_net_name level_south_clock_rpt_tap_0_0_net -pins level_south_clock_tap_ck00/i -location {1554.599 1286.775}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_south_clock_rpt_tap_1 -new_net_name level_south_clock_rpt_tap_1_net -pins level_south_clock_tap_ck01/i -location {3942.215 1286.775}
eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name level_south_clock_rpt_tap_1_0 -new_net_name level_south_clock_rpt_tap_1_0_net -pins level_south_clock_tap_ck01/i -location {3942.215 1286.775}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_south_clock_rpt_tap_2 -new_net_name level_south_clock_rpt_tap_2_net -pins level_south_clock_tap_ck02/i -location {6411.227 1286.775}
eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name level_south_clock_rpt_tap_2_0 -new_net_name level_south_clock_rpt_tap_2_0_net -pins level_south_clock_tap_ck02/i -location {6411.227 1286.775}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_south_clock_rpt_tap_3 -new_net_name level_south_clock_rpt_tap_3_net -pins level_south_clock_tap_ck03/i -location {8853.107 1286.775}
eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name level_south_clock_rpt_tap_3_0 -new_net_name level_south_clock_rpt_tap_3_0_net -pins level_south_clock_tap_ck03/i -location {8853.107 1286.775}
connect_pin -inst i_grid_quad_south_filler_i_grid_quad_south_filler_east -pin grid_clk -net {grid_clk_to_south[3]}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name level_south_east_clock_rpt_tap_0 -new_net_name level_south_east_clock_rpt_tap_0_net -pins i_grid_quad_south_filler_i_grid_quad_south_filler_east/grid_clk -location {8858.107 150.735}
eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name level_south_east_clock_rpt_tap_0_0 -new_net_name level_south_east_clock_rpt_tap_0_0_net -pins level_south_east_clock_rpt_tap_0/i -location {8858.107 150.735}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name tree_source_a_s0 -new_net_name tree_source_a_s0_net -pins {level4_tap_b_t00/i level4_tap_a_t00/i} -location {4885.118 4663.535}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name tree_source_b_s0 -new_net_name tree_source_b_s0_net -pins {level4_tap_b_t40/i level4_tap_a_t40/i} -location {4912.118 4674.535}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_level4_tap_b_t00_net_2 -new_net_name levelx_tap_break_long_nets_level4_tap_b_t00_net_2_net -pins level4_tap_b_t00/o -location {7285.289 6931.575}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_level4_tap_b_t00_net_1 -new_net_name levelx_tap_break_long_nets_level4_tap_b_t00_net_1_net -pins level4_tap_b_t00/o -location {6088.562 6931.575}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_level4_tap_a_t00_net_2 -new_net_name levelx_tap_break_long_nets_level4_tap_a_t00_net_2_net -pins level4_tap_a_t00/o -location {2480.14712 6921.495}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_level4_tap_a_t00_net_1 -new_net_name levelx_tap_break_long_nets_level4_tap_a_t00_net_1_net -pins level4_tap_a_t00/o -location {3685.99106 6921.495}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_level4_tap_b_t40_net_2 -new_net_name levelx_tap_break_long_nets_level4_tap_b_t40_net_2_net -pins level4_tap_b_t40/o -location {7263.35828 2415.735}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_level4_tap_b_t40_net_1 -new_net_name levelx_tap_break_long_nets_level4_tap_b_t40_net_1_net -pins level4_tap_b_t40/o -location {6091.16264 2415.735}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_level4_tap_a_t40_net_2 -new_net_name levelx_tap_break_long_nets_level4_tap_a_t40_net_2_net -pins level4_tap_a_t40/o -location {2533.32584 2405.655}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_level4_tap_a_t40_net_1 -new_net_name levelx_tap_break_long_nets_level4_tap_a_t40_net_1_net -pins level4_tap_a_t40/o -location {3712.58042 2405.655}
eco_update_cell -insts levelx_tap_break_long_nets_level4_tap_a_t40_net_2 -cells F6UNAA_BUFAX12
eco_update_cell -insts levelx_tap_break_long_nets_level4_tap_b_t40_net_2 -cells F6UNAA_BUFAX12
eco_update_cell -insts levelx_tap_break_long_nets_level4_tap_a_t00_net_2 -cells F6UNAA_BUFAX12
eco_update_cell -insts levelx_tap_break_long_nets_level4_tap_b_t00_net_2 -cells F6UNAA_BUFAX12
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_n_1_4 -new_net_name levelx_tap_break_long_nets_n_1_4_net -pins levelx_tap_clock_port/o -location {4891.835 4584.14208}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_n_1_3 -new_net_name levelx_tap_break_long_nets_n_1_3_net -pins levelx_tap_clock_port/o -location {4891.835 3439.76031}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_n_1_2 -new_net_name levelx_tap_break_long_nets_n_1_2_net -pins levelx_tap_clock_port/o -location {4891.835 2295.37854}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_n_1_1 -new_net_name levelx_tap_break_long_nets_n_1_1_net -pins levelx_tap_clock_port/o -location {4891.835 1150.99677}
eco_update_cell -insts levelx_tap_break_long_nets_n_1_4 -cells F6UNAA_BUFAX12
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_tree_source_b_s0_net_2 -new_net_name levelx_tap_break_long_nets_tree_source_b_s0_net_2_net -pins tree_source_b_s0/o -location {4918.967 2442.86952}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_tree_source_b_s0_net_1 -new_net_name levelx_tap_break_long_nets_tree_source_b_s0_net_1_net -pins tree_source_b_s0/o -location {4918.967 3553.22226}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_tree_source_a_s0_net_2 -new_net_name levelx_tap_break_long_nets_tree_source_a_s0_net_2_net -pins tree_source_a_s0/o -location {4891.835 6881.6874}
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name levelx_tap_break_long_nets_tree_source_a_s0_net_1 -new_net_name levelx_tap_break_long_nets_tree_source_a_s0_net_1_net -pins tree_source_a_s0/o -location {4891.835 5772.6312}
eco_update_cell -insts levelx_tap_break_long_nets_tree_source_a_s0_net_2 -cells F6UNAA_BUFAX12
eco_update_cell -insts levelx_tap_break_long_nets_tree_source_b_s0_net_2 -cells F6UNAA_BUFAX12

remove_inverters  [get_cells *level* -filter ref_name=~*12*] true


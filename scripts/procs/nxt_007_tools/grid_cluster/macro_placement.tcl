
set macros [get_cells "
i_gmu_cluster*i_gmu_top*i_gmu*i_bin_dlink*bin_dl_0_i_bin_dlink*i_bin*i_800_sdt*i_sdt_mem*ebb__gmu_sdt_1r1w_128x136_i
i_gmu_cluster*i_gmu_top*i_gmu*i_bin_dlink*bin_dl_0_i_bin_dlink*i_bin*i_804_dmem*i_sram*ebb__gmu_dmem_be_1rw_3136x156_i
i_gmu_cluster*i_gmu_top*i_gmu*i_bin_dlink*bin_dl_1_i_bin_dlink*i_bin*i_800_sdt*i_sdt_mem*ebb__gmu_sdt_1r1w_128x136_i
i_gmu_cluster*i_gmu_top*i_gmu*i_bin_dlink*bin_dl_1_i_bin_dlink*i_bin*i_804_dmem*i_sram*ebb__gmu_dmem_be_1rw_3136x156_i
i_gmu_cluster*i_gmu_top*i_gmu*i_gmu_buffers*i_shared_buffer_0*i_shared_mem*ebb__gmu_shared_buffer_1r1w_160x132_i
i_gmu_cluster*i_gmu_top*i_gmu*i_gmu_buffers*i_shared_buffer_1*i_shared_mem*ebb__gmu_shared_buffer_1r1w_160x132_i
"]

set_db $macros .place_status unplaced

set cell_name i_gmu_cluster*i_gmu_top*i_gmu*i_bin_dlink*bin_dl_0_i_bin_dlink*i_bin*i_800_sdt*i_sdt_mem*ebb__gmu_sdt_1r1w_128x136_i
place_inst $cell_name {442.1490 653.5200} R0
create_place_halo -halo_deltas 0.5 0.5 0.5 0.5 -inst $cell_name

set cell_name i_gmu_cluster*i_gmu_top*i_gmu*i_bin_dlink*bin_dl_0_i_bin_dlink*i_bin*i_804_dmem*i_sram*ebb__gmu_dmem_be_1rw_3136x156_i
place_inst $cell_name {8.0370 520.4700} R180
create_place_halo -halo_deltas 0.5 0.5 0.5 0.5 -inst $cell_name

set cell_name i_gmu_cluster*i_gmu_top*i_gmu*i_bin_dlink*bin_dl_1_i_bin_dlink*i_bin*i_800_sdt*i_sdt_mem*ebb__gmu_sdt_1r1w_128x136_i
place_inst $cell_name {8.0370 220.0800} MY
create_place_halo -halo_deltas 0.5 0.5 0.5 0.5 -inst $cell_name

set cell_name i_gmu_cluster*i_gmu_top*i_gmu*i_bin_dlink*bin_dl_1_i_bin_dlink*i_bin*i_804_dmem*i_sram*ebb__gmu_dmem_be_1rw_3136x156_i
place_inst $cell_name {357.7890 220.0800} R0
create_place_halo -halo_deltas 0.5 0.5 0.5 0.5 -inst $cell_name

set cell_name i_gmu_cluster*i_gmu_top*i_gmu*i_gmu_buffers*i_shared_buffer_1*i_shared_mem*ebb__gmu_shared_buffer_1r1w_160x132_i
place_inst $cell_name {8.0370000000 297.3600000000} MY
create_place_halo -halo_deltas 0.5 0.5 0.5 0.5 -inst $cell_name

set cell_name i_gmu_cluster*i_gmu_top*i_gmu*i_gmu_buffers*i_shared_buffer_0*i_shared_mem*ebb__gmu_shared_buffer_1r1w_160x132_i
place_inst $cell_name {451.0980000000 520.5600000000} R0
create_place_halo -halo_deltas 0.5 0.5 0.5 0.5 -inst $cell_name

set_db $macros .place_status fixed

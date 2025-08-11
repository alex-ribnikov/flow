set _DESIGN $DESIGN_NAME
set_db leakage_power_effort                 medium
set_db lp_insert_clock_gating               true
set_db [get_db designs] .lp_clock_gating_max_flops 48

##### elaborate attributes
set_db hdl_preserve_unused_registers false

##### synthesis attributes
set_db delete_unloaded_insts       true
set_db delete_unloaded_seqs        true
set_db optimize_constant_0_flops   false
set_db optimize_constant_1_flops   false
set_db optimize_constant_latches   false
set_db optimize_merge_flops        false
set_db optimize_merge_latches      false
set_db tns_opto                    false
set_db drc_first                   false

set pins_to_balance {
    i_grid_quad_north_filler_i_grid_quad_north_filler_c0/grid_clk 0.249
    i_grid_quad_north_filler_i_grid_quad_north_filler_c1/grid_clk 0.265
    i_grid_quad_north_filler_i_grid_quad_north_filler_c2/grid_clk 0.267
    i_grid_quad_north_filler_i_grid_quad_north_filler_c3/grid_clk 0.302
    i_grid_quad_north_filler_i_grid_quad_north_filler_c4/grid_clk 0.302
    i_grid_quad_north_filler_i_grid_quad_north_filler_c5/grid_clk 0.341
    i_grid_quad_north_filler_i_grid_quad_north_filler_c6/grid_clk 0.343
    i_grid_quad_north_filler_i_grid_quad_north_filler_c7/grid_clk 0.364
    i_grid_quad_south_filler_i_grid_quad_south_filler_c0/grid_clk 0.217 
    i_grid_quad_south_filler_i_grid_quad_south_filler_c1/grid_clk 0.255 
    i_grid_quad_south_filler_i_grid_quad_south_filler_c2/grid_clk 0.257 
    i_grid_quad_south_filler_i_grid_quad_south_filler_c3/grid_clk 0.280 
    i_grid_quad_south_filler_i_grid_quad_south_filler_c4/grid_clk 0.282 
    i_grid_quad_south_filler_i_grid_quad_south_filler_c5/grid_clk 0.310 
    i_grid_quad_south_filler_i_grid_quad_south_filler_c6/grid_clk 0.331 
    i_grid_quad_south_filler_i_grid_quad_south_filler_c7/grid_clk 0.347
    i_grid_quad_west_filler_i_grid_quad_west_filler_r0/grid_clk 0.306
    i_grid_quad_west_filler_i_grid_quad_west_filler_r1/grid_clk 0.308
    i_grid_quad_west_filler_i_grid_quad_west_filler_r2/grid_clk 0.308
    i_grid_quad_west_filler_i_grid_quad_west_filler_r3/grid_clk 0.309
    i_grid_quad_west_filler_i_grid_quad_west_filler_r4/grid_clk 0.308
    i_grid_quad_west_filler_i_grid_quad_west_filler_r5/grid_clk 0.309
    i_grid_quad_west_filler_i_grid_quad_west_filler_r6/grid_clk 0.313
    i_grid_quad_east_filler_i_grid_quad_east_filler_r0/grid_clk 0.168
    i_grid_quad_east_filler_i_grid_quad_east_filler_r1/grid_clk 0.126
    i_grid_quad_east_filler_i_grid_quad_east_filler_r2/grid_clk 0.174
    i_grid_quad_east_filler_i_grid_quad_east_filler_r3/grid_clk 0.126
    i_grid_quad_east_filler_i_grid_quad_east_filler_r4/grid_clk 0.174
    i_grid_quad_east_filler_i_grid_quad_east_filler_r5/grid_clk 0.125
    i_grid_quad_east_filler_i_grid_quad_east_filler_r6/grid_clk 0.175
    i_grid_quad_east_filler_i_grid_quad_east_filler_r7/grid_clk 0.168
}

set lib_cell F6UNAA_CKINVX32

# Set to 20ps
set delay_per_inv_pair 0.02


set fill_buffer_insts {}

foreach {pin_name target_delay} $pins_to_balance {

    ## Calculate number of inverters to insert
    set number_of_invs [expr round($target_delay/$delay_per_inv_pair) * 2]

    # Find current driver
    set pin_obj [get_db pins $pin_name]
    set net_obj [get_db $pin_obj .net]
    set driver_pin [get_db $net_obj .drivers]
    set driver_inst [get_db $driver_pin .inst]
    set driver_input [get_db $driver_inst .pins -if { .direction == in}]

    for { set i 0 } { $i < $number_of_invs } { incr i } {
        set prefix [lindex [split $pin_name "/"] 0]_fill_balance_$i
        eco_add_repeater \
            -cells $lib_cell \
            -name ${prefix} \
            -new_net_name ${prefix}_net \
            -pins [get_db $driver_input .name]  \
            -location [get_db $driver_inst .location]
        
        lappend fill_buffer_insts $prefix

    }
}
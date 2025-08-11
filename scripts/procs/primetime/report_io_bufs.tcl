proc report_io_bufs {} {
    
    set cell_list {
    grid_quad_east_filler_row_0_top     \
    grid_quad_east_filler_row_7_top     \
    grid_quad_east_filler_row_notch_top \
    grid_quad_east_filler_row_top       \
    grid_quad_north_filler_col_top      \
    grid_quad_south_filler_col_0_top    \
    grid_quad_south_filler_col_top      \
    grid_quad_south_filler_east_col_top \
    grid_quad_west_filler_row_top       \
    grid_ecore_cluster \
    }
    
    set inports  [all_inputs ]
    set outports [all_outputs ]
    
    set innets  [get_nets -of $inports  -seg -filter is_clock_network==false]
    set outnets [get_nets -of $outports -seg -filter is_clock_network==false]
    
    set all_incells  [get_cells -of $innets  -filter is_hierarchical==false] 

    set all_outcells [get_cells -of $outnets -filter is_hierarchical==false]
    
    foreach rn $cell_list {
    
        set cell [index_collection [get_cells -filter ref_name==$rn] 0]
        set pins [get_pins -of $cell -filter is_clock_pin==false]
        set nets [get_nets -of $pins -seg]
        set common_innets  [common_collection $nets $innets]
        set common_outnets [common_collection $nets $innets]
        set rcvs [get_cells -of $common_innets -filter is_hierarchical==false]
        set drvs [get_cells -of $common_outnets -filter is_hierarchical==false]
        
    }
    
}

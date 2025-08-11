proc route_in_strt_line { nets } { 

    set nets [get_nets $nets -hier -filter full_name!~*clk&&full_name!~*rst_n&&full_name!~dft_scan_en]
    
    puts "-I- Running route_in_strt_line on [sizeof $nets] nets"

    # Check alignement (location + layer const)    
    set p2p_nets {}
    array unset net_const_arr
    puts "-I- Setting route rule on p2p nets [ory_time::now]"
    set curr 0
    set total [sizeof $nets]
    set dec   [expr int(ceil(0.01*$total))]
    foreach_in_collection net $nets {

#        ory_progress $curr $total
        incr curr

        if { ![llength [set drv [get_db $net .driver_pins]]] } { set drv [get_db $net .driver_ports] }
        if { ![llength [set rcv [get_db $net .load_pins  ]]] } { set rcv [get_db $net .load_ports] }

        if { [llength [concat $drv $rcv]] > 2 } { puts "-W- Net [get_db $net .name] has multiple receivers or noe drv/rcv" ; continue }

        set drv_layer [get_db $drv .layer.route_index]
        set rcv_layer [get_db $rcv .layer.route_index]

        set res [compare_pins $drv $rcv]
        
        if { $res == "true" } {
            if { [expr $curr%$dec] == 0 } { puts "-I- Net [get_db $net .name]: Set layer conatraints"}
            set_route_attributes -nets [get_db $net .name] -top_preferred_routing_layer $drv_layer -bottom_preferred_routing_layer $drv_layer        
            lappend net_const_arr($drv_layer) [get_db $net .name]
            append_to_collection p2p_nets $net            
        } else {
            puts "-W- Net [get_db $net .name]: $res"
        }


    }
    
    # Route
    set_db [get_db $p2p_nets] .dont_touch true
    
    set prev_route_design_with_timing_driven   [get_db   route_design_with_timing_driven  ]
    set prev_route_design_with_si_driven       [get_db   route_design_with_si_driven      ]
    set prev_route_design_detail_end_iteration [get_db   route_design_detail_end_iteration]
    set_db   route_design_with_timing_driven   false
    set_db   route_design_with_si_driven       false
    set_db   route_design_detail_end_iteration 5

    so $p2p_nets
    route_global_detail -selected 
    
    set_db   route_design_with_timing_driven    $prev_route_design_with_timing_driven  
    set_db   route_design_with_si_driven        $prev_route_design_with_si_driven      
    set_db   route_design_detail_end_iteration  $prev_route_design_detail_end_iteration
 
}

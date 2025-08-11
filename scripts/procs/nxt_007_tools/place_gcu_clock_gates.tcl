proc ory_place_gcu_clock_gates { top_bbox bottom_bbox } {

    # set top_bbox    [list 0 475 481 950]
    # set bottom_bbox [list 0 0 481 475]
    # set gates [ory_place_gcu_clock_gates $top_bbox $bottom_bbox]

    if { [regexp "Genus" [get_db program_name]] == 1 } {
        # Expect def from FP or something
        # read_def .....
        return
    }
    
    set number_of_L0_gates 2
    set number_of_L1_gates [list 8 3] ; # 24 with x y detail
    
    set L0_gates [list i_gcc_aon/u_car_ep_int_grid_clk/gen_clnt_0_u_clk_gate[0]/u_clk_gate/i_clk_gate i_gcc_aon/u_car_ep_int_grid_clk/gen_clnt_0_u_clk_gate[1]/u_clk_gate/i_clk_gate]
    set L1_gates [list ]
    set all_gates {}
    
    lassign $top_bbox    xlu ylu xhu yhu
    lassign $bottom_bbox xld yld xhd yhd    

    set dxu [expr 1.0*($xhu - $xlu)/[lindex $number_of_L1_gates 0]]
    set dxd [expr 1.0*($xhd - $xld)/[lindex $number_of_L1_gates 0]]    
    set dyu [expr 1.0*($yhu - $ylu)/[lindex $number_of_L1_gates 1]]        
    set dyd [expr 1.0*($yhd - $yld)/[lindex $number_of_L1_gates 1]]        
    
    set x0u  [expr $dxu/2 + $xlu]
    set x0d  [expr $dxd/2 + $xld]    
    set y0u  [expr $ylu - $dyu/2]        
    set y0d  [expr $yld - $dyd/2]            
   
    # Populize L1 Gates and assign location
    

    for { set i 0 } { $i < [lindex $number_of_L1_gates 0] } { incr i } {
    
        # Up        
        for { set j 0 } { $j < [lindex $number_of_L1_gates 1] } { incr j } {
            set gate_name i_gcu_top/gcu/GCU_COL_${i}_gcu_col/genblk1_${j}_genblk1_u_leb_clk_gate/i_clk_gate
            set loc_arr($i,$j) [list [list [format %.2f [expr $i*$dxu + $x0u]] [format %.2f [expr $y0u - $j*$dyu]] ] $gate_name]
            place_inst $gate_name [lindex $loc_arr($i,$j) 0]
            set_db [get_db insts $gate_name] .place_status soft_fixed
            lappend all_gates $gate_name
        }
    
        # Down
        for { set j 0 } { $j < [expr 2 * [lindex $number_of_L1_gates 1]] } { incr j } {
            set gate_name i_gcu_top/gcu/GCU_COL_${i}_gcu_col/genblk1_${j}_genblk1_u_leb_clk_gate/i_clk_gate
            set loc_arr($i,$j) [list [list [format %.2f [expr $i*$dxu + $x0u]] [format %.2f [expr $y0u - ($j-[lindex $number_of_L1_gates 1])*$dyu]] ] $gate_name]                    
            place_inst $gate_name [lindex $loc_arr($i,$j) 0]  
            set_db [get_db insts $gate_name] .place_status soft_fixed                      
            lappend all_gates $gate_name            
        }        
        
    }
    
    # Up
    set gate_name i_gcc_aon/u_car_ep_int_grid_clk/gen_clnt_0_u_clk_gate[0]/u_clk_gate/i_clk_gate
    set loc [list [expr 1.0*($xlu + $xhu)/2] [expr 1.0*($ylu + $yhu)/2]]
    place_inst $gate_name $loc
    set_db [get_db insts $gate_name] .place_status soft_fixed    
    lappend all_gates $gate_name                

    # Down
    set gate_name i_gcc_aon/u_car_ep_int_grid_clk/gen_clnt_0_u_clk_gate[1]/u_clk_gate/i_clk_gate
    set loc [list [expr 1.0*($xld + $xhd)/2] [expr 1.0*($yld + $yhd)/2]]    
    place_inst $gate_name $loc            
    set_db [get_db insts $gate_name] .place_status soft_fixed  
    lappend all_gates $gate_name  
    
    place_detail -inst [join $all_gates " "]                    
    set_db [get_db insts $all_gates] .place_status fixed

####################################################################################
####################################################################################
#    return $all_gates
####################################################################################
####################################################################################    

    # TODO - this shouldn't be here
    # Update skew group
    # Check that there are not CTS buffers between grid_clk and i_gcc_aon/u_car_ep_int_grid_clk/gen_clnt_0_u_clk_gate[0]/u_clk_gate/i_clk_gate for example
    set ignore_pins [get_db [get_db insts $gates] .pins.name *CP]
    update_skew_group -skew_group grid_clk/func -add_ignore_pins [join $ignore_pins]
    create_skew_group -auto_sinks -name clk_gate_0 -sources i_gcc_aon/u_car_ep_int_grid_clk/gen_clnt_0_u_clk_gate[0]/u_clk_gate/i_clk_gate/Q 
    create_skew_group -auto_sinks -name clk_gate_1 -sources i_gcc_aon/u_car_ep_int_grid_clk/gen_clnt_0_u_clk_gate[1]/u_clk_gate/i_clk_gate/Q     
    
#    set_db pin:i_gcc_aon/u_car_ep_int_grid_clk/gen_clnt_0_u_clk_gate[0]/u_clk_gate/i_clk_gate/CP .cts_sink_type ignore
#    set_db pin:i_gcc_aon/u_car_ep_int_grid_clk/gen_clnt_0_u_clk_gate[1]/u_clk_gate/i_clk_gate/CP .cts_sink_type ignore    
#    create_clock_tree_spec -out_file ${g_design}_user_cts_spec.tcl    
    
    return $all_gates
}











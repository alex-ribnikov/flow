# start_record 

#set_db [get_db nets grid_clk] .dont_touch false
#
#### Route from clock port to center of grid ###
##bring_clock_port_to_center {5968.2495 4353.09}
#
#
#### ADD BUFFER ON CLOCK PORT ###
#set repeater_template F6UNAA_LPDSINVGT5X96
#
#set clock_port [get_db ports grid_clk]
#set clock_port_location [lindex [get_db $clock_port .location] 0]
#set clock_port_rpt_location [list [lindex $clock_port_location 0] [expr [lindex $clock_port_location 1] + 5]]
#
#set_db eco_honor_dont_use false
#set_db eco_update_timing false
#set_db eco_refine_place false
#set_db eco_check_logical_equivalence false
#
## Delete BRCM inserted assign buffers
#delete_inst -inst  assignBuf_*
#
#### PLACE ICG ###
#place_inst i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY [list [lindex $clock_port_location 0] [expr [lindex $clock_port_location 1] + 2]] r0 
##################
#
#eco_add_repeater -cells $repeater_template -name "levelx_tap_clock_port" -new_net_name levelx_tap_clock_port_net -pins i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY/o -location $clock_port_rpt_location
#
#set_db eco_honor_dont_use true
#set_db eco_update_timing true
#set_db eco_refine_place true
#set_db eco_check_logical_equivalence true
#
#set_db place_detail_eco_max_distance 20
#set_db [get_cells i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY] .place_status placed
#place_detail -inst "levelx_tap_clock_port i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY"
#
#
#### SET PADDING TO SUPPER INVERTERS ###
##set h [get_db [get_db base_cells F6UNAA_LPDSINVGT5X96] .bbox.dy]
##set w [get_db [get_db base_cells F6UNAA_LPDSINVGT5X96] .bbox.dx]
##expr $w/[get_db [get_db sites CORE_6] .size.x]
#set_db [get_db base_cells F6UNAA_LPDSINVGT5X96] .bottom_padding 5
#set_db [get_db base_cells F6UNAA_LPDSINVGT5X96] .top_padding    5
#set_db [get_db base_cells F6UNAA_LPDSINVGT5X96] .right_padding  10
#set_db [get_db base_cells F6UNAA_LPDSINVGT5X96] .left_padding   10
#
#### GET BLOCKS FOR PLACEMENT BLOCKAGES ###
#set hier_cells [get_db insts i_*_i_* -if !.base_cell==*F6*]
#
#
#### LEVEL 0 TAPS ###
## Example: for {set r 0} { $r < 8 } { incr r 2} { for {set c 0} { $c < 8 } { incr c 1 } { puts -nonew "t$r$c \{*r${r}_c${c}*/*clk r[expr $r +1]_c${c}*/grid_clk \} "  } ; puts "" }
##set tap_groups_list [list \
##t00 {i_cluster_r0_c0_*/*clk i_cluster_r1_c0_*/*clk } t01 {i_cluster_r0_c1_*/*clk i_cluster_r1_c1_*/*clk } t02 {i_cluster_r0_c2_*/*clk i_cluster_r1_c2_*/*clk } t03 {i_cluster_r0_c3_*/*clk i_cluster_r1_c3_*/*clk } t04 {i_cluster_r0_c4_*/*clk i_cluster_r1_c4_*/*clk } t05 {i_cluster_r0_c5_*/*clk i_cluster_r1_c5_*/*clk } t06 {i_cluster_r0_c6_*/*clk i_cluster_r1_c6_*/*clk } t07 {i_cluster_r0_c7_*/*clk i_cluster_r1_c7_*/*clk } \
##t20 {i_cluster_r2_c0_*/*clk i_cluster_r3_c0_*/*clk } t21 {i_cluster_r2_c1_*/*clk i_cluster_r3_c1_*/*clk } t22 {i_cluster_r2_c2_*/*clk i_cluster_r3_c2_*/*clk } t23 {i_cluster_r2_c3_*/*clk i_cluster_r3_c3_*/*clk } t24 {i_cluster_r2_c4_*/*clk i_cluster_r3_c4_*/*clk } t25 {i_cluster_r2_c5_*/*clk i_cluster_r3_c5_*/*clk } t26 {i_cluster_r2_c6_*/*clk i_cluster_r3_c6_*/*clk } t27 {i_cluster_r2_c7_*/*clk i_cluster_r3_c7_*/*clk } \
##t40 {i_cluster_r4_c0_*/*clk i_cluster_r5_c0_*/*clk } t41 {i_cluster_r4_c1_*/*clk i_cluster_r5_c1_*/*clk } t42 {i_cluster_r4_c2_*/*clk i_cluster_r5_c2_*/*clk } t43 {i_cluster_r4_c3_*/*clk i_cluster_r5_c3_*/*clk } t44 {i_cluster_r4_c4_*/*clk i_cluster_r5_c4_*/*clk } t45 {i_cluster_r4_c5_*/*clk i_cluster_r5_c5_*/*clk } t46 {i_cluster_r4_c6_*/*clk i_cluster_r5_c6_*/*clk } t47 {i_cluster_r4_c7_*/*clk i_cluster_r5_c7_*/*clk } \
##t60 {i_cluster_r6_c0_*/*clk i_cluster_r7_c0_*/*clk } t61 {i_cluster_r6_c1_*/*clk i_cluster_r7_c1_*/*clk } t62 {i_cluster_r6_c2_*/*clk i_cluster_r7_c2_*/*clk } t63 {i_cluster_r6_c3_*/*clk i_cluster_r7_c3_*/*clk } t64 {i_cluster_r6_c4_*/*clk i_cluster_r7_c4_*/*clk } t65 {i_cluster_r6_c5_*/*clk i_cluster_r7_c5_*/*clk } t66 {i_cluster_r6_c6_*/*clk i_cluster_r7_c6_*/*clk } t67 {i_cluster_r6_c7_*/*clk i_cluster_r7_c7_*/*clk }  ]
#
#set tap_groups_list [list \
#t00 {*r0_c0*/*clk *r1_c0*/grid_clk } t01 {*r0_c1*/*clk *r1_c1*/grid_clk } t02 {*r0_c2*/*clk *r1_c2*/grid_clk } t03 {*r0_c3*/*clk *r1_c3*/grid_clk } t04 {*r0_c4*/*clk *r1_c4*/grid_clk } t05 {*r0_c5*/*clk *r1_c5*/grid_clk } t06 {*r0_c6*/*clk *r1_c6*/grid_clk } t07 {*r0_c7*/*clk *r1_c7*/grid_clk } \
#t20 {*r2_c0*/*clk *r3_c0*/grid_clk } t21 {*r2_c1*/*clk *r3_c1*/grid_clk } t22 {*r2_c2*/*clk *r3_c2*/grid_clk } t23 {*r2_c3*/*clk *r3_c3*/grid_clk } t24 {*r2_c4*/*clk *r3_c4*/grid_clk } t25 {*r2_c5*/*clk *r3_c5*/grid_clk } t26 {*r2_c6*/*clk *r3_c6*/grid_clk } t27 {*r2_c7*/*clk *r3_c7*/grid_clk } \
#t40 {*r4_c0*/*clk *r5_c0*/grid_clk } t41 {*r4_c1*/*clk *r5_c1*/grid_clk } t42 {*r4_c2*/*clk *r5_c2*/grid_clk } t43 {*r4_c3*/*clk *r5_c3*/grid_clk } t44 {*r4_c4*/*clk *r5_c4*/grid_clk } t45 {*r4_c5*/*clk *r5_c5*/grid_clk } t46 {*r4_c6*/*clk *r5_c6*/grid_clk } t47 {*r4_c7*/*clk *r5_c7*/grid_clk } \
#t60 {*r6_c0*/*clk *r7_c0*/grid_clk } t61 {*r6_c1*/*clk *r7_c1*/grid_clk } t62 {*r6_c2*/*clk *r7_c2*/grid_clk } t63 {*r6_c3*/*clk *r7_c3*/grid_clk } t64 {*r6_c4*/*clk *r7_c4*/grid_clk } t65 {*r6_c5*/*clk *r7_c5*/grid_clk } t66 {*r6_c6*/*clk *r7_c6*/grid_clk } t67 {*r6_c7*/*clk *r7_c7*/grid_clk } ]
#
## block_all_horizontal $hier_cells
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list level0_tap 600 true
#remove_my_blockages
#
#### LEVEL 1 TAPS ###
## for {set r 0} { $r < 8 } { incr r 2} { for {set c 0} { $c < 8 } { incr c 2 } { puts -nonew "t$r$c \{level0_tap*t$r$c/i level0_tap*t$r[expr $c + 1]/i\} "  } ; puts "" }
#set tap_groups_list [list t00 {level0_tap*t00/i level0_tap*t01/i} t02 {level0_tap*t02/i level0_tap*t03/i} t04 {level0_tap*t04/i level0_tap*t05/i} t06 {level0_tap*t06/i level0_tap*t07/i} \
#t20 {level0_tap*t20/i level0_tap*t21/i} t22 {level0_tap*t22/i level0_tap*t23/i} t24 {level0_tap*t24/i level0_tap*t25/i} t26 {level0_tap*t26/i level0_tap*t27/i} \
#t40 {level0_tap*t40/i level0_tap*t41/i} t42 {level0_tap*t42/i level0_tap*t43/i} t44 {level0_tap*t44/i level0_tap*t45/i} t46 {level0_tap*t46/i level0_tap*t47/i} \
#t60 {level0_tap*t60/i level0_tap*t61/i} t62 {level0_tap*t62/i level0_tap*t63/i} t64 {level0_tap*t64/i level0_tap*t65/i} t66 {level0_tap*t66/i level0_tap*t67/i} ]
#
## block_all_horizontal $hier_cells
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list level1_tap 35
#remove_my_blockages
#
#### LEVEL 2 TAPS ###
## for {set r 0} { $r < 8 } { incr r 2} { for {set c 0} { $c < 8 } { incr c 4 } { puts -nonew "t$r$c \{level1_tap_t$r$c/i level1_tap_t$r[expr $c + 2]/i\} "  } ; puts "" }
#set tap_groups_list [list t00 {level1_tap_t00/i level1_tap_t02/i} t04 {level1_tap_t04/i level1_tap_t06/i} \
#t20 {level1_tap_t20/i level1_tap_t22/i} t24 {level1_tap_t24/i level1_tap_t26/i} \
#t40 {level1_tap_t40/i level1_tap_t42/i} t44 {level1_tap_t44/i level1_tap_t46/i} \
#t60 {level1_tap_t60/i level1_tap_t62/i} t64 {level1_tap_t64/i level1_tap_t66/i} ]
#
## block_all_vertical $hier_cells
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list level2_tap 200 true
#remove_my_blockages
#
#### LEVEL 3 TAPS ###
## for {set r 0} { $r < 8 } { incr r 4} { for {set c 0} { $c < 8 } { incr c 4 } { puts -nonew "t$r$c \{level2_tap*t$r$c/i level2_tap*t[expr $r + 2]$c/i\} "  } ; puts "" }
#set tap_groups_list [list t00 {level2_tap*t00/i level2_tap*t20/i} t04 {level2_tap*t04/i level2_tap*t24/i} \
#t40 {level2_tap*t40/i level2_tap*t60/i} t44 {level2_tap*t44/i level2_tap*t64/i} ]
#
## block_all_vertical $hier_cells
## block_all_horizontal $hier_cells
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list level3_tap 50 true
#remove_my_blockages
#
#
#### LEVEL 4 TAPS ###
## for {set r 0} { $r < 8 } { incr r 4} { for {set c 0} { $c < 8 } { incr c 8 } { puts -nonew "t$r$c \{level3_tap*t$r$c/i level3_tap*t$r[expr $c + 4]/i\} "  } ; puts "" }
#set tap_groups_list [list t00 {level3_tap*t00/i level3_tap*t04/i} \
#t40 {level3_tap*t40/i level3_tap*t44/i} ]
#
## block_all_vertical $hier_cells
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list level4_tap 25 true
#remove_my_blockages
#
#### OUTPUT CLOCK PORTS ###
#
#### WEST ###
#set tap_groups_list [list ck00 {*quad_west_filler_r0/grid_clk *quad_west_filler_r1/grid_clk} \
#                          ck10 {*quad_west_filler_r2/grid_clk *quad_west_filler_r3/grid_clk} \
#                          ck20 {*quad_west_filler_r4/grid_clk *quad_west_filler_r5/grid_clk} \
#                          ck30 {*quad_west_filler_r6/grid_clk *quad_west_filler_r7/grid_clk} ]
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list level_west_clock_tap 50 
## CONNECT PORTS AND CONNECT NEW TAPS TO LAST DRIVER
#set_db eco_honor_dont_use false
#set_db eco_update_timing false
#set_db eco_refine_place false
#set_db eco_check_logical_equivalence false
#
## 0
#set in_name   grid_clk_to_west[0]
#set out_name  level_west_clock_tap_ck00/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_west_clock_tap_ck00
#set out_name  level0_tap_b_t00/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] -10]
#set y        [lindex $location 1]
#eco_add_repeater -cells $repeater_template -name "level_west_clock_rpt_tap_0" -new_net_name "level_west_clock_rpt_tap_0_net" -pins $in_name/i -location [list $x $y]
#
## 1
#set in_name   grid_clk_to_west[1]
#set out_name  level_west_clock_tap_ck10/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_west_clock_tap_ck10
#set out_name  level0_tap_b_t20/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] -10]
#set y        [lindex $location 1]
#eco_add_repeater -cells $repeater_template -name "level_west_clock_rpt_tap_1" -new_net_name "level_west_clock_rpt_tap_1_net" -pins $in_name/i -location [list $x $y]
#
## 2
#set in_name   grid_clk_to_west[2]
#set out_name  level_west_clock_tap_ck20/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_west_clock_tap_ck20
#set out_name  level0_tap_b_t40/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] -10]
#set y        [lindex $location 1]
#eco_add_repeater -cells $repeater_template -name "level_west_clock_rpt_tap_2" -new_net_name "level_west_clock_rpt_tap_2_net" -pins $in_name/i -location [list $x $y]
#
####### Manually ###############
## 3
#place_inst level_west_clock_tap_ck30 [list [get_db [get_cells level_west_clock_tap_ck20] .bbox.ll.x] [get_db [get_cells level0_tap_b_t60] .bbox.ll.y]] r0
##place_detail -inst level_west_clock_tap_ck30
#
#set in_name   grid_clk_to_west[3]
#set out_name  level_west_clock_tap_ck30/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_west_clock_tap_ck30
#set out_name  level0_tap_b_t60/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] -10]
#set y        [lindex $location 1]
#eco_add_repeater -cells $repeater_template -name "level_west_clock_rpt_tap_3" -new_net_name "level_west_clock_rpt_tap_3_net" -pins $in_name/i -location [list $x $y]
#
#set_db eco_honor_dont_use true
#set_db eco_update_timing true
#set_db eco_refine_place true
#set_db eco_check_logical_equivalence true
#
#
#write_db out/db/post_west_buffering.enc.dat
#
#### EAST ###
#set tap_groups_list [list ck00 {*quad_east_filler_r0/grid_clk *quad_east_filler_r1/grid_clk} \
#                          ck10 {*quad_east_filler_r2/grid_clk *quad_east_filler_r3/grid_clk} \
#                          ck20 {*quad_east_filler_r4/grid_clk *quad_east_filler_r5/grid_clk} \
#                          ck30 {*quad_east_filler_r6/grid_clk *quad_east_filler_r7/grid_clk} ]
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list level_east_clock_tap 50 
## CONNECT PORTS AND CONNECT NEW TAPS TO LAST DRIVER
#set_db eco_honor_dont_use false
#set_db eco_update_timing false
#set_db eco_refine_place false
#set_db eco_check_logical_equivalence false
#
## 0
#set in_name   grid_clk_to_east[0]
#set out_name  level_east_clock_tap_ck00/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_east_clock_tap_ck00
#set out_name  level0_tap_b_t07/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +10]
#set y        [lindex $location 1]
#eco_add_repeater -cells $repeater_template -name "level_east_clock_rpt_tap_0" -new_net_name "level_east_clock_rpt_tap_0_net" -pins $in_name/i -location [list $x $y]
#
## 1
#set in_name   grid_clk_to_east[1]
#set out_name  level_east_clock_tap_ck10/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_east_clock_tap_ck10
#set out_name  level0_tap_b_t27/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +10]
#set y        [lindex $location 1]
#eco_add_repeater -cells $repeater_template -name "level_east_clock_rpt_tap_1" -new_net_name "level_east_clock_rpt_tap_1_net" -pins $in_name/i -location [list $x $y]
#
## 2
#set in_name   grid_clk_to_east[2]
#set out_name  level_east_clock_tap_ck20/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_east_clock_tap_ck20
#set out_name  level0_tap_b_t47/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +10]
#set y        [lindex $location 1]
#eco_add_repeater -cells $repeater_template -name "level_east_clock_rpt_tap_2" -new_net_name "level_east_clock_rpt_tap_2_net" -pins $in_name/i -location [list $x $y]
#
## 3
#set in_name   grid_clk_to_east[3]
#set out_name  level_east_clock_tap_ck30/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_east_clock_tap_ck30
#set out_name  level0_tap_b_t67/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +10]
#set y        [lindex $location 1]
#eco_add_repeater -cells $repeater_template -name "level_east_clock_rpt_tap_3" -new_net_name "level_east_clock_rpt_tap_3_net" -pins $in_name/i -location [list $x $y]
#
#set_db eco_honor_dont_use true
#set_db eco_update_timing true
#set_db eco_refine_place true
#set_db eco_check_logical_equivalence true
#
#
#### NORTH ###
#set tap_groups_list [list ck00 {*quad_north_filler_c0/grid_clk *quad_north_filler_c1/grid_clk} \
#                          ck01 {*quad_north_filler_c2/grid_clk *quad_north_filler_c3/grid_clk} \
#                          ck02 {*quad_north_filler_c4/grid_clk *quad_north_filler_c5/grid_clk} \
#                          ck03 {*quad_north_filler_c6/grid_clk *quad_north_filler_c7/grid_clk} ]
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list level_north_clock_tap 50 
##
##set tap_groups_list [list ck00 {level_north_clock_tap_b_ck00/i level_north_clock_tap_a_ck00/i } \
##                          ck01 {level_north_clock_tap_b_ck01/i level_north_clock_tap_a_ck01/i } \
##                          ck02 {level_north_clock_tap_b_ck02/i level_north_clock_tap_a_ck02/i } \
##                          ck03 {level_north_clock_tap_b_ck03/i level_north_clock_tap_a_ck03/i } ]
##set tap_pins_list [create_tap_groups $tap_groups_list ]
##insert_taps $tap_pins_list level_north_clock_1_tap 50 
## CONNECT PORTS AND CONNECT NEW TAPS TO LAST DRIVER
#set_db eco_honor_dont_use false
#set_db eco_update_timing false
#set_db eco_refine_place false
#set_db eco_check_logical_equivalence false
#
## 0
#set in_name   grid_clk_to_north[0]
#set out_name  level_north_clock_tap_ck00/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_north_clock_tap_ck00
#set out_name  level1_tap_t00/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +5]
#set y        [expr [lindex $location 1] +3 ]
#eco_add_repeater -cells $repeater_template -name "level_north_clock_rpt_tap_0"   -new_net_name "level_north_clock_rpt_tap_0_net"   -pins $in_name/i -location [list $x $y]
#eco_add_repeater -cells F6UNAA_LPDINVX48   -name "level_north_clock_rpt_tap_0_0" -new_net_name "level_north_clock_rpt_tap_0_0_net" -pins level_north_clock_rpt_tap_0/i -location [list $x $y]
#
## 1
#set in_name   grid_clk_to_north[1]
#set out_name  level_north_clock_tap_ck01/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_north_clock_tap_ck01
#set out_name  level1_tap_t02/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +5]
#set y        [expr [lindex $location 1] +3]
#eco_add_repeater -cells $repeater_template -name "level_north_clock_rpt_tap_1"   -new_net_name "level_north_clock_rpt_tap_1_net"   -pins $in_name/i -location [list $x $y]
#eco_add_repeater -cells F6UNAA_LPDINVX48   -name "level_north_clock_rpt_tap_1_1" -new_net_name "level_north_clock_rpt_tap_1_1_net" -pins level_north_clock_rpt_tap_1/i -location [list $x $y]
#
## 2
#set in_name   grid_clk_to_north[2]
#set out_name  level_north_clock_tap_ck02/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_north_clock_tap_ck02
#set out_name  level1_tap_t04/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +5]
#set y        [expr [lindex $location 1] +3]
#eco_add_repeater -cells $repeater_template -name "level_north_clock_rpt_tap_2"   -new_net_name "level_north_clock_rpt_tap_2_net"   -pins $in_name/i -location [list $x $y]
#eco_add_repeater -cells F6UNAA_LPDINVX48   -name "level_north_clock_rpt_tap_2_2" -new_net_name "level_north_clock_rpt_tap_2_2_net" -pins level_north_clock_rpt_tap_2/i -location [list $x $y]
#
## 3
#set in_name   grid_clk_to_north[3]
#set out_name  level_north_clock_tap_ck03/o
#connect_hpin - -net [get_db [get_nets -of $out_name] .name] -pin_name $in_name 
#
#set in_name   level_north_clock_tap_ck03
#set out_name  level1_tap_t06/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +5]
#set y        [expr [lindex $location 1] +3]
#eco_add_repeater -cells $repeater_template -name "level_north_clock_rpt_tap_3"   -new_net_name "level_north_clock_rpt_tap_3_net"    -pins $in_name/i -location [list $x $y]
#eco_add_repeater -cells F6UNAA_LPDINVX48   -name "level_north_clock_rpt_tap_3_3" -new_net_name "level_north_clock_rpt_tap_3_3_net" -pins level_north_clock_rpt_tap_3/i -location [list $x $y]
#
#set_db eco_honor_dont_use true
#set_db eco_update_timing true
#set_db eco_refine_place true
#set_db eco_check_logical_equivalence true
#
#
#### SOUTH ###
#set tap_groups_list [list ck00 {*quad_south_filler_c0/grid_clk *quad_south_filler_c1/grid_clk} \
#                          ck01 {*quad_south_filler_c2/grid_clk *quad_south_filler_c3/grid_clk} \
#                          ck02 {*quad_south_filler_c4/grid_clk *quad_south_filler_c5/grid_clk} \
#                          ck03 {*quad_south_filler_c6/grid_clk *quad_south_filler_c7/grid_clk} ]
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list level_south_clock_tap 50 
##
##set tap_groups_list [list ck00 {level_south_clock_tap_b_ck00/i level_south_clock_tap_a_ck00/i } \
##                          ck01 {level_south_clock_tap_b_ck01/i level_south_clock_tap_a_ck01/i } \
##                          ck02 {level_south_clock_tap_b_ck02/i level_south_clock_tap_a_ck02/i } \
##                          ck03 {level_south_clock_tap_b_ck03/i level_south_clock_tap_a_ck03/i } ]
##set tap_pins_list [create_tap_groups $tap_groups_list ]
##insert_taps $tap_pins_list level_south_clock_1_tap 50 
## CONNECT PORTS AND CONNECT NEW TAPS TO LAST DRIVER
#set_db eco_honor_dont_use false
#set_db eco_update_timing false
#set_db eco_refine_place false
#set_db eco_check_logical_equivalence false
#
## 0
#set in_name   level_south_clock_tap_ck00
#set out_name  level1_tap_t60/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +5]
#set y        [expr [lindex $location 1] +3 ]
#eco_add_repeater -cells $repeater_template -name "level_south_clock_rpt_tap_0"   -new_net_name "level_south_clock_rpt_tap_0_net"   -pins $in_name/i -location [list $x $y]
#eco_add_repeater -cells F6UNAA_LPDINVX48   -name "level_south_clock_rpt_tap_0_0" -new_net_name "level_south_clock_rpt_tap_0_0_net" -pins level_south_clock_rpt_tap_0/i -location [list $x $y]
#
## 1
#set in_name   level_south_clock_tap_ck01
#set out_name  level1_tap_t62/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +5]
#set y        [expr [lindex $location 1] +3]
#eco_add_repeater -cells $repeater_template -name "level_south_clock_rpt_tap_1"   -new_net_name "level_south_clock_rpt_tap_1_net"   -pins $in_name/i -location [list $x $y]
#eco_add_repeater -cells F6UNAA_LPDINVX48   -name "level_south_clock_rpt_tap_1_1" -new_net_name "level_south_clock_rpt_tap_1_1_net" -pins level_south_clock_rpt_tap_1/i -location [list $x $y]
#
## 2
#set in_name   level_south_clock_tap_ck02
#set out_name  level1_tap_t64/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +5]
#set y        [expr [lindex $location 1] +3]
#eco_add_repeater -cells $repeater_template -name "level_south_clock_rpt_tap_2"    -new_net_name "level_south_clock_rpt_tap_2_net"   -pins $in_name/i -location [list $x $y]
#eco_add_repeater -cells F6UNAA_LPDINVX48   -name "level_south_clock_rpt_tap_2_2"  -new_net_name "level_south_clock_rpt_tap_2_2_net" -pins level_south_clock_rpt_tap_2/i -location [list $x $y]
#
## 3
#set in_name   level_south_clock_tap_ck03
#set out_name  level1_tap_t66/o
#connect_pin  -inst $in_name -pin i -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +5]
#set y        [expr [lindex $location 1] +3]
#eco_add_repeater -cells $repeater_template -name "level_south_clock_rpt_tap_3"    -new_net_name "level_south_clock_rpt_tap_3_net"   -pins $in_name/i -location [list $x $y]
#eco_add_repeater -cells F6UNAA_LPDINVX48   -name "level_south_clock_rpt_tap_3_3"  -new_net_name "level_south_clock_rpt_tap_3_3_net" -pins level_south_clock_rpt_tap_3/i -location [list $x $y]
#
#set_db eco_honor_dont_use true
#set_db eco_update_timing true
#set_db eco_refine_place true
#set_db eco_check_logical_equivalence true
#
#### SOUTH EAST ###
#set_db eco_honor_dont_use false
#set_db eco_update_timing false
#set_db eco_refine_place false
#set_db eco_check_logical_equivalence false
#
#set in_name  i_grid_quad_south_filler_i_grid_quad_south_filler_east
#set out_name level_south_clock_tap_ck03/o
#connect_pin  -inst $in_name -pin grid_clk -net [get_db [get_nets -of $out_name] .name]
#
#set location [lindex [get_db [get_pins $out_name] .location] 0]
#set x        [expr [lindex $location 0] +5]
#set y        [expr [lindex $location 1] +3]
#eco_add_repeater -cells $repeater_template -name "level_south_east_clock_rpt_tap_0"   -new_net_name "level_south_east_clock_rpt_tap_0_net"   -pins $in_name/grid_clk -location [list $x $y]
#eco_add_repeater -cells F6UNAA_LPDINVX48   -name "level_south_east_clock_rpt_tap_0_0" -new_net_name "level_south_east_clock_rpt_tap_0_0_net" -pins level_south_east_clock_rpt_tap_0/i -location [list $x $y]
#
#set_db eco_honor_dont_use true
#set_db eco_update_timing true
#set_db eco_refine_place true
#set_db eco_check_logical_equivalence true
#
#
#place_detail -inst [get_db [get_cells level_*_clock*tap*] .name]
#
#write_db out/db/post_tap_insertion.enc.dat
#
#### INSERT CLOCK SOURCES ###
## for {set r 0} { $r < 8 } { incr r 4} { for {set c 0} { $c < 8 } { incr c 8 } { puts -nonew "t$r$c \{level3_tap*t$r$c/i level3_tap*t$r[expr $c + 4]/i\} "  } ; puts "" }
#set tap_groups_list [list s0 {level4_tap*t00/i level4_tap*t40/i} ]
#
## block_all_vertical $hier_cells
## block_all_horizontal $hier_cells
#set tap_pins_list [create_tap_groups $tap_groups_list ]
#insert_taps $tap_pins_list tree_source 25 true
#remove_my_blockages
#
#
#set clock_cells [add_to_collection [get_cells -hier *level*_tap*] [get_cells -hier *tree_source*]]
#set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
#
#t $clock_nets {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] 0]} {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] 0] }
#t [get_pins */grid_clk] {count_levels_from_source $o}
#
#write_db out/db/post_buidling_inv_tree.enc.dat
#
#### BREAKDOWN LONG NETS ###
##set clock_cells [remove_from_collection [get_cells -hier *level*_tap*] [get_cells level_*_clock*tap*]]
##set clock_nets  [get_nets -of $clock_cells]
##break_up_long_clock_nets $clock_nets 1000 "" 
#
#set clock_nets [get_nets *level4*tap*]
#break_up_long_clock_nets $clock_nets 1250
#
#### TODO add break_up_long_clock_nets a flag to decide rather I buffer close to drv or rcv ???
#set clock_nets [get_nets -of inst:grid_quadrant/levelx_tap_clock_port]
#break_up_long_clock_nets $clock_nets 1050
#
#set clock_cells [get_cells -hier *tree_source*]
#set clock_nets  [get_nets -of $clock_cells]
#break_up_long_clock_nets $clock_nets 1200
#
#set_db [get_db nets grid_clk] .dont_touch true
#
#end_record
#
#set clock_cells [add_to_collection [get_cells -hier *level*tap*] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
#set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
#set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
#set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]
#
#place_detail
#
#t $clock_nets {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] 0]} {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] 0] }
#t [get_pins */grid_clk] {count_levels_from_source $o}
#
#set clock_cells [add_to_collection [get_cells -hier *level*tap*] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
#set_db $clock_cells .place_status fixed
#
#return
#
#so $clock_cells
#write_def -selected ../inter/clock_cells_placement_new.def
#
##
##write_db -verilog out/db/${DESIGN_NAME}.pre_htree_route.enc.dat
##read_def ../inter/clock_cells_placement.def
##
##place_detail
#
#### ROUTING ###
##create_route_rule -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 -spacing_multiplier {M16:M17 1.3} -name NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076_1p3Space
##
##create_route_type -name MyclockRouteTop3   -top_preferred_layer $MAX_ROUTING_LAYER                -bottom_preferred_layer [expr $MAX_ROUTING_LAYER -1] -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076_1p3Space
##create_route_type -name MyclockRouteTrunk3 -top_preferred_layer $MAX_ROUTING_LAYER                -bottom_preferred_layer 7                            -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076_1p3Space
##create_route_type -name MyclockRouteLeaf3  -top_preferred_layer [expr min($MAX_ROUTING_LAYER,10)] -bottom_preferred_layer 2                            -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076_1p3Space
## 
##set_db cts_route_type_top   MyclockRouteTop3
##set_db cts_route_type_trunk MyclockRouteTrunk3
##set_db cts_route_type_leaf  MyclockRouteLeaf3
##
##eee "commit_clock_tree_route_attributes"

# ROUTE P2P

set_db eco_honor_dont_use false
set_db eco_update_timing false
set_db eco_refine_place false
set_db eco_check_logical_equivalence false

#source -e -v ../inter/record_connectivity_change_090822_1526.tcl
#read_def     /services/bespace/users/ory/nextflow_pn85_drop/be_work/brcm5/grid_quadrant/v0_pre_pn85_drop/inter/clock_cells_placement.def

source   ../inter/record_connectivity_change_090822_1526.tcl
read_def ../inter/clock_cells_placement_240822.def
read_def ../inter/clock_nets_routing_250822.def

set STAGE cts
source scripts/templates/quad/block_carpets.tcl

set clock_cells [add_to_collection [get_cells -hier *level*tap*] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]
#
#puts "-I- Legalizeing super buffers"
#source -e -v scripts/templates/quad/super_bufs/SuperBufferLegalizer.tcl

set_db $clock_cells .place_status fixed

delete_obj [get_db place_blockages *cts*]

place_detail 

set route_blockages [get_db route_blockages *tmp*]
delete_obj $route_blockages

#set repeater_template F6UNAA_LPDSINVGT5X96
#set_via_pillars -base_pin F6UNAA_LPDSINVGT5X96/o  -required 1 {MY_VP6}


puts "-I- Building via ladder"
#source -e -v scripts/templates/quad/super_bufs/MoveViaLadder.tcl
be_build_x96_vl [get_cells [get_db $clock_cells -if .base_cell==*96*]] false

set_db route_early_global_top_routing_layer 18
set_db design_top_routing_layer 18

create_route_rule -name grid_clk_vp_rule_2 -width   {M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 \
                                           -spacing {M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}
                                         
set_db $clock_nets .route_rule {}
foreach net [get_db $clock_nets .name] {
  set_route_attributes -reset -nets $net
  set_route_attributes -nets $net -top_preferred_routing_layer 18 -bottom_preferred_routing_layer 17 \
                       -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort high \
                       -route_rule grid_clk_vp_rule_2
}
#read_def snapshot.def

set_db $clock_cells .place_status fixed
set_db $clock_nets .dont_touch true
set_db $clock_nets .wires.status fixed
set_db $clock_nets .vias.status fixed

write_db -verilog out/db/${DESIGN_NAME}.place_post_vp.enc.dat

# TODO: Legalize via pillar vs routing carpets

t $clock_nets {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] 0]} {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] 0] }
t [get_pins */grid_clk] {count_levels_from_source $o}

#set_db $clock_cells .place_status placed
#set_db place_detail_eco_max_distance 300
#place_detail -inst [get_object_name $clock_cells]

### TODO: CHECK IF I CAN ROUTE WITH NO TIMING UPDATE
set_db route_design_with_timing_driven false
set_db route_design_antenna_diode_insertion false
#set_db opt_via_pillar_effort high
set_db opt_via_pillar_effort low
set_db route_design_with_si_driven false
set_db route_design_detail_fix_antenna false
set_db route_design_detail_end_iteration 1

delete_obj [get_db [get_db [get_nets ] .wires ] -if .status==unknown]
delete_obj [get_db [get_db [get_nets ] .vias ] -if .status==unknown]

be_route_p2p [get_nets $clock_nets]

so $clock_nets 
route_global_detail -selected

write_db -verilog out/db/${DESIGN_NAME}.place_post_grid_clk_route.enc.dat

set_db $clock_cells .place_status fixed
set_db $clock_nets .dont_touch true
set_db $clock_nets .wires.status fixed
set_db $clock_nets .vias.status fixed

so $clock_nets 
write_def -routing -selected out/def/${DESIGN_NAME}.grid_clk_route_and_vp.enc.dat

#set_db route_early_global_route_selected_net_only true

#foreach net $clock_nets {
#    so $net
#    route_global_detail -selected
#}

#set group 10
#set size [llength $clock_nets]
#set step [expr int(ceil(1.0*$size/$group))]
#set to   $step
#set from 0
#for { set i 0 } { $i < $group } { incr i } { 
#    
#    if { $to > $size } { set to end }
#    
#    set nets [lrange $clock_nets $from $to]
#    so $nets 
#    puts "-D- Nets from: $from $to Index: $i"
#    puts "-D- Nets [llength $nets]"
#    if { [llength $nets] == 0 } { continue }
#
#    
#    route_global_detail -selected
##    route_early_global
#    if { $to == "end" } { continue }
#
#    set from [expr $to   + 1]
#    set to   [expr $to   + $step]
#    
#}

#
#set clock_cells [add_to_collection [get_cells -hier *level*tap*] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
#set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
#set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
#set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]
#
#set_db $clock_cells .place_status fixed
#set_db $clock_nets .dont_touch true
#set_db $clock_nets .wires.status fixed
#set_db $clock_nets .vias.status fixed
#set_db $clock_nets .route_rule {}
#
##create_route_rule -name quad_cts_lower_m_route_rule -spacing_multiplier {2:10 3}
#
#foreach net [get_db $clock_nets .name] {
#  set_route_attributes -reset -nets $net
#  set_route_attributes -nets $net -top_preferred_routing_layer 18 -bottom_preferred_routing_layer 17 \
#                       -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort high \
#                       -route_rule quad_cts_lower_m_route_rule
#}

############## Reference ###############
#@innovus 90> set_db $clock_cells .place_status fixed
#143 fixed
#@innovus 91> set_db $clock_nets .dont_touch true
#144 true
#@innovus 92> set_db $clock_nets .wires.status fixed
#4250 fixed
#@innovus 93> set_db $clock_nets .vias.status fixed
#4695 fixed
#########################################
#
#write_db -verilog out/db/${DESIGN_NAME}.post_manual_grid_clk_build.enc.dat

#set_interactive_constraint_mode func
#create_clock_tree_spec
#set_db cts_target_max_transition_time 0.075
#set_propagated_clock [get_clocks *grid_clk]
#set_interactive_constraint_mode {}
##report_timing
##return
#report_skew_groups -summary     > reports/report_skew_groups.rpt
#report_clock_trees -histograms  > reports/report_clock_trees.rpt
#redirect repotrs/skew_hist.rpt { be_skew_hist 1000000 func_no_od_125_LIBRARY_SS_cworst_setup }

if { [get_db clock_trees] == "" } { create_clock_tree_spec }
set_interactive_constraint_mode func
set_db [get_db clock_trees *grid_*clk*] .cts_target_max_transition_time 0.075
set_propagated_clock [get_clocks *grid_clk]
set_interactive_constraint_mode {}

report_skew_groups -summary     > reports/report_skew_groups.rpt
report_clock_trees -histograms  > reports/report_clock_trees.rpt
redirect repotrs/skew_hist.rpt { be_skew_hist 1000000 func_no_od_125_LIBRARY_SS_cworst_setup }

set fp [open reports/clock_nets_info.rpt w]
redirect -var res {clock_nets_info $clock_nets}
puts $fp "All nets:\n---------"
puts $fp $res
for {set i 0} {$i < 5} { incr i } {
    if { [sizeof [set nets [get_nets level${i}_tap_*]]] > 0 } { 
        redirect -var res { clock_nets_info $nets 2 }
        puts $fp ""
        puts $fp "Nets level${i}_tap_*:\n----------------"
        puts $fp $res
    }
}
close $fp

redirect -var res { report_blocks_latency }
echo ""   >> reports/detailed_blocks_clock_latency.rpt
echo $res >> reports/detailed_blocks_clock_latency.rpt

delete_obj [get_db place_blockages carpet_cts_blockage]

create_route_blockage  -layers {M16 M17} -rects [get_db designs .bbox] -name do_not_route_m1716_please

foreach inst_dpo [get_db [get_db insts -if .base_cell==*top*]] {
  set rect [lindex [get_db $inst_dpo .bbox] 0]
  lassign $rect xl yl xh yh
  set rect [list [expr $xl + 2] [expr $yl + 2] [expr $xh - 2] [expr $yh - 2]]
  create_route_blockage -rects $rect  -layers {M15}  -name temp_block_blockages
}

set MAX_ROUTING_LAYER 16
set_db route_early_global_top_routing_layer 16
set_db design_top_routing_layer 16
#
#if {[get_db route_types .name clockRouteTop] != ""} {
#  set_db cts_route_type_top   default
#  set_db cts_route_type_trunk default
#  set_db cts_route_type_leaf  default
#  delete_obj [get_db route_types clockRoute*]
#}
create_route_type -name new_clockRouteTop -top_preferred_layer $MAX_ROUTING_LAYER -bottom_preferred_layer [expr $MAX_ROUTING_LAYER -1] -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076_SHLD -shield_net VSS
create_route_type -name new_clockRouteTrunk -top_preferred_layer $MAX_ROUTING_LAYER -bottom_preferred_layer 7 -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076_SHLD -shield_net VSS
create_route_type -name new_clockRouteLeaf -top_preferred_layer [expr min($MAX_ROUTING_LAYER,10)] -bottom_preferred_layer 2 -preferred_routing_layer_effort high -route_rule NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076
set_db cts_route_type_top   new_clockRouteTop
set_db cts_route_type_trunk new_clockRouteTrunk
set_db cts_route_type_leaf  new_clockRouteLeaf

commit_clock_tree_route_attributes -verbose

if { [get_db clock_trees] == "" } { create_clock_tree_spec }

set_db [get_db clock_trees *grid_*clk*] .cts_opt_ignore true
t [get_db clock_trees] cts_opt_ignore
clock_design

#return

write_db -verilog out/db/${DESIGN_NAME}.cts.enc.dat

report_skew_groups -summary

set fp [open reports/clock_nets_info_post.rpt w]
redirect -var res {clock_nets_info $clock_nets}
puts $fp "All nets:\n---------"
puts $fp $res
for {set i 0} {$i < 5} { incr i } {
    if { [sizeof [set nets [get_nets level${i}_tap_*]]] > 0 } { 
        redirect -var res { clock_nets_info $nets 2 }
        puts $fp ""
        puts $fp "Nets level${i}_tap_*:\n----------------"
        puts $fp $res
    }
}
close $fp




proc check_clock_drc { clock_nets } {
    echo "" > check_clock_drc.rpt
    foreach net [get_db -uniq $clock_nets] {
        if { [llength $net] != 1 } { puts "-W- Did not check net: $net" ; continue }
        so $net
        redirect -app check_clock_drc.rpt { check_drc -check_only selected_net }
    }
}


proc remove_clock_shorts { net } {

  set clock_cells [add_to_collection [get_cells -hier *level*tap*] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
  set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
  set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
  set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]
  
  set clock_nets_wires [get_db $clock_nets .wires]
  set clock_nets_vias  [get_db $clock_nets .vias]
  
  delete_markers
  set net [get_nets $net]
  if { [sizeof $net] == 0 } { return -1 }
  so $net 
  check_drc -check_only selected_net
    
  set shorts [get_db markers -if .subtype==Metal_Short]
  
  array unset box_layer_arr
  foreach short $shorts { set box_layer_arr([lindex [get_db $short .bbox] 0]) [get_db $short .layer.name] }

  set wires {}  
  set vias  {}
  foreach box [array names box_layer_arr] { 
      set wires [concat $wires [get_db [get_wires_within $box $box_layer_arr($box)]]] 
      set vias  [concat $vias  [get_db [get_vias_within  $box ] -if .via_def.top_layer.name==$box_layer_arr($box)||.via_def.bottom_layer.name==$box_layer_arr($box)]] 
  }
  set wires [get_db -uniq $wires]
  set vias  [get_db -uniq $vias]
  
  set filtered_wires {}
  foreach wire $wires {
      if { [lsearch $clock_nets_wires $wire] > -1 } { continue }
      lappend filtered_wires $wire
  }

  set filtered_vias {}
  foreach via $vias {
      if { [lsearch $clock_nets_vias $via] > -1 } { continue }
      lappend filtered_vias $via
  }
  
  delete_obj $filtered_wires
  delete_obj $filtered_vias
  
}

proc remove_clock_dangling { clock_nets } {
  set clock_nets_wires [get_db $clock_nets .wires]
  set clock_nets_vias  [get_db $clock_nets .vias]
  
  set ants [get_db markers -if .subtype==ConnectivityAntenna]
  
  array unset box_layer_arr
  foreach ant $ants { set box_layer_arr([lindex [get_db $ant .bbox] 0]) [get_db $ant .layer.name] }

  set wires {}  
  foreach box [array names box_layer_arr] { 
      set wires [concat $wires [get_db [get_wires_within $box $box_layer_arr($box)]]] 
  }
  set wires [get_db -uniq $wires]
 
  set filtered_wires {}
  foreach wire $wires {
      if { [lsearch $clock_nets_wires $wire] < 0 } { continue }
      lappend filtered_wires $wire
  }
  
  delete_obj $filtered_wires
}


proc remove_grid_clk_pin_connect {{pins ""}} {

    set grid_clk_pins [get_pins -of [get_cells -filter ref_name=~*top*] -filter name==grid_clk]
    
    foreach_in_collection pin $grid_clk_pins {
        set loc [lindex [get_db $pin .location] 0]
        lassign $loc x y
        set box [list [expr $x - 0.6] [expr $y - 0.6] [expr $x + 0.75] [expr $y + 1]]
        set wires [get_db [get_wires_within $box M17 true]]
        set wires [concat $wires [get_db [get_wires_within $box M16 true]]]
        set wires [concat $wires [get_db [get_wires_within $box M15 true]]]
        
        set vias  [get_db [get_vias_within $box]]
        
        set wires2del [get_db $wires -if .obj_type==patch_wire||(.net.name==[get_db $pin .net.name]&&.length<2)]
        set vias2del  [get_db $vias  -if .net.name==[get_db $pin .net.name]]
        
        if { [llength $wires2del] == 0 && [llength $vias2del] == 0 } { continue }
        
        delete_obj $wires2del
        delete_obj $vias2del
    }
    
    set clock_nets [get_nets -of $grid_clk_pins]
    
    create_route_rule -name grid_clk_vp_rule_2 -width   {M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 \
                                               -spacing {M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}

    set_db $clock_nets .route_rule {}
    foreach net [get_db $clock_nets .name] {
      set_route_attributes -reset -nets $net
      set_route_attributes -nets $net -top_preferred_routing_layer 18 -bottom_preferred_routing_layer 17 \
                           -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort high \
                           -route_rule grid_clk_vp_rule_2
    }
    
    ### TODO: CHECK IF I CAN ROUTE WITH NO TIMING UPDATE
    set_db route_design_with_timing_driven false
    set_db route_design_antenna_diode_insertion false
    #set_db opt_via_pillar_effort high
    set_db opt_via_pillar_effort low
    set_db route_design_with_si_driven false
    set_db route_design_detail_fix_antenna false
    set_db route_design_detail_end_iteration 1

    set_db $clock_nets .dont_touch true
    set_db $clock_nets .wires.status fixed
    set_db $clock_nets .vias.status fixed

    so $clock_nets 
    route_global_detail -selected

}













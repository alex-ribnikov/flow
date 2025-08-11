start_record
enter_eco_mode

set_db [get_db nets grid_clk] .dont_touch false

### Route from clock port to center of grid ###
#bring_clock_port_to_center {5968.2495 4353.09}


### ADD BUFFER ON CLOCK PORT ###
set repeater_template F6UNAA_LPDSINVGT5X96

set clock_port [get_db ports grid_clk]
set clock_port_location [lindex [get_db $clock_port .location] 0]
set clock_port_rpt_location [list [lindex $clock_port_location 0] [expr [lindex $clock_port_location 1] + 5]]

set_db eco_honor_dont_use false
set_db eco_update_timing false
set_db eco_refine_place false
set_db eco_check_logical_equivalence false

# Delete BRCM inserted assign buffers
delete_inst -inst  assignBuf_*

### PLACE ICG ###
eco_update_cell -insts i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY -cells F6UNAA_LPDCKENOAX8
place_inst i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY [list [lindex $clock_port_location 0] [expr [lindex $clock_port_location 1] + 2]] r0 
#################
eco_add_repeater -cells F6UNAA_LPDSINVGT5X96 -name "levelx_tap_clock_port_1" -new_net_name levelx_tap_clock_port_net_1 -pins i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY/o -location [list [lindex $clock_port_rpt_location 0] [expr [lindex $clock_port_rpt_location 1] + 100]]
#eco_add_repeater -cells F6UNAA_LPDSINVG3X48 -name "levelx_tap_clock_port_0" -new_net_name levelx_tap_clock_port_net_0 -pins i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY/o -location $clock_port_rpt_location

set_db eco_honor_dont_use true
set_db eco_update_timing true
set_db eco_refine_place true
set_db eco_check_logical_equivalence true

set_db place_detail_eco_max_distance 20
set_db [get_cells i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY] .place_status placed
be_legalize_super_inv levelx_tap_clock_port* false
place_detail -inst i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY


### GET BLOCKS FOR PLACEMENT BLOCKAGES ###
set hier_cells [get_db insts i_*_i_* -if !.base_cell==*F6*]


### INSERT DRIVER PER ROW ###
set tap_groups_list [list \
t0 {*r0_c*/grid_clk } \
t1 {*r1_c*/grid_clk } \
t2 {*r2_c*/grid_clk } \
t3 {*r3_c*/grid_clk } \
t4 {*r4_c*/grid_clk } \
t5 {*r5_c*/grid_clk } \
t6 {*r6_c*/grid_clk } ]
#t7 {*r7_c*/grid_clk } ]

set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list levelx_tap_row 53 false {0 -580}

### CHANGE CONNECTIVITY TO CHAIN ROW DRIVERS ###
connect_pin  -inst levelx_tap_row_t0 -pin i -net [get_db [get_nets -of levelx_tap_row_t1/o] .name]
connect_pin  -inst levelx_tap_row_t1 -pin i -net [get_db [get_nets -of levelx_tap_row_t2/o] .name]
connect_pin  -inst levelx_tap_row_t2 -pin i -net [get_db [get_nets -of levelx_tap_row_t3/o] .name]
connect_pin  -inst levelx_tap_row_t3 -pin i -net [get_db [get_nets -of levelx_tap_row_t4/o] .name]
connect_pin  -inst levelx_tap_row_t4 -pin i -net [get_db [get_nets -of levelx_tap_row_t5/o] .name]
connect_pin  -inst levelx_tap_row_t5 -pin i -net [get_db [get_nets -of levelx_tap_row_t6/o] .name]


### LEVEL 0 TAPS ###
# Example: for {set r 0} { $r < 8 } { incr r 1} { for {set c 0} { $c < 8 } { incr c 8 } { puts -nonew "t$r$c \{*r${r}_c${c}*/grid_clk \} "  } ; puts "" }
#set tap_groups_list [list \
#t00 {i_cluster_r0_c0_*/*clk i_cluster_r1_c0_*/*clk } t01 {i_cluster_r0_c1_*/*clk i_cluster_r1_c1_*/*clk } t02 {i_cluster_r0_c2_*/*clk i_cluster_r1_c2_*/*clk } t03 {i_cluster_r0_c3_*/*clk i_cluster_r1_c3_*/*clk } t04 {i_cluster_r0_c4_*/*clk i_cluster_r1_c4_*/*clk } t05 {i_cluster_r0_c5_*/*clk i_cluster_r1_c5_*/*clk } t06 {i_cluster_r0_c6_*/*clk i_cluster_r1_c6_*/*clk } t07 {i_cluster_r0_c7_*/*clk i_cluster_r1_c7_*/*clk } \
#t20 {i_cluster_r2_c0_*/*clk i_cluster_r3_c0_*/*clk } t21 {i_cluster_r2_c1_*/*clk i_cluster_r3_c1_*/*clk } t22 {i_cluster_r2_c2_*/*clk i_cluster_r3_c2_*/*clk } t23 {i_cluster_r2_c3_*/*clk i_cluster_r3_c3_*/*clk } t24 {i_cluster_r2_c4_*/*clk i_cluster_r3_c4_*/*clk } t25 {i_cluster_r2_c5_*/*clk i_cluster_r3_c5_*/*clk } t26 {i_cluster_r2_c6_*/*clk i_cluster_r3_c6_*/*clk } t27 {i_cluster_r2_c7_*/*clk i_cluster_r3_c7_*/*clk } \
#t40 {i_cluster_r4_c0_*/*clk i_cluster_r5_c0_*/*clk } t41 {i_cluster_r4_c1_*/*clk i_cluster_r5_c1_*/*clk } t42 {i_cluster_r4_c2_*/*clk i_cluster_r5_c2_*/*clk } t43 {i_cluster_r4_c3_*/*clk i_cluster_r5_c3_*/*clk } t44 {i_cluster_r4_c4_*/*clk i_cluster_r5_c4_*/*clk } t45 {i_cluster_r4_c5_*/*clk i_cluster_r5_c5_*/*clk } t46 {i_cluster_r4_c6_*/*clk i_cluster_r5_c6_*/*clk } t47 {i_cluster_r4_c7_*/*clk i_cluster_r5_c7_*/*clk } \
#t60 {i_cluster_r6_c0_*/*clk i_cluster_r7_c0_*/*clk } t61 {i_cluster_r6_c1_*/*clk i_cluster_r7_c1_*/*clk } t62 {i_cluster_r6_c2_*/*clk i_cluster_r7_c2_*/*clk } t63 {i_cluster_r6_c3_*/*clk i_cluster_r7_c3_*/*clk } t64 {i_cluster_r6_c4_*/*clk i_cluster_r7_c4_*/*clk } t65 {i_cluster_r6_c5_*/*clk i_cluster_r7_c5_*/*clk } t66 {i_cluster_r6_c6_*/*clk i_cluster_r7_c6_*/*clk } t67 {i_cluster_r6_c7_*/*clk i_cluster_r7_c7_*/*clk }  ]

set tap_groups_list [list \
t00 {*r0_c0*/grid_clk } t01 {*r0_c1*/grid_clk } t02 {*r0_c2*/grid_clk } t03 {*r0_c3*/grid_clk } t04 {*r0_c4*/grid_clk } t05 {*r0_c5*/grid_clk } t06 {*r0_c6*/grid_clk } t07 {*r0_c7*/grid_clk } \
t10 {*r1_c0*/grid_clk } t11 {*r1_c1*/grid_clk } t12 {*r1_c2*/grid_clk } t13 {*r1_c3*/grid_clk } t14 {*r1_c4*/grid_clk } t15 {*r1_c5*/grid_clk } t16 {*r1_c6*/grid_clk } t17 {*r1_c7*/grid_clk } \
t20 {*r2_c0*/grid_clk } t21 {*r2_c1*/grid_clk } t22 {*r2_c2*/grid_clk } t23 {*r2_c3*/grid_clk } t24 {*r2_c4*/grid_clk } t25 {*r2_c5*/grid_clk } t26 {*r2_c6*/grid_clk } t27 {*r2_c7*/grid_clk } \
t30 {*r3_c0*/grid_clk } t31 {*r3_c1*/grid_clk } t32 {*r3_c2*/grid_clk } t33 {*r3_c3*/grid_clk } t34 {*r3_c4*/grid_clk } t35 {*r3_c5*/grid_clk } t36 {*r3_c6*/grid_clk } t37 {*r3_c7*/grid_clk } \
t40 {*r4_c0*/grid_clk } t41 {*r4_c1*/grid_clk } t42 {*r4_c2*/grid_clk } t43 {*r4_c3*/grid_clk } t44 {*r4_c4*/grid_clk } t45 {*r4_c5*/grid_clk } t46 {*r4_c6*/grid_clk } t47 {*r4_c7*/grid_clk } \
t50 {*r5_c0*/grid_clk } t51 {*r5_c1*/grid_clk } t52 {*r5_c2*/grid_clk } t53 {*r5_c3*/grid_clk } t54 {*r5_c4*/grid_clk } t55 {*r5_c5*/grid_clk } t56 {*r5_c6*/grid_clk } t57 {*r5_c7*/grid_clk } \
t60 {*r6_c0*/grid_clk } t61 {*r6_c1*/grid_clk } t62 {*r6_c2*/grid_clk } t63 {*r6_c3*/grid_clk } t64 {*r6_c4*/grid_clk } t65 {*r6_c5*/grid_clk } t66 {*r6_c6*/grid_clk } t67 {*r6_c7*/grid_clk } \
t70 {*r7_c0*/grid_clk } t71 {*r7_c1*/grid_clk } t72 {*r7_c2*/grid_clk } t73 {*r7_c3*/grid_clk } t74 {*r7_c4*/grid_clk } t75 {*r7_c5*/grid_clk } t76 {*r7_c6*/grid_clk } t77 {*r7_c7*/grid_clk } ]

# block_all_horizontal $hier_cells
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level0_tap 600 false {0 -500}
remove_my_blockages

### LEVEL 1 TAPS ###
# for {set r 0} { $r < 8 } { incr r 1} { for {set c 0} { $c < 8 } { incr c 2 } { puts -nonew "t$r$c \{level0_tap*t$r$c/i level0_tap*t$r[expr $c + 1]/i\} "  } ; puts "" }
set tap_groups_list [list \
t00 {level0_tap*t00/i level0_tap*t01/i} t02 {level0_tap*t02/i level0_tap*t03/i} t04 {level0_tap*t04/i level0_tap*t05/i} t06 {level0_tap*t06/i level0_tap*t07/i} \
t10 {level0_tap*t10/i level0_tap*t11/i} t12 {level0_tap*t12/i level0_tap*t13/i} t14 {level0_tap*t14/i level0_tap*t15/i} t16 {level0_tap*t16/i level0_tap*t17/i} \
t20 {level0_tap*t20/i level0_tap*t21/i} t22 {level0_tap*t22/i level0_tap*t23/i} t24 {level0_tap*t24/i level0_tap*t25/i} t26 {level0_tap*t26/i level0_tap*t27/i} \
t30 {level0_tap*t30/i level0_tap*t31/i} t32 {level0_tap*t32/i level0_tap*t33/i} t34 {level0_tap*t34/i level0_tap*t35/i} t36 {level0_tap*t36/i level0_tap*t37/i} \
t40 {level0_tap*t40/i level0_tap*t41/i} t42 {level0_tap*t42/i level0_tap*t43/i} t44 {level0_tap*t44/i level0_tap*t45/i} t46 {level0_tap*t46/i level0_tap*t47/i} \
t50 {level0_tap*t50/i level0_tap*t51/i} t52 {level0_tap*t52/i level0_tap*t53/i} t54 {level0_tap*t54/i level0_tap*t55/i} t56 {level0_tap*t56/i level0_tap*t57/i} \
t60 {level0_tap*t60/i level0_tap*t61/i} t62 {level0_tap*t62/i level0_tap*t63/i} t64 {level0_tap*t64/i level0_tap*t65/i} t66 {level0_tap*t66/i level0_tap*t67/i} \
t70 {level0_tap*t70/i level0_tap*t71/i} t72 {level0_tap*t72/i level0_tap*t73/i} t74 {level0_tap*t74/i level0_tap*t75/i} t76 {level0_tap*t76/i level0_tap*t77/i} ]


# block_all_horizontal $hier_cells
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level1_tap 35
remove_my_blockages

### LEVEL 2 TAPS ###
# for {set r 0} { $r < 8 } { incr r 1} { for {set c 0} { $c < 8 } { incr c 4 } { puts -nonew "t$r$c \{level1_tap_t$r$c/i level1_tap_t$r[expr $c + 2]/i\} "  } ; puts "" }
set tap_groups_list [list \
t00 {level1_tap_t00/i level1_tap_t02/i} t04 {level1_tap_t04/i level1_tap_t06/i} \
t10 {level1_tap_t10/i level1_tap_t12/i} t14 {level1_tap_t14/i level1_tap_t16/i} \
t20 {level1_tap_t20/i level1_tap_t22/i} t24 {level1_tap_t24/i level1_tap_t26/i} \
t30 {level1_tap_t30/i level1_tap_t32/i} t34 {level1_tap_t34/i level1_tap_t36/i} \
t40 {level1_tap_t40/i level1_tap_t42/i} t44 {level1_tap_t44/i level1_tap_t46/i} \
t50 {level1_tap_t50/i level1_tap_t52/i} t54 {level1_tap_t54/i level1_tap_t56/i} \
t60 {level1_tap_t60/i level1_tap_t62/i} t64 {level1_tap_t64/i level1_tap_t66/i} \
t70 {level1_tap_t70/i level1_tap_t72/i} t74 {level1_tap_t74/i level1_tap_t76/i} ]


# block_all_vertical $hier_cells
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level2_tap 200 true
remove_my_blockages


### LEVEL 3 TAPS ###
## TODO: Need to insert each line (L3 + True on split), than insert driver on prev line L3, thans insert new line L3, repeat
## TODO: Or maybeeeee - 1st (before L0) insert driver per row, then build trees in each row...
set tap_groups_list [list t00 {level2_tap*t00/i level2_tap*t04/i} \
                          t10 {level2_tap*t10/i level2_tap*t14/i} \
                          t20 {level2_tap*t20/i level2_tap*t24/i} \
                          t30 {level2_tap*t30/i level2_tap*t34/i} \
                          t40 {level2_tap*t40/i level2_tap*t44/i} \
                          t50 {level2_tap*t50/i level2_tap*t54/i} \
                          t60 {level2_tap*t60/i level2_tap*t64/i} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level3_tap 50 true

set tap_groups_list [list t70 {level2_tap*t70/i level2_tap*t74/i} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level3_tap 50 true {-60 0}


set clock_cells [add_to_collection [get_cells -hier *level*_tap*] [get_cells -hier *tree_source*]]
set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]

t $clock_nets {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] 0]} \
              {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] 0] } \
              {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] 0] \
              + [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] 0]}
t [get_pins */grid_clk] {count_levels_from_source $o}


### WEST ###
set tap_groups_list [list ck00 {*quad_west_filler_r0/grid_clk} \
                          ck10 {*quad_west_filler_r1/grid_clk} \
                          ck20 {*quad_west_filler_r2/grid_clk} \
                          ck30 {*quad_west_filler_r3/grid_clk} \
                          ck40 {*quad_west_filler_r4/grid_clk} \
                          ck50 {*quad_west_filler_r5/grid_clk} \
                          ck60 {*quad_west_filler_r6/grid_clk} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level_west_clock_tap 50 false {0 -550}
# CONNECT PORTS AND CONNECT NEW TAPS TO LAST DRIVER
### TODO: ADD LPDS48X REPEATER BETWEEN HTREE LAST LEVEL AND WEST FILLER DRIVER
connect_pin  -inst level_west_clock_tap_ck00 -pin i -net level0_tap_t00_net
connect_pin  -inst level_west_clock_tap_ck10 -pin i -net level0_tap_t10_net
connect_pin  -inst level_west_clock_tap_ck20 -pin i -net level0_tap_t20_net
connect_pin  -inst level_west_clock_tap_ck30 -pin i -net level0_tap_t30_net
connect_pin  -inst level_west_clock_tap_ck40 -pin i -net level0_tap_t40_net
connect_pin  -inst level_west_clock_tap_ck50 -pin i -net level0_tap_t50_net
connect_pin  -inst level_west_clock_tap_ck60 -pin i -net level0_tap_t60_net

connect_hpin - -net level_west_clock_tap_ck00_net -pin_name grid_clk_to_west[0]
connect_hpin - -net level_west_clock_tap_ck20_net -pin_name grid_clk_to_west[1]
connect_hpin - -net level_west_clock_tap_ck40_net -pin_name grid_clk_to_west[2]
connect_hpin - -net level_west_clock_tap_ck60_net -pin_name grid_clk_to_west[3]

set tap_groups_list [list ck00 {level_west_clock_tap_ck00/i} \
                          ck10 {level_west_clock_tap_ck10/i} \
                          ck20 {level_west_clock_tap_ck20/i} \
                          ck30 {level_west_clock_tap_ck30/i} \
                          ck40 {level_west_clock_tap_ck40/i} \
                          ck50 {level_west_clock_tap_ck50/i} \
                          ck60 {level_west_clock_tap_ck60/i} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level_west_clock_even_tap 50 false {0 0}


write_db out/db/post_west_buffering.enc.dat
return
### EAST ###
set tap_groups_list [list ck00 {*quad_east_filler_r0/grid_clk} \
                          ck10 {*quad_east_filler_r1/grid_clk} \
                          ck20 {*quad_east_filler_r2/grid_clk} \
                          ck30 {*quad_east_filler_r3/grid_clk} \
                          ck40 {*quad_east_filler_r4/grid_clk} \
                          ck50 {*quad_east_filler_r5/grid_clk} \
                          ck60 {*quad_east_filler_r6/grid_clk} \
                          ck70 {*quad_east_filler_r7/grid_clk} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level_east_clock_tap 80 false {0 -550}
# CONNECT PORTS AND CONNECT NEW TAPS TO LAST DRIVER
### TODO: ADD LPDS48X REPEATER BETWEEN HTREE LAST LEVEL AND east FILLER DRIVER
connect_pin  -inst level_east_clock_tap_ck00 -pin i -net level0_tap_t07_net
connect_pin  -inst level_east_clock_tap_ck10 -pin i -net level0_tap_t17_net
connect_pin  -inst level_east_clock_tap_ck20 -pin i -net level0_tap_t27_net
connect_pin  -inst level_east_clock_tap_ck30 -pin i -net level0_tap_t37_net
connect_pin  -inst level_east_clock_tap_ck40 -pin i -net level0_tap_t47_net
connect_pin  -inst level_east_clock_tap_ck50 -pin i -net level0_tap_t57_net
connect_pin  -inst level_east_clock_tap_ck60 -pin i -net level0_tap_t67_net
connect_pin  -inst level_east_clock_tap_ck70 -pin i -net level0_tap_t77_net

connect_hpin - -net level_east_clock_tap_ck00_net -pin_name grid_clk_to_east[0]
connect_hpin - -net level_east_clock_tap_ck20_net -pin_name grid_clk_to_east[1]
connect_hpin - -net level_east_clock_tap_ck40_net -pin_name grid_clk_to_east[2]
connect_hpin - -net level_east_clock_tap_ck60_net -pin_name grid_clk_to_east[3]


set tap_groups_list [list ck00 {level_east_clock_tap_ck00/i} \
                          ck10 {level_east_clock_tap_ck10/i} \
                          ck20 {level_east_clock_tap_ck20/i} \
                          ck30 {level_east_clock_tap_ck30/i} \
                          ck40 {level_east_clock_tap_ck40/i} \
                          ck50 {level_east_clock_tap_ck50/i} \
                          ck60 {level_east_clock_tap_ck60/i} \
                          ck70 {level_east_clock_tap_ck70/i} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level_east_clock_even_tap 50 false {0 0}


### NORTH ###
set tap_groups_list [list ck00 {*quad_north_filler_c0/grid_clk *quad_north_filler_c1/grid_clk} \
                          ck01 {*quad_north_filler_c2/grid_clk *quad_north_filler_c3/grid_clk} \
                          ck02 {*quad_north_filler_c4/grid_clk *quad_north_filler_c5/grid_clk} \
                          ck03 {*quad_north_filler_c6/grid_clk *quad_north_filler_c7/grid_clk} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level_north_clock_tap 80 

connect_pin  -inst level_north_clock_tap_ck00 -pin i -net level1_tap_t00_net
connect_pin  -inst level_north_clock_tap_ck01 -pin i -net level1_tap_t02_net
connect_pin  -inst level_north_clock_tap_ck02 -pin i -net level1_tap_t04_net
connect_pin  -inst level_north_clock_tap_ck03 -pin i -net level1_tap_t06_net

connect_hpin - -net level_north_clock_tap_ck00_net -pin_name grid_clk_to_north[0]
connect_hpin - -net level_north_clock_tap_ck01_net -pin_name grid_clk_to_north[1]
connect_hpin - -net level_north_clock_tap_ck02_net -pin_name grid_clk_to_north[2]
connect_hpin - -net level_north_clock_tap_ck03_net -pin_name grid_clk_to_north[3]

set tap_groups_list [list ck00 {level_north_clock_tap_ck00/i} \
                          ck01 {level_north_clock_tap_ck01/i} \
                          ck02 {level_north_clock_tap_ck02/i} \
                          ck03 {level_north_clock_tap_ck03/i} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level_north_clock_even_tap_0 50 false {0 -1000} 


set tap_groups_list [list ck00 {level_north_clock_tap_ck00/i} \
                          ck01 {level_north_clock_tap_ck01/i} \
                          ck02 {level_north_clock_tap_ck02/i} \
                          ck03 {level_north_clock_tap_ck03/i} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level_north_clock_even_tap_1 50 false {0 -10} F6UNAA_LPDSINVG3X48


### SOUTH ###
set tap_groups_list [list ck00 {*quad_south_filler_c0/grid_clk *quad_south_filler_c1/grid_clk} \
                          ck01 {*quad_south_filler_c2/grid_clk *quad_south_filler_c3/grid_clk} \
                          ck02 {*quad_south_filler_c4/grid_clk *quad_south_filler_c5/grid_clk} \
                          ck03 {*quad_south_filler_c6/grid_clk *quad_south_filler_c7/grid_clk} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level_south_clock_tap 80 

connect_pin  -inst level_south_clock_tap_ck00 -pin i -net level0_tap_t70_net
connect_pin  -inst level_south_clock_tap_ck01 -pin i -net level0_tap_t72_net
connect_pin  -inst level_south_clock_tap_ck02 -pin i -net level0_tap_t74_net
connect_pin  -inst level_south_clock_tap_ck03 -pin i -net level0_tap_t76_net

# Will be in PN99 netlist
connect_hpin - -net level_south_clock_tap_ck00_net -pin_name grid_clk_to_south[0]
connect_hpin - -net level_south_clock_tap_ck01_net -pin_name grid_clk_to_south[1]
connect_hpin - -net level_south_clock_tap_ck02_net -pin_name grid_clk_to_south[2]
connect_hpin - -net level_south_clock_tap_ck03_net -pin_name grid_clk_to_south[3]

set tap_groups_list [list ck00 {level_south_clock_tap_ck00/i} \
                          ck01 {level_south_clock_tap_ck01/i} \
                          ck02 {level_south_clock_tap_ck02/i} \
                          ck03 {level_south_clock_tap_ck03/i} ]
set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list level_south_clock_even_tap 80 


### SOUTH EAST ###
set_db eco_honor_dont_use false
set_db eco_update_timing false
set_db eco_refine_place false
set_db eco_check_logical_equivalence false

set in_name  i_grid_quad_south_filler_i_grid_quad_south_filler_east
set out_name level_south_clock_tap_ck03/o
connect_pin  -inst $in_name -pin grid_clk -net [get_db [get_nets -of $out_name] .name]

set location [lindex [get_db [get_pins $out_name] .location] 0]
set x        [expr [lindex $location 0] +5]
set y        [expr [lindex $location 1] +3]
eco_add_repeater -cells $repeater_template    -name "level_south_east_clock_rpt_tap_0"   -new_net_name "level_south_east_clock_rpt_tap_0_net"   -pins $in_name/grid_clk -location [list $x $y]
eco_add_repeater -cells F6UNAA_LPDSINVG3X48   -name "level_south_east_clock_rpt_tap_0_0" -new_net_name "level_south_east_clock_rpt_tap_0_0_net" -pins level_south_east_clock_rpt_tap_0/i -location [list $x $y]
eco_add_repeater -cells F6UNAA_LPDSINVG3X48   -name "level_south_east_clock_rpt_tap_0_1" -new_net_name "level_south_east_clock_rpt_tap_0_1_net" -pins level_south_east_clock_rpt_tap_0_0/i -location [list $x $y]

set_db eco_honor_dont_use true
set_db eco_update_timing true
set_db eco_refine_place true
set_db eco_check_logical_equivalence true


be_legalize_super_inv [get_db [get_cells level_*_clock*tap*] .name] true 400

write_db out/db/post_tap_insertion.enc.dat


# MOVE EVEN TAPS TO SIT CLOSE TO DRIVER INSTEAD OF RECEIVER
place_inst level_west_clock_even_tap_ck60  {628.5495 1286.67} mx 
place_inst level_west_clock_even_tap_ck20  {628.5495 5802.51} mx 
place_inst level_west_clock_even_tap_ck30  {628.5495 4673.55} mx 
place_inst level_west_clock_even_tap_ck40  {628.5495 3544.59} mx 
place_inst level_west_clock_even_tap_ck00  {628.5495 8060.43} mx 
place_inst level_west_clock_even_tap_ck50  {628.5495 2415.63} mx 
place_inst level_west_clock_even_tap_ck10  {628.5495 6931.47} mx 
place_inst level_east_clock_even_tap_ck60  {9120.8655 1286.67} mx 
place_inst level_east_clock_even_tap_ck20  {9120.8655 5802.51} mx 
place_inst level_east_clock_even_tap_ck70  {9120.8655 157.71}  mx 
place_inst level_east_clock_even_tap_ck30  {9120.8655 4673.55} mx 
place_inst level_east_clock_even_tap_ck40  {9120.8655 3544.59} mx 
place_inst level_east_clock_even_tap_ck00  {9120.8655 8060.43} mx 
place_inst level_east_clock_even_tap_ck50  {9120.8655 2415.63} mx 
place_inst level_east_clock_even_tap_ck10  {9120.8655 6931.47} mx 
place_inst level_south_clock_even_tap_ck02 {5512.3095 147.63} mx 
place_inst level_south_clock_even_tap_ck03 {7927.0575 157.71} mx 
place_inst level_south_clock_even_tap_ck00 {927.0015 147.63}  mx 
place_inst level_south_clock_even_tap_ck01 {3043.2975 147.63} mx 



### Balancve inversion ###
# 
#
#levelx_tap_row_t0/i   9     
#levelx_tap_row_t2/i   7     
#levelx_tap_row_t4/i   5     
#levelx_tap_row_t6/i   3     
set tap_groups_list [list \
t0x {levelx_tap_row_t0/i } \
t1x {levelx_tap_row_t1/i } \
t2x {levelx_tap_row_t2/i } \
t3x {levelx_tap_row_t3/i } \
t4x {levelx_tap_row_t4/i } \
t5x {levelx_tap_row_t5/i } \
t6x {levelx_tap_row_t6/i } ]
#t7 {*r7_c*/grid_clk } ]

set tap_pins_list [create_tap_groups $tap_groups_list ]
insert_taps $tap_pins_list levelx_tap_row 53 false {0 -10} F6UNAA_LPDSINVG3X48



set clock_cells [add_to_collection [get_cells -hier *level*_tap*] [get_cells -hier *tree_source*]]
set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]

t $clock_nets {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] 0]} \
              {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] 0] } \
              {expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.y]] 0] \
              + [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $o] .location.x]] 0]}
t [get_pins */grid_clk] {count_levels_from_source $o}


### BREAKDOWN LONG NETS ###
#set clock_cells [remove_from_collection [get_cells -hier *level*_tap*] [get_cells level_*_clock*tap*]]
#set clock_nets  [get_nets -of $clock_cells]
#break_up_long_clock_nets $clock_nets 1000 "" 
set clock_nets [get_nets *level3_tap_*t*_net*]
break_up_long_clock_nets $clock_nets 1300 

set_db [get_db nets grid_clk] .dont_touch true

end_record

set STAGE cts
#source scripts/templates/quad/block_carpets.tcl

set clock_cells [add_to_collection [get_cells -hier *level*tap*] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]

set_db $clock_cells .place_status fixed

delete_obj [get_db place_blockages *cts*]

place_detail 

set route_blockages [get_db route_blockages *temp*]
delete_obj $route_blockages

set route_blockages [get_db route_blockages *do_not_route_m1716_please*]
delete_obj $route_blockages

puts "-I- Building via ladder"
be_build_super_inv_vp

set_db route_early_global_top_routing_layer 18
set_db design_top_routing_layer 18

if { [get_db route_rules grid_clk_vp_rule_2] == "" } {
create_route_rule -name grid_clk_vp_rule_2 -width   {M1 0.02  M2 0.02  M3 0.02  M4 0.02  M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 \
                                         -spacing {M1 0.014 M2 0.015 M3 0.022 M4 0.022 M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}
}
                                         
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

write_db -verilog out/db/${DESIGN_NAME}.post_grid_clk_route.enc.dat

set_db $clock_cells .place_status fixed
set_db $clock_nets .dont_touch true
set_db $clock_nets .wires.status fixed
set_db $clock_nets .vias.status fixed

write_db -verilog      out/db/${DESIGN_NAME}.${STAGE}.enc.dat
write_def -routing     out/def/${DESIGN_NAME}.${STAGE}.def.gz
write_lef_abstract -5.8 \
-top_layer $MAX_ROUTING_LAYER \
-pg_pin_layers $MAX_ROUTING_LAYER \
-stripe_pins \
-property \
out/lef/${DESIGN_NAME}.${STAGE}.lef

so $clock_cells
write_def -selected ../out/def/${DESIGN_NAME}.clock_cells_placement_new.def
so $clock_nets 
write_def -routing -selected out/def/${DESIGN_NAME}.grid_clk_route_and_vp.enc.dat

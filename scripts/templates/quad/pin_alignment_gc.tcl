align_pins_b2b i_grid_clusters_wrap_i_cluster_r2_c4 i_grid_clusters_wrap_i_cluster_r3_c4 v true
align_pins_b2b i_grid_clusters_wrap_i_cluster_r4_c4 i_grid_clusters_wrap_i_cluster_r3_c4 v true

### NFI2TCU
#quick_spread_pins i_grid_quad_west_filler_i_grid_quad_west_filler_r3    i_grid_tcu_col_i_grid_tcu_cluster_r3_c0_i_tcu_top  h 
align_pins_b2b i_grid_clusters_wrap_i_cluster_r0_c1 i_grid_tcu_col_i_grid_tcu_cluster_r0_c0  h true

### NFI2SOUTHCOL0
align_pins_b2b i_grid_tcu_col_i_grid_ecore_cluster_r7_c0  i_grid_quad_south_filler_i_grid_quad_south_filler_c0 v true

### NFI2SOUTH REG
align_pins_b2b i_grid_clusters_wrap_i_cluster_r7_c3    i_grid_quad_south_filler_i_grid_quad_south_filler_c3 v true ; 

### NFI2NORTH 
align_pins_b2b i_grid_clusters_wrap_i_cluster_r0_c2    i_grid_quad_north_filler_i_grid_quad_north_filler_c2 v true

### NFI2EAST
align_pins_b2b i_grid_clusters_wrap_i_cluster_r0_c7  i_grid_quad_east_filler_i_grid_quad_east_filler_r0 h true
align_pins_b2b i_grid_clusters_wrap_i_cluster_r1_c7  i_grid_quad_east_filler_i_grid_quad_east_filler_r1 h true
align_pins_b2b i_grid_clusters_wrap_i_cluster_r4_c7  i_grid_quad_east_filler_i_grid_quad_east_filler_r4 h true
align_pins_b2b i_grid_clusters_wrap_i_cluster_r7_c7  i_grid_quad_east_filler_i_grid_quad_east_filler_r7 h true

### NORHT2TCU
align_pins_b2b i_grid_quad_north_filler_i_grid_quad_north_filler_c0 i_grid_tcu_col_i_grid_tcu_cluster_r0_c0 v true

### WEST
align_pins_b2b i_grid_tcu_col_i_grid_tcu_cluster_r6_c0 i_grid_quad_west_filler_i_grid_quad_west_filler_r6 h true
align_pins_b2b i_grid_tcu_col_i_grid_tcu_cluster_r6_c0 i_grid_quad_west_filler_i_grid_quad_west_filler_r6 h true
align_pins_b2b i_grid_tcu_col_i_grid_tcu_cluster_r6_c0 i_grid_quad_west_filler_i_grid_quad_west_filler_r6 h true

### 
align_pins_b2b i_grid_tcu_col_i_grid_tcu_cluster_r6_c0 i_grid_tcu_col_i_grid_ecore_cluster_r7_c0 v true
align_pins_b2b i_grid_clusters_wrap_i_cluster_r7_c1    i_grid_tcu_col_i_grid_ecore_cluster_r7_c0 h true


### REWIND...
align_pins_b2b i_grid_quad_north_filler_i_grid_quad_north_filler_c3  i_grid_clusters_wrap_i_cluster_r0_c3_i_cbu_i_cbui_top  v true
align_pins_b2b i_grid_quad_south_filler_i_grid_quad_south_filler_c1  i_grid_clusters_wrap_i_cluster_r7_c1_i_cbu_i_cbue_top v true
align_pins_b2b i_grid_clusters_wrap_i_cluster_r2_c2_i_cbu_i_cbue_top i_grid_clusters_wrap_i_cluster_r3_c2_i_cbu_i_cbui_top v true
align_pins_b2b i_grid_clusters_wrap_i_cluster_r2_c2_i_cbu_i_cbue_top i_grid_clusters_wrap_i_cluster_r2_c2_i_cbu_i_cbui_top v true

### TCU2TCU
align_pins_b2b i_grid_tcu_col_i_grid_tcu_cluster_r1_c0    i_grid_tcu_col_i_grid_tcu_cluster_r0_c0 v true


### CBUIRIGHT2TCULEFT
quick_spread_pins i_grid_quad_west_filler_i_grid_quad_west_filler_r3    i_grid_tcu_col_i_grid_tcu_cluster_r3_c0_i_tcu_top  h 
copy_pins i_grid_clusters_wrap_i_cluster_r3_c3 i_grid_tcu_col_i_grid_tcu_cluster_r3_c0 h 0 \
                        {big_rs_ms_west_ack_msg big_rs_ms_west_ack_msg \
                         big_rs_ms_west_ack_valid big_rs_ms_west_ack_valid \
                         big_rs_ms_west_req_msg big_rs_ms_west_req_msg \
                         big_rs_ms_west_req_valid big_rs_ms_west_req_valid \
                         cbus_to_west_data cbus_to_west_data \
                         cbus_to_west_ready cbus_to_west_ready \
                         cbus_to_west_valid cbus_to_west_valid \
                         dlink_to_west_dlink_data dlink_to_west_dlink_data \
                         dlink_to_west_dlink_ready dlink_to_west_dlink_ready \
                         dlink_to_west_dlink_valid dlink_to_west_dlink_valid \
                         nbus_to_west_nbus_data nbus_to_west_nbus_data \
                         nbus_to_west_nbus_ready nbus_to_west_nbus_ready \
                         nbus_to_west_nbus_valid nbus_to_west_nbus_valid \
                         west_direct_in_data_channels west_direct_in_data_channels \
                         west_direct_in_data_valid west_direct_in_data_valid \
                         west_direct_out_data_channels west_direct_out_data_channels \
                         west_direct_out_data_valid west_direct_out_data_valid \
                         west_dlink_to_dlink_data west_dlink_to_dlink_data \
                         west_dlink_to_dlink_ready west_dlink_to_dlink_ready \
                         west_dlink_to_dlink_valid west_dlink_to_dlink_valid \
                         west_nbus_to_nbus_data west_nbus_to_nbus_data \
                         west_nbus_to_nbus_ready west_nbus_to_nbus_ready \
                         west_nbus_to_nbus_valid west_nbus_to_nbus_valid \
                         west_strap_logical_col west_strap_logical_col \
                         west_tlm_ts_sync west_tlm_ts_sync \
                         west_to_cbus_data west_to_cbus_data \
                         west_to_cbus_ready west_to_cbus_ready \
                         west_to_cbus_valid west_to_cbus_valid }
                        
                        

### TCU2WEST
align_pins_b2b i_grid_tcu_col_i_grid_tcu_cluster_r3_c0 i_grid_quad_west_filler_i_grid_quad_west_filler_r3 h true
align_pins_b2b i_grid_clusters_wrap_i_cluster_r7_c1    i_grid_tcu_col_i_grid_ecore_cluster_r7_c0 h true
align_pins_b2b i_grid_tcu_col_i_grid_tcu_cluster_r6_c0 i_grid_tcu_col_i_grid_ecore_cluster_r7_c0 v true
align_pins_b2b i_grid_quad_south_filler_i_grid_quad_south_filler_c0 i_grid_tcu_col_i_grid_ecore_cluster_r7_c0 v true

### WESTRIGHT2LEFT
mirror_bus2bus i_grid_quad_west_filler_i_grid_quad_west_filler_r3/east_dlink_to_dlink i_grid_quad_west_filler_i_grid_quad_west_filler_r3/dlink_to_west_dlink h left
mirror_bus2bus i_grid_quad_west_filler_i_grid_quad_west_filler_r3/dlink_to_east_dlink i_grid_quad_west_filler_i_grid_quad_west_filler_r3/west_dlink_to_dlink h left



# EAST2EAST
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r0 i_grid_quad_east_filler_i_grid_quad_east_filler_r1 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r2 i_grid_quad_east_filler_i_grid_quad_east_filler_r1 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r3 i_grid_quad_east_filler_i_grid_quad_east_filler_r2 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r6 i_grid_quad_east_filler_i_grid_quad_east_filler_r7 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r6 i_grid_quad_east_filler_i_grid_quad_east_filler_r5 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r4 i_grid_quad_east_filler_i_grid_quad_east_filler_r5 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r1 i_grid_quad_east_filler_i_grid_quad_east_filler_r0 v true


align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r0 i_grid_quad_east_filler_i_grid_quad_east_filler_r1 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r0 i_grid_quad_east_filler_i_grid_quad_east_filler_r1 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r0 i_grid_quad_east_filler_i_grid_quad_east_filler_r1 v true

align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r1 i_grid_quad_east_filler_i_grid_quad_east_filler_r2 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r1 i_grid_quad_east_filler_i_grid_quad_east_filler_r2 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r1 i_grid_quad_east_filler_i_grid_quad_east_filler_r2 v true

align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r2 i_grid_quad_east_filler_i_grid_quad_east_filler_r3 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r2 i_grid_quad_east_filler_i_grid_quad_east_filler_r3 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r2 i_grid_quad_east_filler_i_grid_quad_east_filler_r3 v true

align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r3 i_grid_quad_east_filler_i_grid_quad_east_filler_r4 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r3 i_grid_quad_east_filler_i_grid_quad_east_filler_r4 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r3 i_grid_quad_east_filler_i_grid_quad_east_filler_r4 v true

align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r4 i_grid_quad_east_filler_i_grid_quad_east_filler_r5 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r4 i_grid_quad_east_filler_i_grid_quad_east_filler_r5 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r4 i_grid_quad_east_filler_i_grid_quad_east_filler_r5 v true

align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r5 i_grid_quad_east_filler_i_grid_quad_east_filler_r6 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r5 i_grid_quad_east_filler_i_grid_quad_east_filler_r6 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r5 i_grid_quad_east_filler_i_grid_quad_east_filler_r6 v true

align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r6 i_grid_quad_east_filler_i_grid_quad_east_filler_r7 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r6 i_grid_quad_east_filler_i_grid_quad_east_filler_r7 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r6 i_grid_quad_east_filler_i_grid_quad_east_filler_r7 v true

align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r7 i_grid_quad_south_filler_i_grid_quad_south_filler_east v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r7 i_grid_quad_south_filler_i_grid_quad_south_filler_east v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r7 i_grid_quad_south_filler_i_grid_quad_south_filler_east v true

# South2South
align_pins_b2b i_grid_quad_south_filler_i_grid_quad_south_filler_c7 i_grid_quad_south_filler_i_grid_quad_south_filler_east h true
align_pins_b2b i_grid_quad_south_filler_i_grid_quad_south_filler_c1 i_grid_quad_south_filler_i_grid_quad_south_filler_c0 h true

# west2west
align_pins_b2b i_grid_quad_west_filler_i_grid_quad_west_filler_r0 i_grid_quad_west_filler_i_grid_quad_west_filler_r1 v true
align_pins_b2b i_grid_quad_west_filler_i_grid_quad_west_filler_r6 i_grid_tcu_col_i_grid_ecore_cluster_r7_c0 v true


############################################################################################################################################################
#### PLACE CLOCK PINS
edit_pin -hinst i_grid_clusters_wrap_i_cluster_r2_c6_i_nfi_mcu_top    -pin grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {1.46 544.26} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -hinst i_grid_clusters_wrap_i_cluster_r2_c6_i_cbu_i_cbue_top -pin grid_clk -layer M15 -assign {785.764 544.32} -fixed_pin -fix_overlap 1 -snap track
edit_pin -hinst i_grid_clusters_wrap_i_cluster_r2_c6_i_cbu_i_cbui_top -pin grid_clk -layer M15 -assign {785.764 0} -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -hinst i_grid_tcu_col_i_grid_tcu_cluster_r2_c0_i_tcu_top     -pin grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {785.764 544.32} -fixed_pin -fix_overlap 1 -side inside -snap track
#North Filler:
edit_pin -hinst [lindex [get_db [get_db insts *filler*north*] .name] 0] -pin grid_clk -layer M15 -assign {785.764 0} -fixed_pin -fix_overlap 1 -snap track

#South Filler (Reg):
edit_pin -hinst i_grid_quad_south_filler_i_grid_quad_south_filler_c7   -pin grid_clk -layer M15 -assign {785.764 20.16} -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -hinst i_grid_quad_south_filler_i_grid_quad_south_filler_east -pin grid_clk -layer M15 -assign {25      20.16} -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track
edit_pin -hinst i_grid_quad_south_filler_i_grid_quad_south_filler_c0   -pin grid_clk -layer M15 -assign {400     20.16} -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track

#East Filler:
edit_pin -hinst i_grid_quad_east_filler_i_grid_quad_east_filler_r7 -pin grid_clk      -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {75.14 544.13} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -hinst i_grid_quad_east_filler_i_grid_quad_east_filler_r7 -pin east_grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {86.396 544.26} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -hinst i_grid_quad_east_filler_i_grid_quad_east_filler_r4 -pin grid_clk      -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {75.14 544.13} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -hinst i_grid_quad_east_filler_i_grid_quad_east_filler_r4 -pin east_grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {86.396 544.26} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -hinst i_grid_quad_east_filler_i_grid_quad_east_filler_r6 -pin grid_clk      -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {75.14 544.13} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -hinst i_grid_quad_east_filler_i_grid_quad_east_filler_r6 -pin east_grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {86.396 544.26} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -hinst i_grid_quad_east_filler_i_grid_quad_east_filler_r0 -pin grid_clk      -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {75.14 544.13} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -hinst i_grid_quad_east_filler_i_grid_quad_east_filler_r0 -pin east_grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {86.396 544.26} -fixed_pin -fix_overlap 1 -side inside -snap track

#West Filler:
edit_pin -hinst i_grid_quad_west_filler_i_grid_quad_west_filler_r6 -pin grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {13.566 544.26} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -hinst i_grid_quad_west_filler_i_grid_quad_west_filler_r7 -pin grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {600 1040} -fixed_pin -fix_overlap 1 -side inside -snap track
############################################################################################################################################################


### SOUTH EAST PLACE BY EDGE
set cell i_grid_quad_south_filler_i_grid_quad_south_filler_east
set pattern ""
if { $pattern == "" } {
    set pins [get_pins $cell/* -filter full_name!~*grid_clk]
} else {
    set pins [get_pins $cell/$pattern -filter full_name!~*grid_clk]
}

set east  [filter_collection $pins full_name=~*/*east*]
set west  [filter_collection $pins full_name=~*/*west*]
set north [filter_collection $pins full_name=~*/*north*]
set south [filter_collection $pins full_name=~*/*south*]

set ur [lindex [get_db [get_cells $cell] .base_cell.bbox.ur] 0]
lassign $ur xh yh
set east_line  [list $xh 2 $xh [expr $yh - 2]]
set west_line  [list 0   2 0   [expr $yh - 2]]
set south_line [list 2   0   [expr $xh - 2] 0  ]
set north_line [list 2   $yh [expr $xh - 2] $yh]

set v_layers { M13 M11 M9  M7 M5 }
set h_layers { M14 M12 M10 M8 M6 }

if { [sizeof $east] > 0 }  { quick_place_pins $cell $east $east_line h $h_layers }
if { [sizeof $west] > 0 }  { quick_place_pins $cell $west $west_line h $h_layers }
if { [sizeof $south] > 0 } { quick_place_pins $cell $south $south_line v $v_layers }
if { [sizeof $north] > 0 } { quick_place_pins $cell $north $north_line v $v_layers }

### SOUT2SOUTHEAST
align_pins_b2b i_grid_quad_south_filler_i_grid_quad_south_filler_east i_grid_quad_south_filler_i_grid_quad_south_filler_c7 h true
align_pins_b2b i_grid_quad_south_filler_i_grid_quad_south_filler_c6 i_grid_quad_south_filler_i_grid_quad_south_filler_c7 h true

### SOUTHBOTTOM2SOUTHTOP
mirror_bus2bus i_grid_quad_south_filler_i_grid_quad_south_filler_c7/nbus_to_north_nbus i_grid_quad_south_filler_i_grid_quad_south_filler_c7/south_nbus_to_nbus v down
mirror_bus2bus i_grid_quad_south_filler_i_grid_quad_south_filler_c7/north_nbus_to_nbus i_grid_quad_south_filler_i_grid_quad_south_filler_c7/nbus_to_south_nbus v down

mirror_bus2bus i_grid_quad_south_filler_i_grid_quad_south_filler_c7/north_to_cbus i_grid_quad_south_filler_i_grid_quad_south_filler_c7/cbus_to_south v down
mirror_bus2bus i_grid_quad_south_filler_i_grid_quad_south_filler_c7/cbus_to_north i_grid_quad_south_filler_i_grid_quad_south_filler_c7/south_to_cbus v down

### SOUTHCOL0MIRROR
align_pins_b2b i_grid_quad_south_filler_i_grid_quad_south_filler_c1 i_grid_quad_south_filler_i_grid_quad_south_filler_c0 h true

mirror_bus2bus i_grid_quad_south_filler_i_grid_quad_south_filler_c0/nbus_to_north_nbus i_grid_quad_south_filler_i_grid_quad_south_filler_c0/south_nbus_to_nbus v down
mirror_bus2bus i_grid_quad_south_filler_i_grid_quad_south_filler_c0/north_nbus_to_nbus i_grid_quad_south_filler_i_grid_quad_south_filler_c0/nbus_to_south_nbus v down

mirror_bus2bus i_grid_quad_south_filler_i_grid_quad_south_filler_c0/north_to_cbus i_grid_quad_south_filler_i_grid_quad_south_filler_c0/cbus_to_south v down
mirror_bus2bus i_grid_quad_south_filler_i_grid_quad_south_filler_c0/cbus_to_north i_grid_quad_south_filler_i_grid_quad_south_filler_c0/south_to_cbus v down



### EAST2SOUTH
quick_spread_pins i_grid_quad_south_filler_i_grid_quad_south_filler_east i_grid_quad_east_filler_i_grid_quad_east_filler_r7  v 
align_pins_b2b i_grid_quad_south_filler_i_grid_quad_south_filler_east i_grid_quad_east_filler_i_grid_quad_east_filler_r7 v true

### EASTTOP2EASTBOTTOM (ROW 7->6)
quick_spread_pins i_grid_quad_east_filler_i_grid_quad_east_filler_r6 i_grid_quad_east_filler_i_grid_quad_east_filler_r7  v 
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/nbus_to_south_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_nbus_to_nbus v up
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/south_nbus_to_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/nbus_to_north_nbus v up

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/south_dlink_to_dlink i_grid_quad_east_filler_i_grid_quad_east_filler_r7/dlink_to_north_dlink v up
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/dlink_to_south_dlink i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_dlink_to_dlink v up

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/cbus_to_south i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_to_cbus v up
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/south_to_cbus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/cbus_to_north v up


### Some manual placements
set leftover_pins [get_pins "
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_dft_clk_gate_en
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_dft_rst_n_override
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_grid_rst_n
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_logical_row[0]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_logical_row[1]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_logical_row[2]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_logical_row[3]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_logical_row[4]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_nsuid[0]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_nsuid[1]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_nsuid[2]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_nsuid[3]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_quad[0]
i_grid_quad_east_filler_i_grid_quad_east_filler_r7/north_strap_quad[1]
"]
quick_place_pins i_grid_quad_east_filler_i_grid_quad_east_filler_r7 $leftover_pins [list 5 1108.8 55 1108.8] v {M13 M11 M9 M7}

### EASTLEFT2EASTRIGHT (ROW 7)
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/nbus_to_west_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/east_nbus_to_nbus h right
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/west_nbus_to_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/nbus_to_east_nbus h right

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/cbus_to_west i_grid_quad_east_filler_i_grid_quad_east_filler_r7/east_to_cbus h right
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/west_to_cbus i_grid_quad_east_filler_i_grid_quad_east_filler_r7/cbus_to_east h right

# EAST ROW 6
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r7 i_grid_quad_east_filler_i_grid_quad_east_filler_r6 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r5 i_grid_quad_east_filler_i_grid_quad_east_filler_r6 v true

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r6/nbus_to_west_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r6/east_nbus_to_nbus h right
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r6/west_nbus_to_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r6/nbus_to_east_nbus h right

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r6/cbus_to_west i_grid_quad_east_filler_i_grid_quad_east_filler_r6/east_to_cbus h right
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r6/west_to_cbus i_grid_quad_east_filler_i_grid_quad_east_filler_r6/cbus_to_east h right

# EAST ROW 4
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r3 i_grid_quad_east_filler_i_grid_quad_east_filler_r4 v true
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r5 i_grid_quad_east_filler_i_grid_quad_east_filler_r4 v true

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r4/nbus_to_west_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r4/east_nbus_to_nbus h right
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r4/west_nbus_to_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r4/nbus_to_east_nbus h right

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r4/cbus_to_west i_grid_quad_east_filler_i_grid_quad_east_filler_r4/east_to_cbus h right
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r4/west_to_cbus i_grid_quad_east_filler_i_grid_quad_east_filler_r4/cbus_to_east h right


# EAST ROW 0
align_pins_b2b i_grid_quad_east_filler_i_grid_quad_east_filler_r1 i_grid_quad_east_filler_i_grid_quad_east_filler_r0 v true

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/nbus_to_west_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/east_nbus_to_nbus h right
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/west_nbus_to_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/nbus_to_east_nbus h right

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/cbus_to_west i_grid_quad_east_filler_i_grid_quad_east_filler_r0/east_to_cbus h right
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/west_to_cbus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/cbus_to_east h right

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/nbus_to_south_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/north_nbus_to_nbus v up
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/south_nbus_to_nbus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/nbus_to_north_nbus v up

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/south_dlink_to_dlink i_grid_quad_east_filler_i_grid_quad_east_filler_r0/dlink_to_north_dlink v up
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/dlink_to_south_dlink i_grid_quad_east_filler_i_grid_quad_east_filler_r0/north_dlink_to_dlink v up

mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/cbus_to_south i_grid_quad_east_filler_i_grid_quad_east_filler_r0/north_to_cbus v up
mirror_bus2bus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/south_to_cbus i_grid_quad_east_filler_i_grid_quad_east_filler_r0/cbus_to_north v up

set leftover_pins [get_pins -hier "
i_grid_quad_east_filler_i_grid_quad_east_filler_r0/lnb_to_north_lnb_data_*
i_grid_quad_east_filler_i_grid_quad_east_filler_r0/north_lnb_to_lnb_data_*
i_grid_quad_east_filler_i_grid_quad_east_filler_r0/lnb_to_north_lnb_ready_*
i_grid_quad_east_filler_i_grid_quad_east_filler_r0/lnb_to_north_lnb_valid_*
i_grid_quad_east_filler_i_grid_quad_east_filler_r0/north_lnb_to_lnb_ready_*
i_grid_quad_east_filler_i_grid_quad_east_filler_r0/north_lnb_to_lnb_valid_*
"]

quick_place_pins i_grid_quad_east_filler_i_grid_quad_east_filler_r0 $leftover_pins [list 15 866.88 100 866.88] v {M13 M11 M9 M7 M5}

### DUMP BIG BLOCK LOCATION
set dir "out/tcl_files_031122"
exec mkdir -pv $dir

create_td_io_placement_file  i_grid_tcu_col_i_grid_tcu_cluster_r0_c0_i_tcu_top       $dir/tcu_top_td_io_placement.tcl 
create_td_io_placement_file  i_grid_clusters_wrap_i_cluster_r1_c1_i_cbu_i_cbue_top   $dir/cbue_top_td_io_placement.tcl
create_td_io_placement_file  i_grid_clusters_wrap_i_cluster_r1_c1_i_cbu_i_cbui_top   $dir/cbui_top_td_io_placement.tcl       
create_td_io_placement_file  i_grid_clusters_wrap_i_cluster_r1_c1_i_nfi_mcu_top      $dir/nfi_mcu_top_td_io_placement.tcl    

create_td_io_placement_file  i_grid_quad_west_filler_i_grid_quad_west_filler_r3      $dir/grid_quad_west_filler_row_top_td_io_placement.tcl 
create_td_io_placement_file  i_grid_quad_south_filler_i_grid_quad_south_filler_c0    $dir/grid_quad_south_filler_col_0_top_td_io_placement.tcl 
create_td_io_placement_file  i_grid_quad_south_filler_i_grid_quad_south_filler_c7    $dir/grid_quad_south_filler_col_top_td_io_placement.tcl 
create_td_io_placement_file  i_grid_quad_south_filler_i_grid_quad_south_filler_east  $dir/grid_quad_south_filler_east_top_td_io_placement.tcl 

create_td_io_placement_file  i_grid_quad_east_filler_i_grid_quad_east_filler_r7      $dir/grid_quad_east_filler_row_7_top_td_io_placement.tcl
create_td_io_placement_file  i_grid_quad_east_filler_i_grid_quad_east_filler_r4      $dir/grid_quad_east_filler_row_notch_top_td_io_placement.tcl
create_td_io_placement_file  i_grid_quad_east_filler_i_grid_quad_east_filler_r1      $dir/grid_quad_east_filler_row_top_td_io_placement.tcl
create_td_io_placement_file  i_grid_quad_east_filler_i_grid_quad_east_filler_r0      $dir/grid_quad_east_filler_row_0_top_td_io_placement.tcl


create_td_io_placement_file  i_grid_quad_north_filler_i_grid_quad_north_filler_c3    $dir/grid_quad_north_filler_col_top_td_io_placement.tcl   
create_td_io_placement_file  i_grid_quad_west_filler_i_grid_quad_west_filler_r7      $dir/grid_quad_west_filler_ecore_row_top_td_io_placement.tcl
















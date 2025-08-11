array unset cells_arr
#set cells_arr(g11) [get_cells *group_1_1*]
#set cells_arr(g12) [get_cells *group_1_2*]
#set cells_arr(g21) [get_cells *group_2_1*]
#set cells_arr(g22) [get_cells *group_2_2*]
set cells_arr(grid_quadrant_grid_cluster_extest_edt_compression_group_1) ""
set cells_arr(grid_quadrant_grid_cluster_extest_edt_compression_group_2) ""
set cells_arr(grid_quadrant_grid_cluster_extest_edt_compression_group_3) ""
set cells_arr(grid_quadrant_grid_cluster_extest_edt_compression_group_4) ""
set cells_arr(grid_quadrant_extest_edt_compression_group_5)              ""
set cells_arr(grid_quadrant_extest_edt_compression_group_4)              ""

set header {group num_of_cells num_of_blocks num_of_blocks_test_pins blocks}
set table {}
foreach index [lsort [array names cells_arr]] {
    
    if { [set cells $cells_arr($index)] == "" } { set cells [get_cells *$index*] }
    set num_of_cells  [sizeof $cells]
    set blocks [get_cells -of [get_pins -of [get_nets -of [get_cells -of  [get_pins -of [get_nets -of [get_pins -of $cells]] -filter full_name=~*extso*]]]  -filter full_name=~*TEST*     ]]
    set num_of_blocks [sizeof $blocks]
    set num_of_blocks_test_pins [sizeof [get_pins -of $blocks -filter full_name=~*TEST*]]
    
    set line [list $index $num_of_cells $num_of_blocks $num_of_blocks_test_pins [lsort -u [get_db $blocks .base_cell.base_name]]]
    lappend table $line
    
}

rls_table -table $table -header $header -spac -breaks

create_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_1 -rects {4829.496 6935.04 4910.892 9172.8} -type guide
update_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_1 -add  -obj [get_db [get_cells *grid_quadrant_grid_cluster_extest_edt_compression_group_1*] .name]

create_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_2 -rects {4829.496 4677.12 4910.892 6914.88} -type guide
update_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_2 -add  -obj [get_db [get_cells *grid_quadrant_grid_cluster_extest_edt_compression_group_2*] .name]

create_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_3 -rects {4829.496 2419.20 4910.892 4656.96} -type guide
update_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_3 -add  -obj [get_db [get_cells *grid_quadrant_grid_cluster_extest_edt_compression_group_3*] .name]

create_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_4 -rects {4829.496 161.28  4910.892 2399.04} -type guide
update_group -name grid_quadrant_grid_cluster_extest_edt_compression_group_4 -add  -obj [get_db [get_cells *grid_quadrant_grid_cluster_extest_edt_compression_group_4*] .name]




proc calc_line_nets { {line ""} } {
    
    set_layer_preference node_layer -is_visible 1
    set_layer_preference pgGround -is_visible 1
    set_layer_preference pgGround -is_visible 0
    
    if { $line == "" } { 
        set bbox [gui_get_box]
        lassign $bbox xl yl xh yh
        set dx [expr abs($xh - $xl)]
        set dy [expr abs($yh - $yl)]
        if { $dx > $dy } {
            set line [list $xl [expr ($yh + $yl)/2.0] $xh [expr ($yh + $yl)/2.0]]
        } else {
            set line [list [expr ($xh + $xl)/2.0] $yl [expr ($xh + $xl)/2.0] $yh]
        }
    }
#    puts "-D- gui_select -line $line"
    gui_select -line $line
    set selected [get_db selected -if .obj_type==wire||.obj_type==via]
    gui_deselect -all
    return [llength [get_db -uniq $selected  .net]]
    
}

proc junction_nets_count {} {
    
    set blocks_lists [list \
    "i_grid_quad_south_filler_i_grid_quad_south_filler_c2 i_grid_clusters_wrap_i_cluster_r7_c2 i_grid_clusters_wrap_i_cluster_r7_c1 i_grid_quad_south_filler_i_grid_quad_south_filler_c1" \
    "i_grid_quad_south_filler_i_grid_quad_south_filler_c4 i_grid_clusters_wrap_i_cluster_r7_c4 i_grid_clusters_wrap_i_cluster_r7_c3 i_grid_quad_south_filler_i_grid_quad_south_filler_c3" \
    "i_grid_quad_south_filler_i_grid_quad_south_filler_c6 i_grid_clusters_wrap_i_cluster_r7_c6 i_grid_clusters_wrap_i_cluster_r7_c5 i_grid_quad_south_filler_i_grid_quad_south_filler_c5" \
    "i_grid_clusters_wrap_i_cluster_r6_c1 i_grid_clusters_wrap_i_cluster_r6_c2 i_grid_clusters_wrap_i_cluster_r7_c2 i_grid_clusters_wrap_i_cluster_r7_c1" \
    "i_grid_clusters_wrap_i_cluster_r5_c1 i_grid_clusters_wrap_i_cluster_r5_c2 i_grid_clusters_wrap_i_cluster_r6_c2 i_grid_clusters_wrap_i_cluster_r6_c1" \
    "i_grid_clusters_wrap_i_cluster_r4_c1 i_grid_clusters_wrap_i_cluster_r4_c2 i_grid_clusters_wrap_i_cluster_r5_c2 i_grid_clusters_wrap_i_cluster_r5_c1" \
    "i_grid_clusters_wrap_i_cluster_r3_c1 i_grid_clusters_wrap_i_cluster_r3_c2 i_grid_clusters_wrap_i_cluster_r4_c2 i_grid_clusters_wrap_i_cluster_r4_c1" \
    "i_grid_clusters_wrap_i_cluster_r2_c1 i_grid_clusters_wrap_i_cluster_r2_c2 i_grid_clusters_wrap_i_cluster_r3_c2 i_grid_clusters_wrap_i_cluster_r3_c1" \
    "i_grid_clusters_wrap_i_cluster_r1_c1 i_grid_clusters_wrap_i_cluster_r1_c2 i_grid_clusters_wrap_i_cluster_r2_c2 i_grid_clusters_wrap_i_cluster_r2_c1" \
    "i_grid_clusters_wrap_i_cluster_r0_c1 i_grid_clusters_wrap_i_cluster_r0_c2 i_grid_clusters_wrap_i_cluster_r1_c2 i_grid_clusters_wrap_i_cluster_r1_c1" \
    "i_grid_clusters_wrap_i_cluster_r6_c3 i_grid_clusters_wrap_i_cluster_r6_c4 i_grid_clusters_wrap_i_cluster_r7_c4 i_grid_clusters_wrap_i_cluster_r7_c3" \
    "i_grid_clusters_wrap_i_cluster_r5_c3 i_grid_clusters_wrap_i_cluster_r5_c4 i_grid_clusters_wrap_i_cluster_r6_c4 i_grid_clusters_wrap_i_cluster_r6_c3" \
    "i_grid_clusters_wrap_i_cluster_r4_c3 i_grid_clusters_wrap_i_cluster_r4_c4 i_grid_clusters_wrap_i_cluster_r5_c4 i_grid_clusters_wrap_i_cluster_r5_c3" \
    "i_grid_clusters_wrap_i_cluster_r3_c3 i_grid_clusters_wrap_i_cluster_r3_c4 i_grid_clusters_wrap_i_cluster_r4_c4 i_grid_clusters_wrap_i_cluster_r4_c3" \
    "i_grid_clusters_wrap_i_cluster_r2_c3 i_grid_clusters_wrap_i_cluster_r2_c4 i_grid_clusters_wrap_i_cluster_r3_c4 i_grid_clusters_wrap_i_cluster_r3_c3" \
    "i_grid_clusters_wrap_i_cluster_r1_c3 i_grid_clusters_wrap_i_cluster_r1_c4 i_grid_clusters_wrap_i_cluster_r2_c4 i_grid_clusters_wrap_i_cluster_r2_c3" \
    "i_grid_clusters_wrap_i_cluster_r0_c3 i_grid_clusters_wrap_i_cluster_r0_c4 i_grid_clusters_wrap_i_cluster_r1_c4 i_grid_clusters_wrap_i_cluster_r1_c3" \
    "i_grid_clusters_wrap_i_cluster_r6_c5 i_grid_clusters_wrap_i_cluster_r6_c6 i_grid_clusters_wrap_i_cluster_r7_c6 i_grid_clusters_wrap_i_cluster_r7_c5" \
    "i_grid_clusters_wrap_i_cluster_r5_c5 i_grid_clusters_wrap_i_cluster_r5_c6 i_grid_clusters_wrap_i_cluster_r6_c6 i_grid_clusters_wrap_i_cluster_r6_c5" \
    "i_grid_clusters_wrap_i_cluster_r4_c5 i_grid_clusters_wrap_i_cluster_r4_c6 i_grid_clusters_wrap_i_cluster_r5_c6 i_grid_clusters_wrap_i_cluster_r5_c5" \
    "i_grid_clusters_wrap_i_cluster_r3_c5 i_grid_clusters_wrap_i_cluster_r3_c6 i_grid_clusters_wrap_i_cluster_r4_c6 i_grid_clusters_wrap_i_cluster_r4_c5" \
    "i_grid_clusters_wrap_i_cluster_r2_c5 i_grid_clusters_wrap_i_cluster_r2_c6 i_grid_clusters_wrap_i_cluster_r3_c6 i_grid_clusters_wrap_i_cluster_r3_c5" \
    "i_grid_clusters_wrap_i_cluster_r1_c5 i_grid_clusters_wrap_i_cluster_r1_c6 i_grid_clusters_wrap_i_cluster_r2_c6 i_grid_clusters_wrap_i_cluster_r2_c5" \
    "i_grid_clusters_wrap_i_cluster_r0_c5 i_grid_clusters_wrap_i_cluster_r0_c6 i_grid_clusters_wrap_i_cluster_r1_c6 i_grid_clusters_wrap_i_cluster_r1_c5" ]
    

    
    foreach blocks_list $blocks_lists {
        set blocks [get_cells $blocks_list]
        set xls [get_db $blocks .bbox.ll.x]
        set yls [get_db $blocks .bbox.ll.y]
        set xhs [get_db $blocks .bbox.ur.x]
        set yhs [get_db $blocks .bbox.ur.y]

        set junction [list [lindex [lsort -real -incr $xhs] 0]   \
                           [lindex [lsort -real -incr $yhs] 0]   \
                           [lindex [lsort -real -incr $xls] end] \
                           [lindex [lsort -real -incr $yls] end]]

    #    set junction {2441.88 2399.04 2414.748 2419.20}
        lassign $junction xl yl xh yh
        set east  [list $xh $yl $xh $yh]
        set west  [list $xl $yl $xl $yh]
        set south [list $xl $yl $xh $yl]
        set north [list $xl $yh $xh $yh]

        set east_count  [calc_line_nets $east]
        set west_count  [calc_line_nets $west]
        set south_count [calc_line_nets $south]
        set north_count [calc_line_nets $north]
        
        puts "-I- Junction \{$junction\}: East - $east_count ; West - $west_count ; South - $south_count ; North - $north_count"
    }
    
}

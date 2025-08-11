
proc create_tap_groups { tap_groups_list } {
    # Example: for {set r 0} { $r < 8 } { incr r 2} { for {set c 0} { $c < 8 } { incr c 1 } { puts -nonew "t$r$c \{i_cluster_r${r}_c${c}_* i_cluster_r[expr $r +1]_c$c_*\} "  } ; puts "" }
    # set tap_groups_list [list t00 {i_cluster_r0_c0_* i_cluster_r1_c0_*} t01 {i_cluster_r0_c1_* i_cluster_r1_c1_*} t02 {i_cluster_r0_c2_* i_cluster_r1_c2_*} t03 {i_cluster_r0_c3_* i_cluster_r1_c3_*} t04 {i_cluster_r0_c4_* i_cluster_r1_c4_*} t05 {i_cluster_r0_c5_* i_cluster_r1_c5_*} t06 {i_cluster_r0_c6_* i_cluster_r1_c6_*} t07 {i_cluster_r0_c7_* i_cluster_r1_c7_*} \
    #                           t20 {i_cluster_r2_c0_* i_cluster_r3_c0_*} t21 {i_cluster_r2_c1_* i_cluster_r3_c1_*} t22 {i_cluster_r2_c2_* i_cluster_r3_c2_*} t23 {i_cluster_r2_c3_* i_cluster_r3_c3_*} t24 {i_cluster_r2_c4_* i_cluster_r3_c4_*} t25 {i_cluster_r2_c5_* i_cluster_r3_c5_*} t26 {i_cluster_r2_c6_* i_cluster_r3_c6_*} t27 {i_cluster_r2_c7_* i_cluster_r3_c7_*} \
    #                           t40 {i_cluster_r4_c0_* i_cluster_r5_c0_*} t41 {i_cluster_r4_c1_* i_cluster_r5_c1_*} t42 {i_cluster_r4_c2_* i_cluster_r5_c2_*} t43 {i_cluster_r4_c3_* i_cluster_r5_c3_*} t44 {i_cluster_r4_c4_* i_cluster_r5_c4_*} t45 {i_cluster_r4_c5_* i_cluster_r5_c5_*} t46 {i_cluster_r4_c6_* i_cluster_r5_c6_*} t47 {i_cluster_r4_c7_* i_cluster_r5_c7_*} \
    #                           t60 {i_cluster_r6_c0_* i_cluster_r7_c0_*} t61 {i_cluster_r6_c1_* i_cluster_r7_c1_*} t62 {i_cluster_r6_c2_* i_cluster_r7_c2_*} t63 {i_cluster_r6_c3_* i_cluster_r7_c3_*} t64 {i_cluster_r6_c4_* i_cluster_r7_c4_*} t65 {i_cluster_r6_c5_* i_cluster_r7_c5_*} t66 {i_cluster_r6_c6_* i_cluster_r7_c6_*} t67 {i_cluster_r6_c7_* i_cluster_r7_c7_*} ]
    # Returns a matching list of clock pins grouped as described above
    
    array set   tap_groups_arr $tap_groups_list
    array unset tap_pins_arr   
    foreach tap [array names tap_groups_arr] {
        set clock_pins         [get_pins -hier $tap_groups_arr($tap)]
        set tap_pins_arr($tap) [get_db $clock_pins]
    }
    
    return [array get tap_pins_arr]    
}

proc calc_taps_location { tap_pins_list } {
    
    array set tap_pins_arr $tap_pins_list

    array unset tap_loc_arr
    foreach tap [array names tap_pins_arr] {
        set tap_loc_arr($tap) [ory_get_com $tap_pins_arr($tap)]
    }
    
    return [array get tap_loc_arr]
}

proc insert_taps { tap_pins_list prefix {legal_dist 50} {split_driver false} {com_offset {0 0}} {base_cell "F6UNAA_LPDSINVGT5X96"} } {

    array set tap_pins_arr $tap_pins_list

    set_db eco_honor_dont_use false
    set_db eco_update_timing false
    set_db eco_refine_place false
    set_db eco_check_logical_equivalence false
    
    lassign $com_offset xoff yoff
    
    set i 0
    foreach tap [array names tap_pins_arr] {

        set tap_loc [ory_get_com $tap_pins_arr($tap)]        
        set tap_loc [list [expr [lindex $tap_loc 0] + $xoff] [expr [lindex $tap_loc 1] + $yoff]]
        lassign $tap_loc x y
        
        if { $split_driver } {
            set receiver_count [llength $tap_pins_arr($tap)]
            set lower_half     [lrange $tap_pins_arr($tap) 0 [expr $receiver_count/2 - 1]]
            set higher_half    [lrange $tap_pins_arr($tap) [expr $receiver_count/2]   end]

            puts "-I- eco_add_repeater -cells $base_cell -name ${prefix}_a_$tap -new_net_name ${prefix}_a_${tap}_net -pins \{[get_db $lower_half .name] \} -location [list [expr $x - 13.5] [expr $y - 5.5]] "           
            puts "-I- eco_add_repeater -cells $base_cell -name ${prefix}_b_$tap -new_net_name ${prefix}_b_${tap}_net  -pins \{[get_db $higher_half .name]\} -location [list [expr $x + 13.5] [expr $y + 5.5]] "            
            
            eco_add_repeater -cells $base_cell -name ${prefix}_a_$tap -new_net_name ${prefix}_a_${tap}_net -pins [get_db $lower_half .name]  -location [list [expr $x - 13.5] [expr $y - 5.5]]
            eco_add_repeater -cells $base_cell -name ${prefix}_b_$tap -new_net_name ${prefix}_b_${tap}_net -pins [get_db $higher_half .name] -location [list [expr $x + 13.5] [expr $y + 5.5]]
        } else {        
            puts "-I- eco_add_repeater -cells $base_cell -name ${prefix}_$tap  -pins \{[get_db $tap_pins_arr($tap) .name]\} -location $tap_loc "
            eco_add_repeater -cells $base_cell -name ${prefix}_$tap -new_net_name ${prefix}_${tap}_net  -pins [get_db $tap_pins_arr($tap) .name] -location $tap_loc        
        }
        incr i
    }

    set_db eco_check_logical_equivalence true
    set_db eco_honor_dont_use true
    set_db eco_update_timing  true
    set_db eco_refine_place   true  

    puts "-I- Running place_detail with max distance of $legal_dist"    
    set cells [get_cell -hier "${prefix}*"]
    be_legalize_super_inv $cells false $legal_dist
}



proc break_up_long_clock_nets { clock_nets max_length {prefix ""} {debug false} {base_cell "F6UNAA_LPDSINVGT5X96"}} {
    
    if { $prefix == "" } { set prefix "levelx_tap_break_long_nets" }
    set margin 0.1

    set_db eco_honor_dont_use false
    set_db eco_update_timing false
    set_db eco_refine_place false
    set_db eco_check_logical_equivalence false
    
    set nets [get_db $clock_nets]
    set bad_nets {}
    array unset bad_nets_arr
    
    puts "-I- Buffering nets longer then $max_length um"
    foreach net $nets {
        
        if { [llength [set driver    [get_db $net .driver_pins]]] == 0 } {set driver    [get_db $net .driver_ports]}
        if { [llength [set receivers [get_db $net .load_pins  ]]] == 0 } {set receivers [get_db $net .load_ports  ]}
        
        if { [llength $driver]    == 0 } { puts "-W- No driver found for $net" ; continue }
        if { [llength $receivers] == 0 } { puts "-W- No receivers found for $net" ; continue }
        
        
        set driver_loc    [lindex [get_db $driver .location] 0]
        set receivers_loc  [ory_get_com $receivers]
        
        lassign $driver_loc drx dry
        lassign $receivers_loc rcx rcy
        
        set xdist     [expr abs($drx - $rcx)]
        set ydist     [expr abs($dry - $rcy)]
        set dist      [expr $xdist + $ydist]

        if { $xdist > $ydist } { set dir "h" } {set dir "v" }
        if { ![string match "v*" $dir] } { if { $dir == "h" && $drx < $rcx } { append dir "r" } { append dir "l" } }
        if { ![string match "h*" $dir] } { if { $dir == "v" && $dry < $rcy } { append dir "u" } { append dir "d" } }
        
                
        if {$dist > [expr (1 + $margin)*$max_length]} { 
            lappend bad_nets $net
            set bad_nets_arr($net) $dir
            set number_of_buffers [expr int(ceil($dist/$max_length))]
            set delta [expr ($dist*0.98)/$number_of_buffers]
            set net_name [get_db $net .base_name]    
            
            puts "-I- Bad net        : $net"
            puts "-I- Distance       : $dist"
            puts "-I- Driver location: $driver_loc"
            puts "-I- Receivers COM  : $receivers_loc"
            
            set newy $dry
            set newx $drx                
#            puts $dir
            for { set i $number_of_buffers } { $i > 0 } { incr i -1 } {
                if { $dir == "hr" } { set newx [expr $drx + $i*$delta] }
                if { $dir == "hl" } { set newx [expr $drx - $i*$delta] } 
                if { $dir == "vu" } { set newy [expr $dry + $i*$delta] }                     
                if { $dir == "vd" } { set newy [expr $dry - $i*$delta] }                     
                puts "-I- eco_add_repeater -cells $base_cell -name ${prefix}_${net_name}_$i  -pins [get_db $driver .name]  -location [list $newx $newy]"
                if { !$debug } { eco_add_repeater -cells $base_cell -name ${prefix}_${net_name}_$i  -new_net_name  ${prefix}_${net_name}_${i}_net -pins [get_db $driver .name]  -location [list $newx $newy] }
            }

        }
        
    }
    
    set cells [get_cell -hier "${prefix}*"]
    set nets  [get_nets -of $cells]
    
    foreach net [get_db $nets] {
        set net_dist [expr  [lindex [lsort -real -incr [get_db [all_connected -leaf $net] .location.y]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $net] .location.y]] 0] \
                   + [lindex [lsort -real -incr [get_db [all_connected -leaf $net] .location.x]] end] - [lindex [lsort -real -incr [get_db [all_connected -leaf $net] .location.x]] 0]]
        if { $net_dist < 200 } {
            
            set inv2del [common_collection [get_cells -of $net] [get_cells  -hier "${prefix}*"]]
            puts "-I- Will delete [get_db $inv2del]"
            remove_inverter $inv2del
            
        }
    }
    

    set_db eco_check_logical_equivalence true
    set_db eco_honor_dont_use true
    set_db eco_update_timing  true
    set_db eco_refine_place   true  

    if { $debug } { return }
    
    set legal_dist 100
    be_legalize_super_inv $cells false 100

}


proc remove_inverters { cells {force false} } {

    enter_eco_mode
    
    if { $force } { set_db $cells .place_status placed ; set_db $cells .dont_touch false ; set_db [get_nets -of $cells] .dont_touch false }
    
    eco_update_cell -insts [get_db  $cells .name] -cells F6UNAA_BUFAX12
    set cells [get_db insts -if .base_cell==base_cell:F6UNAA_BUFAX12]
    eco_delete_repeater -insts [get_db $cells .name]

    enter_eco_mode true

}

proc block_all_vertical { cells {xmargin 5} } {
    
    set core  [lindex [get_db designs .bbox] 0]
    set boxes [get_db $cells .bbox]
    
    lassign $core xl yl xh yh
    
    # stretch boxes
    set new_boxes {}
    foreach box $boxes {
        lassign $box bxl byl bxh byh
        lappend new_boxes [list [expr $bxl - $xmargin] $yl [expr $bxh + $xmargin] $yh]
    }
        
    set blockage_prefix "my_cells_blockage"
    create_place_blockage -rect $new_boxes -name $blockage_prefix
    
}

proc block_all_horizontal { cells {ymargin 2} } {

    set core  [lindex [get_db designs .bbox] 0]
    set boxes [get_db $cells .bbox]
    
    lassign $core xl yl xh yh
    
    # stretch boxes
    set new_boxes {}
    foreach box $boxes {
        lassign $box bxl byl bxh byh
        lappend new_boxes [list $xl [expr $byl - $ymargin] $xh [expr $byh + $ymargin]]
    }
        
    set blockage_prefix "my_cells_blockage"
    create_place_blockage -rect $new_boxes -name $blockage_prefix

}

proc remove_my_blockages {} {
    
    set bs [get_db place_blockages *my_cells_blockage*]
    delete_obj $bs
    
}

proc draw_blocks_latency { {delta 0.015} } {

    set cells [get_db insts i_*_i_* -if !.base_cell==*F6*]
    set pins  [get_pins -of $cells -filter full_name=~*/grid_clk]
    
    set arr_late_list {}
    set arr_mean_list {}
    set arr_early_list {}

    array unset pin_arr
    foreach_in_collection pin $pins {
        set arr_late   [get_db $pin .arrival_max_rise]
        set arr_mean   [get_db $pin .arrival_mean_max_rise]        
        set arr_early  [expr [get_db $pin .arrival_mean_max_rise]*2-[get_db $pin .arrival_max_rise]]
        set pin_arr([get_db $pin .name]) [list $arr_late $arr_mean $arr_early]
        lappend arr_late_list   $arr_late 
        lappend arr_mean_list   $arr_mean 
        lappend arr_early_list  $arr_early
    }
    
    gui_show
    set_layer_preference node_layer -is_visible 0
    gui_delete_objs -all
    gui_clear_highlight -all
        
    set avg_arr [expr [lsum $arr_mean_list]/[llength $arr_mean_list]]
    set min_lim [expr $avg_arr - $delta]
    set max_lim [expr $avg_arr + $delta]
    puts "-I- Average latency is [format "%.3f" $avg_arr]"
    puts "-I- Window is between [format "%.3f" $min_lim] to [format "%.3f" $max_lim]"
    
    foreach pin [array names pin_arr] {
        
        set color "green"
        set layer "BEGREEN"
        if { [lindex $pin_arr($pin) 1] > $max_lim } {
            set color "red"
            set layer "BERED"
        } elseif { [lindex $pin_arr($pin) 1] < $min_lim } {
            set color "orange"
            set layer "BEORANGE"
        }
        
        set inst [get_db [get_pins $pin] .inst]
        puts "[format "%-60s" $inst] [format "%-10s" $color] [format "%-.3f" [lindex $pin_arr($pin) 1]]"
        
        set box [lindex [get_db $inst .bbox] 0]
        
        lassign $box xl yl xh yh
        set width [expr $xh - $xl]       
        set hight [expr $yh - $yl]
                
        gui_highlight $inst -color $color -pattern none
        create_gui_text -layer $layer -pt [list [expr $xl + 20] [expr $yl + 0.25*$hight + 120]] -height 105 -label "Mean:  [lindex $pin_arr($pin) 1]"
        create_gui_text -layer $layer -pt [list [expr $xl + 20] [expr $yl + 0.25*$hight]] -height 95 -label "Late:  [lindex $pin_arr($pin) 0]"
        create_gui_text -layer $layer -pt [list [expr $xl + 20] [expr $yl + 0.25*$hight - 110]] -height 95 -label "Early: [lindex $pin_arr($pin) 2]"
    }
    set_layer_preference BEGREEN   -color lightgreen
    set_layer_preference BERED     -color red
    set_layer_preference BEORANGE  -color orange   

}


proc clock_nets_info { clock_nets {sort_by 0} } {

#    set clock_cells [add_to_collection [get_cells -hier *level*_tap*] [get_cells -hier *tree_source*]]
#    set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
#    set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
#    set clock_nets [concat $clock_nets [get_db $from_east_clock_nets]]
    
    ory_calc_net_length $clock_nets
#    
#    puts "-I- proc5 == net delay"
#    puts "-I- proc6 == worst load input transition"
#    t $clock_nets resistance_max num_loads capacitance_max be_net_length  \
#    {format "%.3f" [expr [avg_list [get_db $o .loads.arrival_max_fall]] - [get_db $o .drivers.arrival_max_fall]]} \
#    {lindex [lsort -real -decr [get_db $o .loads.slew_max_fall]] 0}\
#    be_detailed_net_length
    
    set table {}
    set len_list {}
    set cap_list {}
    set delay_list {}
    set res_list {}
    set arr_list {}
    
    foreach_in_collection net [get_nets $clock_nets] {
        set name  [get_db $net .name]
        set res   [get_db $net .resistance_max]
        set rcvs  [get_db $net .num_loads]
        set cap   [get_db $net .capacitance_max]
        set lng   [get_db $net .be_net_length]
        set dlng  [get_db $net .be_detailed_net_length]
        set delay [expr [avg_list [get_db $net .loads.arrival_max_fall]] - [get_db $net .drivers.arrival_max_fall]]
        set trans [lindex [lsort -real -decr [get_db $net .loads.slew_max_fall]] 0]
        set fo    [all_fanout -from [get_db $net .drivers] -endpoints]
        set arr_mean [avg_list [get_db $fo .arrival_mean_max_rise]]
        
        set new_line [list $name $rcvs $arr_mean $delay $cap $trans $res $lng $dlng]
        lappend table $new_line        
        
        lappend lng_list   $lng
        lappend cap_list   $cap
        lappend delay_list $delay
        lappend res_list   $res
        lappend arr_list   $arr_mean
    }
    
    set header  {Net  Loads AvgID  Delay  capacitance_max MaxLdTrans Res  Length Det_Length}
    set tformat {"%s" "%d"  "%.3f" "%.3f" "%.3f"          "%.3f"          "%.3f" "%.3f" "%s"}
    if { $sort_by == 0 || $sort_by == 7 } {
        set table [lsort -index $sort_by $table]
    } else {
        set table [lsort -incr -real -index $sort_by $table]
    }
    
    rls_table -table $table -header $header -spac -breaks -format $tformat
    
    set cap_res   [ory_get_list_variance $cap_list]
    set delay_res [ory_get_list_variance $delay_list]
    set lng_res   [ory_get_list_variance $lng_list]
    set arr_res   [ory_get_list_variance $arr_list]
    
    puts ""
    puts "-I- Net length AVG     : [format "%10s" [format "%.3f" [lindex $lng_res 1]]]"
    puts "-I- Net length SD      : [format "%10s" [format "%.3f" [lindex $lng_res end]]] : [format "%10s" [format "%.2f" [expr 100.0*[lindex $lng_res end]/[lindex $lng_res 1]]]]% of AVG"
    puts "-I- Net length MAX DIFF: [format "%10s" [format "%.3f" [expr [lindex [lsort -real -decr $lng_list] 0] - [lindex [lsort -real -decr $lng_list] end]]]] : [format "%10s" [format "%.2f" [expr 100.0*([lindex [lsort -real -decr $lng_list] 0] - [lindex [lsort -real -decr $lng_list] end])/[lindex $lng_res 1]]]]% of AVG"
    puts ""    
    puts "-I- Net cap AVG        : [format "%10s" [format "%.3f" [lindex $cap_res 1]]]"
    puts "-I- Net cap SD         : [format "%10s" [format "%.3f" [lindex $cap_res end]]] : [format "%10s" [format "%.2f" [expr 100.0*[lindex $cap_res end]/[lindex $cap_res 1]]]]% of AVG"
    puts "-I- Net cap MAX DIFF   : [format "%10s" [format "%.3f" [expr [lindex [lsort -real -decr $cap_list] 0] - [lindex [lsort -real -decr $cap_list] end]]]] : [format "%10s" [format "%.2f" [expr 100.0*([lindex [lsort -real -decr $cap_list] 0] - [lindex [lsort -real -decr $cap_list] end])/[lindex $cap_res 1]]]]% of AVG"
    puts ""
    puts "-I- Net delay AVG      : [format "%10s" [format "%.3f" [lindex $delay_res 1]]]"
    puts "-I- Net delay SD       : [format "%10s" [format "%.3f" [lindex $delay_res end]]] : [format "%10s" [format "%.2f" [expr 100.0*[lindex $delay_res end]/[lindex $delay_res 1]]]]% of AVG"
    puts "-I- Net delay MAX DIFF : [format "%10s" [format "%.3f" [expr [lindex [lsort -real -decr $delay_list] 0] - [lindex [lsort -real -decr $delay_list] end]]]] : [format "%10s" [format "%.2f" [expr 100.0*([lindex [lsort -real -decr $delay_list] 0] - [lindex [lsort -real -decr $delay_list] end])/[lindex $delay_res 1]]]]% of AVG"
    puts ""
    puts "-I- Net EP ID AVG      : [format "%10s" [format "%.3f" [lindex $arr_res 1]]]"
    puts "-I- Net EP ID SD       : [format "%10s" [format "%.3f" [lindex $arr_res end]]] : [format "%10s" [format "%.2f" [expr 100.0*[lindex $arr_res end]/[lindex $arr_res 1]]]]% of AVG"
    puts "-I- Net EP ID MAX DIFF : [format "%10s" [format "%.3f" [expr [lindex [lsort -real -decr $arr_list] 0] - [lindex [lsort -real -decr $arr_list] end]]]] : [format "%10s" [format "%.2f" [expr 100.0*([lindex [lsort -real -decr $arr_list] 0] - [lindex [lsort -real -decr $arr_list] end])/[lindex $arr_res 1]]]]% of AVG"
}


proc report_blocks_latency { } {

    set cells [get_db insts i_*_i_* -if !.base_cell==*F6*]
    set pins  [get_pins -of $cells -filter full_name=~*/grid_clk]
    
    set arr_late_list {}
    set arr_mean_list {}
    set arr_early_list {}

    set grid_clk_port [get_ports grid_clk]
    set gc_arr    [get_db $grid_clk_port .arrival_min_rise]

    array unset pin_arr
    foreach_in_collection pin $pins {
        set arr_late   [expr [get_db $pin .arrival_max_rise] - $gc_arr]
        set arr_mean   [expr [get_db $pin .arrival_mean_max_rise] - $gc_arr]
        set arr_early  [expr $arr_mean*2-$arr_late]
        set pin_arr([get_db $pin .name]) [list $arr_late $arr_mean $arr_early]
        lappend arr_late_list   $arr_late 
        lappend arr_mean_list   $arr_mean 
        lappend arr_early_list  $arr_early
    }
    
        
    set avg_arr   [expr [lsum $arr_mean_list]/[llength $arr_mean_list]]
    set avg_early [expr [lsum $arr_early_list]/[llength $arr_mean_list]]
    set avg_late  [expr [lsum $arr_late_list]/[llength $arr_mean_list]]
    
    set detailed_table {}
    foreach pin [lsort [array names pin_arr]] {
        set inst [get_db [get_pins $pin] .inst.name]
        set new_line [list $inst [lindex $pin_arr($pin) 2] [lindex $pin_arr($pin) 0] [lindex $pin_arr($pin) 1]] 
        lappend detailed_table $new_line
    }
    
    redirect reports/detailed_blocks_clock_latency.rpt { rls_table -table $detailed_table -spac -breaks -header [list "Cell" "minID" "maxID" "avgID"] }
    
    set block_list {west_filler east_filler south_filler north_filler cbue_top cbui_top tcu_top nfi_mcu_top}
    puts "Per block groupd average:\n-------------------------"
    puts "[format "%-20s" Block_Group] [format "%-5s" early] [format "%-5s" late] [format "%-5s" avg]"
    puts "--------------------------------------"
    puts "[format "%-20s" Total AVG] [format "%.3f" $avg_early] [format "%.3f" $avg_late] [format "%.3f" $avg_arr]"
    puts "[format "%-20s" Total] [format "%.3f" [lindex [lsort -real -inc $arr_early_list] 0]] [format "%.3f" [lindex [lsort -real -inc $arr_late_list] end]] [format "%.3f" $avg_arr]"
    puts "--------------------------------------"
    foreach block $block_list {    
        set min_avg [exec cat reports/detailed_blocks_clock_latency.rpt | grep $block | awk {{ sum += $3 } END { if (NR > 0) print sum / NR }}]
        set max_avg [exec cat reports/detailed_blocks_clock_latency.rpt | grep $block | awk {{ sum += $5 } END { if (NR > 0) print sum / NR }}]
        set avg_avg [exec cat reports/detailed_blocks_clock_latency.rpt | grep $block | awk {{ sum += $7 } END { if (NR > 0) print sum / NR }}]
        puts "[format "%-20s" $block] [format "%.3f" $min_avg] [format "%.3f" $max_avg] [format "%.3f" $avg_avg]"
    }
    
    puts ""
    puts "Per cluster average:\n-------------------"
    puts "[format "%-20s" Block_Group] [format "%-5s" early] [format "%-5s" late] [format "%-5s" avg]"
    puts "--------------------------------------"
    puts "[format "%-20s" Total] [format "%.3f" $avg_early] [format "%.3f" $avg_late] [format "%.3f" $avg_arr]"
    puts "--------------------------------------"
    for {set c 0} {$c < 8} {incr c} {
        for {set r 0} {$r < 8} {incr r} {
            set pattern "r${r}_c${c}"
            set min_avg [exec cat reports/detailed_blocks_clock_latency.rpt | grep $pattern | awk {{ sum += $3 } END { if (NR > 0) print sum / NR }}]
            set max_avg [exec cat reports/detailed_blocks_clock_latency.rpt | grep $pattern | awk {{ sum += $5 } END { if (NR > 0) print sum / NR }}]
            set avg_avg [exec cat reports/detailed_blocks_clock_latency.rpt | grep $pattern | awk {{ sum += $7 } END { if (NR > 0) print sum / NR }}]
            puts "[format "%-20s" $pattern] [format "%.3f" $min_avg] [format "%.3f" $max_avg] [format "%.3f" $avg_avg]"
        }
    }
}


proc delete_nets_shorts { clock_nets {min_layer 2} {max_layer 15}} {
  
  set_db $clock_nets .wires.status routed
  set_db $clock_nets .vias.status routed

  delete_markers
  foreach net $clock_nets {so $net ; check_drc -check_only selected_net }
  set shorts [get_db markers -if .subtype==Metal_Short]
  
  set wires {}
  set vias {}
  
  foreach short $shorts {
      set box [get_db $short .bbox]
      set ri  [get_db $short .layer.route_index]
      set via_layer "VIA[expr $ri-1]"
      if { $ri > $max_layer || $ri < $min_layer } { continue }
      set layer "M[expr $ri-1]"      
      set wires [concat $wires [get_db [get_wires_within $box $layer ]]]
      set vias  [concat $vias  [get_db [get_vias_within $box] -if .via_def.cut_layer.name==$via_layer&&.net.name!=VDD&&.net.name!=VSS]]
#      delete_object $wires
  }
  
  set_db [get_db $clock_nets .wires -if .layer.name==M17||.layer.name==M16] .status fixed
  
}




proc be_route_p2p { nets } {

    if { [get_db route_rules grid_clk_vp_rule_2] == "" } {
    create_route_rule -name grid_clk_vp_rule_2 -width   {M1 0.02  M2 0.02  M3 0.02  M4 0.02  M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 \
                                             -spacing {M1 0.014 M2 0.015 M3 0.022 M4 0.022 M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}
    }
    
    delete_routes -net $nets -layer {M16 VIA16 M17}
    set margin -2.5
    
    set nets [get_nets $nets]
    
    foreach_in_collection net $nets {
        puts -nonewline [format "%-80s" [get_object_name $net]]
        set th  35
    #    set net [get_nets FE_RN_9]
        set drv [get_db $net .drivers]
        set rcv [get_db $net .loads]

        set drv_point  [lindex [get_db $drv .location] 0]
        set rcv_points [get_db $rcv .location]

        lassign $drv_point drvx drvy

        set rcvx {}
        set rcvy {}

        set is_2way  false
        set is_right false
        set is_left  false
        set is_up    false
        set is_down  false
        
        set max_x 0
        set max_y 0
        
        foreach point $rcv_points {
            lassign $point x y

            set dx [expr abs($x - $drvx)]
            set dy [expr abs($y - $drvy)]
            if { $dx < $th && $dy < $th } { continue }
            
            if { $dx > $max_x } { set max_x $dx ; set max_x_p $point }
            if { $dy > $max_y } { set max_y $dy ; set max_y_p $point }
            
            lappend rcvx $x
            lappend rcvy $y
            
            if { $x > [expr $drvx + $th] } { set is_right true }
            if { $x < [expr $drvx - $th] } { set is_left  true }
            if { $y > [expr $drvy + $th] } { set is_up    true }
            if { $y < [expr $drvy - $th] } { set is_down  true }
#            puts "$is_right $is_left $is_up $is_down"

        }
        if { [llength $rcvx]==0 || [llength $rcvy]==0 } { puts " M16 0 ; M17 0" ;  continue }
        if { $is_right && $is_left } { set is_2way "h" }
        if { $is_up    && $is_down } { set is_2way "v" }
        if { $is_right && $is_left && $is_up && $is_down } { set is_2way "hv" }

        set line_list {}
        if { $is_2way == "false" } {
            
            set avg_rcvx [avg_list $rcvx]
            set avg_rcvy [avg_list $rcvy]
            
            if { ([_or_ [list $is_right $is_left $is_up $is_down]] && [minority [list $is_right $is_left $is_up $is_down]]) || [expr $max_x/$max_y] > 0.475 && [expr $max_x/$max_y] < 0.525 } {

                set dx [expr abs($avg_rcvx - $drvx)]
                set dy [expr abs($avg_rcvy - $drvy)]

                if { $dy > $th } { lappend line_list [list $drvx $drvy     $drvx     $avg_rcvy "v"] }
                if { $dx > $th } { lappend line_list [list $drvx $avg_rcvy $avg_rcvx $avg_rcvy "h"] }
            
            } else {
            
                set top_half {}
                set bot_half {}
                set top_ys   {}
                set bot_ys   {}
                foreach point $rcv_points { 
                    lassign $point x y
#                    puts "Point: $point ; $y ; $avg_rcvy"
                    if { $y < $avg_rcvy } {
                        lappend bot_half $x
                        lappend bot_ys   $y
                    } else {
                        lappend top_half $x
                        lappend top_ys   $y
                    }
                }
                
                set vline [list [avg_list $top_half] $drvy [avg_list $top_half] [avg_list $top_ys] "v"]
                set hline [list $drvx $drvy [avg_list $bot_half] $drvy "h"]
                lappend line_list $vline
                lappend line_list $hline
            
            }

        } else {

            if       { $is_2way == "v" } {
                set avg_rcvx [avg_list $rcvx]
                set vline    [list $avg_rcvx [lindex [lsort -real -incr $rcvy] 0] $avg_rcvx [lindex [lsort -real -incr $rcvy] end] "v"]

                lappend line_list $vline

                set dx [expr abs($avg_rcvx - $drvx)]
                if { $dx > $th } { lappend line_list [list $drvx $drvy $avg_rcvx $drvy "h"] }
            } elseif { $is_2way == "h" } {
                set avg_rcvy [avg_list $rcvy]
                set hline    [list [lindex [lsort -real -incr $rcvx] 0] $avg_rcvy [lindex [lsort -real -incr $rcvx] end] $avg_rcvy "h"]

                lappend line_list $hline

                set dy [expr abs($avg_rcvy - $drvy)]
                if { $dy > $th } { lappend line_list [list $drvx $drvy $drvx $avg_rcvy "v"] }
            } else {

                set avg_rcvx [avg_list $rcvx]
                set vline    [list $avg_rcvx [lindex [lsort -real -incr $rcvy] 0] $avg_rcvx [lindex [lsort -real -incr $rcvy] end] "v"]

                lappend line_list $vline
                
                set avg_rcvy [avg_list $rcvy]
                
                set top_half {}
                set bot_half {}
                set top_ys   {}
                set bot_ys   {}
                foreach point $rcv_points { 
                    lassign $point x y
#                    puts "Point: $point ; $y ; $avg_rcvy"
                    if { $y < $avg_rcvy } {
                        lappend bot_half $x
                        lappend bot_ys   $y
                    } else {
                        lappend top_half $x
                        lappend top_ys   $y
                    }
                }
                
                set hline    [list [lindex [lsort -real -incr $top_half] 0] [avg_list $top_ys] [lindex [lsort -real -incr $top_half] end] [avg_list $top_ys] "h"]
                lappend line_list $hline
                set hline    [list [lindex [lsort -real -incr $bot_half] 0] [avg_list $bot_ys] [lindex [lsort -real -incr $bot_half] end] [avg_list $bot_ys] "h"]
                lappend line_list $hline            
            }

        }


        # TODO: Determine if PG on lines
        set safety 5        
        set new_line_list {}
        foreach line $line_list {

          set dir [lindex $line end]
          set newl [lrange $line 0 3]
          lassign $newl x0 y0 x1 y1
        # TODO EDIT get_wires_within and create get_wires_overlap
          if { $dir == "v" } {
          
            set index 0
            set width [get_db [get_db layers  M17] .width]
            set m17_pg_dist 11.5411
            set box   [list [expr min($x0,$x1) - $width/2] [expr min($y0,$y1)] [expr max($x0,$x1) + $width/2] [expr max($y0,$y1)]]

            # TODO - Find closest VDD-VSS pair
            set box [list [expr min($x0,$x1) - $m17_pg_dist] [expr min($y0,$y1)] [expr max($x0,$x1) + $m17_pg_dist] [expr max($y0,$y1)]]
            set wires [get_db [get_wires_within $box M17 true] -if .net.name==VDD||.net.name==VSS]
            set pgxs  [lsort -u [get_db $wires .path.x]]

            if { [llength $pgxs] != 2 && [llength $pgxs] != 3 } { puts "-E- Failed finding PG" ; return }
            if { [llength $pgxs] == 3 } { set pgxs [lrange $pgxs 1 2] }
            
            set pitch [expr abs([lindex $pgxs 0] - [lindex $pgxs 1])]
            set x0    [expr [lsum $pgxs]/2]
            set x1 $x0

            set newl  [list $x0 $y0 $x1 $y1]

            set box   [list [expr min($x0,$x1) - $width/2] [expr min($y0,$y1)] [expr max($x0,$x1) + $width/2] [expr max($y0,$y1)]]

            set wires [get_wires_within $box M17 true]
            set orig_newl $newl            
            while { [llength $wires] > 0 && $index < $safety} {
                set newl  [list [expr $x0 - $pitch] $y0 [expr $x1 - $pitch] $y1]
                lassign $newl x0 y0 x1 y1
                set box   [list [expr min($x0,$x1) - $width/2] [expr min($y0,$y1)] [expr max($x0,$x1) + $width/2] [expr max($y0,$y1)]]
                set wires [get_wires_within $box M17 true]
                incr index
            }
            if { $index == $safety && [llength $wires] > 0 } {
                set index 0
                lassign $orig_newl x0 y0 x1 x2
                while { [llength $wires] > 0 && $index < $safety} {
                    set newl  [list [expr $x0 + $pitch] $y0 [expr $x1 + $pitch] $y1]
                    lassign $newl x0 y0 x1 y1
                    set box   [list [expr min($x0,$x1) - $width/2] [expr min($y0,$y1)] [expr max($x0,$x1) + $width/2] [expr max($y0,$y1)]]
                    set wires [get_wires_within $box M17 true]
                    incr index
                }
            }

            lappend new_line_list [concat $newl $dir]

          } else {

            set index 0
            set m16_pg_dist 4.341
            set width [get_db [get_db layers  M16] .width]
            set box   [list [expr min($x0,$x1)] [expr min($y0,$y1) - $width/2] [expr max($x0,$x1)] [expr max($y0,$y1) + $width/2]]

            set box [list [expr min($x0,$x1)] [expr min($y0,$y1) - $m16_pg_dist] [expr max($x0,$x1)]  [expr max($y0,$y1) + $m16_pg_dist]]
            set wires [get_db [get_wires_within $box M16 true] -if .net.name==VDD||.net.name==VSS]
            set pgys  [lsort -u [get_db $wires .path.y]]
            
            if { [llength $pgys] != 2 && [llength $pgys] != 3 } { puts "-E- Failed finding PG" ; return }
            if { [llength $pgys] == 3 } { set pgys [lrange $pgys 1 2] }
            
            set pitch [expr abs([lindex $pgys 0] - [lindex $pgys 1])]
            set y0    [expr [lsum $pgys]/2]
            set y1 $y0

            set newl  [list $x0 $y0 $x1 $y1]

            set box   [list [expr min($x0,$x1)] [expr min($y0,$y1) - $width/2] [expr max($x0,$x1)] [expr max($y0,$y1) + $width/2]]

            set wires [get_wires_within $box M16 true]
            while { [llength $wires] > 0 && $index < $safety } {
                # TODO find closest vdd-vss
                set newl [list $x0 [expr $y0 - $pitch] $x1 [expr $y1 - $pitch]]
                lassign $newl x0 y0 x1 y1
                set box   [list [expr min($x0,$x1)] [expr min($y0,$y1) - $width/2] [expr max($x0,$x1)] [expr max($y0,$y1) + $width/2]]
                set wires [get_wires_within $box M16 true]
                incr index
            }
            if { $index == $safety && [llength $wires] > 0 } {
                set index 0
                lassign $orig_newl x0 y0 x1 x2
                while { [llength $wires] > 0 && $index < $safety} {
                    set newl [list $x0 [expr $y0 + $pitch] $x1 [expr $y1 + $pitch]]
                    lassign $newl x0 y0 x1 y1
                    set box   [list [expr min($x0,$x1)] [expr min($y0,$y1) - $width/2] [expr max($x0,$x1)] [expr max($y0,$y1) + $width/2]]
                    set wires [get_wires_within $box M16 true]
                    incr index
                }
            }


            lappend new_line_list [concat $newl $dir]

          }

        }
        
        if { [llength $new_line_list] == 0 } { puts " M16 0 ; M17 0" ; continue }

        set settings "set_db edit_wire_type regular
        set_db edit_wire_nets [get_object_name $net]
        set_db edit_wire_create_crossover_vias {0}
        set_db edit_wire_layer_vertical   M17
        set_db edit_wire_layer_horizontal   M16
        set_db edit_wire_rule {grid_clk_vp_rule_2}
        "
        eval $settings
        foreach line $new_line_list {
          lassign $line x0 y0 x1 y1 dir
          
          if { $dir == "v" } { set y0 [expr $y0 + $margin] ; set y1 [expr $y1 - $margin] } else { set x0 [expr $x0 + $margin] ; set x1 [expr $x1 - $margin] }
          
          edit_add_route_point $x0  $y0
          edit_end_route_point $x1  $y1
        }
        
        if { [llength [set m17w [get_db [get_db $net .wires] -if .layer.name==M17]]] > 0 } { set m17l [get_db $m17w .length] } { set m17l 0 }
        if { [llength [set m16w [get_db [get_db $net .wires] -if .layer.name==M16]]] > 0 } { set m16l [get_db $m16w .length] } { set m16l 0 }
        puts " M16 $m16l ; M17 $m17l"

    }
}


proc be_route_p2p_v2 { nets } {

    if { [get_db route_rules grid_clk_vp_rule_2] == "" } {
    create_route_rule -name grid_clk_vp_rule_2 -width   {M1 0.02  M2 0.02  M3 0.02  M4 0.02  M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 \
                                             -spacing {M1 0.014 M2 0.015 M3 0.022 M4 0.022 M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}
    }
    
    delete_routes -net $nets -layer {M16 VIA16 M17}
    set margin -2.5
    
    set nets [get_nets $nets]
    
    foreach_in_collection net $nets {
        puts -nonewline [format "%-80s" [get_object_name $net]]
        set th  35
    #    set net [get_nets FE_RN_9]
        set drv [get_db $net .drivers]
        set rcv [get_db $net .loads]

        set drv_point  [lindex [get_db $drv .location] 0]
        set rcv_points [get_db $rcv .location]

        lassign $drv_point drvx drvy

        set rcvx {}
        set rcvy {}

        set is_2way  false
        set is_right false
        set is_left  false
        set is_up    false
        set is_down  false
        
        set max_x 0
        set max_y 0
        
       
        foreach point $rcv_points {
            lassign $point x y

            set dx [expr abs($x - $drvx)]
            set dy [expr abs($y - $drvy)]
            if { $dx < $th && $dy < $th } { continue }
            
            if { $dx > $max_x } { set max_x $dx }
            if { $dy > $max_y } { set max_y $dy }
            
            lappend rcvx $x
            lappend rcvy $y
            
            if { $x > [expr $drvx + $th] } { set is_right true }
            if { $x < [expr $drvx - $th] } { set is_left  true }
            if { $y > [expr $drvy + $th] } { set is_up    true }
            if { $y < [expr $drvy - $th] } { set is_down  true }
            puts "$is_right $is_left $is_up $is_down"

        }
        if { [llength $rcvx]==0 || [llength $rcvy]==0 } { puts " M16 0 ; M17 0" ;  continue }
        if { $is_right && $is_left } { set is_2way "h" }
        if { $is_up    && $is_down } { set is_2way "v" }
        if { $is_right && $is_left && $is_up && $is_down } { set is_2way "hv" }

        set line_list {}
        if { $is_2way == "false" } {
            
            set avg_rcvx [avg_list $rcvx]
            set avg_rcvy [avg_list $rcvy]

            set dx [expr abs($avg_rcvx - $drvx)]
            set dy [expr abs($avg_rcvy - $drvy)]

            if { $dy > $th } { lappend line_list [list $drvx $drvy     $drvx     $avg_rcvy "v"] }
            if { $dx > $th } { lappend line_list [list $drvx $avg_rcvy $avg_rcvx $avg_rcvy "h"] }

        } else {

            if       { $is_2way == "v" } {
                set avg_rcvx [avg_list $rcvx]
                set vline    [list $avg_rcvx [lindex [lsort -real -incr $rcvy] 0] $avg_rcvx [lindex [lsort -real -incr $rcvy] end] "v"]

                lappend line_list $vline

                set dx [expr abs($avg_rcvx - $drvx)]
                if { $dx > $th } { lappend line_list [list $drvx $drvy $avg_rcvx $drvy "h"] }
            } elseif { $is_2way == "h" } {
                set avg_rcvy [avg_list $rcvy]
                set hline    [list [lindex [lsort -real -incr $rcvx] 0] $avg_rcvy [lindex [lsort -real -incr $rcvx] end] $avg_rcvy "h"]

                lappend line_list $hline

                set dy [expr abs($avg_rcvy - $drvy)]
                if { $dy > $th } { lappend line_list [list $drvx $drvy $drvx $avg_rcvy "v"] }
            } else {

                set avg_rcvx [avg_list $rcvx]
                set vline    [list $avg_rcvx [lindex [lsort -real -incr $rcvy] 0] $avg_rcvx [lindex [lsort -real -incr $rcvy] end] "v"]

                lappend line_list $vline
                
                set avg_rcvy [avg_list $rcvy]
                
                set top_half {}
                set bot_half {}
                set top_ys   {}
                set bot_ys   {}
                foreach point $rcv_points { 
                    lassign $point x y
#                    puts "Point: $point ; $y ; $avg_rcvy"
                    if { $y < $avg_rcvy } {
                        lappend bot_half $x
                        lappend top_ys   $y
                    } else {
                        lappend top_half $x
                        lappend bot_ys   $y
                    }
                }
                
                set hline    [list [lindex [lsort -real -incr $top_half] 0] [avg_list $top_ys] [lindex [lsort -real -incr $top_half] end] [avg_list $top_ys] "h"]
                lappend line_list $hline
                set hline    [list [lindex [lsort -real -incr $bot_half] 0] [avg_list $bot_ys] [lindex [lsort -real -incr $bot_half] end] [avg_list $bot_ys] "h"]
                lappend line_list $hline            
            }

        }


        # TODO: Determine if PG on lines
        set safety 5        
        set new_line_list {}
        foreach line $line_list {

          set dir [lindex $line end]
          set newl [lrange $line 0 3]
          lassign $newl x0 y0 x1 y1
        # TODO EDIT get_wires_within and create get_wires_overlap
          if { $dir == "v" } {
          
            set index 0
            set width [get_db [get_db layers  M17] .width]
            set m17_pg_dist 11.5411
            set box   [list [expr min($x0,$x1) - $width/2] [expr min($y0,$y1)] [expr max($x0,$x1) + $width/2] [expr max($y0,$y1)]]

            # TODO - Find closest VDD-VSS pair
            set box [list [expr min($x0,$x1) - $m17_pg_dist] [expr min($y0,$y1)] [expr max($x0,$x1) + $m17_pg_dist] [expr max($y0,$y1)]]
            set wires [get_db [get_wires_within $box M17 true] -if .net.name==VDD||.net.name==VSS]
            set pgxs  [lsort -u [get_db $wires .path.x]]

            if { [llength $pgxs] != 2 && [llength $pgxs] != 3 } { puts "-E- Failed finding PG" ; return }
            if { [llength $pgxs] == 3 } { set pgxs [lrange $pgxs 1 2] }
            
            set pitch [expr abs([lindex $pgxs 0] - [lindex $pgxs 1])]
            set x0    [expr [lsum $pgxs]/2]
            set x1 $x0

            set newl  [list $x0 $y0 $x1 $y1]

            set box   [list [expr min($x0,$x1) - $width/2] [expr min($y0,$y1)] [expr max($x0,$x1) + $width/2] [expr max($y0,$y1)]]

            set wires [get_wires_within $box M17 true]
            set orig_newl $newl            
            while { [llength $wires] > 0 && $index < $safety} {
                set newl  [list [expr $x0 - $pitch] $y0 [expr $x1 - $pitch] $y1]
                lassign $newl x0 y0 x1 y1
                set box   [list [expr min($x0,$x1) - $width/2] [expr min($y0,$y1)] [expr max($x0,$x1) + $width/2] [expr max($y0,$y1)]]
                set wires [get_wires_within $box M17 true]
                incr index
            }
            if { $index == $safety && [llength $wires] > 0 } {
                set index 0
                lassign $orig_newl x0 y0 x1 x2
                while { [llength $wires] > 0 && $index < $safety} {
                    set newl  [list [expr $x0 + $pitch] $y0 [expr $x1 + $pitch] $y1]
                    lassign $newl x0 y0 x1 y1
                    set box   [list [expr min($x0,$x1) - $width/2] [expr min($y0,$y1)] [expr max($x0,$x1) + $width/2] [expr max($y0,$y1)]]
                    set wires [get_wires_within $box M17 true]
                    incr index
                }
            }

            lappend new_line_list [concat $newl $dir]

          } else {

            set index 0
            set m16_pg_dist 4.341
            set width [get_db [get_db layers  M16] .width]
            set box   [list [expr min($x0,$x1)] [expr min($y0,$y1) - $width/2] [expr max($x0,$x1)] [expr max($y0,$y1) + $width/2]]

            set box [list [expr min($x0,$x1)] [expr min($y0,$y1) - $m16_pg_dist] [expr max($x0,$x1)]  [expr max($y0,$y1) + $m16_pg_dist]]
            set wires [get_db [get_wires_within $box M16 true] -if .net.name==VDD||.net.name==VSS]
            set pgys  [lsort -u [get_db $wires .path.y]]
            
            if { [llength $pgys] != 2 && [llength $pgys] != 3 } { puts "-E- Failed finding PG" ; return }
            if { [llength $pgys] == 3 } { set pgys [lrange $pgys 1 2] }
            
            set pitch [expr abs([lindex $pgys 0] - [lindex $pgys 1])]
            set y0    [expr [lsum $pgys]/2]
            set y1 $y0

            set newl  [list $x0 $y0 $x1 $y1]

            set box   [list [expr min($x0,$x1)] [expr min($y0,$y1) - $width/2] [expr max($x0,$x1)] [expr max($y0,$y1) + $width/2]]

            set wires [get_wires_within $box M16 true]
            while { [llength $wires] > 0 && $index < $safety } {
                # TODO find closest vdd-vss
                set newl [list $x0 [expr $y0 - $pitch] $x1 [expr $y1 - $pitch]]
                lassign $newl x0 y0 x1 y1
                set box   [list [expr min($x0,$x1)] [expr min($y0,$y1) - $width/2] [expr max($x0,$x1)] [expr max($y0,$y1) + $width/2]]
                set wires [get_wires_within $box M16 true]
                incr index
            }
            if { $index == $safety && [llength $wires] > 0 } {
                set index 0
                lassign $orig_newl x0 y0 x1 x2
                while { [llength $wires] > 0 && $index < $safety} {
                    set newl [list $x0 [expr $y0 + $pitch] $x1 [expr $y1 + $pitch]]
                    lassign $newl x0 y0 x1 y1
                    set box   [list [expr min($x0,$x1)] [expr min($y0,$y1) - $width/2] [expr max($x0,$x1)] [expr max($y0,$y1) + $width/2]]
                    set wires [get_wires_within $box M16 true]
                    incr index
                }
            }


            lappend new_line_list [concat $newl $dir]

          }

        }
        
        if { [llength $new_line_list] == 0 } { puts " M16 0 ; M17 0" ; continue }

        set settings "set_db edit_wire_type regular
        set_db edit_wire_nets [get_object_name $net]
        set_db edit_wire_create_crossover_vias {0}
        set_db edit_wire_layer_vertical   M17
        set_db edit_wire_layer_horizontal   M16
        set_db edit_wire_rule {grid_clk_vp_rule_2}
        "
        eval $settings
        foreach line $new_line_list {
          lassign $line x0 y0 x1 y1 dir
          
          if { $dir == "v" } { set y0 [expr $y0 + $margin] ; set y1 [expr $y1 - $margin] } else { set x0 [expr $x0 + $margin] ; set x1 [expr $x1 - $margin] }
          
          edit_add_route_point $x0  $y0
          edit_end_route_point $x1  $y1
        }
        
        if { [llength [set m17w [get_db [get_db $net .wires] -if .layer.name==M17]]] > 0 } { set m17l [get_db $m17w .length] } { set m17l 0 }
        if { [llength [set m16w [get_db [get_db $net .wires] -if .layer.name==M16]]] > 0 } { set m16l [get_db $m16w .length] } { set m16l 0 }
        puts " M16 $m16l ; M17 $m17l"

    }
}


proc be_connect_pre_route_to_vp { net } {
    
    
    
}

proc _return_event {{index 0}} {return [history event $index]}

proc start_record { {file ""} {cmd_list_to_record {}} } {
    
    if { $file == "" } { set ::_be_record_file record_connectivity_change_[::ory_time::stamp].tcl } { set ::_be_record_file $file }
    echo "enter_eco_mode" > $::_be_record_file
    
    proc record_last_command { args } {
        set res [lindex $args 0]
        echo $res >> $::_be_record_file
    }
    
    if { $cmd_list_to_record == {} } {    
      set cmd_list_to_record { eco_add_repeater connect_pin connect_hpin eco_update_cell disconnect_hpin disconnect_pin delete_inst place_inst }
    }

    foreach cmd $cmd_list_to_record {
        if { [regexp "record_last_command" [trace info execution $cmd]] == 0 } { 
            trace add execution $cmd leave record_last_command
        }
    }
    
}

proc info_record {} {
    set cmd_list_to_record { eco_add_repeater connect_pin connect_hpin eco_update_cell disconnect_hpin disconnect_pin }
    foreach cmd $cmd_list_to_record {
        puts "-I- Command: $cmd  \tTrace: [trace info execution $cmd]"
    }
    puts "-I- Record fille at: $::_be_record_file"
}


proc end_record {} {
    set cmd_list_to_record { eco_add_repeater connect_pin connect_hpin eco_update_cell disconnect_hpin disconnect_pin }
    foreach cmd $cmd_list_to_record {        
        if { [regexp "record_last_command" [trace info execution $cmd]] == 1 } { 
            trace remove execution $cmd leave record_last_command
        }
    }
    puts "-I- Record fille at: $::_be_record_file"
}

proc be_legalize_super_inv { {user_cells ""} {padding true} {max_dist 53} } {
    
    set constant_y_offset 5.25 ; # From BRCM spec. Will be added to row spread polygon
    set_db place_detail_honor_inst_pad true
    set_db place_detail_pad_fixed_insts true
    set prev_value [get_db place_detail_eco_max_distance]
    
    # This array defines row vertical spacing (Y lego - cell height) and Y and X offset when spreading the using the def
    array unset base_cells_attributes
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:spacing)  [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGT5X96] .bbox.ur.y]]
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:site)     SPRBUF
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:XDefOff)  9027
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:YDefOff)  2520
    
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:spacing)  [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGR5X96] .bbox.ur.y]]
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:site)     SPRBUF96R5
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:XDefOff)  9027
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:YDefOff)  2100
    
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:spacing) [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGT7X320] .bbox.ur.y]]
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:site)    SPRBUF320T7
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:XDefOff) 9027
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:YDefOff) 2520

    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:spacing) [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGR7X320] .bbox.ur.y]]
    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:site)    SPRBUF320R7
    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:XDefOff) 9027
    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:YDefOff) 2100

    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:spacing) [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGR5X192] .bbox.ur.y]]
    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:site)    SPRBUF192R5
    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:XDefOff) 9027
    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:YDefOff) 2100   
    
    set base_cells_attributes(F6UNAA_LPDSINVG3X48:spacing) [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVG3X48] .bbox.ur.y]]
    set base_cells_attributes(F6UNAA_LPDSINVG3X48:site)    SPRBUF48G3
    set base_cells_attributes(F6UNAA_LPDSINVG3X48:XDefOff) 9027
    set base_cells_attributes(F6UNAA_LPDSINVG3X48:YDefOff) 2520                

    set base_cells_attributes(F6UNAA_LPDSINVGT7X384:spacing) [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGT7X384] .bbox.ur.y]]
    set base_cells_attributes(F6UNAA_LPDSINVGT7X384:site)    SPRBUF384T7
    set base_cells_attributes(F6UNAA_LPDSINVGT7X384:XDefOff) 9027
    set base_cells_attributes(F6UNAA_LPDSINVGT7X384:YDefOff) 2520

    set base_cells_attributes(F6UNAA_LPDSINVGT5X192:spacing) [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGT5X192] .bbox.ur.y]]
    set base_cells_attributes(F6UNAA_LPDSINVGT5X192:site)    SPRBUF192T5
    set base_cells_attributes(F6UNAA_LPDSINVGT5X192:XDefOff) 9027
    set base_cells_attributes(F6UNAA_LPDSINVGT5X192:YDefOff) 2520   
    


    
    # Polygon to spread the rows by
    set boundary [lindex [get_db designs .boundary] 0]
    set poly {}
    foreach coor $boundary {
        lassign $coor x y
        if { $y == 0 } { set y $constant_y_offset }
        lappend poly [list $x $y]
    }
    
    array unset orig_loc_arr

    foreach key [array names base_cells_attributes *site*] {
        
        set base_cell [lindex [split $key ":"] 0]
        set site      $base_cells_attributes($base_cell:site)
        set spacing   $base_cells_attributes($base_cell:spacing)
        set XDefOff   $base_cells_attributes($base_cell:XDefOff)
        set YDefOff   $base_cells_attributes($base_cell:YDefOff)
        
        set width    [get_db [get_db base_cells $base_cell] .bbox.ur.x]
        set height   [get_db [get_db base_cells $base_cell] .bbox.ur.y]
        set hratio   1
        set vratio   1.5
        set hsite    0.051
        set vsite    0.21
        set hpadding [expr int( $width*$hratio/$hsite )]
        set vpadding [expr int( $height*$vratio/$vsite )]
        
        if { $padding } {
            set_db [get_db base_cells $base_cell] .bottom_padding $vpadding
            set_db [get_db base_cells $base_cell] .top_padding    $vpadding
            set_db [get_db base_cells $base_cell] .right_padding  $hpadding
            set_db [get_db base_cells $base_cell] .left_padding   $hpadding
        } else {
            set_db [get_db base_cells $base_cell] .bottom_padding 0
            set_db [get_db base_cells $base_cell] .top_padding    0
            set_db [get_db base_cells $base_cell] .right_padding  0
            set_db [get_db base_cells $base_cell] .left_padding   0
        }
        
        if { [set cells [get_db insts -if .base_cell.name==$base_cell]] == "" } { continue }
        if { $user_cells != "" } { set cells [get_db [common_collection [get_cells $cells] [get_cells $user_cells]]] }
        if { $cells == "" } { continue }
        
        puts "-I- Legalizing [llength $cells] cells of type $base_cell (super_inv_legalizer)"
        
        foreach cell $cells { set orig_loc_arr([get_db $cell .name]) [lindex [get_db $cell .location] 0] }
        
        # spread the iste rows of the Super Buffers legal locations
        create_row -site $site -polygon $poly -spacing $spacing -no_abut -no_flip_rows

        # Save orig lef file, and update lef
        set orig_lef_file [get_db [get_db base_cells $base_cell] .lef_file_name]
        update_lef_macro -macro $base_cell ./scripts/templates/quad/super_bufs/tsmc5ff_ck06t0750v.lef 

        # write def, move X by 8.3895, read it to the design
        write_def ex.def -no_core_cells -no_std_cells -no_special_net -no_tracks
        cat ex.def  | awk "{if (NF > 10 && \$3 == \"$site\") {m=\$4+$XDefOff; \$4=m}; print}" > ex1.def ; # This offset is off by 0.2um - but using the correct 9427 offset does not work
        cat ex1.def | awk "{if (NF > 10 && \$3 == \"$site\") {m=\$5+$YDefOff; \$5=m}; print}" > ex2.def
        redirect -var garbage { read_def ex2.def }

        # set the Super-Buffer at MX orientation and the site-rows + Enabling 60u as a legal movement
        set_db $cells .place_status placed
        set_db $cells .orient mx
        set_db [get_db rows  -if {.site.name == $site}] .orient mx
        set_db place_detail_eco_max_distance $max_dist
        set_db $cells .base_cell.site $site

        # Legalizing on the "special" site rows
        redirect place_detail_1_res.rpt { place_detail -inst [get_db $cells .name] }

        # remove the site rows, verify the Super-Buffers are at MX orientation and change their link to default sites
        delete_obj [get_db rows -if {.site.name == $site}]
        set_db $cells .orient mx
        set_db $cells .base_cell.site CORE_6

        # legalize place again to see that there are no movements - expect a 0.2um movement
        redirect place_detail_2_res.rpt {  place_detail -inst [get_db $cells .name] }
        # Change back to orig lef file
        update_lef_macro -macro $base_cell $orig_lef_file

        set_db [get_db base_cells $base_cell] .bottom_padding $vpadding
        set_db [get_db base_cells $base_cell] .top_padding    $vpadding
        set_db [get_db base_cells $base_cell] .right_padding  $hpadding
        set_db [get_db base_cells $base_cell] .left_padding   $hpadding

    }
    set_db place_detail_eco_max_distance $prev_value
    
    echo "Cell Displacement:\n----------------\n" > legalize_super_inv.rpt
    set disp_list {}
    foreach cell [array names orig_loc_arr] {
        
        set new_loc [lindex [get_db [get_cells $cell] .location] 0]
        set orig_loc $orig_loc_arr($cell)
        
        set xdisp [expr [lindex $new_loc 0] - [lindex $orig_loc 0]]
        set ydisp [expr [lindex $new_loc 1] - [lindex $orig_loc 1]]        
        set total_disp [expr abs($xdisp) + abs($ydisp)]
        
        lappend disp_list [list $cell $xdisp $ydisp $total_disp]
        
    }
    
    set disp_list [lsort -real -dec -index 3 $disp_list]
    
    redirect -app legalize_super_inv.rpt {rls_table -table $disp_list -header [list "Cell" "x_disp" "y_disp" "total_disp"] -spacious -breaks}
    
    puts "-I- Cell displacement (be_legalize_super_inv)"        
    rls_table -table $disp_list -header [list "Cell" "x_disp" "y_disp" "total_disp"] -spacious -breaks
    
}

proc be_build_super_inv_vp { {user_cells ""} } {

    # This array defines row vertical spacing (Y lego - cell height) and Y and X offset when spreading the using the def
    array unset base_cells_attributes
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:vp_def)     ./scripts/templates/quad/super_bufs/wip_96w_upto_m15_2vp.def 
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:m3_offset)  { 0.2645 -0.1740 }
    
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:vp_def)     "TBD" 
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:m3_offset)  {}
    
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:vp_def)    ./scripts/templates/quad/super_bufs/vp_def_320w_4p_upto16.def
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:m3_offset) { 0.2645 -0.1740 }

    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:vp_def)    ./scripts/templates/quad/super_bufs/clk_wip_320t_up_to_m15_4vps.def 
    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:m3_offset) { 0.2645 0.216 }

    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:vp_def)    ./scripts/templates/quad/super_bufs/clk_wip_192t_up_to_m15_2vps.def 
    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:m3_offset) { 0.0605 0.200 }
    
    set base_cells_attributes(F6UNAA_LPDSINVG3X48:vp_def)      ./scripts/templates/quad/super_bufs/vp_def_48w_1p_upto15.def
    set base_cells_attributes(F6UNAA_LPDSINVG3X48:m3_offset)   { 0.2645 -0.0010 }

    set base_cells_attributes(F6UNAA_LPDSINVGT7X384:vp_def)    ./scripts/templates/quad/super_bufs/vp_def_384w_4p_upto16.def
    set base_cells_attributes(F6UNAA_LPDSINVGT7X384:m3_offset) { 0.2645 -0.1740 }
    
    puts "-I- deleting early global route (be_build_super_inv_vp)"    
    delete_obj [get_db [get_db nets .wires] -if .status==unknown]
    delete_obj [get_db [get_db nets .vias ] -if .status==unknown]

    foreach key [array names base_cells_attributes *vp_def*] {
        
        set base_cell [lindex [split $key ":"] 0]
        set vp_def    $base_cells_attributes($base_cell:vp_def)
        set m3_offset $base_cells_attributes($base_cell:m3_offset)
        
        if { [set cells [get_db insts -if .base_cell.name==$base_cell]] == "" } { continue }
        if { $user_cells != "" } { set cells [get_db [common_collection [get_cells $cells] [get_cells $user_cells]]] }
        if { $cells == "" } { continue }
        puts "-I- Building VP for [llength $cells] cells of type $base_cell (be_build_super_inv_vp)"
        
        if { ![file exists $vp_def] } { puts "-E- No VP LEF file found in $vp_def" ; return -1 }

        #== Read the Via-Pillar ==#
        set new_net_name vp_net_$base_cell
        create_net -name $new_net_name

        #== Def with M15 ==#
        read_def -nets $vp_def

        set VPx [lindex [lsort -real -incr [get_db [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M3] .rect.ll.x]] 0]
        set VPy [lindex [lsort -real -incr [get_db [get_db [get_db [get_db nets $new_net_name] .wires] -if .rect.ll.x==$VPx&&.layer.name==M3] .rect.ll.y] ] 0]
        set RefNet "vp_net_$base_cell"
        
        puts "[format "%-80s" Cell_Name] [format "%-30s" Out_Net] [format "%-20s" "Ref_VP_Loc"] Shift"
        
        set zero_shift_net ""
        
        foreach c $cells {
            #== Select the INV ==#
            so [get_db $c .name]

            #== Get all needed attributes ==#
            set llx_anchor [get_db $c .bbox.ll.x]
            set lly_anchor [get_db $c .bbox.ll.y]
            set net    [get_db [get_db $c .pins -if {.direction==out}] .net]
            set OutNet [get_db $net .name]

            set shift [list [format "%.5f" [expr $llx_anchor - $VPx + [lindex $m3_offset 0]]] [format "%.5f" [expr $lly_anchor - $VPy + [lindex $m3_offset 1]] ]]

            puts "[format "%-80s" $c] [format "%-30s" $OutNet] [format "%-20s" "$llx_anchor $lly_anchor"] $shift"

            if { [lsum $shift] == 0 } { 
                set zero_shift_net $OutNet
            }
            
            for { set index 2 } { $index <= 16 } { incr index } {
                set wires [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M$index]
                set vias  [get_db [get_db [get_db nets $new_net_name] .vias]  -if .via_def.bottom_layer.name==M[expr $index - 1]]
                
                if { $wires != "" } {
                  so $wires
                  set cmd "edit_copy [join $shift " "] -net $OutNet"
                  eval $cmd
                }
                
                if { $vias != "" } {
                  so $vias
                  set cmd "edit_copy [join $shift " "] -net $OutNet"
                  eval $cmd
                }
            }

        }
        
        if { $zero_shift_net != "" } {
            puts "-I- Found zero shift net: $zero_shift_net"
            select_routes -nets $RefNet
            select_vias -nets $RefNet
            edit_update_route_net -to $zero_shift_net
        }

        #== Remove the redundant via-pillar ==#
        delete_obj [concat [get_db [get_db net:$RefNet ] .wires] [get_db [get_db net:$RefNet ] .vias]]
        delete_obj $RefNet
    }
}


proc be_build_x96_vl { {cells ""} {check_drc true} {delete_egr true} } {
    
    if { $delete_egr } {
        delete_obj [get_db [get_db nets .wires] -if .status==unknown]
        delete_obj [get_db [get_db nets .vias ] -if .status==unknown]
    }

    #== get_all Super-Inverters X96
    if { $cells == "" } {
        set SuperInvX96 [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }]
    } else {
        set SuperInvX96 [get_db [get_cells $cells]]
    }
    # set SuperInvX96 [get_db inst:grid_quadrant/level2_tap_b_t00]
    #== Read the Via-Pillar ==#
    create_net -name vp_net_right
    create_net -name vp_net_left

    #== Def with M15 ==#
    read_def scripts/templates/quad/super_bufs/vp_def_right_m15

    #== Def without M15 ==#
    #read_def scripts/templates/quad/super_bufs/vp_def_right
    read_def scripts/templates/quad/super_bufs/vp_def_left

    set VPx 2643.05
    set VPy 7798.35
    set RefNetRight "vp_net_right"
    set RefNetLeft  "vp_net_left"

    foreach c $SuperInvX96 {
        #== Select the INV ==#
        so [get_db $c .name]

        #== Get all needed attributes ==#
        set llx_anchor [get_db $c .bbox.ll.x]
        set lly_anchor [get_db $c .bbox.ll.y]
        set OutNet [get_db [get_db selected .pins -if {.direction==out}] .net.name]
        set M3DistFromBBox 2.8565
        set M3DistFromBBox [expr 2.8565]
        set Diff 0.01
        set M5DistFromBBox [expr $M3DistFromBBox - $Diff]

        # if {$OutNet==$RefNet} {continue}
        #== Calcultate the Left VP new location ==#
        set New_M3_VP_xloc [expr $llx_anchor + $M3DistFromBBox - $VPx]
        set New_M5_VP_xloc [expr $llx_anchor + $M5DistFromBBox - $VPx]    
        set New_VP_yloc [expr $lly_anchor - $VPy]

        #== Calculate Right VP new Location ==#
        set Right_M3_VP_xloc [expr $llx_anchor + $M3DistFromBBox - $VPx - 2.584]
        set Right_M5_VP_xloc [expr $llx_anchor + $M5DistFromBBox - $VPx - 2.584]    


        #== Select wires/vias in M3/V3 ==#
        so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name == M3}] [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer==layer:VIA3}]]
        edit_copy $New_M3_VP_xloc $New_VP_yloc -net $OutNet
        so [concat [get_db [get_db net:$RefNetLeft ] .wires. -if {.layer.name == M3}] [get_db [get_db net:$RefNetLeft ] .vias -if {.via_def.cut_layer==layer:VIA3}]]
        edit_copy $Right_M3_VP_xloc $New_VP_yloc -net $OutNet

        #== Select wires/vias which are in M4-M12,M15/V4-V12==#    
        so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name != M3 && .layer.name != M13 && .layer.name != M14}] [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer != layer:VIA3 && .via_def.cut_layer != layer:VIA13 && .via_def.cut_layer != layer:VIA14}]]
        edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
        so [concat [get_db [get_db net:$RefNetLeft ] .wires. -if {.layer.name != M3 && .layer.name != M13 && .layer.name != M14}] [get_db [get_db net:$RefNetLeft ] .vias -if {.via_def.cut_layer != layer:VIA3 && .via_def.cut_layer != layer:VIA13 && .via_def.cut_layer != layer:VIA14}]]
        edit_copy $Right_M5_VP_xloc $New_VP_yloc -net $OutNet

        #== Select wires/vias which are in M13 ==#        
        so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name == M13}]]
        edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
        so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name == M13}]]
        edit_copy [expr $Right_M5_VP_xloc + 0.1] $New_VP_yloc -net $OutNet

       #== Select wires/vias which are in V13 ==#        
        so [concat [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer==layer:VIA13}]]
        edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
        so [concat [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer==layer:VIA13}]]
        edit_copy [expr $Right_M5_VP_xloc + 0.1] $New_VP_yloc -net $OutNet


        #== Select wires/vias which in M14 ==#        
        so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name == M14}]]
        edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
        so [concat [get_db [get_db net:$RefNetLeft ] .wires. -if {.layer.name == M14}]]
        edit_copy $Right_M5_VP_xloc [expr $New_VP_yloc - 0.25] -net $OutNet

        #== Select wires/vias which are in V14 ==#        
        so [concat [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer==layer:VIA14}]]
        edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
    }

    #== Clean all provios markers ==#
    delete_markers -all

    #== Check DRC for the Via-Pillar==#
    if { $check_drc } {
        redirect VP_Check_DRC {
          foreach n [get_db -uniq [get_db -uniq [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .pins -if {.direction == out}] .net.name] {
            so $n ; 
            puts "checking drc on net: [get_db selected  .name]" ; 
            check_drc -check_only selected_net
          }
        }
    } else {
        puts "-W- Skipping check_drc for clock nets"
        puts "-W- If you wish to run check_drc, run:"
        puts "-W- foreach n \[get_db -uniq \[get_db -uniq \[get_db insts -if \{.base_cell.name == F6UNAA_LPDSINVGT5X96 \}\] .pins -if \{.direction == out\}\] .net.name\] \{"
        puts "-W-   so \$n ; "
        puts "-W-   puts \"checking drc on net: \[get_db selected  .name\]\" ; "
        puts "-W-   check_drc -check_only selected_net"
        puts "-W- \}"
    }


    #== Remove the redundant via-pillar ==#
    delete_obj [concat [get_db [get_db net:$RefNetRight ] .wires] [get_db [get_db net:$RefNetRight ] .vias]]
    delete_obj [concat [get_db [get_db net:$RefNetLeft  ] .wires] [get_db [get_db net:$RefNetLeft  ] .vias]]

    delete_obj $RefNetRight
    delete_obj $RefNetLeft

    # so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name == M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer==layer:VIA3}]]
    # edit_copy -3.876 0 -net level2_tap_a_t00_net
    # so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name != M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer != layer:VIA3}]]
    # edit_copy -3.886 0 -net level2_tap_a_t00_net

}



proc be_build_x320w_vl { {cells ""} {check_drc true} {delete_egr true} } {
    
    set bc_name F6UNAA_LPDSINVGT7X320
    
    if { $delete_egr } {
        delete_obj [get_db [get_db nets .wires] -if .status==unknown]
        delete_obj [get_db [get_db nets .vias ] -if .status==unknown]
    }

    #== get_all Super-Inverters T7X320
    if { $cells == "" } {
        set SuperInvX320 [get_db insts -if {.base_cell.name == $bc_name }]
    } elseif { [set SuperInvX320 [get_db [get_cells $cells]]] == ""  } {
        puts "-E- Did not find any $bc_name cells (be_build_x320w_vl)" ; return -1 
    }

    #== Read the Via-Pillar ==#
    set new_net_name vp_net_$bc_name
    create_net -name $new_net_name

    #== Def with M15 ==#
    read_def scripts/templates/quad/super_bufs/vp_def_320w_4p_upto16.def

    set VPx [lindex [lsort -real -incr [get_db [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M3] .rect.ll.x]] 0]
    set VPy [lindex [lsort -real -incr [get_db [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M3] .rect.ll.y]] 0]
    set m3_offset { 0.2645 -0.1740 }
    set RefNet "vp_net_$bc_name"

    foreach c $SuperInvX320 {
        #== Select the INV ==#
        so [get_db $c .name]

        #== Get all needed attributes ==#
        set llx_anchor [get_db $c .bbox.ll.x]
        set lly_anchor [get_db $c .bbox.ll.y]
        set net    [get_db [get_db $c .pins -if {.direction==out}] .net]
        set OutNet [get_db $net .name]
#        set M3DistFromBBox 2.8565
#        set M3DistFromBBox [expr 2.8565]
#        set Diff 0.01
#        set M5DistFromBBox [expr $M3DistFromBBox - $Diff]

        set shift [list [expr $llx_anchor - $VPx + [lindex $m3_offset 0]] [expr $lly_anchor - $VPy + [lindex $m3_offset 1]] ]
        
        puts "[format "%-80s" $c] [format "%-30s" $OutNet] [format "%-20s" "$llx_anchor $lly_anchor"] $shift"

        for { set index 3 } { $index <= 16 } { incr index } {
            set wires [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M$index]
            set vias  [get_db [get_db [get_db nets $new_net_name] .vias]  -if .via_def.bottom_layer.name==M[expr $index - 1]]

            so $wires
            set cmd "edit_copy [join $shift " "] -net $OutNet"
            eval $cmd

            so $vias
            set cmd "edit_copy [join $shift " "] -net $OutNet"
            eval $cmd
        }

    }

    #== Check DRC for the Via-Pillar==#
    if { $check_drc } {
        #== Clean all provios markers ==#
        delete_markers -all
        redirect VP_Check_DRC {
          foreach n [get_db -uniq [get_db -uniq [get_db insts -if {.base_cell.name == $bc_name }] .pins -if {.direction == out}] .net.name] {
            so $n ; 
            puts "checking drc on net: [get_db selected  .name]" ; 
            check_drc -check_only selected_net
          }
        }
    } else {
        puts "-W- Skipping check_drc for clock nets"
        puts "-W- If you wish to run check_drc, run:"
        puts "-W- foreach n \[get_db -uniq \[get_db -uniq \[get_db insts -if \{.base_cell.name == F6UNAA_LPDSINVGT5X96 \}\] .pins -if \{.direction == out\}\] .net.name\] \{"
        puts "-W-   so \$n ; "
        puts "-W-   puts \"checking drc on net: \[get_db selected  .name\]\" ; "
        puts "-W-   check_drc -check_only selected_net"
        puts "-W- \}"
    }


    #== Remove the redundant via-pillar ==#
    delete_obj [concat [get_db [get_db net:$RefNet ] .wires] [get_db [get_db net:$RefNet ] .vias]]
    delete_obj $RefNet

    # so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name == M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer==layer:VIA3}]]
    # edit_copy -3.876 0 -net level2_tap_a_t00_net
    # so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name != M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer != layer:VIA3}]]
    # edit_copy -3.886 0 -net level2_tap_a_t00_net

}


proc be_build_x320t_vl { {cells ""} {check_drc true} {delete_egr true} } {
    
    set bc_name F6UNAA_LPDSINVGR7X320
    
    if { $delete_egr } {
        delete_obj [get_db [get_db nets .wires] -if .status==unknown]
        delete_obj [get_db [get_db nets .vias ] -if .status==unknown]
    }

    #== get_all Super-Inverters T7X320
    if { $cells == "" } {
        set SuperInvX320 [get_db insts -if {.base_cell.name == $bc_name }]
    } elseif { [set SuperInvX320 [get_db [get_cells $cells]]] == "" } {
        puts "-E- Did not find any $bc_name cells (be_build_x320t_vl)" ; return -1 
    }

    #== Read the Via-Pillar ==#    
    set new_net_name vp_net_$bc_name
    create_net -name $new_net_name

    #== Def with M15 ==#
    read_def scripts/templates/quad/super_bufs/clk_wip_320t_up_to_m15_4vps.def

    set VPx [lindex [lsort -real -incr [get_db [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M3] .rect.ll.x]] 0]
    set VPy [lindex [lsort -real -incr [get_db [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M3] .rect.ll.y]] 0]
    set m3_offset { 0.2645 0.216 }
    set RefNet "vp_net_$bc_name"

    foreach c $SuperInvX320 {
        #== Select the INV ==#
        so [get_db $c .name]

        #== Get all needed attributes ==#
        set llx_anchor [get_db $c .bbox.ll.x]
        set lly_anchor [get_db $c .bbox.ll.y]
        set net    [get_db [get_db $c .pins -if {.direction==out}] .net]
        set OutNet [get_db $net .name]
#        set M3DistFromBBox 2.8565
#        set M3DistFromBBox [expr 2.8565]
#        set Diff 0.01
#        set M5DistFromBBox [expr $M3DistFromBBox - $Diff]

        set shift [list [expr $llx_anchor - $VPx + [lindex $m3_offset 0]] [expr $lly_anchor - $VPy + [lindex $m3_offset 1]] ]
        
        puts "[format "%-80s" $c] [format "%-30s" $OutNet] [format "%-20s" "$llx_anchor $lly_anchor"] $shift"

        for { set index 3 } { $index <= 16 } { incr index } {
            set wires [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M$index]
            set vias  [get_db [get_db [get_db nets $new_net_name] .vias]  -if .via_def.bottom_layer.name==M[expr $index - 1]]

            so $wires
            set cmd "edit_copy [join $shift " "] -net $OutNet"
            eval $cmd

            so $vias
            set cmd "edit_copy [join $shift " "] -net $OutNet"
            eval $cmd
        }

    }

    #== Clean all provios markers ==#
    delete_markers -all

    #== Check DRC for the Via-Pillar==#
    if { $check_drc } {
        redirect VP_Check_DRC {
          foreach n [get_db -uniq [get_db -uniq [get_db insts -if {.base_cell.name == $bc_name }] .pins -if {.direction == out}] .net.name] {
            so $n ; 
            puts "checking drc on net: [get_db selected  .name]" ; 
            check_drc -check_only selected_net
          }
        }
    } else {
        puts "-W- Skipping check_drc for clock nets"
        puts "-W- If you wish to run check_drc, run:"
        puts "-W- foreach n \[get_db -uniq \[get_db -uniq \[get_db insts -if \{.base_cell.name == F6UNAA_LPDSINVGT5X96 \}\] .pins -if \{.direction == out\}\] .net.name\] \{"
        puts "-W-   so \$n ; "
        puts "-W-   puts \"checking drc on net: \[get_db selected  .name\]\" ; "
        puts "-W-   check_drc -check_only selected_net"
        puts "-W- \}"
    }


    #== Remove the redundant via-pillar ==#
    delete_obj [concat [get_db [get_db net:$RefNet ] .wires] [get_db [get_db net:$RefNet ] .vias]]
    delete_obj $RefNet

    # so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name == M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer==layer:VIA3}]]
    # edit_copy -3.876 0 -net level2_tap_a_t00_net
    # so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name != M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer != layer:VIA3}]]
    # edit_copy -3.886 0 -net level2_tap_a_t00_net

}




proc be_build_x192t_vl { {cells ""} {check_drc true} {delete_egr true} } {
    
    set bc_name F6UNAA_LPDSINVGR5X192
    
    if { $delete_egr } {
        delete_obj [get_db [get_db nets .wires] -if .status==unknown]
        delete_obj [get_db [get_db nets .vias ] -if .status==unknown]
    }

    #== get_all Super-Inverters T7X320
    if { $cells == "" } {
        set SuperInvX192 [get_db insts -if {.base_cell.name == $bc_name }]
    } else {
        puts "-E- Did not find any $bc_name cells (be_build_x192t_vl)" ; return -1 
    }

    #== Read the Via-Pillar ==#
    set new_net_name vp_net_$bc_name
    create_net -name $new_net_name

    #== Def with M15 ==#
    read_def scripts/templates/quad/super_bufs/clk_wip_192t_up_to_m15_2vps.def

    set VPx [lindex [lsort -real -incr [get_db [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M3] .rect.ll.x]] 0]
    set VPy [lindex [lsort -real -incr [get_db [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M3] .rect.ll.y]] 0]
    set m3_offset { 0.2645 0.216 }
    set RefNet "vp_net_$bc_name"

    foreach c $SuperInvX192 {
        #== Select the INV ==#
        so [get_db $c .name]

        #== Get all needed attributes ==#
        set llx_anchor [get_db $c .bbox.ll.x]
        set lly_anchor [get_db $c .bbox.ll.y]
        set net    [get_db [get_db $c .pins -if {.direction==out}] .net]
        set OutNet [get_db $net .name]
#        set M3DistFromBBox 2.8565
#        set M3DistFromBBox [expr 2.8565]
#        set Diff 0.01
#        set M5DistFromBBox [expr $M3DistFromBBox - $Diff]

        set shift [list [expr $llx_anchor - $VPx + [lindex $m3_offset 0]] [expr $lly_anchor - $VPy + [lindex $m3_offset 1]] ]
        
        puts "[format "%-80s" $c] [format "%-30s" $OutNet] [format "%-20s" "$llx_anchor $lly_anchor"] $shift"

        for { set index 3 } { $index <= 16 } { incr index } {
            set wires [get_db [get_db [get_db nets $new_net_name] .wires] -if .layer.name==M$index]
            set vias  [get_db [get_db [get_db nets $new_net_name] .vias]  -if .via_def.bottom_layer.name==M[expr $index - 1]]

            so $wires
            set cmd "edit_copy [join $shift " "] -net $OutNet"
            eval $cmd

            so $vias
            set cmd "edit_copy [join $shift " "] -net $OutNet"
            eval $cmd
        }

    }

    #== Clean all provios markers ==#
    delete_markers -all

    #== Check DRC for the Via-Pillar==#
    if { $check_drc } {
        redirect VP_Check_DRC {
          foreach n [get_db -uniq [get_db -uniq [get_db insts -if {.base_cell.name == $bc_name }] .pins -if {.direction == out}] .net.name] {
            so $n ; 
            puts "checking drc on net: [get_db selected  .name]" ; 
            check_drc -check_only selected_net
          }
        }
    } else {
        puts "-W- Skipping check_drc for clock nets"
        puts "-W- If you wish to run check_drc, run:"
        puts "-W- foreach n \[get_db -uniq \[get_db -uniq \[get_db insts -if \{.base_cell.name == F6UNAA_LPDSINVGT5X96 \}\] .pins -if \{.direction == out\}\] .net.name\] \{"
        puts "-W-   so \$n ; "
        puts "-W-   puts \"checking drc on net: \[get_db selected  .name\]\" ; "
        puts "-W-   check_drc -check_only selected_net"
        puts "-W- \}"
    }


    #== Remove the redundant via-pillar ==#
    delete_obj [concat [get_db [get_db net:$RefNet ] .wires] [get_db [get_db net:$RefNet ] .vias]]
    delete_obj $RefNet

    # so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name == M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer==layer:VIA3}]]
    # edit_copy -3.876 0 -net level2_tap_a_t00_net
    # so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name != M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer != layer:VIA3}]]
    # edit_copy -3.886 0 -net level2_tap_a_t00_net

}


proc check_super_inv_drc { {cells ""} {nets ""} {short_only false}} {

    if { $cells == "" } { 
        set cells [get_db insts -if .base_cell==*UN*LPDSINV*]
    } else {
        set cells [get_db [get_cells $cells ]]
    }
    
    if { $cells == "" } { puts "-E- No super inv cells found (check_super_inv_drc) [ory_time::now]" ; return -1 }
    
    if { $nets == "" } {
        set nets [get_db -uniq [get_net -of [get_pins -of $cells]]]
    } else {
        set nets  [get_db -uniq [get_nets $nets]]
        set cells [get_db [common_collection [get_cells -of $nets] [get_cells $cells]]]
    }
    
    puts "-I- Delete DRC markers (check_super_inv_drc) [ory_time::now]"
    delete_markers -all
    
    puts "-I- Check DRCs on each net for [llength $nets] nets (check_super_inv_drc) [ory_time::now]"
    set file_name "check_super_inv_drc_[::ory_time::stamp].rpt"
    redirect $file_name {
        foreach net $nets {
            puts "-I- Checking DRC on net: $net"
            deselect_obj -all
            select_obj $net
            check_drc -check_only selected_net
        }
    }
    
    puts "-I- Check DRCs over each cell's area for [llength $cells] (check_super_inv_drc) [ory_time::now]"
    redirect -app $file_name {
        foreach cell $cells {
            puts "-I- Checking DRC over cell: $cell"
            set area [get_db $cell .bbox]
            check_drc -area $area
        }
    }
    
    puts "-I- Checking connectivity for [llength $nets] (check_super_inv_drc) [ory_time::now]"
    redirect -app $file_name {puts "-I- Check connectivity:"}
    redirect -app $file_name {check_connectivity -net [get_db $nets .name] -ignore_dangling}
    
    puts "-I- Check DRC log in: $file_name (check_super_inv_drc) [ory_time::now]"
#    redirect -var res { if { [catch {puts [exec grep -s "Verification Complete" $file_name | grep -s -v "0 Viols"]} res] } {} }
#    
#    if { $res == ""  } {
#        set total 0 
#    } else {
#        set total [lsum [regsub -all " +" [string map {"{" " " "}" " "} [regexp -inline -all " \[0-9\]+ " $res]] " "]]
#    }
    puts "-I- Found total of [llength [get_db markers]] DRC violations related to super inverters (check_super_inv_drc) [ory_time::now]"
    
    array unset drc_subtype 
    foreach type [lsort [get_db markers .subtype]] {
        set drc_subtype($type) [llength [get_db markers -if .subtype==$type]]
    }
    parray drc_subtype    
    
}


proc be_insert_dummy_invs { pins {number_of_invs 2} {base_cell F6LLAA_LPDINVX32} } {
    
    set prefix "be_super_inv_dummy_inv_"
    set index  0
    set all_new_insts {}
    
    while { [llength [get_db insts "$prefix$index" ]] != 0 } { incr index }
    
    foreach pin [get_db [get_pins $pins]] {
        
        set pin_loc [get_db $pin .location]
        set net     [get_db $pin .net]
        
        set cmd ""
        set new_insts {}
        for { set i 0 } { $i < $number_of_invs } { incr i } {
            
            set new_cell_name $prefix$index
            lappend new_insts $new_cell_name
            lappend all_new_insts $new_cell_name

            append cmd "create_inst -name $new_cell_name -base_cell $base_cell -location $pin_loc -orient r0 -dont_snap -place_status placed\n"
            
            incr index
            
        }        
        eval $cmd
        
        set cmd ""
        set new_cells [get_db [get_cells $new_insts]]        
        foreach new_cell $new_cells {
            set in    [get_db [get_pins -of $new_cell -filter direction==in] .base_name]
            append cmd "connect_pin -inst [get_db $new_cell .name] -pin $in -net [get_db $net .name]\n"
        }
        eval $cmd
                
    }

    set all_new_cells [get_db [get_cells $all_new_insts] .name]

    set prev_value [get_db place_detail_eco_max_distance]
    set_db place_detail_eco_max_distance 20

    place_detail -inst $all_new_cells

    set_db place_detail_eco_max_distance $prev_value
   
}

proc be_insert_diode { pins {number_of_invs 1} {base_cell F6LLAA_DIODEX4} } {
    
    set prefix "be_super_inv_diode_"
    set index  0
    set all_new_insts {}
    
    while { [llength [get_db insts "$prefix$index" ]] != 0 } { incr index }
    
    foreach pin [get_db [get_pins $pins]] {
        
        set pin_loc [get_db $pin .location]
        set net     [get_db $pin .net]
        
        set cmd ""
        set new_insts {}
        for { set i 0 } { $i < $number_of_invs } { incr i } {
            
            set new_cell_name $prefix$index
            lappend new_insts $new_cell_name
            lappend all_new_insts $new_cell_name

            append cmd "create_inst -name $new_cell_name -base_cell $base_cell -location $pin_loc -orient r0 -dont_snap -place_status placed\n"
            
            incr index
            
        }        
        eval $cmd
        
        set cmd ""
        set new_cells [get_db [get_cells $new_insts]]        
        foreach new_cell $new_cells {
            set in    [get_db [get_pins -of $new_cell -filter direction==in] .base_name]
            append cmd "connect_pin -inst [get_db $new_cell .name] -pin $in -net [get_db $net .name]\n"
        }
        eval $cmd
                
    }

    set all_new_cells [get_db [get_cells $all_new_insts] .name]

    set prev_value [get_db place_detail_eco_max_distance]
    set_db place_detail_eco_max_distance 20

    place_detail -inst $all_new_cells

    set_db place_detail_eco_max_distance $prev_value
   
}

proc get_super_invs_cells { {pattern ""} } {    
    set cells [get_db insts -if .base_cell==*LPDSINV*]
    return $cells        
}

proc get_super_invs_nets { {pattern ""} } {
    set nets [get_nets -of [get_super_invs_cells $pattern]]
    return [get_db -uniq $nets]
}


proc enter_eco_mode { {end false} } {
    
    proc _pre_eco_settings { args } {
        set_db eco_honor_dont_use false
        set_db eco_update_timing false
        set_db eco_refine_place false
        set_db eco_check_logical_equivalence false
        set_db eco_honor_fixed_wires false
    }

    set cmd_list_to_record { \
      eco_add_repeater \
      eco_update_cell \
      delete_inst }

    foreach cmd $cmd_list_to_record {
        if { !$end && [regexp "_pre_eco_settings" [trace info execution $cmd]] == 0 } { 
            trace add execution $cmd enter _pre_eco_settings
        } elseif { $end } {            
            set_db eco_honor_dont_use true
            set_db eco_update_timing true
            set_db eco_refine_place true
            set_db eco_check_logical_equivalence true
            set_db eco_honor_fixed_wires true            
            trace remove execution $cmd enter _pre_eco_settings
        }
    }
}


proc clock_tree_cell_dist { } {
    
    set clock_cells [add_to_collection [get_cells -quiet -hier *level*tap*] [add_to_collection [get_cells -quiet -hier *tree_source*] [get_cells -quiet -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
    
    set table {}
    
    for { set i 0 } { $i < 5 } { incr i } {
        
        set level_cells [filter_collection $clock_cells full_name=~"*level$i*"]
        
        foreach_in_collection cell $level_cells {
            
            set cell_name [get_db $cell .name]
            set cell_loc  [lindex [get_db $cell .location] 0]
            lassign $cell_loc x0 y0 
            
            set out_pin [get_pins -of $cell -filter direction==out]
            set net     [get_nets -of $out_pin]
            set rcvs    [get_db $net .loads]
            
            foreach rcv $rcvs { 
                set rcv_loc [lindex [get_db $rcv .location] 0] 
                lassign $rcv_loc xr yr 
                
                set dist [format "%.2f" [expr abs($x0 - $xr) + abs($y0 -$yr)]]
                
                lappend table [list $cell_name [get_db $rcv .name] $dist]
            }            
            
        }
        
    }
    
    rls_table -table $table -header {drv rcv dist} -spac -breaks
     
}


proc split_clock_net { net splits {prefix ""} {base_cell F6UNAA_LPDSINVGT5X96} } {
    
    # Splits == number of new nets!
    
    if { $prefix == "" } { set prefix "levelx_tap_split_clock_net" }
    set margin 0.1

    set_db eco_honor_dont_use false
    set_db eco_update_timing false
    set_db eco_refine_place false
    set_db eco_check_logical_equivalence false
    
    set nets [get_db [get_nets $net]]
    
    puts "-I- Splitting net [get_db $net .name] into $splits nets"
        
    if { [llength [set driver    [get_db $net .driver_pins]]] == 0 } {set driver    [get_db $net .driver_ports]}
    if { [llength [set receivers [get_db $net .load_pins  ]]] == 0 } {set receivers [get_db $net .load_ports  ]}

    if { [llength $driver]    == 0 } { puts "-W- No driver found for $net" ; continue }
    if { [llength $receivers] == 0 } { puts "-W- No receivers found for $net" ; continue }

    set driver_loc    [lindex [get_db $driver .location] 0]
    set receivers_loc  [ory_get_com $receivers]

    lassign $driver_loc drx dry
    lassign $receivers_loc rcx rcy

    set xdist     [expr abs($drx - $rcx)]
    set ydist     [expr abs($dry - $rcy)]
    set dist      [expr $xdist + $ydist]

    if { $xdist > $ydist } { set dir "h" } {set dir "v" }
    if { ![string match "v*" $dir] } { if { $dir == "h" && $drx < $rcx } { append dir "r" } { append dir "l" } }
    if { ![string match "h*" $dir] } { if { $dir == "v" && $dry < $rcy } { append dir "u" } { append dir "d" } }
    
    set new_net_length [expr $dist/$splits]
   
    #??????
 
    set_db eco_check_logical_equivalence true
    set_db eco_honor_dont_use true
    set_db eco_update_timing  true
    set_db eco_refine_place   true  

    if { $debug } { return }
    
    be_legalize_super_inv $cells 100

}

::parseOpt::cmdSpec htree_add_useful_skew {
    -help "Add inverter-pair repeater. Notice that this script is effective only for SINGLE AXIS x/y nets"
    -opt    {
            {-optname inpins_list    -type list     -default ""                     -required 1   -help "list of lists. clock input pins of adjacent buffers sharing the same driver. each node in the list is a group to delay"}
            {-optname base_cell      -type string   -default "F6UNAA_LPDSINVG3X48"  -required 0   -help "type of cell to insert"}
            {-optname dist_load      -type integer  -default 5                      -required 0   -help "Distance of 1st inverter pair from load"}
            {-optname dist_bw_pairs  -type integer  -default 200                    -required 0   -help "Distance between each inverter pair"}            
            {-optname dist_bw_invs   -type integer  -default 0                      -required 0   -help "Distance between inverters within a pair"}            
            {-optname new_cell_name  -type string   -default "add_useful_skew_inv"  -required 0   -help "name of new repeaters. Will add _0 and _1 to cell name, and _net to new net name"}                        
            {-optname num_of_cells   -type integer  -default 1                      -required 0   -help "Number of pairs to add"} 
            {-optname no_legalize    -type boolean  -default false                  -required 0   -help "If true, do not leglize inserted cells"} 
            {-optname route          -type boolean  -default false                  -required 0   -help "Run route at the end of insertion"} 
            {-optname is_debug          -type boolean  -default false                  -required 0   -help "Do not insert any cells. Just print commands"} 
    }
}
proc htree_add_useful_skew { args } {
    
    enter_eco_mode

	if { ! [::parseOpt::parseOpt htree_add_useful_skew $args] } { return 0 }
    set inpins_list    $opt(-inpins_list)
    set base_cell      $opt(-base_cell)
    set dist_load      $opt(-dist_load)
    set dist_bw_pairs  $opt(-dist_bw_pairs)
    set dist_bw_invs   $opt(-dist_bw_invs)
    set new_cell_name  $opt(-new_cell_name)
    set num_of_cells   $opt(-num_of_cells)
    set no_legalize    $opt(-no_legalize)
    set route          $opt(-route)
    set is_debug       $opt(-is_debug)
         
    set all_new_cells {}
    set all_new_nets  {}
    set start 0
    foreach inpins $inpins_list {
    
        set inpins [get_db [get_pins $inpins]]
        if { [llength $inpins] == 0 } { puts "-E- No pins provided (htree_add_useful_skew)" ; return -1 }

        set rcv_com [ory_get_com $inpins]
        set drv_loc [lindex [get_db [get_pins -of [get_nets -of $inpins] -filter direction==out] .location] 0]

        lassign $rcv_com rcvx rcvy
        lassign $drv_loc drvx drvy

        set distx [expr - $rcvx + $drvx]
        set disty [expr - $rcvy + $drvy]

        if { [expr abs($distx)] > [expr abs($disty)] } { 
            set dir "h" 
            set sign [expr abs($distx)/$distx]
            set rcvx [expr $rcvx + $sign*$dist_load]
        } else { 
            set dir "v" 
            set sign [expr abs($disty)/$disty]
            set rcvy [expr $rcvy + $sign*$dist_load]
        }

        array unset new_locs
        for { set i 0 } { $i < [expr $num_of_cells ] } { incr i } {
            if { $dir == "h" } { 
                set new_locs([expr $start + 2*$i + 0]) [list [expr $rcvx + $i*$sign*$dist_bw_pairs - 0.5*$sign*$dist_bw_invs] $rcvy]
                set new_locs([expr $start + 2*$i + 1]) [list [expr $rcvx + $i*$sign*$dist_bw_pairs + 0.5*$sign*$dist_bw_invs] $rcvy]
            } else {
                set new_locs([expr $start + 2*$i + 0]) [list $rcvx [expr $rcvy + $i*$sign*$dist_bw_pairs - 0.5*$sign*$dist_bw_invs]   ]
                set new_locs([expr $start + 2*$i + 1]) [list $rcvx [expr $rcvy + $i*$sign*$dist_bw_pairs + 0.5*$sign*$dist_bw_invs]]
            }
        }        
        incr start [expr 2*$i]

        # Set add_buffer_on_route commands
        # TODO: MAKE SURE THE BUFFERS ARE ACTUALLY !!ON ROUTE!!
        set_db eco_honor_fixed_wires false
        foreach i [lsort -dec -real [array names new_locs]] {
            lassign $new_locs($i) x y
            set cmd "eco_add_repeater -cell $base_cell -location \{$x $y\} -pins \{[get_db $inpins .name]\} -name ${new_cell_name}_$i -new_net_name ${new_cell_name}_${i}_net"
            puts "Running: $cmd"
            if { $is_debug } { continue } 
            eval $cmd 
        }
        set_db eco_honor_fixed_wires true

        set new_cells [get_db [get_cells -quiet $new_cell_name*]]
        set new_nets  [get_db [get_nets -quiet -of $new_cells]]
        
        lappend all_new_cells $new_cells
        lappend all_new_nets  $new_nets
    
    }
    
    set all_new_cells [get_db -uniq [get_cells -quiet $all_new_cells]]
    set all_new_nets  [get_db -uniq [get_nets -quiet $all_new_nets]]
    
    if { !$no_legalize && !$is_debug } {

        delete_routes -net    $all_new_nets
        be_legalize_super_inv $all_new_cells false 100
        be_build_super_inv_vp $all_new_cells

        set_db $all_new_cells .place_status fixed
        set_db $all_new_nets .dont_touch true
        set_db $all_new_nets .wires.status fixed
        set_db $all_new_nets .vias.status fixed
        
    }

    
#    if { $route } {
#        be_build_super_inv_vp $all_new_cells
#        
#        if { [get_db route_rules grid_clk_vp_rule_2] == "" } {
#        create_route_rule -name grid_clk_vp_rule_2 -width   {M1 0.02  M2 0.02  M3 0.02  M4 0.02  M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 \
#                                                 -spacing {M1 0.014 M2 0.015 M3 0.022 M4 0.022 M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}
#        }
#
#        set_db $new_nets .route_rule {}
#        foreach net [get_db $all_new_nets .name] {
#          set_route_attributes -reset -nets $net
#          set_route_attributes -nets $net -top_preferred_routing_layer 18 -bottom_preferred_routing_layer 17 \
#                               -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort high \
#                               -route_rule grid_clk_vp_rule_2
#        }
#
#        set_db $all_new_cells .place_status fixed
#        set_db $all_new_nets .dont_touch true
#        set_db $all_new_nets .wires.status fixed
#        set_db $all_new_nets .vias.status fixed
#
#        be_route_p2p [get_nets $new_nets]
#    }
#    
    
    enter_eco_mode true
    return $all_new_cells
    
}

proc quad_clock_route { cells } {
    
    set cells [get_db [get_cells $cells]]
    set nets  [get_db [get_nets -of $cells]]
    
    if { [llength $nets] == 0 } { puts "-E- No nets found for given cells" ;  return -1 }
    
    delete_routes -net    $nets
    be_build_super_inv_vp [get_cells -of [get_db [get_pins -of $nets] -if .direction==out]]
        
    if { [get_db route_rules grid_clk_vp_rule_2] == "" } {
    create_route_rule -name grid_clk_vp_rule_2 -width   {M1 0.02  M2 0.02  M3 0.02  M4 0.02  M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 \
                                             -spacing {M1 0.014 M2 0.015 M3 0.022 M4 0.022 M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}
    }

    set_db $nets .route_rule {}
    foreach net [get_db $nets .name] {
      set_route_attributes -reset -nets $net
      set_route_attributes -nets $net -top_preferred_routing_layer 18 -bottom_preferred_routing_layer 17 \
                           -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort high \
                           -route_rule grid_clk_vp_rule_2
    }

    be_route_p2p [get_nets $nets]


    ### TODO: CHECK IF I CAN ROUTE WITH NO TIMING UPDATE
    set_db route_design_with_timing_driven false
    set_db route_design_antenna_diode_insertion false
    set_db route_design_with_si_driven false
    set_db route_design_detail_fix_antenna false
    set_db route_design_detail_end_iteration 1

    deselect_obj -all
    select_obj  $nets
    route_global_detail -selected
    deselect_obj -all
    
    ### TODO: CHECK IF I CAN ROUTE WITH NO TIMING UPDATE
    set_db route_design_with_timing_driven true
    set_db route_design_antenna_diode_insertion true
    set_db route_design_with_si_driven true
    set_db route_design_detail_fix_antenna true
    set_db route_design_detail_end_iteration 0
    
    ory_calc_net_length $nets
    puts "-I- Quad clock nets length:"
    t $nets be_net_length

}

proc dbNetWireLenX { net } {
    set x_total ""
    foreach x_len [get_db [get_db [get_db nets $net] .wires -if {.direction==horizontal}] .length] { set x_total [expr $x_total + $x_len]} ; 
    return $x_total
}
proc dbNetWireLenY { net } {
    set y_total ""
    foreach y_len [get_db [get_db [get_db nets $net] .wires -if {.direction==vertical}] .length] { set y_total [expr $y_total + $y_len]} ; 
    return $y_total
}
proc getNetLength { name } {
     if { $name == 0x0 } { return "*" }
     set NetLength [expr [dbNetWireLenX $name ] + [dbNetWireLenY $name ]]
     return $NetLength
} 
proc ecoAddRepeaterChain { net maxdist cell } {
    enter_eco_mode
    puts "Batch Mode set to true"
    if {[get_db [get_db nets $net] .num_connections] == 2} {
        set len [getNetLength $net]
        puts "Net: $net Length: $len"
        while {$len > $maxdist} {
            puts "Remaining length: $len relative_distance_to_sink: [expr $maxdist/$len]"
            puts "eco_add_repeater -net $net -cells $cell -relative_distance_to_sink [expr $maxdist/$len]"
            set result [ eco_add_repeater -net $net -cells $cell -relative_distance_to_sink [expr $maxdist/$len] ]
            set newInstName [lindex $result 2]
            select_obj [get_db insts $newInstName]
            set len [getNetLength $net]
        }

        # Place last buffer nearby the driver
        if {$len > 10.0} {
            puts "Remaining length > 10: $len relative_distance_to_sink: [expr 1-(10.0/$len)]"
            puts "eco_add_repeater -net $net -cells $cell -relative_distance_to_sink [expr 1-(10.0/$len)]"
            set result [ eco_add_repeater -net $net -cells $cell -relative_distance_to_sink [expr 1-(10.0/$len)] ]
            set newInstName [lindex $result 2]
            select_obj [get_db insts $newInstName]
        }
        select_obj [get_db selected .pins.net.name]
    } else {
        puts "Warning: cannot create chain because net has more than one endpoint"
    }
    puts "Batch Mode set to false"
    enter_eco_mode true
}


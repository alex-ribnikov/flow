proc compare_pins { p1 p2 } { 

    if { [get_db $p1 .obj_type] == "port" } {  
        set layer1 [get_db $p1 .layer.route_index]
    } else { 
        set layer1 [get_db $p1 .base_pin.physical_pins.layer_shapes.layer.route_index]
    }
    
    if { [get_db $p2 .obj_type] == "port" } {  
        set layer2 [get_db $p2 .layer.route_index]
    } else { 
        set layer2 [get_db $p2 .base_pin.physical_pins.layer_shapes.layer.route_index]
    }  
    
    if { $layer1 != $layer2 } { return "layers_mismatch_p1_${layer1}_p2_${layer2}" } { set layer $layer1 }  
    if { [llength $layer] > 1 } { return "multiple_layers_p1_[join ${layer} "_"]" }
    if { [expr $layer%2] == 0 } { set dir "v" } { set dir "h" } 
    
    if { [get_db $p1 .obj_type] == "port" } {  
        set l1 [lindex [get_db $p1 .location] 0]
        lassign $l1 xl yl  
        set width [get_db $p1 .width]
        set depth [get_db $p1 .depth]      
        if { $dir == "h" } { set xh [expr $xl + $depth] ; set yh [expr $yl + $width] } { set xh [expr $xl + $width] ; set yh [expr $yl + $depth] }
        set b1 [list $xl $yl $xh $yh]
        set c1_loc {0 0}
    } else { 
        set c1_loc [lindex [get_db [get_cells -of $p1] .location] 0]
        set b1 [lindex [get_db $p1 .base_pin.physical_pins.layer_shapes.shapes.rect] 0]
        set l1 [list [expr ([lindex $b1 0] + [lindex $b1 2])/2.0]  [expr ([lindex $b1 1] + [lindex $b1 3])/2.0] ]
    }
    
    if { [get_db $p2 .obj_type] == "port" } {  
        set l2 [lindex [get_db $p2 .location] 0]
        lassign $l2 xl yl  
        set width [get_db $p2 .width]
        set depth [get_db $p2 .depth]      
        if { $dir == "h" } { set xh [expr $xl + $depth] ; set yh [expr $yl + $width] } { set xh [expr $xl + $width] ; set yh [expr $yl + $depth] }
        set b2 [list $xl $yl $xh $yh]
        set c2_loc {0 0}
    } else { 
        set c2_loc [lindex [get_db [get_cells -of $p2] .location] 0]
        set b2 [lindex [get_db $p2 .base_pin.physical_pins.layer_shapes.shapes.rect] 0]
        set l2 [list [expr ([lindex $b2 0] + [lindex $b2 2])/2.0]  [expr ([lindex $b2 1] + [lindex $b2 3])/2.0] ]
    }  
    
    if { [info exists c1_loc] && [info exists c2_loc] } {
        set xOffset [expr [lindex $c1_loc 0] - [lindex $c2_loc 0]]
        set yOffset [expr [lindex $c1_loc 1] - [lindex $c2_loc 1]]
    }
    
    if { $dir == "h" } {
        
        set y1 [format "%.4f" [lindex $l1 1]]
        set y2 [format "%.4f" [expr [lindex $l2 1] - $yOffset]]
        set w1 [format "%.4f" [expr [lindex $b1 3] - [lindex $b1 1]]]
        set w2 [format "%.4f" [expr [lindex $b2 3] - [lindex $b2 1]]] 
        
        if { $y1 != $y2 } { return "location_mismatch_dir_${dir}_p1_${y1}_p2_${y2}" }
        if { $w1 != $w2 } { return "width_mismatch_dir_${dir}_p1_${w1}_p2_${w2}"    }
        
    } elseif { $dir == "v" } {

        set x1 [format "%.4f" [lindex $l1 0]]
        set x2 [format "%.4f" [expr [lindex $l2 0] - $xOffset]]
        set w1 [format "%.4f" [expr [lindex $b1 2] - [lindex $b1 0]]]
        set w2 [format "%.4f" [expr [lindex $b2 2] - [lindex $b2 0]]]
        
        if { $x1 != $x2 } { return "location_mismatch_${dir}_p1_${x1}_p2_${x2}" }
        if { $w1 != $w2 } { return "width_mismatch_${dir}_p1_${w1}_p2_${w2}"    }
        
    } else {
        return "no_dir_determined"
    }
    
    return true            
}

proc pin_dist { p1 p2 } { 
    if { [catch {set p1_loc [lindex [get_db $p1 .location] 0]} res] } { puts "-E- Proc pin_dist failed:" ; puts $res ; return -1 }
    if { [catch {set p2_loc [lindex [get_db $p2 .location] 0]} res] } { puts "-E- Proc pin_dist failed:" ; puts $res ; return -1 }
    
    if { [catch {set dist [expr abs([lindex $p1_loc 0] - [lindex $p2_loc 0]) + abs([lindex $p1_loc 1] - [lindex $p2_loc 1])]} res] } { puts "-E- Proc pin_dist failed:" ; puts $res ; return -1 }
    
    return $dist
}

proc get_non_abuted_pins_nets { nets } {
    if { [catch {set nets [get_nets -quiet $nets]} res] } { puts "-E- Proc get_non_abutmed_pins failed with:" ; puts $res ; return -1 }
    if { [sizeof $nets] == 0 } { puts "-W- Found 0 nets" ; return -1 }
    
    set non_abuted_pins {}
    set curr 0
    set total [sizeof $nets]
    
    foreach_in_collection net $nets {
        ory_progress $curr $total
        incr curr

        if { ![llength [set drv [get_db $net .driver_pins]]] } { set drv [get_db $net .driver_ports] }
        if { ![llength [set rcv [get_db $net .load_pins  ]]] } { set rcv [get_db $net .load_ports] }

        if { [llength [concat $drv $rcv]] != 2 } { continue }
        
        set dist [pin_dist $drv $rcv]
        
        if { $dist < 0 } { puts "-W- [get_db $net .name] pins returned invalid distance" ; continue }
        if { $dist > 1 } { append_to_collection non_abuted_pins_nets $net }
    }
    puts ""
    puts "-I- Found [sizeof $non_abuted_pins_nets] non abuted pins nets"
    return $non_abuted_pins_nets
}

proc check_cell_pin_alignment { cell {ports_only false} {inter_only false} } {

    set cell [get_cells $cell]
    
    set pins [get_db [get_db $cell .pins] -if !.base_name=="*TEST*" ]
    set nets [get_nets [get_db $pins .net]]
    
    #### FILTER NETS ####
    set mult_conn_nets [get_db -uniq $nets -if .num_connections>2]
    if { [set N [llength [lsort -u $mult_conn_nets]]] > 0 } { 
        puts "-W- Found $N nets with more then 2 connections" 
        t [lsort -u $mult_conn_nets] driver_pins
    }    
    
    #### COMPARE PINS AND LOCATIONS TO CHECK ALIGNMENT ####
    set filtered_nets [remove_from_collection $nets [get_nets $mult_conn_nets]]
    
    set dir "reports/pin_alignment"
    exec mkdir -p $dir
    set file_name "$dir/alignment_report_[get_object_name $cell].rpt"
    set fp [open $file_name w]
    
    set layer_mis 0
    set location_mis 0
    set width_mis 0
    set not_connected 0
    
    foreach net [get_db $filtered_nets] {
#        puts $net
        if { [llength [set driver    [get_db $net .driver_pins]]] == 0 } {set driver    [get_db $net .driver_ports]}
        if { [llength [set receiver  [get_db $net .load_pins  ]]] == 0 } {set receiver  [get_db $net .load_ports  ]}

        if { $ports_only &&   [get_db $driver .obj_type] == "pin"  && [get_db $receiver .obj_type] == "pin"      } { continue }
        if { $inter_only && ( [get_db $driver .obj_type] == "port" || [get_db $receiver .obj_type] == "port" ) } { continue }
        
        if { [llength $driver] == 0 || [llength $receiver] == 0 } {  incr not_connected ; continue ; puts "-W- Net $net have no driver and/or receiver"}
        
        if { [set res [compare_pins $driver $receiver]] != true } {
            set line "[format "%-50s" $res] [format "%-10s" [get_db $driver .obj_type]] [format "%-100s" [get_db $driver .name]] [format "%-10s" [get_db $receiver .obj_type]] [get_db $receiver .name]"
            if { [regexp "layers_mismatch" $line  ] } { incr layer_mis }
            if { [regexp "location_mismatch" $line] } { incr location_mis }
            if { [regexp "width_mismatch" $line   ] } { incr width_mis }
            puts $fp $line
        }
    }
    close $fp
    
    puts "-I- Cell [get_db $cell .name] with [lindex [split [exec wc -l $file_name] " "] 0] violations. Layer: $layer_mis ; Location: $location_mis ; Width: $width_mis ; Connection: $not_connected"
            
}


proc check_all_quad_cells { {cells ""} {pattern "i_*_i_*"} {ports_only false} {inter_only false} } {
    set file reports/check_all_quad_cells_pin_alignment.rpt
    echo "-I- check_all_quad_cells violation summary:" > $file
    
    if { $cells == "" } {
        set cells [get_db [get_db insts $pattern] -if .is_macro==true||.is_black_box==true ]
    } else {
        set cells [get_db [get_cells $cells]]
    }
    
    if { $cells == "" } { puts "-E- No cells found for alignment check" ; return }
    
    foreach cell $cells {
        puts "-I_ Running on cell: $cell"
        if { [catch {redirect -app $file { check_cell_pin_alignment $cell $ports_only $inter_only }} res] } { puts "-W- Check failed" }
    }
    set sum [lsum [exec grep violations $file | awk {{print $5}}]]
    
    puts [exec grep violations $file]
    puts "-I- Total number of violations: $sum"
    
}


proc count_levels_from_source { pin } {
    
    set afi [all_fanin -to $pin -flat -only_cells]
    set inv [filter_collection $afi is_inverter==true]
    set buf [filter_collection $afi is_buffer==true] 
    
    return [expr 2*[sizeof $buf] + [sizeof $inv]]   
    
}

proc get_common_pin_map { b1 b2 file_name } {
    
    set b1_bc [get_db [get_cells $b1] .base_cell.name]
    set b2_bc [get_db [get_cells $b2] .base_cell.name]
    
    set b1_loc  [lindex [get_db [get_cells $b1  ] .location] 0]
    set b2_loc  [lindex [get_db [get_cells $b2  ] .location] 0]

    set b1_bbox [lindex [get_db [get_cells $b1] .bbox] 0]
    set b2_bbox [lindex [get_db [get_cells $b2] .bbox] 0]

    set offsetx [expr [get_db [get_cells $b1] .bbox.ll.x] - [get_db [get_cells $b2] .bbox.ll.x]]
    set offsety [expr [get_db [get_cells $b1] .bbox.ll.y] - [get_db [get_cells $b2] .bbox.ll.y]]    

    set b1_pins [get_db [get_db insts $b1] .pins]
    set b2_pins [get_db [get_db insts $b2] .pins]    

    set b1_nets [get_nets [get_db $b1_pins .net]]
    set b2_nets [get_nets [get_db $b2_pins .net]]
    set common_nets [get_db [common_collection $b1_nets $b2_nets] -if .num_connections==2]
    
    set fp [open $file_name w]
    
    foreach net $common_nets {
        
	    set pins   [all_connected -leaf $net]
        
        if { [sizeof $pins ] != 2 } { continue }
        
        set b1_pin [get_db $pins -if .name==*$b1/*]
        set b2_pin [get_db $pins -if .name==*$b2/*]      
        
        puts $fp "[get_db $b1_pin .base_name] [get_db $b2_pin .base_name]"
        
    }
    puts $fp "offsetx $offsetx"
    puts $fp "offsety $offsety"  

    close $fp    
}

proc check_net_route { net } { 
    set wires [get_db $net .wires]
    if { [llength $wires] > 1 } { return false } { return true }
}

proc filter_routed_p2p_nets { p2p_nets } {
    
    if { [is_attribute -obj net be_net_length] } {
        set_db [get_db $p2p_nets ] .be_net_length 0
        set_db [get_db $p2p_nets ] .be_detailed_net_length {}
    }
    
    ory_calc_net_length [get_db $p2p_nets]
    
    set routed [get_db $p2p_nets -if .be_net_length>0.2]
    
    set straight {}
    foreach net $routed {
        if {[check_net_route $net]} {lappend straight $net}
    }
    
    return $straight

}


proc convert_lef_to_arr { lef_file } {
    
    set fp [open $lef_file r]
    set fd [read $fp]
    close $fp
    
    set design ""
    set data   ""
    set is_record false
    set is_pin false
    set pin_name ""
    array unset lef_arr
    
    foreach line [split $fd "\n"] {

        if { $line == "" || [regexp "VDD" $line] || [regexp "VSS" $line] } { continue }
        if { $line == "" } { continue }
        if { !$is_record } {
            if { [regexp " Generated on" $line] } { set date   [join [lrange [split [string trim [regsub -all " +" $line " "] " "] " "] 3 end] " "] }
            if { [regexp " Design" $line]       } { set design [join [lrange [split [string trim [regsub -all " +" $line " "] " "] " "] 2 2] " "] }
            if { [regexp "MACRO $design" $line] } { set is_record true }
            continue
        } 
#        puts "$line 1: $is_pin $pin_name"
        if { !$is_pin } {
            if { [regexp "PIN " $line] } { set is_pin true; set pin_name [join [lrange [split [string trim [regsub -all " +" $line " "] " "] " "] 1 1] " "] }
            continue
        }
#        puts "$line 2: $is_pin $pin_name"
        if { $is_pin && [regexp "END [string map {"\[" "\\\[" "\]" "\\\]"} $pin_name]" $line] } { set is_pin false ; continue}
#        puts "$line 3: $is_pin $pin_name"
        if { [regexp "LAYER +(\[A-Z0-9\]+) "      $line res layer] } { set lef_arr($design:$pin_name:layer) $layer }
        if { [regexp "RECT +(\[0-9\\\.\\\- \]+) " $line res rect]  } { set lef_arr($design:$pin_name:rect)  [string trim [regsub -all "\\. \|\\.$" [regsub -all "0+$" [regsub -all "0+ " $rect " "] ""] ".0 "] " "]  }        
    }
    
    set lef_arr($design:date) $date
    
    return [array get lef_arr]
    
}



proc convert_def_pins_to_arr { def_file } {
    
    set fp [open $def_file r]
    set fd [read $fp]
    close $fp
    
    set units   0
    set design ""
    set data   ""
    set is_record false
    set is_pin false
    set pin_name ""
    array unset def_arr
    
    foreach line [split $fd "\n"] {
        
        if { $line == "" || [regexp "USE GROUND" $line] || [regexp "USE POWER" $line] } { continue }
        if { [regexp "END PINS" $line] } { break }
        if { !$is_record } {
            if { [regexp "UNITS DISTANCE MICRONS" $line] } { set units  [join [lrange [split [string trim [regsub -all " +" $line " "] " "] " "] 3 3] " "] }
            if { [regexp " Generated on"          $line] } { set date   [join [lrange [split [string trim [regsub -all " +" $line " "] " "] " "] 3 end] " "] }
            if { [regexp " Design"                $line] } { set design [join [lrange [split [string trim [regsub -all " +" $line " "] " "] " "] 2 2] " "] }
            if { [regexp "PINS "                  $line] } { set is_record true }
            continue
        } 
#        puts "$line 1: $is_pin $pin_name"
        if { !$is_pin } {
            if { [regexp "\\\- (\[a-zA-Z_0-9\\\[\\\]\]+) +\\\+" $line res pin_name] } { set is_pin true }
            continue
        }
#        puts "$line 2: $is_pin $pin_name"
#        if { $is_pin && [regexp "END [string map {"\[" "\\\[" "\]" "\\\]"} $pin_name]" $line] } { set is_pin false ; continue}
#        puts "$line 3: $is_pin $pin_name"
        if { [regexp "LAYER +(\[A-Z0-9\]+) (\[0-9\\\-\(\) \]+)" $line res layer m_rect] } {             
            set def_arr($design:$pin_name:layer) $layer
        }
        if { [regexp "PLACED +\\\( (\[0-9\\\.\\\- \]+) \\\) +(\[A-Z\])" $line res loc swen] || [regexp "FIXED +\\\( (\[0-9\\\.\\\- \]+) \\\) +(\[A-Z\])" $line res loc swen] } { 
            
            set m_rect [string trim [regsub -all " +" [string map {"(" "" ")" ""} $m_rect] " "] " "]
            
            if { $swen == "N" } {
            set xl [expr 1.0*([lindex $loc 0] + [lindex $m_rect 0])/$units]
            set xh [expr 1.0*([lindex $loc 0] + [lindex $m_rect 2])/$units]
            set yl [expr 1.0*([lindex $loc 1] + [lindex $m_rect 1])/$units]
            set yh [expr 1.0*([lindex $loc 1] + [lindex $m_rect 3])/$units]
            } elseif { $swen == "S" } { 
            set xl [expr 1.0*([lindex $loc 0] + [lindex $m_rect 0])/$units]
            set xh [expr 1.0*([lindex $loc 0] + [lindex $m_rect 2])/$units]
            set yl [expr 1.0*([lindex $loc 1] - [lindex $m_rect 3])/$units]
            set yh [expr 1.0*([lindex $loc 1] - [lindex $m_rect 1])/$units]            
            } elseif { $swen == "E" } {
            set xl [expr 1.0*([lindex $loc 0] + [lindex $m_rect 1])/$units]
            set xh [expr 1.0*([lindex $loc 0] + [lindex $m_rect 3])/$units]
            set yl [expr 1.0*([lindex $loc 1] - [lindex $m_rect 2])/$units]
            set yh [expr 1.0*([lindex $loc 1] - [lindex $m_rect 0])/$units]            
            } else {
            set xl [expr 1.0*([lindex $loc 0] - [lindex $m_rect 3])/$units]
            set xh [expr 1.0*([lindex $loc 0] - [lindex $m_rect 1])/$units]
            set yl [expr 1.0*([lindex $loc 1] + [lindex $m_rect 0])/$units]
            set yh [expr 1.0*([lindex $loc 1] + [lindex $m_rect 2])/$units]            
            }

            set def_arr($design:$pin_name:rect) [list $xl $yl $xh $yh] 

            set m_rect {}
            set is_pin false
            continue 
        }
    }
    
    set def_arr($design:date) $date
    return [array get def_arr]
    
}

proc verify_lef_def { lef_file def_file } {
    
    array unset lef_arr
    array unset def_arr

    array set lef_arr [convert_lef_to_arr $lef_file]
    array set def_arr [convert_def_pins_to_arr $def_file]

    array unset res_arr    
    foreach key [array names lef_arr] {
    
        if { [info exists def_arr($key)] } {
            if { $def_arr($key) != $lef_arr($key) } { set res_arr($key) "$def_arr($key) NE $lef_arr($key)"}
        } else {
            set res_arr(lefNOdef:$key) $lef_arr($key)
        }    
    }    
    
    foreach key [array names def_arr] {
    
        if { [info exists lef_arr($key)] } {
        } else {
            set res_arr(defNOlef:$key) $def_arr($key)
        }    
    }  
    
    parray res_arr  
}

proc compare_lefs { lef1 lef2 } {
    
    array unset lef1_arr
    array unset lef2_arr

    array set lef1_arr [convert_lef_to_arr $lef1]
    array set lef2_arr [convert_lef_to_arr $lef2]

    array unset res_arr    
    foreach key [array names lef1_arr] {
    
        if { [info exists lef2_arr($key)] } {
            if { $lef2_arr($key) != $lef1_arr($key) } { set res_arr($key) "(lef1) $lef1_arr($key) NE (lef2) $lef2_arr($key)"}
        } else {
            set res_arr(lef1NOlef2:$key) $lef1_arr($key)
        }    
    }    
    
    foreach key [array names lef2_arr] {
    
        if { [info exists lef1_arr($key)] } {
        } else {
            set res_arr(lef2NOlef1:$key) $lef2_arr($key)
        }    
    }  
    
    if { [info exists res_arr] } {    
        parray res_arr
    } {
        puts "-I- No Diffs"
    }
}

proc verify_old_vs_new_lefs { old_lef_dir new_lef_dir } {

    if { ![file exists $old_lef_dir] } { puts "-E- Directory $old_lef_dir not exists" ; return }
    if { ![file exists $new_lef_dir] } { puts "-E- Directory $new_lef_dir not exists" ; return }
    
    echo "-I- Comparing $old_lef_dir with $new_lef_dir [ory_time::now]" > reports/verify_old_vs_new_lefs.rpt
    
    foreach old_lef_file [glob $old_lef_dir/*lef] {        
        set base_name   [lindex [split $old_lef_file "/"] end]
        if { ![regexp "(\[a-zA-Z\\\._0-9\]+)\\\.lef" $base_name res block_name]  } { puts "-W- Could not extract block name for $old_lef_file" ; continue }
        
        set block_name [lindex [split $block_name "."] 0]
        
        if { [set new_lef_file [glob -nocomplain $new_lef_dir/${block_name}*.lef]] == "" } { puts "-W- No Def file found for $base_name" ; continue }
        puts "-I- Comparing $old_lef_file with $new_lef_file [ory_time::now]"
        redirect -app reports/verify_old_vs_new_lefs.rpt { compare_lefs $old_lef_file $new_lef_file }
    }

}


proc verify_all_lef_def { lef_dir def_dir } {
    
    if { ![file exists $lef_dir] } { puts "-E- Directory $lef_dir not exists" ; return }
    if { ![file exists $def_dir] } { puts "-E- Directory $def_dir not exists" ; return }
    
    foreach lef_file [glob $lef_dir/*lef] {        
        set base_name   [lindex [split $lef_file "/"] end]
        if { ![regexp "(\[a-zA-Z\\\._0-9\]+)\\\.lef" $base_name res block_name]  } { puts "-W- Could not extract block name for $lef_file" ; continue }
        
        set block_name [lindex [split $block_name "."] 0]
        
        if { [set def_file [glob -nocomplain $def_dir/${block_name}*.def*]] == "" } { puts "-W- No Def file found for $base_name" ; continue }
        puts "-I- Comparing $lef_file VS $def_file"
        puts "-I- Unzip def file"
        if { [regexp "\\\.gz" $def_file res] } { 
            exec less $def_file > ${def_file}_tmp_
            set def_file ${def_file}_tmp_
            puts "-I- Verifying lef vs def"
            verify_lef_def $lef_file $def_file
            rm ${def_file}
        } else {
            puts "-I- Verifying lef vs def"
            verify_lef_def $lef_file $def_file
        }        
    }
    
}




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

proc quick_place_pins { hinst pins line dir layers } {

    lassign $line xl yl xh yh
    set distx [expr $xh - $xl]
    set disty [expr $yh - $yl]
    if { $dir == "v" || $dir == "V" } { 
        set dist  $distx 
        set const $yl
        set start $xl
    } elseif { $dir == "h" || $dir == "H" } {
        set dist  $disty
        set const $xl
        set start $yl
    } else {
        puts "-E- dir must be v OR h"
        exit
    }
    
    set pins       [get_db $pins .base_name]
    set size       [llength $pins]
    set delta      [expr 1.0*$dist/$size]
    set layersNum  [llength $layers] 
    
    set cmd ""
    for { set i 0 } { $i < $size } {incr i} {
        set p      [lindex $pins $i]
        set layer  [lindex $layers [expr $i%$layersNum]]
        set newP   [expr $start + $i*$delta]
        if { $dir == "v" || $dir == "V" } { set new_loc [list $newP $const] } { set new_loc [list $const $newP] }
        if { $hinst != "" } {
            set new_line "edit_pin -hinst $hinst -snap track -fix_overlap  1  -pin $p -layer $layer -assign  \"$new_loc\""
        } else {
            set new_line "edit_pin -snap track -fix_overlap  1  -pin $p -layer $layer -assign  \"$new_loc\""
        }
        append cmd "$new_line\n"
    }
    
    set_db assign_pins_edit_in_batch true
    eval $cmd
    set_db assign_pins_edit_in_batch false    
    
}

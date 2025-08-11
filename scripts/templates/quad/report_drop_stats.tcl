#!/bin/tclsh

proc _parse_args_ { args } {
    upvar opt opt
    set args [regsub -all "\{\|\}\|\\\\" $args ""]
    set split_args [split $args "-"]
    
    foreach arg $split_args {
        if { $arg == "" || $arg == "{" || $arg == "}" } { continue }
        set opt([lindex $arg 0]) [lrange $arg 1 end]
    }
}

proc report_drop_stats { drop_dir } {
    
    if { ![file exists $drop_dir]} { puts "-E- No drop dir found: $drop_dir" ; return -1 }
    
    set sub_dirs_list [list "lef" \
                            "def" \
                            "spef" \
                            "gpd" \
                            "oas" \
                            "netlist" \
                            "lib" \
                            "sdc"]
                            
    set block_list [list "cbue_top" \
                         "cbui_top" \
                         "tcu_top" \
                         "grid_quad_east_filler_row_0_top" \
                         "grid_quad_east_filler_row_notch_top" \
                         "grid_quad_east_filler_row_7_top" \
                         "grid_quad_east_filler_row_top" \
                         "grid_quad_north_filler_col_top" \
                         "grid_quad_south_filler_col_0_top" \
                         "grid_quad_south_filler_col_top" \
                         "grid_quad_south_filler_east_col_top" \
                         "grid_quad_west_filler_ecore_row_top" \
                         "grid_quad_west_filler_row_top" \
                         "nfi_mcu_top" \
                         "grid_quadrant"]
                         
    array unset res_arr
    
    foreach block $block_list {        
        foreach sub_dir $sub_dirs_list {
            set dir "$drop_dir/$sub_dir"
            if { ![file exists $dir] } { puts "-W- No dir $dir found" ; continue}
            set res_arr($block:$sub_dir) [glob -nocomplain $dir/$block*]
        }        
    }
    
    set table {}
    set header [list [format "%-50s" "Block_name"] [format "%-15s" "LEF"] [format "%-15s" "DEF"] [format "%-15s" "SPEF"]  [format "%-15s" "GPD"] [format "%-15s" "OAS"]\
    [format "%-15s" "NETLIST"] [format "%-15s" "LIB"] [format "%-15s" "SDC"]]
    lappend table $header
    foreach block $block_list {
        set line [list [format "%-50s" $block]]
        foreach sub_dir $sub_dirs_list {
            if { $res_arr($block:$sub_dir) == "" } { set count 0 } { set count [llength $res_arr($block:$sub_dir)] }
            lappend line [format "%-15s" $count]
        }
        lappend table $line
    }
    
    foreach line $table {
        puts [join $line " "]
    }
        
#    parray res_arr

}
report_drop_stats [split $argv " "]
#parse_blocks_csv [split $argv " "]


#
#proc report_drop_stats { drop_dir } {
#    
#    if { ![file exists $drop_dir]} { puts "-E- No drop dir found: $drop_dir" ; return -1 }
#    
#    set sub_dirs_list [list "lefs" \
#                            "defs" \
#                            "spefs" \
#                            "netlists" \
#                            "libs" \
#                            "sdc"]
#                            
#    set block_list [list "cbue_top" \
#                         "cbui_top" \
#                         "tcu_top" \
#                         "grid_quad_east_filler_row_0_top" \
#                         "grid_quad_east_filler_row_notch_top" \
#                         "grid_quad_east_filler_row_7_top" \
#                         "grid_quad_east_filler_row_top" \
#                         "grid_quad_north_filler_col_top" \
#                         "grid_quad_south_filler_col_0_top" \
#                         "grid_quad_south_filler_col_top" \
#                         "grid_quad_south_filler_east_col_top" \
#                         "grid_quad_west_filler_ecore_row_top" \
#                         "grid_quad_west_filler_row_top" \
#                         "nfi_mcu_top" \
#                         "grid_quadrant"]
#                         
#    array unset res_arr
#    
#    foreach block $block_list {        
#        foreach sub_dir $sub_dirs_list {
#            set dir "$drop_dir/$sub_dir"
#            if { ![file exists $dir] } { puts "-W- No dir $dir found" ; continue}
#            set res_arr($block:$sub_dir) [glob -nocomplain $dir/$block*]
#        }        
#    }
#    
#    set table {}
#    set header [list [format "%-50s" "Block_name"] [format "%-15s" "LEF"] [format "%-15s" "DEF"] [format "%-15s" "SPEF"] [format "%-15s" "NETLIST"] [format "%-15s" "LIB"] [format "%-15s" "SDC"]]
#    lappend table $header
#    foreach block $block_list {
#        set line [list [format "%-50s" $block]]
#        foreach sub_dir $sub_dirs_list {
#            if { $res_arr($block:$sub_dir) == "" } { set count 0 } { set count [llength $res_arr($block:$sub_dir)] }
#            lappend line [format "%-15s" $count]
#        }
#        lappend table $line
#    }
#    
#    foreach line $table {
#        puts [join $line " "]
#    }
#        
##    parray res_arr
#
#}
#report_drop_stats [split $argv " "]

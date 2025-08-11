set cell grid_quad_east_filler_row_notch_top
set myx  162.792 
set myy  1108.80
set bc [get_db base_cells $cell]
set lc [get_db $bc .lib_cells]
if { [get_db $bc .lef_file_name] != "" } {
    set x [expr [get_db $bc .bbox.ur.x] - [get_db $bc .bbox.ll.x]]
    set y [expr [get_db $bc .bbox.ur.y] - [get_db $bc .bbox.ll.y]]
    puts "-I- Cell: $cell. Using lef x and y: $x $y VS $myx $myy"
#    if { $x != $myx || $y != $myy } { exit }
    
} else {
    puts "-I- Cell: $cell. Using my x and y: $myx $myy"
    set x $myx 
    set y $myy
}
if { $lc == "" } { puts "-I- Cell: Creating BBOX"
create_blackbox -cell $cell -size $x $y -core_spacing 0 0 0 0 \
    -min_pitch_left 2 -min_pitch_right 2 -min_pitch_top 2 -min_pitch_bottom 2 \
    -reserved_layer {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16} -pin_layer_top {4 6 8 10 12 14 16} -pin_layer_bottom {4 6 8 10 12 14 16} \
    -pin_layer_left {5 7 9 11 13 15} -pin_layer_right {5 7 9 11 13 15}
}

set cell grid_quad_east_filler_row_7_top
set myx  162.792 
set myy  1098.72
set bc [get_db base_cells $cell]
set lc [get_db $bc .lib_cells]
if { [get_db $bc .lef_file_name] != "" } {
    set x [expr [get_db $bc .bbox.ur.x] - [get_db $bc .bbox.ll.x]]
    set y [expr [get_db $bc .bbox.ur.y] - [get_db $bc .bbox.ll.y]]
    puts "-I- Cell: $cell. Using lef x and y: $x $y VS $myx $myy"
##    if { $x != $myx || $y != $myy } { exit }
} else {
    puts "-I- Cell: $cell. Using my x and y: $myx $myy"
    set x $myx 
    set y $myy
}
if { $lc == "" } { puts "-I- Cell: Creating BBOX"
create_blackbox -cell $cell -size $x $y -core_spacing 0 0 0 0 \
    -min_pitch_left 2 -min_pitch_right 2 -min_pitch_top 2 -min_pitch_bottom 2 \
    -reserved_layer {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16} -pin_layer_top {4 6 8 10 12 14 16} -pin_layer_bottom {4 6 8 10 12 14 16} \
    -pin_layer_left {5 7 9 11 13 15} -pin_layer_right {5 7 9 11 13 15}
}

set cell grid_quad_east_filler_row_0_top
set myx  162.792 
set myy  937.44
set bc [get_db base_cells $cell]
set lc [get_db $bc .lib_cells]
if { [get_db $bc .lef_file_name] != "" } {
    set x [expr [get_db $bc .bbox.ur.x] - [get_db $bc .bbox.ll.x]]
    set y [expr [get_db $bc .bbox.ur.y] - [get_db $bc .bbox.ll.y]]
    puts "-I- Cell: $cell. Using lef x and y: $x $y VS $myx $myy"
#    if { $x != $myx || $y != $myy } { exit }
    
} else {
    puts "-I- Cell: $cell. Using my x and y: $myx $myy"
    set x $myx 
    set y $myy
}    
if { $lc == "" } { puts "-I- Cell: Creating BBOX"
create_blackbox -cell $cell -size $x $y -core_spacing 0 0 0 0 \
    -min_pitch_left 2 -min_pitch_right 2 -min_pitch_top 2 -min_pitch_bottom 2 \
    -reserved_layer {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16} -pin_layer_top {4 6 8 10 12 14 16} -pin_layer_bottom {4 6 8 10 12 14 16} \
    -pin_layer_left {5 7 9 11 13 15} -pin_layer_right {5 7 9 11 13 15}
}
#  
#set cell grid_quad_west_filler_ecore_row_top
#set myx  813.96 
#set myy  1128.96
#set bc [get_db base_cells $cell]
#set lc [get_db $bc .lib_cells]
#if { [get_db $bc .lef_file_name] != "" } {
#    set x [expr [get_db $bc .bbox.ur.x] - [get_db $bc .bbox.ll.x]]
#    set y [expr [get_db $bc .bbox.ur.y] - [get_db $bc .bbox.ll.y]]
#    puts "-I- Cell: $cell. Using lef x and y: $x $y VS $myx $myy"
##    if { $x != $myx || $y != $myy } { exit }
#    
#} else {
#    puts "-I- Cell: $cell. Using my x and y: $myx $myy"
#    set x $myx 
#    set y $myy
#}    
#if { $lc == "" } { puts "-I- Cell: Creating BBOX"
#create_blackbox -cell $cell -size $x $y -core_spacing 0 0 0 0 \
#    -min_pitch_left 2 -min_pitch_right 2 -min_pitch_top 2 -min_pitch_bottom 2 \
#    -reserved_layer {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16} -pin_layer_top {4 6 8 10 12 14 16} -pin_layer_bottom {4 6 8 10 12 14 16} \
#    -pin_layer_left {5 7 9 11 13 15} -pin_layer_right {5 7 9 11 13 15}
#}
    
set cell grid_quad_south_filler_col_0_top
set myx  542.64
set myy  141.12
set bc [get_db base_cells $cell]
set lc [get_db $bc .lib_cells]
if { [get_db $bc .lef_file_name] != "" } {
    set x [expr [get_db $bc .bbox.ur.x] - [get_db $bc .bbox.ll.x]]
    set y [expr [get_db $bc .bbox.ur.y] - [get_db $bc .bbox.ll.y]]
    puts "-I- Cell: $cell. Using lef x and y: $x $y VS $myx $myy"
#    if { $x != $myx || $y != $myy } { exit }
    
} else {
    puts "-I- Cell: $cell. Using my x and y: $myx $myy"
    set x $myx 
    set y $myy
}    
if { $lc == "" } { puts "-I- Cell: Creating BBOX"
create_blackbox -cell $cell -size $x $y -core_spacing 0 0 0 0 \
    -min_pitch_left 2 -min_pitch_right 2 -min_pitch_top 2 -min_pitch_bottom 2 \
    -reserved_layer {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16} -pin_layer_top {4 6 8 10 12 14 16} -pin_layer_bottom {4 6 8 10 12 14 16} \
    -pin_layer_left {5 7 9 11 13 15} -pin_layer_right {5 7 9 11 13 15}
}

set cell grid_quad_south_filler_east_col_top
set myx  108.528
set myy  151.20
set bc [get_db base_cells $cell]
set lc [get_db $bc .lib_cells]
if { [get_db $bc .lef_file_name] != "" } {
    set x [expr [get_db $bc .bbox.ur.x] - [get_db $bc .bbox.ll.x]]
    set y [expr [get_db $bc .bbox.ur.y] - [get_db $bc .bbox.ll.y]]
    puts "-I- Cell: $cell. Using lef x and y: $x $y VS $myx $myy"
#    if { $x != $myx || $y != $myy } { exit }
    
} else {
    puts "-I- Cell: $cell. Using my x and y: $myx $myy"
    set x $myx 
    set y $myy
}    
if { $lc == "" } { puts "-I- Cell: Creating BBOX"
create_blackbox -cell $cell -size $x $y -core_spacing 0 0 0 0 \
    -min_pitch_left 2 -min_pitch_right 2 -min_pitch_top 2 -min_pitch_bottom 2 \
    -reserved_layer {1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16} -pin_layer_top {4 6 8 10 12 14 16} -pin_layer_bottom {4 6 8 10 12 14 16} \
    -pin_layer_left {5 7 9 11 13 15} -pin_layer_right {5 7 9 11 13 15}    
}    

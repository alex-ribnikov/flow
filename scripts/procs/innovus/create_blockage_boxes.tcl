proc create_blockage_boxes { {blockages_offset 6} {blockage_dx 3} {blockage_dy 3} {blockage_name "IOBUFS_BLOCKAGE"} {chessboard 1} {endcap_len 1.3} {chessboard_lines 1} } {	
	set blockage_list ""
	set design_edges [lsort -u [get_db [get_db ports ] .pin_edge ]]	
    set design_bounderies [get_db designs .boundary]
    set x_bounds ""
    set y_bounds ""
    foreach b [lindex $design_bounderies 0] {
    	lappend x_bounds [lindex $b 0 ]
        lappend y_bounds [lindex $b 1 ]
    }
    set x_bounds [lsort -u -dictionary $x_bounds]
    set y_bounds [lsort -u -dictionary $y_bounds]
    if {[lindex $design_edges 0] == -1 } {set design_edges [lrange $design_edges 1 end]}
    foreach edge $design_edges {
    	if {[expr $edge %2] == 0 } {
        	set x_coor [lsort -u [get_db [get_db ports -if .pin_edge==$edge ] .location.x]]
            set side [lsort -u [get_db [get_db ports -if .pin_edge==$edge ] .side]]
            if {$side == "west" } {
            	set left_edge 1
            } else {set left_edge 0}
            set y_bot_cor [lindex [lsort -u -dictionary [get_db [get_db ports -if .pin_edge==$edge ] .location.y] ] 0]
            set y_top_cor [lindex [lsort -u -dictionary [get_db [get_db ports -if .pin_edge==$edge ] .location.y] ] end]
            set y_cor $y_bot_cor
            while {$y_cor <= $y_top_cor} {
            	if {$left_edge == 1} {
            	set y0 $y_cor; set y1 [expr $y_cor + $blockage_dy] ; set x0 [expr $x_coor + $endcap_len] ; set x1  [expr $x0 + $blockage_dx];
                if {$chessboard} {set y00  $y1 ; set y11 [expr $y00 + $blockage_dy ] ; set x00 $x1 ; set x11  [expr $x00 + $blockage_dx];}
                } else {set y0 $y_cor; set y1 [expr $y_cor + $blockage_dy] ; set x0 [expr $x_coor - $endcap_len] ; set x1  [expr $x0 - $blockage_dx];
                 if {$chessboard} {set y00  $y1 ; set y11 [expr $y00 + $blockage_dy ] ; set x00 $x1 ; set x11  [expr $x00 - $blockage_dx];}	
                }
            	set rect [list $x0 $y0 $x1 $y1]
            	append blockage_list "\{$rect\} "               
                set rect_chess [list $x00 $y00 $x11 $y11]
            	append blockage_list "\{$rect_chess\} "
                set y_cor [expr $y_cor + $blockages_offset]
            }
        } else {
           	set y_coor [lsort -u [get_db [get_db ports -if .pin_edge==$edge ] .location.y]]
            set side [lsort -u [get_db [get_db ports -if .pin_edge==$edge ] .side]]
            if {$side == "south" } {
            	set south_edge 1
            } else {set south_edge 0}
            set x_bot_cor [lindex [lsort -u -dictionary  [get_db [get_db ports -if .pin_edge==$edge ] .location.x] ] 0]
            set x_top_cor [lindex [lsort -u -dictionary [get_db [get_db ports -if .pin_edge==$edge ] .location.x] ] end]
            set x_cor $x_bot_cor
            while {$x_cor <= $x_top_cor} {
            	if {$south_edge == 1} {
            	set y0 $y_coor; set y1 [expr $y_coor + $blockage_dy] ; set x0 $x_cor ; set x1  [expr $x_cor + $blockage_dx];
                if {$chessboard} {set y00  $y1 ; set y11 [expr $y00 + $blockage_dy ] ; set x00 $x1 ; set x11  [expr $x00 + $blockage_dx];}
                } else {set y0 $y_coor; set y1 [expr $y_coor - $blockage_dy] ; set x0 $x_cor ; set x1  [expr $x_cor + $blockage_dx];
                	if {$chessboard} {set y00  $y1 ; set y11 [expr $y00 - $blockage_dy ] ; set x00 $x1 ; set x11  [expr $x00 + $blockage_dx];}
                }
            	set rect [list $x0 $y0 $x1 $y1]
            	append blockage_list "\{$rect\} "
                set rect_chess [list $x00 $y00 $x11 $y11]
            	append blockage_list "\{$rect_chess\} "
                set x_cor [expr $x_cor + $blockages_offset]
        }
        }
    }
	create_place_blockage -rects $blockage_list -name $blockage_name   
}
###################################
proc create_io_blockages { args } {	

    set PROC [lindex [info level 0] 0]

# // PARSE ARGS 
  # INFO
    set proc_info "
$PROC creates an array of checkerboard placement blockages.
The user can select dx , dy , and number of checkerboard lines.
"
  # ARG DATA
         # opt_name         must  type      default            info
    set my_args {
        { blockage_dx        0   integer   3                   "the X size of each blockage" }
        { blockage_dy        0   integer   3                   "the Y size of each blockage" }
        { blockage_name      0   string    IOBUFS_BLOCKAGE     "placement_blockage name" }
        { no_checkerboard    0   boolean   0                   "DISABLED // checkerboard is on by default. use this flag to disable // DISABLED" }
        { blockage_lines     0   integer   6                   "number of checkerboard lines along each edge" }
        { endcap_dx          0   string    1.352               "distance of blockages from the horizontal edges" }
        { endcap_dy          0   string    0.21                "distance of blockages from the vertical edges" }
        { edges              0   string    all                 "a list of edges to add IOBUFFERS on. 0 is west, 1 is north, ..." }
    }
    if { [be_parse_args $proc_info $my_args $args] != "0" } { return }
# //

  # init settings
    #set checkerboard          [expr {$no_checkerboard ? "0" : "1"}]
    set checkerboard 1 ;# CURRENTLY ONLY SUPPORTING checkerboard
    set blockage_list       ""
    set design_edges        [lsort -u [get_db [get_db ports ] .pin_edge ]]	
    set design_bounderies   [get_db designs .boundary]
    set x_bounds            ""
    set y_bounds            ""
    
    foreach b [lindex $design_bounderies 0] {
        lappend x_bounds [lindex $b 0 ]
        lappend y_bounds [lindex $b 1 ]
    }
    set x_bounds [lsort -u -dictionary $x_bounds]
    set y_bounds [lsort -u -dictionary $y_bounds]
    if {[lindex $design_edges 0] == -1 } {set design_edges [lrange $design_edges 1 end]}

    foreach edge $design_edges {
      # skip if not on allowed edges  
        if { ($edges != "all") && ([lsearch $edges $edge] < 0) } { continue }
      #   
        if { [expr $edge % 2] == 0 } {
            set dir_const "x"
            set dir_var   "y"
            lassign "$blockage_dx $blockage_dy" blk_const blk_var
            set endcap_len $endcap_dx
        } else {
            set dir_const "y"
            set dir_var   "x"            
            lassign "$blockage_dy $blockage_dx" blk_const blk_var            
            set endcap_len $endcap_dy
        }
        
        set edge_ports  [get_db ports -if .pin_edge==$edge]                                 ; list
        set const_coor  [lsort -u [get_db $edge_ports .location.${dir_const}]]
        set var_list    [lsort -u -dictionary [get_db $edge_ports .location.${dir_var}] ]   ; list
        set side        [lsort -u [get_db $edge_ports .side]]
        set is_ll       [regexp "south|west" $side]
        set var_bot     [lindex $var_list 0]
        set var_top     [lindex $var_list end]

        set fill 1
        set var_cur $var_bot
        
        while { $var_cur <= $var_top } {
        
            set mult [expr $is_ll ? "1" : "-1"]     ;# to advance away from the edges
          # setting rect based on edge
            set var_0 [expr $var_cur]
            set var_1 [expr $var_0   + $blk_var]

            set line_fill $fill
            for { set i 0 } { $i < $blockage_lines } { incr i } {
                set const_0 [expr $const_coor + ${mult}*$endcap_len + $i*$blk_const]
                set const_1 [expr $const_0    + ${mult}*$blk_const]
              # add blockages checkerboard pattern
                if { $line_fill } {
                    if { [expr $edge % 2] == 0 } {
                        append blockage_list "\{$const_0 $var_0 $const_1 $var_1\} "
                    } else {
                        append blockage_list "\{$var_0 $const_0 $var_1 $const_1\} "                    
                    }
                }
                set line_fill [expr 1 - $line_fill]
            }
          # advance to next row
            set var_cur [expr $var_cur + $blk_var]
            set fill [expr 1 - $fill]   ;# checkerboard pattern
        }

        create_place_blockage -rects $blockage_list -name $blockage_name  
    }
}




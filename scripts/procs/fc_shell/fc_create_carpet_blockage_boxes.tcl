proc create_blockage_boxes {} {

	global IOBUFFER_CELL
	set blk_name "IOBUFS_BLOCKAGE"
	if {[sizeof [get_cells *IOBuf*]]} {remove_buffer [get_cells *IOBuf*]}
	if {[sizeof [get_placement_blockages *$blk_name*]]} {remove_placement_blockages [get_placement_blockages *$blk_name*]}

	#calculating blockage size, depends on buffer cell
	set site_dx [lindex [lsort -u [get_attribute [get_site_defs ] width ]] 0]
	set site_dy [lindex [lsort -u [get_attribute [get_site_defs ] height ]] 0]
	set my_padding "2 0 2 0"

	set blk_dx [lindex [lsort -u -real [get_attribute [get_lib_cells $IOBUFFER_CELL] width]] end]
	set blk_dy [lsort -u -real [get_attribute [get_lib_cells $IOBUFFER_CELL] height]]
	set blk_dx [expr $blk_dx + ([lindex $my_padding 0] + [lindex $my_padding 2])*$site_dx]

	create_carpet_blockage_boxes -blockage_name $blk_name -blockage_dx $blk_dx -blockage_dy $blk_dy

}

proc create_carpet_blockage_boxes { args } {	

    set PROC [lindex [info level 0] 0]

# // PARSE ARGS 
  # INFO
    set proc_info "
$PROC creates an array of checkerboard placement blockages.
The user can select dx , dy , and number of checkerboard lines.
"
# endcap_dx should be 0.4095 - 0.3840 inludes 0.0255 shifting between die/core boundaries
# endcap_dy should be  - 0.117 inludes 0.0845 shifting between die/core boundaries
  # ARG DATA
         # opt_name         must  type      default            info
    set my_args {
        { blockage_dx        0   integer   3                   "the X size of each blockage" }
        { blockage_dy        0   list      {}                  "the Y size of each blockage" }
        { blockage_name      0   string    IOBUFS_BLOCKAGE     "placement_blockage name" }
        { no_checkerboard    0   boolean   0                   "DISABLED // checkerboard is on by default. use this flag to disable // DISABLED" }
        { blockage_lines     0   integer   6                   "number of checkerboard lines along each edge" }
        { endcap_dx          0   string    0.4095              "distance of blockages from the horizontal edges" }
        { endcap_dy          0   string    0.2015                "distance of blockages from the vertical edges" }
        { edges              0   string    all                 "a list of edges to add IOBUFFERS on. 0 is west, 1 is north, ..." }
    }
    if { [be_parse_args $proc_info $my_args $args] != "0" } { return }
# //

  # init settings
    #set checkerboard          [expr {$no_checkerboard ? "0" : "1"}]
    set checkerboard 1 ;# CURRENTLY ONLY SUPPORTING checkerboard
    set blockage_list       "" 
    
    
    set blockage_dy_1 [lindex $blockage_dy 0]
    if {[llength $blockage_dy] == 1} {lappend blockage_dy $blockage_dy_1}

    lassign [join  [get_attribute [get_designs ] boundary_bounding_box.ur]] X_ur Y_ur
    set shifting [expr ![expr [scan "x" %c] - 120]*$endcap_dx + [expr [scan "x" %c] - 120]*0.395]
    set X_ll $shifting
    set X_ur [expr $X_ur - $shifting]
    set shifting [expr ![expr [scan "y" %c] - 120]*$endcap_dy + [expr [scan "y" %c] - 120]*0.395]
    set height [lindex $blockage_dy 0]
    if {$height==0.286} {set height 0.169}
    set cmd "index \[get_site_rows -filter \{site_height==$height\}\] 0"
    set first_site [eval $cmd]
    set Y_ll [get_attribute $first_site bounding_box.ll_y]
    
    set index 0
    set blockage_lines [expr ceil([expr $X_ur - $X_ll] / $blockage_dx)]
    set fill 1

    while { $Y_ll <= $Y_ur } {

	set const_coor $X_ll
        set var_0 $Y_ll
	set var_1 [expr $Y_ll + [lindex $blockage_dy $index]]

    	set line_fill $fill
        for { set i 0 } { $i < $blockage_lines } { incr i } {
                set const_0 [expr $const_coor + ($i*$blockage_dx) ] ; 
                set const_1 [expr $const_0 + $blockage_dx]; 
		if { $line_fill } {
                        append blockage_list "\{\{$const_0 $var_0\} \{$const_1 $var_1\}\} "
                }
                set line_fill [expr 1 - $line_fill]
        }

          # advance to next row
        set Y_ll [expr $Y_ll + [lindex $blockage_dy $index]]
        set fill [expr 1 - $fill]   ;# checkerboard pattern
        set index [expr !$index]

    }
        create_placement_blockage -boundary $blockage_list -name $blockage_name

}




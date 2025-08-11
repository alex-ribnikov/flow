#
#
#
if {[get_attribute [get_ports] pin_edge -quiet]!=""} {
undefine_derived_user_attribute -name pin_edge -classes port
}
proc lrrotate {bbox {times 1}} {
	set nbbox $bbox
	for {set i 0} {$i<$times} {incr i} {
		set nbbox [concat [list [lindex $nbbox end]] [lrange $nbbox 0 end-1]]
	}
	return $nbbox
}
define_derived_user_attribute \
          -name pin_edge \
          -classes {port} \
          -type int \
          -get_command {
	set i 1
	set const 0
	set bounding_box [get_attribute %object bounding_box]
	set boundary [get_attribute [get_blocks] outer_keepout_boundary] 
	set 0_n [lsearch  $boundary {0.0000 [1-9]*}]
	set 0_0 [lsearch  $boundary {0.0000 0.0000}]
	if {${0_n}<${0_0}} {
		set times [expr [llength $boundary] -${0_0} -1]
		set boundary [lreverse [lrrotate $boundary $times]]	
	}
	set edge -1
	foreach p $boundary { 
 	 if {[expr [lindex [get_attribute $bounding_box ll] $const]==[lindex $p $const]] || ([lindex [get_attribute $bounding_box ur] $const]==[lindex $p $const])} {set edge $i;break}
 	 set const [expr 1 - $const]
 	 incr i
	}
	return $edge

}
proc be_color_hiers { HIER_LIST {incremental 0} {color_list ""} } {

    global STAGE
    gui_set_highlight_options -auto_cycle_color 1
    gui_set_highlight_options -current_color yellow 
    if { ![info exists STAGE] } { set stage "place" }

    if { !$incremental } { 
  	gui_change_highlight -remove -all_colors
	remove_annotation_shapes -all

	puts "HIER_LIST $HIER_LIST"
	if {[string equal $HIER_LIST "-clear"]} {	    
	    return
	}
    }
    
    lassign [lindex [get_attribute [current_design] boundary_bbox] 1] x y
    set font_size         16
    if { $y > 500 } { set font_size [expr int($y/30)] }   
 
    set dy [expr int($y/(2 + max(20,(0.5*[llength $HIER_LIST]))))]

    set col_idx 0
    
    set yloc [expr $y - 2*$dy]
    set xloc [expr $x*1.08]
    
    foreach {h_name pat} $HIER_LIST {
        set my_obj [get_cells -hierarchical -filter "full_name=~*$pat*"]
        set sz [sizeof $my_obj]
        
        if { $sz == "0" } { continue }
      # hier size readability
        if { $sz > 1000000 } {
            set sz "[expr 0.1*int(10*0.000001*$sz+0.5)]M"
        } elseif { $sz > 1000 } {
            set sz "[expr 0.1*int(10*0.001*$sz+0.5)]K"        
        }
	append_to_collection my_obj [create_annotation_text -origin "$xloc $yloc" -text "$h_name $sz" -font_size $font_size -horizontal_alignment left]

      # highlighting text and insts
        if { [llength $color_list] } {
 		gui_change_highlight  -collection $my_obj -color [lindex $color_list [expr $col_idx%[llength $color_list]]]
        } else {
		gui_change_highlight  -collection $my_obj
        }
        
        incr col_idx
        set  yloc [expr $yloc - 2*$dy]
    }
  # set zoom
    gui_zoom -window [gui_get_current_window -view] -rect "[expr -0.1*$x] [expr -0.1*$y] [expr 1.5*$x] [expr 1.1*$y]"

}

proc be_color_ports { PORT_LIST {incremental 0} {color_list ""} } {

    set font_size         20
    set new_bus_dist     100    ;# the distance in um between two parts of a bus to allow for a new bus section
    set small_bus_limit  100    ;# size in um for width of bus or part of bus, that below will write in perpendicular to the ports
    set skip_bus_limit   100    ;# size of bus or part of bus that if below limit will not be annotated
    gui_set_highlight_options -auto_cycle_color 1
    gui_set_highlight_options -current_color yellow 

    if { !$incremental } { 
        gui_change_highlight -remove -all_colors
	remove_annotation_shapes -all
    }
    set is_text_exists [sizeof [get_annotation_shapes -quiet]]
    set col_idx 0
    lassign [lindex [get_attribute [current_design] boundary_bbox] 1] X Y
    if { $Y > 500 } { set font_size [expr int($Y/25)] }   
 
    foreach {p_name pat} $PORT_LIST {
        set my_obj [get_ports *$pat*]
        set sz [sizeof $my_obj]
        
	set loc_list ""
 	if { $p_name != "NO_TEXT" } {
            set p_name_len      [expr $font_size * [string length $p_name]]
            set small_bus_lim   [expr max($small_bus_limit,0.5*$p_name_len)]
        
            if { $sz > 1000000 } {
                set sz "[expr 0.1*int(10*0.000001*$sz+0.5)]M"
            } elseif { $sz > 1000 } {
                set sz "[expr 0.1*int(10*0.001*$sz+0.5)]K"        
            }
        
            set side    [lindex [lsort -u [get_attribute $my_obj pin_edge]] end]
            set is_vert [expr !($side%2)]
        
	    set cmd "get_ports \$my_obj -filter {pin_edge==${side}}"
	    set _my_obj [eval $cmd]

            set const [expr { $is_vert ? "y" : "x" }]
            set var   [expr { $is_vert ? "x" : "y" }]
        
    
	    set a_list [lsort -real -unique [get_attribute [get_ports $_my_obj] bounding_box.ll_$const]]
            foreach _a $a_list {
		set cmd "lsort -real \[get_attribute \[get_ports \$_my_obj -filter  {bounding_box.ll_${const}==${_a}}\] bounding_box.ll_${var}\]"

		set b_list [eval $cmd] 
                set b_prev [expr 0 - 2*$new_bus_dist]
                set b0 [lindex $b_list 0]
            
                set cntr   0
                set markers ""
                foreach _b $b_list {
                    incr cntr
                    if { [expr $_b - $b_prev] > $new_bus_dist } {
                        if { $cntr >= $skip_bus_limit } {
                            lappend markers "$b0 $b_prev"
			}
                        set b0 $_b
                    }
                    set b_prev $_b
                }
                if { $cntr >= $skip_bus_limit } {        
                    lappend markers "$b0 $_b"
                }
                foreach {b0 b1} [join $markers] {
                    #set is_small [expr ($b1 - $b0) < $small_bus_lim]
		    set is_small 1

                    set b "[expr 0.5*($b0 + $b1) + ($is_small*(0.5*($font_size))) - (1 - $is_small)*0.3*$p_name_len ]"
                    if { $_a > 0 } {
                        set a "[expr $_a + 1.4*$font_size + (1 - $is_vert)*($font_size)]"
                    } else {
                        set a "[expr $_a - ($is_vert)*$font_size - 1.4*$font_size - (0.5*$is_small*$p_name_len)]"
                    }

                    if { $is_vert } {
                        set orient   [expr {$is_small ? "R90" : "R0"}]
                        lappend loc_list "$b $a"
                    } else {
                        set orient   [expr {$is_small ? "R0" : "R90"}]                
                        lappend loc_list "$a $b"
                    }
                }
            }
        } ;# TEXT GUI

        foreach {x y} [join $loc_list] {    
            append_to_collection my_obj [create_annotation_text -origin "$x $y" -text "$p_name" -font_size $font_size -orientation $orient]
        }
        
        if { [llength $color_list] } {

	    gui_change_highlight  -collection $my_obj -color [lindex $color_list [expr $col_idx%[llength $color_list]]]

        } else {
            if { $col_idx == 11 } { incr col_idx }
            if { $col_idx == 12 } { incr col_idx }
	    
            gui_change_highlight  -collection $my_obj
        }
        
        incr col_idx
    }
#    gui_fit
    if { $is_text_exists } {
        gui_zoom -window [gui_get_current_window -view] -rect "[expr -0.1*$X] [expr -0.1*$Y] [expr 1.5*$X] [expr 1.1*$Y]"
    } else {
         gui_zoom -window [gui_get_current_window -view] -rect "[expr -0.2*$X] [expr -0.2*$Y] [expr 1.2*$X] [expr 1.2*$Y]"
    }
}



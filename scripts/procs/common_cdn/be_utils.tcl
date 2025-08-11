#
#
#

proc be_color_hiers { HIER_LIST {incremental 0} {color_list ""} } {

    global STAGE

    if { ![info exists STAGE] } { set stage "place" }

    set_layer_preference violation -is_visible 0
    set_layer_preference node_layer -is_visible 0
    if { !$incremental } { 
        gui_clear_highlight -all
        delete_obj [get_db gui_texts]
    }
    
    lassign [join [get_db designs .bbox.ur]] x y

    set dy [expr int($y/(2 + max(18,(0.5*[llength $HIER_LIST]))))]

    set col_idx 0
    
    set yloc [expr $y - 2*$dy]
    set xloc [expr $x*1.08]
    
    foreach {h_name pat} $HIER_LIST {
        set my_obj [get_db insts *$pat*]
        set sz [llength $my_obj]
        
        if { $sz == "0" } { continue }
      # hier size readability
        if { $sz > 1000000 } {
            set sz "[expr 0.1*int(10*0.000001*$sz+0.5)]M"
        } elseif { $sz > 1000 } {
            set sz "[expr 0.1*int(10*0.001*$sz+0.5)]K"        
        }
      # adding text  
        lappend my_obj [create_gui_text -pt "$xloc $yloc" -label "$h_name  $sz" -height $dy -layer 1]
      # highlighting text and insts
        if { [llength $color_list] } {
            gui_highlight $my_obj -color [lindex $color_list [expr $col_idx%[llength $color_list]]]
        } else {
            if { $col_idx == 11 } { incr col_idx }
            if { $col_idx == 12 } { incr col_idx }
            gui_highlight $my_obj -index [expr 1 + 1*$col_idx]
        }
        
        incr col_idx
        set  yloc [expr $yloc - $dy]
    }
  # set zoom
    gui_zoom -rect "[expr -0.1*$x] [expr -0.1*$y] [expr 1.5*$x] [expr 1.1*$y]"
}

proc be_color_ports { PORT_LIST {incremental 0} {color_list ""} } {

    set font_size         20
    set new_bus_dist     100    ;# the distance in um between two parts of a bus to allow for a new bus section
    set small_bus_limit  100    ;# size in um for width of bus or part of bus, that below will write in perpendicular to the ports
    set skip_bus_limit   100    ;# size of bus or part of bus that if below limit will not be annotated
    
    set_layer_preference violation -is_visible 0
    set_layer_preference node_layer -is_visible 0
    if { !$incremental } { 
        gui_clear_highlight -all
        delete_obj [get_db gui_texts]
    }
    set is_text_exists [llength [get_db gui_texts]]
    
    set col_idx 0
    lassign [join [get_db designs .bbox.ur]] X Y
    if { $Y > 500 } { set font_size [expr int($Y/25)] }   
 
    foreach {p_name pat} $PORT_LIST {
        set my_obj [get_db ports *$pat*]
        set sz [llength $my_obj]
        
	set loc_list ""
 	if { $p_name != "NO_TEXT" } {
            set p_name_len      [expr $font_size * [string length $p_name]]
            set small_bus_lim   [expr max($small_bus_limit,0.5*$p_name_len)]
        
            if { $sz > 1000000 } {
                set sz "[expr 0.1*int(10*0.000001*$sz+0.5)]M"
            } elseif { $sz > 1000 } {
                set sz "[expr 0.1*int(10*0.001*$sz+0.5)]K"        
            }
        
            set side    [lindex [lsort [get_db $my_obj .side]] end]
            set is_vert [regexp ".o.th" $side]
        
	    set _my_obj [get_db $my_obj -if .side==$side]

            set const [expr { $is_vert ? "y" : "x" }]
            set var   [expr { $is_vert ? "x" : "y" }]
        
            set a_list [lsort -unique [get_db $_my_obj .location.$const]]
            foreach _a $a_list {
        
                set b_list [lsort -real [get_db [get_db $_my_obj -if .location.${const}==$_a] .location.${var}]] 
                set b_prev [expr 0 - 2*$new_bus_dist]
                set b0 [lindex $b_list 0]
            
                set cntr   0
                set markers ""
                foreach _b $b_list {
                    incr cntr
                    if { [expr $_b - $b_prev] > $new_bus_dist } {
                        if { $cntr >= $skip_bus_limit } {
                            lappend markers "$b0 $b_prev"
                            set cntr 0
                        }
                        set b0 $_b
                    }
                    set b_prev $_b
                }
                if { $cntr >= $skip_bus_limit } {        
                    lappend markers "$b0 $_b"
                }
                foreach {b0 b1} [join $markers] {
                    set is_small [expr ($b1 - $b0) < $small_bus_lim]

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

        foreach "x y" [join $loc_list] {    
            lappend my_obj [create_gui_text -pt "$x $y" -label "$p_name" -height $font_size -layer 1 -orient $orient]
        }
        
        if { [llength $color_list] } {
            gui_highlight $my_obj -color [lindex $color_list [expr $col_idx%[llength $color_list]]]
        } else {
            if { $col_idx == 11 } { incr col_idx }
            if { $col_idx == 12 } { incr col_idx }
            gui_highlight $my_obj -index [expr 1 + 1*$col_idx]
        }
        
        incr col_idx
    }
#    gui_fit
    if { $is_text_exists } {
        gui_zoom -rect "[expr -0.1*$X] [expr -0.1*$Y] [expr 1.5*$X] [expr 1.1*$Y]"
    } else {
        gui_zoom -rect "[expr -0.2*$X] [expr -0.2*$Y] [expr 1.2*$X] [expr 1.2*$Y]"
    }
}

#
proc be_snapshot {args} {
  # //  
    set PROC "[lindex [info level 0] 0]"

  # // Parse args
    set help_info "
    $PROC saves design snapshot under given location and name
    "
    # opt_name                  must  type      default                          info
    set my_args {
      { file_name                 1  string      ""                               "name of the .gif file to be saved" }
      { dim_level                 0  string      "medium"                         "will dim background to be either 'dark' 'medium' or 'none'" }
      { dont_remove_text          0  boolean     0                                "if not used, will remove all added gui texts after save design" } 
      { dont_clear_highlights     0  boolean     0                                "if not used, will run 'gui_clear_highlight -all'" }
      { dont_hide_layers          0  boolean     0                                "if not used, will hide all layers (except highlighted)" }
      { dont_hide_violations      0  boolean     0                                "if not used, will hide all violations markers (except highlighted)" }
      { custom_zoom               0  string      ""                               "if not given, will zoom to design size+- 5%. if used, please give full bbox to zoom to" }
    }

    if { [be_parse_args $help_info $my_args $args] != 0 } { return }

    if { $dim_level!="none" && $dim_level!="dark" && $dim_level!="medium" } {
        puts "-E- $PROC required <dim_level> to be either 'dark' , 'medium' or 'none'"
        $PROC -help ; return
    }

    if { !$dont_hide_layers }       { set_layer_preference node_layer -is_visible 0 }
    if { !$dont_hide_violations }   { set_layer_preference violation  -is_visible 0 }
    gui_dim_foreground -light_level $dim_level

    ### maybe search automatically for rects of texts ?
    if { $custom_zoom == "" } {
        lassign [join [get_db [get_db designs] .bbox]] x0 y0 x1 y1
        set x [expr $x1 - $x0]
        set y [expr $y1 - $y0]
     
        set d 0.05
     
        gui_zoom -rect "[expr $x0 - $d*$x] [expr $y0 - $d*$y0] [expr $x1 + $d*$x] [expr $y1 + $d*$y]"
    }
    
    if { [regexp -all {(.*)\/([^\/]*)} $file_name ~ d f] } {
        file mkdir $d
    }
    write_to_gif $file_name

    if { !$dont_clear_highlights } { gui_clear_highlight -all }
    if { !$dont_remove_text }      { delete_obj [get_db gui_texts] }
}

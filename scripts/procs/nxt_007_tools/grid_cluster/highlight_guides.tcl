proc highlight_guides { {i ""}  {j ""} {highlight_box false} } {

    global LEBS_MAPPED
	if { (![info exists LEBS_MAPPED] || $LEBS_MAPPED==0) } { map_leb_cells }

	set color_list [split "red|blue|green|yellow|magenta|cyan|lightpink|purple|teal|olive|plum|navy|pink|lime|orange|brown|lightblue|gold|chocolate|lightgreen|maroon|salmon|violet|darkcyan|royalblue|darkgreen|tomato|chartreuse|wheat|deepskyblue|darkorange|darkred|white" "|"]

	if { $i!="" && $j!="" } {
		set group_name *GCU_COL_${i}_gcu_col*leb_inst_${j}_genblk1_leb*
		set color [lindex $color_list [expr round(rand()*32)]]

        if { [regexp "Genus" [get_db program_name]] == 1 } {
		    if { $i == "*" } { gui_pv_highlight -append -color $color [get_db insts -if {.leb_row == $j }]  ; return }     
		    if { $j == "*" } { gui_pv_highlight -append -color $color [get_db insts -if {.leb_col == $i }]  ; return } 
		    gui_pv_highlight -append -color $color [get_db insts -if {.leb_col == $i && .leb_row == $j }]  ; return              
        } else {
		    gui_highlight -auto_color [get_db insts -if {.name == $group_name }]
        }

        return
    }
    
#    for {set i 0} { $i < 60 } { incr i } {
#        for {set j 0} { $j < 60 } { incr j } {
#			set group_name *GCU_COL_${i}_gcu_col*leb_inst_${j}_genblk1_leb*
#	        if { [regexp "Genus" [get_db program_name]] == 1 } {
#			    gui_pv_highlight -append -color [lindex $color_list [expr ($j + $i)%33]] [get_db insts -if {.name == $group_name }]			        
#	        } else {            
#			    gui_highlight -auto_color [get_db insts -if {.name == $group_name }]			
#	        }
#        }
#    }

}

proc map_leb_cells {} {
	
	global LEBS_MAPPED
    
    define_attribute leb_row -category leb_cells -data_type int -obj_type inst 
    define_attribute leb_col -category leb_cells -data_type int -obj_type inst

	for {set i 0} { $i < 8 } { incr i } {

        puts "-I- Mapping LEB_${i}_*"
#            set current_leb [get_db region:*/LEB_${i}_${j}]
#        set leb_cells [get_db insts -if { .name==*GCU_COL_${i}_gcu_col*leb_inst_*_genblk1_leb* }]
        set leb_cells [get_db insts *GCU_COL_${i}_gcu_col*leb_inst_*_genblk1_leb*]
        set_db $leb_cells .leb_col $i -quiet


    }	
   	for { set j 0 } { $j < 60 } { incr j } {
     	puts "-I- Mapping LEB_*_${j}"
#          set current_leb [get_db region:*/LEB_${i}_${j}]
#        set leb_cells [get_db insts -if { .name==*GCU_COL_*_gcu_col*leb_inst_${j}_genblk1_leb* }]
        set leb_cells [get_db insts *GCU_COL_*_gcu_col*leb_inst_${j}_genblk1_leb* ]
        set_db $leb_cells .leb_row $j -quiet
            
    }  

    set LEBS_MAPPED 1          
    
}

proc report_lebs_util { {force_map 0} {calc_dist 0} } {
	
    global LEBS_MAPPED
    
	if { (![info exists LEBS_MAPPED] || $LEBS_MAPPED==0) || $force_map } { map_leb_cells }
	
    # Define user attributes    	
    if { [regexp "Genus" [get_db program_name]] == 1 } { set obj "region" } else { set obj "group" }
    define_attribute dist_from_leb 	-category leb_cells -data_type double -obj_type inst 
    define_attribute my_leb_util 	-category leb_cells -data_type double -obj_type inst     
    define_attribute leb_area 		-category leb_cells -data_type double -obj_type $obj 
    define_attribute leb_util 		-category leb_cells -data_type double -obj_type $obj     
    define_attribute leb_cell_count -category leb_cells -data_type int 	 -obj_type $obj         
    define_attribute leb_regs_count -category leb_cells -data_type int 	 -obj_type $obj             
    define_attribute leb_rpts_count -category leb_cells -data_type int 	 -obj_type $obj                 
    define_attribute leb_clks_count -category leb_cells -data_type int 	 -obj_type $obj                     
    define_attribute leb_logc_count -category leb_cells -data_type int 	 -obj_type $obj                         
    array unset lebs_arr 
    
	for {set i 0} { $i < 8 } { incr i } {
      	for { set j 0 } { $j < 60 } { incr j } {
        	
            if { [regexp "Genus" [get_db program_name]] == 1 } {
            set current_leb [get_db regions [get_db current_design .name]/LEB_${i}_${j} ]
            } else {
            set current_leb [get_db groups [get_db current_design .name]/LEB_${i}_${j} ]            
            }
            if { [llength $current_leb] == 0 } { puts "-W- LEB_${i}_${j} Not found" ; continue}
            set leb_bbox	[get_db $current_leb .rects]
            lassign [join $leb_bbox " "] xl yl xh yh
            set leb_area 	[expr ($yh-$yl)*($xh-$xl)]
            
            set leb_cells	[get_db insts -if { .leb_col==$i && .leb_row==$j }]
            set cells_area	[get_db $leb_cells .area]
            set total_leb_cells_area [lsum $cells_area]
            
            set lebs_arr($current_leb) 			[get_db $current_leb .name]
            set lebs_arr($current_leb:count)	[llength $leb_cells]
            set lebs_arr($current_leb:area)		$leb_area
            set lebs_arr($current_leb:util)		[format "%.2f" [expr $total_leb_cells_area/$leb_area]]
			
            # Fitler by cell type
            set regs	    [get_db $leb_cells -if { .is_sequential==true && !.base_cell.name==CK*}]
            set clocks   	[get_db $leb_cells -if { .base_cell.name==CK*}]
            set bufsNinvs   [get_db $leb_cells -if { !.base_cell.name==CK* && (.base_cell.name==*BUFF* || .base_cell.name==*INV*) }]
            set logic       [remove_from_collection [get_cells $leb_cells] [add_to_collection [get_cells $bufsNinvs] [add_to_collection [get_cells $clocks] [get_cells $regs]] ]]
            set lebs_arr($current_leb:regs)	    [llength $regs]
            set lebs_arr($current_leb:bits)	    [sizeof [get_pins -of $regs -filter direction==out]]
			set lebs_arr($current_leb:clocks)   [llength $clocks]
			set lebs_arr($current_leb:repeaters) [llength $bufsNinvs]
 			set lebs_arr($current_leb:logic)    [sizeof_collection $logic]
            
            set_db $current_leb .leb_area       $lebs_arr($current_leb:area)        -quiet
            set_db $current_leb .leb_util       $lebs_arr($current_leb:util)  		-quiet
            set_db $current_leb .leb_cell_count $lebs_arr($current_leb:count)		-quiet
            set_db $current_leb .leb_regs_count $lebs_arr($current_leb:regs)		-quiet
            set_db $current_leb .leb_rpts_count $lebs_arr($current_leb:repeaters)	-quiet
            set_db $current_leb .leb_clks_count $lebs_arr($current_leb:clocks)      -quiet                                                  
            set_db $current_leb .leb_logc_count $lebs_arr($current_leb:logic)       -quiet                                                                
            
            if { $calc_dist } {
            	set leb_x [expr ($xh+$xl)/2]
            	set leb_y [expr ($yh+$yl)/2]                
                set total_dist 0
                
                foreach cell $leb_cells {
                	set cell_location [join [get_db $cell .location] " "]
                    if { [llength $cell_location] != 2} { continue }
                    lassign $cell_location cell_x cell_y
                    set dx [expr ($leb_x - $cell_x)] ; set dy [expr ($leb_y - $cell_y)] ; set dist [expr sqrt( $dx*$dx + $dy*$dy )]
                    set total_dist [expr $total_dist + $dist ]
                    
                    set_db $cell .dist_from_leb $dist							-quiet
                    set_db $cell .my_leb_util 	$lebs_arr($current_leb:util)	-quiet
                }
                set lebs_arr($current_leb:dist) [expr $total_dist/[llength $leb_cells]]
            }
        }    
    }
    
    set table {}
    foreach leb [array names lebs_arr] {

    	if { [regexp ":\[a-z\]+\$" $leb] } { continue }
        
        if { $calc_dist } { 
    	    lappend table [list $lebs_arr($leb) $lebs_arr($leb:util) $lebs_arr($leb:area) $lebs_arr($leb:count) $lebs_arr($leb:regs) $lebs_arr($leb:bits) $lebs_arr($leb:clocks) $lebs_arr($leb:repeaters) $lebs_arr($leb:logic) $lebs_arr($leb:dist)]
        } else {
	        lappend table [list $lebs_arr($leb) $lebs_arr($leb:util) $lebs_arr($leb:area) $lebs_arr($leb:count) $lebs_arr($leb:regs) $lebs_arr($leb:bits) $lebs_arr($leb:clocks) $lebs_arr($leb:repeaters) $lebs_arr($leb:logic) ]        
        }
        
    }
    
    if { $calc_dist } {
	    set header 	[list Name Util Box_area Cell_count Regs Bits Bufs_N_Invs Clock_cells Logic AVG_dist(um)]
	    set style   "%-20s %.2f %.2f %d %d %d %d %d %d %.2f"    
    } else {
	    set header 	[list Name Util Box_area Cell_count Regs Bits Bufs_N_Invs Clock_cells Logic]
	    set style   "%-20s %.2f %.2f %d %d %d %d %d %d"
    }
    
    set table [lsort -real -index 1 -dec $table]
    
    redirect [get_db current_design .name]_lebs_util_[clock format [clock seconds] -format %Y%m%d_%H%M].tbl { rls_table -table $table -header $header -format $style -spacious -breaks } 
    
    return [array get lebs_arr]	
    
}






















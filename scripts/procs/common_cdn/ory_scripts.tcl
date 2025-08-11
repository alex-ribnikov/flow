
##################
# Prints progress bar
##################
proc ory_progress {cur tot {is_pct true}} {
    # if you don't want to redraw all the time, uncomment and change ferquency
    #if {$cur % ($tot/300)} { return }
    # set to total width of progress bar
    set total 76
  
    set half [expr {$total/2}]
    
    if { $is_pct } {
        if { [set percent [expr {100.*$cur/$tot}]] > 100 } { set percent 100 }
        set val (\ [format "%6.2f%%" $percent]\ )
        set str "\r|[string repeat = [
                    expr {round($percent*$total/100)}]][
                            string repeat { } [expr {$total-round($percent*$total/100)}]]|"
        set str "[string range $str 0 $half]$val[string range $str [expr {$half+[string length $val]-1}] end]"
    } else {
        
    }
    puts -nonewline stderr $str
}

##################
# Return all macros
##################
proc all_macros { args } {
	return [get_cells [get_db insts -if .is_macro==true]]
}

##################
# Support some wildcards
# TODO: edit/delete this proc
##################
proc ory_get_cells { cells } { 
# Get cells using wildcards. I didn't find any better built in option
	if { $cells == "" } { return "" }
	redirect -var garbage { set res [sizeof_collection $cells] }
	if { [string length $cells] > 8 && $res > 0 } { return $cells }
	
	set split_1		[string map {"{" "" "}" ""} [split $cells "\n"]]
	set split_2     [split $split_1 " "]	
	
	set res {}
	foreach cell $split_2 {
# 		puts $cell
		if { $cell == "" } { continue }
		set new_cells [get_cells [get_db insts -if { .name==$cell }]]
		append_to_collection res $new_cells
	}

	return $res
}

##################
# Return clock gates
##################
proc ory_get_clock_gates {} {
	return [get_cells [get_db insts -if { .base_cell.is_integrated_clock_gating==true  }]]
}

##################
# Csc with wildcards (edit probably!)
##################
proc csc { cells } {
# Change selection to cells
	set cells [ory_get_cells $cells ]
	
	if { ![sizeof $cells] } { puts "-E- No matching cells found" ; return -1}
	
	deselect_obj [get_db selected]
		
	select_obj $cells
}

##################
# select obj + deselct
##################
proc so { obj } {

	deselect_obj [get_db selected]    
    select_obj $obj

}

##################
# select obj + deselct
##################
proc cs { obj } {

	deselect_obj [get_db selected]    
    select_obj $obj

}

##################
# Get selected - same as Roy's
##################
#proc gs {} {
#    
#    # set collection {}
#    # set selected [get_db selected]
#    # set obj_types [lsort -u [get_db $selected .obj_type]]
#    
##    append_to_collection collection [get_cells -quiet $selected]
##    append_to_collection collection [get_pins  -quiet $selected]
##    append_to_collection collection [get_port  -quiet $selected]        
##    append_to_collection collection [get_nets  -quiet $selected]            
#    
##    return $collection
#	return [get_db selected]
#}

##################
# Get pin's clocks
##################
proc c { objects } {
    foreach obj [get_db $objects] {
        set clocks [get_db $obj .clocks.base_name]
        puts "$obj \t $clocks"
    }
}


##################
# Get hierarchies of cells
# <level1>/<level2><etc....>
# sort by number of cells in hierarchy / alphabetical order
# effort of "bus" compression
##################
proc ory_get_hiers_of_cells { cells {level 0} {sort_by 0} {compression_effort "low"} } {

    if { $compression_effort == "high" } {
    	regsub -all "\[0-9\]+" [get_db $cells .parent.name ] "*" all_parent_names
    } else {
    	regsub -all "\\\[\[0-9\]+\\\]" [get_db $cells .parent.name ] "\[*\]" all_parent_names    
    }

    # Show $level levels of hierarchies
    array unset res_arr

    if { $level > 0 } {
        
        set pattern "\[a-zA-Z0-9_\*\]+/"
        set reg_phrase [string repeat $pattern $level]
        foreach name $all_parent_names {
            regexp $reg_phrase $name name
            set name [string trim $name "/"]
            if { [info exists res_arr($name)] } {
                lappend res_arr($name) $name        
            } else {
                set res_arr($name) [list $name]
            }

        }
            
    } else {
        foreach name $all_parent_names {
            if { [info exists res_arr($name)] } {
                lappend res_arr($name) $name        
            } else {
                set res_arr($name) [list $name]
            }

        }
    }

    set table {}
    foreach name [array names res_arr] {
        
        lappend table [list [llength $res_arr($name)] $name]
        
    }
    
    if { $sort_by } {
        set s_table [lsort -decr -index $sort_by $table]
    } else {
        set s_table [lsort -decr -real -index $sort_by $table]
    }
    
    rls_table -table $s_table -header "#ofCells Hier_cell" -format "%-5d %s" -spacious -breaks
    

}

##################
# Parsing an obj attributes
##################
proc ory_get_obj_dbs { obj {key_prefix ""} {att_list {}} } {

    array unset obj_att_arr
	
    if { $att_list == {} } {
        redirect -var all_attributes { get_db $obj .* }
        foreach att [lrange [split $all_attributes "\n"] 1 end] {
            if  { $att == "" } { continue }
            if { ![regexp "^  (\[a-zA-Z0-9_\]+):" $att res att_name] } { continue }
            lappend att_list $att_name        
        }
    }
    
    foreach att_name $att_list {
    	if { $key_prefix != "" } {
            set obj_att_arr($key_prefix:$att_name) [get_db $obj .$att_name]        
        } else {
            set obj_att_arr($att_name) [get_db $obj .$att_name]
        }
    }
    
    return [array get obj_att_arr]
    
}

##################
# Calc center of mass
##################
proc ory_get_com { objects {is_list_of_locs false} } {

    if { $is_list_of_locs } {
        set locations $objects
    } else {
        set locations [get_db $objects .location]
    }
    
    set x_sum 0
    set y_sum 0 
    
    foreach location $locations {
        set splited [split [string map {"\{" "" "\}" ""} $location] " "]
        set x_sum [expr $x_sum + [lindex $splited 0]]
        set y_sum [expr $y_sum + [lindex $splited 1]]        
    }   
    
    set com_x [expr $x_sum/[llength $locations]]
    set com_y [expr $y_sum/[llength $locations]]    
    
    return [list $com_x $com_y]
}

##################
# Highligh LEB clock gates 
##################
proc ory_highlight_leb_clock_gates { {i ""}  {j ""} {calc_dist false} {check_fo_size false} } {

	set color_list [split "red|blue|green|yellow|magenta|cyan|lightpink|purple|teal|olive|plum|navy|pink|lime|orange|brown|lightblue|gold|chocolate|lightgreen|maroon|salmon|violet|darkcyan|royalblue|darkgreen|tomato|chartreuse|wheat|deepskyblue|darkorange|darkred|white" "|"]

	if { $i!="" && $j!="" } {
		set gate_name  i_gcu_top/gcu/GCU_COL_${i}_gcu_col/genblk1_${j}_genblk1_u_leb_clk_gate/i_clk_gate
		set gate_pin   i_gcu_top/gcu/GCU_COL_${i}_gcu_col/genblk1_${j}_genblk1_u_leb_clk_gate/i_clk_gate/Q        
        set afo        [all_fanout -only_cells -from $gate_pin -flat -endpoint]
		set color [lindex $color_list [expr round(rand()*32)]]

        if { [regexp "Genus" [get_db program_name]] == 1 } {
            gui_pv_highlight -append -color $color [get_db insts $gate_name]
		    gui_pv_highlight -append -color $color $afo
        } else {
            gui_highlight -auto_color [get_db insts $gate_name]
		    gui_highlight -auto_color $afo
        }
    }
    
    # Calc dist
    if { $calc_dist } {
        set gate_location [split [string map {"\{" "" "\}" ""} [get_db [get_db insts $gate_name] .location] ] " "]
        set afo_com       [ory_get_com $afo]
        set dist [expr abs([lindex $afo_com 0] - [lindex $gate_location 0]) + abs([lindex $afo_com 1] - [lindex $gate_location 1])]
        puts "Gate index $i $j dist: [format %.2f $dist]\tCOM: [format %.2f $afo_com]"
    }
    
#    if { $check_fo_size } {
#        set gate_location [split [string map {"\{" "" "\}" ""} [get_db [get_db insts $gate_name] .location] ] " "]
#        set afo_com       [ory_get_com $afo]
#        set dist [expr abs([lindex $afo_com 0] - [lindex $gate_location 0]) + abs([lindex $afo_com 1] - [lindex $gate_location 1])]
#        puts "Gate index $i $j dist: $dist"
#    }    

}

##################
# Highlight leb guides
##################
proc ory_highlight_guides { {i ""}  {j ""} {highlight_box false} } {

    global LEBS_MAPPED
	if { (![info exists LEBS_MAPPED] || $LEBS_MAPPED==0) } { ory_map_leb_cells }

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

}

##################
# Map leb cells
# TODO: Is this still needed?
##################
proc ory_map_leb_cells {} {
	
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

##################
# Calculate LEB utilization
##################
proc ory_report_lebs_util { {force_map 0} {calc_dist 0} } {
	
    global LEBS_MAPPED
    
	if { (![info exists LEBS_MAPPED] || $LEBS_MAPPED==0) || $force_map } { ory_map_leb_cells }
	
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


#############################################
# Saves objects to a file, in a "set \[get_db ...\] format
proc ory_output_objects { objects collection_name file_name } {

   set type [lsort -u [get_db $objects .obj_type] ]

   if { [llength $type] > 1 } {
       puts "-E- Your objects must be all of the same type!"
       return
   }
   
   set obj_name [get_db $objects .name]
   set cmd "set $collection_name \[get_db ${type}s \" \\\n"
   
   foreach obj $objects {
       append cmd "[get_db $obj .name] \\\n"
   }
   append cmd "\"\]"

   redirect $file_name {puts $cmd}
   puts "-I- Source $file_name to set $collection_name"
   
}



proc ory_comma {num {sep ,}} {
    while {[regsub {^([-+]?\d+)(\d\d\d)} $num "\\1$sep\\2" num]} {}
    return $num
}

proc ory_isnumeric { string } {
    if { $string == "" } { return 0 }
    if { [string is digit $string] || [string is double $string] || [string is integer $string] || [string is wideinteger $string] } {
        return 1
    }
    return 0
}

proc ory_commify_table { data } {
    
    # This proc enter commas to all the numbers in a table (list of lists)
    set new_data $data
    set i 0
    foreach line $data {
        set j 0
        set new_line $line
        foreach cell $line {
            if { [ory_isnumeric $cell] } {
                set new_line [lreplace $new_line $j $j [ory_comma [string trim [format %#.f $cell] "."]]]
            }
            incr j

        }
        set new_data [lreplace $new_data $i $i $new_line]
        incr i
    }

    return $new_data
}

proc ory_sort_cells { cells } {
# Returns [list "Clock cells" "FFs" "Bufs/Invs" "Combinational cells"]
    foreach cell $cells {                                    
        if { [get_db $cell .is_integrated_clock_gating] == true } {
            lappend clock_cells $cell                                                                
        } elseif { [get_db $cell .is_sequential] == true} {
            lappend sequentials $cell                                                                
        } elseif { [get_db $cell .is_buffer] == true || [get_db $cell .is_inverter] == true } {
            lappend repeaters $cell                                                                  
        } elseif { [get_db $cell .is_combinational] == true } {
            lappend logics $cell                                                                       
        }
    }
    return [list $clock_cells $sequentials $repeaters $logics]
}



proc ory_leb_type_vt { {cells {} } } {

    set leb_cells [get_db hinsts *i_gcu_top*LEB_TYPES_*]
    array unset leb_types_arr
    foreach hcell $leb_cells {
        set cell_name [get_db $hcell .name]
        if { ![regexp "/LEB_TYPES_\[0-9\]+_(\[a-zA-Z0-9_\]+)$" $hcell res leb_type] } { continue }
        lappend leb_types_arr($leb_type) $hcell       
    }
    
    set table {}
    foreach leb_type [lsort [array names leb_types_arr]] {
        set pattern "*$leb_type/*"
        set all_cells   [get_db insts $pattern]
        
        set res [be_report_cells_vt -return_res -insts $pattern]
        
        lassign [lindex $res 0] svt  svt_count  svt_cpct  svt_area  svt_apct        
        lassign [lindex $res 1] lvt  lvt_count  lvt_cpct  lvt_area  lvt_apct        
        lassign [lindex $res 2] ulvt ulvt_count ulvt_cpct ulvt_area ulvt_apct                
        
        lappend table [list $leb_type $svt_area  $svt_apct $lvt_area $lvt_apct $ulvt_area $ulvt_apct]
        
    }
#    set table [lsort -index end-1 -real -decreasing $table]
    set header [list "Leb Type" "SVT Area" "SVT pct" "LVT Area" "LVT pct" "ULVT Area" "ULVT pct" ]
    set format [list "%s"       "%.2f"      "%7s"     "%.2f"      "%7s"     "%.2f"       "%7s"     ]

    # Sum table

    set total {"Total"}
    for {set i 1} { $i < [expr [llength $header] ] } {incr i 2} {
        lappend total [format "%.2f" [ory_lsum -list $table -index $i]]
        lappend total ""
    }
    lappend table [list "" "" "" "" "" "" ""]    
    lappend table $total
    rls_table -format $format -table $table -header $header -spacious -breaks
    
}


proc ory_count_leb_types { {cells {} } } {

    set leb_cells [get_db hinsts *i_gcu_top*LEB_TYPES_*]
    array unset leb_types_arr
    foreach hcell $leb_cells {
        set cell_name [get_db $hcell .name]
        if { ![regexp "/LEB_TYPES_\[0-9\]+_(\[a-zA-Z0-9_\]+)$" $hcell res leb_type] } { continue }
        lappend leb_types_arr($leb_type) $hcell       
    }
    
    set table {}
    foreach leb_type [lsort [array names leb_types_arr]] {
        set pattern "*$leb_type/*"
        set all_cells   [get_db insts $pattern]
        set res         [ory_sort_cells $all_cells]
        set areas       [get_db $all_cells .area]
        set total_area  [format "%.2f" [lsum $areas]]
        lassign $res clock_cells sequentials repeaters logics
        
        set num_of_inst   [llength $leb_types_arr($leb_type)]
        set num_of_cells  [llength $all_cells]
        set num_of_seqs   [llength $sequentials]
        set num_of_bits   [sizeof [get_pins -of $sequentials -filter direction==out]]
        set num_of_logics [llength $logics] 
        set num_of_rpts   [llength $repeaters] 
        set num_of_icgs   [llength $clock_cells]
        
        lappend table [list $leb_type $num_of_inst $num_of_cells [expr 1.0 * $num_of_cells / $num_of_inst] \
        $num_of_seqs [expr 1.0 * $num_of_seqs / $num_of_inst] \
        $num_of_bits [expr 1.0 * $num_of_bits / $num_of_inst] \
        $num_of_logics [expr 1.0 * $num_of_logics / $num_of_inst] \
        $num_of_rpts $num_of_icgs $total_area [expr 1.0 * $total_area / $num_of_inst] ]
    }
    set table [lsort -index end-1 -real -decreasing $table]
    set header [list "Leb Type" "#ofInsts" "#ofCells" "Avg" "#ofSeq" "Avg" "#ofBits" "Avg" "#ofLogic" "Avg" "#ofRpts" "#ofICGs" "TotalArea" "Avg" ]
    set format [list "%s"       "%7s"      "%7s"      "%5s" "%7s"    "%5s" "%7s"     "%5s" "%7s"      "%5s" "%7s"     "%10s"    "%8s"       "%5s" ]

    # Sum table
    set total {"Total"}
    for {set i 1} { $i < [expr [llength $header] ] } {incr i} {
        lappend total [format "%.2f" [ory_lsum -list $table -index $i]]
    }
    lappend table $total
    rls_table -format $format -table [ory_commify_table $table] -header $header -spacious -breaks
    
}


::parseOpt::cmdSpec ory_lsum {
    -help "Input: list or list of lists that includes atleast on column of numbers (float/int) and index of column to sum.\nOutput: sum of sublist or list.\n"
    -opt {
        {-optname list         -type list -default ""   -required 1 -help "List (or list of lists) to sum"}
        {-optname index        -type integer -default 0   -required 0 -help "Column in list of lists or default 0"}
    }
}
proc ory_lsum { args } {

    if { ! [::parseOpt::parseOpt ory_lsum $args] } { return 0 }    
    
    set l       $opt(-list)
    set index   $opt(-index) 
    
    # Is list of lists?
    if { [llength [lindex $l 0]] > 1 } {        
        # Get sub-list
        set newl []
        foreach node $l {
#            puts [lindex $node $index]
            lappend newl [lindex $node $index]
        }        
    } else {
        set newl $l
    }
    # Sum newl if every cell is a number
    set sum 0
    foreach node $newl {
        if { [ory_isnumeric $node] } {
            set sum [expr $sum + $node]
        } else {
            puts "-E- Error: All summerized cells must be numbers.\n-E- proc oy_lsum could not sum list."
            return
        }
    }
    return $sum
    
}




##################
# Check before source
# TODO: Add search path
# TODO: Add some flags like display
##################
proc source_if_exists { file } {

   if { [file exists $file] } {
       source -e -v $file
   } else {
       puts "-W- source_if_exists: Could not find $file"       
   }
   
   return -1
}

##################
# Parse Genus QOR report
##################
proc parse_genus_qor { file } {
    
    set fp      [open $file r]
    set fp_data [read $fp]
    close $fp
    
    set parsed_data {}
    foreach line [split $fp_data "\n"] {
        
        if { $line == "" } { continue }
        set spline [split [regsub -all "  +" $line " "] " "]
        
        # 
        
    }
    
    return parsed_data    
}

##################
# Show proc
# Based on the get_proc_source script
##################
proc be_show_proc { proc_name } {
    
    redirect -var  source_proc {get_proc_source $proc_name}
    set source_proc [glob [join $source_proc]]
    set my_file [split [exec cat $source_proc] "\n"]
    set line [expr [lsearch  -regexp  $my_file ".*proc.*$proc_name .*"] + 1]
    exec nedit -read -line $line $source_proc &

}

##################
# Same as show_proc without read_only flag
##################
proc be_edit_proc { proc_name } {
    
    redirect -var  source_proc {get_proc_source $proc_name}
    set source_proc [glob [join $source_proc]]
    set my_file [split [exec cat $source_proc] "\n"]
    set line [expr [lsearch  -regexp  $my_file ".*proc.*$proc_name .*"] + 1]
    exec nedit -line $line $source_proc &

}

proc be_refresh_user_dontuse {} {

    set user_defined_dont_use_list      [split [get_db user_dontuse_list] " "]
    set user_dont_use_lib_cells         [lsort -u [get_db [get_db lib_cells $user_defined_dont_use_list] .base_cell]]

    if { [regexp "Genus" [get_db program_name]] } {
        set_db [get_db $user_dont_use_lib_cells .lib_cells] .avoid true
    }
    set_dont_use [get_db $user_dont_use_lib_cells .lib_cells]

}

proc ory_return_vt_group { base_cell_name } {

    array unset vt_rule_arr
    
    set vt_rule_arr(svt)    [list  SVT06   SVT DSVT P6S]
    set vt_rule_arr(lvt)    [list  LVT06   LVT DLVT P6S]
    set vt_rule_arr(ulvt)   [list  ULT06   ULT DULVT P6U]
    set vt_rule_arr(lvtll)  [list  LVTLL06 DLVTLL]
    set vt_rule_arr(ulvtll) [list  ULTLL06 DULVTLL]
    
    set group "UNKNOWN"
    
    foreach vt_group [lsort [array names vt_rule_arr]] {
    
        foreach pattern $vt_rule_arr($vt_group) {
            
            if { [regexp $pattern $base_cell_name] } { set group $vt_group }
            
        }
    
    }
    
    return $group
}

proc be_set_design_source { } {

    if { [is_attribute design_source -obj root] == 0 } {
        # Define design source - in genus: RTL, in innovus: syn dir / db
        define_attribute design_source -category be_user_attributes -data_type string -obj_type root -default ""
    }
    
    if { [is_attribute place_netlist_source -obj root] == 0 } {   
        define_attribute place_netlist_source -category be_user_attributes -data_type string -obj_type root -default ""
    } 

    if { [get_db program_short_name] == "genus" } {
        set_db -quiet design_source [get_db designs .entity_filename]
    } else {
        # WIP - define design_source att in innovus - syn folder maybe?
        if { $::STAGE == "floorplan" } {
            
            if { $::NETLIST == "None" } {
                if { ![file exists [set netlist $::SYN_DIR/out/${::DESIGN_NAME}.Syn.v.gz]] } { puts "-E- No netlist found" }
            } else {
                if { ![file exists [set netlist $::NETLIST]] } { puts "-E- No netlist found" }
            }
            set design_source $::SYN_DIR/out
            
        } else {
            
            if { $::PLACE_START_FROM == "db" } {
                if { [set netlist       [get_db place_netlist_source]] != "" } {  
                    set design_source [get_db design_source] 
                } else {
                    set netlist out/db/${::DESIGN_NAME}.floorplan.enc.dat/${::DESIGN_NAME}.v.gz
                    set design_source out/db/${::DESIGN_NAME}.floorplan.enc.dat
                }
            } elseif { $::PLACE_START_FROM == "def" } {

                if { $::NETLIST == "None" } {
                    if { ![file exists [set netlist $::SYN_DIR/out/${::DESIGN_NAME}.Syn.v.gz]] } { puts "-E- No netlist found" }
                } else {
                    if { ![file exists [set netlist $::NETLIST]] } { puts "-E- No netlist found" }
                }
                set design_source $::SYN_DIR/out

            } elseif { $::PLACE_START_FROM == "syn_incr" } {
                if { $::NETLIST == "None" } {
                    if { ![file exists [set netlist $::SYN_DIR/out/${::DESIGN_NAME}.Syn.v.gz]] } { puts "-E- No netlist found" }
                } else {
                    if { ![file exists [set netlist $::NETLIST]] } { puts "-E- No netlist found" }
                }
                set design_source $::SYN_DIR/out
	    
            } else {
                set design_source $::SYN_DIR/out/${::DESIGN_NAME}.Syn.invs_db/${::DESIGN_NAME}.stylus.enc
                set netlist       $design_source/${::DESIGN_NAME}.v.gz            
            }
            

                    
        }
        
        if { [file exists $netlist] && ![file exists $design_source] } { set design_source $netlist }

        set_db -quiet design_source        [exec realpath $design_source]
        set_db -quiet place_netlist_source [exec realpath $netlist]        
    }

}


proc be_show_log {} {

    set log_file [get_db log_file]
    exec nedit -read $log_file &

}


proc redirect_and_catch { args } { 
    
    redirect -var redirect_return_var { if { [catch {eval [join $args " "]} res] } { puts "$res \n-E- Error running $args"}} 
    
    if { [regexp -all "\\\-E\\\- Error running $args" $redirect_return_var res] } { 
        set err_msg [join [lrange [split $redirect_return_var "\n"] 0 end-2] "\n"] 
        puts $err_msg 
        
        set redirect_return_var [join [lrange [split $redirect_return_var "\n"] end-1 end] "\n"]
    } else { set err_msg "" }
    
    return $redirect_return_var
    
}





proc find_cell_doc { base_cell } {

    if { ![is_attribute be_cell_desc -obj_type base_cell] } {    
        define_attribute be_cell_doc  -category be_user_attributes -data_type string  -obj_type base_cell -default ""
        define_attribute be_cell_doc  -category be_user_attributes -data_type string  -obj_type lib_cell  -default ""
        define_attribute be_cell_doc  -category be_user_attributes -data_type string  -obj_type library   -default ""        
        define_attribute be_cell_desc -category be_user_attributes -data_type string  -obj_type base_cell -default ""        
        define_attribute be_cell_desc -category be_user_attributes -data_type string  -obj_type inst      -default ""        
    } elseif { [set bcd [get_db $base_cell .be_cell_doc]] != "" } {
        return $bcd
    } elseif { [set bcd [lindex [get_db $base_cell .lib_cells.be_cell_doc] 0]] != "" } {
        set_db -quiet $base_cell .be_cell_doc $bcd
        return $bcd
    } elseif { [set bcd [lindex [get_db $base_cell .lib_cells.library.be_cell_doc] 0]] != "" } {
        set_db -quiet [get_db $base_cell .lib_cells] .be_cell_doc $bcd
        set_db -quiet $base_cell .be_cell_doc $bcd
        return $bcd    
    }
    set lib_file      [lindex [get_db $base_cell .lib_cells.library.files]]
    set doc_path      "[join [lrange [split $lib_file "/"] 0 14] "/"]/doc"
    set pdf           [glob -nocomplain $doc_path/*pdf]
    
    if { $pdf == "" } { return "" }
    
    set pdf_base_name [lindex [split $pdf "/"] end]
    exec cp -Lp $pdf ".$pdf_base_name"
    exec pdftotext ".$pdf_base_name"
    file delete ".$pdf_base_name"
    
    
    set rp  [exec realpath ".$pdf_base_name" | cat]
    set bcd [string replace $rp end-2 end "txt"]
    set_db -quiet $base_cell .be_cell_doc $bcd
    set_db -quiet [get_db $base_cell .lib_cells]         .be_cell_doc $bcd
    set_db -quiet [get_db $base_cell .lib_cells.library] .be_cell_doc $bcd
    
    return $bcd
    
}

proc set_cell_desc { base_cell } {

    if { ![is_attribute be_cell_desc -obj_type base_cell] } {    
        define_attribute be_cell_doc  -category be_user_attributes -data_type string  -obj_type base_cell -default ""
        define_attribute be_cell_doc  -category be_user_attributes -data_type string  -obj_type lib_cell  -default ""
        define_attribute be_cell_doc  -category be_user_attributes -data_type string  -obj_type library   -default ""        
        define_attribute be_cell_desc -category be_user_attributes -data_type string  -obj_type base_cell -default ""        
        define_attribute be_cell_desc -category be_user_attributes -data_type string  -obj_type inst      -default ""        
    }
    
    set bcd [get_db  $base_cell .be_cell_doc]
    if { $bcd == "" } {
#        puts "Finding BCD: [find_cell_doc $base_cell]"
        set bcd [find_cell_doc $base_cell]
    }    
#    puts "BCD: $bcd"
    
    if { $bcd == "" } { return }
    
    set fp [open $bcd r]
    set fd [read $fp]
    close $fp
    
    set bc_relevant_name [join [lrange [split [get_db $base_cell .name] "_"] 1 end-1] "_"]
    if { [catch {set result [string trim [exec grep -A3 $bc_relevant_name $bcd | grep -A1 "Cells Description" | tail -1] \"]} res] } { set result "" }
    
    # Standardize result string 
    set std_res ""
    foreach char [split $result {}] {
        scan $char %c av
        if { $av > 127 } { set char "*" }
        append std_res $char
    }
    set result $std_res
    
    set_db -quiet $base_cell .be_cell_desc $result
    
    return $result
        
}

proc set_all_base_cells_desc { } {
    
    set base_cells [get_db base_cells]
    
    set index 0
    set total [llength $base_cells]
    
    foreach bc $base_cells {
        incr index    
        ory_progress $index $total
        
#        puts $bc
        set_cell_desc $bc
    }    
    puts ""
    
}

proc get_inst_desc { inst } {
    
    set base_cell [get_db $inst .base_cell]
    
    if { ![is_attribute be_cell_doc -obj_type base_cell] || [set bci [get_db $base_cell .be_cell_desc]] == "" } {
        set bci [set_cell_desc $base_cell]
    }
    
    return [list [get_db $base_cell .name] $bci]

}

#
#proc be_copy_stage_start  { stage } {
#
#    if { [get_db program_short_name] == "genus" } {
#    
#    } else {
#        
#        set rpt_list         [glob -nocomplain reports/${stage}_*]
#        set stage_rpt_folder reports/$stage
#        
#        set log_files [glob -nocomplain log/${stage}.*]
#        
#        exec mkdir -pv reports/.tmp_prev log/.tmp_prev
#        
#        
#        if { $rpt_list != "" } {
#            puts "-I- Copy $stage reports to tmp prev folder"
#            file delete -force reports/.tmp_prev/${stage}_*
#            foreach file $rpt_list {
#                exec cp -fp $file  reports/.tmp_prev/
#            }
#        }     
#        
#        if { [file exists $stage_rpt_folder] } {
#            puts "-I- Copy $stage reports folder to tmp prev folder"        
#            file delete -force reports/.tmp_prev/$stage
#            exec cp -rfp $stage_rpt_folder reports/.tmp_prev/
#        }
#        
#        if { $log_files != "" } {
#            puts "-I- Copy $stage logs to tmp prev folder"        
#            file delete -force log/.tmp_prev/$stage.*
#            foreach file $log_files {            
#                exec cp -fp $file log/.tmp_prev/
#            }
#            set_db log_file  log/${stage}.log
#            set_db logv_file log/${stage}.logv
#            set_db cmd_file  log/${stage}.cmd                        
#        }
#    
#    }
#
#}
#
#proc be_copy_stage_finish { stage } {
#
#    if { [get_db insts]}
#
#}


proc ory_get_cell_func { cell } {

    if { ![catch {get_db $cell} res] } {
        set type [get_db $cell .obj_type]
    }
    
    if { $type != "base_cell" } {
    
        
    
    }
    
    return "[get_db $cell .name] -> [get_db [get_db [get_db [lindex [get_db $cell .lib_cells] 0] .lib_pins] -if .direction==out] .function]"
    
}


proc ory_sum_table { table {sort_by -1} } {

    set num_of_col [llength [lindex $table 0]]
    set col_types  {}
    
    # Transpose
    set table_t [_transposeMatrix $table]
    
    # 1st passage - mark columns
    set new_table_t {}
    foreach line $table_t {
        set is_float false
        set dec_digits -1 
        set but_did_i_check_format false 
        set format_str ""          
        set col_type "number"
        set col_tot  0
        foreach v $line {
            if { ![ _isnumeric $v ] } {
                set col_type "notAnumber"
                break
            } else {
                set col_tot [expr $col_tot + $v]
                if { !$but_did_i_check_format } {
                    if { [regexp "\\.(\[0-9\]+)" $v res dec_digits] } {            
                        set format_str "%.[string length $dec_digits]f"
                    }
                }
            }
        }
        if { $format_str != "" } { set col_tot [format $format_str $col_tot] }
        lappend col_types $col_type
        
        if { $col_type == "number" } { 
            set new_line [concat $line $col_tot]
        } else {
            set new_line [concat $line [list "-"]]
        }
        lappend new_table_t $new_line
    }     
    
    # Transpose
    set table [_transposeMatrix $new_table_t]
    
    return $table
}

proc _isnumeric { string } {
    if { $string == "" } { return 0 }
    if { [string is digit $string] || [string is double $string] || [string is integer $string] || [string is wideinteger $string] } {
        return 1
    }
    return 0
}

proc _iota n {
   # index vector generator, e.g. iota 5 => 0 1 2 3 4
   set res {}
   for {set i 0} {$i<$n} {incr i} {
       lappend res $i
   }
   set res
}

proc _transposeMatrix m {
   set cols [_iota [llength [lindex $m 0]]]
   foreach row $m {
       foreach element $row   *col $cols {
           lappend ${*col} $element
       }
   }
   eval list $[join $cols " $"]
}

proc remove_from_list { list1 list2 } {
    # Return all elemnts in list1 which are not in list2
    foreach elem $list1 {dict set   y $elem 1}
    foreach elem $list2 {dict unset y $elem}
    set result [dict keys $y]
    return $result
}



proc avg_list { l } {
    
    if { [llength $l] == 0 } { return 0 }
    
    set s 0
    foreach v $l { set s [expr $s + $v] }
    
    return [expr 1.0*$s/[llength $l]]
    
}


proc ory_get_list_variance { l } {
    # Returns list of variance, average and number of samples
    set sum     [lsum $l]
    set len     [llength $l]
    set avg     [expr $sum/$len]
    set d_sum   0
    
    foreach delay $l {
        set d_sum [expr ($d_sum + ($delay - $avg)**2 )]
    }
    
    set var [expr $d_sum/$len ]
    set std [expr sqrt($var)]
    
    return [list $var $avg $len $std]
}

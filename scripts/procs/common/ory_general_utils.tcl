proc t {args} {
    if {[llength $args]==0} {
        echo "Usage: t <collection> \[flags\] \[attribute name\] \[attribute name\] \[\{proc\}\] \[./file\] ..."
        echo "optional additional flags: return, nosort, noname, full_name, uniq\[c\]\[n\]\n\n";
        echo "procedure usage: must include a space! example: {return \[get_pins -of \$o\]}"
        echo "to write directly to a file, it must start with ./ or /, if the file ends with .csv it will be written as csv"
	return
    }
    
    set is_list false
    
    redirect -var garbage { if { [catch {set objects_list [get_db [lindex $args 0]]} res] } { set objects_list [lindex $args 0] ; set is_list true} }

    if { $is_list } { puts [join [lsort -dictionary $objects_list] "\n"] ; return }

    if {[llength $args]==1} {
        # quick print collection
        set table [list]
        foreach o $objects_list {
            lappend table [get_db $o .name]
        }
        puts [join [lsort -dictionary $table] "\n"]
	    return
    }
    # parse "command line"
    set table [list]
    set attrs [list]
    set doReturn 0  
    set doSort 1
    set noName 0
    set doUniq 0
    set doUniqCount 0
    set toFile ""
    array set UNIQ {}
    set header [list {Object Name}]
    set attrsData [list]
    foreach a [lrange $args 1 end] {
	if {$a=="return"} {
	    set doReturn 1
	} elseif {$a=="nosort"} {
	    set doSort 0
	} elseif {$a=="noname"} {
	    set noName 1
	} elseif {[regexp {^uniq(c)?(\d+)?$} $a -> count field]} {
	    set doUniq 1
	    if {$count=="c"} {set doUniqCount 1}
	    if {$field==""} {set field 0}
	    set uniqField $field
	} elseif {[regexp {^[\/\~\.]} $a]} {
	    set toFile $a
	} else {
	    if {$a=="full_name"} {set noName 1}
	    lappend attrs $a
	    if {[regexp {\s} $a]} {
		lappend header "proc[llength $attrs]"
	    } else {
		lappend header $a
	    }
	}
    }
    set col $objects_list
    if {$noName} {set header [lrange $header 1 end]}
    set soCol [llength $col]
    # get attributes data
    foreach a $attrs {
	if {[regexp {\s} $a]} {
	    eval "proc temp_t_procedure {o} {$a}"
	    set data [list]
	    foreach o $col {
		set v [eval {temp_t_procedure $o}]
		if {[regexp {^_sel\d+$} $v]} {
		    set v [get_db $v .name]
		}
		lappend data $v
	    }
	    lappend attrsData $data
	} else {
	    set data [ory_get_attribute  $col $a]
	    set need [expr {-[llength $data]}]
	    if {[llength $data]!=$soCol} {
		set data [list]
		foreach o $col {
		    if {[expr {$need==0}]} {break}
		    set v [ory_get_attribute  $o $a]
		    if {$v!=""} {incr need}
		    lappend data $v
		}
	    }
	    lappend attrsData $data
	}
    }
    # transpose to table
    set oi 0
    foreach o $col {
	set line [list]
	if {!$noName} {if { ![catch {set Objname [get_db $o .name]} res] } { lappend line $Objname } else { lappend line "Obj$oi" } }
	set ai 0
	foreach a $attrs {
	    lappend line [lindex [lindex $attrsData $ai] $oi]
	    incr ai
	}
	if {$doUniq} {
	    set val [lindex $line $uniqField]
	    if {[info exists UNIQ($val)]} {
		incr UNIQ($val)
		incr oi
		continue
	    }
	    set UNIQ($val) 1
	}
	incr oi
	lappend table $line
    }
    if {$doUniq && $doUniqCount} {
	# add uniq count
	for {set oi 0} {$oi<[llength $table]} {incr oi} {
	    set line [lindex $table $oi]
	    set val [lindex $line $uniqField]
	    lset table $oi [lreplace $line $uniqField $uniqField "$val ($UNIQ($val))"]
	}
    }
    # finish
    if {$doReturn} {return $table}
    if {$doSort} {set table [lsort -dictionary $table]}
    if {$toFile==""} {
	rls_table -header $header -table $table -spacious -breaks -no_sep
    } elseif {[regexp {\.csv$} $toFile]} {
	rls_table -header $header -table $table -file $toFile -csv_mode
    } else {
	rls_table -header $header -table $table -spacious -breaks -no_sep -file $toFile
    }
}


proc ory_get_attribute { object attribute } {
	get_db $object .$attribute
}

proc lsum { list } {
	set sum 0
	foreach v $list {
     set sum [expr $sum + $v]
    }
    return $sum
}


proc common_collection { c1 c2 } {
	return [remove_from_collection $c1 [remove_from_collection $c1 $c2]]
}




proc ory_bus_compress { ports {level 0} {table false} {key_words {}} } {

	if { $level == 0 } {
	set new_list [lsort [regsub -all "_\[0-9\]+ \|_\[0-9\]+$" [regsub -all "\\\[\[0-9\]+\\\]" $ports "[*]"] "* " ] ]
    } else {
	set new_list [lsort [regsub -all "\[0-9\\\[\\\]\]+" $ports "*" ] ]
    }

	set new_list [lsort [regsub -all "_\\\*" $new_list "*" ] ]    
	set new_list [lsort [regsub -all "\\\*+" $new_list "*" ] ]        
    
    if {$key_words != {}} {
        	set regsub_string [join $key_words "\|"]
            puts $regsub_string
          	set new_list [lsort [regsub -all $regsub_string $new_list "*" ] ]
    }

    if { $table } {
        set counters {}
        foreach item $new_list {
            dict incr counters $item
        }
        set new_list {}
        dict for {item count} $counters {
            lappend new_list [list $item $count]
        }        
        set new_list [lsort -decr -real -index 1 $new_list]
        return $new_list
    } else {
    	set new_list [lsort -uniq [regsub -all "\\\*+" $new_list "*" ] ]            
        return $new_list
    }
    
}


proc oy_find_missing_open_brackets { file } {

    set fp [open $file r]
    set fp_data [read $fp]
    close $fp
    
    set split_data [split $fp_data "\n"]
    
    set last [llength $split_data]
    set balance_curly 0
    set balance_square 0
    set balance_round 0        
    set 1st_unb_line -1
    
    array unset lines_arr
    
    for {set i 0 } { $i < $last } { incr i } {

        set current_line [lindex $split_data $i]
                
        set open_b_num [llength [split $current_line "\{"]]
        set close_b_num [llength [split $current_line "\}"]]
        	
        set balance_curly [expr $balance_curly + $close_b_num - $open_b_num]
        
        set open_b_num [llength [split $current_line "\["]]
        set close_b_num [llength [split $current_line "\]"]]
        
        set balance_square [expr $balance_square + $close_b_num - $open_b_num]
        
        set open_b_num [llength [split $current_line "\("]]
        set close_b_num [llength [split $current_line "\)"]]
        
        set balance_round [expr $balance_round + $close_b_num - $open_b_num]

        puts "$balance_curly | $balance_square | $balance_round --- $current_line"
#        puts "$balance_curly | $balance_square | $balance_round --- $last_balanced_line"         
        
        set lines_arr($i) [list $balance_curly $balance_square $balance_round]
        
        if { $balance_curly > 0 } { puts $current_line  ; set br_type 0 ; set unb_bracket $i ; break }   
        if { $balance_square > 0 } { puts $current_line ; set br_type 1 ; set unb_bracket $i ; break }                     
        if { $balance_round > 0 } { puts $current_line  ; set br_type 2 ; set unb_bracket $i ; break }                
            
    } 
    
    return $i
}


proc oy_find_missing_close_brackets { file } {

    set fp [open $file r]
    set fp_data [read $fp]
    close $fp
    
    set split_data [split $fp_data "\n"]
    
    set last [llength $split_data]
    set balance_curly 0
    set balance_square 0
    set balance_round 0        
    set 1st_unb_line -1
    
    
    for {set i [expr $last - 1] } { $i >= 0 } { incr i -1 } {

        set current_line [lindex $split_data $i]
        
#         puts $current_line
                
        set open_b_num [llength [split $current_line "\{"]]
        set close_b_num [llength [split $current_line "\}"]]
        
        set balance_curly [expr $balance_curly + $close_b_num - $open_b_num]
        
        if { $balance_curly < 0 } { puts $current_line ; return "-I- Missing \'\}\' in line: $i" }
        
        set open_b_num [llength [split $current_line "\["]]
        set close_b_num [llength [split $current_line "\]"]]
        
        set balance_square [expr $balance_square + $close_b_num - $open_b_num]
        
        if { $balance_square < 0 } { puts $current_line ; return "-I- Missing \'\]\' in line: $i" }        
        
        set open_b_num [llength [split $current_line "\("]]
        set close_b_num [llength [split $current_line "\)"]]
        
        set balance_round [expr $balance_round + $close_b_num - $open_b_num]
        
        if { $balance_round < 0 } { puts $current_line ; return "-I- Missing \'\)\' in line: $i" }                
            
    } 

}

proc get_proc_name {} {return [info level [expr [info level] -1]]}


proc minority {bool_args} {
  # Initialize a count to 0
  set count 0

  # Iterate over the arguments
  foreach arg $bool_args {
    # If the current argument is equal to the specified value, increment the count
    if {$arg} {
      incr count
    }
  }

  # If the count is less than or equal to 1, return 1 (minority of arguments are equal to the specified value)
  if {$count <= [expr [llength $bool_args]/2.0]} {
    return 1
  }
  # Otherwise, return 0 (majority of arguments are not equal to the specified value)
  return 0
}

proc _or_ {bool_args} {
    return [expr [join $bool_args "||"]]
}

proc _and_ {bool_args} {
    return [expr [join $bool_args "&&"]]
}


proc list2hist { vector bin } {

    set vector [lsort -real -increasing $vector]
    set max_val [lindex $vector end]
    set min_val [lindex $vector 0]
    set buck_l [expr $min_val - 0.5*$bin]
    set buck_h $buck_l
    array unset l
    set max_word 0
    set min 9999
    set max -9999
    set table {} 
    set indx 0
    set count 0
    while { $buck_h < $max_val } {
        set buck_h [expr $buck_l + $bin]
        set count 0
#        puts "range: $buck_l $buck_h"
        foreach val $vector { 
            if { ($val > $buck_l) && ($val <= $buck_h) } { incr count }
        }
        if {$buck_h >= $max_val} {
            set n "\($buck_l\)-\($max_val\)"
#             puts "$n: $count"
            set l($indx:$n) $count
            incr indx
            if { [string length $n] > $max_word } { set max_word [string length $n] }         
        } else {
            set n "\($buck_l\)-\($buck_h\)"
#             puts "$n: $count"
            set l($indx:$n) $count
            incr indx
            if { [string length $n] > $max_word } { set max_word [string length $n] } 
        }
        if { $min > $count } { set min $count}
        if { $max < $count } { set max $count}        
        set buck_l [expr $buck_h]
#puts "$buck_h $max_val $count"        
    }

    set ratio [expr (1.0*($max-$min)/[llength $vector])/($max/200.0)]
    if { $min == $max } { set ratio 1 }

#    puts "-D- ratio=$ratio, max=$max, min=$min mw=$max_word" ; parray l

#    foreach n [lsort [array names l]] { puts "[format "%-${max_word}s" [lindex [split $n ":"] 1]] - [format "%-8s" $l($n)] - [string repeat "\#" [expr int($l($n)*$ratio) + 1]]" }
    
    for { set i 0 } { $i < $indx } { incr i } {
        
        set n [array names l $i:*]
        puts "[format "%-${max_word}s" [lindex [split $n ":"] 1]] - [format "%-8s" $l($n)] - [format "%-8s" [format "%.2f" [expr 100.0*$l($n)/[llength $vector]]]%] - [string repeat "\#" [expr int($l($n)*$ratio) + 1]]"
        
    }
 

}

proc split_bbox {bbox xslice yslice {margin 0.0}} {
  set bbox_list {}
  set dx [expr {(1+$margin)*([lindex $bbox 2] - [lindex $bbox 0]) / $xslice}]
  set dy [expr {(1+$margin)*([lindex $bbox 3] - [lindex $bbox 1]) / $yslice}]
  for {set i 0} {$i < $xslice} {incr i} {
    for {set j 0} {$j < $yslice} {incr j} {
      set x0 [expr {[lindex $bbox 0] + $i * $dx}]
      set y0 [expr {[lindex $bbox 1] + $j * $dy}]
      set x1 [expr {$x0 + $dx}]
      set y1 [expr {$y0 + $dy}]
      lappend bbox_list [list $x0 $y0 $x1 $y1]
    }
  }
  return $bbox_list
}

proc split_bbox_by_slice_size {bbox dx dy {margin 0.0}} {
  set bbox_list {}
  
  lassign $bbox xl yl xh yh
  set xsize [expr $xh - $xl]
  set ysize [expr $yh - $yl]
  
  set xslice [expr ceil($xsize/$dx)]
  set yslice [expr ceil($ysize/$dy)]
  
  set dx [expr {(1+$margin)*([lindex $bbox 2] - [lindex $bbox 0]) / $xslice}]
  set dy [expr {(1+$margin)*([lindex $bbox 3] - [lindex $bbox 1]) / $yslice}]
  for {set i 0} {$i < $xslice} {incr i} {
    for {set j 0} {$j < $yslice} {incr j} {
      set x0 [expr {[lindex $bbox 0] + $i * $dx}]
      set y0 [expr {[lindex $bbox 1] + $j * $dy}]
      set x1 [expr {$x0 + $dx}]
      set y1 [expr {$y0 + $dy}]
      lappend bbox_list [list $x0 $y0 $x1 $y1]
    }
  }
  return $bbox_list
}

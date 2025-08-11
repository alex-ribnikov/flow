proc be_read_sdc { sdc_file } {
    redirect -tee ./reports/read_sdc.rpt {source -e -v $sdc_file}
    puts [exec grep -B1 -i "error\\|warning" sdc.rpt]
}


proc ory_get_hiers_of_cells { cells {level 0} {sort_by 0} {compression_effort "low"} } {

    set top_name  [current_design_name]
    set names     [get_object_name $cells]
    set new_names {}
    foreach n $names { 
        if { ![regexp "/" $n] } { lappend new_names $top_name ; continue }
        lappend new_names [join [lrange [split $n "/"] 0 end-1] "/"] 
    }

    if { $compression_effort == "high" } {
    	regsub -all "\[0-9\]+"         $new_names "*" all_parent_names
    } else {
    	regsub -all "\\\[\[0-9\]+\\\]" $new_names "\[*\]" all_parent_names    
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

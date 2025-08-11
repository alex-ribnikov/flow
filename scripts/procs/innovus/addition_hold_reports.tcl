proc _short_report_timing_summary { file {rep_dir ""} } {
	if { ![file exists $file] } { 
        puts "-E- No file was Found\n"
        return -1
    }
    if { $rep_dir == ""} {
    set rep_dir [get_db user_stage_reports_dir]
	#puts "$rep_dir"
    }
    set time_factor 1.0 
    if { [get_db program_short_name] == "innovus" } {
        set time_unit [get_time_unit]
        if { [regexp "ns" $time_unit res] } { set time_factor 1000.0 } else { set time_factor 1.0 }
    }
    set fp [open "$file" r]
    set timing_summary  [read $fp]
    close $fp    
    set trimmed_rpt [regsub -all  "  +" $timing_summary " "]
    if { [regexp "Genus" [get_db program_name]] } {
    regexp "ALL (\[0-9\\-\\.\]+) (\[0-9\\-\\.\]+) (\[0-9\\-\\.\]+)" $trimmed_rpt res wns tns fep
    } else {
    regexp "ALL \[0-9\*-\.\]+ (\[0-9\\-\\.\]+) (\[0-9\\-\\.\]+) (\[0-9\\-\\.\]+)" $trimmed_rpt res wns tns fep   
    }    
    if { ![info exists wns] } { puts "-W- No negative paths found" ; return -1}    
    set timing_table {}
    foreach line [split $trimmed_rpt "\n"] {    
       if {$line == ""} { continue }
       set line [regsub -all "N/A" $line "0.000"]       
       set spline [split $line " "]       
       if { [lindex $spline 1] != "Group" } { continue }
       if { [regexp "Genus" [get_db program_name]] } {
       lassign $spline empty group column group_name group_wns group_tns group_fep
       } else {
       lassign $spline empty group column group_name group_nsigma group_wns group_tns group_fep       
       }       
       lappend timing_table [list $group_name [expr $time_factor*$group_wns] [expr $time_factor*$group_tns] $group_fep]    
    }
    #puts "Setup Corner is:  [get_db [get_db analysis_views -if .is_setup_default==true] .name]"
    set timing_table [lsort -index 2 -real -decre $timing_table ]
    lappend timing_table [list "" "" "" ""]
    lappend timing_table [list All [expr $time_factor*$wns] [expr $time_factor*$tns] $fep]    
    set timing_format [list "%s" "%10s" "%12s" "%10s"]
    set timing_header [list "Group" "WNS(ps)" "TNS(ps)" "FEP"]
    redirect -var table_res {rls_table -format $timing_format -header $timing_header -table $timing_table -spacious -breaks}
    set timing_status "
    [nice_header "Setup Timing QOR"] \n$table_res"           
}

proc _short_report_time_design { file {rep_dir ""} } {

	if { ![file exists $file] } { 
        puts "-E- No file was Found\n"
        return -1
    }
	if { $rep_dir == ""} {
    set rep_dir [get_db user_stage_reports_dir]
	#puts "$rep_dir"
    }
    set time_factor 1.0 
    if { [get_db program_short_name] == "innovus" } {
        set time_unit [get_time_unit]
        if { [regexp "ns" $time_unit res] } { set time_factor 1000.0 } else { set time_factor 1.0 }
    }
    set fp [open "$file" r]
    set timing_summary  [split [read $fp] "\n"]
    close $fp               
    set timing_table {}
    set new_wns {}
    set new_tns {}
    set gmode 0
    foreach line $timing_summary { \
    #puts "[expr [regexp "Hold mode" $line]] "
	   if { [expr [regexp "Hold mode" $line]] != 0 || [expr [regexp "Setup mode" $line]] != 0 } {  
       		set groups  [split $line "|"]
            if {[expr [regexp "Hold mode" $line]] != 0} {
            	set gmode 1
            }
            #puts "$groups"
            #puts "[llength $groups]"
            foreach gr $groups {
            	if { $gr != "" && ![regexp "Hold mode" $gr] && ![regexp "Setup mode" $gr]} {
                lappend group_list $gr	
                }
            }
            set group_list [concat {*}$group_list]
            #puts "$group_list"
            
            continue           
       }   
       #puts "[regexp "WNS (ns):" $line]"     
       if { [expr [regexp "WNS " $line]] != 0 } {
       #puts "$line"
       set line [regsub -all "N/A" $line "0.000"]       
       set spline_wns [split $line "|"]
       set spline_wns  [lrange [concat {*}$spline_wns] 2 end]
       foreach val $spline_wns {
       lappend new_wns [expr $val * $time_factor]
       }                             
       }  
       if {[expr [regexp "TNS " $line]] != 0 } {
       set line [regsub -all "N/A" $line "0.000"]       
       set spline_tns [split $line "|"]  
       set spline_tns  [lrange [concat {*}$spline_tns] 2 end]
       foreach val $spline_tns {
       lappend new_tns [expr $val * $time_factor]
       }               
       }
       if {[expr [regexp "Violating Paths" $line]] != 0 } {
       set line [regsub -all "N/A" $line "0.000"]       
       set violat [split $line "|"] 
       set violat [lrange [concat {*}$violat] 2 end]              
       }  
       if {[expr [regexp "All Paths" $line]] != 0 } {
       set line [regsub -all "N/A" $line "0.000"]       
       set all_p [split $line "|"]
       set all_p [lrange [concat {*}$all_p] 2 end]      
       break       
       }                                  
    }
    #puts "Hold Corner is:  [get_db [get_db analysis_views -if .is_hold_default==true] .name]"
    lappend timing_table $group_list
    lappend timing_table $new_wns
    lappend timing_table $new_tns
    lappend timing_table $violat
    lappend timing_table $all_p
    set temp1 [_transposeMatrix    $timing_table ]
    #lappend timing_table [list All [expr $time_factor*$wns] [expr $time_factor*$tns] $fep]    
    set timing_format [list "%s" "%10s" "%12s" "%10s" "%10s"]
    set timing_header [list "Group" "WNS(ps)" "TNS(ps)" "Violation Paths" "All Paths"]
    redirect -var table_res {rls_table -format $timing_format -header $timing_header -table $temp1 -spacious -breaks}
    if {$gmode == 1} {
    set timing_status "
    [nice_header "Hold Timing QOR"]\n$table_res" 
    } else {set timing_status "
    [nice_header "Setup Timing QOR"]\n$table_res"}
             
}

proc report_ports_conn { {file ""} } {
    
    set ports [get_ports -filter full_name!~*_clk*&&full_name!~*rst*]
    
    set res {}
    
    foreach_in_collection p $ports {
        lappend res [report_port_conn $p]
    }
    set res [lsort -index 2 -real -dec $res]
    if { $file == "" } { set fp [open reports/report_ports_conn.rpt w] } { set fp [open $file w] }
    puts $fp "Port_name Direction FI/FO IsCombo IsBBox IsReg"
    foreach line $res {
        puts $fp [string map {"{" "" "}" ""} $line]
    }
    close $fp
}

proc report_port_conn { port } {
    
    set dir [get_attribute $port direction]
    set fio -1
    set is_combo na  
    set is_reg na  
    set is_bbox na
    
    if { $dir == "in" } {

        set afo      [all_fanout -from $port -flat -end]
        set fio      [sizeof $afo]
        
        set is_combo [expr [sizeof [filter_collection [all_fanout -from $port -flat -only] "is_combinational==true&&is_sequential==false&&is_black_box==false&&ref_name!~*INV*&&ref_name!~*BUF*"]] ? true : false] 
        set is_bbox  [expr [sizeof [filter_collection [all_fanout -from $port -flat -only] "is_black_box==true"]] ? true : false]         
        set is_reg   [expr !$is_combo && [sizeof [filter_collection [all_fanout -from $port -end -flat -only] "is_sequential==true&&is_black_box==false"]] ? true : false]         

        
    } elseif { $dir == "out" } {
        set afi [all_fanin -to $port -flat -start]
        set fio      [sizeof $afi]
        
        set is_combo [expr [sizeof [filter_collection [all_fanin -to $port -flat -only] "is_combinational==true&&is_sequential==false&&is_black_box==false&&ref_name!~*INV*&&ref_name!~*BUF*"]] ? true : false]         
        set is_bbox  [expr [sizeof [filter_collection [all_fanin -to $port -flat -only] "is_black_box==true"]] ? true : false]         
        set is_reg   [expr !$is_combo && [sizeof [filter_collection [all_fanin -to $port -start -flat -only] "is_sequential==true&&is_black_box==false"]] ? true : false]                 
        
    } else {

    }
    
    set res [list [get_object_name $port] $dir $fio $is_combo $is_bbox $is_reg]   
    
}   

proc be_check_timing { {waivers_file ""} {check_timing_file ""} } {
    
    if { $check_timing_file == "" } {
    redirect -var check_timing_res {check_timing}
    } else { 
        set fp [open $check_timing_file r]
        set check_timing_res [read $fp]
        close $fp
    }
    
    set record false
    set title  false
    set check  ""
    array unset violations_arr
    
    foreach line [split $check_timing_res "\n"] {
    
        if { $line == "" || [regexp "\-\-\-\-\-" $line] || [regexp " Changed " $line]} { continue }
        
        if { [regexp "Checking" $line] } { set check [string map {"." ""} [lrange [split [lindex [split $line ":"] 1] " "] 2 end]] ; puts "Check: $check"}
        
        if { [regexp "Warning\|Error" $line] } { puts $line 
            
            set record true
            set title  true
            
            set spline      [split $line ":"]
            set severity    [lindex $spline 0]
            set description [string trim [string trim [lindex $spline 1] " "] "."]
            
            puts "S: $severity ; D: $description"
            
            continue
                    
        } elseif { [regexp "Information" $line] } { 
#            puts $line 
            set record false
#            
#            set spline      [split $line ":"]
#            set severity    [lindex $spline 0]
#            set description [string trim [string trim [lindex $spline 1] " "] "."]
#            
#            puts "S: $severity ; D: $description"
#            
#            set violations_arr($description) ""
            
            continue 
        }
                
        if { $record } {
            if {$title} { set list_title [string trim [string trim $line " "] "."] ; set title false ; continue}
#            lappend violations_arr($check:$description:$list_title) $line
            lappend violations_arr($check) $line
        }
    }
    
    # TODO - Waiving mechanism
    set file reports/check_timing_verbose.rpt
    set fp   [open $file w]
    puts $fp $check_timing_res
    close $fp
    
#    # This report is with no waivers
#    set file reports/check_timing.rpt.original
#    set fp   [open $file w]
#    puts $fp $check_timing_res
#    close $fp
    
    # This is the final report to be parsed
    set file reports/check_timing.rpt
    set fp   [open $file w]    
#    parray violations_arr
    puts $fp "[format  "%-40s" "Violation"] Count\n-----------------------------------------------"
    foreach check $::timing_check_defaults {
       set name [array names violations_arr *$check*] 
       if { $name != "" } { set count [llength $violations_arr($name)] } { set count 0 }
       puts $fp "[format "%-40s" $check] [format "%d" $count]"
    }
    close $fp
    
    exec cat $file    
}


proc be_check_design { {waivers_file ""} } {

    check_design -nosplit > ./reports/check_design_verbose.rpt
    check_design -summary > ./reports/check_design.rpt
    
    exec cat ./reports/check_design.rpt
}







#!/bin/tclsh

    set log_file $argv

    set fp [open $log_file r]
    set fd [read $fp]
    close $fp
    
    set exclude_phrase  "^\@file\|^Suppress \|^Un-suppress \|puts +\"\-E\-\|puts +\"\-W\-\|\\\|Error \|\\\|Warning \|^ERROR     \|^INFO "
    set error_phrase   "ERROR\|Error\|\-E\-"
    set warning_phrase "WARN\|WARNING\|Warning\|\-W\-"
    
    set errors   {}
    set warnings {}
    foreach line [split $fd "\n"] {
        if       { [regexp $exclude_phrase  $line res] } {
            continue        
        } elseif { [regexp $error_phrase  $line res] } {
            lappend errors   $line
        } elseif { [regexp $warning_phrase $line res] } {
            lappend warnings $line
        } 
    }
    
    
    # Parse errors
    array unset err_arr
    foreach line $errors {
        if       { [regexp "\\\-E\\\-" $line res] } {
            lappend err_arr(flow_related) $line
        } elseif { [regexp "INTERNAL ERROR" $line res] } {
            lappend err_arr(INTERNAL_ERROR) $line        
        } elseif { [regexp "\\\*\\\*ERROR: +.(\[A-Z\]+\\\-\[0-9\]+).:" $line res err_type] } {
            lappend err_arr($err_type) $line        
        } elseif { [regexp " \\\[(\[A-Z\]+\\\-\[0-9\]+)\\\] " $line res err_type] } {
            lappend err_arr($err_type) $line        
        }    
    }
    
    # Parse warnings
    array unset wrn_arr
    foreach line $warnings {
        if       { [regexp "\\\-W\\\-" $line res] } {
            lappend wrn_arr(flow_related) $line
        } elseif { [regexp "\\\*\\\*WARN: +.(\[A-Z\]+\\\-\[0-9\]+).:" $line res err_type] } {
            lappend wrn_arr($err_type) $line 
        } elseif { [regexp "\\\#WARNING +(\[A-Z\]+\\\-\[0-9\]+) " $line res err_type] } {
            lappend wrn_arr($err_type) $line 
        } elseif { [regexp "\\\WARNING +(\[A-Z\]+\\\-\[0-9\]+) " $line res err_type] } {
            lappend wrn_arr($err_type) $line 
        } elseif { [regexp " \\\[(\[A-Z\]+\\\-\[0-9\]+)\\\] " $line res err_type] } {
            lappend wrn_arr($err_type) $line        
        }
    }
           
        
    set file_name $log_file.errSum
    set fp [open $file_name w]

    set table {}
    foreach err [array names err_arr] {    	
        set line [list $err [llength $err_arr($err)]]
        lappend table $line        
    }
    puts $fp "[format %-15s "Error Type"]| Count"
    puts $fp "[string repeat - 15]|------"
    foreach line $table {
        puts $fp "[format %-15s [lindex $line 0]]| [lindex $line 1]"
    }
    
    puts $fp ""
    set table {}    
    foreach err [array names wrn_arr] {    	
        set line [list $err [llength $wrn_arr($err)]]
        lappend table $line        
    }    
    
    puts $fp "[format %-15s "Warning Type"]| Count"
    puts $fp "[string repeat - 15]|------"
    foreach line $table {
        puts $fp "[format %-15s [lindex $line 0]]| [lindex $line 1]"
    }
    
    puts $fp ""
    puts $fp "#------------------------------------------"
    puts $fp "# Error Messages - Total of [llength $errors]"
    puts $fp "#------------------------------------------"        
    puts $fp [join $errors "\n"]
    puts $fp ""

    puts $fp "#------------------------------------------"
    puts $fp "# Warning Messages - Total of [llength $warnings]"
    puts $fp "#------------------------------------------"      
    puts $fp [join $warnings "\n"]
    puts $fp ""

	

    
    close $fp              
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

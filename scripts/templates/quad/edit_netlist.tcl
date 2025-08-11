#!/bin/tclsh

proc _parse_args_ { args } {
    upvar opt opt
    set args [regsub -all "\{\|\}\|\\\\" $args ""]
    set split_args [split $args "-"]
    
    foreach arg $split_args {
        if { $arg == "" || $arg == "{" || $arg == "}" } { continue }
        set opt([lindex $arg 0]) [lrange $arg 1 end]
    }
}

proc get_inst_list_from_netlist { netlist } {
    
    set sorted_possible_insts [lsort -u  [regexp -all -inline  "\[a-zA-Z_0-9\]+"  [regexp -all -inline ";\n\[ \t\]+(\[a-zA-Z0-9_\]+)" $netlist ]]]
    
    if { [llength $sorted_possible_insts] == 0 }  { puts "-E- No insts found" ; return -1 }
    
    set filter_words "wire input output" 
     
    set inst_list {}
    foreach inst $sorted_possible_insts {
        if { [regexp $inst $filter_words res] } { continue }
        lappend inst_list $inst
    }
    
    return $inst_list
}

proc change_inst_name { args } {

    if { [string length $args] == 2 || [regexp "\\\-help" $args] } { 
        puts "-HELP- Generate tcl file that converts hinsts to blackboxes
        -input_file       \tstring \tInput file (.v OR .v.gz)
        -inst_map         \tString \tInst map to change names i.e. {u1 u1_for_spef u2 u2_empty}
        -patterns         \tString \tComma Seperated List. Only change names for instances matching this pattern. i.e. r0c\[0-4\]  
        -spef_pattern     \tString \tAll instances matching this pattern will be changed to *_for_spef
        -empty_pattern    \tString \tAll instances matching this pattern will be changed to *_empty
        -is_module        \tBool   \tIf true - only change module name. Default false.
        -output           \tString \tOutput file name
        "
        return
    }
  
    ### Parse args ###
    _parse_args_  $args
    
    if { ![info exists opt(input_file)  ] } { puts "-E- input_file is required"     } { set input_file    $opt(input_file)}
    if { ![info exists opt(output)      ] } { puts "-E- output is required"         } { set output        $opt(output)    }  
    if { [info exists opt(is_module)    ] } { set is_module $opt(is_module)         } { set is_module     false           }
    if { [info exists opt(inst_map)     ] } { set inst_map $opt(inst_map)           } { set inst_map      ""              }
    if { [info exists opt(patterns)     ] } { set patterns $opt(patterns)           } { set patterns      ""              }
    if { [info exists opt(spef_pattern) ] } { set spef_pattern $opt(spef_pattern)   } { set spef_pattern  ""              }
    if { [info exists opt(empty_pattern)] } { set empty_pattern $opt(empty_pattern) } { set empty_pattern ""              }
    
        
    if { ![file exists $input_file] } { puts "-E- Input file $input_file not found" ; exit }
    
    if { $inst_map == "" && $spef_pattern == "" && $empty_pattern == ""     } { puts "-E- You must define either inst_map, spef_pattern or empty_pattern" ; exit }
    if { ( $spef_pattern != "" || $empty_pattern != "" ) && $patterns != "" } { puts "-E- pattern and (spef_pattern and/or empty_pattern) are mutually exclusive" ; exit }
    if { $inst_map != "" && $patterns == ""                                 } { puts "-W- No patterns were defined. The script will replace all instances according to inst_map" }
    
    if { [regexp "\\\.gz" $input_file] }  { set fd [exec zcat $input_file] } { set fd [exec cat $input_file] }

    # Filter out insts from netlist
    set inst_list [get_inst_list_from_netlist $fd]
    
    ### EDIT BY INSTANCE MAP ###
    if { $inst_map != "" } {

        set index -1
        set new_netlist ""
        array set inst_map_arr [split $inst_map " "]
        if { $patterns != "" } { set patterns_list [split $patterns ","] } { set patterns_list {} }
        
        set lines [split $fd "\n"]
        foreach line $lines {
            incr index
            
#            if { ![expr $index%1000] } { puts $line }
            
            if { [regexp "^#" $line ] } { 
                append new_netlist "$line\n"
                continue 
            }
            
            foreach inst [array names inst_map_arr] {                
                set inst_pattern "\[ \t\]($inst)$\|\[ \t\]($inst) "
                set sub_pattern  "$inst"
                set is_pattern true
                
                if { $is_module && ![regexp "module" $line] } { continue }
                if { ![regexp $inst_pattern $line] } { continue }
#                puts "if { !\[regexp $inst_pattern $line\] } { continue }"
                foreach pattern $patterns_list {
                    if { [regexp $pattern $line res] } { set is_pattern true ; break } else { set is_pattern false }   
                    set next_line [lindex $lines [expr $index + 1]]                
                    if { [regexp $pattern $next_line res] } { set is_pattern true ; break } else { set is_pattern false }                       
                }

                if { !$is_pattern } { continue }

                set line [regsub "$sub_pattern" $line "\t$inst_map_arr($inst) "]
                puts "-I- Switched $sub_pattern with \t$inst_map_arr($inst) in line: $index: $line"
                break
            }
            
            append new_netlist "$line\n"
            
        }
        
        set fp [open $output w]
        puts $fp "/*\n#######################################"
        foreach n [array names opt] { puts $fp "# $n = $opt($n)" }
        puts $fp "#######################################*/\n"        
        puts $fp $new_netlist
        close $fp
        
        return 
    }


}
change_inst_name [split $argv " "]

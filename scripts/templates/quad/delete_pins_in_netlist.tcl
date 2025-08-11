

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

proc delete_pins_from_cell { args } {

    if { [string length $args] == 2 || [regexp "\\\-help" $args] } { 
        puts "-HELP- Generate tcl file that converts hinsts to blackboxes
        -input_file       \tstring \tInput file (.v OR .v.gz)
        -patterns         \tString \tComma Seperated List. Only change names for instances matching this pattern. i.e. r0c\[0-4\]  
        -cell_name        \tFor example \"nfi_mcu_top\"
        -output           \tString \tOutput file name
        "
        return
    }
  
    ### Parse args ###
    _parse_args_  $args
    
    if { ![info exists opt(input_file)  ] } { puts "-E- input_file is required" ; exit    } { set input_file    $opt(input_file)}
    if { ![info exists opt(output)      ] } { puts "-E- output is required"     ; exit    } { set output        $opt(output)    }  
    if { [info exists opt(cell_name)    ] } { set cell_name $opt(cell_name)         } { puts "-E- cell_name is required" ; exit }
    if { [info exists opt(patterns)     ] } { set patterns $opt(patterns)           } { puts "-E- Patterns are required" ; exit }
    
        
    if { ![file exists $input_file] } { puts "-E- Input file $input_file not found" ; exit }
    
    if { [regexp "\\\.gz" $input_file] }  { set fd [exec zcat $input_file] } { set fd [exec cat $input_file] }
    
    set index -1
    set counter 0
    set patterns_list [split $patterns ","] 
    set lines [split $fd "\n"]
    set in_cell false
    set is_record true
    
    set new_netlist ""    
    foreach line $lines {

        incr index
        set is_record true
#            if { ![expr $index%1000] } { puts $line }

        if { [regexp "^#" $line ] } { 
            append new_netlist "$line\n"
            continue 
        }
        
        if { $in_cell && [regexp ";" $line] } { set in_cell false ; puts "-I- Removed $counter pins from $cell_name" }
        if { [regexp "$cell_name " $line] } { set in_cell true ; set counter 0 }
        
        foreach pattern $patterns_list {
            if { $in_cell } {
                if {[regexp $pattern $line]} {
                    puts $line
                    incr counter
                    if {[regexp "$cell_name " $line]} { ; append new_netlist "$line\n" }
                    set is_record false
                    break
                }
            } 
        }
               
        if { $is_record } { append new_netlist "$line\n" }

    }

    set fp [open $output w]
    puts $fp "/*\n#######################################"
    foreach n [array names opt] { puts $fp "# $n = $opt($n)" }
    puts $fp "#######################################*/\n"        
    puts $fp $new_netlist
    close $fp

}





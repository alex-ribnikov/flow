proc be_report_timing { args } {
    
    set cmd "report_timing [join $args " "]" 
    redirect -var res { eval $cmd }
    
    if { [regexp "\-physical" $cmd] } {
        
        set new_res ""
        set lines [split $res "\n"]
        foreach line $lines { 
            set new_line $line       
            if { [regexp "\\\(\(\[0-9\\\.\]+\),\(\[0-9\\\.\]+\)\\\)" $line res x y] } { 
                set dist ""
                if { [info exists prev_x] && [info exists prev_y] } {
                    set dist [expr (abs($x - $prev_x) + abs($y - $prev_y))/1000.0]                    
                }
                set prev_x $x
                set prev_y $y
                set new_line "$line $dist"
            }
            puts $new_line
            append new_res "$new_line\n"            
        }
        unset prev_x
        unset prev_y        
        set res $new_res
    }
    
    puts $res
}

proc pt_get_hfn { {th 100} {nets ""} } {
    if { $nets == "" } {
        set nets [get_nets -hier -quiet -filter "number_of_leaf_loads>$th"]
    } else {
        set nets [get_nets -hier -quiet $nets -filter "number_of_leaf_loads>$th"]
    }
    return $nets
}

proc pt_set_ideal_net_on_hfn { {th 100} {trans_val 0.100} {nets ""}} {
    
    puts "-I- Getting nets"
    set nets [pt_get_hfn $th $nets]
    
    if { [sizeof $nets] == 0 } { puts "-W- Did not find any HFN nets" ; return }
    puts "-I- Setting ideal, annotated transition and latency on [sizeof $nets] high fanout nets"
    puts "-I- Out of which [sizeof [filter_collection $nets is_clock_network==true]] nets are clock nets"
    foreach_in_collection net $nets {
#        puts "-D- Net: [get_object_name $net]"    
        set pin_list [add_to_collection [get_attribute $net leaf_loads] [get_attribute $net leaf_drivers]]

        set_annotated_transition -fall $trans_val $pin_list   
        set_annotated_transition -rise $trans_val $pin_list   

        set_annotated_delay -net -from [get_attribute $net leaf_drivers] -to [get_attribute $net leaf_loads] $trans_val 
    }
    
}







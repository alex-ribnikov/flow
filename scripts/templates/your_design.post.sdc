
if { [info exists ::synopsys_program_name] } {
    if { [info exists STAGE] && $STAGE == "syn" } {
    	set period [lindex [lsort -real -inc [get_attribute [get_clocks ] period] ] 0]
    	set pct 0.12
    	puts "-I- Setting max_transition of $pct*$period on all data pins"
    	set_max_transition [expr $period*$pct] $name -data_path
    }

    
    
    
# PT preperation
} elseif { [info exists STAGE] && $STAGE == "syn" } {
    # Set max transition
    set clocks [get_db clocks]
    set period [lindex [lsort -real -inc [get_db clocks .period]] 0]
    set pct 0.12
    puts "-I- Setting max_transition of $pct*$period on all data pins"
    set_max_transition [expr $period*$pct/1000]
} else {
    # Set max transition
    set clocks [get_db clocks]
    foreach clock $clocks {
        set period [get_db $clock .period]
        set name   [get_db $clock .hierarchical_name]
        set pct 0.12
        puts "-I- Setting max_transition of $pct*$period on all data pins related to clock $name"    
        set_max_transition [expr $period*$pct] $name -data_path
    }
}

#if { [info exists STAGE] && $STAGE == "place" } {
#    set clocks [get_db clocks]
#    foreach clock $clocks {
#        set name   [get_db $clock .hierarchical_name]
#        set icg_clock_pins [get_db pins -if .is_clock_gating_clock==true&&.clocks.hierarchical_name==$name]
#        
#        if { [llength $icg_clock_pins] == 0 } { continue }
#        
#        puts "-I- Setting clock latency on clock enable clock pins"
#        set_clock_latency -0.05 $icg_clock_pins -clock_gate -clock $name  
#    }
#}

#if { [info exists STAGE] && $STAGE == "syn" } {
#    set_db designs .lp_clock_gating_auto_path_adjust             fixed
#    set_db designs .lp_clock_gating_auto_path_adjust_fixed_delay -50
#}

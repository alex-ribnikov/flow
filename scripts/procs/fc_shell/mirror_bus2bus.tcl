proc mirror_bus2bus { b1_pattern b2_pattern direction {edge ""} {write_tcl false} } {
    # HELP - places b2_pattern pins/ports on the "edge" side according to b1_pattern's location
    
    if { [sizeof [set b1 [get_ports -quiet $b1_pattern*]]] == 0 } { set b1 [get_pins -quiet $b1_pattern*] }
    if { [sizeof [set b2 [get_ports -quiet $b2_pattern*]]] == 0 } { set b2 [get_pins -quiet $b2_pattern*] }
    
    if { [sizeof_collection $b1] != [sizeof_collection $b2] } { puts "-W- Busses have different width!" }
    if { [lsort -unique [get_attribute $b1 physical_status]] != "placed"  && [lsort -unique [get_attribute $b1 physical_status]] != "fixed" } { puts "-E- Bus 1 ports must be placed before mirroring!"; return }

    
    if { [lsort -unique [get_attribute $b1 object_class]] == "port" } {

	lassign [get_attribute [current_design ] boundary_bounding_box.ur] xh yh
	lassign [get_attribute [current_design ] boundary_bounding_box.ll] xl yl

        if { $direction == "V" || $direction == "v" } {

            set y1 [lindex [get_attribute [index $b1 0] bounding_box.center] 1]
            if { $y1 < [expr ($yh + $yl)/2] } { set side $yh } else { set side $yl }

        } elseif { $direction == "H" || $direction == "h" } {

            set x1 [lindex [get_attribute [index $b1 0] bounding_box.center] 0]
            if { $x1 < [expr ($xh + $xl)/2] } { set side $xh } else { set side $xl }

        } else {
            puts "-E- direction must be h/H or v/V!" ; return -1 
        }
        set b1_cell ""
    } else {
         
    }
    if {$write_tcl} {set fo [open "pin_constarints.tcl" w]}
    foreach_in_collection b1_port $b1 {

        set b2_port [regsub $b1_pattern [get_attribute $b1_port name]  $b2_pattern]
        set x1 [lindex [get_attribute $b1_port bounding_box.center] 0]
        set y1 [lindex [get_attribute $b1_port bounding_box.center] 1]  
        set layer [get_attribute $b1_port layer.name]    
        
        if { [get_attribute $b1_port object_class] == "port" } {
            if { $direction == "V" || $direction == "v" } {
                set b2_location [list $x1 $side]
            } elseif { $direction == "H" || $direction == "h" } {
                set b2_location [list $side $y1]
            }
        } else {   
        }
        
        
        if { [get_attribute $b1_port object_class] == "port" } {
            set edit_pin_cmd "set_individual_pin_constraints -allowed_layers $layer -location \"$b2_location\" -ports  [get_attribute $b2_port name]"
        } else {       
        }
        set line "if { \[catch { $edit_pin_cmd } res \] } { puts \"-E- Unable to place $b2_port AND [get_attribute $b1_port name]\" }"
        if {$write_tcl} {puts $fo $line} {eval $line}           
    }
   ### Placing pins ###
   if {$write_tcl} {
   	puts $fo "puts \"-I_ eval place_pins command with fast_route mode\" "
   	puts $fo "set tmp_fast_gr \[get_app_option_value -name plan.pins.fast_route\]"
   	puts $fo "set_app_options -name plan.pins.fast_route -value true"
   	puts $fo "redirect -var eval_placing_res { place_pins -ports \$b2 }"
   	puts $fo "set_app_options -name plan.pins.fast_route -value \$tmp_fast_gr"
   	puts $fo "if { \[regexp \"Error\" \$eval_placing_res\] } { 
        	puts \"-E- Errors founs during command eval\n-E- See reports/eval_errors.rpt for more details\" 
        	set fp \[open reports/eval_errors.rpt w\]
        	puts \$fp \$eval_placing_res
        	close \$fp
}"
	close $fo
	puts "-I- tcl file script pin_constarints.tcl saved"
	return

   }
   puts "-I- eval place_pins command with fast_route mode "
   set tmp_fast_gr [get_app_option_value -name plan.pins.fast_route]
   set_app_options -name plan.pins.fast_route -value true
   redirect -var eval_placing_res { place_pins -ports $b2 }
   set_app_options -name plan.pins.fast_route -value $tmp_fast_gr
   if { [regexp "Error" $eval_placing_res] } { 
        puts "-E- Errors founs during command eval\n-E- See reports/eval_errors.rpt for more details" 
        set fp [open reports/eval_errors.rpt w]
        puts $fp $eval_placing_res
        close $fp
    }
    ### Compare actual vs assigned placement ###
    echo "port1 ports2 diff" >  reports/debug_mirror_b2b.rpt
    set num_of_pairs [expr min([sizeof_collection $b1],[sizeof_collection $b2])]
    set num_of_misaligned_pairs 0
    set shorter_col [expr {[expr $num_of_pairs == [sizeof_collection $b1]] ? $b1 : $b2}]
    set shorter_col_pattern [expr {[expr $num_of_pairs == [sizeof_collection $b1]] ? $b1_pattern : $b2_pattern}]
    set longer_col_pattern [expr {[expr $num_of_pairs == [sizeof_collection $b1]] ? $b2_pattern : $b1_pattern}]

    
    foreach_in_collection port $shorter_col {

	set another_port [regsub $shorter_col_pattern [get_attribute $port name]  $longer_col_pattern]
        lassign [get_attribute $port bounding_box.center] x1 y1
	lassign [get_attribute $another_port bounding_box.center] x2 y2
	set x_diff [expr $x1 - $x2]
	set y_diff [expr $y1 - $y2]
	set diff [expr ![string compare [string toupper $direction] "H"] * $y_diff + ![string compare [string toupper $direction] "V"] * $x_diff ]        
        set is_aligned_pair [expr !$diff]
	if !$is_aligned_pair {
		incr num_of_misaligned_pairs
		puts "-W- [get_attribute $port name] and [get_attribute $another_port name]  are not aligned, diff: [expr abs($diff)]"
                echo "[get_attribute $port name] [get_attribute $another_port name] [expr abs($diff)]" >>  reports/debug_mirror_b2b.rpt
	}  
    }

    puts "-I- Out of $num_of_pairs tested, $num_of_misaligned_pairs not aligned"
    if {$num_of_misaligned_pairs} {puts "-I- report of misaligned pairs reports/debug_mirror_b2b.rpt  was saved"}
    puts "-I- End pin alignment for $b1_pattern - $b2_pattern. [::ory_time::now]"        

}



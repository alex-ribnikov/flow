
proc get_orient_by_pins {} {

	set memories [get_cells -hier -filter {is_hard_macro}]
	set r0 0
	set r180 0
	set mx 0
	set my_o 0
	foreach_in_collection mem $memories {
		set ll_x_pins [lindex [lsort -u -real [get_attribute [get_pins -of_objects $mem -filter {port_type==signal}] bounding_box.ll_x]] 0]
		set ll_x_memory [get_attribute $mem boundary_bounding_box.ll_x]
		set orient [get_attribute $mem orientation]

		if {$ll_x_memory < $ll_x_pins} {
			set pin_side "right"
		} else {
			set pin_side "left"
		}

		if {$pin_side == "left"} {
			if {$orient=="R0"||$orient=="MY"} {
				puts "Orient is R0"
				incr r0
				gui_set_highlight_options -current_color yellow
				gui_change_highlight -add -collection $mem
			} else {
				puts "Orient is MX"
				incr mx
				gui_set_highlight_options -current_color orange
				gui_change_highlight -add -collection $mem	
			}
		} else {
			if {$orient=="R0"||$orient=="MY"} {
				puts "Orient is MY"
				incr my_o
				gui_set_highlight_options -current_color red
				gui_change_highlight -add -collection $mem
			} else {
				puts "Orient is R180"
				incr r180
				gui_set_highlight_options -current_color green
				gui_change_highlight -add -collection $mem	
			}

		}
	}


	puts "R0 $r0 MX $mx MY $my_o R180 $r180"	

}


proc get_real_orient {mem} {

	set ll_x_pins [lindex [lsort -u [get_attribute [get_pins -of_objects $mem -filter {port_type==signal}] bounding_box.ll_x]] 0]
	set ll_x_memory [get_attribute $mem boundary_bounding_box.ll_x]
	set orient [get_attribute $mem orientation]

	if {$ll_x_memory < $ll_x_pins} {
		set pin_side "right"
	} else {
		set pin_side "left"
	}

	if {$pin_side == "left"} {
		if {$orient=="R0"||$orient=="MY"} {
			return "R0"
		} else {
			return "MX"
		}
	} else {
		if {$orient=="R0"||$orient=="MY"} {
			return "MY"
		} else {
			return "R180"
		}

	}

}


	define_derived_user_attribute \
	          -name real_orient \
	          -classes {cell} \
	          -type string \
	          -get_command {
			if {[get_attribute %object is_hard_macro]} {
				get_real_orient %object
			}
     		      }

define_derived_user_attribute \
	          -name is_same_orient \
	          -classes {cell} \
	          -type boolean \
	          -get_command {
			if {[get_attribute %object is_hard_macro]} {
				return [expr ![string compare [get_attribute %object real_orient] [get_attribute %object orientation]]] ;
			}
     		      }

#R0 - pins in left
#MX - pins in left
#MY - pins in right
#R180 - pins in right

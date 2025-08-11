
proc has_left_or_right_pins {mem} {

set macro_bbox_ll_x [get_attribute $mem boundary_bounding_box.ll_x ]
set macro_bbox_ur_x [get_attribute $mem boundary_bounding_box.ur_x ]

set pins [get_pins -of $mem -filter {port_type==signal}]

if {[sizeof_collection $pins] == 0} {
    return false
}

set all_pin_ll_x [get_attribute $pins bounding_box.ll_x]
set sorted_pin_ll_x [lsort -real -u $all_pin_ll_x]
set min_pin_ll_x [lindex $sorted_pin_ll_x 0]

set all_pin_ur_x [get_attribute $pins bounding_box.ur_x]
set sorted_pin_ur_x [lsort -real -decreasing -u $all_pin_ur_x]
set max_pin_ur_x [lindex $sorted_pin_ur_x 0]

set has_left_pin false
set has_right_pin false

if {$min_pin_ll_x <= $macro_bbox_ll_x} {
    set has_left_pin true
}

if {$max_pin_ur_x >= $macro_bbox_ur_x} {
    set has_right_pin true
}

if {$has_left_pin || $has_right_pin} {
    return true
} else {
    return false
}
	
}

proc has_bottom_or_top_pins {mem} {

set macro_bbox_ll_y [get_attribute $mem boundary_bounding_box.ll_y ]
set macro_bbox_ur_y [get_attribute $mem boundary_bounding_box.ur_y ]

set pins [get_pins -of $mem -filter {port_type==signal}]

if {[sizeof_collection $pins] == 0} {
    return false
}

set all_pin_ll_y [get_attribute $pins bounding_box.ll_y]
set sorted_pin_ll_y [lsort -real -u $all_pin_ll_y]
set min_pin_ll_y [lindex $sorted_pin_ll_y 0]

set all_pin_ur_y [get_attribute $pins bounding_box.ur_y]
set sorted_pin_ur_y [lsort -real -decreasing -u $all_pin_ur_y]
set max_pin_ur_y [lindex $sorted_pin_ur_y 0]

set has_bottom_pin false
set has_top_pin false

if {$min_pin_ll_y <= $macro_bbox_ll_y} {
    set has_bottom_pin true
}

if {$max_pin_ur_y >= $macro_bbox_ur_y} {
    set has_top_pin true
}

if {$has_bottom_pin || $has_top_pin} {
    return true
} else {
    return false
}
}

define_derived_user_attribute \
	  -name has_h_pins \
	  -classes {cell} \
	  -type boolean \
	  -get_command {
		if {[get_attribute %object is_hard_macro]} {
			has_left_or_right_pins	%object
		}
	      }

define_derived_user_attribute \
	  -name has_v_pins \
	  -classes {cell} \
	  -type boolean \
	  -get_command {
		if {[get_attribute %object is_hard_macro]} {
			has_bottom_or_top_pins %object 
		}
	      }


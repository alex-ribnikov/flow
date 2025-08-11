
gui_deselect -all
###X 3.876
###Y 0.84
set_db edit_wire_drc_on 0
select_routes -nets {VDD VSS} -obj_type  via
puts "[exec  date +%d%h%y_%H_%M_%S]"

	set xx 3.876
	set yy 0.84
	set top_x  [get_db designs .bbox.ur.x]
	set top_y  [get_db designs .bbox.ur.y]

			set ii 1
			while {$yy < $top_y} {
				edit_copy 0 $yy -keep_net_name
				incr ii
				set yy [expr 0.84*$ii]
			}
			
	select_routes -nets {VDD VSS} -obj_type  via	
	set xx 3.876
	set yy 0.84
	set pp 1
	set top_x  [get_db designs .bbox.ur.x]
	set top_y  [get_db designs .bbox.ur.y]

			set ii 1
			while {$xx < $top_x} {
				edit_copy $xx 0 -keep_net_name
				incr ii
				set xx [expr 3.876*$ii]
			}
			
		
puts "[exec  date +%d%h%y_%H_%M_%S]"
gui_deselect -all
if {0} {

 puts "[exec  date +%d%h%y_%H_%M_%S]"
	set xx 0
	set yy 0.84
	set pp 1
	#set top_x  [get_db designs .bbox.ur.x]
	#set top_y  [get_db designs .bbox.ur.y]
	set top_x  1890
	set top_y  2410

	while {$xx < $top_x} {
			set ii 1
			while {$yy < $top_y} {
				edit_copy $xx $yy -keep_net_name
				incr ii
				set yy [expr 0.84*$ii]
			}

			set xx [expr 3.876*$pp]
			incr pp
			set yy 0.84

	}

puts "[exec  date +%d%h%y_%H_%M_%S]"



}


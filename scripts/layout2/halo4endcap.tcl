
foreach mem [get_db insts -if {.base_cell.base_class == block && .base_cell == *M5*}] {
#set inst [get_db selected . ]
	set inst [get_db $mem .name]
	set ori [get_db $mem .orient]
	set lx [expr [get_db $mem .bbox.ll.x] + 0.8]
	set ly [expr [get_db $mem .bbox.ll.y] + 0.001]
	set lrowo [get_db [get_obj_in_area -obj_type {row} -polygons "$lx $ly"] .orient]
	set ux [expr [get_db $mem .bbox.ur.x] - 0.8]
	set uy [expr [get_db $mem .bbox.ur.y] - 0.001]
	set urowo [get_db [get_obj_in_area -obj_type {row} -polygons "$ux $uy"] .orient]

	if {$lrowo=="r0"} {set lly 0.84} else {set lly 1.05}
	if {$urowo=="r0"} {set uuy 1.05} else {set uuy 0.84}
	if {$ori=="r0" || $ori=="mx"} {set llx 1.02 ; set uux 0.51} else {set llx 0.51 ;set uux 1.02}

	create_place_halo -halo_deltas "$llx $lly $uux $uuy" -insts $inst -snap_to_site
	#create_place_halo -halo_deltas "0.9 $lly 0.51 $uuy" -insts $inst -snap_to_site -orient r0

}





#set bump_pitch_x 70
# Use 72um to match M15 stripes
#To see what would be the strategy to match bump pitch and M15 stripes spacing
set bump_size 25.92
set bump_pitch_x 40.6980
set bump_pitch_y 40
set bump_grid_offset_x [expr 5.193]
set bump_grid_offset_y [expr $bump_size/2]
set ploc_file [open out/${DESIGN_NAME}.ploc w]


set llx [get_db current_design .core_bbox.ll.x]
set lly [get_db current_design .core_bbox.ll.y]
set urx [get_db current_design .core_bbox.ur.x]
set ury [get_db current_design .core_bbox.ur.y]
set nbr_bumps_VDD 0
set nbr_bumps_VSS 0
set cy $bump_grid_offset_y

while {$cy <  $ury } {
   puts "cy = $cy ; ury = $ury"
   set i 0
   while { [expr ($i * $bump_pitch_x) + $bump_grid_offset_x] < $urx } {
	set cx [expr ($i * $bump_pitch_x) + $bump_grid_offset_x]
	set net_name [get_db [lindex [get_obj_in_area -areas "[expr $cx -1] [expr $cy - 1] [expr $cx + 1] [expr $cy +1]" -layers AP -obj_type special_wire] 0] .net.name]
    puts "cy = $cy ; cx = $cx ; net_name : $net_name"	
    if { $net_name == "" } { incr i ; continue }
	set cmd "puts \$ploc_file \"bump_${net_name}_\$nbr_bumps_$net_name $cx $cy AP $net_name\""
	eval $cmd
	
	set cmd "create_gui_text -label $net_name -layer AP -box {[expr $cx-2] [expr $cy-2] [expr $cx+2] [expr $cy+2]}"
	eval $cmd
	
	set cmd "incr nbr_bumps_$net_name"
	eval $cmd
	incr i
   }
   set cy [expr $cy + $bump_pitch_y]
}
close $ploc_file
#  delete_obj [get_db gui_texts ]

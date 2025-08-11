set cell_height_track1 0.117
set cell_height_track2 0.169
set two_cell_height_track [expr $cell_height_track1+$cell_height_track2]
set four_cell_height_track [expr $two_cell_height_track * 2]
set l 0
while {$l<=19} {
	set M${l}_pitch_track [get_attribute [get_layers M${l}] pitch]
	incr l
}
set is_first_row_flip [get_attribute [get_attribute [get_site_rows -first_row] site_array] is_first_row_flipped]

set M0_track_offset  -0.0060 ;
set M1_track_offset   0.0240 ;
set M2_track_offset   0.0195 ;
set M3_track_offset   0.011 ;
set M4_track_offset   -0.0085 ;
set M5_track_offset   -0.0240 ;
set M6_track_offset   0.0380 ;
set M7_track_offset   0.0380 ;
set M8_track_offset   0.0380 ;
set M9_track_offset   0.0380 ;
set M10_track_offset  0.0380 ;
set M11_track_offset  0.0380 ;
set M12_track_offset  0.0380 ;
set M13_track_offset  0.0380 ;
set M14_track_offset  0.0000 ;
set M15_track_offset  0.0000 ;
set M16_track_offset  0.0000 ;
set M17_track_offset  0.0000 ;
set M18_track_offset  0.0000 ;
set M19_track_offset  0.0000 ;


echo "Getting FP Info"
set core_llx_track [lindex [lindex [get_attribute [get_core_area] bbox] 0] 0]
set core_lly_track [lindex [lindex [get_attribute [get_core_area] bbox] 0] 1]
set core_urx_track [lindex [lindex [get_attribute [get_core_area] bbox] 1] 0]
set core_ury_track [lindex [lindex [get_attribute [get_core_area] bbox] 1] 1]

set die_llx_track [lindex [lindex [get_attribute [current_block] boundary_bbox] 0] 0]
set die_lly_track [lindex [lindex [get_attribute [current_block] boundary_bbox] 0] 1]
set die_urx_track [lindex [lindex [get_attribute [current_block] boundary_bbox] 1] 0]
set die_ury_track [lindex [lindex [get_attribute [current_block] boundary_bbox] 1] 1]

echo "Track Creation..."
set_attribute [get_layer M0]  routing_direction horizontal
set_attribute [get_layer M1]  routing_direction vertical
set_attribute [get_layer M2]  routing_direction horizontal
set_attribute [get_layer M3]  routing_direction vertical
set_attribute [get_layer M4]  routing_direction horizontal
set_attribute [get_layer M5]  routing_direction vertical
set_attribute [get_layer M6]  routing_direction horizontal
set_attribute [get_layer M7]  routing_direction vertical
set_attribute [get_layer M8]  routing_direction horizontal
set_attribute [get_layer M9]  routing_direction vertical
set_attribute [get_layer M10] routing_direction horizontal
set_attribute [get_layer M11] routing_direction vertical
set_attribute [get_layer M12] routing_direction horizontal
set_attribute [get_layer M13] routing_direction vertical
set_attribute [get_layer M14] routing_direction horizontal
set_attribute [get_layer M15] routing_direction vertical
set_attribute [get_layer M16] routing_direction horizontal
set_attribute [get_layer M17] routing_direction vertical
set_attribute [get_layer AP]  routing_direction horizontal

#remove_tracks -all
#########################
###  Vertical tracks  ###
##########################
echo "M1 Track Creation ..."
remove_tracks -layer M1
create_track -layer M1 -space $M1_pitch_track -dir X -offset $M1_track_offset -relative_to core_area



echo "M3 Track Creation ..."
remove_tracks -layer M3
create_track -layer M3  -space $M3_pitch_track -dir X -offset $M3_track_offset  -relative_to core_area 

echo "M5 Track Creation ..."
remove_tracks -layer M5
set first_track_color mask_two
set second_track_color mask_one

create_track -layer M5 -dir X -mask_pattern $first_track_color -space [expr 2*$M5_pitch_track]  -offset $M5_track_offset  -relative_to core_area
create_track -layer M5 -dir X -mask_pattern $second_track_color -space [expr 2*$M5_pitch_track] -offset [expr $M5_track_offset + $M5_pitch_track]  -relative_to core_area

echo "M7 Track Creation ..."
remove_tracks -layer M7
create_track -layer M7  -space $M7_pitch_track -dir X -offset $M7_track_offset  -relative_to block_boundary 


echo "M9 Track Creation ..."
remove_tracks -layer M9
create_track -layer M9  -space $M9_pitch_track -dir X -offset $M9_track_offset  -relative_to block_boundary 


echo "M11 Track Creation ..."
remove_tracks -layer M11
create_track -layer M11  -space $M11_pitch_track -dir X -offset $M11_track_offset  -relative_to block_boundary 

echo "M13 Track Creation ..."
remove_tracks -layer M13
create_track -layer M13  -space $M13_pitch_track -dir X -offset $M13_track_offset  -relative_to block_boundary

echo "M15 Track Creation ..."
remove_tracks -layer M15
create_track -layer M15  -space $M15_pitch_track -dir X -offset $M15_track_offset  -relative_to block_boundary

echo "M17 Track Creation ..."
remove_tracks -layer M17
create_track -layer M17  -space $M17_pitch_track -dir X -offset $M17_track_offset  -relative_to block_boundary

echo "M19 Track Creation ..."
remove_tracks -layer M19
create_track -layer M19  -space $M19_pitch_track -dir X -offset $M19_track_offset  -relative_to block_boundary



###########################
###  Horizontal tracks  ###
###########################

echo "M0 Track Creation ..."

    set first_track_color mask_two
    set second_track_color mask_one
remove_tracks -layer M0

create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr -0.0060] -relative_to core_area -width 0.027 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.0240]  -relative_to core_area -width 0.013 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.0470]  -relative_to core_area -width 0.013 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.0700]  -relative_to core_area -width 0.013 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.0930]  -relative_to core_area -width 0.013 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.1230]  -relative_to core_area -width 0.027 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.1535]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.1775]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.2015]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.2255]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.2495]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.2800]  -relative_to core_area -width 0.027 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.0240 + 0.286]  -relative_to core_area -width 0.013 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.0470 + 0.286]  -relative_to core_area -width 0.013 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.0700 + 0.286]  -relative_to core_area -width 0.013 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.0930 + 0.286]  -relative_to core_area -width 0.013 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.1230 + 0.286]  -relative_to core_area -width 0.027 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.1535 + 0.286]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.1775 + 0.286]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.2015 + 0.286]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $first_track_color  -space $four_cell_height_track -offset [expr 0.2255 + 0.286]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}
create_track -layer M0 -dir Y -mask_pattern $second_track_color -space $four_cell_height_track -offset [expr 0.2495 + 0.286]  -relative_to core_area -width 0.014 -end_grid_relative_to core_area -end_grid_high_offset 0.041 -end_grid_high_steps {0.0240 0.0240} -end_grid_low_offset 0.007 -end_grid_low_steps {0.0240 0.0240}


echo "M2 Track Creation ..."
remove_tracks -layer M2

    set first_track_color mask_one
    set second_track_color mask_two


create_track -layer M2 -dir Y -mask_pattern $first_track_color -space [expr 2*$M2_pitch_track] -offset $M2_track_offset   -relative_to core_area
create_track -layer M2 -dir Y -mask_pattern $second_track_color -space [expr 2*$M2_pitch_track] -offset [expr $M2_track_offset + $M2_pitch_track]  -relative_to core_area

echo "M4 Track Creation ..."
remove_tracks -layer M4
create_track -layer M4 -space $M4_pitch_track -dir Y -offset $M4_track_offset  -relative_to core_area

echo "M6 Track Creation ..."
remove_tracks -layer M6
create_track -layer M6 -space $M6_pitch_track -dir Y -offset $M6_track_offset -relative_to block_boundary

echo "M8 Track Creation ..."
remove_tracks -layer M8
create_track -layer M8 -space $M8_pitch_track -dir Y -offset $M8_track_offset -relative_to block_boundary

echo "M10 Track Creation ..."
remove_tracks -layer M10
create_track -layer M10 -space $M10_pitch_track -dir Y -offset $M10_track_offset -relative_to block_boundary

echo "M12 Track Creation ..."
remove_tracks -layer M12
create_track -layer M12 -space $M12_pitch_track -dir Y -offset $M12_track_offset -relative_to block_boundary

echo "M14 Track Creation ..."
remove_tracks -layer M14
create_track -layer M14 -space $M14_pitch_track -dir Y -offset $M14_track_offset  -relative_to block_boundary

echo "M16 Track Creation ..."
remove_tracks -layer M16
create_track -layer M16 -space $M16_pitch_track -dir Y -offset $M16_track_offset  -relative_to block_boundary


echo "M18 Track Creation ..."
remove_tracks -layer M18
create_track -layer M18 -space $M18_pitch_track -dir Y -offset $M18_track_offset  -relative_to block_boundary



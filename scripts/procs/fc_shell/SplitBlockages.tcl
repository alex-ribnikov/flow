# This script will split large partially blocked blockages into smaller ones

proc SplitBlockages {{size 50}} {

	set blockages [get_placement_blockages -filter "bounding_box.width>$size&&blockage_type!=hard"]
	foreach_in_collection blockage $blockages {
                set percent [get_attribute $blockage blocked_percentage]
                set blockage_type [get_attribute $blockage blockage_type]
                set URX [get_attribute $blockage bounding_box.ur_x]
                set URY [get_attribute $blockage bounding_box.ur_y]
                set LLX [get_attribute $blockage bounding_box.ll_x]
                set LLY [get_attribute $blockage bounding_box.ll_y]
                set new_urx [expr $LLX + $size]
                for {set new_llx $LLX} {$new_urx < $URX} {} {
                                set new_blockage [create_placement_blockage -type $blockage_type -boundary [list [list [list $new_llx $LLY] [list $new_urx $URY]]] -blocked_percentage $percent]
                                set new_urx [expr $new_urx + $size]
                                set new_llx [expr $new_llx + $size]
                }
                set new_blockage [create_placement_blockage -type $blockage_type -boundary [list [list [list $new_llx $LLY] [list $URX $URY]]] -blocked_percentage $percent]
		remove_placement_blockage $blockage
	}

	set blockages [get_placement_blockages -filter "bounding_box.height>$size&&blockage_type!=hard"]
	foreach_in_collection blockage $blockages {
                set percent [get_attribute $blockage blocked_percentage]
                set blockage_type [get_attribute $blockage blockage_type]
                set URX [get_attribute $blockage bounding_box.ur_x]
                set URY [get_attribute $blockage bounding_box.ur_y]
                set LLX [get_attribute $blockage bounding_box.ll_x]
                set LLY [get_attribute $blockage bounding_box.ll_y]
                set new_ury [expr $LLY + $size]

                for {set new_lly $LLY} {$new_ury < $URY} {} {
                                set new_blockage [create_placement_blockage -type $blockage_type -boundary [list [list [list $LLX $new_lly] [list $URX $new_ury]]] -blocked_percentage $percent]
                                set new_ury [expr $new_ury + $size]
                                set new_lly [expr $new_lly + $size]
                }
                set new_blockage [create_placement_blockage -type $blockage_type -boundary [list [list [list $LLX $new_lly] [list $URX $URY]]] -blocked_percentage $percent]
		remove_placement_blockage $blockage
	}
}

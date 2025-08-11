
proc memory_placement_checker_brcm3  {{fName memplace.tcl}} {
    if {[get_selection]==""} {
	change_selection [get_cells -hier -filter "is_hard_macro"]
    }
    if {[get_selection]!=""} {
   set fo [open $fName w]
	foreach_in_collection memory [get_selection] {
		set memory_name [get_attribute [get_cell $memory] -name full_name]
		set memory_base_name [get_attribute [get_cell $memory] -name ref_name]
		set ORI [get_attribute [get_cell $memory] -name orientation]
		set memx [get_attribute [get_cell $memory] -name width]
		set memy [get_attribute [get_cell $memory] -name height]

		set gridy 0.988
		set gridx 0.048


		if {$ORI == "R0" } {
			set MEMORY_X [lindex [get_attribute [get_cells $memory ] origin]  0]
			set MEMORY_Y [lindex [get_attribute [get_cells $memory ] origin]  1]
			set minx 0
			set miny 0
		} elseif  {$ORI == "MX" } {
			set MEMORY_X [lindex [get_attribute [get_cells $memory ] origin]  0]
			set MEMORY_Y [lindex [get_attribute [get_cells $memory ] origin]  1]
			set minx 0
			set miny $memy
		} elseif  {$ORI == "MY" } {
			set MEMORY_X [lindex [get_attribute [get_cells $memory ] origin]  0]
			set MEMORY_Y [lindex [get_attribute [get_cells $memory ] origin]  1]
			set minx $memx
			set miny 0
		} elseif  {$ORI == "R180" } {
			set MEMORY_X [lindex [get_attribute [get_cells $memory ] origin]  0]
			set MEMORY_Y [lindex [get_attribute [get_cells $memory ] origin]  1]
			set minx $memx
			set miny $memy
		}
	
	
		if {$ORI == "R0" ||$ORI == "MX"} {
		    set offset 0;#0.024
			set MXA [lindex [split [expr ($MEMORY_X-$offset)/$gridx] .] 1]
			set MYA [lindex [split [expr $MEMORY_Y/$gridy] .] 1]
		}
		if {$ORI == "R180" ||$ORI == "MY"} {
		    set offset 0 ;#-0.024
			set MXA [lindex [split [expr ($MEMORY_X+$offset)/$gridx] .] 1]
			set MYA [lindex [split [expr $MEMORY_Y/$gridy] .] 1]
		}
	
		#set MXA [lindex [split [expr $MEMORY_X/$gridx] .] 1]
		#set MYA [lindex [split [expr $MEMORY_Y/$gridy] .] 1]

		if {$MXA > 0 && $MYA > 0} {
			set ppx [lindex [split [expr $MEMORY_X/$gridx] .] 0]
			set NEWX [expr $ppx*$gridx -$minx+$offset]
			set NEWX_PLUS [expr ($ppx+1)*$gridx-$minx+$offset]
			set ppy [lindex [split [expr $MEMORY_Y/$gridy] .] 0]
			set NEWY [expr $ppy*$gridy -$miny]
			set NEWY_PLUS [expr ($ppy+1)*$gridy-$miny]
			puts $fo "### ERROR: memory $memory_name is not placed on grid"
			puts $fo "###     legal location for memory is:"
			puts $fo "       set_cell_location -coordinates {$NEWX $NEWY} $memory_name -orientation $ORI -ignore_fixed -fixed"
			puts $fo "       set_cell_location -coordinates {$NEWX $NEWY_PLUS} $memory_name -orientation $ORI -ignore_fixed -fixed"
			puts $fo "       set_cell_location -coordinates {$NEWX_PLUS $NEWY_PLUS} $memory_name -orientation $ORI -ignore_fixed -fixed"
			puts $fo "       set_cell_location -coordinates {$NEWX_PLUS $NEWY} $memory_name -orientation $ORI -ignore_fixed -fixed"
		} elseif {$MXA > 0 && $MYA == "0.0"} {
			set ppx [lindex [split [expr $MEMORY_X/$gridx] .] 0]
			set NEWX [expr $ppx*$gridx -$minx+$offset]
			set NEWX_PLUS [expr ($ppx+1)*$gridx-$minx+$offset]		
			set MY [expr $MEMORY_Y-$miny]
			puts $fo "### ERROR: memory $memory_name is not placed on grid"
			puts $fo "###     legal location for memory is:"
			puts $fo "       set_cell_location -coordinates {$NEWX $MY} $memory_name -orientation $ORI -ignore_fixed -fixed"
			puts $fo "       set_cell_location -coordinates {$NEWX_PLUS $MY} $memory_name -orientation $ORI -ignore_fixed -fixed"
		} elseif {$MXA == "0.0" && $MYA > 0} {
			set ppy [lindex [split [expr $MEMORY_Y/$gridy] .] 0]
			set NEWY [expr $ppy*$gridy -$miny]
			set NEWY_PLUS [expr ($ppy+1)*$gridy-$miny]
			set MX [expr $MEMORY_X-$minx+$offset]
			puts $fo "### ERROR: memory $memory_name is not placed on grid"
			puts $fo "###     legal location for memory is:"
			puts $fo "       set_cell_location -coordinates {$MX $NEWY} $memory_name -orientation $ORI -ignore_fixed -fixed"
			puts $fo "       set_cell_location -coordinates {$MX $NEWY_PLUS} $memory_name -orientation $ORI -ignore_fixed -fixed"					

		}
		 

	}
close $fo
if {[exec cat memplace.tcl] !=""} {
	puts "\033\[31m\033\[1m please check memplace.tcl file on your working dir \033\[0m "
} else {
	puts "\033\[32m\033\[2m memory is on grid \033\[0m "
}



} else {
       puts "\033\[31m\033\[1m please select memory \033\[0m "

}
}






	




	












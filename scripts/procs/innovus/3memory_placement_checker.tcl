
proc 3memory_placement_checker  {{fName memplace.tcl}} {
if {[get_db selected .]!=""} {
   set fo [open $fName w]
	foreach memory [get_db selected .] {
		set memory_name [get_db $memory .name]
		set memory_base_name [get_db $memory .base_cell.name]
		set ORI [get_db $memory .orient]
		set memx [get_db [get_cells $memory] .bbox.dx]
		set memy [get_db [get_cells $memory] .bbox.dy]

		if {[string match *M3SRF*BSI* $memory_base_name]} {set gridx 3.04 ; set gridy 0.572}		
		if {[string match *M3SP111* $memory_base_name]} {set gridx 1.52 ; set gridy 3.04}		
		if {[string match *M3SRF*_wrapper $memory_base_name]} {set gridx 1.52 ; set gridy 1.52}		
		if {[string match *M3PSP* $memory_base_name]} {set gridx 1.52 ; set gridy 1.52}		
		if {[string match *M3DP222* $memory_base_name]} {set gridx 1.52 ; set gridy 3.04}		

		if {$ORI == "r0" } {
			set MEMORY_X [get_db [get_cells $memory]  .bbox.ll.x]
			set MEMORY_Y [get_db [get_cells $memory]  .bbox.ll.y]
			set minx 0
			set miny 0
		} elseif  {$ORI == "mx" } {
			set MEMORY_X [get_db [get_cells $memory]  .bbox.ll.x]
			set MEMORY_Y [get_db [get_cells $memory]  .bbox.ur.y]
			set minx 0
			set miny $memy
		} elseif  {$ORI == "my" } {
			set MEMORY_X [get_db [get_cells $memory]  .bbox.ur.x]
			set MEMORY_Y [get_db [get_cells $memory]  .bbox.ll.y]
			set minx $memx
			set miny 0
		} elseif  {$ORI == "r180" } {
			set MEMORY_X [get_db [get_cells $memory]  .bbox.ur.x]
			set MEMORY_Y [get_db [get_cells $memory]  .bbox.ur.y]
			set minx $memx
			set miny $memy
		}
	
		
		set MXA [lindex [split [expr $MEMORY_X/$gridx] .] 1]
		set MYA [lindex [split [expr $MEMORY_Y/$gridy] .] 1]

		if {$MXA > 0 && $MYA > 0} {
			set ppx [lindex [split [expr $MEMORY_X/$gridx] .] 0]
			set NEWX [expr $ppx*$gridx -$minx]
			set NEWX_PLUS [expr ($ppx+1)*$gridx-$minx]
			set ppy [lindex [split [expr $MEMORY_Y/$gridy] .] 0]
			set NEWY [expr $ppy*$gridy -$miny]
			set NEWY_PLUS [expr ($ppy+1)*$gridy-$miny]
			puts $fo "### ERROR: memory $memory_name is not placed on grid"
			puts $fo "###     legal location for memory is:"
			puts $fo "       place_inst $memory_name $NEWX $NEWY $ORI"
			puts $fo "       place_inst $memory_name $NEWX $NEWY_PLUS $ORI"
			puts $fo "       place_inst $memory_name $NEWX_PLUS $NEWY_PLUS $ORI"
			puts $fo "       place_inst $memory_name $NEWX_PLUS $NEWY $ORI"
		} elseif {$MXA > 0 && $MYA == "0.0"} {
			set ppx [lindex [split [expr $MEMORY_X/$gridx] .] 0]
			set NEWX [expr $ppx*$gridx -$minx]
			set NEWX_PLUS [expr ($ppx+1)*$gridx-$minx]		
			set MY [expr $MEMORY_Y-$miny]
			puts $fo "### ERROR: memory $memory_name is not placed on grid"
			puts $fo "###     legal location for memory is:"
			puts $fo "       place_inst $memory_name $NEWX $MY $ORI"
			puts $fo "       place_inst $memory_name $NEWX_PLUS $MY $ORI"
		} elseif {$MXA == "0.0" && $MYA > 0} {
			set ppy [lindex [split [expr $MEMORY_Y/$gridy] .] 0]
			set NEWY [expr $ppy*$gridy -$miny]
			set NEWY_PLUS [expr ($ppy+1)*$gridy-$miny]
			set MX [expr $MEMORY_X-$minx]
			puts $fo "### ERROR: memory $memory_name is not placed on grid"
			puts $fo "###     legal location for memory is:"
			puts $fo "       place_inst $memory_name $MX $NEWY $ORI"
			puts $fo "       place_inst $memory_name $MX $NEWY_PLUS $ORI"					

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






	




	












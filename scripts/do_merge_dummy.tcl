default layout_cache off

set DM_FLAG 0
set DODPO_FLAG 0

set DESIGN_NAME [lindex [split [pwd] /] end-2]
set DM_DIR  [regsub pnr [pwd] dm]
set DM_FILE $DM_DIR/DM_$DESIGN_NAME.oas

set DODPO_DIR  [regsub pnr [pwd] dodpo]
set DODPO_FILE $DODPO_DIR/DODPO_$DESIGN_NAME.oas


if {[llength [glob -nocomplain $DM_FILE]] > 0} {
   puts "-I-  Dummy Metal file exists."
   set DM_FLAG 1
} else {
   puts "ERROR: missing Dummy Metal file."
}

if {[llength [glob -nocomplain $DODPO_FILE]] > 0} {
   puts "-I-  Dummy ODPO file exists."
   set DODPO_FLAG 1
} else {
   puts "ERROR: missing Dummy ODPO file."
}

if {$DM_FLAG} {
# open dummy metal layout
   puts "open Dummy Metal file $DM_FILE"
   set DM_LAYOUT [layout open  $DM_FILE DM_${DESIGN_NAME}]
   
   if {[llength [cell active]]>0 } {
#      cell edit_state 1
#       foreach cell [layout cells] {
#           puts "changes top name to DM_$DESIGN_NAME"
#           layout cell rename $cell DM_$cell -layout $DM_LAYOUT
#       }
#      cell edit_state 0
   } else {
      puts "Warning: Dummy Metal oas missing top cell"
      set DM_FLAG 0
   }
}

if {$DODPO_FLAG} {
# open dummy odpo layout
   puts "open Dummy ODPO file $DODPO_FILE"
   set DODPO_LAYOUT [layout open  $DODPO_FILE DODPO_$DESIGN_NAME]
   if {[llength [cell active]]>0 } {
#      cell edit_state 1
#      puts "changes top name to DODPO_$DESIGN_NAME"
#      layout cell rename $DESIGN_NAME DODPO_$DESIGN_NAME -layout $DODPO_LAYOUT
#      cell edit_state 0
   } else {
      puts "Warning: Dummy ODPO oas missing top cell"
      set DODPO_FLAG 0
   }
}



# open main layout

#set BLOCK_LAYOUT [layout open [pwd]/out/gds/${DESIGN_NAME}_merge.oas.gz $DESIGN_NAME]
set BLOCK_LAYOUT [layout open [pwd]/out/oas/${DESIGN_NAME}_merge.oas $DESIGN_NAME]

cell edit_state 1


layout display filter_layer_hier 1
layer show 108:0
find init -type {shape} -layer {108:0} -layout $BLOCK_LAYOUT  -cell $DESIGN_NAME

set POLYGON [lindex [table row get 1:1:1] end-2]

set PPP [string map {"\(" "" "\)" ""} $POLYGON]
set PP [list]
foreach number $PPP {
   lappend PP [expr $number * 1000]
}

#select at  0 0
#set BBOX [lindex [cell info ] end]
#set X0 [lindex $BBOX 0]
#set Y0 [lindex $BBOX 1]
#
#set X1 [lindex $BBOX 4]
#set Y1 [lindex $BBOX 5]

puts "-I-  adding DM Exclude untill M17"

layer show 150:30
for {set i 0} {$i < 18} {incr i} {
   set lll "150:[expr 30 + $i]"
   set cmd "layer configure $lll -name \"\""
   eval $cmd
   set cmd "layer active $lll"
   eval $cmd

polygon  -layer $lll $PP -layout $BLOCK_LAYOUT -cell $DESIGN_NAME

#   set cmd "cell object add rectangle {coords {$X0 $Y0 $X1 $Y1} }"
#   set cmd "cell object add polygon {coords $POLYGON }"
#   eval $cmd
}

layout display filter_layer_hier 0
layer show *

if {$DM_FLAG} {
   puts "-I- adding DM layout"
   layout reference add $DM_LAYOUT -layout $BLOCK_LAYOUT
   cell add sref DM_${DESIGN_NAME} 0 0 -layout $BLOCK_LAYOUT
}
if {$DODPO_FLAG} {
   puts "-I- adding DODPO layout"
   layout reference add $DODPO_LAYOUT -layout $BLOCK_LAYOUT
   cell add sref DODPO_${DESIGN_NAME} 0 0 -layout $BLOCK_LAYOUT
}

layout save $BLOCK_LAYOUT -format oasis  -compression 9 -rename [pwd]/out/oas/${DESIGN_NAME}.oas

puts "DONE"

exec touch .merge_done

exit

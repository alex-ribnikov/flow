proc  remove_macros_grid {} {
global grids
# to remove previos grids or constraints
if {1} {
remove_grids -all
remove_macro_constraints
set_snap_setting -default
if {[info exists grids]} {unset grids}
}
}

proc create_macros_grid {} {
global grids
global MEM_PREFIX_PATTERN
set macros [get_cells -hier -filter "is_hard_macro && ref_name=~$MEM_PREFIX_PATTERN*"]

# M4_M6 signal M7 PG pins grid
# x_step 4.56 y_step 0.988
set group_macros [get_cells -q -of_objects  [get_pins -of $macros -filter {(port_type==power||port_type==ground)&&layer.name==M7}]]
set group_macros [get_cells -q -of_objects  [get_pins -q -of $group_macros -filter {port_type==signal&&(layer.name==M6||layer.name==M4)}]]
if {[sizeof $group_macros]} {
create_grid -type user -x_step  4.56 -y_step 0.988 macros2PG_M4_M6_M7_grid
set_snap_setting -class macro_cell -snap user -user_grid macros2PG_M4_M6_M7_grid
set_macro_constraints $group_macros -alignment_grid macros2PG_M4_M6_M7_grid
set_fixed_objects -unfix $group_macros
snap_objects $group_macros
set_snap_setting -default
set macros [remove_from_collection $macros $group_macros]
set grids(macros2PG_M4_M6_M7_grid) [get_attribute $group_macros full_name]
}

# M4_M6 signal M6 PG pins grid
# x_step 0.048 y_step 0.988
set group_macros [get_cells -q -of_objects  [get_pins -of $macros -filter {(port_type==power||port_type==ground)&&layer.name==M6}]]
set group_macros [get_cells -q -of_objects  [get_pins -q -of $group_macros -filter {port_type==signal&&(layer.name==M6||layer.name==M4)}]]
if {[sizeof $group_macros]} {
create_grid -type user -x_step  0.048 -y_step 0.988 macros2PG_M4_M6_M6_grid
set_snap_setting -class macro_cell -snap user -user_grid macros2PG_M4_M6_M6_grid
set_macro_constraints $group_macros -alignment_grid macros2PG_M4_M6_M6_grid
set_fixed_objects -unfix $group_macros
snap_objects $group_macros
set_snap_setting -default
set macros [remove_from_collection $macros $group_macros]
set grids(macros2PG_M4_M6_M6_grid) [get_attribute $group_macros full_name]
}
 
# remaining macros - not associated with any grid
set group_macros $macros
if {[sizeof $group_macros]} {
puts "-W- the following macros are not associated with any grid:"
puts [join [get_attribute $group_macros full_name] "\n"]
}
}

proc report_macros_grid {} {
global grids
foreach_in_collection grid [get_grids] {
set name [get_attribute $grid name]
set x_step [get_attribute $grid x_step]
set y_step [get_attribute $grid y_step]
set macros $grids($name)
puts "grid: $name"
puts "num macros: [llength $macros]"
puts "step in X direction: $x_step"
puts "step in Y direction: $y_step"
set badOnesX [lmap m $macros { set macro [get_cells $m]; set x [lindex [get_attribute $macro origin] 0]; set check [format "%.4f" [expr $x / $x_step * $x_step]];  expr {[expr ($check-$x)] ? "[get_attribute $macro name] $x $check " : [continue] } } ]
set badOnesY [lmap m $macros { set macro [get_cells $m]; set y [lindex [get_attribute $macro origin] 1]; set check [format "%.4f" [expr $y / $y_step * $y_step]];  expr {[expr ($check-$y)] ? "[get_attribute $macro name] $y $check" : [continue] } } ]
puts "num violated x:[llength $badOnesX]"
if {[llength $badOnesX]} {puts [join $badOnesX "\n"]}
puts "num violated y:[llength $badOnesY]"
if {[llength $badOnesY]} {puts [join $badOnesY "\n"]}
puts "\n"
}
}

proc define_fp_spacing_rules {} {
# spacing rules definitions moved to setup file
global H_MIN_SR
global H_SR
global V_MIN_SR
global V_SR
set H_MAX_MIN_SR [expr $H_MIN_SR * 2]
set V_MAX_MIN_SR [expr $V_MIN_SR * 2]
set delta 0.001
set min_H_forbid_range [expr $H_MAX_MIN_SR + $delta]
set max_H_forbid_range [expr $H_SR - $delta]
set min_V_forbid_range [expr $V_MAX_MIN_SR + $delta]
set max_V_forbid_range [expr $V_SR - $delta]

remove_floorplan_rules -all

set macross [get_cells -hier -filter {is_hard_macro&&ref_name =~ M3*&&defined(is_same_orient)}]
set same_h [lsort -u [get_attribute [filter_collection $macross is_same_orient&&has_h_pins] ref_name]]
set same_not_h [lsort -u [get_attribute [filter_collection $macross is_same_orient&&!has_h_pins] ref_name]]
set diff_h [lsort -u [get_attribute [filter_collection $macross !is_same_orient&&has_h_pins] ref_name]]
set diff_not_h [lsort -u [get_attribute [filter_collection $macross !is_same_orient&&!has_h_pins] ref_name]]
set same_v [lsort -u [get_attribute [filter_collection $macross is_same_orient&&has_v_pins] ref_name]]
set same_not_v [lsort -u [get_attribute [filter_collection $macross is_same_orient&&!has_v_pins] ref_name]]
set diff_v [lsort -u [get_attribute [filter_collection $macross !is_same_orient&&has_v_pins] ref_name]]
set diff_not_v [lsort -u [get_attribute [filter_collection $macross !is_same_orient&&!has_v_pins] ref_name]]

set ol [list R0 R180 MX MY]
set ll [list]
foreach o $ol {
 foreach l $ol {
  lappend ll "$o $l"
 }
}

### Horizontal Rules ###
# 1
if {[llength $same_not_h]||[llength $diff_not_h]} {

set cmd "set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_1 -no_overlap_policy true \
-valid_list $H_MIN_SR -min  $H_MIN_SR -forbidden_ranges {{$min_H_forbid_range $max_H_forbid_range}} \
-from_lib_cells \[get_lib_cells \" \$same_not_h \$diff_not_h \"  \] -to_lib_cells \[get_lib_cells \"\$same_not_h \$diff_not_h\" \] -identical \
-orientation_pairs \$ll"

eval $cmd
}
# 2
if {[llength $diff_h]&&[llength $same_h]} {

set cmd "set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_2 -no_overlap_policy true \
-valid_list $H_MIN_SR -min  $H_MIN_SR -forbidden_ranges {{$min_H_forbid_range $max_H_forbid_range}} \
-from_lib_cells \$diff_h -to_lib_cells \$same_h -identical \
-orientation_pairs {{MY MY} {MY R180} {R180 MY} {R180 R180}}"

eval $cmd

set lt $ll
foreach o {{MY MY} {MY R180} {R180 MY} {R180 R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_10 -no_overlap_policy true \
-valid_list $H_SR -min  $H_SR \
-from_lib_cells $diff_h -to_lib_cells $same_h -identical \
-orientation_pairs $lt

}
# 3
if {[llength $diff_h]&&([llength $same_not_h]||[llength $diff_not_h])} {

set cmd "set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_3 -no_overlap_policy true \
-valid_list $H_MIN_SR -min  $H_MIN_SR -forbidden_ranges {{$min_H_forbid_range $max_H_forbid_range}} \
-from_lib_cells \$diff_h -to_lib_cells \[get_lib_cells \"\$same_not_h \$diff_not_h \"\] -identical \
-orientation_pairs {{MY R0} {MY MY} {MY MX} {MY R180} {R180 R0} {R180 MY} {R180 MX} {R180 R180}}"

eval $cmd

set lt $ll
foreach o {{MY R0} {MY MY} {MY MX} {MY R180} {R180 R0} {R180 MY} {R180 MX} {R180 R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_11 -no_overlap_policy true \
-valid_list $H_SR -min  $H_SR \
-from_lib_cells $diff_h -to_lib_cells [get_lib_cells " $same_not_h $diff_not_h" ] -identical \
-orientation_pairs $lt
}
# 4
if {[llength $diff_h]} {

set cmd "set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_4 -no_overlap_policy true \
-valid_list $H_MIN_SR -min  $H_MIN_SR -forbidden_ranges {{$min_H_forbid_range $max_H_forbid_range}} \
-from_lib_cells \$diff_h -to_lib_cells \$diff_h -identical \
-orientation_pairs {{MY R0} {R180 R0} {MY MX} {R180 MX}}"

eval $cmd

set lt $ll
foreach o {{MY R0} {R180 R0} {MY MX} {R180 MX}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_12 -no_overlap_policy true \
-valid_list $H_SR -min  $H_SR \
-from_lib_cells $diff_h -to_lib_cells $diff_h -identical \
-orientation_pairs $lt
}
# 5
if {([llength $same_not_h]||[llength $diff_not_h])&&[llength $same_h]} {

set cmd "set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_5 -no_overlap_policy true \
-valid_list $H_MIN_SR -min  $H_MIN_SR -forbidden_ranges {{$min_H_forbid_range $max_H_forbid_range}} \
-from_lib_cells \[get_lib_cells \"\$same_not_h \$diff_not_h\"  \] -to_lib_cells \$same_h ] -identical \
-orientation_pairs {{R0 MY} {MY MY} {MX MY} {R180 MY} {R0 R180} {MY R180} {MX R180} {R180 R180}}"

eval $cmd

set lt $ll
foreach o {{R0 MY} {MY MY} {MX MY} {R180 MY} {R0 R180} {MY R180} {MX R180} {R180 R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_13 -no_overlap_policy true \
-valid_list $H_SR -min  $H_SR \
-from_lib_cells [get_lib_cells "$same_not_h $diff_not_h"  ] -to_lib_cells $same_h -identical \
-orientation_pairs $lt

}
# 6
if {[llength $same_h]} {

set cmd "set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_6 -no_overlap_policy true \
-valid_list $H_MIN_SR -min  $H_MIN_SR -forbidden_ranges {{$min_H_forbid_range $max_H_forbid_range}} \
-from_lib_cells \$same_h -to_lib_cells \$same_h -identical \
-orientation_pairs {{R0 MY} {R0 R180} {MX MY} {MX R180}}"

eval $cmd

set lt $ll
foreach o {{R0 MY} {R0 R180} {MX MY} {MX R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_14 -no_overlap_policy true \
-valid_list $H_SR -min  $H_SR \
-from_lib_cells $same_h -to_lib_cells $same_h -identical \
-orientation_pairs $lt

}
# 7
if {([llength $same_not_h]||[llength $diff_not_h])&&[llength $diff_h]} {

set cmd "set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_7 -no_overlap_policy true \
-valid_list $H_MIN_SR -min  $H_MIN_SR -forbidden_ranges {{$min_H_forbid_range $max_H_forbid_range}} \
-from_lib_cells \[get_lib_cells \"\$same_not_h \$diff_not_h\"  \] -to_lib_cells \$diff_h -identical \
-orientation_pairs {{R0 R0} {MY R0} {MX R0} {R180 R0} {R0 MX} {MY MX} {MX MX} {R180 MX}}"

eval $cmd

set lt $ll
foreach o {{R0 R0} {MY R0} {MX R0} {R180 R0} {R0 MX} {MY MX} {MX MX} {R180 MX}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_15 -no_overlap_policy true \
-valid_list $H_SR -min  $H_SR \
-from_lib_cells [get_lib_cells "$same_not_h $diff_not_h" ] -to_lib_cells $diff_h -identical \
-orientation_pairs $lt

}
# 8
if {[llength $same_h]&&[llength $diff_h]} {

set cmd "set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_8 -no_overlap_policy true \
-valid_list $H_MIN_SR -min  $H_MIN_SR -forbidden_ranges {{$min_H_forbid_range $max_H_forbid_range}} \
-from_lib_cells \$same_h -to_lib_cells \$diff_h -identical \
-orientation_pairs {{R0 R0} {R0 MX} {MX R0} {MX MX}}"

eval $cmd

set lt $ll
foreach o {{R0 R0} {R0 MX} {MX R0} {MX MX}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_16 -no_overlap_policy true \
-valid_list $H_SR -min  $H_SR \
-from_lib_cells $same_h -to_lib_cells $diff_h -identical \
-orientation_pairs $lt

}
# 9
if {[llength $same_h]&&([llength $same_not_h]||[llength $diff_not_h])} {

set cmd "set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_9 -no_overlap_policy true \
-valid_list $H_MIN_SR -min  $H_MIN_SR -forbidden_ranges {{$min_H_forbid_range $max_H_forbid_range}} \
-from_lib_cells \$same_h -to_lib_cells \[get_lib_cells \"\$same_not_h \$diff_not_h\" \] -identical \
-orientation_pairs {{R0 R0} {R0 MY} {R0 MX} {R0 R180} {MX R0} {MX MY} {MX MX} {MX R180}}"

eval $cmd

set lt $ll
foreach o {{R0 R0} {R0 MY} {R0 MX} {R0 R180} {MX R0} {MX MY} {MX MX} {MX R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions horizontal -name m2m_h_consolidated_rule_17 -no_overlap_policy true \
-valid_list $H_SR -min  $H_SR \
-from_lib_cells $same_h -to_lib_cells [get_lib_cells "$same_not_h $diff_not_h" ] -identical \
-orientation_pairs $lt

}
### Vertical Rules ###
# 1
if {[llength $same_not_v]||[llength $diff_not_v]} {

set cmd "set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_1 -no_overlap_policy true \
-valid_list $V_MIN_SR -min  $V_MIN_SR -forbidden_ranges {{$min_V_forbid_range $max_V_forbid_range}} \
-from_lib_cells \[get_lib_cells \"\$same_not_v \$diff_not_v\"  \] -to_lib_cells \[get_lib_cells \"\$same_not_v \$diff_not_v\" \] -identical \
-orientation_pairs \$ll"

eval $cmd
}
# 2
if {[llength $diff_v]&&[llength $same_v]} {

set cmd "set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_2 -no_overlap_policy true \
-valid_list $V_MIN_SR -min  $V_MIN_SR -forbidden_ranges {{$min_V_forbid_range $max_V_forbid_range}} \
-from_lib_cells \$diff_v -to_lib_cells \$same_v -identical \
-orientation_pairs {{MY MX} {MY R180} {R0 MX} {R0 R180}}"

eval $cmd

set lt $ll
foreach o {{MY MX} {MY R180} {R0 MX} {R0 R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_10 -no_overlap_policy true \
-valid_list $V_SR -min  $V_SR \
-from_lib_cells $diff_v -to_lib_cells $same_v -identical \
-orientation_pairs $lt

}
# 3
if {[llength $diff_v]&&([llength $same_not_v]||[llength $diff_not_v])} {

set cmd "set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_3 -no_overlap_policy true \
-valid_list $V_MIN_SR -min  $V_MIN_SR -forbidden_ranges {{$min_V_forbid_range $max_V_forbid_range}} \
-from_lib_cells \$diff_v -to_lib_cells \[get_lib_cells \"\$same_not_v \$diff_not_v\" \] -identical \
-orientation_pairs {{MY R0} {MY MX} {MY MY} {MY R180} {R0 R0} {R0 MX} {R0 MY} {R0 R180}}"

eval $cmd

set lt $ll
foreach o {{MY R0} {MY MX} {MY MY} {MY R180} {R0 R0} {R0 MX} {R0 MY} {R0 R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_11 -no_overlap_policy true \
-valid_list $V_SR -min  $V_SR \
-from_lib_cells $diff_v -to_lib_cells [get_lib_cells "$same_not_v $diff_not_v" ] -identical \
-orientation_pairs $lt
}
# 4
if {[llength $diff_v]} {
set cmd "set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_4 -no_overlap_policy true \
-valid_list $V_MIN_SR -min  $V_MIN_SR -forbidden_ranges {{$min_V_forbid_range $max_V_forbid_range}} \
-from_lib_cells \$diff_v -to_lib_cells \$diff_v -identical \
-orientation_pairs {{MY R180} {MY MX} {R0 R180} {R0 MX}}"

eval $cmd

set lt $ll
foreach o {{MY R180} {MY MX} {R0 R180} {R0 MX}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_12 -no_overlap_policy true \
-valid_list $V_SR -min  $V_SR \
-from_lib_cells $diff_v -to_lib_cells $diff_v -identical \
-orientation_pairs $lt
}
# 5
if {([llength $same_not_v]||[llength $diff_not_v])&&[llength $same_v]} {

set cmd "set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_5 -no_overlap_policy true \
-valid_list $V_MIN_SR -min  $V_MIN_SR -forbidden_ranges {{$min_V_forbid_range $max_V_forbid_range}} \
-from_lib_cells \[get_lib_cells \"\$same_not_v \$diff_not_v\"  \] -to_lib_cells \$same_v ] -identical \
-orientation_pairs {{R0 MX} {MX MX} {MY MX} {R180 MX} {R0 R180} {MX R180} {MY R180} {R180 R180}}"

eval $cmd

set lt $ll
foreach o {{R0 MX} {MX MX} {MY MX} {R180 MX} {R0 R180} {MX R180} {MY R180} {R180 R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_13 -no_overlap_policy true \
-valid_list $V_SR -min  $V_SR \
-from_lib_cells [get_lib_cells "$same_not_v $diff_not_v"  ] -to_lib_cells $same_v -identical \
-orientation_pairs $lt

}
# 6
if {[llength $same_v]} {

set cmd "set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_6 -no_overlap_policy true \
-valid_list $V_MIN_SR -min  $V_MIN_SR -forbidden_ranges {{$min_V_forbid_range $max_V_forbid_range}} \
-from_lib_cells \$same_v -to_lib_cells \$same_v -identical \
-orientation_pairs {{R0 MX} {R0 R180} {MY MX} {MY R180}}"

eval $cmd

set lt $ll
foreach o {{R0 MX} {R0 R180} {MY MX} {MY R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_14 -no_overlap_policy true \
-valid_list $V_SR -min  $V_SR \
-from_lib_cells $same_v -to_lib_cells $same_v -identical \
-orientation_pairs $lt

}
# 7
if {[llength $same_v]&&([llength $same_not_v]||[llength $diff_not_v])} {
set cmd "set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_7 -no_overlap_policy true \
-valid_list $V_MIN_SR -min  $V_MIN_SR -forbidden_ranges {{$min_V_forbid_range $max_V_forbid_range}} \
-from_lib_cells \$same_v -to_lib_cells \[get_lib_cells \"\$same_not_v \$diff_not_v\"  \] -identical \
-orientation_pairs {{R0 R0} {R0 MX} {R0 MY} {R0 R180} {MY R0} {MY MX} {MY MY} {MY R180}}"

eval $cmd

set lt $ll
foreach o {{R0 R0} {R0 MX} {R0 MY} {R0 R180} {MY R0} {MY MX} {MY MY} {MY R180}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_15 -no_overlap_policy true \
-valid_list $V_SR -min  $V_SR \
-from_lib_cells  $same_v -to_lib_cells [get_lib_cells "$same_not_v $diff_not_v" ] -identical \
-orientation_pairs $lt

}
# 8
if {([llength $same_not_v]||[llength $diff_not_v])&&[llength $diff_v]} {
set cmd "set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_8 -no_overlap_policy true \
-valid_list $V_MIN_SR -min  $V_MIN_SR -forbidden_ranges {{$min_V_forbid_range $max_V_forbid_range}} \
-from_lib_cells \[ get_lib_cells \"\$same_not_v \$diff_not_v\"\] -to_lib_cells \$diff_v -identical \
-orientation_pairs {{R0 R180} {MX R180} {MY R180} {R180 R180} {R0 MX} {MX MX} {MY MX} {R180 MX}}"

eval $cmd

set lt $ll
foreach o {{R0 R180} {MX R180} {MY R180} {R180 R180} {R0 MX} {MX MX} {MY MX} {R180 MX}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_16 -no_overlap_policy true \
-valid_list $V_SR -min  $V_SR \
-from_lib_cells [get_lib_cells "$same_not_v $diff_not_v" ] -to_lib_cells $diff_v -identical \
-orientation_pairs $lt

}
# 9
if {[llength $same_v]&&[llength $diff_v]} {
set cmd "set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_9 -no_overlap_policy true \
-valid_list $V_MIN_SR -min  $V_MIN_SR -forbidden_ranges {{$min_V_forbid_range $max_V_forbid_range}} \
-from_lib_cells \$same_v -to_lib_cells \$diff_v -identical \
-orientation_pairs {{R0 R180} {R0 MX} {MY R180} {MY MX}}"

eval $cmd

set lt $ll
foreach o {{R0 R180} {R0 MX} {MY R180} {MY MX}} {
 set cmd "lreplace \$lt [lsearch $lt $o] [lsearch $lt $o]"
 set lt [eval $cmd]
}

set_floorplan_spacing_rules -directions vertical -name m2m_v_consolidated_rule_17 -no_overlap_policy true \
-valid_list $V_SR -min  $V_SR \
-from_lib_cells $same_v -to_lib_cells $diff_v -identical \
-orientation_pairs $lt

}
}


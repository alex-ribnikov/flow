delete_routes -type special -layer {M0 VIA0 M1 VIA1 M2 VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}

#######################
# Variable definition #
#######################
set tile_height [get_db site:$DEFAULT_SITE .size.y]
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 8} { set M7_pin 1 } else { set M7_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 9} { set M8_pin 1 } else { set M8_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 10} { set M9_pin 1 } else { set M9_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 11} { set M10_pin 1 } else { set M10_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 12} { set M11_pin 1 } else { set M11_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 13} { set M12_pin 1 } else { set M12_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 14} { set M13_pin 1 } else { set M13_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 15} { set M14_pin 1 } else { set M14_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 16} { set M15_pin 1 } else { set M15_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 17} { set M16_pin 1 } else { set M16_pin 0 }
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 18} { set M17_pin 1 } else { set M17_pin 0 }

#get all pins pitch from tech :
set M1_pitch  [get_db layer:M1 .pitch_y]
set M2_pitch  [get_db layer:M2 .pitch_x]
set M3_pitch  [get_db layer:M3 .pitch_y]
set M4_pitch  [get_db layer:M4 .pitch_x]
set M5_pitch  [get_db layer:M5 .pitch_y]
set M6_pitch  [get_db layer:M6 .pitch_x]
set M7_pitch  [get_db layer:M7 .pitch_y]
set M8_pitch  [get_db layer:M8 .pitch_x]
set M9_pitch  [get_db layer:M9 .pitch_y]
set M10_pitch [get_db layer:M10 .pitch_x]
set M11_pitch [get_db layer:M11 .pitch_y]
set M12_pitch [get_db layer:M12 .pitch_x]
set M13_pitch [get_db layer:M13 .pitch_y]
set M14_pitch [get_db layer:M14 .pitch_x]
set M15_pitch [get_db layer:M15 .pitch_y]
set M16_pitch [get_db layer:M16 .pitch_x]
set M17_pitch [get_db layer:M17 .pitch_y]




set M0_width                [expr [get_db layer:M0 .width]*4]
set M1_width                [get_db layer:M1 .width]
set M2_width                [get_db layer:M2 .width]
set M3_width                [get_db layer:M3 .width]
set M4_width                [get_db layer:M4 .width]
set M5_width                [get_db layer:M5 .width]
set M6_width                [get_db layer:M6 .width]
set M7_width                [get_db layer:M7 .width]
set M8_width                [get_db layer:M8 .width]
set M9_width                [expr [get_db layer:M9 .width]*1]
set M10_width               [expr [get_db layer:M10 .width]*1]
set M11_width               [expr [get_db layer:M11 .width]*1]
set M12_width               0.188
set M13_width               0.156
set M14_width		    [expr [get_db layer:M14 .width]*3]
set M15_width		    0.45
set M16_width		    1.26
set M17_width		    3.6

set M4_width_mem               0.10
set M5_width_mem               0.196
set M6_width_mem               0.196
set M7_width_mem               0.196
set M8_width_mem               0.196
set M9_width_mem               0.196
set M10_width_mem              0.196 

set M1_min_space    [expr $M1_pitch-$M1_width]
set M2_min_space    [expr $M2_pitch-$M2_width]
set M3_min_space    [expr $M3_pitch-$M3_width]
set M4_min_space    [expr $M4_pitch-$M4_width]
set M5_min_space    [expr $M5_pitch-$M5_width]
set M6_min_space    [expr $M6_pitch-$M6_width]
set M7_min_space    [expr $M7_pitch-$M7_width]
set M8_min_space    [expr $M8_pitch-$M8_width]
set M9_min_space    [expr $M9_pitch-$M9_width]
set M10_min_space   [expr $M10_pitch-$M10_width]
set M11_min_space   [expr $M11_pitch-$M11_width]
#set M12_min_space   [expr $M12_pitch-$M12_width]
set M12_min_space   0.09
set M13_min_space   0.09
set M14_min_space   0.126
set M15_min_space   0.171
set M16_min_space   0.45
set M17_min_space   0.45

set VIA0_master VIA01_big_BW20_UW20
set VIA1_master VIA12_1cut_BW20_UW20
set VIA2_master VIA23_1cut_BW20_UW20
set VIA3_master VIA34_1cut_BW20_UW20
#set VIA4_master VIA45_1cut_BW22_UW38
#set VIA3_master VIA34_1cut_BW20_UW24
#set VIA4_master VIA45_1cut_BW24_UW38
#set VIA5_master VIA56_1cut_BW38_UW38
set VIA4_master VIA45_1cut_BW20_UW38_ISO
set VIA5_master VIA56_1cut_BW38_UW38_ISO
set VIA6_master VIA67_1cut_BW38_UW38_ISO
set VIA7_master VIA78_1cut_BW38_UW38_ISO
set VIA8_master VIA89_1cut_BW38_UW38_ISO
set VIA9_master VIA910_1cut_BW38_UW38_ISO
#set VIA6_master generated
#set VIA7_master generated
#set VIA8_master generated
#set VIA9_master generated
set VIA10_master VIA1011_1cut_BW38_UW76_ISO 
set VIA11_master generated 
set VIA12_master generated
set VIA13_master generated
set VIA14_master generated
#set VIA11_master VIAGEN1112

set die2coreOffset_x        0.228
set die2coreOffset_y        0.240

# margins to edge for Mx bounding box:
# set PG_x_margin             0
# set PG_y_margin             [expr $tile_height/2]
# set PG_bbox                 "[expr [get_db current_design .bbox.ll.x] + $PG_x_margin] [expr [get_db current_design .bbox.ll.y] + $PG_y_margin] [expr [get_db current_design .bbox.ur.x] - $PG_x_margin] [expr [get_db current_design .bbox.ur.y] - $PG_y_margin]"



#M1:  must follow mask 1

set M1_set2set_dist         [expr 66*$M1_pitch]
set M1_offset               [expr (7*$M1_pitch) + 0.0085 -$M1_width/2]
set M1_spacing              "[expr (5*$M1_pitch)] [expr (29*$M1_pitch)] [expr (5*$M1_pitch)]"
set M1_stappling    ""


#M2:
set M2_set2set_dist   	[expr 2*$tile_height + 0*$M2_pitch]
set M2_offset          	[expr 1*$tile_height + 6*$M2_pitch + 1*$M2_width/2]
set M2_stappling   	"-stapling {0.238 M1}"
set M2_spacing    	"[expr $M2_min_space + 5*$M2_pitch ]"


#M3:
#set M3_set2set_dist         [expr 54*$M3_pitch]
#set M3_spacing              "[expr 4*$M3_pitch-$M3_min_space] [expr 25*$M3_pitch-$M3_min_space] [expr 4*$M3_pitch-$M3_min_space]"
set M3_set2set_dist         2.244
set M3_spacing              "[expr 4*$M3_pitch-$M3_min_space] [expr 25*$M3_pitch-$M3_min_space] [expr 4*$M3_pitch-$M3_min_space]"
set M3_offset               [expr $M1_offset + 0*$M3_pitch]
set M3_stapling             ""

#M4:
set M4_set2set_dist         [expr 19*$M4_pitch]
set M4_offset               [expr $M2_offset]
#set M4_spacing              "[expr $M4_min_space + $M4_set2set_dist/2 + -2*$M4_pitch ]"
set M4_spacing              "[expr $M4_min_space + 2*$M4_pitch ] [expr $M4_min_space + 0*$M4_pitch ] [expr $M4_min_space + 2*$M4_pitch ] "
set M4_stapling             "-stapling {0.5 M3}"

#M4_mem:
set M4_set2set_dist_mem         [expr 24*$M4_pitch]
set M4_offset_mem               [expr  3*$M4_pitch]
set M4_spacing_mem              "0.384"

#M5:
#set M5_set2set_dist         [expr 31*$M5_pitch]
#set M5_spacing               "[expr 16*$M5_pitch - $M5_min_space]"
set M5_set2set_dist         2.245
set M5_spacing               1.128
set M5_offset               [expr $M1_offset + 0*$M5_pitch]
set M5_stapling             ""
#set M5_stapling             "-stapling {0.4 M4}"

#M5_mem:
set M5_set2set_dist_mem         [expr 33*$M5_pitch]
set M5_spacing_mem              "0.966"
set M5_offset_mem               [expr 3*$M5_pitch]


#M6:
set M6_set2set_dist         [expr 0.76 + $M6_pitch]
set M6_offset               $M4_offset
set M6_spacing              $M6_min_space
if {$MAX_ROUTING_LAYER == 7} {
  set M6_stapling             ""
  set M6_spacing              $M6_min_space
  set M6_nets                 "VSS VDD"
} else {
  set M6_stapling             "-stapling {0.395 M5}"
  set M6_spacing              "[expr $M6_min_space +$M6_pitch] [expr 3*$M6_pitch - $M6_min_space]  [expr $M6_min_space +$M6_pitch]"
  set M6_nets                 {VSS VSS VDD VDD }
}

#M6_mem:
set M6_set2set_dist_mem         [expr 33*$M6_pitch]
set M6_spacing_mem              "0.966"
set M6_offset_mem               [expr 3*$M6_pitch]

#M7:
#set M7_set2set_dist         [expr 14*$M7_pitch]
set M7_set2set_dist         2.245
set M7_spacing              1.166
set M7_offset               [expr 3*$M7_pitch]
if {$MAX_ROUTING_LAYER == 8} {
  set M7_stapling             ""
} else {
  set M7_stapling             "-stapling {0.395 M6}"
}
#M7_mem:
set M7_set2set_dist_mem         [expr 31*$M7_pitch]
set M7_spacing_mem              "0.966"
set M7_offset_mem               [expr 1*$M7_pitch]

#M8:
#set M8_set2set_dist         $M4_set2set_dist
#set M8_offset               [expr $M4_offset - 0*$M8_pitch ]
set M8_set2set_dist         0.836
set M8_offset               0.44
if {$MAX_ROUTING_LAYER == 9} {
  set M8_stapling             ""
  set M8_spacing              [expr $M8_min_space + 4*$M8_pitch]
  set M8_nets                 "VSS VDD"
} else {
  set M8_stapling             "-stapling {0.395 M7}"
  set M8_spacing              "[expr $M8_min_space +$M8_pitch] [expr 3*$M8_pitch - $M8_min_space]  [expr $M8_min_space +$M8_pitch]"
  set M8_nets                 {VSS VSS VDD VDD }
}



#M8_mem:
set M8_set2set_dist_mem         [expr 33*$M8_pitch]
set M8_spacing_mem              "0.966"
set M8_offset_mem               [expr 3*$M8_pitch]

#M9:
#set M9_set2set_dist         [expr 14*$M9_pitch]
#set M9_spacing              "[expr $M9_min_space + 0*$M9_pitch] "
set M9_set2set_dist         2.245
set M9_spacing              1.116
set M9_offset               [expr 3*$M9_pitch]
if {$MAX_ROUTING_LAYER == 10} {
   set M9_stapling   ""
} else {
   set M9_stapling   "-stapling {0.395 M8}"
}

#M9_mem:
set M9_set2set_dist_mem         [expr 33*$M9_pitch]
set M9_spacing_mem              "0.966"
set M9_offset_mem               [expr 3*$M9_pitch]

#M10:
set M10_set2set_dist         $M8_set2set_dist
set M10_offset               $M8_offset
set M10_spacing              "[expr $M10_min_space + 0*$M10_pitch]"
if {$MAX_ROUTING_LAYER == 11} {
  set M10_stapling   ""
  set M10_spacing              [expr $M10_min_space + 4*$M10_pitch]
  set M10_nets                 "VSS VDD"
} else {
  set M10_stapling   		"-stapling {0.395 M9}"
  set M10_spacing               "[expr $M10_min_space + $M10_pitch] [expr 2*$M10_pitch + $M10_min_space]  [expr $M10_min_space +$M10_pitch]"
  set M10_nets                  {VSS VSS VDD VDD }
}

#M10_mem:
set M10_set2set_dist_mem        [expr 33*$M10_pitch ]
set M10_offset_mem              0.966
set M10_spacing_mem             [expr 3*$M10_pitch]

#M11:
set M11_set2set_dist         $M9_set2set_dist
set M11_offset               $M9_offset
set M11_spacing              [expr $M9_spacing -$M11_pitch ]
set M11_stapling   ""


#M12:
set M12_set2set_dist        [expr 11*$M12_pitch]
set M12_offset              [expr 2*$M12_pitch - $M12_width/2 + 0.032]
set M12_spacing             "[expr $M12_min_space + 0*$M12_pitch]"
set M12_stapling   ""


#M13:
set M13_set2set_dist        [expr 12*$M13_pitch]
set M13_offset              [expr 4*$M13_pitch - $M13_width/2]
set M13_spacing             "$M13_min_space"

#M14:
set M14_set2set_dist	    [expr 11*$M14_pitch]
set M14_offset  	    [expr 3*$M14_pitch - $M14_width/2]
set M14_spacing 	    0.189

#M15:
set M15_set2set_dist	    [expr 11*$M15_pitch]
set M15_offset  	    [expr 3*$M15_pitch - $M15_width/2]
set M15_spacing 	    0.189
#M16:
set M16_offset  	    [expr 3*$M16_pitch - $M16_width/2]
set M16_spacing 	    0.45
set M16_set2set_dist	    [expr $M16_width*2+$M16_spacing*2 + 0.629]       ; # nead to be 80% utilization or less

#M17:
set M17_offset  	    0.1
set M17_spacing 	    0.585
set M17_set2set_dist	    [expr $M17_width*2+$M17_spacing*2 + 0.629]       ; # nead to be 80% utilization or less



#########################
# Create temp blockages # 
#########################
# Over Macros
foreach inst_dpo [get_db insts -if {.base_cell.base_class == block}] {
  create_route_blockage -rects [join [get_computed_shapes [get_db $inst_dpo .bbox] SIZE 0.465]] -layers {M1 M2 M3 M4 M5 M6 M7 M8 M9 VIA0 VIA1 VIA2 VIA3 VIA4 VIA5 VIA6 VIA7 VIA8}  -name temp_mem_blockages
}

#################################
# Build main grid from M0 to M10 #
#################################
# M0 followpins
reset_db -category generate_special_via
set_db add_stripes_stacked_via_top_layer M0
set_db add_stripes_stacked_via_bottom_layer M0
set_db route_special_connect_broken_core_pin true

route_special -nets {VSS VDD} -connect corePin -core_pin_target none -allow_jogging 0 -allow_layer_change 0 -core_pin_layer M0 -core_pin_width $M0_width -user_class M0_FOLLOWPIN
# delete_routes -type special -layer { VIA0 M1 VIA1 M2 VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M1 stripes
reset_db -category add_stripes
set_db add_stripes_stacked_via_top_layer M1
set_db add_stripes_stacked_via_bottom_layer M0
set_db add_stripes_stapling_nets_style side_to_side_full_nets
set_db add_stripes_trim_stripe core_boundary
set_db generate_special_via_rule_preference $VIA0_master

set cmd "add_stripes -layer M1 $M1_stappling  \
  -width $M1_width \
  -direction vertical \
  -set_to_set_distance $M1_set2set_dist \
  -start_offset $M1_offset \
  -stop_offset $M1_offset \
  -nets {VDD VDD VSS VSS}\
  -snap_wire_center_to_grid grid \
  -spacing \"$M1_spacing\" \
 -create_pins 0  "

eval $cmd 


# delete_routes -type special -layer {VIA1 M2 VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M2 stripes
reset_db -category add_stripes
reset_db -category generate_special_via
set_db add_stripes_stacked_via_top_layer M2
set_db add_stripes_stacked_via_bottom_layer M1
set_db generate_special_via_rule_preference $VIA1_master
set_db add_stripes_stapling_nets_style side_to_side

set cmd "add_stripes -layer M2 $M2_stappling \
  -width $M2_width \
  -direction horizontal \
  -set_to_set_distance [expr $M2_set2set_dist] \
  -start_offset $M2_offset  \
  -nets {VDD VSS } \
  -spacing \"$M2_spacing\" "
  
eval $cmd

# delete_routes -type special -layer { VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M3  stripes
reset_db -category add_stripes
reset_db -category generate_special_via
set_db add_stripes_stacked_via_top_layer M3
set_db add_stripes_stacked_via_bottom_layer M2
set_db add_stripes_stapling_nets_style side_to_side
set_db generate_special_via_rule_preference $VIA2_master

set cmd "add_stripes -layer M3 \
  $M3_stapling \
 -width $M3_width \
 -direction vertical \
 -set_to_set_distance [expr $M3_set2set_dist] \
 -start_offset $M3_offset \
 -create_pins 0 \
 -nets {VDD VDD VSS VSS } \
 -spacing \"$M3_spacing\" \
  -snap_wire_center_to_grid grid \
"
eval $cmd


# delete_routes -type special -layer {  VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}

# M4 stapling stripes
reset_db -category add_stripes
reset_db -category generate_special_via
set_db add_stripes_stacked_via_top_layer M4
set_db add_stripes_stacked_via_bottom_layer M3
set_db add_stripes_stapling_nets_style side_to_side
set_db generate_special_via_rule_preference $VIA3_master

set cmd "add_stripes -layer M4 \
  $M4_stapling \
  -width $M4_width \
  -direction horizontal \
  -set_to_set_distance $M4_set2set_dist \
  -start_offset $M4_offset \
  -stop_offset $M4_offset \
  -create_pins 0 -nets {VDD VDD VSS VSS } \
  -spacing \"$M4_spacing\" \
  -snap_wire_center_to_grid grid \
  "

eval $cmd

# delete_routes -type special -layer {   VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}

# M5 stapling stripes
reset_db -category add_stripes
reset_db -category generate_special_via
set_db add_stripes_stacked_via_top_layer M5
set_db add_stripes_stacked_via_bottom_layer M4
set_db add_stripes_stapling_nets_style side_to_side
set_db generate_special_via_rule_preference $VIA4_master

set cmd "add_stripes -layer M5  \
  -width [expr 1*$M5_width] \
  $M5_stapling \
  -direction vertical \
  -set_to_set_distance $M5_set2set_dist \
  -start_offset $M5_offset \
  -create_pins 0 \
  -spacing \"$M5_spacing\" \
  -nets {VDD VSS} \
   -snap_wire_center_to_grid grid \
  "
eval $cmd
  
  
# delete_routes -type special -layer {    VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M6 stapling stripes
reset_db -category add_stripes
reset_db -category generate_special_via
set_db add_stripes_stacked_via_top_layer M6
set_db add_stripes_stacked_via_bottom_layer M5
set_db add_stripes_stapling_nets_style side_to_side
set_db generate_special_via_rule_preference $VIA5_master
set cmd "add_stripes -layer M6 \
  $M6_stapling \
  -width $M6_width \
  -direction horizontal \
  -set_to_set_distance $M6_set2set_dist \
  -start_offset $M6_offset \
  -create_pins 0 -nets \"$M6_nets\" \
  -spacing \"$M6_spacing\" \
   -snap_wire_center_to_grid grid \
   "
eval $cmd

if {$MAX_ROUTING_LAYER > 7} {
# delete_routes -type special -layer {     VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M7 stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M7
   set_db add_stripes_stacked_via_bottom_layer M6
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA6_master
   set cmd "add_stripes -layer M7  \
  	-width $M7_width  \
  	$M7_stapling \
  	-direction vertical \
  	-set_to_set_distance $M7_set2set_dist \
  	-start_offset $M7_offset \
  	-create_pins 0 \
  	-spacing \"$M7_spacing\" \
  	-nets {VDD VSS } \
  	-snap_wire_center_to_grid grid \
  	"
  eval $cmd
}

if {$MAX_ROUTING_LAYER > 8} {
# delete_routes -type special -layer {  VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M8 stapling stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M8
   set_db add_stripes_stacked_via_bottom_layer M7
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA7_master
   set cmd "add_stripes -layer M8 \
  	$M8_stapling \
  	-width $M8_width \
  	-direction horizontal \
  	-set_to_set_distance $M8_set2set_dist \
  	-start_offset $M8_offset \
  	-create_pins $M8_pin -nets \"$M8_nets\" \
  	-spacing \"$M8_spacing\" \
  	-snap_wire_center_to_grid grid \
   	"
   eval $cmd
}

if {$MAX_ROUTING_LAYER > 9} {
# delete_routes -type special -layer { VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M9 stapling stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M9
   set_db add_stripes_stacked_via_bottom_layer M8
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA8_master
   set cmd "add_stripes -layer M9  \
  	$M9_stapling \
  	-width $M9_width \
  	-direction vertical \
  	-set_to_set_distance $M9_set2set_dist \
  	-start_offset $M9_offset \
  	-create_pins $M9_pin \
  	-spacing \"$M9_spacing\" \
  	-nets {VDD VSS } \
  	-snap_wire_center_to_grid grid \
   "
   eval $cmd
}

if {$MAX_ROUTING_LAYER > 10} {
# delete_routes -type special -layer {  VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M10 stapling stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M10
   set_db add_stripes_stacked_via_bottom_layer M9
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA9_master
   set cmd "add_stripes -layer M10 \
  	$M10_stapling \
  	-width $M10_width \
  	-direction horizontal \
  	-set_to_set_distance $M10_set2set_dist \
  	-start_offset $M10_offset \
  	-create_pins $M10_pin -nets \"$M10_nets\" \
  	-spacing \"$M10_spacing\" \
   	-snap_wire_center_to_grid grid \
   "
   eval $cmd
}

#########################
# Delete temp blockages #
#########################
if {[llength  [get_db insts -if {.base_cell.base_class == block}]] > 0} {
   delete_route_blockages -name temp_mem_blockages
########################
# Build Macro sub-grid #
########################
# Create M4 stripes over macro to connect to M3 pins
# delete_routes -type special -sub_class MEM_PG -layer {  VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 }
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M4
   set_db add_stripes_stacked_via_bottom_layer M3
   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block}] {
     add_stripes \
  	-nets {VDD VSS} \
  	-layer M4 -direction horizontal -width $M4_width_mem \
    	-spacing $M4_spacing_mem \
    	-set_to_set_distance $M4_set2set_dist_mem \
    	-area [get_db $inst_dpo .bbox] \
    	-snap_wire_center_to_grid grid \
    	-start_offset $M4_offset_mem \
    	-stop_offset $M4_offset_mem \
	-user_class MEM_PG
   }

# M5 stripes mesh
# delete_routes -type special -sub_class MEM_PG -layer {   VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 }
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M5
   set_db add_stripes_stacked_via_bottom_layer M4
   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block}] {
     add_stripes -nets {VDD VSS} \
     	-layer M5 \
	-direction vertical \
	-width $M5_width_mem \
   	-spacing $M5_spacing_mem \
	-set_to_set_distance $M5_set2set_dist_mem \
    	-area [get_db $inst_dpo .bbox] \
    	-snap_wire_center_to_grid grid \
    	-start_offset $M5_offset_mem  \
    	-stop_offset  $M5_offset_mem  \
	-user_class MEM_PG
   }

# M6 stripes mesh
# delete_routes -type special -sub_class MEM_PG -layer {   VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 }
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M6
   set_db add_stripes_stacked_via_bottom_layer M5
   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block}] {
     add_stripes \
     	-nets {VDD VSS} \
	-layer M6 \
	-direction horizontal \
	-width $M6_width_mem \
    	-spacing $M6_spacing_mem \
	-set_to_set_distance $M6_set2set_dist_mem \
    	-area [get_db $inst_dpo .bbox] \
    	-snap_wire_center_to_grid grid \
    	-start_offset $M6_offset_mem \
    	-stop_offset $M6_offset_mem \
	-user_class MEM_PG
   }

if {$MAX_ROUTING_LAYER > 7} {
# M7 stripes mesh
# delete_routes -type special -sub_class MEM_PG -layer {   VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 }
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M7
   set_db add_stripes_stacked_via_bottom_layer M6
   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block}] {
     add_stripes \
     	-nets {VDD VSS} \
	-layer M7 \
	-direction vertical \
	-width $M7_width_mem \
    	-spacing $M7_spacing_mem \
	-set_to_set_distance $M7_set2set_dist_mem \
    	-area [get_db $inst_dpo .bbox] \
    	-snap_wire_center_to_grid grid \
    	-start_offset $M7_offset_mem \
    	-stop_offset $M7_offset_mem \
	-user_class MEM_PG
   }
}
if {$MAX_ROUTING_LAYER > 8} {
# M8 stripes mesh
# delete_routes -type special -sub_class MEM_PG -layer {   VIA7 M8 VIA8 M9 VIA9 M10  }
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M8
   set_db add_stripes_stacked_via_bottom_layer M7
   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block}] {
     add_stripes \
     	-nets {VDD VSS} \
	-layer M8 \
	-direction horizontal \
	-width $M8_width_mem \
    	-spacing $M8_spacing_mem \
	-set_to_set_distance $M8_set2set_dist_mem \
    	-area [get_db $inst_dpo .bbox] \
    	-snap_wire_center_to_grid grid \
    	-start_offset $M8_offset_mem \
    	-stop_offset $M8_offset_mem \
	-user_class MEM_PG
   }
}
if {$MAX_ROUTING_LAYER > 9} {
# M9 stripes mesh
# delete_routes -type special -sub_class MEM_PG -layer {   VIA8 M9 VIA9 M10  }
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M9
   set_db add_stripes_stacked_via_bottom_layer M8
   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block}] {
     add_stripes \
     	-nets {VDD VSS} \
	-layer M9 \
	-direction vertical \
	-width $M9_width_mem \
    	-spacing $M9_spacing_mem \
	-set_to_set_distance $M9_set2set_dist_mem \
    	-area [get_db $inst_dpo .bbox] \
    	-snap_wire_center_to_grid grid \
    	-start_offset $M9_offset_mem  \
    	-stop_offset $M9_offset_mem \
	-user_class MEM_PG
   }
}
if {$MAX_ROUTING_LAYER > 10} {
# M10 stripes mesh
# delete_routes -type special -sub_class MEM_PG -layer {   VIA9 M10  }
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M10
   set_db add_stripes_stacked_via_bottom_layer M9
   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block}] {
     add_stripes \
     	-nets {VDD VSS} \
     	-layer M10 \
	-direction horizontal \
	-width $M10_width_mem \
    	-spacing $M10_spacing_mem \
	-set_to_set_distance $M10_set2set_dist_mem \
    	-area [get_db $inst_dpo .bbox] \
    	-snap_wire_center_to_grid grid \
    	-start_offset $M10_offset_mem  \
    	-stop_offset $M10_offset_mem \
	-user_class MEM_PG
   }
}


}
###################################
# Build main grid from M11 to M17 #
###################################

if {$MAX_ROUTING_LAYER > 11} {
# delete_routes -type special -layer {   VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M11 stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M11
   set_db add_stripes_stacked_via_bottom_layer M10
   set cmd "add_stripes -layer M11  \
  	$M11_stapling \
  	-width [expr 2*$M11_width] \
  	-direction vertical \
  	-set_to_set_distance $M11_set2set_dist \
  	-start_offset $M11_offset \
  	-create_pins $M11_pin \
  	-spacing \"$M11_spacing\" \
  	-nets {VDD VSS } \
  	-snap_wire_center_to_grid half_grid \
   "
   eval $cmd
}

if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER > 12} { 
# delete_routes -type special -layer {   VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
# M12 stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M12
   set_db add_stripes_stacked_via_bottom_layer M11
   set cmd "add_stripes -layer M12 \
 	-width $M12_width \
 	$M12_stapling \
 	-direction horizontal \
 	-set_to_set_distance $M12_set2set_dist \
  	-create_pins $M12_pin \
 	-nets {VSS VDD} \
 	-spacing \"$M12_spacing\" \
 	-start_offset $M12_offset \
   "
   eval $cmd 
} 

if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER > 13} { 
  # delete_routes -type special -layer {  VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
  # M13 stripes
  reset_db -category add_stripes
  reset_db -category generate_special_via
  set_db add_stripes_stacked_via_top_layer M13
  set_db add_stripes_stacked_via_bottom_layer M12
  set cmd "add_stripes -layer M13 \
  	-width $M13_width \
  	-direction vertical \
  	-set_to_set_distance $M13_set2set_dist \
  	-nets {VDD VSS} \
  	-spacing \"$M13_spacing\" \
  	-start_offset $M13_offset \
  	-create_pins $M13_pin \
  "
  eval $cmd
}

if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER > 14} { 
  # delete_routes -type special -layer {VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17 }
  # M14 stripes
  reset_db -category add_stripes
  reset_db -category generate_special_via
  set_db add_stripes_stacked_via_top_layer M14
  set_db add_stripes_stacked_via_bottom_layer M13
  set cmd "add_stripes -layer M14 \
    -width $M14_width -direction horizontal \
    -set_to_set_distance $M14_set2set_dist \
    -create_pins $M14_pin \
    -nets {VDD VSS} \
    -spacing \"$M14_spacing\" \
    -extend_to design_boundary \
    -start_offset $M14_offset
    "
    
  eval $cmd
}
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 16} {
  # delete_routes -type special -layer {VIA14 M15 VIA15 M16 VIA16 M17 }
  #  # M15 stripes
  reset_db -category add_stripes
  reset_db -category generate_special_via
  set_db add_stripes_stacked_via_top_layer M15
  set_db add_stripes_stacked_via_bottom_layer M14
  set cmd "add_stripes -layer M15 \
    -width $M15_width -direction vertical \
    -set_to_set_distance $M15_set2set_dist \
    -create_pins $M15_pin \
    -nets {VDD VSS} \
    -spacing \"$M15_spacing\" \
    -start_offset $M15_offset \
    -extend_to design_boundary "
  
  eval $cmd

}
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 17} {
  # delete_routes -type special -layer {VIA15 M16 VIA16 M17 }
  # M16 stripes
	set_db add_stripes_stacked_via_top_layer M16 
	set_db add_stripes_stacked_via_bottom_layer M15 
	add_stripes \
		-layer M16 \
		-width $M16_width \
		-direction horizontal \
		-set_to_set_distance $M16_set2set_dist  \
    		-create_pins $M16_pin \
		-nets {VDD VSS} \
		-spacing $M16_spacing \
		-start_offset $M16_offset \
		-extend_to design_boundary 
}
if {[info exists MAX_ROUTING_LAYER] && $MAX_ROUTING_LAYER == 18} {
#      delete_routes -type special -layer { VIA16 M17 RV AP}
	set_db add_stripes_stacked_via_top_layer M17 
	set_db add_stripes_stacked_via_bottom_layer M16 
	add_stripes \
		-layer M17 \
		-width $M17_width \
    		-create_pins $M17_pin \
		-direction vertical \
		-set_to_set_distance $M17_set2set_dist  \
		-nets {VDD VSS} \
		-spacing $M17_spacing \
		-start_offset $M17_offset \
		-extend_to design_boundary 
}



#######################
# Colorize power mesh #
#######################
#eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}

##############
# DRC checks #
##############
#check_drc -limit 100000
#check_floorplan -odd_even_site_row

################################
# Fix potential Min DRC errors #
################################
#fix_via -min_step 
#eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}
#check_drc -limit 100000

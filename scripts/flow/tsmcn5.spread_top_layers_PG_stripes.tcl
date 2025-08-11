#      delete_routes -type special -layer {M13 VIA13 M14 VIA14 M15 RV AP}
##################################################################################################################################
###	this etting is taken from create power grid script.
##################################################################################################################################
if {[info exists DEFAULT_SITE]} {
	set tile_height [get_db site:$DEFAULT_SITE .size.y]
} else {
	set tile_height [get_db site:core .size.y]
}

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
if {[lsearch  [get_db [get_db layers] .name] M16] > -1} {set M16_pitch [get_db layer:M16 .pitch_x] } else {set M16_pitch 0}
if {[lsearch  [get_db [get_db layers] .name] M17] > -1} {set M17_pitch [get_db layer:M17 .pitch_y] } else {set M17_pitch 0}


if {[lsearch  [get_db [get_db layers] .name] M17] > -1} {
   set M2_width                [get_db layer:M2 .width]
   set M6_width                [get_db layer:M6 .width]
   set M7_width                [get_db layer:M7 .width]
   set M8_width                [get_db layer:M8 .width]
   set M9_width                [expr [get_db layer:M9 .width]*1]
   set M10_width               [expr [get_db layer:M10 .width]*1]
   
   if {[regexp snps ${::env(PROJECT)}]} {
   	set M11_width               [expr [get_db layer:M11 .width]*1]
   	set M12_width               0.188
   	set M13_width               0.156
   } elseif {[regexp tsmc ${::env(PROJECT)}]} {
	set M11_width               0.076
	set M12_width               0.062
	set M13_width               0.188
   }
   
   set M14_width               [expr [get_db layer:M14 .width]*3]
   set M15_width               0.45
   set M16_width               1.26
   set M17_width               3.6
} else {
   set M8_width                [get_db layer:M8 .width]
   set M9_width                [expr [get_db layer:M9 .width]*2]
   set M10_width               [expr [get_db layer:M10 .width]*1]
   set M11_width               [expr [get_db layer:M11 .width]*7]
   set M11_width               0.408
   set M12_width               [expr [get_db layer:M12 .width]*1]
   set M13_width               0.45
   set M14_width               1.26
   set M15_width               3.6
}

set M6_min_space    [expr $M6_pitch-$M6_width]
set M7_min_space    [expr $M7_pitch-$M7_width]
set M8_min_space    [expr $M8_pitch-$M8_width]
set M10_min_space   [expr $M10_pitch-$M10_width]
if {[lsearch  [get_db [get_db layers] .name] M17] > -1} {
   set M9_min_space    [expr $M9_pitch-$M9_width]
   if {[regexp snps ${::env(PROJECT)}]} {
   	set M12_min_space   0.09
   } elseif {[regexp tsmc ${::env(PROJECT)}]} {
	set M12_min_space   [expr $M12_pitch-$M12_width]
   }
   set M13_min_space   0.09
   set M14_min_space   0.126
   set M15_min_space   0.171
   set M16_min_space   0.45
   set M17_min_space   0.45
} else {
   set M9_min_space    0.038
   set M12_min_space   [expr $M12_pitch-$M12_width]
}

set die2coreOffset_x        0.228
set die2coreOffset_y        0.240

# margins to edge for Mx bounding box:
# set PG_x_margin             0
# set PG_y_margin             [expr $tile_height/2]
# set PG_bbox                 "[expr [get_db current_design .bbox.ll.x] + $PG_x_margin] [expr [get_db current_design .bbox.ll.y] + $PG_y_margin] [expr [get_db current_design .bbox.ur.x] - $PG_x_margin] [expr [get_db current_design .bbox.ur.y] - $PG_y_margin]"

if {[lsearch  [get_db [get_db layers] .name] M17] > -1} {
   set M1_set2set_dist         [expr 36*$M1_pitch]
   set M2_offset          	[expr 1*$tile_height + 0*$M2_pitch - 1*$M2_width/2]
   set M3_set2set_dist         $M1_set2set_dist
   set M4_offset               [expr $M2_offset]
   set M5_set2set_dist   		$M3_set2set_dist
   set M5_offset      		0.5635
   set M6_set2set_dist         [expr 0.76 + $M6_pitch]
   set M6_spacing              [expr $M6_min_space + 2*$M6_pitch]
   set M6_offset               $M4_offset
   
   #M7:
   set M7_set2set_dist         $M5_set2set_dist
   set M7_spacing              [expr $M7_min_space + 7*$M7_pitch]
   set M7_offset               $M5_offset
   set M7_stapling             "-stapling {0.395 M6}"

   #M8:
   set M8_set2set_dist         $M6_set2set_dist
   set M8_offset               $M6_offset
   set M8_spacing              [expr $M8_min_space + 2*$M8_pitch]
   set M8_stapling             "-stapling {0.395 M7}"
      
   #M9:
   set M9_set2set_dist         $M7_set2set_dist
   set M9_spacing              [expr $M9_min_space + 7*$M9_pitch]
   set M9_offset               $M7_offset
   set M9_stapling   "-stapling {0.395 M8}"
   
   #M10:
   set M10_set2set_dist         $M8_set2set_dist
   set M10_offset               $M8_offset
   set M10_spacing              "[expr $M10_min_space + 2*$M10_pitch]"
   set M10_stapling   		"-stapling {0.395 M9}"
   
   #M11:
   set M11_set2set_dist         $M9_set2set_dist
   set M11_offset               $M9_offset
   set M11_spacing 		 [expr 7*$M11_pitch]
   set M11_stapling   ""
   
   #M12:
   set M12_set2set_dist        $M10_set2set_dist
   set M12_offset              $M10_offset
   set M12_spacing             "[expr $M12_min_space + 0*$M12_pitch]"
   set M12_stapling   ""
   
   #M13:
   set M13_set2set_dist        [expr 12*$M13_pitch]
   set M13_offset              [expr 4*$M13_pitch - $M13_width/2 -0.01]
   set M13_spacing             "$M13_min_space"
   
   #M14:
   set M14_set2set_dist        [expr 11*$M14_pitch]
   set M14_offset              [expr 3*$M14_pitch - $M14_width/2]
   set M14_spacing             0.189
   
   #M15:
   set M15_set2set_dist        [expr 11*$M15_pitch]
   set M15_offset              [expr 3*$M15_pitch - $M15_width/2]
   set M15_spacing             0.189
   #M16:
   set M16_offset              [expr 3*$M16_pitch - $M16_width/2]
   set M16_spacing             0.45
   set M16_set2set_dist        [expr $M16_width*2+$M16_spacing*2 + 0.629]	; # nead to be 80% utilization or less
   
   #M17:
   set M17_offset              0.1
   set M17_spacing             0.585
   set M17_set2set_dist        [expr $M17_width*2+$M17_spacing*2 + 0.629]	; # nead to be 80% utilization or less
   
} else {
   
   #M7:
   set M7_set2set_dist         3.42
   set M7_spacing              "0.114 0.114 1.368  0.114 0.114"
   set M7_offset               1.1975
   set M7_stapling             "-stapling {0.4 M6}"
   
   #M8:
   set M8_set2set_dist         0.96
   set M8_offset               1.534
   set M8_spacing              "[expr 2*$M8_pitch - $M8_width] [expr $M8_set2set_dist/2 - 2*$M8_pitch  - $M8_width ] [expr 2*$M8_pitch - $M8_width  ]"
   set M8_stapling             "-stapling {0.4 M7}"
   
   #M9:
   set M9_spacing              "[expr $M9_min_space + $M9_pitch] [expr $M7_set2set_dist/2 - 3*$M9_pitch- $M9_width] [expr $M9_min_space + $M9_pitch]"
   set M9_offset               1.1975
   set M9_set2set_dist         $M7_set2set_dist
   set M9_stapling   	    "-stapling {0.4 M8}"
   
   #M10:
   set M10_set2set_dist        [expr 0*$M10_pitch + 0.96]
   set M10_offset               [expr 1.61 -$M8_pitch]
   set M10_spacing             [expr  $M10_set2set_dist/2 - $M10_width]
   set M10_stapling            "-stapling {0.5 M9}"
   
   
   #M11:
   set M11_set2set_dist        [expr 3.42]
   set M11_offset              [expr 1.3495 - 0.13]
   set M11_spacing             [expr $M11_set2set_dist/2 - $M11_width]
   
   #M12:
   set M12_set2set_dist        [expr 4*$M12_pitch]
   set M12_offset              [expr 4*$M12_pitch - $M12_width/2]
   set M12_spacing             "[expr $M12_set2set_dist/4 - $M12_width] [expr 2*$M12_pitch + $M12_min_space] [expr $M12_set2set_dist/4 - $M12_width]"
   
   
   #M13:
   set M13_set2set_dist        [expr 14*$M13_pitch]
   set M13_offset              [expr 4*$M13_pitch - $M13_width/2]
   set M13_spacing             0.171
   
   #M14:
   set M14_set2set_dist        [expr 7*$M14_pitch]
   set M14_offset              [expr 3*$M14_pitch - $M14_width/2]
   set M14_spacing            [expr $M14_pitch/2]
   
   #M15:
   set M15_set2set_dist        [expr 10*$M15_pitch]
   set M15_offset              [expr 3*$M15_pitch - $M15_width/2]
   set M15_spacing             [expr $M15_set2set_dist/2 - $M15_width]
}




##################################################################################################################################
### check the highest PG stripe and spread above it till M15
##################################################################################################################################


foreach LAYER {M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 M17} {
	if {[llength [get_db [get_db [get_db nets -if {.is_power==true}] .special_wires] -if ".layer==layer:$LAYER"]] > 0} {
		set UPPER_LAYER $LAYER
	}
}

if {$UPPER_LAYER == "M8"} {
#      delete_routes -type special -layer {VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17 RV AP}
	set UPPER_LAYER M9
	set LOWER_LAYER_NUMBER M8
	set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
	set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
	add_stripes \
		-layer $UPPER_LAYER \
		-width $M9_width \
		-direction horizontal \
		-set_to_set_distance $M9_set2set_dist  \
		-nets {VDD VSS} \
		-spacing $M9_spacing \
		-start_offset $M9_offset \
		-extend_to design_boundary 
}

if {$UPPER_LAYER == "M9"} {
#      delete_routes -type special -layer {VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17 RV AP}
	set UPPER_LAYER M10
	set LOWER_LAYER_NUMBER M9
	set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
	set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
	add_stripes \
		-layer $UPPER_LAYER \
		-width $M10_width \
		-direction horizontal \
		-set_to_set_distance $M10_set2set_dist  \
		-nets {VDD VSS} \
		-spacing $M10_spacing \
		-start_offset $M10_offset \
		-extend_to design_boundary 
}

if {$UPPER_LAYER == "M10"} {
#      delete_routes -type special -layer { VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17 RV AP}
	set UPPER_LAYER M11
	set LOWER_LAYER_NUMBER M10
	set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
	set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
	add_stripes \
		-layer $UPPER_LAYER \
		-width $M11_width \
		-direction vertical \
		-set_to_set_distance $M11_set2set_dist  \
		-nets {VDD VSS} \
		-spacing $M11_spacing \
		-start_offset $M11_offset \
		-extend_to design_boundary 
}

if {$UPPER_LAYER == "M11"} {
#      delete_routes -type special -layer { VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17 RV AP}
	set UPPER_LAYER M12
	set LOWER_LAYER_NUMBER M11
	set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
	set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
	add_stripes \
		-layer $UPPER_LAYER \
		-width $M12_width \
		-direction horizontal \
		-set_to_set_distance $M12_set2set_dist  \
		-nets {VDD VSS} \
		-spacing $M12_spacing \
		-start_offset $M12_offset \
		-extend_to design_boundary 
}


if {$UPPER_LAYER == "M12"} {
#      delete_routes -type special -layer { VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17 RV AP}
	set UPPER_LAYER M13
	set LOWER_LAYER_NUMBER M12
	set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
	set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
	add_stripes \
		-layer $UPPER_LAYER \
		-width $M13_width \
		-direction vertical \
		-set_to_set_distance $M13_set2set_dist  \
		-nets {VDD VSS} \
		-spacing $M13_spacing \
		-start_offset $M13_offset \
		-extend_to design_boundary 
}

if {$UPPER_LAYER == "M13"} {
#      delete_routes -type special -layer { VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17 RV AP}
	set UPPER_LAYER M14
	set LOWER_LAYER_NUMBER M13
	set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
	set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
	add_stripes \
		-layer $UPPER_LAYER \
		-width $M14_width \
		-direction horizontal \
		-set_to_set_distance $M14_set2set_dist  \
		-nets {VDD VSS} \
		-spacing $M14_spacing \
		-start_offset $M14_offset \
		-extend_to design_boundary 
}

if {$UPPER_LAYER == "M14"} {
#      delete_routes -type special -layer { VIA14 M15 VIA15 M16 VIA16 M17 RV AP}
	set UPPER_LAYER M15
	set LOWER_LAYER_NUMBER M14
	set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
	set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
	add_stripes \
		-layer $UPPER_LAYER \
		-width $M15_width \
		-direction vertical \
		-set_to_set_distance $M15_set2set_dist  \
		-nets {VDD VSS} \
		-spacing $M15_spacing \
		-start_offset $M15_offset \
		-extend_to design_boundary 
}


if {$UPPER_LAYER == "M15"} {
	if {[lsearch  [get_db [get_db layers] .name] M16] > -1} {
#      delete_routes -type special -layer {VIA15 M16 VIA16 M17 RV AP}
		set UPPER_LAYER M16
		set LOWER_LAYER_NUMBER M15
		set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
		set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
		add_stripes \
			-layer $UPPER_LAYER \
			-width $M16_width \
			-direction horizontal \
			-set_to_set_distance $M16_set2set_dist  \
			-nets {VDD VSS} \
			-spacing $M16_spacing \
			-start_offset $M16_offset \
			-extend_to design_boundary 
	} else {
#      delete_routes -type special -layer { RV AP}
		set UPPER_LAYER AP
		set LOWER_LAYER_NUMBER 15
		set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
		set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
		add_stripes \
			-layer $UPPER_LAYER \
			-width 13.8 \
			-direction horizontal \
			-set_to_set_distance 145  \
			-nets {VDD VDD VDD VDD VSS VSS VSS VSS} \
			-spacing {1.8 1.8 1.8 11.9 1.8 1.8 1.8}  \
			-start_offset 6.9 \
			-extend_to design_boundary 
	}
}

if {$UPPER_LAYER == "M16"} {
#      delete_routes -type special -layer { VIA16 M17 RV AP}
	set UPPER_LAYER M17
	set LOWER_LAYER_NUMBER M16
	set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
	set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
	add_stripes \
		-layer $UPPER_LAYER \
		-width $M17_width \
		-direction vertical \
		-set_to_set_distance $M17_set2set_dist  \
		-nets {VDD VSS} \
		-spacing $M17_spacing \
		-start_offset $M17_offset \
		-extend_to design_boundary 
}

if {$UPPER_LAYER == "M17"} {
	set UPPER_LAYER AP
	set LOWER_LAYER_NUMBER M17
	set_db add_stripes_stacked_via_top_layer $UPPER_LAYER 
	set_db add_stripes_stacked_via_bottom_layer $LOWER_LAYER_NUMBER 
	add_stripes \
		-layer $UPPER_LAYER \
		-width 13.8 \
		-create_pins true \
		-direction horizontal \
		-set_to_set_distance 145  \
		-nets {VDD VDD VDD VDD VSS VSS VSS VSS} \
		-spacing {1.8 1.8 1.8 11.9 1.8 1.8 1.8}  \
		-start_offset 6.9 \
		-extend_to design_boundary 
}


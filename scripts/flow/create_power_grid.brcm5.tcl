check_script_location

set start_t [clock seconds]
puts "-I- Start running create_power_grid at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

if {![info exists ADD_TOP_POWER] } {set ADD_TOP_POWER false}
set UPPER_LAYER M0

if {$ADD_TOP_POWER == "false"} {
   delete_routes -type special -layer {M0 VIA0 M1 VIA1 M2 VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
} else {
   foreach LAYER {M7 M8 M9 M10 M11 M12 M13 M14 M15 M16 M17} {
   	if {[llength [get_db [get_db [get_db nets -if {.is_power==true}] .special_wires] -if ".layer==layer:$LAYER"]] > 0} {
		set UPPER_LAYER [get_db layer:$LAYER .route_index]
   	}
   }
   
   
}
#######################
# Variable definition #
#######################
set tile_height [get_db site:$DEFAULT_SITE .size.y]

#get all pins pitch from tech :
set M0_pitch  [get_db layer:M0 .pitch_x]
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
set M6_double_width         [expr [get_db layer:M6 .width]*2]
set M7_width                [get_db layer:M7 .width]
set M7_double_width         [expr [get_db layer:M7 .width]*2]
set M8_width                [get_db layer:M8 .width]
set M9_width                [expr [get_db layer:M9 .width]*1]
set M9_double_width         [expr [get_db layer:M9 .width]*2]
set M10_width               [expr [get_db layer:M10 .width]*1]
set M11_width               [expr [get_db layer:M11 .width]*1]
set M11_double_width        [expr [get_db layer:M11 .width]*2]
#set M12_width               0.188
set M12_width               0.226
#set M13_width               0.156
set M13_width               0.46
#set M14_width		    [expr [get_db layer:M14 .width]*3]
set M14_width		    0.54
set M15_width		    1.35
set M16_width		    1.4
set M17_width		    4.05

set M4_width_mem               0.12
set M5_width_mem               0.25
set M6_width_mem               0.25
set M7_width_mem               0.25
set M8_width_mem               0.25
set M9_width_mem               0.25
set M10_width_mem              0.25 

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
#				P5VIA01A_V2
set VIA0_master P5VIA01_V2
#set VIA0_master VIA01_big_BW20_UW20
#set VIA0_master VIA01_1cut_BW14_UW20

set VIA1_master {P5VIA12 P5VIA01A_V2}
#set VIA1_master generated
#set VIA1_master VIA12_1cut_BW20_UW20
set VIA2_master P5VIA23B
set VIA3_master generated

#set VIA4_master VIA45_1cut_BW22_UW38
#set VIA3_master VIA34_1cut_BW20_UW24
#set VIA4_master VIA45_1cut_BW24_UW38
#set VIA5_master VIA56_1cut_BW38_UW38
set VIA4_master P5VIA45B
set VIA5_master P5VIA56
#set VIA6_master P5VIA67B
set VIA6_VSS_master P5VIA67B
set VIA6_VDD_master P5VIA67A

set VIA7_master P5VIA78A
set VIA8_master P5VIA89A
set VIA9_master P5VIA910A
#set VIA6_master generated
#set VIA7_master generated
#set VIA8_master generated
#set VIA9_master generated
set VIA10_master P5VIA1011
set VIA11_master P5VIA1112
set VIA12_master P5VIA1213
set VIA13_master P5VIA1314
set VIA14_master P5VIA1415
set VIA15_master P5VIA1516
set VIA16_master P5VIA1617

#set VIA11_master VIAGEN1112

set die2coreOffset_x        0.228
set die2coreOffset_y        0.240

# margins to edge for Mx bounding box:
# set PG_x_margin             0
# set PG_y_margin             [expr $tile_height/2]
# set PG_bbox                 "[expr [get_db current_design .bbox.ll.x] + $PG_x_margin] [expr [get_db current_design .bbox.ll.y] + $PG_y_margin] [expr [get_db current_design .bbox.ur.x] - $PG_x_margin] [expr [get_db current_design .bbox.ur.y] - $PG_y_margin]"



#M1:  must follow mask 1

set M1_spacing              "[expr (6*$M1_pitch)-$M1_width ] [expr (6*$M1_pitch)-$M1_width] [expr (6*$M1_pitch)-$M1_width] [expr (6*$M1_pitch)-$M1_width] [expr (6*$M1_pitch)-$M1_width]"
#set M1_stappling    ""
#set M1_stapling             "-stapling {0.592 0.21 0.42:1 }"
#set M1_stapling             "-stapling {0.592 m0 }"


set M1_set2set_dist         [expr 114*$M1_pitch]
#set M1_offset               [expr (7*$M1_pitch) + 0.0085 -$M1_width/2]

set M1_VDD_offset               [expr 0.007 + 16*$M1_pitch]

set M1_VDD_spacing              "[expr (6*$M1_pitch)-$M1_width ] [expr (6*$M1_pitch)-$M1_width] [expr (24*$M1_pitch)-$M1_width] [expr (6*$M1_pitch)-$M1_width ] [expr (6*$M1_pitch)-$M1_width] [expr (24*$M1_pitch)-$M1_width] [expr (6*$M1_pitch)-$M1_width ] [expr (6*$M1_pitch)-$M1_width]" 
#set M1_VDD_stapling             "-stapling {0.592 0.164-->0.21 0.84:1 }"
#set M1_VDD_stapling             "-stapling {0.592 0.168 0.84:1 }"
#set M1_VDD_stapling             "-stapling {0.592 0.21 0.84:1 }"
set M1_VDD_stapling             "-stapling {0.592 0.42 0.84:1 }"



set M1_VSS_spacing              "[expr (6*$M1_pitch)-$M1_width ] [expr (6*$M1_pitch)-$M1_width] [expr (24*$M1_pitch)-$M1_width] [expr (6*$M1_pitch)-$M1_width ] [expr (6*$M1_pitch)-$M1_width] [expr (24*$M1_pitch)-$M1_width] [expr (6*$M1_pitch)-$M1_width ] [expr (6*$M1_pitch)-$M1_width]" 
#set M1_VSS_stapling             "-stapling {0.592 0.376-->0.422 0.84:1 }"  
#set M1_VSS_stapling             "-stapling {0.592 0.378 0.84:1 }"
#set M1_VSS_stapling             "-stapling {0.592 0.42 0.84:1 }"
set M1_VSS_stapling             "-stapling {0.592 0.63 0.84:1 }"


set M1_VSS_offset               [expr 0.007 + 34*$M1_pitch]




#M2:
set M2_set2set_dist   	[expr 12*$M2_pitch]
#set M2_offset          	[expr 1*$tile_height + 6*$M2_pitch + 1*$M2_width/2]
#set M2_offset          	[expr 6*$M2_pitch ]
set M2_offset          	"0.2"


set M2_stapling   	"-stapling {0.484 M1}"
set M2_spacing    	"[expr 6*$M2_pitch - $M2_width ]"


#M3:
#set M3_set2set_dist         [expr 54*$M3_pitch]
#set M3_spacing              "[expr 4*$M3_pitch-$M3_min_space] [expr 25*$M3_pitch-$M3_min_space] [expr 4*$M3_pitch-$M3_min_space]"
set M3_set2set_dist         1.292
#set M3_set2set_dist         [expr  30*$M3_pitch]
set M3_spacing              "[expr 4*$M3_pitch-$M3_width] [expr 11*$M3_pitch-$M3_width] [expr 4*$M3_pitch-$M3_width]"
#set M3_offset               [expr $M1_offset+ 3*$M3_pitch]
set M3_offset               [expr 0.032 + 13*$M3_pitch]


set M3_stapling             ""

#M4: VDD

set M4_VDD_offset               [expr $M2_offset]

#set M4_spacing              "[expr $M4_min_space + $M4_set2set_dist/2 + -2*$M4_pitch ]"
#set M4_spacing              "[expr 5*$M4_pitch - $M4_width ] [expr 5*$M4_pitch - $M4_width ]"
set M4_spacing              "[expr 10*$M4_pitch - $M4_width ]"
#set M4_VDD_stapling             "-stapling {0.424 0.259 1.292:1}"
#set M4_VDD_stapling             "-stapling {0.424 0.190--> 0.4085 1.292:1}"
set M4_VDD_stapling             "-stapling {0.424 0.646 1.292:1}"




#M4: VSS
set M4_set2set_dist         [expr 10*$M4_pitch]
set M4_VSS_offset               "0.41"
#set M4_spacing              "[expr $M4_min_space + $M4_set2set_dist/2 + -2*$M4_pitch ]"
set M4_spacing              "[expr 10*$M4_pitch - $M4_width ] "
#set M4_VSS_stapling             "-stapling {0.5 0.7 1.292:1}"
#set M4_VSS_stapling             "-stapling {0.5 0.836-->1.0175 1.292:1}"
set M4_VSS_stapling             "-stapling {0.5 1.292 1.292:1}"




#M5:
#set M5_set2set_dist         [expr 31*$M5_pitch]
#set M5_spacing               "[expr 16*$M5_pitch - $M5_min_space]"
set M5_set2set_dist          [expr 17*$M5_pitch]
set M5_spacing              "[expr 4*$M5_pitch - $M5_width ] [expr 4*$M5_pitch - $M5_width ] [expr 5*$M5_pitch - $M5_width]" 
set M5_offset               [expr 0.019 + 6*$M5_pitch]
set M5_stapling             ""
#set M5_stapling             "-stapling {0.4 M4}"
 


#M6:
set M6_set2set_dist         [expr 14* $M6_pitch]
set M6_offset               "-0.04"
set M6_spacing              [expr 6*$M6_pitch ]
set M6_stapling             " "
set M6_nets                 " VSS VDD"


#M7: VSS
set M7_set2set_dist          [expr 17*$M7_pitch]
#set M7_set2set_dist 	     1.300
set M7_VSS_spacing           [expr 16*$M7_pitch]
set M7_VSS_offset            -0.038 ; #   [expr 1.178 - 0.0255]
set M7_VSS_width             $M7_double_width
set M7_stapling             ""

#M7: VDD
set M7_VDD_spacing           [expr 4*$M7_pitch- $M7_width]
set M7_VDD_offset            [expr 0.399 + 0.0505 +0.0255]
set M7_VDD_width             $M7_width

#M8:
#set M8_set2set_dist         $M4_set2set_dist
#set M8_offset               [expr $M4_offset - 0*$M8_pitch ]
set M8_set2set_dist         [expr  7*$M8_pitch]
set M8_spacing              [expr 7*$M8_pitch- $M8_width]

set M8_offset               0.54

  #set M8_VSS_stapling             "-stapling {0.376 0.836-->1.14 1.292:1}"

  set M8_VSS_stapling             "-stapling {0.376 1.2905 1.292:1}"
  set M8_VSS_spacing              [expr 7*$M8_pitch- $M8_width]
  set M8_VSS_nets                 {VSS }

 # set M8_VDD_stapling             "-stapling {0.4720 0.19--> 0.494 1.292:1}"

  set M8_VDD_stapling             "-stapling {0.4720 0.6445 1.292:1}"
  set M8_VDD_spacing              [expr 7*$M8_pitch- $M8_width]
  set M8_VDD_nets                 {VDD }
  

#M9: VSS
#set M9_set2set_dist         [expr 14*$M9_pitch]
#set M9_spacing              "[expr $M9_min_space + 0*$M9_pitch] "
set M9_set2set_dist         [expr 17*$M9_pitch]
set M9_VSS_spacing          [expr 16*$M9_pitch]
set M9_VSS_offset           -0.038 ; #  
#set M9_VSS_offset           [expr 1.254 - 0.0255 +0.0255 ]
set M9_VSS_width             $M9_double_width

if {$MAX_ROUTING_LAYER == 10} {
   set M9_stapling   ""
} else {
   set M9_stapling   ""
}
#M9: VDD
set M9_VDD_spacing           [expr 4*$M9_pitch - $M9_width]
#set M9_VDD_offset            [expr 0.475 - 0.0065 - 0.0205+0.0255]
set M9_VDD_offset            0.475
set M9_VDD_width             $M9_width


#M10:
set M10_set2set_dist         $M8_set2set_dist
set M10_offset               $M8_offset
#  set M10_VSS_stapling   		 "-stapling {0.376 1.14 1.292:1}"
set M10_VSS_stapling   		 "-stapling {0.376 1.292 1.292:1}"
set M10_spacing               $M8_spacing
set M10_VSS_nets                  {VSS }
  
#  set M10_VDD_stapling   		 "-stapling {0.4720 0.494 1.292:1}"
set M10_VDD_stapling   		 "-stapling {0.4720 0.646 1.292:1}"
set M10_VDD_nets                  {VDD }



#M11: VSS
set M11_set2set_dist         $M9_set2set_dist
#set M11_VSS_offset               [expr 1.2540 - 0.076 + 0.0505 +0.0255]
set M11_VSS_offset               -0.038 ; # 
set M11_VSS_spacing              [expr 16*$M11_pitch]
set M11_stapling   ""

#M11: VDD
#set M11_VDD_offset               [expr 0.608 - 0.027 + 0.0255]
set M11_VDD_offset               0.608
set M11_VDD_spacing              [expr 7*$M11_pitch -$M11_pitch ]
set M11_stapling   ""





#M12:
set M12_set2set_dist        [expr 20*$M12_pitch]
#set M12_offset              [expr 2*$M12_pitch - $M12_width/2 + 0.032]
set M12_offset 		-0.113
set M12_spacing             "[expr 10*$M12_pitch- $M12_width]"
set M12_stapling   ""


#M13:
set M13_set2set_dist        [expr 34*$M13_pitch]
#set M13_offset               [expr 4*$M13_pitch - $M13_width/2 + 2.031 - 0.435 + 0.1075 ]
set M13_offset		    -0.23
set M13_spacing             [expr 17*$M13_pitch - $M13_width]

#M14:
set M14_set2set_dist	    [expr 20*$M14_pitch]
set M14_offset  	    -0.27
set M14_spacing 	    [expr 10*$M14_pitch - $M14_width]

#M15:
set M15_set2set_dist	    [expr 34*$M15_pitch]
#set M15_offset  	    [expr 3*$M15_pitch - $M15_width/2 + 3.6985]
set M15_offset  	    -0.675
set M15_spacing 	    [expr 17*$M15_pitch - $M15_width]
#M16:
set M16_set2set_dist	    [expr 10*$M16_pitch]	     ; # nead to be 80% utilization or less
set M16_offset  	    -0.7
set M16_spacing 	    [expr 5*$M16_pitch - $M16_width]

#M17:
set M17_set2set_dist	    [expr 28*$M17_pitch]     ;   # nead to be 80% utilization or less
set M17_offset  	    -2.025
set M17_spacing 	    [expr 14*$M17_pitch - $M17_width]
   


#########################
# Create temp blockages # 
#########################
# dont enter this if when adding PG for IR analysis
if {$ADD_TOP_POWER == "false"} {
   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block}] {
  	create_route_blockage -rects [join [get_computed_shapes [get_db $inst_dpo .place_halo_bbox] SIZEY 0.15]] -layers {M0 }  -name temp_mem_blockages
  	if {[regexp BSI [get_db $inst_dpo .base_cell] ]} {
		set X1 [lindex [get_db $inst_dpo .place_halo_bbox] 0 0]
		set X2 [lindex [get_db $inst_dpo .place_halo_bbox] 0 2]
		set Y1 [lindex [get_db $inst_dpo .place_halo_bbox] 0 1]
		set Y2 [lindex [get_db $inst_dpo .place_halo_bbox] 0 3]
	
	    create_route_blockage -rects [join [get_computed_shapes  "$X1 $Y1 $X2 $Y2" SIZEX 0.6755 SIZEY 0.15]] -layers {M1 }  -name temp_mem_blockages
	    set X1 [expr [lindex [get_db $inst_dpo .place_halo_bbox] 0 0] - 0.188]
	    
	    create_route_blockage -rects [join [get_computed_shapes  "$X1 $Y1 $X2 $Y2" SIZEX 0.6755 SIZEY 0.15]] -layers {M2}  -name temp_mem_blockages
	    
  	} else {
	    create_route_blockage -rects [join [get_computed_shapes [get_db $inst_dpo .place_halo_bbox] SIZEX 1.03]] -layers {M1 M2}  -name temp_mem_blockages
  	}
	set X1 [lindex [get_db $inst_dpo .place_halo_bbox] 0 0]
	set X2 [lindex [get_db $inst_dpo .place_halo_bbox] 0 2]
	set Y1 [lindex [get_db $inst_dpo .bbox] 0 1]
	set Y2 [lindex [get_db $inst_dpo .bbox] 0 3]
  	create_route_blockage -rects [join [get_computed_shapes "$X1 $Y1 $X2 $Y2" SIZEY 0.1195 SIZEX 0.0765]] -layers {M3 M4 M5}  -spacing 0 -name temp_mem_blockages
   }
   foreach inst_dpo [get_db place_blockages -if ".type==hard && .name == finishfp_place_blkg*"] {
  	create_route_blockage -rects [join [get_computed_shapes [get_db $inst_dpo .rects] SIZEY 0.05]] -layers {M0 }  -name temp_mem_blockages
   }

set BOUNDARY [lindex [get_db designs .boundary] 0]
for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL == $XU} {
		set XL [expr $XL - 0.3]
		set XU [expr $XU + 0.3]
		set cmd "create_route_blockage -rects { $XL $YL $XU $YU } -layers {M3 M5} -spacing 0   -name block_edge"
		echo $cmd
		eval $cmd
	}
}


#   set X2 [lindex [get_db designs .bbox] 0 2]
#   set X1 [expr $X2 - 0.3]
#   set Y1 [lindex [get_db designs .bbox] 0 1]
#   set Y2 [lindex [get_db designs .bbox] 0 3]
#
#   create_route_blockage -rects "$X1 $Y1 $X2 $Y2" -layers {M3 M5} -spacing 0   -name block_edge

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M0 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
   # delete_routes -type special -layer { M0 VIA0 M1 VIA1 M2 VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}

set BOUNDARY [lindex [get_db designs .boundary] 0]
for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL == $XU} {
		set XL [expr $XL - 0.028]
		set XU [expr $XU + 0.028]
	}
	if {$YL == $YU} {
		set YL [expr $YL - 0.028]
		set YU [expr $YU + 0.028]
	}
	set cmd "create_route_blockage -rects { $XL $YL $XU $YU } -layers {M0} -spacing 0   -name block_boundary"
	echo $cmd
	eval $cmd
}


   reset_db -category generate_special_via
   reset_db -category add_stripes

   set_db add_stripes_stacked_via_top_layer M0
   set_db add_stripes_stacked_via_bottom_layer M0
   set_db route_special_connect_broken_core_pin true

   route_special -nets {VSS VDD} -connect corePin -core_pin_target none -allow_jogging 0 -allow_layer_change 0 -core_pin_layer M0 -core_pin_width $M0_width -user_class M0_FOLLOWPIN

   delete_obj [get_db route_blockages *block_boundary*]

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M1 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
   # delete_routes -type special -layer {  VIA0 M1 VIA1 M2 VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   # M1
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M1
   set_db add_stripes_stacked_via_bottom_layer M0
   set_db add_stripes_stapling_nets_style side_to_side


   set cmd "add_stripes -layer M1 \
 		-width $M1_width \
 		-direction vertical \
 		-set_to_set_distance 3.876 \
 		-start_offset 0.755 \
		-stop_offset 0.0755 \
 		-create_pins 0 \
 		-nets {VDD VSS VDD VSS VDD VSS} \
 		-spacing {0.592 0.592 0.592 0.592 0.592 } \
 		-snap_wire_center_to_grid grid \
	"
   echo $cmd
   eval $cmd


##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M2 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
   # delete_routes -type special -layer {  VIA1 M2 VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M2
   set_db add_stripes_stacked_via_bottom_layer M1
   set_db add_stripes_stapling_nets_style side_to_side
   set cmd "add_stripes -layer M2 \
 		-width $M2_width \
 		-direction horizontal \
 		-set_to_set_distance 0.42 \
 		-start_offset 0.2 \
 		-create_pins 0 \
 		-nets {VDD VSS } \
 		-spacing {0.190 } \
 		-snap_wire_center_to_grid grid \
   "
   echo $cmd
   eval $cmd


##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M3 - M4 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
set BOUNDARY [lindex [get_db designs .boundary] 0]
for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL == $XU} {
		set XU [expr $XU + 0.04]
	}
	if {$YL == $YU} {
		set YU [expr $YU + 0.04]
		set YL [expr $YL - 0.04]
		set cmd "create_route_blockage -rects { $XL $YL $XU $YU } -layers {M3} -spacing 0   -name block_boundary"
		echo $cmd
		eval $cmd
	}
}

#   set X1 [lindex [get_db designs .bbox] 0 0]
#   set X2 [lindex [get_db designs .bbox] 0 2]
#   set Y1 [lindex [get_db designs .bbox] 0 1]
#   set Y2 [expr $Y1 + 0.04]
#   create_route_blockage -layers M3 -name block_boundary -rects "{$X1 $Y1} {$X2 $Y2}"
#
#   set Y2 [lindex [get_db designs .bbox] 0 3]
#   set Y1 [expr $Y2 - 0.04]
#
#   create_route_blockage -layers M3 -name block_boundary -rects "{$X1 $Y1} {$X2 $Y2}"


   # delete_routes -type special -layer { VIA2 M3 VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   # M3  stripes
   # spread only 1, create vias add the second

   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block && .base_cell == *BSI*}] {
	set X1 [expr [lindex [get_db $inst_dpo .place_halo_bbox] 0 0] - 0.238]
	set X2 [lindex [get_db $inst_dpo .place_halo_bbox] 0 2]
	set Y1 [lindex [get_db $inst_dpo .bbox] 0 1]
	set Y2 [lindex [get_db $inst_dpo .bbox] 0 3]
  	create_route_blockage -rects [join [get_computed_shapes "$X1 $Y1 $X2 $Y2" SIZEY 0.1195 SIZEX 0.0765]] -layers {M3 }  -spacing 0 -name M3_temp_mem_blockages
   }



   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M3
   set_db add_stripes_stacked_via_bottom_layer M2
   set_db add_stripes_stapling_nets_style side_to_side


   set cmd "add_stripes -layer M3 \
  		$M3_stapling \
 		-width $M3_width \
 		-direction vertical \
 		-set_to_set_distance [expr $M3_set2set_dist] \
 		-start_offset $M3_offset \
 		-create_pins 0 \
 		-nets {VDD  VSS } \
 		-spacing 0.61 \
  		-snap_wire_center_to_grid grid \
   "
   eval $cmd

   delete_obj [get_db route_blockages *M3_temp_mem_blockages*]

   # delete_routes -type special -layer {  VIA3 M4 VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}

   # M4  stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M4
   set_db add_stripes_stacked_via_bottom_layer M3
   set_db add_stripes_stapling_nets_style side_to_side

   set cmd "add_stripes -layer M4 \
 		-width $M4_width \
 		-direction horizontal \
 		-set_to_set_distance 0.42 \
 		-start_offset 0.2 \
 		-create_pins 0 \
 		-nets {VDD VSS } \
 		-spacing {0.190 } \
 		-snap_wire_center_to_grid grid \
   "
   echo $cmd
   eval $cmd




   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M3
   set_db add_stripes_stacked_via_bottom_layer M3
   set_db add_stripes_stapling_nets_style side_to_side
   set cmd "add_stripes -layer M3 \
  		$M3_stapling \
 		-width $M3_width \
 		-direction vertical \
 		-set_to_set_distance [expr $M3_set2set_dist] \
 		-start_offset [expr $M3_offset + 0.168 ] \
 		-create_pins 0 \
 		-nets {VDD  VSS } \
 		-spacing 0.61 \
  		-snap_wire_center_to_grid grid \
   "
   eval $cmd


   delete_obj [get_db route_blockages -if ".name==block_boundary*"]



   # replace VIA 01 with BRCM VIA


   puts "*** replace VIAGEN01 to P5VIA01A_V2 for VDD ***"
   set start_t_via [clock seconds]
   set SVIA_01 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M0" ]
   set i 0
   set size [llength $SVIA_01]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_01 {
	set current_via_def [get_db $via .via_def.name]
	if {[expr fmod ((round([get_db $via .point.y]/0.21) -1 ) /2,2)] == 1} {
		edit_update_via -from $current_via_def -to P5VIA01A_V2 -at [get_db $via .point]
	} else {
		edit_update_via -from $current_via_def -to P5VIA01_V2 -at [get_db $via .point]
		
	}
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"

   puts "*** replace VIAGEN01 to P5VIA01A_V2 for VSS ***"
   set start_t_via [clock seconds]
   set SVIA_01 [get_db [get_db net:VSS .special_vias] -if ".via_def.bottom_layer.name == M0" ]
   set i 0
   set size [llength $SVIA_01]
   set dec [expr int(floor($size*0.1))]

   foreach via $SVIA_01 {
	set current_via_def [get_db $via .via_def.name]
	if {[expr fmod ((round([get_db $via .point.y]/0.21) ) /2,2)] == 0} {
		edit_update_via -from $current_via_def -to P5VIA01A_V2 -at [get_db $via .point]
	} else {
		edit_update_via -from $current_via_def -to P5VIA01_V2 -at [get_db $via .point]
		
	}
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"

   # replace VIA 12 with BRCM VIA
   puts "*** replace VIAGEN12 to P5VIA12 for VDD ***"
   set start_t_via [clock seconds]
   set SVIA_12 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M1" ]
   set i 0
   set size [llength $SVIA_12]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_12 {
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA12 -at [get_db $via .point]
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"

   puts "*** replace VIAGEN12 to P5VIA12 for VSS ***"
   set start_t_via [clock seconds]
   set SVIA_12 [get_db [get_db net:VSS .special_vias] -if ".via_def.bottom_layer.name == M1" ]
   set i 0
   set size [llength $SVIA_12]
   set dec [expr int(floor($size*0.1))]

   foreach via $SVIA_12 {
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA12 -at [get_db $via .point]
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"


   # replace VIA 23 with BRCM VIA
   puts "*** replace VIAGEN23 to P5VIA23B for VDD ***"
   set start_t_via [clock seconds]
   set SVIA_23 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M2" ]
   set i 0
   set size [llength $SVIA_23]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_23 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA23B -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.084
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"
   
   puts "*** replace VIAGEN23 to P5VIA23B for VSS ***"
   set start_t_via [clock seconds]
   set SVIA_23 [get_db [get_db net:VSS .special_vias] -if ".via_def.bottom_layer.name == M2" ]
   set i 0
   set size [llength $SVIA_23]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_23 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA23B -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.084
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"


   # replace VIA 34 with BRCM VIA
   puts "*** replace VIAGEN34 to P5VIA34B for VDD ***"
   set start_t_via [clock seconds]
   set SVIA_34 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M3" ]
   set i 0
   set size [llength $SVIA_34]
   set dec [expr int(floor($size*0.1))]

   foreach via $SVIA_34 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA34B -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.084
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"
   
   puts "*** replace VIAGEN34 to P5VIA34B for VSS ***"
   set start_t_via [clock seconds]
   set SVIA_34 [get_db [get_db net:VSS .special_vias] -if ".via_def.bottom_layer.name == M3" ]
   set i 0
   set size [llength $SVIA_34]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_34 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA34B -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.084
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"




   puts "-I-  remove M1 , M2 , M4 stripes"

   select_obj [get_db [get_db net:VDD .special_wires] -if ".layer.name == M1"]
   delete_routes -selected -wires_only
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M1"]
   delete_routes -selected  -wires_only
   select_obj [get_db [get_db net:VDD .special_wires] -if ".layer.name == M2"]
   delete_routes -selected -wires_only
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M2"]
   delete_routes -selected  -wires_only


##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M5 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################

   # delete_routes -type special -layer {   VIA4 M5 VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
  
   foreach inst_dpo [get_db insts -if {.base_cell.base_class == block && .base_cell == *BSI*}] {
	set X1 [expr [lindex [get_db $inst_dpo .place_halo_bbox] 0 0] - 0.196 - 0.108 -0.0265]
	set X2 [lindex [get_db $inst_dpo .place_halo_bbox] 0 2]
	set Y1 [lindex [get_db $inst_dpo .bbox] 0 1]
	set Y2 [lindex [get_db $inst_dpo .bbox] 0 3]
   
   	create_route_blockage -rects [join [get_computed_shapes "$X1 $Y1 $X2 $Y2" SIZEY 0.1195 SIZEX 0.0765]] -layers {M5}  -spacing 0 -name M5_temp_mem_blockages
  }


   # M5 stapling stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M5
   set_db add_stripes_stacked_via_bottom_layer M4
   set_db add_stripes_stapling_nets_style side_to_side
   set_db add_stripes_keep_pitch_after_snap true 
	 

   set cmd "add_stripes -layer M5  \
  		-width [expr 1*$M5_width] \
  		-direction vertical \
  		-set_to_set_distance $M5_set2set_dist \
  		-start_offset $M5_offset \
  		-create_pins 1 \
  		-spacing 0.57 \
  		-nets {VDD } \
   		-snap_wire_center_to_grid grid \
   "
   eval $cmd

   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}
   set cmd "add_stripes -layer M5  \
  		-width [expr 1*$M5_width] \
  		-direction vertical \
  		-set_to_set_distance $M5_set2set_dist \
  		-start_offset [expr $M5_offset + 0.608] \
  		-create_pins 1 \
  		-spacing 0.57 \
  		-nets {VSS} \
   		-snap_wire_center_to_grid grid \
   "
   eval $cmd

   delete_obj [get_db route_blockages *M5_temp_mem_blockages*]

   # M5 stapling stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M5
   set_db add_stripes_stacked_via_bottom_layer M5
   set_db add_stripes_stapling_nets_style side_to_side
   set_db add_stripes_keep_pitch_after_snap true 

   set cmd "add_stripes -layer M5  \
  		-width [expr 1*$M5_width] \
  		-direction vertical \
  		-set_to_set_distance $M5_set2set_dist \
  		-start_offset [expr $M5_offset + 0.304] \
  		-create_pins 1 \
  		-spacing 0.646 \
  		-nets {VDD } \
   		-snap_wire_center_to_grid grid \
   "
   eval $cmd

   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}
   set cmd "add_stripes -layer M5  \
  		-width [expr 1*$M5_width] \
  		-direction vertical \
  		-set_to_set_distance $M5_set2set_dist \
  		-start_offset [expr $M5_offset + 0.304 + 0.608 + 0.076] \
  		-create_pins 1 \
  		-spacing 0.646 \
  		-nets { VSS} \
   		-snap_wire_center_to_grid grid \
   "
   eval $cmd


   # replace VIA 45 with BRCM VIA
   puts "*** replace VIAGEN45 to P5VIA45B for VDD ***"  
   set start_t_via [clock seconds]
   set SVIA_45 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M4" ]
   set i 0
   set size [llength $SVIA_45]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_45 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA45B -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.152
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"
   
   puts "*** replace VIAGEN45 to P5VIA45A for VSS ***"  
   set start_t_via [clock seconds]
   set SVIA_45 [get_db [get_db net:VSS .special_vias] -if ".via_def.bottom_layer.name == M4" ]
   set i 0
   set size [llength $SVIA_45]
   set dec [expr int(floor($size*0.1))]

   foreach via $SVIA_45 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA45A -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.190
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"

   puts "-I-  remove M4 stripes"
   select_obj [get_db [get_db net:VDD .special_wires] -if ".layer.name == M4"]
   delete_routes -selected -wires_only
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M4"]
   delete_routes -selected  -wires_only


##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M6 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
  
   # delete_routes -type special -layer {    VIA5 M6 VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   # M6 stapling stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M6
   set_db add_stripes_stacked_via_bottom_layer M5
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA5_master

   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}

   set cmd "add_stripes -layer M6 \
   		$M6_stapling \
  		-width $M6_double_width \
  		-direction horizontal \
  		-set_to_set_distance $M6_set2set_dist \
  		-extend_to design_boundary \
  		-start_offset $M6_offset \
  		-stop_offset -0.076 \
  		-create_pins 1 \
  		-nets {VSS} \
  		-spacing \"$M6_spacing\" \
   "
   eval $cmd
   
   reset_db add_stripes_orthogonal_offset
   set cmd "add_stripes -layer M6 \
   		$M6_stapling \
  		-width $M6_double_width \
  		-direction horizontal \
  		-set_to_set_distance $M6_set2set_dist \
  		-extend_to design_boundary \
  		-start_offset [expr $M6_offset + 0.56] \
  		-stop_offset -0.076 \
  		-create_pins 1 \
  		-nets {VDD} \
  		-spacing \"$M6_spacing\" \
   "
   eval $cmd

   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M6}
   set_db edit_wire_width_horizontal $M6_double_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_status routed
   set_db edit_wire_cut_class {P5VIA56}
   set_db generate_special_via_preferred_vias_only keep

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$YL == $YU} {
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M6"]
   edit_merge_routes
   deselect_obj -all 

} ; # if {$ADD_TOP_POWER == "false"} 


##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M7 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################

if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 7) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 8 )} {
   # delete_routes -type special -layer {     VIA6 M7 VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   # M7 VSS stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M7
   set_db add_stripes_stacked_via_bottom_layer M6
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA6_VSS_master
   
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}
  

   set cmd "add_stripes -layer M7  \
  		$M7_stapling \
  		-width $M7_VSS_width  \
  		-direction vertical \
  		-extend_to design_boundary \
  		-set_to_set_distance $M7_set2set_dist \
  		-start_offset $M7_VSS_offset \
  		-stop_offset -0.076 \
  		-create_pins 1 \
  		-spacing \"$M7_VSS_spacing\" \
  		-nets {VSS } \
   "
   eval $cmd
  
   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M7}
   set_db edit_wire_layer_vertical {M7}
   set_db edit_wire_width_horizontal $M7_VSS_width
   set_db edit_wire_width_vertical $M7_VSS_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_status routed
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_cut_class $VIA6_VSS_master
   set_db generate_special_via_preferred_vias_only keep

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL == $XU} {
		puts "-I- adding M7 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
   
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M7"]
   edit_merge_routes
   deselect_obj -all 

  
   puts "create  M7 VSS ports"
   foreach wire_shape [get_db [get_db net:VSS .special_wires ] -if ".layer.name == M7"] {
       set llx [get_db $wire_shape  .rect.ll.x]
       set urx [get_db $wire_shape  .rect.ur.x]
       set lly [get_db $wire_shape  .rect.ll.y]
       set ury [get_db $wire_shape  .rect.ur.y]
   
#       set lly -0.076
       set lly [get_db $wire_shape  .rect.ll.y]
       set ury [expr $lly + 0.15]
       create_physical_pin -allow_outside_boundary -layer M7 -name VSS -rect "$llx $lly $urx $ury"
       
#       set ury [expr [lindex [get_db designs .bbox] 0 3] + 0.076]
       set ury [get_db $wire_shape  .rect.ur.y]
       set lly [expr $ury -0.15]
       create_physical_pin -allow_outside_boundary -layer M7 -name VSS -rect "$llx $lly $urx $ury"
   } 
   
   # M7 VDD stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M7
   set_db add_stripes_stacked_via_bottom_layer M6
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA6_VDD_master
   
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}
   
   
   set cmd "add_stripes -layer M7  \
  		$M7_stapling \
  		-width $M7_VDD_width  \
  		-direction vertical \
  		-set_to_set_distance $M7_set2set_dist \
  		-start_offset $M7_VDD_offset \
  		-create_pins 1 \
  		-spacing \"$M7_VDD_spacing\" \
  		-nets {VDD  } \
   "
   eval $cmd
  
  
  
   if {$MAX_ROUTING_LAYER < 9} {
	puts "*** replace VIAGEN76 to P5VIA67A for VDD ***"
   	set start_t_via [clock seconds]
	set SVIA_67 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M6 && .via_def.name == VIAGEN67*" ]
   	set i 0
   	set size [llength $SVIA_67]
   	set dec [expr int(floor($size*0.1))]
	
     	foreach via $SVIA_67 {
	   deselect_obj -all
	   select_obj $via
	   set current_via_def [get_db $via .via_def.name]
	   edit_update_via -from $current_via_def -to $VIA6_VDD_master -at [get_db $via .point]
	   move_obj -selected -direction right -distance 0.152

	   deselect_obj -all
	   incr i 
	   if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
     	}
   	set end_t_via [clock seconds]
   	puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"
	
     	set cmd "add_stripes -layer M7  \
  		   $M7_stapling \
  		   -width $M7_VDD_width  \
  		   -direction vertical \
  		   -set_to_set_distance $M7_set2set_dist \
  		   -start_offset [expr $M7_VDD_offset + 0.304] \
  		   -create_pins 1 \
  		   -spacing \"$M7_VDD_spacing\" \
  		   -nets {VDD  } \
  	"
     	eval $cmd
   }
  
   puts "create  M7 VDD ports"
   foreach wire_shape [get_db [get_db net:VDD .special_wires ] -if ".layer.name == M7"] {
	set llx [get_db $wire_shape  .rect.ll.x]
	set urx [get_db $wire_shape  .rect.ur.x]
	set lly [get_db $wire_shape  .rect.ll.y]
	set ury [get_db $wire_shape  .rect.ur.y]
   
#	set lly -0.076
       set lly [get_db $wire_shape  .rect.ll.y]
   	set ury [expr $lly + 0.15]
	create_physical_pin -allow_outside_boundary -layer M7 -name VDD -rect "$llx $lly $urx $ury"
	
#	set ury [expr [lindex [get_db designs .bbox] 0 3] + 0.076]
       set ury [get_db $wire_shape  .rect.ur.y]
	set lly [expr $ury -0.15]
	create_physical_pin -allow_outside_boundary -layer M7 -name VDD -rect "$llx $lly $urx $ury"
   } 
}

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M8 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################

if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 8) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 9 )} {
   # delete_routes -type special -layer {  VIA7 M8 VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   # M8 VDD VIAS

   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M8
   set_db add_stripes_stacked_via_bottom_layer M7
   set_db add_stripes_stapling_nets_style side_to_side
   
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.150}
    
   set cmd "add_stripes -layer M8 \
  		-width $M8_width \
  		-direction horizontal \
  		-set_to_set_distance $M8_set2set_dist \
  		-start_offset -0.02 \
		-stop_offset  -0.12 \
  		-create_pins 1 \
		-nets VDD \
  		-spacing $M8_VSS_spacing \
  		-snap_wire_center_to_grid grid \
   "
   eval $cmd


   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VDD}
   set_db edit_wire_layer_horizontal {M8}
   set_db edit_wire_layer_vertical {M8}
   set_db edit_wire_width_horizontal $M8_width
   set_db edit_wire_width_vertical $M8_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_status routed
   reset_db edit_wire_cut_class
   set_db generate_special_via_preferred_vias_only keep

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$YL == $YU} {
		puts "-I- adding M7 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP



   puts "*** replace VIAGEN67 to P5VIA67A for VDD ***"
   set start_t_via [clock seconds]
   set SVIA_67 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M6 && .via_def.name == VIAGEN67*" ]
   set i 0
   set size [llength $SVIA_67]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_67 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to $VIA6_VDD_master -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.152

	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"
    
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M7
   set_db add_stripes_stacked_via_bottom_layer M7
   set_db add_stripes_stapling_nets_style side_to_side
   
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}
   set cmd "add_stripes -layer M7  \
  		$M7_stapling \
  		-width $M7_VDD_width  \
  		-direction vertical \
  		-set_to_set_distance $M7_set2set_dist \
  		-start_offset [expr $M7_VDD_offset + 0.304] \
  		-create_pins 1 \
  		-spacing \"$M7_VDD_spacing\" \
  		-nets {VDD  } \
   "
   eval $cmd
   
   puts "create  M7 VDD ports"
   foreach wire_shape [get_db [get_db net:VDD .special_wires ] -if ".layer.name == M7"] {
	set llx [get_db $wire_shape  .rect.ll.x]
	set urx [get_db $wire_shape  .rect.ur.x]
	set lly [get_db $wire_shape  .rect.ll.y]
	set ury [get_db $wire_shape  .rect.ur.y]
   
#	set lly -0.076
       set lly [get_db $wire_shape  .rect.ll.y]
   	set ury [expr $lly + 0.15]
	create_physical_pin -allow_outside_boundary -layer M7 -name VDD -rect "$llx $lly $urx $ury"
	
#	set ury [expr [lindex [get_db designs .bbox] 0 3] + 0.076]
       set ury [get_db $wire_shape  .rect.ur.y]
	set lly [expr $ury -0.15]
	create_physical_pin -allow_outside_boundary -layer M7 -name VDD -rect "$llx $lly $urx $ury"
   } 

   puts "*** replace VIAGEN78 to P5VIA78A for VDD ***"
   set start_t_via [clock seconds]
   set SVIA_78 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M7" ]
   set i 0
   set size [llength $SVIA_78]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_78 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA78A -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.152
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"

   select_obj [get_db [get_db net:VDD .special_wires] -if ".layer.name == M8"]
   delete_routes -selected -wires_only


   # M8 VSS stapling stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M8
   set_db add_stripes_stacked_via_bottom_layer M7
   set_db add_stripes_stapling_nets_style side_to_side
   
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.150}
 
   set cmd "add_stripes -layer M8 \
  		-width $M8_width \
  		-direction horizontal \
  		-set_to_set_distance $M8_set2set_dist \
  		-start_offset -0.02 \
		-stop_offset  -0.12 \
  		-create_pins 1 \
		-nets VSS \
  		-spacing \"$M8_VSS_spacing\" \
  		-snap_wire_center_to_grid grid \
   	"
   eval $cmd
   
   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M8}
   set_db edit_wire_layer_vertical {M8}
   set_db edit_wire_width_horizontal $M8_width
   set_db edit_wire_width_vertical $M8_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_status routed
   set_db edit_wire_look_down_layers {1}
   reset_db edit_wire_cut_class
   set_db generate_special_via_preferred_vias_only keep
   
   set STOP_DRC [get_db edit_wire_stop_at_drc]
   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL < $XU} {
#		set XL [expr $XL - 0.35]
#		set XU [expr $XU + 0.35]
	} else {
#		set XL [expr $XL + 0.35]
#		set XU [expr $XU - 0.35]
	}
	if {$YL == $YU} {
		puts "-I- adding M7 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
   set_db edit_wire_stop_at_drc  $STOP_DRC
 
   puts "*** replace VIAGEN78 to P5VIA78B for VSS ***"
   set start_t_via [clock seconds]
   set SVIA_78 [get_db [get_db net:VSS .special_vias] -if ".via_def.bottom_layer.name == M7" ]
   set i 0
   set size [llength $SVIA_78]
   set dec [expr int(floor($size*0.1))]
  
   foreach via $SVIA_78 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA78B -at [get_db $via .point]
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"

   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M8"]
   delete_routes -selected -wires_only
}

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M9 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################

if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 9) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 10 )} {
   # delete_routes -type special -layer { VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   #  M9 VSS  stapling stripes

   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M8
   set_db add_stripes_stacked_via_bottom_layer M8
   set_db add_stripes_stapling_nets_style side_to_side
   
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.150}
 
   set cmd "add_stripes -layer M8 \
  		-width $M8_width \
  		-direction horizontal \
  		-set_to_set_distance $M8_set2set_dist \
  		-start_offset -0.02 \
		-stop_offset  -0.12 \
  		-create_pins 1 \
		-nets VSS \
  		-spacing \"$M8_VSS_spacing\" \
  		-snap_wire_center_to_grid grid \
   "
   eval $cmd

   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M8}
   set_db edit_wire_layer_vertical {M8}
   set_db edit_wire_width_horizontal $M8_width
   set_db edit_wire_width_vertical $M8_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_status routed
   set_db edit_wire_look_down_layers {1}
   reset_db edit_wire_cut_class
   set_db generate_special_via_preferred_vias_only keep
   
   set STOP_DRC [get_db edit_wire_stop_at_drc]
   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL < $XU} {
#		set XL [expr $XL - 0.35]
#		set XU [expr $XU + 0.35]
	} else {
#		set XL [expr $XL + 0.35]
#		set XU [expr $XU - 0.35]
	}
	if {$YL == $YU} {
		puts "-I- adding M8 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
   set_db edit_wire_stop_at_drc  $STOP_DRC



   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M9
   set_db add_stripes_stacked_via_bottom_layer M8
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA8_master
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.038}
   
   set cmd "add_stripes -layer M9  \
  		$M9_stapling \
  		-width $M9_VSS_width \
  		-direction vertical \
  		-set_to_set_distance $M9_set2set_dist \
  		-start_offset $M9_VSS_offset \
		-stop_offset  -0.12 \
  		-create_pins 1 \
  		-spacing \"$M9_VSS_spacing\" \
  		-nets { VSS } \
   "
   eval $cmd

   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M9}
   set_db edit_wire_layer_vertical {M9}
   set_db edit_wire_width_horizontal $M9_VSS_width
   set_db edit_wire_width_vertical $M9_VSS_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_status routed
   reset_db edit_wire_cut_class 
   reset_db generate_special_via_rule_preference
   set_db generate_special_via_preferred_vias_only keep
   
#   set STOP_DRC [get_db edit_wire_stop_at_drc]
#   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL == $XU} {
		puts "-I- adding M9 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
#   set_db edit_wire_stop_at_drc  $STOP_DRC

   
   
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M8"]
   delete_routes -selected -wires_only

   puts "*** replace VIAGEN89 to P5VIA89B for VSS ***"
   set start_t_via [clock seconds]
   set SVIA_89 [get_db [get_db net:VSS .special_vias] -if ".via_def.bottom_layer.name == M8" ]
   set i 0
   set size [llength $SVIA_89]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_89 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA89B -at [get_db $via .point]
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"


   # delete_routes -type special -layer { VIA8 M9 VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   #  M9 VDD  stapling stripes

   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M8
   set_db add_stripes_stacked_via_bottom_layer M8
   set_db add_stripes_stapling_nets_style side_to_side
   
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.150}
 
   set cmd "add_stripes -layer M8 \
  		-width $M8_width \
  		-direction horizontal \
  		-set_to_set_distance $M8_set2set_dist \
  		-start_offset -0.02 \
		-stop_offset  -0.12 \
		-nets VDD \
  		-spacing $M8_VSS_spacing \
  		-snap_wire_center_to_grid grid \
   "
   eval $cmd
   
   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VDD}
   set_db edit_wire_layer_horizontal {M8}
   set_db edit_wire_layer_vertical {M8}
   set_db edit_wire_width_horizontal $M8_width
   set_db edit_wire_width_vertical $M8_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_status routed
   reset_db edit_wire_cut_class
   set_db generate_special_via_preferred_vias_only keep
   
   set STOP_DRC [get_db edit_wire_stop_at_drc]
   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL < $XU} {
#		set XL [expr $XL - 0.35]
#		set XU [expr $XU + 0.35]
	} else {
#		set XL [expr $XL + 0.35]
#		set XU [expr $XU - 0.35]
	}
	if {$YL == $YU} {
		puts "-I- adding M8 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
   set_db edit_wire_stop_at_drc  $STOP_DRC


   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M9
   set_db add_stripes_stacked_via_bottom_layer M8
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA8_master
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}
   
   set cmd "add_stripes -layer M9  \
  		$M9_stapling \
  		-width $M9_width \
  		-direction vertical \
  		-set_to_set_distance $M9_set2set_dist \
  		-start_offset $M9_VDD_offset \
  		-create_pins 1 \
  		-spacing \"$M9_VDD_spacing\" \
  		-nets {VDD   } \
   "
   eval $cmd
   

   puts "*** replace VIAGEN89 to P5VIA89A for VDD ***"
   set start_t_via [clock seconds]
   set SVIA_89 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M8" ]
   set i 0
   set size [llength $SVIA_89]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_89 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA89A -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.152
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"
  
   if {$MAX_ROUTING_LAYER < 11} {
  	set_db add_stripes_stacked_via_bottom_layer M9
   
   	set cmd "add_stripes -layer M9  \
  	  	   $M9_stapling \
  	  	   -width $M9_width \
  	  	   -direction vertical \
  	  	   -set_to_set_distance $M9_set2set_dist \
  	  	   -start_offset [expr $M9_VDD_offset + 0.304] \
  	  	   -create_pins 1 \
  	  	   -spacing \"$M9_VDD_spacing\" \
  	  	   -nets {VDD   } \
   	"
   	eval $cmd
   }
   
   select_obj [get_db [get_db net:VDD .special_wires] -if ".layer.name == M8"]
   delete_routes -selected -wires_only
   
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M9"]
   edit_merge_routes

}

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M10 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 10) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 11 )} {
   # delete_routes -type special -layer {  VIA9 M10 VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   # VSS M10 stapling stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M10
   set_db add_stripes_stacked_via_bottom_layer M9
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA9_master
  
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.188}


   set cmd "add_stripes -layer M10 \
  		-width $M10_width \
  		-direction horizontal \
  		-set_to_set_distance $M10_set2set_dist \
  		-start_offset -0.02 \
		-stop_offset  -0.12 \
		-nets VDD \
  		-spacing $M10_spacing \
   		-snap_wire_center_to_grid grid \
   "
   eval $cmd


   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VDD}
   set_db edit_wire_layer_horizontal {M10}
   set_db edit_wire_layer_vertical {M10}
   set_db edit_wire_width_horizontal $M10_width
   set_db edit_wire_width_vertical $M10_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_status routed
   reset_db edit_wire_cut_class
   set_db generate_special_via_preferred_vias_only keep
   reset_db generate_special_via_rule_preference
   
   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$YL == $YU} {
		puts "-I- adding M10 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP




   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M9
   set_db add_stripes_stacked_via_bottom_layer M9
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA8_master
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}
   set cmd "add_stripes -layer M9  \
  	  	$M9_stapling \
  	  	-width $M9_width \
  	  	-direction vertical \
  	  	-set_to_set_distance $M9_set2set_dist \
  	  	-start_offset [expr $M9_VDD_offset + 0.304] \
  	  	-create_pins 1 \
  	  	-spacing \"$M9_VDD_spacing\" \
  	  	-nets {VDD   } \
   "
   eval $cmd
  

   puts "*** replace VIAGEN910 to P5VIA910A for VDD ***"
   set start_t_via [clock seconds]
   set SVIA_910 [get_db [get_db net:VDD .special_vias] -if ".via_def.bottom_layer.name == M9 && .via_def.name == VIAGEN910*" ]
   set i 0
   set size [llength $SVIA_910]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_910 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA910A -at [get_db $via .point]
	move_obj -selected -direction right -distance 0.152
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"

   select_obj [get_db [get_db net:VDD .special_wires] -if ".layer.name == M10"]
   delete_routes -selected -wires_only



   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M10
   set_db add_stripes_stacked_via_bottom_layer M9
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA9_master
  
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.188}


   set cmd "add_stripes -layer M10 \
  		-width $M10_width \
  		-direction horizontal \
  		-set_to_set_distance $M10_set2set_dist \
  		-start_offset -0.02 \
		-stop_offset  -0.12 \
		-nets VSS \
  		-spacing $M10_spacing \
   		-snap_wire_center_to_grid grid \
   "
   eval $cmd

   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M10}
   set_db edit_wire_layer_vertical {M10}
   set_db edit_wire_width_horizontal $M10_width
   set_db edit_wire_width_vertical $M10_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_status routed
   reset_db edit_wire_cut_class
   set_db generate_special_via_preferred_vias_only keep
   reset_db generate_special_via_rule_preference
   
   set STOP_DRC [get_db edit_wire_stop_at_drc]
   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL < $XU} {
#		set XL [expr $XL - 0.35]
#		set XU [expr $XU + 0.35]
	} else {
#		set XL [expr $XL + 0.35]
#		set XU [expr $XU - 0.35]
	}
	if {$YL == $YU} {
		puts "-I- adding M7 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
   set_db edit_wire_stop_at_drc  $STOP_DRC


   puts "*** replace VIAGEN910 to P5VIA910A for VSS ***"
   set start_t_via [clock seconds]
   set SVIA_910 [get_db [get_db net:VSS .special_vias] -if ".via_def.bottom_layer.name == M9" ]
   set i 0
   set size [llength $SVIA_910]
   set dec [expr int(floor($size*0.1))]
   
   foreach via $SVIA_910 {
	deselect_obj -all
	select_obj $via
	set current_via_def [get_db $via .via_def.name]
	edit_update_via -from $current_via_def -to P5VIA910B -at [get_db $via .point]
	deselect_obj -all
	incr i 
	if { ![expr $i%$dec] } { puts "[format "    Completing %2.0f%s of VIAS (%d / %d)" [expr int(100*$i/$size)] % $i $size]"}
   }
   set end_t_via [clock seconds]
   puts "-I- Elapse time is [expr ($end_t_via - $start_t_via)/60/60/24] days , [clock format [expr $end_t_via - $start_t_via] -timezone UTC -format %T]"

   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M10"]
   delete_routes -selected -wires_only

}

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M11 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 11) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 12 )} {
   # delete_routes -type special -layer {   VIA10 M11 VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   # M11 VSS stripes

   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M10
   set_db add_stripes_stacked_via_bottom_layer M10
   set_db add_stripes_stapling_nets_style side_to_side
  
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.188}


   set cmd "add_stripes -layer M10 \
  		-width $M10_width \
  		-direction horizontal \
  		-set_to_set_distance $M10_set2set_dist \
  		-start_offset -0.02 \
		-stop_offset  -0.12 \
		-nets VDD \
  		-spacing $M10_spacing \
   		-snap_wire_center_to_grid grid \
   "
   eval $cmd

   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VDD}
   set_db edit_wire_layer_horizontal {M10}
   set_db edit_wire_layer_vertical {M10}
   set_db edit_wire_width_horizontal $M10_width
   set_db edit_wire_width_vertical $M10_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_status routed
   reset_db edit_wire_cut_class
   set_db generate_special_via_preferred_vias_only keep
   
   set STOP_DRC [get_db edit_wire_stop_at_drc]
   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL < $XU} {
#		set XL [expr $XL - 0.35]
#		set XU [expr $XU + 0.35]
	} else {
#		set XL [expr $XL + 0.35]
#		set XU [expr $XU - 0.35]
	}
	if {$YL == $YU} {
		puts "-I- adding M10 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
   set_db edit_wire_stop_at_drc  $STOP_DRC


   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M11
   set_db add_stripes_stacked_via_bottom_layer M10
   set_db generate_special_via_rule_preference $VIA10_master

   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.038}
   # M11 VDD stripes
   set cmd "add_stripes -layer M11  \
  		$M11_stapling \
  		-width $M11_double_width \
  		-direction vertical \
  		-set_to_set_distance $M11_set2set_dist \
  		-start_offset $M11_VDD_offset \
  		-create_pins 1 \
  		-spacing \"$M11_VDD_spacing\" \
  		-nets {VDD } \
   "
   eval $cmd
   
   select_obj [get_db [get_db net:VDD .special_wires] -if ".layer.name == M10"]
   delete_routes -selected -wires_only

   # M11 VSS stripes

   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M10
   set_db add_stripes_stacked_via_bottom_layer M10
   set_db add_stripes_stapling_nets_style side_to_side
  
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.188}


   set cmd "add_stripes -layer M10 \
  		-width $M10_width \
  		-direction horizontal \
  		-set_to_set_distance $M10_set2set_dist \
  		-start_offset -0.02 \
		-stop_offset  -0.12 \
		-nets VSS \
  		-spacing $M10_spacing \
   		-snap_wire_center_to_grid grid \
   "
   eval $cmd

   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M10}
   set_db edit_wire_layer_vertical {M10}
   set_db edit_wire_width_horizontal $M8_width
   set_db edit_wire_width_vertical $M8_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_status routed
   reset_db edit_wire_cut_class
   set_db generate_special_via_preferred_vias_only keep
   reset_db generate_special_via_rule_preference
   set STOP_DRC [get_db edit_wire_stop_at_drc]
   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL < $XU} {
#		set XL [expr $XL - 0.35]
#		set XU [expr $XU + 0.35]
	} else {
#		set XL [expr $XL + 0.35]
#		set XU [expr $XU - 0.35]
	}
	if {$YL == $YU} {
		puts "-I- adding M10 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
   set_db edit_wire_stop_at_drc  $STOP_DRC



   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M11
   set_db add_stripes_stacked_via_bottom_layer M10
   set_db generate_special_via_rule_preference $VIA10_master

   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.1525}

   set cmd "add_stripes -layer M11  \
  		$M11_stapling \
  		-width $M11_double_width \
  		-direction vertical \
  		-set_to_set_distance $M11_set2set_dist \
  		-start_offset $M11_VSS_offset \
		-stop_offset  -0.12 \
  		-create_pins 1 \
  		-spacing \"$M11_VSS_spacing\" \
  		-nets {VSS } \
   "
   eval $cmd
   
   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M11}
   set_db edit_wire_layer_vertical {M11}
   set_db edit_wire_width_horizontal $M11_double_width
   set_db edit_wire_width_vertical $M11_double_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_status routed
   reset_db edit_wire_cut_class 
   reset_db generate_special_via_rule_preference
   set_db generate_special_via_preferred_vias_only keep
   
#   set STOP_DRC [get_db edit_wire_stop_at_drc]
#   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL == $XU} {
		puts "-I- adding M11 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
#   set_db edit_wire_stop_at_drc  $STOP_DRC

   
  
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M10"]
   delete_routes -selected -wires_only
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M11"]
   edit_merge_routes
   deselect_obj -all 

   
}
  

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M12 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 12) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 13 )} { 
   # delete_routes -type special -layer {   VIA11 M12 VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   # M12 stripes
   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M12}
   set_db edit_wire_layer_vertical {M12}
   set_db edit_wire_width_horizontal $M12_width
   set_db edit_wire_width_vertical $M12_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_cut_class $VIA11_master
   set_db edit_wire_status routed
   set_db generate_special_via_preferred_vias_only keep
   set_db generate_special_via_rule_preference $VIA11_master
   
#   set STOP_DRC [get_db edit_wire_stop_at_drc]
#   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL < $XU} {
		set XL [expr $XL - 0.247]
		set XU [expr $XU + 0.247]
	} else {
		set XL [expr $XL + 0.247]
		set XU [expr $XU - 0.247]
	}
	if {$YL == $YU} {
		puts "-I- adding M12 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  
   set_db edit_wire_snap  $SNAP
#   set_db edit_wire_stop_at_drc  $STOP_DRC

   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M12
   set_db add_stripes_stacked_via_bottom_layer M11
   set_db generate_special_via_rule_preference $VIA11_master
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.247}

   set cmd "add_stripes -layer M12 \
 		$M12_stapling \
 		-width $M12_width \
 		-direction horizontal \
 		-set_to_set_distance $M12_set2set_dist \
  		-create_pins 1 \
 		-nets {VSS  } \
 		-spacing \"$M12_spacing\" \
		-stop_offset  -0.15 \
 		-start_offset $M12_offset \
   "
   eval $cmd 

   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M12"]
   edit_merge_routes
   deselect_obj -all 




   reset_db add_stripes_orthogonal_offset 

   set cmd "add_stripes -layer M12 \
 		$M12_stapling \
 		-width $M12_width \
 		-direction horizontal \
 		-set_to_set_distance $M12_set2set_dist \
  		-create_pins 1 \
 		-nets { VDD } \
 		-spacing $M12_spacing \
 		-start_offset [expr $M12_offset + 1.26] \
   "
   eval $cmd 
   
} 

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M13 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 13) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 14 )} { 
   # delete_routes -type special -layer {  VIA12 M13 VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17}
   # M13 stripes
   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M13}
   set_db edit_wire_layer_vertical {M13}
   set_db edit_wire_width_horizontal $M13_width
   set_db edit_wire_width_vertical $M13_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_cut_class  $VIA12_master
   set_db edit_wire_status routed
   set_db generate_special_via_preferred_vias_only keep
   set_db generate_special_via_rule_preference $VIA12_master
   
#   set STOP_DRC [get_db edit_wire_stop_at_drc]
#   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$YL < $YU} {
		set YL [expr $YL - 0.280]
		set YU [expr $YU + 0.280]
	} else {
		set YL [expr $YL + 0.280]
		set YU [expr $YU - 0.280]
	}
	if {$XL == $XU} {
		puts "-I- adding M11 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
   
   set_db edit_wire_snap  $SNAP

   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M13
   set_db add_stripes_stacked_via_bottom_layer M12
   set_db generate_special_via_rule_preference $VIA12_master
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.280}

   set cmd "add_stripes -layer M13 \
  		-width $M13_width \
  		-direction vertical \
  		-set_to_set_distance $M13_set2set_dist \
  		-nets {VSS } \
  		-spacing \"$M13_spacing\" \
  		-start_offset $M13_offset \
		-stop_offset  -0.25 \
  		-create_pins 1 \
   "
   eval $cmd

   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M13"]
   edit_merge_routes
   deselect_obj -all 

   reset_db add_stripes_orthogonal_offset 

   set cmd "add_stripes -layer M13 \
  		-width $M13_width \
  		-direction vertical \
  		-set_to_set_distance $M13_set2set_dist \
  		-nets { VDD} \
  		-spacing $M13_spacing \
  		-start_offset [expr $M13_offset + 2.261]  \
  		-create_pins 1 \
   "
   eval $cmd

}

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M14 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 14) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 15 )} { 
   # delete_routes -type special -layer {VIA13 M14 VIA14 M15 VIA15 M16 VIA16 M17 }
   # M14 stripes
  
   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db generate_special_via_rule_preference $VIA13_master
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M14}
   set_db edit_wire_layer_vertical {M14}
   set_db edit_wire_width_horizontal $M14_width
   set_db edit_wire_width_vertical $M14_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_cut_class $VIA13_master
   set_db edit_wire_status routed
   
   set_db generate_special_via_preferred_vias_only keep
   
#   set STOP_DRC [get_db edit_wire_stop_at_drc]
#   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$XL < $XU} {
		set XL [expr $XL - 0.675]
		set XU [expr $XU + 0.675]
	} else {
		set XL [expr $XL + 0.675]
		set XU [expr $XU - 0.675]
	}
	if {$YL == $YU} {
		puts "-I- adding M14 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
  

   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M14
   set_db add_stripes_stacked_via_bottom_layer M13
   set_db generate_special_via_rule_preference $VIA13_master

   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.675}

   set cmd "add_stripes -layer M14 \
		-width $M14_width \
		-direction horizontal \
    		-set_to_set_distance $M14_set2set_dist \
    		-create_pins 1 \
    		-nets {VSS } \
    		-spacing \"$M14_spacing\" \
    		-extend_to design_boundary \
    		-stop_offset  -0.28 \
    		-start_offset $M14_offset \
   "
   eval $cmd
  
  
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M14"]
   edit_merge_routes
   deselect_obj -all 
  
  
  
   reset_db add_stripes_orthogonal_offset 
   set cmd "add_stripes -layer M14 \
    		-width $M14_width \
		-direction horizontal \
    		-set_to_set_distance $M14_set2set_dist \
    		-create_pins 1 \
    		-nets { VDD} \
    		-spacing \"$M14_spacing\" \
    		-extend_to design_boundary \
    		-stop_offset  -0.28 \
    		-start_offset [expr $M14_offset + 2.52] \
   "
   eval $cmd  

}

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M15 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 15) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 16 )} {
   # delete_routes -type special -layer {VIA14 M15 VIA15 M16 VIA16 M17 }
   #  # M15 stripes
   set BOUNDARY [lindex [get_db designs .boundary] 0]
   
   set_db edit_wire_type special
   set_db edit_wire_nets {VSS}
   set_db edit_wire_layer_horizontal {M15}
   set_db edit_wire_layer_vertical {M15}
   set_db edit_wire_width_horizontal $M15_width
   set_db edit_wire_width_vertical $M15_width
   set_db edit_wire_look_up_layers {1}
   set_db edit_wire_look_down_layers {1}
   set_db edit_wire_cut_class  $VIA14_master
   set_db edit_wire_status routed
   set_db generate_special_via_preferred_vias_only keep
   set_db generate_special_via_rule_preference $VIA14_master
   
#   set STOP_DRC [get_db edit_wire_stop_at_drc]
#   set_db edit_wire_stop_at_drc  false

   set SNAP [get_db edit_wire_snap]
   set_db edit_wire_snap  false

   for {set i 0} {$i < [llength [lindex [get_db designs .boundary] 0]]} {incr i} {
	set XL [lindex $BOUNDARY $i 0]
	set YL [lindex $BOUNDARY $i 1]
	set j [expr $i+1]
	if {$j == [llength [lindex [get_db designs .boundary] 0]]} { set j 0}
	set XU [lindex $BOUNDARY $j 0]
	set YU [lindex $BOUNDARY $j 1]
	if {$YL < $YU} {
		set YL [expr $YL - 0.729]
		set YU [expr $YU + 0.729]
	} else {
		set YL [expr $YL + 0.729]
		set YU [expr $YU - 0.729]
	}
	if {$XL == $XU} {
		puts "-I- adding M11 to edge {[lindex $BOUNDARY $i]}{[lindex $BOUNDARY $j]}"
		edit_add_route_point $XL $YL
		edit_end_route_point $XU $YU	
	}
   }
   
   set_db edit_wire_snap  $SNAP
   
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M15
   set_db add_stripes_stacked_via_bottom_layer M14
   set_db generate_special_via_rule_preference $VIA14_master
  
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.729}

   set cmd "add_stripes -layer M15 \
    		-width $M15_width \
		-direction vertical \
    		-set_to_set_distance $M15_set2set_dist \
    		-create_pins 1 \
    		-nets {VSS } \
    		-spacing \"$M15_spacing\" \
    		-stop_offset  -0.7 \
    		-start_offset $M15_offset \
    		-extend_to design_boundary \
   "
   eval $cmd
   select_obj [get_db [get_db net:VSS .special_wires] -if ".layer.name == M15"]
   edit_merge_routes
   deselect_obj -all 
  
   reset_db add_stripes_orthogonal_offset 
   set cmd "add_stripes -layer M15 \
    		-width $M15_width \
		-direction vertical \
    		-set_to_set_distance $M15_set2set_dist \
    		-create_pins 1 \
    		-nets { VDD} \
    		-spacing \"$M15_spacing\" \
    		-stop_offset  -0.7 \
    		-start_offset [expr $M15_offset + 4.522] \
    		-extend_to design_boundary \
   "
   eval $cmd  

}

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M16 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 16) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 17 )} {
   # delete_routes -type special -layer {VIA15 M16 VIA16 M17 }
   # M16 stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M16 
   set_db add_stripes_stacked_via_bottom_layer M15 
   set_db generate_special_via_rule_preference $VIA15_master
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -2.025}
  
  
   set cmd "add_stripes \
		-layer M16 \
		-width $M16_width \
		-direction horizontal \
		-set_to_set_distance $M16_set2set_dist  \
   		-create_pins 1 \
		-nets {VSS } \
		-spacing $M16_spacing \
		-start_offset $M16_offset \
    		-stop_offset  -0.73 \
		-extend_to design_boundary \
   "
   eval $cmd	

   reset_db add_stripes_orthogonal_offset 
   set cmd "add_stripes \
		-layer M16 \
		-width $M16_width \
		-direction horizontal \
		-set_to_set_distance $M16_set2set_dist  \
   		-create_pins 1 \
		-nets { VDD} \
		-spacing $M16_spacing \
		-start_offset [expr $M16_offset + 5.04] \
		-extend_to design_boundary \
   "
   eval $cmd	

}

##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert M17 PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER == 18) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 18 )} {
   #      delete_routes -type special -layer { VIA16 M17 RV AP}
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M17 
   set_db add_stripes_stacked_via_bottom_layer M16
   set_db generate_special_via_rule_preference $VIA16_master
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -1.325}

   set cmd "add_stripes \
		-layer M17 \
		-width $M17_width \
    		-create_pins 1 \
		-direction vertical \
		-set_to_set_distance $M17_set2set_dist  \
		-nets {VSS } \
		-spacing $M17_spacing \
		-start_offset $M17_offset \
    		-stop_offset  -2.1 \
		-extend_to design_boundary  "
		
   eval $cmd
	
   reset_db add_stripes_orthogonal_offset 
   set cmd "add_stripes \
		-layer M17 \
		-width $M17_width \
    		-create_pins 1 \
		-direction vertical \
		-set_to_set_distance $M17_set2set_dist  \
		-nets { VDD} \
		-spacing $M17_spacing \
		-start_offset [expr $M17_offset + 13.566] \
    		-stop_offset  -2.1 \
		-extend_to design_boundary  "
		
   eval $cmd
}


##################################################################################################################################
##################################################################################################################################
##																##
##																##
##    insert AP PG														##
##																##
##																##
##																##
##################################################################################################################################
##################################################################################################################################

# AP
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER == 19) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 19 )} {
   # delete_routes -type special -layer {RV AP }
   # AP stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer AP
   set_db add_stripes_stacked_via_bottom_layer M17
  
#  set_db generate_special_via_ignore_design_boundary true
#  set_db generate_special_via_extend_out_wire_end true
#  set_db add_stripes_orthogonal_offset {all -2.025}
  
   set j 0
   while {[expr $j *(40*5)] < [lindex [get_db designs .bbox] 0 3]} {
	set i 0
     	while {[expr $i * (135.66 + 3.6 + 51.084+13.146)] <  [lindex [get_db designs .bbox] 0 2]} {
	   set X1 [expr $i*(135.66 + 3.6 + 51.084+13.146)]
	   set Y1 [expr $j*(40*5)]
	   set X2 [expr 51.084 + $X1]
	   set Y2 [expr 80+25.92+$Y1]
	   create_route_blockage -rects "[expr $X1 -6.573]  [expr $Y1 + 40] [expr $X2 + 6.573] [expr $Y2 -40]" -layers {AP }  -name AP_BUMP
	   if {$X2 > [lindex [get_db designs .bbox] 0 2]} {set X2 [lindex [get_db designs .bbox] 0 2]}
	   if {$Y2 > [lindex [get_db designs .bbox] 0 3]} {set Y2 [lindex [get_db designs .bbox] 0 3]}
	   if {[expr $j %2]} {
	   	# VDD
		create_shape -layer AP -net VDD -rect "$X1 $Y1 $X2 $Y2" -shape iowire -status routed
	   } else {
		# VSS
		create_shape -layer AP -net VSS -rect "$X1 $Y1 $X2 $Y2" -shape iowire -status routed
	   }
	   #create_route_blockage -rects "$X1 $Y1 $X2 $Y2" -layers {AP }  -name AP_BUMP
	   incr i
	}
   	incr j
   }
  
   set cmd "add_stripes \
		-layer AP \
		-width 25.92 \
		-direction horizontal \
    		-create_pins 0 \
		-set_to_set_distance 80  \
		-nets {VSS VDD} \
		-spacing 14.08 \
		-extend_to design_boundary "
		
   eval $cmd	
   delete_obj [get_db route_blockages *AP_BUMP*]
   
   puts "-I- create ploc file for redhawk."
   source ./scripts/flow/generate_voltus_AP_power_sources.tcl
}

delete_obj [get_db route_blockages *temp_mem_blockages*]
delete_obj [get_db route_blockages -if ".name == block_edge"]

#######################
# Colorize power mesh #
#######################
#eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}

##############
# DRC checks #
##############
delete_drc_markers
check_drc -limit 100000
#check_floorplan -odd_even_site_row

################################
# Fix potential Min DRC errors #
################################
#fix_via -min_step 
#eval_legacy {colorizePowerMesh  -colorize_geometry_only 0}
#check_drc -limit 100000



set end_t [clock seconds]
puts "-I- End running create_power_grid at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

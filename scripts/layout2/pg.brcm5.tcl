set_db edit_wire_snap false
source ./scripts/layout/cut_layer.tcl
source ./scripts/layout/cut_stop_layer.tcl
set_multi_cpu_usage -local_cpu 16 -cpu_per_remote_host 4 -remote_host 1 -keep_license true
check_script_location

set start_t [clock seconds]
puts "-I- Start running create_power_grid at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

if {1} {

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
# dont enter this if when adding PG for IR analysis
if {$ADD_TOP_POWER == "false"} {

   reset_db -category generate_special_via
   reset_db -category add_stripes

   set_db add_stripes_stacked_via_top_layer M0
   set_db add_stripes_stacked_via_bottom_layer M0
   set_db route_special_connect_broken_core_pin true

   route_special -nets {VSS VDD} -connect corePin -core_pin_target none -allow_jogging 0 -allow_layer_change 0 -core_pin_layer M0 -core_pin_width $M0_width -user_class M0_FOLLOWPIN


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
read_def scripts/layout/DEF4PG/M0_via12.def
source ./scripts/layout/cp_v.tcl
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
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M2
   set_db add_stripes_stacked_via_bottom_layer M2
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

#####cut M0 -M1

set lx [get_db current_design .bbox.ll.x]
set ly [get_db current_design .bbox.ll.y]
set ux [get_db current_design .bbox.ur.x]
set uy [get_db current_design .bbox.ur.y]

cut_view_setting 0 2 0

gui_select -append -line "$lx $uy $ux $uy"
delete_selected_from_floorplan
gui_select -append -line "$ux $ly $ux $uy"
delete_selected_from_floorplan

set uux [expr $ux+5]
set uuy [expr $uy +3]
gui_select -append -rect "$ux $ly $uux $uuy"
delete_selected_from_floorplan
gui_select -append -rect "$lx $uy $uux $uuy"
delete_selected_from_floorplan




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
set top_lx [get_db current_design .bbox.ll.x]
set top_ly [get_db current_design .bbox.ll.y]
set top_ux [get_db current_design .bbox.ur.x]
set top_uy [get_db current_design .bbox.ur.y]
set m3_sp 0.04
set b_gap 0.1
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
 		-start_offset $M3_offset \
 		-create_pins 0 \
 		-nets {VDD  VSS } \
 		-spacing 0.61 \
  		-snap_wire_center_to_grid grid \
  		-area {$top_lx [expr $top_ly+$m3_sp] [expr $top_ux-$b_gap] [expr $top_uy-$m3_sp]} \
   "
   eval $cmd







   # M4  stripes
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M4
   set_db add_stripes_stacked_via_bottom_layer M4
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

read_def scripts/layout/DEF4PG/P5VIA34B_m.def
reset_db -category generate_special_via
set_db generate_special_via_ignore_drc 1
set_db  generate_special_via_rule_preference P5VIA34B_m

update_power_vias  -bottom_layer M3 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M4  -create_via_on_signal_pins 1



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
  		-area {$top_lx [expr $top_ly+$m3_sp] [expr $top_ux -$b_gap] [expr $top_uy-$m3_sp]} \
   "
   eval $cmd





read_def scripts/layout/DEF4PG/VIA23_pg.def
reset_db -category generate_special_via
set_db  generate_special_via_rule_preference VIA23_pg
set_db generate_special_via_ignore_drc 1
update_power_vias  -bottom_layer M2 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M3  -create_via_on_signal_pins 1

####udi M5
  reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M5
   set_db add_stripes_stacked_via_bottom_layer M5
   set_db add_stripes_stapling_nets_style side_to_side
   set_db add_stripes_keep_pitch_after_snap true 
   
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}
   set m5_gap 0.22
   set cmd "add_stripes -layer M5  \
  		-width [expr 1*$M5_width] \
  		-direction vertical \
  		-set_to_set_distance $M5_set2set_dist \
  		-start_offset [expr $M5_offset + 0.608] \
  		-create_pins 1 \
  		-spacing 0.57 \
  		-nets {VSS} \
   		-snap_wire_center_to_grid grid \
   		-area {$top_lx $top_ly [expr $top_ux -$m5_gap] $top_uy} \
   "
   eval $cmd



read_def scripts/layout/DEF4PG/P5VIA45A_l.def
reset_db -category generate_special_via
set_db generate_special_via_ignore_drc 1
set_db  generate_special_via_rule_preference P5VIA45A_L

update_power_vias  -bottom_layer M4 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M5  -create_via_on_signal_pins 1

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
  		-start_offset $M5_offset \
  		-create_pins 1 \
  		-spacing 0.57 \
  		-nets {VDD } \
   		-snap_wire_center_to_grid grid \
   "
   eval $cmd

read_def scripts/layout/DEF4PG/P5VIA45B_S.def
reset_db -category generate_special_via
set_db generate_special_via_ignore_drc 1
set_db  generate_special_via_rule_preference P5VIA45B_S

update_power_vias  -bottom_layer M4 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M5  -create_via_on_signal_pins 1


deselect_obj -all
select_routes -obj_type wire -net VSS -layer M5
edit_copy -keep_net_name 0.38 0
deselect_obj -all


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

  reset_db -category add_stripes
   reset_db -category generate_special_via
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M6
   set_db add_stripes_stacked_via_bottom_layer M5
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA5_master

   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}

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
set_db gui_verbose db


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

} ; # if {$ADD_TOP_POWER == "false"}


if {($ADD_TOP_POWER == "true" &&  ($UPPER_LAYER < 8 || $UPPER_LAYER < 9 || $UPPER_LAYER < 10 ))} {
	delete_routes -net {VDD VSS} -type special -obj_type {wire via} -layer {M10 M9 M8 M7 VIA7 VIA8 VIA9 VIA10}
}



   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M7
   set_db add_stripes_stacked_via_bottom_layer M7
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
		-nets VDD \
  		-spacing $M8_VSS_spacing \
  		-snap_wire_center_to_grid grid \
   "
   eval $cmd


read_def scripts/layout/DEF4PG/P5VIA78A_pg.def
read_def scripts/layout/DEF4PG/P5VIA89A_pg.def
read_def scripts/layout/DEF4PG/P5VIA910A_pg.def

 

reset_db -category generate_special_via
set_db generate_special_via_ignore_drc 1
set_db  generate_special_via_rule_preference P5VIA78A_pg
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true

update_power_vias  -bottom_layer M7 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M8  -create_via_on_signal_pins 1
deselect_obj -all
select_routes -obj_type wire -layer M7 -nets VDD
edit_copy -keep_net_name 0.3040 0
deselect_obj -all
select_routes -obj_type wire -layer M8 -nets VDD
edit_update_route_net -to VSS
deselect_obj -all


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
  

reset_db -category generate_special_via
set_db generate_special_via_ignore_drc 1
set_db  generate_special_via_rule_preference P5VIA78B
 set_db generate_special_via_ignore_design_boundary true


update_power_vias  -bottom_layer M7 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M8  -create_via_on_signal_pins 1


update_power_vias  -bottom_layer M6 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M7  -create_via_on_signal_pins 1

select_routes -obj_type wire -layer M8 -nets VSS

edit_update_route_net -to VDD
deselect_obj -all


   puts "create  M7 VDD ports"
   foreach wire_shape [get_db [get_db net:VDD .special_wires ] -if ".layer.name == M7"] {
	set llx [get_db $wire_shape  .rect.ll.x]
	set urx [get_db $wire_shape  .rect.ur.x]
	set lly [get_db $wire_shape  .rect.ll.y]
	set ury [get_db $wire_shape  .rect.ur.y]
   
#	set lly -0.076
       set lly [get_db $wire_shape  .rect.ll.y]
	if {$lly < [get_db current_design .bbox.ll.y]} {
   	set ury [expr $lly + 0.15]
	create_physical_pin -allow_outside_boundary -layer M7 -name VDD -rect "$llx $lly $urx $ury"
	}
	
#	set ury [expr [lindex [get_db designs .bbox] 0 3] + 0.076]
        set ury [get_db $wire_shape  .rect.ur.y]
	if {$ury > [get_db current_design .bbox.ur.y]} {
	set lly [expr $ury -0.15]
	create_physical_pin -allow_outside_boundary -layer M7 -name VDD -rect "$llx $lly $urx $ury"
	}
   }

###################################
   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M9
   set_db add_stripes_stacked_via_bottom_layer M9
   set_db add_stripes_stapling_nets_style side_to_side
   set_db generate_special_via_rule_preference $VIA6_VDD_master
   
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true
   set_db add_stripes_orthogonal_offset {all -0.076}
   
   
   set cmd "add_stripes -layer M9  \
  		$M9_stapling \
  		-width $M9_VDD_width  \
  		-direction vertical \
  		-set_to_set_distance $M9_set2set_dist \
  		-start_offset $M7_VDD_offset \
  		-create_pins 1 \
  		-spacing \"$M9_VDD_spacing\" \
  		-nets {VDD  } \
   "
   eval $cmd
  

 
 

reset_db -category generate_special_via
set_db generate_special_via_ignore_drc 1
set_db  generate_special_via_rule_preference P5VIA89A_pg
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true

update_power_vias  -bottom_layer M8 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M9  -create_via_on_signal_pins 1




 
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


reset_db -category generate_special_via
set_db generate_special_via_ignore_drc 1
set_db  generate_special_via_rule_preference P5VIA910A_pg
   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true

update_power_vias  -bottom_layer M9 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M10  -create_via_on_signal_pins 1





deselect_obj -all
select_routes -obj_type wire -layer M9 -nets VDD
edit_copy -keep_net_name 0.3040 0
deselect_obj -all
select_routes -obj_type wire -layer M10 -nets VDD
edit_update_route_net -to VSS
deselect_obj -all

select_routes -obj_type wire -layer M8 -nets VDD
edit_update_route_net -to VSS
deselect_obj -all


   reset_db -category add_stripes
   reset_db -category generate_special_via
   set_db add_stripes_stacked_via_top_layer M9
   set_db add_stripes_stacked_via_bottom_layer M9
   set_db add_stripes_stapling_nets_style side_to_side
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
  

   reset_db -category add_stripes
   reset_db -category generate_special_via

   set_db generate_special_via_ignore_design_boundary true
   set_db generate_special_via_extend_out_wire_end true


update_power_vias  -bottom_layer M9 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M10  -create_via_on_signal_pins 1 -nets VSS
update_power_vias  -bottom_layer M8 -via_using_exact_crossover_size true  -add_vias 1 -orthogonal_only 0 -top_layer M9  -create_via_on_signal_pins 1 -nets VSS


deselect_obj -all
select_routes -obj_type wire -layer M8 -nets {VDD VSS}
delete_routes -selected  -wires_only
select_routes -obj_type wire -layer M4 -nets {VDD VSS}
delete_routes -selected  -wires_only
select_routes -obj_type wire -layer M2 -nets {VDD VSS}
delete_routes -selected  -wires_only




if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER == 7) } {delete_routes -net {VDD VSS} -type special -obj_type {wire via} -layer {M10 M9 M8 VIA7 VIA8 VIA9 VIA10}}
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER == 8) } {delete_routes -net {VDD VSS} -type special -obj_type {wire via} -layer {M10 M9 VIA8 VIA9 VIA10}}
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER == 9) } {delete_routes -net {VDD VSS} -type special -obj_type {wire via} -layer {M10  VIA9 VIA10}}
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER == 10) } {delete_routes -net {VDD VSS} -type special -obj_type {wire via} -layer {VIA10}}




if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 10) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 12 )} {


 
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


deselect_obj -all
select_routes -obj_type wire -layer M10 -nets VSS
edit_update_route_net -to VDD
deselect_obj -all

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
 


select_routes -obj_type wire -layer M10 -nets {VDD VSS}
delete_routes -selected  -wires_only

}
#####12
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 12) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 13 )} {

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
####13-15
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 13) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 14 )} {

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

if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 14) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 15 )} {

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
if {($ADD_TOP_POWER == "false" && $MAX_ROUTING_LAYER > 15) || ($ADD_TOP_POWER == "true" &&  $UPPER_LAYER < 16 )} {
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



#######cut pg over mem
source ./scripts/layout/cut_layer.tcl
#set llist [get_db [get_db insts -if {.base_cell.base_class == block && .base_cell == *BSI*}] .name ]
#cut_pg_over_macro -min_layer 0 -max_layer 5 -ext_all_side 2 -macros $llist


set llist [get_db [get_db insts -if {.base_cell.base_class == block && .base_cell == *M5*}] ]
if {$llist!=""} {


foreach mem $llist {

	set top_sp 0.1
	set bot_sp 0.1
	set right_sp 0.37
	set left_sp 0.37

	set t_ex [expr [get_db $mem .place_halo_top]+$top_sp]
	set b_ex [expr [get_db $mem .place_halo_bottom]+$bot_sp]
	set r_ex [expr [get_db $mem .place_halo_right]+$right_sp]
	set l_ex [expr [get_db $mem .place_halo_left]+$left_sp]
	set mem_name [get_db $mem .name]
	cut_pg_over_macro -min_layer 0 -max_layer 0 -right_ext $r_ex -left_ext $l_ex -top_ext $t_ex -bottom_ext $b_ex -macros $mem_name

	set top_sp -0.03
	set bot_sp -0.03
	set right_sp 0.37
	set left_sp 0.37

	set t_ex [expr [get_db $mem .place_halo_top]+$top_sp]
	set b_ex [expr [get_db $mem .place_halo_bottom]+$bot_sp]
	set r_ex [expr [get_db $mem .place_halo_right]+$right_sp]
	set l_ex [expr [get_db $mem .place_halo_left]+$left_sp]
	set mem_name [get_db $mem .name]


	cut_pg_over_macro -min_layer 0 -max_layer 2 -right_ext $r_ex -left_ext $l_ex -top_ext $t_ex -bottom_ext $b_ex -macros $mem_name

}
set llist [get_db [get_db insts -if {.base_cell.base_class == block && .base_cell == *M5*}] .name ]

cut_pg_over_macro -min_layer 2 -max_layer 4 -right_ext 1.1 -left_ext 1.1 -top_ext 0.31 -bottom_ext 0.31 -macros $llist                                                                                                          
cut_stop_layer -min_layer 5 -max_layer 5 -right_ext 1.2 -left_ext 1.2 -top_ext 0.31 -bottom_ext 0.31 -macros $llist                                                                                                          
}                 
set llist [get_db [get_db insts -if {.base_cell.base_class == block && .base_cell != *BSI*}] .name ]
if {$llist!=""} {	
#block                                                                                                                        
 cut_pg_over_macro -min_layer 0 -max_layer 0 -right_ext 0.37 -left_ext 0.37 -top_ext 0.1 -bottom_ext 0.1 -macros $llist
 cut_pg_over_macro -min_layer 0 -max_layer 2 -right_ext 0.37 -left_ext 0.37 -top_ext -0.03 -bottom_ext -0.03 -macros $llist
 cut_pg_over_macro -min_layer 2 -max_layer 5 -right_ext 1.2 -left_ext 1.2 -top_ext 0.11 -bottom_ext 0.11 -macros $llist
 #cut_pg_over_macro -min_layer 5 -max_layer 10 -right_ext 0.1 -left_ext 0.1 -top_ext 0.00 -bottom_ext 0.00 -macros $llist
}
gui_set_tool select

source ./scripts/layout/fix_via5_mem.tcl











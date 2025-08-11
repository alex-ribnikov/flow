set_db eco_honor_dont_use false
set_db eco_update_timing false
set_db eco_refine_place false
set_db eco_check_logical_equivalence false

set_db [get_db insts *levelx*] .place_status placed

foreach cell [get_db insts *levelx*] {
    eco_update_cell -insts [get_db $cell .name] -cells F6UNAA_LPDSINVGT7X320
}




### COPY VIA PILLAR FOR X PILLARS USE (FOR 5PINS / 7PINS)
# 1. WRITE DEF SELECTE TO SAVE CURRENT WORK - check
# /services/bespace/users/ory/nextflow_pn85_drop_ww33/be_work/brcm5/grid_quadrant/v4_pn85_cts_wip/pnr/vp_def_320w_wip4_2_and_a_half_pillars.def
# 2. LEAVE ONLY LEFTMOST PILLAR AND SAVE IT ALONE IN WRITE DEF - check
# /services/bespace/users/ory/nextflow_pn85_drop_ww33/be_work/brcm5/grid_quadrant/v4_pn85_cts_wip/pnr/vp_def_320w_wip6_1_pillar.def
# 3. RESTORE -> LEAVE ONLY 2 LEFTMOST PILLARS AND SAVE IT IN WRITE DEF
# /services/bespace/users/ory/nextflow_pn85_drop_ww33/be_work/brcm5/grid_quadrant/v4_pn85_cts_wip/pnr/vp_def_320w_wip5_2_pillars.def
# 4. RESTORE -> WRITE DOWN OFFSETS FOR EACH LAYER AND TRANSLATE TO CP COMMANDS PER LAYER -> RUN INDIVIDUALLY TO VERIFY
# 4.1 ADD M13,M14,M15 AS NEEDED
# 4.2 CHECK ON PT
# 
# 5. TEST ON DIFFERENT LPDS CELLS WITH 2-3-4 X5/X7 PILLARS 


# M3 offsets
#set m3_offset {0 2.604 5.208 7.812}


set net [get_nets n_place_FE_RN_12]


set m3_offset 5.208

set wires [get_db $net .wires -if .layer.name==M3]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M2]

so $wires
edit_copy $m3_offset 0 -keep_net_name 
so $vias
edit_copy $m3_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M4]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M3]

so $wires
edit_copy $m3_offset 0 -keep_net_name 
so $vias
edit_copy $m3_offset 0 -keep_net_name 


set m5_offset 5.168

set wires [get_db $net .wires -if .layer.name==M5]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M4]

so $wires
edit_copy $m5_offset 0 -keep_net_name 
so $vias
edit_copy $m5_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M6]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M5]

so $wires
edit_copy $m5_offset 0 -keep_net_name 
so $vias
edit_copy $m5_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M7]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M6]

so $wires
edit_copy $m5_offset 0 -keep_net_name 
so $vias
edit_copy $m5_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M8]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M7]

so $wires
edit_copy $m5_offset 0 -keep_net_name 
so $vias
edit_copy $m5_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M9]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M8]

so $wires
edit_copy $m5_offset 0 -keep_net_name 
so $vias
edit_copy $m5_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M10]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M9]

so $wires
edit_copy $m5_offset 0 -keep_net_name 
so $vias
edit_copy $m5_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M11]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M10]

so $wires
edit_copy $m5_offset 0 -keep_net_name 
so $vias
edit_copy $m5_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M12]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M11]

so $wires
edit_copy $m5_offset 0 -keep_net_name 
so $vias
edit_copy $m5_offset 0 -keep_net_name 


set m13_offset 4.921

set wires [get_db $net .wires -if .layer.name==M13]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M12]

so $wires
edit_copy $m13_offset 0 -keep_net_name 
so $vias
edit_copy $m13_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M14]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M13]

so $wires
edit_copy $m13_offset 0 -keep_net_name 
so $vias
edit_copy $m13_offset 0 -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M15]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M14]

so $wires
edit_copy $m13_offset 0 -keep_net_name 
so $vias
edit_copy $m13_offset 0 -keep_net_name 




#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################



set_db eco_honor_dont_use false
set_db eco_update_timing false
set_db eco_refine_place false
set_db eco_check_logical_equivalence false

set_db [get_cells levelx_tap_break_long_nets_n_1_3] .place_status placed
eco_update_cell -insts levelx_tap_break_long_nets_n_1_3 -cells F6UNAA_LPDSINVGR7X320

set net net:grid_quadrant/FE_RN_11

place_inst levelx_tap_break_long_nets_n_1_3 {4857.2655 2764.02} mx 

#
#set_db eco_honor_dont_use false
#set_db eco_update_timing false
#set_db eco_refine_place false
#set_db eco_check_logical_equivalence false
#
#foreach cell [get_db insts *levelx*] {
#    eco_update_cell -insts [get_db $cell .name] -cells F6UNAA_LPDSINVGR7X320
#}


########### CREATING ONE VP UP TO M14 ###########
read_def /services/bespace/users/ory/nextflow_pn85_drop_ww33/be_work/brcm5/grid_quadrant/v4_pn85_cts_wip/pnr/clk_wip_320t_up_to_m15.def


########### CP THIS VP TO CREATE 2 VPS ###########
set m3_offset 2.1
set m4_offset 2.1


set wires [get_db $net .wires -if .layer.name==M3]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M2]

so $wires
edit_copy 0 $m3_offset -keep_net_name 
so $vias
edit_copy 0 $m3_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M4]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M3]

so $wires
edit_copy 0 $m4_offset -keep_net_name 
so $vias
edit_copy 0 $m4_offset -keep_net_name 


set m5_offset 2.1
set m6_offset 2.24


set wires [get_db $net .wires -if .layer.name==M5]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M4]

so $wires
edit_copy 0 $m5_offset -keep_net_name 
so $vias
edit_copy 0 $m5_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M6]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M5]

so $wires
edit_copy 0 $m6_offset -keep_net_name 
so $vias
edit_copy 0 $m6_offset -keep_net_name 


set m7_offset 2.24
set m8_offset 2.24


set wires [get_db $net .wires -if .layer.name==M7]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M6]

so $wires
edit_copy 0 $m7_offset -keep_net_name 
so $vias
edit_copy 0 $m7_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M8]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M7]

so $wires
edit_copy 0 $m8_offset -keep_net_name 
so $vias
edit_copy 0 $m8_offset -keep_net_name 


set m9_offset 2.24
set m10_offset 2.24


set wires [get_db $net .wires -if .layer.name==M9]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M8]

so $wires
edit_copy 0 $m9_offset -keep_net_name 
so $vias
edit_copy 0 $m9_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M10]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M9]

so $wires
edit_copy 0 $m10_offset -keep_net_name 
so $vias
edit_copy 0 $m10_offset -keep_net_name 


set m11_offset 2.24
set m12_offset 2.52


set wires [get_db $net .wires -if .layer.name==M11]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M10]

so $wires
edit_copy 0 $m11_offset -keep_net_name 
so $vias
edit_copy 0 $m11_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M12]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M11]

so $wires
edit_copy 0 $m12_offset -keep_net_name 
so $vias
edit_copy 0 $m12_offset -keep_net_name 



set m13_offset 2.52
set m14_offset 2.52


set wires [get_db $net .wires -if .layer.name==M13]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M12]

so $wires
edit_copy 0 $m13_offset -keep_net_name 
so $vias
edit_copy 0 $m13_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M14]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M13]

so $wires
edit_copy 0 $m14_offset -keep_net_name 
so $vias
edit_copy 0 $m14_offset -keep_net_name 

########### CONNECT 2 VPS WITH M15 AND DUPLICATE ###########

set m3_offset 4.83
set m4_offset 4.788


set wires [get_db $net .wires -if .layer.name==M3]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M2]

so $wires
edit_copy 0 $m3_offset -keep_net_name 
so $vias
edit_copy 0 $m3_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M4]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M3]

so $wires
edit_copy 0 $m4_offset -keep_net_name -orientation mx
so $vias
edit_copy 0 $m4_offset -keep_net_name -orientation mx


set m5_offset 4.788
set m6_offset 5.04


set wires [get_db $net .wires -if .layer.name==M5]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M4]

so $wires
edit_copy 0 $m5_offset -keep_net_name  -orientation mx
so $vias
edit_copy 0 $m5_offset -keep_net_name  -orientation mx

set wires [get_db $net .wires -if .layer.name==M6]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M5]

so $wires
edit_copy 0 $m6_offset -keep_net_name 
so $vias
edit_copy 0 $m6_offset -keep_net_name 


set m7_offset 5.04
set m8_offset 5.04


set wires [get_db $net .wires -if .layer.name==M7]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M6]

so $wires
edit_copy 0 $m7_offset -keep_net_name 
so $vias
edit_copy 0 $m7_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M8]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M7]

so $wires
edit_copy 0 $m8_offset -keep_net_name 
so $vias
edit_copy 0 $m8_offset -keep_net_name 


set m9_offset  5.04
set m10_offset 5.04


set wires [get_db $net .wires -if .layer.name==M9]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M8]

so $wires
edit_copy 0 $m9_offset -keep_net_name 
so $vias
edit_copy 0 $m9_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M10]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M9]

so $wires
edit_copy 0 $m10_offset -keep_net_name 
so $vias
edit_copy 0 $m10_offset -keep_net_name 


set m11_offset 5.04
set m12_offset 5.04


set wires [get_db $net .wires -if .layer.name==M11]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M10]

so $wires
edit_copy 0 $m11_offset -keep_net_name 
so $vias
edit_copy 0 $m11_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M12]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M11]

so $wires
edit_copy 0 $m12_offset -keep_net_name 
so $vias
edit_copy 0 $m12_offset -keep_net_name 


set m13_offset 5.04
set m14_offset 5.04


set wires [get_db $net .wires -if .layer.name==M13]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M12]

so $wires
edit_copy 0 $m13_offset -keep_net_name 
so $vias
edit_copy 0 $m13_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M14]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M13]

so $wires
edit_copy 0 $m14_offset -keep_net_name 
so $vias
edit_copy 0 $m14_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M15]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M14]

so $wires
edit_copy 0 $m14_offset -keep_net_name 
so $vias
edit_copy 0 $m14_offset -keep_net_name 





#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################
#####################################################################################################################



set_db eco_honor_dont_use false
set_db eco_update_timing false
set_db eco_refine_place false
set_db eco_check_logical_equivalence false

set_db [get_cells levelx_tap_break_long_nets_n_1_3] .place_status placed
eco_update_cell -insts levelx_tap_break_long_nets_n_1_3 -cells F6UNAA_LPDSINVGR5X192

set net net:grid_quadrant/FE_RN_11

place_inst levelx_tap_break_long_nets_n_1_3 {4888.4775 2758.14} r0 

read_def wip_192t_upto_m14_1vp.def

#
#set_db eco_honor_dont_use false
#set_db eco_update_timing false
#set_db eco_refine_place false
#set_db eco_check_logical_equivalence false
#
#foreach cell [get_db insts *levelx*] {
#    eco_update_cell -insts [get_db $cell .name] -cells F6UNAA_LPDSINVGR5X192
#}

set m3_offset 3.15
set m4_offset 3.15

set wires [get_db $net .wires -if .layer.name==M2]

so $wires
edit_copy 0 $m3_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M3]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M2]

so $wires
edit_copy 0 $m3_offset -keep_net_name 
so $vias
edit_copy 0 $m3_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M4]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M3]

so $wires
edit_copy 0 $m4_offset -keep_net_name -orientation mx
so $vias
edit_copy 0 $m4_offset -keep_net_name -orientation mx



set m5_offset 3.15
set m6_offset 3.36


set wires [get_db $net .wires -if .layer.name==M5]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M4]

so $wires
edit_copy 0 $m5_offset -keep_net_name  -orientation mx
so $vias
edit_copy 0 $m5_offset -keep_net_name  -orientation mx

set wires [get_db $net .wires -if .layer.name==M6]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M5]

so $wires
edit_copy 0 $m6_offset -keep_net_name 
so $vias
edit_copy 0 $m6_offset -keep_net_name 


set m7_offset 3.36
set m8_offset 3.36


set wires [get_db $net .wires -if .layer.name==M7]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M6]

so $wires
edit_copy 0 $m7_offset -keep_net_name 
so $vias
edit_copy 0 $m7_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M8]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M7]

so $wires
edit_copy 0 $m8_offset -keep_net_name 
so $vias
edit_copy 0 $m8_offset -keep_net_name 


set m9_offset  3.36
set m10_offset 3.36


set wires [get_db $net .wires -if .layer.name==M9]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M8]

so $wires
edit_copy 0 $m9_offset -keep_net_name 
so $vias
edit_copy 0 $m9_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M10]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M9]

so $wires
edit_copy 0 $m10_offset -keep_net_name 
so $vias
edit_copy 0 $m10_offset -keep_net_name 


set m11_offset 3.36
set m12_offset 2.52


set wires [get_db $net .wires -if .layer.name==M11]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M10]

so $wires
edit_copy 0 $m11_offset -keep_net_name 
so $vias
edit_copy 0 $m11_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M12]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M11]

so $wires
edit_copy 0 $m12_offset -keep_net_name 
so $vias
edit_copy 0 $m12_offset -keep_net_name 


set m13_offset 2.6
set m14_offset 2.52


set wires [get_db $net .wires -if .layer.name==M13]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M12]

so $wires
edit_copy 0 $m13_offset -keep_net_name 
so $vias
edit_copy 0 $m12_offset -keep_net_name 

set wires [get_db $net .wires -if .layer.name==M14]
set vias  [get_db $net .vias  -if .via_def.bottom_layer.name==M13]

so $wires
edit_copy 0 $m14_offset -keep_net_name 
so $vias
edit_copy 0 $m14_offset -keep_net_name 



#######################################################################################################################
#######################################################################################################################
#######################################################################################################################


enter_eco_mode

set cells2change [get_db insts -if .base_cell==base_cell:F6UNAA_LPDINVX48]

set_db $cells2change .place_status placed
eco_update_cell -insts [get_db $cells2change .name] -cells F6UNAA_LPDSINVG3X48

set net net:grid_quadrant/FE_RN_11

place_inst levelx_tap_break_long_nets_n_1_3 {4888.4775 2758.14} r0 

read_def wip_192t_upto_m14_1vp.def






















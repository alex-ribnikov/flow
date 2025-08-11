delete_obj [get_db [get_db nets .wires] -if .status==unknown]
delete_obj [get_db [get_db nets .vias ] -if .status==unknown]

#== get_all Super-Inverters X96
set SuperInvX96 [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }]
# set SuperInvX96 [get_db inst:grid_quadrant/level2_tap_b_t00]
#== Read the Via-Pillar ==#
create_net -name vp_net_right
create_net -name vp_net_left

#== Def with M15 ==#
read_def scripts/templates/quad/super_bufs/vp_def_right_m15

#== Def without M15 ==#
#read_def scripts/templates/quad/super_bufs/vp_def_right
read_def scripts/templates/quad/super_bufs/vp_def_left

set VPx 2643.05
set VPy 7798.35
set RefNetRight "vp_net_right"
set RefNetLeft  "vp_net_left"

foreach c $SuperInvX96 {
    #== Select the INV ==#
    so [get_db $c .name]

    #== Get all needed attributes ==#
    set llx_anchor [get_db $c .bbox.ll.x]
    set lly_anchor [get_db $c .bbox.ll.y]
    set OutNet [get_db [get_db selected .pins -if {.direction==out}] .net.name]
    set M3DistFromBBox 2.8565
    set M3DistFromBBox [expr 2.8565]
    set Diff 0.01
    set M5DistFromBBox [expr $M3DistFromBBox - $Diff]

    # if {$OutNet==$RefNet} {continue}
    #== Calcultate the Left VP new location ==#
    set New_M3_VP_xloc [expr $llx_anchor + $M3DistFromBBox - $VPx]
    set New_M5_VP_xloc [expr $llx_anchor + $M5DistFromBBox - $VPx]    
    set New_VP_yloc [expr $lly_anchor - $VPy]

    #== Calculate Right VP new Location ==#
    set Right_M3_VP_xloc [expr $llx_anchor + $M3DistFromBBox - $VPx - 2.584]
    set Right_M5_VP_xloc [expr $llx_anchor + $M5DistFromBBox - $VPx - 2.584]    


    #== Select wires/vias in M3/V3 ==#
    so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name == M3}] [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer==layer:VIA3}]]
    edit_copy $New_M3_VP_xloc $New_VP_yloc -net $OutNet
    so [concat [get_db [get_db net:$RefNetLeft ] .wires. -if {.layer.name == M3}] [get_db [get_db net:$RefNetLeft ] .vias -if {.via_def.cut_layer==layer:VIA3}]]
    edit_copy $Right_M3_VP_xloc $New_VP_yloc -net $OutNet
    
    #== Select wires/vias which are in M4-M12,M15/V4-V12==#    
    so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name != M3 && .layer.name != M13 && .layer.name != M14}] [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer != layer:VIA3 && .via_def.cut_layer != layer:VIA13 && .via_def.cut_layer != layer:VIA14}]]
    edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
    so [concat [get_db [get_db net:$RefNetLeft ] .wires. -if {.layer.name != M3 && .layer.name != M13 && .layer.name != M14}] [get_db [get_db net:$RefNetLeft ] .vias -if {.via_def.cut_layer != layer:VIA3 && .via_def.cut_layer != layer:VIA13 && .via_def.cut_layer != layer:VIA14}]]
    edit_copy $Right_M5_VP_xloc $New_VP_yloc -net $OutNet

    #== Select wires/vias which are in M13 ==#        
    so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name == M13}]]
    edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
    so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name == M13}]]
    edit_copy [expr $Right_M5_VP_xloc + 0.1] $New_VP_yloc -net $OutNet

   #== Select wires/vias which are in V13 ==#        
    so [concat [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer==layer:VIA13}]]
    edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
    so [concat [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer==layer:VIA13}]]
    edit_copy [expr $Right_M5_VP_xloc + 0.1] $New_VP_yloc -net $OutNet

    
    #== Select wires/vias which in M14 ==#        
    so [concat [get_db [get_db net:$RefNetRight ] .wires. -if {.layer.name == M14}]]
    edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
    so [concat [get_db [get_db net:$RefNetLeft ] .wires. -if {.layer.name == M14}]]
    edit_copy $Right_M5_VP_xloc [expr $New_VP_yloc - 0.25] -net $OutNet

    #== Select wires/vias which are in V14 ==#        
    so [concat [get_db [get_db net:$RefNetRight ] .vias -if {.via_def.cut_layer==layer:VIA14}]]
    edit_copy $New_M5_VP_xloc $New_VP_yloc -net $OutNet
}

#== Clean all provios markers ==#
delete_markers -all

#== Check DRC for the Via-Pillar==#
redirect VP_Check_DRC {
  foreach n [get_db -uniq [get_db -uniq [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .pins -if {.direction == out}] .net.name] {
    so $n ; 
    puts "checking drc on net: [get_db selected  .name]" ; 
    check_drc -check_only selected_net
  }
}

#== Remove the redundant via-pillar ==#
delete_obj [concat [get_db [get_db net:$RefNetRight ] .wires] [get_db [get_db net:$RefNetRight ] .vias]]
delete_obj [concat [get_db [get_db net:$RefNetLeft  ] .wires] [get_db [get_db net:$RefNetLeft  ] .vias]]

delete_obj $RefNetRight
delete_obj $RefNetLeft

# so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name == M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer==layer:VIA3}]]
# edit_copy -3.876 0 -net level2_tap_a_t00_net
# so [concat [get_db [get_db net:level2_tap_b_t00_net ] .wires. -if {.layer.name != M3}] [get_db [get_db net:level2_tap_b_t00_net ] .vias -if {.via_def.cut_layer != layer:VIA3}]]
# edit_copy -3.886 0 -net level2_tap_a_t00_net

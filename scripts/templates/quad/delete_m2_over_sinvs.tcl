set clock_cells [add_to_collection [get_cells -hier *level*tap*] [add_to_collection [get_cells -hier *tree_source*] [get_cells -hier *i_grid_clk_dt_icg_i_clk_gate_SIZE_ONLY*]]]
set clock_nets  [get_db [get_nets -of [get_pins -of $clock_cells -filter direction==out]]]
set from_east_clock_nets [get_nets -of [get_ports grid_clk_from_east*]]
set clock_nets  [concat [concat $clock_nets [get_db $from_east_clock_nets]] [get_db nets grid_clk]]


set m2w {}
set m2v {}
foreach box [get_db [get_db insts -if .base_cell==*F6UNAA_LPDSINVGT5X96*] .bbox] {
    
    lappend m2w [get_db [get_wires_within $box M2]]
    set vias [get_db [get_vias_within $box] -if .via_def.bottom_layer.name==M2||.via_def.top_layer.name==M2]    
    lappend m2v $vias
    
}
set m2w [join $m2w]
set m2v [join $m2v]


set m2w_filtered {}
foreach w $m2w { set net [get_nets [get_db $w .net]] ; set cc [common_collection $net [get_nets $clock_nets]] ; if { [sizeof $cc] > 0 || [get_db $net .name]=="VDD" || [get_db $net .name]=="VSS" } {  } { lappend m2w_filtered $w  } }

set m2v_filtered {}
foreach v $m2v { set net [get_nets [get_db $v .net]] ; set cc [common_collection $net [get_nets $clock_nets]] ; if { [sizeof $cc] > 0 || [get_db $net .name]=="VDD" || [get_db $net .name]=="VSS" } {  } { lappend m2v_filtered $v  } }

if { [llength $m2w_filtered] > 0 } { delete_obj $m2w_filtered }
if { [llength $m2v_filtered] > 0 } { delete_obj $m2v_filtered }

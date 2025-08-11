set pattern "_AO2B222_"
foreach cc [get_db [get_db base_cells *${pattern}*_1] .name ] {
    set_cell_edge_spacing GROUP1 GROUP2 -spacing 0.21        
    set_cell_edge_type -cell $cc -top GROUP1 -range 0 0.2
    set_cell_edge_type -cell $cc -bottom GROUP2 -range 0 0.2
    set_cell_edge_type -cell $cc -bottom GROUP1 -range 0 0.2
    set_cell_edge_type -cell $cc -top GROUP2 -range 0 0.2
}
set pattern "_AOI32_"
foreach cc [get_db [get_db base_cells *${pattern}*_1] .name ] {
    set_cell_edge_spacing GROUP1 GROUP2 -spacing 0.21        
    set_cell_edge_type -cell $cc -top GROUP1 -range 0 0.2
    set_cell_edge_type -cell $cc -bottom GROUP2 -range 0 0.2
    set_cell_edge_type -cell $cc -bottom GROUP1 -range 0 0.2
    set_cell_edge_type -cell $cc -top GROUP2 -range 0 0.2
}


set cell F6LLAA_BORDERCORNERINTPTIERIGHT
foreach cor [get_db [get_db insts -if {.base_cell.name == $cell} ] -if {.orient == r180 || .orient == my}] {
	set ori [get_db $cor .orient ]
	set xx [expr [get_db $cor .location.x] -0.05]
	set yy [expr [get_db $cor .location.y] +0.05]
	set_db [get_obj_in_area -obj_type {inst} -polygons "$xx $yy"] .orient $ori
}















































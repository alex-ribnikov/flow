if {[info exists dest_dir] && [file isdir $dest_dir]} {
} else {
    set dest_dir .
}
#set collection_result_display_limit 10000
set module_name [get_db  [get_db designs] .name]
set v_file [open $dest_dir/${module_name}.mbr.temp w]
set d_file [open $dest_dir/${module_name}.mbr.debug w]


set exceptions [get_db exceptions -if .exception_type!="path_group"]
set froms [get_db $exceptions .from_points]
set tos [get_db $exceptions .to_points]
set throughs [get_db $exceptions .through_points]
set pins  [get_pins -quiet [join [concat $froms $tos $throughs]]]
set pins  [common_collection $pins [get_pins -of [get_cell -of  $pins -filter "ref_name=~*DFF*"]]]

foreach_in_collection pin $pins {
    set v_flop [get_cell -of $pin]
    set excs   [get_db $pin .exceptions.name]
    set types  [get_db $pin .exceptions.exception_type]
    
    puts $v_file [get_db  $v_flop .name]     
    puts $d_file "CELL: [get_db  $v_flop .name], EXCEPTIONS: $excs, EXCEPTIONS_TYPE: $types"
}


close $v_file
close $d_file

##########################
## Ignore exceptions
##########################
#set module_name [get_object_name [current_design]]
#set v_file [open ${module_name}.mbr a]
#
#redirect -variable exceptions {report_timing_requirements -ignored -nosplit}
#regsub -all "\\*" $exceptions "" exceptions
#regsub -all "\{" $exceptions "" exceptions
#regsub -all "\}" $exceptions "" exceptions
#foreach_in_collection v_flops [get_cells -quiet -of_objects [get_pins -quiet  [split $exceptions]] -filter "ref_name=~*DFF*"] {
#    puts $v_file [get_object $v_flops]
#}
#foreach_in_collection v_flops [get_cells -quiet [split $exceptions] -filter "ref_name=~*DFF*"] {
#    puts $v_file [get_object $v_flops]
#}
#close $v_file

#########################
# Append Case value
#########################
set v_file [open ${module_name}.mbr a]
set d_file [open ${module_name}.mbr.debug a]
foreach_in_collection ff [get_cells -quiet -of_objects [get_pins -quiet -of_objects [get_cells -hier * -filter "is_rise_edge_triggered==true"] -filter "pin_direction==out && (timing_case_logic_value==0 || timing_case_logic_value==1)"]] {
 puts $v_file [get_db $ff .name]
 puts $d_file "CELL: [get_db $ff .name], EXCEPTION: SET_CASE_ANALYSIS"
}
close $v_file
close $d_file

exec sort -u $dest_dir/${module_name}.mbr.temp > $dest_dir/${module_name}.mbr
exec rm -rf $dest_dir/${module_name}.mbr.temp

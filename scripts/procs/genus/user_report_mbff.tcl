proc user_report_mbff {report_name} {

  set sbff_cnt [lindex [get_metric design.instances.register] 1]
  set mbff_cell_list [get_db -unique  [get_db base_cells -if {.is_flop && .name==MB*} ] .name]
  set bit_list [lsort -u -integer -increasing [lsearch -all -inline -index 1 -subindices [lmap x $mbff_cell_list {regexp -all -inline -- {MB(\d+)} $x}] *]]
  
  set dict_bit_stat {}
  dict set dict_bit_stat mbff_count 0
  dict set dict_bit_stat total_bit_count 0
  foreach x $bit_list {
    dict set dict_bit_stat $x [llength [get_db -regexp [get_db insts -if {.is_flop}] .base_cell.name "^MB$x\\D"]]
    dict set dict_bit_stat mbff_count [expr [dict get $dict_bit_stat mbff_count] + [dict get $dict_bit_stat $x]]
    dict set dict_bit_stat total_bit_count [expr [dict get $dict_bit_stat total_bit_count] + $x * [dict get $dict_bit_stat $x]]
  }
  
  set total_ff_cnt [expr $sbff_cnt + [dict get $dict_bit_stat mbff_count]]
    
  set port [open $report_name a]
  
  get_metric -names design.instances.register
  puts $port ""
  puts $port "------------------------------------------------------------"
  puts $port "        Current design flip-flop statistics"
  puts $port ""
  puts $port [format "Single-Bit FF Count  :%13s" $sbff_cnt]
  puts $port [format "Multi-Bit FF Count   :%13s" [dict get $dict_bit_stat mbff_count]]
  
  foreach x $bit_list {
     puts $port [format "-%2s-Bit FF Count     :%13s" $x [dict get $dict_bit_stat $x]]
  }
  
  puts $port [format "Total Bit Count      :%13s" [dict get $dict_bit_stat total_bit_count]]
  puts $port [format "Total FF Count       :%13s" $total_ff_cnt]
  
  if $total_ff_cnt {
    puts $port [format "Bits Per Flop        :%13.3f" [expr 1.0 * [dict get $dict_bit_stat total_bit_count] / $total_ff_cnt]]
  } else {
    puts $port [format "Bits Per Flop        :%13s" "NA"]
  }
  
  puts $port "------------------------------------------------------------"
  puts $port ""
  close $port
  report_multibit_inferencing >> $report_name
}

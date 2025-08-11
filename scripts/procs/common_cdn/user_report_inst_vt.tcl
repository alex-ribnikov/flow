proc user_report_inst_vt {report_name} {
   
   set port [open $report_name w]

   set list_vt_groups [lsort -uniq [get_db [get_db base_cells] .voltage_threshold_group]]
   
   set total_cells [llength [get_db base_cells]]
   set total_insts [llength [get_db insts -if {.is_physical == false}]]
   
   puts $port "Number of VT partitions  = [llength $list_vt_groups]"                  
   puts $port "Standard cells in design = $total_cells"                                                                                 
   puts $port "Instances in design      = $total_insts"                                                                               
   puts $port "" 
   puts $port "Instance distribution across the VT partitions:"                                                                 
   puts $port "" 
  
   set sum_of_nbr 0
   set sum_of_cell_nbr 0
   foreach vt_group $list_vt_groups {
     set vt_nbr [llength [get_db insts .base_cell.voltage_threshold_group $vt_group]]
     set vt_cell_nbr [llength [get_db base_cells .voltage_threshold_group $vt_group]]
     set vt_percentage [expr $vt_nbr / $total_insts]
     set sum_of_nbr [expr $sum_of_nbr + $vt_nbr]
     set sum_of_cell_nbr [expr $sum_of_cell_nbr + $vt_cell_nbr]
     puts $port [format " %s : \tinst = %i (%.2f%%), \tcells = %i (%.2f%%)" $vt_group $vt_nbr [expr [expr 100 * $vt_nbr] / double($total_insts)] $vt_cell_nbr [expr [expr 100 * $vt_cell_nbr] / double($total_cells)]]
   }
   set vt_nbr [expr $total_insts - $sum_of_nbr]
   set vt_cell_nbr [expr $total_cells - $sum_of_cell_nbr]
   puts $port [format " OTHER : \tinst = %i (%.2f%%), \tcells = %i (%.2f%%)" $vt_nbr [expr [expr 100 * $vt_nbr] / double($total_insts)] $vt_cell_nbr [expr [expr 100 * $vt_cell_nbr] / double($total_cells)]]
   
  puts $port "" 
  close $port
   
}

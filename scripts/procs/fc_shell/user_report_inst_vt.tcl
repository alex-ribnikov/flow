proc user_report_inst_vt {report_name} {
   
   set port [open $report_name w]

   set list_vt_groups [lsort -unique [get_attribute [get_lib_cells] threshold_voltage_group]]
   
   set total_cells [sizeof_collection [get_lib_cells]]
   #set total_insts [sizeof_collection [get_cells -filter {!is_physical}]]
   set total_insts [sizeof_collection [get_cells]]
   
   puts $port "Number of VT partitions  = [llength $list_vt_groups]"                  
   puts $port "Standard cells in design = $total_cells"                                                                                 
   puts $port "Instances in design      = $total_insts"                                                                               
   puts $port "" 
   puts $port "Instance distribution across the VT partitions:"                                                                 
   puts $port "" 
  
   set sum_of_nbr 0
   set sum_of_cell_nbr 0
   foreach vt_group $list_vt_groups {
     set cmd "sizeof_collection \[get_cells -filter {lib_cell.threshold_voltage_group == $vt_group}\]"
     set vt_nbr [eval $cmd]
     set cmd "sizeof_collection \[get_lib_cells -filter {threshold_voltage_group == $vt_group}\]"
     set vt_cell_nbr [eval $cmd]
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

proc be_check_multiport {} {
    
    puts "-I- Running be_check_multiport"
    global STAGE
    global RUNNING_DIR
    set stage $STAGE
    if { $stage != "" } { set file_name ${RUNNING_DIR}/reports/${STAGE}/check_multiport.rpt } { set file_name reports/multiport.rpt }

    #== Open file ==#
    set fp [open "multiport" w+]

    #== Get all suspected output ports ==#
    set OutPorts [get_ports -filter {direction==out&&net.number_of_flat_loads>1}]
    puts $fp "Port-Name Reason/Issue\n--------- ------------"

    #== Check if MP or D&P ==#
    foreach_in_collection p $OutPorts {
#number_of_flat_loads
#leaf_loads

      set IsMultiPort [expr [sizeof  [filter_collection [get_attribute $p net.leaf_loads] object_class==port]] > 1]
      set IsLogic     [expr [sizeof  [filter_collection [get_attribute $p net.leaf_loads] object_class==pin ]] > 0]

      set n [get_object_name $p]
      
      if {$IsLogic} {
          puts $fp "$n Driving-Logic-and-Ports"
      } elseif {$IsMultiPort} {
          puts $fp "$n Driving-Muli-Port"
      }
    }
    close $fp


    exec cat multiport | column -t > $file_name 
    exec rm multiport

    echo "-I- Multiport report file is under: $file_name"
}

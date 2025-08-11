proc be_check_multiport { {stage ""} } {
    
    puts "-I- Running be_check_multiport"
    
    if { $stage != "" } { set file_name [get_db user_stage_reports_dir]/${stage}_multiport.rpt } { set file_name reports/multiport.rpt }

    #== Open file ==#
    set fp [open "multiport" w+]

    #== Get all output ports ==#
    set OutPorts [get_db ports -if {.direction==out}]
    puts $fp "Port-Name Reason/Issue\n--------- ------------"

    #== Check if MP or D&P ==#
    foreach p $OutPorts {

      set IsMultiPort [llength [get_object_name  [get_ports [get_db $p .net.loads] -quiet]]]
      set IsLogic     [llength [get_object_name  [get_pins  [get_db $p .net.loads] -quiet]]]
      
      set n [get_db $p .name]
      
      if {($IsLogic > 0)} {
          puts $fp "$n Driving-Logic-and-Ports"
          continue
      } elseif {($IsMultiPort > 1 )} {
          puts $fp "$n Driving-Muli-Port"
          continue
      }
    }
    close $fp


    exec cat multiport | column -t > $file_name 
    exec rm multiport

    echo "-I- Multiport report file is under: $file_name"
}

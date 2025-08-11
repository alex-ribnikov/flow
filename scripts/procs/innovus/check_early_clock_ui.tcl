proc check_early_clock {insts} {
   set ckPins [get_object_name [get_pins -of_objects $insts -filter is_clock==true]]
   if {[llength $ckPins] > 0} {
      puts "Slack to register | Slack from register | Clock pin"
      puts "----------------- | ------------------- | ---------"
   } else {
      return "Can't find clock pins of $insts"
   }
   foreach ckPin $ckPins {
      set dinPin [get_object_name [get_pins -of_objects [get_cells -of_objects $ckPin] -filter "direction==in&&is_data==true&&is_preset==false"]]
      set doutPin [get_object_name [get_pins -of_objects [get_cells -of_objects $ckPin] -filter "direction==out"]]
      set inSlack [get_property [report_timing -to $dinPin -collection] slack]
      set outSlack [get_property [report_timing -to $doutPin -collection] slack]
      set inNum [get_property [report_timing -to $dinPin -collection] num_cell_arcs]
      set outNum [get_property [report_timing -to $doutPin -collection] num_cell_arcs]
      puts "$inSlack  ($inNum)       | $outSlack   ($outNum)        | $ckPin"
   }
}

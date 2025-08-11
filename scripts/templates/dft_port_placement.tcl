remove_tracks -all
source scripts/layout/N3E-track-icc2.tcl
#set fillPattern "fill_optimised"
set m7T  [get_attribute [get_layer M7] pitch]


set V4M [format "%.4f" [expr 0.76/15]]

set_app_options -name plan.pins.fast_route -value true
set_app_options -name plan.pins.ignore_pin_spacing_constraint_to_pg -value true
set_app_options -name plan.pins.incremental -value true

set _port_list " \
    TEST__* \
"
set xStart 385
set xOffset [format "%.3f" [expr [sizeof_collection [get_ports $_port_list]]*$V4M + $m7T]]
set xEnd  [expr $xStart + $xOffset]
puts "Start Offset: $xStart Step: $xOffset End Offset: $xEnd"
set bund [create_bundle [get_nets $_port_list]]
create_pin_constraint -self -sides 2 -type bundle -bundles $bund -bundle_order ordered -layers M7 -interleaving_layer_range 3 -pin_spacing_tracks 1 -keep_pins_together true -range "$xStart $xEnd"
set test_ports [get_ports $_port_list]
place_pins  -self -ports [get_object_name $test_ports] -nets_to_exclude_from_routing [get_object_name [get_nets -of_object $test_ports]]

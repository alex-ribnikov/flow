proc create_boundary_placement_halo {args} {
  parse_proc_arguments -args $args options

# Halo width
set halo_width $options(-halo_width)

foreach i [get_computed_shapes [get_computed_shapes [get_db designs .boundary]] XOR [get_computed_shapes [get_db designs .boundary] SIZE -$halo_width] ] {
  set x1 [lindex $i 0]
  set y1 [lindex $i 1]
  set x2 [lindex $i 2]
  set y2 [lindex $i 3]

  create_place_blockage -name boundary_place_halo -type hard -rects $i
}
puts "INFO: Created placement blockages around block boundary - This can be removed using \"delete_obj \[get_db place_blockages {-if .name == boundary_halo}\]\" "
}
define_proc_arguments create_boundary_placement_halo \
  -info "Create placement blockages along block boundary" \
  -define_args {
    {-halo_width "Width of the placement halo" "none" float {required}}
  }

proc create_boundary_routing_halo {args} {
  parse_proc_arguments -args $args options

# Halo width
set halo_width $options(-halo_width)
set layers $options(-layers)

foreach i [get_computed_shapes [get_computed_shapes [get_db designs .boundary]] XOR [get_computed_shapes [get_db designs .boundary] SIZE -$halo_width] ] {
  set x1 [lindex $i 0]
  set y1 [lindex $i 1]
  set x2 [lindex $i 2]
  set y2 [lindex $i 3]

  create_route_blockage -name boundary_route_halo -layers $layers -rects $i
}
puts "INFO: Created routing blockages around block boundary - This can be removed using \"delete_obj \[get_db route_blockages {-if .name == boundary_route_halo}\]\" "
}
define_proc_arguments create_boundary_routing_halo \
  -info "Create routing blockages along block boundary" \
  -define_args {
    {-halo_width "Width of the routing halo" "none" float {required}}
    {-layers "List of blocking layers" "none" string {required}}
  }

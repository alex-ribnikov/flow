
proc create_placement_blockage {args} {
	parse_proc_arguments -args $args options
	if {[info exists options(-name) ]}    {set NAME $options(-name)}
	if {[info exists options(-type) ]}    {set TYPE $options(-type)}
	if {[info exists options(-boundary) ]}    {set BOUNDARY $options(-boundary)}
	set cmd ""
	if {[info exists NAME]} {set cmd "${cmd}-name $NAME "}
	if {[info exists TYPE]} {set cmd "${cmd}-type $TYPE "}
	if {[info exists BOUNDARY]} {set cmd "${cmd}-rects {$BOUNDARY} "}
	set cmd "create_place_blockage $cmd"
	eval $cmd

}

define_proc_arguments create_placement_blockage \
	-info "Creates cell placement blockages that can be placed" \
  	-define_args {
		{-name "Specifies the name of the placement blockage." "" string {optional}}
		{-type  "Specifies the type of blockage to be created." "" string  {optional}}
		{-boundary  "Specifies the polygon vertices of the blockage, in microns" "" string  {optional}}
    	}





proc set_routing_rule {args} {
	parse_proc_arguments -args $args options
	if {[info exists options(-default_rule) ]}         {set DEFAULT_RULE ""}
	if {[info exists options(-min_routing_layer) ]}    {set MIN_ROUTING_LAYER $options(-min_routing_layer)}
	if {[info exists options(-max_routing_layer) ]}    {set MAX_ROUTING_LAYER $options(-max_routing_layer)}
	if {[info exists options(-min_layer_is_user) ]}    {set MIN_LAYER_IS_USER $options(-min_layer_is_user)}
	if {[info exists options(-max_layer_is_user) ]}    {set MAX_LAYER_IS_USER $options(-max_layer_is_user)}
	if {[info exists options(-min_layer_mode) ]}       {set MIN_LAYER_MODE $options(-min_layer_mode)}
	if {[info exists options(-min_layer_mode_soft_cost) ]}    {set MIN_LAYER_MODE_SOFT_COST $options(-min_layer_mode_soft_cost)}
	if {[info exists options(-max_layer_mode) ]}              {set MAX_LAYER_MODE $options(-max_layer_mode)}
	if {[info exists options(-max_layer_mode_soft_cost) ]}    {set MAX_LAYER_MODE_SOFT_COST $options(-max_layer_mode_soft_cost)}
	set cmd ""
	if {[info exists MIN_ROUTING_LAYER]} {set cmd "${cmd}-bottom_preferred_routing_layer $MIN_ROUTING_LAYER "}
	if {[info exists MIN_LAYER_MODE_SOFT_COST]} {set cmd "${cmd}-preferred_routing_layer_effort $MIN_LAYER_MODE_SOFT_COST "}
	if {[info exists MIN_LAYER_MODE]} {set cmd "${cmd}-route_rule_effort $MIN_LAYER_MODE "}
	if {[info exists MAX_ROUTING_LAYER]} {set cmd "${cmd}-top_preferred_routing_layer $MAX_ROUTING_LAYER "}
#	parray options
	set cmd "set_route_attributes -nets $options(net) $cmd"
#	echo $cmd
	eval $cmd


}

define_proc_arguments set_routing_rule \
	-info "Creates cell placement blockages that can be placed" \
  	-define_args {
		{-default_rule "" "" boolean {optional}}
		{-min_routing_layer  "Bottom routing layer for the object" "" string  {optional}}
		{-max_routing_layer  "Top routing layer for the object" "" string  {optional}}
		{-min_layer_is_user  "" "" string  {optional}}
		{-max_layer_is_user  "" "" string  {optional}}
		{-min_layer_mode  "Non default rule effort" "" string  {optional}}
		{-min_layer_mode_soft_cost  "Routing effort level" "" string  {optional}}
		{-max_layer_mode  "" "" string  {optional}}
		{-max_layer_mode_soft_cost  "" "" string  {optional}}
		{net  "" "net" string  {optional}}
    	}



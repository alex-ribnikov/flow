

proc report_timing_cg {args} {

	set RT_ARG [list]
	parse_proc_arguments -args $args options
    		if {[info exists options(-to) ]} {set TO $options(-to)}
    		if {[info exists options(-rise_to) ]} {set RISE_TO $options(-rise_to)}
    		if {[info exists options(-fall_to) ]} {set FALL_TO $options(-fall_to)}
    		if {[info exists options(-from) ]} {set FROM $options(-from)}
    		if {[info exists options(-rise_from) ]} {set RISE_FROM $options(-rise_from)}
    		if {[info exists options(-fall_from) ]} {set FALL_FROM $options(-fall_from)}
    		if {[info exists options(path_collection) ]}            {lappend RT_ARG "$options(path_collection)"}
    		if {[info exists options(-through) ]}                   {lappend RT_ARG "-through $options(-through)"}
    		if {[info exists options(-rise_through) ]}              {lappend RT_ARG "-rise_through $options(-rise_through)"}
    		if {[info exists options(-fall_through) ]}              {lappend RT_ARG "-fall_through $options(-fall_through)"}
    		if {[info exists options(-exclude) ]}                   {lappend RT_ARG "-exclude $options(-exclude)"}
    		if {[info exists options(-rise_exclude) ]}              {lappend RT_ARG "-rise_exclude $options(-rise_exclude)"}
    		if {[info exists options(-fall_exclude) ]}              {lappend RT_ARG "-fall_exclude $options(-fall_exclude)"}
    		if {[info exists options(-delay_type) ]}                {lappend RT_ARG "-delay_type $options(-delay_type)"}
    		if {[info exists options(-nworst) ]}                    {lappend RT_ARG "-nworst $options(-nworst)"}
    		if {[info exists options(-max_paths) ]}                 {lappend RT_ARG "-max_paths $options(-max_paths)"}
    		if {[info exists options(-group) ]}                     {lappend RT_ARG "-group $options(-group)"}
    		if {[info exists options(-slack_greater_than) ]}        {lappend RT_ARG "-slack_greater_than $options(-slack_greater_than)"}
    		if {[info exists options(-slack_lesser_than) ]}         {lappend RT_ARG "-slack_lesser_than $options(-slack_lesser_than)"}
    		if {[info exists options(-ignore_register_feedback) ]}  {lappend RT_ARG "-ignore_register_feedback $options(-ignore_register_feedback)"}
    		if {[info exists options(-pba_mode) ]}                  {lappend RT_ARG "-pba_mode $options(-pba_mode)"}
    		if {[info exists options(-start_end_type) ]}            {lappend RT_ARG "-start_end_type $options(-start_end_type)"}
    		if {[info exists options(-domain_crossing) ]}           {lappend RT_ARG "-domain_crossing $options(-domain_crossing)"}
    		if {[info exists options(-cover_through) ]}             {lappend RT_ARG "-cover_through $options(-cover_through)"}
    		if {[info exists options(-tag_paths_filtered_by_pba) ]} {lappend RT_ARG "-tag_paths_filtered_by_pba $options(-tag_paths_filtered_by_pba)"}
    		if {[info exists options(-pre_commands) ]}              {lappend RT_ARG "-pre_commands $options(-pre_commands)"}
    		if {[info exists options(-post_commands) ]}             {lappend RT_ARG "-post_commands $options(-post_commands)"}
    		if {[info exists options(-vdd_slack_lesser_than) ]}     {lappend RT_ARG "-vdd_slack_lesser_than $options(-vdd_slack_lesser_than)"}
    		if {[info exists options(-vdd_slack_greater_than) ]}    {lappend RT_ARG "-vdd_slack_greater_than $options(-vdd_slack_greater_than)"}
    		if {[info exists options(-path_type) ]}                 {lappend RT_ARG "-path_type $options(-path_type)"}
    		if {[info exists options(-significant_digits) ]}        {lappend RT_ARG "-significant_digits $options(-significant_digits)"}
    		if {[info exists options(-exceptions) ]}                {lappend RT_ARG "-exceptions $options(-exceptions)"}
    		if {[info exists options(-imsa_session) ]}              {lappend RT_ARG "-imsa_session $options(-imsa_session)"}
    		if {[info exists options(-sort_by) ]}                   {lappend RT_ARG "-sort_by $options(-sort_by)"}
    		if {[info exists options(-attributes) ]}                {lappend RT_ARG "-attributes $options(-attributes)"}
    		if {[info exists options(-dvfs_scenarios) ]}            {lappend RT_ARG "-dvfs_scenarios $options(-dvfs_scenarios)"}
    		if {[info exists options(-unique_pins) ]}               {lappend RT_ARG "-unique_pins"}
    		if {[info exists options(-include_hierarchical_pins) ]} {lappend RT_ARG "-include_hierarchical_pins"}
    		if {[info exists options(-trace_latch_borrow) ]}        {lappend RT_ARG "-trace_latch_borrow"}
    		if {[info exists options(-trace_latch_forward) ]}       {lappend RT_ARG "-trace_latch_forward"}
    		if {[info exists options(-normalized_slack) ]}          {lappend RT_ARG "-normalized_slack"}
    		if {[info exists options(-start_end_pair) ]}            {lappend RT_ARG "-start_end_pair"}
    		if {[info exists options(-cover_design) ]}              {lappend RT_ARG "-cover_design"}
    		if {[info exists options(-dont_merge_duplicates) ]}     {lappend RT_ARG "-dont_merge_duplicates"}
    		if {[info exists options(-pocv_pruning) ]}              {lappend RT_ARG "-pocv_pruning"}
    		if {[info exists options(-input_pins) ]}                {lappend RT_ARG "-input_pins"}
    		if {[info exists options(-nets) ]}                      {lappend RT_ARG "-nets"}
    		if {[info exists options(-nosplit) ]}                   {lappend RT_ARG "-nosplit"}
    		if {[info exists options(-transition_time) ]}           {lappend RT_ARG "-transition_time"}
    		if {[info exists options(-capacitance) ]}               {lappend RT_ARG "-capacitance"}
    		if {[info exists options(-report_ignored_register_feedback) ]} {lappend RT_ARG "-report_ignored_register_feedback"}
    		if {[info exists options(-crosstalk_delta) ]}           {lappend RT_ARG "-crosstalk_delta"}
    		if {[info exists options(-derate) ]}                    {lappend RT_ARG "-derate"}
    		if {[info exists options(-variation) ]}                 {lappend RT_ARG "-variation"}
    		if {[info exists options(-voltage) ]}                   {lappend RT_ARG "-voltage"}
    		if {[info exists options(-supply_net_group) ]}          {lappend RT_ARG "-supply_net_group"}
    		if {[info exists options(-physical) ]}                  {lappend RT_ARG "-physical"}
    		if {[info exists options(-vdd_slack) ]}                 {lappend RT_ARG "-vdd_slack"}
		if {[info exists ::pt_shell_mode] && $::pt_shell_mode == "primetime_master"} {
			if {[info exists FROM]} {
				set_distributed_variables {FROM    }
				get_distributed_variables FROM_ENDPOINT    -merge_type unique_list -pre_commands {set FROM_ENDPOINT [get_object_name [all_fanout -from $FROM -endpoints_only -flat]]}
				lappend RT_ARG "-from {$FROM_ENDPOINT}"
			}
			if {[info exists RISE_FROM]} {
				set_distributed_variables {RISE_FROM    }
				get_distributed_variables RISE_FROM_ENDPOINT    -merge_type unique_list -pre_commands {set RISE_FROM_ENDPOINT [get_object_name [all_fanout -from $RISE_FROM -endpoints_only -flat]]}
				lappend RT_ARG "-rise_from {$RISE_FROM_ENDPOINT}"
			}
			if {[info exists FALL_FROM]} {
				set_distributed_variables {FALL_FROM    }
				get_distributed_variables FALL_FROM_ENDPOINT    -merge_type unique_list -pre_commands {set FALL_FROM_ENDPOINT [get_object_name [all_fanout -from $FALL_FROM -endpoints_only -flat]]}
				lappend RT_ARG "-fall_from {$FALL_FROM_ENDPOINT}"
			}
			if {[info exists TO]} {
				set_distributed_variables {TO    }
				get_distributed_variables TO_ENDPOINT    -merge_type unique_list -pre_commands {set TO_ENDPOINT [get_object_name [get_pins -of [all_fanout -from $TO -endpoints_only -flat -only_cells] -filter "direction == in && !is_clock_pin"]]}
				lappend RT_ARG "-to {$TO_ENDPOINT}"
			}
			if {[info exists RISE_TO]} {
				set_distributed_variables {RISE_TO    }
				get_distributed_variables RISE_TO_ENDPOINT    -merge_type unique_list -pre_commands {set RISE_TO_ENDPOINT [get_object_name [get_pins -of [all_fanout -from $RISE_TO -endpoints_only -flat -only_cells] -filter "direction == in && !is_clock_pin"]]}
				lappend RT_ARG "-rise_to {$RISE_TO_ENDPOINT}"
			}
			if {[info exists FALL_TO]} {
				set_distributed_variables {FALL_TO    }
				get_distributed_variables FALL_TO_ENDPOINT    -merge_type unique_list -pre_commands {set FALL_TO_ENDPOINT [get_object_name [get_pins -of [all_fanout -from $FALL_TO -endpoints_only -flat -only_cells] -filter "direction == in && !is_clock_pin"]]}
				lappend RT_ARG "-fall_to {$FALL_TO_ENDPOINT}"
			}
			
			
		} else {
			if {[info exists FROM]} {
				set FROM_ENDPOINT [all_fanout -from $FROM -endpoints_only -flat]
				lappend RT_ARG "-from $FROM_ENDPOINT"
			}
			if {[info exists RISE_FROM]} {
				set RISE_FROM_ENDPOINT [all_fanout -from $RISE_FROM -endpoints_only -flat]
				lappend RT_ARG "-rise_from $RISE_FROM_ENDPOINT"
			}
			if {[info exists FALL_FROM]} {
				set FALL_FROM_ENDPOINT [all_fanout -from $FALL_FROM -endpoints_only -flat]
				lappend RT_ARG "-fall_from $FALL_FROM_ENDPOINT"
			}
			
			
			if {[info exists TO]} {
				set TO_ENDPOINT [get_pins -of [all_fanout -from $TO -endpoints_only -flat -only_cells] -filter "direction == in && !is_clock_pin"]
				lappend RT_ARG "-to $TO_ENDPOINT"
			}
			if {[info exists RISE_TO]} {
				set RISE_TO_ENDPOINT [get_pins -of [all_fanout -from $RISE_TO -endpoints_only -flat -only_cells] -filter "direction == in && !is_clock_pin"]
				lappend RT_ARG "-rise_to $RISE_TO_ENDPOINT"
			}
			if {[info exists FALL_TO]} {
				set FALL_TO_ENDPOINT [get_pins -of [all_fanout -from $FALL_TO -endpoints_only -flat -only_cells] -filter "direction == in && !is_clock_pin"]
				lappend RT_ARG "-fall_to $FALL_TO_ENDPOINT"
			}
		}
		set cmd "report_timing"
		for {set i 0} {$i < [llength $RT_ARG]} {incr i} {
			set cmd "$cmd [lindex $RT_ARG $i]"
		}
		eval $cmd
		

}

define_proc_attributes report_timing_cg \
  	-define_args {
    		{-to "To pins, ports, nets, or clocks" "to_list" list {optional}}
    		{-rise_to "Rising to pins, ports, nets, or clocks" "rise_to_list" list {optional}}
    		{-fall_to "Falling to pins, ports, nets, or clocks" "fall_to_list" list {optional}}
    		{-from "From pins, ports, nets, or clocks" "from_list" list {optional}}
    		{-rise_from "Rising from pins, ports, nets, or clocks" "rise_from_list" list {optional}}
    		{-fall_from "Falling from pins, ports, nets, or clocks" "fall_from_list" list {optional}}
    		{-through "Through pins, ports, nets, or cells" "through_list" list {optional}}
    		{-rise_through "Rising through pins, ports, nets, or cells" "rise_through_list" list {optional}}
    		{-fall_through "Falling through pins, ports, nets, or cells" "fall_through_list" list {optional}}
    		{-exclude "Exclude pins, ports, nets or cells" "exclude_list" list {optional}}
    		{-rise_exclude "Exclude rising of pins, ports, nets or cells" "rise_exclude_list" list {optional}}
    		{-fall_exclude "Exclude falling of pins, ports, nets or cells" "fall_exclude_list" list {optional}}
    		{-delay_type "Type of path delay: Values: max, min, min_max, max_rise, max_fall, min_rise, min_fall" "delay_type" string {optional}}
    		{-nworst "List N worst paths to endpoint: Value >= 1" "paths_per_endpoint" int {optional}}
    		{-max_paths "Maximum number of paths per path group to output Value >= 1" "count" int {optional}}
    		{-group "Limit report to paths in these groups" "group_name" string {optional}}
    		{-unique_pins "Find paths through unique pins" "" boolean {optional}}
    		{-slack_greater_than "Display paths with slack greater than this" "slack_limit" float {optional}}
    		{-slack_lesser_than "Display paths with slack less than this" "slack_limit" float {optional}}
    		{-ignore_register_feedback "Ignore feedback loops to registers" "feedback_slack_cutoff" string {optional}}
    		{-include_hierarchical_pins "Create timing point for each hierarchical pin in path" "" boolean {optional}}
    		{-trace_latch_borrow "Trace timing paths through borrowing latches" "" boolean {optional}}
    		{-trace_latch_forward "Trace timing paths beyond latch loop breakers" "" boolean {optional}}
    		{-pba_mode "Path-Based Analysis mode: Values: none, path, exhaustive, ml_exhaustive" "values_list" string {optional}}
    		{-start_end_type "Subset of paths to return: Values: reg_to_reg, reg_to_out, in_to_reg, in_to_out" "from_to_type" string {optional}}
    		{-domain_crossing "Separate cross domain paths (default is all): Values: all, only_crossing, exclude_crossing)" "string" string {optional}}
    		{-normalized_slack "Sort by normalized slack" "" boolean {optional}}
    		{-start_end_pair "List worst path per start-endpoint pair" "" boolean {optional}}
    		{-cover_design "List worst path through every violating pin" "" boolean {optional}}
    		{-cover_through "Through pins, ports, nets, or cells" "through_list" list {optional}}
    		{-dont_merge_duplicates "Do not merge paths that appear in more than one scenario" "" boolean {optional}}
    		{-tag_paths_filtered_by_pba "Tag GBA paths filtered out in PBA analysis" "tag name" int {optional}}
    		{-dvfs_scenarios "Select paths for specific DVFS scenarios" "DVFS Scenarios" string {optional}}
    		{-pre_commands "Pre merged reporting commands to be executed at worker(s)" "pre_command string" string {optional}}
    		{-post_commands "Post merged reporting commands to be executed at worker(s)" "post command string" string {optional}}
    		{-pocv_pruning "Filter out any path which does not contribute to high sigma failure rate" "" boolean {optional}}
    		{-vdd_slack_lesser_than "Perform Voltage slack analysis on all paths with up to this" "vdd_slack_limit" float {optional}}
    		{-vdd_slack_greater_than "Perform Voltage slack analysis on all paths with down to this" "vdd_slack_down_limit" float {optional}}
    		{-path_type "Format for path report:\n                           Values: full, full_clock, short, end,\n                           summary, full_clock_expanded)" "format" string {optional}}
    		{-input_pins "Show input pins in path" "" boolean {optional}}
    		{-nets "List net names" "" boolean {optional}}
    		{-nosplit "Do not split lines when columns overflow" "" boolean {optional}}
    		{-transition_time "Display transition time for each pin" "" boolean {optional}}
    		{-capacitance "Display total capacitance for each net" "" boolean {optional}}
    		{-report_ignored_register_feedback "Report ignored feedback loops to registers" "" boolean {optional}}
    		{-significant_digits "Number of digits to display:\n                            Range: 0 to 13" "digits" int {optional}}
    		{-crosstalk_delta "Show crosstalk effects" "" boolean {optional}}
    		{-derate "Show derate factors" "" boolean {optional}}
    		{-variation "Report variation-aware info" "" boolean {optional}}
    		{-exceptions "Scope of timing exceptions reporting: Values:\n                           dominant, overridden, all" "exception_type" string {optional}}
    		{-voltage "Report pin voltages" "" boolean {optional}}
    		{-imsa_session "Focus IMSA session name" "name of focus IMSA session" string {optional}}
    		{-sort_by "sort_by" "<slack|group>" string {optional}}
    		{-supply_net_group "Show supply net group names for path elements" "" boolean {optional}}
    		{-physical "Show pin XY locations" "" boolean {optional}}
    		{-attributes "Attributes to be printed in the timing report" "attribute_list" list {optional}}
    		{-vdd_slack "Print Voltage slack analysis report" "" boolean {optional}}
    		{path_collection "a collection of timing paths" "path_collection" string {optional}}
     }

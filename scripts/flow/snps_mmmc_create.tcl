proc mmmc_create {} {
  global TEST 
  global OCV 
  global STAGE 
  global DESIGN_NAME 
  global mmmc_results 
  global sdc_files
  global scenarios
  global all_scenarios
  global rc_corner
  global pvt_corner
  global TECHNOLOGY_LAYER_MAP
  set fid [open $mmmc_results w]
  set counter 0
  if {[llength [info commands remove_modes]]}     {puts $fid "remove_modes -all"}
  if {[llength [info commands remove_corners]]}   {puts $fid "remove_corners -all"}
  if {[llength [info commands remove_scenarios]]} {puts $fid "remove_scenarios -all"}

  set rc_list [list]
  set mode_list [list]
  foreach _view $all_scenarios {
	puts "-I- creating proc for scenario: scenario_proc_${_view}"
	set mode [lindex [split $_view "_"] 0]
	set check [lindex [split $_view "_"] end]
	regsub "${mode}_(.*)_${check}" $_view {\1} sub_pvt
	regexp {(.*[SF])_(.*)} $sub_pvt match pvt rc
	set library_ [lindex $pvt_corner($pvt,timing) [lsearch $pvt_corner($pvt,timing) *_sc*]]
	regsub "\.lib" [regsub "\.gz" [lindex [split [lindex $library_ 0] /] end] ""] "" library
	set temperature $pvt_corner($pvt,temperature)
	if {[lsearch $rc_list $rc] == -1} { lappend rc_list $rc }
	if {[lsearch $mode_list $mode] == -1} { lappend mode_list $mode }
	
	 
	
	
	if {$::synopsys_program_name != "fc_shell" && $::synopsys_program_name != "rtl_shell"} {
	
		puts $fid "proc scenario_proc_${_view} {} {"
		puts $fid "\tglobal STAGE"
		puts $fid "\tglobal IS_PHYSICAL"
		
		# create scenario
		puts $fid "\tcreate_scenario $_view"
	
		# TLU PLUS
		puts $fid "\tset_tlu_plus_files \\\n\t\t-max_tluplus $rc_corner($rc,nxtgrd) \\\n\t\t-tech2itf_map $TECHNOLOGY_LAYER_MAP"
		puts $fid "\tcheck_tlu_plus_files > reports/check_tlu_plus_files_${_view}.rpt"
		puts $fid "\tset_scenario_options -setup false -hold false -leakage_power false -dynamic_power false"

		# set operation condition
		if {[info exists OCV] && ($OCV != "None" || $OCV != "none")} {
			puts $fid "\tset_operating_conditions -library $library $pvt_corner($pvt,op_code) -analysis_type on_chip_variation"
		} else {
			puts $fid "\tset_operating_conditions -library $library $pvt_corner($pvt,op_code)"
		}
		
		# read SDC
		puts $fid "\tforeach constraint_file {$sdc_files($mode)} {
			\t\tset sss \[lindex \[split \$constraint_file /\] end\]
			\t\tredirect -tee -file reports/read_\${sss}   {source -e -v \$constraint_file}
			\t}"
		
		
		puts $fid "}\n"
		
	} else {
		# create single mode . single corner.
		# moving to multiple for single SDC. 
		if {[info exists TEST] && $TEST == "true"} {
			# create mode , corner , scenario
			puts $fid "# create scenario $_view"
			puts $fid "##############################################################################"
#			puts $fid "if {!\[sizeof_collection \[get_parasitic_techs -quiet $rc\]\] } {read_parasitic_tech -tlup $rc_corner($rc,nxtgrd) -layermap $TECHNOLOGY_LAYER_MAP -name $rc }"
			puts $fid "read_parasitic_tech -tlup $rc_corner($rc,nxtgrd) -layermap $TECHNOLOGY_LAYER_MAP -name $rc"
			puts $fid "if {!\[sizeof_collection \[get_mode -quiet ${mode}\]\] } {create_mode ${mode} }"
#			puts $fid "create_mode ${mode}"
			puts $fid "if {!\[sizeof_collection \[get_corner -quiet ${rc}_${temperature}\]\] } {create_corner ${pvt}_${rc}_${temperature} }"
#			puts $fid "create_corner ${rc}_${temperature}"
			puts $fid "create_scenario -mode ${mode} -corner ${pvt}_${rc}_${temperature} -name $_view"


		
			puts $fid "set_scenario_status $_view -none -setup false -hold false -leakage_power false -dynamic_power false -max_transition false -max_capacitance false -min_capacitance false -active false"
			puts $fid "set_parasitic_parameters -corners ${pvt}_${rc}_${temperature} -early_spec $rc -early_temperature $temperature -late_spec $rc -late_temperature $temperature "
#			puts $fid "set_extraction_options -corners ${pvt}_${rc}_${temperature}_${counter} -late_ccap_threshold [lindex $rc_corner($rc,ccap_threshold) 0 1] -early_ccap_threshold [lindex $rc_corner($rc,ccap_threshold) 0 0]  "
#			puts $fid "set_extraction_options -corners ${pvt}_${rc}_${temperature}_${counter} -late_ccap_ratio [lindex $rc_corner($rc,ccap_ratio) 0 1] -early_ccap_ratio [lindex $rc_corner($rc,ccap_ratio) 0 0]  "
	
			# set operation condition
			if {[info exists OCV] && ($OCV != "None" || $OCV != "none")} {
				puts $fid "set_operating_conditions -library $library $pvt_corner($pvt,op_code) -analysis_type on_chip_variation"
			} else {
				puts $fid "set_operating_conditions -library $library $pvt_corner($pvt,op_code)"
			}
			if {[info exists pvt_corner($pvt,label)] && $pvt_corner($pvt,label) != ""} {
				puts $fid "set_process_label $pvt_corner($pvt,label)"
			}
			puts $fid "split_sdc $mode ${pvt}_${rc}_${temperature} $_view" 
			puts $fid "\n\n"
			
	   	} else {
		
			# create mode , corner , scenario
			puts $fid "# create scenario $_view"
			puts $fid "##############################################################################"
#			puts $fid "if {!\[sizeof_collection \[get_parasitic_techs -quiet $rc\]\] } {read_parasitic_tech -tlup $rc_corner($rc,nxtgrd) -layermap $TECHNOLOGY_LAYER_MAP -name $rc }"
			puts $fid "read_parasitic_tech -tlup $rc_corner($rc,nxtgrd) -layermap $TECHNOLOGY_LAYER_MAP -name $rc"
			puts $fid "create_mode ${mode}_${counter}"
			puts $fid "create_corner ${pvt}_${rc}_${temperature}_${counter}"
			puts $fid "create_scenario -mode ${mode}_${counter} -corner ${pvt}_${rc}_${temperature}_${counter} -name $_view"
		
			puts $fid "set_scenario_status $_view -none -setup false -hold false -leakage_power false -dynamic_power false -max_transition false -max_capacitance false -min_capacitance false -active false"
			puts $fid "set_parasitic_parameters -corners ${pvt}_${rc}_${temperature}_${counter} -early_spec $rc -early_temperature $temperature -late_spec $rc -late_temperature $temperature "
#			puts $fid "set_extraction_options -corners ${pvt}_${rc}_${temperature}_${counter} -late_ccap_threshold [lindex $rc_corner($rc,ccap_threshold) 0 1] -early_ccap_threshold [lindex $rc_corner($rc,ccap_threshold) 0 0]  "
#			puts $fid "set_extraction_options -corners ${pvt}_${rc}_${temperature}_${counter} -late_ccap_ratio [lindex $rc_corner($rc,ccap_ratio) 0 1] -early_ccap_ratio [lindex $rc_corner($rc,ccap_ratio) 0 0]  "
			

			# set operation condition
			if {[info exists OCV] && ($OCV != "None" || $OCV != "none")} {
				puts $fid "set_operating_conditions -library $library $pvt_corner($pvt,op_code) -analysis_type on_chip_variation"
			} else {
				puts $fid "set_operating_conditions -library $library $pvt_corner($pvt,op_code)"
			}
			if {[info exists pvt_corner($pvt,label)] && $pvt_corner($pvt,label) != ""} {
				puts $fid "set_process_label $pvt_corner($pvt,label)"
			}
	  		puts $fid "foreach constraint_file {$sdc_files($mode)} {
				\tset sss \[lindex \[split \$constraint_file /\] end\]
				\tredirect -tee -file reports/read_\${sss}   {source -e -v \$constraint_file}
				}"
			puts $fid "\n\n"
	
	
	   	} ; # end if TEST

	} ; #if {$synopsys_program_name != fc_shell} 
		
	incr counter
		
  } ; # foreach _view $all_scenarios
  if {$::synopsys_program_name == "fc_shell" || $::synopsys_program_name == "rtl_shell"} {
	# create single mode . single corner.
	# moving to multiple for single SDC. 
	puts $fid "#-----------------------------------------------------------------------------\n"
	if {[info exists TEST] && $TEST == "true"} {
		# read SDC
		
		
		puts $fid "foreach_in_collection mode \[all_modes\] {"
		puts $fid "	set mode_name \[get_attribute \$mode name\]"
		puts $fid "	current_mode \$mode_name"
		puts $fid "	set scenario_name \[get_attribute \[current_scenario\] name\]"
		puts $fid "	if {\[file exists sdc/general_\${scenario_name}.sdc\]} {redirect -tee -file reports/read_general_\${scenario_name}   {source -e -v sdc/general_\${scenario_name}.sdc}}"
		puts $fid "	redirect -tee -file reports/read_mode_\${mode_name}   {source -e -v sdc/mode_\${mode_name}.sdc}"
		puts $fid "}"

		puts $fid "foreach_in_collection corner \[all_corners\] {"
		puts $fid "	set corner_name \[get_attribute \$corner name\]"
		puts $fid "	current_corner \$corner_name"
		puts $fid "	set scenario_name \[get_attribute \[current_scenario\] name\]"
		puts $fid "	if {\[file exists sdc/general_\${scenario_name}.sdc\]} {redirect -tee -file reports/read_general_\${scenario_name}   {source -e -v sdc/general_\${scenario_name}.sdc}}"
		puts $fid "	redirect -tee -file reports/read_corner_\${corner_name}   {source -e -v sdc/corner_\${corner_name}.sdc}"
		puts $fid "}"

		puts $fid "foreach_in_collection scenario \[all_scenarios\] {"
		puts $fid "	set scenario_name  \[get_attribute \$scenario name\]"
		puts $fid "	current_scenario \$scenario_name"
		puts $fid "	if {\[file exists sdc/general_\${scenario_name}.sdc\]} {redirect -tee -file reports/read_general_\${scenario_name}   {source -e -v sdc/general_\${scenario_name}.sdc}}"
		puts $fid "	redirect -tee -file reports/read_scenario_\${scenario_name}   {source -e -v sdc/scenario_\${scenario_name}.sdc}"
		puts $fid "}"
		
		
		
#              	foreach mmm $mode_list {
#        	      	puts $fid "current_mode $mmm"
#        	     	puts $fid "foreach constraint_file {$sdc_files($mmm)} {
#        		      \tset sss \[lindex \[split \$constraint_file /\] end\]
#        		      \tredirect -tee -file reports/read_\${sss}   {source -e -v \$constraint_file}
#        		      }"
#			puts $fid "#-----------------------------------------------------------------------------\n"
#		}
  	} ; # end if TEST
	puts $fid "## To remove duplicate modes, corners, scenarios, and to improve runtime and capacity without loss of constraints :"
	puts $fid "remove_duplicate_timing_contexts"

  }
  close $fid

} ; # end of proc



proc mmmc_create {} {
  global STAGE 
  global DESIGN_NAME 
  global mmmc_results 
  global sdc_files
  global scenarios
  global all_scenarios
  global rc_corner
  global pvt_corner
  set fid [open $mmmc_results w]

  set SET_ANALYSIS_VIEW "\nset_analysis_view"
  if {[info exists scenarios(setup)] && $scenarios(setup) != ""}     {
  	set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW \\\n -setup \[list \\\n"
	foreach _view $scenarios(setup) {
		set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW  $_view \\\n"
	}
	set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW \]"
  }
  if {[info exists scenarios(hold)] && $scenarios(hold) != ""}       {
  	set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW \\\n -hold \[list \\\n"
	foreach _view $scenarios(hold) {
		set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW  $_view \\\n"
	}
	set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW \]"
  }
  if {[info exists scenarios(dynamic)] && $scenarios(dynamic) != ""} {
  	set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW \\\n -dynamic \[list \\\n"
	foreach _view $scenarios(dynamic) {
		set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW  $_view \\\n"
	}
	set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW \]"
  }
  if {[info exists scenarios(leakage)] && $scenarios(leakage) != ""} {
  	set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW \\\n -leakage \[list \\\n"
	foreach _view $scenarios(leakage) {
		set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW  $_view \\\n"
	}
	set SET_ANALYSIS_VIEW "$SET_ANALYSIS_VIEW \]"
  }

  foreach check {setup hold} {
  	foreach mode [array name sdc_files] {
  		foreach rc [array name rc_corner] {
			foreach scenario $all_scenarios {
				if {[regexp "${mode}_(.*)_${rc}_${check}" $scenario match pvt] || (![regexp "setup" $scenario] && ![regexp "hold" $scenario] && [regexp "${mode}_(.*)_${rc}" $scenario match pvt])} {
				
#			foreach pvt_corner_name [array name pvt_corner] {}
#			   if {[regexp {(.*),timing} $pvt_corner_name match pvt] && ![regexp {,} $rc] && $sdc_files($mode) != ""} {}
					set CREATE_LIBRARY_SET($pvt) "create_library_set -name lib_${pvt} \\\n -timing \[list \\\n"
					foreach _lib $pvt_corner($pvt,timing) {
						set CREATE_LIBRARY_SET($pvt) "$CREATE_LIBRARY_SET($pvt)  $_lib \\\n"
					}
					set CREATE_LIBRARY_SET($pvt) "$CREATE_LIBRARY_SET($pvt) \] \\\n"
					if {[info command distribute_partition] == ""} {
						if { ( [get_db / .program_short_name] == "innovus" || [get_db / .program_short_name] == "tempus" ) && [llength $pvt_corner($pvt,ocv)] != 0 } {
							set CREATE_LIBRARY_SET($pvt) "$CREATE_LIBRARY_SET($pvt) -socv \[list \\\n"
							foreach _lib $pvt_corner($pvt,ocv) {
								set CREATE_LIBRARY_SET($pvt) "$CREATE_LIBRARY_SET($pvt)  $_lib \\\n"
							}
							set CREATE_LIBRARY_SET($pvt) "$CREATE_LIBRARY_SET($pvt) \]\n"
						}
					} else {
						set CREATE_LIBRARY_SET($pvt) "$CREATE_LIBRARY_SET($pvt) -socv \[list \\\n"
						foreach _lib $pvt_corner($pvt,ocv) {
							set CREATE_LIBRARY_SET($pvt) "$CREATE_LIBRARY_SET($pvt)  $_lib \\\n"
						}
						set CREATE_LIBRARY_SET($pvt) "$CREATE_LIBRARY_SET($pvt) \]\n"
			
					}

					set CREATE_TIMING_CONDITION($pvt) "create_timing_condition -name $pvt -library_sets lib_${pvt}\n"
					set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "create_rc_corner -name ${rc}_$pvt_corner($pvt,temperature) \\\n -qrc_tech $rc_corner($rc) \\\n -temperature $pvt_corner($pvt,temperature) \\\n"
					if {[info exists rc_corner($rc,preRoute_res)]	  && $rc_corner($rc,preRoute_res) != ""}     {set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "$CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) -pre_route_res $rc_corner($rc,preRoute_res) \\\n" }
					if {[info exists rc_corner($rc,postRoute_res)]    && $rc_corner($rc,postRoute_res) != ""}    {set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "$CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) -post_route_res $rc_corner($rc,postRoute_res) \\\n" }
					if {[info exists rc_corner($rc,preRoute_cap)]	  && $rc_corner($rc,preRoute_cap) != ""}     {set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "$CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) -pre_route_cap $rc_corner($rc,preRoute_cap) \\\n" }
					if {[info exists rc_corner($rc,postRoute_cap)]    && $rc_corner($rc,postRoute_cap) != ""}    {set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "$CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) -post_route_cap $rc_corner($rc,postRoute_cap) \\\n" }
					if {[info exists rc_corner($rc,postRoute_xcap)]   && $rc_corner($rc,postRoute_xcap) != ""}   {set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "$CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) -post_route_cross_cap $rc_corner($rc,postRoute_xcap) \\\n" }
					if {[info exists rc_corner($rc,preRoute_clkres)]  && $rc_corner($rc,preRoute_clkres) != ""}  {set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "$CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) -pre_route_clock_res $rc_corner($rc,preRoute_clkres) \\\n" }
					if {[info exists rc_corner($rc,preRoute_clkcap)]  && $rc_corner($rc,preRoute_clkcap) != ""}  {set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "$CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) -pre_route_clock_cap $rc_corner($rc,preRoute_clkcap) \\\n" }
					if {[info exists rc_corner($rc,postRoute_clkcap)] && $rc_corner($rc,postRoute_clkcap) != ""} {set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "$CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) -post_route_clock_cap $rc_corner($rc,postRoute_clkcap) \\\n" }
					if {[info exists rc_corner($rc,postRoute_clkres)] && $rc_corner($rc,postRoute_clkres) != ""} {set CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) "$CREATE_RC_CORNER(${rc}$pvt_corner($pvt,temperature)) -post_route_clock_res $rc_corner($rc,postRoute_clkres) \\\n" }
					set CREATE_DELAY_CORNER(${pvt}_${rc}_${check})  "create_delay_corner \\\n -name ${pvt}_${rc}_${check} \\\n -timing_condition $pvt \\\n -rc_corner ${rc}_$pvt_corner($pvt,temperature)"
					set CREATE_CONSTRAINT_MODE(${mode}) "create_constraint_mode -name ${mode} \\\n -sdc_files \[list \\\n"
					foreach _sdc $sdc_files(${mode}) {
						set CREATE_CONSTRAINT_MODE(${mode}) "$CREATE_CONSTRAINT_MODE(${mode}) $_sdc \\\n"
					}
					set CREATE_CONSTRAINT_MODE(${mode}) "$CREATE_CONSTRAINT_MODE(${mode}) \]"
					if {[info exists STAGE] && $STAGE == "route"} {
						set CREATE_ANALYSIS_VIEW_LATENCY(${mode}_${pvt}_${rc}_${check})  "catch \"exec touch out/db/${DESIGN_NAME}.cts.enc.dat/mmmc/views/${mode}_${pvt}_${rc}_${check}/latency.sdc\""
					} elseif {[info exists STAGE] && $STAGE == "cts"} {
						set CREATE_ANALYSIS_VIEW_LATENCY(${mode}_${pvt}_${rc}_${check})  "catch \"exec touch out/db/${DESIGN_NAME}.place.enc.dat/mmmc/views/${mode}_${pvt}_${rc}_${check}/latency.sdc\""
					}
					set CREATE_ANALYSIS_VIEW(${mode}_${pvt}_${rc}_${check}) "create_analysis_view -name ${mode}_${pvt}_${rc}_${check} -constraint_mode $mode -delay_corner ${pvt}_${rc}_${check}"
				} ; #end if 
			} ; # end foreach pvt
		} ; # end foreach rc
	} ; # end foreach mode
  } ; # end foreach check
  
  set flat_list {}
  foreach scenario [array names scenarios] {
      set flat_list [concat $flat_list $scenarios($scenario)]
  }
  
  puts $fid "##### define library sets\n"
  foreach pvt [array name CREATE_LIBRARY_SET] {
  	puts $fid $CREATE_LIBRARY_SET($pvt)
	puts $fid $CREATE_TIMING_CONDITION($pvt)
  }
  puts $fid "\n##### define rc corner\n"
  foreach rc [array name CREATE_RC_CORNER] {
  	puts $fid $CREATE_RC_CORNER($rc)
  }
  puts $fid "\n##### MMMC : define delay corners, i.e."
  puts $fid "#####        link timing libraries and operating conditions to rc corners\n"
  foreach delay [array name CREATE_DELAY_CORNER] {
  	puts $fid $CREATE_DELAY_CORNER($delay)
  }  
  puts $fid "\n##### define timing constraint\n"
  foreach mode [array name CREATE_CONSTRAINT_MODE] {
  	puts $fid $CREATE_CONSTRAINT_MODE($mode)
  }  
  puts $fid "\n##### MMMC : define analysis views, i.e."
  puts $fid "#####        link each constraint modes to each delay corner\n"
  foreach view [array name CREATE_ANALYSIS_VIEW] {
	if {[info exists CREATE_ANALYSIS_VIEW_LATENCY]} {
  		puts $fid $CREATE_ANALYSIS_VIEW_LATENCY($view)
	}
  	puts $fid $CREATE_ANALYSIS_VIEW($view)
  }  
  puts $fid $SET_ANALYSIS_VIEW

  close $fid
}



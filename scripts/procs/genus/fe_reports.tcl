proc fe_check_design { waivers_file } {

    set yaml_scripts "./scripts/flow"

	check_design -undriven -unloaded -multiple_driver -unresolved > ./reports/check_design_verbose.rpt
	check_design > ./reports/check_design.rpt
  
	if { [file exists $waivers_file] } {
		puts "-I- Executing $yaml_scripts/run_rtl2be_waivers.tcl -inplace -report_dir ./reports -check_design_waiver_file $waivers_file"
		exec $yaml_scripts/run_rtl2be_waivers.tcl                -inplace -report_dir ./reports -check_design_waiver_file $waivers_file
	} else {
        exec touch /tmp/$::env(USER)_empty_file
    	puts "-W- No check_design_waivers file found"
		puts "-I- Executing $yaml_scripts/run_rtl2be_waivers.tcl -inplace -report_dir ./reports -check_design_waiver_file empty_file"
		exec $yaml_scripts/run_rtl2be_waivers.tcl                -inplace -report_dir ./reports -check_design_waiver_file /tmp/$::env(USER)_empty_file        
    }

}

proc fe_check_timing { waivers_file } {

    set yaml_scripts "./scripts/flow"

    check_timing_intent -verbose > ./reports/check_timing_verbose.rpt
	    
	if { [file exists $waivers_file] } {
	    puts "-I- Executing $yaml_scripts/run_rtl2be_waivers.tcl -inplace -report_dir ./reports -check_timing_waiver_file $waivers_file"
	    exec $yaml_scripts/run_rtl2be_waivers.tcl                -inplace -report_dir ./reports -check_timing_waiver_file $waivers_file        
	} else {
        exec touch /tmp/$::env(USER)_empty_file
    	puts "-W- No check_timing_waivers file found"
	    puts "-I- Executing $yaml_scripts/run_rtl2be_waivers.tcl -inplace -report_dir ./reports -check_timing_waiver_file empty_file"
	    exec $yaml_scripts/run_rtl2be_waivers.tcl                -inplace -report_dir ./reports -check_timing_waiver_file /tmp/$::env(USER)_empty_file                
    }

}


proc fe_report_hdl { } {

	set file_r [open [get_db log_file] r] 
	  
	if { [info exists be_archive_netlist] } { set mode netlist } else { set mode rtl }
	 
	if {$mode == "netlist"} {  
		set file_w [open [file join ./reports/read_netlist.rpt] w]
	   	set print_line "false"
	   	while {![eof $file_r]} {
	    	set line [gets $file_r]
	     	if {[regexp {^Starting read_netlist command} $line]} {set print_line "true"}
	     	if {$print_line} {puts $file_w $line}
	     	if {[regexp {^End of read_netlist command} $line]} {set print_line "false"}
	   	}
	   	close $file_w
	 } else {
	 	set file_w [open [file join ./reports/read_hdl.rpt] w]
	   	set print_line "false"
	   	while {![eof $file_r]} {
	     	set line [gets $file_r]
	     	if {[regexp "^-I- Reading filelist from" $line]} {set print_line "true"}            
	     	if {$print_line} {puts $file_w $line}
	     	if {[regexp "^and the MEMORY_USAGE after Elaboration" $line]} {set print_line "false"}
	   	}
	   	close $file_r
	   	close $file_w
    } 

}

proc fe_report_constraints { } {

    set sdc_file $::sdc_files(func)

	if {[regexp {no_sdc} $sdc_file]} {
		catch {exec touch empty.sdc}
	    set constraint_mode_sdc empty.sdc
    }
    
    redirect ./reports/read_sdc.rpt "update_constraint_mode -name [get_db constraint_modes .name] -sdc_files \{$sdc_file\}"
    
}



proc fe_io_logic_levels { stage {rpt_type "rpt_and_viol"} {overrides ""} {report_name ""} } {

    # timing report params
        set LOGIC_LEVELS 20000
        set NWORST           4

    # for violations calculations
        set CLK_DERATE 0.92
        set CLK_JTR    75
        set MEAN_DLY   25

    set _hdr "Startpoint Endpoint StartClk EndClk LogicLevels Period"

    # rpt_type can be   "rpt_only" , "viol_only" , "rpt_and_viol"
    # overrides in the form of '<st_clk> <end_clk> <level_thr>' - ex. 'pclk qclk 18'
  if { [regexp "rpt" $rpt_type] } {
    set local_clocks [get_db clocks -if .name!=virtual*]

        ###
    if { [llength $local_clocks] } {
	puts "-I- fe_io_logic_levels - entering in2reg"
	set _logic_timing_data [report_timing -logic_levels $LOGIC_LEVELS -nworst $NWORST -from [get_db ports -if .direction==in] -to $local_clocks -views [get_db analysis_views -if .is_setup_default==true] -logic_levels_tcl_list]
	set _f_name "[get_db user_stage_reports_dir]/${stage}_report_input_logic_levels.rpt"
        set _f [open $_f_name.tmp w]
        puts $_f "$_hdr" 
        foreach _path $_logic_timing_data {
            lassign $_path st end logic
            set st_clk  [file tail [lindex [get_db [get_db ports $st]  .timing_info] 0 1 0]]
            set end_clk [file tail [lindex [get_db [get_db pins $end] .timing_info] 0 3 0]]
            set clk_prd [lindex [get_db [get_db clocks */$end_clk] .period] 0]
            puts $_f "$st $end $st_clk $end_clk $logic $clk_prd"
        }
        close $_f
        exec cat $_f_name.tmp | column -t > $_f_name
        exec cat $_f_name     | sed {s/\[[0-9+]*\]/[*]/g} | sed {s/_[0-9+]*_/_*_/g} | sed {s/_[0-9+]*\//_*\//g} | tr -s { } | sort | uniq -c | sort -k6rn | sed "1i [concat group_size $_hdr]" | column -t > $_f_name.vectorized        
	file delete $_f_name.tmp
   
        ###
	puts "-I- fe_io_logic_levels - entering reg2out"
        set _logic_timing_data [report_timing -logic_levels $LOGIC_LEVELS -nworst $NWORST -from $local_clocks -to [get_db ports -if .direction==out] -views [get_db analysis_views -if .is_setup_default==true] -logic_levels_tcl_list]
	set _f_name "[get_db user_stage_reports_dir]/${stage}_report_output_logic_levels.rpt"
        set _f [open $_f_name.tmp w]
        puts $_f "$_hdr" 
        foreach _path $_logic_timing_data {
            lassign $_path st end logic
            set st_clk  [file tail [get_db [get_db pins $st] .clocks.name]]
            set end_clk [file tail [lindex [get_db [get_db ports $end] .timing_info] 0 3 0]]
            set clk_prd [lindex [get_db [get_db clocks */$end_clk] .period] 0]
            puts $_f "$st $end $st_clk $end_clk $logic $clk_prd"
        }
        close $_f
        exec cat $_f_name.tmp | column -t > $_f_name
        exec cat $_f_name     | sed {s/\[[0-9+]*\]/[*]/g} | sed {s/_[0-9+]*_/_*_/g} | sed {s/_[0-9+]*\//_*\//g} | tr -s { } | sort | uniq -c | sort -k6rn | sed "1i [concat group_size $_hdr]" | column -t > $_f_name.vectorized        
	file delete $_f_name.tmp
    }
    # // init for filtered violations reports
    puts "-I- fe_io_logic_levels - checking all"
    set _logic_timing_data [report_timing -logic_levels $LOGIC_LEVELS -nworst $NWORST -views [get_db analysis_views -if .is_setup_default==true] -logic_levels_tcl_list]
    set _f_name "[get_db user_stage_reports_dir]/${stage}_report_all_logic_levels.rpt"
    set _f [open $_f_name.tmp w]
    puts $_f "$_hdr" 
    
    foreach _path $_logic_timing_data {
        lassign $_path st end logic
        set st_clk  [file tail [get_db [get_db pins $st] .clocks.name]]
        set end_clk [file tail [lindex [get_db [get_db pins $end] .timing_info] 0 3 0]]
        set clk_prd [lindex [get_db [get_db clocks */$end_clk] .period] 0]
        puts $_f "$st $end $st_clk $end_clk $logic $clk_prd"
    }
    close $_f
    exec cat $_f_name.tmp | column -t > $_f_name
    exec cat $_f_name     | sed {s/\[[0-9+]*\]/[*]/g} | sed {s/_[0-9+]*_/_*_/g} | sed {s/_[0-9+]*\//_*\//g} | tr -s { } | sort | uniq -c | sort -k6rn | sed "1i [concat group_size $_hdr]" | column -t > $_f_name.vectorized        
    file delete $_f_name.tmp
    puts "-I- Done with report stage"
  } ;# END OF CREATING REPORTS

  if { [regexp "viol" $rpt_type] } {
    puts "-I- Starting Violations analysis"
    if { $report_name != "" } {
        set f_rpt $report_name
    } else {
        set f_rpt "[get_db user_stage_reports_dir]/${stage}_report_all_logic_levels.rpt"
    }
    if { [file exists $f_rpt] } {
        # parse existing file
        set _v_name "[get_db user_stage_reports_dir]/${stage}_logic_levels_violation.rpt"
        set _v [open $_v_name.tmp w]
        puts $_v "[concat $_hdr threshold]" 
        array set path_periods ""
        foreach "st end per" $overrides {
            set path_periods($st,$end,user) "$per"
        }
        set f [open $f_rpt r] ; set rpt_data [split [read $f] "\n"] ; close $f
        foreach line [lrange $rpt_data 1 end] {
            lassign $line st end st_clk end_clk logic clk_prd
            if { $clk_prd == "" } { continue }
            set found_ovrd 0
            foreach "_st _end _src" [regsub -all "," [array names path_periods] " "] {
                if { ([string match $_st $st_clk])&&([string match $_end $end_clk]) } {
                    set thr $path_periods($_st,$_end,$_src)
                    set found_ovrd 1
                    break
                }
            }
            if { !$found_ovrd } {
                set thr [expr int(ceil((($clk_prd*$CLK_DERATE)-$CLK_JTR)/$MEAN_DLY) - 2)]   ;# 8% + 75ps clk_derate + jitter, assuming mean delay 0.025, 2 additionals stages for FF delay
                set path_periods($st_clk,$end_clk,formula) $thr
                set _src "formula"
            }
            if { $logic >= $thr } {
                puts $_v "$st $end $st_clk $end_clk $logic $clk_prd ${thr}(${_src})"
            } 
        }
        close $_v
        exec cat $_v_name.tmp | column -t > $_v_name
        exec rm $_v_name.tmp
    } else {
        fe_io_logic_levels $stage "rpt_and_viol" $overrides $report_name
    }
  }  
}

proc fe_report_io_fo { stage {dbg 0} } {
    
    global scenarios

    set div_clk_by "1000.0"

    set alrgs [add_to_collection [all_registers -edge] [all_registers -level]]
    set alcgs [get_cells [get_db insts -if .is_integrated_clock_gating]]
    
    set alrgs [remove_from_collection $alrgs $alcgs]
    
    array set clock_periods ""

    # Inputs 
    set ai [filter_collection [all_inputs] is_clock_used_as_clock!=true]
    
    set ai_table {}
    set ai_det_table {}
    
   if { $dbg } { puts "-dbg- 000 - entering main inputs loop" }

    foreach_in_collection port $ai {
        set name [get_db $port .name]
        if { $dbg } { puts "-dbg- 001 -   starting on   $name" }
        
        set all_fo [all_fanout -from $port -flat -end -only]
        set fo   [common_collection $all_fo $alrgs]
        set cgs  [common_collection $all_fo $alcgs]
        
        set clk  [file tail [lindex [get_db [get_db $port] .timing_info] 0 1 0]]
        if { ![info exists clock_periods($clk)] } {
            set prd [get_db [get_db clocks [lindex $scenarios(setup) 0]/$clk] .period]
	    if { [string is double $prd] && [string length $prd] } {
	    	set clock_periods($clk) [expr $prd/$div_clk_by]
            } else {
 		set clock_periods($clk) $prd
	    }
        }
        
        while { [sizeof $cgs] } {
            set _fo [all_fanout -only -flat -end -from [get_pins -of $cgs -filter direction==out]]
            set cgs   [remove_from_collection [common_collection $_fo $alcgs] $cgs]
            if { [sizeof $_fo] } { append_to_collection -unique fo $_fo }
        }
        
        # <HN> displaying only 100 first fanouts because TCL shell get's stuck sorting larger lists
        if { [sizeof $fo] > 0 } { set names [lrange [get_db $fo .name] 0 99] } else { set names [get_db $fo .name] }
        
        lappend ai_table     [list $name $clk:$clock_periods($clk) [sizeof $fo]]
        lappend ai_det_table [list $name $clk:$clock_periods($clk) [sizeof $fo] $names]       
        if { $dbg } { puts "-dbg- 002 -   done with     $name" }
    }
    if { $dbg } { puts "-dbg- 005 - INPUTS DONE - finished main loop" }
    set sort_ai_table     [lsort -index 2 -dec -real $ai_table]         
    set sort_ai_det_table [lsort -index 2 -dec -real $ai_det_table]      
    if { $dbg } { puts "-dbg- 006 - INPUTS DONE - lists sorted" }
    
    # Outputs 
    set ao [all_outputs]
    
    set ao_table {}
    set ao_det_table {}    

    if { $dbg } { puts "-dbg- 010 - entering main outputs loop" }
    
    foreach_in_collection port $ao {
        if { $dbg } { puts "-dbg- 011 -   starting on   $name" }
        set name [get_db $port .name]
        set fi   [common_collection [all_fanin -to $port -flat -start -only] $alrgs]

        set clk  [file tail [lindex [get_db [get_db $port] .timing_info] 0 3 0]]
        if { ![info exists clock_periods($clk)] } {
            set clock_periods($clk) ""
        }
        
        # <HN> displaying only 100 first fanins because TCL shell get's stuck sorting larger lists
        if { [sizeof $fi] > 0 } { set names [lrange [get_db $fi .name] 0 99] } else { set names [get_db $fi .name] }
        
        lappend ao_table     [list $name $clk:$clock_periods($clk) [sizeof $fi]]
        lappend ao_det_table [list $name $clk:$clock_periods($clk) [sizeof $fi] $names]        
        if { $dbg } { puts "-dbg- 012 -   done with     $name" }
    }
    if { $dbg } { puts "-dbg- 015 - OUTPUTS DONE - finished main loop" }
    set sort_ao_table     [lsort -index 2 -dec -real $ao_table]         
    set sort_ao_det_table [lsort -index 2 -dec -real $ao_det_table]     
    if { $dbg } { puts "-dbg- 016 - OUTPUTS DONE - lists sorted" }
    
    redirect [get_db user_stage_reports_dir]/${stage}_outputs_fi_size.rpt          { rls_table -table $sort_ao_table -spac -breaks -header [list "Port_Name" "Clk" "FI"] }
    redirect [get_db user_stage_reports_dir]/${stage}_inputs_fo_size.rpt           { rls_table -table $sort_ai_table -spac -breaks -header [list "Port_Name" "Clk" "FO"] }    
    redirect [get_db user_stage_reports_dir]/${stage}_outputs_fi_size.rpt.detailed { rls_table -table $sort_ao_det_table -spac -breaks -header [list "Port_Name" "Clk" "FI" "Startpoints"] }
    redirect [get_db user_stage_reports_dir]/${stage}_inputs_fo_size.rpt.detailed  { rls_table -table $sort_ai_det_table -spac -breaks -header [list "Port_Name" "Clk" "FO" "Endpoints"] }        
    
    exec cat [get_db user_stage_reports_dir]/${stage}_outputs_fi_size.rpt | tail -n +3 | tr {\|} { } | sed {s/\[[0-9+]*\]/[*]/g} | tr -s { } | sort | uniq -c | sort -k4rn | sed {1i Group_size Name Clk FI} | column -t > [get_db user_stage_reports_dir]/${stage}_outputs_fi_size.rpt.vectorized
    exec cat [get_db user_stage_reports_dir]/${stage}_inputs_fo_size.rpt  | tail -n +3 | tr {\|} { } | sed {s/\[[0-9+]*\]/[*]/g} | tr -s { } | sort | uniq -c | sort -k4rn | sed {1i Group_size Name Clk FO} | column -t > [get_db user_stage_reports_dir]/${stage}_inputs_fo_size.rpt.vectorized    
    if { $dbg } { puts "-dbg- 100 - ALL DONE : [get_db user_stage_reports_dir]/${stage}_inputs_fo_size.rpt" } 
}

proc fe_report_messages { stage } {

    puts "-I- Report filtered messages"
    set file_name [get_db user_reports_dir]/report_messages_${stage}.rpt
    redirect -var res { report_messages -warning -error -all -message_list "[get_db messages .name SDC* CDFG* ELAB*]" } 
    
    set index 0
    set fp [open $file_name w]
    foreach line [split $res "\n"] {
        puts "-D-[format "%-4d" $index] $line"
        puts $fp $line
        incr index
    }
    close $fp

    puts "-I- Report all messages"
    set file_name [get_db user_reports_dir]/report_messages_all_${stage}.rpt
    redirect  -var res  { report_messages -all }
    
    set index 0
    set fp [open $file_name w]
    foreach line [split $res "\n"] {
        puts "-D-[format "%-4d" $index] $line"
        puts $fp $line
        incr index
    }
    close $fp

}


proc fe_report_ft { } {
    #            - report_feedthrough:   
    proc _find_inport { outport } {  
        get_ports [all_fanin -to $outport -flat -startpoints_only] -quiet -filter "direction==in"
    }
    
    set port [open [get_db user_stage_reports_dir]/feedthrough.rpt w]
    foreach outport [get_object_name [get_ports * -filter "direction==out"]] {
        if {[set input [_find_inport $outport]] ne ""} { 
            foreach_in_collection in $input {
                puts $port [format "%-20s %-20s" "[get_object_name $in]" " --> $outport"]
            }
        }
    }
    close $port
    exec cat [get_db user_stage_reports_dir]/feedthrough.rpt | sed {s/\[[0-9+]*\]/[*]/g} | tr -s { } | sort | uniq -c | sort -k1rn | sed {1i Num Inport Outport} | column -t > [get_db user_stage_reports_dir]/feedthrough.rpt.vectorized    

}


proc fe_report_timing_logic_levels { file_name } {
    set start_t [clock seconds]
    puts "-I- Start running fe_report_timing_logic_levels $file_name at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
    
    
#    report_timing -logic_levels 10000 -views [lindex [get_db [get_db analysis_views *setup*] .name] 0] > $file_name

    set _hdr "Start End StartClk EndClk LogicLevels"
    # <HN> currently selecting only first view for multy view mode - not sure why.. review
    if {[llength [get_db analysis_views ]] > 1} {
        set _logic_timing_data [report_timing -logic_levels 50000 -views [lindex [get_db [get_db analysis_views *setup*] .name] 0] -logic_levels_tcl_list]
    } else {
        set _logic_timing_data [report_timing -logic_levels 50000 -views [get_db [get_db analysis_views] .name] -logic_levels_tcl_list]
    }
    set _f_name "$file_name"
    set _f [open $_f_name.tmp w]
    puts $_f "$_hdr" 
    foreach _path $_logic_timing_data {
        lassign $_path st end logic
        set st_clk  [file tail [get_db [get_db pins $st] .clocks.name]]
        set end_clk [file tail [lindex [get_db [get_db pins $end] .timing_info] 0 3 0]]
        set clk_prd [lindex [get_db [get_db clocks */$end_clk] .period] 0]
        puts $_f "$st $end $end_clk $clk_prd $logic"
    }
    close $_f
    exec cat $_f_name.tmp | column -t > $_f_name
    exec cat $_f_name     | sed {s/\[[0-9+]*\]/[*]/g} | sed {s/_[0-9+]*_/_*_/g} | sed {s/_[0-9+]*\//_*\//g} | tr -s { } | sort | uniq -c | sort -k6rn | sed {1i group_size Startpoints Endpoints EndClock ClkPeriod LogicLevels} | column -t > $_f_name.vectorized        

    set end_t [clock seconds]
    puts "-I- End running fe_report_timing_logic_levels $file_name at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
    puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
}

proc report_ports_status { {file ""} } {
    set start_t [clock seconds]
    puts "-I- Start running report_ports_status $file at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
    
    set ports [get_ports]
    
    array unset sum_arr
    set sum_arr(in:ports) 0
    set sum_arr(in:comb) 0
    set sum_arr(in:reg) 0
    set sum_arr(in:NoReg) 0
    set sum_arr(in:fio) 0
    set sum_arr(in:bbox) 0
    set sum_arr(in:ft) 0
    
    set sum_arr(out:ports) 0
    set sum_arr(out:comb) 0
    set sum_arr(out:reg) 0
    set sum_arr(out:NoReg) 0
    set sum_arr(out:fio) 0
    set sum_arr(out:bbox) 0
    set sum_arr(out:ft) 0

    set sum_arr(inout:ports) 0
    set sum_arr(inout:comb) 0
    set sum_arr(inout:reg) 0
    set sum_arr(inout:NoReg) 0
    set sum_arr(inout:fio) 0
    set sum_arr(inout:bbox) 0
    set sum_arr(inout:ft) 0
    

    set res {}
    
    foreach_in_collection p $ports {
        puts "-D- [ory_time::now] -- [get_object_name $p]"
        lappend res [report_port_status $p]
    }
    set res [lsort -index 3 -real -dec $res]
    if { $file == "" } { set fp [open reports/report_ports_status.rpt w] } { set fp [open $file w] }
    puts $fp "Name Dir Reg/Not FoutCnt DFFCnt FdThCnt Combo/NoCombo LgcLvl IsBBox IsReg"    
    foreach line $res {
        puts $fp [string map {"{" "" "}" ""} $line]
        set spline [split $line " "]
        lassign $spline name dir NoReg fio DffCnt ft comb lvl bbox reg
        set sum_arr($dir:ports) [expr $sum_arr($dir:ports) + 1]  
        if { $fio    != "na" && $fio>1          } { set sum_arr($dir:fio)   [expr $sum_arr($dir:fio) + 1]  } 
        if { $comb   != "na" && $comb=="Yes"    } { set sum_arr($dir:comb)  [expr $sum_arr($dir:comb) + 1] } 
        if { $reg    != "na" && $reg            } { set sum_arr($dir:reg)   [expr $sum_arr($dir:reg) + 1]  }        
        if { $NoReg  != "na" && $NoReg=="Yes"   } { set sum_arr($dir:NoReg) [expr $sum_arr($dir:NoReg) + 1]}        
        if { $bbox   != "na" && $bbox           } { set sum_arr($dir:bbox)  [expr $sum_arr($dir:bbox) + 1] }
        if { $ft     != "na" && $ft             } { set sum_arr($dir:ft)    [expr $sum_arr($dir:ft) + 1]   }
        
    }
    

    puts $fp "\nTotal:"    
    puts $fp "Dir PortCount Reg/Not FoutCnt FdThCnt Combo/NoCombo IsBBox IsReg"
    puts $fp "Inputs $sum_arr(in:ports) $sum_arr(in:NoReg) $sum_arr(in:fio) $sum_arr(in:ft) $sum_arr(in:comb) $sum_arr(in:bbox) $sum_arr(in:reg) " 
    puts $fp "Outputs $sum_arr(out:ports) $sum_arr(out:NoReg) $sum_arr(out:fio) $sum_arr(out:ft) $sum_arr(out:comb) $sum_arr(out:bbox) $sum_arr(out:reg) "
    puts $fp "Inoutputs $sum_arr(inout:ports) $sum_arr(inout:NoReg) $sum_arr(inout:fio) $sum_arr(inout:ft) $sum_arr(inout:comb) $sum_arr(inout:bbox) $sum_arr(inout:reg) "
    
    close $fp
#    parray sum_arr
    set end_t [clock seconds]
    puts "-I- End running report_ports_status $file at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
    puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
}

proc report_port_status { port } {
    
    set dir [get_db $port .direction]
    set fio -1
    set is_comb false  
    set is_reg false  
    set is_bbox false
    set is_ft false
    set is_not_reg false
    set lvl -1
    set dff_cnt -1

    if { $dir == "in" } {
        
        set afo_only     [all_fanout -from $port -flat -only_cells]
        set afo_only_end [all_fanout -from $port -flat -only_cells -end]
        if { [sizeof [set afo [all_fanout -from $port -flat -end]]] == 0 } { set afo $afo_only }
        set afo     [remove_from_collection $afo $port]
        set comb    [filter_collection -quiet $afo_only "is_combinational==true&&is_sequential==false&&is_hard_macro==false&&ref_name!~*INV*&&ref_name!~*BUF*"]
        set bbox    [filter_collection -quiet $afo_only "is_hard_macro==true"]
        set ft_bbox [filter_collection -quiet [remove_from_collection $afo_only $afo_only_end] "is_hard_macro==true"]
        set dff     [filter_collection -quiet $afo_only_end "is_sequential==true&&is_black_box==false"]
        
        set fio      [sizeof  $afo]
#        TODO: filter real blackboxes!!!!
        set is_comb    [expr [sizeof $comb   ] ? true : false] 
        set is_bbox    [expr [sizeof $bbox   ] ? true : false]         
        set is_ft_bbox [expr [sizeof $ft_bbox] ? true : false]
        set is_reg     [expr !$is_comb && [set dff_cnt [sizeof $dff]] > 0 ? true : false]
        set is_not_reg [expr $is_comb || $fio > 1 || !$is_reg ? true : false]
#        set is_ft    [expr [sizeof [get_ports -quiet [all_connected -leaf [all_connected $port]]]] > 1 ? true : false]         
        set is_ft      [expr !$is_ft_bbox && [sizeof [get_ports -quiet $afo]]>0 ? [sizeof [get_ports -quiet $afo]] : 0] 
        set lvl        [lindex [get_fi_depth $port] 0]        

        
    } elseif { $dir == "out" } {
        set afi_only       [all_fanin -to $port -flat -only_cells]
        set afi_only_start [all_fanin -to $port -flat -only_cells -start]
        if { [sizeof [set afi [all_fanin -to $port -flat -start]]] == 0 } { set afi $afi_only_start }
        set comb    [filter_collection -quiet $afi_only "is_combinational==true&&is_sequential==false&&is_hard_macro==false&&ref_name!~*INV*&&ref_name!~*BUF*"]
        set bbox    [filter_collection -quiet $afi_only "is_hard_macro==true"]
        set ft_bbox [filter_collection -quiet [remove_from_collection $afi_only $afi_only_start] "is_hard_macro==true"]
        set dff     [filter_collection -quiet $afi_only_start "is_sequential==true&&is_hard_macro==false"]
        
        set afi [remove_from_collection $afi $port]
        set fio      [sizeof [get_cells -quiet -of $afi]]
        
#        TODO: filter real blackboxes!!!!
        set is_comb    [expr [sizeof $comb] ? true : false]         
        set is_bbox    [expr [sizeof $bbox] ? true : false]         
        set is_ft_bbox [expr [sizeof $ft_bbox] ? true : false]
        set is_reg     [expr !$is_comb && [set dff_cnt [sizeof $dff]] > 0 ? true : false]                 
        set is_not_reg [expr $is_comb || $fio > 1 || !$is_reg ? true : false]

#        set is_ft    [expr [sizeof [get_ports -quiet $afi]] > 0 ? true : false]  
        set is_ft      [expr !$is_ft_bbox && [sizeof [get_ports -quiet $afi]]>0 ? [sizeof [get_ports -quiet $afi]] : 0]         
        set lvl        [lindex [get_fo_depth $port] 0]
        
    } else {

    }
    
    set res [list [get_object_name $port] $dir [expr $is_not_reg ? "No" : "Yes"] $fio $dff_cnt $is_ft [expr $is_comb ? "Yes" : "No" ] $lvl $is_bbox $is_reg]
    
}   

proc get_fi_depth { p {th 100}} {

  set itr 0
  set root_p $p
  set n [get_nets -of $root_p]

  while { $itr < $th } {
     
      set pi [get_pins -leaf -quiet -of $n -filter direction==in]
      set root_p [get_pins -leaf -quiet -of [get_cells -quiet -of $pi -filter is_sequential==false&&is_macro==false&&is_black_box==false] -filter direction==out]

#      puts "-D- $itr --- [sizeof $n] --- [sizeof $root_p]"

      if { [sizeof $root_p] } {
          set n [get_nets -of $root_p]
          incr itr
          set ep [get_object_name [index_collection [get_cells -of $root_p] 0]]
      } else {
          if { [sizeof [set regs [get_cells -quiet -of $pi -filter is_sequential==true]]] > 0 } { set ep [get_object_name [index_collection $regs 0]] } { set ep "" } 
          break
      }                
      
  }

  return [list $itr $ep] 
  
}

proc get_fo_depth { p {th 100} } {

  set itr 0

  set sink_p $p
  set n [get_nets -of $sink_p]

  while { $itr < $th } {
      set po [get_pins -leaf -quiet -of $n -filter direction==out&&is_hierarchical==false]
      set sink_p [get_pins -leaf -quiet -of [get_cells -quiet -of $po -filter is_sequential==false&&is_macro==false&&is_black_box==false] -filter direction==in]

      if { [sizeof $sink_p] } {
          set n [get_nets -of $sink_p]
          incr itr
          set sp [get_object_name [index_collection [get_cells -of $sink_p] 0]]
      } else {
          if { [sizeof [set regs [get_cells -quiet -of $po -filter is_sequential==true]]] > 0 } { set sp [get_object_name [index_collection $regs 0]] } { set sp "" } 
          break
      }
  }

  return [list $itr $sp]
  
}

proc fi_depth { {file ""} {p_col ""} {thr 100} {prnt_bin 20} {dbg 0} } {
  set start_t [clock seconds]
  puts "-I- Start running fi_depth $file at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"


  array unset dbg_arr
  
  if { $file == ""  } { set file reports/report_inputs_logic_levels.rpt }
  if { $p_col == "" } { set p_col [all_inputs] }
  
  set p_sz [sizeof $p_col]
  set cnt_milestone [expr ceil($p_sz/$prnt_bin)]
  set mult 1

  set mode "thr"
  set max_port_len 0
  set max_ep_len 0
  set table {}
  set bad_ports ""
  set cnt 0
  
  if { $thr < 0 } { set thr 9999 ; set mode "max"}

  foreach_in_collection p $p_col {
    incr cnt

    set itr 0
    
    set root_p $p
    set n [get_nets -of $root_p]
    
    set less_than 0

    if { $dbg > 1} { puts "Starting on port $cnt : [get_object_name $p]" }
    
    while { $itr < $thr } {
    
        set pi [get_pins -leaf -quiet -of $n -filter direction==in]
        set root_p [get_pins -leaf -quiet -of [get_cells -quiet -of $pi -filter is_sequential==false&&is_macro==false&&is_black_box==false] -filter direction==out]
        
        if { [sizeof $root_p] } {
            set n [get_nets -of $root_p]
            incr itr
            if { $dbg > 1 } { puts "  iter $itr" ; foreach_in_collection _pi $pi { puts "    [get_object_name $_pi]" } }
            if { $dbg > 0 } { set array_dbg(${cnt}__${itr}) $pi }
            set ep [get_object_name [index_collection [get_cells -of $root_p] 0]]
        } else {
            set less_than 1
            if { [sizeof [set regs [get_cells -quiet -of $pi -filter is_sequential==true]]] > 0 } { set ep [get_object_name [index_collection $regs 0]] } { set ep "" } 
            break
        }                
    }
    if { [set new_len [string length $ep]] > $max_ep_len                    } { set max_ep_len   $new_len }
    if { [set new_len [string length [get_object_name $p]]] > $max_port_len } { set max_port_len $new_len }  
    set new_line [list [get_object_name $p] $itr $ep]
    lappend table $new_line

    if { !$less_than } { append_to_col bad_ports $p }
    
    if { $cnt > [expr $cnt_milestone*$mult] } {
      puts "$cnt / $p_sz   -   found [sizeof_collection $bad_ports] violating ports"
      incr mult
    }
  }
  
  set table [lsort -index 1 -real -dec $table]
  set c0    [expr ${max_port_len} + 4]
  set c2    [expr ${max_ep_len}   + 4]
  
  set fp [open $file w]
  puts $fp "-I- Found [sizeof $bad_ports] ports being sampled after more then $thr logic levels"
  puts $fp "[format "%-${c0}s" Port] [format "%13s" Logic_levels]    [format "%-${c2}s" Endpoint]"
  foreach line $table {
    puts $fp "[format "%-${c0}s" [lindex $line 0]] [format "%13s" [lindex $line 1]]    [format "%-${c2}s" [lindex $line 2]]"
  }
  close $fp
  
  if { $dbg == "1"} { 
      return [array get array_dbg]
  } else {    
      return $bad_ports
  }
  set end_t [clock seconds]
  puts "-I- End running fi_depth $file at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
  puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
  
}

proc fo_depth { {file ""} {p_col ""} {thr 100} {prnt_bin 20} } {
  set start_t [clock seconds]
  puts "-I- Start running fo_depth $file at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

  if { $file == ""  } { set file reports/report_outputs_logic_levels.rpt }
  if { $p_col == "" } { set p_col [all_outputs] }

  set p_sz [sizeof $p_col]
  set cnt_milestone [expr ceil($p_sz/$prnt_bin)]
  set mult 1

  set mode "thr"
  set max_port_len 0
  set max_sp_len 0
  set table {}
  set bad_ports ""
  set cnt 0

  if { $thr < 0 } { set thr 9999 ; set mode "max"}
  
  foreach_in_collection p $p_col {
    incr cnt

    set itr 0
    
    set sink_p $p
    set n [get_nets -of $sink_p]
    
    set less_than 0
    
    while { $itr < $thr } {
    
        set po [get_pins -leaf -quiet -of $n -filter direction==out&&is_hierarchical==false]
        set sink_p [get_pins -leaf -quiet -of [get_cells -quiet -of $po -filter is_sequential==false&&is_macro==false&&is_black_box==false] -filter direction==in]
        
        if { [sizeof $sink_p] } {
            set n [get_nets -of $sink_p]
            incr itr
            set sp [get_object_name [index_collection [get_cells -of $sink_p] 0]]
        } else {
            set less_than 1
            if { [sizeof [set regs [get_cells -quiet -of $po -filter is_sequential==true]]] > 0 } { set sp [get_object_name [index_collection $regs 0]] } { set sp "" } 
            break
        }
    }
    if { [set new_len [string length $sp]] > $max_sp_len                    } { set max_sp_len   $new_len }
    if { [set new_len [string length [get_object_name $p]]] > $max_port_len } { set max_port_len $new_len }  
    set new_line [list [get_object_name $p] $itr $sp]
    lappend table $new_line

    if { !$less_than } { append_to_col bad_ports $p }

    if { $cnt > [expr $cnt_milestone*$mult] } {
      puts "$cnt / $p_sz   -   found [sizeof_collection $bad_ports] violating ports"
      incr mult
    }
  }
  
  set table [lsort -index 1 -real -dec $table]
  set c0    [expr ${max_port_len} + 4]
  set c2    [expr ${max_sp_len}   + 4]
  
  set fp [open $file w]
  puts $fp "-I- Found [sizeof $bad_ports] ports being sampled after more then $thr logic levels"
  puts $fp "[format "%-${c0}s" Port] [format "%13s" Logic_levels]    [format "%-${c2}s" Endpoint]"
  foreach line $table {
    puts $fp "[format "%-${c0}s" [lindex $line 0]] [format "%13s" [lindex $line 1]]    [format "%-${c2}s" [lindex $line 2]]"
  }
  close $fp

  set end_t [clock seconds]
  puts "-I- End running fo_depth $file at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
  puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

  
  return $bad_ports
}

proc _hn_dbg_single_depth_path { dbg_array } {
    array set my_arr $dbg_array
    set lvl [llength [array names my_arr]]
    set end_p [get_pins -quiet $my_arr(1__${lvl}) -filter full_name!~*reg*]
    if { ![sizeof $end_p] } { set end_p [get_pins -quiet $my_arr(1__${lvl})] }
    set _p [index_col $end_p 0]

    puts "$lvl - [get_object_name $_p]"
    incr lvl -1

    while {$lvl >= 1} { 
        set _p [index_col [common_collection $my_arr(1__${lvl}) [get_pins -of [get_cells -of [get_pins -leaf -of [get_nets -of $_p] -filter direction==out]] -filter direction==in]] 0]
        puts "$lvl - [get_object_name $_p]"
        incr lvl -1
    }
}

proc fe_report_tap_clock_fo {{file ""}} {
    set clock_port [get_ports -quiet *tck*]
    if { [sizeof $clock_port] == 0 } { puts "-W- No tck clock port found" ; return -1 }
    puts "-I- Reporting FO registers of tap clock port: [get_object_name $clock_port]"
    set fo   [all_fanout -from $clock_port -flat -end -only]
    set args [all_registers]
    set fo_args [common_collection $fo $args]
    if { [sizeof $fo] == 0 } { puts "-W- No fanout found for port [get_object_name $clock_port]" ; return -1 }
    
    if { $file == "" } { set file reports/report_tap_clock_fo.rpt }
    set fp [open $file w]
    puts $fp "-I- Reporting FO registers of tap clock port: [get_object_name $clock_port]"
    foreach cell [lsort [get_object_name $fo_args]] { puts $fp $cell }
    close $fp
}


proc fe_check_clock_gate { {file ""} } {
	set start_t [clock seconds]
	puts "-I- Start running fe_check_clock_gate $file at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
    
    set allowed_cgs_names {NXT_CLK_GATE \
NXT_CLK_GATE_DFT \
NXT_CLK_MUX \
NXT_CLK_MUX4 \
NXT_CLK_INV \
NXT_CLK_BUF \
NXT_CLK_OR \
NXT_CLK_AND \
NXT_CLK_AND_3 \
NXT_DFT_TBC_CLK_BUF \
NXT_CLK_PHASE_SEL \
nxt_clk_divider }

#nxt_clk_gate_rst_ovrd \
#nxt_glitchfree_clkmux \
#nxt_glitchfree_clkmux_select \
#nxt_clk_divider \
#nxt_clk_edge_trim

    set all_edge  [all_registers -edge]
                           
    set all_clock_cells []
    set clock_sources [get_db [get_clocks  -quiet] .sources]
    if { [llength $clock_sources] == 0 } { 
        set all_clock_cells {}
    } else {
        set all_clock_cells [remove_from_collection [all_fanout -flat -from $clock_sources -only] [filter_collection $all_edge is_integrated_clock_gating_cell!=true]]            
    }
    
    set sync_cells      [filter_collection $all_clock_cells ref_name=~*RESYNC*]
    set all_clock_cells [filter_collection $all_clock_cells is_macro==false&&ref_name!~*RESYNC*]
    set non_ulvt_cgs    [filter_collection $all_clock_cells ref_name!~*UN*]
    set unmapped_clock_cells [get_db $all_clock_cells -if .base_cell==""]
    
    set not_allowed_cells {}
    set cell_name_filter_string "full_name!~*RC_CG*&&"
    set module_name_filter_string ""
    foreach pattern $allowed_cgs_names {
        append module_name_filter_string ".hinst.module.name!=*$pattern*&&" 
    }
    
    set module_name_filter_string [string trim $module_name_filter_string "&"]
    set cell_name_filter_string [string trim $cell_name_filter_string "&"]
    
    set not_allowed_cells [get_db [filter_collection $all_clock_cells $cell_name_filter_string] -if $module_name_filter_string]
    set allowed_cells     [remove_from_collection $all_clock_cells [get_cells $not_allowed_cells]]
    
    if { $file == "" } { set file reports/not_allowed_clock_gates.rpt }
    set fp [open $file w]
    puts $fp "Not Allowed Cells:\n------------------"
    foreach cell [lsort [get_object_name $not_allowed_cells]] { puts $fp $cell }
    puts $fp "\nAllowed Patterns:\n------------------"
    foreach cell [lsort $allowed_cgs_names] { puts $fp $cell }
    puts $fp "\nExclude Cells:\n------------------"
    foreach cell [lsort [get_object_name [filter_collection $all_clock_cells full_name=~*RC_CG*]]] { puts $fp $cell }
    puts $fp "\nAllowed Cells:\n------------------"
    foreach cell [get_db $allowed_cells] { puts $fp "$cell\t\t\t[get_db $cell .hinst.module.name]"}
    puts $fp "\nNon EN Synch Cells:\n------------------"
    foreach cell [get_db $sync_cells -if .base_cell!=*F6EN*] { puts $fp "$cell\t\t\t[get_db $cell .base_cell.name]"}
    puts $fp "\nNon UN Cells:\n------------------"
    foreach cell [get_db $non_ulvt_cgs] { puts $fp "$cell\t\t\t[get_db $cell .base_cell.name]"}
    close $fp 
    
    puts "-I- [sizeof $all_clock_cells] clock gates found"
    puts "-I- [sizeof $not_allowed_cells] not allowed clock gates found"
    puts "-I- [sizeof [filter_collection $all_clock_cells full_name=~*RC_CG*]] excluded clock gates found"
    puts "-I- [llength [get_db $sync_cells -if .base_cell!=*F6EN*]] non EN synchronizer cells found out of [sizeof $sync_cells]"
    puts "-I- [sizeof $non_ulvt_cgs] non UN cells out of [sizeof $all_clock_cells] clock gates found"
    puts "-I- [sizeof $unmapped_clock_cells] unmapped cells out of [sizeof $all_clock_cells] clock gates found"
    puts "-I- See detailed list in: $file"
	set end_t [clock seconds]
	puts "-I- End running fe_check_clock_gate $file at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
	puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
    
}

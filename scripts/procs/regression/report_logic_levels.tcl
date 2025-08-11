###########################################################
# This is the main proc
# Tables and parseOpt will come from the following sources
redirect /dev/null {
source /space/users/ory/user/be_scripts/regression/parseOpt.tcl
source /space/users/ory/user/be_scripts/regression/rls_table.tcl
source /space/users/ory/user/be_scripts/regression/oy_time.tcl
}
###########################################################
::parseOpt::cmdSpec ory_map_logic_levels {
    -help "Report longest-logic-levels paths"
    -opt    {
            {-optname max_paths   -type integer   -default 50000     -required 0 -help "Max number of paths for report timing"}
            {-optname nworst      -type integer   -default 50        -required 0 -help "Max number of paths per endpoint"}            
            {-optname internal    -type boolean   -default false     -required 0 -help "If false, searching IO only"}
            {-optname no_derate   -type boolean   -default false     -required 0 -help "Use set_timing_derate for more accurate results (Runtime). This may corrupt your timing status!!!!"}
            {-optname mapped      -type boolean   -default false     -required 0 -help "If the design is mapped, use collection to count levels (Runtime)"}                                    
            {-optname output      -type string    -default ""        -required 0 -help "File name"}                                                
    }
}

proc ory_map_logic_levels { args } {
	# TODO
    # CHange flags to syngen + derate -DONE
    # Check for invs in gen - Not yet
    # check internal levels - Not yet
    # Add clock + cycle - DONE
    # Report timing per port VS nworst=100 - DONE. Report by bus
    # Sanity check for outputs - with Moriya and Yigal later
    # Insert to regression flow
    # Cheatsheet to FE
	if { ! [::parseOpt::parseOpt ory_map_logic_levels $args] } { return 0 }
    set internal  $opt(-internal)
    set max_paths $opt(-max_paths)
    set nworst    $opt(-nworst)
	set no_derate $opt(-no_derate)
	set mapped    $opt(-mapped)    
    
    parray opt
    
    if { !$internal } {  
    
    	set all_inputs  [all_inputs]
    	set all_outputs [all_outputs]            
        
        set pins [all_fanout -from $all_inputs -flat]
        set pins [add_to_collection $pins [all_fanin -to $all_outputs -flat]]

        set cells [get_db [get_cells -quiet -of $pins] -if {!.is_latch==true && !.is_flop==true && !.is_sequential}]
		
        if { !$no_derate } {
            puts "-I- Derating cells delay. [::ory_time::now]"    
            foreach view [get_db analysis_views] {
	            set corner [get_db $view .delay_corner]
	            set_timing_derate -delay_corner $corner -cell_delay -late 1000  $cells
	        }    
        }
		
        # Compress bus: [3] -> * ; "1" means that 5_[3] -> *_* ; less busses. Reasonable runtime on big partitions    
		set compressed_list [ory_bus_compress [get_db [all_inputs] .name] 1]

        if { $mapped } {    
            puts "-I- Getting outputs timing paths. [::ory_time::now]: nworst=$nworst ; max_paths=$max_paths"
		    set timing_paths {}            
 		    set timing_paths [report_timing -unconstrained -collection -max_paths $max_paths -nworst $nworst -to $all_outputs]

            set nworst    [lindex [lsort -real -inc [list 10   $nworst]] 0]
            set max_paths [lindex [lsort -real -inc [list 5000 $max_paths]] 0]            
            puts "-I- Getting inputs timing paths. [::ory_time::now]: nworst=$nworst ; max_paths=$max_paths"                        
            foreach bus $compressed_list {
	            redirect /dev/null {
                	set new_timing_paths [report_timing -unconstrained -collection -max_paths $max_paths -nworst $nworst -from [get_ports $bus -filter direction==in]] 
#                    puts "$bus   [sizeof $new_timing_paths]   "
                    append_to_collection -uniq timing_paths $new_timing_paths 
                }
            }
                        puts "-I- DONE - Getting timing paths. [::ory_time::now]"
        } else {
        	set string_list [list "report_timing -max_paths $max_paths -nworst $nworst -unconstrained -from \[ all_inputs \]"]
#            set rpt_str2 "report_timing -max_paths $max_paths -nworst $nworst -unconstrained -to   \[ all_outputs \]"
            set nworst    [lindex [lsort -real -inc [list 10   $nworst]] 0]
            set max_paths [lindex [lsort -real -inc [list 5000 $max_paths]] 0]            
            foreach bus $compressed_list {
            	lappend string_list "report_timing -unconstrained -max_paths $max_paths -nworst $nworst -from \[get_ports $bus -filter direction==in\]"
            }
            
    	    puts "-I- Using get_logic_levels to retrieve logic levels. [::ory_time::now]"            
	        redirect /dev/null { applet load get_logic_levels }
            redirect /tmp/count_logic_levels.rpt {echo "# This is not empty"}
            foreach string $string_list {
            	if { $string == "" } {continue}
    	    	redirect -app /tmp/count_logic_levels.rpt { get_logic_levels -skip_buf -skip_inv $string ; puts ""}
            }
        }

    } else {

        if { !$no_derate } {
            puts "-I- Derating cells delay. [::ory_time::now]"
            set cells [get_db insts -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]
            foreach view [get_db analysis_views] {
	            set corner [get_db $view .delay_corner]
	            set_timing_derate -delay_corner $corner -cell_delay -late 1000 $cells 
	        }
        }
        
        if { $mapped } {    
            puts "-I- Getting timing paths. [::ory_time::now]"
		    set timing_paths [report_timing -collection -max_paths $max_paths -nworst $nworst]
        } else {
      	    puts "-I- Using get_logic_levels to retrieve logic levels. [::ory_time::now]"            
            redirect /dev/null { applet load get_logic_levels }
        	redirect /tmp/count_logic_levels.rpt {  get_logic_levels -skip_buf -skip_inv  "report_timing -max_paths $max_paths -nworst $nworst" }
        }

    }
	if { $mapped } {
        puts "-I- Counting cells. [::ory_time::now]"        
	    set table {}
        foreach_in_collection tp $timing_paths {
       	    set points   [get_db $tp .timing_points] 
            set start    [get_db $tp .launching_point.name]
            set end      [get_db $tp .capturing_point.name]
            set pins     [get_db [get_db $tp .timing_points] .pin]
            set cells    [get_db [get_cells -quiet -of $pins] -if {!.is_latch==true && !.is_flop==true && !.is_sequential}]
            
            set from_clock [get_db $tp .launching_clock.name]
            set to_clock   [get_db $tp .capturing_clock.name]
			
            set ct     [list [get_db [get_clocks -quiet $from_clock] .period] [get_db [get_clocks -quiet $to_clock] .period]]
            if { [lindex $ct 0] == [lindex $ct 1] } {set ct [join [lsort -u $ct]]}
            set ct [lminus $ct {{}}]
            
            set logic   [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]]
            set buffers [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && !.is_combinational==true || .is_buffer==true || .is_inverter==true}]]
            lappend table [list [llength $cells] $logic $buffers $from_clock $to_clock $ct $start $end]                        
        }
        
#        foreach_in_collection tp [common_collection $timing_paths $timing_paths] {
#			
#            set points  [get_db $tp .timing_points]
#            set start   [get_db $tp .launching_point.name]
#            set end     [get_db $tp .capturing_point.name]
#            set pins    [get_db [get_db $tp .timing_points] .pin]
#            set cells   [get_db [get_cells -quiet -of $pins] -if {!.is_latch==true && !.is_flop==true && !.is_sequential}]
#
#            if { [llength $cells] == 0 } { 
#                set logic 0 ; set buffers 0
#            } else {
#                set logic   [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && .is_combinational==true && !.is_buffer==true && !.is_inverter==true}]]
#                set buffers [llength [get_db $cells -if {!.is_latch==true && !.is_flop==true && !.is_sequential && !.is_combinational==true || .is_buffer==true || .is_inverter==true}]]
#            }
#            if {$cells == "" || $logic == "" || $buffers == "" } { return "$start $end"}
#            lappend table [list [llength $cells] $logic $buffers $start $end]
#            puts "[list [llength $cells] $logic $buffers $start $end]"
#        }
        set header        [list Cells Logic Buf_Inv FromCLK ToCLK CT From To] 
    	set sorted_table  [lsort -index 1 -real -dec $table]
        
    } else {
#    	puts "-I- Using get_logic_levels to retrieve logic levels. [::ory_time::now]"
#	    redirect /dev/null { applet load get_logic_levels }
#    	redirect /tmp/count_logic_levels.rpt { get_logic_levels -skip_buf -skip_inv $rpt_str1 ; puts ""}
#    	if { [info exists rpt_str2] } { redirect -app /tmp/count_logic_levels.rpt { get_logic_levels -skip_buf -skip_inv $rpt_str2 } }
        
        puts "-I- Parsing logic levels report. [::ory_time::now]"
        set grep_res [regsub -all "\\-\\-" [exec cat /tmp/count_logic_levels.rpt | grep -B2 "Logic Level" ] "@"]
        
        foreach phrase [split $grep_res "@"] {
        	regexp "Start Point   \\-\\> (\[a-zA-Z0-9_\\\[\\\]/\]+).+End Point     \\-\\> (\[a-zA-Z0-9_\\\[\\\]/\]+).+Logic Levels  \\-\\> (\[0-9\]+)" $phrase main start end levels
            if { !$levels } { continue }
            if { [set dec [sizeof [get_ports -quiet "$start $end"]]] } { set levels [expr $levels - (2-$dec)] }
            if { [sizeof [get_ports -quiet $start]] == 0 } { set from_clock [get_db [get_db pins $start] .clocks.base_name] } else { set from_clock ""}
            if { [sizeof [get_ports -quiet $end  ]] == 0 } { set to_clock   [get_db [get_db pins $end] .clocks.base_name]   } else { set to_clock ""}
            lappend table [list $levels $from_clock $to_clock $start $end]            
        }
        set header        [list Logic "Start_clock(s)" "End_clock(s)" From To]    	
    	set sorted_table  [lsort -index 0 -real -dec $table]       
    }

    if { $opt(-output) == "" } { set output "logic_levels_report.rpt" } else { set output $opt(-output)}    
    puts "-I- Print table to $output"
    redirect $output { rls_table -table $sorted_table -header $header -breaks }
	
    if { ![catch {glob /tmp/count_logic_levels.rpt} res] } { file delete -force /tmp/count_logic_levels.rpt }
}

proc ory_bus_compress { ports {level 0} {key_words {}} } {

	if { $level == 0 } {
	set new_list [lsort -uniq [regsub -all "_\[0-9\]+ \|_\[0-9\]+$" [regsub -all "\\\[\[0-9\]+\\\]" $ports "[*]"] "* " ] ]
    } else {
	set new_list [lsort -uniq [regsub -all "\[0-9\\\[\\\]\]+" $ports "*" ] ]
    }

	set new_list [lsort -uniq [regsub -all "_\\\*" $new_list "*" ] ]    
	set new_list [lsort -uniq [regsub -all "\\\*+" $new_list "*" ] ]        
    
    if {$key_words != {}} {
        	set regsub_string [join $key_words "\|"]
            puts $regsub_string
          	set new_list [lsort -uniq [regsub -all $regsub_string $new_list "*" ] ]
    }

	set new_list [lsort -uniq [regsub -all "\\\*+" $new_list "*" ] ]            
    
    return $new_list
    
}


















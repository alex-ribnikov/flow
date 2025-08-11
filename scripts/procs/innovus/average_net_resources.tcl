::parseOpt::cmdSpec avg_net_resources {
    -help "Report longest-logic-levels paths"
    -opt    {
            {-optname nets               -type string   -default ""       -required 0 -help ""}
            {-optname include_clocks     -type boolean  -default false -required 0 -help ""}
            {-optname update_net_length  -type boolean  -default false -required 0 -help ""}
    }
}

proc avg_net_resources { args } {
    
	if { ! [::parseOpt::parseOpt avg_net_resources $args] } { return 0 }
    
    if { $opt(-nets) != "" } {
        set nets [get_db $opt(-nets)]
    } else {
        set nets [get_db nets -if .is_clock==false&&.is_ground==false&&.is_power==false]
    }
  
    if { $opt(-update_net_length) } {
      puts "-I- Calc net length for [llength $nets] nets"
      ory_calc_net_length $nets
    }

    set resources [get_db $nets .be_detailed_net_length]
    set totals {}
    array unset res_arr
    foreach v $resources {
        lassign $v layer length
        lappend res_arr($layer) $length
        lappend totals $length
    }
    set total_length [lsum $totals]
    puts "-I- Number of nets: [llength $nets] ; Total length $total_length um"
    set acc 0
    foreach l [list 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18] {
        
        if { ![info exists res_arr(M${l})] } { continue }
        
        set layer_sum [lsum $res_arr(M${l})]
        
        set acc [expr $acc + $layer_sum]
        
        puts -nonewline "M$l\t:\t[format "%8s" [format "%.3f" [expr 100.0*$layer_sum/$total_length]]%]"
        puts            "[format "%10s" [format "%.3f" [expr 100.0*$acc/$total_length]]%]"
    }
}


proc be_report_congestion { stage {num_hotspot 10} {gui false} } {

    set file_name [get_db user_stage_reports_dir]/${stage}_congestion_report.rpt

    puts "-I- Reporting Congestion to $file_name"
    if { [get_db program_short_name] == "genus" } {
        redirect $file_name {report_congestion}        
    } else {
        redirect $file_name {report_congestion -hotspot -3d -num_hotspot $num_hotspot -overflow}
    }
    
    set fp [open $file_name]
    set cong_rpt [read $fp]
    close $fp
    
    if { ![regexp "\((\[0-9\.\]+%) H\)" $cong_rpt res hov  ] && $stage != "route" }                     { set hov "NA" } 
    if { ![regexp "\((\[0-9\.\]+%) V\)" $cong_rpt res vov  ] && $stage != "route"  }                    { set vov "NA" }
    if { ![regexp "hotspot area = (\[0-9.\]+/\[0-9.\]+)" $cong_rpt res hs_area] && $stage != "route"  } { set hs_area "NA" }        
    
    if { $gui } {
        gui_show
        set_layer_preference routeCongest -is_visible 1
        set_layer_preference node_layer -is_visible 0
        
        if { [ catch { set hs_table [exec grep -A[expr 3*$num_hotspot ] "congestion hotspot bounding boxes and scores of all layers hotspot" $file_name] } res] } {
            puts "-W- Could not find hotspot table in $file_name"
            return
        }
        
        set rect_list [regsub -all " +" [regexp -inline -all "\[0-9\\\.\]+ +\[0-9\\\.\]+ +\[0-9\\\.\]+ +\[0-9\\\.\]+" $hs_table]  " "]
        
        foreach rect $rect_list {
            create_gui_shape -rect $rect -layer BE
            set_layer_preference BE -is_visible 1
            set_layer_preference BE -color orange -stipple none
        }
    
    }
    
    set routing_status "
    [nice_header "Report Congestion"]
    H overflow            : $hov
    V overflow            : $vov
    Hotspot Area          : $hs_area (area is in unit of 4 std-cell row bins)
    "
    
    puts $routing_status
}









# TM - add procs to be_report
#######################################
# Read time_design reports from Innovus
#######################################
proc read_time_design_rpt { fileName } {
   if {[string match "*.gz" $fileName]} {
      #puts "Unzipping file $fileName"
      set fName [string replace $fileName end-2 end ""]
      exec gunzip $fileName
      set zip 1
   } else {
      set fName $fileName
      set zip 0
   }
   set timing_table {}
   set fi [open $fName r]
   while {[gets $fi data] >=0} {
      set line [lsearch -not -all -inline [split $data " | "] {}]
      if {[lindex $line 1] == "mode"} {
         set title [lrange $line 2 end-1]
         #puts $title
      } elseif {[lindex $line 0] == "WNS"} {
         set wns_tmp [lrange $line 2 end-1]
         set wns {}
         foreach ww $wns_tmp {
	    if {[regexp "N/A" $ww]} { 
	        lappend wns $ww
	    } else {
                lappend wns [expr 1000*$ww]
	    }
         }
         #puts $wns
      } elseif {[lindex $line 0] == "TNS"} {
         set tns_tmp [lrange $line 2 end-1]
         set tns {}
         foreach tt $tns_tmp {
	    if {[regexp "N/A" $tt]} { 
	        lappend tns $tt
	    } else {
                lappend tns [expr 1000*$tt]
	    }
         }
         #puts $tns
      } elseif {[lindex $line 0] == "Violating"} {
         set vp [lrange $line 2 end-1]
         #puts $vp
      } elseif {[lindex $line 0] == "All"} {
         set all [lrange $line 2 end-1]
         #puts $all
         foreach tt $title {
            set ind [lsearch $title $tt]
            lappend timing_table [list $tt [lindex $wns $ind] [lindex $tns $ind] [lindex $vp $ind]]
         }
      }
   }
   close $fi
   if {$zip} {
#      puts "Zipping file $fileName"
      exec gzip $fName
   }
   return $timing_table
}

#############################
####################################
# Users mail list
####################################
#proc be_get_supper_user_email { {project "NONE"} } {
#
#    set supper_user_mail_arr(idon)  "all"
#    set supper_user_mail_arr(royl)  "all"
#    set supper_user_mail_arr(nitzano)  "nxt013"
#    unset -nocomplain arr
#    
#    foreach key [array name supper_user_mail_arr] {
#        set value $supper_user_mail_arr($key)
#	if {[regexp all $value] || [regexp $project $value]} {
#	    lappend arr $key
#	}
#    }
#    if {[info exists arr] && [llength $arr] > 0} {
#        return $arr
#    }
#        
#}
#

####################################
# Users mail list
####################################
#proc be_get_user_email { {user ""} } {
#
#    array set user_mail_arr "
#    idon        ido.naishtein@nextsilicon.com
#    ory         or.yagev@nextsilicon.com
#    meravi      merav.ifrach@nextsilicon.com
#    royl        roy.leibo@nextsilicon.com
#    hilleln     hillel.nevo@nextsilicon.com
#    yigal       yigal.hacham@nextsilicon.com
#    igorb       igor.bernshtein@nextsilicon.com
#    liorb       lior.burshtein@nextsilicon.com
#    liorz       lior.zucker@nextsilicon.com
#    nitzano     nitzan.ovadia@nextsilicon.com
#    talm        tal.mazor@nextsilicon.com
#    shaisa      shai.sade@nextsilicon.com
#    moshela     moshe.lavi@nextsilicon.com
#    rivkah      rivka.henchinski@nextsilicon.com
#    tamarc      tamar.cooper@nextsilicon.com
#    rinate      rinat.epstein@nextsilicon.com
#    noac        noa.cohen@nextsilicon.com
#    ehudk       ehud.kantorovich@nextsilicon.com
#    "
#    if { $user == "" } { set user $::env(USER) }
#    
#    if { [info exists user_mail_arr($user)] } {
#          return $user_mail_arr($user)
#    } else {        
#        if { ![catch { set address [exec git config --global user.email] } res] && $address != "" } {
#            return [regsub -all {\"} $address {}]
#        }                 
#        puts "-W- No email adress found for $user"
#        return ""
#    }    
#}

if { [info command be_get_user_email] != "" } {
	puts "-I- Sourcing BE_MAILS from common"
	source scripts/procs/common/be_mails.tcl
}

####################################
# Return report header
####################################
proc be_get_report_header { {report_name ""} } {

    global PROJECT
    global DESIGN_NAME
    global STAGE
    
    set pawad   [exec pwd]
    set run     [lindex [split $pawad "/"] end]
    set version [lindex [split $pawad "/"] end-1]

#    if { [info exists ${PROJECT}] } { set project $${PROJECT} } else { set project [lindex [split $pawad "/"] end-3] }
    
#    if { [info exists ::env(BLOCK)] } { 
#        set block $::env(BLOCK)     
#    } elseif { [info exists ::DESIGN_NAME] } {
#        set block $::DESIGN_NAME
#    } elseif { [llength [get_db designs .name]] > 0 } { 
#        set block [get_db designs .name]
#    } else {
#        set block   [lindex [split $pawad "/"] end-2] 
#    }
    
#    if { [info exists ::STAGE] } { set stage $::STAGE } else { set stage [get_db be_stage] }
    
    if { [llength [get_db attributes *design_source]] > 0 } { set ds [get_db design_source] } else { set ds "" }   


    set file_header "
============================================================
  Report:                 $report_name
  Generated by:           [get_db program_name] [get_db program_version]
  Generated on:           [clock format [clock seconds] -format "%b %d %Y   %r"]
  Module:                 [get_db designs .name]
  Operating conditions:   [get_db [get_db analysis_views -if {.is_setup==true}] .name] 
  Operating conditions:   [get_db [get_db analysis_views -if {.is_hold==true}] .name] 
  User:                   $::env(USER)
  Folder:                 [exec pwd]
  Run:                    $run  
  Version:                $version  
  Project:                $PROJECT  
  Block:                  $DESIGN_NAME
  Stage:                  $STAGE
  Design Source:          $ds
============================================================
    "
    
    return $file_header
}

####################################
# Return section header
####################################
proc nice_header { text_here } {
    set upper  [string toupper $text_here]
    set length [string length $text_here]
    set line   [string repeat "=" [expr $length + 8]]
    
    set nh "
$line
==  $upper  ==
$line"

  return $nh
}


##################
# Report QOR
# Generate a bunch of reports
# Parse them nicely
# TODO: Add flags / verbose/ modes?
##################
::parseOpt::cmdSpec be_reports {
    -help "Generate BE reports in Genus and Innovus"
    -opt    {
            {-optname stage       -type string    -default ""        -required 1 -help "The stage you are at"}
            {-optname block       -type string    -default ""        -required 0 -help "Your block"}            
            {-optname output      -type string    -default ""        -required 0 -help "Output file name"}                                                
            {-optname output_dir  -type string    -default ""        -required 0 -help "Output directory for detailed reports. Default is coming from 'get_db user_reports_dir'"}                                                            
            {-optname all         -type boolean   -default false     -required 0 -help "Generate all reports regardless of other flags"}
            {-optname verbose     -type boolean   -default false     -required 0 -help "Generate even more reports!"}            
            {-optname timing      -type boolean   -default true      -required 0 -help "Generate timing reports"}
            {-optname clocks      -type boolean   -default false     -required 0 -help "Generate clock (info) reports"}
            {-optname cts         -type boolean   -default false     -required 0 -help "Generate CTS quality reports"}            
            {-optname count       -type boolean   -default true      -required 0 -help "Generate cell count report"}                                    
            {-optname multibit    -type boolean   -default false     -required 0 -help "Generate multibit report"}                                                
            {-optname utilization -type boolean   -default true      -required 0 -help "Generate utilization and area reports"}                                    
            {-optname power       -type boolean   -default false     -required 0 -help "Generate pwoer reports"}                                    
            {-optname routing     -type boolean   -default false     -required 0 -help "Generate routing congestion and drc reports"}                                                
            {-optname sequentials -type boolean   -default false     -required 0 -help "Generate removed and unclocked regs reports (Empty in Innovus)"}                                    
            {-optname post_route_extraction_effort -type string   -default "medium"     -required 0 -help "(low / medium / high) Default extraction effort is Low to save runtime in Innovus."}                                                
            {-optname execute     -type boolean   -default false     -required 0 -help "WIP - Run Actual reports or just post_process from existing reports"}                                    
            {-optname mail        -type boolean   -default false     -required 0 -help "Mail the user (if email exists in be_get_user_email proc). Use be_show_proc be_get_user_email if needed"}                                    
    }
}

##################
# Unified format for BE QOR report
# + Prints some detailed reports
##################
proc be_reports { args } {
   global STAGE

    if { ! [::parseOpt::parseOpt be_reports $args] } { return 0 }

    set stage       $opt(-stage)
    set block       $opt(-block)
    set output      $opt(-output)
    set output_dir  $opt(-output_dir)    
    set all         $opt(-all)
    set verbose     $opt(-verbose)
    set timing      $opt(-timing)
    set clocks      $opt(-clocks)
    set cts         $opt(-cts)    
    set count       $opt(-count)    
    set mbit        $opt(-multibit)        
    set utilization $opt(-utilization)
    set power       $opt(-power)
    set routing     $opt(-routing)
    set sequentials $opt(-sequentials)
    set extraction_effort $opt(-post_route_extraction_effort)    

    set pawad   [exec pwd]
    set run     [lindex [split $pawad "/"] end]
    set version [lindex [split $pawad "/"] end-1]
#    if { [info exists ${PROJECT}]               } { set project $${PROJECT} } else { set project [lindex [split $pawad "/"] end-3] }
    if { $block == "" && [info exists ::DESIGN_NAME] } { set block $::DESIGN_NAME     } else { set block   [lindex [split $pawad "/"] end-2] }

    if { $output_dir != "" } { 
    	set tmp_out_dir [get_db user_reports_dir] 
        set_db user_reports_dir $output_dir 
        set_db user_stage_reports_dir $output_dir
    } 
    
    if { $stage != "" } {
        set_db -quiet be_stage $stage
    } else {
        if { [info exists ::STAGE] } { set stage $::STAGE ; set_db -quiet be_stage $stage } else { set stage [get_db be_stage] }     
    }


    set file_header [be_get_report_header be_reports]
    

    ##################################  
    # Report timing summary
    if { $all || $timing } {

    puts "-I- Getting timing data [::ory_time::now]"
    
    if { ![regexp "Genus" [get_db program_name]] && ( [set current_effort [get_db extract_rc_effort_level]] != $extraction_effort ) } {
        set_db extract_rc_effort_level $extraction_effort
    }
    
    if { $verbose } {
        be_generate_timing_reports $stage 
    }
    
    redirect -var table_res { catch { be_short_report_timing_summary $stage $block } _res }
    if { [string length $_res] } { puts "-E- be_short_report_timing_summary finished with an error: $_res" }
    set timing_status "
    [nice_header "Timing QOR"] \n$table_res"

    }
    ##################################    


    ##################################  
    # Report clocks
    # TODO: Do I need all these reports? maybe add flags or options for them?
    if { $all || $clocks } {
        
    puts "-I- Getting clocks data [::ory_time::now]"
    if {[get_db program_short_name] == "innovus"} {
       redirect [get_db user_stage_reports_dir]/${stage}_report_clock_gating.rpt { report_clock_gating_check }
    } else {
       redirect [get_db user_stage_reports_dir]/${stage}_report_clock_gating.rpt { report_clock_gating }
    }

    redirect -var report_clocks { be_short_report_clocks $stage $block }
    
    set clock_status "
    [nice_header "Clocks"] \n-I- Detailed clock_gating report in: [get_db user_stage_reports_dir]/${stage}_report_clock_gating.rpt \n"
    
    if { [regexp "Genus" [get_db program_name]] || [llength [get_db clock_trees]] > 0 } { 
        report_clock_tree_structure -out_file [get_db user_stage_reports_dir]/${stage}_clock_tree_structure.rpt 
        append clock_status "-I- Detailed clock_tree_structure in: [get_db user_stage_reports_dir]/${stage}_clock_tree_structure.rpt "
    }        
    if { ![regexp "Genus" [get_db program_name]] } {
        if { [llength [get_db clock_trees]] > 0 } { 
            report_clock_trees -out_file [get_db user_stage_reports_dir]/${stage}_report_clock_trees.rpt 
            append clock_status "-I- Detailed report_clock_trees in: [get_db user_stage_reports_dir]/${stage}_report_clock_trees.rpt  "            
        }
    }
    
    append clock_status "
    $report_clocks "    

    }
    ##################################  


    ##################################  
    # Cell Count
    if { $all || $count } {
        
    puts "-I- Counting cells [::ory_time::now]"
    
    set cell_count [redirect_and_catch be_count_cells]
    set io_count   [redirect_and_catch be_count_interface]
    
    set cell_count_status "
    [nice_header "Cell Count"] \n$cell_count \n$io_count "

    }
    ##################################  
 
 
    ##################################  
    # Multibit
    if { $all || $mbit } {
        
        puts "-I- Report Multibit [::ory_time::now]"
        set mbit_report [redirect_and_catch be_report_mbit $stage]        
        
        set mbit_status "
        [nice_header "mbit count"] \n$mbit_report"

    }
    ##################################  
    
     
    
    ##################################  
    # Area and Utilization calc
    if { $all || $utilization } {
        
    puts "-I- Calculating area and utilization [::ory_time::now]"
    set area_report [redirect_and_catch be_new_report_util]
    set area_status "
    [nice_header Area] \n$area_report"

    }
    ##################################      


    ##################################  
    # Power data
    if { $all || $power } {
        
    puts "-I- Getting power data [::ory_time::now]"
    set power_report [redirect_and_catch be_short_report_power $block $stage ]    
    set power_status "
    [nice_header "power"]\n$power_report"
    
    }
    ##################################  


    ##################################  
    # Congestion data
    if { $all || $routing } {
        
    puts "-I- Getting congestion data [::ory_time::now]"
 
    # Congestion
    set hs_scr "NA"
    set hs_bbox "NA"   
    set hov "NA"
    set vov "NA"
    set hs_area "NA"
    if { [regexp "Genus" [get_db program_name]] } {    
        redirect -var cong_rpt { report_congestion }
        if { ![regexp "H overflow            : (\[0-9\.\]+%)" $cong_rpt res hov  ]  } { set hov "NA" }
        if { ![regexp "V overflow            : (\[0-9\.\]+%)" $cong_rpt res vov  ]  } { set vov "NA" }
        if { ![regexp "hotspot area = (\[0-9.\]+/\[0-9.\]+)"  $cong_rpt res hs_area]} { set hs_area "NA" }        
    } elseif { [regexp "place|cts" $stage] } {
        redirect -var cong_rpt { report_congestion -overflow -hotspot }
        if { ![regexp "\((\[0-9\.\]+%) H\)" $cong_rpt res hov  ] && $stage != "route" }                     { set hov "NA" } 
        if { ![regexp "\((\[0-9\.\]+%) V\)" $cong_rpt res vov  ] && $stage != "route"  }                    { set vov "NA" }
        if { ![regexp "hotspot area = (\[0-9.\]+/\[0-9.\]+)" $cong_rpt res hs_area] && $stage != "route"  } { set hs_area "NA" }        
        
        set hotspot_file "reports/$block.$stage.hotspot.summary"
        redirect $hotspot_file { puts $cong_rpt }

        set cong_data [split $cong_rpt "\n"]

        set hs_idx [lsearch $cong_data "*hotspot score*"]
	if { $hs_idx > 0 } {
	    set hotspot_line 	[lindex $cong_data [expr 2 + $hs_idx]]
	    if {[regexp {22.1} [get_db program_version]]} {
	    set hs_scr 		[lindex $hotspot_line end-1]
            set hs_bbox		[lrange $hotspot_line end-6 end-3]

	    } else {
		set hs_scr 		[lindex $hotspot_line end-3]
            	set hs_bbox		[lrange $hotspot_line end-6 end-5]

	    }
        }
    }

    set drc_status "NA"
    set shorts "NA"
    if { ![regexp "Genus" [get_db program_name]] } {
        puts "-I- Getting DRC data [::ory_time::now]"
        # Do some check drc stuff
        set drc_status [redirect_and_catch be_short_check_drc $stage $block  ]
        set shorts     [redirect_and_catch be_report_shorts_per_layer ]
    }
    
    set routing_status "
    [nice_header "routing"]
    H overflow            : $hov
    V overflow            : $vov
    Hotspot Area          : $hs_area (area is in unit of 4 std-cell row bins)
    Hotspot Score         : $hs_scr  (worst bbox    $hs_bbox)

    [nice_header "drc"] \n$drc_status
    [nice_header "short_per_layer"] \n$shorts"    
    }
    
    if { $stage == "route" } {
	    set glitches [redirect_and_catch be_report_si_glithces]    
	    append routing_status "[nice_header "si_glitches"] \n$glitches"
    }
    ##################################  


    ##################################  
    # Removed and unclocked sequentials and timing loops
    if { $all || $sequentials } {
    
    puts "-I- Getting removed and unclocked sequentials [::ory_time::now]"
    if { [regexp "Genus" [get_db program_name]] } {        
    set removed_seq_res [redirect_and_catch report_removed_sequentials $stage ]
    set async_report    [redirect_and_catch report_reset_ffs $stage]
    } else {
    set removed_seq_res "NA"
    set async_report "NA"    
    }
    redirect -var unclocked_report { report_unclocked_registers }
    
    set loops_rpt [redirect_and_catch be_report_loop $stage]
    set loops_status "
    [nice_header loops] \n$loops_rpt"

    set removed_status "
    [nice_header removed]\n$removed_seq_res"


    set unclocked_status "
    [nice_header unclocked]\n$unclocked_report"

    set async_status "
    [nice_header async_status] \n$async_report"
    
    }
    ##################################  
    
    ##################################  
    # Report all root attributes
    set res [redirect_and_catch be_report_all_root_attributes $stage]
    ##################################        
        
    ##################################  
    # Run Time, Mem, CPU
    set rt_mem_cpu [be_rt_mem_cpu $stage]
    ##################################  
    

    ##################################  
    # Prints report
    set file_name $output
    if { $output == "" } { set file_name "[get_db user_reports_dir]/${stage}.be.qor" }
    
    puts "-I- Printing QOR report to: $file_name"

    echo $file_header > $file_name
    if { $all || $timing      } { redirect -app $file_name { puts $timing_status     } }
    if { $all || $clocks      } { redirect -app $file_name { puts $clock_status      } }
    if { $all || $count       } { redirect -app $file_name { puts $cell_count_status } }
    if { $all || $mbit        } { redirect -app $file_name { puts $mbit_status       } }    
    if { $all || $utilization } { redirect -app $file_name { puts $area_status       } }
    if { $all || $power       } { redirect -app $file_name { puts $power_status      } }
    if { $all || $routing     } { redirect -app $file_name { puts $routing_status    } }
    if { $all || $sequentials } { redirect -app $file_name { puts $loops_status      } }
    if { $all || $sequentials } { redirect -app $file_name { puts $removed_status    } }
    if { $all || $sequentials } { redirect -app $file_name { puts $unclocked_status  } }
    if { $all || $sequentials } { redirect -app $file_name { puts $async_status      } }    


    
    redirect -app $file_name { puts  $rt_mem_cpu }
    
    if { $output_dir != "" } { set_db user_reports_dir $tmp_out_dir ; set_db user_stage_reports_dir $tmp_out_dir ; }
    
    if { $timing && ![regexp "Genus" [get_db program_name]] && ( $current_effort != $extraction_effort ) } {
        set_db extract_rc_effort_level $current_effort
    }
    
    
    # Add this + mail option be_sum_to_csv
    
    if { $opt(-mail) } {        
        set address [be_get_user_email]
        if { $address != "" } {
            set suser [be_get_supper_user_email]
            foreach sss $suser {
	        set address "$address [be_get_user_email $sss]"
	    }
	    regsub {\s} [lsort -unique $address] "," address
            
            
            
            puts "-I- Mailing the report to: $address"
#            exec cat $file_name | unix2dos | mail -s "BE_FLOW - Stage: $stage - Run: $run - Version: $version" $address
            exec cat $file_name | mail -r BE_Run_Summary@nextsilicon.com -a $file_name -s "BE_FLOW - Stage: $stage - Run: $run - Version: $version" $address
        }            
    }    
}




##################
# Report removed sequentials
##################
proc report_removed_sequentials { stage } {

    set file_name [get_db user_stage_reports_dir]/${stage}_sequential_verbose.rpt
    redirect $file_name {report_sequential }

    set file_name [get_db user_stage_reports_dir]/${stage}_sequential_deleted_verbose.rpt
    redirect $file_name {report_sequential -deleted}

    set file_r [open  $file_name r]

    set is_reason "false"
    set nb_unloaded 0
    set nb_constant_0 0
    set nb_constant_1 0
    set nb_merged 0

    while {![eof $file_r]} {
      set line [gets $file_r]
      if {[regexp {^   Reason} $line]} {
        set is_reason "true"
      }
      if {$is_reason} {
        if {[regexp {^unloaded} $line]} {
          incr nb_unloaded
        }
        if {[regexp {^constant 0} $line]} {
          incr nb_constant_0
        }
        if {[regexp {^constant 1} $line]} {
          incr nb_constant_1
        }
        if {[regexp {^merged} $line]} {
          incr nb_merged
        }
      }
    }
    
    close $file_r
    
    set rpt "-I- Detailed report is in $file_name
report_sequential -deleted summary:
  Sequential element deleted for \"unloaded\" reason:   $nb_unloaded
  Sequential element deleted for \"merged\" reason:     $nb_merged
  Sequential element deleted for \"constant 0\" reason: $nb_constant_0
  Sequential element deleted for \"constant 1\" reason: $nb_constant_1
"

    puts $rpt

}

##################
# Self explenatory
##################
proc report_unclocked_registers { {stage ""} } {


    if { $stage == "" } { set stage [get_db be_stage] }
    set file_name [get_db user_stage_reports_dir]/${stage}_report_unclocked_registers.rpt

    set args       [all_registers -edge_trig]
    set clock_pins [get_pins -quiet -of $args -filter is_clock==true]
    
    set unclocked_pins [get_pins -quiet [get_db $clock_pins -if {.clocks==""}]]

    set floating_pins  {}
    foreach pin [get_db $clock_pins] {
        set afi [all_fanin -to $pin -flat]
        if { [sizeof $afi] == 1 } { lappend floating_pins $pin }      
    }
    set floating_pins [get_pins -quiet $floating_pins]

set file_header "    
============================================================
  Generated by:           [get_db program_name] [get_db program_version]
  Generated on:           [clock format [clock seconds] -format "%b %d %Y   %r"]
  Module:                 [get_db designs .name]
  Operating conditions:   [get_db [get_db analysis_views -if {.is_setup==true}] .name] 
  Operating conditions:   [get_db [get_db analysis_views -if {.is_hold==true}] .name] 
  User:                   $::env(USER)
============================================================
"
    echo $file_header > $file_name
    
    echo "
No clock on pin:" >> $file_name   
    if { [sizeof $unclocked_pins] > 0 } {
    redirect -app $file_name { t $unclocked_pins }
    }

    echo "
  
No driver pins:" >> $file_name       
    if { [sizeof $floating_pins] > 0 } {
    redirect -app $file_name { t $floating_pins }
    }
        
    set rpt "-I- Detailed reports in $file_name
-I- Total of [sizeof $args] registers found
-I- Found [sizeof $unclocked_pins] pins with no clock defined on them
-I- Found [sizeof $floating_pins] clock pins with no clock driver"
    
    puts $rpt   

}

################################################################################
# Unified clock report in Genus and Innovus
################################################################################    
proc be_short_report_clocks { {stage ""} {block ""} } {

    if { $block == "" && [info exists ::env(BLOCK)] } { set block $::env(BLOCK) }
    
        set file_name [get_db user_stage_reports_dir]/${stage}_report_clocks.rpt

        ################################################################################
        # Report clocks in genus is OK but in Innovus we need to do something else
        ################################################################################    

        if { [regexp "Genus" [get_db program_name]] } {

        redirect $file_name  { report_clocks }

        # Parse report clocks
        set fp [open $file_name r]
        set key ""
        array unset clock_report_arr
        set clock_report_arr(clock_desc:header)                           [list "Mode" "Clock Name" "Period" "Pin/Port" "#ofRegisters"]
        set clock_report_arr(clock_late:header) [list "Mode" "Clock Name" "Net Late R" "Net_Late F" "Src Late R" "Src Late F" "Unc R" "Unc F"]   
        set clock_report_arr(clock_desc) ""
        set clock_report_arr(clock_late) "" 

        while {![eof $fp]} {

            set line         [gets $fp]
            if { $line == "" } { continue }
            set nospace_line [string trim [regsub -all  "  +" $line " "] " "]
            set spline       [split $nospace_line " "]

            if { [regexp "Clock Description" $line] } {
                set key "clock_desc"
            } elseif { [regexp "Clock Network Latency" $line] } {
                set key "clock_late"        
            } elseif { [regexp "Clock Relationship" $line] } {
                break
            } elseif { $key != "" && [llength $spline] == 8 && [lindex $spline 0] != "Mode"} {
                if { $key == "clock_desc" } {
                    lassign $spline mode clock_name period rise fall clock_domain pin_port num_of_regs
                    lappend clock_report_arr($key) [list $mode $clock_name $period $pin_port $num_of_regs]
                } else {
                    lassign $spline mode clock_name net_latency_rise net_latency_fall src_latency_rise src_latency_fall setup_unc_rise setup_unc_fall
                    if { [expr $net_latency_rise + $net_latency_fall + $src_latency_rise + $src_latency_fall + $setup_unc_rise + $setup_unc_fall] != 0} { 
                        lappend clock_report_arr($key) [list $mode $clock_name $net_latency_rise $net_latency_fall $src_latency_rise $src_latency_fall $setup_unc_rise $setup_unc_fall] 
                    }
                }
            }
        }
        close $fp

        # Stage report for print
        redirect -var clock_desc_tabel { rls_table -table $clock_report_arr(clock_desc) -header $clock_report_arr(clock_desc:header) -spacious -breaks }
        redirect -var clock_late_tabel { rls_table -table $clock_report_arr(clock_late) -header $clock_report_arr(clock_late:header) -spacious -breaks }

    set rpt "
-I- Detailed report in: $file_name
-I- Clock Description:
$clock_desc_tabel
-I- Clock Network Latency and Setup Uncertainty:
$clock_late_tabel"        
    
    } else {
    ################################################################################
    # For now, it's a very ugly seperation, but we can make it prettier later
    ################################################################################    
        set args   [all_registers -edge]
        set clocks [get_db clocks -if {!.name==*virtual*}]
        
        set table {}
        
        foreach clock [get_db $clocks ] {
            set name        [get_db $clock .base_name]
            redirect /dev/null { 
            set mode        [get_db $clock .view_name] 
            set period      [get_db $clock .period]            
            set waveform    [split [get_db $clock .waveform] " "]
            set sources     [get_db [get_db $clock .sources] .base_name]
            set num_of_regs [sizeof [common_collection [get_cells -of [get_db $clock .clock_network_pins]] [all_registers -edge_triggered ]] ]
            }
            lappend table [list $mode $name $period $sources $num_of_regs]
        }
        
        set header  [list "Mode" "Clock Name" "Period" "Pin/Port" "#ofRegisters"]
        redirect -var clock_desc_tabel { rls_table -table $table -header $header -spacious -breaks }     
        
        set rpt "-I- Clock Description:
$clock_desc_tabel "
        
    }
    
    puts $rpt
}

##################
# Report power + parsing
##################
proc be_short_report_power { {block ""} {stage ""} {file ""} } {

    if { $block == "" && [info exists ::env(BLOCK)] } { set block $::env(BLOCK) }
    
    if {[get_db program_short_name] == "innovus"} {
        set file [get_db user_stage_reports_dir]/power.rpt
    } elseif { $file == "" } {
        set file [get_db user_stage_reports_dir]/${stage}_report.power
        redirect $file { report_power }
    } elseif { ![file exists $file] } {
        puts "-W- File $file not found"
        puts "-W- Running report_power"
        redirect $file { report_power }        
    }

    
    if { [regexp "Genus" [get_db program_name]] } {  
        set units [get_db lp_power_unit]  
        # Leakage Power                   
        set leakage_power "[get_db designs .power_leakage] $units"
        # Dynamic Power                   
        set dynamic_power "[get_db designs .power_dynamic] $units"
        # Total Power                     
        set total_power   "[get_db designs .power_total] $units"
        
	    if { [llength [get_db [get_db insts] .base_cell]] != 0 } {
        	    redirect -var vt_report {be_report_cells_vt}
	    } else {
	            set vt_report ""
	    }
        
        set power_report "Leakage Power: $leakage_power
Dynamic Power: $dynamic_power                 
Total Power:   $total_power"

    } else {
        set units        [lindex [split [exec grep -E "Power Units " $file] " "] end]
        set power_report "Power Units: $units\n[exec grep -E "Total.*Power:" $file]"
		redirect -var vt_report {be_report_cells_vt}          
    }
    
    set rpt "-I- Detailed report in: $file
$power_report

Lib cells VT:
$vt_report"    

    puts $rpt
}

##################
# Get/calc area + util
##################
proc be_new_report_util {} {
    
    if       { [get_db program_short_name] == "innovus" } {
        set is_phys true
        set is_macro_txt "is_macro_cell"
        set phys_cmd     "get_db insts -if {!.is_macro==true && .is_physical==true && .name!=FILL_*}"
        redirect /dev/null { set core_area [format "%.2f" [get_computed_shapes [get_db designs .boundary] -output area]] }
        set x [get_db designs .bbox.ur.x]
        set y [get_db designs .bbox.ur.y]        
    } elseif { [get_db program_short_name] == "genus" } {
        set is_macro_txt "is_macro"
        set phys_cmd     "get_db pcells"
        if { [get_db designs .boundary] != "no_value" } {
            set is_phys true
            redirect /dev/null { set core_area [format "%.2f" [get_computed_shapes [get_db designs .boundary] -output area]] }
            set x [get_db designs .bbox.ur.x]
            set y [get_db designs .bbox.ur.y]        
            
        } else {
            set is_phys false
            set core_area 0
            set x 0
            set y 0
        }
    } 
    
    set all_macros [get_cells -quiet -hier -filter "is_hierarchical == false && $is_macro_txt == true"]
    set all_leafs  [get_cells -quiet -hier -filter "is_hierarchical == false && $is_macro_txt == false"]
    set all_phys   [eval $phys_cmd]
    set all_edge   [all_registers -edge]
    set all_level  [all_registers -level]
    
    # Leaf Instance area
    if { [catch {set leaf_cell_area [lsum [get_db $all_leafs .area ]]} res] } { set leaf_cell_area 0 }
    # Macro Instance area
    set macro_cell_area [lsum [get_db $all_macros .area ]]
    # Physical Instance area   
    if { [get_db program_short_name] == "genus" } {
        set phys_cell_area 0
        foreach pc $all_phys {
            set a [expr [get_db $pc .height]*[get_db $pc .width]]
            set phys_cell_area [expr $phys_cell_area + $a]
        }
    } else {
        set phys_cell_area [lsum [get_db $all_phys .area ]]
    }
    
    # Sequential Instance area    
    if { [catch {if { [sizeof $all_edge]  > 0 } { set flop_cell_area   [lsum [get_db [filter_collection $all_edge  "is_integrated_clock_gating_cell==false"]  .area ]] } { set flop_cell_area 0 }}  res] } { set flop_cell_area  0 }
    if { [catch {if { [sizeof $all_level] > 0 } { set latch_cell_area  [lsum [get_db [filter_collection $all_level "is_integrated_clock_gating_cell==false"]  .area ]] } { set latch_cell_area 0 }} res] } { set latch_cell_area 0 }   
    # Combinational Instance area 
    if { [catch { set comb_cell_area [lsum [get_db [get_cells -quiet -hier -filter "is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false"] .area ]] } res] } { set comb_cell_area 0 }
    # Buffer Instance area 
    if { [catch { set buff_cell_area [lsum [get_db [get_cells -quiet -hier -filter "is_hierarchical == false && is_buffer==true"] .area ]] } res] } { set buff_cell_area 0 }
    # Inverter Instance area 
    if { [catch { set inv_cell_area  [lsum [get_db [get_cells -quiet -hier -filter "is_hierarchical == false && is_inverter==true"] .area ]] } res] } { set inv_cell_area 0 }
    # ICG Instance area 
    if { [catch { set icg_cell_area  [lsum [get_db  [get_cells -quiet -hier -filter  "is_hierarchical == false && is_integrated_clock_gating_cell==true"] .area ]] } res] } { set icg_cell_area 0 }
    
    set total_std_area [expr $leaf_cell_area + $phys_cell_area]
    
    if { $is_phys } {
    set pb_soft      [get_db [get_db place_blockages -if {.type == soft }] .rects]
    set pb_hard      [get_db [get_db place_blockages -if {.type == hard }] .rects]
    set macro_rects  [get_db $all_macros .bbox]
    redirect /dev/null { set pb_soft_area [get_computed_shapes $pb_soft OR $pb_soft ANDNOT $macro_rects -output area] }
    redirect /dev/null { set pb_hard_area [get_computed_shapes $pb_hard OR $pb_hard ANDNOT $macro_rects -output area] }  
    redirect /dev/null { set pb_net_area  [get_computed_shapes $pb_soft OR $pb_hard ANDNOT $macro_rects -output area] }
    } else {
        set pb_soft_area 0
        set pb_hard_area 0
        set pb_net_area  0
    }
    array set report_area_arr   [list leaf_cell_area $leaf_cell_area macro_cell_area $macro_cell_area phys_cell_area $phys_cell_area \
                                 flop_cell_area $flop_cell_area comb_cell_area  $comb_cell_area  buff_cell_area $buff_cell_area \
                                 inv_cell_area  $inv_cell_area  icg_cell_area   $icg_cell_area latch_cell_area $latch_cell_area \
                                 soft_blkg_area $pb_soft_area   hard_blkg_area  $pb_hard_area  total_blkg_area $pb_net_area] 
    
#    parray report_area_arr
    
    if { [info exists core_area] && $core_area > 0 } {
        
        #% Pure Gate Density #1 (Subtracting BLOCKAGES): 20.115%
        set pure_gate_density_1 [format "%.2f" [expr 100*$total_std_area/($core_area - $pb_net_area)]]  
        #% Pure Gate Density #2 (Subtracting BLOCKAGES and Physical Cells): 4.480%  
        set pure_gate_density_2 [format "%.2f" [expr 100*$leaf_cell_area/($core_area - $pb_net_area)]]          
        #% Pure Gate Density #3 (Subtracting MACROS): 20.115%  
        set pure_gate_density_3 [format "%.2f" [expr 100*$total_std_area/($core_area - $macro_cell_area)]]                  
        #% Pure Gate Density #4 (Subtracting MACROS and Physical Cells): 4.480% 
        set pure_gate_density_4 [format "%.2f" [expr 100*$leaf_cell_area/($core_area - $macro_cell_area)]]                  
        #% Pure Gate Density #5 (Subtracting MACROS and BLOCKAGES): 20.115%  
        set pure_gate_density_5 [format "%.2f" [expr 100*$total_std_area/($core_area - $macro_cell_area - $pb_net_area)]]                  
        set pure_gate_density_6 [format "%.2f" [expr 100*$leaf_cell_area/($core_area - $macro_cell_area - $pb_net_area)]]                          
        #% Pure Gate Density #6 ((Unpreplaced Standard Inst + Unpreplaced Block Inst + Unpreplaced Black Blob Inst + Fixed Clock Inst Area) / (Free Site Area + Fixed Clock Inst Area) for insts are placed): 4.899%  
        # ???
        #% Core Density (Counting Std Cells and MACROs): 20.115%  
        set core_dens_1 [format "%.2f" [expr 100*($total_std_area+$macro_cell_area)/($core_area)]]                  
        #% Core Density #2(Subtracting Physical Cells): 4.480%  
        set core_dens_2 [format "%.2f" [expr 100*($leaf_cell_area+$macro_cell_area)/($core_area)]]                          
        #% Chip Density (Counting Std Cells and MACROs and IOs): 20.115%  
        #% Chip Density #2(Subtracting Physical Cells): 4.480%  
        
    } else {
        set pure_gate_density_1 "NA"
        set pure_gate_density_2 "NA"
        set pure_gate_density_3 "NA"
        set pure_gate_density_4 "NA"
        set pure_gate_density_5 "NA"         
        set pure_gate_density_6 "NA"                 
        set core_dens_1 "NA"
        set core_dens_2 "NA"
        set core_area   "NA"
        set x "NA"
        set y "NA"
    }
    
    puts -nonewline "-I- Area \[um^2\]:"
    puts "
Leaf Cell Area:          [format "%.2f" $leaf_cell_area] ; # Leaf (no physical cells area)
Physical Cell Area:      [format "%.2f" $phys_cell_area] ; # Without FILLER cells (FILL_*)
Flop Cell Area:          [format "%.2f" $flop_cell_area] 
Latch Cell Area:         [format "%.2f" $latch_cell_area] 
Combinational Cell Area: [format "%.2f" $comb_cell_area] 
Buffer Cell Area:        [format "%.2f" $buff_cell_area] 
Inverter Cell Area:      [format "%.2f" $inv_cell_area] 
Clock Gate Cell Area:    [format "%.2f" $icg_cell_area] 
Macro Cell Area:         [format "%.2f" $macro_cell_area] 
Hard Blockage Area:      [format "%.2f" $pb_hard_area] 
Soft Blockage Area:      [format "%.2f" $pb_soft_area] 
Effective Blockage Area: [format "%.2f" $pb_net_area] ; # Soft and Hard blockages area w.o. overlap
Core Area:               $core_area
X:                       $x
Y:                       $y


Pure STD Cell Density:        [format "%-8s"  $pure_gate_density_4%] ; # Leaf_cell_area / (Core_area - Macro_area) AKA BRCM STYLE
Effective Density:            [format "%-8s"  $pure_gate_density_6%] ; # Leaf_cell_area / (Core_area - Macro_area - Effective_blockages_area)
Effective include Phys cells: [format "%-8s"  $pure_gate_density_5%] ; # (Leaf_cell_area + Phys_cell_area) / (Core_area - Macro_area)
"
    
    return [array get report_area_arr]
    
}
proc be_short_report_utilization { {stage ""} {block ""} {file ""} } {

    if { $block == "" && [info exists ::env(BLOCK)] } { set block $::env(BLOCK) }
    
    if { [regexp "Genus" [get_db program_name]] && [expr [llength [get_db insts -if {.area==no_value}]] / (1.0*[llength [get_db insts]]) ] > 0.2 } {
        puts "-W- Too many cells have no area"
        return
    }
    

    
    if { [get_db program_short_name] == "genus" } {
 
        # Leaf Instance Area
        set leaf_cell_Area [lsum [get_db [get_cells -hier -filter "is_hierarchical == false && is_macro == false"] .area ]]
        # Macro Instance Area
        set macro_cell_Area [lsum [get_db [get_cells -hier -filter "is_hierarchical == false && is_macro == true"] .area ]]
        
        # Physical Instance Area  
        set phys_cells [get_db pcells] 
        set phys_cell_Area 0
        foreach pc $phys_cells {
            set a [expr [get_db $pc .height]*[get_db $pc .width]]
            set phys_cell_Area [expr $phys_cell_Area + $a]
        }
 
    } else {    

        # Leaf Instance Area
        set leaf_cell_Area [lsum [get_db [get_cells -hier -filter "is_hierarchical == false && is_macro_cell == false"] .area ]]
        # Macro Instance Area
        set macro_cell_Area [lsum [get_db [get_cells -hier -filter "is_hierarchical == false && is_macro_cell == true"] .area ]]
        # Physical Instance Area   
        set phys_cell_Area [lsum [get_db [get_db insts -if {!.is_macro==true && .is_physical==true}] .area ]]
        
    }
    # Sequential Instance Area    
    set all_edge [all_registers -edge]
    if { [sizeof $all_edge] > 0 } { set seq_cell_Area  [lsum [get_db [filter_collection $all_edge "is_integrated_clock_gating_cell==false"]  .area ]] } { set seq_cell_Area 0 }
    # Combinational Instance Area 
    set comb_cell_Area [lsum [get_db [get_cells -quiet -hier -filter "is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false"] .area ]]
    # Buffer Instance Area 
    set buff_cell_Area [lsum [get_db [get_cells -quiet -hier -filter "is_hierarchical == false && is_buffer==true"] .area ]]    
    # Inverter Instance Area 
    set inv_cell_Area  [lsum [get_db [get_cells -quiet -hier -filter "is_hierarchical == false && is_inverter==true"] .area ]]    
    # ICG Instance Area 
    set icg_cell_Area  [lsum [get_db  [get_cells -quiet -hier -filter  "is_hierarchical == false && is_integrated_clock_gating_cell==true"] .area ]]    

    # Net Area        
    if { [regexp "Genus" [get_db program_name]] } {
        set net_area       [format "%.2f" [get_db designs .net_area]]
    } else {
        set net_area "N\A"
    }
    
    # Utilization
    set bbox [list 0 0 0 0]
    if { [regexp "Genus" [get_db program_name]] } {    
        # Detailed report
        set file_name [get_db user_stage_reports_dir]/${stage}_report.area
        redirect $file_name { report_area }
        # Die area
        set die_area      [get_db designs .die_area]
        # BBox
        set bbox [split [string map {"{" "" "}" ""} [get_db designs .bbox]] " "]

    } else {
        if { $file != "" && [file exists $file] } {
        set file_name $file
        } else {
        set file_name [get_db user_stage_reports_dir]/${stage}_summary_report.rpt    
        redirect /dev/null { report_summary -no_html -out_file $file_name }
        }
#        set res [exec grep -E "Total area\|Pure Gate Density\|Core Density\|Chip Density" [get_db user_stage_reports_dir]/${stage}_summary_report.rpt]            
        set res      [exec grep -E "Total area of Core:" $file_name]            
        set die_area [lindex [split $res " "] 4]
        
        set res      [exec grep -E "Core Density .Counting Std Cells and MACROs." $file_name]    
        set utilization [string trim [lindex [split $res " "] 8] "%"]
        
        # BBox
        set bbox [split [string map {"{" "" "}" ""} [get_db designs .io_bbox]] " "]        
    }
    
    lassign $bbox xl yl xh yh
    set dx 0
    set dy 0
    if { $xh > 0 } { set dx [expr $xh - $xl] }
    if { $yh > 0 } { set dy [expr $yh - $yl] }           
    
    # Effective utilization
    set pb_rects [get_db [get_db place_blockages -if {.type == hard }] .rects]
    set pb_rects_area 0
    foreach rect $pb_rects {
        lassign $rect xl yl xh yh
        set pb_rects_area [expr $pb_rects_area + ($yh - $yl)*($xh - $xl) ]
    }
    set eff_util      [expr 100 * ($leaf_cell_Area + $phys_cell_Area)/( $die_area - $pb_rects_area - $macro_cell_Area )]
    set eff_no_phy    [expr 100 * ($leaf_cell_Area)/( $die_area - $pb_rects_area - $macro_cell_Area )]
    
    
    if { [regexp "Genus" [get_db program_name]] } {    
        # Utilization
        set utilization   [expr 100 * ($leaf_cell_Area + $phys_cell_Area + $macro_cell_Area)/($die_area - $pb_rects_area)]
    }
    
    
    set rpt "
-I- Detailed report in: $file_name
-I- Area:
Leaf Cell Area:          [format %.2f $leaf_cell_Area]
Physical Cell Area:      [format %.2f $phys_cell_Area ]
Sequential Cell Area:    [format %.2f $seq_cell_Area  ]
Combinational Cell Area: [format %.2f $comb_cell_Area ]
Buffer Cell Area:        [format %.2f $buff_cell_Area ]
Inverter Cell Area:      [format %.2f $inv_cell_Area ]
Clock Gate Cell Area:    [format %.2f $icg_cell_Area  ]
Macro Cell Area:         [format %.2f $macro_cell_Area ]
Net Area:                $net_area

-I- Utilization:
Hard Blockage Area:                           [format %.2f $pb_rects_area]
Die Area:                                     [format %.2f $die_area     ]
X:                                            [format %.2f $dx     ]
Y:                                            [format %.2f $dy     ]
Utilization:                                  [format %.2f $utilization  ]%
Effective Utilization:                        [format %.2f $eff_util     ]%
Effective Utilization (No physical cells) :   [format %.2f $eff_no_phy   ]%
* Effective utilization                     = Total Cell Area    / (Die Area - Macro Cell Area - Hard Blckage Area)
* Effective utilization (No physical cells) = Standard Cell Area / (Die Area - Macro Cell Area - Hard Blckage Area)"

    puts $rpt
    
}

##################
# Count different type of cells
##################
proc be_count_cells { {stage ""} } {
    set stt [clock seconds]
    puts "-I-  be_count_cells at: [clock format $stt -format "%d/%m/%y %H:%M:%S"]"

    if { [info exists ::STAGE] && $stage == "" } { set stage $::STAGE }

    if       { [get_db program_short_name] == "innovus" } {
        set is_phys true
        set is_macro_txt "is_macro_cell"
        set phys_cmd     "get_db insts -if {!.is_macro==true && .is_physical==true && .name!=FILL_*}"
    } elseif { [get_db program_short_name] == "genus" } {
        set is_macro_txt "is_macro"
        set phys_cmd     "get_db pcells"
    } 

    
    set all_edge  [all_registers -edge]
    set all_level [all_registers -level_sensitive]
    set all_macros [get_cells -quiet -hier -filter "is_hierarchical == false && $is_macro_txt == true"]
    set macro_cell_count [sizeof $all_macros]
    
    if { [get_db program_short_name] == "genus" } {
        # Leaf Instance count
        set leaf_cell_count [sizeof [get_cells -hier -filter "is_hierarchical == false && is_macro == false"]]
        # Physical Instance count      
        set phys_cell_count [llength [get_db pcells]]
        # Sequential Instance Count    
        if { [sizeof $all_edge] > 0 } { set seq_cell_count  [sizeof  [filter_collection $all_edge  "is_integrated_clock_gating_cell==false"]] } { set seq_cell_count 0 }
        # Latch Instance Count    
        if { [sizeof $all_level] > 0 } { set latch_cell_count [llength [get_db $all_level -if .base_cell.is_integrated_clock_gating=="false"]] } { set latch_cell_count 0 }
        # Combinational Instance Count 
        set comb_cell_count  [sizeof [get_cells -hier -filter "is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false"]]
        # Buffer Instance Area 
        set buff_cell_count  [sizeof [get_cells -hier -filter "is_hierarchical == false && is_buffer==true "]]
        # Inverter Instance Area 
        set inv_cell_count   [sizeof [get_cells -hier -filter "is_hierarchical == false && is_inverter==true "]]

        # Clock Tree Instance Count 
        if { [sizeof $all_edge] > 0 } {
            set clock_sources [get_db [get_clocks ] .sources]
            if { $clock_sources == "" } {
                puts "-W- No clock sources found"
                set all_clock_cells {}
            } else {
                set all_clock_cells [remove_from_collection [all_fanout -flat -from $clock_sources -only] [filter_collection $all_edge is_integrated_clock_gating_cell!=true]]            
            }
        } else {
             puts "Warning: no registers in the design"
#            set all_clock_cells [get_clock_network_objects -clocks grid_clk -type cell]
             set all_clock_cells ""
        }
        if { $all_clock_cells != {} } {
            set icg_cell_count  [sizeof [filter_collection $all_clock_cells " is_integrated_clock_gating_cell==true "]]
            set clock_inv       [sizeof [filter_collection $all_clock_cells " is_inverter==true "]]
            set clock_buf       [sizeof [filter_collection $all_clock_cells " is_buffer==true "]]
            set clock_logic     [sizeof [filter_collection $all_clock_cells " is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false "]]
        } else {
            set icg_cell_count 0
            set clock_inv      0
            set clock_buf      0
            set clock_logic    0
        }

       # Hierarchical Instance Count  
        set hier_cell_count [llength [get_db hinsts ]]        
    } else {
        # Leaf Instance count
        set leaf_cell_count [sizeof [get_cells -hier -filter "is_hierarchical == false && is_macro_cell == false"]]
        # Physical Instance count      
        set phys_cell_count [llength [get_db insts -if {!.is_macro==true && .is_physical==true}]]
        # Sequential Instance Count    
        if { [sizeof $all_edge] > 0 } { set seq_cell_count  [sizeof  [filter_collection $all_edge  "is_integrated_clock_gating_cell==false"]] } { set seq_cell_count 0 }
        # Latch Instance Count    
        set latch_cell_count [llength [get_db $all_level -if .base_cell.is_integrated_clock_gating=="false"]]
        # Combinational Instance Count 
        set comb_cell_count  [sizeof [get_cells -hier -filter "is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false"]]
        # Buffer Instance Area 
        set buff_cell_count  [sizeof [get_cells -hier -filter "is_hierarchical == false && is_buffer==true "]]
        # Inverter Instance Area 
        set inv_cell_count   [sizeof [get_cells -hier -filter "is_hierarchical == false && is_inverter==true "]]
        
        # Clock Tree Instance Count 
        if { [sizeof $all_edge] > 0 } {
            set all_clock_cells [remove_from_collection [get_clock_network_objects -clocks [get_clocks]  -type cell] [filter_collection $all_edge is_integrated_clock_gating_cell!=true]]
        } else {
             puts "Warning: no registers in the design"
#            set all_clock_cells [get_clock_network_objects -clocks grid_clk -type cell]
             set all_clock_cells ""
        }
        if { $all_clock_cells != {} } {
            set icg_cell_count  [sizeof [filter_collection $all_clock_cells " is_integrated_clock_gating_cell==true "]]
            set clock_inv       [sizeof [filter_collection $all_clock_cells " is_inverter==true "]]
            set clock_buf       [sizeof [filter_collection $all_clock_cells " is_buffer==true "]]
            set clock_logic     [sizeof [filter_collection $all_clock_cells " is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false "]]
        } else {
            set icg_cell_count 0
            set clock_inv      0
            set clock_buf      0
            set clock_logic    0
        }

        # Hierarchical Instance Count  
        set hier_cell_count [llength [get_db hinsts ]]    
    }

    # IO count
    set ports_count [sizeof [get_ports]]    
    
    # bit Count  
    if { [get_db program_short_name] == "genus" } {
        
        redirect -var rpt_mbit            { report_multibit_inferencing }

        if { ![regexp "No Sequential Instance got merged to multibit" $rpt_mbit res] } {
            set m2 0 ; set m4 0 ; set m6 0 ; set m8 0 
            regexp "Single-bit flip-flop +(\[0-9\]+)" $rpt_mbit res single
            regexp "Multi-bit flip-flop +(\[0-9\]+) +(\[0-9.\]+)" $rpt_mbit res multi bank_ratio
            regexp "2\-bit +(\[0-9\]+)" $rpt_mbit res m2
            regexp "4\-bit +(\[0-9\]+)" $rpt_mbit res m4
            regexp "6\-bit +(\[0-9\]+)" $rpt_mbit res m6                                        
            regexp "8\-bit +(\[0-9\]+)" $rpt_mbit res m8 

            set bit_count [expr $m2*2 + $m4*4 + $m6*6 + $m8*8 + $single]
        } else {
            set bit_count       [llength  [get_db [all_registers -edge -out] -if !.inst.base_cell.is_integrated_clock_gating==true]]
        }
        
    } else {
        redirect -var rpt_mbit  { report_multi_bit_ffs -stat }
     	#redirect -var rpt_mbit  { report_multibit }
        if { ![regexp "Total Bit Count +: +(\[\\\-_a-zA-Z0-9\\\.\]+)"     $rpt_mbit res bit_count  ] } { set bit_count NA }       
    }

    set rpt "Leaf Cell Count:          $leaf_cell_count 
Physical Cell Count:      $phys_cell_count 
Sequential Cell Count:    $seq_cell_count  
FF Bit Count:             $bit_count        
Latch Cell Count:         $latch_cell_count
Combinational Cell Count: [expr $comb_cell_count - [expr {$clock_logic eq "NA" ? 0 : $clock_logic}]]
Buffer Cell Count:        [expr $buff_cell_count - [expr {$clock_buf   eq "NA" ? 0 : $clock_buf}]]
Inverter Cell Count:      [expr $inv_cell_count  - [expr {$clock_inv   eq "NA" ? 0 : $clock_inv}]]
ICG Count:                $icg_cell_count  
Clock inverters:          $clock_inv
Clock Buffers:            $clock_buf
Clock Logic:              $clock_logic
Hierarchical Cell Count:  $hier_cell_count 
Port Count:               $ports_count"

    puts $rpt
set ett [clock seconds]
puts "-I- End running be_count_cells at: [clock format $ett -format "%d/%m/%y %H:%M:%S"]"
puts "-I- Elapse time is [expr ($ett - $stt)/60/60/24] days , [clock format [expr $ett - $stt] -timezone UTC -format %T]"
}

##################
# Count IOs
##################
proc be_count_interface { } {

    set all_in  [sizeof [all_inputs]]
    set all_out [sizeof [all_outputs]]
    
    set rpt "Inputs:   $all_in
Outputs:  $all_out
Total IO: [expr $all_in + $all_out]"

}

##################
# Parsing report_timing_summary
##################
proc be_short_report_timing_summary { {stage ""} {block ""} } {

    if { $block == "" && [info exists ::env(BLOCK)] } { set block $::env(BLOCK) }
    set time_factor 1.0 
    if { [get_db program_short_name] == "innovus" } {
        set time_unit [get_time_unit]
        if { [regexp "ns" $time_unit res] } { set time_factor 1000.0 } else { set time_factor 1.0 }
    }

    # enable setup + hold timing summary
    # TM - remove this section since we do parsing on time_design
    #set mode_list "setup"
    #if { ([get_db program_short_name] != "genus")&&(![regexp "floorplan|place" $stage]) } {
    #  lappend mode_list "hold"
    #  set prev_state [get_db timing_enable_simultaneous_setup_hold_mode]
    #  set_db timing_enable_simultaneous_setup_hold_mode true
    #}

    # save timing_summary to variable and to report as backup/debug    
    if { [get_db program_short_name] == "genus"} {
       set mode_list "setup"
       redirect -var timing_summary { report_timing_summary }
       redirect reports/$stage.timing_summary.rpt { puts $timing_summary }

      # restore simultaneous setup hold mode
      #if { [regexp "hold" $mode_list"] } {
      #  set_db timing_enable_simultaneous_setup_hold_mode $prev_state
      #}

       set trimmed_rpt [split [regsub -all  "  +" $timing_summary " "] "\n"]

       # Searching for section indexes from timing_summary
       set section_idx [lsort -int -increasing [lsearch -all $trimmed_rpt "*WNS TNS FEP*"]]

       set output_res ""

       foreach tim_mode $mode_list {
           unset -nocomplain wns
           # finding the start of setup/hold timing section
           set tim_idx [lsearch $trimmed_rpt "*[string toupper $tim_mode]*WNS TNS FEP*"]
           if { $tim_idx < 0 } { continue }
           # finding the end of setup/hold timing section
           set tim_end [lindex $section_idx [expr 1 + [lsearch $section_idx $tim_idx]]]
           if { ![llength $tim_end] } { set tim_end "end" }
           # finding the total summary line for the stage
           set tim_sum_line [lsearch -inline [lrange $trimmed_rpt $tim_idx $tim_end] "*View*: ALL*"]
           # taking wns tns and fep from summary line
           lassign [lrange $tim_sum_line end-2 end] wns tns fep
        
           if { ![string length $wns] } { 
               append output_res "-W- No negative $mode paths found\n" 
           } else {
               append output_res "[string toupper $tim_mode] TIMING:\n"
               set timing_table {}
               # searching for timig_group data
               foreach line [lsearch -all -inline [lrange $trimmed_rpt $tim_idx $tim_end] "*Group : *"] {
                   if {$line == ""} { continue }
                   set line [regsub -all "N/A" $line "0.000"]       
                   set group_name [lindex $line 2] 
                   lassign [lrange $line end-2 end] group_wns group_tns group_fep
                   lappend timing_table [list $group_name [expr $time_factor*$group_wns] [expr $time_factor*$group_tns] $group_fep]
               }
               set timing_table [lsort -index 2 -real -decre $timing_table ]
               lappend timing_table [list "" "" "" ""]
               lappend timing_table [list All [expr $time_factor*$wns] [expr $time_factor*$tns] $fep]

               set timing_format [list "%s" "%10s" "%12s" "%10s"]
               set timing_header [list "Group" "WNS(ps)" "TNS(ps)" "FEP"]
            
               redirect -append -var output_res {rls_table -format $timing_format -header $timing_header -table $timing_table -spacious -breaks}
               append output_res "\n"
               #lappend output_res $table_res
           }
       }
    } else {
    # innovus
       set output_res ""
       foreach tim_mode [list "setup" "hold"] {
           if { $stage == "route" } {
               if {$tim_mode == "setup"} {
                   set timing_table [read_time_design_rpt [get_db user_stage_reports_dir]/${block}.summary.gz]
               } else {
                   set timing_table [read_time_design_rpt [get_db user_stage_reports_dir]/${block}_hold.summary.gz]
               }
           } elseif { $stage == "cts_only" } {
               if {$tim_mode == "setup"} {
                   set timing_table [read_time_design_rpt reports/cts/${stage}/${stage}.summary.gz]
               } else {
                   set timing_table [read_time_design_rpt reports/cts/${stage}/${stage}_hold.summary.gz]
               }
           } elseif { $stage == "place" } {
               if {$tim_mode == "setup"} {
	           if {[file exists reports/${stage}/${stage}.summary.gz]}  {set timing_table [read_time_design_rpt reports/${stage}/${stage}.summary.gz]}
 	           if {[file exists reports/${stage}/${stage}.summary]}  {set timing_table [read_time_design_rpt reports/${stage}/${stage}.summary]}
		   if {![info exists timing_table]} {continue}
              } else {
                   continue
               }
           } else {
               if {$tim_mode == "setup"} {
                   set timing_table [read_time_design_rpt reports/${stage}/${stage}.summary.gz]
               } else {
                   set timing_table [read_time_design_rpt reports/${stage}/${stage}_hold.summary.gz]
               }
           }
           
	 # handeling N/A in timing summary, replacing simple numerical sort 
	   #set timing_table [lsort -index 2 -real -decre $timing_table]
	   set timing_table [regsub -all " N/A N/A N/A" $timing_table "__REGSUB__ -999 -999 -999"]
	   set timing_table [lsort -index 2 -real -decre $timing_table]
	   set timing_table [regsub -all "__REGSUB__ -999 -999 -999" $timing_table " N/A N/A N/A"]	           

	   lappend timing_table [list "" "" "" ""]
           if {[lindex [lindex $timing_table [lsearch -regex $timing_table "all"]] 1] >= 0} {
               append output_res "-W- No negative $tim_mode paths found\n"
           } else {
               append output_res "[string toupper $tim_mode] TIMING:\n"
           }
           set timing_format [list "%s" "%10s" "%12s" "%10s"]
           set timing_header [list "Group" "WNS(ps)" "TNS(ps)" "FEP"]
           redirect -append -var output_res {rls_table -format $timing_format -header $timing_header -table $timing_table -spacious -breaks}
           append output_res "\n"
       }
    }
    puts $output_res
}

##################
# Run and parse check_drc
##################
proc be_short_check_drc { {stage ""} {block ""} } {

    if { $block == "" && [info exists ::env(BLOCK)] } { set block $::env(BLOCK) }

    set file_name [get_db user_stage_reports_dir]/${stage}_check_drc.rpt
    
    set cmd "check_drc -out_file $file_name -limit 100000 -layer_range \[list M[expr max(1,[get_db route_design_bottom_routing_layer] - 1)] M[expr [get_db route_design_top_routing_layer] -1 ]\]"
    set check_drc_failed false
    
    puts "-I- Running $cmd"
    redirect -var cmd_res { if { [catch {eval $cmd} res] } { set check_drc_failed true } }

    if { $check_drc_failed } {
        puts $cmd_res
        return ""
    } 
    
    set fp [open $file_name r]
    set longest_name [string length "TOTAL DRC"]
    array unset drc_arr
    while {![eof $fp]} {

        set line         [gets $fp]
        if { $line == "" || [regexp "Bound" $line res] } { continue }

        if { [regexp "(^\[a-zA-Z\]+): \\( (\[a-zA-Z \]+) \\)\|^( )\\\( (\[a-zA-Z \]+) \\\) " $line res category violation c2 v2 ] } {
        
            if { $category == "" && $v2 != "" } {  set category "Other" ; set violation $v2 }
        
            lappend drc_arr($category:$violation) $violation
            if { [set name_length [string length "$category:$violation"]] > $longest_name } { set longest_name [string length "$category:$violation"] }        
        }
    }
    close $fp
    
    set total_drc 0
    set rpt "-I- $cmd \n"
    foreach category [lsort [array names drc_arr]] {
        append rpt "[format %-${longest_name}s $category]: [llength $drc_arr($category)]\n"
        set total_drc [expr $total_drc + [llength $drc_arr($category)]]
    }
    append rpt "[format %-${longest_name}s "TOTAL DRC"]: $total_drc"
    
    puts $rpt
}

##################
# Generate detailed timing reports
##################
proc be_generate_timing_reports { stage {num_of_paths 2000} } {

    if { [regexp "Genus" [get_db program_name]] } {
        report_timing -max_paths $num_of_paths                                           > [get_db user_stage_reports_dir]/${stage}.rpt
        report_timing -max_paths $num_of_paths -from [all_registers] -to [all_registers] > [get_db user_stage_reports_dir]/${stage}.rpt.reg2reg
        report_timing -max_paths $num_of_paths -from [all_registers] -to [all_outputs]   > [get_db user_stage_reports_dir]/${stage}.rpt.reg2out
        report_timing -max_paths $num_of_paths -from [all_inputs]    -to [all_registers] > [get_db user_stage_reports_dir]/${stage}.rpt.in2reg
        report_timing -max_paths $num_of_paths -from [all_inputs]    -to [all_outputs]   > [get_db user_stage_reports_dir]/${stage}.rpt.in2out
    #} else {
       # TM - remove this section since we have time_design before every be_reports
        #time_design       -report_only -expanded_views -report_dir [get_db user_stage_reports_dir] -num_paths $num_of_paths -report_prefix $stage
        #if { [llength [get_db [get_clocks]  .is_propagated true]] > 0 } {
        #time_design -hold -report_only -expanded_views -report_dir [get_db user_stage_reports_dir] -num_paths $num_of_paths -report_prefix $stage        
        #}
    }    
    
}



proc be_count_base_cells { } {

    if { [llength [get_db attributes *is_hdh] ] == 0 } {
        define_attribute -category be_user_attributes -obj_type base_cell -data_type int     -default 0         insts_count
        define_attribute -category be_user_attributes -obj_type base_cell -data_type double  -default 0         avg_load        
        define_attribute -category be_user_attributes -obj_type base_cell -data_type bool    -default false     is_hdh
        define_attribute -category be_user_attributes -obj_type base_cell -data_type double  -default 0	        avg_total_power        
        define_attribute -category be_user_attributes -obj_type base_cell -data_type double  -default 0	        avg_leakage_power        
        define_attribute -category be_user_attributes -obj_type base_cell -data_type double  -default 0	        avg_internal_power        
        define_attribute -category be_user_attributes -obj_type base_cell -data_type double  -default 0	        avg_switching_power                            
        define_attribute -category be_user_attributes -obj_type base_cell -data_type double  -default 0	        avg_dynamic_power                                    
        define_attribute -category be_user_attributes -obj_type base_cell -data_type string  -default "other"   be_cell_group
    }

    set hpc_libs         [get_db lib_cells *hdh*]
    set hpc_base_cells   [lsort -u [get_db $hpc_libs .base_cell.name]]
    set_db -quiet [get_db $hpc_libs .base_cell] .is_hdh true

    set base_cells [get_db base_cells .name]

    array unset cells_arr 
    set total   [llength $base_cells]
    set current 0
    foreach bc $base_cells {

        ory_progress $current $total
        incr current
        
        set cells        [get_db insts -if {.base_cell.name==$bc}]
        set num_of_cells [llength $cells]
       
        if { $num_of_cells > 0 } {
            set cells_arr($bc) $num_of_cells
            set_db -quiet [get_db base_cells $bc] .insts_count $num_of_cells
            
            set total_power [lsum [get_db $cells .power_total]    ]
            set total_dyn   [lsum [get_db $cells .power_dynamic]  ]
            set total_int   [lsum [get_db $cells .power_internal] ]
            set total_swi   [lsum [get_db $cells .power_switching]]        
            set total_lkg   [lsum [get_db $cells .power_leakage]  ]

            set avg_power   [expr $total_power / $num_of_cells ]
            set avg_dyn     [expr $total_dyn / $num_of_cells ]
            set avg_int     [expr $total_int / $num_of_cells ]
            set avg_swi     [expr $total_swi / $num_of_cells ]
            set avg_lkg     [expr $total_lkg / $num_of_cells ]

            set_db -quiet [get_db base_cells $bc] .avg_total_power      $avg_power
            set_db -quiet [get_db base_cells $bc] .avg_leakage_power    $avg_lkg  
            set_db -quiet [get_db base_cells $bc] .avg_internal_power   $avg_int  
            set_db -quiet [get_db base_cells $bc] .avg_switching_power  $avg_swi  
            set_db -quiet [get_db base_cells $bc] .avg_dynamic_power    $avg_dyn  

            
            set out_pins   [get_db [get_db $cells .pins] -if {.direction==out}]
            set nets       [get_nets -quiet -of $out_pins]
            if { [sizeof $nets] == 0 } { 
            set avg_load -1
            } else {
            set loads      [get_db $nets .num_loads]
            set total_load [lsum $loads]
            set avg_load   [format "%.1f" [expr 1.0*$total_load/[llength $out_pins]]]
            }
            set_db -quiet [get_db base_cells $bc] .avg_load $avg_load
        }

    }
    puts ""

}


::parseOpt::cmdSpec be_base_cells_info {
    -help "Prints some info on base cells"
    -opt {
        {-optname pattern      -type string  -default ""      -required 0 -help "Pattern of lib_cells you wish to print"}
        {-optname exclude      -type string  -default ""      -required 0 -help "Pattern of lib_cells you DO NOT wish to print"}        
        {-optname detailed     -type boolean -default false   -required 0 -help "Print even more info"}
        {-optname sort_by      -type integer -default 0       -required 0 -help "Sort table by: 0. name, 1. insst_count, 2. area, 3. max_cap"}        
        {-optname threshold    -type integer -default 0       -required 0 -help "base_cells with at least this much instances"} 
        {-optname min_area     -type float   -default -1      -required 0 -help "base_cells with at least this much area"}         
        {-optname csv          -type string  -default ""      -required 0 -help "Export table to csv"}        
    }
}

proc be_base_cells_info { args } {

    if { ! [::parseOpt::parseOpt be_base_cells_info $args] } { return 0 }    

    set pattern  $opt(-pattern)
    set exclude  $opt(-exclude)    
    set detailed $opt(-detailed)
    set sort_by  $opt(-sort_by)
    set threshold  $opt(-threshold)   
    set min_area $opt(-min_area) 

    if { $pattern == "" } {
        set lib_cells  [get_lib_cells *]
        set base_cells [get_db base_cells -if { .insts_count>$threshold && .area > $min_area } ]
    } else {
        set lib_cells    [get_lib_cells $pattern]
        set base_cells   [get_db [get_db $lib_cells .base_cell] -if { .insts_count>$threshold  && .area > $min_area } ]
    }
    
    if { $exclude != "" } {
        set lib_cells    [get_db $lib_cells -if !.name==$exclude]
        set base_cells   [get_db [get_db $lib_cells .base_cell] -if { .insts_count>$threshold  && .area > $min_area } ]        
    }
    
    
    ###########################################################################
    # Determine VT groups
    # Array name structure: arr(process:group_name) = pattern
    array unset vt_rule_arr

    # SNPS
    set vt_rule_arr(snpsn5:svt)    "SVT06"
    set vt_rule_arr(snpsn5:lvt)    "LVT06"
    set vt_rule_arr(snpsn5:lvtll)  "LVTLL06"
    set vt_rule_arr(snpsn5:ulvt)   "ULT06"
    set vt_rule_arr(snpsn5:ulvtll) "ULTLL06"
    
    set vt_rule_arr(snpsn7:svt)    "SVT"
    set vt_rule_arr(snpsn7:lvt)    "LVT"
    set vt_rule_arr(snpsn7:ulvt)   "ULT"
    
    # TSMC
    set vt_rule_arr(tsmcn5:svt)    "DSVT"
    set vt_rule_arr(tsmcn5:lvt)    "DLVT"
    set vt_rule_arr(tsmcn5:lvtll)  "DLVTLL"
    set vt_rule_arr(tsmcn5:ulvt)   "DULVT"
    set vt_rule_arr(tsmcn5:ulvtll) "DULVTLL"
    
    set vt_rule_arr(tsmcn7:svt)    "DSVT"
    set vt_rule_arr(tsmcn7:lvt)    "DLVT"
    set vt_rule_arr(tsmcn7:ulvt)   "DULVT"    
    
    # BRCM
    set vt_rule_arr(brcmn7:svt)    "P6S"
    set vt_rule_arr(brcmn7:lvt)    "P6L"
    set vt_rule_arr(brcmn7:ulvt)   "P6U"    

    set vt_rule_arr(brcmn5:LL)     "F6LL"
    set vt_rule_arr(brcmn5:LN)     "F6LN"
    set vt_rule_arr(brcmn5:UL)     "F6UL"       
    set vt_rule_arr(brcmn5:UN)     "F6UN"       
    set vt_rule_arr(brcmn5:EN)     "F6EN"           
    ###########################################################################
    
    ############################################################################
    # Determine process and vendor
	set node "n[get_db design_process_node]"
	set lib  [lindex [get_db [get_db [get_db lib_cells] .library] .files] 0]
    if { [string match "*SNPS*" $lib] } {
    	set vendor "snps"
    } elseif { [string match "*BRCM*" $lib] } {
    	set vendor "brcm"
    } else {
    	set vendor "tsmc"
    }        
    set process "${vendor}$node"
    set array_names [lsort [array names vt_rule_arr *$process*]]
    ############################################################################        

    
    set table {}
    set total_area  0
    set total_cells 0
    foreach bc [lsort -u $base_cells] {    
        set name         [get_db $bc .name]
        set insts_count  [get_db $bc .insts_count]       
        set area         [get_db $bc .area]
        set bbox         [split [lindex [get_db $bc .bbox] 0] " "]
        set hight        [lindex $bbox 3]
        set width        [lindex $bbox 2]        
        set avg_load     [get_db $bc .avg_load]
        
        # Area        
        set total_area  [expr $total_area  + $area]
        set total_cells [expr $total_cells + $insts_count]        
        
        # Flags
		set is_buffer                     [get_db $bc .is_buffer                  ]
		set is_inverter                   [get_db $bc .is_inverter                ]
    	set is_combinational              [get_db $bc .is_combinational           ]
        set is_flop                       [get_db $bc .is_flop                    ]
        set is_sequential                 [get_db $bc .is_sequential              ]
		set is_integrated_clock_gating    [get_db $bc .is_integrated_clock_gating ]
        
        # Set group
        if { $is_buffer } {
            set group "buff"
        } elseif { $is_inverter } {
           	set group "inv"
        } elseif { $is_combinational } {
        	set group "comb"
        } elseif { $is_integrated_clock_gating } {
        	set group "icg"
        } elseif { $is_flop || $is_sequential } {
        	set group "reg"
        } else {
        	set group "other"
        }
        set_db -quiet $bc .be_cell_group $group
        # Power
        set avg_pwr [format "%.6f" [get_db $bc .avg_total_power    ]]
        set avg_dyn [format "%.6f" [get_db $bc .avg_dynamic_power  ]]
        set avg_swi [format "%.6f" [get_db $bc .avg_switching_power]]
        set avg_int [format "%.6f" [get_db $bc .avg_internal_power ]]
        set avg_lkg [format "%.6f" [get_db $bc .avg_leakage_power  ]]

		# VT Groups
        set vt_group NULL
        foreach key $array_names {
            if { [regexp $vt_rule_arr($key) $name] } { set vt_group [lindex [split $key ":"] end] }
        }
        
        # Cap, Func
        set out_pins     [get_lib_pins -quiet -of [lindex [get_db $bc .lib_cells] 0] -filter direction==out]
        if { [sizeof $out_pins] > 0 } {
            set max_cap      [get_db $out_pins .max_capacitance]
            set avg_max_cap  [format "%.3f" [expr [lsum $max_cap]/[llength $max_cap]]]
            set func         [get_db $out_pins .function]
        } else {
            set max_cap -1
            set avg_max_cap -1
            set func NULL
            set group phys
        }

        if { !$detailed } {   lappend table [list $name $group $vt_group $insts_count $area $hight $width $avg_max_cap $avg_load $func] ; continue }
        
        if { ![info exists min_max_cap($group)] || $avg_max_cap < $min_max_cap($group) } {
            set min_max_cap($group) $avg_max_cap
        }        
        
        if { ![info exists min_area_arr($group)] || $area < $min_area_arr($group) } {
            set min_area_arr($group) $area
        }   
        
        if { [llength [get_db attributes */be_cell_delay]] > 0 }  {       
            set avg_worst_cell_delay [format "%.3f" [get_db $bc .avg_worst_cell_delay]]
            set avg_best_cell_delay [format "%.3f" [get_db $bc .avg_best_cell_delay]]            
        } else {
            set avg_worst_cell_delay 999
            set avg_best_cell_delay 999            
        }
        
        lappend table [list $name $group $vt_group $insts_count $area $hight $width $avg_max_cap $avg_load \
              $avg_lkg $avg_swi $avg_int $avg_pwr $avg_worst_cell_delay $avg_best_cell_delay \
              $is_buffer $is_inverter $is_combinational $is_flop $is_sequential $is_integrated_clock_gating $func]
        
    }
    
    # If detailed - add Normalized values
    set new_tabel {}
    if { $detailed } {
        foreach line $table {
            lassign $line name group vt_group ic a h w amc al nevermind            

            set norm_drive_size [format "%.4f" [expr $amc/$min_max_cap($group)]  ]
            set norm_area       [format "%.4f" [expr $a/$min_area_arr($group)]]
            
            set new_line [concat $line [list $norm_drive_size $norm_area]]
            lappend new_table $new_line
        }
        set table $new_table
    }   
    
    if { $sort_by > 0 } { set table [lsort -index $sort_by -inc -real $table] }
    
    lappend table [list "" "" "" "" "" ""]
    lappend table [list Total "" "" $total_cells [format "%.5f" $total_area] "" ""]
    
    if { !$detailed } { 
    	set header [list Base_cell Group VT_group insts_count area hight width max_cap avg_load func] 
    } else {
    	set header [list Base_cell Group VT_group insts_count area hight width max_cap avg_load \
        pwr_lkg pwr_sw pwr_int pwr_tot avg_worst_delay avg_best_delay \
        is_buf is_inv is_comb is_flop is_seq is_icg func Norm_drive_size Norm_area]     
    }

    
    rls_table -table $table -header $header -spac -breaks
    
    if { $opt(-csv) != "" } {
	    redirect  $opt(-csv) { rls_table -table $table -header $header -csv_mode }
    }

}





::parseOpt::cmdSpec be_report_cells_vt {
    -help "Base cells VT split"
    -opt {
        {-optname base_cells_pattern  -type string   -default ""    -required 0 -help "Base/lib cell pattern.  If both patterns are being used, inst prevail!"}
        {-optname insts_name_pattern  -type string   -default ""    -required 0 -help "Instances name pattern. If both patterns are being used, inst prevail!"}
        {-optname cells               -type string   -default ""    -required 0 -help "Cells to check. If both patterns and cells are being used, cells prevail!"}
        {-optname return_res          -type boolean  -default false -required 0 -help "Return table instead of print"}        
    }
}
proc be_report_cells_vt { args } {
    global VT_GROUPS
    global PROJECT

    if { ! [::parseOpt::parseOpt be_report_cells_vt $args] } { return 0 }    

    set base_cells_pattern $opt(-base_cells_pattern)
    set insts_name_pattern $opt(-insts_name_pattern)    
    set cells $opt(-cells)

    if { $cells == "" && $insts_name_pattern != "" } {
        if { [get_db program_short_name] == "genus" } {
            set cells      [get_cells -quiet -hier -filter "full_name=~$insts_name_pattern && is_hierarchical==false && is_macro == false && pin_count >= 2"]        
        } else { 
            set cells      [get_cells -quiet -hier -filter "full_name=~$insts_name_pattern && is_hierarchical==false && is_macro_cell == false && pin_count >= 2"]
        }
    } elseif { $cells == "" && $base_cells_pattern != "" } {
        set cells      [get_cells -quiet -hier -filter "is_hierarchical==false && ref_name=~$base_cells_pattern && pin_count >= 2"]
    } elseif { $cells == "" } {
        if { [get_db program_short_name] == "genus" } { 
            set cells [get_cells -quiet -hier -filter "is_hierarchical==false && is_macro == false && pin_count >= 2"]
        } else {
            set cells [get_cells -quiet -hier -filter "is_hierarchical==false && is_macro_cell == false && pin_count >= 2"]
        }        
    }

    array unset vt_rule_arr
    
#    # Array name structure: arr(process:group_name) = pattern
#    # SNPS
#    set vt_rule_arr(snpsn5:0:svt)    "*SVT06*"
#    set vt_rule_arr(snpsn5:1:lvt)    "*LVT06*"
#    set vt_rule_arr(snpsn5:2:lvtll)  "*LVTLL06*"
#    set vt_rule_arr(snpsn5:3:ulvt)   "*ULT06*"
#    set vt_rule_arr(snpsn5:4:ulvtll) "*ULTLL06*"
#    
#    set vt_rule_arr(snpsn7:0:svt)    "*SVT*"
#    set vt_rule_arr(snpsn7:1:lvt)    "*LVT*"
#    set vt_rule_arr(snpsn7:2:ulvt)  "*ULT*"
#    
#    # TSMC
#    set vt_rule_arr(tsmcn5:0:svt)    "*DSVT"
#    set vt_rule_arr(tsmcn5:1:lvt)    "*DLVT"
#    set vt_rule_arr(tsmcn5:2:lvtll)  "*DLVTLL"
#    set vt_rule_arr(tsmcn5:3:ulvt)   "*DULVT"
#    set vt_rule_arr(tsmcn5:4:ulvtll) "*DULVTLL"
#    
#    set vt_rule_arr(tsmcn7:0:svt)    "*DSVT"
#    set vt_rule_arr(tsmcn7:1:lvt)    "*DLVT"
#    set vt_rule_arr(tsmcn7:2:ulvt)   "*DULVT"    
#    
#    # BRCM
#    set vt_rule_arr(brcmn7:0:svt)    "P6S*"
#    set vt_rule_arr(brcmn7:1:lvt)    "P6L*"
#    set vt_rule_arr(brcmn7:2:ulvt)   "P6U*"    
#    
#    set vt_rule_arr(brcmn5:0:SN)     "F6SN*"
#    set vt_rule_arr(brcmn5:1:LL)     "F6LL*"
#    set vt_rule_arr(brcmn5:2:LN)     "F6LN*"
#    set vt_rule_arr(brcmn5:3:UL)     "F6UL*"       
#    set vt_rule_arr(brcmn5:4:UN)     "F6UN*"       
#    set vt_rule_arr(brcmn5:5:EN)     "F6EN*"       
#    
#    #SMSNG
#    set vt_rule_arr(smsngn4:0:RVTLL)  "*S6P25TR*06*"
#    set vt_rule_arr(smsngn4:1:RVT)    "*S6P25TR*04*"
#    set vt_rule_arr(smsngn4:2:LVTLL)  "*S6P25TL*06"
#    set vt_rule_arr(smsngn4:3:LVT)    "*S6P25TL*04"
#    set vt_rule_arr(smsngn4:4:SLVTLL) "*S6P25TSL*06"
#    set vt_rule_arr(smsngn4:5:SLVT)   "*S6P25TSL*04"
#
#    set vt_groups_list [list brcmn5 tsmcn5 snpsn5 brcmn7 tsmcn7 snpsn7 smsngn4]    


    set i 0
    foreach key [array names VT_GROUPS] {
        set cmd "set vt_rule_arr(${PROJECT}:$i:${key}) $VT_GROUPS($key)"
	echo $cmd
	eval $cmd
	incr i
    }
    set vt_groups_list [list ${PROJECT}]    
  
    ############################################################################
    set node "n[get_db design_process_node]"
    set process ""
    foreach group [regexp -inline -all "\[a-zA-Z\]+$node" $vt_groups_list] {    
        foreach sub_group [array names vt_rule_arr $group*] {            
            if { [llength [get_db base_cells $vt_rule_arr($sub_group)]] > 0 } { set process "[lindex [split $sub_group ":"] 0]" ; break }
        }
        if { $process != "" } { break }   
    }
#    echo "process $process"
    set process $PROJECT
#	set lib  [lindex [get_db [get_db [get_db lib_cells] .library] .files] 0]
#    if { [string match "*SNPS*" $lib] } {
#    	set vendor "snps"
#    } elseif { [string match "*BRCM*" $lib] } {
#    	set vendor "brcm"
#    } else {
#    	set vendor "tsmc"
#    }        
    
    if { $process == "" } { 
        puts "-E- Could not determine process"
        return -1
    }

    ############################################################################    

#    set total  [llength $base_cells]
#    set total_a [format "%.4f" [lsum [get_db $base_cells .area]]]         
    set total 0
    set total_a 0
    set remaining_cells $cells    
    array unset vt_cells_arr
    set table {}
    
    foreach key [lsort [array names vt_rule_arr *$process*]] {
    	
        set group [lindex [split $key ":"] end]

        set relevant_cells  [filter_collection $cells ref_name=~$vt_rule_arr($key)]
        set remaining_cells [remove_from_collection $remaining_cells $relevant_cells]
        
        set vt_cells_arr($group:cells)     $relevant_cells
        set vt_cells_arr($group:count)     [sizeof $vt_cells_arr($group:cells)]        
        set vt_cells_arr($group:count_pct) 0
        if { [sizeof $vt_cells_arr($group:cells)] } { set vt_cells_arr($group:area)  [format "%.4f" [lsum [get_db  $vt_cells_arr($group:cells) .area]]] } { set vt_cells_arr($group:area) 0 }
        set vt_cells_arr($group:area_pct)  0
        
        set total   [expr $total   + $vt_cells_arr($group:count)]
        set total_a [expr $total_a + $vt_cells_arr($group:area)]

    }

    if { [sizeof $remaining_cells] > 0 } {
        puts "-W- Found [sizeof $remaining_cells] cells with no VT afiiliation"
    }
    
    # Calc pct
    foreach key [lsort [array names vt_rule_arr *$process*]] {

        set group [lindex [split $key ":"] end]
        set vt_cells_arr($group:count_pct) "[format "%.2f" [expr  100.0 * $vt_cells_arr($group:count) / $total]]%"
        set vt_cells_arr($group:area_pct)  "[format "%.2f" [expr  100.0 * $vt_cells_arr($group:area) / $total_a]]%"

        lappend table [list $group $vt_cells_arr($group:count) $vt_cells_arr($group:count_pct) \
                                   $vt_cells_arr($group:area)  $vt_cells_arr($group:area_pct)]
    }
        
    lappend table [list "" "" "" "" ""]
    lappend table [list "Total" $total "" $total_a ""]
    
    if { $opt(-return_res) } { return $table }
    
    set header [list Type count pct area pct]
    rls_table -table $table -header $header -spac -breaks        
}


proc be_get_cells_by_vt  { {cells ""} } {
    
    set_message -suppress -id TCLCMD-513
    
    if { $cells == "" } {
        if { [get_db program_short_name] == "genus" } { 
            set cells [get_cells -quiet -hier -filter "is_hierarchical==false && is_macro == false && pin_count >= 2"]
        } else {
        	set cells [get_cells -quiet -hier -filter "is_hierarchical==false && is_macro_cell == false && pin_count >= 2"]
        }        
    }

    array unset vt_rule_arr
    
    # Array name structure: arr(process:group_name) = pattern
    # SNPS
    set vt_rule_arr(snpsn5:svt)    "*SVT06*"
    set vt_rule_arr(snpsn5:lvt)    "*LVT06*"
    set vt_rule_arr(snpsn5:lvtll)  "*LVTLL06*"
    set vt_rule_arr(snpsn5:ulvt)   "*ULT06*"
    set vt_rule_arr(snpsn5:ulvtll) "*ULTLL06*"
    
    set vt_rule_arr(snpsn7:svt)    "*SVT*"
    set vt_rule_arr(snpsn7:lvt)    "*LVT*"
    set vt_rule_arr(snpsn7:ulvt)  "*ULT*"
    
    # TSMC
    set vt_rule_arr(tsmcn5:svt)    "*DSVT"
    set vt_rule_arr(tsmcn5:lvt)    "*DLVT"
    set vt_rule_arr(tsmcn5:lvtll)  "*DLVTLL"
    set vt_rule_arr(tsmcn5:ulvt)   "*DULVT"
    set vt_rule_arr(tsmcn5:ulvtll) "*DULVTLL"
    
    set vt_rule_arr(tsmcn7:svt)    "*DSVT"
    set vt_rule_arr(tsmcn7:lvt)    "*DLVT"
    set vt_rule_arr(tsmcn7:ulvt)   "*DULVT"    
    
    # BRCM
    set vt_rule_arr(brcmn7:svt)    "P6S*"
    set vt_rule_arr(brcmn7:lvt)    "P6L*"
    set vt_rule_arr(brcmn7:ulvt)   "P6U*"    
    
    set vt_rule_arr(brcmn5:SN)     "F6SN*"
    set vt_rule_arr(brcmn5:LL)     "F6LL*"
    set vt_rule_arr(brcmn5:LN)     "F6LN*"
    set vt_rule_arr(brcmn5:UL)     "F6UL*"       
    set vt_rule_arr(brcmn5:UN)     "F6UN*"       
    set vt_rule_arr(brcmn5:EN)     "F6EN*"       
    
    set vt_rule_arr(brcmn3:SN)     "E*SN*"
    set vt_rule_arr(brcmn3:LL)     "E*LL*"
    set vt_rule_arr(brcmn3:LN)     "E*LN*"
    set vt_rule_arr(brcmn3:UL)     "E*UL*"       
    set vt_rule_arr(brcmn3:UN)     "E*UN*"       
    set vt_rule_arr(brcmn3:EN)     "E*EN*"       
    
    #SMSNG
    set vt_rule_arr(smsngn4:0:RVT)    "*S6P25TR*"
    set vt_rule_arr(smsngn4:1:LVT)    "*S6P25TL*"
    set vt_rule_arr(smsngn4:2:SLVT)   "*S6P25TSL*"

    set vt_groups_list [list brcmn3 brcmn5 tsmcn5 snpsn5 brcmn7 tsmcn7 snpsn7 smsngn4]    
  
    ############################################################################
	set node "n[get_db design_process_node]"
    set process ""
    foreach group [regexp -inline -all "\[a-zA-Z\]+$node" $vt_groups_list] {    
        foreach sub_group [array names vt_rule_arr $group*] {            
            if { [llength [get_db base_cells $vt_rule_arr($sub_group)]] > 0 } { set process "[lindex [split $sub_group ":"] 0]" ; break }
        }
        if { $process != "" } { break }   
    }

#	set lib  [lindex [get_db [get_db [get_db lib_cells] .library] .files] 0]
#    if { [string match "*SNPS*" $lib] } {
#    	set vendor "snps"
#    } elseif { [string match "*BRCM*" $lib] } {
#    	set vendor "brcm"
#    } else {
#    	set vendor "tsmc"
#    }        
    
    if { $process == "" } { 
        puts "-E- Could not determine process"
        return -1
    }

    ############################################################################    

#    set total  [llength $base_cells]
#    set total_a [format "%.4f" [lsum [get_db $base_cells .area]]]         
    set total 0
    set total_a 0
    set remaining_cells $cells    
    array unset vt_cells_arr
    set table {}

    foreach key [lsort [array names vt_rule_arr *$process*]] {
    	
        set group [lindex [split $key ":"] end]

        set relevant_cells  [filter_collection $cells ref_name=~$vt_rule_arr($key)]
        set remaining_cells [remove_from_collection $remaining_cells $relevant_cells]
        
        set vt_cells_arr($group:cells)     $relevant_cells
        set vt_cells_arr($group:count)     [sizeof $vt_cells_arr($group:cells)]        
        set vt_cells_arr($group:count_pct) 0
        if { [sizeof $vt_cells_arr($group:cells)] } { set vt_cells_arr($group:area)  [format "%.4f" [lsum [get_db  $vt_cells_arr($group:cells) .area]]] } { set vt_cells_arr($group:area) 0 }
        set vt_cells_arr($group:area_pct)  0
        
        set total   [expr $total   + $vt_cells_arr($group:count)]
        set total_a [expr $total_a + $vt_cells_arr($group:area)]

    }

    if { [sizeof $remaining_cells] > 0 } {
        puts "-W- Found [sizeof $remaining_cells] cells with no VT afiiliation"
    }
    
    # Calc pct
    set return_vec {}
    foreach key [lsort [array names vt_rule_arr *$process*]] {

        set group [lindex [split $key ":"] end]
        set vt_cells_arr($group:count_pct) "[format "%.2f" [expr  100.0 * $vt_cells_arr($group:count) / $total]]%"
        set vt_cells_arr($group:area_pct)  "[format "%.2f" [expr  100.0 * $vt_cells_arr($group:area) / $total_a]]%"
        
        lappend return_vec [list $group [get_db $vt_cells_arr($group:cells)]]
        
        lappend table [list $group $vt_cells_arr($group:count) $vt_cells_arr($group:count_pct) \
                                   $vt_cells_arr($group:area)  $vt_cells_arr($group:area_pct)]
    }
        
    lappend table [list "" "" "" "" ""]
    lappend table [list "Total" $total "" $total_a ""]
    
    set header [list Type count pct area pct]
    rls_table -table $table -header $header -spac -breaks     

    set_message -unsuppress -id TCLCMD-513
    
    return $return_vec  
    
    
}


proc be_short_report_dont_use { {output ""} } {

    if { [llength [get_db attributes *is_hdh] ] == 0 } {
        define_attribute -category be_user_attributes -obj_type base_cell -data_type int     -default 0     insts_count
        define_attribute -category be_user_attributes -obj_type base_cell -data_type double  -default 0     avg_load        
        define_attribute -category be_user_attributes -obj_type base_cell -data_type bool    -default false is_hdh
    }

    if { [regexp "Genus" [get_db program_name]] } {
        set avoid_cells   [lsort -u [get_db [get_db lib_cells -if .avoid==true] .base_cell]]
        set num_of_ac     [llength $avoid_cells]
    } else {
        set avoid_cells   {}
        set num_of_ac     0
    }
    
    set dontuse_cells [get_db base_cells -if .dont_use==true]    
    set num_of_dc     [llength $dontuse_cells]            
    
    set user_defined_dont_use_list      [split [get_db user_dontuse_list] " "]
    set user_dont_use_lib_cells         [lsort -u [get_db [get_db lib_cells $user_defined_dont_use_list] .base_cell]]
    
    set predefine_defined_dont_use_list [split [get_db predefine_dontuse_list] " "]
    set predefine_dont_use_lib_cells    [get_db base_cells $predefine_defined_dont_use_list]    
    
    set original_dont_use_cells         [lsort -u [concat $predefine_dont_use_lib_cells $user_dont_use_lib_cells]]
    set total      [llength $original_dont_use_cells]
    set current    0
    set table {}
    
    puts "-REPORT DONTUSE- Count cells"    
    foreach bc $original_dont_use_cells {

        #ory_progress $current $total
        incr current
        
        set cells [get_db insts -if {.base_cell.name==$bc}]

        if { [llength $cells ] > 0 } {
            set cell_count [llength $cells ]
            set_db -quiet [get_db base_cells $bc] .insts_count $cell_count
            if { $cell_count > 0 } { lappend table [list [get_db $base_cell .name] $cell_count]  }
        }
    }
    puts ""
    
    redirect -var cell_count_table { rls_table -table $table -header [list Base_cell Insts_count] -spac -breaks}
    
    set rpt "
+-----------------------+
+ Report Dont Use Cells +
+-----------------------+    

Sum of user dont_use cells:       [llength $user_dont_use_lib_cells]
Sum of predefined dont_use cells: [llength $predefine_dont_use_lib_cells]
Sum of Actual avoid cells:        $num_of_ac
Sum of Actual dont_use cells:     $num_of_dc

Base cells with more then 0 instances:
-------------------------------------
$cell_count_table
    "
    
    puts $rpt 

}


proc ory_report_hfn { {th 200} {nets ""} } {


    if { $nets == "" } {
        set nets [get_db nets -if ".num_loads>$th"]
    } else {
        set nets [get_db nets $nets -if ".num_loads>$th"]
    }
    
    t $nets dont_touch num_loads { lsort -u [get_db $o .loads.clocks.base_name] }


}


::parseOpt::cmdSpec ory_report_hier {
    -help "Prints some info on base cells"
    -opt {
        {-optname root       -type string  -default ""      -required 0 -help "Hierarchy to start from. Exclusive with -cells. Default is TOP. i.e. my_block_top/my_cpu_wrap/cpu"}
        {-optname cells      -type string  -default ""      -required 0 -help "Default is all cells in the design. Exclusive with -root"}
        {-optname level      -type integer -default 1       -required 0 -help "Default is 1 level"}        
        {-optname sort_by    -type integer -default 0       -required 0 -help "0 will sort by name"}
        {-optname power      -type boolean -default false   -required 0 -help "Add power data"}        
        {-optname area       -type boolean -default false   -required 0 -help "Add area data"} 
        {-optname file_name  -type string  -default ""      -required 0 -help "If not empty, saves to file_name and file_name.csv"}         
    }
}

proc ory_report_hier { args } {

    set start_t [clock seconds]
    puts "-I- Start running ory_report_hier at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

    if { ! [::parseOpt::parseOpt ory_report_hier $args] } { return 0 }    
    
    if { [get_db program_short_name] == "innovus" } {
        set seq_filter "is_sequential==true&&is_integrated_clock_gating_cell!=true"
        set icg_filter "is_integrated_clock_gating_cell==true"
    } else {
        set seq_filter "is_sequential==true&&is_flop==true" 
        set icg_filter "is_integrated_clock_gating==true"           
    }
    
    set root     $opt(-root)
    set cells    $opt(-cells)
    set level    $opt(-level)
    set sort_by  $opt(-sort_by)
    set power    $opt(-power)
    set area     $opt(-area)

    if { $cells != "" && $root != "" } { puts "-E- You can not use both -root and -cells!" ; return -1 }

    if { $cells != "" } {    
	    set cells_collection [get_cells $cells]
    } elseif { $root != "" } {
	    set cells_collection [get_cells -hier -filter "is_hierarchical == false && full_name =~ $root/*"]    
        set root_level [llength [regexp -all -inline "/" $root]]
        set level      [expr $root_level + $level]
    } else {
	    set cells_collection [get_cells -hier -filter "is_hierarchical == false"]
    }

  	regsub -all "\\\[\[0-9\]+\\\]" [get_db $cells_collection .parent.name ] "\[*\]" all_parents_names    
    

    # Show $level levels of hierarchies
    array unset res_arr
        
    set pattern "\[a-zA-Z0-9_\*\]+/"
    set reg_phrase [string repeat $pattern $level]
    foreach name [lsort -u $all_parents_names] {
        regexp $reg_phrase $name name
        set name [string trim $name "/"]
        if { [info exists res_arr($name)] } {
            lappend res_arr($name) $name        
        } else {
            set res_arr($name) [list $name]
        }
    }

    array unset hier_arr
    array unset top_arr
    array unset total_arr    

    foreach hier [array names res_arr] {
        set current_level [expr [llength [regexp -all -inline "/" $hier]] + 1]
        
        if { $hier == [get_db designs .name] } {
            set hier_cells [get_cells -hier -filter "is_hierarchical == false && full_name !~ */*"]
        } elseif { $level > 1 && $current_level < $level } {
            set hier_cells [filter_collection $cells_collection "full_name=~$hier/* && full_name!~$hier/*/*"]
        } else {
            if { $level > 1 && ![regexp "/" $hier] } { continue }
            set hier_cells [filter_collection $cells_collection full_name=~$hier/*]
        }
        
        if { [sizeof $hier_cells] == 0 } { puts "-W- $hier is empty" ; continue }
        
        set is_hips                       [filter_collection $hier_cells is_black_box==true ]
    	set is_buffer                     [filter_collection $hier_cells is_buffer==true                  ]
		set is_inverter                   [filter_collection $hier_cells is_inverter==true                ]
    	set is_combinational              [filter_collection $hier_cells is_combinational==true           ]
        set is_sequential                 [filter_collection $hier_cells $seq_filter ]
		set is_integrated_clock_gating    [filter_collection $hier_cells $icg_filter ]

        set hier_arr($hier)      $hier
        set hier_arr($hier:size) [sizeof $hier_cells                ]
        set hier_arr($hier:hips) [sizeof $is_hips                   ]
        set hier_arr($hier:buff) [sizeof $is_buffer                 ]
        set hier_arr($hier:inv)  [sizeof $is_inverter               ]
        set hier_arr($hier:comb) [sizeof $is_combinational          ]
        set hier_arr($hier:seq)  [sizeof $is_sequential]
        set hier_arr($hier:bits) [sizeof [get_pins -quiet -of $is_sequential -filter direction==out]]                          
        set hier_arr($hier:icg)  [sizeof $is_integrated_clock_gating] 
        
        if { $area } {
            if { [sizeof $hier_cells                ] > 0 } { set hier_arr($hier:all:area)   [format "%.2f" [lsum [get_db $hier_cells                 .area]]] } else { set hier_arr($hier:all:area)  0 }
            if { [sizeof $is_hips                   ] > 0 } { set hier_arr($hier:hips:area)  [format "%.2f" [lsum [get_db $is_hips                    .area]]] } else { set hier_arr($hier:hips:area) 0 }
            if { [sizeof $is_buffer                 ] > 0 } { set hier_arr($hier:buff:area)  [format "%.2f" [lsum [get_db $is_buffer                  .area]]] } else { set hier_arr($hier:buff:area) 0 }
            if { [sizeof $is_inverter               ] > 0 } { set hier_arr($hier:inv:area)   [format "%.2f" [lsum [get_db $is_inverter                .area]]] } else { set hier_arr($hier:inv:area)  0 }
            if { [sizeof $is_combinational          ] > 0 } { set hier_arr($hier:comb:area)  [format "%.2f" [lsum [get_db $is_combinational           .area]]] } else { set hier_arr($hier:comb:area) 0 }
            if { [sizeof $is_sequential             ] > 0 } { set hier_arr($hier:seq:area)   [format "%.2f" [lsum [get_db $is_sequential              .area]]] } else { set hier_arr($hier:seq:area)  0 }
            if { [sizeof $is_integrated_clock_gating] > 0 } { set hier_arr($hier:icg:area)   [format "%.2f" [lsum [get_db $is_integrated_clock_gating .area]]] } else { set hier_arr($hier:icg:area)  0 }
        }
        
        if { $power } { 
            if { [sizeof $hier_cells                ] > 0 } { set hier_arr($hier:all:power_total)  [format "%.3f" [lsum [get_db $hier_cells                 .power_total]]] } else { set hier_arr($hier:all:power_total)  0 }
            if { [sizeof $is_hips                   ] > 0 } { set hier_arr($hier:hips:power_total) [format "%.3f" [lsum [get_db $is_hips                    .power_total]]] } else { set hier_arr($hier:hips:power_total) 0 }
            if { [sizeof $is_buffer                 ] > 0 } { set hier_arr($hier:buff:power_total) [format "%.3f" [lsum [get_db $is_buffer                  .power_total]]] } else { set hier_arr($hier:buff:power_total) 0 }
            if { [sizeof $is_inverter               ] > 0 } { set hier_arr($hier:inv:power_total)  [format "%.3f" [lsum [get_db $is_inverter                .power_total]]] } else { set hier_arr($hier:inv:power_total)  0 }
            if { [sizeof $is_combinational          ] > 0 } { set hier_arr($hier:comb:power_total) [format "%.3f" [lsum [get_db $is_combinational           .power_total]]] } else { set hier_arr($hier:comb:power_total) 0 }
            if { [sizeof $is_sequential             ] > 0 } { set hier_arr($hier:seq:power_total)  [format "%.3f" [lsum [get_db $is_sequential              .power_total]]] } else { set hier_arr($hier:seq:power_total)  0 }               
            if { [sizeof $is_integrated_clock_gating] > 0 } { set hier_arr($hier:icg:power_total)  [format "%.3f" [lsum [get_db $is_integrated_clock_gating .power_total]]] } else { set hier_arr($hier:icg:power_total)  0 }
            
            if { [sizeof $hier_cells                ] > 0 } { set hier_arr($hier:all:power_dynamic)  [format "%.3f" [lsum [get_db $hier_cells                 .power_dynamic]]] } else { set hier_arr($hier:all:power_dynamic)  0 }
            if { [sizeof $is_hips                   ] > 0 } { set hier_arr($hier:hips:power_dynamic) [format "%.3f" [lsum [get_db $is_hips                    .power_dynamic]]] } else { set hier_arr($hier:hips:power_dynamic) 0 }
            if { [sizeof $is_buffer                 ] > 0 } { set hier_arr($hier:buff:power_dynamic) [format "%.3f" [lsum [get_db $is_buffer                  .power_dynamic]]] } else { set hier_arr($hier:buff:power_dynamic) 0 }
            if { [sizeof $is_inverter               ] > 0 } { set hier_arr($hier:inv:power_dynamic)  [format "%.3f" [lsum [get_db $is_inverter                .power_dynamic]]] } else { set hier_arr($hier:inv:power_dynamic)  0 }
            if { [sizeof $is_combinational          ] > 0 } { set hier_arr($hier:comb:power_dynamic) [format "%.3f" [lsum [get_db $is_combinational           .power_dynamic]]] } else { set hier_arr($hier:comb:power_dynamic) 0 }
            if { [sizeof $is_sequential             ] > 0 } { set hier_arr($hier:seq:power_dynamic)  [format "%.3f" [lsum [get_db $is_sequential              .power_dynamic]]] } else { set hier_arr($hier:seq:power_dynamic)  0 }               
            if { [sizeof $is_integrated_clock_gating] > 0 } { set hier_arr($hier:icg:power_dynamic)  [format "%.3f" [lsum [get_db $is_integrated_clock_gating .power_dynamic]]] } else { set hier_arr($hier:icg:power_dynamic)  0 }      
            
            if { [sizeof $hier_cells                ] > 0 } { set hier_arr($hier:all:power_leakage)  [format "%.3f" [lsum [get_db $hier_cells                 .power_leakage]]] } else { set hier_arr($hier:all:power_leakage)  0 }
            if { [sizeof $is_hips                   ] > 0 } { set hier_arr($hier:hips:power_leakage) [format "%.3f" [lsum [get_db $is_hips                    .power_leakage]]] } else { set hier_arr($hier:hips:power_leakage) 0 }
            if { [sizeof $is_buffer                 ] > 0 } { set hier_arr($hier:buff:power_leakage) [format "%.3f" [lsum [get_db $is_buffer                  .power_leakage]]] } else { set hier_arr($hier:buff:power_leakage) 0 }
            if { [sizeof $is_inverter               ] > 0 } { set hier_arr($hier:inv:power_leakage)  [format "%.3f" [lsum [get_db $is_inverter                .power_leakage]]] } else { set hier_arr($hier:inv:power_leakage)  0 }
            if { [sizeof $is_combinational          ] > 0 } { set hier_arr($hier:comb:power_leakage) [format "%.3f" [lsum [get_db $is_combinational           .power_leakage]]] } else { set hier_arr($hier:comb:power_leakage) 0 }
            if { [sizeof $is_sequential             ] > 0 } { set hier_arr($hier:seq:power_leakage)  [format "%.3f" [lsum [get_db $is_sequential              .power_leakage]]] } else { set hier_arr($hier:seq:power_leakage)  0 }               
            if { [sizeof $is_integrated_clock_gating] > 0 } { set hier_arr($hier:icg:power_leakage)  [format "%.3f" [lsum [get_db $is_integrated_clock_gating .power_leakage]]] } else { set hier_arr($hier:icg:power_leakage)  0 }                                    
        }
                               
        
    }


    set table {}
    foreach hier [array names hier_arr] {
        
        if { [regexp ":" $hier] } { continue }
        set line [list $hier $hier_arr($hier:size) $hier_arr($hier:hips) $hier_arr($hier:buff) $hier_arr($hier:inv) $hier_arr($hier:comb) $hier_arr($hier:seq) $hier_arr($hier:bits) $hier_arr($hier:icg) ]
        
        if { $area } {
            set line [concat $line [list $hier_arr($hier:all:area) $hier_arr($hier:hips:area) $hier_arr($hier:buff:area) $hier_arr($hier:inv:area) $hier_arr($hier:comb:area) $hier_arr($hier:seq:area) $hier_arr($hier:icg:area)]]        
        }
        
        if { $power } {
            set line [concat $line [list $hier_arr($hier:all:power_total)  $hier_arr($hier:all:power_dynamic)   $hier_arr($hier:all:power_leakage)  \
                                         $hier_arr($hier:hips:power_total) $hier_arr($hier:hips:power_dynamic)  $hier_arr($hier:hips:power_leakage) \
                                         $hier_arr($hier:buff:power_total) $hier_arr($hier:buff:power_dynamic)  $hier_arr($hier:buff:power_leakage) \
                                         $hier_arr($hier:inv:power_total)  $hier_arr($hier:inv:power_dynamic)   $hier_arr($hier:inv:power_leakage)  \
                                         $hier_arr($hier:comb:power_total) $hier_arr($hier:comb:power_dynamic)  $hier_arr($hier:comb:power_leakage) \
                                         $hier_arr($hier:seq:power_total)  $hier_arr($hier:seq:power_dynamic)   $hier_arr($hier:seq:power_leakage)  \
                                         $hier_arr($hier:icg:power_total)  $hier_arr($hier:icg:power_dynamic)   $hier_arr($hier:icg:power_leakage) ]]         
        }
        
        lappend table $line

    }


    
    if { $sort_by == 0 } {
        set s_table [lsort -decr $table]
    } else {
        set s_table [lsort -decr -real -index $sort_by $table]
    }

    set s_table [ory_sum_table $s_table]
    
    set header [list Hier "#ofCells" HIPs Buf Inv Comb Seq Bits ICG ]
    
    if { $area } {
        set header [concat $header [list Hier_area HIP_area buf_area inv_area comb_area seq_area icg_area]]
    }
    
    if { $power} {
        set header [concat $header [list Hier_pwr dyn lkg \
                                         HIP_pwr  dyn lkg \
                                         buf_pwr  dyn lkg \
                                         inv_pwr  dyn lkg \
                                         comb_pwr dyn lkg \
                                         seq_pwr  dyn lkg \
                                         icg_pwr  dyn lkg ]]   
    }
    
    set file_name $opt(-file_name)
    if { $file_name == "" } {
    rls_table -table $s_table -header $header -format "%s %-10d %-6d %-6d %-6d %-6d %-6d" -spacious -breaks
    return
    }
    
    if { [set csv_file_name [regsub ".rpt" $file_name ".csv"]] == $file_name } { set csv_file_name ${file_name}.csv }
    
    redirect $file_name     { rls_table -table $s_table -header $header -format "%s %-10d %-6d %-6d %-6d %-6d %-6d" -spacious -breaks }
    redirect $csv_file_name { rls_table -csv -table $s_table -header $header -format "%s %-10d %-6d %-6d %-6d %-6d %-6d" -spacious -breaks }    

    set end_t [clock seconds]
    puts "-I- End running ory_report_hier at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
    puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

}


proc ory_report_ports { {ports ""} {threshold 0} {aggressive true} } {

    
    if { $ports == "" } { set ports [get_db ports] }
    
    
    if { $aggressive } { 

	    set new_list [lsort -uniq [regsub -all "_\[0-9\]+ \|_\[0-9\]+$" [regsub -all "\\\[\[a-zA-Z0-9\]+\\\]" [get_db $ports .name] "[*]"] "* " ] ]

	    set new_list [lsort -uniq [regsub -all "_\\\*" $new_list "*" ] ]    
	    set new_list [lsort -uniq [regsub -all "\\\*+" $new_list "*" ] ]        

	    set comp_list [lsort -uniq [regsub -all "\\\*+" $new_list "*" ] ]            

    } else {
        set comp_list [ory_bus_compress [get_db $ports .name]]
    }
    
    array unset bus_arr
    foreach bus $comp_list {
        
        set bus_ports [get_db ports $bus]
        set bus_arr($bus) [llength $bus_ports]
        set bus_arr($bus:direction) [lsort -u [get_db  $bus_ports .direction]]

    }
    
    set table {}
    set total 0
    foreach bus [array names bus_arr ] {

        if { [regexp ":" $bus] } { continue }
        set size $bus_arr($bus)
        set dir  $bus_arr($bus:direction)
        
        if { $size > $threshold } {
            lappend table [list $bus $size $dir]
            set total [expr $total + $size]
        }
    
    }
    
    set s_table [lsort -index 0 -inc $table]
    
    lappend s_table [list "" "" ""]
    lappend s_table [list "Total" $total ""]

    set header [list Bus Size Direction]    
    rls_table -table $s_table -header $header -format "%s %-5d %-5d" -spacious -breaks
        

}


proc be_report_loop { {stage ""} } {

    if { $stage == "" } { set stage [get_db be_stage] }
    set file_name [get_db user_stage_reports_dir]/${stage}_report_loop.rpt
    
    set rpt ""
    
    if { [get_db program_short_name] == "genus" } {
        
        redirect $file_name { report_loop -sdcfile out/${stage}_disable_timing_loops.sdc}
        set fp [open $file_name r]
        set fd [read $fp]
        close $fp
        
        if { [regexp "No loop breakers to report" $fd] } { set rpt "-I- No loop breakers to report" ; return $rpt }

    }
    
    set loop_breakers [get_db insts *loop_breaker*]
    if { [file exists $file_name] } { 
        set rpt "-I- Detailed report in: $file_name\n"
    }
    append rpt "-I- Found [llength $loop_breakers] loop breakers in the design"
    
    puts $rpt    
}


::parseOpt::cmdSpec be_sum_to_csv {
    -help "Parse be.qor report to csv file"
    -opt {
        {-optname csv_file     -type string  -default ""      -required 0 -help "Name of csv_file to create. If exists, append new line to file"}
        {-optname stage        -type string  -default ""      -required 0 -help "Name of stage. If empty, taken from the rpeort"}        
        {-optname be_qor_file  -type string  -default ""      -required 0 -help "Report to parse. If empty, taken by stage. If both stage and be_qor_file are empty, take the latest file"}                
        {-optname comment      -type string  -default ""      -required 0 -help "Comment to add at the end of the line in the csv"}                
        {-optname final        -type boolean -default false   -required 0 -help "Indicates it is the last report in a STAGE"}                
        {-optname mail         -type boolean -default false   -required 0 -help "Mail csv to user"}                
    }
}

proc be_sum_to_csv { args } {

    if { ! [::parseOpt::parseOpt be_sum_to_csv $args] } { return 0 }    

    set stage $opt(-stage)
    set csv_file $opt(-csv_file)
    set be_qor_file $opt(-be_qor_file)
    set comment $opt(-comment)
    set final $opt(-final)

    set parse_res    [be_parse_qor_report $stage $be_qor_file]
    set new_line     [concat [lindex $parse_res 0] $comment]
    set return_file  [lindex $parse_res 1] 
    set return_stage [lindex $parse_res 2]  
    set design_name  [lindex $new_line 2]   
   
    #################
    # Parse CSV file   
    #################
    if { $csv_file == "" } {        
        set csv_file "../[lindex [split [pwd] "/"] end-1]_[lindex [split [pwd] "/"] end]_qor_summary.csv"
    }
    set rp [ exec realpath $csv_file ]

    set header [list Date Time Block_name Source Version Run stage "X(um)" "Y(um)" Area Leaf_Cell_Area Utilization Cell_count "Buf/inv" \
                     Logic Flops Bits Removed_seq num_of_ports "%svt" "%lvtll" "%lvt" "%ulvtll" "%ulvt" "%en" \
                     internal switching dynamic leakage total Bank_ratio 2_mulibit 4_mulibit 6_multibit 8_mulibit "Total WNS(ps)" "Total TNS(ps)" "Total FEP" "R2R WNS(ps)" \
                     "R2R TNS(ps)" "R2R FEP" "Hold WNS(ns)" "Hold TNS(ps)" "Hold FEP" V H num_of_shorts DRC_Total Run_time CPU Mem Comment]
    
    if { ![file exists $csv_file] } {
        puts "-I- Creating $rp file"
        redirect $csv_file { puts [join $header ","]}
    }
    
    redirect -app $csv_file { puts [join $new_line ","]}  
    
    set echo_txt "-I- Report QOR summary: \$rp\n"
    
    if { [info var ::RUNNING_LOCAL_SCRIPTS] != "" && [llength $::RUNNING_LOCAL_SCRIPTS] > 0 } {
        foreach file $::RUNNING_LOCAL_SCRIPTS { append echo_txt "-W- LOCAL FILE: [file normalize $file]\n" }
    }

    if { $final } {
        set log [exec cat [get_db log_file]]
###################################################################################################
#     Start running synthesis at: 28/05/21 09:18:17
#     End running synthesis at: 28/05/21 14:41:24
#     Elapse time is 0 days , 05:23:07
###################################################################################################
        set hour_pattern "\[0-9\]+:\[0-9\]+:\[0-9\]+"
        set date_pattern "\[0-9\]+/\[0-9\]+/\[0-9\]+"    
        if { ![regexp "#     Elapse time is +(\[0-9\]) days , ($hour_pattern)" $log res days hours] } { set hours NA ; set days NA }
        
        # Report errors/warnings
        redirect reports/${return_stage}_err.sum { be_report_messages }
                
        # Append snapshots if exists
        set att_ss ""
        if { ( $return_stage == "place" || $return_stage == "cts" || $return_stage == "route" ) && [file exists "reports/$return_stage/snapshot"] } {
            set snapshots_list [list reports/$return_stage/snapshot/${design_name}.congestion.gif \
                                     reports/$return_stage/snapshot/${design_name}.density.gif \
                                     reports/$return_stage/snapshot/${design_name}.placement.gif \
                                     reports/$return_stage/snapshot/ss_${design_name}.amoeba.gif ]
            foreach file [glob -nocomplain reports/$return_stage/snapshot/*user*.gif] {
		lappend snapshots_list $file
	    }
	    foreach file $snapshots_list {
                if { [file exists $file] } { append att_ss "-a $file " }
            }
        }
        set mail_cmd      "exec echo \"-I- Report QOR summary: \$rp\" | mail -r BE_Run_Summary@nextsilicon.com -a \$csv_file -a \$return_file $att_ss -s \$subject \$address"
        set bsh_mail_cmd  "_be_convert_reports_to_bash_mail \$subject \"$echo_txt\" reports/\${return_stage}_err.sum \$address \[list \$csv_file \$return_file\]"
    } else {
        set mail_cmd      "exec echo \"-I- Report QOR summary: \$rp\" | mail -r BE_Run_Summary@nextsilicon.com -a \$csv_file -a \$return_file -s \$subject \$address"
        set bsh_mail_cmd  "_be_convert_reports_to_bash_mail \$subject \"$echo_txt\" reports/\${return_stage}_err.sum \$address \[list \$csv_file \$return_file\]"
    }     

    
    if { $opt(-mail) } {        
        set address [be_get_user_email]
        if { $address != "" } {
	    set suser [be_get_supper_user_email]
            foreach sss $suser {
	        set address "$address [be_get_user_email $sss]"
	    }
	    regsub {\s} [lsort -unique $address] "," address

	
            puts "-I- Mailing $rp to: $address"
            set subject "BE_FLOW - $design_name - $return_stage - QOR summary [::ory_time::now]"
            if { $final } {
              if { [catch { eval $mail_cmd } res ] } { 
                puts "-E- be_sum_to_csv failed to mail reports" 
              } else {
                if { [catch { eval $bsh_mail_cmd } res] } {
                  puts "-E- _be_convert_reports_to_bash_mail failed to mail reports"
                  puts $res
                }
              }
            } else {            
              if { [catch { eval $mail_cmd } res ] } {                 
                puts "-E- be_sum_to_csv failed to mail reports" 
              } else {
                if { [catch { eval $bsh_mail_cmd } res] } {
                  puts "-E- _be_convert_reports_to_bash_mail failed to mail reports"
                  puts $res
                }
              } 
            }
        }            
    }              
    
}
   

proc be_parse_qor_report { {stage ""} {file ""} } {

    if { $stage != "" } {
        set be_reports_file reports/${stage}.be.qor
        if { ![file exists $be_reports_file] } { puts "-W- No $be_reports_file found" ; return }
    } else {
    # If no stage - take the latest file
        if { [catch {glob reports/*be.qor} res] } { puts "-W- No be.qor reports found in ./reports dir" ; return }
        redirect -var files { ls -t "./reports/*be.qor" }
        set be_reports_file [lindex [split $files "\n"] 0]
        set stage           [lindex [split [file tail $be_reports_file] "."] 0]
    }

    if { $file != "" } { set be_reports_file $file; puts "-W- Overriding stage useage. Reading $file instead" }

    set fp [open $be_reports_file r]
    set fd [read $fp]
    close $fp

        
    #-------------------------
    # Parse like the wind
    #-------------------------

    # block
    if { ![regexp " +Block: +(\[_a-zA-Z0-9\]+)" $fd res block_name] } { set block_name NA}
    # Design source
    if { ![regexp " +Design Source: +(\[^ \n\]+)" $fd res design_source] }  { set design_source NA}
    # version
    if { ![regexp " +Version: +(\[_a-zA-Z0-9\\\.\]+)" $fd res version] }  { set version NA}
    # date and time
    if { ![regexp " +Generated on: +(\[A-Za-z\]+ \[0-9\]+ \[0-9\]+) +(\[0-9: a-z\]+)" $fd res date hour] }  { set date NA; set hour NA}
    # desc
    if { ![regexp " +Run: +(\[_a-zA-Z0-9\]+)" $fd res desc ] } { set desc NA}       
    # stage
    if { $stage == "" } {
        if { ![regexp " +Stage: +(\[_a-zA-Z0-9\]+)" $fd res stage] } { set stage NA }
    }
    # x
    if { ![regexp "X: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res x] } { set x NA }
    if { ![regexp "Y: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res y] } { set y NA }
    # area
    if { ![regexp "Core Area: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res area] } { set area NA }
    # util
    if { ![regexp "Effective Density: +(\[\\\-_a-zA-Z0-9\\\.\]+%)" $fd res util] } { set util NA }
    if { ![regexp "Leaf Cell Area: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res lc_area] } { set lc_area NA }    
    # cell count
    if { ![regexp "Leaf Cell Count: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res cell_count] } { set cell_count NA }
    # buf/inv
    if { ![regexp "Buffer Cell Count: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res bufs  ] } { set bufs 0 }
    if { ![regexp "Inverter Cell Count: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res invs] } { set invs 0 }
    # logic
    if { ![regexp "Combinational Cell Count: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res logic] } { set logic NA }
    # seq
    if { ![regexp "Sequential Cell Count: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res flops  ] } { set flops NA }      
    if { ![regexp "FF Bit Count: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res bits  ] } { set bits NA }          
    # removed
    if { ![regexp "Sequential element deleted for .unloaded. reason: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res unloaded  ] } { set unloaded 0}              
    if { ![regexp "Sequential element deleted for .merged. reason: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res merged      ] } { set merged   0}          
    if { ![regexp "Sequential element deleted for .constant 0. reason: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res const0  ] } { set const0   0}
    if { ![regexp "Sequential element deleted for .constant 1. reason: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res const1  ] } { set const1   0}
    # ports
    if { ![regexp "Port Count: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res ports] } { set ports NA }
    # VT
    #set vt_pattern "+\\\| \[0-9\]+ +\\\| \[0-9\\\.\]+% +\\\| \[0-9\\\.\]+ +\\\| (\[0-9\\\.\]+%)"    
    set vt_pattern "+\\\| \[0-9\]+ +\\\| +\[0-9\\\.\]+% +\\\| +\[0-9\\\.\]+ +\\\| +(\[0-9\\\.\]+%)"
    if { ![regexp "LVT $vt_pattern"    $fd res lvt   ] } { set lvt    NA}
    if { ![regexp "LVTLL $vt_pattern"  $fd res lvtll ] } { set lvtll  NA}
    if { ![regexp "ULVT $vt_pattern"   $fd res ulvt  ] } { set ulvt   NA}
    if { ![regexp "ULVTLL $vt_pattern" $fd res ulvtll] } { set ulvtll NA}
    if { ![regexp "SVT $vt_pattern"    $fd res svt   ] } { set svt    NA}
    if { ![regexp "EVT $vt_pattern"    $fd res en    ] } { set en     NA}    

    if { $lvt == "NA" && $lvtll == "NA" && $ulvt == "NA" && $ulvtll == "NA" && $svt == "NA" } {
        if { ![regexp "LN $vt_pattern"    $fd res lvt   ] } { set lvt    NA}
        if { ![regexp "LL $vt_pattern"  $fd res lvtll ] } { set lvtll  NA}
        if { ![regexp "UN $vt_pattern"   $fd res ulvt  ] } { set ulvt   NA}
        if { ![regexp "UL $vt_pattern" $fd res ulvtll] } { set ulvtll NA}
        if { ![regexp "TBD $vt_pattern"    $fd res svt   ] } { set svt    NA}        
    }
    
    # Power
    if { ![regexp "Leakage Power: +(\[\\\-_a-zA-Z0-9\\\.\]+)"   $fd res lkg ] } { set lkg NA}
    if { ![regexp "Dynamic Power: +(\[\\\-_a-zA-Z0-9\\\.\]+)"   $fd res dyn ] } { set dyn 0}
    if { ![regexp "Internal Power: +(\[\\\-_a-zA-Z0-9\\\.\]+)"  $fd res int ] } { set int 0}
    if { ![regexp "Switching Power: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res swt ] } { set swt 0}       
    if { ![regexp "Total Power: +(\[\\\-_a-zA-Z0-9\\\.\]+)"     $fd res tot ] } { set tot NA}      

    # Overflow
    if { ![regexp " +H overflow +: +(\[\\\-_a-zA-Z0-9\\\.\]+%)" $fd res hof] } { set hof NA }
    if { ![regexp " +V overflow +: +(\[\\\-_a-zA-Z0-9\\\.\]+%)" $fd res vof] } { set vof NA }       

    # RT, MEM, CPU
    set hour_pattern "\[0-9\]+:\[0-9\]+:\[0-9\]+"
    set date_pattern "\[0-9\]+/\[0-9\]+/\[0-9\]+"    
    if { ![regexp "Elapsed: +(\[0-9\]) days , ($hour_pattern)" $fd res days hours] } { set hours NA ; set days NA }
    if { ![regexp "Peak Mem: +(\[0-9\\\.\]+)" $fd res mem    ] }  { set mem     NA }
    if { ![regexp "CPU: +(\[0-9\]+)"          $fd res cpu    ] }  { set cpu     NA }    
    
    if { $hours != "NA" && $days > 0 } {
        set days2hours    [expr 24*$days]
        set current_hours [scan [string range $hours 0 1] %d]
        set new_hours     [expr $days2hours + $current_hours]
        set hours         "$new_hours:[string range $hours 3 end]"
    }
    set run_time $hours
    
    set wns_hold_all NA
    set tns_hold_all NA
    set fep_hold_all NA
    set wns_hold_r2r NA
    set tns_hold_r2r NA
    set fep_hold_r2r NA
    
    # FLOW
    if { [regexp "Generated by: +Innovus" $fd res] } { set flow "innovus" } else { set flow "genus" }

    # Genus
    if { $flow == "genus" } {

        # MBIT
        if { ![regexp "Bank Ratio: +(\[\\\-_a-zA-Z0-9\\\.\]+%)" $fd res bank_ratio ] } { set bank_ratio 0}
        if { ![regexp " +2-bit: +(\[\\\-_a-zA-Z0-9\\\.\]+)"     $fd res mb2        ] } { set mb2        0}
        if { ![regexp " +4-bit: +(\[\\\-_a-zA-Z0-9\\\.\]+)"     $fd res mb4        ] } { set mb4        0}
        if { ![regexp " +6-bit: +(\[\\\-_a-zA-Z0-9\\\.\]+)"     $fd res mb6        ] } { set mb6        0}       
        if { ![regexp " +8-bit: +(\[\\\-_a-zA-Z0-9\\\.\]+)"     $fd res mb8        ] } { set mb8        0}       
        
        # Timing
        set timing_patther ""
        if { ![regexp "All     +\\\| +(\[\\\-0-9\\\.\]+) +\\\| +(\[\\\-0-9\\\.\]+) +\\\| +(\[\\\-0-9\\\.\]+)" $fd res wns_all tns_all fep_all] } {set wns_all NA; set tns_all NA; set fep_all NA}
        if { ![regexp "reg2reg +\\\| +(\[\\\-0-9\\\.\]+) +\\\| +(\[\\\-0-9\\\.\]+) +\\\| +(\[\\\-0-9\\\.\]+)" $fd res wns_r2r tns_r2r fep_r2r] } {set wns_r2r NA; set tns_r2r NA; set fep_r2r NA}       

        
        set shorts    NA
        set drc_total NA
        

    } else {
    # Innovus

        # MBIT
        if { ![regexp "Single-Bit FF Count +: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res single_bit ] } { set single_bit NA}
        if { ![regexp "Total Bit Count +: +(\[\\\-_a-zA-Z0-9\\\.\]+)"     $fd res total_bit  ] } { set total_bit NA }       
        if { ![regexp " 2-Bit FF Count +: +(\[\\\-_a-zA-Z0-9\\\.\]+)"      $fd res mb2        ] } { set mb2        0}
        if { ![regexp " 4-Bit FF Count +: +(\[\\\-_a-zA-Z0-9\\\.\]+)"      $fd res mb4        ] } { set mb4        0}
        if { ![regexp " 6-Bit FF Count +: +(\[\\\-_a-zA-Z0-9\\\.\]+)"      $fd res mb6        ] } { set mb6        0}      
        if { ![regexp " 8-Bit FF Count +: +(\[\\\-_a-zA-Z0-9\\\.\]+)"      $fd res mb8        ] } { set mb8        0}
        
        if { $single_bit != "NA" && $total_bit != "NA" } { set bank_ratio "[expr 100.0*($total_bit - $single_bit)/$total_bit]%" } else { set bank_ratio 0 }  
        
        # Timing
        set timing_patther ""
        if { ![regexp "All     +\\\| +(\[\\\-0-9\\\.\]+) +\\\| +(\[\\\-0-9\\\.\]+) +\\\| +(\[\\\-0-9\\\.\]+)" $fd res wns_all tns_all fep_all] } {set wns_all NA; set tns_all NA; set fep_all NA}
        if { ![regexp "reg2reg +\\\| +(\[\\\-0-9\\\.\]+) +\\\| +(\[\\\-0-9\\\.\]+) +\\\| +(\[\\\-0-9\\\.\]+)" $fd res wns_r2r tns_r2r fep_r2r] } {set wns_r2r NA; set tns_r2r NA; set fep_r2r NA}       
        
        # Route
        if { ![regexp "SHORT:Metal Short +: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res shorts] } { set shorts 0 }
        if { ![regexp "TOTAL DRC +: +(\[\\\-_a-zA-Z0-9\\\.\]+)" $fd res drc_total] } { set drc_total NA }               
        
    }    
    
    set line     [list $date $hour $block_name $design_source $version $desc $stage \
                       $x $y $area $lc_area $util \
                       $cell_count [expr $bufs+$invs] $logic $flops $bits [expr $unloaded + $merged + $const0 + $const1] $ports \
                       $svt $lvtll $lvt $ulvtll $ulvt $en\
                       $int $swt [expr $dyn + $int + $swt] $lkg $tot \
                       $bank_ratio $mb2 $mb4 $mb6 $mb8 \
                       $wns_all $tns_all $fep_all \
                       $wns_r2r $tns_r2r $fep_r2r \
                       $wns_hold_all $tns_hold_all $fep_hold_all \
                       $vof $hof \
                       $shorts $drc_total \
                       $run_time $cpu $mem ]
    
    
    #-----------------
    # FORMATING
    #-----------------
    set new_line {}
    
    foreach v $line {
    
        # if not string
        if { ![regexp "\[a-zA-Z\\\<\\\>\\\/\\\_\\\%\]" $v res] } { 
            
            # Dec
            if { [regexp "\[0-9\]+\\\.\[0-9\]+" $v] } {
                
                set max_length 6                
                set num_length [string length $v]
                
                if { $max_length < $num_length } {
                set int_length [string length [lindex [split $v "."] 0]]
                set dec_length [string length [lindex [split $v "."] 1]]
                
                set format_length [expr $max_length - $int_length]
                set dec_length    [lindex [lsort -real -dec [list $format_length 0] ] 0]

                set new_format    "%.${dec_length}f"
                
                set v [format $new_format $v]
                }
                
            } else {
            # Int?

            }
            
        }
        
        lappend new_line $v
    
    }
    
    return [list $new_line $be_reports_file $stage]
    

}


######################################
# Get Latest eee measurement from log
######################################
proc be_rt_mem_cpu { {stage ""} {file ""} } {
    
    if { $file == "" } {
    set file [get_db log_file]
    }
    set fp   [open $file r]
    set fd   [read $fp]
    close $fp
    
    # Get eee runtime
    set hour_pattern "\[0-9\]+:\[0-9\]+:\[0-9\]+"
    set date_pattern "\[0-9\]+/\[0-9\]+/\[0-9\]+"
    if { $stage == "" } {
        set prefix "\\\-I"
        if { ![regexp "$date_pattern $hour_pattern"   [lindex [regexp -all -inline "\\\-I\\\- Start running \[a-zA-Z_\]+ +at: \[0-9/ :\]+" $fd] end]  started] } { set started NA }
        if { ![regexp "$date_pattern $hour_pattern"   [lindex [regexp -all -inline "\\\-I\\\- End running \[a-zA-Z_\]+ +at: \[0-9/ :\]+" $fd] end]  ended    ] } { set ended   NA }
        if { ![regexp "\[0-9\]+ days , $hour_pattern" [lindex [regexp -all -inline "\\\-I\\\- Elapse time is \[0-9\]+ days , $hour_pattern" $fd] end] elapsed] } { set elapsed NA }
    } else {
        set prefix "\\\-I\\\- BE_STAGE: $stage " 
    }
    if { ![regexp "$date_pattern $hour_pattern"   [lindex [regexp -all -inline "$prefix\\\- Start running \[a-zA-Z_\]+ +at: \[0-9/ :\]+" $fd] end]  started] } { set started NA }
    if { ![regexp "$date_pattern $hour_pattern"   [lindex [regexp -all -inline "$prefix\\\- End running \[a-zA-Z_\]+ +at: \[0-9/ :\]+" $fd] end]  ended    ] } { set ended   NA }
    if { ![regexp "\[0-9\]+ days , $hour_pattern" [lindex [regexp -all -inline "$prefix\\\- Elapse time is \[0-9\]+ days , $hour_pattern" $fd] end] elapsed] } { set elapsed NA }                

    # Genus
    if { [get_db program_short_name] == "genus" } {
    
    # Get memory data
    set peak_memory                [get_db peak_memory               ]
    set memory_usage               [get_db memory_usage              ]
    set peak_physical_memory_usage [get_db peak_physical_memory_usage]
    set physical_memory_usage      [get_db physical_memory_usage     ]
    
    set max_mem [lindex [lsort -real -dec [list $peak_memory $memory_usage $peak_physical_memory_usage $physical_memory_usage] ] 0]

    # Get CPU data
    set cpu [get_db max_cpus_per_server]
    } else {    
    # Innovus    
#    puts "WIP"
    redirect -var resources {report_resource}

    if { ![regexp "peak res=(\[0-9\\\.\]+M)" $resources res max_mem] } { set max_mem NA }
    
    set cpu [get_multi_cpu_usage -local_cpu]
    
    }
    
    
    
    set rpt "[nice_header "runtime"]
Started:  $started
Ended:    $ended
Elapsed:  $elapsed
Peak Mem: $max_mem
CPU:      $cpu
"
    return $rpt
    
}


proc be_get_shorts_nets { args } {

    set shorts_markers [get_db markers -if .subtype==Metal_Short&&.originator==check] 
    
    if { [llength $shorts_markers] == 0 } {
        puts "-I- No shorts found"
        return 
    }
        
    set objs  [get_db -uniq $shorts_markers .objects]
    
    return $objs

}


proc be_report_mbit { {stage ""} } {

    if { [get_db program_short_name] == "genus" } {
        redirect [get_db user_stage_reports_dir]/${stage}_report.mbit            { report_multibit_inferencing }
        redirect [get_db user_stage_reports_dir]/${stage}_report_not_merged.mbit { report_multibit_inferencing -not_merged_sum}    
        set fp [open [get_db user_stage_reports_dir]/${stage}_report.mbit r]
        set fd [read $fp]
        close $fp

        if { ![regexp "No Sequential Instance got merged to multibit" $fd res] } {
            set m2 0 ; set m4 0 ; set m6 0 ; set m8 0 
            regexp "Single-bit flip-flop +(\[0-9\]+)" $fd res single
            regexp "Multi-bit flip-flop +(\[0-9\]+) +(\[0-9.\]+)" $fd res multi bank_ratio
            regexp "2\-bit +(\[0-9\]+)" $fd res m2
            regexp "4\-bit +(\[0-9\]+)" $fd res m4
            regexp "6\-bit +(\[0-9\]+)" $fd res m6                                        
            regexp "8\-bit +(\[0-9\]+)" $fd res m8 

            set mbit_report "\nBank Ratio:\t$bank_ratio%\nSingl:\t\t$single\nTotal Mbit:\t$multi\n\t2-bit:\t$m2\n\t4-bit:\t$m4\n\t6-bit:\t$m6\n\t8-bit:\t$m8"
        } else {
            set mbit_report "-W- $res"
        }
    } else {
	set MBIT_DEPENDENCIES_FIXED 0
	if {[regexp {22.1} [get_db program_version]] || !${MBIT_DEPENDENCIES_FIXED}} {
        redirect [get_db user_stage_reports_dir]/${stage}_report.mbit            { report_multi_bit_ffs -stat }
	} else {
		set mb_cmd "report_multibit"
		redirect [get_db user_stage_reports_dir]/${stage}_report.mbit            { $mb_cmd }
	}
        set mbit_report [exec cat [get_db user_stage_reports_dir]/${stage}_report.mbit]
    }

    puts $mbit_report
}


proc report_reset_ffs { {stage ""} } {

    set all_flops         [get_db insts -if ".is_integrated_clock_gating==false && .is_flop==true"]    
    set async_clear_pins  [get_db $all_flops -if !.base_cell.lib_cells.async_clear_pins==""]
    set async_preset_pins [get_db $all_flops -if !.base_cell.lib_cells.async_preset_pins==""] 
    set both              [get_db $all_flops -if !.base_cell.lib_cells.async_preset_pins==""&&!.base_cell.lib_cells.async_clear_pins==""]
    set reset_pct         "[format "%.2f" [expr 100.0*([llength $async_clear_pins]  - [llength $both])/[llength $all_flops]]]%"
    set preset_pct        "[format "%.2f" [expr 100.0*([llength $async_preset_pins] - [llength $both])/[llength $all_flops]]]%"    
    set both_pct          "[format "%.2f" [expr 100.0*[llength $both]/[llength $all_flops]]]%"
    
    set table {} 
    foreach ff [lsort -u [concat $async_clear_pins $async_preset_pins]] {
        
        set name     [get_db $ff .name]
        set desc_res [get_inst_desc $ff]
        set bcn      [lindex $desc_res 0]
        set desc     [lindex $desc_res 1]
        set is_reset  false
        set is_preset false 
        
        if { [get_db $ff !.base_cell.lib_cells.async_clear_pins]  == "" } { set is_reset  true }
        if { [get_db $ff !.base_cell.lib_cells.async_preset_pins] == "" } { set is_preset true }
        
        lappend table [list $name $bcn $is_reset $is_preset $desc]
                
    }
    
    set header [list "Name" "Base_cell" "Rest" "Set" "Desc"]
    
    redirect [get_db user_stage_reports_dir]/${stage}_detailed_async_ff_pins.rpt { rls_table -header $header -table $table -spac -breaks }
    
    puts "-I- Detailed report is in: reports/${stage}_detailed_async_ff_pins.rpt"
    puts "-I- $reset_pct percent of all flops have async reset pin (lindex 0 on return)"
    puts "-I- $preset_pct percent of all flops have async preset pin (lindex 1 on return)"    
    puts "-I- $both_pct percent of all flops have async preset and reset pins (lindex 2 on return)"    

	return [list $async_clear_pins $async_preset_pins $both]

}



#proc be_get_stages_prefixes { } {
#    
#    set files [glob ./scripts/*tcl]
#    if { [catch {set lines [string map {"$" "\$"} [exec echo $files | xargs grep opt_new_inst_prefix ]]} res] } { return -1 }
#        
#    foreach line [split $lines "\n"] {
#        set stage ""
#        regexp "do_(\[a-zA-Z\]+).tcl" $line res stage
#        regexp "opt_new_inst_prefix \"(.+)\"" $line res prefix
#        regsub "\\\${STAGE}" $prefix $stage new_prefix
#        puts $line
#        puts "${stage} $prefix" 
#        puts $new_prefix       
#    }
#    
#    
#
#}

::parseOpt::cmdSpec be_count_cell_prefixes {
    -help "Count cell prefix by stage/opt_design reason/cts type"
    -opt {
        {-optname mode     -type string  -default "all"      -required 0 -help "All=all reports. cts=just cts cell. opt_design=opt_design cells. stage=stages prefixes "}
    }
}
proc be_count_cell_prefixes { args } {

   if { ! [::parseOpt::parseOpt be_count_cell_prefixes $args] } { return 0 }    

   set mode $opt(-mode)

   if { ![is_attribute -obj inst be_cell_stage] } {
        define_attribute be_cell_stage     -category be_user_attributes -data_type string  -obj_type inst -default ""
        define_attribute be_cell_reason    -category be_user_attributes -data_type string  -obj_type inst -default ""
        define_attribute be_cell_cts_type  -category be_user_attributes -data_type string  -obj_type inst -default ""                
   }

   set stages_list {"i_place_opt_"                
                    "i_place_"
                    "i_cts_hold_"                 
                    "i_cts_only_"                 
                    "i_cts_"                      
                    "i_route_track_opt_"          
                    "i_route_post_route_h_"       
                    "i_route_post_route_"         
                    "i_route_fix_drc_"}           

    array set prefix_arr {FE_MDBC "Instance added by multi-driver net buffering optDesign"
    FE_MDBN "Net added by multi-driver net buffering optDesign"
    FE_OCP_RBC "Instance added by rebuffering optDesign"
    FE_OCP_RBN "Net added by rebuffering optDesign"
    FE_OCPC "Instance added by critical path optimization optDesign"
    FE_OCPN "Net added by critical path optimization optDesign"
    FE_OFC "Buffer instance added by rule-based buffer insertion or DRV fixing insertRepeater/optDesign"
    FE_OFN "Buffer net added by rule-based buffer insertion or DRV fixing insertRepeater/optDesign"
    FE_PHC "Instance added by hold time repair optDesign"
    FE_PHN "Net added by hold time repair optDesign"
    FE_PSBC "Instance added by buffer insertion in optDesign - postRoute optDesign"
    FE_PSBN "Net added by buffer insertion in optDesign - postRoute optDesign"
    FE_PSC "Instance added by postroute setup repair optDesign"
    FE_PSN "Net added by postroute setup repair optDesign"
    FE_PSRN "Net added by postRoute restructuring optDesign"
    FE_RC "Instance created by netlist restructuring optDesign"
    FE_RN "Net created by netlist restructuring optDesign"
    FE_USC "Instance added during useful skew optimization optDesign"
    FE_PDC "Instance added by postroute DRV fixing optDesign"
    FE_PDN "Net added by postroute DRV fixing optDesign"
    FE_RAC "Instance added by reclaim optimizer optDesign"
    FE_RAN "Net added by reclaim optimizer optDesign"
    FE_USKC "Instance added during useful skew optimization optDesign/skewClock"
    FE_USKN "Net added during useful skew optimization optDesign/skewClock"
    FE_TBOPTPSBC "Cell added during postRoute multi-buffering (NBF) in TBOpt flow optDesign"
    FE_TBOPTPSBN "Net added during postRoute multi-buffering (NBF) in TBOpt flow optDesign"
    FE_TBOPTC "Cell added during postRoute single-buffering in TBOpt flow optDesign"
    FE_TBOPTN "Net added during postRoute single-buffering in TBOpt flow optDesign"}
    
    array set cts_prefix_arr {cuk "Cts: Unknown creator, will not appear in the netlist."
    ccl "Cts: Created by the clustering process to meet the slew target."    
    ccl_a "Cts: Created during clustering by the agglom clustering algorithm"
    cbi "Cts: Created by the swapping buffers and inverters for power."
    cex "Cts: Existing cells in the clock tree which cannot be removed."
    coi "Cts: Cells created as a result of cancelling out inversions."
    ccd "Cts: Created by clustering for balancing the tree - these cells are not necessary to meet the slew target."
    cci "Cts: Created by the clustering process to fix inversion."
    csf "Cts: Created by the CTS slew fixing step in cases where clustering did not meet the slew target."
    cms "Cts: Created during the process of physically moving clock gates to improve their enable timing."
    cid "Cts: Created by CTS on the outputs of weak driving cells to reduce insertion delay."
    cdb "Cts: Created by CTS to balance the delays in the clock tree."
    cwb "Cts: Created by CTS to balance the wire delays in the clock tree."
    cfo "Cts: Created by CTS to reduce fanout skew."
    csk "Cts: Created by the CTS skew fixing step to finely balance the clock tree."
    cmf "Cts: Created by CTS to buffer long nets."
    cbc "Cts: Created by the clock tree conditioning step to clone off sub trees that cannot be optimized by gated synthesis, such as those parts above RAMs, black boxes, and lockup latches."
    css "Cts: Created by the early cloning of simple sink allocations."
    cdc "Cts: A clock driver created by adding the driver cell process for the add_driver_cell property."
    cpd "Cts: A clock driver created below an input port or above an output port specified by attribute cts_add_port_driver."
    ccg "Cts: A clock gate created by one of the gated synthesis algorithms."
    cse "Cts: A clock driver created above exclude pins to remove them from the clock tree."
    cfh "Cts: A clock driver created as part of a flexible H-tree."
    cat "Cts: Created by the add_clock_tree_source_group_roots command"
    cpc_drv "Cts: A clock driver created by post conditioning"
    cpc_sk "Cts : A clock driver created by post conditioning"
    PRO "Post route optimization"
    PRO_drv "Post route optimization"
    PRO_sk "Post route optimization"
    sfc "Cloned by slew fixing"
    ccc "Cts : Created by clone_clock_cells command"
    qrb "Cts: A clock driver created by global route buffering"
    sgb "Cts : A clock driver created by global route buffering"
    idc "Cloned to reduce insertion delay"
    vgb "Cts : A clock driver crated by VG buffering"
    USK "skewClock"
    cff "Cts: A clock driver created by fanout fixing"
    CTSG "Unnamed : this should not be used anymore"}
    
    puts "-I- Getting cells "
    set cells [get_db [get_cells -hier] -if .obj_type==inst]

    
    if { $mode == "all" || $mode == "stage" } {
        set table {}
        set_db -quiet $cells .be_cell_stage ""            
        foreach pattern $stages_list {
            set res [get_db [regexp -all -inline "inst:\[a-zA-Z_0-9/\\\[\\\]\]+${pattern}\[a-zA-Z_0-9/\\\[\\\]\]+ " $cells] -if .be_cell_stage==""] 
            if { [set len [llength $res]] > 0 } {
                lappend table [list $pattern $len]
                set_db -quiet $res .be_cell_stage "$pattern"
            }
        }
        set header [list Stage Count]
        rls_table -table [lsort -real -index 1 -dec $table] -header $header -spac -breaks
        puts ""
    }

    if { $mode == "all" || $mode == "opt_design" } {    
        set table {}
        set_db -quiet $cells .be_cell_reason   ""    
        foreach pattern [lsort -dec [array names prefix_arr]] {
            set res [get_db [regexp -all -inline "inst:\[a-zA-Z_0-9/\\\[\\\]\]+${pattern}\[a-zA-Z_0-9/\\\[\\\]\]+ " $cells] -if .be_cell_reason==""]
            if { [set len [llength $res]] > 0 } {
                lappend table [list $pattern $len $prefix_arr($pattern)]
                set_db -quiet $res .be_cell_reason "$pattern"
            }
        }
        set header [list Opt_Design_prefix Count Description]
        rls_table -table [lsort -real -index 1 -dec $table] -header $header -spac -breaks
        puts ""
    }

    if { $mode == "all" || $mode == "cts" } {
        set table {}
        set_db -quiet $cells .be_cell_cts_type ""   
        foreach pattern [lsort -dec [array names cts_prefix_arr]] {
            set res [get_db [regexp -all -inline "inst:\[a-zA-Z_0-9/\\\[\\\]\]+_${pattern}_\[a-zA-Z_0-9\\\[\\\]\]+ " $cells] -if .be_cell_cts_type==""]
            if { [set len [llength $res]] > 0 } {
                lappend table [list $pattern $len $cts_prefix_arr($pattern)]
    #            foreach inst $res { set_db -quiet $inst .be_cell_cts_type "$pattern [get_db $inst .be_cell_cts_type]" }
                set_db -quiet $res .be_cell_cts_type "$pattern"            
            }
        }
        set header [list CTS_prefix Count Description]
        rls_table -table [lsort -real -index 1 -dec $table] -header $header -spac -breaks
        puts ""
    }
    
}


proc be_report_all_root_attributes { {stage ""} } {

    set all_atts [get_db attributes root/*]

    set max_len1  0
    set max_len2  83
    array unset att_array 
    foreach att $all_atts {
        
        set full_name                [get_db $att .name]
        set att_array($full_name:name)     [get_db $att .base_name]
        set att_array($full_name:def)      [get_db $att .default_value]
        set att_array($full_name:help)     [get_db $att .help]
        set att_array($full_name:settable) [get_db $att .is_settable]
        set att_array($full_name:user)     [get_db $att .is_user_defined]
        set att_array($full_name:obsolete) false        
        
        # Check if obsolete
        redirect -var res  {set att_array($full_name:value)    [get_db $att_array($full_name:name)]} 
        if { [regexp "has become obsolete" $res] } { 
            set att_array($full_name:obsolete) true 
        }
        
        if { $att_array($full_name:def) != $att_array($full_name:value) } { set att_array($full_name:changed) true } else { set att_array($full_name:changed) false }
        
        if { [string length $att_array($full_name:name)] > $max_len1 } { set max_len1 [string length $att_array($full_name:name)] }
#        if { [string length $att_array($full_name:def) ] > $max_len2 } { set max_len2 [string length $att_array($full_name:def)] ; if { $max_len2 > 83 } { puts $full_name } }        
    }
    
    if { [is_attribute -obj root user_stage_reports_dir] && [get_db user_stage_reports_dir] != "" } {  set folder [get_db user_stage_reports_dir] } else { set folder reports }

    set def_att_report     $folder/${stage}_default_attributes.rpt
    set non_def_att_report $folder/${stage}_non_default_attributes.rpt    
    set obs_att_report     $folder/${stage}_obsolete_attributes.rpt        
    set user_att_report    $folder/${stage}_user_defined_attributes.rpt            

    set list_th 1
    set str_th  100
    
    set header_def     "[format %-${max_len1}s Name] [format %-${str_th}s Value] Help\n"
    set header_non_def "[format %-${max_len1}s Name] [format %-${str_th}s Value] [format %-${max_len2}s Default_Value] Help\n"
    
    echo $header_def     > $def_att_report
    echo $header_non_def > $non_def_att_report
    echo $header_non_def > $obs_att_report
    echo $header_non_def > $user_att_report    

    foreach key [array names att_array *:name] {
        
        set att    [lindex [split $key ":"] 0]
        set value  $att_array($att:value)
        set name   $att_array($att:name)
        set help   [regsub -all "\n" $att_array($att:help) " "]
        set def    $att_array($att:def)
        
        if       { [regexp "\n" $value] } { 
            set value "[lindex [split $value "\n"] 0]..." 
        } elseif { [llength $value] > $list_th } { 
            set value "[lrange $value 0 $list_th]... And [expr [llength $value] - $list_th] others" 
        } 
        if { [string length $value] > $str_th   } { set value "[string range $value 0 $str_th-4]..." }
        if { [string length $help]  > $str_th   } { set help  "[string range $help  0 $str_th-4]..." }        
        if { [string length $def]   > $max_len2 } { set def   "[string range $def   0 $max_len2-4]..." }                


        
        set line "[format %-${max_len1}s $name] [format %-${str_th}s $value]"
        if { $att_array($att:user) } {
            echo $line >> $user_att_report
        } elseif { $att_array($att:changed) } {
            append line " [format %-${max_len2}s $def] $help"
            if { $att_array($att:obsolete) } { 
                echo $line >> $obs_att_report
            } else {
                echo $line >> $non_def_att_report
            }            
        } else {
            append line " $help"
            echo $line >> $def_att_report
        }
    
    }

}

proc be_report_si_glithces {  } {

    set file  reports/route/route.SI_Glitches.rpt
    
#    set fp [open $file r]
#    set fd [read $fp]
#    close $fp
    if { [file exists $file] } { puts [exec grep "Total number of glitch violations" $file] }
}


proc be_report_shorts_per_layer {} {

    set shorts [get_db markers -if .subtype==Metal_Short]
    set layers [lsort -u [get_db $shorts .layer.name]   ]
    
    set header [list Layer Num_of_shorts]
    set table {}
    foreach l $layers {
        lappend table [list $l [llength [get_db $shorts -if .layer.name==$l]]]
    }
    
    redirect -var res {rls_table -table $table -header $header -spac -breaks}
    
    puts $res
    
}




proc be_classify_base_cells { } {

    if { [is_attribute -obj_type root be_base_cell_types] } {
        define_attribute -category be_user_attributes -obj_type root -data_type string  -default ""   be_base_cell_types
    } else { 
        return 
    }

    set base_cells [get_db base_cells]

    set cell_type_list {}
    set total   [llength $base_cells]
    set current 0
    foreach bc $base_cells {

        ory_progress $current $total
        incr current

        # Flags
		set is_buffer              [get_db $bc .is_buffer            ]
		set is_inverter            [get_db $bc .is_inverter          ]
    	set is_combinational       [get_db $bc .is_combinational     ]
        set is_flop                [get_db $bc .is_flop              ]
        set is_sequential          [get_db $bc .is_sequential        ]
        set is_macro               [get_db $bc .is_macro             ]
        
        # Set group
        if { $is_inverter || $is_buffer } {
           	set group "bufinv"
        } elseif { $is_combinational } {
        	set group "logic"
        } elseif { $is_flop || $is_sequential || $is_macro } {
        	set group "flop"
        } else {
        	set group "other"
        }        
        
        lappend cell_type_list [list $bc $group]
        
    }
    puts ""
    set_db -quiet be_base_cell_types [join $cell_type_list]
    
    return 0

}

proc be_get_return_base_cell_type { bc } {
    
    set base_cell_types_list [get_db be_base_cell_types]
    
    if { [regexp "$bc (\[a-z\]+) " $base_cell_types_list res type] } {
        return $type
    } else {
        return NULL
    }
    
}




proc ory_parse_report_timing_file { file } {

#    set file bla_1000.rpt
    set fp [open $file r]
    set timing_paths [read $fp]
    close $fp
    
    set res [be_parse_timing_paths $timing_paths]
    
    return $res
    

}



proc be_report_timing { args } {
	
    if { [regexp {\-help} $args] } {
        report_timing -help
        return
    }

    set prev_trf [get_db timing_report_fields]
    set_db -quiet timing_report_fields {timing_point cell edge fanout load transition total_derate delay arrival pin_location flags}
    set cmd  "report_timing -split_delay $args"
    redirect -var timing_paths { eval $cmd }
    set_db -quiet timing_report_fields $prev_trf

    if { [regexp "No paths found" $timing_paths] || [regexp "No constrained timing paths" $timing_paths] } {
        puts $timing_paths
        return 
    }
    
    set res [be_parse_timing_paths $timing_paths]
    
    puts [lindex $res 1]

}



::parseOpt::cmdSpec be_report_timing_summary {
    -help "Report longest-logic-levels paths"
    -opt    {
            {-optname from        -type string   -default ""       -required 0 -help "Report timing from"}
            {-optname to          -type string   -default ""       -required 0 -help "Report timing to"}
            {-optname max_paths   -type integer  -default 1000     -required 0 -help "Max number of paths for report timing"}
            {-optname max_slack   -type integer  -default 999      -required 0 -help "Only report slacks lower then this value"}            
            {-optname nworst      -type integer  -default 1        -required 0 -help "Max number of paths per endpoint"}            
            {-optname group       -type string   -default ""       -required 0 -help "Path group"}                        
            {-optname debug_rpt   -type boolean  -default false    -required 0 -help "Generate timing report to load in timing debugger"}                                    
            {-optname output      -type string   -default ""       -required 0 -help "File name"}                                                
    }
}

proc be_report_timing_summary { args } {
    set start_t [clock seconds]
    puts "-I- Start running be_report_timing_summary at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"

	if { ! [::parseOpt::parseOpt be_report_timing_summary $args] } { return 0 }
    
    set cmd "report_timing -hpin -split_delay -max_slack $opt(-max_slack) -max_path $opt(-max_paths) -nworst $opt(-nworst)"
    if { $opt(-group) != "" } {   append cmd " -group $opt(-group)"   }
    if { $opt(-from)  != "" } {   append cmd " -from $opt(-from)"   }
    if { $opt(-to)    != "" } {   append cmd " -to $opt(-to)"   }        

    puts "-I- Eval: $cmd"
    
    set prev_trf [get_db timing_report_fields]
    set_db -quiet timing_report_fields {timing_point cell edge fanout load transition total_derate delay arrival pin_location flags}
    
    redirect -var return_var { eval $cmd }
    redirect _ory_tmp_report_timing.rpt { puts $return_var }
    
    set_db -quiet timing_report_fields $prev_trf
    
    # If not paths found
    if { [regexp "No paths found" $return_var] || [regexp "No constrained timing paths" $return_var] } {
        puts $return_var
        return -7
    }
        
    set output $opt(-output)
    if { $output == "" } { set output "ory_timing_summary.rpt" }
        
    if { [catch {set res [be_parse_timing_paths $return_var]} err] } {
        puts "-E- Error running be_parse_timing_paths"
        puts $err
        return -1
    }
    set table   [lindex $res 0]
    set new_rpt [lindex $res 1]
    
    set header [list "Path_id" "Group" "Slack" "Cells" "Logic" "Buf/Inv" "Dist" "From_Clk" "From" "To_Clk" "To"]
    redirect -var print_table { rls_table -table $table -header $header -spac -breaks }

    redirect ${output}          { puts $print_table }
    redirect ${output}.detailed { puts $new_rpt }

    file delete _ory_tmp_report_timing.rpt
    
    puts "-I- Report: $output"
    
    if { $opt(-debug_rpt) } {
        puts "-I- Create timing debug file"
        append cmd " -output_format gtd"
        redirect $output.mtarpt { eval $cmd }
    }
    set end_t [clock seconds]
    puts "-I- End running be_report_timing_summary at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
    puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"

}

proc be_parse_timing_paths { timing_paths } {
    global PROJECT

#    if { [info exists ${PROJECT}] } { set proj $${PROJECT} } else { set proj [lindex [split [pwd] "/"] end-3] }
        
    if { [regexp "snpsn" $PROJECT] } {
	    puts "-I- process is snps 5nm"
        set bc_pattern "(HDB\[A-Z\]+06_\[A-Z0-9_\]+) |(sacrls\[a-z0-9\]+) "
    } elseif { [regexp "brcm|inext|nextcore|nxt080" $PROJECT] } {
	    puts "-I- process is brcm 5nm"
        set bc_pattern "(F6\[A-Z\]+\[A-Z\]\[A-Z\]_\[A-Z0-9_\]+) |(M5SRF\[A-Z0-9\]) "
    } else {       
        set bc_pattern "DOOMED_TO_FAIL"
    }

    if { [get_db program_short_name] == "genus" } {
        set program "genus"
        set dp_pattern " +Data Path:\- +(\[\\\-0-9\\\.\]+)"
    } else {
        set program "not_genus"
        set dp_pattern " +Data Path:\\\+ +(\[\\\-0-9\\\.\]+)"
    }


    array unset paths_arr 
    set start 0
    set end   0
    set string_len [string length $timing_paths]
    for {set i 1} { $end != $string_len } { incr i } {

        set path      "Path $i"    
        set next_path "Path [expr $i + 1]"
        set start [string first $path $timing_paths $end]
        set end   [expr [string first $next_path $timing_paths $start+1] - 1]

        if { $end < 0 } { set end $string_len }
        
        set paths_arr($i) [string range $timing_paths $start $end]

    }
    
    
    set table {}
    set new_rpt ""
    foreach id [lsort -real -inc [array names paths_arr]] {
        
        set path $paths_arr($id)
#        if { [catch { set base_cells [regexp -all -inline $bc_pattern $path] } res] } { set base_cells {} }

        if { [catch { regexp " +Slack:= +(\[\\\-0-9\\\.\]+)" $path regres slack } res] || $res == 0 } { set slack "NA" }        
        if { [catch { regexp $dp_pattern $path regres dp } res] || $res == 0  } { set dp "NA" }                

        if { [catch { regexp " +Group: +(\[A-Za-z0-9_/\\\[\\\]\]+)"              $path regres group } res]              || $res == 0  } { set group "NA" }                
        if { [catch { regexp " +Startpoint: \\(\[R|F|L\]\\) +(\[A-Za-z0-9_/\\\[\\\]\]+)" $path regres startpoint } res] || $res == 0  } { set startpoint "NA" }                
        if { [catch { regexp " +Endpoint: \\(\[R|F|L\]\\) +(\[A-Za-z0-9_/\\\[\\\]\]+)"   $path regres endpoint } res]   || $res == 0  } { set endpoint "NA" }                        
        
        set startpoint_pattern [string map {"[" "." "]" "."} $startpoint]
        set endpoint_pattern   [string map {"[" "." "]" "."} $endpoint]        
        
        if { [catch { set clocks [regexp -all -inline " +Clock: \\(\[R|F|L\]\\) +(\[A-Za-z0-9_/\\\[\\\]\]+)"   $path  ] } res] || $res == 0  } { set clocks "NA" }                                
        lassign $clocks a start_clock b end_clock
        
#        set number_of_cells [llength $base_cells]
        set pins  {}
        set flops 0
        set logic 0
        set rpts  0
        set rc_delay 0
        set logic_delay 0
        set rpts_delay  0
        set flop_delay  0
        set avg_logic_delay 0
        set avg_rpts_delay  0  
        set dist 0    
        set prevx -1
        set prevy -1 
        set is_path false
#        if { $number_of_cells > 0 } { 

            foreach line [split $path "\n"] { 
#   puts "-1: $line"
                if { [regexp "Net has unmapped pin" $line] || [regexp "Endpoint" $line] || ![regexp "unmapped" $line] && ![regexp $bc_pattern $line] && ![regexp "\(arrival\|port\)" $line] && ![regexp $endpoint_pattern $line] } { continue }
#   puts "0: $line"                
                if { [regexp "hpin" $line] } { continue }

                set spline [split [string trim [regsub -all " +" $line " "] " "] " "]

                lassign $spline pin bc edge fo cap trans derate delay arrival loc flags 
                
                if { $pin == "$startpoint" } { set is_path true ; set prev_arrival $arrival }
                if { !$is_path } { continue }
                
                lassign [split [string map {"(" "" ")" ""} $loc] ","] x y
                lappend pins $pin
                
                if { $prevx > 0 } {
                    set dist [expr $dist + abs($x - $prevx) + abs($y - $prevy)]
                }
#   puts "1: $line"
                if { $delay == "-" } { set delay 0 }
                
                if { ![regexp "unmapped" $bc] && ( ($program == "genus" && $cap != "-" && $trans != "-" && $bc != "(arrival)") || ($program == "not_genus" && $cap != "-" && $trans != "-" && $bc != "(arrival)" && $fo == "-" ) ) \
                   || [regexp "unmapped" $bc] && (  $program == "genus" && $cap != "-" && $trans != "-" && $bc != "(arrival)")} {
                    
                    if { [regexp "unmapped" $bc] } { 
                        set lc $bc
                    } elseif { $program != "genus" } { 
                        set lc [get_db base_cells $bc] 
                    } else { 
                        set lc [index_collection [get_lib_cells $bc] 0] 
                    }
#   puts "2 --- : $line"
                    if { [regexp "unmapped" $bc] && ![regexp "_flop" $bc] } { incr logic ; set logic_delay [expr $logic_delay + $arrival - $prev_arrival] ; continue }        

                    if { ![regexp "unmapped" $bc] && ( [get_db $lc .is_buffer] || [get_db $lc .is_inverter] ) } { 
#   puts "3 --- $logic --- BUFINV : $line"
                        incr rpts 
                        set rpts_delay [expr $rpts_delay + $arrival - $prev_arrival]
                    } elseif { [regexp "_flop" $bc] || ![regexp "unmapped" $bc] && ![get_db $lc .is_integrated_clock_gating] && ( [get_db $lc .is_flop] || [get_db $lc .is_memory] || [get_db $lc .is_macro] ) } { 
#   puts "3 --- $logic --- FLOP : $line"
                        incr flops 
                        set flop_delay [expr $flop_delay + $arrival - $prev_arrival]                        
                    } else { 
#   puts "3 --- $logic --- LOGIC : $line"
                        incr logic 
                        set logic_delay [expr $logic_delay + $arrival - $prev_arrival]
                    }
                    


                } else {
                    set rc_delay [expr $rc_delay + $arrival - $prev_arrival]
                }
                
                set prevx $x
                set prevy $y
                set prev_arrival $arrival 
                
#                puts "$line $rpts_delay $logic_delay $rc_delay $flop_delay"
                                            
            }
            
            if { $logic > 0 } { set avg_logic_delay [expr $logic_delay/$logic] } 
            if { $rpts > 0  } { set avg_rpts_delay  [expr $rpts_delay/$rpts]   } 
            set cells_delay [expr $logic_delay + $rpts_delay + $flop_delay]
            set d_err       [expr {$dp > 0 ?  (1.0*$dp-$cells_delay - $rc_delay)/$dp : 0.0 }]

            set sn  "NA"
            set sna "NA"
            set ll  "NA"
            set lla "NA"
            set ln  "NA"
            set lna "NA"
            set ul  "NA"
            set ula "NA"
            set un  "NA"
            set una "NA"
            set en  "NA"
            set ena "NA"

            set cells [get_db -uniq [get_cells -quiet -of [get_pins -quiet $pins]] -if .obj_type==inst&&.is_flop==false&&.is_black_box==false&&.is_macro==false]

            if { [llength $cells] > 0 && [llength [get_db $cells .base_cell]] == [llength $cells] } {
                redirect garbage { set vt_res [be_report_cells_vt -cells [get_cells $cells] -return] } 
                set sn  [lindex [lindex $vt_res 0] 4]
                set sna [lindex [lindex $vt_res 0] 3]
                set ll  [lindex [lindex $vt_res 1] 4]
                set lla [lindex [lindex $vt_res 1] 3]
                set ln  [lindex [lindex $vt_res 2] 4]
                set lna [lindex [lindex $vt_res 2] 3]
                set ul  [lindex [lindex $vt_res 3] 4]
                set ula [lindex [lindex $vt_res 3] 3]
                set un  [lindex [lindex $vt_res 4] 4]
                set una [lindex [lindex $vt_res 4] 3]
                set en  [lindex [lindex $vt_res 5] 4]
                set ena [lindex [lindex $vt_res 5] 3]

            }

#        }
        
        set line [list $id $group $slack [expr $logic + $rpts] $logic $rpts "[format "%.2f" $dist]" $start_clock $startpoint $end_clock $endpoint ]    
        lappend table $line
        
        append new_rpt "$path"
        append new_rpt "Path Summary:
        Logic       :=    $logic                             
      Buf/Inv       :=    $rpts  
      
Total Dist          :=    [format "%.2f" $dist]

Total RC   Delay    :=    [format "%.3f" $rc_delay]
Total Cell Delay    :=    [format "%.3f" $cells_delay]
Total Logic Delay   :=    [format "%.3f" [expr $logic*$avg_logic_delay]]
Total Buf/Inv Delay :=    [format "%.3f" [expr $rpts*$avg_rpts_delay]]

Avg Logic Delay     :=    [format "%.3f" $avg_logic_delay]
Avg Buf/Inv Delay   :=    [format "%.3f" $avg_rpts_delay ]

Cell+RC delay Error (%):  [format "%.2f" [expr 100*$d_err]]%

SN                  :=    $sn
LL                  :=    $ll
LN                  :=    $ln
UL                  :=    $ul
UN                  :=    $un
EN                  :=    $en

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n\n"        
    }
    
    return [list $table $new_rpt]

}


proc be_parse_timing_paths_file { timing_paths_file } {

    global PROJECT
#    if { [info exists ${PROJECT}] } { set proj $${PROJECT} } else { set proj [lindex [split [pwd] "/"] end-3] }
    
    if { [regexp "snpsn" $PROJECT] } {
	    puts "-I- process is snps 5nm"
        set bc_pattern "(HDB\[A-Z\]+06_\[A-Z0-9_\]+) |(sacrls\[a-z0-9\]+) "
    } elseif { [regexp "brcm|inext|nextcore|nxt080" $PROJECT] } {
	    puts "-I- process is brcm 5nm"
        set bc_pattern "(F6\[A-Z\]+\[A-Z\]\[A-Z\]_\[A-Z0-9_\]+) |(M5SRF\[A-Z0-9\]) "
    } else {       
        set bc_pattern "DOOMED_TO_FAIL"
    }

    if { [get_db program_short_name] == "genus" } {
        set program "genus"
        set dp_pattern " +Data Path:\- +(\[\\\-0-9\\\.\]+)"
    } else {
        set program "not_genus"
        set dp_pattern " +Data Path:\\\+ +(\[\\\-0-9\\\.\]+)"
    }


    array unset paths_arr 
    set start 0
    set end   0
    set string_len [string length $timing_paths]
    for {set i 1} { $end != $string_len } { incr i } {

        set path      "Path $i"    
        set next_path "Path [expr $i + 1]"
        set start [string first $path $timing_paths $end]
        set end   [expr [string first $next_path $timing_paths $start+1] - 1]

        if { $end < 0 } { set end $string_len }
        
        set paths_arr($i) [string range $timing_paths $start $end]

    }
    
    
    set table {}
    set new_rpt ""
    foreach id [lsort -real -inc [array names paths_arr]] {
        
        set path $paths_arr($id)
#        if { [catch { set base_cells [regexp -all -inline $bc_pattern $path] } res] } { set base_cells {} }

        if { [catch { regexp " +Slack:= +(\[\\\-0-9\\\.\]+)" $path regres slack } res] || $res == 0 } { set slack "NA" }        
        if { [catch { regexp $dp_pattern $path regres dp } res] || $res == 0  } { set dp "NA" }                

        if { [catch { regexp " +Group: +(\[A-Za-z0-9_/\\\[\\\]\]+)"              $path regres group } res]              || $res == 0  } { set group "NA" }                
        if { [catch { regexp " +Startpoint: \\(\[R|F|L\]\\) +(\[A-Za-z0-9_/\\\[\\\]\]+)" $path regres startpoint } res] || $res == 0  } { set startpoint "NA" }                
        if { [catch { regexp " +Endpoint: \\(\[R|F|L\]\\) +(\[A-Za-z0-9_/\\\[\\\]\]+)"   $path regres endpoint } res]   || $res == 0  } { set endpoint "NA" }                        
        
        set startpoint_pattern [string map {"[" "." "]" "."} $startpoint]
        set endpoint_pattern   [string map {"[" "." "]" "."} $endpoint]        
        
        if { [catch { set clocks [regexp -all -inline " +Clock: \\(\[R|F|L\]\\) +(\[A-Za-z0-9_/\\\[\\\]\]+)"   $path  ] } res] || $res == 0  } { set clocks "NA" }                                
        lassign $clocks a start_clock b end_clock
        
#        set number_of_cells [llength $base_cells]
        set flops 0
        set logic 0
        set rpts  0
        set rc_delay 0
        set logic_delay 0
        set rpts_delay  0
        set flop_delay  0
        set avg_logic_delay 0
        set avg_rpts_delay  0  
        set dist 0    
        set prevx -1
        set prevy -1 
        set is_path false
#        if { $number_of_cells > 0 } { 

            foreach line [split $path "\n"] { 
#   puts "-1: $line"
                if { [regexp "Net has unmapped pin" $line] || [regexp "Endpoint" $line] || ![regexp "unmapped" $line] && ![regexp $bc_pattern $line] && ![regexp "\(arrival\|port\)" $line] && ![regexp $endpoint_pattern $line] } { continue }
#   puts "0: $line"                
                if { [regexp "hpin" $line] } { continue }

                set spline [split [string trim [regsub -all " +" $line " "] " "] " "]

                lassign $spline pin bc edge fo cap trans derate delay arrival loc flags 
                
                if { $pin == "$startpoint" } { set is_path true ; set prev_arrival $arrival }
                if { !$is_path } { continue }
                
                lassign [split [string map {"(" "" ")" ""} $loc] ","] x y
                
                if { $prevx > 0 } {
                    set dist [expr $dist + abs($x - $prevx) + abs($y - $prevy)]
                }
#   puts "1: $line"
                if { $delay == "-" } { set delay 0 }
                
                if { ![regexp "unmapped" $bc] && ( ($program == "genus" && $cap != "-" && $trans != "-" && $bc != "(arrival)") || ($program == "not_genus" && $cap != "-" && $trans != "-" && $bc != "(arrival)" && $fo == "-" ) ) \
                   || [regexp "unmapped" $bc] && (  $program == "genus" && $cap != "-" && $trans != "-" && $bc != "(arrival)")} {
                    
                    if { [regexp "unmapped" $bc] } { 
                        set lc $bc
                    } elseif { $program != "genus" } { 
                        set lc [get_db base_cells $bc] 
                    } else { 
                        set lc [index_collection [get_lib_cells $bc] 0] 
                    }
#   puts "2 --- : $line"
                    if { [regexp "unmapped" $bc] && ![regexp "_flop" $bc] } { incr logic ; set logic_delay [expr $logic_delay + $arrival - $prev_arrival] ; continue }        

                    if { ![regexp "unmapped" $bc] && ( [get_db $lc .is_buffer] || [get_db $lc .is_inverter] ) } { 
#   puts "3 --- $logic --- BUFINV : $line"
                        incr rpts 
                        set rpts_delay [expr $rpts_delay + $arrival - $prev_arrival]
                    } elseif { [regexp "_flop" $bc] || ![regexp "unmapped" $bc] && ![get_db $lc .is_integrated_clock_gating] && ( [get_db $lc .is_flop] || [get_db $lc .is_memory] || [get_db $lc .is_macro] ) } { 
#   puts "3 --- $logic --- FLOP : $line"
                        incr flops 
                        set flop_delay [expr $flop_delay + $arrival - $prev_arrival]                        
                    } else { 
#   puts "3 --- $logic --- LOGIC : $line"
                        incr logic 
                        set logic_delay [expr $logic_delay + $arrival - $prev_arrival]
                    }
                    


                } else {
                    set rc_delay [expr $rc_delay + $arrival - $prev_arrival]
                }
                
                set prevx $x
                set prevy $y
                set prev_arrival $arrival 
                
#                puts "$line $rpts_delay $logic_delay $rc_delay $flop_delay"
                                            
            }
            
            if { $logic > 0 } { set avg_logic_delay [expr $logic_delay/$logic] } 
            if { $rpts > 0  } { set avg_rpts_delay  [expr $rpts_delay/$rpts]   } 
            set cells_delay [expr $logic_delay + $rpts_delay + $flop_delay]
            set d_err       [expr {$dp > 0 ?  (1.0*$dp-$cells_delay - $rc_delay)/$dp : 0.0 }]
#        }
        
        set line [list $id $group $slack [expr $logic + $rpts] $logic $rpts "[format "%.2f" $dist]" $start_clock $startpoint $end_clock $endpoint ]    
        lappend table $line
        
        append new_rpt "$path"
        append new_rpt "Path Summary:
        Logic       :=    $logic                             
      Buf/Inv       :=    $rpts  
      
Total Dist          :=    [format "%.2f" $dist]

Total RC   Delay    :=    [format "%.3f" $rc_delay]
Total Cell Delay    :=    [format "%.3f" $cells_delay]
Total Logic Delay   :=    [format "%.3f" [expr $logic*$avg_logic_delay]]
Total Buf/Inv Delay :=    [format "%.3f" [expr $rpts*$avg_rpts_delay]]

Avg Logic Delay     :=    [format "%.3f" $avg_logic_delay]
Avg Buf/Inv Delay   :=    [format "%.3f" $avg_rpts_delay ]

Cell+RC delay Error (%):  [format "%.2f" [expr 100*$d_err]]%

#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------\n\n\n"        
    }
    
    return [list $table $new_rpt]

}


proc be_report_nets_resources { out_file {update_nets_length false} {nets ""} } {

    if { $nets == "" } {
        set nets [get_nets -hier ]
    } else {
        set nets [get_db nets -if { ! .wires=="" } ]
    }

    if { $update_nets_length } {
        puts "-I- Calculate nets length"
        ory_calc_net_length $nets
    }

    puts "-I- Print nets resources to $out_file"
    redirect $out_file { t $nets be_net_length be_detailed_net_length }

}


::parseOpt::cmdSpec be_report_timing_buckets {
    -help "Report longest-logic-levels paths"
    -opt    {
            {-optname file        -type string   -default ""       -required 0 -help "be_report_timing_summary file to parse"}
            {-optname from        -type string   -default ""       -required 0 -help "Report timing from"}
            {-optname to          -type string   -default ""       -required 0 -help "Report timing to"}
            {-optname max_paths   -type integer  -default 20000    -required 0 -help "Max number of paths for report timing"}
            {-optname nworst      -type integer  -default 10       -required 0 -help "Max number of paths per endpoint"}            
            {-optname group       -type string   -default ""       -required 0 -help "Max number of paths per endpoint"}                        
            {-optname level       -type integer  -default 999      -required 0 -help "Levels of hierarchy to group by"}                        
            {-optname min_th      -type integer  -default 1        -required 0 -help "Min number of paths per bucket"}                        
            {-optname bus_comp    -type boolean  -default true     -required 0 -help "Compress ports to busses"}                                    
            {-optname sort_by     -type integer  -default 1        -required 0 -help "1 - TNS, 2 - WNS, 3 - FEP, 4 - SlackPerPath..."}                        
            {-optname output      -type string   -default ""       -required 0 -help "File name"}                                                
    }
}

proc be_report_timing_buckets { args } {

	if { ! [::parseOpt::parseOpt be_report_timing_buckets $args] } { return 0 }
    
    if { $opt(-file) == "" } {    
        set file "summary_for_bucket_report.rpt"
        set cmd "be_report_timing_summary -output $file -max_slack 0"
        
        if {$opt(-from) != ""     } { append cmd " -from $opt(-from)"}
        if {$opt(-to) != ""       } { append cmd " -to $opt(-to)"}
        if {$opt(-max_paths) != ""} { append cmd " -max_paths $opt(-max_paths)"}
        if {$opt(-nworst) != ""   } { append cmd " -nworst $opt(-nworst)"}
        if {$opt(-group) != ""    } { append cmd " -group $opt(-group)"}
        
        puts "-I- Eval: $cmd"
        if { [eval $cmd] == -7 } { return }
        
    } else {
        set file $opt(-file)
    }

#    set file reports/syn.rpt
    
    puts "-I- Parsing paths"
    
    set fp [open $file r]
    set fd [read $fp]
    close $fp
        
    set level $opt(-level)
    
    array unset bkt_arr 
    
    foreach line [lrange [split $fd "\n"] 2 end] {
        
        if { $line == "" } { continue }
        
        set spline [split [regsub -all " +" $line ""] "|"]
        lassign $spline id group slack cells logic rpts dist fromclk from toclk to  

        set spfrom [split $from "/"]
        set spto   [split $to   "/"]
        
        if { [llength $spfrom] == 1 } {
            set from_name [string map {"{" "" "}" ""} $spfrom]
            if { $opt(-bus_comp) } { 
            	set from_name [regsub "\\\[\[0-9\]+\\\]" $from_name "[*]"]
                set from_name [regsub -all "_\[0-9\]+_"  $from_name "_*_"]
                set from_name [regsub -all "\[0-9\]+_"   $from_name "*_"]                
                set from_name [regsub -all "_\[0-9\]+"   $from_name "_*"]
            }                                
        } elseif { [llength $spfrom] <= [expr $level + 1]  } {
            set from_name "[join [lrange $spfrom 0 [llength $spfrom]-3] "/"]/*"
        } else {
            set from_name "[join [lrange $spfrom 0 $level-1] "/"]/*"
        }
        
        if { [llength $spto] == 1 } {
            set to_name [string map {"{" "" "}" ""} $spto]
            if { $opt(-bus_comp) } { 
            	set to_name [regsub "\\\[\[0-9\]+\\\]" $to_name "[*]"]
                set to_name [regsub -all "_\[0-9\]+_"  $to_name "_*_"]
                set to_name [regsub -all "\[0-9\]+_"   $to_name "*_"]                
                set to_name [regsub -all "_\[0-9\]+"   $to_name "_*"]
            }                                
        } elseif { [llength $spto] <= [expr $level + 1]  } {
            set to_name "[join [lrange $spto 0 [llength $spto]-3] "/"]/*"
        } else {
            set to_name   "[join [lrange $spto 0 $level-1] "/"]/*"
        }        
        
        set bucket_name "$from_name To $to_name"      
        
        lappend bkt_arr($bucket_name) [list $group $slack $cells $logic $rpts $dist]
                
    }
    
    set id 0
    set table {}
    foreach bucket_name [array names bkt_arr] {
        
        set paths $bkt_arr($bucket_name)
        set fep   0
        set group [lindex [lindex $paths 0] 0]
        
        set from "" ; set to ""
        if { [catch {regexp "(.*) To (.*)" $bucket_name res from to} catch_res] } { set from NA ; set to NA }

        set slacks { 0 }
        set cells  { 0 }
        set logics { 0 }
        set rpts   { 0 }
        set dists  { 0 }
        foreach path $paths { 
            
            set slack [lindex $path 1] 
            if { $slack <=0 } {
                lappend slacks $slack
                incr fep
            } else {
                continue
            }
            
            lappend cells  [lindex $path 2] 
            lappend logics [lindex $path 3] 
            lappend rpts   [lindex $path 4] 
            lappend dists  [lindex $path 5]                                                 
        }
        
        if { $fep < $opt(-min_th)   } { continue }
        if { $opt(-group) != "" && $group != $opt(-group) } { continue }
        
        set tns          [lsum $slacks]
        set wns          [lindex [lsort -real -inc $slacks] 0]
        
        set total_cells  [lsum $cells]
        set total_logics [lsum $logics]
        set total_rpts   [lsum $rpts]
        set total_dists  [lsum $dists]
        
        set avg_slack  [expr 1.0 * $tns          / $fep]
        set avg_cells  [expr 1.0 * $total_cells  / $fep]        
        set avg_logics [expr 1.0 * $total_logics / $fep]        
        set avg_rpts   [expr 1.0 * $total_rpts   / $fep]        
        set avg_dists  [expr 1.0 * $total_dists  / $fep]                                

        
        set line [list $group $tns $wns $fep $avg_slack $avg_cells $avg_logics $avg_rpts $avg_dists $from $to ]
        lappend table $line
        
        incr id

    }
    
    set sb $opt(-sort_by)
   	set sorted_table [lsort -index 1 -real -inc $table ]
    
    if { $sb == 1 || $sb == 2 || $sb == 4 } {
    	set sorted_table [lsort -index $sb -real -inc $sorted_table ]
    } elseif { $sb >= 3 && $sb <= 8 } {
    	set sorted_table [lsort -index $sb -real -dec $sorted_table ]    
    } else {
        set sorted_table [lsort -index $sb $sorted_table ]     
    }
    
    set table_format [list "%s" "%.3f" "%.3f" "%s" "%.3f" "%.3f" "%.3f" "%.3f" "%.3f" "%s" "%s"]
    set header [list Group TNS WNS FEP SlackPerPath CellsPerPath LogicPerPath RptsPerPath DistPerPath From To]
    
    rls_table -table $sorted_table -header $header -format $table_format -breaks -spac

}



proc _be_convert_reports_to_bash_mail { subject headline err_sum recipient {attachments {}} } {

    set file_name "./[pid]_send_mail.bs"
    set err_sum_html ${err_sum}.html


    ############################
    # Construct bash mail sender
    ############################    
    set fp [open $file_name w]
    
    puts $fp "#!/bin/bash"
    
    set attach_string ""
#    if { $attachments != {} } {
#        set attach_string "-a [regsub " " [join $attachments " "] " -a "]"
#    }
    
    set cmd_line "cat \"${err_sum}.html\" | mailx -r BE_Run_Summary@nextsilicon.com -s \"$subject \$(echo -e \\\\\\nContent-Type: text/html)\" $recipient"    
    
    puts $fp $cmd_line 
    
    close $fp
    
    
    #########################
    # Convert err_sum to html
    #########################
    if { ![file exists $err_sum] } { puts "-E- No <STAGE>_err.sum exists" ; file delete $file_name ; return -1 }
    set fp [open $err_sum r]
    set fd [read $fp]
    close $fp
    
    set is_error false    
    set error_lines ""
    set warng_lines ""
    set other_lines ""
    set style_start    ""
    set style_end      " "                
    
    set   fp [open ${err_sum}.html w]
    puts $fp  "<html><body>"
    
    foreach line [split $headline "\n"] {
        if { [regexp "^\\\-W\\\- " $line res] } { 
            puts $fp  "<h2 style=\"color:DarkRed;\">$line</h2>"        
        } else {
            puts $fp  "<h2 style=\"color:DarkBlue;\">$line</h2>"
        }
    }
    puts $fp  "<pre>"
    foreach line [split $fd "\n"] {      
#      set new_line "$line "

            
      if { [regexp "ERROR" $line] || [regexp "Error" $line] } {
#        set new_line "<b style=\"color:DarkRed;\">$line</b>" 
#        append error_lines "$new_line"
         set style_start "<b style=\"color:DarkRed;\">"
         set style_end   "</b>"
      } elseif { [regexp "WARNING" $line] || [regexp "Warning" $line] } {
#        set new_line "<b style=\"color:DarkRed;\">$line</b>" 
#        append error_lines "$new_line"
         set style_start "<b style=\"color:Orange;\">"
         set style_end   "</b>"
      } elseif { [regexp "INFO" $line] || [regexp "Info" $line] } {
#        set new_line "<b style=\"color:DarkRed;\">$line</b>" 
#        append error_lines "$new_line"
         set style_start "<b style=\"color:DarkGreen;\">"
         set style_end   "</b>"
      } else {

      }
      
      puts $fp "$style_start$line$style_end"
    }

    puts  $fp  "<html></body></pre>"    
    close $fp
    
    exec chmod 755 $file_name
    exec $file_name    
    file delete $file_name
}


proc be_report_messages { {file ""} {waivers {}} } {
    
    if { [get_db program_short_name] == "innovus" } { set cmd "report_messages " } { set cmd "report_messages -include -all" }
    
    redirect -var res {eval $cmd}
    
    # Normalize Genus report messages

    if { [get_db program_short_name] == "genus" } {
        set table {}
        set new_res [regsub -all "\\|\|\\--+" $res ""]
        foreach line [lrange [split $new_res "\n"] 3 end] {
            if { $line == "" } { continue }
            set tline [regsub " " $line ""]
            if { [string range $tline 0 0] == " " } { continue }
            set spline [split [string trim [regsub -all " +" $line " "] " "] " "]
            lassign $spline type severity count rest
            set desc [join [lrange $spline 3 end] " "]
            lappend table [list $severity $type $count $desc]
        }
        set header {Severity ID Count Summary}
        redirect -var res {rls_table -table $table -header $header -spac}
        set res [regsub -all "\\|" $res ""]
    }
    
    if { $waivers == {} } {         
        set waivers_file ./scripts/flow/waivers.csv
        if { [file exists $waivers_file] } {
            set fp [open $waivers_file r]
            set fd [read $fp]
            close $fp
            
            foreach line [lrange [split $fd "\n"] 1 end] { 
                set is_waiv false
                if { $line == "" } { continue }
                set spline [split $line ","]
                lassign $spline severity type is_waiv
                if { $is_waiv==TRUE || $is_waiv==true } { lappend waivers $type }
            }                                    
        } else { puts "-W- No waivers file found" }
    } else {
        puts "-I- Applying local waivers"
    }
    
    set filtered ""    
    foreach line [split $res "\n"] { 
        if { $line == "" } { append filtered "${line}\n" }
        set spline [split [regsub -all " +" $line " "] " "]
        lassign $spline severity type count rest
        if { [lsearch $waivers $type] > -1 } { continue }
        append filtered "${line}\n"
    }
    
    set waivers_line "-I- Waivered messages: [join $waivers " "]"
    append filtered $waivers_line
    
    if { $file != "" } {
        set fp [open $file w]
        puts $fp $filtered
        close $fp
    }
    
    puts $filtered

}

proc be_info_msg_waivers {{lim 80}} {
    set waivers_file ./scripts/flow/waivers.csv
    set table {}
    if { [file exists $waivers_file] } {
        set fp [open $waivers_file r]
        set fd [read $fp]
        close $fp

        foreach line [lrange [split $fd "\n"] 1 end] { 
            set is_waiv false        
            if { $line == "" } { continue }
            set spline [split $line ","]
            lassign $spline severity type is_waiv 
            if { [get_db messages $type] == "" } { continue }            
            if { [get_db program_short_name] == "genus" } { 
              set desc [string trim [join [get_db [get_db messages $type] .type] " "] "\n"]
            } else {
              set desc [string trim [join [lrange [split [get_db [get_db messages $type] .message] ":"] 1 end] " "] "\n"]
            }
            if { $lim > 0 } { if { [string length $desc] > $lim } { set desc "[string range $desc 0 $lim]..." } }
            lappend table [list $severity $type $is_waiv $desc]
        }
    } else { puts "-W- No waivers file found" }
    
    set header {Severity Type Is_waiver Desc}
    rls_table -table $table -header $header -spac -breaks
}

proc be_check_clock_cells_vt { {file ""} } {

    set all_edge  [all_registers -edge]
    set clock_sources [get_db [get_clocks ] .sources]
    if { $clock_sources == "" } {
        puts "-E- No clock sources found"
        set all_clock_cells {}
        return ""
    } else {
        set all_clock_cells [remove_from_collection [all_fanout -flat -from $clock_sources -only] [filter_collection $all_edge is_integrated_clock_gating_cell!=true]]            
    }
    puts "-I- Checking for clock cells VT percentage. (be_check_clock_cells_vt)"
    redirect -var res_table { set res [be_get_cells_by_vt $all_clock_cells] }
    puts $res_table 
    
    array unset res_arr
    array set res_arr [join $res " "]
    
    set rpt    "-I- Report clock cells VT\n"
    append rpt "-I- Total number of clock cells: [sizeof $all_clock_cells]\n"
    append rpt "\n$res_table"
    
    set vt_cts(brcmn3) "UN"
    set vt_cts(brcmn5) "UN"
    set vt_cts(smsngn4) "SLVT"
    
    set vt_groups_list [list brcmn3 brcmn5 tsmcn5 snpsn5 brcmn7 tsmcn7 snpsn7 smsngn4]    
 
    set node "n[get_db design_process_node]"
    set process ""
    foreach group [regexp -inline -all "\[a-zA-Z\]+$node" $vt_groups_list] {    
        foreach sub_group [array names vt_cts $group*] {            
            if { [llength [get_db base_cells $vt_cts($sub_group)]] > 0 } { set process $sub_group ; break }
        }
        if { $process != "" } { break }   
    }
    set cts_vt $vt_cts($sub_group)
    set uncells $res_arr($cts_vt)
    if { [llength $uncells] != [sizeof $all_clock_cells] } { 
        puts "-E- Not all clock cells are $cts_vt cells. (be_check_clock_cells_vt)"
        foreach vt [array names res_arr] {
            set vtcells $res_arr($vt)
            set length [llength $vtcells]
            append rpt "\n-I- Total number of $vt cells: $length\n--------------------------------\n"
            append rpt "[join $vtcells "\n"]\n"
        }
    } else {
        puts "-I- All clock cells UN cells. (be_check_clock_cells_vt)"
        append rpt "-I- All clock cells are UN cells."
    }
    
    if { $file == "" } { set file reports/check_clock_cells_vt.rpt }    
    
    set fp [open $file w]
    puts $fp $rpt
    close $fp
    
}

#####################
# Count Given Cells
#####################
proc _be_count_cells { {cells ""} } {

    if       { [get_db program_short_name] == "innovus" } {
        set is_phys true
        set is_macro_txt "is_macro_cell"
        set phys_cmd     "get_db insts -if {!.is_macro==true && .is_physical==true && .name!=FILL_*}"
    } elseif { [get_db program_short_name] == "genus" } {
        set is_macro_txt "is_macro"
        set phys_cmd     "get_db pcells"
    } 
    
    if { $cells == "" } { 
        set cells [get_cells -hier]
    } else {
        set cells [get_cells $cells]
    }

    
    set all_edge  [common_collection $cells [all_registers -edge]]
    set all_level [common_collection $cells [all_registers -level_sensitive]]
    set all_macros [common_collection $cells [get_cells -quiet -hier -filter "is_hierarchical == false && $is_macro_txt == true"]]
    set macro_cell_count [sizeof $all_macros]
    
    if { [get_db program_short_name] == "genus" } {
        # Leaf Instance count
        set leaf_cell_count [sizeof [common_collection $cells [get_cells -hier -filter "is_hierarchical == false && is_macro == false"]]]
#        # Physical Instance count      
#        set phys_cell_count [llength [get_db pcells]]
        # Sequential Instance Count    
        if { [sizeof $all_edge] > 0 } { set seq_cell_count  [sizeof  [filter_collection $all_edge  "is_integrated_clock_gating_cell==false"]] } { set seq_cell_count 0 }
        # Latch Instance Count    
        if { [sizeof $all_level] > 0 } { set latch_cell_count [llength [get_db $all_level -if .base_cell.is_integrated_clock_gating=="false"]] } { set latch_cell_count 0 }
        # Combinational Instance Count 
        set comb_cell_count  [sizeof [common_collection $cells [get_cells -hier -filter "is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false"]]]
        # Buffer Instance Area 
        set buff_cell_count  [sizeof [common_collection $cells [get_cells -hier -filter "is_hierarchical == false && is_buffer==true "]]]
        # Inverter Instance Area 
        set inv_cell_count   [sizeof [common_collection $cells [get_cells -hier -filter "is_hierarchical == false && is_inverter==true "]]]

        # Clock Tree Instance Count 
        if { [sizeof $all_edge] > 0 } {
            set clock_sources [get_db [get_clocks ] .sources]
            if { $clock_sources == "" } {
                puts "-W- No clock sources found"
                set all_clock_cells {}
            } else {
                set all_clock_cells [common_collection $cells [remove_from_collection [all_fanout -flat -from $clock_sources -only] [filter_collection $all_edge is_integrated_clock_gating_cell!=true]]]
            }
        } else {
             puts "Warning: no registers in the design"
#            set all_clock_cells [common_collection $cells [get_cells [get_clock_network_objects -clocks grid_clk -type cell]]
             set all_clock_cells ""
	
        }
        if { $all_clock_cells != {} } {
            set icg_cell_count  [sizeof [filter_collection $all_clock_cells " is_integrated_clock_gating_cell==true "]]
            set clock_inv       [sizeof [filter_collection $all_clock_cells " is_inverter==true "]]
            set clock_buf       [sizeof [filter_collection $all_clock_cells " is_buffer==true "]]
            set clock_logic     [sizeof [filter_collection $all_clock_cells " is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false "]]
        } else {
            set icg_cell_count 0
            set clock_inv      0
            set clock_buf      0
            set clock_logic    0
        }

    } else {
        # Leaf Instance count
        set leaf_cell_count [sizeof [common_collection $cells [get_cells -hier -filter "is_hierarchical == false && is_macro_cell == false"]]]
        # Sequential Instance Count    
        if { [sizeof $all_edge] > 0 } { set seq_cell_count  [sizeof  [filter_collection $all_edge  "is_integrated_clock_gating_cell==false"]] } { set seq_cell_count 0 }
        # Latch Instance Count    
        set latch_cell_count [llength [get_db $all_level -if .base_cell.is_integrated_clock_gating=="false"]]
        # Combinational Instance Count 
        set comb_cell_count  [sizeof [common_collection $cells [get_cells -hier -filter "is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false"]]]
        # Buffer Instance Area 
        set buff_cell_count  [sizeof [common_collection $cells [get_cells -hier -filter "is_hierarchical == false && is_buffer==true "]]]
        # Inverter Instance Area 
        set inv_cell_count   [sizeof [common_collection $cells [get_cells -hier -filter "is_hierarchical == false && is_inverter==true "]]]
        
        # Clock Tree Instance Count 
        if { [sizeof $all_edge] > 0 } {
            set all_clock_cells [common_collection $cells [remove_from_collection [get_clock_network_objects -clocks [get_clocks] -type cell] [filter_collection $all_edge is_integrated_clock_gating_cell!=true]]]
        } else {
             puts "Warning: no registers in the design"
#            set all_clock_cells [common_collection $cells [get_cells [get_clock_network_objects -clocks grid_clk -type cell]]
             set all_clock_cells ""
        }
        set icg_cell_count  [sizeof [filter_collection $all_clock_cells " is_integrated_clock_gating_cell==true "]]
        set clock_inv       [sizeof [filter_collection $all_clock_cells " is_inverter==true "]]
        set clock_buf       [sizeof [filter_collection $all_clock_cells " is_buffer==true "]]
        set clock_logic     [sizeof [filter_collection $all_clock_cells " is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false "]]

    }

    set rpt "Leaf Cell Count:          $leaf_cell_count 
Sequential Cell Count:    $seq_cell_count  
Latch Cell Count:         $latch_cell_count
Combinational Cell Count: [expr $comb_cell_count - [expr {$clock_logic eq "NA" ? 0 : $clock_logic}]]
Buffer Cell Count:        [expr $buff_cell_count - [expr {$clock_buf   eq "NA" ? 0 : $clock_buf}]]
Inverter Cell Count:      [expr $inv_cell_count  - [expr {$clock_inv   eq "NA" ? 0 : $clock_inv}]]
ICG Count:                $icg_cell_count  
Clock inverters:          $clock_inv
Clock Buffers:            $clock_buf
Clock Logic:              $clock_logic
"

    puts $rpt
}


proc be_sum_timing_paths_col { tps } {
    
    set table  {}
    set header {id slack cell_delay net_delay dist logic inv buf sn ll ln ul un en sp ep}
    set id 0
    
    foreach tp [get_db $tps] {
        
        set slack      [get_db $tp .slack]
        set sp         [get_db $tp .launching_point.name]
        set ep         [get_db $tp .capturing_point.name]
        set cell_delay [get_db $tp .path_cell_delay]
        set net_delay  [get_db $tp .path_net_delay]
        
        set cells  [get_cells -quiet [get_db [get_db -uniq [get_db [get_db -uniq $tp  .timing_points.pin] -if .obj_type==pin] .inst] -if .is_flop==false]]
        set logic  [sizeof [filter_collection $cells "is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false"]]
        set buf    [sizeof [filter_collection $cells "is_hierarchical == false && is_buffer==true "]]
        set inv    [sizeof [filter_collection $cells "is_hierarchical == false && is_inverter==true "]]
        
        set dist   [ory_get_points_dist [get_db $tp .timing_points.pin.location]]
        
        set sn  "NA"
        set sna "NA"
        set ll  "NA"
        set lla "NA"
        set ln  "NA"
        set lna "NA"
        set ul  "NA"
        set ula "NA"
        set un  "NA"
        set una "NA"
        set en  "NA"
        set ena "NA"

        if { [sizeof $cells] > 0 } {
            redirect garbage { set vt_res [be_report_cells_vt -cells $cells -return] }

            set sn  [lindex [lindex $vt_res 0] 4]
            set sna [lindex [lindex $vt_res 0] 3]
            set ll  [lindex [lindex $vt_res 1] 4]
            set lla [lindex [lindex $vt_res 1] 3]
            set ln  [lindex [lindex $vt_res 2] 4]
            set lna [lindex [lindex $vt_res 2] 3]
            set ul  [lindex [lindex $vt_res 3] 4]
            set ula [lindex [lindex $vt_res 3] 3]
            set un  [lindex [lindex $vt_res 4] 4]
            set una [lindex [lindex $vt_res 4] 3]
            set en  [lindex [lindex $vt_res 5] 4]
            set ena [lindex [lindex $vt_res 5] 3]
        }
        set new_line [list $id $slack $cell_delay $net_delay $dist $logic $inv $buf $sn $ll $ln $ul $un $en $sp $ep]
        lappend table $new_line
        incr id
        
    }
    
    rls_table -table $table -header $header -breaks -spac
    
}

## Accepts a timing summary file, and compress it to buckets
## Columns_action - ignore == do nothing, avg == calc avg, avg_sum == calc avg and sum into seperate columns, compress == bus_compress
#proc bucketize_timing_summary { rpt_file {delimiter "|"} \
#                              {colunmns_action_map "id ignore \
#                                                    slack avg_sum \
#                                                    cell_delay avg \
#                                                    net_delay avg \
#                                                    dist avg \
#                                                    logic avg \
#                                                    inv avg \
#                                                    buf avg \
#                                                    sn avg \
#                                                    ll avg \
#                                                    ln avg \
#                                                    ul avg \
#                                                    un avg \
#                                                    en avg \
#                                                    sp compress \
#                                                    ep compress"}} {
#    
#    if { ![file exists $rpt_file] } { puts "-E- File $rpt_file not exists" ; return -1 }
#    
#    set fp [open $rpt_file r]
#    set fd [split [read $fp] "\n"]
#    close $fp
#
#    array set col_ac_arr [split [regsub -all " +" $colunmns_action_map " "] " "]
#    
#    array unset col_id_arr 
#    set c 0
#    set i -1
#    foreach v [split [regsub -all " +" $colunmns_action_map " "] " "] {
#        incr i
#        if { [expr $i%2] } { continue }
#        set col_id_arr($c) $v
#        incr c                
#    }
#    
#    # Parse columns and actions
#    array unset res_arr
#    foreach col [array names col_ac_arr] {
#        set act $col_ac_arr($col)
#        if { $act == "ignore" } {
#            continue 
#        } elseif { $act == "avg" } {
#            set res_arr($col:avg) {}
#        } elseif { $act == "avg_sum" } {
#            set res_arr($col:avg) {}
#            set res_arr($col:sum) {}
#        } elseif { $act == "sum" } {
#            set res_arr($col:sum) {}
#        } elseif { $act == "compress" } {
#            set res_arr($col:compress) {}
#        }
#    }
#    
#    # Get compressed columns
#    
#    # Parse values into columns    
#    foreach line $fd {
#        
#        if { $line == "" || [regexp "\\-\\-\\-+" $line] } { continue }
#        
#        set spline [split $line $delimiter]
#        
#        set i 0
#        foreach v $spline {            
#            set col $col_id_arr($i)            
#            set act $col_ac_arr($col)
#            incr i
#            
#            set v [regsub -all " +" $v ""]
#            
#            if { $act == "ignore" } {
#                continue 
#            } elseif { $act == "avg" } {
#                lappend res_arr($col:avg) $v
#            } elseif { $act == "avg_sum" } {
#                lappend res_arr($col:avg) $v
#                lappend res_arr($col:sum) $v
#            } elseif { $act == "sum" } {
#                lappend res_arr($col:sum) $v
#            } elseif { $act == "compress" } {
#                lappend res_arr($col:compress) $v
#            }
#        }
#    }   
#    
#}
#
#
#
#

proc be_draw_hotspots { {num_of_hotspots 10} {keep 0} } {

    set PROC [lindex [info level 0] 0]

    global DESIGN_NAME STAGE

    if { !$keep } { gui_clear_highlight }

    set rpt_cong "reports/${DESIGN_NAME}.${STAGE}.${num_of_hotspots}_hotspot.summary"
    redirect $rpt_cong { report_congestion -hotspot -num_hotspot $num_of_hotspots }
    # reading report to variable, by lines
    set f [open $rpt_cong r] ; set f_data [split [read $f] \n] ; close $f

    set hdr_idx [lsearch $f_data "*hotspot bbox*hotspot score*"]

    for { set i 2 } { [expr $hdr_idx + $i] < [llength $f_data] } { incr i 2 } {
        set line [lindex $f_data [expr $hdr_idx + $i]]
        lassign [join $line] ~ ~ ~ ~ x0 y0 x1 y1 ~ scr
        if { ($x0 == "") && ($y1 == "") } { continue }
        set rct [create_gui_shape -layer my_lay -rect "$x0 $y0 $x1 $y1" -width 2]
        gui_highlight $rct -color [be_scale_green_red $scr]
    }
    
    gui_dim_foreground -light_level medium
    
    set_layer_preference violation -is_visible 0
    set_layer_preference node_layer -is_visible 0

    lassign [join [get_db [get_db designs] .bbox]] x0 y0 x1 y1
    set x [expr $x1 - $x0]
    set y [expr $y1 - $y0]

    set d 0.05

    gui_zoom -rect "[expr $x0 - $d*$x] [expr $y0 - $d*$y0] [expr $x1 + $d*$x] [expr $y1 + $d*$y]"
    deselect_obj -all
}


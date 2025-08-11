#!/usr/bin/tclsh

    puts "-I-  Preparing BE checklist ..."
     set pnr [lindex [ split  [exec pwd] "/" ] end]
     regsub "pnr" $pnr  "" prefix
     set WA [join [regsub "pnr.*" [split [exec pwd] "/"] ""] "/"]
     set block_name [lindex [split  [exec pwd] "/"] end-2]
     ###################################################################
     #                 results DirFor Grafana
     ###################################################################
       set dirname "$WA/$pnr/grafana"
       if {![file exist $dirname] == 1} {
  	       exec 	mkdir $WA/$pnr/grafana
       } 
     ###################################################################
     if {[info exists DESIGN_NAME]} {
        set design_name $DESIGN_NAME
     } else {
         set design_name [lindex [split [pwd] "/"] end-2]
     }
     
      if {([file exist $WA/$pnr/${design_name}_be_checklist_summary.csv]) && ([lindex $argv 0] != "init") && ([lindex $argv 0] != "all")} {
         # update the file:
         set OFILE [open  $WA/$pnr/${design_name}_be_checklist_summary.csv a]
      } else {
         set OFILE [open  $WA/$pnr/${design_name}_be_checklist_summary.csv w]

      }


#===============================================================================
#                                PROCs
#===============================================================================
   source     $WA/$pnr/scripts/procs/common/be_mails.tcl

#=================================================
     # find the project
     proc find_proj {{WA} {pnr} {stage}} {
      global PROJECT  
      set proj "NA"
      if { [info exists PROJECT] } {
	     set proj $PROJECT
      } else {
        find_latest_log $stage
        if {[check_grep latest_${stage}.log "${stage}"] } {
           set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
           if {[check_grep ${WA}/${pnr}/log/$log_file "set PROJECT" ]} {
              set proj [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "PROJECT" | egrep -m 1 "set PROJECT"] end]
           }
        } else {
           set proj [lindex [split [pwd] "/"] end-3]
        }
      }
      return $proj
    };# find_proj  
     #=================================================
    proc find_latest_log {{stage}} {
        if {[catch {exec ls log/  | egrep do_${stage}.log | egrep -v "errSum"}] == 0 } {
          set fo [open fusion.log w]
          set fo_log [open latest_${stage}.log w]
          puts  $fo "[exec ls log/ | egrep "${stage}\.log" | egrep -v "errSum"]"
          close $fo
          puts $fo_log "[exec tail -n 1 fusion.log]"
          close $fo_log
          exec rm fusion.log
       } else {
         exec touch latest_${stage}.log
       }
     };# find_latest_log
    #=================================================
     proc check_grep {{test_file} {grep_this} {index ""}} {
       set status_grep 0
       if {$index != ""} {
           if {[file exist $test_file]} {
              if {[regexp {\.gz} $test_file ]} {
                 if {([catch {exec zcat $test_file | egrep -w $grep_this }] == 0) || ([catch {exec zcat $test_file | egrep $grep_this }] == 0)} {
                    if {([catch {lindex [exec zcat $test_file | egrep -w $grep_this] $index}] == 0) || ([catch {lindex [exec zcat $test_file | egrep $grep_this] $index}] == 0)} { 
                       set status_grep 1
                    }
                 } 
              } else {
                 if {([catch {exec cat $test_file | egrep -w $grep_this }] == 0) || ([catch {exec cat $test_file | egrep $grep_this }] == 0)} {
                    if {([catch {lindex [exec cat $test_file | egrep -w $grep_this] $index}] == 0) || ([catch {lindex [exec cat $test_file | egrep $grep_this] $index}] == 0)} { 
                     set status_grep 1
                  }
                 } 
              }
           }
        } elseif {$index == ""} {
           if {[file exist $test_file]} {
              if {[regexp {\.gz} $test_file ]} {
                 if {([catch {exec zcat $test_file | egrep -w $grep_this }] == 0) || ([catch {exec zcat $test_file | egrep $grep_this }] == 0)} {
                    set status_grep 1
                 } 
              } else {
                 if {([catch {exec cat $test_file | egrep -w $grep_this }] == 0) || ([catch {exec cat $test_file | egrep $grep_this }] == 0)} {
                     set status_grep 1
                 } 
              }
           }
        }

          return $status_grep
      };#check_grep
     #=================================================
     proc transposed_column_to_row {line} {
       set fot [open transposed_data.rpt w]
       foreach elem  $line  {
         if {![regexp {\"} $elem]} {
            puts -nonewline $fot "[regsub -all "{|}" $elem ""],"
         } else {
            set count_print 1
            foreach elem1 [split $elem ":"] {
              if {$count_print < [llength [split $elem ":"]]} { 
                  puts $fot  "[regsub -all "{|}" $elem1 ""]"
              } else {
                puts -nonewline $fot "[regsub -all "{|}" $elem1 ""],"
              }
            incr count_print 
            }
         }
       } 
       close $fot
     };# transposed_column_to_row 
     #=================================================
     proc send_the_transposed_file {{design_name} {file} {stage}} {
        set fi [open ${file} r]
        set tmp_output_file "tmp_${design_name}_${stage}.csv"
        set output_file "grafana/${design_name}_${stage}.csv"
        set line1 ""
        set line2 ""
        set line3 ""
        while {[gets $fi line]>=0} {
           lappend line1 [lindex [split $line ","] 0]
           lappend line2 [lindex [split $line ","] 1]
           lappend line3 [lindex [split $line ","] 2]
        }  
        set row1 [transposed_column_to_row $line1]
        if {[file exist transposed_data.rpt]} {
           exec cat transposed_data.rpt > $tmp_output_file
        }
        exec echo "" >> $tmp_output_file

        set row2 [transposed_column_to_row $line2]
        if {[file exist transposed_data.rpt]} {
           exec cat transposed_data.rpt >> $tmp_output_file
        }
        exec echo "" >> $tmp_output_file
        
        set row3 [transposed_column_to_row $line3]
        if {[file exist transposed_data.rpt]} {
           exec cat transposed_data.rpt >> $tmp_output_file 
        }
        #exec cat $tmp_output_file | egrep -v ",,,,.*,," > $output_file
        exec cat $tmp_output_file | egrep -v ",,,,.*" > $output_file
         exec rm $tmp_output_file

     };# send_the_transposed_file
     #=================================================
      #=================================================
     # Host name
     proc host_name {{WA} {pnr} {stage}} {
        set fo [open host.rpt w]
        find_latest_log $stage
        if {[check_grep latest_${stage}.log "${stage}"] } {
           set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
           if {[check_grep ${WA}/${pnr}/log/$log_file "host:" ]} {
              puts $fo "Host name,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "host:"] 5],${WA}/${pnr}/log/$log_file"
           } else {
              puts $fo "Host name,NA check,${WA}/${pnr}/log/$log_file"
           }   
        } else {
           puts $fo "Host name,NA check,${WA}/${pnr}/log/*${stage}.log"
        }   
        exec rm latest_${stage}.log
       close $fo
       
     };#host_name
     #=================================================
     proc fusion_version {{WA} {pnr} {stage}} {
      set fo [open fusion_version.rpt w]
           find_latest_log $stage
           if {[check_grep latest_${stage}.log "${stage}"] } {
              set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
              if {[check_grep ${WA}/${pnr}/log/$log_file "Version " 1 ]} {
                 puts $fo "fusion version,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Version " | head -n 1] 1],${WA}/${pnr}/log/$log_file"
              } else {
                 puts $fo "fusion version,NA check,${WA}/${pnr}/log/$log_file"
              }   
           } else {
              puts $fo "fusion version,NA check,${WA}/${pnr}/log/*${stage}.log" 
           }   
           
        exec rm latest_${stage}.log
        close $fo
     };# fusion_version 

     #=================================================
      ## check EFFORT:
     proc effort {{WA} {pnr} {stage}} {
       set fo [open effort.rpt w]
       find_latest_log $stage
       if {[check_grep latest_${stage}.log "${stage}"] } {
          set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
          if {[check_grep ${WA}/${pnr}/log/$log_file "set.*EFFORT"]} {
              exec egrep "set.*EFFORT" log/do_${stage}.log.full > effort
              puts $fo "EFFORT,[lindex [exec head -n 1 effort] 2],$log_file"
              puts $fo "VT_EFFORT,[lindex [exec tail -n 1 effort] 2],$log_file"
              exec rm effort
          } else {
             puts $fo "EFFORT, NA check,$log_file "
             puts $fo "VT_EFFORT, NA check,$log_file  "
          }
          
       } else {
          puts $fo "EFFORT, NA check,${WA}/${pnr}/log/*${stage}.log "
          puts $fo "VT_EFFORT, NA check,${WA}/${pnr}/log/*${stage}.log  "
      }
    close $fo
   };# effort 
 #=================================================
 # log scan:
   proc logscan {{log}} {
       set log_file $log

       set fp [open $log_file r]
       #set fd [read $fp]
       #close $fp
       
       set exclude_phrase  "^\@file\|^Suppress \|^Un-suppress \|puts +\"\-E\-\|puts +\"\-W\-\|\\\|Error \|\\\|Warning \|^ERROR     \|^INFO "
       set error_phrase   "ERROR\|Error\|\-E\-"
       set warning_phrase "WARN\|WARNING\|Warning\|\-W\-"
       
       set errors   {}
       set warnings {}
       while {[gets $fp line]>=0} {
           if       { [regexp $exclude_phrase  $line res] } {
               continue        
           } elseif { [regexp $error_phrase  $line res] } {
               lappend errors   $line
           } elseif { [regexp $warning_phrase $line res] } {
               lappend warnings $line
           } 
       }
       
       
       # Parse errors
       array unset err_arr
       foreach line $errors {
           if       { [regexp "\\\-E\\\-" $line res] } {
               lappend err_arr(flow_related) $line
           } elseif { [regexp "INTERNAL ERROR" $line res] } {
               lappend err_arr(INTERNAL_ERROR) $line        
           } elseif { [regexp "\\\*\\\*ERROR: +.(\[A-Z\]+\\\-\[0-9\]+).:" $line res err_type] } {
               lappend err_arr($err_type) $line        
           } elseif { [regexp " \\\[(\[A-Z\]+\\\-\[0-9\]+)\\\] " $line res err_type] } {
               lappend err_arr($err_type) $line        
           }    
       }
       
       # Parse warnings
       array unset wrn_arr
       foreach line $warnings {
           if       { [regexp "\\\-W\\\-" $line res] } {
               lappend wrn_arr(flow_related) $line
           } elseif { [regexp "\\\*\\\*WARN: +.(\[A-Z\]+\\\-\[0-9\]+).:" $line res err_type] } {
               lappend wrn_arr($err_type) $line 
           } elseif { [regexp "\\\#WARNING +(\[A-Z\]+\\\-\[0-9\]+) " $line res err_type] } {
               lappend wrn_arr($err_type) $line 
           } elseif { [regexp "\\\WARNING +(\[A-Z\]+\\\-\[0-9\]+) " $line res err_type] } {
               lappend wrn_arr($err_type) $line 
           } elseif { [regexp " \\\[(\[A-Z\]+\\\-\[0-9\]+)\\\] " $line res err_type] } {
               lappend wrn_arr($err_type) $line        
           }
       }
              
           
       set file_name $log_file.errSum
       set fp [open $file_name w]

       set table {}
       foreach err [array names err_arr] {    	
           set line [list $err [llength $err_arr($err)]]
           lappend table $line        
       }
       puts $fp "[format %-15s "Error Type"]| Count"
       puts $fp "[string repeat - 15]|------"
       foreach line $table {
           puts $fp "[format %-15s [lindex $line 0]]| [lindex $line 1]"
       }
       
       puts $fp ""
       set table {}    
       foreach err [array names wrn_arr] {    	
           set line [list $err [llength $wrn_arr($err)]]
           lappend table $line        
       }    
       
       puts $fp "[format %-15s "Warning Type"]| Count"
       puts $fp "[string repeat - 15]|------"
       foreach line $table {
           puts $fp "[format %-15s [lindex $line 0]]| [lindex $line 1]"
       }
       
       puts $fp ""
       puts $fp "#------------------------------------------"
       puts $fp "# Error Messages - Total of [llength $errors]"
       puts $fp "#------------------------------------------"        
       puts $fp [join $errors "\n"]
       puts $fp ""

       puts $fp "#------------------------------------------"
       puts $fp "# Warning Messages - Total of [llength $warnings]"
       puts $fp "#------------------------------------------"      
       puts $fp [join $warnings "\n"]
       puts $fp ""
       
       close $fp              
    
    };# logscan


proc analyzed_log_scan {{stage} } {
     # find the latest <stage>.log
     find_latest_log $stage
     set fo [open log_scan_results w]
     set ft [open log_scan_results_for_transposed w]
     if {[check_grep latest_${stage}.log "${stage}"]} {
         logscan log/[exec cat latest_${stage}.log]
           if {[file exist log/[exec cat latest_${stage}.log].errSum]} {
             #set fo [open log_scan_results w]
            # set ft [open log_scan_results_for_transposed w]
              foreach num {1 2} {
                 if {$num==1} {
                   puts $fo "log scan results for stage $stage,\"[regsub "#" [exec cat log/[exec cat latest_${stage}.log].errSum | egrep "Error Messages"] ""] "
                   puts -nonewline $ft "log scan results for stage $stage,\"[regsub "#" [exec cat log/[exec cat latest_${stage}.log].errSum | egrep "Error Messages"] ""]: "
                 } else {
                   puts $fo "[regsub "#" [exec cat log/[exec cat latest_${stage}.log].errSum | egrep "Warning Messages"] ""]\",[exec pwd]/log/[exec cat latest_${stage}.log].errSum" 
                   puts $ft "[regsub "#" [exec cat log/[exec cat latest_${stage}.log].errSum | egrep "Warning Messages"] ""]\",[exec pwd]/log/[exec cat latest_${stage}.log].errSum" 
                 }
              }
          } else {
             puts $fo "log scan results for stage $stage, NA check,[exec pwd]/log/${stage}.log.errSum "
             puts $ft "log scan results for stage $stage, NA check,[exec pwd]/log/${stage}.log.errSum "
          }
     } else {
       puts $fo "log scan results for stage $stage, NA check,[exec pwd]/log/*${stage}.log* "
       puts $ft "log scan results for stage $stage, NA check,[exec pwd]/log/*${stage}.log* "
     }
       close $fo
       close $ft
   };# analyzed_log_scan

 #=================================================
  proc report_from_be_qor {{stage} {WA} {pnr} } {
      set fo [open reports/${stage}/report_from_be_qor.csv w]
      set ft [open reports/${stage}/report_from_be_qor_for_transpose.csv w]
      if {[file exist $WA/$pnr/reports/${stage}/${stage}.be.qor]}  {
         # cell density
         if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "Pure STD Cell Density" 4 ] } {
              puts $fo "cell density,[lindex [ exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Pure STD Cell Density"] 4],$WA/$pnr/reports/${stage}/${stage}.be.qor"
              puts $ft "cell density,[lindex [ exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Pure STD Cell Density"] 4],$WA/$pnr/reports/${stage}/${stage}.be.qor"
           } else {
              puts $fo "cell density,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts $ft "cell density,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
           }  
         # HotSpot Score, 
         if {$stage != "route"} {
           if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "Hotspot Score" 3 ]} {
                puts $fo "HotSpot Score,[lindex [ exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Hotspot Score"] 3],$WA/$pnr/reports/${stage}/${stage}.be.qor"
                puts $ft "HotSpot Score,[lindex [ exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Hotspot Score"] 3],$WA/$pnr/reports/${stage}/${stage}.be.qor"
             } else {
                puts $fo "HotSpot Score,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
                puts $ft "HotSpot Score,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
             } 
          } 
         #  report congestion
         if {$stage != "route"} {
           if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "H overflow" 3 ] } {
                set h_overflow [lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "H overflow"] 3]
                set v_overflow [lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "V overflow"] 3]
                puts $fo "report congestion,\" $h_overflow H "
                puts -nonewline $ft "report congestion,\" $h_overflow H "
                puts $fo "$v_overflow V\",$WA/$pnr/reports/${stage}/${stage}.be.qor"
                puts $ft "$v_overflow V\",$WA/$pnr/reports/${stage}/${stage}.be.qor"
             } else {
                puts $fo "report congestion,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
                puts $ft "report congestion,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
             }  
          } 
              # power
         if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "Total Internal Power" 3 ] } {
               puts $fo "Total Internal Power,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Total Internal Power"] 3] mW,$WA/$pnr/reports/${stage}/${stage}.be.qor"
               puts $fo "Total Switching Power,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Total Switching Power"] 3] mW,$WA/$pnr/reports/${stage}/${stage}.be.qor"
               puts $fo "Total Leakage Power,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Total Leakage Power"] 3] mW,$WA/$pnr/reports/${stage}/${stage}.be.qor"
               puts $fo "Total Power,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Total Power"] 2] mW,$WA/$pnr/reports/${stage}/${stage}.be.qor"
               puts $ft "Total_Internal_Power,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Total Internal Power"] 3] mW,$WA/$pnr/reports/${stage}/${stage}.be.qor"
               puts $ft "Total_Switching_Power,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Total Switching Power"] 3] mW,$WA/$pnr/reports/${stage}/${stage}.be.qor"
               puts $ft "Total_Leakage_Power,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Total Leakage Power"] 3] mW,$WA/$pnr/reports/${stage}/${stage}.be.qor"
               puts $ft "Total_Power,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Total Power"] 2] mW,$WA/$pnr/reports/${stage}/${stage}.be.qor"
           } else {
              puts $fo "Total Internal Power,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts $fo "Total Switching Power,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts $fo "Total Leakage Power,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts $fo "Total Power,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts $ft "Total_Internal_Power,NA"
              puts $ft "Total_Switching_Power,NA"
              puts $ft "Total_Leakage_Power,NA"
              puts $ft "Total_Power,NA"
           }  
              # Cell count
         if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "Leaf Cell Count" end]} {
               puts $fo "Leaf Cell Count,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Leaf Cell Count"] end],$WA/$pnr/reports/${stage}/${stage}.be.qor"
               puts $ft "Leaf_Cell_Count,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Leaf Cell Count"] end]"
           } else {
              puts $fo "Leaf Cell Count,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts $ft "Leaf_Cell_Count,NA"
           }  
           # how many FF in the design:
         if {[check_grep ${WA}/${pnr}/reports/${stage}/${stage}.be.qor "FF Bit Count" end]} {
             puts  $fo "FF Bit Count,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/${stage}.be.qor |  egrep "FF Bit Count"] end], ${WA}/${pnr}/reports/${stage}/${stage}.be.qor"
             puts  $ft "FF_Bit_Count,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/${stage}.be.qor |  egrep "FF Bit Count"] end]"
         } else {
             puts  $fo "FF Bit Count,NA check, ${WA}/${pnr}/reports/${stage}/${stage}.be.qor"
             puts  $ft "FF_Bit_Count,NA"
         }
         # how many Gated , in compile
        if {$stage=="compile"} { 
         if {[check_grep ${WA}/${pnr}/reports/${stage}/${stage}.be.qor "Gated registers" end]} {
             puts  $fo "Gated registers,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/${stage}.be.qor |  egrep "Gated registers"] end], ${WA}/${pnr}/reports/${stage}/${stage}.be.qor"
             puts  $ft "Gated_registers,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/${stage}.be.qor |  egrep "Gated registers"] end]"


         } else {
             puts  $fo "Gated registers,NA check, ${WA}/${pnr}/reports/${stage}/${stage}.be.qor"
             puts  $ft "Gated_registers,NA"
         }
         # how many UN-Gated , in compile
         if {[check_grep ${WA}/${pnr}/reports/${stage}/${stage}.be.qor "Ungated registers" ]} {
             puts  $fo "Ungated registers,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/${stage}.be.qor |  egrep "Ungated registers"] end], ${WA}/${pnr}/reports/${stage}/${stage}.be.qor"
             puts  $ft "Ungated_registers,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/${stage}.be.qor |  egrep "Ungated registers"] end]"


         } else {
             puts  $fo "Ungated registers,NA check, ${WA}/${pnr}/reports/${stage}/${stage}.be.qor"
             puts  $ft "Ungated_registers,NA"
         }

       }
         #
            # how many ICG in the design:
         if {[check_grep ${WA}/${pnr}/reports/${stage}/${stage}.be.qor "ICG Count:" end]} {
             puts  $fo "ICG count,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/${stage}.be.qor |  egrep "ICG Count:"] end], ${WA}/${pnr}/reports/${stage}/${stage}.be.qor"
             puts  $ft "ICG_count,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/${stage}.be.qor |  egrep "ICG Count:"] end]"
         } else {
             puts  $fo "ICG count,NA check, ${WA}/${pnr}/reports/${stage}/${stage}.be.qor"
             puts  $ft "ICG_count,NA"
         }

              # AREA
         if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "Leaf Cell Area" 3 ]} {
               puts $fo "Leaf Cell Area,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Leaf Cell Area"] 3] um^2,$WA/$pnr/reports/${stage}/${stage}.be.qor"
               puts $ft "Leaf_Cell_Area,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Leaf Cell Area"] 3]"
           } else {
              puts $fo "Leaf Cell Area,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts $ft "Leaf_Cell_Area,NA"
           }  
              # %VT cells count
         if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "^ULVT" ]} {
           puts $fo "report VT cells,\""
           puts -nonewline $ft "report_VT_cells,\":"
           foreach vt {LVT ULVT EVT } {
            exec cat $WA/$pnr/reports/${stage}/${stage}.be.qor | egrep "^${vt}" > tmp_vt.rpt
            set fi [open tmp_vt.rpt r]
            while {[gets $fi line]>=0} {
              if {![regexp {ULVT\*} $line]} {
                puts $fo "[lindex $line 0]   [lindex $line 4]"
                puts -nonewline $ft "[lindex $line 0]   [lindex $line 4]:"
              }
            } 
           }
           puts $fo "\", $WA/$pnr/reports/${stage}/${stage}.be.qor"
           puts $ft "\""
           exec rm tmp_vt.rpt

         } else {
              puts $fo "report VT cells,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
           #   puts $ft "report_VT_cells,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts -nonewline $ft "report_VT_cells,\":"
              foreach v {LVT LVTLL ULVT ULVTLL EVT} {
                 puts  -nonewline $ft "${v} NA:"
              }
              puts $ft "\""
           }  

                 # %VT Area
         if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "^ULVT" ]} {
           puts $fo "report VT area,\""
           puts -nonewline $ft "report_VT_area,\":"
           foreach vt {LVT ULVT EVT } {
            exec cat $WA/$pnr/reports/${stage}/${stage}.be.qor | egrep "^${vt}" > tmp_vt.rpt
            set fi [open tmp_vt.rpt r]
            while {[gets $fi line]>=0} {
              if {![regexp {ULVT\*} $line]} {
                puts $fo "[lindex $line 0]   [lindex $line end]"
                puts -nonewline $ft "[lindex $line 0]   [lindex $line end]:"
              }
            } 
           }
           puts $fo "\", $WA/$pnr/reports/${stage}/${stage}.be.qor"
           puts $ft "\""
           exec rm tmp_vt.rpt

         } else {
              puts $fo "report VT area,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
           #   puts $ft "report_VT_area,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts -nonewline $ft "report_VT_area,\":"
              foreach v {LVT LVTLL ULVT ULVTLL EVT} {
                 puts  -nonewline $ft "${v} NA:"
              }
              puts $ft "\""
           }  


          # MBIT
         if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "Flip-flop cells banking ratio" ]} {
             puts  $fo "Multibit Conversion,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Flip-flop cells banking ratio"] end],$WA/$pnr/reports/${stage}/${stage}.be.qor"
             puts  $ft "Multibit_Conversion,[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "Flip-flop cells banking ratio"] end]"
        } else {
            puts $fo "Multibit Conversion,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
            puts $ft "Multibit_Conversion,NA"
         }  
              # Setup Timing
           if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "reg2reg" 2 ]} {
            set print_count 1
           foreach type {reg2reg  reg2cgate reg2out in2reg in2out "all "} {
            if {[check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "$type" 2 ]} {
              if {$print_count==1} {
                 puts $fo "Setup Timing(WNS/TNS/VP),\"[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 6] "
                 puts -nonewline $ft "Setup Timing(WNS/TNS/VP),\"[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 6]: "
                 incr print_count
              } else {
                puts $fo "[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 6]"
                puts -nonewline $ft "[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "$type" | head -n 1] 6]:"
              }
           } 
         } 
          puts $fo "\",$WA/$pnr/reports/${stage}/${stage}.be.qor"
          puts $ft "\""
              
          } else {
              puts $fo "Setup Timing,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts $ft "Setup Timing,NA"
          }  

         # Hold Timing
        if {[regexp {cts|route} $stage]} {
            if {([check_grep $WA/$pnr/reports/${stage}/${stage}.be.qor "reg2reg" 2 ]) && ([ llength [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "reg2reg"]] == 14)} {
                 puts $fo "Hold Timing(WNS/TNS/VP),[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 6],$WA/$pnr/reports/${stage}/${stage}.be.qor "
                 puts $ft "Hold Timing(WNS/TNS/VP),[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 6],$WA/$pnr/reports/${stage}/${stage}.be.qor "
            
          } else {
              puts $fo "Hold Timing,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
              puts $ft "Hold Timing,NA check,$WA/$pnr/reports/${stage}/${stage}.be.qor "
          }  
        }
        
      }  else {
            puts $fo "Main file ${stage}.be.qor.rpt,NA check, $WA/$pnr/reports/${stage}/${stage}.be.qor.rpt"
            puts $ft "Main file ${stage}.be.qor.rpt,NA check, $WA/$pnr/reports/${stage}/${stage}.be.qor.rpt"
      }
     
        close $fo  
        close $ft  
     
  };# report_from_be_qor  
 #=================================================
 proc report_timing_path_groups {{WA} {pnr} {stage} {block_name}} {
          if {[file exist reports/${stage}/report_from_be_qor_for_transpose.csv]} {
                 set fo [open reports/${stage}/report_group_path.csv w]
                 set fi [open reports/${stage}/report_from_be_qor_for_transpose.csv r]
                 while {[gets $fi line]>=0} {
                    if {[regexp {Setup Timing} $line]} {
                       foreach tm [split [regsub -all {\"} [lindex [split [regsub [lindex $line 0] $line ""] ","] 1] {}] ":"] {
                          if {$tm != ""} {
                           puts $fo "[lindex [split $tm "/"] 0 0],[lindex [split $tm "/"] 0 1],[lindex [split $tm "/"] 1],[lindex [split $tm "/"] 2]"
                        }
                       }
                    }
                  }
                  close $fi
               } else {
                  foreach group "reg2reg reg2cgate reg2out in2reg in2out all" {
                     puts $fo "$group,NA,NA,NA,NA,NA,NA"
                  }
               }
              if {[file exist $WA/$pnr/reports/${stage}/user_group_path_summary.csv]} {
                 set fi_u [open $WA/$pnr/reports/${stage}/user_group_path_summary.csv r]
                  while {[gets $fi_u line]>=0} {
                     puts $fo "$line"
                  }
              }
     close $fo
     # Generate the group-path table
     set GPFILE [open $WA/$pnr/grafana/${block_name}_group_path_${stage}.csv w]
     puts $GPFILE "Date,Time,Work_Area,Block_Name,PROJECT,STAGE,Group_Name,WNS,TNS,VP"
     set first_print 1
     set fi [open reports/${stage}/report_group_path.csv r]
     while {[gets $fi line]>=0} {
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fid [open date.rpt r]
     while {[gets $fid line_id]>=0} {
          if {[lindex [split [lindex $line_id 3] ":"] 0] < 12} {   
            puts -nonewline $GPFILE "[lindex $line_id 1] [lindex $line_id 2] [lindex $line_id end],"
            puts -nonewline $GPFILE "[lindex $line_id 3] AM,"
         } elseif {[lindex [split [lindex $line_id 3] ":"] 0]==12} {
            puts -nonewline $GPFILE "[lindex $line_id 1] [lindex $line_id 2] [lindex $line_id end],"
            puts -nonewline $GPFILE "[lindex $line_id 3] PM,"
         } else {
            puts -nonewline $GPFILE "[lindex $line_id 1] [lindex $line_id 2] [lindex $line_id end],"
            puts -nonewline $GPFILE "[expr [lindex [split [lindex $line_id 3] ":"] 0] -12]:[lindex [split [lindex $line_id 3] ":"] 1]:[lindex [split [lindex $line_id 3] ":"] 2] PM,"
         }
       } 
        exec rm date.rpt
        set proj [find_proj $WA $pnr $stage]
        puts -nonewline $GPFILE "${WA}/${pnr},$block_name,$proj,$stage,"
        puts $GPFILE "$line"
     }
     close $GPFILE


    };# report_timing_path_groups
 #=================================================
  proc clock_list {{WA} {pnr} {stage}} {
    set clk_list ""
    if {[check_grep  ${WA}/${pnr}/reports/${stage}/report_clocks.rpt "virtual_" ]} {
       exec cat ${WA}/${pnr}/reports/${stage}/report_clocks.rpt |  egrep -v virtual_ | egrep "\{|\}" > tmp 
       set fi [open tmp r]
       while {[gets $fi line]>=0} {
         lappend clk_list [lindex $line 0]
       }
       exec rm tmp
    } 
    return $clk_list
  };# clock_list
 #=================================================
#=================================================================================================
#                                           END PROCs
#==================================================================================================

if { ([lindex $argv 0] == "init") || ([lindex $argv 0] == "all")} {
     #===============================================================================
     #                                Init
     #===============================================================================
     set FFILE [open $WA/$pnr/${design_name}_for_transposed_data_1.csv w] 
     set stage "init"
     puts $OFILE "STAGE,        init"
     puts $OFILE "DATE,[exec date]"
     puts $OFILE "Work Area,${WA}/${pnr}"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         puts $FFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $FFILE "Time,[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         puts $FFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $FFILE "Time,[lindex $line 3] PM"
      } else {
         puts $FFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $FFILE "Time,[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	 } 
     set proj [find_proj $WA $pnr "init"]
     exec rm date.rpt
     puts $OFILE "PROJECT,$proj"
     puts $FFILE "Work_Area,${WA}/${pnr}"
     puts $FFILE "Block_Name,$block_name"
     puts $FFILE "PROJECT,$proj"
     puts $FFILE "STAGE,init"
      # host name:
     host_name $WA $pnr $stage
     if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $FFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
         exec rm host.rpt
     } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $FFILE "Host_name,NA"
     }
     
     # fusion version
      fusion_version $WA $pnr $stage
    if {[check_grep  fusion_version.rpt "fusion version" ]} {
         puts $OFILE "[ exec cat fusion_version.rpt | head -n 1]"
         puts $FFILE "fusion_version,[lindex [ split [exec cat fusion_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "fusion version,NA check,fusion_version.rpt"
         puts $FFILE "fusion_version,NA"
    }

     ## check EFFORT:
     effort $WA $pnr $stage
     if {[check_grep  effort.rpt "VT_EFFORT" ]} {
         puts $OFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1],[lindex [split [exec cat effort.rpt | head -n 1] ","] 2]"
         puts $OFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1],[lindex [split [exec cat effort.rpt | head -n 1] ","] 2]"
         puts $FFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $FFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         exec rm effort.rpt
    } else {
         puts $OFILE "EFFORT,NA check,effort.rpt"
         puts $OFILE "VT_EFFORT,NA check,effort.rpt"
         puts $FFILE "EFFORT,NA"
         puts $FFILE "VT_EFFORT,NA"
    }

    #================================================
     # link to scripts version:
      if {[regexp {\/} [exec ls -lt scripts | head -n1]]} {
         puts $OFILE "scripts version,[ lindex [exec ls -lt scripts | head -n1] end]"
         puts $FFILE "scripts_version,[ lindex [exec ls -lt scripts | head -n1] end]"
     } else {
         puts $OFILE "scripts version,NA Local"
         puts $FFILE "scripts_version,NA"
     }
     #================================================
     # check contains of scripts_local 
      set fo [open tmp w]
      puts $fo "[exec ls  scripts_local]"
      close $fo
      set fi [open tmp r]
      puts $OFILE "Check these files under scripts_local/,\""
      puts -nonewline $FFILE "files_under_scripts_local,\""
      while {[gets $fi line]>=0} {
        if {![regexp {mmmc_results|supplement_setup} $line]} {
             puts  $OFILE "$line"
             puts  -nonewline $FFILE "$line:"
           }
        }
        puts  $OFILE "\", $WA/$pnr/scripts_local"
        puts $FFILE "\" "
        puts $FFILE "files_under_scripts_local_input,$WA/$pnr/scripts_local"
      exec rm tmp
     #================================================
    # need to activate file ./scripts/bin/parse_args.csh, to generate the default values
    #  --> .tmp_user_inputs.tcl
    exec ./scripts/bin/parse_args.csh fusion
    puts $OFILE "Results compare user_inputs.tcl TO default setting (.tmp_user_inputs.tcl),\""
    puts -nonewline $FFILE "compare_user_inputs_2_default_setting,\""
    if {([file exist $WA/$pnr/.tmp_user_inputs.tcl]) && ([file exist $WA/$pnr/user_inputs.tcl])} {
     # set fi_ref [open $WA/$pnr/.tmp_user_inputs.tcl r]
      set fi_cmp [open $WA/$pnr/user_inputs.tcl r]
      while {[gets $fi_cmp line]>=0} {
        if {[regexp {set} $line]} {
           if {[catch {exec cat $WA/$pnr/.tmp_user_inputs.tcl | egrep -w [lindex $line 1] }] == 0} {
              set line_ref [exec cat $WA/$pnr/.tmp_user_inputs.tcl | egrep -w [lindex $line 1]] 
              if {[lindex $line 2] != [lindex $line_ref 2]} {
                 # if value is different
                 if {![regexp {ARGO|K8S|WIN|TERM_OPTIONS|VNC_SERVER|VNC_DISPLAY|LABEL|DESC|MEMORY|TAIL|CPU|STAGES} [lindex $line 1]]} {
                   puts $OFILE "[lindex $line 1] [lindex $line 2]" 
                   puts -nonewline $FFILE "[lindex $line 1] [lindex $line 2]:" 
                 } 
              }
   
           } else {
              # parameter doesn't exsit in default
                  puts $OFILE "[lindex $line 1] [lindex $line 2]"  
                  puts -nonewline $FFILE "[lindex $line 1] [lindex $line 2]:"  
   
           }
   
        }
      };# while fi_cmp...
      puts $OFILE "\", $WA/$pnr/user_inputs.tcl"
      puts $FFILE "\""
      puts $FFILE "compare_user_inputs_2_default_setting_input, $WA/$pnr/user_inputs.tcl"
   
     } else {
      puts $OFILE "Results compare user_inputs.tcl TO default setting (.tmp_user_inputs.tcl),Can't find  $WA/$pnr/user_inputs.tcl ||  $WA/$pnr/.tmp_user_inputs.tcl"
      puts $FFILE "compare_user_inputs_2_default_setting,NA"
     }
  
 

    #================================================
    # links to RTL, locations 
     #  NOTE :
     #  Activate be_checklist general, after reading filelist
     set stage "init"
     find_latest_log $stage
     if {[check_grep latest_${stage}.log "${stage}"] } {
        set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
         if {[check_grep ${WA}/${pnr}/log/$log_file "path_to_filelist_location" ]} {
           set filelist [lindex [exec cat log/do_init.log.full | egrep "path_to_filelist_location" | tail -n 1] end]
           set fi [open $filelist r]
           puts $OFILE "link to RTL files,\"$filelist"
           puts -nonewline $FFILE "link_to_RTL_files,\"$filelist:"
           while {[gets $fi line]>=0} {
             if {[regexp {\-f} $line]} { 
               puts $OFILE "[lindex $line 1]"
               puts -nonewline $FFILE "[lindex $line 1]:"
             }
           }
            puts $OFILE "\",$filelist"
            puts $FFILE "\""

        } else {
           puts $OFILE "link to RTL files, NA check, $log_file "
           puts $FFILE "link_to_RTL_files,NA"
        }
     } else {
           puts $OFILE "link to RTL files, NA check,${WA}/${pnr}/log/*${stage}.log  "
           puts $FFILE "link_to_RTL_files,NA"
    }


     #================================================
     # link to ndm, for STD & MEMs/Macros/...
       if {[check_grep $WA/$pnr/scripts/setup/setup.${proj}.tcl  "\.ndm" ]} {
        exec cat $WA/$pnr/scripts/setup/setup.${proj}.tcl | egrep "\.ndm" > tmp
        exec sed -i {s/\\//g} tmp
        set fi [open tmp r]
        set first_puts 1
        while {[gets $fi line]>=0}  {
          if {$first_puts==1} {
             puts  $OFILE "link to STD NDMs dirs,\"$line"
             incr first_puts 
          } else {
             puts  $OFILE "$line"
          }
        }
         puts  $OFILE "\", $WA/$pnr/scripts/setup/setup.${proj}.tcl"
         exec rm tmp
     } else {
        puts $OFILE "link to STD NDMs dirs, NA check ,  $WA/$pnr/scripts/setup/setup.${proj}.tcl "
     }
     # NDMs links for MEMs
      if {[check_grep $WA/inter/supplement_setup.tcl "\.ndm" ]} {
        if {[catch {exec cat $WA/inter/supplement_setup.tcl | egrep "\.ndm" }] == 0} {
           set list_of_paths ""
           exec cat $WA/inter/supplement_setup.tcl | egrep "\.ndm" > tmp
           exec sed -i {s/\\//g} tmp
           set fi [open tmp r]
           set first_puts 1
           while {[gets $fi line]>=0} {
             if {$first_puts==1} {
               puts $OFILE  "link to MACROs NDMs dir,\"$line"
               incr first_puts 
            } else {
               puts $OFILE "$line"
            }
           }
           puts  $OFILE "\", $WA/inter/supplement_setup.tcl"
     
        }
     } else {
          puts $OFILE "link to MACROs NDMs dir, NA check , $WA/inter/supplement_setup.tcl  "
     }

     #================================================
     # check for ports & macro placement
     if {[check_grep $WA/$pnr/reports/${stage}/report_unplaced_ports.rpt " ports" ]} {
        puts $OFILE "ports placement,[exec cat  $WA/$pnr/reports/${stage}/report_unplaced_ports.rpt | egrep " ports"],$WA/$pnr/reports/${stage}/report_unplaced_ports.rpt"
     } else {
        puts $OFILE "ports placement, NA check, $WA/$pnr/reports/${stage}/report_unplaced_ports.rpt"

     }

     if {[check_grep $WA/$pnr/reports/${stage}/report_macro_placement.rpt " macros" ]} {
        puts $OFILE "macro placement,[exec cat  $WA/$pnr/reports/${stage}/report_macro_placement.rpt | egrep " macros"],$WA/$pnr/reports/${stage}/report_macro_placement.rpt"
     } else {
        puts $OFILE "macro placement,NA check,$WA/$pnr/reports/${stage}/report_macro_placement.rpt"

     }
     #================================================
   # reports physical cells
    if {[file exist $WA/$pnr/reports/${stage}/reports_physical_cells.rpt]} {
       set first_puts 1
       set fi [open $WA/$pnr/reports/${stage}/reports_physical_cells.rpt r]
       while {[gets $fi line]>=0} {
         if {[regexp  {[A-Z]+} $line]} { 
           if {$first_puts==1} {
             puts $OFILE "physical cells,\"$line"
             puts $FFILE "[lindex $line 0],[lindex $line 1]"
             incr first_puts 
           } else {
             puts $OFILE "$line"
             puts $FFILE "[lindex $line 0],[lindex $line 1]"
           }
         }
       }
       puts $OFILE "\",$WA/$pnr/reports/${stage}/reports_physical_cells.rpt"
    } else {
       puts $OFILE "physical cells,NA check, $WA/$pnr/reports/${stage}/reports_physical_cells.rpt"

    }
    #================================================
    #  Check bonus cells (spare) - Need to Add !!!!!!
      puts $OFILE "bonus cells, NA (need to add this one) !!!!!"
      puts $FFILE "bonus_cells,NA"
    #================================================

   # report check timing
    if {[check_grep ${WA}/${pnr}/reports/${stage}/check_timing.rpt "  TCK-" ]} {
        exec cat ${WA}/${pnr}/reports/${stage}/check_timing.rpt | egrep "  TCK-" > ct.rpt
        set fi [open ct.rpt r]
           puts  $OFILE "check timing,\""
           while {[gets $fi line]>=0} {
              puts  $OFILE "$line"
           }
         puts  $OFILE "\",${WA}/${pnr}/reports/${stage}/check_timing.rpt"  
         exec rm ct.rpt 
     } else {
         puts  $OFILE "check timing,NA check, ${WA}/${pnr}/reports/${stage}/check_timing.rpt"
     }
 
  #================================================
  # log scan statistics 
    analyzed_log_scan $stage
        puts $OFILE "[exec cat log_scan_results]"
        puts $FFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $FFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed
    #----------------------------------------

   close $FFILE
 };# END Init/Floorplan
  #===============================================================================
  #                                Compile
  #===============================================================================
  if {([lindex $argv 0] == "compile") || ([lindex $argv 0] == "all")} {
     set CMFILE [open $WA/$pnr/${design_name}_for_transposed_data_2.csv w] 
     set stage "compile"
     puts $OFILE "STAGE,      compile"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         puts $CMFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $CMFILE "Time,[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         puts $CMFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $CMFILE "Time,[lindex $line 3] PM"
      } else {
         puts $CMFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $CMFILE "Time,[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	  }
     set proj [find_proj $WA $pnr "compile"]
     exec rm date.rpt
     puts $CMFILE "Work_Area,${WA}/${pnr}"
     puts $CMFILE "Block_Name,$block_name"
     puts $CMFILE "PROJECT,$proj"
     puts $CMFILE "STAGE,compile"
     # host name:
     host_name $WA $pnr $stage
     if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $CMFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
         exec rm host.rpt
     } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $CMFILE "Host_name,NA"
     }
     
     # fusion version
      fusion_version $WA $pnr $stage
    if {[check_grep  fusion_version.rpt "fusion version" ]} {
         puts $OFILE "[ exec cat fusion_version.rpt | head -n 1]"
         puts $CMFILE "fusion_version,[lindex [ split [exec cat fusion_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "fusion version,NA check,fusion_version.rpt"
         puts $CMFILE "fusion_version,NA"
    }

     ## check EFFORT:
       effort $WA $pnr $stage
     if {[check_grep  effort.rpt "VT_EFFORT" ]} {
         puts $OFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $OFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         puts $CMFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $CMFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         exec rm effort.rpt
    } else {
         puts $OFILE "EFFORT,NA check,effort.rpt"
         puts $OFILE "VT_EFFORT,NA check,effort.rpt"
         puts $CMFILE "EFFORT,NA"
         puts $CMFILE "VT_EFFORT,NA"
    }
     
     # report check timing
    if {[check_grep ${WA}/${pnr}/reports/${stage}/check_timing.rpt "  TCK-" ]} {
        exec cat ${WA}/${pnr}/reports/${stage}/check_timing.rpt | egrep "  TCK-" > ct.rpt
        set fi [open ct.rpt r]
           puts  $OFILE "check timing,\""
           while {[gets $fi line]>=0} {
              puts  $OFILE "$line"
           }
         puts  $OFILE "\",${WA}/${pnr}/reports/${stage}/check_timing.rpt"  
         exec rm ct.rpt 
     } else {
         puts  $OFILE "check timing,NA check, ${WA}/${pnr}/reports/${stage}/check_timing.rpt"
     }
 # calculate MEMs bits, and ~ the Number of transistors in the design
      if {[check_grep $WA/$pnr/reports/${stage}/preplace_count.rpt "MEMORYs"]} {
       set fi [open $WA/$pnr/reports/${stage}/preplace_count.rpt r] 
       set calculate_bits 0
       while {[gets $fi line]>=0} {
          if {([regexp {MEMORYs} $line]) && ([regexp {[A-Z]} [lindex [split $line ":"] 1]])} { 
            set line_to_work [lindex [split $line ":"] 1]
            set base_name [lindex $line_to_work 0]
            set num_of_mem [lindex $line_to_work 1] 
            if {[regexp {[0-9]+X[0-9]+} $line_to_work]} {
              set x [lindex [split [regexp -inline {[0-9]+X[0-9]+} $line_to_work] "X"] 0]
              set y [lindex [split [regexp -inline {[0-9]+X[0-9]+} $line_to_work] "X"] 1]
            } elseif {[regexp {[0-9]+x[0-9]+} $line_to_work]} {
              set x [lindex [split [regexp -inline {[0-9]+x[0-9]+} $line_to_work] "x"] 0]
              set y [lindex [split [regexp -inline {[0-9]+x[0-9]+} $line_to_work] "x"] 1]
            } else {
              set x 0
              set y 0 
            }

            set calculate_bits [expr ($x*$y*$num_of_mem) + $calculate_bits]
           }
         }
         puts $OFILE "Calculate the MEMs BITs,$calculate_bits,$WA/$pnr/reports/${stage}/preplace_count.rpt"
         puts $CMFILE "Calculate_MEMs_BITs,$calculate_bits"
         close $fi
       } else {
         puts $OFILE "Calculate the MEMs BITs,NA,$WA/$pnr/reports/${stage}/preplace_count.rpt"
         puts $CMFILE "Calculate_MEMs_BITs,NA"
       }
      # Calculate number of Transistors ~ Num Of STD * 6
       if {[check_grep $WA/$pnr/reports/${stage}/preplace_count.rpt "Leaf_Cells_Count"]} {
          set fi [open $WA/$pnr/reports/${stage}/preplace_count.rpt r] 
          while {[gets $fi line]>=0} {
             if {[regexp {Leaf_Cells_Count} $line]} {
              puts $OFILE "Calculate the number of transistors,[expr [lindex $line  2] * 6 ],$WA/$pnr/reports/${stage}/preplace_count.rpt "
              puts $CMFILE "Calculate_the_number_of_transistors,[expr [lindex $line  2] * 6 ]"
            }
           }
        } else {
         puts $OFILE "Calculate the number of transistors,NA check,$WA/$pnr/reports/${stage}/preplace_count.rpt"
         puts $CMFILE "Calculate_the_number_of_transistors,NA"
       }
     #================================================


      report_from_be_qor $stage $WA $pnr
     if {[file exist reports/${stage}/report_from_be_qor.csv]} {
       set fi_re [open reports/${stage}/report_from_be_qor.csv r]
        while {[gets $fi_re line]>=0} {
           puts $OFILE "$line"
        }
       exec rm reports/${stage}/report_from_be_qor.csv
     } else {
       puts $OFILE "report from qor, NA check, reports/${stage}/report_from_be_qor.csv  "
     }

     if {[file exist reports/${stage}/report_from_be_qor_for_transpose.csv]} {
       set fi_rt [open reports/${stage}/report_from_be_qor_for_transpose.csv r]
        while {[gets $fi_rt line]>=0} {
          if {[regexp {HotSpot} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CMFILE "HotSpot_Score,NA"
            } else {
               puts $CMFILE "HotSpot_Score,[lindex [split $line ","] 1]"
            }
           puts $CMFILE "HotSpot_Score_input,[lindex [split $line ","] 2]"
          }
          if {[regexp {cell density} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CMFILE "cell_density,NA"
            } else {
               puts $CMFILE "cell_density,[regsub -all {%} [lindex [split $line ","] 1] {} ]"
            }
          }
          if {[regexp {report congestion} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CMFILE "congestion_H,NA"
               puts $CMFILE "congestion_V,NA"
            } else {
               puts $CMFILE "congestion_H,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 0] {} ]"
               puts $CMFILE "congestion_V,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 2] {} ]"
            }
          }
          if {[regexp {Power} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CMFILE "[lindex [split $line ","] 0],NA"
            } else {
               puts $CMFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1 0]"
            }
          }

          if {[regexp {Multibit_Conversion|Leaf_Cell_Area|Leaf_Cell_Count|FF_Bit_Count|Gated_registers|Ungated_registers|ICG_count} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CMFILE "[lindex [split $line ","] 0],NA"
            } else {
               if {[regexp {Multibit_Conversion} $line]} {
                  puts $CMFILE "[lindex [split $line ","] 0],[regsub -all {%} [lindex [split $line ","] 1] {}]"
               } else {
                  puts $CMFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1]"
               }
            }
          }
          if {[regexp {report_VT_cells} $line]} {
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }
           if {[regexp {report_VT_area} $line]} {
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $CMFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }

          if {[regexp {Setup Timing} $line]} {
            foreach tm [regsub -all {\"} [split [lindex [split $line ","] 1] ":"] ""] {
               if {$tm!=""} {
                set i 0
                foreach case "wns tns vp" {
                   if {[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i] != ""} {
                     puts $CMFILE "[lindex $tm 0]_${case},[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i]"
                  } else {
                     puts $CMFILE "[lindex $tm 0]_${case},NA"
                  }
                   incr i
                }
              }
            }
          }

        }

        # generate timing table, per stage
        report_timing_path_groups $WA $pnr $stage $block_name
        exec rm reports/${stage}/report_from_be_qor_for_transpose.csv
     } else {
        puts $CMFILE "HotSpot_Score,NA"
        puts $CMFILE "HotSpot_Score_input,reports/${stage}/report_from_be_qor_for_transpose.csv"
        puts $CMFILE "cell_density,NA"
        puts $CMFILE "congestion_H,NA"
        puts $CMFILE "congestion_V,NA"
        puts $CMFILE "Total_Internal_Power,NA"
        puts $CMFILE "Total_Switching_Power,NA"
        puts $CMFILE "Total_Leakage_Power,NA"
        puts $CMFILE "Total_Power,NA"
        puts $CMFILE "Leaf_Cell_Count,NA"
        puts $CMFILE "Gated_registers,NA"
        puts $CMFILE "Ungated_registers,NA"
        puts $CMFILE "ICG_count,NA"
        puts $CMFILE "Leaf_Cell_Area,NA"
        puts $CMFILE "LVT_cells,NA"
        puts $CMFILE "LVTLL_cells,NA"
        puts $CMFILE "ULVT_cells,NA"
        puts $CMFILE "ULVTLL_cells,NA"
        puts $CMFILE "EVT_cells,NA"
        puts $CMFILE "LVT_area,NA"
        puts $CMFILE "LVTLL_area,NA"
        puts $CMFILE "ULVT_area,NA"
        puts $CMFILE "ULVTLL_area,NA"
        puts $CMFILE "EVT_area,NA"
        ## NEED to complite for all -->NA
        foreach group "reg2reg reg2cgate reg2out in2reg in2out" {
           foreach case "wns tns vp" {
              puts $CMFILE "${group}_$case,NA"

           }
        }
     }

  
  #===================================================
      # log scan statistics 
    analyzed_log_scan $stage
        puts $OFILE "[exec cat log_scan_results]"
        puts $CMFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $CMFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed
    #----------------------------------------
   close $CMFILE
 };# END Compile
  #===============================================================================
  ####===============================================================================
  ####                                Place
  ####===============================================================================
  if {([lindex $argv 0] == "place") || ([lindex $argv 0] == "all")} {
     set PFILE [open $WA/$pnr/${design_name}_for_transposed_data_3.csv w] 
     set stage "place"
     puts $OFILE "STAGE,      place"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         puts $PFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $PFILE "Time,[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         puts $PFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $PFILE "Time,[lindex $line 3] PM"
      } else {
         puts $PFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $PFILE "Time,[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	  }
     set proj [find_proj $WA $pnr "place"]
     exec rm date.rpt
     puts $PFILE "Work_Area,${WA}/${pnr}"
     puts $PFILE "Block_Name,$block_name"
     puts $PFILE "PROJECT,$proj"
     puts $PFILE "STAGE,place"
     # host name:
     host_name $WA $pnr $stage
     if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $PFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
         exec rm host.rpt
     } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $PFILE "Host_name,NA"
     }
     
     # fusion version
      fusion_version $WA $pnr $stage
    if {[check_grep  fusion_version.rpt "fusion version" ]} {
         puts $OFILE "[ exec cat fusion_version.rpt | head -n 1]"
         puts $PFILE "fusion_version,[lindex [ split [exec cat fusion_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "fusion version,NA check,fusion_version.rpt"
         puts $PFILE "fusion_version,NA"
    }

     ## check EFFORT:
       effort $WA $pnr $stage
     if {[check_grep  effort.rpt "VT_EFFORT" ]} {
         puts $OFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $OFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         puts $PFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $PFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         exec rm effort.rpt
    } else {
         puts $OFILE "EFFORT,NA check,effort.rpt"
         puts $OFILE "VT_EFFORT,NA check,effort.rpt"
         puts $PFILE "EFFORT,NA"
         puts $PFILE "VT_EFFORT,NA"
    }
  #================================================
  # IO buffer statistics
       if {[file exist $WA/$pnr/reports/${stage}/io_buffers_statistics.csv]} {
          set fi [open $WA/$pnr/reports/${stage}/io_buffers_statistics.csv r]
          set first_print 0
          while {[gets $fi line]>=0} {
            if {$first_print==0} {
              puts $OFILE "IO buffers statistics,\"$line"
              incr first_print
            } else {
              puts $OFILE "$line"
            }
            if {[regexp {Total IO} $line ]} {
                puts $PFILE "Total_IO_buffers,[lindex $line 3]"
                puts $PFILE "Total_IO_buffers_input,$WA/$pnr/reports/${stage}/io_buffers_statistics.csv"
            }
          }
        puts  $OFILE "\",$WA/$pnr/reports/${stage}/io_buffers_statistics.csv" 
      } else {
         puts $OFILE  "IO buffers statistics,NA check,  $WA/$pnr/reports/${stage}/io_buffers_statistics.csv"
         puts $PFILE  "Total_IO_buffers,NA"
         puts $PFILE  "Total_IO_buffers_input,$WA/$pnr/reports/${stage}/io_buffers_statistics.csv"

      }
      #================================================
     # Measure length between IO buffers & ports:
       if {[check_grep $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt "MAX_length_between_port_2_iobuf" 1 ]} {
          puts $OFILE "Measure distance between IO buffers to ports(Max value),[ lindex [exec cat $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt | egrep "MAX_length_between_port_2_iobuf"] 1] um, $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt"
          puts $PFILE "Max_distance_IO_buffers_to_ports\[um\],[ lindex [exec cat $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt | egrep "MAX_length_between_port_2_iobuf"] 1]"
          puts $PFILE "Max_distance_IO_buffers_to_ports_input,$WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt"

      } else {
         puts $OFILE "Measure distance between IO buffers to ports(Max value), NA check, $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt"
          puts $PFILE "Max_distance_IO_buffers_to_ports\[um\],NA"
          puts $PFILE "Max_distance_IO_buffers_to_ports_input,$WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt"
      }
     #================================================
     # IO Sampled BY MB
       if {[check_grep $WA/$pnr/reports/${stage}/io_sampled.rpt "found_ports_sampled_by_mbit" 1]} {
          puts $OFILE "found_ports_sampled_by_mbit,[ lindex [exec cat $WA/$pnr/reports/${stage}/io_sampled.rpt | egrep "found_ports_sampled_by_mbit"] 1], $WA/$pnr/reports/${stage}/io_sampled.rpt"
          puts $PFILE "IO_Sampled_BY_MB,[ lindex [exec cat $WA/$pnr/reports/${stage}/io_sampled.rpt | egrep "found_ports_sampled_by_mbit"] 1]"
          puts $PFILE "IO_Sampled_BY_MB_input,$WA/$pnr/reports/${stage}/io_sampled.rpt"

      } else {
         puts $OFILE "found_ports_sampled_by_mbit, NA check, $WA/$pnr/reports/${stage}/io_sampled.rpt"
         puts $PFILE "IO_Sampled_BY_MB,NA"
         puts $PFILE "IO_Sampled_BY_MB_input,$WA/$pnr/reports/${stage}/io_sampled.rpt"
      }
     #================================================
     # IO Buffers driving output ports:
     if {[check_grep $WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt "Found_io_buffer_violations" 1]} {
          puts $OFILE "Found_io_buffer_violations,[ lindex [exec cat $WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt | egrep "Found_io_buffer_violations"] 1], $WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt"
          puts $PFILE "IO_Buffers_driving_ports_violations,[ lindex [exec cat $WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt | egrep "Found_io_buffer_violations"] 1]"
          puts $PFILE "IO_Buffers_driving_ports_violations_input,$WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt"

      } else {
        puts $OFILE "Number of IO Buffers driving ports violations,NA check, $WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt"
        puts $PFILE "IO_Buffers_driving_ports_violations,NA"
        puts $PFILE "IO_Buffers_driving_ports_violations_input,$WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt"
     }
     #================================================
  # buf inv count & info
  if {[file exist reports/${stage}/reports_buf_inv_count.rpt]} {
     set fi [open reports/${stage}/reports_buf_inv_count.rpt r]
     set first_print 1
     while {[gets $fi line]>=0} {
        if {$first_print} {
            puts $OFILE "count buffer/inverter info,\"$line "
            set first_print 0
        } else {
           puts $OFILE "$line"
        }
     } 
           puts $OFILE "\",$WA/$pnr/reports/${stage}/count_buf_inv.rpt"
  }
  if {[file exist reports/${stage}/reports_buf_inv_count_trans.rpt]} {
     set fi [open reports/${stage}/reports_buf_inv_count_trans.rpt r]
     while {[gets $fi line]>=0} {
         puts $PFILE "$line"
     }
  }
#-------------------------------------------------------
 
      
      report_from_be_qor $stage $WA $pnr
     if {[file exist reports/${stage}/report_from_be_qor.csv]} {
       set fi_re [open reports/${stage}/report_from_be_qor.csv r]
        while {[gets $fi_re line]>=0} {
           puts $OFILE "$line"
        }
       exec rm reports/${stage}/report_from_be_qor.csv
     } else {
       puts $OFILE "report from qor, NA check, reports/${stage}/report_from_be_qor.csv  "
     }

     if {[file exist reports/${stage}/report_from_be_qor_for_transpose.csv]} {
       set fi_rt [open reports/${stage}/report_from_be_qor_for_transpose.csv r]
        while {[gets $fi_rt line]>=0} {
          if {[regexp {HotSpot} $line]} {
            if {[regexp {NA} $line]} { 
               puts $PFILE "HotSpot_Score,NA"
            } else {
               puts $PFILE "HotSpot_Score,[lindex [split $line ","] 1]"
            }
           puts $PFILE "HotSpot_Score_input,[lindex [split $line ","] 2]"
          }
          if {[regexp {cell density} $line]} {
            if {[regexp {NA} $line]} { 
               puts $PFILE "cell_density,NA"
            } else {
               puts $PFILE "cell_density,[regsub -all {%} [lindex [split $line ","] 1] {} ]"
            }
          }
          if {[regexp {report congestion} $line]} {
            if {[regexp {NA} $line]} { 
               puts $PFILE "congestion_H,NA"
               puts $PFILE "congestion_V,NA"
            } else {
               puts $PFILE "congestion_H,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 0] {} ]"
               puts $PFILE "congestion_V,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 2] {} ]"
            }
          }
          if {[regexp {Power} $line]} {
            if {[regexp {NA} $line]} { 
               puts $PFILE "[lindex [split $line ","] 0],NA"
            } else {
               puts $PFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1 0]"
            }
          }

          if {[regexp {Multibit_Conversion|Leaf_Cell_Area|Leaf_Cell_Count|FF_Bit_Count|Gated_registers|Ungated_registers|ICG_count} $line]} {
            if {[regexp {NA} $line]} { 
               puts $PFILE "[lindex [split $line ","] 0],NA"
            } else {
               if {[regexp {Multibit_Conversion} $line]} {
                  puts $PFILE "[lindex [split $line ","] 0],[regsub -all {%} [lindex [split $line ","] 1] {}]"
               } else {
                  puts $PFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1]"
               }
            }
          }
          if {[regexp {report_VT_cells} $line]} {
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }
           if {[regexp {report_VT_area} $line]} {
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $PFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }

          if {[regexp {Setup Timing} $line]} {
            foreach tm [regsub -all {\"} [split [lindex [split $line ","] 1] ":"] ""] {
               if {$tm!=""} {
                set i 0
                foreach case "wns tns vp" {
                   if {[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i] != ""} {
                     puts $PFILE "[lindex $tm 0]_${case},[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i]"
                  } else {
                     puts $PFILE "[lindex $tm 0]_${case},NA"
                  }
                   incr i
                }
              }
            }
          }

        }

        # generate timing table, per stage
        report_timing_path_groups $WA $pnr $stage $block_name
        exec rm reports/${stage}/report_from_be_qor_for_transpose.csv
     } else {
        puts $PFILE "HotSpot_Score,NA"
        puts $PFILE "HotSpot_Score_input,reports/${stage}/report_from_be_qor_for_transpose.csv"
        puts $PFILE "cell_density,NA"
        puts $PFILE "congestion_H,NA"
        puts $PFILE "congestion_V,NA"
        puts $PFILE "Total_Internal_Power,NA"
        puts $PFILE "Total_Switching_Power,NA"
        puts $PFILE "Total_Leakage_Power,NA"
        puts $PFILE "Total_Power,NA"
        puts $PFILE "Leaf_Cell_Count,NA"
        puts $PFILE "Gated_registers,NA"
        puts $PFILE "Ungated_registers,NA"
        puts $PFILE "ICG_count,NA"
        puts $PFILE "Leaf_Cell_Area,NA"
        puts $PFILE "LVT_cells,NA"
        puts $PFILE "LVTLL_cells,NA"
        puts $PFILE "ULVT_cells,NA"
        puts $PFILE "ULVTLL_cells,NA"
        puts $PFILE "EVT_cells,NA"
        puts $PFILE "LVT_area,NA"
        puts $PFILE "LVTLL_area,NA"
        puts $PFILE "ULVT_area,NA"
        puts $PFILE "ULVTLL_area,NA"
        puts $PFILE "EVT_area,NA"
        ## NEED to complite for all -->NA
        foreach group "reg2reg reg2cgate reg2out in2reg in2out" {
           foreach case "wns tns vp" {
              puts $PFILE "${group}_$case,NA"

           }
        }
     }

    #================================================

      # log scan statistics 
    analyzed_log_scan $stage
        puts $OFILE "[exec cat log_scan_results]"
        puts $PFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $PFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed
    #----------------------------------------
  close $PFILE

 };# END place
  ####===============================================================================
  ####                                Cts - Only
  ####===============================================================================
if {([lindex $argv 0] == "cts_only") || ([lindex $argv 0] == "all")} {
     set COFILE [open $WA/$pnr/${design_name}_for_transposed_data_4.csv w] 
      # generate cts_only log file :
      set number_of_lines [lindex [split [exec egrep -n "save_block.*cts_only" log/do_cts.log.full] ":"] 0]
        if {[catch {exec ls log/  | egrep do_cts.log.full | egrep -v "errSum"}] == 0 } {
              set fi [open log/do_cts.log.full r]
              set fo [open log/do_cts_only.log.full w]
              set count_lines 1
              while {[gets $fi line]>=0} {
                 if {$count_lines<=$number_of_lines} {
                   puts $fo "$line"
                   incr count_lines
                 } else {
                   close $fo 
                   break
                 } 
              };# while ..
        } else {
            exec touch log/do_cts_only.log.full
        }
     set stage "cts_only"
     puts $OFILE "STAGE,      cts_only"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         puts $COFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $COFILE "Time,[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         puts $COFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $COFILE "Time,[lindex $line 3] PM"
      } else {
         puts $COFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $COFILE "Time,[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	  }
     set proj [find_proj $WA $pnr "$stage"]
     exec rm date.rpt
     puts $COFILE "Work_Area,${WA}/${pnr}"
     puts $COFILE "Block_Name,$block_name"
     puts $COFILE "PROJECT,$proj"
     puts $COFILE "STAGE,cts_only"
     # host name:
     host_name $WA $pnr $stage
     if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $COFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
         exec rm host.rpt
     } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $COFILE "Host_name,NA"
     }
     
     # fusion version
      fusion_version $WA $pnr $stage
    if {[check_grep  fusion_version.rpt "fusion version" ]} {
         puts $OFILE "[ exec cat fusion_version.rpt | head -n 1]"
         puts $COFILE "fusion_version,[lindex [ split [exec cat fusion_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "fusion version,NA check,fusion_version.rpt"
         puts $COFILE "fusion_version,NA"
    }

     ## check EFFORT:
       effort $WA $pnr $stage
     if {[check_grep  effort.rpt "VT_EFFORT" ]} {
         puts $OFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $OFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         puts $COFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $COFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         exec rm effort.rpt
    } else {
         puts $OFILE "EFFORT,NA check,effort.rpt"
         puts $OFILE "VT_EFFORT,NA check,effort.rpt"
         puts $COFILE "EFFORT,NA"
         puts $COFILE "VT_EFFORT,NA"
    }
       
     #  USEFUL SKEW
     find_latest_log $stage
     if {[check_grep latest_${stage}.log "${stage}"] } {
         set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
         if {[check_grep ${WA}/${pnr}/log/$log_file "set USEFUL_SKEW" ]} {
              puts $OFILE  "USEFUL_SKEW,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep  "set USEFUL_SKEW"] 2],${WA}/${pnr}/log/$log_file"
              puts $COFILE  "USEFUL_SKEW,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep  "set USEFUL_SKEW"] 2]"
              set  USEFUL_SKEW [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep  "set USEFUL_SKEW"] 2]
         } else {
            puts $OFILE "USEFUL_SKEW,NA check,${WA}/${pnr}/log/$log_file"
            puts $COFILE "USEFUL_SKEW,NA"
            set  USEFUL_SKEW "NA"
         }
       exec rm latest_cts_only.log
     } else {
      puts $OFILE "USEFUL_SKEW,NA check,${WA}/${pnr}/log/[exec tail -n 1 latest_cts_only.log]"
      puts $COFILE "USEFUL_SKEW,NA"
      set  USEFUL_SKEW "NA"
     }   
    
#-------------------------------------------------------
## Analyzed Clock Tree:
#-------------------------------------------------------
 set COCAFILE [open $WA/$pnr/grafana/${block_name}_cts_only_clock_analyzed.csv w] 
   puts $COCAFILE "Date,Time,Work_Area,Block_Name,Project,Stage,Clock,Useful_Skew,Sinks_Count,Min_Level,Max_Level,Median_Level,Clock_Repeater_Count,Clock_Repeater_Area,Clock_Std_Area,Max_Latency,Global_Skew,Trans_DRC_Count,Cap_DRC_Count,Wire_Length"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         set Date "[lindex $line 1] [lindex $line 2] [lindex $line end]"
         set Time "[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         set Date "[lindex $line 1] [lindex $line 2] [lindex $line end]"
         set Time "[lindex $line 3] PM"
      } else {
         set Date "[lindex $line 1] [lindex $line 2] [lindex $line end]"
         set Time "[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	  }

     set clocks_list [clock_list $WA $pnr $stage]

 if {($clocks_list != "") && ([file exists  $WA/$pnr/reports/${stage}/report_clock_qor.summary]) && ([file exists  $WA/$pnr/reports/${stage}/report_clock_qor.level])} {
     foreach clk $clocks_list { 
       if {[check_grep $WA/$pnr/reports/${stage}/report_clock_qor.summary ${clk}]} {
          #set grep_clk_info [exec cat $WA/$pnr/reports/${stage}/report_clock_qor.summary |  egrep ${clk} | tail -n 1]
          set grep_clk_info [exec cat $WA/$pnr/reports/${stage}/report_clock_qor.summary |  egrep ${clk} | egrep -v "default_" | tail -n 1]
          if {[regexp {[0-9]} [lindex $grep_clk_info 2]]} {
             set num_sinks           [lindex $grep_clk_info 2]
          } else {
             set num_sinks           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 4]]} {
             set clk_repeater_count           [lindex $grep_clk_info 4]
          } else {
             set clk_repeater_count           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 5]]} {
             set clk_repeater_area           [lindex $grep_clk_info 5]
          } else {
             set clk_repeater_area           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 6]]} {
             set clk_std_area          [lindex $grep_clk_info 6]
          } else {
             set clk_std_area           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 7]]} {
             set max_latency           [lindex $grep_clk_info 7]
          } else {
             set max_latency           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 8]]} {
             set global_skew           [lindex $grep_clk_info 8]
          } else {
             set global_skew           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 9]]} {
             set trans_drc_count           [lindex $grep_clk_info 9]
          } else {
             set trans_drc_count           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 10]]} {
             set cap_drc_count           [lindex $grep_clk_info 10]
          } else {
             set cap_drc_count           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 11]]} {
             set wire_length           [lindex $grep_clk_info 11]
          } else {
             set wire_length           "NA"
          }

       } else {
          set num_sinks           "NA"
          set clk_repeater_count  "NA"
          set clk_repeater_area   "NA"
          set clk_std_area        "NA"
          set max_latency         "NA"
          set global_skew         "NA"
          set trans_drc_count     "NA"
          set cap_drc_count       "NA"
          set wire_length         "NA"
       }
          
      if {[check_grep $WA/$pnr/reports/${stage}/report_clock_qor.level ${clk}]} {
          set grep_clk_info [exec cat $WA/$pnr/reports/${stage}/report_clock_qor.level |  egrep ${clk} | head -n 1]
          if {[regexp {[0-9]} [lindex $grep_clk_info 2]]} {
             set max_level           [lindex $grep_clk_info 2]
          } else {
             set max_level           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 3]]} {
             set min_level           [lindex $grep_clk_info 3]
          } else {
             set min_level           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 4]]} {
             set median_level           [lindex $grep_clk_info 4]
          } else {
             set median_level           "NA"
          }
      } else {
          set max_level         "NA"
          set min_level         "NA"
          set median_level      "NA"

      }
     puts $COCAFILE "$Date,$Time,$WA/$pnr,$block_name,$proj,$stage,$clk,$USEFUL_SKEW,$num_sinks,$min_level,$max_level,$median_level,$clk_repeater_count,$clk_repeater_area,$clk_std_area,$max_latency,$global_skew,$trans_drc_count,$cap_drc_count,$wire_length" 
     puts $OFILE "${clk}_num_sinks,$num_sinks,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_min_level,$min_level,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_max_level,$max_level,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_median_level,$median_level,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_repeater_count,$clk_repeater_count,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_repeater_area,$clk_repeater_area,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_std_area,$clk_std_area,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_max_latency,$max_latency,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_global_skew,$global_skew,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_trans_drc_count,$trans_drc_count,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_cap_drc_count,$cap_drc_count,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_wire_length,$wire_length,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     };# end foreach clk...
 } elseif {$clocks_list != ""} {
    foreach clk $clocks_list {
        puts $COCAFILE "$Date,$Time,$WA/$pnr,$block_name,$proj,$stage,$clk,$USEFUL_SKEW,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA"
     puts $OFILE "${clk}_num_sinks,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_min_level,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_max_level,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_median_level,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_repeater_count,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_repeater_area,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_std_area,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_max_latency,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_global_skew,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_trans_drc_count,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_cap_drc_count,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_wire_length,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
    } 
 } 

 close $COCAFILE
#-------------------------------------------------------
 #  clock cells violations 
     if {[check_grep ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt "clock_tree_Cells_violations" ]} {
         puts  $OFILE "clock tree cells violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt |  egrep "clock_tree_Cells_violations"] 1], ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt"
         puts  $COFILE "clock_tree_cells_violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt |  egrep "clock_tree_Cells_violations"] 1]"
     } else {
         puts  $OFILE "clock tree cells violations,NA check, ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt"
         puts  $COFILE "clock_tree_cells_violations,NA"
     }
#-------------------------------------------------------
# buf inv count & info
if {[file exist reports/${stage}/reports_buf_inv_count.rpt]} {
   set fi [open reports/${stage}/reports_buf_inv_count.rpt r]
   set first_print 1
   while {[gets $fi line]>=0} {
      if {$first_print} {
          puts $OFILE "count buffer/inverter info,\"$line "
          set first_print 0
      } else {
         puts $OFILE "$line"
      }
   } 
         puts $OFILE "\",$WA/$pnr/reports/${stage}/count_buf_inv.rpt"
}
if {[file exist reports/${stage}/reports_buf_inv_count_trans.rpt]} {
   set fi [open reports/${stage}/reports_buf_inv_count_trans.rpt r]
   while {[gets $fi line]>=0} {
       puts $COFILE "$line"
   }
}
#-------------------------------------------------------
# max_transition, max_cap, min_pulse_width, min_period
  if {[check_grep ${WA}/${pnr}/reports/${stage}/report_constraint.rpt "Number of" ]} {
    exec cat ${WA}/${pnr}/reports/${stage}/report_constraint.rpt |  egrep "Number of"  > number_of_vio.rpt
    foreach vio {max_transition max_capacitance min_pulse_width min_period } {
      if {[catch {exec cat number_of_vio.rpt | egrep "$vio"}] == 0} {
         exec cat number_of_vio.rpt | egrep "$vio" > tmp_vio
         set fi [open tmp_vio r]
         set count_vio 0 
         while {[gets $fi line]>=0} {
           set count_vio [expr $count_vio + [lindex [split $line ":"] end]]
         }
         puts $OFILE "$vio,$count_vio,${WA}/${pnr}/reports/${stage}/report_constraint.rpt"
         puts $COFILE "$vio,$count_vio"
         exec rm tmp_vio
      } else {
        puts $OFILE "$vio,NA,${WA}/${pnr}/reports/${stage}/report_constraint.rpt"
        puts $COFILE "$vio,NA"
      }
    }
    exec rm number_of_vio.rpt
  } else {
    foreach vio {max_transition max_capacitance min_pulse_width min_period } {
       puts $OFILE "$vio,NA,${WA}/${pnr}/reports/${stage}/report_constraint.rpt"
       puts $COFILE "$vio,NA"
    }
  }
#-------------------------------------------------------
# check that every clock pin start from clock.
  if {[check_grep ${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt "clock_pins_not_connect_to_clock" ]} {
     puts $OFILE "clock_pins_not_connect_to_clock_violation,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt | egrep "clock_pins_not_connect_to_clock" ] 1],${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt"
     puts $COFILE "clock_pins_not_connect_to_clock_violation,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt | egrep "clock_pins_not_connect_to_clock" ] 1]"

  } else {
      puts $OFILE "clock_pins_not_connect_to_clock_violation,NA,${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt"
      puts $COFILE "clock_pins_not_connect_to_clock_violation,NA"
 }

#-------------------------------------------------------
# check routing_rule to each clock net
  if {[check_grep ${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt "clock_ndr_violations" ]} {
     puts $OFILE "clock_ndr_violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt | egrep "clock_ndr_violations" ] 1],${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt"
     puts $COFILE "clock_ndr_violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt | egrep "clock_ndr_violations" ] 1]"

  } else {
     puts $OFILE "clock_ndr_violations,NA,${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt"
     puts $COFILE "clock_ndr_violations,NA"

  }
#-------------------------------------------------------
      report_from_be_qor $stage $WA $pnr
     if {[file exist reports/${stage}/report_from_be_qor.csv]} {
       set fi_re [open reports/${stage}/report_from_be_qor.csv r]
        while {[gets $fi_re line]>=0} {
           puts $OFILE "$line"
        }
    #   exec rm reports/${stage}/report_from_be_qor.csv
     } else {
       puts $OFILE "report from qor, NA check, reports/${stage}/report_from_be_qor.csv  "
     }

     if {[file exist reports/${stage}/report_from_be_qor_for_transpose.csv]} {
       set fi_rt [open reports/${stage}/report_from_be_qor_for_transpose.csv r]
        while {[gets $fi_rt line]>=0} {
          if {[regexp {HotSpot} $line]} {
            if {[regexp {NA} $line]} { 
               puts $COFILE "HotSpot_Score,NA"
            } else {
               puts $COFILE "HotSpot_Score,[lindex [split $line ","] 1]"
            }
           puts $COFILE "HotSpot_Score_input,[lindex [split $line ","] 2]"
          }
          if {[regexp {cell density} $line]} {
            if {[regexp {NA} $line]} { 
               puts $COFILE "cell_density,NA"
            } else {
               puts $COFILE "cell_density,[regsub -all {%} [lindex [split $line ","] 1] {} ]"
            }
          }
          if {[regexp {report congestion} $line]} {
            if {[regexp {NA} $line]} { 
               puts $COFILE "congestion_H,NA"
               puts $COFILE "congestion_V,NA"
            } else {
               puts $COFILE "congestion_H,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 0] {} ]"
               puts $COFILE "congestion_V,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 2] {} ]"
            }
          }
          if {[regexp {Power} $line]} {
            if {[regexp {NA} $line]} { 
               puts $COFILE "[lindex [split $line ","] 0],NA"
            } else {
               puts $COFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1 0]"
            }
          }

          if {[regexp {Multibit_Conversion|Leaf_Cell_Area|Leaf_Cell_Count|FF_Bit_Count|Gated_registers|Ungated_registers|ICG_count} $line]} {
            if {[regexp {NA} $line]} { 
               puts $COFILE "[lindex [split $line ","] 0],NA"
            } else {
               if {[regexp {Multibit_Conversion} $line]} {
                  puts $COFILE "[lindex [split $line ","] 0],[regsub -all {%} [lindex [split $line ","] 1] {}]"
               } else {
                  puts $COFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1]"
               }
            }
          }
          if {[regexp {report_VT_cells} $line]} {
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }
           if {[regexp {report_VT_area} $line]} {
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $COFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }

          if {[regexp {Setup Timing} $line]} {
            foreach tm [regsub -all {\"} [split [lindex [split $line ","] 1] ":"] ""] {
               if {$tm!=""} {
                set i 0
                foreach case "wns tns vp" {
                   if {[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i] != ""} {
                     puts $COFILE "[lindex $tm 0]_${case},[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i]"
                  } else {
                     puts $COFILE "[lindex $tm 0]_${case},NA"
                  }
                   incr i
                }
              }
            }
          }

        }

        # generate timing table, per stage
        report_timing_path_groups $WA $pnr $stage $block_name
      #  exec rm reports/${stage}/report_from_be_qor_for_transpose.csv
     } else {
        puts $COFILE "HotSpot_Score,NA"
        puts $COFILE "HotSpot_Score_input,reports/${stage}/report_from_be_qor_for_transpose.csv"
        puts $COFILE "cell_density,NA"
        puts $COFILE "congestion_H,NA"
        puts $COFILE "congestion_V,NA"
        puts $COFILE "Total_Internal_Power,NA"
        puts $COFILE "Total_Switching_Power,NA"
        puts $COFILE "Total_Leakage_Power,NA"
        puts $COFILE "Total_Power,NA"
        puts $COFILE "Leaf_Cell_Count,NA"
        puts $COFILE "Gated_registers,NA"
        puts $COFILE "Ungated_registers,NA"
        puts $COFILE "ICG_count,NA"
        puts $COFILE "Leaf_Cell_Area,NA"
        puts $COFILE "LVT_cells,NA"
        puts $COFILE "LVTLL_cells,NA"
        puts $COFILE "ULVT_cells,NA"
        puts $COFILE "ULVTLL_cells,NA"
        puts $COFILE "EVT_cells,NA"
        puts $COFILE "LVT_area,NA"
        puts $COFILE "LVTLL_area,NA"
        puts $COFILE "ULVT_area,NA"
        puts $COFILE "ULVTLL_area,NA"
        puts $COFILE "EVT_area,NA"
        ## NEED to complite for all -->NA
        foreach group "reg2reg reg2cgate reg2out in2reg in2out" {
           foreach case "wns tns vp" {
              puts $COFILE "${group}_$case,NA"

           }
        }
     }


    #================================================

      # log scan statistics 
    #analyzed_log_scan $stage
    analyzed_log_scan "cts"
        puts $OFILE "[exec cat log_scan_results]"
        puts $COFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $COFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed
    #----------------------------------------
  close $COFILE

 };# END cts_only

  ####===============================================================================
  ####===============================================================================
  ####                                Cts
  ####===============================================================================
  if {([lindex $argv 0] == "cts") || ([lindex $argv 0] == "all")} {
     set CFILE [open $WA/$pnr/${design_name}_for_transposed_data_5.csv w] 
     set stage "cts"
     puts $OFILE "STAGE,      cts"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         puts $CFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $CFILE "Time,[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         puts $CFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $CFILE "Time,[lindex $line 3] PM"
      } else {
         puts $CFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $CFILE "Time,[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	  }
     set proj [find_proj $WA $pnr "cts"]
     exec rm date.rpt
     puts $CFILE "Work_Area,${WA}/${pnr}"
     puts $CFILE "Block_Name,$block_name"
     puts $CFILE "PROJECT,$proj"
     puts $CFILE "STAGE,cts"
     # host name:
     host_name $WA $pnr $stage
     if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $CFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
         exec rm host.rpt
     } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $CFILE "Host_name,NA"
     }
     
     # fusion version
      fusion_version $WA $pnr $stage
    if {[check_grep  fusion_version.rpt "fusion version" ]} {
         puts $OFILE "[ exec cat fusion_version.rpt | head -n 1]"
         puts $CFILE "fusion_version,[lindex [ split [exec cat fusion_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "fusion version,NA check,fusion_version.rpt"
         puts $CFILE "fusion_version,NA"
    }

     ## check EFFORT:
       effort $WA $pnr $stage
     if {[check_grep  effort.rpt "VT_EFFORT" ]} {
         puts $OFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $OFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         puts $CFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $CFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         exec rm effort.rpt
    } else {
         puts $OFILE "EFFORT,NA check,effort.rpt"
         puts $OFILE "VT_EFFORT,NA check,effort.rpt"
         puts $CFILE "EFFORT,NA"
         puts $CFILE "VT_EFFORT,NA"
    }
       
     #  USEFUL SKEW
     find_latest_log $stage
     if {[check_grep latest_${stage}.log "${stage}"] } {
         set log_file [exec cat latest_cts.log | egrep "cts"]
         if {[check_grep ${WA}/${pnr}/log/$log_file "set USEFUL_SKEW" ]} {
              puts $OFILE  "USEFUL_SKEW,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep  "set USEFUL_SKEW"] 2],${WA}/${pnr}/log/$log_file"
              puts $CFILE  "USEFUL_SKEW,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep  "set USEFUL_SKEW"] 2]"
              set  USEFUL_SKEW [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep  "set USEFUL_SKEW"] 2]
         } else {
            puts $OFILE "USEFUL_SKEW,NA check,${WA}/${pnr}/log/$log_file"
            puts $CFILE "USEFUL_SKEW,NA"
            set  USEFUL_SKEW "NA"
         }
       exec rm latest_cts.log
     } else {
      puts $OFILE "USEFUL_SKEW,NA check,${WA}/${pnr}/log/[exec tail -n 1 latest_cts.log]"
      puts $CFILE "USEFUL_SKEW,NA"
      set  USEFUL_SKEW "NA"
     }   
    
#-------------------------------------------------------
## Analyzed Clock Tree:
#-------------------------------------------------------
 set CCAFILE [open $WA/$pnr/grafana/${block_name}_cts_clock_analyzed.csv w] 
   puts $CCAFILE "Date,Time,Work_Area,Block_Name,Project,Stage,Clock,Useful_Skew,Sinks_Count,Min_Level,Max_Level,Median_Level,Clock_Repeater_Count,Clock_Repeater_Area,Clock_Std_Area,Max_Latency,Global_Skew,Trans_DRC_Count,Cap_DRC_Count,Wire_Length"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         set Date "[lindex $line 1] [lindex $line 2] [lindex $line end]"
         set Time "[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         set Date "[lindex $line 1] [lindex $line 2] [lindex $line end]"
         set Time "[lindex $line 3] PM"
      } else {
         set Date "[lindex $line 1] [lindex $line 2] [lindex $line end]"
         set Time "[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	  }

     set clocks_list [clock_list $WA $pnr $stage]

 if {($clocks_list != "") && ([file exists  $WA/$pnr/reports/${stage}/report_clock_qor.summary]) && ([file exists  $WA/$pnr/reports/${stage}/report_clock_qor.level])} {
     foreach clk $clocks_list { 
       if {[check_grep $WA/$pnr/reports/${stage}/report_clock_qor.summary ${clk}]} {
          #set grep_clk_info [exec cat $WA/$pnr/reports/${stage}/report_clock_qor.summary |  egrep ${clk} | tail -n 1]
          set grep_clk_info [exec cat $WA/$pnr/reports/${stage}/report_clock_qor.summary |  egrep ${clk} | egrep -v "default_" | tail -n 1]
          if {[regexp {[0-9]} [lindex $grep_clk_info 2]]} {
             set num_sinks           [lindex $grep_clk_info 2]
          } else {
             set num_sinks           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 4]]} {
             set clk_repeater_count           [lindex $grep_clk_info 4]
          } else {
             set clk_repeater_count           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 5]]} {
             set clk_repeater_area           [lindex $grep_clk_info 5]
          } else {
             set clk_repeater_area           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 6]]} {
             set clk_std_area          [lindex $grep_clk_info 6]
          } else {
             set clk_std_area           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 7]]} {
             set max_latency           [lindex $grep_clk_info 7]
          } else {
             set max_latency           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 8]]} {
             set global_skew           [lindex $grep_clk_info 8]
          } else {
             set global_skew           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 9]]} {
             set trans_drc_count           [lindex $grep_clk_info 9]
          } else {
             set trans_drc_count           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 10]]} {
             set cap_drc_count           [lindex $grep_clk_info 10]
          } else {
             set cap_drc_count           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 11]]} {
             set wire_length           [lindex $grep_clk_info 11]
          } else {
             set wire_length           "NA"
          }

       } else {
          set num_sinks           "NA"
          set clk_repeater_count  "NA"
          set clk_repeater_area   "NA"
          set clk_std_area        "NA"
          set max_latency         "NA"
          set global_skew         "NA"
          set trans_drc_count     "NA"
          set cap_drc_count       "NA"
          set wire_length         "NA"
       }
          
      if {[check_grep $WA/$pnr/reports/${stage}/report_clock_qor.level ${clk}]} {
          set grep_clk_info [exec cat $WA/$pnr/reports/${stage}/report_clock_qor.level |  egrep ${clk} | head -n 1]
          if {[regexp {[0-9]} [lindex $grep_clk_info 2]]} {
             set max_level           [lindex $grep_clk_info 2]
          } else {
             set max_level           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 3]]} {
             set min_level           [lindex $grep_clk_info 3]
          } else {
             set min_level           "NA"
          }
          if {[regexp {[0-9]} [lindex $grep_clk_info 4]]} {
             set median_level           [lindex $grep_clk_info 4]
          } else {
             set median_level           "NA"
          }
      } else {
          set max_level         "NA"
          set min_level         "NA"
          set median_level      "NA"

      }
     puts $CCAFILE "$Date,$Time,$WA/$pnr,$block_name,$proj,$stage,$clk,$USEFUL_SKEW,$num_sinks,$min_level,$max_level,$median_level,$clk_repeater_count,$clk_repeater_area,$clk_std_area,$max_latency,$global_skew,$trans_drc_count,$cap_drc_count,$wire_length" 
     puts $OFILE "${clk}_num_sinks,$num_sinks,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_min_level,$min_level,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_max_level,$max_level,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_median_level,$median_level,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_repeater_count,$clk_repeater_count,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_repeater_area,$clk_repeater_area,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_std_area,$clk_std_area,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_max_latency,$max_latency,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_global_skew,$global_skew,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_trans_drc_count,$trans_drc_count,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_cap_drc_count,$cap_drc_count,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_wire_length,$wire_length,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     };# end foreach clk...
 } elseif {$clocks_list != ""} {
    foreach clk $clocks_list {
        puts $CCAFILE "$Date,$Time,$WA/$pnr,$block_name,$proj,$stage,$clk,$USEFUL_SKEW,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA,NA"
     puts $OFILE "${clk}_num_sinks,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_min_level,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_max_level,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_median_level,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_repeater_count,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_repeater_area,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_clk_std_area,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_max_latency,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_global_skew,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_trans_drc_count,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_cap_drc_count,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
     puts $OFILE "${clk}_wire_length,NA,$WA/$pnr/reports/${stage}/report_clock_qor.summary"
    } 
 } 

 close $CCAFILE
#-------------------------------------------------------
 #  clock cells violations 
     if {[check_grep ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt "clock_tree_Cells_violations" ]} {
         puts  $OFILE "clock tree cells violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt |  egrep "clock_tree_Cells_violations"] 1], ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt"
         puts  $CFILE "clock_tree_cells_violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt |  egrep "clock_tree_Cells_violations"] 1]"
     } else {
         puts  $OFILE "clock tree cells violations,NA check, ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells_violations.rpt"
         puts  $CFILE "clock_tree_cells_violations,NA"
     }
#-------------------------------------------------------
# buf inv count & info
if {[file exist reports/${stage}/reports_buf_inv_count.rpt]} {
   set fi [open reports/${stage}/reports_buf_inv_count.rpt r]
   set first_print 1
   while {[gets $fi line]>=0} {
      if {$first_print} {
          puts $OFILE "count buffer/inverter info,\"$line "
          set first_print 0
      } else {
         puts $OFILE "$line"
      }
   } 
         puts $OFILE "\",$WA/$pnr/reports/${stage}/count_buf_inv.rpt"
}
if {[file exist reports/${stage}/reports_buf_inv_count_trans.rpt]} {
   set fi [open reports/${stage}/reports_buf_inv_count_trans.rpt r]
   while {[gets $fi line]>=0} {
       puts $CFILE "$line"
   }
}
#-------------------------------------------------------
# max_transition, max_cap, min_pulse_width, min_period
  if {[check_grep ${WA}/${pnr}/reports/${stage}/report_constraint.rpt "Number of" ]} {
    exec cat ${WA}/${pnr}/reports/${stage}/report_constraint.rpt |  egrep "Number of"  > number_of_vio.rpt
    foreach vio {max_transition max_capacitance min_pulse_width min_period } {
      if {[catch {exec cat number_of_vio.rpt | egrep "$vio"}] == 0} {
         exec cat number_of_vio.rpt | egrep "$vio" > tmp_vio
         set fi [open tmp_vio r]
         set count_vio 0 
         while {[gets $fi line]>=0} {
           set count_vio [expr $count_vio + [lindex [split $line ":"] end]]
         }
         puts $OFILE "$vio,$count_vio,${WA}/${pnr}/reports/${stage}/report_constraint.rpt"
         puts $CFILE "$vio,$count_vio"
         exec rm tmp_vio
      } else {
        puts $OFILE "$vio,NA,${WA}/${pnr}/reports/${stage}/report_constraint.rpt"
        puts $CFILE "$vio,NA"
      }
    }
    exec rm number_of_vio.rpt
  } else {
    foreach vio {max_transition max_capacitance min_pulse_width min_period } {
       puts $OFILE "$vio,NA,${WA}/${pnr}/reports/${stage}/report_constraint.rpt"
       puts $CFILE "$vio,NA"
    }
  }
#-------------------------------------------------------
# check that every clock pin start from clock.
  if {[check_grep ${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt "clock_pins_not_connect_to_clock" ]} {
     puts $OFILE "clock_pins_not_connect_to_clock_violation,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt | egrep "clock_pins_not_connect_to_clock" ] 1],${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt"
     puts $CFILE "clock_pins_not_connect_to_clock_violation,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt | egrep "clock_pins_not_connect_to_clock" ] 1]"

  } else {
      puts $OFILE "clock_pins_not_connect_to_clock_violation,NA,${WA}/${pnr}/reports/${stage}/reports_clock_to_each_clk_pin.rpt"
      puts $CFILE "clock_pins_not_connect_to_clock_violation,NA"
 }

#-------------------------------------------------------
# check routing_rule to each clock net
  if {[check_grep ${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt "clock_ndr_violations" ]} {
     puts $OFILE "clock_ndr_violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt | egrep "clock_ndr_violations" ] 1],${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt"
     puts $CFILE "clock_ndr_violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt | egrep "clock_ndr_violations" ] 1]"

  } else {
     puts $OFILE "clock_ndr_violations,NA,${WA}/${pnr}/reports/${stage}/report_clock_ndr_violations.rpt"
     puts $CFILE "clock_ndr_violations,NA"

  }
#-------------------------------------------------------
      report_from_be_qor $stage $WA $pnr
     if {[file exist reports/${stage}/report_from_be_qor.csv]} {
       set fi_re [open reports/${stage}/report_from_be_qor.csv r]
        while {[gets $fi_re line]>=0} {
           puts $OFILE "$line"
        }
       exec rm reports/${stage}/report_from_be_qor.csv
     } else {
       puts $OFILE "report from qor, NA check, reports/${stage}/report_from_be_qor.csv  "
     }

     if {[file exist reports/${stage}/report_from_be_qor_for_transpose.csv]} {
       set fi_rt [open reports/${stage}/report_from_be_qor_for_transpose.csv r]
        while {[gets $fi_rt line]>=0} {
          if {[regexp {HotSpot} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CFILE "HotSpot_Score,NA"
            } else {
               puts $CFILE "HotSpot_Score,[lindex [split $line ","] 1]"
            }
           puts $CFILE "HotSpot_Score_input,[lindex [split $line ","] 2]"
          }
          if {[regexp {cell density} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CFILE "cell_density,NA"
            } else {
               puts $CFILE "cell_density,[regsub -all {%} [lindex [split $line ","] 1] {} ]"
            }
          }
          if {[regexp {report congestion} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CFILE "congestion_H,NA"
               puts $CFILE "congestion_V,NA"
            } else {
               puts $CFILE "congestion_H,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 0] {} ]"
               puts $CFILE "congestion_V,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 2] {} ]"
            }
          }
          if {[regexp {Power} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CFILE "[lindex [split $line ","] 0],NA"
            } else {
               puts $CFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1 0]"
            }
          }

          if {[regexp {Multibit_Conversion|Leaf_Cell_Area|Leaf_Cell_Count|FF_Bit_Count|Gated_registers|Ungated_registers|ICG_count} $line]} {
            if {[regexp {NA} $line]} { 
               puts $CFILE "[lindex [split $line ","] 0],NA"
            } else {
               if {[regexp {Multibit_Conversion} $line]} {
                  puts $CFILE "[lindex [split $line ","] 0],[regsub -all {%} [lindex [split $line ","] 1] {}]"
               } else {
                  puts $CFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1]"
               }
            }
          }
          if {[regexp {report_VT_cells} $line]} {
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }
           if {[regexp {report_VT_area} $line]} {
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $CFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }

          if {[regexp {Setup Timing} $line]} {
            foreach tm [regsub -all {\"} [split [lindex [split $line ","] 1] ":"] ""] {
               if {$tm!=""} {
                set i 0
                foreach case "wns tns vp" {
                   if {[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i] != ""} {
                     puts $CFILE "[lindex $tm 0]_${case},[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i]"
                  } else {
                     puts $CFILE "[lindex $tm 0]_${case},NA"
                  }
                   incr i
                }
              }
            }
          }

        }

        # generate timing table, per stage
        report_timing_path_groups $WA $pnr $stage $block_name
        exec rm reports/${stage}/report_from_be_qor_for_transpose.csv
     } else {
        puts $CFILE "HotSpot_Score,NA"
        puts $CFILE "HotSpot_Score_input,reports/${stage}/report_from_be_qor_for_transpose.csv"
        puts $CFILE "cell_density,NA"
        puts $CFILE "congestion_H,NA"
        puts $CFILE "congestion_V,NA"
        puts $CFILE "Total_Internal_Power,NA"
        puts $CFILE "Total_Switching_Power,NA"
        puts $CFILE "Total_Leakage_Power,NA"
        puts $CFILE "Total_Power,NA"
        puts $CFILE "Leaf_Cell_Count,NA"
        puts $CFILE "Gated_registers,NA"
        puts $CFILE "Ungated_registers,NA"
        puts $CFILE "ICG_count,NA"
        puts $CFILE "Leaf_Cell_Area,NA"
        puts $CFILE "LVT_cells,NA"
        puts $CFILE "LVTLL_cells,NA"
        puts $CFILE "ULVT_cells,NA"
        puts $CFILE "ULVTLL_cells,NA"
        puts $CFILE "EVT_cells,NA"
        puts $CFILE "LVT_area,NA"
        puts $CFILE "LVTLL_area,NA"
        puts $CFILE "ULVT_area,NA"
        puts $CFILE "ULVTLL_area,NA"
        puts $CFILE "EVT_area,NA"
        ## NEED to complite for all -->NA
        foreach group "reg2reg reg2cgate reg2out in2reg in2out" {
           foreach case "wns tns vp" {
              puts $CFILE "${group}_$case,NA"

           }
        }
     }


    #================================================

      # log scan statistics 
    analyzed_log_scan $stage
        puts $OFILE "[exec cat log_scan_results]"
        puts $CFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $CFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed
    #----------------------------------------
  close $CFILE

 };# END cts
 #===============================================================================
 ####===============================================================================
 ####                                Route
 ####===============================================================================
 if {([lindex $argv 0] == "route") || ([lindex $argv 0] == "all")} {
     set RFILE [open $WA/$pnr/${design_name}_for_transposed_data_6.csv w] 
     set stage "route"
     puts $OFILE "STAGE,      route"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         puts $RFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $RFILE "Time,[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         puts $RFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $RFILE "Time,[lindex $line 3] PM"
      } else {
         puts $RFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $RFILE "Time,[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	  }
     set proj [find_proj $WA $pnr "route"]
     exec rm date.rpt
     puts $RFILE "Work_Area,${WA}/${pnr}"
     puts $RFILE "Block_Name,$block_name"
     puts $RFILE "PROJECT,$proj"
     puts $RFILE "STAGE,route"
     # host name:
     host_name $WA $pnr $stage
     if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $RFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
         exec rm host.rpt
     } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $RFILE "Host_name,NA"
     }
     
     # fusion version
      fusion_version $WA $pnr $stage
    if {[check_grep  fusion_version.rpt "fusion version" ]} {
         puts $OFILE "[ exec cat fusion_version.rpt | head -n 1]"
         puts $RFILE "fusion_version,[lindex [ split [exec cat fusion_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "fusion version,NA check,fusion_version.rpt"
         puts $RFILE "fusion_version,NA"
    }

     ## check EFFORT:
       effort $WA $pnr $stage
     if {[check_grep  effort.rpt "VT_EFFORT" ]} {
         puts $OFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $OFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         puts $RFILE "[lindex [split [exec cat effort.rpt | head -n 1] ","] 0],[lindex [split [exec cat effort.rpt | head -n 1] ","] 1]"
         puts $RFILE "[lindex [split [exec cat effort.rpt | tail -n 1] ","] 0],[lindex [split [exec cat effort.rpt | tail -n 1] ","] 1]"
         exec rm effort.rpt
    } else {
         puts $OFILE "EFFORT,NA check,effort.rpt"
         puts $OFILE "VT_EFFORT,NA check,effort.rpt"
         puts $RFILE "EFFORT,NA"
         puts $RFILE "VT_EFFORT,NA"
    }
       

#-------------------------------------------
# buf inv count & info
if {[file exist reports/${stage}/reports_buf_inv_count.rpt]} {
   set fi [open reports/${stage}/reports_buf_inv_count.rpt r]
   set first_print 1
   while {[gets $fi line]>=0} {
      if {$first_print} {
          puts $OFILE "count buffer/inverter info,\"$line "
          set first_print 0
      } else {
         puts $OFILE "$line"
      }
   } 
         puts $OFILE "\",$WA/$pnr/reports/${stage}/count_buf_inv.rpt"
}
if {[file exist reports/${stage}/reports_buf_inv_count_trans.rpt]} {
   set fi [open reports/${stage}/reports_buf_inv_count_trans.rpt r]
   while {[gets $fi line]>=0} {
       puts $RFILE "$line"
   }
}
#-------------------------------------------------------
# max_transition, max_cap, min_pulse_width, min_period
  if {[check_grep ${WA}/${pnr}/reports/${stage}/report_constraint.rpt "Number of" ]} {
    exec cat ${WA}/${pnr}/reports/${stage}/report_constraint.rpt |  egrep "Number of"  > number_of_vio.rpt
    foreach vio {max_transition max_capacitance min_pulse_width min_period } {
      if {[catch {exec cat number_of_vio.rpt | egrep "$vio"}] == 0} {
         exec cat number_of_vio.rpt | egrep "$vio" > tmp_vio
         set fi [open tmp_vio r]
         set count_vio 0 
         while {[gets $fi line]>=0} {
           set count_vio [expr $count_vio + [lindex [split $line ":"] end]]
         }
         puts $OFILE "$vio,$count_vio,${WA}/${pnr}/reports/${stage}/report_constraint.rpt"
         puts $RFILE "$vio,$count_vio"
         exec rm tmp_vio
      } else {
        puts $OFILE "$vio,NA check,${WA}/${pnr}/reports/${stage}/report_constraint.rpt"
        puts $RFILE "$vio,NA"
      }
    }
    exec rm number_of_vio.rpt
  } else {
    foreach vio {max_transition max_capacitance min_pulse_width min_period } {
       puts $OFILE "$vio,NA check,${WA}/${pnr}/reports/${stage}/report_constraint.rpt"
       puts $RFILE "$vio,NA"
    }
  }
#-------------------------------------------------------
# dont_use cells check
  if {[check_grep ${WA}/${pnr}/reports/${stage}/report_dont_use_cells.rpt "Found_dont_use_cells_violations" ]} {
     puts $OFILE "Found_dont_use_cells_violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_dont_use_cells.rpt | egrep "Found_dont_use_cells_violations"] end],${WA}/${pnr}/reports/${stage}/report_dont_use_cells.rpt"
     puts $RFILE "Found_dont_use_cells_violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_dont_use_cells.rpt | egrep "Found_dont_use_cells_violations"] end]"

  } else {
     puts $OFILE "Found_dont_use_cells_violations,NA check,${WA}/${pnr}/reports/${stage}/report_dont_use_cells.rpt"
     puts $RFILE "Found_dont_use_cells_violations,NA"
  }
#-------------------------------------------------------
# Net length
  if {[check_grep ${WA}/${pnr}/reports/${stage}/report_nets_length.rpt "Found_long_nets" ]} {
     puts $OFILE "Found_long_nets,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_nets_length.rpt | egrep "Found_long_nets"] 1],${WA}/${pnr}/reports/${stage}/report_nets_length.rpt"
     puts $RFILE "Found_long_nets,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_nets_length.rpt | egrep "Found_long_nets"] 1]"

  } else {
     puts $OFILE "Found_long_nets,NA,${WA}/${pnr}/reports/${stage}/report_nets_length.rpt"
     puts $RFILE "Found_long_nets,NA"
  }
#-------------------------------------------------------
# route quality
  if {[check_grep ${WA}/${pnr}/reports/${stage}/report_route_quality_ratio.rpt "Worst_route_quality_ratio" ]} {
     puts $OFILE "Worst_route_quality_ratio,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_route_quality_ratio.rpt | egrep "Worst_route_quality_ratio"] end],${WA}/${pnr}/reports/${stage}/report_route_quality_ratio.rpt"
     puts $RFILE "Worst_route_quality_ratio,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_route_quality_ratio.rpt | egrep "Worst_route_quality_ratio"] end]"

  } else {
     puts $OFILE "Worst_route_quality_ratio,NA,${WA}/${pnr}/reports/${stage}/report_route_quality_ratio.rpt"
     puts $RFILE "Worst_route_quality_ratio,NA"
  }
#-------------------------------------------------------
      report_from_be_qor $stage $WA $pnr
     if {[file exist reports/${stage}/report_from_be_qor.csv]} {
       set fi_re [open reports/${stage}/report_from_be_qor.csv r]
        while {[gets $fi_re line]>=0} {
           puts $OFILE "$line"
        }
       exec rm reports/${stage}/report_from_be_qor.csv
     } else {
       puts $OFILE "report from qor, NA check, reports/${stage}/report_from_be_qor.csv  "
     }

     if {[file exist reports/${stage}/report_from_be_qor_for_transpose.csv]} {
       set fi_rt [open reports/${stage}/report_from_be_qor_for_transpose.csv r]
        while {[gets $fi_rt line]>=0} {
          if {[regexp {HotSpot} $line]} {
            if {[regexp {NA} $line]} { 
               puts $RFILE "HotSpot_Score,NA"
            } else {
               puts $RFILE "HotSpot_Score,[lindex [split $line ","] 1]"
            }
           puts $RFILE "HotSpot_Score_input,[lindex [split $line ","] 2]"
          }
          if {[regexp {cell density} $line]} {
            if {[regexp {NA} $line]} { 
               puts $RFILE "cell_density,NA"
            } else {
               puts $RFILE "cell_density,[regsub -all {%} [lindex [split $line ","] 1] {} ]"
            }
          }
          if {[regexp {report congestion} $line]} {
            if {[regexp {NA} $line]} { 
               puts $RFILE "congestion_H,NA"
               puts $RFILE "congestion_V,NA"
            } else {
               puts $RFILE "congestion_H,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 0] {} ]"
               puts $RFILE "congestion_V,[regsub -all {%} [lindex [lindex [split  $line ","] 1 0] 2] {} ]"
            }
          }
          if {[regexp {Power} $line]} {
            if {[regexp {NA} $line]} { 
               puts $RFILE "[lindex [split $line ","] 0],NA"
            } else {
               puts $RFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1 0]"
            }
          }

          if {[regexp {Multibit_Conversion|Leaf_Cell_Area|Leaf_Cell_Count|FF_Bit_Count|Gated_registers|Ungated_registers|ICG_count} $line]} {
            if {[regexp {NA} $line]} { 
               puts $RFILE "[lindex [split $line ","] 0],NA"
            } else {
               if {[regexp {Multibit_Conversion} $line]} {
                  puts $RFILE "[lindex [split $line ","] 0],[regsub -all {%} [lindex [split $line ","] 1] {}]"
               } else {
                  puts $RFILE "[lindex [split $line ","] 0],[lindex [split $line ","] 1]"
               }
            }
          }
          if {[regexp {report_VT_cells} $line]} {
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_cells,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }
           if {[regexp {report_VT_area} $line]} {
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 1 1]"
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 2 1]"
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 3 1]"
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 4 1]"
               puts $RFILE "[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 0]_area,[lindex [split [regsub -all {%|\(|\)|\"} $line { }] ":"] 5 1]"
          }

          if {[regexp {Setup Timing} $line]} {
            foreach tm [regsub -all {\"} [split [lindex [split $line ","] 1] ":"] ""] {
               if {$tm!=""} {
                set i 0
                foreach case "wns tns vp" {
                   if {[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i] != ""} {
                     puts $RFILE "[lindex $tm 0]_${case},[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i]"
                  } else {
                     puts $RFILE "[lindex $tm 0]_${case},NA"
                  }
                   incr i
                }
              }
            }
          }

        }

        # generate timing table, per stage
        report_timing_path_groups $WA $pnr $stage $block_name
        exec rm reports/${stage}/report_from_be_qor_for_transpose.csv
     } else {
        puts $RFILE "HotSpot_Score,NA"
        puts $RFILE "HotSpot_Score_input,reports/${stage}/report_from_be_qor_for_transpose.csv"
        puts $RFILE "cell_density,NA"
        puts $RFILE "congestion_H,NA"
        puts $RFILE "congestion_V,NA"
        puts $RFILE "Total_Internal_Power,NA"
        puts $RFILE "Total_Switching_Power,NA"
        puts $RFILE "Total_Leakage_Power,NA"
        puts $RFILE "Total_Power,NA"
        puts $RFILE "Leaf_Cell_Count,NA"
        puts $RFILE "Gated_registers,NA"
        puts $RFILE "Ungated_registers,NA"
        puts $RFILE "ICG_count,NA"
        puts $RFILE "Leaf_Cell_Area,NA"
        puts $RFILE "LVT_cells,NA"
        puts $RFILE "LVTLL_cells,NA"
        puts $RFILE "ULVT_cells,NA"
        puts $RFILE "ULVTLL_cells,NA"
        puts $RFILE "EVT_cells,NA"
        puts $RFILE "LVT_area,NA"
        puts $RFILE "LVTLL_area,NA"
        puts $RFILE "ULVT_area,NA"
        puts $RFILE "ULVTLL_area,NA"
        puts $RFILE "EVT_area,NA"
        ## NEED to complite for all -->NA
        foreach group "reg2reg reg2cgate reg2out in2reg in2out" {
           foreach case "wns tns vp" {
              puts $RFILE "${group}_$case,NA"

           }
        }
     }

#----------------------------------------
 # log scan statistics 
    analyzed_log_scan $stage
        puts $OFILE "[exec cat log_scan_results]"
        puts $RFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $RFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed
#----------------------------------------

   close $RFILE

 };# END route

  #===============================================================================
  # END checklist
  close $OFILE
  #===============================================================================
     set file_name "$WA/$pnr/${design_name}_be_checklist_summary.csv"
     exec echo "be checklist reports : ${design_name} , stage : $stage " > tmp
     exec cat tmp | mail -r be_checklist_summary@nextsilicon.com -a $file_name -s "be checklist summary report for ${design_name}, stage : $stage " ido.naishtein@nextsilicon.com,[be_get_user_email $::env(USER)]
     exec rm tmp
 #===============================================================================
     # for statistics:
  if {([lindex $argv 0] == "init") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_1.csv]} {
        set stage "init"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_1.csv $stage
        exec rm ${design_name}_for_transposed_data_1.csv
     } 
  };# mail for init  
  if {([lindex $argv 0] == "compile") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_2.csv]} {
        set stage "compile"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_2.csv $stage
        exec rm ${design_name}_for_transposed_data_2.csv
     } 
  };# mail for compile  
   if {([lindex $argv 0] == "place") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_3.csv]} {
        set stage "place"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_3.csv $stage
        exec rm ${design_name}_for_transposed_data_3.csv
     } 
  };# mail for place  
   if {([lindex $argv 0] == "cts_only") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_4.csv]} {
        set stage "cts_only"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_4.csv $stage
        exec rm ${design_name}_for_transposed_data_4.csv
     } 
  };# mail for cts_only
   if {([lindex $argv 0] == "cts") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_5.csv]} {
        set stage "cts"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_5.csv $stage
        exec rm ${design_name}_for_transposed_data_5.csv
     } 
  };# mail for cts  
   if {([lindex $argv 0] == "route") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_6.csv]} {
        set stage "route"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_6.csv $stage
        exec rm ${design_name}_for_transposed_data_6.csv
     } 
  };# mail for route  

 #===============================================================================


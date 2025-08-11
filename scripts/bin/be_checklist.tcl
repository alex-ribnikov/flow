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
     
      if {([file exist $WA/$pnr/${design_name}_be_checklist_summary.csv]) && ([lindex $argv 0] != "general_floorplan") && ([lindex $argv 0] != "all")} {
         # update the file:
         set OFILE [open  $WA/$pnr/${design_name}_be_checklist_summary.csv a]
      } else {
         set OFILE [open  $WA/$pnr/${design_name}_be_checklist_summary.csv w]

      }

     #===============================================================================
     #                                PROCs
     #===============================================================================
     source     $WA/$pnr/scripts/procs/common/be_mails.tcl

     proc analyzed_log_scan {{stage} } {
     # find the latest <stage>.log
     find_latest_log $stage
     if {[file exist log/[exec cat latest_${stage}.log]]} {
         logscan log/[exec cat latest_${stage}.log]
           if {[file exist log/[exec cat latest_${stage}.log].errSum]} {
             set fo [open log_scan_results w]
             set ft [open log_scan_results_for_transposed w]
              foreach num {1 2} {
                 if {$num==1} {
                   puts $fo "log scan results for stage $stage,\"[regsub "#" [exec cat log/[exec cat latest_${stage}.log].errSum | egrep "Error Messages"] ""] "
                   puts -nonewline $ft "log scan results for stage $stage,\"[regsub "#" [exec cat log/[exec cat latest_${stage}.log].errSum | egrep "Error Messages"] ""]: "
                 } else {
                   puts $fo "[regsub "#" [exec cat log/[exec cat latest_${stage}.log].errSum | egrep "Warning Messages"] ""]\",[exec pwd]/log/[exec cat latest_${stage}.log].errSum" 
                   puts $ft "[regsub "#" [exec cat log/[exec cat latest_${stage}.log].errSum | egrep "Warning Messages"] ""]\",[exec pwd]/log/[exec cat latest_${stage}.log].errSum" 
                 }
              }
            close $fo
            close $ft
          } else {
             puts $fo "log scan results for stage $stage, NA check,[exec pwd]/log/${stage}.log.errSum "
             puts $ft "log scan results for stage $stage, NA check,[exec pwd]/log/${stage}.log.errSum "
          }
     } else {
       puts $fo "log scan results for stage $stage, NA check,[exec pwd]/log/${stage}.log* "
       puts $ft "log scan results for stage $stage, NA check,[exec pwd]/log/${stage}.log* "
     }
   };# analyzed_log_scan
     #=================================================
     proc find_latest_log {{stage}} {
    if {[catch {exec ls log/  | egrep ${stage}.log | egrep -v "full|errSum"}] == 0 } {
          set fo [open innovus.log w]
          set fo_log [open latest_${stage}.log w]
          puts  $fo "[exec ls log/ | egrep "${stage}\.log" | egrep -v "errSum|full"]"
          close $fo
          puts $fo_log "[exec tail -n 1 innovus.log]"
          close $fo_log
          exec rm innovus.log
       } else {
         exec touch latest_${stage}.log
       }
     };# find_latest_log 
     #=================================================
     # check the filelist file:
     proc check_filelist {{file_to_check ""}} {
          set list_of_paths ""
          set fo [open rtl_list.rpt w]
          set fot [open rtl_list_trans.rpt w]
          if {[check_grep $file_to_check "srcfile|rtl_files" 1 ]} {
             set fi [open [lindex [exec cat $file_to_check | egrep "srcfile|rtl_files"] 1] r]
             while {[gets $fi line]>=0}  {
                 lappend list_of_paths [regsub "[lindex [split $line "/"] end]" $line ""]
              }
              set first_puts 1
              foreach link [lsort -u  $list_of_paths] {
                if {$first_puts==1} {
                  puts $fo "link to RTL files,\"$link"
                  puts -nonewline $fot "link_to_RTL_files,\"$link:"
                  incr first_puts 
               } else {
                  puts $fo "$link"
                  puts -nonewline $fot "$link:"
               }
              }
              puts $fo "\", $file_to_check "
              puts $fot "\" "
          } else {
             puts $fo "link to RTL files, NA check,  $WA/inter/filelist"
             puts $fot "link_to_RTL_files,NA"
          }
      close $fo
      close $fot
     };#check_filelist
     #=================================================
     # Host name
     proc host_name {{WA} {pnr} {stage}} {
        set fo [open host.rpt w]
        find_latest_log $stage
        if {[check_grep latest_${stage}.log "${stage}"] } {
           set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
           if {[check_grep ${WA}/${pnr}/log/$log_file "Host:" ]} {
              puts $fo "Host name,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Host:"] 1],${WA}/${pnr}/log/$log_file"
           } else {
              puts $fo "Host name,NA check,${WA}/${pnr}/log/$log_file"
           }   
        } else {
           puts $fo "Host name,NA check,${WA}/${pnr}/log/[exec tail -n 1 latest_${stage}.log]"
        }   
        exec rm latest_${stage}.log
       close $fo
       
     };#host_name
     #=================================================
     # Innovus version:
     proc innovus_version {{WA} {pnr} {stage}} {
      set fo [open innovus_version.rpt w]
      if {[file exist ${WA}/${pnr}/log/${stage}.log]} {
           find_latest_log $stage
           if {[check_grep latest_${stage}.log "${stage}"] } {
              set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
              if {[check_grep ${WA}/${pnr}/log/$log_file "Version:" 1 ]} {
                 puts $fo "Innovus version,[lindex [split [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Version:"] 1] ","] 0],${WA}/${pnr}/log/$log_file"
              } else {
                 puts $fo "Innovus version,NA check,${WA}/${pnr}/log/$log_file"
              }   
           } else {
              puts $fo "Innovus version,NA check,${WA}/${pnr}/log/[exec tail -n 1 latest_${stage}.log]"
           }   
           
           exec rm latest_${stage}.log
         } else {
              puts $fo "Innovus version,NA check, ${WA}/${pnr}/log/${stage}.log"

         }
         close $fo
     };# innovus_version 
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
     proc logscan {{log}} {
       set log_file $log

       set fp [open $log_file r]
       set fd [read $fp]
       close $fp
       
       set exclude_phrase  "^\@file\|^Suppress \|^Un-suppress \|puts +\"\-E\-\|puts +\"\-W\-\|\\\|Error \|\\\|Warning \|^ERROR     \|^INFO "
       set error_phrase   "ERROR\|Error\|\-E\-"
       set warning_phrase "WARN\|WARNING\|Warning\|\-W\-"
       
       set errors   {}
       set warnings {}
       foreach line [split $fd "\n"] {
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
     #=================================================
     proc get_data_transition {{stage} {design_name} {WA} {pnr}} {
       set fo [open reports/${stage}/report_from_trans.csv w]
       if {$stage != "route"} {
           if {[check_grep $WA/$pnr/reports/${stage}/${stage}.tran.gz "in the design" 3 ] } {
               puts $fo "data transition violations,[lindex [exec zcat $WA/$pnr/reports/${stage}/${stage}.tran.gz | egrep "in the design"] 3],$WA/$pnr/reports/${stage}/${stage}.tran.gz"
           } else {
               puts $fo "data transition violations,NA check,$WA/$pnr/reports/${stage}/${stage}.tran.gz "
           }  
       } else {
           if {[check_grep $WA/$pnr/reports/${stage}/${design_name}.tran.gz "in the design" 3 ] } {
               puts $fo "data transition violations,[lindex [exec zcat $WA/$pnr/reports/${stage}/${design_name}.tran.gz | egrep "in the design"] 3],$WA/$pnr/reports/${stage}/${design_name}.tran.gz "
           } else {
               puts $fo "data transition violations,NA check,$WA/$pnr/reports/${stage}/${design_name}.tran.gz "
           }  
       } 
       close $fo
     };#get_data_transition 
     #=================================================
     proc report_from_be_qor {{stage} {WA} {pnr} } {
      set fo [open reports/${stage}/report_from_be_qor.csv w]
      set ft [open reports/${stage}/report_from_be_qor_for_transpose.csv w]
      if {[file exist $WA/$pnr/reports/${stage}.be.qor]}  {
         # cell density
         if {[check_grep $WA/$pnr/reports/${stage}.be.qor "Pure STD Cell Density" 4 ] } {
              puts $fo "cell density,[lindex [ exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Pure STD Cell Density"] 4],$WA/$pnr/reports/${stage}.be.qor"
              puts $ft "cell density,[lindex [ exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Pure STD Cell Density"] 4],$WA/$pnr/reports/${stage}.be.qor"
           } else {
              puts $fo "cell density,NA check,$WA/$pnr/reports/${stage}.be.qor "
              puts $ft "cell density,NA check,$WA/$pnr/reports/${stage}.be.qor "
           }  
         # HotSpot Score, 
         if {$stage != "route"} {
           if {[check_grep $WA/$pnr/reports/${stage}.be.qor "Hotspot Score" 3 ]} {
                puts $fo "HotSpot Score,[lindex [ exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Hotspot Score"] 3],$WA/$pnr/reports/${stage}.be.qor"
                puts $ft "HotSpot Score,[lindex [ exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Hotspot Score"] 3],$WA/$pnr/reports/${stage}.be.qor"
             } else {
                puts $fo "HotSpot Score,NA check,$WA/$pnr/reports/${stage}.be.qor "
                puts $ft "HotSpot Score,NA check,$WA/$pnr/reports/${stage}.be.qor "
             } 
          } 
         #  report congestion
         if {$stage != "route"} {
           if {[check_grep $WA/$pnr/reports/${stage}.be.qor "H overflow" 3 ] } {
                set h_overflow [lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "H overflow"] 3]
                set v_overflow [lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "V overflow"] 3]
                puts $fo "report congestion,\" $h_overflow H "
                puts -nonewline $ft "report congestion,\" $h_overflow H "
                puts $fo "$v_overflow V\",$WA/$pnr/reports/${stage}.be.qor"
                puts $ft "$v_overflow V\",$WA/$pnr/reports/${stage}.be.qor"
             } else {
                puts $fo "report congestion,NA check,$WA/$pnr/reports/${stage}.be.qor "
                puts $ft "report congestion,NA check,$WA/$pnr/reports/${stage}.be.qor "
             }  
          } 
              # power
         if {[check_grep $WA/$pnr/reports/${stage}.be.qor "Total Internal Power" 3 ] } {
               puts $fo "Total Internal Power,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Total Internal Power"] 3] mW,$WA/$pnr/reports/${stage}.be.qor"
               puts $fo "Total Switching Power,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Total Switching Power"] 3] mW,$WA/$pnr/reports/${stage}.be.qor"
               puts $fo "Total Leakage Power,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Total Leakage Power"] 3] mW,$WA/$pnr/reports/${stage}.be.qor"
               puts $fo "Total Power,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Total Power"] 2] mW,$WA/$pnr/reports/${stage}.be.qor"
               puts $ft "Total Internal Power,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Total Internal Power"] 3] mW,$WA/$pnr/reports/${stage}.be.qor"
               puts $ft "Total Switching Power,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Total Switching Power"] 3] mW,$WA/$pnr/reports/${stage}.be.qor"
               puts $ft "Total Leakage Power,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Total Leakage Power"] 3] mW,$WA/$pnr/reports/${stage}.be.qor"
               puts $ft "Total Power,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Total Power"] 2] mW,$WA/$pnr/reports/${stage}.be.qor"
           } else {
              puts $fo "report Power,NA check,$WA/$pnr/reports/${stage}.be.qor "
              puts $ft "report Power,NA check,$WA/$pnr/reports/${stage}.be.qor "
           }  
              # Cell count
         if {[check_grep $WA/$pnr/reports/${stage}.be.qor "Leaf Cell Count" 3]} {
               puts $fo "Leaf Cell Count,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Leaf Cell Count"] 3],$WA/$pnr/reports/${stage}.be.qor"
               puts $ft "Leaf Cell Count,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Leaf Cell Count"] 3],$WA/$pnr/reports/${stage}.be.qor"
           } else {
              puts $fo "Leaf Cell Count,NA check,$WA/$pnr/reports/${stage}.be.qor "
              puts $ft "Leaf Cell Count,NA check,$WA/$pnr/reports/${stage}.be.qor "
           }  
           # how many FF in the design:
         if {[check_grep ${WA}/${pnr}/reports/${stage}.be.qor "Sequential Cell Count:" 3]} {
             puts  $fo "Sequential Cell Count(NO CG),[lindex [exec cat ${WA}/${pnr}/reports/${stage}.be.qor |  egrep "Sequential Cell Count:"] 3], ${WA}/${pnr}/reports/${stage}.be.qor"
             puts  $ft "Sequential Cell Count(NO CG),[lindex [exec cat ${WA}/${pnr}/reports/${stage}.be.qor |  egrep "Sequential Cell Count:"] 3], ${WA}/${pnr}/reports/${stage}.be.qor"
         } else {
             puts  $fo "Sequential Cell Count(NO CG),NA check, ${WA}/${pnr}/reports/${stage}.be.qor"
             puts  $ft "Sequential Cell Count(NO CG),NA check, ${WA}/${pnr}/reports/${stage}.be.qor"
         }
              # AREA
         if {[check_grep $WA/$pnr/reports/${stage}.be.qor "Leaf Cell Area" 3 ]} {
               puts $fo "Leaf Cell Area,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Leaf Cell Area"] 3] um^2,$WA/$pnr/reports/${stage}.be.qor"
               puts $ft "Leaf Cell Area,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Leaf Cell Area"] 3] um^2,$WA/$pnr/reports/${stage}.be.qor"
           } else {
              puts $fo "Leaf Cell Area,NA check,$WA/$pnr/reports/${stage}.be.qor "
              puts $ft "Leaf Cell Area,NA check,$WA/$pnr/reports/${stage}.be.qor "
           }  
              # %VT
         if {[check_grep $WA/$pnr/reports/${stage}.be.qor "^ULVT" ]} {
           puts $fo "report VT,\""
           puts -nonewline $ft "report VT,\""
           foreach vt {SVT LVT ULVT EVT} {
            exec cat $WA/$pnr/reports/${stage}.be.qor | egrep "^${vt}" > tmp_vt.rpt
            set fi [open tmp_vt.rpt r]
            while {[gets $fi line]>=0} {
              puts $fo "[lindex $line 0]   [lindex $line 4]"
              puts -nonewline $ft "[lindex $line 0]   [lindex $line 4]:"
            } 
           }
           puts $fo "\", $WA/$pnr/reports/${stage}.be.qor"
           puts $ft "\", $WA/$pnr/reports/${stage}.be.qor"
           exec rm tmp_vt.rpt

         } else {
              puts $fo "report VT,NA check,$WA/$pnr/reports/${stage}.be.qor "
              puts $ft "report VT,NA check,$WA/$pnr/reports/${stage}.be.qor "
           }  
          # MBIT
         if {[check_grep $WA/$pnr/reports/${stage}.be.qor "Multibit Conversion Ratio" ]} {
             puts  $fo "Multibit Conversion,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Multibit Conversion Ratio"] end]%,$WA/$pnr/reports/${stage}.be.qor"
             puts  $ft "Multibit Conversion,[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Multibit Conversion Ratio"] end]%,$WA/$pnr/reports/${stage}.be.qor"
        } elseif {[check_grep $WA/$pnr/reports/${stage}.be.qor "Multibit Conversion" ]} {
             puts  $fo "Multibit Conversion,[lindex [split [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Multibit Conversion"] "|"] end-1]%,$WA/$pnr/reports/${stage}.be.qor"
             puts  $ft "Multibit Conversion,[lindex [split [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "Multibit Conversion"] "|"] end-1]%,$WA/$pnr/reports/${stage}.be.qor"
          } else {
              puts $fo "Multibit Conversion,NA check,$WA/$pnr/reports/${stage}.be.qor "
              puts $ft "Multibit Conversion,NA check,$WA/$pnr/reports/${stage}.be.qor "
           }  
              # Setup Timing
           if {[check_grep $WA/$pnr/reports/${stage}.be.qor "reg2reg" 2 ]} {
            set print_count 1
           foreach type {reg2reg reg2cgate reg2out in2reg in2out} {
            if {[check_grep $WA/$pnr/reports/${stage}.be.qor "$type" 2 ]} {
              if {$print_count==1} {
                 puts $fo "Setup Timing(WNS/TNS/VP),\"[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 6] "
                 puts -nonewline $ft "Setup Timing(WNS/TNS/VP),\"[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 6]: "
                 incr print_count
              } else {
                puts $fo "[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 6]"
                puts -nonewline $ft "[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "$type" | head -n 1] 6]:"
              }
           } 
         } 
          puts $fo "\",$WA/$pnr/reports/${stage}.be.qor"
          puts $ft "\",$WA/$pnr/reports/${stage}.be.qor"
              
          } else {
              puts $fo "Setup Timing,NA check,$WA/$pnr/reports/${stage}.be.qor "
              puts $ft "Setup Timing,NA check,$WA/$pnr/reports/${stage}.be.qor "
          }  

         # Hold Timing
        if {($stage == "cts") || ($stage == "route")} {
            if {([check_grep $WA/$pnr/reports/${stage}.be.qor "reg2reg" 2 ]) && ([ llength [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "reg2reg"]] == 14)} {
                 puts $fo "Hold Timing(WNS/TNS/VP),[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 6],$WA/$pnr/reports/${stage}.be.qor "
                 puts $ft "Hold Timing(WNS/TNS/VP),[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 0]   [lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 2]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 4]/[lindex [exec cat  $WA/$pnr/reports/${stage}.be.qor |  egrep "reg2reg" | tail -n 1] 6],$WA/$pnr/reports/${stage}.be.qor "
            
          } else {
              puts $fo "Hold Timing,NA check,$WA/$pnr/reports/${stage}.be.qor "
              puts $ft "Hold Timing,NA check,$WA/$pnr/reports/${stage}.be.qor "
          }  
        }
        
      }  else {
            puts $fo "Main file ${stage}.be.qor.rpt,NA check, $WA/$pnr/reports/${stage}.be.qor.rpt"
            puts $ft "Main file ${stage}.be.qor.rpt,NA check, $WA/$pnr/reports/${stage}.be.qor.rpt"
      }
     
        close $fo  
        close $ft  
     
     };#report_from_be_qor
     #=================================================
      ##################
      # Run and parse check_drc
      ##################
      proc summary_check_drc {{stage} } {
        set fo [open short_drc.rpt w]
        if {[check_grep [exec pwd]/reports/${stage}/${stage}_check_drc.rpt "Total Violations" ] } {

           
           
           set fp [open [exec pwd]/reports/${stage}/${stage}_check_drc.rpt r]
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
         #  set rpt "-I- $cmd \n"
          
           foreach category [lsort [array names drc_arr]] {
               append rpt "[format %-${longest_name}s $category]: [llength $drc_arr($category)]\n"
               set total_drc [expr $total_drc + [llength $drc_arr($category)]]
           }
           append rpt "[format %-${longest_name}s "TOTAL DRC"]: $total_drc"
           
           puts $fo "$rpt"

        } else {
          #puts $fo "DRC summary, NA check,[exec pwd]/reports/route/route_check_drc.rpt" 
          # cat the DRC results, to short_summary file
           exec cat [exec pwd]/reports/${stage}/${stage}_check_drc.rpt > short_drc.rpt
        }  
        close $fo
      } ;# summary_check_drc

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

     proc report_path_groups {{WA} {pnr} {stage} {block_name}} {
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
                  foreach group "reg2reg reg2cgate reg2out in2reg in2out" {
                     puts $fo "$group,NA,NA,NA"
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


    };# report_path_groups
     #=================================================
     #===============================================================================


 if { ([lindex $argv 0] == "general_floorplan") || ([lindex $argv 0] == "all")} {
     #===============================================================================
     #                                General
     #===============================================================================
     set GFILE [open $WA/$pnr/${design_name}_for_transposed_data_1.csv w] 
     puts $OFILE "STAGE,        General"
     puts $OFILE "DATE,[exec date]"
     puts $OFILE "Work Area,${WA}/${pnr}"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         puts $GFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $GFILE "Time,[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         puts $GFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $GFILE "Time,[lindex $line 3] PM"
      } else {
         puts $GFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $GFILE "Time,[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	 } 
     set proj [find_proj $WA $pnr "place"]
     exec rm date.rpt
     puts $OFILE "PROJECT,$proj"
     puts $GFILE "Work_Area,${WA}/${pnr}"
     puts $GFILE "Block_Name,$block_name"
     puts $GFILE "PROJECT,$proj"
     puts $GFILE "STAGE,general"
     # some of the reports are under place/
     set stage "place"
     # Genus version:
     # check if syn OR syn"prefix"
     if {[file exist $WA/syn$prefix/log/do_syn.log]} {
         if {[check_grep $WA/syn$prefix/log/do_syn.log "Version:" 1]} {
           puts $OFILE "Genus version,[lindex [split [lindex [exec cat $WA/syn$prefix/log/do_syn.log | egrep "Version:"] 1] ","] 0],$WA/syn$prefix/log/do_syn.log"
          } else {
           puts $OFILE "Genus version,NA check,$WA/syn$prefix/log/do_syn.log"
          }
     } elseif {[file exist $WA/syn/log/do_syn.log]} {
          if {[check_grep $WA/syn/log/do_syn.log "Version:" 1]} {
            puts $OFILE "Genus version,[lindex [split [lindex [exec cat $WA/syn/log/do_syn.log | egrep "Version:"] 1] ","] 0],$WA/syn/log/do_syn.log"
          } else {
            puts $OFILE "Genus version,NA check,$WA/syn/log/do_syn.log"
          }
     } else {
         puts $OFILE "Genus version,NA check,$WA/syn/log/do_syn.log"

     }
     #================================================
     # link to scripts version:
      set fo [open tmp w]
      puts $fo "[exec ls -lt scripts]"
      close $fo
      puts $OFILE "scripts version,[ lindex [exec cat tmp] end]"
      puts $GFILE "scripts_version,[ lindex [exec cat tmp] end]"
      exec rm tmp
     #================================================
     # check contains of scripts_local 
      set fo [open tmp w]
      puts $fo "[exec ls  scripts_local]"
      close $fo
      set fi [open tmp r]
      puts $OFILE "Check these files under scripts_local/,\""
      puts -nonewline $GFILE "files_under_scripts_local,\""
      while {[gets $fi line]>=0} {
        if {![regexp {mmmc_results|supplement_setup} $line]} {
             puts  $OFILE "$line"
             puts  -nonewline $GFILE "$line:"
           }
        }
        puts  $OFILE "\", $WA/$pnr/scripts_local"
        puts $GFILE "\" "
        puts $GFILE "files_under_scripts_local_input,$WA/$pnr/scripts_local"
      exec rm tmp
     #================================================
    # need to activate file ./scripts/bin/parse_args.csh, to generate the default values
    #  --> .tmp_user_inputs.tcl
    exec ./scripts/bin/parse_args.csh innovus
    puts $OFILE "Results compare user_inputs.tcl TO default setting (.tmp_user_inputs.tcl),\""
    puts -nonewline $GFILE "compare_user_inputs_2_default_setting,\""
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
                   puts -nonewline $GFILE "[lindex $line 1] [lindex $line 2]:" 
                 } 
              }
   
           } else {
              # parameter doesn't exsit in default
                  puts $OFILE "[lindex $line 1] [lindex $line 2]"  
                  puts -nonewline $GFILE "[lindex $line 1] [lindex $line 2]:"  
   
           }
   
        }
      };# while fi_cmp...
      puts $OFILE "\", $WA/$pnr/user_inputs.tcl"
      puts $GFILE "\""
      puts $GFILE "compare_user_inputs_2_default_setting_input, $WA/$pnr/user_inputs.tcl"
   
     } else {
      puts $OFILE "Results compare user_inputs.tcl TO default setting (.tmp_user_inputs.tcl),Can't find  $WA/$pnr/user_inputs.tcl ||  $WA/$pnr/.tmp_user_inputs.tcl"
      puts $GFILE "compare_user_inputs_2_default_setting,NA"
     }
  
 

    #================================================
    # links to RTL, locations 
     set netlist ""
     set stage "floorplan"
     find_latest_log $stage
     if {[check_grep latest_${stage}.log "${stage}"] } {
       set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
       if {[check_grep ${WA}/${pnr}/log/$log_file "Reading verilog netlist" 3 ]} {
           if {[catch {exec realpath [regsub -all "'" [lindex [exec cat  ${WA}/${pnr}/log/$log_file | egrep "Reading verilog netlist"] 3] ""]}] == 0} { 
            set netlist [exec realpath [regsub -all "'" [lindex [exec cat  ${WA}/${pnr}/log/$log_file | egrep "Reading verilog netlist"] 3] ""]]
           } else {
             set netlist "NA"    
           }
       }
     }
    # check in place, if we don't run here floorplan stage
    if {$netlist == ""} {   
       set stage "place"
       find_latest_log $stage
       if {[check_grep latest_${stage}.log "${stage}"] } {
         set log_file [exec cat latest_${stage}.log | egrep "${stage}"]
         if {[check_grep ${WA}/${pnr}/log/$log_file "Reading verilog netlist" 3 ]} {
           # check maybe the netlist was deleted fro WA 
           if {[catch {exec realpath [regsub -all "'" [lindex [exec cat  ${WA}/${pnr}/log/$log_file | egrep "Reading verilog netlist"] 3] ""]}] == 0} { 
             set netlist [exec realpath [regsub -all "'" [lindex [exec cat  ${WA}/${pnr}/log/$log_file | egrep "Reading verilog netlist"] 3] ""]]
           } else {
             set netlist "NA"    
           }
         }
       }
    }

     if {([lsearch -regexp $netlist $WA] == -1) && ($netlist != "")} {
        # the netlist ISN'T from our WA
          puts $OFILE "link to RTL files,$netlist,${WA}/${pnr}/log/$log_file"
          puts $GFILE "link_to_RTL_files,$netlist"

     } elseif {[file exist $WA/[lsearch -inline [split $netlist "/"] syn*]/filelist] && ($netlist != "") && (![regexp {scripts_local} $netlist])} {
        # if we read verilog & it is from our WA syn..., check for filelist (netlist NOT under scripts_local/)
         check_filelist  $WA/[lsearch -inline [split $netlist "/"] syn*]/filelist
         if {[file exist rtl_list.rpt]} {
            set fi [open rtl_list.rpt r]
            while {[gets $fi line]>=0} {
               puts $OFILE "$line"
            }
         } else {
             puts $OFILE "link to RTL files, NA check, $WA/rtl_list.rpt (syn*/filelist) "
         }
         if {[file exist rtl_list_trans.rpt]} {
            set fi [open rtl_list_trans.rpt r]
            while {[gets $fi line]>=0} {
               puts $GFILE "$line"
            }
         } else {
             puts $GFILE "link_to_RTL_files,NA"
         }
     } elseif {[file exist $WA/inter/filelist] && ($netlist != "") && (![regexp {scripts_local} $netlist])} {
        # if we read verilog & it is from our WA. syn..., check for filelist, under inter/ (netlist NOT under scripts_local/)
         check_filelist  $WA/inter/filelist
         if {[file exist rtl_list.rpt]} {
            set fi [open rtl_list.rpt r]
            while {[gets $fi line]>=0} {
               puts $OFILE "$line"
            }
         } else {
             puts $OFILE "link to RTL files, NA check, $WA/rtl_list.rpt (inter/filelist) "
         }
         if {[file exist rtl_list_trans.rpt]} {
            set fi [open rtl_list_trans.rpt r]
            while {[gets $fi line]>=0} {
               puts $GFILE "$line"
            }
         } else {
             puts $GFILE "link_to_RTL_files,NA"
         }
     } elseif {[regexp {scripts_local} [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "set NETLIST_FILE" | head -n 1] 4] ]} {
        # if netlist taken under scripts_local/..
          puts $OFILE "link to RTL files,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "set NETLIST_FILE" | head -n 1] 4],"
          puts $GFILE "link_to_RTL_files,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "set NETLIST_FILE" | head -n 1] 4],"
     } elseif {[check_grep ${WA}/${pnr}/log/$log_file "Reading verilogBinary netlist" ]} {
          # we start place from db
          puts $OFILE "link to RTL files,[regsub -all "'" [lindex [exec cat  ${WA}/${pnr}/log/$log_file | egrep "Reading verilogBinary netlist"] 3 ] "" ],${WA}/${pnr}/log/$log_file"
          puts $GFILE "link_to_RTL_files,[regsub -all "'" [lindex [exec cat  ${WA}/${pnr}/log/$log_file | egrep "Reading verilogBinary netlist"] 3 ] "" ]"
       } else {
           puts $OFILE "link to RTL files,NA check,${WA}/${pnr}/log/$log_file"
           puts $GFILE "link_to_RTL_files,NA"
       }
     

     #================================================
     # link to Libs, for STD & MEMs/Macros/...
     
     set list_of_paths ""
     if {[check_grep $WA/$pnr/scripts/setup/setup.${proj}.tcl  "\.lib\.gz" ]} {
        exec cat $WA/$pnr/scripts/setup/setup.${proj}.tcl | egrep "\.lib\.gz" > tmp
        exec sed -i {s/\\//g} tmp
        set fi [open tmp r]
        while {[gets $fi line]>=0}  {
            lappend list_of_paths [regsub "[lindex [split $line "/"] end]" $line ""]
         }
         set first_puts 1
         foreach link [regsub -all "\{|\}" [lsort -u $list_of_paths] ""] {
           if {$first_puts==1} {
             puts  $OFILE "link to STD LIBs files,\"$link"
             incr first_puts 
          } else {
             puts  $OFILE "$link"
          }
         }
         puts  $OFILE "\", $WA/$pnr/scripts/setup/setup.${proj}.tcl"
         exec rm tmp
     } else {
        puts $OFILE "link to STD LIBs files, NA check ,  $WA/$pnr/scripts/setup/setup.${proj}.tcl "
     }
     # check we can find LIBs for MEMs
     if {[check_grep $WA/inter/supplement_setup.tcl "\.lib" ]} {
        if {[catch {exec cat $WA/inter/supplement_setup.tcl | egrep "\.lib" }] == 0} {
           set list_of_paths ""
           exec cat $WA/inter/supplement_setup.tcl | egrep "\.lib" > tmp
           exec sed -i {s/\\//g} tmp
           set fi [open tmp r]
           while {[gets $fi line]>=0}  {
              lappend list_of_paths [regsub "[lindex [split $line "/"] end]" $line ""]
            }
           set first_puts 1
           foreach link [lsort -u  $list_of_paths] {
             if {$first_puts==1} {
               puts $OFILE  "link to MEMs LIBs files,\"$link"
               incr first_puts 
            } else {
               puts $OFILE "$line"
            }
           }
           puts  $OFILE "\", $WA/inter/supplement_setup.tcl"
     
        }
     } else {
          puts $OFILE "link to MEMs LIBs files, NA check , $WA/inter/supplement_setup.tcl  "
     }
     #================================================
       set stage "place"
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
         puts $GFILE "Calculate_MEMs_BITs,$calculate_bits"
         close $fi
       } else {
         puts $GFILE "Calculate_MEMs_BITs,NA"
       }
      # Calculate number of Transistors ~ Num Of STD * 6
       if {[check_grep $WA/$pnr/reports/${stage}/preplace_count.rpt "Leaf_Cells_Count"]} {
          set fi [open $WA/$pnr/reports/${stage}/preplace_count.rpt r] 
          while {[gets $fi line]>=0} {
             if {[regexp {Leaf_Cells_Count} $line]} {
              puts $OFILE "Calculate the number of transistors,[expr [lindex $line  2] * 6 ],$WA/$pnr/reports/${stage}/preplace_count.rpt "
            }
           }
        } else {
         puts $OFILE "Calculate the number of transistors,NA check,$WA/$pnr/reports/${stage}/preplace_count.rpt"
       }
     #================================================
     #  Check bonus cells (spare) - Need to Add !!!!!!
       puts $OFILE "bonus cells, NA (need to add this one) !!!!!"
       puts $GFILE "bonus_cells,NA"
     #================================================
     #===============================================================================

     #===============================================================================
     #                                FloorPlan/Preplace
     #===============================================================================
     set FFILE [open $WA/$pnr/${design_name}_for_transposed_data_2.csv w] 
     puts $OFILE "STAGE,        FLOORPLAN"
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
     exec rm date.rpt
     puts $FFILE "Work_Area,${WA}/${pnr}"
     puts $FFILE "Block_Name,$block_name"
     puts $FFILE "PROJECT,$proj"
     puts $FFILE "STAGE,floorplan"
     # because all the pre-place reports are under place/
     set stage "place"
     if {[check_grep ${WA}/${pnr}/reports/${stage}/check_floorplan_preplace.rpt "Message Summary:" ]} {
        set results_check_floorplan [exec cat ${WA}/${pnr}/reports/${stage}/check_floorplan_preplace.rpt | egrep "Message Summary:"]
        puts  $OFILE "check floorplan,[lindex $results_check_floorplan 3] [regsub "," [lindex $results_check_floorplan 4] ""] [lindex $results_check_floorplan 5] [lindex $results_check_floorplan 6], ${WA}/${pnr}/reports/${stage}/check_floorplan_preplace.rpt"
       puts $FFILE "check_floorplan_warnings,[lindex $results_check_floorplan 3]"
       puts $FFILE "check_floorplan_errors,[lindex $results_check_floorplan 5]"
     } else {
         puts  $OFILE "check floorplan,NA check, ${WA}/${pnr}/reports/${stage}/check_floorplan_preplace.rpt"
         puts  $FFILE "check_floorplan_warnings,NA"
         puts  $FFILE "check_floorplan_errors,NA"
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
             incr first_puts 
           } else {
             puts $OFILE "$line"
           }
         }
       }
       puts $OFILE "\",$WA/$pnr/reports/${stage}/reports_physical_cells.rpt"
    } else {
       puts $OFILE "physical cells,NA check, $WA/$pnr/reports/${stage}/reports_physical_cells.rpt"

    }
     #================================================
   # report check timing
    if {[check_grep ${WA}/${pnr}/reports/${stage}/check_timing_summary.rpt "#|-|Warning|TIMING" ]} {
        exec cat reports/${stage}/check_timing_summary.rpt | egrep -v "#|-|Warning|TIMING" > ct.rpt
        set fi [open ct.rpt r]
           puts  $OFILE "check timing,\""
           while {[gets $fi line]>=0} {
              puts  $OFILE "$line"
           }
         puts  $OFILE "\",${WA}/${pnr}/reports/${stage}/check_timing_summary.rpt"  
         exec rm ct.rpt 
     } else {
         puts  $OFILE "check timing,NA check, ${WA}/${pnr}/reports/${stage}/check_timing_summary.rpt"
         puts  $FFILE "check timing,NA"
     }
 
     #================================================
   # preplace - leaf cell count
    if {[check_grep ${WA}/${pnr}/reports/${stage}/preplace_count.rpt "Leaf Instance count" 4 ]} {
         puts $OFILE "Leaf Instance count,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/preplace_count.rpt | egrep "Leaf Instance count"] 4],${WA}/${pnr}/reports/${stage}/preplace_count.rpt"
         puts $FFILE "Leaf_Instance_count,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/preplace_count.rpt | egrep "Leaf Instance count"] 4]"
     } else {
         puts  $OFILE "Leaf Instance count,NA check, ${WA}/${pnr}/reports/${stage}/preplace_count.rpt"
         puts  $FFILE "Leaf_Instance_count,NA"
      }
   # preplace - Sequential Instance Count
    if {[check_grep ${WA}/${pnr}/reports/${stage}/preplace_count.rpt "Sequential Cells Count" 4 ]} {
         puts $OFILE "Sequential Cells Count(NO CG),[lindex [exec cat ${WA}/${pnr}/reports/${stage}/preplace_count.rpt | egrep "Sequential Cells Count"] 4],${WA}/${pnr}/reports/${stage}/preplace_count.rpt"
         puts $FFILE "Sequential_Cells_Count_NO_CG,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/preplace_count.rpt | egrep "Sequential Cells Count"] 4]"
     } else {
         puts  $OFILE "Sequential Cells Count(NO CG),NA check, ${WA}/${pnr}/${stage}/reports/preplace_count.rpt"
         puts  $FFILE "Sequential_Cells_Count_NO_CG,NA"
     }
   # preplace - report VT
    if {[check_grep ${WA}/${pnr}/reports/${stage}/preplace_count.rpt "VT" ]} {
       puts $OFILE "report VT,\""
       foreach vt {SVT LVT LVTLL ULVTLL ULVT EVT} {
         puts $OFILE "$vt  [lindex [exec cat ${WA}/${pnr}/reports/${stage}/preplace_count.rpt | egrep "^${vt} "] 2]"
       }
       puts $OFILE "\",${WA}/${pnr}/reports/${stage}/preplace_count.rpt"

    } else {
         puts  $OFILE "Sequential Instance Count,NA check, ${WA}/${pnr}/reports/${stage}/preplace_count.rpt"
    }
    close $GFILE
    close $FFILE
    # ONLY for sending mail, preplace
    set stage "preplace"
 };# general_floorplan   
#===============================================================================
#                                 Place
#===============================================================================
  
 if {([file exist .place_done]) && (([lindex $argv 0] == "place") || ([lindex $argv 0] == "all"))} {
     set PFILE [open $WA/$pnr/${design_name}_for_transposed_data_3.csv w] 
     set stage "place"
     puts $OFILE "STAGE,        PLACE"
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
     set proj [find_proj $WA $pnr $stage]
     exec rm date.rpt
     puts $PFILE "Work_Area,${WA}/${pnr}"
     puts $PFILE "Block_Name,$block_name"
     puts $PFILE "PROJECT,$proj"
     puts $PFILE "STAGE,place"
     set stage "place"
    # host name:
     host_name $WA $pnr $stage
    if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $PFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
    } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $PFILE "Host_name,NA"
    }

     innovus_version $WA $pnr $stage
    if {[check_grep  innovus_version.rpt "Innovus version" ]} {
         puts $OFILE "[ exec cat innovus_version.rpt | head -n 1]"
         puts $PFILE "Innovus_version,[lindex [ split [exec cat innovus_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "Innovus version,NA check,innovus_version.rpt"
         puts $PFILE "Innovus_version,NA"
    }

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
         puts $OFILE  "IO buffers statistics,NA check,  $WA/$pnr/${stage}/reports/io_buffers_statistics.csv"
         puts $PFILE  "Total_IO_buffers,NA,$WA/$pnr/reports/${stage}/io_buffers_statistics.csv"
         puts $PFILE  "Total_IO_buffers_input,$WA/$pnr/reports/${stage}/io_buffers_statistics.csv"

      }
     #================================================
     # Measure length between IO buffers & ports:
       if {[check_grep $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt "MAX length between port" 7 ]} {
          puts $OFILE "Measure distance between IO buffers to ports(Max value),[ lindex [exec cat $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt | egrep "MAX length between port"] 7] um, $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt"
          puts $PFILE "Max_distance_IO_buffers_to_ports\[um\],[ lindex [exec cat $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt | egrep "MAX length between port"] 7]"
          puts $PFILE "Max_distance_IO_buffers_to_ports_input,$WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt"

      } else {
         puts $OFILE "Measure distance between IO buffers to ports(Max value), NA check, $WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt"
          puts $PFILE "Max_distance_IO_buffers_to_ports\[um\],NA"
          puts $PFILE "Max_distance_IO_buffers_to_ports_input,$WA/$pnr/reports/${stage}/measure_distance_between_io_buffers_to_ports.rpt"
      }
     #================================================
     # IO Sampled BY MB
       if {[file exist $WA/$pnr/reports/${stage}/io_sampled.rpt]} {
         set fi [open $WA/$pnr/reports/${stage}/io_sampled.rpt r]
         while {[gets $fi line]>=0} {
            if {[regexp {\-I\-|\-E\-} $line]} {
             puts $OFILE "IO Sampled BY MB,[regsub "," [lindex $line 2] ""],$WA/$pnr/reports/${stage}/io_sampled.rpt"
             puts $PFILE "IO_Sampled_BY_MB,[regsub "," [lindex $line 2] ""]"
             puts $PFILE "IO_Sampled_BY_MB_input,$WA/$pnr/reports/${stage}/io_sampled.rpt"
          }
         }
      } else {
         puts $OFILE "IO Sampled BY MB, NA check, $WA/$pnr/reports/${stage}/io_sampled.rpt"
         puts $PFILE "IO_Sampled_BY_MB,NA"
         puts $PFILE "IO_Sampled_BY_MB_input,$WA/$pnr/reports/${stage}/io_sampled.rpt"
      }
     #================================================
     # IO Buffers driving output ports:
     if {[file exist $WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt]} {
       set fi [open $WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt r]
       while {[gets $fi line]>=0} {
          if {[regexp {\-I\-|\-E\-} $line]} {
           puts $OFILE "Number of IO Buffers driving ports violations,[regsub "," [lindex $line 2] ""],$WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt"
           puts $PFILE "IO_Buffers_driving_ports_violations,[regsub "," [lindex $line 2] ""]"
           puts $PFILE "IO_Buffers_driving_ports_violations_input,$WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt"
        }
       }
     } else {
        puts $OFILE "Number of IO Buffers driving ports violations,NA check, $WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt"
        puts $PFILE "IO_Buffers_driving_ports_violations,NA"
        puts $PFILE "IO_Buffers_driving_ports_violations_input,$WA/$pnr/reports/${stage}/io_buffers_driving_ports.rpt"
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
           puts $PFILE "HotSpot_Score,[lindex [split $line ","] 1]"
           puts $PFILE "HotSpot_Score_input,[lindex [split $line ","] 2]"
          }
          if {[regexp {Setup Timing} $line]} {
            foreach tm [regsub -all {\"} [split [lindex [split $line ","] 1] ":"] ""] {
               if {$tm!=""} {
                set i 0
                foreach case "wns tns vp" {
                   puts $PFILE "[lindex $tm 0]_${case},[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i]"
                   incr i
                }
              }
            }
          }
        }
        # generate timing table, per stage
        report_path_groups $WA $pnr $stage $block_name
        exec rm reports/${stage}/report_from_be_qor_for_transpose.csv
     } else {
        puts $PFILE "HotSpot_Score,NA"
        puts $PFILE "HotSpot_Score_input,reports/${stage}/report_from_be_qor_for_transpose.csv"
        foreach group "reg2reg reg2cgate reg2out in2reg in2out" {
           foreach case "wns tns vp" {
              puts $PFILE "${group}_$case,NA"

           }
        }

     }

    #================================================
    # check data transition:
    get_data_transition $stage $design_name $WA $pnr
    if {[file exist reports/${stage}/report_from_trans.csv]} {
       set fi [open reports/${stage}/report_from_trans.csv r]
        while {[gets $fi line]>=0} {
           puts $OFILE "$line"
           puts $PFILE "data_transition_violations,[lindex [split $line ","] 1]"
           puts $PFILE "data_transition_violations_input,[lindex [split $line ","] 2]"
        } 
       close $fi
     #  exec rm reports/${stage}/report_from_trans.csv
    } else {
       puts $OFILE "data transition violations,NA check,reports/${stage}/report_from_trans.csv"
       puts $PFILE "data_transition_violations,NA"
       puts $PFILE "data_transition_violations_input,reports/${stage}/report_from_trans.csv"
    }
    #================================================
    #================================================
    # check floorplan after place
    if {[check_grep ${WA}/${pnr}/reports/${stage}/check_floorplan_place.rpt "Message Summary:" ]} {
        set results_check_floorplan [exec cat ${WA}/${pnr}/reports/${stage}/check_floorplan_place.rpt | egrep "Message Summary:"]
        puts  $OFILE "check floorplan,[lindex $results_check_floorplan 3] [regsub "," [lindex $results_check_floorplan 4] ""] [lindex $results_check_floorplan 5] [lindex $results_check_floorplan 6],${WA}/${pnr}/reports/${stage}/check_floorplan_place.rpt"
        puts  $PFILE "check_floorplan_warnings,[lindex $results_check_floorplan 3]"
        puts  $PFILE "check_floorplan_errors,[lindex $results_check_floorplan 5]"
     } else {
        puts  $OFILE "check floorplan,NA check, ${WA}/${pnr}/reports/${stage}/check_floorplan_place.rpt"
        puts  $PFILE "check_floorplan_warnings,NA"
        puts  $PFILE "check_floorplan_errors,NA"
     }
     # log scan
        analyzed_log_scan $stage
        puts $OFILE "[exec cat log_scan_results]"
        puts $PFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $PFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed
        
      close $PFILE
  };# place 
     #===============================================================================
     #                                 CTS
     #===============================================================================
   if {([file exist .cts_done]) && (([lindex $argv 0] == "cts") || ([lindex $argv 0] == "all"))} {
     set CFILE [open $WA/$pnr/${design_name}_for_transposed_data_4.csv w] 
     set stage "cts"
     puts $OFILE "STAGE,        CTS"
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
     set proj [find_proj $WA $pnr $stage]
     exec rm date.rpt
     puts $CFILE "Work_Area,${WA}/${pnr}"
     puts $CFILE "Block_Name,$block_name"
     puts $CFILE "PROJECT,$proj"
     puts $CFILE "STAGE,cts"
    #================================================
    # host name:
     host_name $WA $pnr $stage
    if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $CFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
    } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $CFILE "Host_name,NA"
    }
     innovus_version $WA $pnr $stage
    if {[check_grep  innovus_version.rpt "Innovus version" ]} {
         puts $OFILE "[ exec cat innovus_version.rpt | head -n 1]"
         puts $CFILE "Innovus_version,[lindex [ split [exec cat innovus_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "Innovus version,NA check,innovus_version.rpt"
         puts $CFILE "Innovus_version,NA"
    }
     # how many clock INV in the design:
     if {[check_grep ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt "^Inverters" 1 ]} {
        if {[lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Inverters"] 1] > 0} {
           exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "inverter" > tmp
           set fi [open tmp r]
           puts $OFILE "Clock inverters,\""
           while {[gets $fi line]>=0} {
             puts $OFILE "[lindex $line 0]   [lindex $line 2]"
           }
           puts $OFILE "Total Clock Inverters  [lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Inverters"] 1]:"
           puts $CFILE "Total_Clock_Inverters,[lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Inverters"] 1]"
           puts $OFILE "\",${WA}/${pnr}/reports/cts/cts_clock_trees.rpt"
         } else {
           puts $OFILE "Clock inverters,Total Inverters  [lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Inverters"] 1],${WA}/${pnr}/reports/cts/cts_clock_trees.rpt"
           puts $CFILE "Total_Clock_Inverters,[lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Inverters"] 1]"

         }

     } else {
         puts   $OFILE "Clock inverters,NA check, ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt"
         puts $CFILE "Total_Clock_Inverters,NA"
     }
    #================================================
     # how many clock BUF in the design:
     if {[check_grep ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt "^Buffers" 1 ]} {
        if {[lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Buffers"] 1] > 0} {
           exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "buffer" > tmp
           set fi [open tmp r]
           puts $OFILE "Clock buffers,\""
           while {[gets $fi line]>=0} {
              puts $OFILE "[lindex $line 0]   [lindex $line 2]"
           }
           puts $OFILE "Total Clock Buffers  [lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Buffers"] 1]"
           puts $CFILE "Total_Clock_Buffers,[lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Buffers"] 1]"
           puts $OFILE "\",${WA}/${pnr}/reports/cts/cts_clock_trees.rpt"
         } else {
           puts $OFILE "Clock buffers,Total Clock Buffers  [lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Buffers"] 1],${WA}/${pnr}/reports/cts/cts_clock_trees.rpt"
           puts $CFILE "Total_Clock_Buffers,[lindex [exec cat ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt | egrep "^Buffers"] 1]"

         }

     } else {
         puts   $OFILE "Clock buffers,NA check, ${WA}/${pnr}/reports/cts/cts_clock_trees.rpt"
         puts   $CFILE "Total_Clock_buffers,NA"
     }
    #================================================
     #  clock cells violations (NO ulvt, *aoi*,..) 
     if {[check_grep ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells.rpt "clock tree violations" 3 ]} {
         puts  $OFILE "clock tree cells violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells.rpt |  egrep "clock tree violations"] 3], ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells.rpt"
         puts  $CFILE "clock_tree_cells_violations,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells.rpt |  egrep "clock tree violations"] 3]"
     } else {
         puts  $OFILE "clock tree cells violations,NA check, ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells.rpt"
         puts  $CFILE "clock_tree_cells_violations,NA"
     }
    #================================================
     #  number of min delay cells, named 'i_cts_hold'  
     if {[check_grep ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells.rpt "number of min delay cells" 6 ]} {
         puts  $OFILE "number of min delay cells,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells.rpt |  egrep "number of min delay cells"] 6], ${WA}/${pnr}/${stage}/reports/reports_clock_tree_cells.rpt"
         puts  $CFILE "number_of_min_delay_cells,[lindex [exec cat ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells.rpt |  egrep "number of min delay cells"] 6]"
     } else {
         puts  $OFILE "number of min delay buffers,NA check, ${WA}/${pnr}/reports/${stage}/reports_clock_tree_cells.rpt"
         puts  $CFILE "number_of_min_delay_cells,NA"
     }
    #================================================
    #  USEFUL SKEW
     find_latest_log $stage
     if {[check_grep latest_cts.log "cts"] } {
         set log_file [exec cat latest_cts.log | egrep "cts"]
         if {[check_grep ${WA}/${pnr}/log/$log_file "set USEFUL_SKEW" 4]} {
              puts $OFILE  "USEFUL_SKEW,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep  "set USEFUL_SKEW"] 4],${WA}/${pnr}/log/$log_file"
              puts $CFILE  "USEFUL_SKEW,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep  "set USEFUL_SKEW"] 4]"
       set  USEFUL_SKEW [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep  "set USEFUL_SKEW"] 4]
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
    

 #================================================
 # Clocks Levels
  if {[check_grep ${WA}/${pnr}/reports/${stage}/all_clocks.trace "Clock tree"]} {
      set fi [open ${WA}/${pnr}/reports/${stage}/all_clocks.trace r]
       set clock_list ""
       set level_list ""
       while {[gets $fi line]>=0} {
         if {[regexp {Clock tree} $line ]} {
             lappend clock_list [lindex [split $line ":"] 0 2]
         }
         if {[regexp {Max Level} $line ]} {
             lappend level_list [lindex $line 2]
         }
       }
   } else {
     puts $OFILE "clocks Levels,NA check,${WA}/${pnr}/reports/${stage}/all_clocks.trace"
   } 
 #============================================================
     #  MIN ID,MAX ID, AVG ID, target_skew,global skew, Skew window occupancy
 if {[check_grep ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt "none "]} {
     set min_id "" 
     set max_id "" 
     set avg_id "" 
     set global_skew "" 
     set target_skew "" 
     set skew_window_occupancy ""
     set i 0 
     foreach clk $clock_list { 
         puts $OFILE "LEVEL_${clk},[lindex $level_list $i],${WA}/${pnr}/reports/${stage}/all_clocks.trace"
         puts $CFILE "LEVEL_${clk},[lindex $level_list $i]"
         incr i
       if {[llength [exec cat ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt | egrep "none " | egrep -v __cdc | egrep $clk]] == 13} {
         set clk_line [exec cat ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt | egrep "none " | egrep -v __cdc | egrep $clk] 
         
         puts $OFILE "MIN_ID_${clk},[lindex $clk_line 3], ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE "MAX_ID_${clk},[lindex $clk_line 4], ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE "AVG_ID_${clk},[lindex $clk_line 5], ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE "Global_SKEW_${clk},[lindex $clk_line 10], ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE "Target_SKEW_${clk},[lindex $clk_line 9] , ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE "Skew_window_occupancy_${clk},[lindex $clk_line 11] \{[regsub "," [lindex $clk_line 12] ""]\}, ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $CFILE "MIN_ID_${clk},[lindex $clk_line 3]"
         puts $CFILE "MAX_ID_${clk},[lindex $clk_line 4]"
         puts $CFILE "AVG_ID_${clk},[lindex $clk_line 5]"
         puts $CFILE "Global_SKEW_${clk},[lindex $clk_line 10]"
         puts $CFILE "Target_SKEW_${clk},[regsub {\*} [lindex $clk_line 9] {}]"
         puts $CFILE "Skew_window_occupancy_${clk},[lindex $clk_line 11]"
         lappend min_id [lindex $clk_line 3]
         lappend max_id [lindex $clk_line 4]
         lappend avg_id [lindex $clk_line 5]
         lappend global_skew [lindex $clk_line 10]
         lappend target_skew [regsub {\*} [lindex $clk_line 9] {}]
         lappend skew_window_occupancy [lindex $clk_line 11]
       }
       if {[llength [exec cat ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt | egrep "none " | egrep -v __cdc | egrep $clk]] == 12} {
         set clk_line [exec cat ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt | egrep "none " | egrep -v __cdc | egrep $clk] 
         puts $OFILE  "MIN_ID_${clk},[lindex $clk_line 2], ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE  "MAX_ID_${clk},[lindex $clk_line 3], ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE  "AVG_ID_${clk},[lindex $clk_line 4], ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE  "Global_SKEW_${clk},[lindex $clk_line 9], ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE  "Target_SKEW_${clk},[lindex $clk_line 8] , ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $OFILE  "Skew_window_occupancy_${clk},[lindex $clk_line 10] \{[regsub "," [lindex $clk_line 11] ""]\}, ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
         puts $CFILE  "MIN_ID_${clk},[lindex $clk_line 2]"
         puts $CFILE  "MAX_ID_${clk},[lindex $clk_line 3]"
         puts $CFILE  "AVG_ID_${clk},[lindex $clk_line 4]"
         puts $CFILE  "Global_SKEW_${clk},[lindex $clk_line 9]"
         puts $CFILE  "Target_SKEW_${clk},[regsub {\*} [lindex $clk_line 8] {}]"
         puts $CFILE  "Skew_window_occupancy_${clk},[lindex $clk_line 10] "
         lappend min_id [lindex $clk_line 2]
         lappend max_id [lindex $clk_line 3]
         lappend avg_id [lindex $clk_line 4]
         lappend global_skew [lindex $clk_line 9]
         lappend target_skew [regsub {\*} [lindex $clk_line 8] {}]
         lappend skew_window_occupancy [lindex $clk_line 10]
       }
    };# end foreach  
   } else {
       puts  $OFILE "skew_group ,NA check, ${WA}/${pnr}/reports/cts/cts_skew_groups.rpt"
      foreach clk $clock_list {
        puts $CFILE "LEVEL_${clk},NA"
        puts $CFILE "MIN_ID_${clk},NA"
        puts $CFILE "MAX_ID_${clk},NA"
        puts $CFILE "AVG_ID_${clk},NA"
        puts $CFILE "Global_SKEW_${clk},NA"
        puts $CFILE "Target_SKEW_${clk},NA"
        puts $CFILE "Skew_window_occupancy_${clk},NA"
      }
       
   }
    ## Table, for Analyze clock:
   set CAFILE [open $WA/$pnr/grafana/${design_name}_cts_clock_analyzed.csv w] 
   puts $CAFILE "Date,Time,Work_Area,Block_Name,PROJECT,STAGE,CLOCK,USEFUL_SKEW,LEVEL,MIN_ID,MAX_ID,AVG_ID,TARGET_SKEW,GLOBAL_SKEW,SKEW_WINDOW_OCCUPANCY"

   set i 0
   set first_print 1
   foreach clk $clock_list {
   set fd [open date.rpt w]
   puts $fd "[exec date]"
   close $fd
   set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         puts -nonewline $CAFILE "[lindex $line 1] [lindex $line 2] [lindex $line end],"
         puts -nonewline $CAFILE "[lindex $line 3] AM,"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         puts -nonewline $CAFILE "[lindex $line 1] [lindex $line 2] [lindex $line end],"
         puts -nonewline $CAFILE "[lindex $line 3] PM,"
      } else {
         puts -nonewline $CAFILE "[lindex $line 1] [lindex $line 2] [lindex $line end],"
         puts -nonewline $CAFILE "[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM,"
      }
	 } 
   exec rm date.rpt
    puts -nonewline $CAFILE "${WA}/${pnr},$block_name,$proj,cts,"
    puts -nonewline $CAFILE "$clk,$USEFUL_SKEW,[lindex $level_list $i],[lindex $min_id $i],[lindex $max_id $i],[lindex $avg_id $i],[lindex $target_skew $i],[lindex $global_skew $i],[lindex $skew_window_occupancy $i]"

     puts $CAFILE ""
     incr i
   }

   close $CAFILE
 #============================================================

 #============================================================
 # report_cts_cell_name_info
 #============================================================
   if {[file exist ${WA}/${pnr}/reports/${stage}/report_cts_cell_name_info.rpt] } {
      set fi [open ${WA}/${pnr}/reports/${stage}/report_cts_cell_name_info.rpt r]
      puts  $OFILE "report_cts_cell_name_info,\""
      while {[gets $fi line]>=0} {
         puts  $OFILE "$line"
      }
      puts $OFILE "\",${WA}/${pnr}/reports/${stage}/report_cts_cell_name_info.rpt"
   } else {
     puts $OFILE "report_cts_cell_name_info,NA check,${WA}/${pnr}/reports/${stage}/report_cts_cell_name_info.rpt "
   }

   if {[file exist ${WA}/${pnr}/reports/${stage}/report_cts_cell_name_info_transposed.rpt] } {
      set fi [open ${WA}/${pnr}/reports/${stage}/report_cts_cell_name_info_transposed.rpt r]
      while {[gets $fi line]>=0} {
         puts  $CFILE "$line"
      }
   } else {
   if {[file exist ${WA}/${pnr}/tmp_cts_cell_name_info]} {
      set fi [open tmp_cts_cell_name_info r]
      while {[gets $fi line]>=0} {
         if {(![regexp {Creators:} $line]) && ($line!="")} {
            puts $CFILE "CTS_${prefix},NA"
         }
       }
    }
   }
   if {[file exist ${WA}/${pnr}/tmp_cts_cell_name_info]} {
      # no need for this one.
       exec rm tmp_cts_cell_name_info
   }
 #============================================================
     report_from_be_qor $stage $WA $pnr
     if {[file exist reports/${stage}/report_from_be_qor.csv]} {
       set fi_re [open reports/${stage}/report_from_be_qor.csv r]
        while {[gets $fi_re line]>=0} {
           puts $OFILE "$line"
        }
        # generate timing table, per stage
        report_path_groups $WA $pnr $stage $block_name
        exec rm reports/${stage}/report_from_be_qor.csv
     } else {
       puts $OFILE "report from qor, NA check, reports/${stage}/report_from_be_qor.csv "
     }

    if {[file exist reports/${stage}/report_from_be_qor_for_transpose.csv]} {
       set fi_rt [open reports/${stage}/report_from_be_qor_for_transpose.csv r]
        while {[gets $fi_rt line]>=0} {
          if {[regexp {HotSpot} $line]} { 
           puts $CFILE "HotSpot_Score,[lindex [split $line ","] 1]"
           puts $CFILE "HotSpot_Score_input,[lindex [split $line ","] 2]"
          }
          if {[regexp {Setup Timing} $line]} {
            foreach tm [regsub -all {\"} [split [lindex [split $line ","] 1] ":"] ""] {
               if {$tm!=""} {
                set i 0
                foreach case "wns tns vp" {
                   puts $CFILE "[lindex $tm 0]_${case},[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i]"
                   incr i
                }
              }
            }
          };# setup time
          if {[regexp {Hold Timing} $line]} {
                puts $CFILE "[lindex [split $line ","] 1 0]_hold_wns,[lindex [split [lindex [split $line ","] 1 1] "/"] 0]"
                puts $CFILE "[lindex [split $line ","] 1 0]_hold_tns,[lindex [split [lindex [split $line ","] 1 1] "/"] 1]"
                puts $CFILE "[lindex [split $line ","] 1 0]_hold_vp,[lindex [split [lindex [split $line ","] 1 1] "/"] 2]"
          };# hold time

        }
       exec rm reports/${stage}/report_from_be_qor_for_transpose.csv
     } else {
        puts $CFILE "HotSpot_Score,NA"
        puts $CFILE "HotSpot_Score_input,reports/${stage}/report_from_be_qor_for_transpose.csv"
        foreach group "reg2reg reg2cgate reg2out in2reg in2out" {
           foreach case "wns tns vp" {
              puts $CFILE "${group}_$case,NA"

           }
        }

     }
    #================================================
    #  shielding
     find_latest_log $stage
     if {[check_grep latest_cts.log "cts"] } {
         set log_file [exec cat latest_cts.log | egrep "cts"]
         if {[check_grep ${WA}/${pnr}/log/$log_file "Number of nets with shield attribute:" 6]} {
              puts $OFILE "shielding,\"Number of nets with shield attribute [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Number of nets with shield attribute:"] 6]"
              puts $OFILE "Number of nets reported [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Number of nets reported:"] 4]" 
              puts $OFILE "Number of nets without shielding [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Number of nets without shielding:"] 5]" 
              puts $OFILE "Average ratio [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Average ratio"] 3]" 
              puts $OFILE "\",  ${WA}/${pnr}/log/$log_file"
              puts $CFILE "Shield_Average_ratio,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Average ratio"] 3]" 

         } else {
            puts $OFILE "Shielding,NA check,${WA}/${pnr}/log/$log_file"
            puts $CFILE "Shield_Average_ratio,NA"
         }
         exec rm latest_cts.log
     } else {
      puts $OFILE "Shielding,NA check,${WA}/${pnr}/log/[exec tail -n 1 latest_cts.log]"
      puts $CFILE "Shield_Average_ratio,NA"
     }   
    #================================================
    #  NDR
     if {[check_grep ${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_cts.rpt "Clock tree nets NDR" 4] } {
         puts $OFILE "NDR routing rules name,\" [lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_cts.rpt | egrep "Clock tree nets NDR"] 4]"
         puts $OFILE "[lindex [exec cat reports/${stage}/report_clock_nets_ndr_cts.rpt | egrep "Clock tree nets NDR"] 5]\",${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_cts.rpt "
         puts $OFILE "NDR routing rules violations,[lindex [exec cat reports/${stage}/report_clock_nets_ndr_cts.rpt | egrep "Clock tree nets NDR violations"] 5],${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_cts.rpt"
         puts $CFILE "NDR_routing_rules_violations,[lindex [exec cat reports/${stage}/report_clock_nets_ndr_cts.rpt | egrep "Clock tree nets NDR violations"] 5]"
     } else {
      puts $OFILE "NDR routing rules name,NA check,${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_cts.rpt"
      puts $CFILE "NDR_routing_rules_violations,NA"
     }   
   
    #================================================
    #  check constraints :  pulse_width
    #                       min period
    # need to run before :
    #  report_constraint -check_type {pulse_width clock_period}  -all_violators -drv_violation_type max_transition                        
     if {[check_grep ${WA}/${pnr}/reports/${stage}/report_constraints_cts.rpt "Check type"] } {
        exec cat ${WA}/${pnr}/reports/${stage}/report_constraints_cts.rpt | egrep "Check type|_setup" > tmp_report_constraints.rpt
        set fi_co [open tmp_report_constraints.rpt r]
        set now_count 0
        set counter_clock_period 0
        set counter_pulse_width 0
        while {[gets $fi_co line]>=0} {
       #   puts "now_count = $now_count" 
         if {[regexp {clock_period} [lindex $line 3]] || ($now_count==1)} {
            set now_count 1
             if {[regexp {_setup} $line]} {
               incr counter_clock_period
            }
         }
         if {[regexp {pulse_width} [lindex $line 3]] || ($now_count==2)} {
            set now_count 2
             if {[regexp {_setup} $line]} {
               incr counter_pulse_width
            }
         }

        }
         puts $OFILE "clock_period violations,$counter_clock_period,${WA}/${pnr}/reports/${stage}/report_constraints_cts.rpt"
         puts $OFILE "pulse_width violations,$counter_pulse_width,${WA}/${pnr}/reports/${stage}/report_constraints_cts.rpt"
         puts $CFILE "clock_period_violations,$counter_clock_period"
         puts $CFILE "pulse_width_violations,$counter_pulse_width"
         exec rm tmp_report_constraints.rpt
        
     } else {
      puts $OFILE "clock_period violations,NA check,${WA}/${pnr}/reports/${stage}/report_constraints_cts.rpt"
      puts $OFILE "pulse_width violations,NA check,${WA}/${pnr}/reports/${stage}/report_constraints_cts.rpt"
      puts $CFILE "clock_period_violations,NA"
      puts $CFILE "pulse_width_violations,NA"
     }   
 

     #================================================
    # reports clock pins that dont start in clock
     if {[check_grep $WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_cts.rpt "clock_pins_not_connect_to_clock" 1]} {
          puts $OFILE "check pin clock violation (if not connected to clock),[lindex [exec cat $WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_cts.rpt | egrep "clock_pins_not_connect_to_clock"] 1],$WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_cts.rpt"
          puts $CFILE "clock_pin_connection_violation,[lindex [exec cat $WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_cts.rpt | egrep "clock_pins_not_connect_to_clock"] 1]"
     } else {
        puts $OFILE "check pin clock violation (if not connected to clock),NA check,$WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_cts.rpt "
        puts $CFILE "clock_pin_connection_violation,NA"
     }  
     #================================================
    # reports clock pins transitions
     if {[check_grep $WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt "clock tree pins with a slew violation" 4]} {
          puts $OFILE "clock transition violations,[lindex [exec cat $WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt | egrep "clock tree pins with a slew violation"] 4],$WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt"
          puts $CFILE "clock_transition_violations,[lindex [exec cat $WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt | egrep "clock tree pins with a slew violation"] 4]"
     } else {
        puts $OFILE "clock transition violations,NA check,$WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt "
        puts $CFILE "clock_transition_violations,NA"
     } 
    #================================================
    # check data transition:
    get_data_transition $stage $design_name $WA $pnr
    if {[file exist reports/${stage}/report_from_trans.csv]} {
       set fi [open reports/${stage}/report_from_trans.csv r]
        while {[gets $fi line]>=0} {
           puts $OFILE "$line"
           puts $CFILE "data_transition_violations,[lindex [split $line ","] 1]"
        } 
       close $fi
       exec rm reports/${stage}/report_from_trans.csv
    } else {
       puts $OFILE "data transition violations,NA check,reports/${stage}/report_from_trans.csv"
       puts $CFILE "data_transition_violations,NA"
    }
     #================================================
     
     # log scan
        analyzed_log_scan $stage
        puts $OFILE "[exec cat log_scan_results]"
        puts $CFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $CFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed

    #================================================
   close $CFILE 
  };# cts 
     #===============================================================================
     #                                 ROUTE
     #===============================================================================

   if {([file exist .route_done]) && (([lindex $argv 0] == "route") || ([lindex $argv 0] == "all"))} {
     set RFILE [open $WA/$pnr/${design_name}_for_transposed_data_5.csv w] 
     set stage "route"
     puts $OFILE "STAGE,        ROUTE"
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
     set proj [find_proj $WA $pnr $stage]
     exec rm date.rpt
     puts $RFILE "Work_Area,${WA}/${pnr}"
     puts $RFILE "Block_Name,$block_name"
     puts $RFILE "PROJECT,$proj"
     puts $RFILE "STAGE,route"
    #================================================
    # host name:
     host_name $WA $pnr $stage
    if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $RFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
    } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $RFILE "Host_name,NA"
    }
     innovus_version $WA $pnr $stage
    if {[check_grep  innovus_version.rpt "Innovus version" ]} {
         puts $OFILE "[ exec cat innovus_version.rpt | head -n 1]"
         puts $RFILE "Innovus_version,[lindex [ split [exec cat innovus_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "Innovus version,NA check,innovus_version.rpt"
         puts $RFILE "Innovus_version,NA"
    }
     report_from_be_qor $stage $WA $pnr
     if {[file exist reports/${stage}/report_from_be_qor.csv]} {
       set fi_re [open reports/${stage}/report_from_be_qor.csv r]
        while {[gets $fi_re line]>=0} {
           puts $OFILE "$line"
        }
        # generate timing table, per stage
        report_path_groups $WA $pnr $stage $block_name
        exec rm reports/${stage}/report_from_be_qor.csv
     } else {
       puts $OFILE "report from qor, NA check, reports/${stage}/report_from_be_qor.csv "
     }

    if {[file exist reports/${stage}/report_from_be_qor_for_transpose.csv]} {
       set fi_rt [open reports/${stage}/report_from_be_qor_for_transpose.csv r]
        while {[gets $fi_rt line]>=0} {
          if {[regexp {HotSpot} $line]} { 
           puts $RFILE "HotSpot_Score,[lindex [split $line ","] 1]"
           puts $RFILE "HotSpot_Score_input,[lindex [split $line ","] 2]"
          }
          if {[regexp {Setup Timing} $line]} {
            foreach tm [regsub -all {\"} [split [lindex [split $line ","] 1] ":"] ""] {
               if {$tm!=""} {
                set i 0
                foreach case "wns tns vp" {
                   puts $RFILE "[lindex $tm 0]_${case},[lindex [split [regsub [lindex $tm 0] $tm ""] "/"] $i]"
                   incr i
                }
              }
            }
          };# setup time
          if {[regexp {Hold Timing} $line]} {
                puts $RFILE "[lindex [split $line ","] 1 0]_hold_wns,[lindex [split [lindex [split $line ","] 1 1] "/"] 0]"
                puts $RFILE "[lindex [split $line ","] 1 0]_hold_tns,[lindex [split [lindex [split $line ","] 1 1] "/"] 1]"
                puts $RFILE "[lindex [split $line ","] 1 0]_hold_vp,[lindex [split [lindex [split $line ","] 1 1] "/"] 2]"
          };# hold time

        }
       exec rm reports/${stage}/report_from_be_qor_for_transpose.csv
     } else {
        puts $RFILE "HotSpot_Score,NA"
        puts $RFILE "HotSpot_Score_input,reports/${stage}/report_from_be_qor_for_transpose.csv"
        foreach group "reg2reg reg2cgate reg2out in2reg in2out" {
           foreach case "wns tns vp" {
              puts $RFILE "${group}_$case,NA"

           }
        }
    }
    #================================================
    #  check constraints :  pulse_width
    #                       min period
    # need to run before :
    #  report_constraint -check_type {pulse_width clock_period}  -all_violators -drv_violation_type max_transition                        
     if {[check_grep ${WA}/${pnr}/reports/${stage}/report_constraints_route.rpt "Check type"] } {
        exec cat ${WA}/${pnr}/reports/${stage}/report_constraints_route.rpt | egrep "Check type|_setup" > tmp_report_constraints.rpt
        set fi_co [open tmp_report_constraints.rpt r]
        set now_count 0
        set counter_clock_period 0
        set counter_pulse_width 0
        while {[gets $fi_co line]>=0} {
       #   puts "now_count = $now_count" 
         if {[regexp {clock_period} [lindex $line 3]] || ($now_count==1)} {
            set now_count 1
             if {[regexp {_setup} $line]} {
               incr counter_clock_period
            }
         }
         if {[regexp {pulse_width} [lindex $line 3]] || ($now_count==2)} {
            set now_count 2
             if {[regexp {_setup} $line]} {
               incr counter_pulse_width
            }
         }

        }
         puts $OFILE "clock_period violations,$counter_clock_period,${WA}/${pnr}/reports/${stage}/report_constraints_route.rpt"
         puts $OFILE "pulse_width violations,$counter_pulse_width,${WA}/${pnr}/reports/${stage}/report_constraints_route.rpt"
         puts $RFILE "clock_period_violations,$counter_clock_period"
         puts $RFILE "pulse_width_violations,$counter_pulse_width"
         exec rm tmp_report_constraints.rpt
        
     } else {
      puts $OFILE "clock_period violations,NA check,${WA}/${pnr}/reports/${stage}/report_constraints_route.rpt]"
      puts $OFILE "pulse_width violations,NA check,${WA}/${pnr}/reports/${stage}/report_constraints_route.rpt]"
      puts $RFILE "clock_period_violations,NA"
      puts $RFILE "pulse_width_violations,NA"
     }   
 
      #================================================
    #  shielding
     find_latest_log $stage
     if {[check_grep latest_route.log "route"] } {
         set log_file [exec cat latest_route.log | egrep "route"]
         if {[check_grep ${WA}/${pnr}/log/$log_file "Number of nets with shield attribute:" 6]} {
              puts $OFILE "shielding,\"Number of nets with shield attribute [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Number of nets with shield attribute:"] 6]"
              puts $OFILE "Number of nets reported [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Number of nets reported:"] 4]" 
              puts $OFILE "Number of nets without shielding [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Number of nets without shielding:"] 5]" 
              puts $OFILE "Average ratio [lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Average ratio"] 3]" 
              puts $OFILE "\",  ${WA}/${pnr}/log/$log_file"
              puts $RFILE "Shield_Average_ratio,[lindex [exec cat ${WA}/${pnr}/log/$log_file | egrep "Average ratio"] 3]" 
         } else {
            puts $OFILE "Shielding,NA check,${WA}/${pnr}/log/$log_file"
            puts $RFILE "Shield_Average_ratio,NA" 
         }
         exec rm latest_route.log
     } else {
      puts $OFILE "Shielding,NA check,${WA}/${pnr}/log/[exec tail -n 1 latest_route.log]"
      puts $RFILE "Shield_Average_ratio,NA" 
     }   
    #================================================
    #  NDR
     if {[check_grep ${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_route.rpt "Clock tree nets NDR" 4] } {
         puts $OFILE "NDR routing rules name,\" [lindex [exec cat ${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_route.rpt | egrep "Clock tree nets NDR"] 4]"
         puts $OFILE "[lindex [exec cat reports/${stage}/report_clock_nets_ndr_route.rpt | egrep "Clock tree nets NDR"] 5]\",${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_route.rpt "
         puts $OFILE "NDR routing rules violations,[lindex [exec cat reports/${stage}/report_clock_nets_ndr_route.rpt | egrep "Clock tree nets NDR violations"] 5],${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_route.rpt"
         puts $RFILE "NDR_routing_rules_violations,[lindex [exec cat reports/${stage}/report_clock_nets_ndr_route.rpt | egrep "Clock tree nets NDR violations"] 5]"
     } else {
      puts $OFILE "NDR routing rules name,NA check,${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_route.rpt]"
      puts $OFILE "NDR routing rules violations,NA check,${WA}/${pnr}/reports/${stage}/report_clock_nets_ndr_route.rpt]"
      puts $RFILE "NDR_routing_rules_violations,NA"
     }   
   
    #================================================
    # reports clock pins that dont start in clock
     if {[check_grep $WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_route.rpt "clock_pins_not_connect_to_clock" 1]} {
          puts $OFILE "check pin clock violation (if not connected to clock),[lindex [exec cat $WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_route.rpt | egrep "clock_pins_not_connect_to_clock"] 1],$WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_route.rpt"
          puts $RFILE "clock_pin_connection_violation,[lindex [exec cat $WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_route.rpt | egrep "clock_pins_not_connect_to_clock"] 1]"
     } else {
        puts $OFILE "check pin clock violation (if not connected to clock),NA check,$WA/$pnr/reports/${stage}/reports_clock_to_each_clk_pin_route.rpt "
        puts $RFILE "clock_pin_connection_violation,NA"
     }  

    #================================================
    # reports Nets length Violations
     if {[check_grep $WA/$pnr/reports/${stage}/report_nets_length_route.rpt "Long Nets" 2]} {
           puts $OFILE "long nets violations,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_nets_length_route.rpt  | egrep "Long Nets"] 2],$WA/$pnr/reports/${stage}/report_nets_length_route.rpt "
           puts $RFILE "long_nets_violations,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_nets_length_route.rpt  | egrep "Long Nets"] 2]"
     } else {
        puts $OFILE "long nets violations,NA check,$WA/$pnr/reports/${stage}/report_nets_length_route.rpt "
        puts $RFILE "long_nets_violations,NA"
     }  
    #================================================
    # route quality Violations
     if {[check_grep $WA/$pnr/reports/${stage}/report_route_quality_ratio.rpt "Worst route quality" 6]} {
         if {[check_grep $WA/$pnr/reports/${stage}/report_route_quality_ratio.rpt "ERRORS" 8]} {
           puts $OFILE "Worst route quality ratio,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_route_quality_ratio.rpt  | egrep "Worst route quality"] 6] include ERRORS,$WA/$pnr/reports/${stage}/report_route_quality_ratio.rpt "
           puts $RFILE "Worst_route_quality_ratio,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_route_quality_ratio.rpt  | egrep "Worst route quality"] 6] include ERRORS"
         } else {
           puts $OFILE "Worst route quality ratio,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_route_quality_ratio.rpt  | egrep "Worst route quality"] 6],$WA/$pnr/reports/${stage}/report_route_quality_ratio.rpt "
           puts $RFILE "Worst_route_quality_ratio,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_route_quality_ratio.rpt  | egrep "Worst route quality"] 6]"
         }
     } else {
        puts $OFILE "Worst route quality ratio,NA check,$WA/$pnr/reports/${stage}/report_route_quality_ratio.rpt "
        puts $RFILE "Worst_route_quality_ratio,NA"
     }  
    #================================================
    # reports clock pins transitions
     if {[check_grep $WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt "clock tree pins with a slew violation" 4]} {
          puts $OFILE "clock transition violations,[lindex [exec cat $WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt | egrep "clock tree pins with a slew violation"] 4],$WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt"
          puts $RFILE "clock_transition_violations,[lindex [exec cat $WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt | egrep "clock tree pins with a slew violation"] 4]"
     } else {
        puts $OFILE "clock transition violations,NA check,$WA/$pnr/reports/${stage}/${stage}_report_clock_trees.rpt "
        puts $RFILE "clock_transition_violations,NA"
     } 
     #================================================
    # check data transition:
    get_data_transition $stage $design_name $WA $pnr
    if {[file exist reports/${stage}/report_from_trans.csv]} {
       set fi [open reports/${stage}/report_from_trans.csv r]
        while {[gets $fi line]>=0} {
           puts $OFILE "$line"
           puts $RFILE "data_transition_violations,[lindex [split $line ","] 1]"
        } 
       close $fi
       exec rm reports/${stage}/report_from_trans.csv
    } else {
       puts $OFILE "data transition violations,NA check,reports/${stage}/report_from_trans.csv"
       puts $RFILE "data_transition_violations,NA"
    }
    #================================================
    
     #================================================
     
     
    # DCAP around clock cells ViolationsDCAPs violations
     if {[check_grep $WA/$pnr/reports/${stage}/report_missing_dcaps.rpt "DCAPs violations" 3]} {
           puts $OFILE "Number of DCAPs violations,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_missing_dcaps.rpt  | egrep "DCAPs violations"] 3],$WA/$pnr/reports/${stage}/report_missing_dcaps.rpt "
           puts $RFILE "Number_of_DCAPs_violations,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_missing_dcaps.rpt  | egrep "DCAPs violations"] 3]"
     } else {
        puts $OFILE "Number of DCAPs violations,NA check,$WA/$pnr/reports/${stage}/report_missing_dcaps.rpt "
        puts $RFILE "Number_of_DCAPs_violations,NA"
     }  
    #================================================
    #================================================
    # reports dont use cell check
     if {[check_grep $WA/$pnr/reports/${stage}/report_dont_use_cells.rpt "Found " 3]} {
           puts $OFILE "don't use cells violations,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_dont_use_cells.rpt  | egrep "Found "] 3],$WA/$pnr/reports/${stage}/report_dont_use_cells.rpt "
           puts $RFILE "don't_use_cells_violations,[lindex [exec cat  $WA/$pnr/reports/${stage}/report_dont_use_cells.rpt  | egrep "Found "] 3]"
     } else {
        puts $OFILE "don't use cells violations,NA check,$WA/$pnr/reports/${stage}/report_dont_use_cells.rpt "
        puts $RFILE "don't_use_cells_violations,NA"
     }  
    #================================================
    #================================================
    # DFM swap %
     if {[check_grep ${WA}/${pnr}/reports/route/route_track_opt.multicut.final.rpt "%"]} {
          exec cat ${WA}/${pnr}/reports/route/route_track_opt.multicut.final.rpt | egrep "%" > tmp_dfm.rpt
          set fi_dfm [open tmp_dfm.rpt r]
          puts $OFILE "Total DFM VIA swap(%) per Metal(Via),\""
          while {[gets $fi_dfm line]>=0} {
             if {![regexp {Total} $line]} {
                  puts $OFILE "[lindex [split $line "|"] 1]   [lindex [split $line "|"] 4]" 
             }
          };# while...
          puts $OFILE "\",${WA}/${pnr}/reports/route/route_track_opt.multicut.final.rpt"
          # for grafana:
          set max_metal_layer 17
          for {set i 0} {$i <= $max_metal_layer} {incr i} {
             set fi_gr [open ${WA}/${pnr}/reports/route/route_track_opt.multicut.final.rpt r]
             while {[gets $fi_gr line]>=0} {
                if {[llength [regexp -inline "M${i}" $line]]} {
                   if {[catch [lindex [split [lindex [ split $line "|"] 4] "(|%"] 1]] } {
                     puts $RFILE "DFM_M${i}_%,[lindex [split [lindex [ split $line "|"] 4] "(|%"] 1]" 
                     break
                  } else {
                     puts $RFILE "DFM_M${i}_%,0.0" 
                     break
                  }
                }
             }
                 close $fi_gr
         };# for metal
          exec rm tmp_dfm.rpt
     }  else {
        puts "Total DFM VIA swap(%) per Metal(Via), NA check, ${WA}/${pnr}/reports/reports/route/route_track_opt.multicut.final.rpt"
        set max_metal_layer 17
        for {set i 0} {$i <= $max_metal_layer} {incr i} {
            puts $RFILE "DFM_M${i}_%,NA"
        }  

     }

    #================================================
    # DRC check:
    summary_check_drc  $stage
    if {[file exist  ${WA}/${pnr}/short_drc.rpt]} {
     if {[check_grep ${WA}/${pnr}/short_drc.rpt "No DRC violations"]} { 
           puts $OFILE "DRC check,[exec cat ${WA}/${pnr}/short_drc.rpt | egrep "No DRC violations"],${WA}/${pnr}/reports/route/route_check_drc.rpt" 
         puts $RFILE "Total_shorts,0"
         puts $RFILE "Total_drc,0"
     } else {
        set fi [open ${WA}/${pnr}/short_drc.rpt r]
         set total_drc 0
         set total_shorts 0
         puts $OFILE "DRC check,\""
         while {[gets $fi line]>=0} {
            puts $OFILE "$line"
            if {[regexp {SHORT} $line]} {
               set total_shorts [expr $total_shorts + [lindex $line end]]
            }
            if {[regexp {TOTAL DRC} $line]} {
               set total_drc  [lindex $line end]
            }
         }   
         puts $OFILE "\",[exec pwd]/reports/route/route_check_drc.rpt"
         exec rm ${WA}/${pnr}/short_drc.rpt
         puts $RFILE "Total_shorts,$total_shorts"
         puts $RFILE "Total_drc,$total_drc"
      }
    } else {
      puts $OFILE "DRC check, NA check,${WA}/${pnr}/short_drc.rpt"
      puts $RFILE "Total_shorts,NA"
      puts $RFILE "Total_drc,NA"
    }

    #================================================
        analyzed_log_scan $stage
        puts $OFILE "[exec cat log_scan_results]"
        puts $RFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $RFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed
    #================================================
   close $RFILE 
   };# route 
    #===============================================================================
    #===============================================================================
    #                                 CHIP_FINISH
    #===============================================================================
   if {([file exist .chip_finish_done]) && (([lindex $argv 0] == "chip_finish") || ([lindex $argv 0] == "all"))} {
     set CHFFILE [open $WA/$pnr/${design_name}_for_transposed_data_6.csv w] 
     set stage "chip_finish"
     puts $OFILE "STAGE,        CHIP_FINISH"
     set fd [open date.rpt w]
     puts $fd "[exec date]"
     close $fd
     set fi [open date.rpt r]
     while {[gets $fi line]>=0} {
       if {[lindex [split [lindex $line 3] ":"] 0] < 12} {   
         puts $CHFFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $CHFFILE "Time,[lindex $line 3] AM"
      } elseif {[lindex [split [lindex $line 3] ":"] 0]==12} {
         puts $CHFFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $CHFFILE "Time,[lindex $line 3] PM"
      } else {
         puts $CHFFILE "Date,[lindex $line 1] [lindex $line 2] [lindex $line end]"
         puts $CHFFILE "Time,[expr [lindex [split [lindex $line 3] ":"] 0] -12]:[lindex [split [lindex $line 3] ":"] 1]:[lindex [split [lindex $line 3] ":"] 2] PM"
      }
	 } 
     set proj [find_proj $WA $pnr $stage]
     exec rm date.rpt
     puts $CHFFILE "Work_Area,${WA}/${pnr}"
     puts $CHFFILE "Block_Name,$block_name"
     puts $CHFFILE "PROJECT,$proj"
     puts $CHFFILE "STAGE,chip_finish"

    # host name:
     host_name $WA $pnr $stage
    if {[check_grep  host.rpt "Host name" ]} {
         puts $OFILE "[ exec cat host.rpt]"
         puts $CHFFILE "Host_name,[lindex [split [exec cat host.rpt] ","] 1]"
    } else {
         puts $OFILE "Host name,NA check,host.rpt"
         puts $CHFFILE "Host_name,NA"
    }
     innovus_version $WA $pnr $stage
    if {[check_grep  innovus_version.rpt "Innovus version" ]} {
         puts $OFILE "[ exec cat innovus_version.rpt | head -n 1]"
         puts $CHFFILE "Innovus_version,[lindex [ split [exec cat innovus_version.rpt | head -n 1] "," ] 1]"
    } else {
         puts $OFILE "Innovus version,NA check,innovus_version.rpt"
         puts $CHFFILE "Innovus_version,NA"
    }
    #================================================
    # check place: 
    if {[file exist $WA/$pnr/reports/chip_finish/check_place_summary.rpt]} {
        if {[check_grep  $WA/$pnr/reports/chip_finish/check_place_summary.rpt "Violation" ]} {
           exec cat  $WA/$pnr/reports/chip_finish/check_place_summary.rpt | egrep "Violation" > vio.rpt
           set fiv [open vio.rpt r]
           set total_vio 0
           puts $OFILE "check_place_violations,\""
           while {[gets $fiv line]>=0} {
              puts  $OFILE "$line"
              set total_vio [expr $total_vio + [lindex [split $line ":"] 1]]
           }
         puts   $OFILE "\",\"$WA/$pnr/reports/chip_finish/check_place_summary.rpt"  
         puts   $OFILE ",$WA/$pnr/reports/chip_finish/check_place_detail.rpt\""  
         puts   $CHFFILE "check_place_violations,$total_vio"
         exec rm vio.rpt 

        } else {
           puts $OFILE "check_place_violations,0,\"$WA/$pnr/reports/chip_finish/check_place_summary.rpt"
           puts $OFILE ",$WA/$pnr/reports/chip_finish/check_place_detail.rpt\""
           puts $CHFFILE "check_place_violations,0"
        }
    } else {
       puts $OFILE "check_place_violations,NA check,$WA/$pnr/reports/chip_finish/check_place_summary.rpt"
       puts $CHFFILE "check_place_violations,NA"
    }



    #================================================
    # DRC check, 
    summary_check_drc  $stage
    if {[file exist  ${WA}/${pnr}/short_drc.rpt]} {
     if {[check_grep ${WA}/${pnr}/short_drc.rpt "No DRC violations"]} { 
           puts $OFILE "DRC check,[exec cat ${WA}/${pnr}/short_drc.rpt | egrep "No DRC violations"],${WA}/${pnr}/reports/route/route_check_drc.rpt" 
         puts $CHFFILE "Total_shorts,0"
         puts $CHFFILE "Total_drc,0"
     } else {
        set fi [open ${WA}/${pnr}/short_drc.rpt r]
        set total_drc 0
        set total_shorts 0
         puts $OFILE "DRC check,\""
         while {[gets $fi line]>=0} {
            puts $OFILE "$line"
            if {[regexp {SHORT} $line]} {
               set total_shorts [expr $total_shorts + [lindex $line 3]]
            }
            if {[regexp {TOTAL DRC} $line]} {
               set total_drc  [lindex $line 3]
            }
         }   
         puts $OFILE "\",[exec pwd]/reports/chip_finish/route_check_drc.rpt"
         exec rm ${WA}/${pnr}/short_drc.rpt
         puts $CHFFILE "Total_shorts,$total_shorts"
         puts $CHFFILE "Total_drc,$total_drc"

      }
    } else {
      puts $OFILE "DRC check, NA check,${WA}/${pnr}/short_drc.rpt"
      puts $CHFFILE "Total_shorts,NA"
      puts $CHFFILE "Total_drc,NA"
    }

    #================================================
    # DCAP cells
      if {[check_grep  $WA/$pnr/reports/chip_finish/report_dcap_cells.rpt "Total_number_from_dcap_cells_list" ]} {
         set fi [open $WA/$pnr/reports/chip_finish/report_dcap_cells.rpt r] 
         puts $OFILE "Dcap_cells,\"" 
         while {[gets $fi line]>=0} {
           if {[regexp {DCAP_CELLS_LIST} $line]} {
              puts $OFILE "[lindex $line 1]    [lindex $line 2]  "
           }
           if {[regexp {Total_number_from_dcap_cells_list} $line]} {
              puts $OFILE "Total_decap_cells    [lindex $line 1]  "
              puts $CHFFILE "Total_decap_cells,[lindex $line 1]  "
           }
         }
         puts $OFILE "\",$WA/$pnr/reports/chip_finish/report_dcap_cells.rpt"
         close $fi

         set fi [open $WA/$pnr/reports/chip_finish/report_dcap_cells.rpt r] 
         puts $OFILE "Eco_Dcap_cells,\"" 
         while {[gets $fi line]>=0} {
           if {[regexp {ECO_DCAP_LIST} $line]} {
              puts $OFILE "[lindex $line 1]    [lindex $line 2]  "
           }
           if {[regexp {Total_number_from_eco_dcap_list} $line]} {
              puts $OFILE "Total_ECO_decap_cells    [lindex $line 1]  "
              puts $CHFFILE "Total_ECO_decap_cells,[lindex $line 1]  "
           }
         }
         puts $OFILE "\",$WA/$pnr/reports/chip_finish/report_dcap_cells.rpt"
         close $fi

      } else {
         puts $OFILE "Total_decap_cells,NA"
         puts $OFILE "Total_ECO_decap_cells,NA"
         puts $CHFFILE "Total_decap_cells,NA"
         puts $CHFFILE "Total_ECO_decap_cells,NA"

      }
    #================================================
    # Add column : 'Total_cap' for grafana
      puts $OFILE "Total_cap,NA need to add"
      puts $CHFFILE "Total_cap,NA"

    #================================================
        analyzed_log_scan $stage
        puts $OFILE "[exec cat log_scan_results]"
        puts $CHFFILE "log_Error_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 0] {}] end]"
        puts $CHFFILE "log_Warning_Messages,[lindex [regsub {\"} [lindex [split [lindex [split [exec cat log_scan_results_for_transposed] ","] 1] ":"] 1] {}] end]"
        exec rm log_scan_results
        exec rm log_scan_results_for_transposed
    #================================================

  close $CHFFILE 
  };# chip_finish
  #===============================================================================
 close $OFILE
  #===============================================================================
     set file_name "$WA/$pnr/${design_name}_be_checklist_summary.csv"
     exec echo "be checklist reports : ${design_name} , stage : $stage " > tmp
     exec cat tmp | mail -r be_checklist_summary@nextsilicon.com -a $file_name -s "be checklist summary report for ${design_name}, stage : $stage " ido.naishtein@nextsilicon.com,[be_get_user_email $::env(USER)]
     exec rm tmp
     #===============================================================================
     # for statistics:
  if {([lindex $argv 0] == "general_floorplan") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_1.csv]} {
        set stage "general"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_1.csv $stage
        exec rm ${design_name}_for_transposed_data_1.csv
     } 
     if {[file exist ${design_name}_for_transposed_data_2.csv]} {
        set stage "floorplan"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_2.csv $stage
        exec rm ${design_name}_for_transposed_data_2.csv
     } 
  };# mail for general,floorplan

 if {([lindex $argv 0] == "place") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_3.csv]} {
        set stage "place"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_3.csv $stage
        exec rm ${design_name}_for_transposed_data_3.csv
     } 
 };# mail for place    

 if {([lindex $argv 0] == "cts") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_4.csv]} {
        set stage "cts"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_4.csv $stage
        exec rm ${design_name}_for_transposed_data_4.csv
     } 
 };# mail for cts    
 if {([lindex $argv 0] == "route") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_5.csv]} {
        set stage "route"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_5.csv $stage
        exec rm ${design_name}_for_transposed_data_5.csv
     } 
 };# mail for route    
 if {([lindex $argv 0] == "chip_finish") || ([lindex $argv 0] == "all")} {
     if {[file exist ${design_name}_for_transposed_data_6.csv]} {
        set stage "chip_finish"
        send_the_transposed_file $design_name ${design_name}_for_transposed_data_6.csv $stage
        exec rm ${design_name}_for_transposed_data_6.csv
     } 
 };# mail for route    
 #===============================================================================

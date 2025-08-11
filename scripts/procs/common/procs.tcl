#################################################################################################################################################################################
#	alias and procedure for cadence tools 																	#
#																						#
#		alias:																				#
#			win	- start gui																	#
#			xx	- get_common_ui_map																#
#			fo	- all_fanout -endpoints_only   -from														#
#			fi	- all_fanin  -startpoints_only -to														#
#			gs	- get selected object name															#
#			gsn	- get_selected object net															#
#			gsc	- get_selected object cell															#
#			gsp	- get_selected object pin															#
#			gsa	- get_selcted 																	#
#			gcl	- get_cell_location																#
#			eco_gcl	- eco_get_cell_location																#
#																						#
#		procedures:																			#
#			get_cell_location	- print to screen placement command for selecte3d object									#
#			csc			- change select object to cel													#
#			csn			- change select object to net													#
#			csp			- change select object to pin													#
#			vl			- print list elements one per row												#
#			v			- print collection elements one per row												#
#			check_script_location	- check if script location is under scripts_local. if true print to screen and wait for  a few second and return script name	#
#			be_print_big_warning	- print $txt as warning and wait $slp seconds											#
#			addiobuffer_proc	- add io buffer to interface													#
#			script_runtime_proc	- print to screen runtime of the main script.											#
#			user_wait_license	- check if license in the list availeable. if not wait till available								#
#			memory_placement_checker- check if memories are located on memory grid.											#
#			report_macro_count	- print count of macros.													#
#			replace_lib_with_db	- get lib file. return db file or empty if file does not exists									#
#																						#
#																						#
#################################################################################################################################################################################
if {![info exists env(LEC_VERSION)]} {

   alias win gui_show
   alias xx   get_common_ui_map
   alias fo   "all_fanout -endpoints_only   -from "
   alias fi   "all_fanin  -startpoints_only -to "
   if {[info command distribute_partition] == ""} {
  	alias gs  "get_db selected"
  	alias gsn "get_nets -of \[gs\]"
  	alias gsc "get_cells -of \[gs\]"
  	alias gsp "get_pins -of \[gs\]"
  	alias gsa "get_db selected"
   }
   alias gcl "get_cell_location"
   alias eco_gcl "eco_get_cell_location"
   if {[info exists ::synopsys_program_name]} {
	alias cs change_selection
	alias gs "get_selection"
	alias gsn "get_nets -of \[gs\]"
	alias gsc "get_cells -of \[gs\]"
	alias gsp "get_pins -of \[gs\]"
	alias gsa "get_attribute \[gs\] "
   }
}

################################
#   BE_PARSE_ARGS
################################
proc be_parse_args { help_info {arg_data ""} {args_in ""} } {

  set PROC [lindex [info level 0] 0]

  # // HELP SECTION //
  if { ($help_info eq "-help")||($help_info eq "-h") } {

    puts "
    $PROC is a generic TCL proc arg parser.

    Usage:     $PROC '<general proc description>' '<arg array>' '<input arg list>'
    
    expected format of arg array:
        {{opt_name   required   type  default   \"info string\"}}
    example:
      # // PARSE ARGS
        set proc_info \"this proc does amazing things\"
        set my_args { 
          { input   1 list    \"\"       \"amazing input list - required\" } 
          { file    0 string  my_f.tcl \"amazing output file\" }
          { verbose 0 boolean false    \"enables amazing verbose\" }
        }
      # setting argument values with respect to given proc args (here as '\$args'):
      # for this example only, setting args in here
        set args \"-verbose -input {ta-da magic}\"  
        if { \[$PROC \$proc_info \$my_args \$args\] } { return }
      # test  
        foreach arg_ \[lsearch -all -inline -subindices -index 0 \$my_args \"*\"\] { 
            puts \[format \"%-20s \t %s\" \$arg_ \[set \$arg_\]\] 
        }
    "
    return 1
  }

  # // PARSING //
  # header for help output 
    set my_table     "{OptName Required Type DefaultValue Comments}" 
    lappend my_table  "------- -------- ---- ------------ --------"   
    array set _opt ""
    array set _w ""
    set i 0 ; foreach _val [join $my_table] { 
        set _w($i) [expr [string length $_val] + 2]
        incr i
    }
  # checking for illegal inputs 
    if { ($args_in != "-help")&&($args_in != "-h") } {
        set input_arg_list [regsub -all {\-} [lsearch -regexp -inline -all "$args_in" {^\-| \-}] ""]
        foreach _arg $input_arg_list {
            if { [lsearch [lsearch -all -inline -subindices -index 0 $arg_data "*"] "$_arg"] < 0 } {
                puts "-E- $_arg is not a valid option - displaying help section\n"
                set args_in "-help"
            }    
        }
    }
  # let the parsing begin  
    foreach _arg_entry $arg_data {
        lassign $_arg_entry arg req type def cmnts
        set my_table_entry "$arg $req $type {$def} {$cmnts}"
          # get table widths    
        set i 0 ; foreach _val $my_table_entry {
            set _val_w [expr [string length $_val] + 2]
            set _w($i) [expr max($_w($i),$_val_w)]
            incr i
        }
        lappend my_table $my_table_entry
      # set arg value from user input, or from default values
        set idx [lsearch $args_in "-$arg"]
        if { $idx >= 0 } {
            if { [regexp boolean $type] } {
                set _opt($arg) 1
            } else {
                set _opt($arg) [lindex $args_in [expr $idx+1]]
            }
        } else {
            set _opt($arg) $def
        }
    }

  # // DISPLAY HELP MENU
    if { [regexp "\-help" $args_in] } {
        puts "$help_info\n"
        foreach line $my_table {
            lassign $line arg req type def cmnts
            puts [format "%-${_w(0)}s %-${_w(1)}s %-${_w(2)}s %-${_w(3)}s %-${_w(4)}s" $arg $req $type $def $cmnts]
        }
        puts ""
        return 1
    } else {
        foreach var [array names _opt] {
            upvar $var ${var}_local
            set ${var}_local $_opt($var)
        }        
        return 0 
    }
}


################################################################################################################
## check_script_location.
################################################################################################################
proc memory_placement_checker {{X_GRID 3.876} {Y_GRID 3.360} {SHIFT 0.0255}} {
	foreach memory [get_db insts -if {.base_cell.is_memory}] {
		set memory_name [get_db $memory .name]
                set ORI [get_db $memory .orient]
                if {$ORI == "r0" } {
                    set MEMORY_X [expr [get_db $memory  .bbox.ll.x] - $SHIFT]
                        set MEMORY_Y [get_db $memory  .bbox.ll.y]
                } elseif  {$ORI == "mx" } {
                        set MEMORY_X [expr [get_db $memory  .bbox.ll.x] - $SHIFT]
                        set MEMORY_Y [get_db $memory  .bbox.ur.y]
                } elseif  {$ORI == "my" } {
                        set MEMORY_X [expr [get_db $memory  .bbox.ur.x] + $SHIFT]
                        set MEMORY_Y [get_db $memory  .bbox.ll.y]
                } elseif  {$ORI == "r180" } {
                        set MEMORY_X [expr [get_db $memory  .bbox.ur.x] + $SHIFT]
                        set MEMORY_Y [get_db $memory  .bbox.ur.y]
               }

		set memory_name [get_db $memory .name]
		set ORI [get_db $memory .orient]
		if {$ORI == "r0" } {
			set MEMORY_X [get_db $memory  .bbox.ll.x]
			set MEMORY_Y [get_db $memory  .bbox.ll.y]
		} elseif  {$ORI == "mx" } {
			set MEMORY_X [get_db $memory  .bbox.ll.x]
			set MEMORY_Y [get_db $memory  .bbox.ur.y]
		} elseif  {$ORI == "my" } {
			set MEMORY_X [get_db $memory  .bbox.ur.x]
			set MEMORY_Y [get_db $memory  .bbox.ll.y]
		} elseif  {$ORI == "r180" } {
			set MEMORY_X [get_db $memory  .bbox.ur.x]
			set MEMORY_Y [get_db $memory  .bbox.ur.y]
		}
		if {[expr int($MEMORY_X / $X_GRID *1000)/1000.0 - int($MEMORY_X / $X_GRID)] > 0 && [expr int($MEMORY_Y / $Y_GRID *1000)/1000.0 - int($MEMORY_Y / $Y_GRID)] > 0} {
#			puts "ERROR: memory $memory_name is not placed on X and Y grid. X = $MEMORY_X , Y =  $MEMORY_Y . "
			puts "ERROR: memory $memory_name is not placed on X and Y grid. X = [get_db $memory .location.x] , Y = [get_db $memory .location.y]  . "
			puts "     legal location for memory is:"
			set DELTA_MINUS [expr $MEMORY_X-int($MEMORY_X / $X_GRID)*$X_GRID]
			set X_LOCATION [expr [get_db $memory .location.x]-$DELTA_MINUS]
			set DELTA_MINUS [expr $MEMORY_Y-int($MEMORY_Y / $Y_GRID)*$Y_GRID]
			set Y_LOCATION [expr [get_db $memory .location.y]-$DELTA_MINUS]
			puts "       place_inst $memory_name {$X_LOCATION $Y_LOCATION} $ORI"
			set DELTA_PLUS  [expr (int($MEMORY_Y / $Y_GRID)+1)*$Y_GRID - $MEMORY_Y]
			set Y_LOCATION [expr [get_db $memory .location.y]+$DELTA_PLUS]
			puts "       place_inst $memory_name {$X_LOCATION $Y_LOCATION} $ORI"
			
			
			set DELTA_PLUS  [expr (int($MEMORY_X / $X_GRID)+1)*$X_GRID - $MEMORY_X]
			set X_LOCATION [expr [get_db $memory .location.x]+$DELTA_PLUS]
			set DELTA_MINUS [expr $MEMORY_Y-int($MEMORY_Y / $Y_GRID)*$Y_GRID]
			set Y_LOCATION [expr [get_db $memory .location.y]-$DELTA_MINUS]
			puts "       place_inst $memory_name {$X_LOCATION $Y_LOCATION} $ORI"
			
			
			set DELTA_PLUS  [expr (int($MEMORY_X / $X_GRID)+1)*$X_GRID - $MEMORY_X]
			set X_LOCATION [expr [get_db $memory .location.x]+$DELTA_PLUS]
			set DELTA_PLUS  [expr (int($MEMORY_Y / $Y_GRID)+1)*$Y_GRID - $MEMORY_Y]
			set Y_LOCATION [expr [get_db $memory .location.y]+$DELTA_PLUS]
			puts "       place_inst $memory_name {$X_LOCATION $Y_LOCATION} $ORI"
			
			
			
		} elseif {[expr int($MEMORY_X / $X_GRID *1000)/1000.0 - int($MEMORY_X / $X_GRID)] > 0} {
#			puts "ERROR: memory $memory_name is not placed on X grid. X = $MEMORY_X ."
			puts "ERROR: memory $memory_name is not placed on X grid. X = [get_db $memory .location.x] ."
			puts "     legal location for memory is:"
			set DELTA_MINUS [expr $MEMORY_X-int($MEMORY_X / $X_GRID)*$X_GRID]
			set DELTA_PLUS  [expr (int($MEMORY_X / $X_GRID)+1)*$X_GRID - $MEMORY_X]
			set Y_LOCATION [get_db $memory .location.y]
			set X_LOCATION [expr [get_db $memory .location.x]-$DELTA_MINUS]
			puts "       place_inst $memory_name {$X_LOCATION $Y_LOCATION} $ORI"
			set X_LOCATION [expr [get_db $memory .location.x]+$DELTA_PLUS]
			puts "       place_inst $memory_name {$X_LOCATION $Y_LOCATION} $ORI"
		} elseif {[expr int($MEMORY_Y / $Y_GRID *1000)/1000.0 - int($MEMORY_Y / $Y_GRID)] > 0} {
#			puts "ERROR: memory $memory_name is not placed on Y grid. Y = $MEMORY_Y ."
			puts "ERROR: memory $memory_name is not placed on Y grid. Y =  [get_db $memory .location.y]."
			puts "     legal location for memory is:"
			set DELTA_MINUS [expr $MEMORY_Y-int($MEMORY_Y / $Y_GRID)*$Y_GRID]
			set DELTA_PLUS  [expr (int($MEMORY_Y / $Y_GRID)+1)*$Y_GRID - $MEMORY_Y]
			set X_LOCATION [get_db $memory .location.x]
			set Y_LOCATION [expr [get_db $memory .location.y]-$DELTA_MINUS]
			puts "       place_inst $memory_name {$X_LOCATION $Y_LOCATION} $ORI"
			set Y_LOCATION [expr [get_db $memory .location.y]+$DELTA_PLUS]
			puts "       place_inst $memory_name {$X_LOCATION $Y_LOCATION} $ORI"
			
			
		}
		
	}
}

################################################################################################################
## replace_lib_with_db.
################################################################################################################

proc replace_lib_with_db {file} {

	#regsub {prod(\S+BSI)} $file {int\1} file            
    
    	if       { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        	return $new_file
    	} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        	return $new_file
    	} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        	return $new_file
    	} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        	return $new_file
    	} else {
		regsub {/prod/} $file {/int/} file            
    		if       { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        		return $new_file
    		} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        		return $new_file
    		} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        		return $new_file
    		} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        		return $new_file
    		} else {
        		puts "-E- File $file have no .db version in folder"
			return ""
		}
    	}
}


################################################################################################################
## check_script_location.
################################################################################################################

proc proc_lec_pass {{PASS true}} {
	puts "\n"
	puts "[string repeat " " 33] [string repeat 0 10 ]"
	puts "[string repeat " " 29] [string repeat 0 18 ]"
	puts "[string repeat " " 25] [string repeat 0 26 ]"
	puts "[string repeat " " 21] [string repeat 0 34 ]"
	puts "[string repeat " " 18] [string repeat 0 40 ]"
	puts "[string repeat " " 16] [string repeat 0 44 ]"
	puts "[string repeat " " 14] [string repeat 0 48 ]"
	puts "[string repeat " " 12] [string repeat 0 52 ]"
	puts "[string repeat " " 10] [string repeat 0 56 ]"
	puts "[string repeat " " 9] [string repeat 0 58 ]"
	puts "[string repeat " " 8] [string repeat 0 60 ]"
	puts "[string repeat " " 7] [string repeat 0 15 ]  [string repeat 0 28 ]  [string repeat 0 15 ]"
	puts "[string repeat " " 7] [string repeat 0 14 ]    [string repeat 0 26 ]    [string repeat 0 14 ]"
	puts "[string repeat " " 6] [string repeat 0 14 ]      [string repeat 0 24 ]      [string repeat 0 14 ]"
	puts "[string repeat " " 6] [string repeat 0 14 ]      [string repeat 0 24 ]      [string repeat 0 14 ]"
	puts "[string repeat " " 5] [string repeat 0 15 ]      [string repeat 0 24 ]      [string repeat 0 15 ]"
	puts "[string repeat " " 5] [string repeat 0 15 ]      [string repeat 0 24 ]      [string repeat 0 15 ]"
	puts "[string repeat " " 5] [string repeat 0 16 ]     [string repeat 0 24 ]     [string repeat 0 16 ]"
	puts "[string repeat " " 5] [string repeat 0 66 ]"
	puts "[string repeat " " 5] [string repeat 0 66 ]"
	puts "[string repeat " " 5] [string repeat 0 66 ]"
	puts "[string repeat " " 5] [string repeat 0 66 ]"
	puts "[string repeat " " 5] [string repeat 0 66 ]"
	puts "[string repeat " " 6] [string repeat 0 64 ]"
	if {$PASS} {
	   puts "[string repeat " " 6] [string repeat 0 14 ]  [string repeat " " 32 ]  [string repeat 0 14 ]"
	   puts "[string repeat " " 7] [string repeat 0 14 ]  [string repeat " " 30 ]  [string repeat 0 14 ]"
	   puts "[string repeat " " 7] [string repeat 0 15 ]  [string repeat " " 28 ]  [string repeat 0 15 ]"
	   puts "[string repeat " " 8] [string repeat 0 15 ]  [string repeat " " 26 ]  [string repeat 0 15 ]"
	   puts "[string repeat " " 9] [string repeat 0 16 ]  [string repeat " " 22 ]  [string repeat 0 16 ]"
	   puts "[string repeat " " 10] [string repeat 0 16 ]  [string repeat " " 20 ]  [string repeat 0 16 ]"
	   puts "[string repeat " " 12] [string repeat 0 16 ]  [string repeat " " 16 ]  [string repeat 0 16 ]"
	   puts "[string repeat " " 14] [string repeat 0 18 ]  [string repeat " " 8 ]  [string repeat 0 18 ]"
	
	} else {
	   puts "[string repeat " " 6] [string repeat 0 26 ]  [string repeat " " 8 ]  [string repeat 0 26 ]"
	   puts "[string repeat " " 7] [string repeat 0 21 ]  [string repeat " " 16 ]  [string repeat 0 21 ]"
	   puts "[string repeat " " 7] [string repeat 0 19 ]  [string repeat " " 20 ]  [string repeat 0 19 ]"
	   puts "[string repeat " " 8] [string repeat 0 17 ]  [string repeat " " 22 ]  [string repeat 0 17 ]"
	   puts "[string repeat " " 9] [string repeat 0 14 ]  [string repeat " " 26 ]  [string repeat 0 14 ]"
	   puts "[string repeat " " 10] [string repeat 0 12 ]  [string repeat " " 28 ]  [string repeat 0 12 ]"
	   puts "[string repeat " " 12] [string repeat 0 9 ]  [string repeat " " 30 ]  [string repeat 0 9 ]"
	   puts "[string repeat " " 14] [string repeat 0 6 ]  [string repeat " " 32 ]  [string repeat 0 6 ]"
	
	}
	puts "[string repeat " " 16] [string repeat 0 44 ]"
	puts "[string repeat " " 18] [string repeat 0 40 ]"
	puts "[string repeat " " 21] [string repeat 0 34 ]"
	puts "[string repeat " " 25] [string repeat 0 26 ]"
	puts "[string repeat " " 29] [string repeat 0 18 ]"
	puts "[string repeat " " 33] [string repeat 0 10 ]"


   
}

################################################################################################################
## report_macro_count.
################################################################################################################

proc be_report_macro_count { {all 1} } {
	global DESIGN_NAME
	if {[info exists ::synopsys_program_name] } {
            if { $all } {
                set my_macro_cells [get_cells -quiet -hier -filter design_type==macro]
            } else {
                set my_macro_cells [filter_collection [get_cells -quiet -hier -filter design_type==macro] within_block_abstraction==false]        
            }
		foreach_in_collection macro_ $my_macro_cells {
			set ref_name [get_attribute $macro_ ref_name]
			incr macro_count($ref_name)
		}
	} else {
        proc all_macro_cells {} {     
            if { [get_db program_short_name] == "innovus" } {
                set is_macro_txt "is_macro_cell"
            } elseif { [get_db program_short_name] == "genus" } {
                set is_macro_txt "is_macro"
            }    
            return [get_cells -quiet -hier -filter "is_hierarchical == false && $is_macro_txt == true"]
        }  
		foreach_in_collection macro_ [all_macro_cells] {
			set ref_name [get_db $macro_ .base_cell.name]
			incr macro_count($ref_name)
		}
    }  
	
	puts "\n"
	puts [string repeat * 50]
	puts "Report : macro count"
	puts "Design : $DESIGN_NAME"
	if {[info exists ::synopsys_program_name] } {
		puts "Version: [get_app_var sh_product_version]"
	}
	puts "Date   : [date]"
	puts [string repeat * 50]
	puts "\n"
	puts [format "%s %70s" "Type" "Count" ]
	puts [string repeat - 80]

	foreach macro_ [lsort [array names macro_count]] { puts [format "%-70s %s" $macro_ $macro_count($macro_)]}
	puts "\n"

}

################################################################################################################
## check_script_location.
################################################################################################################

proc check_script_location {{FORCE false}} {
   global RUNNING_LOCAL_SCRIPTS
   if {$FORCE == "false"} {
   	set SCRIPT__  [info script]
   } else {
   	set SCRIPT__  $FORCE
   }
   if {![info exists pt_shell_mode] || $pt_shell_mode  != "primetime_master"} {
       set width 130       
   } else {
       #set width [lindex [exec stty size] 1]
       set width 130       
   }

   if {$width > 130} { 
   	set XSPACE $width
   } else {
   	set XSPACE 130
   }
   if {[regexp scripts_local $SCRIPT__] } {
   	puts [string repeat # [expr $XSPACE - 10 ]]
   	puts [string repeat # [expr $XSPACE - 10 ]]
	puts [format "%s %*s" "#####" [expr $XSPACE - 16 ] "#####"]
	puts [format "%s %*s" "####" [expr $XSPACE - 15 ] "####"]
	puts [format "%s %*s" "###" [expr $XSPACE - 14 ] "###"]
	puts [format "%s %*s" "###" [expr $XSPACE - 14 ] "###"]
	puts [format "%s %*s" "###     !!!!!!!!!!!" [expr $XSPACE - 30 ] "!!!!!!!!!!!     ###"]
	puts [format "%s %*s" "###      !!     !!" [expr $XSPACE - 29 ] "!!     !!      ###"]
	puts [format "%s %*s" "###       !!   !!" [expr $XSPACE - 28 ] "!!   !!       ###"]
	puts [format "###        !! !!       \033\[1;31mrunning %-*s\033\[0m  !! !!        ###"  [expr $XSPACE - 59 ] "$SCRIPT__ script from script_local location"]
	puts [format "%s %*s" "###         !!!" [expr $XSPACE - 26 ] "!!!         ###"]
	puts [format "%s %*s" "###          !" [expr $XSPACE - 25 ] "!          ###"]
	puts [format "%s %*s" "###          !" [expr $XSPACE - 25 ] "!          ###"]
	puts [format "%s %*s" "###" [expr $XSPACE - 14 ] "###"]
	puts [format "%s %*s" "###" [expr $XSPACE - 14 ] "###"]
	puts [format "%s %*s" "####" [expr $XSPACE - 15 ] "####"]
	puts [format "%s %*s" "#####" [expr $XSPACE - 16 ] "#####"]
   	puts [string repeat # [expr $XSPACE - 10 ]]
   	puts [string repeat # [expr $XSPACE - 10 ]]
   	if {![info exists pt_shell_mode] || $pt_shell_mode  == "primetime_master"} {
		exec sleep 5
	}
	lappend RUNNING_LOCAL_SCRIPTS $SCRIPT__
   }
   
}

################################################################################################################
## Print warning and wait $slp seconds
################################################################################################################

proc be_print_big_warning { txt {slp 10}} {

   if {![info exists pt_shell_mode] || $pt_shell_mode  != "primetime_master"} {
       set width 130       
   } else {
       #set width [lindex [exec stty size] 1]
       set width 130       
   }

   if {$width > 130} { 
   	set XSPACE $width
   } else {
   	set XSPACE 130
   }

   	puts [string repeat # [expr $XSPACE - 10 ]]
   	puts [string repeat # [expr $XSPACE - 10 ]]
	puts [format "%s %*s" "#####" [expr $XSPACE - 16 ] "#####"]
	puts [format "%s %*s" "####" [expr $XSPACE - 15 ] "####"]
	puts [format "%s %*s" "###" [expr $XSPACE - 14 ] "###"]
	puts [format "%s %*s" "###" [expr $XSPACE - 14 ] "###"]
	puts [format "%s %*s" "###     !!!!!!!!!!!" [expr $XSPACE - 30 ] "!!!!!!!!!!!     ###"]
	puts [format "%s %*s" "###      !!     !!" [expr $XSPACE - 29 ] "!!     !!      ###"]
	puts [format "%s %*s" "###       !!   !!" [expr $XSPACE - 28 ] "!!   !!       ###"]
	puts [format "###        !! !!       \033\[1;31m%-*s\033\[0m  !! !!        ###"  [expr $XSPACE - 51 ] "$txt"]
	puts [format "%s %*s" "###         !!!" [expr $XSPACE - 26 ] "!!!         ###"]
	puts [format "%s %*s" "###          !" [expr $XSPACE - 25 ] "!          ###"]
	puts [format "%s %*s" "###          !" [expr $XSPACE - 25 ] "!          ###"]
	puts [format "%s %*s" "###" [expr $XSPACE - 14 ] "###"]
	puts [format "%s %*s" "###" [expr $XSPACE - 14 ] "###"]
	puts [format "%s %*s" "####" [expr $XSPACE - 15 ] "####"]
	puts [format "%s %*s" "#####" [expr $XSPACE - 16 ] "#####"]
   	puts [string repeat # [expr $XSPACE - 10 ]]
   	puts [string repeat # [expr $XSPACE - 10 ]]
   	if {![info exists pt_shell_mode] || $pt_shell_mode  == "primetime_master"} {
		exec sleep $slp
	}

   
}

################################################################################################################
## select instance.
################################################################################################################
proc csc {obj} {
	if {![info exists ::synopsys_program_name] && ![ info exists env(LEC_VERSION) ]} {
		deselect_obj [get_db selected]    
		select_obj [get_cells $obj]
	} elseif {[info exists ::synopsys_program_name]} {
		change_selection [get_cells -hier $obj] -replace
	}

}
################################################################################################################
## print to screen start time, end time and total time of command
################################################################################################################
proc calc_run_time {start end} {
   set diff [expr $end - $start]
   set days [expr $diff/86400]
   set diff [expr $diff%86400]
   set hours [expr $diff/3600]
   set diff [expr $diff%3600]
   set min [expr $diff/60]
   return ${days}D:${hours}H:${min}M
}


proc eee {eee_cmd {fileName {}} {cmd_desc {}}} {
	set start_t [clock seconds]
	puts "-I- Start running $eee_cmd at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
	eval $eee_cmd
	set end_t [clock seconds]
	puts "-I- End running $eee_cmd at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
	puts "-I- Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
	if {$fileName != ""} {
		set OFILE [open $fileName a]
		set run_time [calc_run_time $start_t $end_t]
		if {$cmd_desc != ""} {
			puts $OFILE "Run time of     $cmd_desc: $run_time"
		} else {
			puts $OFILE "Run time of     $eee_cmd: $run_time"
		}
		close $OFILE
	}
}
proc eee_stage { stage eee_cmd {fileName {}} {cmd_desc {}}} {
	set start_t [clock seconds]
	puts "-I- BE_STAGE: $stage - Start running $stage at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
    	if { [file exists ./user_inputs.tcl] } { source -e -v ./user_inputs.tcl }
    	if { [info exists ::STAGE] } { set STAGE $::STAGE }
    	puts "-I- Running: $eee_cmd"
	eval $eee_cmd
	set end_t [clock seconds]
	puts "-I- BE_STAGE: $stage - End running $stage at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
	puts "-I- BE_STAGE: $stage - Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
	if {$fileName != ""} {
		set OFILE [open $fileName a]
		set run_time [calc_run_time $start_t $end_t]
		if {$cmd_desc != ""} {
			puts $OFILE "Run time of     $cmd_desc: $run_time"
		} else {
			puts $OFILE "Run time of     $eee_cmd: $run_time"
		}
		close $OFILE
	}
}
################################################################################################################
## select net.
################################################################################################################
proc csn {obj} {
	if {![info exists ::synopsys_program_name] && ![ info exists env(LEC_VERSION) ]} {
		deselect_obj [get_db selected]    
		select_obj [get_nets $obj]
	} elseif {[info exists ::synopsys_program_name]} {
		change_selection [get_nets $obj] -replace
	}
}
################################################################################################################
## select pin.
################################################################################################################
proc csp {obj} {
	if {![info exists ::synopsys_program_name] && ![ info exists env(LEC_VERSION) ]} {
		deselect_obj [get_db selected]    
		select_obj [get_pins $obj]
	} elseif {[info exists ::synopsys_program_name]} {
		change_selection [get_pins $obj] -replace
	}
}
################################################################################################################
## print to screen place inst command on the selected cell location.
################################################################################################################
proc get_cell_location {{mark_as ""}} {
	if {![info exists ::synopsys_program_name] } {
		if {$mark_as == "" || $mark_as == "-fixed" || $mark_as == "-placed" || $mark_as == "-soft_fixed"} {
		   foreach inst_ [get_db selected -if ".obj_type==inst"] {
			set inst_name [get_db [get_cells $inst_] .name]
			set inst_location [get_db [get_cells $inst_] .location]
			set inst_orientation [get_db [get_cells $inst_] .orient]
			puts "place_inst $inst_name $inst_location $inst_orientation $mark_as"
		   }
		} else {
			puts "Error: wrong mark_as: $mark_as argument.\n can be empty or -fixed or -placed or -soft_fixed"
		}
	} else {
		foreach_in_collection inst_ [filter_collection [get_selection] "object_class == cell"] {
			set inst_name [get_object_name [get_cells $inst_]]
			set inst_location [lindex [get_attribute [get_cells $inst_] boundary_bbox] 0 ]
			set inst_orientation [get_attribute [get_cells $inst_] orientation]
			puts "set_cell_location  $inst_name -coordinates \"$inst_location\" -orientation $inst_orientation $mark_as"
		}
	}
}

################################################################################################################
## print to screen eco cell location  command on the selected cell location.
################################################################################################################
proc eco_get_cell_location {{mark_as ""}} {
   if {$mark_as == "" || $mark_as == "-fixed" || $mark_as == "-placed" || $mark_as == "-soft_fixed"} {
      foreach inst_ [get_db selected -if ".obj_type==inst"] {
         set inst_name [get_db [get_cells $inst_] .name]
         set inst_location [get_db [get_cells $inst_] .location]
         set inst_orientation [get_db [get_cells $inst_] .orient]
         set inst_base_cell [get_db [get_cells $inst_] .base_cell.name]
         puts "eco_update_cell  -insts $inst_name -location $inst_location -orient $inst_orientation -cells $inst_base_cell"
      }
   } else {
      puts "Error: wrong mark_as: $mark_as argument.\n can be empty or -fixed or -placed or -soft_fixed"
   }
}

################################################################################################################
## print to screen a list one line per raw.
################################################################################################################
proc vl {args} {
	foreach lll [eval $args] {
		puts $lll
	}
}

################################################################################################################
## print to screen a colection one line per raw.
################################################################################################################
proc v {args} {
	foreach_in_collection lll [eval $args] {
		puts [get_object_name $lll]
	}
}

################################################################################################################
##   addiobuffer_proc	- add io buffer to interface								
################################################################################################################
proc addiobuffer_proc {args} {
	parse_proc_arguments -args $args options
	if {[info exists options(-buffer) ]}    {set BUFFER $options(-buffer)}
	if {[info exists options(-useable_buffer) ]}    {set USEABLE_BUFFER $options(-useable_buffer)}
	if {[info exists options(-antenna) ]}   {set ANTENNA $options(-antenna)}
	if {[info exists options(-padding) ]}   {set PADDING $options(-padding)} else {set PADDING "0 0 0 0"}
	if {[info exists options(-direction) ]} {set DIRECTION $options(-direction)} else {set DIRECTION "both"}
	
	if {![info exists BUFFER] && ![info exists ANTENNA]} {
		puts "***ERROR need to give BUFFER or ANTENNA cell"
		return
	}	
	if {[llength $PADDING] > 1 } {
		set left_side    [lindex $PADDING 0]
		set top_side     [lindex $PADDING 1]
		set right_side   [lindex $PADDING 2]
		set bottom_side  [lindex $PADDING 3]
	} else {
		set left_side    $PADDING
		set top_side     $PADDING
		set right_side   $PADDING
		set bottom_side  $PADDING
	}
	set_cell_padding -cell $BUFFER  -bottom_side $bottom_side -top_side $top_side -right_side $right_side -left_side $left_side
    
	if {[info exists ANTENNA]} {set_cell_padding -cell [lindex $ANTENNA 0] -bottom_side $bottom_side -top_side $top_side -right_side $right_side -left_side $left_side}

    
	# Manage clock ports
	set _clock_nets [lsort -unique [get_db [get_db clocks .sources -if { .obj_type == port } ] .net.name ]]
#	set _clkNetFile [open clock_nets.txt w]
#	  foreach _net $_clock_nets {puts $_clkNetFile $_net}
#	close $_clkNetFile
   	if {[info exists BUFFER]} {
		set fid [open excNetFileName.txt w]
		set excNetFileName_flag 0
   		set _cmd " add_io_buffers -suffix _IOBuf -port -exclude_clock_nets -status softfixed"
   		if {$DIRECTION == "both" || $DIRECTION == "both_ant" || $DIRECTION == "in" || $DIRECTION == "in_ant" } { 
			set _cmd "$_cmd -in_cells $BUFFER" 
			foreach ppp [get_db ports -if ".direction == in"] {
				if {[get_db $ppp .net.num_loads] == 0} { 
					puts $fid [get_db $ppp .net.name]
					set excNetFileName_flag 1
				}
			}
		}
   		if {$DIRECTION == "both" || $DIRECTION == "both_ant" || $DIRECTION == "out" } { 
			set _cmd "$_cmd -out_cells $BUFFER" 
			foreach ppp [get_db ports -if ".direction == out"] {
				if {[get_db $ppp .net.num_drivers] == 0} { 
					puts $fid [get_db $ppp .net.name]
					set excNetFileName_flag 1
				}
			}
		}
		close $fid
		if {$excNetFileName_flag} {set _cmd "$_cmd -exclude_nets_file excNetFileName.txt"}
		puts "-I- $_cmd"
   		eval $_cmd   


  		 ###	size only 
   		if {[info exists USEABLE_BUFFER]} {
		 	puts "-I- setting size only with useable_buffer $USEABLE_BUFFER"
			set _list_cells {}
   			foreach _cell $USEABLE_BUFFER {
	  			set _list_cells [concat $_list_cells [lsort -unique [get_db lib_cells .base_name $_cell]]]	
			}
   		}   
		puts "-I- setting size_only on [llength [get_db insts *_IOBuf]] IOBuf"
		define_attribute user_size_only_cell -obj_type inst -data_type bool -category user -default false -help_string "if attribute is true cell will be size only" 
   		foreach _inst [get_db insts *_IOBuf] {
      			set_db $_inst .dont_touch size_ok
      			if {[info exists _list_cells] && $_list_cells != "" } {
          			set_db $_inst .use_cells $_list_cells
				set_db $_inst .user_size_only_cell true
      			}
   		}
   		#dont touch on net
		puts "-I- setting dont touch on IO nets"
  		set top_nets [get_db ports .net.escaped_name]
   		foreach _inst [get_db insts *_IOBuf*] {
			if {[llength [get_db [get_db $_inst .pins -if ".direction==in"] .net.drivers -if ".obj_type==port"]] > 0 && ($DIRECTION=="in" || $DIRECTION=="in_ant" || $DIRECTION=="both" || $DIRECTION=="both_ant" )} {
				set _net  [get_db [get_db $_inst .pins -if ".direction==in"] .net]
				set_db $_net .dont_touch true
			}
			if {[llength [get_db [get_db $_inst .pins -if ".direction==out"] .net.loads -if ".obj_type==port"]] > 0 && ($DIRECTION=="out" || $DIRECTION=="both" || $DIRECTION=="both_ant" )} {
				set _net  [get_db [get_db $_inst .pins -if ".direction==out"] .net]
				set_db $_net .dont_touch true
			}
   		}
		delete_cell_padding $BUFFER
   	}
	if {[info exists ANTENNA] && ($DIRECTION == "both_ant" || $DIRECTION == "in_ant" )} {
	# Add input diodes
		foreach _port [get_db ports -if { .direction == in } ] {
	    		if { [lsearch -exact $_clock_nets [get_db $_port .net.name ]] >= 0 } { continue }    ; # skip clocks
	    		if { [get_db $_port .net.num_loads ] == 0 } { continue }
	    		set _pin [list [get_db $_port .net.loads.inst.name ] [get_db $_port .net.loads.base_name ]]
			create_diode -diode_cell [lindex $ANTENNA 0] -pin $_pin -prefix DONT_TOUCH_IODio
		}
		delete_cell_padding [lindex $ANTENNA 0]
   	}
   	if {[info exists BUFFER] || [info exists ANTENNA]} {
		# Refine place
		set _insts [concat [concat [get_db insts *_IOBuf] [get_db insts *DONT_TOUCH_IODio* ]]]
		set_db $_insts .place_status soft_fixed
		place_detail -inst [get_db $_insts .name]
		set_db $_insts .place_status fixed
   	}
}

if {![info exists ::synopsys_program_name] && ![ info exists env(LEC_VERSION) ]} {
  define_proc_arguments addiobuffer_proc \
  -info "add buffer to io" \
  -define_args {
    {-buffer "add buffer to IO" "" string {optional}}
    {-useable_buffer "list of buffers to upsize" "" string {optional}}
    {-antenna "add antenna to input" "" string {optional}}
    {-direction "place buffer on input , output or both" "" string {optional}}
    {-padding "add padding to created cells.  can give 1 number for all sides, or left top right bottom " "" string {optional}}
     }
}
################################################################################################################
##   script_runtime_proc	- calculate and print runtime or script								
################################################################################################################
proc script_runtime_proc {args} {
	global SCRIPT_RUNTIME_START_VARIABLE
	global env
	parse_proc_arguments -args $args options
	if {[info exists options(-start) ]}    {set _START "true"} else {set _START "false"}
	if {[info exists options(-end) ]}    {set _END "true"} else {set _END "false"}

   if {$_START == "false" && $_END == "false"} {
	puts "-E- missing start or end option"
	return
   }

   if {$_START} {
	set SCRIPT_RUNTIME_START_VARIABLE [clock seconds]
	puts "-I- Start running on host: $env(HOST) , at: [clock format $SCRIPT_RUNTIME_START_VARIABLE -format "%d/%m/%y %H:%M:%S"]"
	if {[regexp "nextk8s|argo" $env(HOST)]} {
		set cmd " sh nextk8s -pod list -regex $env(HOST) | grep \"k8s-worker\" | perl -pe 's/.*k8s-worker/k8s-worker/' "
		set WORKER [lindex [split [eval $cmd] " "] 0]
		puts "-I- host is running on K8S Worker: $WORKER"	
	}
   }
   if {$_END} {
	if {![info exist SCRIPT_RUNTIME_START_VARIABLE]} {
		puts "-E- need to do start before end"
		return
	}
	set end_t [clock seconds]
	puts "###################################################################################################"
	puts "#     Start running STAGE at: [clock format $SCRIPT_RUNTIME_START_VARIABLE -format "%d/%m/%y %H:%M:%S"]"
	puts "#     End running STAGE at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
	puts "#     Elapse time is [expr ($end_t - $SCRIPT_RUNTIME_START_VARIABLE)/60/60/24] days , [clock format [expr $end_t - $SCRIPT_RUNTIME_START_VARIABLE] -timezone UTC -format %T]"
	puts "###################################################################################################"
   }
}


if {[info exists ::synopsys_program_name] } {
	define_proc_attributes script_runtime_proc \
  		-define_args {
    			{-start "starttime for runtime proc" "" boolean {optional}}
    			{-end "print to screen runtime of script" "" boolean {optional}}
     	}
} elseif { [info exists env(LEC_VERSION) ]} {
} else {
	define_proc_arguments script_runtime_proc \
		-info "print to runtime of script." \
		-define_args {
			{-start "starttime for runtime proc" "" boolean {optional}}
			{-end "print to screen runtime of script" "" boolean {optional}}
		}
}

################################################################################################################
##   user_wait_Quantus_license	- check if Quantus license exists 								
################################################################################################################
proc user_wait_license {args} {
  parse_proc_arguments -args $args options
  if {[info exists options(-timeout) ]}    {set TIMEOUT $options(-timeout)} 
  if {[info exists options(-required_features) ]}   {set _LIST_OF_REQUIRED_FEATURES $options(-required_features)}
  set TIME_TO_PRINT_MASSAGE 10

  set START_TIME [clock seconds] 
  set TIMEOUT_FLAG 1

#  set _list_of_required_features {}
#  lappend _list_of_required_features Virtuoso_QRC_Extraction_XL
#  lappend _list_of_required_features QRC_Advanced_Analysis
#  lappend _list_of_required_features Advanced_sub_10nm_modeling

  foreach _feature $_LIST_OF_REQUIRED_FEATURES {
	set _licenseCheck($_feature) Unavailable
  }
  puts "-I- checking if $_LIST_OF_REQUIRED_FEATURES licenses available. [exec date]"
  while { [regexp Unavailable [array get _licenseCheck]] == 1 && $TIMEOUT_FLAG } {
	if {[expr ([clock milliseconds] - $START_TIME*1000 )%(60*1000*$TIME_TO_PRINT_MASSAGE)] < 85} { puts "[expr ([clock milliseconds] - $START_TIME*1000 )%(60*1000*$TIME_TO_PRINT_MASSAGE)] -I- waiting for license to be available. [exec date]" }
	if {[info exists  TIMEOUT] && [expr [clock seconds] - $START_TIME] > $TIMEOUT} {
		puts "-W- Timeout reached"
		set TIMEOUT_FLAG 0
	}
	foreach _feature $_LIST_OF_REQUIRED_FEATURES {
		foreach line [split [ exec lmstat -a -f $_feature  ] "\n"] {
			if {[regexp Total $line]} {
       				regexp {Total of ([0-9]+) license[s]* in use} $line match in_use_licenses
        			regexp {Total of ([0-9]+) license[s]* issued} $line match issued_licenses
				#puts $line
			}
		}
        	if { $in_use_licenses < $issued_licenses } {
            		set _licenseCheck($_feature) Available
        	} 
	}  
  }
  if {!$TIMEOUT_FLAG} {
	return 0
  } else {
	puts "-I- license available continue running. waiting time for license: [clock format [expr [clock seconds] - $START_TIME] -timezone UTC -format %T]"
	return 1
  }
 
}

if {![info exists ::synopsys_program_name] && ![info exists env(LEC_VERSION)]} {
define_proc_arguments user_wait_license \
  -info "check if license of requierd feature available" \
  -define_args {
    {-required_features "list of requierd features need check for" "" list {required}}
    {-timeout "if time in second pass this number. proc will stop waiting for license and return timeout." "" int {optional}}
     }
}

################
# BE UNIQ DATA #
proc be_uniquify_data {args} {
  # // Modify lists or arrays to hold uniqe values, and keep original order  //
    set PROC "[lindex [info level 0] 0]"
  # Parse args
    set help_info "
$PROC takes lists and arrays, and updates them to be uniquified    
"
    # opt_name         must  type      default              info
    set my_args {
      { list_names       0  string      ""                  "list of list names to uniquify" }
      { array_names      0  string      ""                  "list of array names to uniquify" }
      { pattern          0  string      ""                  "list of patterns in array fields to uniquify" }
      { verbose         0  boolean     0                   "print additional info" }
    }

    if { [be_parse_args $help_info $my_args $args] != 0 } { return }

  # Check inputs (must have at least one of 'list_names' or 'array_names')
    if { ![info exists list_names] && ![info exists array_names] } {
        puts "ERROR - $PROC requires either '-list_names' or '-array_names' as inputs"
    }    

  # // ~ Proc Body ~ //
  # Iterating over lists
    if { [info exists list_names] } {
        foreach my_list $list_names {
            if { $verbose } {
                puts "-I- $PROC - GOT $my_list"
            }
          # linking list into proc level  
            set local_list "lcl_${my_list}"
            catch {upvar $my_list $local_list} res
            if { ![info exists $local_list] } { 
	        if { $verbose } { puts "-I- list $my_list doesn't exist at sending proc level" }
	        continue 
	    }            
            set orig_len [llength [set $local_list]]
          # uniquifying list

            if { $verbose } {
                puts "-I- $PROC -   initial list:    [set $local_list]"
                puts "-I- $PROC -     (initial length: $orig_len)"
            }
            array unset   my_res
            array set     my_res [be_uniq_list [set $local_list]]

          # updating value of input list to the uniquified list
            set $local_list $my_res(uniq_list)
            if { $verbose } {
                puts "-I- $PROC -   final entry:    $my_res(uniq_list)"
                puts "-I- $PROC -     (final length: [llength $my_res(uniq_list)])"
            }

          # print basic info
            if { [llength $my_res(dup_list)] } {
                puts     "-I- $PROC -   uniquified list $my_list"
                if { $verbose } {
                    puts "-I- $PROC -      listing removed items from the list:"
                    puts "-I- $PROC -        $my_res(dup_list)"
                }
            } else {
                if { $verbose } {    
		    puts     "-I- $PROC -   list $my_list was already uniq"
            	}
	    }
        }
    }
  # Iterating over arrays
    if { [info exists array_names] } {
        set num_of_arrays [llength $array_names]
        for {set i 0} {$i<$num_of_arrays} {incr i} {
            set my_arr [lindex $array_names $i]
            set my_pat [lindex $pattern $i]
            if { $my_pat == "" } { set my_pat "*" }

            if { $verbose } {
                puts "-I- $PROC - GOT all entries of array $my_arr filtered by $my_pat"
            }
          # linking array to local proc
            set local_arr "lcl_${my_arr}"
            catch [upvar $my_arr $local_arr] res
	    if { ![info exists $local_arr] } { 
		if { $verbose} { puts "-I- array $my_arr does not exist in calling level" }
		continue 
	    }
          # iterating over all filtered entries of the array
            foreach entry [lsearch -all -inline [array names $local_arr] "$my_pat"] {
                set orig_len [llength [set ${local_arr}($entry)]]
                if { $verbose } {
                    puts "-I- $PROC -   initial entry:    [set ${local_arr}($entry)]"
                    puts "-I- $PROC -     (initial length: $orig_len)"
                }
              
              # uniquifying list
                array unset   my_res
                array set     my_res [be_uniq_list [set ${local_arr}($entry)]]
                set new_list $my_res(uniq_list)

                if { $verbose } {
                    puts "-I- $PROC -   final entry:    $new_list"
                    puts "-I- $PROC -     (final length: [llength $new_list])"
                }

                if { [llength $my_res(dup_list)] } {
                    puts "-I- $PROC -   uniquified array entry ${my_arr}($entry)"
                    if { $verbose } {
                        puts "-I- $PROC -    listing removed items from the array entry:"
                        puts "-I- $PROC -        $my_res(dup_list)"                    
                    }
                } else {
                    if { $verbose } {
                        puts     "-I- $PROC -   array entry ${my_arr}($entry) was already uniq"
                    }
                }
              # updating array entry
                set ${local_arr}($entry) $new_list
            }        
        }
    }
}

# uniquifies a list in-order, returns new list
proc be_uniq_list {in_list} {
    array set results "uniq_list {} dup_list {}"
    
    foreach val $in_list {
        if { [lsearch $results(uniq_list) $val] < 0 } {
            lappend results(uniq_list) $val 
        } else {
            if { [lsearch $results(dup_list) $val] < 0 } {
                lappend results(dup_list) $val
            }
        }
    }
    return [array get results]
}

# 
proc be_scale_green_red { val {max 1000} } {

    set i [expr int(round((30.0*(min($val,$max))/$max))) ]

    set g [format %X [expr min(15,(30 - $i))]]
    set r [format %X [expr min(15,$i)]]

    return "#${r}${r}${g}${g}00"
}


::parseOpt::cmdSpec rls_table {
    -help "Prints out a list of lists in a text table"
    -opt {
	{-optname title         -type string  -default "" -required 0 -help "title to print before table - no formatting"}
        {-optname table         -type list    -default {} -required 0 -help "table data - is a list of lists"}
        {-optname header        -type list    -default {} -required 0 -help "table header titles:\nuse empty string to skip a columns title\nuse a '-' prefix to align to the right"}
        {-optname repeat_header -type string  -default "" -required 0 -help "repeat header every X number of lines"}
        {-optname format        -type list    -default {} -required 0 -help "list of format styles for table columns"}
        {-optname breaks        -type bool    -default 0  -required 0 -help "include break lines?"}
        {-optname spacious      -type bool    -default 0  -required 0 -help "add extra spaces for columns?"}
        {-optname no_separator  -type bool    -default 0  -required 0 -help "no vertical separator?"}
        {-optname width_limit   -type string  -default "" -required 0 -help "limit column width (breaks to lines) - off by default"}
	{-optname offset        -type int     -default 0  -required 0 -help "add some spaces to the left of the entire table"}
        {-optname to            -type string  -default "" -required 0 -help "set output file handle instead of STDOUT"}
        {-optname file          -type string  -default "" -required 0 -help "set output file name instead of STDOUT"}
	{-optname footer        -type string  -default "" -required 0 -help "footer to print after table - no formatting"}
        {-optname csv_mode      -type bool    -default 0  -required 0 -help "write out a csv rather than an actual table\nheader will appear once, no break lines regardless of input\n-spacious, -breaks, -no_separator ignored\n-width_limit will cut lines rather instead of breaking\n-offset will add empty column entries instead of spaces"}
    }
}

# rls_table prints out a list of lists in a text table
proc rls_table {args} {
    global synopsys_program_name

    if { ![::parseOpt::parseOpt rls_table  $args] } { return 0 }

    set limit -1
    set hRepeat -1
    set breaks 0
    set extraSpaces 0
    set csvMode 0
    set header [list]
    set format [list]
    set vSep "|"
    set hSep "-"
    set xSep "+"
    set target ""
    set SPACE ""
    catch {if {$opt(-breaks)==1} {set breaks 1}}
    catch {if {$opt(-spacious)==1} {set extraSpaces 1}}
    catch {if {$opt(-csv_mode)==1} {set csvMode 1}}
    catch {if {$opt(-no_separator)==1} {set vSep " "; set xSep "-"}}
    if {[info exists opt(-header)]} {set header $opt(-header)}
    if {[info exists opt(-format)]} {set format $opt(-format)}
    if {[info exists opt(-repeat_header)]} {set hRepeat $opt(-repeat_header)}
    if {[info exists opt(-width_limit)]} {set limit $opt(-width_limit)}
    if { $csvMode && \
             ($extraSpaces || $breaks || $vSep== " " || [expr {$hRepeat == -1}] ) } {
	puts "-W- Ignoring -spacious, -breaks, -no_separator, -repeat_header in csv mode"
	set hRepeat -1
	set breaks 0
    }
    set table $opt(-table)

    if { $opt(-to) != "" && $opt(-file) != "" } {
        puts "-E- Cannot specify both -file and -to"
        return 0
    }
    if { $opt(-to) != "" } {
        set target $opt(-to)
    } elseif { $opt(-file) != "" } {
        if {[catch {open $opt(-file) w} target]} {
            puts "-E- Failed to open $opt(-file) log file for output"
            return 0
        }
    }
 
    if {([llength $header]==0) && ($breaks || $hRepeat>-1)} {
	puts "-E- rls_table: -breaks and -repeat_header require the header to be specified"
	return 0
    }

    if {$extraSpaces} {
	set vSep " $vSep "
	set xSep "$hSep$xSep$hSep"
    }

    # handle padding reversal in header
    set direction [list]
    if {[llength $header]>0} {
	set tempHeader [list]
	foreach column $header {
	    if {[string range $column 0 0]=="-"} {
		lappend tempHeader [string range $column 1 end]
		lappend direction ""
	    } else {
		lappend tempHeader $column
		lappend direction "-"
	    }
	}
	set header $tempHeader
    }

    array set COLUMN {}
    array set EXTRA {}
    array set VSEP {}
    # get column widths for all data lines
    set num 0
    set fixedTable [list]
    array set HEIGHT {}
    for {set lineNum 0} {$lineNum<[llength $table]} {incr lineNum} {
	set line [lindex $table $lineNum]
	if {($line=="header") || ($line=="break")} {
	    if {!$opt(-csv_mode)} {
	    	# ignore these lines in csv mode
	    	lappend fixedTable $line
	    }
	    continue
	}
	set fixedLine [list]
	set maxHeight 1
	for {set i 0} {$i<[llength $line]} {incr i} {
	    set fixedSub [list]
	    
	    set column [lindex $line $i]
	    # limit column width
	    if {$limit>-1} {
		if {$csvMode} {
		    set column [string range $column 0 [expr $limit -1]]
		} else {
		    set fixedColumn [list]
		    foreach subline [split $column "\n"] {
			while {[string length $subline]>$limit} {
			    lappend fixedColumn [string range $subline 0 [expr $limit-1]]
			    set subline [string range $subline $limit end]
			}
			if {[string length $subline]>0} {
			    lappend fixedColumn $subline
			}
		    }
		    set column [join $fixedColumn "\n"]
		}
	    }
	    set height 0
	    foreach subline [split $column "\n"] {
		# format entry
		incr height
		if {[llength $format]>0} {
		    if {[expr {[llength $format]>$i}]} {
			set thisFormat [lindex $format $i]
			if {$thisFormat!=""} {
			    catch {set subline [format $thisFormat $subline]}
			}
		    }
		}
		# handle width
		set len [string length $subline]
		if {[info exists COLUMN($i)]} {
		    if {[expr {$len>$COLUMN($i)}]} {
			set COLUMN($i) $len
		    }
		} else {
		    set COLUMN($i) $len
		    set EXTRA($i) ""
		    set num [expr {$i+1}]
		}
		# handle separator
		if {[lindex $header [expr 1+$i]]==""} {
		    regsub -all {.} $vSep { } VSEP($i)
		} else {
		    set VSEP($i) $vSep
		}
		lappend fixedSub $subline
	    }
	    if {[string length $column]==0} {
		if {![info exists COLUMN($i)]} {
		    set COLUMN($i) 0
		}
		if {![info exists EXTRA($i)]} {
		    set EXTRA($i) ""
		}
		if {![info exists VSEP($i)]} {
		    if {[lindex $header [expr 1+$i]]==""} {
			regsub -all {.} $vSep { } VSEP($i)
		    } else {
			set VSEP($i) $vSep
		    }
		    lappend fixedSub ""
		}
	    }
	    if {$height>$maxHeight} {set maxHeight $height}
	    lappend fixedLine [join $fixedSub "\n"]
	}
	if {$maxHeight>1} {set HEIGHT($lineNum) $maxHeight}
	lappend fixedTable $fixedLine
    }
    set table $fixedTable

    # open multiple lines
    if {[llength [array names HEIGHT]]>0} {
	set fixedTable [list]
	for {set lineNum 0} {$lineNum<[llength $table]} {incr lineNum} {
	    set line [lindex $table $lineNum]
	    if {($line=="header") || ($line=="break") || ![info exists HEIGHT($lineNum)]} {
		lappend fixedTable $line
		continue
	    }
	    # actual work
	    for {set slNum 0} {$slNum<$HEIGHT($lineNum)} {incr slNum} {
		set fixedLine [list]
		foreach column $line {
		    lappend fixedLine [lindex [split $column "\n"] $slNum]
		}
		lappend fixedTable $fixedLine
	    }
	}
	set table $fixedTable
    }

    if {([info exists opt(-title)]) && ($opt(-title)!="")} {
	rls_table_echo $opt(-title) $target
    }

    if {[info exists opt(-offset)]} {
	if {$csvMode} {
	    while {[string length $SPACE]<$opt(-offset)} {append SPACE ","}
	} else {
	    set SPACE [format "%$opt(-offset)s" ""]
	}
    }

    if {$header!=""} {
	# create empty columns if header has more entries
	while {$num<[llength $header]} {
	    set COLUMN($num) 0
	    set EXTRA($num) ""
	    regsub -all {.} $vSep { } VSEP($num)
	    incr num
	}
	# create empty header titles if table has more columns
	while {[llength $header]<$num} {
	    lappend header ""
	    lappend direction "-"
	}

	# handle header widths
	set formattedHeader ""
	set breakLine ""
	set extra 0
	set extraSpot 0
	for {set i [expr [llength $header]-1]} {$i>=0} {set i [expr $i-1]} {
	    set element [lindex $header $i]
	    if {($element=="") && ($i!="0")} {
		set extra [expr {$extra+$COLUMN($i)+1+2*$extraSpaces}]
		if {$extraSpot==0} {
		    set extraSpot $i
		}
	    } else {
		set missing [expr {[string length $element]-$COLUMN($i)-$extra}]
		for {set j 0} {$j<$missing} {incr j} {
		    if {$extraSpot>0} {
			append EXTRA($extraSpot) " "
		    } else {
			incr COLUMN($i)
		    }
		}
		for {} {$missing<0} {incr missing} {
		    append element " "
		}
		if {$csvMode} {
		    regsub -all {(^|[^\\]),} [lindex $header $i] {\1\,} cleanElement
		    set formattedHeader "$cleanElement,$formattedHeader"
		} else {
		    set formattedHeader [format "%s%s%s" $element $vSep $formattedHeader]
		}
		regsub -all {.} $element $hSep breakPart
		set breakLine "$breakPart$xSep$breakLine"
		set extra 0
		set extraSpot 0
	    }
	}
	if {$csvMode} {
	    regsub {\,+$} $formattedHeader {} formattedHeader
	} else {
	    set formattedHeader [string range $formattedHeader 0 [expr [string length $formattedHeader]  - [string length $xSep]] ]
	}
	set breakLine [string range $breakLine 0 [expr [string length $breakLine] - [string length $xSep]]]
	rls_table_echo $formattedHeader $target
	if {$breaks} {rls_table_echo $breakLine $target}
    } else {
	# set default left->right direction
	for {set i 0} {$i<$num} {incr i} {lappend direction "-"}
    }

    # prepare format line
    set formatLine ""
    for {set i 0} {$i<$num} {incr i} {
	if {$csvMode} {
	    append formatLine "%s,"
	} else {
	    append formatLine "%[lindex $direction $i]$COLUMN($i)s$EXTRA($i)$VSEP($i)"
	}
    }
    if {$csvMode} {
	regsub {\,+$} $formatLine {} formatLine
    } else {
	set formatLine [string range $formatLine 0 [expr [string length $formatLine]-[string length $vSep]]]
    }

    set counter 0
    foreach line $table {
	if {($counter==$hRepeat) || (!$csvMode && $line=="header")} {
	    if {$csvMode} {
		rls_table_echo $formattedHeader $target
	    } else {
		if {$breaks} {rls_table_echo $breakLine $target}
		rls_table_echo $formattedHeader $target
		if {$breaks} {rls_table_echo $breakLine $target}
		set counter 0
		if {$line=="header"} {continue}
	    }
	} elseif {!$csvMode && ($line=="break")} {
	    if {[info exists breakLine]} {rls_table_echo $breakLine $target}
	    incr counter
	    continue
	}
	while {[llength $line]<$num} {lappend line ""}
	if {$csvMode} {
	    regsub -all {(^|[^\\]),} $line {\1\,} line
	}
	rls_table_echo [eval [list format $formatLine] $line] $target
	incr counter
    }

    set SPACE ""

    if {([info exists opt(-footer)]) && ($opt(-footer)!="")} {
	rls_table_echo $opt(-footer) $target
    }

    if { $opt(-file) != "" } {
        close $target
    }
}
###############################################################
proc rls_table_echo {{line} {target ""}} {
  upvar SPACE SPACE
  if {$target==""} {
    puts "$SPACE$line"
  } else {
    puts $target "$SPACE$line"
  }
}
###############################################################

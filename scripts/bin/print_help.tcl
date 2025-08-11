#!/bin/tclsh

#puts "This is my\033\[1;3;30;47m Special \033\[0mtext" ; #RED
#puts "Special"
#puts -nonewline "\033\[0m text";# Reset

proc be_style { str } {
    
    set start  "\\\\-BSS\\\\-"
    set end    "\\\\-BSE\\\\-"    
    set style_start "\033\[1;3;30;47m "
    set style_end   " \033\[0m"

	set style [regsub -all $end [regsub -all $start $str $style_start] $style_end]

    set style [regsub -all "/appost/" $style "'"]

    return $style

}

set help_text [split [join $argv " "] ";"]

set max_flag 4
set max_def  9
set max_desc 11

set table {}
foreach line $help_text { 
#	puts "L: $line"         
    if { $line == "" } { continue }
    set spline  [split $line "'"]
#    puts $line
    set desc    [be_style [lindex $spline end-1]]
    lassign [split [lindex $spline 0] " "] blank flag def
    
  	set desc_len [string length $desc]
    set def_len  [string length $def]
    set flag_len [string length $flag]
    
    if { $desc_len > $max_desc } { set max_desc [expr 1 + $desc_len] }
    if { $def_len >  $max_def   } { set max_def  [expr 2 + $def_len ] }
    if { $flag_len > $max_flag } { set max_flag [expr 1 + $flag_len] }
    
#    puts "$flag;$def;$desc"
    
    lappend table [list $flag $def $desc]    
}

set header [list [format "%-${max_flag}s" "Flag"] [format "%-${max_def}s" "Default"] [format "%-${max_desc}s" "Description"]]
set spacer [string repeat "-" [expr $max_flag + $max_def + $max_desc]]

puts [join $header]
puts $spacer

foreach line $table {
    lassign $line flag def desc
    set new_line [list [format "%-${max_flag}s" "$flag"] [format "%-${max_def}s" "$def"] [format "%-${max_desc}s" "$desc"]]
	puts [join $new_line]
}


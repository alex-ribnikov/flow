#!/bin/tclsh

if { [llength $argv] == 0 } {
	set repo_source  $::env(REPO_SOURCE)
	set filelist     $::env(FILELIST)
} else {
    set repo_source $argv[1]
    set filelist    $argv[2]
}

if { [file exists $filelist] } {
set fp      [open $filelist r]
set fp_data [read $fp]
close $fp
} else {
puts "-E- Filelist $filelist not found!"
return
}

set parsed_file_list ""

puts "-I- Reading file list from: $filelist"

foreach line [split $fp_data "\n"] {
       
    # If sub filelist:
    if { [regexp "^\-f " $line res] } {
        set sub_filelist [regsub -all "^\./" [lindex [split $line " "] 1] "$repo_source/"]
        set sub_filelist_data   [regsub -all "REPLACETHIS" [exec cat $sub_filelist | sed {s/\.\//REPLACETHIS/g}] "$repo_source/"]
        append parsed_file_list "$sub_filelist_data\n"
    } else {
        append parsed_file_list "$line\n"
    }

}

if { [info exists ::env(WORK)] } { 
    set private_filelist $::env(WORK)/inter/private_filelist.flist
} else {
    set private_filelist ./inter/private_filelist.flist
}
set fp [open $private_filelist w]

puts $fp $parsed_file_list

close $fp

puts "-I- Generated filelist is in: ./inter/private_filelist.flist"

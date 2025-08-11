set nextinside_path $NEXTINSIDE
set lists_location  $nextinside_path/auto_gen/gendir/$DESIGN_NAME/${DESIGN_NAME}_gen_filelist/ ; # Assumed location of lib and lef lists
set be_flow_folder  $::env(BEROOT)/be_flow/ns_flow/scripts/

##################################
# Generate filelists names
##################################
set filelist [list "leflist"]
foreach key [array names pvt_corner] {
    if { ![regexp "timing" $key] } { continue }  
    set corner [lindex [split $key ","] 0]
    lappend filelist "${corner}.liblist"
}

##################################
# Check for a private filelists
##################################
set realpaths {}
foreach file $filelist {
    if       { [file exists ./$file] } {
#        puts "-I- Reading file $file from: [exec realpath ./$file]"
        lappend realpaths ./$file    

    } elseif { [file exists ../inter/$file] } {
#        puts "-I- Reading $file from: [exec realpath ../inter/$file]"
        lappend realpaths ../inter/$file

    } elseif { [file exists $lists_location/$file] } {
#        puts "-I- Reading $file from: $lists_location/$file"
        lappend realpaths $lists_location/$file
        
    } elseif { [file exists $be_flow_folder/$file] } {
#        puts "-I- Reading $file from: $be_flow_folder/$file"
        lappend realpaths $be_flow_folder/$file
    }
}

##################################
# Read filelists
##################################
foreach file $realpaths {

    set fp [open $file r]
    set fd [read $fp]
    close $fp

    if { [regexp "/leflist" $file] } {
        puts "-I- Reading $file into leflist"
        set LEF_FILE_LIST "$LEF_FILE_LIST [join [split $fd "\n"] " "]"
    } else {
        set PVT_CORNER [lindex [split [lindex [split $file "/"] end] "."] 0]
        puts "-I- Reading $file into pvt_croners $PVT_CORNER"
        set pvt_corner($PVT_CORNER,timing) "$pvt_corner($PVT_CORNER,timing) [join [split $fd "\n"] " "]"
    }

}

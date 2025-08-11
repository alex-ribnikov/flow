set nextinside_path $::env(RTL_SOURCE)
set filelist        $nextinside_path/auto_gen/gendir/$::env(BLOCK)/${::env(BLOCK)}_gen_filelist/filelist

if {[file exists auto_gen]} {file delete auto_gen}
if {[file exists design]} {file delete design}
file link -symbolic auto_gen $nextinside_path/auto_gen
file link -symbolic design $nextinside_path/design

##################################
# Check for a private filelist
##################################
if       { [file exists $::env(WORK)/filelist] } {
    puts "-I- Reading filelist from: $::env(WORK)/filelist"
    read_hdl -language sv -f $::env(WORK)/filelist    

} elseif { [file exists $::env(WORK)/inter/filelist] } {
    puts "-I- Reading filelist from: $::env(WORK)/inter/filelist"
    read_hdl -language sv -f $::env(WORK)/inter/filelist

} else {
    puts "-I- Reading filelist from: $filelist"
    read_hdl -language sv -f $filelist
}


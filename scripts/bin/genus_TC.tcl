##########README################################
# source build.tcl at the place where you want to write out the testcase.
# A directory called gtcase will be generated
# To make sure gtcase doesn't contain any softlink
# You can do something like:
# cp -Lrfp gtcase gtcase_2
# rm -rf gtcase
# mv gtcase
# Please transfer the gtcase 
################################################



# testcase directory
#set td genus_testcase
set td gtcase
set F  testcase

# create directories
file mkdir $td

# write genus db script containing tcl and db data
write_db -all -script $td/${F}.tcl $td/${F}.db

# testcase tcl sed script
set script sed.csh
file rename -force $td/${F}.tcl $td/${F}_orig.tcl
redirect $script {puts -nonewline "cat $td/${F}_orig.tcl"}

# populate local library directories

# mmmc
file mkdir $td/libs
set dir $td/libs/mmmc
file mkdir $dir

# rc_corners
foreach x [::legacy::get_attr rc_corners] {
  file mkdir $dir/[file tail $x]
  #!set new_attr ""
  foreach f [::legacy::get_attr qrc_tech_file $x] {
    set cmd "file copy -force $f $dir/[file tail $x]"
    puts "Info: $cmd"
    eval $cmd
    redirect -append $script {puts -nonewline " | sed \"s*$f*./$dir/[file tail $x]/[file tail $f]*\""}
  }
}

# lef libraries
set dir $td/libs/lef
file mkdir $dir
#!set new_attr ""
foreach f [::legacy::get_attr lef_library] {
  set cmd "file copy -force $f $dir"
  puts "Info: $cmd"
  eval $cmd
  redirect -append $script {puts -nonewline " | sed \"s*$f*$dir/[file tail $f]*\""}
}

# power
file mkdir $td/libs/power

# mmmc - libs
set dir $td/libs/mmmc
foreach x [::legacy::get_attr library_set] {
  foreach f [::legacy::get_attr library $x] {
    set cmd "file copy -force $f $dir/[file tail $f]"
    puts "Info: $cmd"
    eval $cmd
    redirect -append $script {puts -nonewline " | sed \"s*$f*$dir/[file tail $f]*\""}
  }
  foreach f [::legacy::get_attr socv_file $x] {
    set cmd "file copy -force $f $dir/[file tail $f]"
    puts "Info: $cmd"
    eval $cmd
    redirect -append $script {puts -nonewline " | sed \"s*$f*$dir/[file tail $f]*\""}
  }  
}

# add read_db to the end of the tcl script
redirect -append $script {puts "\necho \"\nread_db $td/${F}.db\n\""}


# run the sed script on the saved testcase tcl file to convert lib paths to local paths
exec chmod 755 $script
exec $script > $td/${F}.tcl


# clean up
#file delete $script
#file delete $td/${F}_orig.tcl

# how to run message
puts "\n# to run the testcase, from the directory above:
> genus -f $td/${F}.tcl
"


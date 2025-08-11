# TM general scripts 
proc showList {list_elem} {
   if {[string match "0x*" $list_elem]} {
      foreach elem [get_object_name $list_elem] {
         puts $elem
      }
   } else {
      foreach elem $list_elem {
         puts $elem
      }
   }
}

proc list2file {listArr fileName} {
   if {[file exists $fileName]} {exec rm $fileName}
   exec touch $fileName
   foreach listVar $listArr {
      echo $listVar >> $fileName
   }
}

proc file2list {fileName} {
   set listArr {}
   set fp [open $fileName r]
   while {[gets $fp data] >=0} {
      lappend listArr $data
   }
   return $listArr
}

proc ladd {l} {
   set total 0
   foreach nxt $l {
      set total [expr $total + $nxt]
   }
   return $total
}


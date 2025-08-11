if {[info command distribute_partition] != ""} {
   # index_collection and foreach_in_collection are not correctly supported for now in DSTA
   proc index_collection {collection index} {
      set _tcl_list {}
      foreach_in_collection _elt $collection {
         set _name [get_object_name $_elt]
         lappend _tcl_list $_name
         set _id($_name) $_elt
      }
      set _indexed_elt [lindex $_tcl_list $index]
      return $_id($_indexed_elt)
   }
}

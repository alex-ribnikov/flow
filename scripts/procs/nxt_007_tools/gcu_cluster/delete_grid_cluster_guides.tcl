# Delete LEB guides
proc delete_LEB_guides  {} {
  if {[get_db groups *LEB*] != ""} {
    delete_obj [get_db groups *LEB*]
  }
}

# Delete FT AON guides
proc delete_LEB_guides  {} {
  if {[get_db groups *_feedthrough_aon_*] != ""} {
    delete_obj [get_db groups *_feedthrough_aon_*]
  }
}

delete_LEB_guides
delete_LEB_guides

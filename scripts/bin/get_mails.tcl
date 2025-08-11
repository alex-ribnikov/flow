proc get_mails {} {
	source scripts/procs/common/be_mails.tcl
	set address [be_get_user_email]       
	if { $address != "" } {
		set suser [be_get_supper_user_email]
		foreach sss $suser {
			set address "$address [be_get_user_email $sss]"
		}
		regsub {\s} [lsort -unique $address] "," address
		return $address
	}
	return ""
}

puts [get_mails]

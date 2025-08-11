BEGIN {
   cmd = 0
}
{
if ($2 == "End" && $3 == "running" ) { 
	$1 = ""
	$2 = ""
	$3 = ""
	$NF = ""
	$(NF-1) = ""
	$(NF-2)=""
	cmd = $0 
	}

if ($2 == "Elapse" && $3 ==  "time" ) {
	if (cmd == 0) {
		print 0
	} else {
		$1 = ""
		$2 = ""
		$3 = ""
		$4 = ""
		print $0" : "cmd
		cmd = 0
	}
}

#if (cmd != 0 && $2 == "Elapse" && $3 ==  "time" ) {print "TTT"}

#{  $1 = "" ; $2 = "" ; $3 = "" ; print cmd" : "$0 ; cmd = 0} 
}

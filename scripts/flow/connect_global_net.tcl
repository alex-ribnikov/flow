lappend LOCAL_SCRIPTS [check_script_location]


foreach net $PWR_NET {
    foreach pin $PWR_PINS {
    	if {[llength [get_db pg_base_pins -if ".base_name ==$pin"]] > 0} {
        	connect_global_net $net  -type pg_pin -pin_base_name $pin
	} else {
		puts "-W- $pin does not exists in the design"
	}
    }
    connect_global_net $net  -type tiehi -all    
}

foreach net $GND_NET {
    foreach pin $GND_PINS {
    	if {[llength [get_db pg_base_pins -if ".base_name ==$pin"]] > 0} {
       		connect_global_net $net  -type pg_pin -pin_base_name $pin
	} else {
		puts "-W- $pin does not exists in the design"
	}
    }
    connect_global_net $net  -type tielo -all    
}



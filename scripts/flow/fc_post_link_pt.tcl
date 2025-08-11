#set XTALK_SI true
#set OCV pocv
#set PROJECT brcm3
#set STAGE compile

#source -e -v ./scripts/setup/setup.brcm3.tcl
source -e -v ${RUNNING_DIR}/scripts/flow/pt_variables.tcl

set mode  [lindex [split $ppslave_scenario "_"] 0]
set check [lindex [split $ppslave_scenario "_"] end]


if {$OCV == "pocv"} {
	regsub "${mode}_(.*)_${check}" $ppslave_scenario {\1} sub_pvt
	regexp {(.*[SF])_(.*)} $sub_pvt match pvt rc
	set TEV_OP_MODE [lindex [split $pvt "_"] end]
	
	if { [info exists pvt_corner($pvt,pt_pocv)]} {
	        foreach pocvm_file $pvt_corner($pvt,pt_pocv) {
	                puts "-I- reading OCVM file: $pocvm_file"
	                read_ocvm $pocvm_file
	        }
	}
	if { [info exists pvt_corner($pvt,pt_ocv)]} {
	        foreach pocvm_file $pvt_corner($pvt,pt_ocv) {
	                puts "-I- reading derate file: $pocvm_file"
	                source -e -v $pocvm_file
	        }
	}
}

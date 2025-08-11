source /space/users/ory/user/be_scripts/source_be_scripts.tcl
init_be_scripts

set block [get_db designs .name]
report_unsampled_ports ${block}_unsampled_port_report.rpt
exit


source ./scripts/procs/source_be_scripts.tcl


set DEFAULT_SITE CORE_6
set MAX_ROUTING_LAYER 16
set MIN_ROUTING_LAYER 2
set ADD_TOP_POWER false


connect_global_net VDD -type pg_pin -pin_base_name VDD
connect_global_net VSS -type pg_pin -pin_base_name VSS

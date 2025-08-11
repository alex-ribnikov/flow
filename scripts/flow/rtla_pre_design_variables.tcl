#------------------------------------------------------------------------------
# Variables to set before loading libraries
#------------------------------------------------------------------------------
#set search_path [list ./rm_setup ./rm_fc_scripts ./rm_tech_scripts ./rm_user_plugin_scripts]
lappend search_path .


   ## Enable on-disk operation for copy_block to save block to disk right away
   #  set_app_options -name design.on_disk_operation -value true ;# default false and global-scoped


# Controls HDLC naming style settings to make it easier to apply
# the same UPF file across multiple tools at the RTL level
set_app_options -name hdlin.naming.upf_compatible -value true

# set_app_options -name hdlin.elaborate.ff_infer_async_set_reset -value true
# set_app_options -name hdlin.elaborate.ff_infer_sync_set_reset  -value false



set_app_options -list {flow.runtime.version "ERI-20230820"}
enable_runtime_improvements

# Memory blockages zero_spacing setting
#set macros [get_flat_cells -filter "design_type==macro"]
#if [sizeof_collection $macros] {
#	set_attribute [get_routing_blockages -of $macros] is_zero_spacing true
#}

 set_app_options -list {design.enable_rule_based_query true}


########################################################################################## 
## Message handling
##########################################################################################
suppress_message ATTR-11 ;# suppress the information about that design specific attribute values override over library values
## set_message_info -id ATTR-11 -limit 1 ;# limit the message normally printed during report_lib_cells to just 1 occurence
set_message_info -id PVT-012 -limit 1
set_message_info -id PVT-013 -limit 1
puts "RM-info: Hostname: [sh hostname]"; puts "RM-info: Date: [date]"; puts "RM-info: PID: [pid]"; puts "RM-info: PWD: [pwd]"

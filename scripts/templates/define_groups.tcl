##################################################################
# -H- If you wish to reset all groups - set it to true
# -H- Otherwise, you will define new groups on top of the default ones
set reset false
foreach mode [get_db constraint_modes  .name] {      
    set_interactive_constraint_modes "$mode"

    if { $reset } { reset_path_group -all ; if { [catch {delete_obj [get_db cost_groups]} res] } {puts "-W- Failed to delete cost group"} ; set reset false }

    set mems     [get_db insts -if .base_cell.is_memory==true]
    set all_regs [remove_from_collection [filter_collection [all_registers ] is_integrated_clock_gating_cell!=true] $mems]

    # Higher number means higher priority
    set default_user_priority 100

    #############################################
    # -H- Set group's name, from and to hierarchies
    # -H- set groups_arr(group_name) {from_hierarchy to_hierarchy}
    # -H- if you wish to use just from or just to hierarchy, use an empty string ("")
    # -H- Using "*" means from/to all registers and memories
    array unset groups_arr
    set groups_arr(FromMCU) {"i_aon_nfi_mcu_top/i_nfi_mcu/i_mcu" "*"}
    set groups_arr(FromCBU) {"i_cbu" "*"}
    set groups_arr(FromNFI) {"i_aon_nfi_mcu_top/i_nfi_mcu/i_nfi_aon" "*"}
    #############################################

    puts "-I- Set user path groups"        
    foreach group_name [array names groups_arr] {
    
        set hier1 [lindex $groups_arr($group_name) 0]
        set hier2 [lindex $groups_arr($group_name) 1]
        set cmd "group_path -name $group_name"

        if { $hier1 != "" } {
            set hier1_cells [get_cells -hier -filter full_name=~$hier1/*]
            set hier1_from [add_to_collection [common_collection $hier1_cells $all_regs] [common_collection $hier1_cells $mems] ]
            append cmd " -from \$hier1_from"
            if { [llength $hier1] == 0 } { puts "-E- Did not find cells matching $hier1/*" }
        }

        if { $hier2 != "" } {
            set hier2_cells [get_cells -hier -filter full_name=~$hier2/*]
            set hier2_to [add_to_collection [common_collection $hier2_cells $all_regs] [common_collection $hier2_cells $mems] ]
            append cmd " -to \$hier2_to"
            if { [llength $hier2] == 0 } { puts "-E- Did not find cells matching $hier2/*" }
        }        
        puts "-I- Set path_group from $hier1 to $hier2"
        set excp [eval $cmd]
        set_db $excp .user_priority $default_user_priority
        
    }

    set_interactive_constraint_modes {}   
}

##################################################################################
## -H- IF YOU WISH TO PRINT REPORT BY PATH GROUP, UNCOMMENT THE FOLLOWING SECTION:
##################################################################################
#set number_of_paths_per_group 10000 ; # Edit to change number of paths per group
#set report_prefix "syn_opt"         ; # Edit to change prefix
#set sub_stage "additional_reports"
#sh mkdir -pv reports/$sub_stage
#foreach group [get_db designs .path_groups.cost_group.name] {
#    puts "-I- Report timing for group $group"
#    be_report_timing_summary -max_slack 999 -max_paths $number_of_paths_per_group  \
#      -nworst 1  -group $group -out reports/$sub_stage/${report_prefix}.rpt.$group
#}















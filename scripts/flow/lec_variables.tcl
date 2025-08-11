tcl_set_command_name_echo on
set_log_file log/lec.log -replace

set_screen_display -noprogress
#set_dofile_abort exit
set_dofile_abort on


### Alias mapping flow is enabled. ###
# Root attribute 'wlec_rtl_name_mapping_flow' was 'false'.
# Root attribute 'alias_flow'                 was 'true'.

set lec_version [regsub {(-)[A-Za-z]} $env(LEC_VERSION) ""]

# Turns on the flowgraph datapath solver.
set wlec_analyze_dp_flowgraph true
# Indicates that resource sharing datapath optimization is present.
set share_dp_analysis         false
# default is to error out when module definitions are missing
set_undefined_cell black_box -noascend -both
# MB options
set_multibit_option -prefix "" -delimiter "_MB_" -revised



# The flowgraph solver is recommended for datapath analysis in LEC 19.1 or newer.
if {$wlec_analyze_dp_flowgraph} {
    set DATAPATH_SOLVER_OPTION "-flowgraph"
} elseif {$share_dp_analysis} {
    set DATAPATH_SOLVER_OPTION "-share"
} else {
    set DATAPATH_SOLVER_OPTION ""
}


# output DB
set_verification_information fv_db


set_flatten_model -verification_info_strip_cdn_name_extension

set_flatten_model -gated_clock
set_flatten_model -seq_constant
set_flatten_model -balanced_modeling



if { $LEC_MODE == "rtl2syn" } {
    set_naming_style genus -golden
set_naming_rule "_" -parameter -golden
set_naming_rule "_" "" -array_delimiter -golden
set_naming_rule "%s\[%d\]" -instance_array -golden
set_naming_rule "%s_reg" -register -golden
set_naming_rule "%L_%s" "%L_%d_%s" "%s" -instance -golden
set_naming_rule "%L_%s" "%L_%d_%s" "%s" -variable -golden
    set_naming_rule -ungroup_separator {_} -golden
    
    
# Align LEC's treatment of mismatched port widths with constant
# connections with Genus's. Genus message CDFG-467 and LEC message
# HRC3.6 may indicate the presence of this issue.
# This option is only available with LEC 17.20-d301 or later.
    set_hdl_options -const_port_extend
# Root attribute 'hdl_resolve_instance_with_libcell' was set to true in Genus.
set_hdl_options -use_library_first on
# Align LEC's treatment of libext in command files with Genus's.

    set_hdl_options -nolibext_def on
    set_hdl_options -VERILOG_INCLUDE_DIR "cwd:incdir:src:yyd:sep"
    
    
    

}

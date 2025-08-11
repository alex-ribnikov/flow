# Color Hierarchies and Ports #
# --------------------------- #

# The searches will be for 'get_db insts/ports *<line_from_list>*'
# you can add '*' inside, or use spaces for multiple searches per line

# // Using COLOR_HIERS as an array of titles + hier patterns in order to support multiple images
if {[info exists COLOR_HIERS]} {
unset COLOR_HIERS
}
set COLOR_HIERS  "
i_apb_splitter {*i_apb_splitter*}
cond_tlm {*_cond_*_tlm*}
i_sb_node {*i_sb_node*}
csr_cfg {*csr_cfg*}
csr_prdata {*csr_prdata*}
xbar_data_channels {*xbar_data_channels*}
i_lcb_unit {*i_lcb_unit*}
"
#
#unset COLOR_HIERS
#array set COLOR_HIERS "
#0 {
#ENDCAP_ {ENDCAP_*}
#}
#1 {
#compile_ {compile_*}
#}
#2 {
#dlink_to_west {*dlink_to_west*}
#bcg_i_grid_clk {*bcg_i_grid_clk*}
#}
#"

# // COLOR PORTS can also be an array, or stay as list.
# // if it is a list   - it will be added to every COLOR_HIERS image
# // if it is an array - it will only be added to the respective COLOR_HIERS with same idx

set COLOR_PORTS "
xbar_data  {*xbar_data*}
cbu_lcb_data_and_cond_elephant  {*cbu_lcb_data_and_cond_elephant*}
apb_master  {*apb_master*}
ds_data   {*ds_data*}
us_data   {*us_data*}
"
# //

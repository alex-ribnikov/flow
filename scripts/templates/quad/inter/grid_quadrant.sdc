# grid_quadrant.sdc
# Updated 1/6/2022 - Yigal

if { ![info exists CLUSTER_NAME] } {
    set CLUSTER_NAME ""
} else {
    set CLUSTER_NAME "${CLUSTER_NAME}/"
}
if { ![info exists INST_NAME] } {
    set INST_NAME "${CLUSTER_NAME}"
    set fc 0
    if {([info exist flat] && $flat)} {
	set s "_"
	set ss "__"
    } elseif {([info exist ::synopsys_program_name] && $::synopsys_program_name eq "dc_shell") || ([info command is_common_ui_mode] ne "" && [get_db program_short_name] eq "genus") || ([info exist flat] && !$flat)} {
	set s "/"
	set ss "/"
    } else {
	set s "_"
	set ss "__"
    }
} else {
    set INST_NAME "${INST_NAME}/${CLUSER_NAME}"
    set fc 1
}


# Define variable which identifies whether flow is at synopsys or cadence
set synopsys  0
if {[info exists ::synopsys_program_name]} {
    set synopsys 1
}

######################
# clocks_parameters.sdc
# created by Yigal on Jun 2021

# Clocks parameters 
#
set GRID_CLK_PERIOD 0.625
set APB_CLK_PERIOD 2
set TEST_CLK_PERIOD 40
#

set GRID_CLK_UNC 0.060
set APB_CLK_UNC 0.18
set TEST_CLK_UNC 1

if { ![info exist TEV_OP_MODE] } {
  set HOLD_UNCERTAINTY 0.01
} elseif { [info exist TEV_OP_MODE] && $TEV_OP_MODE == "FF" } {
  set HOLD_UNCERTAINTY 0.01
} else {
  set HOLD_UNCERTAINTY 0.025
}

#

set UNC_SCALING 0
if {([info exist ::synopsys_program_name] && $::synopsys_program_name eq "dc_shell") || ([info command is_common_ui_mode] ne "" && [get_db program_short_name] eq "genus")} {set UNC_SCALING 0.08}
if {([info exist ::synopsys_program_name] && $::synopsys_program_name eq "icc_shell") || ([info command is_common_ui_mode] ne "" && [get_db program_short_name] eq "innovus")} {
    if { ![info exist STAGE] } {
	set UNC_SCALING 0.08
    } elseif { $STAGE == "place" } {
	set UNC_SCALING 0.08
    } elseif { $STAGE == "cts" } {
	set UNC_SCALING 0.06
    } elseif { $STAGE == "route" } {
	set UNC_SCALING 0.02
    }
}
if {([info exist ::synopsys_program_name] && $::synopsys_program_name eq "pt_shell") || ([info command is_common_ui_mode] ne "" && [get_db program_short_name] eq "tempus")} {
    if { $fc == 0 } { set UNC_SCALING 0.02 }
}
set GRID_CLK_UNC       [expr ($GRID_CLK_UNC       + ($UNC_SCALING * $GRID_CLK_PERIOD))]
set APB_CLK_UNC        [expr ($APB_CLK_UNC        + ($UNC_SCALING * $APB_CLK_PERIOD))]
set TEST_CLK_UNC       [expr ($TEST_CLK_UNC       + ($UNC_SCALING * $TEST_CLK_PERIOD))]


# clocks_parameters.sdc
######################


#if {![info exists IS_CLOCK] ||  !$IS_CLOCK} {
    # Clocks defintions 
    #
    create_clock -period $GRID_CLK_PERIOD     -name grid_clk [get_ports grid_clk]
    create_clock -period $GRID_CLK_PERIOD     -name grid_east_0_clk [get_ports grid_clk_from_east[0]]
    create_clock -period $GRID_CLK_PERIOD     -name grid_east_1_clk [get_ports grid_clk_from_east[1]]
    create_clock -period $GRID_CLK_PERIOD     -name grid_east_2_clk [get_ports grid_clk_from_east[2]]
    create_clock -period $GRID_CLK_PERIOD     -name grid_east_3_clk [get_ports grid_clk_from_east[3]]
    # Virtual Clocks
    create_clock -period $GRID_CLK_PERIOD     -name virtual_grid_clk
    create_clock -period $GRID_CLK_PERIOD     -name virtual_grid_east_0_clk
    create_clock -period $GRID_CLK_PERIOD     -name virtual_grid_east_1_clk
    create_clock -period $GRID_CLK_PERIOD     -name virtual_grid_east_2_clk
    create_clock -period $GRID_CLK_PERIOD     -name virtual_grid_east_3_clk
    create_clock -period $APB_CLK_PERIOD      -name virtual_apb_clk
    
if {!$fc} {
create_clock -name TEST__DFT_CLK -period $TEST_CLK_PERIOD [get_ports {TEST__DFT_CLK}]
set_clock_uncertainty -setup  $TEST_CLK_UNC [get_clocks {TEST__DFT_CLK}]
create_clock -name virtual_TEST__DFT_CLK -period $TEST_CLK_PERIOD
set_clock_uncertainty -setup  $TEST_CLK_UNC [get_clocks {virtual_TEST__DFT_CLK}]
create_clock -name TEST__EDT_CLOCK -period $TEST_CLK_PERIOD [get_ports {TEST__EDT_CLOCK}]
set_clock_uncertainty -setup  $TEST_CLK_UNC [get_clocks {TEST__EDT_CLOCK}]
create_clock -name virtual_TEST__EDT_CLOCK -period $TEST_CLK_PERIOD
set_clock_uncertainty -setup  $TEST_CLK_UNC [get_clocks {virtual_TEST__EDT_CLOCK}]
create_clock -name tessent_bisr_clock_TEST__BISR_CLK -period $TEST_CLK_PERIOD [get_ports TEST__BISR_CLK]
set_clock_uncertainty -setup  $TEST_CLK_UNC [get_clocks {tessent_bisr_clock_TEST__BISR_CLK}]
create_clock -name virtual_TEST__BISR_CLK  -period $TEST_CLK_PERIOD
set_clock_uncertainty -setup  $TEST_CLK_UNC [get_clocks {virtual_TEST__BISR_CLK}]
}

    # Uncertainty
    #
    set_clock_uncertainty -setup $GRID_CLK_UNC                -from [get_clocks {grid_clk}]   -to [get_clocks {grid_clk}]
    set_clock_uncertainty -setup [expr ($GRID_CLK_UNC * 0.5)] -from [get_clocks {grid_clk}]   -to [get_clocks {virtual_grid_clk}]
    set_clock_uncertainty -setup [expr ($GRID_CLK_UNC * 0.5)] -from [get_clocks {virtual_grid_clk}] -to [get_clocks {grid_clk}]
    set_clock_uncertainty -setup 0                            -from [get_clocks {virtual_grid_clk}] -to [get_clocks {virtual_grid_clk}]
    set_clock_uncertainty -setup $GRID_CLK_UNC                -from [get_clocks {grid_east_*_clk}]   -to [get_clocks {grid_east_*_clk}]
    set_clock_uncertainty -setup [expr ($GRID_CLK_UNC * 0.5)] -from [get_clocks {grid_east_*_clk}]   -to [get_clocks {virtual_grid_east_*_clk}]
    set_clock_uncertainty -setup [expr ($GRID_CLK_UNC * 0.5)] -from [get_clocks {virtual_grid_east_*_clk}] -to [get_clocks {grid_east_*_clk}]
    set_clock_uncertainty -setup 0                            -from [get_clocks {virtual_grid_east_*_clk}] -to [get_clocks {virtual_grid_east_*_clk}]
    set_clock_uncertainty -setup $APB_CLK_UNC                 -from [get_clocks {virtual_apb_clk}] -to [get_clocks {virtual_apb_clk}]
    set_clock_uncertainty -hold  $HOLD_UNCERTAINTY [all_clocks]
#}
    # 
    ## Clock Groups
    # 
set_clock_groups -name MAIN1_CLK -asynchronous -group {grid_clk virtual_grid_clk grid_east_*_clk virtual_grid_east_*_clk} -group {virtual_apb_clk}
set_clock_groups -name MAIN_EAST_CLK -asynchronous -group {grid_clk virtual_grid_clk} \
                                                   -group {grid_east_0_clk virtual_grid_east_0_clk} -group {grid_east_1_clk virtual_grid_east_1_clk} \
                                                   -group {grid_east_2_clk virtual_grid_east_2_clk} -group {grid_east_3_clk virtual_grid_east_3_clk} -allow_path
if {!$fc} {
set_clock_groups -name edt_clock_async -async -group [get_clocks -quiet {TEST__EDT_CLOCK virtual_TEST__EDT_CLOCK} ]
set_clock_groups -name dft_clock_async -async -group [get_clocks -quiet {TEST__DFT_CLK virtual_TEST__DFT_CLK} ]
set_clock_groups -name tessent_tck_1   -async -group [get_clocks -quiet {tessent_bisr_clock_TEST__BISR_CLK virtual_TEST__BISR_CLK} ]
}

# Async reset signals
#
set_multicycle_path 10 -setup -from [get_ports grid_rst_n_sf_from_east] -start
set_multicycle_path 9 -hold  -from [get_ports grid_rst_n_sf_from_east] -start

# Tie Signals 
#
set_multicycle_path 10 -setup -from [get_ports strap_*] -start
set_multicycle_path 9 -hold  -from [get_ports strap_*] -start

# set functional mode
# set functional mode iddq & scan_en

set_case_analysis 0 [get_ports "dft_rst_n_override*"]
if {[sizeof_collection [get_ports -quiet *shift_en]] > 0} {
  set_case_analysis 0 [get_ports {*shift_en}]
}



# Yigal - TODO: check for read after write. add bypass flops on memories that are failing.
set_disable_timing -from rclk -to wclk   [get_cells -hier -filter "ref_name=~M5SRF211* && ref_name != M5SRF211HC128X89RR00121VT3525G6BSICH20OLA"]
set_disable_timing -from wclk -to rclk   [get_cells -hier -filter "ref_name=~M5SRF211* && ref_name != M5SRF211HC128X89RR00121VT3525G6BSICH20OLA"]
#M5SRF211HC512X78RR10221VT3525G6BSICW1H20OLA
#M5SRF211HC512X22RR10211VT3525G6BSICH20OLA
#M5SRF211HC128X141RR00121VT3525G6BSICH20OLA
#M5SRF211HC128X77RR00121VT3525G6BSICH20OLA
#M5SRF211HC256X97RR00221VT3525G6BSICH20OLA
#M5SRF211HC128X89RR00121VT3525G6BSICH20OLA - estimated lib

##### from cbui.sdc #####
# TODO - is there any Async Fifo? if yes add constraints
# set max delay to constrain the async paths in nxt_async_fifo
# get_data has two cycles to propagate. i set it to 1.5cycles.
# optimize the path at the output of the 2FF/3FF synchronizer in the async fifo in order to increase the settling time. 

######################
# from lcb.sdc
#
# configuration registers. ready and stable long ago before in use.
# Total - xxxx
# leu_cfg - 8489
# fcb_cfg - 2232
# xbar_cfg - 2304
# Rs_cfg   - 2076
# TODO: add also leb_imm_cfg - 0
set lcb_leu_csr "i_cbui${s}i_lcb*${s}i_lcb_unit${s}i_lcb_core${s}*_top${s}i_leu_csr*"
set leu_csr_cfg [get_pins -quiet "${INST_NAME}${lcb_leu_csr}${s}*cfg_*_reg*/q*"]
set lcb_csr "i_cbui${s}i_lcb*${s}i_lcb_csr"
set lcb_csr_cfg [add_to_collection $leu_csr_cfg [get_pins -quiet "${INST_NAME}${lcb_csr}${s}cfg_*_reg*/q*"]]
set fcb_csr "i_cbui${s}i_fcb*${s}i_fcb_core${s}i_fcb_csr"
set fcb_csr_cfg [get_pins -quiet "${INST_NAME}${fcb_csr}${s}*cfg_*_reg*/q*"]
set csr_cfg [add_to_collection $lcb_csr_cfg $fcb_csr_cfg]
set xbar_csr "i_cbui${s}i_cbui_xbar_wrap${s}i_cbui_xbar_csr"
set xbar_csr_cfg [get_pins -quiet "${INST_NAME}${xbar_csr}${s}*cfg_*_reg*/q*"]
set csr_cfg [add_to_collection $csr_cfg $xbar_csr_cfg]

set lcb_rs_csr "i_cbui${s}i_lcb?${s}i_lcb_unit${s}i_rs${s}i_rs_csr"
set lcb_rs_csr_cfg [get_pins -quiet  "${INST_NAME}${lcb_rs_csr}${s}*cfg_*_reg*/q*"]
#set lcb_rs_csr_cfg [add_to_collection $lcb_rs_csr_cfg [get_pins -quiet  "${INST_NAME}${lcb_rs_csr}${s}*rf_conf_reg*/q*"]]
set fcb_rs_csr "i_cbui${s}i_fcb?${s}i_rs${s}i_rs_csr"
set fcb_rs_csr_cfg [get_pins -quiet  "${INST_NAME}${fcb_rs_csr}${s}*cfg_*_reg*/q*"]
#set fcb_rs_csr_cfg [add_to_collection $fcb_rs_csr_cfg [get_pins -quiet  "${INST_NAME}${fcb_rs_csr}${s}*rf_conf_reg*/q*"]]
set rs_csr_cfg [add_to_collection $lcb_rs_csr_cfg $fcb_rs_csr_cfg]
set csr_cfg [add_to_collection $csr_cfg $rs_csr_cfg]

set big_rs_csr "i_cbui${s}i_big_rs${s}i_big_rs_csr"
set big_rs_csr_cfg [get_pins -quiet  "${INST_NAME}${big_rs_csr}${s}cfg_*_reg*/q*"]
set csr_cfg [add_to_collection $csr_cfg $big_rs_csr_cfg]

set cbu_grid_clk [get_clocks {grid_clk}]
set_multicycle_path 3 -setup -from $cbu_grid_clk -through $csr_cfg -to $cbu_grid_clk
set_multicycle_path 2 -hold  -from $cbu_grid_clk -through $csr_cfg -to $cbu_grid_clk
puts [format "%-20s %-20s" "# lcb - leu_csr cfg registers (8489 per lcb): " "[sizeof_collection $lcb_csr_cfg]"]
puts [format "%-20s %-20s" "# fcb - fcb_csr cfg registers (1116 per fcb): " "[sizeof_collection $fcb_csr_cfg]"]
puts [format "%-20s %-20s" "# cbui_xbar - cbui_xbar cfg registers (2304): " "[sizeof_collection $xbar_csr_cfg]"]
puts [format "%-20s %-20s" "# cbui_rs - cbui_rs cfg registers (155 per lcb or fcb): " "[sizeof_collection $rs_csr_cfg]"]
puts [format "%-20s %-20s" "# cbui_big_rs - cbui_big_rs cfg registers (573 per big_rs): " "[sizeof_collection $big_rs_csr_cfg]"]
puts [format "%-20s %-20s" "# cbui_top - cbui_top total cfg registers: " "[sizeof_collection $csr_cfg]"]
puts [format "%-20s %-20s" "# cbui_top - cbui_top total unique cfg registers: " "[sizeof_collection [get_pins [lsort -unique [get_object_name $csr_cfg]]]]"]
##############

##### from cbue.sdc #####
######################
# from lcb.sdc
#
# configuration registers. ready and stable long ago before in use.
# Total - xxxx
# leu_cfg - 25467
# fcb_cfg - 1116
# xbar_cfg - 2688
# mep      - 506
# cbue_rs  - 2050
# TODO: add also leb_imm_cfg - 0
set lcb_leu_csr "i_cbue${s}i_lcb*${s}i_lcb_unit${s}i_lcb_core${s}*_top${s}i_leu_csr*"
set leu_csr_cfg [get_pins -quiet "${INST_NAME}${lcb_leu_csr}${s}*cfg_*_reg*/q*"]
set lcb_csr "i_cbue${s}i_lcb*${s}i_lcb_csr"
set lcb_csr_cfg [add_to_collection $leu_csr_cfg [get_pins -quiet "${INST_NAME}${lcb_csr}${s}cfg_*_reg*/q*"]]
set fcb_csr "i_cbue${s}i_fcb*${s}i_fcb_core${s}i_fcb_csr"
set fcb_csr_cfg [get_pins -quiet "${INST_NAME}${fcb_csr}${s}*cfg_*_reg*/q*"]
set csr_cfg [add_to_collection $lcb_csr_cfg $fcb_csr_cfg]
set xbar_csr "i_cbue${s}i_cbue_xbar_wrap${s}i_cbue_xbar_csr"
set xbar_csr_cfg [get_pins -quiet "${INST_NAME}${xbar_csr}${s}*cfg_*_reg*/q*"]
set csr_cfg [add_to_collection $csr_cfg $xbar_csr_cfg]
set mep_csr "i_cbue${s}i_mep?${s}g_core_?_i_mep_core${s}i_mep_core_csr"
set mep_csr_cfg [get_pins -quiet "${INST_NAME}${mep_csr}${s}*cfg_*_reg*/q*"]
set csr_cfg [add_to_collection $csr_cfg $mep_csr_cfg]
set mep_comp_csr "i_cbue${s}i_mep?${s}mep_complex_csr"
set mep_comp_csr_cfg [get_pins -quiet "${INST_NAME}${mep_comp_csr}${s}*cfg_*_reg*/q*"]
set csr_cfg [add_to_collection $csr_cfg $mep_comp_csr_cfg]
#set mep_core_csr "i_cbue${s}i_mep?${s}g_core*mep_core_csr"
#set mep_core_csr_cfg [get_pins -quiet "${INST_NAME}${mep_core_csr}${s}*cfg_*_reg*/q*"]
#set csr_cfg [add_to_collection $csr_cfg $mep_core_csr_cfg]

set lcb_rs_csr "i_cbue${s}i_lcb?${s}i_lcb_unit${s}i_rs${s}i_rs_csr"
set lcb_rs_csr_cfg [get_pins -quiet  "${INST_NAME}${lcb_rs_csr}${s}*cfg_*_reg*/q*"]
#set lcb_rs_csr_cfg [add_to_collection $lcb_rs_csr_cfg [get_pins -quiet  "${INST_NAME}${lcb_rs_csr}${s}*rf_conf_reg*/q*"]]
set fcb_rs_csr "i_cbue${s}i_fcb?${s}i_rs${s}i_rs_csr"
set fcb_rs_csr_cfg [get_pins -quiet  "${INST_NAME}${fcb_rs_csr}${s}*cfg_*_reg*/q*"]
#set fcb_rs_csr_cfg [add_to_collection $fcb_rs_csr_cfg [get_pins -quiet  "${INST_NAME}${fcb_rs_csr}${s}*rf_conf_reg*/q*"]]
set rs_csr_cfg [add_to_collection $lcb_rs_csr_cfg $fcb_rs_csr_cfg]
set csr_cfg [add_to_collection $csr_cfg $rs_csr_cfg]

#set rs_csr "i_cbue${s}*${s}*${s}*${s}i_rs_csr"
#set rs_csr_cfg [get_pins -quiet "${INST_NAME}${rs_csr}${s}*rf_conf_reg*/q*"]
#set rs_csr "i_cbue${s}*${s}*${s}*rs_csr"
#set rs_csr_cfg [add_to_collection $rs_csr_cfg [get_pins -quiet "${INST_NAME}${rs_csr}${s}*rf_conf_reg*/q*"]]
#set rs_csr_cfg [add_to_collection $rs_csr_cfg [get_pins -quiet "${INST_NAME}${rs_csr}${s}*cfg*_reg*/q*"]]
#set csr_cfg [add_to_collection $csr_cfg [get_pins [lsort -unique [get_object_name $rs_csr_cfg]]]]

set cbu_grid_clk [get_clocks {grid_clk}]
set_multicycle_path 3 -setup -from $cbu_grid_clk -through $csr_cfg -to $cbu_grid_clk
set_multicycle_path 2 -hold  -from $cbu_grid_clk -through $csr_cfg -to $cbu_grid_clk
puts [format "%-20s %-20s" "# lcb - leu_csr cfg registers (8489 per lcb): " "[sizeof_collection $lcb_csr_cfg]"]
puts [format "%-20s %-20s" "# fcb - fcb_csr cfg registers (1116 per fcb): " "[sizeof_collection $fcb_csr_cfg]"]
puts [format "%-20s %-20s" "# cbue_xbar - cbue_xbar cfg registers (2688): " "[sizeof_collection $xbar_csr_cfg]"]
puts [format "%-20s %-20s" "# mep - mep cfg registers (2224 per mep): " "[sizeof_collection $mep_csr_cfg]"]
puts [format "%-20s %-20s" "# mep - mep comp cfg registers (506 per mep): " "[sizeof_collection $mep_comp_csr_cfg]"]
puts [format "%-20s %-20s" "# cbue_rs - cbue_rs cfg registers (155 per lcb or fcb): " "[sizeof_collection $rs_csr_cfg]"]
puts [format "%-20s %-20s" "# cbue_top - cbue_top total cfg registers: " "[sizeof_collection $csr_cfg]"]
puts [format "%-20s %-20s" "# cbue_top - cbue_top total unique cfg registers: " "[sizeof_collection [get_pins [lsort -unique [get_object_name $csr_cfg]]]]"]


#### TEMP!! inorder to fix mapcont
# TODO: Yigal: need to fix since it doesnt work for flat netlist
##set mapcont_pins [get_pins -hier -filter "full_name =~ *i_mep*g_core_*_i_mep_core*i_mep_vala*i_mep_mapcont*"]
##set_multicycle_path 2 -setup  -through  $mapcont_pins 
##set_multicycle_path 1 -hold   -through  $mapcont_pins 
##############

 
##### from nfi_mcu.sdc #####

puts "-I- Starting to add private MCPs"

set grid_clk [get_clocks grid_clk]

# CFG bit / semi-static
puts "<HN> mcp_2_group      \[get_pins i_nfi_mcu${s}i_nfi_aon${s}i_nfi_csr${s}*cfg_nfi_periph_*_reg*/q*\]"
set           mcp_2_group    [get_pins ${INST_NAME}i_nfi_mcu${s}i_nfi_aon${s}i_nfi_csr${s}*cfg_nfi_periph_*_reg*/q*]
# BIN Write to DMEM 
puts "<HN> mcp_2_group      \[get_pins i_nfi_mcu${s}i_mcu${s}i_mcu_squad${s}i_bin_complex${s}g_bin_*_i_bin${s}i_dmem_*${s}i_sram${s}i_bank_*${s}ebb__mcu_bin_dmem_1rw_2048x137_i/add\[*\]\]"
append_to_col mcp_2_group    [get_pins ${INST_NAME}i_nfi_mcu${s}i_mcu${s}i_mcu_squad${s}i_bin_complex${s}g_bin_*_i_bin${s}i_dmem_*${s}i_sram${s}i_bank_*${s}ebb__mcu_bin_dmem_1rw_2048x137_i/add[*]]
puts "<HN> mcp_2_group      \[get_pins i_nfi_mcu${s}i_mcu${s}i_mcu_squad${s}i_bin_complex${s}g_bin_*_i_bin${s}i_dmem_*${s}i_sram${s}i_bank_*${s}ebb__mcu_bin_dmem_1rw_2048x137_i/cs\]"
append_to_col mcp_2_group    [get_pins ${INST_NAME}i_nfi_mcu${s}i_mcu${s}i_mcu_squad${s}i_bin_complex${s}g_bin_*_i_bin${s}i_dmem_*${s}i_sram${s}i_bank_*${s}ebb__mcu_bin_dmem_1rw_2048x137_i/cs]
puts "<HN> mcp_2_group      \[get_pins i_nfi_mcu${s}i_mcu${s}i_mcu_squad${s}i_bin_complex${s}g_bin_*_i_bin${s}i_dmem_*${s}i_sram${s}i_bank_*${s}ebb__mcu_bin_dmem_1rw_2048x137_i/din\[*\]\]"
append_to_col mcp_2_group    [get_pins ${INST_NAME}i_nfi_mcu${s}i_mcu${s}i_mcu_squad${s}i_bin_complex${s}g_bin_*_i_bin${s}i_dmem_*${s}i_sram${s}i_bank_*${s}ebb__mcu_bin_dmem_1rw_2048x137_i/din[*]]
puts "<HN> mcp_2_group      \[get_pins i_nfi_mcu${s}i_mcu${s}i_mcu_squad${s}i_bin_complex${s}g_bin_*_i_bin${s}i_dmem_*${s}i_sram${s}i_bank_*${s}ebb__mcu_bin_dmem_1rw_2048x137_i/we\]"
append_to_col mcp_2_group    [get_pins ${INST_NAME}i_nfi_mcu${s}i_mcu${s}i_mcu_squad${s}i_bin_complex${s}g_bin_*_i_bin${s}i_dmem_*${s}i_sram${s}i_bank_*${s}ebb__mcu_bin_dmem_1rw_2048x137_i/we]


set_multicycle_path 2 -setup -from $grid_clk -through $mcp_2_group -to $grid_clk -comment "HN 22ww18d permanent setup mcps"
set_multicycle_path 1 -hold  -from $grid_clk -through $mcp_2_group -to $grid_clk -comment "HN 22ww18d permanent hold  mcps"


# TEST Constraints
#
if {!$fc} {

set test_mcp_pin [get_pins -quiet { */ti */te */TEST__SIN* */TEST__IN* DFT_lockup_g*/d ts_*lockup_latchn*/d ts_*lockup_latchp*/d } ]
echo "WARNING: wrapperChainLockupLatchList is not defined!"
set wrapperChainLockupLatchList {}

## ERROR: Hierarchical test file grid_quadrant.wrapper_chain_cells.tcl was not found!

puts "INFO: Using MCP of 64 for clock grid_clk. Effective test period will be 40ns"
puts "INFO: Using MCP of 64 for clock grid_east_0_clk. Effective test period will be 40ns"
puts "INFO: Using MCP of 64 for clock grid_east_1_clk. Effective test period will be 40ns"
puts "INFO: Using MCP of 64 for clock grid_east_2_clk. Effective test period will be 40ns"
puts "INFO: Using MCP of 64 for clock grid_east_3_clk. Effective test period will be 40ns"
#set_clock_groups -name edt_clock_async -async -group [get_clocks -quiet {TEST__EDT_CLOCK virtual_TEST__EDT_CLOCK} ]
#set_clock_groups -name dft_clock_async -async -group [get_clocks -quiet {TEST__DFT_CLK virtual_TEST__DFT_CLK} ]
set test_tgl_mcp_pin [get_pins -quiet { TGL_WRP_MUX__*/i1 } ]
if { [ sizeof_collection $test_tgl_mcp_pin ] > 0 } {
  set_multicycle_path -setup -end 64 -through $test_tgl_mcp_pin -to [get_clocks { grid_clk grid_east_?_clk } ]
  set_multicycle_path -hold  -end 63 -through $test_tgl_mcp_pin -to [get_clocks { grid_clk grid_east_?_clk } ]
}
set_multicycle_path -setup -end 8 -from [get_ports -quiet { TEST__SE } ]
set_false_path -hold  -from [get_ports -quiet { TEST__SE } ]

set test_mcp_output_port [get_ports -quiet { TEST__FULL_SOUT_* TEST__EDT_SINGLE_CHAIN_SOUT* TEST__EDT_OUT_* TEST__EDT_EXTEST_OUT_* TEST__EXTEST_EDT_SINGLE_CHAIN_SOUT TEST__EDT_TDR_SOUT16 TEST__BISR_SOUT}]
set test_mcp_input_port [get_ports -quiet {TEST__FULL_SIN_* TEST__CLK_GATE_DISABLE TEST__ASYNC_DISABLE TEST__CLK_GATE_DISABLE_CKGT TEST__M5SRF211HC_GLOBAL_* TEST__MEM_CLK_GATE_DISABLE TEST__MEM_GLOBAL_* TEST__MEM_OVSTB TEST__SPARE_* TEST__TDR_RST TEST__M5SP111HD_GLOBAL_* TEST__EXTEST_EDT_SINGLE_CHAIN_SIN TEST__EDT_TDR_SEL16 TEST__TDR_SHIFT TEST__TDR_CAPTURE TEST__FSM_UDR TEST__EDT_TDR_SIN16 TEST__EDT_UPDATE TEST__EDT_IN_* TEST__EDT_EXTEST_IN_* TEST__BISR_SHIFT_EN TEST__BISR_CLK TEST__BISR_RESET TEST__BISR_SIN  }]

set_multicycle_path -setup -end 64 -from $test_mcp_input_port -to [get_clocks { grid_clk grid_east_?_clk } ]
set_multicycle_path -setup -start 64 -from [get_clocks { grid_clk grid_east_?_clk } ] -to $test_mcp_output_port
set_multicycle_path -end -setup 64 -through $test_mcp_pin -to [get_clocks { grid_clk grid_east_?_clk } ]
set_multicycle_path -end -hold 63 -through $test_mcp_pin -to [get_clocks { grid_clk grid_east_?_clk } ]

if { [info exists non_wrapper_chain_cells] && [sizeof_collection $non_wrapper_chain_cells ] > 0 } {
  set_multicycle_path -end -setup 64 -from $non_wrapper_chain_cells -through $hier_test_mcp_exclude_pins -to [get_clocks { grid_clk grid_east_?_clk } ]
  set_multicycle_path -end -hold 63 -from $non_wrapper_chain_cells -through $hier_test_mcp_exclude_pins -to [get_clocks { grid_clk grid_east_?_clk } ]
}

set test_fp_hold_input_port [get_ports -quiet {TEST__FULL_SIN_* TEST__CLK_GATE_DISABLE TEST__ASYNC_DISABLE TEST__M5SRF211HC_GLOBAL_* TEST__MEM_CLK_GATE_DISABLE TEST__MEM_GLOBAL_* TEST__MEM_OVSTB TEST__SPARE_* TEST__TDR_RST TEST__M5SP111HD_GLOBAL_* TEST__EXTEST_EDT_SINGLE_CHAIN_SIN TEST__EDT_TDR_SEL16 TEST__TDR_SHIFT TEST__TDR_CAPTURE TEST__FSM_UDR TEST__EDT_TDR_SIN16 TEST__EDT_UPDATE TEST__EDT_IN_* TEST__EDT_EXTEST_IN_* TEST__BISR_SHIFT_EN TEST__BISR_CLK TEST__BISR_RESET TEST__BISR_SIN TEST__EDT_SINGLE_CHAIN_SIN* }]
set_false_path -hold -from $test_fp_hold_input_port

set test_fp_hold_output_port [get_ports -quiet { TEST__FULL_SOUT_* TEST__EDT_SINGLE_CHAIN_SOUT* TEST__EDT_OUT_* TEST__EDT_EXTEST_OUT_* TEST__EXTEST_EDT_SINGLE_CHAIN_SOUT TEST__EDT_TDR_SOUT16 TEST__BISR_SOUT}]
set_false_path -hold -to $test_fp_hold_output_port

## Specify synchronous wrapper chain lockup latches for block flow (if applicable).
  set TVAR(synchronous_wrapper_chain_lockup_latch_list) {}

}

# I/O Constraints
#
if {!$fc} {
set clk_ports {grid_clk grid_clk_from_east*}
set grid_clk_n_ports {lnb_data__?__?_c?_from_north* lnb_ready__?_c?_from_north* lnb_valid__?_c?_from_north* lnb_data__?__?_c?_to_north* lnb_valid__?_c?_to_north* lnb_ready__?_c?_to_north*} 
set grid_clk_m_ports {cbus_data__?_ef_from_north* cbus_ready_ef_from_north* cbus_valid_ef_from_north* cbus_data__?_ef_from_south* cbus_ready_ef_from_south* cbus_valid_ef_from_south* dlink_data_ef_from_north* dlink_data_ef_from_south* dlink_ready_ef_from_north dlink_valid_ef_from_north dlink_ready_ef_from_south dlink_valid_ef_from_south lnb_data__?__?_ef_from_north* lnb_ready__?_ef_from_north* lnb_valid__?_ef_from_north* nbus_data__?__?_ef_from_south* nbus_ready__?_ef_from_south* nbus_valid__?_ef_from_south* cbus_data__?_ef_to_north* cbus_data__?_ef_to_south* cbus_ready_ef_to_north* cbus_ready_ef_to_south* cbus_valid_ef_to_north* cbus_valid_ef_to_south* dlink_data_ef_to_north* dlink_data_ef_to_south* dlink_ready_ef_to_north dlink_ready_ef_to_south dlink_valid_ef_to_north dlink_valid_ef_to_south lnb_data__?__?_ef_to_north* lnb_ready__?_ef_to_north* lnb_valid__?_ef_to_north* nbus_data__?__?_ef_to_south* nbus_ready__?_ef_to_south* nbus_valid__?_ef_to_south*}
set grid_clk_s_ports {nbus_data__?__?_c?_from_south* cbus_data__?_c?_from_south* cbus_ready_c?_from_south* nbus_ready__?_c?_from_south* nbus_valid__?_c?_from_south* cbus_valid_c?_from_south* cbus_data__?_c?_to_south* nbus_data__?__?_c?_to_south* cbus_valid_c?_to_south* nbus_valid__?_c?_to_south* nbus_ready__?_c?_to_south* cbus_valid_c?_to_south* cbus_ready_c?_to_south*}
set grid_clk_w_ports {dlink_data__?_r?_from_west* dlink_ready_r?_from_west* dlink_valid_r?_from_west* dlink_data__?_r?_to_west* dlink_valid_r?_to_west* dlink_ready_r?_to_west*}
set grid_clk_w_ecore_ports {ecore_cep_lnb_pkt__?__?_r7_from_west* ecore_cep_lnb_valid__?_r7_from_west* ecore_csr_req_cbus_data_r7_from_west* ecore_csr_req_cbus_valid_r7_from_west ecore_csr_resp_cbus_data_r7_from_west* ecore_csr_resp_cbus_valid_r7_from_west ecore_lnb_cip_ready__?_r7_from_west *_cbus_ecore_csr_ready_r7_from_west *_cbus_ecore_csr_data_r7_to_west* *_cbus_ecore_csr_valid_r7_to_west}
set grid_clk_e_ports {nbus_data__?__?_r?_from_east* cbus_data__?_r?_from_east* nbus_valid__?_r?_from_east* cbus_valid_r?_from_east* nbus_ready__?_r?_to_east* cbus_ready_r?_to_east* ecore_cep_lnb_ready__?_r7_to_west* ecore_csr_*_cbus_ready_r7_to_west ecore_lnb_cip_pkt__?__?_r7_to_west* ecore_lnb_cip_valid__?_r7_to_west}
set grid_clk_e0_ports {cbus_ready_r0_from_east* cbus_ready_r1_from_east* nbus_ready__?_r0_from_east* nbus_ready__?_r1_from_east* cbus_data__?_r0_to_east* cbus_data__?_r1_to_east* cbus_valid_r0_to_east* cbus_valid_r1_to_east* nbus_data__?__?_r0_to_east* nbus_data__?__?_r1_to_east* nbus_valid__?_r0_to_east* nbus_valid__?_r1_to_east*}
set grid_clk_e1_ports {cbus_ready_r2_from_east* cbus_ready_r3_from_east* nbus_ready__?_r2_from_east* nbus_ready__?_r3_from_east* cbus_data__?_r2_to_east* cbus_data__?_r3_to_east* cbus_valid_r2_to_east* cbus_valid_r3_to_east* nbus_data__?__?_r2_to_east* nbus_data__?__?_r3_to_east* nbus_valid__?_r2_to_east* nbus_valid__?_r3_to_east*}
set grid_clk_e2_ports {cbus_ready_r4_from_east* cbus_ready_r5_from_east* nbus_ready__?_r4_from_east* nbus_ready__?_r5_from_east* cbus_data__?_r4_to_east* cbus_data__?_r5_to_east* cbus_valid_r4_to_east* cbus_valid_r5_to_east* nbus_data__?__?_r4_to_east* nbus_data__?__?_r5_to_east* nbus_valid__?_r4_to_east* nbus_valid__?_r5_to_east*}
set grid_clk_e3_ports {cbus_ready_r6_from_east* cbus_ready_r7_from_east* nbus_ready__?_r6_from_east* nbus_ready__?_r7_from_east* cbus_data__?_r6_to_east* cbus_data__?_r7_to_east* cbus_valid_r6_to_east* cbus_valid_r7_to_east* nbus_data__?__?_r6_to_east* nbus_data__?__?_r7_to_east* nbus_valid__?_r6_to_east* nbus_valid__?_r7_to_east*}
set apb_clk_ports {dft_clk_gate_en_sf_from_east dft_rst_n_override_sf_from_east grid_rst_n_sf_from_east strap_* i_remote_sensor remote_sensor_return v_remote_sensor}
#
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_n_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_n_ports -filter "direction == out"]
#
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_m_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_m_ports -filter "direction == out"]
#
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.8)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_s_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_s_ports -filter "direction == out"]
#
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.8)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_w_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_w_ports -filter "direction == out"]
#
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.8)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_w_ecore_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_w_ecore_ports -filter "direction == out"]
#
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.8)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_e_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_clk [get_ports -quiet $grid_clk_e_ports -filter "direction == out"]
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.8)] -clock virtual_grid_east_0_clk [get_ports -quiet $grid_clk_e0_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_east_0_clk [get_ports -quiet $grid_clk_e0_ports -filter "direction == out"]
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.8)] -clock virtual_grid_east_1_clk [get_ports -quiet $grid_clk_e1_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_east_1_clk [get_ports -quiet $grid_clk_e1_ports -filter "direction == out"]
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.8)] -clock virtual_grid_east_2_clk [get_ports -quiet $grid_clk_e2_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_east_2_clk [get_ports -quiet $grid_clk_e2_ports -filter "direction == out"]
set_input_delay  [expr ($GRID_CLK_PERIOD * 0.8)] -clock virtual_grid_east_3_clk [get_ports -quiet $grid_clk_e3_ports -filter "direction == in && full_name != grid_clk"]
set_output_delay [expr ($GRID_CLK_PERIOD * 0.7)] -clock virtual_grid_east_3_clk [get_ports -quiet $grid_clk_e3_ports -filter "direction == out"]
#
set_input_delay  [expr ($APB_CLK_PERIOD * 0.1)] -clock virtual_apb_clk [get_ports -quiet $apb_clk_ports -filter "direction == in"]
#set_output_delay [expr ($APB_CLK_PERIOD * 0.1)] -clock virtual_apb_clk [get_ports -quiet $apb_clk_ports -filter "direction == out"]
#


# Transition and Load
set_input_transition [expr ($GRID_CLK_PERIOD * 0.10)] [get_ports * -filter "direction == in"]
set_load 0.01 [all_outputs]
}

unset CLUSTER_NAME
unset INST_NAME






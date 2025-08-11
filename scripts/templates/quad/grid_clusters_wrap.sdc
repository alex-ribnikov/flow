if { ![info exists INST_NAME] } {
     set INST_NAME ""
     set fc 0
     set s "/"
     set ss "/"
   } else {
     set INST_NAME "${INST_NAME}/"
     set fc 1
   }

if {[info exists ::env(PROJECT)] && ${::env(PROJECT)} == "brcm5" } {
    set FF_DATA_OUT "q"
} else {
    set FF_DATA_OUT "Q"
}


# Define variable which identifies whether flow is at synopsys or cadence
set synopsys  0
if {[info exists ::synopsys_program_name]} {
    set synopsys 1
}

# clocks_parameters.sdc
# created by Yigal on Jun 2021

# Clocks parameters 
#
set GRID_CLK_PERIOD 1.000
set APB_CLK_PERIOD 2
#
set GRID_CLK_UNC 0.060
set APB_CLK_UNC 0.18


if { ![info exist TEV_OP_MODE] } {
  set HOLD_UNCERTAINTY 0.015
} elseif { [info exist TEV_OP_MODE] && $TEV_OP_MODE == "FF" } {
  set HOLD_UNCERTAINTY 0.01
} else {
  set HOLD_UNCERTAINTY 0.025
}

#
set DC_SCALING 0.08
if {([info exist ::synopsys_program_name] && $::synopsys_program_name eq "dc_shell") || ([info command is_common_ui_mode] ne "" && [get_db program_short_name] eq "genus")} {
set GRID_CLK_UNC     [expr ($GRID_CLK_UNC     + ($DC_SCALING * $GRID_CLK_PERIOD))]
set APB_CLK_UNC      [expr ($APB_CLK_UNC      + ($DC_SCALING * $APB_CLK_PERIOD))]
}

# Clocks defintions 
#
create_clock -period $GRID_CLK_PERIOD     -name grid_clk [get_ports grid_clk]
# Virtual Clocks
create_clock -period $GRID_CLK_PERIOD     -name virtual_grid_clk
create_clock -period $APB_CLK_PERIOD      -name virtual_apb_clk



# Uncertainty
#
set_clock_uncertainty -setup $GRID_CLK_UNC                -from [get_clocks {grid_clk}]   -to [get_clocks {grid_clk}]
set_clock_uncertainty -setup [expr ($GRID_CLK_UNC * 0.5)] -from [get_clocks {grid_clk}]   -to [get_clocks {virtual_grid_clk}]
set_clock_uncertainty -setup [expr ($GRID_CLK_UNC * 0.5)] -from [get_clocks {virtual_grid_clk}] -to [get_clocks {grid_clk}]
set_clock_uncertainty -setup 0                            -from [get_clocks {virtual_grid_clk}] -to [get_clocks {virtual_grid_clk}]
set_clock_uncertainty -setup $APB_CLK_UNC                 -from [get_clocks {virtual_apb_clk}] -to [get_clocks {virtual_apb_clk}]
set_clock_uncertainty -hold  $HOLD_UNCERTAINTY [all_clocks]

if {[info exists STAGE] && ($STAGE == "syn" || $STAGE == "place")} {
    set_clock_latency 0.06 [get_pins -of_objects [get_cells -hier -filter "ref_name=~*RR10221VT3525G6EBCH20LA*"] -filter {full_name =~ */CKA}]
    
}




set_clock_groups -name MAIN1_CLK -asynchronous -group {grid_clk virtual_grid_clk} -group {virtual_apb_clk}

### TMP False path dlink paths between 3-4 rows
set_false_path -from i_cluster_r3_c*/*dlink* -to   i_cluster_r4_c*/*dlink* 
set_false_path -to   i_cluster_r3_c*/*dlink* -from i_cluster_r4_c*/*dlink*


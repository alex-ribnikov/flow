#################################################################################
# Synopsys Auto Setup Mode
#################################################################################
history keep 250

set_app_var synopsys_auto_setup true

# The Synopsys Auto Setup mode sets undriven signals in the reference design to
# "0" or "BINARY" (as done by DC), and the undriven signals in the impl design are
# forced to "BINARY".  This is done with the following setting:
	# set_app_var verification_set_undriven_signals synthesis

# Uncomment the next line to revert back to the more conservative default setting:
# 31/12/2023 Royl :  should fail on ALL un driven 

#if {[info exists FM_MODE] && $FM_MODE == "rtl2syn"} {
#	set_app_var verification_set_undriven_signals SYNTHESIS
#} else {
#}
	set_app_var verification_set_undriven_signals BINARY:X

set_app_var verification_failing_point_limit 100

set verification_blackbox_match_mode Identity
set verification_verify_unread_tech_cell_pins true
set verification_constant_prop_mode top
set verification_clock_gate_hold_mode collapse_all_cg_cells
set fm_clock_gate_new_solution true
## From Solvnet: Designs have a clock gating latch that drive black box inputs or primary outputs
set verification_clock_gate_edge_analysis true
set verification_assume_reg_init Auto
set verification_constant_prop_mode auto

set_app_var  dpx_keep_workers_alive  false

#set_app_var  dpx_verification_strategies {none o3 s8 l2 s2}

catch {set FC_SHELL [sh which fc_shell]}

if {[info exists FC_SHELL]} {
	regsub "/bin/fc_shell" ${FC_SHELL} "" FC_DWROOT
	set hdlin_dwroot $FC_DWROOT
} else {
	set hdlin_dwroot /tools/snps/fusioncompiler/V-2023.12-SP5-5
}

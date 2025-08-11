if {[info exists CTL_FILE_LIST] && $CTL_FILE_LIST != "" } {
   foreach CTL_FILE $CTL_FILE_LIST {
   	if {[llength [get_db insts -if ".base_cell== [regsub {.ctl} [lindex [split $CTL_FILE "/"] end] ""]"]] > 0} {
		puts "-I- reading ctl file for block [regsub {.ctl} [lindex [split $CTL_FILE "/"] end] ""]"
		read_dft_abstract_model -ctl $CTL_FILE -use_scan_structures_shift_enable_only
   	}
   }
}

if {[info exists SCAN_ABSTRUCT] &&  $SCAN_ABSTRUCT != "" } {
   foreach SCAN_ABSTRUCT_file $SCAN_ABSTRUCT {
   	read_dft_abstract_model $SCAN_ABSTRUCT_file
   }
}
set num_of_scan_chain 400

if {[sizeof_collection [get_ports -quiet dft_scan_en]] == 0} {create_port_bus -name dft_scan_en -input}
if {[sizeof_collection [get_ports -quiet shift_en]] == 0} {create_port_bus -name shift_en -input}


for {set i 0} {$i<$num_of_scan_chain} {incr i} {
  create_port_bus -name DFT_sdi_$i -input
  create_port_bus -name DFT_sdo_$i -output
}

define_shift_enable -name shift_en -active high shift_en
define_test_signal -active high -name dft_scan_en -function test_mode dft_scan_en
define_test_clock -name shift_clk -period 100 grid_clk

set_db [current_design] .lp_clock_gating_test_signal dft_scan_en
for {set i 0} {$i<$num_of_scan_chain} {incr i} {
  define_scan_chain -name scan_chain_$i -shift_enable shift_en -sdi DFT_sdi_$i -sdo DFT_sdo_$i
}

check_dft_rules > reports/dft/check_dft_rules_pre.rpt
fix_dft_violations -clock -test_control dft_scan_en
fix_dft_violations -async_reset -async_set -test_control dft_scan_en
check_dft_rules > reports/dft/check_dft_rules_post.rpt

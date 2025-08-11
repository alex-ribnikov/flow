
set DFT_staVariables_FILE  ${DFT_COLLATERALS}/${DESIGN_NAME}.staVariables.tcl 
if {[file exists ${DFT_COLLATERALS}/${DESIGN_NAME}.wrapper_chain_cells.tcl]} {
	puts "-I- sourcing DFT wrapper_chain_cells tcl file"
	source -e -v ${DFT_COLLATERALS}/${DESIGN_NAME}.wrapper_chain_cells.tcl
}
if {[file exists ${DFT_COLLATERALS}/${DESIGN_NAME}.staVariables.tcl]} {
	puts "-I- sourcing DFT staVariables tcl file"
 	source -v -e  ${DFT_COLLATERALS}/${DESIGN_NAME}.staVariables.tcl
}



set TEST__DFT_CLK_period   20
set TEST__BISR_CLK_period  20
set TEST__EDT_CLOCK_period 20



create_clock [get_ports TEST__DFT_CLK]  \
  -period $TEST__DFT_CLK_period \
  -name TEST__DFT_CLK -add

create_clock   \
  -period $TEST__DFT_CLK_period \
  -name virtual_TEST__DFT_CLK 

set_clock_groups -asynchronous -name TEST__DFT_CLKS  -group [get_clocks *TEST__DFT_CLK] 

set bisr_clk [get_ports  -quiet TEST__BISR_CLK ]

if { [sizeof_collection $bisr_clk] } {
 	create_clock [get_ports TEST__BISR_CLK]  \
  		-period $TEST__BISR_CLK_period \
  		-name TEST__BISR_CLK -add

 	create_clock   \
  		-period $TEST__BISR_CLK_period \
  		-name virtual_TEST__BISR_CLK 

   	set_clock_groups -asynchronous -name TEST__BISR_CLKS -group [get_clocks *TEST__BISR_CLK] 

  	set_input_delay  [expr 0.25 * $TEST__BISR_CLK_period] -clock [get_clocks virtual_TEST__BISR_CLK]  [get_ports TEST__BISR_SIN*] -clock_fall
  	set_output_delay [expr 0.25 * $TEST__BISR_CLK_period] -clock [get_clocks virtual_TEST__BISR_CLK]  [get_ports TEST__BISR_SOUT*]
  	set_input_delay  [expr 0.25 * $TEST__BISR_CLK_period] -clock [get_clocks virtual_TEST__BISR_CLK]  [get_ports TEST__BISR_SHIFT_EN] -clock_fall
  	set_input_delay  [expr 0.25 * $TEST__BISR_CLK_period] -clock [get_clocks virtual_TEST__BISR_CLK]  [get_ports TEST__BISR_RESET] -clock_fall

  	set_input_delay  [expr 0.25 * $TEST__BISR_CLK_period] -clock [get_clocks virtual_TEST__BISR_CLK]  [get_ports TEST__MEM_BSI*] -clock_fall
}
 
 
set edt_clk [get_ports  -quiet TEST__EDT_CLOCK ]

if { [sizeof_collection $edt_clk] } {

 	create_clock [get_ports TEST__EDT_CLOCK] \
  		-period $TEST__EDT_CLOCK_period -add \
  		-name TEST__EDT_CLOCK

 	create_clock \
  		-period $TEST__EDT_CLOCK_period \
  		-name virtual_TEST__EDT_CLOCK


   	set_clock_groups -asynchronous -name TEST_EDT_CLOCKS -group [get_clocks *TEST__EDT_CLOCK] 

  	set_input_delay  [expr 0.25 * $TEST__EDT_CLOCK_period]  -add -clock [get_clocks virtual_TEST__EDT_CLOCK] [get_ports TEST__EDT_TDR_SIN*]
  	set_output_delay [expr 0.25 * $TEST__EDT_CLOCK_period]  -add -clock [get_clocks virtual_TEST__EDT_CLOCK] [get_ports TEST__EDT_TDR_SOUT*]

} 

set_false_path -from [get_ports TEST__TDR_RST] 
set_input_delay  [expr 0.25 * $TEST__DFT_CLK_period] -clock [get_clocks virtual_TEST__DFT_CLK] [get_ports TEST__TDR_CAPTURE]  -clock_fall
set_input_delay  [expr 0.25 * $TEST__DFT_CLK_period] -clock [get_clocks virtual_TEST__DFT_CLK] [get_ports TEST__TDR_SHIFT]  -clock_fall
set_input_delay  [expr 0.25 * $TEST__DFT_CLK_period] -clock [get_clocks virtual_TEST__DFT_CLK] [get_ports TEST__TDR_UPDATE_P] 
set_input_delay  [expr 0.25 * $TEST__DFT_CLK_period] -clock [get_clocks virtual_TEST__DFT_CLK] [get_ports TEST__EDT_TDR_SEL]  -clock_fall
set_input_delay  [expr 0.25 * $TEST__DFT_CLK_period] -clock [get_clocks virtual_TEST__DFT_CLK] [get_ports TEST__EDT_TDR_SIN*]  -clock_fall
set_output_delay [expr 0.25 * $TEST__DFT_CLK_period] -clock [get_clocks virtual_TEST__DFT_CLK] [get_ports TEST__EDT_TDR_SOUT*] 


set_multicycle_path -setup 2  -from [get_ports TEST__EDT_TDR_SEL] 
set_multicycle_path -hold  1  -from [get_ports TEST__EDT_TDR_SEL] 

  


if {[info exists flops2excludeFromShiftMCP] && $flops2excludeFromShiftMCP !=""} {
 	set mcp_include_pins [remove_from_collection [get_pins -hier *reg*/ti] [get_pins $flops2excludeFromShiftMCP]]
} else {
	set mcp_include_pins [get_pins -hier -quiet *reg*/ti]
}
if { [sizeof_collection $mcp_include_pins] } {
    puts "-I- adding MCP for ti pins ([sizeof_collection $mcp_include_pins] pins found)"
    set_multicycle_path 15 -setup  -to $mcp_include_pins -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -start
    set_multicycle_path 14 -hold   -to $mcp_include_pins -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -start
}

set mcp_include_pins [get_pins -hier -quiet */TEST__SIN*]

if { [sizeof_collection $mcp_include_pins] } {
    puts "-I- adding MCP for SI pins ([sizeof_collection $mcp_include_pins] pins found)"
    set_multicycle_path 15 -setup  -to $mcp_include_pins -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -start
    set_multicycle_path 14 -hold   -to $mcp_include_pins -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -start
}

set mcp_include_pins [get_pins -hier -quiet */TEST__SO*]

if { [sizeof_collection $mcp_include_pins] } {
    puts "-I- adding MCP for SO pins ([sizeof_collection $mcp_include_pins] pins found)"
    set_multicycle_path 15 -setup  -through $mcp_include_pins -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -start 
    set_multicycle_path 14 -hold   -through $mcp_include_pins -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -start
}

set mcp_include_pins [get_pins -quiet -of_object [get_cells -hier -quiet -filter "ref_name=~M3*"] -filter "name=~si*"]

if { [sizeof_collection $mcp_include_pins] } {
    puts "-I- adding MCP for si* pins ([sizeof_collection $mcp_include_pins] pins found)"
    set_multicycle_path 15 -setup  -to $mcp_include_pins -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -start
    set_multicycle_path 14 -hold   -to $mcp_include_pins -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -start
}



set_multicycle_path 15 -setup -to   [remove_from_collection [all_clocks] [get_clocks *TEST*]] -from [get_ports *TEST* -filter "direction==in"] -end
set_multicycle_path 14 -hold  -to   [remove_from_collection [all_clocks] [get_clocks *TEST*]] -from [get_ports *TEST* -filter "direction==in"] -end

set_multicycle_path 15 -setup -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -to   [get_ports *TEST* -filter "direction==out"] -start
set_multicycle_path 14 -hold  -from [remove_from_collection [all_clocks] [get_clocks *TEST*]] -to   [get_ports *TEST* -filter "direction==out"] -start




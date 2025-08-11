# group path
#------------------------------------------------------------------------------
puts "-I- Grouping Paths"

set_interactive_constraint_modes func

reset_path_group -all
set all_blocks_pins [get_pins -of [get_db [ all_registers ] -if .is_macro==true] -filter full_name!~*TEST*&&name!~grid_clk*]
set all_filler_pins [get_pins -of [get_db [ all_registers ] -if .is_macro==true&.name==*filler*&] -filter full_name!~*TEST*&&name!~grid_clk*]
set all_TEST_pins   [get_pins -of [filter_collection [ all_registers ] full_name=~*TEST*||full_name=~*tessent*] ]
set TEST_in         [get_db [all_inputs ] -if .name==*TEST*&&.is_clock_used_as_clock!=true]
set TEST_out        [get_db [all_outputs] -if .name==*TEST*]

group_path -name grid_clock_b2b             -from grid_clk -through $all_blocks_pins -to grid_clk
group_path -name grid_clock_in2b            -from [get_db [all_inputs ] -if .name!=*TEST*&&.is_clock_used_as_clock!=true]  -through $all_filler_pins -to grid_clk
group_path -name grid_clock_b2out           -to   [get_db [all_outputs ] -if .name!=*TEST*&&.is_clock_used_as_clock!=true] -through $all_filler_pins -from grid_clk
group_path -name grid_clock_from_east_in2b  -from [get_db [all_inputs ] -if .name!=*TEST*&&.is_clock_used_as_clock!=true]  -through $all_filler_pins -to grid_east_*_clk
group_path -name grid_clock_from_east_b2out -to   [get_db [all_outputs ] -if .name!=*TEST*&&.is_clock_used_as_clock!=true] -through $all_filler_pins -from grid_east_*_clk

group_path -name test_reg2reg  -from $all_TEST_pins -to $all_TEST_pins
group_path -name test_in2reg   -from $TEST_in -through $all_TEST_pins
group_path -name test_reg2out  -through $all_TEST_pins -to $TEST_out
group_path -name test_th_pins  -through $all_TEST_pins

set_path_group_options grid_clock_b2b              -effort_level low -slack_adjustment 3.5 
set_path_group_options grid_clock_in2b             -effort_level low -slack_adjustment 3.5 
set_path_group_options grid_clock_b2out            -effort_level low -slack_adjustment 3.5 
set_path_group_options grid_clock_from_east_in2b   -effort_level low -slack_adjustment 3.5 
set_path_group_options grid_clock_from_east_b2out  -effort_level low -slack_adjustment 3.5 

set_path_group_options test_reg2reg -effort_level low
set_path_group_options test_in2reg  -effort_level low
set_path_group_options test_reg2out -effort_level low
set_path_group_options test_th_pins -effort_level low

set_interactive_constraint_modes {}   



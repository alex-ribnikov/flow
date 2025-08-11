### modified by Vlad from Ansys on December 5 2021
## Rev 1.4

import glob
workarea = '<>'

### worker configs ###


#slurm_command = '<>'
slurm_command = 'scripts/bin/rhsc_nextk8s.csh -cpu 1 -memory 25 '
#slurm_command = '/tools/common/bin/nextk8s run -cpu 1 -memory 25 -desc RH_slave -command '

big_command = '<>'

min_num_workers   = 1
num_workers_per_launch = 1
worker_multiplier = 1.0
max_num_workers   = 30

wait_for_workers =  {AnalysisView : 0.5}
# remove barrier for more parallelism, only for block level becasue it is worker consuming.
scheduler_barrier = True

### EMIR flows and metrics control ###
top_cell_name = 'DESIGN_NAME'

temperature = 105
clock_cycle =  625e-12
temperature_em = 105
temperature_em_rms = 5
scenario_duration = 10*clock_cycle	
default_input_pin_transition_time = 3e-12


### Changing defaults
options = get_default_options()
options['scenario_options'].apl_interpolation_policy='Method5'
options['scenario_options'].npv_rise_init_probability=0.6 
options['scenario_options'].multi_voltage_demand_current=True


########################
current_per_micron_bqm = None
model_details = None
avm_files = False  #False for static

keep_stats_level_static = KeepStats('Full',)
keep_stats_level_dynamic = KeepStats('Full', cycle_stats = True, current_heatmaps = False, bump_heatmaps = False , effective_dvd_in_only_use_delay_filter = True, first_event_used_for_effective_dvd = True)
step_size = 3e-12

# dvd diagnostics top amount of victims
top_victims = 5000

#please set main power supply voltage first
focus_pg_nets = ['VDD', 'VSS']
voltage_levels = {'VDD':0.83, 'VSS': 0.0}  

#BQM input
pitch = 40
via_staple_distance = 40

settings_dv = {
    'focus_pg_nets': focus_pg_nets}


settings_ev = {
    'detail_extraction_net_type': 'all',
    'calculate_spr' : True,
    'extract_temperature': temperature}

settings_tv = {
    'logic_graph': {
        'extend_subgraph_effort_level' : 'high'}}


settings_mvc = {
    'ignore_shield_nets': True}


settings_bqm = {
    'scenario_type' : 'External',
    'pvt' : {
        'voltage_levels' : voltage_levels}}



settings_swa = {'object_settings': {
    'design_values' :{
        'clock_period' :                      clock_cycle,
        'clock_pin_toggle_rate' :             2.00,
        'combinational_pin_toggle_rate' :     COMBINATIONAL_TOGGLE,
        'macro_output_pin_toggle_rate' :      MACRO_TOGGLE,
        'sequential_output_pin_toggle_rate' : SEQUENTIAL_TOGGLE,
        'primary_input_port_toggle_rate' :    IO_TOGGLE,
        'activity_precedence' : ['default_activity'],},}}



settings_pwr = {
    'pvt': {
        'voltage_levels': voltage_levels,
        'temperature' : temperature, },
    'calculation': {
        'internal': {
            'nlpm_extrapolation' : True ,
            'default_input_pin_transition_time' : default_input_pin_transition_time, 
	    'types_with_independent_nlpm':['flip_flop', 'latch', 'memory', 'combinational', 'pad', 'macro', 'unknown'],},
        'current_data_precedence': ['APL','CCSPower', 'NLPM',]}}

settings_pwr_nvp = {
    'pvt': {
        'voltage_levels': voltage_levels,
        'temperature' : temperature, },
    'calculation': {
        'internal': {
            'nlpm_extrapolation' : True ,
            'default_input_pin_transition_time' : default_input_pin_transition_time, },
        'current_data_precedence': ['APL','CCSPower', 'NLPM',]}}


pwr_calculation_settings = {
     'internal':{
         'cell_types_with_independent_nlpm':['flip_flop', 'latch', 'memory', 'combinational', 'pad', 'macro', 'unknown']}}

settings_scn_stat = {
    'scenario_type' : "Static",
    'pvt': {
        'voltage_levels': voltage_levels,
        'temperature' : temperature},
    'calculation': {
        'current_data_precedence' : ['APL','CCSPower','NLPM']}}



#settings_npv_dyn = {
#'cell_values':[{'pattern' : 'M5S*' , 'mode_control' : {'mode_sequence' : ['ACTIVE_BRCM_EMIR_WORST_F12_O100'] ,'mode_sequence_repeats': True } }]}



settings_scn_nvp_dyn = {
    'coverage_mode': True,
    'frame_length': 2*clock_cycle,
    'sta' : {'arrival_time_policy': {'clock_path_pins': 'avg', 'data_path_pins':'random'}},
    'event' : {'always_active_clocks': {'clock_instances' : True, 'sequential_instances' : True}},
    'calculation': {
        'current_data_precedence' : ['APL', 'NLPM', 'CCSPower'],},
    'object_settings': { 'cell_values' : [
        {'pattern':'M5S*','mode_control': {'mode_sequence': ['ACTIVE_BRCM_EMIR_WORST_F12_O100'],'mode_sequence_repeats': True, 'mode_change' : {'period': clock_cycle}, } }]},
    'pvt': {
        'voltage_levels' : voltage_levels}}


#    'object_settings': {'cell_values':[{'pattern' : 'M5S*' , 'mode_control' : {'mode_sequence' : ['ACTIVE_BRCM_EMIR_WORST_F12_O100'] ,'mode_sequence_repeats': True } }] },

    
settings_scn_dyn = {
    'pvt': {
        'voltage_levels' : voltage_levels,
        'temperature' : temperature},
    'calculation': {
        'net_delay_type' : 'basic',
        'macro_multi_clock_behavior' : 'fastest',
        'current_data_precedence' : ['APL', 'NLPM', 'CCSPower'],},
    'event': {
        'glitch_settings' : {
            'remove_glitches': True,
            'glitch_supress_multiplier' : 3.0},
        'toggle_non_sequential_start_points' : True,
        'enable_events_for_scan_out_pins' : True,
        'default_clock_period' : clock_cycle,
        'default_input_pin_transition_time' : default_input_pin_transition_time,},
    'sta': {
        'arrival_time_policy' : 'avg',
        'input_transition_times_for_non_sequential_start_points' : True},
    'object_settings': {
        'cell_values':[
         #   {'pattern' : 'SAS*' , 'mode_control' : {
          #      'mode_probabilities' : {'avm_read': 0.3,'avm_write' : 0.2,'standby_trig' : 0.5 } } },
           # {'pattern' : 'SAC*' , 'mode_control' : {
            #    'mode_probabilities' : {'avm_read': 0.3,'avm_write' : 0.2,'standby_trig' : 0.5 } } },
            {'pattern' : 'M5S*' , 'mode_control' : {
                'mode_sequence' : ['ACTIVE_BRCM_EMIR_WORST_F12_O100'] ,'mode_sequence_repeats': True } }],
        'design_values':{
            'toggle_rate': 0.3,
            'event_time_precedence' : {
                'clock_instance'             : ['sta', 'propagated'],
                'data_instance'              : ['propagated'],
                'sequential_launch'          : ['sta', 'propagated'],
                'non_sequential_start_point' : ['sta', 'propagated'],
                'gate_vcd_instance'          : ['propagated'],},
            'transition_time_precedence' : {
                'clock_instance'             : ['sta', 'propagated'],
                'data_instance'              : ['sta', 'propagated'],
                'sequential_launch'          : ['sta', 'propagated'],
                'non_sequential_start_point' : ['sta', 'propagated'],
                'gate_vcd_instance'          : ['sta', 'propagated'],}}}}


settings_swa_sigem = {'object_settings' :
                      {'design_values':{
                          'clock_period' :  clock_cycle,
                          'clock_pin_toggle_rate' : 2.0,
                          'combinational_pin_toggle_rate' : 1.0,
                          'macro_output_pin_toggle_rate' : 1.0,
                          'sequential_output_pin_toggle_rate' : 1.0,
                          'primary_input_port_toggle_rate' : 1.0,
                          'activity_precedence': ['default_activity'] } }}


settings_scv = {
    'default_transition_time': default_input_pin_transition_time,
    'default_toggle_rate': 2.0,
    'default_voltage': voltage_levels[focus_pg_nets[0]],
    'default_frequency': clock_cycle,
    'voltage_levels' : voltage_levels,
    'recovery_factor' : 0.8,
    'temperature' : temperature_em,
    'enable_voltage_derating' : True,
    'constant_net_overrides' :  {
        'toggle_rate': 2.0,
        'transition_time' :default_input_pin_transition_time,
        'frequency': clock_cycle,
        'voltage': voltage_levels[focus_pg_nets[0]]}}




### input data ###

tech_file_name ='/services/bespace/users/royl/deliveries/from_brcm/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_typical_apache.tech'

ploc_files = 'PLOC_FILE'
#pgarc_file_names = []

##define apl files
#apl_list = glob.glob('/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025//tsmc5ff*/apache/FF0960125/*')
#apl_list.append('/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211218/memory/int/power/apache/apl/CURRENT/*')
apl_file_names= []
#for ii in apl_list:
#  apl_file_names.append({'file_name':ii})


##define avm files
avm_config_files= None
if avm_files:
  avm_config_files= list()
  avm_list = glob.glob('<>'+'avm_cfg/*')
  for ii in avm_list:
    avm_config_files.append({'file_name':ii})

liberty_file_names= []
#liberty_file_names = glob.glob('/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_*/db/*.lib.gz*')
#liberty_file_names = liberty_file_names.append('/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211218/memory/prod/tim/etm/*.lib')

lef_files=[]

#lef_files_std = glob.glob('/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20211025/tsmc5ff_*/lef/*.*lef')
#lef_files_mem = glob.glob('/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20211218/memory/prod/lay/lef/*.lef')
#lef_files = lef_files_std + lef_files_mem
#lef_files.append('/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/cadence/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.lef')
#lef_files.append('/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_25Oct2021//TECH_5FF/cadence/var_active_17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.lef')

def_files = glob.glob('DEF_FILE')

#spef_files = [{'file_name': '<>.spef'},]
timing_window_files = [{'file_name': 'TIMING_WINDOW_FILES'}]

gpd_dirs = [{'dir_name':'GPD_DIR', 'cell_name':'DESIGN_NAME', 'selected_corners':'SELECTED_CORNERS'}]

gp_print('########################################################################')
gp_print('PD-INFO : DEF  ->',def_files)
#gp_print('PD-INFO : SPEF ->',spef_files)
gp_print('PD-INFO : GPD ->',gpd_dirs)
gp_print('PD-INFO : TWF  ->',timing_window_files)
gp_print('########################################################################')



### vector inputs ####
#vcd_start_time = ''
#vcd_end_time = ''
#vcd_duration = vcd_end_time - vcd_start_time
#vcd_profiler_interval= 10*clock_cycle
#vcd_scn_TR = ''
#
#vcd_preamble = ''
#
#vcd_file = ''
#map_file = ''
#vcd_files = [{
#    'file_name': vcd_file,
#    'preamble': vcd_preamble,
#    'time_slices':[{
#        'slice_name': 'slice1',
#        'start_time': vcd_start_time,
#        'stop_time':vcd_end_time}]}]
#
#
#namemap_file = [{
#    'file_name': map_file,
#    'delimiter' : '/',
#    'map_symbol' : ':' ,
#    'map_type' : 'rtl_to_gate',
#    'instances': '',
#    'rtl_preamble' : '',
#    'gate_preamble': ''}]
#
#
#settings_vcv = {
#    'convert_x': 'high_state',
#    'annotation_type' : 'all',
#    'namemap' : {
#        'namemap_files' : namemap_file}}
#
#
#settings_ppv = {
#    'time_interval_length': vcd_profiler_interval,
#    'pvt': {
#        'voltage_levels' : voltage_levels,
#        'temperature' : temperature},
#    'event': {
#        'infer_icg_enable_signals_from_fanin_prop': True},
#    'calculation': {
#        'internal': {
#            'accuracy': 'high',
#            'nlpm_extrapolation': True,},
#        'switching': {
#            'accuracy': 'high',
#            'transition_count': 'rise_plus_fall_div_2'},
#        'leakage': {
#            'assign_cell_leakage_to_primary_power': False,
#            'accuracy': 'high'}},
#    'object_settings': {
#        'design_values': {
#            'gate_vcd_mode' : 'tick_based',
#            'results' : {
#                'interval_based': True,
#                'save_policy' : ['supply', 'clock_domain','cell_category']},
#            'leaf_instance_results' : {
#                'interval_based': True,},
#            'event_time_precedence' : {
#                'clock_instance'             : ['sta', 'propagated'],
#                'data_instance'              : ['propagated'],
#                'sequential_launch'          : ['sta', 'propagated'],
#                'non_sequential_start_point' : ['sta', 'propagated'],
#                'gate_vcd_instance'          : ['propagated'],},
#            'transition_time_precedence' : {
#                'clock_instance'             : ['sta', 'propagated'],
#                'data_instance'              : ['sta', 'propagated'],
#                'sequential_launch'          : ['sta', 'propagated'],
#                'non_sequential_start_point' : ['sta', 'propagated'],
#                'gate_vcd_instance'          : ['sta', 'propagated'],}}}}

### created by Vlad from Ansys on Aug25/2021
## Rev 1.3
import os
set_config('gp.skip_completed_views', 1)
#set_config('micro_resiliency', 1)
include('./dynamic_inputs.py')
include('./custom_scripts.py')

default_input_pin_transition_time = 3e-12
temperature_em_rms = 5
dv_settings = {
    }
    
settings_scv = {
    'default_transition_time': default_input_pin_transition_time,
    'default_toggle_rate': 2.0,
    'default_voltage': voltage_levels[focus_pg_nets[0]],
    'default_frequency': default_period,
    'voltage_levels' : voltage_levels,
    'recovery_factor' : 0.8,
    'temperature' : pwr_temp,
    'enable_voltage_derating' : True,
    'constant_net_overrides' :  {
        'toggle_rate': 2.0,
        'transition_time' :default_input_pin_transition_time,
        'frequency': default_period,
        'voltage': voltage_levels[focus_pg_nets[0]]}}

wait_for_workers =  {AnalysisView : 0.5}
# remove barrier for more parallelism, only for block level becasue it is worker consuming.
scheduler_barrier = True


#slurm_command = '<>'
slurm_command = 'scripts/bin/rhsc_nextk8s.csh -cpu 1 -memory 25 '
#slurm_command = '/tools/common/bin/nextk8s run -cpu 1 -memory 25 -desc RH_slave -command '

big_command = '<>'

min_num_workers   = 1
num_workers_per_launch = 1
worker_multiplier = 1.0
max_num_workers   = 30



gp.open_scheduler_window()
#### Creating Launcher for Workers ####
########################################################################################################
ll = create_grid_launcher("slurm_launcher",slurm_command, num_workers_per_launch=num_workers_per_launch )
#ll = create_local_launcher('ll')
register_default_launcher(ll, max_num_workers=max_num_workers, wait_for_workers=wait_for_workers,multiplier = worker_multiplier)


options = get_default_options()
options['scenario_options'].apl_interpolation_policy = 'Method5'
options['scenario_options'].npv_rise_init_probability=0.6
options['scenario_options'].multi_voltage_demand_current = True

db = gp.open_db('./sigem_db')

reports_dir = './reports'
if not os.path.isdir(reports_dir):
    os.mkdir(reports_dir)

swa_object_settings = { 'design_values' : { 'clock_period' : default_period,
                                            'clock_pin_toggle_rate' : clock_toggle_rate,
                                            'combinational_pin_toggle_rate' : data_toggle_rate,
                                            'macro_output_pin_toggle_rate' : data_toggle_rate,
                                            'sequential_output_pin_toggle_rate' : data_toggle_rate,
                                            'activity_precedence' : ['default_activity'],
                                            'clock_precedence' : ['sta'],
                                           }
                       }
pwr_calculation_settings = {'internal':{'cell_types_with_independent_nlpm':['flip_flop', 'latch', 'memory', 'combinational', 'pad', 'macro', 'unknown']}}
include('./object_settings.py')

# View creation
lv = db.create_liberty_view(liberty_file_names = lib_files,
                            pgarc_file_names=lib_files_custom,
                            apl_file_names=apl_files,
                            tag = 'lv',options = options)

nv =db.create_tech_view(tech_file_name=tech_file,
                        tag = 'nv',options=options)

try:
    models_dir
    macro_view = db.create_macro_view(model_details=models_dir,
                                      tag='macro_view',options=options)

    dv0 = db.create_design_view(def_files=def_files,
                                lef_files=lef_files,
                                lib_views=lv,
                                top_cell_name = block_name,
                                settings = dv_settings,
                                design_ecos = design_ecos,
                                rename_pg_nets = rename_pg_nets,
                                focus_pg_nets = focus_pg_nets,
                                macro_views = [macro_view],
                                tag= 'dv0',options=options)
except NameError:
    dv0 = db.create_design_view(def_files=def_files,
                                lef_files=lef_files,
                                lib_views=lv,
                                top_cell_name = block_name,
                                settings = dv_settings,
                                design_ecos = design_ecos,
                                rename_pg_nets = rename_pg_nets,
                                focus_pg_nets = focus_pg_nets,
                                tag= 'dv0',options=options)

dv = db.create_modified_design_view(dv0,
                                    eco_commands=package.parse_ploc_func(th_ploc),
                                    tag='dv')
try:
    sdc_files
    tv = db.create_timing_view(dv,
                               timing_window_files=tw_files,
                               sdc_files=sdc_files,
                               tag = 'tv',options=options)
except NameError:
    tv = db.create_timing_view(dv,
                               timing_window_files=tw_files,
                               tag = 'tv',options=options)


ev = db.create_extract_view(dv,
                            tech_view=nv,
                            temperature=extract_temp,
                            tag = 'ev',options=options, mode='signal',
                            calculate_spr=True)


evx =db.create_extract_view_from_files(dv,
                                       gpd_dirs = gpd_dirs,
                                       tag='evx',options=options)

sv_sigem = db.create_simulation_view(ev,
                                       tag = 'sv_dynamic',options=options,
                                       enable_reduction=False, sim_type = 'sigem')
				       
				       
#sv_sigem = db.create_simulation_view(extract_view = ev, options=options, tag = "sv_sigem", sim_type = 'sigem' )
swa_sigem = db.create_switching_activity_view(timing_view=tv,
                                        object_settings=swa_object_settings,
                                        tag='swa',options=options)
#swa_sigem = db.create_switching_activity_view(timing_view = tv, options=options, tag = "swa_sigem", settings = settings_swa_sigem, )


scv = db.create_signal_net_current_view(simulation_view = sv_sigem, switching_activity_view = swa_sigem, timing_view = tv, external_parasitics = evx, options = options,  tag = 'scv', settings = settings_scv,)
sigem_dc = db.create_electromigration_view(analysis_view = scv, tag = 'sigem_dc', options = options, settings = {'mode': 'DC','temperature_em' : pwr_temp,})
sigem_peak = db.create_electromigration_view(analysis_view = scv, tag = 'sigem_peak', options = options, settings = {'mode': 'PEAK','temperature_em' : pwr_temp,})
sigem_rms = db.create_electromigration_view(analysis_view = scv, tag = 'sigem_rms', options = options, settings = {'mode': 'RMS','temperature_em' : pwr_temp, 'delta_t_rms': temperature_em_rms})


### sigEM reports ###
emir_reports.write_sigem_dirty_net_report(scv, output_file = './reports/dirty_nets.rpt')
emir_reports.write_sigem_dropped_net_report(scv, output_file = './reports/dropped_nets.rpt')
emir_reports.write_sigem_net_attributes(scv, output_file = './reports/sigem_net_attributes.rpt.gz')
emir_reports.write_sigem_open_report(scv, output_file = './reports/open_nets.rpt')
emir_reports.write_em_metal_report(sigem_dc, output_file = './reports/dc_metal_em.rpt', max_lines = 1000, em_range = 80.0)
emir_reports.write_em_via_report(sigem_dc, output_file = './reports/dc_via_em.rpt', max_lines = 1000, em_range = 80.0)
emir_reports.write_em_metal_report(sigem_rms, output_file = './reports/rms_metal_em.rpt', max_lines = 1000, em_range = 80.0)
emir_reports.write_em_via_report(sigem_rms, output_file = './reports/rms_via_em.rpt', max_lines = 1000, em_range = 80.0)
emir_reports.write_em_metal_report(sigem_peak, output_file = './reports/peak_metal_em.rpt', max_lines = 1000, em_range = 80.0)
emir_reports.write_em_via_report(sigem_peak, output_file = './reports/peak_via_em.rpt', max_lines = 1000, em_range = 80.0)
gen_em_hist(sigem_rms,file_name='./reports/sigem_rms_hist', step=10, start=70 ,end=200,title = 'SigEM RMS Histogram',)
gen_em_hist(sigem_peak,file_name='./reports/sigem_peak_hist', step=10, start=70 ,end=200,title = 'SigEM Peak Histogram',)
gen_em_hist(sigem_dc,file_name='./reports/sigem_dc_hist', step=10, start=70 ,end=200,title = 'SigEM DC Histogram',)



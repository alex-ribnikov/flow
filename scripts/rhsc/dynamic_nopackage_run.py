# Redhawk-SC dynamic analysis without package run script
# 2021_R1.* compatible version
import os
include('./dynamic_inputs.py')
include('./custom_scripts.py')

dv_settings = {
    }

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

db = gp.open_db('./dynamic_db')

# View creation variables
#include('./phantom_pin_settings.py')

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

swa = db.create_switching_activity_view(timing_view=tv,
                                        object_settings=swa_object_settings,
                                        tag='swa',options=options)

ev = db.create_extract_view(dv,
                            tech_view=nv,
                            temperature=extract_temp,
                            tag = 'ev',options=options,
                            calculate_spr=True)

sv_dynamic = db.create_simulation_view(ev,
                                       tag = 'sv_dynamic',options=options,
                                       enable_reduction=False)

# evx =db.create_extract_view_from_files(dv,
#                                        input_files = spef_files,
#                                        tag='evx',options=options)

evx =db.create_extract_view_from_files(dv,
                                       gpd_dirs = gpd_dirs,
                                       tag='evx',options=options)

pwr = db.create_power_view(design_view=dv,
                           switching_activity_view=swa,
                           extract_view=None,
                           timing_view=tv,
                           voltage_levels=voltage_levels,
                           external_parasitics=evx,
                           temperature=pwr_temp,
                           calculation_settings = pwr_calculation_settings,
                           tag = 'pwr',options=options)

scn_dynamic = db.create_no_prop_scenario_view(power_view=pwr,
                                              timing_view=tv,
                                              extract_view=None,
                                              voltage_levels=voltage_levels,
                                              external_parasitics=evx,
                                              analysis_duration = sim_time,
                                              frame_length = 2*default_period,
                                              ensure_coverage = True,
                                              tag='scn_dynamic',options=options,
                                              object_settings=object_settings,
                                              default_clock = {},
                                              arrival_time_policy={'clock_path_pins': 'avg',
                                                                   'data_path_pins': 'random'},
                                              always_active_clocks={'clock_instances' : True,
                                                                    'sequential_instances' : True},
                                              current_data_precedence = ['APL', 'NLPM', 'CCSPower'],
                                              )

av_dynamic = db.create_analysis_view(sv_dynamic,
                        scn_dynamic,
                        step_size = 10e-12,
                        duration = sim_time,
                        keep_stats_level=KeepStats('Medium',cycle_stats = True,timing_window_stats_mode='sliding_window'),
                        current_snap_method = 'charge',
                        current_derate_mode='chargebased',
                        tag='av_dynamic', options=options)



# Report generation

data = data_integrity_reports.get_spef_annotation_summary(evx, view=None, reported_blocks=None)
data_integrity_reports.write_spef_annotation_reports(data, evx,summary_file='./reports/evx_spef_annotation_summary.rpt', detail_file='./reports/evx_spef_unannotated_details.rpt')
 

emir_reports.write_instance_power_report_and_summary(scn_dynamic, output_files = {'summary_file_name': './reports/power_summary_logic_prop.rpt', 'detailed_file_name':'./reports/detailed_power_logic_prop.rpt'}, settings = {'detailed_report_max_lines':10000})
emir_reports.write_instance_power_report_and_summary(pwr, output_files = {'summary_file_name': './reports/power_summary.rpt', 'detailed_file_name':'./reports/detailed_power_summary.rpt'}, settings = {'detailed_report_max_lines':10000})


emir_reports.write_all_instance_voltages(av_dynamic,output_file='./reports/av_logic_prop_non_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True, max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(non_clocks_filter,scn=scn_dynamic))
emir_reports.write_all_instance_voltages(av_dynamic, output_file='./reports/av_logic_prop_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True,max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(clocks_filter,scn=scn_dynamic))
emir_reports.write_all_instance_voltages(av_dynamic, output_file='./reports/av_logic_prop_top_1k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True,max_lines=1000, skip_instances_with_no_effdvd=True)
emir_reports.write_demand_currents(av_dynamic, output_file='./reports/logic_prop_demand_currents.sv')
scenario_utils.get_switching_coverage(scn_dynamic, file_name = './reports/switching_coverage_logic_prop.rpt',frame_length = default_period )
inst_spr(av_dynamic,file_name='./reports/logic_prop_worst_spr.rpt')
create_heatmaps([av_dynamic],dv,reports_dir = './reports/dynamic_nvp',range_in_perc_dyn = (3,10),colormap_style = 'stair_step_legacy')
plot_hist(av_dynamic.get_instance_voltage_histogram(data_type='eff_dvd'), (600, 825), threshold = 740, title = 'Dynamic Logic-Prop  voltage drop', file_name = './reports/dynamic_logic_prop_drop_hist', x_label = 'voltage[mV]')


reports_dir = 'reports/dynamic_nvp'
data = data_integrity_reports.get_timing_view_data_integrity_summary(timing_view=tv,detailed_reports = True)
data_integrity_reports.write_timing_view_data_integrity_reports(data =data,timing_view= tv, output_directory=reports_dir)

#report_script = os.path.join(actroot,'lib/seascape/python/gen_dynamic_reports.py')
#include(report_script)
#gen_dynamic_reports(av_dynamic,rpt_dir=rpt_dir)


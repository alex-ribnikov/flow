# Redhawk-SC static analysis run script
# 2021_R2.* (and python 3) compatible version
import os
include('./static_inputs.py')
include('./custom_scripts.py')

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

db = gp.open_db('./static_db')


reports_dir = './reports'
if not os.path.isdir(reports_dir):
    os.mkdir(reports_dir)
if not os.path.isdir(reports_dir+'/static/'):
    os.mkdir(reports_dir+'/static/')
if not os.path.isdir(reports_dir+'/PowerEM/'):
    os.mkdir(reports_dir+'/PowerEM/')




# View creation variables
dv_settings = { 'design_ecos': design_ecos,
                'rename_pg_nets': [],
                'focus_pg_nets': focus_pg_nets,
}

include('../scripts/rhsc/phantom_pin_settings.py')

swa_object_settings = { 'design_values' : { 'clock_period' : default_period,
                                            'clock_pin_toggle_rate' : clock_toggle_rate,
                                            'combinational_pin_toggle_rate' : data_toggle_rate,
                                            'macro_output_pin_toggle_rate' : data_toggle_rate,
                                            'sequential_output_pin_toggle_rate' : data_toggle_rate,
                                            'activity_precedence' : ['default_activity'],
                                            'clock_precedence' : ['sta'],
                                           }
                       }
swa_settings = {'constant_propagation' : 'off',
                'default_clock_period' : default_period,
                'object_settings' : swa_object_settings}
ev_settings = {'extract_temperature': extract_temp,
               'calculate_spr': True,
               'include_ron_in_spr': True,
               }
pwr_calculation_settings = {'internal':{'cell_types_with_independent_nlpm':['flip_flop', 'latch', 'memory', 'combinational', 'pad', 'macro', 'unknown']}}
pwr_settings = {'calculation': pwr_calculation_settings,
                'pvt': {'voltage_levels': voltage_levels, 'temperature': pwr_temp},
                }
scn_settings = {'pvt': {'voltage_levels': voltage_levels}}
em_settings = {'temperature_em': em_temp}
try:
    spef_files
except NameError:
    spef_files = None
try:
    gpd_dirs
except NameError:
    gpd_dirs = None

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
                                macro_views = [macro_view],
                                tag= 'dv0',options=options)
except NameError:
    dv0 = db.create_design_view(def_files=def_files,
                                lef_files=lef_files,
                                lib_views=lv,
                                top_cell_name = block_name,
                                settings = dv_settings,
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
                                        settings=swa_settings,
                                        tag='swa',options=options)

ev = db.create_extract_view(dv,
                            tech_view=nv,
                            settings = ev_settings,
                            tag = 'ev',options=options,
                            )

evx =db.create_extract_view_from_files(dv,
                                       input_files = spef_files,
                                       gpd_dirs = gpd_dirs,
                                       tag='evx',options=options)

pwr = db.create_power_view(design_view=dv,
                           switching_activity_view=swa,
                           extract_view=None,
                           timing_view=tv,
                           external_parasitics=evx,
                           settings = pwr_settings,
                           tag = 'pwr',options=options)

scn_static = db.create_scenario_view(power_view=pwr,
                                     timing_view=tv,
                                     scenario_type='Static',
                                     settings = scn_settings,
                                     external_parasitics=evx,
                                     tag='scn_static',options=options)

sv_static = db.create_simulation_view(ev,
                                      enable_reduction=False,
                                      tag = 'sv_static',options=options)

av_static = db.create_analysis_view(sv_static,
                                    scn_static,
                                    tag='av_static', options=options)

em_static = db.create_electromigration_view(av_static,
                                            mode='DC',
                                            settings = em_settings,
                                            tag='em_dc',options=options)

# Report generation
# report_script = os.path.join(actroot,'lib/seascape/python/gen_static_reports.py')
# include(report_script)
# gen_static_reports(em_static,av_static,rpt_dir=rpt_dir)
#

emir_reports.write_instance_power_report_and_summary(pwr, output_files = {'summary_file_name': './reports/static/power_summary.rpt', 'detailed_file_name':'./reports/static/detailed_power.rpt'}, settings = {'detailed_report_max_lines':10000})
emir_reports.write_all_instance_voltages(av_static, output_file='./reports/static/static_voltage_drop_top_10K.rpt.gz', max_lines = 10000,)
inst_spr(av_static,file_name='./reports/static/worst_spr.rpt')
create_heatmaps([av_static],dv,reports_dir = './reports/static',range_in_perc_static = (0,3) ,colormap_style = 'stair_step_legacy')
plot_hist(av_static.get_instance_voltage_histogram(), (750, 825), threshold = 800, title = 'Static voltage drop', file_name = './reports/static/static_drop_hist', x_label = 'voltage[mV]')


emir_reports.write_em_metal_report(em_static, output_file = './reports/PowerEM/metal_em.rpt', max_lines = 1000, em_range = 80.0)
emir_reports.write_em_via_report(em_static, output_file = './reports/PowerEM/via_em.rpt', max_lines = 1000, em_range = 80.0)
gen_em_hist(em_static,file_name='./reports/PowerEM/em_hist', step=10, start=70 ,end=200,title = 'PowerEM Histogram',)

gp.move_views_to_disk()
print_design_summary(av_static)


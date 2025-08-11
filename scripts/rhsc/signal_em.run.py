# Redhawk-sc signal_em_sc run script
# 2021_R2.* compatible version
import os
include('./signal_em_inputs.py')
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
ll = create_grid_launcher("slurm_launcher",slurm_command, num_workers_per_launch=num_workers_per_launch )
#ll = create_local_launcher('ll')
register_default_launcher(ll, max_num_workers=max_num_workers, wait_for_workers=wait_for_workers,multiplier = worker_multiplier)


options = get_default_options()
options['scenario_options'].apl_interpolation_policy = 'Method5'
options['layout_options'].degrading_def_cell_min_instance_count = -1


reports_dir = './reports'
if not os.path.isdir(reports_dir):
    os.mkdir(reports_dir)



db = gp.open_db(sigem_db)
try:
  db2 = gp.open_db(sigem_db2)
except NameError:
  pass

# View variables
dv_settings = { 'design_ecos': design_ecos,
                'rename_pg_nets': rename_pg_nets,
                'focus_pg_nets': focus_pg_nets,
}
try:
  sigem_object_settings
except NameError:
  sigem_object_settings = {}

av_sigem_settings = {'default_transition_time' : default_transition_time,
                     'default_toggle_rate' : data_toggle_rate,
                     'default_frequency' : default_freq,
                     'recovery_factor' : 1,
                     'voltage_levels': voltage_levels,
                     'object_settings' : sigem_object_settings,
                     'temperature': em_temp,
                    }
extraction_settings = {'mark_signal_pin_shapes' : True,
                       'extract_temperature' : extract_temp,
                       'detail_extraction_net_type' : 'signal',
                       'calculate_spr' : False,
                       }
                       
calculation_settings =  { 'internal' : { 'cell_types_with_independent_nlpm' : ['unknown'] }}
pwr_settings = {'calculation': calculation_settings,
                'pvt': {'voltage_levels': voltage_levels, 'temperature': pwr_temp},
                }

swa_object_settings = { 'design_values' : { 'activity_precedence' : ['default_activity'],
                                            'clock_precedence' : ['sta'],
                                            'clock_pin_toggle_rate' : clock_toggle_rate,
                                            'clock_period' : default_period,
                                            'combinational_pin_toggle_rate' : data_toggle_rate,
                                            'macro_output_pin_toggle_rate' : data_toggle_rate,
                                            'sequential_output_pin_toggle_rate' : data_toggle_rate,
                                            }
                        }
swa_settings = {'constant_propagation' : 'off',
                'default_clock_period' : default_period,
                'object_settings' : swa_object_settings}


em_peak_settings = {'mode': 'peak',
                    'temperature_em': em_temp,
                    'enable_signal_pin_em' : False,
                    }
em_rms_settings = {'mode': 'rms',
                   'enable_signal_pin_em' : False,
                   'delta_t_rms': 5.0,
                    }
try:
    spef_files
except NameError:
    spef_files = None
try:
    gpd_dirs
except NameError:
    gpd_dirs = None

# Create views
lv = db.create_liberty_view(liberty_file_names = lib_files,
                            options = options,
                            pgarc_file_names = lib_files_custom,
                            tag = 'lv')

dv = db.create_design_view(def_files = def_files,
                           lef_files = lef_files,
                           lib_views = lv,
                           top_cell_name = design_name,
                           settings=dv_settings,
                           options = options,
                           tag = 'dv')

tv = db.create_timing_view(design_view = dv,
                           timing_window_files = tw_files,
                           sdc_files = sdc_files,
                           options = options,
                           tag = 'tv')

swa = db.create_switching_activity_view(timing_view = tv,
                                        settings = swa_settings,
                                        options = options,
                                        tag = 'swa')

nv = db.create_tech_view(tech_file_name = tech_file,
                         options = options,
                         tag = 'nv')
try:
  sigem_db2
  ev = db2.create_extract_view(design_view = dv,
                               tech_view = nv,
                               options = options,
                               settings = extraction_settings,
                               tag = 'ev')
except NameError:
  ev = db.create_extract_view(design_view = dv,
                              tech_view = nv,
                              options = options,
                              settings = extraction_settings,
                              tag = 'ev')

evx = db.create_extract_view_from_files(design_view = dv,
                                        input_files = spef_files,
                                        gpd_dirs = gpd_dirs,
                                        options = options,
                                        store_dnet = True,
                                        store_pi_model = True,
                                        tag = 'evx')

pwr = db.create_power_view(design_view = dv,
                           switching_activity_view = swa,
                           extract_view = None,
                           timing_view = tv,
                           external_parasitics = evx,
                           options = options,
                           settings = pwr_settings,
                           tag = 'pwr')

sv_sigem = db.create_simulation_view(extract_view = ev,
                                     enable_reduction = False,
                                     options = options,
                                     sim_type = 'sigem',
                                     tag = 'sv_sigem')

av_sigem = db.create_signal_net_current_view(simulation_view = sv_sigem,
                                             switching_activity_view = swa,
                                             timing_view = tv,
                                             external_parasitics = evx,
                                             options = options,
                                             settings = av_sigem_settings,
                                             tag = 'av_sigem')

em_peak = db.create_electromigration_view(analysis_view = av_sigem,
                                          options = options,
                                          settings = em_peak_settings,
                                          tag = 'em_peak')

em_rms = db.create_electromigration_view(analysis_view = av_sigem,
                                         options = options,
                                         settings = em_rms_settings,
                                         tag = 'em_rms')


# Report generation and deltaT
rms_viol_report = rpt_dir + '/' + design_name + '.em_rms.violations.rpt'
analysis_utils.report_em_violations(em_rms,
                                    file_name=rms_viol_report,
                                    limit=MAXINT,comment=None,
                                    em_threshold=100.0)
peak_viol_report = rpt_dir + '/' + design_name + '.em_peak.violations.rpt'
analysis_utils.report_em_violations(em_peak,
                                    file_name=peak_viol_report,
                                    limit=MAXINT,comment=None,
                                    em_threshold=100.0)



#include(str(actroot) + '/lib/seascape/python/signal_em.functions.py')
#fdrop = rpt_dir + '/' + design_name + '.signal_em.dropped_nets'
#fdirty = rpt_dir + '/' + design_name + '.signal_em.dirty_nets'
#write_problem_net_reports(av_sigem,fdrop, fdirty)

#viols = em_rms.get_em_violations(violation_range=1.0, ignore_sliver = True)
#if len(viols) > 0:
#  include(str(actroot) + '/lib/seascape/python/deltaT.py')
#else:
#  final_rpt = rpt_dir + '/' + design_name + '.signal_em.violations.final_report'
#  with open (final_rpt, 'w') as outf:
#    outf.write('TOTAL NON-waived Violations: 0\n')


### sigEM reports ###
emir_reports.write_instance_power_report_and_summary(pwr, output_files = {'summary_file_name': './reports/power_summary.rpt', 'detailed_file_name':'./reports/detailed_power.rpt'}, settings = {'detailed_report_max_lines':10000})


emir_reports.write_sigem_dirty_net_report(av_sigem, output_file = './reports/dirty_nets.rpt')
emir_reports.write_sigem_dropped_net_report(av_sigem, output_file = './reports/dropped_nets.rpt')
emir_reports.write_sigem_net_attributes(av_sigem, output_file = './reports/sigem_net_attributes.rpt.gz')
emir_reports.write_sigem_open_report(av_sigem, output_file = './reports/open_nets.rpt')

emir_reports.write_em_metal_report(em_rms, output_file = './reports/rms_metal_em.rpt', max_lines = 1000, em_range = 80.0)
emir_reports.write_em_via_report(em_rms, output_file = './reports/rms_via_em.rpt', max_lines = 1000, em_range = 80.0)
emir_reports.write_em_metal_report(em_peak, output_file = './reports/peak_metal_em.rpt', max_lines = 1000, em_range = 80.0)
emir_reports.write_em_via_report(em_peak, output_file = './reports/peak_via_em.rpt', max_lines = 1000, em_range = 80.0)
gen_em_hist(em_rms,file_name='./reports/sigem_rms_hist', step=10, start=70 ,end=200,title = 'SigEM RMS Histogram',)
gen_em_hist(em_peak,file_name='./reports/sigem_peak_hist', step=10, start=70 ,end=200,title = 'SigEM Peak Histogram',)


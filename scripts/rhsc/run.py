### created by Vlad from Ansys on Aug25/2021
## Rev 1.3
import os
set_config('gp.skip_completed_views', 1)
#set_config('micro_resiliency', 1)


### run controls ###
run_reports = True     #Data Integrity reports, to check the validation of the input data. example: instances in the design with no lib file.   
static = True          #Static analysis, calculatin the avatege power and assigning currents behavior to each instance,. than solving ohm low for the voltage matrix.
dynamic_prop = True   #Dynamic analysis based on instance coverage in the design. randomise data on flops and than propogate them through logic to capture path. (prop = proppogation)
dynamic_pcvs = True   #Dynamic analysis based on an output target power (usualy from IPF file), controling power consumption using power gates. (pcvs- power constrain vectoeless scenario)
dynamic_nvp = False   #Dynamic analysis based on an output target power (usualy from IPF file), controling power consumption using power gates. (pcvs- power constrain vectoeless scenario)
run_pgem = True        #Electromigration analysis on the power grid. 
run_dyn_pgem = False   #Dynamic (time transient) Electromigration analysis on the power grid
run_sigem = True       #Electromigration analysis on the Signal nets.
bqm = True             #early grid heck, can run preplace. defining currents (current_per_micron_bqm) in props on metal 0 and projecting the entire grid currents, then calculating node voltages. (BQM- Build Quality Metric)
run_vector_profiler = False
run_vector_stress = False
check_via = True       #Running a via mising via diagnostic on the grid
dvd_diagnostic = False #Analysing worst v-drop to diagnose the worst aggresors instances in the design.  
r_eff = True           #Claculatin effective resistance from voltage pin to all the the posible pathes to power scorces. gives indication on power distribution and specific resistance unomalis. 
CPM = False            #Calculating the total current, resistance, capcity, and frequancy for the block. (Chip Power Model)


include('./input_files.py')
include('./custom_scripts.py')

gp.open_scheduler_window()


#### Creating Launcher for Workers ####
########################################################################################################
ll = create_grid_launcher("slurm_launcher",slurm_command, num_workers_per_launch=num_workers_per_launch )
#ll = create_local_launcher('ll')
register_default_launcher(ll, max_num_workers=max_num_workers, wait_for_workers=wait_for_workers,multiplier = worker_multiplier)



options = get_default_options()
options['signal_net_current_options'].current_heatmap_modes = ['rms','avg', 'peak']
options['extraction_options'].cached_net_short_buffer_size= 1000


########################################################################################################
#### Opening a Central DB ####
########################################################################################################
db = open_db("./" + top_cell_name + "_db",)
populate_view_tags()

views = db.get_view_names()


#### Reports ####
#reports dir preparation
if run_reports:

    reports_dir = './reports'

    if not os.path.isdir(reports_dir):
        os.mkdir(reports_dir)
    if not os.path.isdir(reports_dir+'/DI_reports/'):
        os.mkdir(reports_dir+'/DI_reports/')
    if not os.path.isdir(reports_dir+'/static/'):
        os.mkdir(reports_dir+'/static/')
    if not os.path.isdir(reports_dir+'/static/'+'/PowerEM/'):
        os.mkdir(reports_dir+'/static/'+'/PowerEM/')
    if not os.path.isdir(reports_dir+'/dynamic/'):
        os.mkdir(reports_dir+'/dynamic/')
    if not os.path.isdir(reports_dir+'/dynamic_nvp/'):
        os.mkdir(reports_dir+'/dynamic_nvp/')
    if not os.path.isdir(reports_dir+'/dynamic/'+'/PowerEM/'):
        os.mkdir(reports_dir+'/dynamic/'+'/PowerEM/')
    if not os.path.isdir(reports_dir+'/sigEM/'):
        os.mkdir(reports_dir+'/sigEM/')
    if not os.path.isdir(reports_dir+'/Vector/'):
        os.mkdir(reports_dir+'/Vector/')




if not 'lv' in views:
    lv = db.create_liberty_view(liberty_file_names = liberty_file_names, apl_file_names = apl_file_names, avm_config_files=avm_config_files, options = options, tag = "lv",)

if not 'nv' in views:
    nv = db.create_tech_view(tech_file_name = tech_file_name, options = options, tag = "nv", )

if not 'dv0' in views:
    dv0 = db.create_design_view(lib_views = lv, tech_view = nv, lef_files = lef_files, def_files = def_files, top_cell_name = top_cell_name, options = options, tag = "dv0", settings = settings_dv,)

if not 'dv' in views:
    #dv = db.create_modified_design_view(design_view = dv0, eco_commands = deco.create_top_sheet_and_plocs_func(dv = dv0, pitch = pitch, via_staple_distance = via_staple_distance), options = options, tag = "dv",)
    dv = db.create_modified_design_view(design_view = dv0, eco_commands = thpkgs_internal.appsc_utils.package.parse_ploc_func(file_name = ploc_files, dv = dv0), options = options, tag = "dv",)
if not 'ev' in views:
    ev = db.create_extract_view(design_view = dv, tech_view = nv, options = options, tag = "ev",settings = settings_ev,)

if not 'evx' in views:
    #evx = db.create_extract_view_from_files(design_view = dv,  store_dnet = True, store_load_cap = True, input_files = spef_files, options = options, tag = "evx",)
     evx = db.create_extract_view_from_files(design_view = dv,  store_dnet = True, store_load_cap = True, gpd_dirs = gpd_dirs, options = options, tag = "evx",)

if not 'sv' in views:
    sv = db.create_simulation_view(extract_view = ev, options = options, tag = "sv", )

if r_eff:
    if not 'reff' in views:
        reff = db.create_effective_resistance_view(sv, options = options, tag = 'reff')

if not 'tv' in views:
    tv = db.create_timing_view(design_view = dv, timing_window_files = timing_window_files, options = options, tag = "tv",settings = settings_tv )


if check_via:
    if not 'mvc' in views:
        bottom_layer = Layer('M0')
        top_layer = dv.get_attributes(dv.get_top_cell())['occupied_layers'][0]
        mvc = db.perform_missing_via_check(design_view = dv, top_layer = top_layer, bottom_layer = bottom_layer, tag = "mvc", options = options, settings = settings_mvc, )



### Design Reports ###
if  run_reports:
    ### Data Integrity Reports ###
    d_di_summary = data_integrity_reports.get_design_view_data_integrity_summary(dv, detailed_reports=True, instance_based=True)
    data_integrity_reports.write_design_view_data_integrity_reports(d_di_summary, dv, "./reports/DI_reports/")
    d_tv_summary = data_integrity_reports.get_timing_view_data_integrity_summary(tv, detailed_reports=True)
    data_integrity_reports.write_timing_view_data_integrity_reports(d_tv_summary, tv, "./reports/DI_reports/")
    d_spef_summary = data_integrity_reports.get_spef_annotation_summary(evx, include_uncovered_net_details=True)
    data_integrity_reports.write_spef_annotation_reports(d_spef_summary, evx, summary_file = "./reports/DI_reports/spef_annotation_summary.rpt",detail_file='./reports/DI_reports/spef_unannotated_details.rpt' )
    timing_view_data_integrity=data_integrity_reports.get_timing_view_data_integrity_summary(tv)
    report_plocs_used(dv,file_name ="./reports/DI_reports/design.ploc")
    if avm_files:
        get_missing_avm(dv, path = './reports/DI_reports/missing_avm.rpt')

    ### Gridcheck Reports ###
    data_integrity_reports.write_short_report(ev, report_short_type="all", output_file = './reports/DI_reports/shorts.rpt.gz')
    data_integrity_reports.write_disconnected_node_report(ev, output_file = './reports/DI_reports/disconnected_nodes.rpt.gz')
    data_integrity_reports.write_disconnected_pg_pins_report(ev, output_file = './reports/DI_reports/disconnected_instances.rpt.gz', max_lines = -1)
    d_conn_summary = data_integrity_reports.get_connectivity_data_integrity_summary(ev, detailed_reports=True)
    data_integrity_reports.write_connectivity_data_integrity_reports(d_conn_summary, ev, output_file = './reports/DI_reports/disconnected_signal_pins.rpt')
    report_pg_arcs={'report_absolute_resistance': True, 'minimal_lines_per_arc': 1000}
    emir_reports.report_instance_pin_spr(ev, report_pg_arcs=report_pg_arcs, output_file = "./reports/DI_reports/instance_pin_spr.rpt")
    if r_eff:
        emir_reports.report_effective_resistance(reff, file_name = './reports/DI_reports/reff_report.rpt', report_type = 'max_res')
    if check_via:
        heatmap_utils.report_missing_vias(missing_via_view = mvc, file_name = './reports/DI_reports/missing_via_locations.rpt', wait = True, get_incell_coord = True, )



#### Run BQM ####

if bqm:
    if not 'mev_bqm' in views:
        check_layer = dv.get_attributes(dv.get_top_cell())['occupied_layers'][-1]
        bqm_probes, bqm_currents = bqm_current.generate_bqm_current_probe_metal(dv, check_layer = check_layer, current_per_micron = current_per_micron_bqm, )

        mev_bqm = db.create_modified_extract_view(ev, probes = bqm_probes, tag = "mev_bqm",options = options, )
        sv_bqm = db.create_simulation_view(mev_bqm, tag = "sv_bqm", options = options, )
        settings_bqm['probe_sources'] =  bqm_currents
        scn_bqm = db.create_scenario_view(timing_view = tv, design_view = dv, tag = "scn_bqm", options = options, settings = settings_bqm,)
    if not 'av_bqm' in views:
        av_bqm = db.create_analysis_view(sv_bqm, scn_bqm, keep_stats_level='Bqm', tag = "av_bqm", options = options, scheduler_barrier = scheduler_barrier  )

        pg_nets = dv.get_nets('pg')
        bqm_inst = generate_drop_heatmaps.generate_pin_voltage_heatmaps(av_bqm, nets = pg_nets, base_level = True)
        bqm_data = db.create_user_view(tag = "bqm_data")
        for net in bqm_inst:
            bqm_data['hm_' + net.get_name()] = bqm_inst[net]
            bqm_data['stats_' + net.get_name()] = normalize_heatmaps.get_heatmap_min_max_median(dv, bqm_inst[net])



#### Run Static Analysis ####

if static:

    if not 'swa' in views:
        swa = db.create_switching_activity_view(timing_view = tv,options=options, tag = "swa", settings= settings_swa,)

    if not 'pwr' in views:
        pwr = db.create_power_view(switching_activity_view = swa, design_view = dv, extract_view = ev, timing_view = tv, external_parasitics = evx, options = options, tag = "pwr", settings =settings_pwr,)

    if not 'scn_static' in views:
        scn_static = db.create_scenario_view(design_view = dv, extract_view = ev, timing_view = tv, external_parasitics = evx, power_view = pwr, options = options, tag = "scn_static", settings = settings_scn_stat, )
    if not 'av_static' in views:
        av_static = db.create_analysis_view(simulation_view = sv, scenario_views = scn_static, options = options, tag = "av_static",keep_stats_level =keep_stats_level_static, scheduler_barrier = scheduler_barrier )

    if  run_reports:
    ### run static reports ###
        emir_reports.write_instance_power_report_and_summary(scn_static, output_files = {'summary_file_name': './reports/static/power_summary.rpt', 'detailed_file_name':'./reports/static/detailed_power.rpt'}, settings = {'detailed_report_max_lines':10000})
        emir_reports.write_all_instance_voltages(av_static, output_file='./reports/static/static_voltage_drop_top_10K.rpt.gz', max_lines = 10000,)
        inst_spr(av_static,file_name='./reports/static/worst_spr.rpt')
        create_heatmaps([av_static],dv,reports_dir = './reports/static',range_in_perc_static = (0,3) ,colormap_style = 'stair_step_legacy')
        plot_hist(av_static.get_instance_voltage_histogram(), (750, 825), threshold = 800, title = 'Static voltage drop', file_name = './reports/static/static_drop_hist', x_label = 'voltage[mV]')




#### Run Dynamic Analysis - Logic nvp ####
if dynamic_nvp:
    if not 'swa' in views:
        swa = db.create_switching_activity_view(timing_view = tv,options=options, tag = "swa", settings= settings_swa,)

    if not 'pwr' in views:
        pwr = db.create_power_view(switching_activity_view = swa, design_view = dv, extract_view = None, timing_view = tv, external_parasitics = evx, options = options, tag = "pwr", settings =settings_pwr_nvp,)


    if not 'scn_dynamic_nvp' in views:
        scn_dynamic_nvp = db.create_no_prop_scenario_view(power_view = pwr, settings = settings_scn_nvp_dyn,
	  timing_view = tv,
	 extract_view=None,
	 tag = "scn_dynamic_nvp",
	 external_parasitics = evx,
	 options = options,
	 default_clock = {},
	 scenario_duration = scenario_duration,)

#	  always_active_clocks = {'clock_instances' : True, 'sequential_instances' : True},
#	  arrival_time_policy={'clock_path_pins': 'avg', 'data_path_pins': 'random'},
#	  frame_length = 2*clock_cycle)
#	  ensure_coverage = True,
#	  current_data_precedence = ['APL', 'NLPM', 'CCSPower'],
#	  object_settings=settings_npv_dyn,
#	  voltage_levels=voltage_levels,
    
    if not 'av_dynamic' in views:
        av_dynamic_nvp = db.create_analysis_view(simulation_view = sv, scenario_views = scn_dynamic_nvp, options = options, tag = "av_dynamic_nvp", duration = scenario_duration, step_size = step_size, keep_stats_level = keep_stats_level_dynamic, scheduler_barrier = scheduler_barrier )

    ### run DvD Diagnostics ipf ###
    if dvd_diagnostic:
        if not 'ddgv_nvp' in views:
            insts = analysis_utils.get_worst_N_instance_compression(av_dynamic_nvp, top_n = top_victims)
            insts = [gp.Instance(xx[0])  for xx in insts.get()]
            ddgv_nvp = db.create_dvd_diagnosis_view(av_dynamic_nvp, victims = insts, options = options, tag = 'ddgv_nvp')
            aggv_nvp = db.create_dvd_aggressor_view(ddgv_nvp, top_n = 50, tag = 'aggv_nvp')
            top_agg = aggv_nvp.get_top_n()
            if run_reports:
                gp.write_to_file('./reports/dynamic_nvp/propagate_top_aggresors.rpt', gp_list(top_agg))
            agg_load_cap(aggv_nvp, av_dynamic_nvp, db)

    if run_reports:
    #### run dynamic reports ####
        emir_reports.write_instance_power_report_and_summary(scn_dynamic_nvp, output_files = {'summary_file_name': './reports/dynamic_nvp/power_summary_logic_prop.rpt', 'detailed_file_name':'./reports/dynamic_nvp/detailed_power_logic_prop.rpt'}, settings = {'detailed_report_max_lines':10000})
        emir_reports.write_all_instance_voltages(av_dynamic_nvp,output_file='./reports/dynamic_nvp/av_logic_prop_non_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True, max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(non_clocks_filter,scn=scn_dynamic_nvp))
        emir_reports.write_all_instance_voltages(av_dynamic_nvp, output_file='./reports/dynamic_nvp/av_logic_prop_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True,max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(clocks_filter,scn=scn_dynamic_nvp))
        emir_reports.write_all_instance_voltages(av_dynamic_nvp, output_file='./reports/dynamic_nvp/av_logic_prop_top_1k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True,max_lines=1000, skip_instances_with_no_effdvd=True)
        emir_reports.write_demand_currents(av_dynamic_nvp, output_file='./reports/dynamic_nvp/logic_prop_demand_currents.sv')
        scenario_utils.get_switching_coverage(scn_dynamic_nvp, file_name = './reports/dynamic_nvp/switching_coverage_logic_prop.rpt',frame_length = clock_cycle )
        inst_spr(av_dynamic_nvp,file_name='./reports/dynamic_nvp/logic_prop_worst_spr.rpt')
        create_heatmaps([av_dynamic_nvp],dv,reports_dir = './reports/dynamic_nvp',range_in_perc_dyn = (3,10),colormap_style = 'stair_step_legacy')
        plot_hist(av_dynamic_nvp.get_instance_voltage_histogram(data_type='eff_dvd'), (600, 825), threshold = 740, title = 'Dynamic Logic-Prop  voltage drop', file_name = './reports/dynamic_nvp/dynamic_logic_prop_drop_hist', x_label = 'voltage[mV]')


if dynamic_prop:

    if not 'scn_dynamic' in views:
        scn_dynamic = db.create_scenario_view(extract_view = ev, timing_view = tv, external_parasitics = evx, options = options, tag = "scn_dynamic", scenario_duration = scenario_duration, settings = settings_scn_dyn)
    if not 'av_dynamic' in views:
        av_dynamic = db.create_analysis_view(simulation_view = sv, scenario_views = scn_dynamic, options = options, tag = "av_dynamic", duration = scenario_duration, step_size = step_size, keep_stats_level = keep_stats_level_dynamic, scheduler_barrier = scheduler_barrier )

    ### run DvD Diagnostics ipf ###
    if dvd_diagnostic:
        if not 'ddgv' in views:
            insts = analysis_utils.get_worst_N_instance_compression(av_dynamic, top_n = top_victims)
            insts = [gp.Instance(xx[0])  for xx in insts.get()]
            ddgv = db.create_dvd_diagnosis_view(av_dynamic, victims = insts, options = options, tag = 'ddgv')
            aggv = db.create_dvd_aggressor_view(ddgv, top_n = 50, tag = 'aggv')
            top_agg = aggv.get_top_n()
            if run_reports:
                gp.write_to_file('./reports/dynamic/propagate_top_aggresors.rpt', gp_list(top_agg))
            agg_load_cap(aggv, av_dynamic, db)

    if run_reports:
    #### run dynamic reports ####
        emir_reports.write_instance_power_report_and_summary(scn_dynamic, output_files = {'summary_file_name': './reports/dynamic/power_summary_logic_prop.rpt', 'detailed_file_name':'./reports/dynamic/detailed_power_logic_prop.rpt'}, settings = {'detailed_report_max_lines':10000})
        emir_reports.write_all_instance_voltages(av_dynamic,output_file='./reports/dynamic/av_logic_prop_non_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True, max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(non_clocks_filter,scn=scn_dynamic))
        emir_reports.write_all_instance_voltages(av_dynamic, output_file='./reports/dynamic/av_logic_prop_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True,max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(clocks_filter,scn=scn_dynamic))
        emir_reports.write_all_instance_voltages(av_dynamic, output_file='./reports/dynamic/av_logic_prop_top_1k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True,max_lines=1000, skip_instances_with_no_effdvd=True)
        emir_reports.write_demand_currents(av_dynamic, output_file='./reports/dynamic/logic_prop_demand_currents.sv')
        scenario_utils.get_switching_coverage(scn_dynamic, file_name = './reports/dynamic/switching_coverage_logic_prop.rpt',frame_length = clock_cycle )
        inst_spr(av_dynamic,file_name='./reports/dynamic/logic_prop_worst_spr.rpt')
        create_heatmaps([av_dynamic],dv,reports_dir = './reports/dynamic',range_in_perc_dyn = (3,10),colormap_style = 'stair_step_legacy')
        plot_hist(av_dynamic.get_instance_voltage_histogram(data_type='eff_dvd'), (600, 825), threshold = 740, title = 'Dynamic Logic-Prop  voltage drop', file_name = './reports/dynamic/dynamic_logic_prop_drop_hist', x_label = 'voltage[mV]')



if dynamic_pcvs:
#requires to run static run
    power_checker = True
    if not 'scn_dynamic_pcvs' in views:
        try:
            target_power = scn_static.get_demand_power_data()['power_drawn_from_power_nets']
            gp_print('target_power is: ',target_power)
            target_power_settings = { 'power_targets': { Instance('') : { '*' : {'target_power' : target_power},}}, 'macro_power_scalable': True, }
        except NameError:
            gp_print('Static Scenario not found!, PCVS scenario can\'t run, please generate a Static Scenario and rerun.')
            power_checker = False

        if power_checker:
            settings_scn_dyn['target_power'] = target_power_settings
            scn_dynamic_pcvs = db.create_scenario_view(extract_view = ev, timing_view = tv, external_parasitics = evx, options = options, tag = "scn_dynamic_pcvs", scenario_duration = scenario_duration, settings = settings_scn_dyn)

            if not 'av_dynamic_pcvs' in views:
                av_dynamic_pcvs = db.create_analysis_view(simulation_view = sv, scenario_views = scn_dynamic_pcvs, options = options, tag = "av_dynamic_pcvs",duration = scenario_duration, step_size = step_size, keep_stats_level = keep_stats_level_dynamic, scheduler_barrier = scheduler_barrier  )

            if dvd_diagnostic:
                ### run DvD Diagnostics PCVS ###
                if not 'ddgv_pcvs' in views:
                    insts = analysis_utils.get_worst_N_instance_compression(av_dynamic_pcvs, top_n = top_victims)
                    insts = [gp.Instance(xx[0])  for xx in insts.get()]
                    ddgv_pcvs = db.create_dvd_diagnosis_view(av_dynamic_pcvs, victims = insts, options = options, tag = 'ddgv_pcvs')
                    aggv_pcvs = db.create_dvd_aggressor_view(ddgv_pcvs, top_n = 50, tag = 'aggv_pcvs')
                    top_agg_pcvs = aggv_pcvs.get_top_n()
                    if run_reports:
                        gp.write_to_file('./reports/dynamic/top_aggresors_pcvs.rpt', gp_list(top_agg_pcvs))
                    agg_load_cap(aggv_pcvs, av_dynamic_pcvs, db)


### dynamic PCVS reports ###
    if power_checker and run_reports:
        emir_reports.write_instance_power_report_and_summary(scn_dynamic_pcvs, output_files = {'summary_file_name': './reports/dynamic/power_summary_pcvs.rpt', 'detailed_file_name':'./reports/dynamic/detailed_power_pcvs.rpt'}, settings = {'detailed_report_max_lines':10000})
        emir_reports.write_all_instance_voltages(av_dynamic_pcvs,output_file='./reports/dynamic/av_pcvs_non_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True, max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(non_clocks_filter,scn=scn_dynamic))
        emir_reports.write_all_instance_voltages(av_dynamic_pcvs, output_file='./reports/dynamic/av_pcvs_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True,max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(clocks_filter,scn=scn_dynamic))
        emir_reports.write_demand_currents(av_dynamic_pcvs, output_file='./reports/dynamic/pcvs_demand_currents.sv')
        scenario_utils.get_switching_coverage(scn_dynamic_pcvs, file_name = './reports/dynamic/switching_coverage_pcvs.rpt',frame_length = clock_cycle )
        inst_spr(av_dynamic_pcvs,file_name='./reports/dynamic/pcvs_worst_spr.rpt')
        create_heatmaps([av_dynamic_pcvs],dv,reports_dir = './reports/dynamic',range_in_perc_dyn = (3,10),colormap_style = 'stair_step_legacy')
        plot_hist(av_dynamic_pcvs.get_instance_voltage_histogram(data_type='eff_dvd'), (600, 825), threshold = 740, title = 'Dynamic PCVS  voltage drop', file_name = './reports/dynamic/dynamic_pcvs_drop_hist', x_label = 'voltage[mV]')


gp.move_views_to_disk()


##### Vector Run ####
if run_vector_profiler:
    if not 'vcv' in views:
        vcv = db.create_value_change_view(design_view = dv, tag = 'vcv', vcd_files = vcd_files, options = options, settings = settings_vcv,)
    value_change_data = [{'view' : vcv, 'slice_name' : 'slice1'}]
    if not 'ppv' in views:
        ppv = db.create_power_profile_view(timing_view = tv, extract_view=ev, external_parasitics=evx, tag='ppv', options=options, value_change_data=value_change_data, scenario_durationn=vcd_duration, settings = settings_ppv)
    ppv_results = ppv.get_results()
    prof_worst_power = vector_selection.find_n_peak_power_slices(scope_results = ppv_results['top'], intervals = ppv_results['intervals'], slice_num_intervals = 1, max_output_slices = 10)
    prof_worst_change = vector_selection.find_n_power_change_slices(scope_results = ppv_results['top'],  intervals = ppv_results['intervals'], max_output_slices = 10)
    gp_print('################################')
    gp_print('power_profile_worst_power' , prof_worst_power)
    gp_print('power_profile_worst_change' , prof_worst_change)
    gp_print('################################')
    if not 'uv_prof' in views:
        uv_prof = db.create_user_view(tag = 'uv_prof')
        uv_prof['prof_worst_power'] = prof_worst_power
        uv_prof['prof_worst_change'] = prof_worst_change
        gp.move_views_to_disk()
    scenario_duration_vcv = uv_prof['prof_worst_power'][0]['end_time'] - uv_prof['prof_worst_power'][0]['start_time']
    if not 'vcv_prof' in views:
        vcd_files_prof = [{'file_name': vcd_file, 'preamble': vcd_preamble, 'time_slices':[{'slice_name': 'prof1', 'start_time': uv_prof['prof_worst_power'][0]['start_time'], 'stop_time': uv_prof['prof_worst_power'][0]['end_time'] }]}]
        vcv_prof = db.create_value_change_view(design_view = dv, tag = 'vcv_prof', vcd_files = vcd_files_prof, options = options, settings = settings_vcv,)
    if not 'scn_dynamic_vcv' in views:
        value_change_data_prof = [{'view' : vcv_prof, 'slice_name' : 'prof1'}]
        settings_scn_dyn['object_settings']['cell_values'] = []
        settings_scn_dyn['object_settings']['design_values']['gate_vcd_mode'] = 'tick_based'
        settings_scn_dyn['event']['infer_icg_enable_signals_from_fanin_prop'] = True
        settings_scn_dyn['object_settings']['design_values']['toggle_rate'] = vcd_scn_TR
        scn_dynamic_vcv = db.create_scenario_view(extract_view = ev, timing_view = tv, external_parasitics = evx, options = options, tag = "scn_dynamic_vcv", scenario_duration = scenario_duration_vcv, value_change_data=value_change_data_prof, settings = settings_scn_dyn,)

    if not 'av_dynamic_vcv' in views:
        av_dynamic_vcv = db.create_analysis_view(simulation_view = sv, scenario_views = scn_dynamic_vcv, options = options, tag = "av_dynamic_vcv",duration = scenario_duration_vcv, step_size = step_size, keep_stats_level = 'Full',scheduler_barrier = False )


    if run_reports:
    ### vcd analysis reports ###
        d_vcv_summary = data_integrity_reports.get_value_change_view_data_integrity_summary(vcv, settings = {'output_data' : ['summary', 'uncovered_instance_pins']})
        data_integrity_reports.write_value_change_view_data_integrity_reports(d_vcv_summary, vcv, output_files = {'summary_file_name': './reports/Vector/vcd_coverage_summary.rpt', 'detailed_file_name': './reports/Vector/detailed_coverage.rpt'} )

        emir_reports.write_instance_power_report_and_summary(scn_dynamic_vcv, file_name_summary_report = './reports/Vector/power_summary_vector.rpt', file_name_detailed_report='./reports/Vector/power_vector.rpt', max_lines_detailed_report = None)
        emir_reports.write_all_instance_voltages(av_dynamic_vcv, output_file = './reports/Vector/voltage_stats_vector.rpt.gz', skip_instances_with_no_effdvd = True, sort_columns = ['eff_Vdd'], max_lines = None, sort_order = 'descending', sort = True  )
        emir_reports.write_demand_currents(av_dynamic_vcv, output_file='./reports/Vector/demand_currents_vcv.sv')
        scenario_utils.get_switching_coverage(scn_dynamic_vcv, file_name = './reports/Vector/switching_coverage_vector.rpt', )
        ppv_pwc_internal = gp.ppv_scope_results_to_pwc(ppv_results['top'], ppv_results['intervals'], title='vector Power over time', power_func=lambda xx: xx.get_total_power())
        plt = plot(ppv_pwc_internal, output_file = './reports/Vector/power_over_time_plot.png')
        plt.close()



if run_vector_stress:
    if not 'vcv' in views:
        vcv = db.create_value_change_view(design_view = dv, tag = 'vcv', vcd_files = vcd_files, options = options, settings = settings_vcv,)
    value_change_data = [{'view' : vcv, 'slice_name' : 'slice1'}]

    if not 'swa_vcv' in views:
        settings_swa['infer_icg_enable_signals_from_fanin_prop'] = True
        swa_vcv = db.create_switching_activity_view(timing_view = tv, value_change_data = value_change_data, options=options, tag = "swa_vcv", settings= settings_swa,)
    if not 'pwr_vcv' in views:
        pwr_vcv = db.create_power_view(switching_activity_view = swa_vcv, design_view = dv, extract_view = ev, timing_view = tv, external_parasitics = evx, options = options, tag = "pwr_vcv", settings =settings_pwr,)
        pwr_vcv.write_instance_power_file(file_name = './reports/Vector/pwr_ipf_orig.ipf')
        os.system('touch ./pwr_ipf_stress.ipf')
        make_ipf(orig_ipf = './reports/Vector/pwr_ipf_orig.ipf', new_ipf = './reports/Vector/pwr_ipf_stress.ipf', TR = 0.3)

    if not 'pwr_vcv_stress' in views:
        pwr_vcv.write_instance_power_file(file_name = './reports/Vector/pwr_ipf_orig.ipf')
        make_ipf(orig_ipf = './reports/Vector/pwr_ipf_orig.ipf', new_ipf = './reports/Vector/pwr_ipf_stress.ipf', TR = 0.3)
        pwr_vcv_stress = db.create_power_view(power_files = [{'file_name' : './reports/Vector/pwr_ipf_stress.ipf'}], design_view = dv, extract_view = ev, timing_view = tv, external_parasitics = evx, options = options, tag = "pwr_vcv_stress", settings =settings_pwr,)

    if not 'scn_dynamic_stress' in views:
        scn_dynamic_stress = db.create_scenario_view(extract_view = ev, timing_view = tv, power_view = pwr_vcv_stress, external_parasitics = evx, options = options, tag = "scn_dynamic_stress", scenario_duration = scenario_duration, settings = settings_scn_dyn)
    if not 'av_dynamic_stress' in views:
        av_dynamic_stress = db.create_analysis_view(simulation_view = sv, scenario_views = scn_dynamic_stress, options = options, tag = "av_dynamic_stress", duration = scenario_duration, step_size = step_size, keep_stats_level = keep_stats_level_dynamic, scheduler_barrier = scheduler_barrier )

    ### run DvD Diagnostics ipf ###
    if dvd_diagnostic:
        if not 'ddgv_stress' in views:
            insts = analysis_utils.get_worst_N_instance_compression(av_dynamic_stress, top_n = top_victims)
            insts = [gp.Instance(xx[0])  for xx in insts.get()]
            ddgv_stress = db.create_dvd_diagnosis_view(av_dynamic_stress, victims = insts, options = options, tag = 'ddgv_stress')
            aggv_stress = db.create_dvd_aggressor_view(ddgv_stress, top_n = 50, tag = 'aggv_stress')
            top_agg = aggv_stress.get_top_n()
            if run_reports:
                gp.write_to_file('./reports/Vector/stress_top_aggresors.rpt', gp_list(top_agg))
            agg_load_cap(aggv_stress, av_dynamic_stress, db)

    if run_reports:
    #### run stress dyanmic reports ####
        emir_reports.write_instance_power_report_and_summary(scn_dynamic_stress, output_files = {'summary_file_name': './reports/Vector/power_summary_stress.rpt', 'detailed_file_name':'./reports/Vector/detailed_power_stress.rpt'}, settings = {'detailed_report_max_lines':10000})
        emir_reports.write_all_instance_voltages(av_dynamic_stress,output_file='./reports/Vector/av_stress_non_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True, max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(non_clocks_filter,scn=scn_dynamic))
        emir_reports.write_all_instance_voltages(av_dynamic_stress, output_file='./reports/Vector/av_stress_clock_top_10k.rpt', columns=None, sort_order='ascending', sort_columns=['eff_Vdd'], sort=True,max_lines=10000, skip_instances_with_no_effdvd=True,filter_func=partial(clocks_filter,scn=scn_dynamic))
        emir_reports.write_demand_currents(av_dynamic_stress, output_file='./reports/Vector/stress_demand_currents.sv')
        scenario_utils.get_switching_coverage(scn_dynamic_stress, file_name = './reports/Vector/switching_coverage_stress.rpt',frame_length = clock_cycle )
        inst_spr(av_dynamic_stress,file_name='./reports/Vector/stress_worst_spr.rpt')
        create_heatmaps([av_dynamic_stress],dv,reports_dir = './reports/Vector',range_in_perc_dyn = (3,10),colormap_style = 'stair_step_legacy')
        plot_hist(av_dynamic_stress.get_instance_voltage_histogram(data_type='eff_dvd'), (600, 825), threshold = 740, title = 'Dynamic Logic-Prop  voltage drop', file_name = './reports/Vector/dynamic_stress_drop_hist', x_label = 'voltage[mV]')









#### Run PG - EM ####

if run_pgem:
    if not 'emv' in views:
        emv = db.create_electromigration_view(analysis_view = av_static, tag = 'emv', options = options, settings = {'mode': 'DC','temperature_em' : temperature_em,})

    if run_dyn_pgem:
        # requires dynamic analysis.
        if (not 'av_dynamic' in views) and (not dynamic_prop):
            gp_print('please run dyanmic analysis before dynamic powerEM')
        else:
            if not 'emv_dyn_rms' in views:
                emv_dyn_rms = db.create_electromigration_view(analysis_view = av_dynamic , tag = 'emv_dyn_rms', options = options, settings = {'mode': 'RMS','temperature_em' : temperature_em, 'delta_t_rms': temperature_em_rms})
            if not 'emv_dyn_peak' in views:
                emv_dyn_peak = db.create_electromigration_view(analysis_view = av_dynamic, tag = 'emv_dyn_peak', options = options, settings = {'mode': 'PEAK','temperature_em' : temperature_em,})

    if run_reports:
    ### powerEM reports ###
        emir_reports.write_em_metal_report(emv, output_file = './reports/static/PowerEM/metal_em.rpt', max_lines = 1000, em_range = 80.0)
        emir_reports.write_em_via_report(emv, output_file = './reports/static/PowerEM/via_em.rpt', max_lines = 1000, em_range = 80.0)
        gen_em_hist(emv,file_name='./reports/static/PowerEM/em_hist', step=10, start=70 ,end=200,title = 'PowerEM Histogram',)
        if run_dyn_pgem:
            emir_reports.write_em_metal_report(emv_dyn_rms, output_file = './reports/dynamic/PowerEM/metal_em_rms.rpt', max_lines = 1000, em_range = 80.0)
            emir_reports.write_em_via_report(emv_dyn_rms, output_file = './reports/dynamic/PowerEM/via_em_rms.rpt', max_lines = 1000, em_range = 80.0)
            gen_em_hist(emv_dyn_rms,file_name='./reports/dynamic/PowerEM/em_rms_hist', step=10, start=70 ,end=200,title = 'RMS PowerEM Histogram',)
            emir_reports.write_em_metal_report(emv_dyn_peak, output_file = './reports/dynamic/PowerEM/metal_em_peak.rpt', max_lines = 1000, em_range = 80.0)
            emir_reports.write_em_via_report(emv_dyn_peak, output_file = './reports/dynamic/PowerEM/via_em_peak.rpt', max_lines = 1000, em_range = 80.0)
            gen_em_hist(emv_dyn_peak,file_name='./reports/dynamic/PowerEM/em_peak_hist', step=10, start=70 ,end=200,title = 'PEAK PowerEM Histogram',)

#### Run Signal - EM ####

if run_sigem:
    sv_sigem = db.create_simulation_view(extract_view = ev, options=options, tag = "sv_sigem", sim_type = 'sigem' )
    swa_sigem = db.create_switching_activity_view(timing_view = tv, options=options, tag = "swa_sigem", settings = settings_swa_sigem, )
    scv = db.create_signal_net_current_view(simulation_view = sv_sigem, switching_activity_view = swa_sigem, timing_view = tv, external_parasitics = evx, options = options,  tag = 'scv', settings = settings_scv,)
    sigem_dc = db.create_electromigration_view(analysis_view = scv, tag = 'sigem_dc', options = options, settings = {'mode': 'DC','temperature_em' : temperature_em,})
    sigem_peak = db.create_electromigration_view(analysis_view = scv, tag = 'sigem_peak', options = options, settings = {'mode': 'PEAK','temperature_em' : temperature_em,})
    sigem_rms = db.create_electromigration_view(analysis_view = scv, tag = 'sigem_rms', options = options, settings = {'mode': 'RMS','temperature_em' : temperature_em, 'delta_t_rms': temperature_em_rms})


    if run_reports:
    ### sigEM reports ###
        emir_reports.write_sigem_dirty_net_report(scv, output_file = './reports/sigEM/dirty_nets.rpt')
        emir_reports.write_sigem_dropped_net_report(scv, output_file = './reports/sigEM/dropped_nets.rpt')
        emir_reports.write_sigem_net_attributes(scv, output_file = './reports/sigEM/sigem_net_attributes.rpt.gz')
        emir_reports.write_sigem_open_report(scv, output_file = './reports/sigEM/open_nets.rpt')
        emir_reports.write_em_metal_report(sigem_dc, output_file = './reports/sigEM/dc_metal_em.rpt', max_lines = 1000, em_range = 80.0)
        emir_reports.write_em_via_report(sigem_dc, output_file = './reports/sigEM/dc_via_em.rpt', max_lines = 1000, em_range = 80.0)
        emir_reports.write_em_metal_report(sigem_rms, output_file = './reports/sigEM/rms_metal_em.rpt', max_lines = 1000, em_range = 80.0)
        emir_reports.write_em_via_report(sigem_rms, output_file = './reports/sigEM/rms_via_em.rpt', max_lines = 1000, em_range = 80.0)
        emir_reports.write_em_metal_report(sigem_peak, output_file = './reports/sigEM/peak_metal_em.rpt', max_lines = 1000, em_range = 80.0)
        emir_reports.write_em_via_report(sigem_peak, output_file = './reports/sigEM/peak_via_em.rpt', max_lines = 1000, em_range = 80.0)
        gen_em_hist(sigem_rms,file_name='./reports/sigEM/sigem_rms_hist', step=10, start=70 ,end=200,title = 'SigEM RMS Histogram',)
        gen_em_hist(sigem_peak,file_name='./reports/sigEM/sigem_peak_hist', step=10, start=70 ,end=200,title = 'SigEM Peak Histogram',)
        gen_em_hist(sigem_dc,file_name='./reports/sigEM/sigem_dc_hist', step=10, start=70 ,end=200,title = 'SigEM DC Histogram',)





### run CPM ###
if CPM:
    big_launcher = create_grid_launcher('big_launcher' ,big_command)
    big_launcher.set_jobs(['cpm.write_spice_deck*', 'cpm.run_asim_power_model*'])
    big_launcher.launch(1)
    settings_ev['reduction'] = {'rollup' : ev_utils.create_rollup_settings(dv,keep_metals=5)}
    if not 'ev_rollup' in views:
        ev_rollup = db.create_extract_view(design_view = dv, tech_view = nv, options = options, tag = "ev_rollup",settings = settings_ev,)
    if not 'sv_rollup' in views:
        sv_rollup = db.create_simulation_view(extract_view = ev_rollup, options = options, tag = "sv_rollup",sim_type = 'cpm' )
    if not 'grm' in views:
        grm = db.create_reduced_model_view(sv_rollup, analysis_view = av_dynamic, tag='grm', options = options, cpm_noglobal_gnd = False, cpm_passive = True, cpm_pincurrent = True, coupled_simulation = True, cpm_rleak = True)
    sp_model = grm.get_reduced_model_in_spice()
    write_to_file('./cpm_model.sp', sp_model)



gp.move_views_to_disk()
sum_views = db.get_view_names()
if 'dynamic_prop' in sum_views:
    print_design_summary(av_dynamic)
elif 'dynamic_pcvs' in sum_views:
    print_design_summary(av_dynamic_pcvs)
elif 'av_static' in sum_views:
    print_design_summary(av_static)
else:
    print_design_summary(dv)

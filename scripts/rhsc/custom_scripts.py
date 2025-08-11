import os
import csv
import thpkgs_internal
import matplotlib.pyplot as plt

def _header():
    h = gp.GpsFunctionHeader('Create Voltage Drop Heatmaps')
    h.add('hm_list', 'it of Analysis views to use for Heatmap creation', list)
    h.add('design_view', 'DesignView to be used', gp.DesignView)
    h.add('reports_dir', 'location to save the reports', str)
    h.add('range_in_perc_static', 'tuple of min and max values to set for static drop heatmap', tuple)
    h.add('range_in_perc_dyn', 'tuple of min and max values to set for dynamic drop heatmap', tuple)
    h.add('em_range', 'tuple of the min and max values in EM heatmap', tuple)
    h.add('colormap_style', 'the color style for heatmap', str)
    h.set_details('''
    Generates heatmaps of the IR drop for a Static Analysis.
    Generates heatmaps of eff_dvd and the min_tw DVD for Dynamic Analysis.
    Generates heatmaps of the EM violations for Electromigration Analysis.
    Generates Bump location snapshot.
    colormap_style can be one of: (linear,stair_step,stair_step_legacy).
    ''')
    return h

@gp.GpsFuncDoc(_header)
def create_heatmaps(hm_list,design_view,reports_dir,range_in_perc_static = (0,3) ,range_in_perc_dyn = (3,10), em_range = (0,0.7),colormap_style = 'linear'):
    if not os.path.isdir(reports_dir):
        os.mkdir(reports_dir)
    if not os.path.isdir(reports_dir + '/heatmaps/'):
         os.mkdir(reports_dir + '/heatmaps/')
    gui = open_layout_window()
    gui.load(design_view)
    gui.set_layer_attribute(layer_name = "Bumps*",visible = True)
    gui.snapshot(str(reports_dir)+'/heatmaps/'+"Bumps.png")
    gui.set_layer_attribute(layer_name = "Bumps*",visible = False)
    gui.set_layer_attribute(layer_name = "Hier instances",visible = False)
    for each_view in hm_list:

        scn_view = each_view.get_related_views(ScenarioView)[0]
        power_nets = design_view.get_nets('power')
        ideal_voltages = scn_view.get_ideal_voltage_levels()
        for net in power_nets:
            gui.select_net(net, selected = False)
        for net in power_nets:
            if isinstance(each_view,AnalysisView):
                if str(each_view) == "av_static":
                    coolv = ideal_voltages[net]*(1-(range_in_perc_static[0]/100.0))
                    hotv = ideal_voltages[net]*(1-(range_in_perc_static[1]/100.0))
                    gui.select_net(net, selected = True)
                    hm = each_view.get_instance_voltage_heatmap()
                    hm_name = "Instance_Voltage_Drop_"+net.get_name()+'_'+str(each_view.get_view_name())
                    gui.add_layer(hm,hm_name,visible = True)
                    gui.set_layer_colormap(hm_name, coolv = coolv,hotv = hotv, colormap_style = colormap_style,cool_is_black = False)
                    gui.snapshot(str(reports_dir)+'/heatmaps/'+hm_name+".png")
                    gui.remove_layer(hm_name)
                    gui.select_net(net, selected = False)

                if (str(each_view) == 'av_dynamic') or (str(each_view) == 'av_dynamic_pcvs'):
                    coolv = ideal_voltages[net]*(1-(range_in_perc_dyn[0]/100.0))
                    hotv = ideal_voltages[net]*(1-(range_in_perc_dyn[1]/100.0))
                    gui.select_net(net, selected = True)
                    for each_type in ['tw_min','eff_dvd']:
                        hm = each_view.get_instance_voltage_heatmap(data_type = each_type)
                        hm_name = "Instance_Voltage_Drop_"+net.get_name()+'_'+each_type+"_"+str(each_view.get_view_name())
                        gui.add_layer(hm,hm_name,visible = True)
                        gui.set_layer_colormap(hm_name, coolv = coolv,hotv = hotv, colormap_style = colormap_style,cool_is_black = False)
                        gui.snapshot(str(reports_dir)+'/heatmaps/'+hm_name+".png")
                        gui.remove_layer(hm_name)
                    gui.select_net(net, selected = False)

            elif isinstance(each_view,ElectromigrationView):
                hm = each_view.get_violation_heatmap()
                coolv = em_range[0]
                hotv = em_range[1]
                hm_name = "Em_violations_"+str(each_view.get_view_name())
                gui.add_layer(hm,hm_name,visible = True)
                gui.set_layer_colormap(hm_name, coolv = coolv,hotv = hotv, colormap_style = colormap_style)
                gui.snapshot(str(reports_dir)+'/heatmaps/'+hm_name+".png")
                gui.remove_layer(hm_name)

    gui.exit()




def _header():
    h = gp.GpsFunctionHeader('Print Design Statistics')
    h.add('view','the view to use for staistics data gathering', object)

    h.set_details('''
    Print Run Statistics.
    View can be one of: (DesignView, ExtractView, AnalysisView)
    If DesignView is passed the function will print design related info only.
    If ExtractView is passed the function wil also print circuit related statistics.
    If AnalysisView is passed the function will also print Power-Part count.
    ''')
    return h

@gp.GpsFuncDoc(_header)
def print_design_summary(view):
    try :
        dv = view.get_related_views(DesignView)[0].get_related_views(DesignView)[0]
    except IndexError :
        dv = view.get_related_views(DesignView)[0]
    dv_stats = dv.get_stats()
    num_via_instances = dv_stats['num_via_instances']
    num_parts = dv_stats['num_parts']
    num_instances = dv_stats['num_instances']
    gp_print('########### Design Statistics ###########')
    gp_print('Instance Count     : ',str(num_instances))
    gp_print('VIA Instance Count : ',str(num_via_instances))
    gp_print('XT Partition Count : ',str(num_parts))
    if isinstance(view,DesignView):
        pass
    else:
        if isinstance(view,ExtractView):
            ev = view
        else:
            ev = view.get_related_views(ExtractView)[0]
        try :
            ev_stats = ev.get_stats()['total_pg_nets']
            ev_info_avaialbe = True
        except :
            pass
        if ev_info_avaialbe :
            try :
                resistors = ev_stats['resistors']
                nodes = ev_stats['nodes']
                gp_print('EV Node Count      : ',str(nodes))
                gp_print('EV Resistor Count  : ',str(resistors))
            except KeyError :
                pass

        if isinstance(view,AnalysisView):
            av = view
            try :
                num_power_partitions = av_static.get_stats()['num_power_partitions']
                gp_print('Power Part Count   : ',str(num_power_partitions))
            except :
                pass




def _header():
    h = gp.GpsFunctionHeader('Save a ploc file that was used in the design')
    h.add('view','modified design view that has ploc data', gp.DesignView)
    h.add('file_name', 'the name of ploc file that will be saved', str)
    h.set_details('''
    Saves a ploc file of the actual ploc bumps that were used in the design.
    ''')
    return h

@gp.GpsFuncDoc(_header)
def report_plocs_used(view,file_name = './design.ploc'):
    bumps = view.get_package_bumps()
    ploc_str = ""
    if len(bumps) == 0:
        ploc_str = "#Reporting plocs that are read in Design View {0}\n##Ploc_name coordinates Layer_name Net_name\n".format(view.get_view_name())
    for (net,net_bumps) in bumps.items():
        for bump in net_bumps:
            ploc_str += "{0} {1} {2} {3}  {4}\n".format(bump.get('pin'),bump.get('coord').x_,bump.get('coord').y_,bump.get('layer'),net)
    write_to_file(file_name,ploc_str)



def _header():
    h = gp.GpsFunctionHeader('calcualte SPR path for instance with worst ground bounce and instance with worst drop')
    h.add('av','Analysis View to be used', gp.AnalysisView)
    h.add('file_name', 'the file name for the report', str)
    h.set_details('''
    Generating an SPR report for the insatnces with the worst Ground Bounce and the worst Drop.
    ''')
    return h

@gp.GpsFuncDoc(_header)
def inst_spr(av,file_name='./worst_spr.rpt'):
    stats = av.get_info()
    inst_bounce = stats['worst_bounce']['instance']
    inst_drop = stats['worst_drop']['instance']
    instances = list()
    instances.append(('Worst Ground Bounce Insatnce ', inst_bounce))
    instances.append(('Worst Drop Insatnce ',inst_drop))
    ev = av.get_related_views(ExtractView)[0]
    fp = open(file_name,'w')
    for (tag,inst) in instances :
        fp.write('#### Doing Spr for : ' + tag +', Instance: '+inst.get_name()+'###\n\n')
        spr = ev.get_shortest_resistance_path(instance=inst,analysis_view=av, voltage_report_type='worst').values()
        for pin in spr :
            fp.write(str(pin))
        fp.write('----------------------------------------------------------------------------------------\n\n')
    fp.close()




###
# Filter Functions that are used for insatnce voltage drop report to
# generate clock only instance report and non-clock insatnce report
###
def non_clocks_filter(instance,pgarc,data_dict,scn):
    try :
        clock_instance = scn.get_attributes(instance)['logic']['clock_instance']
        if clock_instance == False:
            return False
        else:
            return True

    except KeyError:
        return True

def clocks_filter(instance,pgarc,data_dict,scn):
    try :
        clock_instance = scn.get_attributes(instance)['logic']['clock_instance']
        if clock_instance == True:
            return False
        else:
            return True

    except KeyError:
        return True


###


### Custom script for Aggressor Load-Cap Heatmap ###

def _map_aggv_load_cap_part(parts, scn, ihm, agg_hm, dv):
    part_id = dv.get_partition_id(parts)
    hm_partial_data = agg_hm.get_partial_data(part_id)
    items = list()
    rvs = hm_partial_data.get_rects_and_values()
    if not rvs:
        return {}

    for rv in rvs:
        if not rv:
            continue
        trap = rv.get_trap()
        inst_id = trap.get_instance_id()
        inst = Instance(inst_id)
        dv_attr = dv.get_attributes(dv.get_attributes(inst)['cell'])['type']
        if dv_attr.is_filler_cell() or dv_attr.is_decap_cell():
            continue
        attr = scn.get_attributes(inst, max_output_pins = None)

        try:
            pin_data = attr['logic']['output_pins']
        except KeyError:
            gp_print('instance without output pins: ', dv.convert_to_name(inst))
            continue
        load_cap = 0
        count = 0
        for kk in pin_data.keys():
            load_cap += pin_data[kk]['load_cap']
            count += 1
        load_cap = load_cap / count
        items.append((inst, load_cap))
    ihm.add_partial_data(part_id, items = items)
    return {'ihm' : ihm}


def _header():
    h = gp.GpsFunctionHeader('create aggresor load-cap HM')
    h.add('aggv', 'aggresor view', thpkgs_internal.voltage_impact.DvdAggressorView)
    h.add('av', 'analysis view related to the aggressor view', gp.AnalysisView)
    h.add('db', 'the db to save the custom HM in', gp.SeaScapeDB)
    h.set_details('''
    Create a custom HM of load-caps that related to all the aggresors found in the aggresor view. ''')
    return h

@gp.GpsFuncDoc(_header)
def agg_load_cap(aggv, av, db ):
    dv = av.get_related_views(DesignView)[0]
    scn = av.get_related_views(ScenarioView)[0]
    agg_hm = aggv.get_aggressor_heatmap()
    ihm = InstanceHeatmapPart(dv)
    mm = MapReduce(dv)
    mm.map_reduce(dv.get_mr_partitions(), partial(_map_aggv_load_cap_part, scn = scn, ihm = ihm, agg_hm = agg_hm, dv = dv), finalize_data = mr_finalize_dict)
    hm = mm.get()['ihm']
    uv = db.create_user_view(tag = 'custom_hm')
    uv['aggv_load_cap_hm'] = hm
    win = LayoutWindow.get_windows()
    for window in win:
        if window.is_ready():
            window.add_layer(hm, 'agg_load_cap')







@sch_func
def job_gen_em_hist(em_view, nv, file_name, comments, step, start ,end) :
    v_hist = dict()
    v_hist['metal'] = dict()
    v_hist['via']   = dict()
    v_hist['total'] = dict()
    for x in range(start, end, step):
        v_hist['metal'][x] = 0
        v_hist['via'][x]   = 0
        v_hist['total'][x] = 0
    c_layer = nv.get_conductor_layer_names()
    v_layer = nv.get_via_layer_names()
    hist = em_view.get_violation_histograms()

    try :
        del hist['total']
    except KeyError :
        pass

    for net in hist.keys() :
        try :
            del hist[net]['total']
            del hist[net]['__ground']
        except KeyError :
            pass

        for x in range(start, end, step) :
            for layer in hist[net].keys():
                list_of_tuples = hist[net][layer].get_waveform()
                for y in list_of_tuples:
                    if x <= y[0]*100 and y[0]*100 < x+step :
                        if layer in c_layer :
                            v_hist['metal'][x] += y[1]
                            v_hist['total'][x] += y[1]
                        elif layer in v_layer :
                            v_hist['via'][x]   += y[1]
                            v_hist['total'][x] += y[1]

    fp = open(file_name+'.dat','w')
    header='Violation_over_%  metal_count     via_count       total'
    fp.write("# "+comments+'\n')
    fp.write('# '+header+'\n')
    fmtString = "%5.3f\t%15d\t%15d\t%15d"
    for x in range(start, end, step) :
        vals = (x,v_hist['metal'][x],v_hist['via'][x] ,v_hist['total'][x] )
        fmtLine = fmtString % vals
        fp.write(fmtLine+'\n')
    fp.close()
    return v_hist




def _header():
    h = gp.GpsFunctionHeader('Generate EM histograms dict and dat file of vias, metals and total')
    h.add('em_view', 'EM view for analysis', gp.ElectromigrationView)
    h.add('file_name','name of the hist dat file',str, none_ok=True)
    h.add('comments','comments at the top of the file', str, none_ok = True)
    h.add('step','bin step',int,none_ok = True)
    h.add('start','starting bin of the histogram',int, none_ok = True)
    h.add('end','ending bin of the histogram',int, none_ok = True)
    h.add('x_label', 'X axis label', str, none_ok = True)
    h.add('y_label','Y axis label', str, none_ok = True)
    h.add('threshold','EM hist pass\fail threshold', int, none_ok = True)
    h.add('num_bins','number of histogram bins', int, none_ok = True)
    h.add('title','Histogram title', str, none_ok = True)
    h.set_details('''
    Generates a data file wih histogram details and save the total EM pass\fail Histogram.
    ''')
    return h



@gp.GpsFuncDoc(_header)
def gen_em_hist(em_view, file_name='./em_hist',comments='EM violations histograms', step=10, start=70 ,end =200, x_label = '%', y_label='count', threshold = 100, num_bins = 20, title = None):
    nv = em_view.get_related_views(TechView)[0]
    hist = em_view.get_violation_histograms()
    plot_hist(hist['total'],range= (start,end) , y_label=y_label, threshold = threshold, num_bins = num_bins, title = title, file_name = file_name, is_em = True)
    hist_dict = job_gen_em_hist(em_view, nv, file_name, comments, step,start,end)


def plot_hist(hist, range,  x_label = '%', y_label='count', threshold = 100, num_bins = 20, title = None,file_name ='./hist', is_em = False ):
    tup_list = hist.get_waveform()
    values = list()
    weights = list()
    for x in tup_list:
        if is_em:
            values.append(x[0]*100)
        else:
            values.append(x[0]*1000)
        weights.append(x[1])
    bin_contents_t,bin_ends_t,patches_t = plt.hist(values,edgecolor='black', linewidth=0.5,weights=weights,bins=num_bins,range=range, log = True)
    plt.title(title)
    plt.grid('on')
    plt.xlabel(x_label)
    plt.ylabel(y_label)
    count = 0
    for p in patches_t :
        if bin_ends_t[count] > threshold :
            if is_em:
                plt.setp(p,'facecolor','r')
            else:
                plt.setp(p, 'facecolor', 'g')
        else :
            if is_em:
                plt.setp(p, 'facecolor', 'g')
            else:
                plt.setp(p,'facecolor','r')
        count +=1

    plt.savefig(file_name+'.png')
    plt.close()

def _get_macros_instances(instances, dv):
    out = list()
    for instance in instances:
        cell = dv.get_attributes(instance)['cell']
        celltype= dv.get_attributes(cell)['type']
        if celltype.is_lib_macro_cell():
            if cell in out:
                continue
            has_lib = False
            has_avm = False
            for i in dv.get_liberty_attributes(cell)['default_process'][0]['files']:
                if 'avm' in i:
                    has_avm = True

                if 'lib' in i:
                    has_lib = True

            if (has_lib) and (not has_avm):
                out.append(cell)
    return out

def _header():
    h = gp.GpsFunctionHeader('Get a list of Macros with missing AVM files')
    h.add('dv','Design View to be used', gp.DesignView)
    h.add('path','specify where you want the report to be saved, default is current location', str)
    h.set_details('''
    Report all Macros with missing AVM, and prints it to the log. example report:
    #Cell Type	    Cell Name
    Macro	pmro_wrapper
    Macro	ts_7ff_tcam_111_hs_f_t_sul_gl_1024x148x1_pbn
    Macro	ts_7ff_tcam_111_hs_f_t_sul_gl_1024x74x1_pbn
    ''')
    return h

@gp.GpsFuncDoc(_header)
def get_missing_avm(dv, path = './missing_avm.rpt'):
    mm = MapReduce(dv)
    mm.map_reduce(dv.get_mr_instances(), partial(_get_macros_instances, dv=dv))
    data = mm.get()
    data = list(set(data))
    with open(path,'w') as f:
        writer = csv.writer(f, delimiter = '\t')
        writer.writerow(['### List of Macros with missing AVMs ###'])
        writer.writerow(['#Cell Type', 'Cell Name'])
        for elem in data:
            gp_print('avms are missing for cell '+repr(dv.convert_to_name(elem)))
            writer.writerows(zip(['Macro'],[dv.convert_to_name(elem)]))
    f.close()
    return dv.convert_to_name(data)


@sch_func
def make_ipf(orig_ipf, new_ipf,  TR = 0.3,):
    fp_new = open(new_ipf,"w")
    fp = open(orig_ipf,"r")
    lines = fp.readlines()
    for line in lines:
        words = line.split(" ")
        if (words[0] != "#") and (words[1] != 'VBP') and (float(words[3]) < TR) :
            words[3] = str(TR)
        fp_new.write(words[0] + " " + words[1] + " " + words[2] + " " + words[3] + " " + words[4] + " " + words[5] + " " + words[6] + " " + words[7] + " " + words[8] + "\n")
    fp_new.close()
    fp.close()
    gp_print('new ipf with a minimum toggle_rate of ' + str(TR) +' has been created at location: ' + new_ipf)

lib_files_custom = [
  '../scripts/rhsc/pgarc_lib'
]

def_files = [
  'DEF_FILE',
]

design_ecos = [
  {'cell':'*FILLER*','trim_type':'cell'},
  {'cell':'*BORDER*','trim_type':'cell'},
  {'cell':'*TIELO*','trim_type':'all'},
  {'cell':'*TIEHI*','trim_type':'all'},
  {'instance':'*spr_gate*','trim_type':'instance'},
]

tw_files = [{'instance_name': '', 'file_name': 'TIMING_WINDOW_FILES', 'transition_time_policy' : 'max'}]

tech_file='TECH_APACHE'

gpd_dirs = [{'dir_name':'GPD_DIR', 'cell_name':'DESIGN_NAME', 'selected_corners':'SELECTED_CORNERS'}]

# load values for output ports
sdc_files = [
  {'file_name' : 'output_loads.sdc', 'capacitance_unit': 1e-12},
]

bsub_cmd = 'bsub -q large -n 2 -R span\[hosts\=1\] -R rusage\[mem\=32768\] -oo ../logs/sc.run.lsf.out -eo ../logs/sc.run.lsf.err'
workers_per_launch = 2
sigem_db = './sigem_db'
rename_pg_nets = []
voltage_levels = {
                'VDD':0.88,
                'VSS':0,
                'AVDD':1.65,
                'AVSS':0,
                'VDDH':1.65,
                'GND':0,
                'AVDDH_VTMON':1.65,
                'VDDQ_EFUSE':1.98,
                'AVDDH_CORE_PLL':1.65,
                'AVSS_CORE_PLL':0,
                'AVDD_PCIE':0.88,
                'AVSS_PCIE':0,
                'PLL_VDD_PCIE0':1.98,
                'AVSS_PLL_PCIE0':0.0,
                'PLL_VDD_PCIE1':1.98,
                'AVSS_PLL_PCIE1':0.0,
                'AVDD_HCSL':0.825,
                'VDDH_LVCMOS':1.65,
                'EDM_VDD':0.913,
                'EDM_VSS':0,
                 }
focus_pg_nets = [
                'VDD',
                'VSS',
                'AVDD',
                'AVSS',
                'VDDH',
                'GND',
                'AVDDH_VTMON',
                'VDDQ_EFUSE',
                'AVDDH_CORE_PLL',
                'AVSS_CORE_PLL',
                'AVDD_PCIE',
                'AVSS_PCIE',
                'PLL_VDD_PCIE0',
                'AVSS_PLL_PCIE0',
                'PLL_VDD_PCIE1',
                'AVSS_PLL_PCIE1',
                'AVDD_HCSL',
                'VDDH_LVCMOS',
                'EDM_VDD',
                'EDM_VSS',
                ]
block_name = 'DESIGN_NAME'
actroot = '/project/apd_nxt009/tools/act'
rpt_dir = 'reports'
default_period = 20e-9
default_freq = 1/default_period
data_toggle_rate = 1.0
clock_toggle_rate = 2.0
default_transition_time = 150e-12
extract_temp = 105
pwr_temp = 105
em_temp = 105.74
# Global variables for reporting
try:
  MAXINT = sys.maxint
except:
  MAXINT = sys.maxsize
design_name = 'DESIGN_NAME'
viaAreaX = 0.646
viaAreaY = 0.210
viaAreaKFE = 0.2068
viaAreaKctr = 0.2157
viaAreaKxm = 0.1961
viaAreaKxp = 0.1961
viaAreaKym = 0.1961
viaAreaKyp = 0.1961
instAF = 0.15


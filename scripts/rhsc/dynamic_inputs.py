lib_files_custom = [
  '../scripts/rhsc/pgarc_lib'
]

def_files = [
  'DEF_FILE',
]

design_ecos = [
  {'cell':'*FILLER*','trim_type':'cell'},
  {'cell':'*BORDER*','trim_type':'cell'},
  {'cell':'*DIODE*','trim_type':'cell'},
  {'cell':'*TIELO*','trim_type':'all'},
  {'cell':'*TIEHI*','trim_type':'all'},
  {'instance':'*spr_gate*','trim_type':'instance'},
]

th_ploc = 'PLOC_FILE'

tw_files = [{'instance_name': '', 'file_name': 'TIMING_WINDOW_FILES', 'slew_type' : 'Max'}]

tech_file='TECH_APACHE'


gpd_dirs = [{'dir_name':'GPD_DIR', 'cell_name':'DESIGN_NAME', 'selected_corners':'SELECTED_CORNERS'}]


bsub_cmd = 'bsub -q large -n 2 -R span\[hosts\=1\] -R rusage\[mem\=32768\] -oo ../logs/sc.run.lsf.out -eo ../logs/sc.run.lsf.err'
workers_per_launch = 2
rename_pg_nets = []
voltage_levels = {
                'VDD':0.7125,
                'VSS':0,
                'AVDD':1.425,
                'AVSS':0,
                'VDDH':1.425,
                'GND':0,
                'AVDDH_VTMON':1.425,
                'VDDQ_EFUSE':1.71,
                'AVDDH_CORE_PLL':1.425,
                'AVSS_CORE_PLL':0,
                'AVDD_PCIE':0.76,
                'AVSS_PCIE':0,
                'PLL_VDD_PCIE0':1.71,
                'AVSS_PLL_PCIE0':0.0,
                'PLL_VDD_PCIE1':1.71,
                'AVSS_PLL_PCIE1':0.0,
                'AVDD_HCSL':0.712,
                'VDDH_LVCMOS':1.425,
                'EDM_VDD':0.789,
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
rpt_dir = '/project/apd_nxt009_blk0/giant/giant-2022.4.1/user/nikumar/PN85.5.1.dft.22Jun2022/impl/cbui_top/avo/power/redhawk_sc_dynamic/rpts'
default_period = 6.250e-10
data_toggle_rate = COMBINATIONAL_TOGGLE
clock_toggle_rate = 2.0
sim_time = 10 * default_period
extract_temp = 105
pwr_temp = 105

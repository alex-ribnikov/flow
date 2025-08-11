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

# spef_files = [
#   {'file_name' : '/project/apd_nxt009/xfers/in/20220914/tcu_top/spef/tcu_top.chip_finish.spef.rc_wc_cc_wc_T_125.gz', 'cell_name' : 'tcu_top'},
# ]

bsub_cmd = 'bsub -q large -n 2 -R span\[hosts\=1\] -R rusage\[mem\=32768\] -oo ../logs/sc.run.lsf.out -eo ../logs/sc.run.lsf.err'
workers_per_launch = 2
rename_pg_nets = []
voltage_levels = {
                'VDD':0.7875,
                'VSS':0,
                'AVDD':1.575,
                'AVSS':0,
                'VDDH':1.575,
                'GND':0,
                'AVDDH_VTMON':1.575,
                'VDDQ_EFUSE':1.89,
                'AVDDH_CORE_PLL':1.575,
                'AVSS_CORE_PLL':0,
                'AVDD_PCIE':0.84,
                'AVSS_PCIE':0,
                'PLL_VDD_PCIE0':1.89,
                'AVSS_PLL_PCIE0':0.0,
                'PLL_VDD_PCIE1':1.89,
                'AVSS_PLL_PCIE1':0.0,
                'AVDD_HCSL':0.788,
                'VDDH_LVCMOS':1.575,
                'EDM_VDD':0.871,
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
rpt_dir = '/project/apd_nxt009_blk0/giant/giant-2022.4.2/user/nikumar/PN85.6.redhawk.exps/impl/tcu_top/avo/power/redhawk_sc_static.customer_def/rpts'
default_period = 6.250e-10
data_toggle_rate = COMBINATIONAL_TOGGLE
clock_toggle_rate = 2.0
extract_temp = 105
pwr_temp = 105
em_temp = 105.74

set cur_path [pwd]
set tCIC_dir "${cur_path}/scripts/innovus/tCIC"

source "${tCIC_dir}/tCIC_macro_usage_manager_N5_General_v1d1_0_2a_Official_12252020.tcl"
source "${tCIC_dir}/tCIC_set_cip_variables_N5_General_v1d1_0_2a_Official_12252020.tcl"

#set this option on top design
#tCIC_set_fullchip_mode 1

#set desgin cell type (Supported Cell Type H210P51/H280P57, default is H210P51)
tCIC_set_design_cell_type H210P51

#set this option to trun on FG112 check (Only work when design is H210P51 block)
#tCIC_set_FG112_mode 1

#set this option to turn on Boundary-Controlled Block check
tCIC_set_boundary_controlled_block_mode 1

#set this option to turn on P76 track alignment 
tCIC_set_align_p76_track_mode 1

#set this option alter boundary cell type
#tCIC_set_boundary_cell_style CW

#set this option alter boundary row cell type (Only work when design is H280P57 block)
#tCIC_set_boundary_row_cell_style NROW

#set Top My layer, to decide max routing blockage layer around DTCD/ICOVL, default =10
#tCIC_set_max_DTCD_layer 10

#report all optional setting 
tCIC_report_optional_setting

#reset macro type
tCIC_reset_macro_usage

#set macro types here
#example for internal testing
tCIC_specify_macro_usage -usage TSMC_SRAM_POR -macro [list ]
tCIC_specify_macro_usage -usage TSMC_SRAM_FP -macro [list ]
tCIC_specify_macro_usage -usage TSMC_ROM -macro [list ]
tCIC_specify_macro_usage -usage TSMC_SRAM_P2 -macro [list  ]
tCIC_specify_macro_usage -usage APR_BLOCK_H210P51_FG28 -macro [list ]
tCIC_specify_macro_usage -usage APR_BLOCK_H210P51_FG112 -macro [list ]
tCIC_specify_macro_usage -usage APR_BLOCK_H210P51_FG28_BC -macro [list ]
tCIC_specify_macro_usage -usage APR_BLOCK_H210P51_FG112_BC -macro [list ]
tCIC_specify_macro_usage -usage APR_BLOCK_H280P57 -macro [list ]
tCIC_specify_macro_usage -usage APR_BLOCK_H280P57_BC -macro [list ]
tCIC_specify_macro_usage -usage MACRO_EFUSE -macro [list ]
tCIC_specify_macro_usage -usage MACRO_ESD_C1 -macro [list ]
tCIC_specify_macro_usage -usage MACRO_ESD_C2 -macro [list ]
tCIC_specify_macro_usage -usage MACRO_ESD_C3 -macro [list ]
tCIC_specify_macro_usage -usage MACRO_BEOL_ONLY -macro [list ]
tCIC_specify_macro_usage -usage MACRO_FG112 -macro [list ]
tCIC_specify_macro_usage -usage DTCD -macro [list ]
tCIC_specify_macro_usage -usage ICOVL -macro [list ]
tCIC_specify_macro_usage -usage ICOVL_2 -macro [list ]
tCIC_specify_macro_usage -usage CUSTOMIZE_IP1 -macro [list sacrls0g4s2p128x136m1b2w0c0p0d0r1rm4rw10zh1h0ms0mg1 sacrls0g4s2p160x132m2b2w0c1p0d0r1rm4rw10zh1h0ms0mg1 saduls0g4s1p3136x156m8b2w0c1p0d0r2rm4rw11e18zh1h0ms0mg1]
tCIC_specify_macro_usage -usage CUSTOMIZE_IP2 -macro [list ]
tCIC_specify_macro_usage -usage CUSTOMIZE_IP3 -macro [list ]
tCIC_specify_macro_usage -usage CUSTOMIZE_IP4 -macro [list ]
tCIC_specify_macro_usage -usage CUSTOMIZE_IP5 -macro [list ]

#report macro usage
tCIC_report_macro_usage

#Check tCIC violation
convert_tCIC_to_ufc -input_files "${tCIC_dir}/tCIC_description_N5_General_v1d1_0_2a_Official_12252020.tcl ${tCIC_dir}/tCIC_N5_General_v1d1_0_2a_Official_12252020.tcl" -ufc_file "${tCIC_dir}/tcic.ufc"
check_ufc "${tCIC_dir}/tcic.ufc" -report_file "${tCIC_dir}/tcic.rpt"

# Fix tCIC violations
fix_floorplan -file "${tCIC_dir}/tCIC_description_N5_General_v1d1_0_2a_Official_12252020.tcl ${tCIC_dir}/tCIC_N5_General_v1d1_0_2a_Official_12252020.tcl" -type tcic


import os
import datetime
import csv
import datetime
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.dialects.postgresql import DATERANGE
from sqlalchemy import create_engine, MetaData, Table, Column, String, Float, Integer, select, text, ForeignKey, UniqueConstraint, PrimaryKeyConstraint, DateTime, update, inspect
from sqlalchemy.orm import relationship
from sqlalchemy.exc import IntegrityError, ProgrammingError
from tenacity import retry, stop_after_attempt, wait_fixed
import time
from sqlalchemy.engine import reflection




# SUMMARY - 52
csv_headers_summary = {'Date': 'date|Date', 'Time': 'time|Time', 'Block_name': 'block_name|String', 'Source': 'source|String',\
            'Version': 'version|String', 'Run': 'run|String', 'stage': 'stage|String', 'X(um)': 'xum|Float',\
            'Y(um)': 'yum|Float', 'Area': 'area|Float', 'Leaf_Cell_Area': 'leaf_cell_area|Float',\
            'Utilization': 'util_percent|Float', 'Cell_count': 'cell_count|Integer', 'Buf/inv': 'buf_inv|Integer',\
            'Logic': 'logic|Integer', 'Flops': 'flops|Integer', 'Bits': 'bits|Integer', 'Removed_seq': 'removed_seq|Integer',\
            'num_of_ports': 'num_of_ports|Integer', '%svt': 'svt_percent|Float', '%lvtll': 'lvtll_percent|Float',\
            '%lvt': 'lvt_percent|Float', '%ulvtll': 'ulvtll_percent|Float', '%ulvt': 'ulvt_percent|Float', '%en': 'en_percent|Float', 'internal': 'internal|Float',\
            'switching': 'switching|Float', 'dynamic': 'dynamic|Float', 'leakage': 'leakage|Float', 'total': 'total|Float', 'Bank_ratio': 'bank_ratio|Float',\
            '2_mulibit': 'two_mulibit|Float', '4_mulibit': 'four_mulibit|Float', '6_multibit': 'six_mulibit|Float', '8_mulibit': 'height_mulibit|Float',\
            'Total WNS(ps)': 'total_wns_ps|Float', 'Total TNS(ps)': 'total_tns_ps|Float',\
            'Total FEP': 'total_fep|Float', 'R2R WNS(ps)': 'r2r_wns_ps|Float', 'R2R TNS(ps)': 'r2r_tns_ps|Float', 'R2R FEP': 'r2r_fep|Float',\
            'Hold WNS(ns)': 'hold_wns_ps|Float', 'Hold TNS(ps)': 'hold_tns_ps|Float', 'Hold FEP': 'hold_fep|Float', 'V': 'v_percent|Float', 'H': 'h_percent|Float',\
            'num_of_shorts': 'num_of_shorts_percent|Float','DRC_Total': 'drc_total|Float', 'Run_time': 'run_time|Duration', 'CPU': 'cpu_requested|Float',\
            'Mem': 'memory_requested|Float', 'Comment': 'comment|String'}


# GENERAL
csv_headers_general = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'PROJECT': 'project|String', 'Block_Name': 'block_name|String', \
            'STAGE': 'stage|String', 'scripts_version': 'scripts_version|String', 'files_under_scripts_local': 'files_under_scripts_local|String',\
            'files_under_scripts_local_input': 'files_under_scripts_local_input|String', 'compare_user_inputs_2_default_setting': 'compare_user_inputs_2_default_setting|String',\
            'compare_user_inputs_2_default_setting_input': 'compare_user_inputs_2_default_setting_input|String', 'link_to_RTL_files': 'link_to_rtl_files|String',\
            'Calculate_MEMs_BITs': 'calculate_mems_bits|String', 'bonus_cells': 'bonus_cells|String'}

# FLOORPLANE
csv_headers_compile = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'Block_Name': 'block_name|String', 'STAGE': 'stage|String', 'Host_name': 'host_name|String','PROJECT': 'project|String', 'fusion_version': 'fusion_version|String',\
                      'EFFORT': 'effort|String', 'VT_EFFORT': 'vt_effort|String', \
                       'Calculate_MEMs_BITs': 'calculate_mems_bits|Integer', 'Calculate_the_number_of_transistors': 'calculate_the_number_of_transistors|Integer', 'cell_density': 'cell_density|Float', 'HotSpot_Score': 'hotspot_score|Float',\
                       'HotSpot_Score_input': 'hotspot_score_input|String', 'congestion_H': 'congestion_h|Float', 'congestion_V': 'congestion_v|Float', 'Total_Internal_Power': 'total_internal_power|Integer', 'Total_Switching_Power': 'total_switching_power|Integer',\
                       'Total_Leakage_Power': 'total_leakage_power|Float', 'Total_Power': 'total_power|Float', 'Leaf_Cell_Count': 'leaf_cell_count|Integer', 'FF_Bit_Count': 'ff_bit_count|Integer', 'Gated_registers': 'gated_registers|Integer', 'Ungated_registers': 'ungated_registers|Integer',\
                       'ICG_count': 'icg_count|Integer', 'Leaf_Cell_Area': 'leaf_cell_area|Float', 'LVT_cells': 'lvt_cells|Float', 'LVTLL_cells': 'lvtll_cells|Float', 'ULVT_cells': 'ulvt_cells|Float', 'ULVTLL_cells': 'ulvtll_cells|Integer',\
                       'EVT_cells': 'evt_cells|Integer', 'LVT_area': 'lvt_area|Integer', 'LVTLL_area': 'lvtll_area|Integer', 'ULVT_area': 'ulvt_area|Integer', 'ULVTLL_area': 'ulvtll_area|Float', 'EVT_area': 'evt_area|Float', 'Multibit_Conversion': 'multibit_conversion|Float',\
                       'reg2reg_wns': 'reg2reg_wns|Float', 'reg2reg_tns': 'reg2reg_tns|Float', 'reg2reg_vp': 'reg2reg_vp|Float', 'reg2out_wns': 'reg2out_wns|Float', 'reg2out_tns': 'reg2out_tns|Float', 'reg2out_vp': 'reg2out_vp|Float', 'in2reg_wns': 'in2reg_wns|Float',\
                       'in2reg_tns': 'in2reg_tns|Float', 'in2reg_vp': 'in2reg_vp|Float', 'in2out_wns': 'in2out_wns|Float', 'in2out_tns': 'in2out_tns|Float', 'in2out_vp': 'in2out_vp|Float', 'all_wns': 'all_wns|Float', 'all_tns': 'all_tns|Float', 'all_vp': 'all_vp|Float',\
                       'Total_IO_buffers': 'total_io_buffers|Float', 'Total_IO_buffers_input': 'total_io_buffers_input|String', 'log_Error_Messages': 'log_error_messages|Integer', 'log_Warning_Messages': 'log_warning_messages|Integer'}


csv_headers_fp = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'Block_Name': 'block_name|String', 'STAGE': 'stage|String', 'PROJECT': 'project|String', 'check_floorplan_warnings': 'check_floorplan_warnings|Integer',\
                    'check_floorplan_errors': 'check_floorplan_errors|Integer', 'Leaf_Instance_count': 'leaf_instance_count|Integer', 'Sequential_Cells_Count_NO_CG': 'sequential_cells_count_no_cg|Integer'}


csv_headers_place = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'Block_Name': 'block_name|String', 'STAGE': 'stage|String', 'PROJECT': 'project|String', 'Host_name': 'host_name|String', 'fusion_version': 'fusion_version|String', 'EFFORT': 'effort|String', 'VT_EFFORT': 'vt_effort|String', 'Total_IO_buffers': 'total_io_buffers|Integer', \
                    'HotSpot_Score_input': 'hotspot_score_input|String',  'Total_IO_buffers_input': 'total_io_buffers_input|String', 'Max_distance_IO_buffers_to_ports[um]': 'max_distance_io_buffers_to_ports_um|Float', 'Max_distance_IO_buffers_to_ports_input': 'max_distance_io_buffers_to_ports_input|String', 'IO_Sampled_BY_MB': 'io_sampled_by_mb|Integer',\
                     'IO_Sampled_BY_MB_input': 'io_sampled_by_mb_input|String', 'IO_Buffers_driving_ports_violations': 'io_buffers_driving_ports_violations|Integer', 'IO_Buffers_driving_ports_violations_input': 'io_buffers_driving_ports_violations_input|String', 'HotSpot_Score': 'hotspot_score|Float',\
		 'ABO_CELL': 'abo_cell|Integer', 'AINV_P': 'ainv_p|Integer', 'APSBUF': 'apsbuf|Integer', 'APSHOLD': 'apshold|Integer', 'APSLS': 'apsls|Integer', 'BINV_P': 'binv_p|Integer', 'BINV_R': 'binv_r|Integer', 'BINV_RR': 'binv_rr|Integer', 'Buf': 'buf|Integer', 'BUFT_GROPTO': 'buft_gropto|Integer', 'BUFT_L': 'buft_l|Integer', 'BUFT_P': 'buft_p|Integer', 'BUFT_RR': 'buft_rr|Integer', 'copt_d_inst': 'copt_d_inst|Integer', 'copt_h_inst': 'copt_h_inst|Integer', 'ctmi': 'ctmi|Integer', 'ctmTdsLR': 'ctmtdslr|Integer', 'congi': 'congi|Integer', 'gre_a': 'gre_a|Integer', 'gre_d': 'gre_d|Integer', 'gre_h': 'gre_h|Integer', 'gre_mt': 'gre_mt|Integer', 'grfo_d': 'grfo_d|Integer', 'grfo_h': 'grfo_h|Integer',\
		 'grfo_inst': 'grfo_inst|Integer', 'grfo_mt': 'grfo_mt|Integer', 'HFSBUF': 'hfsbuf|Integer', 'HFSINV': 'hfsinv|Integer', 'phfnr_buf': 'phfnr_buf|Integer', 'popt_d_inst': 'popt_d_inst|Integer', 'SGI': 'sgi|Integer', 'ZBUF': 'zbuf|Integer', 'Z_gre_BUF': 'z_gre_buf|Integer', 'Z_gre_INV': 'z_gre_inv|Integer', 'Z_gre_BUF_f': 'z_gre_buf_f|Integer', 'Z_gre_INV_f': 'z_gre_inv_f|Integer', 'ZINV': 'zinv|Integer', 'ABUF_PR': 'abuf_pr|Integer', 'AINV_PR': 'ainv_pr|Integer', 'APS_CLK_ISO': 'aps_clk_iso|Integer', 'APS_FTB': 'aps_ftb|Integer', 'APS_PI': 'aps_pi|Integer', 'APS_TDBUF': 'aps_tdbuf|Integer', 'BINV_S': 'binv_s|Integer', 'BUFT_S': 'buft_s|Integer', 'FTB': 'ftb|Integer', 'MPN_BUF': 'mpn_buf|Integer', 'MVISOL': 'mvisol|Integer', 'MV_RESTRICTION': 'mv_restriction|Integer',\
 		'PI': 'pi|Integer', 'PIOLD': 'piold|Integer', 'pmd': 'pmd|Integer', 'RBBUF': 'rbbuf|Integer', 'RBINV': 'rbinv|Integer', 'RLB': 'rlb|Integer', 'buf_drc_cln': 'buf_drc_cln|Integer', 'clk_drv_r': 'clk_drv_r|Integer', 'cto_buf': 'cto_buf|Integer', 'cto_buf_cln': 'cto_buf_cln|Integer', 'cto_buf_drc': 'cto_buf_drc|Integer', 'cto_dtrdly': 'cto_dtrdly|Integer', 'cto_inv': 'cto_inv|Integer', 'cto_inv_cln': 'cto_inv_cln|Integer', 'cto_inv_drc': 'cto_inv_drc|Integer', 'cto_st': 'cto_st|Integer',\
		 'ctosc*asb': 'ctosc_asb|Integer', 'ctosc_drc_inst': 'ctosc_drc_inst|Integer', 'ctosc_gls_inst': 'ctosc_gls_inst|Integer', 'ctosc_inst': 'ctosc_inst|Integer', 'cts_buf': 'cts_buf|Integer', 'ctsctobgt_ht': 'ctsctobgt_ht|Integer', 'ctsctobgt_st': 'ctsctobgt_st|Integer', 'ctsctobgt_sw': 'ctsctobgt_sw|Integer', 'cts_dlydt': 'cts_dlydt|Integer', 'cts_inv': 'cts_inv|Integer', 'CTS_MCSB': 'cts_mcsb|Integer', 'cts_trgdly': 'cts_trgdly|Integer',\
 		'dly_icdb_inst': 'dly_icdb_inst|Integer', 'dly_inst': 'dly_inst|Integer', 'dly_mcsb_inst': 'dly_mcsb_inst|Integer', 'dly_trglat_inst': 'dly_trglat_inst|Integer', 'ICDB': 'icdb|Integer', 'inv_drc_cln': 'inv_drc_cln|Integer', 'msgts_l': 'msgts_l|Integer', 'sbcto_ht': 'sbcto_ht|Integer', 'sbcto_st': 'sbcto_st|Integer', 'sbcto_sw': 'sbcto_sw|Integer', 'ugs': 'ugs|Integer', 'ZCTSBUF': 'zctsbuf|Integer', 'ZCTSINV': 'zctsinv|Integer', 'ctsiso_split': 'ctsiso_split|Integer',\
		 'bdp': 'bdp|Integer', 'BDP': 'bdpp|Integer', 'bcg': 'bcg|Integer', 'bip': 'bip|Integer', 'biso': 'biso|Integer', 'btd': 'btd|Integer', 'vcg': 'vcg|Integer', 'vdp': 'vdp|Integer', 'vip': 'vip|Integer', 'viso': 'viso|Integer', 'vtd': 'vtd|Integer', 'ropt_d_inst': 'ropt_d_inst|Integer', 'ropt_h_inst': 'ropt_h_inst|Integer', 'ropt_mt_inst': 'ropt_mt_inst|Integer', 'ropt_inst': 'ropt_inst|Integer', 'ccd_drc': 'ccd_drc|Integer', 'ccd_hold': 'ccd_hold|Integer', 'ccd_setup': 'ccd_setup|Integer', 'ctobgt_inst': 'ctobgt_inst|Integer', 'optlc': 'optlc|Integer', 'u/U': 'u_u|Integer',\
		 'cell_density': 'cell_density|String',\
      'congestion_H': 'congestion_h|String', 'congestion_V': 'congestion_v|String', 'Total_Internal_Power': 'total_internal_power|String', 'Total_Switching_Power': 'total_switching_power|Float', 'Total_Leakage_Power': 'total_leakage_power|Float', 'Total_Power': 'total_power|Float', 'Leaf_Cell_Count': 'leaf_cell_count|Float', 'FF_Bit_Count': 'ff_bit_count|Float', 'ICG_count': 'icg_count|Float', \
                     'Leaf_Cell_Area': 'leaf_cell_area|Float', 'LVT_cells': 'lvt_cells|Float', 'LVTLL_cells': 'lvttl_cells|Float', 'ULVT_cells': 'ulvt_cells|Float', 'ULVTLL_cells': 'ulvtll_cells|Float', 'EVT_cells': 'evt_cells|Float', 'LVT_area': 'lvt_area|Float', 'LVTLL_area': 'lvtll_area|Float', 'ULVT_area': 'ulvt_area|Float', 'ULVTLL_area': 'ulvtll_area|Float', 'EVT_area': 'evt_area|Float', 'Multibit_Conversion': 'multibit_conversion|Float', 'all_wns': 'all_wns|Float', 'all_tns': 'all_tns|Float', 'all_vp': 'all_vp|Float', 'reg2reg_wns': 'reg2reg_wns|Float', 'reg2reg_tns': 'reg2reg_tns|Float', 'reg2reg_vp': 'reg2reg_vp|Float', 'reg2cgate_wns': 'reg2cgate_wns|Float', 'reg2cgate_tns': 'reg2cgate_tns|Float',  'reg2cgate_vp': 'reg2cgate_vp|Float',\
                     'reg2out_wns': 'reg2out_wns|Float', 'reg2out_tns': 'reg2out_tns|Float', 'reg2out_vp': 'reg2out_vp|Float', 'in2reg_wns': 'in2reg_wns|Float', 'in2reg_tns': 'in2reg_tns|Float', 'in2reg_vp': 'in2reg_vp|Float', 'in2out_wns': 'in2out_wns|Float', 'in2out_tns': 'in2out_tns|Float', 'in2out_vp': 'in2out_vp|Float',\
                     'data_transition_violations': 'data_transition_violations|Integer', 'data_transition_violations_input': 'data_transition_violations_input|String', 'check_floorplan_warnings': 'check_floorplan_warnings|Integer', 'check_floorplan_errors': 'check_floorplan_errors|Integer', \
                     'log_Error_Messages': 'log_error_messages|Integer', 'log_Warning_Messages': 'log_warning_messages|Integer'}

# CTS CLOCK
csv_headers_cts_clock = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'Block_Name': 'block_name|String', 'PROJECT': 'project|String', 'STAGE': 'stage|String', 'Host_name': 'host_name|String', 'fusion_version': 'fusion_version|String', 'EFFORT': 'effort|String', 'VT_EFFORT': 'vt_effort|String', 'USEFUL_SKEW': 'useful_skew|String',\
		 'clock_tree_cells_violations': 'clock_tree_cells_violations|Integer', 'ABO_CELL': 'abo_cell|Integer', 'AINV_P': 'ainv_p|Integer', 'APSBUF': 'apsbuf|Integer', 'APSHOLD': 'apshold|Integer', 'APSLS': 'apsls|Integer', 'BINV_P': 'binv_p|Integer', 'BINV_R': 'binv_r|Integer', 'BINV_RR': 'binv_rr|Integer', 'Buf': 'buf|Integer', 'BUFT_GROPTO': 'buft_gropto|Integer', 'BUFT_L': 'buft_l|Integer', 'BUFT_P': 'buft_p|Integer', 'BUFT_RR': 'buft_rr|Integer', 'copt_d_inst': 'copt_d_inst|Integer', 'copt_h_inst': 'copt_h_inst|Integer', 'ctmi': 'ctmi|Integer', 'ctmTdsLR': 'ctmtdslr|Integer', 'congi': 'congi|Integer', 'gre_a': 'gre_a|Integer', 'gre_d': 'gre_d|Integer', 'gre_h': 'gre_h|Integer', 'gre_mt': 'gre_mt|Integer', 'grfo_d': 'grfo_d|Integer', 'grfo_h': 'grfo_h|Integer',\
		 'grfo_inst': 'grfo_inst|Integer', 'grfo_mt': 'grfo_mt|Integer', 'HFSBUF': 'hfsbuf|Integer', 'HFSINV': 'hfsinv|Integer', 'phfnr_buf': 'phfnr_buf|Integer', 'popt_d_inst': 'popt_d_inst|Integer', 'SGI': 'sgi|Integer', 'ZBUF': 'zbuf|Integer', 'Z_gre_BUF': 'z_gre_buf|Integer', 'Z_gre_INV': 'z_gre_inv|Integer', 'Z_gre_BUF_f': 'z_gre_buf_f|Integer', 'Z_gre_INV_f': 'z_gre_inv_f|Integer', 'ZINV': 'zinv|Integer', 'ABUF_PR': 'abuf_pr|Integer', 'AINV_PR': 'ainv_pr|Integer', 'APS_CLK_ISO': 'aps_clk_iso|Integer', 'APS_FTB': 'aps_ftb|Integer', 'APS_PI': 'aps_pi|Integer', 'APS_TDBUF': 'aps_tdbuf|Integer', 'BINV_S': 'binv_s|Integer', 'BUFT_S': 'buft_s|Integer', 'FTB': 'ftb|Integer', 'MPN_BUF': 'mpn_buf|Integer', 'MVISOL': 'mvisol|Integer', 'MV_RESTRICTION': 'mv_restriction|Integer',\
 		'PI': 'pi|Integer', 'PIOLD': 'piold|Integer', 'pmd': 'pmd|Integer', 'RBBUF': 'rbbuf|Integer', 'RBINV': 'rbinv|Integer', 'RLB': 'rlb|Integer', 'buf_drc_cln': 'buf_drc_cln|Integer', 'clk_drv_r': 'clk_drv_r|Integer', 'cto_buf': 'cto_buf|Integer', 'cto_buf_cln': 'cto_buf_cln|Integer', 'cto_buf_drc': 'cto_buf_drc|Integer', 'cto_dtrdly': 'cto_dtrdly|Integer', 'cto_inv': 'cto_inv|Integer', 'cto_inv_cln': 'cto_inv_cln|Integer', 'cto_inv_drc': 'cto_inv_drc|Integer', 'cto_st': 'cto_st|Integer',\
		 'ctosc*asb': 'ctosc_asb|Integer', 'ctosc_drc_inst': 'ctosc_drc_inst|Integer', 'ctosc_gls_inst': 'ctosc_gls_inst|Integer', 'ctosc_inst': 'ctosc_inst|Integer', 'cts_buf': 'cts_buf|Integer', 'ctsctobgt_ht': 'ctsctobgt_ht|Integer', 'ctsctobgt_st': 'ctsctobgt_st|Integer', 'ctsctobgt_sw': 'ctsctobgt_sw|Integer', 'cts_dlydt': 'cts_dlydt|Integer', 'cts_inv': 'cts_inv|Integer', 'CTS_MCSB': 'cts_mcsb|Integer', 'cts_trgdly': 'cts_trgdly|Integer',\
 		'dly_icdb_inst': 'dly_icdb_inst|Integer', 'dly_inst': 'dly_inst|Integer', 'dly_mcsb_inst': 'dly_mcsb_inst|Integer', 'dly_trglat_inst': 'dly_trglat_inst|Integer', 'ICDB': 'icdb|Integer', 'inv_drc_cln': 'inv_drc_cln|Integer', 'msgts_l': 'msgts_l|Integer', 'sbcto_ht': 'sbcto_ht|Integer', 'sbcto_st': 'sbcto_st|Integer', 'sbcto_sw': 'sbcto_sw|Integer', 'ugs': 'ugs|Integer', 'ZCTSBUF': 'zctsbuf|Integer', 'ZCTSINV': 'zctsinv|Integer', 'ctsiso_split': 'ctsiso_split|Integer',\
		 'bdp': 'bdp|Integer', 'BDP': 'bdpp|Integer', 'bcg': 'bcg|Integer', 'bip': 'bip|Integer', 'biso': 'biso|Integer', 'btd': 'btd|Integer', 'vcg': 'vcg|Integer', 'vdp': 'vdp|Integer', 'vip': 'vip|Integer', 'viso': 'viso|Integer', 'vtd': 'vtd|Integer', 'ropt_d_inst': 'ropt_d_inst|Integer', 'ropt_h_inst': 'ropt_h_inst|Integer', 'ropt_mt_inst': 'ropt_mt_inst|Integer', 'ropt_inst': 'ropt_inst|Integer', 'ccd_drc': 'ccd_drc|Integer', 'ccd_hold': 'ccd_hold|Integer', 'ccd_setup': 'ccd_setup|Integer', 'ctobgt_inst': 'ctobgt_inst|Integer', 'optlc': 'optlc|Integer', 'u/U': 'u_u|Integer',\
		 'max_transition': 'max_transition|Integer', 'max_capacitance': 'max_capacitance|Integer', 'min_pulse_width': 'min_pulse_width|Integer', 'min_period': 'min_period|Integer', 'clock_pins_not_connect_to_clock_violation': 'clock_pins_not_connect_to_clock_violation|Integer', 'clock_ndr_violations': 'clock_ndr_violations|Integer', 'cell_density': 'cell_density|Float', 'HotSpot_Score': 'hotspot_score|Float', 'HotSpot_Score_input': 'hotspot_score_input|String', 'congestion_H': 'congestion_h|Float', 'congestion_V': 'congestion_v|Float', 'report_Power': 'report_power|Float',\
		 'Leaf_Cell_Count': 'leaf_cell_count|Integer', 'FF_Bit_Count': 'ff_bit_count|Integer', 'ICG_count': 'icg_count|Integer', 'Leaf_Cell_Area': 'leaf_cell_area|Float', 'LVT_cells': 'lvt_cells|Integer', 'LVTLL_cells': 'lvtll_cells|Integer', 'ULVT_cells': 'ulvt_cells|Integer', 'ULVTLL_cells': 'ulvtll_cells|Integer', 'EVT_cells': 'evt_cells|Integer', 'LVT_area': 'lvt_area|Float', 'LVTLL_area': 'lvtll_area|Float', 'ULVT_area': 'ulvt_area|Float', 'ULVTLL_area': 'ulvtll_area|Float', 'EVT_area': 'evt_area|Float', 'Multibit_Conversion': 'multibit_conversion|Float',\
		 'reg2reg_wns': 'reg2reg_wns|Float', 'reg2reg_tns': 'reg2reg_tns|Float', 'reg2reg_vp': 'reg2reg_vp|Integer', 'reg2out_wns': 'reg2out_wns|Float', 'reg2out_tns': 'reg2out_tns|Float', 'reg2out_vp': 'reg2out_vp|Integer', 'in2reg_wns': 'in2reg_wns|Float', 'in2reg_tns': 'in2reg_tns|Float', 'in2reg_vp': 'in2reg_vp|Integer', 'in2out_wns': 'in2out_wns|Float', 'in2out_tns': 'in2out_tns|Float', 'in2out_vp': 'in2out_vp|Integer', 'all_wns': 'all_wns|Float', 'all_tns': 'all_tns|Float', 'all_vp': 'all_vp|Integer',\
		 'log_Error_Messages': 'log_error_messages|Integer', 'log_Warning_Messages': 'log_warning_messages|Integer'}

# CTS
csv_headers_cts = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'Block_Name': 'block_name|String', 'PROJECT': 'project|String', 'STAGE': 'stage|String', 'Host_name': 'host_name|String', 'fusion_version': 'fusion_version|String', 'EFFORT': 'effort|String', 'VT_EFFORT': 'vt_effort|String', 'USEFUL_SKEW': 'useful_skew|String',\
		 'clock_tree_cells_violations': 'clock_tree_cells_violations|Integer', 'ABO_CELL': 'abo_cell|Integer', 'AINV_P': 'ainv_p|Integer', 'APSBUF': 'apsbuf|Integer', 'APSHOLD': 'apshold|Integer', 'APSLS': 'apsls|Integer', 'BINV_P': 'binv_p|Integer', 'BINV_R': 'binv_r|Integer', 'BINV_RR': 'binv_rr|Integer', 'Buf': 'buf|Integer', 'BUFT_GROPTO': 'buft_gropto|Integer', 'BUFT_L': 'buft_l|Integer', 'BUFT_P': 'buft_p|Integer', 'BUFT_RR': 'buft_rr|Integer', 'copt_d_inst': 'copt_d_inst|Integer', 'copt_h_inst': 'copt_h_inst|Integer', 'ctmi': 'ctmi|Integer', 'ctmTdsLR': 'ctmtdslr|Integer', 'congi': 'congi|Integer', 'gre_a': 'gre_a|Integer', 'gre_d': 'gre_d|Integer', 'gre_h': 'gre_h|Integer', 'gre_mt': 'gre_mt|Integer', 'grfo_d': 'grfo_d|Integer', 'grfo_h': 'grfo_h|Integer',\
		 'grfo_inst': 'grfo_inst|Integer', 'grfo_mt': 'grfo_mt|Integer', 'HFSBUF': 'hfsbuf|Integer', 'HFSINV': 'hfsinv|Integer', 'phfnr_buf': 'phfnr_buf|Integer', 'popt_d_inst': 'popt_d_inst|Integer', 'SGI': 'sgi|Integer', 'ZBUF': 'zbuf|Integer', 'Z_gre_BUF': 'z_gre_buf|Integer', 'Z_gre_INV': 'z_gre_inv|Integer', 'Z_gre_BUF_f': 'z_gre_buf_f|Integer', 'Z_gre_INV_f': 'z_gre_inv_f|Integer', 'ZINV': 'zinv|Integer', 'ABUF_PR': 'abuf_pr|Integer', 'AINV_PR': 'ainv_pr|Integer', 'APS_CLK_ISO': 'aps_clk_iso|Integer', 'APS_FTB': 'aps_ftb|Integer', 'APS_PI': 'aps_pi|Integer', 'APS_TDBUF': 'aps_tdbuf|Integer', 'BINV_S': 'binv_s|Integer', 'BUFT_S': 'buft_s|Integer', 'FTB': 'ftb|Integer', 'MPN_BUF': 'mpn_buf|Integer', 'MVISOL': 'mvisol|Integer', 'MV_RESTRICTION': 'mv_restriction|Integer',\
 		'PI': 'pi|Integer', 'PIOLD': 'piold|Integer', 'pmd': 'pmd|Integer', 'RBBUF': 'rbbuf|Integer', 'RBINV': 'rbinv|Integer', 'RLB': 'rlb|Integer', 'buf_drc_cln': 'buf_drc_cln|Integer', 'clk_drv_r': 'clk_drv_r|Integer', 'cto_buf': 'cto_buf|Integer', 'cto_buf_cln': 'cto_buf_cln|Integer', 'cto_buf_drc': 'cto_buf_drc|Integer', 'cto_dtrdly': 'cto_dtrdly|Integer', 'cto_inv': 'cto_inv|Integer', 'cto_inv_cln': 'cto_inv_cln|Integer', 'cto_inv_drc': 'cto_inv_drc|Integer', 'cto_st': 'cto_st|Integer',\
		 'ctosc*asb': 'ctosc_asb|Integer', 'ctosc_drc_inst': 'ctosc_drc_inst|Integer', 'ctosc_gls_inst': 'ctosc_gls_inst|Integer', 'ctosc_inst': 'ctosc_inst|Integer', 'cts_buf': 'cts_buf|Integer', 'ctsctobgt_ht': 'ctsctobgt_ht|Integer', 'ctsctobgt_st': 'ctsctobgt_st|Integer', 'ctsctobgt_sw': 'ctsctobgt_sw|Integer', 'cts_dlydt': 'cts_dlydt|Integer', 'cts_inv': 'cts_inv|Integer', 'CTS_MCSB': 'cts_mcsb|Integer', 'cts_trgdly': 'cts_trgdly|Integer',\
 		'dly_icdb_inst': 'dly_icdb_inst|Integer', 'dly_inst': 'dly_inst|Integer', 'dly_mcsb_inst': 'dly_mcsb_inst|Integer', 'dly_trglat_inst': 'dly_trglat_inst|Integer', 'ICDB': 'icdb|Integer', 'inv_drc_cln': 'inv_drc_cln|Integer', 'msgts_l': 'msgts_l|Integer', 'sbcto_ht': 'sbcto_ht|Integer', 'sbcto_st': 'sbcto_st|Integer', 'sbcto_sw': 'sbcto_sw|Integer', 'ugs': 'ugs|Integer', 'ZCTSBUF': 'zctsbuf|Integer', 'ZCTSINV': 'zctsinv|Integer', 'ctsiso_split': 'ctsiso_split|Integer',\
		 'bdp': 'bdp|Integer', 'BDP': 'bdpp|Integer', 'bcg': 'bcg|Integer', 'bip': 'bip|Integer', 'biso': 'biso|Integer', 'btd': 'btd|Integer', 'vcg': 'vcg|Integer', 'vdp': 'vdp|Integer', 'vip': 'vip|Integer', 'viso': 'viso|Integer', 'vtd': 'vtd|Integer', 'ropt_d_inst': 'ropt_d_inst|Integer', 'ropt_h_inst': 'ropt_h_inst|Integer', 'ropt_mt_inst': 'ropt_mt_inst|Integer', 'ropt_inst': 'ropt_inst|Integer', 'ccd_drc': 'ccd_drc|Integer', 'ccd_hold': 'ccd_hold|Integer', 'ccd_setup': 'ccd_setup|Integer', 'ctobgt_inst': 'ctobgt_inst|Integer', 'optlc': 'optlc|Integer', 'u/U': 'u_u|Integer',\
		 'max_transition': 'max_transition|Integer', 'max_capacitance': 'max_capacitance|Integer', 'min_pulse_width': 'min_pulse_width|Integer', 'min_period': 'min_period|Integer','clock_pins_not_connect_to_clock_violation': 'clock_pins_not_connect_to_clock_violation|Integer',  'clock_ndr_violations': 'clock_ndr_violations|Integer', 'cell_density': 'cell_density|Float', 'HotSpot_Score': 'hotspot_score|Float', 'HotSpot_Score_input': 'hotspot_score_input|String', 'congestion_H': 'congestion_h|Float', 'congestion_V': 'congestion_v|Float', 'report_Power': 'report_power|Float',\
		 'Leaf_Cell_Count': 'leaf_cell_count|Integer', 'FF_Bit_Count': 'ff_bit_count|Integer', 'ICG_count': 'icg_count|Integer', 'Leaf_Cell_Area': 'leaf_cell_area|Float', 'LVT_cells': 'lvt_cells|Integer', 'LVTLL_cells': 'lvtll_cells|Integer', 'ULVT_cells': 'ulvt_cells|Integer', 'ULVTLL_cells': 'ulvtll_cells|Integer', 'EVT_cells': 'evt_cells|Integer', 'LVT_area': 'lvt_area|Float', 'LVTLL_area': 'lvtll_area|Float', 'ULVT_area': 'ulvt_area|Float', 'ULVTLL_area': 'ulvtll_area|Float', 'EVT_area': 'evt_area|Float', 'Multibit_Conversion': 'multibit_conversion|Float',\
		 'reg2reg_wns': 'reg2reg_wns|Float', 'reg2reg_tns': 'reg2reg_tns|Float', 'reg2reg_vp': 'reg2reg_vp|Integer', 'reg2out_wns': 'reg2out_wns|Float', 'reg2out_tns': 'reg2out_tns|Float', 'reg2out_vp': 'reg2out_vp|Integer', 'in2reg_wns': 'in2reg_wns|Float', 'in2reg_tns': 'in2reg_tns|Float', 'in2reg_vp': 'in2reg_vp|Integer', 'in2out_wns': 'in2out_wns|Float', 'in2out_tns': 'in2out_tns|Float', 'in2out_vp': 'in2out_vp|Integer', 'all_wns': 'all_wns|Float', 'all_tns': 'all_tns|Float', 'all_vp': 'all_vp|Integer',\
		 'log_Error_Messages': 'log_error_messages|Integer', 'log_Warning_Messages': 'log_warning_messages|Integer'}

# ROUTE  
csv_headers_route = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'Block_Name': 'block_name|String', 'STAGE': 'stage|String', 'PROJECT': 'project|String', 'Host_name': 'host_name|String', 'fusion_version': 'fusion_version|String', 'EFFORT': 'effort|String', 'VT_EFFORT': 'vt_effort|String',  \
                     'max_transition': 'max_transition|Integer', 'max_capacitance': 'max_capacitance|Integer', 'min_pulse_width': 'min_pulse_width|Integer', 'min_period': 'min_period|Integer',\
 		'Found_dont_use_cells_violations': 'found_dont_use_cells_violations|Integer', 'Found_long_nets': 'found_long_nets|Integer', 'Worst_route_quality_ratio': 'worst_route_quality_ratio|Float',\
		  'cell_density': 'cell_density|Float', 'report_Power': 'report_power|Float', 'Leaf_Cell_Count': 'leaf_cell_count|Integer', 'FF_Bit_Count': 'ff_bit_count|Integer', 'ICG_count': 'icg_count|Integer', 'Leaf_Cell_Area': 'leaf_cell_area|Float', 'LVT_cells': 'lvt_cells|Integer', 'LVTLL_cells': 'lvtll_cells|Integer', 'ULVT_cells': 'ulvt_cells|Integer', 'ULVTLL_cells': 'ulvtll_cells|Integer', 'EVT_cells': 'evt_cells|Integer', 'LVT_area': 'lvt_area|Float', 'LVTLL_area': 'lvtll_area|Float', 'ULVT_area': 'ulvt_area|Float', 'ULVTLL_area': 'ulvtll_area|Float', 'EVT_area': 'evt_area|Float', 'Multibit_Conversion': 'multibit_conversion|Float',\
		 'reg2reg_wns': 'reg2reg_wns|Float', 'reg2reg_tns': 'reg2reg_tns|Float', 'reg2reg_vp': 'reg2reg_vp|Integer', 'reg2out_wns': 'reg2out_wns|Float', 'reg2out_tns': 'reg2out_tns|Float', 'reg2out_vp': 'reg2out_vp|Integer',\
		 'in2reg_wns': 'in2reg_wns|Float', 'in2reg_tns': 'in2reg_tns|Float', 'in2reg_vp': 'in2reg_vp|Integer', 'in2out_wns': 'in2out_wns|Float', 'in2out_tns': 'in2out_tns|Float', 'in2out_vp': 'in2out_vp|Integer', 'all_wns': 'all_wns|Float', 'all_tns': 'all_tns|Float', 'all_vp': 'all_vp|Integer',\
		 'log_Error_Messages': 'log_error_messages|Integer', 'log_Warning_Messages': 'log_warning_messages|Integer'
}

# GROUP 
csv_group_headers = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'Block_Name': 'block_name|String', 'STAGE': 'stage|String', 'PROJECT': 'project|String',\
                         'Group_Name': 'group_name|String', 'STAGE': 'stage|String', 'WNS': 'wns|Float', 'TNS': 'tns|Float', 'VP': 'vp|Integer'}

# CHIP FINISH
csv_chip_finish = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'Block_Name': 'block_name|String', 'STAGE': 'stage|String', 'PROJECT': 'project|String', 'Host_name': 'host_name|String', \
                   'fusion_version': 'fusion_version|String', 'check_place_violations': 'check_place_violations|Integer', 'Total_shorts': 'total_shorts|Integer', 'Total_drc': 'total_drc|Integer',\
                   'Total_decap_cells': 'total_decap_cells|Integer', 'Total_ECO_decap_cells': 'total_eco_decap_cells|Integer', 'Total_cap': 'total_cap|Integer', 'log_Error_Messages': 'log_error_messages|Integer',\
                   'log_Warning_Messages': 'log_warning_messages|Integer'}

csv_headers_init = {'Date': 'date|Date', 'Time': 'time|Time', 'Work_Area': 'work_area|String', 'Block_Name': 'block_name|String', 'STAGE': 'stage|String', 'PROJECT': 'project|String', 'Host_name': 'host_name|String', \
                    'fusion_version': 'fusion_version|String', 'EFFORT': 'effort|String', 'VT_EFFORT': 'vt_effort|String', 'scripts_version': 'scripts_version|String', 'files_under_scripts_local': 'files_under_scripts_local|String',\
                    'files_under_scripts_local_input': 'files_under_scripts_local_input|String', 'compare_user_inputs_2_default_setting': 'compare_user_inputs_2_default_setting|String',\
                    'compare_user_inputs_2_default_setting_input': 'compare_user_inputs_2_default_setting_input|String', 'link_to_RTL_files': 'link_to_rtl_files|String', 'TAP': 'tap|Integer', 'ENDCAP': 'endcap|Integer', 'FPGFILL': 'fpgfill|Integer',\
                    'FPDCAP':'fpdcap|Integer', 'bonus_cells': 'bonus_cells|Integer', 'log_Error_Messages': 'log_error_messages|String', 'log_Warning_Messages': 'log_warning_messages|String'}


class Base:
    def __init__(self, stage, csv_file, group):
        
        self.stage = stage
        self.group = group
        self.csv_file = csv_file
        self.csv_headers = {}
        print('working on stage %s, group: %s' % (self.stage, self.group))
        self.get_db_params()
        if self.group:
            self.table_name = '%s_group' % self.stage
        else:
            self.table_name = self.stage
            
        self.create_table_if_not_exists()
        self.data = [] 
        
                
    def get_db_params(self,):
        
        self.POSTGRES_HOST = "hw-postgresql.hw.k8s.nextsilicon.com"
        self.k8s_POSTGRES_HOST = "hw-postgresql.hw.svc.cluster.local."
        self.POSTGRES_USER = os.environ['POSTGRES_USER']
        self.POSTGRES_PASSWORD = os.environ['POSTGRES_PASSWORD'] 
        self.DB_NAME = os.environ['DB_NAME']
        self.DATE = datetime.datetime.now().strftime("%Y-%m-%d")
        self.TIME = datetime.datetime.now().strftime("%H:%M:%S %p")
        
        POSTGRES_HOST = self.POSTGRES_HOST
        POSTGRES_PASSWORD = self.POSTGRES_PASSWORD
       # POSTGRES_HOST = self.POSTGRES_HOST
        DB_NAME = self.DB_NAME
        POSTGRES_USER = self.POSTGRES_USER
        POSTGRES_PASSWORD = self.POSTGRES_PASSWORD
        username = 'hw'
        self.engine = self.create_engine_with_retry(f'postgresql://{POSTGRES_USER}:{POSTGRES_PASSWORD}@{POSTGRES_HOST}/{DB_NAME}?application_name={username}')
        self.metadata = MetaData()
       
    def get_csv_headers(self):
        print('setting CSV header...')
        match self.stage:          
            case 'init':
                self.csv_headers = csv_headers_init
            case 'compile':
                self.csv_headers = csv_headers_compile
            case 'cts':
                self.csv_headers = csv_headers_cts
            case 'place':
                self.csv_headers = csv_headers_place
            case 'cts_only':
                self.csv_headers = csv_headers_cts_clock
            case 'route':
                self.csv_headers = csv_headers_route
            case 'chip_finish':
                self.csv_headers = csv_chip_finish
        
        if self.group:
            self.csv_headers = csv_group_headers
            
        print(self.csv_headers)


    def convert_csv_dict(self,): 
        # read csv file to a list of dictionaries
        date_format = '%b %d %Y'
        time_format = ' %I:%M:%S %p'
        datetime_format = '%b %d %Y %I:%M:%S %p'
        duration_format = '%H:%M:%S'
        date = None
        
        with open(self.csv_file, 'r') as file:
            csv_reader = csv.DictReader(file)
            for row in csv_reader:
                _dict = {}
                for k in row:
                    if k == '': continue
                    new_val = None
                    if row[k] == 'NA':
                        continue
                    match self.csv_headers[k].split('|')[1]:
                        
                        case 'String':
                            new_val = str(row[k])

                        case 'Float':
                            if len(row[k].split('%')) > 1:
                                new_val = float(row[k].split('%')[0])
                            else:
                                new_val = float(row[k])

                        case 'Integer':
                            new_val = int(row[k])
                                                
                        case 'Date':
                            date = row[k]
                            continue
                            new_val = datetime.datetime.strptime(row[k], date_format)
                                            
                        case 'Duration':
                            duration = row[k].split(':')
                            new_val = datetime.timedelta(hours=int(duration[0]), minutes=int(duration[1]), seconds=int(duration[2])).total_seconds()
                            
                        case 'Time':
                            new_val = datetime.datetime.strptime('%s %s' % (date, row[k]), datetime_format)
                            #new_val = datetime.datetime.strptime(row[k], time_format)
                            _dict['date'] = new_val
                            continue
                            
                    _dict[self.csv_headers[k].split('|')[0]] = new_val
                
                _dict['username'] = os.environ['USER'] 
                if self.stage != 'summary' and not self.group:
                    _dict['run'] = _dict['work_area'].split('/')[-1]
                    _dict['version'] = _dict['work_area'].split('/')[-2]
                    _dict['gifs'] = 'https://artifactory.k8s.nextsilicon.com/ui/api/v1/download/contentBrowsing/generic-repo/backend/%s/%s/%s/%s/%s/%s_load_gifs.html?isNativeBrowsing=true' % (os.environ['USER'], _dict['block_name'], _dict['version'], _dict['run'], _dict['stage'], _dict['stage'])    
                                    
                self.data.append(_dict)
                
                # 'https://artifactory.k8s.nextsilicon.com/ui/native/generic-repo/backend/%s/%s/%s/%s'
                
        for row in self.data:
            print(row)

    @retry(stop=stop_after_attempt(3), wait=wait_fixed(1))
    def create_engine_with_retry(self, connection_string):
        return create_engine(connection_string)

    def check_if_table_exists(self,):
        if not inspect(self.engine).has_table(self.table_name): 
            return False
        return True

    def create_table_if_not_exists(self,):
        

        # Create a connection to the database
        
        if not self.check_if_table_exists():
            print('Creating table %s on DB %s' % (self.table_name, self.DB_NAME))
            try:

                # Create a MetaData instance
                match self.stage:          
                    case 'init':
                        self.csv_headers = csv_headers_init
                        self.define_init_table()
                    
                    case 'compile':
                        self.csv_headers = csv_headers_compile
                        self.define_compile_table()

                    case 'cts':
                        self.csv_headers = csv_headers_cts
                        self.define_cts_table()
                        
                    case 'place':
                        self.csv_headers = csv_headers_place
                        self.define_place_table()
                        
                    case 'cts_only':
                        self.csv_headers = csv_headers_cts_clock
                        self.define_cts_clock_table()
                        
                    case 'route':
                        self.csv_headers = csv_headers_route
                        self.define_route_table()
                    
                    case 'chip_finish':
                        self.csv_headers = csv_chip_finish
                        self.define_chip_finish_table()
                
                if self.group:
                    self.csv_headers = csv_group_headers
                    self.define_group_table()
                #define_table(table_name, metadata)
                self.metadata.create_all(self.engine)
            except Exception as e:
                raise e
        
        else: 
            print('Table %s is already exists, skipping' % self.table_name)

    def define_compile_table(self,):
        _table = Table(
        self.stage, 
        self.metadata, Column('id', Integer, primary_key=True, autoincrement=True), Column('date', DateTime, default=datetime.datetime), Column('work_area', String),Column('block_name', String), Column('stage', String), Column('project', String),
        Column('host_name', String), Column('fusion_version', String), Column('effort', String), Column('vt_effort', String), Column('calculate_mems_bits', Integer), Column('calculate_the_number_of_transistors', Integer), Column('cell_density', Float), 
        Column('hotspot_score', Float), Column('hotspot_score_input', String), Column('congestion_h', Float), Column('congestion_v', Float), Column('total_internal_power', Integer), Column('total_switching_power', Integer), Column('total_leakage_power', Float), 
        Column('total_power', Float), Column('leaf_cell_count', Integer), Column('ff_bit_count', Integer), Column('gated_registers', Integer), Column('ungated_registers', Integer), Column('icg_count', Integer), Column('leaf_cell_area', Float), Column('lvt_cells', Float), Column('lvtll_cells', Float),
        Column('ulvt_cells', Float), Column('ulvtll_cells', Integer), Column('evt_cells', Integer), Column('lvt_area', Integer), Column('lvtll_area', Integer), Column('ulvt_area', Integer), Column('ulvtll_area', Float), Column('evt_area', Float),
        Column('multibit_conversion', Float), Column('reg2reg_wns', Float), Column('reg2reg_tns', Float), Column('reg2reg_vp', Float), Column('reg2out_wns', Float), Column('reg2out_tns', Float), Column('reg2out_vp', Float), Column('in2reg_wns', Float), 
        Column('in2reg_tns', Float), Column('in2reg_vp', Float), Column('in2out_wns', Float), Column('in2out_tns', Float), Column('in2out_vp', Float), Column('all_wns', Float), Column('all_tns', Float), Column('all_vp', Float), Column('total_io_buffers', Float),
        Column('total_io_buffers_input', String), Column('log_error_messages', Integer), Column('log_warning_messages', Integer), Column('run', String), Column('version', String), Column('username', String), Column('gifs', String), 
        UniqueConstraint('date', 'work_area', 'block_name', name='compile_uq_date_wa_block'))
        return _table
    
    def define_init_table(self,):
        _table = Table(
        self.stage,
        self.metadata, Column('id', Integer, primary_key=True, autoincrement=True), Column('date', DateTime, default=datetime.datetime), Column('work_area', String), Column('block_name', String),  Column('stage', String), Column('project', String), Column('host_name', String), 
        Column('fusion_version', String), Column('effort', String), Column('vt_effort', String), Column('scripts_version', String), Column('files_under_scripts_local', String), Column('files_under_scripts_local_input', String), Column('compare_user_inputs_2_default_setting', String), 
        Column('compare_user_inputs_2_default_setting_input', String), Column('link_to_rtl_files', String), Column('tap', Integer),Column('endcap', Integer), Column('fpgfill', Integer), Column('fpdcap', Integer), Column('bonus_cells', Integer), Column('log_error_messages', Integer), Column('log_warning_messages', Integer), Column('run', String), Column('version', String), Column('username', String), Column('gifs', String), UniqueConstraint('date', 'work_area', 'block_name', name='init_uq_date_wa_block'))    
        return _table

    def define_place_table(self,):
        _table = Table(
        self.stage, 
        self.metadata, Column('id', Integer, primary_key=True, autoincrement=True), Column('date', DateTime, default=datetime.datetime), Column('username', String),
        Column('work_area', String), Column('block_name', String),  Column('stage', String), Column('project', String), Column('host_name', String), Column('fusion_version', String), 
        Column('effort', String), Column('vt_effort', String), Column('total_io_buffers', String), Column('total_io_buffers_input', String), 
        Column('max_distance_io_buffers_to_ports_um', Float), Column('max_distance_io_buffers_to_ports_input', String), Column('io_sampled_by_mb', Integer), Column('io_sampled_by_mb_input', String), 
        Column('io_buffers_driving_ports_violations', Integer), Column('io_buffers_driving_ports_violations_input', String), Column('abo_cell', Integer), Column('ainv_p', Integer), Column('apsbuf', Integer), Column('apshold', Integer), Column('apsls', Integer), Column('binv_p', Integer), Column('binv_r', Integer), Column('binv_rr', Integer), Column('buf', Integer), Column('buft_gropto', Integer), Column('buft_l', Integer), Column('buft_p', Integer), Column('buft_rr', Integer), Column('copt_d_inst', Integer), Column('copt_h_inst', Integer), 
	Column('ctmi', Integer), Column('ctmtdslr', Integer), Column('congi', Integer), Column('gre_a', Integer), Column('gre_d', Integer), Column('gre_h', Integer), Column('gre_mt', Integer), Column('grfo_d', Integer), Column('grfo_h', Integer), Column('grfo_inst', Integer), Column('grfo_mt', Integer), Column('hfsbuf', Integer), Column('hfsinv', Integer), Column('phfnr_buf', Integer), Column('popt_d_inst', Integer), Column('sgi', Integer), Column('zbuf', Integer), Column('z_gre_buf', Integer), Column('z_gre_inv', Integer), Column('z_gre_buf_f', Integer), Column('z_gre_inv_f', Integer),
	 Column('zinv', Integer), Column('abuf_pr', Integer), Column('ainv_pr', Integer), Column('aps_clk_iso', Integer), Column('aps_ftb', Integer), Column('aps_pi', Integer), Column('aps_tdbuf', Integer), Column('binv_s', Integer), Column('buft_s', Integer), Column('ftb', Integer), Column('mpn_buf', Integer), Column('mvisol', Integer), Column('mv_restriction', Integer), Column('pi', Integer), Column('piold', Integer), Column('pmd', Integer), Column('rbbuf', Integer), Column('rbinv', Integer), Column('rlb', Integer), Column('buf_drc_cln', Integer), Column('clk_drv_r', Integer), Column('cto_buf', Integer), 
	Column('cto_buf_cln', Integer), Column('cto_buf_drc', Integer), Column('cto_dtrdly', Integer), Column('cto_inv', Integer), Column('cto_inv_cln', Integer), Column('cto_inv_drc', Integer), Column('cto_st', Integer), Column('ctosc_asb', Integer), Column('ctosc_drc_inst', Integer), Column('ctosc_gls_inst', Integer), Column('ctosc_inst', Integer), Column('cts_buf', Integer), Column('ctsctobgt_ht', Integer), Column('ctsctobgt_st', Integer), Column('ctsctobgt_sw', Integer), 
	Column('cts_dlydt', Integer), Column('cts_inv', Integer), Column('cts_mcsb', Integer), Column('cts_trgdly', Integer), Column('dly_icdb_inst', Integer), Column('dly_inst', Integer), Column('dly_mcsb_inst', Integer), Column('dly_trglat_inst', Integer), Column('icdb', Integer), Column('inv_drc_cln', Integer), Column('msgts_l', Integer), Column('sbcto_ht', Integer), Column('sbcto_st', Integer), Column('sbcto_sw', Integer), Column('ugs', Integer), Column('zctsbuf', Integer), Column('zctsinv', Integer), 
	Column('ctsiso_split', Integer), Column('bdp', Integer), Column('bdpp', Integer), Column('bcg', Integer), Column('bip', Integer), Column('biso', Integer), Column('btd', Integer), Column('vcg', Integer), Column('vdp', Integer), Column('vip', Integer), Column('viso', Integer), Column('vtd', Integer), Column('ropt_d_inst', Integer), Column('ropt_h_inst', Integer), Column('ropt_mt_inst', Integer), Column('ropt_inst', Integer), Column('ccd_drc', Integer), Column('ccd_hold', Integer), Column('ccd_setup', Integer), Column('ctobgt_inst', Integer), Column('optlc', Integer), Column('u_u', Integer), 
	 Column('cell_density', String), Column('hotspot_score', Float), 
        Column('hotspot_score_input', String), Column('congestion_h', String), Column('congestion_v', String), Column('total_internal_power', String), Column('total_switching_power', Float), 
        Column('total_leakage_power', Float), Column('total_power', Float), Column('leaf_cell_count', Float), Column('ff_bit_count', Float), Column('icg_count', Float), Column('leaf_cell_area', Float), 
        Column('lvt_cells', Float), Column('lvttl_cells', Float), Column('ulvt_cells', Float), Column('ulvtll_cells', Float), Column('evt_cells', Float), Column('lvt_area', Float), Column('lvtll_area', Float), 
        Column('ulvt_area', Float), Column('ulvtll_area', Float), Column('evt_area', Float), Column('multibit_conversion', Float), Column('all_wns', Float), 
Column('all_tns', Float), Column('all_vp', Float), Column('reg2reg_wns', Float), Column('reg2reg_tns', Float), 
        Column('reg2reg_vp', Float), Column('reg2cgate_wns', Float), Column('reg2cgate_tns', Float), Column('reg2cgate_vp', Float), Column('reg2out_wns', Float), Column('reg2out_tns', Float), 
        Column('reg2out_vp', Float), Column('in2reg_wns', Float), Column('in2reg_tns', Float), Column('in2reg_vp', Float), 
        Column('in2out_wns', Float), Column('in2out_tns', Float), Column('in2out_vp', Float), Column('data_transition_violations', Integer), Column('data_transition_violations_input', String), 
        Column('check_floorplan_warnings', Integer), Column('check_floorplan_errors', Integer), Column('run', String), Column('version', String),
        Column('log_error_messages', Integer),  Column('gifs', String), Column('log_warning_messages', Integer), UniqueConstraint('date', 'work_area', 'block_name', name='place_uq_date_wa_block'))        
        return _table 
          
    def define_cts_table(self,):
        if 'cts' in self.metadata.tables: return
        _table = Table(
        self.stage, 
        self.metadata, Column('id', Integer, primary_key=True, autoincrement=True), Column('date', DateTime, default=datetime.datetime), Column('username', String),
        Column('work_area', String), Column('block_name', String),  Column('stage', String), Column('project', String), Column('host_name', String), Column('fusion_version', String), Column('effort', String), Column('vt_effort', String), 
	Column('useful_skew', String), Column('clock_tree_cells_violations', Integer), Column('abo_cell', Integer), Column('ainv_p', Integer), Column('apsbuf', Integer), Column('apshold', Integer), Column('apsls', Integer), Column('binv_p', Integer), Column('binv_r', Integer), Column('binv_rr', Integer), Column('buf', Integer), Column('buft_gropto', Integer), Column('buft_l', Integer), Column('buft_p', Integer), Column('buft_rr', Integer), Column('copt_d_inst', Integer), Column('copt_h_inst', Integer), 
	Column('ctmi', Integer), Column('ctmtdslr', Integer), Column('congi', Integer), Column('gre_a', Integer), Column('gre_d', Integer), Column('gre_h', Integer), Column('gre_mt', Integer), Column('grfo_d', Integer), Column('grfo_h', Integer), Column('grfo_inst', Integer), Column('grfo_mt', Integer), Column('hfsbuf', Integer), Column('hfsinv', Integer), Column('phfnr_buf', Integer), Column('popt_d_inst', Integer), Column('sgi', Integer), Column('zbuf', Integer), Column('z_gre_buf', Integer), Column('z_gre_inv', Integer), Column('z_gre_buf_f', Integer), Column('z_gre_inv_f', Integer),
	 Column('zinv', Integer), Column('abuf_pr', Integer), Column('ainv_pr', Integer), Column('aps_clk_iso', Integer), Column('aps_ftb', Integer), Column('aps_pi', Integer), Column('aps_tdbuf', Integer), Column('binv_s', Integer), Column('buft_s', Integer), Column('ftb', Integer), Column('mpn_buf', Integer), Column('mvisol', Integer), Column('mv_restriction', Integer), Column('pi', Integer), Column('piold', Integer), Column('pmd', Integer), Column('rbbuf', Integer), Column('rbinv', Integer), Column('rlb', Integer), Column('buf_drc_cln', Integer), Column('clk_drv_r', Integer), Column('cto_buf', Integer), 
	Column('cto_buf_cln', Integer), Column('cto_buf_drc', Integer), Column('cto_dtrdly', Integer), Column('cto_inv', Integer), Column('cto_inv_cln', Integer), Column('cto_inv_drc', Integer), Column('cto_st', Integer), Column('ctosc_asb', Integer), Column('ctosc_drc_inst', Integer), Column('ctosc_gls_inst', Integer), Column('ctosc_inst', Integer), Column('cts_buf', Integer), Column('ctsctobgt_ht', Integer), Column('ctsctobgt_st', Integer), Column('ctsctobgt_sw', Integer), 
	Column('cts_dlydt', Integer), Column('cts_inv', Integer), Column('cts_mcsb', Integer), Column('cts_trgdly', Integer), Column('dly_icdb_inst', Integer), Column('dly_inst', Integer), Column('dly_mcsb_inst', Integer), Column('dly_trglat_inst', Integer), Column('icdb', Integer), Column('inv_drc_cln', Integer), Column('msgts_l', Integer), Column('sbcto_ht', Integer), Column('sbcto_st', Integer), Column('sbcto_sw', Integer), Column('ugs', Integer), Column('zctsbuf', Integer), Column('zctsinv', Integer), 
	Column('ctsiso_split', Integer), Column('bdp', Integer), Column('bdpp', Integer), Column('bcg', Integer), Column('bip', Integer), Column('biso', Integer), Column('btd', Integer), Column('vcg', Integer), Column('vdp', Integer), Column('vip', Integer), Column('viso', Integer), Column('vtd', Integer), Column('ropt_d_inst', Integer), Column('ropt_h_inst', Integer), Column('ropt_mt_inst', Integer), Column('ropt_inst', Integer), Column('ccd_drc', Integer), Column('ccd_hold', Integer), Column('ccd_setup', Integer), Column('ctobgt_inst', Integer), Column('optlc', Integer), Column('u_u', Integer), 
	Column('max_transition', Integer), Column('max_capacitance', Integer), Column('min_pulse_width', Integer), Column('min_period', Integer),Column('clock_pins_not_connect_to_clock_violation', Integer),  Column('clock_ndr_violations', Integer), Column('cell_density', Float), Column('hotspot_score', Float), Column('hotspot_score_input', String), Column('congestion_h', Float), Column('congestion_v', Float), Column('report_power', Float), Column('leaf_cell_count', Integer), Column('ff_bit_count', Integer), Column('icg_count', Integer), Column('leaf_cell_area', Float), Column('lvt_cells', Integer), Column('lvtll_cells', Integer), Column('ulvt_cells', Integer), 
	Column('ulvtll_cells', Integer), Column('evt_cells', Integer), Column('lvt_area', Float), Column('lvtll_area', Float), Column('ulvt_area', Float), Column('ulvtll_area', Float), Column('evt_area', Float), Column('multibit_conversion', Float),
	 Column('reg2reg_wns', Float), Column('reg2reg_tns', Float), Column('reg2reg_vp', Integer), Column('reg2out_wns', Float), Column('reg2out_tns', Float), Column('reg2out_vp', Integer), Column('in2reg_wns', Float), Column('in2reg_tns', Float), Column('in2reg_vp', Integer), Column('in2out_wns', Float), Column('in2out_tns', Float), Column('in2out_vp', Integer), Column('all_wns', Float), Column('all_tns', Float), Column('all_vp', Integer), Column('run', String), Column('version', String), Column('log_error_messages', Integer), Column('log_warning_messages', Integer),  Column('gifs', String), UniqueConstraint('date', 'work_area', 'block_name', name='cts_uq_date_wa_block'))        
        return _table
    
    def define_route_table(self,):
        if 'route' in self.metadata.tables: return
        _table = Table(
        self.stage,
        self.metadata, Column('id', Integer, primary_key=True, autoincrement=True), Column('date', DateTime, default=datetime.datetime), Column('username', String),
        Column('work_area', String), Column('block_name', String),  Column('stage', String), Column('project', String), Column('host_name', String), Column('fusion_version', String), Column('effort', String), Column('vt_effort', String),
	Column('max_transition', Integer), Column('max_capacitance', Integer), Column('min_pulse_width', Integer), Column('min_period', Integer), Column('found_dont_use_cells_violations', Integer), Column('found_long_nets', Integer), Column('worst_route_quality_ratio', Float), Column('cell_density', Float), Column('report_power', Float), Column('leaf_cell_count', Integer), Column('ff_bit_count', Integer), Column('icg_count', Integer), Column('leaf_cell_area', Float), Column('lvt_cells', Integer), Column('lvtll_cells', Integer), Column('ulvt_cells', Integer), 
	Column('ulvtll_cells', Integer), Column('evt_cells', Integer), Column('lvt_area', Float), Column('lvtll_area', Float), Column('ulvt_area', Float), Column('ulvtll_area', Float), Column('evt_area', Float), Column('multibit_conversion', Float),
	Column('reg2reg_wns', Float), Column('reg2reg_tns', Float), Column('reg2reg_vp', Integer), Column('reg2out_wns', Float), Column('reg2out_tns', Float), Column('reg2out_vp', Integer), Column('in2reg_wns', Float), Column('in2reg_tns', Float), Column('in2reg_vp', Integer), Column('in2out_wns', Float), Column('in2out_tns', Float), Column('in2out_vp', Integer), Column('all_wns', Float), Column('all_tns', Float), Column('all_vp', Integer),
	Column('run', String), Column('version', String),Column('log_error_messages', Integer), Column('log_warning_messages', Integer),  Column('gifs', String), UniqueConstraint('date', 'work_area', 'block_name', name='route_uq_date_wa_block'))        
        return _table
    
    
    def define_cts_clock_table(self,):
        if 'cts_only' in self.metadata.tables: return
        _table = Table(
        self.stage, 
        self.metadata, Column('id', Integer, primary_key=True, autoincrement=True), Column('date', DateTime, default=datetime.datetime), Column('work_area', String), Column('block_name', String), Column('username', String),
	 Column('stage', String), Column('project', String), Column('host_name', String), Column('fusion_version', String), Column('effort', String), Column('vt_effort', String), 
	Column('useful_skew', String), Column('clock_tree_cells_violations', Integer), Column('abo_cell', Integer), Column('ainv_p', Integer), Column('apsbuf', Integer), Column('apshold', Integer), Column('apsls', Integer), Column('binv_p', Integer), Column('binv_r', Integer), Column('binv_rr', Integer), Column('buf', Integer), Column('buft_gropto', Integer), Column('buft_l', Integer), Column('buft_p', Integer), Column('buft_rr', Integer), Column('copt_d_inst', Integer), Column('copt_h_inst', Integer), 
	Column('ctmi', Integer), Column('ctmtdslr', Integer), Column('congi', Integer), Column('gre_a', Integer), Column('gre_d', Integer), Column('gre_h', Integer), Column('gre_mt', Integer), Column('grfo_d', Integer), Column('grfo_h', Integer), Column('grfo_inst', Integer), Column('grfo_mt', Integer), Column('hfsbuf', Integer), Column('hfsinv', Integer), Column('phfnr_buf', Integer), Column('popt_d_inst', Integer), Column('sgi', Integer), Column('zbuf', Integer), Column('z_gre_buf', Integer), Column('z_gre_inv', Integer), Column('z_gre_buf_f', Integer), Column('z_gre_inv_f', Integer),
	 Column('zinv', Integer), Column('abuf_pr', Integer), Column('ainv_pr', Integer), Column('aps_clk_iso', Integer), Column('aps_ftb', Integer), Column('aps_pi', Integer), Column('aps_tdbuf', Integer), Column('binv_s', Integer), Column('buft_s', Integer), Column('ftb', Integer), Column('mpn_buf', Integer), Column('mvisol', Integer), Column('mv_restriction', Integer), Column('pi', Integer), Column('piold', Integer), Column('pmd', Integer), Column('rbbuf', Integer), Column('rbinv', Integer), Column('rlb', Integer), Column('buf_drc_cln', Integer), Column('clk_drv_r', Integer), Column('cto_buf', Integer), 
	Column('cto_buf_cln', Integer), Column('cto_buf_drc', Integer), Column('cto_dtrdly', Integer), Column('cto_inv', Integer), Column('cto_inv_cln', Integer), Column('cto_inv_drc', Integer), Column('cto_st', Integer), Column('ctosc_asb', Integer), Column('ctosc_drc_inst', Integer), Column('ctosc_gls_inst', Integer), Column('ctosc_inst', Integer), Column('cts_buf', Integer), Column('ctsctobgt_ht', Integer), Column('ctsctobgt_st', Integer), Column('ctsctobgt_sw', Integer), 
	Column('cts_dlydt', Integer), Column('cts_inv', Integer), Column('cts_mcsb', Integer), Column('cts_trgdly', Integer), Column('dly_icdb_inst', Integer), Column('dly_inst', Integer), Column('dly_mcsb_inst', Integer), Column('dly_trglat_inst', Integer), Column('icdb', Integer), Column('inv_drc_cln', Integer), Column('msgts_l', Integer), Column('sbcto_ht', Integer), Column('sbcto_st', Integer), Column('sbcto_sw', Integer), Column('ugs', Integer), Column('zctsbuf', Integer), Column('zctsinv', Integer), 
	Column('ctsiso_split', Integer), Column('bdp', Integer), Column('bdpp', Integer), Column('bcg', Integer), Column('bip', Integer), Column('biso', Integer), Column('btd', Integer), Column('vcg', Integer), Column('vdp', Integer), Column('vip', Integer), Column('viso', Integer), Column('vtd', Integer), Column('ropt_d_inst', Integer), Column('ropt_h_inst', Integer), Column('ropt_mt_inst', Integer), Column('ropt_inst', Integer), Column('ccd_drc', Integer), Column('ccd_hold', Integer), Column('ccd_setup', Integer), Column('ctobgt_inst', Integer), Column('optlc', Integer), Column('u_u', Integer), 
	Column('max_transition', Integer), Column('max_capacitance', Integer), Column('min_pulse_width', Integer), Column('min_period', Integer), Column('clock_pins_not_connect_to_clock_violation', Integer), Column('clock_ndr_violations', Integer), Column('cell_density', Float), Column('hotspot_score', Float), Column('hotspot_score_input', String), Column('congestion_h', Float), Column('congestion_v', Float), Column('report_power', Float), Column('leaf_cell_count', Integer), Column('ff_bit_count', Integer), Column('icg_count', Integer), Column('leaf_cell_area', Float), Column('lvt_cells', Integer), Column('lvtll_cells', Integer), Column('ulvt_cells', Integer), 
	Column('ulvtll_cells', Integer), Column('evt_cells', Integer), Column('lvt_area', Float), Column('lvtll_area', Float), Column('ulvt_area', Float), Column('ulvtll_area', Float), Column('evt_area', Float), Column('multibit_conversion', Float),
	 Column('reg2reg_wns', Float), Column('reg2reg_tns', Float), Column('reg2reg_vp', Integer), Column('reg2out_wns', Float), Column('reg2out_tns', Float), Column('reg2out_vp', Integer), Column('in2reg_wns', Float), Column('in2reg_tns', Float), Column('in2reg_vp', Integer), Column('in2out_wns', Float), Column('in2out_tns', Float), Column('in2out_vp', Integer), Column('all_wns', Float), Column('all_tns', Float), Column('all_vp', Integer), Column('run', String), Column('version', String), Column('log_error_messages', Integer), Column('log_warning_messages', Integer),  Column('gifs', String)
       , UniqueConstraint('date', 'work_area', 'block_name', name='cts_clock_uq_date_wa_block'))
        return _table
    
    def define_group_table(self,):
        if 'group' in self.metadata.tables: return
        _table = Table(
        '%s_group' % self.stage, 
        self.metadata, Column('id', Integer, primary_key=True, autoincrement=True), Column('date', DateTime, default=datetime.datetime), Column('work_area', String), Column('block_name', String), Column('username', String),
        Column('stage', String), Column('project', String), Column('group_name', String), Column('wns', Float), Column('tns', Float), Column('vp', Integer), 
        Column('run', String), Column('version', String), UniqueConstraint('date', 'work_area', 'block_name', name='%s_group_uq_date_wa_block' % self.stage))        
        return _table
    
    def define_chip_finish_table(self,):
        if 'chip_finish' in self.metadata.tables: return
        _table = Table(
        self.stage, 
        self.metadata, Column('id', Integer, primary_key=True, autoincrement=True), Column('date', DateTime, default=datetime.datetime), Column('work_area', String), Column('block_name', String), Column('username', String),
        Column('stage', String), Column('project', String), Column('host_name', String), Column('fusion_version', String), Column('check_place_violations', Integer), Column('total_shorts', Integer), Column('total_drc', Integer), Column('total_decap_cells', Integer), Column('run', String), Column('version', String),
        Column('total_eco_decap_cells', Integer), Column('total_cap', Integer), Column('log_error_messages', Integer), Column('log_warning_messages', Integer), 
        UniqueConstraint('date', 'work_area', 'block_name', name='chip_finish_uq_date_wa_block'))        
        return _table
    
    def insert_db(self,):

        try:
            with self.engine.connect() as connection:
                match self.stage:      
                    case 'init':
                        results = self.define_init_table()
                    
                        for record in self.data:
                            stmt = insert(results).values(**record)
                            stmt = stmt.on_conflict_do_nothing(constraint="init_uq_date_wa_block")
                            connection.execute(stmt)
                            connection.commit()
                                                        
                    case 'compile':
                        if self.group:
                            results = self.define_group_table()
                            constraint_name = 'compile_group_uq_date_wa_block'
                        else:
                            results = self.define_compile_table()
                            constraint_name = "compile_uq_date_wa_block"
                        for record in self.data:
                            stmt = insert(results).values(**record)
                            stmt = stmt.on_conflict_do_nothing(constraint=constraint_name)
                            connection.execute(stmt)
                            connection.commit()
                                                
                    case 'place':
                        if self.group:
                            results = self.define_group_table()
                            constraint_name = 'place_group_uq_date_wa_block'
                        else:
                            results = self.define_place_table()
                            constraint_name = "place_uq_date_wa_block"
                        for record in self.data:
                            stmt = insert(results).values(**record)
                            stmt = stmt.on_conflict_do_nothing(constraint=constraint_name)               
                            connection.execute(stmt)
                            connection.commit()
                                                   
                    case 'cts':
                        if self.group:
                            results = self.define_group_table()
                            constraint_name = "cts_group_uq_date_wa_block"
                        else:
                            results = self.define_cts_table()
                            constraint_name = "cts_uq_date_wa_block"
                        
                        for record in self.data:
                            stmt = insert(results).values(**record)
                            stmt = stmt.on_conflict_do_nothing(constraint=constraint_name)               
                            connection.execute(stmt)
                            connection.commit() 
                            
                    case 'cts_only':
                        results = self.define_cts_clock_table()
                        for record in self.data:
                            stmt = insert(results).values(**record)
                            stmt = stmt.on_conflict_do_nothing(constraint="cts_clock_uq_date_wa_block")               
                            connection.execute(stmt)
                            connection.commit()
                                
                    case 'route':
                        if self.group:
                            results = self.define_group_table()
                            constraint_name = "route_group_uq_date_wa_block"
                        else:
                            results = self.define_route_table()
                            constraint_name = "route_uq_date_wa_block"
                        for record in self.data:
                            stmt = insert(results).values(**record)
                            stmt = stmt.on_conflict_do_nothing(constraint=constraint_name)               
                            connection.execute(stmt)
                            connection.commit()
                                               
                    case 'chip_finish':
                        results = self.define_chip_finish_table()
                        for record in self.data:
                            stmt = insert(results).values(**record)
                            stmt = stmt.on_conflict_do_nothing(constraint="chip_finish_uq_date_wa_block")
                            connection.execute(stmt)
                            connection.commit()
        except:
            raise
        
        print("Data inserted successfully")

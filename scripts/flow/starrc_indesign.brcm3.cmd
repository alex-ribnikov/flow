*********************************************************************************
** Stand-alone StarRC Reference Methodology 				       **
** Gate Level Flow							       **
** Version: Q-2019.12-SP4 (May 26, 2020)                                       **
** Copyright (C) 1998-2020 Synopsys, Inc. All rights reserved.                 **
*********************************************************************************

***********     SETUP     **********
 NUM_CORES: 16
 STARRC_DP_STRING: list localhost:16

SHORTS_LIMIT: 50000

* Specify block name for parasitic extraction
* BLOCK:  nsc_l3u_wrapper_v3/route

* Provide top macro def file
* TOP_DEF_FILE: BLOCK_DEF_FILE

* NDM flow
* NDM_DATABASE: /bespace/users/royl/inext/be_work/brcm3/nsc_l3u_wrapper_v3/nextcore_pn85_3_l3u_bsi_20250116_2050/pnr_v3.14/out/nsc_l3u_wrapper_v3_lib


* Provide the mapping file in which design layers mapped to process layers 
 MAPPING_FILE: /project/foundry/TSMC/N3/BRCM/PDK/20241007/StarRCXT/19M_1xa1xb1xc1xd1ya1yb6y2yy2yx2r_R07512FFE_lefdef_rcxt_map



BUS_BIT: []
HIERARCHICAL_SEPARATOR: /

* Use '*' to extract all signal nets in the design. Otherwise, provide the net names to be extracted separated by a space. Wildcards '?' and '!' are accepted for net names
NETS: *
***NETLIST_SELECT_NETS: * !_BOUNDARY_WIRES_RESERVED

* Use 'RC' to perform resistance and capacitance extraction on the nets
EXTRACTION: RC 

DEF_MASKSHIFT_CONSISTENCY_CHECK: NO

* Enable Double Patterning Technology
DPT: YES 

 REDUCTION: NO_EXTRA_LOOPS
 REDUCTION_MAX_DELAY_ERROR: 1e-14
 COUPLING_ABS_THRESHOLD: 1e-15
 COUPLING_REL_THRESHOLD: 1.0e-2

 
 ***********     FLOW SELECTION       **********
* Provide the defined corners.smc file
* CORNERS_FILE: ./corners.smc

* Put DENSITY_OUTSIDE_BLOCK: density_value in corners.smc file
* For details on DENISTY_OUTSIDE_BLOCK refer to the User Guide
* List all corners to be extracted separated by a space
 SELECTED_CORNERS: rc_wc_cc_wc_0 c_wc_cc_wc_0 rc_bc_cc_bc_0 c_bc_cc_bc_0 rc_wc_cc_wc_T_125 c_wc_cc_wc_T_125 rc_bc_cc_bc_125 c_bc_cc_bc_125 rc_wc_cc_wc_T_0 c_wc_cc_wc_T_0 rc_wc_cc_wc_125 c_wc_cc_wc_125


* Enable the SMC feature
SIMULTANEOUS_MULTI_CORNER: YES


NETLIST_COMPRESS_COMMAND: gzip -q

***********     SKIPPING ALL CELLS **********
 INSTANCE_PORT: SUPERCONDUCTIVE CELL *LPDSINV* PORT o
 SKIP_CELLS: * 


***********     FILL HANDLING      **********
* Provide the setting how the metal fill needs to be treated, FLOATING or GROUNDED
METAL_FILL_POLYGON_HANDLING: FLOATING

* Provide the fill OASIS layer map file that consists of fill gds layers mapped to design database layers
* METAL_FILL_OASIS_FILE: 
* METAL_FILL_BLOCK_NAME: DM_nsc_l3u_wrapper_v3

***********     METAL FILL STATISTICS REPORTING     **********
REPORT_METAL_FILL_STATISTICS: YES
OASIS_LAYER_MAP_FILE: /project/foundry/TSMC/N3/TSMC/PDK/APR/snps/11.1B/PRTF_ICC2_3nm_014_Syn_V11_1b/PR_tech/Synopsys/StarDummyMap/PRTF_ICC2_N3E_dummy_19M_1Xa_h_1Xb_v_1Xc_h_1Xd_v_1Ya_h_1Yb_v_6Y_hvhvhv_2Yy2Yx2R_SHDMIM.11_1b.map

NON_COLOR_POLYGON_HANDLING: NONE

***********     PARASITIC OUTPUT       **********
COUPLE_TO_GROUND: NO
COUPLING_MULTIPLIER: 1
NETLIST_CONNECT_OPENS: !*

EXTRACT_VIA_CAPS: YES
 PARASITIC_EXPLORER_ENABLE_ANALYSIS: YES
 
NETLIST_LOCATION_TRANSFORMS: YES

 * Provide the working directory name to which StarRC internal information is written in binary
STAR_DIRECTORY: ./work 

* Provide the name of a directory
* GPD: ./out/gpd/nsc_l3u_wrapper_v3.route.HIER.gpd

* NETLIST_FILE: ./out/spef/nsc_l3u_wrapper_v3.route.spef.gz
* NETLIST_FORMAT: SPEF
LEF_FOREIGN_MACRO_ASSOCIATION: YES 
OASIS_FILE: /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ck05t0750v/oasis/tsmc3ffe_ck05t0750v.oas
OASIS_FILE: /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lp05t0750v/oasis/tsmc3ffe_lp05t0750v.oas
OASIS_FILE: /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_misc/oasis/tsmc3ffe_misc.oas
OASIS_FILE: /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_ga05t0750v/oasis/tsmc3ffe_ga05t0750v.oas
OASIS_FILE: /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_lscore/oasis/tsmc3ffe_lscore.oas
OASIS_FILE: /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_sc05t0750v/oasis/tsmc3ffe_sc05t0750v.oas
OASIS_FILE: /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_hm05t0750v/oasis/tsmc3ffe_hm05t0750v.oas
OASIS_FILE: /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_mb05t0750v/oasis/tsmc3ffe_mb05t0750v.oas
OASIS_FILE: /project/foundry/TSMC/N3/BRCM/IP/STD/20241007/tsmc3ffe_top05t0750v/oasis/tsmc3ffe_top05t0750v.oas
OASIS_FILE: /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_DTCD_library_kit_general_v0d9_1_230327/N3E_DTCD_ALL_phantom_general_20220327.oas
OASIS_FILE: /project/foundry/TSMC/N3/TSMC/Docs/DRM/1.1/N3E_ICOVL_library_kit_General_v0d9_1_20230327/N3E_ICOVL_ALL_phantom_general_20220327.oas

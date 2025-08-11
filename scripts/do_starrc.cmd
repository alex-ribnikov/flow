*********************************************************************************
** Stand-alone StarRC Reference Methodology 				       **
** Gate Level Flow							       **
** Version: Q-2019.12-SP4 (May 26, 2020)                                       **
** Copyright (C) 1998-2020 Synopsys, Inc. All rights reserved.                 **
*********************************************************************************

***********     SETUP     **********
 NUM_CORES: CPU
 STARRC_DP_STRING: list HOSTS

SHORTS_LIMIT: 50000

* Specify block name for parasitic extraction
BLOCK:  DESIGN_NAME

* Provide top macro def file
* TOP_DEF_FILE: BLOCK_DEF_FILE

* NDM flow
* NDM_DATABASE: BLOCK_NDM_LIB


* Provide the mapping file in which design layers mapped to process layers 
 MAPPING_FILE: TECHNOLOGY_LAYER_MAP



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
CORNERS_FILE: ./corners.smc

* Put DENSITY_OUTSIDE_BLOCK: density_value in corners.smc file
* For details on DENISTY_OUTSIDE_BLOCK refer to the User Guide
* List all corners to be extracted separated by a space
 SELECTED_CORNERS: EXTRACT_CORNERS


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
* METAL_FILL_BLOCK_NAME: DM_DESIGN_NAME

***********     METAL FILL STATISTICS REPORTING     **********
REPORT_METAL_FILL_STATISTICS: YES
OASIS_LAYER_MAP_FILE: STREAM_LAYER_MAP_FILE

** NON_COLOR_POLYGON_HANDLING: NONE
NON_COLOR_POLYGON_HANDLING  : WARN

***********     PARASITIC OUTPUT       **********
COUPLE_TO_GROUND: NO
COUPLING_MULTIPLIER: 1

** BRCM set this to CONNECT all open
NETLIST_CONNECT_OPENS: !*

EXTRACT_VIA_CAPS: YES
 PARASITIC_EXPLORER_ENABLE_ANALYSIS: YES
 
NETLIST_LOCATION_TRANSFORMS: YES

 * Provide the working directory name to which StarRC internal information is written in binary
STAR_DIRECTORY: ./work 

* Provide the name of a directory
GPD: ./out/gpd/DESIGN_NAME.STAGE.HIER.gpd


* default is YES, BRCM set it no
* MERGE_VIAS_IN_ARRAY         : NO
NETLIST_USE_M_FACTOR        : NO

* from BRCM , 
INTRANET_CAPS               : NO
DENSITY_BASED_THICKNESS     : YES
DENSITY_OUTSIDE_BLOCK       : 0.5
MULTIGATE_MODELS            : YES


* NETLIST_FILE: ./out/spef/DESIGN_NAME.STAGE.spef.gz
* NETLIST_FORMAT: SPEF
LEF_FOREIGN_MACRO_ASSOCIATION: YES 

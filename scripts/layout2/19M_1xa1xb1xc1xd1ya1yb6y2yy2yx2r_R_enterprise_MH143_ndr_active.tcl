

#
# Copyright      : Broadcom Limited 2022
# Target process : TSMC N3E Process
# Stack          : 19M w/ 1-M1 1-Mxa 1-Mxb 1-Mxc 1-Mxd 1-Mya 1-Myb 6-My 2-Myy 2-Myx 2-Mr plus UTRDL
#  
#
# Tracking       : Enterprise
# Rows           : MH143
#  

# Load the vias file.  This is needed because old giant versions <= 6.0.1 and
# old act-make_target versions <= 5.6.1 load this ndr file before the via file.
# This hack should be removed when people are using newer giant and
# act-make_target versions that load the vias file before the ndr file.
# 24/02/2025 Royl: we dont have this 
#if {[info exists pwrGridViaDefnFile] && [file exists $pwrGridViaDefnFile]} {
#  source $pwrGridViaDefnFile
#  puts "Info: Sourced extra vias before NDR rules"
#} else {
#  puts "WARNING: extra vias file does not exist or pwrGridViaDefnFile variable not set in $env(ACTROOT)/$env(ICPROCESS)/iccii/tcl/configuration.tcl"
#}


if {[sizeof_collection [get_routing_rules -quiet DEFAULT_SHLD]] > 0} { remove_routing_rule DEFAULT_SHLD }
create_routing_rule DEFAULT_SHLD \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.0380 M8 0.0380 M9 0.0380 M10 0.0380 M11 0.0380 M12 0.0380 M13 0.0380 M14 0.0620 M15 0.0620 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.038 M8 0.038 M9 0.038 M10 0.038 M11 0.038 M12 0.038 M13 0.038 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " \
        -shield_width " \
         M0 0  \
         M1 0  \
         M2 0  \
         M3 0  \
         M4 0  \
         M5 [get_attribute [get_layers M5] min_width]  \
         M6 [get_attribute [get_layers M6] min_width]  \
         M7 [get_attribute [get_layers M7] min_width]  \
         M8 [get_attribute [get_layers M8] min_width]  \
         M9 [get_attribute [get_layers M9] min_width]  \
         M10 [get_attribute [get_layers M10] min_width]  \
         M11 [get_attribute [get_layers M11] min_width]  \
         M12 [get_attribute [get_layers M12] min_width]  \
         M13 [get_attribute [get_layers M13] min_width]  \
         M14 [get_attribute [get_layers M14] min_width]  \
         M15 [get_attribute [get_layers M15] min_width]  \
         M16 [get_attribute [get_layers M16] min_width]  \
         M17 [get_attribute [get_layers M17] min_width]  \
         M18 [get_attribute [get_layers M18] min_width]  \
         M19 [get_attribute [get_layers M19] min_width]  \
         AP [get_attribute [get_layers AP] min_width]  \
         " \
        -shield_spacing "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.038 M8 0.038 M9 0.038 M10 0.038 M11 0.038 M12 0.038 M13 0.038 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  "


############################################################################
###
###   NDR_A__m78910111213_p076;
###
###   M[0-6]   : Default
###   M[7-13]  : Roughly 2X
###   M[14-19] : Default
###      
############################################################################
if {[sizeof_collection [get_routing_rules -quiet NDR_A__m78910111213_p076]] > 0} { remove_routing_rule NDR_A__m78910111213_p076 }
create_routing_rule NDR_A__m78910111213_p076 \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.0620 M15 0.0620 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " \
        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1cut_BW38_UW76 1x1 NR} {VIA78_big_BW76_UW76 1x1 NR} {VIA89_big_BW76_UW76 1x1 NR} {VIA910_big_BW76_UW76 1x1 NR} {VIA1011_big_BW76_UW76 1x1 NR} {VIA1112_big_BW76_UW76 1x1 NR} {VIA1213_big_BW76_UW76 1x1 NR} {VIA1314_1cut_BW76_UW62 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}

if {[sizeof_collection [get_routing_rules -quiet NDR_A__m78910111213_p076_SHLD]] > 0} { remove_routing_rule NDR_A__m78910111213_p076_SHLD }
create_routing_rule NDR_A__m78910111213_p076_SHLD \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.0620 M15 0.0620 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " \
        -shield_width " \
         M0 0  \
         M1 0  \
         M2 0  \
         M3 0  \
         M4 0  \
         M5 [get_attribute [get_layers M5] min_width]  \
         M6 [get_attribute [get_layers M6] min_width]  \
         M7 [get_attribute [get_layers M7] min_width]  \
         M8 [get_attribute [get_layers M8] min_width]  \
         M9 [get_attribute [get_layers M9] min_width]  \
         M10 [get_attribute [get_layers M10] min_width]  \
         M11 [get_attribute [get_layers M11] min_width]  \
         M12 [get_attribute [get_layers M12] min_width]  \
         M13 [get_attribute [get_layers M13] min_width]  \
         M14 [get_attribute [get_layers M14] min_width]  \
         M15 [get_attribute [get_layers M15] min_width]  \
         M16 [get_attribute [get_layers M16] min_width]  \
         M17 [get_attribute [get_layers M17] min_width]  \
         M18 [get_attribute [get_layers M18] min_width]  \
         M19 [get_attribute [get_layers M19] min_width]  \
         AP [get_attribute [get_layers AP] min_width]  \
         " \
        -shield_spacing "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " \
        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1cut_BW38_UW76 1x1 NR} {VIA78_big_BW76_UW76 1x1 NR} {VIA89_big_BW76_UW76 1x1 NR} {VIA910_big_BW76_UW76 1x1 NR} {VIA1011_big_BW76_UW76 1x1 NR} {VIA1112_big_BW76_UW76 1x1 NR} {VIA1213_big_BW76_UW76 1x1 NR} {VIA1314_1cut_BW76_UW62 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}


############################################################################
###
###   NDR_B__m78910111213_p114;
###
###   M[0-6]   : Default
###   M[7-13]  : Roughly 3X
###   M[14-19] : Default
###      
############################################################################
if {[sizeof_collection [get_routing_rules -quiet NDR_B__m78910111213_p114]] > 0} { remove_routing_rule NDR_B__m78910111213_p114 }
create_routing_rule NDR_B__m78910111213_p114 \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.0620 M15 0.0620 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1cut_BW38_UW114 1x1 NR} {VIA78_big_BW114_UW114 1x1 NR} {VIA89_big_BW114_UW114 1x1 NR} {VIA910_big_BW114_UW114 1x1 NR} {VIA1011_big_BW114_UW114 1x1 NR} {VIA1112_big_BW114_UW114 1x1 NR} {VIA1213_big_BW114_UW114 1x1 NR} {VIA1314_1cut_BW114_UW62_NDR 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}

if {[sizeof_collection [get_routing_rules -quiet NDR_B__m78910111213_p114_SHLD]] > 0} { remove_routing_rule NDR_B__m78910111213_p114_SHLD }
create_routing_rule NDR_B__m78910111213_p114_SHLD \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.0620 M15 0.0620 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " \
        -shield_width " \
         M0 0  \
         M1 0  \
         M2 0  \
         M3 0  \
         M4 0  \
         M5 [get_attribute [get_layers M5] min_width]  \
         M6 [get_attribute [get_layers M6] min_width]  \
         M7 [get_attribute [get_layers M7] min_width]  \
         M8 [get_attribute [get_layers M8] min_width]  \
         M9 [get_attribute [get_layers M9] min_width]  \
         M10 [get_attribute [get_layers M10] min_width]  \
         M11 [get_attribute [get_layers M11] min_width]  \
         M12 [get_attribute [get_layers M12] min_width]  \
         M13 [get_attribute [get_layers M13] min_width]  \
         M14 [get_attribute [get_layers M14] min_width]  \
         M15 [get_attribute [get_layers M15] min_width]  \
         M16 [get_attribute [get_layers M16] min_width]  \
         M17 [get_attribute [get_layers M17] min_width]  \
         M18 [get_attribute [get_layers M18] min_width]  \
         M19 [get_attribute [get_layers M19] min_width]  \
         AP [get_attribute [get_layers AP] min_width]  \
         " \
        -shield_spacing "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1cut_BW38_UW114 1x1 NR} {VIA78_big_BW114_UW114 1x1 NR} {VIA89_big_BW114_UW114 1x1 NR} {VIA910_big_BW114_UW114 1x1 NR} {VIA1011_big_BW114_UW114 1x1 NR} {VIA1112_big_BW114_UW114 1x1 NR} {VIA1213_big_BW114_UW114 1x1 NR} {VIA1314_1cut_BW114_UW62_NDR 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}


############################################################################
###
###   NDR_C__m78910111213_p152_m1415_p170;
###
###   M[0-6]   : Default
###   M[7-13]  : Roughly 4X
###   M[14-15] : Roughly 3X
###   M[16-19] : Default
###      
############################################################################
if {[sizeof_collection [get_routing_rules -quiet NDR_C__m78910111213_p152_m1415_p170]] > 0} { remove_routing_rule NDR_C__m78910111213_p152_m1415_p170 }
create_routing_rule NDR_C__m78910111213_p152_m1415_p170 \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.152 M8 0.152 M9 0.152 M10 0.152 M11 0.152 M12 0.152 M13 0.152 M14 0.170 M15 0.170 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.096 M15 0.096 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1cut_BW38_UW152 1x1 NR} {VIA78_big_BW152_UW152 1x1 NR} {VIA89_big_BW152_UW152 1x1 NR} {VIA910_big_BW152_UW152 1x1 NR} {VIA1011_big_BW152_UW152 1x1 NR} {VIA1112_big_BW152_UW152 1x1 NR} {VIA1213_big_BW152_UW152 1x1 NR} {VIA1314_1cut_BW152_UW170_NDR 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}

if {[sizeof_collection [get_routing_rules -quiet NDR_C__m78910111213_p152_m1415_p170_SHLD]] > 0} { remove_routing_rule NDR_C__m78910111213_p152_m1415_p170_SHLD }
create_routing_rule NDR_C__m78910111213_p152_m1415_p170_SHLD \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.152 M8 0.152 M9 0.152 M10 0.152 M11 0.152 M12 0.152 M13 0.152 M14 0.170 M15 0.170 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.096 M15 0.096 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " \
        -shield_width " \
         M0 0  \
         M1 0  \
         M2 0  \
         M3 0  \
         M4 0  \
         M5 [get_attribute [get_layers M5] min_width]  \
         M6 [get_attribute [get_layers M6] min_width]  \
         M7 [get_attribute [get_layers M7] min_width]  \
         M8 [get_attribute [get_layers M8] min_width]  \
         M9 [get_attribute [get_layers M9] min_width]  \
         M10 [get_attribute [get_layers M10] min_width]  \
         M11 [get_attribute [get_layers M11] min_width]  \
         M12 [get_attribute [get_layers M12] min_width]  \
         M13 [get_attribute [get_layers M13] min_width]  \
         M14 [get_attribute [get_layers M14] min_width]  \
         M15 [get_attribute [get_layers M15] min_width]  \
         M16 [get_attribute [get_layers M16] min_width]  \
         M17 [get_attribute [get_layers M17] min_width]  \
         M18 [get_attribute [get_layers M18] min_width]  \
         M19 [get_attribute [get_layers M19] min_width]  \
         AP [get_attribute [get_layers AP] min_width]  \
         " \
        -shield_spacing "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.096 M15 0.096 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1cut_BW38_UW152 1x1 NR} {VIA78_big_BW152_UW152 1x1 NR} {VIA89_big_BW152_UW152 1x1 NR} {VIA910_big_BW152_UW152 1x1 NR} {VIA1011_big_BW152_UW152 1x1 NR} {VIA1112_big_BW152_UW152 1x1 NR} {VIA1213_big_BW152_UW152 1x1 NR} {VIA1314_1cut_BW152_UW170_NDR 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}


############################################################################
###
###   NDR_D__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p170;
###
###   M[0-6]   : Default
###   M[7-13]  : Roughly 5X
###   M[13]    : Roughly 6X
###   M[14-15] : Roughly 3X
###   M[16-19] : Default
###      
############################################################################
if {[sizeof_collection [get_routing_rules -quiet NDR_D__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p170]] > 0} { remove_routing_rule NDR_D__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p170 }
create_routing_rule NDR_D__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p170 \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.190 M8 0.152 M9 0.190 M10 0.190 M11 0.190 M12 0.190 M13 0.228 M14 0.170 M15 0.170 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.096 M15 0.096 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1x2_NDR 1x1 NR} {VIA78_big_BW190_UW152_NDR 1x1 NR} {VIA89_big_BW152_UW190_NDR 1x1 NR} {VIA910_big_BW190_UW190_NDR 1x1 NR} {VIA1011_big_BW190_UW190_NDR 1x1 NR} {VIA1112_big_BW190_UW190_NDR 1x1 NR} {VIA1213_big_BW190_UW228_NDR 1x1 NR} {VIA1314_1x2_NDR 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}

if {[sizeof_collection [get_routing_rules -quiet NDR_D__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p170_SHLD]] > 0} { remove_routing_rule NDR_D__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p170_SHLD }
create_routing_rule NDR_D__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p170_SHLD \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.190 M8 0.152 M9 0.190 M10 0.190 M11 0.190 M12 0.190 M13 0.228 M14 0.170 M15 0.170 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.096 M15 0.096 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " \
        -shield_width " \
         M0 0  \
         M1 0  \
         M2 0  \
         M3 0  \
         M4 0  \
         M5 [get_attribute [get_layers M5] min_width]  \
         M6 [get_attribute [get_layers M6] min_width]  \
         M7 [get_attribute [get_layers M7] min_width]  \
         M8 [get_attribute [get_layers M8] min_width]  \
         M9 [get_attribute [get_layers M9] min_width]  \
         M10 [get_attribute [get_layers M10] min_width]  \
         M11 [get_attribute [get_layers M11] min_width]  \
         M12 [get_attribute [get_layers M12] min_width]  \
         M13 [get_attribute [get_layers M13] min_width]  \
         M14 [get_attribute [get_layers M14] min_width]  \
         M15 [get_attribute [get_layers M15] min_width]  \
         M16 [get_attribute [get_layers M16] min_width]  \
         M17 [get_attribute [get_layers M17] min_width]  \
         M18 [get_attribute [get_layers M18] min_width]  \
         M19 [get_attribute [get_layers M19] min_width]  \
         AP [get_attribute [get_layers AP] min_width]  \
         " \
        -shield_spacing "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.096 M15 0.096 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1x2_NDR 1x1 NR} {VIA78_big_BW190_UW152_NDR 1x1 NR} {VIA89_big_BW152_UW190_NDR 1x1 NR} {VIA910_big_BW190_UW190_NDR 1x1 NR} {VIA1011_big_BW190_UW190_NDR 1x1 NR} {VIA1112_big_BW190_UW190_NDR 1x1 NR} {VIA1213_big_BW190_UW228_NDR 1x1 NR} {VIA1314_1x2_NDR 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}


############################################################################
###
###   NDR_E__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p378_m1617_p252;
###
###   M[0-6]   : Default
###   M[7-13]  : Roughly 5X
###   M[13]    : Roughly 6X
###   M[14-15] : Roughly 6X
###   M[16-17] : Roughly 2X
###   M[18-19] : Default
###      
############################################################################
if {[sizeof_collection [get_routing_rules -quiet NDR_E__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p378_m1617_p252]] > 0} { remove_routing_rule NDR_E__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p378_m1617_p252 }
create_routing_rule NDR_E__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p378_m1617_p252 \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.190 M8 0.152 M9 0.190 M10 0.190 M11 0.190 M12 0.190 M13 0.228 M14 0.378 M15 0.378 M16 0.252 M17 0.252 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.144 M15 0.144 M16 0.280 M17 0.280 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1x2_NDR 1x1 NR} {VIA78_big_BW190_UW152_NDR 1x1 NR} {VIA89_big_BW152_UW190_NDR 1x1 NR} {VIA910_big_BW190_UW190_NDR 1x1 NR} {VIA1011_big_BW190_UW190_NDR 1x1 NR} {VIA1112_big_BW190_UW190_NDR 1x1 NR} {VIA1213_big_BW190_UW228_NDR 1x1 NR} {VIA1314_2x2_NDR 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}

if {[sizeof_collection [get_routing_rules -quiet NDR_E__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p378_m1617_p252_SHLD]] > 0} { remove_routing_rule NDR_E__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p378_m1617_p252_SHLD }
create_routing_rule NDR_E__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p378_m1617_p252_SHLD \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.190 M8 0.152 M9 0.190 M10 0.190 M11 0.190 M12 0.190 M13 0.228 M14 0.378 M15 0.378 M16 0.252 M17 0.252 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.144 M15 0.144 M16 0.280 M17 0.280 M18 0.538 M19 0.462 AP 1.800  " \
        -shield_width " \
         M0 0  \
         M1 0  \
         M2 0  \
         M3 0  \
         M4 0  \
         M5 [get_attribute [get_layers M5] min_width]  \
         M6 [get_attribute [get_layers M6] min_width]  \
         M7 [get_attribute [get_layers M7] min_width]  \
         M8 [get_attribute [get_layers M8] min_width]  \
         M9 [get_attribute [get_layers M9] min_width]  \
         M10 [get_attribute [get_layers M10] min_width]  \
         M11 [get_attribute [get_layers M11] min_width]  \
         M12 [get_attribute [get_layers M12] min_width]  \
         M13 [get_attribute [get_layers M13] min_width]  \
         M14 [get_attribute [get_layers M14] min_width]  \
         M15 [get_attribute [get_layers M15] min_width]  \
         M16 [get_attribute [get_layers M16] min_width]  \
         M17 [get_attribute [get_layers M17] min_width]  \
         M18 [get_attribute [get_layers M18] min_width]  \
         M19 [get_attribute [get_layers M19] min_width]  \
         AP [get_attribute [get_layers AP] min_width]  \
         " \
        -shield_spacing "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.144 M15 0.144 M16 0.280 M17 0.280 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1x2_NDR 1x1 NR} {VIA78_big_BW190_UW152_NDR 1x1 NR} {VIA89_big_BW152_UW190_NDR 1x1 NR} {VIA910_big_BW190_UW190_NDR 1x1 NR} {VIA1011_big_BW190_UW190_NDR 1x1 NR} {VIA1112_big_BW190_UW190_NDR 1x1 NR} {VIA1213_big_BW190_UW228_NDR 1x1 NR} {VIA1314_2x2_NDR 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}


############################################################################
###
###   NDR_F__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540;
###
###   M[0-6]   : Default
###   M[7-13]  : Roughly 5X
###   M[13]    : Roughly 6X
###   M[14-15] : Roughly 8X
###   M[16-17] : Roughly 4X
###   M[18-19] : Default
###      
############################################################################
if {[sizeof_collection [get_routing_rules -quiet NDR_F__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540]] > 0} { remove_routing_rule NDR_F__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540 }
create_routing_rule NDR_F__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540 \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.190 M8 0.152 M9 0.190 M10 0.190 M11 0.190 M12 0.190 M13 0.228 M14 0.525 M15 0.525 M16 0.540 M17 0.540 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.135 M15 0.135 M16 0.230 M17 0.230 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1x2_NDR 1x1 NR} {VIA78_big_BW190_UW152_NDR 1x1 NR} {VIA89_big_BW152_UW190_NDR 1x1 NR} {VIA910_big_BW190_UW190_NDR 1x1 NR} {VIA1011_big_BW190_UW190_NDR 1x1 NR} {VIA1112_big_BW190_UW190_NDR 1x1 NR} {VIA1213_big_BW190_UW228_NDR 1x1 NR} {VIA1516_2x2_NDR 1x1 NR} {VIA1617_2x2_NDR 1x1 NR} {VIA1718_NDR 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}

if {[sizeof_collection [get_routing_rules -quiet NDR_F__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_SHLD]] > 0} { remove_routing_rule NDR_F__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_SHLD }
create_routing_rule NDR_F__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_SHLD \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.190 M8 0.152 M9 0.190 M10 0.190 M11 0.190 M12 0.190 M13 0.228 M14 0.525 M15 0.525 M16 0.540 M17 0.540 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.135 M15 0.135 M16 0.230 M17 0.230 M18 0.538 M19 0.462 AP 1.800  " \
        -shield_width " \
         M0 0  \
         M1 0  \
         M2 0  \
         M3 0  \
         M4 0  \
         M5 [get_attribute [get_layers M5] min_width]  \
         M6 [get_attribute [get_layers M6] min_width]  \
         M7 [get_attribute [get_layers M7] min_width]  \
         M8 [get_attribute [get_layers M8] min_width]  \
         M9 [get_attribute [get_layers M9] min_width]  \
         M10 [get_attribute [get_layers M10] min_width]  \
         M11 [get_attribute [get_layers M11] min_width]  \
         M12 [get_attribute [get_layers M12] min_width]  \
         M13 [get_attribute [get_layers M13] min_width]  \
         M14 [get_attribute [get_layers M14] min_width]  \
         M15 [get_attribute [get_layers M15] min_width]  \
         M16 [get_attribute [get_layers M16] min_width]  \
         M17 [get_attribute [get_layers M17] min_width]  \
         M18 [get_attribute [get_layers M18] min_width]  \
         M19 [get_attribute [get_layers M19] min_width]  \
         AP [get_attribute [get_layers AP] min_width]  \
         " \
        -shield_spacing "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.135 M15 0.135 M16 0.230 M17 0.230 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1x2_NDR 1x1 NR} {VIA78_big_BW190_UW152_NDR 1x1 NR} {VIA89_big_BW152_UW190_NDR 1x1 NR} {VIA910_big_BW190_UW190_NDR 1x1 NR} {VIA1011_big_BW190_UW190_NDR 1x1 NR} {VIA1112_big_BW190_UW190_NDR 1x1 NR} {VIA1213_big_BW190_UW228_NDR 1x1 NR} {VIA1516_2x2_NDR 1x1 NR} {VIA1617_2x2_NDR 1x1 NR} {VIA1718_NDR 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}


############################################################################
###
###   NDR_G__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_m1819_p900;
###
###   M[0-6]   : Default
###   M[7-13]  : Roughly 5X
###   M[13]    : Roughly 6X
###   M[14-15] : Roughly 8X
###   M[16-17] : Roughly 4X
###   M[18-19] : Roughly 2X
###      
############################################################################
if {[sizeof_collection [get_routing_rules -quiet NDR_G__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_m1819_p900]] > 0} { remove_routing_rule NDR_G__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_m1819_p900 }
create_routing_rule NDR_G__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_m1819_p900 \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.190 M8 0.152 M9 0.190 M10 0.190 M11 0.190 M12 0.190 M13 0.228 M14 0.525 M15 0.525 M16 0.540 M17 0.540 M18 0.900 M19 0.900 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.2415 M15 0.2755 M16 0.576 M17 0.762 M18 1.345 M19 1.836 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1x2_NDR 1x1 NR} {VIA78_big_BW190_UW152_NDR 1x1 NR} {VIA89_big_BW152_UW190_NDR 1x1 NR} {VIA910_big_BW190_UW190_NDR 1x1 NR} {VIA1011_big_BW190_UW190_NDR 1x1 NR} {VIA1112_big_BW190_UW190_NDR 1x1 NR} {VIA1213_big_BW190_UW228_NDR 1x1 NR} {VIA1516_2x2_NDR 1x1 NR} {VIA1617_2x2_NDR 1x1 NR} {VIA1718_NDR 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}

if {[sizeof_collection [get_routing_rules -quiet NDR_G__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_m1819_p900_SHLD]] > 0} { remove_routing_rule NDR_G__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_m1819_p900_SHLD }
create_routing_rule NDR_G__m7_p190_m8_p152_m9101112_p190_m13_p228_m1415_p525_m1617_p540_m1819_p900_SHLD \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.190 M8 0.152 M9 0.190 M10 0.190 M11 0.190 M12 0.190 M13 0.228 M14 0.525 M15 0.525 M16 0.540 M17 0.540 M18 0.900 M19 0.900 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.2415 M15 0.2755 M16 0.576 M17 0.762 M18 1.345 M19 1.836 AP 1.800  " \
        -shield_width " \
         M0 0  \
         M1 0  \
         M2 0  \
         M3 0  \
         M4 0  \
         M5 [get_attribute [get_layers M5] min_width]  \
         M6 [get_attribute [get_layers M6] min_width]  \
         M7 [get_attribute [get_layers M7] min_width]  \
         M8 [get_attribute [get_layers M8] min_width]  \
         M9 [get_attribute [get_layers M9] min_width]  \
         M10 [get_attribute [get_layers M10] min_width]  \
         M11 [get_attribute [get_layers M11] min_width]  \
         M12 [get_attribute [get_layers M12] min_width]  \
         M13 [get_attribute [get_layers M13] min_width]  \
         M14 [get_attribute [get_layers M14] min_width]  \
         M15 [get_attribute [get_layers M15] min_width]  \
         M16 [get_attribute [get_layers M16] min_width]  \
         M17 [get_attribute [get_layers M17] min_width]  \
         M18 [get_attribute [get_layers M18] min_width]  \
         M19 [get_attribute [get_layers M19] min_width]  \
         AP [get_attribute [get_layers AP] min_width]  \
         " \
        -shield_spacing "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.2415 M15 0.2755 M16 0.576 M17 0.762 M18 1.345 M19 1.836 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1x2_NDR 1x1 NR} {VIA78_big_BW190_UW152_NDR 1x1 NR} {VIA89_big_BW152_UW190_NDR 1x1 NR} {VIA910_big_BW190_UW190_NDR 1x1 NR} {VIA1011_big_BW190_UW190_NDR 1x1 NR} {VIA1112_big_BW190_UW190_NDR 1x1 NR} {VIA1213_big_BW190_UW228_NDR 1x1 NR} {VIA1516_2x2_NDR 1x1 NR} {VIA1617_2x2_NDR 1x1 NR} {VIA1718_NDR 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}


############################################################################
###
###   NDR_CLKA__m78910111213_p114;
###
###   M[0-6]   : Default
###   M[7-13]  : Roughly 3X
###   M[14-19] : Default
###      
############################################################################
if {[sizeof_collection [get_routing_rules -quiet NDR_CLKA__m78910111213_p114]] > 0} { remove_routing_rule NDR_CLKA__m78910111213_p114 }
create_routing_rule NDR_CLKA__m78910111213_p114 \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.0620 M15 0.0620 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1cut_BW38_UW114 1x1 NR} {VIA78_big_BW114_UW114 1x1 NR} {VIA89_big_BW114_UW114 1x1 NR} {VIA910_big_BW114_UW114 1x1 NR} {VIA1011_big_BW114_UW114 1x1 NR} {VIA1112_big_BW114_UW114 1x1 NR} {VIA1213_big_BW114_UW114 1x1 NR} {VIA1314_1cut_BW114_UW62_NDR 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}

if {[sizeof_collection [get_routing_rules -quiet NDR_CLKA__m78910111213_p114_SHLD]] > 0} { remove_routing_rule NDR_CLKA__m78910111213_p114_SHLD }
create_routing_rule NDR_CLKA__m78910111213_p114_SHLD \
        -default_reference_rule \
        -taper_distance 3.0 \
        -snap_to_track \
        -driver_taper_distance 0 \
        -widths "M0 0.0130 M1 0.0280 M2 0.0120 M3 0.0180 M4 0.0190 M5 0.0200 M6 0.0380 M7 0.114 M8 0.114 M9 0.114 M10 0.114 M11 0.114 M12 0.114 M13 0.114 M14 0.0620 M15 0.0620 M16 0.1260 M17 0.1260 M18 0.4500 M19 0.4500 AP 1.8000  " \
        -spacings "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " \
        -shield_width " \
         M0 0  \
         M1 0  \
         M2 0  \
         M3 0  \
         M4 0  \
         M5 [get_attribute [get_layers M5] min_width]  \
         M6 [get_attribute [get_layers M6] min_width]  \
         M7 [get_attribute [get_layers M7] min_width]  \
         M8 [get_attribute [get_layers M8] min_width]  \
         M9 [get_attribute [get_layers M9] min_width]  \
         M10 [get_attribute [get_layers M10] min_width]  \
         M11 [get_attribute [get_layers M11] min_width]  \
         M12 [get_attribute [get_layers M12] min_width]  \
         M13 [get_attribute [get_layers M13] min_width]  \
         M14 [get_attribute [get_layers M14] min_width]  \
         M15 [get_attribute [get_layers M15] min_width]  \
         M16 [get_attribute [get_layers M16] min_width]  \
         M17 [get_attribute [get_layers M17] min_width]  \
         M18 [get_attribute [get_layers M18] min_width]  \
         M19 [get_attribute [get_layers M19] min_width]  \
         AP [get_attribute [get_layers AP] min_width]  \
         " \
        -shield_spacing "M0 0.010 M1 0.020 M2 0.014 M3 0.017 M4 0.019 M5 0.022 M6 0.038 M7 0.076 M8 0.076 M9 0.076 M10 0.076 M11 0.076 M12 0.076 M13 0.076 M14 0.081 M15 0.071 M16 0.160 M17 0.140 M18 0.538 M19 0.462 AP 1.800  " 
# Error: In command create_routing_rule, Custom via def VIA67_1cut_BW38_UW114 cannot be used to create a routing rule. Only simple via defs may be specified. (NDMUI-883)
#        -vias {{VIA01_1cut_BW13_UW28 1x1 NR} {VIA12_1cut_BW28_UW12 1x1 NR} {VIA23_1cut_BW12_UW18 1x1 NR} {VIA34_1cut_BW18_UW19 1x1 NR} {VIA45_1cut_BW19_UW20 1x1 NR} {VIA56_1cut_BW20_UW38 1x1 NR} {VIA67_1cut_BW38_UW114 1x1 NR} {VIA78_big_BW114_UW114 1x1 NR} {VIA89_big_BW114_UW114 1x1 NR} {VIA910_big_BW114_UW114 1x1 NR} {VIA1011_big_BW114_UW114 1x1 NR} {VIA1112_big_BW114_UW114 1x1 NR} {VIA1213_big_BW114_UW114 1x1 NR} {VIA1314_1cut_BW114_UW62_NDR 1x1 NR} {VIA1415_1cut 1x1 NR} {VIA1516_1cut 1x1 NR} {VIA1617_1cut 1x1 NR} {VIA1718_1cut 1x1 NR} {VIA1819_1cut 1x1 NR} {VIA19AP_1cut 1x1 NR}}


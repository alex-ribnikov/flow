####################################################################################################
## insert_column_clock_skew.tcl
##
## Adds pairs of inverters to slightly skew the clock between columns.
##
####################################################################################################


##--------------------------------------------------------------------------------------------------
## USER SETTINGS
##--------------------------------------------------------------------------------------------------

## repeaters_per_column : Set the number of repeater pairs to insert per column
## Format is column_number then repeater_count
##
## NOTE: we skipped column 0 on purpose
set repeaters_per_column {
    1 1
    2 1
    3 2
    4 2
    5 3
    6 3
    7 4
}

## lib_cell : the library cell to insert
##
## NOTE: F6UNAA_LPDSINVGT5X96 was chosen to match the other loads in the H-tree
set lib_cell F6UNAA_LPDSINVGT5X96


## horizontal_pitch/vertical_pitch : distance between placement origins of new cells
##
## This is determined by the F6UNAA_LPDSINVGT5X96 cell site distance
set horizontal_pitch 27.132
set vertical_pitch   10.08

##--------------------------------------------------------------------------------------------------
## Update tool settings
##--------------------------------------------------------------------------------------------------

set settings {
    eco_honor_dont_use false
    eco_update_timing false
    eco_refine_place false
    eco_check_logical_equivalence false
    eco_honor_fixed_wires false
    route_design_with_si_driven false
    route_design_detail_fix_antenna false
    route_design_with_timing_driven false
    place_detail_eco_max_distance 100
}

set revert_settings {}

foreach {setting value} $settings {
    lappend revert_settings $setting [get_db $setting]
    set_db $setting $value
}


##--------------------------------------------------------------------------------------------------
## Add repeaters to each column
##--------------------------------------------------------------------------------------------------

## Remove any existing detail routing
delete_routes -type regular

## Save a list of new instantance to place
set new_insts {}

foreach {col count} $repeaters_per_column {
    ## Look for level1 tap A cells for this column
    set l0_taps [lsort [get_db insts level0_tap_a_t*${col}]]

    ## Figure out direction to place skew cells in
    if { [expr $col % 2] == 0 } {
        set direction left
    } else {
        set direction left
    }

    ## We need 2 inverters per count
    set count [expr $count *2]

    ## For each tap, insert $count repeater pairs on output pin
    foreach tapa $l0_taps {
        ## Get the basename of $tapa and use to find tapb
        set namea [get_db $tapa .name]
        set nameb [regsub _a_ $namea _b_ ]
        set tapb [get_db insts $nameb]

        puts "-I- Adding $count repeater(s) to $namea and $nameb inputs"
        set pin [get_db pins [list $namea/i $nameb/i]]

        ## Figure out starting location
        set bboxa [lindex [get_db $tapa .bbox] 0]
        set bboxb [lindex [get_db $tapb .bbox] 0]
        set llx [expr min([lindex $bboxa 0],[lindex $bboxb 0])]
        set lly [expr min([lindex $bboxa 1],[lindex $bboxb 1])]
        set urx [expr max([lindex $bboxa 2],[lindex $bboxb 2])]
        set ury [expr max([lindex $bboxa 3],[lindex $bboxb 3])]
        
        # ## Set x0 to the left or right of the bbox 
        # if { $direction == "left" } {
        #     set x0 $llx
        # } else {
        #     set x0 $urx
        # }
        
        ## We have 2 super_inv_rows and hence 2 row positions
        set yr0 $lly
        set yr1 [expr $lly - $vertical_pitch]

        ## Start to right of bbox
        set x0 $urx

        ## Start at col 0 and row 1
        set super_inv_col 0
        set super_inv_row 1

        ## Special case for col == 7
        if { $col == 7 } {
            set super_inv_row 0
        }

        ## Run the eco_add_repeater command $count times
        for { set i 0 } { $i < $count  } { incr i } {
            ## Choose super_inv_row
            set y0 [set yr${super_inv_row}]

            ## Shift left or right depending on $direction
            ## Only shift for super_inv_row 1
            ## Always shift for col 7
            if { $super_inv_row == 1 || $col == 7 } {
                if { $direction == "left" } {
                    set x0 [expr $x0 - $horizontal_pitch]
                } else {
                    set x0 [expr $x0 + $horizontal_pitch]
                }
            }

            ## Name the new objects
            set prefix [regsub _a ${namea}_skew_${i} ""]
            
            ## Insert once instance of $lib_cell
            eco_add_repeater \
                -cells $lib_cell \
                -name ${prefix} \
                -new_net_name ${prefix}_net \
                -pins [get_db $pin .name]  \
                -location [list $x0 $y0]
            
            ## Flip the correct way to avoid PG shorts
            set_db [get_db insts ${prefix}] .orient MX

            ## Connect next instance to the input pin of the current instance
            set pin [get_db pins ${prefix}/i]

            ## Save for later
            lappend new_insts ${prefix}

            ## Increment column
            incr super_inv_col

            ## Alternate between rows (after super_inv_col 1)
            ## Do not alternate for col 7
            if { $super_inv_col > 1 && $col != 7 } {
                if { $super_inv_row == 0 } {
                    set super_inv_row 1
                } else {
                    set super_inv_row 0
                }
            }
        }
    }

    ## Pad north/south filler for the same col
    set north_pin [get_db pins i_grid_quad_north_filler_i_grid_quad_north_filler_c$col/grid_clk]
    set south_pin [get_db pins i_grid_quad_south_filler_i_grid_quad_south_filler_c$col/grid_clk]

    foreach pin [list $north_pin $south_pin] {
        ## Place just below driver
        set net [get_db $pin .net]
        set location [lindex [get_db $net .drivers.inst.location] 0]
        set x [lindex $location 0]
        set y [expr [lindex $location 1] - $vertical_pitch]

        for { set i 0 } { $i < $count  } { incr i } {
            set prefix [lindex [split [get_db $pin .name] "/"] 0]_skew_${i}
            eco_add_repeater \
                -cells $lib_cell \
                -name ${prefix} \
                -new_net_name ${prefix}_net \
                -pins [get_db $pin .name]  \
                -location [list $x $y]
            set x [expr $x + $horizontal_pitch]
            lappend new_insts $prefix
        }
    }
}
be_legalize_super_inv $new_insts false 400
set_db [get_cells $new_insts] .place_status fixed

return
#redirect reports/$STAGE/post_skew_insertion.check_super_inv_drc.rpt check_super_inv_drc -tee 
write_db out/db/$DESIGN_NAME.post_skew_insertion.enc.dat


##--------------------------------------------------------------------------------------------------
## Isolate output clocks
##--------------------------------------------------------------------------------------------------

source ./scripts/templates/quad/pn99_clock_recipe/isolate_output_clocks.tcl
be_legalize_super_inv [get_cells $new_insts -filter full_name=~*split*] false 400
set_db [get_cells $new_insts] .place_status fixed

t [add_to_collection [get_pins */grid_clk*] [get_ports *grid_clk_to*]] {count_levels_from_source $o}

redirect reports/$STAGE/post_port_isolation.check_super_inv_drc.rpt check_super_inv_drc -tee 
write_db out/db/$DESIGN_NAME.post_port_isolation.enc.dat


##--------------------------------------------------------------------------------------------------
## Insert blockages and legalize super invs
##--------------------------------------------------------------------------------------------------

## Unplace all regular instances excluding clock buffers/invs, macros and physical cells
if { ![info exists new_insts] } {
    set new_insts [get_db [get_db insts {*filler*skew* level*_tap_*skew* grid_clk_to*split*}] .name]
}
set_db [get_db insts i_vtmon_remote_sensor] .place_status fixed
set clock_nets [get_db nets -if .is_clock]
set clock_cells [get_db [get_cells -of $clock_nets]]
set comb_clock_cells [get_db $clock_cells -if {.is_sequential == false}]
set cells_to_unplace [get_db insts -if {.is_physical == false && .is_macro == false && .place_status != fixed}]
set cells_to_unplace_without_comb_clock [lmap inst $cells_to_unplace {
    if { $inst in $comb_clock_cells } {
        continue
    } else {
        set inst
    }
}]
set_db $cells_to_unplace_without_comb_clock .place_status unplaced

## Add placement blockage to stop buffer being inserted near routing channels between blocks
source scripts_local/cts_hard_blockages.tcl

## Legalize super inverters (run it twice for some reason, still investigating)
be_legalize_super_inv $new_insts false 400
be_legalize_super_inv $new_insts false 400

## Remove placement blockage
delete_obj [get_db place_blockages carpet_cts_blockage]

## Fix placement of skew instances
set_db [get_db insts $new_insts] .place_status fixed

## Revert place_status of regular cells
set_db $cells_to_unplace_without_comb_clock .place_status placed

## Remove overlaps of regular cells and skew instances
place_detail

redirect reports/$STAGE/post_skew_legalize.check_super_inv_drc.rpt check_super_inv_drc -tee 
write_db out/db/$DESIGN_NAME.post_skew_legalize.enc.dat


##--------------------------------------------------------------------------------------------------
## Route clocks
##--------------------------------------------------------------------------------------------------
set_db route_early_global_top_routing_layer 18
set_db design_top_routing_layer 18

# Select all clock tree cells to re-route
set cells [get_cells -hier {*skew* *split*}] 
set_db $cells .place_status fixed
set nets  [get_nets -of $cells]
set nets  [get_db -uniq [add_to_collection $nets [get_nets -of [get_ports {grid_clk_to* grid_clk_from* grid_clk}]]]]
set cells [get_cells -of [get_db  $nets .drivers]]

quad_clock_route $cells
#if { [llength $nets] == 0 } { puts "-E- No nets found for given cells" ;  return -1 }
#
#delete_routes -net $nets
#be_build_super_inv_vp $cells
#
#write_db out/db/$DESIGN_NAME.post_via_pillar.enc.dat
#
#if { [get_db route_rules grid_clk_vp_rule_2] == "" } {
#    create_route_rule -name grid_clk_vp_rule_2 \
#        -width   {M1  0.02 M2  0.02  M3  0.02  M4  0.02  M5  0.038 M6  0.04 M7  0.038 M8 0.04 
#                  M9 0.038 M10 0.04 M11 0.076 M12 0.062 M13 0.688 M14 0.396 M15 0.7} \
#        -init NDR_A__m6_p080__m7_p076__m8_p080__m9_p076__m10_p080__m11_p076 \
#        -spacing {M1 0.014 M2 0.015 M3 0.022 M4 0.022 M5 0.038 M6 0.04 M7 0.038 M8 0.04 M9 0.038 M10 0.04}
#}
#
#set_db $nets .route_rule {}
#foreach net [get_db $nets .name] {
#    set_route_attributes -reset -nets $net
#    set_route_attributes -nets $net \
#        -top_preferred_routing_layer 18 -bottom_preferred_routing_layer 17 -preferred_routing_layer_effort high \
#        -route_rule grid_clk_vp_rule_2
#}
#
#be_route_p2p [get_nets $nets]
#
#foreach {setting value} $settings {
#    set_db $setting $value
#}
#
#deselect_obj -all
#select_obj $nets
#route_global_detail -selected
#deselect_obj -all

check_super_inv_drc

# write_db out/db/$DESIGN_NAME.post_skew_route.enc.dat

##--------------------------------------------------------------------------------------------------
## Revert settings to original values
##--------------------------------------------------------------------------------------------------

foreach {setting value} $revert_settings {
    set_db $setting $value
}

return


##--------------------------------------------------------------------------------------------------
## Reference commands & notes
##--------------------------------------------------------------------------------------------------

## Add via pillars to new instances
be_build_super_inv_vp $new_insts

## Route clock nets (includes adding via pillars)
quad_clock_route $new_insts

## Check drc over super invs
check_super_inv_drc

## Route regular clock nets without via ladders
set cells [get_db [get_cells $cells]]
set nets  [get_db [get_nets -of $cells]]
delete_routes -net    $nets

foreach net [get_db $nets .name] {
    set_route_attributes -reset -nets $net
    set_route_attributes -nets $net \
                        -si_post_route_fix false -skip_antenna_fix false -preferred_routing_layer_effort high \
                        -route_rule grid_clk_vp_rule_2
}

## Export data for StarRCXT and PrimeTime
## NOTE: out/db/$DESIGN_NAME.cts.enc.dat.bak contains the original cts database
write_db  -verilog out/db/$DESIGN_NAME.cts.enc.dat
write_def -routing out/def/$DESIGN_NAME.cts.def.gz
so $cells
write_def -selected out/def/$DESIGN_NAME.clock_cells_only.def.gz
so $nets
write_def -routing -selected out/def/$DESIGN_NAME.clock_nets_only.def.gz

## Then run the following commands:
./run_starrc.csh -stage cts -with_dm false
./run_pt.csh -stage cts -read_spef false -read_gpd true -single -views func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup -interactive


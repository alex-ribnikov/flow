####################################################################################################
#
# This script isolates grid_quadrant block's output clocks
#
####################################################################################################


#---------------------------------------------------------------------------------------------------
# Check that output clock ports are isolated from the rest of the tree
#---------------------------------------------------------------------------------------------------

set isolated_clock_ports [get_db ports grid_clk_to_*]
puts "-I- sanity checking isolatation of [llength $isolated_clock_ports] clock ports ..."

set needs_isolation {}

foreach port_obj $isolated_clock_ports {
    set net_obj [get_db $port_obj .net]
    set loads [get_db $net_obj .loads]
    if { [llength $loads] > 1} {
        puts "-E- [get_db $port_obj .name] needs isolating"
        lappend needs_isolation $port_obj
    }
}

set error_count [llength $needs_isolation]
if { $error_count } {
    puts "-E- found $error_count ports that need isolation"
} else {
    puts "-I- all clock ports are isolated"
}


#---------------------------------------------------------------------------------------------------
# Fix broken outputs
#---------------------------------------------------------------------------------------------------

foreach port_obj $needs_isolation {
    set prefix [regsub -all {[\[\]]} [get_db $port_obj .name] {_}]_split

    # Find current driver and net of port
    set net_obj [get_db $port_obj .net]
    set driver_pin [get_db $net_obj .drivers]
    set driver_inst [get_db $driver_pin .inst]

    set x [get_db $driver_inst .location.x]
    set y [expr [get_db $driver_inst .location.y] + $vertical_pitch]

    # Create new inst using same cell and location as driver
    set new_inst [create_inst \
        -base_cell [get_db $driver_inst .base_cell] \
        -location [list $x $y] \
        -orient [get_db $driver_inst .orient] \
        -name $prefix
    ]

    # Save for legalize later
    # NOTE: added $driver_inst to list to work-around bad placement
    lappend new_insts $prefix ; #$driver_inst

    # Create new output net
    set new_net [create_net -name ${prefix}_net]

    # Connect new inverter input to same net as driver input
    set driver_input [get_db $driver_inst .pins -if {.direction == in}]
    set driver_input_net [get_db $driver_input .net]
    connect_pin \
        -inst [get_db $new_inst .name] \
        -pin [get_db $driver_input .base_name] \
        -net [get_db $driver_input_net .name]

    # Disconnect all input pins from old net (leaving the port connected)
    set pins_to_move [get_db $net_obj .loads -if {.obj_type == pin}]
    foreach pin $pins_to_move {
        disconnect_pin -inst [get_db $pin .inst.name] -pin [get_db $pin .base_name]
    }

    # Connect all input pins to new net
    foreach pin $pins_to_move {
        connect_pin \
            -inst [get_db $pin .inst.name] \
            -pin [get_db $pin .base_name] \
            -net [get_db $new_net .name]
    }

    # Connect new net to new inst output
    set new_inst_output [get_db $new_inst .pins -if {.direction == out}]
    connect_pin \
        -inst [get_db $new_inst .name] \
        -pin [get_db $new_inst_output .base_name] \
        -net [get_db $new_net .name]

}


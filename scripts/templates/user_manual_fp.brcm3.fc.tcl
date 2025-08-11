# Defines the coordinates for the block boundary.
# Can be specified using either real numbers or integers.
# Example: {{0 0} {0 29} {239 29} {239 12} {240 12} {240 0}}
set block_boundary {{0.0000 0.0000} {0.0000 315.1720} {7628.8800 315.1720} {7628.8800 130.4160} {7660.8000 130.4160} {7660.8000 0.0000}}

# Specifies the path to the macros and blockages file.
# Supported formats: .tcl, .def, or .def.gz
set macros_file "/bespace/users/rinate/nextflow/be_work/brcm3/d2d_wrap_n/work_PN99/pnr_1307/MACROS_and_BLOCKAGES.def.gz"

# Specifies the path to the ports file.
# Supported formats: .tcl, .def, or .def.gz
set ports_file "/bespace/users/rinate/nextflow/be_work/brcm3/d2d_wrap_n/work_PN99/pnr_1307/PINS.def.gz"

# Specifies the path to an optional Tcl file for custom blockages.
# This file is read prior to the automatic blockage creation.
# Leave empty if no custom blockage file is needed.
set blockage_file ""

# Specifies the path to an optional Tcl file to be sourced at the end of the floorplan flow.
# Leave empty if no post-floorplan script is needed.
set post_fp_file ""

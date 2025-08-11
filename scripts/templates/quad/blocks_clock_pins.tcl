# CBUI
edit_pin -pin grid_clk -layer M15 -assign {784.30   1.67} -fixed_pin -fix_overlap 1 -snap track -side inside -pin_depth 0.5 -pin_width 0.126

# CBUE
edit_pin -pin grid_clk -layer M15 -assign {783.70 542.32} -fixed_pin -fix_overlap 1 -snap track -side inside -pin_depth 0.5 -pin_width 0.126

# NFI
edit_pin -pin grid_clk       -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {3.09 545.37} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -pin grid_clk_div_2 -layer M9                 -assign {25   0.0000} -fixed_pin -fix_overlap 1  -snap track

# TCU
edit_pin -pin grid_clk -layer M15 -assign {783.70 542.32} -fixed_pin -fix_overlap 1 -snap track -side inside -pin_depth 0.5 -pin_width 0.126

# WEST 0
edit_pin -pin grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {15.56 541.87} -fixed_pin -fix_overlap 1 -side inside -snap track

# WEST ECORE
edit_pin -pin grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {599 1041} -fixed_pin -fix_overlap 1 -side inside -snap track

# EAST
edit_pin -pin grid_clk      -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {74.35 541.87} -fixed_pin -fix_overlap 1 -side inside -snap track
edit_pin -pin east_grid_clk -layer M15 -pin_depth 0.5 -pin_width 0.126 -assign {84 546.87} -fixed_pin -fix_overlap 1 -side inside -snap track

# NORTH
edit_pin -pin grid_clk -layer M15 -assign {785.764 0} -fixed_pin -fix_overlap 1 -snap track

# SOUTH 0 
edit_pin -pin grid_clk -layer M15 -assign {400     40.32} -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track

# SOUTH
edit_pin -pin grid_clk -layer M15 -assign {785.764 40.32} -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track

# SOUTH EAST
edit_pin -pin grid_clk -layer M15 -assign {25      50.40} -spread_direction counterclockwise   -fixed_pin -fix_overlap 1 -snap track


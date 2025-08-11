redirect -var garbage { init_be_scripts }

reset_path_group -all

set icgs [ory_get_clock_gates]
set gcu  [remove_from_collection [ory_get_cells *i_gcu_cluster*] $icgs]
set gsu  [remove_from_collection [ory_get_cells *i_gsu_cluster*] $icgs]
set gmu  [remove_from_collection [ory_get_cells *i_gmu_cluster*] $icgs]

set_path_group -to   $icgs         -name clock_gates
set_path_group -from $gcu -to $gcu -name gcu_cluster
set_path_group -from $gsu -to $gsu -name gsu_cluster
set_path_group -from $gmu -to $gmu -name gmu_cluster
set_path_group -from $gmu -to $gcu -name gmu2gcu_cluster
set_path_group -from $gmu -to $gsu -name gmu2gsu_cluster
set_path_group -from $gcu -to $gsu -name gcu2gsu_cluster
set_path_group -from $gcu -to $gmu -name gcu2gmu_cluster
set_path_group -from $gsu -to $gmu -name gsu2gmu_cluster
set_path_group -from $gsu -to $gcu -name gsu2gcu_cluster

set_path_group -to   [get_ports -filter direction==out] -name reg2out
set_path_group -from [get_ports -filter direction==in]  -name in2reg

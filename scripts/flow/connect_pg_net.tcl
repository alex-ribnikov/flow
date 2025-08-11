
# NDMUI-096
set_app_options -as_user -list {
mv.pg.default_power_supply_net_name VDD 
mv.pg.default_ground_supply_net_name VSS
}


connect_pg_net -automatic


source ./scripts/layout/incr_pg_mesh.low_blocks.tcl



# reminders:
#1. update search proc - done
#2 catch cases of M3 shapes in block boundary to be cut, check other layer below M5 as well
# check_pg_drc error data
# fix maxstackrange for via7 also , above mem with M7 as top layer - done
# add safety flag to check if via9 and via10 already were shifted -done
# add automatic revert to original KOM on specific mems - done
# review and add maxpattern drc fix
# review and add via0 coloring drc fix
# check if possible to replace the exact length filtering with more genral in pro cclean_pg_around_die_auto

########################################################## run control  ##########################################################
set run_resize_mem_kom_for_pg_cut 1 ;# default is 0. in case user want to have narrow channels without boundary cells , it go to run_resize_mem_kom_for_pg_cut and edit the script with a list of mems to extent thier KOM.
set run_clean_pg_around_mems_auto 1
set run_clean_pg_around_die_auto 1
set run_connect_mems_to_pg_mesh 1
set run_clean_pg_around_rectangular_block 0  ;# default is 0 , NOTE! for hier-blocks : user need to set to 1 only after the correct cut values per each subblock, see note #5 below
set run_mark_and_connect_borderrowpwall_objects 0 ;# default is 0
set run_mark_and_connect_borderrownwall_objects 0;# default is 0
set run_check_pg_drc_pre 1
set run_clean_danglin_shapes_vias 1
set run_shift_via9_via10_above_mems 1 ;# to avoid stackRangeMaxStackLevel DRC violations in TF
set run_auto_fix_drc 1 
set run_sanity_check_drc 1
set run_auto_fix_missing_via 1 ;# fix missing pg VIA0
set run_revert_resize_mem_kom_for_pg_cut 1 ;# default is to keep KOM extended , if set to 1 then it will revert to original KOM , before extension BUT user will have to put additional blockage to avoid any cells in channels
set run_overide_pg_mesh_locally 0 ;# always 0 except special blocks , for example cfg_car_top
set run_clean_m5_VIA5_m6_VIA6_from_block_boundary 1 ;# set 1 if want to keep only M7 continous, this is the default.
set run_check_lvs 0;# set this to 1 if the design is legalized , otherwise default is 0

##########################################################   proc Notes  ########################################################## 

# 1. Auto clean PG around mems {proc:clean_pg_around_mems_auto} :
# this proc will automatically cut the PG shapes and via around mems upto top-mem layer with below assumptions:
# on east and west sides, if boundary cells exist it cuts the mesh at space 0.696 + 0.238 offset to M0 boundary cells pin, if boundary cells not exist it cuts at 0.696
# on south and north sides, if boundary cells exist it cuts the mesh at the first row above the mem halo (wither low or high row side) ,if boundary cells not exist it cuts at 0.8/0.9 which is the mem Keepout margin halo
# if user abut memories it should make sure no gap is between those mems except the reqiored halo, otherwise there might be left dangling pg vias and shapes
# VIAs that intersect with the above lines will be remove or left depend on the value of cut_intersect_vias

# example1 clean_pg_around_mems_auto $mems 1 : this will clean pf around $mems and will also remove intersecting vias with the lines of cuts

# 2 . Manual clean PG around mems {proc:clean_pg_inside_bbox_manual} :
#  this proc will clean vias OR shapes inside a given bbox
# example1    clean_pg_inside_bbox_manual 221.5610 161.9645 222.2330 162.3675 M1
# example2   clean_pg_inside_bbox_manual 221.5610 161.9645 222.2330 162.3675 VIA3

#3. Auto clean PG below M5 around die edges {proc:clean_pg_around_die_auto}:
# example clean_pg_around_die_auto , no args , executed on top_design level
# 
#4. Auto connect mems pins to upper mesh {proc:connect_mems_to_pg_mesh}:
# works on all mems types (m5,m6,m7).
# use VIA master defined in the main scripts by the USER.
# NOTES : for mem type of m6 ,  VSS via6 connection genearate a DRC error stackRangeMaxStackLevel, temp to bypass using "-drc check_but_no_fix"
# USER need to review if this is real drc issue in signoff run, if yes than fix PG def by brcm

#5. Auto clean_pg_around_rectangular_block {proc:clean_pg_around_rectangular_block} :
# proc clean pg around subblock with given cut offsets from its boundary specified by the USER
# works on rectangular block , 
# example clean_pg_around_rectangular_block i_cfg_pll_wrap/i_cfg_pll/pll 15.192 15.301 15.192 15.301 1 M0

#6. Auto connect BORDERWALL P and N cells to pg mesh {proc:run_mark_and_connect_borderrow?wall_objects
# this proc will keep the M1 verticall shape to connect the M0 pin of the BORDERWALL cells to VSS or VDD depende on cell type
# will also create the missing VIA0 for this connection to pass LVS

##########################################################   start - (optional) open_block   ########################################################## 

proc mt {args} {
	global tab_count
	set tab_string ""
	set time [clock seconds]
	set command [join $args]
	incr tab_count
	for {set i $tab_count} {$i > 0} {set i [expr $i - 1]} {
		append tab_string "\t"
	} 
	echo "${tab_string}### <Start> ### Started timer for command \"$command\" (Start at: [lindex [date] 2]\/[lindex [date] 1]\/[lindex [date] 4] - [lindex [date] 3])"
	uplevel $args
	set mins [expr ([clock seconds] - $time) / 60]
	set hours [expr $mins / 60]
	set mins [expr $mins % 60]
	set secs [expr ([clock seconds] - $time) % 60]
	echo [format "${tab_string}###  <End>  ### Runtime: %02d:%02d:%02d for command \"$command\" (Ended at: [lindex [date] 2]\/[lindex [date] 1]\/[lindex [date] 4] - [lindex [date] 3])" $hours $mins $secs]
	set tab_count [expr $tab_count - 1]
}
# mt ...

save_block -as pre_pg_fix


##############################################################   PG verification and fixing   ##############################################################    
#connect_pg_net -automatic
connect_pg_net -net $vdd_net [get_pins -hier -filter name==${vdd_net}]
connect_pg_net -net $vss_net [get_pins -hier -filter name==${vss_net}]

#pg connectivity
if {$run_clean_danglin_shapes_vias} {
    set check_pg_connectivity_objects [check_pg_connectivity]
    set floating_vias [get_vias $check_pg_connectivity_objects -quiet] ; if {[sizeof_collection $floating_vias]} {remove_vias $floating_vias}
    set floating_shapes [get_shapes $check_pg_connectivity_objects -quiet]; if {[sizeof_collection $floating_shapes]} {remove_shapes $floating_shapes}
    # final pg connectivity
    check_pg_connectivity -error_view_name check_pg_connectivity.post
}


#missing via
#connect_pg_net -automatic
if {$run_auto_fix_missing_via} { auto_fix_missing_via $vdd_net $vss_net } ;# please note , some of the added VIA0 will be removed later on when fixing PG drc, for specific location where vertical M1 straps intersect with boundary celll RB region

# final missing via
check_pg_missing_vias -nets "$vdd_net $vss_net" > check_pg_missing_vias.${design_name}.post

# drc fix
check_pg_drc > check_pg_drc.${design_name}.global.post_b4_fix

if {$run_auto_fix_drc} { auto_fix_drc } ;# this is done after missing vias, to remove drc-violated vias added by missing via fixing

# pg coloring
#derive_pg_mask_constraint -overwrite ;# derive correct pg coloring
#derive_pg_mask_constraint
#derive_pg_mask_constraint -derive_cut_mask

# WA to fix coloring issue in M5 due to new PG version from BRDM : project/foundry/TSMC/N3/BRCM/PDK/20250416/inqa/  ;# updated by BRCM

#set all_via4_pg [get_vias -filter cut_layer_names==VIA4&&valid_for_cut]
#set all_via5_pg [get_vias -filter cut_layer_names==VIA5&&valid_for_cut]

#write_routes -objects $all_via4_pg -output v4.pg
#write_routes -objects $all_via5_pg -output v5.pg

#remove_vias $all_via4_pg
#remove_vias $all_via5_pg

derive_pg_mask_constraint -check_fix_shape_drc -overwrite

#source v4.pg ;# revert back v4 and v5
#source v5.pg

# final drc
check_pg_drc  > check_pg_drc.${design_name}.global.post

# final lvs
if {$run_check_lvs} { check_lvs -checks {short open} -nets "$vdd_net $vss_net" -exclude_child_cell_types lib_cell -max_errors 10000 -check_child_cells 0 -open_reporting detailed }

if {$run_revert_resize_mem_kom_for_pg_cut} {
    # Auto revert back the original KOMs
    if {[sizeof_collection [get_cells $mems -filter extended_kom!=""]]} {
	set mems_to_revert [get_object_name [get_cells $mems -filter extended_kom!=""]]
	foreach xx $mems_to_revert {
	    set kom [get_keepout_margins -of_objects [get_cells $xx]]
	    set_attribute $kom margin [get_attribute [get_cells $xx] extended_kom]
	}
    }
}

save_block

return ;# end


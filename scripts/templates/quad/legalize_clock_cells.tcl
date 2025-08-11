# spread the iste rows of the Super Buffers legal locations
create_row -site SPRBUF -polygon {{705.432 5.25} {705.432 1038.24} {0.0 1038.24} {0.0 8940.96} {9713.256 8940.96} {9713.256 8678.88} {9876.048 8678.88} {9876.048 4465.44} {9821.784 4465.44} {9821.784 4243.68} {9876.048 4243.68} {9876.048 231.84} {9821.784 231.84} {9821.784 5.25}} -spacing 9.03 -no_abut -no_flip_rows

# write def, move X by 8.3895, read it to the design
write_def ex.def -no_core_cells -no_std_cells -no_special_net -no_tracks
cat ex.def | awk "{if (NF > 10 && \$3 == \"SPRBUF\") {m=\$4+16779; \$4=m}; print}" > ex1.def
read_def ex1.def

# set the Super-Buffer at MX orientation and the site-rows + Enabling 60u as a legal movement
set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .orient mx
set_db [get_db rows  -if {.site.name == SPRBUF}] .orient mx
set_db place_detail_eco_max_distance 60
set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .base_cell.site SPRBUF

set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .place_status placed

# Legalizing on the "special" site rows
place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .name]

# remove the site rows, verify the Super-Buffers are at MX orientation and change their link to default sites
delete_obj [get_db rows -if {.site.name == SPRBUF}]
set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .orient mx
set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .base_cell.site CORE_6

# legalize place again to see that there are no movements
place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .name]

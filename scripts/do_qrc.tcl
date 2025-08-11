input_db -type def -lef_file_list LEF_FILE_LIST

extraction_setup -stream_layer_map_file STREAM_LAYER_MAP_FILE

input_db -type def -gds_file_list MACRO_GDS_FILE_LIST
graybox -type layout

##### MMMC : define rc corners


process_technology \
 -technology_library_file TECHNOLOGY_LIBRARY_FILE \
 -technology_name    TECHNOLOGY_NAME      \
 -technology_corner TECHNOLOGY_CORNER 	\
 -temperature TEMPERATURE
 

## 29.9.2021 Roy: need to check this ERROR:  -strict_maskshift_checking false
extraction_setup \
 -strict_maskshift_checking false \
 -max_fracture_length 25 \
 -technology_layer_map   TECHNOLOGY_LAYER_MAP 
   

#extract             -selection all -type rc_coupled
extract 	    -selection all -type c_only_coupled
capacitance -decoupling_factor 1.0 -mode high


parasitic_reduction -enable_reduction false
global_nets         -nets GLOBAL_NETS 
metal_fill   -type "floating" \


output_db \
 -type                   spef \
 -hierarchy_delimiter    "/"\
 -subtype                "starN" \
 -disable_subnodes       false \

filter_coupling_cap \
 -cap_filtering_mode               absolute_and_relative \
 -total_cap_threshold              0  \
 -coupling_cap_threshold_absolute  1e-15  \
 -coupling_cap_threshold_relative  1.0e-2 \

output_setup -file_name out/spef/DESIGN_NAME.STAGE \
             -compressed true \

log_file     -dump_options true -max_warning_messages 100 -file_name log/do_qrcExtract_DESIGN_NAME.log


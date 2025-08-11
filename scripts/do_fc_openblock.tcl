#################################################################################################################################################################################
#																						#
#	this script will run Fusion_compiler  																		#
#	variable received from shell are:																	#
#		CPU		- number of CPU to run.8 per license														#
#		DESIGN_NAME	- name of top model																#
#		IS_PHYSICAL	- runing physical synthesis															#
#		SCAN 		- insert scan to the design															#
#		OCV 		- run with ocv 																	#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	27/11/2024	Royl	initial script																#
#																						#
#																						#
#################################################################################################################################################################################

set STAGE open

source ./scripts/procs/source_be_scripts.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}

set_host_options -max_cores $CPU

script_runtime_proc -start


#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	set setup_file scripts/setup/setup.${PROJECT}.tcl
}
source -v $setup_file
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[info exists STAGE_TO_OPEN] && $STAGE_TO_OPEN != "" && $STAGE_TO_OPEN != "true"} {
  	if { [regexp {\.v} $STAGE_TO_OPEN] } {
	} elseif {[regexp {_lib,(\S+)} $STAGE_TO_OPEN match SSS] || [regexp {_lib$} $STAGE_TO_OPEN  ]} {
		if {[info exists SSS]} {
			regsub ",$SSS" $STAGE_TO_OPEN "" LLL
		}
		set LIB_WA ""
		regsub {out/\S+_lib} $LLL "" LIB_WA
		puts "-I- open lib for readonly $LLL"
		open_lib -read $LLL
		if {[info exists SSS]} {
			regexp {(\S+)_lib} [get_object_name [index_collection [get_libs] 0]] match BLOCK_NAME
			puts "-I- open_block ${BLOCK_NAME}/$SSS"
			open_block -read ${BLOCK_NAME}/$SSS
			if {[file exists ${LIB_WA}reports/${SSS}/write_app_options.bin]} {
				puts "-I- reading app_option from file ${LIB_WA}reports/${SSS}/write_app_options.bin"
				read_app_options ${LIB_WA}reports/${SSS}/write_app_options.bin
			}
			set STAGE $SSS
			
		} else {
			list_block 
		}
  	# // opening verilog netlist
  	} else {
		open_lib out/${DESIGN_NAME}_lib
		open_block ${DESIGN_NAME}/$STAGE_TO_OPEN
		if {[file exists reports/${STAGE_TO_OPEN}/write_app_options.bin]} {
			puts "-I- reading app_option from file reports/${STAGE_TO_OPEN}/write_app_options.bin"
			read_app_options reports/${STAGE_TO_OPEN}/write_app_options.bin
		}
		
			set STAGE $STAGE_TO_OPEN
	}
} else {
	open_lib out/${DESIGN_NAME}_lib
	list_blocks

}

if {[sizeof_collection [current_block]] > 0} {
	if {$CREATE_LIB} {
		if {$STAGE == "route"} {
			file copy -force ./scripts/do_starrc.cmd ./scripts_local/
			sh perl -p -i -e 's/NUM_CORES/* NUM_CORES/' scripts_local/do_starrc.cmd
			sh perl -p -i -e 's/STARRC_DP_STRING/* STARRC_DP_STRING/' scripts_local/do_starrc.cmd
			sh perl -p -i -e 's/CORNERS_FILE/* CORNERS_FILE/' scripts_local/do_starrc.cmd
			sh perl -p -i -e 's/SELECTED_CORNERS/* SELECTED_CORNERS/' scripts_local/do_starrc.cmd
			sh perl -p -i -e 's/GPD/* GPD/' scripts_local/do_starrc.cmd
			set cmd "sh perl -p -i -e 's#TECHNOLOGY_LAYER_MAP#$TECHNOLOGY_LAYER_MAP#' scripts_local/do_starrc.cmd"
			eval $cmd
			set cmd "sh perl -p -i -e 's#STREAM_LAYER_MAP_FILE#$STREAM_LAYER_MAP_FILE#' scripts_local/do_starrc.cmd"
			eval $cmd
			foreach sss $STREAM_FILE_LIST {
				echo "OASIS_FILE: $sss" >> scripts_local/do_starrc.cmd
			}
	
        		echo "SIGNOFF_IMAGE:  [sh which StarXtract]" > ./scripts_local/starrc_indesign.cfg
       			echo "COMMAND_FILE:      [pwd]/scripts_local/do_starrc.cmd" >> ./scripts_local/starrc_indesign.cfg
        		echo "CORNER_GRD_FILE: [pwd]/scripts_local/starrc_indesign.smc" >> ./scripts_local/starrc_indesign.cfg

        		file delete scripts_local/starrc_indesign.smc
        		foreach_in_collection ccc [all_corners] {
                		regexp {.*_FF_(.*)_(\d*)_\d$} [get_object_name $ccc] match rc temp
                		echo "[get_object_name $ccc] $rc_corner($rc,nxtgrd)" >> ./scripts_local/starrc_indesign.smc
        		}
        		set_app_options -name extract.starrc_mode -value true
        		set_starrc_options -config ./scripts_local/starrc_indesign.cfg
        		set_extract_model_options \
                		-extract_model_with_clock_latency_arcs true \
                		-extract_model_clock_latency_arcs_include_all_registers true
		
		} elseif {$STAGE == "cts"} {
        		set_extract_model_options \
                		-extract_model_with_clock_latency_arcs true \
                		-extract_model_clock_latency_arcs_include_all_registers true
		
		} else {
        		set_extract_model_options \
                		-extract_model_with_clock_latency_arcs false \
                		-extract_model_clock_latency_arcs_include_all_registers false
		}
		
		set_host_options -target PrimeTime -max_cores [expr round(double($CPU) / [sizeof_collection [all_scenarios ]])]
        	echo "set STAGE $STAGE" > ./scripts_local/fc_pre_link_pt.tcl
        	echo "set DESIGN_NAME $DESIGN_NAME" >> ./scripts_local/fc_pre_link_pt.tcl
        	echo "set PROJECT $PROJECT" >> ./scripts_local/fc_pre_link_pt.tcl
        	echo "set RUNNING_DIR [pwd]" >> ./scripts_local/fc_pre_link_pt.tcl
        	echo "set OCV ${OCV}" >> ./scripts_local/fc_pre_link_pt.tcl
        	echo "source [pwd]/scripts/setup/setup.${PROJECT}.tcl" >> ./scripts_local/fc_pre_link_pt.tcl

        	set_pt_options \
                	-pt_exec [sh which pt_shell] \
			-work_dir ETM_work_dir/${STAGE} \
                	-post_link_script ./scripts/flow/fc_post_link_pt.tcl \
                	-pre_link_script ./scripts_local/fc_pre_link_pt.tcl

		sh rm -rf ETM_work_dir/${STAGE}
        	report_extract_model_options
        	eee {extract_model -etm_lib_work_dir out/ETM_lib}
		file mkdir out/db/${STAGE}
		foreach_in_collection sss [all_scenarios] {
			set sss_name [get_object_name $sss]
			file copy -force ETM_work_dir/${STAGE}/DMSA/${sss_name}/${DESIGN_NAME}.lib out/db/${STAGE}/${DESIGN_NAME}_${sss_name}.lib
			file copy -force ETM_work_dir/${STAGE}/DMSA/${sss_name}/${DESIGN_NAME}_lib.db out/db/${STAGE}/${DESIGN_NAME}_${sss_name}_lib.db
		}

	}
	if {[info exists LIB_PREP] && $LIB_PREP == "true"} {
		bedb_lib_prep $STAGE
	}

}
#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
script_runtime_proc -end
echo ""

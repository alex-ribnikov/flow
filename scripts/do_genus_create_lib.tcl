
set STAGE syn
if {![file exists reports/lib_gen]} {mkdir -pv reports/lib_gen}

source ./scripts/procs/common/procs.tcl

#script_runtime_proc -start

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
# Variables to set before loading libraries
#------------------------------------------------------------------------------
#set_db library_setup_ispatial true ;                                    # (default : false
set_db max_cpus_per_server $CPU


set WLM true

if {[info exists WLM] && $WLM == "false"} {

	set mmmc_results mmmc_results.tcl

	source scripts/flow/mmmc_create.tcl
	mmmc_create
	set cmd "read_mmmc { $mmmc_results }"
	eval $cmd
	
	set cmd "read_physical -lef \[list $LEF_FILE_LIST\]"
	eval $cmd

} else {
   set mode  [lindex [split [lindex $scenarios(setup) 0] "_"] 0]
   set check [lindex [split [lindex $scenarios(setup) 0] "_"] end]
   regsub "${mode}_(.*)_${check}" [lindex $scenarios(setup) 0] {\1} sub_pvt
   regexp {(.*[SF])_(.*)} $sub_pvt match PVT rc
   set_db library $pvt_corner($PVT,timing)
   
   if {[info exists pvt_corner($PVT,op_code_lib)] && $pvt_corner($PVT,op_code_lib) != ""} {
      set library_sc $pvt_corner($PVT,op_code_lib)
   } else {
	
      regsub ".lib.gz" [lindex [split [lindex $pvt_corner($PVT,timing) 0] /] end] "" library
      regsub {tsmc5ff_\S\S06t0750v_} $library "tsmc5ff_sc06t0750v_" library_sc
      echo "library_sc $library_sc"
   }
}



if {[info exists NETLIST] && $NETLIST != "None"} {
    	puts "-I- read_netlist -top ${DESIGN_NAME} $NETLIST"
    	read_netlist -top ${DESIGN_NAME} $NETLIST
} else {
    if {[file exists out/${DESIGN_NAME}.Syn.v.gz]} {
    	puts "-I- read_netlist -top ${DESIGN_NAME} out/${DESIGN_NAME}.Syn.v.gz"
    	read_netlist -top ${DESIGN_NAME} out/${DESIGN_NAME}.Syn.v.gz
    } elseif  {[file exists out/${DESIGN_NAME}.Syn.v]} {
    	puts "-I- read_netlist -top ${DESIGN_NAME} out/${DESIGN_NAME}.Syn.v"
    	read_netlist -top ${DESIGN_NAME} out/${DESIGN_NAME}.Syn.v
    } else {
    	puts "ERROR missing netlist out/${DESIGN_NAME}.Syn.v.gz or out/${DESIGN_NAME}.Syn.v"
    	exit
    }
}

if {[info exists WLM] && $WLM == "false"} {

    init_design
} else {

    if {[info exists SDC_LIST] && $SDC_LIST != "None"} {
        puts "-I- read_sdc $SDC_LIST"
	read_sdc $SDC_LIST
    } else {
        puts "-I- read_sdc out/${DESIGN_NAME}.sdc"
        read_sdc out/${DESIGN_NAME}.sdc
    }

    set_operating_conditions \
	-max_library ${library_sc}.db:${library_sc} \
	-max $pvt_corner($PVT,op_code) \
	-min $pvt_corner($PVT,op_code)
	
	echo "set_operating_conditions -max_library ${library_sc}.db:${library_sc} -max $pvt_corner($PVT,op_code) -min $pvt_corner($PVT,op_code)"

    set_db interconnect_mode wireload
    set_db wireload_mode top
    set_db [get_db designs]  .force_wireload [get_db wireloads *tsmc5ff_ck06t0750v_pssg*/W3600]

}




report_timing -max_paths 10000 -from [all_inputs] > reports/lib_gen/${PVT}_in2reg.rpt
report_timing -max_paths 10000 -to [all_outputs] > reports/lib_gen/${PVT}_reg2out.rpt

write_lib_lef  -debug -lib out/${DESIGN_NAME}_${PVT}
#script_runtime_proc -end

exit

##########################################################################
# Synopsys(R) IC Compiler II Library Manager(TM) Library Preparation  
# Version: R-2020.09 (Sep 2020)
##########################################################################
set STAGE generate
set BLOCK_NAME [lindex [split [pwd] '/'] end]



source ../scripts/procs/common/procs.tcl 
source -e -v ../scripts/flow/lm_variable.tcl


create_workspace -scale_factor $scale_factor -flow $sel_ndm_flow -technology $TECH_FILE $BLOCK_NAME

if {[regexp tsmc5ff_ $BLOCK_NAME]} {
	read_lef -preserve_lef_cell_site -create_eeq_setting_for_block_and_pad -configure_frame_options $LEF_FILE
} else {
	read_lef  $LEF_FILE
}

read_db $logic_db

report_workspace


if {$diode_cells != "" && $diode_pin != "" && [sizeof_collection [get_lib_cells */${diode_cells}/design -quiet]] > 0} {
	foreach _current_cell [get_lib_cells */${diode_cells}/design -quiet] {
	  set_attribute [get_lib_pins -quiet -of_objects [get_lib_cells */${_current_cell}/design] -filter "name == $diode_pin"] is_diode true
	  echo "set_attribute \[get_lib_pins -quiet -of_objects \[get_lib_cells \*\/${_current_cell}\/design] -filter \"name == $diode_pin\"] is_diode true" >> ${create_ndm_commands}
	}
}

report_app_options > ./reports/report_app_options.rep
check_workspace -allow_missing
commit_workspace -force -output ndm/$BLOCK_NAME.ndm

    remove_workspace

exit
    
set all_ndms [glob ${cell_lib_dir}/*.ndm]
  foreach ndm $all_ndms {
      if {![string match "*${clib_name}_tech_only*" $ndm]} {
      create_workspace -scale_factor $scale_factor -flow edit $ndm
      echo "\ncreate_workspace -scale_factor $scale_factor -flow edit $ndm" >> ${create_ndm_commands}
      read_clf_antenna_properties $ant_clf_for_existing_lib
      echo "read_clf_antenna_properties $ant_clf_for_existing_lib" >> ${create_ndm_commands}
      echo "check_workspace -allow_missing" >> ${create_ndm_commands}
      echo "commit_workspace -force -output $ndm" >> ${create_ndm_commands}
      echo "remove_workspace" >> ${create_ndm_commands}
      check_workspace -allow_missing
      commit_workspace -force -output $ndm
      remove_workspace
    }
  }

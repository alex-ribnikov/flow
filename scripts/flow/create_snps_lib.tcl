#################################################################################
# Search Path Setup
#
# Set up the search path to find the libraries and design files.
#################################################################################

#  set_app_var search_path ". ${ADDITIONAL_SEARCH_PATH} $search_path"


########################################################################
## Library creation
########################################################################


## Library configuration flow: calls library manager under the hood to generate .nlibs, store, and link them
#  - To enable it, in design_setup.tcl, set LIBRARY_CONFIGURATION_FLOW to true,
#    specify LINK_LIBRARY with .db files, and specify REFERENCE_LIBRARY with physical source files. 
#    In fc_setup.tcl, make sure search_path includes all relevant locations. 
foreach rc_ [array name rc_corner] {
	if {[regexp $rc_ [regsub "_setup" [regsub "merge_" [regsub "func_" [lindex $scenarios(setup) 0] ""] ""] ""]] } { 
		regsub  _${rc_} [regsub "_setup" [regsub "merge_" [regsub "func_" [lindex $scenarios(setup) 0] ""] ""] ""] "" pvt
		set rc $rc_
	}
}


set new_list {}
foreach file $pvt_corner($pvt,timing) {
	#regsub {prod(\S+BSI)} $file {int\1} file            
    
    	if       { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue
    	} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue    
    	} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue
    	} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue
    	} else {
		regsub {/prod/} $file {/int/} file            
    		if       { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue
    		} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue    
    		} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue
    		} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue
    		} else {
        		puts "-E- File $file have no .db version in folder"
		}
    	}
}

regsub "\.db" [lindex [split [lindex $new_list 0] /] end] "" library


if {[llength [info command shell_is_dcnxt_shell]] && [shell_is_dcnxt_shell] && [shell_is_in_topographical_mode]}  {
	puts "-I- creat_snps_lib shell_is_dcnxt_shell"
	set new_list {}
	foreach pvt_index [lsearch -all [array name pvt_corner] *timing] {
   		foreach file $pvt_corner([lindex [array name pvt_corner] $pvt_index]) {
		#regsub {prod(\S+BSI)} $file {int\1} file            
    
    			if { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        			lappend new_list $new_file
        			continue
    			} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        			lappend new_list $new_file
        			continue    
    			} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        			lappend new_list $new_file
        			continue
    			} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        			lappend new_list $new_file
        			continue
    			} else {
				regsub {/prod/} $file {/int/} file            
    				if       { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        				lappend new_list $new_file
        				continue
    				} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        				lappend new_list $new_file
        				continue    
    				} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        				lappend new_list $new_file
        				continue
    				} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        				lappend new_list $new_file
        				continue
    				} else {
        				puts "-E- File $file have no .db version in folder"
				}
    			}
   		}
        
	}

	set TARGET_LIBRARY_FILES [regsub "{}" $new_list ""]
	#set TARGET_LIBRARY_FILES $new_list
	set ADDITIONAL_LINK_LIB_FILES ""



	set_app_var target_library ${TARGET_LIBRARY_FILES}
	set_app_var link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES $synthetic_library"


#  	set mw_site_name_mapping { {CORE_6 unit}  {CORE_8 unit}}
#	set_icc2_options -convert_sites {{CORE_6 unit} {CORE_8 unit}}
	
  	set ndm_reference_library ${NDM_REFERENCE_LIBRARY}
  	set ndm_design_library ${DESIGN_NAME}.ndm

	create_lib ${DESIGN_NAME}_lib -tech $TECH_FILE -ref_libs $NDM_REFERENCE_LIBRARY
    	
	check_library > reports/check_library.rpt

} elseif {[llength [info command  shell_is_in_topographical_mode] ]&& [shell_is_in_topographical_mode]} {
    puts "-I- creat_snps_lib shell_is_in_topographical_mode"
	set TARGET_LIBRARY_FILES $new_list
	set ADDITIONAL_LINK_LIB_FILES ""



	set_app_var target_library ${TARGET_LIBRARY_FILES}
	set_app_var link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES $synthetic_library"

     	set_tlu_plus_files -max_tluplus $rc_corner($rc,nxtgrd) \
                       -min_tluplus  $rc_corner($rc,nxtgrd) \
                       -tech2itf_map $TECHNOLOGY_LAYER_MAP

    	check_library > reports/check_library.rpt
    	check_tlu_plus_files

} elseif { $synopsys_program_name == "fc_shell" || (${synopsys_program_name} == "rtl_shell")} {
	puts "-I- fc_shell"
	if {[file exists out/${DESIGN_NAME}_lib]} {
		puts "-W-:  block lib exists. deleteing it."
		sh rm -rf out/${DESIGN_NAME}_lib.old

#		file delete -force out/${DESIGN_NAME}_lib.old
		file rename -force out/${DESIGN_NAME}_lib out/${DESIGN_NAME}_lib.old
#		file delete -force out/${DESIGN_NAME}_lib
		
	}
	
#	set_pvt_configuration -temperatures {0 125} -voltages {0.67 0.83} 
	
	create_lib out/${DESIGN_NAME}_lib -tech $TECH_FILE -ref_libs $NDM_REFERENCE_LIBRARY
	
#	if {[info exists PRF_FILE_LIST] && $PRF_FILE_LIST != ""} {
#		puts "-I- reading PRF files"
#		foreach PRF_FILE $PRF_FILE_LIST {
#			echo "$PRF_FILE"
#			read_physical_rules [glob $PRF_FILE]
#		}
#	}

} else {
	puts "-I- creat_snps_lib WIRELOAD"
	set TARGET_LIBRARY_FILES $new_list
	set ADDITIONAL_LINK_LIB_FILES ""



	set_app_var target_library ${TARGET_LIBRARY_FILES}
	set_app_var link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES $synthetic_library"


#    	set_wire_load_model -name W180000 -library $library

}

#if {[shell_is_in_topographical_mode]} {
#}

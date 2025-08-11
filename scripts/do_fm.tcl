#################################################################################################################################################################################
#																						#
#	this script will run formality verification  																		#
#	variable received from shell are:																	#
#		CPU		- number of CPU to run.8 per license														#
#		DESIGN_NAME	- name of top model																#
#		SCAN 		- insert scan to the design															#
#																						#
#																						#
#	 Var	date of change	owner		 comment															#
#	----	--------------	-------	 ---------------------------------------------------------------									#
#	0.1	26/06/2022	Royl	initial script																#
#																						#
#																						#
#################################################################################################################################################################################
set STAGE FM

if {[file exists user_inputs.tcl]} {source -e -v user_inputs.tcl}
if {[info exists FM_MODE] && $FM_MODE == "None"} {puts "Error: Undefined fm_mode $FM_MODE"}
if {[info exists DPX] && $DPX && ([regexp "nextk8s" $env(HOST)] || [regexp "argo" $env(HOST)])} {
	set DESCRIPTION "[string tolower [lindex [split [pwd] "/"] end]]_slave"
	if {! [string is digit $DPX]} {
		set DPX 1
	}
	set DPX_CPU [expr round ($CPU / ($DPX * 1.0))]
	set_dpx_options \
		-work_dir WORK \
		-protocol CUSTOM \
		-max_memory $MEMORY \
		-max_cores $DPX_CPU \
		-max_workers $DPX \
		-submit_command "[pwd]/scripts/bin/k8s_fmdpx.sh -CPU $DPX_CPU -MEMORY $MEMORY -LABEL $LABEL"

#	check_dpx_options
	start_dpx_workers
	report_dpx_workers

} else {
	set_host_options -max_cores  $CPU
}


source ../scripts/procs/common/procs.tcl

script_runtime_proc -start

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file ./scripts_local/setup.tcl
} elseif {[file exists ../scripts_local/setup.tcl]} {
	puts "-I- reading setup file from ../scripts_local"
	set setup_file ../scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	set setup_file ../scripts/setup/setup.${PROJECT}.tcl
}
source -v -e $setup_file

if {[file exists ../../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../../inter "
	source -v -e ../../inter/supplement_setup.tcl
}

if {[file exists ./scripts_local/supplement_setup_be.tcl]} {
	puts "-I- reading supplement_setup_be file from scripts_local"
	source -v -e ./scripts_local/supplement_setup_be.tcl
} elseif {[file exists ../scripts_local/supplement_setup_be.tcl]} {
	puts "-I- reading supplement_setup_be file from ../scripts_local"
	source -v -e ../scripts_local/supplement_setup_be.tcl
} elseif {[file exists ./scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v -e ./scripts_local/supplement_setup.tcl
} elseif {[file exists ../scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../scripts_local"
	source -v -e ../scripts_local/supplement_setup.tcl
}
# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing" -verbose 0

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/fm_variables.tcl]} {
	puts "-I- reading fm_variables file from scripts_local"
	source -v -e scripts_local/fm_variables.tcl
} elseif {[file exists ../scripts_local/fm_variables.tcl]} {
	puts "-I- reading fm_variables file from ../scripts_local"
	source -v -e ../scripts_local/fm_variables.tcl
} else {
	puts "-I- reading fm_variables file from scripts"
	source -v -e ../scripts/flow/fm_variables.tcl
}

#################################################################################
# Read in the SVF file(s)
#################################################################################
if {$FM_MODE == "rtl2syn"} {
    set STAGE compile
    set svf_list "${FUSION_DIR}/out/svf/${DESIGN_NAME}_init.svf ${FUSION_DIR}/out/svf/${DESIGN_NAME}_${STAGE}.svf"
} elseif {$FM_MODE == "syn2place" || $FM_MODE == "dft2place"} {
    set STAGE place
    set svf_list "${FUSION_DIR}/out/svf/${DESIGN_NAME}_${STAGE}.svf"
} elseif {$FM_MODE == "place2route"} {
    set STAGE route
    set svf_list "${FUSION_DIR}/out/svf/${DESIGN_NAME}_${STAGE}.svf"
}


## Change svf to be a list and read all svf up to the stage I'm running using -append
if {[info exists SVF_FILE] && $SVF_FILE != "None"} {
    set appnd ""
    foreach svf $SVF_FILE {
	if {[file exist $svf]} {
	    eval "set_svf $appnd $svf"
	    set appnd "-append"
	} else {
	    puts "Error: SVF file does not exists:  $svf"
	}
    }
} elseif {[info exists SVF_FILE] && $SVF_FILE == "None"} {
    if {[file exists ${SYN_DIR}/out/${DESIGN_NAME}.svf]} {
	set_svf ${SYN_DIR}/out/${DESIGN_NAME}.svf
    } elseif  {[info exists STAGE]} {
	set appnd ""
	foreach svf $svf_list {
	    if {[file exist $svf]} {
		eval "set_svf $appnd $svf"
		set appnd "-append"
	    } else {
		puts "Error: SVF file does not exists:  $svf"
	    }
	}
    }
} elseif {$FM_MODE == "rtl2syn"} {
    puts "Error: missing SVF file for RTL 2 Syn verification"
}


if {0} {
if {[info exists SVF_FILE] && [llength $SVF_FILE] > 1 } {
    set appnd ""
    foreach svf $SVF_FILE {
	eval "set_svf $appnd $svf"
	set appnd "-append"
    }
} elseif {[info exists SVF_FILE] && $SVF_FILE == "None"} {
	if {[file exists ${SYN_DIR}/out/${DESIGN_NAME}.svf]} {
			set_svf ${SYN_DIR}/out/${DESIGN_NAME}.svf
    } elseif {[file exists ${FUSION_DIR}/out/svf/${DESIGN_NAME}_${STAGE}.svf]} {
	set_svf ${FUSION_DIR}/out/svf/${DESIGN_NAME}_${STAGE}.svf
	} elseif {$FM_MODE == "rtl2syn"} {
	puts "Error: missing SVF file for RTL 2 Syn verification"
	}
} elseif {[info exists SVF_FILE] && $SVF_FILE != "None"} {
	set flag 1
	foreach sff $SVF_FILE {
		if {$flag && [file exist $sff]} {
			puts "-I- reading svf file: $sff"
			set_svf $sff
			set flag 0
		} elseif {[file exist $sff]} {
			puts "-I- appending svf file: $sff"
			set_svf -append $SVF_FILE
		} else {
			puts "Error: SVF file does not exists:  $sff"
		}
	}
}
}
#################################################################################
# Read in the libraries
#################################################################################
foreach rc_ [array name rc_corner] {
	if {[regexp $rc_ [regsub "_setup" [regsub "func_" [lindex $scenarios(setup) 0] ""] ""]]} { 
		regsub  _${rc_} [regsub "_setup" [regsub "func_" [lindex $scenarios(setup) 0] ""] ""] "" pvt
		set rc $rc_
	}
}

set new_list {}

# 31/12/2023 Royl: lib list should come only from one pvt corner.
#                  searching for missing lib in all corner might resulat in unknown filelist.
#foreach pvt_timing [lsearch -all -inline [array names pvt_corner] "*,timing"] {
#    foreach file $pvt_corner($pvt_timing) {
foreach file $pvt_corner($pvt,timing) {

	#regsub {prod(\S+BSI)} $file {int\1} file            
    
#        regsub {_p..g_.*} $file {} file_base
#        if { [lsearch $new_list "${file_base}_p??g_*"] >= 0 } {
#            continue
#        }
    
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
set TARGET_LIBRARY_FILES $new_list
set ADDITIONAL_LINK_LIB_FILES ""

foreach tech_lib "${TARGET_LIBRARY_FILES} ${ADDITIONAL_LINK_LIB_FILES}" {
  read_db -technology_library $tech_lib
}

#################################################################################
# set files to compare 
#################################################################################
if {$FM_MODE == "rtl2syn"} {
    set ffff "None"
    if {![file exists ${SYN_DIR}] && [file exists ${FUSION_DIR}]} {
	set SYN_DIR FUSION_DIR
    }
    if {[file exists ${SYN_DIR}/user_inputs.tcl]} {
	set fff [exec grep FILELIST ${SYN_DIR}/user_inputs.tcl]
	set ffff [regsub -all {\"} [lindex [split $fff " "] end] ""] ; #" 
    }
    
    if {$ffff == "None"} {
	puts "-I- use default filelist"
	if { [file exists $SYN_DIR/filelist] } {
	    set golden_verilog_files  $SYN_DIR/filelist
	} elseif { [file exists $FUSION_DIR/../inter/filelist] } {
	    set golden_verilog_files $FUSION_DIR/../inter/filelist
	} elseif { [file exists $FUSION_DIR//filelist] } {
	    set golden_verilog_files $FUSION_DIR/filelist
	}
    } else {
	if {[file exists $ffff]} {
	    puts "-I- read filelist from DC user_inputs"
	    set golden_verilog_files  "$ffff"
	} elseif {[file exists ${SYN_DIR}/$ffff ]} {
	    puts "-I- read filelist from DC user_inputs"
	    set golden_verilog_files  "${SYN_DIR}/$ffff"
	} elseif {[file exists ${FUSION_DIR}/$ffff ]} {
	    puts "-I- read filelist from DC user_inputs"
	    set golden_verilog_files  "${FUSION_DIR}/$ffff"
		}
    }
    if {[file exists $SYN_DIR/out/$DESIGN_NAME.Syn.v.gz]} {
	set revised_verilog_files $SYN_DIR/out/$DESIGN_NAME.Syn.v.gz	 
    } elseif {[file exists $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v.gz]} {
	set revised_verilog_files $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v.gz	 
    } elseif {[file exists $SYN_DIR/out/$DESIGN_NAME.Syn.v]} {
	set revised_verilog_files $SYN_DIR/out/$DESIGN_NAME.Syn.v	 
    }  elseif {[file exists $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v]} {
	set revised_verilog_files $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v	 
    } 
    
} elseif {$FM_MODE == "syn2place"} {
    if {[file exists $SYN_DIR/out/$DESIGN_NAME.Syn.v.gz]} {
	set golden_verilog_files $SYN_DIR/out/$DESIGN_NAME.Syn.v.gz	 
    } elseif {[file exists $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v.gz]} {
	set golden_verilog_files $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v.gz	 
    } elseif {[file exists $SYN_DIR/out/$DESIGN_NAME.Syn.v]} {
	set golden_verilog_files $SYN_DIR/out/$DESIGN_NAME.Syn.v	 
    } elseif {[file exists $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v]} {
	set golden_verilog_files $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v	 
    } 
    
    if {[file exists $FUSION_DIR/out/netlist/${DESIGN_NAME}_place.v.gz]} {
	set revised_verilog_files $FUSION_DIR/out/netlist/${DESIGN_NAME}_place.v.gz	 
    }    
} elseif {$FM_MODE == "syn2dft"} { 
    if {[file exists $SYN_DIR/out/$DESIGN_NAME.Syn.v.gz]} {
	set golden_verilog_files $SYN_DIR/out/$DESIGN_NAME.Syn.v.gz
    } elseif {[file exists $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v.gz]} {
	set golden_verilog_files $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v.gz
    } elseif {[file exists $SYN_DIR/out/$DESIGN_NAME.Syn.v]} {
	set golden_verilog_files $SYN_DIR/out/$DESIGN_NAME.Syn.v
    } elseif {[file exists $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v]} {
	set golden_verilog_files $FUSION_DIR/out/netlist/$DESIGN_NAME.compile.v
    }
    if {[file exists $SYN_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz]} {
	set revised_verilog_files $SYN_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz
    }  elseif {[file exists $FUSION_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz]} {
	set revised_verilog_files $FUSION_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz
    }
} elseif {$FM_MODE == "dft2place"} {
    if {[file exists $SYN_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz]} {
	set golden_verilog_files  $SYN_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz
    }  elseif {[file exists $FUSION_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz]} {
	set golden_verilog_files $FUSION_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz
    }
    
    
    if {[file exists $FUSION_DIR/out/netlist/${DESIGN_NAME}_place.v.gz]} {
	set revised_verilog_files $FUSION_DIR/out/netlist/${DESIGN_NAME}_place.v.gz
    }
} elseif {$FM_MODE == "place2route"} {
     if {[file exists $FUSION_DIR/out/netlist/${DESIGN_NAME}_place.v.gz]} {
	set golden_verilog_files $FUSION_DIR/out/netlist/${DESIGN_NAME}_place.v.gz	 
    }    
    if {[file exists $FUSION_DIR/out/netlist/${DESIGN_NAME}.route.v.gz]} {
	set revised_verilog_files $FUSION_DIR/out/netlist/${DESIGN_NAME}.route.v.gz	 
    }    
}

if {[info exists GOLDEN_NETLIST]  && $GOLDEN_NETLIST != "None"}  { set golden_verilog_files $GOLDEN_NETLIST  }
if {[info exists REVISED_NETLIST] && $REVISED_NETLIST != "None"} { set revised_verilog_files $REVISED_NETLIST}

puts "GOLDEN_NETLIST: $GOLDEN_NETLIST $golden_verilog_files\nREVISED_NETLIST: $REVISED_NETLIST $revised_verilog_files"
if {![info exists golden_verilog_files] && ![info exists revised_verilog_files]} { puts "ERROR: missing golden_verilog_files and revised_verilog_files. need to define GOLDEN_NETLIST and REVISED_NETLIST flag."; exit 1}
if {![info exists golden_verilog_files]} { puts "ERROR: missing golden_verilog_files. need to define GOLDEN_NETLIST flag."; exit 1}
if {![info exists revised_verilog_files]} { puts "ERROR: missing revised_verilog_files. need to define REVISED_NETLIST flag."; exit 1}

set golden_verilog_files_tmp ""      
foreach f $golden_verilog_files {
    if { [file exists $f] } { lappend golden_verilog_files_tmp $f } \
    else { puts "ERROR: golden file    $f    does not exist" }     
}
if { [llength $golden_verilog_files_tmp] } {
    set golden_verilog_files $golden_verilog_files_tmp
} else {
    puts "ERROR: no golden files exists from:  $golden_verilog_files" ; exit 1
}

set revised_verilog_files_tmp ""      
foreach f $revised_verilog_files {
    if { [file exists $f] } { lappend revised_verilog_files_tmp $f } \
    else { puts "ERROR: revised file    $f    does not exist" }     
}
if { [llength $revised_verilog_files_tmp] } {
    set revised_verilog_files $revised_verilog_files_tmp
} else {
    puts "ERROR: no revised files exists from:  $revised_verilog_files" ; exit 1
}


#################################################################################
# Read in the Reference Design as verilog/vhdl source code
#################################################################################

## Meravi - Need to chenge it to use RTL* varables
if {$FM_MODE == "rtl2elab" || $FM_MODE == "elab2syn" || $FM_MODE == "rtl2syn" || $FM_MODE == "rtl2syn_flat" || $FM_MODE == "rtl2rtl" || $FM_MODE == "rtl2rtl_flat" || $FM_MODE == "syn2dft" || $FM_MODE == "syn2place"} {
    if {[info exists RTL_2_SYN_LIB_LIST] } {
	set golden_libs_var     $RTL_2_SYN_LIB_LIST
        set revised_libs_var     $RTL_2_SYN_LIB_LIST
}
    if {[info exists RTL_2_SYN_NETLIST_LIST]} {
	set golden_verilogs_var $RTL_2_SYN_NETLIST_LIST
        set revised_verilogs_var $RTL_2_SYN_NETLIST_LIST
    }
    
    if { $FM_MODE == "syn2dft" } {
	if {[info exists POST_DFT_LIB_LIST]} {
	    set revised_libs_var     $POST_DFT_LIB_LIST
	}
	if {[info exists POST_DFT_NETLIST_LIST]} {
	    set revised_verilogs_var $POST_DFT_NETLIST_LIST
	}
    }
} elseif {$FM_MODE == "dft2place" || $FM_MODE == "scantest"} {
    if {[info exists POST_DFT_LIB_LIST]} {
	set golden_libs_var      $POST_DFT_LIB_LIST
    }
    if {[info exists POST_DFT_NETLIST_LIST]} {
	set golden_verilogs_var  $POST_DFT_NETLIST_LIST
    }
    if {[info exists POST_LAYOUT_LIB_LIST]} {
	set revised_libs_var     $POST_LAYOUT_LIB_LIST
    }
    if {[info exists POST_LAYOUT_NETLIST_LIST]} {
	set revised_verilogs_var $POST_LAYOUT_NETLIST_LIST
    }
}

if {[info exists golden_libs_var]} {
    foreach file $golden_libs_var {
	if {[regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file]} {
	    read_db -r $new_file
	} elseif {[regsub "\.lib\$"     $file "\.db" new_file] && [file exists $new_file]} {
	    read_db -r $new_file
	} else {
	    puts "Error: lib file $file does not have .db for reference"
	}
    }
}

if {$FM_MODE == "rtl2syn"} {

	set fid [open $golden_verilog_files r]
	set read_filelist [split [read $fid] \n]
	close $fid

	regexp {(\S+srcfile\.flist)} $read_filelist srcfile
	regexp {(\S+rtl_files\.flist)} $read_filelist rtl_files

        if {[info exists srcfile]} {
	    set fou  [open tmp_srcfile.flist w]
	    set flou [open tmp_filelist w]
	    set srcid [open $srcfile r]
	    set src_filelist [read $srcid]
	    close $srcid
	    foreach line $src_filelist {
		if {![regexp {vstub} $line]} {
		    puts $fou $line
		}
	    }
	    if {[info exists golden_verilogs_var]} {
		foreach fff $golden_verilogs_var {
		    puts $fou $fff 
		}
	    }
	    foreach line $read_filelist {
		if {[regexp {srcfile.flist} $line]} {
		    #sh grep -v srcfile.flist tmp_filelist > tmp_filelist_1
		    puts $flou "-f [pwd]/tmp_srcfile.flist"
		} elseif {[regexp {flist} $line]} {
		    puts $flou $line
		}
	    }
	    close $flou
	    close $fou
	}
	if {[info exists rtl_files]} {
	    set fou  [open tmp_rtl_files.flist w]
	    set flou [open tmp_filelist w]
	    set rtlid [open $rtl_files r]
	    set rtl_filelist [read $rtlid]
	    close $rtlid

	    foreach line $rtl_filelist {
		if {![regexp {vstub} $line]} {
		    puts $fou $line
		} 
	    }
	    
	    foreach line $read_filelist {
		
		if {[regexp {rtl_files.flist} $line]} {
		    puts $flou  "-f [pwd]/tmp_rtl_files.flist"
		} elseif {[regexp {flist} $line]} {
		    puts $flou $line 
		}
		if {[info exists golden_verilogs_var]} {
		    foreach fff $golden_verilogs_var {
			puts $fou $fff 
		    }
		}
	    }
	    close $flou
	    close $fou
	}
	
	
	
	##?? 	if {[info exists golden_libs_var]} {
	##??     		foreach file $golden_libs_var {
	##?? 			if {[regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file]} {
	##?? 				read_db -r $new_file
	##?? 			} elseif {[regsub "\.lib\$"     $file "\.db" new_file] && [file exists $new_file]} {
	##?? 				read_db -r $new_file
	##?? 			} else {
	##?? 				puts "Error: lib file $file does not have .db for reference"
	##?? 			}
	##?? 		}
	##?? 	}
	
	
	read_sverilog -r -f tmp_filelist -work_library WORK
	set_top r:/WORK/${DESIGN_NAME}
	
    } else {
	if {$FM_MODE == "syn2dft" || $FM_MODE == "dft2place"} {
	    if {[info exists golden_verilogs_var]} {
		lappend golden_verilog_files $golden_verilogs_var
	    }
	    ##?? 		if {[info exists golden_libs_var]} {
	    ##??     			foreach file $golden_libs_var {
	    ##?? 				if {[regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file]} {
	    ##?? 					read_db -r $new_file
	    ##?? 			    } elseif {[regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file]} {
##?? 				    read_db -r $new_file
	    ##?? 				} else {
##?? 					puts "Error: lib file $file does not have .db for reference"
##?? 				}
##?? 			}
##?? 		}
##?? 	}
##?? 	
	
	
    	puts "reading golden netlist $golden_verilog_files"
	read_verilog -r ${golden_verilog_files} -work_library WORK
	set_top r:/WORK/${DESIGN_NAME}
	
}


if {$FM_MODE == "rtl2syn" || $FM_MODE == "syn2place" || $FM_MODE == "syn2dft" || $FM_MODE == "dft2place"} {
	if {[info exists revised_verilogs_var]} {
    		lappend revised_verilog_files $revised_verilogs_var
	}
	if {[info exists revised_libs_var]} {
	    foreach file $revised_libs_var {
			if {[regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file]} {
				read_db -i $new_file
			} elseif {[regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file]} {
				read_db -i $new_file
			} else {
				puts "Error: lib file $file does not have .db for implementation"
			}
		}
	}
}

puts "reading revised netlist : $revised_verilog_files"
read_verilog -i $revised_verilog_files -work_library WORK

if { ![info exists REVISED_DESIGN_NAME] } { 
    set REVISED_DESIGN_NAME $DESIGN_NAME
}


set _f_src "../scripts_local/${DESIGN_NAME}.${FM_MODE}.naming_rules.tcl"
if {[file exists $_f_src]} {
    puts "-I- reading naming_rule commands file: $_f_src"
    source -e -v $_f_src
}

set_top i:/WORK/${REVISED_DESIGN_NAME}


#################################################################################
# Configure constant ports
#
#################################################################################
set _f_src "../scripts_local/common.${FM_MODE}.constraints.tcl"
if {[file exists $_f_src]} {
    puts "-I- reading constraints commands file: $_f_src"
    source -e -v $_f_src
}

set _f_src "../scripts_local/${DESIGN_NAME}.${FM_MODE}.constraints.tcl"
if {[file exists $_f_src]} {
    puts "-I- reading constraints commands file: $_f_src"
    source -e -v $_f_src
}


if {[file exists ../scripts_local/user_match.tcl]} {
	puts "-I- reading user match file: ../scripts_local/user_match.tcl"
	source -e -v ../scripts_local/user_match.tcl
} elseif {[file exists scripts/setup/user_match.${PROJECT}.tcl]} {
	puts "-I- reading user match file: scripts/setup/user_match.${PROJECT}.tcl"
	source -e -v scripts/setup/user_match.${PROJECT}.tcl
}




report_black_box > reports/black_boxes.rpt
report_dont_verify_points > reports/dont_verify.rpt
report_constraint > reports/report_constraint.rpt
report_constants > reports/report_constants.rpt


#################################################################################
# Match compare points and report unmatched points 
#################################################################################

match

report_unmatched_points > reports/report_unmatched_points.rpt
report_unmatched_points -status unread > reports/fm_unmatched.unread.rpt
report_svf_operation -status rejected  > reports/report_svf_rejected.rpt

write_register_mapping -replace -bbpin -prime_power -cg_latch reports/register_mapping.rpt


#################################################################################
# Verify and Report
#
# If the verification is not successful, the session will be saved and reports
# will be generated to help debug the failed or inconclusive verification.
#################################################################################
#set verification_alternate_strategy l2
# s2 s3 s1 o2 l1 l3 s8 s4 o4 o3 q1 q2 s7 s9 o1 s10 l2

set verification_timeout_limit 4:0:0

set VERIFY [verify] 

if { $verification_status == "INCONCLUSIVE"} {
	puts "-I- verification is INCONCLUSIVE . try alternate_strategy o3"
	set verification_timeout_limit 5:0:0
	set verification_alternate_strategy o3
	verify
}

if { $verification_status == "INCONCLUSIVE"} {
	puts "-I- verification is INCONCLUSIVE . try alternate_strategy s8"
	set verification_timeout_limit 5:0:0
	set verification_alternate_strategy s8
	verify
}

if { $verification_status == "INCONCLUSIVE"} {
	puts "-I- verification is INCONCLUSIVE . try alternate_strategy l2"
	set verification_timeout_limit 5:0:0
	set verification_alternate_strategy l2
	verify
}

if { $verification_status == "INCONCLUSIVE"} {
	puts "-I- verification is INCONCLUSIVE . try alternate_strategy s2"
	set verification_timeout_limit 1:0:0
	set verification_alternate_strategy s2
	verify
}



save_session -replace session/${DESIGN_NAME}

report_failing_points > reports/report_failing_points.rpt
report_aborted_points > reports/report_aborted_points.rpt

report_matched_points >  reports/fm_matched.rpt
report_passing_points >  reports/fm_passed.rpt

if {$verification_status ==  "FAILED"} {
  # Use analyze_points to help determine the next step in resolving verification
  # issues. It runs heuristic analysis to determine if there are potential causes
  # other than logical differences for failing or hard verification points. 
  analyze_points -all > reports/analyze_points.rpt
  puts "\n\tFORMAL VERIFICATION FAILED"
} elseif {$verification_status == "INCONCLUSIVE"} {
  report_unverified_points -last > reports/report_unverified_points.rpt
  puts "\n\tFORMAL VERIFICATION INCONCLUSIVE"

} elseif {$verification_status == "SUCCEEDED"} {
  puts "\n\tFORMAL VERIFICATION PASSED"

}

script_runtime_proc -end

if {$INTERACTIVE == "false"} { exit }

if {0 && $verification_status == "INCONCLUSIVE"} {

set_run_alternate_strategies_options \
	-max_cores 4 \
	-num_processes 2 \
	-protocol CUSTOM \
	-submit_command "../scripts/bin/fm_nextk8s.csh -cpu 4 -mem 30 -pwd /services/bespace/users/royl/inext/inext_hw_fe/gendir_formality_d2d_west_ctrl/rtl2syn -description fm_alt_stg -label None" 

set_run_alternate_strategies_options \
	-max_cores 4 \
	-num_processes 2 \
	-protocol CUSTOM \
	-submit_command  "cd /services/bespace/users/royl/inext/inext_hw_fe/gendir_formality_d2d_west_ctrl/rtl2syn  ; /usr/bin/ssh lvi"

run_alternate_strategies -replace -directory alternate_strategy -session session/d2d_west_ctrl.fss

}

tclmode
tcl_set_command_name_echo  on
#################################################################################################################################################################################
#                                                                                        #
#    this script will run conformal verification                                                                          #
#    variable received from shell are:                                                                    #
#        CPU        - number of CPU to run.8 per license                                                        #
#        DESIGN_NAME    - name of top model                                                                #
#        SCAN         - insert scan to the design                                                            #
#                                                                                        #
#                                                                                        #
#     Var    date of change    owner         comment                                                            #
#    ----    --------------    -------     ---------------------------------------------------------------                                    #
#    0.1    28/02/2022    Royl    initial script                                                                #
#                                                                                        #
#                                                                                        #
#################################################################################################################################################################################

set STAGE conformal
set start_t [clock seconds]
#set_log_file lec.log.$env(LEC_VERSION) -replace
puts "-I- Start running  at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"


if { [file exists user_inputs.tcl] } { source  user_inputs.tcl }
puts "LEC_MODE $LEC_MODE" 
puts "GOLDEN_NETLIST $GOLDEN_NETLIST" 
puts "REVISED_NETLIST $REVISED_NETLIST" 
puts "PROJECT $PROJECT" 

if {![file exists ./sourced_scripts/lec/${LEC_MODE}]} {exec mkdir -pv ./sourced_scripts/lec/${LEC_MODE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/lec/${LEC_MODE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/}
source ../scripts/procs/common/procs.tcl

#set_dofile_abort on

#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists ../scripts_local/setup.tcl]} {
    puts "-I- reading setup file from scripts_local"
    set setup_file ../scripts_local/setup.tcl
} elseif {($LEC_MODE == "dft2place" || $LEC_MODE == "place2route" || $LEC_MODE == "route2chip_finish") && [file exists ${INNOVUS_DIR}/scripts_local/setup.tcl]} {
    puts "-I- reading setup file from ${INNOVUS_DIR}/scripts_local"
    set setup_file ${INNOVUS_DIR}/scripts_local/setup.tcl
} elseif {($LEC_MODE == "rtl2syn" || $LEC_MODE == "syn2dft") && [file exists ${SYN_DIR}/scripts_local/setup.tcl]} {
    puts "-I- reading setup file from ${SYN_DIR}/scripts_local"
    set setup_file ${SYN_DIR}/scripts_local/setup.tcl
} else {
    puts "-I- reading setup file from scripts"
    set setup_file ../scripts/setup/setup.$PROJECT.tcl
}

source  $setup_file

if {[file exists ../scripts_local/supplement_setup_be.tcl]} {
    puts "-I- reading supplement_setup_be file from scripts_local"
    source  ../scripts_local/supplement_setup_be.tcl
} elseif {[file exists ../../inter/supplement_setup_be.tcl]} {
    puts "-I- reading supplement_setup_be file from ../inter "
    source ../../inter/supplement_setup_be.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

########################################################################
# Sets up the log file and instructs the tool to display usage and other
# information.
##########################################################################

info hostname
date
usage -auto -elapse

########################################################################
# Sets up rtl2map
# .
##########################################################################
set DATAPATH_SOLVER_OPTION "-flowgraph"

if {$LEC_MODE == "rtl2map"} { 
    # Turns on the flowgraph datapath solver.
    set wlec_analyze_dp_flowgraph true
    # Indicates that resource sharing datapath optimization is present.
    set share_dp_analysis         false
    set DATAPATH_SOLVER_OPTION "-flowgraph"
    
    set_verification_information rtl_fv_map_db
    # Implementation information for elaborated but not mapped netlist.
    set_flatten_model -verification_info_strip_cdn_name_extension
    
    
    read_implementation_information $SYN_DIR/fv/${DESIGN_NAME} -revised fv_map
    set_undriven_signal x -golden
    set_naming_style genus -golden

    set_naming_rule "__" -parameter -golden
    set_naming_rule "_" "_" -array_delimiter -golden
    set_naming_rule "%s\[%d\]" -instance_array -golden
    set_naming_rule "%s_reg" -register -golden
    set_naming_rule "%L_%s" "%L_%d__%s" "%s" -instance -golden
    set_naming_rule "%L_%s" "%L_%d__%s" "%s" -variable -golden
    
        set_naming_rule -ungroup_separator {_} -golden
        set_hdl_options -const_port_extend
    # Root attribute 'hdl_resolve_instance_with_libcell' was set to true in Genus.
    set_hdl_options -use_library_first on
    # Align LEC's treatment of libext in command files with Genus's.
        set_hdl_options -nolibext_def on
        set_hdl_options -VERILOG_INCLUDE_DIR "cwd:incdir:src:yyd:sep"
    
    set syn_version_log [exec grep -m1 /tools/cdnc/genus $SYN_DIR/log/do_syn.log ]
    regexp {.*(/tools/cdnc/genus/\S+)/.*} $syn_version_log all match
    set syn_version [join [lrange [split $match "/"] 0 4 ] "/"]

    set syn_ver_log [exec grep Version $SYN_DIR/log/do_syn.log]
    regsub "," [lindex [split $syn_ver_log " "] 1] "" syn_ver

    set env(RC_VERSION)     "$syn_ver"
    set env(CDN_SYNTH_ROOT) "$syn_version/tools.lnx86"
    set CDN_SYNTH_ROOT      "$syn_version/tools.lnx86"
    set env(CW_DIR) "$syn_version/tools.lnx86/lib/chipware"
    set CW_DIR      "$syn_version/tools.lnx86/lib/chipware"



    add_search_path . $syn_version/tools.lnx86/lib/tech -library -both
} elseif {$LEC_MODE == "rtl2syn"} { 
    set env(RC_VERSION)     "21.15-s080_1"
    set env(CDN_SYNTH_ROOT) "/tools/cdnc/genus/21.15.000/tools.lnx86"
    set CDN_SYNTH_ROOT      "/tools/cdnc/genus/21.15.000/tools.lnx86"
    set env(CW_DIR) "/tools/cdnc/genus/21.15.000/tools.lnx86/lib/chipware"
    set CW_DIR      "/tools/cdnc/genus/21.15.000/tools.lnx86/lib/chipware"

    set_undriven_signal x -golden
    set_naming_style dc -golden
    set DATAPATH_SOLVER_OPTION "-flowgraph"
    
#    add_renaming_rule -pin struct2 {\[%a\]\[%d\]} {.@1\[@2\]]}  -golden
#
#    vpx add renaming rule test1 {\[%a]\[%d]} {_@1_\[@2]} -pin -golden
#    vpx add renaming rule test2 {_%d\[%a\]} {_@1_@2_} -pin -golden

} elseif {$LEC_MODE == "rtl2elab" || $LEC_MODE == "elab2syn" || $LEC_MODE == "rtl2syn" || $LEC_MODE == "rtl2syn_flat" || $LEC_MODE == "rtl2rtl" || $LEC_MODE == "rtl2rtl_flat"} {
    set env(RC_VERSION)     "21.15-s080_1"
    set env(CDN_SYNTH_ROOT) "/tools/cdnc/genus/21.15.000/tools.lnx86"
    set CDN_SYNTH_ROOT      "/tools/cdnc/genus/21.15.000/tools.lnx86"
    set env(CW_DIR) "/tools/cdnc/genus/21.15.000/tools.lnx86/lib/chipware"
    set CW_DIR      "/tools/cdnc/genus/21.15.000/tools.lnx86/lib/chipware"

    set_undriven_signal z -golden
    set wlec_analyze_dp_flowgraph true
    set share_dp_analysis         false
    
    
     if {$wlec_analyze_dp_flowgraph} {
             set DATAPATH_SOLVER_OPTION "-flowgraph"
      } elseif {$share_dp_analysis} {
             set DATAPATH_SOLVER_OPTION "-share"
      } else {
              set DATAPATH_SOLVER_OPTION ""
      }    
    

}
#vpxmode
#add renaming rule test1  "\[%a]\[%d]"  "_@1_\[@2]" -pin -both
#tclmode

#########################################################################
# Change 'exit' to 'ON' to stop the script execution but not exit the tool.

#set_dofile_abort on

#set_undefined_cell Black_box -noascend     ;#// if module is missing lib - will treat as bbox
set_rule_handling -limit 1000 *

###########################################################################
# Change the number of threads to enable multithreading
#set_parallel_option -threads 1,$CPU -norelease_license
set_parallel_option -threads 1,$CPU
set_compare_options -threads 1,$CPU

##########################################################################
# READ LIBRARY
# library and design files
##########################################################################

    # <HN TODO> Read explicitly from supplement_setup
 #  add_notranslate_modules -library -both \
  #   GCU_M5* M5S* M5P*

  # adding no translate on SRAMs
if {[info exists NOTRANSLATE_BLOCK] && $NOTRANSLATE_BLOCK != ""} {
   
    set  notrans_modules $NOTRANSLATE_BLOCK 
    set  notrans_modules [regsub {(_\S+)?\.lef} [regsub {\S*/} [lsearch -all -inline $LEF_FILE_LIST "/BRCM/memories/"] ""] "*"]
} else {
    set  notrans_modules [regsub {(_\S+)?\.lef} [regsub {\S*/} [lsearch -all -inline $LEF_FILE_LIST "/BRCM/memories/"] ""] "*"]
}
if { [llength $notrans_modules] } {
    add_notranslate_modules -library -both $notrans_modules
}

## Meravi - Need to define a variable in supplemental_setup per stage for nontranslate
set _f_src "../scripts_local/${DESIGN_NAME}.${LEC_MODE}.notranslate.tcl"
if {[file exists $_f_src]} {
    exec cp -pv $_f_src ./sourced_scripts/    
    set _f_local "./sourced_scripts/${DESIGN_NAME}.${LEC_MODE}.notranslate.tcl"
    puts "-I- reading add_notranslate commands file: $_f_src"
    source $_f_src
}    

add_renaming_rule -module  ESTIMATE_REMOVE {_ESTIMATED$} {}
set mode  [lindex [split [lindex $scenarios(setup) 0] "_"] 0]
set check [lindex [split [lindex $scenarios(setup) 0] "_"] end]
regsub "${mode}_(.*)_${check}" [lindex $scenarios(setup) 0] {\1} sub_pvt
regexp {(.*[SF])_(.*)} $sub_pvt match PVT rc

#regexp {(.*[SF])_(.*)} [lindex $scenarios(setup) 0] match PVT rc]
#set LIB_LIST $pvt_corner($PVT,timing)

# <HN> Fix to include flies that are missing all views
set LIB_LIST ""
foreach pvt_timing [lsearch -all -inline [array names pvt_corner] "*,timing"] {
    foreach file $pvt_corner($pvt_timing) {
        regsub {_p..g_.*} $file {} file_base
        if { [lsearch $LIB_LIST "${file_base}_p??g_*"] >= 0 } {
            continue
        }
        lappend LIB_LIST $file  
    }
}
# //

if {$LEC_MODE == "rtl2elab" || $LEC_MODE == "elab2syn" || $LEC_MODE == "rtl2syn" || $LEC_MODE == "rtl2syn_flat" || $LEC_MODE == "rtl2rtl" || $LEC_MODE == "rtl2rtl_flat" || $LEC_MODE == "syn2dft"} {
    if {[info exists RTL_2_SYN_LIB_LIST] } {
	set golden_libs_var     $RTL_2_SYN_LIB_LIST
        set revised_libs_var     $RTL_2_SYN_LIB_LIST
    }
    if {[info exists RTL_2_SYN_NETLIST_LIST]} {
	set golden_verilogs_var $RTL_2_SYN_NETLIST_LIST
        set revised_verilogs_var $RTL_2_SYN_NETLIST_LIST
    }
    
    if { $LEC_MODE == "syn2dft" } {
	if {[info exists POST_DFT_LIB_LIST]} {
	    set revised_libs_var     $POST_DFT_LIB_LIST
	}
	if {[info exists POST_DFT_NETLIST_LIST]} {
	    set revised_verilogs_var $POST_DFT_NETLIST_LIST
	}
    }
} elseif {$LEC_MODE == "dft2place" || $LEC_MODE == "scantest"} {
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


# //

#set LIB_LIST $pvt_corner([lindex [array names pvt_corner] [lsearch [array names pvt_corner] *SS*timing]])


read_library -liberty -both [join ${LIB_LIST}]

if { [info exists golden_libs_var] } {
    puts "Info: Reading golden libs"
    foreach glib $golden_libs_var {
	read_library -liberty -append  -golden $glib
    }
}
if { [info exists revised_libs_var] } {
    puts "Info: Reading Revised libs"
    foreach rlib $revised_libs_var {
	read_library -liberty -append -revised $rlib
    }
}

##########################################################################
# READ DESIGN
# 
##########################################################################
if {$LEC_MODE == "rtl2rtl" || $LEC_MODE == "rtl2rtl_flat"} {
    puts "Information: filelist for golden and revised must come from user define"
} elseif {$LEC_MODE == "rtl2map"} {
    set fff [exec grep " Reading filelist" $SYN_DIR/log/do_syn.log | tail -n1 ]
    set golden_verilog_files "${SYN_DIR}/[lindex $fff end]"
    set revised_verilog_files $SYN_DIR/out/${DESIGN_NAME}.syn_map.v.gz
;## Need to add rtl2elab and elab2syn
} elseif {$LEC_MODE == "rtl2elab" || $LEC_MODE == "elab2syn" || $LEC_MODE == "rtl2syn" || $LEC_MODE == "rtl2syn_flat"} {
    set golden_verilog_files ../../inter/filelist
    set revised_verilog_files $SYN_DIR/out/$DESIGN_NAME.Syn.v.gz
} elseif {$LEC_MODE == "syn2dft"} {
    set golden_verilog_files $SYN_DIR/out/$DESIGN_NAME.Syn.v.gz
    set revised_verilog_files $SYN_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz
} elseif {$LEC_MODE == "dft2place"} {
    set golden_verilog_files $SYN_DIR/../inter/$DESIGN_NAME/${DESIGN_NAME}.v.gz
    set revised_verilog_files $INNOVUS_DIR/out/db/${DESIGN_NAME}.place.enc.dat/${DESIGN_NAME}.v.gz
} elseif {$LEC_MODE == "route2chip_finish"} {
    set golden_verilog_files $INNOVUS_DIR/out/db/${DESIGN_NAME}.route.enc.dat/${DESIGN_NAME}.v.gz
    set revised_verilog_files $INNOVUS_DIR/out/db/${DESIGN_NAME}.chip_finish.enc.dat/${DESIGN_NAME}.v.gz
}


if {[info exists GOLDEN_NETLIST]  && $GOLDEN_NETLIST != "None"}  { set golden_verilog_files  $GOLDEN_NETLIST  }
if {[info exists REVISED_NETLIST] && $REVISED_NETLIST != "None"} { set revised_verilog_files $REVISED_NETLIST }

if {![info exists golden_verilog_files] && ![info exists revised_verilog_files]} { puts "ERROR: missing golden_verilog_files and revised_verilog_files. need to define GOLDEN_NETLIST and REVISED_NETLIST flag."; exit 1}
if {![info exists golden_verilog_files]}   { puts "ERROR: missing golden_verilog_files. need to define GOLDEN_NETLIST flag."; exit 1}
if {![info exists revised_verilog_files]}  { puts "ERROR: missing revised_verilog_files. need to define REVISED_NETLIST flag."; exit 1}
#if {![file exists $golden_verilog_files] && ![file exists $revised_verilog_files]}  { puts "ERROR: golden and revised files do not exist: \n\t$golden_verilog_files\n\t$revised_verilog_files" ; exit 1}

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


if {[regexp "filelist" $golden_verilog_files]} {
    
   if {$LEC_MODE == "rtl2map"} {
       puts "reading golden RTL filelist from $golden_verilog_files"
       set rrr [exec grep -B1 -A20 read_design $SYN_DIR/fv/${DESIGN_NAME}/lec.rtl2map.do | grep -B10 "elaborate_design -golden" | grep -v "elaborate_design -golden"]
       regsub [lindex $fff end] $rrr $golden_verilog_files READ_DESIGN
       echo $READ_DESIGN
       eval $READ_DESIGN
   } elseif {$LEC_MODE == "rtl2elab" || $LEC_MODE == "elab2syn" || $LEC_MODE == "rtl2syn" || $LEC_MODE == "rtl2syn_flat" || $LEC_MODE == "rtl2rtl" || $LEC_MODE == "rtl2rtl_flat"} {


      # if { [info exists golden_libs_var] } {
#	   #lappend LIB_LIST [join [set $golden_libs_var]]
#	   foreach glib $golden_libs_var {
#	       read_library -liberty -append  -golden $glib
#	   }
   #    }

       puts "reading golden RTL filelist from $golden_verilog_files"
       read_design \
	   -remove_float_instance \
           -enumconstraint \
       -define NXT_PRIMITIVES \
       -define BRCM_NO_MEM_SPECIFY \
       -define SYNTHESIS  \
	   -merge bbox -golden -lastmod -noelab -sv09 -f  $golden_verilog_files
   }
   elaborate_design -golden -root "$DESIGN_NAME" -rootonly 
    
} else {
  # additional verilog files
    if {[info exists golden_verilogs_var]} {
        set golden_verilog_files "[set $golden_verilogs_var] [join $golden_verilog_files]"
    }
  # additional lib files
  ##  if {$LEC_MODE == "syn2dft"} {
  ##      set _tmp_stage "syn"
  ##  } elseif {$LEC_MODE == "dft2place" || $LEC_MODE == "scantest"} {
  ##      set _tmp_stage "postDFT"
  ##      }
  ##  if {[info exists golden_libs_var]} {
  ##      puts "-I- reading additional $_tmp_stage lib files"
  ##      read_library -liberty -append -golden [join [set $golden_libs_var]]
  ##      } else {
  ##      puts "-I- no additional $_tmp_stage lib files found"
  ##      }
  # reading golden design
    
    puts "reading golden netlist $golden_verilog_files"
    read_design -verilog -replace -golden [join $golden_verilog_files] -root $DESIGN_NAME     
}

# ~ ~ READING REVISED DESIGN ~ ~
if {[regexp "filelist" $revised_verilog_files]} {
    puts "reading revised RTL filelist from $revised_verilog_files"
    
    ### read_design -enumconstraint -define SYNTHESIS  -merge bbox -revised -lastmod -noelab -sv09 -f  $revised_verilog_files
          read_design \
	   -remove_float_instance \
           -enumconstraint \
       -define NXT_PRIMITIVES \
       -define BRCM_NO_MEM_SPECIFY \
       -define SYNTHESIS  \
	   -merge bbox -revised -lastmod -noelab -sv09 -f  $revised_verilog_files
    elaborate_design -revised -root "$DESIGN_NAME" -rootonly 
} else {
  # additional verilog design    
    if {[info exists revised_verilogs_var]} {
        set revised_verilog_files "[set $revised_verilogs_var] $revised_verilog_files"
    }

  # additional lib files
##   if {$LEC_MODE == "rtl2elab" || $LEC_MODE == "elab2syn" || $LEC_MODE == "rtl2syn" || $LEC_MODE == "rtl2syn_flat"} {
##       set _tmp_stage "syn"
##   } elseif {$LEC_MODE == "dft2place" || $LEC_MODE == "scantest"} {
##       set _tmp_stage "postDFT"
##       }
## 	
##   if {[info exists revised_libs_var]} {
##       puts "-I- reading additional $_tmp_stage lib files"
##       read_library -liberty -append -revised [join [set $revised_libs_var]]
##       } else {
##       puts "-I- no additional $_tmp_stage lib files found"
##           }
  # reading revised design
    if {![info exists REVISED_DESIGN_NAME]} {
        set REVISED_DESIGN_NAME $DESIGN_NAME
            }
    puts "reading revised netlist : $revised_verilog_files"
    read_design -verilog -replace -revised [join $revised_verilog_files] -root $REVISED_DESIGN_NAME
        ## Meravi - move  read_inplementation here - check if it starts from RTL first

}

set _f_src "../scripts_local/common.${LEC_MODE}.naming_rules.tcl"
if {[file exists $_f_src]} {
    exec cp -pv $_f_src ./sourced_scripts/    
    set _f_local "./sourced_scripts/common.${LEC_MODE}.naming_rules.tcl"
    puts "-I- reading naming_rule commands file: $_f_local"
    source $_f_local
}

### <HN> CHANGE - point to the central location, and copy to scripts_local if exists like hbm_v2 and hbm

set _f_src "../scripts_local/${DESIGN_NAME}.${LEC_MODE}.naming_rules.tcl"
if {[file exists $_f_src]} {
    exec cp -pv $_f_src ./sourced_scripts/    
    set _f_local "./sourced_scripts/${DESIGN_NAME}.${LEC_MODE}.naming_rules.tcl"
    puts "-I- reading naming_rule commands file: $_f_local"
    source $_f_local
}

##########################################################################
# set_flatten_model
# 
##########################################################################
 
if {[regexp "filelist" $golden_verilog_files] && [regexp "filelist" $revised_verilog_files]} {
    set_flatten_model -seq_constant
    set_flatten_model -seq_constant_x_to 0
    set_flatten_model -nodff_to_dlat_zero
    set_flatten_model -nodff_to_dlat_feedback
    set_flatten_model -hier_seq_merge
    set_flatten_model -gated_clock

    set_flatten_model -balanced_modeling
} elseif {[regexp "filelist" $golden_verilog_files]} {

    uniquify -all -nolib -golden
    
#add_renaming_rule ug_separate_rule1 __ {/} -both
#uniquify -all -nolib -golden -use_renaming_rule
#delete_renaming_rule ug_separate_rule1    

    set_flatten_model -nodff_to_dlat_zero -golden
    set_flatten_model -nodff_to_dlat_feedback -golden
    set_flatten_model -balanced_modeling -golden
    set_flatten_model -gated_clock -golden
    set_flatten_model -seq_constant -golden
#    set_flatten_model -seq_constant_x_to 0 -golden
    set_flatten_model -hier_seq_merge -golden
    vpx set flatten model  -SEQ_CONSTANT -golden
    
    
}


catch {checkpoint out/read_design.ckpt -replace}
if {$LEC_MODE == "rtl2syn"} { 
    echo "reading vsdc file"
#    system cfm_env vsdc2usetup.py /bespace/users/royl/inext/be_work/brcm5/lcb/flow_test/syn_dc/out/lcb.vsdc --output out/vsdc.setup --verbose --change_pin_name
#    read_guidance_information out/vsdc.setup -apply_pin
   if {[file exists ${SYN_DIR}/out/${DESIGN_NAME}.vsdc]} {
      read_setup_information -type VSDC ${SYN_DIR}/out/${DESIGN_NAME}.vsdc -apply_name_change
   }
  vpx add renaming rule sss2 {\.%a} {\[@1\]} -pin -revised


#  vpx add renaming rule test1 "\[%a]\[%d]" "_@1_\[@2]" -pin -both
#  vpx add renaming rule test2 "_%d\[%a]" "_@1_@2_" -pin -both
}

#   add renaming rule test3 {%a\[%d\].%a} {_@1_@2_@3]}  -pin -both
if {$LEC_MODE == "rtl2map"} { 
    set ANALYZE_MODULE [exec grep analyze_module $SYN_DIR/fv/${DESIGN_NAME}/lec.rtl2map.do]
    if {[info exists ANALYZE_MODULE] } {
        echo $ANALYZE_MODULE
        eval $ANALYZE_MODULE
    }
}
# write_library -revised out/lib.v

##########################################################################
# GENERATE REPORTS
# design data, black boxes, floating signals and environment setup
##########################################################################

report_design_data > reports/report_design_data.rpt
report_black_box -detail > reports/report_black_box.rpt
report_floating_signals > reports/report_floating_signals.rpt
report_environment > reports/report_environment.rpt

##########################################################################
# ECO flow
# 
##########################################################################
if {$LEC_MODE == "eco"} { 
    set_eco_option -flat
    uniquify -all -nolibrary -revised
    flatten -matchhierarch -nolibrary -revised
    set_flatten_model -gated_clock 
    report_mismatched_pin -type input > top_pi.do
    dofile top_pi.do
    report_mismatched_pin -type output > top_po.do
    dofile top_po.do
#    set_analyze_option -auto -report_map

}

############################################################################
# Enable auto analysis to help resolve issues due to sequential
# redundancy, sequential constant, clock gating, or sequential merging
# This option will automatically enable 'analyze abort -compare'
# to solve the aborts. 
if {[info exists MAPPING_FILE] && $MAPPING_FILE != "None"} {
   set_analyze_option -auto -report_map -mapping_file $mapping_file
   set_mapping_method -search_in_mapping_file
} else {
   set_analyze_option -auto -report_map -noanalyze_abort
}
set_mapping_method -sensitive
# middle_io_wrap exception
#if { ($LEC_MODE == "rtl2syn") && ($DESIGN_NAME == "middle_io_wrap") } {
#    add_primary_input /i_ds05_vtmon_w_reg_sbus_wrapper_01/thermal_sensor/inst_analog/pad_DAC -golden -pin
#    add_pin_constraints 0 /i_ds05_vtmon_w_reg_sbus_wrapper_01/thermal_sensor/inst_analog/pad_DAC -golden
#}


if { $DISABLE_SCAN == "true" || ($LEC_MODE == "scantest") } {
    # General Constraints
    set _f_const "../scripts_local/common.${LEC_MODE}.constraints.tcl"
    if {[file exists $_f_const]} {
        puts "-I- reading general constraint file: $_f_const"
        source $_f_const
    }
    # Block constraints
    set _f_src "../scripts_local/${DESIGN_NAME}.${LEC_MODE}.constraints.tcl"
    if {[file exists $_f_src]} {
        exec cp -pv $_f_src ./sourced_scripts/    
        set _f_local "./sourced_scripts/${DESIGN_NAME}.${LEC_MODE}.constraints.tcl"
        puts "-I- reading constraints commands file: $_f_local"
        source $_f_local
    }
} ;# $DISABLE_SCAN == "true" || scantest


report_cut_point > reports/report_cut_point.rpt
report_pin_constraints > reports/report_pin_constraints.rpt

if { $LEC_MODE == "rtl2map" || $LEC_MODE == "rtl2rtl" || $LEC_MODE == "rtl2syn" } {
    if {[file exists ../scripts_local/add_noblack_box.tcl ]} {
        puts "-I- source  ../scripts_local/add_noblack_box.tcl"
        source ../scripts_local/add_noblack_box.tcl
    }
#    write_hier_compare_dofile hier2.do -verbose -threshold 10000 -noexact_pin_match -constraint -usage \
#        -replace -balanced_extraction -input_output_pin_equivalence -extract_icg -function_pin_mapping -pin_binding
    set APPEND_STRING	{if {[get_compare_points -abort -count] > 0} {
	write_compared_points out/abort.lst -class abort -replace;
	 analyze_abort -class all -compare; 
	write_compared_points out/abort_aa.lst -class abort -replace}}

#    run_hier_compare hier2.do -check_noneq 
    eval {  write_hier_compare_dofile hier_r2r.do -replace -usage \
	-prepend_string "report_design_data; usage ; analyze_datapath -verbose" \
		-append_string "$APPEND_STRING"}

        run_hier_compare hier_r2r.do -nodynamic
    #save_session out/verified.session -replace
   
    # <HN> 24ww01c need to be in LEC mode for these reports
    set_system_mode lec
 
    report_verification > reports/report_verification.rpt
    report_compare_data -class nonequivalent -class abort -class notcompared > reports/report_compare_data.rpt
    catch { report_unmapped_points -notmapped > reports/report_unmapped_points.rpt }
    write_mapped_points out/mapped_points.tcl -REPlace

} else {
    
    ############################################################################
    # Specify the modeling directives for constant opimization and clock gating.
    #set_flatten_model -nodff_to_dlat_zero 
    #set_flatten_model -nodff_to_dlat_feedback
    set_flatten_model -nodff_dc

    set_flatten_model -seq_constant
    set_flatten_model -gated_clock
    set_system_mode lec
    
    ## Meravi - need to create a mapping file names for Razi like <design_name>_<tool>_<mode>_mapping.tcl -->  ../scripts_local/${DESIGN_NAME}.${LEC_MODE}.mappings.tcl
    set _f_src "../scripts_local/${DESIGN_NAME}.${LEC_MODE}.mappings.tcl"
    if {[file exists $_f_src]} {
        exec cp -pv $_f_src ./sourced_scripts/    
        set _f_local "./sourced_scripts/${DESIGN_NAME}.${LEC_MODE}.mappings.tcl"
        puts "-I- reading mappings commands file: $_f_local"
        source $_f_local
    }
    
    ############################################################################
    # GENERATE REPORTS
    # mapped and unmapped key points
    ############################################################################
    report_mapped_points -summary > reports/report_mapped_points.rpt
    catch { report_unmapped_points -notmapped > reports/report_unmapped_points.rpt }
    catch { report_unmapped_points -extra }

    report_messages -modeling -verbose -golden > reports/report_messages_golden_verbose.rpt
    report_messages -modeling -verbose -revised > reports/report_messages_revised_verbose.rpt
    report_messages -mapping -verbose -golden  > reports/report_messages_mapping_golden_verbose.rpt
    report_messages -mapping -verbose -revised > reports/report_messages_mapping_revised_verbose.rpt

 
    write_mapped_points out/mapped_points.tcl -REPlace

    # MI
    add_compared_points -all
    ############################################################################
    # COMPARE DESIGNS
    ############################################################################
    analyze_datapath -module -verbose 
    eval analyze_datapath $DATAPATH_SOLVER_OPTION -verbose
    
    ############################################################################
    # COMPARE DESIGNS
    ############################################################################
    # MI
    # MI add_compared_points -all
    
    if { ($LEC_MODE == "dft2place")&&($DESIGN_NAME=="periphery_top_io_wrap") } {
       # delete_compared_points "i_nxt_gpio_aux_genblk1_i_gpio_vbias" -golden
       # delete_compared_points "i_nxt_gpio_aux_genblk1_i_gpio_por" -golden
    }

    if {$LEC_MODE == "eco"} {
       compare  
 
    	puts "-I- analyze_hier_compare"
        analyze_hier_compare -dofile hier.eco.do -replace -eco_aware -verbose
    	puts "-I- compare eco hierarchy"
#        compare eco hierarchy

        report_eco_hierarchy -noneq -verbose > reports/report_eco_hierarchy.noneq.verbose.rpt
        report_eco_check -verbose  > reports/report_eco_check.verbose.rpt
        puts "-I- analyze_eco"
        if {[info exists ECO_NUM] && $ECO_NUM != "None"} {
            eval analyze_eco out/patch_eco${ECO_NUM}.v -rep -ecopin_dofile ecopin.do -replace 
        } else {
            analyze_eco out/patch.v -rep -ecopin_dofile ecopin.do -replace 
        }
       
        set_system_mode setup 
    	puts "-I- apply_patch -auto -golden -keephier"
        apply_patch -auto -golden -keephier
        
        
        set PWD [exec pwd]
        catch {set GENUS [exec which genus]}
        if {![info exists GENUS]} {
            puts "WARNING : cannot find genus exectution file"
            set GENUS "/tools/cdnc/genus/21.15.000/tools.lnx86/bin/genus"
        }
        if {[info exists ECO_NUM] && $ECO_NUM != "None"} {
             set cmd "optimize_patch -workdir ${PWD} -instancenaming LOGIC_ECO${ECO_NUM}_inst_%d -netnaming LOGIC_ECO${ECO_NUM}_net_%d -sequentialnaming LOGIC_ECO${ECO_NUM}_reg_%s -synexec $GENUS -PRESYNscript $PWD/scripts/flow/pre_syn.tcl"
        } else {
             set cmd "optimize_patch -workdir ${PWD} -instancenaming LOGIC_ECO_inst_%d -netnaming LOGIC_ECO_net_%d -sequentialnaming LOGIC_ECO_reg_%s -synexec $GENUS -PRESYNscript $PWD/scripts/flow/pre_syn.tcl"
        }

        if {[file exists ../scripts_local/mmmc_results.tcl_not]} {
          set cmd "$cmd -MMMC $PWD/../scripts_local/mmmc_results.tcl"
        } else {
          set cmd "$cmd -library $LIB_LIST -sdc $SDC_LIST"
        }
        eval $cmd
        #eval optimize_patch -workdir ${PWD}/genus_eco_${ECO_NUM} -library $LIB_LIST -sdc $SDC_LIST -instancenaming "ECO${ECO_NUM}_inst_%d" -netnaming "ECO_${ECO_NUM}_net_%d" -sequentialnaming "ECO_${ECO_NUM}_reg_%s" -synexec "$GENUS"
        #write verification info <uvi>
        write_eco_design -DIR [pwd]/out -newfile %s.pre.G3 -replace -report reports/ECO${ECO_NUM}_prelogics.rpt
        report_eco_changes -innovus -file out/eco${ECO_NUM}.tcl -replace
        report_eco_changes -summary -file out/eco${ECO_NUM}.sum -replace

    } else {
        compare -noneq_stop 200 
	if {[get_compare_points -abort -count] > 0} {
	    write_compared_points out/abort.lst -class abort
	    analyze_abort -compare
	    write_compared_points out/abort_aa.lst -class abort

	    #set_compare_effort high
	    #compare -noneq_stop 200
	}
    
        ############################################################################
        # GENERATE REPORTS
        # compare data, mapped key points and verification information
        ############################################################################
    
        report_compare_data -class nonequivalent -class abort -class notcompared > reports/report_compare_data.rpt
        report_compare_data -class nonequivalent > reports/report_nonequivalent.rpt
        catch { report_unmapped_points -notmapped > reports/report_unmapped_points.rpt }
        report_verification > reports/report_verification.rpt
        report_statistics > reports/report_statistics.rpt
    
        puts "No of compare points = [get_compare_points -count]"
        puts "No of diff points    = [get_compare_points -NONequivalent -count]"
        puts "No of abort points   = [get_compare_points -abort -count]"
        puts "No of unknown points = [get_compare_points -unknown -count]"
        if {[get_compare_points -count] == 0} {
            puts "---------------------------------"
            puts "ERROR: No compare points detected"
            puts "---------------------------------"
        }
        if {[get_compare_points -NONequivalent -count] > 0} {
            puts "------------------------------------"
            puts "ERROR: Different Key Points detected"
            puts "------------------------------------"
        }
        if {[get_compare_points -abort -count] > 0} {
            puts "-----------------------------"
            puts "ERROR: Abort Points detected "
            puts "-----------------------------"
        }
        if {[get_compare_points -unknown -count] > 0} {
            puts "----------------------------------"
            puts "ERROR: Unknown Key Points detected"
            puts "----------------------------------"
        }
    } ; #  if {$LEC_MODE == "eco"}
    #checkpoint out/verified.ckpt -replace
}
#save_session out/final.session -replace
## this if will mask the printing of the below commands (before executing them)
if {1} {
    set end_t [clock seconds]
    puts "###################################################################################################"
    puts "#     Start running STAGE at: [clock format $start_t -format "%d/%m/%y %H:%M:%S"]"
    puts "#     End running STAGE at: [clock format $end_t -format "%d/%m/%y %H:%M:%S"]"
    puts "#     Elapse time is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
    puts "###################################################################################################"
}
if {$LEC_MODE == "eco"} {
            exit
} else {
    if { $LEC_MODE == "rtl2map" || $LEC_MODE == "rtl2rtl" || $LEC_MODE == "rtl2syn" } {
	report_hier_compare_result  -non_equivalent > check
	report_hier_compare_result  -abort >> check
	report_hier_compare_result  -uncompared >> check
	set fail [split [read [open check r]] "\n"]
	if {[lsearch -regexp  $fail {^Non-equivalent:\s+(\S+)}] > -1 || [lsearch -regexp  $fail {^Abort\s+:\s+(\S+)}] > -1} {
	    puts "\n\tFORMAL VERIFICATION FAILED"
	    catch {checkpoint out/compare.ckpt -replace}
	    proc_lec_pass false
	    if { $INTERACTIVE != "true"} { 
		exit
	    }
	} else {
	    puts "\n\tFORMAL VERIFICATION PASS"
	    catch {checkpoint out/compare.ckpt -replace}
	    proc_lec_pass 
	    if { $INTERACTIVE != "true"} { 
		exit
	    }

	}
} else {
    if {[get_compare_points -nonequivalent -count] > 0 || [get_compare_points -abort -count] > 0 || [get_compare_points -notcompared -count] > 0 } {
        puts "\n\tFORMAL VERIFICATION FAILED"

	    catch {checkpoint out/compare.ckpt -replace}
        #save_session out/compare.session -replace

#    analyze_sequential_constants -REPORT > reports/analyze_sequential_constants.rpt
        proc_lec_pass false
        if { $INTERACTIVE != "true"} { 
            exit
        }
     } else {
        puts "\n\tFORMAL VERIFICATION PASSED"
	    catch {checkpoint out/compare.passed.ckpt -replace}
        proc_lec_pass
        if { $INTERACTIVE != "true"} { 
           exit
	    }
        }
     }
}




# source to this file come from :
# /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/inext_design_kit_20210704/PNR_SUPPORT_SCRIPTS/invs_apply_socv_derates.tcl
#####################################################################
####### Copy and Translate derate files from innovus to genus #######
#####################################################################

# !!! TODO - verify these settings and efine them in seutp.tcl file
set TVAR(sta,apply_aging_derates) false ; # ???
#set TVAR(sta,apply_clock_aging_derate_from_gater) false ; # ???
#set TVAR(sta,clock_vt_mismatch_derate)

#set TVAR(sta,max_vnom) 0.83

#TVAR(sta,max_vnom,$voltage)
#set TVAR(sta,use_85C_aging_derates) false ; # ???
#set TVAR(sta,enable_struct_clk_net_derate) false ; # ???
# !!!

#set INVS_SOCV_SUPPORT_DIR /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/latest/INVS_SOCV_SUPPORT_DIR
set lib_file_index [lsearch [get_db libraries .files] *STD*]
if { $lib_file_index < 0 } { puts "-E- No STD cells lib found!" ; #exit }
set lib_file [lindex [get_db libraries .files] $lib_file_index]
set new_pointer "[join [lrange [split $lib_file "/"] 0 end-3] "/"]/INVS_SOCV_SUPPORT_DIR"

if { ![file exists $new_pointer] } {
    echo "INFO: no new pointer variable"
    set new_pointer "[join [lrange [split $lib_file "/"] 0 end-3] "/"]/TIMING_SUPPORT/INVS"
    set PT_new_pointer "[join [lrange [split $lib_file "/"] 0 end-3] "/"]/TIMING_SUPPORT/PTSI"
    echo "INFO: new_pointer is $new_pointer"
    echo "INFO: PT_new_pointer is: PT_new_pointer"
 
    if { ![file exists $new_pointer] } {
	puts "-E- No INVS_SOCV_SUPPORT_DIR found!"
    	#exit
    } else {
    	set INVS_SOCV_SUPPORT_DIR $new_pointer
        set PTSI_SOCV_SUPPORT_DIR $PT_new_pointer
    }
} else {
    set INVS_SOCV_SUPPORT_DIR $new_pointer
    set PTSI_SOCV_SUPPORT_DIR $PT_new_pointer
}


mkdir -pv ./derates
file delete -force ./derates/*



foreach file [glob $INVS_SOCV_SUPPORT_DIR/*] {
    if { [file exists $file] } { exec cp -rp $file ./derates/ }
}


set orig_support_dir $INVS_SOCV_SUPPORT_DIR
set PT_orig_support_dir $PTSI_SOCV_SUPPORT_DIR
set INVS_SOCV_SUPPORT_DIR ./derates/

if { [get_db program_short_name] == "genus" } {

    unsuppress_msg {SDC-208 TUI-170 SDC-204 TUI-182}  
    
    cd ./derates
    
    set cmd "exec ls | xargs sed -i \{1 i\# This file was copied from $orig_support_dir\}"
    eval $cmd
    
#    exec ls | xargs sed -i {s/-quiet//g}
#    exec ls | xargs sed -i {s/get_lib_cells/get_db lib_cells /g}
#    exec ls | xargs sed -i {s/-filter \"base_name=~/-if \".base_name==/g}
#    exec ls | xargs sed -i {s/all_delay_corners/get_db designs .delay_corners.name/g}    

    # use primetime files for sigma
    echo 1
    foreach file [glob $PTSI_SOCV_SUPPORT_DIR/sigma_derate_primetime-lvf_tsmc5ff*.tcl] {
        set new_file [lindex [split $file '/' ] end]
        sed 's/\-pocvm_coefficient_scale_factor/\-sigma \-multiply/g' $file  | sed 's/-cell_delay/-delay_corner \$tempus_del_cnr/g' > $new_file
    }
    echo 2
    set cmd " ls sigma_derate_primetime* | xargs sed -i \{1 i\# This file was copied from $PTSI_SOCV_SUPPORT_DIR\}"
    #eval $cmd
    echo 3

    # use primetime files for timing_derate_simulswitch
    foreach file [glob $PTSI_SOCV_SUPPORT_DIR/timing_derate_simulswitch_primetime-*coefficient] {
        set new_file [lindex [split $file '/' ] end]
        sed 's/set_multi_input_switching_coefficient/set_timing_derate \-input_switching \-delay_corner \$tempus_del_cnr \-data/g' $file  | sed 's/-delay /-cell_delay /g' | sed 's/\-override//g' > $new_file
    }
    echo 4

    cd ../    

    if { [file exists ./derates/memory_derates.tcl] } {

        set fp [open ./derates/memory_derates.tcl r]
        set fd [read $fp]
        close $fp
        
        set new_data {}
        
        foreach line [split $fd "\n"] {

            if { [regexp "get_cells  -of_objects \\\$mem_lib_cells" $line] } {
                set line "set mem_cells {}\nforeach bc \[get_db -uniq \$mem_lib_cells .base_cell\] { set mem_cells \[concat \$mem_cells \[get_db insts -if .base_cell==\$bc\] \] }\nset memory_cells \[get_cells -quiet \$mem_cells\]"
            }
            
            if { [regexp "report_socv_library" $line ] } {
                set line "  set report \"No report_socv_library defined in genus, so this is what we get\""
            }
            
            lappend new_data $line              
        }
        


    }
    set  fp  [open ./derates/memory_derates.tcl w]    
    puts $fp [join $new_data "\n"] 
    close $fp

    
} else {
   
    cd ./derates
    
    set cmd "exec ls | xargs sed -i \{1 i\# This file was copied from $orig_support_dir\}"
    eval $cmd


    # use primetime files for sigma
    foreach file [glob $PTSI_SOCV_SUPPORT_DIR/sigma_derate_primetime-lvf_tsmc5ff*.tcl] {
        set new_file [lindex [split $file '/' ] end]
        sed "s/\-pocvm_coefficient_scale_factor/\-sigma \-multiply/g" $file  | sed "s/-cell_delay/-delay_corner \$tempus_del_cnr/g" > $new_file
    }

    set cmd " ls sigma_derate_primetime* | xargs sed -i \{1 i\# This file was copied from $PTSI_SOCV_SUPPORT_DIR\}"
    eval $cmd

    # use primetime files for timing_derate_simulswitch
    foreach file [glob $PTSI_SOCV_SUPPORT_DIR/timing_derate_simulswitch_primetime-*coefficient] {
        set new_file [lindex [split $file '/' ] end]
        sed "s/set_multi_input_switching_coefficient/set_timing_derate \-input_switching \-delay_corner \$tempus_del_cnr \-data/g" $file  | sed "s/-delay /-cell_delay /g" | sed "s/\-override//g" > $new_file
    }
    


    cd ../  

}

    echo 5

# Fix unsuitable anntoation script
if { [file exists ./derates/memory_derates.tcl] } {
    
    set fp [open ./derates/memory_derates.tcl r]
    set fd [read $fp]
    close $fp
    
    set index 0
    set start_index -1
    set brace_count 0
    foreach line [split $fd "\n"] {
    
        if { $start_index > 0 && $brace_count == 0            } { set end_index [expr $index - 1] ; break }     
        if { [regexp "proc annotate_memory_hold_arcs " $line] } { set start_index $index  }
        
        set ob [llength [regexp -inline -all "{" $line]]
        set cb [llength [regexp -inline -all "}" $line]]
        
        incr brace_count [expr $ob-$cb]
        
        incr index
#        puts $line
#        puts $brace_count        
    }
    
    set new_annotate_memory_hold_arcs "
proc annotate_memory_hold_arcs {memory_cells pattern hold_margin} {

  set checked_lib_cells \[list\]
  foreach_in_collection lib_cell \[get_lib_cells -quiet \[get_db  lib_cells */\$pattern\] \] {
    set ref_name \[get_db \$lib_cell .base_name\]

    ## to prevent an arc from being added multiple times as each memory is associated with multiple libraries (ss/mem.db, ff/mem.db).
    if {\[lsearch \$checked_lib_cells \$ref_name\] != -1} {continue}

    lappend checked_lib_cells \$ref_name
    set arcs \[get_db \$lib_cell .lib_arcs\]
    set arcs \[get_db \$arcs -if .sense==hold_clk*\]
    foreach arc \$arcs {
      set from_pin \[get_db \[get_db \$arc .from_lib_pin\] .base_name\]
      set to_pin   \[get_db \[get_db \$arc .to_lib_pin\] .base_name\]
      if {!\[info exists uniqueCheck(\${ref_name},\${from_pin},\${to_pin})\]} {

        lappend memHoldArcs(\$ref_name) \[list \$from_pin \$to_pin\]
        set uniqueCheck(\${ref_name},\${from_pin},\${to_pin}) 1
      }
    }
  }

  foreach_in_collection inst \$memory_cells {
    set inst_name \[get_object_name \$inst\]
    set ref_name \[get_db \$inst .base_cell.name\]
    puts \"INFO: Adding \${hold_margin}ps of incremental hold delay to hold timing arcs for \$inst_name (\$ref_name)\"

    if { !\[info exists memHoldArcs(\$ref_name)\] } { return }

    foreach list \$memHoldArcs(\$ref_name) {
      set from_pin \[lindex \$list 0\]
      set to_pin \[lindex \$list 1\]
      set_annotated_check \$hold_margin -incr -hold -from \[get_pins \$inst_name/\$from_pin\] -to \[get_pins \$inst_name/\$to_pin\]
    }
  }
}    
    "
    
    set new_mem_derate [lreplace [split $fd "\n"] $start_index $end_index $new_annotate_memory_hold_arcs]
    
    set  fp  [open ./derates/memory_derates.tcl w]    
    puts $fp [join $new_mem_derate "\n"] 
    close $fp
}


#####################################################################

set_interactive_constraint_modes [all_constraint_modes -active]

set processIdentLC 5ff

set processIdentUC [string toupper $processIdentLC]

# set ALL mean and sigma/sensitivity derates to 1.0
reset_timing_derate
#
# reset annotated checks - currently only used for memory inputs for hold
reset_annotated_check -all

# NOTE:  once the mean and/or sigma derates are applied, you MUST VERIFY all subsequant
#        modifications that are applied are modifying the values correctly!  For example
#          "-add"      without specifying -mean or -sigma does nothing
#          "-multiply" without specifying -mean or -sigma does nothing
#
#        Hence, it is VERY IMPORTANT that the files are applied in the appropriate orders

# jdb - apply secv derates across each delay corner spec'd per pvt

foreach dc [get_db [get_db analysis_views -if .is_active==true] .delay_corner] { 

    set bn [get_db $dc .name]
    set tempus_del_cnr $bn
    set tc [get_db $dc .early_timing_condition_string]
    
    #set cut_name [join [lrange [split $bn "_"] 0 end-2] "_"] 
    set cut_name [get_db $dc .default_early_timing_condition.name]
    set lib_name "lib_$cut_name"
    
    set corner_libs [get_db libraries $lib_name/*]
    set lib_list [list]
    foreach name [get_db $corner_libs .base_name] {
        set cut_name [join [lrange [split $name "_"] 0 end-1] "_"]
        lappend lib_list $cut_name
    }

    set libs [lsort -u $lib_list]
    
    puts "\n\n-I- corner: $dc\n\ttempus_del_cnr $tempus_del_cnr\n\ttc: $tc"
    
    
# Roy 12/02/2023 does not read this to Prime Time
    # set per lib_cell unique mean derates applied with -multipy of the previous value(should be 1.0 after reset above)
    echo 6
    
    set filename [lindex $pvt_corner($tc,pt_ocv) [lsearch  $pvt_corner($tc,pt_ocv) *global_signoff]]
    puts "-I- global_signoff file: $filename"
    
    if {[file exists $filename]} {
        set new_file [lindex [split $filename '/' ] end]
        puts "-I- global_signoff new file: $new_file"
        set lib_voltage [lindex [split $new_file "_"] 3]
        if {[get_db program_short_name] == "genus"} {
            sed 's/set_timing_derate/set_timing_derate -delay_corner \$tempus_del_cnr/g' $filename | sed 's#-increment\$#-increment \[get_lib_cells *${lib_voltage}*/* -filter \"base_name=~F6*\" -quiet\]#g'  | perl -pe   's/(^.*min_data_aging_derate.*vt_mismatch_data.pffg.)/# \$1/g' | perl -pe 's/(set_timing_derate.*max_data_aging_derate)/# \$1/' > ./derates/tmp
	    perl -pe 's/(set_timing_derate.*(expr.*.staRecipeDataCellDerate.early,.name. . .vt_mismatch_data.pffg.).*)/if \{\[\$2\]>0\} \{ \$1 \}/'  ./derates/tmp > ./derates/tmp_1  
	    perl -pe 's/(set_timing_derate.*(.staRecipeDataCellDerate.late,.name.).*)/if \{\$2>0\} \{ \$1 \}/'  ./derates/tmp_1 > ./derates/tmp_2  
	    perl -pe 's/(set_timing_derate.*(.min_recovery_aging_derate).*)/if \{\$2>0\} \{ \$1 \}/'  ./derates/tmp_2 > ./derates/tmp_3  
	    perl -pe 's/(set_timing_derate.*(.max_recovery_aging_derate).*)/if \{\$2>0\} \{ \$1 \}/'  ./derates/tmp_3 > ./derates/tmp_4  
	    perl -pe 's/(set_timing_derate.*(.staRecipeCellRecoveryDerate.early,.name.).*)/if \{\$2>0\} \{ \$1 \}/'  ./derates/tmp_4 > ./derates/tmp_5
	    perl -pe 's/(set_timing_derate.*(.staRecipeCellRecoveryDerate.late,.name.).*)/if \{\$2>0\} \{ \$1 \}/'   ./derates/tmp_5 > ./derates/tmp_6 
	    perl -pe 's/(set_timing_derate.*net.*) -incr/\$1 -add/' ./derates/tmp_6 > ./derates/$new_file  

	     



        } else {
           sed "s/set_timing_derate/set_timing_derate \-delay_corner \$tempus_del_cnr/g" $filename | sed "s#\-increment\$#\-increment \[get_lib_cells *${lib_voltage}*/* -filter \"base_name=~F6*\" \-quiet\]#g"  > ./derates/$new_file    
	   if {![regexp {22.1} [get_db program_version]]} {
	       exec perl -p -i -e "s/(-net -incr .*)/\$1 \[get_nets -hierarchical \]/" ./derates/$new_file  
 	   } 

        }
        set cmd " ls ./derates/$new_file | xargs sed -i \{1 i\# This file was copied from $filename\}"
        echo "CMD: $cmd"
#    eval $cmd
        source  ./derates/$new_file
    
    } else {
       puts "WARNING: filename mean_derate_innovus-socv: $filename for delay_corner: $bn does NOT exist"
    }
    

#    foreach lib $libs { 
#      set filename $INVS_SOCV_SUPPORT_DIR/mean_derate_innovus-socv_${lib}.tcl
#      if {[file exists $filename]} {
#       puts "-I- Loading mean_derate_innovus-socv: $filename for delay_corner: $bn"
#       source $filename
#      } elseif {[regexp {M5.*X.*VT.*} $filename]} {
#       #this is N5 memories  and does not have mean_derate_innovus-socv.
#      } else {
#       puts "WARNING: filename mean_derate_innovus-socv: $filename for delay_corner: $bn does NOT exist"
#      }
#    }

# Roy 12/02/2023 reading Prime Time setting instead of Innovus
    # set per lib_cell unique sigma derates applied with -multipy of the previous value(should be 1.0 after reset above)
    foreach lib $libs { 
#      set filename $INVS_SOCV_SUPPORT_DIR/sigma_derate_innovus-socv_${lib}.tcl
      set filename $INVS_SOCV_SUPPORT_DIR/sigma_derate_primetime-lvf_${lib}.tcl
      if {[file exists $filename]} {
#        puts "-I- Loading sigma_derate_innovus-socv $filename for delay_corner: $bn"
        puts "-I- Loading sigma_derate_primetime-lvf_tsmc5ff $filename for delay_corner: $bn"
        source  $filename
      } elseif {[regexp {M5.*X.*VT.*} $filename]} {
      	#this is N5 memories  and does not have mean_derate_innovus-socv.
      } else {
#        puts "WARNING: sigma_derate_innovus-socv filename $filename for delay_corner: $bn does NOT exist"
        puts "WARNING: sigma_derate_primetime-lvf_tsmc5ff filename $filename for delay_corner: $bn does NOT exist"
      }
    }
    
    echo 7

    # apply aging derates
    # Apply default worst-case -add(additive) mean derate across all lib_cells
    #   and then adjust each vt flavor(uvt/lvt/svt) from the default
    # This file must be source after the two above in order for the "additive" margin to
    # be handled correctly

    # Define char points
    set char_points {}
    foreach lib $libs {  
        set char_point "${processIdentUC}_[join [lrange [split $lib "_"] 2 end] "_"]"
        lappend char_points $char_point  
    } 
     
    set char_points [lsort -u $char_points]
    
    echo 8
     
    foreach char_point $char_points {
        if { [info exists TVAR(sta,use_ce_aging)] && $TVAR(sta,use_ce_aging) } {
          set filename $INVS_SOCV_SUPPORT_DIR/${char_point}_innovus-socv.global_signoff.ce
        } else {
          set filename $INVS_SOCV_SUPPORT_DIR/${char_point}_innovus-socv.global_signoff
        }
        if {[file exists $filename]} {
	   if {[get_db program_short_name] == "genus"} {
	   } else {
              puts "-I- Loading innovus-socv.global_signoff $filename for delay_corner: $bn"
              source  $filename
	   }
        } else {
          #puts "WARNING: innovus-socv.global_signoff filename $filename for delay_corner: $bn does NOT exist"
        }
    }
    
    echo 9

# Roy 12/02/2023 reading Prime Time setting instead of Innovus
    # apply simultanious switching(MIS/SSI) derates only in hold corners
#    if {[regexp _hold $tempus_del_cnr]} {
      foreach lib $libs { 
         regexp {(tsmc5ff_\S+)_p[fs].*} $lib match libbb
         if {[info exists libbb]} {
	    set filename ./derates/timing_derate_simulswitch_primetime-lvf_${libbb}.coefficient
	 } else { 
	    set filename ./derates/timing_derate_simulswitch_primetime-lvf_${lib}.coefficient
	 }
#        set filename $INVS_SOCV_SUPPORT_DIR/timing_derate_simulswitch_innovus-socv_${lib}.tcl
#        set filename $PTSI_SOCV_SUPPORT_DIR/timing_derate_simulswitch_primetime-lvf_${lib}.tcl
        if {[file exists $filename]} {
#          puts "-I- Loading timing_derate_simulswitch_innovus $filename for $tempus_del_cnr ..."
          puts "-I- Loading timing_derate_simulswitch_primetime $filename for $tempus_del_cnr ..."
          source $filename
        } else {
          puts "WARNING: timing_derate_simulswitch_innovus filename $filename for $tempus_del_cnr does NOT exist"
#          puts "WARNING: timing_derate_simulswitch_primetime filename $filename for $tempus_del_cnr does NOT exist"
        }
      }
#    }

    echo 10

# Roy 21/02/2023 add extra derate for corrolation:
    if {[regexp _hold $tempus_del_cnr]} {
    } else {
       
       set_timing_derate 0.290 [get_lib_cells F6L*_BSDFFRW4VPX4] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.290 [get_lib_cells F6L*_BSDFFRW4VPX2] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.290 [get_lib_cells F6L*_BSDFFRX2] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.290 [get_lib_cells F6L*_BSDFFRX8] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.290 [get_lib_cells F6L*_BSDFFMX2] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.290 [get_lib_cells F6L*_BSDFFRX4] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.290 [get_lib_cells F6L*_BSDFFW4VPX2] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.290 [get_lib_cells F6L*_BSDFFW4VPX2] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.455 [get_lib_cells F6L*_BSDFFX4] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.290 [get_lib_cells F6L*_BSDFFX8] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.255 [get_lib_cells F6UL*_BSDFFMX2] -increment -cell_check -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.365 [get_lib_cells F6UL*_BSDFFX8] -increment -cell_check -data -delay_corner $tempus_del_cnr
       echo 10.1
	
       set_timing_derate 0.041 [get_lib_cells F6UN*_OAI222X1]    -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.029 [get_lib_cells F6ENAA_SRESYNC3RX2] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       
       echo 10.2
       set_timing_derate -early -0.045 [get_lib_cells F6UN*_LPDINVX4]	 -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -early  0.045 [get_lib_cells F6UNAA_LPDINVX28]  -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -early  0.045 [get_lib_cells F6UNAA_LPDINVX32]  -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -early -0.045 [get_lib_cells F6UNAA_LPDINVX8]   -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -early -0.045 [get_lib_cells F6UN*_LPDINVX16]   -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -early -0.045 [get_lib_cells F6UN*_LPDINVX24]   -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -early -0.045 [get_lib_cells F6UN*_LPDINVX12]   -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -early  0.045 [get_lib_cells F6UNAA_LPDINVX32]  -increment -cell_delay -clock -delay_corner $tempus_del_cnr
      
       set_timing_derate -late  0.065 [get_lib_cells F6UN*_LPDINVX4]	-increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -late -0.065 [get_lib_cells F6UNAA_LPDINVX28]  -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -late -0.065 [get_lib_cells F6UNAA_LPDINVX32]  -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -late  0.065 [get_lib_cells F6UNAA_LPDINVX8]	-increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -late  0.065 [get_lib_cells F6UN*_LPDINVX16]	-increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -late  0.065 [get_lib_cells F6UN*_LPDINVX24]	-increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -late  0.065 [get_lib_cells F6UN*_LPDINVX12]	-increment -cell_delay -clock -delay_corner $tempus_del_cnr
       set_timing_derate -late -0.065 [get_lib_cells F6UNAA_LPDINVX32]  -increment -cell_delay -clock -delay_corner $tempus_del_cnr
       echo 10.3
      
       set_timing_derate 0.088 [get_lib_cells F6S*_DLY025X2]    -increment -cell_delay -data -delay_corner $tempus_del_cnr

       set_timing_derate 0.068 [get_lib_cells *M5PSP111HD*]    -increment -cell_delay -data -delay_corner $tempus_del_cnr
              
     
       set_timing_derate 0.290 [get_lib_cells F6UL*_BSDFFX2] -increment -cell_check -data -delay_corner $tempus_del_cnr
       
       set_timing_derate 0.085 [get_lib_cells F6L*X1]  -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.081 [get_lib_cells F6L*X2]  -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.077 [get_lib_cells F6L*X4]  -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.073 [get_lib_cells F6L*X6]  -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.069 [get_lib_cells F6L*X8]  -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.065 [get_lib_cells F6L*X12]   -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.057 [get_lib_cells F6L*X14]   -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.052 [get_lib_cells F6L*X16]   -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.037 [get_lib_cells F6L*X20]   -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.033 [get_lib_cells F6L*X24]   -increment -cell_delay -data -delay_corner $tempus_del_cnr
       

       
       set_timing_derate 0.044 [get_lib_cells F6UL*X1] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.035 [get_lib_cells F6UL*X2] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.031 [get_lib_cells F6UL*X4] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.029 [get_lib_cells F6UL*X6] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.026 [get_lib_cells F6UL*X8] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.024 [get_lib_cells F6UL*X10] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.022 [get_lib_cells F6UL*X12] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.021 [get_lib_cells F6UL*X16] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       set_timing_derate 0.019 [get_lib_cells F6UL*X24] -increment -cell_delay -data -delay_corner $tempus_del_cnr
       
    }

    

}
echo 11

# apply memory-specific scalar derates and incremental hold checks on memory input pins
#   NOTE: the scalar derates will override anything applied above to memories
set filename $INVS_SOCV_SUPPORT_DIR/memory_derates.tcl
if {[file exists $filename]} {
  puts "Loading $filename for $tempus_del_cnr ..."
  if { [catch { source $filename } res ] } { puts $res ; puts "Error - failed during $filename source" ; return }
} else {
  puts "WARNING: filename $filename for $tempus_del_cnr does NOT exist"
}
set_interactive_constraint_modes {}
puts "End sourcing"

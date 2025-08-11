#!/bin/tclsh

proc _parse_args_ { args } {
    upvar opt opt
    set args [regsub -all "\{\|\}\|\\\\" $args ""]
    set split_args [split $args "-"]
    
    foreach arg $split_args {
        if { $arg == "" || $arg == "{" || $arg == "}" } { continue }
        set opt([lindex $arg 0]) [lrange $arg 1 end]
    }
}

proc parse_blocks_csv { csv_file target_dir reports_only } {
    
    if { ![file exists $csv_file]  } { puts "-E- File $csv_file not found." ; return -1 }
    if { ![file exists $target_dir]} { puts "-I- Creating directoru: $target_dir" ; exec mkdir -pv $target_dir }
    
    exec mkdir -pv $target_dir/lefs
    exec mkdir -pv $target_dir/defs
    exec mkdir -pv $target_dir/libs
    exec mkdir -pv $target_dir/netlists
    exec mkdir -pv $target_dir/spefs
    exec mkdir -pv $target_dir/gpds
    exec mkdir -pv $target_dir/dbs
    
    exec touch $target_dir/MANIFEST.txt
    exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copying inputs to [exec realpath $target_dir]" >> $target_dir/MANIFEST.txt

    set view_list [list "func_no_od_125_LIBRARY_SS_c_wc_cc_wc_T_setup"  \
                        "func_no_od_125_LIBRARY_FF_c_bc_cc_bc_hold"     \
                        "func_no_od_minT_LIBRARY_FF_c_bc_cc_bc_hold"    \
                        "func_no_od_minT_LIBRARY_FF_rc_wc_cc_wc_T_hold" \
                        "func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup" \
                        "func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup" \
                        "func_no_od_125_LIBRARY_FF_rc_bc_cc_bc_hold"    \
                        "func_no_od_minT_LIBRARY_FF_rc_bc_cc_bc_hold"   \
                        "func_no_od_minT_LIBRARY_SS_rc_bc_cc_bc_setup"  \
                        "func_no_od_125_LIBRARY_FF_rc_wc_cc_wc_T_hold"  \
                        "func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup"]
    
    set fp [open $csv_file r]
    set fd [read $fp]
    close $fp
    
    array unset res_arr
    
    foreach line [lrange [split $fd "\n"] 1 end] {
        
        set spline [split $line ","]
        lassign $spline block_name tag date wa stage is_lef is_lib is_spef is_spef is_netlist is_oas is_def
        
        if { $block_name == "" } { continue }
        
        exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy $block_name data from $wa with tag $tag at stage $stage:" >> $target_dir/MANIFEST.txt
        
        if { $stage == "merge" || $stage == "pt" } { set stage "chip_finish" } 
        puts "-I- Copying files for block $block_name"
        
        ### LEF ###
        if { ![info exists is_lef] || $is_lef!="false" } {
            set lef_path $wa/out/lef/${block_name}.${stage}.lef
            if { [file exists $lef_path] } { exec cp -fp $lef_path $target_dir/lefs/ ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy LEF from $lef_path" >> $target_dir/MANIFEST.txt } { puts "-W- File $lef_path not found" ; set res_arr($block_name:lef) true }
        }
        
        ### DEF ###
        if { ![info exists is_def] || $is_def!="false" } {
            set def_path $wa/out/def/${block_name}.${stage}.def.gz
            if { [file exists $def_path] } { exec cp -fp $def_path $target_dir/defs/ ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy DEF from $def_path" >> $target_dir/MANIFEST.txt } { puts "-W- File $def_path not found" ; set res_arr($block_name:def) true }
        }
        
        ### NETLIST ###
        if { ![info exists is_netlist] || $is_netlist!="false" } {
            set netlist_path $wa/out/db/${block_name}.${stage}.enc.dat/${block_name}.v.gz
            if { [file exists $netlist_path] } { exec cp -fp $netlist_path $target_dir/netlists/ ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy NETLIST from $netlist_path" >> $target_dir/MANIFEST.txt } { puts "-W- File $netlist_path not found" ; set res_arr($block_name:netlist) true }
        }
        
        if { $stage == "chip_finish" } {
            set db_path $wa/out/db/${block_name}.${stage}.enc.dat
            if { [file exists $db_path] } { exec cp -Lrfp $db_path $target_dir/dbs/ ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy DB from $db_path" >> $target_dir/MANIFEST.txt  } { puts "-W- File $db_path not found" ; set res_arr($block_name:db) true }            
        }
        
        ### LIB ###
        if { ![info exists is_lib] || $is_lib!="false" } {
#            if { $stage == "chip_finish" } { set lib_stage "route" } { set lib_stage $stage }            
            if { $stage == "chip_finish" } { 
                set tail       [lindex [split $wa "/"] end]
                set run ""
                regexp "pnr_(\[a-zA-Z0-9\\\._\]+)" $tail res run
                if { $run != "" } { set pt_area "pt_${run}" } { set pt_area "pt" }                
                foreach view $view_list {
                    set lib_path $wa/../$pt_area/out/lib/${block_name}_${view}.lib
                    set db_path $wa/../$pt_area/out/lib/${block_name}_${view}_lib.db
                    if { [file exists $lib_path] } { exec cp -fp $lib_path $target_dir/libs/ ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy LIB  from $lib_path" >> $target_dir/MANIFEST.txt  } { puts "-W- File $lib_path not found" ; set res_arr($block_name:lib:$view) true }
                    if { [file exists $db_path]  } { exec cp -fp $db_path $target_dir/libs/  ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy PTDB from $db_path" >> $target_dir/MANIFEST.txt  } { puts "-W- File $db_path not found" ; set res_arr($block_name:lib:$view) true }
                }
            } else {
                foreach view $view_list {
                    set lib_path $wa/out/lib/${block_name}.${stage}.${view}.lib.gz
                    if { [file exists $lib_path] } { exec cp -fp $lib_path $target_dir/libs/ ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy LIB  from $lib_path" >> $target_dir/MANIFEST.txt  } { puts "-W- File $lib_path not found" ; set res_arr($block_name:lib:$view) true }
                }
            }
        }
        
        ### SPEF ###
        if { ![info exists is_spef] || $is_spef!="false" } {
            if { $stage != "chip_finish" } {
                foreach view $view_list {
		            set mode [lindex [split $view "_"] 0]
		            set check [lindex [split $view "_"] end]
		            regsub "${mode}_(.*)_${check}" $view {\1} sub_pvt
		            regexp {(.*[SF])_(.*)} $sub_pvt match pvt rc
                    regexp "no_od_(.*)_LIBRARY" $sub_pvt res temp
                    set spef_path $wa/out/spef/${block_name}.${stage}.spef*${rc}_${temp}.gz
                    if { [file exists $spef_path] } { exec cp -fp $spef_path $target_dir/spefs/ ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy SPEF from $spef_path" >> $target_dir/MANIFEST.txt  } { puts "-W- File $spef_path not found" ; set res_arr($block_name:spef:${rc}_${temp}) true }
                }
            } else {
                set tail       [lindex [split $wa "/"] end]
                set run ""
                regexp "pnr_(\[a-zA-Z0-9\\\._\]+)" $tail res run
                if { $run != "" } { set starrc_area "starrc_${run}" } { set starrc_area "starrc" }
                if { [catch {set files [glob $wa/../$starrc_area/out/spef/*chip_finish*spef*]} res] } { puts "-W- File $file not found" ; set res_arr($block_name:spef:starrc) true ; continue }
                
                foreach file $files {
                    if { [regexp ".gz" $file res] } { 
                        if { [file exists $file] } { exec cp -fp $file $target_dir/spefs/ ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy SPEF from $file" >> $target_dir/MANIFEST.txt  } { puts "-W- File $file not found" ; set res_arr($block_name:spef:$file) true }
                    } else {
                        # prase spef file name and rename it
                        lassign [split [lindex [split $file "/"] end] "."] b s sp rct
                        if { [file exists $file] } { exec cp -fp $file $target_dir/spefs/${b}.${s}_${rct}.spef.gz ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy SPEF from $file" >> $target_dir/MANIFEST.txt  } { puts "-W- File $file not found" ; set res_arr($block_name:spef:${rc}_${temp}) true }
                    }
                }
            }
        }
        
        ### GPD ###
        if { ![info exists is_spef] || $is_spef!="false" } {
            set tail       [lindex [split $wa "/"] end]
            set run ""
            regexp "pnr_(\[a-zA-Z0-9\\\._\]+)" $tail res run
            if { $run != "" } { set starrc_area "starrc_${run}" } { set starrc_area "starrc" }
            set gpd_path $wa/../$starrc_area/out/gpd/${block_name}.${stage}.HIER.gpd
            if { ![file exists $gpd_path] } { puts "-W- File $gpd_path not found" ; set res_arr($block_name:gpd:starrc) true ; continue }
            exec cp -rfp $gpd_path $target_dir/gpds/ ; exec echo "-I- [clock format [clock seconds] -format "%d/%m/%Y %T"] - Copy GPD from $gpd_path" >> $target_dir/MANIFEST.txt 
        }
        
    }
    
    parray res_arr
#    parray res_arr > parse_csv_res.rpt
    
    return [array get res_arr]
    
}
puts [split $argv " "]
parse_blocks_csv [lindex $argv 0] [lindex $argv 1] [lindex $argv 2]

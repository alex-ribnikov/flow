proc be_trace_sourced_procs { } {
    
    if { ![info exists ::synopsys_program_name] && [get_db attributes root/proc_sources] == "" } {
        define_attribute proc_sources -category be_user_attributes -data_type string -obj_type root -skip_in_db -default ""          
    } elseif { [info exists ::synopsys_program_name] && ![info exists ::PROC_SOURCES] } {
        set ::PROC_SOURCES ""
    }
    
    proc recordDefinitionLocation {call code result op} {
        if {$code} return
        regexp "::(.*)" [uplevel 1 [list namespace which -command [lindex $call 1]]] res name
        set location [file normalize [uplevel 1 {info script}]]
        if { $location == "" } { set location "NA" }

        set proc_and_lock "$name,$location"
        redirect -app debug_proc_source { puts $proc_and_lock }
        
        if { ![info exists ::synopsys_program_name] } {
            set current_value  [get_db proc_sources]
        } else {
            set current_value  $::PROC_SOURCES
        }

        array set pnl_arr  [split $current_value ","]

        set pnl_arr($name) $location
        set new_value      [join [array get pnl_arr] ","]

        if { ![info exists ::synopsys_program_name] } {
            set_db -quiet proc_sources $new_value
        } else {
            set ::PROC_SOURCES $new_value
        }
    }
    
    if { ![regexp "recordDefinitionLocation" [join [trace info execution proc]] res]} {
        trace add execution proc leave recordDefinitionLocation
    }
}

proc be_cp_sourced_script {cmd args} {
#    puts "-D- DMC: $cmd"
#    puts "-D- ARG: $args"

    set cmd [regsub -all "\\-v|\\-e" $cmd ""]
    
	if {![file exists sourced_scripts/${::STAGE} ]} {exec mkdir -pv sourced_scripts/${::STAGE}}
    set file_realpath [lindex $cmd end]    
    if {![file exists $file_realpath ]} {
    	foreach arg [lrange [regexp -all -inline {\S+} $cmd] 1 end] {
        	if {[lindex $arg 0 ] != "-"} {
            set file_realpath $arg
            break
            }
        }
    } 
    set file [lindex [split $file_realpath "/"] end ]
    set dir ""    
    if {[regexp -all  {scripts\/} $file_realpath] } {                   set dir "/scripts"
    } elseif {[regexp -all  {\/inter\/} $file_realpath] } {             set dir "/inter"
    } elseif {[regexp -all  {\/scripts_local\/} $file_realpath] } {     set dir "/scripts_local"
    }
    
    if {[regexp {^/tools} $file_realpath]} {return}
    set dest "sourced_scripts/${::STAGE}${dir}"
    set cp_cmd  "exec cp -p $file_realpath $dest/$file"
   
    if { ![file exists $dest] } { exec mkdir -pv $dest }
    echo "-D-    $cp_cmd"
    if { $file_realpath=="" || [catch "$cp_cmd" res] } {
        puts "-E- Command: $cp_cmd Failed"
        puts $res
    }
    set start_t [clock seconds]
    set t_stamp [clock format $start_t -format "%d/%m/%y %H:%M:%S"]
    if { ![info exists ::be_sourced_files_list] } { set ::be_sourced_files_list {} }
    if {[lsearch -glob -exact $::be_sourced_files_list  [list [lindex $cmd end] $t_stamp] ] < 0} {
        set line [list [lindex $cmd end] $t_stamp] 
    	echo $line >> sourced_scripts/${::STAGE}_sourced_scripts.rpt
    	lappend ::be_sourced_files_list [list [lindex $cmd end] $t_stamp]
	}
    
}

proc get_proc_source { proc_name } {
    
    if { ![info exists ::synopsys_program_name] } {
        set current_value  [get_db proc_sources]
    } else {
        set current_value  $::PROC_SOURCES
    }
    
    array set pnl_arr  [split $current_value ","]
    
    if { [info exists pnl_arr($proc_name)] } {
        puts $pnl_arr($proc_name)
        return
    }
    
    puts "-E- Proc $proc_name source was not found"
}

proc init_be_scripts { {wb_setup false} } {

    if {[info exists ::STAGE] && $::STAGE != "open_block"} {
	  ## Trace definition of 'source' command for copying every sourced script.
	  if {[trace info execution source] == {} }  {trace add execution source enter be_cp_sourced_script}
	  ##
      set sc [info script]
      if {$sc != ""} {
          be_cp_sourced_script "$sc"
      }
    }
	history keep 2000
	set file_list {}


    set flow ""
    if { ![info exists ::synopsys_program_name] && [regexp "Genus" [get_db program_name]] } {  ; # Genus    
        set vendor cdn
        set flow GENUS
        set flow_name genus
    } elseif { ![info exists ::synopsys_program_name] && [regexp "Innovus" [get_db program_name]] } { 
        set vendor cdn
        set flow INN
        set flow_name innovus
    } elseif { ![info exists ::synopsys_program_name] && [regexp "Joules" [get_db program_name]] } { 
        set vendor cdn
        set flow JOULES
        set flow_name joules
    } elseif {  [info exists ::synopsys_program_name] && [regexp "dc_" $::synopsys_program_name] } {
        set vendor snps
        set flow DC
        set flow_name dc
    } elseif {  [info exists ::synopsys_program_name] && [regexp "pt_" $::synopsys_program_name] } {
        set vendor snps
        set flow PT
        set flow_name primetime
    } elseif {  [info exists ::synopsys_program_name] && [regexp "fc_" $::synopsys_program_name] } {
        set vendor snps
        set flow FC
        set flow_name FusionCompiler
    } elseif { ! [info exists ::synopsys_program_name] } {
        set vendor cdn
        set flow ""
        set flow_name ""
    } elseif {  [info exists ::synopsys_program_name] } {
        set vendor snps
        set flow ""
        set flow_name ""
    }
    
    # Define "root"
    set root ""

    if {       [file exists ./scripts/procs] } {
        set root [exec realpath ./scripts/procs ]
    } elseif { [info exists ::sh_launch_dir] && [file exists $::sh_launch_dir/scripts/procs] } {
        set root [exec realpath $::sh_launch_dir/scripts/procs ]
    } elseif { [info exists ::env(BEROOT)  ] } {
        set root $::env(BEROOT)/ns_flow/scripts/procs 
    }
    
    if { $root != "" } {
        puts "-I- scripts source is $root"
    } else {
        puts "-E- No be_scripts found (Error)" ;
    }
    
    ########################################
    # Trace sourced procs
    if { ![info exists ::synopsys_program_name] } {
        be_trace_sourced_procs
    }

    ########################################
    # Source WB inv/gns setup scripts
	if { $wb_setup } {
        global g_controls
        if { [info exists ::env(CONTROLS)] } {
            set g_controls  $::env(CONTROLS) 
        } else {
            set g_controls ""
        }
        set_interactive_constraint_modes func    
        puts "-I- Sourcing from CONTROLS: $g_controls"
        if { ![catch { set procs_file [glob $g_controls/${flow}.procs.tcl] } res ] }   { source $procs_file }        
        if { ![catch { set setup_file [glob $g_controls/${flow}.setup.paste] } res ] } { source $setup_file }                    
	}

    ########################################    
    # Source be_team user scripts
	set dir "$root/common"
	set file_list [glob -noc $dir/*tcl]
	
    # First source parseopt (if exists)
    set file $root/common/parseOpt.tcl
    if { [file exists $file] } { redirect /dev/null { source $file } }
    
	foreach file $file_list {
		puts "-I- Sourcing common scripts: $file"
        redirect -var error_info { if { [catch {source $file} res] } { set failed true } else { set failed false } }
        if { $failed } { puts "-E- Failed sourcing $file"; puts "-E- Error Info:" ; puts $error_info ; puts $res }
	}
    
	set dir "$root/common_${vendor}"
	set file_list [glob -noc $dir/*tcl]

	foreach file $file_list {
		puts "-I- Sourcing common scripts: $file"
        redirect -var error_info { if { [catch {source $file} res] } { set failed true } else { set failed false } }
        if { $failed } { puts "-E- Failed sourcing $file"; puts "-E- Error Info:" ; puts $error_info ; puts $res }
	}
    
    
	set file_list {}
    if { $flow=="GENUS" } {  ; # Genus
		set dir "$root/genus"
        if { [catch { set file_list [glob $dir/*tcl] } res ] } { return }
	    foreach file $file_list {
    		puts "-I- Sourcing Genus scripts: $file"    
            redirect -var error_info { if { [catch {source $file} res] } { set failed true } else { set failed false } }
            if { $failed } { puts "-E- Failed sourcing $file"; puts "-E- Error Info:" ; puts $error_info ; puts $res }
	    }
    } elseif { $flow=="INN" } { 
	    # Innovus
		set dir "$root/innovus"
		if { [catch { set file_list [glob $dir/*tcl] } res ] } { return }
	    foreach file $file_list {
    		puts "-I- Sourcing Innovus scripts: $file"    
            redirect -var error_info { if { [catch {source $file} res] } { set failed true } else { set failed false } }
            if { $failed } { puts "-E- Failed sourcing $file"; puts "-E- Error Info:" ; puts $error_info ; puts $res }
	    }    
    } elseif { $flow=="DC" } { 
	    # Design Compiler
		set dir "$root/dc"
		if { [catch { set file_list [glob $dir/*tcl] } res ] } { return }
	    foreach file $file_list {
    		puts "-I- Sourcing DC scripts: $file"    
            redirect -var error_info { if { [catch {source $file} res] } { set failed true } else { set failed false } }
            if { $failed } { puts "-E- Failed sourcing $file"; puts "-E- Error Info:" ; puts $error_info ; puts $res }
	    }    
    } elseif { $flow=="FC" } { 
	# Fusion Compiler
	set dir "$root/fc_shell"	
	if { [catch { set file_list [glob $dir/*tcl] } res ] } { return }
	    foreach file $file_list {
    		puts "-I- Sourcing DC scripts: $file"    
            	redirect -var error_info { if { [catch {source $file} res] } { set failed true } else { set failed false } }
            	if { $failed } { puts "-E- Failed sourcing $file"; puts "-E- Error Info:" ; puts $error_info ; puts $res }
	    }    
    } elseif { $flow=="PT" } { 
	    # PrimeTme
		set dir "$root/pt_shell"
		if { [catch { set file_list [glob $dir/*tcl] } res ] } { return }
	    foreach file $file_list {
    		puts "-I- Sourcing PT scripts: $file"    
            redirect -var error_info { if { [catch {source $file} res] } { set failed true } else { set failed false } }
            if { $failed } { puts "-E- Failed sourcing $file"; puts "-E- Error Info:" ; puts $error_info ; puts $res }
	    }    
    }
    
    ########################################
    # Define some user defined attribute
    if { [info exists ::env(WORK)] } { set work $::env(WORK) } else { set work [pwd] }

    if { [file exists ./reports] && [file exists ./out] } {
        set user_reports   [exec realpath ./reports]
        set user_outputs   [exec realpath ./out]
    } else {
        set user_reports   $work/$flow_name/reports
        set user_outputs   $work/$flow_name/out
    	
        if { ![file exists $work/$flow_name/reports]   } { exec mkdir -p $user_reports } 
     	if { ![file exists $work/$flow_name/out]       } { exec mkdir -p $user_outputs }         
    }
    
    if { ![info exists ::synopsys_program_name] } {
        if { [get_db attributes user_reports_dir] == "" } {
            puts "-I- Setting user_reports_dir: $user_reports"
            define_attribute user_reports_dir       -category be_user_attributes -data_type out_dir  -obj_type root -default "$user_reports" -skip_in_db
            define_attribute user_outputs_dir       -category be_user_attributes -data_type out_dir  -obj_type root -default "$user_outputs" -skip_in_db    
        } else {
            puts "-I- user_reports_dir: [get_db attributes user_reports_dir]"    
        }

        if { ![is_attribute user_stage_reports_dir -obj_type root] } { define_attribute user_stage_reports_dir -category be_user_attributes -data_type out_dir  -obj_type root -default "$user_reports" -skip_in_db  }

        if { [get_db attributes be_stage] == "" } {
            # Define be_stage att 
            define_attribute be_stage -category be_user_attributes -data_type string  -obj_type root -default "NOSTAGE" 
        }
    }
        
}
init_be_scripts

proc dft_files_generator {} {
	global DESIGN_NAME
	global sdc_files
	# directory creation
	set root [split [pwd] /]
	set version [lindex $root end-1] 
	set block_name [lindex $root end-2] 
	set dir_name [string cat $block_name "." $version ".dft_files"]
	if {![file exists $dir_name]} {exec mkdir $dir_name}
	
	# README
	echo "[pwd]" > $dir_name/README
	
	# compile netlist
	if {![file exists out/netlist/$block_name.compile.v.gz]} {
		puts "no compile netlist found!"
		return
	} else {
		set fl [exec realpath out/netlist/$block_name.compile.v.gz ]
		exec cp out/netlist/$block_name.compile.v.gz $dir_name
	} 
	
	if {[file exists out/netlist/$block_name.compile_hier.v.gz]} {
		set fl_hier [exec realpath out/netlist/$block_name.compile_hier.v.gz ]
		exec cp out/netlist/$block_name.compile_hier.v.gz $dir_name
	} 
	# sdc file
	if { $sdc_files(func) == "" } {
		puts "no sdc file found!"
		return
	} else {
		set sdc_path [list]
		foreach fff $sdc_files(func) { 
			file copy -force $fff $dir_name 
			lappend sdc_path [file normalize $fff]
		}
	} 
	
	# clocks
	if {[file exists $dir_name/clock.report]} {exec rm $dir_name/clock.report}
	foreach_in_collection clk [get_clocks -filter {!is_virtual&&defined(period)}] {
		set period [get_attribute $clk period]
		set frequency [expr 1/$period]
		echo "[format "%-14s" [get_attribute $clk sources.name]] [format "%-7s" [get_attribute $clk sources.direction]put ] [format "%.2f" ${frequency}]GHz" >> $dir_name/clock.report
	}
	
	# MCPs
	report_exceptions >  $dir_name/exceptions.rpt
	# -from , port_type==signal etc.
	set fi [open $dir_name/exceptions.rpt r]
	set con [read $fi]
	close $fi
	set lines [lrange [split $con "\n"] 7 end-2]
	set newlist [lmap elem $lines {regsub {#.*} $elem ""}]
	#set newlist [lmap elem $newlist {regsub {set_false_path.*} $elem ""}]
	set newlist [lmap elem $newlist {regsub {set_path_margin.*} $elem ""}]
	set filtered_list [lsearch -all -inline -not $newlist ""]
	set mcp_data [join $filtered_list "\n"]
	#set mcp_data [join $lines "\n"]
	echo $mcp_data >  $dir_name/MCP_ON_DATA.report
	exec rm $dir_name/exceptions.rpt
	
	# Memories
	echo "[sizeof [get_cells -hierarchical -filter is_hard_macro]] Memory\n" > $dir_name/memory_configuration.report
	be_report_macro_count > $dir_name/report_macro_count.rpt
	set fi [open  $dir_name/report_macro_count.rpt r]
	set con [read $fi]
	close $fi
	set lines [split $con "\n"]
	# removing report header
	set data [lrange $lines [lsearch $lines "Type*"] end]
	echo [join $data "\n"] >> $dir_name/memory_configuration.report
	exec rm $dir_name/report_macro_count.rpt
	
	# memory_grouping_BSI_memory
	memory_grouping_BSI $dir_name/memory_grouping_BSI_memory
	
	# summary file
	echo "1. critical FF with AON clock source" > $dir_name/dft.report
	if {[sizeof_collection [get_flat_cells -quiet *bcg*aon* ]] > 0 } {
		echo [join [get_object_name [all_fanout -from [get_pins -of [get_flat_cells *bcg*aon*]] -only_cells -endpoints_only]] "\n" ] >> $dir_name/dft.report
	}
	echo "\n" >> $dir_name/dft.report
	echo "2. memory configuration and number of instance\n" >> $dir_name/dft.report
	echo "[sizeof [get_cells -hierarchical -filter is_hard_macro]] Macros\n" >> $dir_name/dft.report
	set my_macro_cells [get_cells -quiet -hier -filter design_type==macro]
	if {[info exists macro_count]} {unset macro_count}
	if {[info exists macro_names]} {unset macro_names}
	foreach_in_collection macro_ $my_macro_cells {
		set ref_name [get_attribute $macro_ ref_name]
		incr macro_count($ref_name)
		lappend macro_names($ref_name) [get_attribute $macro_ full_name]
	}
	foreach ref_name [lsort [array names macro_names]] {
		echo "$ref_name X $macro_count($ref_name)" >> $dir_name/dft.report
		echo [join [lsort -u $macro_names($ref_name)] "\n"] >> $dir_name/dft.report
		echo "\n" >> $dir_name/dft.report
	}
	echo "\n" >> $dir_name/dft.report
	echo "3. clock input clock output + frequencies  (<clock port> <direction> <cycle time>)" >> $dir_name/dft.report
	foreach_in_collection clk [get_clocks -filter {!is_virtual&&defined(period)}] {
		set period [get_attribute $clk period]
		set frequency [expr 1/$period]
		echo "# [get_attribute $clk sources.name] [format "%.2f" ${frequency}]GHz" >> $dir_name/dft.report
		echo "[format "%-14s" [get_attribute $clk sources.name]] [format "%-7s" [get_attribute $clk sources.direction]put ] $period" >> $dir_name/dft.report
	}
	echo "\n" >> $dir_name/dft.report
	echo "4. reset port" >> $dir_name/dft.report
	echo "[join [get_object_name [get_ports *_rst*]] "\n" ]" >> $dir_name/dft.report
	echo "\n" >> $dir_name/dft.report
	echo "5. memory grouping for BSI memory. like the snapshot below.
	one type of memory per controller.
	same freq per controller
	12Mb or less per controller" >> $dir_name/dft.report
	set fi [open $dir_name/memory_grouping_BSI_memory.rpt r]
	set con [read $fi]
	close $fi
	echo "\n$con" >> $dir_name/dft.report
	echo "\n" >> $dir_name/dft.report
	echo "6. ports need to be excluded from wrapper  (analog )" >> $dir_name/dft.report
	echo "\n" >> $dir_name/dft.report
	echo "7. enable net for isolation cell (critical / none critical)" >> $dir_name/dft.report
	echo "\n" >> $dir_name/dft.report
	echo "8. MCP complex gate list or naming convention" >> $dir_name/dft.report
	#echo $mcp_data >> $dir_name/dft.report
	echo "\n" >> $dir_name/dft.report
	echo "9. netlist" >> $dir_name/dft.report
	echo "$fl" >> $dir_name/dft.report
	if {[info exists fl_hier]} {
		echo "9.1 hier netlist" >> $dir_name/dft.report
		echo "$fl_hier" >> $dir_name/dft.report
	}
	echo "\n" >> $dir_name/dft.report
	echo "10. sdc file" >> $dir_name/dft.report
	echo "$sdc_path"  >> $dir_name/dft.report
	
}
	

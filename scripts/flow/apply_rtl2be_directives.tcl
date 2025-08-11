proc apply_rtl2be_directives {} {
  global nextinside_path
  set block_name [get_db designs .name]
  set dont_touch_list_file      $nextinside_path/auto_gen/rtl2be/$block_name/${block_name}_nxt_info_dont_touch.txt
  set dont_touch_err_file       nxt_info_dont_touch.err
  set dont_touch_gen_file       ${block_name}_dont_touch.tcl
  set size_only_list_file       $nextinside_path/auto_gen/rtl2be/$block_name/${block_name}_nxt_info_size_only.txt
  set size_only_gen_file        ${block_name}_resize_only.tcl
  set size_only_err_file        nxt_info_size_only.err
  set dont_scan_list_file       $nextinside_path/auto_gen/rtl2be/$block_name/${block_name}_nxt_non_scan_hierarchy.txt
  set dont_scan_err_file        nxt_non_scan_hierarchy.err
  set dont_scan_gen_file        ${block_name}_dont_scan.tcl
  set dft_tbc_buf_list_file     $nextinside_path/auto_gen/rtl2be/$block_name/${block_name}_nxt_dft_tbc_buf.txt
  set dft_tbc_buf_gen_file      ${block_name}_dft_tbc_buf.tcl
  set dft_tbc_buf_err_file      nxt_dft_tbc_buf.err
  set dft_tbc_clk_buf_list_file $nextinside_path/auto_gen/rtl2be/$block_name/${block_name}_nxt_dft_tbc_clk_buf.txt
  set dft_tbc_clk_buf_gen_file  ${block_name}_dft_tbc_clk_buf.tcl
  set dft_tbc_clk_buf_err_file  nxt_dft_tbc_clk_buf.err
  set soft_guide_list_file      $nextinside_path/auto_gen/rtl2be/$block_name/${block_name}_relative_placement_directive.txt
  set soft_guide_err_file       relative_placement_directive.err
  set soft_guide_gen_file       ${block_name}_soft_guide.tcl

  if {[file exists $dont_touch_list_file]} {
    puts "Parsing $dont_touch_list_file ..."
    start_time
    set file_r [open $dont_touch_list_file r]
    set file_w1 [open $dont_touch_gen_file w]
    set file_w2 [open $dont_touch_err_file w]
    puts $file_w1 "# Generated dont_touch commmands on existing instances"
    puts $file_w1 "# from file: $dont_touch_list_file"
    puts $file_w2 "# Source file: $dont_touch_list_file"
    puts $file_w2 "# Can't find the following instances in the design:"

    while {[gets $file_r line]>=0} {
      regsub {\.info\[0\]} $line {} inst_name
      set inst_name [string map { . * [ * ] * / * } $inst_name]
      regsub {\*$} $inst_name {\]} inst_name
      set inst_dpo  [get_db insts $inst_name]
      
      if {$inst_dpo ne ""} {
        foreach _inst $inst_dpo {
          set_db $_inst .dont_touch true
	  if {[regexp {i_clk_gate$} $_inst]} {
            puts $file_w1 "set_db \[get_db insts ${_inst}*\] .dont_touch true"
	  } else {
            puts $file_w1 "set_db $_inst .dont_touch true"
	  }
	}
      } else {
          puts $file_w2 "  $inst_name"
      }
    }
    close $file_r
    close $file_w1
    close $file_w2
    puts "Parsed $dont_touch_list_file in [elapsed_time]."
  }

  if {[file exists $size_only_list_file]} {
    puts "Parsing $size_only_list_file ..."
    start_time
    set file_r [open $size_only_list_file r]
    set file_w1 [open $size_only_gen_file w]
    set file_w2 [open $size_only_err_file w]
    puts $file_w1 "# Generated resize_only commmands on existing instances"
    puts $file_w1 "# from file: $size_only_list_file"
    puts $file_w2 "# Source file: $size_only_list_file"
    puts $file_w2 "# Can't find the following instances in the design:"

    while {[gets $file_r line]>=0} {
      regsub {\.info\[0\]} $line {} inst_name
      set inst_name [string map { . * [ * ] * / * } $inst_name]
      regsub {\*$} $inst_name {\]} inst_name
      set inst_dpo  [get_db insts $inst_name]
      
      if {$inst_dpo ne ""} {
        foreach _inst $inst_dpo {
          set_db $_inst .dont_touch size_ok
	  if {[regexp {i_clk_gate$} $_inst]} {
            puts $file_w1 "set_db \[get_db insts ${_inst}*\] .dont_touch size_ok"
	  } else {
            puts $file_w1 "set_db $_inst .dont_touch size_ok"
	  }
	}
      } else {
          puts $file_w2 "  $inst_name"
      }
    } 
    close $file_r
    close $file_w1
    close $file_w2
    puts "Parsed $size_only_list_file in [elapsed_time]."
  }

  if {[file exists $dont_scan_list_file]} {
    puts "Parsing $dont_scan_list_file ..."
    start_time
    set file_r [open $dont_scan_list_file r]
    set file_w1 [open $dont_scan_gen_file w]
    set file_w2 [open $dont_scan_err_file w]
    puts $file_w1 "# Generated dont_scan commmands on existing modules"
    puts $file_w1 "# from file: $dont_scan_list_file"
    puts $file_w2 "# Source file: $dont_scan_list_file"
    puts $file_w2 "# Can't find the following modules in the design:"

    while {[gets $file_r line]>=0} {
      regsub {\.info\[0\]} $line {} hinst_name
      set hinst_name [string map { . * [ * ] * / * } $hinst_name]
      regsub {\*$} $hinst_name {\]} hinst_name
      set hinst_dpo  [get_db hinsts $hinst_name]
      
      if {$hinst_dpo ne ""} {
        foreach _hinst $hinst_dpo {
          set_db $_hinst .dft_dont_scan true
          puts $file_w1 "set_db $_hinst .dft_dont_scan true"
	}
      } else {
          puts $file_w2 "  $hinst_name"
      }
    } 
    close $file_r
    close $file_w1
    close $file_w2
    puts "Parsed $dont_scan_list_file in [elapsed_time]."
  }
  if {[file exists $dft_tbc_buf_list_file]} {
    puts "Parsing $dft_tbc_buf_list_file ..."
    start_time
    set file_r [open $dft_tbc_buf_list_file r]
    set file_w1 [open $dft_tbc_buf_gen_file w]
    set file_w2 [open $dft_tbc_buf_err_file w]
    puts $file_w1 "# Generated resize_only commmands on existing DFT buffer instances"
    puts $file_w1 "# from file: $dft_tbc_buf_list_file"
    puts $file_w2 "# Source file: $dft_tbc_buf_list_file"
    puts $file_w2 "# Can't find the following DFT buffer instances in the design:"

    while {[gets $file_r line]>=0} {
      regsub {\.info\[0\]} $line {} inst_name
      set inst_name [string map { . * [ * ] * / * } $inst_name]
      regsub {i_dft_buf$} $inst_name {i_dft_buf\[*\]} inst_name
      set inst_dpo  [get_db insts $inst_name]
      
      if {$inst_dpo ne ""} {
        foreach _inst $inst_dpo {
          set_db $_inst .dont_touch size_ok
          puts $file_w1 "set_db $_inst .dont_touch size_ok"
	}
      } else {
          puts $file_w2 "  $inst_name"
      }
    } 
    close $file_r
    close $file_w1
    close $file_w2
    puts "Parsed $dft_tbc_buf_list_file in [elapsed_time]."
  }
  if {[file exists $dft_tbc_clk_buf_list_file]} {
    puts "Parsing $dft_tbc_clk_buf_list_file ..."
    start_time
    set file_r [open $dft_tbc_clk_buf_list_file r]
    set file_w1 [open $dft_tbc_clk_buf_gen_file w]
    set file_w2 [open $dft_tbc_clk_buf_err_file w]
    puts $file_w1 "# Generated resize_only commmands on existing DFT clock buffer instances"
    puts $file_w1 "# from file: $dft_tbc_clk_buf_list_file"
    puts $file_w2 "# Source file: $dft_tbc_clk_buf_list_file"
    puts $file_w2 "# Can't find the following DFT clock buffer instances in the design:"

    while {[gets $file_r line]>=0} {
      regsub {\.info\[0\]} $line {} inst_name
      set inst_name [string map { . * [ * ] * / * } $inst_name]
      regsub {i_dft_clk_buf$} $inst_name {i_dft_clk_buf\[*\]} inst_name
      set inst_dpo  [get_db insts $inst_name]
      
      if {$inst_dpo ne ""} {
        foreach _inst $inst_dpo {
          set_db $_inst .dont_touch size_ok
          puts $file_w1 "set_db $_inst .dont_touch size_ok"
	}
      } else {
          puts $file_w2 "  $inst_name"
      }
    } 
    close $file_r
    close $file_w1
    close $file_w2
    puts "Parsed $dft_tbc_clk_buf_list_file in [elapsed_time]."
  }
  if {[file exists $soft_guide_list_file]} {
    puts "Parsing $soft_guide_list_file ..."
    start_time
    set file_r [open $soft_guide_list_file r]
    set file_w1 [open $soft_guide_gen_file w]
    set file_w2 [open $soft_guide_err_file w]
    puts $file_w1 "# Generated soft_guide commmands on existing modules"
    puts $file_w1 "# from file: $soft_guide_list_file"
    puts $file_w2 "# Source file: $soft_guide_list_file"
    puts $file_w2 "# Can't find the following modules in the design:"

    while {[gets $file_r line]>=0} {
      regsub {\.info\[0\]} $line {} hinst_name
      set hinst_name [string map { . * [ * ] * / * } $hinst_name]
      regsub {\*$} $hinst_name {\]} hinst_name
      set hinst_dpo  [get_db hinsts $hinst_name]
      
      if {$hinst_dpo ne ""} {
        foreach _hinst $hinst_dpo {
          if {[get_db program_short_name] != "genus"} {
            create_boundary_constraint -hinst $_hinst -type cluster
          }
	  puts $file_w1 "create_boundary_constraint -hinst $_hinst -type cluster"
	}
      } else {
          puts $file_w2 "  $hinst_name"
      }
    } 
    close $file_r
    close $file_w1
    close $file_w2
    puts "Parsed $soft_guide_list_file in [elapsed_time]."
  }

}

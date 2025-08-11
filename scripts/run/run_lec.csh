#!/bin/tcsh -fe

source /tools/common/pkgs/modules/current/init/tcsh


#   Flag             Default   Description                                                                                
#   --------------------------------------------------------------------------------------------------------------------
# -design_name             <>            'MUST - partition/block name';\
# -project                 <>            'MUST - nxt008 / nxt007 etc.';\
# -lec_mode                <>            'Options:  $lec_modes';\
# -cpu                     4             'Number of cpus per run. (default 8)';\
# -interactive             false         'Do not exit when done';\
# -syn_dir      		 <>            'Default - syn folder to start from. \-BSS\-Default is syn_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
# -innovus_dir             <>            'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
# -golden_netlist          <>            'Defaults: filelist , syn_map   , syn_opt   , place';\
# -revised_netlist         <>            'Defaults: syn_map  , syn_opt   , place     , pnr_final';\
# -disable_scan            false         'will disable dft signals from golden and revised';\
# -dofile                  <>            'point to outside do file ';\
# -use_tool_dofile         false         'work for rtl2map,map2syn,dft2place only, will take dofile script from genus/innovus output';\
# -sdc_list                <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
# -eco_num 	         <> 	       'eco number';\
# -restore                 false         'restore previous session';\
# -other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool';\
# -local                   false         'If true run  do_fm  from scripts_local folder.';\
# -scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
# -help                    false         'Prints help for the relevant tool' ;\


#-----------------------------------
# Run
#-----------------------------------
#set SYN_DIR = `echo $PWD | perl -pe 's/lec/syn/'`
#set INNOVUS_DIR = `echo $PWD | perl -pe 's/lec/pnr/'`

#-----------------------------------
# Parsing flags
#-----------------------------------
source ./scripts/bin/parse_args.csh lec $argv 

if ( $is_exit  == "true" ) then
    exit 2
endif


#-----------------------------------
# nextk8s run 
#-----------------------------------
echo "k8s: $k8s"
if ($k8s == "true" ) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh lec $argv 
   exit 0
endif
###
###
###echo "k8s: $k8s"
###if ($k8s == "true" ) then
###   set PROFILER = "NONE"
###   if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###   if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###   if ($PROFILER != "NONE") then
###      echo "k8s profiler: $PROFILER"
###      if (`grep lec ../inter/k8s_profiler | wc -l` == 0) then
###          echo "Warning: missing lec stage for k8s_profiler. adding default values cpu $cpu , memory $memory"
###          echo "lec $cpu $memory" >> ../inter/k8s_profiler
###      endif
###      set memory = `cat $PROFILER | perl -pe 's/#.*//' | grep lec | awk '{print $NF}'`
###      set cpu = `cat $PROFILER | perl -pe 's/#.*//' | grep lec | awk '{print $(NF-1)}'`
###      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.3; $1*1.3==int($1*1.3) ? x=$1*1.3 : x=int($1*1.3)+1 ; printf x"\n" }'`
###   else
###      set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
###      set K8S_CPU = `echo $cpu | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
###      set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.3; $1*1.3==int($1*1.3) ? x=$1*1.3 : x=int($1*1.3)+1 ; printf x"\n" }'`
###   endif
###   echo "K8S_CPU $K8S_CPU limit $cpu"
###   echo "K8S_MEM $K8S_MEM limit $K8S_MEM_LIMIT"
###
###
###   set AAA = `echo $argv | perl -pe 's/-k8s//;s/-desc \S+//;s/-tail//;s/-vnc_server \S+//;s/-vnc_display \S+//;s/-win//;'`
###   set AAA = "$AAA -k8s false"
###   if ($desc == "None") then
###      set desc = `echo $PWD | awk -F'/' '{print $NF}' | cut -c1-20 | tr "[:upper:]" "[:lower:]"`
###   else
###      set desc = `echo $desc | tr "[:upper:]" "[:lower:]"`
###   endif
###   echo "k8s:  $k8s"
###   echo "desc: $desc"
###   echo "argv: $argv"
###   echo "AAA:  $AAA"
###      
###   set COMMAND = "./scripts/run/run_lec.csh $AAA"
###   echo $COMMAND
###   if ($win == "true" || $interactive == "true" || $restore == "true") then
###       if ($vnc_display == "None" || $vnc_server == "None") then
###           echo "ERROR: missing vnc_display or vnc_server"
###	   exit 1
###       endif
###       if ( $?NXT080) then
###           if ( $NXT080 == "true") then
###               set terminal = "setenv NXT080 true && $terminal"
###           endif
###       endif
###       set cmd = "nextk8s run -command '$terminal -e "\""$COMMAND"\""' -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc $desc -memory $K8S_MEM -memory-limit $K8S_MEM_LIMIT -x-display-num $vnc_display -vnc-server $vnc_server"
###   else
###       set cmd = "nextk8s run -command '$COMMAND' -x-server -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc $desc -memory $K8S_MEM -memory-limit $K8S_MEM_LIMIT"
###       if ($tail == "true") then
###          set cmd = "$cmd -tail"
###       endif
###   endif
###   
###   
###   echo $cmd
###   eval $cmd
###   exit
###endif



#-----------------------------------
# Load modules 
#-----------------------------------
#module clear -f
#module unload cdnc/confrml/19.20.100
module unload cdnc/confrml
if ($tool_version != "None") then
    if (`(module avail cdnc/confrml/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: Conformal version $tool_version"
	module load cdnc/confrml/$tool_version
    else 
        echo "Info: Conformal version "
        module load cdnc/confrml/22.20.200
    endif
    if (`(module avail cdnc/innovus/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: innovus version $tool_version"
	module load cdnc/innovus/$tool_version
    else 
        echo "Info: innovus version 22.14.000"
        module load cdnc/innovus/22.14.000
    endif
    if (`(module avail cdnc/genus/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: genus version $tool_version"
	module load cdnc/genus/$tool_version
    else 
        echo "Info: genus version 22.14.000"
        module load cdnc/genus/22.14.000
    endif
else
    module load cdnc/confrml/22.20.200 cdnc/genus/22.14.000
endif


#-----------------------------------
# running scripts 
#-----------------------------------
if ( $local == "false") then
   set DO_FILE = ../scripts/do_lec.do
else
   set DO_FILE = ../scripts_local/do_lec.do
endif


#-----------------------------------
# mkdir
#-----------------------------------
echo "-I- mode : $lec_mode"

mkdir -pv $lec_mode
mv .tmp_user_inputs.tcl ${lec_mode}/user_inputs.tcl
cd $lec_mode
if (! -d scripts) then
    ln -s ../scripts
endif
if ($use_tool_dofile == "true") then
   mkdir -pv scripts_local
   if ($lec_mode == "rtl2syn") then
       if ($dofile == "None") then
            set DO_FILE = scripts_local/lec.rtl2Syn.do
            echo $syn_dir/out/fv/lec.rtl2Syn.do
            \cp -p $syn_dir/out/fv/lec.rtl2Syn.do scripts_local/.
       else
	    set dofile_real = `realpath $dofile`
            \cp -p $dofile_real scripts_local/.
	    set DO_FILE = scripts_local/`basename $dofile_real`
       endif
       set cmd = "perl -p -i -e 's#out/fv/#$syn_dir/out/fv/#'  $DO_FILE"
       eval $cmd
       perl -p -i -e 's#../inter#../../inter#' $DO_FILE
       perl -p -i -e 's#^(report\S+) (.*)#\1 \2 > reports/\1.rpt#' $DO_FILE
       perl -p -i -e 's#^(report\S+)$#\1 > reports/\1.rpt#' $DO_FILE
       perl -p -i -e 's#(reports/report_verification\.rpt)#\1\nexec cat \1#' $DO_FILE
       if ($golden_netlist != "None") then
	  echo "using golden netlist : $golden_netlist"
	  perl -p -i -e 's#(read_design.*golden.*\s)\S+$#\1 qawsedrftg#' $DO_FILE
	  perl -p -i -e "s#qawsedrftg#$golden_netlist#" $DO_FILE
       endif
       if ($revised_netlist != "None") then
	  echo "using revised netlist : $revised_netlist"
	  perl -p -i -e 's#(read_design.*revised.*\s)\S+$#\1 qawsedrftg#' $DO_FILE
	  perl -p -i -e "s#qawsedrftg#$revised_netlist#" $DO_FILE
       endif
   else if ($lec_mode == "rtl2map") then
        if ($dofile == "None") then
   	    echo $syn_dir/out/fv/lec.rtl2map.do
            \cp -p $syn_dir/out/fv/lec.rtl2map.do scripts_local/.
	    set DO_FILE = scripts_local/lec.rtl2map.do
	else
	    set dofile_real = `realpath $dofile`
            \cp -p $dofile_real scripts_local/.
	    set DO_FILE = scripts_local/`basename $dofile_real`
	endif
	if ($project == "inext") then
	    set cmd = "perl -p -i -e 's#fv/${design_name}#$syn_dir/genus_fv/${design_name}#'  $DO_FILE"
	    eval $cmd
	    set cmd = "perl -p -i -e 's# ./filelist# $syn_dir/filelist#'  $DO_FILE"
	    eval $cmd
	else
	    set cmd = "perl -p -i -e 's#out/fv#$syn_dir/out/fv#'  $DO_FILE"
	    eval $cmd
	    set cmd = "perl -p -i -e 's# ./filelist# $syn_dir/filelist#'  $DO_FILE"
	    eval $cmd
	endif
	
	perl -p -i -e 's/set_log_file/#set_log_file/' $DO_FILE
	perl -p -i -e 's#(set logfile)\s+\S+#\1 log/lec.log#' $DO_FILE
	
	perl -p -i -e 's#../inter#../../inter#' $DO_FILE
	perl -p -i -e 's#^(\s*)(report\S+)(\s*)(.*) > .*#\1\2\3\4#' $DO_FILE
	perl -p -i -e 's#^(\s*)(report\S+)$#\1\2 > reports/\2.rpt#' $DO_FILE
	perl -p -i -e 's#^(\s*)(report\S+) -(\S+)$#\1\2 -\3 > reports/\2.\3.rpt#' $DO_FILE
	perl -p -i -e 's#^(\s*)(report\S+) -(\S+) -(\S+)$#\1\2 -\3 -\4 > reports/\2.\3.\4.rpt#' $DO_FILE
	
	# dont stop on error when saving design
	perl -p -i -e 's/(checkpoint.*)/set_dofile_abort off\n\1\nset_dofile_abort on\n/' $DO_FILE

#	perl -p -i -e 's#^(report\S+) (.*)#\1 \2 > reports/\1.rpt#' $DO_FILE
#	perl -p -i -e 's#(reports/report_verification\.rpt)#\1\nexec cat \1#' $DO_FILE
	perl -p -i -e 's#(write_hier_compare_dofile.*)\\#\1 -threshold 10000 \\#' $DO_FILE
	perl -p -i -e 's/vpxmode/#vpxmode/' $DO_FILE
# 11/01/2024 Roy: why do we need this ?
#	sed -i '/add_renaming_rule/a \\nset _f "scripts_local/lec.rtl2map.pre_write_hier_compare.tcl"\nif \{\[file exists \$_f\]\} \{ source -v -e \$_f \}' $DO_FILE

   	if ($golden_netlist != "None") then
   	   echo "using golden netlist : $golden_netlist"
   	   perl -p -i -e 's#(read_design.*golden.*\s)\S+filelist$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$golden_netlist#" $DO_FILE
   	endif
   	if ($revised_netlist != "None") then
   	   echo "using revised netlist : $revised_netlist"
   	   perl -p -i -e 's#(read_design.*revised.*\s)\S+$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$revised_netlist#" $DO_FILE
   	endif
   else if ($lec_mode == "map2syn") then
        if ($dofile == "None") then
	    set DO_FILE = scripts_local/lec.map2Syn.do
   	    echo $syn_dir/out/fv/lec.map2Syn.do
            \cp -p $syn_dir/out/fv/lec.map2Syn.do scripts_local/.
	else
	    set dofile_real = `realpath $dofile`
            \cp -p $dofile_real scripts_local/.
	    set DO_FILE = scripts_local/`basename $dofile_real`
	endif
	set cmd = "perl -p -i -e 's#out/fv#$syn_dir/out/fv#'  $DO_FILE"
	echo $cmd
	eval $cmd
	
	perl -p -i -e 's/set_log_file/#set_log_file/' $DO_FILE
	perl -p -i -e 's#(set logfile)\s+\S+#\1 log/lec.log#' $DO_FILE
	
	perl -p -i -e 's#../inter#../../inter#' $DO_FILE
	perl -p -i -e 's#^(\s*)(report\S+)(\s*)(.*) > .*#\1\2\3\4#' $DO_FILE
	perl -p -i -e 's#^(\s*)(report\S+)$#\1\2 > reports/\2.rpt#' $DO_FILE
	perl -p -i -e 's#^(\s*)(report\S+) -(\S+)$#\1\2 -\3 > reports/\2.\3.rpt#' $DO_FILE
	perl -p -i -e 's#^(\s*)(report\S+) -(\S+) -(\S+)$#\1\2 -\3 -\4 > reports/\2.\3.\4.rpt#' $DO_FILE
	perl -p -i -e 's#^(\s*)(report\S+) -(\S+) (\S+) -(\S+) (\S+) -(\S+) (\S+)$#\1\2 -\3 \4 -\5 \6 -\7 \8 > reports/\2.\4.\6.\8.rpt#' $DO_FILE

# dont stop on error when saving design
	perl -p -i -e 's/(checkpoint.*)/set_dofile_abort off\n\1\nset_dofile_abort on\n/' $DO_FILE

#	perl -p -i -e 's/(report.*) > \S+/\1/' $DO_FILE
#	perl -p -i -e 's#^(report\S+) (.*)#\1 \2 > reports/\1.rpt#' $DO_FILE
#	perl -p -i -e 's#^(report\S+)$#\1 > reports/\1.rpt#' $DO_FILE
#	perl -p -i -e 's#(reports/report_verification\.rpt)#\1\nexec cat \1#' $DO_FILE
	perl -p -i -e 's/vpxmode/#vpxmode/' $DO_FILE
   	if ($golden_netlist != "None") then
   	   echo "using golden netlist : $golden_netlist"
   	   perl -p -i -e 's#(read_design.*golden.*\s)\S+$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$golden_netlist#" $DO_FILE
   	endif
   	if ($revised_netlist != "None") then
   	   echo "using revised netlist : $revised_netlist"
   	   perl -p -i -e 's#(read_design.*revised.*\s)\S+$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$revised_netlist#" $DO_FILE
	else
   	   set cmd = "perl -p -i -e 's#(read_design.*revised.*\s)(\S+)#\1 ${syn_dir}/\2#' $DO_FILE"
	   
	   echo "$cmd"
	   eval "$cmd"
   	endif
   else if ($lec_mode == "syn2dft") then
	echo "Warning: syn2dft should run without -use_tool_dofile flag"
	sleep 5
   else if ($lec_mode == "dft2place") then
	set DO_FILE = scripts_local/lec.place.do

   	echo $innovus_dir/out/fv/place/lec.place.do
	\cp -p $innovus_dir/out/fv/place/lec.place.do scripts_local/.

	perl -p -i -e 's#\.\.#../..#' scripts_local/lec.place.do
	set cmd = "perl -p -i -e 's#out/fv#$innovus_dir/out/fv#' scripts_local/lec.place.do"
	eval $cmd
	
	perl -p -i -e  's#^(report\S+) (.*)#\1 \2 > reports/\1.rpt#' scripts_local/lec.place.do
	perl -p -i -e  's#^(report\S+)$#\1 > reports/\1.rpt#' scripts_local/lec.place.do
	if ($disable_scan == "true") then
		set cmd = "perl -p -i -e 's/set_system_mode/add_pin_constraints 0 {TEST__SE} -both\nset_system_mode/' $DO_FILE"
		eval $cmd
		set cmd = "perl -p -i -e 's/set_system_mode/add_instance_constraints 0 ${design_name}_gate0_tessent_tdr_sri_ctrl_inst__int_ltest_en_latch_reg -both\nset_system_mode/' $DO_FILE"
		eval $cmd
		set cmd = "perl -p -i -e 's/set_system_mode/add_instance_constraints 0 ${design_name}_gate0_tessent_tdr_sri_ctrl_inst__ext_ltest_en_latch_reg -both\nset_system_mode/' $DO_FILE"
		eval $cmd
		
		#set cmd = "perl -p -i -e 's/set_system_mode/add_pin_constraints 1 {TEST__TDR_RST} -both\nset_system_mode/' $DO_FILE"
		#eval $cmd
#		perl -p -i -e 's/set_system_mode/set TEST_PORTS \[find -Port -Input TEST* -Revised\]\nforeach lll \$TEST_PORTS {\n\tif {\$lll eq "TEST__TDR_RST" || \$lll == "TEST__MEM_OVSTB" || \$lll == "TEST__ISO_ENABLE_OVERRIDE" || \$lll == "TEST__CLK_ENABLE_OVERRIDE" } {\n\t\tadd_pin_constraints 1 \$lll -Both\n\t} else {\n\t\tadd_pin_constraints 0 \$lll -Both\n\t}\n}\nset_system_mode/' $DO_FILE
	endif
      	if ($golden_netlist != "None") then
   	   echo "using golden netlist : $golden_netlist"
   	   perl -p -i -e 's#^(set golden_verilog_files)\s+\S+$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$golden_netlist#" $DO_FILE
   	endif
      	if ($revised_netlist != "None") then
   	   echo "using revised netlist : $revised_netlist"
   	   perl -p -i -e 's#^(set revised_verilog_files)\s+\S+$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$revised_netlist#" $DO_FILE
   	endif
   else if ($lec_mode == "place2route") then
	set DO_FILE = scripts_local/lec.route.do
   	echo $innovus_dir/out/fv/route/lec.route.do
	\cp -p $innovus_dir/out/fv/route/lec.route.do scripts_local/.
	perl -p -i -e 's#\.\.#../..#' scripts_local/lec.route.do
	set cmd = "perl -p -i -e 's#out/fv#$innovus_dir/out/fv#' scripts_local/lec.route.do"
	eval $cmd
	
	perl -p -i -e  's#^(report\S+) (.*)#\1 \2 > reports/\1.rpt#' scripts_local/lec.route.do
	perl -p -i -e  's#^(report\S+)$#\1 > reports/\1.rpt#' scripts_local/lec.route.do
	if ($disable_scan == "true") then
		set cmd = "perl -p -i -e 's/set_system_mode/add_pin_constraints 0 {shift_en} -golden\nset_system_mode/' $DO_FILE"
		eval $cmd
		set cmd = "perl -p -i -e 's/set_system_mode/add_pin_constraints 0 {shift_en} -revised\nset_system_mode/' $DO_FILE"
		eval $cmd
		set cmd = "perl -p -i -e 's/set_system_mode/add_pin_constraints 0 {dft_scan_en} -golden\nset_system_mode/' $DO_FILE"
		eval $cmd
		set cmd = "perl -p -i -e 's/set_system_mode/add_pin_constraints 0 {dft_scan_en} -revised\nset_system_mode/' $DO_FILE"
		eval $cmd
	endif
      	if ($golden_netlist != "None") then
   	   echo "using revised netlist : $golden_netlist"
   	   perl -p -i -e 's#^(set golden_verilog_files)\s+\S+$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$revised_netlist#" $DO_FILE
   	endif
      	if ($revised_netlist != "None") then
   	   echo "using revised netlist : $revised_netlist"
   	   perl -p -i -e 's#^(set revised_verilog_files)\s+\S+$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$revised_netlist#" $DO_FILE
   	endif
   else if ($lec_mode == "route2chip_finish") then
	set DO_FILE = scripts_local/lec.chip_finish.do
   	echo $innovus_dir/out/fv/chip_finish/lec.chip_finish.do
	\cp -p $innovus_dir/out/fv/chip_finish/lec.chip_finish.do scripts_local/.
	perl -p -i -e 's#\.\.#../..#' scripts_local/lec.chip_finish.do
	set cmd = "perl -p -i -e 's#out/fv#$innovus_dir/out/fv#' scripts_local/lec.chip_finish.do"
	eval $cmd
	
	perl -p -i -e  's#^(report\S+) (.*)#\1 \2 > reports/\1.rpt#' scripts_local/lec.chip_finish.do
	perl -p -i -e  's#^(report\S+)$#\1 > reports/\1.rpt#' scripts_local/lec.chip_finish.do
	if ($golden_netlist != "None") then
   	   echo "using revised netlist : $golden_netlist"
   	   perl -p -i -e 's#^(set golden_verilog_files)\s+\S+$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$golden_netlist#" $DO_FILE
	endif
	if ($revised_netlist != "None") then
   	   echo "using revised netlist : $revised_netlist"
   	   perl -p -i -e 's#^(set revised_verilog_files)\s+\S+$#\1 qawsedrftg#' $DO_FILE
	   perl -p -i -e "s#qawsedrftg#$revised_netlist#" $DO_FILE
	endif
   endif
   
   
    perl -p -i -e 's/(exit \-f)/if {[get_compare_points -nonequivalent -count] > 0 || [get_compare_points -abort -count] > 0 || [get_compare_points -notcompared -count] > 0 } {\n\1/' $DO_FILE
    perl -p -i -e 's/(exit \-f)/    puts \"\\n\\tFORMAL VERIFICATION FAILED\" \n\1/' $DO_FILE
    perl -p -i -e 's/(exit \-f)/    proc_lec_pass false \n\1/' $DO_FILE
    perl -p -i -e 's/(exit \-f)/    if { \$INTERACTIVE != "true"} { \n\1/' $DO_FILE
    perl -p -i -e 's/(exit \-f)/        exit\n\1/' $DO_FILE
    perl -p -i -e 's/(exit \-f)/    }\n\1/' $DO_FILE
    
    
    perl -p -i -e 's/(exit \-f)/ } else { \n\1/' $DO_FILE
    perl -p -i -e 's/(exit \-f)/    puts \"\\n\\tFORMAL VERIFICATION PASSED\"\n\1/' $DO_FILE
    perl -p -i -e 's/(exit \-f)/    proc_lec_pass\n\1/' $DO_FILE
    perl -p -i -e 's/(exit \-f)/    exit\n\1/' $DO_FILE
    perl -p -i -e 's/(exit \-f)/ }/' $DO_FILE
    
    perl -p -i -e 's#^tclmode#tclmode\nsource ../scripts/procs/common/procs.tcl#' $DO_FILE
    perl -p -i -e 's#^tclmode#tclmode\nif { [file exists user_inputs.tcl] } { source  user_inputs.tcl }#' $DO_FILE
   
#   perl -p -i -e 's#^exit.*#set FID \[open reports/report_verification.rpt r\]\nset FLAG 0\nwhile {\[gets \$FID line\] != -1} { if {\[regexp {FAIL} \$line\]} { set FLAG 1 }}\nclose \$FID\nif { \$FLAG} {\n\tanalyze_sequential_constants -REPORT > reports/analyze_sequential_constants.rpt\n\tputs "\n\tFORMAL VERIFICATION FAILED"\n} else {\n\tputs "\n\tFORMAL VERIFICATION PASSED"\n\texit\n}#' $DO_FILE
#   perl -p -i -e 's#^exit#if { !\[catch {exec grep "Compare Results" reports/report_verification.rpt | grep FAIL | wc -l}\]} {\n\tanalyze_sequential_constants -REPORT > reports/analyze_sequential_constants.rpt\n\tputs "\\n\\tFORMAL VERIFICATION FAILED"\n} else {\n\tputs "\\n\\tFORMAL VERIFICATION PASSED"\n\texit\n}#'  $DO_FILE
   perl -p -i -e 's/set_dofile_abort exit/set_dofile_abort on/' $DO_FILE
else
   setenv DW_DEFINE /tools/cdnc/genus/21.15.000/share/synth/lib/chipware/old_encrypt_sim/verilog/
endif ; #if ($use_tool_dofile == "true") then

  #<HN> replacing exit -f 
    perl -p -i -e 's/exit \-f/exit/' $DO_FILE


set OUTPUT_DIR  = "./out"       
set REPORTS_DIR = "./reports"   
set LOG_DIR     = "./log"       

mkdir -pv $OUTPUT_DIR ${OUTPUT_DIR}_prev $REPORTS_DIR ${REPORTS_DIR}_prev $LOG_DIR ${LOG_DIR}_prev log
#if ( `ls -a $LOG_DIR | wc -l` > 2 ) then
#    echo "-I- Copying existing logs to ${LOG_DIR}_prev directory" 
# \cp -fp $LOG_DIR/* ${LOG_DIR}_prev/
# \rm -f $LOG_DIR/*
#endif


####################################################################################################################################
##   running command
####################################################################################################################################
if ($restore == "false") then
	if ($lec_mode == "eco") then
		lec -XL -ECO -NOGui -Dofile $DO_FILE -LOGfile log/lec.log
	else
		echo "-I- running lec"
		lec -XL -NOGui -Dofile $DO_FILE -LOGfile log/lec.log
	endif
else
	echo "-I- running lec restore"
	lec -XL -NOGui -RESTART_CHECKPoint out/compare.ckpt -LOGfile log/restore.log
endif

cd ..

####################################################################################################################################
##   calculate memory usage and update k8s_profiler + 20%
####################################################################################################################################
#-----------------------------------
# memory usage k8s profiler update
#-----------------------------------
if ( `echo $HOST| grep nextk8s | wc -l` > 0) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh profiler_update lec
endif

###if (`echo $HOST| grep nextk8s | wc -l` > 0) then
###   set MEM_USAGE = `curl -s -g https://prometheus.k8s.nextsilicon.com/api/v1/query --data-urlencode 'query=max_over_time(container_memory_working_set_bytes{pod="'$HOST'",container="hw-ldap"}[14d])' | jq '.data.result[].value[1]' | perl -pe 's/"//g' | awk '{print $1/1024.0/1024.0/1024.0}'`
###   if ( $MEM_USAGE == "") then
###       echo "MEM USAGE unavailable for pod $HOST from containeer hw-ldap"
###   else
###       set MEM_USAGE_20 = `echo $MEM_USAGE | awk '{print $1*1.5}'`
###       set PROFILER = "NONE"
###       if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###       if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###       if ($PROFILER != "NONE") then
###           \cp $PROFILER ${PROFILER}.lec_old
###           echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in k8s profiler $PROFILER to $MEM_USAGE_20   (usage + 50%)"
###           set cmd = 'perl -p -i -e '\''s/(lec \d+) \d+/$1 '$MEM_USAGE_20'/'\'' '$PROFILER
###           echo $cmd
###           eval $cmd
###       else
###           if ( -d ../inter) then
###               echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in ../inter/k8s_profiler to $MEM_USAGE_20   (usage + 50%)"
###               echo "lec $cpu $MEM_USAGE_20" >> ../inter/k8s_profiler
###           else
###               echo "WARNING: memory usage for run is $MEM_USAGE .  update memory usage in ./scripts_local/k8s_profiler to $MEM_USAGE_20   (usage + 20%)"
###               echo "lec $cpu $MEM_USAGE_20" >> ./scripts_local/k8s_profiler
###           endif
###       endif
###   endif
###endif

####################################################################################################################################
##   end of run
####################################################################################################################################

echo "Finished running LEC flow on $STAGE mode"
exit 0


# if rtl2map failed do the below and rerun:
 #grep "will not be blackboxed" log/lec.rtl2map.log | awk '{print $3}' | perl -pe "s/'//g;s/\(\S\)//" | awk '{print "add_noblack_box "$1" -both"}' > scripts_local/add_noblack_box.tcl
 #grep "will be unblackboxed" log/lec.rtl2map.log | awk '{print $3}' | perl -pe "s/'//g;s/\(\S\)//" | awk '{print "add_noblack_box "$1" -both"}' >> scripts_local/add_noblack_box.tcl


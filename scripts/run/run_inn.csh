#!/bin/tcsh -fe

source /tools/common/pkgs/modules/current/init/tcsh

#Flag               Default   Description                                                                                                                                 
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------
# -argo	          false     'Run through argo';\
# -k8s	          false     'Run through k8s';\
# -desc	          <>        'k8s pod name. 20 char limit . default is running dir name';\
# -memory	          60        'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
# -tail	          false     'tail after create k8s pod';\
# -design_name      <>        'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
# -project          <>        'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
# -cpu              16        'Number of cpus per run. (default 16)';\
# -stages           <>        'Comma seperated list. Options: floorplan / place / cts / route / chip_finish / dummy / merge / eco . \-BSS\-Default is all but floorplan\-BSE\-';\
# -batch            true      'Run in batch mode - run stages one after another';\
# -place_start_from db        'floorplan (db) , def , syn , syn_incr';\
# -flow_start_from  db        'If place starts from db/syn - should the flow start from floorplan (db) OR def OR syn stylus db ';\
# -place_opt        0         'Number of place opt loops. 0 means None.';\
# -break_cts        true      'If true, runs ccopt_design -cts, and opt_design -setup seperatly, instead of full ccopt_design. Use \-BSS\-scripts_local/post_cts_pre_opt.tcl\-BSE\- to run commands before opt_design -setup';\
# -vt_effort        medium    'high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL';\
# -useful_skew      false     'if true, allow cadence opt tools to apply useful skew';\
# -ecf	          false     'if true, allow cadence opt tools to apply early clock flow';\
# -create_ilm       false     'Create ilm for hierarchical flow - Adds runtime';\
# -create_lib       false     'Create lib for hierarchical flow - Adds runtime';\
# -create_lib_pt    false     'Create lib for hierarchical flow - using PrimeTime. options are true, false, only';\
# -create_spef      false     'Create spef for hierarchical flow - Adds runtime';\
# -via_pillars      false     'Insert via pillars if possible';\
# -open             <>        'Stage to open';\
# -refresh          false     'If refresh == lef, reads lef from setup. If regresh == lib, recreate mmmc and reads it. I both, do both. If false, reads from DB';\
# -syn_dir          <>        'Syn folder to start from. \-BSS\-Default is syn OR syn_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-';\
# -wait_for_syn     false     'wait for synthesis to end before running';\
# -netlist          <>        'Default - \-BSS\-SYN_DIR/out/DESIGN_NAME.Syn.v.gz\-BSE\-';\
# -scandef          <>        'Default - \-BSS\-SYN_DIR/out/DESIGN_NAME.Syn.scandef.gz\-BSE\-';\
# -io_buffers_dir   in        'in / in_ant / out / both / both_ant / none (default)';\
# -scan             true      'Run insert_dft and scan-related processes';\
# -ocv              true      'Run in ocv mode';\
# -manual_fp        false     'If True, stops pre user manua_fp stage. If False, run your manual FP recipe';\
# -interactive      false     'Do not exit when done';\
# -logv             false     'To produce logv file';\
# -sdc_list         <>        'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
# -def_file         <>        '.def file or .def.gz file. \-BSS\-Default is ./DESIGN_NAME.def  OR ../inter/DESIGN_NAME.def\-BSE\-';\
# -eco_num          <>        'run eco number ';\
# -eco_do           STA       'eco will do STA , SEM , LOGIC , LOGIC_TCL';\
# -eco_netlist      <>        'netlist eco for netlist compare ';\
# -eco_script       <>        'script eco for logic eco ';\
# -stop_after       <>        'Stop after this stage - fp/place/cts_cluster/cts/route';\
# -force            false     'Start new stage without checking if the previous was done';\
# -other_args       <>        'Other arguments as a string. This string will be sourced as is in the tool';\
# -user_input       false     'read same user inputs as last run. need to define k8s flags again.';\
# -local            false     'If true run all do_ stages from scripts_local folder. can also run stages comma seperated list';\
# -scripts_version  <>        'scripts version. defaul will take the latest from be_repository' ;\
# -help             false     'Prints help for the relevant tool' ;\
# 




####################################################################################################################################
##   Parse args
####################################################################################################################################
source ./scripts/bin/parse_args.csh innovus $argv 

if ( $is_exit  == "true" ) then
    exit 2
endif
####################################################################################################################################
##   wait for genus 
####################################################################################################################################
set SYN_DIR = $syn_dir
if ($wait_for_syn == "true") then
   echo "-I- wait for ${syn_dir}/.syn_done"
   while ( ! -f ${syn_dir}/.syn_done) 
      sleep 5
   end
   echo "-I- file exists. start runing Innovus stages: $stages"
endif

####################################################################################################################################
##   nextk8s run
####################################################################################################################################

if ( $open != "None" ) then
    if (! -f $open) then
 	    set stages = $open
	    echo "open $open . stages = $stages"
    endif
endif

echo "stages: $stages"
echo "k8s $k8s"
if ($k8s == "true" ) then
   if ($desc == "None") then
       set desc = `echo $PWD | awk -F'/' '{print $NF}' | cut -c1-20 | tr "[:upper:]" "[:lower:]"`
   else
       set desc = `echo $desc | tr "[:upper:]" "[:lower:]"`
   endif
   
   if ($open != "None" ) then
       source ./scripts/bin/k8s_launcher.csh inn $argv
   else
       echo "#\!/bin/tcsh -fe" > k8s_dispatch.csh
       echo "echo  > COMMAND " >> k8s_dispatch.csh
       echo "echo  > grafana/grafana.log" >> k8s_dispatch.csh
       echo "set memory = $memory" >> k8s_dispatch.csh
       echo "set cpu = $cpu" >> k8s_dispatch.csh
       echo "set desc = $desc" >> k8s_dispatch.csh
       echo "set open = $open" >> k8s_dispatch.csh
       echo "set syn_dir = $syn_dir" >> k8s_dispatch.csh
       echo "set manual_fp = $manual_fp" >> k8s_dispatch.csh
       echo "set interactive = $interactive" >> k8s_dispatch.csh
       echo "set vnc_display = $vnc_display" >> k8s_dispatch.csh
       echo "set vnc_server = $vnc_server" >> k8s_dispatch.csh
       echo "set win = $win" >> k8s_dispatch.csh
       echo "set label = $label" >> k8s_dispatch.csh
       echo "set terminal = $terminal" >> k8s_dispatch.csh
       echo "set tail = $tail" >> k8s_dispatch.csh
       echo "foreach stage (`echo $stages`)" >> k8s_dispatch.csh
       echo '   set AAA = `echo '$argv' | perl -pe "s/-stages \S+//;"`' >> k8s_dispatch.csh
       echo '   source ./scripts/bin/k8s_launcher.csh inn $AAA -stages $stage ' >> k8s_dispatch.csh
#   get running parameters , LOG / HOST / COMMAND
       echo '   echo "cmd: $cmd" >> COMMAND' >> k8s_dispatch.csh
       echo '	echo "Waiting for stage $stage to finish." >> COMMAND' >> k8s_dispatch.csh
       echo '	sleep 180' >> k8s_dispatch.csh
       echo '	set last_log = `\ls -tr log/do_${stage}.log.full | grep -v logv | tail -1`  ' >> k8s_dispatch.csh
#       echo '	set host_ = `grep -m1 nextk8s $last_log | awk '\''{print $2}'\''`' >> k8s_dispatch.csh
#       echo '	set host  = `echo $host_ | awk -F"-" '\''{$NF="" ; print $0}'\'' | perl -pe '\''s/ /-/g;s/-$//'\''`' >> k8s_dispatch.csh
       echo '	set host  = $host__' >> k8s_dispatch.csh
       echo '	echo log file : $last_log >> COMMAND' >> k8s_dispatch.csh
#       echo '	echo host : $host >> COMMAND' >> k8s_dispatch.csh
       
       echo '	while ( ! -f .${stage}_done)' >> k8s_dispatch.csh
       # search for Errors in the log file. 
       ################################################
       # check if pod exists. 
       echo '	   if (`echo $host | grep nextk8s | wc -l` == 0) then' >> k8s_dispatch.csh
       echo '	      echo "Warning: unknown host. no active checkers."' >> k8s_dispatch.csh
       echo '	      echo "Warning: unknown host. no active checkers" >> COMMAND' >> k8s_dispatch.csh
       echo '	   else' >> k8s_dispatch.csh
       echo '	      if (`nextk8s list -regex $host | grep -v list | grep $host | wc -l ` == 0) then' >> k8s_dispatch.csh
       echo '	    	 echo "Host $host does not exists and stage $stage is not done"' >> k8s_dispatch.csh
       echo '	    	 echo "Host $host does not exists and stage $stage is not done" > log/ERROR.log' >> k8s_dispatch.csh
       echo '	    	 echo "Host $host does not exists and stage $stage is not done" >> COMMAND' >> k8s_dispatch.csh
       echo '	    	 exit 1' >> k8s_dispatch.csh
       echo '	      endif' >> k8s_dispatch.csh

       # check if log has -E- No $stage done. 
       echo '	      if (`grep "\-E\- No" $last_log | grep "_done found. Make sure" | wc -l`) then' >> k8s_dispatch.csh
       echo '	   	 echo `grep "\-E\- No" $last_log | grep "_done found. Make sure"`' >> k8s_dispatch.csh
       echo '	   	 echo `grep "\-E\- No" $last_log | grep "_done found. Make sure" ` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	   	 echo `grep "\-E\- No" $last_log | grep "_done found. Make sure" ` >> COMMAND' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
          echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       endif
       echo '	   	 exit 1' >> k8s_dispatch.csh
       echo '	      endif' >> k8s_dispatch.csh
       
       # check if log has Invalid return code while executing. 
       echo '	      if (`grep "Invalid return code while executing" $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '	   	 echo `grep -A3 -B5 "Invalid return code while executing" $last_log`' >> k8s_dispatch.csh
       echo '	   	 echo `grep -A5 -B5 "Invalid return code while executing" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	   	 echo `grep  "Invalid return code while executing" $last_log` >> COMMAND' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
           echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       endif
       echo '	   	 exit 1' >> k8s_dispatch.csh
       echo '	      endif' >> k8s_dispatch.csh
       
       # check if log have  CTE-2|CTE-27|IMPCTE-2|IMPCTE-27 Warning. 
       echo '	      if (`egrep -w "CTE-2|CTE-27|IMPCTE-2|IMPCTE-27" $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "CTE-2|CTE-27|IMPCTE-2|IMPCTE-27" $last_log`' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "CTE-2|CTE-27|IMPCTE-2|IMPCTE-27" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w "CTE-2|CTE-27|IMPCTE-2|IMPCTE-27" $last_log` >> COMMAND' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
           echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       endif
       echo '	   	 exit 1' >> k8s_dispatch.csh
       echo '	      endif' >> k8s_dispatch.csh
       
       # check if log have  IMPDF-200 Warning. 
       echo '	      if (`egrep -w "IMPDF-200" $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "IMPDF-200" $last_log`' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "IMPDF-200" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w "IMPDF-200" $last_log` >> COMMAND' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
           echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       endif
       echo '	   	 exit 1' >> k8s_dispatch.csh
       echo '	      endif' >> k8s_dispatch.csh
       
       # check if log have  IMPVL-346 Warning. 
       echo '	      if (`egrep -w "IMPVL-346 " $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "IMPVL-346" $last_log`' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "IMPVL-346" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w "IMPVL-346" $last_log` >> COMMAND' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
           echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       endif
       echo '	   	 exit 1' >> k8s_dispatch.csh
       echo '	      endif' >> k8s_dispatch.csh
       
       # check if log have  IMPDB-2504  Warning. 
       echo '	      if (`egrep -w "IMPDB-2504 " $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "IMPDB-2504" $last_log`' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "IMPDB-2504" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w "IMPDB-2504" $last_log` >> COMMAND' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
           echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       endif
       echo '	   	 exit 1' >> k8s_dispatch.csh
       echo '	      endif' >> k8s_dispatch.csh
       
       echo '	   endif' >> k8s_dispatch.csh
       
       
       # wait 300 sec and check again
       echo '	   echo "wainting for ${stage}_done"' >> k8s_dispatch.csh
       echo '	   sleep 300' >> k8s_dispatch.csh
       echo '	end' >> k8s_dispatch.csh
       echo '	echo STAGE $stage done >> COMMAND' >> k8s_dispatch.csh
       echo 'end' >> k8s_dispatch.csh
       echo 'exit 0' >> k8s_dispatch.csh
       


       chmod 755 k8s_dispatch.csh
       set desc = disp_${desc}
       set COMMAND = "./k8s_dispatch.csh"
       if ( $?NXT080 ) then
           if (  $NXT080 == "true") then
               set COMMAND = "setenv NXT080 true && $COMMAND"
           endif
       endif
       if ($tail == "true") then
           echo '/tools/common/bin/nextk8s run -command "'$COMMAND'" -working-dir '$PWD' -cpu-limit 1 -cpu 0.1 -desc '$desc' -memory 1 -tail  -queue-name backend -queue-mode'
          /tools/common/bin/nextk8s run -command "$COMMAND" -working-dir $PWD -cpu-limit 1 -cpu 0.1 -desc $desc -memory 1 -tail  -queue-name backend -queue-mode
       else
          /tools/common/bin/nextk8s run -command "$COMMAND" -working-dir $PWD -cpu-limit 1 -cpu 0.1 -desc $desc -memory 1  -queue-name backend -queue-mode
       endif
   
   endif
   exit 0

endif








if ($k8s == "true_FALSE" ) then
   set PROFILER = "NONE"
   if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
   if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
   
   if ($desc == "None") then
      set desc = `echo $PWD | awk -F'/' '{print $NF}' | cut -c1-20 | tr "[:upper:]" "[:lower:]"`
   else
      set desc = `echo $desc | tr "[:upper:]" "[:lower:]"`
   endif
   echo "k8s:  $k8s"
   echo "desc: $desc"
   echo "argv: $argv"
   
   
       echo "#\!/bin/csh" > k8s_dispatch.csh
       echo "echo  > COMMAND " >> k8s_dispatch.csh
       echo "set PROFILER = $PROFILER" >> k8s_dispatch.csh
       echo 'if ($PROFILER != "NONE") then' >> k8s_dispatch.csh
   echo '   set AAA = `echo '$argv' | perl -pe "s/-k8s// ; s/-desc \S+// ; s/-stages \S+//;s/-tail// ; "`' >> k8s_dispatch.csh
       echo '   set AAAA = `echo $AAA | perl -pe "s/-cpu \S+//"`' >> k8s_dispatch.csh
       echo "   foreach stage (`echo $stages`)" >> k8s_dispatch.csh
       echo '      set memory = `cat $PROFILER | perl -pe "s/#.*//" | grep $stage | awk '\''{print $NF}'\''`' >> k8s_dispatch.csh
       echo '      set cpu = `cat $PROFILER | perl -pe '\''s/#.*//'\'' | grep $stage | awk '\''{print $(NF-1)}'\''`' >> k8s_dispatch.csh
       echo '      echo "cpu $cpu"' >> k8s_dispatch.csh
       echo '      set K8S_CPU = `echo $cpu | awk '\''{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\\n" }'\''`' >> k8s_dispatch.csh
       echo '      set K8S_MEM = `echo $memory | awk '\''{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\\n" }'\''`' >> k8s_dispatch.csh
       echo '      echo "K8S_MEM $K8S_MEM"' >> k8s_dispatch.csh
       echo '      echo "K8S_CPU $K8S_CPU"' >> k8s_dispatch.csh
   echo '      set COMMAND = "./scripts/run/run_inn.csh -cpu $cpu -stages $stage $AAAA"' >> k8s_dispatch.csh
           echo '      if ( $?NXT080 ) then' >> k8s_dispatch.csh
           echo '          if (  $NXT080 == "true") then' >> k8s_dispatch.csh
           echo '              set COMMAND = "setenv NXT080 true && $COMMAND"' >> k8s_dispatch.csh
           echo '          endif' >> k8s_dispatch.csh
           echo '      endif' >> k8s_dispatch.csh


          if ($tail == "true") then
      echo '      set cmd = "/tools/common/bin/nextk8s run -command '\''$COMMAND'\'' -x-server -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc '$desc' -memory-limit $memory -memory $K8S_MEM -tail"' >> k8s_dispatch.csh
          else
      echo '      set cmd = "/tools/common/bin/nextk8s run -command '\''$COMMAND'\'' -x-server -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc '$desc' -memory-limit $memory -memory $K8S_MEM"' >> k8s_dispatch.csh
          endif
       
       echo '      echo "cmd: $cmd" >> COMMAND' >> k8s_dispatch.csh
       echo '      eval $cmd ' >> k8s_dispatch.csh
       echo '      echo "Waiting for stage $stage to finish." >> COMMAND' >> k8s_dispatch.csh
       echo '      sleep 60' >> k8s_dispatch.csh
       echo '      set last_log = `\ls -tr log/${stage}.log* | grep -v logv | tail -1`  ' >> k8s_dispatch.csh
       echo '      set host_ = `grep -m1 nextk8s $last_log | awk '\''{print $2}'\''`' >> k8s_dispatch.csh
       echo '      set host  = `echo $host_ | awk -F"-" '\''{$NF="" ; print $0}'\'' | perl -pe '\''s/ /-/g;s/-$//'\''`' >> k8s_dispatch.csh
       echo '      echo log file : $last_log >> COMMAND' >> k8s_dispatch.csh
       echo '      echo host : $host >> COMMAND' >> k8s_dispatch.csh
       echo '      while ( ! -f .${stage}_done)' >> k8s_dispatch.csh
       # search for Errors in the log file. 
       echo '	  if (`grep "\-E\- No" $last_log | grep "_done found. Make sure" | wc -l`) then' >> k8s_dispatch.csh
       echo '	     echo `grep "\-E\- No" $last_log | grep "_done found. Make sure"`' >> k8s_dispatch.csh
       echo '	     echo `grep "\-E\- No" $last_log | grep "_done found. Make sure" ` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	     echo `grep "\-E\- No" $last_log | grep "_done found. Make sure" ` >> COMMAND' >> k8s_dispatch.csh
       echo '            /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       echo '	     exit 1' >> k8s_dispatch.csh
       echo '	  endif' >> k8s_dispatch.csh
       echo '	  if (`grep "Invalid return code while executing" $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '	     echo `grep -A3 -B5 "Invalid return code while executing" $last_log`' >> k8s_dispatch.csh
       echo '	     echo `grep -A5 -B5 "Invalid return code while executing" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	     echo `grep  "Invalid return code while executing" $last_log` >> COMMAND' >> k8s_dispatch.csh
       echo '            /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       echo '	     exit 1' >> k8s_dispatch.csh
       echo '	  endif' >> k8s_dispatch.csh
       echo '	  if (`egrep -w "CTE-2|CTE-27|IMPCTE-2|IMPCTE-27" $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '	     echo `egrep -w -B2 "CTE-2|CTE-27|IMPCTE-2|IMPCTE-27" $last_log`' >> k8s_dispatch.csh
       echo '	     echo `egrep -w -B2 "CTE-2|CTE-27|IMPCTE-2|IMPCTE-27" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	     echo `egrep -w "CTE-2|CTE-27|IMPCTE-2|IMPCTE-27" $last_log` >> COMMAND' >> k8s_dispatch.csh
       echo '            /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       echo '	     exit 1' >> k8s_dispatch.csh
       echo '	  endif' >> k8s_dispatch.csh
       echo '	  echo "wainting for ${stage}_done"' >> k8s_dispatch.csh
       echo '	  sleep 60' >> k8s_dispatch.csh
       echo '      end' >> k8s_dispatch.csh
       echo '      echo STAGE $stage done >> COMMAND' >> k8s_dispatch.csh
       echo '   end' >> k8s_dispatch.csh
       echo '   exit 0' >> k8s_dispatch.csh
       echo 'else' >> k8s_dispatch.csh
       echo '   set AAA = `echo '$argv' | perl -pe '\''s/-k8s//;s/-desc \S+//;s/-tail//'\''`' >> k8s_dispatch.csh
       echo '   set COMMAND = "./scripts/run/run_inn.csh $AAA"' >> k8s_dispatch.csh
          echo '   if ( $?NXT080) then' >> k8s_dispatch.csh
          echo '       if ( $NXT080 == "true") then' >> k8s_dispatch.csh
          echo '           set COMMAND = "setenv NXT080 true && $COMMAND"' >> k8s_dispatch.csh
          echo '       endif' >> k8s_dispatch.csh
          echo '   endif' >> k8s_dispatch.csh
   echo "   set cpu = $cpu" >> k8s_dispatch.csh
   echo "   set memory = $memory" >> k8s_dispatch.csh
   echo '   set K8S_CPU = `echo $cpu | awk '\''{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\\n" }'\''`' >> k8s_dispatch.csh
   echo '   set K8S_MEM = `echo $memory | awk '\''{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\\n" }'\''`' >> k8s_dispatch.csh
          if ($tail == "true") then
      echo '   set cmd = "/tools/common/bin/nextk8s run -command '\''$COMMAND'\'' -x-server -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc '$desc' -memory-limit $memory -memory $K8S_MEM -tail"' >> k8s_dispatch.csh
          else
      echo '   set cmd = "/tools/common/bin/nextk8s run -command '\''$COMMAND'\'' -x-server -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc '$desc' -memory-limit $memory -memory $K8S_MEM"' >> k8s_dispatch.csh
       endif
       echo '   echo "cmd: $cmd" >> COMMAND' >> k8s_dispatch.csh
       echo '   eval $cmd' >> k8s_dispatch.csh
       echo '   exit 0' >> k8s_dispatch.csh
       echo 'endif' >> k8s_dispatch.csh
       chmod 755 k8s_dispatch.csh
       set desc = disp_${desc}
       set COMMAND = "./k8s_dispatch.csh"
       if ( $?NXT080 ) then
           if (  $NXT080 == "true") then
               set COMMAND = "setenv NXT080 true && $COMMAND"
           endif
       endif
    
       if ($tail == "true") then
          /tools/common/bin/nextk8s run -command "$COMMAND" -working-dir $PWD -cpu-limit 1 -cpu 0.1 -desc $desc -memory 1 -tail
       else
          /tools/common/bin/nextk8s run -command "$COMMAND" -working-dir $PWD -cpu-limit 1 -cpu 0.1 -desc $desc -memory 1
       endif
   exit 0
   
endif

####################################################################################################################################
##  Load modules
####################################################################################################################################
module unload cdnc/innovus cdnc/genus cdnc/quantus cdnc/pegasus cdnc/ssv 
if ($tool_version != "None") then
    module load cdnc/quantus/22.11.000 cdnc/pegasus/22.14.000 cdnc/ssv/20.14.000
    
    if (`(module avail cdnc/genus/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: genus version $tool_version"
	module load cdnc/genus/$tool_version
    else 
        echo "Info: genus version 23.32.000"
        module load cdnc/genus/23.32.000
    endif
    if (`(module avail cdnc/innovus/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: innovus version $tool_version"
	module load cdnc/innovus/$tool_version
    else 
        echo "Info: innovus version 23.32.000"
        module load cdnc/innovus/23.32.000
    endif
    
else
    module load cdnc/innovus/23.32.000 cdnc/genus/23.32.000 cdnc/quantus/22.11.000 cdnc/pegasus/22.14.000 cdnc/ssv/20.14.000
endif





mkdir -pv scripts_local work log reports out/def out/db out/fp out/netlist out/lef out/gds out/verilog out/lib grafana
#\rm -rf log/*


####################################################################################################################################
##   user setting
####################################################################################################################################
#-----------------------------------------------------------------------------------------------------------------------------------
# all stages setting
#-----------------------------------------------------------------------------------------------------------------------------------
setenv PROJECT  $project

#set DESIGN_NAME  = `echo $PWD | awk -F '/' '{print $(NF-2)}'`
#set DESIGN_NAME = $design_name
#set CREATE_LIB  = $create_lib 	 ; # options are: true , false 
#-----------------------------------------------------------------------------------------------------------------------------------
# place stage setting
#-----------------------------------------------------------------------------------------------------------------------------------
#set wait_for_syn = "false" 	 ; # options are: true , false 




#-----------------------------------------------------------------------------------------------------------------------------------
# files setting
#-----------------------------------------------------------------------------------------------------------------------------------
if ( $netlist == "None" ) then
    set NETLIST_FILE = "$SYN_DIR/out/${design_name}.Syn.v.gz"
    echo "set NETLIST_FILE $NETLIST_FILE\n" >> .tmp_user_inputs.tcl
else 
    set NETLIST_FILE = $netlist
    echo "set NETLIST_FILE $NETLIST_FILE\n" >> .tmp_user_inputs.tcl
endif

if ( $scandef == "None" ) then
    set SCAN_DEF_FILE = "$SYN_DIR/out/${design_name}.Syn.scandef.gz"
    echo "set SCAN_DEF_FILE $SCAN_DEF_FILE\n" >> .tmp_user_inputs.tcl
else 
    set SCAN_DEF_FILE = $scandef
    echo "set SCAN_DEF_FILE $SCAN_DEF_FILE\n" >> .tmp_user_inputs.tcl
endif

####################################################################################################################################
##   definig stages to run
####################################################################################################################################
#set STAGES = ""
#set STAGES = "$STAGES floorplan"
#set STAGES = "$STAGES place"
#set STAGES = "$STAGES cts"
#set STAGES = "$STAGES route"
#set STAGES = "$STAGES eco"
#set STAGES = "$STAGES chip_finish"
set STAGES = "$stages"


####################################################################################################################################
##   stages scripts
####################################################################################################################################


if ( $?local && $local == "true" ) then
    # Run from local do file
    set scripts_folder = ./scripts_local
else
    # Run from central do file
    set scripts_folder = ./scripts
endif

if ($?local && `echo $local | egrep "true|open" | wc -l`) then
    set OPEN_SCRIPT = "./scripts_local/do_openblock.tcl"
else
    set OPEN_SCRIPT = "./scripts/do_openblock.tcl"
endif
if ($?local && `echo $local | egrep "true|floorplan" | wc -l`) then
    set FLOORPLAN_SCRIPT = "./scripts_local/do_floorplan.tcl"
else
    set FLOORPLAN_SCRIPT = "./scripts/do_floorplan.tcl"
endif
if ($?local && `echo $local | egrep "true|place" | wc -l`) then
    set PLACE_SCRIPT = "./scripts_local/do_place.tcl"
else
    set PLACE_SCRIPT = "./scripts/do_place.tcl"
endif
if ($?local && `echo $local | egrep "true|cts" | wc -l`) then
    set CTS_SCRIPT = "./scripts_local/do_cts.tcl"
else
    set CTS_SCRIPT = "./scripts/do_cts.tcl"
endif
if ($?local && `echo $local | egrep "true|route" | wc -l`) then
    set ROUTE_SCRIPT = "./scripts_local/do_route.tcl"
else
    set ROUTE_SCRIPT = "./scripts/do_route.tcl"
endif
if ($?local && `echo $local | egrep "true|eco" | wc -l`) then
    set ECO_SCRIPT = "./scripts_local/do_eco.tcl"
else
    set ECO_SCRIPT = "./scripts/do_eco.tcl"
endif
if ($?local && `echo $local | egrep "true|chip_finish" | wc -l`) then
    set CHIP_FINISH_SCRIPT = "./scripts_local/do_chip_finish.tcl"
else
    set CHIP_FINISH_SCRIPT = "./scripts/do_chip_finish.tcl"
endif


####################################################################################################################################
##   non user variables
####################################################################################################################################
set MANUAL_FP = $manual_fp
if ( $?logv && $logv == "true") then
	set LOGV = ""
else
	set LOGV = "-no_logv"
endif




####################################################################################################################################
##   shell arguments
####################################################################################################################################
set STAGE_TO_OPEN = $open
if ( $STAGE_TO_OPEN != "None" ) then
    set STAGES = "open"
    set force  = "true"
    echo "set STAGE_TO_OPEN $open" >> .tmp_user_inputs.tcl
    echo "set STAGE $open      \n" >> .tmp_user_inputs.tcl  
 \cp -p .tmp_user_inputs.tcl open_user_inputs.tcl
else 
   if ($user_inputs == "false") then
	 \cp -p .tmp_user_inputs.tcl user_inputs.tcl
   else
      echo "using existing user input file"
   endif
endif

#\rm .tmp_user_inputs.tcl
####################################################################################################################################
##   execute stages 
####################################################################################################################################
foreach STAGE (`echo $STAGES`)
    echo "-I- Running $STAGE"
    if ( ${STAGE} != "floorplan"  ) then
        ## Avner added here start of HTML file
        echo "<html>" > grafana/${STAGE}_load_gifs.html
        echo "<body>" >> grafana/${STAGE}_load_gifs.html
        echo "<h2>Snapshots</h2>" >> grafana/${STAGE}_load_gifs.html
    endif
    
    set log_file = log/${STAGE}.log
    
    if ($create_lib_pt != "only") then
        # Remove old done stage
        if ( -e .${STAGE}_done ) then
            \rm .${STAGE}_done
        endif    
    
        if ( $force == "false" ) then 
        # Check of previous stage is done
            if ( $previous_stage == "syn" ) then
                if ( ! -e $syn_dir/.syn_done ) then
                    echo "-E- No .syn_done found in $syn_dir. Make sure syn is done, or use -force to overide this check"
                    echo "-E- No .syn_done found in $syn_dir. Make sure syn is done, or use -force to overide this check" > $log_file
                    exit 1
                endif
            else 
                if ( ! -e .${previous_stage}_done ) then
                    echo "-E- No .${previous_stage}_done found. Make sure $previous_stage is done, or use -force to overide this check"
                    echo "-E- No .${previous_stage}_done found. Make sure $previous_stage is done, or use -force to overide this check" > $log_file
    
                    exit 1
                endif
            endif
            set previous_stage = $STAGE
        endif
    
    
        if ($STAGE == "open") then
            set log_file = `whoami`_`date +%F.%T`
            innovus -common_ui \
             -wait 1000 \
           -execute " \
            #               WA: $WA_PATH \
            source -e -v ./open_user_inputs.tcl ; \
            " \
            -files $OPEN_SCRIPT \
            $LOGV -log log/open_${log_file}.log
        else if ($STAGE == "floorplan") then
            innovus -common_ui \
            -wait 1000 \
            -execute " \
            #	WA: $WA_PATH \
            source -e -v ./user_inputs.tcl ; \
            " \
            -files $FLOORPLAN_SCRIPT \
            $LOGV -log $log_file | tee log/do_floorplan.log.full
        else if ($STAGE == "place1") then
	   touch .place_done

        else if ($STAGE == "place") then
           innovus -common_ui \
            -wait 1000 \
            -execute " \
            #	WA: $WA_PATH \
            source -e -v ./user_inputs.tcl ; \
            " \
            -files $PLACE_SCRIPT \
            $LOGV -log $log_file | tee log/do_place.log.full
        else if ($STAGE == "cts") then
            innovus -common_ui \
            -wait 1000 \
            -execute " \
            #	WA: $WA_PATH \
            source -e -v ./user_inputs.tcl ; \
            " \
            -files $CTS_SCRIPT \
            $LOGV -log $log_file | tee log/do_cts.log.full
        else if ($STAGE == "route") then
            innovus -common_ui \
            -wait 1000 \
            -execute " \
            #	WA: $WA_PATH \
            source -e -v ./user_inputs.tcl ; \
            " \
            -files $ROUTE_SCRIPT \
            $LOGV -log $log_file | tee log/do_route.log.full
        else if ($STAGE == "chip_finish") then
            innovus -common_ui \
            -wait 1000 \
            -execute " \
            #	WA: $WA_PATH \
            source -e -v ./user_inputs.tcl ; \
            " \
            -files $CHIP_FINISH_SCRIPT \
            $LOGV -log $log_file | tee log/do_chip_finish.log.full
        else if ($STAGE == "eco") then
            set log_file = log/${STAGE}${eco_num}.log
            innovus -common_ui \
            -wait 1000 \
            -execute " \
            #	WA: $WA_PATH \
            source -e -v ./user_inputs.tcl ; \
            " \
            -files $ECO_SCRIPT \
            $LOGV -log $log_file | tee log/do_eco${eco_num}.log.full
        else if ($STAGE == "dummy") then
            set INNOVUS_DIR = $PWD
            set DM_DIR = `echo $PWD  | perl -pe 's/pnr/dm/'`
            set DODPO_DIR = `echo $PWD  | perl -pe 's/pnr/dodpo/'`
            mkdir -pv $DM_DIR
            mkdir -pv $DODPO_DIR
            if ( ! -d $DM_DIR/scripts ) then
                \cp -rfp scripts $DM_DIR
            endif 
            if ( ! -f $DM_DIR/run_dm.csh ) then
                \cp -p scripts/run/run_dm.csh $DM_DIR/
            endif
            if ( ! -d $DODPO_DIR/scripts ) then
                \cp -rfp scripts $DODPO_DIR
            endif 
            if ( ! -f $DODPO_DIR/run_dodpo.csh ) then
                \cp -p scripts/run/run_dodpo.csh $DODPO_DIR/
            endif
            cd $DODPO_DIR
            ./run_dodpo.csh &
            cd $DM_DIR
            ./run_dm.csh
            cd $INNOVUS_DIR
            touch .dummy_done
        else if ($STAGE == "merge") then
            ./scripts/run/run_merge.csh
            touch .merge_done
        endif
    endif ; #if ($create_lib_pt != "only")
    set last_log = "`ls -tr log/*.log* | grep -v logv | tail -1`"


###    # calculate memory usage and update k8s_profiler + 20%
###    if ($fe_mode == "false" && `echo $HOST| grep nextk8s | wc -l` > 0) then
###       set MEM_USAGE = `curl -s -g https://prometheus.k8s.nextsilicon.com/api/v1/query --data-urlencode 'query=max_over_time(container_memory_working_set_bytes{pod="'$HOST'",container="hw-ldap"}[14d])' | jq '.data.result[].value[1]' | perl -pe 's/"//g' | awk '{print $1/1024.0/1024.0/1024.0}'`
###       if ( $MEM_USAGE == "") then
###   	   echo "MEM USAGE unavailable for pod $HOST from containeer hw-ldap"
###       else
###           set MEM_USAGE_20 = `echo $MEM_USAGE | awk '{print $1*1.2}'`
###           set PROFILER = "NONE"
###           if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
###           if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
###           if ($PROFILER != "NONE") then
###              \cp $PROFILER ${PROFILER}.${STAGE}_old
###               echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in k8s profiler $PROFILER to $MEM_USAGE_20   (usage + 20%)"
###               set cmd = 'perl -p -i -e '\''s/('$STAGE' \d+) \d+/$1 '$MEM_USAGE_20'/'\'' '$PROFILER
###               echo $cmd
###               eval $cmd
###           else
###               if ( -d ../inter) then
###                   echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in ../inter/k8s_profiler to $MEM_USAGE_20   (usage + 20%)"
###                   echo "$STAGE $cpu $MEM_USAGE_20" >> ../inter/k8s_profiler
###               else
###                   echo "WARNING: memory usage for run is $MEM_USAGE .  update memory usage in ./scripts_local/k8s_profiler to $MEM_USAGE_20   (usage + 20%)"
###                   echo "$STAGE $cpu $MEM_USAGE_20" >> ./scripts_local/k8s_profiler
###               endif
###           endif
###       endif
###    endif

    
    if ( -e .${STAGE}_done ) then
        echo "-I- $STAGE done with normal exit"
        ./scripts/bin/logscan.tcl $last_log
	
        if ( ${STAGE} != "floorplan"  ) then
            source ./scripts/bin/run_db.csh
            ## Avner Added here a close HTML 
            echo "</body>" >> grafana/${STAGE}_load_gifs.html
            echo "</html>" >> grafana/${STAGE}_load_gifs.html

            # upload GIFs to artifactory
            echo "-I- uploading HTML into artifactory"
            echo "#################################################################################################"
            setenv JFROG_USER becad
            setenv JFROG_PASS Becad_123
            set _run =  `pwd | tr "/" " " | awk '{print $NF}'`
            set _version = `pwd | tr "/" " " | awk '{print $(NF-1)}'`
            echo "uploading HTML into artifactory url: generic-repo/backend/${USER}/${block_name}/${_version}/${_run}/${STAGE}/${STAGE}_load_gifs.html" >> grafana/grafana.log
            /tools/common/bin/cing-artifactory upload -src-artifact grafana/${STAGE}_load_gifs.html -dst-artifact generic-repo/backend/${USER}/${block_name}/${_version}/${_run}/${STAGE}/ || echo "failed to upload load_gifs.html into artifactory" >> grafana/grafana.log



            if ($create_lib_pt == "true") then
                set VIEWS = `grep "Operating conditions" reports/${STAGE}.be.qor | perl -pe 's/^\s*Operating conditions://;s/\n/ /;s/\s+/ /g'`
                if (`echo $HOST | grep nextk8s | wc -l`) then
                    set hosts_ = nextk8s
                else
                    set hosts_ = localhost;
                endif
                if ($STAGE == "route") then 
                    set XTALK_SI = true 
                else 
                    set XTALK_SI = false
                endif
                if ($STAGE == "floorplan") then 
                    set READ_SPEF = "false" 
                else 
                    set READ_SPEF = "true"
                endif
                xterm \
                    -T "run lib generator for stage ${STAGE}" \
                    -bg white -fg black -e csh \
                    -c './scripts/run/run_pt.csh \
                    -views {${VIEWS}} \
                    -hosts ${hosts_} \
                    -create_lib \
                    -create_lib_only \
                    -xtalk ${XTALK_SI} \
                    -read_spef ${READ_SPEF} \
                    -read_gpd false \
                    -pba_mode path \
                    -stage ${STAGE} \
                    -spef_dir $PWD \
                    -netlist out/db/${design_name}.${STAGE}.enc.dat/${design_name}.v.gz'
            endif
 endif
    else
        echo "-E- $STAGE done with abnormal exit"
        ./scripts/bin/logscan.tcl $last_log
        exit 1
    endif
    
####################################################################################################################################
##   calculate memory usage and update k8s_profiler + 20%
####################################################################################################################################
   if ( `echo $HOST| grep nextk8s | wc -l` > 0) then
      echo "k8s: $k8s"
      source ./scripts/bin/k8s_launcher.csh profiler_update $STAGE
   endif

end
#echo $STAGE > $STAGE

## Avner Added here a close HTML 
exit 0

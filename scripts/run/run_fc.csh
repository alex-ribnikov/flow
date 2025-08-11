#!/bin/tcsh -fe
unlimit 

source /tools/common/pkgs/modules/current/init/tcsh

#Flag               Default   Description                                                                                                                                 
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------

setenv SNPS_MAX_WAITTIME  259200

setenv SNPS_MAX_QUEUETIME 259200 
####################################################################################################################################
##   check scripts version
####################################################################################################################################

if (`echo $argv | grep "\-scripts_version" | wc -l `) then
    echo "scripts_version exists in argv"
    set VERSION = `echo $argv | perl -pe 's/.*-scripts_version//'|awk '{print $1}'`
    if (`echo $VERSION | grep "\-" | wc -l`) then
        echo "scripts_version  is invalid "
    else
        echo "scripts_version is $VERSION "
	
   	if (! -e /bespace/users/be_repository/ns_flow/$VERSION/scripts && ! -e /ex-bespace/users/be_repository/ns_flow/$VERSION/scripts) then
       		echo "$VERSION  is not valid value for scripts repository."
       		exit
   	endif
   	set LINK_DIR = `\ls -lrt scripts | awk '{print $NF}' `
   	# if scripts is link to repository and differ from VERSION, update the link.
   	# else print a warning and holt for 60 sec.
   	if (-l ./scripts && `echo $LINK_DIR | grep be_repository | wc -l`) then
      		set LINK_DIR = `\ls -lrt scripts | awk '{print $NF}' | awk -F '/' '{print $(NF-1)}' `
      		if ($VERSION != $LINK_DIR) then
          		echo "remove link:        $LINK_DIR"
#	  		unlink scripts
   			if (-e /bespace/users/be_repository/ns_flow/$VERSION/scripts) then
	  			echo "create link to scripts: /bespace/users/be_repository/ns_flow/$VERSION/scripts "
          			ln -sf /bespace/users/be_repository/ns_flow/$VERSION/scripts .
			else if (-e /ex-bespace/users/be_repository/ns_flow/$VERSION/scripts) then
	  			echo "create link to scripts: /ex-bespace/users/be_repository/ns_flow/$VERSION/scripts "
          			ln -sf /ex-bespace/users/be_repository/ns_flow/$VERSION/scripts .
			else
				echo "ERROR: missing /bespace/users/be_repository/ns_flow/$VERSION/scripts or /ex-bespace/..."
			endif
      		endif
   	else   
      		echo "####################################################################################################\n"
      		echo "Warning: scripts is not link to be_repository"
      		echo "         you Should use local scripts instead"
      		echo "####################################################################################################\n"
		sleep 3
   	endif   
	
    endif

endif

 


####################################################################################################################################
##   Parse args
####################################################################################################################################
source ./scripts/bin/parse_args.csh fusion $argv 

if ( $is_exit  == "true" ) then
    exit 2
endif


echo "stages: $stages"
echo "k8s $k8s"
if ($k8s == "true" ) then
   if ($desc == "None") then
       set desc = `echo $PWD | awk -F'/' '{print $NF}' | cut -c1-20 | tr "[:upper:]" "[:lower:]"`
   else
       set desc = `echo $desc | tr "[:upper:]" "[:lower:]"`
   endif
   
   if ($open != "None" || $report_only == "true") then
       source ./scripts/bin/k8s_launcher.csh fusion $argv 
   else
       echo "#\!/bin/tcsh -fe" > k8s_dispatch.csh
       echo 'echo "dispetcher host is: $HOST" > COMMAND ' >> k8s_dispatch.csh
       echo 'echo "#------------------------------------------------------" >> COMMAND ' >> k8s_dispatch.csh
       echo "set memory = $memory" >> k8s_dispatch.csh
       echo "set cpu = $cpu" >> k8s_dispatch.csh
       echo "set desc = $desc" >> k8s_dispatch.csh
       echo "set open = $open" >> k8s_dispatch.csh
       echo "set manual_fp = $manual_fp" >> k8s_dispatch.csh
       echo "set interactive = $interactive" >> k8s_dispatch.csh
       echo "set vnc_display = $vnc_display" >> k8s_dispatch.csh
       echo "set vnc_server = $vnc_server" >> k8s_dispatch.csh
       echo "set win = $win" >> k8s_dispatch.csh
       echo "set label = $label" >> k8s_dispatch.csh
       echo "set terminal = $terminal" >> k8s_dispatch.csh
       echo "set tail = $tail" >> k8s_dispatch.csh
       echo "set ccc = 0" >> k8s_dispatch.csh
       echo "foreach stage (`echo $stages`)" >> k8s_dispatch.csh
       echo '   set AAA = `echo '$argv' | perl -pe "s/-stages \S+//;"`' >> k8s_dispatch.csh
       echo '   echo "running stage $stage ." >> COMMAND' >> k8s_dispatch.csh
       echo '   source ./scripts/bin/k8s_launcher.csh fusion $AAA -stages $stage ' >> k8s_dispatch.csh
#   get running parameters , LOG / HOST / COMMAND
#       echo '   echo "cmd: $cmd" >> COMMAND' >> k8s_dispatch.csh
       echo '   set host = $host__' >> k8s_dispatch.csh
       echo '   echo host : $host >> COMMAND' >> k8s_dispatch.csh
       echo '   while (`nextk8s list -regex $host__ | grep $host__ | grep Pending | wc -l`) ' >> k8s_dispatch.csh
       echo '      echo "`date` : host is Pending" >> COMMAND' >> k8s_dispatch.csh
       echo '	   sleep 60' >> k8s_dispatch.csh
       echo '   end' >> k8s_dispatch.csh
       echo '   if (`nextk8s list -regex $host__ | grep $host__ | grep Running | wc -l`) then' >> k8s_dispatch.csh
       echo '         echo "Info: Host $host__ is Running."' >> k8s_dispatch.csh
       echo '         echo "Info: Host $host__ is Running." >> COMMAND' >> k8s_dispatch.csh
       echo '   else' >> k8s_dispatch.csh
       echo '         echo "Error: Host $host__ is not Running.   exit"' >> k8s_dispatch.csh
       echo '         echo "Error: Host $host__ is not Running.   exit" >> COMMAND' >> k8s_dispatch.csh
       echo '         sleep 3' >> k8s_dispatch.csh
       echo '         exit 1' >> k8s_dispatch.csh
       echo '   endif' >> k8s_dispatch.csh
	   
       echo '   sleep 120' >> k8s_dispatch.csh
#       echo '	set host_ = `grep -m1 nextk8s $last_log | awk '\''{print $2}'\''`' >> k8s_dispatch.csh
#       echo '	set host  = `echo $host_ | awk -F"-" '\''{$NF="" ; print $0}'\'' | perl -pe '\''s/ /-/g;s/-$//'\''`' >> k8s_dispatch.csh
       echo '   set last_log = `\ls -tr log/do_${stage}.log.full | grep -v logv | tail -1`  ' >> k8s_dispatch.csh
       echo '   echo log file : $last_log >> COMMAND' >> k8s_dispatch.csh
       
       echo '   while ( ! -f .${stage}_done)' >> k8s_dispatch.csh
       # search for Errors in the log file. 
       ################################################
       # check if pod exists. 
       echo '      if (`echo $host | grep nextk8s | wc -l` == 0) then' >> k8s_dispatch.csh
       echo '         echo "Warning: unknown host. no active checkers."' >> k8s_dispatch.csh
       echo '         echo "Warning: unknown host. no active checkers" >> COMMAND' >> k8s_dispatch.csh
       echo '      else' >> k8s_dispatch.csh
       echo '         if (`nextk8s list -regex $host | grep -v list | grep $host | wc -l ` == 0) then' >> k8s_dispatch.csh
       echo '       	 echo "Host $host does not exists and stage $stage is not done"' >> k8s_dispatch.csh
       echo '       	 echo "Host $host does not exists and stage $stage is not done" > log/ERROR.log' >> k8s_dispatch.csh
       echo '       	 echo "Host $host does not exists and stage $stage is not done" >> COMMAND' >> k8s_dispatch.csh
       echo '       	 set subject = "\047 BE_ERROR - $stage \047 "'	>> k8s_dispatch.csh
       echo '       	 set pwd = `/bin/pwd`'	>> k8s_dispatch.csh
       echo '       	 set address = `tclsh scripts/bin/get_mails.tcl` '  >> k8s_dispatch.csh
       echo '       	 set cmd = "exec echo -I- Running Failed: $pwd | mail -r BE_Run_Error@nextsilicon.com -s $subject -a log/ERROR.log $address" ' >> k8s_dispatch.csh
       echo '       	 eval $cmd ' >> k8s_dispatch.csh
       echo '	   	 sleep 20' >> k8s_dispatch.csh
       echo '       	 exit 1' >> k8s_dispatch.csh
       echo '         endif' >> k8s_dispatch.csh

       # check if log has -E- No $stage done. 
       echo '	      if (`grep "\-E\- No" $last_log | grep "_done found. Make sure" | wc -l`) then' >> k8s_dispatch.csh
       echo '	   	 echo `grep "\-E\- No" $last_log | grep "_done found. Make sure"`' >> k8s_dispatch.csh
       echo '	   	 echo `grep "\-E\- No" $last_log | grep "_done found. Make sure" ` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	   	 echo `grep "\-E\- No" $last_log | grep "_done found. Make sure" ` >> COMMAND' >> k8s_dispatch.csh
       echo '	   	 set subject = "\047 BE_ERROR - $stage\047 "'	>> k8s_dispatch.csh
       echo '	   	 set pwd = `/bin/pwd`'	>> k8s_dispatch.csh
       echo '	   	 set address = `tclsh scripts/bin/get_mails.tcl` '  >> k8s_dispatch.csh
       echo '	   	 set cmd = "exec echo -I- Running Failed: $pwd | mail -r BE_Run_Error@nextsilicon.com -s $subject -a log/ERROR.log $address" ' >> k8s_dispatch.csh
       echo '	   	 eval $cmd ' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
           echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       endif
       echo '	   	sleep 20' >> k8s_dispatch.csh
       echo '	   	 exit 1' >> k8s_dispatch.csh
       echo '	      endif' >> k8s_dispatch.csh
       
       # check if log has stopped at line. 
       echo '	     if (`grep "stopped at line" $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '		grep -B4 "stopped at line" $last_log | sed "s/[{}]//g" ' >> k8s_dispatch.csh
       echo '		grep -B4 "stopped at line" $last_log | sed "s/[{}]//g" > log/ERROR.log' >> k8s_dispatch.csh
       echo '		echo `grep  "stopped at line" $last_log` >> COMMAND' >> k8s_dispatch.csh
       echo '		set subject = "\047 BE_ERROR  $stage\047 "'	>> k8s_dispatch.csh
       echo '		set pwd = `/bin/pwd`'	>> k8s_dispatch.csh
       echo '		set address = `tclsh scripts/bin/get_mails.tcl` '  >> k8s_dispatch.csh
       echo '		set cmd = "exec echo -I- Running Failed: $pwd | mail -r BE_Run_Error@nextsilicon.com -s $subject -a log/ERROR.log $address" ' >> k8s_dispatch.csh
       echo '		eval $cmd ' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
           echo '		/tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
       endif
       echo '	   	sleep 20' >> k8s_dispatch.csh
       echo '		exit 1' >> k8s_dispatch.csh
       echo '	     endif' >> k8s_dispatch.csh

       # check if log have  Error: can't read \S+: no such variable. 
       echo '	     if (`grep -P "Error: can\S+ read \S+: no such variable" $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '		echo `grep -P -B2 -A10 "Error: can\S+ read \S+: no such variable" $last_log`' >> k8s_dispatch.csh
       echo '		echo `grep -P -B2 -A10 "Error: can\S+ read \S+: no such variable" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
       echo '		echo `grep -P "Error: can\S+ read \S+: no such variable" $last_log` >> COMMAND' >> k8s_dispatch.csh
       echo '		set subject = "\047 BE_ERROR  $stage\047 "'	>> k8s_dispatch.csh
       echo '		set pwd = `/bin/pwd`'	>> k8s_dispatch.csh
       echo '		set address = `tclsh scripts/bin/get_mails.tcl` '  >> k8s_dispatch.csh
       echo '		set cmd = "exec echo -I- Running Failed: $pwd | mail -r BE_Run_Error@nextsilicon.com -s $subject -a log/ERROR.log $address" ' >> k8s_dispatch.csh
       echo '		eval $cmd ' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
       echo '		/tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
           endif
       echo '	   	sleep 20' >> k8s_dispatch.csh
       echo '		exit 1' >> k8s_dispatch.csh
       echo '	     endif' >> k8s_dispatch.csh

       
       
#       # check if log have  IMPDF-200 Warning. 
#       echo '	      if (`egrep -w "IMPDF-200" $last_log | wc -l`) then' >> k8s_dispatch.csh
#       echo '	   	 echo `egrep -w -B2 "IMPDF-200" $last_log`' >> k8s_dispatch.csh
#       echo '	   	 echo `egrep -w -B2 "IMPDF-200" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
#       echo '	   	 echo `egrep -w "IMPDF-200" $last_log` >> COMMAND' >> k8s_dispatch.csh
#       echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
#       echo '	   	 exit 1' >> k8s_dispatch.csh
#       echo '	      endif' >> k8s_dispatch.csh
#       
#       # check if log have  IMPVL-346 Warning. 
#       echo '	      if (`egrep -w "IMPVL-346 " $last_log | wc -l`) then' >> k8s_dispatch.csh
#       echo '	   	 echo `egrep -w -B2 "IMPVL-346" $last_log`' >> k8s_dispatch.csh
#       echo '	   	 echo `egrep -w -B2 "IMPVL-346" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
#       echo '	   	 echo `egrep -w "IMPVL-346" $last_log` >> COMMAND' >> k8s_dispatch.csh
#       echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
#       echo '	   	 exit 1' >> k8s_dispatch.csh
#       echo '	      endif' >> k8s_dispatch.csh
#       
#       # check if log have  IMPDB-2504  Warning. 
#       echo '	      if (`egrep -w "IMPDB-2504 " $last_log | wc -l`) then' >> k8s_dispatch.csh
#       echo '	   	 echo `egrep -w -B2 "IMPDB-2504" $last_log`' >> k8s_dispatch.csh
#       echo '	   	 echo `egrep -w -B2 "IMPDB-2504" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
#       echo '	   	 echo `egrep -w "IMPDB-2504" $last_log` >> COMMAND' >> k8s_dispatch.csh
#       echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
#       echo '	   	 exit 1' >> k8s_dispatch.csh
#       echo '	      endif' >> k8s_dispatch.csh
#
#       # check if log have  CTS-036  Warning. 
       echo '	      if (`egrep -w "CTS-036" $last_log | wc -l`) then' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "CTS-036" $last_log`' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w -B2 "CTS-036" $last_log` > log/ERROR.log' >> k8s_dispatch.csh
       echo '	   	 echo `egrep -w "CTS-036" $last_log` >> COMMAND' >> k8s_dispatch.csh
       echo '	   	 set subject = "\047 BE_ERROR - $stage\047 "'	>> k8s_dispatch.csh
       echo '	   	 set pwd = `/bin/pwd`'	>> k8s_dispatch.csh
       echo '	   	 set address = `tclsh scripts/bin/get_mails.tcl` '  >> k8s_dispatch.csh
       echo '	   	 set cmd = "exec echo -I- Running Failed: $pwd | mail -r BE_Run_Error@nextsilicon.com -s $subject -a log/ERROR.log $address" ' >> k8s_dispatch.csh
       echo '	   	 eval $cmd ' >> k8s_dispatch.csh
       if ($interactive == "false" && $win == "false") then
       echo '	   	 /tools/common/bin/nextk8s kill -regex $host' >> k8s_dispatch.csh
           endif
       echo '	   	sleep 20' >> k8s_dispatch.csh
       echo '	   	 exit 1' >> k8s_dispatch.csh
       echo '	      endif' >> k8s_dispatch.csh
       echo '	   endif' >> k8s_dispatch.csh
       
       
       # wait 300 sec and check again
       echo '	   if ($ccc == 0) then' >> k8s_dispatch.csh
       echo '	      echo "`date` : waiting for ${stage}_done" >> COMMAND' >> k8s_dispatch.csh
       echo '	      sleep 180' >> k8s_dispatch.csh
       echo '	   else' >> k8s_dispatch.csh
       echo '	      @ ccc = $ccc + 1' >> k8s_dispatch.csh
       echo '	      sleep 180' >> k8s_dispatch.csh
       echo '	   endif' >> k8s_dispatch.csh
       echo '	   if ($ccc == 10) then' >> k8s_dispatch.csh
       echo '	      set ccc = 0' >> k8s_dispatch.csh
       echo '	   endif' >> k8s_dispatch.csh
       
       echo '	end' >> k8s_dispatch.csh
       echo '	echo STAGE $stage done >> COMMAND' >> k8s_dispatch.csh
       echo '	source ./scripts/bin/run_db.csh $stage & ' >> k8s_dispatch.csh
       echo 'end' >> k8s_dispatch.csh

       echo 'sleep 3' >> k8s_dispatch.csh
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
          /tools/common/bin/nextk8s run -command "$COMMAND" -label hw-be -working-dir $PWD -cpu-limit 1 -cpu 0.1 -desc $desc -memory 1 -tail  -queue-name backend -queue-mode
       else
          /tools/common/bin/nextk8s run -command "$COMMAND" -label hw-be -working-dir $PWD -cpu-limit 1 -cpu 0.1 -desc $desc -memory 1  -queue-name backend -queue-mode
       endif
   
   endif
   sleep 3
   exit 0

endif

####################################################################################################################################
##  Load modules
####################################################################################################################################
module unload snps/fusioncompiler snps/prime snps/icvalidator snps/prime snps/starrc

module load snps/prime/V-2023.12-SP5-1 snps/starrc/V-2023.12-SP5-2 
module load snps/icvalidator/V-2023.12-SP5-11


if ($tool_version != "None") then
    
    if (`(module avail snps/fusioncompiler/$tool_version) | & grep $tool_version | wc -l` > 0 ) then
        echo "Info: Fusion version $tool_version"
	module load snps/fusioncompiler/$tool_version
    else 
        echo "Info: Fusion version V-2023.12-SP5-5"
        module load snps/fusioncompiler/V-2023.12-SP5-5 
    endif
    
else
   module load snps/fusioncompiler/V-2023.12-SP5-5 
endif


# HOT FIX for X version
if (`which fc_shell | grep "X-2025" | wc -l`) then
	setenv LD_PRELOAD /lib64/libudev.so.1
endif

#-----------------------------------
# mkdir
#-----------------------------------
mkdir -pv grafana sourced_scripts reports/elab out/netlist out/lib  out/floorplan out/svf out/sdc out/def out/lef out/oas scripts_local log

#-----------------------------------
# Run
#-----------------------------------



####################################################################################################################################
##   definig stages to run
####################################################################################################################################
#set STAGES = ""
#set STAGES = "$STAGES init"
#set STAGES = "$STAGES compile"
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
    set OPEN_SCRIPT = "./scripts/do_fc_openblock.tcl"
endif
if ($?local && `echo $local | egrep "true|report_only" | wc -l`) then
    set REPORT_SCRIPT = "./scripts_local/do_fc_reportonly.tcl"
else
    set REPORT_SCRIPT = "./scripts/do_fc_reportonly.tcl"
endif
if ($?local && `echo $local | egrep "true|init" | wc -l`) then
    set INIT_SCRIPT = "./scripts_local/do_fc_init.tcl"
else
    set INIT_SCRIPT = "./scripts/do_fc_init.tcl"
endif
if ($?local && `echo $local | egrep "true|compile" | wc -l`) then
    set COMPILE_SCRIPT = "./scripts_local/do_fc_compile.tcl"
else
    set COMPILE_SCRIPT = "./scripts/do_fc_compile.tcl"
endif
if ($?local && `echo $local | egrep "true|place" | wc -l`) then
    set PLACE_SCRIPT = "./scripts_local/do_fc_place.tcl"
else
    set PLACE_SCRIPT = "./scripts/do_fc_place.tcl"
endif
if ($?local && `echo $local | egrep "true|cts" | wc -l`) then
    set CTS_SCRIPT = "./scripts_local/do_fc_cts.tcl"
else
    set CTS_SCRIPT = "./scripts/do_fc_cts.tcl"
endif
if ($?local && `echo $local | egrep "true|route" | wc -l`) then
    set ROUTE_SCRIPT = "./scripts_local/do_fc_route.tcl"
else
    set ROUTE_SCRIPT = "./scripts/do_fc_route.tcl"
endif
if ($?local && `echo $local | egrep "true|eco" | wc -l`) then
    set ECO_SCRIPT = "./scripts_local/do_fc_eco.tcl"
else
    set ECO_SCRIPT = "./scripts/do_fc_eco.tcl"
endif
if ($?local && `echo $local | egrep "true|chip_finish" | wc -l`) then
    set CHIP_FINISH_SCRIPT = "./scripts_local/do_fc_chip_finish.tcl"
else
    set CHIP_FINISH_SCRIPT = "./scripts/do_fc_chip_finish.tcl"
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
else if ($report_only == "true") then
      set STAGE_TO_REPORT = $stages
      set STAGES = "report_only"
      set force  = "true"
      echo "set STAGE_TO_REPORT $stages" >> .tmp_user_inputs.tcl
      echo "set STAGE $stages      \n" >> .tmp_user_inputs.tcl  
 \cp -p .tmp_user_inputs.tcl report_user_inputs.tcl
else 
   if ($user_inputs == "false") then
 \cp -p .tmp_user_inputs.tcl user_inputs.tcl
   else
      echo "using existing user input file"
   endif
endif

\rm .tmp_user_inputs.tcl

####################################################################################################################################
##   execute stages 
####################################################################################################################################
foreach STAGE (`echo $STAGES`)
    echo "-I- Running $STAGE"
    set log_file = log/do_${STAGE}.log.full
    # Remove old done stage
    if ( -e .${STAGE}_done ) then
        \rm .${STAGE}_done
    endif
    if ( -e .${STAGE}_reports_done ) then
        \rm .${STAGE}_reports_done
    endif

    if ( $force == "false" ) then 
        if ($STAGE != "init") then
        # Check of previous stage is done
    	    if ( ! -e .${previous_stage}_done ) then
    		echo "-E- No .${previous_stage}_done found. Make sure $previous_stage is done, or use -force to overide this check"
    		echo "-E- No .${previous_stage}_done found. Make sure $previous_stage is done, or use -force to overide this check" > $log_file
    		sleep 3
		exit 1
    	    endif
    	endif
    endif
    set previous_stage = $STAGE
    
    if ($STAGE == "open") then
       set log_file = `whoami`_`date +%F.%T`
      fc_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./open_user_inputs.tcl ; \
                " \
	    -f $OPEN_SCRIPT | tee -i log/open_${log_file}.log
    
    else if ($STAGE == "report_only") then
       set log_file = `whoami`_`date +%F.%T`
      fc_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./report_user_inputs.tcl ; \
                " \
	    -f $REPORT_SCRIPT | tee -i log/reports_${log_file}.log


    else if ($STAGE == "init") then
       cp -pf $INIT_SCRIPT sourced_scripts/.
    
        fc_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./user_inputs.tcl ; \
                " \
	    -f ./sourced_scripts/do_fc_init.tcl | tee -i log/do_${STAGE}.log.full
    
    else if ($STAGE == "compile") then
        cp -pf $COMPILE_SCRIPT sourced_scripts/.
        fc_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./user_inputs.tcl ; \
                " \
	    -f ./sourced_scripts/do_fc_compile.tcl | tee -i log/do_${STAGE}.log.full
    
    else if ($STAGE == "place") then
        cp -pf $PLACE_SCRIPT sourced_scripts/.
        fc_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./user_inputs.tcl ; \
                " \
	    -f ./sourced_scripts/do_fc_place.tcl | tee -i log/do_${STAGE}.log.full

    else if ($STAGE == "cts") then
       cp -pf $CTS_SCRIPT sourced_scripts/.
       fc_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./user_inputs.tcl ; \
                " \
	    -f ./sourced_scripts/do_fc_cts.tcl | tee -i log/do_${STAGE}.log.full

    else if ($STAGE == "route") then
        cp -pf $ROUTE_SCRIPT sourced_scripts/.
        fc_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./user_inputs.tcl ; \
                " \
	    -f ./sourced_scripts/do_fc_route.tcl | tee -i log/do_${STAGE}.log.full

    else if ($STAGE == "chip_finish") then
        cp -pf $CHIP_FINISH_SCRIPT sourced_scripts/.
        fc_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./user_inputs.tcl ; \
                " \
	    -f ./sourced_scripts/do_fc_chip_finish.tcl | tee -i log/do_${STAGE}.log.full

    
    else if ($STAGE == "eco") then
        cp -pf $ECO_SCRIPT sourced_scripts/.
        fc_shell \
    	    -x " \
                #	WA: $WA_PATH \
                source -e -v ./user_inputs.tcl ; \
                " \
	    -f ./sourced_scripts/do_fc_eco.tcl | tee -i log/do_${STAGE}.log.full

    
    else if ($STAGE == "dummy") then
        set PNR_DIR = $PWD
        set DM_DIR = `echo $PWD  | perl -pe 's/pnr/dm/'`
        set DODPO_DIR = `echo $PWD  | perl -pe 's/pnr/dodpo/'`
        mkdir -pv $DM_DIR
        mkdir -pv $DODPO_DIR
        if ( ! -d $DM_DIR/scripts ) then
            \cp -rfp scripts $DM_DIR
        endif 
        if ( ! -d $DODPO_DIR/scripts ) then
            \cp -rfp scripts $DODPO_DIR
        endif 
	
        cd $DODPO_DIR
        if ( ! -f $DODPO_DIR/run_dodpo.csh ) then
	    set cmd = "./scripts/run/run_icv_drc.csh -type dodpo"
	    if ($win == "true") then
	        set cmd = "$cmd -win"        
	    endif
	    echo $cmd > run_dodpo.csh
	    
        endif
	\rm -f .dodpo_done
        source ./run_dodpo.csh 
        cd $DM_DIR
	set cmd = "./scripts/run/run_icv_drc.csh -type dm"
	if ($win == "true") then
	    set cmd = "$cmd -win"        
	endif
	echo $cmd > run_dm.csh
	\rm -f .dm_done
        source ./run_dm.csh
        cd $PNR_DIR
	while (! -e  ${DODPO_DIR}/.dodpo_done || ! -e ${DM_DIR}/.dm_done )
        	echo "-I- dummy not done"
		sleep 60
	end
        touch .dummy_done
    else if ($STAGE == "merge") then
        ./scripts/run/run_merge.csh
         touch .merge_done
    else if ($STAGE == "place1") then
    else if ($STAGE == "place1") then
    else if ($STAGE == "place1") then
    endif
    
    if ( -e .${STAGE}_done ) then
        echo "-I- $STAGE done with normal exit"
        if ($k8s == "false") then
		source ./scripts/bin/run_db.csh $STAGE &
	endif
    else
        echo "-E- $STAGE done with abnormal exit"
	sleep 3
        exit 1
    endif


    if ( `echo $HOST| egrep "nextk8s|argo" | wc -l` > 0) then
        echo "k8s: $k8s"
        source ./scripts/bin/k8s_launcher.csh profiler_update $STAGE
    endif
    echo "INFO: end stage $STAGE from stages $STAGES"
end
echo "INFO: normal exit"
sleep 3
exit 0

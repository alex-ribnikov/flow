#!/bin/csh -fe

set CPU_RATIO = 2.0
set MEM_RATIO = 1.5
set MEM_LIMIT_RATIO = 1.3
set MEM_USAGE_RATIO = 1.3


#------------------------------------------
# parse argument
#------------------------------------------

set TOOL = $argv[1]
set ARR = ()
set i = 1
while ($i < $#argv) 
  @ i++
  set ARR = ($ARR $argv[$i])
end

if ( ! $?open ) then 
   set open = "None"      
else
   if ($open == "") then
      set open = "None"      
   endif
endif

if ( ! $?report_only ) then 
   set report_only = "false"      
endif

if ( ! $?tail) then 
   set tail = "false"      
endif
if ( ! $?manual_fp) then 
   set manual_fp = "false"      
endif

if ( ! $?interactive) then 
   set interactive = "false"      
endif

if ( ! $?image) then 
   set image = "None"      
endif

#set i = 0
#while ($i < $#argv) 
#  @ i++
#  if ("$argv[$i]" == "-help") then
#        echo "-I- goto help"
#        goto HELP
#  endif
#  if ("$argv[$i]" == "-t" || "$argv[$i]" == "-tool") then
#        @ i++
#        set TOOL = $argv[$i]
#  endif
#end

#----------------------------------------------------
# tool variables 
#----------------------------------------------------
if ($TOOL == "genus") then
     set STAGE_ = "syn"
     set COMMAND = "./scripts/run/run_genus.csh "
else if ($TOOL == "rtla") then
     set STAGE_ = "syn"
     set COMMAND = "./scripts/run/run_rtla.csh "
else if ($TOOL == "dc") then
     set STAGE_ = "syn"
     set COMMAND = "./scripts/run/run_dc.csh "
else if ($TOOL == "pt") then
     set STAGE_ = "pt"
     set open = "None"
     set COMMAND = "./scripts/run/run_pt.csh -hosts nextk8s"
else if ($TOOL == "starrc") then
     set STAGE_ = "starrc"
     set COMMAND = "./scripts/run/run_starrc.csh "
else if ($TOOL == "icv_drc") then
     set STAGE_ = "drc"
     set COMMAND = "./scripts/run/run_icv_drc.csh "
else if ($TOOL == "drc") then
     set STAGE_ = "drc"
     set COMMAND = "./scripts/run/run_drc.csh "
else if ($TOOL == "lec") then
     set STAGE_ = $lec_mode
     set COMMAND = "./scripts/run/run_lec.csh "
     set open = "None"
else if ($TOOL == "fm") then
     set STAGE_ = $fm_mode
     set COMMAND = "./scripts/run/run_fm.csh "
else if ($TOOL == "rhsc") then
     set STAGE_ = $analyse_type
     set COMMAND = "./scripts/run/run_rhsc.csh "
else if ($TOOL == "lib_gen") then
     set STAGE_ = "lib_gen"
     set COMMAND = "./scripts/run/run_lib_generation.csh "
else if ($TOOL == "inn") then
     set COMMAND = "./scripts/run/run_inn.csh "
     if ( $open != "None" ) then
         if (! -f $open) then
 	    set STAGE_ = $open
	    echo "open $open . stages = $STAGE_"
	 else
	    set STAGE_ = "open"
         endif
     else
        set STAGE_ = $stage
     endif
else if ($TOOL == "fusion") then
     set COMMAND = "./scripts/run/run_fc.csh "
     if ( $open != "None" ) then
         if (! -f $open) then
 	    set STAGE_ = $open
	    echo "open $open . stages = $STAGE_"
	 else
	    set STAGE_ = "open"
         endif
     else if ($report_only == "true") then
        set STAGE_ = $stages
     else
        set STAGE_ = $stage
     endif
else if ($TOOL == "profiler_update") then
     set STAGE__ = $argv[2]
     goto PROFILER_UPDATE
     
endif



#----------------------------------------------------
# resource parser 
#----------------------------------------------------
set PROFILER = "NONE"
if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
if ($PROFILER != "NONE") then

   echo "k8s profiler: $PROFILER"
   if (`grep $STAGE_ $PROFILER | wc -l` == 0) then
       if ( $open == "None") then 
           echo "Warning: missing $STAGE_ stage for k8s_profiler. adding default values cpu $cpu , memory $memory"
           echo "$STAGE_ $cpu $memory" >> $PROFILER
       endif
   endif
   echo "ARR $ARR"
   ## overide value from argument
   if (`echo $ARR | grep "\-cpu " | wc -l` == 0) then
       set cpu__ = `cat $PROFILER | perl -pe 's/#.*//' | grep -w $STAGE_ | awk '{print $(NF-1)}'`
       echo "CPU from profiler: $cpu__ "
   else 
      set cpu__ = 0
   endif
   if (`echo $ARR | grep "\-memory " | wc -l` == 0) then
       set memory__ = `cat $PROFILER | perl -pe 's/#.*//' | grep -w $STAGE_ | awk '{print $NF}'`
       echo "MEMORY from profiler: $memory__ "
   else
      set memory__ = 0
   endif
   echo 1
   #if cpu/memory value is 0, use default value
   if ( ! $?cpu__ ) then 
   else
      if ($cpu__ == "" || $cpu__ == 0) then
         echo "cpu taken from default value $cpu"
         set cpu = $cpu
      else
         echo "cpu taken from profiler $cpu__"
         set cpu = $cpu__
      endif
   endif
   
   if ( ! $?memory__ ) then 
   else
      if ($memory__ == "" || $memory__ == 0) then
         echo "memory taken from default value $memory"
         set memory = $memory
      else
         echo "memory taken from profiler $memory__"
         set memory = $memory__
      endif
   endif
   



#   set K8S_CPU = `echo $cpu    | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
#   set K8S_MEM = `echo $memory | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`
else
   if ( $open == "None") then 
       if ( -d ../inter ) then
           echo "Warning: missing $STAGE_ stage in  ../inter/k8s_profiler. adding default values cpu $cpu , memory $memory"
           echo "$STAGE_ $cpu $memory" >> ../inter/k8s_profiler
       else
           echo "Warning: No ../inter folder . adding default values cpu $cpu , memory $memory to ./scripts_local/k8s_profiler"
	   if ( ! -d ./scripts_local ) then
	   	mkdir -pv scripts_local
	   endif
           echo "$STAGE_ $cpu $memory" >> ./scripts_local/k8s_profiler
       endif
   endif
endif

if ($report_only == "true") then 
   set memory = `echo "1.4 * $memory" | bc`
endif

set cmd = 'set K8S_CPU = `echo '$cpu' | awk '\'' { x=$1/'$CPU_RATIO';$1/'$CPU_RATIO'==int($1/'$CPU_RATIO') ? x=$1/'$CPU_RATIO' : x=int($1/'$CPU_RATIO')+1 ; printf x }'\''`'
eval "$cmd"
set cmd = 'set K8S_MEM = `echo '$memory' | awk '\'' { x=$1/'$MEM_RATIO';$1/'$MEM_RATIO'==int($1/'$MEM_RATIO') ? x=$1/'$MEM_RATIO' : x=int($1/'$MEM_RATIO')+1 ; printf x }'\''`'
eval "$cmd"
set cmd = 'set K8S_MEM_LIMIT = `echo '$memory' | awk '\'' { x=$1*'$MEM_LIMIT_RATIO';$1*'$MEM_LIMIT_RATIO'==int($1*'$MEM_LIMIT_RATIO') ? x=$1*'$MEM_LIMIT_RATIO' : x=int($1*'$MEM_LIMIT_RATIO')+1 ; printf x }'\''`'
eval "$cmd"

#set K8S_MEM_LIMIT = `echo $memory | awk '{x=$1*1.2; $1*1.2==int($1*1.2) ? x=$1*1.2 : x=int($1*1.2)+1 ; printf x"\n" }'`


echo "K8S_CPU $K8S_CPU limit $cpu"
echo "K8S_MEM $K8S_MEM limit $K8S_MEM_LIMIT"

#----------------------------------------------------
# remove arguments from command line 
#----------------------------------------------------

set AAA = `echo $ARR | perl -pe 's/-k8s true//;s/-k8s//;s/-desc \S+//;s/-tail//;s/-vnc_server \S+//;s/-vnc_display \S+//;s/-cpu \S+//;s/-memory \S+//;'`
set AAA = "$AAA -cpu $cpu -memory $memory -k8s false"

if ($desc == "None") then
   set desc = `echo $PWD | awk -F'/' '{print $NF}' | cut -c1-20 | tr "[:upper:]" "[:lower:]"`
else
   set desc = `echo $desc | tr "[:upper:]" "[:lower:]"`
endif

set BBB = `echo $PWD | awk -F'/' '{print $(NF-2)}' | tr "[:upper:]" "[:lower:]" `
#echo "k8s:  $k8s"
echo "desc: $desc"
echo "argv: $argv"
echo "ARR:  $ARR"
echo "AAA:  $AAA"
   
#----------------------------------------------------
# define command line 
#----------------------------------------------------
set COMMAND = "$COMMAND $AAA"
echo "COMMAND $COMMAND"
if ( $interactive == "true" || $win == "true" ||  $open != "None" || $manual_fp == "true" ) then
    echo " open terminal . interactive $interactive , win $win , open $open , manual_fp $manual_fp"
    if ($vnc_display == "None" || $vnc_server == "None") then
	echo "ERROR: missing vnc_display or vnc_server"
     	exit 1
    endif
    if ( $?NXT080) then
	if ( $NXT080 == "true") then
	    set terminal = "setenv NXT080 true && $terminal"
	endif
    endif
    set cmd = "nextk8s run -command 'sleep 4 && $terminal -e "\""$COMMAND"\""' -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc $desc -memory $K8S_MEM -memory-limit $K8S_MEM_LIMIT -x-display-num $vnc_display -vnc-server $vnc_server -block-name $BBB  -queue-name backend -queue-mode"
else
    set cmd = "nextk8s run -command '$COMMAND' -x-server -working-dir $PWD -cpu-limit $cpu -cpu $K8S_CPU -desc $desc -memory $K8S_MEM -memory-limit $K8S_MEM_LIMIT  -block-name $BBB  -queue-name backend -queue-mode"
    if ($tail == "true") then
       set cmd = "$cmd -tail"
    endif
endif


#----------------------------------------------------
#  run on a specific server define by label
#----------------------------------------------------
if ($label != "None") then
    set cmd = "$cmd -label $label"
endif

if ($image != "None") then
    set cmd = "$cmd -image $image"
endif


#----------------------------------------------------
#  run k8s
#----------------------------------------------------

echo $cmd
eval $cmd | tee kkk.txt
set host__ = `grep nextk8s kkk.txt | grep "creating job" | awk '{print $NF}'`
#echo "Host: $host__" >> COMMAND
echo "cmd: $cmd" >> COMMAND
grep http kkk.txt >> COMMAND
\rm kkk.txt

goto END

PROFILER_UPDATE:

echo "Info: profiler update"
set MEM_USAGE = `curl -s -g https://prometheus.k8s.nextsilicon.com/api/v1/query --data-urlencode 'query=max_over_time(container_memory_working_set_bytes{pod="'$HOST'",container="hw-ldap"}[14d])' | jq '.data.result[].value[1]' | perl -pe 's/"//g' | awk '{print $1/1024.0/1024.0/1024.0}'`
if ( $MEM_USAGE == "") then
    echo "WARNING  MEM USAGE unavailable for pod $HOST from containeer hw-ldap"
else
#    set MEM_USAGE_20 = `echo $MEM_USAGE | awk '{print $1*1.2}'`
    set PPP = `echo $MEM_USAGE_RATIO | awk '{x=$1*100 - 100 ; print x}'`
    set cmd = 'set MEM_USAGE_20 =  `echo '$MEM_USAGE' | awk '\'' { x = int ($1*'$MEM_USAGE_RATIO')+1 ; print x } '\''`'
    eval "$cmd"
    
    set PROFILER = "NONE"
    if ( -f ../inter/k8s_profiler) set PROFILER = "../inter/k8s_profiler"
    if ( -f ./scripts_local/k8s_profiler) set PROFILER = "scripts_local/k8s_profiler"
    if ($PROFILER != "NONE") then
       \cp $PROFILER ${PROFILER}.${STAGE__}_old
       if (`cat $PROFILER | perl -pe 's/#.*//' | grep $STAGE__ | wc -l` > 0) then
	  echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in k8s profiler $PROFILER to $MEM_USAGE_20   (usage + $PPP%)"
	  set cmd = 'perl -p -i -e '\''s/('^${STAGE__}' \d+) \d+/$1 '$MEM_USAGE_20'/'\'' '$PROFILER
#	  echo $cmd
	  eval $cmd
       else
	    echo "WARNING: stage $STAGE__ does not exists in profiler $PROFILER."
	    echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in k8s profiler $PROFILER to $MEM_USAGE_20   (usage + $PPP%)"
	    echo "${STAGE__} $cpu $MEM_USAGE_20" >> $PROFILER
       
       endif
       
    else
	if ( -d ../inter) then
	    echo "INFO: memory usage for run is $MEM_USAGE .  update memory usage in ../inter/k8s_profiler to $MEM_USAGE_20   (usage + $PPP%)"
	    echo "${STAGE__} $cpu $MEM_USAGE_20" >> ../inter/k8s_profiler
	else
	    echo "WARNING: memory usage for run is $MEM_USAGE .  update memory usage in ./scripts_local/k8s_profiler to $MEM_USAGE_20	(usage + $PPP%)"
	    echo "${STAGE__} $cpu $MEM_USAGE_20" >> ./scripts_local/k8s_profiler
	endif
    endif
endif

END:

#!/bin/csh
#################################################################################################################################################
#																		#
#	this script will run Argo on BE flow  													#
#																		#
#																		#
#	 Var	date of change	owner		 comment											#
#	----	--------------	-------	 ---------------------------------------------------------------					#
#	0.1	02/02/2023	Royl	initial script												#
#																		#
#																		#
#################################################################################################################################################
# find location for scripts directory
if (-d scripts) then
    set script_dir="scripts"
else

    set called =($_)
    if ("$called" != "") then
        set script_fn=`readlink -f $called[2]`
    else
        set script_fn=`readlink -f $0`
    endif
    set script_dir=`dirname $script_fn`
    if (`echo $script_dir | grep "/scripts/run/" | wc -l`) then
        set script_dir=`echo $script_dir | perl -pe 's#/run$##'`
    else
        echo "Error: scripts directory is unknown. please run this file from scripts/run/run_argo.csh
	exit 0
    endif
endif

#-----------------------------------
# Parsing flags
#-----------------------------------
#setenv BEROOT   `git rev-parse --show-toplevel` ; # <This is where your "nextflow" folder is>

#source ../../../../ns_flow/scripts/bin/parse_args.csh argo $argv 
source ${script_dir}/bin/parse_args.csh argo $argv

if ( $is_exit  == "true" ) then
    exit 2
endif


#-----------------------------------
# profiler for compute resources
#-----------------------------------
if ($profiler == "None") then
   if ( -f ../inter/k8s_profiler) set profiler = "../inter/k8s_profiler"
   if ( -f inter/k8s_profiler) set profiler = "inter/k8s_profiler"
   if ( -f scripts_local/k8s_profiler) set profiler = "scripts_local/k8s_profiler"
else
   set profiler = `realpath $profiler`
endif
if ($profiler == "None") then
      echo "Error: argo missing profiler"
      exit 1
endif

echo "k8s profiler: $profiler"

#-----------------------------------
# define stages
#-----------------------------------
if ( "$stages" != "None" ) then 
   set stages  = ($stages:as/,/ /)        
endif

if ($eco == "true" ) then
   set stages = "eco chip_finish dummy starrc pt"
   if ($eco_num == "None") then
      echo "ERROR: missing eco_num"
      exit 1
   endif
   if ($drc == "true") set stages = "$stages drc"
   if ($ant == "true") set stages = "$stages ant"
   if ($lvs == "true") set stages = "$stages lvs"
endif

if ($pnr == "true" ) then
   set stages = "floorplan place cts route chip_finish"
endif

#-----------------------------------
# remove argument related to argo
#-----------------------------------
set AAA = `echo $argv | perl -pe 's/-eco_num \d+//;s/-eco//;s/-ant//;s/-lvs//;s/-pnr//;s/-drc//;s/-desc \S+//;s/-stages \S+//;s/-create_folder//;'`
echo $AAA

#-----------------------------------
# define working dir
#-----------------------------------
set EXIT_FLAG = false

if ($working_dir == "None") then
   set working_dir = $PWD
else
   set working_dir = `realpath $working_dir`
endif

if (`echo $working_dir | perl -pe '#/# #g' | awk '{print $NF}' | grep pnr | wc -l `) then
   set pnr_working_dir = $working_dir
   set syn_working_dir = `echo $working_dir | perl -pe 's/pnr_(\S+)/syn_\1/;s/syn$/starrc/'`
   set starrc_working_dir = `echo $working_dir | perl -pe 's/pnr_(\S+)/starrc_\1/;s/pnr$/starrc/'`
   set pt_working_dir   = `echo $working_dir | perl -pe 's/pnr_(\S+)/pt_\1/;s/pnr$/pt/'`
   set drc_working_dir  = `echo $working_dir | perl -pe 's/pnr_(\S+)/drc_\1/;s/pnr$/drc/'`
   set ant_working_dir  = `echo $working_dir | perl -pe 's/pnr_(\S+)/ant_\1/;s/pnr$/ant/'`
   set lvs_working_dir  = `echo $working_dir | perl -pe 's/pnr_(\S+)/lvs_\1/;s/pnr$/lvs/'`
   set rhsc_working_dir = `echo $working_dir | perl -pe 's/pnr_(\S+)/rhsc_\1/;s/rhsc$/lvs/'`
else
   set syn_working_dir = "$working_dir/syn"
   set pnr_working_dir = "$working_dir/pnr"
   set starrc_working_dir = "$working_dir/starrc"
   set pt_working_dir   = "$working_dir/pt"
   set drc_working_dir  = "$working_dir/drc"
   set ant_working_dir  = "$working_dir/ant"
   set lvs_working_dir  = "$working_dir/lvs"
   set rhsc_working_dir = "$working_dir/rhsc"
endif


#-----------------------------------
# create argo yaml
#-----------------------------------
\cp -p ${script_dir}/templates/argo.yaml .
set cmd = "perl -p -i -e 's#WORKING_DIR#$working_dir#' argo.yaml"
eval $cmd

set i = 0
foreach stage (`echo $stages`)
   set K8S_MEM = `cat $profiler | perl -pe 's/#.*//' | grep $stage | awk '{print $NF}'`
   set K8S_CPU = `cat $profiler | perl -pe 's/#.*//' | grep $stage | awk '{print $(NF-1)}'`
   set K8S_CPU_r = `echo $K8S_CPU | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
   echo "$stage"
   switch  ($stage) 
      case "syn": 
	 echo "- type: genus" >> argo.yaml
     	 echo "  command: cd $syn_working_dir && ./run_genus.csh $AAA" >> argo.yaml
     	 echo "  name: pnr-floorplan" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
     	 breaksw
      case "floorplan": 
	 echo "- type: innovus" >> argo.yaml
     	 echo "  command: cd $pnr_working_dir && ./run_inn.csh -cpu $K8S_CPU -stages floorplan $AAA" >> argo.yaml
     	 echo "  name: pnr-floorplan" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
     	 breaksw
     case "place": 
	 echo "- type: innovus" >> argo.yaml
     	 echo "  command: cd $pnr_working_dir && ./run_inn.csh -cpu $K8S_CPU -stages place $AAA" >> argo.yaml
     	 echo "  name: pnr-place" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "innovus-floorplan"
     	 breaksw
     case "cts": 
	 echo "- type: innovus" >> argo.yaml
     	 echo "  command: cd $pnr_working_dir && ./run_inn.csh -cpu $K8S_CPU -stages cts $AAA" >> argo.yaml
     	 echo "  name: pnr-cts" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "innovus-place"
     	 breaksw
     case "route": 
	 echo "- type: innovus" >> argo.yaml
     	 echo "  command: cd $pnr_working_dir && ./run_inn.csh -cpu $K8S_CPU -stages route $AAA" >> argo.yaml
     	 echo "  name: pnr-route" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "innovus-cts"
     	 breaksw
      case "eco": 
	 echo "- type: innovus"  >> argo.yaml
     	 echo "  command: cd $pnr_working_dir && ./run_inn.csh -stages eco -eco_num $eco_num $AAA"  >> argo.yaml
     	 echo "  name: pnr-eco"  >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
     	 breaksw
      case "chip_finish": 
	 echo "- type: innovus" >> argo.yaml
	 if (`echo $stages | grep route| wc -l`) then
     	    echo "  command: cd $pnr_working_dir && ./run_inn.csh -stages chip_finish $AAA" >> argo.yaml
            set dependence = "innovus-pnr-route"
	 else
      	   echo "  command: cd $pnr_working_dir && ./run_inn.csh -stages chip_finish -eco_num $eco_num $AAA" >> argo.yaml
           set dependence = "innovus-pnr-eco"
	 endif
     	 echo "  name: pnr-chip-finish" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
     	 breaksw
      case "dummy": 
	 echo "- type: calibre" >> argo.yaml
     	 echo "  command: cd $pnr_working_dir && ./run_inn.csh -stages dummy" >> argo.yaml
     	 echo "  name: dummy" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "innovus-pnr-chip-finish"
     	 breaksw
      
      case "starrc": 
         if (! -d $starrc_working_dir) then
	    if ($create_folder == "false") then
                echo "ERROR: folder $starrc_working_dir does not exists"
	        set EXIT_FLAG = "true"
	    else
                echo "WARNING: folder $starrc_working_dir  is created"
	        mkdir $starrc_working_dir
                cd $starrc_working_dir
	\cp -rfp ${pnr_working_dir}/scripts* .
	\cp -p scripts/run/run_starrc.csh .
		cd $working_dir
	    endif
	 endif
     	 echo "- type: starrc" >> argo.yaml
     	 echo "  command: cd $starrc_working_dir && run_starrc.csh" >> argo.yaml
     	 echo "  name: starrc" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "calibre-dummy"
     	 breaksw
      
      case "pt": 
         if (! -d $pt_working_dir) then
	    if ($create_folder == "false") then
                echo "ERROR: folder $pt_working_dir does not exists"
	        set EXIT_FLAG = "true"
	    else
                echo "WARNING: folder $pt_working_dir  is created"
	        mkdir $pt_working_dir
                cd $pt_working_dir
	\cp -rfp ${pnr_working_dir}/scripts* .
	\cp -p scripts/run/run_pt.csh .
		cd $working_dir
	    endif
	 endif
     	 echo "- type: pt" >> argo.yaml
     	 echo "  command: cd $pt_working_dir && run_pt.csh -cpu $K8S_CPU -memory ${K8S_MEM} -hosts nextk8s" >> argo.yaml
     	 echo "  name: pt" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
          set dependence = "starrc-starrc"
     	 breaksw
      case "merge": 
	 echo "- type: innovus" >> argo.yaml
     	 echo "  command: cd $pnr_working_dir && ./run_inn.csh -stages merge" >> argo.yaml
     	 echo "  name: merge" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "calibre-dummy"
     	 breaksw
      case "drc": 
         if (! -d $drc_working_dir) then
	    if ($create_folder == "false") then
                echo "ERROR: folder $drc_working_dir does not exists"
	        set EXIT_FLAG = "true"
	    else
                echo "WARNING: folder $drc_working_dir  is created"
	        mkdir $drc_working_dir
                cd $drc_working_dir
	\cp -rfp ${pnr_working_dir}/scripts* .
	\cp -p scripts/run/run_drc.csh .
		cd $working_dir
	    endif
	 endif
	 echo "- type: calibre" >> argo.yaml
     	 echo "  command: cd $drc_working_dir && ./run_drc.csh" >> argo.yaml
     	 echo "  name: drc" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "innovus-merge"
     	 breaksw
      case "ant": 
         if (! -d $ant_working_dir) then
	    if ($create_folder == "false") then
                echo "ERROR: folder $ant_working_dir does not exists"
	        set EXIT_FLAG = "true"
	    else
                echo "WARNING: folder $ant_working_dir  is created"
	        mkdir $ant_working_dir
                cd $ant_working_dir
	\cp -rfp ${pnr_working_dir}/scripts* .
	\cp -p scripts/run/run_ant.csh .
		cd $working_dir
	    endif
	 endif
	 echo "- type: calibre" >> argo.yaml
     	 echo "  command: cd $ant_working_dir && ./run_ant.csh" >> argo.yaml
     	 echo "  name: ant" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "innovus-merge"
     	 breaksw
      case "lvs": 
         if (! -d $lvs_working_dir) then
	    if ($create_folder == "false") then
                echo "ERROR: folder $lvs_working_dir does not exists"
	        set EXIT_FLAG = "true"
	    else
                echo "WARNING: folder $lvs_working_dir  is created"
	        mkdir $lvs_working_dir
                cd $lvs_working_dir
	\cp -rfp ${pnr_working_dir}/scripts* .
	\cp -p scripts/run/run_lvs.csh .
		cd $working_dir
	    endif
	 endif
	 echo "- type: calibre" >> argo.yaml
     	 echo "  command: cd $lvs_working_dir && ./run_lvs.csh" >> argo.yaml
     	 echo "  name: lvs" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "innovus-merge"
     	 breaksw
      case "rhsc": 
         if (! -d $rhsc_working_dir) then
	    if ($create_folder == "false") then
                echo "ERROR: folder $rhsc_working_dir does not exists"
	        set EXIT_FLAG = "true"
	    else
                echo "WARNING: folder $rhsc_working_dir  is created"
	        mkdir $rhsc_working_dir
                cd $rhsc_working_dir
	\cp -rfp ${pnr_working_dir}/scripts* .
	\cp -p scripts/run/run_rhsc.csh .
		cd $working_dir
	    endif
	 endif
	 echo "- type: rhsc" >> argo.yaml
     	 echo "  command: cd $rhsc_working_dir && ./run_rhsc.csh" >> argo.yaml
     	 echo "  name: rhsc" >> argo.yaml
     	 echo "  cpu-request: $K8S_CPU_r" >> argo.yaml
     	 echo "  cpu-limit: $K8S_CPU" >> argo.yaml
     	 echo "  memory-request: ${K8S_MEM}Gi" >> argo.yaml
     	 echo "  memory-limit: ${K8S_MEM}Gi" >> argo.yaml
         set dependence = "pt-pt"
     	 breaksw
      default:
     	 breaksw
   endsw
   if ($i > 0) then
	echo "  dependencies:" >> argo.yaml
	echo "    - $dependence" >> argo.yaml
   endif
   
   echo "" >> argo.yaml
   
   @ i ++
end
if ($EXIT_FLAG == "false") then
    /bespace/users/nextRelease-be -block-config argo.yaml -release pnr
endif
 

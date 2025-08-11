#!/bin/csh
#################################################################################################################################################
#																		#
#	this script will run Jenksing docker   													#
#	to run need to define 															#
#																		#
#																		#
#	 Var	date of change	owner		 comment											#
#	----	--------------	-------	 ---------------------------------------------------------------					#
#	0.1	28/12/2021	Royl	initial script												#
#																		#
#																		#
#################################################################################################################################################
#xhost +

if (`echo $HOST | grep nxt-gw| wc -l`) then
	set XDISPLAY = `vncserver -list | tail -n1 | awk '{print $1}' | perl -pe 's/://'`
endif


set MEM = 60
set CPU = 16
set BG = black
set FG = SpringGreen3
set PWD_ = $PWD

####################################################################################################################################
##   shell arguments
####################################################################################################################################
#-----------------------------------
# Parsing flags
#-----------------------------------
set i = 0
while ($i < $#argv) 
  @ i++
  if ("$argv[$i]" == "-help") then
  	echo "-I- goto help"
   	goto HELP
  endif
  if ("$argv[$i]" == "-list") then
  	echo "-I- goto list"
   	goto LIST
  endif
  if ("$argv[$i]" == "-kill") then
   	@ i++
	set KILL = $argv[$i]
   	goto KILL
  endif
  if ("$argv[$i]" == "-cpu") then
   	@ i++
	set CPU = $argv[$i]
  endif
  if ("$argv[$i]" == "-cmd") then
   	@ i++
	set COMMAND = $argv[$i]
  endif
  if ("$argv[$i]" == "-mem") then
   	@ i++
	set MEM = $argv[$i]
  endif
  if ("$argv[$i]" == "-pwd") then
   	@ i++
	set PWD_ = $argv[$i]
  endif
  if ("$argv[$i]" == "-display") then
   	@ i++
	set XDISPLAY = $argv[$i]
  endif  
  if ("$argv[$i]" == "-fg") then
   	@ i++
	set FG = $argv[$i]
  endif  
  if ("$argv[$i]" == "-bg") then
   	@ i++
	set BG = $argv[$i]
  endif      
  if ("$argv[$i]" == "-stages") then
   	@ i++
	set STAGES = $argv[$i]
  endif      
  
  #### common genus and innovus flags
  if ("$argv[$i]" == "-ocv") then
	set OCV = "true"
  endif      
  if ("$argv[$i]" == "-scan") then
	set SCAN = "true"
  endif      
  if ("$argv[$i]" == "-useful_skew") then
	set USEFUL_SKEW = "true"
  endif      
  if ("$argv[$i]" == "-sdc_list") then
   	@ i++
	set SDC_LIST = $argv[$i]
  endif      
  
  
  #### innovus flags
  if ("$argv[$i]" == "-syn_dir") then
   	@ i++
	set SYN_DIR = $argv[$i]
  endif      
  if ("$argv[$i]" == "-scandef") then
   	@ i++
	set SCANDEF = $argv[$i]
  endif      
  if ("$argv[$i]" == "-eco_num") then
   	@ i++
	set ECO_NUM = $argv[$i]
  endif      
  if ("$argv[$i]" == "-eco_do") then
   	@ i++
	set ECO_DO = $argv[$i]
  endif      
  if ("$argv[$i]" == "-io_buffers_dir") then
   	@ i++
	set IO_BUFFERS_DIR = $argv[$i]
  endif      
  if ("$argv[$i]" == "-ecf") then
	set ECF = "true"
  endif      
  if ("$argv[$i]" == "-via_pillars") then
	set VIA_PILLARS = "true"
  endif      
  if ("$argv[$i]" == "-create_lib") then
	set CREATE_LIB = "true"
  endif      
  if ("$argv[$i]" == "-force") then
	set FORCE = "true"
  endif      
  if ("$argv[$i]" == "-local") then
	set LOCAL = "true"
  endif      
  
  
  #### genus flags
  if ("$argv[$i]" == "-nextinside") then
   	@ i++
	set NEXTINSIDE = $argv[$i]
  endif      
  if ("$argv[$i]" == "-def_file") then
   	@ i++
	set DEF_FILE = $argv[$i]
  endif      
  if ("$argv[$i]" == "-filelist") then
   	@ i++
	set FILELIST = $argv[$i]
  endif      
  if ("$argv[$i]" == "-flat_design") then
   	@ i++
	set FLAT_DESIGN = $argv[$i]
  endif      
  if ("$argv[$i]" == "-is_physical") then
	set IS_PHYSICAL = "true"
  endif      
  if ("$argv[$i]" == "-mbit") then
	set MBIT = "true"
  endif      
  if ("$argv[$i]" == "-is_hybrid") then
	set IS_HYBRID = "true"
  endif      
  if ("$argv[$i]" == "-remove_flops") then
	set REMOVE_FLOPS = "true"
  endif      
  if ("$argv[$i]" == "-error_on_blackbox_false") then
	set ERROR_ON_BLACKBOX = "false"
  endif      
  
  # PrimeTime flags
  if ("$argv[$i]" == "-xtalk") then
   	@ i++
	set XTALK = $argv[$i]
  endif      
  if ("$argv[$i]" == "-single") then
	set SINGLE = "true"
  endif      
  if ("$argv[$i]" == "-views") then
   	@ i++
	set VIEWS = $argv[$i]
  endif      
  if ("$argv[$i]" == "-eco") then
	set ECO = "true"
  endif      
  if ("$argv[$i]" == "-rh_out") then
	set RH_OUT = "true"
  endif      
  if ("$argv[$i]" == "-hosts") then
   	@ i++
	set HOSTS = $argv[$i]
  endif      
  if ("$argv[$i]" == "-netlist") then
   	@ i++
	set NETLIST = $argv[$i]
  endif      
  if ("$argv[$i]" == "-spef_dir") then
   	@ i++
	set SPEF_DIR = $argv[$i]
  endif      
  if ("$argv[$i]" == "-gpd_dir") then
   	@ i++
	set GPD_DIR = $argv[$i]
  endif      
  if ("$argv[$i]" == "-innovus_dir") then
   	@ i++
	set INNOVUS_DIR = $argv[$i]
  endif      
  if ("$argv[$i]" == "-spef_files") then
   	@ i++
	set SPEF_FILES = $argv[$i]
  endif      
  if ("$argv[$i]" == "-gpd_files") then
   	@ i++
	set GPD_FILES = $argv[$i]
  endif      

end


echo "-I- running with cpu: $CPU "
echo "-I- running with mem: $MEM "
if ($?XDISPLAY ) then 
	echo "-I- display num: $XDISPLAY "
endif
echo "-I- bg color: $BG "
echo "-I- fg color: $FG "
if (! $?COMMAND ) then 
	set COMMAND  = "xterm -sl 16000 -n  COMMAND -geometry 210x56 -bg $BG -fg $FG -title ${PWD_}_${CPU}CPU_${MEM}MEM -e csh"
endif
#set COMMAND  = "xterm -geometry 120x40 -bg white -fg black -e csh"
set DESCRIPTION = "xterm"
####################################################################################################################################
##   run stages
####################################################################################################################################
if  ($?STAGES) then
	set DESCRIPTION = `echo ${PWD_}_$STAGES | awk -F '/' '{print $NF}' | perl -pe 's/,/_/g'`
	set DESCRIPTION = `echo ${PWD_} | awk -F '/' '{print $NF}' | perl -pe 's/,/_/g'`
	if (`echo $STAGES | grep floorplan | wc -l` || `echo $STAGES | grep place | wc -l` || `echo $STAGES | grep cts | wc -l` || `echo $STAGES | grep route  | wc -l` || `echo $STAGES | grep eco  | wc -l` || `echo $STAGES | grep chip_finish  | wc -l` || `echo $STAGES | grep dummy  | wc -l` || `echo $STAGES | grep merge  | wc -l`) then
		if (`echo $STAGES | grep floorplan | wc -l` ) then
			echo "Error: cannot run synthesis and innovus at same time"
			exit 2
		endif
		#set COMMAND  = "$COMMAND -c '\''./run_inn.csh -cpu ${CPU} -stages $STAGES'\''"
		#set COMMAND  = "$COMMAND -c '\''./run_inn.csh -cpu ${CPU} -stages $STAGES'\''"
		set COMMAND = "./run_inn.csh -cpu ${CPU} -stages $STAGES"
	endif
	if (`echo $STAGES | grep inn | wc -l` ) then
		set COMMAND = "./run_inn.csh -cpu ${CPU}"
	endif
	if (`echo $STAGES | grep syn | wc -l` || `echo $STAGES | grep genus | wc -l`) then
		set COMMAND = "./run_genus.csh -cpu ${CPU}"
	endif
	if (`echo $STAGES | egrep "sta|pt" | wc -l` ) then
		set COMMAND = "./run_pt.csh "
	endif
endif 

####################################################################################################################################
##   innovus run
####################################################################################################################################
if (`echo $COMMAND | grep run_inn | wc -l` || `echo $COMMAND | grep run_genus | wc -l`) then
	if ($?SDC_LIST) then
		set COMMAND = "$COMMAND -sdc_list $SDC_LIST"
	endif
	if ($?USEFUL_SKEW) then
		set COMMAND = "$COMMAND -useful_skew"
	endif
	if ($?SCAN) then
		set COMMAND = "$COMMAND -scan"
	endif
	if ($?OCV) then
		set COMMAND = "$COMMAND -ocv"
	endif
	if ($?CREATE_LIB) then
		set COMMAND = "$COMMAND -create_lib"
	endif
endif

if (`echo $COMMAND | grep run_genus | wc -l`) then
	if ($?NEXTINSIDE) then
		set COMMAND = "$COMMAND -nextinside $NEXTINSIDE"
	endif
	if ($?DEF_FILE) then
		set COMMAND = "$COMMAND -def_file $DEF_FILE"
	endif
	if ($?FILELIST) then
		set COMMAND = "$COMMAND -filelist $FILELIST"
	endif
	if ($?FLAT_DESIGN) then
		set COMMAND = "$COMMAND -flat_design $FLAT_DESIGN"
	endif
	if ($?IS_PHYSICAL) then
		set COMMAND = "$COMMAND -is_physical"
	endif
	if ($?IS_HYBRID) then
		set COMMAND = "$COMMAND -is_hybrid"
	endif
	if ($?MBIT) then
		set COMMAND = "$COMMAND -mbit"
	endif
	if ($?REMOVE_FLOPS) then
		set COMMAND = "$COMMAND -remove_flops"
	endif
	if ($?ERROR_ON_BLACKBOX) then
		set COMMAND = "$COMMAND -error_on_blackbox false"
	endif
endif

if (`echo $COMMAND | grep run_inn | wc -l`) then
	if ($?SYN_DIR) then
		set COMMAND = "$COMMAND -syn_dir $SYN_DIR"
	endif
	if ($?SCANDEF) then
		set COMMAND = "$COMMAND -scandef $SCANDEF"
	endif
	if ($?ECO_NUM) then
		set COMMAND = "$COMMAND -eco_num $ECO_NUM"
	endif
	if ($?ECO_DO) then
		set COMMAND = "$COMMAND -eco_do $ECO_DO"
	endif
	if ($?IO_BUFFERS_DIR) then
		set COMMAND = "$COMMAND -io_buffers_dir $IO_BUFFERS_DIR"
	endif
	if ($?ECF) then
		set COMMAND = "$COMMAND -ecf"
	endif
	if ($?VIA_PILLARS) then
		set COMMAND = "$COMMAND -via_pillars"
	endif
	if ($?FORCE) then
		set COMMAND = "$COMMAND -force"
	endif
	if ($?LOCAL) then
		set COMMAND = "$COMMAND -local"
	endif
endif

if (`echo $COMMAND | grep run_pt | wc -l`) then
	if ($?CREATE_LIB) then
		set COMMAND = "$COMMAND -create_lib"
	endif
	if ($?IS_PHYSICAL) then
		set COMMAND = "$COMMAND -is_physical"
	endif
	if ($?XTALK) then
		set COMMAND = "$COMMAND -xtalk $XTALK"
	endif
	if ($?SINGLE) then
		set COMMAND = "$COMMAND -single"
	endif
	if ($?VIEWS) then
		set COMMAND = "$COMMAND -views $VIEWS"
	endif
	if ($?RH_OUT) then
		set COMMAND = "$COMMAND -rh_out"
	endif
	if ($?ECO) then
		set COMMAND = "$COMMAND -eco"
	endif
	if ($?ECO_NUM) then
		set COMMAND = "$COMMAND -eco_num $ECO_NUM"
	endif
	if ($?HOSTS) then
		set COMMAND = "$COMMAND -hosts $HOSTS"
	endif
	if ($?NETLIST) then
		set COMMAND = "$COMMAND -netlist $NETLIST"
	endif
	if ($?SPEF_DIR) then
		set COMMAND = "$COMMAND -spef_dir $SPEF_DIR"
	endif
	if ($?GPD_DIR) then
		set COMMAND = "$COMMAND -gpd_dir $GPD_DIR"
	endif
	if ($?INNOVUS_DIR) then
		set COMMAND = "$COMMAND -innovus_dir $INNOVUS_DIR"
	endif
	if ($?SPEF_FILES) then
		set COMMAND = "$COMMAND -spef_files $SPEF_FILES"
	endif
	if ($?GPD_FILES) then
		set COMMAND = "$COMMAND -gpd_files $GPD_FILES"
	endif
endif

####################################################################################################################################
##   run command
####################################################################################################################################
echo "CMD"
if (`echo $COMMAND | grep run_ | wc -l`) then
	echo $COMMAND > ${PWD_}/.run_tool.csh
	#set COMMAND "source ./.run_tool.csh"
	#set COMMAND  = "$COMMAND -c '\''./run_inn.csh -cpu ${CPU} -stages $STAGES'\''"
endif

set CMD =  "nextk8s run -command ' $COMMAND ' -desc $DESCRIPTION -cpu $CPU -memory $MEM -working-dir $PWD_"

if ($?XDISPLAY ) then 
	set CMD = "$CMD -x-display-num $XDISPLAY "
else 
	if (`echo $COMMAND | egrep "run_inn|run_genus" | wc -l`) then
		set CMD = "$CMD -x-server "
	endif
endif

echo $CMD
eval $CMD

goto END

LIST:
nextk8s list -pod $USER
goto END

KILL:
nextk8s kill -pod $KILL
goto END



HELP:
echo "variable this script can get are:"
echo "  -help 		: print this help"
echo "  -list 		: print list of open docker sessions"
echo "  -kill 		: kill specifice session"
echo "  -cmd	 	: run custom command"
echo "  -cpu	 	: set the requierment cpu"
echo "  -mem	 	: set the requierment mem"
echo "  -display	: set display number (if failed to extract from VNC)"
echo "  -bg		: bg color"
echo "  -fg		: fg color"
echo "  -title		: window title"
echo "  -pwd		: folder to run command from"
echo "  -stages         : Comma seperated list. Options: syn / floorplan / place / cts / route / chip_finish / dummy / eco /merge / pt / inn will run Innovuse default."
echo ""
echo "Genus flags"
echo "  -nextinside            <>              For  FE: REPO_ROOT . For  BE: /project/nxt008/next_RTL_drops/bravo_fn1_release/nextinside_20210119_11 ."
echo "  -is_physical           false           If true, run physical synthesis -  expects .def file  in ./ OR ../inter/ OR using -def"
echo "  -is_hybrid             false           If true, run physical syn_gen and syn_map, but NOT physical syn_opt.  expects .def file  in ./ OR ../inter/ OR using -def"
echo "  -useful_skew           false           if true will do useful skew for physical run"
echo "  -scan                  true/false      Defaults:  BE - true. FE - false . Run insert_dft and scan-related processes"
echo "  -ocv                   false           Run in ocv mode"
echo "  -mbit                  false           Run with multibit"
echo "  -flat_design           false           flat design before specific stage. option can be false , syn_opt , save_design"
echo "  -create_lib            false           Create lib for hierarchical flow - Adds runtime"
echo "  -remove_flops          true            Defaults:  BE - true. FE - false . Remove constant and unloaded flops"
echo "  -error_on_blackbox_false     false            If true, ignores error on blackbox on elaborate. Default:  false"
echo "  -sdc_list              <>              Comma seperated list of .sdc files. Will be sourced in order.  Default is ./DESIGN_NAME.sdc OR ../inter/.sdc"
echo "  -def_file              <>              .def file or .def.gz file.  Default is ./DESIGN_NAME.def OR ../inter/DESIGN_NAME.def"
echo "  -filelist              <>              Private filelist file"
echo ""
echo "Innovus flags"
echo "  -useful_skew       false     if true, allow cadence opt tools to apply useful skew"
echo "  -ecf               false     if true, allow cadence opt tools to apply early clock flow"
echo "  -create_lib        false     Create lib for hierarchical flow - Adds runtime"
echo "  -via_pillars       false     Insert via pillars if possible"
echo "  -syn_dir           <>        Syn folder to start from.  Default is syn OR syn_SUFFIX-TO-MATCH-YOUR-PNR-NAME"
echo "  -scandef           <>        Default -  SYN_DIR/out/DESIGN_NAME.Syn.scandef.gz"
echo "  -io_buffers_dir    in        in / in_ant / out / both / both_ant / none (default)"
echo "  -sdc_list          <>        Comma seperated list of .sdc files. Will be sourced in order.  Default is ./DESIGN_NAME.sdc OR ../inter/.sdc"
echo "  -eco_num           <>        run eco number"
echo "  -eco_do            <>        echo will do STA , SEM"
echo "  -force             false     Start new stage without checking if the previous was done"
echo "  -local             false     If true run do_ file from scripts_local folder"
echo ""
echo "PrimeTime flags"
echo "variable this script can get are:"
echo "  -create_lib  	: create .lib file. default false"
echo "  -physical    	: eco stage is done with physical information default false"
echo "  -xtalk		: run with si information. default true"
echo "  -single		: run single scenario"
echo "  -views		: run this views"
echo "  -host		: servers to run dmsa. should be localhost , nextk8s"
echo "  -eco		: run fix eco timing"
echo "  -eco_num	: run fix eco timing number"
echo "  -gpd_files	: read this gpd files"
echo "  -spef_files	: read this spef files"
echo "  -netlist	: read this netlists"
echo "  -spef_dir	: location of spef dir. expected to be under out/spef"
echo "  -gpd_dir	: location of gpd dir.  expected to be under out/gpd"
echo "  -innovus_dir	: location of innovus dir"
echo "  -rh_out 	: output redhawk timing windows file"
echo ""



END:

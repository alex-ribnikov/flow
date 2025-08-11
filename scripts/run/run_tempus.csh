#!/bin/csh
#################################################################################################################################################
#																		#
#	this script will run Tempuse STA  													#
#	to run need to define 															#
#		INTERACTIVE 	  - dont exit at end of script											#
#		SAVE_ECO_DB 	  - create eco DB for Tempus ECO										#
#		HOSTS 		  - localhost to run on the current server. or server list for multi server (DSTA/DMMMC)			#
#		distribute_STA	  - run dsta													#
#		OCV 		  - run with OCV												#
#		READ_SPEF 	  - read spef													#
#		CREATE_LIB 	  - create timing lib for block													#
#		PHYSICAL	  - run in physical mode											#
#		STAGE	 	  - stage to take innovus database from			 							#
#		INNOVUS_DIR 	  - location of INNOVUS directory for netlist/def database 							#
#		SPEF_DIR 	  - location of SPEF dir 											#
#		XTALK_SI 	  - run with si setting 											#
#		NETLIST_FILE_LIST - netlist file list of the design if nor using innovus DB							#
#		SPEF_FILE_LIST 	  - spef file list if need to override location from setup.tcl.							#
#		VIEW 		  - the view to run on. if define 1 view, will run in single view (sta/dsta).					#
#				    if define more than 1, will run MMMC/DMMMC									#
#																		#
#																		#
#	 Var	date of change	owner		 comment											#
#	----	--------------	-------	 ---------------------------------------------------------------					#
#	0.1	12/04/2021	Royl	initial script												#
#																		#
#																		#
#################################################################################################################################################
module unload ssv
module load  ssv/201

mkdir -pv log reports out out/lib
\rm -f log/do_tempus*

####################################################################################################################################
##   Setting env vars 
##   TODO - add flag parsser!!!
####################################################################################################################################
setenv BEROOT   `git rev-parse --show-toplevel` ; # <This is where your "nextflow" folder is>
setenv PROJECT  `echo $PWD | awk -F '/' '{print $(NF-3)}'`

####################################################################################################################################
##   link to scripts
####################################################################################################################################
if ( ! -e scripts ) then
    ln -s $BEROOT/ns_flow/scripts scripts
endif


####################################################################################################################################
##   user setting
####################################################################################################################################
set INTERACTIVE = "false"
set SAVE_ECO_DB = "false"
set CREATE_LIB = "false"

#-----------------------------------------------------------------------------------------------------------------------------------
# run setting
#-----------------------------------------------------------------------------------------------------------------------------------
set CPU = 16
#set HOSTS = (fdiv crosstalk) ; # can be localhost of servers list.
set HOSTS = (localhost) ; # can be localhost of servers list.
set distribute_STA = "false"
setenv TMPDIR /local/tmp

#-----------------------------------------------------------------------------------------------------------------------------------
# design setting
#-----------------------------------------------------------------------------------------------------------------------------------
set DESIGN_NAME  = `echo $PWD | awk -F '/' '{print $(NF-2)}'`
set OCV = "false"		
set READ_SPEF = "true"
set XTALK_SI = "true"
set PHYSICAL = "false"

set STAGE = "route"
set INNOVUS_DIR = "../pnr"
set SPEF_DIR = "../qrc"


set NETLIST_FILE_LIST = "$INNOVUS_DIR/out/db/${DESIGN_NAME}.${STAGE}.enc.dat/${DESIGN_NAME}.v.gz"
set SPEF_FILE_LIST = {}

####################################################################################################################################
##   define views to run
####################################################################################################################################
set VIEWS = (\
func_ssgnp0p675v0c_cworst_setup \
func_ssgnp0p675v125c_cworst_setup \
func_ssgnp0p675v0c_rcworst_setup \
func_ssgnp0p675v125c_rcworst_setup \
func_ssgnp0p675v0c_cworst_hold \
func_ssgnp0p675v125c_cworst_hold \
func_ffgnp0p825v125c_cbest_hold \
func_ffgnp0p825v0c_cbest_hold \
)

set VIEWS = (\
func_ssgnp0p675v0c_cworst_setup \
)
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
  if ("$argv[$i]" == "-interactive") then
  	echo "-I- running interactive"
   	set INTERACTIVE = "true"
  endif
  if ("$argv[$i]" == "-create_lib") then
  	echo "-I- create_lib"
   	set CREATE_LIB = "true"
  endif
  if ("$argv[$i]" == "-physical") then
  	echo "-I- running physical"
   	set PHYSICAL = "true"
  endif
  if ("$argv[$i]" == "-dsta") then
  	echo "-I- running distribute_STA"
   	set distribute_STA = "true"
  endif
  if ("$argv[$i]" == "-read_spef") then
  	@ i++
	set READ_SPEF = $argv[$i]
	if (`echo $READ_SPEF | grep "\-" | wc -l ` > 0) then
	  	echo "ERROR: $argv[$i] is not READ_SPEF value. should be true/false"
		exit
	else
  		echo "-I- running with READ_SPEF $READ_SPEF"
  	endif
  endif
  if ("$argv[$i]" == "-xtalk") then
  	@ i++
	set XTALK_SI = $argv[$i]
	if (`echo $XTALK_SI | grep "\-" | wc -l ` > 0) then
	  	echo "ERROR: $argv[$i] is not xtalk value. should be true/false"
		exit
	else
  		echo "-I- running with XTALK $XTALK_SI"
  	endif
  endif
  if ("$argv[$i]" == "-stage") then
  	@ i++
	set STAGE = $argv[$i]
	if (`echo $STAGE | grep "\-" | wc -l ` > 0) then
	  	echo "ERROR: $argv[$i] is not stage value. should be syn / place / cts / route / chip_finish"
		exit
	else
  		echo "-I- running on stage $STAGE"
  	endif
  endif
  if ("$argv[$i]" == "-views") then
  	@ i++
	set VIEWS = $argv[$i]
	if (`echo $VIEWS | grep "\-" | wc -l ` > 0) then
	  	echo "ERROR: $argv[$i] is not views value. should be proper view"
		exit
	else
  		echo "-I- running with $VIEWS views"
  	endif
  endif
  if ("$argv[$i]" == "-cpu") then
  	@ i++
	set CPU = $argv[$i]
	if (`echo $CPU | grep "\-" | wc -l ` > 0) then
	  	echo "ERROR: $argv[$i] is not cpu value. should be number of cpu"
		exit
	else
  		echo "-I- running with $CPU cpu"
  	endif
  endif
  if ("$argv[$i]" == "-spef") then
  	@ i++
	set SPEF_FILE_LIST = $argv[$i]
	if (`echo $SPEF_FILE_LIST | grep "\-" | wc -l ` > 0) then
	  	echo "ERROR: $argv[$i] is not spef files . should be list of spef files"
		exit
	else
  		echo "-I- running with $SPEF_FILE_LIST spef"
  	endif
  endif
  if ("$argv[$i]" == "-netlist") then
  	@ i++
	set NETLIST_FILE_LIST = $argv[$i]
	if (`echo $NETLIST_FILE_LIST | grep "\-" | wc -l ` > 0) then
	  	echo "ERROR: $argv[$i] is not netlist value. should be list of netlist files"
		exit
	else
  		echo "-I- running with $NETLIST_FILE_LIST netlist"
  	endif
  endif
  if ("$argv[$i]" == "-spef_dir") then
  	@ i++
	set SPEF_DIR = $argv[$i]
	if (`echo $SPEF_DIR | grep "\-" | wc -l ` > 0) then
	  	echo "ERROR: $argv[$i] is not SPEF_DIR. should be spef dir location."
		exit
	else
  		echo "-I- running on spef dir $SPEF_DIR "
  	endif
  endif
  if ("$argv[$i]" == "-innovus_dir") then
  	@ i++
	set INNOVUS_DIR = $argv[$i]
	if (`echo $INNOVUS_DIR | grep "\-" | wc -l ` > 0) then
	  	echo "ERROR: $argv[$i] is not INNOVUS_DIR"
		exit
	else
  		echo "-I- running on innovus dir $INNOVUS_DIR "
  	endif
  endif
end

####################################################################################################################################
##   stages scripts
####################################################################################################################################
set TEMPUS_SCRIPT = "scripts/do_tempus.tcl"

####################################################################################################################################
##   execute run
####################################################################################################################################
if ($distribute_STA == "true") then
   set DISTRIBUTED = "-distributed"
else
   set DISTRIBUTED = ""
endif

echo > tempus_user_input.tcl
echo "set DESIGN_NAME $DESIGN_NAME" >> tempus_user_input.tcl
echo "set VIEWS {$VIEWS}" >> tempus_user_input.tcl
echo "set OCV $OCV" >> tempus_user_input.tcl
echo "set CPU $CPU" >> tempus_user_input.tcl
echo "set STAGE $STAGE" >> tempus_user_input.tcl
echo "set HOSTS {$HOSTS}" >> tempus_user_input.tcl
echo "set PHYSICAL $PHYSICAL" >> tempus_user_input.tcl
echo "set INNOVUS_DIR $INNOVUS_DIR" >> tempus_user_input.tcl
echo "set SPEF_DIR $SPEF_DIR" >> tempus_user_input.tcl
echo "set NETLIST_FILE_LIST $NETLIST_FILE_LIST" >> tempus_user_input.tcl
echo "set SPEF_FILE_LIST $SPEF_FILE_LIST" >> tempus_user_input.tcl
echo "set READ_SPEF $READ_SPEF" >> tempus_user_input.tcl
echo "set XTALK_SI $XTALK_SI" >> tempus_user_input.tcl
echo "set INTERACTIVE $INTERACTIVE" >> tempus_user_input.tcl
echo "set SAVE_ECO_DB $SAVE_ECO_DB" >> tempus_user_input.tcl
echo "set CREATE_LIB $CREATE_LIB" >> tempus_user_input.tcl

tempus -common_ui $DISTRIBUTED -tso -files ${TEMPUS_SCRIPT} -log log/do_tempus.log
goto END

HELP:
echo "variable this script can get are:"
echo "\t-help 		: print this help"
echo "\t-interactive 	: dont exit in the end of the run. default false"
echo "\t-create_lib  	: create .lib file. default false"
echo "\t-physical    	: eco stage is done with physical information default false"
echo "\t-dsta		: run single view distribute mahine. default false"
echo "\t-xtalk		: run with si information. default true"
echo "\t-stage 		: run on this stage"
echo "\t-views		: run this views"
echo "\t-cpu		: number of cpus "
echo "\t-spef		: read this spef files"
echo "\t-netlist		: read this netlists"
echo "\t-spef_dir	: location of spef dir. expected to be under out/spef"
echo "\t-innovus_dir	: location of innovus dir"
echo "\t"

END:

#
#tempus -common_ui \
#	$DISTRIBUTED \
# 	-tso \
#	-execute " \
#	set DESIGN_NAME $DESIGN_NAME; \
#	set VIEWS {$VIEWS} ; \
#	set OCV $OCV ; \
#	set CPU $CPU ; \
#	set HOSTS {$HOSTS} ; \
#	set PHYSICAL $PHYSICAL ; \
#	set INNOVUS_DIR $INNOVUS_DIR ; \
#	set SPEF_DIR $SPEF_DIR ; \
#	set NETLIST_FILE_LIST $NETLIST_FILE_LIST ; \
#	set SPEF_FILE_LIST $SPEF_FILE_LIST ; \
#	set READ_SPEF $READ_SPEF ; \
#	set INTERACTIVE $INTERACTIVE ; \
#	set SAVE_ECO_DB $SAVE_ECO_DB ; \
#	" \
#	-files ${TEMPUS_SCRIPT} -log log/do_tempus.log


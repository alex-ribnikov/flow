#!/bin/csh

#set CPU 8
#set DESIGN_NAME     grid_cluster               
#set ::env(PROJECT)  nxt008                     
#set ::env(BEROOT)   $::env(REPO_ROOT)/nextflow 
#set ::env(SYN4RTL)  true    
#set MODE            from_netlist ; # from_rtl will run power_map (syn)                   
#set NEXTINSIDE      $::env(REPO_ROOT)          
#set NETLIST         /bespace/users/ory/syn4rtl/new_nextinside/gendir/out/grid_cluster.Syn.v.gz ; # Maybe "syn" folder?
#set STIM_FILE       /bespace/users/ory/syn4rtl/new_nextinside/gendir/wb_env/inter/dump.fsdb ; # Def is ../inter/${DESIGN_NAME}.fsdb?
#set MAP_FILE        "" ; # If empty, use automap
#set FRAME_COUNT     10
#set X_VALUE         0
#set DUT_INST        /cluster_tb/grid_cluster
#set FROM_FRAME      0
#set TO_FRAME        10


##-----------------------------------
## FE Root / BE Root
##-----------------------------------
#if ( "$?REPO_ROOT" == 0 ) then
#    setenv BEROOT   `git rev-parse --show-toplevel` ; # <This is where your "nextflow" folder is>
##    set nextinside = /project/nxt008/nextinside_model_releases/nextinside_bravo_20210119_bravo_fn1    
#else
#    setenv BEROOT   $REPO_ROOT/nextflow ; # <This is where your "nextflow" folder is>
#endif 


#-----------------------------------
# Parsing flags
#-----------------------------------
#source $BEROOT/ns_flow/scripts/bin/parse_args.csh joules $argv 
#
#if ( $is_exit  == "true" ) then
#    exit
#endif


#-----------------------------------
# Run
#-----------------------------------
module clear -f
module unload joules jls
module load jls/191/latest

mkdir -pv log out reports scripts_local
\rm -rf log/*

setenv PROJECT  nxt008
setenv SYN4RTL  true


set cpus             =  8
set design_name     =  grid_cluster               
set MODE            =  from_netlist 
set nextinside      =  $REPO_ROOT
set NETLIST         =  "/bespace/users/ory/syn4rtl/new_nextinside/gendir/out/grid_cluster.Syn.v.gz"
set STIM_FILE       =  "/bespace/users/ory/syn4rtl/new_nextinside/gendir/wb_env/inter/dump.fsdb"
set MAP_FILE        =  "" 
set FRAME_COUNT     =  10
set X_VALUE         =  0
set DUT_INST        =  "/cluster_tb/grid_cluster"
set FROM_FRAME      =  0
set TO_FRAME        =  10



joules \
    -common_ui \
	-execute " \
	set CPU          $cpus ; \
	set DESIGN_NAME  $design_name ; \
    set INTERACTIVE  false ; \
    set NEXTINSIDE   $nextinside ; \
    set NETLIST      /bespace/users/ory/syn4rtl/new_nextinside/gendir/out/grid_cluster.Syn.v.gz ; \
	set STIM_FILE    /bespace/users/ory/syn4rtl/new_nextinside/gendir/wb_env/inter/dump.fsdb  ; \
	set MAP_FILE     ''   ; \
	set FRAME_COUNT  10  ; \
	set X_VALUE      0  ; \
	set DUT_INST     /cluster_tb/grid_cluster  ; \
	set FROM_FRAME   0  ; \
	set TO_FRAME     10  ; \
	" \
	-f ./scripts/do_joulesPwr.tcl \
	-log log/do_joulesPwr.log | tee -a log/joulesPwr.log.full


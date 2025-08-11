#!/bin/tcsh -fe
source /tools/common/pkgs/modules/current/init/tcsh

module unload genus innovus
module load genus/211 innovus/211
#-----------------------------------
# Parsing flags
#-----------------------------------
source ./scripts/bin/parse_args.csh lib_gen $argv 

if ( $is_exit  == "true" ) then
    exit
endif


if ($user_inputs == "false") then
   mv .tmp_user_inputs.tcl user_inputs.tcl
endif

#set PROJECT_OPTION = "nxt080 nextcore"

####################################################################################################################################
if ( $?local && $local == "true" ) then
    # Run from local do file
    set do_scripts = ./scripts_local/do_genus_create_lib.tcl
else
    # Run from central do file
    set do_scripts = ./scripts/do_genus_create_lib.tcl
endif


####################################################################################################################################
#-----------------------------------
# nextk8s run 
#-----------------------------------
echo "k8s: $k8s"
if ($k8s == "true" ) then
   echo "k8s: $k8s"
   source ./scripts/bin/k8s_launcher.csh lib_gen $argv 
   exit 0
endif


####################################################################################################################################


#foreach PPP (`echo $PROJECT_OPTION`)
#    echo "PROJECT $PPP"
#    set cmd = "perl -p -i -e 's/set PROJECT \S+/set PROJECT $PPP/' ./user_inputs.tcl"
#    eval $cmd
#    genus \
#        -execute "source -e -v ./user_inputs.tcl" \
#        -f ./scripts/do_genus_create_lib.tcl \
#        -log log/do_genus_create_lib.log | tee -a log/do_genus_create_lib_$PPP.log.full
#end

    genus \
        -execute "source -e -v ./user_inputs.tcl" \
        -f ./scripts/do_genus_create_lib.tcl \
        -log log/do_genus_create_lib.log | tee -a log/do_genus_create_lib_${project}.log.full


setenv SNPSLMD_QUEUE true
setenv SNPS_MAX_QUEUETIME  18000
module load snps/fusioncompiler/S-2021.06-SP1
/tools/snps/lc/S-2021.06-SP5/bin/lc_shell -x '\
    source -e -v ./user_inputs.tcl ; \
    set lib_files [glob out/${DESIGN_NAME}*.lib] ; \
    foreach lib $lib_files { \
      regexp {out/(.*)\.lib} $lib match lib_file_name ; \
      read_lib $lib ;\
      set lib_name [get_object_name [get_libs]] ; \
      write_lib -output out/${lib_file_name}.db $lib_name  ; \
    } ; \
    exit '   | tee -a log/do_lc.log.full


exit 0

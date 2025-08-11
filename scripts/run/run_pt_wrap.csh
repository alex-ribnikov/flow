#!/bin/csh


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


#-----------------------------------
# Parsing flags
#-----------------------------------
source ./scripts/bin/parse_args.csh pt $argv 
if ( "$PROJECT" == "None" ) then
    setenv PROJECT  `echo $PWD | awk -F '/' '{print $(NF-3)}'`
else
    setenv PROJECT $project
endif
set VIEWS = ($views)


if ( "$VIEWS" == "None" ) then
    # 6 ciritcal views from BRTCM
    set VIEWS = (\
    func_no_od_minT_LIBRARY_SS_c_wc_cc_wc_T_setup \
    func_no_od_minT_LIBRARY_SS_rc_wc_cc_wc_T_setup \
    func_no_od_125_LIBRARY_SS_rc_wc_cc_wc_T_setup \
    func_qod_125_LIBRARY_FF_rc_bc_cc_bc_hold \
    func_qod_125_LIBRARY_FF_rc_wc_cc_wc_hold \
    func_qod_minT_LIBRARY_FF_c_bc_cc_bc_hold \
    )    
endif

if ($RH_OUT == "true" &&  `echo $VIEWS | grep func_qod_125_LIBRARY_FF_rc_wc_cc_wc_hold | wc -l` == 0 ) then
    echo "Adding view: func_qod_125_LIBRARY_FF_rc_wc_cc_wc_hold"
    set VIEWS = (\
    $VIEWS \
    func_qod_125_LIBRARY_FF_rc_wc_cc_wc_hold \
)
endif



if ($RESTORE == "false" && $CREATE_LIB_ONLY == "false") then
#	\rm -f log/do_pt*
#	mv reports_old reports_delete
#	mv reports reports_old
#	\rm -rf reports_delete &
	
	mv work_old work_delete
	mv work work_old
	\rm -rf work_delete &
	
	mv session_old session_delete
	mv session session_old
	\rm -rf session_delete &
	
	mkdir -pv log reports out out/lib out/rhtf session work
endif
if ($CREATE_LIB_ONLY == "true") then
	\rm -f log/do_pt*
	mv work_old work_delete
	mv work work_old
	\rm -rf work_delete &
endif


set pt_dir = `pwd`
foreach view ( $VIEWS )
    
    mkdir -pv $pt_dir/work/$view/sourced_scripts/$stage
    cd $pt_dir/work/$view
 	mkdir -pv log reports out out/lib out/rhtf session work
    
    if (! -d scripts ) then
        ln -f -s $pt_dir/scripts       scripts
    endif
    if (! -d scripts_local ) then
        ln -f -s $pt_dir/scripts_local scripts_local
    endif
    ln -f -s $pt_dir/scripts/run/run_pt.csh run_pt.csh
    ln -f -s log/do_pt.log out.log
    
    set cmd = "./scripts/run/run_pt.csh $argv -views $view -single -k8s -desc pt_wrap"
    
    if ( "$argv" !~ "*-innovus_dir*") then
        set cmd = "$cmd -innovus_dir $innovus_dir"
    endif
    if ( "$argv" !~ "*-spef_dir*") then
        set cmd = "$cmd -spef_dir $spef_dir"
    endif
    if ( "$argv" !~ "*-gpd_dir*") then
        set cmd = "$cmd -gpd_dir $gpd_dir"
    endif
    if ( "$argv" !~ "*-project*") then
        set cmd = "$cmd -project $project"
    endif
    if ( "$argv" !~ "*-design_name*") then
        set cmd = "$cmd -design_name $design_name"
    endif
    
    echo "-I- Running: $cmd"
    set cmd = "$cmd"
    eval $cmd  ; echo "> $pt_dir/log/do_pt_wrap.log &"
    
end

'wait'
echo "-I- Waiting for pt_wrap to finish"
foreach view ( $VIEWS )
    while (! -f $pt_dir/work/$view/.pt_done )
        sleep 300
        echo "-?- Are we there yet?"
    end
end

echo "-I- All jobs are done"
echo "-I- Moving sessions to pt dir"
mkdir -pv $pt_dir/session/$design_name
foreach view ( $VIEWS )
    echo "-I- Moving files for $view"
    mkdir -pv $pt_dir/reports/$view
    mv $pt_dir/work/$view/session/$design_name/$view $pt_dir/session/$design_name/$view
    mv $pt_dir/work/$view/reports/* $pt_dir/reports/$view
    mv $pt_dir/work/$view/out/lib/* $pt_dir/out/lib/
    mv $pt_dir/work/$view/out/rhtf/* $pt_dir/out/rhtf/
end

#    mv out/lib/*  $pt_dir/out/lib/
#    mv out/rhtf/* $pt_dir/out/rhtf/




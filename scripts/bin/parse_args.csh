#!/bin/tcsh

set is_exit = "true"
set is_debug = "false"
set is_error = "false"
set is_fast = "false"

set help = "\033[1;3m \n\
###################################### \n\
 \n\
How to run:  \n\
source parse_args.csh FLOW_NAME "`echo $`"argv \n\
For help type: -help OR -help FLOW_NAME \n\
Valid flows are: genus, dc, innovus, joules, voltus, tempus, starrc, pt, rtla, fusion, ptpx, fm, rhsc, lib_gen, drc \n\
\n\
###################################### \n\
\033[0m"


###########################################
#------------------------------------------
# FLOW DEFAULTS - structure is -flag_name default_value help_text
#------------------------------------------
###########################################

#------------------------------------------
# GENUS
#------------------------------------------
set genus_musts       = "design_name project"
set genus_defs = ";\
-k8s	                 true/false    'Run through k8s. Defaults: \-BSS\-BE - true. FE - false\-BSE\-.';\
-win	                 false         'open k8s terminal and run in it.';\
-term_options            <>            'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server              <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display             <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	                 <>            'set k8s label';\
-desc	                 <>            'k8s pod name. 20 char limit . default is running dir name';\
-memory	                 60            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-tail	                 false         'tail after create k8s pod';\
-design_name             <>            'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project                 <>            'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-cpu                     16            'Number of cpus per run. (default 16)';\
-is_physical             false         'If true, run physical synthesis - \-BSS\-expects .def file\-BSE\- in ./  OR ../inter/ OR using -def';\
-is_hybrid               false         'If true, run physical syn_gen and syn_map, but NOT physical syn_opt. \-BSS\-expects .def file\-BSE\- in ./  OR ../inter/ OR using -def';\
-useful_skew             false         'if true will do useful skew for physical run';\
-scan                    false         'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Run insert_dft and scan-related processes';\
-ocv                     flat          'Run in ocv mode options: none / flat / socv ';\
-mbit                    false         'Run with multibit';\
-wlm                     false         'run with wireload model.option are false , W1600 , W3600';\
-lpg                     true          'insert low power clock gating cells';\
-no_autoungroup          false         'Specifies that automatic ungrouping is completely disabled.';\
-vt_effort               low           'high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL';\
-power_effort            none          'none - Disables power optimization.  low - Performs a low-effort power optimization with minimum trade-off. high - Performs the best power optimization with a higher trade-off';\
-flat_design             <>            'Flat design before specific stage. Options are false, syn_opt, save_design. \-BSS\-BE Default is syn_opt. FE Default is false\-BSE\-';\
-interactive             false         'Do not exit when done';\
-fe_mode                 false         'Do not run BE related stuff. Faster syn for FE';\
-create_lib              false         'Create lib for hierarchical flow - Adds runtime';\
-remove_flops            true          'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Remove constant and unloaded flops';\
-error_on_blackbox       true          'If false, ignores error on blackbox on elaborate. Default: \-BSS\-true \-BSE\-';\
-constraints_root        <>            'location for central constraint definition file';\
-sdc_list                <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-def_file                <>            '.def file or .def.gz file. \-BSS\-Default is ./DESIGN_NAME.def  OR ../inter/DESIGN_NAME.def\-BSE\-';\
-filelist                <>            'Private filelist file';\
-be_partitions           <>            'List of modules to be synthesized as libs/ILM models/blackbox';\
-search_path             <>            'Path to a REPO_ROOT area that contains lib/ILM files under its target/syn_regressions dir';\
-stop_after              final         'Defaults: finish run. Stop after this stage - elaborate/syn_gen/syn_map/final';\
-detailed_timing         true/false    'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Print detailed timing reports';\
-check_design_waivers    <>            'FE use - waivers file for check_design';\
-check_timing_waivers    <>            'FE use - waivers file for check_design';\
-report_fi_fo_size       false         'syn_reg only - Report size of FI FO from/to interface';\
-report_logic_levels     false         'syn_reg only - Report logic levels number on interface and internal';\
-open                    <>            'Stage to open syn_gen, syn_map, syn_opt OR Syn';\
-other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool. \-BSS\- Must be within /appost/ YOUR STRING /appost/ \-BSE\-';\
-user_inputs             false         'read same user inputs as last run. need to define k8s flags again.';\
-local                   false         'If true run do_ file from scripts_local folder';\
-scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
-tool_version            <>            'genus version. default will be define in run_genus.csh' ;\
-help                    false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# RTLA
#------------------------------------------
set rtla_musts       = "design_name project"
set rtla_stages       = "init syn"
set rtla_defs = ";\
-k8s	                    	     false    'Run through k8s. Defaults: \-BSS\-BE - true. FE - false\-BSE\-.';\
-win	                    	     false    'open k8s terminal and run in it.';\
-term_options               	     <>       'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server                 	     <>       'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display                	     <>       'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	                    	     <>       'set k8s label';\
-desc	                    	     <>       'k8s pod name. 20 char limit . default is running dir name';\
-memory	                    	     60       'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-tail	                    	     false    'tail after create k8s pod';\
-design_name                         <>       'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project                             <>       'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-cpu                                 8        'Number of cpus per run. (default 16)';\
-stages           		      <>      'Comma seperated list. Options: init / syn .';\
-ocv                     	     flat     'Run in ocv mode options: none / flat / pocv ';\
-is_physical                         false    'If true, run physical synthesis - \-BSS\-expects .def file\-BSE\- in ./  OR ../inter/ OR using -def';\
-retime                              true     'Uses  the  adaptive  retiming  algorithm  during optimization to improve delay.';\
-no_boundary_opt                     false    'Specifies that no hierarchical boundary optimization is to be performed.';\
-useful_skew                         false     'allow RTL-A opt tools to apply useful skew.  options are false / true ';\
-vt_effort                           low      'high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL';\
-effort                              medium   'effort value for run. low / medium / high ';\
-power_effort                        none     'none - Disables power optimization.  low - Performs a low-effort power optimization with minimum trade-off. high - Performs the best power optimization with a higher trade-off';\
-flat_design                         <>       'Flat design before specific stage. Options are false , syn_opt , save_design . \-BSS\-BE Default is syn_opt. FE Default is false\-BSE\-';\
-remove_flops                        true     'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Remove constant and unloaded flops';\
-autofix	                     false    'If true, run with bbox and dirty rtl';\
-enable_rtl_restructuring            false    '' ;\
-enable_upf                          false    '' ;\
-enable_pre_rtl_opt_netlist_checks   true     '' ;\
-upf_mode                            false    '' ;\
-enable_cts                          false    '' ;\
-enable_multibit                     false    '' ;\
-dynamic_power_analysis              false    '' ;\
-sort_by_timing_metrics              <>      '' ;\
-write_qor_data                      true     '' ;\
-create_abstract       		     false    'Create abstract for hierarchical flow - Adds runtime';\
-run_timing_reports                  true     '' ;\
-saif_file_power_scenario            <>       '' ;\
-constraints_root           	     <>       'location for central constraint definition file';\
-sdc_list                   	     <>       'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-def_file                   	     <>       '.def file or .def.gz file. \-BSS\-Default is ./DESIGN_NAME.def  OR ../inter/DESIGN_NAME.def\-BSE\-';\
-filelist                   	     <>       'Private filelist file';\
-open                       	     <>       'Stage to open syn_gen, syn_map, syn_opt OR Syn';\
-saif_file                  	     <>       'load SAIF file ';\
-saif_inst_name             	     <>       'When loading SAIF activity file - specify the instance path of the design top';\
-other_args                 	     <>       'Other arguments as a string. This string will be sourced as is in the tool. \-BSS\- Must be within /appost/ YOUR STRING /appost/ \-BSE\-';\
-user_inputs                	     false    'read same user inputs as last run. need to define k8s flags again.';\
-local                      	     false    'If true run do_ file from scripts_local folder';\
-interactive                	     false    'Do not exit when done';\
-fe_mode                    	     true     'Do not run BE related stuff. Faster syn for FE';\
-scripts_version            	     <>       'scripts version. defaul will take the latest from be_repository' ;\
-tool_version              	     <>       'dc version. default will be define in run_dc.csh' ;\
-force            		     false    'Start new stage without checking if the previous was done';\
-help                       	     false    'Prints help for the relevant tool' ;\
"

#------------------------------------------
# DC
#------------------------------------------
set dc_musts       = "design_name project"
set dc_defs = ";\
-k8s	                 true/false    'Run through k8s. Defaults: \-BSS\-BE - true. FE - false\-BSE\-.';\
-win	                 false         'open k8s terminal and run in it.';\
-term_options            <>            'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server              <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display             <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	                 <>            'set k8s label';\
-desc	                 <>            'k8s pod name. 20 char limit . default is running dir name';\
-memory	                 60            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-tail	                 false         'tail after create k8s pod';\
-design_name             <>            'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project                 <>            'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-cpu                     8             'Number of cpus per run. (default 16)';\
-is_physical             false         'If true, run physical synthesis - \-BSS\-expects .def file\-BSE\- in ./  OR ../inter/ OR using -def';\
-scan                    false         'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Run insert_dft and scan-related processes';\
-scan_ff                 true          'insert scan FF or none scan FF';\
-ocv                     flat          'Run in ocv mode options: none / flat / socv ';\
-mbit                    false         'Run with multibit';\
-lpg                     true          'insert low power clock gating cells';\
-retime                  true          'Uses  the  adaptive  retiming  algorithm  during optimization to improve delay.';\
-zwlm                    true          'run with zero interconnect delay mode.';\
-no_autoungroup          true          'Specifies that automatic ungrouping is completely disabled.';\
-no_boundary_opt         false         'Specifies that no hierarchical boundary optimization is to be performed.';\
-vt_effort               low           'high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL';\
-power_effort            none          'none - Disables power optimization.  low - Performs a low-effort power optimization with minimum trade-off. high - Performs the best power optimization with a higher trade-off';\
-flat_design             <>            'Flat design before specific stage. Options are false , syn_opt , save_design . \-BSS\-BE Default is syn_opt. FE Default is false\-BSE\-';\
-compile_incr            0             'extra compile increment . 0 means None.';\
-create_lib              false         'Create lib for hierarchical flow - Adds runtime';\
-create_spef             false         'Create spef for hierarchical flow - Adds runtime';\
-remove_flops            true          'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Remove constant and unloaded flops';\
-error_on_blackbox       true          'If false, ignores error on blackbox on elaborate. Default: \-BSS\-true \-BSE\-';\
-constraints_root        <>            'location for central constraint definition file';\
-sdc_list                <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-def_file                <>            '.def file or .def.gz file. \-BSS\-Default is ./DESIGN_NAME.def  OR ../inter/DESIGN_NAME.def\-BSE\-';\
-filelist                <>            'Private filelist file';\
-be_partitions           <>            'List of modules to be synthesized as libs/ILM models/blackbox';\
-search_path             <>            'Path to a REPO_ROOT area that contains lib/ILM files under its target/syn_regressions dir';\
-stop_after              final         'Defaults: finish run. Stop after this stage - elaborate/syn_gen/syn_map';\
-detailed_timing         true/false    'Defaults: \-BSS\-BE - true. FE - false\-BSE\-. Print detailed timing reports';\
-check_design_waivers    <>            'FE use - waivers file for check_design';\
-check_timing_waivers    <>            'FE use - waivers file for check_design';\
-report_fi_fo_size       false         'syn_reg only - Report size of FI FO from/to interface';\
-report_logic_levels     false         'syn_reg only - Report logic levels number on interface and internal';\
-detailed_hier_report    false         'will create a more detailed hierarchy cell report';\
-open                    <>            'Stage to open syn_gen, syn_map, syn_opt OR Syn';\
-saif_file               <>            'load SAIF file ';\
-saif_inst_name          <>            'When loading SAIF activity file - specify the instance path of the design top';\
-other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool. \-BSS\- Must be within /appost/ YOUR STRING /appost/ \-BSE\-';\
-brcm                    true          'run BRCM script';\
-user_inputs             false         'read same user inputs as last run. need to define k8s flags again.';\
-local                   false         'If true run do_ file from scripts_local folder';\
-interactive             false         'Do not exit when done';\
-fe_mode                 false         'Do not run BE related stuff. Faster syn for FE';\
-scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
-tool_version            <>            'dc version. default will be define in run_dc.csh' ;\
-help                    false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# INNOVUS
#------------------------------------------
set innovus_musts        = "design_name project"
set innovus_stages       = "floorplan place cts route chip_finish"
set innovus_stages_no_fp = "place cts route chip_finish"
set innovus_defs = ";\
-argo	          false     'Run through argo';\
-k8s	          true     'Run through k8s';\
-win	          false     'open k8s terminal and run in it.';\
-term_options     <>        'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server       <>        'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display      <>        'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	          <>        'set k8s label';\
-desc	          <>        'k8s pod name. 20 char limit . default is running dir name';\
-memory	          60        'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-tail	          false     'tail after create k8s pod';\
-design_name      <>        'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project          <>        'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-cpu              16        'Number of cpus per run. (default 16)';\
-stages           <>        'Comma seperated list. Options: floorplan / place / cts / route / chip_finish / dummy / merge / eco .';\
-batch            true      'Run in batch mode - run stages one after another';\
-place_start_from db        'floorplan (db) , def , syn , syn_incr. \-BSS\-if place start from fp, default stages floorplan-chip_finish. if def, place to chip_finish\-BSE\-'; \
-flow_start_from  db        'If place starts from db/syn - should the flow start from floorplan (db) OR def OR syn stylus db ';\
-place_opt        0         'Number of place opt loops. 0 means None.';\
-break_cts        true      'If true, runs ccopt_design -cts, and opt_design -setup seperatly, instead of full ccopt_design. Use \-BSS\-scripts_local/post_cts_pre_opt.tcl\-BSE\- to run commands before opt_design -setup';\
-break_route      false     'If true, runs route_design -track_opt , opt_design  -setup -hold , instead of full route_opt_design.';\
-vt_effort        medium    'high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL';\
-useful_skew      false     'if true, allow cadence opt tools to apply useful skew';\
-ecf	          false     'if true, allow cadence opt tools to apply early clock flow';\
-create_ilm       false     'Create ilm for hierarchical flow - Adds runtime';\
-create_lib       false     'Create lib for hierarchical flow - Adds runtime';\
-create_lib_pt    false     'Create lib for hierarchical flow - using PrimeTime. options are true, false, only';\
-create_spef      false     'Create spef for hierarchical flow - Adds runtime';\
-via_pillars      false     'Insert via pillars if possible';\
-open             <>        'Stage to open';\
-refresh          false     'If refresh == lef, reads lef from setup. If regresh == lib, recreate mmmc and reads it. I both, do both. If false, reads from DB';\
-syn_dir          <>        'Syn folder to start from. \-BSS\-Default is syn OR syn_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-';\
-wait_for_syn     false     'wait for synthesis to end before running';\
-flat_netlist     true      'netlist is hierarchy or flat;\
-netlist          <>        'Default - \-BSS\-SYN_DIR/out/DESIGN_NAME.Syn.v.gz\-BSE\-';\
-scandef          <>        'Default - \-BSS\-SYN_DIR/out/DESIGN_NAME.Syn.scandef.gz\-BSE\-';\
-io_buffers_dir   in        'in / in_ant / out / both / both_ant / none (default)';\
-scan             true      'Run insert_dft and scan-related processes';\
-ocv              socv      'Run in ocv mode. options are socv , flat , none';\
-manual_fp        false     'If True, stops pre user manua_fp stage. If False, run your manual FP recipe';\
-interactive      false     'Do not exit when done';\
-constraints_root <>        'location for central constraint definition file';\
-sdc_list         <>        'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-def_file         <>        '.def file or .def.gz file. \-BSS\-Default is ./DESIGN_NAME.def  OR ../inter/DESIGN_NAME.def\-BSE\-';\
-eco_num          <>        'run eco number ';\
-eco_do           STA       'eco will do STA , SEM , LOGIC , LOGIC_TCL';\
-eco_netlist      <>        'netlist eco for netlist compare ';\
-eco_script       <>        'script eco for logic eco ';\
-stop_after       <>        'Stop after this stage - fp/place/cts_cluster/cts/route';\
-force            false     'Start new stage without checking if the previous was done';\
-other_args       <>        'Other arguments as a string. This string will be sourced as is in the tool';\
-user_inputs      false     'read same user inputs as last run. need to define k8s flags again.';\
-local            false     'If true run all do_ stages from scripts_local folder. can also run stages comma seperated list';\
-logv             false     'To produce logv file';\
-scripts_version  <>        'scripts version. defaul will take the latest from be_repository' ;\
-tool_version     <>        'innovus version. default will be define in run_inn.csh' ;\
-help             false     'Prints help for the relevant tool' ;\
"

#------------------------------------------
# Fusion
#------------------------------------------
set fusion_musts        = "design_name project"
set fusion_stages       = "init compile place cts route chip_finish"
set fusion_stages_dft   = "init place cts route chip_finish"
set fusion_defs = ";\
-argo	                  false     	'Run through argo';\
-k8s	                  true      	'Run through k8s';\
-win	                  false     	'open k8s terminal and run in it.';\
-term_options             <>	    	'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server               <>	    	'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display              <>	    	'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	                  hw-be	    	'set k8s label';\
-desc	                  <>	    	'k8s pod name. 20 char limit . default is running dir name';\
-memory	                  60	    	'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-cpu                      16	    	'Number of cpus per run. (default 16)';\
-tail	                  false     	'tail after create k8s pod';\
-design_name              <>	    	'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project                  <>	    	'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-fe_mode                  false     	'Do not run BE related stuff. Faster syn for FE';\
-open                     <>        	'Stage to open';\
-stages                   <>        	'Comma seperated list. Options: init / compile / place / cts / route / chip_finish / dummy / merge / eco .';\
-report_only              false         'Run only reports';\
-chip_finish_open_block   <>            'open chip_finish on this specific block';\
-ocv                      pocv      	'Run in ocv mode. options are pocv , flat , none';\
-clock_margin             true      	'Run with extra clock uncertainty per stage';\
-useful_skew              true     	'allow Fusion opt tools to apply useful skew.  options are false / place (start from place) / cts (start from cts) ';\
-effort_timing            medium      	'effort value for run. low / medium / high /extreme';\
-effort_cong              high      	'congestion effort value for run.  medium / high / ultra';\
-vt_effort                high      	'high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL';\
-starrc_indesign          true     	'run starrc during route stage ';\
-manual_fp                false     	'If true, stops pre user manua_fp stage. If False, run your manual FP recipe';\
-mbit		          true	    	'Default - place. Options: true / false / place / cts / route ';\
-start_from_netlist       false	    	'If true, uses DFT netlist directly (requires -fp_tcl). If false, runs netlist_eco using previous compile block as base.';\
-dft_collaterals          <>        	'Path to DFT collaterals to be used in incremental init mode (e.g. /project/nxt013/delivery/from_brcm/40_scan.19April)';\
-fp_tcl                   <>	        'floorplan.tcl file created by write_floorplan command. Can be found under out/floorplan/compile/fp.tcl';\
-inc_init                 false         'If true, enables incremental init mode. in init, inserts DFT (requires -dft_collaterals, method depends on -start_from_netlist). in place, uses init_inc block instead of compile';\
-break_cts        	  false         'If true, runs synthesize_clock_trees and balance_clock_groups';\
-cts_create_shields       false         'If true, create shield for clock tree';\
-io_buffers_dir           none            'in / in_ant / out / both / both_ant / none (default)';\
-io_buffer_distribution   checkerboard  'checkerboard / layer ';\
-no_autoungroup           false     	'Specifies that automatic ungrouping is completely disabled.';\
-flat_design              true     	'Flat design after compile stage. ';\
-report_fi_fo_size        false     	'syn_reg only - Report size of FI FO from/to interface';\
-report_logic_levels      false     	'syn_reg only - Report logic levels number on interface and internal';\
-constraints_root         <>	    	'location for central constraint definition file';\
-sdc_list                 <>	    	'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-def_file                 <>	    	'.def file or .def.gz file. \-BSS\-Default is ./DESIGN_NAME.def  OR ../inter/DESIGN_NAME.def\-BSE\-';\
-eco_num                  <>	    	'run eco number ';\
-create_abstract          false     	'Create abstract for hierarchical flow - Adds runtime';\
-create_lib               false     	'Create lib for hierarchical flow - Adds runtime';\
-stop_after               <>            'Stop after this in the stage - compile:initial_map /  ';\
-lib_prep                 false     	'lib preperation for release flow.';\
-refresh                  false     	'it will update NDM pointer ';\
-interactive              false     	'Do not exit when done';\
-force                    false     	'Start new stage without checking if the previous was done';\
-other_args               <>	    	'Other arguments as a string. This string will be sourced as is in the tool';\
-user_inputs              false     	'read same user inputs as last run. need to define k8s flags again.';\
-local                    false     	'If true run all do_ stages from scripts_local folder. can also run stages comma seperated list';\
-scripts_version          <>        	'scripts version. defaul will take the latest from be_repository' ;\
-tool_version             <>        	'innovus version. default will be define in run_inn.csh' ;\
-help                     false     	'Prints help for the relevant tool' ;\
"

#------------------------------------------
# ARGO
#------------------------------------------
set argo_musts       = "design_name project"
set argo_defs = ";\
-profiler         <>        'profiler file for setting compute resources. default location is in inter or script_local';\
-desc	          <>        'k8s pod name. 20 char limit . default is running dir name';\
-working_dir      <>        'innovus working dir. all other tools will follow the same suffix (after pnr)';\
-pnr	          false     'run Place and Route flow';\
-eco	          false     'run STA eco flow';\
-eco_num          <>        'run eco number ';\
-eco_do           STA       'echo will do STA , SEM ';\
-drc	          false     'add DRC to eco flow';\
-lvs	          false     'add LVS to eco flow';\
-ant	          false     'add ANT to eco flow';\
-create_folder    false     'create missing starrc/pt/drc/lvs/and/rhsc folders';\
-innovus_-------- <>        '----------------------------------------------------------------------------------------------------------------------------------------------------------------------------';\
-design_name      <>        'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project          <>        'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-stages           <>        'Comma seperated list. Options: floorplan / place / cts / route / chip_finish / dummy / merge / eco . \-BSS\-Default is all but floorplan\-BSE\-';\
-batch            true      'Run in batch mode - run stages one after another';\
-place_start_from db        'floorplan (db) , def , syn , syn_incr';\
-flow_start_from  db        'If place starts from db/syn - should the flow start from floorplan (db) OR def OR syn stylus db ';\
-place_opt        0         'Number of place opt loops. 0 means None.';\
-break_cts        false     'If true, runs ccopt_design -cts, and opt_design -setup seperatly, instead of full ccopt_design. Use \-BSS\-scripts_local/post_cts_pre_opt.tcl\-BSE\- to run commands before opt_design -setup';\
-vt_effort        medium    'high - Use all VT types. medium - Dont user ULVT. low - Dont use ULVT and ULVTLL';\
-useful_skew      false     'if true, allow cadence opt tools to apply useful skew';\
-ecf	          false     'if true, allow cadence opt tools to apply early clock flow';\
-create_ilm       false     'Create ilm for hierarchical flow - Adds runtime';\
-create_lib       false     'Create lib for hierarchical flow - Adds runtime';\
-create_lib_pt    false     'Create lib for hierarchical flow - using PrimeTime. options are true, false, only';\
-create_spef      false     'Create spef for hierarchical flow - Adds runtime';\
-via_pillars      false     'Insert via pillars if possible';\
-open             <>        'Stage to open';\
-refresh          false     'If refresh == lef, reads lef from setup. If regresh == lib, recreate mmmc and reads it. I both, do both. If false, reads from DB';\
-syn_dir          <>        'Syn folder to start from. \-BSS\-Default is syn OR syn_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-';\
-wait_for_syn     false     'wait for synthesis to end before running';\
-netlist          <>        'Default - \-BSS\-SYN_DIR/out/DESIGN_NAME.Syn.v.gz\-BSE\-';\
-scandef          <>        'Default - \-BSS\-SYN_DIR/out/DESIGN_NAME.Syn.scandef.gz\-BSE\-';\
-io_buffers_dir   in        'in / in_ant / out / both / both_ant / none (default)';\
-scan             true      'Run insert_dft and scan-related processes';\
-ocv              true      'Run in ocv mode';\
-manual_fp        false     'If True, stops pre user manua_fp stage. If False, run your manual FP recipe';\
-interactive      false     'Do not exit when done';\
-logv             false     'To produce logv file';\
-sdc_list         <>        'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-def_file         <>        '.def file or .def.gz file. \-BSS\-Default is ./DESIGN_NAME.def  OR ../inter/DESIGN_NAME.def\-BSE\-';\
-stop_after       <>        'Stop after this stage - fp/place/cts_cluster/cts/route';\
-force            false     'Start new stage without checking if the previous was done';\
-local            false     'If true run do_ file from scripts_local folder';\
-other_args       <>        'Other arguments as a string. This string will be sourced as is in the tool';\
-user_inputs       false     'read same user inputs as last run. need to define k8s flags again.';\
-scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
-help             false     'Prints help for the relevant tool' ;\
"


#------------------------------------------
# STARRC
#------------------------------------------
set starrc_musts = ""
set starrc_defs = ";\
-k8s	          true          'Run through k8s';\
-win	          false         'open k8s terminal and run in it.';\
-term_options     <>            'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server       <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display      <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	          hw-be         'set k8s label';\
-desc	          <>            'k8s pod name. 20 char limit . default is running dir name';\
-memory	          60            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-tail	          false         'tail after create k8s pod';\
-design_name      <>        	'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project          <>        	'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-cpu              8         	'Default - 8. Number of cpus per run. ';\
-hosts	          localhost:CPU 'localhost';\
-with_dm	  false     	'Default - false';\
-input_db         NDM       	'Default - "NDM". Can be NDM or DEF-';\
-output_file      GPD       	'Default - "GPD". Can be GPD or SPEF-';\
-stage      	  chip_finish   'Default -chip_finish. ';\
-pnr_dir          <>        	'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
-dm_dir      	  <>        	'Default - ';\
-pnr_def          <>        	'def file for starrc run. Default is <PNR_DIR>/out/def/<design_name>.<stage>.def.gz ';\
-pnr_ndm          <>        	'def file for starrc run. Default is <PNR_DIR>/out/<design_name>_lib ';\
-dm_oasis_file    <>        	'Default - ';\
-oasis_files  	  <>		'Default - ';\
-flat		  false		'Default -false. Running flat extraction';\
-local            false     	'If true take do cmd file from scripts_local folder';\
-scripts_version  <>            'scripts version. defaul will take the latest from be_repository' ;\
-tool_version     <>        	'starrc version. default will be define in run_starrc.csh' ;\
-help             false         'Prints help for the relevant tool' ;\
"
#------------------------------------------
# PrimeTime
#------------------------------------------
set pt_musts = ""
set pt_defs = ";\
-k8s	             true/false    'Run through k8s. Defaults: \-BSS\-BE - true. FE - false\-BSE\-.';\
-win	             false         'open k8s terminal and run in it.';\
-term_options        <>            'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server          <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display         <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	             hw-be         'set k8s label';\
-desc	             <>            'k8s pod name. 20 char limit . default is running dir name';\
-memory	             50            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-tail	             false         'tail after create k8s pod';\
-fe_mode             false         'Do not run BE related stuff. Faster syn for FE';\
-design_name         <>            'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project             <>            'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-cpu                 2             'Number of cpus per run. (default 16)';\
-stage               chip_finish   '';\
-interactive         false         'Do not exit when done';\
-constraints_root    <>            'location for central constraint definition file';\
-sdc_list            <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-pba_mode 	     exhaustive	   'options for pba mode are: none , path , exhaustive';\
-ocv 		     pocv	   'ocv setting: none , flat , pocv(default)';\
-io_clock_latency    true          'run with automatic calculated clock latency for io';\
-xtalk 		     true/false    'run with si information. true when reading parasitic file. false else';\
-read_spef	     false         'read parasitic spef file. default is reading gpd';\
-read_gpd	     true          'read this gpd files';\
-spef_files          <>            'read this spef files. when running single view. wrap list of files is "" ';\
-gpd_files           <>            'read this spef files. wrap list of files is "" ';\
-spef_dir            <>            'Spef folder containing all spef corners. \-BSS\-Default is starrc_SUFFIX-TO-MATCH-YOUR-PT-NAME\-BSE\-';\
-gpd_dir             <>            'GPD folder containing all GPD corners. \-BSS\-Default is starrc_SUFFIX-TO-MATCH-YOUR-PT-NAME\-BSE\-';\
-pnr_dir             <>        	   'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PT-NAME\-BSE\-'';\
-netlist             <>            'read this netlists file list. default is taking netlist from pnr/out/db/stage/design_name.v.gz';\
-flat_netlist        true          'netlist is hierarchy or flat;\
-create_blackbox     false         'If true, the tool will automatically convert unresolved references to blackboxes';\
-hosts	             localhost     'servers to run dmsa. should be localhost , nextk8s, list of servers between quatation marks';\
-single		     false         'run PT in single mode';\
-views		     <>		   'run list of views in list separated with spaces. default in the run_pt.csh';\
-views_list          <>		   'print list of views';\
-eco		     false  	   'run fix eco timing';\
-eco_num 	     <> 	   'run fix eco timing number';\
-physical 	     false 	   'eco stage is done with physical information default false';\
-create_lib 	     false 	   'create .lib file. default false';\
-create_lib_only     false 	   'create only lib files without any reports';\
-create_hs           false         'create hyperscale model';\
-rh_out 	     false    	   'output redhawk timing windows file';\
-restore 	     false         'restore sessions';\
-session             <>            'Provide single session to restore - override the usage of VIEWS';\
-power_reports       false         'generate power reports using Prime Power';\
-timing_reports      true          'generate timing reports';\
-vcd_file            false         'read this activity file for power reports using Prime Power';\
-vcd_type            rtl           'can be  empty (for timing simulation) , rtl , zero_delay';\
-vcd_block_path      <>            'the block hierarchy path inside the VCD';\
-block_path          <>            'the block hierarchy path inside the DESIGN';\
-vcd_start           <>            'can be empty for taking all simulation, otherwise VCD START time';\
-vcd_end             <>            'can be empty for taking all simulation, otherwise VCD END time';\
-map_file            <>            'map file for rtl simulation';\
-save_power          false         'save session after reading power VCD';\
-other_args          <>            'Other arguments as a string. This string will be sourced as is in the tool. \-BSS\- Must be within /appost/ YOUR STRING /appost/ \-BSE\-';\
-user_inputs         false         'read same user inputs as last run. need to define k8s flags again.';\
-local               false         'If true run  do_fm  from scripts_local folder.';\
-scripts_version     <>            'scripts version. defaul will take the latest from be_repository' ;\
-tool_version        <>        	   'PrimeTime version. default will be define in run_pt.csh' ;\
-help                false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# PTPX
#------------------------------------------
set ptpx_musts = ""
set ptpx_defs = ";\
-k8s	             false         'Run through k8s';\
-win	             false         'open k8s terminal and run in it.';\
-vnc_server          <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display         <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	             <>            'set k8s label';\
-desc	             <>            'k8s pod name. 20 char limit . default is running dir name';\
-memory	             50            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-design_name         <>            'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project             <>            'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-cpu                 2             'Number of cpus per run. (default 16)';\
-stage               syn	   '';\
-interactive         false         'Do not exit when done';\
-constraints_root    <>            'location for central constraint definition file';\
-sdc_list            <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-ocv 		     none	   'ocv setting: none , flat , pocv(default)';\
-io_clock_latency    false          'run with automatic calculated clock latency for io';\
-read_spef	     false          'read parasitic spef file. default is reading gpd';\
-read_gpd	     false         'read this gpd files';\
-spef_files          <>            'read this spef files. when running single view. wrap list of files is "" ';\
-gpd_files           <>            'read this spef files. wrap list of files is "" ';\
-netlist             <>            'read this netlists file list. default is taking netlist from pnr/out/db/stage/design_name.v.gz';\
-views		     <>		   'run list of views in list separated with spaces. default in the run_pt.csh';\
-timing_reports      false          'generate timing reports';\
-restore 	     false         'restore sessions';\
-session             <>            'Provide single session to restore - override the usage of VIEWS';\
-vcd_file            false         'read this activity file for power reports using Prime Power';\
-vcd_type            rtl           'can be  empty (for timing simulation) , rtl , zero_delay';\
-vcd_block_path      <>            'the block hierarchy path inside the VCD';\
-block_path          <>            'the block hierarchy path inside the DESIGN';\
-vcd_start           <>            'can be empty for taking all simulation, otherwise VCD START time';\
-vcd_end             <>            'can be empty for taking all simulation, otherwise VCD END time';\
-map_file            <>            'map file for rtl simulation';\
-save_power          false         'save session after reading power VCD';\
-other_args          <>            'Other arguments as a string. This string will be sourced as is in the tool. \-BSS\- Must be within /appost/ YOUR STRING /appost/ \-BSE\-';\
-local               false         'If true run  do_fm  from scripts_local folder.';\
-scripts_version     <>            'scripts version. defaul will take the latest from be_repository' ;\
-tool_version        <>        	   'PrimeTime version. default will be define in run_pt.csh' ;\
-help                false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# Joules
#------------------------------------------
set joules_musts       = "design_name project"
set joules_defs = ";\
-design_name             <>            'MUST - partition/block name';\
-project                 <>            'MUST - nxt008 / nxt007 etc.';\
-fe_mode                 false         '' ;\
-cpu                     8             'Number of cpus per run. (default 8)';\
-interactive             true          'Do not exit when done';\
-sdc_list                <>            'SDC FILES' ;\
-netlist                 <>            'Default - ../syn/out/DESIGN_NAME.Syn.v.gz';\
-filelist                <>            'Filelist';\
-stim_file               <>            'fsdb/vcd etc.';\
-map_file                <>            'syn generated do<>map file';\
-help                    false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# Voltus
#------------------------------------------
set voltus_musts       = "netlist design_name project"
set voltus_defs = ";\
-design_name                <>            'MUST - partition/block name';\
-project                    <>            'MUST - nxt008 / nxt007 etc.';\
-cpus                       8             'Number of cpus per run. (default 8)';\
-is_interactive             true          'Do not exit when done';\
-is_ocv                     false         '';\
-netlist                    <>            '';\
-spef_list                  <>            '';\
-sdc_list                   <>            '';\
-views_list                 <>            '';\
-def                        <>            '';\
-global_activity            0.1           'Activity factor for set_default_switching_activity';\
-input_activity             <>            'Activity factor for set_default_switching_activity';\
-sequential_activity        <>            'Activity factor for set_default_switching_activity';\
-clock_gates_output         1.4           'Activity factor for set_default_switching_activity';\
-stim_file                  <>            'fsdb/vcd etc.';\
-map_file                   <>            'syn generated do...map file';\
-nextinside                 <>            'dunno';\
-create_db                  true          '';\
-power_method               static        '';\
-rail_analysis_temperature  125           '';\
-tmpdir                     /local/tmp    '';\
-help                    false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# Tempus
#------------------------------------------
set tempus_musts       = "design_name project"
set tempus_defs = ";\
-design_name                <>            'MUST - partition/block name';\
-project                    <>            'MUST - nxt008 / nxt007 etc.';\
-cpus                       8             'Number of cpus per run. (default 8)';\
-is_interactive             true          'Do not exit when done';\
-is_ocv                     false         '';\
-read_spef                  true          '';\
-physical                   false         '';\
-netlist                    <>            '';\
-stage                      chip_finish   '';\
-spef_list                  <>            '';\
-sdc_list                   <>            '';\
-views_list                 <>            '';\
-def                        <>            '';\
-save_eco_db                false         '';\
-dsta                       false         '';\
-hosts                      localhost     '';\
-innovus_dir                ../pnr        '';\
-spef_dir                   ../qrc        '';\
-nextinside                 <>            'dunno';\
-tmpdir                     /local/tmp    '';\
-other_args                 <>        'Other arguments as a string. This string will be sourced as is in the tool';\
-help                    false         'Prints help for the relevant tool' ;\
"


#------------------------------------------
# LEC
##------------------------------------------
set lec_musts       = "design_name project"
set lec_modes       = "eco rtl2rtl rtl2rtl_flat rtl2elab elab2syn rtl2map map2syn rtl2syn rtl2syn_flat net2net syn2place syn2dft dft2place place2route scantest route2chip_finish"
set lec_defs = ";\
-k8s	                 true/false    'Run through k8s. Defaults: \-BSS\-BE - true. FE - false\-BSE\-.';\
-win	                 false         'open k8s terminal and run in it.';\
-term_options            <>            'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server              <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display             <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	                 <>            'set k8s label';\
-desc	                 <>            'k8s pod name. 20 char limit . default is running dir name';\
-memory	                 50            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-tail	                 false         'tail after create k8s pod';\
-cpu                     4             'Number of cpus per run. (default 8)';\
-fe_mode                 false         'Do not run BE related stuff. Faster syn for FE';\
-design_name             <>            'MUST - partition/block name';\
-project                 <>            'MUST - nxt008 / nxt007 etc.';\
-lec_mode                <>            'Options:  $lec_modes';\
-interactive             false         'Do not exit when done';\
-syn_dir      		 <>            'Default - syn folder to start from. \-BSS\-Default is syn_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
-innovus_dir             <>            'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
-golden_netlist          <>            'Defaults: filelist , syn_map   , syn_opt   , place';\
-revised_netlist         <>            'Defaults: syn_map  , syn_opt   , place     , pnr_final';\
-disable_scan            false         'will disable dft signals from golden and revised';\
-dofile                  <>            'point to outside do file ';\
-use_tool_dofile         false         'work for rtl2map,map2syn,dft2place only, will take dofile script from genus/innovus output';\
-constraints_root        <>            'location for central constraint definition file';\
-sdc_list                <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-eco_num 	         <> 	       'eco number';\
-restore                 false         'restore previous session';\
-other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool';\
-local                   false         'If true run  do_fm  from scripts_local folder.';\
-scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
-tool_version            <>            'lec version. default will be define in run_lec.csh' ;\
-help                    false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# Formality
##------------------------------------------
set fm_musts       = "design_name project"
set fm_modes       = "rtl2syn syn2place syn2dft net2net dft2place place2route route2chip_finish"
set fm_defs = ";\
-k8s	                 true/false    'Run through k8s. Defaults: \-BSS\-BE - true. FE - false\-BSE\-.';\
-win	                 false         'open k8s terminal and run in it.';\
-term_options            <>            'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server              <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display             <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	                 hw-be         'set k8s label';\
-desc	                 <>            'k8s pod name. 20 char limit . default is running dir name';\
-dpx	                 false         'run FM in DPX mode';\
-memory	                 50            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-cpu                     4             'Number of cpus per run. (default 8)';\
-tail	                 false         'tail after create k8s pod';\
-fe_mode                 false         'Do not run BE related stuff. Faster syn for FE';\
-design_name             <>            'MUST - partition/block name';\
-project                 <>            'MUST - nxt008 / nxt007 etc.';\
-fm_mode                 <>            'Options:  $fm_modes';\
-interactive             false         'Do not exit when done';\
-syn_dir      		 <>            'Default - syn folder to start from. \-BSS\-Default is syn_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
-innovus_dir             <>            'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
-fusion_dir              <>            'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
-golden_netlist          <>            'Defaults: filelist , syn_map   , syn_opt   , place';\
-revised_netlist         <>            'Defaults: syn_map  , syn_opt   , place     , pnr_final';\
-svf_file                <>            'svf file';\
-disable_scan            <>            'will disable dft signals from golden and revised';\
-use_tool_dofile         false         'work for rtl2map,map2syn,dft2place only, will take dofile script from genus/innovus output';\
-restore                 false         'restore previous session';\
-other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool';\
-local                   false         'If true run  do_fm  from scripts_local folder.';\
-scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
-tool_version            <>            'formality version. default will be define in run_.csh' ;\
-help                    false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# LC
#------------------------------------------
set lc_musts       = "libs_dir "
set lc_defs = ";\
-design_name             <>            'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project                 <>            'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-libs_dir                <>            'Libs Directory';\
-db_dir                  <>            'db destination directory. Default == libs_dir';\
-help                    false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# Redhawk_SC
#------------------------------------------
set rhsc_musts       = "design_name project"
set rhsc_defs = ";\
-k8s	                    false          	    'Run through k8s';\
-win	                    false          	    'open k8s terminal and run in it.';\
-term_options               <>             	    'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server                 <>             	    'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display                <>             	    'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	                    hw-be         	    'set k8s label';\
-image	                    hw-ldap-rocky-9:latest  'set k8s OS image';\
-desc	                    <>            	    'k8s pod name. 20 char limit . default is running dir name';\
-memory	                    50            	    'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-cpu                        16            	    'Number of cpus per run. (default 16)';\
-design_name                <>            	    'MUST - partition/block name';\
-grid                       local         	    'run using local resources or k8s. options: local , k8s ';\
-project                    <>            	    'MUST - nxt008 / nxt007 etc.';\
-pnr_dir                    <>            	    'Default - PNR folder to start from. \-BSS\-Default is pnr_SUFFIX-TO-MATCH-YOUR-PNR-NAME\-BSE\-'';\
-starrc_dir                 <>            	    'starrc running dir. \-BSS\-Default is starrc_SUFFIX-TO-MATCH-YOUR-PT-NAME\-BSE\-';\
-constraints_root           <>            	    'location for central constraint definition file';\
-sdc_list                   <>            	    'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-gpd_dir                    <>            	    'GPD folder containing all GPD corners. \-BSS\-Default is starrc_SUFFIX-TO-MATCH-YOUR-RHSC-NAME\-BSE\-';\
-pt_dir                     <>            	    'pt running dir. \-BSS\-Default is pt_SUFFIX-TO-MATCH-YOUR-RHSC-NAME\-BSE\-';\
-stage                      chip_finish   	    '';\
-create_db                  false         	    'running innovus to create top PG layers DEF and ploc file.';\
-create_twf                 true          	    'running primetime  to create timing window file.';\
-analyse_type               static        	    'running IR analysis mode. options are static / dynamic / sigem.';\
-twf                        <>            	    'Timing Windows file created by PrimeTime. \-BSS\-Default is pt_SUFFIX-TO-MATCH-YOUR-RHSC-NAME/out/rhtf/DESIGN_NAME_PVT.rh.timing.gz\-BSE\-';\
-ploc_file                  <>           	    'power source location file. created by innovus run.';\
-def_file                   <>           	    'created by innovus';\
-scripts_version            <>           	    'scripts version. defaul will take the latest from be_repository' ;\
-tool_version               <>           	    'rhsc version. default will be define in run_.csh' ;\
-help                       false        	    'Prints help for the relevant tool' ;\
"

#------------------------------------------
# Lib Generator
#------------------------------------------
set lib_gen_musts       = "design_name project"
set lib_gen_defs = ";\
-k8s	                 true/false    'Run through k8s. Defaults: \-BSS\-BE - true. FE - false\-BSE\-.';\
-win	                 false         'open k8s terminal and run in it.';\
-term_options            <>            'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server              <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display             <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	                 <>            'set k8s label';\
-desc	                 <>            'k8s pod name. 20 char limit . default is running dir name';\
-memory	                 60            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-tail	                 false         'tail after create k8s pod';\
-design_name             <>            'Default - nextflow/be_work/project_name/\-BSS\-block_name\-BSE\-';\
-project                 <>            'Default - nextflow/be_work/\-BSS\-project_name\-BSE\-/block_name';\
-cpu                     16            'Number of cpus per run. (default 16)';\
-wlm                     true          'run with wireload model.option are false , W1600 , W3600';\
-interactive             false         'Do not exit when done';\
-fe_mode                 false         'Do not run BE related stuff. Faster syn for FE';\
-sdc_list                <>            'Comma seperated list of .sdc files. Will be sourced in order. \-BSS\-Default is ./DESIGN_NAME.sdc OR ../inter/.sdc \-BSE\-';\
-netlist                 <>            'Private netlist file';\
-other_args              <>            'Other arguments as a string. This string will be sourced as is in the tool. \-BSS\- Must be within /appost/ YOUR STRING /appost/ \-BSE\-';\
-user_inputs             false         'read same user inputs as last run. need to define k8s flags again.';\
-local                   false         'If true run do_ file from scripts_local folder';\
-scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
-tool_version            <>            'genus version. default will be define in run_genus.csh' ;\
-help                    false         'Prints help for the relevant tool' ;\
"

#------------------------------------------
# DRC
#------------------------------------------
set drc_musts       = "design_name project"
set drc_defs = ";\
-k8s	                 true          'Run through k8s. Defaults: true..';\
-win	                 false         'open k8s terminal and run in it.';\
-term_options            <>            'option for xterm/xfc4-terminal when running in win /open / intercative mode.';\
-vnc_server              <>            'VNC server to open the shell. default from ~/.VNC_SERVER file first line. ';\
-vnc_display             <>            'VNC server display number to open the shell. default from ~/.VNC_SERVER file second line. ';\
-label	                 hw-be         'set k8s label';\
-desc	                 <>            'k8s pod name. 20 char limit . default is running dir name';\
-memory	                 40            'nextk8s peak memory usage. take numbers per stage from ../inter/k8s_memory_profiler if exists. else default is 60GB';\
-cpu                     16            'Number of cpus per run. (default 16)';\
-tail	                 false         'tail after create k8s pod';\
-design_name             <>            'MUST - partition/block name';\
-project                 <>            'MUST - nxt008 / nxt007 etc.';\
-layout_file             <>            'Default - ../pnr<>/out/gds/DESIGN_NAME.oas';\
-pnr_dir                 <>            'Default - ../pnr<>';\
-type                    drc           'run this type of drc: drc / package / ant / dodpo / dm ';\
-local                   false         'search for RUNSET in scripts_local folder';\
-scripts_version         <>            'scripts version. defaul will take the latest from be_repository' ;\
-tool_version            <>            'genus version. default will be define in run_genus.csh' ;\
-help                    false         'Prints help for the relevant tool' ;\
"

###########################################
#------------------------------------------
# DETERMINE INPUTS
#------------------------------------------
###########################################

if ( $#argv == 0 ) then    
    echo $help
    exit
endif

set flow_options = "rtla|genus|dc|innovus|joules|voltus|tempus|lc|starrc|lec|pt|fm|rhsc|argo|ptpx|lib_gen|fusion|drc"
set flow = `echo $argv | grep -Eo "\b($flow_options)\b" | head -n 1`
#set flow    = `echo $argv | grep -o '^tempus \| tempus$\|^tempus$\|^genus \| genus$\|^genus$\|^innovus \| innovus\|^innovus$\|^joules \| joules\|^joules$\|^voltus \| voltus\|^voltus$'`
#set is_help = `echo $argv | grep -o '\-help'`

###########################################
#------------------------------------------
# DETERMINE FLOW
#------------------------------------------
###########################################

echo "-I- flow $flow"
if ("$flow" == "") then
    echo "\033[1;31;40m-E- $flow Is not a valid flow name\033[0m"
    echo $help
    exit
endif

set defs  = `eval echo \$${flow}_defs`
set musts = `eval echo \$${flow}_musts`




###########################################
#------------------------------------------
# PARSE DEFAULTS
#------------------------------------------
###########################################
set defs_tr = `echo $defs | tr " " "=" | sed 's/==//g'`
set split    = ($defs_tr:as/;/ /)

set flags_list = ""

foreach line ($split )

    if ( "$line" == "=" ) then
        continue 
    endif

    set clean_line = `echo $line | tr "=" " "`
    set flag       = $clean_line[1]
    set value      = $clean_line[2]

    if ( "$value" == "<>" ) then
        set value = "None"
    endif

    set flag_name  = `echo $flag | sed 's/-//g'`
    set flags_list = "$flags_list $flag_name"        
    set set_cmd    = "set `echo $flag_name` = $value"
#        echo $set_cmd
    eval $set_cmd

end
        
if (`echo $argv| grep "-user_inputs" | wc -l` > 0) then
    if (! -f user_inputs.tcl)  then
       echo "Error: missing existing user inputs file."
       echo "       running with default values"
    else
        set inputfile = "`cat user_inputs.tcl| grep set`"
        set i=1
        while ($i <= $#inputfile)
            set flag_name_ = `echo $inputfile[$i] | awk '{print $2}' | tr "[:upper:]" "[:lower:]"`
            set value_ = `echo $inputfile[$i] | awk '{$1="";$2=""}1'`
#            echo "$value : $flag "
            set set_cmd    = "set `echo $flag_name_` = $value_"
            eval $set_cmd
            @ i ++
        end
       
    endif
endif
#echo $flags_list


###########################################
#------------------------------------------
# PARSE FLAGS
#------------------------------------------
###########################################

set index = 1
while ($index < $#argv) 
    @ index = $index + 1
    foreach flag ($flags_list )
        set jndex = $index
        @ jndex ++
        if ( "-$flag" == "$argv[$index]" ) then
	    set value = ""
	    set while_flag = 1	   
	    if ($jndex > $#argv) then
	        set while_flag = 0
	    endif
	    while ($while_flag) 
		if ($flag == "term_options") then
		    	set value = "$argv[$jndex]"
 		        @ jndex++
	                set while_flag = 0
		else if ("$argv[$jndex]" =~ "-*" || "$argv[$jndex]" == "" ) then
	            set while_flag = 0
	        else
	            if ("$value" == "") then 
		    	set value = "$argv[$jndex]"
		    else
                        set value = "$value $argv[$jndex]"
		    endif
 		    @ jndex++
                endif
	       
	        if ($jndex > $#argv) then
	            set while_flag = 0
	        endif
	    end
	    
            # Accept boolean flags
	    if ("$value" == "") then 
	    	set value = "true"
	    endif
	    
            set  set_cmd  = "set `echo $flag` = "\""$value"\"
            echo "-I- $set_cmd"
            eval $set_cmd
	
    	else if ( "$argv[$index]" =~ "-*debug" ) then
            set is_debug = "true"
    	else if ( "$argv[$index]" =~ "-*fast" ) then
            set is_fast = "true"
        endif
        
    end

end

###########################################
#------------------------------------------
# HELP
#------------------------------------------
###########################################
if ( "$help" == true ) then
    echo $help
    
    if ( "$flow" != "" ) then
#        echo $defs | sed 's/;/\n/g' 
        ./scripts/bin/print_help.tcl $defs
    endif        
    
    exit
endif 

#set other_args_flag = false
#set other_args_list = ()
#
#foreach flag ($flags_list )
#
#    set index = 1 
#
#    foreach arg ($argv )
#       
#        @ index = $index + 1
#	echo "index $index ; arg $arg"
#	
#        if ( $other_args_flag == true && "$arg" =~ -[a-z]* ) then
#            set other_args_flag = false
#        endif
#
#        if ( "-$flag" == "$arg" ) then
#            set  tmp_value = `eval echo \$$index`
#            set  def_value = `eval echo \$$index`
#            
#            # Accept other args
#            if ( "$arg" == "-other_args" ) then
#                set other_args_flag = true
#            else
#                set other_args_flag = false                
#            endif 
#            
#            # Accept boolean flags
#            if ( "$tmp_value" =~ "-*" || "$tmp_value" == "" ) then
#                set value = "true"                      
#            else
#                set value = $tmp_value
#            endif
#            
#            if ( $other_args_flag == false ) then
#                set  set_cmd  = "set `echo $flag` = $value"
#                echo "-I- $set_cmd"
#                eval $set_cmd
#            endif
#        else if ( $other_args_flag == true ) then
#            set other_args_list = ( $other_args_list $arg )
#        endif
#
#        if ( "$arg" =~ "-*debug" ) then
#            set is_debug = "true"
#        endif
#
#    end
#
#end


###########################################
#------------------------------------------
# FIND ILEGAL FLAGS
#------------------------------------------
###########################################
foreach arg ($argv )

    set legal = true
    
    if ( "$arg" =~ -[a-z]* ) then    	       
        set legal = false
        foreach flag ($flags_list )
            if ( "-$flag" == "$arg" || "$arg" =~ "-*debug" || "$arg" =~ "-fast") then
                set legal = true
            endif
        end
    endif

    if ( $legal == false ) then
        echo "\n###########################################\n\033[1;31;40m-E- $arg is not a legal flag for $flow\033[0m\n###########################################\n"
        echo $help
        if ( "$flow" != "" ) then
#            echo $defs | sed 's/;/\n/g' 
            ./scripts/bin/print_help.tcl $defs
        endif        
        exit        
    endif

end



###########################################
#------------------------------------------
# VERIFY 
#------------------------------------------
###########################################

if (! $?terminal) then 
   if ( -f ~/TERMINAL ) then
      set terminal = `head -n1 TERMINAL`
   else
      if (`whoami` == "meravi") then
         set terminal = "xterm"
      else
         set terminal = "xfce4-terminal"
      endif
   
   endif    
endif
if (  $?term_options) then       
   if ( $term_options != "None") then
         set terminal = "$terminal $term_options"
   endif
endif


if (! $?vnc_server) then       
  set vnc_server = "None"
endif 
if (! $?vnc_display) then       
  set vnc_display = "None"
endif 

if ($vnc_server == "None") then       
   if ( -f ~/.VNC_SERVER ) then
      set vnc_server = `head -n1 ~/.VNC_SERVER`
   endif 
endif
if ($vnc_display == "None") then       
   if ( -f ~/.VNC_SERVER ) then
      set vnc_display = `tail -n1 ~/.VNC_SERVER`
   endif 
endif

if ( "$k8s" == "true/false" ) then    
    if ( $fe_mode == "true" ) then
        set k8s = "false"
    else
        set k8s = "true"        
    endif
endif

#------------------------------------------
# TREAT UNDEFINED VARS (IN JOULES VS OTHER FLOWS)
#------------------------------------------
if (! $?fe_mode) then       
  set fe_mode = "false"
endif 

if (! $?sdc_list) then       
  set sdc_list = "None"
endif 

if (! $?def) then       
  set def = "None"
endif 

if ( $flow == "joules" ) then

    if ( "$design_name" == "None" ) then
        set design_name = `pwd | tr "/" " " | awk '{print $(NF-2)}'`
    endif 

    if ( "$project" == "None" ) then
        set project     = `pwd | tr "/" " " | awk '{print $(NF-3)}'`
    endif     
    
    if ( "$netlist" != "None" && $filelist != "None" ) then
        echo "-E- Netlist and fileslit are mutually exclusive"
	exit 1
    endif
    
    if ( "$netlist" == "None" && $filelist == "None" ) then
        echo "-E- Must define either netlist or filelist"
	exit 1
    endif
    
endif


#------------------------------------------
# FOR BE ONLY - EXTRACT BLOCK AND PROJECT FROM PATH
#------------------------------------------
if ( $flow == "innovus" || "$fe_mode" != "true" ) then

    if ( "$design_name" == "None" ) then
        set design_name = `pwd | tr "/" " " | awk '{print $(NF-2)}'`
    endif 

    if ( "$project" == "None" ) then
        set project     = `pwd | tr "/" " " | awk '{print $(NF-3)}'`
    endif     
endif


#------------------------------------------
# VERIFY MUSTS
#------------------------------------------
foreach must ($musts )

    set value =  `eval echo \$$must`
    if ( "$value" == "None" ) then
        echo "-E- Flag '$must' can not be empty"
        exit
    endif

end

if (! $?def_file) then
    set def_file = "None"
endif

if (! $?open) then
    set open = ""
endif

#------------------------------------------
# VERIFY FILES - sdc
#------------------------------------------    
if ( "$sdc_list" != "None" ) then 
    if (! $?wait_for_syn) then
        set split    = ($sdc_list:as/,/ /)        
        foreach file ($split )
            if ( ! -e "$file" ) then
                echo "\033[1;31;40m-E- SDC file: $file not found\033[0m"
                exit
            endif
        end
    else
        if ($wait_for_syn == "false") then
            set split    = ($sdc_list:as/,/ /)        
            foreach file ($split )
                if ( ! -e "$file" ) then
                    echo "\033[1;31;40m-E- SDC file: $file not found\033[0m"
                    exit
                endif
            end
	endif
    endif
endif

#------------------------------------------
# VERIFY FILES - def
#------------------------------------------        
if ( "$def_file" != "None" ) then
    if (! $?wait_for_syn) then
        if ( ! -e "$def_file" ) then
            echo "\033[1;31;40m-E- DEF file: $def_file not found\033[0m"
            exit
        endif
    else
        if ($wait_for_syn == "false") then
            if ( ! -e "$def_file" ) then
                echo "\033[1;31;40m-E- DEF file: $def_file not found\033[0m"
                exit
            endif
	endif
    endif
endif



#------------------------------------------
# VERIFY GENUS
#------------------------------------------    
if ( $flow == genus && "$open" != "" ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is genus"
    endif


    #------------------------------------------
    # SOME FE/BE DIFFERENT DEFAULTS
    #------------------------------------------        
    if ( "$scan" == "true/false" ) then    
    	if ( $fe_mode == "true" ) then
			set scan = false
        else
			set scan = true        
        endif
    endif
    if ( "$create_lib" == "false/true" ) then    
    	if ( $fe_mode == "true" ) then
			set create_lib = true
        else
			set create_lib = false        
        endif
    endif
    
    if ( "$remove_flops" == "true/false" ) then    
    	if ( $fe_mode == "true" ) then
			set remove_flops = false
        else
			set remove_flops = true        
        endif
    endif    
    
    if ( "$flat_design" == "None" && "$fe_mode" == true ) then
        set flat_design = false
    endif

    if ( "$flat_design" == "None" && "$fe_mode" == false ) then
        set flat_design = save_design
    endif    
    
    if ( "$detailed_timing" == "true/false" ) then    
    	if ( $fe_mode == "true" ) then
			set detailed_timing = true
        else
			set detailed_timing = false        
        endif
    endif      


    #------------------------------------------
    # VERIFY RTL SOURCE
    #------------------------------------------        
#    if ( "$nextinside" == "None" ) then
#        if ( $fe_mode == "true" && $open == "None" ) then
#            if ( "$?REPO_ROOT" == 0 ) then
#                echo "\033[1;31;40m-E- No nextinside or REPO_ROOT specified\033[0m"
#                exit
#            else
#                echo "-I- Running in FE mode"
#                echo "set nextinside = $REPO_ROOT"
#                set nextinside = $REPO_ROOT            
#            endif            
#        else
#            echo "-I- Running in BE mode"
#            echo "-I- set nextinside = $BE_DEFAULT_NEXTINSIDE"
#            set nextinside = $BE_DEFAULT_NEXTINSIDE
#        endif
#    endif    


endif 
#------------------------------------------
# END VERIFY GENUS
#------------------------------------------    

#------------------------------------------
# VERIFY DC
#------------------------------------------    
if ( $flow == dc && "$open" != "" ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is dc"
    endif


    #------------------------------------------
    # SOME FE/BE DIFFERENT DEFAULTS
    #------------------------------------------        
    if ( "$scan" == "true/false" ) then    
    	if ( $fe_mode == "true" ) then
			set scan = false
        else
			set scan = true        
        endif
    endif
    if ( "$create_lib" == "false/true" ) then    
    	if ( $fe_mode == "true" ) then
			set create_lib = true
        else
			set create_lib = false        
        endif
    endif
    
    if ( "$remove_flops" == "true/false" ) then    
    	if ( $fe_mode == "true" ) then
			set remove_flops = false
        else
			set remove_flops = true        
        endif
    endif    
    
    if ( "$flat_design" == "None" && "$fe_mode" == true ) then
        set flat_design = false
    endif

    if ( "$flat_design" == "None" && "$fe_mode" == false ) then
        set flat_design = syn_opt
    endif    
    
    if ( "$detailed_timing" == "true/false" ) then    
    	if ( $fe_mode == "true" ) then
			set detailed_timing = true
        else
			set detailed_timing = false        
        endif
    endif      


    #------------------------------------------
    # VERIFY RTL SOURCE
    #------------------------------------------        
#    if ( "$nextinside" == "None" ) then
#        if ( $fe_mode == "true" && $open == "None" ) then
#            if ( "$?REPO_ROOT" == 0 ) then
#                echo "\033[1;31;40m-E- No nextinside or REPO_ROOT specified\033[0m"
#                exit
#            else
#                echo "-I- Running in FE mode"
#                echo "set nextinside = $REPO_ROOT"
#                set nextinside = $REPO_ROOT            
#            endif            
#        else
#            echo "-I- Running in BE mode"
#            echo "-I- set nextinside = $BE_DEFAULT_NEXTINSIDE"
#            set nextinside = $BE_DEFAULT_NEXTINSIDE
#        endif
#    endif    


endif 
#------------------------------------------
# END VERIFY DC
#------------------------------------------    

#------------------------------------------
# VERIFY INNOVUS
#------------------------------------------    
if ( $flow == innovus ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is innovus"
    endif
    if ( "$stages" != "None" ) then 
        set stages  = ($stages:as/,/ /)        
    else if ( $place_start_from == "syn" || $place_start_from == "syn_incr"  || $place_start_from == "def" ) then
        set stages  = "$innovus_stages_no_fp"
    else
        set stages  = "$innovus_stages"
    endif
    
    set stage0 = `echo $stages | awk '{print $1}'`
    if ( $is_debug == "true" ) then
         echo "DEBUG: stage0 is $stage0"
         echo "DEBUG: eco_num is $eco_num"
    endif

    if      ( $stage0 == "cts" ) then
    	set previous_stage = place
    else if ( $stage0 == "route" ) then
    	set previous_stage = cts
    else if ( $stage0 == "chip_finish" && $eco_num == "None" ) then
    	set previous_stage = route        
    else if ( $stage0 == "chip_finish" && ($eco_num == 1 || $eco_num > 1)) then
    	set previous_stage = eco${eco_num}
    else if ( $stage0 == "dummy" ) then
    	set previous_stage = chip_finish        
    else if ( $stage0 == "merge" ) then
    	set previous_stage = dummy        
    else if ( $stage0 == "eco" &&  $eco_num == "None") then
        echo "Error: missing eco_num flag"
	set is_error = "true"
    else if ( $stage0 == "eco" && $eco_num == "1" ) then
    	set previous_stage = route
    else if ( $stage0 == "eco" && $eco_num > "1" ) then
    	set prev_eco_num = $eco_num
	@ prev_eco_num--
    	set previous_stage = eco${prev_eco_num}
    else if ( $place_start_from == "syn" || $place_start_from == "syn_incr" || $place_start_from == "def" ) then
        set previous_stage = syn
    else if ( $place_start_from == "db" && $stage0 == "floorplan" ) then 
        set previous_stage = syn
    else if ( $place_start_from == "db" && $stage0 == "place" ) then 
        set previous_stage = floorplan        
    endif

	#------------------------------------------
	# MATCH SYN DIR
	#------------------------------------------    
    if ( "$syn_dir" == "None" ) then

        set pnr_name = `pwd | tr "/" " " | awk '{print $NF}'`
        
        if ( $pnr_name == "pnr" ) then
            set suffix  = ""
        else 
	        set suffix  = `echo $pnr_name | sed 's/pnr//g'`
        endif

        set syn_dir = "../syn$suffix"
        
    endif
    if ( $create_lib_pt == "true") then
	set create_spef = "true"
    endif
    
	#------------------------------------------
	# VERIFY STOP AFTER
	#------------------------------------------    
    if ( "$stop_after" != "None" && "$stop_after" != "fp" && "$stop_after" != "place" && "$stop_after" != "cts_cluster" && "$stop_after" != "cts" && "$stop_after" != "route" ) then
        echo "\033[1;31;40m-E- In Innovus -stop_after can accept fp, place, cts_cluster, cts or route only\033[0m"
        exit
    endif
    if ( $is_debug == "true" ) then
         echo "DEBUG: end of flow is innovus"
    endif

endif 
#------------------------------------------
# END VERIFY INNOVUS
#------------------------------------------    


#------------------------------------------
# VERIFY FUSION
#------------------------------------------    
if ( $flow == fusion ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is fusion"
    endif
    if ( "$stages" != "None" ) then 
        set stages  = ($stages:as/,/ /)        
    else if ( $inc_init == "true" ) then
        set stages  = "$fusion_stages_dft"
    else
        set stages  = "$fusion_stages"
    endif
    
    set stage0 = `echo $stages | awk '{print $1}'`
    if ( $is_debug == "true" ) then
         echo "DEBUG: stage0 is $stage0"
#         echo "DEBUG: eco_num is $eco_num"
    endif

    if      ( $stage0 == "compile" ) then
    	set previous_stage = init
    else if ( $stage0 == "place" && $inc_init == "true" ) then
    	set previous_stage = init
    else if ( $stage0 == "place" ) then
    	set previous_stage = compile
    else if ( $stage0 == "cts" ) then
    	set previous_stage = place
    else if ( $stage0 == "route" ) then
    	set previous_stage = cts
    else if ( $stage0 == "chip_finish" && $eco_num == "None" ) then
    	set previous_stage = route        
    else if ( $stage0 == "chip_finish" && ($eco_num == 1 || $eco_num > 1)) then
    	set previous_stage = eco${eco_num}
    else if ( $stage0 == "dummy" ) then
    	set previous_stage = chip_finish        
    else if ( $stage0 == "merge" ) then
    	set previous_stage = dummy        
    endif

    if ( $is_debug == "true" ) then
         echo "DEBUG: end of flow is fusion"
    endif

endif 
#------------------------------------------
# END VERIFY FUSION
#------------------------------------------    

#------------------------------------------
# VERIFY RTLA
#------------------------------------------    
if ( $flow == rtla ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is rtla"
    endif
    if ( "$stages" != "None" ) then 
        set stages  = ($stages:as/,/ /)        
    else
        set stages  = "$rtla_stages"
    endif
    echo "stages $stages"
    set stage0 = `echo $stages | awk '{print $1}'`
    if ( $is_debug == "true" ) then
         echo "DEBUG: stage0 is $stage0"
#         echo "DEBUG: eco_num is $eco_num"
    endif

    if      ( $stage0 == "syn" ) then
    	set previous_stage = init
    endif

    if ( $is_debug == "true" ) then
         echo "DEBUG: end of flow is rtla"
    endif

endif 
#------------------------------------------
# END VERIFY RTLA
#------------------------------------------    

#------------------------------------------
# VERIFY LEC
#------------------------------------------    
if ( $flow == lec ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is lec"
    endif
    if ( $lec_mode != "None" ) then
	if ( "$lec_modes" =~ "*$lec_mode*" ) then
	   set STAGE = $lec_mode       
	else
           echo "$lec_modes ; $lec_mode" 
           echo "\033[1;31;40m-E- STAGE $lec_mode is not recognized. Please choose from: $lec_modes\033[0m" ; exit
	endif
    else
        set STAGE = "pnr_final"
    endif
    

    #------------------------------------------
    # MATCH SYN DIR
    #------------------------------------------    
    if ( "$syn_dir" == "None" ) then

        set pnr_name = `pwd | tr "/" " " | awk '{print $NF}'`
        
        if ( $pnr_name == "pnr" ) then
            set suffix  = ""
        else 
	        set suffix  = `echo $pnr_name | sed 's/lec//g'`
        endif

        set syn_dir = "../../syn$suffix"
    else 
        set syn_dir = `realpath $syn_dir`
    endif

    #------------------------------------------
    # MATCH SYN DIR
    #------------------------------------------    
    if ( "$innovus_dir" == "None" ) then

        set pnr_name = `pwd | tr "/" " " | awk '{print $NF}'`
        
        if ( $pnr_name == "lec" ) then
            set suffix  = ""
        else 
	        set suffix  = `echo $pnr_name | sed 's/lec//g'`
        endif

        set innovus_dir = "../../pnr$suffix"
    else 
        set innovus_dir = `realpath $innovus_dir`
    endif
    
    #------------------------------------------
    # full path for netlist
    #------------------------------------------    
    if ( "$golden_netlist" != "None" ) then
        set golden_netlist = `realpath $golden_netlist`
    endif
    if ( "$revised_netlist" != "None" ) then
        set revised_netlist = `realpath $revised_netlist`
    endif






    
endif 
#------------------------------------------
# END VERIFY LEC
#------------------------------------------    

#------------------------------------------
# VERIFY FM
#------------------------------------------    
if ( $flow == fm ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is fm"
    endif

    if ( $fm_mode != "None" ) then
	if ( "$fm_modes" =~ "*$fm_mode*" ) then
	   set STAGE = $fm_mode       
	else
           echo "$fm_modes ; $fm_mode" 
           echo "\033[1;31;40m-E- STAGE $fm_mode is not recognized. Please choose from: $fm_modes\033[0m" ; exit
	endif
    else
        set STAGE = "pnr_final"
    endif
    

#    #------------------------------------------
#    # MATCH SYN DIR
#    #------------------------------------------    
#    if ( "$syn_dir" == "None" ) then
#
#        set pnr_name = `pwd | tr "/" " " | awk '{print $NF}'`
#        
#        if ( $pnr_name == "pnr" ) then
#            set suffix  = ""
#        else 
#	        set suffix  = `echo $pnr_name | sed 's/fm//g'`
#        endif
#
#        set syn_dir = "../../syn$suffix"
#    else 
#        set syn_dir = `realpath $syn_dir`
#    endif
#
#    #------------------------------------------
#    # MATCH innovus DIR
#    #------------------------------------------    
#    if ( "$innovus_dir" == "None" ) then
#
#        set pnr_name = `pwd | tr "/" " " | awk '{print $NF}'`
#        
#        if ( $pnr_name == "lec" ) then
#            set suffix  = ""
#        else 
#	        set suffix  = `echo $pnr_name | sed 's/fm//g'`
#        endif
#
#        set innovus_dir = "../../pnr$suffix"
#    else 
#        set innovus_dir = `realpath $innovus_dir`
#    endif
    
    #------------------------------------------
    # MATCH fusion DIR
    #------------------------------------------    
    if ( "$fusion_dir" == "None" ) then

        set pnr_name = `pwd | tr "/" " " | awk '{print $NF}'`
        
        if ( $pnr_name == "pnr" ) then
            set suffix  = ""
        else 
	        set suffix  = `echo $pnr_name | sed 's/fm//g'`
        endif

        set fusion_dir = "../../pnr$suffix"
    else 
        set fusion_dir = `realpath $fusion_dir`
    endif
    
    #------------------------------------------
    # full path for netlist
    #------------------------------------------    
    if ( "$golden_netlist" != "None" ) then
        set golden_netlist = `realpath $golden_netlist`
    endif
    if ( "$revised_netlist" != "None" ) then
        set revised_netlist = `realpath $revised_netlist`
    endif
    if ( "$svf_file" != "None" ) then
        set svf_file = `realpath $svf_file`
    endif

endif 
#------------------------------------------
# END VERIFY FM
#------------------------------------------    

#------------------------------------------
# VERIFY STARRC
#------------------------------------------    
if ( $flow == starrc ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is starrc"
    endif

	set DESIGN_NAME = $design_name
    if ( "$pnr_dir" == "None" ) then
        set PNR_DIR = `pwd | perl -pe 's/starrc/pnr/' `
    else 
        set PNR_DIR = `realpath $pnr_dir`
    endif
    if ( "$dm_dir" == "None" ) then
        set DM_DIR = `pwd | perl -pe 's/starrc/dm/' ` 
    else
    	set DM_DIR = `realpath $dm_dir`
    endif
    if ( "$stage" == "chip_finish" ) then
        set STAGE = "chip_finish"
    else 
    	set STAGE = $stage
    endif  
    if ( "$cpu" == "8" ) then
        set CPU = 8
    else 
     	set CPU = $cpu
    endif
    if ( "$hosts" == "localhost:CPU" ) then
    	set suffix = $CPU
        set HOSTS = "localhost:$suffix"
    else 
    	set HOSTS =$hosts
    endif
   
    if ($with_dm == "None") then
     	set WITH_DM = "false"
    else 
    	set WITH_DM = $with_dm  
    endif
    if ($output_file == "None") then
    	set OUTPUT_FILE = "GPD"
    else 
    	set OUTPUT_FILE = $output_file
    endif 
    if ( "$pnr_def" == "None" ) then
        set PNR_DEF = "${PNR_DIR}/out/def/${design_name}.${stage}.def.gz"
    else 
    	set PNR_DEF = `realpath $pnr_def`
    endif
    if ( "$pnr_ndm" == "None" ) then
        set PNR_NDM = "${PNR_DIR}/out/${design_name}_lib"
    else 
    	set PNR_NDM = `realpath $pnr_ndm`
    endif
    if ($dm_oasis_file == "None") then
    	set DM_OASIS_FILE = "$DM_DIR/DM_${design_name}.oas"
    else 
    	set DM_OASIS_FILE = `realpath $dm_oasis_file  `   
    endif
	if (! -f $DM_OASIS_FILE && $with_dm == "true")  then
   		echo "ERROR: DM file $DM_OASIS_FILE does not exists . running without DM"
   		set WITH_DM = "false"
	else 
   	   echo "-I- DM file $DM_OASIS_FILE"
	endif

endif 
#------------------------------------------
# END VERIFY STARRC
#------------------------------------------    

#------------------------------------------
# VERIFY PRIME TIME
#------------------------------------------    
if ( $flow == pt ) then
#    set DESIGN_NAME = $design_name
#    set STAGE = $stage
#    set VIEWS = $views
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is pt"
    endif

    if ( $pba_mode != "none" && $pba_mode != "path" && $pba_mode != "exhaustive" && $pba_mode != "ex" ) then
	echo "Error: $pba_mode is not pba mode valid option. it can be none , path , exhaustive .\n"
        ./scripts/bin/print_help.tcl $defs
	exit	
    endif
    if ( $ocv != "none" && $ocv != "flat" && $ocv != "pocv" ) then
	echo "Error: $ocv is not ocv valid option. it can be none , flat , pocv ."
    endif
    if ( $vcd_type != "" && $vcd_type != "rtl" && $vcd_type != "zero_delay" ) then
	echo "Error: $vcd_type is not vcd valid type. it can be empty , rtl , zero_delay ."
    endif
    
    
    if ( "$spef_dir" == "None" ) then
        set spef_dir = `pwd | sed 's/\(.*\)\/pt/\1\/starrc/' `
    else 
        set spef_dir = `realpath $spef_dir`
    endif
    if ( "$gpd_dir" == "None" ) then
        set gpd_dir = `pwd | sed 's/\(.*\)\/pt/\1\/starrc/' `
    else 
        set gpd_dir = `realpath $gpd_dir`
    endif
    if ("$xtalk" == "true/false") then
      if ("$read_spef" == "true" || "$read_gpd" == "true") then
         set xtalk_si = "true"
         set xtalk = "true"
     else 
         set xtalk_si = "false"
         set xtalk = "false"
      endif
    else 
         set xtalk_si = $xtalk
    endif
   

    if ( "$pnr_dir" == "None" ) then
        set pnr_dir = `pwd | perl -pe 's/pt/pnr/' `
    else 
        set pnr_dir = `realpath $pnr_dir`
    endif
    if ( "$netlist" == "None" ) then
        if (-e $pnr_dir/out/db/${design_name}.${stage}.enc.dat/${design_name}.v.gz) then
   	   set netlist = "$pnr_dir/out/db/${design_name}.${stage}.enc.dat/${design_name}.v.gz"
	else if (-e $pnr_dir/out/netlist/${design_name}.${stage}.v.gz) then
   	   set netlist = "$pnr_dir/out/netlist/${design_name}.${stage}.v.gz"
	else
	   echo "Error netlist file does not exists"
#	   exit 1
	endif
    else 
        set netlist = `realpath $netlist`
    endif
    if ( "$stage" == "syn" || "$stage" == "place" ) then
        set update_io_clock_latency = "false"
    else
        set update_io_clock_latency = $io_clock_latency
    endif

#
#    set INNOVUS_DIR = $innovus_dir
#    set SPEF_DIR = $spef_dir
#    set GPD_DIR = $gpd_dir
    set NETLIST_FILE_LIST = "$netlist"
#   
#    set OCV = $ocv
#    set CPU = $cpu
#    set HOSTS = $hosts
#    set PHYSICAL = $physical
#    set ECO = $eco
#    set ECO_NUMBER = $eco_num
#    set PBA_MODE = $pba_mode
#    set RESTORE = $restore
#    set RH_OUT = $rh_out
    set SPEF_FILE_LIST = $spef_files
    set GPD_FILE_LIST = $gpd_files
#    set READ_SPEF = $read_spef
#    set READ_GPD = $read_gpd
#    set SDC_LIST = "$sdc_list"
#    set INTERACTIVE = $interactive
#    set CREATE_LIB = $create_lib
#    set CREATE_LIB_ONLY = $create_lib_only
#    set POWER_REPORTS = $power_reports
#    set VCD_FILE = $vcd_file
#    set VCD_TYPE = $vcd_type
#    set VCD_BLOCK_PATH = $vcd_block_path
#    
#    
endif 

#------------------------------------------
# END VERIFY PRIME TIME
#------------------------------------------    
#------------------------------------------
# VERIFY redhawk_SC
#------------------------------------------    

if ( $flow == "rhsc" ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is rhsc"
    endif
    set DESIGN_NAME = $design_name
    set STAGE = $stage
#    set RUN_SIGEM = $run_sigem
#    set BQM = $bqm
#    set R_EFF = $r_eff
    set CREATE_DB = $create_db
    set CREATE_TWF = $create_twf
    
    if ( "$innovus_dir" == "None" ) then
        set innovus_dir = `pwd | perl -pe 's/rhsc/pnr/' `
    else 
        set innovus_dir = `realpath $innovus_dir`
    endif
    if ( "$starrc_dir" == "None" ) then
        set starrc_dir = `pwd | perl -pe 's/rhsc/starrc/' `
    else 
        set starrc_dir = `realpath $starrc_dir`
    endif
    
    if ( "$pt_dir" == "None" ) then
        set pt_dir = `pwd | perl -pe 's/rhsc/pt/' `
    else 
        set pt_dir = `realpath $pt_dir`
    endif
    
    if ( $analyse_type != "static" && $analyse_type != "dynamic" && $analyse_type != "sigem" ) then
	echo "Error: $analyse_type is not analyse_type valid option. it can be static / dynamic / sigem."
        ./scripts/bin/print_help.tcl $defs
	exit
    endif
    if ( "$gpd_dir" == "None" ) then
        set gpd_dir  = "${starrc_dir}"
    else 
        set gpd_dir = `realpath $gpd_dir`
    endif

#    if ( "$gpd_dir" == "None" ) then
#        set gpd_dir  = "${starrc_dir}/out/gpd/${DESIGN_NAME}.${STAGE}.HIER.gpd"
#    else 
#        set gpd_dir = `realpath $gpd_dir`
#    endif
    if ( "$ploc_file" == "None" ) then
        set ploc_file  = "$PWD/out/${DESIGN_NAME}.ploc"
    endif
    if ( "$def_file" == "None" ) then
        set def_file  = "$PWD/out/def/${DESIGN_NAME}.${STAGE}.def.gz"
    endif
    
    
    set INNOVUS_DIR = $innovus_dir
    set STARRC_DIR = $starrc_dir
    set PT_DIR = $pt_dir
    set GPD_DIR = $gpd_dir
    set PLOC_FILE = $ploc_file
    set DEF_FILE = $def_file
    

    
    
#    if ("$analyse_type" == "static") then
#	set STATIC = "True"
#	set RUN_DYN_PGEM = "False"
#        set RUN_VECTOR_PROFILER = "False"
#        set RUN_VECTOR_STRESS = "False"
#        set CHECK_VIA = "True"
#        set DVD_DIAGNOSTIC = "False"
#        set CPM = "False"
#	
#        if ("$dynamic_prop" == "false/true") then
#		set dynamic_prop = "False"
#	endif
#        if ("$dynamic_pcvs" == "false/true") then
#		set dynamic_pcvs = "False"
#	endif
#        if ("$run_pgem" == "true/false") then
#		set run_pgem = "True"
#	endif
#   else 
#	set STATIC = "False"
#	set RUN_DYN_PGEM = "True"
#        set RUN_VECTOR_PROFILER = "False"
#        set RUN_VECTOR_STRESS = "False"
#        set CHECK_VIA = "True"
#        set DVD_DIAGNOSTIC = "True"
#        set CPM = "False"
#        if ("$dynamic_prop" == "false/true") then
#		set dynamic_prop = "True"
#	endif
#        if ("$dynamic_pcvs" == "false/true") then
#		set dynamic_pcvs = "True"
#	endif
#        if ("$run_pgem" == "true/false") then
#		set run_pgem = "False"
#	endif
#   
#   endif
    
#   set DYNAMIC_PCVS = $dynamic_pcvs
#   set DYNAMIC_PROP = $dynamic_prop
#   set RUN_PGEM = $run_pgem
   
endif
#------------------------------------------
# VERIFY RH
#------------------------------------------    


#------------------------------------------
# VERIFY DRC
#------------------------------------------    
if ( $flow == drc ) then
    if ( $is_debug == "true" ) then
         echo "DEBUG: flow is drc"
    endif

    if ( "$design_name" == "None" ) then
        set design_name = `pwd | tr "/" " " | awk '{print $(NF-2)}'`
    endif 

    if ( "$project" == "None" ) then
        set project     = `pwd | tr "/" " " | awk '{print $(NF-3)}'`
    endif     
    if ( "$pnr_dir" == "None" ) then
        if ($type == "dodpo") then
           set PNR_DIR = `pwd | perl -pe 's/dodpo/pnr/' `
        else if ($type == "dm") then
           set PNR_DIR = `pwd | perl -pe 's/dm/pnr/' `
	else
           set PNR_DIR = `pwd | perl -pe 's/drc/pnr/' `
	endif
    else 
        set PNR_DIR = `realpath $pnr_dir`
    endif
    if ( "$layout_file" == "None" ) then
        if ($type == "dodpo" || $type == "dm") then
	    if (-e ${PNR_DIR}/out/oas/${design_name}_merge.oas) then
                set LAYOUT_FILE = "${PNR_DIR}/out/oas/${design_name}_merge.oas"
                set layout_file = "${PNR_DIR}/out/oas/${design_name}_merge.oas"
	    else if (-e ${PNR_DIR}/out/oas/${design_name}_merge.oas.gz ) then
                set LAYOUT_FILE = "${PNR_DIR}/out/oas/${design_name}_merge.oas.gz"
                set layout_file = "${PNR_DIR}/out/oas/${design_name}_merge.oas.gz"
	    else
	        echo "Error: Layout file not exists
	    endif
	else
	    if (-e ${PNR_DIR}/out/oas/${design_name}.oas) then
                set LAYOUT_FILE = "${PNR_DIR}/out/oas/${design_name}.oas"
                set layout_file = "${PNR_DIR}/out/oas/${design_name}.oas"
	    else if (-e ${PNR_DIR}/out/oas/${design_name}.oas.gz) then
                set LAYOUT_FILE = "${PNR_DIR}/out/oas/${design_name}.oas.gz"
                set layout_file = "${PNR_DIR}/out/oas/${design_name}.oas.gz"
	    else
	        echo "Error: Layout file not exists
	    endif
	endif
    else 
    	set LAYOUT_FILE = `realpath $layout_file`
    endif

endif 
#------------------------------------------
# END VERIFY DRC
#------------------------------------------    


#------------------------------------------
# VERIFY LC
#------------------------------------------    

if ( $flow == "lc" ) then
    if ( $db_dir == "None" ) then
        set db_dir = $libs_dir
    endif
endif
#------------------------------------------
# VERIFY LC
#------------------------------------------    


#------------------------------------------
# VERIFY JOULES
#------------------------------------------    
if ( $flow == joules ) then


endif 
#------------------------------------------
# END VERIFY JOULES
#------------------------------------------    

###########################################
#------------------------------------------
#  k8s checkers
#------------------------------------------
###########################################
if ($?k8s && $?interactive) then       
    if ($k8s == "true" && $interactive == "true") then
#   	echo "ERROR: cannot run interactive and k8s."
#	exit 1
    endif 
endif 


###########################################
#------------------------------------------
#  UPDATE LINK TO SCRIPTS FOLDER
#------------------------------------------
###########################################

if (  -e scripts && $fe_mode == "false") then
   # check if scripts version is coming from user or default value.
   if ($scripts_version == "None") then
      if (-f version) then
      	set VERSION_ = `cat version`
      else if (-f ../inter/version) then
      	set VERSION_ = `cat ../inter/version`
      else if (-f /bespace/users/be_repository/ns_flow/version) then
      	set VERSION_ = `cat /bespace/users/be_repository/ns_flow/version`
      else if (-f /ex-bespace/users/be_repository/ns_flow/version) then
      	set VERSION_ = `cat /ex-bespace/users/be_repository/ns_flow/version`
      else
      	set VERSION_ = "None"
      endif
   else
      set VERSION_ = $scripts_version
   endif
   
   # check if scripts folder exists
   if ($VERSION_ == "None") then
   	echo "Warning: no access to be_repository"
   else
   	if (! -e /bespace/users/be_repository/ns_flow/$VERSION_/scripts && ! -e /ex-bespace/users/be_repository/ns_flow/$VERSION_/scripts) then
       		echo "$VERSION_  is not valid value for scripts repository."
       		exit
   	endif
   
  	# get current scripts link dir
   	set LINK_DIR = `\ls -lrt scripts | awk '{print $NF}' `
   
   	# if scripts is link to repository and differ from VERSION, update the link.
   	# else print a warning and holt for 60 sec.
   	if (-l ./scripts && `echo $LINK_DIR | grep be_repository | wc -l`) then
      		set LINK_DIR = `\ls -lrt scripts | awk '{print $NF}' | awk -F '/' '{print $(NF-1)}' `
      		if ($VERSION_ != $LINK_DIR) then
          		echo "remove old link:        $LINK_DIR"
	  		unlink scripts
   			if (-e /bespace/users/be_repository/ns_flow/$VERSION_/scripts) then
	  			echo "create link to scripts: /bespace/users/be_repository/ns_flow/$VERSION_/scripts "
          			ln -sf /bespace/users/be_repository/ns_flow/$VERSION_/scripts .
			else if (-e /ex-bespace/users/be_repository/ns_flow/$VERSION_/scripts) then
	  			echo "create link to scripts: /ex-bespace/users/be_repository/ns_flow/$VERSION_/scripts "
          			ln -sf /ex-bespace/users/be_repository/ns_flow/$VERSION_/scripts .
			else
				echo "ERROR: missing /bespace/users/be_repository/ns_flow/$VERSION_/scripts or /ex-bespace/..."
			endif
      		endif
   	else   
      		echo "####################################################################################################\n"
      		echo "Warning: scripts is not link to be_repository"
      		echo "         you Should use local scripts instead"
      		echo "####################################################################################################\n"
		if ($is_fast == "false" && ! `echo $argv | grep views_list | wc -l `  ) then
			sleep 30
		endif
   	endif   
   endif
endif


#------------------------------------------
# SET TMP DIR
#------------------------------------------   
if ( -d /local/tmp ) then 
   echo "-I- Setting temp dir - /local/tmp"
   setenv TMPDIR /local/tmp
else if  ( -d /local-tmp ) then 
   echo "-I- Setting temp dir - /local-tmp"
   setenv TMPDIR /local-tmp
else if  ( -d /tmp ) then 
   echo "-I- Setting temp dir - /tmp"
   setenv TMPDIR /tmp
else
   echo "-W- not setting  temp dir"
endif



#------------------------------------------
# PRINT DEBUG AND EXIT
#------------------------------------------    
if ( $is_debug == "true" ) then
    
    echo "\nFlags values:"
        
    foreach flag ($flags_list )
        set value = "$flag"
        set  echo_cmd = "echo $value = "`echo $`"`echo $value`"
        eval $echo_cmd
    end
    
    echo "\nArgs: $argv"
    
	exit

endif
#------------------------------------------
# SET WA PATH
#------------------------------------------    
set WA_PATH  = `pwd | tr "/" " " | awk '{print $(NF-3)"/"$(NF-2)"/"$(NF-1)"/"$(NF)}'`

#------------------------------------------
# PRINT TCL FILE WITH ALL VARIABLES
#------------------------------------------    
echo 'puts "-I- Source user inputs file for tool '$flow'"\n' > .tmp_user_inputs.tcl
foreach flag ($flags_list )
    set value = "$flag"
    set VALUE = ` echo $value | tr "[a-z]" "[A-Z]" `
    if ( $VALUE != "OTHER_ARGS") then

        set value_cmd  = "echo "`echo $`"`echo $value`"
        set real_value = `eval $value_cmd`
        set set_cmd    = "set $VALUE `echo +$real_value+`"
    
        echo $set_cmd | tr "+" '"' >> .tmp_user_inputs.tcl
    endif
end

if ( $?other_args) then 
   if ( "$other_args" != "None" ) then
       echo "-I- Print other_args to user_inputs"
       echo $other_args >> .tmp_user_inputs.tcl
   endif
endif
#if ( "$other_args_list" != "" ) then
#    echo "-I- Print other_args to user_inputs"
#    echo $other_args_list >> .tmp_user_inputs.tcl
#endif

set is_exit = "false"

###########################################
#------------------------------------------
# HELP
#------------------------------------------
###########################################
if ( "$is_error" == true ) then
    echo ""
    echo $help
    
    if ( "$flow" != "" ) then
#        echo $defs | sed 's/;/\n/g' 
        ./scripts/bin/print_help.tcl $defs
    endif        
    
    exit
endif 









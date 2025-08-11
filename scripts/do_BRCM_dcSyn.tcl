#source  /space2/users/shahara/nxt_hw_fe_soc_clean/nic/tbc_dcnxt_optimization_customer_final_wa_to_resolve_crash_during_pass1_mapping_for_star_4389227.tbc
#source /space2/users/shahara/nxt_hw_fe_soc_clean/nic/tbc_customer_final_wa_dcnxt_optimization_customer_tbc_wa_dcnxt_optimization_crash_for_star_5936921.tbc

echo "HOST name: $env(HOST)"
set STAGE syn
#if { [info exists ::env(SYN4RTL)] } { set fe_mode $::env(SYN4RTL) } else { set fe_mode false }
if {![file exists reports/dft]}  {exec mkdir reports/dft}
if {![file exists reports/syn]}  {exec mkdir reports/syn}
if {![file exists reports/elab]} {exec mkdir reports/elab}
if {![file exists reports/compile]} {sh mkdir reports/compile}
if {![file exists reports/compile_incr]} {sh mkdir reports/compile_incr}


if {![info exists RUN_TIMING_REPORTS]} {set RUN_TIMING_REPORTS true}

#------------------------------------------------------------------------------
# reading  procedures
#------------------------------------------------------------------------------
# Central procs
# create proc just for synopsys
source ./scripts/procs/source_be_scripts.tcl
#source ./scripts/procs/common/procs.tcl
#source ./scripts/procs/genus/regression_procs.tcl
if {![file exists ./sourced_scripts/${STAGE}]} {exec mkdir -pv ./sourced_scripts/${STAGE}}
exec cp -pv [file normalize [info script]] ./sourced_scripts/${STAGE}/.
if {[file exists ./user_inputs.tcl]} {exec cp -pv ./user_inputs.tcl ./sourced_scripts/${STAGE}/.}


script_runtime_proc -start


#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	set setup_file ./scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	set setup_file scripts/setup/setup.${PROJECT}.tcl
}
source -v -e $setup_file
if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v -e ../inter/supplement_setup.tcl
}

if {[file exists ./scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v -e ./scripts_local/supplement_setup.tcl
}

# uniquifying data
be_uniquify_data -list_names "LEF_FILE_LIST NDM_REFERENCE_LIBRARY STREAM_FILE_LIST SCHEMATIC_FILE_LIST" -array_names "pvt_corner" -pattern "*,timing"

######################################################################

# Sample Script for 5nm FF Density Library (0.5 Version)
# This script is to be used only for Design Compiler WLM/ZWLM or TOPO
#######################################################################

#######################################################################
#  Set WLM or ZWLM or DC-Topo Variables
# DCTOPO 0 => WLM,  DCTOPO 1 => Run DC-TOPO physical synthesis
# ZWLM 1  => Zero Interconnect Delay, ZWLM 0 => WLM
#std_cell_7T => 7.5T std lib,by default it is 6T
#######################################################################
date
set_host_options -max_cores $CPU
##nramani - Based on synthesis guidelines given, till def is available make this as 0, ZWLM=0 when DCT is available
#set DCTOPO 1
if {[info exists IS_PHYSICAL] && $IS_PHYSICAL} {
	set DCTOPO 1
} else {
	set DCTOPO 0
}

set ZWLM   ${ZWLM}
set std_cell_7T     0
## set const_prop true later , for now true
if {[info exists REMOVE_FLOPS]} {
	puts "-I- set const_prop $REMOVE_FLOPS"
	set const_prop $REMOVE_FLOPS
} else  {
	puts "-I- set const_prop true"
	set const_prop true
}
if {[file exists ${SAIF_FILE}] && [info exists SAIF_INST_NAME]} {
    set USE_SAIF 1
    set saif_instance_name $SAIF_INST_NAME
    puts "DEBUG: USE_SAIF = 1; saif file : $SAIF_FILE ; saif_instance_name = ${saif_instance_name}"
} else {
    set USE_SAIF 0
    puts "DEBUG: USE_SAIF = 0"
}
########################################################################
# Set user variables
########################################################################
#set top [lindex [split [pwd] /] 9]
set top $DESIGN_NAME

set tc_dir "[pwd]"
set logs_dir "[pwd]/logs"
if {![file exists ${logs_dir}]} {
	file mkdir ${logs_dir};
	puts "Creating directory ${logs_dir}"
}
set sh_command_log_file "logs/${top}.cmd.log"
set sh_output_log_file "logs/${top}.log"
# Point to work directory
set dc_reports_hier "[pwd]/reports/hier"
set dc_reports_flat "[pwd]/reports/flat"
set dc_outputs_hier "[pwd]/outputs/hier"
set dc_outputs_flat "[pwd]/outputs/flat"
set data_dir "[pwd]/data"
set logs_dir "[pwd]/logs"
#set def "[pwd]/def"

###user variables
#set PN85_RTL_ROOT /projects/apd_nxt080/xfers/in/15092023/NXT080_PN85.2_20230915/project/nxt080/nxt080_model_releases/nxt080_PN85.2_release_filelist_20230914_1648
#set filelist  ${PN85_RTL_ROOT}/filelists_only/${top}/filelist
#set filelist  ./inputs/filelist
#set sdc_path /project/apd_nxt080/designers/ss943226/synthesis/PN85.2/collaterals/${top}.sdc 

if { ![info exists FILELIST] || $FILELIST == "None" } {   
	if       { [file exists ./filelist] } {
           set filelist ./filelist    
   
	} elseif { [file exists ../inter/filelist] } {
           set filelist ../inter/filelist
   
	} else {
		puts "Error: missing filelist"
		exit 1
	}
       
} else {
	set filelist $FILELIST
}

set sdc_path $sdc_files(func)

##if {$USE_SAIF} {
##set saif_path ./inputs/activity/PN50_ver2_combined.saif
##}
#set dc_scripts "[pwd]/../scripts"
#set def "/project/apd_nxt009_blk1/giant/giant-2022.10.0/user/nramani/PN99.2.17Nov2022/impl/pcie_top_syn_wrap/block_tools/floorplan/data/pcie_top_syn_wrap.def.gz"
#set def "/project/apd_nxt009_blk1/giant/giant-2022.10.1/user/lb939471/PN99.5_pre/impl/${top}/source.fp2.0.0/${top}.def.gz"
#set def "/project/apd_nxt009_blk0/giant/giant-2022.10.1/user/lb939471/PN99.6.28Dec2022/impl/${top}/source.fp2.1.0/${top}.def.gz"

########################################################################
# Create Reports and output directory
########################################################################

if {![file exists ${dc_reports_hier}]} {
	file mkdir ${dc_reports_hier};
	puts "Creating directory ${dc_reports_hier}"
}

if {![file exists ${dc_reports_flat}]} {
	file mkdir ${dc_reports_flat};
	puts "Creating directory ${dc_reports_flat}"
}


if {![file exists ${dc_outputs_hier}]} {
	file mkdir ${dc_outputs_hier};
	puts "Creating directory ${dc_outputs_hier}"
}

if {![file exists ${dc_outputs_flat}]} {
	file mkdir ${dc_outputs_flat};
	puts "Creating directory ${dc_outputs_flat}"
}


if {![file exists ${data_dir}]} {
	file mkdir ${data_dir};
	puts "Creating directory ${data_dir}"
}
#if {![file exists ${def}]} {
#	file mkdir ${def};
#	puts "Creating directory ${def}"
#}


### DC version
## get the version from shell,dont hard-code to avoid discrepency
set getver [split $bin_path /]
set dc_version [lindex $getver 4]
echo $dc_version

########################################################################
# set Top design
#######################################################################

if {$DCTOPO} {
	set mw_design_lib ${top}_dct.mwlib
}

set DESIGN_LIBRARY ${top}_ndm.lib

set SYN_HOME /tools/snps/syn/$dc_version

########################################################################
# Source setup scripts
########################################################################

source ./scripts/flow/BRCM_common_dct_setup.tcl

##iplib for memories/IP
##iplib for memories/IP
#set iplib_nxt080 "/project/apd_nxt080/iplib/PN85.2"
#set iplib_memory  "${iplib_nxt080}/memory/db"

###library setup , change the name and have one for 7.5T by adding a loop
source ./scripts/flow/BRCM_dct_lib_setup_for_6T.tcl


########################################################################
# Run Stats Initialize
########################################################################

#lsi_time_stats initialize

########################################################################
# Some of the tech file constructs of TSMC 16FF are not supported in DC-T
# use this directive before reading in the tech file
########################################################################
##Should we turn this off initially to verify all warnings/errors are fine ?
if {$DCTOPO} {
	set ignore_tf_error true
}

########################################################################
# Create MWLIB for DC-T
########################################################################

if {$DCTOPO} {
	#if [file exists $mw_design_lib] { sh rm -rf $mw_design_lib }
	if [file exists $DESIGN_LIBRARY] { sh rm -rf $DESIGN_LIBRARY }
	# extend_mw_layers
	# create_mw_lib -tech $mw_tech_file -mw_reference_library $mw_reference_library -open $mw_design_lib
	create_lib $DESIGN_LIBRARY  -tech $mw_tech_file -ref_libs $ndm_ref_libs
		set_tlu_plus_files -max_tluplus $max_tlu -min_tluplus $min_tlu \
		-tech2itf_map $map_file
	#redirect $dc_reports_hier/${top}_cln05_runstats { lsi_time_stats {Create MWLIB} }
}
########################################################################
# Setup SVF for Formal
########################################################################

#set_svf ${top}_formal.svf
set_svf out/${DESIGN_NAME}.svf
set_vsdc out/${DESIGN_NAME}.vsdc


set_message_info -id VER-130 -limit 1

if {[regexp "grid_node_top|mss|msu|reg_fifo|vcu|ncu" $top]} {
	set_app_var synthetic_library {standard.sldb dw_foundation.sldb dw_minpower.sldb};
	set power_enable_minpower true ;
} else {
	set_app_var synthetic_library {standard.sldb dw_foundation.sldb};
}


set_app_var link_allow_physical_variant_cells true
set_app_var alib_library_analysis_path . # FIXME
set_app_var hdlin_enable_upf_compatible_naming true ;

# 30/01/2024 Royl: Controls whether the register transformation are recorded and can be reported by the report_transformed_registers command
set compile_enable_report_transformed_registers true

# The below is not an application variable, 
set hdlin_define_synthesis_macro true ;

## module name limit , by default it shortenes the name if it exceeds 256, should we make it 1024 and keep the shortening var or restrict it to 256 itself?
# Enables shortening of names
#set_app_var hdlin_shorten_long_module_name true ;
# Specify minimum number of characters. Default: 256
#set_app_var hdlin_module_name_limit 1024 ;
set hdlin_shorten_long_module_name true
set hdlin_module_name_limit 256

set_app_var mw_design_library $dc_outputs_hier/${top}.mwlib ;
set mw_site_name_mapping { {CORE unit} {Core unit} {core unit} }

# Enable the insertion of level-shifters on clock nets for a multivoltage flow
#set_app_var auto_insert_level_shifters_on_clocks all


##    set_app_var hdlin_infer_multibit default_all ;
#Dont use DG,BG cells,check once if any errors as a double check
#set_dont_use   [get_lib_cell */P6*DG_*]
#set_dont_use   [get_lib_cell */P6*BG_*]
#set_dont_use   [get_lib_cell */P6U*]

########################################################################
# Read RTL files
########################################################################

#07/01/2024 Roy: this should help with formality run
set_app_var hdlin_enable_hier_map true ;

file delete -force $data_dir/WORK
define_design_lib WORK -path $data_dir/WORK
lappend search_path $SYN_HOME

if {$USE_SAIF} {
	saif_map -start
}

echo "Reading filelist $filelist"

analyze -format sverilog -vcs "+define+NXT_PRIMITIVES +BRCM_NO_MEM_SPECIFY -f $filelist"
#
#if {[regexp car $top] || [regexp pll $top]} {
#  read_verilog /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20230905/verilog/ds05_pllsys01_wrapper_04_behavioral_verilog.v
#}
#
#if {[regexp io_wrap $top]} {
#  read_verilog /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20230905/verilog/ds05_vtmon_w_reg_sbus_wrapper_01_behavioral_verilog.v
#  read_verilog /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20230905/verilog/ds05_LIB_PM_GEN6_TS5FF_S0_01_behavioral_verilog.v
#}
#
#if {$top == "nxt080_top"} {
#  #read_verilog /project/apd_nxt080/iplib/PN85.2/design_support/watermark/BCM_WATERMARK_IP50lbca2asSl9Sls22i02_module.v
#  #read_verilog /project/apd_nxt080/iplib/PN85.2/design_support/watermark/BCM_WATERMARK_WRAPPER_DS05_LIB_ANCIL_NS_02_001.v
#  read_verilog /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20230905/verilog/ds05_lib_ancil_ns_02_behavioral_verilog.v
#  read_verilog /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/BRCM_DESIGN_SUPPORT/20230905/verilog/ds05_pllsys01_wrapper_04_behavioral_verilog.v
#}

#elaborate ${top}
redirect -tee -file reports/elaborate.rpt {elaborate ${top}}

#link > $logs_dir/${top}_link.log

redirect -tee -file reports/link.rpt  { [catch {link} link_status] }
if { $link_status == 0} { 
    puts "Error: Design has  unresolved references. check reports/link.rpt for more information " 
#    puts $link_status 
    exit 1 
}




#07/01/2024 Roy: this should help with formality run
set_verification_top

####################################
## Save elaborated design
####################################
write -hierarchy -format ddc     -output out/${DESIGN_NAME}.elab.ddc
write -hierarchy -format verilog -output out/${DESIGN_NAME}.elab.v
exec gzip -f out/${DESIGN_NAME}.elab.v

####################################
## Adding Change Names
####################################
# <HN>23ww52c - reports show bad namings, using unwanted charachters
#               adding these few basic changes
#define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
#define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
#define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port
#define_name_rules scip -first_restricted {0-9 _}
#define_name_rules scip -replacement_char _

#change_names -hierarchy -rules scip

####################################
## Elaboration reports
####################################		    

#be_check_design
#check_design -nosplit > ./reports/check_design_elab_verbose.rpt
#check_design -summary > ./reports/check_design_elab.rpt
parallel_execute [list \
	"report_clock_gating -nosplit > reports/elab/report_clock_gating.elab.rpt" \
	"report_clock_gating -nosplit -verbose > reports/elab/report_clock_gating_verbose.elab.rpt" \
]

redirect -file reports/elab/report_macro_count.rpt {be_report_macro_count}
be_report_feedthroughs ./reports/elab/feedthrough.rpt

#################################################################################
#################################################################################
# Load UPF MV Setup
#
# golden.upf, a UPF template file, can be used as a reference to develop a UPF-based
# low power intent file.
#
# You can also use Visual UPF in Design Vision to generate a UPF template for
# your design. To open the Visual UPF dialog box, choose Power > Visual UPF.
# For information about Visual UPF, see the Power Compiler User Guide.
#
#################################################################################

if {[info exists UPF_FILE] && [file exists $UPF_FILE]} {
	puts "-I-  loading UPF file $UPF_FILE"
	load_upf ${UPF_FILE}
	
	if {$top=="nsc_hod_chiplet"} {
		set_voltage 0.85 -object_list VDD_HOD
		set_voltage 0.75 -object_list VDDA_HOD
		set_voltage 0 -object_list VSS
	}
	
	if {![check_mv_design -power_nets]} {
		puts "Error: One or more supply nets are missing a defined voltage.  Use the set_voltage command to set the appropriate voltage upon the supply."
		puts "This script will now exit."
		return
		exit 1
	}
}


#################################################################################

if {$top=="nxt080_top"} {
  #current_design scu_top
  #compile
  current_design ${top}
  #set_dont_touch [get_designs general_pll]
  
  define_name_rules verilog -preserve_struct_ports
  change_names -rules verilog -hierarchy
  #  source /lab/projects/da/act-1.0/lib/tcl/change_names_avago.tcl
  #------------------------------------------------------------------------------

  ######set bus_naming_style {%s_%dA}

  ######suppress_message "NMA-8"
  suppress_message "NMA-9"
  suppress_message "NMA-16"
  suppress_message "NMA-14"
  suppress_message "UCN-4"

  set change_names_dont_change_bus_members true
  define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
  define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
  define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port

  define_name_rules scip -first_restricted {0-9 _}
  #define_name_rules scip -last_restricted  {_}
  change_names -hierarchy -rules scip
  #define_name_rules scip_last -equal_ports_nets
  #define_name_rules scip_last -special verilog
  #change_names -hierarchy -rules scip_last
  change_names -hierarchy -rules verilog
  #------------------------------------------------------------------------------

  
  
  write_file -format ddc -hier -output $dc_reports_hier/${top}_elab.ddc
  write_file -format verilog -hier -output $dc_reports_hier/${top}_elab.v
  write_file -format verilog -output $dc_reports_hier/${top}.bbox.v

  puts "-I- memory usage for read_design: [mem] KB"
  script_runtime_proc -end
  #  return
  exec touch .syn_done
  if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {
  return
  } else {
        exit
  }
}

##dont touch on NXT modules
if {[regexp car $top] || [regexp pll $top]} {
  set_dont_touch [get_designs NXT*]
set dont_touch_signals {*REFCLK_P_PAD* *REFCLK_N_PAD* *SOC_ABUS0* *SOC_ABUS1* *TST0_PAD* *TST1_PAD* *JITBUF_P_PAD* *JITBUF_N_PAD* *REFCLK_INT* *REFCLK_OUT*}
foreach port  $dont_touch_signals {
    echo "Applying dont touch on port $port in block $top"
    set_dont_touch [get_nets -of_objects [get_ports $port]]
}
}
##dont_touch on NXT_CLK_MUX modules
#set_dont_touch [get_designs NXT_CLK_MUX*]

##For io wrappers
##set dont_touch on peb and VGDC pins
#if {[regexp io_wrap $top]} {
#  set_dont_touch [get_nets */peb]
#  set_dont_touch [get_nets */VGDC]
#  set_dont_touch [get_nets -of_object [get_cells -hier -f "ref_name=~BCM5FFXD18DFT_D18XH_POR"]]
#  set_dont_touch [get_nets -of_object [get_cells -hier -f "ref_name=~BCM5FFXD18DFT_D18XH_VBIAS"]]
#  set_dont_touch [get_nets -of_object [get_cells -hier -f "ref_name=~BCM5FFXD18DFT_D18XV_POR"]]
#  set_dont_touch [get_nets -of_object [get_cells -hier -f "ref_name=~BCM5FFXD18DFT_D18XV_VBIAS"]]
#  set_dont_touch [get_nets -of_object [get_cells -hier -f "ref_name=~BCM5FFXD18DFT_D1818H_TRAN"]]
#  set_dont_touch [get_nets -of_object [get_cells -hier -f "ref_name=~BCM5FFXD18DFT_D1818V_TRAN"]]
#}

#### size_only only real load and leaf cells which are tech instantiated"
set v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F*SRESYNC* && is_hierarchical==false"]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F*CK*MUX* && is_hierarchical==false"]]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F*CK*EN* && is_hierarchical==false"]]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *DONT_TOUCH* && is_hierarchical==false"]]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *dont_touch* && is_hierarchical==false"]]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *SIZE_ONLY* && is_hierarchical==false"]]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *size_only* && is_hierarchical==false"]]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *DONTTOUCH* && is_hierarchical==false"]]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *donttouch* && is_hierarchical==false"]]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *SIZEONLY* && is_hierarchical==false"]]
set v_preserve_cells [add_to_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *sizeonly* && is_hierarchical==false"]]

#set v_preserve_cells [remove_from_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *i_clk_or_gate_SIZE_ONLY* && is_hierarchical==false"]]
#set v_preserve_cells [remove_from_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *i_clk_mux_2x_SIZE_ONLY && is_hierarchical==false"]]
#set v_preserve_cells [remove_from_collection $v_preserve_cells [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *sync_fifo_observability* && is_hierarchical==false"]]
##newly added 
set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *i_clk_or_gate_SIZE_ONLY* && is_hierarchical==false"]
set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *i_clk_mux_2x_SIZE_ONLY && is_hierarchical==false"]
set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *sync_fifo_observability* && is_hierarchical==false"]
set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *i_xor_DONT_TOUCH* && is_hierarchical==false"]

set v_i 0
foreach_in_collection v_preserve_cell $v_preserve_cells {

    set output_pins [get_pins -of_objects $v_preserve_cell -filter "pin_direction==out"]

    if { [get_nets -of_object $output_pins] == ""} {
        puts "Found unloaded [get_object $v_preserve_cell], thus not setting set_size_only attribute on it"
                incr v_i
    } else {
        set_size_only -all_instances $v_preserve_cell
        set_attribute $v_preserve_cell del_unloaded_gate_off false
        set_attribute $v_preserve_cell const_prop_off false
	set_attribute $v_preserve_cell local_optz_off false
    }
}
puts "Warning: Skipped size_only on $v_i cells as they dont have a load"

report_size_only -nosplit > $dc_reports_flat/${top}_report_size_only.rpt


########################################################################
# lsi_change_names
########################################################################

#source /lab/projects/da/act-1.0/lib/tcl/change_names_avago.tcl
#------------------------------------------------------------------------------
######set bus_naming_style {%s_%dA}

######suppress_message "NMA-8"
suppress_message "NMA-9"
suppress_message "NMA-16"
suppress_message "NMA-14"
suppress_message "UCN-4"

set change_names_dont_change_bus_members true
define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port

define_name_rules scip -first_restricted {0-9 _}
#define_name_rules scip -last_restricted  {_}
#23/02/2025 Roy : tool crash 
#change_names -hierarchy -rules scip
#define_name_rules scip_last -equal_ports_nets
#define_name_rules scip_last -special verilog
#change_names -hierarchy -rules scip_last
#23/02/2025 Roy : tool crash 
#change_names -hierarchy -rules verilog

#------------------------------------------------------------------------------




#redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { lsi_time_stats {Link and Check} }



if {$USE_SAIF} {
     ###Reading saif files
     puts "-I- reading saif file $SAIF_FILE\n    instance name $saif_instance_name"
     read_saif -auto_map_names -input ${SAIF_FILE} -instance_name ${saif_instance_name}
     redirect  reports/${top}_saif_report_after_elab.rpt {report_saif -hierarchy -rtl_saif}
}

#write_file -format ddc -hier -output $dc_reports_hier/${top}_elab.ddc
#write_file -format verilog -hier -output $dc_reports_hier/${top}_elab.v
#write_file -format verilog -output $dc_reports_hier/${top}.bbox.v

#set uniquify_naming_style "${top}_%s_%d"
#uniquify

set current_design ${top}

#*********************************dont touch cells******************
#added based on Yigals' input as per tracker
if {[sizeof_collection [get_cells -quiet -hierarchical -filter "ref_name=~ *SRESYNC*"]] > 0} {
	puts "-I set dont touch on ref_name=~ *SRESYNC*"
	set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ *SRESYNC*"]
}
if {[sizeof_collection [get_cells -quiet -hierarchical -filter "ref_name=~ *CK*MUX*"]] > 0} {
	puts "-I set dont touch on ref_name=~ *CK*MUX*"
	set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ *CK*MUX*"]
}
if {[sizeof_collection [get_cells -quiet -hierarchical -filter "full_name=~ *DONT_TOUCH*"]] > 0} {
	puts "-I set dont touch on full_name=~ *DONT_TOUCH*"
	set_dont_touch [get_cells -quiet -hierarchical -filter "full_name=~ *DONT_TOUCH*"]
}
if {[sizeof_collection [get_cells -quiet -hierarchical -filter "full_name=~ *SIZE_ONLY*"]] > 0} {
	puts "-I set dont touch on full_name=~ *SIZE_ONLY*"
	set_attribute  [get_cells -quiet -hierarchical -filter "full_name=~ *SIZE_ONLY*"] size_only true
}
if {[sizeof_collection [get_cells -quiet -hierarchical -filter "full_name=~ *i_clk_or_gate_SIZE_ONLY*"]] > 0} {
	puts "-I set dont touch on full_name=~ *i_clk_or_gate_SIZE_ONLY*"
	set_dont_touch [get_cells -quiet -hierarchical -filter "full_name=~ *i_clk_or_gate_SIZE_ONLY*"]
}
if {[sizeof_collection [get_cells -quiet -hierarchical -filter "full_name=~ *i_clk_mux_2x_SIZE_ONLY*"]] > 0} {
	puts "-I set dont touch on full_name=~ *i_clk_mux_2x_SIZE_ONLY*"
	set_dont_touch [get_cells -quiet -hierarchical -filter "full_name=~ *i_clk_mux_2x_SIZE_ONLY*"]
}
if {[sizeof_collection [get_cells -quiet -hierarchical -filter "full_name=~ *sync_fifo_observability* && is_hierarchical==false"]] > 0} {
	puts "-I set dont touch on full_name=~ *sync_fifo_observability*"
	set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *sync_fifo_observability* && is_hierarchical==false"]
}
if {[sizeof_collection [get_cells -quiet -hierarchical -filter "full_name=~ *i_xor_DONT_TOUCH* && is_hierarchical==false"]] > 0} {
	puts "-I set dont touch on full_name=~ *i_xor_DONT_TOUCH*"
	set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ F* && full_name=~ *i_xor_DONT_TOUCH* && is_hierarchical==false"]
}


###DFT dont touch cells

set hdlin_enable_elaborate_ref_linking true

set enable_bit_blasted_bus_linking true
set_app_var timing_save_library_derate true
# Read Timing Constraints (SDC/TCL)
foreach constraint_file $sdc_path {
	set sss [lindex [split $constraint_file /] end]
	redirect -tee -file reports/read_${sss}   {source -e -v $constraint_file}
}



redirect -file reports/check_design_elab.rpt { check_design -nosplit }
redirect -file reports/check_design_elab.summary.rpt { check_design -summary }
redirect -file reports/check_timing.rpt { check_timing }
report_net_fanout -high_fanout -nosplit > reports/report_net_fanout_high.rpt

#define_name_rules verilog -preserve_struct_ports
#change_names -rules verilog -hierarchy

########################################################################
# Stop After elaborate
########################################################################
if { [info exists STOP_AFTER] && $STOP_AFTER == "elaborate" } {
	puts "-I- exit after elaboration"
	puts "-I- memory usage for read_design: [mem] KB"
	script_runtime_proc -end
	exec touch .syn_done
	if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {
		return
	} else {
		exit
	}
}

########################################################################
# lsi_change_names
########################################################################

#source /lab/projects/da/act-1.0/lib/tcl/change_names_avago.tcl
#------------------------------------------------------------------------------
######set bus_naming_style {%s_%dA}

######suppress_message "NMA-8"
suppress_message "NMA-9"
suppress_message "NMA-16"
suppress_message "NMA-14"
suppress_message "UCN-4"

set change_names_dont_change_bus_members true
define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port

define_name_rules scip -first_restricted {0-9 _}
#define_name_rules scip -last_restricted  {_}
#23/02/2025 Roy : tool crash 

#change_names -hierarchy -rules scip
#define_name_rules scip_last -equal_ports_nets
#define_name_rules scip_last -special verilog
#change_names -hierarchy -rules scip_last
#23/02/2025 Roy : tool crash 

#change_names -hierarchy -rules verilog
#------------------------------------------------------------------------------


#redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { #lsi_time_stats {Link and Check} }

#report_net_fanout -high_fanout -nosplit > $dc_reports_hier/${top}_highfanout.rpt
if {$PROJECT == "brcm3" || $PROJECT == "nxt013" } {
	set cells ""
	foreach lib [get_object_name [get_libs *tsmc3ffe_*067*]] {
		append_to_collection cells [list [get_lib_cells ${lib}/E?L*]]
	}
	set_attribute -quiet [get_object_name $cells] threshold_voltage_group lvt
	
	set cells ""
	foreach lib [get_object_name [get_libs *tsmc3ffe_*067*]] {
		append_to_collection cells [list [get_lib_cells -quiet ${lib}/E?UL*]]
	}
	set_attribute -quiet [get_object_name $cells] threshold_voltage_group ulvt
	
	set cells ""
	foreach lib [get_object_name [get_libs *tsmc3ffe_*067*]] {
		append_to_collection cells [list [get_lib_cells -quiet ${lib}/E?UN*]]
	}
	set_attribute -quiet [get_object_name $cells] threshold_voltage_group unvt
	
	set cells ""
	foreach lib [get_object_name [get_libs *tsmc3ffe_*067*]] {
		if {[sizeof_collection [get_lib_cells -quiet ${lib}/E?EN*]] > 0} {
			append_to_collection cells [list [get_lib_cells -quiet ${lib}/E?EN*]]
		}
	}
	set_attribute -quiet [get_object_name $cells] threshold_voltage_group evt
} else {
	if {[regexp "nsc|cxl" $top]}  {
		set cells ""
		foreach lib [get_object_name [get_libs *tsmc5ff_*076*]] {
			append_to_collection cells [list [get_lib_cells ${lib}/F6L*]]
		}
		set_attribute -quiet [get_object_name $cells] threshold_voltage_group lvt
	
		set cells ""
		foreach lib [get_object_name [get_libs *tsmc5ff_*076*]] {
			append_to_collection cells [list [get_lib_cells -quiet ${lib}/F6UL*]]
		}
		set_attribute -quiet [get_object_name $cells] threshold_voltage_group ulvt
	
		set cells ""
		foreach lib [get_object_name [get_libs *tsmc5ff_*076*]] {
			append_to_collection cells [list [get_lib_cells -quiet ${lib}/F6UN*]]
		}
		set_attribute -quiet [get_object_name $cells] threshold_voltage_group unvt
		
		set cells ""
		foreach lib [get_object_name [get_libs *tsmc5ff_*076*]] {
			if {[sizeof_collection [get_lib_cells -quiet ${lib}/F6EN*]] > 0} {
				append_to_collection cells [list [get_lib_cells -quiet ${lib}/F6EN*]]
			}
		}
		set_attribute -quiet [get_object_name $cells] threshold_voltage_group evt
	
	} else {
		set cells ""
		foreach lib [get_object_name [get_libs *tsmc5ff_*067*]] {
			append_to_collection cells [list [get_lib_cells ${lib}/F6L*]]
		}
		set_attribute -quiet [get_object_name $cells] threshold_voltage_group lvt
	
		set cells ""
		foreach lib [get_object_name [get_libs *tsmc5ff_*067*]] {
			append_to_collection cells [list [get_lib_cells -quiet ${lib}/F6UL*]]
		}
		set_attribute -quiet [get_object_name $cells] threshold_voltage_group ulvt
	
		set cells ""
		foreach lib [get_object_name [get_libs *tsmc5ff_*067*]] {
			append_to_collection cells [list [get_lib_cells -quiet ${lib}/F6UN*]]
		}
		set_attribute -quiet [get_object_name $cells] threshold_voltage_group unvt
	
		set cells ""
		foreach lib [get_object_name [get_libs *tsmc5ff_*067*]] {
			if {[sizeof_collection [get_lib_cells -quiet ${lib}/F6EN*]] > 0} {
				append_to_collection cells [list [get_lib_cells -quiet ${lib}/F6EN*]]
			}
		}
		set_attribute -quiet [get_object_name $cells] threshold_voltage_group evt
	
	}
}

#redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { lsi_time_stats {Read SDC} }

# group_path -name INPUTS   -from [all_inputs]    -to [all_registers]
# group_path -name OUTPUTS  -from [all_registers] -to [all_outputs]
# group_path -name FEEDTHRU -from [all_inputs]    -to [all_outputs]
group_path -name INPUTS   -from [all_inputs]    -to [all_registers]
group_path -name OUTPUTS  -from [all_registers] -to [all_outputs]
group_path -name FEEDTHRU -from [all_inputs]    -to [all_outputs]
group_path -name REG2REG -from [all_registers]    -to [all_registers -include_icg] -weight 100 -critical_range 100

#redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { #lsi_time_stats {Group Paths} }

########################################################################
# Check Design for Early RTL debugging
########################################################################

#redirect $dc_reports_hier/${top}_cln05_check_design.rpt {check_design}

if {$DCTOPO} {
	if {$PROJECT == "brcm3" || $PROJECT == "nxt013"} {
		set_preferred_routing_direction -layers {M0 M2 M4 M6 M8 M10 M12 M14 M16 M18 AP} -direction horizontal
		set_preferred_routing_direction -layers {M1 M3 M5 M7 M9 M11 M13 M15 M17 M19} -direction vertical
	} else {
		set_preferred_routing_direction -layers {M0 M2 M4 M6 M8 M10 M12 M14 M16 AP} -direction horizontal
		set_preferred_routing_direction -layers {M1 M3 M5 M7 M9 M11 M13 M15 M17} -direction vertical
	}

	report_preferred_routing_direction > $dc_reports_hier/${top}_routing_directions.rpt
}

########################################################################
# Read DEF file for DC-Topo Synthesis
########################################################################
if {$DCTOPO} {
	#sh cp -rpf ${input_def} $def/${top}.def.gz
	#sh chmod -R 777 $def/${top}.def.gz

#source $dc_scripts/updateDesignDef.tcl
#updateDefMacroNames $def/${top}.def $def/${top}.dct.def

	set enable_rule_based_query true
	extract_physical_constraints $DEF_FILE -verbose


	if {[file exists ./scripts_local/physical_constraints.tcl]} {
		puts "-I- Sourcing script file ./scripts_local/physical_constraints.tcl"
		source -echo -verbose ./scripts_local/physical_constraints.tcl
   	}

	set enable_rule_based_query false
	#redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { #lsi_time_stats {Read DEF} }
	report_physical_constraints > reports/report_physical_constraints.rpt
   	report_preferred_routing_direction > reports/report_routing_directions.rpt
}

########################################################################

if {$PROJECT == "brcm3" || $PROJECT == "nxt013"} {
	set_driving_cell  \
			 -library $library_sc  \
			 -lib_cell  E1LLRA_BUFAX4 -pin o [all_inputs]
	
	set_load \
		       [expr 4 * [load_of ${library_sc}/E2LLRA_INVAX2/i] ] \
	               [all_outputs]
} else {
	set_driving_cell  \
			 -library $library_sc  \
			 -lib_cell  F6LNAA_BUFAX4 -pin o [all_inputs]
	
	set_load \
		       [expr 4 * [load_of ${library_sc}/F6LLAA_INVAX2/i] ] \
	               [all_outputs]
}

########################################################################
# Specify Clock Gating (if needed)
########################################################################

if {[regexp "grid_node_top|mss|msu|reg_fifo|vcu|ncu" $top]} {
	set_clock_gating_style -min 3 \
		-positive_edge_logic integrated:${library_ck}/F6LNAA_LPDCKENOAX16 \
		-control_point before -control_signal scan_enable -setup 0.100 -num_stages 1 -observation_logic_depth 2
} else {
	if {[info exists PROJECT] && $PROJECT == "nextcore"} {
			set_clock_gating_style -min 8 \
				-positive_edge_logic integrated:${library_ck}/F6UNAA_LPDCKENOAX16 \
				-control_point before -control_signal scan_enable -setup 0.050 -num_stages 1 -observation_logic_depth 2

#				-control_point before -control_signal scan_enable -setup 0.035 -num_stages 1 -observation_logic_depth 2
#				-control_point before -control_signal scan_enable -setup 0.085 -num_stages 1 -observation_logic_depth 2
	} elseif {[info exists PROJECT] && $PROJECT == "brcm3" || $PROJECT == "nxt013"} {
		puts "-I- ICG project brcm3"
		set_clock_gating_style -min 8 \
 			-positive_edge_logic integrated:${library_ck}/E5UNRA_LPDCKENOAX16 \
 			-control_point before -control_signal scan_enable -setup $CLOCK_GATING_SETUP -num_stages 1 -observation_logic_depth 2
	} else {
		puts "-I- ICG project else"
		set_clock_gating_style -min 8 \
 			-positive_edge_logic integrated:${library_ck}/F6LNAA_LPDCKENOAX16 \
 			-control_point before -control_signal scan_enable -setup 0.100 -num_stages 1 -observation_logic_depth 2
	}
}

##Added to improve gating coverage
set power_cg_derive_related_clock true

set_clock_gating_check -setup 0.200 [current_design]


if {[regexp "^nsc" $top]}  {
set ckg_exclude [get_ports -filter "direction == in"]
} else {
set ckg_exclude ""
}
sizeof_collection $ckg_exclude
if {$PROJECT == "brcm3" || $PROJECT == "nxt013"} {
	append_to_collection ckg_exclude [get_pins -of [get_cells -f "ref_name =~ M3*" -hier] -f "direction == out"]
} else {
    	append_to_collection ckg_exclude [get_pins -of [get_cells -f "ref_name =~ M5*" -hier] -f "direction == out"]
}
sizeof_collection $ckg_exclude
if  {$top == "ddr5_syn_wrap" || $top == "ecore_quad_complex_top" || $top == "hbm3_chiplet" || $top == "pcore_axi_syn_top"  } {

	append_to_collection ckg_exclude [get_pins -of_objects [get_cells -f "ref_name=~ecore_hif_wrap_top || ref_name=~hbm3_mc4_syn_wrap || ref_name=~cadence_mc_controller_with_sram_wrap || ref_name=~pcore_l3_cluster_cpu_top || ref_name=~pcore_l3_cluster_bank_noc_wrapper" -hierarchical] -f "direction==out"]

}
sizeof_collection $ckg_exclude
redirect {ckg_exclude.rpt} { 
    foreach_in_collection a $ckg_exclude {                                                                                                                                   echo [get_object_name $a]
 }
}
 
###NS wants quad interacting blocks to have gater
set grid_clk_ports ""
if  { $top == "hbm3_chiplet"} {
	#set grid_clk_ports [get_ports {dl?_egress_* dl?_ingress_*}]
	set grid_clk0_ports [get_ports {dl?_egress_*_r0* dl?_ingress_*_r0* dl?_egress_*_r1* dl?_ingress_*_r1*}]
	set grid_clk1_ports [get_ports {dl?_egress_*_r2* dl?_ingress_*_r2* dl?_egress_*_r3* dl?_ingress_*_r3*}]
	set grid_clk2_ports [get_ports {dl?_egress_*_r4* dl?_ingress_*_r4* dl?_egress_*_r5* dl?_ingress_*_r5*}]
	set grid_clk3_ports [get_ports {dl?_egress_*_r6* dl?_ingress_*_r6* dl?_egress_*_r7* dl?_ingress_*_r7*}]
	set grid_clk_ports [get_ports "$grid_clk0_ports $grid_clk1_ports $grid_clk2_ports $grid_clk3_ports"]
}

if  { $top == "ecore_quad_complex_top"} {
	set grid_clk_ports {g2h_cbus_req_cip_* g2h_cbus_rsp_cep_* g2h_lnb_req_cip_* g2h_lnb_rsp_cep_* h2g_cbus_req_cep_* h2g_cbus_rsp_cip_* h2g_lnb_req_cep_* h2g_lnb_rsp_cip_*}     
}

if {[regexp d2d $top]} {
	set grid_clk_ports  [get_ports {d2d_grid_* grid_d2d_* d2d_cc_lnb_data* d2d_cc_lnb_valid* cc_d2d_lnb_ready* cc_d2d_lnb_data* cc_d2d_lnb_valid* d2d_cc_lnb_ready*}]
}

if  { $top == "center_hif_tile_top"} {
	#set grid_g2h_clk_ports {g2h_dlink_* g2h_p* g2h_lnb_req_cip_* g2h_lnb_rsp_cep_* g2h_cbus_rsp_cep_* g2h_cbus_req_cip_*}
	#set grid_h2g_clk_ports {h2g_dlink_* h2g_p* h2g_lnb_rsp_cip_* h2g_lnb_req_cep_* h2g_cbus_req_cep_* h2g_cbus_rsp_cip_*}
	#set grid_clk_port {g2h_dlink_* g2h_p* g2h_lnb_req_cip_* g2h_lnb_rsp_cep_* g2h_cbus_rsp_cep_* g2h_cbus_req_cip h2g_dlink_* h2g_p* h2g_lnb_rsp_cip_* h2g_lnb_req_cep_* h2g_cbus_req_cep_* h2g_cbus_rsp_cip_*}
	set g2h_grid_clk {g2h_dlink_* g2h_p* g2h_lnb_req_cip_* g2h_lnb_rsp_cep_* g2h_cbus_rsp_cep_* g2h_cbus_req_cip_* g2h_tlm_ts_sync_out}
	set h2g_grid_clk {h2g_dlink_* h2g_p* h2g_lnb_rsp_cip_* h2g_lnb_req_cep_* h2g_cbus_req_cep_* h2g_cbus_rsp_cip_* h2g_tlm_ts_sync_out}
	set grid_clk_ports {g2h_dlink_* g2h_p* g2h_lnb_req_cip_* g2h_lnb_rsp_cep_* g2h_cbus_rsp_cep_* g2h_cbus_req_cip_* g2h_tlm_ts_sync_out h2g_dlink_* h2g_p* h2g_lnb_rsp_cip_* h2g_lnb_req_cep_* h2g_cbus_req_cep_* h2g_cbus_rsp_cip_* h2g_tlm_ts_sync_out}
}


set ckg_exclude [remove_from_collection $ckg_exclude $grid_clk_ports] 
   sizeof_collection $ckg_exclude
   redirect {ckg_exclude_grid.rpt} { 
    foreach_in_collection a $ckg_exclude {                                                                                                                                   echo [get_object_name $a]
}
}

if {![regexp "grid_node_top|mss|msu|reg_fifo|vcu|ncu" $top]} {
	set_clock_gating_enable -exclude $ckg_exclude
}

set compile_clock_gating_through_hierarchy true

#set power_remove_redundant_clock_gates false
set power_do_not_size_icg_cells true
set case_analysis_propagate_through_icg true
#redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { #lsi_time_stats {Set Clock Gating} }

#########################################################################
##### 5nm Synthesis StdCell and Memory Derates
### Set STD_CELL_AGING_DERATE to 0.06 for HOD, 0.05 for QOD, 0.04 for NOD
set STD_CELL_AGING_DERATE   0.05
### Set the STD_CELL_PROCESS_DERATE to 0.00 by default, 0.02 for specific early programs
set STD_CELL_PROCESS_DERATE 0.00
### Set memory aging to 3%
set MEMORY_AGING_DERATE     0.03
### Set the MEMORY_PROCESS_DERATE to 0.00 by default, 0.03 for specific early programs
set MEMORY_PROCESS_DERATE   0.00

if {$PROJECT == "brcm3" || $PROJECT == "nxt013"} {
	set memory_name_pattern *M3*X*VT*
	set memory_libcells [get_lib_cells */$memory_name_pattern -quiet]
	set std_cell_libcells [remove_from_collection [get_lib_cells -quiet tsmc*/E*] $memory_libcells]
} else {
	set memory_name_pattern *M5*X*VT*
	set memory_libcells [get_lib_cells */$memory_name_pattern -quiet]
	set std_cell_libcells [remove_from_collection [get_lib_cells -quiet tsmc*/*F6*] $memory_libcells]
}


### standard cell: aging + process cell_delay derate
set_timing_derate  -late  [expr 1.0 + $STD_CELL_AGING_DERATE + $STD_CELL_PROCESS_DERATE] -cell_delay -data $std_cell_libcells

if { [sizeof_collection $memory_libcells] > 0 } {
    ## memory: 5% default margin + 3% aging + process cell_delay derate
    set_timing_derate  -late  [expr 1.05 + $MEMORY_AGING_DERATE + $MEMORY_PROCESS_DERATE] -cell_delay -data $memory_libcells
    ## memory: 5% default margin + 3% aging + process cell_check derate
    set_timing_derate  -late  [expr 1.05 + $MEMORY_AGING_DERATE + $MEMORY_PROCESS_DERATE] -cell_check       $memory_libcells
}

########################################################################
# Compile Constraints
########################################################################

#-- Compile constraints
set_max_area 0.0

#-- Recommended option for leakage power optimization
# set_leakage_optimization false

if {$PROJECT == "brcm3" || $PROJECT == "nxt013"} {
	   source -e -v scripts/flow/BRCM_dont_use_cln03.tcl > reports/dont_use.rpt
	   echo "apc : $apc"
	   echo "ac:   $ac"
	   echo "ap:   $ap"
	
} else {
	if {[regexp "grid_node_top|mss|msu|reg_fifo|vcu|ncu|arc_wrapper|alb_cpu_top" $top]} {
	   ###dont use or remove dont_use
	   source -e -v scripts/flow/BRCM_dont_use_cln05_tgate.tcl > reports/dont_use.rpt
	   echo "apc : $apc"
	   echo "ac:   $ac"
	   echo "ap:   $ap"
	} elseif {[regexp "nsc" $top]} {
	   #INCR compile with UL opened up and buffered FFs hidden
	   source -e -v scripts/flow/BRCM_dont_use_cln05_incr_nsc.tcl > reports/dont_use.rpt
	} else {
	   ###dont use or remove dont_use
	   source -e -v scripts/flow/BRCM_dont_use_cln05.tcl > reports/dont_use.rpt
	   echo "apc : $apc"
	   echo "ac:   $ac"
	   echo "ap:   $ap"
	}
	
	set_target_library_subset -clock_path -use {*/F6LNAA_CKMUX2X2 */F6LNAA_CKMUX2X8}
}
########################################################################
# Specify WLM to be used (0.5, 1.0, )
########################################################################
##applicable for first round till def is available
if {!$DCTOPO} {
	set_wire_load_model -name W3600 -library $library_sc

}

if {!$DCTOPO && $ZWLM} {
    set_zero_interconnect_delay_mode true
}

########################################################################
# Fix output ports
########################################################################

set_fix_multiple_port_nets -all -outputs
set_fix_multiple_port_nets -all -buffer_constants

########################################################################
# Specify operating conditions
########################################################################

#	set_operating_conditions -library $library_sc $pvt_corner($pvt,op_code)
set_operating_conditions \
	-max_library ${library_sc}.db:${library_sc} \
	-max $pvt_corner($pvt,op_code)
########################################################################
# Timing Derate for OCV Margin
# Apply 4.5% to be consistent with ICC, Total DC-T Margin for 0.2 library is 15%
# This Additional OCV Margin is not required if this 4.5% is already included in uncertainty margin
########################################################################

#set_timing_derate -data -early 0.955
#set_timing_derate -data -late  1.045

########################################################################
# Use max_trans attribute in DC-T
# Use 0.3 for 16FF
########################################################################
set_max_transition 0.2 [current_design]

########################################################################
# Variables to improve correlation to PT/ICC (Enable as needed)
########################################################################

set timing_use_enhanced_capacitance_modeling true
set timing_enable_multiple_clocks_per_reg true

########################################################################
# Library check and Compile check for DCTOPO
########################################################################

# if {$DCTOPO} {
#  redirect $dc_reports_hier/${top}_cln05_check_library.rpt {check_library}
#  redirect $dc_reports_hier/${top}_cln05_compile_check.rpt {compile_ultra -check_only}
# ### Preferred routing directions to match the directions in the iccii .tf and lef
# set_preferred_routing_direction -layers {M0 M2 M4 M6 M8 M10 M12 M14 M16 AP} -direction horizontal
# set_preferred_routing_direction -layers {M1 M3 M5 M7 M9 M11 M13 M15 M17} -direction vertical
# report_preferred_routing_direction > $dc_reports_hier/${top}_routing_directions.rpt
# }

########################################################################
# Min, Max Routing Layers
# Applicable for DCT, as DCG will use the DEF file with all metal blockages provided
# Change Accordingly for 6 Layers Vs 8 Layers
########################################################################

if {$DCTOPO} {
	set_ignored_layers -min_routing_layer M3 -max_routing_layer M17
	## set_congestion_options -layer M3 -availability 0.6
	## set_congestion_options -layer M4 -availability 0.6
	## set_congestion_options -layer M5 -availability 0.6
	## set_congestion_options -layer M6 -availability 0.6
	## set_congestion_options -layer M7 -availability 0.7
	## set_congestion_options -layer M8 -availability 0.7
	## set_congestion_options -layer M9 -availability 0.5
	## set_congestion_options -layer M10 -availability 0.5
	## set_congestion_options -layer M11 -availability 0.5
	## set_congestion_options -layer M12 -availability 0.5
	## set_congestion_options -layer M13 -availability 0.5
	## set_congestion_options -layer M14 -availability 0.1
	## set_congestion_options -layer M15 -availability 0.1
}


########################################################################
# Placement/Blockage constraints
########################################################################

########################################################################
# Placement/Blockage constraints
########################################################################
if {$DCTOPO} {
	set placer_max_cell_density_threshold 0.75
	set placer_soft_keepout_channel_width 10
}

########################################################################
# Critical Range & Compile options
########################################################################

set_critical_range 0.5 [current_design]

#set_ungroup dummy_buffer*
##set write_name_nets_same_as_ports true


#set compile_prefer_mux true
##Use the following variable during incremental compile
set spg_congestion_placement_in_incremental_compile true


##You can enable retiming in the script instead of embedded script. This is for retiming
#set_optimize_registers true -design [current_design]  -print_critical_loop


########################################################################
# Add revision TAG cell
########################################################################

# Add revision info
  set full_date [sh date '+%b_%d_%Y']
  set REV_DATE ${full_date}
  if {$PROJECT == "brcm3" || $PROJECT == "nxt013"} {
	  set revision_cell ${library_sc}/E1LLRA_INVX4
  } else {
	  set revision_cell ${library_sc}/F6LLAA_INVX4
  }

  set this_revision_string [join [list DC_SYNTH_BRCM_REV_TAG_${top}$REV_DATE] ]
  set this_rev_cell $this_revision_string
  create_cell $this_rev_cell $revision_cell
  #create_cell $this_rev_cell -logic 0
  set_dont_touch [get_cells $this_rev_cell]

########################################################################
# Compile_Ultra
# use -spg option for congestion dominated designs
########################################################################

set compile_seqmap_identify_shift_registers false

if { ${const_prop} == true } {
  set compile_delete_unloaded_sequential_cells true
  set compile_seqmap_propagate_high_effort true
  set compile_seqmap_propagate_constants true
  set compile_enable_constant_propagation_with_no_boundary_opt true
} else {
  set compile_delete_unloaded_sequential_cells false
  set compile_seqmap_propagate_high_effort false
  set compile_seqmap_propagate_constants false
  set compile_enable_constant_propagation_with_no_boundary_opt false
}
  set compile_enable_register_merging true

set enable_recovery_removal_arcs false
set compile_seqmap_identify_shift_registers false
set change_names_dont_change_bus_members true
set write_name_nets_same_as_ports true
set synlib_enable_analyze_dw_power 1
set hdlin_reporting_level comprehensive
set compile_fix_multiple_port_nets true
set compile_timing_high_effort_tns true

set_app_var compile_ultra_ungroup_dw true ;
set_app_var spg_enable_via_resistance_support true ;
set compile_ultra_ungroup_small_hierarchies true


if {$DCTOPO} {

    set compile_register_replication true
    set_app_var compile_register_replication_across_hierarchy true
    if {[regexp "grid_node_top|mss|msu|reg_fifo|vcu|ncu" $top]} {
	##power optimization		
	set_compile_power_high_effort -total TRUE	
    }	

}

##Reset pipeline/high fanout FF cloning
if {[regexp "nsc" $top]} {
    if [file exists scripts_local/${top}_replication.tcl] {
       source -e -v scripts_local/${top}_replication.tcl
    }
}

if {[regexp "grid_node_top|mss|msu|reg_fifo|vcu|ncu" $top]} {
##power optimization		
# moved to DCT run
#set_compile_power_high_effort -total TRUE		
		
##next option		
set_dynamic_optimization true		
set_app_var power_low_power_placement true	
}
	
if {$top == "arc_wrapper"} {
remove_generated_clock [get_clocks */*gclk]
}

#if {$top=="sandbox_center_top"} {
#  foreach blk {d2d_to_bridge_pipe_stage bridge_to_d2d_pipe_stage} {
#    echo "Compiling sub-block $blk"
#    current_design $blk
#    create_clock -period 0.5 [get_ports axi_clk]
#    compile -scan
#   define_name_rules verilog -preserve_struct_ports
#   change_names -rules verilog -hierarchy
#   source /lab/projects/da/act-1.0/lib/tcl/change_names_avago.tcl
#   current_design ${top}
#   set_dont_touch [get_designs $blk]
# }
#}

set blks [list  pcore_eth2hif_lnb_repeater_NUM_OF_SLICES1 d2d_to_bridge_pipe_stage bridge_to_d2d_pipe_stage nxt_vr_repeater_cluster_bcg_NUM_OF_SLICES2_DATA_WIDTH133 apb_repeater_cluster_1_0_1_0_3_32_4_32 axi_repeater_0_2_1_1_48_512_64_6_8_1_3_2_2_13_8_69_9_5_4_4_3_4 ]
if {[regexp sandbox $top]} {
  	foreach blk $blks {
    		if {[sizeof_collection [get_designs -quiet $blk]]} {
      			current_design $blk
#      			set clk axi_clk
      			set clk [lindex [get_object_name [get_ports *_clk* -f "full_name!~*dft* && direction==in"]] 0]
      			#if {[regexp apb $blk]} { set clk apb_clk }
      			echo "arrao : pre-compiling sub-block $blk with clock=$clk"
      			#create_clock -period 0.5 [get_ports ${clk}]
      			create_clock -period 0.5 [get_ports $clk ]
      			set_input_delay 0.45 [all_inputs] -clock $clk
      			set_output_delay 0.45 [all_outputs] -clock $clk
      			set_fix_multiple_port_nets -all -outputs
      			set_fix_multiple_port_nets -all -buffer_constants
			set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ SRESYNC"]
			set_dont_touch [get_cells -quiet -hierarchical -filter "ref_name=~ CKMUX*"]
 			set_dont_touch [get_cells -quiet -hierarchical -filter "full_name=~ DONT_TOUCH"]
      			set_attribute  [get_cells -quiet -hierarchical -filter "full_name=~ SIZE_ONLY"] size_only true
      			compile -scan -gate_clock
      			define_name_rules verilog -preserve_struct_ports
      			change_names -rules verilog -hierarchy
#      			source /lab/projects/da/act-1.0/lib/tcl/change_names_avago.tcl
			#------------------------------------------------------------------------------
			######set bus_naming_style {%s_%dA}

			######suppress_message "NMA-8"
			suppress_message "NMA-9"
			suppress_message "NMA-16"
			suppress_message "NMA-14"
			suppress_message "UCN-4"

			set change_names_dont_change_bus_members true
			define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
			define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
			define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port

			define_name_rules scip -first_restricted {0-9 _}
			#define_name_rules scip -last_restricted  {_}
			change_names -hierarchy -rules scip
						#define_name_rules scip_last -equal_ports_nets
			#define_name_rules scip_last -special verilog
			#change_names -hierarchy -rules scip_last
			change_names -hierarchy -rules verilog
			#------------------------------------------------------------------------------


      			current_design ${top}
 			set_dont_touch [get_designs $blk]
			set_dont_touch [get_cells -hierarchical -filter "ref_name==$blk"]
    		} else {
      			echo "arrao : sub-block $blk not found"
    		}
  	}
}

if {[regexp sandbox $top]} {
  	set_dont_touch_network [get_ports apb_clk]
}

#------------------------------------------------------------------------------
# extra setting and operations 
#------------------------------------------------------------------------------
set hook_script "./scripts_local/pre_compile_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

if {$DCTOPO} {
	compile_ultra -check_only -spg > reports/compile_ultra.check
	
	set exit_flag 0
	
	set MISSING_LOCATION [filter_collection [all_macro_cells] "is_fixed==false"]
	if {[sizeof_collection $MISSING_LOCATION] > 0} {
		set exit_flag 1
		puts "ERROR below macros are uplaced. "
		foreach_in_collection inst $MISSING_LOCATION {
            		puts "[get_object_name $inst]"
		}
        	puts "\n"
	}
	
	if {![catch {exec grep SPG-011 reports//compile_ultra.check} results options]} {
		set exit_flag 1
		puts "ERROR below macros are uplaced. "
		puts "$results"
        	puts "\n"		
	}
	
	if {$exit_flag} {
		puts "Fatal Error. exit."
		exit 1
	}
	
	set cmd "compile_ultra -scan  -no_seq_output_inversion -spg"
	if {![info exists NO_AUTOUNGROUP] || $NO_AUTOUNGROUP == "true"} {
		set cmd "$cmd -no_autoungroup"
	}
	if {![info exists LPG] || $LPG == "true"} {
		set cmd "$cmd -gate_clock"
	}
	if {![info exists RETIME] || $RETIME == "true"} {
		set cmd "$cmd -retime"
	}

	echo $cmd
	eee $cmd

#	if {[regexp "nsc|grid_node_top|mss|msu|reg_fifo|alb_cpu_top|arc_wrapper" $top]} {
#		eee {compile_ultra -scan  -no_seq_output_inversion -gate_clock -spg}
#	} else {
#		eee {compile_ultra -scan  -no_seq_output_inversion -gate_clock -spg -no_autoungroup}
# 	}
}

if {!$DCTOPO} {
	set cmd "compile_ultra -scan  -no_seq_output_inversion "
	if {![info exists NO_AUTOUNGROUP] || $NO_AUTOUNGROUP == "true"} {
		set cmd "$cmd -no_autoungroup"
	}
	if {![info exists LPG] || $LPG == "true"} {
		set cmd "$cmd -gate_clock"
	}
	if {![info exists RETIME] || $RETIME == "true"} {
		set cmd "$cmd -retime"
	}

	echo $cmd
#	sdp -start
	eee $cmd
#	sdp -stop
	
#	if {[regexp "nsc|grid_node_top|mss|msu|reg_fifo|alb_cpu_top|arc_wrapper" $top]} {
#		eee {compile_ultra -scan  -no_seq_output_inversion -gate_clock}
#	} else {
#		eee {compile_ultra -scan  -no_seq_output_inversion -gate_clock -no_autoungroup}
#	}
}

if {[info exists UPF_FILE] && [file exists $UPF_FILE]} {
	### analyze_mv_feasibility is the command that helps to identify if optimization will result in unmapped PM cells without running synthesis.
	### analyze_mv_feasibility analyzes the UPF and design/library setup and provides feedback on whether all the isolation cells and enable level shifters can get mapped
	analyze_mv_feasibility
}

#------------------------------------------------------------------------------
# post setting and operations 
#------------------------------------------------------------------------------
set hook_script "./scripts_local/post_compile_setting.tcl"
if {[file exists $hook_script]} {
        puts "-I- running Extra setting from $hook_script"
        check_script_location $hook_script
        source -v $hook_script
}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write -hierarchy -format ddc -output out/${DESIGN_NAME}.compile.ddc
write -hierarchy -format verilog -output out/${DESIGN_NAME}.compile.v
exec gzip -f out/${DESIGN_NAME}.compile.v

#------------------------------------------------------------------------------
# compile reports
#------------------------------------------------------------------------------
set timing_reports [list \
	"report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 > reports/compile/compile.rpt.detailed"
	]

   foreach path_group [get_object_name [get_path_groups]] {
	lappend timing_reports "report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 -slack_lesser_than 0 -group $path_group > reports/compile/compile.rpt.$path_group.detailed"
   }

   parallel_execute $timing_reports

   exec gawk -f ./scripts/bin/slacks.awk reports/compile/compile.rpt.detailed     | sort -n > reports/compile/compile.rpt
   exec ./scripts/bin/timing_filter.pl reports/compile/compile.rpt.detailed
   
   foreach path_group [get_object_name [get_path_groups]] {
	exec gawk -f ./scripts/bin/slacks.awk reports/compile/compile.rpt.$path_group.detailed	| sort -n > reports/compile/compile.rpt.$path_group
	exec ./scripts/bin/timing_filter.pl reports/compile/compile.rpt.$path_group.detailed

   }
   
redirect -file reports/report_app_var_compile.rpt {report_app_var}
redirect -file reports/report_app_var_only_changed_vars_compile.rpt {report_app_var -only_changed_vars}
redirect -file reports/compile/report_resource.rpt {report_resource -nosplit -hierarchy}

if {[llength [info command shell_is_dcnxt_shell]] && [shell_is_dcnxt_shell]}  {
	report_transformed_register > reports/compile/report_transformed_register.rpt
}

#------------------------------------------------------------------------------
# compile incr
#------------------------------------------------------------------------------
if {[info exists AUTO_PG] && $AUTO_PG == "true"} {
	puts "-I- create_auto_path_groups"
	create_auto_path_groups -mode mapped \
		-prefix AUTO_PG_ \
		-file scripts_local/auto_path_groups.tcl
}


#if {[regexp "grid_node_top|mss|msu|reg_fifo|vcu|ncu" $top]} {
#

if {[regexp "grid_node_top|mss|msu|reg_fifo|vcu|ncu|arc_wrapper|alb_cpu_top" $top]} {

	#INCR compile with UL opened up and buffered FFs hidden
	source -e -v scripts/flow/BRCM_dont_use_cln05_incr.tcl > reports/dont_use_incr.rpt
	#set_attribute [get_lib_cells -regexp -quiet .*/F6UL.*] dont_use false
	#set_attribute [get_lib_cells -regexp -quiet .*/F6.*BSDFF.*] dont_use true
	eee {compile_ultra -incr}
	

}
if {[regexp "nsc" $top]} {
	   #INCR compile with UL opened up and buffered FFs hidden
	#   source -e -v scripts/flow/BRCM_dont_use_cln05_incr_nsc.tcl > reports/dont_use_incr.rpt
}

if {[regexp "^nsc|alb_cpu_top|arc_wrapper" $top]} {
	eee {compile_ultra -incr}
}

#redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { lsi_time_stats {Compile} }
if {$USE_SAIF} {
redirect  $dc_reports_hier/${top}_saif_report_after_compile.rpt { report_saif -hierarchy -rtl_saif -missing }
}


if {[info exists AUTO_PG] && $AUTO_PG == "true"} {
	puts "-I- remove_auto_path_groups"
	remove_auto_path_groups
           	remove_path_group AUTO_PG*
}

#------------------------------------------------------------------------------
# save design
#------------------------------------------------------------------------------
write -hierarchy -format ddc -output out/${DESIGN_NAME}.compile_incr.ddc
write -hierarchy -format verilog -output out/${DESIGN_NAME}.compile_incr.v
exec gzip -f out/${DESIGN_NAME}.compile_incr.v

if {$top == "arc_wrapper"} {
remove_generated_clock [get_clocks */*gclk]
}

#------------------------------------------------------------------------------
# compile reports
#------------------------------------------------------------------------------
# ports checker
source ./scripts/procs/dc/reports.tcl
report_ports_conn


if {[llength [info command shell_is_dcnxt_shell]] && [shell_is_dcnxt_shell]}  {
	report_transformed_register > reports/compile_incr/report_transformed_register.rpt
}

set timing_reports [list \
     "report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 > reports/compile_incr/compile_incr.rpt.detailed"
     ]

foreach path_group [get_object_name [get_path_groups]] {
     lappend timing_reports "report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 -slack_lesser_than 0 -group $path_group > reports/compile_incr/compile_incr.rpt.$path_group.detailed"
}

parallel_execute $timing_reports

exec gawk -f ./scripts/bin/slacks.awk reports/compile_incr/compile_incr.rpt.detailed	 | sort -n > reports/compile_incr/compile_incr.rpt
exec ./scripts/bin/timing_filter.pl reports/compile_incr/compile_incr.rpt.detailed

foreach path_group [get_object_name [get_path_groups]] {
     exec gawk -f ./scripts/bin/slacks.awk reports/compile_incr/compile_incr.rpt.$path_group.detailed	     | sort -n > reports/compile_incr/compile_incr.rpt.$path_group
     exec ./scripts/bin/timing_filter.pl reports/compile_incr/compile_incr.rpt.$path_group.detailed

}

parallel_execute [list \
	"report_qor > reports/compile_incr/report_qor.compile_incr.rpt" \
	"report_area -nosplit > reports/compile_incr/report_area.compile_incr.rpt" \
	"report_area -nosplit -hierarchy > reports/compile_incr/report_area_hierarchy.compile_incr.rpt" \
	"report_clock_gating -nosplit > reports/compile_incr/report_clock_gating.compile_incr.rpt" \
	"report_clock_gating -nosplit -ungated -verbose > reports/compile_incr/report_clock_gating_verbose.compile_incr.rpt" \
]

# script under scripts/procs/common_snps/be_reports.tcl
# generating syn_inputs_fo_size.rpt and syn_outputs_fi_size.rpt
eee {catch { be_report_io_fo  } err}
# script under scripts/procs/common_snps/be_reports.tcl
# generating report_logic_levels.rpt
eee {catch { be_report_logic_levels } err}

# // Parsing logic levels report to produce sorted inputs report
set logic_level_report "reports/report_logic_levels.rpt"
if { [file exists $logic_level_report] } {
    set fi    [open $logic_level_report r]
    set f_rpt [split [read $fi] \n]
    close $fi

    set my_hdr [lindex $f_rpt 0]
    set my_inputs ""
    set my_outputs ""

    foreach _entry $f_rpt {
        lassign $_entry _start _end _sclk _eclk _lgc _prd _grp
        if { [regexp {[a-zA-Z]} $_start] } {
            if { ![regexp {/} $_start] && [regexp {/} $_end] } {
                lappend my_inputs $_entry
            } elseif { [regexp {/} $_start] && ![regexp {/} $_end] } {
                lappend my_outputs $_entry
            }
        }
    }
    set sorted_inputs  [lsort -index 2 [lsort -real -decreasing -index 4 $my_inputs]]
    set sorted_outputs [lsort -index 3 [lsort -real -decreasing -index 4 $my_outputs]]

    set fo [open "reports/syn_report_input_logic_levels.rpt" w]
    puts $fo "$my_hdr"
    foreach _l $sorted_inputs {
        puts $fo "$_l"
    }
    close $fo

    set fo [open "reports/syn_report_output_logic_levels.rpt" w]
    puts $fo "$my_hdr"
    foreach _l $sorted_outputs {
        puts $fo "$_l"
    }
    close $fo
}
# // done creating syn_report_input_logic_levels.rpt

redirect -file reports/compile_incr/report_power.compile_incr.rpt        		{ report_power -nosplit}
#redirect -file reports/compile_incr/report_power_cell.compile_incr.rpt	       	{ report_power -nosplit -verbose -cell}
redirect -file reports/compile_incr/report_power_hierarchy.compile_incr.rpt 	{ report_power -nosplit -hierarchy -verbose}
redirect -file reports/compile_incr/report_resource.rpt {report_resource -nosplit -hierarchy}

########################################################################
# Group I/O & Feedthrough paths
########################################################################

########################################################################
# Write Reports
########################################################################
##change naming conventions as appropriate
#redirect $dc_reports_hier/${top}_cln05_check_timing.rpt {check_timing}
#redirect $dc_reports_hier/${top}_cln05_dw_foundation.rpt {report_synlib dw_foundation.sldb}
#redirect $dc_reports_hier/${top}_cln05_timing_full__dc.rpt {report_timing_alias_full}
#redirect $dc_reports_hier/${top}_cln05_timing_summary.rpt {report_timing_alias_summary}
#redirect $dc_reports_hier/${top}_cln05_area_dc.rpt {report_area_alias}
#redirect $dc_reports_hier/${top}_cln05_power_dc.rpt {report_power_alias}
#redirect $dc_reports_hier/${top}_cln05_qor_dc.rpt {report_qor}
#redirect $dc_reports_hier/${top}_cln05_vtdist_dc.rpt {report_threshold_voltage_group}
##redirect $dc_reports_hier/${top}_cln05_resource_post_synth.rpt {report_resource -nosplit -hierarchy}
#redirect $dc_reports_hier/${top}_cln05_clock_gating.rpt {report_clock_gating -verbose -ungated -nosplit}
#redirect $dc_reports_hier/${top}_cln05_grid_clk.rpt {report_timing -group grid_clk -nosplit -slack_lesser_than 0 -max_paths 1000000}
##redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { lsi_time_stats {Write Reports} }
#redirect $dc_reports_hier/${top}_cln05_short_summary_pg.rpt {report_timing_alias_short}

if {$DETAILED_HIER_REPORT} {
    be_report_hier -area -level 4 -details
} else {
    be_report_hier -area -level 4
}


###########################################################################
# Quick snapshot of the floorplan
###########################################################################

if {$DCTOPO} {
gui_start -no_windows
gui_create_window -type LayoutWindow
gui_show_map -map "Global Route Congestion" -show true
gui_zoom -window [gui_get_current_window -view] -full
gui_write_window_image -format jpg -file $dc_outputs_hier/${top}_floorplan.jpg
gui_close_window -all
}

########################################################################
# lsi_change_names
########################################################################

#source $fs_release/shared/synopsys/scripts/naming_rules/lsi_change_names.tcl
if {![regexp sandbox $top] && ![regexp chiplet $top]} {
  	set uniquify_naming_style "${top}_%s_%d"
  	puts "Uniquifying $top as it is not a sandbox or chiplet"
  	uniquify -force
} else {
  	puts "Skip uniquify on $top"
}

#source /lab/projects/da/act-1.0/lib/tcl/change_names_avago.tcl
#----------------------------------------------------------------------------------------------
######suppress_message "NMA-8"
suppress_message "NMA-9"
suppress_message "NMA-16"
suppress_message "NMA-14"
suppress_message "UCN-4"

set change_names_dont_change_bus_members true
define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port

define_name_rules scip -first_restricted {0-9 _}
#define_name_rules scip -last_restricted  {_}
change_names -hierarchy -rules scip
#define_name_rules scip_last -equal_ports_nets
#define_name_rules scip_last -special verilog
#change_names -hierarchy -rules scip_last
change_names -hierarchy -rules verilog
#----------------------------------------------------------------------------------------------


#ungroup -flatten  -force -all
define_name_rules -map {{"/", "__"}}  verilog -restrict "/"
change_names -rules verilog


#set_svf -off


##lsi_change_names
#redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { #lsi_time_stats {Change Names} }

########################################################################
# Write Netlist, DDC, SDC
########################################################################
##
#write -f verilog -hier -o $dc_outputs_hier/${top}.v
#write -f ddc -hier -o $dc_outputs_hier/${top}.ddc
##added below code
foreach_in_collection v_mem [get_cells -quiet -hier -filter "ref_name=~*M5SRF211*EB*_wrapper"] {
    if {[string match 0 [get_attr [get_flat_pins -quiet -of_object $v_mem -filter "lib_pin_name=~CORE_BIST_PTRN_FILL"] constant_value]]} {
        foreach_in_collection v_DA_pin [get_flat_pins -of_object $v_mem -filter "lib_pin_name=~DA*"] {
            set_disable_timing $v_mem -from BIST_CLK -to [file tail [get_object $v_DA_pin]]
        }
    }
}

set sdc_write_unambiguous_names false
set write_sdc_output_lumped_net_capacitance false
set write_sdc_output_net_resistance false

###remove path groups
remove_path_group INPUTS
remove_path_group OUTPUTS
remove_path_group FEEDTHRU
remove_path_group REG2REG 
remove_clock_gating_check [current_design]
write_sdc -nosplit  $dc_outputs_hier/${top}.sdc

##write_parasitics -format distributed -output $dc_outputs_hier/${top}_cln05_dct.${dc_version}.spef
##write_sdf $dc_outputs_hier/${top}_cln05_dct.${dc_version}.sdf

#redirect -append $dc_reports_hier/${top}_cln05_runstats.$dc_version { lsi_time_stats {Write Outputs} }

if {$DCTOPO} {
write_def -output outputs/hier/${top}.def
}
echo "Remove bad icgs if you wish to"

if {$USE_SAIF} {
write_saif -output $dc_outputs_hier/${top}_noprop.saif.gz
write_saif -propagated -output $dc_outputs_hier/${top}.saif.gz
}

##optimize_area
eee {optimize_netlist -area}

#####remove unloaded clk gates
#source -e -v ${dc_scripts}/remove_floating_cells.tcl

####Flattening
if {[info exists FLAT_DESIGN] && $FLAT_DESIGN != "false" } {
	write -hierarchy -format ddc -output out/${DESIGN_NAME}.hier.ddc
	write -hierarchy -format verilog -output out/${DESIGN_NAME}.hier.v
	exec gzip -f out/${DESIGN_NAME}.hier.v
	
	set power_cg_flatten true ; #Flatten clock gates
	ungroup -flatten  -force -all
	#source /lab/projects/da/act-1.0/lib/tcl/change_names_avago.tcl
	#----------------------------------------------------------------------------------------------
	#	define_name_rules -map {{"/", "__"}}  verilog -restrict "/"
	#	change_names -rules verilog
	######set bus_naming_style {%s_%dA}

	######suppress_message "NMA-8"
	suppress_message "NMA-9"
	suppress_message "NMA-16"
	suppress_message "NMA-14"
	suppress_message "UCN-4"
	
	set change_names_dont_change_bus_members true
	define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type cell
	define_name_rules scip -allowed          {a-z A-Z 0-9 _}   -type net
	define_name_rules scip -allowed          {a-z A-Z 0-9 _[]} -type port
	
	define_name_rules scip -first_restricted {0-9 _}
	#define_name_rules scip -last_restricted  {_}
	change_names -hierarchy -rules scip
	#define_name_rules scip_last -equal_ports_nets
	#define_name_rules scip_last -special verilog
	#change_names -hierarchy -rules scip_last
	change_names -hierarchy -rules verilog
	#----------------------------------------------------------------------------------------------

	define_name_rules -map {{"/", "__"}}  verilog -restrict "/"
	change_names -rules verilog
	#write -f verilog -hier -o $dc_outputs_flat/${top}.v
	#write -f ddc -hier -o $dc_outputs_flat/${top}.ddc
}

set sdc_write_unambiguous_names false
set write_sdc_output_lumped_net_capacitance false
set write_sdc_output_net_resistance false

write_sdc -nosplit  out/${top}.sdc

if {[info exists CREATE_SPEF] && $CREATE_SPEF == "true" } {
	puts "-I- generate spef files "
   	set start_t [clock seconds]
	write_parasitics -output out/spef/${DESIGN_NAME}.${STAGE}.spef.${rc}_$pvt_corner($pvt,temperature).gz
   	set end_t [clock seconds]
   	puts "-I- Elapse time for running write_parasitics is [expr ($end_t - $start_t)/60/60/24] days , [clock format [expr $end_t - $start_t] -timezone UTC -format %T]"
}


if {$USE_SAIF} {
    write_saif -output out/${top}_noprop.saif.gz
    write_saif -propagated -output out/${top}.saif.gz
    saif_map -type ptpx       -write_map out/${DESIGN_NAME}.mapped.SAIF.ptpx.namemap
}

if {$DCTOPO} {
write_def -output $dc_outputs_flat/${top}.def
}

set dest_dir $dc_outputs_flat
#source $dc_scripts/dump_mbr_dc.tcl
#
###dump flattened reports
#redirect $dc_reports_flat/${top}_cln05_check_timing.rpt {check_timing}
#redirect $dc_reports_flat/${top}_cln05_dw_foundation.rpt {report_synlib dw_foundation.sldb}
#redirect $dc_reports_flat/${top}_cln05_timing_full__dc.rpt {report_timing_alias_full}
#redirect $dc_reports_flat/${top}_cln05_timing_summary.rpt {report_timing_alias_summary}
#redirect $dc_reports_flat/${top}_cln05_area_dc.rpt {report_area_alias}
#redirect $dc_reports_flat/${top}_cln05_power_dc.rpt {report_power_alias}
#redirect $dc_reports_flat/${top}_cln05_qor_dc.rpt {report_qor}
#redirect $dc_reports_flat/${top}_cln05_vtdist_dc.rpt {report_threshold_voltage_group}
#redirect $dc_reports_flat/${top}_cln05_resource_post_synth.rpt {report_resource -nosplit -hierarchy}
#redirect $dc_reports_flat/${top}_cln05_clock_gating.rpt {report_clock_gating -verbose -ungated -nosplit}
#redirect $dc_reports_flat/${top}_cln05_grid_clk.rpt {report_timing -group grid_clk -nosplit -slack_lesser_than 0 -max_paths 1000000}
#redirect $dc_reports_flat/${top}_cln05_dw_area.rpt {report_area -nosplit -designware}
###registers not receiving clocks
#source /project/apd_nxt009/common_scripts/dc/proc.get_unclocked_registers.tcl
#redirect ${dc_reports_flat}/${top}_cln05_unclocked_registers.rpt {get_unclocked_registers}
##create path groups and dump flat reports for better understanding
group_path -name INPUTS   -from [all_inputs]    -to [all_registers]
group_path -name OUTPUTS  -from [all_registers] -to [all_outputs]
group_path -name FEEDTHRU -from [all_inputs]    -to [all_outputs]
group_path -name REG2REG -from [all_registers]  -to [all_registers]

#redirect ${dc_reports_flat}/${top}_cln05_timing_full__dc_pg.rpt {report_timing_alias_full}
#redirect ${dc_reports_flat}/${top}_cln05_timing_summary_pg.rpt {report_timing_alias_summary}
#redirect ${dc_reports_flat}/${top}_cln05_qor_dc_pg.rpt {report_qor}
#redirect ${dc_reports_flat}/${top}_cln05_short_summary_pg.rpt {report_timing_alias_short}

set_svf -off
set_vsdc -off


write -hierarchy -format ddc -output out/${DESIGN_NAME}.Syn.ddc
write -hierarchy -format verilog -output out/${DESIGN_NAME}.Syn.v
exec gzip -f out/${DESIGN_NAME}.Syn.v

if {[llength [info command shell_is_dcnxt_shell]] && [shell_is_dcnxt_shell]}  {
	report_transformed_register > reports/syn/report_transformed_register.rpt
}

##### 28052023 Roy: our reports
set timing_reports [list \
	"report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 > reports/syn/syn.rpt.detailed"
	]
foreach path_group [get_object_name [get_path_groups]] {
	lappend timing_reports "report_timing -derate -capacitance -transition_time -input_pins -nets -nosplit -max_paths 10000 -slack_lesser_than 0 -group $path_group > reports/syn/syn.rpt.$path_group.detailed"
}
parallel_execute $timing_reports

exec gawk -f ./scripts/bin/slacks.awk reports/syn/syn.rpt.detailed     | sort -n > reports/syn/syn.rpt
exec ./scripts/bin/timing_filter.pl reports/syn/syn.rpt.detailed

foreach path_group [get_object_name [get_path_groups]] {
	echo "exec gawk -f ./scripts/bin/slacks.awk reports/syn/syn.rpt.$path_group.detailed | sort -n > reports/syn/syn.rpt.$path_group"
	exec gawk -f ./scripts/bin/slacks.awk reports/syn/syn.rpt.$path_group.detailed | sort -n > reports/syn/syn.rpt.$path_group
        exec ./scripts/bin/timing_filter.pl reports/syn/syn.rpt.$path_group.detailed

}


parallel_execute [list \
	"report_qor > reports/syn/report_qor.syn.rpt" \
	"report_area -nosplit > reports/syn/report_area.syn.rpt" \
	"report_area -nosplit -hierarchy > reports/syn/report_area_hierarchy.syn.rpt" \
	"report_clock_gating -nosplit > reports/syn/report_clock_gating.syn.rpt" \
	"report_clock_gating -nosplit -ungated -verbose > reports/syn/report_clock_gating_verbose.syn.rpt" \
	"report_threshold_voltage_group -nosplit > reports/report_threshold_voltage_group.rpt" \
	"report_synlib dw_foundation.sldb > reports/synlib_dw_foundation.rpt" \
	"report_timing -loops > reports/timing_loops.rpt" \
]


redirect -file reports/syn/report_power.syn.rpt        { report_power -nosplit}
#redirect -file reports/syn/report_power_cell.syn.rpt	       { report_power -nosplit -verbose -cell}
redirect -file reports/syn/report_power_hierarchy.syn.rpt { report_power -nosplit -hierarchy -verbose}
redirect -file reports/syn/all_violators.rpt {report_constraints -all_violators -significant_digits 3 -verbose}

redirect -file reports/syn/check_design.rpt { check_design -nosplit }
redirect -file reports/syn/check_design.summary.rpt { check_design -summary }
redirect -file reports/syn/check_timing.rpt { check_timing }
redirect -file reports/syn/report_resource.rpt {report_resource -nosplit -hierarchy}

 
redirect -file reports/report_app_var.rpt {report_app_var}
redirect -file reports/report_app_var_only_changed_vars.rpt {report_app_var -only_changed_vars}

if {[info exists UPF_FILE] && [file exists $UPF_FILE]} {
	redirect -file reports/check_mv_design.rpt {check_mv_design}
	redirect -file reports/check_mv_design_verbose.rpt {check_mv_design -verbose}
	  # Report all power domains in the design
  	redirect -file reports/report_power_domain_hierarchy.rpt {report_power_domain -hierarchy}
  
  	# Report the top level supply nets
  	redirect -file reports/report_supply_net.rpt {report_supply_net}
  
  	# Report the level shifters in the design
  	if {[sizeof_collection [get_power_domains * -hierarchical -quiet]] > 0} {
    		redirect -file reports/report_level_shifter.rpt {report_level_shifter -domain [get_power_domains * -hierarchical]}
  	} else {
    		redirect -file reports/report_level_shifter.rpt {report_level_shifter}
  	}
}

if {$DCTOPO} {
 #   redirect $dc_reports_hier/${top}_cln05_congestion.rpt {report_congestion}
}

#------------------------------------------------------------------------------
# End of script
#------------------------------------------------------------------------------
puts "-I- memory usage for read_design: [mem] KB"
script_runtime_proc -end


exec touch .syn_done

if {[info exists INTERACTIVE] && $INTERACTIVE == "true" } {
	return
}

exit

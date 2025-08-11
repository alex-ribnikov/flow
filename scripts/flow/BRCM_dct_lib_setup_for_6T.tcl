###STD CELL LIB for 6T




## Library configuration flow: calls library manager under the hood to generate .nlibs, store, and link them
#  - To enable it, in design_setup.tcl, set LIBRARY_CONFIGURATION_FLOW to true,
#    specify LINK_LIBRARY with .db files, and specify REFERENCE_LIBRARY with physical source files. 
#    In fc_setup.tcl, make sure search_path includes all relevant locations. 
foreach rc_ [array name rc_corner] {
	if {[regexp $rc_ [regsub "_setup" [regsub "func_" [lindex $scenarios(setup) 0] ""] ""]]} { 
		regsub  _${rc_} [regsub "_setup" [regsub "func_" [lindex $scenarios(setup) 0] ""] ""] "" pvt
		set rc $rc_
	}
}


set new_list {}
foreach file $pvt_corner($pvt,timing) {
	#regsub {prod(\S+BSI)} $file {int\1} file            
    
    	if       { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue
    	} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue    
    	} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue
    	} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        	lappend new_list $new_file
        	continue
    	} else {
		regsub {/prod/} $file {/int/} file            
    		if       { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue
    		} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue    
    		} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue
    		} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        		lappend new_list $new_file
        		continue
    		} else {
        		puts "-E- File $file have no .db version in folder"
		}
    	}
}

regsub "\.db" [lindex [split [lindex $new_list 0] /] end] "" library

regsub {tsmc5ff_\S\S06t0750v_}  $library "tsmc5ff_sc06t0750v_" library_sc
regsub {tsmc5ff_\S\S06t0750v_}  $library "tsmc5ff_ck06t0750v_" library_ck
if {$PROJECT == "brcm3" || $PROJECT == "nxt013"} {
	
	regsub {tsmc3ffe_\S\S05t0750v_} $library "tsmc3ffe_sc05t0750v_" library_sc
	regsub {tsmc3ffe_\S\S05t0750v_} $library "tsmc3ffe_ck05t0750v_" library_ck
}

if {[llength [info command shell_is_dcnxt_shell]] && [shell_is_dcnxt_shell]}  {
	puts "-I- creat_snps_lib shell_is_dcnxt_shell"
	set new_list {}
	foreach pvt_index [lsearch -all [array name pvt_corner] *timing] {
   		foreach file $pvt_corner([lindex [array name pvt_corner] $pvt_index]) {
		#regsub {prod(\S+BSI)} $file {int\1} file            
    
    			if { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        			lappend new_list $new_file
        			continue
    			} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        			lappend new_list $new_file
        			continue    
    			} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        			lappend new_list $new_file
        			continue
    			} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        			lappend new_list $new_file
        			continue
    			} else {
				regsub {/prod/} $file {/int/} file            
    				if       { [regsub "\.lib\.gz\$" $file "\.db"     new_file] && [file exists $new_file] } {
        				lappend new_list $new_file
        				continue
    				} elseif { [regsub "\.lib\.gz\$" $file "_lib\.db" new_file] && [file exists $new_file] } {
        				lappend new_list $new_file
        				continue    
    				} elseif { [regsub "\.lib\$"     $file "\.db"     new_file] && [file exists $new_file] } {
        				lappend new_list $new_file
        				continue
    				} elseif { [regsub "\.lib\$"     $file "_lib\.db" new_file] && [file exists $new_file] } {
        				lappend new_list $new_file
        				continue
    				} else {
        				puts "-E- File $file have no .db version in folder"
				}
    			}
   		}
        
	}

#	set TARGET_LIBRARY_FILES [regsub "{}" $new_list ""]
	#set TARGET_LIBRARY_FILES $new_list
#	set ADDITIONAL_LINK_LIB_FILES ""

#	set_app_var target_library ${TARGET_LIBRARY_FILES}
#	set_app_var link_library "* $target_library $ADDITIONAL_LINK_LIB_FILES $synthetic_library"

}


#set standard_cell_5nmlib_dir_6t "/lab/libraries/avago/digital/cln05ff"
#set standard_cell_5nmlib_dir_6t "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/STD/BRCM/20230310/"

################################################################################################
## Technology variables
################################################################################################
#set TECHNOLOGY_SUPPORT_DIR "/lab/projects/da/act-1.0/cln05"
################################################################################################
## PVT variables
################################################################################################


######################################################################################################
# Milkyway Libraries for DC-Topo run, Not needed for WLM synthesis
#####################################################################################################

# set MWLIB_LIST [ list \
# 	${standard_cell_5nmlib_dir_6t}/tsmc5ff_sc06t0750v/milkyway/tsmc5ff_sc06t0750v.mdb \
# 	${standard_cell_5nmlib_dir_6t}/tsmc5ff_ck06t0750v/milkyway/tsmc5ff_ck06t0750v.mdb \
# ]

set ndm_ref_libs $NDM_REFERENCE_LIBRARY


##################################################################################################
# search_path : Specifies directories that the tool searches
##################################################################################################
##nramani , edit as applicable to nxt008, add top cells if top is being synthesized
set search_path [ list . \
  ${synopsys_path}/libraries/syn \
]



###############################################################################################
# link_library : Specifies the list of design files and libraries used during linking.
#
# list IP, memories, IO, "hard stuff" in this section
################################################################################################
##nramani - should i add any other corner like the ones in compile file??
set link_lib_std "$new_list"

set link_lib_mem ""
#nramani-keep updating as needed, updated on 10/09/2020
set link_lib_mem [list ]


set ip_list ""
set ip_list [list \
]



set blk_db ""

set chip_top [lindex [split [pwd] /] 9]
#
#if {$chip_top == "hbm3_chiplet"} {
#set blk_db [list \
# /project/apd_nxt009/designers/nramani/synthesis/PN99.12.pcore.ecore.center.hif/DC_runs/01032023/hbm3_chiplet/mc4_db/hbm3_mc4_syn_wrap_lib.db \
# ]
# }
#
#if {$chip_top == "ddr5_syn_wrap"} {
#set blk_db [list \
# /project/apd_nxt009/designers/nramani/synthesis/PN99.12.pcore.ecore.center.hif/DC_runs/01032023/ddr5_syn_wrap/mc_db/cadence_mc_controller_with_sram_wrap_lib.db \
# /project/apd_nxt009/designers/nramani/synthesis/PN99.12.pcore.ecore.center.hif/DC_runs/01032023/ddr5_syn_wrap/mc_1_db/cadence_mc_1_controller_with_sram_wrap_lib.db \
# /project/apd_nxt009/designers/arrao/synthesis/PN99.4/ddr5_syn_wrap/cadence_phy_cdn_hs_phy_top.portsOnly.db
# ]
# }
#
#if {$chip_top == "ecore_quad_complex_top"} {
#set blk_db [list \
#/project/apd_nxt009/designers/nramani/synthesis/PN99.10.ecore_quad.center.hif/DC_runs/270102023/ecore_quad_complex_top/hif_db/ecore_hif_wrap_top_lib.db \
#    ]
#}
#
#
#if {$chip_top == "pcore_axi_syn_top"} {
#set blk_db [list \
# /project/apd_nxt009/designers/nramani/synthesis/PN99.12.pcore.ecore.center.hif/DC_runs/01032023/pcore_axi_syn_top/cpu_db/pcore_l3_cluster_cpu_top_lib.db \
# /project/apd_nxt009/designers/nramani/synthesis/PN99.12.pcore.ecore.center.hif/DC_runs/01032023/pcore_axi_syn_top/l3_db/pcore_l3_cluster_bank_noc_wrapper_lib.db \
# /project/apd_nxt009/designers/nramani/synthesis/PN99.12.pcore.ecore.center.hif/DC_runs/01032023/pcore_axi_syn_top/bmt_db/pcore_bmt_syn_top_lib.db \
# /project/apd_nxt009/designers/nramani/synthesis/PN99.12.pcore.ecore.center.hif/DC_runs/01032023/pcore_axi_syn_top/config_db/pcore_config_wrapper_lib.db \
# /project/apd_nxt009/designers/nramani/synthesis/PN99.12.pcore.ecore.center.hif/DC_runs/01032023/pcore_axi_syn_top/east_noc_db/pcore_noc_east_wrapper_lib.db \
# /project/apd_nxt009/designers/nramani/synthesis/PN99.12.pcore.ecore.center.hif/DC_runs/01032023/pcore_axi_syn_top/west_noc_db/pcore_noc_west_wrapper_lib.db \
# ]
# }

###############################################################################################
# target_library : Specifies the list of Target libraries to be used for optimization
### SVT/LVT/UVT Libraries
###############################################################################################

 ## High performance
##nramani, confirm once if these are okay for opt, add top when top is being synth
set target_library_std "tsmc5ff_sc06t0750v_pssg_s300_v0670_t000_xcwccwt.db tsmc5ff_ck06t0750v_pssg_s300_v0670_t000_xcwccwt.db"
set symbol_library "generic.sdb"
set synthetic_library "standard.sldb dw_foundation.sldb"

#set link_library "* $link_lib_std $synthetic_library $link_lib_mem"
#set link_library "* $link_lib_std $link_lib_mem $ip_list $blk_db  $synthetic_library"
set link_library "* $link_lib_std  $synthetic_library"
set target_library "$link_lib_std"

##for memories,check if we can generate mwlib

set mem_list {}


### Add memories physical views
foreach mem  $mem_list {
# lappend  ndm_ref_libs "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/IP/MEM/BRCM/memories/20230310/memory/prod/lay/${mem}.ndm"
  }
 
 foreach mlib $ndm_ref_libs {
#   lappend  mw_reference_library "$mlib"
 }

#echo $mw_reference_library
###################################################################################
# Technology File, Tluplus file settings
###################################################################################
##nramani, review the below files, TECH FILE R_.tf doesnt seem to exist. Is that okay? Using R_enterprise as of now,guidelines also say R.tf
#set TECH_FILE "/lab/projects/da/M+0/act/cln05/iccii/share/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.tf"
#set TLUPLUS_MAX_FILE $TECHNOLOGY_SUPPORT_DIR/milkyway/share/15M_1x1xa1ya5y2yy2yx2r_R07518FF_rcworst_CCworst.tlup
#set TLUPLUS_MIN_FILE $TECHNOLOGY_SUPPORT_DIR/milkyway/share/15M_1x1xa1ya5y2yy2yx2r_R07518FF_cbest_CCbest.tlup
#set MAP_FILE  "$TECHNOLOGY_SUPPORT_DIR/milkyway/share/16M_1x1xb1xe1ya1yb4y2yy4z_R07512FF_lefdef_rcxt_map"

#set TECH_FILE "/projects/bcm/tech/tsmc5ff_M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_1UTRDL/milkyway/generic/pnr/prod/tsmc5ff_M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_1UTRDL.tf.6"
#set TECH_FILE "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_10March2023/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R_enterprise.tf"

#set TLUPLUS_MAX_FILE /projects/bcm/tech/tsmc5ff_M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_1UTRDL/star/generic/extraction/prod/corner/tsmc5ff_M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_1UTRDL_worst_C_CCworst.nxtgrd
#set TLUPLUS_MAX_FILE  /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_10March2023/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cworst_CCworst.nxtgrd
set TLUPLUS_MAX_FILE  $rc_corner(c_wc_cc_wc,nxtgrd)

#set TLUPLUS_MIN_FILE /projects/bcm/tech/tsmc5ff_M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_1UTRDL/star/generic/extraction/prod/corner/tsmc5ff_M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_1UTRDL_best_C_CCbest_T.nxtgrd
#set TLUPLUS_MIN_FILE /project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_10March2023/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_cbest_CCbest.nxtgrd
set TLUPLUS_MIN_FILE $rc_corner(c_bc_cc_bc,nxtgrd)

#set MAP_FILE  "/projects/bcm/tech/tsmc5ff_M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_1UTRDL/star/generic/extraction/prod/tsmc5ff_M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_1UTRDLt_xt.map"
set MAP_FILE  "/project/foundry/TSMC/N5/M1_1Mx_1Mxb_1Mxe_1Mya_1Myb_5My_2Myy_2Myx_2Mr_UT_ALRDL/PDK_Broadcom/nxt009_designkit_10March2023/TECH_5FF/synopsys/17M_1x1xb1xe1ya1yb5y2yy2yx2r_R07512FF_lefdef_rcxt_map"

set max_tlu $TLUPLUS_MAX_FILE
set min_tlu $TLUPLUS_MIN_FILE
set map_file $MAP_FILE
set mw_tech_file $TECH_FILE

set mw_logic1_net VDD
set mw_logic0_net VSS

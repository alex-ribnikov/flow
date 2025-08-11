if { [info exists FM_MODE] } {

    ## Define mapping between clock port and its respective multiport clock
    #add_renaming_rule leq_clk_port %w__LEQ%d @1 -type PI -revised

    ## // rvsd(lec) = impl(fm) ; 

    ## set equivalent clock ports for multi-port clocking. Below section is applied only for block with multi point CTS
    set LISToports_rvsd ""
    set LEQPorts_rvsd [find_port i:/WORK/${DESIGN_NAME}/*__LEQ*]
    foreach port $LEQPorts_rvsd {
      regsub __LEQ.* $port "" oport
      if {[lsearch -exact $LISToports_rvsd $oport] == -1} {
        lappend LISToports_rvsd $oport
      }
    }   
    foreach port $LISToports_rvsd {
      set tmpLEQPorts ""
      foreach LeqPort $LEQPorts_rvsd {
        if {[string match ${port}__LEQ* $LeqPort]} {
          set_user_match -type port [regsub i: $port r:] $LeqPort
        }
      }
    }

    ## set equivalent cloned clock gates
###    set all_imp_cg_clones [regexp -all -inline {[^ ]+_clone_?[0-9]*[ $]} [find_cells i:/WORK/${DESIGN_NAME}/*_clone*]]
###    foreach cg $all_imp_cg_clones {
###        set ref_cg [regsub i: [regsub {(_clone_?[0-9]*)+[ ]*$} $cg {}] r:]
###        if { [find_cells $ref_cg] != "" } {
###            set_user_match -type cell [find_cells $ref_cg] [find_cells $cg]
###        }
###    }

   ## Set input test ports to 0. Some ports will set to 1 later in the loop
      set p_list [find_ports i:/WORK/${DESIGN_NAME}/TEST* -in]
      foreach l $p_list {
         set_constant $l 0 -type port
      }
   
      set_constant [find_ports i:/WORK/${DESIGN_NAME}/TEST__TDR_RST -in] 1 -type port
      set_constant [find_ports i:/WORK/${DESIGN_NAME}/TEST__MEM_OVSTB -in] 1 -type port
      set_constant [find_ports i:/WORK/${DESIGN_NAME}/TEST__ISO_ENABLE_OVERRIDE -in] 1 -type port
      set_constant [find_ports i:/WORK/${DESIGN_NAME}/TEST__CLK_ENABLE_OVERRIDE -in] 1 -type port
   
      set p_list [find_ports i:/WORK/${DESIGN_NAME}/TEST*SPARE*_H* -in]
      foreach l $p_list {
         set_constant $l 1 -type port
      }
      set p_list [find_ports i:/WORK/${DESIGN_NAME}/TEST*SPARE*_L* -in]
      foreach l $p_list {
         set_constant $l 0 -type port
      }


      foreach ltest_en [find_cells *:/WORK/${DESIGN_NAME}/*_gate0_tessent_tdr_sri_ctrl_inst__*ltest_en_latch_reg] {
        set_constant $ltest_en 0 -type cell
      }
    # Memory DFT
      set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/*/*PBIST* -in]
      set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/*/*TMG_MODE* -in]
      set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/*/*REDN* -in]
      set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/*/TEST__* -in]
      set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/*/siw[*] -in]
      set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/*/si[*] -in]
      set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/*/sir -in]    
      ## Test output ports
      set_dont_verify_point [find_ports i:/WORK/${DESIGN_NAME}/TEST__* -out]          

  #deal with problems associated with scan chain reorder
      set latchInstNameList [ list \
        *Q_MUXD_LOCKUP \
        LOCKUP* \
        ts_*_lockuplatch* \
        ts_*_lockup_latchn_* \
      ]
      foreach latchInstName $latchInstNameList {
          set latchInstPins [find_pins i:/WORK/${DESIGN_NAME}/${latchInstName}/d -in]
          if { $latchInstPins != "" } {
              set_dont_verify_point $latchInstPins
          }
      }                     

## Remove constant on any TEST* ports which already exist in pre-test netlist
    if { $FM_MODE == "syn2dft" } {
        set p_list [find_ports r:/WORK/${DESIGN_NAME}/TEST* -in]
        foreach l $p_list {
           set m [regsub r: $l i:]
           remove_constant $m
        }
    } else {
      ### if ref design is not SYN - need to extract original TEST names from syn2dft run
    }

} elseif {[info exists LEC_MODE]} {

    if {$LEC_MODE == "scantest"} {
      # <HN> switching the control constraints from syn2dft stage
        add_pin_constraints 1 TEST__SE  -module ${DESIGN_NAME}  -both
        add_pin_constraints 1 TEST__TDR_SHIFT  -module ${DESIGN_NAME}  -both
        add_pin_constraints 1 TEST__CLK_GATE_DISABLE_CKGT  -module ${DESIGN_NAME}  -both
        add_pin_constraints 1 TEST__CLK_GATE_DISABLE  -module ${DESIGN_NAME}  -both
        add_pin_constraints 0 TEST__TDR_RST  -module ${DESIGN_NAME}  -both
        add_pin_constraints 0 TEST__MEM_OVSTB  -module ${DESIGN_NAME}  -both
        add_pin_constraints 0 TEST__ISO_ENABLE_OVERRIDE  -module ${DESIGN_NAME}  -both      

        set TEST_PORTS [find -Port -Input TEST*SPARE*_H* -Revised]
        foreach lll $TEST_PORTS {
            add_pin_constraints 1 $lll -Revised
        }
        set TEST_PORTS [find -Port -Input TEST*SPARE*_L* -Revised]
        foreach lll $TEST_PORTS {
            add_pin_constraints 0 $lll -Revised
        }        
    
    } else {
        add_renaming_rule leq_clk_port %w__LEQ%d @1 -type PI -revised

        ## set equivalent clock ports for multi-port clocking. Below section is applied only for block with multi point CTS
        set LISToports_rvsd ""
        set LEQPorts_rvsd [find -port *__LEQ* -revised]
        foreach port $LEQPorts_rvsd {
          regsub __LEQ.* $port "" oport
          if {[lsearch -exact $LISToports_rvsd $oport] == -1} {
            lappend LISToports_rvsd $oport
          }
        }   
        foreach port $LISToports_rvsd {
          set tmpLEQPorts ""
          foreach LeqPort $LEQPorts_rvsd {
            if {[string match ${port}__LEQ* $LeqPort]} {
              lappend tmpLEQPorts $LeqPort
            }
          }
          add_pin_equivalences $tmpLEQPorts -revised
          add_renaming_rule ${port}_rename1 ${port}__LEQ%d $port -map -type PO PI -both
        }
    }

    if { $LEC_MODE == "syn2dft" || $LEC_MODE == "net2net" } {
  ## //   Adding lec constraints from BRCM <HN>23ww32c   //
  #     - ~ - ~ - ~ - ~ - ~ - ~ -- - ~ - ~ - ~ - ~ - ~ -  

        set TEST_PORTS [find -Port -Input TEST__* -Revised]
        foreach lll $TEST_PORTS {
            if {$lll eq "TEST__TDR_RST" || $lll == "TEST__MEM_OVSTB" || $lll == "TEST__ISO_ENABLE_OVERRIDE" || $lll == "TEST__CLK_ENABLE_OVERRIDE" } {
  	        puts "-I- Setting pin constraint 1 on $lll"
            add_pin_constraints 1 $lll -Revised
            add_pin_constraints 1 $lll -gold
         } else {
	        puts "-I- Setting pin constraint 0 on $lll"
            add_pin_constraints 0 $lll -Revised
            add_pin_constraints 0 $lll -gold
         }
        }

        set TEST_PORTS [find -Port -Input TEST*SPARE*_H* -Revised]
        foreach lll $TEST_PORTS {
            delete_pin_constraints $lll -Revised
            add_pin_constraints 1 $lll -Revised
        }
        set TEST_PORTS [find -Port -Input TEST*SPARE*_L* -Revised]
        foreach lll $TEST_PORTS {
  #          add_pin_constraints 0 $lll -Revised
        }

  ## Remove constant on any TEST* ports which already exist in pre-test netlist
        set p_list [find -Port -Input TEST* -Golden]
        foreach l $p_list {
           delete_pin_constraints $l -Revised
        }
          
    # inner module (bbox/memories) dft
      foreach _mode "golden revised" {
          set mem_p [find_cfm -hier -pin */TEST__* -filter direction==in -${_mode}]
          if { $mem_p != "" } {
              set module_list [lsort -unique [regsub -all {[^ ]*/} [find_cfm -libcell -of_obj [find_cfm -instance -of_obj $mem_p]] {}] ]
              if { $module_list == "" } {
                  set module_list [lsort -unique [regsub -all {[^ ]*/} [find_cfm -design -of_obj [find_cfm -instance -of_obj $mem_p]] {}] ]
              }
              foreach _mdl $module_list {
                if { $DESIGN_NAME != "nxt009_top" } {
                  set module_pins [regsub -all {[\{\}]} [find_cfm -libpin */$_mdl/TEST__* -filter direction==in] {}]
                  foreach _mod_p [lsort -unique [regsub -all {[^ ]*/} $module_pins {}]] {
                      add_primary_input  -module $_mdl -pin $_mod_p -${_mode}
                  }
                }
                  add_ignored_inputs -module $_mdl TEST__* -${_mode}
              }
          }
      }

      set mem_p_list "
      *PBIST*
      *TMG_MODE*
      *REDN*
      siw\[*\]
      si\[*\]
      sir
      *dft_clk_gate_en*
      *dft_rst_n_override*
      "
      foreach _mode "golden revised" {
        foreach _p $mem_p_list {    
          set mem_p [find_cfm -hier -pin */${_p} -${_mode} -filter direction==in&&name!~TEST__*]
          if { $mem_p != "" } {
              set module_list [lsort -unique [regsub -all {[^ ]*/} [find_cfm -libcell -of_obj [find_cfm -instance -of_obj $mem_p]] {}] ]
              if { $module_list == "" } {
                  set module_list [lsort -unique [regsub -all {[^ ]*/} [find_cfm -design -of_obj [find_cfm -instance -of_obj $mem_p]] {}] ]
              }
              foreach _mdl $module_list {
                if { $DESIGN_NAME != "nxt009_top" } {
                  set module_pins [regsub -all {[\{\}]} [find_cfm -libpin */$_mdl/${_p} -filter direction==in&&name!~TEST__*] {}]
                  foreach _mod_p [lsort -unique [regsub -all {[^ ]*/} $module_pins {}]] {
                      add_primary_input  -module $_mdl -pin $_mod_p -${_mode}
                  }
                }  
                  add_ignored_inputs -module $_mdl ${_p} -${_mode}
              }
          }
        }
        set mem_p [find -hier -port -output TEST__* -${_mode}] 
        if { $mem_p != ""} {
          add_ignored_outputs $mem_p -${_mode}
        }
      }        

      ## ignore test power gating flops
        set myloop 0
        while { [ find -hier -instance "TEST__CKGT_$myloop" -gold ] != "" } {
          add_instance_constraints 1 TEST__CKGT_$myloop -replace -gold
          if { [ find -hier -instance "TEST__CKGT_$myloop" -revised ] != "" } {
          add_instance_constraints 1 TEST__CKGT_$myloop -replace -revised
          }
          incr myloop
        }
      ## Constrain test logic to be inactive
        foreach _mode "revised golden" {
            foreach ltest_en [find -hier -instance *_gate0_tessent_tdr_sri_ctrl_inst__*ltest_en_latch_reg -${_mode}] {
                add_instance_constraints 0 $ltest_en -${_mode}
            }
        }
###      ## For memories
###      set m_list  [find -Module M5RM* M5S* M5P* GCU_M5* BCM5FFXD* BCM5FFXHCSL* ds05_sbus2vtmon_01* LIB_PM_GEN6* LIB_VTMON_* -Revised]
###
###      foreach inst $m_list {
###        # some pins are bi-directional for some reason.. setting as inputs to cover those cases as well 
###         foreach _p "si*    *PBIST*    *TMG_MODE*    *REDN*    *TEST__*" {
###            assign_pin_direction in $inst $_p -both
###            add_ignored_inputs $_p -module $inst -both
###         }
###      }
    # // END OF "syn2dft" or "net2net" //
    } elseif { $LEC_MODE == "dft2place" || $LEC_MODE == "place2route" } {
      # TEST ports
        add_pin_constraints 0 TEST__SE  -module ${DESIGN_NAME}  -both
        add_pin_constraints 0 TEST__TDR_SHIFT  -module ${DESIGN_NAME}  -both
        add_pin_constraints 0 TEST__CLK_GATE_DISABLE_CKGT  -module ${DESIGN_NAME}  -both
        add_pin_constraints 0 TEST__CLK_GATE_DISABLE  -module ${DESIGN_NAME}  -both
        add_pin_constraints 1 TEST__TDR_RST  -module ${DESIGN_NAME}  -both
        add_pin_constraints 1 TEST__MEM_OVSTB  -module ${DESIGN_NAME}  -both
        add_pin_constraints 1 TEST__ISO_ENABLE_OVERRIDE  -module ${DESIGN_NAME}  -both        

      # <HN> after error due to change in post_layout - BRCM requested to add these constraints in post_layout as well
        set TEST_PORTS [find -Port -Input TEST*SPARE*_H* -Revised]
        foreach lll $TEST_PORTS {
            delete_pin_constraints $lll -both
            add_pin_constraints 1 $lll -both
        }
        set TEST_PORTS [find -Port -Input TEST*SPARE*_L* -Revised]
        foreach lll $TEST_PORTS {
            delete_pin_constraints $lll -both            
            add_pin_constraints 0 $lll -both
        }

      # bbox TEST pins   
        set m_list  [find -Module M5RM* M5S* M5P* GCU_M5* BCM5FFXD* BCM5FFXHCSL* ds05_sbus2vtmon_01* LIB_PM_GEN6* LIB_VTMON_* -Revised]      
        set mem_p_list "
        siw\[*\]
        si\[*\]
        sir
        "
        foreach inst $m_list {
           foreach _p $mem_p_list {
              assign_pin_direction in $inst $_p -both
              add_ignored_inputs $_p -module $inst -both
           }
        }

      #deal with problems associated with scan chain reorder - ignore lockup latches data pins
        set latchInstNameList "
          *Q_MUXD_LOCKUP
          LOCKUP*
          ts_*_lockuplatch*
          ts_*_lockup_latchn_*
        "
        foreach latchInstName $latchInstNameList {
            foreach _mode "golden revised" {
                if { [find -instance $latchInstName -HIERarchical -${_mode}] != "" } {
                  #add_ignored_inputs d -Instance $latchInstName -${_mode}  ;# This very reasonable command doesn't seem to catch..
                  add_primary_input $latchInstName/d -pin -cut -${_mode}
                  add_pin_constraints 0 $latchInstName/d -${_mode}
                }
            }
        }

      # Constrain test logic to be inactive
        foreach _mode "revised golden" {
            foreach ltest_en [find -hier -instance *_gate0_tessent_tdr_sri_ctrl_inst__*ltest_en_latch_reg -${_mode}] {
                add_instance_constraints 0 $ltest_en -${_mode}
            }
        }
    # // END OF "dft2place" or "place2route"     
    }
}

#######################################################################################################################################
##
##	ecore_quad_complex_top
##
#######################################################################################################################################
if {$DESIGN_NAME == "ecore_quad_complex_top"} {
    if {[info exists FM_MODE] && $FM_MODE == "syn2dft"} {
        set_constant r:/WORK/${DESIGN_NAME}/ecore_0_test_mode  0 -type port
        set_constant r:/WORK/${DESIGN_NAME}/ecore_0_dft_clk_gate_en 0 -type port
        set_constant r:/WORK/${DESIGN_NAME}/ecore_0_dft_rst_n_override 0 -type port
        set_constant r:/WORK/${DESIGN_NAME}/ecore_1_test_mode  0 -type port
        set_constant r:/WORK/${DESIGN_NAME}/ecore_1_dft_clk_gate_en 0 -type port
        set_constant r:/WORK/${DESIGN_NAME}/ecore_1_dft_rst_n_override 0 -type port
        
    } elseif {[info exists LEC_MODE] && $LEC_MODE == "syn2dft"} {
        set TEST_PORTS [find -Port -Input ecore_?_test_mode -Revised]
        foreach lll $TEST_PORTS {
           add_pin_constraints 0 $lll -Revised
        }
        set TEST_PORTS [find -Port -Input ecore_?_dft_clk_gate_en -Revised]
        foreach lll $TEST_PORTS {
           add_pin_constraints 0 $lll -Revised
        }
        set TEST_PORTS [find -Port -Input ecore_?_dft_rst_n_override -Revised]
        foreach lll $TEST_PORTS {
           add_pin_constraints 0 $lll -Revised
        }

        if {$LEC_MODE == "syn2dft"} {
           set m_list  [find -Module ecore_hif* -Revised]
           foreach inst $m_list {
              add_ignored_inputs TEST_* -module $inst -both
              add_ignored_inputs test_mode -module $inst -both
              add_ignored_inputs dft_clk_gate_en -module $inst -both
              add_ignored_inputs dft_rst_n_override -module $inst -both
           }
           set m_list  [find -Module M5* -Revised]
           foreach inst $m_list {
              assign_pin_direction in $inst BIST_DONE_*_OUT -revised
              add_ignored_inputs BIST_DONE_*_OUT -module $inst -revised
           }           
        }
    }

#######################################################################################################################################
##
##	scu_top_syn_wrap
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "scu_top_syn_wrap"} {
    if {[info exists FM_MODE] && $FM_MODE == "dft2place"} {

    } elseif {[info exists LEC_MODE] && $LEC_MODE == "dft2place"} {

        set _test_libs [lsort -unique [regsub -all {[^ ]*/} [find_cfm -libcell -of_obj [find_cfm -libpin */*/TEST__SIN*]] {}] ]
        foreach _mdl $_test_libs {
            add_ignored_inputs -module $_mdl TEST__SIN* -both
        }
    }
 
#######################################################################################################################################
##
##	ecore_hif_wrap_top
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "ecore_hif_wrap_top"} {
    if {[info exists FM_MODE] && $FM_MODE == "dft2place"} {

    } elseif {[info exists LEC_MODE] && $LEC_MODE == "dft2place"} {

        set _test_libs [lsort -unique [regsub -all {[^ ]*/} [find_cfm -libcell -of_obj [find_cfm -libpin */*/TEST__SIN*]] {}] ]
        foreach _mdl $_test_libs {
            add_ignored_inputs -module $_mdl TEST__SIN* -both
        }
    }

#######################################################################################################################################
##
##	pcore_axi_syn_top
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "pcore_axi_syn_top"} {
    if {[info exists FM_MODE] && $FM_MODE == "syn2dft"} {
           set_constant i:/WORK/${DESIGN_NAME}/TEST__CUST_RST_n  1 -type port
           set_dont_verify_points [find_pins i:/WORK/${DESIGN_NAME}/i_pcore_bmt_syn_top/TEST* -in	]
           set_dont_verify_points [find_pins i:/WORK/${DESIGN_NAME}/i_pcore_top_wrap_i_pcore_l3_cluster_top_i_pcore_config/TEST* -in	]
           set_dont_verify_points [find_pins i:/WORK/${DESIGN_NAME}/i_pcore_top_wrap_i_pcore_l3_cluster_top_g_noc_com_l3_wrapper_?__i_noc_l3_wrapper/TEST* -in	]
           set_dont_verify_points [find_pins i:/WORK/${DESIGN_NAME}/i_pcore_top_wrap_i_pcore_l3_cluster_top_g_cpu_wrapper_?__i_cpu_wrapper_i_l2_cluster_cpu_top/TEST* -in	]
           set_dont_verify_points [find_pins i:/WORK/${DESIGN_NAME}/i_pcore_top_wrap_i_pcore_l3_cluster_top_i_pcore_noc_east/TEST* -in	]
           set_dont_verify_points [find_pins i:/WORK/${DESIGN_NAME}/i_pcore_top_wrap_i_pcore_l3_cluster_top_i_pcore_noc_west/TEST* -in	]
    } elseif {[info exists LEC_MODE] && $LEC_MODE == "syn2dft"} {
           set ttt [find -Port -Input TEST__CUST_RST_n -Revised] 
           delete_pin_constraints $ttt -Revised
           add_pin_constraints 1 $ttt -Revised
           set m_list  [find -Module pcore_bmt_syn_top -Revised]
           foreach inst $m_list {
              add_ignored_inputs TEST_* -module $inst -both
           }
           set m_list  [find -Module pcore_config_wrapper -Revised]
           foreach inst $m_list {
              add_ignored_inputs TEST_* -module $inst -both
           }
           set m_list  [find -Module pcore_l3_cluster_bank_noc_wrapper -Revised]
           foreach inst $m_list {
              add_ignored_inputs TEST_* -module $inst -both
           }
           set m_list  [find -Module pcore_l3_cluster_cpu_top -Revised]
           foreach inst $m_list {
              add_ignored_inputs TEST_* -module $inst -both
           }
           set m_list  [find -Module pcore_noc_east_wrapper -Revised]
           foreach inst $m_list {
              add_ignored_inputs TEST_* -module $inst -both
           }
           set m_list  [find -Module pcore_noc_west_wrapper -Revised]
           foreach inst $m_list {
              add_ignored_inputs TEST_* -module $inst -both
           }
    }
   
#######################################################################################################################################
##
##	hbm3_chiplet
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "hbm3_chiplet"} {

    set mod "hbm3_mc4_syn_wrap"

    if {[info exists FM_MODE]} {
        
    } elseif {[info exists LEC_MODE] && (($LEC_MODE == "syn2dft")||($LEC_MODE == "dft2place")) } {
        add_ignored_inputs TEST__* -module $mod -both
    }


#######################################################################################################################################
##
##	middle_io_wrap
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "middle_io_wrap"} {
    if {[info exists FM_MODE] && $FM_MODE == "rtl2syn"} {
	   set_dont_verify_points {r:/WORK/middle_io_wrap/i_ds05_vtmon_w_reg_sbus_wrapper_01/thermal_sensor/TEST__SHIFT_CLK\*unread\*/IN} 
	   set_dont_verify_points {r:/WORK/middle_io_wrap/i_ds05_vtmon_w_reg_sbus_wrapper_01/thermal_sensor/inst_analog.pwrBB/pad_ADC} 
       set_dont_verify_points {r:/WORK/middle_io_wrap/i_ds05_vtmon_w_reg_sbus_wrapper_01/thermal_sensor/inst_analog.pwrBB/sensor_therm_out} 
	   set_dont_verify_points {r:/WORK/middle_io_wrap/i_ds05_vtmon_w_reg_sbus_wrapper_01/thermal_sensor/inst_analog.pwrBB/pad_DAC} 


	   set_dont_verify_points {r:/WORK/middle_io_wrap/i_ds05_vtmon_w_reg_sbus_wrapper_01/thermal_sensor/inst_analog.pwrBB/pad_ADC}
	   set_dont_verify_points {r:/WORK/middle_io_wrap/i_ds05_vtmon_w_reg_sbus_wrapper_01/thermal_sensor/inst_analog.pwrBB/sensor_therm_out}
	   set_dont_verify_points {r:/WORK/middle_io_wrap/i_ds05_vtmon_w_reg_sbus_wrapper_01/thermal_sensor/inst_analog.pwrBB/pad_DAC}
	   
    } elseif {[info exists LEC_MODE] && $LEC_MODE == "rtl2syn"} {
    }
#######################################################################################################################################
##
##	pcore_l3_cluster_cpu_top
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "pcore_l3_cluster_cpu_top"} {
    if {[info exists FM_MODE] && $FM_MODE == "syn2dft"} {
       set_constant [find_ports i:/WORK/${DESIGN_NAME}/test_se -in] 0 -type port  
    } elseif {[info exists LEC_MODE] && $LEC_MODE == "syn2dft"} {
        add_pin_constraints 0 ${DESIGN_NAME}/test_se -Revised
    }

#######################################################################################################################################
##
##	ddr5_syn_wrap
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "ddr5_syn_wrap"} {
    if {[info exists FM_MODE] && $FM_MODE == "syn2dft"} {
          set_dont_verify_points [find_pins i:/WORK/${DESIGN_NAME}/i_cadence_phy_ddr_subsystem_cadence_mc_controller_mci_wrapper_cadence_mc_1_controller_ch1/TEST* -in	]
          set_dont_verify_points [find_pins i:/WORK/${DESIGN_NAME}/i_cadence_phy_ddr_subsystem_cadence_mc_controller_mci_wrapper_cadence_mc_controller_ch0/TEST* -in	]
       # constraints for ddr from BRCM <HN>23ww32d
          set_constant r:/WORK/${DESIGN_NAME}/dft_clk_gate_en  0 -type port
          set_constant r:/WORK/${DESIGN_NAME}/dft_rst_n_override  0 -type port
          set_constant i:/WORK/${DESIGN_NAME}/dft_rst_n_override  0 -type port
          set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/i_cadence_phy_ddr_subsystem_cdn_hs_phy_top/*_scan_in* -in]
          set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/i_cadence_phy_ddr_subsystem_cdn_hs_phy_top/iddq_en ]
          set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/i_cadence_phy_ddr_subsystem_cdn_hs_phy_top/opcg_pgmsi ]
          set_dont_verify_point [find_pins i:/WORK/${DESIGN_NAME}/i_cadence_phy_ddr_subsystem_cdn_hs_phy_top/jtag_dataout_* ]       

    } elseif {[info exists LEC_MODE] && $LEC_MODE == "syn2dft"} {
          set m_list  [find -Module cadence_mc_controller_with_sram_wrap -Revised]
          foreach inst $m_list {
             add_ignored_inputs TEST_* -module $inst -both
          }
          set m_list  [find -Module cadence_mc_1_controller_with_sram_wrap -Revised]
          foreach inst $m_list {
             add_ignored_inputs TEST_* -module $inst -both
          }

          add_pin_constraints 0 dft_clk_gate_en -golden
          add_pin_constraints 0 dft_rst_n_override -golden
          add_pin_constraints 0 dft_rst_n_override -Revised

          set mod "cadence_phy_cdn_hs_phy_top"

          set ignore_rvsd_pins_list "
              pll_testout_1   smbus_cmd     opcg_trig_sync_out   freq_change_req
          "
          foreach _pin $ignore_rvsd_pins_list {
              assign_pin_direction in $mod $_pin -revised
              add_ignored_inputs $_pin -module $mod -revised
          }
              
          set ignore_both_pins_list "
              *_scan_in*      *_scan_out*   iddq_en      opcg_pgmsi          jtag_data*     phy_jtag_tdr_sdo
          "
          foreach _pin $ignore_both_pins_list {
              assign_pin_direction in $mod $_pin -both
              add_ignored_inputs $_pin -module $mod  -both
          }
   }


#######################################################################################################################################
##
##	grid_quadrant
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "grid_quadrant"} {
    if {[info exists FM_MODE] && $FM_MODE == "syn2dft"} {
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_clusters_wrap/i_cluster_*/south_dft_clk_gate_en} 0
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_clusters_wrap/i_cluster_*/south_dft_rst_n_override} 0
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_quad_east_filler/i_grid_quad_east_filler*/south_dft_clk_gate_en} 0
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_quad_east_filler/i_grid_quad_east_filler*/south_dft_rst_n_override} 0
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_quad_west_filler/i_grid_quad_west_filler_*/south_dft_clk_gate_en} 0
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_quad_west_filler/i_grid_quad_west_filler_*/south_dft_rst_n_override} 0
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_tcu_col/i_grid_tcu_cluster_*/south_dft_clk_gate_en} 0
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_tcu_col/i_grid_tcu_cluster_*/south_dft_rst_n_override} 0
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_quad_south_filler/i_grid_quad_south_filler_*/east_dft_clk_gate_en} 0
       set_constant -type port {r:/WORK/grid_quadrant/i_grid_quad_south_filler/i_grid_quad_south_filler_*/east_dft_rst_n_override} 0

        set p_list [find_pins r:/WORK/${DESIGN_NAME}/*/*dft_clk_gate_en* -in]
	echo " number of dft_clk_gate_en element in reference: [llength $p_list]"
        foreach l $p_list {
           set_constant $l 0 -type pin
        }
	
        set p_list [find_pins r:/WORK/${DESIGN_NAME}/*/*dft_rst_n_override* -in]
	echo " number of dft_rst_n_override element in reference: [llength $p_list]"
        foreach l $p_list {
           set_constant $l 0 -type pin
        }
	
        set p_list [find_pins i:/WORK/${DESIGN_NAME}/*/*dft_clk_gate_en* -in]
	echo " number of dft_clk_gate_en element in impl: [llength $p_list]"
        foreach l $p_list {
           set_constant $l 0 -type pin
        }
	
        set p_list [find_pins i:/WORK/${DESIGN_NAME}/*/*dft_rst_n_override* -in]
	echo " number of dft_rst_n_override element in impl: [llength $p_list]"
        foreach l $p_list {
           set_constant $l 0 -type pin
        }
    } elseif {[info exists LEC_MODE] && $LEC_MODE == "syn2dft"} {
    
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_cluster -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_cluster -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_ecore_cluster -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_ecore_cluster -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_quad_east_filler_row_0_top -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_quad_east_filler_row_0_top -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_quad_east_filler_row_notch_top -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_quad_east_filler_row_notch_top -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_quad_east_filler_row_top -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_quad_east_filler_row_top -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_north_filler_col_top -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_north_filler_col_top -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_south_filler_col_0_top -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_south_filler_col_0_top -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_south_filler_col_top -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_south_filler_col_top -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_south_filler_east_col_top -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_south_filler_east_col_top -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_west_filler_row_top -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_west_filler_row_top -both
	    add_pin_constraints 0 *dft_clk_gate_en    -Module grid_tcu_cluster -both
	    add_pin_constraints 0 *dft_rst_n_override -Module grid_tcu_cluster -both
        
    }


#######################################################################################################################################
##
##	d2d_east_ctrl
##
#######################################################################################################################################
} elseif {$DESIGN_NAME == "d2d_east_ctrl"} {
    if {[info exists FM_MODE] && $FM_MODE == "syn2dft"} {
        set_user_match -type port r:/WORK/d2d_east_ctrl/apb_clk i:/WORK/d2d_east_ctrl/apb_clk__LEQ0
        set_user_match -type port r:/WORK/d2d_east_ctrl/apb_clk i:/WORK/d2d_east_ctrl/apb_clk__LEQ1
        set_user_match -type port r:/WORK/d2d_east_ctrl/apb_clk i:/WORK/d2d_east_ctrl/apb_clk__LEQ2
        set_user_match -type port r:/WORK/d2d_east_ctrl/apb_clk i:/WORK/d2d_east_ctrl/apb_clk__LEQ3
        set_user_match -type port r:/WORK/d2d_east_ctrl/apb_clk i:/WORK/d2d_east_ctrl/apb_clk__LEQ4
        set_user_match -type port r:/WORK/d2d_east_ctrl/apb_clk i:/WORK/d2d_east_ctrl/apb_clk__LEQ5
        set_user_match -type port r:/WORK/d2d_east_ctrl/apb_clk i:/WORK/d2d_east_ctrl/apb_clk__LEQ6
        set_user_match -type port r:/WORK/d2d_east_ctrl/apb_clk i:/WORK/d2d_east_ctrl/apb_clk__LEQ7
	
        set_user_match -type port r:/WORK/d2d_east_ctrl/cortex_ahb_hclk i:/WORK/d2d_east_ctrl/cortex_ahb_hclk__LEQ0
        set_user_match -type port r:/WORK/d2d_east_ctrl/cortex_ahb_hclk i:/WORK/d2d_east_ctrl/cortex_ahb_hclk__LEQ1
        set_user_match -type port r:/WORK/d2d_east_ctrl/cortex_ahb_hclk i:/WORK/d2d_east_ctrl/cortex_ahb_hclk__LEQ2
        set_user_match -type port r:/WORK/d2d_east_ctrl/cortex_ahb_hclk i:/WORK/d2d_east_ctrl/cortex_ahb_hclk__LEQ3
        set_user_match -type port r:/WORK/d2d_east_ctrl/cortex_ahb_hclk i:/WORK/d2d_east_ctrl/cortex_ahb_hclk__LEQ4
        set_user_match -type port r:/WORK/d2d_east_ctrl/cortex_ahb_hclk i:/WORK/d2d_east_ctrl/cortex_ahb_hclk__LEQ5
        set_user_match -type port r:/WORK/d2d_east_ctrl/cortex_ahb_hclk i:/WORK/d2d_east_ctrl/cortex_ahb_hclk__LEQ6
        set_user_match -type port r:/WORK/d2d_east_ctrl/cortex_ahb_hclk i:/WORK/d2d_east_ctrl/cortex_ahb_hclk__LEQ7
	
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ0
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ1
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ2
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ3
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ4
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ5
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ6
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ7
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ8
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ9
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ10
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ11
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ12
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ13
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ14
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ15
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ16
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ17
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ18
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ19
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ20
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ21
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ22
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ23
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ24
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ25
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ26
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ27
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ28
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ29
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ30
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ31
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ32
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ33
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ34
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ35
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ36
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ37
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ38
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ39
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ40
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ41
        set_user_match -type port r:/WORK/d2d_east_ctrl/d2d_ls_clk i:/WORK/d2d_east_ctrl/d2d_ls_clk__LEQ42
    } elseif {[info exists LEC_MODE] && $LEC_MODE == "syn2dft"} {
        add_renaming_rule {Mapb_clk} {apb_clk__LEQ0} {apb_clk} -Revised
        add_pin_equivalences apb_clk__LEQ0 apb_clk__LEQ1 -revised
        add_pin_equivalences apb_clk__LEQ0 apb_clk__LEQ2 -revised
        add_pin_equivalences apb_clk__LEQ0 apb_clk__LEQ3 -revised
        add_pin_equivalences apb_clk__LEQ0 apb_clk__LEQ4 -revised
        add_pin_equivalences apb_clk__LEQ0 apb_clk__LEQ5 -revised
        add_pin_equivalences apb_clk__LEQ0 apb_clk__LEQ6 -revised
        add_pin_equivalences apb_clk__LEQ0 apb_clk__LEQ7 -revised
        
        
        add_renaming_rule {Mcortex_ahb_hclk} {cortex_ahb_hclk__LEQ0} {cortex_ahb_hclk} -Revised
        add_pin_equivalences cortex_ahb_hclk__LEQ0 cortex_ahb_hclk__LEQ1 -revised
        add_pin_equivalences cortex_ahb_hclk__LEQ0 cortex_ahb_hclk__LEQ2 -revised
        add_pin_equivalences cortex_ahb_hclk__LEQ0 cortex_ahb_hclk__LEQ3 -revised
        add_pin_equivalences cortex_ahb_hclk__LEQ0 cortex_ahb_hclk__LEQ4 -revised
        add_pin_equivalences cortex_ahb_hclk__LEQ0 cortex_ahb_hclk__LEQ5 -revised
        add_pin_equivalences cortex_ahb_hclk__LEQ0 cortex_ahb_hclk__LEQ6 -revised
        add_pin_equivalences cortex_ahb_hclk__LEQ0 cortex_ahb_hclk__LEQ7 -revised
        
        add_renaming_rule {Md2d_ls_clk} {d2d_ls_clk__LEQ0} {d2d_ls_clk} -Revised
        add_pin_equivalences d2d_ls_clk__LEQ0 d2d_ls_clk__LEQ* -revised
    }
#######################################################################################################################################
##
##	d2d_pll_wrap
##
#######################################################################################################################################
} elseif { $DESIGN_NAME == "d2d_pll_wrap" } {
    if {[info exists LEC_MODE]} {
        puts " entering private d2d_pll_wrap constraints "
        if { $LEC_MODE == "net2net" } {
           add_renaming_rule {MpllW} {pllsys03_wrapper_pll} {brcm_pll_max_mmi_wrapper_island_lvl_pllsys03_wrapper_pll} -Revised
           add_renaming_rule {Mpwron} {pwr_good_reset} {pwron_reset_l} -Revised -type  PI -REPlace
           add_renaming_rule {Mrefclk} {d2d_pll_ref_clk_in} {pll_ref_clk_in} -Revised -type  PI -REPlace

           set TEST_PORTS [find -Port -Input TEST__PLL_RESETS_BYPASS -Revised]
           add_pin_constraints 0 $TEST_PORTS -Revised
	    }
        if { $LEC_MODE == "syn2dft" } {
            
            add_renaming_rule {HN_pll_ref_clk} {pll_ref_clk_in} {d2d_pll_ref_clk_in} -revised 
            add_renaming_rule {HN_REFCLK_PAD}  {REFCLK_%a_PAD}  {D2D_REFCLK_@1_PAD}  -revised 
            add_renaming_rule {HN_soc_dbus_in} {soc_dbus_in%d\[%d\]}  {d2d_soc_dbus_in@1\[@2\]}  -revised
            add_renaming_rule {HN_pll_rst} {resetn} {pll_ctl_reset_n} -revised 
            add_renaming_rule {HN_pll_refclk} {refclk_select} {cfg_d2d_pll_reg_refclk_select} -revised 
            add_renaming_rule {HN_term50} {term50_enable} {cfg_d2d_pll_reg_term50_enable} -revised 
            add_renaming_rule {HN_acbyp} {acbyp_enable} {cfg_d2d_pll_reg_acbyp_enable} -revised 
            add_renaming_rule {HN_pd_clkbuf} {pd_clkbuf} {cfg_d2d_pll_reg_pd_clkbuf} -revised 
            add_renaming_rule {HN_soc_abus0} {soc_abus0} {d2d_soc_abus0} -revised 
#            add_renaming_rule {HN_soc_abus0_z} {soc_abus0_z} {d2d_soc_abus0_z} -revised 
            add_renaming_rule {HN_soc_abus1} {soc_abus1} {d2d_soc_abus1} -revised 
#            add_renaming_rule {HN_soc_abus1_z} {soc_abus1_z} {d2d_soc_abus1_z} -revised 
            
            add_renaming_rule {Mpwron} {pwron_reset_l} {pwr_good_reset} -Revised

#            assign_pin_direction in cpll05_pllsys03_top_ns_01 SOC_ABUS* -revised
#            add_ignored_inputs SOC_ABUS* -module cpll05_pllsys03_top_ns_01 -revised
#            assign_pin_direction in cpll05_pllsys03_top_ns_01 SOC_ABUS* -golden
#            add_ignored_inputs SOC_ABUS* -module cpll05_pllsys03_top_ns_01 -golden

        }
    }
#######################################################################################################################################
##
## nxt009_top
##
#######################################################################################################################################
} elseif { $DESIGN_NAME == "nxt009_top" } {
    if {[info exists LEC_MODE]} {
        if { $LEC_MODE == "syn2dft" } {

            add_renaming_rule {HN_nxt009_top_inst} {/} {_} -Instance -Golden 

            add_ignored_inputs VDDQ -revised

            # <HN> translating from Nethra's FM commands file
            add_ignored_inputs  FUSE_CTRL_*                 -module  ds05_memmaster_02  -both
            add_ignored_inputs  MBR_DONE_PASS               -module  ds05_memmaster_02  -both
            add_ignored_inputs  OTP_*                       -module  ds05_memmaster_02  -both
            #add_ignored_inputs  efuse_core_burn_valid_eclk  -module  scu_top_syn_wrap   -both
            add_ignored_inputs  b2c_bisr_*                  -module  cfg_car_top        -both
            add_ignored_inputs  clk_opcg_pgm                -module  ddr5_syn_wrap      -both
            add_ignored_inputs  opcg_trig                   -module  ddr5_syn_wrap      -both

            add_ignored_inputs "MM_*"  -module ds05_fuse_controller_04 -both
            add_ignored_inputs "TAP_*" -module ds05_fuse_controller_04 -both 
            add_ignored_inputs "TDR_*" -module ds05_fuse_controller_04 -both


	    add_ignored_inputs TEST__EXT_CLK -module sd05C_pcie_pcs_d5_ub_ns_06 -both
	    add_ignored_inputs TEST__EXT_CLK -module sd05C_d5_tt_ub_ns_02 -both
    
	    add_primary_input /TEST__ASYNC_DISABLE -revised
	    add_pin_constraints 0 /TEST__ASYNC_DISABLE -revised


            # TEST__SPARE
            foreach {c p} "
                1 TEST__SPARE_H*             
                0 TEST__SPARE_L*             
                0 TEST__CKMUX_OVERRIDE       
                0 TEST__DOM_SCAN             
                0 TEST__TMS                  
                0 TEST__CLK_GATE_DISABLE     
                0 TEST__CLK_GATE_DISABLE_CKGT
                0 TEST__SCAN_EN              
                0 TEST__XBLOCK_TDF_ONLY      
                0 TEST__XBLOCK_SSA_AND_TDF   
                0 TEST__ASYNC_DISABLE        
                0 TEST__TDR_RST              
                1 TEST__ATPG_MODE_L          
                1 TEST__CORE_TAP_CTRL_L      
                1 TEST__SBUS_TAP_CTRL_L      
            " {
                foreach _p [find_cfm -pin i_scu_top_i_tap_controller/$p -revised] {
                    add_primary_input $_p -revised
                    add_pin_constraints $c $_p -revised
                }            
            }

            add_ignored_inputs bscan_ac_init_clk1 -module periphery_top_io_wrap_west -revised
            add_instance_constraints 0 -revised nxt009_top_gate0_tessent_tdr_sri_tdr5_inst__tdr_reg_1_
            
        } elseif { $LEC_MODE == "dft2place" } {

	    add_primary_input i_sandbox_nw_top_i_sandbox_nw_i_apb_system_nw_tree_APB_RPTR_HBM_NW_0__i_hbm_nw_apb_repeater_cluster/ts_0_lockup_latchn_clkc1_intno226_i/d -pin -cut -golden
            add_primary_input i_sandbox_nw_top_i_sandbox_nw_i_apb_system_nw_tree_APB_RPTR_HBM_NW_0__i_hbm_nw_apb_repeater_cluster/ts_0_lockup_latchn_clkc1_intno226_i/d -pin -cut -revised
            add_pin_constraints 0 i_sandbox_nw_top_i_sandbox_nw_i_apb_system_nw_tree_APB_RPTR_HBM_NW_0__i_hbm_nw_apb_repeater_cluster/ts_0_lockup_latchn_clkc1_intno226_i/d -both 

            add_primary_input i_sandbox_sw_top_i_sandbox_sw_i_apb_system_sw_tree_APB_RPTR_HBM_SW_0__i_hbm_sw_apb_repeater_cluster/ts_0_lockup_latchn_clkc1_intno226_i/d -pin -cut -golden
            add_primary_input i_sandbox_sw_top_i_sandbox_sw_i_apb_system_sw_tree_APB_RPTR_HBM_SW_0__i_hbm_sw_apb_repeater_cluster/ts_0_lockup_latchn_clkc1_intno226_i/d -pin -cut -revised
            add_pin_constraints 0 i_sandbox_sw_top_i_sandbox_sw_i_apb_system_sw_tree_APB_RPTR_HBM_SW_0__i_hbm_sw_apb_repeater_cluster/ts_0_lockup_latchn_clkc1_intno226_i/d -both 

            add_primary_input i_scu_top_i_apb_sandbox_scu_APB_RPTR_SANDBOX_SCU_0__i_sandbox_scu_apb_repeater_cluster/ts_0_lockup_latchn_clkc1_intno226_i/d -pin -cut -golden
            add_primary_input i_scu_top_i_apb_sandbox_scu_APB_RPTR_SANDBOX_SCU_0__i_sandbox_scu_apb_repeater_cluster/ts_0_lockup_latchn_clkc1_intno226_i/d -pin -cut -revised
            add_pin_constraints 0 i_scu_top_i_apb_sandbox_scu_APB_RPTR_SANDBOX_SCU_0__i_sandbox_scu_apb_repeater_cluster/ts_0_lockup_latchn_clkc1_intno226_i/d -both 
	
            # scu_top TEST
            foreach {c p} "
                1 TEST__SPARE_H*             
                0 TEST__SPARE_L*             
                0 TEST__CKMUX_OVERRIDE       
                0 TEST__DOM_SCAN             
                0 TEST__TMS                  
                0 TEST__CLK_GATE_DISABLE     
                0 TEST__CLK_GATE_DISABLE_CKGT
                0 TEST__SCAN_EN              
                0 TEST__XBLOCK_TDF_ONLY      
                0 TEST__XBLOCK_SSA_AND_TDF   
                0 TEST__ASYNC_DISABLE        
                0 TEST__TDR_RST              
                1 TEST__ATPG_MODE_L          
                1 TEST__CORE_TAP_CTRL_L      
                1 TEST__SBUS_TAP_CTRL_L      
            " {
                foreach mode "golden revised" {
                  foreach _p [find_cfm -pin i_scu_top_i_tap_controller/$p -$mode] {
                    add_primary_input $_p -$mode
                    add_pin_constraints $c $_p -$mode
                  }
                }
            }
            # module clock duplications
            foreach "bbx clk_list" "
                pcore_axi_syn_top         {apb_clk axi_clk cluster_clk cpu_clk} 
                center_hif_tile_top       {apb_clk axi_clk g2h_grid_clk h2g_grid_clk}
                ecore_quad_complex_top    {cpu_clk}
                eth_syn_wrap              {apb_clk axi_clk}
                pcie_top_syn_wrap         {apb_clk axi_clk pclk Max_PCLK}
                d2d_east_ctrl             {apb_clk cortex_ahb_hclk d2d_ls_clk}
                d2d_west_ctrl             {apb_clk cortex_ahb_hclk d2d_ls_clk}
                scu_top_syn_wrap          {apb_clk axi_clk}
                ddr_ctrl_bridge           {apb_clk axi_clk}
            " {
                foreach clk $clk_list {
                  add_renaming_rule -replace "HN_${bbx}_${clk}" "${clk}__LEQ%d" "${clk}" -Revised -bbox $bbx
                  set my_pins [regsub -all {\S*/} [find_cfm -libpin *$bbx*/${clk}__LEQ* -revised] {}]
                  add_pin_equivalences $my_pins -module $bbx -revised
                }
            }

            add_ignored_inputs TEST__FULL_SIN*  -module ecore_quad_complex_top -both
            add_ignored_inputs TEST__SIN*       -module general_pll -both
            add_ignored_inputs TEST__FULL_SIN*  -module hbm3_chiplet -both
            add_ignored_inputs TEST__FULL_SIN*  -module hbm3_chiplet_v2 -both
            add_ignored_inputs TEST__FULL_SIN*  -module ddr5_syn_wrap -both
            add_ignored_inputs TEST__FULL_SIN*  -module ddr_ctrl_bridge -both
            add_ignored_inputs TEST__SIN*       -module grid_quadrant_tessent_mbisr_controller -both
            
      }  ;# // End of dft2place 
    } ;# // End of LEC_MODE
#######################################################################################################################################
##
## periphery_top_io_wrap
##
#######################################################################################################################################
} elseif { $DESIGN_NAME == "periphery_top_io_wrap" } {
    if {[info exists LEC_MODE]} {
        if { $LEC_MODE == "dft2place" } {

            ### <HN>23ww45c - in postDFT we have 3 cells on io ring that turn into 2 cells in postLayout
            ###               ( 1 cell is removed, and all outputs are split among the other 2 cells )
            ###               ( this happens twice (two 3 cell-groups turn into two 2 cell-groups - for _POR and _VBIAS )
            ###               Our solution is to set these two 3 cells group as equivalnet in postDFT, and the same for the two 2 cell-groups in postLayout
            
            ###               Optimal solution would be to fix in RTL and have 2 cells to begin with.
            ###               BRCMs solution is to set selected outputs of these cells as constant.
            

            add_instance_equivalences "i_dft_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio_vbias i_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio_vbias i_nxt_gpio_aux_genblk1_i_gpio_vbias" -golden

            add_instance_equivalences "i_dft_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio_vbias i_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio_vbias" -revised

            add_instance_equivalences "i_dft_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio_por i_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio_por i_nxt_gpio_aux_genblk1_i_gpio_por" -golden

            add_instance_equivalences "i_dft_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio_por i_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio_por" -revised


#            set c0 "i_nxt_gpio_aux_genblk1_i_gpio"
#            set c1 "i_dft_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio"
#            set c2 "i_gpio_ana_wrap_i_gpio_aux_genblk1_i_gpio"
#
#            array set d18vx_pin_list "
#                vbias   {VGDC VGDP VGPG}
#                por     {modehv0_vddo modehv1_vddo modehv0b_vddp peb_vddp pebb_vddo}
#            "
#             
#             set mdl "BCM5FFXD18DFT_D18XV"
#                        
#            foreach sfx [array names d18vx_pin_list] {
#                add_instance_equivalences "${c0}_${sfx} ${c1}_${sfx} ${c2}_${sfx}" -golden
#                add_instance_equivalences "${c1}_${sfx} ${c2}_${sfx}" -revised
#            
#                foreach p $d18vx_pin_list($sfx) {
##                    add_output_stuck_at 1 $p -module ${mdl}_[string toupper $sfx] -both
#                }
#            }
        }   ;# // END OF dft2place
    }   ;# // END OF LEC_MODE
    
}

################################################################################
#
# File:         add_power.tcl
# Description:  Allows for resource allocation to model power grid impact on
#               signal routing.  
#                 ** Not LVS clean  **
#                 ** Not to be used for IR analysis **
#               This Tcl script is compatible with Encounter, Innovus and ICC2.
# Author:       Jason Gentry
# Created:      Tue Sep 11 08:52:05 MDT 2012
# Modified:     $Date:$ (Jason Gentry) jason.gentry@broadcom.com
# Language:     Tcl
#
# (C) Copyright 2012, Broadcom, all rights reserved.
#
################################################################################

namespace eval AvagoPowerGrid {
  ### Proc exports.
  namespace export add_avago_power_grid
  namespace export check_macro_snap_grid
  namespace export add_avago_clock_blockages
  namespace export remove_avago_clock_blockages

  ### Variable declarations.
  variable clkRsrcMetal _GC_ROUTE__DELETE
  variable clkRsrcBlkgMetals [list _GC_ROUTE__DELETE _LC_ROUTE__DELETE]

  ### Procedure definitions.
  proc add_avago_power_grid {args} {
    global pwrGridConfig
    global pwrGridBolsterConfig
    global pwrGridTrackInfo
    global pwrGridBolsterHalo
    variable maxInstBlkLyr; unset -nocomplain maxInstBlkLyr
    variable maxHInstBlkLyr; unset -nocomplain maxHInstBlkLyr
    variable minLayer; unset -nocomplain minLayer
    variable maxLayer; unset -nocomplain maxLayer
    variable powerPitch; unset -nocomplain powerPitch
    variable wireRepeat; unset -nocomplain wireRepeat
    variable wireDir; unset -nocomplain wireDir
    variable supplyInfos; unset -nocomplain supplyInfos
    variable viaXRepeat; unset -nocomplain viaXRepeat
    variable viaYRepeat; unset -nocomplain viaYRepeat
    variable supplys [list VSS VDD]
    variable signalUse
    set signalUse(VSS) GROUND
    set signalUse(VDD) POWER

    ### Variable check.
    if {! [info exists pwrGridConfig] || ! [info exists pwrGridTrackInfo]} {
      error "Power configuration variables not found."
    }

    ### Option parsing.
    set headBoxes [head_boxes]
    set options(-area) [agDBUToMicrons $headBoxes]
    parse_proc_arguments -args $args options
    set pgAreas [agMicronsToDBU $options(-area)]
    set pgAreas [_logop_and $pgAreas $headBoxes]
    set aCfg $pwrGridConfig
    if {[info exists options(-bolster_insts)]} {
      if {! [info exists pwrGridBolsterConfig]} {
        error "Cannot use '-bolster_insts' option unless 'pwrGridBolsterConfig' variable is defined."
      }
      set bCfg $pwrGridBolsterConfig
    } else {
      set bCfg $aCfg
    }

    if {$bCfg == $aCfg && [info exists options(-bolster_insts)]} {
      ### No need to bolster if no bolster-specific configuration exists.
      unset options(-bolster_insts)
    }

    ### Interpret the power tracking.
    #agCreateRowsTracks
    puts "Info: Initializing power tracking information..."
    init_power_tracking $aCfg

    ### Remove the existing grid first.
    puts "Info: Removing existing power grid (if any)..."
    remove_power_grid

    ### Process the instances.
    set hinstPtrList [store_hinsts]
    puts "Info: Processing design hierarchical instance(s)..."
    foreach hinstPtr $hinstPtrList {
      foreach box [_inst_boxes $hinstPtr] {
        for {set layer $minLayer} {$layer <= $maxHInstBlkLyr($hinstPtr)} {incr layer} {
          lappend instBoxes($layer) $box
        }
      }
    }
    set instPtrList [store_macros]
    puts "Info: Processing design macro(s)..."
    foreach instPtr $instPtrList {
      set inst_boxes [_inst_boxes $instPtr]
      for {set layer $minLayer} {$layer <= $maxInstBlkLyr($instPtr)} {incr layer} {
        set use_boxes $inst_boxes
        if {$layer < $maxInstBlkLyr($instPtr)} {
          set spc [_inst_halo $layer]
          if {$spc != 0} {
            set use_boxes [lindex [_logop_size $use_boxes $spc]]
          }
        }
        if {! [info exists allInstBoxes($layer)]} {
          set allInstBoxes($layer) [list]
        }
        set allInstBoxes($layer) [concat $allInstBoxes($layer) $use_boxes]
        if {! [info exists instBoxes($layer)]} {
          set instBoxes($layer) [list]
        }
        set instBoxes($layer) [concat $instBoxes($layer) $use_boxes]
      }
    }
    if {[info exists options(-bolster_insts)]} {
      puts "Info: Processing instance bolstering..."
      init_power_tracking $bCfg
      set blstHalo [agMicronsToDBU $pwrGridBolsterHalo]
      foreach instPat $options(-bolster_insts) {
        foreach instName [_find_insts $instPat] {
          set instPtr [_get_inst_ptr $instName]
          if {[is_inst_macro $instPtr]} {
            set iBoxes [_inst_boxes $instPtr]]
            set bBoxes [_logop_size $iBoxes $blstHalo]
            for {set layer $minLayer} {$layer <= $maxLayer} {incr layer} {
              if {! [configs_are_equivalent $aCfg $bCfg $layer]} {
                foreach bBox $bBoxes {
                  lappend blstrBoxes($layer) $bBox
                }
              }
            }
          }
        }
      }
      set shrinkHead [_logop_size [head_boxes] -$blstHalo]
      foreach layer [array names blstrBoxes] {
        if {! [info exists allInstBoxes($layer)]} {
          set allInstBoxes($layer) [list]
        }
        set andnot [_logop_andnot $blstrBoxes($layer) $allInstBoxes($layer)]
        set and [_logop_and $andnot $shrinkHead]
        set blstrBoxes($layer) [_logop_and $and $pgAreas]
      }
    }

    ### Now add the power grid.
    puts "Info: Generating power grid DEF..."
    create_def
    for {set layer $minLayer} {$layer <= $maxLayer} {incr layer} {
      set aAddAreas $pgAreas
      set bAddAreas [list]
      set aCutAreas [list]
      set bCutAreas [list]
      if {[info exists blstrBoxes($layer)]} {
        set aCutAreas [_logop_or2 $aCutAreas $blstrBoxes($layer)]
        set bAddAreas $blstrBoxes($layer)
      }
      if {[info exists instBoxes($layer)]} {
        set aCutAreas [_logop_or2 $aCutAreas $instBoxes($layer)]
        if {[llength $bAddAreas]} {
          set bCutAreas [_logop_or2 $bCutAreas $instBoxes($layer)]
        }
      }
      add_routes $aAddAreas $aCutAreas $layer $aCfg
      add_routes $bAddAreas $bCutAreas $layer $bCfg
      set vLayer [agLayerName [agLayerInfo -up_via_layer [agGetLayerByZ $layer]]]
      if {[llength $vLayer]} {
        add_vias $aAddAreas $aCutAreas $vLayer $aCfg
        add_vias $bAddAreas $bCutAreas $vLayer $bCfg
      }
    }
    puts "Info: Reading power grid DEF..."
    _read_def
    puts "Info: Done.  Thank you for choosing Broadcom."
  }
  define_proc_attributes add_avago_power_grid \
    -info "Add power grid model for resource allocation" \
    -define_args { \
      {-bolster_insts "Bolster the power grid around these instances or glob-style instance name patterns" instList list optional} \
      {-area "Area to add the power grid to." area list optional} \
    }

  proc check_macro_snap_grid {args} {
    global pwrPlanningTrackingTables
    global instOriginForceSnapXGrid
    global instOriginForceSnapYGrid
    global instOriginForceSnapXOffset
    global instOriginForceSnapYOffset
    global instOriginForceSnapRefOrient
    global instOriginForceSnapGridByLayer
    global instOriginAllowedOrients
    global synopsys_program_name
    global pwrGridConfig
    global pwrGridTrackInfo
    set options(-snap_origin) 0
    set options(-return_off_grid) 0
    parse_proc_arguments -args $args options
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set siteDefn [index_collection [get_site_defs] 0]
      set placeXGrid [agMicronsToDBU [get_attribute $siteDefn width]]
      set placeYGrid [agMicronsToDBU [get_attribute $siteDefn height]]
    } else {
      set defaultSite [dbFPlanDefaultTechSite [dbCellFPlan [dbgTopCell]]]
      set placeXGrid [dbSiteSizeX $defaultSite]
      set placeYGrid [dbSiteSizeY $defaultSite]
    }
    set enumOppIdx(0) 2
    set enumOppIdx(1) 3
    set enumOppIdx(2) 0
    set enumOppIdx(3) 1
  
    ### See if there are any forced snap grids specified.
    foreach layerName [array names instOriginForceSnapGridByLayer] {
      set lyr [agLayerWireId [agGetLayerByExtName $layerName]]
      set forceSnapLayer($lyr) [agMicronsToDBU $instOriginForceSnapGridByLayer($layerName)]
    }
    foreach cellPat [array names instOriginForceSnapXGrid] {
      foreach cellName [_find_cells_by_name $cellPat] {
        set forceSnapX($cellName) [agMicronsToDBU $instOriginForceSnapXGrid($cellPat)]
      }
    }
    foreach cellPat [array names instOriginForceSnapYGrid] {
      foreach cellName [_find_cells_by_name $cellPat] {
        set forceSnapY($cellName) [agMicronsToDBU $instOriginForceSnapYGrid($cellPat)]
      }
    }
    foreach cellPat [array names instOriginForceSnapXOffset] {
      foreach cellName [_find_cells_by_name $cellPat] {
        foreach offset $instOriginForceSnapXOffset($cellPat) {
          if {[regexp {(R0|MY|MX|R180):(.*)} $offset match fori fval]} {
            ### Orient-specific offset specification.
            set forceOffsetX($cellName,$fori) [agMicronsToDBU $fval]
          } else {
            set forceOffsetX($cellName) [agMicronsToDBU $offset]
          }
        }
      }
    }
    foreach cellPat [array names instOriginForceSnapYOffset] {
      foreach cellName [_find_cells_by_name $cellPat] {
        foreach offset $instOriginForceSnapYOffset($cellPat) {
          if {[regexp {(R0|MY|MX|R180):(.*)} $offset match fori fval]} {
            ### Orient-specific offset specification.
            set forceOffsetY($cellName,$fori) [agMicronsToDBU $fval]
          } else {
            set forceOffsetY($cellName) [agMicronsToDBU $offset]
          }
        }
      }
    }
    foreach cellPat [array names instOriginForceSnapRefOrient] {
      foreach cellName [_find_cells_by_name $cellPat] {
        set refOrient($cellName) $instOriginForceSnapRefOrient($cellPat)
      }
    }
    foreach cellPat [array names instOriginAllowedOrients] {
      foreach cellName [_find_cells_by_name $cellPat] {
        set forceOrients($cellName) $instOriginAllowedOrients($cellPat)
      }
    }
  
    ### Read power specified (or default) power configuration variables.
    if {! [info exists pwrGridConfig] || ! [info exists pwrGridTrackInfo]} {
      error "Power configuration variables not found."
    }
  
    set lastPitch 0
    set lastNonViaLayer -1
    set prevLayer -1
    set maxMetal 0
    set layerIds [list]
    foreach rtLayerName [agLayerInfo -lef_names -route_layers] {
      set rtLyrPtr [_get_layer_pointer $rtLayerName]
      set key $pwrGridConfig,$rtLayerName
      set metalId [_get_layer_z $rtLyrPtr]
      lappend layerIds $metalId
      if {$prevLayer >= 0} {
        set viaUpLyr($prevLayer) $metalId 
      }
      if {[info exists pwrGridTrackInfo($key)]} {
        ### See if the last layer was a via-stack.
        if {$lastNonViaLayer >= 0 && $lastNonViaLayer != [expr {$metalId-1}]} {
          ### Yup.
          set viaUpLyr($lastNonViaLayer) $metalId 
        }
        if {$maxMetal < $metalId} {set maxMetal $metalId}
  
        ### Store power pitch.
        foreach {effPitch rptPitch dir1 dir2} $pwrGridTrackInfo($key) {break}
        ### Backward compatibility for older pwrGridTrackInfo definitions.
        if {$dir1 == "h" || $dir1 == "v"} {
          set dir $dir1
        } else {
          set dir $dir2
        }
        set pwrPitch($metalId) [agMicronsToDBU $effPitch]
        set lastPitch $pwrPitch($metalId)
  
        set lastNonViaLayer $metalId
      } else {
        ### Via-stack layer.
        set pwrPitch($metalId) $lastPitch
      }
      set prevLayer $metalId
    }
    set viaUpLyr($prevLayer) $metalId 
    foreach metalId $layerIds {
      if {! [info exists viaOnlyLyr($metalId)]} {
        set viaOnlyLyr($metalId) 0
      }
      if {! [info exists viaStackLyr($metalId)]} {
        set viaStackLyr($metalId) 0
        if {$viaUpLyr($metalId) != [expr {$metalId+1}]} {
          for {set i $metalId} {$i < $viaUpLyr($metalId)} {incr i} {
            set viaStackLyr($i) 1
            set viaStackUpLyr($i) $viaUpLyr($metalId)
            if {$i != $metalId} {
              set viaOnlyLyr($i) 1
            }
          }
        }
      }
    }
  
    ### Aggregate list of instances to process.
    set instList [list]
    foreach instPtr [store_macros] {
      set allInsts([_inst_name $instPtr]) $instPtr
    }
    if {[info exists options(instList)]} {
      foreach instPat $options(instList) {
        foreach instName [array names allInsts $instPat] {
          lappend instList $allInsts($instName)
        }
      }
      if {! [llength $instList]} {
        puts "Warning: No instance(s) matched specified instList."
      }
    } else {
      foreach instName [array names allInsts] {
        lappend instList $allInsts($instName)
      }
      if {! [llength $instList]} {
        puts "Warning: No instance(s) found in the design."
      }
    }
  
    if {! [llength $instList]} {return 1}
  
    ### Run through list of instance pointers looking for legal placements.
    set rc 1
    set offGrid [list]
    foreach instPtr $instList {
      ### Figure out the instance coords, orient.
      set cellName [_inst_cell $instPtr]
      set instBox [agBoxesBoundingBox [_inst_boxes $instPtr]]
      set instOrient [_inst_orient $instPtr]
      set instName [_inst_name $instPtr]
      set pstatus [_inst_pstatus $instPtr]
      if {$pstatus == "unplaced"} {
        puts "Warning: Instance '$instName ($cellName)' is unplaced."
        set rc 0
        continue
      }
  
      ### Check orient if specified.
      if {[info exists forceOrients($cellName)]} {
        set found_legal 0
        foreach check_orient $forceOrients($cellName) {
          if {$check_orient == $instOrient} {
            set found_legal 1
            break
          }
        }
        if {! $found_legal} {
          set rc 0
          puts "Error: Instance '$instName ($cellName)' has illegal orient '$inst_orient', must be one of [join $forceOrients($cellName) {, }]."
        }
      }
  
      ### Based on the orient, figure out which coordinates need to be on-grid.
      switch -exact -- $instOrient {
        R0 -
        MX90 {
          set xIdx 0
          set yIdx 1
          set offXSign "+"
          set offYSign "+"
        }
        MY -
        R90 {
          set xIdx 2
          set yIdx 1
          set offXSign "-"
          set offYSign "+"
        }
        MX -
        R270 {
          set xIdx 0
          set yIdx 3
          set offXSign "+"
          set offYSign "-"
        }
        R180 -
        MY90 {
          set xIdx 2
          set yIdx 3
          set offXSign "-"
          set offYSign "-"
        }
      }
      ### If the reference orient is specified, swap the index.
      set refOriStr ""
      if {[info exists refOrient($cellName)]} {
        switch -exact -- $refOrient($cellName) {
          R0 {
            ### Do nothing.
          }
          MX {
            set yIdx $enumOppIdx($yIdx)
          }
          MY {
            set xIdx $enumOppIdx($xIdx)
          }
          R180 {
            set xIdx $enumOppIdx($xIdx)
            set yIdx $enumOppIdx($yIdx)
          }
        }
        set refOriStr ", reference orient $refOrient($cellName)"
      }
  
      ### Figure out max layer for each instance.
      if {[info exists options(-max_top_layer)]} {
        set instMaxLayer($instPtr) [min $options(-max_top_layer) [agMaxBlockedLayer $instPtr]]
      } elseif {[info exists options(-force_top_layer)]} {
        set instMaxLayer($instPtr) [min $maxMetal $options(-force_top_layer)]
      } else {
        set instMaxLayer($instPtr) [min $maxMetal [agMaxBlockedLayer $instPtr]]
      }
  
      if {[info exists forceOffsetX($cellName,$instOrient)]} {
        set xOff $forceOffsetX($cellName,$instOrient)
      } elseif {[info exists forceOffsetX($cellName)]} {
        set xOff ${offXSign}$forceOffsetX($cellName)
      } else {
        set xOff 0
      }
      if {[info exists forceOffsetY($cellName,$instOrient)]} {
        set yOff $forceOffsetY($cellName,$instOrient)
      } elseif {[info exists forceOffsetY($cellName)]} {
        set yOff ${offYSign}$forceOffsetY($cellName)
      } else {
        set yOff 0
      }
      unset -nocomplain xConstraint yConstraint
      if {$instMaxLayer($instPtr) == -1} {
        ### No pin layers, at least snap it to the placement grid?
        if {[agIsLayerHorizontal $minMetal]} {
          set xLyr [expr {$minMetal+1}]
          set yLyr $minMetal
        } else {
          set yLyr [expr {$minMetal+1}]
          set xLyr $minMetal
        }
        if {[info exists forceSnapX($cellName)]} {
          set xSnap $forceSnapX($cellName)
        } else {
          set xSnap $placeXGrid
          if {! [info exists forceOffsetX($cellName)] && \
            ! [info exists forceOffsetX($cellName,$instOrient)]} {
            set xOff ${offXSign}[agSnapToPlaceXDBUGrid 0]
          }
        }
        if {[info exists forceSnapY($cellName)]} {
          set ySnap $forceSnapY($cellName)
        } else {
          set ySnap $placeYGrid
          if {! [info exists forceOffsetY($cellName)] && \
            ! [info exists forceOffsetY($cellName,$instOrient)]} {
            set yOff ${offYSign}[agSnapToPlaceYDBUGrid 0]
          }
        }
      } else {
        ### Figure out which grids we are worried about, via-stack layers will
        ### have an impact on this.
        set maxLyr $instMaxLayer($instPtr)
        set adjFactLyr -1
        if {$viaStackLyr($maxLyr) && $viaOnlyLyr($maxLyr)} {
          set maxLyr $viaStackUpLyr($maxLyr)
          set adjFactLyr [expr {$maxLyr-1}]
        }
        if {[agIsLayerHorizontal $maxLyr]} {
          set xLyr [expr {$maxLyr-1}]
          set yLyr $maxLyr
        } else {
          set xLyr $maxLyr
          set yLyr [expr {$maxLyr-1}]
        }
        ### In case the x/yLyr doesn't have power definitions.
        if {! [info exists offsets($xLyr)]} {set offsets($xLyr) [list]}
        if {! [info exists pwrPitch($xLyr)]} {set pwrPitch($xLyr) $placeXGrid}
        if {! [info exists offsets($yLyr)]} {set offsets($yLyr) [list]}
        if {! [info exists pwrPitch($yLyr)]} {set pwrPitch($yLyr) $placeYGrid}
        set xFact 2
        set yFact 2
        if {$xLyr == $adjFactLyr} {set xFact 1}
        if {$yLyr == $adjFactLyr} {set yFact 1}
        ### Depending on the top-most layer's power pitch offsets, there
        ### could be an additional factor to apply to ensure the power grid
        ### is compatible.  Only check this if the cell has power pins on
        ### the max h/v layer, though.
        set addXFact 1
        set addYFact 1
        set xFact [expr {$addXFact * $xFact}]
        set yFact [expr {$addYFact * $yFact}]
  
        if {[info exists forceSnapX($cellName)]} {
          set xSnap $forceSnapX($cellName)
          set xConstraint "user-specified X (cellPattern=$cellName)"
        } elseif {[info exists forceSnapLayer($xLyr)]} {
          set xSnap $forceSnapLayer($xLyr)
          set xConstraint "user-specified X ($xLyr=[agDBUToMicrons $xSnap])"
        } else {
          set xSnap [expr {$xFact*$pwrPitch($xLyr)}]
        }
        if {[info exists forceSnapY($cellName)]} {
          set ySnap $forceSnapY($cellName)
          set yConstraint "user-specified Y (cellPattern=$cellName)"
        } elseif {[info exists forceSnapLayer($yLyr)]} {
          set ySnap $forceSnapLayer($yLyr)
          set yConstraint "user-specified Y ($yLyr=[agDBUToMicrons $ySnap])"
        } else {
          set ySnap [expr {$yFact*$pwrPitch($yLyr)}]
        }
      }
  
      set xLyrName $xLyr
      set yLyrName $yLyr
      if {! [info exists xConstraint]} { set xConstraint $xLyrName }
      if {! [info exists yConstraint]} { set yConstraint $yLyrName }
  
      ### Now check/correct.
      set xC [lindex $instBox $xIdx]
      set xS [expr {[agSnapDBUCoord $xC $xSnap]+$xOff}]
      set xD [expr {$xC-$xS}]
      set yC [lindex $instBox $yIdx]
      set yS [expr {[agSnapDBUCoord $yC $ySnap]+$yOff}]
      set yD [expr {$yC-$yS}]
      set xoffStr ""
      set yoffStr ""
      if {$xOff != 0} {
        set xoffStr ", X offset [agDBUToMicrons $xOff]"
      }
      if {$yOff != 0} {
        set yoffStr ", Y offset [agDBUToMicrons $yOff]"
      }
      set offStr " offsets [agDBUToMicrons $xOff]/[agDBUToMicrons $yOff]"
      if {$xD || $yD} {
        lappend offGrid $instName
        if {$options(-snap_origin)} {
          if {$xD && $yD} {
            puts "Info: Moving instance '$instName ($cellName)' origin from [agDBUToMicrons $xC],[agDBUToMicrons $yC] to [agDBUToMicrons $xS],[agDBUToMicrons $yS] to align origin to $xConstraint/$yConstraint pitches [agDBUToMicrons $xSnap]/[agDBUToMicrons $ySnap]${offStr}${refOriStr}."
          } elseif {$xD} {
            puts "Info: Moving instance '$instName ($cellName)' X location from [agDBUToMicrons $xC] to [agDBUToMicrons $xS] to align origin to $xConstraint pitch [agDBUToMicrons $xSnap]${xoffStr}${refOriStr}."
          } elseif {$yD} {
            puts "Info: Moving instance '$instName ($cellName)' Y location from [agDBUToMicrons $yC] to [agDBUToMicrons $yS] to align origin to $yConstraint pitch [agDBUToMicrons $ySnap]${yoffStr}${refOriStr}."
          }
          foreach {llx lly urx ury} $instBox {
            set llx [agDBUToMicrons [expr {$llx - $xD}]]
            set lly [agDBUToMicrons [expr {$lly - $yD}]]
            set urx [agDBUToMicrons [expr {$urx - $xD}]]
            set ury [agDBUToMicrons [expr {$ury - $yD}]]
          }
          _place_inst $instName [list $llx $lly $urx $ury] $instOrient
        } else {
          set rc 0
          if {$xD && $yD} {
            puts "Warning: Instance '$instName ($cellName)' origin placement at [agDBUToMicrons $xC],[agDBUToMicrons $yC] is off-grid with respect to $xConstraint/$yConstraint pitches [agDBUToMicrons $xSnap]/[agDBUToMicrons $ySnap]${offStr}${refOriStr}."
          } elseif {$xD} {
            puts "Warning: Instance '$instName ($cellName)' X location at [agDBUToMicrons $xC] is off-grid with respect to $xConstraint pitch [agDBUToMicrons $xSnap]${xoffStr}${refOriStr}."
          } elseif {$yD} {
            puts "Warning: Instance '$instName ($cellName)' Y location at [agDBUToMicrons $yC] is off-grid with respect to $yConstraint pitch [agDBUToMicrons $ySnap]${yoffStr}${refOriStr}."
          }
        }
      }
    }
  
    ### We're done.
    if {$options(-return_off_grid)} {
      return $offGrid
    }
    return $rc
  }
  define_proc_attributes check_macro_snap_grid \
    -info "Check instance origin placement grid with respect to the power grid configuration" \
    -define_args { \
      {-snap_origin "Move off-grid h/instance(s) to be on-grid" "" boolean optional} \
      {-force_top_layer "Force the h/insts(s) top-layer to this layer" layer int optional} \
      {-max_top_layer "Cap what the max layer for instances can be" layer int optional} \
      {-return_off_grid "Return instance list of those macros that are offgrid" "" boolean optional} \
      {instList "List of h/instances or glob-style h/instance match patterns (default: all insts)" instList list optional} \
    }

  proc add_avago_clock_blockages {args} {
    global pwrGridConfig
    global clock_blockage_estimates
    variable powerPitch
    variable clkRsrcMetal
    variable clkRsrcBlkgMetals

    ### Configuration check.
    if {! [info exists clock_blockage_estimates]} {
      puts "Error: Clock blockage estimates have not yet been configured for this process."
      return 0
    }

    ### Parse argument(s).
    set options(-density) default
    parse_proc_arguments -args $args options

    ### Remove any existing clock resource blockages.
    remove_avago_clock_blockages

    ### Initialize constants.
    set cfg $pwrGridConfig
    set headBoxes [head_boxes]
    foreach {hllx hlly hurx hury} [agBoxesBoundingBox $headBoxes] {break}
    agCreateRowsTracks
    init_power_tracking $cfg

    ### Determine percentage of resource to assume for each layer.
    foreach key [array names clock_blockage_estimates *,default] {
      set layer [lindex [split $key ,] 0]
      set cfgKey $cfg,[agLayerName [agGetLayerByZ $layer]]
      if {! [info exists minLayer] || $minLayer > $layer} {
        set minLayer $layer
      }
      if {! [info exists maxLayer] || $maxLayer < $layer} {
        set maxLayer $layer
      }
      if {[info exists clock_blockage_estimates($layer,$options(-density))]} {
        set rsrcBlkg($layer) [expr {1.0 * $clock_blockage_estimates($layer,$options(-density)) / 100}]
      } else {
        set rsrcBlkg($layer) [expr {1.0 * $clock_blockage_estimates($layer,default) / 100}]
      }
    }

    ### Store the resource blockages associated with macros.
    foreach instPtr [store_macros] {
      set instBoxes [_inst_boxes $instPtr]
      for {set layer $minLayer} {$layer <= [agMaxBlockedLayer $instPtr]} {incr layer} {
        if {! [info exists layerBlkBoxes($layer)]} {
          set layerBlkBoxes($layer) [list]
        }
        ### Grow the box by one supertrack to avoid creating DRC issues.
        set pPitch [_get_power_pitch $cfg [agGetLayerByZ $layer]]
        set instBoxes [_logop_size $instBoxes $pPitch]
        set layerBlkBoxes($layer) [concat $layerBlkBoxes($layer) $instBoxes]
      }
    }

    ### See if we have existing nets with the same name.
    foreach clkRsrcBlkgMetal $clkRsrcBlkgMetals {
      set netPtr [_get_net_pointer $clkRsrcBlkgMetal]
      if {$netPtr == "" || $netPtr == "0x0"} {continue}
      ### Avoid areas that already have clock resources.
      foreach sWire [_get_net_wires $netPtr] {
        if {$sWire == "" || $sWire == "0x0"} {continue}
        set layer [_get_wire_layer $sWire]
        if {! [info exists rsrcBlkg($layer)]} {continue}
        ### Snap sWire edges out to nearest supertrack.
        foreach sRect [_get_wire_boxes $sWire] {
          if {$sRect == ""} {continue}
          foreach {sllx slly surx sury} $sRect {break}
          set pitch [_get_power_pitch $cfg [agGetLayerByZ $layer]]
          if {[agIsLayerHorizontal $layer]} {
            set stllx [expr {$sllx - $pitch}]
            set stlly [snap_dn $slly $pitch]
            set sturx [expr {$surx + $pitch}]
            set stury [snap_up $sury $pitch]
          } else {
            set stllx [snap_dn $sllx $pitch]
            set stlly [expr {$slly - $pitch}]
            set sturx [snap_up $surx $pitch]
            set stury [expr {$sury + $pitch}]
          }
          lappend layerBlkBoxes($layer) [list $stllx $stlly $sturx $stury]
        }
      }
    }

    ### Create the clock resource emulation metal if it does not already exist.
    set netPtr [_get_or_create_phy_net $clkRsrcMetal 1]

    ### Using the percent resource blockage values, split into minimum-width
    ### wires and distribute across the block.
    foreach layer [lsort -integer -increasing [array names rsrcBlkg]] {
      set strapCount($layer) 0
      set wires [list]
      set layerPtr [_get_layer_pointer $layer]
      set layerName [agLayerName [agGetLayerByZ $layer]]
      puts "Info: Adding clock blockage metal for layer $layer..."
      set vert [agIsLayerVertical $layer]
      set pwrPitch [_get_power_pitch $cfg $layerPtr]
      set trackPitch [_get_layer_pitch $layerPtr]
      set wireHalfW [expr {[_get_layer_width $layerPtr]/2}]
      ### Find the total number of tracks available.
      if {$vert} {
        set numTracks($layer) [expr {($hurx-$hllx)/$trackPitch}]
      } else {
        set numTracks($layer) [expr {($hury-$hlly)/$trackPitch}]
      }
      set blkTracks [expr {int(ceil(1.0 * $rsrcBlkg($layer) * $numTracks($layer)))}]
      set step [expr {int(floor(1.0 * $numTracks($layer) / $blkTracks))}]
      set start [expr {$step/2}]
      for {set sigTrk $start} {$sigTrk < $numTracks($layer)} {incr sigTrk $step} {
        set sigCrd [expr {$sigTrk * $trackPitch}]
        set stNum [expr {[snap_dn $sigCrd $pwrPitch] / $pwrPitch}]

        ### Add the wire to the middle of the supertrack.
        incr strapCount($layer)
        set midCrd [_snap_to_track [expr {$stNum*$pwrPitch + ($pwrPitch/2)}] $layerPtr]
        if {$vert} {
          lappend wires [list \
              [expr {$midCrd - $wireHalfW}] $hlly \
              [expr {$midCrd + $wireHalfW}] $hury \
            ]
        } else {
          lappend wires [list \
              $hllx [expr {$midCrd - $wireHalfW}] \
              $hurx [expr {$midCrd + $wireHalfW}] \
            ]
        }
      }

      if {[llength $wires]} {
        ### Now ANDNOT the resource shapes with the blockages.
        if {[info exists layerBlkBoxes($layer)]} {
          set addWires [_logop_andnot $wires $layerBlkBoxes($layer)]
        } else {
          set addWires $wires
        }

        ### Just in case the block is rectilinear, limit to block regions.
        set addWires [_logop_and $addWires $headBoxes]
        foreach wire $addWires {
          _create_wire $netPtr $wire $layer "ROUTED"
        }
      }
    }

    ### Print summary.
    puts ""
    puts "Resource Blockage Summary:"
    puts "--------------------------"
    set totalStraps 0
    foreach layer [lsort -integer -increasing [array names rsrcBlkg]] {
      if {! [info exists strapCount($layer)]} {continue}
      set layerName [agLayerName [agGetLayerByZ $layer]]
      set blkPerc [expr {100.0 * $strapCount($layer) / $numTracks($layer)}]
      puts [format {  %-7s %20s : (%.3f %% blockage)} $layerName "$strapCount($layer)/$numTracks($layer) tracks" $blkPerc]
      incr totalStraps $strapCount($layer)
    }

    return $totalStraps
  }
  define_proc_attributes add_avago_clock_blockages \
    -info "Add clock blockage metal that emulates the resources blocked by structured clocking" \
    -define_args { \
      {-density "Assumed register/clock density" sort_by one_of_string {optional value_help {values {default low medium high}}}} \
    }

  proc remove_avago_clock_blockages {} {
    global synopsys_program_name
    variable clkRsrcMetal
    ### Only remove "ROUTED" GCD metal, "FIXED" was pushed down from
    ### top-level resource needs.
    set netPtr [_get_net_pointer $clkRsrcMetal]
    if {$netPtr == "" || $netPtr == "0x0"} {return}
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      if {[sizeof_collection $netPtr]} {
        remove_routes -nets $netPtr -stripe -lib_cell_pin_connect
      }
    } else {
      if {$netPtr} {
        editDelete -nets $clkRsrcMetal -status "ROUTED"
      }
    }
  }

  proc init_power_tracking {cfgName} {
    global pwrGridTrackInfo
    global pwrGridVirtualLayer
    variable minLayer
    variable maxLayer
    variable powerPitch
    variable wireRepeat
    variable wireDir
    variable supplyInfos
    variable viaXRepeat
    variable viaYRepeat

    ### Processing the routing layers.
    foreach rtLayerName [agLayerInfo -lef_names -route_layers] {
      set rtLyrPtr [_get_layer_pointer $rtLayerName]
      set key $cfgName,$rtLayerName
      if {[info exists pwrGridVirtualLayer($key)] && \
        $pwrGridVirtualLayer($key)} {continue}
      if {[info exists pwrGridTrackInfo($key)]} {
        set metalId [_get_layer_z $rtLyrPtr]
        if {! [info exists minLayer] || $metalId < $minLayer} {
          set minLayer $metalId
        }
        if {! [info exists maxLayer] || $metalId > $maxLayer} {
          set maxLayer $metalId
        }
        foreach {effPitch rptPitch dir1 dir2} $pwrGridTrackInfo($key) {break}
        ### Backward compatibility for older pwrGridTrackInfo definitions.
        if {$dir1 == "h" || $dir1 == "v"} {
          set dir $dir1
          set lrangeIdx 3
        } else {
          set dir $dir2
          set lrangeIdx 4
        }
        if {[llength $rptPitch] > 1} {
          ### No support for grid cuts at the moment.
          if {$dir == "h"} {
            set rptPitch [lindex $rptPitch 1]
          } else {
            set rptPitch [lindex $rptPitch 0]
          }
        }
        set powerPitch($key) [agMicronsToDBU $effPitch]
        set wireRepeat($key) [agMicronsToDBU $rptPitch]
        set wireDir($key) $dir
        foreach supply_info [lrange $pwrGridTrackInfo($key) $lrangeIdx end] {
          foreach {supplyIdx width delta mask} $supply_info {break}
          if {! [info exists mask]} {set mask 0}
          if {[llength $delta] > 1} {
            ### No support for grid cuts at the moment.
            set delta [lindex $delta 0]
          }
          lappend supplyInfos($key) [list \
              $supplyIdx [agMicronsToDBU $width] \
              [agMicronsToDBU $delta] $mask \
            ]
        }
      }
    }
    ### Now process the via layers.
    foreach viaLayerName [agLayerInfo -lef_names -via_layers] {
      set viaLyrPtr [_get_layer_pointer $viaLayerName]
      set key $cfgName,$viaLayerName
      if {[info exists pwrGridTrackInfo($key)]} {
        foreach {effPitch rptXPitch rptYPitch} $pwrGridTrackInfo($key) {break}
        set powerPitch($key) [agMicronsToDBU $effPitch]
        set viaXRepeat($key) [agMicronsToDBU $rptXPitch]
        set viaYRepeat($key) [agMicronsToDBU $rptYPitch]
        foreach supply_info [lrange $pwrGridTrackInfo($key) 3 end] {
          foreach {supplyIdx viaName xDelta yDelta} $supply_info {break}
          lappend supplyInfos($key) [list \
              $supplyIdx $viaName \
              [agMicronsToDBU $xDelta] \
              [agMicronsToDBU $yDelta] \
            ]
        }
      }
    }
  }

  proc configs_are_equivalent {cfg1 cfg2 layer} {
    variable powerPitch
    variable wireRepeat
    variable wireDir
    variable supplyInfos
    variable viaXRepeat
    variable viaYRepeat
    if {$powerPitch($cfg1,$layer) != $powerPitch($cfg2,$layer)} { return 0 }
    if {$wireRepeat($cfg1,$layer) != $wireRepeat($cfg2,$layer)} { return 0 }
    if {$wireDir($cfg1,$layer) != $wireDir($cfg2,$layer)} { return 0 }
    if {$supplyInfos($cfg1,$layer) != $supplyInfos($cfg2,$layer)} { return 0 }
    if {$viaXRepeat($cfg1,$layer) != $viaXRepeat($cfg2,$layer)} { return 0 }
    if {$viaYRepeat($cfg1,$layer) != $viaYRepeat($cfg2,$layer)} { return 0 }
    return 1
  }

  proc is_inst_macro {instPtr} {
    global synopsys_program_name
    set isMacro 0
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set isMacro [get_attribute $instPtr is_hard_macro]
    } else {
      set cellPtr [dbInstCell $instPtr]
      if {[dbIsCellBlock $cellPtr] || \
          [dbIsCellAreaIo $cellPtr] || \
        [dbIsCellIo $cellPtr]} {
        set isMacro 1
      }
    }
    return $isMacro
  }

  proc store_macros {} {
    variable maxInstBlkLyr
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      foreach_in_collection objPtr [get_cells -quiet -hierarchical * -filter "is_hierarchical == false && (is_hard_macro == true || is_io == true) && design_type != flip_chip_pad"] {
        set instName [_inst_name $objPtr]
        if {[get_attribute $objPtr is_hard_macro] && ! [get_attribute $objPtr is_io]} {
          if {[_inst_pstatus $objPtr] == "unplaced"} {
            puts "Warning: Instance '$instName' is unplaced, skipping..."
            continue
          }
          set maxInstBlkLyr($objPtr) [agMaxBlockedLayer $objPtr]
        }
      }
    } else {
      dbForEachHeadCell [dbgHead] cellPtr {
        if {[dbCellOrigCell $cellPtr]} {
          ### This is a clone of another cell (min/max library case).
          continue
        }
        if {[dbIsCellBlackBox $cellPtr]} {
          puts "Warning: Skipping black-box cell '[dbCellName $cellPtr]'..."
          continue
        }
        if {! [dbIsCellBlock $cellPtr] && \
            ! [dbIsCellAreaIo $cellPtr] && \
          ! [dbIsCellIo $cellPtr]} {
          continue
        }
        foreach instName [dbFindInstsByCell [dbCellName $cellPtr]] {
          set instPtr [dbGetInstByName $instName]
          if {[dbInstPlacementStatus $instPtr] == "dbcUnplaced"} {
            puts "Warning: Instance '$instName' is unplaced, skipping..."
            continue
          }
          set maxInstBlkLyr($instPtr) [agMaxBlockedLayer $instPtr]
        }
      }
    }
    return [array names maxInstBlkLyr]
  }

  proc store_hinsts {} {
    variable maxHInstBlkLyr
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      foreach_in_collection hinstPtr [get_cells -quiet -hier * -filter "design_type == module"] {
        set refname [get_attribute $hinstPtr ref_name]
        if {[sizeof_collection [get_blocks -hierarchical -quiet $refname]]} {
          set maxHInstBlkLyr($hinstPtr) [agMaxBlockedLayer $hinstPtr]
        }
      }
    } else {
      dbForEachFPlanConstraint [dbCellFPlan [dbgTopCell]] FPlanConst {
        set instPtr [dbConstraintHInst $FPlanConst]
        ### Only store the fence if it has been partitioned.
        if {! [set instPtn [dbHInstPtn $instPtr]]} {continue}
        set maxHInstBlkLyr($instPtr) [agMaxBlockedLayer $instPtr]
      }
    }
    return [array names maxHInstBlkLyr]
  }

  proc macro_objects {} {
    variable maxInstBlkLyr
    return [array names maxInstBlkLyr]
  }

  proc hinst_objects {} {
    variable maxHInstBlkLyr
    return [array names maxHInstBlkLyr]
  }

  proc _find_cells_by_name {cellPat} {
    set rc ""
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      foreach_in_collection lib_cell [get_lib_cells -quiet */$cellPat] {
        lappend rc [get_object_name $lib_cell]
      }
    } else {
      lappend rc {*}[dbGet -e head.allCells.name $cellPat]
    }
    return $rc
  }

  proc _inst_name {objPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set instName [get_attribute $objPtr name]
    } else {
      set instName [dbInstName $objPtr]
    }
    return $instName
  }

  proc _inst_cell {objPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set cellName [get_attribute $objPtr ref_name]
    } else {
      set cellName [dbCellName [dbInstCell $objPtr]]
    }
    return $cellName
  }

  proc _inst_boxes {objPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set hinstBoxes [agPolyToRects [agMicronsToDBU [get_attribute $objPtr boundary]]]
    } else {
      set hinstBoxes [join [dbGet -e -d $objPtr.boxes]]
    }
    return $hinstBoxes
  }

  proc _inst_orient {instPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set orient [get_attribute $instPtr orientation]
    } else {
      set orient [string range [dbInstOrient $instPtr] 3 end]
    }
    return $orient
  }

  proc _inst_pstatus {instPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set pstatus [get_attribute $instPtr physical_status]
    } else {
      set pstatus [string tolower [string range [dbInstPlacementStatus $instPtr] 3 end]]
    }
    return $pstatus
  }

  proc _place_inst {instName instBox orient} {
    global synopsys_program_name
    foreach {llx lly urx ury} $instBox {break}
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set instPtr [get_cells $instName]
      ### Adjust inst "origin" based on orient.
      switch -exact -- $orient {
        R0 {
          set x $llx
          set y $lly
        }
        MX {
          set x $llx
          set y $ury
        }
        MY {
          set x $urx
          set y $lly
        }
        R180 {
          set x $urx
          set y $ury
        }
      }
      set_attribute $instPtr origin [list $x $y]
      set_attribute $instPtr orientation $orient
    } else {
      set x [agMicronsToDBU $llx]
      set y [agMicronsToDBU $lly]
      set instPtr [dbGetInstByName $instName]
      dbPlaceInst $instPtr $x $y dbc$orient
    }
  }

  proc head_boxes {} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set headBoxes [agPolyToRects \
          [agMicronsToDBU \
            [get_attribute -objects [current_design] -name boundary]]]
    } else {
      set headBoxes [join [dbGet -d top.fplan.boxes]]
    }
    return $headBoxes
  }

  proc _create_wire {netPtr rect layer {status {}}} {
    global synopsys_program_name
    set vert [agIsLayerVertical $layer]
    set shapePtr [list]
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set layerPtr [_get_layer_pointer $layer]
      foreach {llx lly urx ury} [agDBUToMicrons $rect] {break}
      if {$vert} {
        set width [expr {$urx-$llx}]
        set cX [expr {($urx+$llx)/2}]
        set centerPts [list \
            [list $cX $lly] \
            [list $cX $ury] \
          ]
      } else {
        set width [expr {$ury-$lly}]
        set cY [expr {($ury+$lly)/2}]
        set centerPts [list \
            [list $llx $cY] \
            [list $urx $cY] \
          ]
      }
      set shapePtr [create_shape -shape_type path \
        -layer $layerPtr \
        -shape_use stripe \
        -path $centerPts \
        -width $width \
        -net $netPtr]
      if {[sizeof_collection $shapePtr]} {
        ### Snap it to the track.
        snap_objects $shapePtr
      }
    } else {
      foreach {llx lly urx ury} [agDBUToMicrons $rect] {break}
      set shapePtr [dbCreateWire $netPtr $llx $lly $urx $ury \
          [agLayerName [agGetLayerByZ $layer]] $vert STRIPE]
      if {$shapePtr && [llength $status]} {
        dbSetStripBoxState $shapePtr $status
      }
    }
    return $shapePtr
  }

  proc _inst_halo {layer} {
    global pwrGridInstHalo
    if {[info exists pwrGridInstHalo]} {
      set spc [agMicronsToDBU $pwrGridInstHalo]
    } else {
      ### Add a min-spacing halo around the instance.
      set spc [_layer_min_space $layer]
    }
    return $spc
  }

  proc _layer_min_space {layer} {
    global synopsys_program_name
    set spc 0
    set layerPtr [_get_layer_pointer $layer]
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set spc [agMicronsToDBU [get_attribute $layerPtr min_spacing]]
      set spc [agMicronsToDBU [get_attribute -object $layerPtr -name min_spacing]]
    } else {
      set spc [dbLayerMinSpace $layerPtr]
    }
    return $spc
  }

  proc snap_coord {coord snap} {
    return [expr {int(round(1.0 * $coord / $snap) * $snap)}]
  }

  proc snap_up {coord snap {min_delta 0}} {
    ### Procedure: snap_up
    ###   This procedure snaps the coordinate "up" given the specified
    ###   snap value along with a minimum delta for snapping (i.e if it
    ###   didn't snap far enough, add another snap value).

    set newCoord [expr {int(ceil(1.0 * $coord / $snap) * $snap)}]
    if {$min_delta && [expr {$newCoord - $coord}] < $min_delta} {
      incr newCoord $snap
    }
    return $newCoord
  }

  proc snap_dn {coord snap {min_delta 0}} {
    ### Procedure: snap_dn
    ###   This procedure snaps the coordinate "down" given the specified
    ###   snap value along with a minimum delta for snapping (i.e if it
    ###   didn't snap far enough, subtract another snap value).

    set newCoord [expr {int(floor(1.0 * $coord / $snap) * $snap)}]
    if {$min_delta && [expr {$coord - $newCoord}] < $min_delta} {
      incr newCoord -$snap
    }
    return $newCoord
  }

  proc add_routes {addAreas cutAreas layerId cfg} {
    variable supplys
    variable wireRepeat
    variable wireDir
    variable supplyInfos
    if {! [llength $addAreas]} {return}

    set layerName [agLayerName [_get_layer_pointer $layerId]]
    set cfgKey $cfg,$layerName
    ### Make sure this isn't a via-only layer.
    if {! [info exists wireRepeat($cfgKey)]} {return}

    ### Split the addAreas into maximally-horizontal/vertical
    ### shapes based on the wire direction.
    if {$wireDir($cfgKey) == "h"} {
      set addAreas [_logop_or $addAreas 1]
    } else {
      set addAreas [_logop_or $addAreas 0]
    }

    ### Create the shapes that would exist over this area.
    foreach addArea $addAreas {
      foreach {allx ally aurx aury} $addArea {break}
      foreach {sllx slly surx sury} $addArea {break}
      if {$wireDir($cfgKey) == "h"} {
        set slly [snap_dn $slly $wireRepeat($cfgKey)]
        set sury [snap_up $sury $wireRepeat($cfgKey)]
      } else {
        set sllx [snap_dn $sllx $wireRepeat($cfgKey)]
        set surx [snap_up $surx $wireRepeat($cfgKey)]
      }
      foreach supply_info $supplyInfos($cfgKey) {
        foreach {supplyIdx width delta mask} $supply_info {break}
        set supply [lindex $supplys $supplyIdx]
        set wireShapes [list]
        if {$wireDir($cfgKey) == "h"} {
          ### Horizontal wire, stamp out across the height of the area.
          set llx $sllx
          set urx $surx
          for {set y $slly} {$y <= $sury} {incr y $wireRepeat($cfgKey)} {
            set lly [expr {$y + $delta - $width/2}]
            set ury [expr {$y + $delta + $width/2}]
            ### See if this shape actually fits in the original addArea or
            ### is just there because of the pattern snapping.
            if {$ury < $ally || $lly > $aury} {continue}
            lappend wireShapes [list $llx $lly $urx $ury]
          }
        } else {
          ### Vertical wire, stamp out across the width of the area.
          set lly $slly
          set ury $sury
          for {set x $sllx} {$x <= $surx} {incr x $wireRepeat($cfgKey)} {
            set llx [expr {$x + $delta - $width/2}]
            set urx [expr {$x + $delta + $width/2}]
            ### See if this shape actually fits in the original addArea or
            ### is just there because of the pattern snapping.
            if {$urx < $allx || $llx > $aurx} {continue}
            lappend wireShapes [list $llx $lly $urx $ury]
          }
        }
        if {[llength $wireShapes]} {
          ### Now cut-away the "cutAreas" from this list of shapes.
          set thresh [expr {$width/2-1}]
          set keepShapes [_logop_andnot $wireShapes $cutAreas]
          ### Get rid of any wires that aren't the full width of the
          ### rail.
          set keepShapes [_logop_size $keepShapes -$thresh]
          set keepShapes [_logop_size $keepShapes $thresh]
          foreach keepShape $keepShapes {
            add_wire $cfg $supply $keepShape $layerId $mask
          }
        }
      }
    }
  }

  proc add_vias {addAreas cutAreas viaLayerName cfg} {
    variable supplys
    variable viaXRepeat
    variable viaYRepeat
    variable supplyInfos
    if {! [llength $addAreas]} {return}

    set cfgKey $cfg,$viaLayerName
    if {! [info exists viaXRepeat($cfgKey)]} {return}

    ### Create the shapes that would exist over this area.
    ### Cut-away the "cutAreas" from this list of shapes.
    set keepShapes [_logop_andnot $addAreas $cutAreas]
    set dnLayer [_get_layer_z [agLayerInfo -down_layer $viaLayerName]]
    foreach addArea $keepShapes {
      foreach {allx ally aurx aury} $addArea {break}
      foreach {sllx slly surx sury} $addArea {break}
      set sllx [snap_dn $sllx $viaXRepeat($cfgKey)]
      set slly [snap_dn $slly $viaYRepeat($cfgKey)]
      set surx [snap_up $surx $viaXRepeat($cfgKey)]
      set sury [snap_up $sury $viaYRepeat($cfgKey)]
      set snapArea [list $sllx $slly $surx $sury]
      foreach supply_info $supplyInfos($cfgKey) {
        ### Reset the bound variables.
        foreach {sllx slly surx sury} $snapArea {break}
        foreach {supplyIdx viaName xDelta yDelta} $supply_info {break}
        set supply [lindex $supplys $supplyIdx]
        set x [expr {$sllx + $xDelta}]
        while {[expr {$surx+$xDelta}] > $aurx} {
          incr surx -$viaXRepeat($cfgKey)
          if {$surx < $sllx} {break}
        }
        incr surx $xDelta
        if {$surx < $sllx} {continue}
        set continue 0
        while {$x < $allx} {
          incr x $viaXRepeat($cfgKey)
          if {$x > $aurx} {
            set continue 1
            break
          }
        }
        if {$continue} {continue}
        set y [expr {$slly + $yDelta}]
        while {[expr {$sury+$yDelta}] > $aury} {
          incr sury -$viaYRepeat($cfgKey)
          if {$sury < $slly} {break}
        }
        incr sury $yDelta
        if {$sury < $slly} {continue}
        set continue 0
        while {$y < $ally} {
          incr y $viaYRepeat($cfgKey)
          if {$y > $aury} {
            set continue 1
            break
          }
        }
        if {$continue} {continue}
        set point [list $x $y]
        set doX [expr {($surx-$x)/$viaXRepeat($cfgKey) + 1}]
        set doY [expr {($sury-$y)/$viaYRepeat($cfgKey) + 1}]
        if {$doX > 0 && $doY > 0} {
          add_via_group $supply $dnLayer \
            $point $viaName $doX $doY \
            $viaXRepeat($cfgKey) \
            $viaYRepeat($cfgKey)
        }
      }
    }
  }

  proc remove_power_grid {} {
    variable supplys
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      foreach supply $supplys {
        set netPtr [get_nets -quiet $supply]
        if {[sizeof_collection $netPtr]} {
          remove_routes -nets $netPtr -stripe -lib_cell_pin_connect
        }
      }
    } else {
      deselectAll
      ### Make sure to only delete "ROUTED" vias and wires as the "FIXED"
      ### wires and vias are structured clocking shields.
      editSelect -nets $supplys -status ROUTED
      editDelete -selected
    }
  }

  proc create_def {} {
    global synopsys_program_name
    variable defHandle
    variable defFile /tmp/AvagoPG[pid].def.gz
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set design [get_attribute [current_design] name]
    } else {
      set design [dbgDesignName]
    }
    set defHandle [CustomDEF:Create -design $design -version 5.8 $defFile]

  }

  proc _read_def {} {
    global synopsys_program_name
    variable defHandle
    variable defFile
    CustomDEF:Close $defHandle
	#exec cp $defFile [pwd]/brcmpg.def.gz
        read_def $defFile
   }

  proc add_wire {cfg signal rect layerId {mask 0}} {
    variable defHandle
    variable signalUse
    variable wireDir
    set cmd {CustomDEF:AddRoute -signal $signal -use $use -rect [list $rect] -layer $layerId -direction $dir -special -shape STRIPE -status ROUTED $defHandle}
    set cmd2 {CustomDEF:AddRoute -signal $signal -use $use -mask $mask -rect [list $rect] -layer $layerId -direction $dir -special -shape STRIPE -status ROUTED $defHandle}
    set use $signalUse($signal)
    set rect [agDBUToMicrons $rect]
    set layer [agLayerName [agGetLayerByZ $layerId]]
    if {$wireDir($cfg,$layer) == "h"} {
      set dir "horizontal"
    } else {
      set dir "vertical"
    }
    if {[llength $mask] && $mask != 0} {
      eval [subst $cmd2]
    } else {
      eval [subst $cmd]
    }
  }

  proc add_via_group {signal layer point viac doX doY stepX stepY} {
    variable defHandle
    variable signalUse
    set cmd {CustomDEF:AddVia -signal $signal -use $use -via_cell $viac -point [list $point] -layer $layer -do_x $doX -do_y $doY -step_x $stepX -step_y $stepY -special -shape STRIPE -status ROUTED $defHandle}
    set use $signalUse($signal)
    set stepX [agDBUToMicrons $stepX]
    set stepY [agDBUToMicrons $stepY]
    set point [agDBUToMicrons $point]
    eval [subst $cmd]
  }

  #############################################################################
  ### Helper procs
  #############################################################################
  proc _find_insts {instPat} {
    global synopsys_program_name
    set results [list]
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      foreach_in_collection objPtr [get_cells -hier * -filter "name =~ $instPat"] {
        lappend results [get_attribute $objPtr name]
      }
    } else {
      set results [dbFindInstsByName $instPat]
    }
    return $results
  }

  proc _get_inst_pointer {instName} {
    global synopsys_program_name
    set results [list]
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set results [get_cells -quiet $instName]
    } else {
      set results [dbGetInstByName $instName]
    }
    return $results
  }

  proc _get_or_create_phy_net {netName pwr_gnd} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set netPtr [get_nets -quiet $netName]
      if {! [sizeof_collection $netPtr]} {
        if {$pwr_gnd} {
          set pgType power
        } else {
          set pgType ground
        }
        create_net -${pgType} $netName
        set netPtr [get_nets -quiet $netName]
      }
    } else {
      if {! [set netPtr [dbGetNetByName $netName]]} {
        addNet -physical $netName
        set netPtr [dbGetNetByName $netName]
        if {$pwr_gnd == 1} {
          dbSet $netPtr.isPwr 1
        } else {
          dbSet $netPtr.isGnd 1
        }
      }
    }
    return $netPtr
  }

  proc _get_net_pointer {netName} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set netPtr [get_nets -quiet $netName]
    } else {
      set netPtr [dbGetNetByName $netName]
    }
    return $netPtr
  }

  proc _get_net_wires {netPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set segPtrs [list]
      foreach_in_collection segPtr [get_shapes -quiet -of_objects $netPtr] {
        lappend segPtrs [get_object_name $segPtr]
      }
    } else {
      set segPtrs [dbGet -e $netPtr.sWires]
    }
    return $segPtrs
  }

  proc _get_wire_boxes {segPtr} {
    global synopsys_program_name
    set wireBoxes [list]
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set segPtr [get_shapes -quiet $segPtr]
      set coords [agMicronsToDBU [join [get_attribute $segPtr bbox]]]
      lappend wireBoxes [join $coords]
    } else {
      lappend wireBoxes [join [dbGet -d $segPtr.box]]
    }
    return $wireBoxes
  }

  proc _get_wire_layer {segPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set segPtr [get_shape -quiet $segPtr]
      set layer [_get_layer_z [get_attribute -quiet $segPtr layer]]
    } else {
      set layer [expr {[dbStripBoxZ $segPtr]-[agGetLayerExtOffset]}]
    }
    return $layer
  }

  proc _get_layer_pointer {layer} {
    if {[regexp {^\d+$} $layer]} {
      return [agGetLayerByZ $layer]
    } else {
      return [agGetLayerByExtName $layer]
    }
  }

  proc _get_layer_pitch {layerPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set pitch [agMicronsToDBU [get_attribute $layerPtr pitch]]
    } else {
      set pitch [dbLayerWirePitch $layerPtr]
    }
    return $pitch
  }

  proc _get_layer_width {layerPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set width [agMicronsToDBU [get_attribute $layerPtr min_width]]
    } else {
      set width [dbLayerWireWidth $layerPtr]
    }
    return $width
  }

  proc _get_layer_z {layerPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      if {[regexp {(metal|M)([0-9]+)} [get_attribute $layerPtr name] match mPfx layerId]} {
        set layer $layerId
      } elseif {[regexp {AP} [get_attribute $layerPtr name]]} {
        set layer [expr {[agHeadNrWireLayer]-1}]
      } else {
        error "Could not determine layer number from layer [get_attribute $layerPtr name]."
      }
    } else {
      set layer [expr {[dbGet $layerPtr.num]-[agGetLayerExtOffset]}]
    }
    return $layer
  }

  proc _get_power_pitch {cfgName layerPtr} {
    variable powerPitch
    set layerName [agLayerName $layerPtr]
    set key $cfgName,$layerName
    if {[info exists powerPitch($key)]} {
      return $powerPitch($key)
    }
    ### This is probably a via-stack layer, get the power
    ### pitch from the via-stacks.
    set viaDn [agLayerInfo -down_via_layer $layerPtr -lef_names]
    set key $cfgName,$viaDn
    if {[info exists powerPitch($key)]} {
      return $powerPitch($key)
    }
    set viaUp [agLayerInfo -up_via_layer $layerPtr -lef_names]
    set key $cfgName,$viaUp
    if {[info exists powerPitch($key)]} {
      return $powerPitch($key)
    }
    error "Power pitch is not defined for config '$cfgName' layer '$layerName'."
  }

  proc _snap_to_track {coord layerPtr} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      ### No synopsys equivalent.
      set coord $coord
    } else {
      set layerId [_get_layer_z $layerPtr]
      set coord [dbSnapCoordToTrack $coord $layerPtr [agIsLayerVertical $layerId]]
    }
    return $coord
  }

  #############################################################################
  ### Geometric Logical Operations
  #############################################################################
  proc _rects_to_collection {shapeList} {
    set rcCol [list]
    foreach shape $shapeList {
      foreach {llx lly urx ury} $shape {break}
      set shapePoly [list [list $llx $lly] [list $urx $ury]]
      append_to_collection rcCol [create_poly_rect -boundary $shapePoly]
    }
    return $rcCol
  }

  proc _poly_to_rects {poly {maximally_vertical 0}} {
    if {$maximally_vertical} {
      set hv vertical
    } else {
      set hv horizontal
    }
    set rects [split_polygons -split $hv $poly]
    set rc [list]
    foreach_in_collection rect [get_attribute $rects poly_rects] {
      lappend rc [join [get_attribute $rect bbox]]
    }
    return $rc
  }

  proc _logop_or {boxes {maximally_vertical 0}} {
    if {[llength $boxes] == 0} {return [list]}
    if {[llength $boxes] == 1} {return $boxes}
    global synopsys_program_name
    set results [list]
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set boxesCol1 [_rects_to_collection [agDBUToMicrons $boxes]]
      set poly [compute_polygons -objects1 $boxesCol1 -operation OR -objects2 $boxesCol1]
      set results [agMicronsToDBU [_poly_to_rects $poly $maximally_vertical]]
    } else {
      if {$maximally_vertical} {
        set results [dbShape -d -output rect $boxes OR $boxes]
      } else {
        set results [dbShape -d -output hrect $boxes OR $boxes]
      }
    }
    return $results
  }

  proc _logop_or2 {boxes1 boxes2 {maximally_vertical 0}} {
    if {[llength $boxes1] == 0} {
      return $boxes2
    } elseif {[llength $boxes2] == 0} {
      return $boxes1
    }
    set boxes [concat $boxes1 $boxes2]
    return [_logop_or $boxes $maximally_vertical]
  }

  proc _logop_and {boxes1 boxes2} {
    if {[llength $boxes2] == 0 || [llength $boxes1] == 0} { return "" }
    global synopsys_program_name
    set results [list]
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set boxesCol1 [_rects_to_collection [agDBUToMicrons $boxes1]]
      set boxesCol2 [_rects_to_collection [agDBUToMicrons $boxes2]]
      set poly [compute_polygons -objects1 $boxesCol1 -operation AND -objects2 $boxesCol2]
      set results [agMicronsToDBU [_poly_to_rects $poly]]
    } else {
      set results [dbShape -d $boxes1 AND $boxes2]
    }
    return $results
  }

  proc _logop_andnot {main_boxes snip_boxes} {
    if {[llength $snip_boxes] == 0} { return $main_boxes }
    if {[llength $main_boxes] == 0} {
      return [list]
    }
    global synopsys_program_name
    set results [list]
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set boxesCol1 [_rects_to_collection [agDBUToMicrons $main_boxes]]
      set boxesCol2 [_rects_to_collection [agDBUToMicrons $snip_boxes]]
      set poly [compute_polygons -objects1 $boxesCol1 -operation NOT -objects2 $boxesCol2]
      set results [agMicronsToDBU [_poly_to_rects $poly]]
    } else {
      set results [dbShape -d $main_boxes ANDNOT $snip_boxes]
    }
    return $results
  }

  proc _logop_size {boxes value} {
    if {[llength $boxes] == 0} {return [list]}
    global synopsys_program_name
    set results [list]
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set boxesCol1 [_rects_to_collection [agDBUToMicrons $boxes]]
      set value [agDBUToMicrons $value]
      set poly [resize_polygons -objects $boxesCol1 -size $value]
      set results [agMicronsToDBU [_poly_to_rects $poly]]
    } else {
      set results [dbShape -d $boxes SIZE $value]
    }
    return $results
  }
}

namespace import -force AvagoPowerGrid::add_avago_power_grid
namespace import -force AvagoPowerGrid::check_macro_snap_grid
namespace import -force AvagoPowerGrid::add_avago_clock_blockages
namespace import -force AvagoPowerGrid::remove_avago_clock_blockages

################################################################################
#
# File:         utilities.tcl
# Description:  Miscellaneous utilities.
# Author:       Jason Gentry
# Created:      Tue Sep 11 08:52:05 MDT 2012
# Modified:     $Date:$ (Jason Gentry) jason.gentry@broadcom.com
# Language:     Tcl
# Package:      N/A
# Status:       Experimental (Do Not Distribute)
#
# (C) Copyright 2012, Broadcom, all rights reserved.
#
################################################################################

proc max {args} {
  set max [lindex [join $args] 0]
  foreach ele [lrange [join $args] 1 end] {
    if {$ele>$max} {set max $ele}
  }
  return $max
}
 
proc min {args} {
  set min [lindex [join $args] 0]
  foreach ele [lrange [join $args] 1 end] {
    if {$ele<$min} {set min $ele}
  }
  return $min
}

proc whatsMyName {{back_level 0} {thru_level ""}} {
  set rc ""
  if {$thru_level == ""} {
    set level [expr {[info level] - (1 + $back_level)}]
    if {$level >= 0} {
      set rc [lindex [info level $level] 0]
    }
  } else {
    for {set i $thru_level} {$i >= $back_level} {incr i -1} {
      set level [expr {[info level] - (1 + $i)}]
      if {$level > 0} {
        append rc "[lindex [info level [expr {[info level] - (1 + $i)}]] 0]->"
      }
    }
  }
  return $rc
}

if {[info commands lunique] == ""} {
  proc lunique {list} {
    ### One-level uniquification.
    set rc [list]
    foreach part $list {
      if {[info exists seen($part)]} {continue}
      set seen($part) 1
      lappend rc $part
    }
    return $rc
  }
}

if {[info commands lexpr] == ""} {
  proc lexpr {a op b} {
    set res {}
    set la [llength $a]
    set lb [llength $b]
    if {$la == 1 && $lb == 1} {
        set res [expr $a $op $b]
    } elseif {$la==1} {
        foreach j $b {lappend res [lexpr $a $op $j]}
    } elseif {$lb==1} {
        foreach i $a {lappend res [lexpr $i $op $b]}
    } elseif {$la == $lb} {
        foreach i $a j $b {lappend res [lexpr $i $op $j]}
    } else {error "list length mismatch $la/$lb"}
    set res
  }
}

proc agDesignName {} {
  global synopsys_program_name
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    set designName [get_attribute [current_design] name]
  } elseif {[catch {dbgDesignName} designName]} {
    error "Could not determine EDA tool"
  }
  return $designName
}

proc agPolyToRects {polygon {step ""} {maximally_vertical 0}} {
  global synopsys_program_name
  if {[llength $polygon] == 0} {return [list]}
  ### step is currently not supported.
  if {$maximally_vertical} {
    set hv vertical
  } else {
    set hv horizontal
  }
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    set poly [agDBUToMicrons $polygon]
    set rects [split_polygons -split $hv $poly]
    set rc [list]
    foreach_in_collection rect [get_attribute $rects poly_rects] {
      lappend rc [join [get_attribute $rect bbox]]
    }
    set rc [agMicronsToDBU $rc]
  } else {
    if {$hv == "vertical"} {
      set rc [dbShape -d -output rect $polygon OR $polygon]
    } else {
      set rc [dbShape -d -output hrect $polygon OR $polygon]
    }
  }
  return $rc
}

proc agBoxHeight {box} {
  return [expr [lindex $box 3] - [lindex $box 1]]
}

proc agBoxWidth {box} {
  return [expr [lindex $box 2] - [lindex $box 0]]
}

proc agBoxCenter {box {microns 0}} {
  if {! $microns} {
    return [list \
        [expr int(1.0 * ([lindex $box 2] + [lindex $box 0]) / 2)] \
        [expr int(1.0 * ([lindex $box 3] + [lindex $box 1]) / 2)] \
        ]
  }
  return [list \
      [expr 1.0 * ([lindex $box 2] + [lindex $box 0]) / 2] \
      [expr 1.0 * ([lindex $box 3] + [lindex $box 1]) / 2] \
      ]
}

proc agBoxesBoundingBox {boxes} {
  foreach box $boxes {
    if {! [info exists llx] || $llx > [lindex $box 0]} {
      set llx [lindex $box 0]
    }
    if {! [info exists lly] || $lly > [lindex $box 1]} {
      set lly [lindex $box 1]
    }
    if {! [info exists urx] || $urx < [lindex $box 2]} {
      set urx [lindex $box 2]
    }
    if {! [info exists ury] || $ury < [lindex $box 3]} {
      set ury [lindex $box 3]
    }
  }
  if {[info exists llx]} {
    return [list $llx $lly $urx $ury]
  }
  return [list]
}

proc agGrowWestBoxes {boxes value} {
  ### If the value is negative we need to perform and MOVE logop
  ### and then do an AND to get the desired shape.
  ### If the value is positive we need to perform and MOVE logop
  ### and then do an OR to get the desired shape.
  ### NOTE: MOVE logops combined with AND/ANDNOT to approximate
  ### the desired SIZE operation can have unintended consequences
  ### when the desired value is larger than the box width/height.
  if {$value == 0} {return $boxes}
  set posNeg [expr {$value < 0}]
  set value [expr -$value]
  set move [dbShape -d -output rect $boxes MOVE [list $value 0]]
  if {$posNeg} {
    set result [dbShape -d -output rect $move AND $boxes]
  } else {
    set result [dbShape -d -output rect $move OR $boxes]
  }
  return $result
}

proc agGrowSouthBoxes {boxes value} {
  ### If the value is negative we need to perform and MOVE logop
  ### and then do an AND to get the desired shape.
  ### If the value is positive we need to perform and MOVE logop
  ### and then do an OR to get the desired shape.
  ### NOTE: MOVE logops combined with AND/ANDNOT to approximate
  ### the desired SIZE operation can have unintended consequences
  ### when the desired value is larger than the box width/height.
  if {$value == 0} {return $boxes}
  set posNeg [expr {$value < 0}]
  set value [expr -$value]
  set move [dbShape -d -output rect $boxes MOVE [list 0 $value]]
  if {$posNeg} {
    set result [dbShape -d -output rect $move AND $boxes]
  } else {
    set result [dbShape -d -output rect $move OR $boxes]
  }
  return $result
}

proc agGrowEastBoxes {boxes value} {
  ### If the value is negative we need to perform and MOVE logop
  ### and then do an AND to get the desired shape.
  ### If the value is positive we need to perform and MOVE logop
  ### and then do an OR to get the desired shape.
  ### NOTE: MOVE logops combined with AND/ANDNOT to approximate
  ### the desired SIZE operation can have unintended consequences
  ### when the desired value is larger than the box width/height.
  if {$value == 0} {return $boxes}
  set posNeg [expr {$value < 0}]
  set move [dbShape -d -output rect $boxes MOVE [list $value 0]]
  if {$posNeg} {
    set result [dbShape -d -output rect $move AND $boxes]
  } else {
    set result [dbShape -d -output rect $move OR $boxes]
  }
  return $result
}

proc agGrowNorthBoxes {boxes value} {
  ### If the value is negative we need to perform and MOVE logop
  ### and then do an AND to get the desired shape.
  ### If the value is positive we need to perform and MOVE logop
  ### and then do an OR to get the desired shape.
  ### NOTE: MOVE logops combined with AND/ANDNOT to approximate
  ### the desired SIZE operation can have unintended consequences
  ### when the desired value is larger than the box width/height.
  if {$value == 0} {return $boxes}
  set posNeg [expr {$value < 0}]
  set move [dbShape -d -output rect $boxes MOVE [list 0 $value]]
  if {$posNeg} {
    set result [dbShape -d -output rect $move AND $boxes]
  } else {
    set result [dbShape -d -output rect $move OR $boxes]
  }
  return $result
}

proc agTermInOutDir {termPtr {simple 0}} {
  switch -exact [dbObjType $termPtr] {
    dbcObjTerm {
      set ftermPtr [dbTermFTerm $termPtr]
    }
    dbcObjFTerm {
      set ftermPtr $termPtr
    }
    dbcObjHTerm {
      set ftermPtr [dbHTermFTerm $termPtr [dbHTermHInst $termPtr]]
    }
    default {
      error "Wrong pointer type: \"[dbObjType $termPtr]\" (should be \"dbcObjTerm\", \"dbcObjFTerm\", or \"dbcObjHTerm\") in \"[whatsMyName]\"\nUsage: [whatsMyName] <termPtr>"
    }
  }
  if {$simple} {
    return [string tolower [string range [dbFTermInOutDir $ftermPtr] 3 end]]
  }
  return [dbFTermInOutDir $ftermPtr]
}

proc agIsLayerHorizontal {layer} {
  global synopsys_program_name
  global sh_dev_null
  set layerPtr [agGetLayerByZ $layer]
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    redirect $::sh_dev_null {
      set dir [get_attribute $layerPtr -name routing_direction]
    }
    return [expr {$dir == "horizontal"}]
  } else {
    return [expr {[dbLayerPrefDir $layerPtr] == "dbcH"}]
  }
}

proc agIsLayerVertical {layer} {
  global synopsys_program_name
  global sh_dev_null
  set layerPtr [agGetLayerByZ $layer]
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    redirect $::sh_dev_null {
      set dir [get_attribute $layerPtr -name routing_direction]
    }
    return [expr {$dir == "vertical"}]
  } else {
    return [expr {[dbLayerPrefDir $layerPtr] == "dbcV"}]
  }
}

proc agMaxBlockedLayer {objPtr} {
  global synopsys_program_name
  global MaxBlockedLayerCache
  set maxLayer -1
  foreach layerName [agLayerInfo -lef_names -route_layers] {
    set layerPtr [agGetLayerByExtName $layerName]
    set layerIdMap($layerName) [agLayerWireId $layerPtr]
  }
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    ### For "current_design" query.
    set refName ""
    if {[get_attribute $objPtr object_class] == "design"} {
      set objPtr [get_blocks -quiet -of_objects $objPtr]
      set refName [get_object_name $objPtr]
      set objPtr [index_collection [get_cells -quiet -hierarchical * -filter "ref_name == $refName"] 0]
    } elseif {[get_attribute $objPtr object_class] == "cell" && \
      [get_attribute $objPtr is_hierarchical] == "true"} {
      set refName [get_attribute $objPtr ref_name]
      set objPtr [get_blocks -quiet -hierarchical $refName]
      if {! [sizeof_collection $objPtr]} {
        ### Cannot figure out max blocked layer for
        ### unpartitioned hinsts.
        return $maxLayer
      }
      set objPtr [index_collection [get_cells -quiet -hierarchical * -filter "ref_name == $refName"] 0]
    } elseif {[get_attribute $objPtr object_class] == "lib_cell"} {
      ### Grab an instance for this lib_cell.
      set refName [get_attribute $objPtr name]
      set objPtr [index_collection [get_cells -hierarchical * -filter "ref_name == $refName"] 0]
    } elseif {[get_attribute $objPtr object_class] == "block"} {
      set refName [get_object_name $objPtr]
      set objPtr [index_collection [get_cells -quiet -hierarchical * -filter "ref_name == $refName"] 0]
    } elseif {[get_attribute $objPtr object_class] == "cell"} {
      set refName [get_attribute $objPtr ref_name]
    }
    if {[info exists MaxBlockedLayerCache($refName)]} {
      return $MaxBlockedLayerCache($refName)
    }
    if {[get_attribute $objPtr object_class] == "cell"} {
      foreach layer [lunique [get_attribute [get_pins -quiet -of_objects $objPtr] layer_name]] {
        if {! [info exists layerIdMap($layer)]} {
          continue
        } elseif {$layerIdMap($layer) > $maxLayer} {
          set maxLayer $layerIdMap($layer)
        }
      }
      foreach layer [lunique [get_attribute [get_shapes -quiet -of_objects $objPtr] layer_name]] {
        if {! [info exists layerIdMap($layer)]} {
          continue
        } elseif {$layerIdMap($layer) > $maxLayer} {
          set maxLayer $layerIdMap($layer)
        }
      }
      foreach layer [lunique [get_attribute [get_routing_blockages -quiet -of_objects $objPtr] layer_name]] {
        if {! [info exists layerIdMap($layer)]} {
          continue
        } elseif {$layerIdMap($layer) > $maxLayer} {
          set maxLayer $layerIdMap($layer)
        }
      }
    } else {
      error "Unsupported object type '[get_attribute $objPtr object_class]'.  Should be 'cell', 'lib_cell', 'block' or 'design'."
    }
    set MaxBlockedLayerCache($refName) $maxLayer
  } else {
    if {[dbObjType $objPtr] == "dbcObjCell" && \
      [set ptnPtr [dbCellPtn $objPtr]]} {
      set objPtr $ptnPtr
    } elseif {[dbObjType $objPtr] == "dbcObjInst" && \
      [set ptnPtr [dbCellPtn [dbInstCell $objPtr]]]} {
      set objPtr $ptnPtr
    }
    switch -exact -- [dbObjType $objPtr] {
      "dbcObjHInst" -
      "dbcObjPtn" {
        if {[dbObjType $objPtr] == "dbcObjHInst"} {
          set ptnPtr [dbHInstPtn $objPtr]
        } else {
          set ptnPtr $objPtr
        }
        if {! $ptnPtr} {
          ### Cannot figure out max blocked layer for
          ### unpartitioned hinsts.
          return $maxLayer
          error "Cannot determine max blocked layer for unpartitioned hinsts."
        }
        for {set i [dbHeadNrWireLayer]} {$i > 0} {incr i -1} {
          if {[dbIsPtnLayerBlockedOnLayer $ptnPtr $i]} {
            set maxLayer [expr {$i-[agGetLayerExtOffset]}]
            break
          }
        }
      }
      "dbcObjCell" -
      "dbcObjInst" {
        if {[dbObjType $objPtr] == "dbcObjInst"} {
          set cellPtr [dbInstCell $objPtr]
        } else {
          set cellPtr $objPtr
        }
        set maxLayer -1
        if {$cellPtr == [dbgTopCell]} {
          ### Top-cell, can't count on power being available.
          set ptnPtr [dbCellPtn $cellPtr]
          for {set i [dbHeadNrWireLayer]} {$i > 0} {incr i -1} {
            if {[dbIsPtnLayerBlockedOnLayer $ptnPtr $i]} {
              set maxLayer [expr {$i-[agGetLayerExtOffset]}]
              break
            }
          }
        } else {
          ### Consider top-level-of-cell ports...
          dbForAllCellPGFTerm $cellPtr ftermPtr {
            dbForEachFTermLefPort $ftermPtr lefPortPtr {
              dbForEachLefPortLayerShape $lefPortPtr lShapePtr {
                set currLayer [agLayerWireId [dbLayerShapeLayer $lShapePtr]]
                if {$maxLayer < $currLayer} {
                  set maxLayer $currLayer
                }
              }
            }
          }
          ### In case this cell has no power, try regular ports...
          dbForEachCellFTerm $cellPtr ftermPtr {
            dbForEachFTermLefPort $ftermPtr lefPortPtr {
              dbForEachLefPortLayerShape $lefPortPtr lShapePtr {
                set currLayer [agLayerWireId [dbLayerShapeLayer $lShapePtr]]
                if {$maxLayer < $currLayer} {
                  set maxLayer $currLayer
                }
              }
            }
          }
          ### ...and top-level-of-cell route obstructions.
          dbForEachCellLefObs $cellPtr lShapePtr {
            set currLayer [agLayerWireId [dbLayerShapeLayer $lShapePtr]]
            if {$maxLayer < $currLayer} {
              set maxLayer $currLayer
            }
          }
        }
      }
      default {
        error "Unsupported object type '[dbObjType $objPtr]'.  Should be 'dbcObjInst', 'dbcObjPtn' or 'dbcObjHInst'."
      }
    }
  }
  return $maxLayer
}

proc agCreateRowsTracks {args} {
  global synopsys_program_name
  global env
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    ### Error out if the iccii_tracking.tcl file does not exist.
    set iccii_tracking [file join $env(INQA_ROOT) $env(ICPROCESS) inqa floorplanning iccii_tracking.tcl]
    if {! [file exists $iccii_tracking]} {
      error "ICCII tracking file '$iccii_tracking' could not be found."
    }
    uplevel #0 "source $iccii_tracking"
    return
  } else {
    set innovus_tracking [file join $env(INQA_ROOT) $env(ICPROCESS) inqa floorplanning innovus_tracking.tcl]
    if {[file exists $innovus_tracking]} {
      uplevel #0 "source $innovus_tracking"
      return
    }
  }

  ### The commands below this point are Innovus specific
  global trackMaskPattern
  global trackOffsetSpec
  global trackPitchPattern
  global rowSiteDefnOrder
  global rowSiteDefnArea
  if {[info exists trackMaskPattern]} {
    set options(-mask_pattern) $trackMaskPattern
  }
  if {[info exists trackOffsetSpec]} {
    set options(-track_offset) $trackOffsetSpec
  }
  if {[info exists trackPitchPattern]} {
    set options(-pitch_pattern) $trackPitchPattern
  }
  set options(-verbose) 0
  parse_proc_arguments -args $args options
  #if {$options(-verbose)} {informSetVerbose}

  ### Tracks
  #inform -type information -verbose "Generating tracks..."
  #inform -type format -verbose "add_tracks -honor_pitch"
  add_tracks -honor_pitch
  set track_command ""
  if {[info exists options(-mask_pattern)]} {
    #inform -type information -verbose "Adding track mask pattern ($options(-mask_pattern))..."
    set track_command "$track_command -mask_pattern \{$options(-mask_pattern)\}"
  }
  if {[info exists options(-track_offset)]} {
    #inform -type information -verbose "Adding track offset ($options(-track_offset))..."
    set track_command "$track_command -offset \{$options(-track_offset)\}"
  }
  if {[info exists options(-pitch_pattern)]} {
    #inform -type information -verbose "Adding track pitch pattern ($options(-pitch_pattern))..."
    set track_command "$track_command -pitch_pattern \{$options(-pitch_pattern)\}"
  }
  if {$track_command ne ""} {
    #inform -type format -verbose "add_tracks $track_command"
    eval add_tracks $track_command
  }

  ### Rows
  if {! [info exists options(-site_definitions)]} {
    if {! [info exists rowSiteDefnOrder]} {
      error "Must specify -site_definitions option when the variable 'rowSiteDefnOrder' is not set."
    }
    ### Do all defined site definitions.
    set options(-site_definitions) $rowSiteDefnOrder
  }
  if {[info exists options(-site_definitions)] && \
    [llength $options(-site_definitions)]} {
    #inform -type format -verbose "deleteRow -all"
    deleteRow -all
    foreach site $options(-site_definitions) {
      if {! [dbGetTechSiteByName $site]} {
        #inform -type warning "Tech site definition '$site' does not exist, skipping."
        continue
      }
      set cmd {createRow -site $site -polygon $newAreaOffsetPolygons}
      if {[info exists rowSiteDefnArea($site,area_offsets)]} {
        set areaOffs $rowSiteDefnArea($site,area_offsets)
      } else {
        set areaOffs {0 0 0 0}
      }
      foreach {no eo wo so} $areaOffs {break}
      
      set fplanBoxes {*}[dbGet top.fPlan.boxes]
      set newAreaOffsetBoxes {}
      foreach fBox $fplanBoxes {
        foreach {hllx hlly hurx hury} $fBox {
          set hllx [expr {$hllx + $wo}]
          set hlly [expr {$hlly + $so}]
          set hurx [expr {$hurx + $eo}]
          set hury [expr {$hury + $no}]
          lappend newAreaOffsetBoxes "{$hllx $hlly $hurx $hury}"
        }
        set newAreaOffsetPolygons [dbShape -output polygon $newAreaOffsetBoxes]
      }
      if {[info exists rowSiteDefnArea($site,extra_options)]} {
        append cmd " $rowSiteDefnArea($site,extra_options)"
      }
      if {[info exists rowSiteDefnArea($site,flip_first)]} {
        append cmd " $rowSiteDefnArea($site,flip_first)"
      }
      #inform -type information -verbose "Creating site row definition for site '$site'..."
      set ecmd [subst $cmd]
      #inform -type format -verbose "$ecmd"
      if {[catch {eval $ecmd} msg]} {
        #inform -type warning "Unable to create site row definition for site '$site' $msg"
      }
    }
  }
  return 1
}
define_proc_attributes agCreateRowsTracks \
  -info "Create row and track definitions." \
  -define_args { \
    {-verbose "Additional informationals" "" boolean optional} \
    {-mask_pattern "Mask pattern to use when adding tracks" maskPat list optional} \
    {-track_offset "Track offset to use when adding tracks" trkOffset list optional} \
    {-pitch_pattern "Pitch pattern to use when adding tracks" pitchPat list optional} \
    {-site_definitions "Site definitions to create rows for" siteDefns list optional} \
  }

### Layer handling.
proc agGetLayerExtOffset {} {
  global synopsys_program_name
  ### Figure out the difference between LEF layer (which can start at M0) and
  ### routing layer (which always starts at M1).  This procedure will return
  ### the offset between the LEF layer and routing layer, in other words:
  ###   LEF layer + offset == Routing Layer.
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    ### Synopsys doesn't suffer from this confusion.
    return 0
  }

  global metalLayerExtOffset
  if {! [info exists metalLayerExtOffset]} {
    ### Compute it.
    set layerId 3 ;# Somewhere in the middle, guaranteed to exist.
    foreach mPfx [list "M" "metal"] {
      set layerPtr [dbGet -p head.layers.extName ${mPfx}$layerId]
      if {$layerPtr} {break}
    }
    if {! [info exists layerPtr]} {
      error "Unable to compute LEF layer/Routing layer offset because layer '$layerId' does not exist."
    }
    set metalId [dbLayerWireId $layerPtr]
    set metalLayerExtOffset [expr {$metalId - $layerId}]
  }
  return $metalLayerExtOffset
}

proc agLayerName {layerPtr} {
  global synopsys_program_name
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    return [get_attribute $layerPtr full_name]
  } else {
    return [dbLayerLefName $layerPtr]
  }
}

proc agLayerWireId {layerPtr} {
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

proc agGetLayerByExtName {args} {
  global synopsys_program_name
  ### This proc does not attempt to convert integers to "M%d", it is
  ### a direct lookup of the extName attribute.
  set rc [list]
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    set rc [get_layers [join $args]]
  } else {
    foreach lyrName [join $args] {
      lappend rc [dbGet -p head.layers.extName $lyrName]
    }
  }
  return $rc
}

proc agGetLayerByZ {layerId} {
  global synopsys_program_name
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    if {$layerId == [expr {[agHeadNrWireLayer]-1}] && \
      [sizeof_collection [set layerPtr [get_layers -quiet "AP"]]]} {
      return $layerPtr
    }
    foreach mPfx [list "M" "metal"] {
      if {[sizeof_collection [set layerPtr [get_layers -quiet ${mPfx}$layerId]]]} {
        return $layerPtr
      }
    }
  } else {
    ### Note that the 'Z' in dbGetLayerByZ refers to routing layer but in
    ### our scripts is almost always used in reference to LEF layer id.
    set metalId [expr {$layerId + [agGetLayerExtOffset]}]
    return [dbGetLayerByZ $metalId]
  }
}

proc agHeadNrWireLayer {} {
  global synopsys_program_name
  ### Return one more than the highest metal layer in the technology.
  if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
    return [sizeof_collection [get_layers -filter "layer_type==interconnect"]]
  } else {
    return [dbHeadNrWireLayer]
  }
}

proc agLayerInfo {args} {
  global _AG_LAYER_INFO
  global synopsys_program_name
  ### _AG_LAYER_INFO
  ###   rtLayers  : All the routing layer names.
  ###   viaLayers : All the via layer names.
  ###   allLayers : All the layer names.
  ###   layerName,lyrUp : Next routing layer.
  ###   layerName,lyrDn : Prev routing layer.
  ###   layerName,viaUp : Next via layer.
  ###   layerName,viaDn : Prev via layer.

  set options(-initialize) 0
  set options(-summary) 0
  set options(-lef_names) 0
  set options(-lef_names) 0
  parse_proc_arguments -args $args options
  if {! [info exists _AG_LAYER_INFO]} {
    set options(-initialize) 1
  }
  if {$options(-initialize)} {
    unset -nocomplain _AG_LAYER_INFO
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set prvViaLyrName {}
      set prvLyrName {}
      set lyrPtrs [sort_collection [get_layers -filter "layer_type==interconnect"] mask_order]
      set viaPtrs [sort_collection [get_layers -filter "layer_type==via_cut"] mask_order]
      if {[sizeof_collection $lyrPtrs] != [expr {[sizeof_collection $viaPtrs]+1}]} {
        error "Assumed number of routing layers [sizeof_collection $lyrPtrs] would be one more than the number of via layers [sizeof_collection $viaPtrs].  Contact tools support."
      }
      for {set i 0} {$i < [sizeof_collection $lyrPtrs]} {incr i} {
        set lyrPtr [index_collection $lyrPtrs $i]
        if {$i < [sizeof_collection $viaPtrs]} {
          set viaPtr [index_collection $viaPtrs $i]
          set viaLyrName [get_attribute $viaPtr full_name]
        } else {
          set viaPtr ""
        }
        set lyrName [get_attribute $lyrPtr full_name]
        lappend _AG_LAYER_INFO(allLayers) $lyrName
        lappend _AG_LAYER_INFO(rtLayers) $lyrName
        set _AG_LAYER_INFO($lyrName,lyrDn) $prvLyrName
        set _AG_LAYER_INFO($lyrName,viaDn) $prvViaLyrName
        if {[info exists prvLyr]} {
          set _AG_LAYER_INFO($prvLyr,lyrUp) $lyrName
        }
        if {[sizeof_collection $viaPtr]} {
          lappend _AG_LAYER_INFO(viaLayers) $viaLyrName
          lappend _AG_LAYER_INFO(allLayers) $viaLyrName
          set _AG_LAYER_INFO($lyrName,viaUp) $viaLyrName
          set _AG_LAYER_INFO($prvViaLyrName,lyrUp) $lyrName
          set _AG_LAYER_INFO($viaLyrName,lyrDn) $lyrName
          set prvViaLyrName $viaLyrName
        }
        set prvLyrName $lyrName
        set prvLyr $lyrName
        incr rtLyr
      }
    } else {
      set rtLyr 1
      set prvViaLyrName {}
      set prvLyrName {}
      while {[set lyrPtr [dbGetLayerByZ $rtLyr]]} {
        set lyrName [dbLayerLefName $lyrPtr]
        lappend _AG_LAYER_INFO(allLayers) $lyrName
        lappend _AG_LAYER_INFO(rtLayers) $lyrName
        set _AG_LAYER_INFO($lyrName,lyrDn) $prvLyrName
        set _AG_LAYER_INFO($lyrName,viaDn) $prvViaLyrName
        if {[info exists prvLyr]} {
          set _AG_LAYER_INFO($prvLyr,lyrUp) $lyrName
        }
        set nxtLyr [expr {$rtLyr+1}]
        set viaLyr V${rtLyr}${nxtLyr}
        if {[set viaLyrPtr [dbGetLayerByName $viaLyr]]} {
          set viaLyrName [dbLayerLefName $viaLyrPtr]
          lappend _AG_LAYER_INFO(viaLayers) $viaLyrName
          lappend _AG_LAYER_INFO(allLayers) $viaLyrName
          set _AG_LAYER_INFO($lyrName,viaUp) $viaLyrName
          set _AG_LAYER_INFO($prvViaLyrName,lyrUp) $lyrName
          set _AG_LAYER_INFO($viaLyrName,lyrDn) $lyrName
        }
        set prvViaLyrName $viaLyrName
        set prvLyrName $lyrName
        set prvLyr $lyrName
        incr rtLyr
      }
    }
  }
  set rc [list]
  if {[info exists options(layer)]} {
    if {[info exists synopsys_program_name] && $synopsys_program_name == "fc_shell"} {
      set options(layer) [get_layers $options(layer)]
    } else {
      if {[dbObjType $options(layer)] == "dbcObjLayer"} {
        set options(layer) [agLayerName $options(layer)]
      }
    }
    set layerName [agLayerName $options(layer)]
    if {[info exists options(-down_layer)]} {
      if {[info exists _AG_LAYER_INFO($layerName,lyrDn)] && \
        [llength $_AG_LAYER_INFO($layerName,lyrDn)]} {
        lappend rc $_AG_LAYER_INFO($layerName,lyrDn)
      }
    }
    if {[info exists options(-down_via_layer)]} {
      if {[info exists _AG_LAYER_INFO($layerName,viaDn)] && \
        [llength $_AG_LAYER_INFO($layerName,viaDn)]} {
        lappend rc $_AG_LAYER_INFO($layerName,viaDn)
      }
    }
    if {[info exists options(-up_layer)]} {
      if {[info exists _AG_LAYER_INFO($layerName,lyrUp)] && \
        [llength $_AG_LAYER_INFO($layerName,lyrUp)]} {
        lappend rc $_AG_LAYER_INFO($layerName,lyrUp)
      }
    }
    if {[info exists options(-up_via_layer)]} {
      if {[info exists _AG_LAYER_INFO($layerName,viaUp)] && \
        [llength $_AG_LAYER_INFO($layerName,viaUp)]} {
        lappend rc $_AG_LAYER_INFO($layerName,viaUp)
      }
    }
  } else {
    if {[info exists options(-max_layer)]} {
      if {[info exists _AG_LAYER_INFO(rtLayers)]} {
        lappend rc [lindex $_AG_LAYER_INFO(rtLayers) end]
      }
    } 
    if {[info exists options(-min_layer)]} {
      if {[info exists _AG_LAYER_INFO(rtLayers)]} {
        lappend rc [lindex $_AG_LAYER_INFO(rtLayers) 0]
      }
    } 
    if {[info exists options(-all_layers)]} {
      if {[info exists _AG_LAYER_INFO(allLayers)]} {
        lappend rc {*}$_AG_LAYER_INFO(allLayers)
      }
    } 
    if {[info exists options(-route_layers)]} {
      if {[info exists _AG_LAYER_INFO(rtLayers)]} {
        lappend rc {*}$_AG_LAYER_INFO(rtLayers)
      }
    } 
    if {[info exists options(-via_layers)]} {
      if {[info exists _AG_LAYER_INFO(viaLayers)]} {
        lappend rc {*}$_AG_LAYER_INFO(viaLayers)
      }
    }
  }
  if {$options(-summary)} {
    if {[info exists options(layer)]} {
      set layerList [agLayerName $options(layer)]
    } else {
      set layerList [list]
      foreach layerPtr $_AG_LAYER_INFO(rtLayers) {
        lappend layerList [agLayerName $layerPtr]
      }
    }
    foreach lyrName $layerList {
      Puts "Layer: $lyrName"
      if {[info exists _AG_LAYER_INFO($lyrName,lyrDn)] && \
        $_AG_LAYER_INFO($lyrName,lyrDn)} {
        Puts "  Down Layer: [agLayerName $_AG_LAYER_INFO($lyrName,lyrDn)]"
      }
      if {[info exists _AG_LAYER_INFO($lyrName,viaDn)] && \
        $_AG_LAYER_INFO($lyrName,viaDn)} {
        Puts "  Down Via Layer: [agLayerName $_AG_LAYER_INFO($lyrName,viaDn)]"
      }
      if {[info exists _AG_LAYER_INFO($lyrName,lyrUp)] && \
        $_AG_LAYER_INFO($lyrName,lyrUp)} {
        Puts "  Up Layer: [agLayerName $_AG_LAYER_INFO($lyrName,lyrUp)]"
      }
      if {[info exists _AG_LAYER_INFO($lyrName,viaUp)] && \
        $_AG_LAYER_INFO($lyrName,viaUp)} {
        Puts "  Up Via Layer: [agLayerName $_AG_LAYER_INFO($lyrName,viaUp)]"
      }
    }
  }
  if {[llength $rc]} {
    if {$options(-lef_names)} {
      return $rc
    }
    return [agGetLayerByExtName $rc]
  }
  return
}
define_proc_attributes agLayerInfo \
  -info "LEF layer information" \
  -define_args { \
    {-initialize "Initialize layer information" "" boolean optional} \
    {-route_layers "Routing layers" "" boolean optional} \
    {-via_layers "Via layers" "" boolean optional} \
    {-all_layers "All layers" "" boolean optional} \
    {-min_layer "Miniumum routing layer" "" boolean optional} \
    {-max_layer "Maximum routing layer" "" boolean optional} \
    {-down_layer "Previous routing layer" "" boolean optional} \
    {-down_via_layer "Previous via layer" "" boolean optional} \
    {-up_layer "Next routing layer" "" boolean optional} \
    {-up_via_layer "Next via layer" "" boolean optional} \
    {-lef_names "Return LEF names instead of layer pointers" "" boolean optional} \
    {-summary "Print layer information summary" "" boolean optional} \
    {layer "The LEF layer name" "layer" string optional} \
  }

### Coordinate snapping routines
proc agMicronsToDBU {args} {
  set rc ""
  foreach arg [join $args] {
    ### Recurse on lists of lists.
    if {[llength $arg] > 1 || [lindex $arg 0] != $arg} {
      lappend rc [agMicronsToDBU $arg]
    } else {
      lappend rc [dbMicronsToDBU $arg]
    }
  }
  return $rc
}

proc agDBUToMicrons {args} {
  set rc ""
  foreach arg [join $args] {
    ### Recurse on lists of lists.
    if {[llength $arg] > 1 || [lindex $arg 0] != $arg} {
      lappend rc [agDBUToMicrons $arg]
    } else {
      lappend rc [dbDBUToMicrons $arg]
    }
  }
  return $rc
}

proc agSnapToPlaceXDBUGrid {coord {gridFactor 1}} {
  global agSnapToPlaceGridXOffset
  global agSnapToPlaceGridYOffset
  global synopsys_program_name
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
  set placeXGrid [expr {$gridFactor*$placeXGrid}]
  if {[info exists synopsys_program_name] && \
    $synopsys_program_name == "fc_shell"} {
    error "Command [whatsMyName] is not currently supported in $synopsys_program_name."
  }
  if {! [info exists agSnapToPlaceGridXOffset]} {
    ### Find the left-most, bottom-most row.  Cache for later look-up
    set siteName [dbGet $defaultSite.name]
    foreach rowPtr [dbGet -e -p2 top.fplan.rows.site.name $siteName] {
      set llx [dbGet -d $rowPtr.box_llx]
      set lly [dbGet -d $rowPtr.box_lly]
      if {! [info exists agSnapToPlaceGridXOffset] || \
        $agSnapToPlaceGridXOffset > $llx} {
        set agSnapToPlaceGridXOffset $llx
      }
      if {! [info exists agSnapToPlaceGridYOffset] || \
        $agSnapToPlaceGridYOffset > $lly} {
        set agSnapToPlaceGridYOffset $lly
      }
    }
    if {! [info exists agSnapToPlaceGridXOffset]} {
      ### Why did this fail?
      error "Unable to determine X/Y site offset (is '$siteName' not defined?)"
    }
  }
  if {$agSnapToPlaceGridXOffset == 0} {
    set snap [agSnapDBUCoord $coord $placeXGrid]
  } else {
    set snap [agSnapDBUDown $coord $placeXGrid]
    set snap [expr {$snap + $agSnapToPlaceGridXOffset}]
  }
  return $snap
}

proc agSnapToPlaceYDBUGrid {coord {gridFactor 1}} {
  global agSnapToPlaceGridXOffset
  global agSnapToPlaceGridYOffset
  global synopsys_program_name
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
  set placeYGrid [expr {$gridFactor*$placeYGrid}]
  if {[info exists synopsys_program_name] && \
    $synopsys_program_name == "fc_shell"} {
    error "Command [whatsMyName] is not currently supported in $synopsys_program_name."
  }
  set defaultSite [dbFPlanDefaultTechSite [dbCellFPlan [dbgTopCell]]]
  set placeYGrid [expr {$gridFactor*[dbSiteSizeY $defaultSite]}]
  if {! [info exists agSnapToPlaceGridXOffset]} {
    ### Find the left-most, bottom-most row.  Cache for later look-up
    set siteName [dbGet $defaultSite.name]
    foreach rowPtr [dbGet -p2 top.fplan.rows.site.name $siteName] {
      set llx [dbGet -d $rowPtr.box_llx]
      set lly [dbGet -d $rowPtr.box_lly]
      if {! [info exists agSnapToPlaceGridXOffset] || \
        $agSnapToPlaceGridXOffset > $llx} {
        set agSnapToPlaceGridXOffset $llx
      }
      if {! [info exists agSnapToPlaceGridYOffset] || \
        $agSnapToPlaceGridYOffset > $lly} {
        set agSnapToPlaceGridYOffset $lly
      }
    }
  }
  if {$agSnapToPlaceGridYOffset == 0} {
    set snap [agSnapDBUCoord $coord $placeYGrid]
  } else {
    set snap [agSnapDBUDown $coord $placeYGrid]
    set snap [expr {$snap + $agSnapToPlaceGridYOffset}]
  }
  return $snap
}

proc agSnapCoord {coord {grid ""}} {
  if {$grid == ""} {
    global defaultSnapGrid
    set grid $defaultSnapGrid
  }
  return [expr round($coord / $grid) * $grid]
}

proc agSnapDBUCoord {coord {grid ""}} {
  if {$grid == ""} {
    global defaultSnapGrid
    set grid [agMicronsToDBU $defaultSnapGrid]
  }
  return [expr {int(round(1.0 * $coord / $grid) * $grid)}]
}

proc agSnapDBUUp {coord {grid ""}} {
  if {$grid == ""} {
    global defaultSnapGrid
    set grid [agMicronsToDBU $defaultSnapGrid]
  }
  return [expr {int(ceil(1.0 * $coord / $grid) * $grid)}]
}

proc agSnapDBUDown {coord {grid ""}} {
  if {$grid == ""} {
    global defaultSnapGrid
    set grid [agMicronsToDBU $defaultSnapGrid]
  }
  return [expr {int(floor(1.0 * $coord / $grid) * $grid)}]
}

proc agSnapUp {coord {grid ""}} {
  if {$grid == ""} {
    global defaultSnapGrid
    set grid [agMicronsToDBU $defaultSnapGrid]
  } else {
    set grid [agMicronsToDBU $grid]
  }
  return [agDBUToMicrons [agSnapDBUUp [agMicronsToDBU $coord] $grid]]
}

proc agSnapDown {coord {grid ""}} {
  if {$grid == ""} {
    global defaultSnapGrid
    set grid [agMicronsToDBU $defaultSnapGrid]
  } else {
    set grid [agMicronsToDBU $grid]
  }
  return [agDBUToMicrons [agSnapDBUDown [agMicronsToDBU $coord] $grid]]
}


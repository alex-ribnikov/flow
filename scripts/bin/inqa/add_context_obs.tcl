################################################################################
#
# File:         add_context_obs.tcl
# Description:  Adds placement obstructions that emulate the placement
#               resources that context cells would occupy.
#               This Tcl script is compatible with Encounter, Innovus and ICC2.
# Author:       Daniel Woo
# Created:      Mon May 16 12:36:03 MDT 2016
# Language:     Tcl
# Package:      N/A
# Status:       Experimental (Do Not Distribute)
#
# (C) Copyright 2016, Avago Technologies, Inc., all rights reserved.
#
################################################################################

namespace eval AvagoContextObs {
  ### Proc exports.
  namespace export remove_avago_context_obs
  namespace export add_avago_context_obs

  ### Variable declarations.
  ### N/A

  ### Procedure definitions.
  proc add_avago_context_obs { } {
    global synopsys_program_name
    global DefaultMacroProximityRightLeftObs
    global DefaultMacroProximityTopBottomObs 
    global DefaultMacroRightLeftObs
    global DefaultVertBndryCellWidth
    global DefaultVertBndryCellHeight
    global DefaultBlkLRspacing

    ### Configuration check.
    if {! [info exists DefaultVertBndryCellWidth]} {
      puts "Error: Context blockage emulation has not yet been configured for this process."
      return 0
    }

    set siteWidth [lindex [_get_site_width_height] 0]

    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      #############################################################
      # Create Placement Blockages over Block edge perimeter
      set bbounds [get_attribute [current_design] boundary]
      set LR_boundary_blockage   [expr $DefaultBlkLRspacing + $DefaultVertBndryCellWidth]
      set bbounds_shrunk_place_blkg       [resize_polygons -objects $bbounds -size [list -$LR_boundary_blockage -$DefaultVertBndryCellHeight]]
      set blk_edge_keepout  [compute_polygons -operation XOR -objects1 $bbounds -objects2 $bbounds_shrunk_place_blkg]
      if {![get_attribute $blk_edge_keepout is_empty]} {
        set CNT 0
        foreach_in_collection pg [get_attribute $blk_edge_keepout poly_rects] {
          set pg_pl  [get_attribute $pg point_list]
          set CNT    [ expr $CNT + 1 ]
          set PBNAME "CONTEXT_PERIMETER_BLKG_${CNT}"
          create_placement_blockage -name  $PBNAME -type hard -boundary $pg_pl
        }
      }

      #############################################################
      # Create Placement Blockages over macros
      #set macro_context_halo_lr [expr $DefaultVertBndryCellWidth + $DefaultMacroRightLeftObs + $siteWidth]
      set macro_context_halo_lr [expr $DefaultVertBndryCellWidth + $DefaultMacroRightLeftObs]
      set macro_context_halo_tb $DefaultVertBndryCellHeight
      set macros [ get_cells -quiet -hier -filter {design_type==macro || design_type==pad || design_type==pad_spacer} ]
      if { [sizeof_collection $macros] > 0} {
        set macros_haloed [resize_polygons -objects $macros -size [list $macro_context_halo_lr $macro_context_halo_tb]]
        set macro_blockages_combined [compute_polygons -operation OR -objects1 $macros_haloed -objects2 $macros_haloed]

        # create new blockages
        foreach_in_collection PR [get_attribute $macro_blockages_combined poly_rects] {
          set PRPL [get_attribute $PR point_list]
          create_placement_blockage -type hard -boundary $PRPL
        }
      }

      ############################################
      # grab and merge placement blockages
      set context_shapes [ get_placement_blockages -quiet * ]
      if { [sizeof_collection $context_shapes] > 0 } {
        set min_gap [list $DefaultMacroProximityRightLeftObs $DefaultMacroProximityTopBottomObs]
        set grown_context_shapes [resize_polygons -objects $context_shapes -size $min_gap]
        set grown_merged_context_shapes [compute_polygons -operation OR -objects1 $grown_context_shapes -objects2 $grown_context_shapes]
        set bbounds_shrunk_min_gap [resize_polygons -objects $bbounds -size [lexpr -1 * $min_gap]]
        set cut_out [compute_polygons -operation NOT -objects1 $bbounds_shrunk_min_gap -objects2 $grown_merged_context_shapes]
        set grown_cut_out [resize_polygons -objects $cut_out -size $min_gap]
        set context_fill_shapes [compute_polygons -operation XOR -objects1 $bbounds -objects2 $grown_cut_out]
        set constrained_merged_context_shapes [compute_polygons -operation AND -objects1 $bbounds -objects2 $context_fill_shapes]
        remove_placement_blockage $context_shapes
      } else {
        set constrained_merged_context_shapes ""
      }

      if { [sizeof_collection $constrained_merged_context_shapes] > 0} {
        set CNT 0
        foreach_in_collection PR [get_attribute $constrained_merged_context_shapes poly_rects] {
          set PRPL [get_attribute $PR point_list]
          set CNT [ expr $CNT + 1 ]
          set PBNAME "CONTEXT_BLKG_${CNT}"

          create_placement_blockage -name  $PBNAME -type hard -boundary $PRPL
        }
      }
    } else {
      #############################################################
      # Create Placement Blockages over Block edge perimeter
      set bbounds [join [dbGet -d top.fplan.boxes]]
      set LR_boundary_blockage  [agMicronsToDBU [expr $DefaultBlkLRspacing + $DefaultVertBndryCellWidth]]
      set TB_boundary_blockage  [agMicronsToDBU $DefaultVertBndryCellHeight]
      set bbounds_shrunk_place_blkg [dbShape -d -output rect $bbounds SIZEX -$LR_boundary_blockage SIZEY -$TB_boundary_blockage]
      set blk_edge_keepout [dbShape -d -output rect $bbounds XOR $bbounds_shrunk_place_blkg]
      if {[llength $blk_edge_keepout]} {
        set CNT 0
        foreach shape $blk_edge_keepout {
          incr CNT
          set PBNAME "CONTEXT_PERIMETER_BLKG_${CNT}"
          createPlaceBlockage -box [agDBUToMicrons $shape] -name $PBNAME
        }
      }

      #############################################################
      # Create Placement Blockages over macros
      #set macro_context_halo_lr [expr $DefaultVertBndryCellWidth + $DefaultMacroRightLeftObs + $siteWidth]
      set macro_context_halo_lr [agMicronsToDBU [expr $DefaultVertBndryCellWidth + $DefaultMacroRightLeftObs]]
      set macro_context_halo_tb [agMicronsToDBU $DefaultVertBndryCellHeight]
      set macros [store_macros]
      if { [llength $macros] > 0} {
        set macroBoxes [list]
        foreach macroPtr $macros {
          lappend macroBoxes {*}[join [dbGet -d $macroPtr.boxes]]
        }
        set macros_haloed [dbShape -d -output rect $macroBoxes SIZEX $macro_context_halo_lr SIZEY $macro_context_halo_tb]
        set macro_blockages_combined [dbShape -d -output rect $macros_haloed OR $macros_haloed]

        # create new blockages
        foreach shape $macro_blockages_combined {
          createPlaceBlockage -box [agDBUToMicrons $shape]
        }
      }

      ############################################
      # grab and merge placement blockages
      set context_shapes [list]
      dbForEachFPlanObstruct [dbHeadFPlan] obsPtr {
        lappend context_shapes [dbObstructBox $obsPtr]
      }
      if { [llength $context_shapes] > 0 } {
        set min_gap_x [agMicronsToDBU $DefaultMacroProximityRightLeftObs]
        set min_gap_y [agMicronsToDBU $DefaultMacroProximityTopBottomObs]
        set grown_context_shapes [dbShape -d -output rect $context_shapes SIZEX $min_gap_x SIZEY $min_gap_y]
        set grown_merged_context_shapes [dbShape -d -output rect $grown_context_shapes OR $grown_context_shapes]
        set bbounds_shrunk_min_gap [dbShape -d -output rect $bbounds SIZEX -$min_gap_x SIZEY -$min_gap_y]
        set cut_out [dbShape -d -output rect $bbounds_shrunk_min_gap ANDNOT $grown_merged_context_shapes]
        set grown_cut_out [dbShape -d -output rect $cut_out SIZEX $min_gap_x SIZEY $min_gap_y]
        set context_fill_shapes [dbShape -d -output rect $bbounds XOR $grown_cut_out]
        set constrained_merged_context_shapes [dbShape -d -output rect $bbounds AND $context_fill_shapes]
        deletePlaceBlockage -all
      } else {
        set constrained_merged_context_shapes ""
      }

      if { [llength $constrained_merged_context_shapes] > 0} {
        set CNT 0
        foreach shape $constrained_merged_context_shapes {
          incr CNT
          set PBNAME "CONTEXT_BLKG_${CNT}"
          createPlaceBlockage -name $PBNAME -box [agDBUToMicrons $shape]
        }
      }
    }
  }

  proc remove_avago_context_obs { } {
    global synopsys_program_name
    puts "Warning: Deleting ALL placement and routing blockages..."
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      remove_placement_blockages -all
      remove_routing_blockages -all
    } else {
      deleteRouteBlk -all
      deletePlaceBlockage -all
    }
  }

  proc _get_site_width_height {} {
    global synopsys_program_name
    if {[info exists synopsys_program_name] && \
      $synopsys_program_name == "fc_shell"} {
      set siteDefn [index_collection [get_site_defs] 0]
      set placeXGrid [get_attribute $siteDefn width]
      set placeYGrid [get_attribute $siteDefn height]
    } else {
      set defaultSite [dbFPlanDefaultTechSite [dbCellFPlan [dbgTopCell]]]
      set placeXGrid [agDBUToMicrons [dbSiteSizeX $defaultSite]]
      set placeYGrid [agDBUToMicrons [dbSiteSizeY $defaultSite]]
    }
    return [list $placeXGrid $placeYGrid]
  }

  proc store_macros {} {
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
}

namespace import -force AvagoContextObs::add_avago_context_obs
namespace import -force AvagoContextObs::remove_avago_context_obs


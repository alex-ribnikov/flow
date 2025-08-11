###############################################################################
#
# File:         dbu_utilities.tcl
# Description:  Implements procedures for use with integer math
#               Usable by any tool (straight tcl), intended for use with tools
#               that do not natively support DBU based methods (such as ICC2)
#               Much of this is copied directly from Jason Gentry's 
#               encounter code (very little needs to be different)
# Authors:      Brett Williams
# Created:      Tue Jul 14 08:13:19 MDT 2015
# Package:      dbu_utilities
# (C) Copyright 2015, Avago Technologies, Inc., all rights reserved.
#
###############################################################################

package provide dbu_utilities 1.20

namespace eval DBUUtil {
  ### Namespace Variables:
  variable Resolution 2000 ;# Scaling factor to use

  #############################################################################
  ### DBU HELPER PROCEDURES
  #############################################################################

  # This creates the precision needed (based on resolution) to snap microns to
  # a grid that makes some kind of sense.  For now, just keep 4 decimal places
  # (this works for Resolutions of 10000 and 2000).
  proc SnapFloat {float_val} {
    set n [format "%.4f" $float_val]
    return [expr {double($n)}]
  }

  proc agMicronPerDBU {} {
    variable Resolution
    return [expr {1./$Resolution}]
  }

  proc DBUToMicrons {arg} {
    variable Resolution
    return [SnapFloat [expr { double($arg) / double($Resolution) }]]
  }

  proc MicronsToDBU {arg} {
    variable Resolution
    return [expr { int(round($arg * $Resolution)) }]
  }


  proc agDBUToMicronsList {args} {
    set rc ""
    foreach arg [join $args] {
      ### Recurse on lists of lists.
      if {[llength $arg] > 1 || [lindex $arg 0] != $arg} {
        lappend rc [agDBUToMicronsList $arg]
      } else {
        lappend rc [DBUToMicrons $arg]
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
        lappend rc [DBUToMicrons $arg]
      }
    }
    return $rc
  }
  
  proc agDBUToMicronsBox {box} {
    return [agDBUToMicrons $box]
  }
  
  proc agMicronsToDBUList {args} {
    set rc ""
    foreach arg [join $args] {
      ### Recurse on lists of lists.
      if {[llength $arg] > 1 || [lindex $arg 0] != $arg} {
        lappend rc [agMicronsToDBUList $arg]
      } else {
        lappend rc [MicronsToDBU $arg]
      }
    }
    return $rc
  }

  proc agMicronsToDBU {args} {
    set rc ""
    foreach arg [join $args] {
      ### Recurse on lists of lists.
      if {[llength $arg] > 1 || [lindex $arg 0] != $arg} {
        lappend rc [agMicronsToDBU $arg]
      } else {
        lappend rc [MicronsToDBU $arg]
      }
    }
    return $rc
  }
  
  proc agMicronsToDBUBox {box {quiet 0}} {
    if {[llength $box] != 4} {
      if {! $quiet} {
        error "[whatsMyName 1]: Box '$box' must have four coordinates (llx lly urx ury)."
      }
      error "Box arguments have incorrect coorindate specifications."
    }
    return [agMicronsToDBU $box]
  }

  namespace export ag*
}

namespace import -force DBUUtil::agMicronPerDBU
namespace import -force DBUUtil::agDBUToMicronsList
namespace import -force DBUUtil::agDBUToMicrons
namespace import -force DBUUtil::agDBUToMicronsBox
namespace import -force DBUUtil::agMicronsToDBUList
namespace import -force DBUUtil::agMicronsToDBU
namespace import -force DBUUtil::agMicronsToDBUBox

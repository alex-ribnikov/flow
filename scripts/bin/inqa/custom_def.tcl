###############################################################################
#
# File:         custom_def.tcl
# Description:  Utilities for reading/writing DEF within SoCE.
# Authors:      Jason Gentry
# Created:      Thu May 14 14:43:06 MDT 2009
# Modified:     $Date:$ (Jason Gentry) jason.gentry@avagotech.com
# Language:     Tcl
# Package:      route_utilities
# Status:       Experimental (Do Not Distribute)
#
# (C) Copyright 2009-2015, Avago Technologies, Inc., all rights reserved.
#
###############################################################################

namespace eval CustomDEF {

  namespace export CustomDEF:Create
  namespace export CustomDEF:AddPin
  namespace export CustomDEF:AddViaDefn
  namespace export CustomDEF:AddVia
  namespace export CustomDEF:AddRoute
  namespace export CustomDEF:AddInst
  namespace export CustomDEF:SetNetGNC
  namespace export CustomDEF:Close

  variable enumPinDirection
  set enumPinDirection(dbcInput) "INPUT"
  set enumPinDirection(input) "INPUT"
  set enumPinDirection(dbcOutput) "OUTPUT"
  set enumPinDirection(output) "OUTPUT"
  set enumPinDirection(dbcBidi) "INOUT"
  set enumPinDirection(inout) "INOUT"
  variable enumInstOrient
  set enumInstOrient(R0)   "N"
  set enumInstOrient(MY)   "FN"
  set enumInstOrient(R180) "S"
  set enumInstOrient(MX)   "FS"
  set enumInstOrient(R90)  "W"
  set enumInstOrient(MX90) "FW"
  set enumInstOrient(R270) "E"
  set enumInstOrient(MY90) "FE"

  ### Main access routines.

  proc CustomDEF:Create {args} {
    variable activeDEFFiles
    set options(-design) [agDesignName]
    set options(-version) 5.8
    set options(-core_area) [list]
    set options(-die_area) [list]
    parse_proc_arguments -args $args options
    if {[file extension $options(output_file)] == ".gz"} {
      set outFile [list | gzip > $options(output_file)]
    } else {
      set outFile $options(output_file)
    }

    if {[catch {open $outFile w} DEF]} { error $DEF }
    set activeDEFFiles($DEF) $options(output_file)
    def_header $DEF $options(-design) $options(-version) \
      $options(-core_area) $options(-die_area)

    return $DEF
  }
  define_proc_attributes CustomDEF:Create \
    -info "Create custom DEF objects" \
    -define_args { \
      {-design "The name of the design to use" design string optional} \
      {-version "DEF version to write (default: 5.5)" version float optional} \
      {-core_area "Core area associated with this design" coords list optional} \
      {-die_area "Die area associated with this design" coords list optional} \
      {output_file "The DEF file to create" filename string required} \
    }

  proc CustomDEF:AddPin {args} {
    variable activeDEFFiles
    variable pinInfo
    set options(-use) "SIGNAL"
    set options(-special) 0
    parse_proc_arguments -args $args options
    if {! [info exists activeDEFFiles($options(def_handle))]} {
      error "Unknown DEF file handle '$options(def_handle)'."
    }
    set shapeRect [agMicronsToDBU $options(-rect)]
    set width [agBoxWidth $shapeRect]
    set height [agBoxHeight $shapeRect]
    foreach {x y} [agBoxCenter $shapeRect] {break}
    set key $options(def_handle),$options(-name)
    if {! [info exists pinInfo($key)]} {
      set data "- $options(-name)"
    } else {
      set data "- $options(-name).extra[llength $pinInfo($key)]"
    }
    if {[info exists options(-net)]} {
      append data " + NET $options(-net)"
      if {$options(-special)} {
        append data " + SPECIAL"
      }
    }
    append data " + DIRECTION $options(-direction)"
    append data " + USE $options(-use)\n"
    set side "S"
    set llx [expr {-$width / 2}]
    set lly [expr {-$height/ 2}]
    set urx [expr {$width  / 2}]
    set ury [expr {$height / 2}]
    append data "  + LAYER [layer_lef_name $options(-layer)] ( $llx $lly ) ( $urx $ury )\n"
    append data "  + $options(-status) ( $x $y ) $side ;"
    lappend pinInfo($key) $data
  }
  define_proc_attributes CustomDEF:AddPin \
    -info "Add custom DEF object" \
    -define_args { \
      {-name "The pin name" name string required} \
      {-direction "The pin direction" direction one_of_string {required value_help {values {INPUT OUTPUT INOUT}}}} \
      {-status "The pin placement status" status one_of_string {required value_help {values {PLACED FIXED COVER}}}} \
      {-layer "The layer of the pin" layer string required} \
      {-net "The net connected to the pin" net string optional} \
      {-special "The net connected to the pin is special" "" boolean optional} \
      {-use "The pin use (default: SIGNAL)" name string optional} \
      {-rect "The pin rectangle" rect list required} \
      {def_handle "The DEF handle" handle string required} \
    }

  proc CustomDEF:AddViaDefn {args} {
    variable activeDEFFiles
    variable viaCellDefns
    parse_proc_arguments -args $args options
    if {! [info exists activeDEFFiles($options(def_handle))]} {
      error "Unknown DEF file handle '$options(def_handle)'."
    }
    set key $options(def_handle),$options(-name)
    set viaCellDefns($key) $options(-via_info)
  }
  define_proc_attributes CustomDEF:AddViaDefn \
    -info "Add custom DEF object" \
    -define_args { \
      {-name "The via name" name string required} \
      {-via_info "The via information" info list required} \
      {def_handle "The DEF handle" handle string required} \
    }

  proc CustomDEF:AddVia {args} {
    variable activeDEFFiles
    variable specialNets
    variable regularNets
    variable useNet
    set options(-special) 0
    set options(-status) "ROUTED"
    parse_proc_arguments -args $args options
    if {! [info exists activeDEFFiles($options(def_handle))]} {
      error "Unknown DEF file handle '$options(def_handle)'."
    }
    if {$options(-special) && ! [info exists options(-shape)]} {
      error "Must specify '-shape' option when using '-special' option."
    }
    set do_by_step [expr {
        [info exists options(-do_x)] + [info exists options(-do_y)] + \
          [info exists options(-step_x)] + [info exists options(-step_y)] \
        }]
    if {$do_by_step} {
      if {$do_by_step != 4} {
        error "Must specify all components of the DO ... BY ... STEP construct."
      }
      set dbs " DO $options(-do_x) BY $options(-do_y) STEP [agMicronsToDBU $options(-step_x) $options(-step_y)]"
    } else {
      set dbs ""
    }
    if {[info exists options(-use)]} {
      set useNet($options(def_handle),$options(-signal)) $options(-use)
    }
    set key $options(def_handle),$options(-signal),$options(-status)
    set point [agMicronsToDBU $options(-point)]
    #######################
    if {$options(-special)} {
      lappend specialNets($key) "[layer_lef_name $options(-layer)] 0 + SHAPE $options(-shape) ( $point ) $options(-via_cell)${dbs}"
    } else {
      lappend regularNets($key) "[layer_lef_name $options(-layer)] 0 ( $point ) $options(-via_cell)${dbs}"
    }
  }
  define_proc_attributes CustomDEF:AddVia \
    -info "Add custom DEF object" \
    -define_args { \
      {-signal "The via signal" name string required} \
      {-use "The via use (default: SIGNAL)" use string optional} \
      {-via_cell "The via cell" via_cell string required} \
      {-point "The coordinate to place the via" point list required} \
      {-layer "The layer of the pin" layer string required} \
      {-status "The status (default: ROUTED)" status one_of_string {optional value_help {values {FIXED ROUTED}}}} \
      {-shape "The via shape" shape one_of_string {optional value_help {values {STRIPE}}}} \
      {-special "The net associated with the via is special" "" boolean optional} \
      {-do_x "The DO X value of the DO BY STEP construct" do_x int optional} \
      {-do_y "The DO Y value of the DO BY STEP construct" do_y int optional} \
      {-step_x "The STEP X value of the DO BY STEP construct" step_x float optional} \
      {-step_y "The STEP Y value of the DO BY STEP construct" step_y float optional} \
      {def_handle "The DEF handle" handle string required} \
    }

  proc CustomDEF:AddRoute {args} {
    variable specialNets
    variable regularNets
    variable activeDEFFiles
    variable useNet
    set options(-special) 0
    set options(-status) "ROUTED"
    parse_proc_arguments -args $args options
    if {! [info exists activeDEFFiles($options(def_handle))]} {
      error "Unknown DEF file handle '$options(def_handle)'."
    }
    if {$options(-special) && [info exists options(-rule)]} {
      error "Cannot specify '-special' and '-rule' options together."
    }
    if {[info exists options(-rule)]} {
      error "Non-default rule wires not yet supported."
    }
    if {$options(-special) && ! [info exists options(-shape)]} {
      error "Must specify '-shape' option when using '-special' option."
    }
    if {[info exists options(-use)]} {
      set useNet($options(def_handle),$options(-signal)) $options(-use)
    }
    set key $options(def_handle),$options(-signal),$options(-status)
    set routeBox [agMicronsToDBU $options(-rect)]
    foreach {llx lly urx ury} $routeBox {break}
    if {$options(-direction) == "horizontal"} {
      set wid [agBoxHeight $routeBox]
      set lly [expr ($lly + $ury)/2]
      set ury *
    } else {
      set wid [agBoxWidth $routeBox]
      set llx [expr ($llx + $urx)/2]
      set urx *
    }
    if {[info exists options(-mask)]} {
      set mask "MASK $options(-mask) "
    } else {
      set mask ""
    }
    if {$options(-special)} {
      lappend specialNets($key) "[layer_lef_name $options(-layer)] $wid + SHAPE $options(-shape) ( $llx $lly ) ${mask}( $urx $ury )"
    } else {
      lappend regularNets($key) "[layer_lef_name $options(-layer)] $wid ( $llx $lly ) ${mask}( $urx $ury )"
    }
  }
  define_proc_attributes CustomDEF:AddRoute \
    -info "Add custom DEF object" \
    -define_args { \
      {-signal "The route signal" name string required} \
      {-use "The pin use (default: SIGNAL)" use string optional} \
      {-rule "Use the specified non-default rule" rule string optional} \
      {-rect "The rectangle associated with the route" rect list required} \
      {-layer "The layer of the route" layer string required} \
      {-mask "The mask number for the route" mask int optional} \
      {-shape "The route shape" shape one_of_string {optional value_help {values {STRIPE}}}} \
      {-direction "The route direction" shape one_of_string {required value_help {values {vertical horizontal}}}} \
      {-special "The net associated with the route is special" "" boolean optional} \
      {-status "The status (default: ROUTED)" status one_of_string {optional value_help {values {FIXED ROUTED}}}} \
      {def_handle "The DEF handle" handle string required} \
    }

  proc CustomDEF:AddInst {args} {
    variable compInfo
    variable activeDEFFiles
    variable enumInstOrient
    set options(-status) "PLACED"
    parse_proc_arguments -args $args options
    if {! [info exists activeDEFFiles($options(def_handle))]} {
      error "Unknown DEF file handle '$options(def_handle)'."
    }
    set key $options(def_handle),$options(-name)
    set placePoint [agMicronsToDBU $options(-coords)]
    foreach {llx lly} $placePoint {break}
    set cmpStr "- $options(-name) $options(-cell)"
    if {[info exists options(-source)]} {
      append cmpStr " + SOURCE $options(-source)"
    }
    append cmpStr " + $options(-status) \( $llx $lly \) $enumInstOrient($options(-orient)) ;"
    lappend compInfo($key) $cmpStr
  }
  define_proc_attributes CustomDEF:AddInst \
    -info "Add custom DEF object" \
    -define_args { \
      {-name "The instance name" name string required} \
      {-cell "The instance's reference cell name" name string required} \
      {-status "The instance placement status (default: PLACED)" status one_of_string {optional value_help {values {FIXED PLACED}}}} \
      {-coords "The llx,lly coordinates to place the instance" point list required} \
      {-source "The instance source" status one_of_string {optional value_help {values {DIST}}}} \
      {-orient "The instance orient" orient one_of_string {required value_help {values {R0 MY MX R180 R90 MX90 R270 MY90}}}} \
      {def_handle "The DEF handle" handle string required} \
    }

  proc CustomDEF:SetNetGNC {args} {
    variable activeDEFFiles
    variable gncInfo
    parse_proc_arguments -args $args options
    if {! [info exists activeDEFFiles($options(def_handle))]} {
      error "Unknown DEF file handle '$options(def_handle)'."
    }
    set key $options(def_handle),$options(-signal)
    set gncInfo($key) $options(-gnc)
  }
  define_proc_attributes CustomDEF:SetNetGNC \
    -info "Set global net connect information to net" \
    -define_args { \
      {-signal "The via signal" name string required} \
      {-gnc "The global net connect info (instance pin pairs)" gnc_info list required} \
      {def_handle "The DEF handle" handle string required} \
    }

  proc CustomDEF:Close {args} {
    ### Close out all activities.
    variable activeDEFFiles
    variable viaCellDefns
    variable pinInfo
    variable specialNets
    variable regularNets
    variable compInfo
    variable gncInfo
    variable useNet
    parse_proc_arguments -args $args options
    if {! [info exists activeDEFFiles($options(def_handle))]} {
      error "Unknown DEF file handle '$options(def_handle)'."
    }

    ### DEF Order.
    ###   VIAS
    ###   REGIONS (unsupported)
    ###   COMPONENTS
    ###   PINS
    ###   BLOCKAGES (unsupported)
    ###   SPECIALNETS
    ###   NETS
    ###   GROUPS (unsupported)

    ### VIAS (Via-Cell definitions)
    set defns [array names viaCellDefns $options(def_handle),*]
    if {[llength $defns] > 0} {
      puts $options(def_handle) "VIAS [llength $defns] ;"
      foreach key $defns {
        foreach {j1 viaCell} [split $key ,] {break}
        puts $options(def_handle) "- $viaCell"
        foreach entry $viaCellDefns($key) {
          foreach {lefLyr box} $entry {break}
          foreach {llx lly urx ury} $box {break}
          puts $options(def_handle) " + RECT $lefLyr ( $llx $lly ) ( $urx $ury )"
        }
        puts $options(def_handle) ";"
        unset viaCellDefns($key)
      }
      puts $options(def_handle) "END VIAS"
    }

    ### COMPONENTS
    set components [array names compInfo $options(def_handle),*]
    if {[llength $components] > 0} {
      puts $options(def_handle) "COMPONENTS [llength $components] ;"
      foreach key $components {
        foreach entry $compInfo($key) {
          puts $options(def_handle) $entry
        }
        unset compInfo($key)
      }
      puts $options(def_handle) "END COMPONENTS"
    }

    ### PINS
    set pins [array names pinInfo $options(def_handle),*]
    if {[llength $pins]} {
      puts $options(def_handle) "\nPINS [llength $pins] ;"
      foreach key $pins {
        foreach entry $pinInfo($key) {
          puts $options(def_handle) $entry
        }
        unset pinInfo($key)
      }
      puts $options(def_handle) "END PINS"
    }

    ### SPECIALNETS
    unset -nocomplain snetList
    foreach key [array names specialNets $options(def_handle),*] {
      foreach {j1 signal j2} [split $key ,] {break}
      set snetList($signal) 1
    }
    if {[array size snetList]} {
      puts $options(def_handle) "\nSPECIALNETS [array size snetList] ;"
      foreach signal [array names snetList] {
        set str "- $signal"
        if {[info exists gncInfo($options(def_handle),$signal)]} {
          foreach {inst pin} [join $gncInfo($options(def_handle),$signal)] {
            append str " ( $inst $pin )"
          }
        }
        puts $options(def_handle) $str
        unset -nocomplain prevStatus
        regsub -all {([][])} $signal {\\\1} sig_key
        foreach key [array names specialNets $options(def_handle),$sig_key,*] {
          foreach {j1 j2 status} [split $key ,] {break}
          if {[info exists useNet($j1,$j2)]} {
            set use "$useNet($j1,$j2)"
          } else {
            set use ""
          }
          if {! [info exists prevStatus]} { set prevStatus "UNDEF" }
          foreach entry $specialNets($key) {
            if {$prevStatus != $status} {
              set type "  + $status "
              set prevStatus $status
            } else {
              set type "    NEW "
            }
            puts $options(def_handle) ${type}${entry}
          }
          if {[llength $use]} {
            puts $options(def_handle) "  + USE $use"
          }
          unset specialNets($key)
        }
        puts $options(def_handle) " ;"
      }
      puts $options(def_handle) "END SPECIALNETS"
    }

    ### NETS
    unset -nocomplain prevStatus
    unset -nocomplain netList
    foreach key [array names regularNets $options(def_handle),*] {
      foreach {j1 signal j2} [split $key ,] {break}
      set netList($signal) 1
    }
    if {[array size netList]} {
      puts $options(def_handle) "\nNETS [array size netList] ;"
      foreach signal [array names netList] {
        set str "- $signal"
        if {[info exists gncInfo($options(def_handle),$signal)]} {
          foreach {inst pin} [join $gncInfo($options(def_handle),$signal)] {
            append str " ( $inst $pin )"
          }
        }
        puts $options(def_handle) $str
        unset -nocomplain prevStatus
        regsub -all {([][])} $signal {\\\1} sig_key
        foreach key [array names regularNets $options(def_handle),$sig_key,*] {
          foreach {j1 signal status} [split $key ,] {break}
          if {[info exists useNet($j1,$j2)]} {
            set use "$useNet($j1,$j2)"
          } else {
            set use ""
          }
          if {! [info exists prevStatus]} { set prevStatus "UNDEF" }
          foreach entry $regularNets($key) {
            if {$prevStatus != $status} {
              set type "  + $status "
              set prevStatus $status
            } else {
              set type "    NEW "
            }
            puts $options(def_handle) ${type}${entry}
          }
          if {[llength $use]} {
            puts $options(def_handle) "  + USE $use"
          }
          unset regularNets($key)
        }
        puts $options(def_handle) " ;"
      }
      puts $options(def_handle) "END NETS"
    }

    ### FOOTER
    def_footer $options(def_handle)
  }
  define_proc_attributes CustomDEF:Close \
    -info "Close out custom DEF creation" \
    -define_args { \
      {def_handle "The DEF handle" handle string required} \
    }

  ### Internal routines.
  proc def_header {fileHandle design version {coreArea ""} {dieArea ""}} {
    variable activeDEFFiles
    if {! [info exists activeDEFFiles($fileHandle)]} {
      error "Unknown DEF file handle '$fileHandle'."
    }
    puts $fileHandle "VERSION $version ;"
    if {$version < 5.6} {
      puts $fileHandle "NAMESCASESENSITIVE ON ;"
    }
    puts $fileHandle "DIVIDERCHAR \"/\" ;"
    puts $fileHandle "BUSBITCHARS \"\[\]\" ;"
    puts $fileHandle "DESIGN $design ;"
    puts $fileHandle "UNITS DISTANCE MICRONS [expr {int(1 / [dbgMicronPerDBU])}] ;"
    if {[llength $coreArea]} {
      puts $fileHandle "PROPERTYDEFINITIONS"
      puts $fileHandle "   DESIGN FE_CORE_BOX_LL_X REAL $cllx ;"
      puts $fileHandle "   DESIGN FE_CORE_BOX_LL_Y REAL $clly ;"
      puts $fileHandle "   DESIGN FE_CORE_BOX_UR_X REAL $curx ;"
      puts $fileHandle "   DESIGN FE_CORE_BOX_UR_Y REAL $cury ;"
      puts $fileHandle "END PROPERTYDEFINITIONS"
    }
    puts $fileHandle ""
    if {[llength $dieArea]} {
      foreach {llx lly urx ury} [agMicronsToDBU $dieArea] {break}
      puts $fileHandle "DIEAREA ( $llx $lly ) ( $urx $ury ) ;"
      puts $fileHandle ""
    }

  }

  proc def_footer {fileHandle {closeHandle 1}} {
    variable activeDEFFiles
    if {! [info exists activeDEFFiles($fileHandle)]} {
      error "Unknown DEF file handle '$fileHandle'."
    }
    puts $fileHandle "END DESIGN"
    close $fileHandle
    unset activeDEFFiles($fileHandle)
  }

  proc layer_lef_name {layer} {
    return [agLayerName [agGetLayerByZ $layer]]
    global synopsys_program_name
    if {[info exists synopsys_program_name] && ($synopsys_program_name == "icc2_shell" || $synopsys_program_name == "fc_shell" )} {
      set layerPtr [get_layers -quiet "metal$layer"]
      return [get_attribute $layerPtr full_name]
    } else {
      return [agLayerName [agGetLayerByZ $layer]]
    }
  }
}
### Import namespace's procedures.
set importList [list \
    CustomDEF::CustomDEF:Create \
    CustomDEF::CustomDEF:AddPin \
    CustomDEF::CustomDEF:AddViaDefn \
    CustomDEF::CustomDEF:AddVia \
    CustomDEF::CustomDEF:AddRoute \
    CustomDEF::CustomDEF:AddInst \
    CustomDEF::CustomDEF:SetNetGNC \
    CustomDEF::CustomDEF:Close \
  ]
foreach import $importList {
  if {[catch {namespace import -force $import} msg]} {
    return -code error "Failed to import $import: $msg"
  }
}

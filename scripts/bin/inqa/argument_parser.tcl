###############################################################################
#
# File:         argument_parser.tcl
# RCS:          $Header: /mnt/data/bk2git/act-utils/1.607/lib/tcl/argument_parser.in.tcl 1.16 2008/02/14 22:36:03-07:00 gentry@talyn.ftc.avagotech.net $
# Description:  TCL-based argument parser functions to define the attributes of
#               the procedure and then parse the arguments within the procedure
#               body.
# Author:       Jason Gentry
# Created:      Wed Feb 28 10:06:12 2001 
# Modified:     $Date: 2008/02/14 22:36:03-07:00 $
# Language:     Tcl
# Package:      N/A
# Status:       Experimental (Do Not Distribute)
#
# (C) Copyright 2001-2015, Avago Technologies, Inc., all rights reserved.
#
###############################################################################

package provide argument_parser 1.18

### No argument parser available.  Define our own.
namespace eval ParseArgs {
  variable procArgTypes        ;# boolean, list, string, etc.
  variable procArgOrder        ;# ordered list of arguments.
  variable procDescription     ;# description of the procedure.
  variable procArgDescriptions ;# descriptions of the procedure args.
  variable procArgRegistered   ;# if the procedure has been registered.
  variable procArgRequired     ;# required arguments.
  variable procArgOneOfString  ;# allowable strings for one_of_string.
  variable procArgStandalones  ;# standalone options.

  namespace export parse_proc_arguments
  namespace export define_proc_attributes
  namespace export print_argument_help
  namespace export usage_help
  namespace export clone_argument_definition
  namespace export registered_procedures
  namespace export registered_procedure_arguments

  ### Because we cannot call define_proc_attributes on itself,
  ### artificially create its array structure.
  set procArgRegistered(define_proc_attributes) 1
  set procArgTypes(define_proc_attributes,-info) string
  set procArgTypes(define_proc_attributes,-define_args) list
  set procArgTypes(define_proc_attributes,-command_group) string
  set procArgTypes(define_proc_attributes,-permanent) boolean
  set procArgTypes(define_proc_attributes,-hide_body) boolean
  set procArgTypes(define_proc_attributes,-hidden) boolean
  set procArgTypes(define_proc_attributes,-dont_abbrev) boolean
  set procArgTypes(define_proc_attributes,name) string
  set procArgRequired(define_proc_attributes) [list name]
  set procArgStandalones(define_proc_attributes) [list name]
  set procDescription(define_proc_attributes) "Define attributes for a procedure"
  set procArgDescriptions(define_proc_attributes,-info) [list info_text "Help string for the procedure"]
  set procArgDescriptions(define_proc_attributes,-define_args) [list arg_defs "Procedure argument definitions for verbose help"]
  set procArgDescriptions(define_proc_attributes,-command_group) [list group_name "Unsupported: Command group for procedure. Default: Procedures"]
  set procArgDescriptions(define_proc_attributes,-permanent) [list "" "Unsupported: Procedure cannot be overwritten"]
  set procArgDescriptions(define_proc_attributes,-hide_body) [list "" "Unsupported: Procedure does not show up in help or info"]
  set procArgDescriptions(define_proc_attributes,-dont_abbrev) [list "" "Unsupported: Procedure can never be abbreviated"]
  set procArgDescriptions(define_proc_attributes,name) [list name "Procedure name"]

  proc parse_proc_arguments {args} {
    ### Warning: If this proc is called a lot of times,
    ### it may cause performance (runtime) issues.
    variable procArgRegistered
    variable procArgTypes
    variable procDescription
    variable procArgDescriptions
    variable procArgRequired
    variable procArgOneOfString
    variable procArgStandalones
    set true 1
    set false 0
    set pos [lsearch -exact $args "-expand_boolean"]
    if {$pos != -1} {
      set true "true"
      set false "false"
      set args [lreplace $args $pos $pos]
    }
    set pos [lsearch -exact $args "-args"]
    if {$pos == -1} {
      error "Required argument '-args' was not found."
    } elseif {[llength $args] < 3} {
      error "Required argument 'result_array' was not found."
    } elseif {[llength $args] > 3} {
      error "extra positional option '[lindex $args 3]'."
    } else {
      set arg_array [lreplace $args $pos [expr {$pos + 1}]]
      set args [lindex $args [expr {$pos + 1}]]
    }
    upvar 1 $arg_array argArray
    if {[info exists argArray] && ! [array exists argArray]} {
      ### Make sure that if it does exist, it is atleast an array.
      unset argArray
    }
    set proc_name [lindex [info level [expr {[info level] - 1}]] 0]
    if {! [info exists procArgRegistered($proc_name)]} {
      ### Perhaps it was registered under it's namespace or maybe
      ### this proc is being profiled?
      set orig_proc $proc_name
      set trys [uplevel 1 "namespace current"]::$orig_proc
      if {[regexp {^(.*)ORIG$} $orig_proc match new_proc]} {
        lappend trys $new_proc
        lappend trys [uplevel 1 "namespace current"]::${new_proc}
        lappend trys [namespace tail $new_proc]
      }
      foreach proc_name $trys {
        if {[info exists procArgRegistered($proc_name)]} { break }
      }
      if {! [info exists procArgRegistered($proc_name)]} {
        error "No procedure arguments definition for '$orig_proc'."
      }
    }
    set idx -1
    for {set i 0} {$i < [llength $args]} {incr i} {
      ### Escape braces in case bus notation is included.
      set arg [lindex $args $i]
      if {[string compare $arg "-help"] == 0} {
        print_argument_help $proc_name
        return -code return
      }
      if {[regexp {^-[a-zA-Z0-9]} $arg]} {
        ### This argument is an option (or looks like one (i.e. -64)).
        ### If it is the -help option, print the help string and exit.
        if {[regexp {^-[0-9]+} $arg]} {
          ### This might be a standalong option.
          if {[info exists procArgTypes($proc_name,$arg)]} {
            ### Matched an option.
            set is_opt 1
          } else {
            ### Must be a standalone option.
            set is_opt 0
          }
        } else {
          set is_opt 1
          ### Search for option match (-bob =~ -bob_dole).
          if {[info exists procArgTypes($proc_name,$arg)]} {
            set possibles "$proc_name,$arg"
          } else {
            set possibles [array names procArgTypes $proc_name,${arg}*]
          }
          if {[llength $possibles] == 0} {
            error "Unknown option '$arg'" 
          } elseif {[llength $possibles] > 1} {
            foreach pos $possibles {
              if {! [info exists matches]} {
                set matches "[lindex [split $pos ,] 1]"
              } else {
                append matches ", [lindex [split $pos ,] 1]"
              }
            }
            set msg "Option '${arg}' ambiguous (possible matches: $matches)."
            error $msg
          }
          set arg [lindex [split $possibles ,] 1]
        }
      } else {
        ### Must be a standalone option.
        set is_opt 0
      }
      if {$is_opt} {
        set key $arg
      } else {
        if {! [info exists procArgStandalones($proc_name)]} {
          error "Extra positional option '$arg'"
        }
        set key [lindex $procArgStandalones($proc_name) [incr idx]]
        if {$key == ""} {
          error "Extra positional option '$arg'"
        }
      }
      set type $procArgTypes($proc_name,$key)
      if {[string compare $type "boolean"] == 0} {
        set argArray($key) $true
        continue
      }
      ### All other options (unless standalone) require that we get
      ### the next value.
      if {$is_opt} {
        set arg [lindex $args [incr i]]
        ### Check for option requiring a value but used at the end
        ### of the option string (i.e. missing its value.
        if {$i == [llength $args]} {
          error "Required value for option '$key' was not found."
        }
      }
      if {[string compare $type "string"] == 0} {
        ### String and list need not be checked...
      } elseif {[string compare $type "list"] == 0} {
        ### String and list need not be checked...
      } elseif {[string compare $type "one_of_string"] == 0} {
        ### Look through the available values.
        if {[info exists procArgOneOfString($proc_name,$key)]} {
          if {[lsearch -exact $procArgOneOfString($proc_name,$key) $arg] == -1} {
            error "value '$arg' for option '$key' is not valid.  Specify one of: $procArgOneOfString($proc_name,$key)"
          }
        }
      } elseif {[string compare $type "float"] == 0} {
        if {! [string is double $arg]} {
          error "Value '$arg' for option '$key' not of type '$type'" 
        }
      } elseif {[string compare $type "int"] == 0} {
        if {! [string is integer $arg]} {
          error "Value '$arg' for option '$key' not of type '$type'" 
        }
      } else {
        error "Value '$arg' for option '$key' not of type '$type'" 
      }
      set argArray($key) $arg
    }
    ### Check for required options.
    if {[info exists procArgRequired($proc_name)]} {
      foreach opt $procArgRequired($proc_name) {
        if {! [info exists argArray($opt)]} {
          error "Required argument '$opt' was not found."
        }
      }
    }
  }

  proc define_proc_attributes {args} {
    variable procArgRegistered
    variable procArgOrder
    variable procArgTypes
    variable procDescription
    variable procArgDescriptions
    variable procArgRequired
    variable procArgOneOfString
    variable procArgStandalones
    ### Format:
    ### define_proc_attributes command \
    ###    -info "What this command does" \
    ###    -define_args {
    ###      {-arg1 "arg1 description" "" boolean optional}
    ###      {-arg2 "arg2 description" arg2_name string optional}
    ###      {-arg3 "arg3 description" arg3_name int required}
    ###      {standalone "standalone description" name string required}
    ###    }

    parse_proc_arguments -args $args results

    ### Clear the old...
    set procArgRegistered($results(name)) 1
    foreach element [array names procArgTypes $results(name),*] {
      unset procArgTypes($element)
    }
    foreach element [array names procArgOrder $results(name)] {
      unset procArgOrder($element)
    }
    foreach element [array names procDescription $results(name)] {
      unset procDescription($element)
    }
    foreach element [array names procArgDescriptions $results(name),*] {
      unset procArgDescriptions($element)
    }
    if {[info exists procArgRequired($results(name))]} {
      unset procArgRequired($results(name))
    }
    if {[info exists procArgOneOfString($results(name))]} {
      unset procArgOneOfString($results(name))
    }
    if {[info exists procArgStandalones($results(name))]} {
      unset procArgStandalones($results(name))
    }

    if {[info exists results(-info)]} {
      set procDescription($results(name)) $results(-info)
    } else {
      set procDescription($results(name)) "Procedure"
    }
    set allowable_types [list boolean string one_of_string list int float]
    if {! [info exists results(-define_args)]} {
      return
    }
    set args $results(-define_args)
    foreach arg_type $args {
      if {[llength $arg_type] == 3} {
        ### Old style.
        set argIdx 0
        set infoIdx 3
        set nameIdx 1
        set typeIdx 1
        set reqIdx 2
      } elseif {[llength $arg_type] == 4} {
        ### Old style.
        set argIdx 0
        set infoIdx 1
        set nameIdx 2
        set typeIdx 2
        set reqIdx 3
      } elseif {[llength $arg_type] == 5} {
        set argIdx 0
        set infoIdx 1
        set nameIdx 2
        set typeIdx 3
        set reqIdx 4
      } else {
        error "Unknown syntax in arg definitions."
      }
      set arg [lindex $arg_type $argIdx]
      if {[regexp {^-} $arg] == 1} {
        set is_option 1
      } else {
        set is_option 0
      }
      set type [lindex $arg_type $typeIdx]
      set name [lindex $arg_type $nameIdx]
      set req_opt [lindex [lindex $arg_type $reqIdx] 0]
      if {[string compare $type "one_of_string"] == 0} {
        if {[string compare [lindex [lindex $arg_type $reqIdx] 1] "value_help"] != 0} {
          error "Required value_help must be defined for $type."
        }
        set procArgOneOfString($results(name),$arg) [lindex [lindex \
          [lindex $arg_type $reqIdx] 2] 1]
      }
      if {[string compare $req_opt "required"] == 0} {
        lappend procArgRequired($results(name)) $arg
      } elseif {[string compare $req_opt "optional"] == 0} {
        ### Nothing.
      } else {
        error "Specified optional or required term '$req_opt' is unknown."
      }
      if {[lsearch -exact $allowable_types $type] == -1} {
        error "Specified argument type '$type' is unsupported."
      }
      lappend procArgOrder($results(name)) $arg
      if {! $is_option} {
        set procArgTypes($results(name),$arg) $type
        lappend procArgStandalones($results(name)) $arg
      } else {
        set procArgTypes($results(name),$arg) $type
      }
      set infoStr [lindex $arg_type $infoIdx]
      set procArgDescriptions($results(name),$arg) [list $name $infoStr]
    }
  }

  proc registered_procedures {{proc_name "*"}} {
    variable procArgRegistered
    return [array names procArgRegistered $proc_name]
  }

  proc registered_procedure_arguments {proc_name} {
    variable procArgRegistered
    variable procArgDescriptions
    variable procArgStandalones
    if {! [info exists procArgRegistered($proc_name)]} {
      return [info args $proc]
    }
    set rc ""
    foreach key [array names procArgDescriptions $proc_name,*] {
      set opt [lindex [split $key ,] 1]
      if {! [regexp {^-} $opt]} {
        ### Standalones will be added later.
        continue
      }
      lappend rc $opt
    }
    if {[info exists procArgStandalones($proc_name)]} {
      foreach standalone $procArgStandalones($proc_name) {
        lappend rc $standalone
      }
    }
    return $rc
  }

  proc clone_argument_definition {orig new} {
    variable procArgRegistered
    variable procArgTypes
    variable procArgOrder
    variable procDescription
    variable procArgDescriptions
    variable procArgRequired
    variable procArgOneOfString
    variable procArgStandalones
    set ars [list procArgTypes \
        procArgOrder \
        procDescription \
        procArgDescriptions \
        procArgRegistered \
        procArgRequired \
        procArgOneOfString \
        procArgStandalones]
    foreach ar $ars {
      upvar 0 $ar array
      foreach {key val} [array get array ${orig}*] {
        regsub $orig $key $new destkey
        set array($destkey) $val
      }
    }
  }

  proc print_argument_help {pattern {short 0} {podFile ""}} {
    variable procArgRegistered
    variable procArgTypes
    variable procArgOrder
    variable procDescription
    variable procArgDescriptions
    variable procArgRequired
    variable procArgOneOfString
    variable procArgStandalones
    if {$podFile != ""} {
      if {[catch {open $podFile w} POD]} {
        error $POD
      }
      set podUsage ""
    }
    foreach proc_name [uplevel #0 "info procs $pattern"] {
      if {! [info exists procArgRegistered($proc_name)]} {
        ### Just print out arg structure.
        set arg_string ""
        foreach arg [info args $proc_name] {
          if {[info default $proc_name $arg argVal]} {
            lappend arg_string [list $arg $argVal]
          } else {
            lappend arg_string $arg
          }
        }
        if {[info exists POD]} {
          pod_header $proc_name $arg_string $POD
          pod_misc $proc_name [file dirname $podFile] $POD
        } else {
          puts " [format %-25s $proc_name] $arg_string"
        }
        continue
      }
      if {[info exists procArgOrder($proc_name)]} {
        foreach arg $procArgOrder($proc_name) {
          set key ${proc_name},${arg}
          set name_desc $procArgDescriptions($key)
          set name [lindex $name_desc 0]
          set desc [lindex $name_desc 1]
          set argName($arg) "$name"
          if {[string compare $procArgTypes($key) "one_of_string"] == 0} {
            append desc ":  Values: $procArgOneOfString($key)"
          }
          set argDesc($arg) "([join $desc])"
        }
      }
      if {[info exists POD]} {
        pod_header $proc_name $procDescription($proc_name) $POD
      } else {
        set chop [chopString $procDescription($proc_name) 50 50]
        set pieces [split $chop "\n"]
        puts " [format %-25s $proc_name] # [lindex $pieces 0]"
      }
      set idx [expr {[string length $proc_name] < 25 ? 25 : [string \
        length $proc_name]}]
      if {! [info exists POD]} {
        for {set i 1} {$i < [llength $pieces]} {incr i} {
          puts " [format %-*s $idx " "] # [lindex $pieces $i]"
        }
      }
      if {$short} { continue }
      if {[info exists procArgOrder($proc_name)]} {
        set options $procArgOrder($proc_name)
      } else {
        set options ""
      }
      #set elements [lsort -command option_sort \
          #[array names procArgDescriptions $proc_name,*] \
          #]
      foreach option $options {
        set key ${proc_name},${option}
        if {! [info exists argDesc($option)]} {
          set argDesc($option) ""
        }
        set chop [chopString $argDesc($option) 45 45]
        set pieces [split $chop "\n"]
        if {! [info exists procArgRequired($proc_name)] || \
          [lsearch -exact $procArgRequired($proc_name) $option] == -1} {
          set req 0
        } else {
          set req 1
        }
        set is_option [regexp {^-[a-zA-Z]} $option]
        set type $procArgTypes($key)
        set name $argName($option)
        if {! $is_option || [string compare $type "boolean"] == 0} {
          if {$req} {
            set foption $option
          } else {
            set foption "\[$option\]"
          }
          if {[info exists POD]} {
            append podUsage "\n [format {   %-26s %s} $foption $argDesc($option)]"
          } else {
            puts [format {   %-26s %s} $foption [lindex $pieces 0]]
          }
        } else {
          if {$req} {
            set foption "$option $name"
          } else {
            set foption "\[$option $name\]"
          }
          if {[info exists POD]} {
            append podUsage "\n [format {   %-26s %s} $foption $argDesc($option)]"
          } else {
            puts [format {   %-26s %s} $foption [lindex $pieces 0]]
          }
        }
        if {! [info exists POD]} {
          for {set i 1} {$i < [llength $pieces]} {incr i} {
            puts " [format %-26s " "]    [lindex $pieces $i]"
          }
        }
      }
      if {[info exists POD]} {
        if {$podUsage != ""} {
          pod_usage $proc_name $POD $podUsage
        }
        pod_misc $proc_name [file dirname $podFile] $POD
      }
    }
    if {$podFile != ""} {
      pod_footer $POD
      close $POD
    }
  }

  proc pod_header {procname procdesc POD} {
    puts $POD "###$procname manual page###"
    puts $POD ""
    puts $POD "=head1 NAME"
    puts $POD ""
    puts $POD "[format %-25s $procname] - $procdesc"
    puts $POD ""
  }

  proc pod_usage {procname POD args} {
    puts $POD "=head1 SYNOPSIS"
    puts $POD ""
    puts $POD "$procname"
    puts $POD ""
    puts $POD "=over 6"
    puts $POD "[join $args]"
    puts $POD ""
    puts $POD "=back 6"
    puts $POD ""
  }

  proc pod_misc {procname searchpath POD} {
    set podFile [file join $searchpath $procname.in.pod]
    if {[file readable $podFile]} {
      set IPOD [open $podFile r]
      while {[gets $IPOD line] >= 0} {
        puts $POD $line
      }
      close $IPOD
    }
  }

  proc pod_footer {POD} {
    global env
    if {[info exists env(USER)]} {
      puts $POD "Manpage created by $env(USER) on [exec date]"
    } else {
      puts $POD "Manpage created on [exec date]"
    }
    puts $POD ""
    puts $POD "=cut"
  }

  proc pod_doc {podDir args} {
    if {! [file isdirectory $podDir]} {
      error "Destination pod directory '$podDir' does not exist."
    }
    foreach procPat [join $args] {
      foreach procname [uplevel #0 "info procs $procPat"] {
        puts "Processing procedure '$procname'..."
        set podFile [file join $podDir ${procname}.pod]
        print_argument_help $procname 0 $podFile
      }
    }
  }

  proc option_sort {key1 key2} {
    variable procArgRequired
    variable procArgStandalones
    foreach {proc_name opt1} [split $key1 ,] {break}
    foreach {proc_name opt2} [split $key2 ,] {break}
    set saopts ""
    set reqopts ""
    if {[info exists procArgStandalones($proc_name)]} {
      set saopts $procArgStandalones($proc_name)
    }
    set pos1 [lsearch -exact $saopts $opt1]
    set pos2 [lsearch -exact $saopts $opt2]
    if {$pos1 != -1 && $pos2 != -1} {
      ### Both are standalone options.
      return [expr $pos1 > $pos2]
    }
    if {$pos1 != -1} {
      ### Opt 1 is standalone.
      return 1
    }
    if {$pos2 != -1} {
      ### Opt 2 is standalone.
      return -1
    }
    if {[info exists procArgRequired($proc_name)]} {
      set reqopts $procArgRequired($proc_name)
    }
    set pos1 [lsearch -exact $reqopts $opt1]
    set pos2 [lsearch -exact $reqopts $opt2]
    if {$pos1 != -1 && $pos2 != -1} {
      ### Both are required options.
      return [expr $pos1 > $pos2]
    }
    if {$pos1 != -1} {
      ### Opt 1 is required.
      return 1
    }
    if {$pos2 != -1} {
      ### Opt 2 is required.
      return -1
    }
    return 0
  }

  proc chopString {message {min 50} {max 75}} {
    set formatted_message ""
    regsub -all {[ ]{2,}} $message " " message
    regsub -all {([{}])} $message {\\\1} message
    set paragraphs [split $message \n]
    set first 1
    foreach paragraph $paragraphs {
      set accumulator 0
      if {$first} {
        set first 0
      } else {
        lappend formatted_message "\n\n"
      }
      foreach word [split $paragraph] {
        set length [expr {[string length $word] + 1}]
        set pre ""
        if {([expr {$length + $accumulator}] > $max)} {
          ### Put the long word on the next line.
          set accumulator $length
          set pre "\n"
        } elseif {($accumulator >= $min)} {
          set accumulator 0
          set pre "\n"
        } else {
          incr accumulator $length
        }
        lappend formatted_message "$pre$word"
      }
    }
    set formatted_message [join $formatted_message]
    return $formatted_message
  }

  proc usage_help {args} {
    set pattern *
    set verbose 0
    parse_proc_arguments -args $args results
    if {[info exists results]} {
      foreach argname [array names results] {
        switch -exact -- $argname {
          -verbose {
            set verbose 1
          }
          pattern {
            set pattern $results($argname)
          }
        }
      }
    }
    set matches [info commands $pattern]
    if {[llength $matches] == 0} {
      puts "Information: No commands matched '$pattern'."
    } else {
      foreach match $matches {
        if {$verbose} {
          puts [print_argument_help $match]
        } else {
          puts [print_argument_help $match 1]
        }
      }
    }
  }
  define_proc_attributes usage_help \
    -info "Display quick help for one or more commands." \
    -define_args {
    {-verbose "Display options like -help" "" boolean optional} \
      {pattern "Display commands matching pattern" pattern string optional} \
    }
}

catch {
  namespace import ParseArgs::parse_proc_arguments
  namespace import ParseArgs::define_proc_attributes
  namespace import ParseArgs::print_argument_help
  namespace import ParseArgs::clone_argument_definition
  namespace import ParseArgs::registered_procedures
  namespace import ParseArgs::registered_procedure_arguments
  namespace import ParseArgs::usage_help
}

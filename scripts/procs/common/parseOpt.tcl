#####################################################
#
# Package defintion for:
#     parseOpt
#
# The following package parseOpt a given args for a procedure.
# 
#  Procedures:
#     ::parseOpt::cmdSpec - Define a spec for a command
#     ::parseOpt::parseOpt - Parse args for a given command
#
#


######################################################
#
# Example of usage:
# Let say I write a procedure called testProc that
#   get 3 options:
#     -cell <cell name>      : String that define the cell name
#     -action <action name>  : String that define the action to do on the cell
#     -all                   : Flag that say - do the action on all cells.
#
# 1. First I will include the new parseOpt package:
#       package require parseOpt 1.0
#       namespace import ::parseOpt::cmdSpec ::parseOpt::parseOpt
# 2. Create a spec for the procedure:
#       cmdSpec testProc {
#         -help "(Any help message for the procedure can be writen here) The procedire perform action on cell"
#         -opt {
#           {-optname cell   -type string -default "" -required 0 -help "Define the cell name"}
#           {-optname action -type string -default "" -required 1 -help "Define the action name"}
#           {-optname all    -type bool   -default 0  -required 0 -help "Define whether to work on all cells"}
#         }
#       }
#    Note:
#      The opt internal list define the rpocedure different option.
#       -optname <Option name in the procedure switch>
#       -type    <string/int/float/bool/ebool/list/one_of_string> - Incase of string, it will be init with an empty string unless the user define else.
#                                     In case of bool the default will be set and if the user will use the procedure with 
#                                       the given switch, the value will be negate.
#                                     In case of list - empty list will be used unless ...
#                                     In case one_of_string - String selection from value list
#       -required <0/1>  - If set to 1 than this option will be must during option parsing.
#       -default <default value> - Define a new default value.
#       -help  <Help message for option> 
#       -values <List of valid value list for usage with one_of_string>
# 3. Usage inside the procedure
#         proc testProc {args} {
#           # If parsing have failed - exist
#           if { ![parseOpt testProc $args] } { return 0 }
#           puts "-I- User info: "
#           puts "-I- Cell: $opt(-cell)"
#           puts "-I- Action: $opt(-action)"
#           puts "-I- All: $opt(-all)"
#         }

package provide parseOpt 7.0
# Loading GUI elements
set bin [file dirname [info script]]

namespace eval ::parseOpt {
    # The following veriable will hold all procedure info
    variable procInfo
    array set procInfo {}

    variable bin 
    set bin [file dirname [info script]]

    variable level0ProcDef
    set level0ProcDef {}

    variable parseOptPath
    set parseOptPath [file dirname [info script]]
    
    variable validOptTypes
    set validOptTypes [list bool \
                           ebool \
                           string \
                           list \
                           int \
                           float \
                           file \
                           directory \
                           one_of_string \
                           point \
                           bbox \
                           lib_cell \
                           lib_pin \
                           cell \
                           port \
                           pin \
                           pin_port \
                           net ]

    variable validArgTypes
    set validArgTypes [list \
                           string \
                           list \
                           int \
                           float \
                           file \
                           directory \
                           one_of_string \
                           point \
                           bbox \
                           lib_cell \
                           lib_pin \
                           cell \
                           port \
                           pin \
                           pin_port \
                           net ]

    

    ##############################
    # In order to make procedure visible
    namespace export parseOpt parseOpts cmdSpec redefine_proc_attributes CmdSpec 
}




#####################################
#
# Proc: cmdSpec
#
# Define the wanted stwitches and default
# value for the given procedure
#
# Arg sturcture: 
#   procedure_name {
#     -help "Help message"
#     -opt {
#       {-type <type> -optname <option name> -default <default value> -required <0/1 must ot not option> -help <help message>}
#     }
#     -default {defaultVariable ...}
#   }  
#
# Example:
#   my_proc {
#     -help "Help message for my proc"
#     -opt {
#        {-type string -optname "cell" -default "" -required 0 -help "Cell name to work on"}
#        {-type string -optname "cell" -default_from_pg "<param name>" -required 0 -help "Cell name to work on"}
#     }
#     -default {fubName1 fubName2}   # This is not must to be define - but if it have been define than it become must variable
#   }
#
# The valid types and values are:
#   string - Must start and end with the sign ". Only a single string can be given.
#            Default: empty string.
#   file   - File name (same as string )
#   directory - Directory name (same as string)
#   list   - Must start and end with {}. 
#            Default: emtpy list.
#   int    - Must be an integer number
#   float  - Must be a number
#   bool   - Can be set to 0 or 1. No value is given after flag that is a bool type.
#            Default: 0.  If user use it - it change its value.
#            If other default is define using command spec (default = 1) than using this flag will negeta the value.
#   ebool  - like bool but actually requires a value, (on/true => 1, off/false => 0)
#   selection - A list of valid values that can be specified. (If using such a type - a default value must be set.
#
#
#####################################
# This is only wrapper over cmdSpec - in order to enable more clean move to convagre flow with JKT
proc ::parseOpt::CmdSpec {args} {
    #echo "-D- warpper of FM ::parseOpt::cmdSpec $args"
    eval ::parseOpt::cmdSpec $args
}


proc ::parseOpt::cmdSpec {args} {
    
    # Getting procedure full name
    set procName [::parseOpt::varPop args]

    array set procInfo [::parseOpt::varPop args]
    
    # Checking if the following command have been already define.
    # If so - remove the old info
    if { [info exists ::parseOpt::procInfo($procName:Init)] } { 
        global PARSEOPT_QUIET_MODE
        if { [info exists  PARSEOPT_QUIET_MODE] && $PARSEOPT_QUIET_MODE } {
        } else {
            puts "-W- parseOpt::cmdSpec : The following command have been already defined, override the following command. ($procName)"
        }
        unset ::parseOpt::procInfo($procName:Init)
        unset ::parseOpt::procInfo($procName:Help)
        unset ::parseOpt::procInfo($procName:Title)
        unset ::parseOpt::procInfo($procName:Opt)
        unset ::parseOpt::procInfo($procName:Default)
    }

    # Setting a flag to define the procedure name have been already use (for next call)
    set ::parseOpt::procInfo($procName:Init) 1
    set ::parseOpt::procInfo($procName:Help) ""
    set ::parseOpt::procInfo($procName:Title) ""
    set ::parseOpt::procInfo($procName:Opt) {}
    set ::parseOpt::procInfo($procName:Default) {}
    set ::parseOpt::procInfo($procName:Opt:optList) {}
    set ::parseOpt::procInfo($procName:Opt:argList) {}


    # Setting default as array - to save run time during initialization of parseOpt
    set ::parseOpt::procInfo($procName:Opt:defaultArray) {}
    set ::parseOpt::procInfo($procName:Opt:noDefault) {}


    
    # Genral data
    set validOpt {"optname" "type" "default" "default_from_pg" "help" "required" "values" "filter" "singel_selection" "radio_grp" "hidden" "validate_cmd" "get_one_of_string_cmd" "win_type" "qualifiers" }

    # Getting all info of procedure
    # Goning over the input array and parsing it
    foreach obj [array names procInfo] { 
        if { [regexp -nocase {\-help} $obj] } {
            # The element is Help
            set ::parseOpt::procInfo($procName:Help) $procInfo($obj)
        } elseif { [regexp -nocase {\-title} $obj] } {
            set ::parseOpt::procInfo($procName:Title) $procInfo($obj)
        } elseif { [regexp -nocase {\-opt} $obj] || [regexp -nocase {\-arg} $obj] } {
            # The elemnt is opt
            set ::parseOpt::procInfo($procName:Opt) $procInfo($obj)
            
            # Internal type.
            #   Can be argument or option.
            set IntType "option"
            if { [regexp -nocase {\-arg} $obj] } {
                set IntType "argument"
            }

            
            # Parsing opt for detail info
            # Going over the list of options
            foreach option $procInfo($obj) {
                # For each list - get all its info
                set optname ""
                set default ""
                set default_from_pg ""
                set type ""
                set selection_values {}
                set help ""
                set required 0
                set singel_selection 0
                set radio_grp ""
                set hidden 0
                set values [list ]
                set filter [list ]
                set validate_cmd [list ]
                set get_one_of_string_cmd [list ]
                set win_type "combobox"    ; # Currently it will be used only by one_of_string - values are : combobox , radiobox and listbox
                set qualifiers ""

                set default_set 0
                
                #foreach option_opt [split $option "-"] {}
                while { [llength $option] > 0 } {
                    set option_name_full [::parseOpt::varPop option]
                    regsub {^\-} $option_name_full {} option_name
                    
                    # Ignore epmty variables
                    if { [regexp {^[[:space:]]*$} $option_name] } { continue }
                    
                    # Checking that this is a valid option
                    if { [lsearch -exact $validOpt $option_name] < 0 } { 
                        puts "-E- parseOpt::cmdSpec : Unknown option type: $option_name (Valid option are: $validOpt)"
                        return 0  
                    }
                    
                    set value [::parseOpt::varPop option]
                    set $option_name $value
                    
                    if { $option_name == "default" } { set default_set 1 }
                }
                
                # If it is qualifiers - map it to one of string
                if { [llength $qualifiers] } {
                    set type "one_of_string"
                    foreach k $qualifiers { if { ![regexp {\-radio} $k] } { set values $k } }
                }

                # Checking that there is a valid option type
                if { $optname == "" } {
                    puts "-E- parseOpt::cmdSpec : Error parsing options, empty option have been found in option name."
                    return -code error "-E- parseOpt::cmdSpec : Error parsing options, empty option have been found in option name."
                }

                if { [expr {[lsearch -exact $::parseOpt::procInfo($procName:Opt:optList) $optname] >= 0}] } {
                    puts "-E- parseOpt::cmdSpec : Error parsing options, double declaration of option name: $optname"
                    return -code error "-E- parseOpt::cmdSpec : Error parsing options, double declaration of option name: $optname"
                }

                
                # Checking that there is a valid option name
                if { $type == "" } {
                    puts "-E- parseOpt::cmdSpec : Unable to find option type for \"$optname\", assuming type string"
                    set type "string"
                }


                # Checking that type is one of the valid types
                #                if { ![regexp {bool} $type] && ![regexp {string} $type] && ![regexp {list} $type] } {
                #                    puts "-E- parseOpt::cmdSpec : Wrong type used in $procName under option $optname. Valid types are bool/string/list."
                #                }
                set skip 1
                if { $IntType == "argument"  } {
                    foreach valid_type $::parseOpt::validArgTypes {
                        if { [regexp $valid_type $type] } {
                            set skip 0
                            break
                        }
                    }
                } else {
                    foreach valid_type $::parseOpt::validOptTypes {
                        if { [regexp $valid_type $type] } {
                            set skip 0
                            break
                        }
                    }
                }
                if { $skip } {
                    puts "-E- parseOpt::cmdSpec : Wrong type used in procedure \"$procName\" under option \"$optname\" type \"$type\" (skipping). Valid types are $::parseOpt::validOptTypes"
                    continue
                }
                
                # Define the elemt info in the global array
                lappend ::parseOpt::procInfo($procName:Opt:optList) $optname
                if { $IntType == "argument" } {
                    lappend ::parseOpt::procInfo($procName:Opt:argList) $optname
                }

                set ::parseOpt::procInfo($procName:Opt:$optname:Help) $help
                set ::parseOpt::procInfo($procName:Opt:$optname:Default) $default
                set ::parseOpt::procInfo($procName:Opt:$optname:Type) $type
                set ::parseOpt::procInfo($procName:Opt:$optname:Required) $required
                set ::parseOpt::procInfo($procName:Opt:$optname:DefaultFromPG) $default_from_pg
                set ::parseOpt::procInfo($procName:Opt:$optname:RadioGrp) $radio_grp
                set ::parseOpt::procInfo($procName:Opt:$optname:Filter) $filter
                set ::parseOpt::procInfo($procName:Opt:$optname:SingelSelection) $singel_selection
                set ::parseOpt::procInfo($procName:Opt:$optname:Hidden) $hidden
                set ::parseOpt::procInfo($procName:Opt:$optname:Values) $values
                set ::parseOpt::procInfo($procName:Opt:$optname:ValidateCmd) $validate_cmd
                set ::parseOpt::procInfo($procName:Opt:$optname:OneOfStringCmd) $get_one_of_string_cmd
                set ::parseOpt::procInfo($procName:Opt:$optname:WinType) $win_type

                # Internal data 
                set ::parseOpt::procInfo($procName:Opt:$optname:IntType) $IntType
                
                if { $default_set } {
                    switch $IntType {
                        "argument" {
                            lappend ::parseOpt::procInfo($procName:Opt:defaultArray) $optname
                        }
                        default {
                            lappend ::parseOpt::procInfo($procName:Opt:defaultArray) "-$optname"
                        }
                    }

                    #  KADANH
                    if { [regexp -nocase {^bool(ean)?$} $type] && [regexp {^\s*$} "$default"] } {
                        set default 0
                    }

                    lappend ::parseOpt::procInfo($procName:Opt:defaultArray) "$default"
                } else {
                    lappend ::parseOpt::procInfo($procName:Opt:noDefault) $optname
                }

            }
            
        } elseif { [regexp -nocase {\-default} $obj] } {
            set ::parseOpt::procInfo($procName:Default) $procInfo($obj)
        } else {
            puts "-W- parseOpt::cmdSpec : Unknown option $obj, ignoring."
        }
    }

    # Inserting level 0 procedure (in case on usage in level 0)
    if { [info level] == 1 } {
        lappend ::parseOpt::level0ProcDef $procName
    }

    return 1
}



#####################################
#
# parse
#
# Init opt array and then parseOpt given args
# 
#####################################
proc ::parseOpt::parseOpt {caller args} {
    return [::parseOpt::parseOptsMain $caller opt $args]
}
proc ::parseOpt::parseOpts {caller optvar args} {
    return [::parseOpt::parseOptsMain $caller $optvar $args]
}


proc ::parseOpt::parseOptsMain {caller optvar args} {

    upvar 2 $optvar opts_ptr
    if { [info exists opts_ptr] } {
        unset opts_ptr
        upvar 2 $optvar opts_ptr
    }
    array set opts_ptr {}
    global env

    # Incase the user send a list of list
    # Support up to 20 levels 
    set i 0
    while { [llength $args] == 1 && $i < 3 } {
        set args [::parseOpt::varPop args]
        incr i
    }
    
   
    # If a proc was not specified, get the name of the proc that called it, and set that as the caller.
    if {$caller == ""} {
        if { [info level] > 1 } {
            set caller [lindex [info level [expr [info level]  - 1] ] 0]
            regsub {^::} $caller {} caller
        } else {
            # This is in case of procedure run in level 0 - 
            #  in this case it is used in a script and not in a procedure
            set level0Proc [set ::parseOpt::level0ProcDef]      
            if { [llength $level0Proc] == 1 } {
                set caller [lindex $level0Proc 0]
            } else {
                set scriptName [file tail [info script]]
                regsub [file extension $scriptName] $scriptName {} scriptName
                set caller $scriptName
                puts "-W- ::parseOpt::parseOpt : You are using parseOpt procedure in a script without specifing a name of option list. Please use parseOpt \$argv <option list name> (Assume $scriptName)"
            }      
        } 
    }

    
    # Verify that command have been defined
    if { ![info exists parseOpt::procInfo($caller:Init)] } {
        puts "-E- parseOpt::parseOpt : No options have been defined for command $caller (use cmdSpec to define options - Caller $caller)"
        return 0
    }

    # Init default values for all veriables
    ::parseOpt::initDefaultValues $caller $optvar

    set valid_options [set ::parseOpt::procInfo($caller:Opt:optList)]
    set valid_args    [set ::parseOpt::procInfo($caller:Opt:argList)]
    set use_gui 0

    set num_arg_given 0

    # Parsing user switches
    array set tmp_use_opts {}
    while { [llength $args] > 0 } {
        set option [::parseOpt::varPop args]

        # Ignore epmty variables
        if { [regexp {^[[:space:]]*$} $option] } { continue }
        
        regsub -all {^[[:space:]]+} $option {} option
        
        # Checking if help needed - if so -> print help and return 0
        if { [regexp -nocase {^\-h$} $option] || [regexp -nocase {^\-help$} $option] } {
            ::parseOpt::printHelp $caller
            set opts_ptr(-help) 1
            return 0;
        }
        if { [regexp -nocase {^\-gui$} $option] } {
            set use_gui 1
            continue
        }
        
        set is_argument 0

        if { ![regexp {^\-} $option] } {
            # We are sure in argument ... 
            # Lets parse it

            # If no argument is valid
            if { ![llength $valid_args] } {
                puts "-E- $caller: There are no valid argument. Please use -help switch for more info."
                return 0
            }

            if { [expr [expr $num_arg_given + 1] > [llength $valid_args]] } {
                puts "-E- $caller: The maximum number of argument that the procedure can get is [llength $valid_args]. Please check usage or use -help for more info"
                return 0
            }

            set option_name [lindex $valid_args $num_arg_given]
            incr num_arg_given

            set is_argument 1
        } else {
            # We can be in option (high prioirty), or arg, second prioirty. 

            
            # Verifing that option exist in the list of valid option
            regsub {^\-} $option {} option_name
            
            
            # Trying to complete option if it is not exist 
            if { [lsearch -exact $valid_options $option_name] < 0 } {
                # Going over the options list - checking if there is a signal start of options
                set index {}
                for { set i 0 } { $i < [llength $valid_options] } { incr i } { 		
                    set opi [lindex $valid_options $i]
                    if {[regexp "^$option_name" $opi]} {
                        lappend index $i
                    }
                }
                
                if { [llength $index] } {
                    if { [llength $index] == 1 } {
                        set option_name [lindex $valid_options [lindex $index 0]]
                    } else {
                        puts -nonewline "-E- $caller: Option $option_name fit to: "
                        foreach i $index {
                            puts -nonewline "-[lindex $valid_options $i] "
                        }
                        puts ""
                        return 0
                    }
                }
            }
            
            # Verifing that option exist in the list of valid options
            if { [lsearch -exact $valid_options $option_name] < 0 } {
                
                # Last chance - are we in args - if so, pass the original value to arg
                if { [llength $valid_args] && [expr [expr $num_arg_given + 1] <= [llength $valid_args]] } {
                    set option_name [lindex $valid_args $num_arg_given]
                    incr num_arg_given

                    set is_argument 1
                } else {

                    puts "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, unknown switch have been found - $option "
                    ::parseOpt::printHelp $caller
                    return -code error "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, unknown switch have been found - $option "
                }
            }
        }


        # Getting the option type
        set option_type  [set ::parseOpt::procInfo($caller:Opt:$option_name:Type)]
        set validate_cmd [set ::parseOpt::procInfo($caller:Opt:$option_name:ValidateCmd)]
        set validate_cmd_set [llength $validate_cmd]

        # If argument - nothing to do - just set value 
        if { $is_argument } {
            set opts_ptr($option_name) $option
            
            # Only check for argument is - one of value and float
            set value $option

            if { $validate_cmd_set } { 
                if { ! [::parseOpt::exec_validate_cmd $caller $option_name $validate_cmd $value] } { return 0 }
            }
            
            if { [regexp -nocase {^one_of_string$} $option_type] } {
                # Getting the value and checking if it is 
                regsub -all {^[[:space:]]+} $value {} value
                set values [::parseOpt::get_one_of_string_list $caller $option_name]
                if { [lsearch -exact $values $value] < 0 } { 
                    puts "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must get one of the following values: $values (and it got: $value)"
                    return -code error "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must get one of the following values: $values (and it got: $value)"
                }
            } elseif { [regexp -nocase {^int(eger)?$} $option_type] } {
                # Althoung the usage of all list/string/unknow is the same - keeping it separete for future feature.
                regsub -all {^[[:space:]]+} $value {} value
                if { [string is int $value]} {
                    set opts_ptr(-$option_name) $value
                } else {
                    puts "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must be an integer (got: $value)"
                    return -code error "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must be an integer (got: $value)"
                }
            } elseif { [regexp -nocase {^float$} $option_type] } {
                # Althoung the usage of all list/string/unknow is the same - keeping it separete for future feature.
                regsub -all {^[[:space:]]+} $value {} value
                if { [string is double $value]} {
                    set opts_ptr(-$option_name) $value
                } else {
                    puts "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must be an number (got: $value)"
                    return -code error "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must be an number (got: $value)"
                }
            }            
            
        } else {
            
            if { [regexp -nocase {^bool(ean)?$} $option_type] } {
                set option_default_value $opts_ptr(-$option_name)
                if { $option_default_value == "" } { set option_default_value 0 }
                set opts_ptr(-$option_name) [expr {!$option_default_value}]
            } elseif { [regexp -nocase {^ebool(ean)?$} $option_type] } {
                # Althoung the usage of all list/string/unknow is the same - keeping it separete for future feature.
                set value [::parseOpt::varPop args]
                regsub -all {^[[:space:]]+} $value {} value
                if {[regexp -nocase {^(on|true|enable|yes)$} $value]} {
                    set value 1
                } elseif {[regexp -nocase {^(off|false|disable|no)$} $value]} {
                    set value 0
                }
                if {$value==1 || $value==0} {
                    set opts_ptr(-$option_name) $value
                } else {
                    puts "-E- parseOpt::pasreOpt : Error, While parsing options of $caller,\n    $option_name must be one of (on/true/yes/enable/1 or off/false/no/disable/0) (got: $value)"
                    return -code error "-E- parseOpt::pasreOpt : Error, While parsing options of $caller,\n    $option_name must be one of (on/true/yes/enable/1 or off/false/no/disable/0) (got: $value)"
                }
            } elseif { [regexp -nocase {^one_of_string$} $option_type] } {
                # Getting the value and checking if it is 
                set value [::parseOpt::varPop args]
                regsub -all {^[[:space:]]+} $value {} value
                set values [::parseOpt::get_one_of_string_list $caller $option_name]
                if { $validate_cmd_set } { 
                    if { ! [::parseOpt::exec_validate_cmd $caller $option_name $validate_cmd $value] } { return 0 }
                } else {
                    if { [lsearch -exact $values $value] < 0 } { 
                        puts "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must get one of the following values: $values (and it got: $value)"
                        return -code error "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must get one of the following values: $values (and it got: $value)"
                    }
                }
                set opts_ptr(-$option_name) $value
            } elseif { [regexp -nocase {^int(eger)?$} $option_type] } {
                # Althoung the usage of all list/string/unknow is the same - keeping it separete for future feature.
                set value [::parseOpt::varPop args]
                regsub -all {^[[:space:]]+} $value {} value
                if { $validate_cmd_set } { 
                    if { ! [::parseOpt::exec_validate_cmd $caller $option_name $validate_cmd $value] } { return 0 }
                }
                if { [string is int $value]} {
                    set opts_ptr(-$option_name) $value
                } else {
                    puts "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must be an integer (got: $value)"
                    return -code error "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must be an integer (got: $value)"
                }
            } elseif { [regexp -nocase {^(point|bbox)$} $option_type] } {
                set value [::parseOpt::varPop args]
                if { $validate_cmd_set } { 
                    if { ! [::parseOpt::exec_validate_cmd $caller $option_name $validate_cmd $value] } { return 0 }
                }
                set opts_ptr(-$option_name) $value
            } elseif { [regexp -nocase {^float$} $option_type] } {
                # Althoung the usage of all list/string/unknow is the same - keeping it separete for future feature.
                set value [::parseOpt::varPop args]
                regsub -all {^[[:space:]]+} $value {} value
                if { $validate_cmd_set } { 
                    if { ! [::parseOpt::exec_validate_cmd $caller $option_name $validate_cmd $value] } { return 0 }
                }
                if { [string is double $value]} {
                    set opts_ptr(-$option_name) $value
                } else {
                    puts "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must be an number (got: $value)"
                    return -code error "-E- parseOpt::pasreOpt : Error, While parsing options of $caller, $option_name must be an number (got: $value)"
                }
            } elseif { [regexp -nocase {^(string|file|directory|pin|pin_port|port|cell|net|lib_cell|lib_pin)$} $option_type] } {
                # Althoung the usage of all list/string/unknow is the same - keeping it separete for future feature.
                set value [::parseOpt::varPop args]
                regsub -all {^[[:space:]]+} $value {} value
                if { $validate_cmd_set } { 
                    if { ! [::parseOpt::exec_validate_cmd $caller $option_name $validate_cmd $value] } { return 0 }
                }
                set opts_ptr(-$option_name) $value
            } elseif { [regexp -nocase {^list$} $option_type] } {
                set value [::parseOpt::varPop args]
                regsub -all {^[[:space:]]+} $value {} value
                if { $validate_cmd_set } { 
                    if { ! [::parseOpt::exec_validate_cmd $caller $option_name $validate_cmd $value] } { return 0 }
                }
                set opts_ptr(-$option_name) $value
            } else {
                puts "-W- parseOpt::pasreOpt : Unknown type has been defined for option $option_name ($option_type)"
                set value [::parseOpt::varPop args]
                regsub -all {^[[:space:]]+} $value {} value
                if { $validate_cmd_set } { 
                    if { ! [::parseOpt::exec_validate_cmd $caller $option_name $validate_cmd $value] } { return 0 }
                }
                set opts_ptr(-$option_name) $value
            }
            
        }

        set tmp_use_opts($option_name) 1
        
        # Define GUI varaible 
        if { $is_argument } {
            set ::parseOpt::procInfo($caller:Opt:$option_name:GuiValue) $opts_ptr($option_name)
        } else {
            set ::parseOpt::procInfo($caller:Opt:$option_name:GuiValue) $opts_ptr(-$option_name)
        }

    }

    if { $use_gui } {
        ::parseOpt::open_gui $caller
        return 0
    }

    # Checking for required options
    foreach op [set ::parseOpt::procInfo($caller:Opt:optList)] {
        # Checking if it is must options
        set must [set ::parseOpt::procInfo($caller:Opt:$op:Required)]
        if { $must && ![info exists tmp_use_opts($op)] } {
            puts "-E- parseOpt::pasreOpt : Error, The following option is must: \"$op\"."
            ::parseOpt::printHelp $caller 
            return -code error "-E- parseOpt::pasreOpt : Error, The following option is must: \"$op\"."
        }
    }

    return 1;
}



#####################################
#####################################
##
## Internal procedures for parseOpt
##
#####################################
#####################################

#####################################
#
# varPop
#
# The following procedure simply pop out 
# a varialbe for a list and return the variable
######################################
proc ::parseOpt::varPop {list_name} {
    upvar 1 $list_name localList
    set first [lindex $localList 0]
    set localList [lrange $localList 1 end]
    return $first
}


#####################################
#
# initDefaultValues
#
# Init the global opt array with the default
# value of each elem.
######################################

proc ::parseOpt::initDefaultValues {caller optvar} {
    upvar 3 $optvar opts_ptr
    global env
    
    if { [info exists ::parseOpt::procInfo($caller:Opt:defaultArray)] } {
        array set opts_ptr $::parseOpt::procInfo($caller:Opt:defaultArray)
    }

    #    foreach op [set ::parseOpt::procInfo($caller:Opt:optList)] { }
    foreach op [set ::parseOpt::procInfo($caller:Opt:noDefault)] {
        switch [set ::parseOpt::procInfo($caller:Opt:$op:IntType)] {
            "option" {
                set  opts_ptr(-$op) [::parseOpt::getDefaultValues $caller $op]
            }
            "argument" {
                set  opts_ptr($op) [::parseOpt::getDefaultValues $caller $op]
            }
        }
    }
}



proc ::parseOpt::getDefaultValues {caller optName} {
    global env

    set value_return ""

    set type [set ::parseOpt::procInfo($caller:Opt:$optName:Type)]
    set default [set ::parseOpt::procInfo($caller:Opt:$optName:Default)]
    set default_from_pg [set ::parseOpt::procInfo($caller:Opt:$optName:DefaultFromPG)]
    set values [::parseOpt::get_one_of_string_list $caller $optName]

    ##############################
    # If we need to start from:
    #   param_get 
    if { $default_from_pg != "" } {
        # Verifying that param exists
        if { [param_info -quiet -name $default_from_pg] } {
            return [param_get -name $default_from_pg]
        }
    }

    if { $default == {} } {
        # User have not define a default - lets define it by ourself
        if { [regexp -nocase {^(string|int(eger)?|float)$} $type] } {
            return ""
        } elseif { [regexp -nocase {^e?bool(ean)?$} $type] } {
            return 0
        } elseif { [regexp -nocase {^one_of_string$} $type] } {
            return [lindex $values 0]
            # If Dynamic value - you will not see the values
            # to fix it - you need to use the next line:
            return $values
            # Not using it since Dynamic is usally is too long
        } elseif { [regexp -nocase {^point$} $type] } {
            return "-1 -1"
        } elseif { [regexp -nocase {^bbox$} $type] } {
            return "-1 -1 -1 -1"
        } else {
            return {}
        } 
    } else {
        # Settign the default value that have been defined by user

        # Replacing enviroment variable (env) with their value
        while { [regexp {\$env} $default]} {
            regexp {\$env\([^ \t\)]+\)} $default var
            regsub {^\$} $var {} var
            set var [set $var]
            regsub {\$env\([^ \t\)]+\)} $default $var default
        }
        
        return $default
    }
    
    # Never here ...
    return $value_return
}




#####################################
#
# printHelp
#
# Print help message
######################################
proc ::parseOpt::printHelp {caller} {
    set offset 8
    set SPACE [format "%${offset}s" ""]
    set table [list]
    set must_options ""
    set arg_table [list]

    # Working on options
    foreach op [set ::parseOpt::procInfo($caller:Opt:optList)] { 
        set arg 0
        if { [info exists ::parseOpt::procInfo($caller:Opt:$op:IntType)] && [set ::parseOpt::procInfo($caller:Opt:$op:IntType)] == "argument" } {
            set arg 1
        }

        foreach field {Type Help DEFAULT Values Required} {
            if {$field=="DEFAULT"} {
                set $field [::parseOpt::getDefaultValues $caller $op]
            } else {
                set $field [set ::parseOpt::procInfo($caller:Opt:$op:$field)]
            }
        }
        if {[regexp -nocase {^one_of_string$} $Type]} {
            append Help "\nValues: [lindex $Values 0]"
            foreach val [lrange $Values 1 end] {append Help ", $val"}
        }
        if { $arg } {
            lappend arg_table [list $Required "$op" "<" $Type ">" $DEFAULT $Help]
        } else {
            lappend table [list $Required "-$op" "<" $Type ">" $DEFAULT $Help]
        }

        if {$Required} {
            if { $arg } {
                append must_options " <$op>"
            } else {
                append must_options " -$op <$Type>"
            }
        }
    }

    
    # Working on argument (always comes at the end)
    

    rls_table -header [list Must Option Type "" "" Default Usage] -table [concat $table $arg_table] \
        -no_sep -breaks -offset $offset -title "Usage:
$SPACE$caller $must_options \[options\]
Description:
$SPACE[set  ::parseOpt::procInfo($caller:Help)]
Options:"
    return 1
}


proc ::parseOpt::cancelCmd {procName window args} {
#    set list [split [lindex $args 0]]

    foreach obj [join [join $args]] {
        catch {itcl::delete object ::parseOpt::$obj} msg
    }
    
    destroy $window
    return 1
}

proc ::parseOpt::previewCmd {procName window} {
    #    destroy $window

    set cmd [::parseOpt::buildCmd $procName $window]


    echo $cmd
}

proc ::parseOpt::okCmd {procName window args} {
    foreach obj [join [join $args]] {
        catch {itcl::delete object ::parseOpt::$obj} msg
    }
    
    destroy $window

    set cmd [::parseOpt::buildCmd $procName $window]

    echo $cmd

    set msg [uplevel \#0 "eval \{$cmd\}"]

    echo $msg
    
    return $msg
}


proc ::parseOpt::defaultCmd {procName window} {

    # Going on all options and setting defaults
    foreach optName $::parseOpt::procInfo($procName:Opt:optList) {
        set ::parseOpt::procInfo($procName:Opt:$optName:GuiValue) [::parseOpt::getDefaultValues $procName $optName]
    }
    
}


proc ::parseOpt::validate {type value} {

    if { [regexp {^\s*$} $value] } { return 1 }

    return [string is $type $value]
}



# Creating CMD for GUI execture or preview
proc ::parseOpt::buildCmd {procName window} {
    
    set cmd "$procName "
    set arg_list [set ::parseOpt::procInfo($procName:Opt:argList)]

    # Going over all options and creating them a GUI
    foreach optName $::parseOpt::procInfo($procName:Opt:optList) {

        set is_argument 0
        if {  $::parseOpt::procInfo($procName:Opt:$optName:IntType) == "argument" } {
            set is_argument 1
        }
        

        set optDefault $::parseOpt::procInfo($procName:Opt:$optName:Default)
        set optDefault [::parseOpt::getDefaultValues $procName $optName]
        set optHidden  $::parseOpt::procInfo($procName:Opt:$optName:Hidden)
        set optType    $::parseOpt::procInfo($procName:Opt:$optName:Type)
        set optReq     $::parseOpt::procInfo($procName:Opt:$optName:Required)
        set values     [::parseOpt::get_one_of_string_list $procName $optName]

        set gui_value $::parseOpt::procInfo($procName:Opt:$optName:GuiValue)
        
        if { $gui_value == $optDefault || $optHidden } { continue }

        if { [regexp -nocase {^bool(ean)?$} $optType ] } {
            if { $gui_value } {
                append cmd "-$optName "
            }
        } elseif { [regexp -nocase {^one_of_string$} $optType ] } {
            if { $is_argument } {
                append cmd " \"$gui_value\" "
            } else {
                append cmd "-$optName \"$gui_value\" "
            }
        } elseif { [regexp -nocase {^(string|int(eger)?|float|ebool(ean)?)$} $optType ] } {
             if { $is_argument } {
                append cmd " \"$gui_value\" "
            } else {
                append cmd "-$optName \"$gui_value\" "
            }
        } elseif { [regexp -nocase {^list$} $optType ] } {
            if { $is_argument } {
                append cmd " \{$gui_value\} "
            } else {
                append cmd "-$optName \{$gui_value\} "
            }
        } elseif { [regexp -nocase {^file$} $optType ] } {
             if { $is_argument } {
                append cmd " \"$gui_value\" "
            } else {
                append cmd "-$optName \"$gui_value\" "
            }
        } elseif { [regexp -nocase {^directory$} $optType ] } {
             if { $is_argument } {
                append cmd " \"$gui_value\" "
            } else {
                append cmd "-$optName \"$gui_value\" "
            }
        } elseif { [regexp -nocase {^(cell|pin|pin_port|port|net|lib_cell|lib_pin|point|bbox)$} $optType ] } {
             if { $is_argument } {
                append cmd " \"$gui_value\" "
            } else {
                append cmd "-$optName \"$gui_value\" "
            }
        }
        
    }
    
    return $cmd
}




proc ::parseOpt::unhide_cmd {cmd} {

    if { $cmd == "all" } {
        foreach k [array get ::parseOpt::procInfo *:Opt:optList] {
            regexp {^(\S+):Opt:optList$} $k lost cmdl
            if { ![info exists cmdl] } { continue }
            foreach opt $::parseOpt::procInfo($cmdl:Opt:optList) {
                set ::parseOpt::procInfo($cmdl:Opt:$opt:Hidden) 0
            }
        }

    } else {
        if { ![info exists ::parseOpt::procInfo($cmd:Opt:optList)] } {
            echo "-E- No such command $cmd"
            return 0
        }
        foreach opt $::parseOpt::procInfo($cmd:Opt:optList) {
            set ::parseOpt::procInfo($cmd:Opt:$opt:Hidden) 0
        }
    }
    
    return 1
}



proc ::parseOpt::exec_validate_cmd {procName optName validateCmd value} {

    if { [catch {set status [eval $validateCmd $procName $optName $value]}] } {
        puts "-E- Fail to validate value for option $optName of command $procName"
        return 0
    }
    if { ! $status  } {
        puts "-E- Value: $value is not legal value for option $optName of command $procName"
    }


    return $status
}



proc ::parseOpt::get_one_of_string_list {procName optName} {

    if { [llength $::parseOpt::procInfo($procName:Opt:$optName:OneOfStringCmd)] } {
        if { [catch {set values [eval $::parseOpt::procInfo($procName:Opt:$optName:OneOfStringCmd) $procName $optName]}] } {
            puts "-E- Fail to get list of values for option $optName of command $procName (eval  $::parseOpt::procInfo($procName:Opt:$optName:OneOfStringCmd) $procName $optName)"
            return [list ]
        }
        return $values 
    }
    

    return [set ::parseOpt::procInfo($procName:Opt:$optName:Values)]
}


proc ::parseOpt::getOptionType {procName optname} {
    if { [info exists ::parseOpt::procInfo($procName:Opt:$optname:Type)] } {
        return $::parseOpt::procInfo($procName:Opt:$optname:Type)
    }
    return "unkown"
}






#####################################
# Init RLS TABLE
#####################################
if { [info commands rls_table] == "" } {
    catch {unset path} msg
    set path $::parseOpt::parseOptPath
    source $path/rls_table.tcl
    unset path
}



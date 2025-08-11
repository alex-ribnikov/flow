###############################
#// Header and explanations //#
#
#This is a comment
#

# //
proc hn_parse_args { help_data {arg_data ""} {args_in ""} } {

  # // HELP SECTION //
  if { ($help_data eq "-help")||($help_data eq "-h") } {

    set PROC hn_parse_args

    puts "
    $PROC takes a help section in an expected format, and sets variables from user or default values.
    expected format is a string of 'help' message, an argument array (detailes below), and the user given arguments.
    expected format of argument array:
        {{opt_name:required:type:default:string with comments} { ... } ... { ... }}
    example:
        { {ports:1:list::ports to do something on} {print:0:boolean:false:will print results if enabled} {...}}
    "
  
    return ""
  }

  # // parse arguments
  
    set my_table     "{OptName Required Type DefaultValue Comments}" 
    lappend my_table  "------- -------- ---- ------------ --------"   
    array set _opt ""
    array set _w ""
    set i 0 ; foreach _val [join $my_table] { 
        set _w($i) [expr [string length $_val] + 2]
        incr i
    }
    
    foreach _arg_entry $arg_data {
        lassign [split $_arg_entry ":"] arg req type def cmnts
        set my_table_entry "$arg $req $type {$def} {$cmnts}"
          # get table widths    
        set i 0 ; foreach _val $my_table_entry {
            set _val_w [expr [string length $_val] + 2]
            set _w($i) [expr max($_w($i),$_val_w)]
            incr i
        }
        lappend my_table $my_table_entry
      # set arg value from user input, or from default values
        set idx [lsearch $args_in "-$arg"]
        if { $idx >= 0 } {
            if { [regexp boolean $type] } {
                set _opt($arg) 1
            } else {
                set _opt($arg) [lindex $args_in [expr $idx+1]]
            }
        } else {
            set _opt($arg) $def
        }
    }

  # // DISPLAY HELP MENU
    if { [regexp "\-help" $args_in] } {
        puts "$help_data"
        foreach line $my_table {
            lassign $line arg req type def cmnts
            puts [format "%-${_w(0)}s %-${_w(1)}s %-${_w(2)}s %-${_w(3)}s %-${_w(4)}s" $arg $req $type $def $cmnts]
        }
        puts ""
        return ""
    } else {
        return [array get _opt]
    }
}
#//

proc hn_get_connectivity { args } {

  set PROC hn_get_connectivity

  set help_cmnt "
$PROC will return a summary of all inputs/outputs from the given object.
By default, it will print out a table with the results, with noprint flag can also return as list.
Make sure to run 'init_be_scripts' before using it, as I'm using Or's script 'ory_get_hiers_of_cells'.   
"

  set my_args "
    {obj:1:list::a get_db list that can be ports, hierarchy cells, insts, pins, etc}
    {level:0:list:2:the hierarchy depth to return. 2 being 'hierA/hierB'}
    {noprint:0:boolean:false:if used, will not print the results, but return them as a list}
    {min:0:integer:10:will only show inputs and outputs if they have at least 'min' connections to given obj}
  "
  
  array set my_opt [hn_parse_args $help_cmnt $my_args $args]        ;   if { ![llength [array get my_opt]] } { return }

  
  array unset all_con_arr
  array set all_con_arr ""
  set my_obj $my_opt(obj)
  
  set type [lsort -unique [get_db $my_obj .obj_type]]

  if { [llength $type] > 1 } {
      # split by type and send separately
  } else {

    if { [regexp "port" $type] } {
         set _in [get_db $my_obj -if {.direction==out}]
         set _out [get_db $my_obj -if {.direction==in}]
    } 
    if { [regexp "hinst" $type] } {
        set tmp_obj [get_db $my_obj .insts -if .is_flop]
        if { ![llength $tmp_obj] } {
            set tmp_obj [get_db $my_obj .insts]
        }
        if { ![llength $tmp_obj] } {
            puts "-W- couldn't find any insts objects relating to hierarchy inst $obj"
            return 0
        } else {
            set my_obj $tmp_obj
            set type "inst"        
        }
    }
    if { [regexp "inst" $type] } {
        if { [llength [get_db $my_obj -if {.base_cell.base_class==block}]] } {
          # // IS HIP
            set _in  [get_db $my_obj .pins -if {.base_name==D\[*\]||.base_name==DA\[*\]||.base_name==DB\[*\]}]
            set _out [get_db $my_obj .pins -if {.base_name==Q\[*\]||.base_name==QA\[*\]||.base_name==QB\[*\]}]
        
        } else { 
          # // ARE CELLS
            if { [llength [get_db $my_obj -if .is_flop]] } {
                set _in  [get_db $my_obj .pins -if {.base_name==D*}]
                set _out [get_db $my_obj .pins -if {.base_name==Q*}]
            }
            if { [llength [get_db $my_obj -if .is_flop==false]] } {
                lappend _in  [get_db $my_obj .pins -if {.direction==in}]
                lappend _out [get_db $my_obj .pins -if {.direction==out}]
            }
        }
    }
    if { [regexp "pin" $type] } { 
        set _in  [get_db $my_obj -if .direction==in] 
        set _out [get_db $my_obj -if .direction==out] 
    }

    set afi ""
    set afo ""
    if { [llength $_in] } {
        set afi [all_fanin -start -to $_in]
    }
    set all_con_arr(cells,in) [get_db [get_db $afi -if .obj_type==pin*] .cell_name]
    set all_con_arr(ports,in) [get_db [get_db $afi -if .obj_type==port*&&.direction!=out]]
    if { [llength $_out] } {
        set afo [all_fanout -end -from $_out]
    }
    set all_con_arr(cells,out) [get_db [get_db $afo -if .obj_type==pin*] .cell_name]
    set all_con_arr(ports,out) [get_db [get_db $afo -if .obj_type==port*&&.direction!=in]]
    
    # // parse results
    set my_inputs ""
    redirect -var _v {ory_get_hiers_of_cells [get_db insts $all_con_arr(cells,in)] $my_opt(level)}
    foreach {_n x _h} [lrange $_v 4 end] {
      if { $_n >= $my_opt(min) } {    
        lappend my_inputs "$_h $_n"
      }
    }
    foreach _p [lsort -unique [regsub -all {_[0-9]+} [regsub -all {(\\?\[\w+\\?\])+} $all_con_arr(ports,in) {*}] {_*}]] {
      set sz [llength [lsearch -all -inline $all_con_arr(ports,in) $_p]]
      if { $sz >= $my_opt(min) } {
        lappend my_inputs "$_p $sz"
      }
    }
    set my_outputs ""
    redirect -var _v {ory_get_hiers_of_cells [get_db insts $all_con_arr(cells,out)] $my_opt(level)}
    foreach {_n x _h} [lrange $_v 4 end] {
      if { $_n >= $my_opt(min) } {
        lappend my_outputs "$_h $_n"
      }
    }
    foreach _p [lsort -unique [regsub -all {_[0-9]+} [regsub -all {(\\?\[\w+\\?\])+} $all_con_arr(ports,out) {*}] {_*}]] {
      set sz [llength [lsearch -all -inline $all_con_arr(ports,out) $_p]]
      if { $sz >= $my_opt(min) } {
        lappend my_outputs "$_p $sz"
      }
    }
    
    set ret_list "{INPUTS -} [lsort -decreasing -integer -index 1 $my_inputs] {OUTPUTS -} [lsort -decreasing -integer -index 1 $my_outputs]" 
    if { $my_opt(noprint) } {
        return $ret_list
    } else {
        rls_table -spacious -breaks -no_sep -header "Port/Hier Count" -table $ret_list  ;   puts ""
    }
  }

}

proc hn_sum_ports { {_arg0 ""} {_arg1 ""} {level 0}} {

    set MIN_DEF 60

    if { $_arg0 eq "" } {   
        set my_ports [get_db ports *]
        set min $MIN_DEF
    } else {
        if { [regexp {^[0-9]+$} $_arg0] } {
            set min $_arg0
            set my_ports $_arg1
            if { $my_ports eq "" } { set my_ports [get_db ports *] }
        } else {
            set my_ports $_arg0
            set min $_arg1
            if { $min eq "" } { set min $MIN_DEF }             
        }
    }

   set my_table ""
    foreach p [ory_bus_compress $my_ports 0] { 
        set idx [string first "/" $p ]
        set _p  [regsub -all {\*+} [regsub -all {\\} [string range $p [expr $idx+1] end] ""] "*"]
        if { $level > 0 } {
            set _p [regsub -all {\*.*|\[.*} $_p "\*"] 
        }
        if { $level > 1 } {
            set _p [regsub -all {\*+} [regsub -all {_[0-9]+} $_p "_*"] {*}]             
        }
        set sz [llength [get_db ports $_p]]
        if { $sz >= $min } {
            lappend my_table "$_p \"[lsort -unique [get_db [get_db ports $_p] .direction]]\" $sz"
            #lappend my_table "$_p $sz"        
        }
        #puts "$p ; $_p ; $sz"
    }
    rls_table -no_s -breaks -spacious -header "BusName Direction Size" -table [lsort -integer -decreasing -index 2 [lsort -unique $my_table]]
    #rls_table -spacious -header "BusName Size" -table [lsort -integer -decreasing -index 1 [lsort -unique $my_table]]

}


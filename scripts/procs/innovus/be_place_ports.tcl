# //
# Added by hilleln 240924
# //

# // usage example start //
### get a list of free tracks (non-pg) sorted by x or y
# set sorted_free_tracks_list [be_ports_get_tracks_list -max_layer 15 -min_layer 6]
### prepare output file     
# set f_out_name "my_port_placements.tcl"
# be_procs_file_out_init "$f_out_name"
### setting flag variable for writing commands, or for debug mode 
# set output_flags [expr {$DBG ? "NO_WRITE" : "$f_out_name"}]
### setting pattern to place port - '0' means track to route in, '1' means track that will be skipped
# set my_pattern_list "{M14 0 1} {M12 0 1} {M10 0 1} {M8 1 0} {M6 0 1 1}"
# set PRIO_LAY "12"
# set _port_mapping "
# west_nbus_to_nbus   nbus_to_east_nbus
# nbus_to_west_nbus   east_nbus_to_nbus
# "
### writing place port commands
# set _tmp_port_list [list [be_ports_sort_bus "west_nbus_to_nbus nbus_to_west_nbus" "0 1 2 3 4" "0" 147 29]] ; list
# set _st     [expr $cbuy + 651]
# set _end    [expr $_st + 85]
# puts "-BE-place_ports writing place port commands for NBUS track 0 from $_st to $_end"    
# be_ports_place_ports -port_list "[join [join $_tmp_port_list]]" -pattern_list $my_pattern_list -start $_st -end $_end -const 0 \
#   -free_tracks_list $sorted_free_tracks_list -interleave -priority_ports "valid|ready" -priority_min_lay $PRIO_LAY -mirror_const $core_x_size -map_list $_port_mapping -file_out $output_flags
### and finishing up the output file
# set f_out [open $f_out_name a]
# puts $f_out "set_db assign_pins_edit_in_batch false"
# puts $f_out "edit_pin -fix_overlap -fixed_pin -layer \"M6 M8 M10\" -pin \[get_db \[get_db ports -if .place_status==unplaced\] .name\] -pattern fill_checkerboard -start \"$core_x_size $_st\" -end \"$core_x_size $_end\""
# puts $f_out "edit_pin -pin south_grid_clk -layer M15 -pin_depth 1.2 -pin_width 0.126 -assign \{[expr 0.5*$core_x_size] [expr 0.5*$core_y_size]\} -fixed_pin -fix_overlap 1 -side inside -snap track"
# puts $f_out "puts \"-BE- failed to place  \[llength \[get_db ports -if .layer.name!=M*\]\] ports\""
# close $f_out
# // usage example done //

#############################
# ~ ~ general info for N5 ~ ~
#############################
#  LAY  Trk/um  1 : 3  1 : 2
#  ---  ------  -----  -----
#   M3  23.810  7.937  7.937 
#   M4  23.810  7.937  7.937
#   M5  13.158  4.386  6
#   M6  12.500  4.167  5.5
#   M7  13.158  4.386  6
#   M8  12.500  4.167  5.5
#   M9  13.158  4.386  6
#  M10  12.500  4.167  5.5
#  M11  13.158  4.386  6
#  M12   7.937  3.175 (4/7)   **  2.381  (3 / 7 routable tracks)
#  M13   7.519  2.211 (5/12)  **  1.769  (4 / 7 routable tracks)
#  M14   3.906  1.587 (4/7)
#  M15   3.906  1.327 (6/9)

# M6 - M12 at 1:3   15.804 trk/um
# M5 - M13 at 1:3   20.190 trk/um

# M6 - M14 at 1:2   17.391 trk/um
# M5 - M13 at 1:2   26.211 trk/um

# M4        4 tracks per gutter
# M6/M8/M10 6 tracks per gutter
# M12/M14   7 tracks per gutter

# M5        3/4     tracks per gutter
# M7,M9     5-3-5   tracks per gutter
# M11       7       tracks per gutter (first and last aren't routable alternating)
# M13       14      tracks per gutter (first and last aren't routable)

###############
# ~ ~ procs ~ ~
###############
# //
proc be_ports_file_out_init { file_out_name } {
    set f_out [open $file_out_name w]
  # adding commands to clear initial port placement if exists
    puts $f_out "set_db \[get_db ports *\] .place_status unplaced"
    puts $f_out "delete_obj \[get_db port_shapes\]"
    puts $f_out "set_db \[get_db ports *\] .location {0 0}"
    puts $f_out ""
    puts $f_out "set_db assign_pins_edit_in_batch true"
    close $f_out
}

# // 
# help info in start of script / using -help 
proc be_ports_get_tracks_list { args } {

  # // INITIAL SETTINGS
    set PROC "[lindex [info level 0] 0]"
  # Parse args
    set help_info "Returns a sorted list of non-pg tracks (layer + x/y coordinates)"

    # opt_name      must   type      default  info
    set my_args {
        {min_layer  0      integer   "6"      "min layer to be used for placing ports"}
        {max_layer  0      integer   "15"     "max layer to be used for placing ports"}
    }
    if { [be_parse_args $help_info $my_args $args] != 0 } { return }

  # // MAIN PROC
    set free_track_list ""
    for { set lay_num $min_layer } { $lay_num <= $max_layer } { incr lay_num } {
        set _lay_dir [expr {$lay_num % 2 > 0 ? "x" : "y"}]     ;# Dir is 'y' or 'x' for even or odd layer num (the changing coordinate)

        puts "-BE-${PROC}- gather track information on M${lay_num}"

      # get all PG wires
        set rect_att "rect"   
        set all_special_wires [get_db [get_db nets "VDD VSS"] .special_wires -if ".layer.name==M${lay_num}&&.user_class!=MEM_PG"]
    
      # if no wires found for this layer, get all PG vias
        if { [llength $all_special_wires] eq 0 } {
            set all_special_wires [get_db [get_db nets "VDD VSS"] .special_vias -if ".via_def.bottom_layer.name==M${lay_num}&&.user_class!=MEM_PG"]
            set rect_att "bottom_rects"
        }

        set routable_count 0  
        if { [llength $all_special_wires] > 0 } {

            set v_idx [regexp "y" $_lay_dir]
            set rect_list [lsort -real -index $v_idx -unique [get_db $all_special_wires .${rect_att}]]
      
            set _len [llength $rect_list]
      
            set l_p [get_db [get_db layers -if .name==M${lay_num}] .pitch_$_lay_dir]
            set l_w [get_db [get_db layers -if .name==M${lay_num}] .width]
            set l_o [get_db [get_db layers -if .name==M${lay_num}] .offset_$_lay_dir]
      
            for { set i 0 } { $i < $_len } { incr i } {
                set cur_rect [lindex $rect_list $i]   ;# // current PG wire
                set nxt_rect [lindex $rect_list $i+1] ;# // next PG wire
                
                lassign $cur_rect x00 y00 x01 y01
                lassign $nxt_rect x10 y10 x11 y11
                
                if { $_lay_dir == "x" } {
                    set _w0 [expr $x01 - $x00]
                    set nxt [expr $x10 - (0.5*${l_p})]
                } else {
                    set _w0 [expr $y01 - $y00]
                    set nxt [expr $y10 - (0.5*${l_p})]
                }
                
                set cur_0 [lindex $cur_rect $v_idx]   ;# PG wire loc
                set cur   [expr $l_o + ($l_p*round(($cur_0 + $_w0 - $l_o + 0.001)/$l_p)) - 0.5*$l_w + $l_p]   ;# 1st routable track loc 
                
                while { [expr $cur + (0.5*$l_w)] < $nxt } {
                    set is_last [expr {($cur + $l_p + (0.5*$l_w)) < $nxt ? 0 : 1}]  ;# if next track is unroutable or PG 
                    lappend free_track_list "{[expr $cur + (0.5*$l_w)] M$lay_num $is_last}"
                    set cur [expr $cur + $l_p]
                    incr routable_count
                }
            }      
        } ;# done collecting track data for a single layer
        if { $routable_count } {
            puts "-BE-${PROC}-     found $routable_count routable tracks for M${lay_num}" 
        } else {
            puts "-BE-${PROC}-     did not find any routable tracks for M${lay_num}, using [llength $all_special_wires] PG wires"
        }
    }
  
    set sorted_free_tracks_list       [lsort -real -index 0 [lsort -unique [join $free_track_list]]]
    return $sorted_free_tracks_list
}

# //
# help info in start of script / using -help 
proc be_ports_place_ports { args } {

    set help_cmnt "
    writes 'edit_pin' commands to a file, from given ports on given tracks, based on layer patterns.
    supports interleave and mirroring options.
    to enable mirroring, give 'mirror_const' and 'map_list'.
    "

  # // INITIAL SETTINGS
    set PROC "[lindex [info level 0] 0]"
  # Parse args
    set help_info "
    writes 'edit_pin' commands to a file, from given ports on given tracks, based on layer patterns.
    supports interleave and mirroring options.
    to enable mirroring, give 'mirror_const' and 'map_list'.
    "

    # opt_name          must   type     default  info
    set my_args {
      {port_list        1      list     ""               "list of ports to place"}
      {free_tracks_list 1      list     ""               "list of available tracks in format of '<x/y value> <layer name> <is_last_in_street>'"}
      {pattern_list     1      list     ""               "layer patterns to place ports by. 0 is free track, 1 is blocked. example '\{M8 1 0 1\} \{M6 0 1 1\}'"}
      {start            1      float    ""               "the lower limit to start place from (either x or y)"}
      {end              1      float    ""               "the upper limit to end   place on   (either x or y)"}
      {const            1      float    ""               "the value of x or y on the edge you want to place ports on. west and south are '0', north is 'design Y' and east is 'design x'"}
      {mirror_const     0      float    ""               "the const value of the mirrored ports"}
      {file_out         0      string   ""               "name of out file to append lines to. if given NO_WRITE - will not write to output file"}    
      {interleave       0      boolean  false            "will attempt interleave placements for each layer separately"}
      {map_list         0      list     ""               "will mirror the port placement from const to mirror_const based on the given bus-mapping in format 'pre0 post0 pre1 post1...'"}
      {priority_ports   0      list     ""               "regexp pattern to match against port names for finding priority ports"}
      {priority_min_lay 0      integer  13               "minimum layer to assign for priority ports"}
      {DBG              0      boolean  false            "will output some debug and statistical data"}
    }

    if { [be_parse_args $help_info $my_args $args] != 0 } { return }

  # init variables
    set no_write [regexp "NO_WRITE" $file_out]
    if { !$no_write } { set f_out [open $file_out a] }

    set _len [llength $port_list]
    set p_idx 0
    
    set mirror [expr {[llength $map_list] > 0 ? 1 : 0}]
    
    lassign "$start $end" v0 v1

  # // MAIN PROC
    # take layer pattern data
    array unset lay_dir_arr
    array unset skip_arr

    foreach lay [regexp -inline -all {M[0-9]+} $pattern_list] {
        set lay_pat [lsearch -inline $pattern_list "$lay *"]
        if { ![regexp {[0-9]} [lindex $lay_pat end]] } {
            set skip_arr($lay) "0 [expr [llength $lay_pat] - 2] {[lrange $lay_pat 1 end-1]} 1"
        } else {
            set skip_arr($lay) "0 [expr [llength $lay_pat] - 1] {[lrange $lay_pat 1 end]} 0"
        }        
        set lay_dir_arr($lay) "x"
    }
    #
    set is_y [expr [regexp -inline {[0-9]+} $lay]%2]

  # Begin looping over all tracks, and prepare initial list
    set port_track_list ""
    set p_idx 0

    set last_val "x"
    foreach "val lay last" [join [join [lsearch -inline -all -regexp $free_tracks_list [regsub -all " " [array names skip_arr] "|"]] ]] {
      
        lassign $skip_arr($lay) skip_idx skip_len skip_pattern cont

        if { $val < $v0 } { continue }
        if { $val > $v1 } { break }

        if { ![lindex $skip_pattern $skip_idx] } {  ;# if track is allowed by pattern
            if { $p_idx < $_len } {
                set _p_name [lindex $port_list $p_idx]
              # tracking last value of x/y  
                set last_val $val
            } else {
                set _p_name "HN_DUMMY_PORT"
            }
            set _p_dir [regexp "in" [get_db [get_db ports $_p_name] .direction]]

            set x [expr { $is_y ? $val : $const }]
            set y [expr { $is_y ? $const : $val }]
          # adding entry to initial list
            lappend port_track_list [list $_p_name $_p_dir $x $y $lay]
          # managing p_idx
            incr p_idx
            #if { $p_idx >= $_len } { break } 
        }
      # managing skip_idx
        incr skip_idx     ;   if { $skip_idx >= $skip_len } { set skip_idx 0 }
        if { $last } {
          if { $cont } {
            if { [lindex $skip_pattern $skip_idx] } {
              incr skip_idx     ;   if { $skip_idx >= $skip_len } { set skip_idx 0 }
            }
          } else {
            set skip_idx 0
          }
        }
        set skip_arr($lay) "$skip_idx $skip_len {$skip_pattern} $cont"        
    }
    if { $p_idx < $_len } { puts "-I- Not enough tracks for required ports ([expr $_len - $p_idx])" } 

  # ~ ~ Change if interleave is required
    if { $interleave } { set port_track_list [be_ports_interleave $port_track_list $DBG] }

  # ~ ~ Change if Valid/Ready High metal is required
    if { [llength $priority_ports] } { set port_track_list [be_ports_do_priority_high $port_track_list $priority_ports $priority_min_lay $interleave $DBG] }

  # ~ ~ Output port list into edit_pin commands
    set final_port_track_list ""
    foreach _entry $port_track_list {
        lassign $_entry _p_name _p_dir x y lay
        if { [regexp "HN_DUMMY_PORT" $_p_name] } { continue }

        lappend final_port_track_list $_entry
        if { !$no_write } {
            puts $f_out "edit_pin -pin $_p_name -layer $lay -assign {$x $y} -snap track -fixed_pin -fix_overlap 1"
        }
        if { $mirror } {    ;# DO MIRRORING
            set m_p_name $_p_name
            foreach {pre post} $map_list { set m_p_name [regsub $pre $m_p_name $post] }
            if { $is_y } { set y $mirror_const } else { set x $mirror_const }
            if { !$no_write } {
                puts $f_out "edit_pin -pin $m_p_name -layer $lay -assign {$x $y} -snap track -fixed_pin -fix_overlap 1"
            }
            lappend final_port_track_list [list $m_p_name [expr 1 - $_p_dir] $x $y $lay]
        }
    }
    puts "-BE-${PROC}- reached $last_val"

    if { !$no_write } { close $f_out ; return $last_val } else { return $final_port_track_list }
}

# //
# sub-proc for be_ports_place_ports
proc be_ports_interleave { port_track_list_in {DBG 0} } {
    array set lay_dir_arr ""
    foreach lay [lsort -unique [regexp -all -inline {M[0-9]+} $port_track_list_in]] {
        set lay_dir_arr($lay) "x"   
    }

    set port_track_list $port_track_list_in
    set track_len [llength $port_track_list_in]

    for { set _i 0 } { $_i < $track_len } { incr _i } {
        lassign [lindex $port_track_list $_i] _p_name _p_dir x y lay
        if { [regexp "HN_DUMMY_PORT" $_p_name] } { continue }
        if { $lay_dir_arr($lay) == "x" } {
            set lay_dir_arr($lay) "$_p_dir"
        } else {
            set _j $_i
            set cur_dir $_p_dir
            set req_dir [expr 1 - $lay_dir_arr($lay)]
            set req_lay $lay
            while { ($req_dir!=$cur_dir) } {
                incr _j
                if { $_j<$track_len } {
                    lassign [lindex $port_track_list $_j] new_p_name cur_dir ~ ~ j_lay
                    if { [regexp "HN_DUMMY_PORT" $new_p_name] } { 
                        set cur_dir $req_dir 
                        set lay_dir_arr($j_lay) "x"
                    }
                } else {
                    puts "-E- Couldn't find interleave replacement for $_p_name"
                    set _j $_i
                    break
                }
            }
            if { $_j != $_i } { ;# a change occured
                if { $DBG } { puts "-I- place_ports debug - interleave replacing    \'[lindex $port_track_list $_i]\'  with   \'[lindex $port_track_list $_j]\'" }
                set port_track_list [lreplace $port_track_list $_j $_j [lreplace [lindex $port_track_list $_j] 0 1 $_p_name $_p_dir] ] ; list
                set port_track_list [lreplace $port_track_list $_i $_i [lreplace [lindex $port_track_list $_i] 0 1 $new_p_name $cur_dir] ] ; list
            }
            set lay_dir_arr($lay) $req_dir
        }
    }
    return $port_track_list
}

# //
# # sub-proc for be_ports_place_ports
proc be_ports_do_priority_high { port_track_list_in {prio_pattern "valid|ready"} {min_high_lay 13} {interleave 0} {DBG 0} } {

    set port_track_list $port_track_list_in
    set track_len [llength $port_track_list_in]

    for { set _i 0 } { $_i < $track_len } { incr _i } {
        lassign [lindex $port_track_list $_i] _p_name _p_dir x y lay
        if { [regexp "HN_DUMMY_PORT" $_p_name] } { continue }
        if { (([string range $lay 1 end] < $min_high_lay) && ([regexp "$prio_pattern" $_p_name])) } {
            set found 0
            set _j 0 ;   set _k $_i
            while { !$found } {
                incr _j ;   if { $_j > $track_len } { puts "-E- couldn't find suitable replacement for $_p_name (idx $_i)" ; break } 
                set _k [expr $_k - (((-1)**$_j)*$_j)]
                if { (($_k>$track_len)||($_k<0)) } { continue }
                lassign [lindex $port_track_list $_k] _k_name _k_dir ~ ~ k_lay
                if { (([string range $k_lay 1 end] >= $min_high_lay) && (![regexp "$prio_pattern" $_k_name])) } {
                    set found 1
                    if { [regexp "HN_DUMMY_PORT" $_k_name] } { set k_lay $_p_dir }
                    if { $interleave } {
                        if { $_p_dir != $_k_dir } { set found 0 }
                    }
                }
            }
            if { $found } {
                if { $DBG } { puts "-BE-be_place_ports- debug - priority replacing    \'[lindex $port_track_list $_i]\'  with   \'[lindex $port_track_list $_k]\'" }
                set port_track_list [lreplace $port_track_list $_k $_k [lreplace [lindex $port_track_list $_k] 0 1 $_p_name $_p_dir] ] ; list
                set port_track_list [lreplace $port_track_list $_i $_i [lreplace [lindex $port_track_list $_i] 0 1 $_k_name $_k_dir]  ] ; list
            }
        }
    }
    return $port_track_list
}

# //
# this proc was originally written as a sub-proc so it is less user-friendly.. TODO - switch to be_parse_args
# sorts port busses based on given data size, bus structure (bundles and tracks are index 0 and index 1 of port name - eg. nbus__1__3[17] is bundle 1 track 3
# for nxt009, these are a few key sorting numbers:
# NBUS 147 29
# CBUS 51 25
#
proc be_ports_sort_bus { bus_list {bundles ""} {tracks "0"} {DATA_SIZE 128} {VALID_PER_IN ""} } {

    set is_2dbus [expr { [sizeof [get_ports -quiet "[lindex $bus_list 0]*__0__0*"] ] > 0 ? 1 : 0}]

    set ret_list ""
    
    set lim $DATA_SIZE
    set VALID_PER $VALID_PER_IN
    
    set _t [expr {$is_2dbus ? "__0" : ""}]
    set max_size [sizeof [get_ports "[lindex $bus_list 0]*data*__0${_t}*"]]      
    if { $lim == "" } { set lim $max_size } 
    if { $VALID_PER == "" } { set VALID_PER $lim}

    set VALID_GROUPS [expr int(ceil($lim / $VALID_PER))]

    foreach b $bundles {
        set valid_grp_idx 0
        while { $valid_grp_idx < $VALID_GROUPS } {
            set mid [expr int(ceil(($VALID_PER * (0.5+$valid_grp_idx))))]
            for { set i [expr $VALID_PER * $valid_grp_idx] } { $i < [expr min($VALID_PER * ($valid_grp_idx + 1),$lim)] } { incr i } {
                if { $i == $mid } {
                    # MID - VALID AND READY
                    foreach t $tracks {
                      foreach bus $bus_list {        
                        if { $is_2dbus } {
                          lappend ret_list "${bus}_valid__${b}__${t}[${valid_grp_idx}]"
                          lappend ret_list "${bus}_ready__${b}__${t}[${valid_grp_idx}]"
                        } else {
                          lappend ret_list "${bus}_valid__${b}[${valid_grp_idx}]"
                          lappend ret_list "${bus}_ready__${b}[${valid_grp_idx}]"          
                        }
                      }    
                    }
                }   ;# END OF VALID READY
                # // spread data
                foreach t $tracks {
                  set _t [expr {$is_2dbus ? "__${t}" : ""}]
                  foreach bus $bus_list {
                    lappend ret_list "${bus}_data__${b}${_t}[${i}]"
                  }
                }
            }
            incr valid_grp_idx
        }
        # Leftovers
        for { set j [expr $VALID_PER * $valid_grp_idx] } { $j < $max_size } { incr j } {
          foreach t $tracks {
          set _t [expr {$is_2dbus ? "__${t}" : ""}]
            foreach bus $bus_list {        
              lappend ret_list "${bus}_data__${b}${_t}[${j}]"
            }
          }      
        }                
    }
    return $ret_list
}

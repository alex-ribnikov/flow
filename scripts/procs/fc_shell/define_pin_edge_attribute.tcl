
proc lrrotate {bbox {times 1}} {
        set nbbox $bbox
        for {set i 0} {$i<$times} {incr i} {
                set nbbox [concat [list [lindex $nbbox end]] [lrange $nbbox 0 end-1]]
        }
        return $nbbox
}


proc define_pin_edge_attribute {} {

        if {[get_attribute [get_ports ] pin_edge -quiet] != ""} {return "pin_edge attribute already exists";}

        define_derived_user_attribute \
          -name pin_edge \
          -classes {port} \
          -type int \
          -get_command {
        set i 1
        set const 0
        set bounding_box [get_attribute %object bounding_box]
        set boundary [get_attribute [get_blocks] outer_keepout_boundary] 
        set 0_n [lsearch  $boundary {0.0000 [1-9]*}]
        set 0_0 [lsearch  $boundary {0.0000 0.0000}]
        if {${0_n}<${0_0}} {
                set times [expr [llength $boundary] -${0_0} -1]
                set boundary [lreverse [lrrotate $boundary $times]]     
        }
        set edge -1
        foreach p $boundary { 
         if {[expr [lindex [get_attribute $bounding_box ll] $const]==[lindex $p $const]] || ([lindex [get_attribute $bounding_box ur] $const]==[lindex $p $const])} {set edge $i;break}
         set const [expr 1 - $const]
         incr i
        }
        return $edge

        }

        return "define pin_edge attribute";
}



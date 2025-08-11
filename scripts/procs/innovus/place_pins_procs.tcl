proc getPins {pattern data_type number_type rtl_name nbr} {

  global pinsList
  
  if { $data_type=="doublebus" } {
  
     if { $number_type=="bin" } {
         
         if {$nbr == "0"} {
              set binary_number 0_0
         } elseif {$nbr == "1"} {
              set binary_number 0_1
         } elseif {$nbr == "2"} {
              set binary_number 1_0
         } else {
              set binary_number 1_1
         } 
         foreach el [lsort -dictionary [get_db [get_db ports ${pattern}_[set binary_number]\[*] .name]] {lappend pinsList $el}

     } else {
     
         # Default : number_type = dec
	 
	 foreach el [lsort -dictionary [get_db [get_db ports ${pattern}_[set nbr]\[*] .name]] {lappend pinsList $el}

         if { $rtl_name=="pins_exception" } {
	  	
              set addPins [get_db [get_db ports [regsub "_u$" ${pattern} ""]valid_u\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports [regsub "_d$" ${pattern} ""]valid_d\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports [regsub "_l$" ${pattern} ""]valid_l\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports [regsub "_r$" ${pattern} ""]valid_r\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports [regsub "_u$" ${pattern} ""]ready_u\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports [regsub "_d$" ${pattern} ""]ready_d\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports [regsub "_l$" ${pattern} ""]ready_l\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports [regsub "_r$" ${pattern} ""]ready_r\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports ${pattern}valid\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports ${pattern}ready\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports ${pattern}ack\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports ${pattern}clr\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}
              set addPins [get_db [get_db ports ${pattern}wr\[[set nbr]\]] .name] ; if { $addPins != "" } {lappend pinsList $addPins}

         }

     }

  } elseif { $data_type=="singlebus" } {

     foreach el [lsort -dictionary [get_db [get_db ports ${pattern}\[[set nbr]\]] .name]] {lappend pinsList $el}

  } else {

     # Default : data_type = none
   
     foreach el [lsort -dictionary [get_db [get_db ports ${pattern}] .name]] {lappend pinsList $el}

  }
 
}

proc place_pins {scheme layers edge offset_start offset_end direction {exec true}} {
  global pinsList
  global A B C D E F G H I J K L M N O P Q R S T U V W X Y Z
  global AA AB AC AD AE AF AG AH AI AJ AK AL AM AN AO AP AQ AR AS AT AU AV AW AX AY AZ
  global tempA tempB tempC tempD tempE tempF tempG tempH tempI tempJ tempK tempL tempM tempN tempO tempP tempQ tempR tempS tempT tempU tempV tempW tempX tempY tempZ
  set pinsList [list ]
  for {set i 0} {$i<[llength $scheme]} {incr i} {
    regexp {([a-zA-Z]+)([0-9]+)} [lindex $scheme $i] match name number
    set cmd "getPins [concat [set [set name]] $number]"
    eval $cmd
  }
  edit_pin \
    -pin              $pinsList \
    -spread_direction $direction \
    -offset_start     $offset_start \
    -offset_end       $offset_end \
    -edge             $edge \
    -layer            [lindex $layers 0] \
    -spread_type      edge \
    -fix_overlap      1 \
    -snap             track \
    -fixed_pin        1

  set_db assign_pins_edit_in_batch true
  set i 0
  set nbr_layers [llength $layers]
  foreach pin $pinsList {
    set pin_width                [get_db layer:[lindex $layers [expr $i % $nbr_layers]] .width]
    set loc [get_db [get_db ports $pin] .physical_pins.layer_shapes.shapes.rect.ll]
    puts $loc
    edit_pin -pin $pin -layer [lindex $layers [expr $i % $nbr_layers]] -assign $loc -fix_overlap 0 -fixed_pin 1 -pin_width [expr 2*$pin_width]
    incr i
  }
  set_db assign_pins_edit_in_batch false
  puts "Successfully spread \[$i\] pins on layers $layers."
}

proc _legalize_SPRBUF { {relevant_base_cells  {F6UNAA_LPDSINVGT5X96} } } {
    # spread the iste rows of the Super Buffers legal locations
    create_row -site SPRBUF -polygon {{705.432 5.25} {705.432 1038.24} {0.0 1038.24} {0.0 8940.96} \
           {9713.256 8940.96} {9713.256 8678.88} {9876.048 8678.88} {9876.048 4465.44} \
           {9821.784 4465.44} {9821.784 4243.68} {9876.048 4243.68} {9876.048 231.84} \
           {9821.784 231.84} {9821.784 5.25}} -spacing 9.03 -no_abut -no_flip_rows

    # write def, move X by 8.3895, read it to the design
    write_def ex.def -no_core_cells -no_std_cells -no_special_net -no_tracks
    # cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF\") {m=\$4+16779; \$4=m}; print}" > ex1.def
    cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF\") {m=\$4+9027; \$4=m}; print}" > ex1.def
    cat ex1.def | awk "{if (NF > 10 && \$3 == \"SPRBUF\") {m=\$5+2520; \$5=m}; print}" > ex2.def
    read_def ex2.def

    # set the Super-Buffer at MX orientation and the site-rows + Enabling 60u as a legal movement
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .place_status placed
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .orient mx
    set_db [get_db rows  -if {.site.name == SPRBUF}] .orient mx
    set_db place_detail_eco_max_distance 400
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .base_cell.site SPRBUF

    # Legalizing on the "special" site rows
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .name]

    # remove the site rows, verify the Super-Buffers are at MX orientation and change their link to default sites
    delete_obj [get_db rows -if {.site.name == SPRBUF}]
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .orient mx
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .base_cell.site CORE_6

    # legalize place again to see that there are no movements
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT5X96 }] .name]
    set_db place_detail_eco_max_distance 0.0
}

proc _legalize_SPRBUF320R7 { {relevant_base_cells  {F6UNAA_LPDSINVGR7X320} } } {
    # spread the iste rows of the Super Buffers legal locations
    create_row -site SPRBUF320R7 -polygon {{705.432 5.25} {705.432 1038.24} {0.0 1038.24} {0.0 8940.96} \
                                           {9713.256 8940.96} {9713.256 8678.88} {9876.048 8678.88} {9876.048 4465.44} \
                                           {9821.784 4465.44} {9821.784 4243.68} {9876.048 4243.68} {9876.048 231.84} \
                                           {9821.784 231.84} {9821.784 5.25}} -spacing 0.84 -no_abut -no_flip_rows

    # write def, move X by 8.3895, read it to the design
    write_def ex.def -no_core_cells -no_std_cells -no_special_net -no_tracks
    # cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF320R7\") {m=\$4+16779; \$4=m}; print}" > ex1.def
    cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF320R7\") {m=\$4+9027; \$4=m}; print}" > ex1.def
    cat ex1.def | awk "{if (NF > 10 && \$3 == \"SPRBUF320R7\") {m=\$5+2100; \$5=m}; print}" > ex2.def
    read_def ex2.def

    # set the Super-Buffer at MX orientation and the site-rows + Enabling 60u as a legal movement
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR7X320 }] .place_status placed
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR7X320 }] .orient mx
    set_db [get_db rows  -if {.site.name == SPRBUF320R7}] .orient mx
    set_db place_detail_eco_max_distance 400
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR7X320 }] .base_cell.site SPRBUF320R7

    # Legalizing on the "special" site rows
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR7X320 }] .name]

    # remove the site rows, verify the Super-Buffers are at MX orientation and change their link to default sites
    delete_obj [get_db rows -if {.site.name == SPRBUF320R7}]
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR7X320 }] .orient mx
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR7X320 }] .base_cell.site CORE_6

    # legalize place again to see that there are no movements
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR7X320 }] .name]
    set_db place_detail_eco_max_distance 0.0
}

proc _legalize_SPRBUF320T7 { {relevant_base_cells  {F6UNAA_LPDSINVGT7X320} } } {
    # spread the iste rows of the Super Buffers legal locations
    create_row -site SPRBUF320T7 -polygon {{705.432 5.25} {705.432 1038.24} {0.0 1038.24} {0.0 8940.96} \
                                           {9713.256 8940.96} {9713.256 8678.88} {9876.048 8678.88} {9876.048 4465.44} \
                                           {9821.784 4465.44} {9821.784 4243.68} {9876.048 4243.68} {9876.048 231.84} \
                                           {9821.784 231.84} {9821.784 5.25}} -spacing 8.61 -no_abut -no_flip_rows

    # write def, move X by 8.3895, read it to the design
    write_def ex.def -no_core_cells -no_std_cells -no_special_net -no_tracks
    # cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF320T7\") {m=\$4+16779; \$4=m}; print}" > ex1.def
    cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF320T7\") {m=\$4+9027; \$4=m}; print}" > ex1.def
    cat ex1.def | awk "{if (NF > 10 && \$3 == \"SPRBUF320T7\") {m=\$5+2520; \$5=m}; print}" > ex2.def
    read_def ex2.def

    # set the Super-Buffer at MX orientation and the site-rows + Enabling 60u as a legal movement
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT7X320 }] .place_status placed
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT7X320 }] .orient mx
    set_db [get_db rows  -if {.site.name == SPRBUF320T7}] .orient mx
    set_db place_detail_eco_max_distance 400
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT7X320 }] .base_cell.site SPRBUF320T7

    # Legalizing on the "special" site rows
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT7X320 }] .name]

    # remove the site rows, verify the Super-Buffers are at MX orientation and change their link to default sites
    delete_obj [get_db rows -if {.site.name == SPRBUF320T7}]
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT7X320 }] .orient mx
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT7X320 }] .base_cell.site CORE_6

    # legalize place again to see that there are no movements
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGT7X320 }] .name]
    set_db place_detail_eco_max_distance 0.0
}

proc _legalize_SPRBUF192R5 { {relevant_base_cells  {F6UNAA_LPDSINVGR5X192} } } {
    # spread the iste rows of the Super Buffers legal locations
    create_row -site SPRBUF192R5 -polygon {{705.432 5.25} {705.432 1038.24} {0.0 1038.24} {0.0 8940.96} \
                                           {9713.256 8940.96} {9713.256 8678.88} {9876.048 8678.88} {9876.048 4465.44} \
                                           {9821.784 4465.44} {9821.784 4243.68} {9876.048 4243.68} {9876.048 231.84} \
                                           {9821.784 231.84} {9821.784 5.25}} -spacing 4.2 -no_abut -no_flip_rows

    # write def, move X by 8.3895, read it to the design
    write_def ex.def -no_core_cells -no_std_cells -no_special_net -no_tracks
    # cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF192R5\") {m=\$4+16779; \$4=m}; print}" > ex1.def
    cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF192R5\") {m=\$4+9027; \$4=m}; print}" > ex1.def
    cat ex1.def | awk "{if (NF > 10 && \$3 == \"SPRBUF192R5\") {m=\$5+2100; \$5=m}; print}" > ex2.def
    read_def ex2.def

    # set the Super-Buffer at r0 orientation and the site-rows + Enabling 60u as a legal movement
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X192 }] .place_status placed
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X192 }] .orient r0
    set_db [get_db rows  -if {.site.name == SPRBUF192R5}] .orient r0
    set_db place_detail_eco_max_distance 400
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X192 }] .base_cell.site SPRBUF192R5

    # Legalizing on the "special" site rows
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X192 }] .name]

    # remove the site rows, verify the Super-Buffers are at r0 orientation and change their link to default sites
    delete_obj [get_db rows -if {.site.name == SPRBUF192R5}]
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X192 }] .orient r0
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X192 }] .base_cell.site CORE_6

    # legalize place again to see that there are no movements
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X192 }] .name]
    set_db place_detail_eco_max_distance 0.0
}


proc _legalize_SPRBUF96R5 { {relevant_base_cells  {F6UNAA_LPDSINVGR5X96} } } {
    # spread the iste rows of the Super Buffers legal locations
    create_row -site SPRBUF96R5 -polygon {{705.432 5.25} {705.432 1038.24} {0.0 1038.24} {0.0 8940.96} \
                                           {9713.256 8940.96} {9713.256 8678.88} {9876.048 8678.88} {9876.048 4465.44} \
                                           {9821.784 4465.44} {9821.784 4243.68} {9876.048 4243.68} {9876.048 231.84} \
                                           {9821.784 231.84} {9821.784 5.25}} -spacing 6.72 -no_abut -no_flip_rows

    # write def, move X by 8.3895, read it to the design
    write_def ex.def -no_core_cells -no_std_cells -no_special_net -no_tracks
    # cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF96R5\") {m=\$4+16779; \$4=m}; print}" > ex1.def
    cat ex.def  | awk "{if (NF > 10 && \$3 == \"SPRBUF96R5\") {m=\$4+9027; \$4=m}; print}" > ex1.def ; # This offset is off by 0.2um - but using the correct 9427 offset does not work
    cat ex1.def | awk "{if (NF > 10 && \$3 == \"SPRBUF96R5\") {m=\$5+2100; \$5=m}; print}" > ex2.def
    read_def ex2.def

    # set the Super-Buffer at MX orientation and the site-rows + Enabling 60u as a legal movement
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X96 }] .place_status placed
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X96 }] .orient mx
    set_db [get_db rows  -if {.site.name == SPRBUF96R5}] .orient mx
    set_db place_detail_eco_max_distance 400
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X96 }] .base_cell.site SPRBUF96R5

    # Legalizing on the "special" site rows
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X96 }] .name]

    # remove the site rows, verify the Super-Buffers are at MX orientation and change their link to default sites
    delete_obj [get_db rows -if {.site.name == SPRBUF96R5}]
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X96 }] .orient mx
    set_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X96 }] .base_cell.site CORE_6

    # legalize place again to see that there are no movements - expect a 0.2um movement
    place_detail -inst [get_db [get_db insts -if {.base_cell.name == F6UNAA_LPDSINVGR5X96 }] .name]
    set_db place_detail_eco_max_distance 0.0
}

proc super_inv_legalizer { {cells ""} } {
    
    # This array defines row vertical spacing (Y lego - cell height) and Y and X offset when spreading the using the def
    array unset base_cells_attributes
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:spacing)  [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGT5X96] .bbox.ur.y]
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:site)     SPRBUF
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:XDefOff)  9027
    set base_cells_attributes(F6UNAA_LPDSINVGT5X96:YDefOff)  2520
    
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:spacing)  [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGR5X96] .bbox.ur.y]
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:site)     SPRBUF96R5
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:XDefOff)  9027
    set base_cells_attributes(F6UNAA_LPDSINVGR5X96:YDefOff)  2100
    
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:spacing) [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGT7X320] .bbox.ur.y]
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:site)    SPRBUF320T7
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:XDefOff) 9027
    set base_cells_attributes(F6UNAA_LPDSINVGT7X320:YDefOff) 2520

    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:spacing) [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGR7X320] .bbox.ur.y]
    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:site)    SPRBUF320R7
    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:XDefOff) 9027
    set base_cells_attributes(F6UNAA_LPDSINVGR7X320:YDefOff) 2100

    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:spacing) [expr 10.08 - [get_db [get_db base_cells F6UNAA_LPDSINVGR5X192] .bbox.ur.y]
    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:site)    SPRBUF192R5
    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:XDefOff) 9027
    set base_cells_attributes(F6UNAA_LPDSINVGR5X192:YDefOff) 2100                
    
    # Polygon to spread the rows by
    set poly [get_db designs .boundary]

    foreach key [array names base_cells_attributes *site*] {
        
        set base_cell [lindex [split $key ":"] 0]
        set site      $base_cells_attributes($base_cell:site)
        set spacing   $base_cells_attributes($base_cell:spacing)
        set XDefOff   $base_cells_attributes($base_cell:XDefOff)
        set YDefOff   $base_cells_attributes($base_cell:YDefOff)
        
        if { [set cells [get_db insts -if .base_cell.name==$base_cell]] == "" } { continue }
        
        puts "-I- Legalizing [llength $cells] cells of type $base_cell (super_inv_legalizer)"
        
        # Save orig lef file, and update lef
        set orig_lef_file [get_db [get_db base_cells $base_cell] .lef_file_name]
        update_lef_macro -macro $base_cell ./scripts/templates/quad/super_bufs/tsmc5ff_ck06t0750v.lef 
        
        # spread the iste rows of the Super Buffers legal locations
        create_row -site $site -polygon $poly -spacing $spacing -no_abut -no_flip_rows

        # write def, move X by 8.3895, read it to the design
        write_def ex.def -no_core_cells -no_std_cells -no_special_net -no_tracks
        cat ex.def  | awk "{if (NF > 10 && \$3 == \"$site\") {m=\$4+$XDefOff; \$4=m}; print}" > ex1.def ; # This offset is off by 0.2um - but using the correct 9427 offset does not work
        cat ex1.def | awk "{if (NF > 10 && \$3 == \"$site\") {m=\$5+$YDefOff; \$5=m}; print}" > ex2.def
        read_def ex2.def

        # set the Super-Buffer at MX orientation and the site-rows + Enabling 60u as a legal movement
        set_db $cells .place_status placed
        set_db $cells .orient mx
        set_db [get_db rows  -if {.site.name == $site}] .orient mx
        set_db place_detail_eco_max_distance 400
        set_db $cells .base_cell.site $site

        # Legalizing on the "special" site rows
        place_detail -inst [get_db $cells .name]

        # remove the site rows, verify the Super-Buffers are at MX orientation and change their link to default sites
        delete_obj [get_db rows -if {.site.name == $site}]
        set_db $cells .orient mx
        set_db $cells .base_cell.site CORE_6

        # legalize place again to see that there are no movements - expect a 0.2um movement
        place_detail -inst [get_db $cells .name]
        set_db place_detail_eco_max_distance 0.0

        # Change back to orig lef file
        update_lef_macro -macro $base_cell $orig_lef_file
        
    }
    
}

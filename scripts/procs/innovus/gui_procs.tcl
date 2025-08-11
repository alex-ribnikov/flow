proc ory_add_my_manu {} {
    # Reference in: https://support.cadence.com/apex/techpubDocViewerPage?path=UGcom/UGcom21.13/Customizing_the_User_Interface.html
    ory_delete_my_manu
    
    gui_add_ui MyManu    -type menu -label MyManu -in main
#    gui_add_ui MyCommand -type command -label "get_cells -of..." -command [list eval "so \[get_cells -of \[get_db selected\]\]"] -in MyManu
#    gui_add_ui MyCommand -type command -label "get_pins -of..."  -command [list eval "so \[get_pins -of \[get_db selected\]\]"] -in MyManu
#    gui_add_ui MyCommand -type command -label "get_nets -of..."  -command [list eval "so \[get_nets -of \[get_db selected\]\]"] -in MyManu    

    set cmd "set_layer_preference pgPower -is_visible 0 ; set_layer_preference pgGround -is_visible 0 ;\
             set_layer_preference node_layer -is_visible 0 ; set_layer_preference M17 -is_visible 1 ;  \
             set_layer_preference VIA16 -is_visible 1 ; set_layer_preference M16 -is_visible 1"    
    gui_add_ui MyCmd  -type command    -label "M16M17_NoPG"      -command "$cmd" -in MyManu

    set cmd "check_all_quad_cells \[gs\] ; puts \"-I- Done\""
    gui_add_ui MyCmd  -type command  -label "check_cells_pin_alignment" -command "$cmd" -in MyManu
    
    set cmd "align_pins_b2i_wdef \[gs .name\] true true ; puts \"-I- Done\""
    gui_add_ui MyCmd  -type command  -label "align_cell_b2i_wdef" -command "$cmd" -in MyManu
    
#    gui_add_ui sep     -type separator -in MyManu
#    
#    gui_add_ui MyCommand -type command -label "get_clock_source..."  -command [list eval "so \[get_db \[get_clocks\] .sources\]"] -in MyManu    
        
    
}

proc ory_delete_my_manu {} {
    set viewMenu [gui_find_ui -type menu -label "MyManu"]
    foreach v $viewMenu { gui_delete_ui $v }
}

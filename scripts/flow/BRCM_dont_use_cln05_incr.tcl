### Dont_use scripts mainly for synthesis, can be used for ICC
### User to specify if apc FFs are needed 
### User to specify if latches are needed
## Async Preset Clear
set apc no
## Async Clear
set ac no
## Async Preset
set ap no
## Latches
set latch no

#UL opened up and buffered FFs hidden
set_attribute [get_lib_cells -regexp -quiet .*/F6UL.*] dont_use false
set_attribute [get_lib_cells -regexp -quiet .*/F6.*BSDFF.*] dont_use true

#            F6.*BSDFFR.* \
#            F6.*BSDFFS.* \
#            F6.*BSDFFRS.* \

set DONT_USE_LIST [ list \
            F6.*_LCAPX.* \
            F6.*_CK.* \
            F6.*_CKRCVRX.* \
            F6.*BORDER.* \
            F6.*DLY.* \
            F6.*BDFF.* \
            F6.*BSDFFM.* \
            F6.*CCCAP.* \
            F6.*CDM.* \
            F6.*DIODE.* \
            F6.*FILLER.* \
            F6.*BDLATN.* \
            F6.*BDLATR.* \
            F6.*BDLATX.* \
            F6.*_DLAT.* \
            F6.*BSDFFCW2.* \
            F6.*BSDFFCW4.* \
            F6.*BSDFFRW2.* \
            F6.*BSDFFRW4.* \
            F6.*BSDFFW2.* \
            F6.*BSDFFW4.* \
            F6.*CKEN.* \
            F6.*LCAP.* \
            F6.*LPD.* \
            F6.*CKRCVR.* \
            F6.*SYNC.* \
            F6.*TRI.* \
            F6.*TOP.* \
            F6.*_SDFFM.* \
            F6.*_DFF.* \
            F6.*TIEG.* \
            F6.*G_.* \
            F6.*BSDFF.* \
            F6.*_AO222.* \
]

  foreach cell ${DONT_USE_LIST} {
    echo "# Checking $cell"
    set_attribute [get_lib_cells -regexp -quiet .*/$cell] dont_use true
  }

if { $apc == "yes" } {
remove_attribute [get_lib_cells -regexp .*/F6.*BSDFFRS.*] dont_use
}
if { $ac == "yes" } {
remove_attribute [get_lib_cells -regexp .*/F6.*BSDFFR.*] dont_use
}
if { $ap == "yes" } {
remove_attribute [get_lib_cells -regexp .*/F6.*BSDFFS.*] dont_use
}
## Clock gating cell
#remove_attribute [get_lib_cells -regexp */F6LNAA_CKENOAX12] dont_use

### Have a latch available if needed
if { $latch == "yes" } {
remove_attribute [get_lib_cells -regexp .*/F6.*BDLATX.*] dont_use
remove_attribute [get_lib_cells -regexp .*/F6.*BDLATN.*] dont_use
}

## Disable u/elvt/svt
set_attribute [get_lib_cells -regexp -quiet .*/F6UN.*] dont_use true
set_attribute [get_lib_cells -regexp -quiet .*/F6EN.*] dont_use true
set_attribute [get_lib_cells -regexp -quiet .*/F6SN.*] dont_use true

# Tap controller logic needs negedge flops
#remove_attribute [get_lib_cells */F6LLAA_DFFNX*] dont_use
#remove_attribute [get_lib_cells */F6LNAA_DFFNX*] dont_use
#
#remove_attribute [get_lib_cells */F6LLAA_DFFNRSX*] dont_use
#remove_attribute [get_lib_cells */F6LNAA_DFFNRSX*] dont_use

##dont use on physical variants
set_attribute [get_lib_cells -regexp -quiet .*/F6LNBA_.*] dont_use true
set_attribute [get_lib_cells -regexp -quiet .*/F6LNCA_.*] dont_use true
set_attribute [get_lib_cells -regexp -quiet .*/F6LNDA_.*] dont_use true
set_attribute [get_lib_cells -regexp -quiet .*/F6LLBA_.*] dont_use true
set_attribute [get_lib_cells -regexp -quiet .*/F6LLCA_.*] dont_use true
set_attribute [get_lib_cells -regexp -quiet .*/F6LLDA_.*] dont_use true

##dont_use on tie cells
set_attribute [get_lib_cells   */F6*TIELO*] dont_use true
set_attribute [get_lib_cells   */F6*TIEHI*] dont_use true


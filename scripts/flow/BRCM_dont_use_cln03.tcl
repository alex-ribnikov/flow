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



remove_attribute [get_lib_cells -regexp .*/E.*] dont_use

#            F6.*BSDFFR.* \
#            F6.*BSDFFS.* \
#            F6.*BSDFFRS.* \

set DONT_USE_LIST [ list \
    E.*DLY.* \
    E.*_LPD.* \
    E.*_.*DLAT.* \
    E.*_CK.* \
    E.*_TOP.*  \
    E.*_BDFF.*  \
    E.*_TRI.*  \
    E.*_DFF.*  \
    E.*_SDFF.* \
    E.*CDM.*  \
    E.*RESYNC.*  \
    E.*G_.*  \
    E1.*DFF.* \
    E2.*A_ONAI22L4X8 \
    E2.*A_ONAI22X8 \
    E.*LCAP.* \
    E.*SYNC.*  \
    E.*BDFF.*  \
    E.*BORDER.*  \
    E.*CCAP.*  \
    E.*DIODE.*  \
    E.*FILLER.* \
    E.*_FANCRSX.* \
    E.*_FANCR2X.* \
    E.*_BSELX.* \
    E.*_ISOLAT.* \
    \
    E.*_AO2222X1 \
    E.*_AO2222V1X1 \
    E.*X30 \
    E.*X27 \
    E.*X24 \
]

  foreach cell ${DONT_USE_LIST} {
    echo "# Checking $cell"
    set_attribute [get_lib_cells -regexp -quiet .*/$cell] dont_use true
  }

if { $apc == "yes" } {
remove_attribute [get_lib_cells -regexp .*/E.*BSDFFRS.*] dont_use
}
if { $ac == "yes" } {
remove_attribute [get_lib_cells -regexp .*/E.*BSDFFR.*] dont_use
}
if { $ap == "yes" } {
remove_attribute [get_lib_cells -regexp .*/E.*BSDFFS.*] dont_use
}
## Clock gating cell
#remove_attribute [get_lib_cells -regexp */F6LNAA_CKENOAX12] dont_use

### Have a latch available if needed
if { $latch == "yes" } {
remove_attribute [get_lib_cells -regexp .*/E.*BDLATX.*] dont_use
remove_attribute [get_lib_cells -regexp .*/E.*BDLATN.*] dont_use
}

## Disable u/elvt/svt
set_attribute [get_lib_cells -regexp -quiet .*/E?UN.*] dont_use true
set_attribute [get_lib_cells -regexp -quiet .*/E?EN.*] dont_use true
set_attribute [get_lib_cells -regexp -quiet .*/E?SN.*] dont_use true

# Tap controller logic needs negedge flops
#remove_attribute [get_lib_cells */F6LLAA_DFFNX*] dont_use
#remove_attribute [get_lib_cells */F6LNAA_DFFNX*] dont_use
#
#remove_attribute [get_lib_cells */F6LLAA_DFFNRSX*] dont_use
#remove_attribute [get_lib_cells */F6LNAA_DFFNRSX*] dont_use

##dont use on physical variants
#set_attribute [get_lib_cells -regexp -quiet .*/F6LNBA_.*] dont_use true
#set_attribute [get_lib_cells -regexp -quiet .*/F6LNCA_.*] dont_use true
#set_attribute [get_lib_cells -regexp -quiet .*/F6LNDA_.*] dont_use true
#set_attribute [get_lib_cells -regexp -quiet .*/F6LLBA_.*] dont_use true
#set_attribute [get_lib_cells -regexp -quiet .*/F6LLCA_.*] dont_use true
#set_attribute [get_lib_cells -regexp -quiet .*/F6LLDA_.*] dont_use true

##dont_use on tie cells
set_attribute [get_lib_cells   */E*TIELO*] dont_use true
set_attribute [get_lib_cells   */E*TIEHI*] dont_use true

remove_attribute [get_lib_cells -regexp .*/E5UNRA_LPDCKENOAX16] dont_use

if {[info exists STAGE] && $STAGE == "syn"} {
   set ILM_FILES " \
   /bespace/users/royl/libs_comp/be_work/snpsn5/lcb/rtl7.2.1/syn_phys/out/ilm \
   "
} else {
   set ILM_FILES " \
   /bespace/users/royl/libs_comp/be_work/snpsn5/lcb/rtl7.2.1/pnr_phys/out/ilm/${STAGE} \
   "
   set LEF_FILE_LIST "$LEF_FILE_LIST \
   	/bespace/users/royl/libs_comp/be_work/snpsn5/lcb/rtl7.2.1/pnr_phys/out/lef/lcb.place.lef \
   "
}


set SCAN_ABSTRUCT " \
/bespace/users/royl/libs_comp/be_work/snpsn5/lcb/rtl7.2.1/syn_phys/out/lcb.Syn.scan.abstract \
"

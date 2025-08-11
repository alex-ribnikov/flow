#------------------------------------------------------------------------------
# read design setting
#------------------------------------------------------------------------------
if {[file exists ./scripts_local/setup.tcl]} {
	puts "-I- reading setup file from scripts_local"
	source -v ./scripts_local/setup.tcl
} else {
	puts "-I- reading setup file from scripts"
	source -v ./scripts/setup/setup.${PROJECT}.tcl
}

if {[file exists ../inter/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from ../inter "
	source -v ../inter/supplement_setup.tcl
}

if {[file exists scripts_local/supplement_setup.tcl]} {
	puts "-I- reading supplement_setup file from scripts_local"
	source -v scripts_local/supplement_setup.tcl
}

if {[info exists CREATE_LIB] && $CREATE_LIB == "true" && $STAGE == "syn"} {
	puts "-I- take scenarios from mmmc_setup file for stage $STAGE."
} elseif {[llength $VIEWS] == 1} {
	set scenarios(setup) $VIEWS ;  set scenarios(hold) $VIEWS ; set scenarios(dynamic) "" ; set scenarios(leakage) ""
} else {
	set scenarios(setup) [list] ;  
	set scenarios(hold) [list] ; 
	set scenarios(dynamic) "" ; 
	set scenarios(leakage) ""
	foreach _VIEW $VIEWS {
		set VIEW_SPLIT [split $_VIEW "_"]
		set check [lindex $VIEW_SPLIT end]
		if {$check == "setup" } {
			lappend scenarios(setup) $_VIEW
		} elseif {$check == "hold" } {
			lappend scenarios(hold) $_VIEW
		} else {
			lappend scenarios(setup) $_VIEW
			lappend scenarios(hold) $_VIEW
		}
	}
}

read_mmmc $mmmc_results


if {[info exists PHYSICAL] && $PHYSICAL == "true"} {
	read_physical -lef $LEF_FILE_LIST
}

#------------------------------------------------------------------------------
# read  design
#------------------------------------------------------------------------------
read_netlist -top ${DESIGN_NAME} $NETLIST_FILE_LIST
init_design

#------------------------------------------------------------------------------
# read tool variables
#------------------------------------------------------------------------------
if {[file exists scripts_local/TEMPUS_variables.tcl]} {
	puts "-I- reading TEMPUS_variables file from scripts_local"
	source -v scripts_local/TEMPUS_variables.tcl
} else {
	puts "-I- reading TEMPUS_variables file from scripts"
	source -v scripts/flow/TEMPUS_variables.tcl
}


#------------------------------------------------------------------------------
# read physical variables
#------------------------------------------------------------------------------
set cmd "regexp {${DESIGN_NAME}.(.*).enc} [lindex $NETLIST_FILE_LIST [lsearch $NETLIST_FILE_LIST *${DESIGN_NAME}*]] match INN_STAGE"
eval $cmd

if {[info exists INN_STAGE] && [info exists PHYSICAL] && $PHYSICAL == "true"} {
	puts "-I- reading physical design from $INNOVUS_DIR/out/def/${DESIGN_NAME}.$INN_STAGE.def.gz"
	##### read def file(s)
	read_hierarchical_def $INNOVUS_DIR/out/def/${DESIGN_NAME}.$INN_STAGE.def.gz 
	#check_place -no_preplaced
}

#set_db distributed_mmmc_disable_reports_auto_redirection true

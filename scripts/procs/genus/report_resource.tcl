############################################################################################
## print to screen resource usage
############################################################################################
proc report_resource {} {
	set CPU_RUNTIME [get_db cpu_runtime]
	set TOTAL_SEC [expr int(fmod(int($CPU_RUNTIME),60))]
	set TOTAL_MIN [expr int(fmod(int($CPU_RUNTIME/60),60))]
	set TOTAL_HOUR [expr int($CPU_RUNTIME/60/60)]
	
	set REAL_RUNTIME [get_db real_runtime]
	set REAL_SEC [expr int(fmod(int($REAL_RUNTIME),60))]
	set REAL_MIN [expr int(fmod(int($REAL_RUNTIME/60),60))]
	set REAL_HOUR [expr int($REAL_RUNTIME/60/60)]
	
	
	puts "Current (total cpu=$TOTAL_HOUR:$TOTAL_MIN:$TOTAL_SEC, real=$REAL_HOUR:$REAL_MIN:$REAL_SEC, peak res=[get_db peak_memory]M, current mem=[get_db memory_usage]M"
}

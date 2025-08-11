::parseOpt::cmdSpec hk_pull_vt {
    -help "Get VT cell area "
    -opt {
        {-optname insts_pattern  -type string   -default ""    -required 1 -help "Hier pattern.  "}
        {-optname comp  -type string   -default ""    -required 0 -help "Possible data compression level (high/low). default is low ."}
        {-optname level      -type integer -default -1       -required 0 -help "Default is -1 means find lowest hier."}
        {-optname all      -type boolean -default false   -required 0 -help "Calculate all hiers and might take a while."}
                
    }
}
proc hk_pull_vt { args } { 
#puts "[::ory_time::now]"  
	if { ! [::parseOpt::parseOpt hk_pull_vt $args] } { return 0 }             
    set insts_name_pattern $opt(-insts_pattern)
    set comp_level $opt(-comp)
    set level  $opt(-level)
	set many $opt(-all)
    #puts $level 
    if { $insts_name_pattern != "" } {
        set instants      [get_db insts -if .name==$insts_name_pattern]
        if {$level == -1} {
        foreach instant $instants {
        if { [get_db program_short_name] == "genus" } {
        set a [get_db  $instant  .name]        
        set i_level [expr [regexp -all / $a  +2]]      
        if {$i_level > $level } {
        set level $i_level
        }
        } elseif {[get_db $instant .hierarchical_level] > $level } {
        set level [get_db $instant .hierarchical_level]
        }
        } 
        } 
                
     
    }
    
     
    puts "Highest level is : $level"      
    	
    if { $comp_level == "high" } {
    #puts "here"
    	regsub -all "\[0-9\]+" [get_db $instants .parent.name ] "*" all_parents_names
    } else {
    	regsub -all "\\\[\[0-9\]+\\\]" [get_db $instants .parent.name ] "\[*\]" all_parents_names
    }
    #puts "$all_parents_names"
#puts "[::ory_time::now]"    
    array unset res_arr        
    set pattern "\[a-zA-Z0-9_\*\]+/"
    set reg_phrase [string repeat $pattern $level ]
    foreach name [lsort -u $all_parents_names] {
        regexp $reg_phrase $name name
        set name [string trim $name "/"]
        if { [info exists res_arr($name)] } {
            lappend res_arr($name) $name        
        } else {
            set res_arr($name) [list $name]
        }
    }
    
#puts "[::ory_time::now]"    

    set size [array size res_arr]
    puts "Hier numbers to calulate: $size"
    if {$size >  100} {
    if {!$many} {
    puts "Too many hiers. For overriding anyway use -all flag."
    return}}
    
    #return
    array unset hier_arr
    array unset top_arr
    array unset vt_rule_arr    
    set vt_rule_arr(snpsn5:svt)    "*SVT06*"
    set vt_rule_arr(snpsn5:lvt)    "*LVT06*"
    set vt_rule_arr(snpsn5:lvtll)  "*LVTLL06*"
    set vt_rule_arr(snpsn5:ulvt)   "*ULT06*"
    set vt_rule_arr(snpsn5:ulvtll) "*ULTLL06*"
    
    set vt_rule_arr(snpsn7:svt)    "*SVT*"
    set vt_rule_arr(snpsn7:lvt)    "*LVT*"
    set vt_rule_arr(snpsn7:ulvt)  "*ULT*"
    
    # TSMC
    set vt_rule_arr(tsmcn5:svt)    "*DSVT"
    set vt_rule_arr(tsmcn5:lvt)    "*DLVT"
    set vt_rule_arr(tsmcn5:lvtll)  "*DLVTLL"
    set vt_rule_arr(tsmcn5:ulvt)   "*DULVT"
    set vt_rule_arr(tsmcn5:ulvtll) "*DULVTLL"
    
    set vt_rule_arr(tsmcn7:svt)    "*DSVT"
    set vt_rule_arr(tsmcn7:lvt)    "*DLVT"
    set vt_rule_arr(tsmcn7:ulvt)   "*DULVT"    
    
    # BRCM
    set vt_rule_arr(brcmn7:svt)    "P6S*"
    set vt_rule_arr(brcmn7:lvt)    "P6L*"
    set vt_rule_arr(brcmn7:ulvt)   "P6U*"    
    
    set vt_rule_arr(brcmn5:LL)     "F6LL*"
    set vt_rule_arr(brcmn5:LN)     "F6LN*"
    set vt_rule_arr(brcmn5:UL)     "F6UL*"
    set vt_rule_arr(brcmn5:UN)     "F6UN*"       
    set vt_rule_arr(brcmn5:EN)     "F6EN*" 
           
    set vt_groups_list [list brcmn5 tsmcn5 snpsn5 brcmn7 tsmcn7 snpsn7]
    ############################################################################
    set node "n[get_db design_process_node]"
    set process ""
    foreach group [regexp -inline -all "\[a-zA-Z\]+$node" $vt_groups_list] {    
        foreach sub_group [array names vt_rule_arr $group*] {            
            if { [llength [get_db base_cells $vt_rule_arr($sub_group)]] > 0 } { set process "[lindex [split $sub_group ":"] 0]" ; break }
        }
        if { $process != "" } { break }   
    }
    if { $process == "" } { 
        puts "-E- Could not determine process"
        return -1
    }
    ############################################################################
	#set node "n[get_db design_process_node]"
	#set lib  [lindex [get_db [get_db [get_db lib_cells] .library] .files] 0]
    #if { [string match "*SNPS*" $lib] } {
    #	set vendor "snps"
    #    set header [list Hier lvt lvt% lvtll lvtll% svt svt% ulvt ulvt% ulvtll ulvtll%]
    #} elseif { [string match "*BRCM*" $lib] } {
    #	set vendor "brcm"
    #    set header [list EN LL LN UN ]
    #} else {
    #	set vendor "tsmc"
        
    #}    
    #set process "${vendor}$node"
    #set process "snpsn5"            
   	if {[string compare $process "snpsn5"] ==0} {
    	set header [list Hier lvt lvt% lvtll lvtll% svt svt% ulvt ulvt% ulvtll ulvtll% Total_Area]}
    if {[string compare $process "brcmn5"] ==0} {
    	set header [list Hier EN EN% LL LL% LN LN% UL UL% UN UN% Total_Area ]}
    
    ############################################################################    
	set table {}
    set prog_b 0
    
	foreach hier [array names res_arr] {
    
    	ory_progress $prog_b $size
        set sum_area 0
        
    	set insts [get_db insts -if .name==$hier]
        set base_cells [get_db $insts .base_cell]   
        
    	redirect  -var rep1 { be_report_cells_vt -inst *$hier* }
       	set lines1 [split $rep1 "\n"]
   		
   		foreach line1 $lines1 {
        set firstWord [regexp -inline {\S+} $line1] 
               
    	if {[string compare $firstWord "Type"] ==0  || [string compare $firstWord "-------+-------+--------+---------+--------"] ==0 ||[string compare  $firstWord "Total"]==0 || [string compare $firstWord "|"]==0}  {
            continue
            }
        if { [string compare $firstWord "lvt"] ==0 || [string compare $firstWord "EN"] ==0 } {        	
            set numbers1 [regexp -all -inline -- {[0-9].|[0-9]+.[0-9]+%?} $line1]
            #set sum_lvt [expr $sum_lvt + [lindex $numbers1 2]]
            #set numbers1 [regexp -all -inline -- {[0-9]+.[0-9]+%?} $line1]
            continue
            }
        if {[string compare $firstWord "lvtll"] ==0 || [string compare $firstWord "LL"] ==0  } {        	
            set numbers2 [regexp -all -inline -- {[0-9].|[0-9]+.[0-9]+%?} $line1]
            #set sum_lvtll [expr $sum_lvtll + [lindex $numbers2 2]]
            #set numbers2 [regexp -all -inline -- {[0-9]+.[0-9]+%?} $line1] 
            continue           
            }
        if {[string compare $firstWord "svt"]==0 || [string compare $firstWord "LN"] ==0 } {
       		 set numbers3 [regexp -all -inline -- {[0-9].|[0-9]+.[0-9]+%?} $line1]
             #set sum_svt [expr $sum_svt + [lindex $numbers3 2]]
            #set numbers3 [regexp -all -inline -- {[0-9]+.[0-9]+%?} $line1]
            continue
            }
       	if {[string compare $firstWord "ulvt"]==0 || [string compare $firstWord "UL"] ==0 } {
        	set numbers4 [regexp -all -inline -- {[0-9].|[0-9]+.[0-9]+%?} $line1]
            #set sum_ulvt [expr $sum_ulvt + [lindex $numbers4 2]]
            #set numbers4 [regexp -all -inline -- {[0-9]+.[0-9]+%?} $line1]
            continue
            }
      	 if {[string compare $firstWord "ulvtll"] ==0 || [string compare $firstWord "UN"] ==0} {
         	set numbers5 [regexp -all -inline -- {[0-9].|[0-9]+.[0-9]+%?} $line1]
            #set sum_ulvtll [expr $sum_ulvtll + [lindex $numbers5 2]]
            #set numbers5 [regexp -all -inline -- {[0-9]+.[0-9]+%?} $line1]
            continue
            }
          
   		 }
        if {[string compare $process "snpsn5"] ==0} {
        set sum_area [expr [lindex $numbers1 2] + [lindex $numbers2 2] + [lindex $numbers3 2] + [lindex $numbers4 2] + [lindex $numbers5 2]]
        lappend table [list $hier [lindex $numbers1 2]  [lindex $numbers1 3] [lindex $numbers2 2]  [lindex $numbers2 3] [lindex $numbers3 2]  [lindex $numbers3 3] [lindex $numbers4 2]  [lindex $numbers4 3] [lindex $numbers5 2]  [lindex $numbers5 3] [format "%.2f" $sum_area]]}
        if {[string compare $process "brcmn5"] ==0} {
         set sum_area [expr [lindex $numbers1 2] + [lindex $numbers2 2] + [lindex $numbers3 2] + [lindex $numbers4 2] +[lindex $numbers5 2] ]
         lappend table [list $hier [lindex $numbers1 2]  [lindex $numbers1 3] [lindex $numbers2 2]  [lindex $numbers2 3] [lindex $numbers3 2]  [lindex $numbers3 3] [lindex $numbers4 2]  [lindex $numbers4 3] [lindex $numbers5 2]  [lindex $numbers5 3] [format "%.2f" $sum_area]]}
        
    	set prog_b [expr $prog_b +1]
    	}
    puts "\n"     
           #if {[string compare $process "snpsn5"] ==0} {
        #lappend table [list "TOTALS" $sum_lvt  "---" $sum_lvtll  "---" $sum_svt  "---" $sum_ulvt  "---" $sum_ulvtll "---"]}
        #if {[string compare $process "brcmn5"] ==0} {
         #lappend table [list "TOTALS" $sum_lvt "---" $sum_lvtll "---"  $sum_svt "---" $sum_ulvt  ]}
             	               
    rls_table -table $table -header $header -spac -breaks                   
    }



proc hk_vt_by_cell {} {
    #total invs buffs combs
    set combin  [sizeof_collection [get_cells -hier -filter "is_hierarchical == false && is_combinational==true && is_buffer==false && is_inverter==false"]]
    set buffers  [sizeof_collection [get_cells -hier -filter "is_hierarchical == false && is_buffer==true "]]
    set inverters  [sizeof_collection [get_cells -hier -filter "is_hierarchical == false && is_inverter==true "]]
    set totals [list $inverters $buffers $combin]
    set objs [list "inverter" "buffer" "combinational"]
    array unset vt_rule_arr

    # Array name structure: arr(process:group_name) = pattern
    # SNPS
    set vt_rule_arr(snpsn5:svt)    "*SVT06*"
    set vt_rule_arr(snpsn5:lvt)    "*LVT06*"
    set vt_rule_arr(snpsn5:lvtll)  "*LVTLL06*"
    set vt_rule_arr(snpsn5:ulvt)   "*ULT06*"
    set vt_rule_arr(snpsn5:ulvtll) "*ULTLL06*"

    set vt_rule_arr(snpsn7:svt)    "*SVT*"
    set vt_rule_arr(snpsn7:lvt)    "*LVT*"
    set vt_rule_arr(snpsn7:ulvt)  "*ULT*"

    # TSMC
    set vt_rule_arr(tsmcn5:svt)    "*DSVT"
    set vt_rule_arr(tsmcn5:lvt)    "*DLVT"
    set vt_rule_arr(tsmcn5:lvtll)  "*DLVTLL"
    set vt_rule_arr(tsmcn5:ulvt)   "*DULVT"
    set vt_rule_arr(tsmcn5:ulvtll) "*DULVTLL"

    set vt_rule_arr(tsmcn7:svt)    "*DSVT"
    set vt_rule_arr(tsmcn7:lvt)    "*DLVT"
    set vt_rule_arr(tsmcn7:ulvt)   "*DULVT"    

    # BRCM
    set vt_rule_arr(brcmn7:svt)    "P6S*"
    set vt_rule_arr(brcmn7:lvt)    "P6L*"
    set vt_rule_arr(brcmn7:ulvt)   "P6U*"    

    set vt_rule_arr(brcmn5:LL)     "F6LL*"
    set vt_rule_arr(brcmn5:LN)     "F6LN*"
    set vt_rule_arr(brcmn5:UL)     "F6UL*"       
    set vt_rule_arr(brcmn5:UN)     "F6UN*"       
    set vt_rule_arr(brcmn5:EN)     "F6EN*"       

    set vt_groups_list [list brcmn5 tsmcn5 snpsn5 brcmn7 tsmcn7 snpsn7]    

    ############################################################################
    set node "n[get_db design_process_node]"
    set process ""
    foreach group [regexp -inline -all "\[a-zA-Z\]+$node" $vt_groups_list] {    
        foreach sub_group [array names vt_rule_arr $group*] {            
            if { [llength [get_db base_cells $vt_rule_arr($sub_group)]] > 0 } { set process "[lindex [split $sub_group ":"] 0]" ; break }
        }
        if { $process != "" } { break }   
    }

    if { $process == "" } { 
         puts "-E- Could not determine process"
         return -1
    }
    if {[string compare $process "snpsn5"] ==0} {
    	    set header [list Type lvt lvt%  lvtll lvtll% svt svt% ulvt ulvt% ulvtll ulvtll% Total_area]}
    if {[string compare $process "brcmn5"] ==0} {
        set header [list Type EN EN% LL LL% LN LN% UL UL% UN UN% Total_area]}
    set table {}

    foreach type $objs {
        #set a [expr [string compare $process "brcmn5"] ==0 ? [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6EN*]] : [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*LVT06*]]]
        #set b [expr [string compare $process "brcmn5"] ==0 ? [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6LL*]] : [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*LVTLL06*]]]
        #set c [expr [string compare $process "brcmn5"] ==0 ? [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6LN*]] : [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*SVT06*]]]
        #set d [expr [string compare $process "brcmn5"] ==0 ? [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6UL*]] : [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*ULT06*]]]
        #set e [expr [string compare $process "brcmn5"] ==0 ? [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6UN*]] : [sizeof_collection [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*ULTLL06*]]]
        set totarea [lsum [get_db [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] .area ]]
        set a [format "%.2f" [expr [string compare $process "brcmn5"] ==0 ? [lsum [get_db [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6EN*] .area]] : [lsum [get_db  [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*LVT06*] .area]]]]
        set aper [format "%.2f" [expr $a * 100 / $totarea] ]
        set b [format "%.2f" [expr [string compare $process "brcmn5"] ==0 ? [lsum [get_db [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6LL*] .area]] : [lsum [get_db  [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*LVTLL06*] .area]]]]
        set bper [format "%.2f" [expr $b * 100 / $totarea] ]
        set c [format "%.2f" [expr [string compare $process "brcmn5"] ==0 ? [lsum [get_db [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6LN*] .area]] : [lsum [get_db  [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*SVT06*] .area]]]]
        set cper [format "%.2f" [expr $c * 100 / $totarea] ]
        set d [format "%.2f" [expr [string compare $process "brcmn5"] ==0 ? [lsum [get_db [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6UL*] .area]] : [lsum [get_db  [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*ULT06*] .area]]]]
        set dper [format "%.2f" [expr $d * 100 / $totarea] ]
        set e [format "%.2f" [expr [string compare $process "brcmn5"] ==0 ? [lsum [get_db [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*F6UN*] .area]] : [lsum [get_db  [filter_collection [get_cells -hierarchical -filter "is_hierarchical==false&&is_$type==true"] ref_name=~*ULTLL06*] .area]]]]
        set eper [format "%.2f" [expr $e * 100 / $totarea] ]
        lappend table [list $type $a $aper $b $bper $c $cper $d $dper $e $eper [format "%.2f" $totarea]]
    }
    
    rls_table -table $table -header $header -spac -breaks                   
}    
   





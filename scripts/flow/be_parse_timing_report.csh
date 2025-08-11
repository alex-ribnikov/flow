#!/bin/tcsh -f

set DEL  = "HN%HN"          ;# unused string to commit substitutions with
set DEL2 = ";" 

### HELP MENU ###
#################

  # // EDIT HERE //
    set FILENAME = "be_parse_timing_report.csh"
    set help_desc  = "Parsing timing report and adding per-path summary"

  set help_menu = " \
    report:-:string:1:path to the timing reports to parse ${DEL2} \
    logic_levels:0:boolean:0:print path logic levels summary ${DEL2} \
    timing_summary:0:boolean:0:print path timing summary ${DEL2} \
    vt:0:boolean:0:print path vt summary ${DEL2} \
    output:-:string:0:path to output file ${DEL2} \
    suffix:parsed:string:0:if output is not given, output file will be <original_report>.suffix ${DEL2} \
    logic_levels_file:scripts/flow/BRCM_logic_levels.tcl:string:0:path to a file with a table of logic level threshold ${DEL2} \
  "
  # // 

set help_hdr   = "Option:Default:Type:Must:Details ${DEL2}"
set help_sep   = "======:=======:====:====:======= ${DEL2}"
  
# get column max sizes to display help table
set help_length_arr = (` echo $help_hdr $help_menu | sed "s/${DEL2}/\n/g" | awk -F ":" '{ for (i=1;i<=NF;i++) { if (length($i)>m[i]) {m[i]=length($i)} }} END {l=length(m) ; for (i=1;i<l;i++) {printf "%%-%ds%s",m[i]+2,(i==(l-1)?"":" ")} ; printf "\n"}' `) 

### parsing args ###
####################

if ( ("$argv[1]" == "-h")||($argv[$n] == "-help") ) then
  # ~ ~ HELP ~ ~#
    echo $help_desc
    echo ""
    foreach line (`echo $help_hdr $help_sep $help_menu | sed "s/\s\+/${DEL}/g;s/${DEL2}/ /g" `)
        printf "$help_length_arr" ` echo $line | sed "s/${DEL}/ /g" | awk -F \: '{for(i=1;i<NF;i++) {printf "%s ",$i}}' `
        printf "%s "              ` echo $line | sed "s/${DEL}/ /g" | sed 's/.*\://g' `
        printf "\n"
    end        
else
  # ~ ~ ARGs ~ ~ #
    foreach line (`echo $help_menu | sed "s/\s\+/${DEL}/g;s/${DEL2}/ /g" `)
        set opt  = `echo $line | awk -F : '{print $1}'`
        set type = `echo $line | awk -F : '{print $3}'`
        set must = `echo $line | awk -F : '{print $4}'`
        
        set n = 1
        while ( $n <= $#argv )
            if      ( "$argv[$n]" == "-$opt" ) then
              # arg given by user
                if  ( "$type" == "boolean" ) then
                    set opt = "1"
                else
                    @ n = ($n + 1)
                    set $opt = `echo $argv[$n]`
                endif
            else if ( $must ) then
              # if arg is a must - return
                echo "Error - argument $opt is a must for $FILENAME"  ;   return
            else            
              # set default value
                set $opt = `echo $line | awk -F : '{print $2}'`
            endif
            @ n = ($n + 1)
        end
    end        
endif

## exceptions and sub-defaults
if ( ($vt == "0")&&($logic_levels == "0")&&($timing_summary == "0") ) then
    @ timing_summary = 1
endif
if ( $output == "-" ) then
    set output = "${report}.${suffix}"
endif

### supporting only logic_levels for now
@ timing_summary = 0
@ vt = 0
@ logic_levels = 1

### Parsing Timing Report ###
#############################

if () 

set freq_table   = `cat $logic_levels_file | awk '{if ($1~/[0-9]+/) {printf "%d ",$1}} END {printf "\n"}' `
set levels_table = `cat $logic_levels_file | awk '{if ($1~/[0-9]+/) {printf "%d ",$2}} END {printf "\n"}' `

cat $report | awk -v V=$vt -v T=$timing_summary -v L=$logic_levels -v O=$output -v S=$out_sum -v TF=$freq_table -v TL=$levels_table ' \
BEGIN {
} 
{ 
  if (($0~/^  Startpoint/)||($0~/^Path [0-9]/)) {  
      z="## Printing Path and summaries ##" ;
      if (ln>0) { 
        
      } 
      z="## Reset variables for new path ##"
      p=1 ; lines="" ; ln=1 ; lines[ln]="$0" ; prd=0
      lgc_buf=0 ; lgc_cmb=0 
  }
  if (p) {
  
  }
}'

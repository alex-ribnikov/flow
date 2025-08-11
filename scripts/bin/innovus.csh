#!/bin/tcsh -f

if (! $?BEROOT) then       
  set BEROOT = `pwd`
endif

set inv_cmd = "source $BEROOT/be_scripts/source_be_scripts.tcl ; init_be_scripts"

if ($#argv == 0) then
    mkdir -p $BEROOT/innovus/logs/ 
    innovus -stylus -no_gui -log "$BEROOT/innovus/logs/innovus_`date +%y%m%d`_`date +%H%M`"  -execute "$inv_cmd" 
else 
    
    set load    = ""
    set read_db = ""    
    set source  = ""        
    set index = 1
    foreach arg ($argv )
       @ index = $index + 1
       switch ($arg)
       case '-help':
           echo ""
           echo "-?- innovus.csh will launch innovus and source be_scripts "
           echo ""
           echo "-?- Options: "
           echo "    -load    :\tExpect a folder name or .db pointer."
           echo "              \tIn case of a folder name (i.e. synLogical) will load the latest .db file on it's /out sub-folder"           
           echo "    -read_db :\tExpect .db pointer."           
           echo "    -source  :\tAny file you wish to source after loading your design"                      
           echo ""       
           exit       
       case '-load':
           set load   = `eval echo \$$index`
           echo "-I- Load: $load"
           breaksw
       case '-read_db':
           set read_db   = `eval echo \$$index`
           echo "-I- Read_db: $source"
           breaksw           
       case '-source':
           set source   = `eval echo \$$index`
           echo "-I- Source: $source"
           breaksw           
       default:
           breaksw           
       endsw
    end

    # If load == stage == folder, cd to it and find the latest .db 
    if ( "$load" != "" ) then 
        set sum = `echo $load | grep -o "/" | wc -l`

        if ( "$sum" == "0" ) then 
            set folder =  $load                   
            set inv_cmd = "$inv_cmd ; cd $folder " 

            # Find latest db in area
            set last_enc_dat = `ls -ltr $folder/out/ | grep enc.dat | tail -1 | awk '{print $9}' `

            if ( "$last_enc_dat" == "" ) then
                echo "-E- No *.enc.dat file found on $folder/out"
                exit
            endif 
            set db = `realpath $folder/out/$last_enc_dat`
        else 
            if ( ! -e $load  ) then
                echo "-E- No .db file found on $load"
                exit
            endif 
            set db = $load
            set folder =  `dirname "$db"`
            set folder =  `dirname "$folder"`

            set inv_cmd = "$inv_cmd ; cd $folder "     

        endif 
    endif 

    if ( "$read_db" != "" ) then
        set db = $read_db
        set folder =  `dirname "$db"`
        set folder =  `dirname "$folder"`

        set inv_cmd = "$inv_cmd ; cd $folder "     
        
    endif

    if ( "$db" == "" || ! -e $db ) then
        echo "-E- No *.enc.dat found!"
        exit
    endif
    
    set inv_cmd = "$inv_cmd ; read_db `realpath $db` ; init_be_scripts true"

    if ( $source != "" ) then 
        set inv_cmd = "$inv_cmd ; source $source -e -v "        
    endif

    mkdir -p $folder/innovus/logs/ 
    innovus -stylus -no_gui -log "$folder/innovus/logs/innovus_`date +%y%m%d`_`date +%H%M`"  -execute "$inv_cmd"    
    
endif 






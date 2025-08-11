#!/bin/tcsh

set help = " \n \
###################################### \n \
 \n \
How to run:  \n \
source setup.csh <-options> \n \
 \n \
Options: \n \
\t    -wa: Work area folder - Must \n \
\t     + Provide full path be_work/<project>/<block>/<new folder name> \n \
\t\t         On this case -b and -p are optional \n \
\t\t         Block and project will be taken from this path! \n \
\t     + Provide just <new folder name> \n \
\t\t         On this case you must provide block and project name! \n \
\t    -b : block name    - Optional. \n \
\t    -p : project name - Optional. \n \
\t    -bi: blocksinfo.json file - Optional \n \
\t\t         Default blocksinfo will come from REPO_SOURCE/scripts. \n \
\t    -wb:  must (default) / all / none \n \
\t\t         Decides what templates to fetch. \n \
\t\t         'must' (default) is what in "`echo $`"PROJFLOW/templates/must/. \n \
\t\t         'all'  is also what in "`echo $`"PROJFLOW/templates/wb_examples/. \n \
\t\t         'none' will copy nothing but "`echo $`"PROJFLOW/templates/must/setup.tcl . \n \
\t    -local_modules:  Boolean. No value. Default is false. \n \
\t\t         Work using local modules from "`echo $`"BEROOT/be_flows/modulefiles. \n \
\t\t         This mode allows you to edit wb files. \n \
\t    -init:  Boolean. No value. Default is false. \n \
\t\t         This flag is just to define BEROOT and aliases. \n \
\t\t         No new block/project/wa needed. \n \
\t    -f:  Create even if no blockinfo. \n \
 \n \
Output: \n \
\t     + The script will create the be_work/<project>/<block>/<new folder name> folders if not exists. \n \
\t     + Parse some environment variables from nextflow/project_flow/<project>/controls/setup.tcl \n \
\t     + Take SDC as defined for the block in blocksinfo (env var = BLOCKSINFO) \n \
\t     + Copy <>.wb and setup.tcl templates from nextflow/project_flow/<project>/templates \n \
\t     + All env vars will be saved in <project>/<block>/<new folder name>/setenv_for_be_setup_<Date>_<time>.csh \n \
\t      \n \
\t     + To exit current setup use alias "unsetup" \n \
 \n \
###################################### \n \
"

if ($#argv == 0) then
    echo $help
    exit
endif 

######################################
# Parse user arguments
######################################

set project = ""
set block = ""
set wa = ""
set bi = ""
set force = "false"
set wb    = "must"
set lmmode = "false"
set index = 1
set init  = "false"
foreach arg ($argv )
#   eval echo \$$index
   @ index = $index + 1
      
   switch ($arg)
   case '-b':
       set block   = `eval echo \$$index`
       echo "-I- Block: $block"
       breaksw
   case '-p':
       set project = `eval echo \$$index`
       echo "-I- Project: $project"
       breaksw
   case '-wa':
       set wa = `eval echo \$$index`
       echo "-I- Work Area: $wa"
       breaksw
   case '-wb':
       set wb = `eval echo \$$index`
       echo "-I- Templates copy status: $wb"
       breaksw       
   case '-bi':
       set bi = `eval echo \$$index`
       echo "-I- blocksinfo: $bi"   
       breaksw
   case '-f':
       set force = "true"
       breaksw       
   case '-rtl':
       set rtlmode = "true"
       breaksw              
   case '-local_modules':
       set lmmode = "true"
       breaksw                     
   case '-init':
       set init = "true"
       breaksw                            
   case '-help':
       echo $help
       exit
   default:
#       echo $arg
       breaksw
   endsw
end


######################################
# If -init is used - Just define BEROOT and aliases and exit
######################################
if ( $init == true ) then
    setenv BEROOT `pwd`
    alias be_setup 'source $BEROOT/be_scripts/setup.csh'
    alias unsetup  'source $BEROOT/be_scripts/bin/unsetup.csh'
    alias work_areas 'tree -d -L 3 $BEROOT/be_work'
    alias inv $BEROOT/be_scripts/bin/innovus.csh
    alias gns $BEROOT/be_scripts/bin/genus.csh
    exit
endif

######################################
# Search for "root" to start from
######################################

set beroot = `pwd`
set res = `ls -l $beroot/ | grep project_flow`

if ( "$res" == "" ) then 
    set beroot = `realpath ../`
    set res = `ls -l $beroot/ | grep project_flow`    
endif
if ( "$res" == "" ) then 
    set beroot = `realpath ../../`
    set res = `ls -l $beroot/ | grep project_flow`    
endif
if ( "$res" == "" ) then 
    set beroot = `realpath ../../../`
    set res = `ls -l $beroot/ | grep project_flow`    
endif
if ( "$res" == "" ) then 
    set beroot = `realpath ../../../../`
    set res = `ls -l $beroot/ | grep project_flow`    
endif
if ( "$res" == "" ) then 
    echo "-E- Could not find proper be_flow file structure!" 
    exit
endif 

echo "-I- BE flow root: $beroot"


######################################
# Verify WA relative / absolute path
# We wish to have WA of this patters:
# beroot/be_work/<proj>/<block>/<folder>
# TODO - consider blocking the user from breaking this pattern!
######################################
set prefix = "$beroot/$project/$block"
set sum = `echo $wa | grep -o "/" | wc -l`

if ( "$wa" == "" && $block != "" ) then 
    set wa     = $prefix/folder
    set folder = ${block}_${USER}_`date +%Y%m%d`
else 
    if ( $sum == 0 ) then     
        set folder = $wa
    else
        set folder = `echo $wa | rev | tr "/" " " | awk '{print $1}' | rev`
        set block = `echo $wa | rev | tr "/" " " | awk '{print $2}' | rev`
        if ( $sum > 1 ) then    
            set project  = `echo $wa | rev | tr "/" " " | awk '{print $3}' | rev`    
        endif   
    endif
endif

if ( $project == "" || $block == "" || $wa == "" ) then
    echo "-E- Enter block (-b) and project (-p) OR work area (-wa) in the format of <proj>/<block>/<folder>!"
    exit
endif


set prefix = "$beroot/be_work/$project/$block"
echo "-I- Work Area: $prefix/$folder"



######################################
# Validate project in control and setting some env vars
# Validate block   in blocksinfo
######################################

#################
# get controls
#################
if ( ! -d $beroot/project_flow/$project ) then
    echo    "-E- No $beroot/project_flow/$project directory found"
    echo    "-E- Make sure your -p <project> is correct and you are running from a valid location"
    echo -n "-I- Avilable projects are:" ;  ls -ltr $beroot/project_flow/ | awk '{print $9}' 
    exit
endif

setenv PROJFLOW $beroot/project_flow/$project
setenv CONTROLS $PROJFLOW/controls    

set setuptcl = $CONTROLS/setup.tcl
if ( ! -f $setuptcl ) then
    echo "-E- No $setuptcl file found in  `pwd`/$controls/."
    echo "-E- Make sure you are running from a valid beflow folder!"    
    exit
endif


echo "-I- Parsing $setuptcl"
set file_name = setenv_for_be_setup_`date +"%y%m%d_%H%M"`.csh
echo -n "" > $file_name
echo "#################\n# Set env vars\n#################\n"   >> $file_name
foreach line ("`cat $setuptcl`")

    if ( "$line" == "# Env vars END" ) then
        break
    endif    

    if ( `echo $line | grep -e "^#"` != "" ) then
        continue
    endif  
    
    if ( `echo $line | grep -e "set"` != "" ) then      
        set varname =  `echo $line | awk '{print $2}' | sed 's/[^a-zA-Z0-9]/_/g' `
        set value   =  `echo $line | awk '{for(i=3;i<=NF;++i)printf $i""FS ; print ""}'`
        set cmd = "setenv $varname $value"
        echo $cmd >> $file_name
    endif
end

source $file_name


#################
# get blocksinfo
#################
echo "-I- Verify blocksinfo"
set jsonrange = 12
if ( "$bi" != "" ) then 
    set blocksinfo = $bi
else 
    set blocksinfo = "$REPO_SOURCE/scripts/blocksinfo.json"
endif

echo "-I- blocksinfo: $blocksinfo"
if ( ! -f $blocksinfo && $force == "false") then
    echo "-E- No blocksinfo found at $blocksinfo!"
    exit
endif


#################
# verify block
# TODO: Get sdc even if not be_partition!!!!!
#################
set grepres = `grep -B"$jsonrange" '"is_be_partition" : "True"' $blocksinfo | grep " {" | grep \"$block\"`
if ( "$grepres" == "" ) then
    echo "-W- Block: $block Not is_partition in $blocksinfo"
    set sdc = NA  
    
    set grepres = `grep -B"$jsonrange" '"is_be_partition" : "False"' $blocksinfo | grep " {" | grep \"$block\"`
    if ( "$grepres" == "" ) then      
        echo "-W- Block: $block Not found in $blocksinfo"
        echo "-I- These are the available blocks in blocksinfo:"
        $beroot/be_scripts/bin/get_valid_block_list.py $blocksinfo
        echo ""
    else
        set sdc = `egrep -o \\\$.+${block}.sdc  $blocksinfo | sed 's/ROOT/SOURCE/g' `
    endif
else 
    #################
    # get sdc
    #################
    set sdc = `egrep -o \\\$.+${block}.sdc  $blocksinfo | sed 's/ROOT/SOURCE/g' `
endif      

#################
# Add some env vars
#################
echo "setenv PROJECT   $project"                                                            >> $file_name
echo "setenv BEROOT    $beroot"                                                             >> $file_name
echo "setenv WORK      $prefix/$folder"                                                     >> $file_name
echo "setenv PROJFLOW  $beroot/project_flow/$project "                                      >> $file_name
echo "setenv TEMPLATES $beroot/project_flow/$project/templates"                             >> $file_name
echo "setenv CONTROLS  $PROJFLOW/controls   "                                               >> $file_name
echo "setenv BESCRIPTS $beroot/be_scripts    \n"                                            >> $file_name
echo "setenv BLOCKINFO `realpath $blocksinfo`"                                              >> $file_name   
echo "setenv BLOCKSDC  $sdc"                                                                >> $file_name   
echo "setenv BLOCK     $block"                                                              >> $file_name   
echo "setenv FILELIST  $REPO_SOURCE/auto_gen/gendir/$block/${block}_gen_filelist/filelist"  >> $file_name


#################
# If using local modules
#################
if ( $lmmode == "true" ) then 
    echo "#################\n# Local Modules\n#################\n"        >> $file_name
    echo "source /tools/common/pkgs/modules/current/init/tcsh"            >> $file_name
    echo "source /tools/common/pkgs/modules/current/init/tcsh_completion" >> $file_name
    echo "module use $beroot/be_flow/modulefiles\n"                       >> $file_name
else
    echo "#################\n# Default Modules\n#################\n"      >> $file_name
    echo "source /tools/common/pkgs/modules/current/init/tcsh"            >> $file_name
    echo "source /tools/common/pkgs/modules/current/init/tcsh_completion" >> $file_name
    echo "module use /space/users/moriya/modulefiles \n"                  >> $file_name
endif

########################################
#
########################################

echo "#################\n# Reload module\n#################\n"   >> $file_name
echo "module purge"                       >> $file_name
echo "module load wb $DEF_TOOLS_innovus_ "                    >> $file_name
echo "module load wb $DEF_TOOLS_joules_ \n"                   >> $file_name

echo "#################\n# Source aliases\n#################\n"  >> $file_name
echo "source $beroot/be_scripts/.aliases" >> $file_name

######################################
# Set env vars, aliases and default modules
######################################
cat $file_name
source $file_name

######################################
# Creating directories and \cp -p stuff
######################################
echo "-I- Setting up $block work area in $prefix/$folder"
mkdir -p $prefix/$folder

echo "-I- Create $prefix/$folder/inter folder with empty user overrides files (if not empty, don't touch)"
mkdir -p $prefix/$folder/inter
touch -a $prefix/$folder/inter/${block}.pre.sdc
touch -a $prefix/$folder/inter/${block}.post.sdc
touch -a $prefix/$folder/inter/insert_dft.tcl
touch -a $prefix/$folder/inter/user_derate.tcl
touch -a $prefix/$folder/inter/user_dont_touch.tcl
touch -a $prefix/$folder/inter/user_floorplan.tcl

# Copy sdc 
if ( -e $BLOCKSDC ) then 
    echo "-I- Copy $BLOCKSDC. No overrite!"
 \cp -np $BLOCKSDC $WORK/inter/
else 
    echo "-W- SDC $BLOCKSDC not found!"
    touch -a $prefix/$folder/inter/$block.sdc
endif

# Copy wb templates

if ( "$wb" == "must" ) then
    echo "-I- Copy .wb templates. No overrite!"
 \cp -np $beroot/project_flow/$project/templates/must/*wb $prefix/$folder/
else if ( "$wb" == "all" ) then
 \cp -np $beroot/project_flow/$project/templates/*/*wb $prefix/$folder/
endif 
\cp -np $beroot/project_flow/$project/templates/must/setup.tcl $prefix/$folder/

######################################
# Define unsetup file
######################################
if ( 1 || ! -e $BEROOT/be_scripts/bin/unsetup.csh ) then 

    echo 'cd $BEROOT'   >  $BEROOT/be_scripts/bin/unsetup.csh
    echo "module purge" >> $BEROOT/be_scripts/bin/unsetup.csh

    foreach line ("`cat $file_name`")
        set unset_txt = `echo $line | grep setenv | grep -v "BEROOT\|WB_"| awk '{print "unsetenv " $2}'`
        if ( "$unset_txt" != "" ) then 
            echo $unset_txt >> $BEROOT/be_scripts/bin/unsetup.csh
        endif
    end

endif


################################################################################################
mv $file_name $prefix/$folder

echo "-I- Creating private RTL file list"
be_scripts/bin/generate_private_filelist.tcl 

cd $prefix/$folder/
echo "-I- DONE :)"


######################################
# unset flags
######################################
unset project 
unset block 
unset wa
unset bi
unset force
unset wb 

#!/bin/csh

#argument is target env for PNR ->test on : /bespace/users/royl/inext/be_work/brcm5/cbui_top/rtl19.1/pnr_v2
#additional data starrc  : /bespace/users/royl/inext/be_work/brcm5/cbui_top/rtl19.1/starrc_v2
#echo $argv[1]
##overwrite flag
set overflag = 0
if ( "$2" != "") then
set overflag = 1
#echo "$overflag"
endif
set pattern = `echo $argv[1] | awk -F '/' '{print $(NF)}' | cut -d "_" -f2- `
set main_dir = `echo $argv[1] | rev | cut -d"/" -f2- | rev `
#echo "$main_dir"
#echo "$pattern"
set block = `echo $argv[1] | awk -F '/' '{print $(NF-2)}'`
#echo $block
set default_stage = "chip_finish"
#echo $default_stage
set def = "$argv[1]/out/def/$block.$default_stage.def.gz"
#fast checks for files patterns? or leave as it is
#echo "$def"


if ( -e "$def" ) then 
	echo "Def file exist. Copying"
    if (( -e $block.def.gz == 0) || ($overflag == 1)) then
 \cp -p $def $block.def.gz 
    endif
else 
	echo " -E- def file does not exists"
    exit
endif
set netlist  = "$argv[1]/out/db/$block.$default_stage.enc.dat/$block.v.gz"
if ( -e "$netlist" ) then 
	echo "Netlist file exist. Copying"
    if (( -e $block.v.gz == 0) || ($overflag == 1)) then
 \cp -p $netlist . 
    endif    
else 
	echo " -E- netlist file does not exists"
    exit
endif
set lef  = "$argv[1]/out/lef/$block.$default_stage.lef"
if ( -e "$lef" ) then 
	echo "Lef file exist. Copying"
    if (( -e $block.lef == 0) || ($overflag == 1)) then
 \cp -p $lef $block.lef 
    endif     
else 
	echo " -E- lef file does not exists"
    exit
endif
set lvs  = "$argv[1]/out/netlist/$block.lvs.v"
if ( -e "$lvs" ) then 
	echo "Lvs file exist. Copying"
    if (( -e $block.lvs.v == 0) || ($overflag == 1)) then
 \cp -p $lvs . 
    endif
    
else 
	echo " -E- lvs file does not exists"
    exit
endif
set gpd  = "$main_dir/starrc_$pattern/out/gpd/$block.$default_stage.HIER.gpd"
if ( -e "$gpd" ) then 
	echo "Gpd file exist. Copying"
    if (( -e $block.HIER.gpd == 0) || ($overflag == 1 )) then
 \cp -rp $gpd $block.HIER.gpd 
    endif   
else 
	echo " -E- gpd file does not exists"
    exit
endif
set sdc = "$main_dir/inter/$block.sdc"
if ( -e $sdc ) then 
	echo "Sdc file exist. Copying"
    if ( (-e $block.sdc == 0) || ($overflag == 1)) then
 \cp -p $sdc . 
    endif       
else 
	echo " -E- sdc file does not exists"
    exit
endif
set oas = "$argv[1]/out/gds/$block.oas.gz"
if ( -e $oas ) then 
	echo "Oas file exist. Copying"
     if (( -e $block.oas == 0) || ($overflag == 1)) then
 \cp -p $oas $block.oas 
    endif    
else 
	echo " -E- oas file does not exists"
    exit
endif
#set spef  = "$main_dir/starrc_$pattern/out/spef/$block.$default_stage.spef"
#if ( -e "$spef" ) then 
#	echo "file exist"
# \cp -p $spef
#else 
#	echo " -E- spef file does not exists"
#    exit 
#endif
echo "Creating package..."
if (( -e "${block}_${pattern}_package.tar.gz" == 0) || ($overflag == 1)) then 
	tar -czvf ${block}_${pattern}_package.tar.gz $block.oas $block.sdc $block.HIER.gpd $block.lvs.v $block.lef $block.v.gz $block.def.gz
    endif 
echo "Done proccess created : ${block}_${pattern}_package.tar.gz "    

#!/usr/bin/python

import re
import gzip
import os
import sys
import shutil
import argparse

#============================#
#== Collaterals definition ==#
#============================#
parser = argparse.ArgumentParser(description='')

parser.add_argument('-wa'    , action="store", dest="CentralArea", default = "None" , help='File to summay on')
parser.add_argument('-blocks', action="store", dest="BlockList", default = "None" , help='File to summay on')
parser.add_argument('-out'   , action="store", dest="out", default = "RegressionTable.rpt", help='Summary file name')

opts = parser.parse_args()
#=========================#
#== check if fils exist ==#
#=========================#
if(opts.CentralArea == "None"):
    print "\nMissing Work Area,\nPlease add one!!!\n"
    sys.exit()

if(opts.BlockList == "None"):
    print "\nMissing Block List,\nPlease add one!!!\n"
    sys.exit()

tool = "Genus"
BL = opts.BlockList
BlockList = BL.split()
init = 0

#== Open file for writing ==#
of  = open("TempFile"  , "w+")
of.write("Block | Stage | Runtime | Leaf_Cell_Count | Leaf_Cell_Area | Seq_Cell_Count | Comb_Cell_Count | Buf/Inv_Cell_Count | Macro_Count | Macro_Area |Removed_seq | Tool \n")
of.write("----- | ----- | ------- | --------------- | -------------- | -------------- | --------------- | ------------------ | ----------- | ---------- |----------- | ---- \n")


for i in BlockList:
    #== init params ==#  
    LeafCellCount = "0"; SeqCellCount = "0"; CombCellCount = "0"; macros = 0; LeafCellsArea = 0;
    BufInvCellCount = 0 ; RemovedCellCount = 0; RunTime = "" ; MacroCount = 0; MacroArea = 0;

    Block = i
    Path = opts.CentralArea + "/target/syn_regressions/" + Block 

    if(os.path.exists(Path + "/reports/syn_opt.be.qor")):
         af  = open(Path + "/reports/syn_opt.be.qor" , "r")
         stage = "syn_opt"
    elif(os.path.exists(Path + "/reports/syn_map.be.qor")):
         af  = open(Path + "/reports/syn_map.be.qor" , "r") 
         stage = "syn_map"
    elif(os.path.exists(Path + "/reports/syn_gen.be.qor")):
         af  = open(Path + "/reports/syn_gen.be.qor" , "r")         
         stage = "syn_gen"
    else:
        
        print("\n" + Block + " ran failed \n")
        continue
 
    mf = open(Path + "/reports/elab/report_macro_count.rpt" , "r")
    for line in mf:
        if ("--------" in line):
          macros = 1
          continue 
        if ((macros == 1) and (len(line) != 1)):
          MacroCount += int(line.split()[1])

    mf.close()

    #== Get relevant data ==#
    for line in af:
      if "Leaf Cell Count" in line:
         LeafCellCount = line.split()[3]

      if "Sequential Cell Count" in line:
         SeqCellCount = line.split()[3]
      
      if "Combinational Cell Count" in line:
         CombCellCount = line.split()[3]
 
      if "Leaf Cell Area" in line:
         LeafCellsArea += float(line.split()[3])
      
      if "Macro Cell Area" in line:
         MacroArea += float(line.split()[3])
      
      
      if (("Buffer Cell Count" in line) or ("Inverter Cell Count" in line)):
         BufInvCellCount += int(line.split()[3])

      if (("Sequential element deleted" in line) and ("constant" not in line)):
         RemovedCellCount += int(line.split()[6])

      if (("Sequential element deleted" in line) and ("constant" in line)):
         RemovedCellCount += int(line.split()[7])

      if "Elapsed" in line:
         RunTime = line.split()[4]

      if "CPU:" in line:
        of.write(Block + " | " + stage + " | " + RunTime + " | " +  LeafCellCount + " | "  + str(LeafCellsArea) + " | " +  SeqCellCount + " | " + CombCellCount + " | " + str(BufInvCellCount) + " | " + str(MacroCount) + " | " + str(MacroArea) + " | " + str(RemovedCellCount) + " | " + tool  + " \n")
        af.close()
        break

of.close();
cmd = "cat TempFile | column -t > " + opts.out
os.system(cmd)
os.remove("TempFile") ;

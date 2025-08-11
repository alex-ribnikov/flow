#!/bin/csh
set i = 0
while ($i < $#argv) 
   @ i++
   if ("$argv[$i]" == "-cpu") then
  	@ i++
	set CPU = $argv[$i]
   endif
   if ("$argv[$i]" == "-description") then
  	@ i++
	set DESCRIPTION = $argv[$i]
   endif
   if ("$argv[$i]" == "-mem") then
  	@ i++
	set MEM = $argv[$i]
   endif
   if ("$argv[$i]" == "-pwd") then
  	@ i++
	set ppp = $argv[$i]
   endif
   if ("$argv[$i]" == "-label") then
  	@ i++
	set LABEL = $argv[$i]
   endif
end

set K8S_CPU = `echo $CPU | awk '{x=$1/2.0; $1/2.0==int($1/2.0) ? x=$1/2.0 : x=int($1/2.0)+1 ; printf x"\n" }'`
set K8S_MEM = `echo $MEM | awk '{x=$1/1.5; $1/1.5==int($1/1.5) ? x=$1/1.5 : x=int($1/1.5)+1 ; printf x"\n" }'`

echo 

set COMMAND = `echo $argv | perl -pe 's/-cpu \d+//;s/-mem \d+\.\d+//;s/-mem \d+//;s/-pwd \S+ //;s/-description \S+//;s/-label \S+//'`
set cmd =  "/tools/common/bin/nextk8s run -command ' setenv SYNOPSYS_LC_ROOT /tools/snps/lc/V-2023.12-SP5-2 ; $COMMAND ' -x-server -cpu $K8S_CPU -cpu-limit $CPU -memory-limit $MEM -memory $K8S_MEM -queue-name backend  -working-dir $ppp -desc $DESCRIPTION   -queue-mode"

if ($LABEL != "None") then
   set cmd = "$cmd -label $LABEL"
endif


echo "ARGV: $argv" > .check
echo "COMMAND: $COMMAND" >> .check
echo $cmd >> $ppp/.check
eval $cmd



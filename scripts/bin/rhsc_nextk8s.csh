#!/bin/csh

set i = 0
while ($i < $#argv) 
   @ i++
   if ("$argv[$i]" == "-cpu") then
       @ i++
       set CPU = $argv[$i]
   endif
   if ("$argv[$i]" == "-memory") then
       @ i++
       set MEM = $argv[$i]
   endif
   if ("$argv[$i]" == "-label") then
       @ i++
       set LABEL = $argv[$i]
   endif
   if ("$argv[$i]" == "-image") then
       @ i++
       set IMAGE = $argv[$i]
   endif
   if ("$argv[$i]" == "-display") then
       @ i++
       set DISPLAY = $argv[$i]
   endif
   if ("$argv[$i]" == "-vnc_server") then
       @ i++
       set VNC_SERVER = $argv[$i]
   endif
end




set COMMAND = `echo $argv | perl -pe 's/-cpu \d+//;s/-memory \d+//;s/-image \S+//;s/-label \S+//;s/-display \d+//;s/-vnc_server \S+//'`


setenv QT_X11_NO_MITSHM 1

set ppp = `echo $PWD | awk -F'/' '{print $NF}'`
set random2 = `head -c 1 /dev/urandom | od -t u1 | cut -c9-`
sleep 1
set random1 = `head -c 1 /dev/urandom | od -t u1 | cut -c9-`
@ random = $random1 * $random2 / 10

#set cmd = "/space/infra/nextk8s run -command '$argv' -cpu 1 -memory 25 -desc rh_slave_$random -shell bash -vnc-server vnc01.il.nextsilicon.com -x-display-num 7"
#set cmd = "/tools/common/bin/nextk8s run -command 'setenv QT_X11_NO_MITSHM 1 ; $COMMAND' -cpu $CPU -memory $MEM -desc rh_slave_$random -shell bash -vnc-server vnc01.il.nextsilicon.com -x-display-num 7"
set cmd = "/tools/common/bin/nextk8s run -command 'setenv QT_X11_NO_MITSHM 1 ; $COMMAND' -cpu $CPU -memory $MEM -desc rh_slave_$random -shell bash "
if (  $?LABEL) then 
   set cmd = "$cmd -label $LABEL"   
endif
if (  $?IMAGE) then 
   set cmd = "$cmd -image $IMAGE"   
endif
if (  $?display) then 
   set cmd = "$cmd -x-display-num $DISPLAY"   
endif
if (  $?VNC_SERVER) then 
   set cmd = "$cmd -vnc-server $VNC_SERVER"   
endif

echo $cmd > nnn_$random.check
eval $cmd



#echo $argv > /services/bespace/users/royl/inext/be_work/brcm5/cbui_top/rtl19.1/rhsc_v8/kkk.check
#
#while ($i < $#argv) 
#   @ i++
#   if ("$argv[$i]" == "-cpu") then
#  	@ i++
#	set CPU = $argv[$i]
#   endif
#   if ("$argv[$i]" == "-mem") then
#  	@ i++
#	set MEM = $argv[$i]
#   endif
#   if ("$argv[$i]" == "-pwd") then
#  	@ i++
#	set ppp = $argv[$i]
#   endif
#end
#set COMMAND = `echo $argv | perl -pe 's/-cpu \d+//;s/-mem \d+//;s/-pwd \S+ //'`
#
#set cmd = "/space/infra/jenkins-worker/hw-jobs-cli-k8s run \
#	-command 'setenv SYNOPSYS_LC_ROOT /tools/snps/lc/R-2020.09-SP5 ; $COMMAND' \
#	-tail \
#	-workingDir $ppp \
#	-cpus $CPU \
#	-memory $MEM "
#
#echo $cmd > $ppp/.check
#eval $cmd


##/space/infra/jenkins-worker/hw-jobs-cli-k8s run -tail -workingDir [pwd] -cpus $CPU -memory 100 -command 

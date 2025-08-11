#!/bin/csh


####################################################################################################################################
##   $1 is a file name - Warning - if the file does not exists, the loop will run forever
##   $2 is timeout in minutes
##   $3 is parent process PID to prevent zombie process
##   $4 is POD name. If local run - pod == 0
####################################################################################################################################
set pod     = $4
set file    = `realpath $1`
set name    = `echo $file | awk -F '/' '{print $NF}'`
set dir     = `echo $file | awk -F'/' -v OFS='/' '{$NF=""}1'`
set subject = "Unchaged File Warning - `pwd`"
echo "-W- File $file did not change for $2 minutes in `pwd`" > ./body.txt
set alert   = 1

echo "-I- Checking if file: $1 is unchanged for over $2 minutes"
while (1)
    if ( "`find $dir -mmin +$2 -name "$name"`" != "") then
        echo "-W- File $file did not change for $2 minutes"
        if ( $alert > 0 ) then
            echo "\n" >> ./body.txt
            cat $file | tail -10 >> ./body.txt
            echo ./body.txt | mail -r BE_Run_Summary@nextsilicon.com -s "$subject" or.yagev@nextsilicon.com
            set alert = -20
        endif
        #echo "-I- Will check again in $2 minutes"
        #sleep "${2}m"
        #continue
    endif
    if ( ! -f "$file" ) then
        echo "-E- File $file not found"
    endif
    
    if ( "$pod" == 0 ) then
        if ("`ps | grep $3 | cat`" == "") then
            echo "-I- Parent process $3 is dead. Killing child process $$"
            exit
        endif    
    else
        ./scripts/bin/is_pod_alive.csh $pod
        if ( "$status" == 0 ) then
            echo "-I- Pod $pod is dead. Killing child process $$"
            exit
        endif
    endif
    #@ alert += 1
    sleep 300
end



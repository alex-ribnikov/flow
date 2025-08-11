#!/bin/bash

echo "<b>$1</b>" | mailx -r BE_Run_Summary@nextsilicon.com -s "$(echo -e "$2\nContent-Type: text/html")" or.yagev@nextsilicon.com


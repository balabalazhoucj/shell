#!/bin/bash
systemload=$(uptime | awk -F '[ ,]' '{print $14}')
processes=$(ps -ef | wc -l)
usage=$(df -h / | awk 'NR==2{print $5 " " $2 }')
userlogged=$(who | wc -l)
Buffers=`grep -we 'Buffers' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
Cached=`grep -we 'Cached' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
MemFree=`grep -ie 'MemFree' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
MemTotal=`grep -ie 'MemTotal' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
SwapCached=`grep -ie 'SwapCached' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
SwapFree=`grep -ie 'SwapFree' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
SwapTotal=`grep -ie 'SwapTotal' /proc/meminfo | cut -d' ' -f2- | tr -d "[A-Z][a-z] "`
MEMUSED="$(( (  $MemTotal - $MemFree  - $Cached  - $Buffers ) *100 / $MemTotal ))"
SWAPUSED="$((( $SwapTotal - $SwapFree - $SwapCached ) * 100 / $SwapTotal ))"


printf '\n\t System information as of $(date)\n \n'
printf '\t System load: %s \t \t Processes: %s\n' $systemload $processes
printf '\t Usage of /: %s of %sB \t User logged in: %s \n' $usage $userlogged
printf '\t Memory usaage: %s%% \t \t Swap usage: %s%% \n' $MEMUSED $SWAPUSED

for i in `ifconfig  | awk '$1~/eth[0-9]/{print $1}'`
do
IP=$(ifconfig $i| awk -F'[ :]+' 'NR==2{print $4}')
printf "\t IP address for %s: %s\n" $i $IP
done
printf '\n'
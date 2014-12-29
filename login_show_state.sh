#!/bin/bash
systemload=$(uptime | awk -F '[ ,]' '{print $13}')
processes=$(ps -ef | wc -l)
usage=$(df -h / | awk 'NR==2{print $5 " " $2 }')
userlogged=$(who | wc -l)
Buffers=`grep -we 'Buffers' /proc/meminfo | awk '{print $2}'`
Cached=`grep -we 'Cached' /proc/meminfo | awk '{print $2}'`
MemFree=`grep -ie 'MemFree' /proc/meminfo | awk '{print $2}'`
MemTotal=`grep -ie 'MemTotal' /proc/meminfo | awk '{print $2}'`
SwapCached=`grep -ie 'SwapCached' /proc/meminfo | awk '{print $2}'`
SwapFree=`grep -ie 'SwapFree' /proc/meminfo | awk '{print $2}'`
SwapTotal=`grep -ie 'SwapTotal' /proc/meminfo | awk '{print $2}'`
MEMUSED="$(( (  $MemTotal - $MemFree  - $Cached  - $Buffers ) *100 / $MemTotal ))"
SWAPUSED="$((( $SwapTotal - $SwapFree - $SwapCached ) * 100 / $SwapTotal ))"
PUBLICIP=$(curl --connect-timeout 5 -s icanhazip.com)

printf "\n\t System information as of $(date) \n \n"
printf '\t System load: %s \t \t Processes: %s \n' $systemload $processes
printf '\t Usage of /: %s of %sB \t User logged in: %s \n' $usage $userlogged
printf '\t Memory usaage: %s%% \t \t Swap usage: %s%% \n' $MEMUSED $SWAPUSED
printf '\t IP address for Public: %s \n' $PUBLICIP
for i in `ifconfig  | awk '$1~/eth[0-9]/{print $1}'`
do
IP=$(ifconfig $i| awk -F'[ :]+' 'NR==2{print $4}')
printf "\t IP address for %s: %s\n" $i $IP
done
printf '\n'
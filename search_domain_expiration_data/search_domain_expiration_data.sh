#!/bin/sh
domainn=$1
exprie_date=$(curl -q "https://www.dynadot.com/domain/whois.html?domain=$domain" |grep -oP '(\d{4}-\d{2}-\d{2})'| sort -nr| head -n 1)
[ -z $exprie_date ] && exit 1 

now_date=$(date -I)
second=$(($(date +%s -d "$exprie_date")-$(date +%s -d "$now_date")))
day=$(($second/3600/24))
echo $day


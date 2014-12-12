#!/bin/sh 
#nginx 日志切割
yesterday=`date -d "yesterday" +"%Y%m%d"` 
before_yesterday=`date -d "-2 day" +"%Y%m%d"` 
Nginx_Dir="/usr/local/nginx" 
Nginx_logs="/app/logs" 
Log_Name="www_access" 
cd /tmp 
[ -d $Nginx_Logs ] && cd $Nginx_logs || exit 1 
[ -f $Log_Name.log ] && /bin/mv $Log_Name.log ${Log_Name}_${yesterday}.log || exit 1 
if [ $? -eq 0 -a -f $Nginx_Dir/logs/nginx.pid ] 
then 
kill -USR1 `cat $Nginx_Dir/logs/nginx.pid` 
fi 
[ -f  ${Log_Name}_${before_yesterday}.log ] && /usr/bin/gzip ${Log_Name}_${before_yesterday}.log|| exit 1 
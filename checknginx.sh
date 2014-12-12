#!/bin/sh
#oldboy
while true
do
	PNUM=`ps -ef|grep nginx|wc -l`
	if [ $PNUM -lt 3 ] then
		/etc/init.d/keepalived stop > /dev/null 2>&1
		kill -9 keepalived > /dev/null 2>&1
		kill -9 keepalived > /dev/null 2>&1
	fi
	sleep 5
done



#!/bin/sh
#by book
while :
do
	nginxpid=`ps -C nginx --no-header|wc -l`
	if [ $nginxpid -eq 0 ];then
		/etc/init.d/nginx start
		sleep 5
		nginxpid=`ps -C nginx --no-header|wc -l`
		if [ $nginxpid -eq 0 ];then
			/etc/init.d/keepalived stop
		fi
	fi
	sleep 5
done
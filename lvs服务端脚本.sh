#!/bin/sh

. /etc/init.d/functions

#定义数组
VIP=192.168.139.10
RIP=(
192.168.139.21
192.168.139.22)

start(){
if [ `ifconfig eth2| wc -l` -ne 2 ];then
        ifconfig eth2:10 ${VIP}/24 up
        route add -host ${VIP} dev eth2
fi
ipvsadm -C
ipvsadm --set 30 5 60
ipvsadm -A -t ${VIP}:80 -s wrr -p 20
for ((i=0;i<${#RIP[*]};i++))
do
        ipvsadm -a -t ${VIP}:80 -r ${RIP[$i]}:80 -g -w 1
done
}

stop(){
if [ `ifconfig eth2| wc -l` -ne 2 ];then
        ifconfig eth2:10 ${VIP}/24 down
        route del -host ${VIP} dev eth2
fi
ipvsadm -D -t ${VIP}:80
}

case "$1" in
start)
        action "ipvs started" /bin/true
        start
;;
stop)
        action "ipvs stoped" /bin/true
        stop
;;
*)
        echo "Usage:$0 {start|stop}"
;;
esac
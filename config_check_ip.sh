#!/bin/sh
#通过应答方式设置网卡信息，同时检查ip合规性

checkip ()
{
	ip=$1
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];then
		#替换.为空格，成为数组
		ip=(${ip//./ })
		for i in ${ip[@]}
		do
			if [[ $i -le 255 ]];then
				single=0 
			else
				single=1
				echo "u input error,pls input again!"
				break
			fi
		done 
	else
		single=1
		echo "u input error,pls input again!"
	fi
}

input()
{
while [[ $single != 0 ]]
do
	read -p "input $1:" value
	checkip $value
done
sed -i "s/\($2=\).*/\1${value}/" /etc/sysconfig/network-scripts/ifcfg-eth0
}
single=1
input "ip address" "IPADDR"
single=1
input "NETMASK" "NETMASK"
single=1
input "GATEWAY" "GATEWAY"

read -p "input DNS[221.228.255.1]:" DNS
if [ -z $DNS ];then
	DNS="221.228.255.1"
else	
	checkip $DNS
fi
echo "nameserver $DNS" > /etc/resolv.conf
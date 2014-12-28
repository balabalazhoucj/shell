#!/bin/sh
#通过应答方式设置网卡信息，同时检查ip合规性

checkip ()
{
	ip=$1
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];then
		ip=(${ip//./ })
		for i in ${ip[@]}
		do
			[[ $i -le 255 ]] || exit 2
		done 
	else
		exit 3
	fi
}

read -p "input ip address:" IP_ADDR
checkip $IP_ADDR
sed -i "s/\(IPADDR=\).*/\1${IP_ADDR}/" /etc/sysconfig/network-scripts/ifcfg-eth0

read -p "input netmask:" NET_MASK
checkip $NET_MASK
sed -i "s/\(NETMASK=\).*/\1${NET_MASK}/" /etc/sysconfig/network-scripts/ifcfg-eth0

read -p "input GATEWAY:" GATE_WAY
checkip $GATE_WAY
sed -i "s/\(GATE_WAY=\).*/\1${GATE_WAY}/" /etc/sysconfig/network-scripts/ifcfg-eth0

read -p "input DNS:" DNS
checkip $DNS
echo "nameserver $DNS" > /etc/resolv.conf
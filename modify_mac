#!/bin/sh
#此脚本解决vmware workstation克隆centos时eth0配置中MAC保留原镜像MAC
#导致网络服务不可用
#包括mac修改、ip、子网掩码、网关、dns设置
#在虚拟机做成镜像前，执行下面语句
# rm -f /etc/udev/rules.d/70-persistent-net.rules
# sed -i '/HWADDR.*\|UUID.*/d' /etc/sysconfig/network-scripts/ifcfg-eth0
# echo "sh /root/ip.sh" >> /etc/bashrc
#在root目录下，复制本脚本内容到ip.sh

#检查ip合规性
checkip ()
{
	ip=$1
	if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]];then
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

#生成新设备MAC
awk -F '"' '$14=="eth0"{print "HWADDR="$8}' /etc/udev/rules.d/70-persistent-net.rules >> /etc/sysconfig/network-scripts/ifcfg-eth0
/etc/init.d/network restart
#删除脚本相关文件
sed -i '$d' /etc/bashrc
rm -f $0
echo "nameserver 221.228.255.1" > /etc/resolv.conf
#更改源
yum install wget -y
mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
cd /etc/yum.repos.d
wget http://mirrors.163.com/.help/CentOS6-Base-163.repo
mv CentOS6-Base-163.repo CentOS-Base.repo
#安装epel源
rpm -Uvh http://ftp.sjtu.edu.cn/fedora/epel/6/i386/epel-release-6-8.noarch.rpm
#wget -O /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-6.repo

#安装软件
yum install lrzsz gcc sysstat ntp openssh-clients lsof man tree parted vim -y
yum groupinstall "Development tools" -y

#禁用selinux
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

#时间同步
echo '*/5 * * * * /usr/sbin/ntpdate time.windows.com > /dev/null 2>&1' >> /var/spool/cron/root

#调整文件描述符大小
echo '*       -       nofile  65536' >> /etc/security/limits.conf

#禁用IPV6
echo -ne "alias net-pf-10 off\noptions ipv6 disable=1" > /etc/modprobe.d/ipv6off.conf

#解决nfs启动过程中访问ipv6
if [ `awk '{print $3}' /etc/redhat-release` = 6.5 ];then
	sed -i "s/udp6/#udp6/" /etc/netconfig
	sed -i "s/tcp6/#tcp6/" /etc/netconfig
fi

#精简开机自动启动项
for a in `chkconfig --list | grep 3:on|awk '{print $1}'`;do chkconfig --level 3 $a off;done
for a in crond network rsyslog sshd sysstat;do chkconfig --level 3 $a on;done 

#modprobe bridge

#去除开机登录信息
#>/etc/redhat-release
>/etc/issue

#添加普通用户并进行sudo授权管理
useradd zhoucj
echo "123456"|passwd --stdin zhoucj&&history –c
echo "zhoucj  ALL=(ALL)       ALL" >> /etc/sudoers

echo "alias vi='vim'" >> /etc/profile
echo "alias grep='grep --colour'" >> /etc/profile
cat > .vimrc <<EOF
set ts=4
set shiftwidth=4
set fencs=utf-8
set t_Co=256
syntax on
EOF

mkdir tools
cd tools


 url=$($mysqlcmd "select REPLACE(ConvertFilePath,'\"\\\"','\"\/\"') as ConvertFilePath from courseware.File where Filename='80后90后员工的干法01.mp4';")

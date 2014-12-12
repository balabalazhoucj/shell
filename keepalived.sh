#keepalived
wget http://www.keepalived.org/software/keepalived-1.1.17.tar.gz
yum install kernel-devel popt-devel -y
ln -s /usr/src/kernels/2.6.32-431.5.1.el6.x86_64 /usr/src/linux/
tar zxf keepalived-1.1.17.tar.gz 
cd keepalived-1.1.17
./configure
make && make install
#生成启动脚本命令
cp /usr/local/etc/rc.d/init.d/keepalived /etc/init.d/
#配置启动脚本参数
cp /usr/local/etc/sysconfig/keepalived /etc/sysconfig/
mkdir /etc/keepalived
#把keepalived模板拷贝到/etc/keepalived/下
cp /usr/local/etc/keepalived/keepalived.conf  /etc/keepalived/
cp /usr/local/sbin/keepalived /usr/sbin/
/etc/init.d/keepalived start




#master
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   router_id LVS_12
}

vrrp_instance VI_1 {
#制定A节点为主节点
    state MASTER
#绑定虚拟IP的网络接口
    interface eth2
#VRRP组名，两个节点的设置必须一样，以指明各个节点属于同一VRRP组
    virtual_router_id 11	
#主节点的优先级（1-254之间），备用节点必须比主节点优先级低
    priority 150
#组播信息发送间隔，两个节点设置必须一样
    advert_int 1
#设置验证信息，两个节点必须一致
    authentication {
        auth_type PASS
        auth_pass 1111
    }
#指定虚拟IP, 两个节点设置必须一样
    virtual_ipaddress {
        192.168.139.10
    }
}

#backup
! Configuration File for keepalived

global_defs {
   notification_email {
     acassen@firewall.loc
     failover@firewall.loc
     sysadmin@firewall.loc
   }
   notification_email_from Alexandre.Cassen@firewall.loc
   smtp_server 192.168.200.1
   smtp_connect_timeout 30
   router_id LVS_12
}

vrrp_instance VI_1 {
    state BACKUP
    interface eth2
    virtual_router_id 11
    priority 50
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 1111
    }
    virtual_ipaddress {
        192.168.139.10
    }
}
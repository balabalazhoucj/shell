#!/bin/bash
# Created By:      Zhoucj <zhoucj98@gmail.com>
# Created Time:    2015-02-02 15:48:52
# Modified Time:   2015-02-03 10:10:33
_PATH="/etc/cacti"
yum install net-snmp* rrdtool openssl wget tar gcc* crontabs -y
sed -i '62s/systemview/all/;85s/#\(.*\)/\1/' /etc/snmp/snmpd.conf
/etc/init.d/snmpd start
wget http://www.cacti.net/downloads/cacti-0.8.8c.tar.gz
tar zxf cacti-0.8.8c.tar.gz
mv cacti-0.8.8c ${_PATH} 
cd ${_PATH}
chown -R www rra log
mysql -uroot -e "create database cacti;grant all on cacti.* to cactiuser@localhost identified by 'cactiuser';flush privileges;"
mysql -uroot cacti < cacti.sql
sed -i 's#//\($url_path = "/\)cacti/"#\1"#' ${_PATH}/include/config.php
sed -i 's/required/sufficient/g' /etc/pam.d/crond
echo '* * * * * php '"$_PATH"'/poller.php > /dev/null 2>&1' >> /var/spool/cron/root
/etc/init.d/crond start
wget http://www.cacti.net/downloads/spine/cacti-spine-0.8.8c.tar.gz
tar zxf cacti-spine-0.8.8c.tar.gz
cd cacti-spine-0.8.8c/
./configure 
make && make install
cp /usr/local/spine/etc/spine.conf.dist /etc/spine.conf
chmod +x ${_PATH}/poller.php
chmod +x /usr/local/spine/bin/spine

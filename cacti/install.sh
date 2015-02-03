#!/bin/bash
# Created By:      Zhoucj <zhoucj98@gmail.com>
# Created Time:    2015-02-02 15:49:43
# Modified Time:   2015-02-03 13:45:19
export _PATH="/etc/cacti" 

sh nginx_pre.sh
[ $? -ne 0 ] && exit 

sh mysql_pre.sh
[ $? -ne 0 ] && exit
/etc/init.d/mysqld start

sh php-fpm_pre.sh
[ $? -ne 0 ] && exit

sh cacti_pre.sh
/etc/init.d/mysqld stop



yum install python-setuptools -y
easy_install supervisor
cat << EOF > /etc/supervisord.conf
[supervisord]                                                               
nodaemon=true                                                            
                                                                            
[program:mysql]
command=/usr/bin/mysqld_safe

[program:nginx]
command=/usr/sbin/nginx -g "daemon off;"     

[program:php-fpm]
command=/usr/sbin/php-fpm
EOF

supervisord -c /etc/supervisord.conf

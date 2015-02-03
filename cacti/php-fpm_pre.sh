#!/bin/bash
# Created By:      Zhoucj <zhoucj98@gmail.com>
# Created Time:    2015-02-02 15:48:20
# Modified Time:   2015-02-02 15:48:28
yum install php php-fpm php-gd -y
sed -i 's/\(user = \)apache/\1www/;s/\(group = \)apache/\1www/' /etc/php-fpm.d/www.conf
sed -i 's/;\(date.timezone =\)/\1 Asia\/Shanghai/' /etc/php.ini
chown -R www /var/lib/php/

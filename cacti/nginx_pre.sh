#!/bin/bash
# Created By:      Zhoucj <zhoucj98@gmail.com>
# Created Time:    2015-02-02 15:46:57
rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm
yum install nginx -y
useradd www -s /sbin/nologin -M
sed -i 's#/scripts#$document_root#;30,36s#\#\(.*\)#\1#g;9s#/usr/share/nginx/html#'"$_PATH"'#;s#\(root           \)html#\1'"$_PATH"'#;10s#\(index\).*#\1 index.php;#' /etc/nginx/conf.d/default.conf
sed -i 's/\(user  \)nginx/\1www/' /etc/nginx/nginx.conf

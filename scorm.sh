#!/bin/sh
. /etc/init.d/functions
. /etc/profile

for n in $(ls *.tar.gz *.zip)
do
	case "$n" in
		*.tar.gz)
			tar -zxf $n > /dev/null 2>&1
			mv $(ls $n|sed 's/\.tar.gz//g') $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.zip)
			yum install unzip -y > /dev/null 2>&1 || return 1
			unzip -q $n 
			;;
		*)
			echo "unsupported this type"
			exit 1
			;;
	esac
done

install_software() {
	cd $1
	if [ -f configure ];then
		./configure $2 >> install.log
		make >> install.log || return 1
		make install >> install.log || return 1
	else
		/usr/bin/python setup.py build >> install.log || return 1
		/usr/bin/python setup.py install >> install.log || return 1
	fi
	cd ..
} >> install.log

apache_install() {
	httpd_path="/usr/local/httpd"
	id apache > /dev/null 2>&1 || useradd -s /bin/nologin -M apache
	yum install pcre-devel zlib-devel openssl-devel -y > /dev/null 2>&1 || return 1
	install_software "apr"
	install_software "apr-util" "--with-apr=/usr/local/apr/"
	mkdir -p ${httpd_path}
	install_software "httpd" "--prefix=${httpd_path} --enable-deflate --enable-http --enable-expires --disable-version --enable-rewrite --enable-included-apr --with-crypto --with-mpm=worker --enable-so"
	sed -i "s/User daemon/User apache/g;s/Group daemon/Group apache/g;s/#ServerName www.example.com:80/ServerName 127.0.0.1:80/g" ${httpd_path}/conf/httpd.conf 
	sed -i  "s:DocumentRoot \"${httpd_path}\/htdocs\":#&:g" ${httpd_path}/conf/httpd.conf
} > install.log

mysql_install() {
	mysql_path="/usr/local/mysql"
	yum install ncurses-devel gcc-c++ cmake perl make bison -y > /dev/null 2>&1 || return 1
	id mysql > /dev/null 2>&1 || useradd -s /bin/nologin -M mysql
	mkdir -p /data/mysqldata
	cd mysql
cmake . -DCMAKE_INSTALL_PREFIX=${mysql_path} \
-DENABLED_LOCAL_INFILE=1 \
-DWITH_PARTITION_STORAGE_ENGINE=1 \
-DWITH_EXTRA_CHARSETS:STRING=all \
-DDEFAULT_CHARSET=utf8 \
-DDEFAULT_COLLATION=utf8_general_ci \
-DMYSQL_USER=mysql
	make -j4 > /dev/null 2>&1
	make install > /dev/null 2>&1
	cd ..
	for a in $(ls /${mysql_path}/bin)
	do
	ln -s /${mysql_path}/bin/${a} /bin
	done
cat > /etc/my.cnf << EOF
[mysqld]
basedir =  ${mysql_path}
datadir = /data/mysqldata
port = 3306
socket = /tmp/mysql.sock
user = mysql
EOF
	chown -R mysql /data/mysqldata
	${mysql_path}/scripts/mysql_install_db --basedir=${mysql_path} --datadir=/data/mysqldata --user=mysql
	cp ${mysql_path}/support-files/mysql.server /etc/init.d/mysqld
	echo "${mysql_path}/lib/" >> /etc/ld.so.conf
	ldconfig
	chmod +x /etc/init.d/mysqld
	/etc/init.d/mysqld start || return 1
	mysql -uroot -e "drop user 'root'@'::1';drop user ''@'localhost';drop user ''@'localhost.localdomain';"
	#	${MYSQLCMD} "update mysql.uesr set password=password('123456') where user='root' and host='localhost';"
	#	${MYSQLCMD} "update mysql.uesr set password=password('123456') where user='root' and host='%';"
} >> install.log

install_python() {
	install_software "Python" "--enable-shared"
	mv /usr/bin/python /usr/bin/python.bak
	ln -s /usr/local/bin/python2.7 /usr/bin/python
	sed -i 's/bin\/python/bin\/python2\.6/g' /usr/bin/yum 
	sed -i 's#\(usr/bin/python\)#\12\.6#' /usr/bin/repoquery
	echo "/usr/local/lib/" >> /etc/ld.so.conf
	ldconfig
	/usr/bin/python -V
} >> install.log

install_python_plugin() {
	#Install & configure wsgi
	install_software "mod_wsgi" "--with-apxs=${httpd_path}/bin/apxs"
	ldconfig /usr/local/lib
	sed -i "/#LoadModule rewrite_module modules\/mod_rewrite.so/a\LoadModule wsgi_module modules\/mod_wsgi.so" ${httpd_path}/conf/httpd.conf
	#Install setuptools
	install_software "setuptools" || return 1
	#Install Webpy
	install_software "web.py" || return 1
	install_software "MySQL-python" || return 1
	#Install Django
	install_software "Django" || return 1
} >> install.log

config_web_site() {
yum install unzip -y
mysql_user="scorm"
mysql_pass="123scorm123"
website="/data/website"
mkdir -p ${website}
cp -r Server_Django ${website} || return 1
echo "include conf/extra/scorm_vhost.conf" >> ${httpd_path}/conf/httpd.conf
cat > ${httpd_path}/conf/extra/scorm_vhost.conf << EOF
<VirtualHost *:80>
	DocumentRoot "${website}/Server_Django/" 
	ServerName 127.0.0.1
	WSGIScriptAlias /scormserver ${website}/Server_Django/django.wsgi/
	Alias /scormserver/static ${website}/Server_Django/staticfile/
	Alias /scormserver/scormrte ${website}/Server_Django/scormrte/
	Alias /static ${website}/Server_Django/Server_Django/static
	AddType text/html .py
	<Directory ${website}>
        Options FollowSymLinks
        AllowOverride None
        Require all granted
	</Directory>
</VirtualHost>
EOF
mysql -uroot -e "create database scorm;"
mysql -uroot -e "grant all on scorm.* to ${mysql_user}@'%' identified by '${mysql_pass}';flush privileges;"
chown -R apache ${website}
[ ! -d ${website}/Server_Django/staticfile/scorm_upload ] && mkdir -p ${website}/Server_Django/staticfile/scorm_upload
#chmod -R 755 ${website}/Server_Django/staticfile/scorm_upload
chown -R apache ${website}/Server_Django/staticfile/scorm_upload
[ ! -d ${website}/Server_Django/log ] && mkdir ${website}/Server_Django/log
#chmod -R 755 ${website}/Server_Django/log
chown -R apache ${website}/Server_Django/staticfile/scorm_upload
${httpd_path}/bin/apachectl start
} >> install.log

echo 
echo "------Install Apache---------"
echo "------Install Apache---------" >> install.log
[ $(ps -ef | grep httpd |wc -l) -le 1 ] && apache_install
if [ $? -eq 0 ];then
	action "Install Apache successed" /bin/true
else
	action "Install Apache error" /bin/false
	exit 1
fi
echo "-----------Install mysql-----------"
echo "-----------Install mysql-----------" >> install.log
[ $(ps -ef | grep mysql |wc -l) -le 1 ] && mysql_install
if [ $? -eq 0 ];then
	action "Install mysql successed" /bin/true
else
	action "Install mysql error" /bin/false
	exit 1
fi

echo "---------Install python---------------"
echo "---------Install python---------------" >> install.log
install_python
if [ $? -eq 0 ];then
	action "Install python successed" /bin/true
else
	action "Install python error" /bin/false
	exit 1
fi
echo "---------Install python plugin---------------"
echo "---------Install python plugin---------------" >> install.log
install_python_plugin
if [ $? -eq 0 ];then
	action "Install python plugin successed" /bin/true
else
	action "Install python plugin error" /bin/false
	exit 1
fi
echo "---------config web site---------------"
echo "---------config web site---------------" >> install.log
config_web_site
if [ $? -eq 0 ];then
	action "config web site successed" /bin/true
else
	action "config web site error" /bin/false
	exit 1
fi

echo -e "Website Path\t${website}"
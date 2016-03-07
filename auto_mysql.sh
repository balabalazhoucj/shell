#!/bin/sh
. /etc/init.d/functions
. /etc/profile
VER="5.6.17"
MUSER="mysql"
MYSQLPORT=3306
MYSQLPATHOLD="/usr/local/mysql-${VER}"
MYSQLPATH=$(echo ${MYSQLPATHOLD} | awk -F "-" '{print $1}')
MYCNF="/etc/my.cnf"
MYSQLD="mysqld"
INSTANCE=2
AUTH="-uroot"
#AUTH="-uroot -p123456"


prepare_mysql() {
	if [ ! -e mysql-${VER}.tar.gz ];then
		echo "no mysql-${VER}.tar.gz package"
		return 1
	fi
	tar zxf mysql-${VER}.tar.gz && cd mysql-${VER}
	yum install ncurses-devel gcc-c++ cmake perl make bison -y > /dev/null 2>&1 || return 1
	id $MUSER > /dev/null 2>1 || useradd -s /bin/nologin -M $MUSER
	mkdir -p ${MYSQLPATHOLD}
	ln -s ${MYSQLPATHOLD} ${MYSQLPATH}
}

install_mysql() {
	cmake . -DCMAKE_INSTALL_PREFIX=${MYSQLPATHOLD} \
	-DENABLED_LOCAL_INFILE=1 \
	-DWITH_PARTITION_STORAGE_ENGINE=1 \
	-DWITH_EXTRA_CHARSETS:STRING=all \
	-DDEFAULT_CHARSET=utf8 \
	-DDEFAULT_COLLATION=utf8_general_ci \
	-DMYSQL_USER=${USER} > install.log
	make -j4 > /dev/null 2>&1
	make install > /dev/null 2>&1
	for a in $(ls ${MYSQLPATH}/bin)
	do
		ln -s ${MYSQLPATH}/bin/${a} /bin
	done
}

config_mysql() {
ID=$(echo $RANDOM$(date +%N)| cut -c 1-2)
[ -f ${MYCNF} ] && cp ${MYCNF} ${MPATH}/mysql$(date +%Y%m%d).cnf
cat >> ${MYCNF} << EOF
[${MYSQLD}]
basedir =  ${MYSQLPATH}
datadir = ${MYSQLDATA}
port = ${MYSQLPORT}
server_id = ${ID}
socket = ${MSCOKET}
user = ${MUSER}
#log-bin = ${MYSQLDATA}/mysql-bin
EOF
}

initializing_mysql() {
	chown -R mysql ${MPATH}
	${MYSQLPATH}/scripts/mysql_install_db --basedir=${MYSQLPATH} --datadir=${MYSQLDATA} --user=${MUSER} > /dev/null 2>&1
}

SINGLE() {
	echo "-----------Install mysql-${VER}-----------"
	if [ $(netstat -nltp | grep 3306 | wc -l) -eq 1 ];then
		echo "Mysql port ${MYSQLPORT} is already in use "
		return 1
	fi
	MPATH="/data/mysql${MYSQLPORT}"
	MYSQLDATA="${MPATH}/data"
	MSCOKET="/tmp/mysql.sock"
	MYSQLCMD="mysql ${AUTH} -e"
	mkdir -p ${MYSQLDATA}
	prepare_mysql && echo "Mysql-${VER} is prepared..." || return 1
	install_mysql && echo "Mysql-${VER} is installed..." || return 1
	config_mysql
	[ -f ${MYCNF} ] && echo "my.cnf is configed..." || return 1
	initializing_mysql
	cp ${MYSQLPATH}/support-files/mysql.server /etc/init.d/mysqld
	chmod +x /etc/init.d/mysqld
	/etc/init.d/mysqld start || return 1
	${MYSQLCMD} "drop user 'root'@'::1';drop user ''@'localhost';drop user ''@'localhost.localdomain';"
#	${MYSQLCMD} "update mysql.uesr set password=password('123456') where user='root' and host='localhost';"
#	${MYSQLCMD} "update mysql.uesr set password=password('123456') where user='root' and host='%';"
}

MUTIL() {
[ $(netstat -nltp | grep 3306 | wc -l) -eq 1 ] && MYSQLPORT=$(expr ${MYSQLPORT} + 1)
sed -i 's/^/#&/g' ${MYCNF}
muser=multi_admin
mpass=123
cat >> ${MYCNF} <<EOF
[mysqld_multi]
mysqld     = ${MYSQLPATH}/bin/mysqld_safe
mysqladmin = ${MYSQLPATH}/bin/mysqladmin
user       = ${muser}
password   = ${mpass}

EOF
	for ((i=1; i<=$INSTANCE; i++))
	do
		MPATH="/data/mysql${MYSQLPORT}"
		MYSQLDATA="${MPATH}/data"
		MSCOKET="${MPATH}/mysql.sock"
		((n++))
		MYSQLD=mysqld${n}
		MYSQLCMD="mysql ${AUTH} -S ${MPATH}/mysql.sock -e"
		mkdir -p ${MYSQLDATA}
		config_mysql && echo "Instance ${i} is configed" || continue 1
		sed -i '/\['"${MYSQLD}"'\]/,${/^basedir/d}' ${MYCNF}
		initializing_mysql
		mysqld_multi start ${i} || continue 1
		echo "waiting for mysql start..."
		sleep 2
		${MYSQLCMD} "grant shutdown on *.* to ${muser}@'localhost' identified by '${mpass}';flush privileges;drop user 'root'@'::1';drop user ''@'localhost';drop user ''@'localhost.localdomain';"
		mysqladmin --login-path=mysqld_multi -S ${MSCOKET} shutdown
		if [ $? -eq 0 ];then
			action "Instance ${i} is initialized..." /bin/true
			echo -e "Instance ${i} Server-ID:\t"${ID}
			echo -e "Instance ${i} Port:\t"${MYSQLPORT}
			echo -e "Instance ${i} Data Path:\t"${MYSQLDATA}
		else
			action "Instance ${i} initializing error" /bin/false
			exit 1
		fi			
		((MYSQLPORT++))
	done
}

echo -e "\n"
echo -e "\t[1] Install mysql-${VER}"
echo -e "\t[2] Install Mysql-${VER} Multi Instance"
echo -e "\n"
read   -p "PLS input Num.[1-4]:" option
case "$option" in
	1)
		SINGLE
	if [ $? = 0 ];then
		action "Mysql is initialized..." /bin/true
	else
		action "Mysql initializing error" /bin/false
		exit 1
	fi				
		;;
	2)
		MUTIL
		echo
		echo "##### How to  mange the mysql multi #####"
		echo "Usage: mysqld_multi [start|stop|restart|report]"
		echo "Optional info: "
		echo " This uses mysql_multi, which allows control of individual mysqld "
		echo " instances. Do this by specifying a list of numbers following the"
		echo " command (start/stop/etc.). For example:"
		echo " mysqld_multi stop 1,3"
		echo " mysqld_multi stop 1-3"
		echo " mysqld_multi stop 1"
		echo " mysqld_multi stop 1-3,5"
		echo " mysqld_multi --help"
		echo
		;;
	*)
		echo "Usage: $0 must be single Num. "
		;;
esac

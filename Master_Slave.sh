#!/bin/sh
. /etc/init.d/functions
. /etc/profile
MS() {
	if [ -z ${MSCOKET} ];then
		action "Variable is null in $0,MSCOKET" /bin/false
		exit 1
	fi
	if [ $(find / -name "mysqld.sock" | wc -l) -eq 0 ];then
		action "Mysql is not running" /bin/false
		exit 1
	fi
	AUTH="-uroot"
	#AUTH="-uroot -p123456"
	MYSQLCMD="mysql ${AUTH} -S ${MSCOKET}"
}
	
MASTER() {
MSCOKET=""
MASTERIP=""
if [ -z ${MASTERIP} ];then
	echo "Variable is null in $0,MASTERIP"
	return 1
fi
MS
#状态为零，非master server
if [ $(${MYSQLCMD} -e "show master status;" | wc -l ) -eq 0 ];then
	echo "Fist,set log-bin postion in my.cnf and restart mysql .For example:log-bin = /data/mysql3307/data"
	return 1
fi
#状态不为零，此非slave server
if [ $(${MYSQLCMD} -e "show slave status;" | wc -l ) -ne 0 ];then
	echo -e "this server is slave"
	return 1
fi
${MYSQLCMD} -e "grant replication slave on *.* to rep@'%' identified by '123';flush privileges;"
${MYSQLCMD} -e "flush tables with read lock"
LOGFILE=$(${MYSQLCMD} -ss -e "show master status"| awk '{print $1}')
POS=$(${MYSQLCMD} -ss -e "show master status"| awk '{print $2}')
if [ -z ${LOGFILE} -o -z ${POS} ];then
	echo "master configure fail"
	return 1
fi
mysqldump ${AUTH} -S ${MSCOKET} -A -B --flush-logs > fullback.sql
${MYSQLCMD} -e "unlock tables;"
cat > SLAVECONF.txt << EOF
change master to
master_host='${MASTERIP}',
master_port=$(${MYSQLCMD} -ss -e "show global variables like 'port';" |awk '{print $2}'),
master_user='rep',
master_password='123',
master_log_file='${LOGFILE}',
master_log_pos=${POS};
EOF
#scp fullback.sql SLAVECONF.txt root@$IP:~
}

SLAVE() {
MSCOKET=""
SLAVEIP=""
if [ -z ${SLAVEIP} ];then
	echo "Variable is null in $0, SLAVEIP"
	return 1
fi
MS
if [ $(${MYSQLCMD} -e "show master status;" | wc -l ) -ne 0 ];then
	echo "this server is master"
	return 1
fi
# if [ $(${MYSQLCMD} -e "show slave status" | wc -l ) -ne 0 ];then
	# echo "this server is slave now"
	# return 1
# fi
echo "restore backup file"
${MYSQLCMD} -e "source fullback.sql"
cat SLAVECONF.txt | ${MYSQLCMD}
${MYSQLCMD} -e "start slave;"
IO=$(${MYSQLCMD} -e "show slave status\G" | grep "Slave_IO_Running:" | awk '{print $2}')
SQL=$(${MYSQLCMD} -e "show slave status\G" | grep "Slave_SQL_Running:" | awk '{print $2}')
}
echo
echo -e "\t[1] Setup Master"
echo -e "\t[2] Setup Slave"
echo -e "\n"
read   -p "PLS input Num.[1,2]:" option
case "$option" in
	1)
		MASTER
		if [ $? -eq 0 ];then
			action "Mysql master is running" /bin/true
			echo "mysql backupfile:fullback.sql"
			echo "masterconf file: SLAVECONF.txt"
		else
			action "Mysql master error" /bin/false
		fi
		;;
	2)
		SLAVE
		if [ $? -eq 0 -a ${IO} = "Yes" -a  ${SQL} = "Yes" ] ;then
			action "Mysql slave is running" /bin/true
			echo "*************Mysql Slave Status"
			sleep 2
			${MYSQLCMD} -S ${MSCOKET}  -e "start slave;show slave status\G" | sed -n "2,13p;46p" | sed 's/^ \+//g'
		else
			action "Mysql Slave is error" /bin/false
			${MYSQLCMD} -S ${MSCOKET} -e "show slave status\G" | egrep "Slave_IO_Running:|Slave_SQL_Running:"
		fi
		;;
	*)
		echo "Usage: $0 must be single Num. "
		;;
esac
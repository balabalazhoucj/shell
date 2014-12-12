###############################
#PS1="`whoami`@`hostname`:"'[$PWD]'
history
USER_IP=`who -u am i 2>/dev/null| awk '{print $NF}'|sed -e 's/[()]//g'`
if [ "$USER_IP" = "" ];then
	USER_IP=`hostname`
fi

if [ ! -d /var/log/.history ];then
	mkdir /var/log/.history
chmod 777 /var/log/.history
fi

if [ ! -d /var/log/.history/${LOGNAME} ];then
	mkdir /var/log/.history/${LOGNAME}
	chmod 300 /var/log/.history/${LOGNAME}
fi

export HISTSIZE=4096
DT=`date +"%Y%m%d_%H%M%S"`
export HISTFILE="/var/log/.history/${LOGNAME}/${USER_IP}_history_$DT"
chmod 600 /var/log/.history/${LOGNAME}/*history* 2>/dev/null
######################################
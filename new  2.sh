#!/bin/bash
#参考  find `pwd` -name 'abc' -type d | xargs rename abc def
#目录重命名，如果新目录存在则拷贝源目录内文件至现有目录中

D_S=睿泰科技
D_N=retechwing_rnu
for f in $(find $(pwd) -name ${D_S} -type d)
do 
	
	cd $(dirname $f) && ls ${D_N} > /dev/null 2>&1
	if [ $? -ne 0 ];then
		mv ${D_S} ${D_N}
	else
		cp ${D_S}/* ${D_N}/ && rm -rf 
	fi
done






RM{
mysql_cmd='mysql -uroot -h -e'
Filepath_cmd=$(${msyql_cmd} 'select FilePath from File where Filename =${dataname} ')
find $(pwd) -name '$(basename $FilePath_cmd)*' | xargs rm -rf
}

for i in RM.txt
do
	dataname=$i
	RM
done




sed -i 's/[0-9]\{4\},/'"''"'/'


select id from file where 
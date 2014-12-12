#!/bin/sh
HIT=0
MISS=0
mysqlcmd="mysql -uroot -e"
while read n
do
    #echo $n
    #$mysqlcmd "select REPLACE(ConvertFilePath,'\\\\','\\/') ConvertFilePath from courseware.File where Filename='${n}'"
    #cmd='select REPLACE(ConvertFilePath,"\\","/"  from courseware.File where Filename='${n}'' 
    #cmd='select REPLACE(ConvertFilePath,"\\","/")  from courseware.File from courseware.File where Filename='"$n"'' 
    #echo "$cmd"
    #url=$($mysqlcmd "$cmd" | sed -n '2p')
    #echo $url
    url=$($mysqlcmd "select REPLACE(ConvertFilePath,'\\\\','\\/') ConvertFilePath from courseware.File where Filename='${n}'" | sed -n '2p')
    [ -z $url ] && exit 1
    status=$(curl -I -s http://cw.elearningcn.com/$url | awk '$2 ~/MISS|HIT/{print $2}')
    [ $status = "HIT" ] && ((HIT++)) && echo $n
    [ $status = "MISS" ] && ((MISS++))
    #read -n1 var
done < 1.txt
total=$(awk '{print NR}' 1.txt | tail -1)
echo -e "total:\t" $total
echo -e "HIT:\t" $HIT
echo -e "MISS:\t"$MISS
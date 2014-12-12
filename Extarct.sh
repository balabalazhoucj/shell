#!/bin/sh

########################
#安装文件解压
#Scprits Name:Extarct.sh
#######################

. /etc/init.d/functions
. /etc/profile

extract() {
local i=0
for n in $(ls *.tar *.tar.gz *.tgz *.tar.bz2 *.tar.bz *.tar.Z *.tar *.gz *.Z *.zip *.rar)
do
	case "$n" in
		*.tar.gz)
			tar -zxf $n > /dev/null 2>&1
			#ls $n |  rev | sed 's/\./&\n/g'|tail -2 | tr -d '\n'| rev,去掉压缩后缀
			#ls $n|sed 's/-[0-9].*//g'，去掉版本号到结尾
			mv $(ls $n |  rev | sed 's/\./&\n/g'|tail -2 | tr -d '\n'| rev) $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.tar.bz2|*.tar.bz)
			tar jxf $n
			mv $(ls $n |  rev | sed 's/\./&\n/g'|tail -2 | tr -d '\n'| rev) $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.tar.Z)
			tar Zxf $n
			mv $(ls $n |  rev | sed 's/\./&\n/g'|tail -2 | tr -d '\n'| rev) $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.tgz)
			tar -zxf $n > /dev/null 2>&1
			mv $(ls $n |  rev | sed 's/\./&\n/g'|tail -1 | tr -d '\n'| rev) $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.tar)
			tar xf $n
			mv $(ls $n |  rev | sed 's/\./&\n/g'|tail -1 | tr -d '\n'| rev) $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.gz)
			[ $(rpm -aq gzip | wc -l) -eq 0 ] && yum install gzip -y
			gzip -d $n
			mv $(ls $n |  rev | sed 's/\./&\n/g'|tail -1 | tr -d '\n'| rev) $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.bz2|*.bz)
			bzip2 -d $n
			mv $(ls $n |  rev | sed 's/\./&\n/g'|tail -1 | tr -d '\n'| rev) $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.Z)
			uncompress $n
			mv $(ls $n |  rev | sed 's/\./&\n/g'|tail -1 | tr -d '\n'| rev) $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.zip)
			[ $(rpm -aq unzip | wc -l) -eq 0 ] && yum install unzip -y
			unzip -q $n
			mv $(ls $n |  rev | sed 's/\./&\n/g'|tail -1 | tr -d '\n'| rev) $(ls $n|sed 's/-[0-9].*//g')
			;;
		*.rar)
			rar e $n
			pk[i]=$(ls ${n}|sed 's/\./&\n/g'|tail -1 | tr -d '\n' ; echo)
			;;
		*)
			echo "unsupported this type"
			;;
	esac
	((i++))
	unset i
done
}

extract
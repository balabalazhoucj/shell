su -c 'yum localinstall --nogpgcheck http://download1.rpmfusion.org/free/el/updates/6/i386/rpmfusion-free-release-6-1.noarch.rpm http://download1.rpmfusion.org/nonfree/el/updates/6/i386/rpmfusion-nonfree-release-6-1.noarch.rpm'


ffmpeg -i input.mp4 -codec copy -map 0 -f segment -vbsf h264_mp4toannexb -flags -global_header -segment_format mpegts -segment_list output.m3u8 -segment_time 10 output-%03d.ts

convert() {
	ffmpeg -i ${n} \
	-codec copy \
	-map 0 \
	-f segment \
	-vbsf h264_mp4toannexb \
	-flags -global_header \
	-segment_format mpegts \
	-segment_list ${FilePath}${Fname}.m3u8 \
	-segment_time 10 \
	${FilePath}/${Fname}-%04d.ts
}

DPATH=$(find / -name *.mp4 -o -name *.flv -type f)
for n in ${DPATH}
do
	P=$(dirname $n)
	Fname=$(basename $n | awk -F . '{print $1}')
	FilePath=$(mkdir -p ${p}/$Fname)
	convert
	if [ $? -eq 0];then
		echo -e "${n}\t${FilePath}/${Fname}" >> convert.log
		rm -f ${n}
	else
		echo "convert error"
done
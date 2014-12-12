yum install \
binutils \
compat-libcap1 \
compat-libstdc++-33 \
compat-libstdc++-33*.i686 \
elfutils-libelf-devel \
gcc \
gcc-c++ \
glibc*.i686 \
glibc \
glibc-devel \
glibc-devel*.i686 \
ksh \
libgcc*.i686 \
libgcc \
libstdc++ \
libstdc++*.i686 \
libstdc++-devel \
libstdc++-devel*.i686 \
libaio \
libaio*.i686 \
libaio-devel \
libaio-devel*.i686 \
make \
sysstat \
unixODBC \
unixODBC*.i686 \
unixODBC-devel \
unixODBC-devel*.i686 -y



#output as png image
set term png enhanced font '/usr/share/fonts/liberation/LiberationSans-Regular.ttf'
#验证是否有该字体!
# ls /usr/share/fonts/liberation/LiberationSans-Regular.ttf
#save file to  png file
#输出图片文件名
set output "keepalive.png"           
#graph title
#图片标题
set title "Lin-credibe"     
#nicer aspect ratio for image size
set size 1,0.7
# y-axis grid
set grid y
# x-axis label
set xlabel "request"
#y-axis label
set ylabel "response time (ms)"
plot "keep.data" using 9 smooth sbezier with lines title "usingKeepAlive",
"nokeep.data" using 9 smooth sbezier with lines title "noKeepAlive"
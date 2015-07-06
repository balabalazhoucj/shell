#安装nginx
yum install pcre-devel openssl-devel -y
useradd -s /sbin/nologin -M nginx
mkdir -p /opt/nginx-1.8.0/{run,log}
ln -s /opt/nginx-1.8.0 /opt/nginx
wget http://nginx.org/download/nginx-1.8.0.tar.gz
tar zxf nginx-1.8.0.tar.gz
cd nginx-1.8.0
./configure --prefix=/data/nginx-1.8.0/ \
--user=nginx \
--group=nginx \
--with-http_ssl_module \
--with-http_sub_module \
--with-http_stub_status_module \
--error-log-path=/data/nginx/log/error.log   \
--http-log-path=/data/nginx/log/access.log   \
--pid-path=/data/nginx/run/nginx.pid \
--with-poll_module \
--with-http_realip_module\
--with-http_flv_module \
--with-http_mp4_module
make && make install
ln -s /opt/nginx-1.8.0 /opt/nginx
cd /opt/nginx/conf
egrep -v "^$|#" nginx.conf.default >nginx.conf

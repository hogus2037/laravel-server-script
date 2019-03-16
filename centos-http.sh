#!/bin/sh

yum -y install gcc gcc-c++ autoconf libjpeg libjpeg-devel libpng libpng-devel freetype freetype-devel libxml2 libxml2-devel zlib zlib-devel glibc glibc-devel glib2 glib2-devel bzip2 bzip2-devel ncurses ncurses-devel curl curl-devel e2fsprogs e2fsprogs-devel krb5 krb5-devel libidn libidn-devel openssl openssl-devel openldap openldap-devel nss_ldap openldap-clients openldap-servers cmake libevent-devel ntp unzip zip git svn

basedir=/data/
logdir=${basedir}logs
redisdir=${basedir}redis
softwaredir=${basedir}software
webdir=${basedir}www

pcre_ver=pcre-8.35
libiconv=libiconv-1.14
libmcrypt=libmcrypt-2.5.8
mhash=mhash-0.9.9.9
mcrypt=mcrypt-2.6.8
nginx_ver=nginx-1.13.5
php=php-7.1.9
redis=redis-3.2.10
mysql=mysql-5.6.21
cmake=cmake-3.8.0-rc4

mkdir -p $logdir
mkdir -p $redisdir
mkdir -p $softwaredir
mkdir -p $webdir

cd $softwaredir

groupadd www
useradd -g www www

# groupadd mysql
# useradd -g mysql mysql

chmod +w $logdir
chmod +w $webdir
chown -R www:www $logdir
chown -R www:www $webdir

cd $softwaredir
tar zxvf ${pcre_ver}.tar.gz
cd $pcre_ver
./configure
make && make install

cd $softwaredir
tar zxvf ${nginx_ver}.tar.gz
cd ${nginx_ver}
./configure --user=www --group=www --prefix=/usr/local/webserver/nginx --with-pcre=${softwaredir}/${pcre_ver} --with-http_stub_status_module --with-http_ssl_module
make && make install
/usr/local/webserver/nginx/sbin/nginx -c /usr/local/webserver/nginx/config/nginx.conf

cd $softwaredir
tar zxvf ${libiconv}.tar.gz
cd ${libiconv}
./configure --prefix=/usr/local
make && make install

cd $softwaredir
tar zxvf ${libmcrypt}.tar.gz
cd ${libmcrypt}
./configure
make
make install
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make && make install

cd $softwaredir
tar zxvf ${mhash}.tar.gz
cd ${mhash}
./configure
make && make install

ln -s /usr/local/lib/libmcrypt.la /usr/lib/libmcrypt.la
ln -s /usr/local/lib/libmcrypt.so /usr/lib/libmcrypt.so
ln -s /usr/local/lib/libmcrypt.so.4 /usr/lib/libmcrypt.so.4
ln -s /usr/local/lib/libmcrypt.so.4.4.8 /usr/lib/libmcrypt.so.4.4.8
ln -s /usr/local/lib/libmhash.a /usr/lib/libmhash.a
ln -s /usr/local/lib/libmhash.la /usr/lib/libmhash.la
ln -s /usr/local/lib/libmhash.so /usr/lib/libmhash.so
ln -s /usr/local/lib/libmhash.so.2 /usr/lib/libmhash.so.2
ln -s /usr/local/lib/libmhash.so.2.0.1 /usr/lib/libmhash.so.2.0.1
ln -s /usr/local/bin/libmcrypt-config /usr/bin/libmcrypt-config

cd $softwaredir
tar zxvf ${mcrypt}.tar.gz
cd ${mcrypt}
/sbin/ldconfig
./configure
make && make install

cp -frp /usr/lib64/libldap* /usr/lib/

cd $softwaredir
tar zxvf ${php}.tar.gz
cd ${php}
./configure --prefix=/usr/local/webserver/php --with-config-file-path=/usr/local/webserver/php/etc --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fpm --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-zip --enable-soap --without-pear --with-mysqli=mysqlnd --with-pdo-mysql=mysqlnd
make ZEND_EXTRA_LIBS='-liconv'
make install
cp php.ini-development /usr/local/webserver/php/etc/php.ini
cp /usr/local/webserver/php/etc/php-fpm.conf.default /usr/local/webserver/php/etc/php-fpm.conf
cp ${softwaredir}/${php}/sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod 755 /etc/init.d/php-fpm


cd $softwaredir
tar zxvf ${redis}.tar.gz
mv ${redis} /usr/local/webserver/redis
cd /usr/local/webserver/redis/
make && make install

cd $softwaredir
unzip phpredis-php7.zip
cd phpredis-php7
/usr/local/webserver/php/bin/phpize
./configure --with-php-config=/usr/local/webserver/php/bin/php-config
make && make install

# cd $softwaredir
# tar zxvf eaccelerator-eaccelerator-42067ac.tar.gz
# cd eaccelerator-eaccelerator-42067ac
# /usr/local/webserver/php/bin/phpize
# ./configure --with-php-config=/usr/local/webserver/php/bin/php-config
# make && make install

# cd $softwaredir
# tar zxvf ${cmake}.tar.gz
# cd ${cmake}
# ./configure
# make && make install

# cd $softwaredir
# tar zxvf ${mysql}.tar.gz
# cd ${mysql}
# cmake -DCMAKE_INSTALL_PREFIX=/usr/local/webserver/mysql \
# -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
# -DDEFAULT_CHARSET=utf8 \
# -DDEFAULT_COLLATION=utf8_general_ci \
# -DWITH_EXTRA_CHARSETS:STRING=utf8,gbk \
# -DWITH_MYISAM_STORAGE_ENGINE=1 \
# -DWITH_INNOBASE_STORAGE_ENGINE=1 \
# -DWITH_MEMORY_STORAGE_ENGINE=1 \
# -DENABLED_LOCAL_INFILE=1 \
# -DMYSQL_DATADIR=/usr/local/webserver/mysql/data \
# -DMYSQL_USER=mysql \
# -DMYSQL_TCP_PORT=3306 \
# -DSYSCONFDIR=/etc \
# -DINSTALL_SHAREDIR=share

# make && make install

# chown -R mysql:mysql /usr/local/webserver/mysql
# cd /usr/local/webserver/mysql
# scripts/mysql_install_db --user=mysql --datadir=/usr/local/webserver/mysql/data
# cp support-files/mysql.server /etc/init.d/mysql
# chkconfig mysql on

# cd ${php}
# cd ext/pdo_mysql
# /usr/local/webserver/php/bin/phpize
# ./configure --with-php-config=/usr/local/webserver/php/bin/php-config --with-pdo-mysql=/usr/local/webserver/mysql 
# make && make install

echo Complete!
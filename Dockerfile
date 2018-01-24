FROM ubuntu:trusty
# Update packages
RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list && apt-get update
# install curl, wget,sql ,server
RUN apt-get install -y libpcre3 libpcre3-dev libssl-dev make gcc g++ build-essential cmake curl wget git unzip python-software-properties python-setuptools software-properties-common debian-archive-keyring python-pip openssl openssh-server
RUN apt-get install -y --force-yes libsodium18 mariadb-server mariadb-client memcached php-memcache
# Install tengine
ADD https://github.com/alibaba/tengine/archive/master.tar.gz .
RUN tar zxvf /master.tar.gz && cd tengine-master && ./configure --with-http_concat_module && make && make install && rm -rf /master.tar.gz /tengine-master
# Install php
ADD https://github.com/php/php-src/archive/master.tar.gz .
RUN tar zxvf /master.tar.gz && cd php-src-master && ./buildconf && ./configure \
    --prefix=/usr/local/php7 \                              #[PHP7安装的根目录]
    --exec-prefix=/usr/local/php7 \
    --bindir=/usr/local/php7/bin \
    --sbindir=/usr/local/php7/sbin \
    --includedir=/usr/local/php7/include \
    --libdir=/usr/local/php7/lib/php \
    --mandir=/usr/local/php7/php/man \
    --with-config-file-path=/usr/local/php7/etc \           #[PHP7的配置目录]
    --with-mysql-sock=/var/run/mysql/mysql.sock \           #[PHP7的Unix socket通信文件]
    --with-mcrypt=/usr/include \
    --with-mhash \
    --with-openssl \
    --with-mysql=shared,mysqlnd \                           #[PHP7依赖mysql库]              
    --with-mysqli=shared,mysqlnd \                          #[PHP7依赖mysql库]
    --with-pdo-mysql=shared,mysqlnd \                       #[PHP7依赖mysql库]
    --with-gd \
    --with-iconv \
    --with-zlib \
    --enable-zip \
    --enable-inline-optimization \
    --disable-debug \
    --disable-rpath \
    --enable-shared \
    --enable-xml \
    --enable-bcmath \
    --enable-shmop \
    --enable-sysvsem \
    --enable-mbregex \
    --enable-mbstring \
    --enable-ftp \
    --enable-gd-native-ttf \
    --enable-pcntl \
    --enable-sockets \
    --with-xmlrpc \
    --enable-soap \
    --without-pear \
    --with-gettext \
    --enable-session \                                      #[允许php会话session]
    --with-curl \                                           #[允许curl扩展]
    --with-jpeg-dir \
    --with-freetype-dir \
    --enable-opcache \                                      #[使用opcache缓存]
    --enable-fpm \
    --enable-fastcgi \
    --with-fpm-user=nginx \                                 #[php-fpm的用户]
    --with-fpm-group=nginx \                                #[php-fpm的用户组]
    --without-gdbm \
    --with-mcrypt=/usr/local/related/libmcrypt \            #[指定libmcrypt位置]
    --disable-fileinfo \
&& make && make install && rm -rf /master.tar.gz /php-src-master
# Install Supervisor & tingyun & shadowsocks
RUN /usr/bin/easy_install supervisor && /usr/bin/easy_install supervisor-stdout
RUN wget http://download.networkbench.com/agent/php/2.7.0/tingyun-agent-php-2.7.0.x86_64.deb?a=1498149881851 -O tingyun-agent-php.deb
RUN wget http://download.networkbench.com/agent/system/1.1.1/tingyun-agent-system-1.1.1.x86_64.deb?a=1498149959157 -O tingyun-agent-system.deb
RUN sudo dpkg -i tingyun-agent-php.deb && sudo dpkg -i tingyun-agent-system.deb && rm -rf /tingyun-*.deb
RUN pip install shadowsocks
# Start
ADD start.sh /start.sh
RUN sed -i -e 's/\r//g' /start.sh && sed -i -e 's/^M//g' /start.sh && chmod +x /*.sh
VOLUME ["/data"]
EXPOSE 22 80 3306 8388 9001 11211
CMD ["/bin/bash", "/start.sh"]

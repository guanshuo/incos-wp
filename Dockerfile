FROM ubuntu:trusty
# apt install
RUN apt-get update && apt-get install -y --force-yes \
    rcs build-essential zlib1g-dev pkg-config libexpat1-dev libgeoip-dev libbz2-dev libaio-dev libreadline-dev libncurses5-dev \
    libpcre3-dev libfreetype6-dev libmcrypt-dev libcurl4-openssl-dev libxml2-dev libpng-dev libjpeg-dev libpng-dev libwebp-dev \
    python-software-properties python-setuptools software-properties-common debian-archive-keyring curl wget unzip git \
    autoconf bison memcached openssl openssh-server
# Install cmake
ADD https://github.com/Kitware/CMake/archive/master.tar.gz .
RUN tar zxvf /master.tar.gz && cd CMake-master && ./bootstrap && make && make install && rm -rf /master.tar.gz /CMake-master
# Install libzip
ADD https://github.com/nih-at/libzip/archive/master.tar.gz .
RUN tar zxvf /master.tar.gz && cd libzip-master && mkdir build && cd build && cmake .. && make && make install && rm -rf /master.tar.gz /libzip-master
# Install re2c
ADD https://github.com/skvadrik/re2c/archive/master.tar.gz .
RUN tar zxvf /master.tar.gz && cd re2c-master/re2c && ./autogen.sh && ./configure && make && make install && rm -rf /master.tar.gz /re2c-master
# ldconfig
RUN echo "/usr/local/lib" >> /etc/ld.so.conf && ldconfig
# Install mariadb
RUN git clone --recurse-submodules --depth=1 https://github.com/MariaDB/server.git && cd server && cmake . \
    -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
    -DMYSQL_DATADIR=/data/mysql \
    -DSYSCONFDIR=/etc/mysql \
    -DWITHOUT_TOKUDB=1 \
    -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
    -DDEFAULT_CHARSET=utf8 \
    -DDEFAULT_COLLATION=utf8_general_ci \
    -DWITHOUT_INNOBASE_STORAGE_ENGINE=1 \
    -DWITHOUT_ARCHIVE_STORAGE_ENGINE=1 \
    -DWITHOUT_BLACKHOLE_STORAGE_ENGINE=1 \
&& make && make install && rm -rf /server
# Install php
ADD https://github.com/php/php-src/archive/master.tar.gz .
RUN tar zxvf /master.tar.gz && cd php-src-master && ./buildconf && ./configure \
    --prefix=/usr/local/php7 \
    --exec-prefix=/usr/local/php7 \
    --bindir=/usr/local/php7/bin \
    --sbindir=/usr/local/php7/sbin \
    --includedir=/usr/local/php7/include \
    --libdir=/usr/local/php7/lib/php \
    --mandir=/usr/local/php7/php/man \
    --with-config-file-path=/usr/local/php7/etc \
    --with-mysql-sock=/var/run/mysqld/mysqld.sock \
    --with-mhash \
    --with-openssl \
    --with-mysqli=shared,mysqlnd \
    --with-pdo-mysql=shared,mysqlnd \
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
    --enable-pcntl \
    --enable-sockets \
    --with-xmlrpc \
    --enable-soap \
    --without-pear \
    --with-gettext \
    --enable-session \
    --with-curl \
    --with-jpeg-dir \
    --with-freetype-dir \
    --enable-opcache \
    --enable-fpm \
    --with-fpm-user=www-data \
    --with-fpm-group=www-data \
    --without-gdbm \
    --enable-fast-install \
    --disable-fileinfo \
&& make && make install && rm -rf /master.tar.gz /php-src-master
# Install tengine
ADD https://github.com/alibaba/tengine/archive/master.tar.gz .
RUN tar zxvf /master.tar.gz && cd tengine-master && ./configure --with-http_concat_module && make && make install && rm -rf /master.tar.gz /tengine-master
# Install Supervisor & tingyun
RUN /usr/bin/easy_install supervisor && /usr/bin/easy_install supervisor-stdout
RUN wget http://download.networkbench.com/agent/php/2.7.0/tingyun-agent-php-2.7.0.x86_64.deb?a=1498149881851 -O tingyun-agent-php.deb
RUN wget http://download.networkbench.com/agent/system/1.1.1/tingyun-agent-system-1.1.1.x86_64.deb?a=1498149959157 -O tingyun-agent-system.deb
RUN sudo dpkg -i tingyun-agent-php.deb && sudo dpkg -i tingyun-agent-system.deb && rm -rf /tingyun-*.deb
# Start
ADD start.sh /start.sh
RUN sed -i -e 's/\r//g' /start.sh && sed -i -e 's/^M//g' /start.sh && chmod +x /*.sh
VOLUME ["/data"]
EXPOSE 22 80 3306 8388 9001 11211
CMD ["/bin/bash", "/start.sh"]

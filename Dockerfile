FROM ubuntu:trusty
# Update packages
RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list && apt-get update
# install curl, wget,sql ,server
RUN apt-get install -y libpcre3 libpcre3-dev libssl-dev make gcc g++ build-essential cmake curl wget git unzip python-software-properties python-setuptools software-properties-common debian-archive-keyring python-pip libsodium-dev openssl openssh-server
RUN add-apt-repository -y ppa:ondrej/php && apt-get update
RUN apt-get install -y --force-yes mariadb-server mariadb-client memcached php7.0 php7.0-fpm php7.0-mysql php7.0-curl php7.0-gd php7.0-imap php7.0-json php7.0-cli php7.0-xml php-memcache
# Install tengine
ADD http://tengine.taobao.org/download/tengine-2.2.0.tar.gz .
RUN tar zxvf tengine-2.2.0.tar.gz && cd tengine-2.2.0 && ./configure --with-http_concat_module && make && make install
# Install Supervisor & tingyun
RUN /usr/bin/easy_install supervisor && /usr/bin/easy_install supervisor-stdout
RUN wget http://download.networkbench.com/agent/php/2.7.0/tingyun-agent-php-2.7.0.x86_64.deb?a=1498149881851 -O tingyun-agent-php.deb
RUN wget http://download.networkbench.com/agent/system/1.1.1/tingyun-agent-system-1.1.1.x86_64.deb?a=1498149959157 -O tingyun-agent-system.deb
RUN sudo dpkg -i tingyun-agent-php.deb
RUN sudo dpkg -i tingyun-agent-system.deb
# Install shadowsocks
RUN pip install shadowsocks
# Start
ADD start.sh /start.sh
RUN sed -i -e 's/\r//g' /start.sh && sed -i -e 's/^M//g' /start.sh && chmod +x /*.sh
VOLUME ["/data"]
EXPOSE 22 80 3306 8118 9001 11211
CMD ["/bin/bash", $shell ]

FROM ubuntu:trusty
# Update packages
RUN echo "deb http://archive.ubuntu.com/ubuntu/ precise universe" >> /etc/apt/sources.list && apt-get update
# install curl, wget,sql ,server
RUN apt-get install -y curl wget git unzip python-software-properties python-setuptools openssh-server software-properties-common debian-archive-keyring
RUN add-apt-repository -y ppa:ondrej/php && apt-get update
RUN apt-get install -y --force-yes mysql-server mysql-client memcached php7.0 php7.0-fpm php7.0-mysql php7.0-curl php7.0-gd php7.0-imap php7.0-json php7.0-cli php7.0-xml php-memcache
# Install tengine
RUN wget http://tengine.taobao.org/download/tengine-2.2.0.tar.gz -O tengine.tar.gz
RUN tar -zxvf tengine.tar.gz && cd /tengine
RUN ./configure --with-http_concat_module
RUN make && make install
RUN cd /
# Install Supervisor & tingyun
RUN /usr/bin/easy_install supervisor && /usr/bin/easy_install supervisor-stdout
RUN wget http://download.tingyun.com/agent/php/2.5.0/tingyun-agent-php-2.5.0.x86_64.deb?a=1479890082446 -O tingyun-agent-php.deb
RUN wget http://download.tingyun.com/agent/system/1.1.1/tingyun-agent-system-1.1.1.x86_64.deb?a=1479890139704 -O tingyun-agent-system.deb
RUN sudo dpkg -i tingyun-agent-php.deb
RUN sudo dpkg -i tingyun-agent-system.deb
# Start
ADD start.sh /start.sh
RUN sed -i -e 's/\r//g' /start.sh && sed -i -e 's/^M//g' /start.sh && chmod +x /*.sh
VOLUME ["/data"]
EXPOSE 22 80 3306 11211
CMD ["/bin/bash", "/start.sh"]

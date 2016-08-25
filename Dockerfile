FROM ubuntu:trusty
# Update packages
# install curl, wget, server, php
RUN apt-get install -y curl wget git unzip python-software-properties python-setuptools openssh-server
RUN add-apt-repository ppa:ondrej/php-7.0
RUN apt-get update
RUN apt-get install -y nginx mysql-server mysql-client php7.0-fpm php7.0-mysql php7.0-curl php7.0-gd php7.0-json php7.0-cli php7.0-imap
# Install Supervisor
RUN /usr/bin/easy_install supervisor && /usr/bin/easy_install supervisor-stdout
# Start
ADD start.sh /start.sh
RUN sed -i -e 's/\r//g' /start.sh && sed -i -e 's/^M//g' /start.sh && chmod +x /*.sh
VOLUME ["/data"]
EXPOSE 22 80 3306
CMD ["/bin/bash", "/start.sh"]
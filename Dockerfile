#!/usr/bin/docker build .
#
# VERSION               1.0

FROM       ubuntu
MAINTAINER maniasso@gmail.com

# create file to see if this is the firstrun when started
RUN touch /firstrun

RUN apt-get update && DEBIAN_FRONTEND="noninteractive" TZ="America/New_York" apt-get install -y tzdata
RUN apt-get install -y \
    make \
    wget \
    gcc \
    libmysqlclient-dev \
    libxml2-dev \
    libmysqlclient-dev  \
    libxml2-dev  \
    libsnmp-dev  \
    libevent-dev  \
    libcurl4-gnutls-dev  \
    libpcre3-dev \
    gcc  \
    make  \
    pkg-config \
    libssh-dev  \
    libssh2-1-dev \
    libopenipmi-dev \
    golang \
    libldap-dev \
    supervisor \
    rsyslog


RUN apt-get install -y \
            apache2 \
            curl \
            libapache2-mod-php \
            ca-certificates \
            mysql-client \
            locales \
            php8.1-bcmath \
            php8.1-gd \
            php8.1-ldap \
            php8.1-mbstring \
            php8.1-mysql \
            php8.1-xml \
            php-fpm && \
            apt-get -y autoremove && \
            apt-get -y clean && \
            rm -rf /var/lib/apt/lists/*

RUN  groupadd --system zabbix  && \
     useradd --system -g zabbix -d /usr/local/etc -s /sbin/nologin -c "Zabbix Monitoring System" zabbix

RUN cd /tmp && \
    wget https://cdn.zabbix.com/zabbix/sources/stable/6.2/zabbix-6.2.0.tar.gz && \
    tar -xvzf zabbix-6.2.0.tar.gz && \
    cd zabbix-6.2.0 && \
    ./configure --enable-server --enable-webservice --enable-agent2 --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 --with-openipmi --with-ssh --with-ldap && \
    make install

WORKDIR /usr/local/etc
RUN mkdir -p /var/www/html/zabbix && \
    cp -rp /tmp/zabbix-6.2.0/ui/* /var/www/html/zabbix && \
    chown -R zabbix:zabbix /var/www/html/zabbix

COPY php.ini /etc/php/8.1/apache2/
COPY supervisord.conf /etc/supervisor
COPY startup.sh /startup.sh
COPY zabbix_server.conf /usr/local/etc
RUN chmod +x /startup.sh

EXPOSE 80 10051
VOLUME [ "/usr/local/etc","/var/www/html" ]

ENTRYPOINT [ "/startup.sh" ]

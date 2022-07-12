#!/bin/bash

if [ -f /firstrun ]; then
        # remote syslog server to docker host
        SYSLOG=`netstat -rn|grep ^0.0.0.0|awk '{print $2}'`
        echo "*.* @$SYSLOG" >> /etc/rsyslog.conf

        # Start syslog server to see something
        # /usr/sbin/rsyslogd

        echo "Running for first time.. need to configure..."

        TIMEZONE="Americas/New_York"
        echo "${TIMEZONE}" > /etc/timezone
        chmod 666 /etc/timezone
        ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime

        # clean up
        rm /firstrun
fi

# Sometimes with un unclean exit the rsyslog pid doesn't get removed and refuses to start
if [ -f /var/run/rsyslogd.pid ]; then
        rm /var/run/rsyslogd.pid
fi

# Start supervisor to start the services
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf -l /var/log/supervisor.log -j /var/run/supervisord.pid

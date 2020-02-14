#!/bin/bash
sed -i "s/host_name.*/host_name $(hostname)/g" /usr/local/nagios/etc/objects/localhost.cfgsed -i "s/host_name.*/host_name $(hostname)/g" /usr/local/nagios/etc/objects/localhost.cfg  
/etc/rc.d/init.d/nagios start
/usr/sbin/httpd -k start
tail -f /var/log/httpd/access_log /var/log/httpd/error_log

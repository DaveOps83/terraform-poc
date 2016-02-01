#!/bin/bash
yum -y update
yum -y install nginx
mv /etc/nginx/nginx.conf /etc/nginx/nginx.conf.install
cat <<NGINX_CONF > /etc/nginx/nginx.conf
user  nginx;
worker_processes  auto;
error_log  /var/log/nginx/error.log;
pid        /var/run/nginx.pid;
events {
    worker_connections 1024;
}
http {
    include         /etc/nginx/mime.types;
    default_type    application/octet-stream;
    access_log  /var/log/nginx/access.log combined;
    error_log  /var/log/nginx/error.log error;
    server {
        listen 80;
        location ~ ^/DataAccessServices/OracleDataService.svc {
            proxy_pass https://${dc_dns};
        }
    }
}
NGINX_CONF
service nginx start
chkconfig nginx on
yum install -y awslogs
mv /etc/awslogs/awslogs.conf /etc/awslogs/awslogs.conf.install
cat <<AWSLOGS_CONF > /etc/awslogs/awslogs.conf
[general]
state_file = /var/lib/awslogs/agent-state

[nginx_access_log]
datetime_format = %b %d %H:%M:%S
file = /var/log/nginx/access.*
log_stream_name = ${log_stream_name}
log_group_name = ${log_group_name}

[nginx_error_log]
datetime_format = %b %d %H:%M:%S
file = /var/log/nginx/error.*
log_stream_name = ${log_stream_name}
log_group_name = ${log_group_name}
AWSLOGS_CONF
service awslogs start
sudo chkconfig awslogs on
yum install -y keepalived

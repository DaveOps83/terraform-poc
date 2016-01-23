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
        location / {
            proxy_pass https://${dc_dns};
        }
    }
}
NGINX_CONF
service nginx start

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

[messages]
datetime_format = %b %d %H:%M:%S
file = /var/log/messages
log_stream_name = ${log_stream_name}-messages
log_group_name = ${log_group_name}

[cloud_init_output_log]
datetime_format = %b %d %H:%M:%S
file = /var/log/cloud-init-output.log
log_stream_name = ${log_stream_name}-cloud-init-output-log
log_group_name = ${log_group_name}

[bootstrap_tests_log]
datetime_format = %b %d %H:%M:%S
file = /var/log/bootstrap-tests.log
log_stream_name = ${log_stream_name}-bootstrap-tests-log
log_group_name = ${log_group_name}

[nginx_access_log]
datetime_format = %b %d %H:%M:%S
file = /var/log/nginx/access.log
log_stream_name = ${log_stream_name}-nginx-access-log
log_group_name = ${log_group_name}

[nginx_error_log]
datetime_format = %b %d %H:%M:%S
file = /var/log/nginx/error.log
log_stream_name = ${log_stream_name}-nginx-error-log
log_group_name = ${log_group_name}
AWSLOGS_CONF
cat <<AWSCLI_CONF > /etc/awslogs/awscli.conf
[plugins]
cwlogs = cwlogs
[default]
region = ${log_region}
AWSCLI_CONF
service awslogs start
chkconfig awslogs on
yum install -y keepalived
cat <<KEEPALIVED_CONF > /etc/keepalived/keepalived.conf
vrrp_script chk_nginx {
  script "pidof nginx"
  interval 2
}
vrrp_instance das_cluster {
  virtual_router_id 2
  interface eth0
  state MASTER
  priority 200
}
KEEPALIVED_CONF
service keepalived start
chkconfig keepalived on

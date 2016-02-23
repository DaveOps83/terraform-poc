#!/bin/bash
yum -y update
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

[cloud-init-output]
datetime_format = %b %d %H:%M:%S
file = /var/log/cloud-init-output.log
log_stream_name = ${log_stream_name}-cloud-init-output
log_group_name = ${log_group_name}
AWSLOGS_CONF
service awslogs start
chkconfig awslogs on

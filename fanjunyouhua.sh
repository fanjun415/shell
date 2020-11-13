#!/bin/sh
# 内核参数调优
grep -q "vm.swappiness" /etc/sysctl.conf || cat >> /etc/sysctl.conf << EOF
########################################
vm.swappiness = 0
net.core.rmem_default = 262144
net.core.rmem_max = 16777216
net.core.wmem_default = 262144
net.core.wmem_max = 16777216
net.core.somaxconn = 262144
net.core.netdev_max_backlog = 262144
net.ipv4.tcp_max_orphans = 262144
net.ipv4.tcp_max_syn_backlog = 262144
net.ipv4.tcp_max_tw_buckets = 10000
net.ipv4.ip_local_port_range = 1024 65500
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.tcp_mem = 786432 1048576 1572864
fs.aio-max-nr = 1048576
fs.file-max = 6815744
kernel.sem = 250 32000 100 128
fs.inotify.max_user_watches = 1048576
EOF
sysctl -p

grep -q "* - nofile" /etc/security/limits.conf || cat >> /etc/security/limits.conf << EOF
########################################
* - nofile 1048576
* - nproc  65536
* - stack  1024
EOF

grep -q "ulimit -n" /etc/profile || cat >> /etc/profile << EOF
########################################
ulimit -n 1048576
ulimit -u 65536
ulimit -s 1024

alias grep='grep --color=auto'
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "
EOF


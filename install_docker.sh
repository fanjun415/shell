#!/bin/bash
set -ex
#1、上传安装包到/opt目录


#2、解压安装包
cd /opt
tar zxvf docker-19.03.3.tgz

#3、拷贝安装程序到安装目录
cp /opt/docker/*  /usr/bin/

#4、创建容器管理进程
mkdir /etc/containerd

containerd config default > /etc/containerd/config.toml

touch /usr/lib/systemd/system/containerd.service

cd /usr/lib/systemd/system

cat>containerd.service<<EOF
##添加以下内容
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/usr/bin/containerd  # 这是你 containerd  文件的放置路径
Delegate=yes
KillMode=process
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable containerd.service
systemctl start containerd.service
systemctl status containerd.service

groupadd docker
touch /usr/lib/systemd/system/docker.socket
cd /usr/lib/systemd/system

cat>docker.socket<<EOF
#docker.socket 文件内容如下：
[Unit]
Description=Docker Socket for the API
PartOf=docker.service

[Socket]
ListenStream=/var/run/docker.sock
SocketMode=0660
SocketUser=root
# 如果出现错误：chown socket at step GROUP: No such process, 可以修改下面的 SocketGroup=root 或创建 docker 用户组（命令 groupadd docker）
SocketGroup=docker

[Install]
WantedBy=sockets.target
EOF

systemctl daemon-reload
systemctl enable containerd.service
systemctl start containerd.service
systemctl status containerd.service

systemctl unmask docker.service
systemctl unmask docker.socket

touch /usr/lib/systemd/system/docker.service
cat>/usr/lib/systemd/system/docker.service<<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
BindsTo=containerd.service
After=network-online.target firewalld.service containerd.service
Wants=network-online.target
Requires=docker.socket

[Service]
Type=notify
# the default is not to use systemd for cgroups because the delegate issues still
# exists and systemd currently does not support the cgroup feature set required
# for containers run by docker
ExecStart=/usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock 
ExecReload=/bin/kill -s HUP $MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

# Note that StartLimit* options were moved from "Service" to "Unit" in systemd 229.
# Both the old, and new location are accepted by systemd 229 and up, so using the old location
# to make them work for either version of systemd.
StartLimitBurst=3

# Note that StartLimitInterval was renamed to StartLimitIntervalSec in systemd 230.
# Both the old, and new name are accepted by systemd 230 and up, so using the old name to make
# this option work for either version of systemd.
StartLimitInterval=60s

# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNOFILE=infinity
LimitNPROC=infinity
LimitCORE=infinity

# Comment TasksMax if your systemd version does not support it.
# Only systemd 226 and above support this option.
TasksMax=infinity

# set delegate yes so that systemd does not reset the cgroups of docker containers
Delegate=yes

# kill only the docker process, not all processes in the cgroup
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

chmod +x /usr/lib/systemd/system/docker.service
systemctl daemon-reload
systemctl enable docker
systemctl start docker

mv /opt/docker-compose-Linux-x86_64 /usr/local/bin/docker-compose
cd /usr/local/bin
chmod +x /usr/local/bin/docker-compose

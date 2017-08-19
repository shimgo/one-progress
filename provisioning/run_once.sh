#!/bin/bash

echo "SELinuxをpermissiveに設定"
setenforce 0

echo "firewalldを起動"
systemctl start firewalld.service

echo "firewalldからsshサービスを削除"
firewall-cmd --permanent --zone=public --remove-service=ssh

echo "firewalldに$1/tcpポートを追加"
firewall-cmd --permanent --zone=public --add-port=$1/tcp

echo "sshdのポートを変更"
sed -i "s/^#.*Port 22/Port $1/g" /etc/ssh/sshd_config 

echo "sshdを再起動"
systemctl restart sshd.service

echo 'SELinuxで新しいsshポートを許可'
semanage port -a -t ssh_port_t -p tcp $1

echo "SELinuxをenforceに設定"
setenforce 1

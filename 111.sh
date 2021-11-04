#!/bin/bash
yum install epel-release -y
yum update -y
yum install curl tar nginx -y
firewall-cmd --zone=public --add-port=80/tcp --permanent > /dev/null 2>&1
firewall-cmd --zone=public --add-port=443/tcp --permanent > /dev/null 2>&1
firewall-cmd --reload > /dev/null 2>&1
systemctl restart nginx
systemctl start nginx
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
export MSID="$(cat /proc/sys/kernel/random/uuid)"
export WEBS="$(date +web%dck%M%S)"
export VMTCP="$(date +vme%ds%Hs%S)"
export VMWS="$(date +vm%Sw%M%Hs)"
bash <(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/281677160/agent/main/config.sh)

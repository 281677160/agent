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
bash <(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/config.sh)
curl https://get.acme.sh | sh |tee build.log
if [[ `grep "Install success!" build.log` ]]; then
	echo "yes"
else
	echo "acme.sh下载错误"
	exit 1
fi
~/.acme.sh/acme.sh --register-account -m xxxx@xxxx.com |tee build.log
if [[ `grep "ACCOUNT_THUMBPRINT" build.log` ]]; then
	echo "yes"
else
	echo "acme.sh运行错误"
	exit 1
fi
~/.acme.sh/acme.sh  --issue  -d 1.bozai.us  --webroot /usr/share/nginx/html/ |tee build.log
if [[ `grep "private.key" build.log` ]] && [[ `grep "cert.crt" build.log` ]]; then
	echo "yes"
else
	echo "申请证书失败"
	exit 1
fi
mkdir /usr/local/etc/xray/cert
~/.acme.sh/acme.sh --installcert -d 1.bozai.us --key-file /usr/local/etc/xray/cert/private.key --fullchain-file /usr/local/etc/xray/cert/cert.crt |tee build.log
if [[ `grep "cert/private.key" build.log` ]] && [[ `grep "cert/cert.crt" build.log` ]]; then
	echo "yes"
else
	echo "证书存放失败"
	exit 1
fi
~/.acme.sh/acme.sh --upgrade --auto-upgrade |tee build.log
if [[ `grep "Upgrade success!" build.log` ]]; then
	echo "yes"
else
	echo "acme.sh更新失败"
	exit 1
fi
chmod -R 755 /usr/local/etc/xray/cer
systemctl enable nginx |tee build.log
if [[ `grep "nginx.service" build.log` ]]; then
	echo "yes"
else
	echo "nginx设置开启启动失败"
	exit 1
fi
systemctl restart nginx
rm -rf /usr/share/nginx/html/*
cd /usr/share/nginx/html/
wget https://github.com/V2RaySSR/Trojan/raw/master/web.zip
unzip web.zip
systemctl restart nginx

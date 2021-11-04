#!/bin/bash

if [[ ! "$USER" == "root" ]]; then
	clear
	echo
	echo -e "\033[31m 警告：请使用root用户操作!~~ \033[0m"
	echo
	sleep 2
	exit 1
fi
clear
echo
echo -e "\033[33m 请输入您的域名[比如：wy.v2ray.com] \033[0m"
read -p " 请输入您的域名：" wzym
export wzym="${wzym}"
echo -e "\033[32m 您的域名为：${wzym} \033[0m"
echo
if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
	yum install epel-release wget -y
	yum update -y
	yum install curl tar nginx -y
	firewall-cmd --zone=public --add-port=80/tcp --permanent > /dev/null 2>&1
	firewall-cmd --zone=public --add-port=443/tcp --permanent > /dev/null 2>&1
	firewall-cmd --reload > /dev/null 2>&1
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
	apt-get update && apt-get install -y wget git socat sudo ca-certificates && update-ca-certificates
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
	apt-get update && apt-get install -y wget git socat sudo ca-certificates && update-ca-certificates
	export AZML="sudo apt install"
else
	echo -e "\033[31m 不支持该系统 \033[0m"
	exit 1
fi
systemctl restart nginx
systemctl start nginx
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
export MSID="$(cat /proc/sys/kernel/random/uuid)"
export WEBS="$(date +web%dck%M%S)"
export VMTCP="$(date +vme%ds%Hs%S)"
export VMWS="$(date +vm%Sw%M%Hs)"
bash <(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/config.sh)
chmod +x /usr/local/etc/xray/config.json
YUMING="$(ping cs.danshui.online -c 5 | egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" |awk 'NR==1')"
getIpAddress=$(curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress)
if [[ ! ${YUMING} == ${getIpAddress} ]]; then
	echo "域名解析IP跟本机不一致"
	exit 1
fi
rm -fr ~/.acme.sh
curl https://get.acme.sh | sh |tee build.log
if [[ `grep "Install success!" build.log` ]]; then
	echo "yes"
else
	echo "acme.sh下载错误"
	exit 1
fi
~/.acme.sh/acme.sh --upgrade
~/.acme.sh/acme.sh --register-account -m xxxx@xxxx.com |tee build.log
if [[ `grep "ACCOUNT_THUMBPRINT" build.log` ]]; then
	echo "yes"
else
	echo "acme.sh运行错误"
	exit 1
fi
~/.acme.sh/acme.sh  --issue  -d ${wzym}  --webroot /usr/share/nginx/html/ |tee build.log
if [[ `grep "END CERTIFICATE" build.log` ]] && [[ `grep "Your cert key is in" build.log` ]]; then
	echo "yes"
else
	echo "申请证书失败"
	exit 1
fi
mkdir -p /usr/local/etc/xray/cert
~/.acme.sh/acme.sh --installcert -d ${wzym} --key-file /usr/local/etc/xray/cert/private.key --fullchain-file /usr/local/etc/xray/cert/cert.crt |tee build.log
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
chmod 775 /usr/local/etc/xray/cert/cert.crt
chmod 775 /usr/local/etc/xray/cert/private.key
systemctl enable nginx
if [[ -e /usr/lib/systemd/system/nginx.service ]]; then
	echo "yes"
else
	echo "nginx设置开机启动失败"
	exit 1
fi
systemctl restart xray
rm -rf /usr/share/nginx/html/*
cd /usr/share/nginx/html/
wget https://github.com/V2RaySSR/Trojan/raw/master/web.zip
unzip web.zip
cd /root
systemctl restart nginx
if [[ `systemctl status xray |grep -c "active (running) "` == '1' ]]; then
	echo "xray运行正常"
	echo "安装结束"
else
	echo "xray没有运行"
	exit 1
fi
exit 0

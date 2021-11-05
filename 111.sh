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
echo -e "\033[32m 欢迎使用全世界最辣鸡的一键安装Xray脚本 \033[0m"
echo
echo
echo -e "\033[33m 请输入您的域名[比如：v2.xray.com] \033[0m"
read -p " 请输入您的域名：" wzym
export wzym="${$wzym}"
echo
echo -e "\033[33m 请输入端口号(默认：443) \033[0m"
read -p " 请输入 1-65535 之间的值：" PORT
export PORT=${PORT:-"443"}
echo
echo
echo -e "\033[32m 您的域名为：${wzym} \033[0m"
echo -e "\033[32m 您的端口为：${PORT} \033[0m"
read -p " [检测是否正确,正确回车继续,不正确按Q回车重新输入]： " NNKC
case $NNKC in
		[Qq])
		bash <(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/111.sh)
		exit 1
	;;
	*)
		echo -e "\033[33m 开始安装Xray,请耐心等候... \033[0m"
	;;
esac
echo
rm -rf /etc/nginx
rm -rf /usr/sbin/nginx
rm /usr/share/man/man1/nginx.1.gz > /dev/null 2>&1
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
rm -rf /usr/local/share/xray
if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
	yum remove -y nginx
	yum install epel-release wget unzip -y
	yum update -y
	yum install git tar nginx -y
	firewall-cmd --zone=public --add-port=80/tcp --permanent > /dev/null 2>&1
	firewall-cmd --zone=public --add-port=443/tcp --permanent > /dev/null 2>&1
	firewall-cmd --reload > /dev/null 2>&1
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
	apt-get remove -y nginx
	apt-get update && apt-get install -y wget git unzip socat sudo ca-certificates && update-ca-certificates
	apt-get install tar nginx -y
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
	apt-get remove -y nginx
	apt-get update && apt-get install -y wget git unzip socat sudo ca-certificates && update-ca-certificates
	apt-get install tar nginx -y
else
	echo -e "\033[31m 不支持该系统 \033[0m"
	exit 1
fi
systemctl stop firewalld
systemctl disable firewalld
systemctl stop nftables
systemctl disable nftables
systemctl stop ufw
systemctl disable ufw
systemctl restart nginx
sleep 3
systemctl start nginx
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
if [[ $? -ne 0 ]];then
	echo -e "\033[31m xray源码安装失败 \033[0m"
	exit 1
else
	echo "yes"
fi
export MSID="$(cat /proc/sys/kernel/random/uuid)"
export WEBS="$(date +ket%dck%M%S)"
export VMTCP="$(date +vmtcp%ds%Hs%S)"
export VMWS="$(date +vmws%Sw%M%Hs)"
bash <(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/config.sh)
chmod +x /usr/local/etc/xray/config.json
export YUMING="$(ping cs.danshui.online -c 5 | egrep -o "[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+" |awk 'NR==1')"
export getIpAddress=$(curl -sS --connect-timeout 10 -m 60 https://www.bt.cn/Api/getIpAddress)
if [[ ! ${YUMING} == ${getIpAddress} ]]; then
	echo
	echo -e "\033[31m 域名解析IP跟本机不一致 \033[0m"
	echo
	echo -e "\033[32m 域名解析IP为：${YUMING} \033[0m"
	echo
	echo -e "\033[32m 本机IP为：${getIpAddress} \033[0m"
	exit 1
else
	echo "yes"
fi
rm -fr /root/acme.sh
curl https://get.acme.sh | sh |tee build.log
if [[ `grep "Install success!" build.log` ]]; then
	echo "yes"
else
	echo -e "\033[31m acme.sh下载失败 \033[0m"
	exit 1
fi
~/.acme.sh/acme.sh --upgrade
~/.acme.sh/acme.sh --register-account -m xxxx@xxxx.com |tee build.log
if [[ `grep "ACCOUNT_THUMBPRINT" build.log` ]]; then
	echo "yes"
else
	echo -e "\033[31m acme.sh运行错误 \033[0m"
	exit 1
fi
~/.acme.sh/acme.sh  --issue  -d ${wzym}  --webroot /usr/share/nginx/html/ |tee build.log
if [[ `grep "END CERTIFICATE" build.log` ]] && [[ `grep "Your cert key is in" build.log` ]]; then
	echo "yes"
else
	echo -e "\033[31m 申请证书失败 \033[0m"
	exit 1
fi
mkdir -p /usr/local/etc/xray/cert
~/.acme.sh/acme.sh --installcert -d ${wzym} --key-file /usr/local/etc/xray/cert/private.key --fullchain-file /usr/local/etc/xray/cert/cert.crt |tee build.log
if [[ `grep "cert/private.key" build.log` ]] && [[ `grep "cert/cert.crt" build.log` ]]; then
	echo "yes"
else
	echo -e "\033[31m 证书存放失败 \033[0m"
	exit 1
fi
~/.acme.sh/acme.sh --upgrade --auto-upgrade |tee build.log
if [[ `grep "Upgrade success!" build.log` ]]; then
	echo "yes"
else
	echo -e "\033[31m 设置acme.sh自动更新失败 \033[0m"
	exit 1
fi
rm -fr build.log
chmod 775 /usr/local/etc/xray/cert/cert.crt
chmod 775 /usr/local/etc/xray/cert/private.key
systemctl enable nginx
if [[ -e /usr/lib/systemd/system/nginx.service ]]; then
	echo "yes"
else
	echo -e "\033[31m nginx设置开机启动失败 \033[0m"
	exit 1
fi
systemctl restart xray
sleep 3
systemctl start xray
rm -rf /usr/share/nginx/html/*
cd /usr/share/nginx/html/
wget https://github.com/V2RaySSR/Trojan/raw/master/web.zip
unzip web.zip
cd /root
systemctl restart nginx
sleep 3
systemctl start nginx
if [[ `systemctl status xray |grep -c "active (running) "` == '1' ]]; then
	echo -e "\033[33m xray运行正常 \033[0m"
	XRAYYX="YES"
else
	echo "xray没有运行"
	exit 1
fi
if [[ `ps -ef |grep nginx` ]]; then
	echo -e "\033[33m nginx运行正常 \033[0m"
	NGINXYX="YES"
else
	echo "nginx没有运行"
	exit 1
fi
curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/xray/pzcon.sh > /root/pzcon.sh
if [[ ${XRAYYX} == "YES" ]] && [[ ${NGINXYX} == "YES" ]]; then
	source /root/pzcon.sh
	sleep 2
	source /usr/local/etc/xray/pzcon
fi
rm -fr /root/pzcon.sh
exit 0

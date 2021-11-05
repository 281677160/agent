
#!/bin/bash

if [[ ! "$USER" == "root" ]]; then
	clear
	echo
	echo -e "\033[31m 警告：请使用root用户操作!~~ \033[0m"
	echo
	sleep 2
	exit 1
fi
if [[ -e /usr/local/etc/xray/pzcon ]] && [[ -e /usr/local/etc/xray/cert/private.key ]]; then
	clear
	echo
	echo -e "\033[32m 1. 查看节点配置信息 \033[0m"
	echo
	echo -e "\033[32m 2. 御载本脚本安装的xray和nginx \033[0m"
	echo
	echo -e "\033[32m 3. 退出程序 \033[0m"
	echo
	while :; do
	echo -e "\033[36m 请输入[ 1、2、3 ]然后回车确认您的选择！ \033[0m"
	read -p " 输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			source /usr/local/etc/xray/pzcon
			sleep 2
			exit 0
		break
		;;
		2)
			systemctl stop nginx
			systemctl stop xray
			if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
				yum remove -y nginx
			elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
				sudo apt-get --purge remove nginx
				sudo apt-get autoremove
				sudo apt-get --purge remove nginx
				sudo apt-get --purge remove nginx-common
				sudo apt-get --purge remove nginx-core
			elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
				sudo apt-get --purge remove nginx
				sudo apt-get autoremove
				sudo apt-get --purge remove nginx
				sudo apt-get --purge remove nginx-common
				sudo apt-get --purge remove nginx-core
			fi
			rm -rf /etc/nginx
			rm -rf /usr/sbin/nginx
			rm -rf /usr/share/nginx
			rm -rf /usr/lib/python3/dist-packages/sos/report/plugins/__pycache__/nginx.cpython-38.pyc
			rm -rf /usr/lib/python3/dist-packages/sos/report/plugins/nginx.py
			rm -rf /var/cache/apt/archives/nginx-common_1.18.0-0ubuntu1.2_all.deb
			rm -rf /var/cache/apt/archives/nginx-core_1.18.0-0ubuntu1.2_amd64.deb
			rm -rf /var/cache/apt/archives/nginx_1.18.0-0ubuntu1.2_all.deb
			rm /usr/share/man/man1/nginx.1.gz > /dev/null 2>&1
			bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
			rm -rf /usr/local/bin/xray
			rm -rf /usr/local/share/xray
			rm -rf /usr/local/etc/xray
			rm -rf /var/log/xray/
			rm -rf /etc/systemd/system/xray.service
			rm -rf /etc/systemd/system/xray@.service
			rm -fr /root/.acme.sh
			sleep 2
			exit 1
		break
		;;
		3)
			sleep 2
			exit 1
		break
    		;;
    		*)
			echo -e "\033[35m 警告：输入错误,请输入正确的编号! \033[0m"
		;;
	esac
	done
else
	clear
	echo
	echo -e "\033[32m 1. 安装Xray和nginx \033[0m"
	echo
	echo -e "\033[32m 2. 退出程序 \033[0m"
	echo
	while :; do
	echo -e "\033[36m 请输入[ 1、2 ]然后回车确认您的选择！ \033[0m"
	read -p " 输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			echo
		break
		;;
		2)
			sleep 2
			exit 1
		break
    		;;
    		*)
			echo -e "\033[35m 警告：输入错误,请输入正确的编号! \033[0m"
		;;
	esac
	done
fi
echo
echo -e "\033[33m 请输入您的域名[比如：v2.xray.com] \033[0m"
read -p " 请输入您的域名：" wzym
export wzym="${wzym}"
echo
echo -e "\033[33m 请输入端口号(建议直接回车使用默认：443) \033[0m"
read -p " 请输入 1-65535 之间的值：" PORT
export PORT=${PORT:-"443"}
echo
echo
echo -e "\033[32m 您的域名为：${wzym} \033[0m"
echo -e "\033[32m 您的端口为：${PORT} \033[0m"
read -p " [检查是否正确,正确回车继续,不正确按Q回车重新输入]： " NNKC
case $NNKC in
		[Qq])
		bash <(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/xray_install.sh)
		exit 1
	;;
	*)
		echo -e "\033[33m 开始安装Xray,请耐心等候... \033[0m"
	;;
esac
echo
if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
	yum remove nginx -y
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
	apt purge nginx -y
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
	apt purge nginx -y
fi
rm -rf /etc/nginx
rm -rf /usr/sbin/nginx
rm -rf /usr/share/nginx
rm /usr/share/man/man1/nginx.1.gz > /dev/null 2>&1
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ remove --purge
rm -rf /usr/local/bin/xray
rm -rf /usr/local/share/xray
rm -rf /usr/local/etc/xray
rm -rf /var/log/xray/
rm -rf /etc/systemd/system/xray.service
rm -rf /etc/systemd/system/xray@.service
rm -fr /root/.acme.sh
osPort80=`netstat -tlpn | awk -F '[: ]+' '$1=="tcp"{print $5}' | grep -w 80`
osPort443=`netstat -tlpn | awk -F '[: ]+' '$1=="tcp"{print $5}' | grep -w 443`
if [[ -n "$osPort80" ]]; then
	process80=`netstat -tlpn | awk -F '[: ]+' '$5=="80"{print $9}'`
	echo -e "\033[35m 检测到80端口被占用，占用进程为：${process80}，本次安装结束 \033[0m"
	exit 1
fi
if [[ -n "$osPort443" ]]; then
	process443=`netstat -tlpn | awk -F '[: ]+' '$5=="443"{print $9}'`
	echo -e "\033[35m 检测到443端口被占用，占用进程为：${process443} \033[0m"
fi
osSELINUXCheck=$(grep SELINUX= /etc/selinux/config | grep -v "#")
if [[ "$osSELINUXCheck" == "SELINUX=enforcing" ]]; then
	echo -e "\033[35m 检测到SELinux为开启强制模式状态，为防止申请证书失败，请先重启VPS后，再执行本脚本 \033[0m"
	exit 1
fi
if [[ "$osSELINUXCheck" == "SELINUX=permissive" ]]; then
	echo -e "\033[35m 检测到SELinux为宽容模式状态，为防止申请证书失败，请先重启VPS后，再执行本脚本 \033[0m"
	exit 1
fi
if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
	yum remove nginx -y
	yum install epel-release wget unzip net-tools socat git tar -y
	yum update -y
	yum install nginx -y
	firewall-cmd --zone=public --add-port=80/tcp --permanent > /dev/null 2>&1
	firewall-cmd --zone=public --add-port=443/tcp --permanent > /dev/null 2>&1
	firewall-cmd --reload > /dev/null 2>&1
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
	apt purge nginx -y
	apt-get update && apt-get install -y wget git unzip net-tools socat sudo tar ca-certificates && update-ca-certificates
	apt-get install nginx -y
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
	apt purge nginx -y
	apt-get update && apt-get install -y wget git unzip net-tools socat tar sudo ca-certificates && update-ca-certificates
	apt-get install nginx -y
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
if [[ `ps -ef |grep nginx` ]]; then
	echo
else
	echo "nginx没有运行"
	exit 1
fi
mkdir /usr/local/bin >/dev/null 2>&1
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u root
export HOME="$PWD"
export WebSite="/usr/share/nginx/html/"
export MSID="$(cat /proc/sys/kernel/random/uuid)"
export WEBS="$(date +VLEws%d%M%S)"
export VMTCP="$(date +VME%S%d%H)"
export VMWS="$(date +VMEws%M%S%H)"
bash <(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/xray/config.sh)
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
curl https://get.acme.sh | sh |tee build.log
if [[ `grep "Install success!" build.log` ]]; then
	echo "yes"
else
	echo -e "\033[31m acme.sh下载失败 \033[0m"
	exit 1
fi
"$HOME"/.acme.sh/acme.sh --upgrade
"$HOME"/.acme.sh/acme.sh --register-account -m xxxx@xxxx.com |tee build.log
if [[ `grep "ACCOUNT_THUMBPRINT" build.log` ]]; then
	echo "yes"
else
	echo -e "\033[31m acme.sh运行错误 \033[0m"
	exit 1
fi
"$HOME"/.acme.sh/acme.sh --issue -d "${wzym}" --webroot "${WebSite}" -k ec-256 --force |tee build.log
if [[ `grep "END CERTIFICATE" build.log` ]] && [[ `grep "Your cert key is in" build.log` ]]; then
	echo "yes"
else
	echo -e "\033[31m 申请证书失败 \033[0m"
	exit 1
fi
mkdir -p /usr/local/etc/xray/cert
"$HOME"/.acme.sh/acme.sh --installcert -d "${wzym}" --fullchainpath /usr/local/etc/xray/cert/cert.crt --keypath /usr/local/etc/xray/cert/private.key --reloadcmd "systemctl restart xray" --ecc --force
if [[ -e /usr/local/etc/xray/cert/private.key ]] && [[ -e /usr/local/etc/xray/cert/cert.crt ]]; then
	echo "yes"
	chmod 775 /usr/local/etc/xray/cert/cert.crt
	chmod 775 /usr/local/etc/xray/cert/private.key
else
	echo -e "\033[31m 证书存放失败 \033[0m"
	exit 1
fi
"$HOME"/.acme.sh/acme.sh --upgrade --auto-upgrade |tee build.log
if [[ `grep "Upgrade success!" build.log` ]]; then
	echo "yes"
else
	echo -e "\033[31m 设置acme.sh自动更新失败 \033[0m"
	exit 1
fi
sed -i '/^\*\ *soft\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
sed -i '/^\*\ *hard\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
echo '* soft nofile 65536' >>/etc/security/limits.conf
echo '* hard nofile 65536' >>/etc/security/limits.conf

if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
   sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
   setenforce 0
fi
rm -fr build.log
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
	clear
	echo
	echo
	source /usr/local/etc/xray/pzcon
fi
rm -fr /root/pzcon.sh
exit 0

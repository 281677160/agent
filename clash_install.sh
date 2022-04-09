#!/bin/bash

clear
echo
echo -e "\033[33m 请输入您的前端网页域名[比如：wy.v2ray.com] \033[0m"
read -p " 请输入您的前端网页域名：" wzym
export wzym="${wzym}"
echo -e "\033[32m 您的前端网页域名为：${wzym} \033[0m"
echo


if [[ ! "$USER" == "root" ]]; then
	clear
	echo
	echo -e "\033[31m 警告：请使用root用户操作!~~ \033[0m"
	echo
	sleep 2
	exit 1
fi
if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
	curl -sL https://rpm.nodesource.com/setup_12.x | bash -
	yum install -y nodejs wget sudo nginx git npm
	npm install -g yarn
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
	apt-get update
	apt install -y curl wget sudo nginx git
	apt-get remove -y --purge npm
	apt-get remove -y --purge nodejs
	apt-get remove -y --purge nodejs-legacy
	apt-get autoremove -y
	curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
	apt-get install -y nodejs
	apt remove -y cmdtest
	apt remove -y yarn
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	apt-get update && apt-get install -y yarn
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
	apt update
	apt install -y curl wget sudo nginx git
	apt remove -y --purge npm
	apt remove -y --purge nodejs
	apt remove -y --purge nodejs-legacy
	apt autoremove -y
	curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
	apt install -y nodejs
	apt remove -y cmdtest
	apt remove -y yarn
	curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
	echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
	apt-get update && apt-get install -y yarn
else
	echo -e "\033[31m 不支持该系统 \033[0m"
	exit 1
fi

if [[ `node --version |egrep -o "v[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
	echo ""
else
	echo -e "\033[31m node安装失败! \033[0m"
  exit 1
fi
if [[ `yarn --version |egrep -o "[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
	echo ""
else
	echo -e "\033[31m yarn安装失败! \033[0m"
  exit 1
fi


cat >/etc/nginx/sites-available/default <<-EOF
server {
listen 80;

server_name localhost;

root /var/www/html/;
index index.html;

location / {
    try_files $uri $uri/ =404;
}
}
EOF

systemctl restart nginx

rm -fr sub-web && git clone https://github.com/CareyWang/sub-web.git
if [[ $? -ne 0 ]];then
	echo -e "\033[31m sub-web下载失败! \033[0m"
	exit 1
else
	cd sub-web
	sed -i "s?https://suo.yt?http://${wzym}:25500?g" "/root/sub-web/.env"
	sed -i "s?http://127.0.0.1:25500/sub?http://${wzym}:25500?g" "/root/sub-web/src/views/Subconverter.vue"
	yarn install
	yarn build
	rm -rf /var/www/html/*
	cp -R /root/sub-web/dist/* /var/www/html/
fi
cd /root
wget https://github.com/tindy2013/subconverter/releases/download/v0.7.2/subconverter_linux64.tar.gz
tar -zxvf subconverter_linux64.tar.gz
sed -i "s?listen = "0.0.0.0"?listen = "127.0.0.1"?g" "/root/subconverter/pref.toml"
sed -i "s?listen = "0.0.0.0"?listen = "127.0.0.1"?g" "/root/subconverter/pref.example.ini"
sed -i "s?http://127.0.0.1:25500/sub?http://${wzym}:25500?g" "/root/subconverter/pref.example.ini"

cat >/etc/systemd/system/sub.service <<-EOF
[Unit]
Description=A API For Subscription Convert
After=network.target
 
[Service]
Type=simple
ExecStart=/root/subconverter/subconverter
WorkingDirectory=/root/subconverter
Restart=always
RestartSec=10
 
[Install]
WantedBy=multi-user.target
EOF
chmod +x /etc/systemd/system/sub.service
systemctl daemon-reload
systemctl start sub
systemctl enable sub
systemctl status sub

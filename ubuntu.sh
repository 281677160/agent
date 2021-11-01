#!/bin/bash

echo
echo -e "\033[33m 请输入您的前端网页域名[比如：sub.v2rayssr.com] \033[0m"
read -p " 请输入您的前端网页域名：" wzym
export wzym=${wzym}
echo -e "\033[32m 您的前端网页域名为：${wzym} \033[0m"
echo
sleep 2
echo
echo -e "\033[33m 请输入您的后端服务器地址域名[比如：suc.v2rayssr.com] \033[0m"
read -p "请输入您的后端服务器地址域名：" fwym
export fwym=${fwym}
echo -e "\033[32m 您的后端服务器地址域名为：${fwym} \033[0m"
echo
sleep 20
cat >/root/sub_suc <<-EOF
wzym=${wzym}
fwym=${fwym}
EOF
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
if [[ `node --version |egrep -o "v[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
	echo ""
else
	echo "node安装失败!"
  exit 1
fi
if [[ `npm --version |egrep -o "[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
	echo ""
else
	echo "npm安装失败!"
  exit 1
fi
npm install -g yarn
if [[ `yarn --version |egrep -o "[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
	echo ""
else
	echo "yarn安装失败!"
  exit 1
fi
rm -fr sub-web && git clone https://github.com/CareyWang/sub-web.git
if [[ $? -ne 0 ]];then
	echo "sub-web下载失败!"
	exit 1
else
	cd sub-web
	yarn install
	yarn serve
fi
exit 0

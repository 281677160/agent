#!/bin/bash
apt-get update
apt-get install -y curl wget sudo git
curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
sudo apt-get install -y nodejs
if [[ `node --version |egrep -o "v[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
	echo "node安装成功!"
else
	echo "node安装不成功!"
  exit 1
fi
if [[ `npm --version |egrep -o "[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
	echo "npm安装成功!"
else
	echo "npm安装不成功!"
  exit 1
fi
npm install -g yarn
if [[ `yarn --version |egrep -o "[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
	echo "yarn安装成功!"
else
	echo "yarn安装不成功!"
  exit 1
fi
rm -fr sub-web && git clone https://github.com/CareyWang/sub-web.git
if [[ $? -ne 0 ]];then
	echo "sub-web下载失败!"
	exit 1
else
	echo "sub-web下载成功!"
	cd sub-web
	yarn install
	yarn serve
fi

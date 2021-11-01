#!/bin/bash
yum update -y
yum install -y curl wget sudo git
curl -sL https://rpm.nodesource.com/setup_10.x | sudo bash -
sudo yum install -y nodejs
if [[ `node --version |egrep -o "v[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
  echo ""
else
	echo "node安装不成功!"
  exit 1
fi
if [[ `npm --version |egrep -o "[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
  echo ""
else
	echo "npm安装不成功!"
  exit 1
fi
npm install -g yarn
if [[ `yarn --version |egrep -o "[0-9]+\.[0-9]+\.[0-9]+"` ]]; then
  echo ""
else
	echo "yarn安装不成功!"
  exit 1
fi
git clone https://github.com/CareyWang/sub-web.git
if [[ $? -ne 0 ]];then
	echo "sub-web下载失败!"
else
  cd sub-web
  yarn install
  yarn serve
fi
cd ../
rm -fr /sub-web/src/views/Subconverter.vue
curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/Subconverter.vue /sub-web/src/views/Subconverter.vue
yarn build
yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh
#!/bin/bash
cd /root
rm -fr /root/sub-web/src/views/Subconverter.vue
curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/Subconverter.vue > /root/sub-web/src/views/Subconverter.vue
yarn build
wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh

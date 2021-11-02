#!/bin/bash
cd /root
source /root/sub_suc
rm -fr /root/sub-web/src/views/Subconverter.vue
curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/Subconverter.vue > /root/sub-web/src/views/Subconverter.vue
if [[ $? -ne 0 ]];then
  echo -e "\033[31m Subconverter.vue文件下载失败! \033[0m"
  exit 1
else
  sed -i "s/192.168.1.1/${fwym}/g" /root/sub-web/src/views/Subconverter.vue
fi
cd sub-web && yarn build
cd /root
echo
echo
echo -e "\033[32m 开始安装宝塔面板，看到提示按 N/Y 的按Y回车继续进行安装! \033[0m"
echo
echo
sleep 10
wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh
exit 0

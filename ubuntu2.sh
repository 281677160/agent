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
echo -e "\033[32m 开始安装宝塔面板，看到提示按 N/Y 的时候按 Y 回车继续进行安装! \033[0m"
echo
echo
sleep 10
if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
	yum install -y wget && wget -O install.sh http://download.bt.cn/install/install_6.0.sh && sh install.sh
elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
	wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh
elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
	wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && bash install.sh
else
	echo -e "\033[31m 不支持该系统 \033[0m"
	exit 1
fi
exit 0

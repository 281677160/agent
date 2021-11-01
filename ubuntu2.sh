#!/bin/bash
echo
echo
echo "请输入你后端的域名[比如：suc.v2rayssr.com]"
read -p " 请输入你后端的域名：" ip
export ip=${ip:-"$suc.danshui.online"}
echo "您的后台地址为：$ip"
echo
echo
cd /root
rm -fr /root/sub-web/src/views/Subconverter.vue
curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/Subconverter.vue > /root/sub-web/src/views/Subconverter.vue
if [[ $? -ne 0 ]];then
  echo "文件下载不成功"
  exit 1
else
  sed -i "s/192.168.1.1/${ip}/g" /root/sub-web/src/views/Subconverter.vue
fi
cd sub-web && yarn build
cd /root
echo
echo
echo "开始安装宝塔面板，看到提示按 N/Y 的按Y回车继续进行安装"
echo
echo
sleep 10
wget -O install.sh http://download.bt.cn/install/install-ubuntu_6.0.sh && sudo bash install.sh
exit 0

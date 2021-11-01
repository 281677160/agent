#!/bin/bash
ip="subqd.danshui.online"
rm  -rf /www/wwwroot/${ip} * !(.user.ini)
cp -RF /root/sub-web/dist/* /www/wwwroot/${ip}
cd /root
wget https://github.com/tindy2013/subconverter/releases/download/v0.6.3/subconverter_linux64.tar.gz
if [[ $? -ne 0 ]];then
  echo "文件下载失败"
else
  tar -zxvf subconverter_linux64.tar.gz
fi
Api="api_access_token\=$(date +e%Swoid%YiI6IC%dIyIiwK%HInBz%MIjogIjIzM3Y)"

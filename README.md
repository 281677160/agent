# v2-ssr
```yaml
支持ubunt18或以下系统，debian10或以下系统
sudo apt-get update && sudo apt install -y wget curl git git-core socat


支持CentOS7或者以下系统
yum apt-get update && sudo yum install -y wget curl git git-core socat
```
#
---
#
---
- SS+SSR一键搭建，后期管理再次输入命令
```yaml
wget -N --no-check-certificate https://raw.githubusercontent.com/shidahuilang/SS-SSR-TG-iptables-bt/main/sh/ssr.sh && chmod +x ssr.sh && bash ssr.sh
```
#
---
#
- TG代理一键搭建，出处：https://github.com/seriyps/mtproto_proxy
```yaml
curl -L -o mtp_install.sh https://git.io/fj5ru && bash mtp_install.sh
```
#
---
#
---
- TG代理一键搭建，后期管理再次输入命令
```yaml
wget -N --no-check-certificate https://raw.githubusercontent.com/shidahuilang/SS-SSR-TG-iptables-bt/main/sh/mtproxy.sh && chmod +x mtproxy.sh && bash mtproxy.sh
```
#
---
#
---
- SS一键搭建，后期管理再次输入命令
```yaml
wget -N --no-check-certificate https://raw.githubusercontent.com/shidahuilang/SS-SSR-TG-iptables-bt/main/sh/ss-go.sh && chmod +x ss-go.sh && bash ss-go.sh
```
#
---
#
---
- 八合一的一键搭建，需要域名，后期管理命令：vasma
```yaml
wget -P /root -N --no-check-certificate "https://raw.githubusercontent.com/mack-a/v2ray-agent/master/install.sh" && chmod 700 /root/install.sh && /root/install.sh
```
#
---
#
- 带网页版的xray教程链接：https://mgxray.xyz/index.php/archives/362/
```yaml
curl https://get.acme.sh | sh
~/.acme.sh/acme.sh --register-account -m xxxx@gmail.com
~/.acme.sh/acme.sh  --issue -d 你的域名   --standalone
~/.acme.sh/acme.sh --installcert -d 你的域名 --key-file /root/private.key --fullchain-file /root/cert.crt
bash <(curl -Ls https://raw.githubusercontent.com/vaxilu/x-ui/master/install.sh)

顺利安装完成后，用IP+54321 端口登录页面，修改好用户名、密码、面板监听端口、面板证书公钥文件路径、面板证书密钥文件路径

重启页面，然后就可以用你的域名+面板监听端口和你新设置的用户名跟密码登录页面了

```

#
---
- v2ray一键搭建，后期管理看下面的命令
```yaml
bash <(curl -s -L https://git.io/JzclH)
```
```yaml

快速管理

v2ray info 查看 V2Ray 配置信息

v2ray config 修改 V2Ray 配置

v2ray link 生成 V2Ray 配置文件链接

v2ray infolink 生成 V2Ray 配置信息链接

v2ray qr 生成 V2Ray 配置二维码链接

v2ray ss 修改 Shadowsocks 配置

v2ray ssinfo 查看 Shadowsocks 配置信息

v2ray ssqr 生成 Shadowsocks 配置二维码链接

v2ray status 查看 V2Ray 运行状态

v2ray start 启动 V2Ray

v2ray stop 停止 V2Ray

v2ray restart 重启 V2Ray

v2ray log 查看 V2Ray 运行日志

v2ray update 更新 V2Ray

v2ray update.sh 更新 V2Ray 管理脚本

v2ray uninstall 卸载 V2Ray

配置文件路径

V2Ray 配置文件路径：/etc/v2ray/config.json

Caddy 配置文件路径：/etc/caddy/Caddyfile

脚本配置文件路径: /etc/v2ray/233blog_v2ray_backup.conf
```
#
---
#
---
- 一键安装BBR，使用BBR+CAKE加速方案，后期管理再次输入命令
```yaml
wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
```
#
---
---
- 一键安装BBR2
```yaml
wget --no-check-certificate -q -O bbr2.sh "https://github.com/yeyingorg/bbr2.sh/raw/master/bbr2.sh" && chmod +x bbr2.sh && bash bbr2.sh auto
```
#
#
---
- 测试解锁流媒体情况，选择4测试
```yaml
bash <(curl -L -s https://raw.githubusercontent.com/lmc999/RegionRestrictionCheck/main/check.sh)
```
```yaml
https://www.vpscang.com/
```

- 一键DD服务器：https://hostloc.com/thread-779358-1-1.html

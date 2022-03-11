首先您要有一个外网的服务器，一般来说线路用香港、日本、新加坡的应该比较好

支持ubunt18或debian10以下系统，(用root用户登录，然后首先对你的系统使用以下命令)

apt-get update && apt-get install -y wget curl git socat sudo ca-certificates && update-ca-certificates
支持CentOS7或者以下系统，(用root用户登录，然后首先对你的系统使用以下命令)
yum install -y wget curl git socat ca-certificates && update-ca-trust force-enable

- xray代理安装,二选一即可
#
```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/xray_install.sh)"
```
```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/x-ui.sh)"
```
---
- TG代理安装,二选一即可
#
```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/erlang_tg.sh)"
```

```yaml
bash <(wget -qO- https://git.io/mtg.sh)
```
---
- BBR安装
#
```yaml
wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
```

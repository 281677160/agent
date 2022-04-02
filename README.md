

支持ubunt18、debian10以下、CentOS7-8系统，(用root用户登录，然后首先对你的系统使用以下命令)
```yaml
yum install -y curl || apt update && apt install -y curl
```
---
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

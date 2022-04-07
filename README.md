

- #### 谷歌云、甲骨云开启root用户SSH连接
#

- 第一步：进入服务器后,切换到root用户,下面命令一般都能切入root用户,如果不行请自行百度
```sh
su - root
```

- 第二步：把下面命令里的中文改成您要设置的服务器密码,然后执行命令
```sh
echo root:你想要设置的密码 |chpasswd root
```

- 第三步：防止服务器没curl，使用命令执行安装curl
```yaml
yum install -y curl || apt update && apt install -y curl
```

- 第四步：一键开启root用户SSH连接
```sh
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/281677160/pve/main/ssh.sh)"
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

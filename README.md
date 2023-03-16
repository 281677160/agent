
防止服务器没curl使用不了一键命令，进入root用户后，执行安装curl、wget命令（安装过后，只要没御载curl、wget或者重置过系统都不需要再次执行了）
```yaml
yum install -y curl wget || sudo apt update && sudo apt install -y curl wget
```

---
#
---

<details>
<summary>🔻谷歌云、甲骨云开启root用户SSH连接🔻</summary>
<br>

第一步：进入服务器后,切换到root用户,下面命令一般都能切入root用户,如果不行请自行百度
```sh
sudo -i   或者   sudo su
```

第二步：进入root用户后，把下面命令里的中文改成您要设置的服务器密码,然后执行命令
```sh
echo root:你想要设置的密码 |chpasswd root
```

第三步：一键开启root用户SSH连接
```sh
bash -c  "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/ssh.sh)"
```

<br />
</details>

---
#
---
<details>
<summary>🔻xray安装（支持的协议：vless、trojan、vmess）🔻</summary>
<br>

```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/xray_install.sh)"
```
<br />
</details>

---
#
---
<details>
<summary>🔻x-ui安装+伪装网站（支持：vmess、vless、trojan、shadowsocks、dokodemo-door、socks、http）🔻</summary>
<br>

```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/x-ui.sh)"
```
<br />
</details>


  
---
#
---
<details>
<summary>🔻TG代理安装🔻</summary>
<br>

TG代理安装,下面两个一键安装二选一即可
```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/erlang_tg.sh)"
```

```yaml
bash <(wget -qO- https://git.io/mtg.sh)
```
<br />
</details>

---
#
---
<details>
<summary>🔻一键搭建CLASH节点转换,无需域名无需证书,自己转换自己使用,支持本地虚拟机（ubuntu、debian、alpine）🔻</summary>
<br>

```yaml
bash -c "$(curl -fsSL https://ghproxy.com/https://raw.githubusercontent.com/281677160/agent/main/clash_install.sh)"
```
<br />
</details>

---
#
---
<details>
<summary>🔻一键搭建CLASH节点转换+短链接，需要域名，自动申请证书🔻</summary>
<br>

```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/clash_turn.sh)"
```
<br />
</details>

---
#
---

<details>
<summary>🔻一键BBR安装🔻</summary>
<br>

```yaml
bash -c "$(curl -fsSL https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh)"
```
<br />
</details>

---
#
---

<details>
<summary>🔻一键DD系统🔻</summary>
<br>


[一键更换系统](https://www.moeelf.com/archives/293.html)

<br />
</details>

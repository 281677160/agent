#!/bin/bash
cat >/usr/local/etc/xray/pzcon <<-EOF
#!/bin/bash
TIME() {
[[ -z "$1" ]] && {
	echo -ne " "
} || {
     case $1 in
	r) export Color="\e[31;1m";;
	g) export Color="\e[32;1m";;
	b) export Color="\e[34;1m";;
	y) export Color="\e[33;1m";;
	z) export Color="\e[35;1m";;
	l) export Color="\e[36;1m";;
      esac
	[[ $# -lt 2 ]] && echo -e "\e[36m\e[0m ${1}" || {
		echo -e "\e[36m\e[0m ${Color}${2}\e[0m"
	 }
      }
}
echo -e "\033[31m VLESS+TCP+XTLS \033[0m"
echo
TIME g "vless://${MSID}@${getIpAddress}:${PORT}?headerType=none&type=tcp&encryption=none&flow=xtls-rprx-direct&security=xtls&sni=${wzym}#VLESS+TCP+XTLS"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TCP+XTLS（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：V2Ray/XRay \033[0m"
echo -e "\033[33m 协议：V2Ray/XRay \033[0m"
echo -e "\033[33m 服务器地址：${getIpAddress} \033[0m"
echo -e "\033[33m 服务器端口：${PORT} \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${MSID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：勾选 \033[0m"
echo -e "\033[33m flow：xtls-rprx-direct \033[0m"
echo -e "\033[33m alpn：默认 \033[0m"
echo -e "\033[33m 域名：${wzym} \033[0m"
echo -e "\033[33m 传输协议：TCP \033[0m"
echo -e "\033[33m 伪装协议：未配置/none \033[0m"
echo
echo
echo
echo
echo -e "\033[31m VLESS+TPC+TLS \033[0m"
echo
TIME g "vless://${MSID}@${wzym}:${PORT}?headerType=none&type=tcp&encryption=none&security=tls&sni=${wzym}#VLESS+TPC+TLS"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TPC+TLS（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：V2Ray/XRay \033[0m"
echo -e "\033[33m 协议：V2Ray/XRay \033[0m"
echo -e "\033[33m 服务器地址：${wzym} \033[0m"
echo -e "\033[33m 服务器端口：${PORT} \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${MSID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：不选 \033[0m"
echo -e "\033[33m alpn：默认 \033[0m"
echo -e "\033[33m 域名：${wzym} \033[0m"
echo -e "\033[33m 传输协议：TCP \033[0m"
echo -e "\033[33m 伪装协议：未配置/none \033[0m"
echo
echo
echo
echo
echo -e "\033[31m VLESS+WS+TLS \033[0m"
echo
TIME g "vless://${MSID}@${wzym}:${PORT}?host=&path=%2F${WEBS}&type=ws&encryption=none&security=tls&sni=${wzym}#VLESS+WS+TLS"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TPC+TLS（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：V2Ray/XRay \033[0m"
echo -e "\033[33m 协议：V2Ray/XRay \033[0m"
echo -e "\033[33m 服务器地址：${wzym} \033[0m"
echo -e "\033[33m 服务器端口：${PORT} \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${MSID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：不选 \033[0m"
echo -e "\033[33m alpn：默认 \033[0m"
echo -e "\033[33m 域名：${wzym} \033[0m"
echo -e "\033[33m 传输协议：WebSocket \033[0m"
echo -e "\033[33m WebSocket Host：空 \033[0m"
echo -e "\033[33m WebSocket Path：${WEBS} \033[0m"
EOF

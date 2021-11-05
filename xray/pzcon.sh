#!/bin/bash
cat >/usr/local/etc/xray/pzcon <<-EOF
echo -e "\033[31m VLESS+TCP+XTLS \033[0m"
echo
echo -e "\033[32m vless://${MSID}@${getIpAddress}:443?headerType=none&type=tcp&encryption=none&flow=xtls-rprx-direct&security=xtls&sni=${YUMING}#VLESS+TCP+XTLS \033[0m"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TCP+XTLS（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：V2Ray/XRay \033[0m"
echo -e "\033[33m 协议：V2Ray/XRay \033[0m"
echo -e "\033[33m 服务器地址：${getIpAddress} \033[0m"
echo -e "\033[33m 服务器端口：443 \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${MSID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：勾选 \033[0m"
echo -e "\033[33m flow：xtls-rprx-direct \033[0m"
echo -e "\033[33m alpn：默认 \033[0m"
echo -e "\033[33m 域名：${YUMING} \033[0m"
echo -e "\033[33m 传输协议：TCP \033[0m"
echo -e "\033[33m 伪装协议：未配置/none \033[0m"
echo
echo
echo
echo
echo -e "\033[31m VLESS+TPC+TLS \033[0m"
echo
echo -e "\033[32m vless://${MSID}@${YUMING}:443?headerType=none&type=tcp&encryption=none&security=tls&sni=${YUMING}#VLESS+TPC+TLS \033[0m"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TPC+TLS（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：V2Ray/XRay \033[0m"
echo -e "\033[33m 协议：V2Ray/XRay \033[0m"
echo -e "\033[33m 服务器地址：${YUMING} \033[0m"
echo -e "\033[33m 服务器端口：443 \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${MSID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：不选 \033[0m"
echo -e "\033[33m alpn：默认 \033[0m"
echo -e "\033[33m 域名：${YUMING} \033[0m"
echo -e "\033[33m 传输协议：TCP \033[0m"
echo -e "\033[33m 伪装协议：未配置/none \033[0m"
echo
echo
echo
echo
echo -e "\033[31m VLESS+WS+TLS \033[0m"
echo
echo -e "\033[32m vless://${MSID}@${YUMING}:443?host=&path=%2F${WEBS}&type=ws&encryption=none&security=tls&sni=${YUMING}#VLESS+WS+TLS \033[0m"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TPC+TLS（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：V2Ray/XRay \033[0m"
echo -e "\033[33m 协议：V2Ray/XRay \033[0m"
echo -e "\033[33m 服务器地址：${YUMING} \033[0m"
echo -e "\033[33m 服务器端口：443 \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${MSID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：不选 \033[0m"
echo -e "\033[33m alpn：默认 \033[0m"
echo -e "\033[33m 域名：${YUMING} \033[0m"
echo -e "\033[33m 传输协议：WebSocket \033[0m"
echo -e "\033[33m WebSocket Host：空 \033[0m"
echo -e "\033[33m WebSocket Path：${WEBS} \033[0m"
EOF

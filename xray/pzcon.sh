#!/bin/bash
cat >/usr/local/etc/xray/pzcon <<-EOF
#!/bin/bash
clear
echo
echo
echo -e "\033[31m VLESS+TCP+XTLS \033[0m"
echo
echo "vless://${MSID}@${getIpAddress}:${PORT}?headerType=none&type=tcp&encryption=none&flow=xtls-rprx-direct&security=xtls&sni=${wzym}#VLESS+TCP+XTLS"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TCP+XTLS（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：XRay \033[0m"
echo -e "\033[33m 协议：VLESS \033[0m"
echo -e "\033[33m 服务器地址：${getIpAddress} \033[0m"
echo -e "\033[33m 服务器端口：${PORT} \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${MSID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：勾选 \033[0m"
echo -e "\033[33m 流控(flow)：xtls-rprx-direct \033[0m"
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
echo "vless://${MSID}@${wzym}:${PORT}?headerType=none&type=tcp&encryption=none&security=tls&sni=${wzym}#VLESS+TPC+TLS"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TPC+TLS（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：XRay \033[0m"
echo -e "\033[33m 协议：VLESS \033[0m"
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
echo "vless://${MSID}@${wzym}:${PORT}?host=&path=%2F${WEBS}&type=ws&encryption=none&security=tls&sni=${wzym}#VLESS+WS+TLS"
echo
echo -e "\033[33m 节点备注/别名：VLESS+WS+TLS（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：XRay \033[0m"
echo -e "\033[33m 协议：VLESS \033[0m"
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
echo -e "\033[33m WebSocket Path：/${WEBS} \033[0m"
EOF

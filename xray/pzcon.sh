#!/bin/bash
cat >/usr/local/etc/xray/pzcon <<-EOF
#!/bin/bash
echo
echo
echo -e "\033[41;33m 查询链接于：$(date +%Y年%m月%d号%H时%M分%S秒)  \033[0m"
echo
echo
echo -e "\033[31m Trojan \033[0m"
echo
echo "trojan://${QJPASS}@${domain}:${PORT}#trojan+${PORT}"
echo
echo -e "\033[32m 二维码链接(浏览器打开)：https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=trojan://${QJPASS}@${domain}:${PORT}#trojan+${PORT} \033[0m"
echo
echo -e "\033[33m 节点备注/别名：Trojan+${PORT}（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：XRay \033[0m"
echo -e "\033[33m 协议：Trojan \033[0m"
echo -e "\033[33m 服务器地址：${domain_ip} \033[0m"
echo -e "\033[33m 服务器端口：${PORT} \033[0m"
echo -e "\033[33m 密码：${QJPASS} \033[0m"
echo -e "\033[33m 传输协议：TCP \033[0m"
echo -e "\033[33m 伪装协议：未配置/none \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m 指纹伪造：禁用 \033[0m"
echo -e "\033[33m TLS Host：空 \033[0m"
echo
echo
echo
echo -e "\033[31m VLESS+TCP+XTLS \033[0m"
echo
echo "vless://${UUID}@${domain_ip}:${PORT}?headerType=none&type=tcp&encryption=none&flow=xtls-rprx-direct&security=xtls&sni=${domain}#VLESS+TCP+XTLS+${PORT}"
echo
echo -e "\033[32m 二维码链接(浏览器打开)：https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=vless://${UUID}@${domain_ip}:${PORT}?headerType=none&type=tcp&encryption=none&flow=xtls-rprx-direct&security=xtls&sni=${domain}#VLESS+TCP+XTLS+${PORT} \033[0m"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TCP+XTLS${PORT}（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：XRay \033[0m"
echo -e "\033[33m 协议：VLESS \033[0m"
echo -e "\033[33m 服务器地址：${domain_ip} \033[0m"
echo -e "\033[33m 服务器端口：${PORT} \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${UUID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：勾选 \033[0m"
echo -e "\033[33m 流控(flow)：xtls-rprx-direct \033[0m"
echo -e "\033[33m alpn：默认 \033[0m"
echo -e "\033[33m 域名：${domain} \033[0m"
echo -e "\033[33m 传输协议：TCP \033[0m"
echo -e "\033[33m 伪装协议：未配置/none \033[0m"
echo
echo
echo
echo -e "\033[31m VLESS+TPC+TLS \033[0m"
echo
echo "vless://${UUID}@${domain}:${PORT}?headerType=none&type=tcp&encryption=none&security=tls&sni=${domain}#VLESS+TPC+TLS+${PORT}"
echo
echo -e "\033[32m 二维码链接(浏览器打开)：https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=vless://${UUID}@${domain}:${PORT}?headerType=none&type=tcp&encryption=none&security=tls&sni=${domain}#VLESS+TPC+TLS+${PORT} \033[0m"
echo
echo -e "\033[33m 节点备注/别名：VLESS+TPC+TLS${PORT}（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：XRay \033[0m"
echo -e "\033[33m 协议：VLESS \033[0m"
echo -e "\033[33m 服务器地址：${domain} \033[0m"
echo -e "\033[33m 服务器端口：${PORT} \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${UUID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：不选 \033[0m"
echo -e "\033[33m alpn：默认 \033[0m"
echo -e "\033[33m 域名：${domain} \033[0m"
echo -e "\033[33m 传输协议：TCP \033[0m"
echo -e "\033[33m 伪装协议：未配置/none \033[0m"
echo
echo
echo
echo -e "\033[31m VLESS+WS+TLS \033[0m"
echo
echo "vless://${UUID}@${domain}:${PORT}?host=&path=%2F${WS_PATH}%2F&type=ws&encryption=none&security=tls&sni=${domain}#VLESS+WS+TLS+${PORT}"
echo
echo -e "\033[32m 二维码链接(浏览器打开)：https://api.qrserver.com/v1/create-qr-code/?size=400x400&data=vless://${UUID}@${domain}:${PORT}?host=&path=%2F${WS_PATH}%2F&type=ws&encryption=none&security=tls&sni=${domain}#VLESS+WS+TLS+${PORT} \033[0m"
echo
echo -e "\033[33m 节点备注/别名：VLESS+WS+TLS${PORT}（可自行修改） \033[0m"
echo -e "\033[33m 节点类型：XRay \033[0m"
echo -e "\033[33m 协议：VLESS \033[0m"
echo -e "\033[33m 服务器地址：${domain} \033[0m"
echo -e "\033[33m 服务器端口：${PORT} \033[0m"
echo -e "\033[33m 加密方式：none \033[0m"
echo -e "\033[33m UUID：${UUID} \033[0m"
echo -e "\033[33m TLS：勾选 \033[0m"
echo -e "\033[33m XTLS：不选 \033[0m"
echo -e "\033[33m alpn：默认 \033[0m"
echo -e "\033[33m 域名：${domain} \033[0m"
echo -e "\033[33m 传输协议：WebSocket \033[0m"
echo -e "\033[33m WebSocket Host：空 \033[0m"
echo -e "\033[33m WebSocket Path：/${WS_PATH}/ \033[0m"
echo
echo -e "\033[32m 查询完毕,往上翻查看  \033[0m"
echo
EOF

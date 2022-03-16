{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [
    {
      "port": ${PORT},
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "${UUID}",
            "flow": "xtls-rprx-direct"
          }
        ],
        "decryption": "none",
        "fallbacks": [
          {
            "dest": 60000,
            "alpn": "",
            "xver": 1
          },
          {
            "dest": 60001,
            "alpn": "h2",
            "xver": 1
          },
          {
            "dest": 60002,
            "path": "/${WS_PATH}/",
            "xver": 1
          }
        ]
      },
      "streamSettings": {
        "network": "tcp",
        "security": "xtls",
        "xtlsSettings": {
          "minVersion": "1.2",
          "certificates": [
            {
              "certificateFile": "/usr/local/etc/xray/self_signed_cert.pem",
              "keyFile": "/usr/local/etc/xray/self_signed_key.pem"
            },
            {
              "certificateFile": "/ssl/xray.crt",
              "keyFile": "/ssl/xray.key"
            }
          ]
        }
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 60002,
      "listen": "127.0.0.1",
      "protocol": "vless",
      "settings": {
          "clients": [
              {
                  "id": "${UUID}"
              }
          ],
          "decryption": "none"
      },
      "streamSettings": {
          "network": "ws",
          "security": "none",
          "wsSettings": {
              "acceptProxyProtocol": true,
              "path": "/${WS_PATH}/"
          }
      }
  }
],
  "outbounds": [
    {
      "protocol": "freedom"
    }
  ]
}

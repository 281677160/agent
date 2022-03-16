{
    "log": {
        "loglevel": "warning"
    },
    "inbounds": [
        {
            "port": 443,
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "ee180d68-c656-4577-943b-bbcff5097566",
                        "flow": "xtls-rprx-direct",
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
                        "path": "/VLEws133759/",
                        "dest": 60002,
                        "xver": 1
                    },
                    {
                        "path": "/VLEws13456/",
                        "dest": 60003,
                        "xver": 1
                    },
                    {
                        "path": "/VLEws134999/",
                        "dest": 60004,
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
            "port": 60000,
            "listen": "127.0.0.1",
            "protocol": "trojan",
            "settings": {
                "clients": [
                    {
                        "password": "JQ37591559",
                    }
                ],
                "fallbacks": [
                    {
                        "dest": 80
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "none",
                "tcpSettings": {
                    "acceptProxyProtocol": true
                }
            }
        },
        {
            "port": 60002,
            "listen": "127.0.0.1",
            "protocol": "vless",
            "settings": {
                "clients": [
                    {
                        "id": "ee180d68-c656-4577-943b-bbcff5097566",
                    }
                ],
                "decryption": "none"
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "acceptProxyProtocol": true,
                    "path": "/VLEws133759/"
                }
            }
        },
        {
            "port": 60003,
            "listen": "127.0.0.1",
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "ee180d68-c656-4577-943b-bbcff5097566",
                    }
                ]
            },
            "streamSettings": {
                "network": "tcp",
                "security": "none",
                "tcpSettings": {
                    "acceptProxyProtocol": true,
                    "header": {
                        "type": "http",
                        "request": {
                            "path": [
                                "/VLEws13456/"
                            ]
                        }
                    }
                }
            }
        },
        {
            "port": 60004,
            "listen": "127.0.0.1",
            "protocol": "vmess",
            "settings": {
                "clients": [
                    {
                        "id": "ee180d68-c656-4577-943b-bbcff5097566",
                    }
                ]
            },
            "streamSettings": {
                "network": "ws",
                "security": "none",
                "wsSettings": {
                    "acceptProxyProtocol": true,
                    "path": "/VLEws134999"
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

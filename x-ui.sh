#!/usr/bin/env bash

#====================================================
# Author：281677160
# Dscription：x-ui onekey Management
# github：https://github.com/281677160/danshui
#====================================================

export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
stty erase ^?

cd "$(
  cd "$(dirname "$0")" || exit
  pwd
)" || exit

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
Hi="${Green}[Hi]${Font}"
ERROR="${Red}[ERROR]${Font}"

# 变量
xui_path="/usr/local/ssl"
xray_conf_dir="/usr/local/x-ui"
website_dir="/www/xray_web/"
cert_group="nobody"
random_num=$((RANDOM % 12 + 4))
HOME="/root"
domainjilu="$HOME/.acme.sh/domainjilu"
arch=$(arch)

function print_ok() {
  echo -e " ${OK} ${Blue} $1 ${Font}"
}
function print_Hi() {
  echo -e " ${Hi} ${Blue} $1 ${Font}"
}
function print_error() {
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
}
function ECHOY()
{
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOG()
{
  echo -e "${Green} $1 ${Font}"
}
function ECHOR()
{
  echo -e "${Red} $1 ${Font}"
}


function is_root() {
if [[ ! "$USER" == "root" ]]; then
  print_error "警告：请使用root用户操作!~~"
  exit 1
fi
if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
  ARCH_PRINT="amd64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
  ARCH_PRINT="arm64"
else
  print_error "不支持此系统,只支持x86_64和arm64的系统"
  exit 1
fi
}

judge() {
  if [[ 0 -eq $? ]]; then
    print_ok "$1 完成"
    sleep 1
  else
    print_error "$1 失败"
    exit 1
  fi
}

function running_state() {
  nginxVersion="$(nginx -v 2>&1)" && NGINX_VERSION="$(echo ${nginxVersion#*/})"
  [[ -z "${NGINX_VERSION}" ]] && NGINX_VERSION="未知"
  [[ -f "/usr/local/x-ui/xui_ver" ]] && xui_ver="$(cat /usr/local/x-ui/xui_ver)"
  [[ -z "${xui_ver}" ]] && xui_ver="未知"
  if [[ `command -v x-ui |grep -c "x-ui"` == '0' ]]; then
    export XUI_ZT="${Blue} x-ui状态${Font}：${Red}未安装${Font}"
  elif [[ `systemctl status x-ui |grep -c "active (running) "` == '1' ]]; then
    export XUI_ZT="${Blue} x-ui状态${Font}：${Green}运行中 ${Font}|${Blue} 版本${Font}：${Green}${xui_ver}${Font}"
  elif [[ `command -v x-ui |grep -c "x-ui"` -ge '1' ]] && [[ `systemctl status x-ui |grep -c "active (running) "` == '0' ]]; then
    export XUI_ZT="${Blue} x-ui状态${Font}：${Green}已安装${Font},${Red}未运行${Font}"
  else
    export XUI_ZT="${Blue} x-ui状态：${Font}未知"
  fi
  if [[ `command -v nginx |grep -c "nginx"` == '0' ]]; then
    export NGINX_ZT="${Blue} Nginx状态${Font}：${Red}未安装${Font}"
  elif [[ `systemctl status nginx |grep -c "active (running) "` == '1' ]]; then
    export NGINX_ZT="${Blue} Nginx状态${Font}：${Green}运行中 ${Font}|${Blue} 版本${Font}：${Green}v${NGINX_VERSION}${Font}"
  elif [[ `command -v nginx |grep -c "nginx"` -ge '1' ]] && [[ `systemctl status nginx |grep -c "active (running) "` == '0' ]]; then
    export NGINX_ZT="${Blue} Nginx状态${Font}：${Green}已安装${Font},${Red}未运行${Font}"
  else
    export NGINX_ZT="${Blue} Nginx状态：${Font}未知"
  fi
}

function DNS_service_provider() {
  clear
  echo
  echo
  ECHOG "请选择您域名的DNS托管商"
  echo
  ECHOY " 1. Cloudflare(免费CDN提供,但是免费域名不能申请泛域名证书)"
  echo
  ECHOY " 2. DNSPod(收费CDN,但是免费域名能申请泛域名证书)"
  echo
  XUANZHEOP=" 请输入数字选择"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSEDNS
  case $CHOOSEDNS in
    1)
      export service_name="cloudflare"
      export DNS_service="dns_cf"
      export DNS_ID="CF_Email"
      export DNS_KEY="CF_Key"
      export DNS_SM="输入cloudflare网站里面的Global API Key"
      export DNS_SM2="注册绑定cloudflare网站的邮箱"
      export DNS_SM3="cloudflare的Global API Key"
      export DNS_SM4="cloudflare绑定邮箱"
    break
    ;;
    2)
      export service_name="DNSPod"
      export DNS_service="dns_dp"
      export DNS_ID="DP_Id"
      export DNS_KEY="DP_Key"
      export DNS_SM="输入DNSPod网站里面的DNSPod Token"
      export DNS_SM2="输入DNSPod网站里面的DNSPod ID"
      export DNS_SM3="DNSPod的DNSPod Token"
      export DNS_SM4="DNSPodDNSPod ID"
    break
    ;;
    *)
      XUANZHEOP=" 请输入正确的数字编号!"
    ;;
    esac
    done
}

function DNS_provider() {
  clear
  echo
  echo
  CF_domain="0"
  if [[ -f "${domainjilu}" ]]; then
    PROFIXI="$(grep 'domain=' ${domainjilu} | cut -d "=" -f2)"
    CFKEYXI="$(grep "${DNS_KEY}=" ${domainjilu} | cut -d "=" -f2)"
    EMAILXI="$(grep "${DNS_ID}=" ${domainjilu} | cut -d "=" -f2)"
  fi
  echo -e "\033[33m 请输入${service_name}解析好泛域名的域名，比如：clash.com] \033[0m"
  export YUMINGIP="请输入"
  while :; do
  CUrrenty=""
  read -p " ${YUMINGIP}：" domain
  if [[ -n "${domain}" ]] && [[ "$(echo ${domain} |grep -c '.')" -ge '1' ]]; then
    CUrrenty="Y"
  fi
  case $CUrrenty in
  Y)
    export domain="$(echo "${domain}" |sed 's/http:\/\///g' |sed 's/https:\/\///g' |sed 's/www.//g' |sed 's/\///g' |sed 's/ //g')"
  break
  ;;
  *)
    export YUMINGIP="敬告,请输入正确的域名"
  ;;
  esac
  done
  if [[ "${CFKEYXI}" == "${DNS_KEY}_xx" ]] && [[ "${EMAILXI}" == "${DNS_ID}_xx" ]] && [[ -f "/root/.acme.sh/${domain}_ecc/${domain}.key" ]]; then
    export CF_domain="1"
  else
    echo
    echo
    export CF_domain="0"
    "$HOME"/.acme.sh/acme.sh --uninstall > /dev/null 2>&1
    rm -rf "$HOME"/.acme.sh > /dev/null 2>&1
    rm -rf /usr/bin/acme.sh > /dev/null 2>&1
    echo -e "\033[33m ${DNS_SM} \033[0m"
    CFKeyIP="请输入"
    while :; do
    export CFKeyIPty=""
    read -p " ${CFKeyIP}：" DNS_KEYy
    if [[ -n "${DNS_KEYy}" ]]; then
      export CFKeyIPty="Y"
    fi
    case $CFKeyIPty in
    Y)
      if [[ "${DNS_service}" = "dns_cf" ]]; then
        export CF_Key="$(echo "${DNS_KEYy}" |sed 's/ //g')"
      else
	export DP_Key="$(echo "${DNS_KEYy}" |sed 's/ //g')"
      fi
    break
    ;;
    *)
      export CFKeyIP="敬告,数据不能为空"
    ;;
    esac
    done
  fi
    
  if [[ "${CFKEYXI}" == "${DNS_KEY}_xx" ]] && [[ "${EMAILXI}" == "${DNS_ID}_xx" ]] && [[ -f "/root/.acme.sh/${domain}_ecc/${domain}.key" ]]; then
     CF_domain="1"
  else
    echo
    echo
    echo -e "\033[33m ${DNS_SM2} \033[0m"
    export EmailIP="请输入"
    while :; do
    export EmailIPty=""
    read -p " ${EmailIP}：" DNS_IDd
    if [[ -n "${DNS_IDd}" ]]; then
      EmailIPty="Y"
    fi
    case $EmailIPty in
    Y)
      if [[ "${DNS_service}" = "dns_cf" ]]; then
        export CF_Email="$(echo "${DNS_IDd}" |sed 's/ //g')"
      else
        export DP_Id="$(echo "${DNS_IDd}" |sed 's/ //g')"
      fi
    break
    ;;
    *)
      export EmailIP="敬告,数据不能为空"
    ;;
    esac
    done
  fi
  echo
  ECHOR "请设置x-ui面板帐号,直接回车则使用 admin"
  read -p " 请输入帐号：" config_account
  export config_account=${config_account:-"admin"}
  
  echo
  ECHOY "请设置x-ui面板密码,直接回车则使用 admin"
  read -p " 请输入密码：" config_password
  export config_password=${config_password:-"admin"}
  
  echo
  ECHOG "请设置x-ui面板端口,直接回车则使用 54321"
  export DUANKO="请输入[10000-65535]之间的值"
  while :; do
  read -p " ${DUANKO}：" config_port
  export config_port=${config_port:-"54321"}
  if [[ "${config_port}" -ge "10000" ]] && [[ "${config_port}" -le "65535" ]]; then
    export PORTY="y"
  fi
  case $PORTY in
  y)
    export config_port="${config_port}"
  break
  ;;
  *)
    export DUANKO="敬告：请输入[10000-65535]之间的值"
  ;;
  esac
  done
  echo
  echo
  if [[ "${CF_domain}" == "1" ]]; then
    ECHOG "您的域名为：${domain} 证书已存在"
    ECHOG "${DNS_SM3}为：已存在"
    ECHOG "${DNS_SM4}为：已存在"
    ECHOG "面板帐号为：${config_account}"
    ECHOG "面板密码为：${config_password}"
    ECHOG "面板端口为：${config_port}"
  else 
    ECHOG "您的域名为：${domain}"
    ECHOG "${DNS_SM3}为：${DNS_KEYy}"
    ECHOG "${DNS_SM4}为：${DNS_IDd}"
    ECHOG "面板帐号为：${config_account}"
    ECHOG "面板密码为：${config_password}"
    ECHOG "面板端口为：${config_port}"
  fi
  echo
  read -p " [检查是否正确,正确回车继续,不正确按Q回车重新输入]： " NNKC
  case $NNKC in
  [Qq])
    system_check
    exit 0
  ;;
  *)
    echo
    print_ok "您已确认无误!"
  ;;
  esac
  echo
  ECHOY "开始执行安装程序,请耐心等候..."
  [[ ! -d "${xui_path}" ]] && mkdir -p "${xui_path}"
  sleep 2
  echo
 }
  
function system_check() {
  source '/etc/os-release'

  if [[ "${ID}" == "centos" && ${VERSION_ID} == "7" ]] || [[ "${ID}" == "centos" && ${VERSION_ID} == "8" ]]; then
    print_ok "当前系统为 Centos ${VERSION_ID} ${VERSION}"
    yum upgrade -y libmodulemd
    export INS="yum install -y"
    export UNINS="yum"
    ${INS} wget git sudo ca-certificates && update-ca-trust force-enable
    wget -N -P /etc/yum.repos.d/ https://raw.githubusercontent.com/281677160/agent/main/xray/nginx.repo
  elif [[ "${ID}" == "ol" ]]; then
    print_ok "当前系统为 Oracle Linux ${VERSION_ID} ${VERSION}"
    export INS="yum install -y"
    export UNINS="yum"
    ${INS} wget git sudo ca-certificates && update-ca-trust force-enable
    wget -N -P /etc/yum.repos.d/ https://raw.githubusercontent.com/281677160/agent/main/xray/nginx.repo
  elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
    print_ok "当前系统为 Debian ${VERSION_ID} ${VERSION}"
    export INS="apt install -y"
    export UNINS="apt"
    ${INS} wget git sudo ca-certificates && update-ca-certificates
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    $INS lsb-release gnupg2

    echo "deb http://nginx.org/packages/debian $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

    apt update
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 18 ]]; then
    print_ok "当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME}"
    export INS="apt install -y"
    export UNINS="apt"
    ${INS} wget git sudo ca-certificates && update-ca-certificatesgit
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    $INS lsb-release gnupg2

    echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt update
  else
    print_error "当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内"
    exit 1
  fi

  if [[ $(grep "nogroup" /etc/group) ]]; then
    cert_group="nogroup"
  fi

  $INS dbus
  
  if [[ -d "/etc/x-ui" ]]; then
    systemctl stop x-ui > /dev/null 2>&1
    systemctl disable x-ui > /dev/null 2>&1
    rm /etc/systemd/system/x-ui.service -f > /dev/null 2>&1
    systemctl daemon-reload > /dev/null 2>&1
    systemctl reset-failed > /dev/null 2>&1
    rm /etc/x-ui/ -rf > /dev/null 2>&1
    rm /usr/local/x-ui/ -rf > /dev/null 2>&1
    rm -rf /usr/bin/x-ui -rf > /dev/null 2>&1
  fi
  
  # 关闭各类防火墙
  systemctl stop firewalld
  systemctl disable firewalld
  systemctl mask firewalld
  systemctl stop nftables
  systemctl disable nftables
  systemctl stop ufw
  systemctl disable ufw
  if [[ `systemctl status iptables |grep -c "enabled"` == '1' ]]; then
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    echo '
    #! /bin/sh
    ### BEGIN INIT INFO
    # Provides:        acceptoff
    # Required-Start:  $local_fs $remote_fs
    # Required-Stop:   $local_fs $remote_fs
    # Default-Start:   2 3 4 5
    # Default-Stop:
    # Short-Description: automatic crash report generation
    ### END INIT INFO
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    iptables -F
    ' >/etc/init.d/acceptoff
    sed -i 's/^[ ]*//g' /etc/init.d/acceptoff
    sed -i '/^$/d' /etc/init.d/acceptoff
    chmod 755 /etc/init.d/acceptoff
    update-rc.d acceptoff defaults 90
  fi
}

function nginx_install() {
  nginxVersion="$(nginx -v 2>&1)" && NGINX_VERSION="$(echo ${nginxVersion#*/})"
  if [[ `command -v nginx |grep -c "nginx"` -ge '1' ]] && [[ "${NGINX_VERSION}" == "1.20.2" ]]; then
    ${INS} nginx >/dev/null 2>&1
    print_ok "Nginx 已存在"
  else
    systemctl stop nginx >/dev/null 2>&1
    systemctl disable nginx >/dev/null 2>&1
    ${UNINS} --purge remove -y nginx >/dev/null 2>&1
    ${UNINS} autoremove -y >/dev/null 2>&1
    ${UNINS} --purge remove -y nginx >/dev/null 2>&1
    ${UNINS} --purge remove -y nginx-common >/dev/null 2>&1
    ${UNINS} --purge remove -y nginx-core >/dev/null 2>&1
    find / -iname 'nginx' 2>&1 | xargs -i rm -rf {}
    ${INS} nginx
    judge "安装 nginx"
  fi
}

function dependency_install() {
  ${INS} socat
  judge "安装 socat"

  ${INS} tar
  judge "安装 tar"
  
  ${INS} lsof
  judge "安装 lsof"

  if [[ "${ID}" == "centos" || "${ID}" == "ol" ]]; then
    ${INS} crontabs
  else
    ${INS} cron
  fi
  judge "安装 crontab"

  if [[ "${ID}" == "centos" || "${ID}" == "ol" ]]; then
    touch /var/spool/cron/root && chmod 600 /var/spool/cron/root
    systemctl start crond && systemctl enable crond
  else
    touch /var/spool/cron/crontabs/root && chmod 600 /var/spool/cron/crontabs/root
    systemctl start cron && systemctl enable cron
  fi
  judge "crontab 自启动配置 "

  ${INS} unzip
  judge "安装 unzip"

  # upgrade systemd
  ${INS} systemd
  judge "安装/升级 systemd"

  if [[ "${ID}" == "centos" ]]; then
    ${INS} pcre pcre-devel zlib-devel epel-release openssl openssl-devel
  elif [[ "${ID}" == "ol" ]]; then
    ${INS} pcre pcre-devel zlib-devel openssl openssl-devel
    # Oracle Linux 不同日期版本的 VERSION_ID 比较乱 直接暴力处理。如出现问题或有更好的方案，请提交 Issue。
    yum-config-manager --enable ol7_developer_EPEL >/dev/null 2>&1
    yum-config-manager --enable ol8_developer_EPEL >/dev/null 2>&1
  else
    ${INS} libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev
  fi

  # 防止部分系统xray的默认bin目录缺失
  mkdir /usr/local/bin >/dev/null 2>&1
  # 开启ROOT用户SSH和防止SSH容易断连
  if [[ `grep -c "ClientAliveInterval 30" /etc/ssh/sshd_config` == '0' ]]; then
    bash -c  "$(curl -fsSL https://raw.githubusercontent.com/281677160/pve/main/ssh.sh)"
  fi
}

function basic_optimization() {
  # 最大文件打开数
  sed -i '/^\*\ *soft\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
  sed -i '/^\*\ *hard\ *nofile\ *[[:digit:]]*/d' /etc/security/limits.conf
  echo '* soft nofile 65536' >>/etc/security/limits.conf
  echo '* hard nofile 65536' >>/etc/security/limits.conf

  # RedHat 系发行版关闭 SELinux
  if [[ "${ID}" == "centos" || "${ID}" == "ol" ]]; then
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    setenforce 0
  fi
}

function domain_check() {
  export domain_ip="$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')" > /dev/null 2>&1
  export local_ip=$(curl -4L api64.ipify.org)
  print_ok "检测域名解析"
  if [[ ! ${local_ip} == ${domain_ip} ]]; then
    echo
    ECHOY "域名解析IP为：${domain_ip}"
    echo
    ECHOY "本机IP为：${local_ip}"
    echo
    print_error "域名解析IP跟本机IP不一致"
    exit 1
  else
    print_ok "域名解析IP为：${domain_ip}"
    print_ok "本机IP为：${local_ip}"
    print_ok "域名解析IP跟本机IP一致"
  fi
}

function port_exist_check() {
  if [[ 0 -eq $(lsof -i:"$1" | grep -i -c "listen") ]]; then
    print_ok "$1 端口未被占用"
    sleep 1
  else
    print_error "检测到 $1 端口被占用，以下为 $1 端口占用信息"
    lsof -i:"$1"
    print_error "5s 后将尝试自动 kill 占用进程"
    sleep 5
    lsof -i:"$1" | awk '{print $2}' | grep -v "PID" | xargs kill -9
    print_ok "kill 完成"
    sleep 1
  fi
}

function xui_install() {
  print_ok "安装 x-ui"
  cd /root
  latest_ver="$(wget -qO- -t1 -T2 "https://api.github.com/repos/FranzKafkaYu/x-ui/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')"
  wget -q -P /root https://ghproxy.com/https://github.com/FranzKafkaYu/x-ui/releases/download/${latest_ver}/x-ui-linux-${ARCH_PRINT}.tar.gz -O /root/x-ui-linux-${ARCH_PRINT}.tar.gz
  judge "x-ui 文件下载"
  rm x-ui/ /usr/local/x-ui/ /usr/bin/x-ui -rf
  tar zxvf x-ui-linux-${ARCH_PRINT}.tar.gz
  judge "x-ui 文件解压"
  chmod +x x-ui/x-ui x-ui/bin/xray-linux-* x-ui/x-ui.sh
  cp x-ui/x-ui.sh /usr/bin/x-ui
  cp -f x-ui/x-ui.service /etc/systemd/system/
  mv x-ui/ /usr/local/
  systemctl daemon-reload
  systemctl enable x-ui
  systemctl restart x-ui
  judge "x-ui 安装"
  echo "v${latest_ver}" >/usr/local/x-ui/xui_ver
  rm -rf /root/x-ui-linux-${ARCH_PRINT}.tar.gz
}

function generate_certificate() {
  /usr/local/x-ui/x-ui setting -username ${config_account} -password ${config_password}
  /usr/local/x-ui/x-ui setting -port ${config_port}
}

function configure_web() {
  rm -rf /www/xui_web
  mkdir -p /www/xui_web
  wget -O web.tar.gz https://raw.githubusercontent.com/281677160/agent/main/xray/web.tar.gz
  tar xzf web.tar.gz -C /www/xui_web
  judge "站点伪装"
  rm -f web.tar.gz
}

function configure_nginx() {
ECHOY "正在设置所有应用配置文件"
cat >"/etc/nginx/conf.d/xui_www.conf" <<-EOF
server {
    listen  80; 
    server_name  ${domain};
    return 301 https://\$host\$request_uri; 
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name  ${domain};
    ssl_certificate ${xui_path}/server.crt;
    ssl_certificate_key ${xui_path}/server.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 60m;
    index index.php index.html index.htm default.php default.htm default.html;
    root /www/xui_web;
    add_header Access-Control-Allow-Origin *;
    
    error_page 404 /index.html;
    gzip on; #开启gzip压缩
    gzip_min_length 1k; #设置对数据启用压缩的最少字节数
    gzip_buffers 4 16k;
    gzip_http_version 1.0;
    gzip_comp_level 6; #设置数据的压缩等级,等级为1-9，压缩比从小到大
    gzip_types text/plain text/css text/javascript application/json application/javascript application/x-javascript application/xml; #设置需要压缩的数据格式
    gzip_vary on;
    
    location ~* \.(css|js|png|jpg|jpeg|gif|gz|svg|mp4|ogg|ogv|webm|htc|xml|woff)$ {
        access_log off;
        add_header Cache-Control "public,max-age=30*24*3600";
    }
    
    location ~ ^/(.user.ini|.htaccess|.git|.svn|.project|LICENSE|README.md)
    {
        return 404;
    }
    access_log off;
}
EOF

cat >/etc/nginx/conf.d/xui_nginx.conf <<-EOF
server
{
    listen 80 default_server;
    listen [::]:80 default_server;
    listen 443 ssl http2;
    listen [::]:443 ssl;
    #配置站点域名，多个以空格分开
    server_name ${domain};
    index index.php index.html index.htm default.php default.htm default.html;
    root /www/xui_web;
    #SSL-START SSL相关配置，请勿删除或修改下一行带注释的404规则
    #error_page 404/404.html;
    #HTTP_TO_HTTPS_START
    ssl_certificate ${xui_path}/server.crt;
    ssl_certificate_key ${xui_path}/server.key;
    #ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
    ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on; 
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
    add_header Strict-Transport-Security "max-age=31536000";
    error_page 497  https://;
    
    #禁止访问的文件或目录
    location ~ ^/(\.user.ini|\.htaccess|\.git|\.svn|\.project|LICENSE|README.md)
    {
        return 404;
    }
    
    location ~ .*\.(gif|jpg|jpeg|png|bmp|swf)$
    {
        expires      30d;
        error_log /dev/null;
        access_log /dev/null;
    }
    
    location ~ .*\.(js|css)?$
    {
        expires      12h;
        error_log /dev/null;
        access_log /dev/null; 
    }
    location ^~ /xui {
	    proxy_pass https://127.0.0.1:${config_port}/xui;
	    proxy_set_header Host \$host;
	    proxy_set_header X-Real-IP \$remote_addr;
	    proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOF
  chmod -R 755 /etc/nginx/conf.d
  systemctl restart nginx
  if [[ $? -ne 0 ]];then
    print_error "配置文件启动失败"
    exit 1
  else
    print_ok "配置文件启动成功"
  fi
}

function ssl_judge_and_install() {
  if [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" && -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" && -f "$HOME/.acme.sh/acme.sh" ]]; then
    print_ok "[${domain}]证书已存在，重新启用证书"
    [[ ! -f "/usr/bin/acme.sh" ]] && ln -s  /root/.acme.sh/acme.sh /usr/bin/acme.sh
    rm -rf ${xui_path}/server.key ${xui_path}/server.crt
    acme.sh --installcert -d "${domain}" --ecc  --key-file   ${xui_path}/server.key   --fullchain-file ${xui_path}/server.crt
    judge "证书启用"
    chown -R nobody.$cert_group "${xui_path}/server.key"
    chown -R nobody.$cert_group "${xui_path}/server.crt"
    sleep 2
    acme.sh --upgrade --auto-upgrade
    judge "SSL 启动证书自动续期"
    if [[ "${DNS_service}" = "dns_cf" ]]; then
      echo "domain=${domain}" > "${domainjilu}"
      echo "CF_Key=CF_Key_xx" >> "${domainjilu}"
      echo "CF_Email=CF_Email_xx" >> "${domainjilu}"
    else
      echo "domain=${domain}" > "${domainjilu}"
      echo "DP_Key=DP_Key_xx" >> "${domainjilu}"
      echo "DP_Id=DP_Id_xx" >> "${domainjilu}"
    fi
    judge "域名记录"
  else
    rm -fr "$HOME"/.acme.sh > /dev/null 2>&1
    acme
  fi
}

function acme() {
  curl -L https://get.acme.sh | sh
  judge "安装acme.sh脚本"
  [[ ! -f "/usr/bin/acme.sh" ]] && ln -s /root/.acme.sh/acme.sh /usr/bin/acme.sh
  acme.sh --set-default-ca --server letsencrypt
  systemctl stop nginx
  sleep 2
  acme.sh --issue --dns "${DNS_service}" -d "${domain}" -d "*.${domain}" --keylength ec-256
  if [[ $? -eq 0 ]]; then
    print_ok "SSL 证书生成成功" 
    rm -rf ${xui_path}/server.key ${xui_path}/server.crt
    acme.sh --installcert -d "${domain}" --ecc  --key-file   ${xui_path}/server.key   --fullchain-file ${xui_path}/server.crt
    judge "SSL 证书配置成功"
    chown -R nobody.$cert_group "${xui_path}/server.key"
    chown -R nobody.$cert_group "${xui_path}/server.crt"
    systemctl start nginx
    acme.sh  --upgrade  --auto-upgrade
    judge "SSL 启动证书自动续期"
    if [[ "${DNS_service}" = "dns_cf" ]]; then
      echo "domain=${domain}" > "${domainjilu}"
      echo "CF_Key=CF_Key_xx" >> "${domainjilu}"
      echo "CF_Email=CF_Email_xx" >> "${domainjilu}"
    else
      echo "domain=${domain}" > "${domainjilu}"
      echo "DP_Key=DP_Key_xx" >> "${domainjilu}"
      echo "DP_Id=DP_Id_xx" >> "${domainjilu}"
    fi
    judge "域名记录"
  else
    systemctl start nginx
    print_error "SSL 证书生成失败"
    rm -rf "$HOME/.acme.sh/${domain}_ecc"
    exit 1
  fi
}

function restart_all() {
  curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/x-ui.sh > "/usr/bin/glxray"
  chmod 777 "/usr/bin/glxray"
  clear
  echo
  echo
  echo
  echo
  ECHOY "1、用浏览器打开此链接： http://${local_ip}:${config_port}"
  ECHOY "2、然后用您设置的帐号密码登录面板"
  ECHOG "3、左侧-->面板设置，然后把《面板证书公钥文件路径》改成 ${xui_path}/server.crt"
  ECHOG "4、左侧-->面板设置，然后把《面板证书密钥文件路径》改成 ${xui_path}/server.key"
  ECHOG "5、左侧-->面板设置，然后把《面板 url 根路径》改成 /xui/"
  ECHOG "6、然后左侧上面-->保存配置,重启面板"
  ECHOY "7、重启面板后使用 https://${domain}/xui 访问您的x-ui面板"
  ECHOG "8、伪装网站访问为 https://${domain}"
  ECHOR "9、提醒：《面板 url 根路径》和《端口》是不能修改成其他的,要修改的话,就相对应的修改nginx的配置文件"
  echo
  echo
  ECHOG "友情提示：再次输入安装命令或者输入[glxray]命令可以对程序进行管理"
  echo
  cat >${xui_path}/conck <<-EOF
  echo -e "\033[32m面板证书公钥文件路径：\033[0m${xui_path}/server.crt"
  echo -e "\033[32m面板证书密钥文件路径：\033[0m${xui_path}/server.key"
EOF
}

function restart_xui() {
  systemctl restart nginx
  systemctl restart x-ui
  sleep 2
  if [[ `systemctl status nginx |grep -c "active (running) "` == '1' ]]; then
    print_ok "nginx运行 正常"
  else
    print_error "nginx没有运行"
    exit 1
  fi
  if [[ `systemctl status x-ui |grep -c "active (running) "` == '1' ]]; then
    systemctl enable x-ui
    print_ok "x-ui运行 正常"
  else
    print_error "x-ui没有运行"
    exit 1
  fi
}

function xui_uninstall() {
  systemctl stop x-ui
  systemctl disable x-ui
  rm /etc/systemd/system/x-ui.service -f
  systemctl daemon-reload
  systemctl reset-failed
  rm /etc/x-ui/ -rf > /dev/null 2>&1
  rm /usr/local/x-ui/ -rf > /dev/null 2>&1
  rm -rf /usr/bin/x-ui -rf > /dev/null 2>&1
  rm -rf /etc/nginx/conf.d/xui_nginx.conf
  rm -rf "/www/xui_web" > /dev/null 2>&1
  rm -rf "/etc/nginx/conf.d/xui_www.conf" > /dev/null 2>&1
  print_ok "x-ui面板御载 完成"
  sleep 1
  source '/etc/os-release'
  if [[ "${ID}" == "centos" ]] || [[ "${ID}" == "ol" ]]; then
    export UNINS="yum"
  else
    export UNINS="apt"
  fi
  if [[ -x "$(command -v nginx)" ]]; then
    clear
    echo
    ECHOR "是否卸载nginx? 按[Y/y]进行御载,按任意键跳过御载程序"
    echo
    ECHOY "如果您还有其他应用在使用nginx，比如clash节点转换，请跳过御载"
    echo
    read -p " 输入您的选择：" uninstall_nginx
    case $uninstall_nginx in
    [Yy])
      systemctl stop nginx
      systemctl disable nginx
      ${UNINS} --purge remove -y nginx
      ${UNINS} autoremove -y
      ${UNINS} --purge remove -y nginx
      ${UNINS} --purge remove -y nginx-common
      ${UNINS} --purge remove -y nginx-core
      find / -iname 'nginx' 2>&1 | xargs -i rm -rf {}
      print_ok "nginx御载 完成"
    ;;
    *) 
       print_ok "您已跳过御载nginx"
       echo
     ;;
    esac
  fi
  sleep 2
  if [[ -d "$HOME"/.acme.sh ]]; then
    clear
    echo
    [[ -f "${domainjilu}" ]] && domain="$(grep 'domain=' ${domainjilu} | cut -d "=" -f2)"
    if [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" && -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" && -f "$HOME/.acme.sh/acme.sh" ]]; then
        export TISHI="提示：[ ${PROFILE} ]证书已经存在,如果还继续使用此域名建议勿删除.acme.sh"
     else
        export WUTISHI="Y"
     fi
     if [[ ${WUTISHI} == "Y" ]]; then
        "$HOME"/.acme.sh/acme.sh --uninstall
        rm -rf $HOME/.acme.sh
	rm -rf /usr/bin/acme.sh
	rm -rf "/usr/local/ssl"
      else
        ECHOR "是否卸载acme.sh? 按[Y/y]进行御载,按任意键跳过御载程序"
        echo
        ECHOY "${TISHI}"
        echo
        read -p " 输入您的选择：" uninstall_acme
        case $uninstall_acme in
        [Yy])
           "$HOME"/.acme.sh/acme.sh --uninstall
           rm -rf "$HOME"/.acme.sh
	   rm -rf /usr/bin/acme.sh
	   rm -rf "/usr/local/ssl"
	   print_ok "acme.sh御载 完成"
	   sleep 2
        ;;
        *) 
           print_ok "您已跳过御载acme.sh"
           echo
        ;;
        esac
     fi
  fi
  print_ok "所有卸载程序执行完毕!"
  exit 0
}

function install_xui() {
  is_root
  DNS_service_provider
  DNS_provider
  system_check
  dependency_install
  basic_optimization
  domain_check
  port_exist_check 80
  xui_install
  nginx_install
  generate_certificate
  configure_web
  ssl_judge_and_install
  configure_nginx
  restart_xui
  restart_all
}
menu() {
  clear
  echo
  echo
  running_state
  echo -e "${XUI_ZT}"
  echo -e "${NGINX_ZT}"
  echo
  ECHOY "1、安装 x-ui面板、nginx和伪装网站"
  ECHOY "2、重启 x-ui面板、nginx"
  ECHOY "3、查询 证书路径"
  ECHOY "4、安装 BBR、锐速加速"
  ECHOY "5、卸载 x-ui面板、nginx"
  ECHOY "6、退出"
  echo
  echo
  XUANZHE="请输入数字"
  while :; do
  read -p " ${XUANZHE}：" menu_num
  case $menu_num in
  1)
    install_xui
    break
    ;;
  2)
    restart_xui
    break
    ;;
  3)
    [[ -f ${xui_path}/conck ]] && source ${xui_path}/conck || ECHOY "无此文件或者没有证书"
    break
    ;;
  4)
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh)"
    break
    ;;
  5)
    xui_uninstall
    break
    ;;
  6)
    exit 0
    break
    ;;
    *)
    XUANZHE="请输入正确的选择"
    ;;
  esac
  done
}
menu "$@"

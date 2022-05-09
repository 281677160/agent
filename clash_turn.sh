#!/bin/bash

# 字体颜色配置
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
Blue="\033[36m"
Font="\033[0m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
OK="${Green}[OK]${Font}"
ERROR="${Red}[ERROR]${Font}"

function print_ok() {
  echo
  echo -e " ${OK} ${Blue} $1 ${Font}"
  echo
}
function print_error() {
  echo
  echo -e "${ERROR} ${RedBG} $1 ${Font}"
  echo
}
function ECHOY()
{
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOG()
{
  echo
  echo -e "${Green} $1 ${Font}"
  echo
}
function ECHOR()
{
  echo
  echo -e "${Red} $1 ${Font}"
  echo
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

export clash_path="/usr/local/etc/clash"
export cert_group="nobody"
export random_num=$((RANDOM % 12 + 4))
export HOME="/root"
export domainjilu="$HOME/.acme.sh/domainjilu"
export HDFW_PORT="25500"
export DLJ_PORT="42301"
export arch=$(arch)

if [[ ! "$USER" == "root" ]]; then
  print_error "警告：请使用root用户操作!~~"
  exit 1
fi
if [[ $arch == "x86_64" || $arch == "x64" || $arch == "amd64" ]]; then
  ARCH_PRINT="linux64"
elif [[ $arch == "aarch64" || $arch == "arm64" ]]; then
  ARCH_PRINT="aarch64"
else
  print_error "不支持此系统,只支持x86_64和arm64的系统"
  exit 1
fi

function system_check() {
  clear
  echo
  echo
  [[ ! -d "${clash_path}" ]] && mkdir -p "${clash_path}"
  CF_domain="0"
  if [[ -f "${domainjilu}" ]]; then
    PROFILE="$(grep 'domain=' ${domainjilu} | cut -d "=" -f2)"
    CFKEYLE="$(grep 'CF_Key=' ${domainjilu} | cut -d "=" -f2)"
    EMAILLE="$(grep 'CF_Email=' ${domainjilu} | cut -d "=" -f2)"
  fi
  echo -e "\033[33m 请输入已解析泛域名的域名，比如：clash.com] \033[0m"
  export YUMINGIP="请输入"
  while :; do
  CUrrenty=""
  read -p " ${YUMINGIP}：" CUrrent_ip
  if [[ -n "${CUrrent_ip}" ]] && [[ "$(echo ${CUrrent_ip} |grep -c '.')" -ge '1' ]]; then
    CUrrenty="Y"
  fi
  case $CUrrenty in
  Y)
    export CUrrent_ip="$(echo "${CUrrent_ip}" |sed 's/http:\/\///g' |sed 's/https:\/\///g' |sed 's/\///g' |sed 's/ //g')"
    export after_ip="http://127.0.0.1:25500"
    export http_suc_ip="https://suc.${CUrrent_ip}"
    export suc_ip="suc.${CUrrent_ip}"
    export www_ip="www.${CUrrent_ip}"
    export myurls_ip="dl.${CUrrent_ip}"
    export domain="${CUrrent_ip}"
  break
  ;;
  *)
    export YUMINGIP="敬告,请输入正确的域名"
  ;;
  esac
  done
    if [[ "${CFKEYLE}" == "CF_Key_xx" ]] && [[ "${EMAILLE}" == "CF_Email_xx" ]] && [[ -f "/root/.acme.sh/${domain}_ecc/${domain}.key" ]]; then
       export CF_domain="1"
    else
       echo
       echo
      export CF_domain="0"
      "$HOME"/.acme.sh/acme.sh --uninstall > /dev/null 2>&1
       rm -rf "$HOME"/.acme.sh > /dev/null 2>&1
       rm -rf /usr/bin/acme.sh > /dev/null 2>&1
       echo -e "\033[33m 输入cloudflare网站里面的Global API Key \033[0m"
       CFKeyIP="请输入"
       while :; do
       export CFKeyIPty=""
       read -p " ${CFKeyIP}：" CF_Key
       if [[ -n "${CF_Key}" ]]; then
         export CFKeyIPty="Y"
       fi
       case $CFKeyIPty in
       Y)
         export CF_Key="${CF_Key}"
	 export CF_Key="$(echo "${CF_Key}" |sed 's/ //g')"
       break
       ;;
       *)
         export CFKeyIP="敬告,Global API Key不能为空,请输入"
       ;;
       esac
       done
    fi
    if [[ "${CFKEYLE}" == "CF_Key_xx" ]] && [[ "${EMAILLE}" == "CF_Email_xx" ]] && [[ -f "/root/.acme.sh/${domain}_ecc/${domain}.key" ]]; then
       CF_domain="1"
    else
       echo
       echo
       echo -e "\033[33m 注册绑定cloudflare网站的邮箱 \033[0m"
       export EmailIP="请输入"
       while :; do
       export EmailIPty=""
       read -p " ${EmailIP}：" CF_Email
       if [[ -n "${CF_Email}" ]]; then
         EmailIPty="Y"
       fi
       case $EmailIPty in
       Y)
         export CF_Email="${CF_Email}"
	 export CF_Email="$(echo "${CF_Email}" |sed 's/ //g')"
       break
       ;;
       *)
         export EmailIP="敬告,CF注册邮箱不能为空,请输入"
       ;;
       esac
       done
    fi
  echo
  echo
  if [[ "${CF_domain}" == "1" ]]; then
    ECHOG "您的域名为：${CUrrent_ip} 证书已存在"
    ECHOG "Global API Key为：已存在"
    ECHOG "CF注册邮箱为：已存在"
  else 
    ECHOG "您的域名为：${CUrrent_ip}"
    ECHOG "Global API Key为：${CF_Key}"
    ECHOG "CF注册邮箱为：${CF_Email}"
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
  sleep 2
  echo
  
  ECHOY "正在安装各种必须依赖"
  echo
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
    yum install -y wget curl sudo git lsof tar systemd dbus
    wget -N -P /etc/yum.repos.d/ https://ghproxy.com/https://raw.githubusercontent.com/281677160/agent/main/xray/nginx.repo
    curl -sL https://rpm.nodesource.com/setup_12.x | bash -
    sudo yum install epel-release
    yum update -y
    yum install -y nodejs redis
    npm install -g yarn
    export INS="yum install -y"
    export PUBKEY="centos"
    export Subcon="/etc/rc.d/init.d/subconverter"
  elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
    export INS="apt-get install -y"
    export UNINS="apt-get remove -y"
    export PUBKEY="ubuntu"
    export Subcon="/etc/init.d/subconverter"
    nodejs_install
  elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
    export INS="apt install -y"
    export UNINS="apt remove -y"
    export PUBKEY="debian"
    export Subcon="/etc/init.d/subconverter"
    nodejs_install
  else
    echo -e "\033[31m 不支持该系统 \033[0m"
    exit 1
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

function nodejs_install() {
    apt update
    ${INS} curl wget sudo git lsof tar systemd lsb-release redis-server dbus gnupg2
    ${UNINS} --purge npm >/dev/null 2>&1
    ${UNINS} --purge nodejs >/dev/null 2>&1
    ${UNINS} --purge nodejs-legacy >/dev/null 2>&1
    apt autoremove -y
    curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
    ${UNINS} cmdtest >/dev/null 2>&1
    ${UNINS} yarn >/dev/null 2>&1
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    rm -f /etc/apt/sources.list.d/nginx.list
    echo "deb http://nginx.org/packages/${PUBKEY} $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt-get update
    ${INS} nodejs yarn
}

function nginx_install() {
  if [[ $(grep "nogroup" /etc/group) ]]; then
    cert_group="nogroup"
  fi
  if ! command -v nginx >/dev/null 2>&1; then
    ${INS} nginx
  else
    print_ok "Nginx 已存在"
    ${INS} nginx >/dev/null 2>&1
  fi
}

function command_Version() {
  if [[ ! -x "$(command -v node)" ]]; then
    print_error "node安装失败!"
    exit 1
  else
    node_version="$(node --version |egrep -o 'v[0-9]+\.[0-9]+\.[0-9]+')"
    print_ok "node版本号为：${node_version}"
  fi
  if [[ ! -x "$(command -v yarn)" ]]; then
    print_error "yarn安装失败!"
    exit 1
  else
    yarn_version="$(yarn --version |egrep -o '[0-9]+\.[0-9]+\.[0-9]+')"
    print_ok "yarn版本号为：${yarn_version}"
  fi
  if [[ ! -x "$(command -v nginx)" ]]; then
    print_error "nginx安装失败!"
    exit 1
  else
    nginxVersion="$(nginx -v 2>&1)" && NGINX_VERSION="$(echo ${nginxVersion#*/})"
    print_ok "Nginx版本号为：${NGINX_VERSION}"
  fi
  if [[ `systemctl status redis |grep -c "active (running) "` == '1' ]]; then
    print_ok "redis安装成功"
  else
    print_error "redis安装失败,有可能是您的机器禁止IPV6造成的,请百度安装redis自行安装试试"
    exit 1
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

function port_exist_check() {
  if [[ $(lsof -i:"${HDFW_PORT}" | grep -i -c "listen") -ge "1" ]]; then
    lsof -i:"${HDFW_PORT}" | awk '{print $2}' | grep -v "PID" | xargs kill -9
  fi
  if [[ $(lsof -i:"${DLJ_PORT}" | grep -i -c "listen") -ge "1" ]]; then
    lsof -i:"${DLJ_PORT}" | awk '{print $2}' | grep -v "PID" | xargs kill -9
  fi
  if [[ $(lsof -i:"80" | grep -i -c "listen") -ge "1" ]]; then
    lsof -i:"80" | awk '{print $2}' | grep -v "PID" | xargs kill -9
  fi
}

function domain_check() {
  if [[ "${CF_domain}" == "0" ]]; then
    export domain_ip="$(ping "${domain}" -c 1 | sed '1{s/[^(]*(//;s/).*//;q}')" > /dev/null 2>&1
    export local_ip=$(curl -4L api64.ipify.org)
    print_ok "检测域名解析"
    if [[ ! ${local_ip} == ${domain_ip} ]]; then
      echo
      ECHOY "域名解析IP为：${domain_ip}"
      echo
      ECHOY "本机IP为：${local_ip}"
      echo
      print_error "域名解析IP跟本机IP不一致,检测域名解析是否生效,或是否打开了CDN了"
      exit 1
    else
      print_ok "域名解析IP为：${domain_ip}"
      print_ok "本机IP为：${local_ip}"
      print_ok "域名解析IP跟本机IP一致"
    fi
  fi
}

function ssl_judge_and_install() {
  if [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" && -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" && -f "$HOME/.acme.sh/acme.sh" ]]; then
    print_ok "[${domain}]证书已存在，重新启用证书"
    [[ ! -f "/usr/bin/acme.sh" ]] && ln -s  /root/.acme.sh/acme.sh /usr/bin/acme.sh
    rm -rf ${clash_path}/server.key ${clash_path}/server.crt
    acme.sh --installcert -d "${domain}" --ecc  --key-file   ${clash_path}/server.key   --fullchain-file ${clash_path}/server.crt
    judge "证书启用"
    chown -R nobody.$cert_group "${clash_path}/server.key"
    chown -R nobody.$cert_group "${clash_path}/server.crt"
    sleep 2
    .acme.sh/acme.sh --upgrade --auto-upgrade
    echo "domain=${domain}" > "${domainjilu}"
    echo "CF_Key=CF_Key_xx" >> "${domainjilu}"
    echo "CF_Email=CF_Email_xx" >> "${domainjilu}"
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
  acme.sh --issue --dns dns_cf -d "${domain}" -d "*.${domain}" --keylength ec-256
  if [[ $? -eq 0 ]]; then
    print_ok "SSL 证书生成成功" 
    rm -rf ${clash_path}/server.key ${clash_path}/server.crt
    acme.sh --installcert -d "${domain}" --ecc  --key-file   ${clash_path}/server.key   --fullchain-file ${clash_path}/server.crt
    judge "SSL 证书配置成功"
    chown -R nobody.$cert_group "${clash_path}/server.key"
    chown -R nobody.$cert_group "${clash_path}/server.crt"
    systemctl start nginx
    acme.sh  --upgrade  --auto-upgrade
    echo "domain=${domain}" > "${domainjilu}"
    echo "CF_Key=CF_Key_xx" >> "${domainjilu}"
    echo "CF_Email=CF_Email_xx" >> "${domainjilu}"
    judge "域名记录"
  else
    systemctl start nginx
    print_error "SSL 证书生成失败"
    rm -rf "$HOME/.acme.sh/${domain}_ecc"
    exit 1
  fi
}

function install_subconverter() {
  ECHOY "正在安装subconverter服务"
  find / -name 'subconverter' 2>&1 | xargs -i rm -rf {}
  if [[ -x "$(command -v docker)" ]]; then
    if [[ `docker images | grep -c "subconverter"` -ge '1' ]] || [[ `docker ps -a | grep -c "subconverter"` -ge '1' ]]; then
      ECHOY "检测到subconverter服务存在，正在御载subconverter服务，请稍后..."
      dockerid="$(docker ps -a |grep 'subconverter' |awk '{print $1}')"
      imagesid="$(docker images |grep 'subconverter' |awk '{print $3}')"
      docker stop -t=5 "${dockerid}" > /dev/null 2>&1
      docker rm "${dockerid}"
      docker rmi "${imagesid}"
      if [[ `docker ps -a | grep -c "subconverter"` == '0' ]] && [[ `docker images | grep -c "subconverter"` == '0' ]]; then
        print_ok "subconverter御载完成"
      else
        print_error "subconverter御载失败"
        exit 1
      fi
    fi  
  fi
  latest_vers="$(wget -qO- -t1 -T2 "https://api.github.com/repos/tindy2013/subconverter/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')"
  [[ -z ${latest_vers} ]] && latest_vers="v0.7.2"
  rm -rf "${clash_path}/subconverter_${ARCH_PRINT}.tar.gz" >/dev/null 2>&1
  wget -P "${clash_path}" https://github.com/tindy2013/subconverter/releases/download/${latest_vers}/subconverter_${ARCH_PRINT}.tar.gz -O "${clash_path}/subconverter_${ARCH_PRINT}.tar.gz"
  if [[ $? -ne 0 ]];then
    print_error "subconverter源码下载失败"
    exit 1
  fi
  rm -rf "${clash_path}/subconverter"
  tar -zxvf "${clash_path}/subconverter_${ARCH_PRINT}.tar.gz" -C "${clash_path}"
  if [[ $? -ne 0 ]];then
    print_error "subconverter解压失败"
    exit 1
  else
    print_ok "subconverter解压完成"
    chmod -R 775 ${clash_path}/subconverter
    export HDPASS="$(cat /proc/sys/kernel/random/uuid)"
    sed -i "s?api_access_token=.*?api_access_token=${HDPASS}?g" "${clash_path}/subconverter/pref.example.ini"
    sed -i "s?managed_config_prefix=.*?managed_config_prefix=${http_suc_ip}?g" "${clash_path}/subconverter/pref.example.ini"
    sed -i "s?listen=.*?listen=127.0.0.1?g" "${clash_path}/subconverter/pref.example.ini"
    sed -i "s?serve_file_root=.*?serve_file_root=/www/dist_web?g" "${clash_path}/subconverter/pref.example.ini"
    sed -i "s?listen =.*?listen = \"127.0.0.1\"?g" "${clash_path}/subconverter/pref.example.toml"
    sed -i "s?serve_file_root =.*?serve_file_root = \"/www/dist_web\"?g" "${clash_path}/subconverter/pref.example.toml"
  fi
  rm -rf "${clash_path}/subconverter_${ARCH_PRINT}.tar.gz"

  echo "
  [Unit]
  Description=A API For Subscription Convert
  After=network.target
    
  [Service]
  Type=simple
  ExecStart=${clash_path}/subconverter/subconverter
  WorkingDirectory=${clash_path}/subconverter
  Restart=always
  RestartSec=10
 
  [Install]
  WantedBy=multi-user.target
  " > /etc/systemd/system/subconverter.service
  sed -i 's/^[ ]*//g' /etc/systemd/system/subconverter.service
  sed -i '1d' /etc/systemd/system/subconverter.service
  chmod 755 /etc/systemd/system/subconverter.service
  sleep 2
  systemctl daemon-reload
  systemctl start subconverter
  systemctl enable subconverter

  if [[ $(lsof -i:"${HDFW_PORT}" | grep -i -c "listen") -ge "1" ]]; then
    print_ok "subconverter安装成功"
  else
    print_error "subconverter安装失败,请再次执行安装命令试试"
    exit 1
  fi
 }

function install_subweb() {
  ECHOY "正在安装sub-web服务"
  rm -fr "${clash_path}/sub-web" && git clone https://github.com/CareyWang/sub-web.git "${clash_path}/sub-web"
  if [[ $? -ne 0 ]];then
    print_error "sub-web下载失败,请再次执行安装命令试试"
    exit 1
  else
    rm -fr "${clash_path}/subweb" && git clone https://github.com/281677160/agent "${clash_path}/subweb"
    judge "sub-web补丁下载"
    chmod -R 775 ${clash_path}/sub-web
    cp -R ${clash_path}/subweb/subweb/* "${clash_path}/sub-web/"
    mv -f "${clash_path}/subweb/subweb/.env" "${clash_path}/sub-web/.env"
    rm -fr "${clash_path}/subweb"
    cd "${clash_path}/sub-web"
    sed -i "s?${after_ip}?${http_suc_ip}?g" "${clash_path}/sub-web/.env"
    sed -i "s?http://127.0.0.2:25500?https://${myurls_ip}?g" "${clash_path}/sub-web/.env"
    sed -i "s?${after_ip}?${http_suc_ip}?g" "${clash_path}/sub-web/src/views/Subconverter.vue"
    sed -i "s?http://127.0.0.2:25500?https://${myurls_ip}?g" "${clash_path}/sub-web/src/views/Subconverter.vue"
    yarn install
    yarn build
    if [[ -d "${clash_path}/sub-web/dist" ]]; then
      [[ ! -d /www/dist_web ]] && mkdir -p /www/dist_web || rm -rf /www/dist_web/*
      cp -R ${clash_path}/sub-web/dist/* /www/dist_web/
    else
      print_error "生成页面文件失败,请再次执行安装命令试试"
      exit 1
    fi
  fi
  cd "${HOME}"
  print_ok "sub-web安装完成"
}

function install_myurls() {
  ECHOY "正在安装短链程序"
  wget -P "${clash_path}" https://github.com/CareyWang/MyUrls/releases/download/v1.10/linux-amd64.tar.gz -O "${clash_path}/linux-amd64.tar.gz"
  if [[ $? -ne 0 ]];then
    print_error "myurls短链程序下载失败,请再次执行安装命令试试!"
    exit 1
  else
    print_ok "myurls短链程序下载完成"
  fi
  rm -rf "${clash_path}/myurls"
  tar -zxvf "${clash_path}/linux-amd64.tar.gz" -C "${clash_path}"
  if [[ $? -ne 0 ]];then
    print_error "myurls解压失败"
    exit 1
  else
    print_ok "myurls解压完成"
    chmod -R 777 "${clash_path}/myurls"
    sed -i "s?const backend = .*?const backend = \'https://${myurls_ip}\'?g" "${clash_path}/myurls/public/index.html"
  fi

  echo "
  [Unit]
  Description=A API For myurls Convert
  After=network.target
    
  [Service]
  Type=simple
  ExecStart=${clash_path}/myurls/linux-amd64-myurls.service -domain ${myurls_ip} -port ${DLJ_PORT}
  WorkingDirectory=${clash_path}/myurls
  Restart=always
  RestartSec=10
 
  [Install]
  WantedBy=multi-user.target
  " > /etc/systemd/system/myurls.service
  sed -i 's/^[ ]*//g' /etc/systemd/system/myurls.service
  sed -i '1d' /etc/systemd/system/myurls.service
  chmod 755 /etc/systemd/system/myurls.service
  systemctl daemon-reload
  systemctl start myurls
  systemctl enable myurls
  sleep 2
  if [[ `systemctl status myurls |grep -c "active (running) "` == '1' ]]; then
    print_ok "短链程序安装完成"
    rm -rf "${clash_path}/linux-amd64.tar.gz"
  else
    print_error "短链程序安装失败"
    exit 1
  fi
}

function nginx_conf() {
ECHOY "正在设置所有应用配置文件"
cat >"/etc/nginx/conf.d/www_nginx.conf" <<-EOF
server {
    listen  80; 
    server_name  ${www_ip} ${CUrrent_ip};
    return 301 https://\$host\$request_uri; 
}
server {
    listen 443 ssl;
    listen [::]:443 ssl;
    server_name  ${www_ip} ${CUrrent_ip};
    ssl_certificate ${clash_path}/server.crt;
    ssl_certificate_key ${clash_path}/server.key;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers TLS13-AES-256-GCM-SHA384:TLS13-CHACHA20-POLY1305-SHA256:TLS13-AES-128-GCM-SHA256:TLS13-AES-128-CCM-8-SHA256:TLS13-AES-128-CCM-SHA256:EECDH+CHACHA20:EECDH+AES128:RSA+AES128:EECDH+AES256:RSA+AES256:EECDH+3DES:RSA+3DES:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_timeout 60m;
    index index.php index.html index.htm default.php default.htm default.html;
    root /www/dist_web;
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

cat >"/etc/nginx/conf.d/suc_nginx.conf" <<-EOF
server {
    listen  80; 
    server_name  ${suc_ip};
    return 301 https://\$host\$request_uri;  
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name  ${suc_ip};
    ssl_certificate ${clash_path}/server.crt;
    ssl_certificate_key ${clash_path}/server.key;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;
    ssl_session_tickets off;
    ssl_protocols         TLSv1.2 TLSv1.3;
    ssl_ciphers           ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
   
    location / {
        proxy_pass http://127.0.0.1:${HDFW_PORT};
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header REMOTE-HOST \$remote_addr;
        add_header Access-Control-Allow-Origin *;
    }
   
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

cat >"/etc/nginx/conf.d/dl_nginx.conf" <<-EOF
server {
    listen  80; 
    server_name  ${myurls_ip};
    return 301 https://\$host\$request_uri; 
}

server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name  ${myurls_ip};
    ssl_certificate ${clash_path}/server.crt;
    ssl_certificate_key ${clash_path}/server.key;
    ssl_session_timeout 1d;
    ssl_session_cache shared:MozSSL:10m;
    ssl_session_tickets off;
    ssl_protocols         TLSv1.2 TLSv1.3;
    ssl_ciphers           ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    index index.php index.html index.htm default.php default.htm default.html;
    root /usr/local/etc/clash/myurls/public;
   
    location / {
        proxy_pass http://127.0.0.1:${DLJ_PORT};
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header REMOTE-HOST \$remote_addr;
        add_header Access-Control-Allow-Origin *;
    }
   
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
  chmod -R 755 /etc/nginx/conf.d
  systemctl restart nginx
  if [[ $? -ne 0 ]];then
    print_error "配置文件启动失败"
    exit 1
  else
    print_ok "配置文件启动成功"
    ECHOY "全部服务安装完毕,请登录 https://${www_ip} 进行使用"
  fi
}


menu2() {
  ECHOG "subconverter已存在，是否要御载subconverter[Y/n]?"
  export DUuuid="请输入[Y/y]确认或[N/n]退出"
  while :; do
  read -p " ${DUuuid}：" IDPATg
  case $IDPATg in
  [Yy])
    ECHOY "开始御载subconverter"
    systemctl stop subconverter
    systemctl disable subconverter
    systemctl daemon-reload
    rm -rf /root/subconverter
    rm -rf /root/sub-web
    rm -rf /www/dist_web
    rm -rf /etc/systemd/system/subconverter.service
    rm -rf /etc/nginx/sites-available/clash_nginx.conf
    print_ok "subconverter御载完成"
  break
  ;;
  [Nn])
   exit 1
  break
  ;;
  *)
    export DUuuid="请正确输入[Y/y]确认或[N/n]退出"
  ;;
  esac
  done
}

menu() {
  system_check
  nginx_install
  command_Version
  basic_optimization
  port_exist_check
  domain_check
  ssl_judge_and_install
  install_subconverter
  install_subweb
  install_myurls
  nginx_conf
}


menu "$@"


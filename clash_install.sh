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

if [[ ! "$USER" == "root" ]]; then
  print_error "警告：请使用root用户操作!~~"
  exit 1
fi

function system_check() {
  clear
  echo
  echo -e "\033[33m 请输入您的域名或当前服务器IP \033[0m"
  read -p " 您当前服务器IP/域名：" current_ip
  export current_ip="${current_ip}"
  export CUrrent_ip="$(echo "${current_ip}" |sed 's/http:\/\///g' |sed 's/https:\/\///g' |sed 's/www.//g' |sed 's/\///g')"
  echo -e "\033[32m 您当前服务器IP/域名为：${CUrrent_ip} \033[0m"
  export current_ip="http://${CUrrent_ip}"
  export after_ip="http://127.0.0.1"
  echo

  ECHOY "正在安装各种必须依赖"
  echo
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
    yum update -y
    yum install -y wget curl sudo git lsof tar
    wget -N -P /etc/yum.repos.d/ https://ghproxy.com/https://raw.githubusercontent.com/281677160/agent/main/xray/nginx.repo
    curl -sL https://rpm.nodesource.com/setup_12.x | bash -
    yum update -y
    yum install -y nodejs npm
    npm install -g yarn
    npm install pm2 -g
    export INS="yum install -y"
  elif [[ "$(. /etc/os-release && echo "$ID")" == "alpine" ]]; then
    echo "
    https://dl-cdn.alpinelinux.org/alpine/v3.12/main
    https://dl-cdn.alpinelinux.org/alpine/v3.12/community
    " > /etc/apk/repositories
    sed -i 's/^[ ]*//g' /etc/apk/repositories
    sed -i '/^$/d' /etc/apk/repositories
    apk update
    apk del yarn nodejs
    apk add git nodejs yarn sudo wget lsof tar npm
    npm install pm2 -g
    export INS="apk add"
  elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
    export INS="apt-get install -y"
    export UNINS="apt-get remove -y"
    export PUBKEY="ubuntu"
    nodejs_install
  elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
    export INS="apt install -y"
    export UNINS="apt remove -y"
    export PUBKEY="debian"
    nodejs_install
  else
    echo -e "\033[31m 不支持该系统 \033[0m"
    exit 1
  fi
}

function nodejs_install() {
    apt update
    ${INS} curl wget sudo git lsof tar lsb-release gnupg2
    ${UNINS} --purge npm
    ${UNINS} --purge nodejs
    ${UNINS} --purge nodejs-legacy
    apt autoremove -y
    curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
    ${UNINS} cmdtest
    ${UNINS} yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    rm -f /etc/apt/sources.list.d/nginx.list
    echo "deb http://nginx.org/packages/${PUBKEY} $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
    apt-get update
    ${INS} nodejs yarn npm
    npm install pm2 -g
}

function nginx_install() {
  if ! command -v nginx >/dev/null 2>&1; then
    ${INS} nginx
  else
    print_ok "Nginx 已存在"
    ${INS} nginx
  fi
  
  if [[ -d /etc/nginx/sites-available ]]; then
    sub_path="/etc/nginx/sites-available/${CUrrent_ip}.conf"
  elif [[ -d /etc/nginx/http.d ]]; then  
    sub_path="/etc/nginx/http.d/${CUrrent_ip}.conf"
  else
    mkdir -p /etc/nginx/conf.d >/dev/null 2>&1
    sub_path="/etc/nginx/conf.d/${CUrrent_ip}.conf"
  fi
cat >"${sub_path}" <<-EOF
server {
    listen 80;
    server_name ${CUrrent_ip};

    root /www/dist;
    index index.html index.htm;

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
}
EOF
  if [[ "$(. /etc/os-release && echo "$ID")" == "alpine" ]]; then
    service nginx restart
    rc-update add nginx boot
  else
    systemctl start nginx
    systemctl enable nginx
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
}

function port_exist_check() {
  if [[ 0 -eq $(lsof -i:"25500" | grep -i -c "listen") ]]; then
    print_ok "25500 端口未被占用"
    sleep 1
  else
    ECHOR "检测到 25500 端口被占用，以下为 25500 端口占用信息"
    lsof -i:"25500"
    ECHOR "5s 后将尝试自动清理占用进程"
    sleep 5
    lsof -i:"25500" | awk '{print $2}' | grep -v "PID" | xargs kill -9
    print_ok "25500端口占用进程清理完成"
    sleep 1
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
  wget https://ghproxy.com/https://github.com/tindy2013/subconverter/releases/download/${latest_vers}/subconverter_linux64.tar.gz
  if [[ $? -ne 0 ]];then
    echo -e "\033[31m subconverter下载失败! \033[0m"
    exit 1
  fi
  tar -zxvf subconverter_linux64.tar.gz
  if [[ $? -ne 0 ]];then
    echo -e "\033[31m subconverter解压失败! \033[0m"
    exit 1
  else
    echo -e "\033[32m subconverter解压成功! \033[0m"
    export HDPASS="$(cat /proc/sys/kernel/random/uuid)"
    sed -i "s?${after_ip}?${current_ip}?g" "/root/subconverter/pref.example.ini"
    sed -i "s?api_access_token=password?api_access_token=${HDPASS}?g" "/root/subconverter/pref.example.ini"
    sed -i "s?0.0.0.0?127.0.0.1?g" "/root/subconverter/pref.example.ini"
    sed -i "s?0.0.0.0?127.0.0.1?g" "/root/subconverter/pref.example.toml"
  fi
  rm -rf "/root/subconverter_linux64.tar.gz"
  if [[ "$(. /etc/os-release && echo "$ID")" == "alpine" ]]; then
    nohup /root/subconverter/./subconverter >/dev/null 2>&1 &
    sed -i '/subconverter/d' "/etc/crontabs/root"
    echo "@reboot nohup /root/subconverter/./subconverter >/dev/null 2>&1 &" >> "/etc/crontabs/root"
    sed -i '/^$/d' "/etc/crontabs/root"
    sleep 3
    if [[ $(lsof -i:"25500" | grep -i -c "listen") -ge "1" ]]; then
      print_ok "subconverter安装成功"
    else
      print_error "subconverter安装失败,请再次执行安装命令试试"
      exit 1
    fi
  else
cat >/etc/systemd/system/subconverter.service <<-EOF
[Unit]
Description=subconverter
Documentation=https://github.com/tindy2013/subconverter
After=network.target
Wants=network.target
[Service]
WorkingDirectory=/root/subconverter
ExecStart=/root/subconverter/subconverter
Restart=on-abnormal
RestartSec=5s
KillMode=mixed
StandardOutput=null
StandardError=syslog
[Install]
WantedBy=multi-user.target
EOF
    chmod 775 /etc/systemd/system/subconverter.service
    systemctl daemon-reload
    systemctl start subconverter
    systemctl enable subconverter
    if [[ `systemctl status subconverter |grep -c "active (running) "` == '1' ]]; then
      print_ok "subconverter安装成功"
    else
      print_error "subconverter安装失败"
      exit 1
    fi
  fi
}

function install_subweb() {
  ECHOY "正在安装sub-web服务"
  rm -fr sub-web && git clone https://ghproxy.com/https://github.com/CareyWang/sub-web.git sub-web
  if [[ $? -ne 0 ]];then
    echo -e "\033[31m sub-web下载失败,请再次执行安装命令试试! \033[0m"
    exit 1
  else
    wget -q https://ghproxy.com/https://raw.githubusercontent.com/281677160/agent/main/Subconverter.vue -O /root/sub-web/src/views/Subconverter.vue
    if [[ $? -ne 0 ]]; then
      curl -fsSL https://cdn.jsdelivr.net/gh/281677160/agent@main/Subconverter.vue > "/root/sub-web/src/views/Subconverter.vue"
    fi
    wget -q https://ghproxy.com/https://raw.githubusercontent.com/281677160/agent/main/xray/clsah.env -O /root/sub-web/.env
    if [[ $? -ne 0 ]]; then
      curl -fsSL https://cdn.jsdelivr.net/gh/281677160/agent@main/xray/clsah.env > "/root/sub-web/.env"
    fi
    cd sub-web
    sed -i "s?${after_ip}?${current_ip}?g" "/root/sub-web/.env"
    sed -i "s?${after_ip}?${current_ip}?g" "/root/sub-web/src/views/Subconverter.vue"
    yarn install
    yarn build
    if [[ -d /root/sub-web/dist ]]; then
      [[ ! -d /www/dist ]] && mkdir -p /www/dist || rm -rf /www/dist/*
      cp -R /root/sub-web/dist/* /www/dist/
    else
      print_error "生成页面文件失败,请再次执行安装命令试试"
      exit 1
    fi
  fi

  print_ok "sub-web安装完成"
    
  ECHOY "全部服务安装完毕,请登录 ${current_ip} 进行使用"
}

menu() {
  system_check
  nginx_install
  command_Version
  port_exist_check
  install_subconverter
  install_subweb
}
menu "$@"

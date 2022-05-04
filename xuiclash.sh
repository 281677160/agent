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
if [[ `dpkg --print-architecture |grep -c "amd64"` == '1' ]]; then
  export ARCH_PRINT="linux64"
elif [[ `dpkg --print-architecture |grep -c "arm64"` == '1' ]]; then
  export ARCH_PRINT="aarch64"
else
  print_error "不支持此系统,只支持x86_64的ubuntu和arm64的ubuntu"
  exit 1
fi

function system_check() {

  ECHOY "正在安装clash节点转换"
  echo
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
    curl -sL https://rpm.nodesource.com/setup_12.x | bash -
    sed -i 's/^SELINUX=.*/SELINUX=disabled/' /etc/selinux/config
    setenforce 0
    yum update -y
    yum install -y nodejs
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
}

function nodejs_install() {
    apt update
    ${UNINS} --purge npm
    ${UNINS} --purge nodejs
    ${UNINS} --purge nodejs-legacy
    apt autoremove -y
    curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
    ${UNINS} cmdtest
    ${UNINS} yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    apt-get update
    ${INS} nodejs yarn
}

function nginx_install() {
  if [[ -d /etc/nginx/sites-available ]]; then
    sub_path="/etc/nginx/sites-available/clash_nginx.conf"
  elif [[ -d /etc/nginx/http.d ]]; then  
    sub_path="/etc/nginx/http.d/clash_nginx.conf"
  else
    mkdir -p /etc/nginx/conf.d >/dev/null 2>&1
    sub_path="/etc/nginx/conf.d/clash_nginx.conf"
  fi
cat >"${sub_path}" <<-EOF
server {
    listen 80;
    server_name ${CUrrent_ip};

    root /www/dist_web;
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
service nginx restart
judge "nginx更新配置"
systemctl enable nginx
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
  rm -rf "/root/subconverter_${ARCH_PRINT}.tar.gz" >/dev/null 2>&1
  wget https://ghproxy.com/https://github.com/tindy2013/subconverter/releases/download/${latest_vers}/subconverter_${ARCH_PRINT}.tar.gz
  if [[ $? -ne 0 ]];then
    echo -e "\033[31m subconverter下载失败! \033[0m"
    exit 1
  fi
  tar -zxvf subconverter_${ARCH_PRINT}.tar.gz
  if [[ $? -ne 0 ]];then
    echo -e "\033[31m subconverter解压失败! \033[0m"
    exit 1
  else
    echo -e "\033[32m subconverter解压成功! \033[0m"
    cp /root/subconverter/pref.example.ini /root/subconverter/pref.ini
    export HDPASS="$(cat /proc/sys/kernel/random/uuid)"
    sed -i "s?${after_ip}?${current_ip}?g" "/root/subconverter/pref.ini"
    sed -i "s?api_access_token=password?api_access_token=${HDPASS}?g" "/root/subconverter/pref.ini"
  fi
  rm -rf "/root/subconverter_${ARCH_PRINT}.tar.gz"
  echo "${latest_vers}" >/root/subconverter/subconverter_vers
 }

function update_rc() {
  echo '
  [Unit]
  Description=A API For Subscription Convert
  After=network.target
    
  [Service]
  Type=simple
  ExecStart=/root/subconverter/subconverter
  WorkingDirectory=/root/subconverter
  Restart=always
  RestartSec=10
 
  [Install]
  WantedBy=multi-user.target
  ' > /etc/systemd/system/subconverter.service
  sed -i 's/^[ ]*//g' /etc/systemd/system/subconverter.service
  sed -i '1d' /etc/systemd/system/subconverter.service
  chmod 755 /etc/systemd/system/subconverter.service
  sleep 2
  systemctl daemon-reload
  systemctl start subconverter
  systemctl enable subconverter
  if [[ $(lsof -i:"25500" | grep -i -c "listen") -ge "1" ]]; then
    print_ok "subconverter安装成功"
  else
    print_error "subconverter安装失败,请再次执行安装命令试试"
    exit 1
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
      [[ ! -d /www/dist_web ]] && mkdir -p /www/dist_web || rm -rf /www/dist_web/*
      cp -R /root/sub-web/dist/* /www/dist_web/
    else
      print_error "生成页面文件失败,请再次执行安装命令试试"
      exit 1
    fi
  fi

  print_ok "sub-web安装完成"
}

menu() {
  system_check
  nginx_install
  command_Version
  port_exist_check
  install_subconverter
  update_rc
  install_subweb
}
menu "$@"

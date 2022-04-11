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
  echo -e " ${OK} ${Blue} $1 ${Font}"
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
  echo -e "\033[33m 请输入您当前服务器IP[比如：192.168.2.1] \033[0m"
  read -p " 您当前服务器IP：" wzym
  export wzym="${wzym}"
  echo -e "\033[32m 您当前服务器IP为：${wzym} \033[0m"
  echo

  ECHOY "正在安装各种必须依赖"
  echo
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
    curl -sL https://rpm.nodesource.com/setup_12.x | bash -
    yum install -y nodejs wget sudo git npm
    npm install -g yarn
  elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
    apt-get update
    apt install -y curl wget sudo nginx git
    apt-get remove -y --purge npm
    apt-get remove -y --purge nodejs
    apt-get remove -y --purge nodejs-legacy
    apt-get autoremove -y
    curl -sL https://deb.nodesource.com/setup_12.x | sudo -E bash -
    apt-get install -y nodejs
    apt remove -y cmdtest
    apt remove -y yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    apt-get update && apt-get install -y yarn
  elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
    apt update
    apt install -y curl wget sudo nginx git
    apt remove -y --purge npm
    apt remove -y --purge nodejs
    apt remove -y --purge nodejs-legacy
    apt autoremove -y
    curl -sL https://deb.nodesource.com/setup_12.x | sudo bash -
    apt install -y nodejs
    apt remove -y cmdtest
    apt remove -y yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    apt-get update && apt-get install -y yarn
  else
    echo -e "\033[31m 不支持该系统 \033[0m"
    exit 1
  fi

  if [[ ! -x "$(command -v node)" ]]; then
    echo -e "\033[31m node安装失败! \033[0m"
    exit 1
  else
    node_version="$(node --version |egrep -o 'v[0-9]+\.[0-9]+\.[0-9]+')"
    echo -e "\033[32m node安装成功! \033[0m"
    echo "node版本号为：${node_version}"
  fi
  if [[ ! -x "$(command -v yarn)" ]]; then
    echo -e "\033[31m yarn安装失败! \033[0m"
    exit 1
  else
    yarn_version="$(yarn --version |egrep -o '[0-9]+\.[0-9]+\.[0-9]+')"
    echo -e "\033[32m yarn安装成功! \033[0m"
    echo "yarn版本号为：${node_version}"
  fi
  
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
    yum remove -y nginx
    find / -iname 'nginx' | xargs -i rm -rf {}
    yum install -y nginx
    judge "Nginx 安装"
    nginxVersion="$(nginx -v 2>&1)" && NGINX_VERSION="$(echo ${nginxVersion#*/})"
    echo "Nginx版本号为：${NGINX_VERSION}"
  else
    apt-get --purge remove -y nginx
    apt-get autoremove -y
    apt-get --purge remove -y nginx
    apt-get --purge remove -y nginx-common
    apt-get --purge remove -y nginx-core
    find / -iname 'nginx' | xargs -i rm -rf {}
    apt-get install -y nginx
    judge "Nginx 安装"
    nginxVersion="$(nginx -v 2>&1)" && NGINX_VERSION="$(echo ${nginxVersion#*/})"
    echo "Nginx版本号为：${NGINX_VERSION}"
  fi
} 

function system_docker() {
  if [[ ! -x "$(command -v docker)" ]]; then
    print_error "没检测到docker，正在安装docker"
    bash -c "$(curl -fsSL https://cdn.jsdelivr.net/gh/281677160/ql@main/docker.sh)"
  fi
}

function systemctl_status() {
  echo
  if [[ "${XTong}" == "openwrt" ]]; then
    /etc/init.d/dockerman start > /dev/null 2>&1
    /etc/init.d/dockerd start > /dev/null 2>&1
    sleep 3
  elif [[ "$(. /etc/os-release && echo "$ID")" == "alpine" ]]; then
    service docker start > /dev/null 2>&1
    sleep 1
    if [[ `docker version |grep -c "runc"` == '1' ]]; then
      print_ok "docker正在运行中!"
    else
      print_error "docker没有启动，请先启动docker，或者检查一下是否安装失败"
      sleep 1
      exit 1
    fi
  else
    systemctl start docker > /dev/null 2>&1
    sleep 1
    echo
    ECHOGG "检测docker是否在运行"
    if [[ `systemctl status docker |grep -c "active (running) "` == '1' ]]; then
      print_ok "docker正在运行中!"
    else
      print_error "docker没有启动，请先启动docker，或者检查一下是否安装失败"
      sleep 1
      exit 1
    fi
  fi
}

function install_subconverter() {
  find / -iname 'subconverter' | xargs -i rm -rf {}
  if [[ `docker images | grep -c "subconverter"` -ge '1' ]] || [[ `docker ps -a | grep -c "subconverter"` -ge '1' ]]; then
    ECHOY "检测到subconverter服务存在，正在御载subconverter服务，请稍后..."
    docker=$(docker ps -a|grep subconverter) && dockerid=$(awk '{print $(1)}' <<<${docker})
    images=$(docker images|grep subconverter) && imagesid=$(awk '{print $(3)}' <<<${images})
    docker stop -t=5 "${dockerid}" > /dev/null 2>&1
    docker rm "${dockerid}"
    docker rmi "${imagesid}"
    if [[ `docker ps -a | grep -c "subconverter"` == '0' ]] && [[ `docker images | grep -c "qinglong"` == '0' ]]; then
      print_ok "subconverter御载完成"
    else
      print_error "subconverter御载失败"
      exit 1
    fi
  fi
  ECHOY "正在安装subconverter服务"
  docker run -d --restart=always -p 25500:25500 tindy2013/subconverter:latest
  if [[ `docker images | grep -c "subconverter"` -ge '1' ]] && [[ `docker ps -a | grep -c "subconverter"` -ge '1' ]]; then
    print_ok "subconverter安装完成"
  else
    print_error "subconverter安装失败"
    exit 1
  fi
}

function install_subweb() {
ECHOY "正在安装sub-web服务"
  rm -fr sub-web && git clone https://ghproxy.com/https://github.com/CareyWang/sub-web.git sub-web
  if [[ $? -ne 0 ]];then
    echo -e "\033[31m sub-web下载失败! \033[0m"
    exit 1
  else
    cd sub-web
    sed -i "s?https://api.wcc.best?http://${wzym}:25500?g" "/root/sub-web/.env"
    sed -i "s?http://127.0.0.1:25500/sub?http://${wzym}:25500/sub?g" "/root/sub-web/src/views/Subconverter.vue"
    yarn install
    yarn build
    if [[ -d /root/sub-web/dist ]]; then
      [[ ! -d /www/dist ]] && mkdir -p /www/dist || rm -rf /www/dist/*
      cp -R /root/sub-web/dist/* /www/dist/
    else
      print_error "生成页面文件失败"
      exit 1
    fi
  fi

  if [[ -f /etc/nginx/sites-available/default ]]; then
    sub_path="/etc/nginx/sites-available/default"
  else
    sub_path="/etc/nginx/conf.d/${wzym}.conf"
  fi
cat >${sub_path} <<-EOF
server {
    listen 80;
    server_name localhost;

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
  systemctl restart nginx
  print_ok "sub-web安装完成"
}

menu() {
  system_check
  system_docker
  systemctl_status
  install_subconverter
  install_subweb
}
menu "$@"

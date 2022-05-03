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
github_branch="main"
xray_conf_dir="/usr/local/x-ui"
website_dir="/www/xray_web/"
xray_access_log="/var/log/xray/access.log"
xray_error_log="/var/log/xray/error.log"
cert_dir="/usr/local/x-ui"
domain_tmp_dir="/usr/local/x-ui"
cert_group="nobody"
random_num=$((RANDOM % 12 + 4))
HOME="/root"

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

function is_root() {
if [[ ! "$USER" == "root" ]]; then
  print_error "警告：请使用root用户操作!~~"
  exit 1
fi
if [[ `dpkg --print-architecture |grep -c "amd64"` == '1' ]]; then
  export ARCH_PRINT="amd64"
elif [[ `dpkg --print-architecture |grep -c "arm64"` == '1' ]]; then
  export ARCH_PRINT="arm64"
else
  print_error "不支持此系统,只支持x86_64的ubuntu和arm64的ubuntu"
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
  if [[ `command -v x-ui |grep -c "x-ui"` == '0' ]]; then
    export XUI_ZT="${Blue} x-ui状态${Font}：${Red}未安装${Font}"
  elif [[ `systemctl status x-ui |grep -c "active (running) "` == '1' ]]; then
    export XUI_ZT="${Blue} x-ui状态${Font}：${Green}运行中 ${Font}|${Blue} 版本${Font}：${Green}v0.3.2${Font}"
  elif [[ `command -v x-ui |grep -c "x-ui"` -ge '1' ]] && [[ `systemctl status cloudreve |grep -c "active (running) "` == '0' ]]; then
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

function system_check() {
  source '/etc/os-release'

  if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]]; then
    print_ok "当前系统为 Centos ${VERSION_ID} ${VERSION}"
    export INS="yum install -y"
    ${INS} socat wget git sudo ca-certificates && update-ca-trust force-enable
    wget -N -P /etc/yum.repos.d/ https://raw.githubusercontent.com/281677160/agent/main/xray/nginx.repo
  elif [[ "${ID}" == "ol" ]]; then
    print_ok "当前系统为 Oracle Linux ${VERSION_ID} ${VERSION}"
    export INS="yum install -y"
    ${INS} wget git sudo
    wget -N -P /etc/yum.repos.d/ https://raw.githubusercontent.com/281677160/agent/main/xray/nginx.repo
  elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
    print_ok "当前系统为 Debian ${VERSION_ID} ${VERSION}"
    export INS="apt install -y"
    ${INS} socat wget git sudo ca-certificates && update-ca-certificates
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    $INS lsb-release gnupg2

    echo "deb http://nginx.org/packages/debian $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

    apt update
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 18 ]]; then
    print_ok "当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME}"
    export INS="apt install -y"
    ${INS} socat wget git sudo ca-certificates && update-ca-certificatesgit
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

function kaishi_install() {
  echo
  echo
  export YUMING="请输入您的域名"
  ECHOY "${YUMING}[比如：v2.xray.com]"
  while :; do
  read -p " ${YUMING}：" domain
  if [[ -n "${domain}" ]] && [[ "$(echo ${domain} |grep -c '\.')" -ge '1' ]]; then
    export domainy="Y"
  fi
  case $domainy in
  Y)
    export domain="${domain}"
  break
  ;;
  *)
    export YUMING="敬告：请输入正确的域名"
  ;;
  esac
  done
  echo
  ECHOY "请输入面板帐号,直接回车则使用 admin"
  read -p " 请输入帐号：" config_account
  export config_account=${config_account:-"admin"}
  
  echo
  ECHOY "请输入面板密码,直接回车则使用 admin"
  read -p " 请输入密码：" config_password
  export config_password=${config_password:-"admin"}
  
  echo
  ECHOY "请输入面板端口,直接回车则使用 54321"
  read -p " 请输入密码：" config_port
  export config_port=${config_port:-"54321"}
  
  echo
  ECHOY "请输入面板根路径,前面要带 “/” 符号,直接回车则使用 /xui"
  read -p " 请输入密码：" config_web
  export config_web=${config_web:-"admin"}
  
  
  ECHOG "您的域名为：${domain}"
  ECHOG "面板帐号为：${config_account}"
  ECHOG "面板密码为：${config_password}"
  ECHOG "面板根路径为：${config_web}"
  echo
  read -p " [检查是否正确,正确回车继续,不正确按Q回车重新输入]： " NNKC
  case $NNKC in
  [Qq])
    install_xui
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
}

function nginx_install() {
  if ! command -v nginx >/dev/null 2>&1; then
    ${INS} nginx
    judge "Nginx 安装"
  else
    print_ok "Nginx 已存在"
    ${INS} nginx
  fi
  # 遗留问题处理
  mkdir -p /etc/nginx/conf.d >/dev/null 2>&1
}
function dependency_install() {
  ${INS} lsof tar
  judge "安装 lsof tar"

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

  ${INS} jq

  if ! command -v jq; then
    wget -P /usr/bin https://raw.githubusercontent.com/281677160/agent/main/xray/jq && chmod +x /usr/bin/jq
    judge "安装 jq"
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
  latest_ver="$(wget -qO- -t1 -T2 "https://api.github.com/repos/vaxilu/x-ui/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')"
  wget -q -P /root https://ghproxy.com/https://github.com/vaxilu/x-ui/releases/download/${latest_ver}/x-ui-linux-${ARCH_PRINT}.tar.gz -O /root/x-ui-linux-${ARCH_PRINT}.tar.gz
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
  rm -rf /root/x-ui-linux-${ARCH_PRINT}.tar.gz
}

function generate_certificate() {
  /usr/local/x-ui/x-ui setting -username ${config_account} -password ${config_password}
  /usr/local/x-ui/x-ui setting -port ${config_port}
}

function ssl_judge_and_install() {
  if [[ -f "$HOME/.acme.sh/${domain}_ecc/${domain}.key" && -f "$HOME/.acme.sh/${domain}_ecc/${domain}.cer" && -f "$HOME/.acme.sh/acme.sh" ]]; then
    print_ok "[${domain}]证书已存在，重新启用证书"
    [[ ! -d /ssl ]] && mkdir -p /ssl || rm -fr /ssl/*
    [[ ! -f "/usr/bin/acme.sh" ]] && ln -s  /root/.acme.sh/acme.sh /usr/bin/acme.sh
    acme.sh --installcert -d "${domain}" --ecc  --key-file   /ssl/xray.key   --fullchain-file /ssl/xray.crt
    judge "证书启用"
    chown -R nobody.$cert_group /ssl/*
    sleep 2
    .acme.sh/acme.sh --upgrade --auto-upgrade
    echo "domain=${domain}" > "${domainjilu}"
    echo -e "\nPORT=${PORT}" >> "${domainjilu}"
    judge "域名记录"
  else
    rm -rf /ssl/* > /dev/null 2>&1
    rm -fr "$HOME"/.acme.sh > /dev/null 2>&1
    acme
  fi
}

function acme() {
  curl -L https://get.acme.sh | sh
  judge "安装acme.sh脚本"
  [[ ! -f "/usr/bin/acme.sh" ]] && ln -s  /root/.acme.sh/acme.sh /usr/bin/acme.sh
  acme.sh --set-default-ca --server letsencrypt
  systemctl stop nginx
  if acme.sh  --issue -d "${domain}"  --standalone -k ec-256; then
    print_ok "SSL 证书生成成功"
    sleep 2
    if acme.sh --installcert -d "${domain}" --ecc  --key-file   /ssl/xray.key   --fullchain-file /ssl/xray.crt; then
      print_ok "SSL 证书配置成功"
      chown -R nobody.$cert_group /ssl/*
      systemctl start nginx
      acme.sh  --upgrade  --auto-upgrade
      echo "domain=${domain}" > "${domainjilu}"
      echo -e "\nPORT=${PORT}" >> "${domainjilu}"
      judge "域名记录"
    fi
  else
    systemctl start nginx
    print_error "SSL 证书生成失败"
    rm -rf "$HOME/.acme.sh/${domain}_ecc"
    exit 1
  fi
}

function configure_nginx() {
  bash -c "$(curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/xray/xui.conf)"
  systemctl restart nginx
  judge "Nginx 配置 修改"
}

function configure_cloudreve() {
  [[ ! -d "${cloudreve_service}" ]] && mkdir -p "${cloudreve_service}"
  [[ ! -d "${cloudreve_path}" ]] && mkdir -p "${cloudreve_path}"
  latest_ver="$(wget -qO- -t1 -T2 "https://api.github.com/repos/cloudreve/Cloudreve/releases/latest" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')"
  cd "${cloudreve_path}"
  echo "${latest_ver}" > latest_ver
  wget -q -P "${cloudreve_path}" https://github.com/cloudreve/Cloudreve/releases/download/${latest_ver}/cloudreve_${latest_ver}_linux_${ARCH_PRINT}.tar.gz -O "${cloudreve_path}"/cloudreve_${latest_ver}_linux_${ARCH_PRINT}.tar.gz
  judge "cloudreve下载"
  sleep 1
  tar xzf cloudreve_${latest_ver}_linux_${ARCH_PRINT}.tar.gz -C "${cloudreve_path}"
  judge "cloudreve解压"
  sleep 1
  rm -fr "${cloudreve_path}"/cloudreve_${latest_ver}_linux_${ARCH_PRINT}.tar.gz
  chmod +x ./cloudreve
  timeout -k 1s 15s ./cloudreve |tee build.log
  print_ok "cloudreve安装 完成"
  Passwd="$(cat ${cloudreve_path}/build.log | grep "初始管理员密码：" | awk '{print $4}')"
  sleep 2
cat >"${cloudreve_service}"/cloudreve.service <<-EOF
[Unit]
Description=Cloudreve
Documentation=https://docs.cloudreve.org
After=network.target
Wants=network.target
[Service]
WorkingDirectory=${cloudreve_path}
ExecStart=${cloudreve_path}/cloudreve
Restart=on-abnormal
RestartSec=5s
KillMode=mixed
StandardOutput=null
StandardError=syslog
[Install]
WantedBy=multi-user.target
EOF
  cd "$HOME"
  chmod 775 "${cloudreve_service}"/cloudreve.service
  systemctl daemon-reload
  systemctl start cloudreve
  systemctl enable cloudreve
}

function restart_all() {
  x-ui enable
  restart_xui
  curl -fsSL https://raw.githubusercontent.com/281677160/agent/main/x-ui.sh > "/usr/bin/glxray"
  chmod 777 "/usr/bin/glxray"
  echo
  ECHOY "1、用浏览器打开此链接： http://${local_ip}:${config_port}"
  ECHOY "2、然后用您设置的帐号密码登录面板，然后把面板根目录修改成 ${config_web}"
  ECHOY "3、根目录路径修改完成,报错设置,重启面板后可以用 https://${domain}${config_web} 访问"
  echo
  ECHOG "友情提示：再次输入安装命令或者输入[glxray]命令可以对程序进行管理"
  cat >/ssl/conck <<-EOF
  echo -e "\033[32m面板证书公钥文件路径：\033[0m/ssl/xray.crt"
  echo -e "\033[32m面板证书密钥文件路径：\033[0m/ssl/xray.key"
EOF
  echo
  echo
  echo -e "\033[31m 请注意：以下[cloudreve云盘]操作必须完成  \033[0m"
  echo
  ECHOY "1、用浏览器打开此链接： https://${domain}"
  ECHOY "2、初始管理员账号：admin@cloudreve.org"
  ECHOY "3、${Passwd}"
  ECHOY "4、点击右上角头像 -> 管理面板"
  ECHOY "5、点击[管理面板]会弹出对话框 \"确定站点URL设置\" 必须选择 \"更改\""
  ECHOY "6、左侧 -> 参数设置 -> 注册与登陆 -> 不允许新用户注册 -> 往下拉点击保存"
  ECHOY "7、左侧 -> 用户 -> 新建用户 -> 添加一个新的管理员，用于自己登录所用"
  echo
  echo
}

function restart_xui() {
  systemctl restart nginx
  x-ui restart
  sleep 1
  if [[ `systemctl status nginx |grep -c "active (running) "` == '1' ]]; then
    print_ok "nginx运行 正常"
  else
    print_error "nginx没有运行"
    exit 1
  fi
  if [[ `systemctl status x-ui |grep -c "active (running) "` == '1' ]]; then
    print_ok "x-ui运行 正常"
  else
    print_error "x-ui没有运行"
    exit 1
  fi
}

function xui_uninstall() {
  x-ui stop
  x-ui disable
  x-ui uninstall
  find / -iname 'x-ui' | xargs -i rm -rf {}
  print_ok "x-ui面板御载 完成"
  sleep 2
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]] || [[ "$(. /etc/os-release && echo "$ID")" == "ol" ]]; then
    yum remove nginx -y
  else
    apt-get --purge remove -y nginx
    apt-get autoremove -y
    apt-get --purge remove -y nginx
    apt-get --purge remove -y nginx-common
    apt-get --purge remove -y nginx-core
  fi
  find / -iname 'nginx' | xargs -i rm -rf {}
  print_ok "nginx御载 完成"
  sleep 2
  if [[ -d "$HOME"/.acme.sh ]]; then
    clear
    echo
    [[ -f "$HOME/.acme.sh/domainjilu" ]] && PROFILE="$(cat $HOME/.acme.sh/domainjilu)"
    if [[ -f "$HOME/.acme.sh/${PROFILE}_ecc/${PROFILE}.cer" ]] && [[ -f "$HOME/.acme.sh/${PROFILE}_ecc/${PROFILE}.key" ]]; then
        export TISHI="提示：[ ${PROFILE} ]证书已经存在,如果还继续使用此域名建议勿删除.acme.sh"
     else
        export WUTISHI="Y"
     fi
     if [[ ${WUTISHI} == "Y" ]]; then
        "$HOME"/.acme.sh/acme.sh --uninstall
        rm -rf $HOME/.acme.sh
        rm -rf /ssl/*
        sed -i '/acme.sh/d' /root/.bashrc > /dev/null 2>&1
        sed -i '/acme.sh/d' /root/.cshrc > /dev/null 2>&1
        sed -i '/acme.sh/d' /root/.tcshrc > /dev/null 2>&1
      else
        ECHOY "是否卸载 acme.sh [Y/N]?"
        echo
        ECHOY "${TISHI}"
        echo
        read -p " 输入您的选择：" uninstall_acme
        case $uninstall_acme in
        [yY])
           "$HOME"/.acme.sh/acme.sh --uninstall
           rm -rf "$HOME"/.acme.sh
           rm -rf /ssl/*
           sed -i '/acme.sh/d' /root/.bashrc > /dev/null 2>&1
           sed -i '/acme.sh/d' /root/.cshrc > /dev/null 2>&1
           sed -i '/acme.sh/d' /root/.tcshrc > /dev/null 2>&1
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
  kaishi_install
  system_check
  dependency_install
  basic_optimization
  domain_check
  port_exist_check 80
  xui_install
  nginx_install
  generate_certificate
  ssl_judge_and_install
  configure_nginx
  configure_cloudreve
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
  ECHOY "1、安装 x-ui面板和nginx"
  ECHOY "2、重启 x-ui面板和nginx"
  ECHOY "3、查询 证书路径"
  ECHOY "4、安装 BBR、锐速加速"
  ECHOY "5、卸载 x-ui面板和nginx"
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
    [[ -f /ssl/conck ]] && source /ssl/conck || ECHOY "无此文件或者没有证书"
    break
    ;;
  4)
    wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
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

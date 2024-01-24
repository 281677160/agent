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

clash_path="/usr/local/etc/clash"
cert_group="nobody"
random_num=$((RANDOM % 12 + 4))
HOME="/root"
domainclash="/root/.acme.sh/domainclash"
HDFW_PORT="25500"
DLJ_PORT="8002"
arch=$(arch)

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

  echo
  echo
  ECHOG "请选择订阅转换格式服务程序"
  echo
  ECHOY " 1. tindy2013/subconverter(原版订阅转换格式服务程序)"
  echo
  ECHOY " 2. MetaCubeX/subconverter(原版基础上改版订阅转换格式服务程序)"
  echo
  XUANZHEOR=" 请输入数字选择"
  while :; do
  read -p " ${XUANZHEOR}： " CHOOSEDNS
  case $SUB_CONVER in
    1)
      export subconv_erter="tindy2013"
      export SUB_service="原版订阅转换服务程序"
    break
    ;;
    2)
      export subconv_erter="MetaCubeX"
      export SUB_service="原版基础上的改版订阅转换服务程序"
    break
    ;;
    *)
      XUANZHEOR=" 请输入正确的数字编号!"
    ;;
    esac
    done
  
  echo
  echo
  ECHOG "您选择的域名托管商为${service_name}"
  echo
  ECHOG "您选择的订阅转换服务程序为${SUB_service}"
  echo
  echo
  read -p " [检查是否正确,正确回车继续,不正确按Q回车重新输入]： " NNKC
  case $NNKC in
  [Qq])
    DNS_service_provider
  ;;
  *)
    echo
  ;;
  esac
}

function DNS_provider() {
  echo
  echo
  CF_domain=""
  if [[ -f "${domainclash}" ]]; then
    PROFIXI="$(grep 'domain=' ${domainclash} | cut -d "=" -f2)"
    CFKEYXI="$(grep "${DNS_KEY}=" ${domainclash} | cut -d "=" -f2)"
    EMAILXI="$(grep "${DNS_ID}=" ${domainclash} | cut -d "=" -f2)"
  fi
  echo -e "\033[33m 请输入${service_name}解析好泛域名的域名，比如：clash.com] \033[0m"
  export YUMINGIP="请输入"
  while :; do
  CUrrenty=""
  read -p " ${YUMINGIP}：" CUrrent_ip
  if [[ -n "${CUrrent_ip}" ]] && [[ "$(echo ${CUrrent_ip} |grep -c '\.')" -ge '1' ]]; then
    CUrrenty="Y"
  fi
  case $CUrrenty in
  Y)
    export CUrrent_ip="$(echo "${CUrrent_ip}" |sed 's/http:\/\///g' |sed 's/https:\/\///g' |sed 's/www.//g' |sed 's/\///g' |sed 's/ //g')"
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
  if [[ "${CFKEYXI}" == "${DNS_KEY}_xx" ]] && [[ "${EMAILXI}" == "${DNS_ID}_xx" ]] && [[ -f "/root/.acme.sh/${domain}_ecc/${domain}.key" ]]; then
    export CF_domain="1"
  else
    echo
    echo
    export CF_domain="0"
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
  echo
  if [[ "${CF_domain}" == "1" ]]; then
    ECHOG "您的域名为：${domain} 证书已存在"
  else 
    ECHOG "您的域名为：${domain}"
    ECHOG "${DNS_SM3}为：${DNS_KEYy}"
    ECHOG "${DNS_SM4}为：${DNS_IDd}"
  fi
  echo
  read -p " [检查是否正确,正确回车继续,不正确按Q回车重新输入]： " NNKC
  case $NNKC in
  [Qq])
    DNS_provider
  ;;
  *)
    echo
    print_ok "您已确认无误!"
  ;;
  esac
  echo
  ECHOY "开始执行安装程序,请耐心等候..."
  [[ ! -d "${clash_path}" ]] && mkdir -p "${clash_path}"
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
    curl -sL https://rpm.nodesource.com/setup_16.x | bash -
    curl --silent --location https://dl.yarnpkg.com/rpm/yarn.repo | sudo tee /etc/yum.repos.d/yarn.repo
    sudo rpm --import https://dl.yarnpkg.com/rpm/pubkey.gpg
    wget -N -P /etc/yum.repos.d/ https://raw.githubusercontent.com/281677160/agent/main/xray/nginx.repo
    ${INS} wget curl git sudo redis ca-certificates && update-ca-trust force-enable
  elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
    print_ok "当前系统为 Debian ${VERSION_ID} ${VERSION}"
    export INS="apt install -y"
    export UNINS="apt"
    apt update
    ${INS} wget curl git sudo redis-server ca-certificates && update-ca-certificates
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list
    $INS lsb-release gnupg2

    curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    echo "deb http://nginx.org/packages/debian $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
    curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

    apt update
  elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 18 ]]; then
    print_ok "当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME}"
    export INS="apt install -y"
    export UNINS="apt"
    apt update
    ${INS} wget curl git sudo redis-server ca-certificates && update-ca-certificates
    # 清除可能的遗留问题
    rm -f /etc/apt/sources.list.d/nginx.list >/dev/null 2>&1
    $INS lsb-release gnupg2

    curl -sL https://deb.nodesource.com/setup_16.x | sudo bash -
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
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
  systemctl stop nginx >/dev/null 2>&1
  systemctl stop subconverter >/dev/null 2>&1
  systemctl stop myurls >/dev/null 2>&1
}

function nodejs_remove() {
    ${UNINS} --purge npm >/dev/null 2>&1
    ${UNINS} --purge nodejs >/dev/null 2>&1
    ${UNINS} --purge nodejs-legacy >/dev/null 2>&1
    ${UNINS} autoremove -y >/dev/null 2>&1
    ${UNINS} cmdtest >/dev/null 2>&1
    ${UNINS} yarn >/dev/null 2>&1
    ${UNINS} --fix-broken install -y >/dev/null 2>&1
}

function nginx_install() {
  nginxVersion="$(nginx -v 2>&1)" && NGINX_VERSION="$(echo ${nginxVersion#*/})"
  if [[ `command -v nginx |grep -c "nginx"` -ge '1' ]] && [[ "${NGINX_VERSION}" == "1.20.2" ]]; then
    ${INS} nginx >/dev/null 2>&1
    systemctl start nginx
    systemctl enable nginx
    print_ok "Nginx 已存在"
  else
    systemctl stop nginx >/dev/null 2>&1
    systemctl disable nginx >/dev/null 2>&1
    systemctl daemon-reload
    ${UNINS} --purge remove -y nginx >/dev/null 2>&1
    ${UNINS} remove -y nginx >/dev/null 2>&1
    ${UNINS} --purge remove -y nginx-common >/dev/null 2>&1
    ${UNINS} --purge remove -y nginx-core >/dev/null 2>&1
    ${UNINS} autoremove -y >/dev/null 2>&1
    rm -rf /etc/nginx /usr/share/nginx
    if [[ "${ID}" == "centos" ]]; then
      ${INS} nginx-1.20.2
    else
      ${INS} nginx
    fi
    systemctl start nginx
    systemctl enable nginx
  fi
  sleep 1
}

function dependency_install() {
  ${INS} nodejs
  judge "安装 nodejs"
  
  ${INS} yarn
  judge "安装 yarn"
  
  ${INS} lsof
  judge "安装 lsof"
  
  ${INS} socat
  judge "安装 socat"
  
  ${INS} tar
  judge "安装 tar"

  if [[ "${ID}" == "centos" ]]; then
    ${INS} crontabs
  else
    ${INS} cron
  fi
  judge "安装 crontab"
  
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
    touch /var/spool/cron/root && chmod 600 /var/spool/cron/root
    systemctl start crond && systemctl enable crond
  else
    touch /var/spool/cron/crontabs/root && chmod 600 /var/spool/cron/crontabs/root
    systemctl start cron && systemctl enable cron
  fi
  judge "crontab 自启动配置"

  ${INS} unzip
  judge "安装 unzip"

  # upgrade systemd
  ${INS} systemd
  judge "安装/升级 systemd"

  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
    ${INS} pcre pcre-devel zlib-devel epel-release openssl openssl-devel
  else
    ${INS} libpcre3 libpcre3-dev zlib1g-dev openssl libssl-dev
  fi
}

function command_Version() {
  systemctl start redis
  systemctl enable redis
  if [[ ! -x "$(command -v node)" ]]; then
    print_error "node安装失败!"
    exit 1
  else
    node_version="$(node --version |egrep -o 'v[0-9]+\.[0-9]+\.[0-9]+')"
    print_ok "node版本号为：${node_version}"
    sleep 1
  fi
  if [[ ! -x "$(command -v yarn)" ]]; then
    print_error "yarn安装失败!"
    exit 1
  else
    yarn_version="$(yarn --version |egrep -o '[0-9]+\.[0-9]+\.[0-9]+')"
    print_ok "yarn版本号为：${yarn_version}"
    sleep 1
  fi
  if [[ `systemctl status nginx |grep -c "active (running) "` == '1' ]]; then
    nginxVersion="$(nginx -v 2>&1)" && NGINX_VERSION="$(echo ${nginxVersion#*/})"
    print_ok "Nginx版本号为：${NGINX_VERSION}"
    sleep 1
  else
    print_error "nginx安装失败!"
    exit 1
  fi
  if [[ `systemctl status redis |grep -c "active (running) "` == '1' ]]; then
    print_ok "redis安装成功"
    sleep 1
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
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
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
    acme.sh --upgrade --auto-upgrade
    judge "启动证书自动续期"
    if [[ "${DNS_service}" = "dns_cf" ]]; then
      echo "domain=${domain}" > "${domainclash}"
      echo "CF_Key=CF_Key_xx" >> "${domainclash}"
      echo "CF_Email=CF_Email_xx" >> "${domainclash}"
    else
      echo "domain=${domain}" > "${domainclash}"
      echo "DP_Key=DP_Key_xx" >> "${domainclash}"
      echo "DP_Id=DP_Id_xx" >> "${domainclash}"
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
    rm -rf ${clash_path}/server.key ${clash_path}/server.crt
    acme.sh --installcert -d "${domain}" --ecc  --key-file   ${clash_path}/server.key   --fullchain-file ${clash_path}/server.crt
    judge "SSL 证书配置成功"
    chown -R nobody.$cert_group "${clash_path}/server.key"
    chown -R nobody.$cert_group "${clash_path}/server.crt"
    systemctl start nginx
    acme.sh  --upgrade  --auto-upgrade
    judge "启动证书自动续期"
    if [[ "${DNS_service}" = "dns_cf" ]]; then
      echo "domain=${domain}" > "${domainclash}"
      echo "CF_Key=CF_Key_xx" >> "${domainclash}"
      echo "CF_Email=CF_Email_xx" >> "${domainclash}"
    else
      echo "domain=${domain}" > "${domainclash}"
      echo "DP_Key=DP_Key_xx" >> "${domainclash}"
      echo "DP_Id=DP_Id_xx" >> "${domainclash}"
    fi
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
  
  if [[ "${subconv_erter}" == "MetaCubeX" ]]; then
    rm -rf "${clash_path}/subconverter_${ARCH_PRINT}.tar.gz" >/dev/null 2>&1
    wget -P "${clash_path}" https://github.com/MetaCubeX/subconverter/releases/download/Alpha/subconverter_${ARCH_PRINT}.tar.gz -O "${clash_path}/subconverter_${ARCH_PRINT}.tar.gz"
  else
    latest_vers="$(wget -qO- -t1 -T2 "https://github.com/281677160/common/releases/download/API/tindy2013.api" | grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' | sed 's/\"//g;s/,//g;s/ //g')"
    [[ -z ${latest_vers} ]] && latest_vers="v0.8.1"
    rm -rf "${clash_path}/subconverter_${ARCH_PRINT}.tar.gz" >/dev/null 2>&1
    wget -P "${clash_path}" https://github.com/tindy2013/subconverter/releases/download/${latest_vers}/subconverter_${ARCH_PRINT}.tar.gz -O "${clash_path}/subconverter_${ARCH_PRINT}.tar.gz"
  fi
  
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
  systemctl daemon-reload
  systemctl start subconverter
  systemctl enable subconverter
  sleep 3
  if [[ $(lsof -i:"${HDFW_PORT}" | grep -i -c "listen") -ge "1" ]]; then
    print_ok "subconverter安装成功"
  else
    print_error "subconverter安装失败,请再次执行安装命令试试"
    exit 1
  fi
 }

function install_subweb() {
  ECHOY "正在安装sub-web服务"
  rm -fr "${clash_path}/sub-web"
  git clone https://github.com/CareyWang/sub-web.git "${clash_path}/sub-web"
  if [[ $? -ne 0 ]];then
    print_error "sub-web下载失败,请再次执行安装命令试试"
    exit 1
  else
    rm -fr "${clash_path}/subweb"
    git clone https://github.com/281677160/agent "${clash_path}/subweb"
    judge "sub-web源码下载"
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
  wget -P "${clash_path}" https://github.com/281677160/MyUrls/releases/download/v1.10/linux-${ARCH_PRINT}-myurls.tar.gz -O "${clash_path}/linux-${ARCH_PRINT}-myurls.tar.gz"
  if [[ $? -ne 0 ]];then
    print_error "myurls短链程序下载失败,请再次执行安装命令试试!"
    exit 1
  else
    print_ok "myurls短链程序下载完成"
  fi
  rm -rf "${clash_path}/myurls"
  tar -zxvf "${clash_path}/linux-${ARCH_PRINT}-myurls.tar.gz" -C "${clash_path}"
  if [[ $? -ne 0 ]];then
    print_error "myurls解压失败"
    exit 1
  else
    print_ok "myurls解压完成"
    chmod -R 775 "${clash_path}/myurls"
    sed -i "s?const backend = .*?const backend = \'https://${myurls_ip}\'?g" "${clash_path}/myurls/public/index.html"
  fi

  echo "
  [Unit]
  Description=A API For myurls Convert
  After=network.target
    
  [Service]
  Type=simple
  ExecStart=${clash_path}/myurls/linux-${ARCH_PRINT}-myurls -domain ${myurls_ip} -port ${DLJ_PORT}
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
  sleep 3
  if [[ $(lsof -i:"${DLJ_PORT}" | grep -i -c "listen") -ge "1" ]]; then
    rm -rf "${clash_path}/linux-${ARCH_PRINT}-myurls.tar.gz"
    print_ok "短链程序安装完成"
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
    client_max_body_size 24M;
    client_body_buffer_size 128k;

    client_header_buffer_size 5120k;
    large_client_header_buffers 16 5120k;
   
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
}

function restart_all() {
  systemctl daemon-reload
  systemctl restart nginx
  systemctl restart subconverter
  systemctl restart myurls
  sleep 3
  clear
  echo
  echo
  if [[ `systemctl status subconverter |grep -c "active (running) "` == '1' ]]; then
    print_ok "subconverter运行 正常"
  else
    print_error "subconverter没有运行"
    exit 1
  fi
  if [[ `systemctl status myurls |grep -c "active (running) "` == '1' ]]; then
    print_ok "myurls运行 正常"
  else
    print_error "myurls没有运行"
    exit 1
  fi
  if [[ `systemctl status nginx |grep -c "active (running) "` == '1' ]]; then
    print_ok "nginx运行 正常"
  else
    print_error "nginx没有运行,会导致以上应用无法正常使用"
    exit 1
  fi
  ECHOY "全部服务安装完毕,请在浏览器打开 ${www_ip} 或 ${CUrrent_ip} 进行使用"
}

function restart_clash_all() {
  ECHOG "正在重启clash节点转换程序"
  systemctl daemon-reload
  systemctl restart nginx
  systemctl restart subconverter
  systemctl restart myurls
  sleep 3
  clear
  echo
  echo
  if [[ `systemctl status subconverter |grep -c "active (running) "` == '1' ]]; then
    print_ok "clash节点转换程序运行 正常"
  else
    print_error "clash节点转换程序没有运行"
  fi
  if [[ `systemctl status myurls |grep -c "active (running) "` == '1' ]]; then
    print_ok "短链接转换程序运行 正常"
  else
    print_error "短链接转换程序没有运行"
    exit 1
  fi
  if [[ `systemctl status nginx |grep -c "active (running) "` == '1' ]]; then
    print_ok "nginx运行 正常"
  else
    print_error "nginx没有运行,会导致以上应用无法正常使用"
    exit 1
  fi
  ECHOY "全部服务重启完毕"
}

function clash_uninstall() {
  source '/etc/os-release'
  if [[ "${ID}" == "centos" ]] || [[ "${ID}" == "ol" ]]; then
    export UNINS="yum"
  else
    export UNINS="apt"
  fi
  
  ECHOG "是否要御载clash节点转换程序?[Y/n]?"
  export DUuuid="请输入[Y/y]确认或[N/n]退出"
  while :; do
  read -p " ${DUuuid}：" IDPATg
  case $IDPATg in
  [Yy])
    systemctl stop subconverter
    systemctl disable subconverter
    systemctl stop myurls
    systemctl disable myurls
    systemctl daemon-reload
    rm -rf /etc/nginx/conf.d/dl_nginx.conf
    rm -rf /etc/nginx/conf.d/suc_nginx.conf
    rm -rf /etc/nginx/conf.d/www_nginx.conf
    rm -rf /www/dist_web
    rm -rf /etc/systemd/system/subconverter.service
    rm -rf /etc/systemd/system/myurls.service
    rm -rf ${clash_path}
    print_ok "clash节点转换程序御载完成"
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
  
  nginxVersion="$(nginx -v 2>&1)" && NGINX_VERSION="$(echo ${nginxVersion#*/})"
  if [[ -x "$(command -v nginx)" ]] && [[ "${NGINX_VERSION}" == "1.20.2" ]]; then
    clear
    echo
    ECHOR "是否卸载nginx? 按[Y/y]进行御载,按任意键跳过御载程序"
    echo
    read -p " 输入您的选择：" uninstall_nginx
    case $uninstall_nginx in
    [Yy])
      systemctl stop nginx
      systemctl disable nginx
      systemctl daemon-reload
      ${UNINS} --purge remove -y nginx >/dev/null 2>&1
      ${UNINS} autoremove -y >/dev/null 2>&1
      ${UNINS} --purge remove -y nginx >/dev/null 2>&1
      ${UNINS} --purge remove -y nginx-common >/dev/null 2>&1
      ${UNINS} --purge remove -y nginx-core >/dev/null 2>&1
      ${UNINS} --fix-broken install -y >/dev/null 2>&1
      find / -iname 'nginx' 2>&1 | xargs -i rm -rf {}
      print_ok "nginx御载 完成"
    ;;
    *) 
       print_ok "您已跳过御载nginx"
       echo
     ;;
    esac
  fi
  
  if [[ -e "$HOME"/.acme.sh ]]; then
    clear
    echo
    [[ -f "${domainclash}" ]] && PROFILE="$(grep -i 'domain=' ${domainclash} | cut -d "=" -f2)"
    if [[ -f "$HOME/.acme.sh/${PROFILE}_ecc/${PROFILE}.cer" ]] && [[ -f "$HOME/.acme.sh/${PROFILE}_ecc/${PROFILE}.key" ]]; then
        export TISHI="提示：[ ${PROFILE} ]证书已经存在,如果还继续使用此域名建议勿删除.acme.sh"
     else
        export WUTISHI="Y"
     fi
     if [[ ${WUTISHI} == "Y" ]]; then
        "$HOME"/.acme.sh/acme.sh --uninstall
        rm -rf $HOME/.acme.sh
	rm -rf /usr/bin/acme.sh
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
}

function install_jiedian() {
  DNS_service_provider
  DNS_provider
  system_check
  nodejs_remove
  nginx_install
  dependency_install
  command_Version
  basic_optimization
  port_exist_check
  domain_check
  ssl_judge_and_install
  install_subconverter
  install_subweb
  install_myurls
  nginx_conf
  restart_all
}


menu() {
  clear
  echo
  if [[ -f "${clash_path}/subconverter/subconverter" ]]; then
    if [[ `systemctl status subconverter |grep -c "active (running) "` == '1' ]]; then
      echo -e "\033[32m clash节点转换程序运行中 \033[0m"
    else
      echo -e "\033[31m clash节点转换程序没有运行 \033[0m"
    fi
  else
     echo -e "\033[31m clash节点转换程序没有安装 \033[0m"
  fi
  
  if [[ -f "${clash_path}/myurls/linux-${ARCH_PRINT}-myurls" ]]; then
    if [[ `systemctl status myurls |grep -c "active (running) "` == '1' ]]; then
      echo -e "\033[32m 短链接转换程序运行中 \033[0m"
    else
      echo -e "\033[31m 短链接转换程序没有运行 \033[0m"
    fi
  else
     echo -e "\033[31m 短链接转换程序没有安装 \033[0m"
  fi
  
  nginxVersion="$(nginx -v 2>&1)" && NGINX_VERSION="$(echo ${nginxVersion#*/})"
  if [[ -x "$(command -v nginx)" ]] && [[ "${NGINX_VERSION}" == "1.20.2" ]]; then
    if [[ `systemctl status nginx |grep -c "active (running) "` == '1' ]]; then
      echo -e "\033[32m nginx运行中 \033[0m"
    else
      echo -e "\033[31m nginx没有运行 \033[0m"
    fi
  else
     echo -e "\033[31m nginx没有安装 \033[0m"
  fi
  echo
  ECHOY "1、安装 clash节点转换程序"
  ECHOY "2、重启 clash节点转换程序"
  ECHOY "3、卸载 clash节点转换程序"
  ECHOY "4、退出"
  echo
  echo
  XUANZHE="请输入数字"
  while :; do
  read -p " ${XUANZHE}：" menu_num
  case $menu_num in
  1)
    install_jiedian
    break
    ;;
  2)
    restart_clash_all
    break
    ;;
  3)
    clash_uninstall
    break
    ;;
  4)
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


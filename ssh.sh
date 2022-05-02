#!/usr/bin/env bash

function system_check() {
  if [[ "$(. /etc/os-release && echo "$ID")" == "centos" ]]; then
    yum install -y sudo
    system_centos
  elif [[ "$(. /etc/os-release && echo "$ID")" == "ubuntu" ]]; then
    apt -y update
    apt install -y sudo
    system_ubuntu
  elif [[ "$(. /etc/os-release && echo "$ID")" == "debian" ]]; then
    apt -y update
    apt install -y sudo
    system_debian
  else
    echo -e "\033[41;33m 不支持您的系统  \033[0m"
    exit 1
  fi
}

function system_centos() {
  if [[ ! -f /etc/ssh/sshd_config ]]; then
    echo -e "\033[33m 安装SSH \033[0m"
    yum install -y openssh-server
    systemctl enable sshd.service
    ssh_PermitRootLogin
    service sshd restart
  else
    ssh_PermitRootLogin
    service sshd restart
  fi
  echo -e "\033[32m 开启root账户SSH完成 \033[0m"
  exit 0
}

function system_ubuntu() {
  if [[ ! -f /etc/ssh/sshd_config ]]; then
    echo -e "\033[33m 安装SSH \033[0m"
    apt-get install -y openssh-server
    ssh_PermitRootLogin
    service ssh restart
  else
    ssh_PermitRootLogin
    service ssh restart
  fi
  echo -e "\033[32m 开启root账户SSH完成 \033[0m"
  exit 0
}

function system_debian() {
  if [[ ! -f /etc/ssh/sshd_config ]]; then
    echo -e "\033[33m 安装SSH \033[0m"
    apt install -y openssh-server
    ssh_PermitRootLogin
    service ssh restart
  else
    ssh_PermitRootLogin
    service ssh restart
  fi
  echo -e "\033[32m 开启root账户SSH完成 \033[0m"
  exit 0
}

function ssh_PermitRootLogin() {
  if [[ `grep -c "ClientAliveInterval 30" /etc/ssh/sshd_config` == '0' ]]; then
    sed -i '/ClientAliveInterval/d' /etc/ssh/sshd_config
    sed -i '/ClientAliveCountMax/d' /etc/ssh/sshd_config
    sh -c 'echo ClientAliveInterval 30 >> /etc/ssh/sshd_config'
    sh -c 'echo ClientAliveCountMax 6 >> /etc/ssh/sshd_config'
  fi
  sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
  sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication yes/g' /etc/ssh/sshd_config
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
system_check "$@"

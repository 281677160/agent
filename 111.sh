#!/usr/bin/env bash

#====================================================
#	System Request:Debian 9+/Ubuntu 18.04+/Centos 7+
#	Author:	wulabing
#	Dscription: Xray onekey Management
#	email: admin@wulabing.com
#====================================================

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
export GITHUB_WORKSPACE="$PWD"
export Home="$PWD/openwrt"
export NETIP="package/base-files/files/etc/networkip"

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
function ECHOY() {
  echo
  echo -e "${Yellow} $1 ${Font}"
  echo
}
function ECHOG() {
  echo
  echo -e "${Green} $1 ${Font}"
  echo
}
  function ECHOR() {
  echo
  echo -e "${Red} $1 ${Font}"
  echo
}

judge() {
  if [[ 0 -eq $? ]]; then
    echo
    print_ok "$1 完成"
    echo
    sleep 1
  else
    echo
    print_error "$1 失败"
    echo
    exit 1
  fi
}

judgeopen() {
  if [[ 0 -eq $? ]]; then
    echo
    print_ok "$1 完成"
    echo
    sleep 1
  else
    echo
    print_error "$1 失败"
    rm -rf openwrte
    echo
    exit 1
  fi
}

if [[ "$USER" == "root" ]]; then
  print_error "警告：请勿使用root用户编译，换一个普通用户吧~~"
  exit 1
fi

function running_state() {
cd ${GITHUB_WORKSPACE}
	clear
	echo
	echo
	echo
	ECHOR "|*******************************************|"
	ECHOG "|                                           |"
	ECHOY "|    首次编译,请输入Ubuntu密码继续下一步    |"
	ECHOG "|                                           |"
	ECHOY "|              编译环境部署                 |"
	ECHOG "|                                           |"
	ECHOR "|*******************************************|"
	echo
	echo
	sudo apt-get update -y
	sudo apt-get full-upgrade -y
	sudo apt-get install -y build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 lib32stdc++6 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl rename libpcap0.8-dev swig rsync
	judge "部署编译环境"
	sudo timedatectl set-timezone Asia/Shanghai
}

function system_kongjian() {
cd ${GITHUB_WORKSPACE}
export Ubunkj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1')"
export FINAL=`echo ${Ubunkj: -1}`
if [[ "${FINAL}" =~ (M|K) ]]; then
	print_error "敬告：可用空间小于[ 1G ]退出编译,建议可用空间大于20G"
	sleep 1
	exit 1
fi
export Ubuntu_mz="$(cat /etc/group | grep adm | cut -f2 -d,)"
export Ubuntu_kj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1' |sed 's/.$//g')"
if [[ "${Ubuntu_kj}" -lt "20" ]];then
	ECHOY "您当前系统可用空间为${Ubuntu_kj}G"
	print_error "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
	read -p " 回车退出，按[Y/y]回车确认继续编译： " YN
	case ${YN} in
		[Yy]) 
			ECHOG  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
		;;
		*)
			ECHOY  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
			sleep 1
			exit 0
	esac
fi
}

function kaishi_install() {
cd ${GITHUB_WORKSPACE}
[[ -z ${ipdz} ]] && export ipdz="192.168.1.1"
ECHOG "设置openwrt的后台IP地址[ 回车默认 $ipdz ]"
read -p " 请输入后台IP地址：" ip
export ip=${ip:-"$ipdz"}
ECHOY "您的后台地址为：$ip"
echo
echo
ECHOG "是否需要选择机型和增删插件?"
read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " MENU
case $MENU in
	[Yy])
		export Menuconfig="YES"
		ECHOY "您执行机型和增删插件命令,请耐心等待程序运行至窗口弹出进行机型和插件配置!"
	;;
	*)
		ECHOR "您已关闭选择机型和增删插件设置！"
	;;
esac
echo
ECHOG "是否把固件上传到<奶牛快传>?"
read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " NNKC
case $NNKC in
	[Yy])
		export UPCOWTRANSFER="true"
		ECHOY "您执行了上传固件到<奶牛快传>!"
	;;
	*)
		ECHOR "您已关闭上传固件到<奶牛快传>！"
	;;
esac
echo
[[ ! $firmware == "openwrt_amlogic" ]] && {
	ECHOG "是否把定时更新插件编译进固件?"
	read -p " [输入[ Y/y ]回车确认，直接回车跳过选择]： " RELE
	case $RELE in
		[Yy])
			export REG_UPDATE="true"
		;;
		*)
			ECHOR "您已关闭把‘定时更新插件’编译进固件！"
			export Github="https://github.com/281677160/build-actions"
		;;
	esac
}
[[ "${REG_UPDATE}" == "true" ]] && {
	[[ -z ${Git} ]] && export Git="https://github.com/281677160/build-actions"
	ECHOG "设置Github地址,定时更新固件需要把固件传至对应地址的Releases"
	ECHOY "回车默认为：$Git"
	read -p " 请输入Github地址：" Github
	export Github=${Github:-"$Git"}
	ECHOG "您的Github地址为：$Github"
	export Apidz="${Github##*com/}"
	export Author="${Apidz%/*}"
	export CangKu="${Apidz##*/}"
}
nginx_ip
}

function nginx_ip() {
cd ${GITHUB_WORKSPACE}
cat >$PWD/${Core} <<-EOF
ipdz=$ip
Git=$Github
EOF

if [[ -d ${Home} ]]; then
cat >${Home}/${Core} <<-EOF
ipdz=$ip
Git=$Github
EOF
fi
}

function nginx_install() {
cd ${GITHUB_WORKSPACE}
ECHOG "正在下载源码中,请耐心等候~~~"
if [[ $firmware == "Lede_source" ]]; then
	if [[ -d ${Home}/build_dir ]] && [[ -d ${Home}/toolchain ]] && [[ -d ${Home}/tools ]] && [[ -d ${Home}/staging_dir ]]; then
		git clone https://github.com/coolsnowwolf/lede openwrte
		judgeopen "${firmware}源码下载"
		cp -rf openwrt/{build_dir,staging_dir,toolchain,tools,config_bf} ${GITHUB_WORKSPACE}/openwrte
		rm -fr openwrte && mv -f openwrte openwrt
	else
		rm -fr openwrte && git clone https://github.com/coolsnowwolf/lede openwrt
		judgeopen "${firmware}源码下载"
	fi
	export ZZZ="package/lean/default-settings/files/zzz-default-settings"
	export OpenWrt_name="18.06"
elif [[ $firmware == "Lienol_source" ]]; then
	rm -rf openwrt && git clone -b 19.07 --single-branch https://github.com/Lienol/openwrt openwrt
	judge "${firmware}源码下载"
	export ZZZ="package/default-settings/files/zzz-default-settings"
	export OpenWrt_name="19.07"
	echo -e "\nipdz=$ip" > openwrt/.Lienol_core
	echo -e "\nGit=$Github" >> openwrt/.Lienol_core
elif [[ $firmware == "Mortal_source" ]]; then
	rm -rf openwrt && git clone -b openwrt-21.02 --single-branch https://github.com/immortalwrt/immortalwrt openwrt
	judge "${firmware}源码下载"
	export ZZZ="package/emortal/default-settings/files/zzz-default-settings"
	export OpenWrt_name="21.02"
elif [[ $firmware == "openwrt_amlogic" ]]; then
	rm -rf openwrt && git clone https://github.com/coolsnowwolf/lede openwrt
	judge "${firmware}源码下载"
	echo
	ECHOG "正在下载打包所需的内核,请耐心等候~~~"
	echo
	rm -rf amlogic-s9xxx && svn co https://github.com/ophub/amlogic-s9xxx-openwrt/trunk/amlogic-s9xxx amlogic-s9xxx
	judge "amlogic内核下载"
	mv amlogic-s9xxx openwrt/amlogic-s9xxx
	curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/make > openwrt/make
	judge "内核版本文件下载"
	mkdir -p openwrt/openwrt-armvirt
	chmod 777 openwrt/make
	export ZZZ="package/lean/default-settings/files/zzz-default-settings"
	export OpenWrt_name="18.06"
fi
nginx_ip
}

function basic_optimization() {
cd ${GITHUB_WORKSPACE}
echo "Compile_Date=$(date +%Y%m%d%H%M)" > $Home/Openwrt.info && source $Home/Openwrt.info
svn co https://github.com/281677160/build-actions/trunk/build $Home/build > /dev/null 2>&1
judge "编译脚本下载"
git clone https://github.com/281677160/common $Home/build/common
judge "额外扩展脚本下载"
chmod -R +x $Home/build/common
chmod -R +x $Home/build/${firmware}
source $Home/build/${firmware}/settings.ini
export REGULAR_UPDATE="${REG_UPDATE}"
cp -Rf $Home/build/common/Custom/compile.sh openwrt/compile.sh
cp -Rf $Home/build/common/*.sh openwrt/build/${firmware}
}

function domain_check() {
ECHOG "正在加载自定义文件和下载插件,请耐心等候~~~"
cd $Home
./scripts/feeds update -a > /dev/null 2>&1
if [[ "${REPO_BRANCH}" == "master" ]]; then
	source "${PATH1}/common.sh" && Diy_lede
elif [[ "${REPO_BRANCH}" == "19.07" ]]; then
	source "${PATH1}/common.sh" && Diy_lienol
elif [[ "${REPO_BRANCH}" == "openwrt-21.02" ]]; then
	source "${PATH1}/common.sh" && Diy_mortal
fi
source build/${firmware}/common.sh && Diy_all
judge "加载自定义文件"
}

function port_exist_check() {
ECHOG "正在加载源和安装源,请耐心等候~~~"
cd $Home
echo
cat >$NETIP <<-EOF
uci set network.lan.ipaddr='$ip'
uci commit network
EOF
sed -i "s/OpenWrt /${Ubuntu_mz} compiled in $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" $ZZZ
sed -i '/CYXluq4wUazHjmCDBCqXF/d' $ZZZ
echo
sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ./feeds/luci/applications`
sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ./package`
sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ./feeds/luci/applications`
sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ./feeds/luci/applications`
./scripts/feeds update -a
./scripts/feeds install -a > /dev/null 2>&1
./scripts/feeds install -a
[[ -e ${Home}/config_bf ]] && {
	cp -rf ${Home}/config_bf ${Home}/.config
} || {
	cp -rf ${Home}/build/${firmware}/.config ${Home}/.config
}
if [[ "${REGULAR_UPDATE}" == "true" ]]; then
	  source build/$firmware/upgrade.sh && Diy_Part1
fi
if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon=y" ${Home}/.config` -eq '0' ]]; then
	echo -e "\nCONFIG_PACKAGE_luci-theme-argon=y" >> ${Home}/.config
fi
find . -name 'README' -o -name 'README.md' | xargs -i rm -rf {}
find . -name 'CONTRIBUTED.md' -o -name 'README_EN.md' -o -name 'DEVICE_NAME' | xargs -i rm -rf {}
}

function configure_xray_ws() {
if [[ "${Menuconfig}" == "YES" ]]; then
	make menuconfig
fi
}

function xray_install() {
ECHOG "正在生成配置文件，请稍后..."
cd $Home
source build/${firmware}/common.sh && Diy_chajian
make defconfig
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	clear
	echo
	echo
	chmod -R +x ${Home}/CHONGTU
	source ${Home}/CHONGTU
	rm -rf {CHONGTU,Chajianlibiao}
	ECHOG "如需重新编译请按 Ctrl+c 结束此次编译，否则30秒后继续编译!"
	make defconfig > /dev/null 2>&1
	sleep 30s
fi
openwrt_config
openwrt_zuihouchuli
}

function openwrt_config() {
cd $Home
export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)"
export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)"
if [[ `grep -c "CONFIG_TARGET_x86_64=y" .config` -eq '1' ]]; then
          export TARGET_PROFILE="x86-64"
elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" .config` -eq '1' ]]; then
          export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
          export TARGET_PROFILE="armvirt"
fi
export COMFIRMWARE="${Home}/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
}

function openwrt_zuihouchuli() {
cd $Home
./scripts/diffconfig.sh > ${Home}/config_bf
if [ "${REGULAR_UPDATE}" == "true" ]; then
          source build/$firmware/upgrade.sh && Diy_Part2
fi
# 为编译做最后处理
BY_INFORMATION="false"
source build/${firmware}/common.sh && Diy_chuli
}

function configure_nginx() {
cd $Home
ECHOG "下载DL文件，请耐心等候..."
rm -fr build.log
make -j8 download 2>&1 |tee build.log
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;
configure_dl
}

function configure_dl() {
cd $Home
if [[ `grep -c "make with -j1 V=s or V=sc" build.log` == '0' ]]; then
	ECHOG "DL文件下载成功"
else
	clear
	echo
	print_error "下载DL失败，更换节点后再尝试下载？"
	QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或输入[N/n]回车,退出下载"
	while :; do
		read -p " [${QLMEUN}]： " XZDLE
		case $XZDLE in
			Y)
				configure_nginx
			break
			;;
			N)
				ECHOR "退出编译程序!"
				sleep 2
				exit 1
			break
    			;;
    			*)
				QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或输入[N/n]回车,退出下载"
			;;
		esac
	done
fi
}

function generate_certificate() {
cd $Home
rm -rf build.log
cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c > CPU
cat /proc/cpuinfo | grep "cpu cores" | uniq >> CPU
sed -i 's|[[:space:]]||g; s|^.||' CPU && sed -i 's|CPU||g; s|pucores:||' CPU
CPUNAME="$(awk 'NR==1' CPU)" && CPUCORES="$(awk 'NR==2' CPU)"
rm -rf CPU
clear
echo
echo
echo
ECHOG "您的CPU型号为[ ${CPUNAME} ]"
echo
echo
ECHOG "在Ubuntu使用核心数为[ ${CPUCORES} ],线程数为[ $(nproc) ]"
echo
echo
if [[ "$(nproc)" == "1" ]]; then
	ECHOY "正在使用[$(nproc)线程]编译固件,预计要[3.5]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (2|3) ]]; then
	ECHOY "正在使用[$(nproc)线程]编译固件,预计要[3]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (4|5) ]]; then
	ECHOY "正在使用[$(nproc)线程]编译固件,预计要[2.5]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (6|7) ]]; then
	ECHOY "正在使用[$(nproc)线程]编译固件,预计要[2]小时左右,请耐心等待..."
elif [[ "$(nproc)" =~ (8|9) ]]; then
	ECHOY "正在使用[$(nproc)线程]编译固件,预计要[1.5]小时左右,请耐心等待..."
else
	ECHOY "正在使用[$(nproc)线程]编译固件,预计要[1]小时左右,请耐心等待..."
fi
rm -fr ${COMFIRMWARE}/*
sleep 8
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make -j$(($(nproc) + 1)) V=s 2>&1 |tee build.log
judge "编译"
if [[ ${firmware} == "Mortal_source" ]]; then
	if [[ `ls -a ${COMFIRMWARE} | grep -c "immortalwrt"` == '0' ]]; then
		print_error "没发现固件存在，编译失败~~!"
		sleep 1
		exit 1
	fi
else
	if [[ `ls -a ${COMFIRMWARE} | grep -c "openwrt"` == '0' ]]; then
		print_error "没发现固件存在，编译失败~~!"
		sleep 1
		exit 1
	fi
	
fi
echo "chenggong" >${Home}/build/chenggong
}

function generate_cer() {
if [[ "${firmware}" == "Lede_source" ]] || [[ -n "$(ls -A "${Home}/.Lede_core" 2>/dev/null)" ]] || [[ -f "$PWD/.Lede_core" ]]; then
	export firmware="Lede_source"
	export CODE="lede"
	export Modelfile="Lede_source"
	export Core=".Lede_core"
	export PATH1="${Home}/build/${firmware}"
	[[ -f $PWD/.Lede_core ]] && source $PWD/.Lede_core
	[[ -f ${Home}/.Lede_core ]] && source ${Home}/.Lede_core
fi
if [[ "${firmware}" == "Lienol_core" ]] || [[ -n "$(ls -A "${Home}/.Lienol_core" 2>/dev/null)" ]] || [[ -f "$PWD/.Lienol_core" ]]; then
	export firmware="Lienol_source"
	export CODE="lienol"
	export Modelfile="Lienol_source"
	export Core=".Lienol_core"
	export PATH1="${Home}/build/${firmware}"
	[[ -f $PWD/.Lienol_core ]] && source $PWD/.Lienol_core
	[[ -f ${Home}/.Lienol_core ]] && source ${Home}/.Lienol_core
fi
if [[ "${firmware}" == "Mortal_core" ]] || [[ -n "$(ls -A "${Home}/.Mortal_core" 2>/dev/null)" ]] || [[ -f "$PWD/.Mortal_core" ]]; then
	export firmware="Mortal_source"
	export CODE="mortal"
	export Modelfile="Mortal_source"
	export Core=".Mortal_core"
	export PATH1="${Home}/build/${firmware}"
	[[ -f $PWD/.Mortal_core ]] && source $PWD/.Mortal_core
	[[ -f ${Home}/.Mortal_core ]] && source ${Home}/.Mortal_core
fi
if [[ "${firmware}" == "amlogic_core" ]] || [[ -n "$(ls -A "${Home}/.amlogic_core" 2>/dev/null)" ]] || [[ -f "$PWD/.amlogic_core" ]]; then
	export firmware="openwrt_amlogic"
	export CODE="lede"
	export Modelfile="openwrt_amlogic"
	export Core=".amlogic_core"
	export PATH1="${Home}/build/${firmware}"
	[[ -f $PWD/.amlogic_core ]] && source $PWD/.amlogic_core
	[[ -f ${Home}/.amlogic_core ]] && source ${Home}/.amlogic_core
fi
}

function install_xray_ws() {
  generate_cer
  running_state
  system_kongjian
  kaishi_install
  nginx_install
  basic_optimization
  domain_check
  port_exist_check
  configure_xray_ws
  xray_install
  configure_nginx
  generate_certificate
}
menu() {
	clear
	echo
	echo
	echo
	ECHOY " 1. Lede_5.4内核,LUCI 18.06版本(Lede_source)"
	echo
	ECHOY " 2. Lienol_4.14内核,LUCI 19.07版本(Lienol_source)"
	echo
	ECHOY " 3. Immortalwrt_5.4内核,LUCI 21.02版本(Mortal_source)"
	echo
	ECHOY " 4. N1和晶晨系列CPU盒子专用(openwrt_amlogic)"
	echo
	ECHOY " 5. 退出编译程序"
	echo
	echo
	echo
	while :; do
	ECHOY "请选择编译源码,输入[ 1、2、3、4、5 ]然后回车确认您的选择！"
	read -p " 输入您的选择： " CHOOSE
	case $CHOOSE in
		1)
			export firmware="Lede_source"
			ECHOG "您选择了：Lede_5.4内核,LUCI 18.06版本"
			install_xray_ws
		break
		;;
		2)
			export firmware="Lienol_source"
			ECHOG "您选择了：Lienol_4.14内核,LUCI 19.07版本"
			install_xray_ws
		break
		;;
		3)
			export firmware="Mortal_source"
			ECHOG "您选择了：Immortalwrt_5.4内核,LUCI 21.02版本"
			install_xray_ws
		break
		;;
		4)
			export firmware="openwrt_amlogic"
			ECHOG "您选择了：N1和晶晨系列CPU盒子专用"
			install_xray_ws
		break
		;;
		5)
			rm -rf compile.sh
			ECHOR "您选择了退出编译程序"
			exit 0
		break
    		;;
    		*)
			ECHOR "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
}

menp() {
  generate_cer
  [[ -f $PWD/openwrt/config_bf ]] && openwrt_config
  cd ${GITHUB_WORKSPACE}
  clear
  echo
  ECHOG "作者：${CODE}"
  ECHOG "源码：${firmware}"
  ECHOG "机型：${TARGET_PROFILE}"
  echo
  ECHOY "1、安装 Xray、nginx和cloudreve"
  ECHOY "2、打印 Xray 节点信息"
  ECHOY "3、安装 BBR、锐速加速"
  ECHOY "4、更新 Xray"
  ECHOY "5、修改 UUID/端口/路径/Tronjian密码"
  ECHOY "6、删除 阿里云盾或腾讯云盾"
  ECHOY "7、卸载 Xray、nginx和cloudreve"
  ECHOY "8、重启 Xray、nginx和cloudreve"
  ECHOY "9、退出"
  echo
  echo
  XUANZHE="请输入数字"
  while :; do
  read -p " ${XUANZHE}：" menu_num
  case $menu_num in
  1)
  generate_cer
  system_kongjian
  kaishi_install
  nginx_install
  basic_optimization
  domain_check
  port_exist_check
  configure_xray_ws
  xray_install
  configure_nginx
  generate_certificate
    break
    ;;
  2)
    source $domain_tmp_dir/pzcon
    break
    ;;
  3)
    wget -N --no-check-certificate "https://raw.githubusercontent.com/ylx2016/Linux-NetSpeed/master/tcp.sh" && chmod +x tcp.sh && ./tcp.sh
    break
    ;;
  4)
    systemctl stop xray
    bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" - install
    restart_all
    break
    ;;
  5)
    configure_gaipeizhi
    break
    ;;
    
  6)
    bash -c "$(curl -Ls https://raw.githubusercontent.com/281677160/agent/main/xray/uninstall_firewall.sh)"
    break
    ;;
  7)
    xray_uninstall
    break
    ;;
  8)
    restart_all
    break
    ;;
  9)
    exit 0
    break
    ;;
    *)
    XUANZHE="请输入正确的选择"
    ;;
  esac
  done
}
if [[ -d ${Home}/staging_dir/host ]]; then
	menp "$@"
else
	menu "$@"
fi

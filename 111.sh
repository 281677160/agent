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
if [[ "$USER" == "root" ]]; then
  echo
  print_error "警告：请勿使用root用户编译，换一个普通用户吧~~"
  echo
  exit 1
fi

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
  echo -e "${Green} $1 ${Font}"
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

function running_state() {
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
	judge "安装/升级必要依赖"
  sudo timedatectl set-timezone Asia/Shanghai
	echo "compile" > .compile
}

function system_kongjian() {
export Ubunkj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1')"
export FINAL=`echo ${Ubunkj: -1}`
if [[ "${FINAL}" =~ (M|K) ]]; then
	echo
	ECHOR "敬告：可用空间小于[ 1G ]退出编译,建议可用空间大于20G,是否继续?"
	sleep 2
	exit 1
	echo
fi
export Ubuntu_mz="$(cat /etc/group | grep adm | cut -f2 -d,)"
export Ubuntu_kj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1' |sed 's/.$//g')"
if [[ "${Ubuntu_kj}" -lt "20" ]];then
	echo
	ECHOY "您当前系统可用空间为${Ubuntu_kj}G"
	echo ""
	ECHOR "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
	echo
	read -p " [回车退出，Y/y确认继续]： " YN
	case ${YN} in
		[Yy]) 
			ECHOG  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
			echo
		;;
		*)
			ECHOG  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
			echo ""
			sleep 2s
			exit 0
	esac
fi
}

function kaishi_install() {
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
echo
mkdir -p ${firmware}
cat >${firmware}/${Core} <<-EOF
ipdz=$ip
Git=$Github
EOF
}

function nginx_install() {
echo
ECHOG "正在下载源码中,请耐心等候~~~"
echo
if [[ $firmware == "Lede_source" ]]; then
	rm -rf openwrt && git clone https://github.com/coolsnowwolf/lede openwrt
	judge "${firmware}源码下载"
	export ZZZ="package/lean/default-settings/files/zzz-default-settings"
	export OpenWrt_name="18.06"
	echo -e "\nipdz=$ip" > openwrt/.Lede_core
	echo -e "\nGit=$Github" >> openwrt/.Lede_core
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
	echo -e "\nipdz=$ip" > openwrt/.Mortal_core
	echo -e "\nGit=$Github" >> openwrt/.Mortal_core
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
	mkdir -p openwrt/openwrt-armvirt
	chmod 777 openwrt/make
	export ZZZ="package/lean/default-settings/files/zzz-default-settings"
	export OpenWrt_name="18.06"
	echo -e "\nipdz=$ip" > openwrt/.amlogic_core
	echo -e "\nGit=$Github" >> openwrt/.amlogic_core
fi
}

function basic_optimization() {
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
echo
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
[ "${Menuconfig}" == "YES" ] && {
make menuconfig
}
}

function xray_install() {
ECHOG "正在生成配置文件，请稍后..."
echo
source build/${firmware}/common.sh && Diy_chajian
make defconfig
./scripts/diffconfig.sh > ${Home}/config_bf
if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
	clear
	echo
	echo
	echo
	chmod -R +x ${Home}/CHONGTU
	source ${Home}/CHONGTU
	rm -rf {CHONGTU,Chajianlibiao}
	echo
	ECHOG "如需重新编译请按 Ctrl+c 结束此次编译，否则30秒后继续编译!"
	make defconfig > /dev/null 2>&1
	sleep 30s
fi
export TARGET_BOARD="$(awk -F '[="]+' '/TARGET_BOARD/{print $2}' .config)"
export TARGET_SUBTARGET="$(awk -F '[="]+' '/TARGET_SUBTARGET/{print $2}' .config)"
if [[ `grep -c "CONFIG_TARGET_x86_64=y" .config` -eq '1' ]]; then
          export TARGET_PROFILE="x86-64"
elif [[ `grep -c "CONFIG_TARGET.*DEVICE.*=y" .config` -eq '1' ]]; then
          export TARGET_PROFILE="$(egrep -o "CONFIG_TARGET.*DEVICE.*=y" .config | sed -r 's/.*DEVICE_(.*)=y/\1/')"
else
          export TARGET_PROFILE="armvirt"
fi
if [ "${REGULAR_UPDATE}" == "true" ]; then
          source build/$firmware/upgrade.sh && Diy_Part2
fi
echo
rm -rf ../{Lede_source,Lienol_source,Mortal_source,openwrt_amlogic}
# 为编译做最后处理
BY_INFORMATION="false"
source build/${firmware}/common.sh && Diy_chuli
export COMFIRMWARE="openwrt/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
}

function configure_nginx() {
ECHOG "正在下载DL文件,请耐心等待..."
QLMEUN="输入[ Nn ]回车,退出下载，更换节点后按回车继续尝试下载DL"
while :; do
[[ -n ${QLMEUN2} ]] && ECHOG "${QLMEUN2}"
rm -fr build.log
make -j8 download 2>&1 |tee build.log
find dl -size -1024c -exec ls -l {} \;
find dl -size -1024c -exec rm -f {} \;
read -p " ${QLMEUN}： " MENU
if [[ `grep -c "make with -j1 V=s or V=sc" build.log` -ge '1' ]]; then
	S="Y"
fi
if [[ ${MENU} == "N" ]] || [[ ${MENU} == "n" ]]; then
	S="N"
fi
case $S in
	Y)
		echo
		ECHOG "DL文件下载成功"
	break
	;;
	N)
		echo
		ECHOR "退出安装程序!"
		echo
		sleep 1
		exit 1
	break
    	;;
    	*)
		QLMEUN="输入[ Nn ]回车,退出下载，更换节点后按回车继续尝试下载DL"
		QLMEUN2="正在重新下载DL文件"
	;;
esac
done
}

function generate_certificate() {
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
sleep 15
make -j$(nproc) V=s 2>&1 |tee build.log
}

function install_xray_ws() {
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
			export Modelfile="Lede_source"
			export PATH1="$PWD/openwrt/build/${firmware}"
			ECHOG "您选择了：Lede_5.4内核,LUCI 18.06版本"
			install_xray_ws
		break
		;;
		2)
			export firmware="Lienol_source"
			export Modelfile="Lienol_source"
			export PATH1="$PWD/openwrt/build/${firmware}"
			ECHOG "您选择了：Lienol_4.14内核,LUCI 19.07版本"
			install_xray_ws
		break
		;;
		3)
			export firmware="Mortal_source"
			export Modelfile="Mortal_source"
			export PATH1="$PWD/openwrt/build/${firmware}"
			ECHOG "您选择了：Immortalwrt_5.4内核,LUCI 21.02版本"
			install_xray_ws
		break
		;;
		4)
			export firmware="openwrt_amlogic"
			export Modelfile="openwrt_amlogic"
			export PATH1="$PWD/openwrt/build/${firmware}"
			ECHOG "您选择了：N1和晶晨系列CPU盒子专用"
			install_xray_ws
		break
		;;
		5)
			rm -rf compile.sh
			ECHOG "您选择了退出编译程序"
			exit 0
		break
    		;;
    		*)
			ECHOY "警告：输入错误,请输入正确的编号!"
		;;
	esac
	done
}
menu "$@"

#!/usr/bin/env bash

#====================================================
#	System Request:Ubuntu 18.04+/20.04+
#	Author:	281677160
#	Dscription: openwrt onekey Management
#	github: https://github.com/281677160/danshui
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
ERROR="${Red}[ERROR]${Font}"

# 变量
export GITHUB_WORKSPACE="$PWD"
export Home="${GITHUB_WORKSPACE}/openwrt"
export NETIP="${Home}/package/base-files/files/etc/networkip"
export date1="$(date +'%m-%d')"

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
function ECHOYY() {
  echo -e "${Yellow} $1 ${Font}"
}
function ECHOGG() {
  echo -e "${Green} $1 ${Font}"
}
  function ECHORR() {
  echo -e "${Red} $1 ${Font}"
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
    rm -rf openwrt
    rm -rf amlogic-s9xxx
    rm -rf build-actions
    rm -rf common
    rm -rf ${GITHUB_WORKSPACE}/OP_DIY
    echo
    exit 1
  fi
}

if [[ "$USER" == "root" ]]; then
  print_error "警告：请勿使用root用户编译，换一个普通用户吧~~"
  exit 1
fi

function op_busuhuanjing() {
cd ${GITHUB_WORKSPACE}
  clear
  echo
  ECHORR "|*******************************************|"
  ECHOGG "|                                           |"
  ECHOYY "|    首次编译,请输入Ubuntu密码继续下一步    |"
  ECHOGG "|                                           |"
  ECHOYY "|              编译环境部署                 |"
  ECHORR "|                                           |"
  ECHOGG "|*******************************************|"
  echo
  sudo apt-get update -y
  sudo apt-get install -y systemd build-essential asciidoc binutils bzip2 gawk gettext git libncurses5-dev libz-dev patch python3 python2.7 unzip zlib1g-dev lib32gcc1 libc6-dev-i386 lib32stdc++6 subversion flex uglifyjs git-core gcc-multilib p7zip p7zip-full msmtp libssl-dev texinfo libglib2.0-dev xmlto qemu-utils upx libelf-dev autoconf automake libtool autopoint device-tree-compiler g++-multilib antlr3 gperf wget curl rename libpcap0.8-dev swig rsync
  judge "部署编译环境"
}

function op_kongjian() {
  cd ${GITHUB_WORKSPACE}
  export Ubunkj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1')"
  export FINAL=`echo ${Ubunkj: -1}`
  if [[ "${FINAL}" =~ (M|K) ]]; then
    print_error "敬告：可用空间小于[ 1G ]退出编译,建议可用空间大于20G"
    sleep 1
    exit 1
  fi
  export Ubuntu_kj="$(df -h|grep -v tmpfs |grep "/dev/.*" |awk '{print $4}' |awk 'NR==1' |sed 's/.$//g')"
  if [[ "${Ubuntu_kj}" -lt "20" ]];then
    ECHOY "您当前系统可用空间为${Ubuntu_kj}G"
    print_error "敬告：可用空间小于[ 20G ]编译容易出错,建议可用空间大于20G,是否继续?"
    read -p " 直接回车退出编译，按[Y/y]回车则继续编译： " YN
    case ${YN} in
      [Yy]) 
        ECHOG  "可用空间太小严重影响编译,请满天神佛保佑您成功吧！"
      ;;
      *)
        ECHOY  "您已取消编译,请清理Ubuntu空间或增加硬盘容量..."
        sleep 1
        exit 0
      ;;
    esac
  fi
}

function op_diywenjian() {
  cd ${GITHUB_WORKSPACE}
  if [[ ! -d ${GITHUB_WORKSPACE}/OP_DIY ]]; then
    git clone https://github.com/281677160/bendi
    judgeopen "OP_DIY文件下载"
    cp -Rf bendi/OP_DIY ${GITHUB_WORKSPACE}/OP_DIY
    rm -rf bendi
  fi
}

function bianyi_xuanxiang() {
  cd ${GITHUB_WORKSPACE}
  bash ${GITHUB_WORKSPACE}/OP_DIY/${firmware}/settings.ini
  echo
  echo
  ECHOGG "是否需要选择机型和增删插件?"
  read -p " [输入[ Y/y ]回车确认，直接回车则为否]： " MENU
  case $MENU in
    [Yy])
      export Menuconfig="true"
      ECHOYY "您执行机型和增删插件命令,请耐心等待程序运行至窗口弹出进行机型和插件配置!"
    ;;
    *)
      export Menuconfig="false"
      ECHORR "您已关闭选择机型和增删插件设置！"
    ;;
  esac

  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    export Github=${Github}
    ECHOYY "您的Github地址为：$Github"
    export Apidz="${Github##*com/}"
    export Author="${Apidz%/*}"
    export CangKu="${Apidz##*/}"
  fi
  sleep 2
}

function op_repo_branch() {
  cd ${GITHUB_WORKSPACE}
  ECHOG "正在下载源码中,请耐心等候~~~"
  rm -rf openwrt && git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" openwrt
  judgeopen "${firmware}源码下载"
}

function ec_repo_branch() {
  cd ${GITHUB_WORKSPACE}
  ECHOG "正在下载源码中,请耐心等候~~~"
  rm -rf openwrte && git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" openwrte
  judgeopen "${firmware}源码下载"
  ECHOG "正在处理数据,请耐心等候~~~"
  cp -rf openwrt/{build_dir,staging_dir,config_bf} ${GITHUB_WORKSPACE}/openwrte
  rm -fr openwrt && mv -f openwrte openwrt
}

function qx_repo_branch() {
  cd ${GITHUB_WORKSPACE}
  ECHOG "正在下载源码中,请耐心等候~~~"
  rm -rf openwrte && git clone -b "$REPO_BRANCH" --single-branch "$REPO_URL" openwrte
  judgeopen "${firmware}源码下载"
  ECHOG "正在处理数据,请耐心等候~~~"
  if [[ -f ${Home}/config_bf ]]; then
    cp -rf ${Home}/config_bf ${GITHUB_WORKSPACE}/openwrte
  else
    cp -rf ${Home}/.config ${GITHUB_WORKSPACE}/openwrte/config_bf
  fi
  rm -fr openwrt && mv -f openwrte openwrt
}

function amlogic_s9xxx() {
  cd ${GITHUB_WORKSPACE}
  if [[ "${firmware}" == "openwrt_amlogic" ]]; then
    ECHOY "正在下载打包所需的内核,请耐心等候~~~"
    if [[ -d amlogic/amlogic-s9xxx ]]; then
      ECHOGG "发现老旧晶晨内核文件存在，请输入ubuntu密码删除老旧内核"
      sudo rm -rf amlogic
    fi
    mkdir -p amlogic
    mkdir -p amlogic/openwrt-armvirt
    rm -rf amlogic-s9xxx && svn co https://github.com/ophub/amlogic-s9xxx-openwrt/trunk/amlogic-s9xxx amlogic-s9xxx
    judgeopen "amlogic内核下载"
    rm -rf amlogic-s9xxx/{.svn,README.cn.md,README.md} > /dev/null 2>&1
    mv amlogic-s9xxx amlogic
    curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/make > amlogic/make
    curl -fsSL https://raw.githubusercontent.com/ophub/amlogic-s9xxx-openwrt/main/.github/workflows/build-openwrt-lede.yml > amlogic/op_kernel
    judge "内核运行文件下载"
    chmod 777 amlogic/make
  fi
  echo "${Core}" > ${Home}/${Core}
}

function op_jiaoben() {
  cd ${GITHUB_WORKSPACE}
  git clone https://github.com/281677160/build-actions
  judgeopen "编译脚本下载"
  chmod -R +x build-actions/build && cp -Rf build-actions/build ${Home}
  rm -rf build-actions
  git clone https://github.com/281677160/common
  judgeopen "额外扩展脚本下载"
  chmod -R +x common && cp -Rf common ${Home}/build
  rm -rf common
  cp -Rf ${Home}/build/common/*.sh ${Home}/build/${firmware}
}

function op_diy_zdy() {
  ECHOG "正在下载插件包,请耐心等候~~~"
  cd $Home
  ./scripts/feeds update -a > /dev/null 2>&1
  source "${PATH1}/common.sh" && ${Diy_zdy}
  judge "passwall和ssr plus下载"
  source build/${firmware}/common.sh && Diy_all
  judge "插件包下载"
}

function op_diy_part() {
  cd $Home
  echo "
  uci set network.lan.ipaddr='$ip'
  uci commit network
  " > $NETIP
  sed -i '/CYXluq4wUazHjmCDBCqXF/d' ${ZZZ} > /dev/null 2>&1
  sed -i "s/OpenWrt /compiled in $(TZ=UTC-8 date "+%Y.%m.%d") @ OpenWrt /g" ${ZZZ}
  sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ${Home}/feeds/luci/applications` > /dev/null 2>&1
  sed -i 's/"网络存储"/"NAS"/g' `grep "网络存储" -rl ${Home}/package` > /dev/null 2>&1
  sed -i 's/"带宽监控"/"监控"/g' `grep "带宽监控" -rl ${Home}/feeds/luci/applications` > /dev/null 2>&1
  sed -i 's/"Argon 主题设置"/"Argon设置"/g' `grep "Argon 主题设置" -rl ${Home}/feeds/luci` > /dev/null 2>&1
}

function op_feeds_update() {
  ECHOG "正在加载源和安装源,请耐心等候~~~"
  cd $Home
  ./scripts/feeds update -a
  ./scripts/feeds install -a > /dev/null 2>&1
  ./scripts/feeds install -a
  if [[ -f ${Home}/config_bf ]]; then
    cp -rf ${Home}/config_bf ${Home}/.config
  else
    cp -rf ${Home}/build/${firmware}/.config ${Home}/.config
  fi
  if [[ `grep -c "CONFIG_PACKAGE_luci-theme-argon=y" ${Home}/.config` == '0' ]]; then
    echo -e "\nCONFIG_PACKAGE_luci-theme-argon=y" >> ${Home}/.config
  fi
}

function op_upgrade1() {
  cd $Home
  echo "Compile_Date=$(date +%Y%m%d%H%M)" > Openwrt.info && source Openwrt.info
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    source build/$firmware/upgrade.sh && Diy_Part1
  fi
}

function op_menuconfig() {
  cd $Home
  if [[ "${Menuconfig}" == "true" ]]; then
    make menuconfig
  fi
}

function make_defconfig() {
  ECHOG "正在生成配置文件，请稍后..."
  cd $Home
  source ${Home}/build/${firmware}/common.sh && Diy_chajian
  make defconfig
  ./scripts/diffconfig.sh > ${Home}/config_bf
  if [ -n "$(ls -A "${Home}/Chajianlibiao" 2>/dev/null)" ]; then
    clear
    echo
    echo
    chmod -R +x ${Home}/CHONGTU
    source ${Home}/CHONGTU
    rm -rf {CHONGTU,Chajianlibiao}
    ECHOG "如需重新编译请按 Ctrl+C 结束此次编译，否则30秒后继续编译!"
    make defconfig > /dev/null 2>&1
    sleep 30
  fi
}

function op_config() {
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
  export OPENGUJIAN="openwrt/bin/targets/${TARGET_BOARD}/${TARGET_SUBTARGET}"
}

function op_upgrade2() {
  cd $Home
  if [ "${REGULAR_UPDATE}" == "true" ]; then
    source build/$firmware/upgrade.sh && Diy_Part2
  fi
}

function openwrt_zuihouchuli() {
  # 为编译做最后处理
  cd $Home
  source build/${firmware}/common.sh && Diy_chuli
}

function op_download() {
  cd $Home
  ECHOG "下载DL文件，请耐心等候..."
  rm -fr ${Home}/build.log
  make -j8 download 2>&1 |tee ${Home}/build.log
  find dl -size -1024c -exec ls -l {} \;
  find dl -size -1024c -exec rm -f {} \;
  if [[ `grep -c "make with -j1 V=s or V=sc" ${Home}/build.log` == '0' ]] || [[ `grep -c "ERROR" ${Home}/build.log` == '0' ]]; then
    ECHOG "DL文件下载成功"
  else
    clear
    echo
    print_error "下载DL失败，更换节点后再尝试下载？"
    QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或输入[N/n]回车,退出编译"
    while :; do
        read -p " [${QLMEUN}]： " XZDLE
        case $XZDLE in
            [Yy])
                op_download
            break
            ;;
            [Nn])
                ECHOR "退出编译程序!"
                sleep 2
                exit 1
            break
            ;;
            *)
                QLMEUN="请更换节点后按[Y/y]回车继续尝试下载DL，或现在输入[N/n]回车,退出编译"
            ;;
        esac
    done
  fi
}

function op_cpuxinghao() {
  cd $Home
  rm -rf build.log
  cat /proc/cpuinfo | grep name | cut -f2 -d: | uniq -c > CPU
  cat /proc/cpuinfo | grep "cpu cores" | uniq >> CPU
  sed -i 's|[[:space:]]||g; s|^.||' CPU && sed -i 's|CPU||g; s|pucores:||' CPU
  CPUNAME="$(awk 'NR==1' CPU)" && CPUCORES="$(awk 'NR==2' CPU)"
  rm -rf CPU
  clear
  ECHOG "您的CPU型号为[ ${CPUNAME} ]"
  ECHOG "在Ubuntu使用核心数为[ ${CPUCORES} ],线程数为[ $(nproc) ]"
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
  sleep 5
}

function op_make() {
  cd $Home
  export Begin="$(date "+%Y/%m/%d-%H.%M")"
  ECHOG "正在编译固件，请耐心等待..."
  npro="$(nproc)"
  if [[ "${npro}" -gt "16" ]];then
    npro="16"
  fi
  rm -fr ${COMFIRMWARE}/*
  rm -fr ${Home}/bin/Firmware/*
  PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin make -j${npro} V=s 2>&1 |tee build.log
  if [[ ${firmware} == "Mortal_source" ]] || [[ "${firmware}" == "Tianling_source" ]]; then
    if [[ `ls -a ${COMFIRMWARE} | grep -c "immortalwrt"` == '0' ]]; then
      if [[ ${byop} == "1" ]]; then
        echo "shibai" >${Home}/build/shibai
      fi
      print_error "编译失败~~!"
      explorer.exe .
      ECHOG "请查看openwrt文件夹里面的[build.log]日志文件查找失败原因"
      sleep 1
      exit 1
    fi
  else
    if [[ `ls -a ${COMFIRMWARE} | grep -c "openwrt"` == '0' ]]; then
      if [[ ${byop} == "1" ]]; then
        echo "shibai" >${Home}/build/shibai
      fi
      print_error "编译失败~~!"
      explorer.exe .
      ECHOG "请查看openwrt文件夹里面的[build.log]日志文件查找失败原因"
      sleep 1
      exit 1
    fi
  fi
  echo "chenggong" >${Home}/build/chenggong
  rm -rf ${Home}/build.log
}

function op_upgrade3() {
  cd $Home
  if [[ "${REGULAR_UPDATE}" == "true" ]]; then
    cp -Rf ${Home}/bin/targets/*/* ${Home}/upgrade
    source ${Home}/build/${firmware}/upgrade.sh && Diy_Part3
  fi
  if [[ `ls -a ${Home}/bin/Firmware | grep -c "${Compile_Date}"` -ge '1' ]]; then
    ECHOY "加入‘定时升级固件插件’的固件已经放入[bin/Firmware]文件夹中"
    export dsgx="加入‘定时升级固件插件’的固件已经放入[bin/Firmware]文件夹中"
    export upgra="1"
  else
    print_error "加入‘定时升级固件插件’的固件失败，您的机型或者不支持定时更新!"
    export upgra="0"
  fi
  cd ${COMFIRMWARE}
  rename -v "s/^immortalwrt/openwrt/" * > /dev/null 2>&1
  if [[ -f ${GITHUB_WORKSPACE}/Clear ]]; then
    mv -f ${GITHUB_WORKSPACE}/Clear ./
    chmod +x Clear && source Clear
    rm -fr Clear
  fi
  rename -v "s/^openwrt/${date1}-${CODE}/" * > /dev/null 2>&1
  cd ${Home}
}

function op_cowtransfer() {
  if [[ "${UPLOAD_COWTRANSFER}" == "true" ]]; then
    ECHOY "正在上传固件至奶牛快传中，请稍后..."
    cd ${GITHUB_WORKSPACE}
    curl -fsSL git.io/file-transfer | sh
    mv ${COMFIRMWARE}/packages ${Home}/bin/targets/${TARGET_BOARD}/packages
    ./transfer cow --block 2621440 -s -p 64 --no-progress ${COMFIRMWARE} 2>&1 | tee cowtransfer.log > /dev/null 2>&1
    export cow="$(cat cowtransfer.log | grep https | cut -f3 -d" ")"
    echo "${cow}" > ${Home}/bin/奶牛快传链接
    ECHOY "奶牛快传：${cow}"
    rm -rf ${GITHUB_WORKSPACE}/cowtransfer.log
    rm -rf ${GITHUB_WORKSPACE}/transfer
  fi
}

function op_amlogic() {
  cd ${GITHUB_WORKSPACE}
  if [[ `ls -a ${Home}/bin/targets/armvirt/64 | grep -c "tar.gz"` == '0' ]]; then
    print_error "没发现tar.gz格式固件存在"
    exit 1
  fi
  if [[ ! -f ${GITHUB_WORKSPACE}/amlogic/make ]]; then
    print_error "没发现打包运行文件存在"
    exit 1
  fi
  
  ECHOY "全部可打包机型：s905x3_s905x2_s905x_s905d_s922x_s912"
  ECHOGG "设置要打包固件的机型[ 直接回车则默认 N1/s905d ]"
  read -p " 请输入您要设置的机型：" model
  export model=${model:-"s905d"}
  ECHOYY "您设置的机型为：${model}"
  echo
  Make_kernel="$(cat ${GITHUB_WORKSPACE}/amlogic/op_kernel |grep ./make |cut -d "k" -f3 |sed s/[[:space:]]//g)"
  ECHOGG "设置打包的内核版本[ 直接回车则默认 ${Make_kernel} ]"
  read -p " 请输入您要设置的内核：" kernel
  export kernel=${kernel:-"${Make_kernel}"}
  ECHOYY "您设置的内核版本为：${kernel}"
  echo
  ECHOGG "设置ROOTFS分区大小[ 直接回车则默认 960 ]"
  read -p " 请输入ROOTFS分区大小：" rootfs
  export rootfs=${rootfs:-"960"}
  ECHOYY "您设置的ROOTFS分区大小为：${rootfs}"
  minsize="$(egrep -o "ROOT_MB=[0-9]+" ${GITHUB_WORKSPACE}/amlogic/make)"
  rootfssize="ROOT_MB=${rootfs}"
  sed -i "s/${minsize}/${rootfssize}/g" ${GITHUB_WORKSPACE}/amlogic/make
  echo
  rm -rf ${GITHUB_WORKSPACE}/amlogic/out/*
  rm -rf ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/*
  cp -Rf ${Home}/bin/targets/armvirt/*/*.tar.gz ${GITHUB_WORKSPACE}/amlogic/openwrt-armvirt/
  ECHOGG "请输入ubuntu密码进行固件打包程序"
  cd amlogic && sudo ./make -d -b ${model} -k ${kernel}
  if [[ `ls -a ${GITHUB_WORKSPACE}/amlogic/out | grep -c "openwrt"` -ge '1' ]]; then
    ECHOY "打包完成，固件存放在[amlogic/out]文件夹"
    explorer.exe .
  else
    print_error "打包失败，请再次尝试!"
  fi
}

function op_end() {
  clear
  echo
  echo
  export End="$(date "+%Y/%m/%d-%H.%M")"
  if [[ ${firmware} == "openwrt_amlogic" ]]; then
    ECHOY "使用[ ${firmware} ]文件夹，编译[ N1和晶晨系列盒子专用固件 ]顺利编译完成~~~"
  else
    ECHOY "使用[ ${firmware} ]文件夹，编译[ ${TARGET_PROFILE} ]顺利编译完成~~~"
  fi
  ECHOY "后台地址: $ip"
  ECHOY "用户名: root"
  ECHOY "密 码: 无"
  ECHOG "开始时间：${Begin}"
  ECHOG "结束时间：${End}"
  ECHOY "固件已经存入${OPENGUJIAN}文件夹中"
  if [[ "${firmware}" == "openwrt_amlogic" ]]; then
    ECHOR "提示：再次输入编译命令可选择打包N1和晶晨系列盒子专用固件"
  fi
  if [[ "${upgra}" == "1" ]]; then
    ECHOG "${dsgx}"
  fi
  explorer.exe .
}

function op_firmware() {
  if [[ "${firmware}" == "Lede_source" ]] || [[ -n "$(ls -A "${Home}/.Lede_core" 2>/dev/null)" ]]; then
    export firmware="Lede_source"
    export CODE="lede"
    export Modelfile="Lede_source"
    export Core=".Lede_core"
    export PATH1="${Home}/build/${firmware}"
    export REPO_URL="https://github.com/coolsnowwolf/lede"
    export REPO_BRANCH="master"
    export ZZZ="${Home}/package/lean/default-settings/files/zzz-default-settings"
    export Diy_zdy="Diy_lede"
    export CONFIG_FILE=".config"
    export DIY_PART_SH="diy-part.sh"
    export OpenWrt_name="18.06"
    [[ -f ${GITHUB_WORKSPACE}/ip ]] && source ${GITHUB_WORKSPACE}/ip
  fi
  if [[ "${firmware}" == "Lienol_source" ]] || [[ -n "$(ls -A "${Home}/.Lienol_core" 2>/dev/null)" ]]; then
    export firmware="Lienol_source"
    export CODE="lienol"
    export Modelfile="Lienol_source"
    export Core=".Lienol_core"
    export PATH1="${Home}/build/${firmware}"
    export REPO_URL="https://github.com/Lienol/openwrt"
    export REPO_BRANCH="19.07"
    export ZZZ="${Home}/package/default-settings/files/zzz-default-settings"
    export Diy_zdy="Diy_lienol"
    export CONFIG_FILE=".config"
    export DIY_PART_SH="diy-part.sh"
    export OpenWrt_name="19.07"
    [[ -f ${GITHUB_WORKSPACE}/ip ]] && source ${GITHUB_WORKSPACE}/ip
  fi
  if [[ "${firmware}" == "Mortal_source" ]] || [[ -n "$(ls -A "${Home}/.Mortal_core" 2>/dev/null)" ]]; then
    export firmware="Mortal_source"
    export CODE="mortal"
    export Modelfile="Mortal_source"
    export Core=".Mortal_core"
    export PATH1="${Home}/build/${firmware}"
    export REPO_URL="https://github.com/immortalwrt/immortalwrt"
    export REPO_BRANCH="openwrt-21.02"
    export ZZZ="${Home}/package/emortal/default-settings/files/zzz-default-settings"
    export Diy_zdy="Diy_mortal"
    export CONFIG_FILE=".config"
    export DIY_PART_SH="diy-part.sh"
    export OpenWrt_name="21.02"
    [[ -f ${GITHUB_WORKSPACE}/ip ]] && source ${GITHUB_WORKSPACE}/ip
  fi
  if [[ "${firmware}" == "Tianling_source" ]] || [[ -n "$(ls -A "${Home}/.Tianling_core" 2>/dev/null)" ]]; then
    export firmware="Tianling_source"
    export CODE="tianling"
    export Modelfile="Tianling_source"
    export Core=".Tianling_core"
    export PATH1="${Home}/build/${firmware}"
    export REPO_URL="https://github.com/immortalwrt/immortalwrt"
    export REPO_BRANCH="openwrt-18.06"
    export ZZZ="${Home}/package/emortal/default-settings/files/zzz-default-settings"
    export Diy_zdy="Diy_Tianling"
    export CONFIG_FILE=".config"
    export DIY_PART_SH="diy-part.sh"
    export OpenWrt_name="tl-18.06"
    [[ -f ${GITHUB_WORKSPACE}/ip ]] && source ${GITHUB_WORKSPACE}/ip
  fi
  if [[ "${firmware}" == "openwrt_amlogic" ]] || [[ -n "$(ls -A "${Home}/.amlogic_core" 2>/dev/null)" ]]; then
    export firmware="openwrt_amlogic"
    export CODE="lede"
    export Modelfile="openwrt_amlogic"
    export Core=".amlogic_core"
    export PATH1="${Home}/build/${firmware}"
    export REPO_URL="https://github.com/coolsnowwolf/lede"
    export REPO_BRANCH="master"
    export ZZZ="${Home}/package/lean/default-settings/files/zzz-default-settings"
    export Diy_zdy="Diy_lede"
    export CONFIG_FILE=".config"
    export DIY_PART_SH="diy-part.sh"
    export OpenWrt_name="18.06"
    [[ -f ${GITHUB_WORKSPACE}/ip ]] && source ${GITHUB_WORKSPACE}/ip
  fi
}

function openwrt_qx() {
      cd ${GITHUB_WORKSPACE}
      if [[ -d amlogic/amlogic-s9xxx ]]; then
        ECHOGG "发现老旧晶晨内核文件存在，请输入ubuntu密码删除老旧内核"
        sudo rm -rf amlogic
      fi
      if [[ -d ${GITHUB_WORKSPACE}/openwrt ]]; then
        ECHOGG "发现老源码存在，正在删除老源码"
        rm -rf ${GITHUB_WORKSPACE}/openwrt
      fi
      openwrt_by
}

function openwrt_sb() {
    ECHOY "因上回编译失败，正在使用保留配置全新编译"
    sleep 3
    byop="1"
    op_firmware
    op_kongjian
    bianyi_xuanxiang
    op_ip
    qx_repo_branch
    amlogic_s9xxx
    op_jiaoben
    op_diy_zdy
    op_diy_part
    op_feeds_update
    op_upgrade1
    op_menuconfig
    make_defconfig
    op_config
    op_upgrade2
    openwrt_zuihouchuli
    op_download
    op_cpuxinghao
    op_make
    op_upgrade3
    op_end
    op_cowtransfer
}

function openwrt_by() {
    op_busuhuanjing
    op_firmware
    op_kongjian
    bianyi_xuanxiang
    op_ip
    op_repo_branch
    amlogic_s9xxx
    op_jiaoben
    op_diy_zdy
    op_diy_part
    op_feeds_update
    op_upgrade1
    op_menuconfig
    make_defconfig
    op_config
    op_upgrade2
    openwrt_zuihouchuli
    op_download
    op_cpuxinghao
    op_make
    op_upgrade3
    op_end
    op_cowtransfer
}
menu() {
  clear
  echo
  cd ${GITHUB_WORKSPACE}
  ECHOY " 1. Lede_5.4内核,LUCI 18.06版本(Lede_source)"
  ECHOY " 2. Lienol_4.14内核,LUCI 17.01版本(Lienol_source)"
  ECHOY " 3. Immortalwrt_5.4内核,LUCI 21.02版本(Mortal_source)"
  ECHOY " 4. Immortalwrt_4.14内核,LUCI 18.06版本(Tianling_source)"
  ECHOY " 5. N1和晶晨系列CPU盒子专用(openwrt_amlogic)"
  ECHOY " 6. 退出编译程序"
  echo
  XUANZHEOP="请输入数字"
  while :; do
  read -p " ${XUANZHEOP}： " CHOOSE
  case $CHOOSE in
    1)
      export firmware="Lede_source"
      ECHOG "您选择了：Lede_5.4内核,LUCI 18.06版本"
      openwrt_qx
    break
    ;;
    2)
      export firmware="Lienol_source"
      ECHOG "您选择了：Lienol_4.14内核,LUCI 17.01版本"
      openwrt_qx
    break
    ;;
    3)
      export firmware="Mortal_source"
      ECHOG "您选择了：Immortalwrt_5.4内核,LUCI 21.02版本"
      openwrt_qx
    break
    ;;
    4)
      export firmware="Tianling_source"
      ECHOG "您选择了：Immortalwrt_4.14内核,LUCI 18.06版本"
      openwrt_qx
    break
    ;;
    5)
      export firmware="openwrt_amlogic"
      ECHOG "您选择了：N1和晶晨系列CPU盒子专用"
      openwrt_qx
    break
    ;;
    6)
      ECHOR "您选择了退出编译程序"
      exit 0
    break
    ;;
    *)
      XUANZHEOP="请输入正确的数字编号!"
    ;;
    esac
    done
}

menuop() {
  op_firmware
  op_config
  cd ${GITHUB_WORKSPACE}
  clear
  echo
  echo -e " ${Blue}当前源码${Font}：${Green}${firmware}${Font}"
  echo -e " ${Blue}编译机型${Font}：${Green}${TARGET_PROFILE}${Font}"
  echo
  echo -e " ${Green}1${Font}.${Yellow}保留配置全新编译${Font}"
  echo -e " ${Green}2${Font}.${Yellow}保留缓存和配置二次编译${Font}"
  echo -e " ${Green}3${Font}.${Yellow}不更新插件和源码二次编译${Font}"
  echo -e " ${Green}4${Font}.${Yellow}更换源码编译${Font}"
  echo -e " ${Green}5${Font}.${Yellow}打包N1和晶晨系列CPU固件${Font}"
  echo -e " ${Green}6${Font}.${Yellow}退出${Font}"
  echo
  XUANZHE="请输入数字"
  while :; do
  read -p " ${XUANZHE}：" menu_num
  case $menu_num in
  1)
    byop="1"
    op_firmware
    op_kongjian
    op_diywenjian
    bianyi_xuanxiang
    op_ip
    qx_repo_branch
    amlogic_s9xxx
    op_jiaoben
    op_diy_zdy
    op_diy_part
    op_feeds_update
    op_upgrade1
    op_menuconfig
    make_defconfig
    op_config
    op_upgrade2
    openwrt_zuihouchuli
    op_download
    op_cpuxinghao
    op_make
    op_upgrade3
    op_end
    op_cowtransfer
  break
  ;;
  2)
    byop="1"
    op_firmware
    op_kongjian
    op_diywenjian
    bianyi_xuanxiang
    op_ip
    ec_repo_branch
    amlogic_s9xxx
    op_jiaoben
    op_diy_zdy
    op_diy_part
    op_feeds_update
    op_upgrade1
    op_menuconfig
    make_defconfig
    op_config
    op_upgrade2
    openwrt_zuihouchuli
    op_download
    op_cpuxinghao
    op_make
    op_upgrade3
    op_end
    op_cowtransfer
  break
  ;;
  3)
    byop="0"
    op_firmware
    bianyi_xuanxiang
    op_ip
    op_upgrade1
    op_menuconfig
    make_defconfig
    op_config
    op_upgrade2
    rm -rf ${Home}/dl
    op_download
    op_make
    op_upgrade3
    op_end
    op_cowtransfer
  break
  ;;
  4)
    menu
  break
  ;;
  5)
    op_amlogic
  break
  ;;   
  6)
    exit 0
    break
  ;;
  *)
    XUANZHE="请输入正确的数字编号!"
  ;;
  esac
  done
}
if [[ -f ${Home}/build/shibai ]]; then
	openwrt_sb
elif [[ -d ${Home}/build_dir ]] && [[ -d ${Home}/toolchain ]] && [[ -d ${Home}/tools ]] && [[ -d ${Home}/staging_dir ]] && [[ -f ${Home}/build/chenggong ]] && [[ -f ${Home}/.config ]]; then
	menuop "$@"
else
	menu "$@"
fi
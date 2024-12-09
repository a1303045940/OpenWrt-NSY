#!/bin/bash

# 修改默认IP
# sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config



# rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/themes/luci-theme-design
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/luci/applications/luci-app-netdata


# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  echo $repodir
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}


git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata

# Themes
# git clone --depth=1 -b 18.06 https://github.com/kiddin9/luci-theme-edge package/luci-theme-edge
# git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config
# git clone --depth=1 https://github.com/kenzok78/luci-theme-design package/luci-theme-design
# git clone --depth=1 https://github.com/xiaoqingfengATGH/luci-theme-infinityfreedom package/luci-theme-infinityfreedom
# git_sparse_clone main https://github.com/haiibo/packages luci-theme-opentomcat
git_sparse_clone main https://github.com/xiaomeng9597/openwrt-theme luci-theme-design

# 更改 Argon 主题背景
mkdir -p package/luci-theme-argon/htdocs/luci-static/argon/img
cp -f $GITHUB_WORKSPACE/images/bg1.jpg package/luci-theme-argon/htdocs/luci-static/argon/img/bg1.jpg

# iStore
git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
git_sparse_clone main https://github.com/linkease/istore luci

# 在线用户
git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# 修改本地时间格式
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 修改版本为编译日期
date_version=$(date +"%y.%m.%d")
orig_version=$(cat "package/lean/default-settings/files/zzz-default-settings" | grep DISTRIB_REVISION= | awk -F "'" '{print $2}')
sed -i "s/${orig_version}/R${date_version} by xiaomeng9597/g" package/lean/default-settings/files/zzz-default-settings

# 取消主题默认设置
# find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

# 默认不开启WiFi
sed -i "s/wireless.radio\${devidx}.disabled=0/wireless.radio\${devidx}.disabled=1/g" package/kernel/mac80211/files/lib/wifi/mac80211.sh

# 替换需要编译的内核版本
# sed -i -E 's/KERNEL_PATCHVER:=[0-9]+\.[0-9]+/KERNEL_PATCHVER:=5.15/' target/linux/rockchip/Makefile
# sed -i -E 's/KERNEL_TESTING_PATCHVER:=[0-9]+\.[0-9]+/KERNEL_TESTING_PATCHVER:=5.15/' target/linux/rockchip/Makefile

rm -f feeds/luci/applications/luci-app-ttyd/luasrc/view/terminal/terminal.htm
wget -P feeds/luci/applications/luci-app-ttyd/luasrc/view/terminal https://xiaomeng9597.github.io/terminal.htm

#集成CPU性能跑分脚本
cp -a $GITHUB_WORKSPACE/configfiles/coremark/* package/base-files/files/sbin/
chmod 755 package/base-files/files/sbin/coremark
chmod 755 package/base-files/files/sbin/coremark.sh

# 加入nsy_g68-plus初始化网络配置脚本
cp -f $GITHUB_WORKSPACE/configfiles/swconfig_install package/base-files/files/etc/init.d/swconfig_install
chmod 755 package/base-files/files/etc/init.d/swconfig_install

cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g68-plus.dts target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3568-nsy-g68-plus.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g16-plus.dts target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3568-nsy-g16-plus.dts

# 集成 nsy_g68-plus WiFi驱动
mkdir -p package/base-files/files/lib/firmware/mediatek
cp -f $GITHUB_WORKSPACE/configfiles/mt7915_eeprom.bin package/base-files/files/lib/firmware/mediatek/mt7915_eeprom.bin
cp -f $GITHUB_WORKSPACE/configfiles/mt7916_eeprom.bin package/base-files/files/lib/firmware/mediatek/mt7916_eeprom.bin

# 电工大佬的rtl8367b驱动资源包，暂时使用这样替换
wget https://github.com/xiaomeng9597/files/releases/download/files/rtl8367b.tar.gz
tar -xvf rtl8367b.tar.gz

# openwrt主线rtl8367b驱动资源包，暂时使用这样替换
# wget https://github.com/xiaomeng9597/files/releases/download/files/rtl8367b-openwrt.tar.gz
# tar -xvf rtl8367b-openwrt.tar.gz


./scripts/feeds update -a
./scripts/feeds install -a

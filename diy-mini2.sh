#!/bin/bash

# 修改默认IP
# sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate

# 更改默认 Shell 为 zsh
# sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
# sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config


# 替换需要编译的内核版本
# sed -i -E 's/KERNEL_PATCHVER:=[0-9]+\.[0-9]+/KERNEL_PATCHVER:=5.10/' target/linux/rockchip/Makefile
# sed -i -E 's/KERNEL_TESTING_PATCHVER:=[0-9]+\.[0-9]+/KERNEL_TESTING_PATCHVER:=5.10/' target/linux/rockchip/Makefile

rm -f feeds/luci/applications/luci-app-ttyd/luasrc/view/terminal/terminal.htm
wget -P feeds/luci/applications/luci-app-ttyd/luasrc/view/terminal https://xiaomeng9597.github.io/terminal.htm

#集成CPU性能跑分脚本
#cp -a $GITHUB_WORKSPACE/configfiles/coremark/* package/base-files/files/bin/
#chmod 755 package/base-files/files/bin/coremark
#chmod 755 package/base-files/files/bin/coremark.sh


# 加入nsy_g68-plus初始化网络配置脚本
cp -f $GITHUB_WORKSPACE/configfiles/swconfig_install package/base-files/files/etc/init.d/swconfig_install
chmod 755 package/base-files/files/etc/init.d/swconfig_install

cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g68-plus.dts target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3568-nsy-g68-plus.dts
cp -f $GITHUB_WORKSPACE/configfiles/dts/rk3568-nsy-g16-plus.dts target/linux/rockchip/files/arch/arm64/boot/dts/rockchip/rk3568-nsy-g16-plus.dts


./scripts/feeds update -a
./scripts/feeds install -a

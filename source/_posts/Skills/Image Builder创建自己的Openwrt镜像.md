title: Image Builder创建自己的Openwrt镜像
date: 2015-07-03 16:04:24
categories: Router
tags: [openwrt, wndr4300]

---

## 下载
```
wget http://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64.tar.bz2
tar xjvf OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64.tar.bz2
cd OpenWrt-ImageBuilder-ar71xx_nand-for-linux-x86_64/
```
<!-- more -->
## 配置
### 预定义的配置
运行make info来获得一个预定义配置的列表
```
Current Target: "ar71xx (Generic devices with NAND flash)"
Default Packages: base-files libc libgcc busybox dropbear mtd uci opkg netifd fstools kmod-gpio-button-hotplug swconfig kmod-ath9k wpad-mini uboot-envtools dnsmasq iptables ip6tables ppp ppp-mod-pppoe kmod-ipt-nathelper firewall odhcpd odhcp6c
Available Profiles:

WNDR4300:
        NETGEAR WNDR3700v4/WNDR4300
        Packages: kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-ledtrig-usbdev
NBG6716:
        Zyxel NBG 6716
        Packages: kmod-rtc-pcf8563 kmod-ath10k
```
如果不需要更改配置,直接就可以创建image了

```
make image PROFILE=WNDR4300
```

### 增加/修改配置
针对预编译包文件`ar71xx`的配置被放在`target/linux/ar71xx/nand/profiles`中。
编辑netgear.mk,将需要的包添加进去. 
```
vi target/linux/ar71xx/nand/profiles/netgear.mk
```
我这里是这样写的:
```
# 
# Copyright (C) 2009-2013 OpenWrt.org 
# 
# This is free software, licensed under the GNU General Public License v2. 
# See /LICENSE for more information. 
# 
 
define Profile/WNDR4300 
        NAME:=NETGEAR WNDR3700v4/WNDR4300 
        PACKAGES:=kmod-usb-core kmod-usb-ohci kmod-usb2 kmod-ledtrig-usbdev \ 
                  kmod-usb-storage block-mount kmod-fs-ext4 ntfs-3g nfs-kernel-server \ 
                  luci-app-ddns e2fsprogs transmission-web \ 
                  luci luci-theme-bootstrap \ 
                  curl python python-curl mtr 
endef 
 
define Profile/WNDR4300/Description 
        Package set optimized for the NETGEAR WNDR3700v4/WNDR4300 
endef 
 
$(eval $(call Profile,WNDR4300)) 

```
## 自定义分区
实现 WNDR4300路由器 overlay分区大于90MB的功能
修改文件`target/linux/ar71xx/image/Makefile`:
```
wndr4300_mtdlayout=mtdparts=ar934x-nfc:256k(u-boot)ro,256k(u-boot-env)ro,256k(caldata),512k(pot),2048k(language),512k(config),3072k(traffic_meter),2048k(kernel),23552k(ubi),25600k@0x6c0000(firmware),256k(caldata_backup),-(reserved)

#改为（将ubi和firmware增加96M，完全使用128M flash）

wndr4300_mtdlayout=mtdparts=ar934x-nfc:256k(u-boot)ro,256k(u-boot-env)ro,256k(caldata),512k(pot),2048k(language),512k(config),3072k(traffic_meter),2048k(kernel),121856k(ubi),123904k@0x6c0000(firmware),256k(caldata_backup),-(reserved)
```

## 文件
一个包含自定义文件的想要加入的目录可以通过使用FILES变量来指定，如果有必要的话自定义文件会替换掉默认已经存在的文件。
```
mkdir -p files/etc/config
#cp xxxxx
make image PROFILE=WNDR4300 FILES=files/
```
## 清理
想要清理临时编译文件和生成的镜像，使用make clean命令。


## tftp刷机

```
tftp 192.168.1.1
mode binary
put openwrt-ar71xx-nand-wndr4300-ubi-factory.img
quit
```

## 参考链接
- [Image Generator (Image Builder)](http://wiki.openwrt.org/zh-cn/doc/howto/obtain.firmware.generate)
- [编译Netgear WNDR4300路由器用Gargoyle（石像鬼）固件](http://blog.ltns.info/linux/build_gargoyle_firmware_for_netgear_wndr4300/)

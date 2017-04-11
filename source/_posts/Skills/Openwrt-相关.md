title: Openwrt 相关
date: 2015-06-28 16:41:10
categories: Router
tags: openwrt

---

# 配置IP地址
```
uci set network.wan.proto=dhcp
uci set network.lan.ipaddr=192.168.11.1
```
<!-- more -->
# 安装更新
1. 下载升级包
```
cd /tmp
wget http://downloads.openwrt.org/snapshots/trunk/ar71xx/openwrt-ar71xx-generic-wzr-hp-g300nh-squashfs-sysupgrade.bin 
wget http://downloads.openwrt.org/snapshots/trunk/ar71xx/md5sums 
```

2. 检测md5
```
md5sum -c md5sums
```
3. 升级
```
sysupgrade -v /tmp/openwrt-ar71xx-generic-wzr-hp-g300nh-squashfs-sysupgrade.bin
```

# 安装软件
## 安装luci
1. 安装luci-web
```
opkg update
opkg install luci
opkg install luci-theme-openwrt
```
2. 配置端口
```
uci delete uhttpd.main.listen_http
uci commit
uci set uhttpd.main.listen_http=192.168.1.1:80
uci commit
```
3. 重启httpd
```
/etc/init.d/uhttpd restart
```

## 安装USB挂载支持
```
opkg update
opkg install kmod-usb-storage block-mount kmod-fs-ext4 ntfs-3g
```

## 安装其他软件
```
opkg install transmission-web samba36-server minidlna nfs-kernel-server
opkg install openssh-sftp-server
```

## 升级所有包
```
opkg upgrade  $(opkg list-upgradable|awk '{print $1}')
```


# tftp刷机[WZR-HP-G300NH]
在Ubuntu上
```
sudo ifconfig eth0 192.168.11.2 
sudo arp -s 192.168.11.1  02:AA:BB:CC:DD:20
```
拔掉路由电源、
在终端输入:
```
tftp 
tftp> verbose 
提示Verbose mode on. 
tftp> binary 
提示 mode set to octet. 
tftp> trace 
提示 Packet tracing on. 
tftp> rexmt 1 
tftp> timeout 60 
tftp> connect 192.168.11.1 
tftp> put 1.bin
```


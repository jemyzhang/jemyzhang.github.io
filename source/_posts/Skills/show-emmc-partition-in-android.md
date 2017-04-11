title: 查看MMC分区信息
date: 2015-11-26 13:55:41
tags: [Android]
---
- 查看块设备列表
```
ls -l /dev/block
```
<!-- more -->
- 查看各分区名称
```
ls -l /dev/block/platform/[sdhci-tegra.3]/by-name
```
其中[sdhci-tegra.3]视具体设备而定
- 查看各分区容量
```
cat /sys/class/block/mmcblk0p1/size```
显示单位是records，1records=512byte
- 查看各分区容量
```
cat /proc/partitions
```
显示单位是blocks，1blocks=1K
- 查看格式和挂载
```
cat /etc/fstab
df -ah
cat /proc/mounts"
```

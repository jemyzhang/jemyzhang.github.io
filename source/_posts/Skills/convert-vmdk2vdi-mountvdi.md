title: VMDK转换为VDI，并mount
date: 2015-07-23 15:25:10
tags: [ubuntu, virtualbox]
---

## vmdk转换为vdi

```
VBoxManage clonehd --format VDI system.vmdk system.vdi
```
<!-- more -->

## mount vdi

- 下载[vdfuse](http://launchpadlibrarian.net/100437376/virtualbox-fuse_4.1.12-dfsg-2_amd64.deb)
  下载后无需安装，直接解压缩后获取usr目录中的vdfuse

- mount
  ```
   mkdir mnt
   sudo ./vdfuse -a -f system.vdi mnt
   ```
   可以看到mnt目录下多了几个文件：
   ![ls ./mnt](http://ww3.sinaimg.cn/large/6edc034cgw1eucqttjjzgj209400twef.jpg)
   然后使用`file`命令可以看到各分区的类型：
   ![file -s Partition1 Partition5 Partition6](http://ww1.sinaimg.cn/large/6edc034cgw1eucr34qyvdj20r301l75p.jpg)
   使用对应的命令mount即可。



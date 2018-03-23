title: Android init.rc主要事件以及服务
date: 2016-08-10
tags: [Android, System]

---

>Action/Service     描述
on early-init     设置init进程以及它创建的子进程的优先级，设置init进程的安全环境
on init     设置全局环境，为cpu accounting创建cgroup(资源控制)挂载点
on fs     挂载mtd分区
on post-fs     改变系统目录的访问权限
on post-fs-data     改变/data目录以及它的子目录的访问权限
on boot     基本网络的初始化，内存管理等等
service servicemanager     启动系统管理器管理所有的本地服务，比如位置、音频、Shared preference等等…
service zygote     启动zygote作为应用进程
<!-- more -->

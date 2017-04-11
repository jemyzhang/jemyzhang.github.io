title: 抓取openwrt软件包建立一个软件源镜像
date: 2015-07-03 14:58:09
categories: Router
tags: [openwrt, wndr4300, wndr3700]
---

最近上海电信抽风, Openwrt官方源几乎不可访问, 但是路由器最近被折腾坏了,重刷了Openwrt,结果安装ddns等软件时就苦逼了, `opkg update`半小时没有结束-_-!
网上各种搜索, 然后找到了这个文章[建立一个Openwrt软件源的镜像](http://www.shuyz.com/setup-openwrt-package-src-mirror.html), 其中带有一个python的grabber源码, 测试一下,发现却不适用WNDR4300 nand的镜像,因为这个镜像是分层目录的,所以就有了下面的修改版. [直接下载源码](https://github.com/jemyzhang/openwrt-package-grabber/raw/master/openwrt_package_grabber.py)
<!-- more -->
```
#!/usr/bin/env python  
# -*- coding: utf-8 -*-
#  
# Openwrt Package Grabber  
#  
# Copyright (C) 2014 http://shuyz.com
# modified by jemyzhang@2015.7
#     
# Usage:
# for WNDR4300/3700:
# python openwrt_package_grabber.py http://downloads.openwrt.org/barrier_breaker/14.07/ar71xx/nand/packages/ ./packages

import urllib2
import re
import os


def save_packages(url, location):
    location = os.path.abspath(location) + os.path.sep
    if not os.path.exists(location):
        os.makedirs(location)
    print 'fetching package list from ' + url
    content = urllib2.urlopen(url, timeout=15).read()

    print 'packages list ok, analysing...'
    pattern = r'<a href="(.*?)">'
    items = re.findall(pattern, content)

    cnt = 0
    for item in items:
        if item == '../':
            continue
        elif item[-1] == '/':
            save_packages(url + item, location + item)
        else:
            cnt += 1
            item = item.replace('%2b', '+')
            print 'downloading item %d: ' % (cnt) + item
            if os.path.isfile(location + item):
                print 'file exists, ignored.'
            else:
                rfile = urllib2.urlopen(url + item)
                with open(location + item, "wb") as code:
                    code.write(rfile.read())


if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3:
        print 'Usage: %s [openwrt url] [save location]'
    else:
        save_packages(sys.argv[1], sys.argv[2])

```

然后找台可以下载的电脑?VPS?下载软件包吧, 既然下载了,那么随便用什么方法,搭一个http服务器就可以继续玩下去了. 
感觉还是用`python -m SimpleHTTPServer`最为方便吧.

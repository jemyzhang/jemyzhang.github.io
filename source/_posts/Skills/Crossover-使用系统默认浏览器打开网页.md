title: Crossover 使用系统默认浏览器打开网页
date: 2015-05-12 10:20:48
tags: [ubuntu,wine,crossover]
---
1. 更改注册表
>Windows Registry Editor Version 5.00
>
>[HKEY_CLASSES_ROOT\http\shell\open\command]
@="\"C:\\windows\\system32\\winebrowser.exe\" -nohome %1"
>
>[HKEY_CLASSES_ROOT\https\shell\open\command]
@="\"C:\\windows\\system32\\winebrowser.exe\" -nohome %1"
<!-- more -->
2. 替换iexplore.exe.so
```
cd /usr/lib/wine/ [crossover: /opt/cxoffice/lib/wine/]
sudo mv iexplore.exe.so iexplore.exe.so.bak
sudo ln -s winebrowser.exe.so iexplore.exe.so
```

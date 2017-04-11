title: top查看指定进程
date: 2015-07-01 16:12:02
tags:
---

```
top -p `pidof [process name] | sed 's/ /,/g'`
```
或更简洁:
```
top -p `pgrep -d , [process name]`
```

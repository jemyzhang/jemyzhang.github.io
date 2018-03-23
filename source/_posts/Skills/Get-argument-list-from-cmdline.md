title: Get argument list from cmdline
author: jemyzhang
tags:
  - ShellScript
categories: []
date: 2016-07-11 10:31:00
---

```shell
pid=$(pidof $PROCNAME)
cat /proc/$pid/cmdline | xargs -0 echo
```
<!-- more -->

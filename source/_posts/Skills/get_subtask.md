title: 查看线程
date: 2016-09-29
tags: [shell, threads, ubuntu]

---

查看线程
===
```shell
awk '{print $1,$2,$14,$15}' /proc/2907/task/*/stat
```


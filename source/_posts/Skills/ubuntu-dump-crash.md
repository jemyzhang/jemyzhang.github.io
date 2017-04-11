title: Dump crash info
date: 2015-11-26 14:01:41
tags: [ubuntu, debug]
---

- install apport-retrace
```
sudo apt-get install apport-retrace
```

- usage
```
apport-retrace --stdout /var/crash/xxx.crash
```

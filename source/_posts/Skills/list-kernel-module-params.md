title: List loaded linux module parameter values
date: 2017-02-20
tags: [shell, skills, linux, snippets]
---
List loaded linux module parameter values
===

```sh
cat /proc/modules | cut -f 1 -d " " | while read module; do \
 echo "Module: $module"; \
 if [ -d "/sys/module/$module/parameters" ]; then \
  ls /sys/module/$module/parameters/ | while read parameter; do \
   echo -n "Parameter: $parameter --> "; \
   cat /sys/module/$module/parameters/$parameter; \
  done; \
 fi; \
 echo; \
done
```

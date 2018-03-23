title: Use password to protect a tgz file
categories: Linux
tags: [tgz, passwd, gpg]
date: 2016-09-30 16:36:00

---

```shell
# encrypt
gpg -o documents.tgz.gpg --symmetric documents.tgz
# decrypt
gpg documents.tgz.gpg
```
<!-- more -->

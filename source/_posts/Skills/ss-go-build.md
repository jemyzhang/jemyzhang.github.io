title: ss-go build
date: 2016-12-27 13:41:42
tags: [go, shadowsocks]
---

```
mkdir -p gopath/src/github.com/orvice/shadowsocks-go
cd gopath/src/github.com/orvice/shadowsocks-go
git clone  git@github.com:jemyzhang/shadowsocks-go.git .
export GOPATH=~/gopath
cd mu
go get
go build
```
<!-- more -->

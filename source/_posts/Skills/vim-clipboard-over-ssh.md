title: vim clipboard over ssh
date: 2016-10-20 11:39:10
tags: [ssh, clipboard, vim]
---

The "clipboard" is a feature of X11, so you will need to enable "X11 forwarding" for the SSH connection in "trusted" mode:
```shell
$ ssh -Y myserver
```
(By default, X11 is forwarded in "untrusted" mode, which is somewhat too restrictive. -Y disables the restrictions.)
<!-- more -->
Also make sure the server has xauth and a X11-capable version of vim installed. You can use xsel -o and xsel -o -b to verify that the clipboard can be accessed.

To make it permanent, add the following to your local ~/.ssh/config:
```shell
Host myserver
    ForwardX11 yes
    ForwardX11Trusted yes
```

Reference:[HERE](http://superuser.com/questions/326871/using-clipboard-through-ssh-in-vim)

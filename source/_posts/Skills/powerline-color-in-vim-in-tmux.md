title: vim-powerline在tmux中颜色显示异常的解决方法
date: 2015-08-11 17:41:11
tags: [VIM, Powerline, TMUX]
---
安装好Powerline后，好不容易折腾完了字体显示，结果使用vim时，发现在tmux中颜色不正常。
![](http://ww3.sinaimg.cn/large/6edc034cgw1euytc9jk32j204q017q2u.jpg)
<!-- more -->

各种折腾，网上说将term设置成`screen-256color`就行了，但是我在tmux中`echo $TERM`，就已经是256了。

然后各种搜索，看到一篇[文章](http://askubuntu.com/questions/125526/vim-in-tmux-display-wrong-colors)，
使用`tmux -2`启动，可以'Force tmux to assume the terminal supports 256 colours'，尝试一下，果然可以：

![](http://ww1.sinaimg.cn/large/6edc034cgw1euytc3e1sqj20530160sl.jpg)


----
- 顺便提一下powerline字体的坑爹事情。install font后，死活都显示框框，各种`fc-cache -vf ~/.fonts/`, copy fontconfig等等都不行，最后发现，将终端字体设置成Powerline字体就行了，搜遍全网，居然没有提及，简直无语。
- 另外，通过ssh连接后vim如果要使用poweline，除了上述需求，特别需要注意的是，要`set encoding=utf-8`，否则也将无法正常显示。

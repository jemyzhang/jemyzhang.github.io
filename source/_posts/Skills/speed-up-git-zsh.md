title: speed up the zsh under the git repo
date: 2017-04-20 17:01:33
tags: [zsh, git]
---

## Method 1
Uncomment the `DISABLE_UNTRACKED_FILES_DIRTY="true"` inside the .zshrc

## Method 2
- Global configuration
```shell
git config --global --add oh-my-zsh.hide-dirty 1
```
- for some of the repo
```shell
git config --add oh-my-zsh.hide-dirty 1
```

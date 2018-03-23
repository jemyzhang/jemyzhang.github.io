title: pyenv
date: 2017-06-20
tags: [python]

---
```shell
# install pyenv
curl -L https://raw.github.com/yyuu/pyenv-installer/master/bin/pyenv-installer | bash
# install dependent libraries
sudo apt install libsqlite3 libbz2-dev libreadline-dev
# install specific version of python
pyenv install 3.6.1
pyenv virtualenv 3.6.1 xxx
pyenv activate xxx
```
<!-- more -->

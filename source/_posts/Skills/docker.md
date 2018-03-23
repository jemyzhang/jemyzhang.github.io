title: docker
date: 2017-01-05 13:49:13
tags: [docker]
---


## Install
```shell
sudo sh -c "wget -qO- https://get.docker.io/gpg | apt-key add -"
sudo sh -c "echo deb http://get.docker.io/ubuntu docker main > /etc/apt/sources.list.d/docker.list"
sudo apt-get update
sudo apt-get install lxc-docker
```
<!-- more -->
## 增加用户到docker组
```shell
sudo usermod jemyzhang -G docker -a
```

## Build and Run
```shell
docker build -t ubuntu-1004-qt .
docker run -i -t ubuntu10.04x32 /bin/bash
docker run -i -t -d -v `pwd`/../workspace:/home/workspace -v `pwd`/../opt:/opt ubuntu10.04x32 /etc/init.d/ssh start -D
```

## Get ip
```shell
docker inspect 2c74 | grep IP
ssh xxx@IP
```

## 提交更改:
将一个container固化为一个新的image，后面的repo:tag可选
```shell
docker commit <container> [repo:tag]
```

## .bashrc无效的解决方法

```shell
workspace@2c7404e9deae:~$ cat .bash_profile 

#!/bin/bash 

if [ -f ~/.bashrc ]; then 
. ~/.bashrc 
fi 
```



## 退出：
```shell
docker rm `docker ps -a | grep Exited | awk '{print $1}'`
```

## 删除镜像：
```shell
docker images --no-trunc| grep none | awk '{print $3}' | xargs -r docker rmi 
```

## 常用命令

总结一下常用命令:

其中<>阔起来的参数为必选，[]阔起来为可选

>
docker version 查看docker的版本号，包括客户端、服务端、依赖的Go等
docker info 查看系统(docker)层面信息，包括管理的images, containers数等
docker search <image> 在docker index中搜索image
docker pull <image> 从docker registry server 中下拉image
docker push <image|repository> 推送一个image或repository到registry
docker push <image|repository>:TAG 同上，指定tag
docker inspect <image|container> 查看image或container的底层信息
docker images TODO filter out the intermediate image layers (intermediate image layers 是什么)
docker images -a 列出所有的images
docker ps 默认显示正在运行中的container
docker ps -l 显示最后一次创建的container，包括未运行的
docker ps -a 显示所有的container，包括未运行的
docker logs <container> 查看container的日志，也就是执行命令的一些输出
docker rm <container...> 删除一个或多个container
docker rm `docker ps -a -q` 删除所有的container
docker ps -a -q | xargs docker rm 同上, 删除所有的container
docker rmi <image...> 删除一个或多个image
docker start/stop/restart <container> 开启/停止/重启container
docker start -i <container> 启动一个container并进入交互模式
docker attach <container> attach一个运行中的container
docker run <image> <command> 使用image创建container并执行相应命令，然后停止
docker run -i -t <image> /bin/bash 使用image创建container并进入交互模式, login shell是/bin/bash
docker run -i -t -p <host_port:contain_port> 将container的端口映射到宿主机的端口
docker commit <container> [repo:tag] 将一个container固化为一个新的image，后面的repo:tag可选
docker build <path> 寻找path路径下名为的Dockerfile的配置文件，使用此配置生成新的image
docker build -t repo[:tag] 同上，可以指定repo和可选的tag
docker build - < <dockerfile> 使用指定的dockerfile配置文件，docker以stdin方式获取内容，使用此配置生成新的image
docker port <container> <container port> 查看本地哪个端口映射到container的指定端口，其实用docker ps 也可以看到

### 杀死所有正在运行的容器
```shell
docker kill $(docker ps -a -q)
```
### 删除所有已经停止的容器
```shell
docker rm $(docker ps -a -q)
```

### 删除所有未打 dangling 标签的镜像
```shell
docker rmi $(docker images -q -f dangling=true)
```

### 删除所有镜像
```
docker rmi $(docker images -q)
```


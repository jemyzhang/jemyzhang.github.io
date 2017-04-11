title: Xfce设置代理Proxy
date: 2016-09-10
tags: [ubuntu, xfce, proxy]
---
Xfce设置代理Proxy
===

<!-- more -->
proxyon.sh
```sh
if [ $(id -u) -ne 0 ]; then
  echo "This script must be run as root";
  exit 1;
fi

if [ $# -eq 2 ]
  then

  gsettings set org.gnome.system.proxy mode 'manual' ;
  gsettings set org.gnome.system.proxy.http host '$1';
  gsettings set org.gnome.system.proxy.http port $2;


  grep PATH /etc/environment > lol.t;
  printf \
  "http_proxy=http://$1:$2/\n\
  https_proxy=http://$1:$2/\n\
  ftp_proxy=http://$1:$2/\n\
  no_proxy=\"localhost,127.0.0.1,localaddress,.localdomain.com\"\n\
  HTTP_PROXY=http://$1:$2/\n\
  HTTPS_PROXY=http://$1:$2/\n\
  FTP_PROXY=http://$1:$2/\n\
  NO_PROXY=\"localhost,127.0.0.1,localaddress,.localdomain.com\"\n" >> lol.t;

  cat lol.t > /etc/environment;


  printf \
  "Acquire::http::proxy \"http://$1:$2/\";\n\
  Acquire::ftp::proxy \"ftp://$1:$2/\";\n\
  Acquire::https::proxy \"https://$1:$2/\";\n" > /etc/apt/apt.conf.d/95proxies;

  rm -rf lol.t;

  else

  printf "Usage $0 <proxy_ip> <proxy_port>\n";

fi
```

proxyoff.sh
```sh
if [ $(id -u) -ne 0 ]; then
  echo "This script must be run as root";
  exit 1;
fi

gsettings set org.gnome.system.proxy mode 'none' ;

grep PATH /etc/environment > lol.t;
cat lol.t > /etc/environment;

printf "" > /etc/apt/apt.conf.d/95proxies;

rm -rf lol.t;
```

使用方法如下：
```sh
$ sudo ./proxyon.sh 10.2.20.17 8080
OR
$ sudo ./proxyon.sh myproxy.server.com 8080
$ sudo ./proxyoff.sh
 ```
 
 或者:
 ```sh
 function proxy_on() {
    export no_proxy="localhost,127.0.0.1,localaddress,.localdomain.com"

    if (( $# > 0 )); then
        valid=$(echo $@ | sed -n 's/\([0-9]\{1,3\}.\)\{4\}:\([0-9]\+\)/&/p')
        if [[ $valid != $@ ]]; then
            >&2 echo "Invalid address"
            return 1
        fi

        export http_proxy="http://$1/"
        export https_proxy=$http_proxy
        export ftp_proxy=$http_proxy
        export rsync_proxy=$http_proxy
        echo "Proxy environment variable set."
        return 0
    fi

    echo -n "username: "; read username
    if [[ $username != "" ]]; then
        echo -n "password: "
        read -es password
        local pre="$username:$password@"
    fi

    echo -n "server: "; read server
    echo -n "port: "; read port
    export http_proxy="http://$pre$server:$port/"
    export https_proxy=$http_proxy
    export ftp_proxy=$http_proxy
    export rsync_proxy=$http_proxy
    export HTTP_PROXY=$http_proxy
    export HTTPS_PROXY=$http_proxy
    export FTP_PROXY=$http_proxy
    export RSYNC_PROXY=$http_proxy
}

function proxy_off(){
    unset http_proxy
    unset https_proxy
    unset ftp_proxy
    unset rsync_proxy
    echo -e "Proxy environment variable removed."
}
```

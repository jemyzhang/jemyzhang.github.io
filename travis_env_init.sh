#!/bin/bash

__COMMENTS__='
# OS: ubuntu 14.04 trusty
# nodejs: 6.9.1
# npm: 3.10.8
# sudo: required
# need "GIT_USER_NAME" "GIT_USER_EMAIL" "GIT_REPO_TOKEN" "BAIDU_ANALYTICS" "BAIDU_URL_SUBMIT_TOKEN" "DuoShuo_SHORT_NAME" variable in env.
# env variable "icarus_opacity_disable" to control icarus opacity version display enable or disable.
# how to use: in travis, use the script to run, eg:
#    source travis_env_init.sh
#    sh travis_env_init.sh
#    ./travis_env_init.sh
'


node --version
npm --version

echo "Hexo environment pre install start."
echo "${__COMMENTS__}"

npm install -g minimatch > /dev/null
npm install -g graceful-fs > /dev/null
npm install -g gulp > /dev/null
npm install -g hexo > /dev/null
npm install -g hexo-cli > /dev/null
npm install > /dev/null

echo "hexo and packages install complete."

# Set git config 
git config --global user.name "${GIT_USER_NAME}"
git config --global user.email "${GIT_USER_EMAIL}"
sed -i'' "s~git@github.com:~https://${GIT_REPO_TOKEN}@github.com/~" _config.yml

theme_config_file="themes/next/_config.yml"
# Enable categories
sed -i "s~#categories: ~categories: ~" "${theme_config_file}"
# enable local search
sed -i "N;s/\(local_search:\n  enable: \)false/\1true/" "${theme_config_file}"
# change scheme
sed -i "s~scheme: Muse~#scheme: Muse~" "${theme_config_file}"
sed -i "s~#scheme: Pisces~scheme: Pisces~" "${theme_config_file}"
# change highlight_theme
sed -i "s~highlight_theme: normal~highlight_theme: night eighties~" "${theme_config_file}"
# change google analytics
sed -i "s~#google_analytics:~google_analytics: ${CFG_GOOGLE_ANALYTICS}~" "${theme_config_file}"
# custom the content style
cat <<EOF > themes/next/source/css/_variables/custom.styl
\$main-desktop = 90%;
\$content-desktop = calc(100% - 260px);
EOF

# add mermaid style
#cat << EOF >> themes/next/layout/_partials/header.swig
#<link rel="stylesheet", href="{{ url_for("https://cdn.bootcss.com/mermaid/6.0.0/mermaid.min.css") }}" />
#<script src="//cdn.bootcss.com/mermaid/6.0.0/mermaid.min.js" />
#EOF

echo "Hexo environment pre install complete OK."

#:D FROM {image_prefix}dev:latest
#:D MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash
export DEBIAN_FRONTEND=noninteractive

# apt-get -y install python-setuptools
# add-apt-repository -y ppa:chris-lea/node.js
curl -sL https://deb.nodesource.com/setup_10.x | bash -
add-apt-repository -y ppa:kivy-team/kivy
apt-get -y update
apt-get -y install make autoconf
apt-get -y install python2.7 python-pip python2.7-dev libpython2.7
apt-get -y install postgresql-client
pip install --upgrade setuptools pip
apt-get -y install python-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev
apt-get -y install python-psycopg2
apt-get -y install python-kivy kivy-examples
apt-get -y install cmdtest
apt-get -y install unrar
pip install --upgrade beautifulsoup4 html5lib requests_toolbelt requests PyYAML ndg_httpsclient
pip install --upgrade pymongo django
apt-get -y install nodejs
npm install -g coffee-script
npm install -g brunch
npm install -g mimosa
npm install -g bower
npm install -g js2coffee
npm install -g yamljs
npm install -g yarn
npm install -g meteor
npm install -g @pingy/cli
npm install -g pug-cli
npm install -g uglify-js
npm install -g stylus

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


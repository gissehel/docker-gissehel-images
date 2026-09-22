#:D FROM {image_prefix}dev:latest
#:D # MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y install apt-transport-https
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
apt-get -y update
apt-get -y install dotnet-sdk-10.0
apt-get -y install make autoconf
apt-get -y install python3 python3-pip python3-dev
apt-get -y install postgresql-client
pip3 install --upgrade setuptools
apt-get -y install libffi-dev libssl-dev libxml2-dev libxslt1-dev
apt-get -y install python3-psycopg2
apt-get -y install unrar
pip3 install --upgrade beautifulsoup4 html5lib requests_toolbelt requests PyYAML ndg_httpsclient pymongo django
apt-get -y install nodejs
npm install -g npm
npm install -g yarn

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


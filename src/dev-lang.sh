#:D FROM {image_prefix}dev:latest
#:D MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y install apt-transport-https
curl -sSL https://packages.microsoft.com/keys/microsoft.asc | apt-key add -
apt-add-repository https://packages.microsoft.com/ubuntu/20.04/prod
curl -fsSL https://deb.nodesource.com/setup_16.x | bash -
apt-get -y update
apt-get -y install dotnet-sdk-2.1 dotnet-sdk-3.1 dotnet-sdk-5.0
apt-get -y install make autoconf
apt-get -y install python2.7 python2.7-dev libpython2.7 python3 python3-pip libpython3.8 python3-dev
apt-get -y install postgresql-client
pip3 install --upgrade setuptools
apt-get -y install python3-dev libffi-dev libssl-dev libxml2-dev libxslt1-dev
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


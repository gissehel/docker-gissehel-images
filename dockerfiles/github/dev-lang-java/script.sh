#:D FROM {image_prefix}dev-lang:latest
#:D MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash
export DEBIAN_FRONTEND=noninteractive

add-apt-repository -y ppa:webupd8team/java
apt -y update
apt -y install oracle-java8-set-default
echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
apt -y install oracle-java8-installer && apt-get clean
update-alternatives --display java

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


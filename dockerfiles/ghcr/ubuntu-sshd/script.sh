#:D FROM phusion/baseimage:master
#:D MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash
export DEBIAN_FRONTEND=noninteractive

# echo "deb http://archive.ubuntu.com/ubuntu xenial multiverse" >> /etc/apt/sources.list
sed -i '/docker_env/d' /etc/group

# Enabling SSH (since 0.9.16)
rm -f /etc/service/sshd/down

apt-get -y update
locale-gen "en_US.UTF-8"
dpkg-reconfigure locales

#apt-mark hold initscripts
#apt-mark hold fuse
apt-get -y upgrade
apt-get -y install unzip wget curl python mercurial git sqlite3 mlocate sudo

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


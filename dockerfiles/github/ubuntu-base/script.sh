#:D FROM ubuntu:latest
#:D # MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash

export DEBIAN_FRONTEND=noninteractive

apt update -y
apt install -y apt-utils locales

locale-gen "en_US.UTF-8"
dpkg-reconfigure locales

apt update -y
apt upgrade -y
apt install -y unzip wget curl tzdata sudo git sqlite3 adduser
update-alternatives --set sudo /usr/bin/sudo.ws
ln -fs /usr/share/zoneinfo/Europe/Paris /etc/localtime
dpkg-reconfigure --frontend noninteractive tzdata

grep -E "^ubuntu:" /etc/passwd >/dev/null 2>&1 && deluser ubuntu

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


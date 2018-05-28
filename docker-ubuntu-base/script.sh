#:D FROM ubuntu:latest
#:D MAINTAINER Gissehel <public-docker-{id}-maintainer@gissehel.org>
#:! /bin/bash

export DEBIAN_FRONTEND=noninteractive

# echo "deb http://archive.ubuntu.com/ubuntu bionic multiverse" >> /etc/apt/sources.list
apt-get update -y
apt-get install -y apt-utils locales

locale-gen "en_US.UTF-8"
dpkg-reconfigure locales

apt-get update -y
apt-get -y upgrade
apt-get -y install unzip wget curl

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


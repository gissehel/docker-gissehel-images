#:D FROM {image_prefix}ubuntu-base:latest
#:D # MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash

export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt install -y unminimize

echo "y" | unminimize

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


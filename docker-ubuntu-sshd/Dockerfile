FROM phusion/baseimage:latest
MAINTAINER Gissehel <public-docker-ubuntu-sshd-maintainer@gissehel.org>

ADD script.sh /tmp/create-image-script
RUN /bin/bash /tmp/create-image-script && rm -f /tmp/create-image-script

.PHONY:none
none:
	echo "nothing to do..."

.PHONY:all

.PHONY:clean
clean:
	rm -rf *.local-image
	rm -rf *.remote-image

%.local-image: %/*
	bash -c 'NAME="$${0%.local-image}"; cd "$${NAME}"; docker build --no-cache --force-rm --build-arg VCS_REF=`git rev-parse --short HEAD` --build-arg BUILD_DATE=`date -u +”%Y-%m-%dT%H:%M:%SZ”` -t local-$${NAME} .' "$@" && touch "$@"


.PHONY:ubuntu-sshd
all:ubuntu-sshd
ubuntu-sshd:ubuntu-sshd.local-image
ubuntu-sshd.local-image: phusion-baseimage--master.remote-image

phusion-baseimage--master.remote-image:
	docker pull "phusion/baseimage:master" && touch "$@"

.PHONY:dev
all:dev
dev:dev.local-image
dev.local-image: ubuntu-sshd.local-image

.PHONY:dev-lang
all:dev-lang
dev-lang:dev-lang.local-image
dev-lang.local-image: dev.local-image

.PHONY:dev-lang-java
all:dev-lang-java
dev-lang-java:dev-lang-java.local-image
dev-lang-java.local-image: dev-lang.local-image

.PHONY:dev-dl
all:dev-dl
dev-dl:dev-dl.local-image
dev-dl.local-image: dev.local-image

.PHONY:irssi
all:irssi
irssi:irssi.local-image
irssi.local-image: ubuntu-sshd.local-image

.PHONY:ubuntu-base
all:ubuntu-base
ubuntu-base:ubuntu-base.local-image
ubuntu-base.local-image: ubuntu--latest.remote-image

ubuntu--latest.remote-image:
	docker pull "ubuntu:latest" && touch "$@"

.PHONY:squid
all:squid
squid:squid.local-image
squid.local-image: ubuntu-base.local-image

.PHONY:squid-open
all:squid-open
squid-open:squid-open.local-image
squid-open.local-image: ubuntu-base.local-image


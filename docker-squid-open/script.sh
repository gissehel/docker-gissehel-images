#:D FROM gissehel/ubuntu-base:latest
#:D MAINTAINER Gissehel <public-docker-{id}-maintainer@gissehel.org>
#:! /bin/bash
#:E expose 3128
#:E CMD ["/start"]

export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y install squid3 apache2-utils

rm -f /etc/squid/squid.conf
mkdir -p /etc/squid/conf

touch /etc/squid/conf/empty.conf

cat <<__END__ >/etc/squid/squid.conf
http_access allow all
http_port 3128
include /etc/squid/conf/*.conf
__END__

mkdir -p /opt/squid

cat <<__END__ >/opt/squid/start.sh
#!/usr/bin/env bash

chown proxy:proxy /var/log/squid
exec /usr/sbin/squid -N
__END__

chmod +x /opt/squid/start.sh

ln -s /opt/squid/start.sh /start

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt

rm -f /tmp/script.sh

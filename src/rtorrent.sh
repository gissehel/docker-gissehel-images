#:D FROM {image_prefix}ubuntu-sshd:latest
#:D MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash

export DEBIAN_FRONTEND=noninteractive

STARTSCRIPT="/etc/service/rtorrent/run"
CONFIG="/home/user/.rtorrent.rc"

apt-get -y update
apt-get -y install rtorrent screen
adduser --disabled-password --gecos "" user

printf "user\tALL=(ALL:ALL) NOPASSWD: ALL\n" > /etc/sudoers.d/user
chmod 0440 /etc/sudoers.d/user

mkdir -p /etc/service/rtorrent
mkdir -p /home/user/.ssh
mkdir -p /home/user/torrent/data
mkdir -p /home/user/torrent/session
mkdir -p /home/user/torrent/torrent_active
mkdir -p /home/user/torrent/finished
echo "screen -x" > /home/user/.bash_history
chown user:user /home/user/.ssh
chown user:user /home/user/torrent
chown user:user /home/user/torrent/data
chown user:user /home/user/torrent/session
chown user:user /home/user/torrent/torrent_active
chown user:user /home/user/torrent/finished
chown user:user /home/user/.bash_history
chmod 0770 /home/user/.ssh
chmod 0777 /var/run/screen
chmod 0644 /home/user/.bash_history

cat <<__END__ > "$STARTSCRIPT"
#!/usr/bin/env bash

. /etc/container_environment.sh

[ -n "\${RTORRENT_IP}" ] && sed -i -e 's/^#* *ip = .*/ip = '"\${RTORRENT_IP}"'/' /home/user/.rtorrent.rc
[ -n "\${RTORRENT_DHT_PORT}" ] && sed -i -e 's/^#* *dht_port = .*/dht_port = '"\${RTORRENT_DHT_PORT}"'/' /home/user/.rtorrent.rc
[ -n "\${RTORRENT_PORT_RANGE}" ] && sed -i -e 's/^#* *port_range = .*/port_range = '"\${RTORRENT_PORT_RANGE}"'/' /home/user/.rtorrent.rc

chown user:user /home/user/.ssh
chown user:user /home/user/torrent
chown user:user /home/user/torrent/data
chown user:user /home/user/torrent/session
chown user:user /home/user/torrent/torrent_active
chown user:user /home/user/torrent/finished
chown user:user /home/user/.bash_history
chown user:user /home/user/.rtorrent.rc

chmod 0770 /home/user/.ssh
chmod 0775 /var/run/screen
chmod 0644 /home/user/.bash_history
chmod 0644 /home/user/.rtorrent.rc

rm -f /home/user/torrent/session/rtorrent.lock

su -l user -c "/usr/bin/screen -AmDS rtorrent /usr/bin/rtorrent"
__END__

cat <<__END__ > "$CONFIG"
#download_rate = 500
#upload_rate = 150

directory = ~/torrent/data

session = ~/torrent/session

#session = ./session

port_range = 6881-6881
port_random = no

check_hash = yes

schedule = watch_directory,5,5,load_start=~/torrent/torrent_active/*.torrent
schedule = untied_directory,5,5,stop_untied=

system.method.set_key = event.download.finished,move_complete,"d.set_directory=~/torrent/finished/;execute=mv,-u,\$d.get_base_path=,~/torrent/finished/"

dht = auto

dht_port = 6880

encryption = allow_incoming,require,require_rc4

__END__


chmod +x "$STARTSCRIPT"
chmod 0644 "$CONFIG"
chown user:user "$CONFIG"

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


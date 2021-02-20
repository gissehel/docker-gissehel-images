#:D FROM {image_prefix}ubuntu-sshd:latest
#:D MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash

STARTIRSSI="/etc/my_init.d/50_start-irssi.sh"
apt-get -y update
apt-get -y install irssi screen
adduser --disabled-password --gecos "" irssi

mkdir -p /home/irssi/.irssi
mkdir -p /home/irssi/.ssh
mkdir -p /home/irssi/download
mkdir -p /home/irssi/irclogs
echo "screen -x" > /home/irssi/.bash_history
chown irssi:irssi /home/irssi/.irssi
chown irssi:irssi /home/irssi/.ssh
chown irssi:irssi /home/irssi/download
chown irssi:irssi /home/irssi/irclogs
chown irssi:irssi /home/irssi/.bash_history
chmod 0770 /home/irssi/.ssh
chmod 0644 /home/irssi/.bash_history
chmod 0777 /var/run/screen

cat <<__END__ > "$STARTIRSSI"
#!/usr/bin/env bash
start-stop-daemon --start --background --chuid irssi:irssi --exec /usr/bin/screen -- -AmdS irssi /usr/bin/irssi
__END__

chmod +x "$STARTIRSSI"

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


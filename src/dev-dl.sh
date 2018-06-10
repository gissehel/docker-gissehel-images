#:D FROM {image_prefix}dev:latest
#:D MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y install make
apt-get -y install unrar unzip par2

LOGIN=gissehel
GROUP=$LOGIN
HOME_USER=/home/$LOGIN
DEV=$HOME_USER/dev
WORKDIR=$DEV/workdir
TEMPDIR=$DEV/tmp

su -l "$LOGIN" bash -c "mkdir -p $DEV && mkdir -p $WORKDIR && cd $DEV && git clone https://github.com/mcrapet/plowshare/ plowshare4 && sed -i -e 's/umask 0066/umask 0022/' plowshare4/src/download.sh && echo 'export TEMP_DIR=$TEMPDIR' >> $HOME_USER/.bashrc && echo 'cd $WORKDIR' >> $HOME_USER/.bashrc && echo \"alias monip=\\\"curl -s http://monip.org | perl -ape 's/<[^>]+>/ /mg; s/ +/ /mg'| grep \\\\\\\" IP \\\\\\\" --color=never | perl -ape 's{ IP : (\S+) (\S+) (.*)}{\\\\\\\$1\\n\\\\\\\$2\\n\\\\\\\$3}'\\\"\" >> $HOME_USER/.bashrc && echo 'monip' >> $HOME_USER/.bashrc "

cd $DEV/plowshare4
make install
su -l "$LOGIN" bash -c "/usr/bin/plowmod --install"
BASH_HISTORY="$HOME_USER/.bash_history"
echo "curl http://monip.org" >> "${BASH_HISTORY}"
echo "monip" >> "${BASH_HISTORY}"
chown gissehel:gissehel "${BASH_HISTORY}"
chmod 0644 "${BASH_HISTORY}"


curl -L https://yt-dl.org/downloads/latest/youtube-dl -o /usr/local/bin/youtube-dl
chmod a+rx /usr/local/bin/youtube-dl


rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


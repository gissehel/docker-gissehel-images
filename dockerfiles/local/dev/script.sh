#:D FROM {image_prefix}ubuntu-sshd:latest
#:D MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash
export DEBIAN_FRONTEND=noninteractive

apt-get -y update
apt-get -y install mercurial git subversion mc vim screen command-not-found man colordiff
apt-get -y install pandoc bash-completion apt-file netcat-openbsd
apt-get -y install net-tools nmap inetutils-ping bind9-host jq mcrypt
apt-get -y install p7zip-full tmux tmuxinator gdebi-core 

apt-file update
rm -f /etc/apt/apt.conf.d/docker-clean
apt-cache gencaches

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce

LOGIN=gissehel

adduser --disabled-password --gecos "" $LOGIN

printf "$LOGIN\tALL=(ALL:ALL) NOPASSWD: ALL\n" > /etc/sudoers.d/$LOGIN
chmod 0440 /etc/sudoers.d/$LOGIN

mkdir /home/$LOGIN/dev
chown $LOGIN:$LOGIN /home/$LOGIN/dev

mkdir /home/$LOGIN/.ssh
chown $LOGIN:$LOGIN /home/$LOGIN/.ssh
chmod 0770 /home/$LOGIN/.ssh

sudo -i -u $LOGIN bash -c "mkdir -p etc; git clone https://github.com/gissehel/dotfiler ~/.dotfiles; git clone https://github.com/gissehel/dot-gissehel ~/.dotfiles/dot-gissehel; git clone https://github.com/gissehel/dot-meta ~/.dotfiles/dot-meta; git clone https://github.com/gissehel/dot-apt ~/.dotfiles/dot-apt; git clone https://github.com/VundleVim/Vundle.vim.git ~/.dotfiles/vundle/.vim/bundle/Vundle.vim; ~/.dotfiles/bin/dot update --skip-pull || ~/.dotfiles/bin/dot update --skip-pull; echo '' | vim -T vt100 --not-a-term +PluginInstall +qall; ~/bin/install-meta"

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


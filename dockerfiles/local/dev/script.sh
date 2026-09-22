#:D FROM {image_prefix}ubuntu-unmin:latest
#:D # MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash
export DEBIAN_FRONTEND=noninteractive

# Fix command-not-found bug (by not using compression for indexes, which is ugly but works)
# https://bugs.launchpad.net/ubuntu/+source/command-not-found/+bug/1876034
sed -i -e 's/GzipIndexes "true"/GzipIndexes "false"/' /etc/apt/apt.conf.d/docker-gzip-indexes

apt -y update
apt -y install mercurial git subversion mc vim screen man colordiff pandoc bash-completion apt-file netcat-openbsd net-tools nmap inetutils-ping bind9-host jq mcrypt p7zip-full tmux tmuxinator gdebi-core command-not-found python3 python-is-python3

apt-file update
rm -f /etc/apt/apt.conf.d/docker-clean
apt-cache gencaches

apt -y update
apt -y install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt -y update
apt -y install docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

LOGIN=gissehel

adduser --disabled-password --gecos "" $LOGIN

printf "$LOGIN\tALL=(ALL:ALL) NOPASSWD: ALL\n" > /etc/sudoers.d/$LOGIN
chmod 0440 /etc/sudoers.d/$LOGIN

mkdirmod() {
    dir="${1}"
    mode="${2}"

    mkdir -p "${dir}"
    chown $LOGIN:$LOGIN "${dir}"
    chmod "${mode}" "${dir}"
}


mkdirmod /home/$LOGIN/dev 0770
mkdirmod /home/$LOGIN/.ssh 0770
mkdirmod /home/$LOGIN/bin 0770

echo "--- === as user === ---"

COMMAND="mkdir -p etc"
COMMAND="${COMMAND}; git clone https://github.com/gissehel/dotfiler ~/.dotfiles"
COMMAND="${COMMAND}; git clone https://github.com/gissehel/dot-gissehel ~/.dotfiles/dot-gissehel"
COMMAND="${COMMAND}; git clone https://github.com/gissehel/dot-meta ~/.dotfiles/dot-meta"
COMMAND="${COMMAND}; git clone https://github.com/gissehel/dot-apt ~/.dotfiles/dot-apt"
COMMAND="${COMMAND}; git clone https://github.com/VundleVim/Vundle.vim.git ~/.dotfiles/vundle/.vim/bundle/Vundle.vim"
COMMAND="${COMMAND}; echo '=== dot run ==='"
COMMAND="${COMMAND}; ~/.dotfiles/bin/dot update --skip-pull || ~/.dotfiles/bin/dot update --skip-pull"
COMMAND="${COMMAND}; echo '' | vim -T vt100 --not-a-term +PluginInstall +qall"
COMMAND="${COMMAND}; echo '=== create-links ==='"
COMMAND="${COMMAND}; mkdir -p ~/.config/autofetch/repos/"
COMMAND="${COMMAND}; ln -s /home/gissehel/.dotfiles/dot-gissehel ~/.config/autofetch/repos/"
COMMAND="${COMMAND}; ln -s /home/gissehel/.dotfiles/dot-meta ~/.config/autofetch/repos/"
COMMAND="${COMMAND}; ln -s /home/gissehel/.dotfiles/dot-apt ~/.config/autofetch/repos/"
COMMAND="${COMMAND}; echo '=== install-meta ==='"
COMMAND="${COMMAND}; ~/bin/install-meta"
COMMAND="${COMMAND}; echo '=== e_bash rc ==='"
COMMAND="${COMMAND}; source ~/.config/e_bash/rc"
COMMAND="${COMMAND}; apt-repos"
COMMAND="${COMMAND}; echo '=== end user ==='"

sudo -i -u $LOGIN bash -c "${COMMAND}"

echo "--- === end as user === ---"

ln -s /home/$LOGIN/.dotfiles/bin/dot /home/$LOGIN/bin/dot
chown $LOGIN:$LOGIN /home/$LOGIN/bin
chown -h $LOGIN:$LOGIN /home/$LOGIN/bin/dot

reset

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


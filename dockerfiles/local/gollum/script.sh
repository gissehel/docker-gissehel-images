#:D FROM {image_prefix}ubuntu-base:latest
#:D MAINTAINER Gissehel <public-docker-{flavor}-{id}-maintainer@gissehel.org>
#:! /bin/bash
#:E expose 4567
#:E CMD ["/start"]

export DEBIAN_FRONTEND=noninteractive

# Install dependencies
apt-get update -y
apt-get upgrade -y
apt-get install -y -q build-essential ruby ruby-dev python python-docutils ruby-bundler libicu-dev libreadline-dev libssl-dev zlib1g-dev git-core git libldap2-dev libidn11-dev cmake
apt-get clean
rm -rf /var/cache/apt/archives/* /var/lib/apt/lists/*

# Install gollum
gem install gollum redcarpet github-markdown asciidoctor creole wikicloth org-ruby RedCloth


# Initialize wiki data
mkdir /data

cat <<__END__ >/usr/local/bin/start-gollum
#!/usr/bin/env bash
if [ ! -d /data/.git ] ; then
    git init /data
    touch /data/config.rb
fi
exec /usr/local/bin/gollum /data --config /data/config.rb
__END__

chmod +x /usr/local/bin/start-gollum
ln -s /usr/local/bin/start-gollum /start

rm -rf /var/lib/apt/lists/*
rm -f /var/log/dpkg.log
rm -rf /var/log/apt
rm -rf /var/cache/apt


FROM gissehel/dev:latest
MAINTAINER Gissehel <public-docker-dev-lang-maintainer@gissehel.org>

ADD script.sh /tmp/create-image-script
RUN /bin/bash /tmp/create-image-script && rm -f /tmp/create-image-script

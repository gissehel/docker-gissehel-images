FROM gissehel/ubuntu-sshd:latest
MAINTAINER Gissehel <public-docker-github-irssi-maintainer@gissehel.org>

ARG BUILD_DATE
ARG VCS_REF

LABEL \
      org.opencontainers.image.created="${BUILD_DATE}" \
      org.opencontainers.image.authors="gissehel" \
      org.opencontainers.image.url="https://github.com/gissehel/docker-gissehel-images" \
      org.opencontainers.image.source="https://github.com/gissehel/docker-gissehel-images" \
      org.opencontainers.image.version="1.27-${VCS_REF}" \
      org.opencontainers.image.revision="${VCS_REF}" \
      org.opencontainers.image.vendor="gissehel" \
      org.opencontainers.image.ref.name="gissehel/irssi" \
      org.opencontainers.image.title="irssi" \
      org.opencontainers.image.description="Image for irssi" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.name="irssi" \
      org.label-schema.version="1.27-${VCS_REF}" \
      org.label-schema.vendor="gissehel" \
      org.label-schema.vcs-url="https://github.com/gissehel/docker-gissehel-images" \
      org.label-schema.schema-version="1.0"

ADD script.sh /tmp/create-image-script
RUN /bin/bash /tmp/create-image-script && rm -f /tmp/create-image-script


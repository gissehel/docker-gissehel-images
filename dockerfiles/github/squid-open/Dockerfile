FROM gissehel/ubuntu-base:latest
MAINTAINER Gissehel <public-docker-github-squid-open-maintainer@gissehel.org>

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
      org.opencontainers.image.ref.name="gissehel/squid-open" \
      org.opencontainers.image.title="squid-open" \
      org.opencontainers.image.description="Image for squid-open" \
      org.label-schema.build-date="${BUILD_DATE}" \
      org.label-schema.vcs-ref="${VCS_REF}" \
      org.label-schema.name="squid-open" \
      org.label-schema.version="1.27-${VCS_REF}" \
      org.label-schema.vendor="gissehel" \
      org.label-schema.vcs-url="https://github.com/gissehel/docker-gissehel-images" \
      org.label-schema.schema-version="1.0"

ADD script.sh /tmp/create-image-script
RUN /bin/bash /tmp/create-image-script && rm -f /tmp/create-image-script

expose 3128
CMD ["/start"]

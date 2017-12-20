#!/usr/bin/env bash

VERSION="1.1"

create_dockerfile() {
    filename="$1"
    dockerfilename="$2"
    id="$3"
    cat "${filename}" | grep '^#:D ' | sed -e 's/^#:D //' | sed -e "s/{id}/${id}/g" > "${dockerfilename}"
    shell="$(cat "${filename}" | grep '^#:! ' | sed -e 's/^#:! //' | sed -e "s/{id}/${id}/g")"
    echo "" >> "${dockerfilename}"
    echo "ARG BUILD_DATE" >> "${dockerfilename}"
    echo "ARG VCS_REF" >> "${dockerfilename}"
    echo "" >> "${dockerfilename}"
    echo "LABEL \\" >> "${dockerfilename}"
    echo "      org.label-schema.build-date=\$BUILD_DATE \\" >> "${dockerfilename}"
    echo "      org.label-schema.vcs-ref=\$VCS_REF \\" >> "${dockerfilename}"
    echo "      org.label-schema.name=${id} \\" >> "${dockerfilename}"
    echo "      org.label-schema.version=${VERSION}-\$VCS_REF \\" >> "${dockerfilename}"
    echo "      org.label-schema.vendor=gissehel \\" >> "${dockerfilename}"
    echo '      org.label-schema.vcs-url="https://github.com/gissehel/docker-gissehel-images" '"\\" >> "${dockerfilename}"
    echo '      org.label-schema.schema-version="1.0"' >> "${dockerfilename}"
    echo "" >> "${dockerfilename}"
    echo "ADD ${filename} /tmp/create-image-script" >> "${dockerfilename}"
    echo "RUN ${shell} /tmp/create-image-script && rm -f /tmp/create-image-script" >> "${dockerfilename}"
}

create_build_hook() {
    dirname="hooks"
    mkdir -p "${dirname}"
    filename="${dirname}/build"
    id="$1"
    echo "" > "${filename}"
    echo "" >> "${filename}"
    echo "" >> "${filename}"
    echo "" >> "${filename}"
    echo "" >> "${filename}"
    echo "" >> "${filename}"
    echo "" >> "${filename}"
    echo '#!/bin/bash' > "${filename}"
    echo '# $IMAGE_NAME var is injected into the build so the tag is correct.' >> "${filename}"
    echo 'docker build --build-arg VCS_REF=`git rev-parse --short HEAD` --build-arg BUILD_DATE=`date -u +”%Y-%m-%dT%H:%M:%SZ”` -t ${IMAGE_NAME} .' >> "${filename}"
}

build() {
    dirname="$1"
    tag="$2"
    pushd .
    cd "${dirname}"
    docker build --force-rm --no-cache --tag "${tag}" .
    popd
}

build_from_id() {
    id="$1"
    create_dockerfile_from_id "${id}"
    build "docker-${id}" "gissehel/${id}"
}

create_dockerfile_from_id() {
    id="$1"
    pushd .
    cd "docker-${id}"
    create_dockerfile "script.sh" "Dockerfile" "${id}"
    create_build_hook "${id}"
    popd
}

create_dockerfile_from_id "ubuntu-sshd"
create_dockerfile_from_id "dev"
create_dockerfile_from_id "dev-lang"
create_dockerfile_from_id "irssi"

#build_from_id "ubuntu-sshd"
#build_from_id "dev"
#build_from_id "dev-lang"
#build_from_id "irssi"


# cd docker-ubuntu-sshd
# docker build --force-rm --no-cache --pull --tag gissehel/ubuntu-sshd .

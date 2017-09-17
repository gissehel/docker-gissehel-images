#!/usr/bin/env bash

create_dockerfile() {
    filename="$1"
    dockerfilename="$2"
    id="$3"
    cat "${filename}" | grep '^#:D ' | sed -e 's/^#:D //' | sed -e "s/{id}/${id}/g" > "${dockerfilename}"
    shell="$(cat "${filename}" | grep '^#:! ' | sed -e 's/^#:! //' | sed -e "s/{id}/${id}/g")"
    echo "" >> "${dockerfilename}"
    echo "ADD ${filename} /tmp/create-image-script" >> "${dockerfilename}"
    echo "RUN ${shell} /tmp/create-image-script && rm -f /tmp/create-image-script" >> "${dockerfilename}"
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
    popd
}

# create_dockerfile_from_id "ubuntu-sshd"
# create_dockerfile_from_id "dev"

# build_from_id "ubuntu-sshd"
build_from_id "dev"
build_from_id "dev-lang"


# cd docker-ubuntu-sshd
# docker build --force-rm --no-cache --pull --tag gissehel/ubuntu-sshd .

#!/usr/bin/env bash

VERSION="1.04"
badgesfilenames="badges.md"
USE_BADGES=1

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
    id="$1"

    mkdir -p "${dirname}"

    filename="${dirname}/build"

    echo '#!/bin/bash' > "${filename}"
    echo '# $IMAGE_NAME var is injected into the build so the tag is correct.' >> "${filename}"
    echo 'docker build --build-arg VCS_REF=`git rev-parse --short HEAD` --build-arg BUILD_DATE=`date -u +”%Y-%m-%dT%H:%M:%SZ”` -t ${IMAGE_NAME} .' >> "${filename}"

    filename="${dirname}/post_push"

    echo "#!/bin/bash" > "${filename}"
    echo "" >> "${filename}"
    echo 'GIT_SHA_TAG='"${VERSION}"'-`git rev-parse --short HEAD`' >> "${filename}"
    echo "docker tag \$IMAGE_NAME \$DOCKER_REPO:\$GIT_SHA_TAG" >> "${filename}"
    echo "docker push \$DOCKER_REPO:\$GIT_SHA_TAG" >> "${filename}"
}

init_badges() {
    echo "" > "${badgesfilenames}"
}

add_badge() {
    id="$1"

    echo -n "" >> "${badgesfilenames}"
    echo -n " [![](https://images.microbadger.com/badges/image/gissehel/${id}.svg)](https://microbadger.com/images/gissehel/${id} \"Get your own image badge on microbadger.com\")" >> "${badgesfilenames}"
    echo -n " [![](https://images.microbadger.com/badges/version/gissehel/${id}.svg)](https://microbadger.com/images/gissehel/${id} \"Get your own version badge on microbadger.com\")" >> "${badgesfilenames}"
    echo -n " [![](https://images.microbadger.com/badges/commit/gissehel/${id}.svg)](https://microbadger.com/images/gissehel/${id} \"Get your own commit badge on microbadger.com\")" >> "${badgesfilenames}"
    echo -n " [gissehel/${id}](https://hub.docker.com/r/gissehel/${id})" >> "${badgesfilenames}"
    echo "" >> "${badgesfilenames}"
    echo "" >> "${badgesfilenames}"
    echo "" >> "${badgesfilenames}"
}

create_readme() {
    cat "README-base.md" "${badgesfilenames}" > "README.md"
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
    [ "${USE_BADGES}" == "1" ] && add_badge "${id}"
    cd "docker-${id}"
    create_dockerfile "script.sh" "Dockerfile" "${id}"
    create_build_hook "${id}"
    popd
}

name="$1"

if [ -z "${name}" ]; then

  init_badges
  create_dockerfile_from_id "ubuntu-sshd"
  create_dockerfile_from_id "dev"
  create_dockerfile_from_id "dev-lang"
  create_dockerfile_from_id "dev-lang-java"
  create_dockerfile_from_id "dev-dl"
  create_dockerfile_from_id "irssi"
  create_readme

else
  USE_BADGES=0
  build_from_id "${name}"

  #build_from_id "ubuntu-sshd"
  #build_from_id "dev"
  #build_from_id "dev-lang"
  #build_from_id "dev-dl"
  #build_from_id "irssi"

fi


# cd docker-ubuntu-sshd
# docker build --force-rm --no-cache --pull --tag gissehel/ubuntu-sshd .

#!/usr/bin/env bash

. "version.sh"
badgesfilenames="badges.md"
gitlabci_filename=".gitlab-ci.yml"
gitlabci_base_filename=".gitlab-ci-base.yml"
USE_BADGES=1

create_dockerfile() {
    filename="$1"
    dockerfilename="$2"
    id="$3"
    flavor="$4"
    image_prefix=""

    [ "${flavor}" == "github" ] && image_prefix="gissehel\\/"
    [ "${flavor}" == "gitlab" ] && image_prefix="registry.gitlab.com\\/gissehel\\/docker-gissehel-images\\/"
    [ "${flavor}" == "local" ] && image_prefix="local-"
    cat "${filename}" | grep '^#:D ' | sed -e 's/^#:D //' | sed -e "s/{id}/${id}/g; s/{image_prefix}/${image_prefix}/g; s/{flavor}/${flavor}/g" > "${dockerfilename}"
    shell="$(cat "${filename}" | grep '^#:! ' | sed -e 's/^#:! //' | sed -e "s/{id}/${id}/g; s/{flavor}/${flavor}/g")"
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
    echo "" >> "${dockerfilename}"
    cat "${filename}" | grep '^#:E ' | sed -e 's/^#:E //' | sed -e "s/{id}/${id}/g" >> "${dockerfilename}"


}

create_build_hook() {
    dirname="hooks"
    id="$1"
    flavor="$2"

    if [ "${flavor}" == "github" ]
    then
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
    fi
}

init_badges() {
    echo "" > "${badgesfilenames}"
}

init_gitlabci() {
    cat "${gitlabci_base_filename}" > "${gitlabci_filename}"
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

add_gitlabci() {
    id="$1"

    echo "        - \"docker build -t registry.gitlab.com/gissehel/docker-gissehel-images/ubuntu-sshd:latest dockerfiles/gitlab/${id}/\"" >> "${gitlabci_filename}"
    echo "        - \"docker tag registry.gitlab.com/gissehel/docker-gissehel-images/ubuntu-sshd:latest registry.gitlab.com/gissehel/docker-gissehel-images/ubuntu-sshd:${VERSION}-\${CI_COMMIT_SHA:0:8}\"" >> "${gitlabci_filename}"
    echo "        - \"docker push registry.gitlab.com/gissehel/docker-gissehel-images/ubuntu-sshd:latest\"" >> "${gitlabci_filename}"
    echo "        - \"docker push registry.gitlab.com/gissehel/docker-gissehel-images/ubuntu-sshd:${VERSION}-\${CI_COMMIT_SHA:0:8}\"" >> "${gitlabci_filename}"


}

create_readme() {
    cat "README-base.md" "${badgesfilenames}" > "README.md"
}

build() {
    dirname="$1"
    tag="$2"
    pushd .>/dev/null
    cd "${dirname}"
    docker build --force-rm --no-cache --tag "${tag}" .
    popd>/dev/null
}

build_from_id() {
    id="$1"
    create_dockerfile_from_id "${id}"
    build "dockerfiles/local/${id}" "local-${id}"
}

create_dockerfile_from_id() {
    id="$1"
    [ "${USE_BADGES}" == "1" ] && add_badge "${id}"
    for flavor in github gitlab local
    do
        pushd .>/dev/null
        mkdir -p "dockerfiles/${flavor}/${id}"
        cp -f "src/${id}.sh" "dockerfiles/${flavor}/${id}/script.sh"
        cd "dockerfiles/${flavor}/${id}"
        create_dockerfile "script.sh" "Dockerfile" "${id}" "${flavor}"
        create_build_hook "${id}" "${flavor}"
        popd>/dev/null
    done
    add_gitlabci "${id}"
}

name="$1"

if [ -z "${name}" ]; then

    init_badges
    init_gitlabci

    create_dockerfile_from_id "ubuntu-sshd"
    create_dockerfile_from_id "dev"
    create_dockerfile_from_id "dev-lang"
    create_dockerfile_from_id "dev-lang-java"
    create_dockerfile_from_id "dev-dl"
    create_dockerfile_from_id "irssi"
    create_dockerfile_from_id "rtorrent"

    create_dockerfile_from_id "ubuntu-base"
    create_dockerfile_from_id "squid"
    create_dockerfile_from_id "squid-open"
    create_dockerfile_from_id "gollum"

    create_readme

else

    case "${name}" in
        clean)
            rm -f .gitlab-ci.yml README.md badges.md
            rm -rf dockerfiles
            ;;
        *)
            USE_BADGES=0
            build_from_id "${name}"
    esac
fi


# cd docker-ubuntu-sshd
# docker build --force-rm --no-cache --pull --tag gissehel/ubuntu-sshd .

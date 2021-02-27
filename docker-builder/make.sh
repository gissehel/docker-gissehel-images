#!/usr/bin/env bash

project_path=$(dirname "$0")
project_path=$(readlink -f "${project_path}")
docker_builder_dir="${project_path}/docker-builder"
docker_builder_data_dir="${project_path}/docker-builder-data"
gitlab_project_var="\${CI_REGISTRY_IMAGE}"

. "${docker_builder_data_dir}/version.sh"
. "${docker_builder_data_dir}/data.sh"

github_action_dir=".github/workflows"

badgesfilenames="${project_path}/badges.md"
gitlabci_filename="${project_path}/.gitlab-ci.yml"
ghcr_action_filename="${project_path}/${github_action_dir}/build.yml"
gitlabci_base_filename="${docker_builder_dir}/.gitlab-ci-base.yml"
makefile_base_filename="${docker_builder_dir}/Makefile-local-base"
ghcr_action_base_filename="${docker_builder_dir}/ghcr-base.yml"
readme_base_filename="${docker_builder_data_dir}/README-base.md"
readme_filename="${project_path}/README.md"
dockerfiles_relative_dir="dockerfiles"
dockerfiles_dir="${project_path}/${dockerfiles_relative_dir}"
makefile_filename="${dockerfiles_dir}/local/Makefile"
src_dir="${project_path}/${src_dir}"

create_dockerfile() {
    filename="$1"
    dockerfilename="$2"
    id="$3"
    flavor="$4"
    image_prefix=""

    [ "${flavor}" == "ghcr" ] && image_prefix="${ghcr_prefix}\\/"
    [ "${flavor}" == "github" ] && image_prefix="${dockerhub_prefix}\\/"
    [ "${flavor}" == "gitlab" ] && image_prefix=$(echo "${gitlab_project}/" | sed -e 's|\/|\\/|g;')
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
    echo "      org.label-schema.vendor=${vendor} \\" >> "${dockerfilename}"
    echo '      org.label-schema.vcs-url="'"${project_url}"'" '"\\" >> "${dockerfilename}"
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

create_makefile_parts() {
    filename="$1"
    id="$2"
    flavor="$3"
    if [ "${flavor}" == "local" ]
    then
        FROM_LINE=$(cat "${filename}" | grep '^#:D FROM ')
        MAKEFILE_PART="${makefile_filename}"

        echo ".PHONY:${id}" >> "${MAKEFILE_PART}"

        if (echo "${FROM_LINE}" | grep '{image_prefix}' 2>&1 >/dev/null)
        then
            IS_FROM_LOCAL="1"
            FROM_IMAGE=$(echo "${FROM_LINE}" | sed -e 's/.*{image_prefix}//; s/:latest//')
            FROM_IMAGE_BASE_FILENAME="${FROM_IMAGE}"
            FROM_IMAGE_FILENAME="${FROM_IMAGE_BASE_FILENAME}.local-image"
        else
            IS_FROM_LOCAL="0"
            FROM_IMAGE=$(echo "${FROM_LINE}" | sed -e 's/.*FROM //;')
            FROM_IMAGE_BASE_FILENAME=$(echo "${FROM_IMAGE}" | sed -e 's/\//-/; s/:/--/')
            FROM_IMAGE_FILENAME="${FROM_IMAGE_BASE_FILENAME}.remote-image"
        fi
        echo "all:${id}" >> "${MAKEFILE_PART}"
        echo "${id}:${id}.local-image" >> "${MAKEFILE_PART}"
        echo "${id}.local-image: ${FROM_IMAGE_FILENAME}" >> "${MAKEFILE_PART}"
        if [ "${IS_FROM_LOCAL}" == "0" ]
        then
            echo "" >> "${MAKEFILE_PART}"
            echo "${FROM_IMAGE_FILENAME}:" >> "${MAKEFILE_PART}"
            printf "\tdocker pull \"${FROM_IMAGE}\" && touch \"\$@\"\n" >> "${MAKEFILE_PART}"
        fi
        echo "" >> "${MAKEFILE_PART}"
        
    fi
}

init_readme() {
    rm -f "${readme_filename}"
    cp "${readme_base_filename}" "${readme_filename}"
}

init_gitlabci() {
    cat "${gitlabci_base_filename}" > "${gitlabci_filename}"
}

init_makefile() {
    mkdir -p "${dockerfiles_dir}/local"
    cat "${makefile_base_filename}" > "${makefile_filename}"
}

init_ghcr_action() {
    mkdir -p $(dirname "${ghcr_action_filename}")
    cat "${ghcr_action_base_filename}" > "${ghcr_action_filename}"
}

add_badge() {
    id="$1"

    echo -n "" >> "${readme_filename}"
    echo -n " [![](https://images.microbadger.com/badges/image/${dockerhub_prefix}/${id}.svg)](https://microbadger.com/images/${dockerhub_prefix}/${id} \"Get your own image badge on microbadger.com\")" >> "${readme_filename}"
    echo -n " [![](https://images.microbadger.com/badges/version/${dockerhub_prefix}/${id}.svg)](https://microbadger.com/images/${dockerhub_prefix}/${id} \"Get your own version badge on microbadger.com\")" >> "${readme_filename}"
    echo -n " [![](https://images.microbadger.com/badges/commit/${dockerhub_prefix}/${id}.svg)](https://microbadger.com/images/${dockerhub_prefix}/${id} \"Get your own commit badge on microbadger.com\")" >> "${readme_filename}"
    echo -n " [${dockerhub_prefix}/${id}](https://hub.docker.com/r/${dockerhub_prefix}/${id})" >> "${readme_filename}"
    echo "" >> "${readme_filename}"
    echo "" >> "${readme_filename}"
    echo "" >> "${readme_filename}"
}

add_gitlabci() {
    id="$1"

    echo "        - \"docker build -t ${gitlab_project_var}/${id}:latest ${dockerfiles_relative_dir}/gitlab/${id}/\"" >> "${gitlabci_filename}"
    echo "        - \"docker tag ${gitlab_project_var}/${id}:latest ${gitlab_project_var}/${id}:${VERSION}-\${CI_COMMIT_SHA:0:8}\"" >> "${gitlabci_filename}"
    echo "        - \"docker push ${gitlab_project_var}/${id}:latest\"" >> "${gitlabci_filename}"
    echo "        - \"docker push ${gitlab_project_var}/${id}:${VERSION}-\${CI_COMMIT_SHA:0:8}\"" >> "${gitlabci_filename}"
}

add_ghcr_action() {
    id="$1"

    echo "          - name: 'Build image ${id} \${{ env.GITHUB_SHA_SHORT }}'" >> "${ghcr_action_filename}"
    echo "            uses: docker/build-push-action@v2" >> "${ghcr_action_filename}"
    echo "            with:" >> "${ghcr_action_filename}"
    echo "                context: ${dockerfiles_relative_dir}/ghcr/${id}/" >> "${ghcr_action_filename}"
    echo "                build-args: |" >> "${ghcr_action_filename}"
    echo "                    VCS_REF=\${{ env.VCS_REF }}" >> "${ghcr_action_filename}"
    echo "                    BUILD_DATE=\${{ env.BUILD_DATE }}" >> "${ghcr_action_filename}"
    echo "                file: ${dockerfiles_relative_dir}/ghcr/${id}/Dockerfile" >> "${ghcr_action_filename}"
    echo "                push: \${{ github.event_name != 'pull_request' }}" >> "${ghcr_action_filename}"
    echo "                tags: ghcr.io/\${{ secrets.CR_USER }}/${id}:latest,ghcr.io/\${{ secrets.CR_USER }}/${id}:${VERSION},ghcr.io/\${{ secrets.CR_USER }}/${id}:${VERSION}-\${{ env.GITHUB_SHA_SHORT }},ghcr.io/\${{ secrets.CR_USER }}/${id}:\${{ env.GITHUB_SHA_SHORT }}" >> "${ghcr_action_filename}"
}

create_dockerfile_from_id() {
    id="$1"
    add_badge "${id}"
    for flavor in github gitlab ghcr local
    do
        pushd .>/dev/null
        mkdir -p "${dockerfiles_dir}/${flavor}/${id}"
        cp -f "${src_dir}/${id}.sh" "${dockerfiles_dir}/${flavor}/${id}/script.sh"
        cd "${dockerfiles_dir}/${flavor}/${id}"
        create_dockerfile "script.sh" "Dockerfile" "${id}" "${flavor}"
        create_build_hook "${id}" "${flavor}"
        create_makefile_parts "script.sh" "${id}" "${flavor}"
        popd>/dev/null
    done
    add_gitlabci "${id}"
    add_ghcr_action "${id}"
}

make_all() {
    init_readme
    init_gitlabci
    init_makefile
    init_ghcr_action

    for id in ${project_images}
    do
        create_dockerfile_from_id "${id}"
    done
}

set_version() {
    VERSION="$1"
    echo "VERSION=\"${VERSION}\"" > "${docker_builder_data_dir}/version.sh"

    make_all
}



name="$1"

if [ -z "${name}" ]; then
    make_all
else

    case "${name}" in
        clean)
            rm -f "${gitlabci_filename}" "${readme_filename}" "${ghcr_action_filename}"
            rm -rf "${dockerfiles_dir}"
            ;;
        set-version)
            set_version "$2"
            ;;
        version)
            echo "Current version : [${VERSION}]"
            ;;
        *)
            echo "Don't understand [${name}]"
    esac
fi


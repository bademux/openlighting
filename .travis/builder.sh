#!/bin/bash

set -e

declare -r proj_tmp="$PWD/tmp"

pre_install() {
  clone_source "git://github.com/OpenLightingProject/ola.git" "0.10.7" "$proj_tmp/ola" 

  # Registering file format recognizers since RUN command is used
  sudo docker run --privileged linuxkit/binfmt:v0.8
  # Update docker to the latest version and enable BuildKit
  bash ./.travis/scripts.sh update_docker
  sudo apt-get -y install git

}

post_install() {
  rm -rf $proj_tmp
}

clone_source() {
  declare -r url="${1}"
  declare -r tag="${2}"
  declare -r out_dir="${3}"
  declare -r user="$(id -u ${USER}):$(id -g ${USER})"

  mkdir -p $out_dir
  echo "Cloning $url $tag"
  git -c advice.detachedHead=false clone -b $tag --depth 1 "$url" "$out_dir"

}

build() {
  bash ./.travis/scripts.sh build_images "$@"
}

build_and_deploy() {
  declare -r image="${1}"
  echo "${DOCKER_PASSWORD}" | docker login -u "${DOCKER_USERNAME}" --password-stdin
  build "$@" --push
}


"$@"

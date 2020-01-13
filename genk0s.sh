#!/usr/bin/env bash

trap 'cleanup' EXIT INT TERM

sed_rules(){
  VERSION=$1
  cat <<EOF # | tee /dev/stderr
s,UA-36037335-10,UA-137403717-1,g
s,baseURL = "https://kubernetes.io",baseURL = "https://k0s.io/${VERSION}",g
s,url = "https://kubernetes.io",url = "/${VERSION}",g
s,https://v1-13.docs.kubernetes.io,/1.13,g
s,https://v1-14.docs.kubernetes.io,/1.14,g
s,https://v1-15.docs.kubernetes.io,/1.15,g
s,https://v1-16.docs.kubernetes.io,/1.16,g
s,https://v1-17.docs.kubernetes.io,/1.17,g
# s,https://kubernetes-io-vnext-staging.netlify.com/,https://k0s-io-vnext-staging.netlify.com/,g
EOF
}

prepare(){
  test -f hugo || wget -qO- https://github.com/gohugoio/hugo/releases/download/v0.62.2/hugo_extended_0.62.2_Linux-64bit.tar.gz | tar xz hugo
  export PATH=$PWD:$PATH
}

loop(){
  # for version in 1.1{4..7}; do
  # for version in 1.1{3,6}; do
  for version in 1.1{3..7}; do
  # for version in 1.17; do
    echo "============================================== Making $version"
    rm -rf $version
    git branch -D "k0s-${version}" &>/dev/null || :
    git checkout release-$version
    git checkout -b k0s-$version release-$version
    sed -i -f <(sed_rules $version) config.toml layouts/partials/head.html
    make build
    mv public $version
    git checkout -f .
  done
}

pack(){
  echo tar c k0s.tar 1.1{3..7}
}

main(){
  prepare
  loop
  pack
}

cleanup(){
  git checkout k0s
}

main "$@"

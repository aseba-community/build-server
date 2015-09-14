#!/bin/sh
set -eu

WORKSPACE=$1
BUILD_ID=$2

apt-get update

cd "$WORKSPACE/source"
debuild clean

git-dch --since=HEAD --snapshot "--snapshot-number=$BUILD_ID"
git commit --message "build #$BUILD_ID" debian/changelog

#TODO: make apt-get check signatures to get rid of --force-yes
mk-build-deps --install --tool "apt-get --no-install-recommends --assume-yes --force-yes" --remove
git-buildpackage -us -uc -tc

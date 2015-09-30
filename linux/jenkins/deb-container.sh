#!/bin/sh
set -eu

WORKSPACE=$1
BUILD_ID=$2

apt-get update

cd "$WORKSPACE/source"

mk-build-deps --install --tool "apt-get --no-install-recommends --assume-yes --force-yes" --remove

sudo -i -u jenkins /srv/linux/jenkins/deb-build.sh "$WORKSPACE" "$BUILD_ID"

debuild clean
git-buildpackage -us -uc

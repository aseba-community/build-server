#!/bin/sh
set -eu

RELEASE=$1
ARCH=$2

if [ ! -d machine ]
#TODO: use tar.xz
then sudo cp --recursive "/var/lib/container/$RELEASE-$ARCH" machine
fi

sudo systemd-nspawn\
 --directory=machine\
 "--machine=$BUILD_TAG"\
 --bind=/srv/linux\
 --bind=/var/lib/jenkins\
 /srv/linux/jenkins/deb-build.sh\
 "$WORKSPACE"

DEBIAN_DIR="$JENKINS_HOME/userContent/debian"
BINARY_DIR="dists/$RELEASE/$GIT_BRANCH/binary-$ARCH"
cp *.* "$DEBIAN_DIR/$BINARY_DIR"
cd "$DEBIAN_DIR"
dpkg-scanpackages "$BINARY_DIR" > "$BINARY_DIR/Packages"
